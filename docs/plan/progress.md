# DXE 双客户端兼容适配 — 施工进度

> 基于 `docs/plan/implementation-plan.md`  
> 开始日期：2026-05-24  
> 最后更新：2026-06-01

---

## 阶段一：内联 Compat + LibDualSpec

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 1.1 | Core.lua 插入 Compat 适配表 | `DXE/Core.lua` | ✅ |
| 1.2 | LibDualSpec 守卫 | `DXE/Libs/LibDualSpec-1.0/LibDualSpec-1.0.lua` | ✅ |
| 1.3 | Compat.lua 保留不加载 | `DXE/Compat.lua` + `DXE/DXE.toc` | ✅ |

---

## 阶段二：核心文件 API 替换

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 2.1 | CreateFrame/SendAddonMsg/GUID/SpellInfo/UIDropDown | `DXE/Core.lua` | ✅ |
| 2.2 | UnitBuff/Debuff/CastInfo/ChannelInfo/GUID | `DXE/Invoker.lua` | ✅ |
| 2.3 | CreateFrame | `DXE/Alerts/Alerts.lua` | ✅ |
| 2.4 | CreateFrame/UIDropDown/ToggleDropDown | `DXE/Pane.lua` | ✅ |
| 2.5 | CreateFrame/UIDropDown | `DXE/Window.lua` | ✅ |
| 2.6 | CreateFrame | `DXE/Windows/*.lua` | ✅ |
| 2.7 | UIDropDown_SetSelectedValue/SetText | `DXE/Windows/Version_Check.lua` | ✅ |

---

## 阶段三：副本文件改造

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 3.1 | UnitRole/Class/IsUnit/SendChat/GetSpellLink/GetNumRaidMembers | `DXE_DragonSoul/Encounters.lua` | ✅ |
| 3.2 | GetPlayerMapPosition/UnitName | `DXE_EndTime/Encounters.lua` | ✅ |

---

## 阶段四：验证

| # | 验证项 | 4.3.4 结果 |
|---|--------|:---------:|
| 4.1 | 插件加载无报错 | ✅ |
| 4.2 | /dxe 面板正常打开 | ✅ |

---

## 阶段五：4.4.2 分支

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 5.1 | IS_CLASSIC 运行时检测 | `DXE/Core.lua` | ✅ |
| 5.2 | BackdropTemplate | `DXE/Core.lua` | ✅ |
| 5.3 | C_ChatInfo.SendAddonMessage | `DXE/Core.lua` | ✅ |
| 5.4 | C_EncounterJournal.GetSectionInfo | `DXE/Core.lua` | ✅ |
| 5.5 | GUID Dragonflight 格式 | `DXE/Core.lua` | ✅ |
| 5.6 | OnEnable 守卫 | `DXE/Alerts/Alerts.lua` | ✅ |
| 5.7 | Options BarTest 守卫 | `DXE_Options/Options.lua` | ✅ |
| 5.8 | GetPlayerMapPosition | `DXE/Core.lua` | ⬜ |
| 5.9 | 4.4.2 Boss 战斗测试 | — | ⬜ |

---

## 统计

| 阶段 | 总任务 | 已完成 | 进度 |
|------|:------:|:------:|:----:|
| 阶段一 | 3 | 3 | 100% |
| 阶段二 | 7 | 7 | 100% |
| 阶段三 | 2 | 2 | 100% |
| 阶段四 | 1 | 1 | 100% |
| 阶段五 | 9 | 7 | 78% |
| **合计** | **23** | **20** | **87%** |

---

## 变更文件清单

| 文件 | 变更 | 说明 |
|------|:----:|------|
| `DXE/Core.lua` | ✏️ | 内联 Compat 适配表 |
| `DXE/Invoker.lua` | ✏️ | UnitBuff/Debuff/CastInfo 替换 |
| `DXE/Alerts/Alerts.lua` | ✏️ | CreateFrame 替换 |
| `DXE/Pane.lua` | ✏️ | CreateFrame/UIDropDown 替换 |
| `DXE/Window.lua` | ✏️ | CreateFrame/UIDropDown 替换 |
| `DXE/Windows/Proximity.lua` | ✏️ | CreateFrame 替换 |
| `DXE/Windows/AlternatePower.lua` | ✏️ | CreateFrame 替换 |
| `DXE/Windows/Version_Check.lua` | ✏️ | CreateFrame/UIDropDown 替换 |
| `DXE_DragonSoul/Encounters.lua` | ✏️ | 单位/团队/通信 API 替换 |
| `DXE_EndTime/Encounters.lua` | ✏️ | 地图/单位 API 替换 |
| `DXE/Libs/LibDualSpec-1.0/LibDualSpec-1.0.lua` | ✏️ | 4.4.2 守卫 |
| `DXE/Compat.lua` | 📄 | 保留不加载（设计参考） |
