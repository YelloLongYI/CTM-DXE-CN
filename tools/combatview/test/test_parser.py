"""Test parser output against expected encounter breakdown.

Usage:
    python tools/combatview/test/test_parser.py combatlog_1
    python tools/combatview/test/test_parser.py combatlog_1 --save
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(ROOT))

from parser import parse_log

DATA_DIR = Path(__file__).resolve().parent / "data"


def get_log_path(name: str) -> Path:
    p = DATA_DIR / f"{name}.txt"
    if not p.exists():
        print(f"Log not found: {p}")
        sys.exit(1)
    return p


def get_expected_path(name: str) -> Path:
    return Path(__file__).resolve().parent / "expected" / f"{name}.json"


def run(log_path: Path) -> list[dict]:
    npc_db_path = Path(__file__).resolve().parent.parent / "npc_db.json"
    with open(npc_db_path, encoding="utf-8") as f:
        npc_db = json.load(f)
    for enc_name in ("utf-8-sig", "utf-8", "gbk", "gb18030"):
        try:
            with open(log_path, encoding=enc_name, errors="replace") as f:
                text = f.read()
            if "ENCOUNTER_START" in text:
                break
        except Exception:
            continue
    result = parse_log(text, npc_db)
    if result is None:
        print("FAIL: parse_log returned None")
        sys.exit(1)
    return [
        {
            "name": enc.name,
            "duration": int(round(enc.duration)),
            "event_count": len(enc.events),
            "start_line": enc.start_line,
            "end_line": enc.end_line,
        }
        for enc in result.encounters
    ]


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python test_parser.py <log_name> [--save]")
        print("  log_name = combatlog_1 (without .txt extension)")
        sys.exit(1)

    name = sys.argv[1]
    log_path = get_log_path(name)
    actual = run(log_path)
    expected_path = get_expected_path(name)

    if "--save" in sys.argv:
        with open(expected_path, "w", encoding="utf-8") as f:
            json.dump(actual, f, indent=2, ensure_ascii=False)
        print(f"Saved {len(actual)} encounters to {expected_path.name}")
        return

    try:
        with open(expected_path, encoding="utf-8") as f:
            expected = json.load(f)
    except FileNotFoundError:
        print(f"No expected file: {expected_path}")
        print("Run with --save first.")
        sys.exit(1)

    if actual == expected:
        print(f"PASS: {name}.txt → {len(actual)} encounters match")
    else:
        print("FAIL: mismatch!")
        print("  Expected:")
        for e in expected:
            print(f"    {e}")
        print("  Actual:")
        for e in actual:
            print(f"    {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
