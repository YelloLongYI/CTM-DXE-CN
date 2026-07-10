# 问题追踪

此文件记录 DXE 适配过程中遇到的已知问题。
后续接手的 AI 请按以下格式追加新问题：

```
N. [模块/文件名] 问题简述
   **状态**: 待确认 / 已修正 / 无法复现
   **环境**: 版本 + 服务器，如 4.4.2 Gilneas
   **描述**: 问题现象、根因、影响范围
   **验证**: 如何重现或验证
```

---

1. [Data_Bastion_Gilneas.lua / Compat] Bastion Cho'gall 10N 下 `&difficulty&` 被判定为英雄
   **状态**: 待确认
   **环境**: 4.4.2 Gilneas
   **描述**: furycd 显示 63（H 模式 `>=3`）而非 37.5（N 模式 `<3`）。
            黑翼血环 10H 已验证 `DXE:GetRaidDifficulty() = 3`（正确，5-2=3）。
            Bastion chogall 10N 未实测 `DXE:GetRaidDifficulty()`。
   **验证**: 进 Bastion Cho'gall 10N 后跑 `/dump DXE:GetRaidDifficulty()`

2. [多个模块] `type = "event"` 搭配 `UNIT_SPELLCAST_SUCCEEDED` / `SPELL_CAST_SUCCESS` 在 4.4.2 不触发
   **状态**: 待确认
   **环境**: 4.4.2 Gilneas
   **描述**: 
     - `UNIT_SPELLCAST_SUCCEEDED` 在 4.4.2 中仅对玩家控制的 unit 触发，NPC BOSS 施法不回调
     - `event = "SPELL_CAST_SUCCESS"` 不是 WoW API 事件名 — `RegisterEvent("SPELL_CAST_SUCCESS")` 静默失败
     - 受影响模块：Descent nefarian Shadowblaze（已修正为 `combatevent`）、Bastion valther Dazzling Destruction（已修正为 `combatevent`）、其余含 `UNIT_SPELLCAST_*` 的模块待排查
     - 修正方式：`type = "combatevent"` + `eventtype = "SPELL_CAST_SUCCESS"` + `spellname = <ID>`，去掉 `"expect",{"#2#","==",...}` 和 `"expect",{"#1#","find","boss"}`
   **验证**: 4.4.2 Gilneas 下进黑翼血环 nefarian，施放 Shadowblaze（81031）是否触发 blazewarn
