# DXE Encounter 数据结构参考

> 记录 DXE 副本模块 `Encounters.lua` 的开发细节——字段含义、event 类型、参数映射、版本差异。编写或调试补丁数据时的速查手册。

---

## 一、Encounter 顶层字段

```lua
local data = {
    version = 5,                    -- 数据版本号
    key = "halfus",                 -- encounter 唯一标识（补丁匹配用）
    zone = L.zone["..."],           -- 所属区域
    category = L.zone["..."],       -- Pane 分类
    name = L.npc_xxx["..."],        -- BOSS 显示名
    icon = "Interface\\...",        -- Encounter Journal 图标路径
    triggers = { ... },             -- 触发条件
    onactivate = { ... },           -- 激活时行为
    userdata = { ... },             -- 运行时变量模板
    alerts = { ... },               -- 告警定义
    events = { ... },               -- 事件监听定义
    onstart = { ... },              -- 战斗开始命令序列
    announces = { ... },            -- 自动喊话/通知
    raidicons = { ... },            -- 团队标记
    arrows = { ... },               -- 屏幕箭头
    filters = { ... },              -- BOSS 喊话/表情过滤
    grouping = { ... },             -- Pane 告警分组
    ordering = { ... },             -- 告警排序
    timers = { ... },               -- 定时器
    windows = { ... },              -- 距离窗口配置
    phrasecolors = { ... },         -- BOSS 名称着色
}
```

---

## 二、Event 类型

DXE 通过 `type` 字段区分两套事件系统：

### 2.1 `type = "event"` — WoW API 事件

监听通过 `RegisterEvent` 注册的原生 WoW 事件，搭配 `event` 字段指定事件名：

```lua
{
    type = "event",
    event = "YELL",         -- → CHAT_MSG_MONSTER_YELL
    execute = { ... },
}

{
    type = "event",
    event = "UNIT_SPELLCAST_SUCCEEDED",
    execute = { ... },
}
```

支持的 `event` 别名（Invoker.lua `REG_ALIASES`，第 2775 行）：

| `event` | 实际 WoW 事件 |
|---------|-------------|
| `YELL` | `CHAT_MSG_MONSTER_YELL` |
| `EMOTE` | `CHAT_MSG_RAID_BOSS_EMOTE` |
| `WHISPER` | `CHAT_MSG_RAID_BOSS_WHISPER` |
| `SAY` | `CHAT_MSG_MONSTER_SAY` |
| `BG_ALLY` | `CHAT_MSG_BG_SYSTEM_ALLIANCE` |
| `BG_HORDE` | `CHAT_MSG_BG_SYSTEM_HORDE` |
| `BG_NEUTRAL` | `CHAT_MSG_BG_SYSTEM_NEUTRAL` |

未列在别名表中的 event 值直接作为 WoW 事件名注册（如 `UNIT_SPELLCAST_SUCCEEDED`、`UNIT_TARGET` 等）。

**参数映射**：按事件原始参数顺序直接编入 `#1#`、`#2#` 等。

```
UNIT_SPELLCAST_SUCCEEDED:
    #1# = unitId   (e.g., "boss1", "player")
    #2# = spellName

YELL / EMOTE:
    #1# = message
    #2# = sender  （4.3.4 为 sender NPC 名，4.4.2 可能为 GUID）
```

> ⚠️ **4.4.2 Classic 兼容性**：`UNIT_SPELLCAST_SUCCEEDED` / `UNIT_SPELLCAST_START` / `UNIT_SPELLCAST_INTERRUPTED` 在 4.4.2 中仅对玩家控制的 unit 触发，NPC BOSS 不再触发。需改为 `combatevent` 类型。

### 2.2 `type = "combatevent"` — 战斗日志事件

监听统一的 `COMBAT_LOG_EVENT_UNFILTERED`，搭配 `eventtype` + `spellname`/`spellid` 过滤：

```lua
-- 单法术
{
    type = "combatevent",
    eventtype = "SPELL_CAST_START",
    spellname = 81031,              -- 法术 ID（数字）或法术名（字符串）
    execute = { ... },
}

-- 多法术
{
    type = "combatevent",
    eventtype = "SPELL_CAST_START",
    spellname = {86408, 86406},     -- 匹配数组中任一法术
    execute = { ... },
}

-- 不按法术过滤（匹配所有该 eventtype）
{
    type = "combatevent",
    eventtype = "UNIT_DIED",
    execute = { ... },
}
```

**spellname 过滤机制**（Invoker.lua `combat_attr_handles`，第 2674 行）：

- `spellname = 81031` — 按数字 ID 匹配，框架通过 `SN[81031]` 查法术名后比对
- `spellname = "Shadowblaze Spark"` — 按字符串名匹配
- `spellid = 81031` — 直接按 ID 匹配（不经过 SN 转换）
- `spellname2` / `spellid2` — 匹配目标法术（dest spell）

支持的 `eventtype`（常用）：

| eventtype | COMBAT_LOG 子事件 | 触发时机 |
|-----------|-------------------|---------|
| `SPELL_CAST_START` | `SPELL_CAST_START` | 开始施法 |
| `SPELL_CAST_SUCCESS` | `SPELL_CAST_SUCCESS` | 施法成功 |
| `SPELL_DAMAGE` | `SPELL_DAMAGE` | 造成伤害 |
| `SPELL_AURA_APPLIED` | `SPELL_AURA_APPLIED` | 光环施加 |
| `SPELL_AURA_APPLIED_DOSE` | `SPELL_AURA_APPLIED_DOSE` | 光环层数增加 |
| `SPELL_AURA_REMOVED` | `SPELL_AURA_REMOVED` | 光环移除 |
| `SPELL_HEAL` | `SPELL_HEAL` | 治疗 |
| `UNIT_DIED` | `UNIT_DIED` | 单位死亡 |
| `ENCOUNTER_START` | `ENCOUNTER_START` | 副本 encounter 开始 |
| `ENCOUNTER_END` | `ENCOUNTER_END` | 副本 encounter 结束 |

**参数映射**：`main_event_handler` 接收的参数按固定位置编入 `#1#` ~ `#N#`（Invoker.lua 第 2754 / 2766 行）：

```
4.3.4 / 4.4.2 统一映射:
    #1#  = srcGUID        -- 施法者 GUID
    #2#  = srcName        -- 施法者名称
    #3#  = srcFlags       -- 施法者标志
    #4#  = dstGUID        -- 目标 GUID
    #5#  = dstName        -- 目标名称
    #6#  = dstFlags       -- 目标标志
    #9#  = spellID        -- 法术 ID
    #10# = spellName      -- 法术名称
```

`#7#` ~ `#8#` 和 `#11#` 之后为 combat log 的额外参数（吸收量、过疗量等），取决于具体 eventtype。

> 与 `event` 类型的关键区别：`combatevent` 的 `#1#` 是 GUID 字符串（如 `Creature-0-3-669-0-41376-000000068A`），不是 unit ID（如 `"boss1"`）。因此 `"expect",{"#1#","find","boss"}` 这类 unit 名检测在 `combatevent` 中无效。应改用 `srcisnpctype` 过滤器或通过 spellname 过滤确保来源为 BOSS。

**`srcisnpctype` 过滤器**：在 event 定义中添加 `srcisnpctype = true`，只匹配施法者为 NPC 的事件。

### 2.3 选择建议

| 场景 | 推荐 | 原因 |
|------|:--:|------|
| 法术施放/打断/光环 | `combatevent` | COMBAT_LOG 跨版本一致，自动 spellname 过滤 |
| BOSS 喊话/表情 | `event` (YELL/EMOTE) | 战斗日志不包含聊天内容 |
| 单位死亡 | `combatevent` | 统一用 combat log 处理 |
| 法术打断 | `combatevent` (SPELL_CAST_START) | `UNIT_SPELLCAST_INTERRUPTED` 4.4.2 仅玩家触发 |

---

## 三、告警定义（alerts）

每个告警是一个字典，key 在 encounter 内唯一：

```lua
alerts = {
    enragecd = {
        varname   = L.alert["Berserk CD"],            -- Options 面板显示名
        type      = "dropdown",                       -- 告警类型
        text      = L.alert["Berserk"],               -- 战斗中计时条显示文字
        time      = 360,                              -- 冷却时间（秒）
        flashtime = 10,                               -- 闪烁提前量（秒）
        color1    = "RED",                            -- 主色
        color2    = "ORANGE",                         -- 闪烁色
        icon      = ST[12317],                        -- 法术/技能图标
        sound     = "ALERT4",                         -- 音效
        sticky    = true,                             -- sticky 不随 boss 切换消失
        behavior  = "overwrite",                      -- 覆盖模式
    },

    novacd = {
        varname   = format(L.alert["%s CD"], SN[86168]),  -- 动态法术名
        type      = "dropdown",
        text      = format(L.alert["Next %s"], SN[86168]),
        time      = 12,
        time2     = 11,                               -- 第二段时间（可选）
        time3     = "<novadelayed>",                  -- 可用 userdata 变量
        flashtime = 3,
        color1    = "MAGENTA",
        icon      = ST[86168],
        sound     = "MINORWARNING",
    },
},
```

### 字段说明

| 字段 | 必需 | 说明 |
|------|:--:|------|
| `varname` | ✅ | Options 面板下拉树中的告警名字 |
| `type` | ✅ | `"dropdown"`=计时条, `"simple"`=纯文字, `"centerpopup"`=屏幕中央弹窗 |
| `text` | | 战斗中计时条显示的提示文字 |
| `time` | ✅ | 主冷却时间（秒），可为数字或 `"<userdata_var>"` 引用 userdata |
| `time2` | | 第二段冷却时间 |
| `time3` | | 第三段冷却时间 |
| `flashtime` | | 计时条闪烁提前量（秒） |
| `color1` | | 主色（`"RED"`, `"ORANGE"`, `"CYAN"` 等） |
| `color2` | | 闪烁色 |
| `icon` | | `ST[spellID]` — 法术图标纹理 |
| `sound` | | 音效 ID（`"ALERT4"`, `"MINORWARNING"`, `"RUNAWAY"` 等） |
| `throttle` | | 节流时间（秒），防止重复触发 |
| `sticky` | | `true` 则不随 BOSS 切换消失 |
| `behavior` | | `"overwrite"` — 覆盖模式下行为 |
| `emphasizewarning` | | `true` 或 `{1, 0.5}` 强调警告 |
| `flashscreen` | | `true` 时屏幕闪烁 |
| `audiocd` | | `true` 时播放音频冷却提示 |

### type 取值

| type | 行为 |
|------|------|
| `"dropdown"` | 在 Pane 中显示为可展开的计时条 |
| `"simple"` | 纯文字警告，不在 Pane 显示 |
| `"centerpopup"` | 屏幕中央弹窗告警 |
| `"cd"` | 仅倒计时，不显示 |
| `"absorb"` | 吸收量告警（配合 `values` 表） |

---

## 四、Invoker 命令速查

`events[].execute[]` 和 `onstart[]` 中的命令列表（Invoker.lua）。

### 告警控制

| 命令 | 用法 | 说明 |
|------|------|------|
| `"alert"` | `"alert","novacd"` | 启动/重置告警计时器 |
| `"alert"` | `"alert",{"novacd", time = 2}` | 启动告警，延迟 2 秒后显示 |
| `"schedulealert"` | `"schedulealert",{"novacd", 3}` | 延迟 3 秒启动告警 |
| `"quash"` | `"quash","novacd"` | 取消指定告警 |
| `"quashall"` | `"quashall",true` | 取消所有当前 active 的告警 |

### 条件控制

| 命令 | 用法 | 说明 |
|------|------|------|
| `"expect"` | `"expect",{"#4#","==","&playerguid&"}` | 条件不满足 → 停止执行当前块 |
| `"expect"` | `"expect",{"<phase>","==","2"}` | 检查 userdata 变量 |
| `"invoke"` | `"invoke",{ {expect..., action...}, {...} }` | 条件分支，依次检查直到命中 |

`expect` 支持的运算符：`==`, `~=`, `<`, `>`, `<=`, `>=`, `find`（字符串包含匹配）。

### 变量操作

| 命令 | 用法 | 说明 |
|------|------|------|
| `"set"` | `"set",{phase = 2}` | 设置 userdata 变量 |
| `"set"` | `"set",{count = "INCR\|1"}` | 递增数值 |
| `"set"` | `"set",{count = "DECR\|1"}` | 递减数值 |
| `"insert"` | `"insert",{"mylist","value"}` | 往容器类 userdata 添加元素 |

### 定时器

| 命令 | 用法 | 说明 |
|------|------|------|
| `"scheduletimer"` | `"scheduletimer",{"mytimer", 5}` | 5 秒后执行命令 |
| `"canceltimer"` | `"canceltimer","mytimer"` | 取消定时器 |
| `"repeattimer"` | `"repeattimer",{"mytimer", 1}` | 每秒重复执行 |

### 团队工具

| 命令 | 用法 | 说明 |
|------|------|------|
| `"raidicon"` | `"raidicon","mymark"` | 放置团队标记 |
| `"removeraidicon"` | `"removeraidicon","#5#"` | 移除指定玩家的标记 |
| `"radar"` | `"radar","myradar"` | 打开距离雷达窗口 |
| `"removeradar"` | `"removeradar",{"myradar", player = "#5#"}` | 移除雷达上的玩家 |
| `"arrow"` | `"arrow","myarrow"` | 屏幕箭头指示 |
| `"removearrow"` | `"removearrow","#5#"` | 移除箭头 |
| `"range"` | `"range",{true}` | 开启/关闭距离检测 |
| `"counter"` | `"counter","mycounter"` | 激活计数器 |
| `"removecounter"` | `"removecounter","mycounter"` | 移除计数器 |
| `"tracing"` | `"tracing",{43735}` | 动态追踪 NPC |
| `"temptracing"` | `"temptracing","#4#"` | 临时追踪单位 |
| `"hidephasemarker"` | `"hidephasemarker",{1,1}` | 隐藏阶段标记 |

### 通信

| 命令 | 用法 | 说明 |
|------|------|------|
| `"announce"` | `"announce","mysay"` | 触发 announces 中定义的自动喊话 |
| `"send"` | `"send","mycomm"` | 发送自定义通信 |

### 特殊参数引用

| 符号 | 含义 |
|------|------|
| `#1#` ~ `#N#` | 事件参数（按位置） |
| `&playerguid&` | 玩家 GUID |
| `&playername&` | 玩家名称 |
| `&difficulty&` | 副本难度（1=10N, 2=25N, 3=10H, 4=25H） |
| `&npcid\|#4#&` | 从 GUID 提取 NPC ID |
| `&unitguid\|src&` | 施法者 GUID |
| `&unitisplayertype\|#1#&` | 检查是否是玩家 |
| `&listsize\|listname&` | 容器列表长度 |
| `&timeleft\|alertname&` | 告警剩余时间 |

---

## 五、userdata 变量

```lua
userdata = {
    chargetext   = "",                                -- 普通字符串
    furiouscount = 0,                                 -- 普通数值
    phase        = 1,                                 -- 阶段变量
    scorchingbreathcd = {11, 23, 21,
                         loop = false, type = "series"},  -- 冷却序列
    engulfunits  = {type = "container", wipein = 3},      -- 容器列表
    shifttext    = "",                                     -- 动态文本模板
},
```

### 变量类型

| 类型 | 声明 | 读写 |
|------|------|------|
| 普通值 | `varname = 0` 或 `varname = ""` | `"set",{varname = ...}` |
| 冷却序列 | `{11, 23, 21, loop = false, type = "series"}` | 由 alert 的 `time` 引用 |
| 容器列表 | `{type = "container", wipein = 3}` | `"insert"` 写入，`&listsize\|name&` 读取 |

### 在 alert 中引用

告警的 `time` 字段可以引用 userdata：
```lua
-- alert 中
time = "<scorchingbreathcd>",   -- 从 userdata 取冷却序列
time = 12,                       -- 固定数字
```

### 在 event 中引用

事件执行块中通过 `"<varname>"` 引用：
```lua
"expect",{"<phase>","==","2"},
"set",{phase = 3},
```

---

## 六、GUID 解析（NID）

Core.lua 第 744 行的 `NID` metatable 负责 GUID → NPC ID 提取：

| GUID 格式 | 示例 | 解析方式 |
|-----------|------|---------|
| Classic | `Creature-0-3-671-0-43686-0000000047` | `strsplit("-")` 取第 6 段（十进制） |
| Legacy hex | `0xF130006D42003A26` | `sub(guid, 9, 12)` 取 16 进制 NPC ID |
| New hex (DF+) | … | `sub(guid, 7, 10)` |

检测优先级：`guid:find("^Creature%-")` → Legacy hex → New hex。**不依赖 `GetBuildInfo()`**，使得 Gilneas 等私服（GUID 为 Classic 格式但 build 不是 4.4.0）也能正确提取 NPC ID。

`NID` 的结果被以下功能使用：
- `triggers.scan` — BOSS 进入战斗检测
- `onactivate.tracing` — BOSS 追踪
- `onactivate.defeat` — BOSS 死亡检测（`DEFEAT_NIDS` 标记所有击杀目标）
- 战斗日志中 `UNIT_DIED` 事件的 npcid 参数
