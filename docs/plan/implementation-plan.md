# DXE 双客户端兼容适配实施计划

> 目标：同一代码库同时支持 WOW 4.3（原版大灾变）和 WOW 4.4.2（怀旧服大灾变）
> 方案：新增 Compat.lua 适配层，核心代码通过 Compat 层调用，运行时版本检测自动分流

---

## 核心原则：4.3 优先

```
┌──────────────────────────────────────────────────────┐
│  1. 每一步改造完成后，必须先通过 4.3 测试                │
│  2. 4.3 测试通过后，才进入下一步                        │
│  3. Compat 层在 4.3 上必须透明——行为与改造前完全一致       │
│  4. 4.4.2 分支在 4.3 验证通过后再实现                   │
│  5. 如果某一阶段导致 4.3 异常，立即回滚该阶段             │
└──────────────────────────────────────────────────────┘
```

Compat.lua 的函数结构：

```lua
function Compat.CreateFrame(...)
    -- 4.3 路径（原版行为，不做任何改变）
    local frame = CreateFrame(...)
    -- 4.4.2 路径（仅当 IS_CLASSIC 为 true 时执行增量逻辑）
    -- （先留空，阶段五再填充）
    return frame
end
```

---

## 前置验证（30 分钟）

在 4.4.2 客户端上验证以下数据，为后续实现提供准确依据：

| 验证项 | 命令 | 目的 |
|--------|------|------|
| 版本号 | `/dump GetBuildInfo()` | 校准 `IS_CLASSIC` 阈值 |
| GUID 格式 | `/dump UnitGUID("target")` | 校准 `GetNPCIDFromGUID` |
| CombatLog 参数 | `/etrace` + 进战斗 | 确认参数布局 |
| UnitBuff 返回值 | `/dump UnitDebuff("player", 1)` | 确认返回值兼容性 |
| PlaySoundFile | `/run PlaySoundFile("Sound\\Interface\\RaidWarning.ogg")` | 确认 API 仍可用 |

---

## 阶段一：插入 Compat.lua 骨架 + 处理 LibDualSpec（~2 小时）

### 1.1 创建 Compat.lua（4.3 透明版本）

所有 Compat 函数在 4.3 上直接透传给原始 API，4.4.2 分支先留空：

```lua
local addon = DXE
local IS_CLASSIC = select(4, GetBuildInfo()) >= 40400
local Compat = {}

-- 4.3 上直接透传，行为和原始调用完全一致
function Compat.CreateFrame(frameType, name, parent, template)
    return CreateFrame(frameType, name, parent, template)
end

function Compat.GetNPCIDFromGUID(guid)
    if NEW_GUID_FORMAT then
        return tonumber(sub(guid, 7, 10), 16)
    else
        return tonumber(sub(guid, 9, 12), 16)
    end
end

function Compat.GetSpellInfo(id)
    return GetSpellInfo(id)
end

-- Dropdown 菜单（4.4.2 中可能废弃，4.3 上透传）
function Compat.UIDropDown_CreateInfo()
    return UIDropDownMenu_CreateInfo()
end
function Compat.UIDropDown_AddButton(info, level)
    UIDropDownMenu_AddButton(info, level)
end
function Compat.UIDropDown_Initialize(frame, init, mode)
    UIDropDownMenu_Initialize(frame, init, mode)
end
function Compat.UIDropDown_SetSelectedValue(frame, value)
    UIDropDownMenu_SetSelectedValue(frame, value)
end
function Compat.UIDropDown_SetText(frame, text)
    UIDropDownMenu_SetText(frame, text)
end
function Compat.ToggleDropDown(level, value, frame, anchor, x, y)
    ToggleDropDownMenu(level, value, frame, anchor, x, y)
end

-- ... 其余函数同上，全部透传

addon.Compat = Compat
```

| 文件 | 变更 | 说明 |
|------|------|------|
| `DXE/Compat.lua` | 🆕 新建 | 4.3 透传版本，~120 行 |
| `DXE/DXE.toc` | ✏️ 第 1 行插入 `Compat.lua` | 必须在 Core.lua 之前 |

### 1.2 处理 LibDualSpec

在 `DXE/Libs/LibDualSpec-1.0/LibDualSpec-1.0.lua` 顶部插入守卫：

```lua
if select(4, GetBuildInfo()) >= 40400 then return end
```

| 文件 | 变更 | 说明 |
|------|------|------|
| `LibDualSpec-1.0.lua` | ✏️ 第 34 行前加守卫 | Classic 上不加载 |

### 🔒 阶段一检查点

**必须在 4.3 上完成以下验证后才能进入阶段二：**

- [ ] 插件正常加载，无 Lua 报错
- [ ] `DXE.Compat` 全局可访问
- [ ] `CreateFrame()` 经 Compat 透传创建出的 Frame 行为不变
- [ ] LibDualSpec 功能正常（双天赋自动切配置仍可用）

---

## 阶段二：核心文件替换 API 调用（~3 小时）

将核心文件中所有直接 WoW API 调用改为 `Compat.xxx()`。**每个文件改完后立即在 4.3 上验证。**

### 2.1 DXE/Core.lua（~15 处）

| 行位置 | 改动 |
|--------|------|
| 全局（~5 处） | `CreateFrame()` → `Compat.CreateFrame()` |
| ~2849, 2857 | `SendAddonMessage()` → `Compat.SendAddonMsg()` |
| ~594-606 | `tonumber(sub(guid,...))` → `Compat.GetNPCIDFromGUID(guid)` |
| ~523, 537 | `GetSpellInfo()` → `Compat.GetSpellInfo()` |

### 2.2 DXE/Invoker.lua（~20 处）

| 行位置 | 改动 |
|--------|------|
| ~60 | `UnitBuff, UnitDebuff` 上值 → `Compat.GetAura` / `Compat.GetDebuff` |
| ~353-369 | 所有 `UnitDebuff()/select(7)/select(4)` → 改为调 Compat |
| ~307, 1323 | `UnitGUID()` 后取子串 → `Compat.GetNPCIDFromGUID()` |
| ~366-369 | `UnitCastingInfo()/UnitChannelInfo()` → `Compat.GetCastInfo()` |

### 2.3 DXE/Media.lua（~20 处）

| 行位置 | 改动 |
|--------|------|
| 全局 | 所有 `CreateFrame()` → `Compat.CreateFrame()` |

### 2.4 DXE/Alerts/Alerts.lua（~5 处）

| 行位置 | 改动 |
|--------|------|
| ~691, 756, 1654, 1691, 4586 | `CreateFrame()` → `Compat.CreateFrame()` |

### 2.5 DXE/Pane.lua（~10 处）

| 行位置 | 改动 |
|--------|------|
| ~233, 238, 1278, 1283, 1442 | `CreateFrame()` → `Compat.CreateFrame()` |
| ~460, 698, 865 | `UnitGUID()` 间接 → `Compat.GetNPCIDFromGUID()` |

### 2.6 DXE/Window.lua（~10 处）

| 行位置 | 改动 |
|--------|------|
| ~141, 152, 168, 184, 192, 213, 231, 239, 331 | `CreateFrame()` → `Compat.CreateFrame()` |

### 2.7 DXE/Windows/（~10 处）

| 文件 | 改动 |
|------|------|
| `Proximity.lua`、`AlternatePower.lua`、`Radar.lua`、`Version_Check.lua`、`Countdown.lua` | `CreateFrame()` → `Compat.CreateFrame()` |

### 2.8 DXE/Core.lua — UIDropDownMenu（~7 处）

| 行位置 | 改动 |
|--------|------|
| ~3767, 3775 | `UIDropDownMenu_CreateInfo()` → `Compat.UIDropDown_CreateInfo()` |
| ~3772, 3781 | `UIDropDownMenu_AddButton()` → `Compat.UIDropDown_AddButton()` |
| ~3785 | `UIDropDownMenu_CreateInfo` 上值 → `Compat.UIDropDown_CreateInfo` |
| ~3798 | `UIDropDownMenu_Initialize()` → `Compat.UIDropDown_Initialize()` |

### 2.9 DXE/Pane.lua — UIDropDownMenu（~12 处）

| 行位置 | 改动 |
|--------|------|
| ~305, 1444 | `UIDropDownMenu_SetSelectedValue()` → `Compat.UIDropDown_SetSelectedValue()` |
| ~311, 336, 370 | `ToggleDropDownMenu()` → `Compat.ToggleDropDown()` |
| ~1356 | `UIDropDownMenu_CreateInfo` 上值 → `Compat.UIDropDown_CreateInfo` |
| ~1376, 1383, 1401, 1410, 1430 | `UIDropDownMenu_CreateInfo()` → `Compat.UIDropDown_CreateInfo()` |
| ~1381, 1389, 1407, 1415, 1436 | `UIDropDownMenu_AddButton()` → `Compat.UIDropDown_AddButton()` |
| ~1443 | `UIDropDownMenu_Initialize()` → `Compat.UIDropDown_Initialize()` |

### 2.10 DXE/Window.lua — UIDropDownMenu（~6 处）

| 行位置 | 改动 |
|--------|------|
| ~306 | `UIDropDownMenu_CreateInfo` 上值 → `Compat.UIDropDown_CreateInfo` |
| ~312, 320 | `UIDropDownMenu_CreateInfo()` → `Compat.UIDropDown_CreateInfo()` |
| ~317, 325 | `UIDropDownMenu_AddButton()` → `Compat.UIDropDown_AddButton()` |
| ~332 | `UIDropDownMenu_Initialize()` → `Compat.UIDropDown_Initialize()` |

### 2.11 DXE/Windows/Version_Check.lua — UIDropDownMenu（~10 处）

| 行位置 | 改动 |
|--------|------|
| ~219, 228, 250, 259, 325 | `UIDropDownMenu_SetSelectedValue()` → `Compat.UIDropDown_SetSelectedValue()` |
| ~220, 229, 251, 260 | `UIDropDownMenu_SetText()` → `Compat.UIDropDown_SetText()` |
| ~356, 377 | `UIDropDownMenu_CreateInfo()` → `Compat.UIDropDown_CreateInfo()` |
| ~362, 383 | `UIDropDownMenu_AddButton()` → `Compat.UIDropDown_AddButton()` |
| ~406 | `UIDropDownMenu_Initialize()` → `Compat.UIDropDown_Initialize()` |

### 🔒 阶段二检查点

**每个文件改完后在 4.3 上验证以下全部，全部通过才能进入阶段三：**

- [ ] 插件正常加载，无 Lua 报错
- [ ] 进一次副本战斗——Boss 计时条、警报、语音正常工作
- [ ] 开 `/dxe` 选项面板——所有控件正常显示和交互
- [ ] 组队后版本检查同步正常
- [ ] Frame 渲染效果与改造前一致（边框、背景色、位置）
- [ ] 下拉菜单（副本选择器、窗口选择器、版本检查下拉）正常弹出和交互

---

## 阶段三：副本文件改造（~30 分钟）

### 3.1 DXE_DragonSoul/Encounters.lua（~10 处）

```lua
-- :3772   UnitGroupRolesAssigned, UnitClass, UnitIsUnit → Compat.xxx
-- :4083   UnitGroupRolesAssigned(candunit) → Compat.GetRole(candunit)
-- :4148   同上
-- :4280   SendChatMessage, UnitName → Compat.SendChatMsg, Compat.UnitName
-- :4523   UnitName("player") → Compat.UnitName("player")
-- :5552   UnitClass, UnitGroupRolesAssigned, UnitName, GetSpellLink, SendChatMessage → Compat.xxx
-- :5624   UnitName(key) → Compat.UnitName(key)
-- :7516   UnitIsDead, UnitIsUnit, tostring, tonumber → Compat.xxx
-- :7616   GetNumRaidMembers() → Compat.GetNumGroupMembers()
-- :7619   不再直接调 UnitIsDead, UnitIsUnit → Compat.xxx
```

### 3.2 DXE_EndTime/Encounters.lua（~5 处）

```lua
-- :812    GetPlayerMapPosition("party"..i) → Compat.GetPlayerMapPos("party"..i)
-- :824    同上 "raid"..i
-- :851    GetPlayerMapPosition, UnitName 上值 → Compat.xxx
-- :898    GetPlayerMapPosition(UnitName("boss1target")) → Compat.xxx
-- :901    同上
```

### 🔒 阶段三检查点

**在 4.3 上验证：**

- [ ] 进 Dragon Soul 副本——Ultraxion 减伤链分配不报错，Madness 腐化线正常
- [ ] 进 End Time 副本——Murozond 地图箭头正常

---

## 阶段四：选项和加载器（~1 小时）

| 文件 | 改动 |
|------|------|
| `DXE_Options/Options.lua` | ~15 处 `CreateFrame()` → `Compat.CreateFrame()` |
| `DXE_Loader/Loader.lua` | ~3 处 `CreateFrame()` → `Compat.CreateFrame()` |

### 🔒 阶段四检查点

**在 4.3 上验证：**

- [ ] 选项面板所有 Tab 可正常切换和操作
- [ ] 加载器按需加载正常

---

## 阶段五：填充 4.4.2 分支（~2 小时）

此时 Compat 层已在 4.3 上运行稳定。4.4.2 分支从空壳开始填充。

### 5.1 Compat.CreateFrame() — BackdropTemplate

```lua
function Compat.CreateFrame(frameType, name, parent, template)
    if IS_CLASSIC then
        return CreateFrame(frameType, name, parent, template or "BackdropTemplate")
    else
        return CreateFrame(frameType, name, parent, template)
    end
end
```

### 5.2 Compat.GetNPCIDFromGUID() — GUID 格式

根据前置验证中观察到的实际格式调整偏移逻辑。

### 5.3 Compat.GetAuraInfo() — UnitBuff/Debuff

根据前置验证观察到的返回值结构决定是否切到 `C_UnitAura`。

### 5.4 Compat.SendAddonMsg() — 通信

```lua
function Compat.SendAddonMsg(prefix, msg, channel, target)
    if IS_CLASSIC then
        C_ChatInfo.SendAddonMessage(prefix, msg, channel, target)
    else
        SendAddonMessage(prefix, msg, channel, target)
    end
end
```

### 5.5 Compat.GetPlayerMapPos() — 地图

```lua
function Compat.GetPlayerMapPos(unit)
    if IS_CLASSIC then
        local pos = C_Map.GetPlayerMapPosition(GetCurrentMapAreaID(), unit)
        return pos and pos.x, pos and pos.y
    else
        return GetPlayerMapPosition(unit)
    end
end
```

### 5.6 Compat.UIDropDown_* — 下拉菜单

根据前置验证确认 4.4.2 是否仍保留 `UIDropDownMenu_*` 系列。如果保留，透传即可；如果废弃，改用 Dragonflight 的 `MenuUtil.CreateContextMenu` 等新 API。

### 5.7 其余函数

根据前置验证结果，对 `GetSpellInfo`、`GetCastInfo`、`GetNumGroupMembers` 等逐一确定是否需要分支。

### 🔒 阶段五检查点

**在 4.4.2 上验证：**

- [ ] 插件正常加载，无 Lua 报错
- [ ] Boss 战斗——计时条、警报正常
- [ ] 选项面板正常
- [ ] 通信正常
- [ ] GUID 解析正常（Boss 血条追踪）
- [ ] 下拉菜单正常（副本选择器、窗口选择器、版本检查下拉）
- [ ] 地图箭头正常（End Time）
- [ ] Ultraxion 减伤链不报错

**回归 4.3 上验证：**

- [ ] 所有 4.3 功能仍然正常

---

## 阶段六：全面测试（~3 小时）

### 6.1 4.3 回归测试

| 测试项 | 方法 |
|--------|------|
| 插件加载 | 无 Lua 报错 |
| Boss 战斗 | 进任意副本（推荐 Firelands 或 Dragon Soul），完整打完一场 |
| 选项面板 | `/dxe`，所有页签操作一遍 |
| 通信 | 组队 → 确认版本检查、开怪倒计时、计时条同步 |
| LibDualSpec | 切天赋 → 确认配置自动切换 |
| 副本模块 | 验证 DragonSoul 和 EndTime 功能正常 |

### 6.2 4.4.2 覆盖测试

| 类别 | 测试项 | 方法 |
|------|--------|------|
| 加载 | 无 Lua 报错 | 登陆 + `/reload` |
| 战斗 | Boss 警报 | 进任意副本战斗 |
| UI | 选项面板 | `/dxe` 验证所有控件 |
| UI | Frame 渲染 | 确认边框、背景、字体无异常 |
| 通信 | 团队同步 | 组队验证 |
| 数据 | GUID 解析 | Boss 追踪正常 |
| 数据 | Aura 检测 | Buff/Debuff 警报正常 |
| 地图 | Map 定位 | End Time 箭头正常 |
| 副本 | Ultraxion 减伤链 | Dragon Soul 不报错 |
| 多副本 | 至少 3 个副本 | 各打完一场完整战斗 |

---

## 工作量汇总

| 阶段 | 内容 | 4.3 检查点 | 4.4.2 检查点 | 估时 |
|------|------|:--:|:--:|------|
| 前置验证 | 4.4.2 环境摸底 | — | — | 0.5h |
| 一 | Compat 骨架 + LibDualSpec | ✅ | — | 2h |
| 二 | 核心文件 API 替换（含 UIDropDownMenu） | ✅ | — | 3.5h |
| 三 | 副本文件改造 | ✅ | — | 0.5h |
| 四 | 选项/加载器改造 | ✅ | — | 1h |
| 五 | 填充 4.4.2 分支 | ✅ | ✅ | 2h |
| 六 | 全面测试 | ✅ | ✅ | 3h |
| **合计** | | | | **~13h** |

---

## 实施顺序

```
前置验证（4.4.2 环境摸底）
    │
    ▼
阶段一                           ← Compat 骨架、LibDualSpec
    │ 4.3 检查点 ─── ❌ ──→ 回滚修复
    ▼
阶段二                           ← 核心文件 API 替换
    │ 4.3 检查点 ─── ❌ ──→ 回滚修复（逐个文件）
    ▼
阶段三 + 四（并行）               ← 副本 + 选项
    │ 4.3 检查点 ─── ❌ ──→ 回滚修复
    ▼
阶段五                           ← 4.4.2 分支填充
    │ 4.4.2 检查点 ─── ❌ ──→ 修复分支
    │ 4.3 回归检查 ─── ❌ ──→ 修复分支（不能影响 4.3）
    ▼
阶段六                           ← 全面测试
```

---

## 风险点

| 风险 | 概率 | 缓解 |
|------|------|------|
| 4.4.2 API 实际兼容度高于预期 | 中 | 前置验证优先做，避免过度工程 |
| 战斗日志参数布局与预期不符 | 中 | `Invoker.lua` 已有版本分支，前置验证确认 |
| Ace3 库升级引入新 bug | 中 | 不在本次改造范围内，独立处理 |
| Compat 替换引入 4.3 回归 bug | 中 | 每个阶段设检查点，透传改法风险最低 |
| Compat 函数签名不匹配 | 低 | 4.3 路径直接透传，参数完全一致 |

---

## 参考文档

| 文件 | 内容 |
|------|------|
| `docs/plan/compat.md` | 架构设计 |
| `docs/plan/api-inventory.md` | API 清单及分类 |
| `DXE/Compat.lua`（待建） | 实现代码 |
