# DXE 双客户端兼容适配实施计划

> 目标：同一代码库同时支持 WOW 4.3（原版大灾变）和 WOW 4.4.2（怀旧服大灾变）
> 方案：Core.lua 内联 Compat 适配表，核心代码通过 `DXE.Compat.xxx()` 调用

---

## 核心原则：4.3 优先

```
1. 每一步改造完成后，必须先通过 4.3 测试
2. 4.3 测试通过后，才进入下一步
3. Compat 层在 4.3 上必须透明——行为与改造前完全一致
4. 4.4.2 分支在 4.3 验证通过后再实现
5. 如果某一阶段导致 4.3 异常，立即回滚
```

---

## 架构：Compat 适配表（Core.lua 内联）

**关键发现：Compat 不能作为单独文件通过 TOC 加载。** 多一个文件会改变 DXE 与第三方插件（Details、ElvUI）自带的 AceAddon-3.0 v12 的初始化时序，导致 `module.db` 为 nil。唯一稳定方案是将 Compat 表内联在 Core.lua 的 `_G.DXE = addon` 之后。

```lua
_G.DXE = addon

local IS_CLASSIC = false  -- 4.3.x 硬编码，阶段五在安全位置覆盖

addon.Compat = setmetatable({
    IS_CLASSIC = IS_CLASSIC,
    -- 自定义函数（无 1:1 映射的 WoW API）
    GetNPCIDFromGUID = function(guid) ... end,
    SendAddonMsg = function(...) ... end,
    UIDropDown_CreateInfo = function() ... end,
    ...
}, {
    __index = _G,  -- 通用透传：CreateFrame、GetSpellInfo 等直接走 _G
})
```

- **`__index = _G`**：未显式定义的函数自动查找 WoW 全局 API，无需逐个定义
- **自定义函数**：`GetNPCIDFromGUID`、`SendAddonMsg`、`UIDropDown_*`、`ToggleDropDown` 等因名称或行为不同需显式定义
- **版本检测**：4.3.x 硬编码 `IS_CLASSIC = false`，阶段五在已验证安全的位置覆盖为 true

---

## 阶段一：内联 Compat + LibDualSpec 守卫 ✅

### 1.1 Core.lua 插入 Compat 适配表

在 `_G.DXE = addon` 和 `addon.version` 之间插入 ~40 行 Compat 定义。

| 文件 | 变更 |
|------|------|
| `DXE/Core.lua` | ✏️ 第 479-517 行 |

### 1.2 处理 LibDualSpec

在 `LibDualSpec-1.0.lua` 顶部插入守卫，4.4.2 上跳过加载。

| 文件 | 变更 |
|------|------|
| `DXE/Libs/LibDualSpec-1.0/LibDualSpec-1.0.lua` | ✏️ 顶部加守卫 |

### 1.3 Compat.lua 保留但不加载

`DXE/Compat.lua` 文件保留在磁盘上供参考，`DXE/DXE.toc` 不加载它。

---

## 阶段二：核心文件 API 替换 ✅

将核心文件中所有直接 WoW API 调用改为 `DXE.Compat.xxx()`。

| # | 文件 | 替换内容 |
|---|------|----------|
| 2.1 | `DXE/Core.lua` | CreateFrame(3), SendAddonMessage(2), GUID(2), GetSpellInfo(2), UIDropDown(8) |
| 2.2 | `DXE/Invoker.lua` | UnitBuff/Debuff 上值(1→覆盖11处), GUID(1), CastInfo/ChannelInfo(4) |
| 2.3 | `DXE/Alerts/Alerts.lua` | CreateFrame(14) |
| 2.4 | `DXE/Pane.lua` | CreateFrame(6), UIDropDown(12), ToggleDropDown(3) |
| 2.5 | `DXE/Window.lua` | CreateFrame(10), UIDropDown(6) |
| 2.6 | `DXE/Windows/*.lua` | CreateFrame (Proximity 2, AlternatePower 2, Version_Check 7) |
| 2.7 | `DXE/Windows/Version_Check.lua` | UIDropDown(10) |

---

## 阶段三：副本文件改造 ✅

| # | 文件 | 替换内容 |
|---|------|----------|
| 3.1 | `DXE_DragonSoul/Encounters.lua` | UnitGroupRolesAssigned, UnitClass, UnitIsUnit, GetNumRaidMembers, SendChatMessage, UnitName, GetSpellLink, UnitIsDead (上值替换, ~10处) |
| 3.2 | `DXE_EndTime/Encounters.lua` | GetPlayerMapPosition, UnitName (上值替换, ~5处) |

---

## 阶段四：验证 ✅

| 验证项 | 4.3.4 结果 |
|--------|:---------:|
| 插件加载无报错 | ✅ |
| `/dxe` 面板正常打开 | ✅ |

---

## 阶段五：4.4.2 分支填充 ⬜

1. 在 Core.lua 已验证安全的位置（`NEW_GUID_FORMAT` 之后）用 `GetBuildInfo()` 覆盖 `addon.Compat.IS_CLASSIC`
2. 补充分支逻辑：
   - `BackdropTemplate` — 覆写 `Compat.CreateFrame`
   - `SendAddonMessage` → `C_ChatInfo` — 覆写 `Compat.SendAddonMsg`
   - `GetPlayerMapPosition` → `C_Map` — 覆写 `Compat.GetPlayerMapPos`
3. 4.4.2 加载和 Boss 战验证

---

## 已知问题

| 问题 | 原因 | 状态 |
|------|------|:----:|
| Compat 单独文件加载导致模块初始化失败 | 与 Details/ElvUI 的 AceAddon v12 初始化时序冲突 | ✅ 已规避 |
| `GetBuildInfo()` 在 Core.lua 早期位置调用触发冲突 | 同上 | ✅ 已规避（硬编码常量） |

---

## 参考文档

| 文件 | 内容 |
|------|------|
| `docs/plan/compat.md` | 架构设计 |
| `docs/plan/api-inventory.md` | API 清单 |
| `docs/plan/progress.md` | 施工进度 |
| `DXE/Compat.lua` | 原始设计参考（不加载） |
