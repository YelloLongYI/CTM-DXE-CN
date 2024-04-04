--[[
	The invoker executes commands in encounter data

	Terminology:

	A command line is every sequential pair of values (1,2), (3,4), (5,6), etc. in a command list
	A command list is an array of command lines
	A command bundle is an array of command lists

	Valid commands are:
		expect 				= {"<token or value> ... <token_n or value_n>","<op>","<token' or value'> ... <token_n' or value_n'>"}
		quash 				= "<alert>"
		set 				= {<var> = <token or value>, ..., <var_n> = <token_n or value_n> }
		alert 				= "<alert>"
		scheduletimer	    = {"<timer>",<token or number>}
		canceltimer 		= "<timer>"
		resettimer 			= [BOOLEAN]
		tracing 			= {<name>,...,<name_n>}
		unittracing		    = {"boss1",...,"boss4"}
        temptracing         = {<name>,....<name_n>}
        closetemptracing
		proximitycheck  	= {"<token>",[10,11,18, or 28]}
		outproximitycheck	= {"<token>",[10,11,18, or 28]}
		raidicon 			= "<raidicon>"
		removeraidicon      = "<token>"
		arrow 				= "<arrow>"
		removearrow 		= "<token>"
		removeallarrows	    = [BOOLEAN]
		invoke              = command bundle
		defeat              = [BOOLEAN]
		insert              = {"<userdata>", value},
		wipe                = "<userdata>"
		batchalert          = {"<alert>",...,"<alert_n>"}
		batchquash          = {"<alert>",...,"<alert_n>"}
		quashall            = [BOOLEAN]
		schedulealert       = {"<alert>",<token or number>}
		repeatalert         = {"<alert>",<token or number>}
		cancelalert         = "<alert>"
        silentDefeat        = [BOOLEAN]
        triggerdefeat       = [BOOLEAN]
        getdistance         = "<token>"
        getguidhp           = "<token>"
]]

local addon = DXE
local L = addon.L
local NID = addon.NID
local SN = addon.SN
local unit_to_unittarget = addon.Roster.unit_to_unittarget
local targetof = addon.targetof

local GetTime = GetTime
local wipe,concat = table.wipe,table.concat
local type,next,select = type,next,select
local ipairs,pairs,unpack = ipairs,pairs,unpack
local tostring,tonumber = tostring,tonumber
local band,bor = bit.band,bit.bor
local match,gmatch,gsub,find,split = string.match,string.gmatch,string.gsub,string.find,string.split
local UnitGUID, UnitName, UnitExists, UnitIsUnit = UnitGUID, UnitName, UnitExists, UnitIsUnit
local UnitBuff,UnitDebuff = UnitBuff,UnitDebuff

local pfl,key,CE,alerts,raidicons,arrows,announces

local function RefreshProfile(db) pfl = db.profile end
addon:AddToRefreshProfile(RefreshProfile)

-- Temp variable environment
local userdata = {}
-- Command line handlers
local handlers = {}

local getid

---------------------------------------------
-- TABLE POOL
---------------------------------------------

local cache = {}
setmetatable(cache,{__mode = "k"})
local new = function()
	local t = next(cache)
	if t then
		cache[t] = nil
		return t
	else
		return {}
	end
end

local del = function(t)
	wipe(t)
	cache[t] = true
	return nil
end

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local module = addon:NewModule("Invoker","AceEvent-3.0","AceTimer-3.0")

addon.Invoker = module
local HW = addon.HW
local Alerts = addon.Alerts
local Arrows = addon.Arrows
local RaidIcons = addon.RaidIcons
-- command bundles executed upon events
local event_to_bundle = {}
local eventtype_to_bundle = {}
local combatbundle_to_filter = {}
local eventbundle_to_filter = {}

--[===[@debug@
local debug

local debugDefaults = {
	-- Related to function names
	Alerts = false,
	REG_EVENT = false,
	["handlers.set"] = false,
	replace_funcs = false,
	insert = false,
	wipe = false,
	wipe_container = false,
	["target.bossunit"] = false,
	["target.OBJECT_TARGET"] = false,
	["target.OBJECT_FOCUS"] = false,
	["target.StartPolling"] = false,
	["target.TeardownTarget"] = false,
	["target.failsafe"] = false,
	["target.scan"] = false,
	["target.try"] = false,
	["target.UNIT_TARGET"] = false,
	["target.fire"] = false,
}

--@end-debug@]===]

function module:OnInitialize()
	addon.RegisterCallback(self,"SetActiveEncounter","OnSet")
	addon.RegisterCallback(self,"StartEncounter","OnStart")
	addon.RegisterCallback(self,"StopEncounter","OnStop")
    addon.RegisterCallback(self,"StartBattleground","OnBattlegroundStart")
	addon.RegisterCallback(self,"StopBattleground","OnBattlegroundStop")
	--[===[@debug@
	self.db = addon.db:RegisterNamespace("Invoker", {
		global = {
			debug = debugDefaults
		},
	})

	debug = addon:CreateDebugger("Invoker",self.db.global,debugDefaults)
	--@end-debug@]===]
end

---------------------------------------------
-- EVENT TUPLES
---------------------------------------------

local tuple = {}

local function SetTuple(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16)
	tuple['1']  = a1  or "nil"
	tuple['2']  = a2  or "nil"
	tuple['3']  = a3  or "nil"
	tuple['4']  = a4  or "nil"
	tuple['5']  = a5  or "nil"
	tuple['6']  = a6  or "nil"
	tuple['7']  = a7  or "nil"
	tuple['8']  = a8  or "nil"
	tuple['9']  = a9  or "nil"
	tuple['10'] = a10 or "nil"
	tuple['11'] = a11 or "nil"
	tuple['12'] = a12 or "nil"
	tuple['13'] = a13 or "nil"
	tuple['14'] = a14 or "nil"
	tuple['15'] = a15 or "nil"
	tuple['16'] = a16 or "nil"

end

---------------------------------------------
-- CONTROLS
---------------------------------------------

function module:OnStart(_,...)
	if not CE then return end
	if next(eventtype_to_bundle) then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","COMBAT_EVENT")
	end
	for event in pairs(event_to_bundle) do
		self:RegisterEvent(event,"REG_EVENT")
	end
	addon:SetTracing(CE.onactivate.tracing)
    addon:SetPhaseMarkers(CE.onactivate.phasemarkers)
	-- Reset colors if not acquired
	for i,hw in ipairs(HW) do
		if hw:IsOpen() and not hw.tracer:First() then
			hw:SetInfoBundle("",1,1)
			hw:ApplyNeutralColor()
		end
	end
	if CE.onstart then
		self:InvokeCommands(CE.onstart,...)
	end
	if CE.enrage then
		self:Enrage(CE.enrage)
	end
end

function module:OnStop()
	if not CE then return end
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	for event in pairs(event_to_bundle) do
		self:UnregisterEvent(event)
	end
	self:ResetUserData()
	Alerts:QuashByPattern("^invoker")
	Arrows:RemoveAll()
	RaidIcons:RemoveAll()
	--self:TeardownTarget()
	self:RemoveAllTimers()
	self:ResetAlertData()
end

---------------------------------------------
-- ENRAGE HANDLER
---------------------------------------------
--[[
	Syntax in Encounters.lua:
	local data = {
		...
		enrage = {
			time10n = 600,
			time25n = 600,
			time10h = 600,
			time25h = 600,
		},
		...
	},
]]

do
	local diff_to_key = {
		[1] = "time10n",
		[2] = "time25n",
		[3] = "time10h",
		[4] = "time25h",
	}
    
    function module:Enrage(info)
		if not info then return end
		local diff = addon:GetRaidDifficulty()
		local key = diff_to_key[diff]

		local time = info[key] or nil
		local text = select(1, GetSpellInfo(8599))
		local icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"

		if time and time > 0 then
			Alerts:Dropdown("invoker_enrage",text,time,30,nil,"RED","GOLD",nil,icon)
		end
	end
end

---------------------------------------------
-- REPLACES
---------------------------------------------

local ReplaceTokens

local function next_series_value(series,key)
	local ix,n = key.."_index",#series
	local i = userdata[ix]
	if i > n and not series.loop then
		i = n
	else
		i = ((i-1)%n)+1 -- Handles looping
		userdata[ix] = userdata[ix] + 1
	end
	return series[i]
end

local upvalue = ""

do
	local function tft()
		return HW[1].tracer:First() and HW[1].tracer:First().."target" or ""
	end
	-- targetchecks (code from BigWigs, thanks!)
	local t = nil
	local function buildTable()
		t = {
			"boss1", "boss2", "boss3", "boss4",
			"target", "targettarget",
			"focus", "focustarget",
			"mouseover", "mouseovertarget",
			"party1target", "party2target", "party3target", "party4target"
		}
		for i = 1, 25 do t[#t+1] = string.format("raid%dtarget", i) end
	end
	local function findTargetByGUID(id)
		local idType = type(id)
		if not t then buildTable() end
		for i, unit in next, t do
			if UnitExists(unit) and not UnitIsPlayer(unit) then
				local unitId = UnitGUID(unit)
				if idType == "number" then unitId = tonumber(unitId:sub(7, 10), 16) end
				if unitId == id then return unit end
			end
		end
	end

	local function GetUnitIdByGUID(mob)
		return findTargetByGUID(mob)
	end

	local function checkTarget(GUID)
        local mobId = GetUnitIdByGUID(GUID)
		if mobId then
			local player = UnitName(mobId.."target")
			if player then return player else return 0 end
		elseif GUID then
			local player = UnitName(GUID.."target")
			if player then return player else return 0 end
        end
	end
	-- end targetchecks
	local RepFuncs = {
		playerguid = function() return addon.PGUID end,
        unitguid = function(unit) unit = addon:AdjustUnit(unit) return UnitGUID(unit) end,
        unitname = function(unit) return UnitName(unit) end,
        unitcombat = function(unit) return UnitAffectingCombat(unit) and "true" or "false" end,
        unitfaction = function(unit) return UnitFactionGroup(unit) end,
        unitreaction = function(unit1,unit2) return UnitReaction(unit1,unit2) end,
		playername = function() return addon.PNAME end,
		vehicleguid  = function() return UnitGUID("vehicle") or "" end,
		vehiclenames = function() return concat(addon:VehicleNames(),", ") end,
		difficulty = function() return addon:GetRaidDifficulty() end,
        groupsize = function() return addon:GetRaidSize() end,
		-- First health watcher
		tft = tft,
		tft_unitexists = function() return not not UnitExists(tft()) end,
		tft_isplayer = function() return not not UnitIsUnit(tft(),"player") end,
		tft_unitname = function() return UnitName(tft()) end,
		srcname_or_YOU = function() return addon.PGUID == tuple['1'] and L.alert["YOU"] or tuple['2'] end,
		dstname_or_YOU = function() return addon.PGUID == tuple['4'] and L.alert["YOU"] or tuple['5'] end,
		upvalue = function() return upvalue end,
		--- Functions with passable arguments
		-- Get's an alert's timeleft. Note: Add support if timeleft is ever used on a tagged alert
		timeleft = function(id,delta) return Alerts:GetTimeleft(getid(id)) + (tonumber(delta) or 0) end,
		npcid = function(guid) guid = ReplaceTokens(guid) return NID[guid] or "" end,
		playerdebuff = function(debuff) return not not UnitDebuff("player",debuff) end,
		playerdebuffdur = function(debuff,rounddown) local x = select(7,UnitDebuff("player",debuff)) - GetTime();return format(rounddown and "%d" or "%f",x) end,
		playerbuff = function(buff) return not not UnitBuff("player",buff) end,
		playerbuffdur = function(buff) local x = select(7,UnitBuff("player",buff)) - GetTime() return format("%d",x) end,
        debuff = function(unit,debuff) return not not UnitDebuff(unit,debuff) end,
		debuffhasdur = function(unit,debuff) local x = select(7,UnitDebuff(unit,debuff)); return tostring(type(tonumber(x)) == "number") end,
        debuffdur = function(unit,debuff) local x = select(7,UnitDebuff(unit,debuff)) - GetTime() return format("%d",x) end,
		buff = function(unit,buff) return not not UnitBuff(unit,buff) end,
		buffdur = function(unit,buff) local x = select(7,UnitBuff(unit,buff)) - GetTime() return format("%d",x) end,
		debuffstacks = function(unit,debuff) local c = select(4,UnitDebuff(unit,debuff)) return c end,
		buffstacks = function(unit,buff) local c = select(4,UnitBuff(unit,buff)) return c end,
		hasicon = function(unit,icon) return RaidIcons:HasIcon(unit,icon) end,
		closest = function(container) return addon:FindClosestUnit(userdata[container]) end,
        ischannelingspell = function(unit, spell) local name = UnitChannelInfo(unit);return spell == name end,
		channeldur = function(unit) local name,sub,text,texture,start,finish = UnitChannelInfo(unit) if start and finish then return (finish - start) / 1000 else return 0 end end,
		castdur =   function(unit) local name,sub,text,texture,start,finish = UnitCastingInfo(unit) if start and finish then return (finish - start) / 1000 else return 0 end end,
        casttimeleft = function(unit) local name,sub,text,texture,start,finish = UnitCastingInfo(unit) if finish then return (finish-(GetTime()*1000)) / 1000 else return 0 end end,
		gethp = function(unit) unit = addon:AdjustUnit(unit) local hp,hpmax = UnitHealth(unit),UnitHealthMax(unit) if hp and hpmax then return hp / hpmax * 100 else return 0 end end,
        getguidhp = function(guid) return addon:GetHPByGUID(guid) end,
		getup = function(unit) unit = addon:AdjustUnit(unit) local up,upmax = UnitPower(unit),UnitPowerMax(unit) if up and upmax then return up / upmax * 100 else return 0 end end,
		getap = function(unit) local ap = UnitPower(unit, ALTERNATE_POWER_INDEX) if ap then return ap else return 0 end end,
        getdistance = function(guid) return addon:GetGUIDDistance(guid) end,
		gettarget = function(guid) return checkTarget(guid) end,
        unitbyguid = function(guid) return tostring(addon:GetUnitByGUID(guid)) end,
		listsize = function(container) return (#userdata[container] or 0) end,
        list = function(container,ignoreColoring) local s ="" for i,v in ipairs(userdata[container]) do s = s..(not ignoreColoring and "<" or "")..v..(not ignoreColoring and ">" or "")..(i<#userdata[container] and ", " or "") end gsub(s,"%s$","") return s end,
        listcontains = function(container,element)
            for i,v in ipairs(userdata[container]) do
                if element == v then return "true" end
            end
            
            return "false"
        end,
        listindexof = function(container,element)
            for i,v in ipairs(userdata[container]) do
                if element == v then return i end
            end
            
            return nil
        end,
        listget = function(container,...)
            local count = select("#",...)
            
            local current = userdata[container]
            for i=1,count do
                local index = select(i,...)
                current = current[index]
            end
            
            return tostring(current)
        end,
        mapget = function(map, key)
            return userdata[map][ReplaceTokens(key) or "nil"]
        end,
        mapsize = function(map)
            local size = 0
            for _,_ in pairs(userdata[map]) do
                size = size + 1
            end
            return size
        end,
        maphaskey = function(map, key)
            return tostring(userdata[map][key] ~= nil)
        end,
		guidisplayertarget = function(guid) return UnitGUID("playertarget") == guid end,
        unitisunit = function(unit1,unit2) return UnitIsUnit(unit1,unit2) and "true" or "false" end,
        unitisplayertype = function(unit) return UnitIsPlayer(unit) and "true" or "false" end,
        unitclass = function(unit) return UnitClass(unit) end,
        sum = function(a,b) return tonumber(a)+tonumber(b) end,
        substract = function(a,b) return tonumber(a)-tonumber(b) end,
        mult = function(a,b) return tonumber(a)*tonumber(b) end,
        divide = function(a,b) return tonumber(a)/tonumber(b) end,
        getraidtargetindexbyguid = function(guid) return addon:GetRaidTargetIndexByGUID(guid) end,
        getraidtargettexturebyguid = function(guid) return addon:GetRaidTargetTextureByGUID(guid) end,
        getraidtargetchatbyguid = function(guid) return addon:GetRaidTargetChatByGUID(guid) end,
        itemenabled = function(var) return tostring(addon.ItemEnabled(var)) end,
        itemvalue = function(var) return addon.ItemValue(var) end,
        valuepriority = function(var,value) return addon.ValuePriority(var, value) end,
        stacks = function(var) return addon.db.profile.Encounters[CE.key][var].stacks or addon.CE.alerts[var].stacks end,
        gettime = function(pattern) return format(pattern or "%d",GetTime()) end,
        sn = function(id) return addon.SN[tonumber(id)] end,
        st = function(id) return addon.ST[tonumber(id)] end,
        sl = function(id) return addon.SL[tonumber(id)] end,
        isnumber = function(value) return tostring(type(tonumber(value))=="number") end,
        match = function(str,pattern) return match(str,pattern) end,
        getbattlegroundtime = function(pattern) return format(pattern or "%d",GetBattlefieldInstanceRunTime()/1000) end,
        neg = function(info) if info == "true" then return "false" elseif info == "false" then return "true" else return info end end,
        unitrole = function(unit) return UnitGroupRolesAssigned(unit) end,
        unitpositionx = function(unit)
            local x,y = GetPlayerMapPosition(unit)
            if x == 0 and y == 0 then
                SetMapToCurrentZone()
                x,y = GetPlayerMapPosition(unit)
            end
            return x
        end,
        unitpositiony = function(unit)
            local x,y = GetPlayerMapPosition(unit)
            if x == 0 and y == 0 then
                SetMapToCurrentZone()
                x,y = GetPlayerMapPosition(unit)
            end
            return y
        end,
        iswipedelayed = function() return tostring(addon:IsWipeDelayed()) end,
        capitalize = function(text) return addon.util.capitalize(text) end,
        getbattlegroundshutdowntime = function() return BATTLEFIELD_SHUTDOWN_TIMER end,
	}

	-- Add funcs for the other health watchers
	do
		for i=2,4 do
			local tft = function() return HW[i].tracer:First() and HW[i].tracer:First().."target" or "" end
			local tft_unitexists = function() return not not UnitExists(tft()) end
			local tft_isplayer = function() return not not UnitIsUnit(tft(),"player") end
			local tft_unitname = function() return UnitName(tft()) end
			RepFuncs["tft"..i] = tft
			RepFuncs["tft"..i.."_unitexists"] = tft_unitexists
			RepFuncs["tft"..i.."_isplayer"] = tft_isplayer
			RepFuncs["tft"..i.."_unitname"] = tft_unitname
		end
	end
    
    local ModFuncs
    
    function addon:RegisterModuleFunctions(CE)
        if CE.key == "default" then return end
        
        if CE.functions and type(CE.functions) == "table" then
            ModFuncs = CE.functions
        else
            ModFuncs = nil
        end
    end
    handlers.execute = function(info)
        if type(info) == "string" and ModFuncs[info] then
            ModFuncs[info]()
        elseif type(info) == "table" then
            local funcName = info[1]
            if ModFuncs[funcName] then            
                for i=2,#info do
                    info[i] = ReplaceTokens(info[i])
                end
                ModFuncs[funcName](select(2,unpack(info)))
            end
        end
        
        return true
    end

	--[===[@debug@
	function module:GetRepFuncs()
		return RepFuncs
	end
	--@end-debug@]===]

	local replace_nums = tuple

	local function replace_vars(str)
        local val = userdata[str]
		if type(val) == "table" then
			val = next_series_value(val,str)
		end
		return val
	end
    
    local function replace_colored_vars(str)
        local val = userdata[str]
		if type(val) == "table" then
			val = next_series_value(val,str)
		end
		return "<"..val..">"
    end

    local replace_funcs
    
    local function replace_funcs(str)
        if find(str,"|") then
            if str:find("&.+&") then
                local func,args = string.match(str,"^([^|]+)|(.+)")
                args = args:find("&.+&") and args:gsub("&(.-)&",replace_funcs) or args
                func = RepFuncs[func] or ModFuncs[func]
                if not func then return end
                return func(split("|",args))
            else
                local func,args = string.match(str,"^([^|]+)|(.+)")
                func = RepFuncs[func] or ModFuncs[func]
                if not func then return end
                return tostring(func(split("|",args)))
           end
            local func,args = match(str,"^([^|]+)|(.+)")
			func = RepFuncs[func] or ModFuncs[func]
			if not func then return end
			--[===[@debug@
			debug("replace_funcs",format("func: %s ret: %s",str,tostring(func(split("|",args)))))
			--@end-debug@]===]
            return tostring(func(split("|",args)))
		else
			local func = RepFuncs[str] or ModFuncs[str]
			if not func then return end
			--[===[@debug@
			debug("replace_funcs",format("func: %s ret: %s",str,tostring(func())))
			--@end-debug@]===]
			return tostring(func())
		end
	end
    
	-- Replaces special tokens with values
	-- IMPORTANT: replace_funcs goes last
	function ReplaceTokens(str)
        if type(str) ~= "string" then return str end
        str = gsub(str,"#(.-)#",replace_nums)
		str = gsub(str,"<<(.-)>>",replace_colored_vars)
        str = gsub(str,"<(.-)>",replace_vars)
        str = gsub(str,"&(.+)&",replace_funcs)
		return str
	end
    
    function addon:ReplaceTokensM(str)
        return ReplaceTokens(str)
    end
end

---------------------------------------------
-- PREFILTER
-- for: alert, announce, arrow, raidicon
---------------------------------------------

local shortcuts = {
	srcself = function() return addon.PGUID == tuple['1'] end,
	srcother = function() return addon.PGUID ~= tuple['1'] end,
	dstself = function() return addon.PGUID == tuple['4'] end,
	dstother = function() return addon.PGUID ~= tuple['4'] end,
}

-- returns <var> or false
-- if false, then break execution in the command handler
local function prefilter(info,command)
	-- var is info
	if type(info) ~= "table" then return ReplaceTokens(info) end
	-- inlined expect
	local expect = info.expect
	if expect and not handlers.expect(expect) then
		return false
	end
	for k,cond in pairs(shortcuts) do
		if info[k] and cond() then
			handlers[command](info[k])
		end
	end
	-- var is the first index
	-- if nil, then break execution in the command handler
    return ReplaceTokens(info[1])
end

addon.ItemEnabled = function(var,enckey)
    local CE = enckey and addon.EDB[enckey] or addon.CE
    local collections = {CE.announces,CE.alerts,CE.misc}
    
    for _,collection in ipairs(collections) do
        local moduleItem = collection[var]
        local profileItem = addon.db.profile.Encounters[CE.key][var]
        if moduleItem and profileItem and profileItem.enabled then return true end
    end
    return false
end

addon.ItemValue = function(var,enckey)
    local CE = enckey and addon.EDB[enckey] or addon.CE
    local collections = {"misc"}
    var = ReplaceTokens(var)
    
    for _,collection in ipairs(collections) do
        local profileItem = addon.db.profile.Encounters[CE.key][collection][var]
        if profileItem then
            return tostring(addon.db.profile.Encounters[CE.key][collection][var].value)
        end
    end
    return "nil"
end

---------------------------------------------
-- CONDITIONS
-- Credits to PitBull4's debug for this idea
---------------------------------------------

do
	local ops = {}

	ops['=='] = function(a, b) return a == b end
	ops['~='] = function(a, b) return a ~= b end
	ops['find'] = function(a,b) return find(a,b) end

	-- Intended to be used on numbers

	ops['>'] = function(a, b)
		a,b = tonumber(a),tonumber(b)
		if not a or not b then return false
		else return a > b end
	end

	ops['>='] = function(a, b)
		a,b = tonumber(a),tonumber(b)
		if not a or not b then return false
		else return a >= b end
	end

	ops['<'] = function(a, b)
		a,b = tonumber(a),tonumber(b)
		if not a or not b then return false
		else return a < b end
	end

	ops['<='] = function(a, b)
		a,b = tonumber(a),tonumber(b)
		if not a or not b then return false
		else return a <= b end
	end

	local t = {}
	for k, v in pairs(ops) do t[#t+1] = k end
	for _, k in ipairs(t) do
		ops["not_" .. k] = function(a, b)
			return not ops[k](a, b)
		end
	end

	--[===[@debug@
	function module:GetConditions()
		return ops
	end
	--@end-debug@]===]

	local t = {}
	-- @ADD TO HANDLERS
	handlers.expect = function(info)
		if #info == 3 then
            return ops[info[2]](ReplaceTokens(info[1]),ReplaceTokens(info[3]))
		else
			-- there are at least two triplets
			--
			-- left to right association
			-- ex. (((a and b) or c) and d)
			--
			-- XXX A XXX A XXX A XXX
			--
			-- 3*x          + (x-1)           = 4x - 1 = total number
			-- ^					 ^
			-- num triplets    num logical ops

			local nres = (#info + 1) / 4
			for i=1,nres do
				-- left index of triplet
				local j = 4*i - 3
				local v1,op,v2 = info[j],info[j+1],info[j+2]
				local v = ops[op](ReplaceTokens(v1),ReplaceTokens(v2))
				t[i] = v
			end
			local ret = t[1]
			for i=2,nres do
				local ix = (i-1)*4
				local log_op = info[ix]
				if log_op == "AND" then
					ret = ret and t[i]
				elseif log_op == "OR" then
					ret = ret or t[i]
				end
			end
			return ret
		end
	end
end

---------------------------------------------
-- USERDATA
---------------------------------------------

do
	local wipeins = {} -- var -> handles

	local alert_keys = {
		"text",
		"time",
		"time10n",
		"time10h",
		"time25n",
		"time25h",
        "time10man",
        "time25man",
	}

	for i=2,9 do
		alert_keys[#alert_keys+1] = "text"..i
		alert_keys[#alert_keys+1] = "time"..i
	end

	function module:ResetUserData()
		wipe(userdata)
		for k,handle in pairs(wipeins) do
            module:CancelTimer(handle)
			wipeins[k] = nil
		end

		-- Copy alert time/text series into userdata
		-- time[2-9], text[2-9], time10n, time10h, time25n, time25h
		if CE.alerts then
			for var,info in pairs(CE.alerts) do
				for _,key in ipairs(alert_keys) do
					-- add userdata variable for this alert key
					local v = info[key]
					if type(v) == "table" then
						-- prepend '_' for safety
						-- ex. "_boltwarntime2"
						local ud_key = "_"..var..key
						userdata[ud_key] = v
						userdata[ud_key.."_index"] = 1
					end
				end
			end
		end

		if CE.userdata then
			-- Copy defaults into userdata
			for k,v in pairs(CE.userdata) do
				if type(v) == "table" then
					-- Indexing for series
					userdata[k.."_index"] = 1
					if v.type == "series" then
						userdata[k] = v
					elseif v.type == "container" then
						userdata[k] = {}
					elseif v.type == "map" then
                        userdata[k] = addon:CopyTable(v)
                    else
                        userdata[k] = addon:CopyTable(v)
                    end
				else
					userdata[k] = v
				end
			end
		end
	end

	-- @ADD TO HANDLERS
	handlers.set = function(info)
		for k,v in pairs(info) do
			local flag = true
			if type(v) == "string" then
				-- Increment/Decrement support
				if find(v,"^INCR") then
					v = ReplaceTokens(v)
                    local delta = tonumber(match(v,"^INCR|(.+)"))
					if not delta then delta = 0 end
                    
                    userdata[k] = userdata[k] + delta
					flag = false
				elseif find(v,"^DECR") then
                    v = ReplaceTokens(v)
                    local delta = tonumber(match(v,"^DECR|(.+)"))
                    if not delta then delta = 0 end
                    
					userdata[k] = userdata[k] - delta
					flag = false
				else
					v = ReplaceTokens(v)
				end
			end
            
			if flag then
				--[===[@debug@
				debug("handlers.set","var: <%s> before: %s after: %s",k,userdata[k],v)
				--@end-debug@]===]
				if type(v) == "table" then
					-- Indexing for series
					userdata[k.."_index"] = 1
					if v.type == "series" then
						userdata[k] = v
					elseif v.type == "container" then
						userdata[k] = {}
					elseif v.type == "map" then
                        userdata[k] = {}
                    end
				else
					userdata[k] = v
				end
			end
            
            -- Counters update
            local numberVal = tonumber(userdata[k])
            if type(numberVal) == "number" then
                addon:CounterSetValue(k,numberVal)
            end
		end
		return true
	end

	local function wipe_container(k)
		wipeins[k] = nil
		wipe(userdata[k])
		--[===[@debug@
		debug("wipe_container","var: %s table values: %s",k,table.concat(userdata[k],", "))
		--@end-debug@]===]
	end

    local ARRAYS = {
        ["party"] = function()
            local tbl = {}
            
            for i=1,GetNumPartyMembers() do
                local unit = "party"..i
                tbl[#tbl+1] = UnitName(unit)
            end
            tbl[#tbl+1] = UnitName("player")
            
            return tbl
        end,
    }
    
	-- @ADD TO HANDLERS
	handlers.insert = function(info)
        local k,v = info[1],info[2]
		v = ReplaceTokens(v)
		local t = userdata[k]
		local arrayName = v:match("^\{(%w+)\}$")
        if arrayName then
            local array = ARRAYS[arrayName]()
            for array_key,array_value in ipairs(array) do
                t[#t+1] = array_value
            end
        else
            t[#t+1] = v
        end
		local ct = CE.userdata[k]
		if ct.wipein and not wipeins[k] then
			wipeins[k] = module:ScheduleTimer(wipe_container,ct.wipein,k)
		end
    
		--[===[@debug@
		debug("insert","var: %s value: %s table values: %s",k,v,table.concat(userdata[k],", "))
		--@end-debug@]===]

		return true
	end
    
    handlers.remove = function(info)
        local k,v = info[1],ReplaceTokens(info[2])
        local t = userdata[k]
        local index = 0
        for i,value in ipairs(t) do
            if v == value then
                index = i
                break
            end
        end
        if index ~= 0 then
            table.remove(t, index)
        end
        
        return true
    end

	-- @ADD TO HANDLERS
	handlers.wipe = function(info)
        wipe(userdata[info])
		--[===[@debug@
		debug("wipe","var: %s table values: %s",info,table.concat(userdata[info],", "))
		--@end-debug@]===]
		return true
	end
    
    
    -- MAPS
    handlers.map = function(info)
        local mapName,mapKey,value = info[1],info[2],info[3]
        mapKey = ReplaceTokens(mapKey)
        
        local flag = true
        if type(value) == "string" then
            -- Increment/Decrement support
            if find(value,"^INCR") then
                value = ReplaceTokens(value)
                local delta = tonumber(match(value,"^INCR|(.+)"))
                if not delta then delta = 0 end
                
                userdata[mapName][mapKey] = userdata[mapName][mapKey] + delta
                flag = false
            elseif find(value,"^DECR") then
                value = ReplaceTokens(value)
                local delta = tonumber(match(value,"^DECR|(.+)"))
                if not delta then delta = 0 end
                
                userdata[mapName][mapKey] = userdata[mapName][mapKey] - delta
                flag = false
            else
                value = ReplaceTokens(value)
            end
        end
        
        if flag then
            userdata[mapName][mapKey] = value
        end
        
        return true
    end
end

---------------------------------------------
-- ALERTS
---------------------------------------------

do
	local throttles = {}
	local counters = {}

	function module:ResetAlertData()
		wipe(throttles)
		wipe(counters)
	end

	local diff_to_key = {
		[1] = "time10n",
		[2] = "time25n",
		[3] = "time10h",
		[4] = "time25h",
	}
    
    local diff_to_dim_key = {
        [1] = "time10man",
		[2] = "time25man",
		[3] = "time10man",
		[4] = "time25man",
    }

	local function resolve_time(time,var,key)
		if type(time) == "table" then
			return next_series_value(time,"_"..var..key)
		elseif type(time) == "string" then
			return tonumber(ReplaceTokens(time))
		else
			return time
		end
	end

	local function resolve_text(text,var,key)
		if type(text) == "table" then
			return next_series_value(text,"_"..var..key)
		else
			return ReplaceTokens(text)
		end
	end

	getid = function(var,customtag)
		local tag = ReplaceTokens(customtag) or (ReplaceTokens(alerts[var]) and ReplaceTokens(alerts[var].tag) or "")
		return format("invoker/%s%s",var,tag == "" and tag or "/"..tag)
	end

	-- @ADD TO HANDLERS
	handlers.alert = function(info)
        local var = prefilter(info,"alert")
		if not var then return true end
        local stgs = pfl.Encounters[key][var]
		if addon:IsRoleEnabled(stgs.enabled) then
			local defn = alerts[var]

			-- Throttling
			if defn.throttle then
				-- Initialize to 0 if non-existant
				throttles[var] = throttles[var] or 0
				-- Check throttle
				local t = GetTime()
                defn.throttle = ReplaceTokens(defn.throttle);
                
				if throttles[var] + defn.throttle < t then
					throttles[var] = t
				else
					-- Failed throttle, exit out
					return true
				end
			end

			if defn.expect and not handlers.expect(defn.expect) then
				-- failed expect condition
				return true
			end

			local id = getid(var, type(info) == "table" and info.tag)
            local idToReplace = info.replace and getid(ReplaceTokens(info.replace)) or id
			local behavior = defn.behavior
			if behavior == "overwrite" then
				Alerts:QuashByPattern(id)
			elseif behavior == "singleton" then
				if Alerts:IsActive(id) then return true end
			end

			local text,time
			-- Check to use specified text
			if info.text then
				if type(info.text) == "number" then -- selecting a different text preset (such as text2, text3, etc.)
                    local key = "text"..info.text
                    local new_text = defn[key]
                    text = resolve_text(new_text,var,key)
                elseif type(info.text) == "string" then -- selecting the text specified as a parameter
                    text = info.text
                end
			end
			-- Replace text if it is still nil
			if not text then text = resolve_text(defn.text,var,"text") end

            local warningtext
            if info.warningtext then
                local key = "warningtext"..info.warningtext
                local new_text = defn[key]
                warningtext = resolve_text(new_text, var, key)
            end
            
            if not warningtext then warningtext = resolve_text(defn.warningtext, var, "warningtext") end
            if find(var,"interruptwarn$") and addon:PlayerCanInterrupt() then
                text = text .. " - INTERRUPT!"
            end
            
			-- Time precedence
			-- 1. specified
			-- 2. difficulty
			-- 3. default

            -- Check to use specified time
            if info.time then
				local key = "time"..info.time
				local new_time = defn[key]
				time = resolve_time(new_time,var,key)
			end

			-- Check for difficulty time
			if not time then
				local diff = addon:GetRaidDifficulty()
				local key = diff_to_key[diff]
				local new_time = defn[key]
				time = new_time and resolve_time(new_time,var,key)
			end
            
            -- Check for raid dimension time
            if not time then
                local diff = addon:GetRaidDifficulty()
				local key = diff_to_dim_key[diff]
				local new_time = defn[key]
				time = new_time and resolve_time(new_time,var,key)
            end

			-- Replace time if it still nil
			if not time then
				time = resolve_time(defn.time,var,"time")
			end

			local flashtime = stgs.flashtime or defn.flashtime

			-- counters
			if stgs.counter then
				local c = counters[var] or 0
				c = c + 1
                text = format("%s (%d)",text,c)
				counters[var] = c
			end
            
            -- Handling the announceText
            if info.announcetext then
                text = {
                    text = text,
                    announceText = info.announcetext,
                }
            elseif defn.announcetext then
                text = {
                    text = text,
                    announceText = ReplaceTokens(defn.announcetext)
                }
            end

            -- Fill direction
            --local defaultFillDirection = addon.Alerts.db.profile.BarFillDirection
            local fillDirection = defn.fillDirection
            --[[
            if defaultFillDirection == "FILL" then
                fillDirection = defn.fillDirection or defaultFillDirection
            else
                fillDirection = defn.fillDirection and (defn.fillDirection == "DEPLETE" and "FILL" or "DEPLETE") or (defaultFillDirection == "FILL" and "FILL" or "DEPLETE")
            end]]
            
            -- Sticky
            local sticky
            if type(defn.sticky) == "boolean" then
                sticky = defn.sticky
            elseif type(defn.sticky) == "string" then
                sticky = ReplaceTokens(defn.sticky) == "true"
            else
                sticky = false
            end
            
            -- Icon
            local icon = ReplaceTokens(defn.icon) or ""
            if find(icon,"[&<>]") then icon = "" end
            
            -- Emphasize Warning
            local emphasizewarning
            if type(defn.emphasizewarning) == "string" then
                emphasizewarning = ReplaceTokens(defn.emphasizewarning)
                if emphasizewarning == "default" then
                    emphasizewarning = stgs.emphasizewarning or false
                else
                    emphasizewarning = emphasizewarning == "true"
                end
            else
                emphasizewarning = stgs.emphasizewarning or false
            end
            
            -- NPC
            local npc = {}
            if defn.type == "absorb" or defn.type == "inflict" then
                if defn.npcid then npc.id = ReplaceTokens(defn.npcid) end
                if defn.npcguid then npc.guid = ReplaceTokens(defn.npcguid) end
            end
            
			--[===[@debug@
            debug("Alerts","id: %s text: %s time: %s flashtime: %s sound: %s color1: %s color2: %s",var,text,time,defn.flashtime,stgs.sound,stgs.color1,stgs.color2)
			--@end-debug@]===]
			-- Sanity check
			if not time or time < 0 then return true end

            -- Check to use an exact time
            if info.timeexact then
                local timeData = {time = tonumber(ReplaceTokens(info.timeexact))}
                if info.timemax then
                    timeData.timemax = tonumber(ReplaceTokens(info.timemax))
                elseif defn.timemax then
                    timeData.timemax = defn.timemax
                else
                    timeData.timemax = time
                end
                time = timeData
            elseif defn.timemax then
                time = {time = time, timemax = defn.timemax}
            end
            
			-- Pass in appropriate arguments
			if defn.type == "dropdown" then
                Alerts:Dropdown(id,text,time,flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,icon,stgs.audiocd,warningtext,stgs.emphasizetimer,fillDirection,sticky,idToReplace)
			elseif defn.type == "centerpopup" then
                Alerts:CenterPopup(id,text,time,flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,icon,stgs.audiocd,warningtext,emphasizewarning,stgs.emphasizetimer,fillDirection,sticky,idToReplace)
            elseif defn.type == "simple" then
				Alerts:Simple(id,warningtext or text,time,stgs.sound,stgs.color1,stgs.flashscreen,icon, emphasizewarning, idToReplace)
			elseif defn.type == "absorb" or defn.type == "inflict" then
                Alerts:Absorb(defn.type, id,text,defn.textformat,time,flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,icon,
				              defn.values[tuple['7']],npc,nil,warningtext,emphasizewarning,stgs.emphasizetimer)
			elseif defn.type == "absorbheal" then
                Alerts:AbsorbHeal(id,text,time,flashtime,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,icon,
				              defn.values[tuple['7']],ReplaceTokens(defn.target),nil,stgs.emphasizetimer)
            end
		end
		return true
	end
    
    handlers.resetalertcounter = function(info)
        local var = prefilter(info,"alert")
		if not var then return true end
		counters[var] = 0
        return true
    end

	handlers.batchalert = function(info)
		for _,info in ipairs(info) do handlers.alert(info) end
		return true
	end

	handlers.quash = function(info)
		if type(info) == "table" then
            Alerts:QuashByPattern(getid(info[1],info[2]))
        else
            Alerts:QuashByPattern(getid(info))
        end
		--[===[@debug@
			debug("Alerts","QUASH: id: %s ",info)
			--@end-debug@]===]
		return true
	end

	handlers.batchquash = function(info)
		for _,var in ipairs(info) do handlers.quash(var) end
		return true
	end

	handlers.quashall = function(info)
        local exceptions
        if type(info) == "table" then
            exceptions = info
        end
        
		Alerts:QuashByPattern("^invoker", exceptions)
		return true
	end

    local ALLOWED_CATEGORIES = {
        alert = true,
        arrow = true
    }
    
    handlers.send = function(info)
        if type(info) == "table" then
            if ALLOWED_CATEGORIES[info[1]] then
                local target = ReplaceTokens(info[3])
                local var = ReplaceTokens(info[2])
                if target and type(target) == "string" and UnitExists(target) then
                    local args = {}
                    for i=4,#info do
                        args[i-3] = ReplaceTokens(info[i])
                    end
                    addon:SendWhisperComm(target,"RAT",info[1],var,unpack(args))
                end
            end
        end
        
        return true
    end
    
    handlers.broadcast = function(info)
        if type(info) == "table" then
            if info[1] == "alert" or info[1] == "arrow" then
                local var = ReplaceTokens(info[2])
                for i=3,#info do
                    info[i] = ReplaceTokens(info[i])
                end
                addon:SendRaidComm("RAT",info[1],var,select(3,unpack(info)))
            end
        end
        
        return true
    end
    
	handlers.settimeleft = function(info)
		local var,time = info[1],info[2]
		local id = getid(var,info.tag)
		if type(time) == "string" then
			time = tonumber(ReplaceTokens(time))
		end
		if not time or time < 0 then return true end
		Alerts:SetTimeleft(id,time)

		return true
	end
    
    handlers.settext = function(info)
        local var, text, announceText = info[1],info[2],info[3]
        local id = getid(var, info.tag)
        
        if not text then return true end
        
        Alerts:SetText(id,text,announceText)
        
        return true
    end
end

function addon:PlayerCanInterrupt()
    local class = UnitClass("player")
    if     class == "Death Knight" 
        or class == "Mage" 
        or class == "Paladin" 
        or class == "Rogue" 
        or class == "Shaman" 
        or class == "Warrior" then
            return true
    elseif class == "Druid" then
    elseif class == "Warlock" then
        local petID = tonumber((UnitGUID("pet")):sub(-12, -9), 16)
        if petID == 23540 then return true end
    elseif class == "Priest" then return false
    end
    return false
end

---------------------------------------------
-- SCHEDULING
---------------------------------------------

do
	local reg_timers = {}
	local alert_timers = {}

	function module:RemoveAllTimers()
		for name in pairs(reg_timers) do handlers.canceltimer(name) end
		for var in pairs(alert_timers) do handlers.cancelalert(var) end
		-- Just to be safe
		self:CancelAllTimers()
	end

	local function schedule(info,timers,firefunc,cancelfunc,schedulefunc,store_args)
        local id,time = ReplaceTokens(info[1]),info[2]
        handlers[cancelfunc](id)
		timers[id] = new()

		if type(time) == "string" then
			time = tonumber(ReplaceTokens(time))
		end

		if not time or time < 0 then return true end

		if store_args then
			local args = new()
			-- Only need the first 7 (up to spellID)
			args[1],args[2],args[3],args[4],args[5],args[6],args[7] =
			tuple['1'],tuple['2'],tuple['3'],tuple['4'],tuple['5'],tuple['6'],tuple['7']

			timers[id].args = args
		end

        local handle = module[schedulefunc](module,firefunc,time,id)
        timers[id].handle = handle
	end

	local function cancel(info,timers)
        if timers[info] then
			module:CancelTimer(timers[info].handle,true)
			if timers[info].args then
				timers[info].args = del(timers[info].args)
			end
			timers[info] = del(timers[info])
		end
	end

	function module:FireTimer(name)
		if not CE.timers then return end
        -- Don't wipe reg_timers[name], it could be rescheduled
		self:InvokeCommands(CE.timers[name],unpack(reg_timers[name].args))
	end
    

	-- @ADD TO HANDLERS
	handlers.scheduletimer = function(info)
        schedule(info,reg_timers,"FireTimer","canceltimer","ScheduleTimer",true)
		return true
	end
    
    handlers.repeattimer = function(info)
        schedule(info,reg_timers,"FireTimer","canceltimer","ScheduleRepeatingTimer",true)
		return true
	end    

	-- @ADD TO HANDLERS
	handlers.canceltimer = function(info)
        cancel(info,reg_timers)
		return true
	end

	function module:FireAlert(info)
        if alert_timers[info].args then
			SetTuple(unpack(alert_timers[info].args))
		end
        if type(info) == "string" then
            info = info:match("^(%w+)[#.+]?")
        elseif type(info) == "table" then
            info[1] = info[1]:match("^(%w+)[#.+]?")
        end
		handlers.alert(info)
	end

	-- @ADD TO HANDLERS
	handlers.schedulealert = function(info)
        schedule(info,alert_timers,"FireAlert","cancelalert","ScheduleTimer",true)
		return true
	end

	-- @ADD TO HANDLERS
	handlers.repeatalert = function(info)
		schedule(info,alert_timers,"FireAlert","cancelalert","ScheduleRepeatingTimer",false)
		return true
	end

	-- @ADD TO HANDLERS
	handlers.cancelalert = function(info)
		cancel(info,alert_timers)
		return true
	end
end

---------------------------------------------
-- BATCHES
---------------------------------------------
do
    handlers.forloop = function(info)
        local start = tonumber(ReplaceTokens(info[1][2]))
        local limit = tonumber(ReplaceTokens(info[1][3]))
        
        for i = start,limit do           
            handlers.set({[info[1][1]] = i}) -- update counter
            handlers.invoke({info[2]}) -- invoke the body
        end
        
        return true
    end
    
    handlers.run = function(info)
        local batch = batches[info]
        if batch then
            handlers.invoke(batch)
        end
        
        return true
    end
end

---------------------------------------------
-- ENGAGE TIMER
---------------------------------------------

do
	-- @ADD TO HANDLERS
	handlers.resettimer = function(info)
		addon:ResetTimer()
		return true
	end
end

---------------------------------------------
-- TRACING
---------------------------------------------

do
	-- @ADD TO HANDLERS
	handlers.tracing = function(info)
        addon:SetTracing(info)
		return true
	end

	handlers.unittracing = function(info)
        local unitGUIDs = {}
        
        if type(info) == "string" then
            local unitGUID = UnitGUID(info)
            if not unitGUID then return end
            unitGUIDs = {unitGUID}
            addon:SetTracing(unitGUIDs)
        else
            for k,v in ipairs(info) do
                local unitGUID = UnitGUID(v)
                if unitGUID then 
                    unitGUIDs[table.getn(unitGUIDs)+1] = unitGUID
                end
            end
        end
        
        addon:SetTracing(unitGUIDs)
        
		return true
	end
    
    handlers.temptracing = function(info)
        if type(info) == "string" then
            if string.find(info,"^#[%d]+#$") then
                info = ReplaceTokens(info)
            elseif string.find(info,"^&(.+)&$") then
                info = ReplaceTokens(info)
            end
            if string.find(info,"^<.+>$") then
                local container = string.match(info,"^<(.+)>$")
                addon:AddTempTracing(userdata[container])
            elseif string.match(info,"^0x.+$") then
                local container = {info}
                addon:AddTempTracing(container)
            elseif UnitExists(info) then
                local container = {info}
                addon:AddTempTracing(container)
            end
        else
            addon:AddTempTracing(info)
        end
		return true
    end
    
    handlers.closetemptracing = function()
        addon:CloseTempHW()
        return true
    end
end

---------------------------------------------
-- PHASE MARKERS
---------------------------------------------
do
    handlers.addphasemarker = function(info)
        local hwIndex = info[1]
        local markerIndex = info[2]
        local percentPos = info[3]
        local label = info[4]
        local description = info[5]
        addon:AddPhaseMarker(hwIndex, markerIndex, percentPos, label, description)
        return true
    end
    
    handlers.removephasemarker = function(info)
        local hwIndex = tonumber(ReplaceTokens(info[1]))
        local markerIndex = tonumber(ReplaceTokens(info[2]))
        addon:RemovePhaseMarker(hwIndex, markerIndex)
        return true
    end
    
    handlers.clearphasemarkers = function(info)
        local hwIndex = info[1]
        addon:ClearPhaseMarkers(hwIndex)
        return true
    end
    
    handlers.hidephasemarker = function(info)
        local hwIndex = tonumber(ReplaceTokens(info[1]))
        local markerIndex = tonumber(ReplaceTokens(info[2]))
        addon:HidePhaseMarker(hwIndex, markerIndex)
        return true
    end
    
    handlers.showphasemarker = function(info)
        local hwIndex = tonumber(ReplaceTokens(info[1]))
        local markerIndex = tonumber(ReplaceTokens(info[2]))
        addon:ShowPhaseMarker(hwIndex, markerIndex)
        return true
    end
end

---------------------------------------------
-- COUNTERS
---------------------------------------------
do
    handlers.counter = function(info)
        if not addon.CE.counters then return end
        
        if type(info) == "table" then
            for _,var in ipairs(info) do
                local counter = addon.CE.counters[var]
                addon:AddCounter(counter)
            end
        elseif type(info) == "string" then
            local counter = addon.CE.counters[info]
            addon:AddCounter(counter)
        end
        
        return true
    end
    
    handlers.removecounter = function(info)
        if type(info) == "table" then
            for _,var in ipairs(info) do
                addon:RemoveCounterr(var)
            end
        elseif type(info) == "string" then
            addon:RemoveCounter(info)
        end
        
        return true
    end
end

---------------------------------------------
-- SILENT DEFEAT
---------------------------------------------
do
    handlers.silentdefeat = function(info)
        if type(info) == "boolean" then
            if not CE.advanced then CE.advanced = {} end
            CE.advanced.silentDefeat = info
        end
        
        return true
    end
end

do
    handlers.triggerdefeat = function(info)
        if type(info) == "boolean" then
            if info then 
                addon:TriggerDefeat(true)
            end
        end
    end
    
    handlers.resettimer = function(info)
        addon:ResetTimer()
        return true
    end
end


---------------------------------------------
-- PROXIMITY CHECKING
---------------------------------------------

do
	local ProximityFuncs = addon:GetProximityFuncs()

	-- @ADD TO HANDLERS
	handlers.proximitycheck = function(info)
		local target,range = info[1],info[2]
		target = ReplaceTokens(target)
		return ProximityFuncs[range](target)
	end

	handlers.outproximitycheck = function(info)
		local target,range = info[1],info[2]
		target = ReplaceTokens(target)
		return not ProximityFuncs[range](target)
	end
    
    handlers.range = function(info)
        local show = info[1]
        local range = info[2]
        local disableDistanceCheck = info[3]
        
        addon:SetProximityVisible(show,range,disableDistanceCheck)
        
        return true
    end
    
    handlers.radar = function(info)
        if pfl.Windows.Proxtype ~= "RADAR" then return true end
        
        local var
        local inrange
        if type(info) == "string" then
            var = info
        else
            var = info[1]
            inrange = tostring(ReplaceTokens(info[2])) == "true"
        end
        
        local data = CE.radars[var]
        if data then
            local stgs = pfl.Encounters[key].radars[var] -- status / color
            if stgs == "0-Off" then return true end
            if data.type == "circle" then
                local mode = {
                    type = ReplaceTokens(data.mode),
                    count = data.count
                }
                local range = tonumber(ReplaceTokens(data.range))
                local manualcheck = data.rangecheck == "manual"
                local persist = ReplaceTokens(data.persist)
                local color = (stgs ~= "1-Default") and addon.Alerts:GetColor(stgs) or addon.db.profile.Proximity.RadarCircleColorSafe
                
                if data.player then
                    local player = ReplaceTokens(data.player)

                    if not data.fixed then                 
                        addon:RadarAddCircleOnPlayer(var, mode, player, range, manualcheck, inrange, persist, color)
                    else
                        local x,y = GetPlayerMapPosition(player)
                        if x == 0 and y == 0 then
                            SetMapToCurrentZone()
                            x,y = GetPlayerMapPosition(player)
                        end
                        addon:RadarAddCircleAtPosition(var, mode, x, y, range, manualcheck, inrange, persist, color)
                    end
                elseif data.x and data.y then
                    local x = ReplaceTokens(data.x)
                    local y = ReplaceTokens(data.y)
                    
                    addon:RadarAddCircleAtPosition(var, mode, x, y, range, manualcheck, inrange, persist, color)
                end
            end
        end
        
        return true
    end
    
    handlers.removeradar = function(info)
        if pfl.Windows.Proxtype ~= "RADAR" then return true end
        
        if type(info) == "table" then
            local key = ReplaceTokens(info[1])
            if info.atplayer then
                local player = ReplaceTokens(info.atplayer)
                local range = info.range and ReplaceTokens(info.range) or nil
                addon:RadarRemoveFixedCircleByPlayer(key, player, range)
            elseif info.player then
                local player = ReplaceTokens(info.player)
                addon:RadarRemoveCircleFromPlayer(key, player)
            else
                addon:RadarRemoveCircleByKey(key)
            end
        elseif type(info) == "string" then
            local key = ReplaceTokens(info)
            addon:RadarRemoveCircleByKey(key)
        end
        
        return true
    end
    
    handlers.radarsetinrange = function(info)
        if pfl.Windows.Proxtype ~= "RADAR" then return true end

        if type(info) == "table" then
            local key = info[1]
            local inrange = tostring(ReplaceTokens(info[3])) == "true"
            if type(info[2]) == "string" then
                local player = ReplaceTokens(info[2])
                addon:RadarSetPlayerInRange(key, player, inrange)
            elseif type(info[2]) == "table" then
                local x,y = ReplaceTokens(info[2][1]), ReplaceTokens(info[2][2])
                addon:RadarSetLocationInRange(key, x, y, inrange)
            end
        end
        
        return true
    end
    
    handlers.radarcirclerange = function(info)
        if pfl.Windows.Proxtype ~= "RADAR" then return true end
        
        if type(info) == "table" then
            local key = ReplaceTokens(info[1])
            local range = tonumber(ReplaceTokens(info[2]))
            addon:RadarSetRange(key, range)
        end
        
        return true
    end
end

---------------------------------------------
-- ARROWS
---------------------------------------------

do
	-- @ADD TO HANDLERS
	handlers.arrow = function(info)
		local var = prefilter(info,"arrow")
		if not var then return true end

		local stgs = pfl.Encounters[key][var]
        if addon:IsRoleEnabled(stgs.enabled) then
			local defn = arrows[var]
			local unit = ReplaceTokens(defn.unit)
            local spell = ReplaceTokens(defn.spell)
            if UnitExists(unit) then
                SetMapToCurrentZone() -- just to make sure
				Arrows:AddTarget(unit,defn.persist,defn.action,defn.msg,spell,stgs.sound,defn.fixed,defn.xpos,defn.ypos,defn.range1,defn.range2,defn.range3,defn.cancelrange,defn.rangeStay)
			end
		end
		return true
	end

	-- @ADD TO HANDLERS
	handlers.removearrow = function(info)
		info = ReplaceTokens(info)
		Arrows:RemoveTarget(info)
		return true
	end

	-- @ADD TO HANDLERS
	handlers.removeallarrows = function(info)
		Arrows:RemoveAll()
		return true
	end
end

---------------------------------------------
-- RAID ICONS
---------------------------------------------

do
	--[[
		 0 = no icon
		 1 = Yellow 4-point Star
		 2 = Orange Circle
		 3 = Purple Diamond
		 4 = Green Triangle
		 5 = White Crescent Moon
		 6 = Blue Square
		 7 = Red "X" Cross
		 8 = White Skull
	]]

	local function is_guid(str)
		return type(str) == "string" and #str == 18 and str:find("%xx%x+")
	end

	-- @ADD TO HANDLERS
	handlers.raidicon = function(info)
		local var = prefilter(info,"raidicon")
		if not var then return true end
        
        if addon:IsGroup() and not addon:ShouldMark(var) then return true end -- Announce gets throttled (somebody else is taking care of that)
        
		local stgs = pfl.Encounters[key][var]
        local partyLeaderBypass = addon.RaidIcons.AllowPartyLeaderBypass()
        
		if (addon:IsPromoted() or (partyLeaderBypass and not addon:IsRaid())) and addon:IsRoleEnabled(stgs.enabled) then 
			local defn = raidicons[var]
            local unit = ReplaceTokens(defn.unit)
            
            local arrayName = unit:match("^\{([%w_]+)\}$")
            local units = arrayName and userdata[arrayName] or {unit}
            
            for _,unit in ipairs(units) do
                if UnitExists(unit) then
                    if defn.type == "FRIENDLY" then
                        RaidIcons:MarkFriendly(unit,stgs,defn.persist)
                    elseif defn.type == "MULTIFRIENDLY" then
                        RaidIcons:MultiMarkFriendly(var,unit,stgs,defn.persist,defn.reset,defn.total)
                    end
                elseif is_guid(unit) then
                    if defn.type == "ENEMY" then
                        RaidIcons:MarkEnemy(unit,stgs,defn.persist,defn.remove)
                    elseif defn.type == "MULTIENEMY" then
                        RaidIcons:MultiMarkEnemy(var,unit,stgs,defn.persist,defn.remove,defn.reset,defn.total)
                    end
                elseif tonumber(unit) ~= nil then
                    if defn.type == "ENEMY" then
                        RaidIcons:MarkEnemy(unit,stgs,defn.persist,defn.remove)
                    elseif defn.type == "MULTIENEMY" then
                        RaidIcons:MultiMarkEnemy(var,unit,stgs,defn.persist,defn.remove,defn.reset,defn.total)
                    end
                end
            end
		end
		return true
	end

	-- @ADD TO HANDLERS
	handlers.removeraidicon = function(info)
		local unit = ReplaceTokens(info)
		if UnitExists(unit) then
			RaidIcons:RemoveIcon(unit)
		end
		return true
	end
end

---------------------------------------------
-- TARGET
---------------------------------------------

do

	--[[
	Target function
	How this will work:
	"target",{
		source = "#1#", -- this is mandatory
		wait = <time>, -- in seconds e.g. 0.2
		raidicon = <raidicon>,
		announce = <announce>,
		arrow = <arrow>,
		alerts = {
			self = <alert>,
			other = <alert>,
			unknown = <alert>,
		}
	}
	]]

	--Here goes actual functions (stolen from DBM and BigWigs, thanks)
	local info

	local function fire(unit)
        if UnitExists(unit) then
			upvalue = UnitName(unit)
			if info.raidicon then
				handlers.raidicon(info.raidicon)
			end
			if info.arrow then
				handlers.arrow(info.arrow)
			end
			if UnitIsUnit(unit,"player") then
				if info.announce then
					handlers.announce(info.announce)
				end
				if info.alerts and info.alerts.self then
					handlers.alert(info.alerts.self)
				end
			else
				if info.alerts and info.alerts.other then
					handlers.alert(info.alerts.other)
				end
			end
		end
	end

	local function checkt(sGUID)
		local t = nil
		local function buildTable()
			t = {
				"boss1", "boss2", "boss3", "boss4",
				"target", "targettarget",
				"focus", "focustarget",
				"mouseover", "mouseovertarget",
				"party1target", "party2target", "party3target", "party4target"
			}
			for i = 1, 25 do t[#t+1] = string.format("raid%dtarget", i) end
		end
		if not t then
			buildTable()
		end

		local targetname = nil
		for i, unit in next, t do
			if UnitGUID(unit) == sGUID then
				targetname = UnitName(unit.."target")
				break
			end
		end

		if targetname then
			fire(targetname)
		elseif not targetname then
			if info.alerts and info.alerts.unknown then
				handlers.alert(info.alerts.unknown)
			end
		end
	end

	handlers.target = function(_info)
		info = _info
		local sguid = ReplaceTokens(info.source)
		if info.wait then
			module:ScheduleTimer(checkt,info.wait,sguid)
		else
			return true
		end
		return true
	end
end

--[[
do
	-- "target",{
	--		unit = <unit>			  -- OPTIONAL
	--		npcid = <npcid>,		  -- OPTIONAL
	-- 	raidicon = <raidicon>, -- fired when target exists
	--		announce = <announce>, -- fired when target is self 	  	-- condition: target exists
	--		arrow = <arrow>, 		  -- fired when target exists
	--		alerts = {
	--			self = <alert>,     -- fired when target is self 		-- condition: target exists
	--			other = <alert>,    -- fired when target is not self 	-- condition: target exists
	--			unknown = <alert>,  -- fired when target doesn't exist
	--		},
	-- }

	-- If a rogue is targeted by Defile and then vanishes then Lich King will recast
	-- it on a different person

	-- Scenario 1
	-- 1. npc triggers SPELL_CAST_START or SPELL_CAST_SUCCESS and srcFlags indicate that the npc is target or focus
	-- 2. Register for UNIT_TARGET. The following could happen:
	-- 	a. UNIT_TARGET is triggered for the boss within 0.3s so fire everything and teardown.
	--				OR
	--		b. UNIT_TARGET is not triggered within 0.3s because the npc did not change targets or focus/target was
	--			lost on the npc (unlikely to happen). If the npc is still a valid unit then fire everything for its
	--			target. Otherwise, scan	raidNtarget for the npc and fire everything for raidNtargettarget.

	-- Scenario 2
	-- 1. npc triggers SPELL_CAST_START or SPELL_CAST_SUCCESS and the npc is not a valid unit
	-- 2. Store npc's current target's guid. If there is no current target then fire info.alerts.unknown if it exists and stop execution.
	-- 3. Schedule a repeating timer every 0.05s	for a target change. Schedule a fail-safe for 0.3s later.
	-- 4. When a target changed is detected then fire everything.

	-- tuple['3'] is srcFlags
	-- Only call from a SPELL_CAST_START or SPELL_CAST_SUCCESS

	local FAILSAFE_TIME = 0.3
	local TRY_REPEAT_TIME = 0.05
	local MAX_TRIES = 6
	local OBJECT_TARGET = COMBATLOG_OBJECT_TARGET
	local OBJECT_FOCUS  = COMBATLOG_OBJECT_FOCUS
	local ut_unit			-- Assigned focus/target for UNIT_TARGET
	local info				-- Cached info
	local last_guid		-- GUID to check against for a target switch
	local tries				-- How many times a poll has been done to check for a target swich
	local try_handle		-- Handle for polling
	local cancel_handle	-- Handle for failsafe

	local function fire(unit)
		--[===[@debug@
		debug("target.fire","unit: %s UnitName: %s",unit,UnitName(unit or ""))
		--@end-debug@]===]
		if UnitExists(unit) then
			upvalue = UnitName(unit)
			if info.raidicon then
				handlers.raidicon(info.raidicon)
			end
			if info.arrow then
				handlers.arrow(info.arrow)
			end
			if UnitIsUnit(unit,"player") then
				if info.announce then
					handlers.announce(info.announce)
				end
				if info.alerts and info.alerts.self then
					handlers.alert(info.alerts.self)
				end
			else
				if info.alerts and info.alerts.other then
					handlers.alert(info.alerts.other)
				end
			end
		else
			if info.alerts and info.alerts.unknown then
				handlers.alert(info.alerts.unknown)
			end
		end
	end

	function module:UNIT_TARGET(_,unit)
		if unit == ut_unit then
			local npcid = NID[UnitGUID(unit)]
			--[===[@debug@
			debug("target.UNIT_TARGET","unit: %s npcid: %s",unit,npcid)
			--@end-debug@]===]
			if info.npcid == npcid then
				fire(targetof[unit])
				self:TeardownTarget()
			end
		end
	end

	local function scan(npcid)
		--[===[@debug@
		debug("target.scan","Invoked")
		--@end-debug@]===]
		for _,unit in pairs(unit_to_unittarget) do
				if	 UnitExists(unit)
				and NID[UnitGUID(unit)] == npcid
				and UnitExists(targetof[unit]) then
				return targetof[unit]
			end
		end
	end

	local function try()
		tries = tries + 1
		local unit = scan(info.npcid)
		local cancel

		--[===[@debug@
		debug("target.try","tries: %s UnitName: %s",tries,UnitName(unit or ""))
		--@end-debug@]===]

		-- target changed
		if unit and UnitGUID(unit) ~= last_guid then
			fire(unit)
			cancel = true
		end

		if cancel then
			module:TeardownTarget()
		elseif tries == MAX_TRIES then
			-- failsafe fire on current target
			fire(unit or "")
			module:TeardownTarget()
		end
	end

	local function failsafe()
		--[===[@debug@
		debug("target.failsafe","Invoked")
		--@end-debug@]===]
		fire(targetof[ut_unit])
		cancel_handle = nil
		module:TeardownTarget()
	end

	function module:TeardownTarget()
		if try_handle then
			self:CancelTimer(try_handle)
			try_handle = nil
		end
		if cancel_handle then
			self:CancelTimer(cancel_handle)
			cancel_handle = nil
		end
		self:UnregisterEvent("UNIT_TARGET")
		--[===[@debug@
		debug("target.TeardownTarget","Invoked")
		--@end-debug@]===]
	end

	-- @ADD TO HANDLERS
	handlers.target = function(_info)
		info = _info
		module:TeardownTarget()
		if info.unit then
			module:RegisterEvent("UNIT_TARGET")
			ut_unit = info.unit
			cancel_handle = module:ScheduleTimer(failsafe,FAILSAFE_TIME)
			--[===[@debug@
			debug("target.bossunit","UnitName: %s",UnitName(targetof[info.unit]))
			--@end-debug@]===]
		elseif band(tuple['3'],OBJECT_TARGET) == OBJECT_TARGET then
			module:RegisterEvent("UNIT_TARGET")
			ut_unit = "target"
			cancel_handle = module:ScheduleTimer(failsafe,FAILSAFE_TIME)
			--[===[@debug@
			debug("target.OBJECT_TARGET","UnitName: %s",UnitName("targettarget"))
			--@end-debug@]===]
		elseif band(tuple['3'],OBJECT_FOCUS) == OBJECT_FOCUS then
			module:RegisterEvent("UNIT_TARGET")
			ut_unit = "focus"
			cancel_handle = module:ScheduleTimer(failsafe,FAILSAFE_TIME)
			--[===[@debug@
			debug("target.OBJECT_FOCUS","UnitName: %s",UnitName("focustarget"))
			--@end-debug@]===]
		else
			local unit = scan(info.npcid)
			if unit then last_guid = UnitGUID(unit)
			else last_guid = nil end
			try_handle = module:ScheduleRepeatingTimer(try,TRY_REPEAT_TIME)
			tries = 0
			--[===[@debug@
			debug("target.StartPolling","UnitName: %s last_guid: %s",UnitName(unit or ""),last_guid)
			--@end-debug@]===]
		end
		return true
	end
end]]

---------------------------------------------
-- THROTTLING ANNOUNCES
---------------------------------------------
local throttleData = {
}

local THROTTLING_REQUEST_PATTERN = "^request;(%w+);(%x+)$"
local THROTTLING_REQUEST_FORMAT = "request;%s;%s"

local THROTTLING_PROVIDE_PATTERN = "^provide;(%w+);(%x+);([%w_%-]+);([%w_%-]+)$"
local THROTTLING_PROVIDE_FORMAT =  "provide;%s;%s;%s;%s"


local THROTTLE_MODE = {
    BY_MODULE = 1, -- Automatically throttled only when the module specifies so and has then not been disabled in settings
    AUTO = 2, -- Automatically throttled but module or settings can disable it
}
local THROTTLE_PROFILES = {
    announces = THROTTLE_MODE.BY_MODULE,
    raidicons = THROTTLE_MODE.AUTO,
    misc = THROTTLE_MODE.BY_MODULE,
}

local function GetThrottledNum(encounterData, throttleKey)
    if encounterData[throttleKey] then
        local count = 0
        
        for _,info in pairs(encounterData[throttleKey]) do
            if THROTTLE_PROFILES[throttleKey] == THROTTLE_MODE.BY_MODULE then
                if info.throttle then count = count + 1 end
            elseif THROTTLE_PROFILES[throttleKey] == THROTTLE_MODE.AUTO then
                count = count + 1
            end
        end
        
        return count
    else
        return 0
    end
end


local THROTTLE_DATA_PATH = {
    misc = {"args"}
}

local THROTTLE_IS_SYNCED = {
    misc = true,
}

local function GetThrottleData(encounterData, throttleKey)
    local data = encounterData[throttleKey]
    if not data then return nil end
    
    local path = THROTTLE_DATA_PATH[throttleKey]
    
    if path then
        for _,step in ipairs(path) do
            data = data[step]
        end
    end
    
    return data
end

local function GetThrottles(encounterData)
    local data = {}
    
    for throttleKey,_ in pairs(THROTTLE_PROFILES) do
        local throttleData = GetThrottleData(encounterData,throttleKey)
        if throttleData and type(throttleData) == "table" then -- Let's deal with type(throttleData) == "function" when we actually need to
            local syncCheck = THROTTLE_IS_SYNCED[throttleKey]
            
            if not data[throttleKey] then data[throttleKey] = {} end
            for k,v in pairs(throttleData) do
                if not syncCheck then
                    if THROTTLE_PROFILES[throttleKey] == THROTTLE_MODE.BY_MODULE then
                        if v.throttle == true then
                            data[throttleKey][k] = false
                        end
                    elseif THROTTLE_PROFILES[throttleKey] == THROTTLE_MODE.AUTO then
                        data[throttleKey][k] = false
                    end
                elseif v.sync then
                    data[throttleKey][k] = v.default
                end
            end
        end
    end
    
    return data
end

local function GetPlayerScore(name)
    local guid = 0xF0000000 - tonumber((UnitGUID(name)):sub(-7,-1), 16)
	local COEF_LEADER = 0xB0000000;
    local COEF_ASSIST = 0xA0000000;
    
    return guid + (addon:GetRaidRank(name) == 2 and COEF_LEADER or 0) + (addon:GetRaidRank(name) == 1 and COEF_ASSIST or 0)
end

local function InsertThrottleData(index, name, encounterData)
 
    if not throttleData[name] then   
        local data = {
            name = name,
            score = GetPlayerScore(name),
            responseKey = format("%x", math.floor(math.random()*1000000000)),
            willAnnounce = GetThrottles(encounterData),
        }
        
        throttleData[index] = data
        throttleData[name] = data
    else
        throttleData[name].score = GetPlayerScore(name)
    end
end

local function AutoSyncAllowed(isPulling)
    if not CE or CE.key == "default" then return false end
    
    if isPulling then return true end
    
    return CE.advanced and CE.advanced.autosyncoptions
end

-- Sets up throttleData table for throttling
function addon:ArrangeThrottling(CE, isPulling)
    if not AutoSyncAllowed(isPulling) then return end
    
    addon:WipeThrottlingData()
    if addon:IsRaid() then 
        for i=1, GetNumRaidMembers() do InsertThrottleData(i, UnitName("raid"..i), CE) end
    elseif addon:IsParty() then
        for i=1, GetNumPartyMembers() do InsertThrottleData(i, UnitName("party"..i), CE) end
        InsertThrottleData(GetNumPartyMembers() + 1, UnitName("player"), CE)
    end
    
    table.sort(throttleData, function(data1, data2) return data1.score > data2.score end)
        
    for i=1,#throttleData do
        for throttleKey,_ in pairs(THROTTLE_PROFILES) do
            local msg = format(THROTTLING_REQUEST_FORMAT,
                               throttleKey,throttleData[i].responseKey)
            self:SendCommMessage("DXE", msg, "WHISPER", throttleData[i].name)
        end
        
    end
end

function addon:WipeThrottlingData()
    throttleData = {}
end


function addon:IsThrottleRequestMatch(msg)
    return msg:match(THROTTLING_REQUEST_PATTERN)
end

function addon:IsThrottleProvideMatch(msg)
    return msg:match(THROTTLING_PROVIDE_PATTERN)
end

function addon:UpdateThrottlingData(sender, msg)
    
    local throttleKey,responseKey,varKey, announceStatus = msg:match(THROTTLING_PROVIDE_PATTERN)
    if throttleData[sender]
        and throttleData[sender].responseKey == responseKey then
        if throttleData[sender].willAnnounce[throttleKey] then
            if type(throttleData[sender].willAnnounce[throttleKey][varKey]) == "boolean" then
                throttleData[sender].willAnnounce[throttleKey][varKey] = announceStatus == "true"
            else
                throttleData[sender].willAnnounce[throttleKey][varKey] = announceStatus
            end
        end
    end
end

function addon:UpdateThrottlingScores()
    if not AutoSyncAllowed() then return end
    
    if addon:IsRaid() then 
        for i=1, GetNumRaidMembers() do InsertThrottleData(i, UnitName("raid"..i), CE) end
    elseif addon:IsParty() then
        for i=1, GetNumPartyMembers() do InsertThrottleData(i, UnitName("party"..i), CE) end
        InsertThrottleData(GetNumPartyMembers() + 1, UnitName("player"), CE)
    end
    
    table.sort(throttleData, function(data1, data2) return data1.score > data2.score end)
end

local requestKeys = {}

function addon:BroadcastThrottlingInfoUpdate(throttleKey, encounter, varKey)
    if not THROTTLE_PROFILES[throttleKey] then return end
    if not requestKeys then return end
    
    for recipient,key in pairs(requestKeys) do
        addon:SendAnnounceInfo(throttleKey, recipient, key, encounter, varKey)
    end
end

function addon:ProvideThrottleData(sender, msg, CE)
    local throttleKey,key = msg:match(THROTTLING_REQUEST_PATTERN)
    if not THROTTLE_PROFILES[throttleKey] then return end
    
    requestKeys[sender] = key
    if CE and CE[throttleKey] then
        local isSynced = THROTTLE_IS_SYNCED[throttleKey]
        local throttleData = GetThrottleData(CE, throttleKey)
        if throttleData and type(throttleData) == "table" then
            for varKey,v in pairs(throttleData) do
                local announce = false
                if isSynced then
                    if v.sync == true and v.throttle == true then
                        announce = true
                    end
                else
                    if THROTTLE_PROFILES[throttleKey] == THROTTLE_MODE.BY_MODULE then
                        if v.throttle == true then
                            announce = true
                        end
                    elseif THROTTLE_PROFILES[throttleKey] == THROTTLE_MODE.AUTO then
                        announce = true
                    end
                end
                
                if announce then addon:SendAnnounceInfo(throttleKey, sender, key, CE, varKey) end
            end
        end
    end
end

local THROTTLE_SETTINGS_PATH = {
    misc = {"misc"},
}

local function GetThrottleSettings(throttleKey, encounter, varKey)
    local stgs = pfl.Encounters[encounter.key]
    
    local settingsPath = THROTTLE_SETTINGS_PATH[throttleKey]
    if settingsPath then
        for _,step in ipairs(settingsPath) do
            stgs = stgs[step]
        end
    end
    
    return stgs[varKey]
end

function addon:SendAnnounceInfo(throttleKey, recipient, key, encounter, varKey)
    local stgs = GetThrottleSettings(throttleKey, encounter, varKey)
    local value
    if THROTTLE_IS_SYNCED[throttleKey] then
        value = stgs.value
    else
        value = (addon:IsRoleEnabled(stgs.enabled) and "true" or "false")
    end

    local msg = format(THROTTLING_PROVIDE_FORMAT,
                       throttleKey, key, varKey, value)    
    self:SendCommMessage("DXE", msg, "WHISPER", recipient)
end

local function ShouldInvokeThrottled(throttleKey,announceVar, referenceValue)
    if THROTTLE_IS_SYNCED[throttleKey] then
        local data = GetThrottleData(CE, throttleKey)
        if not data[announceVar].sync then
            return true
        end
    else
        if CE[throttleKey] and CE[throttleKey][announceVar] then
            if THROTTLE_PROFILES[throttleKey] == THROTTLE_MODE.BY_MODULE then
                if CE[throttleKey][announceVar].throttle ~= true 
                    or not pfl.Encounters[CE.key][announceVar].throttle then
                    return true
                end
            elseif THROTTLE_PROFILES[throttleKey] == THROTTLE_MODE.AUTO then
                if not pfl.Encounters[CE.key][announceVar].throttle
                    or CE[throttleKey][announceVar].throttle == false then
                    return true
                end
            end
        end
    end
    local player = UnitName("player")
    
    for _,data in ipairs(throttleData) do
        local throttledCategory = data.willAnnounce[throttleKey]
        if data.name == player then
            if data.willAnnounce[throttleKey] then 
                if type(throttledCategory[announceVar]) == "boolean" then
                    if throttledCategory[announceVar] then
                        return true
                    end
                else
                    if throttledCategory[announceVar] == referenceValue then
                        return true
                    end
                end
            end
        else
            if throttledCategory then 
                if type(throttledCategory[announceVar]) == "boolean" then
                    if throttledCategory[announceVar] then
                        return false
                    end
                else
                    if throttledCategory[announceVar] == referenceValue then
                        return false
                    end
                end
            end
        end
    end

    return false
end

addon.ValuePriorityPlayer = function(throttleKey, announceVar, referenceValue)
    for _,data in ipairs(throttleData) do
        local throttledCategory = data.willAnnounce[throttleKey]
        
        if data.willAnnounce[throttleKey] then 
            if type(throttledCategory[announceVar]) == "boolean" then
                if throttledCategory[announceVar] then
                    return data.name
                end
            else
                if throttledCategory[announceVar] == referenceValue then
                    return data.name
                end
            end
        end
    end
    
    return nil
end

addon.ValuePriority = function(var, key)
    return ShouldInvokeThrottled("misc", var, key)
end

function addon:ShouldAnnounce(announceVar)
    return ShouldInvokeThrottled("announces", announceVar)
end

function addon:ShouldMark(markVar)
    return ShouldInvokeThrottled("raidicons", markVar)
end

---------------------------------------------
-- ANNOUNCES
---------------------------------------------

do
	local SendChatMessage = SendChatMessage

	-- @ADD TO HANDLERS
	handlers.announce = function(info)
		local var = prefilter(info,"announce")
		if not var then return true end

		local stgs = pfl.Encounters[key][var]
		if addon:IsRoleEnabled(stgs.enabled) then
            local defn = announces[var]
            
            if defn.subtype == "achievement" and not pfl.Chat.AchievementAnnouncements then return true end
			if addon:IsGroup() and not addon:ShouldAnnounce(var) then return true end -- Announce gets throttled (somebody else is taking care of that)
            
			if defn.type == "SAY" then
				local msg = ReplaceTokens(defn.msg)
				SendChatMessage(msg,"SAY")
            elseif defn.type == "RAID" then
                local msg = ReplaceTokens(defn.msg)
                SendChatMessage(msg, "RAID")
            elseif defn.type == "PARTY" then
                local msg = ReplaceTokens(defn.msg)
                if addon:IsParty() then
                    SendChatMessage(msg, "PARTY")
                else
                    SendChatMessage(msg, "SAY")
                end
			elseif defn.type == "RAID_WARNING" then
                if addon:GetRaidRank() > 0 then
                    local msg = ReplaceTokens(defn.msg)
                    msg = string.gsub(msg,"|T[%a%d\\_%.]+:%d+[:%d]*|t[%s]?","") -- removing the textures
                    SendChatMessage(msg, "RAID_WARNING")
                end
            end
		end
		return true
	end
end

---------------------------------------------
-- INVOKING
---------------------------------------------

do
    local function serialize(info)
        if type(info) == "table" then
            local buffer = "{"
            
            for i,v in ipairs(info) do
                buffer = format("%s %s = %s (%s),",buffer, i, tostring(v), type(v))
            end
            
            local n = #info
            for k,v in pairs(info) do
                if (type(k) ~= "number") or (k > n) then
                    buffer = format("%s %s = %s (%s),",buffer, tostring(k), tostring(v), type(v))
                end
            end
            
            buffer = buffer.."}"
            return buffer
            
        else
            return format("%s (%s)", tostring(info), type(info))
        end
    end

	local flag = true

	-- @param bundle Command bundles
	-- @param ... arguments passed with the event
	function module:InvokeCommands(bundle,...)
        if flag then SetTuple(...) end
		if bundle == nil then
            return nil
        end
        for _,list in ipairs(bundle) do
			for i=1,#list,2 do
				local infotype,info = list[i],list[i+1]
				local handler = handlers[infotype]
				-- Make sure handler exists in case of an unsupported command
                if handler then
                    local status, err = pcall(handler,info)
                    if not status then
                        error(format("Invokation Error:\n         Boss = %s\n         Instance = %s\n         InfoType = %s\n         Info: %s\nCausing error:      %s",
                                      tostring(CE and CE.name),GetInstanceInfo(), infotype, serialize(info), err))
                    else
                        if not err then break end
                    end
                else
                    error(format("No Such Command Error:\n         Boss = %s\n         Instance = %s\n         InfoType = %s\n         Info: %s\nCausing error:      %s",
                                      tostring(CE and CE.name),GetInstanceInfo(), infotype, serialize(info), err))
                end
			end
		end
	end

	-- @ADD TO HANDLERS
	handlers.invoke = function(info)
		-- tuple has already been set
		flag = false; module:InvokeCommands(info); flag = true
		return true
	end
end

---------------------------------------------
-- EVENTS
---------------------------------------------

do
	local throttles = {}  -- bundle -> throttle time
	local times = {}      -- bundle -> last time

	local function main_event_handler(bundles,bundle_to_filter,attr_handles,...)
		if not bundles then return end
		for _,bundle in ipairs(bundles) do
			local skip = false
			if throttles[bundle] then
				times[bundle] = times[bundle] or 0
				local t = GetTime()
				if times[bundle] + throttles[bundle] < t then
					times[bundle] = t
				else
					skip = true
				end
			end
			if not skip then
				local filter = bundle_to_filter[bundle]
				local flag = true
				for attr,data in pairs(filter) do
					-- all conditions have to pass for the bundle to fire
					if not attr_handles[attr](data,...) then
						flag = false
						break
					end
				end
				if flag then
					module:InvokeCommands(bundle,...)
				end
			end
		end
	end

	local TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
	local TYPE_NPC = COMBATLOG_OBJECT_TYPE_NPC

	local combat_attr_handles = {
		spellid = function(hash,...)
			local spellid = select(7,...)
			return hash[spellid]
		end,

		spellid2 = function(hash,...)
			local spellid2 = select(10,...)
			return hash[spellid2]
		end,

		spellname = function(hash,...)
			local spellname = select(8,...)
			return hash[spellname]
		end,

		spellname2 = function(hash,...)
			local spellname2 = select(11,...)
			return hash[spellname2]
		end,

		srcnpcid = function(hash,...)
			local srcguid = ...
			return hash[NID[srcguid]]
		end,

		dstnpcid = function(hash,...)
			local dstguid = select(4,...)
			return hash[NID[dstguid]]
		end,

		srcisplayertype = function(bool,...)
			local _,_,srcflags = ...
			return (band(srcflags,TYPE_PLAYER) == TYPE_PLAYER) == bool
		end,

		srcisnpctype = function(bool,...)
			local _,_,srcflags = ...
			return (band(srcflags,TYPE_NPC) == TYPE_NPC) == bool
		end,

		srcisplayerunit = function(bool,...)
			local srcguid = ...
			return (srcguid == addon.PGUID) == bool
		end,

		dstisplayertype = function(bool,...)
			local dstflags = select(6,...)
			return (band(dstflags,TYPE_PLAYER) == TYPE_PLAYER) == bool
		end,

		dstisnpctype = function(bool,...)
			local dstflags = select(6,...)
			return (band(dstflags,TYPE_NPC) == TYPE_NPC) == bool
		end,

		dstisplayerunit = function(bool,...)
			local dstguid = select(4,...)
			return (dstguid == addon.PGUID) == bool
		end,
	}

	local combat_transforms = {
		spellname = function(spellid) return SN[spellid] end,
		spellname2 = function(spellid) return SN[spellid] end,
	}

	local weare42 = tonumber((select(4, GetBuildInfo()))) > 40100
	if weare42 then
		function module:COMBAT_EVENT(event,timestamp,eventtype,hideCaster,srcGUID, srcName, srcFlags, srcFlags2, dstGUID, dstName, dstFlags, dstFlags2, ...)
			main_event_handler(eventtype_to_bundle[eventtype],combatbundle_to_filter,combat_attr_handles, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
		end
	else
		function module:COMBAT_EVENT(event,timestamp,eventtype,hideCaster,...)
			main_event_handler(eventtype_to_bundle[eventtype],combatbundle_to_filter,combat_attr_handles,...)
		end
	end

	local REG_ALIASES = {
		YELL = "CHAT_MSG_MONSTER_YELL",
		EMOTE = "CHAT_MSG_RAID_BOSS_EMOTE",
		WHISPER = "CHAT_MSG_RAID_BOSS_WHISPER",
        BG_ALLY = "CHAT_MSG_BG_SYSTEM_ALLIANCE",
        BG_HORDE = "CHAT_MSG_BG_SYSTEM_HORDE",
        BG_NEUTRAL = "CHAT_MSG_BG_SYSTEM_NEUTRAL",
        SAY = "CHAT_MSG_MONSTER_SAY",
	}

	local reg_attr_handles = {
		msg = function(hash,...)
			local msg = ...
			for str in pairs(hash) do
				if find(msg,str) then
					return true
				end
			end
		end,

		spellname = function(hash,...)
			local _,spell = ...
			return hash[spell]
		end,

		npcname = function(hash,...)
			local _,npcname = ...
			return hash[npcname]
		end,
	}

	local reg_transforms = {
		spellname = function(spellid) return SN[spellid] end,
	}

	function module:REG_EVENT(event,...)
		main_event_handler(event_to_bundle[event],eventbundle_to_filter,reg_attr_handles,...)
	end

	local function to_hash(work,trans)
		if type(work) ~= "table" then
			if trans then work = trans(work) end
			return {[work] = true}
		else
			-- work is an array
			local t = {}
			for k,v in pairs(work) do
				if trans then v = trans(v) end
				t[v] = true
			end
			return t
		end
	end

	-- filter structure = {
	-- 	[attribute] = {
	-- 		[value] = true,
	--			...
	--			[valueN] = true,
	--		},
	--    .
	--    .
	--    .
	-- 	[attributeN] = {
	-- 		[value] = true,
	--			...
	--			[valueN] = true,
	--		},
	-- }


	local function create_filter(info,handles,transforms)
		local filter = {}
		for attr in pairs(handles) do
			if info[attr] then
				if type(info[attr]) == "boolean" then
					filter[attr] = info[attr]
				else
					filter[attr] = to_hash(info[attr],transforms[attr])
				end
			end
		end
		return filter
	end

    local function add_combat_event_data(eventtype, info)
        local t = eventtype_to_bundle[eventtype]
        if not t then
            t = {}
            eventtype_to_bundle[eventtype] = t
        end
        t[#t+1] = info.execute

        combatbundle_to_filter[info.execute] = create_filter(info,combat_attr_handles,combat_transforms)
    end
    
	function module:AddEventData()
		if not CE.events then return end
		-- Iterate over events table
		for _,info in ipairs(CE.events) do
			if info.type == "combatevent" then
				if type(info.eventtype) == "string" then
                    add_combat_event_data(info.eventtype, info)
                elseif type(info.eventtype) == "table" then
                    for _,eventtype in ipairs(info.eventtype) do
                        add_combat_event_data(eventtype, info)
                    end
                end
			elseif info.type == "event" then
				local event = REG_ALIASES[info.event] or info.event
				local t = event_to_bundle[event]
				if not t then
					t = {}
					event_to_bundle[event] = t
				end
				t[#t+1] = info.execute

				eventbundle_to_filter[info.execute] = create_filter(info,reg_attr_handles,reg_transforms)
			end
			if info.throttle then throttles[info.execute] = info.throttle end
		end
	end

	function module:WipeEvents()
		wipe(event_to_bundle)
		wipe(eventtype_to_bundle)
		wipe(combatbundle_to_filter)
		wipe(eventbundle_to_filter)
		wipe(throttles)
		wipe(times)
		self:UnregisterAllEvents()
	end
end


---------------------------------------------
-- TRACER ACQUIRES
---------------------------------------------
-- Holds command bundles
local AcquiredBundles = {}
local UnitIsDead = UnitIsDead

function module:HW_TRACER_ACQUIRED(_,unit,npcid)
	if AcquiredBundles[npcid] and not UnitIsDead(unit) then
		self:InvokeCommands(AcquiredBundles[npcid])
	end
end

-- Each entry in
function module:SetOnAcquired()
	wipe(AcquiredBundles)
	local onacquired = CE.onacquired
	if not onacquired then return end
	for npcid,bundle in pairs(onacquired) do
		AcquiredBundles[npcid] = bundle
	end
end

addon.RegisterCallback(module,"HW_TRACER_ACQUIRED")


---------------------------------------------
-- GUID FUNCTIONS
---------------------------------------------
function addon:GetHPByGUID(guid)
    if addon:IsRaid() then
        for i = 1, GetNumRaidMembers() do
            local unit = "raid"..i.."target"
            if UnitGUID(unit) == guid then
                local hp,hpmax = UnitHealth(unit),UnitHealthMax(unit)
                if hp and hpmax then
                    return hp / hpmax * 100
                else
                    return 0
                end 
            end
        end
    else
        local unit = "playertarget"
        if UnitGUID(unit) == guid then
            local hp,hpmax = UnitHealth(unit),UnitHealthMax(unit)
            if hp and hpmax then
                return hp / hpmax * 100
            else
                return 0
            end 
        end
        for i = 1, GetNumPartyMembers() do
            unit = "party"..i.."target"
            if UnitGUID(unit) == guid then
                local hp,hpmax = UnitHealth(unit),UnitHealthMax(unit)
                if hp and hpmax then
                    return hp / hpmax * 100
                else
                    return 0
                end 
            end
        end
    end
    
    return 200
end

function addon:AdjustUnit(unit)
    local name = UnitName(unit)
    local i = 1
    if unit == "boss" then
        while not name or name == "Unknown" do
            if i >= addon.BOSS_MAX then return 0 end
            unit = "boss"..i
            name = UnitName(unit)
            i = i + 1
        end
    end
    
    return unit
end

function addon:GetUnitByGUID(guid)
    for _,unit in pairs(unit_to_unittarget) do
        if UnitExists(unit) and UnitGUID(unit) == guid then
            return unit
        end
    end
    
    return nil
end

function addon:GetRaidTargetIndexByGUID(guid)
    local unit = addon:GetUnitByGUID(guid)
    
    return unit and GetRaidTargetIndex(unit) or nil
end

function addon:GetRaidTargetTextureByGUID(guid)
    local icon = addon:GetRaidTargetIndexByGUID(guid)
    if icon then
        return format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:24:24:0:5\124t",icon)
    else
        return ""
    end
end

local raidTargetIndexes = {
    [1] = "{star}",
    [2] = "{circle}",
    [3] = "{diamond}",
    [4] = "{triangle}",
    [5] = "{moon}",
    [6] = "{square}",
    [7] = "{cross}",
    [8] = "{skull}",
}

function addon:GetRaidTargetChatByGUID(guid)
    local iconIndex = addon:GetRaidTargetIndexByGUID(guid)
    
    if iconIndex then
        return raidTargetIndexes[iconIndex]
    else
        return ""
    end
end
    
-- MISC FUNCTIONS

do
    handlers.setcvar = function(info)
        local key = info[1]
        local value = info[2]
        
        if type(key) ~= "string" then return true end
        
        SetCVar(key, value)
        return true
    end
end
    
---------------------------------------------
-- PVP & BATTLEGROUNDS
---------------------------------------------
function module:OnBattlegroundStart(_,...)
    if not CE or CE.key == "default" then return end
	if next(eventtype_to_bundle) then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","COMBAT_EVENT")
	end
	for event in pairs(event_to_bundle) do
		self:RegisterEvent(event,"REG_EVENT")
	end
	-- Reset colors if not acquired
	--[[
    for i,hw in ipairs(HW) do
		if hw:IsOpen() and not hw.tracer:First() then
			hw:SetInfoBundle("",1,1)
			hw:ApplyNeutralColor()
		end
	end
    ]]
	if CE.onstart then
		self:InvokeCommands(CE.onstart,...)
	end
end

function module:OnBattlegroundStop(event)
    if event == "StopBattleground" then 
        module:ScheduleTimer("OnBattlegroundStop",1)
        return nil
    end
    if not CE then return end
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	for event in pairs(event_to_bundle) do
		self:UnregisterEvent(event)
	end
	self:ResetUserData()
	Alerts:QuashByPattern("^invoker")
	Arrows:RemoveAll()
	RaidIcons:RemoveAll()
	self:RemoveAllTimers()
	self:ResetAlertData()
end
    
---------------------------------------------
-- API
---------------------------------------------

function module:OnSet(_,data)
	--[===[@debug@
	assert(type(data) == "table","Expected 'data' table as argument #1 in OnSet. Got '"..tostring(data).."'")
	--@end-debug@]===]
	-- Set upvalues
	CE = data
	arrows = CE.arrows
	raidicons = CE.raidicons
	alerts = CE.alerts
    batches = CE.batches
	announces = CE.announces
	key = CE.key
	-- Wipe events
	self:WipeEvents()
	-- Register events
	self:AddEventData()
	-- Copy data.userdata to userdata upvalue
	self:ResetUserData()
	-- OnAcquired
	self:SetOnAcquired()
end

---------------------------------------------
-- USERDATA EXPORT API
---------------------------------------------
function addon:GetVar(var)
    return userdata[var]
end


