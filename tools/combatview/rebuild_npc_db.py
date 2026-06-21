"""Regenerate npc_db.json from all DXE Encounters.lua files."""
import re, json
from pathlib import Path

root = Path(__file__).resolve().parent.parent.parent
npc_db = {}

for enc_path in sorted(root.glob("DXE_*/Encounters.lua")):
    text = enc_path.read_text(encoding="utf-8", errors="replace")

    blocks = re.finditer(
        r"\bdo\b\s+local data\s*=\s*\{.*?DXE:RegisterEncounter\(data\)\s*end",
        text, re.DOTALL,
    )
    for block in blocks:
        b = block.group()

        key_m = re.search(r'key\s*=\s*"([^"]+)"', b)
        if not key_m:
            continue
        key = key_m.group(1)
        if key == "common":
            continue

        zone_m = re.search(r'zone\s*=\s*L\.zone\["([^"]+)"\]', b)
        zone = zone_m.group(1) if zone_m else ""

        name_m = re.search(r'name\s*=\s*L\.\w+\["([^"]+)"\]', b)
        if not name_m:
            name_m = re.search(r'name\s*=\s*"([^"]+)"', b)
        name = name_m.group(1) if name_m else key

        scan_section = re.search(r"scan\s*=\s*\{([^}]+)\}", b)
        if not scan_section:
            continue
        scan_text = scan_section.group(1)
        npc_ids = re.findall(r"(\d{4,6})", scan_text)

        is_trash = key.endswith("trash") or name.lower() == "trash"

        for i, nid_str in enumerate(npc_ids):
            nid = int(nid_str)
            nc = re.search(rf"{nid_str},\s*--\s*([^\n]+)", scan_text)
            if not nc:
                nc = re.search(rf"{nid_str}\s*--\s*([^\n]+)", b)
            npc_name = nc.group(1).strip().rstrip("*").strip() if nc else f"NPC_{nid}"

            role = "trash" if is_trash else ("boss" if i == 0 else "add")
            npc_db[str(nid)] = {"n": npc_name, "r": role, "z": zone, "e": key, "en": name}

sorted_db = dict(sorted(npc_db.items(), key=lambda x: int(x[0])))
out = root / "tools" / "combatview" / "npc_db.json"
with open(out, "w", encoding="utf-8") as f:
    json.dump(sorted_db, f, indent=2, ensure_ascii=False)

print(f"{len(sorted_db)} NPCs written")
bosses = sum(1 for v in sorted_db.values() if v["r"] == "boss")
adds = sum(1 for v in sorted_db.values() if v["r"] == "add")
trash = sum(1 for v in sorted_db.values() if v["r"] == "trash")
print(f"  {bosses} boss, {adds} add, {trash} trash")
