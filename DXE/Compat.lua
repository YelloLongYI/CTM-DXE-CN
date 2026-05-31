---------------------------------------------------------
-- DXE/Compat.lua
-- WoW 客户端 API 适配层
--
-- IS_CLASSIC 初始值硬编码为 4.3.4，Core.lua:594 安全位置修正
---------------------------------------------------------

local Compat = setmetatable({
    IS_CLASSIC = false,

    -- GUID 解析
    GetNPCIDFromGUID = function(guid)
        if not guid then return nil end
        return tonumber(guid:sub(7, 10), 16)
    end,

    -- 通信
    SendAddonMsg = function(prefix, msg, channel, target)
        SendAddonMessage(prefix, msg, channel, target)
    end,

    -- 下拉菜单
    UIDropDown_CreateInfo = function()
        return UIDropDownMenu_CreateInfo()
    end,
    UIDropDown_AddButton = function(info, level)
        UIDropDownMenu_AddButton(info, level)
    end,
    UIDropDown_Initialize = function(frame, init, mode)
        UIDropDownMenu_Initialize(frame, init, mode)
    end,
    UIDropDown_SetSelectedValue = function(frame, value)
        UIDropDownMenu_SetSelectedValue(frame, value)
    end,
    UIDropDown_SetText = function(frame, text)
        UIDropDownMenu_SetText(frame, text)
    end,
    ToggleDropDown = function(level, value, frame, anchor, x, y)
        ToggleDropDownMenu(level, value, frame, anchor, x, y)
    end,
}, {
    __index = _G,
})

_G.DXE.Compat = Compat