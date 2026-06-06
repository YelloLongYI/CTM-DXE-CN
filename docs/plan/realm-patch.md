# DXE Realm 补丁机制设计文档

> **目标**：允许 DXE 副本模块针对不同服务器（Realm）对 encounter 数据进行局部覆盖，核心数据 `Encounters.lua` 保持不变。

---

## 一、设计补丁数据

### 1.1 文件命名

每个副本模块可包含一个或多个 Realm 补丁文件，命名规范为：

```
DXE_<Module>/
├── Encounters.lua                  ← 基础数据（永远不动）
├── Data_<Module>_<Realm>.lua       ← 特定 Realm 的补丁数据
```

例：

```
DXE_Bastion/
├── Encounters.lua
├── Data_Bastion_Apollo.lua         ← 空（无差异）
├── Data_Bastion_JRG.lua            ← JRG 服差异
├── Data_Bastion_XXX.lua            ← 未来新增服务器
```

### 1.2 补丁文件结构

```lua
-- Data_Bastion_JRG.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST

DXE:RegisterRealmPatch("JRG", "halfus", {
    triggers = {
        scan = { 44600, 44650, 99999, 44797, 44652 },   -- NPC ID 不同
    },
    alerts = {
        enragecd = { time = 420 },                        -- 狂暴时间不同
        novacd   = { time = 14 },                         -- 技能 CD 不同
    },
})

DXE:RegisterRealmPatch("JRG", "chogall", {
    triggers = {
        scan = { 43324, 88888 },
        yell = "Worship me, mortals!",
    },
})

-- 无差异的 BOSS（valther、ascendcouncil、sinestra、bottrash）不写
```

`RegisterRealmPatch` 第一个参数为 Realm 标识，需与下拉框 key 一致。**文件不再需要 Realm 守卫**——所有补丁一次性注册到 `realmPatchDefs`，Realm 切换时通过 `ApplyRealmPatches` 动态匹配。

### 1.3 可补丁的数据范围

补丁仅处理**非本地化**的 encounter 字段。本地化数据（BOSS 名称、喊话文本、警报文本）由 `Locales.lua` 管理，不在补丁范围内。

| 类型 | 管理方式 | 例子 |
|------|----------|------|
| NPC ID、法术 ID | **补丁覆盖** | `triggers.scan`、`events.spellname` |
| 计时数值 | **补丁覆盖** | `alerts.<name>.time`、`userdata.<name>` |
| 颜色、音效、图标 | **补丁覆盖** | `alerts.<name>.color1`、`alerts.<name>.sound` |
| BOSS 名称 | 本地化 (`Locales.lua`) | `L.npc_bastion["Halfus Wyrmbreaker"]` |
| 喊话触发文本 | 本地化 (`Locales.lua`) | `L.chat_bastion["^Enough!"]` |
| 警报显示文本 | 本地化 (`Locales.lua`) | `L.alert["Berserk CD"]` |

---

## 二、补丁合并逻辑

### 2.1 deepMerge 算法

```lua
local function hasNumericKey(t)
    for k in pairs(t) do
        if type(k) == "number" and math.floor(k) == k then
            return true
        end
    end
    return false
end

local function deepMerge(target, source)
    for k, v in pairs(source) do
        -- ① false 表示删除此字段
        if v == false then
            target[k] = nil

        -- ② source 值是 table
        elseif type(v) == "table" then
            -- DXE.Replace 包裹 → 强制整表替换
            if getmetatable(v) and getmetatable(v).__dxe_replace then
                target[k] = v
            -- 含整数 key → 整表替换
            elseif hasNumericKey(v) then
                target[k] = v
            -- 纯字典 + target 存在同名字典 → 递归进入
            elseif type(target[k]) == "table" then
                deepMerge(target[k], v)
            -- 纯字典 + target 不存在 → 整表赋值（新增）
            else
                target[k] = v
            end

        -- ③ number、string、boolean → 直接覆盖
        else
            target[k] = v
        end
    end
end

DXE.Replace = function(t)
    return setmetatable(t, { __dxe_replace = true })
end
```

### 2.2 合并示例

**基础数据**：

```lua
EDB["halfus"].alerts.enragecd = {
    varname   = "Berserk CD",
    type      = "dropdown",
    text      = "Berserk",
    time      = 360,
    flashtime = 10,
    color1    = "RED",
    icon      = ST[12317],
}
```

**补丁数据**：

```lua
{ alerts = { enragecd = { time = 420 } } }
```

**合并过程**：

| 层级 | source key | 动作 |
|------|-----------|------|
| 1 | `alerts` | 字典 → 递归 |
| 2 | `enragecd` | 字典 → 递归 |
| 3 | `time` | 标量 → `target.time = 420` |

`flashtime`、`color1`、`icon` 等字段在 source 中不存在，不做任何操作。

**合并后**：

```lua
EDB["halfus"].alerts.enragecd = {
    varname   = "Berserk CD",    -- 保留
    type      = "dropdown",      -- 保留
    text      = "Berserk",       -- 保留
    time      = 420,             -- 已覆盖
    flashtime = 10,              -- 保留
    color1    = "RED",           -- 保留
    icon      = ST[12317],       -- 保留
}
```

### 2.3 关键规则

| 场景 | 补丁写法 | 结果 |
|------|----------|------|
| 覆盖单个字段 | `{ time = 14 }` | 只改 time，其余不动 |
| 覆盖多个字段 | `{ time = 14, flashtime = 5 }` | 只改 time 和 flashtime |
| 新增一整条 alert | `{ newalert = { time=30, ... } }` | alerts 字典内新增 key |
| 替换整个数组 | `scan = { 1, 2, 3 }` | hasNumericKey=true → 整表替换 |
| 删除一个 key | `{ obsolete = false }` | target.obsolete = nil |
| 不写的 BOSS | 不调用 `RegisterRealmPatch` | 零改动 |

---

## 三、加载补丁数据

### 3.1 TOC 文件

所有文件按顺序在 `.toc` 中列出，补丁文件必须在 `Encounters.lua` 之前加载：

```
# DXE_Bastion.toc
Locales.lua
Data_Bastion_Apollo.lua         ← 补丁文件先加载，注册到 realmPatchDefs
Data_Bastion_JRG.lua            ← 注册到 realmPatchDefs
Data_Bastion_Test.lua           ← 注册到 realmPatchDefs
Encounters.lua                  ← 最后注册，根据当前 Realm 合入补丁
```

### 3.2 Realm 配置

Realm 标识由玩家在 DXE 设置中手动配置，存储在 `DXE.db.profile.Globals.Realm`，默认值为 `"Apollo"`。切换 Realm 时触发 `ApplyRealmPatches()`，补丁立即生效无需 `/reload`。

```lua
-- Core.lua 默认设置
defaults = {
    profile = {
        Globals = {
            Realm = "Apollo",
        },
    },
}
```

### 3.2.1 从玩家配置到补丁生效 —— 完整流程

```
模块加载时（一次性）:
──────────────────────────────────
Data_Bastion_Apollo.lua   → RegisterRealmPatch("Apollo", ...) → 存入 realmPatchDefs
Data_Bastion_JRG.lua      → RegisterRealmPatch("JRG", ...)    → 存入 realmPatchDefs
Data_Bastion_Test.lua     → RegisterRealmPatch("Test", ...)   → 存入 realmPatchDefs
                                │
Encounters.lua            → RegisterEncounter → 读取 realmPatchDefs[currentRealm]
                                │
                                ▼
                          当前 Realm 匹配的补丁 → deepMerge 合入 data

切换 Realm 时（即时生效）:
──────────────────────────────────
Options 下拉框选 "JRG"  → ApplyRealmPatches("JRG")
                              │
                              ▼
                         realmPatchDefs["JRG"] → 遍历所有已加载的 encounter
                              │
                              ▼
                         PatchEncounter → deepMerge → ACR:NotifyChange 刷新 UI
```

> 无需 `/reload`，无需重新加载模块。补丁数据在模块首次加载时一次性注册，Realm 切换时即时应用。

**结论**：同一个 TOC 列出所有服务器文件，运行时根据 `DXE.db.profile.Globals.Realm` 的值，只有一个文件的补丁生效，其余全部跳过。不需要重新打包、不需要切换分支。

### 3.3 补丁持久化与即时应用

补丁文件**不直接修改 EDB**，而是通过 `RegisterRealmPatch(realm, key, patch)` 存入 `realmPatchDefs`：

```lua
addon.realmPatchDefs = setmetatable({}, { __mode = "v" })

function addon:RegisterRealmPatch(realm, key, patchTable)
    -- 持久存储
    self.realmPatchDefs[realm] = self.realmPatchDefs[realm] or {}
    self.realmPatchDefs[realm][key] = self.realmPatchDefs[realm][key] or {}
    self.realmPatchDefs[realm][key][#self.realmPatchDefs[realm][key] + 1] = patchTable

    -- 当前 Realm 匹配且 encounter 已加载 → 立即应用
    if self.db.profile.Globals.Realm == realm and self.EDB[key] then
        self:PatchEncounter(key, patchTable)
    end
end

function addon:ApplyRealmPatches(realm)
    for key, orig in pairs(self.EDB_original) do
        if key ~= "default" then
            -- 从 EDB_original 复原，重新合入目标 Realm 的补丁
            local restored = deepCopy(orig)
            local defs = self.realmPatchDefs[realm]
            if defs and defs[key] then
                for _, p in ipairs(defs[key]) do
                    deepMerge(restored, p)
                end
            end
            -- 注销旧 encounter，注册新 encounter，触发 Options 刷新
            self.callbacks:Fire("OnUnregisterEncounter", self.EDB[key])
            self.EDB[key] = restored
            self.callbacks:Fire("OnRegisterEncounter", restored)
        end
    end
    local ACR = LibStub("AceConfigRegistry-3.0", true)
    if ACR then ACR:NotifyChange("DXE") end
end
```

`RegisterEncounter` 内根据当前 Realm 从 `realmPatchDefs` 合入补丁：

```lua
function addon:RegisterEncounter(data)
    local key = data.key
    -- 保存原始数据副本，用于 Realm 切换时恢复
    local ok, copy = pcall(deepCopy, data)
    self.EDB_original[key] = ok and copy or {}

    -- 根据当前 Realm 合入补丁
    local currentRealm = self.db.profile.Globals.Realm
    if self.realmPatchDefs[currentRealm] and self.realmPatchDefs[currentRealm][key] then
        for _, p in ipairs(self.realmPatchDefs[currentRealm][key]) do
            deepMerge(data, p)
        end
    end
    -- ... 剩余注册逻辑 ...
end
```

---

### 4.3 完整生命周期

```
    启动登录                      进入副本                        BOSS 战
       │                             │                              │
       ▼                             ▼                              ▼
┌──────────────┐   ┌─────────────────────────┐   ┌──────────────────────────┐
│ DXE 核心初始化 │   │ Loader 按区域加载模块     │   │ Invoker 读取 CE           │
│ OnInitialize  │   │ 补丁文件 → realmPatchDefs │   │ CE = EDB["halfus"]        │
│ EDB 已就绪    │──▶│ Encounters → 按当前Realm  │──▶│ 此时已是补丁后的最终数据    │
│              │   │           合入补丁到 data  │   │ 透明生效                  │
└──────────────┘   │ EDB_original 留存原始数据  │   └──────────────────────────┘
                   └─────────────────────────┘
                             │
                   ┌─────────┴──────────┐
                   │ 切换 Realm（即时生效）  │
                   │ ApplyRealmPatches()  │
                   │  → EDB_original 复原   │
                   │  → 新 Realm 补丁合入   │
                   │  → OnUnregister+       │
                   │    OnRegister 回调     │
                   │  → ACR:NotifyChange    │
                   │    刷新 UI             │
                   └───────────────────────┘
```

### 4.4 安全保证

#### 补丁 key 不匹配

补丁的 key 必须与 `Encounters.lua` 中 `data.key` 完全一致，否则补丁**静默不生效**，不会报错也不会崩溃。

```lua
-- Encounters.lua 注册
data.key = "halfus"
DXE:RegisterEncounter(data)

-- 补丁文件（正确）
DXE:RegisterRealmPatch("JRG", "halfus", { ... })   -- ✅

-- 补丁文件（错误：key 写错）
DXE:RegisterRealmPatch("JRG", "halfus_typo", { ... })  -- ❌
```

执行流程：

```
RegisterRealmPatch("halfus_typo", patch)
    │
    ├── EDB["halfus_typo"] = nil（不存在，也不会被注册）
    │   → 入队列 realmPatches["halfus_typo"]
    │
    ▼
RegisterEncounter → EDB["halfus"] = data
    │
    └── realmPatches["halfus"] 为空 → realmPatches["halfus_typo"] 未被消费
        → 补丁永久滞留，不会触发任何警告
```

后续每次 `RegisterEncounter` 只消费匹配的 key，不会遍历整个队列做检查。因此**拼写错误不会报错**，只是补丁不生效。建议补丁文件中为每条 `RegisterRealmPatch` 加注释标注对应的 BOSS 名称，方便人工复查。

#### 其他场景

| 场景 | 行为 |
|------|------|
| 补丁引用了不存在的字段路径 | Lua 取 nil，静默创建新路径 |
| 多个补丁文件注册同一个 key | 队列依次消费，后面覆盖前面 |
| 补丁文件排在 Encounters 之前 | 入队列，RegisterEncounter 时消费 |
| 补丁文件排在 Encounters 之后 | EDB[key] 已存在，立即 deepMerge |

---

## 五、完整示例

**Encounters.lua**（基础数据，保持不变）：

```lua
do
    local data = {
        version = 7,
        key = "halfus",
        zone = L.zone["The Bastion of Twilight"],
        name = L.npc_bastion["Halfus Wyrmbreaker"],
        triggers = { scan = { 44600, 44650, 44645, 44797, 44652 } },
        alerts = {
            enragecd = { time = 360, flashtime = 10, color1 = "RED" },
            novacd   = { time = 12,  flashtime = 3,  color1 = "MAGENTA" },
        },
    }
    DXE:RegisterEncounter(data)
end
```

**Data_Bastion_JRG.lua**（补丁数据，仅差异）：

```lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST

DXE:RegisterRealmPatch("JRG", "halfus", {
    triggers = {
        scan = { 44600, 44650, 99999, 44797, 44652 },
    },
    alerts = {
        enragecd = { time = 420 },
    },
})
```

**补丁后的最终 EDB["halfus"]**：

```lua
{
    key = "halfus",
    triggers = { scan = { 44600, 44650, 99999, 44797, 44652 } },  -- 整表替换
    alerts = {
        enragecd = {
            time = 420,       -- 已覆盖
            flashtime = 10,   -- 保留
            color1 = "RED",   -- 保留
        },
        novacd = {
            time = 12,        -- 未改动
            flashtime = 3,    -- 未改动
            color1 = "MAGENTA", -- 未改动
        },
    },
}
```

---

## 六、关键发现

### 6.1 文件无需 Realm 守卫

补丁文件使用 `DXE:RegisterRealmPatch(realm, key, patch)` 声明目标 Realm，**不再需要文件头守卫**。所有补丁在模块加载时一次性注册到 `realmPatchDefs`，Realm 切换时通过 `ApplyRealmPatches` 即时匹配。

```lua
-- ✅ 当前写法
DXE:RegisterRealmPatch("JRG", "halfus", { ... })

-- ❌ 旧写法（已废弃）
if DXE.db.profile.Globals.Realm ~= "JRG" then return end
DXE:RegisterRealmPatch("halfus", { ... })
```

有守卫时，非当前 Realm 的补丁无法入库，切 Realm 后补丁丢失。

### 6.2 切换 Realm 即时生效

Realm 下拉框切换时调用 `DXE:ApplyRealmPatches(realm)`，遍历 `realmPatchDefs` 中该 Realm 的所有补丁并应用到已加载的 encounter，然后 `ACR:NotifyChange` 刷新 UI。无需 `/reload`。

### 6.3 数据文件禁止包含 RegisterEncounter

每个副本模块只能 `Encounters.lua` 调用 `RegisterEncounter`。补丁文件只能用 `DXE:RegisterRealmPatch`。

### 6.4 EDB 为 Core.lua 的 local 变量

`RegisterRealmPatch` 和 `PatchEncounter` 内必须使用 `self.EDB`（`addon.EDB`），闭包中直接引用 local `EDB` 可能为 `nil`。

### 6.5 TOC 加载顺序

补丁文件必须在 `Encounters.lua` 之前加载。

---

## 七、代码改动清单

| 文件 | 改动 |
|------|------|
| `DXE/Core.lua` | 新增 `hasNumericKey`、`deepMerge`、`DXE.Replace` 工具函数；新增 `realmPatchDefs` 持久存储、`RegisterRealmPatch(realm, key, patch)`、`PatchEncounter`、`ApplyRealmPatches(realm)`；`RegisterEncounter` 开头按当前 Realm 合入补丁 |
| `DXE_Options/Options.lua` | Realm 下拉框 set 函数末尾调用 `ApplyRealmPatches` |
| 各模块 `Data_<Module>_<Realm>.lua` | 不含文件头守卫，只用 `DXE:RegisterRealmPatch(realm, key, patch)` |
| 各模块 `DXE_<Module>.toc` | `Data_*` 补丁文件排在 `Encounters.lua` 之前 |

---

## 八、未来计划：数组补丁优化

> **状态：设计阶段，均未实现**

### 8.1 方案A：`_N` 命名索引

#### 8.1.1 动机

当前 `deepMerge` 遇到数组（`hasNumericKey = true`）执行整表替换。补丁中 `events`、`onstart`、`grouping` 等数组字段必须完整复制 base 的全部元素，即使只改了其中一条的 spellname。

以 `anhuur` 为例，补丁中 `events` 需要复制 base 的全部 6 个 event（104 行），而实际差异仅 3 个 spellname。

#### 8.1.2 方案

补丁中数组改用 `_1`/`_5`/`_N` 命名 key 声明差异，框架按名称匹配 base 数组位置执行逐元素合并。`_` 前缀遵循 Lua 惯例，表示"框架内部标记"，不绑定任何字段语义，适用于所有数组字段：

```lua
-- events：只改第 1、2、5 个 event
events = {
    _1 = { spellname = 75592 },
    _2 = { spellname = 75592 },
    _5 = { spellname = 75322 },
},

-- onstart：只改第 1 条命令
onstart = {
    _1 = { "alert", "newcd" },
},

-- grouping：用 DXE.Replace 整体替换 + 命名索引改内部
grouping = DXE.Replace({
    _2 = { alerts = {"phalanxwarn", "phalanxduration"} },
}),

-- triggers.scan：只改第 1 个 NPC ID
triggers = {
    scan = DXE.Replace({
        _1 = 99999,
        _100 = 88888,    -- 支持任意位数
    }),
},
```

**命名规范**：
- key 格式：`_\d+`（下划线 + 任意位数字），如 `_1`、`_10`、`_100`
- 数字为 base 数组的 1-based 索引（Lua 数组最小索引为 1）
- 作用域限定在所在 table 内：`events._1` 和 `onstart._1` 互不冲突

**对比**：

| | 当前（整表替换） | 命名索引 |
|---|---|---|
| 补丁行数（anhuur events） | 104 行（全抄 6 个 event） | 6 行（只写差异） |
| base 增删中间 event | 补丁位置错乱须重写 | `_5` 永远命中位置 5 |
| 可读性 | 看不出差异 | 一眼就知改了哪些 |
| 新增 event | 必须全抄 | `_7 = {...}` 即可 |

#### 8.1.3 deepMerge 检测逻辑

在 `hasNumericKey` 之前插入命名数组检测：

```
deepMerge(target, source):
  for k, v in source:
    ...
    ② type(v) == "table":
       a) DXE.Replace → 整表替换
       b) isNamedArray(v) + target[k] 是 array
          → 对每个 nk, nv in v:
              idx = tonumber(nk:match("^_(%d+)$"))
              if target[k][idx] exists → deepMerge(target[k][idx], nv)
       c) hasNumericKey(v) + target[k] 是 array
          → 按 index 逐元素合并
       d) target[k] 是 table → 递归合并
       e) 否则 → 赋值
```

其中 `isNamedArray` 检测 table 的所有 key 是否匹配模式 `_\d+`（至少有一个 key）。

#### 8.1.4 最终结果

补丁合并后 target 的数组仍是 `{ {...}, {...}, ... }` 纯数组格式，`_1`/`_5` 仅作为临时匹配索引，不会残留。`DXE.Replace` 仍可在任意层级强制整表替换。

#### 8.1.5 优劣

| 优点 | 缺点 |
|------|------|
| 零 base 改动 | 位置偏移时须手动更新 `_N` |
| 实现简单，仅需 `isNamedArray` + regex | `_3` 不直观，需对照 base 数位置 |
| 适用于所有数组字段 | |

---

### 8.2 方案B：Tag 匹配

> **状态：设计阶段，未实现**

#### 8.2.1 方案

给需要被补丁修改的数组元素加 `tag` 语义标签，补丁按 tag 匹配而非按位置。**只有被 patch 的条目需要 tag，其余条目不动。**

**Base Encounters.lua** — 仅 e2（blitz）和 e5（malady）加 tag：

```lua
events = {
    { spellname = 90249, ... },                         -- [1] 无 tag → 永久不变
    { tag = "blitz",  spellname = 90250, ... },         -- [2] 有 tag → 可被补丁匹配
    { type = "emote", ... },                            -- [3] 无 tag
    { type = "yell", ... },                             -- [4] 无 tag
    { tag = "malady", spellname = 90170, ... },         -- [5] 有 tag → 可被补丁匹配
    { ... },                                            -- [6] 无 tag
},
```

**Gilneas 补丁** — 只写有差异的，按 tag 匹配：

```lua
events = {
    { tag = "blitz",  spellname = 74670 },              -- 匹配 base[2]
    { tag = "malady", spellname = 74699 },              -- 匹配 base[5]
},
```

#### 8.2.2 合并逻辑

```
deepMerge(base.events, patch.events):

1. 扫描 base，建 tag → index 映射:  { blitz→2, malady→5 }

2. 遍历 patch:
   patch[1]: tag="blitz" → 在映射中找到 → base[2]
             deepMerge(base[2], {spellname=74670})
             → base[2].spellname=74670, type/eventtype/execute 保留
   patch[2]: tag="malady" → base[5]
             deepMerge(base[5], {spellname=74699})

3. 未匹配 entry:
   base[1][3][4][6] (无 tag 或 tag 不在 patch 中) → 原封不动
```

**四种情况**：

| | base 有 tag | base 无 tag |
|---|---|---|
| **patch 有匹配** | ✅ deepMerge，只改指定字段 | —（匹配不到，静默跳过） |
| **patch 无对应条目** | ✅ base 原封不动 | ✅ base 原封不动 |
| **patch 有 tag 但 base 无** | — | 追加到末尾 |

#### 8.2.3 deepMerge 检测逻辑

与方案 A 的 `isNamedArray` 并列，优先检测 tag：

```
② type(v) == "table":
   a) DXE.Replace → 整表替换
   b) hasTaggedItems(v) + target[k] 是 array
      → 对 base 建 tag→index 映射
      → 遍历 patch：每条的 tag 匹配 base → deepMerge(base[idx], item)
      → 未匹配的 base 条目保持不动
   c) isNamedArray(v) + target[k] 是 array  (方案 A)
      → 按 _N 索引合并
   d) hasNumericKey(v) + target[k] 是 array
      → 按位置逐元素合并
   e) target[k] 是 table → 递归合并
```

其中 `hasTaggedItems` 检测数组中是否有条目含 `tag` 字段。

#### 8.2.4 与方案A 对比

| | 方案A（`_N` 位置索引） | 方案B（tag 匹配） |
|---|---|---|
| 匹配依据 | `_1`、`_5` 数字位置 | `"blitz"`、`"malady"` 语义 tag |
| base 改动 | 无 | 被 patch 的 event 加 `tag`（其余不动） |
| base 插入新 event | 后续 `_N` 全部偏移，须手动修正 | tag 不变则补丁无需改动 |
| base 重排顺序 | 须改补丁 | 不受影响 |
| 可读性 | `_3` 不知道是什么 | `"blitz"` 一眼看懂 |
| tag 重名 | 不存在 | 需保证同一数组内 tag 唯一 |
| 实现复杂度 | `isNamedArray` + regex | `hasTaggedItems` + tag→index 映射 |
| 工程风险 | 低（不改 base） | 中（须给被 patch 的 event 加 tag） |

