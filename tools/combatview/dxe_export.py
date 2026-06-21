"""Export Encounter data to DXE Lua timer format and JSON."""

from __future__ import annotations
import json
from datetime import datetime

from models import Encounter


def export_lua(enc: Encounter) -> str:
    lines = [
        f"-- {enc.name} — 技能时间轴 (由 CombatView 自动生成)",
        f"-- 战斗时长: {enc.duration:.1f}s",
        f"-- 导出时间: {datetime.now().isoformat()}",
        "",
        "local timers = {",
    ]

    boss_ids = {n.npc_id for n in enc.npcs.values() if n.role in ("boss", "add")}
    seen: set[str] = set()
    all_ev = []

    for ev in enc.events:
        if ev.src_npc_id not in boss_ids:
            continue
        if ev.event_type not in (
            "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED"
        ):
            continue
        key = f"{ev.rel_time:.1f}_{ev.spell_name}"
        if key in seen:
            continue
        seen.add(key)
        all_ev.append(ev)

    all_ev.sort(key=lambda e: e.rel_time)

    for ev in all_ev:
        cat = _categorize(ev)
        src = enc.npcs.get(ev.src_npc_id)
        npc_name = src.name if src else ev.src_name
        lines.append(
            f'    [{ev.rel_time:.1f}] = {{ "{_esc_lua(ev.spell_name)}", '
            f'"{cat}", "{_esc_lua(npc_name)}" }},'
        )

    lines.append("}")
    lines.append("return timers")
    return "\n".join(lines) + "\n"


def export_json(enc: Encounter) -> str:
    data = {
        "name": enc.name,
        "duration": round(enc.duration, 1),
        "npcs": [
            {
                "id": npc.npc_id,
                "name": npc.name,
                "role": npc.role,
                "eventCount": len(npc.events),
                "events": [
                    {
                        "t": round(ev.rel_time, 1),
                        "type": ev.event_type,
                        "spell": ev.spell_name,
                        "spellId": ev.spell_id,
                        "school": ev.spell_school,
                        "target": ev.dst_name,
                        "amount": ev.amount,
                    }
                    for ev in sorted(npc.events, key=lambda e: e.rel_time)
                ],
            }
            for npc in enc.npcs.values()
        ],
    }
    return json.dumps(data, ensure_ascii=False, indent=2)


def _categorize(ev) -> str:
    name = (ev.spell_name or "").lower()
    if ev.event_type == "SPELL_AURA_APPLIED":
        if "buff" in name or "enrage" in name:
            return "buff"
        return "aura"
    if ev.event_type == "SPELL_CAST_START":
        return "cast"
    if "summon" in name or "spawn" in name:
        return "summon"
    if any(w in name for w in ("breath", "blast", "nova", "wave")):
        return "frontal"
    if "strike" in name or "cleave" in name:
        return "melee"
    return "ability"


def _esc_lua(s: str) -> str:
    return (s or "").replace("\\", "\\\\").replace('"', '\\"')
