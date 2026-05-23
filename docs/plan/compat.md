# DXE 双客户端兼容适配方案

## 一、目标

同一套代码库，同时支持 **WOW 4.3（原版大灾变）** 和 **WOW 4.4.2（怀旧服大灾变）**，通过运行时版本检测自动切换 API 实现。

## 二、架构

```
┌─────────────────────────────────────────────────────┐
│              DXE 核心业务代码                          │
│  Core.lua / Invoker.lua / Alerts.lua / Media.lua ... │
│                                                       │
│  所有 WoW API 调用统一改为 Compat.xxx()               │
│  原始 API 名不再出现在业务代码中                       │
└───────────────────────┬─────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────┐
│                 DXE/Compat.lua                       │
│                                                       │
│  IS_CLASSIC = select(4, GetBuildInfo()) >= 40400     │
│                                                       │
│  Compat.CreateFrame(...)   → 分支处理 BackdropTemplate │
│  Compat.GetAuraInfo(...)    → 分支处理 UnitBuff/Debuff │
│  Compat.GetCastInfo(...)    → 分支处理施法信息         │
│  Compat.GetNPCID(...)       → 分支处理 GUID 格式       │
│  Compat.GetMapPosition(...) → 分支处理地图位置         │
│  Compat.SendAddon(...)      → 分支处理通信             │
│  Compat.GetSpellInfo(...)   → 分支处理法术查询         │
└───────────────────────┬─────────────────────────────┘
                        │
          ┌─────────────┴─────────────┐
          ▼                           ▼
   ┌──────────────┐           ┌──────────────────┐
   │ 4.3 原生 API  │           │ 4.4.2 Dragonflight│
   │ UnitDebuff   │           │ C_UnitAura        │
   │ SendAddonMsg │           │ C_ChatInfo        │
   │ CreateFrame  │           │ BackdropTemplate  │
   │ GetMapPos    │           │ C_Map             │
   └──────────────┘           └──────────────────┘
```

## 三、文件变更清单

| 文件 | 变更类型 | 说明 |
|---|---|---|
| `DXE/Compat.lua` | 新增 | 版本检测 + API 分支封装，约 150 行 |
| `DXE/DXE.toc` | 修改 | `Compat.lua` 插入第 1 行加载；注释 `LibDualSpec-1.0.lua` 行 |
| `DXE/Core.lua` | 修改 | ~15 处裸 API → `Compat.xxx()` |
| `DXE/Invoker.lua` | 修改 | ~20 处 aura/cast 调用替换 |
| `DXE/Media.lua` | 修改 | ~20 处 `CreateFrame` → `Compat.CreateFrame` |
| `DXE/Alerts/Alerts.lua` | 修改 | ~5 处 `CreateFrame` 替换 |
| `DXE/Pane.lua` | 修改 | ~10 处 `CreateFrame` 替换 |
| `DXE/Window.lua` | 修改 | ~10 处 `CreateFrame` 替换 |
| `DXE/Windows/*.lua` | 修改 | ~10 处 |
| `DXE_EndTime/Encounters.lua` | 修改 | ~5 处 `GetPlayerMapPosition` → `Compat` |
| `DXE_DragonSoul/Encounters.lua` | 修改 | ~10 处裸 API 替换 |
| 其他副本 Encounters.lua | 不变 | 纯数据声明，零修改 |
| `DXE_Options/Options.lua` | 修改 | ~15 处 `CreateFrame` 替换 |

## 四、LibDualSpec 的处理

不改 `.toc`，改为在库文件内部加守卫：

```lua
-- LibDualSpec-1.0.lua 顶部插入
if select(4, GetBuildInfo()) >= 40400 then return end
```

这样加载该文件时，Classic 客户端直接 return，`LibStub` 中不会注册该库，`DXE` 中所有 `if LDS then` 自动跳过。

## 五、Compat.lua 核心结构

```lua
local addon = DXE
local Compat = {}
local IS_CLASSIC = select(4, GetBuildInfo()) >= 40400

Compat.CreateFrame       = function(...) ... end   -- BackdropTemplate 分支
Compat.GetAuraInfo        = function(...) ... end   -- UnitBuff/Debuff vs C_UnitAura
Compat.GetCastInfo        = function(...) ... end   -- 施法信息 ms/s 差异
Compat.GetChannelInfo     = function(...) ... end
Compat.GetNPCIDFromGUID   = function(...) ... end   -- GUID 解析差异
Compat.GetPlayerMapPos    = function(...) ... end   -- GetPlayerMapPosition vs C_Map
Compat.SendAddonMsg       = function(...) ... end   -- SendAddonMessage vs C_ChatInfo
Compat.GetSpellInfo       = function(...) ... end

addon.Compat = Compat
```

## 六、版本检测

```lua
-- 4.3 原版：Interface 40300
-- 4.4.2 Classic：Interface >= 40400
local IS_CLASSIC = select(4, GetBuildInfo()) >= 40400
```

一个全局标记，`Compat.lua` 内部所有分支用它。

## 七、改造原则

1. 版本差异集中在 Compat.lua，核心业务代码只调 `Compat.xxx()`
2. 逐步替换，按致命程度优先：BackdropTemplate → 通信 → Aura → 其余
3. 副本数据文件不改，它们是通过核心引擎间接执行，不是直接调 API
4. 不改逻辑，只换调用方式。例如 `UnitDebuff("player", name)` → `Compat.GetAuraInfo("player", name, "HARMFUL")`

## 八、下一步

1. 获取 4.4.2 客户端上 `GetBuildInfo()` 的实际返回值，确认版本检测阈值
2. 验证 4.4.2 上各个差异 API 的实际行为（战斗日志格式、aura 返回值、GUID 格式）
3. 编写 `Compat.lua`
4. 逐步替换核心代码中的裸 API 调用
5. 在 4.3 和 4.4.2 上分别测试
