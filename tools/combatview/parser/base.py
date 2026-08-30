"""Base parser interface."""

from __future__ import annotations
from abc import ABC, abstractmethod
from models import ParseResult


def split_csv(line: str) -> list[str]:
    """Split a WoW combat-log CSV line, respecting double-quoted fields.

    Unit/spell names may contain commas (e.g. ``"Invisible Stalker (Cataclysm
    Boss, Ignore Combat, Floating)"``); a naive ``str.split(",")`` would break
    the field layout. WoW escapes an embedded quote as a doubled ``""``.
    """
    parts: list[str] = []
    cur: list[str] = []
    in_quotes = False
    i = 0
    n = len(line)
    while i < n:
        ch = line[i]
        if ch == '"':
            if in_quotes and i + 1 < n and line[i + 1] == '"':
                cur.append('"')
                i += 1
            else:
                in_quotes = not in_quotes
        elif ch == ',' and not in_quotes:
            parts.append(''.join(cur))
            cur = []
        else:
            cur.append(ch)
        i += 1
    parts.append(''.join(cur))
    return parts


class BaseParser(ABC):
    format_name: str = "unknown"

    @abstractmethod
    def parse(self, text: str, npc_db: dict | None = None,
              non_combat_spell_ids: set[str] | None = None) -> ParseResult:
        ...

    @abstractmethod
    def detect(self, first_line: str) -> bool:
        """Return True if this parser can handle the given log format."""
        ...
