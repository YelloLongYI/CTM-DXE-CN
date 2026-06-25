# CombatView

WOW Combat Log Analyzer — 拖入 WoWCombatLog.txt，提取 BOSS/NPC 技能时间轴，辅助 DXE encounter 脚本编写。

## 启动

```
python tools\combatview\combatview.py
```

或双击 `tools\combatview\run.bat`。

中文日志文件会自动检测编码（UTF-8 / GBK / GB18030）。

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
| NPC 选择 | 只看某个 BOSS/小怪/玩家 | 勾选/取消，☐ 只显示已分类 |
| 法术选择 | 只看某个技能 | 勾选/取消，右键法术列 → 只看/不看 |
| 事件类型 | 只看 CAST/AURA 等 | 勾选/取消，右键事件列 → 只看/不看 |

## 右键菜单

| 位置 | 选项 |
|------|------|
| 事件列 | 只看该事件类型 / 不看该事件类型 |
| 法术列 | 只看该法术 / 不看该法术 |
| 时间轴 (📊 按钮) | 重新标记 NPC 为 Boss/小怪/Trash |

## 解析原理

不依赖 `ENCOUNTER_START`/`ENCOUNTER_END` 的精确配对，而是按 `encounter_key` 将 NPC 分组：

```
同一 encounter_key 下的所有 NPC 事件 → 归入同一场 encounter

ENCOUNTER_START  → 通过 encounter_id 对标，给 encounter 命名
ENCOUNTER_END    → 通过 encounter_id 对标，关闭 encounter
defeat_npc_id 死亡 → 标记击杀
新 ENCOUNTER_START → 自动重开同名 encounter（支持灭团重试）
encounter_key 含 "trash" → 自动跳过（通道小怪不创建 encounter）
```

多阶段 BOSS 战（如升腾者议会 P1 议会成员 + P3 源质畸体）会被正确合并为一场。

## 配置文件

### `npc_db.json`

NPC 分类数据库，从 DXE 全部 `Encounters.lua` 的 `triggers.scan` 提取，格式：

```json
{
  "47120": {
    "name": "Argaloth",
    "role": "boss",
    "zone": "Baradin Hold",
    "encounter_key": "argaloth",
    "encounter_name": "Argaloth",
    "defeat_npc_id": 47120
  },
  "43735": {
    "name": "Elementium Monstrosity",
    "role": "boss",
    "zone": "The Bastion of Twilight",
    "encounter_key": "ascendcouncil",
    "encounter_name": "Ascendant Council",
    "defeat_npc_id": 43735
  }
}
```

| 字段 | 含义 |
|------|------|
| `name` | NPC 名字 |
| `role` | 角色：`boss` / `add` / `trash` |
| `zone` | 副本名 |
| `encounter_key` | 分组依据，同一 key 下的 NPC 归入同一场 BOSS 战 |
| `encounter_name` | BOSS 战显示名 |
| `defeat_npc_id` | 死亡标记击杀的 NPC ID |

运行 `python tools\combatview\rebuild_npc_db.py` 可从 DXE 重新同步。

### `config.json`

```json
{
  "hidden_event_types": ["SPELL_ABSORBED"]
}
```

`hidden_event_types` 中的事件类型默认不显示。**只读**，需手动编辑此文件来修改。运行时的勾选/取消不写回。

### `~/.combatview_npc.json`

用户右键标记的 NPC 分类，优先级高于 `npc_db.json`。

## 导出

| 格式 | 说明 |
|------|------|
| Lua | DXE 计时器格式：`{ [time] = { "spell", "type", "npc" } }` |
| JSON | 结构化数据，含全部 NPC 和事件 |

## 测试

```
python tools\combatview\test\test_parser.py combatlog_1        # 验证
python tools\combatview\test\test_parser.py combatlog_1 --save # 保存预期
```

目录结构：

```
tools/combatview/test/
├── test_parser.py
├── expected/
│   └── combatlog_1.json          ← 与 data/ 下同名
└── data/
    └── combatlog_1.txt
```

预期文件记录每场 BOSS 战的名称、时长（秒）、事件数。改 parser 后跑一次确保不破坏现有解析逻辑。

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
