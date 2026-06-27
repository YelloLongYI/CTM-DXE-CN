"""Base parser interface."""

from __future__ import annotations
from abc import ABC, abstractmethod
from models import ParseResult


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
