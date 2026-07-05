# DXE 双客户端兼容适配 — 施工进度

> 开始日期：2026-05-24  
> 最后更新：2026-07-06

---

## 阶段一：内联 Compat + LibDualSpec

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 1.1 | Core.lua 插入 Compat 适配表 | `DXE/Core.lua` | ✅ |
| 1.2 | LibDualSpec 守卫 | `DXE/Libs/LibDualSpec-1.0/LibDualSpec-1.0.lua` | ✅ |

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

## 阶段四：4.3.4 验证

| # | 验证项 | 结果 |
|---|--------|:----:|
| 4.1 | 插件加载无报错 | ✅ |
| 4.2 | /dxe 面板正常打开 | ✅ |

---

## 阶段五：4.4.2 引擎适配

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 5.1 | IS_CLASSIC 运行时检测 | `DXE/Core.lua` | ✅ |
| 5.2 | CreateFrame + BackdropTemplate | `DXE/Core.lua` | ✅ |
| 5.3 | SendAddonMessage → C_ChatInfo | `DXE/Core.lua` | ✅ |
| 5.4 | EJ_GetSectionInfo → C_EncounterJournal (EJSN+EJST) | `DXE/Core.lua` | ✅ |
| 5.5 | GUID Dragonflight 格式 | `DXE/Core.lua` | ✅ |
| 5.6 | GetSpellInfo icon number→string | `DXE/Core.lua` | ✅ |
| 5.7 | SN/ST/EJSN/EJST 去 geterrorhandler | `DXE/Core.lua` | ✅ |
| 5.8 | OnEnable 守卫 | `DXE/Alerts/Alerts.lua` | ✅ |
| 5.9 | Options BarTest 守卫 | `DXE_Options/Options.lua` | ✅ |
| 5.10 | 战斗 NID → Compat.GetNPCIDFromGUID | `DXE/Core.lua` | ✅ |
| 5.11 | Texture:SetGradient → ApplyGradient | `DXE/Core.lua` + 4 Window 文件 | ✅ |

---

## 阶段六：4.4.2 验证

| # | 验证项 | 结果 |
|---|--------|:----:|
| 6.1 | 插件加载无报错 | ✅ |
| 6.2 | /dxe 面板正常打开 | ✅ |
| 6.3 | 副本数据加载正常 | ✅ |
| 6.4 | Start test alerts 正常 | ✅ |
| 6.5 | 大部分技能图标/名字正常 | ✅ |

---

## 已知问题：Spell ID 不兼容

4.4.2 数据库中部分技能 ID 与 4.3.4 不一致，`GetSpellInfo(id)` 查不到导致图标白方块。技能名字来自 Encounters.lua 硬编码 text 字段不受影响。

| 副本 | 旧 ID | 状态 |
|------|:----:|:----:|
| 火焰之地 | 100441 | ⬜ 待查 |
| 火焰之地 | 101219 | ⬜ 待查 |

> 参考：DBM 对应副本 .lua 文件交叉对照，或 `/dump GetSpellInfo("技能名")` 反查

---

## 统计

| 阶段 | 总任务 | 已完成 | 进度 |
|------|:------:|:------:|:----:|
| 阶段一 | 2 | 2 | 100% |
| 阶段二 | 7 | 7 | 100% |
| 阶段三 | 2 | 2 | 100% |
| 阶段四 | 2 | 2 | 100% |
| 阶段五 | 11 | 11 | 100% |
| 阶段六 | 5 | 5 | 100% |
| **合计** | **29** | **29** | **100%** |

---

## 变更文件清单

| 文件 | 变更 | 说明 |
|------|:----:|------|
| `DXE/Core.lua` | ✏️ | Compat 表 + 4.4.2 分支 |
| `DXE/Invoker.lua` | ✏️ | UnitBuff/Debuff/CastInfo 替换 |
| `DXE/Alerts/Alerts.lua` | ✏️ | CreateFrame + OnEnable 守卫 |
| `DXE/Pane.lua` | ✏️ | CreateFrame/UIDropDown 替换 |
| `DXE/Window.lua` | ✏️ | CreateFrame/UIDropDown 替换 |
| `DXE/Windows/Proximity.lua` | ✏️ | CreateFrame + SetGradient 替换 |
| `DXE/Windows/AlternatePower.lua` | ✏️ | CreateFrame + SetGradient 替换 |
| `DXE/Windows/Radar.lua` | ✏️ | SetGradient 替换 |
| `DXE/Windows/Version_Check.lua` | ✏️ | CreateFrame/UIDropDown 替换 |
| `DXE_DragonSoul/Encounters.lua` | ✏️ | 单位/团队/通信 API 替换 |
| `DXE_EndTime/Encounters.lua` | ✏️ | 地图/单位 API 替换 |
| `DXE_Options/Options.lua` | ✏️ | BarTest 守卫 |
| `DXE/Libs/LibDualSpec-1.0/LibDualSpec-1.0.lua` | ✏️ | 4.4.2 守卫 |
