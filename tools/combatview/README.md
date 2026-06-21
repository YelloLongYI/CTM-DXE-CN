# CombatView

WOW Combat Log Analyzer — 拖入 WoWCombatLog.txt，提取 BOSS/NPC 技能时间轴，辅助 DXE encounter 脚本编写。

## 启动

```
python tools\combatview\combatview.py
```

或双击 `tools\combatview\run.bat`。

## 主界面

```
┌─────────────────┬──────────────────────────────────┬──────────────┐
│ 📋 战斗列表      │ 时间  │ 事件  │ NPC │ 法术 │ 目标 │ 🔍 事件详情   │
│                 ├──────────────────────────────────┤              │
│ ▼ 巴拉丁监狱     │ 0:03.1│ CAST │Arga │ 流星…│ 玩家 │ 时间: 0:03.1 │
│   Argaloth      │ 0:15.7│ AURA │Arga │ 狂暴 │ —   │ 施法者: ...  │
│                 │ 0:27.3│ CAST │Stor │ 暗影…│ 玩家 │ 事件: ...    │
├─────────────────┤                                  │              │
│ 选择 NPC        │                                  │              │
│ ☑ Argaloth     │                                  │              │
│ ☐ Twi Brute    │                                  │              │
│ ☐ 只显示已分类   │                                  │              │
├─────────────────┤                                  │              │
│ 选择法术         │                                  │              │
│ ☑ 流星猛击 (4)  │                                  │              │
│ ☑ 噬体毁灭 (3)  │                                  │              │
│ [全选] [全不选]  │                                  │              │
├─────────────────┤                                  │              │
│ 选择事件类型     │                                  │              │
│ ☑ SPELL_CAST…  │                                  │              │
│ ☐ SPELL_ABSOR… │                                  │              │
│ [全选] [全不选]  │                                  │              │
└─────────────────┴──────────────────────────────────┴──────────────┘
```

## 四层过滤器

从上到下同时生效，只有全部满足的事件才显示在表格中：

| 层级 | 作用 | 操作 |
|------|------|------|
| NPC 选择 | 只看某个 BOSS/小怪 | 勾选/取消，☐ 只显示已分类 |
| 法术选择 | 只看某个技能 | 勾选/取消，右键法术列 → 只看/不看 |
| 事件类型 | 只看 CAST/AURA 等 | 勾选/取消，右键事件列 → 只看/不看 |

## 右键菜单

| 位置 | 选项 |
|------|------|
| 事件列 | 只看该事件类型 / 不看该事件类型 |
| 法术列 | 只看该法术 / 不看该法术 |
| 时间轴 (📊 按钮) | 重新标记 NPC 为 Boss/小怪/Trash |

## 配置文件

### `npc_db.json`
NPC 分类数据库，从 DXE 全部 `Encounters.lua` 的 `triggers.scan` 提取，格式：

```json
{
  "47120": {"n": "Argaloth", "r": "boss", "z": "Baradin Hold", "e": "argaloth", "en": "Argaloth"},
  "44650": {"n": "Storm Rider", "r": "add", "z": "The Bastion of Twilight", "e": "halfus", "en": "Halfus Wyrmbreaker"}
}
```

| 字段 | 含义 |
|------|------|
| `n` | NPC 名字 |
| `r` | 角色：`boss` / `add` / `trash` |
| `z` | 副本名 |
| `e` | encounter key，可追溯到 DXE 中的哪个 BOSS 战 |
| `en` | encounter 显示名 |

运行 `python tools\combatview\rebuild_npc_db.py` 可从 DXE 重新同步。

### `config.json`
默认隐藏的事件类型：

```json
{
  "hidden_event_types": ["SPELL_ABSORBED"]
}
```

加载日志后这些类型默认不显示。在左侧勾选/取消后自动写回。

### `~/.combatview_npc.json`
用户右键标记的 NPC 分类，优先级高于 `npc_db.json`。

## 导出

| 格式 | 说明 |
|------|------|
| Lua | DXE 计时器格式：`{ [time] = { "spell", "type", "npc" } }` |
| JSON | 结构化数据，含全部 NPC 和事件 |

## 支持的日志格式

| 格式 | 识别方式 | Parser |
|------|---------|--------|
| Cataclysm Classic (4.4.2+) | `BUILD_VERSION,4.4` + `Creature-` GUID | `parser/cata_classic.py` |
| 原始 Cataclysm (4.3.4) | `0xF130` 十六进制 GUID | `parser/cata_original.py` |

自动检测，无需手动选择。

## 依赖

- Python >= 3.9
- PySide6 >= 6.5

```bash
pip install PySide6
```
