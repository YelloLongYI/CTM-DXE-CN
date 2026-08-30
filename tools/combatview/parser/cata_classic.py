"""Parser for Cataclysm Classic (build 4.4.2+) combat log format.

Format:
  MM/DD/YYYY HH:MM:SS.mmmm  EVENT_TYPE,Creature-0-...-NPCID-...,"Name",flags,flags2,...
"""

from __future__ import annotations
import re
import time
from datetime import datetime

from parser.base import BaseParser, split_csv
from models import SpellEvent, NPCUnit, Encounter, ParseResult


class CataClassicParser(BaseParser):
    format_name = "cata_classic"

    LINE_RE = re.compile(
        r'^(\d{1,2})/(\d{1,2})/(\d{4})\s+'
        r'(\d{1,2}):(\d{1,2}):(\d{1,2})\.(\d{1,4})\s+'
        r'([A-Z][A-Z_]+),(.*)$'
    )

    ENCOUNTER_RE = re.compile(
        r'^(\d{1,2})/(\d{1,2})/(\d{4})\s+'
        r'(\d{1,2}):(\d{1,2}):(\d{1,2})\.(\d{1,4})\s+'
        r'ENCOUNTER_(START|END),'
    )

    # Combat events with at least 8 comma fields after event type
    COMBAT_EVENTS = frozenset({
        "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_CAST_FAILED",
        "SPELL_AURA_APPLIED", "SPELL_AURA_REMOVED", "SPELL_AURA_REFRESH",
        "SPELL_DAMAGE", "SPELL_MISSED", "SPELL_HEAL", "SPELL_ENERGIZE",
        "SPELL_SUMMON", "SPELL_CREATE", "SPELL_INTERRUPT", "SPELL_DISPEL",
        "SPELL_STOLEN", "SPELL_PERIODIC_DAMAGE", "SPELL_PERIODIC_HEAL",
        "SPELL_PERIODIC_MISSED", "SPELL_PERIODIC_ENERGIZE",
        "SPELL_ABSORBED", "SPELL_INSTAKILL",
        "UNIT_DIED", "UNIT_DESTROYED",
        "SWING_DAMAGE", "RANGE_DAMAGE", "DAMAGE_SHIELD",
        "ENVIRONMENTAL_DAMAGE", "DAMAGE_SPLIT",
    })

    def detect(self, first_line: str) -> bool:
        """Detect Cata Classic by BUILD_VERSION mention or year in date."""
        return bool(re.search(r'BUILD_VERSION,4\.4', first_line))

    SILENCE_TIMEOUT_MS = 60_000  # 120s no NPC events → auto-close

    def parse(self, text: str, npc_db: dict | None = None,
              non_combat_spell_ids: set[str] | None = None) -> ParseResult:
        t0 = time.perf_counter()
        lines = text.split("\n")
        if lines and lines[0].startswith("\ufeff"):
            lines[0] = lines[0][1:]

        # Build encounter groups from npc_db
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

        # Dynamic mapping: encounter_id (from log) → enc_key (from npc_db name match)
        enc_id_to_key: dict[int, str] = {}

        encounters: list[Encounter] = []
        # active encounter per enc_key
        key_enc: dict[str, Encounter] = {}
        # keys that have been closed (don't reopen)
        closed_keys: set[str] = set()
        line_num = 0
        match_count = 0
        miss_count = 0

        def _close(key: str, end_abs: float, success: bool) -> None:
            enc = key_enc.pop(key, None)
            if enc:
                enc.end_abs = end_abs
                enc.success = success
                enc.end_line = line_num
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
                enc.start_line = line_num
                key_enc[key] = enc
                encounters.append(enc)
            return key_enc[key]

        for line in lines:
            line_num += 1
            line = line.strip()
            if not line:
                continue

            # ---- ENCOUNTER_START ----
            if "ENCOUNTER_START" in line[:50]:
                abs_t = self._parse_encounter_time(line)
                eid = self._extract_int_field(line, 1)
                matched_key = enc_id_to_key.get(eid)
                if not matched_key:
                    # Just use the first active encounter's key (only one encounter
                    # is active before any END has fired)
                    matched_key = next(iter(key_enc), None)
                if eid > 0 and matched_key:
                    enc_id_to_key[eid] = matched_key
                if matched_key:
                    if matched_key not in key_enc:
                        closed_keys.discard(matched_key)
                        enc = _get_or_create(matched_key, abs_t)
                        if enc:
                            enc._named = True
                    else:
                        enc = key_enc[matched_key]
                        enc._named = True
                        enc.start_line = line_num
                continue

            # ---- ENCOUNTER_END ----
            if "ENCOUNTER_END" in line[:50]:
                eid = self._extract_int_field(line, 1)
                matched_key = enc_id_to_key.get(eid)
                if matched_key:
                    _close(matched_key, self._parse_encounter_time(line),
                           self._extract_int_field(line, 5) == 1)
                continue

            # ---- combat event ----
            ev = self._parse_line(line)
            if ev is None:
                miss_count += 1
                continue
            match_count += 1

            # Find enc_key for this NPC
            ekey = npc_to_enc.get(ev.src_npc_id) or npc_to_enc.get(ev.dst_npc_id)
            if ekey is None:
                continue  # unknown NPC, skip entirely

            # UNIT_DIED on defeat target → close
            if ev.event_type == "UNIT_DIED" and ev.dst_npc_id > 0:
                for grp_key, grp in enc_groups.items():
                    if grp["defeat"] == ev.dst_npc_id:
                        _close(grp_key, ev.abs_time, True)
                        break

            # Add to encounter
            # Skip non-combat spells (player casts that don't start combat)
            if non_combat_spell_ids and ev.spell_id and ev.spell_id in non_combat_spell_ids:
                continue

            if ev.src_npc_id:
                # A boss's aura expiring on a player (e.g. a debuff wearing off)
                # is not evidence the boss is being fought; don't open a new
                # encounter from it. Still record it once the fight is active.
                if (ev.event_type == "SPELL_AURA_REMOVED"
                        and ev.dst_npc_id >= 1_000_000_000
                        and ekey not in key_enc):
                    continue
                if ekey in key_enc:
                    enc = key_enc[ekey]
                    last = getattr(enc, "_last_npc", 0.0)
                    if not getattr(enc, "_named", False) and last > 0 and ev.abs_time - last > self.SILENCE_TIMEOUT_MS:
                        _close(ekey, last, False)
                        closed_keys.discard(ekey)
                enc = _get_or_create(ekey, ev.abs_time)
                if enc is None:
                    continue
                ev.rel_time = (ev.abs_time - enc.start_abs) / 1000.0
                self._add_npc_event(enc, ev, ev.src_npc_id, ev.src_name)
                enc._last_npc = ev.abs_time
            elif ev.dst_npc_id and ev.event_type in ("SPELL_SUMMON", "SPELL_CREATE"):
                if ekey in key_enc:
                    enc = key_enc[ekey]
                    ev.rel_time = (ev.abs_time - enc.start_abs) / 1000.0
                    self._add_npc_event(enc, ev, ev.dst_npc_id, ev.dst_name)
            elif ev.dst_npc_id and ev.event_type in ("SPELL_SUMMON", "SPELL_CREATE"):
                if ekey in key_enc:
                    enc = key_enc[ekey]
                    ev.rel_time = (ev.abs_time - enc.start_abs) / 1000.0
                    self._add_npc_event(enc, ev, ev.dst_npc_id, ev.dst_name)

        # End of file
        for key in list(key_enc.keys()):
            enc = key_enc[key]
            _close(key, getattr(enc, "_last_npc", enc.start_abs), False)

        # Finalize
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

    def _parse_line(self, line: str) -> SpellEvent | None:
        m = self.LINE_RE.match(line)
        if not m:
            return None
        parts: list[str] = split_csv(m.group(9))
        if len(parts) < 8:
            return None
        event_type = m.group(8)
        if event_type not in self.COMBAT_EVENTS:
            return None

        abs_time = self._parse_abs_time(m)
        src_guid = parts[0]
        src_name = self._strip_quotes(parts[1])
        dst_guid = parts[4]
        dst_name = self._strip_quotes(parts[5])

        is_spell = event_type.startswith("SPELL_")
        src_npc_id = self._extract_npc_id(src_guid) or self._extract_player_id(src_guid)
        dst_npc_id = self._extract_npc_id(dst_guid) or self._extract_player_id(dst_guid)
        return SpellEvent(
            rel_time=0.0,
            abs_time=abs_time,
            event_type=event_type,
            src_guid=src_guid,
            src_name=src_name,
            src_npc_id=src_npc_id if (src_guid.startswith("Player-") or not self._is_player_pet(parts[2])) else 0,
            dst_guid=dst_guid,
            dst_name=dst_name,
            dst_npc_id=dst_npc_id if (dst_guid.startswith("Player-") or not self._is_player_pet(parts[6])) else 0,
            spell_id=parts[8] if is_spell and len(parts) > 8 else "",
            spell_name=self._strip_quotes(parts[9]) if is_spell and len(parts) > 9 else "",
            spell_school=self._safe_int(parts[10]) if is_spell and len(parts) > 10 and parts[10] else 0,
            amount=self._safe_int(parts[11]) if is_spell and len(parts) > 11 and parts[11] else 0,
            raw_line=line,
        )

    def _add_npc_event(self, enc: Encounter, ev: SpellEvent, npc_id: int, name: str) -> None:
        if npc_id not in enc.npcs:
            enc.npcs[npc_id] = NPCUnit(npc_id=npc_id, name=name)
        enc.npcs[npc_id].events.append(ev)
        enc.events.append(ev)

    @staticmethod
    def _extract_npc_id(guid: str) -> int:
        """Extract NPC ID from Creature-0-ZONE-INST-UK-NPCID-SPAWNUID."""
        if not guid or not (guid.startswith("Creature-") or guid.startswith("Vehicle-")):
            return 0
        parts = guid.split("-")
        if len(parts) >= 6:
            try:
                return int(parts[5])
            except ValueError:
                return 0
        return 0

    @staticmethod
    def _extract_player_id(guid: str) -> int:
        """Player GUID: Player-<realm>-<lowguid>. Return offset ID."""
        if not guid.startswith("Player-"):
            return 0
        parts = guid.split("-")
        if len(parts) >= 3:
            try:
                return 1_000_000_000 + int(parts[2], 16)
            except ValueError:
                return 0
        return 0

    @staticmethod
    def _strip_quotes(s: str) -> str:
        return s.strip('"') if s else ""

    @staticmethod
    def _safe_int(s: str) -> int:
        """Parse int from string that may be decimal or hex (0x prefix)."""
        try:
            return int(s, 0)
        except (ValueError, TypeError):
            return 0

    @staticmethod
    def _is_player_pet(flag_str: str) -> bool:
        if not flag_str:
            return False
        try:
            flags = int(flag_str, 0)
        except (ValueError, TypeError):
            return False
        # Pet bits: 0x100 (pet), 0x400 (guardian), 0x800 (possess)
        # Player type: 0x511, 0x512
        # Totems/ghouls/army: these have player sub-type bits set
        player_type = flags & 0xFF00
        # Player sub-types (0x500, 0x1100, 0x2100, etc.) → pet/totem/guardian
        # NPC sub-type is typically 0x0000, 0x0800, 0x0A00
        if player_type in (0x0500, 0x1100, 0x2100, 0x4100):
            return True
        return bool(flags & (0x511 | 0x400 | 0x2000))

    @staticmethod
    def _parse_abs_time(m: re.Match[str]) -> float:
        month, day = int(m.group(1)), int(m.group(2))
        year = int(m.group(3))
        h, mn, sec = int(m.group(4)), int(m.group(5)), int(m.group(6))
        ms_str = m.group(7)
        ms = int(ms_str)
        if len(ms_str) > 3:
            ms = ms // (10 ** (len(ms_str) - 3))
        elif len(ms_str) < 3:
            ms = ms * (10 ** (3 - len(ms_str)))
        dt = datetime(year, month, day, h, mn, sec, ms * 1000)
        return dt.timestamp() * 1000.0

    def _parse_encounter_time(self, line: str) -> float:
        m = self.ENCOUNTER_RE.search(line)
        if m:
            return self._parse_abs_time(m)
        return 0.0

    @staticmethod
    def _extract_encounter_name(line: str) -> str:
        parts = line.split(",")
        if len(parts) >= 3:
            return parts[2].strip('"')
        return "(unknown)"

    @staticmethod
    def _extract_int_field(line: str, index: int) -> int:
        parts = split_csv(line)
        try:
            return int(parts[index], 0) if len(parts) > index else 0
        except (ValueError, IndexError):
            return 0
