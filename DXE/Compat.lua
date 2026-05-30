---------------------------------------------------------
-- DXE/Compat.lua
-- WoW 客户端 API 适配层
--
-- 目标：4.3（原版）和 4.4.2（怀旧服）共用一个代码库
-- 4.3 路径：直接透传给原始 WoW API
-- 4.4.2 路径：阶段五填充
---------------------------------------------------------

local IS_CLASSIC = select(4, GetBuildInfo()) >= 40400
local Compat = {}

Compat.IS_CLASSIC = IS_CLASSIC

---------------------------------------------------------
-- FRAME 创建
---------------------------------------------------------

function Compat.CreateFrame(frameType, name, parent, template)
    return CreateFrame(frameType, name, parent, template)
end

---------------------------------------------------------
-- GUID 解析：从 UnitGUID 字符串中提取 NPC ID
---------------------------------------------------------

local NEW_GUID_FORMAT = select(2, GetBuildInfo()) >= 12484

function Compat.GetNPCIDFromGUID(guid)
    if not guid then return nil end
    if NEW_GUID_FORMAT then
        return tonumber(guid:sub(7, 10), 16)
    else
        return tonumber(guid:sub(9, 12), 16)
    end
end

---------------------------------------------------------
-- 法术
---------------------------------------------------------

function Compat.GetSpellInfo(id)
    return GetSpellInfo(id)
end

function Compat.GetSpellLink(id)
    return GetSpellLink(id)
end

---------------------------------------------------------
-- Aura（Buff / Debuff 查询）
---------------------------------------------------------

function Compat.UnitBuff(unit, ...)
    return UnitBuff(unit, ...)
end

function Compat.UnitDebuff(unit, ...)
    return UnitDebuff(unit, ...)
end

---------------------------------------------------------
-- 施法
---------------------------------------------------------

function Compat.GetCastInfo(unit)
    return UnitCastingInfo(unit)
end

function Compat.GetChannelInfo(unit)
    return UnitChannelInfo(unit)
end

---------------------------------------------------------
-- 通信
---------------------------------------------------------

function Compat.SendAddonMsg(prefix, msg, channel, target)
    SendAddonMessage(prefix, msg, channel, target)
end

function Compat.SendChatMessage(msg, ...)
    SendChatMessage(msg, ...)
end

---------------------------------------------------------
-- 地图
---------------------------------------------------------

function Compat.GetPlayerMapPos(unit)
    return GetPlayerMapPosition(unit)
end

---------------------------------------------------------
-- 团队
---------------------------------------------------------

function Compat.GetNumRaidMembers()
    return GetNumRaidMembers()
end

function Compat.GetNumPartyMembers()
    return GetNumPartyMembers()
end

---------------------------------------------------------
-- 单位信息
---------------------------------------------------------

function Compat.UnitName(unit)
    return UnitName(unit)
end

function Compat.UnitClass(unit)
    return UnitClass(unit)
end

function Compat.UnitIsUnit(unit, other)
    return UnitIsUnit(unit, other)
end

function Compat.UnitIsDead(unit)
    return UnitIsDead(unit)
end

function Compat.UnitGroupRolesAssigned(unit)
    return UnitGroupRolesAssigned(unit)
end

---------------------------------------------------------
-- 音效
---------------------------------------------------------

function Compat.PlaySoundFile(file, ...)
    PlaySoundFile(file, ...)
end

---------------------------------------------------------
-- 下拉菜单（Dragonflight 中已废弃，4.3 上透传）
---------------------------------------------------------

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

---------------------------------------------------------

_G.DXE_Compat = Compat