-- Raid Status is extending the functions of AutoResponder
-----------------------------------------------------------
local addon = DXE
local L = addon.L

local ipairs, pairs = ipairs, pairs
local remove,wipe = table.remove,table.wipe
local match,len,format,split,find = string.match,string.len,string.format,string.split,string.find
local GetTime = GetTime

local NID = addon.NID
local CE

local throttle = {}

local MODS = {
    bigwigs = "^<BW>",
	dbm = "^<Deadly Boss Mods>",
	dbm2 = "^<DBM>",
	dxe = "^DXE Autoresponder",
    dxe2 = "^<DXE>",
} -- don't respond to addon whispers
local modFilter = false

local defaults = {
	profile = {
        enabled = true,
        interval = 30,
        filterPhrases = true,
        spamCap = 8, -- maximum number of messages until the spam filter is triggered
    }
}

local RAID_STATUS_REQUESTS = {"^dxes$","^dxestatus$"}

----------------------------------
-- INITIALIZATION
----------------------------------

local module = addon:NewModule("RaidStatus","AceEvent-3.0")
addon.RaidStatus = module

local db,pfl
module.RAID_STATUS_REQUESTS = RAID_STATUS_REQUESTS

function module:RefreshProfile() pfl = db.profile end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("RaidStatus", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
    
    addon.RegisterCallback(self, "TriggerDefeat",  "HandleEvent")
    addon.RegisterCallback(self, "StartEncounter", "HandleEvent")
    addon.RegisterCallback(self, "RaidWipe",  "HandleEvent")
    
    self:RegisterEvent("CHAT_MSG_WHISPER")
    
    -- RDF lockout
    self:RegisterEvent("LFG_PROPOSAL_SHOW")
    
    -- Regular lockout
    self:RegisterEvent("INSTANCE_LOCK_START")
    self:RegisterEvent("INSTANCE_LOCK_WARNING")
    self:RegisterEvent("CHAT_MSG_SYSTEM")
    addon.RegisterCallback(self, "OnRegisterEncounter", "ACCEPT_LOCK_LATE")
    
    self:whisperfilter()
end

function module:IsEnabled()
    return pfl.enabled
end

local CR = select(4,CalendarGetDate())
local MONTH_DAYS ={  
   [1] = 31,
   [2] = CR%4==0 and (CR%100==0 and (CR%400==0 and 29 or 28) or 29) or 28,
   [3] = 31,
   [4] = 30,
   [5] = 31,
   [6] = 30,
   [7] = 31,
   [8] = 31,
   [9] = 30,
   [10] = 31,
   [11] = 30,
   [12] = 31,
}
local encounterGroups = {}

---------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------

-- Creates a date table for given arguments
---------------------------------------------
local function newDate(hour,minute,dayOfTheWeek,day,month,year,deltaDays)
    day = day + (deltaDays or 0)
    if day > MONTH_DAYS[month] then
        day = day - MONTH_DAYS[month]
        month = month + 1
    end

    if month > 12 then
        month = month  - 12
        year = year + 1
    end

    return {
        hour = hour,
        minute = minute,
        dayOfTheWeek = dayOfTheWeek,
        day = day,
        month = month,
        year = year
    }  
end

-- Compares 2 dates
---------------------
-- Returns true if d is before d2, otherwise false
local function compareDates(d, d2)
   if d.year < d2.year then return true end
   if d.year == d2.year then
      if d.month < d2.month then return true end
      if d.month == d2.month then
         if d.day < d2.day then return true end
         if d.day == d2.day then
            if d.hour < d2.hour then return true end
            if d.hour == d2.hour then
               if d.minute < d2.minute then return true end
            end
         end
      end
   end
   
   return false
end


-- DAYS_TILL_RESET (lockout reset)
local DTR = setmetatable({},{
      __index = function(t,k)
         if type(k) ~= "number" then return "nil" end
         return 6-((k+2)%7)
      end,
})

local function GetResetDate(date,instanceType)
   if instanceType == "raid" then
      return newDate(
         5, 0,
         date.dayOfTheWeek, date.day, date.month, date.year,
         DTR[date.dayOfTheWeek]
      )
   else
      return newDate(
         5, 0,
         date.dayOfTheWeek, date.day, date.month, date.year,
         1
      )
   end
end

local function GetCurrentDate()
    local hour, minute = GetGameTime()
    local dayOfTheWeek, month, day, year = CalendarGetDate()
    return newDate(hour, minute, dayOfTheWeek, day, month, year)
end

-- Produces array from parameter array, leaving out all indexes less or equal to the limit
local function cut(arr,limit)
   local newArr ={} 
   for i,info in ipairs(arr) do
      if i>limit then
         newArr[i-limit] = info
      end
   end
   return newArr
end

-- Encounter status ID:
local ESID = {
    [0] = "{skull}", -- Boss is alive
    [1] = "{triangle}",  -- Encounter in progress
    [2] = "{cross}",  -- Boss has been defeated
}

local DIFFS = {
    [1] = "Normal",
    [2] = "Heroic",
}

local function CreateBlankReport(category)
    if not addon.ZONE_TO_CATEGORY[category] then return nil end
    local groupType = select(2,GetInstanceInfo())
    local report = {
        LockDate = nil,
        Encounters = {},
        instanceType = groupType,
    }

    for key,data in pairs(addon.EDB) do
        if category == data.zone or category == data.category then
            if not addon:IsModuleTrash(key) and not addon:IsModuleEvent(key) then
                if data.groupkey and encounterGroups[data.groupkey] then
                    local groupData = encounterGroups[data.groupkey]
                    report["Encounters"][data.groupkey] = {}
                    if groupData.total or groupData.labels then
                        for i=1,groupData.total or #groupData.labels do
                            report["Encounters"][data.groupkey][i] = {
                                key = nil,
                                status = 0,
                                difficulty = nil,
                            }
                        end
                    else
                        report["Encounters"][data.groupkey]["key"] = nil
                        report["Encounters"][data.groupkey]["status"] = 0
                        report["Encounters"][data.groupkey]["difficulty"] = nil
                    end
                else
                    report["Encounters"][key] = {}
                    report["Encounters"][key]["status"] = 0
                    report["Encounters"][key]["difficulty"] = nil
                end
            end
        end
    end
    local name = UnitName("player")
    pfl["ReportData"][name][category] = report
    
    return report
end

local function RefreshReportData(category)
    if not addon.ZONE_TO_CATEGORY[category] then return nil end
    
    local name = UnitName("player")
    local report = pfl["ReportData"][name][category]
    
    for key,data in pairs(addon.EDB) do
        if category == data.zone or category == data.category then
            if not addon:IsModuleTrash(key) and not addon:IsModuleEvent(key) then
                if data.groupkey and encounterGroups[data.groupkey] then
                    if not report["Encounters"][data.groupkey] then
                        local groupData = encounterGroups[data.groupkey]
                        report["Encounters"][data.groupkey] = {}
                        if groupData.total or groupData.labels then
                            for i=1,groupData.total or #groupData.labels do
                                report["Encounters"][data.groupkey][i] = {
                                    key = nil,
                                    status = 0,
                                    difficulty = nil,
                                }
                            end
                        else
                            report["Encounters"][data.groupkey]["key"] = nil
                            report["Encounters"][data.groupkey]["status"] = 0
                            report["Encounters"][data.groupkey]["difficulty"] = nil
                        end
                    end
                else
                    if not report["Encounters"][key] then
                        report["Encounters"][key] = {}
                        report["Encounters"][key]["status"] = 0
                        report["Encounters"][key]["difficulty"] = nil
                    end
                end
            end
        end
    end
end

local function GetReportData(category)
    local name = UnitName("player")
    if not pfl["ReportData"] then pfl["ReportData"] = {} end
    if not pfl["ReportData"][name] then pfl["ReportData"][name] = {} end
    if not pfl["ReportData"][name][category] then
        CreateBlankReport(category)
    end

    RefreshReportData(category)
    
    return pfl["ReportData"][name][category]
end

local function HasLockoutExpired(category)
    local reportData = GetReportData(category)
    if reportData.LockDate then
        local resetDate = GetResetDate(reportData.LockDate, reportData.instanceType)
        local currentDate = GetCurrentDate()
        return compareDates(resetDate, currentDate)
    else
        return false
    end
end


local function GenerateReport(category)
    if HasLockoutExpired(category) then CreateBlankReport(category) end
    local reportData = GetReportData(category)
    if not reportData then return end
    
    local report = {}

    -- Generating raw report
    local maxOrder = 0
    for key,data in pairs(reportData.Encounters) do
        if encounterGroups[key] then
            local groupData = encounterGroups[key]
            if groupData.total then
                for i=1,groupData.total do
                    local name = data[i].key and addon.EDB[data[i].key].name or format("%s (%s)",groupData.name,i)
                    local msg = format("%s : %s%s", ESID[data[i].status], name, data[i].difficulty and format(" (%s)",DIFFS[data[i].difficulty]) or "")
                    local order = groupData.order + i - 1

                    if order > maxOrder then maxOrder = order end
                    report[order] = msg
                end
            elseif groupData.labels then
                for i=1,#groupData.labels do
                    local name = data[i].key and addon.EDB[data[i].key].name or groupData.labels[i]
                    local msg = format("%s : %s%s", ESID[data[i].status], name, data[i].difficulty and format(" (%s)",DIFFS[data[i].difficulty]) or "")
                    local order = groupData.order + i - 1

                    if order > maxOrder then maxOrder = order end
                    report[order] = msg
                end
            else
                local name = addon.EDB[data.key] and addon.EDB[data.key].name or groupData.name
                local order = groupData.order
                if type(data) == "table" then
                    report[order] = format("%s : %s%s", ESID[data.status], name, data.difficulty and format(" (%s)",DIFFS[data.difficulty]) or "")
                elseif type(data) == "number" then -- to deal with older profile data
                    report[order] = format("%s : %s", ESID[data], name)
                end
            end
        elseif addon.EDB[key] then
            local name = addon.EDB[key].name
            local order = addon.EDB[key].order
            if order > maxOrder then maxOrder = order end
            if type(data) == "table" then
                report[order] = format("%s : %s%s", ESID[data.status], name, data.difficulty and format(" (%s)",DIFFS[data.difficulty]) or "")
            elseif type(data) == "number" then -- to deal with older profile data
                report[order] = format("%s : %s", ESID[data], name)
            end
        end
    end
    
    -- Cleaning up the report
    local newIndex = 1
    local reportSorted = {}
    for i=1,maxOrder do
        local reportLine = report[i]
        if reportLine then
            reportSorted[newIndex] = reportLine
            newIndex = newIndex + 1
        end
    end
    report = reportSorted
    
    return report
end

local MSG_SPAM_TIMER = 11 -- spam filter cooldown

function addon:SendRaidStatusLate(data)
    local report, recipient = data.report, data.recipient
    local msgLimit = pfl.spamCap
    local msgSent = 0
    addon:EnableModuleChatFilter()
    for _,msg in ipairs(report) do
        if msgLimit > 0 then
            SendChatMessage(format("<DXE> %s",msg), "WHISPER", nil, recipient)
            msgLimit = msgLimit - 1
            msgSent = msgSent + 1
        else
            report = cut(report, pfl.spamCap)
            local data = {report = report, recipient = recipient}
            addon:ScheduleTimer("SendRaidStatusLate",MSG_SPAM_TIMER,data)
            msgLimit = -1
            break
        end
    end
    addon:ScheduleTimer("DisableModuleChatFilter",1)
end

local function SendRaidStatus(category, report, recipient)
    if not report or not recipient then return end
    addon:EnableModuleChatFilter()
    local msgLimit = pfl.spamCap
    local groupSize = select(5, GetInstanceInfo())
    local groupSizeLabel = groupSize ~= 0 and format(" (%s-Player)",groupSize) or ""
    local description = format("{circle}{square} %s%s {square}{circle}", category, groupSizeLabel)
    SendChatMessage(format("<DXE> %s",description), "WHISPER", nil, recipient)
    msgLimit = msgLimit - 1
    
    for _,msg in ipairs(report) do
        if msgLimit > 0 then
            SendChatMessage(format("<DXE> %s",msg), "WHISPER", nil, recipient)
            msgLimit = msgLimit - 1
        else
            report = cut(report, pfl.spamCap - 1)
            local data = {report = report, recipient = recipient}
            addon:ScheduleTimer("SendRaidStatusLate",MSG_SPAM_TIMER,data)
            msgLimit = -1
            break
        end
    end
    addon:ScheduleTimer("DisableModuleChatFilter",1)
end
--local reportData = GetReportData(category)
--reportData.Encounters
local function ChangeBossInRaidStatus(category, key, status, difficulty)
    if addon:IsModuleTrash(key) then return end
    local reportData = GetReportData(category)
    if not reportData then return end
    
    local encData = addon.EDB[key]
    if encData then
        if encData.groupkey and encounterGroups[encData.groupkey] then
            local groupData = encounterGroups[encData.groupkey]
            if groupData.total or groupData.labels then
                for i=1,groupData.total or #groupData.labels do
                    if reportData.Encounters[encData.groupkey][i]["status"] ~= 2 then
                        reportData.Encounters[encData.groupkey][i]["key"] = key
                        reportData.Encounters[encData.groupkey][i]["status"] = status
                        reportData.Encounters[encData.groupkey][i]["difficulty"] = difficulty
                        break
                    end
                end
            else
                if reportData.Encounters[encData.groupkey]["status"] ~= 2 then
                    reportData.Encounters[encData.groupkey]["key"] = key
                    reportData.Encounters[encData.groupkey]["status"] = status
                    reportData.Encounters[encData.groupkey]["difficulty"] = difficulty
                end
            end
        else
            if reportData.Encounters[key]["status"] ~= 2 then
                reportData.Encounters[key]["status"] = status
                reportData.Encounters[key]["difficulty"] = difficulty
            end
        end
    else
        for groupKey,groupData in pairs(encounterGroups) do
            if groupData.labels then
                for i,groupLabel in ipairs(groupData.labels) do
                    if groupLabel == key then
                        if reportData.Encounters[groupKey][i]["status"] ~= 2 then
                            reportData.Encounters[groupKey][i]["key"] = nil
                            reportData.Encounters[groupKey][i]["status"] = status
                            reportData.Encounters[groupKey][i]["difficulty"] = difficulty
                            break
                        end
                    end
                end
            else
                if groupData.name == key then
                    reportData.Encounters[groupKey]["key"] = nil
                    reportData.Encounters[groupKey]["status"] = status
                    reportData.Encounters[groupKey]["difficulty"] = difficulty
                end
            end
        end
    end
end

function addon:RegisterEncounterGroup(data)
    if not encounterGroups[data.key] then
        encounterGroups[data.key] = {
            name = data.name,
            labels = data.labels,
            zone = data.zone
        }
    end
    local minOrder = 100
    for key,encdata in pairs(addon.EDB) do
        if encdata.groupkey and encdata.groupkey == data.key then
            if minOrder > encdata.order then minOrder = encdata.order end
        end
        if not encounterGroups[data.key].category then
            encounterGroups[data.key].category = encdata.zone or encdata.category
        end
    end
    encounterGroups[data.key].order = minOrder
    module:ACCEPT_LOCK_LATE("REGISTER_ENCOUNTER_GROUP",encounterGroups[data.key])
end


---------------------------------------------
-- EVENT HANDLING
---------------------------------------------

function module:HandleEvent(event)
    if not addon.CE or addon.CE == "default" and not addon:IsModuleTrash(addon.CE.key) and not addon:IsModuleEvent(addon.CE.key) then return end
    if event == "TriggerDefeat" then 
        module:ACCEPT_LOCK()
        module:BossDefeat(addon.CE.category or addon.CE.zone, addon.CE.key)
    elseif event == "StartEncounter" then
        module:BossPull(addon.CE.category or addon.CE.zone, addon.CE.key)
    elseif event == "RaidWipe" then
        module:BossWipe(addon.CE.category or addon.CE.zone, addon.CE.key)
    end
    
end

function module:BossPull(category, key)
    local _, groupType, difficultyID = GetInstanceInfo()
    if groupType == "party" and difficultyID == 1 then return end -- Ignore 5-man normals
    if addon:IsModuleTrash(key) or addon:IsModuleEvent(key) then return end -- Ignore trash and events
    local difficultyIndex = addon:IsHeroic() and 2 or 1
    ChangeBossInRaidStatus(category, key, 1, difficultyIndex)
end

function module:BossDefeat(category, key, lockoutOffer)
    local _, groupType, difficultyID = GetInstanceInfo()
    if groupType == "party" and difficultyID == 1 then return end -- Ignore 5-man normals
    if addon:IsModuleTrash(key) or addon:IsModuleEvent(key) then return end -- Ignore trash and events
    
    if HasLockoutExpired(category) then CreateBlankReport(category) end
    local difficultyIndex
    if lockoutOffer and groupType ~= "party" and difficultyID ~= 2 then
        difficultyIndex = nil
    else
        difficultyIndex = addon:IsHeroic() and 2 or 1
    end
    ChangeBossInRaidStatus(category, key, 2, difficultyIndex)
    local reportData = GetReportData(category)
    if not reportData["LockDate"] then
        reportData["LockDate"] = GetCurrentDate()
    end
    
    if not reportData["instanceType"] then
        local instanceType = select(2,GetInstanceInfo())
        reportData["instanceType"] = instanceType
    end
end

function module:BossWipe(category, key)
    local _, groupType, difficultyID = GetInstanceInfo()
    if groupType == "party" and difficultyID == 1 then return end -- Ignore 5-man normals
    if addon:IsModuleTrash(key) or addon:IsModuleEvent(key) then return end -- Ignore trash and events
    
    local difficultyIndex = addon:IsHeroic() and 2 or 1
    ChangeBossInRaidStatus(category, key, 0, difficultyIndex)
end

---------------------------------------------
-- CHAT & WHISPERS HANDLING
---------------------------------------------
function addon:DisableModuleChatFilter()
    modFilter = false
end

function addon:EnableModuleChatFilter()
    modFilter = true
end

function module:CHAT_MSG_WHISPER(_, msg, sender)
    pfl.interval = 1
    if pfl.enabled then
        for _,RequestFragment in ipairs(RAID_STATUS_REQUESTS) do
            if find(msg, RequestFragment) then
                if throttle[sender] and (GetTime() <= throttle[sender] + pfl.interval) then return true end
                --local category = (UnitIsDeadOrGhost("player")) and (addon.CE.category or addon.CE.category) or GetRealZoneText()
                local categoryData = addon.ZONE_TO_CATEGORY[GetRealZoneText()]
                if categoryData then
                    local category = categoryData.category
                    
                    if UnitIsDeadOrGhost("player") then
                        category = addon.ZONE_TO_CATEGORY[addon.CE.category or addon.CE.category].category
                    end
                    
                    if category then
                        local _, groupType, difficultyID = GetInstanceInfo()
                        if groupType == "party" and difficultyID == 1 then 
                            addon:EnableModuleChatFilter()
                            SendChatMessage("<DXE> No Raid Status available for player's 5-man normal difficulty dungeon.", "WHISPER", nil, sender)
                            addon:ScheduleTimer("DisableModuleChatFilter",1)
                        else
                            local report = GenerateReport(category)
                            SendRaidStatus(category, report, sender)
                        end
                    else
                        addon:EnableModuleChatFilter()
                        SendChatMessage("<DXE> Player is not inside a known dungeon.", "WHISPER", nil, sender)
                        addon:ScheduleTimer("DisableModuleChatFilter",1)
                    end
                    throttle[sender] = GetTime()
                    return true
                else
                    addon:EnableModuleChatFilter()
                    SendChatMessage("<DXE> Player is not inside a known dungeon.", "WHISPER", nil, sender)
                    addon:ScheduleTimer("DisableModuleChatFilter",1)
                end
            end
        end   
    end
end


function module:whisperfilter()

	local function RAID_STATUS_FILTER(self,event,msg,sender, ...)
        if type(msg) == "string" then
            if pfl.enabled then
                if modFilter then
                    for k,v in pairs(MODS) do
                        if find(msg,v) then
                            if event == "CHAT_MSG_WHISPER" and sender == UnitName("player") then
                                return false, msg, sender, ...
                            else
                                return true
                            end
                        end
                    end
                end
            end
            if pfl.enabled or pfl.filterPhrases then
                for _,RequestFragment in ipairs(RAID_STATUS_REQUESTS) do
                    if find(msg, RequestFragment) then
                        if event == "CHAT_MSG_WHISPER_INFORM" then
                            return false, msg, sender, ...
                        else
                            return true
                        end
                    end
                end 
            end
		end
        
        return false, msg, sender, ...
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", RAID_STATUS_FILTER)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", RAID_STATUS_FILTER)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", RAID_STATUS_FILTER)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", RAID_STATUS_FILTER)
end

---------------------------------------------
-- KILLED BOSSES HANDLING
---------------------------------------------

local hasLFGproposal = false
local dungeonID = -1

local hasLockProposal = false
local lockoutData = {}
local lateLockoutData = {}
local function GetBossByName(idname)
    for key, data in pairs(addon.EDB) do
        if data.lfgname then
            if data.lfgname == idname then
                return data
            end
        else
            if data.name == idname then
                return data
            end
        end
    end
end

local function GetGroupByName(groupName)
    for key, data in pairs(encounterGroups) do
        if data.labels then
            for _,label in ipairs(data.labels) do
                if groupName == label then return {key = key, category = data.category} end
            end
        elseif data.name == groupName then
            return {key = key, category = data.category}
        end
    end
    
    return nil
end

-- RDF Lockout Retrival
function module:LFG_PROPOSAL_SHOW()
    hasLFGproposal = true
    dungeonID = LFGDungeonReadyPopup.dungeonID
    local dungeonName = select(5, GetLFGProposal())
    local bossN = GetLFGDungeonNumEncounters(dungeonID)
    
    -- Preparing received lockout data
    lockoutData = {}
    for encIndex=1,bossN do
        local bossName, _, isKilled = GetLFGDungeonEncounterInfo(dungeonID, encIndex)
        if isKilled then
            local bossData = GetBossByName(bossName)
            lockoutData[bossData.key] = isKilled
        end
        
    end
end

-- Regular Lockout Retrival
function module:INSTANCE_LOCK_START(...)
    module:LOCK_PROPOSAL(...)
end

function module:CHAT_MSG_SYSTEM(...)
    module:LOCK_PROPOSAL(...)
end

function module:INSTANCE_LOCK_WARNING(...)
    module:LOCK_PROPOSAL(...)
end


local function InsertBossLockout(bossName)
    local bossData = GetBossByName(bossName)
    local groupData = GetGroupByName(bossName)
    if bossData then
        lockoutData[bossData.key] = bossData.category or bossData.zone
    elseif groupData then
        lockoutData[bossName] = groupData.category or groupData.zone
    else
        lateLockoutData[bossName] = true
    end
end

function module:LOCK_PROPOSAL(event, ...)
    if event == "INSTANCE_LOCK_START" or event == "INSTANCE_LOCK_WARNING" or event == "ADDON_LOADING" then -- Lockout offer
        local lockTime, _, bossN, bossDead = GetInstanceLockTimeRemaining()
        if bossN > 0 then
            hasLockProposal = true
            lockoutData = {}
            
            for i=1,bossN do
                local bossName, _, isKilled = GetInstanceLockTimeRemainingEncounter(i)
                if isKilled then
                    InsertBossLockout(bossName)
                end
            end
        end
    elseif event == "CHAT_MSG_SYSTEM" then -- Lockout accepted
        local msg = select(1, ...)
        local lockTime, _, bossN, bossDead = GetInstanceLockTimeRemaining()
        if not hasLockProposal then return end
        if find(msg,"You are now saved to this instance") then
            module:ACCEPT_LOCK()
        end 
    end
end

-- If DXE just loaded we need to check weather the instance lock is ticking
module:LOCK_PROPOSAL("ADDON_LOADING")

function module:ACCEPT_LOCK()
    if not hasLockProposal then return end
    
    hasLockProposal = false
    for key,category in pairs(lockoutData) do
        module:BossDefeat(category, key, true)
    end
    lockoutData = {}
end

-- Transfers temporary boss names from lateLockoutData table to boss keys in lockoutData table
-- because in the moment of lockout offer the DXE module for instance hasn't been loaded yet
function module:ACCEPT_LOCK_LATE(event, data)
    for bossName,_ in pairs(lateLockoutData) do
        if event == "REGISTER_ENCOUNTER_GROUP" then
            if data.name then
                if bossName == data.name then
                    lockoutData[bossName] = data.category or data.zone
                    lateLockoutData[bossName] = nil
                end
            elseif data.labels then
                for _,label in ipairs(data.labels) do
                    if bossName == label then
                        lockoutData[bossName] = data.category or data.zone
                        lateLockoutData[bossName] = nil
                    end
                end
            end
        elseif event == "OnRegisterEncounter" then
            if data.groupkey then
                local groupData = encounterGroups[data.groupkey]
                if groupData then
                    if groupData.labels then
                        for _,label in ipairs(groupData.labels) do
                            if label == bossName then
                                lockoutData[data.groupkey] = data.category or data.zone
                                break
                            end
                        end
                    else
                        if groupData.name == bossName then
                            lockoutData[data.groupkey] = data.category or data.zone
                            break
                        end
                    end
                end
            else
                local name = data.lfgname or data.name
                if bossName == name then
                    lockoutData[data.key] = data.category or data.zone
                    lateLockoutData[bossName] = nil
                    break
                end
            end
        end
    end
end

function addon:ID()
    
end


