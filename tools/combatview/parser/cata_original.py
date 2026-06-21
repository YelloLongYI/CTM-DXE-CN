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

    def parse(self, text: str) -> ParseResult:
        t0 = time.perf_counter()
        lines = text.split("\n")
        if lines and lines[0].startswith("\ufeff"):
            lines[0] = lines[0][1:]

        encounters: list[Encounter] = []
        current_enc: Encounter | None = None
        current_start_abs: float = 0.0
        line_num = 0
        match_count = 0
        miss_count = 0

        current_year = datetime.now().year

        for line in lines:
            line_num += 1
            line = line.strip()
            if not line:
                continue

            if "ENCOUNTER_START" in line[:50]:
                name = self._extract_encounter_name(line)
                abs_t = self._parse_encounter_time(line, current_year)
                current_enc = Encounter(
                    name=name,
                    encounter_id=self._extract_int_field(line, 1),
                    difficulty=self._extract_int_field(line, 3),
                    group_size=self._extract_int_field(line, 4),
                    start_abs=abs_t,
                    end_abs=0.0,
                )
                current_start_abs = abs_t
                encounters.append(current_enc)
                continue

            if "ENCOUNTER_END" in line[:50]:
                if current_enc:
                    current_enc.end_abs = self._parse_encounter_time(line, current_year)
                    current_enc.success = self._extract_int_field(line, 4) == 1
                    current_enc = None
                    current_start_abs = 0.0
                continue

            ev = self._parse_line(line, current_year)
            if ev is None:
                miss_count += 1
                continue
            match_count += 1

            if current_enc:
                ev.rel_time = (ev.abs_time - current_start_abs) / 1000.0
                if ev.src_npc_id:
                    self._add_npc_event(current_enc, ev, ev.src_npc_id, ev.src_name)
                elif ev.dst_npc_id and ev.event_type in ("SPELL_SUMMON", "UNIT_DIED", "SPELL_CREATE"):
                    self._add_npc_event(current_enc, ev, ev.dst_npc_id, ev.dst_name)

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
