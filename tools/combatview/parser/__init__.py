"""Parser auto-detection and dispatching."""

from parser.base import BaseParser
from parser.cata_classic import CataClassicParser
from parser.cata_original import CataOriginalParser
from models import ParseResult

_parsers: list[BaseParser] = [
    CataClassicParser(),
    CataOriginalParser(),
]


def detect_format(first_line: str) -> BaseParser | None:
    for p in _parsers:
        if p.detect(first_line):
            return p
    # fallback: try each parser
    for p in _parsers:
        if p.LINE_RE.match(first_line):
            return p
    return None


def parse_log(text: str) -> ParseResult | None:
    """Parse WoWCombatLog.txt content. Auto-detects format."""
    if not text.strip():
        return None
    first = text.split("\n", 1)[0].strip()
    if first.startswith("\ufeff"):
        first = first[1:]
    parser = detect_format(first)
    if parser is None:
        return None
    return parser.parse(text)
