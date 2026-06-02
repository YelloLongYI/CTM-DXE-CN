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
-- 守卫：非目标 Realm 直接跳过
if DXE.db.profile.Globals.Realm ~= "JRG" then return end

-- 每个有差异的 BOSS 调用一次
DXE:RegisterRealmPatch("halfus", {
    triggers = {
        scan = { 44600, 44650, 99999, 44797, 44652 },   -- NPC ID 不同
    },
    alerts = {
        enragecd = { time = 420 },                        -- 狂暴时间不同
        novacd   = { time = 14 },                         -- 技能 CD 不同
    },
})

DXE:RegisterRealmPatch("chogall", {
    triggers = {
        scan = { 43324, 88888 },
        yell = "Worship me, mortals!",
    },
})

-- 无差异的 BOSS（valther、ascendcouncil、sinestra、bottrash）不写
```

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
            -- 含整数 key → 整表替换
            if hasNumericKey(v) then
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

所有文件按顺序在 `.toc` 中列出，补丁文件必须在 `Encounters.lua` 之前加载，确保补丁队列在注册时已被填充：

```
# DXE_Bastion.toc
Locales.lua
Data_Bastion_Apollo.lua         ← 补丁文件先加载，Realm 守卫过滤
Data_Bastion_JRG.lua            ← 匹配 Realm 的补丁入队列
Data_Bastion_Test.lua           ← 匹配 Realm 的补丁入队列
Encounters.lua                  ← 最后注册，合并队列中的补丁
```

### 3.2 Realm 配置

Realm 标识由玩家在 DXE 设置中手动配置，存储在 `DXE.db.profile.Globals.Realm`，默认值为 `"Apollo"`。Core.lua 中的 `pfl` 是文件级 `local` 变量，外部模块不可访问，因此补丁文件中必须通过 `DXE.db.profile.Globals.Realm` 读取。

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

以玩家将 Realm 设为 `"JRG"` 后进入暮光堡垒为例：

```
玩家配置 Realm = "JRG"
        │
        ▼
进入 The Bastion of Twilight
        │
        ▼
DXE_Loader 扫描到 DXE_Bastion 的 X-DXE-Zone 匹配 → LoadAddOn
        │
        ▼
TOC 按序加载所有文件:
        │
        ├── Locales.lua              ← 多语言文本加载
        │
        ├── Encounters.lua           ← RegisterEncounter 注册所有 BOSS（Apollo 默认数据）
        │
        ├── Data_Bastion_Apollo.lua
        │   │  if DXE.db.profile.Globals.Realm ~= "Apollo" then return end
        │   │  "JRG" ~= "Apollo" → return（跳过）
        │   └── 不执行任何补丁
        │
        └── Data_Bastion_JRG.lua
            │  if DXE.db.profile.Globals.Realm ~= "JRG" then return end
            │  "JRG" == "JRG" → 通过
            │
            ├── RegisterRealmPatch("halfus", { ... })
            ├── RegisterRealmPatch("chogall", { ... })
            │       │
            │       ▼
            │   EDB["halfus"] 已存在 → deepMerge 就地修改
            │   EDB["chogall"] 已存在 → deepMerge 就地修改
            │
            └── 补丁完成
```

同样一次加载，**如果玩家 Realm 保持默认 `"Apollo"`**：

```
Data_Bastion_Apollo.lua    → "Apollo" == "Apollo" → 通过（当前为空，零补丁）
Data_Bastion_JRG.lua       → "Apollo" ~= "JRG"    → return（跳过）
```

**结论**：同一个 TOC 列出所有服务器文件，运行时根据 `DXE.db.profile.Globals.Realm` 的值，只有一个文件的补丁生效，其余全部跳过。不需要重新打包、不需要切换分支。

### 3.3 注册队列机制

补丁文件**不直接修改 EDB**，而是通过 `RegisterRealmPatch` 注册，由框架自动调度，**消除 TOC 顺序依赖**。

```lua
-- Core.lua 新增

-- 待处理的补丁队列
addon.realmPatches = {}

-- 注册补丁（TOC 顺序无关）
function addon:RegisterRealmPatch(key, patchTable)
    if EDB[key] then
        -- encounter 已注册 → 立即 patch
        self:PatchEncounter(key, patchTable)
    else
        -- encounter 尚未注册 → 入队列等待
        self.realmPatches[key] = self.realmPatches[key] or {}
        self.realmPatches[key][#self.realmPatches[key] + 1] = patchTable
    end
end

-- PatchEncounter：执行 deepMerge
function addon:PatchEncounter(key, patch)
    local base = EDB[key]
    if not base then
        self:Print(format("|cffff0000[RealmPatch]|r encounter '%s' not found", key))
        return
    end
    deepMerge(base, patch)
end
```

---

## 四、补丁应用时序

### 4.1 消费队列

在 `RegisterEncounter` 末尾新增队列消费逻辑：

```lua
function addon:RegisterEncounter(data)
    -- ... 现有 80 行注册逻辑不变 ...
    EDB[key] = data

    -- 消费等候中的补丁
    if self.realmPatches[key] then
        for _, patch in ipairs(self.realmPatches[key]) do
            self:PatchEncounter(key, patch)
        end
        self.realmPatches[key] = nil
    end
end
```

### 4.2 两种情况

```
情况A：补丁文件先加载（TOC 中 Data_* 在 Encounters 之前）
─────────────────────────────────────────────────────
RegisterRealmPatch("halfus", patch)
    → EDB["halfus"] 不存在 → 进队列
Encounters.lua 加载
    → RegisterEncounter(data) → EDB["halfus"] = data
        → realmPatches["halfus"] 有等候 → 消费 → PatchEncounter ✅

情况B：Encounters.lua 先加载（TOC 中 Encounters 在前）
─────────────────────────────────────────────────────
RegisterEncounter(data) → EDB["halfus"] = data
    → realmPatches["halfus"] 为空 → 无操作
Data_*.lua 加载
    → RegisterRealmPatch("halfus", patch)
        → EDB["halfus"] 存在 → 立即 PatchEncounter ✅
```

**结论：两种 TOC 顺序均正确。**

### 4.3 完整生命周期

```
    启动登录                  进入副本                   BOSS 战
       │                         │                         │
       ▼                         ▼                         ▼
┌──────────────┐   ┌─────────────────────┐   ┌──────────────────────┐
│ DXE 核心初始化 │   │ Loader 按区域加载    │   │ Invoker 读取 CE       │
│ OnInitialize  │   │ DXE_Bastion         │   │ CE = EDB["halfus"]    │
│ EDB 已就绪    │──▶│ Encounters 注册 ──┐  │──▶│ 此时已是补丁后的最终数据│
│              │   │ Realm Patch apply ◄┘  │   │ 透明生效              │
└──────────────┘   └─────────────────────┘   └──────────────────────┘
```

### 4.4 安全保证

#### 补丁 key 不匹配

补丁的 key 必须与 `Encounters.lua` 中 `data.key` 完全一致，否则补丁**静默不生效**，不会报错也不会崩溃。

```lua
-- Encounters.lua 注册
data.key = "halfus"
DXE:RegisterEncounter(data)

-- 补丁文件（正确）
DXE:RegisterRealmPatch("halfus", { ... })   -- ✅ 匹配，补丁生效

-- 补丁文件（错误）
DXE:RegisterRealmPatch("halfus_typo", { ... })  -- ❌ 不匹配，补丁丢弃
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
if DXE.db.profile.Globals.Realm ~= "JRG" then return end

DXE:RegisterRealmPatch("halfus", {
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

### 6.1 Realm 守卫的变量作用域

`pfl` 是 `DXE/Core.lua` 中的 `local` 变量（第 562 行），**外部 addon 文件无法访问**。

```lua
-- Core.lua
local db, gbl, pfl    -- 文件级 local，仅 Core.lua 内部可用
```

补丁文件运行在 `DXE_Bastion` 的加载上下文中，`pfl` 为 `nil`，`pfl.Globals` 会直接报错。正确写法是使用 DXE 的公开接口：

```lua
-- ❌ 错误：pfl 在其他文件中为 nil
if pfl.Globals.Realm ~= "JRG" then return end

-- ✅ 正确：DXE.db 是全局可访问的
if DXE.db.profile.Globals.Realm ~= "JRG" then return end
```

### 6.2 数据文件禁止包含 RegisterEncounter

每个副本模块只能有一个文件调用 `RegisterEncounter(data)`——即 `Encounters.lua`。

若补丁文件也调用 `RegisterEncounter`，与 `Encounters.lua` 注册相同的 key 时会触发：

```lua
if EDB[key] then error("Encounter "..key.." already exists") return end
```

这会导致 `Encounters.lua` 的注册被拦截，`OnRegisterEncounter` 回调不会触发，Options 面板无法构建。

补丁文件只能用 `DXE:RegisterRealmPatch(key, patch)`，框架会在 `RegisterEncounter` 内自动合入队列中的补丁。

### 6.3 TOC 加载顺序

补丁文件必须在 `Encounters.lua` **之前**加载，确保补丁队列在注册时已被填充：

```
Locales.lua
Data_Bastion_Apollo.lua       ← 先加载所有补丁文件
Data_Bastion_JRG.lua          ← Realm 守卫过滤
Data_Bastion_Test.lua         ← 匹配 Realm 的补丁入队列
Encounters.lua                ← 后注册，合并队列中的补丁
```

### 6.4 EDB 为 Core.lua 的 local 变量

`EDB` 在 `DXE/Core.lua` 中声明为 `local EDB = {}`（第 1178 行），同时暴露为 `addon.EDB`（第 1179 行）。`RegisterRealmPatch` 和 `PatchEncounter` 定义在 `EDB` 赋值之前，闭包中直接引用 local `EDB` 在函数调用时可能为 `nil`。

```lua
-- ❌ 错误：闭包中 local EDB 可能为 nil
function addon:RegisterRealmPatch(key, patchTable)
    if EDB[key] then
        ...
    end
end

-- ✅ 正确：使用 addon 上的公共引用
function addon:RegisterRealmPatch(key, patchTable)
    if self.EDB[key] then
        ...
    end
end
```

`self.EDB`（即 `addon.EDB` / `DXE.EDB`）指向同一个表，不受闭包变量提升影响。

---

## 七、代码改动清单

| 文件 | 改动 |
|------|------|
| `DXE/Core.lua` | 新增 `hasNumericKey`、`deepMerge` 工具函数；新增 `realmPatches` 队列、`RegisterRealmPatch`、`PatchEncounter`（内部使用 `self.EDB`）；`RegisterEncounter` 开头合入队列补丁到 data |
| 各模块 `Data_<Module>_<Realm>.lua` | 只含 Realm 守卫 + `DXE:RegisterRealmPatch`，不含 `RegisterEncounter` |
| 各模块 `DXE_<Module>.toc` | `Data_*` 补丁文件排在 `Encounters.lua` 之前 |
