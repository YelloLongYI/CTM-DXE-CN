local defaults = {
	profile = {8,7,6,5,4,3,2,1,Enabled = true,EnabledPartyLeaderBypass = true},
	--[===[@debug@
	global = {
		debug = {
		},
	},
	--@end-debug@]===]
}

-- WORKS: SetRaidTarget(unit,0); SetRaidTarget(unit,[1,8]) 
-- BROKEN: SetRaidTarget(unit,[1,8]); SetRaidTarget(unit,0) 

local addon = DXE
local L = addon.L

local wipe = table.wipe
local targetof = addon.targetof
local SetRaidTarget_Blizzard = SetRaidTarget
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitGUID = UnitGUID
local ipairs,pairs = ipairs,pairs

local module = addon:NewModule("RaidIcons","AceTimer-3.0","AceEvent-3.0")
addon.RaidIcons = module


local db,pfl
local debug

local match,find,gmatch,sub = string.match,string.find,string.gmatch,string.sub

-- RaidIcons list
local iconsList = {
    {texture = format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",1),name = L["Star"],color = "ffff00"},
    {texture = format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",2),name = L["Circle"],color = "ff7d0a"},
    {texture = format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",3),name = L["Diamond"],color = "ff00ff"},
    {texture = format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",4),name = L["Triangle"],color = "00ff00"},
    {texture = format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",5),name = L["Moon"],color = "f0f0f0"},
    {texture = format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",6),name = L["Square"],color = "53a9ff"},
    {texture = format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",7),name = L["Cross"],color = "ff0000"},
    {texture = format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",8),name = L["Skull"],color = "ffffff"},
}

addon.RaidIcons.iconsList = iconsList
-- Workaround the issue where in 4.0.1 SetRaidTarget now toggles
-- Just like SetRaidTargetIcon
local function SetRaidTarget(unit, icon)
	if not icon then return end
	if GetRaidTargetIndex(unit) ~= icon then
		SetRaidTarget_Blizzard(unit,icon)
	end
end

function module:RefreshProfile() pfl = db.profile end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("RaidIcons", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")

	--[===[@debug@
	debug = addon:CreateDebugger("RaidIcons",db.global,db.global.debug)
	--@end-debug@]===]
end

function module:OnDisable()
	self:RemoveAll()
end

-------------------------------------------
-- FRIENDLY MARKING
-------------------------------------------

do
	local units = {}        -- unit -> handle
	local friendly_cnt = {} -- var  -> count
	local count_resets = {} -- var  -> handle

	local function ResetCount(var)
		friendly_cnt[var] = nil
		count_resets[var] = nil
	end

	---------------------------------
	-- API
	---------------------------------

	function module:RemoveIcon(removeData)
		if not pfl.Enabled then return end
        local unit -- unit to icon remove from
        local icon -- player's old icon to reset
        if type(removeData) == "table" then
            unit = removeData.unit
            icon = removeData.icon or 0
        else
            unit = removeData
            icon = 0
        end
		module:CancelTimer(units[unit],true)
		SetRaidTarget(unit,icon)
		units[unit] = nil
	end

	function module:MarkFriendly(unit,iconData,persist,ix)
		if not pfl.Enabled then return end
		-- Unschedule unit's icon removal. The schedule is effectively reset.
		if units[unit] then 
			self:CancelTimer(units[unit],true) 
			units[unit] = nil
		end
        ix = ix or 0
        ix = ix + 1
        local iconVar = iconData["mark"..ix]
        local icon
        
        if find(iconVar, "^preset[1-8]$") then
            icon = pfl[tonumber(match(iconVar, "^preset([1-8])$"))]
        elseif find(iconVar, "^custom[1-8]$") then
            icon = tonumber(match(iconVar, "^custom([1-8])$"))
        end
        if not (GetRaidTargetIndex(unit) == icon) then -- don't override unit's icon if they are the same
            local removeData = {
                unit = unit,
                icon = GetRaidTargetIndex(unit),
            }
            SetRaidTarget(unit,icon)
            if persist then
                units[unit] = self:ScheduleTimer("RemoveIcon",persist,removeData)
            end
        end
	end

	-- Actual icon is chosen by increasing icon parameter
	function module:MultiMarkFriendly(var,unit,iconData,persist,reset,total)
		if not pfl.Enabled then return end
		local ix = friendly_cnt[var] or 0
		-- maxed out
		if ix >= total then return end
		--icon = icon + ix -- calc icon
		self:MarkFriendly(unit,iconData,persist,ix)
		friendly_cnt[var] = ix + 1
		if not count_resets[var] and reset  then
			count_resets[var] = self:ScheduleTimer(ResetCount,reset,var)
		end
	end

	function module:RemoveAllFriendly()
		for unit in pairs(units) do self:RemoveIcon(unit) end
		wipe(friendly_cnt)
		wipe(count_resets)
	end
end

-------------------------------------------
-- ENEMY MARKING
-------------------------------------------

do
	local PAUSE_TIME = 0.5
	local unit_to_unittarget = addon.Roster.unit_to_unittarget
	local enemy_cnt = {}      -- var  -> count
	local count_resets = {}   -- var  -> handle
	local used_icons = {}     -- var  -> {icons}
	local removes = {}        -- var  -> handle

	local guids = {}          -- guid -> icon
	local teardown_handle
	local registered          -- whether or not we registered for events

	local function Teardown()
		if registered then
			module:UnregisterEvent("UNIT_TARGET")
			module:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
			registered = nil
		end
		if teardown_handle then
			module:CancelTimer(teardown_handle)
			teardown_handle = nil
		end
		wipe(guids)
	end

	local function MarkUnit(unit)
		--[===[@debug@
		assert(type(unit) == "string")
		--@end-debug@]===]
		local guid = UnitGUID(unit)
		if guid then
			local icon = guids[guid]
			if icon then
				SetRaidTarget(unit,icon)
				local currentIcon = GetRaidTargetIndex(unit)
                guids[guid] = nil
				-- teardown if guids is empty
				if not next(guids) then Teardown() end
				return true
			else
                local id = tostring(tonumber((guid):sub(-12, -9), 16))
                icon = guids[id]
                if icon then
                    SetRaidTarget(unit,icon)
                    guids[id] = nil
                    if not next(guids) then Teardown() end
                    return true
                end
            end
        end
	end

	local function MarkGUID(guid,icon)
		--[===[@debug@
		assert(type(guid) == "string")
		assert(type(icon) == "number")
		--@end-debug@]===]

		for _,unit in pairs(unit_to_unittarget) do
			if UnitGUID(unit) == guid then
				SetRaidTarget(unit,icon)
				return true
			end
		end
	end
    
    local function MarkID(id,icon)
		--[===[@debug@
		assert(type(guid) == "string")
		assert(type(icon) == "number")
		--@end-debug@]===]
		for _,unit in pairs(unit_to_unittarget) do
            local guid = UnitGUID(unit,"raidicon")
            if guid then
                local unitID = tonumber((guid):sub(-12, -9), 16)
                if unitID == tonumber(id) then
                    SetRaidTarget(unit,icon)
                    return true
                end
            end
		end
	end
    
	local function ResetCount(var)
		enemy_cnt[var]    = nil
		count_resets[var] = nil
	end

	-- Note: SetRaidTarget("player",[1-8]); SetRaidTarget("player",0) doesn't work
	-- so the second call has to be scheduled PAUSE_TIME later

	local function RemovePlayerIcon()
		SetRaidTarget("player",0)
	end

	local function RemoveSingleIcon(icon)
		SetRaidTarget("player",icon)
		module:ScheduleTimer(RemovePlayerIcon,PAUSE_TIME)
	end

	local function RemoveMultipleIcons(var)
        local t = used_icons[var]
		if t then
			for i,icon in ipairs(t) do
				SetRaidTarget("player",icon)
				t[i] = nil -- reuse table during attempt
			end
		end
		removes[var] = nil
		module:ScheduleTimer(RemovePlayerIcon,PAUSE_TIME)
	end

	---------------------------------
	-- EVENTS
	---------------------------------

	function module:UNIT_TARGET(_,unit)
		MarkUnit(targetof[unit])
	end

	function module:UPDATE_MOUSEOVER_UNIT()
		MarkUnit("mouseover")
	end

    function module:ParseIcon(iconVar)
        if find(iconVar, "^preset[1-8]$") then
            return pfl[tonumber(match(iconVar, "^preset([1-8])$"))]
        elseif find(iconVar, "^custom[1-8]$") then
            return tonumber(match(iconVar, "^custom([1-8])$"))
        end
    end
    
    function module:GUIDHasPriorIcon(var, guid, iconData, total)
        for _,unit in pairs(unit_to_unittarget) do
			if UnitGUID(unit) == guid then
				if module:UnitHasPriorIcon(var, unit, iconData, total) then return true end
			end
		end
        
        return false
    end
    
    function module:UnitHasPriorIcon(var, unit, iconData, total)
        if type(total) ~= "number" or total < 1 then return end
        
        for i=1,total do
            local iconVar = iconData["mark"..i]
            local icon = module:ParseIcon(iconVar)
            if GetRaidTargetIndex(unit) == icon then
                return true
            end
        end
        
        return false
    end
    
    

	---------------------------------
	-- API
	---------------------------------

	-- @param persist <number> number of seconds to attempt marking
	-- @param remove <boolean> whether or not to remove after persist
	function module:MarkEnemy(guid,iconData,persist,remove,ix)
		if not pfl.Enabled then return end
		ix = ix or 0
        ix = ix + 1
        local iconVar = iconData["mark"..ix]
        local icon = module:ParseIcon(iconVar)
        local success = MarkGUID(guid,icon) or MarkID(guid,icon)
		if not success then
			guids[guid] = icon
			if not registered then
				self:RegisterEvent("UNIT_TARGET")
				self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
				registered = true
			end
			if persist then
                if teardown_handle then self:CancelTimer(teardown_handle) end
                teardown_handle = self:ScheduleTimer(Teardown,persist)
            end
		end

		if remove then self:ScheduleTimer(RemoveSingleIcon,persist,icon) end
	end

	function module:MultiMarkEnemy(var,guid,iconData,persist,remove,reset,total)
		if not pfl.Enabled then return end

		-- var keeps track of icon count
		local ix = enemy_cnt[var] or 0
		-- maxed out
        if ix == total or module:GUIDHasPriorIcon(var,guid,iconData,total) then
            return false
        end
        self:MarkEnemy(guid,iconData,persist,false,ix) -- ignore single icon removing
		enemy_cnt[var] = ix + 1
		if not count_resets[var] and reset then
			count_resets[var] = self:ScheduleTimer(ResetCount,reset,var)
		end
        
        local iconVar = iconData["mark"..(ix + 1)]
        local icon = module:ParseIcon(iconVar)
		-- multiple removes
		if remove then
			local t = used_icons[var]
			if not t then
				t = {}
				used_icons[var] = t
			end
			t[#t+1] = icon
			-- make sure we only schedule one
			if not removes[var] and persist  then
				removes[var] = self:ScheduleTimer(RemoveMultipleIcons,persist,var)
			end
		end
	end

	function module:RemoveAllEnemy()
		wipe(enemy_cnt)
		wipe(count_resets)
		wipe(used_icons)
		wipe(removes)
		Teardown()
	end
end

-------------------------------------------
-- CLEANUP
-------------------------------------------

function module:RemoveAll()
	if not pfl.Enabled then return end

	self:RemoveAllFriendly()
	self:RemoveAllEnemy()
	self:CancelAllTimers() -- goes last
end

-------------------------------------------
-- UTIL
-------------------------------------------

function module:HasIcon(unit,icon)
	icon = tonumber(icon)
	return icon and GetRaidTargetIndex(unit) == icon
end

function module:AllowPartyLeaderBypass()
    if pfl then
        if pfl.EnabledPartyLeaderBypass == nil then
            return false
        elseif not pfl.EnabledPartyLeaderBypass then
            return false
        end
    end
    
    return true
end
