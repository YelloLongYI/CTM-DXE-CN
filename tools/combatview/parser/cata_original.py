"""Parser for original Cataclysm (build 4.3.4 and below) combat log format.

Format:
  MM/DD HH:MM:SS.mmm  EVENT_TYPE,0xF130...,"Name",0xF130,0x0,...
"""

from __future__ import annotations
import re
import time
from datetime import datetime

from parser.base import BaseParser
from models import SpellEvent, NPCUnit, Encounter, ParseResult


class CataOriginalParser(BaseParser):
    format_name = "cata_original"

    LINE_RE = re.compile(
        r'^(\d{1,2})/(\d{1,2})\s+'
        r'(\d{1,2}):(\d{1,2}):(\d{1,2})\.(\d{1,3})\s+'
        r'([A-Z][A-Z_]+),(.*)$'
    )

    ENCOUNTER_RE = re.compile(
        r'^(\d{1,2})/(\d{1,2})\s+'
        r'(\d{1,2}):(\d{1,2}):(\d{1,2})\.(\d{1,3})\s+'
        r'ENCOUNTER_(START|END),'
    )

    COMBAT_EVENTS = frozenset({
        "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_CAST_FAILED",
        "SPELL_AURA_APPLIED", "SPELL_AURA_REMOVED", "SPELL_AURA_REFRESH",
        "SPELL_DAMAGE", "SPELL_MISSED", "SPELL_HEAL", "SPELL_ENERGIZE",
        "SPELL_SUMMON", "SPELL_CREATE", "SPELL_INTERRUPT", "SPELL_DISPEL",
        "SPELL_STOLEN", "SPELL_PERIODIC_DAMAGE", "SPELL_PERIODIC_HEAL",
        "UNIT_DIED", "UNIT_DESTROYED",
        "SWING_DAMAGE", "RANGE_DAMAGE", "DAMAGE_SHIELD",
        "ENVIRONMENTAL_DAMAGE", "DAMAGE_SPLIT",
    })

    # Old format: no srcFlags2/dstFlags2, fewer fields
    # srcGUID,srcName,srcFlags,dstGUID,dstName,dstFlags[,spellID,spellName,spellSchool]
    SPELL_ID_IDX   = 6   # spellID
    SPELL_NAME_IDX = 7   # spellName
    SPELL_SCHOOL_IDX = 8 # spellSchool
    AMOUNT_IDX     = 9   # amount

    def detect(self, first_line: str) -> bool:
        """Detect old format: no year in timestamp, hex GUID prefix."""
        # Check for hex GUID pattern early in a data line
        return bool(re.search(r'0x[0-9A-Fa-f]{12,}', first_line))

    SILENCE_TIMEOUT_MS = 60_000

    def parse(self, text: str, npc_db: dict | None = None) -> ParseResult:
        t0 = time.perf_counter()
        lines = text.split("\n")
        if lines and lines[0].startswith("\ufeff"):
            lines[0] = lines[0][1:]

        enc_groups: dict[str, dict] = {}
        npc_to_enc: dict[int, str] = {}
        if npc_db:
            for nid_str, entry in npc_db.items():
                ekey = entry.get("encounter_key", "")
                if not ekey or "trash" in ekey.lower():
                    continue
                if ekey not in enc_groups:
                    enc_groups[ekey] = {
                        "npcs": set(),
                        "defeat": entry.get("defeat_npc_id", 0),
                        "name": entry.get("encounter_name", ekey),
                    }
                enc_groups[ekey]["npcs"].add(int(nid_str))
            for ekey, grp in enc_groups.items():
                for nid in grp["npcs"]:
                    npc_to_enc.setdefault(nid, ekey)

        enc_id_to_key: dict[int, str] = {}
        encounters: list[Encounter] = []
        key_enc: dict[str, Encounter] = {}
        closed_keys: set[str] = set()
        line_num = 0
        match_count = 0
        miss_count = 0
        current_year = datetime.now().year

        def _close(key: str, end_abs: float, success: bool) -> None:
            enc = key_enc.pop(key, None)
            if enc:
                enc.end_abs = end_abs
                enc.success = success
                closed_keys.add(key)

        def _get_or_create(key: str, abs_t: float) -> Encounter | None:
            if key in closed_keys:
                return None
            if key not in key_enc:
                grp = enc_groups.get(key, {})
                enc = Encounter(
                    name=grp.get("name", key),
                    encounter_id=0, difficulty=0, group_size=0,
                    start_abs=abs_t, end_abs=0.0,
                )
                enc._key = key
                encounters.append(enc)
                key_enc[key] = enc
            return key_enc[key]

        for line in lines:
            line_num += 1
            line = line.strip()
            if not line:
                continue

            if "ENCOUNTER_START" in line[:50]:
                eid = self._extract_int_field(line, 1)
                matched_key = enc_id_to_key.get(eid) or next(iter(key_enc), None)
                if eid > 0 and matched_key:
                    enc_id_to_key[eid] = matched_key
                if matched_key:
                    closed_keys.discard(matched_key)
                    if matched_key not in key_enc:
                        _get_or_create(matched_key, self._parse_encounter_time(line, current_year))
                continue

            if "ENCOUNTER_END" in line[:50]:
                eid = self._extract_int_field(line, 1)
                matched_key = enc_id_to_key.get(eid)
                if matched_key:
                    _close(matched_key, self._parse_encounter_time(line, current_year),
                           self._extract_int_field(line, 4) == 1)
                continue

            ev = self._parse_line(line, current_year)
            if ev is None:
                miss_count += 1
                continue
            match_count += 1

            ekey = npc_to_enc.get(ev.src_npc_id) or npc_to_enc.get(ev.dst_npc_id)
            if ekey is None:
                continue

            if ev.event_type == "UNIT_DIED" and ev.dst_npc_id > 0:
                for grp_key, grp in enc_groups.items():
                    if grp["defeat"] == ev.dst_npc_id:
                        _close(grp_key, ev.abs_time, True)
                        break

            if ev.src_npc_id:
                enc = _get_or_create(ekey, ev.abs_time)
                if enc is None:
                    continue
                ev.rel_time = (ev.abs_time - enc.start_abs) / 1000.0
                self._add_npc_event(enc, ev, ev.src_npc_id, ev.src_name)
            elif ev.dst_npc_id and ev.event_type in ("SPELL_SUMMON", "SPELL_CREATE"):
                if ekey in key_enc:
                    enc = key_enc[ekey]
                    ev.rel_time = (ev.abs_time - enc.start_abs) / 1000.0
                    self._add_npc_event(enc, ev, ev.dst_npc_id, ev.dst_name)

        for key in list(key_enc.keys()):
            enc = key_enc[key]
            _close(key, enc.start_abs, False)

        for enc in encounters:
            if enc.end_abs > enc.start_abs:
                enc.duration = (enc.end_abs - enc.start_abs) / 1000.0
            enc.events.sort(key=lambda e: e.rel_time)
            for npc in enc.npcs.values():
                npc.events.sort(key=lambda e: e.rel_time)

        t1 = time.perf_counter()
        return ParseResult(
            encounters=encounters,
            raw_lines=line_num,
            parse_time=round(t1 - t0, 3),
            log_format=self.format_name,
        )

    # --- internal ---

    def _parse_line(self, line: str, year: int) -> SpellEvent | None:
        m = self.LINE_RE.match(line)
        if not m:
            return None
        parts: list[str] = m.group(8).split(",")
        if len(parts) < 6:
            return None
        event_type = m.group(7)
        if event_type not in self.COMBAT_EVENTS:
            if not event_type.startswith("SPELL_"):
                return None

        abs_time = self._parse_abs_time(m, year)
        src_guid = parts[0]
        src_name = self._strip_quotes(parts[1])
        dst_guid = parts[3]
        dst_name = self._strip_quotes(parts[4])

        is_spell = event_type.startswith("SPELL_")
        spell_id = parts[self.SPELL_ID_IDX] if is_spell and len(parts) > self.SPELL_ID_IDX else ""
        spell_name = self._strip_quotes(parts[self.SPELL_NAME_IDX]) if is_spell and len(parts) > self.SPELL_NAME_IDX else ""
        spell_school = self._safe_int(parts[self.SPELL_SCHOOL_IDX]) if is_spell and len(parts) > self.SPELL_SCHOOL_IDX and parts[self.SPELL_SCHOOL_IDX] else 0
        amount = self._safe_int(parts[self.AMOUNT_IDX]) if is_spell and len(parts) > self.AMOUNT_IDX and parts[self.AMOUNT_IDX] else 0

        return SpellEvent(
            rel_time=0.0,
            abs_time=abs_time,
            event_type=event_type,
            src_guid=src_guid,
            src_name=src_name,
            src_npc_id=(self._extract_npc_id_hex(src_guid) or self._extract_player_id_hex(src_guid)) if (not src_guid.startswith("0xF130") or not self._is_player_pet(parts[2])) else 0,
            dst_guid=dst_guid,
            dst_name=dst_name,
            dst_npc_id=(self._extract_npc_id_hex(dst_guid) or self._extract_player_id_hex(dst_guid)) if (not dst_guid.startswith("0xF130") or not self._is_player_pet(parts[5])) else 0,
            spell_id=spell_id,
            spell_name=spell_name,
            spell_school=spell_school,
            amount=amount,
            raw_line=line,
        )

    def _add_npc_event(self, enc: Encounter, ev: SpellEvent, npc_id: int, name: str) -> None:
        if npc_id not in enc.npcs:
            enc.npcs[npc_id] = NPCUnit(npc_id=npc_id, name=name)
        enc.npcs[npc_id].events.append(ev)
        enc.events.append(ev)

    @staticmethod
    def _extract_npc_id_hex(guid: str) -> int:
        if not guid or not guid.startswith("0x"):
            return 0
        hex_str = guid[2:].upper()
        if len(hex_str) >= 12:
            try:
                return int(hex_str[8:12], 16)
            except ValueError:
                return 0
        return 0

    @staticmethod
    def _extract_player_id_hex(guid: str) -> int:
        """Player hex GUID: 0x0000000000001234 → offset ID from low 24 bits."""
        if not guid or not guid.startswith("0x"):
            return 0
        hex_str = guid[2:].upper()
        if len(hex_str) >= 12 and not hex_str.startswith("F13"):
            try:
                return 1_000_000_000 + int(hex_str, 16) % 1_000_000
            except ValueError:
                return 0
        return 0

    @staticmethod
    def _strip_quotes(s: str) -> str:
        return s.strip('"') if s else ""

    @staticmethod
    def _safe_int(s: str) -> int:
        try:
            return int(s, 0)
        except (ValueError, TypeError):
            return 0

    @staticmethod
    def _is_player_pet(flag_str: str) -> bool:
        if not flag_str:
            return False
        flags = int(flag_str, 0)
        player_type = flags & 0xFF00
        if player_type in (0x0500, 0x1100, 0x2100, 0x4100):
            return True
        return bool(flags & (0x511 | 0x400 | 0x2000))

    @staticmethod
    def _parse_abs_time(m: re.Match[str], year: int) -> float:
        month, day = int(m.group(1)), int(m.group(2))
        h, mn, sec = int(m.group(3)), int(m.group(4)), int(m.group(5))
        ms_str = m.group(6)
        ms = int(ms_str)
        if len(ms_str) < 3:
            ms = ms * (10 ** (3 - len(ms_str)))
        dt = datetime(year, month, day, h, mn, sec, ms * 1000)
        return dt.timestamp() * 1000.0

    def _parse_encounter_time(self, line: str, year: int) -> float:
        m = self.ENCOUNTER_RE.search(line)
        if m:
            return self._parse_abs_time(m, year)
        return 0.0

    @staticmethod
    def _extract_encounter_name(line: str) -> str:
        parts = line.split(",")
        if len(parts) >= 3:
            return parts[2].strip('"')
        return "(unknown)"

    @staticmethod
    def _extract_int_field(line: str, index: int) -> int:
        parts = line.split(",")
        try:
            return int(parts[index], 0) if len(parts) > index else 0
        except (ValueError, IndexError):
            return 0
