# DXE 双客户端兼容适配 — 施工进度

> 基于 `docs/plan/implementation-plan.md`
> 开始日期：2026-05-24

---

## 前置验证

| # | 任务 | 状态 |
|---|------|:----:|
| 0.1 | `/dump GetBuildInfo()` 确认版本号 | ⬜ |
| 0.2 | `/dump UnitGUID("target")` 确认 GUID 格式 | ⬜ |
| 0.3 | `/etrace` 确认 CombatLog 参数 | ⬜ |
| 0.4 | `/dump UnitDebuff("player", 1)` 确认返回值 | ⬜ |
| 0.5 | `/run PlaySoundFile(...)` 确认音效 API | ⬜ |

---

## 阶段一：Compat.lua + LibDualSpec

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 1.1 | 创建 Compat.lua | `DXE/Compat.lua` | ✅ 2026-05-24 |
| 1.1 | TOC 插入加载顺序 | `DXE/DXE.toc` | ✅ 2026-05-24 |
| 1.2 | LibDualSpec 守卫 | `DXE/Libs/LibDualSpec-1.0/LibDualSpec-1.0.lua` | ✅ 2026-05-24 |

### 🔒 阶段一检查点

| # | 验证项 | 4.3 | 4.4.2 |
|---|--------|:---:|:-----:|
| CP1.1 | 插件正常加载，无 Lua 报错 | ⬜ | ⬜ |
| CP1.2 | DXE.Compat 全局可访问 | ⬜ | ⬜ |
| CP1.3 | CreateFrame 经 Compat 透传创建 Frame 行为不变 | ⬜ | ⬜ |
| CP1.4 | LibDualSpec 功能正常（双天赋自动切配置） | ⬜ | ⬜ |

---

## 阶段二：核心文件 API 替换

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 2.1 | CreateFrame / SendAddonMsg / GUID / SpellInfo 替换 | `DXE/Core.lua` | ⬜ |
| 2.2 | UnitBuff/Debuff / GUID / CastInfo 替换 | `DXE/Invoker.lua` | ⬜ |
| 2.3 | CreateFrame 替换 | `DXE/Media.lua` | ⬜ |
| 2.4 | CreateFrame 替换 | `DXE/Alerts/Alerts.lua` | ⬜ |
| 2.5 | CreateFrame / GUID 替换 | `DXE/Pane.lua` | ⬜ |
| 2.6 | CreateFrame 替换 | `DXE/Window.lua` | ⬜ |
| 2.7 | CreateFrame 替换 | `DXE/Windows/*.lua` | ⬜ |
| 2.8 | UIDropDownMenu 替换 | `DXE/Core.lua` | ⬜ |
| 2.9 | UIDropDownMenu + ToggleDropDown 替换 | `DXE/Pane.lua` | ⬜ |
| 2.10 | UIDropDownMenu 替换 | `DXE/Window.lua` | ⬜ |
| 2.11 | UIDropDownMenu + SetText 替换 | `DXE/Windows/Version_Check.lua` | ⬜ |

### 🔒 阶段二检查点

| # | 验证项 | 4.3 | 4.4.2 |
|---|--------|:---:|:-----:|
| CP2.1 | 插件正常加载，无 Lua 报错 | ⬜ | ⬜ |
| CP2.2 | Boss 战斗——计时条、警报、语音正常 | ⬜ | ⬜ |
| CP2.3 | 选项面板 `/dxe` 正常显示和交互 | ⬜ | ⬜ |
| CP2.4 | 组队后版本检查同步正常 | ⬜ | ⬜ |
| CP2.5 | Frame 渲染效果与改造前一致 | ⬜ | ⬜ |
| CP2.6 | 下拉菜单正常弹出和交互 | ⬜ | ⬜ |

---

## 阶段三：副本文件改造

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 3.1 | UnitRole/UnitClass/UnitIsUnit/SendChat 等替换 | `DXE_DragonSoul/Encounters.lua` | ⬜ |
| 3.2 | GetPlayerMapPosition 替换 | `DXE_EndTime/Encounters.lua` | ⬜ |

### 🔒 阶段三检查点

| # | 验证项 | 4.3 | 4.4.2 |
|---|--------|:---:|:-----:|
| CP3.1 | Dragon Soul — Ultraxion 减伤链不报错 | ⬜ | ⬜ |
| CP3.2 | Dragon Soul — Madness 腐化线正常 | ⬜ | ⬜ |
| CP3.3 | End Time — Murozond 地图箭头正常 | ⬜ | ⬜ |

---

## 阶段四：选项和加载器

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 4.1 | CreateFrame 替换 | `DXE_Options/Options.lua` | ⬜ |
| 4.2 | CreateFrame 替换 | `DXE_Loader/Loader.lua` | ⬜ |

### 🔒 阶段四检查点

| # | 验证项 | 4.3 | 4.4.2 |
|---|--------|:---:|:-----:|
| CP4.1 | 选项面板所有 Tab 可正常切换和操作 | ⬜ | ⬜ |
| CP4.2 | 加载器按需加载正常 | ⬜ | ⬜ |

---

## 阶段五：填充 4.4.2 分支

| # | 任务 | 文件 | 状态 |
|---|------|------|:----:|
| 5.1 | BackdropTemplate 分支 | `DXE/Compat.lua` | ⬜ |
| 5.2 | GUID 解析分支 | `DXE/Compat.lua` | ⬜ |
| 5.3 | Aura 查询分支 | `DXE/Compat.lua` | ⬜ |
| 5.4 | 通信分支 | `DXE/Compat.lua` | ⬜ |
| 5.5 | 地图分支 | `DXE/Compat.lua` | ⬜ |
| 5.6 | 下拉菜单分支（如需要） | `DXE/Compat.lua` | ⬜ |
| 5.7 | 其余函数分支 | `DXE/Compat.lua` | ⬜ |

### 🔒 阶段五检查点

| # | 验证项 | 4.3 | 4.4.2 |
|---|--------|:---:|:-----:|
| CP5.1 | 插件正常加载，无 Lua 报错 | ⬜ | ⬜ |
| CP5.2 | Boss 战斗——计时条、警报正常 | ⬜ | ⬜ |
| CP5.3 | 选项面板正常 | ⬜ | ⬜ |
| CP5.4 | 通信正常 | ⬜ | ⬜ |
| CP5.5 | GUID 解析正常（Boss 血条追踪） | ⬜ | ⬜ |
| CP5.6 | 下拉菜单正常 | ⬜ | ⬜ |
| CP5.7 | 地图箭头正常（End Time） | ⬜ | ⬜ |
| CP5.8 | Ultraxion 减伤链不报错 | ⬜ | ⬜ |

---

## 阶段六：全面测试

| # | 验证项 | 4.3 | 4.4.2 |
|---|--------|:---:|:-----:|
| 6.1 | 插件加载无报错 | ⬜ | ⬜ |
| 6.2 | Boss 战斗（Firelands 或 Dragon Soul 完整一场） | ⬜ | ⬜ |
| 6.3 | 选项面板所有页签 | ⬜ | ⬜ |
| 6.4 | 通信——版本检查、开怪倒计时、计时条同步 | ⬜ | ⬜ |
| 6.5 | LibDualSpec 切天赋配置自动切换（4.3 独有） | ⬜ | N/A |
| 6.6 | 副本模块 DragonSoul 和 EndTime 功能正常 | ⬜ | ⬜ |
| 6.7 | Frame 渲染——边框、背景、字体无异常 | ⬜ | ⬜ |
| 6.8 | Aura 检测——Buff/Debuff 警报正常 | ⬜ | ⬜ |
| 6.9 | 至少 3 个副本各打完一场完整战斗 | ⬜ | ⬜ |

---

## 统计

| 阶段 | 总任务 | 已完成 | 进度 |
|------|:------:|:------:|:----:|
| 前置验证 | 5 | 0 | 0% |
| 阶段一 | 3 | 3 | 100% |
| 阶段二 | 11 | 0 | 0% |
| 阶段三 | 2 | 0 | 0% |
| 阶段四 | 2 | 0 | 0% |
| 阶段五 | 7 | 0 | 0% |
| 阶段六 | 9 | 0 | 0% |
| **合计** | **39** | **3** | **8%** |
