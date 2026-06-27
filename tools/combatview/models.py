"""Data models for CombatView."""

from __future__ import annotations
from dataclasses import dataclass, field


@dataclass
class SpellEvent:
    rel_time: float              # seconds from encounter start
    abs_time: float              # UTC timestamp in milliseconds
    event_type: str              # SPELL_CAST_START, SPELL_AURA_APPLIED, etc.
    src_guid: str
    src_name: str
    src_npc_id: int
    dst_guid: str
    dst_name: str
    dst_npc_id: int
    spell_id: str
    spell_name: str
    spell_school: int
    amount: int
    raw_line: str


@dataclass
class NPCUnit:
    npc_id: int
    name: str
    role: str = "unknown"        # boss / add / trash / unknown
    events: list[SpellEvent] = field(default_factory=list)


@dataclass
class Encounter:
    name: str
    encounter_id: int
    difficulty: int
    group_size: int
    start_abs: float             # UTC milliseconds
    end_abs: float               # UTC milliseconds
    duration: float = 0.0        # seconds
    success: bool = False
    start_line: int = 0           # log line number of first NPC event or START
    end_line: int = 0             # log line number of close event
    npcs: dict[int, NPCUnit] = field(default_factory=dict)
    events: list[SpellEvent] = field(default_factory=list)

    @property
    def boss_npcs(self) -> list[NPCUnit]:
        return [n for n in self.npcs.values() if n.role == "boss"]

    @property
    def add_npcs(self) -> list[NPCUnit]:
        return [n for n in self.npcs.values() if n.role == "add"]

    def shift_start(self, new_start_abs: float) -> None:
        if not hasattr(self, "_original_start_abs"):
            self._original_start_abs = self.start_abs
            self._original_duration = self.duration
        self.start_abs = new_start_abs
        for ev in self.events:
            ev.rel_time = (ev.abs_time - self.start_abs) / 1000.0
        all_times = [ev.rel_time for ev in self.events]
        self.duration = max(all_times) - min(all_times) if all_times else 0.0

    def reset_start(self) -> None:
        if hasattr(self, "_original_start_abs"):
            self.start_abs = self._original_start_abs
            self.duration = self._original_duration
            for ev in self.events:
                ev.rel_time = (ev.abs_time - self.start_abs) / 1000.0
            delattr(self, "_original_start_abs")
            delattr(self, "_original_duration")


@dataclass
class ParseResult:
    encounters: list[Encounter]
    raw_lines: int
    parse_time: float            # seconds
    log_format: str              # "cata_classic" or "cata_original"
