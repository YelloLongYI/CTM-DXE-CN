# DXE WoW API 清单

> 扫描范围：DXE 项目自有代码（排除 `Libs/` 目录下的第三方库）
> 生成日期：2026-05-24
> 最后更新：2026-06-03

## 一、GetNumRaidMembers / GetNumPartyMembers / GetNumGroupMembers

4.4.2 Classic 移除了 `GetNumRaidMembers()` 和 `GetNumPartyMembers()`，统一为 `GetNumGroupMembers()`。

| API | 4.3.4 | 4.4.2 Classic |
|-----|-------|--------------|
| `GetNumRaidMembers()` | 团队中返回人数（含自己），否则 0 | **已移除** |
| `GetNumPartyMembers()` | 小队中返回人数（不含自己），否则 0 | **已移除** |
| `GetNumGroupMembers()` | 不存在 | 返回队伍总人数（含自己） |

### Shim（`DXE/Core.lua` 第 482-491 行）

用 `IsInRaid()` 判断场景，`GetNumGroupMembers()` 兼容替换：

| | 单人 | 5 人队 | 团队 |
|------|:--:|:--:|:--:|
| `GetNumRaidMembers()` | 0 | 0 | N |
| `GetNumPartyMembers()` | 0 | 4 | 0 |

## 二、总览

- **API 总数：~130+**
- 全部为 4.3 时代原生全局函数，未使用任何 `C_*` 命名空间 API
- 按密集度排序：`Core.lua` > `Invoker.lua` > `Alerts.lua` > `PvPScore.lua`

## 三、按 Compat.lua 封装需求分类

### 🔴 必须封装（4.4.2 行为有变化）

#### Frame 创建
| API | 用量 | 4.4.2 变化 |
|-----|------|------------|
| `CreateFrame` | 50+ 处 | 需要 `BackdropTemplate` 混入 |
| `SetBackdrop` | ~15 处 | 依赖 BackdropTemplate |
| `SetBackdropColor` | ~10 处 | 同上 |
| `SetBackdropBorderColor` | ~8 处 | 同上 |
| `GetBackdropBorderColor` | 1 处 | 同上 |

#### Aura 查询（返回值结构变化）
| API | 用量 | 4.4.2 变化 |
|-----|------|------------|
| `UnitBuff` | ~8 处 | 返回值数量/顺序变化，需改用 `C_UnitAura` |
| `UnitDebuff` | ~30 处 | 同上 |
| `UnitAura` | ~2 处 | 同上 |

#### 通信
| API | 用量 | 4.4.2 变化 |
|-----|------|------------|
| `SendAddonMessage` | 2 处 | 需改用 `C_ChatInfo.SendAddonMessage` |

#### 地图
| API | 用量 | 4.4.2 变化 |
|-----|------|------------|
| `GetPlayerMapPosition` | ~10 处 | 需改用 `C_Map.GetPlayerMapPosition` |

#### GUID 解析
| API | 间接 | 4.4.2 变化 |
|-----|------|------------|
| `UnitGUID` | ~30 处 | GUID 字符串格式变化，导致 NPC ID 提取偏移失效 |

#### 双天赋（LibDualSpec 依赖的函数）
| API | 位于 | 4.4.2 变化 |
|-----|------|------------|
| `GetActiveTalentGroup` | LibDualSpec-1.0 | 已删除 |
| `GetNumTalentGroups` | LibDualSpec-1.0 | 已删除 |

---

### 🟡 需验证封装（4.4.2 行为可能变化）

#### 施法信息
| API | 用量 | 说明 |
|-----|------|------|
| `UnitCastingInfo` | ~2 处 | 返回值 startTime/endTime 单位可能从 ms 变为 s |
| `UnitChannelInfo` | ~2 处 | 同上 |

#### 法术查询
| API | 用量 | 说明 |
|-----|------|------|
| `GetSpellInfo` | ~5 处 | 可能有 `C_Spell.GetSpellInfo` 替代 |
| `GetSpellLink` | ~2 处 | 同上 |

#### 角色/天赋
| API | 用量 | 说明 |
|-----|------|------|
| `GetTalentInfo` | 1 处 | 天赋系统在 4.4.2 中重做 |
| `GetPrimaryTalentTree` | 1 处 | 同上 |

#### 单位
| API | 用量 | 说明 |
|-----|------|------|
| `UnitGroupRolesAssigned` | ~5 处 | Dragonflight 角色判定机制变化 |
| `UnitFactionGroup` | ~10 处 | 可能行为一致，需验证 |
| `UnitInParty` | ~2 处 | 验证是否仍可用 |
| `UnitInRaid` | ~2 处 | 同上 |

#### 团队/副本
| API | 用量 | 说明 |
|-----|------|------|
| `GetNumRaidMembers` | ~40 处 | 可能与 `GetNumPartyMembers` 合并 |
| `GetNumPartyMembers` | ~15 处 | 同上 |
| `GetRaidRosterInfo` | ~5 处 | 返回值顺序可能变化 |
| `GetRaidDifficulty` | ~20 处 | 难度 ID 映射可能变化 |

---

### 🟢 兼容（4.4.2 行为一致，不需封装）

#### 单位基础
`UnitName` `UnitExists` `UnitIsUnit` `UnitIsDead` `UnitIsDeadOrGhost`
`UnitIsFriend` `UnitIsEnemy` `UnitIsPlayer` `UnitIsConnected`
`UnitIsVisible` `UnitIsPartyLeader` `UnitIsRaidOfficer` `UnitAffectingCombat`
`UnitHealth` `UnitHealthMax` `UnitPower` `UnitPowerMax` `UnitPowerType`
`UnitClass` `UnitInVehicle` `UnitReaction`

#### 事件
`RegisterEvent` `UnregisterEvent` `RegisterAddonMessagePrefix`

#### 事件常量
`COMBAT_LOG_EVENT_UNFILTERED` `PLAYER_REGEN_ENABLED` `PLAYER_REGEN_DISABLED`
`INSTANCE_ENCOUNTER_ENGAGE_UNIT` `RAID_ROSTER_UPDATE` `PARTY_MEMBERS_CHANGED`
`ZONE_CHANGED_NEW_AREA` `CHAT_MSG_MONSTER_YELL` `CHAT_MSG_MONSTER_EMOTE`
`CHAT_MSG_MONSTER_SAY` `CHAT_MSG_MONSTER_WHISPER` `CHAT_MSG_MONSTER_PARTY`
`CHAT_MSG_RAID_BOSS_EMOTE` `CHAT_MSG_RAID_BOSS_WHISPER`
`CHAT_MSG_BG_SYSTEM_NEUTRAL` `CHAT_MSG_BG_SYSTEM_ALLIANCE` `CHAT_MSG_BG_SYSTEM_HORDE`
`CHAT_MSG_ADDON` `CHAT_MSG_WHISPER` `UNIT_NAME_UPDATE` `UNIT_TARGET` `UNIT_AURA`
`UPDATE_WORLD_STATES` `UPDATE_BATTLEFIELD_SCORE` `UPDATE_MOUSEOVER_UNIT`
`PLAYER_DEAD` `PLAYER_ALIVE` `PLAYER_ENTERING_WORLD` `ADDON_LOADED`
`START_TIMER` `CINEMATIC_START` `CINEMATIC_STOP` `GOSSIP_SHOW`
`LFG_PROPOSAL_SHOW` `LFG_PROPOSAL_FAILED` `LFG_PROPOSAL_SUCCEEDED`
`BATTLEFIELD_MGR_ENTRY_INVITE` `BATTLEFIELD_MGR_EJECTED` `BATTLEFIELD_MGR_ENTERED`

#### 聊天
`SendChatMessage` `ChatFrame_AddMessageEventFilter` `ChatFrame_MessageEventHandler`
`BNSendWhisper`

#### 战斗/副本
`CombatLogGetCurrentEventInfo` `IsInInstance` `GetInstanceInfo`
`GetInstanceLockTimeRemaining` `GetInstanceLockTimeRemainingEncounter`
`GetBattlefieldInstanceRunTime` `GetBattlefieldWinner` `GetBattlefieldStatus`
`GetBattlefieldPortExpiration` `GetBattlefieldScore` `GetBattlefieldTeamInfo`
`GetBattlefieldPosition` `GetBattlefieldFlagPosition`

#### 地图
`SetMapToCurrentZone` `GetCurrentMapDungeonLevel` `GetCurrentMapAreaID`
`GetMapInfo` `GetMapLandmarkInfo` `GetRealZoneText` `GetPlayerFacing`

#### LFG
`GetLFGDungeonEncounterInfo` `GetLFGDungeonInfo` `GetLFGDungeonNumEncounters`
`GetLFGProposal` `GetLFGProposalMember` `GetLFGRandomDungeonInfo`

#### 闲话
`GetGossipOptions` `GetNumGossipOptions` `SelectGossipOption`

#### 复活/死亡
`AcceptResurrect` `RepopMe` `ResurrectGetOfferer` `GetReleaseTimeRemaining`
`GetCorpseRecoveryDelay` `HasSoulstone`

#### 掉落菜单
`UIDropDownMenu_CreateInfo` `UIDropDownMenu_AddButton` `UIDropDownMenu_Initialize`
`UIDropDownMenu_SetSelectedValue` `UIDropDownMenu_SetText`

#### 其他全局
`GetTime` `GetGameTime` `GetLocale` `GetBuildInfo`
`GetCVar` `SetCVar` `GetScreenHeight`
`PlaySoundFile` `hooksecurefunc` `InCinematic`
`LeaveParty` `UninviteUnit` `StaticPopup_Show`
`GetAddOnInfo` `GetAddOnMetadata` `IsAddOnLoaded` `LoadAddOn`
`GetWorldStateUIInfo` `GetNumWorldStateUI`
`IsShiftKeyDown` `IsControlKeyDown`

#### 全局常量/Frame
`UIParent` `RaidWarningFrame` `RaidBossEmoteFrame` `WorldStateScoreFrame` `MovieFrame`
`ALTERNATE_POWER_INDEX`

## 四、Compat.lua 封装优先级

| 优先级 | API 组 | 说明 |
|--------|--------|------|
| P0 | `CreateFrame` + Backdrop 系列 | 不处理插件直接无法渲染 |
| P0 | `LibDualSpec` 守卫 | 不处理登陆时报错 |
| P1 | `UnitBuff` / `UnitDebuff` | 核心战斗逻辑依赖 |
| P1 | `SendAddonMessage` | 团队同步功能 |
| P2 | `GetPlayerMapPosition` | 仅 DXE_EndTime 使用 |
| P2 | `UnitCastingInfo` / `UnitChannelInfo` | 仅 ~4 处调用 |
| P2 | `UnitGUID` NPC ID 提取 | 已有 `NID` 代理表，需新增偏移 |
| P3 | `GetSpellInfo` / `GetSpellLink` | 低用量，向后兼容性高 |
| P3 | `GetNumRaidMembers` / `GetNumPartyMembers` | **4.4.2 已移除**，全局 shim 已实施 |

## 五、副本 Encounters.lua 分类

### 需要修改（2 个）

#### DXE_DragonSoul/Encounters.lua（~10 处，9069 行）

| 文件:行号 | API | 说明 |
|-----------|-----|------|
| `:3772` | `UnitGroupRolesAssigned, UnitClass, UnitIsUnit` | Ultraxion 减伤链分配逻辑 |
| `:4083, :4148` | `UnitGroupRolesAssigned()` | 同上 |
| `:4280` | `SendChatMessage, UnitName` | 减伤链分配消息发送 |
| `:4523` | `UnitName("player")` | 硬编码自己名字做模式匹配 |
| `:5552` | `UnitClass, UnitGroupRolesAssigned, UnitName, GetSpellLink, SendChatMessage` | Spine of Deathwing 分配逻辑 |
| `:5624` | `UnitName(key)` | 同上 |
| `:7516` | `UnitIsDead, UnitIsUnit, tostring, tonumber` | Madness of Deathwing 腐化位置线 |
| `:7616, :7633` | `GetNumRaidMembers()` | 腐化线遍历团队成员 |
| `:7619, :7666` | `UnitIsDead()`, `UnitIsUnit()` | 同上 |
| `:7679` | `UnitIsDead()`, `UnitIsUnit()` | 同上 |

#### DXE_EndTime/Encounters.lua（~5 处，1677 行）

| 文件:行号 | API | 说明 |
|-----------|-----|------|
| `:812` | `GetPlayerMapPosition("party"..i)` | Murozond 技能定位 |
| `:824` | `GetPlayerMapPosition("raid"..i)` | 同上 |
| `:851` | `GetPlayerMapPosition, UnitName` | 上值缓存 |
| `:898` | `GetPlayerMapPosition(UnitName("boss1target"))` | 同上 |
| `:901` | `GetPlayerMapPosition(UnitName("boss1target"))` | 同上 |

### 不需要修改（其余全部）

以下副本文件为纯数据声明（NPC ID、Spell ID、触发文本、命令包），不直接调用 WoW API，通过核心引擎间接执行，不受 4.4.2 影响：

| 副本 | 文件 | 行数 |
|------|------|------|
| DXE_Baradin | `DXE_Baradin/Encounters.lua` | — |
| DXE_Bastion | `DXE_Bastion/Encounters.lua` | 3901 |
| DXE_Battlegrounds | `DXE_Battlegrounds/Encounters.lua` | — |
| DXE_BlackrockCaverns | `DXE_BlackrockCaverns/Encounters.lua` | — |
| DXE_Deadmines | `DXE_Deadmines/Encounters.lua` | — |
| DXE_Descent | `DXE_Descent/Encounters.lua` | — |
| DXE_Firelands | `DXE_Firelands/Encounters.lua` | 5830 |
| DXE_GrimBatol | `DXE_GrimBatol/Encounters.lua` | — |
| DXE_HallsOfOrigination | `DXE_HallsOfOrigination/Encounters.lua` | — |
| DXE_HourOfTwilight | `DXE_HourOfTwilight/Encounters.lua` | — |
| DXE_LostCityOfTolvir | `DXE_LostCityOfTolvir/Encounters.lua` | — |
| DXE_ShadowfangKeep | `DXE_ShadowfangKeep/Encounters.lua` | — |
| DXE_Stonecore | `DXE_Stonecore/Encounters.lua` | — |
| DXE_Throne | `DXE_Throne/Encounters.lua` | — |
| DXE_ThroneOfTides | `DXE_ThroneOfTides/Encounters.lua` | — |
| DXE_VortexPinnacle | `DXE_VortexPinnacle/Encounters.lua` | — |
| DXE_WellOfEternity | `DXE_WellOfEternity/Encounters.lua` | 1902 |
| DXE_WorldEvents | `DXE_WorldEvents/Encounters.lua` | — |
| DXE_ZulAman | `DXE_ZulAman/Encounters.lua` | — |
| DXE_ZulGurub | `DXE_ZulGurub/Encounters.lua` | — |

## 六、其他无需改动的部分

- `Locales.lua` 系列——仅使用 `GetLocale()`
- 大部分 `SendChatMessage`、`GetTime`、事件注册——行为一致
