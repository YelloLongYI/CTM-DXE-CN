-- Auto Responder for whispers during encounters
-------------------------------------------------

local addon = DXE
local L = addon.L

local ipairs, pairs = ipairs, pairs
local remove,wipe = table.remove,table.wipe
local match,len,format,split,find = string.match,string.len,string.format,string.split,string.find
local GetTime = GetTime

local NID = addon.NID
local CE
local AR = {}
local MODS = {
    bigwigs = "^<BW>",
	dbm = "^<Deadly Boss Mods>",
	dbm2 = "^<DBM>",
	dxe = "^DXE Autoresponder",
    dxe2 = "^<DXE>",
} -- don't respond to addon whispers

local defaults = {
	profile = {
        enabled = true,
        details = true,
        announcewipe = true,
        announcedefeat = true,
        interval = 15,
        updatethrottle = true,
    },
}

----------------------------------
-- INITIALIZATION
----------------------------------

local module = addon:NewModule("AutoResponder","AceEvent-3.0")
addon.AutoResponder = module

local db,pfl

function module:RefreshProfile() pfl = db.profile end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("AutoResponder", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
    addon.RegisterCallback(self, "TriggerDefeat", "AnnounceDefeat")
    addon.RegisterCallback(self, "RaidWipe", "AnnounceWipe")
	addon.RegisterCallback(self,"SetActiveEncounter","Set")
end

function addon:GetRaidInfo()
    local diffData = select(3, GetInstanceInfo())
    local diff = not addon:IsHeroic() and "Normal" or "Heroic"
    local dim = select(5, GetInstanceInfo())
    
    return dim, diff
end

function module:AnnounceDefeat(_, CE)    
    if not pfl.enabled or not pfl.announcedefeat then return end
  
    local encounter = CE["name"]
    local dim,diff = addon:GetRaidInfo()
    local difficulty = format("%s-Player %s", dim, diff)
    local msg = format("<DXE> %s has defeated %s (%s).", UnitName("player"), encounter, difficulty) 
  
    for sender,_ in pairs(AR.throttle) do
        SendChatMessage(msg, "WHISPER", nil, sender)
    end
  
    AR.throttle = {}
end

function module:AnnounceWipe(_, CE)
    if not pfl.enabled or not pfl.announcedefeat then return end
  
    local encounter = CE["name"]
    local dim,diff = addon:GetRaidInfo()
    local difficulty = format("%s-Player %s", dim, diff)
    local msg = format("<DXE> %s has wiped on %s (%s).", UnitName("player"), encounter, difficulty) 
  
    for sender,_ in pairs(AR.throttle) do
        SendChatMessage(msg, "WHISPER", nil, sender)
    end
  
    AR.throttle = {}
end

---------------------------------------------
-- Chat Frame Filter
---------------------------------------------

local filterSetup = false
local filterActive = false
function addon:AutoResponder_whisperfilter(activate)
    
	local function BOSS_MOD_FILTER(self,event,msg,sender,...)
        if type(msg) == "string" then
            if filterActive then
                for _,fragment in ipairs(addon.RaidStatus.RAID_STATUS_REQUESTS) do
                    if event == "CHAT_MSG_WHISPER" then
                        if find(msg, fragment) then return true end
                    end
                end
                for k,v in pairs(MODS) do
                    if find(msg,v) then
                        if event == "CHAT_MSG_WHISPER" and sender == UnitName("player") then
                            return false,msg,sender,...
                        else
                            return true
                        end
                    end
                end
                return false,msg,sender,...
            else
                return false,msg,sender,...
            end
		end
	end
    if not filterSetup then
        filterSetup = true
        ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", BOSS_MOD_FILTER)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", BOSS_MOD_FILTER)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", BOSS_MOD_FILTER)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", BOSS_MOD_FILTER)
    end
    
    filterActive = activate
end

---------------------------------------------
-- Encounter Load/Start/Stop
---------------------------------------------
function module:Set(_,data)
	if pfl.enabled then
		addon.RegisterCallback(self,"StartEncounter","Start")
		addon.RegisterCallback(self,"StopEncounter","Stop")
        addon.RegisterCallback(self,"StartBattleground","Start")
        addon.RegisterCallback(self,"StopBattleground","Stop")
		if AR then wipe(AR) end
		CE = data
		AR.boss = CE.name
		AR.msg = format(L["<DXE> Currently fighting %s. Send \"dxestatus\" for details."],AR.boss)
		AR.throttle = {} -- who whispered us
	end
end

function module:Start(_,...)
	self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER")
    addon:AutoResponder_whisperfilter(true)
end

function module:Stop()
	self:UnregisterEvent("CHAT_MSG_WHISPER")
	self:UnregisterEvent("CHAT_MSG_BN_WHISPER")
    addon:ScheduleTimer("AutoResponder_whisperfilter", 1, false)
end

---------------------------------------------
-- Responder
---------------------------------------------
do
    local function helper()
        local elapsed = addon.Pane.timer.left:GetText()
		local alive = 0
        local total = 0
		local percent = "n.a."
        local found = false
        local dim,diff = addon:GetRaidInfo()
		local difficulty = format("%s-Player %s", dim, diff)
    
        if string.find(elapsed,"%d+:%d+") then
            local time = string.match(elapsed, "(%d+):%d+")
            elapsed = format("%s minute%s",time, (tonumber(time)>1) and "s" or "")    
        else
            elapsed = format("%s second%s", elapsed, tonumber(elapsed)>1 and "s" or "")
        end

        local curZone = select(1,GetInstanceInfo())
		
        if GetNumRaidMembers() > 0 then
            for i = 1, GetNumRaidMembers() do
                local name = select(1, GetRaidRosterInfo(i))
                local zone,online,dead = select(7,GetRaidRosterInfo(i))
                alive = alive + ((not UnitIsDeadOrGhost("raid"..i) and curZone == zone and online) and 1 or 0)
                total = total + ((not UnitIsDeadOrGhost("raid"..i) and curZone ~= zone) and 0 or 1)
            end
        elseif GetNumPartyMembers() > 0 then
            for i = 0, GetNumPartyMembers() do
                local unit = i == 0 and "player" or "party"..i
                local x,y = GetPlayerMapPosition(unit)
                local online = UnitIsConnected(unit)
                if online and x and y and x ~= 0 and y ~= 0 then
                    total = total + 1
                    if not UnitIsDeadOrGhost(unit) then
                        alive = alive + 1
                    end
                end
            end
        else
            total = 1
            alive = not UnitIsDeadOrGhost("player") and 1 or 0
        end


        for i=1, MAX_BOSS_FRAMES do
            if UnitExists("boss"..i) then
                local hp,hpmax = UnitHealth("boss"..i),UnitHealthMax("boss"..i)
                percent = string.format("%0.0f", hp/hpmax * 100)
                return elapsed,alive,total,percent,difficulty
            end
        end
        
        return elapsed,alive,totla,0,difficulty
        
	end

	local function send(recip, msg, realid)
		if realid then
			BNSendWhisper(recip, msg)
		else
			SendChatMessage(msg, "WHISPER", nil, recip)
		end
	end

    local function IsGroupMember(sender)
        if (UnitInRaid(sender) or UnitInParty(sender)) and UnitAffectingCombat(sender) then
            return true
        else
            return false
        end
    end
    
    
	function module:responder(msg, sender, realid)
        for k,v in pairs(MODS) do
			if find(msg,v) then return true end
		end
        if IsGroupMember(sender) then return true end

        local isRaidStatus = false
        for _,RequestFragment in ipairs(addon.RaidStatus.RAID_STATUS_REQUESTS) do
            if find(msg, RequestFragment) then
                isRaidStatus = true
                break
            end
        end
        
        if addon:IsModuleEvent(addon.CE.key) or addon:IsModuleTrash(addon.CE.key) then return true end
        
        if not AR.throttle[sender] then
            AR.throttle[sender] = {
                time = 0,
                raidStatusInfo = false,
            }
		end
		if GetTime() > AR.throttle[sender].time + pfl.interval then
			if addon:IsModuleBattleground(addon.CE.key) then
                if UnitAffectingCombat("player") then
                    local status = format(L["<DXE> %s is busy fighting in %s. They will get back to you later."],UnitName("player"), addon.CE.name)
                    send(sender, status, realid)
                end
            else
                local dur,alive,total,percent,diff = helper()
                local status = format(L["<DXE> %s is busy fighting %s (%s)"],UnitName("player"), AR.boss, diff or "Unknown")
                details = pfl.details and format(L[" - %s%% || %s elapsed (%s/%s people alive)."], percent, dur, alive, total) or "."
                AR.status = status..details

                send(sender, AR.status, realid)
                AR.throttle[sender].time = GetTime()
                if not AR.throttle[sender].raidStatusInfo then
                    if not isRaidStatus and addon.RaidStatus:IsEnabled() then
                        AR.throttle[sender].raidStatusInfo = true
                        send(sender, format("<DXE> For information about instance bosses' status, whisper phrase 'dxes' or 'dxestatus'."), realid)
                    end
                end
            end
        else
            if pfl.updatethrottle then AR.throttle[sender].time = GetTime() end
		end
	end
end

---------------------------------------------
-- Events
---------------------------------------------
do
	function module:CHAT_MSG_WHISPER(_, msg, sender)
		self:responder(msg, sender, false)
	end

	function module:CHAT_MSG_BN_WHISPER(_, msg, ...)
		local realid = select(12, ...)
		self:responder(msg, realid, true)
	end
end


