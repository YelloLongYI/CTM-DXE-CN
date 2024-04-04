local addon = DXE
local format,find = string.format,string.find
local OF = addon.originalfunctions

local defaults = {
	profile = {
        VictoryAnnouncementEnabled = true,
        VictoryScreenshot = false,
		HideVictoryFrameOnLeaving = true,
        AutoRelease = true,
        
        -- Faction Swapping
        FactionMode = "ACTUAL",
        HomeTeamLocation = "LEFT",
        FactionSwap = {
            WorldMapPOIs = true,
            Minimap = true,
            BattlegroundChat = true,
            BattlefieldScore = true,
        },
	}
}

local L = addon.L

local db,pfl,gbl

local GetInstanceInfo = GetInstanceInfo

local BATTLEGROUNDS = {}

---------------------------------------
-- INITIALIZATION
---------------------------------------

local module = addon:NewModule("PvP Core","AceTimer-3.0","AceEvent-3.0")
addon.PvP = module
addon.PvP.defaults = defaults

function module:RefreshProfile()
	pfl = db.profile
end

local AddChatFilter, OnWorldStateScoreShow, OnWorldStateScoreFrame_Update

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("PvP_Core", defaults)
	db = self.db
	pfl = db.profile
    gbl = db.global
    
	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    self:RegisterEvent("PLAYER_DEAD")
    hooksecurefunc(WorldStateScoreFrame,"Show",OnWorldStateScoreShow)
    hooksecurefunc("WorldStateScoreFrame_Update",OnWorldStateScoreFrame_Update)   
    AddChatFilter()
end

---------------------------------------
-- FACTIONS
---------------------------------------
local Faction = {}
addon.Faction = Faction

do 
    function Faction:GetMode()
        return pfl.FactionMode
    end

    function Faction:GetHomeTeamLocation()
        return pfl.HomeTeamLocation
    end

    function Faction:Of(unit)
        local finalFaction
        if (unit == "player") or UnitIsUnit(unit,"player") then
            if not not UnitBuff("player","Alliance") then
                finalFaction = "alliance"
            elseif not not UnitBuff("player","Horde") then
                finalFaction = "horde"
            else
                local faction = UnitFactionGroup(unit)
                finalFaction = faction and faction:lower()
            end
        else
            local faction = UnitFactionGroup(unit)
            finalFaction = faction and faction:lower()
        end
        return finalFaction
    end

    local SwapFaction = {
        ["alliance"] = "horde",
        ["horde"] = "alliance",
        ["Alliance"] = "Horde",
        ["Horde"] = "Alliance",
        [0] = 1, -- Horde to Alliance
        [1] = 0, -- Alliance to Horde
    }

    Faction.Map = {
        alliance = {
            color = "67c1ed",
            capital = "Alliance",
        },
        horde = {
            color = "ff0000",
            capital = "Horde",
        },
    }

    Faction.List = {"alliance","horde"}

    function Faction:Swap(faction)
        return SwapFaction[faction]
    end

    function Faction:Adjust(data)
        if type(data) == "function" then data = data() end
        local shouldSwitch = Faction:ShouldSwitchSides()    
        local dataType = type(data)
        
        if dataType == "table" then
            -- Setting up Faction slots
            if data.alliance and data.horde then
                data[1] = shouldSwitch and data.horde or data.alliance
                data[2] = shouldSwitch and data.alliance or data.horde
            end
        elseif dataType == "string" or dataType == "number" then
            if Faction:Swap(data) then
                data = shouldSwitch and Faction:Swap(data) or data
            end
        end

        return data

    end

    function Faction:GetPreferred()
        local FactionMode = Faction:GetMode()
        local actualFaction = UnitFactionGroup("player"):lower()
        
        if FactionMode == "ALLIANCE" then
            return "alliance"
        elseif FactionMode == "HORDE" then
            return "horde"
        elseif FactionMode == "CURRENT" then
            if not not UnitBuff("player","Alliance") then
                return "alliance"
            elseif not not UnitBuff("player","Horde") then
                return "horde"
            else
                return actualFaction
            end
        elseif FactionMode == "ACTUAL" then
            return actualFaction
        end
    end
    
    function Faction:IsAllianceHome()
        local isAllianceHome = Faction:GetPreferred() == "alliance"
        local isHomeLeft = Faction:GetHomeTeamLocation() == "LEFT"
        
        return isAllianceHome == isHomeLeft
    end

    local LandMarkFactionMap = {
        [2] = 3,     -- Mine (Horde)                          =>  Mine (Alliance)
        [3] = 2,     -- Mine (Alliance)                       =>  Mine (Horde)
        [9] = 12,    -- City (Alliance assaulted)             =>  City (Horde assaulted)
        [12] = 9,    -- City (Horde assaulted)                =>  City (Alliance assaulted)
        [11] = 10,   -- City (Alliance controlled)            =>  City (Horde controlled)
        [10] = 11,   -- City (Horde controlled)               =>  City (Alliance controlled)
        [4] = 14,    -- Graveyard (Alliance assaulted)        =>  Graveyard (Horde assaulted)
        [14] = 4,    -- Graveyard (Horde assaulted)           =>  Graveyard (Alliance assaulted)
        [15] = 13,   -- Graveyard (Alliance)                  =>  Graveyard (Horde)
        [13] = 15,   -- Graveyard (Horde)                     =>  Graveyard (Alliance)
        [17] = 19,   -- Gold Mine (Alliance assaulted)        =>  Gold Mine (Horde assaulted)
        [19] = 17,   -- Gold Mine (Horde assaulted)           =>  Gold Mine (Alliance assaulted)
        [18] = 20,   -- Gold Mine (Alliance)                  =>  Gold Mine (Horde)
        [20] = 18,   -- Gold Mine (Horde)                     =>  Gold Mine (Alliance)
        [22] = 24,   -- Lumber Mill (Alliance assaulted)      =>  Lumber Mill (Horde assaulted)
        [24] = 22,   -- Lumber Mill (Horde assaulted)         =>  Lumber Mill (Alliance assaulted)
        [23] = 25,   -- Lumber Mill (Alliance)                =>  Lumber Mill (Horde)
        [25] = 23,   -- Lumber Mill (Horde)                   =>  Lumber Mill (Alliance)
        [27] = 29,   -- Blacksmith (Alliance assaulted)       =>  Blacksmith (Horde assaulted)
        [29] = 27,   -- Blacksmith (Horde assaulted)          =>  Blacksmith (Alliance assaulted)
        [28] = 30,   -- Blacksmith (Alliance)                 =>  Blacksmith (Horde)
        [30] = 28,   -- Blacksmith (Horde)                    =>  Blacksmith (Alliance)
        [32] = 34,   -- Farm (Alliance assaulted)             =>  Farm (Horde assaulted)
        [34] = 32,   -- Farm (Horde assaulted)                =>  Farm (Alliance assaulted)
        [33] = 35,   -- Farm (Alliance)                       =>  Farm (Horde)
        [35] = 33,   -- Farm (Horde)                          =>  Farm (Alliance)
        [37] = 39,   -- Stables (Alliance assaulted)          =>  Stables (Horde assaulted)
        [39] = 37,   -- Stables (Horde assaulted)             =>  Stables (Alliance assaulted)
        [38] = 40,   -- Stables (Alliance)                    =>  Stables (Horde)
        [40] = 38,   -- Stables (Horde)                       =>  Stables (Alliance)
        [43] = 44,   -- Alliance flag                         =>  Horde flag
        [44] = 43,   -- Horde flag                            =>  Alliance flag
        [50] = 52,   -- Tower (Alliance damaged)              =>  Tower (Horde damaged)
        [52] = 50,   -- Tower (Horde damaged)                 =>  Tower (Alliance damaged)
        [51] = 53,   -- Tower (Alliance destroyed)            =>  Tower (Horde destroyed)
        [53] = 51,   -- Tower (Horde destroyed)               =>  Tower (Alliance destroyed)
        [71] = 68,   -- Workshop (Alliance)                   =>  Workshop (Horde)
        [68] = 71,   -- Workshop (Horde)                      =>  Workshop (Alliance)
        [72] = 69,   -- Workshop (Alliance damaged)           =>  Workshop (Horde damaged)    
        [69] = 72,   -- Workshop (Horde damaged)              =>  Workshop (Alliance damaged)
        [73] = 70,   -- Workshop (Alliance destroyed)         =>  Workshop (Horde destroyed)
        [70] = 73,   -- Workshop (Horde destroyed)            =>  Workshop (Alliance destroyed)
        [80] = 77,   -- Gate (Alliance)                       =>  Gate (Horde)
        [77] = 80,   -- Gate (Horde)                          =>  Gate (Alliance)    
        [81] = 78,   -- Gate (Alliance damaged)               =>  Gate (Horde damaged)
        [78] = 81,   -- Gate (Horde damaged)                  =>  Gate (Alliance damaged)
        [82] = 79,   -- Gate (Alliance destroyed)             =>  Gate (Horde destroyed)
        [79] = 82,   -- Gate (Horde destroyed)                =>  Gate (Alliance destroyed)    
        [136] = 138, -- Siege Workshop (Alliance)             =>  Siege Workshop (Horde)
        [138] = 136, -- Siege Workshop (Horde)                =>  Siege Workshop (Alliance)
        [137] = 139, -- Siege Workshop (Alliance assaulted)   =>  Siege Workshop (Horde assaulted)
        [139] = 137, -- Siege Workshop (Horde assaulted)      =>  Siege Workshop (Alliance assaulted)
        [141] = 143, -- Hangar (Alliance)                     =>  Hangar (Horde)
        [143] = 141, -- Hangar (Horde)                        =>  Hangar (Alliance)
        [142] = 144, -- Hangar (Alliance assaulted)           =>  Hangar (Horde assaulted)
        [144] = 142, -- Hangar (Horde assaulted)              =>  Hangar (Alliance assaulted)
        [146] = 148, -- Docks (Alliance)                      =>  Docks (Horde)
        [148] = 146, -- Docks (Horde)                         =>  Docks (Alliance)
        [147] = 149, -- Docks (Alliance assaulted)            =>  Docks (Horde assaulted)
        [149] = 147, -- Docks (Horde assaulted)               =>  Docks (Alliance assaulted)
        [151] = 153, -- Rafinery (Alliance)                   =>  Rafinery (Horde)
        [153] = 151, -- Rafinery (Horde)                      =>  Rafinery (Alliance)
        [152] = 154, -- Rafinery (Alliance assaulted)         =>  Rafinery (Horde assaulted)
        [154] = 152, -- Rafinery (Horde assaulted)            =>  Rafinery (Alliance assaulted)
    }

    function Faction:ShouldSwitchSides()
        return Faction:Of("player") ~= Faction:GetPreferred()
    end

    OF.GetNumMapLandmarks = GetNumMapLandmarks
    GetNumMapLandmarks = function()
        local instance,instanceType = GetInstanceInfo()
        if instanceType == "pvp" and instance == "Alterac Valley" and OF.GetNumMapLandmarks() == 22 then
            local towerFound = false
            for i=1,OF.GetNumMapLandmarks() do
                local name = GetMapLandmarkInfo(i)
                if name == "East Frostwolf Tower" then
                    towerFound = true
                    break
                end
            end
            return towerFound and OF.GetNumMapLandmarks() or 23
        end
        
        return OF.GetNumMapLandmarks()
    end

    OF.GetMapLandmarkInfo = GetMapLandmarkInfo
    
    GetMapLandmarkInfo = function(index)
        local name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID = OF.GetMapLandmarkInfo(index)
        
        local instance,instanceType = GetInstanceInfo()
        -- Fixing disappearing POI in Alterac Valley
        if instanceType == "pvp" and instance == "Alterac Valley" and OF.GetNumMapLandmarks() == 22 and index == 23 then
            local towerFound = false
            for i=1,OF.GetNumMapLandmarks() do
                local name = OF.GetMapLandmarkInfo(i)
                if name == "East Frostwolf Tower" then
                    towerFound = true
                    break
                end
            end
            if not towerFound then
                name = "East Frostwolf Tower"
                description = "Destroyed"
                textureIndex = 6
                x = 0.4925394654274
                y = 0.84533333778381
                mapLinkID = nil
                inBattleMap = true
                graveyardID = 0
                areaID = -1
            end
        end
        
        
        
        if pfl.FactionSwap.WorldMapPOIs and instanceType == "pvp" then
            local landmarksToIgnore = addon.BattlegroundAPI:GetAttribute("modules","POI","ignoreFactionSwapping")
            if not landmarksToIgnore or not landmarksToIgnore[name] then
                if LandMarkFactionMap[textureIndex] and Faction:ShouldSwitchSides() then
                    textureIndex = LandMarkFactionMap[textureIndex]
                end
            end
        end
        
        return name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID
    end

    function module:SwapFactionInText(text)
        if text then
            return text:gsub("Horde","Alli<>ance"):gsub("Alliance","Horde"):gsub("Alli<>ance","Alliance")
        else
            return text
        end
    end

    local FactionChatFilter = function(self, event, msg, sender, ...)
        if pfl.FactionSwap.BattlegroundChat and Faction:ShouldSwitchSides() then
            if event == "CHAT_MSG_BG_SYSTEM_HORDE" then
                if sender then
                    msg = module:SwapFactionInText(msg)
                    ChatFrame_MessageEventHandler(self,"CHAT_MSG_BG_SYSTEM_ALLIANCE",msg, nil, ...)
                    
                    return true 
                end
            elseif event == "CHAT_MSG_BG_SYSTEM_ALLIANCE" then
                if sender then
                    msg = module:SwapFactionInText(msg)
                    ChatFrame_MessageEventHandler(self,"CHAT_MSG_BG_SYSTEM_HORDE",msg, nil, ...)
                    
                    return true
                end
            elseif event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" or event == "CHAT_MSG_MONSTER_YELL" or event == "CHAT_MSG_RAID_BOSS_EMOTE" then
                return false, module:SwapFactionInText(msg), sender, ... 
            end
        end
        
        return false, msg, sender, ...
    end

    AddChatFilter = function()
        local RaidBossEmoteFrame_OnEvent = RaidBossEmoteFrame:GetScript("OnEvent")
        RaidBossEmoteFrame:SetScript("OnEvent", function(self,event,msg,...)
            if event == "RAID_BOSS_EMOTE" then
                if pfl.FactionSwap.BattlegroundChat and Faction:ShouldSwitchSides() then
                    msg = module:SwapFactionInText(msg)
                end
            end
            
            RaidBossEmoteFrame_OnEvent(self,event,msg,...)
        end)
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_ALLIANCE", FactionChatFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_HORDE",    FactionChatFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_NEUTRAL",  FactionChatFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_YELL",       FactionChatFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_EMOTE",    FactionChatFilter)

    OF.GetBattlefieldScore = GetBattlefieldScore
    GetBattlefieldScore = function(index)
        local arg1, arg2, arg3, arg4, arg5, faction, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15 = OF.GetBattlefieldScore(index)
        
        if pfl.FactionSwap.BattlefieldScore and Faction:ShouldSwitchSides() then
            faction = Faction:Swap(faction)
        end
        
        return arg1, arg2, arg3, arg4, arg5, faction, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15
    end

    OF.GetBattlefieldTeamInfo = GetBattlefieldTeamInfo
    GetBattlefieldTeamInfo = function(faction)
        if pfl.FactionSwap.BattlefieldScore and Faction:ShouldSwitchSides() then
            faction = Faction:Swap(faction)
        end
        
        return OF.GetBattlefieldTeamInfo(faction)
    end

    OF.SetBattlefieldScoreFaction = SetBattlefieldScoreFaction
    SetBattlefieldScoreFaction = function(faction)
        if pfl.FactionSwap.BattlefieldScore and Faction:ShouldSwitchSides() then
            faction = Faction:Swap(faction)
        end
        
        return OF.SetBattlefieldScoreFaction(faction)
    end

    OF.GetBattlefieldWinner = GetBattlefieldWinner
    GetBattlefieldWinner = function()
        local winner = OF.GetBattlefieldWinner(faction)
        return (pfl.FactionSwap.BattlefieldScore and Faction:ShouldSwitchSides()) and Faction:Swap(winner) or winner
    end

    --GetBattlefieldWinner


    local WINNER_TO_FACTION = {
        [0] = "Horde",
        [1] = "Alliance"
    }

    OnWorldStateScoreShow = function()
        if addon:IsRunning() and MiniMapBattlefieldFrame.status == "active" then
            local winner = OF.GetBattlefieldWinner()
            if winner == 2 then -- Premature end or Battleground time out
                addon:StopBattleground()
            elseif winner then -- Battleground won by either side
                addon:TriggerBattlegroundVictory(WINNER_TO_FACTION[winner])
            end
        end
    end

    OnWorldStateScoreFrame_Update = function()
        local winner = GetBattlefieldWinner()
        if MiniMapBattlefieldFrame.status == "active" and winner and winner ~= 2 then
            addon.Alerts:SetWinScoreText()
        end
    end

    function module:UpdateMinimapIcons(reset)
        if not reset and pfl.FactionSwap.Minimap and Faction:ShouldSwitchSides() then
            Minimap:SetIconTexture("Interface\\Addons\\DXE\\Textures\\POIICONS")
        else
            Minimap:SetIconTexture("Interface/MINIMAP/POIICONS")
        end
    end
end

function module:ActivateBattleground(delayed)
    if not delayed then module:ScheduleTimer("ActivateBattleground",0.1,true);return end -- just to delay the function to beat the race condition
    if addon:IsRunning() then return end
    
    local instanceName, instanceType = GetInstanceInfo()
    
    if instanceType ~= "pvp" then return end
    
    local moduleFound = false
    for key, data in addon:IterateEDB() do
        if data.zone == instanceName then
            if addon.CE.key ~= data.key then
                addon:SetActiveEncounter(data.key)
                moduleFound = true
            end
            break
        end
    end
    
    -- Setting up minimap by factions
    module:UpdateMinimapIcons()
    
    if moduleFound then
        if (GetBattlefieldInstanceRunTime() - 120*1000) > 0 then
            addon:StartBattleground()
--            addon.PvPScore:Score_Reset()
        else
            addon:UpdateTriggers()
            addon:ShowScore("TIMER")
        end
    end
end

local lastInstance, lastInstanceType
local reloadInBG = false

function module:PLAYER_ENTERING_WORLD()
    local instanceName, instanceType = GetInstanceInfo()
    reloadInBG = lastInstance == nil and instanceType == "pvp"
    local leavingFromBG = (instanceType ~= "pvp") and (lastInstanceType == "pvp")
    lastInstanceType = instanceType
    lastInstance = instanceName
    if leavingFromBG then 
        if pfl.HideVictoryFrameOnLeaving then addon.Alerts:HideLegionAlert() end
        addon.PvPScore:ScoreFrame_Hide()
        module:UpdateMinimapIcons(true)
        if addon:IsModuleBattleground(addon.CE.key) then addon:StopBattleground(true) end
    end
end

function module:PLAYER_ENTERING_BATTLEGROUND()
    dxeprint("PLAYER_ENTERING_BATTLEGROUND: "..(GetBattlefieldInstanceRunTime()/1000))
    module:ActivateBattleground()
end

function module:IsReloadInBG()
    return reloadInBG
end

local BATTLEGROUND_PREFIX = "bg-"

function addon:RegisterBattleground(data)
    data.key = BATTLEGROUND_PREFIX..data.key   
    addon:RegisterEncounter(data)
    module:ActivateBattleground()
end

function addon:IsModuleBattleground(key)
    if not key and not addon.CE then return false end
    return find(key or addon.CE.key,format("%s-",BATTLEGROUND_PREFIX))
end

function addon:StartBattleground()
    startedOnIEEU = true -- to block wiping on combatstop
    if addon:IsRunning() then return end
    if addon:GetActiveEncounter() == "default" then return end
    
    addon:StartTimer(true,(GetBattlefieldInstanceRunTime()-120*1000)/1000)
    addon:ShowScore("ALL")
    addon.callbacks:Fire("StartBattleground",CE)
    addon.Alerts:StartGlobalResTimer()
    addon:UpdateBestTimer(true, true)
    addon:UpdatePaneVisibility()
    addon:PauseScanning()
    addon:OpenWindows()
end

function addon:StopBattleground(stoppedByLeaving)
    if not stoppedByLeaving and not addon:IsRunning() then return end
    addon.callbacks:Fire("StopBattleground",stoppedByLeaving)
    addon:StopTimer()
    
    addon:UpdatePaneVisibility()
    
    addon:ResumeScanning()
    addon:ResetDefeatTbl()
    addon:ResetWipeTriggers()
    addon.Alerts:AoEResTimer_Hide()
end

function addon:TriggerBattlegroundVictory(winningSide)
    if addon:GetActiveEncounter() == "default" then return end
    if not addon:IsRunning() then return end
    
    
    -- Handle defeat alert
    local screenTaken = false
    local apfl = addon.db.profile
    local CE = addon.CE
    
    addon.Alerts.QuashAll()
    if pfl.VictoryAnnouncementEnabled then
        local alertWinner = Faction:ShouldSwitchSides() and Faction:Swap(winningSide) or winningSide
        addon.Alerts:BattlegroundWonAlert(CE, alertWinner, "None")
        
        -- A defeat screenshot
        if pfl.VictoryScreenshot and Faction:Of("player") == winningSide:lower() then
            screenTaken = true
            addon:ScheduleTimer("Screen",3)
        end
    end
    
    -- Stop the encounter
    addon.callbacks:Fire("TriggerBattlegroundVictory",CE)
    addon:StopBattleground()

    if apfl.Proximity.AutoHide then
        self:HideProximity()
        self:HideRadar()
    end
    
    if apfl.AlternatePower.AutoHide then
        self:HideAlternatePower()
    end
    
    -- Speed kill record
    local oldTime = addon:GetBestTime(CE.key,winningSide)
    local newTime = addon.Pane.timer:GetTime()
    
    addon:UpdateBestTimeDiff(true)
    
    if apfl.Pane.RecordBestTime then
        if not oldTime or newTime < oldTime then
            addon:SetNewBestTime(newTime,CE.key,winningSide)
            if oldTime then addon.Pane.timer:SetTextColor(0.13, 0.57, 1) else addon.Pane.timer:SetTextColor(0, 1, 0) end
            addon.Pane.besttimerlabel:SetText("Former speed kill:")
            local recordTime = addon:TimeToText(newTime)
            if apfl.Pane.AnnounceRecordKillOnScreen then
                addon.Alerts:SpeedkillRecordAlert(recordTime,apfl.SpecialWarnings.VictoryAnnouncementEnabled)
            end
            
            addon:Print(format("%s won in a new fastest time of %s.", CE.name, recordTime))
            if apfl.Pane.ScreenshotBestTime and not screenTaken then
                self:ScheduleTimer("Screen",3)
            end
        else
            addon.Pane.timer:SetTextColor(1, 0, 0)
        end
    end
end

function module:PLAYER_DEAD()
    if pfl.AutoRelease then
        if addon.CE and addon.CE.key and addon:IsModuleBattleground(addon.CE.key) then
            if addon:IsRunning() and not HasSoulstone() then
                RepopMe()
            end
        end
    end
end

function module:ToggleAutoRelease()
    pfl.AutoRelease = not pfl.AutoRelease
    addon:Print("Automatic Release of Spirit in battlegrounds has been "..(pfl.AutoRelease and "|cff00ff00ENABLED|r" or "|cffff0000DISABLED|r"))
end

