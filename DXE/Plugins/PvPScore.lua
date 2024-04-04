local addon = DXE
local format,find = string.format,string.find
local ceil,floor,abs,cos,pi = math.ceil,math.floor,math.abs,math.cos,math.pi
local error = error
local run,lookup = addon.util.run, addon.util.lookup
local TraverseTable = addon.util.TraverseTable
local OF = addon.originalfunctions
local LaterUpdates = {}

local defaults = {
	profile = {
		Enabled = true,
        Scale = 0.7,
        
        -- Colors
        Colors = {
            neutral     = {r = 1,    g = 1,    b = 0,     a = 1},
            unavailable = {r = 0.8,  g = 0,    b = 0.925, a = 1},
            alliance    = {r = 0,    g = 0.75, b = 1,     a = 1},
            horde       = {r = 0.75, g = 0,    b = 0,     a = 1},
            unknown     = {r = 1,    g = 1,    b = 1,     a = 1},
        },
        
        FlashColors = {
            neutral =     {r = 1,    g = 1,    b = 0,     a = 1},
            unavailable = {r = 0.8,  g = 0,    b = 0.925, a = 1},
            alliance =    {r = 0,    g = 0.85, b = 1,     a = 1},
            horde =       {r = 1,    g = 0,    b = 0,     a = 1},
        },
        
        -- Score
        ScoreTexture = "Blizzard",
        ScoreBorder = "Blizzard Tooltip",
        ScoreBorderEdge = 20,
        ScoreFont = "Friz Quadrata TT",
        ShowScoreProgress = true,
        ScoreProgressTexture = "Blizzard",
        ScoreProgressAlpha = 0.35,
        
        -- Timer
        TimerFont = "Friz Quadrata TT",
        
        -- Score Slots
        ShowSlots = true,
        ScoreSlotsTexture = "Blizzard",
        ScoreSlotsBorder = "Blizzard Tooltip",
        ScoreSlotsBorderEdge = 20,
        ScoreSlotsFont = "Friz Quadrata TT",
        ScoreSlotsTextureAlpha = 1,
        ScoreSlotsBorderAlpha = 1,
        ScoreBorderUpdateColors = true,
        ScoreSlotBorderColor = {0.8, 0.8, 0.8},
        
        -- Capture Bar
        EnableCaptureBar = true,
        CaptureBarTexture = "Blizzard",
        CaptureBarBorder = "Blizzard Tooltip",
        CaptureBarBorderEdge = 10,
        
        HideBlizzTimers = false,
        ShowGrandCountdown = true,
        Pattern = {
            Incoming = "{square} {baseName} - ENEMY INCOMING! {square}",
            IncomingSpecific = "{square} {baseName} - INCOMING ({playerCount} enemies)! {square}",
            Safe = "{triangle} {baseName} - SAFE! {triangle}",
            UnderAttack = "{cross} {baseName} - UNDER ATTACK! {cross}",
        }
	}
}

local L = addon.L
local db,pfl,gbl

---------------------------------------
-- INITIALIZATION
---------------------------------------
local SM = LibStub("LibSharedMedia-3.0")
local module = addon:NewModule("PvP Score","AceTimer-3.0","AceEvent-3.0")
local ScoreSlots = addon:NewModule("PvP Score - Slots","AceTimer-3.0","AceEvent-3.0")
local Score = addon:NewModule("PvP Score - Score","AceTimer-3.0")
local ScoreTimer = {}
local BattlegroundShutdown = {}
local CaptureBar = {}

local BattlegroundModules
local BattlegroundAPI = {}
addon.BattlegroundAPI = BattlegroundAPI
local Faction = addon.Faction
local FactionMap = Faction.Map

addon.PvPScore = module
addon.PvPScore.defaults = defaults
local PvP = addon.PvP
local Countdown = addon.Countdown
local CE
local TestMode = false

local TestSlots = {
    count = 5,
    texts = {"Slot 1","Slot 2","Slot 3","Slot 4","Slot 5"},
    --colors = {"neutral","unavailable","alliance","horde","unknown"},
    colors = {alliance = "alliance", horde = "horde", [3] = "unavailable", [4] = "neutral", [5] = "unknown"},
    widthmult = {2,2,3,2,2},
    offsetmults = {
        {2, 5, 0, -5, -2},
        {0, 0, 0, -1, -1},
    },
    height = {37,37,74,37,37},
    offsets = {
        {0,0,0,0,0},
        {-10, -10, -10, -10, -10},
    },
}

local TIME_WARM_UP = 2 * 60 -- 2 minutes in seconds

local function colorByFaction(faction, text)
    if not faction or not FactionMap[faction] then
        return tostring(text) or ""
    else
        return format("|cff%s%s|r",FactionMap[faction].color, text and tostring(text) or faction)
    end
end

BattlegroundAPI.colorByFaction = colorByFaction

local function getClassIcon(classToken)
    if classToken == nil then return "" end
    local left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[classToken])
    return format("|T%s:20:20:0:0:256:256:%s:%s:%s:%s|t",
        "Interface\\WorldStateFrame\\ICONS-CLASSES",
        left*256, right*256, top*256,  bottom*256)
end

function BattlegroundAPI:SetModuleVariables(tbl)
    addon.Invoker:InvokeCommands({{"set",tbl}})
end

function module:RefreshProfile()
	pfl = db.profile
end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("PvP_Score", defaults)
	db = self.db
	pfl = db.profile
    gbl = db.global
    
	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
    addon.RegisterCallback(self, "StartBattleground")
    addon.RegisterCallback(self, "StopBattleground")
    addon.RegisterCallback(self, "SetActiveEncounter", "RefreshActiveEncounter")
    self:RegisterEvent("START_TIMER")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    local TimerTracker_OnEvent = TimerTracker:GetScript("OnEvent")
    TimerTracker:SetScript("OnEvent",function(...)
        if not pfl.HideBlizzTimers then TimerTracker_OnEvent(...) end
    end)
    
    self:ScoreFrame_Create()
    self:ScoreFrame_Skin()
    self:ScoreFrame_AdaptFactions()
    self:ScoreFrame_Hide()
end

---------------------------------------
-- EVENT HANDLING
---------------------------------------
local CHAT_EVENTS = {
    ["CHAT_MSG_BG_SYSTEM_ALLIANCE"] = "chat-battleground",
    ["CHAT_MSG_BG_SYSTEM_HORDE"] = "chat-battleground",
    ["CHAT_MSG_BG_SYSTEM_NEUTRAL"] = "chat-battleground",
    ["CHAT_MSG_MONSTER_YELL"] = "yell",
}

local CHAT_EVENT_TO_FACTION = {
    ["CHAT_MSG_BG_SYSTEM_ALLIANCE"] = "alliance",
    ["CHAT_MSG_BG_SYSTEM_HORDE"]    = "horde",
    ["CHAT_MSG_BG_SYSTEM_NEUTRAL"]  = "unknown",
}
    
do
    local function UnregisterChatTriggers()
        for event,_ in pairs(CHAT_EVENTS) do
            module:UnregisterEvent(event)
        end
    end
    
    local function UpdateChatTriggers()
        UnregisterChatTriggers()
        
        for event,_ in pairs(CHAT_EVENTS) do
            module:RegisterEvent(event, "Battleground_ProcessMsg")
        end
    end
    
    function module:START_TIMER(event,timerType,current,maximum)
        if not CE or not addon:IsModuleBattleground(CE and CE.key) then return end
        
        local instanceType = select(2, GetInstanceInfo())
        if instanceType ~= "pvp" or current <= 0 then return end
        
        local delta = math.abs(ScoreTimer:GetTime()-current)
        if delta > 0.4 then
            ScoreTimer:Start(current)
            if pfl.HideBlizzTimers then Countdown:StartTimer(current) end
        end
        
        -- Trigger a start timer update within the battleground modules
        BattlegroundAPI:SetModuleVariables({
            ["StartTime"] = current,
        })
        self:FireBattlegroundEvent("START_TIMER_UPDATE")
        
    end

    function module:PLAYER_ENTERING_WORLD()
        local instanceType = select(2,GetInstanceInfo())
        if instanceType == "pvp" then
            UIloaded = true
            UpdateChatTriggers()
        else
            UIloaded = false
            UnregisterChatTriggers()
        end
    end

    function module:PLAYER_REGEN_ENABLED()
        if hideBlizzScoreLater then
            WorldStateAlwaysUpFrame:Hide()
            hideBlizzScoreLater = false
        end
        
        module:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end

    function module:RefreshActiveEncounter()
        CE = addon.CE
        if addon:IsModuleBattleground() then
            BattlegroundAPI:RunTemplateAttribute("setup")
        end
        
    end

    function module:StartBattleground()
        RequestBattlefieldScoreData()
        
        self:RegisterEvent("UPDATE_WORLD_STATES")
        self:RegisterEvent("ZONE_CHANGED")
        
        -- Start score timer using the time limit
        local limit = module:GetWinTime()
        if limit > 0 then ScoreTimer:Start(limit) else ScoreTimer:Clear() end
        BattlegroundShutdown:StartMonitor()
    end
    
    function module:StopBattleground(event,stoppedByLeaving)
        ScoreTimer:Pause()
        BattlegroundShutdown:StopMonitor()
        
        self:UnregisterEvent("UPDATE_WORLD_STATES")
        self:UnregisterEvent("ZONE_CHANGED")
        
        module:ScoreFrame_StopRefreshTimers()
        BattlegroundModules:UnregisterAllEvents()
        BattlegroundModules:StopTimers()
        
        if not stoppedByLeaving then
            Score:ScheduleTimer("Refresh",0.1)
            ScoreSlots:ScheduleTimer("Refresh",0.1)
        end
    end
end

---------------------------------------
-- FACTIONS
---------------------------------------
local adjustFactionOrder = function(data)
    if type(data) == "function" then data = data() end
    if type(data) ~= "table"    then return data   end
    
    local result = addon:CopyTable(data)
    for k,v in pairs(result) do
        result[k] = Faction:Adjust(v)
    end
    
    --dxeprint(format("player's effective faction: %s", Faction:Of("player")),"problem")
    --dxeprint(format("home team location: %s", Faction:GetHomeTeamLocation()),"problem")
    
    -- Setting up Faction slots
    if result.alliance and result.horde then                
        local amAlliance       = Faction:Of("player") == "alliance"
        local isHomeLeft       = Faction:GetHomeTeamLocation() == "LEFT"
        local allianceIsHome   = amAlliance == isHomeLeft
        
        result[1] = allianceIsHome and result.alliance or result.horde
        result[2] = allianceIsHome and result.horde    or result.alliance
    end
    
    return result
end

---------------------------------------
-- BATTLEGROUND PROGRESS
---------------------------------------

local battlegroundStartFlagCheck = false
local shouldHaveSwitched

do
    function module:UPDATE_WORLD_STATES()
        if not addon:IsRunning() or not addon:IsModuleBattleground() then return end
        module:ScoreFrame_Refresh(false)
        CaptureBar:Update()
    end
    
    function module:ZONE_CHANGED()
        if not addon:IsRunning() or not addon:IsModuleBattleground() then return end
        CaptureBar:Update()
    end

    function module:Battleground_Reset()
        
        BattlegroundModules:Reset()
        BattlegroundModules:GetCore("flags"):UnFixFlagIcon()
        
        -- Initialization
        BattlegroundAPI:RunTemplateAttribute("init")
        BattlegroundAPI:RunModuleAttribute("init")
        
        battlegroundStartFlagCheck = false
        
        shouldHaveSwitched = Faction:ShouldSwitchSides()
    end
    
    function module:CanDraw()
        return BattlegroundAPI:GetAttribute("canDraw") == true
    end
    
    
    function module:InvokeWinnerPredictionCommands(winner)
        -- Set module variables
        BattlegroundAPI:SetModuleVariables({
            ["WinTime"] = module:GetWinTime(),
            ["WinFaction"] = Faction:Adjust(winner),
            ["WinFactionPure"] = winner,
        })
        
        -- Module actions
        if winner == "alliance" or winner == "horde" then
            self:FireBattlegroundEvent("FACTION_LEADS")
        elseif winner == "unknown" and module:CanDraw() then
            self:FireBattlegroundEvent("DRAW_STATE")
        end
    end
    
    function module:FireBattlegroundEvent(event)
        if not CE.battleground or not CE.battleground.events then return end
        
        for _,info in ipairs(CE.battleground.events) do
            if lookup(event, info.event) then
                addon.Invoker:InvokeCommands(info.execute)
            end
        end
    end
    
    function addon:GetTemplateAttribute(...)
        return BattlegroundAPI:GetTemplateAttribute(...)
    end
    
    function addon:GetModuleAttribute(...)
        return BattlegroundAPI:GetModuleAttribute(...)
    end
    
    function module:Battleground_ProcessMsg(event,msg,...)
        if not addon:IsModuleBattleground() then
            module:RefreshActiveEncounter()
        end
        
        if addon:IsModuleBattleground() then
            BattlegroundModules:ProcessChat(event,msg, BattlegroundAPI:GetTemplateAttribute("modules"))
            BattlegroundModules:ProcessChat(event,msg, BattlegroundAPI:GetModuleAttribute("modules"))
        end
    end
end

---------------------------------------
-- SCORE FRAME
---------------------------------------
local ScoreFrame
local showFrame, timerShown, panelsShown = false, false, false

-- Animations
local ShowScoreAnimation, ShowScoreGlobeAnimation, ShowScorePanelsAnimation, ShowSlotsAnimation, ShowScoreAnimation_Init

do
    local DXEScoreFrameAnchor
    local UIloaded = false
    local hideBlizzScoreLater = false

    local function CreateAnimation(parent, initFunction, animationFunction, finishedFunction, endFrame, delay)
       
        local since = 0
        local interval = 1/30
        local actualFrame = 1
        local frame

        if not delay then delay = 0 end

        local function OnUpdate(self, elapsed)
            since = since + elapsed
            while(since > interval) do
                frame = actualFrame - delay
                animationFunction(frame)
             
                if frame >= endFrame then
                    parent:SetScript("OnUpdate",nil)
                    if finishedFunction then finishedFunction() end
                    since = 0
                    actualFrame = 1
                    return
                end
             
                since = since - interval
                actualFrame = actualFrame + 1
            end
        end

        return {
            Play = function()
                initFunction()
                parent:SetScript("OnUpdate", OnUpdate)
            end
        }
    end

    function module:ScoreFrame_Create()
        DXEScoreFrameAnchor = addon:CreateLockableFrame("ScoreFrameAnchor",400,128,format("%s - %s",L["PvP"],L["ScoreFrame Anchor"]))
        addon:RegisterMoveSaving(DXEScoreFrameAnchor,"TOP","UIParent","TOP",0,-35)
        addon:LoadPosition("DXEScoreFrameAnchor")
        
        -- Score Frame
        ScoreFrame = CreateFrame("Frame","DXEScoreFrame",UIParent)
        ScoreFrame:ClearAllPoints()

        ScoreFrame:SetPoint("TOP",DXEScoreFrameAnchor,"TOP",0,0)
        ScoreFrame:SetWidth(400)
        ScoreFrame:SetHeight(128)
        ScoreFrame:SetAlpha(1)
        ScoreFrame:SetFrameStrata("LOW")
        ScoreFrame:SetScale(pfl.Scale)
        
        ScoreFrame.Timer = {}
        
        -- Timer Frame
        local TimerFrame = CreateFrame("Frame","DXE Globe Frame",ScoreFrame)
        TimerFrame:ClearAllPoints()
        TimerFrame:SetPoint("CENTER",ScoreFrame,"CENTER",0,0)
        TimerFrame:SetWidth(128)
        TimerFrame:SetHeight(128)
        TimerFrame:SetFrameStrata("MEDIUM")
        ScoreFrame.Timer.Frame = TimerFrame

        -- Globe (texture)
        local GlobeTexture = ScoreFrame.Timer.Frame:CreateTexture(nil,"OVERLAY", nil, 1)
        GlobeTexture:SetTexture("Interface\\\WorldMap\\UI-World-Icon")
        GlobeTexture:ClearAllPoints()
        GlobeTexture:SetPoint("CENTER",ScoreFrame,"CENTER",0,0)
        GlobeTexture:SetWidth(85)
        GlobeTexture:SetHeight(85)
        GlobeTexture:SetBlendMode("BLEND")
        GlobeTexture:SetDrawLayer("BACKGROUND",-6)
        ScoreFrame.Timer.GlobeTexture = GlobeTexture

        -- Fire Ring (frame)
        local FireRingFrame = CreateFrame("Frame","DXE Fire Ring Frame",ScoreFrame)
        FireRingFrame:ClearAllPoints()
        FireRingFrame:SetPoint("CENTER",ScoreFrame,"CENTER",0,0)
        FireRingFrame:SetWidth(128)
        FireRingFrame:SetHeight(128)
        FireRingFrame:SetFrameStrata("MEDIUM")
        ScoreFrame.Timer.FireRingFrame = FireRingFrame
        
        -- Fire Ring (texture)
        local FireRingTexture = FireRingFrame:CreateTexture(nil,"OVERLAY",nil,2)
        FireRingTexture:SetTexture("Interface\\UnitPowerBarAlt\\Atramedes_Circular_Flash")
        FireRingTexture:ClearAllPoints()
        FireRingTexture:SetPoint("CENTER",ScoreFrame,"CENTER",0,0)
        FireRingTexture:SetWidth(128)
        FireRingTexture:SetHeight(128)
        FireRingTexture:SetBlendMode("ADD")
        FireRingTexture:SetDrawLayer("OVERLAY",1)
        FireRingTexture:SetVertexColor(1,1,1,1)
        ScoreFrame.Timer.FireRingTexture = FireRingTexture

        ag = FireRingTexture:CreateAnimationGroup()
        if not ag:IsPlaying() then
           local spin = ag:CreateAnimation("Rotation")
           spin:SetOrder(1)
           spin:SetDuration(20)
           spin:SetDegrees(360)
           ag:SetLooping("REPEAT")
           ag:Play()
        end

        -- Not enough players dummy frame
        BattlegroundShutdown.UpdateFrame = CreateFrame("Frame","DXE Not Enough Players Frame",ScoreFrame)

        -- Timer Text
        local TimerText = FireRingFrame:CreateFontString(nil, "OVERLAY")
        TimerText:SetShadowOffset(2, -2)
        TimerText:ClearAllPoints()
        TimerText:SetPoint("CENTER",FireRingTexture,"CENTER",0,0)
        TimerText:SetWidth(128)
        TimerText:SetHeight(128)
        TimerText:SetDrawLayer("OVERLAY",2)
        TimerText:SetVertexColor(1, 1, 1, 1)
        ScoreFrame.Timer.Text = TimerText

        -- Score Border (frame)
        local BorderFrame = CreateFrame("Frame","DXE Score Bar Border",ScoreFrame)
        BorderFrame:ClearAllPoints()
        BorderFrame:SetPoint("CENTER",FireRingTexture,"CENTER",0,0)
        BorderFrame:SetWidth(300)
        BorderFrame:SetHeight(65)
        BorderFrame:SetFrameStrata("LOW")
        ScoreFrame.border = BorderFrame
        
        local ANIMATION_TIME = 1
        
        local function MoveToValue_OnUpdate(self, elapsed)
            if self.IsAnimating then
                self.t0 = GetTime()
                return
            end
            
            local dt = GetTime() - self.t0
            local newValue = self.val0 + (self.valMax * (1 - cos(pi*dt/ANIMATION_TIME))) / 2
            if self.valMax - newValue < 0.1 then
                self.isUpdating = false
                self:SetScript("OnUpdate",nil)
                self:SetValue(self.valMax)
            else
                self:SetValue(newValue)
            end
        end
        
        local function MoveToValue(self, newValue)
            if self:GetValue() ~= newValue then
                self.t0 = GetTime()
                self.val0 = self:GetValue()
                self.valMax = newValue
                if not self.isUpdating then 
                    self.isUpdating = true
                    self:SetScript("OnUpdate",MoveToValue_OnUpdate)
                end
            end
        end
        
        --------------------
        -- Alliance Score --
        --------------------
        do
            ScoreFrame.Alliance = {}
            
            -- Background Texture
            local Texture = ScoreFrame:CreateTexture(nil, "OVERLAY", nil, 4)
            Texture:SetWidth(140)
            Texture:SetHeight(60)
            Texture:SetVertexColor(0, 0.75, 1, 0.1)
            Texture:SetBlendMode("DISABLE")
            Texture:SetDrawLayer("BACKGROUND",-8)
            ScoreFrame.Alliance.Texture = Texture
            
            -- Progress Bar
            local ProgressBar = CreateFrame("StatusBar",nil,ScoreFrame)
            ProgressBar:SetMinMaxValues(0, 100)
            ProgressBar:ClearAllPoints()
            ProgressBar:SetPoint("TOPLEFT",Texture,"TOPLEFT")
            ProgressBar:SetPoint("BOTTOMRIGHT",Texture,"BOTTOMRIGHT")
            ProgressBar:SetFrameStrata("LOW")
            ProgressBar:SetFrameLevel(1) 
            ProgressBar.MoveToValue = MoveToValue
            ScoreFrame.Alliance.ProgressBar = ProgressBar
            --ProgressBar:SetScript("OnUpdate",function(self, elapsed) print(elapsed) end)
            
            -- Text
            local ScoreText = ScoreFrame:CreateFontString(nil, "OVERLAY")
            ScoreText:SetShadowOffset(2, -2)
            ScoreText:SetWidth(128)
            ScoreText:SetHeight(128)
            ScoreText:SetDrawLayer("OVERLAY",8)
            ScoreFrame.Alliance.Text = ScoreText
            
            -- Emblem (texture)
            local Logo = FireRingFrame:CreateTexture(nil, "OVERLAY", nil, 4)
            Logo:SetTexture("Interface\\Timer\\Alliance-Logo")
            Logo:SetWidth(64)
            Logo:SetHeight(64)
            Logo:SetDrawLayer("OVERLAY")
            ScoreFrame.Alliance.Logo = Logo

            -- Winner Highlight (texture)
            local Highlight = ScoreFrame:CreateTexture(nil,"OVERLAY", nil, 5)
            Highlight:SetTexture("Interface\\BUTTONS\\UI-ActionButton-Border")
            Highlight:SetTexCoord(0.21,0.77,0.23,0.78)
            Highlight:ClearAllPoints()
            Highlight:SetPoint("CENTER",ScoreFrame.Alliance.Texture,"CENTER",0,0)
            Highlight:SetWidth(142) -- 320
            Highlight:SetHeight(60)
            Highlight:SetBlendMode("ADD")
            Highlight:SetDrawLayer("BACKGROUND",-7)
            Highlight:SetVertexColor(0,0.75,1,1)
            ScoreFrame.Alliance.Highlight = Highlight
        end
        
        --------------------
        -- Horde Score --
        --------------------
        do
            ScoreFrame.Horde = {}
        
            -- Background Texture
            local Texture = ScoreFrame:CreateTexture(nil, "OVERLAY", nil, 4)
            Texture:SetWidth(140)
            Texture:SetHeight(60)
            Texture:SetVertexColor(0.75, 0, 0, 1)
            Texture:SetBlendMode("DISABLE")
            Texture:SetDrawLayer("BACKGROUND",-8)
            ScoreFrame.Horde.Texture = Texture
            
            -- Progress Bar
            local ProgressBar = CreateFrame("StatusBar",nil,ScoreFrame)
            ProgressBar:SetMinMaxValues(0,100)
            ProgressBar:ClearAllPoints()
            ProgressBar:SetPoint("TOPLEFT",Texture,"TOPLEFT")
            ProgressBar:SetPoint("BOTTOMRIGHT",Texture,"BOTTOMRIGHT")
            ProgressBar:SetFrameStrata("LOW")
            ProgressBar:SetFrameLevel(1) 
            ProgressBar.MoveToValue = MoveToValue
            ScoreFrame.Horde.ProgressBar = ProgressBar
            
            -- Text
            local ScoreText = ScoreFrame:CreateFontString(nil, "OVERLAY")
            ScoreText:SetShadowOffset(2, -2)
            ScoreText:SetWidth(128)
            ScoreText:SetHeight(128)
            ScoreText:SetDrawLayer("OVERLAY",8)
            ScoreFrame.Horde.Text = ScoreText
            
            -- Emblem (texture)
            local Logo = FireRingFrame:CreateTexture(nil, "OVERLAY", nil, 4)
            Logo:SetTexture("Interface\\Timer\\Horde-Logo")
            Logo:SetWidth(64)
            Logo:SetHeight(64)
            Logo:SetDrawLayer("OVERLAY")
            ScoreFrame.Horde.Logo = Logo

            -- Winner Highlight (texture)
            local Highlight = ScoreFrame:CreateTexture(nil,"OVERLAY", nil, 5)
            Highlight:SetTexture("Interface\\BUTTONS\\UI-ActionButton-Border")
            Highlight:SetTexCoord(0.21,0.77,0.23,0.78)
            Highlight:ClearAllPoints()
            Highlight:SetPoint("CENTER",ScoreFrame.Horde.Texture,"CENTER",0,0)
            Highlight:SetWidth(142)
            Highlight:SetHeight(60)
            Highlight:SetBlendMode("ADD")
            Highlight:SetDrawLayer("BACKGROUND",-7)
            Highlight:SetVertexColor(1,0,0,1)
            ScoreFrame.Horde.Highlight = Highlight
        end
        ----------------------------------------------------------------------
        ---------------------------- ANIMATIONS ------------------------------
        ----------------------------------------------------------------------
        ShowScoreAnimation_Init = function()
            ScoreTimer:Clear()
            ScoreFrame.Timer.Frame:SetAlpha(1)
            ScoreFrame.Timer.FireRingFrame:SetAlpha(1)
            ScoreFrame.Timer.GlobeTexture:SetWidth(0.1)
            ScoreFrame.Timer.GlobeTexture:SetHeight(0.1)
            ScoreFrame.Timer.GlobeTexture:SetAlpha(0)
            ScoreFrame.Timer.Text:SetAlpha(0)
            
            FireRingTexture:SetWidth(0.1)
            FireRingTexture:SetHeight(0.1)
            FireRingTexture:SetAlpha(0)
            ScoreFrame.border:SetWidth(0.1)
            ScoreFrame.border:SetAlpha(0)
            
            ScoreFrame.Alliance.Texture:SetAlpha(0)
            ScoreFrame.Alliance.ProgressBar:SetValue(0)
            ScoreFrame.Alliance.ProgressBar:SetAlpha(0)
            ScoreFrame.Alliance.Text:SetAlpha(0)
            ScoreFrame.Alliance.Logo:SetAlpha(0)
            ScoreFrame.Alliance.Highlight:SetAlpha(0)
            ScoreFrame.Alliance.Highlight:SetWidth(0.01)
            
            ScoreFrame.Horde.Texture:SetAlpha(0)
            ScoreFrame.Horde.ProgressBar:SetValue(0)
            ScoreFrame.Horde.ProgressBar:SetAlpha(0)
            ScoreFrame.Horde.Text:SetAlpha(0)
            ScoreFrame.Horde.Logo:SetAlpha(0)
            ScoreFrame.Horde.Highlight:SetAlpha(0)
            ScoreFrame.Horde.Highlight:SetWidth(0.01)
        end

        local ShowScoreAnimation_Step = function(frame)
            -- Globa Fade In
            if frame >= 0 and frame <= 8 then
                local perc = frame / 8
                ScoreFrame.Timer.GlobeTexture:SetWidth(perc*85+0.01)
                ScoreFrame.Timer.GlobeTexture:SetHeight(perc*85+0.01)
                ScoreFrame.Timer.GlobeTexture:SetAlpha(perc)
                FireRingTexture:SetWidth(perc*128+0.01)
                FireRingTexture:SetHeight(perc*128+0.01)
                FireRingTexture:SetAlpha(perc)
            end
            -- Timer Text Fade-in
            if frame >= 16 and frame <= 24 then
                local perc = (frame - 16) / 8
                ScoreFrame.Timer.Text:SetAlpha(perc)
            end
           
           -- Score Backgrounds Pre-Show
           if frame == 7 then
                ScoreFrame.border:SetAlpha(1)
                ScoreFrame.Alliance.Texture:SetAlpha(1)
                ScoreFrame.Alliance.ProgressBar:SetAlpha(pfl.ShowScoreProgress and 1 or 0)
                ScoreFrame.Horde.Texture:SetAlpha(1)
                ScoreFrame.Horde.ProgressBar:SetAlpha(pfl.ShowScoreProgress and 1 or 0)
           end
           
           -- Score Backgrounds Fade-in
           if frame >= 4 and frame <= 18 then
                local perc = (frame - 4) / 11
                ScoreFrame.Alliance.Texture:SetWidth(perc*137+0.01)
                ScoreFrame.Horde.Texture:SetWidth(perc*137+0.01)
                ScoreFrame.border:SetWidth(perc*280+0.01)
                ScoreFrame.Alliance.Highlight:SetWidth(perc*142+0.01)
                ScoreFrame.Horde.Highlight:SetWidth(perc*142+0.01)
                if lastWinner == "alliance" then ScoreFrame.Alliance.Highlight:SetAlpha(perc) end
                if lastWinner == "horde" then ScoreFrame.Horde.Highlight:SetAlpha(perc) end
           end
           
           if frame >= 8 and frame <= 16 then
                local perc = (frame - 8) / 8
                ScoreFrame.Alliance.Text:SetAlpha(perc)
                ScoreFrame.Horde.Text:SetAlpha(perc)
                ScoreFrame.Alliance.Logo:SetAlpha(perc)
                ScoreFrame.Horde.Logo:SetAlpha(perc)
           end 
        end

        local ShowScoreGlobeAnimation_Init = function()
            ScoreTimer:Clear()
            ScoreFrame.Timer.Frame:SetAlpha(1)
            ScoreFrame.Timer.FireRingFrame:SetAlpha(1)
            
            ScoreFrame.Timer.GlobeTexture:SetWidth(0.1)
            ScoreFrame.Timer.GlobeTexture:SetHeight(0.1)
            FireRingTexture:SetWidth(0.1)
            FireRingTexture:SetHeight(0.1)
            
            ScoreFrame.Timer.Text:SetAlpha(0)
            ScoreFrame.border:SetAlpha(0)
            
            ScoreFrame.Alliance.Texture:SetAlpha(0)
            ScoreFrame.Alliance.Highlight:SetAlpha(0)
            ScoreFrame.Alliance.Text:SetAlpha(0)
            ScoreFrame.Alliance.Logo:SetAlpha(0)
            ScoreFrame.Alliance.ProgressBar:SetAlpha(0)
            
            ScoreFrame.Horde.Texture:SetAlpha(0)
            ScoreFrame.Horde.Highlight:SetAlpha(0)
            ScoreFrame.Horde.Text:SetAlpha(0)
            ScoreFrame.Horde.Logo:SetAlpha(0)
            ScoreFrame.Horde.ProgressBar:SetAlpha(0)
        end

        local ShowScoreGlobeAnimation_Step = function(frame)
           -- Globa Fade In
           if frame >= 0 and frame <= 8 then
                local perc = frame / 8
                FireRingTexture:SetWidth(perc*128+0.01)
                FireRingTexture:SetHeight(perc*128+0.01)
                ScoreFrame.Timer.GlobeTexture:SetWidth(perc*85+0.01)
                ScoreFrame.Timer.GlobeTexture:SetHeight(perc*85+0.01)
           end
           
           -- Timer Text Fade-in
           if frame >= 6 and frame <= 14 then
                local perc = (frame - 6) / 8
                ScoreFrame.Timer.Text:SetAlpha(perc)
           end
           
        end

        local ShowScorePanelsAnimation_Init = function()
            ScoreFrame.Timer.Frame:SetAlpha(1)
            ScoreFrame.Timer.FireRingFrame:SetAlpha(1)
            
            ScoreFrame.border:SetWidth(0.01)
            ScoreFrame.border:SetAlpha(0)
            
            ScoreFrame.Alliance.Texture:SetWidth(0.1)
            ScoreFrame.Alliance.Logo:SetAlpha(0)
            ScoreFrame.Alliance.Highlight:SetAlpha(0)
            ScoreFrame.Alliance.Highlight:SetWidth(0.01)
            ScoreFrame.Alliance.Text:SetAlpha(0)
            ScoreFrame.Alliance.ProgressBar:SetAlpha(0)
            --ScoreFrame.Alliance.ProgressBar:SetValue(0)
            ScoreFrame.Alliance.ProgressBar.IsAnimating = true
            
            ScoreFrame.Horde.Texture:SetWidth(0.1)
            ScoreFrame.Horde.Logo:SetAlpha(0)
            ScoreFrame.Horde.Highlight:SetAlpha(0)
            ScoreFrame.Horde.Highlight:SetWidth(0.01)
            ScoreFrame.Horde.Text:SetAlpha(0)
            ScoreFrame.Horde.ProgressBar:SetAlpha(0)
            
            --ScoreFrame.Horde.ProgressBar:SetValue(0)
        end

        local ShowScorePanelsAnimation_Step = function(frame)
            -- Score Backgrounds Pre-Show
            if frame == 7 then
                ScoreFrame.border:SetAlpha(1)
                ScoreFrame.Alliance.Texture:SetAlpha(1)
                ScoreFrame.Alliance.ProgressBar:SetAlpha(1)
                ScoreFrame.Horde.Texture:SetAlpha(1)
                ScoreFrame.Horde.ProgressBar:SetAlpha(1)
            end

            -- Score Backgrounds Fade-in
            if frame >= 4 and frame <= 18 then
                local perc = (frame - 4) / 11
                ScoreFrame.Alliance.Texture:SetWidth(perc*137+0.01)
                ScoreFrame.Horde.Texture:SetWidth(perc*137+0.01)
                ScoreFrame.border:SetWidth(perc*280+0.01)
                ScoreFrame.Alliance.Highlight:SetWidth(perc*142+0.01)
                ScoreFrame.Horde.Highlight:SetWidth(perc*142+0.01)
            end

            if frame >= 8 and frame <= 16 then
                local perc = (frame - 8) / 8
                ScoreFrame.Alliance.Text:SetAlpha(perc)
                ScoreFrame.Horde.Text:SetAlpha(perc)
                ScoreFrame.Alliance.Logo:SetAlpha(perc)
                ScoreFrame.Horde.Logo:SetAlpha(perc)
                if lastWinner == "alliance" then ScoreFrame.Alliance.Highlight:SetAlpha(perc) end
                if lastWinner == "horde" then ScoreFrame.Horde.Highlight:SetAlpha(perc) end
            end 
        end

        ShowSlotsAnimation = function()
            if not BattlegroundAPI:GetAttribute("slots") and not TestMode then return end
            ScoreSlots:Setup(TestMode and TestSlots)
            module:ScheduleTimer("ScoreSlots_RefreshSetup",0.1)
            module:ScheduleTimer("ScoreSlots_Show",0.5)
            ScoreFrame.Alliance.ProgressBar.IsAnimating = false
        end
        
        ShowScoreAnimation = CreateAnimation(ScoreFrame.Timer.Frame, ShowScoreAnimation_Init,
                                             ShowScoreAnimation_Step, ShowSlotsAnimation,
                                             24, 30)
        ShowScoreGlobeAnimation = CreateAnimation(ScoreFrame.Timer.Frame, ShowScoreGlobeAnimation_Init,
                                                  ShowScoreGlobeAnimation_Step, nil,
                                                  14, 30)
        ShowScorePanelsAnimation = CreateAnimation(ScoreFrame.border, ShowScorePanelsAnimation_Init, 
                                                   ShowScorePanelsAnimation_Step, ShowSlotsAnimation,
                                                   18, 30)
    end

    function module:ScoreFrame_Skin()
        ScoreFrame:SetScale(pfl.Scale)
        ScoreFrame.Timer.Text:SetFont(SM:Fetch("font",pfl.TimerFont), 24, "OUTLINE")
        ScoreFrame.Timer.Text:SetShadowColor(0,0,0,0.5)
        
        -- Score Bars
        ScoreFrame.border:SetBackdrop({
            edgeSize = pfl.ScoreBorderEdge,
            edgeFile = DXE.SM:Fetch("border",pfl.ScoreBorder),
        })
        
        ScoreFrame.Alliance.Texture:SetTexture(DXE.SM:Fetch("statusbar",pfl.ScoreTexture))
        ScoreFrame.Horde.Texture:SetTexture(DXE.SM:Fetch("statusbar",pfl.ScoreTexture))
        
        ScoreFrame.Alliance.Text:SetFont(SM:Fetch("font",pfl.ScoreFont), 30)
        ScoreFrame.Alliance.Text:SetShadowColor(0,0,0,0.5)
        
        ScoreFrame.Horde.Text:SetFont(SM:Fetch("font",pfl.ScoreFont), 30)
        ScoreFrame.Horde.Text:SetShadowColor(0,0,0,0.5)
        
        ScoreFrame.Alliance.ProgressBar:SetAlpha(pfl.ShowScoreProgress and 1 or 0)
        ScoreFrame.Alliance.ProgressBar:SetStatusBarTexture(DXE.SM:Fetch("statusbar",pfl.ScoreProgressTexture))
        ScoreFrame.Alliance.ProgressBar:GetStatusBarTexture():SetHorizTile(false)
        ScoreFrame.Alliance.ProgressBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND",-7)
        ScoreFrame.Alliance.ProgressBar:GetStatusBarTexture():SetBlendMode("ADD")
        ScoreFrame.Alliance.ProgressBar:SetStatusBarColor(0, 0.75, 1, pfl.ScoreProgressAlpha)

        ScoreFrame.Horde.ProgressBar:SetAlpha(pfl.ShowScoreProgress and 1 or 0)
        ScoreFrame.Horde.ProgressBar:SetStatusBarTexture(DXE.SM:Fetch("statusbar",pfl.ScoreProgressTexture))
        ScoreFrame.Horde.ProgressBar:GetStatusBarTexture():SetHorizTile(false)
        ScoreFrame.Horde.ProgressBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND",-7)
        ScoreFrame.Horde.ProgressBar:GetStatusBarTexture():SetBlendMode("ADD")
        ScoreFrame.Horde.ProgressBar:SetStatusBarColor(0.75, 0, 0, pfl.ScoreProgressAlpha)
    end

    function module:ScoreFrame_AdaptFactions()
        local allianceIsHome = Faction:IsAllianceHome()
        local SF = ScoreFrame
        
        SF.Alliance.Texture:ClearAllPoints()
        SF.Alliance.Texture:SetPoint(allianceIsHome and "RIGHT" or "LEFT",SF.Timer.FireRingTexture,"CENTER",0,0)
        
        SF.Alliance.Text:ClearAllPoints()
        SF.Alliance.Text:SetPoint("CENTER",SF.Alliance.Texture,"CENTER",allianceIsHome and -15 or 15,0)
        
        SF.Alliance.Logo:ClearAllPoints()
        SF.Alliance.Logo:SetPoint("CENTER",SF.border,allianceIsHome and "LEFT" or "RIGHT",0,0)
        
        SF.Alliance.ProgressBar:SetReverseFill(allianceIsHome)
        
        SF.Horde.Texture:ClearAllPoints()
        SF.Horde.Texture:SetPoint(allianceIsHome and "LEFT" or "RIGHT",SF.Timer.FireRingTexture,"CENTER",0,0)
        
        SF.Horde.Text:ClearAllPoints()
        SF.Horde.Text:SetPoint("CENTER",SF.Horde.Texture,"CENTER",allianceIsHome and 15 or -15,0)
        
        SF.Horde.Logo:ClearAllPoints()
        SF.Horde.Logo:SetPoint("CENTER",SF.border,allianceIsHome and "RIGHT" or "LEFT",0,0)
        
        SF.Horde.ProgressBar:SetReverseFill(not allianceIsHome)
        
        
    end

    function module:ScoreFrame_Hide()
        ScoreFrame:Hide()
        CaptureBar:Hide()
        ScoreSlots:Hide()
        showFrame = false
        timerShown = false
        panelsShown = false
        WorldStateAlwaysUpFrame:Show()
        ScoreSlots:ClearMacros()
    end
    
    -- This function is meant to be called by Options to update everything when you change settings
    function module:ScoreFrame_UpdateFrames()
        module:UpdateFactionBars()
        CaptureBar:Skin()
        CaptureBar:AdjustFactions()
        
        if pfl.Enabled and showFrame then
            if not ScoreFrame:IsShown() then
                ScoreFrame:Show()
                WorldStateAlwaysUpFrame:Hide()
            else
                module:ScoreFrame_Skin()
                module:ScoreSlots_RefreshSetup(true)
                
                module:ScoreFrame_AdaptFactions()
                Score:UpdateFrames()
                Score:UpdateWinner()
                ScoreSlots:UpdateData()
                ScoreSlots:UpdateFrames()
            end
        elseif not pfl.Enabled and showFrame and ScoreFrame:IsShown() then
            ScoreFrame:Hide()
            WorldStateAlwaysUpFrame:Show()
        end
    end
    
    function module:ScoreFrame_Refresh(refresh,customTime,code)
        if not customTime and not addon:IsRunning() then return end
                
        -- Block simultaneous updates
        local now = GetTime()
        
        if customTime then
            module:ScheduleTimer("ScoreFrame_RefreshLater",customTime, now + customTime)
        elseif LaterUpdates[now] == nil or customTime then
            LaterUpdates[now] = {
                refresh = refresh,
                timer = module:ScheduleTimer("ScoreFrame_RefreshLater",0.1, now),
                cancel = false,
            }
        elseif type(LaterUpdates[now]) == "table" then
            LaterUpdates[now].refresh = LaterUpdates[now].refresh or refresh
        end
    end
    
    function module:ScoreFrame_RefreshLater(now)
        local updateData = LaterUpdates[now]
        if not updateData or updateData.cancel == true then return end
        
        local refresh = updateData.refresh
        LaterUpdates[now] = nil
        
                
        ScoreSlots:Refresh()
        Score:Refresh(now)
        Score:RefreshWinner(refresh, now)
    end
    
    function module:ScoreFrame_StopRefreshTimers()
        for _,data in pairs(LaterUpdates) do
            if data.timer then
                module:CancelTimer(data.timer, true)
            end
        end
    end

    function module:ScoreFrame_Reset()
        Score:Reset()
        Score:UpdateFrames()
        Score:SetWinner(nil)
        ScoreTimer:SetText(nil)
        ScoreSlots:ClearMacros()
    end
    
    function module:UpdateFactionBars()
        local shouldSwitch = Faction:ShouldSwitchSides()
       
        if shouldHaveSwitched ~= nil then
            if shouldSwitch ~= shouldHaveSwitched then
                module:SwapFactionBars()
                shouldHaveSwitched = shouldSwitch
            end
        else
            shouldHaveSwitched = shouldSwitch
        end
    end
    
    function module:SwapFactionBars()
        local patterns = {
            ["alliance.+$"] = {
                original = "alliance",
                replacement = "horde"
            },
            ["horde.+$"] = {
                original = "horde",
                replacement = "alliance",
            }
        }
        
        local filteredBars = {}
        
        for pattern,replacement in pairs(patterns) do
            filteredBars[replacement] = addon.Alerts:GetByPattern(pattern)
        end
        
        
        
        for key,bars in pairs(filteredBars) do
            for idData,info in pairs(bars) do
                local var,tag = idData.var, idData.tag
                local cleanID = var:match(key.original.."(%w+)") -- extracting the rest of the key (allianceassaultcd => assaultcd)
                cleanID = key.replacement..cleanID -- adding the opposite faction prefix (assaultcd => hordeassaultcd)
                
                info.text = PvP:SwapFactionInText(info.text)
                
                
                addon.Invoker:InvokeCommands({
                    {
                        "quash",{var, tag},
                        "alert",{
                            cleanID,
                            timeexact    = info.time,
                            timemax      = info.timemax,
                            tag          = tag,
                            text         = info.text,
                            announcetext = info.announceText},
                    }
                })
            end
        end
    end
end

---------------------------------------
-- SCORE 
---------------------------------------
do
    local scoreData, winnerData
    local ScoreAPI = {}
    BattlegroundAPI.Score = ScoreAPI
    
    ---------------------------------------
    -- SCORE DATA FUNCTIONS
    ---------------------------------------
    function Score:Reset()
        scoreData = {}
        scoreData.ScoreLoaded = false
        for faction,_ in pairs(FactionMap) do
            scoreData[faction] = {
                points = 0,
                lastPoints = 0,
            }
        end
        
        winnerData = {
            winner = "unknown",
            winTime = -1,
        }
        
        ScoreFrame.Alliance.ProgressBar:SetValue(0)
        ScoreFrame.Horde.ProgressBar:SetValue(0)
    end
    
    function ScoreAPI:GetPointsOf(faction)
        if not FactionMap[faction] then
            error(format("%s (%s) is not an acceptable faction.", tostring(faction), type(faction)))
        end
        
        return scoreData[faction].points
    end
    
    function ScoreAPI:GetScoreTimeOf(faction)
        if not FactionMap[faction] then
            error(format("%s (%s) is not an acceptable faction.", tostring(faction), type(faction)))
        end
        
        return scoreData[faction].scoreTime
    end
    
    
    function ScoreAPI:SetPointsFor(faction, points, now)
        if not FactionMap[faction] then
            error(format("%s (%s) is not an acceptable faction.", tostring(faction), type(faction)))
        end
        
        if type(points) ~= "number" then
            error(format("%s (%s) must be a number.", tostring(points), type(points)))
        end
        
        local score = scoreData[faction]
        score.lastPoints = score.points
        score.points = points
        
        if points ~= score.lastPoints then score.scoreTime = now end
    end
    
    
    function ScoreAPI:SetAttribute(name, faction, value)
        if not FactionMap[faction] then
            error(format("%s (%s) is not an acceptable faction.", tostring(faction), type(faction)))
        end
        
        scoreData[faction][name] = value
    end
    
    function ScoreAPI:GetAttribute(name, faction)
        if not FactionMap[faction] then
            error(format("%s (%s) is not an acceptable faction.", tostring(faction), type(faction)))
        end
        
        return scoreData[faction][name]
    end
    
    ---------------------------------------
    -- SCORE UPDATE FUNCTIONS
    ---------------------------------------
    function Score:Refresh(now)
        Score:UpdateData(now)
        Score:UpdateFrames()
    end
    
    function Score:UpdateData(now)
        if not module:ScoreFrame_HasScore() then return end
        -- A custom getscore function
        local statesBroken   = BattlegroundAPI:GetAttribute("modules","score","statesBroken")
        local customGetScore = BattlegroundAPI:GetAttribute("modules","score","getscore")
        
        if customGetScore then
            local alliancePoints, hordePoints = customGetScore()
            
            if statesBroken and not scoreData.ScoreLoaded then
                scoreData.ScoreLoaded = true
                local tmp = alliancePoints
                alliancePoints = hordePoints
                hordePoints = tmp
            end
            
            ScoreAPI:SetPointsFor("alliance", alliancePoints, now)
            ScoreAPI:SetPointsFor("horde",    hordePoints,    now)
        
        -- Default way of getting score
        else
            local pattern        = BattlegroundAPI:GetAttribute("modules","score","pattern")
            local parameterIndex = BattlegroundAPI:GetAttribute("modules","score","parameterIndex")
            local indexes        = BattlegroundAPI:GetAttribute("modules","score","indexes")
            
            for faction,_ in pairs(FactionMap) do
                local index = indexes[(statesBroken and not scoreData.ScoreLoaded) and Faction:Swap(faction) or faction]
                local points = tonumber(string.match((select(parameterIndex, GetWorldStateUIInfo(index)) or ""), pattern)) or 0
                ScoreAPI:SetPointsFor(faction, points, now)
            end
            
            if statesBroken and not scoreData.ScoreLoaded then scoreData.ScoreLoaded = true end
        end
    end
    
    function Score:UpdateFrames()
        
        local scoreData = {
            alliance = ScoreAPI:GetPointsOf("alliance"),
            horde    = ScoreAPI:GetPointsOf("horde"),
        }
        local finalScore = BattlegroundAPI:GetAttribute("modules","score","finalScore") or 1e-300
        local maxScore = BattlegroundAPI:GetAttribute("modules","score","maxScore")
        
        if TestMode then
            scoreData.alliance = 230
            scoreData.horde    = 230
            maxScore = nil
            finalScore = 460
        end
        
        Faction:Adjust(scoreData)

        local allianceScore = maxScore and (1 - tonumber(scoreData[2] / maxScore)) or (tonumber(scoreData[1]) / finalScore)
        local hordeScore    = maxScore and (1 - tonumber(scoreData[1] / maxScore)) or (tonumber(scoreData[2]) / finalScore)

        ScoreFrame.Alliance.Text:SetText(tostring(scoreData[1]))
        ScoreFrame.Horde.Text:SetText(tostring(scoreData[2]))
        ScoreFrame.Alliance.ProgressBar:MoveToValue(100 * allianceScore)
        ScoreFrame.Horde.ProgressBar:MoveToValue(100 * hordeScore)
    end
    
    ---------------------------------------
    -- SCORE UTILITY FUNCTIONS
    ---------------------------------------
    function ScoreAPI:HasFactionScored(faction)
        if not FactionMap[faction] then
            error(format("%s (%s) is not an acceptable faction.", tostring(faction), type(faction)))
        end
        
        return scoreData[faction].lastPoints ~= scoreData[faction].points
    end
    
    function module:ScoreFrame_HasScore()
        return not not BattlegroundAPI:GetAttribute("modules","score")
    end
    
    ---------------------------------------
    -- WINNER FUNCTIONS
    ---------------------------------------
    function Score:SetWinner(newWinner,winTime)
        winnerData.winner = newWinner
        winnerData.winTime = winTime or -1
    end
    
    function ScoreAPI:GetWinner()
        return winnerData.winner
    end

    function Score:RefreshWinner(refresh, now)
        local hasNewWinner = module:EstablishWinner(refresh, now)
        if hasNewWinner then Score:UpdateWinner() end
    end

    function module:EstablishWinner(refresh, now)
        
        -- Establishing the winner
        local winner,winTime = BattlegroundAPI:RunAttribute({"establishWinner","func"}, now)
        local hasNewWinner = false
        if winner then
            if winner ~= ScoreAPI:GetWinner() then
                hasNewWinner = true
            elseif winTime and winTime ~= module:GetWinTime() then
                hasNewWinner = true
            end
        end
        
        -- UI update
        if hasNewWinner then
            Score:SetWinner(winner,winTime)
        
            -- Start score timer using the win time
            wintime = module:GetWinTime()
            if wintime > 0 then ScoreTimer:Start(wintime) end
            
            if addon:IsRunning() then module:InvokeWinnerPredictionCommands(winner) end
        end
        
        return hasNewWinner
        
    end
    
    function Score:UpdateWinner()
        local winner = Faction:Adjust(winnerData.winner)
        
        if winner == "alliance" then
            ScoreFrame.Alliance.Highlight:SetAlpha(1)
            ScoreFrame.Horde.Highlight:SetAlpha(0)
        elseif winner == "horde" then
            ScoreFrame.Alliance.Highlight:SetAlpha(0)
            ScoreFrame.Horde.Highlight:SetAlpha(1)
        else
            ScoreFrame.Alliance.Highlight:SetAlpha(0)
            ScoreFrame.Horde.Highlight:SetAlpha(0)
        end
    end
    
    function module:GetWinTime()
        local timelimit = BattlegroundAPI:GetAttribute("timelimit")
        
        if timelimit then
            return TIME_WARM_UP + timelimit - (GetBattlefieldInstanceRunTime()/1000)
        else
            return winnerData.winTime
        end
    end
end

---------------------------------------
-- NOT ENOUGH PLAYERS
---------------------------------------
do
    local function BattlegroundShutdown_OnUpdate(self,elapsed)        
        --print(elapsed)
        -- Battleground shutdown timer
        if BATTLEFIELD_SHUTDOWN_TIMER > 0 and not BattlegroundShutdown.ShutdownFired then
            BattlegroundShutdown.ShutdownFired = true
            BattlegroundAPI:SetModuleVariables({
                ["TimeOut"] = BATTLEFIELD_SHUTDOWN_TIMER,
            })
            module:FireBattlegroundEvent("NOT_ENOUGH_PLAYERS")
        end
        
        if BATTLEFIELD_SHUTDOWN_TIMER == 0 and BattlegroundShutdown.ShutdownFired then
            BattlegroundShutdown.ShutdownFired = false
            module:FireBattlegroundEvent("ENOUGH_PLAYERS")
        end
    end

    function BattlegroundShutdown:StartMonitor()
        BattlegroundShutdown.ShutdownFired = false
        BattlegroundShutdown.UpdateFrame:SetScript("OnUpdate",BattlegroundShutdown_OnUpdate)
    end
    
    function BattlegroundShutdown:StopMonitor()
        BattlegroundShutdown.UpdateFrame:SetScript("OnUpdate",nil)
    end
    
end

---------------------------------------
-- SCORE TIMER 
---------------------------------------
do
    local ScoreTimerAPI = {}
    BattlegroundAPI.ScoreTimer = ScoreTimerAPI
    
    local function HHMMSS(time)
        --%%.%df
        if time < 3600 and time >= 60 then
            time = floor(time)
            local min = floor(time/60)
            local sec = ceil(time % 60)
            
            return format("%d:%2d",min,sec):gsub("%s","0")
        elseif time >= 3600 then
            time = floor(time)
            local hr = floor(time/3600)
            local min = floor((time % 3600) / 60)
            local sec = ceil((time - 3600*hr - 60*min) % 60)
            
            return format("%d:%2d:%2d",hr,min,sec):gsub("%s","0")
        elseif time < 60 then       
            return format("%.2f",time)
        elseif time <= 0 then
            return ""    
        end
    end

    local lastTime = 0

    function ScoreTimer:SetText(time)
        if not time then
            ScoreFrame.Timer.Text:SetText("")
            return
        end
        
        if (lastTime < 3600 and time >= 3600) or (time < 3600 and lastTime >= 3600) then
            if time < 3600 then
                ScoreFrame.Timer.Text:SetFont("Fonts\\FRIZQT__.TTF",24, "OUTLINE")
            else
                ScoreFrame.Timer.Text:SetFont("Fonts\\FRIZQT__.TTF",18, "OUTLINE")
            end
        end
        
        ScoreFrame.Timer.Text:SetText(HHMMSS(time))
        lastTime = time
    end

    local scoreTimerEndTime
    local countUp
    local TimerState = {
        STOPPED = 0,
        PAUSED = 1,
        RUNNING = 2,
        
    }
    ScoreTimer.State = TimerState.STOPPED
    
    function ScoreTimer:GetTime()
        return (scoreTimerEndTime or 0) - GetTime()
    end

    local function ScoreFrameTimer_OnUpdate(self,elapsed)        
        -- Battleground timer
        if ScoreTimer.State == TimerState.RUNNING then
            local time = ScoreTimer:GetTime()
            
            if time < 0 then
                ScoreTimer:Stop()
            else
                ScoreTimer:SetText(time)
            end
        end
    end

    function ScoreTimer:Start(time,countup)
        ScoreTimer:SetTime(time)
        
        if ScoreTimer.State == TimerState.STOPPED then
            ScoreFrame.Timer.FireRingFrame:SetScript("OnUpdate",ScoreFrameTimer_OnUpdate)
        end
        
        if ScoreTimer.State ~= TimerState.RUNNING then
            ScoreTimer.State = TimerState.RUNNING
            countUp = countup or false
        end

        if not timerShown then
            addon:ShowScore("TIMER")
        end
    end
    ScoreTimerAPI.Start = ScoreTimer.Start

    function ScoreTimer:SetTime(time)
        scoreTimerEndTime = GetTime() + time
        ScoreTimer:SetText(time)
    end
    ScoreTimerAPI.SetTime = ScoreTimer.SetTime
    
    function ScoreTimer:Stop(clearText)
        ScoreTimer.State = TimerState.STOPPED
        ScoreFrame.Timer.FireRingFrame:SetScript("OnUpdate",nil)
        ScoreTimer:SetText(not clearText and 0 or nil)
    end

    function ScoreTimer:Pause()
        ScoreTimer.State = TimerState.PAUSED
    end
    
    ScoreTimerAPI.Pause = ScoreTimer.Pause

    function ScoreTimer:Clear()
        ScoreTimer:Stop(true)
    end
    ScoreTimerAPI.Clear = ScoreTimer.Clear

    function ScoreTimer:IsRunning()
        return (ScoreTimer.State == TimerState.RUNNING),UIloaded
    end
end

---------------------------------------
-- SCORE SLOTS
---------------------------------------
do
    local slotPool = {}
    local slotCount = 0

    local HandleSlotSafeActions

    local slotsData = {}
    function ScoreSlots:UnpackData()
        return slotCount, slotsData.texts, slotsData.colors, slotsData.flashing, slotsData.actions, slotsData.textOnly
    end
    
    function ScoreSlots:SetData(texts, colors, flashing, actions, textOnly)
        slotsData.texts = texts
        slotsData.colors = colors
        slotsData.flashing = flashing
        slotsData.actions = actions
        slotsData.textOnly = textOnly
    end
    
    function GetData()
        return slotsData
    end
    
    function ScoreSlots:IsSlotTextOnly(slotIndex)
        local SlotTextOnly = slotsData.textOnly
        
        if SlotTextOnly == true then
            return true
        elseif type(SlotTextOnly) == "table" and SlotTextOnly[slotIndex] == true then
            return true
        else
            return false
        end
    end

    function ScoreSlots:Create(count, slotTexts, slotColors, slotActions, slotTextOnly, dimensions, offsets)
        -- Hiding all slots
        ScoreSlots:Hide()

        slotCount = count
        local maxwidth = ScoreFrame.border:GetWidth()
        local width = maxwidth/count
        local maxtotalwidth = 0
        local leftoffset = 0

        if dimensions.widthMult then
            if type(dimensions.widthMult) == "table" then
                for i=1,count do maxtotalwidth = maxtotalwidth + (dimensions.widthMult and dimensions.widthMult[i] or 1)*width end
            elseif type(dimensions.widthMult) == "number" then
                maxtotalwidth = maxtotalwidth + dimensions.widthMult*width*count
            end
        else
            maxtotalwidth = maxtotalwidth + width*count
        end
        
        local updateMacrosLater = UnitAffectingCombat("player")
        
        
        for i=1,count do
            local slot
            local name = "DXE Score Slot "..i
            
            -- Creating slot frame
            if not slotPool[i] then
                slot = CreateFrame("Button",name, ScoreFrame)
                slot.texture = slot:CreateTexture(nil,"OVERLAY",nil,2)
                slot.text = slot:CreateFontString(nil, "OVERLAY")
                if updateMacrosLater then 
                    slot.macro = {}
                else
                    slot.macro = CreateFrame("Button", format("DXE Score Slot Button %s",i), UIParent, "SecureActionButtonTemplate")
                end
                slot.highlight = slot:CreateTexture(nil,"OVERLAY")
                slot.fadein = slot:CreateAnimationGroup()
                
                local a1 = slot.fadein:CreateAnimation("Alpha")
                a1:SetOrder(1)
                a1:SetDuration(0.5)
                a1:SetChange(1)
                a1:SetStartDelay(0.03125*(i-1))
                slot.fadein:SetScript("OnPlay",function() 
                    slot.text:SetAlpha(1)
                end)
                slot.fadein:SetScript("OnFinished",function() slot:SetAlpha(1) end)
                
                slotPool[i] = slot
            else
                slot = slotPool[i]
            end
            
            slot:RegisterForClicks("RightButtonUp","LeftButtonUp","MiddleButtonUp")
            slot:SetScript("OnClick", HandleSlotSafeActions)
            slot:EnableMouse(false)
            
            local offsetX = 0
            local offsetY = 35
            if offsets.offsets then
                if type(offsets.offsets) == "table" then
                    if type(offsets.offsets[1]) == "table" then
                        offsetX = offsetX + offsets.offsets[1][i] or 0
                        if type(offsetX) == "string" then
                            local mult = tonumber(offsetX:match("^(.+)x$"))
                            if not mult then mult = 1 end
                            offsetX = offsetX + mult * width
                        end
                    else
                        offsetX = offsetX + offsets.offsets[1] or 0
                    end
                    if type(offsets.offsets[2]) == "table" then
                        offsetY = offsetY + offsets.offsets[2][i] or 0
                        if type(offsetY) == "string" then
                            local mult = tonumber(offsetY:match("^(.+)x$"))
                            if not mult then mult = 1 end
                            offsetY = offsetY + mult * width
                        end
                    else
                        offsetY = offsetY + offsets.offsets[2] or 0
                    end
                end
            end
            
            local slotHeight
            if type(dimensions.height) == "table" then
                slotHeight = dimensions.height[i]
            else
                slotHeight = dimensions.height
            end
            
            if offsets.offsetMults then
                if type(offsets.offsetMults) == "table" then
                    offsetX = offsetX + (offsets.offsetMults[1][i] or 0) * width
                    offsetY = offsetY + (offsets.offsetMults[2][i] or 0) * slotHeight
                end
            end
            
            slot:ClearAllPoints()
            slot:SetPoint("TOPLEFT",ScoreFrame,"BOTTOM",-maxtotalwidth/2 + leftoffset + offsetX, offsetY)
            local widthMult
            if dimensions.widthMult then
                if type(dimensions.widthMult) == "table" then
                    widthMult = dimensions.widthMult[i] or 1
                else
                    widthMult = dimensions.widthMult
                end
            else
                widthMult = 1
            end
            
            slot:SetWidth(width*widthMult)
            leftoffset = leftoffset + width*widthMult
            
            slot:SetHeight(slotHeight)
            slot:SetFrameStrata("HIGH")
            
            -- Slot Background texture
            local texture = slot.texture
            texture:SetWidth(widthMult*width-8)
            texture:SetHeight(slotHeight-6)
            texture:ClearAllPoints()
            texture:SetPoint("CENTER",slot,"CENTER",0,0)
            texture:SetDrawLayer("BACKGROUND",0)
            if slotColors and slotColors[i] then
                ScoreSlots:SetSlotColor(i, slotColors[i])
            else
                ScoreSlots:SetSlotColor(i, Colors.unknown)
            end

            -- Slot Text
            local text = slot.text
            text:SetFont(SM:Fetch("font",pfl.ScoreSlotsFont), 14)
            text:SetShadowColor(0,0,0,0.75)
            text:SetShadowOffset(2, -2)
            text:SetAlpha(0)
            
            if slotTexts and slotTexts[i] then text:SetText(slotTexts[i]) end
            text:SetWidth(1.5*widthMult*width)
            text:SetHeight(slotHeight)
            text:ClearAllPoints()
            text:SetPoint("CENTER",slot,"CENTER",0,0)
            text:SetDrawLayer("ARTWORK",1)
            
            -- Slot Flash Highlight
            local highlight = slot.highlight
            highlight:SetTexture("Interface\\OPTIONSFRAME\\21STEPGRAYSCALE")
            highlight:SetTexCoord(0.75,0,0,1)
            highlight:SetWidth(widthMult*(width/2))
            highlight:SetHeight(slotHeight)
            highlight:ClearAllPoints()
            highlight:SetPoint("TOPLEFT",slot,"TOPLEFT",0,0)
            highlight:SetBlendMode("ADD")
            highlight:SetDrawLayer("BACKGROUND",2)
            highlight:SetAlpha(0)
            
            
            if slotTextOnly then
                local textOnly
                if type(slotTextOnly) == "table" then
                    textOnly = slotTextOnly[i]
                elseif type(slotTextOnly) == "boolean" then
                    textOnly = slotTextOnly
                end
                
                if not textOnly then
                    slot.highlight:Show()
                    slot.texture:Show()
                    slot.textOnly = false
                else
                    slot.highlight:Hide()
                    slot.texture:Hide()
                    slot.textOnly = true
                end
                
            else
                slot.highlight:Show()
                slot.texture:Show()
                slot.textOnly = false
            end
            
            -- Slot Macro Button
            if not updateMacrosLater then
                local macro = slot.macro
                macro:SetScale(0.7)
                macro:ClearAllPoints()
                macro:SetWidth(slot:GetWidth())
                macro:SetHeight(slot:GetHeight())
                macro:SetPoint("TOPLEFT",UIParent,"TOPLEFT",slot:GetLeft(),slot:GetTop())
                macro:SetFrameStrata("DIALOG")
                macro:SetAttribute("type", "macro")
                
                -- Setting up the macro button commands
                if slotActions then
                    local action = slotActions[i]
                    if action then
                        local actionType = action[1]
                        
                        if actionType == "macro" then
                            macro:SetAttribute("macrotext", slotMacros[i] or "")
                            macro:EnableMouse(slotMacros[i] ~= "")
                        else
                            macro:EnableMouse(false)
                        end
                    else
                        macro:EnableMouse(false)
                    end
                end
                
                macro:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",slot:GetLeft(),slot:GetTop())
                macro:SetAlpha(1)
                macro:Show()
            else
                slot.combatUpdate = slot.combatUpdate or {}
                slot.combatUpdate.createMacro  = true
                slot.combatUpdate.newMacroText = slotMacros and slotMacros[i]
                
                ScoreSlots:RegisterEvent("PLAYER_REGEN_ENABLED")
            end
            
            -- Setting up the slot button commands
            if slotActions then
                local action = slotActions[i]
                if action then
                    local actionType = action[1]
                    
                    if not module:SetSlotSafeAction(i,actionType, action[2]) then
                        slot:EnableMouse(false)
                    end
                else
                    slot:EnableMouse(false)
                end
            end
            
            slot:SetAlpha(0)
            slot:Hide()
        end
    end
    
    function ScoreSlots:Setup(slotData)
        local count = TraverseTable(slotData, "count") or BattlegroundAPI:GetAttribute("slots", "count")
        
        local slotTexts    = TraverseTable(slotData, "texts")    or BattlegroundAPI:GetAttribute("slots", "texts")
        local slotColors   = TraverseTable(slotData, "colors")   or BattlegroundAPI:GetAttribute("slots", "colors")
        local slotActions  = TraverseTable(slotData, "actions")  or BattlegroundAPI:GetAttribute("slots", "actions")
        local slotTextOnly = TraverseTable(slotData, "textOnly") or BattlegroundAPI:GetAttribute("slots", "textOnly")
        
        local dimensions = {
            width      = TraverseTable(slotData, "width")      or BattlegroundAPI:GetAttribute("slots", "width"),
            height     = TraverseTable(slotData, "height")     or BattlegroundAPI:GetAttribute("slots", "height"),
            widthMult  = TraverseTable(slotData, "widthmult")  or BattlegroundAPI:GetAttribute("slots", "widthmult"),
            heightMult = TraverseTable(slotData, "heightmult") or BattlegroundAPI:GetAttribute("slots", "heightmult"),
        }
        local offsets = {
            offsets     = TraverseTable(slotData, "offsets")     or BattlegroundAPI:GetAttribute("slots", "offsets"),
            offsetMults = TraverseTable(slotData, "offsetmults") or BattlegroundAPI:GetAttribute("slots", "offsetmults"),
        }
        
        -- Fill-in default colors
        if not slotColors then
            slotColors = {}
            for i=1,count do
                slotColors[i] = "unknown"
            end
        end
        
        ScoreSlots:SetData(slotTexts and addon:CopyTable(slotTexts) or {}, slotColors, {}, slotActions or {}, slotTextOnly or {})
        
        -- Converting faction values
        slotTexts    = adjustFactionOrder(slotTexts)
        slotColors   = adjustFactionOrder(slotColors)
        slotActions  = adjustFactionOrder(slotActions)
        slotTextOnly = adjustFactionOrder(slotTextOnly)
                
        ScoreSlots:Create(count, slotTexts, slotColors, slotActions, slotTextOnly, dimensions, offsets)
    end

    function ScoreSlots:Hide()
        for i=1,#slotPool do
            ScoreSlots:StopSlotFlashing(i)
            slotPool[i].texture:SetVertexColor(1, 1, 1, pfl.ScoreSlotsTextureAlpha)
            slotPool[i]:Hide()
        end
    end

    function module:ScoreSlots_Show()
        for i=1,slotCount do
            local slot = slotPool[i]
            slot.fadein:Play()
            if pfl.ShowSlots 
              and (TestMode or addon.db.profile.Encounters[CE.key].battleground.ShowScoreSlots) then
                slot:Show()
            end
        end
    end


    function ScoreSlots:PLAYER_REGEN_ENABLED()
        for i,slot in pairs(slotPool) do
            local combatUpdate = slot.combatUpdate
            if combatUpdate then
                if combatUpdate.createMacro then
                    local macro = CreateFrame("Button", format("DXE Score Slot Button %s",i), UIParent, "SecureActionButtonTemplate")
                    macro:SetScale(0.7)
                    macro:ClearAllPoints()
                    macro:SetWidth(slot:GetWidth())
                    macro:SetHeight(slot:GetHeight())
                    macro:SetPoint("TOPLEFT",UIParent,"TOPLEFT",slot:GetLeft(),slot:GetTop())
                    macro:SetFrameStrata("DIALOG")
                    macro:SetAttribute("type", "macro")
                    macro:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",slot:GetLeft(),slot:GetTop())
                    macro:EnableMouse(false)
                    slot:EnableMouse(true)
                    slot.macro = macro
                    combatUpdate.createMacro = nil
                end
                local macro = slot.macro
                if combatUpdate.newMacroText then
                    macro:SetAttribute("macrotext",combatUpdate.newMacroText)
                    local showMacro = combatUpdate.newMacroText ~= ""
                    macro:EnableMouse(showMacro)
                    slot:EnableMouse(false)
                    combatUpdate.newMacroText = nil
                else
                    macro:EnableMouse(false)
                end
            end
        end
                
        ScoreSlots:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
    
    function ScoreSlots:SetSlotText(slotIndex, text, offsetX, offsetY)
        if slotIndex > slotCount then return end
        local slot = slotPool[slotIndex]
        
        slot.text:SetText(text)
        local _, _, _, curOffsetX, curOffsetY = slot.text:GetPoint(1)
        offsetX = offsetX or curOffsetX
        offsetY = offsetY or curOffsetY
        
        slot.text:ClearAllPoints()
        slot.text:SetPoint("CENTER",slot,"CENTER",offsetX,offsetY)
    end

    function ScoreSlots:SetSlotColor(slotIndex, color)
        if slotIndex > slotCount then return end
        color = type(color) == "string" and pfl.Colors[color] or color
        slotPool[slotIndex].texture:SetVertexColor(color.r or 1, color.g or 1, color.b or 1, pfl.ScoreSlotsTextureAlpha)
        if pfl.ScoreBorderUpdateColors then
            slotPool[slotIndex].obr = color.r or 1
            slotPool[slotIndex].obg = color.g or 1
            slotPool[slotIndex].obb = color.b or 1
            slotPool[slotIndex]:SetBackdropBorderColor(color.r or 1, color.g or 1, color.b or 1, pfl.ScoreSlotsBorderAlpha)
        else
            local bc = pfl.ScoreSlotBorderColor
            slotPool[slotIndex]:SetBackdropBorderColor(bc[1] or 1, bc[2] or 1, bc[3] or 1, pfl.ScoreSlotsBorderAlpha)
        end
    end

    function ScoreSlots:SetFlashColor(slotIndex, color)
        local colorType = type(color)
        if color and (colorType == "table" or (colorType == "string" and color ~= "")) then
            ScoreSlots:FlashSlot(slotIndex, color)
        else
            ScoreSlots:StopSlotFlashing(slotIndex)
        end
    end

    local function GetCurretAlpha()
        for i=1,slotCount do
            local highlight = slotPool[slotIndex].highlight
            
        end
        
        return 0
    end

    function ScoreSlots:FlashSlot(slotIndex, color)
        color = type(color) == "string" and pfl.FlashColors[color] or color
        if slotIndex > slotCount then return end
        
        local highlight = slotPool[slotIndex].highlight
        highlight:SetVertexColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
        if highlight.flash and (highlight.flash:IsPlaying() or highlight.playing) then return end
        
        highlight:SetAlpha(0)
        highlight.flash = highlight:CreateAnimationGroup()
        highlight.playing = true
        
        local a1 = highlight.flash:CreateAnimation("Alpha")
        local a2 = highlight.flash:CreateAnimation("Alpha")
        
        a1:SetOrder(1)
        a1:SetDuration(0.5)
        a1:SetChange(1)
        
        a2:SetOrder(2)
        a2:SetDuration(0.5)
        a2:SetChange(-1)

        highlight.flash:SetLooping("REPEAT")
        highlight.flash:Play()
    end

    function ScoreSlots:StopSlotFlashing(slotIndex)
        if slotIndex > slotCount then return end
        
        local highlight = slotPool[slotIndex].highlight
        if not highlight.flash then return end
        
        highlight.flash:Stop()
        highlight.playing = nil
        highlight:SetAlpha(0)
    end

    function module:ScoreSlots_RefreshSetup(globalOnly)
        -- Global refresh
        for i=1,slotCount do
            local slot = slotPool[i]
            if slot.textOnly then
                slot:SetBackdrop(nil)
            else
                slot:SetBackdrop({
                    edgeSize = pfl.ScoreSlotsBorderEdge,
                    edgeFile = SM:Fetch("border",pfl.ScoreSlotsBorder),
                })
                if pfl.ScoreBorderUpdateColors then
                    if not slot.obr and not slot.obg and not slot.obb then
                        local br, bg, bb = slot:GetBackdropBorderColor()
                        slot:SetBackdropBorderColor(br or 1, bg or 1, bb or 1, pfl.ScoreSlotsBorderAlpha)
                        slot.obr = br
                        slot.obg = bg
                        slot.obb = bb
                    else
                        slot:SetBackdropBorderColor(slot.obr, slot.obg, slot.obb, pfl.ScoreSlotsBorderAlpha)
                    end
                else
                    local bc = pfl.ScoreSlotBorderColor
                    slot:SetBackdropBorderColor(bc[1] or 1, bc[2] or 1, bc[3] or 1, pfl.ScoreSlotsBorderAlpha)
                end
            end
            slot.texture:SetTexture(SM:Fetch("statusbar",pfl.ScoreSlotsTexture))
            slot.texture:SetAlpha(pfl.ScoreSlotsTextureAlpha)
            
            slot.text:SetFont(SM:Fetch("font",pfl.ScoreSlotsFont), 14)
            
            if globalOnly then
                if pfl.ShowSlots and (TestMode or addon.db.profile.Encounters[CE.key].battleground.ShowScoreSlots) then
                    slot:Show()
                else
                    slot:Hide()
                end
            else
                ScoreSlots:Refresh()
            end
        end
    end

    function ScoreSlots:Refresh(ignoreUWS) -- (UWS = UPDATE_WORLD_STATES event)
        if ignoreUWS then
            local now = GetTime()
            local updateData = LaterUpdates[now]
            if updateData then
                updateData.cancel = true
            end
        end
        
        ScoreSlots:UpdateData()
        ScoreSlots:UpdateFrames()
    end
    
    function BattlegroundAPI:RefreshSlots()
        ScoreSlots:Refresh(true)
    end
    
    function ScoreSlots:UpdateData()
        -- Update the source data
        BattlegroundModules:Run("updateData")
        
        -- Update the slots data
        BattlegroundModules:RunInSequence("refreshSlots",ScoreSlots:UnpackData())
        BattlegroundAPI:RunModuleAttribute({"slots","refresh"},ScoreSlots:UnpackData())
    end
    
    local function AdjustIndex(slotIndex)
        -- Translate slot index using the index guide
        local indexGuide = BattlegroundAPI:GetAttribute("slots","indexGuide")
        local newIndex = slotIndex
        if indexGuide then newIndex = indexGuide[newIndex] or newIndex end
        
        -- Reverse the index order if necessary
        if not TestMode and not BattlegroundAPI:GetAttribute("slots","disallowFactionSwitching")
          and not addon.db.profile.Encounters[CE.key].battleground.DisableSlotFactionSwitching then
            local amAlliance       = Faction:Of("player") == "alliance"
            local isHomeLeft       = Faction:GetHomeTeamLocation() == "LEFT"
            local allianceIsHome   = amAlliance == isHomeLeft
            local count = BattlegroundAPI:GetAttribute("slots","count")
            local factionSwitchingIndex = BattlegroundAPI:GetAttribute("slots","factionSwitchingIndex")
            if not allianceIsHome then
                if factionSwitchingIndex then
                    newIndex = factionSwitchingIndex[newIndex]
                else
                    newIndex = count - newIndex + 1
                end
            end
        end
        
        return newIndex
    end
    
    function ScoreSlots:UpdateFrames()
        local offsets = BattlegroundAPI:GetAttribute("slots","textOffsets")
        local slotCount, texts, colors, flashing, actions = ScoreSlots:UnpackData()
       
        texts =    adjustFactionOrder(texts)
        colors =   adjustFactionOrder(colors)
        actions =  adjustFactionOrder(actions)
        flashing = adjustFactionOrder(flashing)
        
        
        for slotIndex=1,slotCount do
            local adjIndex = AdjustIndex(slotIndex)
            local offsetX = offsets and (offsets[1][adjIndex] or 0) or 0
            local offsetY = offsets and (offsets[2][adjIndex] or 0) or 0
            
            if texts[adjIndex] then ScoreSlots:SetSlotText(slotIndex, texts[adjIndex], offsetX, offsetY) end
            if colors[adjIndex] then ScoreSlots:SetSlotColor(slotIndex, colors[adjIndex]) end
            ScoreSlots:SetFlashColor(slotIndex, flashing[adjIndex])
            if actions[adjIndex] then module:SetSlotAction(slotIndex, actions[adjIndex].type or actions[adjIndex][1], actions[adjIndex].arg or actions[adjIndex][2]) end
        end
    end

    function module:ShowSlotsOnly()
        ScoreFrame.Timer.Frame:SetAlpha(0)
        ScoreFrame.Timer.FireRingFrame:SetAlpha(0)
        ScoreFrame.border:SetAlpha(0)
        ScoreFrame.Alliance.Texture:SetAlpha(0)
        ScoreFrame.Horde.Texture:SetAlpha(0)
        ScoreFrame.Alliance.Text:SetAlpha(0)
        ScoreFrame.Horde.Text:SetAlpha(0)
        ScoreFrame.Alliance.Logo:SetAlpha(0)
        ScoreFrame.Horde.Logo:SetAlpha(0)
        ScoreFrame.Alliance.Highlight:SetAlpha(0)
        ScoreFrame.Horde.Highlight:SetAlpha(0)
        ShowSlotsAnimation()
        if not timerShown and not panelsShown then
            for i=1,slotCount do
                local slot = slotPool[i]
                local _,_,_,xOffset,yOffset = slot:GetPoint(1)
                slot:ClearAllPoints()
                slot:SetPoint("TOPLEFT",DXEScoreFrameAnchor,"TOP",xOffset,-33)
            end
        end
    end

    ---------------------------------------
    -- SCORE SLOTS - ACTIONS
    ---------------------------------------
    local SAFE_ACTIONS = {
        ["base-help"] = true,
    }

    local baseTimers = {}
    local baseAttackersCounters = {}

    function module:SetSlotMacro(slotIndex, macroText)
        if slotIndex > slotCount then return false end
        local slot = slotPool[slotIndex]
        
        if not UnitAffectingCombat("player") then
            local macro = slot.macro
            macro:SetAttribute("macrotext", macroText)
            macro:EnableMouse(macroText ~= "")
        else
            slot.combatUpdate = slot.combatUpdate or {}
            slot.combatUpdate.newMacroText = macroText
            
            ScoreSlots:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
        slot:EnableMouse(false)
        
        return true
    end

    function ScoreSlots:ClearMacros()
        if UnitAffectingCombat("player") then return end
        
        for i=1,#slotPool do
            module:SetSlotMacro(i, "")
            slotPool[i]:Hide()
        end
    end

    function module:SetSlotSafeAction(slotIndex, actionType, actionParameter)
        if not SAFE_ACTIONS[actionType] then return false end
        if slotIndex > slotCount then return false end
        
        local slot = slotPool[slotIndex]
        slot.actionType = actionType
        slot.actionParameter = actionParameter
        slot:EnableMouse(true)
        
        return true
    end
    
    function module:SetSlotAction(slotIndex, actionType, actionParameter)
        if slotIndex > slotCount then return false end
        
        if actionType == "macro" then
            return module:SetSlotMacro(slotIndex, actionParameter)
        elseif SAFE_ACTIONS[actionType] then
            return module:SetSlotSafeAction(slotIndex, actionType, actionParameter)
        end
    end

    function module:ReportAttack(baseName)
        local count = baseAttackersCounters[baseName]
        count = count < 10 and count or 1
        local text
        if count == 1 then
            text = pfl.Pattern.Incoming:gsub("{baseName}",baseName)
        elseif count >= 2 then
            text = pfl.Pattern.IncomingSpecific:gsub("{baseName}",baseName):gsub("{playerCount}",count)
        end
        
        SendChatMessage(text, "Battleground")
        baseAttackersCounters[baseName] = 0
        baseTimers[baseName] = nil
    end

    HandleSlotSafeActions = function (self, button, ...)
        -- Calling out for help to defend the base
        if self.actionType == "base-help" then
            local baseName = self.actionParameter
            if button == "LeftButton" then
                if baseTimers[baseName] then
                    module:CancelTimer(baseTimers[baseName],true)
                end
                baseTimers[baseName] = module:ScheduleTimer("ReportAttack",1,baseName)
                
                if not baseAttackersCounters[baseName] then
                    baseAttackersCounters[baseName] = 1
                else
                    baseAttackersCounters[baseName] = baseAttackersCounters[baseName] + 1
                end
            elseif button == "RightButton" then
                local text = pfl.Pattern.Safe:gsub("{baseName}",baseName)
                SendChatMessage(text, "Battleground")
            elseif button == "MiddleButton" then
                local text = pfl.Pattern.UnderAttack:gsub("{baseName}",baseName)
                SendChatMessage(text, "Battleground")
            end
        end
    end
end

---------------------------------------
-- SCORE CAPTURE BAR
---------------------------------------
do
    function CaptureBar:Skin()
        local CaptureFrame = CaptureBar.Frame
        if not CaptureFrame then return end
        
        CaptureFrame:SetBackdrop({
            edgeSize = pfl.CaptureBarBorderEdge,
            edgeFile = DXE.SM:Fetch("border",pfl.CaptureBarBorder),
        })
        
        CaptureFrame.TextureNeutral:SetTexture(DXE.SM:Fetch("statusbar",pfl.CaptureBarTexture))
        CaptureFrame.TextureAlliance:SetTexture(DXE.SM:Fetch("statusbar",pfl.CaptureBarTexture))
        CaptureFrame.TextureHorde:SetTexture(DXE.SM:Fetch("statusbar",pfl.CaptureBarTexture))
    end
    
    function CaptureBar:AdjustFactions()
        local CaptureFrame = CaptureBar.Frame
        if not CaptureFrame then return end
        
        local allianceIsHome = Faction:IsAllianceHome()
        local anchor1 = allianceIsHome and "RIGHT" or "LEFT"
        local anchor2 = allianceIsHome and "LEFT" or "RIGHT"
        
        CaptureFrame.TextureAlliance:ClearAllPoints()
        CaptureFrame.TextureAlliance:SetPoint(anchor1,CaptureFrame.TextureNeutral,anchor2)
        CaptureFrame.TextureHorde:ClearAllPoints()
        CaptureFrame.TextureHorde:SetPoint(anchor2,CaptureFrame.TextureNeutral,anchor1)
    end
    
    function CaptureBar:Update()
        if not pfl.EnableCaptureBar then
            CaptureBar:Hide()
            return
        end
        
        for i=1,GetNumWorldStateUI() do
            local _, state, _, _, _, _, _, _, extendedUI, value, neutralPercent = GetWorldStateUIInfo(i)
            if extendedUI == "CAPTUREPOINT" then
                if state == 1 then
                    CaptureBar:Show()
                    CaptureBar:SetValue(value)
                else
                    CaptureBar:Hide()
                end
                break
            end
        end
        
        for i=1, NUM_EXTENDED_UI_FRAMES do
            frame = _G["WorldStateCaptureBar"..i]
            if frame then frame:Hide() end
        end
    end
    
    function CaptureBar:SetValue(value)
        local CaptureFrame = CaptureBar.Frame
        local Indicator = CaptureFrame.Indicator
        
        local effectiveFaction = Faction:Of("player")
        local preferredFaction = Faction:GetPreferred()
        local isAlliance = effectiveFaction == "alliance"
        local isHomeLeft = Faction:GetHomeTeamLocation() == "LEFT"
        
        local adjustedValue = (isAlliance == isHomeLeft) and value or (100 - value)
        local position = (CaptureFrame:GetWidth() * adjustedValue) / 100
        if not CaptureBar.oldPosition then CaptureBar.oldPosition = position end
        
        -- Update direction arrows
        local showLeft = position > CaptureBar.oldPosition
        local showRight = position < CaptureBar.oldPosition
        if showLeft then CaptureFrame.ArrowLeft:Show() else CaptureFrame.ArrowLeft:Hide() end
        if showRight then CaptureFrame.ArrowRight:Show() else CaptureFrame.ArrowRight:Hide() end
        
        -- Update highlights
        if preferredFaction == effectiveFaction then
            showAllianceHighlight = value > 70
            showHordeHighlight    = value < 30
        else
            showAllianceHighlight = value < 30
            showHordeHighlight    = value > 70
        end
        
        if showAllianceHighlight then 
            CaptureFrame.HighlightAlliance:Show()
            CaptureFrame.TextureAlliance:SetAlpha(1)
        else
            CaptureFrame.HighlightAlliance:Hide()
            CaptureFrame.TextureAlliance:SetAlpha(0.35)
        end
        
        if showHordeHighlight then
            CaptureFrame.HighlightHorde:Show()
            CaptureFrame.TextureHorde:SetAlpha(1)
        else
            CaptureFrame.HighlightHorde:Hide()
            CaptureFrame.TextureHorde:SetAlpha(0.35)
        end
        
        if showAllianceHighlight or showHordeHighlight then
            CaptureFrame.TextureNeutral:SetAlpha(0.35)
        else
            CaptureFrame.TextureNeutral:SetAlpha(1)
        end
        
        -- Set the indicator position
        Indicator:ClearAllPoints()
        Indicator:SetPoint("CENTER",CaptureFrame,"RIGHT",-position,0)
        
        CaptureBar.oldPosition = position
    end
    
    function CaptureBar:Show()
        if not CaptureBar.Frame then 
            CaptureBar:Create()
            CaptureBar:Skin()
            CaptureBar:AdjustFactions()
        end
        
        if not CaptureBar.Frame:IsShown() then CaptureBar.Frame:Show() end
    end
    
    function CaptureBar:Hide()
        if CaptureBar.Frame then CaptureBar.Frame:Hide() end
    end

    function CaptureBar:Create()
        -- Capture Bar (Border)
        local CaptureFrame = CreateFrame("Frame","DXE Score Capture Bar",ScoreFrame)
        CaptureFrame:ClearAllPoints()
        CaptureFrame:SetPoint("CENTER",ScoreFrame.Timer.FireRingTexture,"CENTER",0,-35)
        CaptureFrame:SetWidth(350)
        CaptureFrame:SetHeight(15)
        CaptureFrame:SetFrameStrata("HIGH")
        CaptureBar.Frame = CaptureFrame
        
        -- Background (Neutral)
        local TextureNeutral = CaptureFrame:CreateTexture(nil, "OVERLAY", nil, 4)
        TextureNeutral:SetWidth(140)
        TextureNeutral:SetHeight(10)
        TextureNeutral:SetVertexColor(1,1,1,1)
        TextureNeutral:SetBlendMode("DISABLE")
        TextureNeutral:SetDrawLayer("BACKGROUND",-8)
        TextureNeutral:ClearAllPoints()
        TextureNeutral:SetPoint("CENTER",ScoreFrame.Timer.FireRingTexture,"CENTER",0,-35)
        CaptureFrame.TextureNeutral = TextureNeutral
        
        -- Background (Alliance)
        local TextureAlliance = CaptureFrame:CreateTexture(nil, "OVERLAY", nil, 4)
        TextureAlliance:SetWidth(105)
        TextureAlliance:SetHeight(10)
        TextureAlliance:SetVertexColor(0,0.75,1,1)
        TextureAlliance:SetBlendMode("DISABLE")
        TextureAlliance:SetDrawLayer("BACKGROUND",-8)
        CaptureFrame.TextureAlliance = TextureAlliance
        
        -- Background (Horde)
        local TextureHorde = CaptureFrame:CreateTexture(nil, "OVERLAY", nil, 4)
        TextureHorde:SetWidth(105)
        TextureHorde:SetHeight(10)
        TextureHorde:SetVertexColor(0.75,0,0,1)
        TextureHorde:SetBlendMode("DISABLE")
        TextureHorde:SetDrawLayer("BACKGROUND",-8)
        CaptureFrame.TextureHorde = TextureHorde
        
        -- Highlight (Alliance)
        local HighlightAlliance = CaptureFrame:CreateTexture(nil,"OVERLAY", nil, 5)
        HighlightAlliance:SetTexture("Interface\\BUTTONS\\UI-ActionButton-Border")
        HighlightAlliance:SetTexCoord(0.21,0.77,0.23,0.78)
        HighlightAlliance:ClearAllPoints()
        HighlightAlliance:SetPoint("CENTER",TextureAlliance,"CENTER",0,0)
        HighlightAlliance:SetWidth(105)
        HighlightAlliance:SetHeight(10)
        HighlightAlliance:SetBlendMode("ADD")
        HighlightAlliance:SetDrawLayer("BACKGROUND",-7)
        HighlightAlliance:SetVertexColor(0,0.75,1,1)
        CaptureFrame.HighlightAlliance = HighlightAlliance
        
        -- Highlight (Horde)
        local HighlightHorde = CaptureFrame:CreateTexture(nil,"OVERLAY", nil, 5)
        HighlightHorde:SetTexture("Interface\\BUTTONS\\UI-ActionButton-Border")
        HighlightHorde:SetTexCoord(0.21,0.77,0.23,0.78)
        HighlightHorde:ClearAllPoints()
        HighlightHorde:SetPoint("CENTER",TextureHorde,"CENTER",0,0)
        HighlightHorde:SetWidth(105)
        HighlightHorde:SetHeight(10)
        HighlightHorde:SetBlendMode("ADD")
        HighlightHorde:SetDrawLayer("BACKGROUND",-7)
        HighlightHorde:SetVertexColor(1,0,0,1)
        CaptureFrame.HighlightHorde = HighlightHorde
        
        -- Indicator
        local Indicator = CaptureFrame:CreateTexture(nil,"OVERLAY", nil, 6)
        Indicator:SetTexture("Interface\\WorldStateFrame\\WorldState-CaptureBar")
        Indicator:SetTexCoord(0.77734375, 0.796875, 0, 0.28125)
        Indicator:SetWidth(5)
        Indicator:SetHeight(18)
        Indicator:SetDrawLayer("OVERLAY",3)
        CaptureFrame.Indicator = Indicator
        
        -- Direction Arrow (Left)
        local ArrowLeft = CaptureFrame:CreateTexture(nil,"OVERLAY", nil, 6)
        ArrowLeft:SetTexture("Interface\\WorldStateFrame\\WorldState-CaptureBar")
        ArrowLeft:SetTexCoord(0.7265625, 0.76171875, 0.140625, 0.375)
        ArrowLeft:SetWidth(16)
        ArrowLeft:SetHeight(30)
        ArrowLeft:ClearAllPoints()
        ArrowLeft:SetPoint("RIGHT",Indicator,"LEFT",1,0)
        ArrowLeft:SetDrawLayer("OVERLAY",3)
        CaptureFrame.ArrowLeft = ArrowLeft
        
        -- Direction Arrow (Right)
        local ArrowRight = CaptureFrame:CreateTexture(nil,"OVERLAY", nil, 6)
        ArrowRight:SetTexture("Interface\\WorldStateFrame\\WorldState-CaptureBar")
        ArrowRight:SetTexCoord(0.76171875, 0.7265625, 0.140625, 0.375)
        ArrowRight:SetWidth(16)
        ArrowRight:SetHeight(30)
        ArrowRight:ClearAllPoints()
        ArrowRight:SetPoint("LEFT",Indicator,"RIGHT",-1,0)
        ArrowRight:SetDrawLayer("OVERLAY",3)
        CaptureFrame.ArrowRight = ArrowRight
    end

end

---------------------------------------
-- API
---------------------------------------
do
    function addon:ShowScore(state)
        if not addon.db.profile.Enabled then return end
        if TestMode then addon:TestScore() end
        
        local hasScore = module:ScoreFrame_HasScore()
        
        module:Battleground_Reset()
        module:ScoreFrame_Reset()
            
        if hasScore and (state == "ALL" or state == "SCORE")  then
            module:ScoreFrame_Refresh(true)
        end
        
        if pfl.Enabled then 
            if not UnitAffectingCombat("player") then
                WorldStateAlwaysUpFrame:Hide()
            else
                hideBlizzScoreLater = true
                module:RegisterEvent("PLAYER_REGEN_ENABLED")
            end
            ScoreFrame:Show() 
        end
        
        ScoreSlots:Setup()
        module:ScoreFrame_AdaptFactions()
        
        if state == "ALL" and hasScore then
            showFrame = true
            if timerShown then 
                addon:ShowScore("SCORE")
            else
                timerShown = true
                panelsShown = true
                ShowScoreAnimation:Play()
            end
        elseif state == "TIMER" or not hasScore then
            if not timerShown then ShowScoreGlobeAnimation:Play() end
            if state == "ALL" then ShowSlotsAnimation() end
            timerShown = true
            showFrame = true
        elseif state == "SCORE" and hasScore then
            ShowScorePanelsAnimation:Play()
            panelsShown = true
            showFrame = true
        end
    end
    
    function addon:TestScore()
        if not TestMode then
            TestMode = true
            ScoreFrame:Show() 
            ShowScoreAnimation:Play()
            showFrame = true
            timerShown = true
            panelsShown = true
            Score:Reset()
            BattlegroundAPI.Score:SetPointsFor("alliance", 230, GetTime())
            BattlegroundAPI.Score:SetPointsFor("horde", 230, GetTime())
            Score:UpdateFrames()
            ScoreTimer:SetText(135)
            CaptureBar:Show()
            CaptureBar:SetValue(50)
        else
            TestMode = false
            module:ScoreFrame_Hide()
            CaptureBar:Hide()
        end
    end
    
    function addon:IsScoreVisible()
        return showFrame
    end
    
    function addon:InstallBattlegroundDefaults(encounterData, defaults)
        defaults.ShowScoreSlots = true
        
        local templateDefaults = BattlegroundAPI:GetTemplateAttribute(encounterData.template, {"settings"})
        if templateDefaults then
            for k,v in pairs(templateDefaults) do
                defaults[k] = v
            end
        end
        
        local moduleDefaults = BattlegroundAPI:GetModuleAttribute(encounterData, {"battleground","settings"})
        if moduleDefaults then
            for k,v in pairs(moduleDefaults) do
                defaults[k] = v
            end
        end
    end
end

---------------------------------------
-- BATTLEGROUND TEMPLATES
---------------------------------------

do
    local BattlegroundTemplates = {
        templates = {}
    }
    
    ------------------------
    -- Template functions --
    ------------------------
    function addon:RegisterBattlegroundTemplate(name, data)
        if not BattlegroundTemplates:Get(name) then
            BattlegroundTemplates.templates[name] = data
        end
    end
    
    function BattlegroundTemplates:Get(templateName)
        templateName = templateName or (CE and CE.template)
        if not templateName then return nil end
        return BattlegroundTemplates.templates[templateName]
    end

    -------------------------
    -- Attribute functions --
    -------------------------
    do
        function BattlegroundAPI:GetTemplateAttribute(...)
            local templateName = select(1,...)
            if templateName then
                local template = BattlegroundTemplates:Get(templateName)
                if template then return TraverseTable(template, unpack(select(2,...))) end
            end

            local template = BattlegroundTemplates:Get() -- returns current BG's template
            return TraverseTable(template, ...)
            
        end
        
        function BattlegroundAPI:GetModuleAttribute(...)
            local moduleData,path = select(1,...)
            if type(moduleData) == "table" and type(path) == "table" then
                return TraverseTable(moduleData, unpack(path))
            else                
                if not CE or not addon:IsModuleBattleground(CE.key) then return nil end
                return TraverseTable(CE.battleground, ...)
            end
        end
        
        function BattlegroundAPI:GetAttribute(...)
            return BattlegroundAPI:GetModuleAttribute(...) or BattlegroundAPI:GetTemplateAttribute(...)
        end
        
        function BattlegroundAPI:RunTemplateAttribute(path, ...)
            if type(path) == "string" then
                return run(BattlegroundAPI:GetTemplateAttribute(path), ...)
            else
                return run(BattlegroundAPI:GetTemplateAttribute(unpack(path)), ...)
            end
        end
        
        function BattlegroundAPI:RunModuleAttribute(path, ...)
            if type(path) == "string" then
                return run(BattlegroundAPI:GetModuleAttribute(path), ...)
            else
                return run(BattlegroundAPI:GetModuleAttribute(unpack(path)), ...)
            end
        end
        
        function BattlegroundAPI:RunAttribute(path, ...)
            if type(path) == "string" then
                return run(BattlegroundAPI:GetAttribute(path), ...)
            else
                return run(BattlegroundAPI:GetAttribute(unpack(path)), ...)
            end
        end
    end
end

---------------------------------------
-- BATTLEGROUND MODULES
---------------------------------------
do
    BattlegroundModules = {
        modules = {}
    }
    local BattlegroundData = {
        modules = {},
        shared = {},
    }

    function BattlegroundModules:NewModule(name)
        local NewModule = addon:NewModule("PvP Score - "..name,"AceTimer-3.0","AceEvent-3.0")
        NewModule.Timers = {}
        
        function NewModule:RepeatTimer(name, time, timerKey, ...)
            if not NewModule.Timers[name] then NewModule.Timers[name] = {} end
            NewModule:StopTimer(name, timerKey)
            
            NewModule.Timers[name][timerKey] = NewModule:ScheduleRepeatingTimer(name, time, ...)
        end
        
        function NewModule:StopTimer(name, timerKey)
            if NewModule.Timers[name] and NewModule.Timers[name][timerKey] then
                NewModule:CancelTimer(NewModule.Timers[name][timerKey],true)
                NewModule.Timers[name][timerKey] = nil
            end
        end
        
        if not NewModule.SetData then
            function NewModule:SetData(newData)
                NewModule.data = newData
            end
        end
        
        return NewModule
    end

    function BattlegroundModules:RegisterModule(name, ModuleCore, data)
        if not name or type(name) ~= "string" then return end
        if BattlegroundModules:Get(name) then return end
        
        BattlegroundModules.modules[name] = {
            core = ModuleCore,
            data = data,
        }
        BattlegroundData.modules[name] = {}
        
        function ModuleCore:GetAttribute(...)
            return BattlegroundAPI:GetAttribute("modules", name, ...)
        end
        
        function ModuleCore:GetRunnableAttribute(path,...)
            if type(path) ~= "table" then path = {path} end
            local runnableAttribute = ModuleCore:GetAttribute(unpack(path))
            if type(runnableAttribute) == "function" then
                return runnableAttribute(...)
            else
                return runnableAttribute
            end
        end
    end
    
    local ModulesWithEvents = {}
    
    function BattlegroundModules:RegisterEvent(module, eventName)
        ModulesWithEvents[module] = true
        module:RegisterEvent(eventName)
    end
    
    function BattlegroundModules:UnregisterAllEvents()
        for module,_ in pairs(ModulesWithEvents) do
            module:UnregisterAllEvents()
            ModulesWithEvents[module] = nil
        end
    end
    
    function BattlegroundModules:Get(name)
        if not BattlegroundModules.modules[name] then
            return nil
        else
            return BattlegroundModules.modules[name].data
        end
    end
    
    function BattlegroundModules:GetCore(name)
        return BattlegroundModules.modules[name].core
    end
    
    function BattlegroundModules:StopTimers()
        -- Stop module timers
        for moduleName,moduleData in pairs(BattlegroundModules.modules) do
            local core = moduleData.core
            local timers = core.Timers
            if timers then
                for functionName,timerData in pairs(timers) do
                    for timerKey,timer in pairs(timerData) do
                        core:StopTimer(functionName, timerKey)
                    end
                end
            end
        end
    end
    
    local function RunModuleFunctionsInCascade(modules,functionName,...)
        if not modules then return end
        
        local args = {...}
        
        for moduleName,_ in pairs(modules) do
            local mod = BattlegroundModules:Get(moduleName)
            if mod and mod[functionName] then 
                args = {mod[functionName](nil,BattlegroundData.modules[moduleName],unpack(args))}
            end
        end
        
        return unpack(args)
    end
    
    local function RunModuleFunctionsInSequence(modules,functionName,...)
        if not modules then return end
                
        for moduleName,_ in pairs(modules) do
            local mod = BattlegroundModules:Get(moduleName)
            if mod and mod[functionName] then 
                mod[functionName](nil,BattlegroundData.modules[moduleName],...)
            end
        end
    end
    --[[
     ScoreSlots:SetData(
            BattlegroundModules:RunInCascade(
                BattlegroundAPI:GetModuleAttribute("modules"),"refreshSlots",ScoreSlots:UnpackData()
            )
        )
    ]]
    function BattlegroundModules:RunInCascade(functionName, ...)
        local args = {...}
        args = {RunModuleFunctionsInCascade(BattlegroundAPI:GetTemplateAttribute("modules"),functionName, unpack(args))}
        args = {RunModuleFunctionsInCascade(BattlegroundAPI:GetModuleAttribute("modules"),functionName, unpack(args))}
        
        return unpack(args)
    end
    
    function BattlegroundModules:RunInSequence(functionName, ...)
        RunModuleFunctionsInSequence(BattlegroundAPI:GetTemplateAttribute("modules"),functionName, ...)
        RunModuleFunctionsInSequence(BattlegroundAPI:GetModuleAttribute("modules"),functionName, ...)
    end
    
    function BattlegroundModules:RunModuleFunction(moduleName, functionName, ...)
        local mod = BattlegroundModules:Get(moduleName)
        if mod and mod[functionName] then mod[functionName](nil,BattlegroundData.modules[moduleName],...) end
    end
    
    function BattlegroundModules:RunModulesFunction(modules,functionName, ...)
        if not modules then return end
        
        for moduleName,_ in pairs(modules) do
            BattlegroundModules:RunModuleFunction(moduleName, functionName, ...)
        end
    end
    
    function BattlegroundModules:Run(functionName,...)
        BattlegroundModules:RunModulesFunction(BattlegroundAPI:GetTemplateAttribute("modules"),functionName,...)
        BattlegroundModules:RunModulesFunction(BattlegroundAPI:GetModuleAttribute("modules"),functionName,...)
    end
    
    function BattlegroundModules:Reset()
        -- Reset battleground modules data
        for moduleName,_ in pairs(BattlegroundData.modules) do
            local blankData = {}
            BattlegroundData.modules[moduleName] = blankData
            BattlegroundModules:GetCore(moduleName):SetData(blankData)
        end
        
        BattlegroundData.shared = {}
        
        BattlegroundModules:Run("initData")
        BattlegroundModules:SetupChatReplacements()
    end
    
    function BattlegroundAPI:SetData(key,value)
        BattlegroundData.shared[key] = value
    end
    
    function BattlegroundAPI:GetData(key)
        return BattlegroundData.shared[key]
    end
    
    ----------
    -- Chat --
    ----------
    local ChatReplacements
    
    local function SetupChatReplacementsInModules(ChatReplacements, modules)
        if not modules then return end
        for moduleName,_ in pairs(modules) do
            local data = {}
            ChatReplacements[moduleName] = data
            BattlegroundModules:RunModuleFunction(moduleName,"setupChatReplacements", data)
        end
    end
    
    function BattlegroundModules:SetupChatReplacements()
        ChatReplacements = {}
        
        SetupChatReplacementsInModules(ChatReplacements, BattlegroundAPI:GetTemplateAttribute("modules"))
        SetupChatReplacementsInModules(ChatReplacements, BattlegroundAPI:GetModuleAttribute("modules"))
    end
    
    local PATTERN_LOWER_KEY = "^_(.+)_$"
    
    local function DissectMessage(text, preset)
        local output = {}
        local matches = {text:match(preset.pattern)}
        local hasMatches = #matches > 0
        local keys = preset.vars
        
        if hasMatches and keys then
            for index,key in ipairs(keys) do
                local lowKey = key:match(PATTERN_LOWER_KEY) -- "_Faction_" becomes "Faction" which indicates the value should be lower-case
                
                if lowKey then
                    output[lowKey] = matches[index]:lower()
                else
                    output[key] = matches[index]
                end
            end
        end

        return hasMatches,output
    end
    
    local PATTERN_VARS_TO_REPLACE = "<([^ ]+)>"
    
        
    local function ReplaceVars(pattern, vars)
       return gsub(pattern,PATTERN_VARS_TO_REPLACE,function(var)
             return vars[var] or var
       end)
    end
    
    local function ProcessChatTrigger(event, msg, triggers, moduleName)
        local chatReplacements = ChatReplacements[moduleName]
        local refreshFrame = false
        
        for _,preset in ipairs(triggers) do
            local hasMatches,varsToSet = DissectMessage(msg, preset)
            if hasMatches then
                -- Replace the chat names for desired names
                if chatReplacements and varsToSet["Location"] then
                    varsToSet["LocationPure"] = varsToSet["Location"]
                    varsToSet["Location"] = chatReplacements[varsToSet["Location"]] or varsToSet["Location"]
                end
                
                -- Replace the missing faction with a faction by the event
                if not varsToSet["Faction"] then
                    varsToSet["Faction"] = CHAT_EVENT_TO_FACTION[event]
                    --varsToSet["FactionCapitalized"] = FactionMap[varsToSet["Faction"]] and FactionMap[varsToSet["Faction"]].capital or varsToSet["Faction"]
                end
                
                
                if varsToSet["Faction"] == "unknown" and varsToSet["Player"] then
                    local faction = Faction:Of(varsToSet["Player"])
                    if faction then
                        varsToSet["Faction"] = faction
                    else
                        varsToSet["Faction"] = Faction:Swap(Faction:Of("player"))
                    end
                end
                
                -- Adjust the faction according to the preferred faction
                if varsToSet["Faction"] then
                    if preset.swapFactions == true then
                        varsToSet["Faction"] = Faction:Swap(varsToSet["Faction"]) or varsToSet["Faction"]
                    end
                    
                    varsToSet["FactionCapitalized"] = FactionMap[varsToSet["Faction"]] and FactionMap[varsToSet["Faction"]].capital or varsToSet["Faction"]
                    varsToSet["FactionPure"] = varsToSet["Faction"]
                    varsToSet["Faction"] = Faction:Adjust(varsToSet["Faction"])
                end
                -- Set variables for the module
                BattlegroundAPI:SetModuleVariables(varsToSet)
                
                -- Fire module events
                BattlegroundModules:FireEvent(moduleName, preset.event, varsToSet)
                
                -- Fire battleground events
                module:FireBattlegroundEvent(preset.event)
                
                refreshFrame = true
            end
        end
        
        if refreshFrame then module:ScoreFrame_Refresh() end
    end
    
    function BattlegroundModules:ProcessChat(event, msg, modules)
        if not modules then return end
        
        for moduleName,data in pairs(modules) do
            local chatData = data.chat
            if chatData then
                -- Match the channel
                local channelFound = lookup(CHAT_EVENTS[event] or event, chatData.channel)
                -- Process the chat message
                if channelFound then
                    ProcessChatTrigger(event, msg, chatData.triggers, moduleName)
                end
            end
        end
    end
    
    ------------
    -- Events --
    ------------
    function BattlegroundModules:FireEvent(moduleName, event, ...)
        local mod = BattlegroundModules:Get(moduleName)
        if mod.events then
            local modEvent = mod.events[event]
            if modEvent then modEvent(mod,...) end
        end
    end

    ------------------
    -- Score MODULE --
    ------------------
    do
        local ScoreModule = BattlegroundModules:NewModule("Score Module")
        local moduleData = {
            --[[
            --initData = FlagModule.InitData,
            --updateData = FlagModule.UpdateData,
            --refreshSlots = FlagModule.RefreshSlots,
            events = {
                ["FLAG_PICKED_UP"] = FlagModule.OnFlagPickedUp,
                ["FLAG_CAPTURED"] = FlagModule.OnFlagCaptured,
                ["FLAG_DROPPED"] = FlagModule.OnFlagDropped,
                ["FLAG_RESET"] = FlagModule.OnFlagReset,
                ["BOTH_FLAGS_RESET"] = FlagModule.OnFlagsReset,
            },
            ]]
        }
        
        BattlegroundModules:RegisterModule("score", ScoreModule, moduleData)
    end

    -----------------
    -- Flag MODULE --
    -----------------
    do
        local FlagModule = BattlegroundModules:NewModule("Flag Module")
        
        local FLAG_STATE = {NO_FLAG = 0, IN_POSSESSION = 1, DROPPED = 2, SCORED = 3}

        --------------------
        -- Data functions --
        --------------------
        local flagData
        
        do
            function FlagModule:SetData(data)
                flagData = data
            end
            
            function FlagModule:InitData(data)
                flagData.FlagStatusLoaded = false
                flagData.alliance = {state = FLAG_STATE.NO_FLAG}
                flagData.horde    = {state = FLAG_STATE.NO_FLAG}
                
                FlagModule:FixFlagIcon()
                BattlegroundModules:RegisterEvent(FlagModule,"WORLD_MAP_UPDATE")
            end
            
            local function FindCarrierAtUnit(unit,sourceUnit)
                dxeprint(format("FindCarrierAtUnit for %s from %s",unit,sourceUnit))
                if not UnitExists(unit) then return end -- The suffixed unit does not exist
                
                local unitFaction = Faction:Of(unit)
                if not flagData[unitFaction] then return end
                if not flagData[unitFaction].carrierUnknown then return end -- ignore flags that are not flagged as missing a carrier
                
                local SlotMapping = FlagModule:GetAttribute("slots")
                local slotsAreSame = SlotMapping.alliance == SlotMapping.horde
                local flagFaction = slotsAreSame and unitFaction or Faction:Swap(unitFaction)
                
                local flagBuff = format("%s Flag", flagFaction)
                if not UnitBuff(unit, flagBuff) then return end -- ignore unit that doesn't have the buff
                
                local carrierData = {
                    name = UnitName(unit),
                    class = select(2, UnitClass(unit))
                }
                flagData[unitFaction].carrier = carrierData
                flagData[unitFaction].carrierUnknown = nil
                
                -- Set the flag variables for the module
                BattlegroundAPI:SetModuleVariables({
                    ["FactionPure"] = flagFaction,
                    ["Faction"]     = Faction:Adjust(flagFaction),
                    ["FlagCarrier"] = carrierData.name,
                })
                
                -- Fire battleground events
                module:FireBattlegroundEvent("FLAG_PICKED_UP")
                
                if not flagData[Faction:Swap(unitFaction)].carrierUnknown then
                    FlagModule:UnregisterEvent("UNIT_TARGET")
                    FlagModule:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
                    FlagModule:UnregisterEvent("UNIT_AURA")
                end
                
                module:ScoreFrame_Refresh()
            end
            
            function FlagModule:UNIT_TARGET(event, unit)
                FindCarrierAtUnit(unit.."target",unit)
            end
            
            function FlagModule:UPDATE_MOUSEOVER_UNIT(event)
                FindCarrierAtUnit("mouseover","player")
            end
            
            function FlagModule:UNIT_AURA(event, unit)
                FindCarrierAtUnit(unit, "player")
            end
                        
            local function KeepLookingForFlag(faction)
                flagData[faction].carrierUnknown = true
                BattlegroundModules:RegisterEvent(FlagModule,"UNIT_TARGET")
                BattlegroundModules:RegisterEvent(FlagModule,"UPDATE_MOUSEOVER_UNIT")
                BattlegroundModules:RegisterEvent(FlagModule,"UNIT_AURA")
            end
            
            local NEUTRAL_FLAG_BUFF = "Netherstorm Flag"
            
            local function FindCarrierInGroup(faction)
                
                for i=1,GetNumRaidMembers() do
                    local unit = "raid"..i
                    local flagBuff = format("%s Flag", Faction:Swap(faction))
                    if UnitBuff(unit, flagBuff) then
                        return {name = UnitName(unit), class = select(2,UnitClass(unit))} -- Unit has a flag buff > CARRIER FOUND
                    elseif UnitBuff(unit, NEUTRAL_FLAG_BUFF) then
                        return {name = UnitName(unit), class = select(2,UnitClass(unit))} -- Unit has a flag buff > CARRIER FOUND
                    end
                end
                
                return nil -- Nobody with a flag buff found > No carrier found
            end
            
            local function FindCarrierOnMap(faction)
                
                -- Look for a flag icon
                local slotsAreSame = FlagModule:IsSingleFlag()
                local flagFaction = slotsAreSame and faction or Faction:Swap(faction)
                
                local flagX, flagY
                for i=1, GetNumBattlefieldFlagPositions() do
                    local x,y,flagType = GetBattlefieldFlagPosition(i)
                    if flagType:lower() == format("%sflag",flagFaction) then
                        flagX,flagY = x,y
                        break
                    end
                end
                
                -- Match the flag icon with raid member's position
                if flagX and flagY then
                    for i=1,GetNumRaidMembers() do
                        local unit = "raid"..i
                        local playerX,playerY = GetPlayerMapPosition(unit)
                        
                        if (flagX == playerX) and (flagY == playerY) then
                            return {name = UnitName(unit), class = select(2,UnitClass(unit))} -- Player position matches the flag > CARRIER FOUND
                        end
                    end
                    
                    return {keepLooking = true} -- Found a flag but not the carrier
                end
                
                -- Look for a battlefield icon
                for i=1,GetNumBattlefieldPositions() do
                    local x,y,name = GetBattlefieldPosition(i)
                    local posFaction = UnitFactionGroup(name) or Faction:Swap(Faction:Of("player"))
                    if posFaction and posFaction:lower() == faction then
                        return {name = name, class = select(2,UnitClass(name))}
                    end
                end
                
                return nil -- No match between the player position and flag position was found > No carrier found
            end
            
            local function FindCarrierInScore(faction)
                local UIstatesBroken = FlagModule:GetAttribute("statesBroken") or false
                local adjustedFaction = UIstatesBroken and Faction:Swap(faction) or faction
                local factionIndex =  BattlegroundAPI:GetAttribute("modules","score","indexes",adjustedFaction)
                
                return (select(2,GetWorldStateUIInfo(factionIndex))) == 2
            end
            
            local function FindCarrierFromUI(faction)                
                local flagIsTaken      = FindCarrierInScore(faction)
                local otherFlagIsTaken = FindCarrierInScore(Faction:Swap(faction))
                
                if flagIsTaken then
                    if not PvP:IsReloadInBG() then
                        return {keepLooking = true}
                    elseif otherFlagIsTaken then
                        return {keepLooking = true}
                    else
                        return nil
                    end
                else
                    return nil
                end
            end
            
            local function FindOurFlagCarrier(faction)
                return FindCarrierInGroup(faction) or FindCarrierOnMap(faction) or FindCarrierFromUI(faction)
            end
            
            local function FindOtherFlagCarrier(faction)
                return FindCarrierOnMap(faction) or FindCarrierFromUI(faction)
            end
            
            local function FindFlagCarrier(faction)
                local myFaction = Faction:Of("player")
                
                if faction == myFaction then
                    return FindOurFlagCarrier(faction)
                else
                    return FindOtherFlagCarrier(faction)
                end
            end
            
            function FlagModule:UpdateData()
                -- Reseting the flag data if victory has been reached
                if GetBattlefieldWinner() and GetBattlefieldWinner() ~= 2 then
                    for faction,_ in pairs(FactionMap) do
                        if flagData[faction].state == FLAG_STATE.SCORED then
                            flagData[faction].returnTime = nil
                        end
                    end
                    
                    return
                end
                
                if flagData.FlagStatusLoaded then return end
                flagData.FlagStatusLoaded = true
                
                for faction,_ in pairs(FactionMap) do
                    local carrierData = FindFlagCarrier(faction)
                    
                    if carrierData then
                        flagData[faction].state = FLAG_STATE.IN_POSSESSION
                    
                        -- Set the flag variables for the module
                        BattlegroundAPI:SetModuleVariables({
                            ["FactionPure"] = Faction:Swap(faction),
                            ["Faction"]     = Faction:Adjust(Faction:Swap(faction)),
                            ["FlagCarrier"] = carrierData.name,
                        })
                        
                        -- Fire battleground events
                        if carrierData.name then module:FireBattlegroundEvent("FLAG_PICKED_UP") end
                        flagData[faction].carrier = carrierData
                        
                        if carrierData.keepLooking then KeepLookingForFlag(faction) end
                    end
                end
            end
            
            function FlagModule:IsSingleFlag()
                return FlagModule:GetAttribute("singleFlag") == true
            end
        end
        
        -----------------
        -- Flag Events --
        -----------------
        do 
            local function DecreaseReturningTime(faction)
                local time = flagData[faction].returnTime
                if not time or time <= 1 then return end
                
                flagData[faction].returnTime = time - 1
            end
            
            function FlagModule:FlagReturningUpdate(factionArg)
                if type(factionArg) == "string" then
                    DecreaseReturningTime(factionArg)
                elseif type(factionArg) == "table" then
                    for _,faction in ipairs(factionArg) do
                        DecreaseReturningTime(faction)
                    end
                else
                    return
                end
                ScoreSlots:Refresh(true)
            end
            
            -- horde > alliance
            function FlagModule:OnFlagPickedUp(args)
                local otherFaction = Faction:Swap(args.FactionPure)
                flagData[otherFaction].state = FLAG_STATE.IN_POSSESSION
                flagData[otherFaction].carrier = {
                    name = args.FlagCarrier,
                    class = FlagModule:getClassFromScoreboard(args.FlagCarrier, otherFaction),
                }
                
                if FlagModule:IsSingleFlag() then
                    flagData[args.FactionPure].state = FLAG_STATE.NO_FLAG
                
                    -- Stop ScoreSlot updates for Flag Returning countdown
                    FlagModule:StopTimer("FlagReturningUpdate", Faction.List)
                    
                else
                    -- Stop ScoreSlot updates for Flag Returning countdown
                    FlagModule:StopTimer("FlagReturningUpdate", otherFaction)
                end
                
                -- Update ScoreSlots
                ScoreSlots:Refresh(true)
                
            end
            
            -- horde > alliance
            function FlagModule:OnFlagDropped(args)
                local otherFaction = Faction:Swap(args.FactionPure)
                flagData[otherFaction].state = FLAG_STATE.DROPPED
                flagData[otherFaction].returnTime = FlagModule:GetAttribute("returnTime")

                -- Cancel potential existing countdowns and start a Flag Returning countdown
                if FlagModule:IsSingleFlag() then
                    FlagModule:RepeatTimer("FlagReturningUpdate", 1, Faction.List, Faction.List)
                else
                    FlagModule:RepeatTimer("FlagReturningUpdate", 1, otherFaction, otherFaction)
                end

                -- Update ScoreSlots
                ScoreSlots:Refresh(true)
            end
            
            function FlagModule:OnFlagCaptured(args)
                local otherFaction = Faction:Swap(args.FactionPure)

                -- It's not a match point
                for faction,_ in pairs(FactionMap) do                        
                    flagData[faction].state      = FLAG_STATE.SCORED
                    flagData[faction].returnTime = FlagModule:GetAttribute("respawnTime")
                end
                
                -- Cancel potential existing countdowns and start a Flag Returning countdown
                FlagModule:RepeatTimer("FlagReturningUpdate", 1, Faction.List, Faction.List)
                
                -- Update ScoreSlots
                ScoreSlots:Refresh()
            end
            
            local function ResetFlag(faction)
                flagData[faction].state      = FLAG_STATE.NO_FLAG
                flagData[faction].returnTime = nil
                
                -- Cancel potential existing countdowns and start a Flag Returning countdown
                if FlagModule:IsSingleFlag() then
                   FlagModule:StopTimer("FlagReturningUpdate", Faction.List)
                else
                    FlagModule:StopTimer("FlagReturningUpdate", faction)
                end
            end
            
            function FlagModule:OnFlagReset(args)
                if args.FactionPure == "unknown" then
                    ResetFlag("alliance")
                    ResetFlag("horde")
                    FlagModule:StopTimer("FlagReturningUpdate", Faction.List)
                else
                    ResetFlag(Faction:Swap(args.FactionPure))
                end
                
                -- Update ScoreSlots
                ScoreSlots:Refresh(true)
            end
            
            function FlagModule:OnFlagsReset(args)
                for faction,_ in pairs(FactionMap) do
                    flagData[faction].state      = FLAG_STATE.NO_FLAG
                    flagData[faction].returnTime = nil
                end
                
                -- Cancel potential existing countdowns and start a Flag Returning countdown
                FlagModule:StopTimer("FlagReturningUpdate", Faction.List)
                
                -- Update ScoreSlots
                ScoreSlots:Refresh(true)
            end
            
            local function FixFlagOnMapShow()
                FlagModule:ScheduleTimer("FixFlagIcon",0)
            end
            
            WorldMapFrame:HookScript("OnShow", FixFlagOnMapShow)
            
            function FlagModule:FixFlagIcon(carrierName, faction)
                FlagModule:UnFixFlagIcon()
                if carrierName and faction == "horde" then return end
                
                for i=1,GetNumBattlefieldPositions() do
                    local x,y,name = GetBattlefieldPosition(i)
                    if x and y and name then
                        carrierName = name
                        break
                    end
                end
                
                local flag
                for i=1, MAX_RAID_MEMBERS do
                    local flagFrame = _G["WorldMapRaid"..i]
                    if flagFrame.name and flagFrame.name == carrierName then
                        if flagFrame.icon:GetTexture() ~= "Interface\\WorldStateFrame\\AllianceFlag" then
                            flagFrame.icon:SetTexture("Interface\\WorldStateFrame\\AllianceFlag")
                            flagFrame.icon:SetTexCoord(0,1,0,1)
                            flagFrame:SetWidth(24)
                            flagFrame:SetHeight(24)
                        end
                    end
                end
            end
            
            function FlagModule:UnFixFlagIcon()
                for i=1, MAX_RAID_MEMBERS do
                    local flagFrame = _G["WorldMapRaid"..i]
                    if flagFrame then
                        flagFrame.icon:SetTexture("Interface\\Minimap\\PartyRaidBlips")
                        flagFrame:SetWidth(16)
                        flagFrame:SetHeight(16)
                    end
                end
            end
            
            function FlagModule:WORLD_MAP_UPDATE()
                FlagModule:FixFlagIcon()
            end
        end
        
        ------------------
        -- Slot refresh --
        ------------------
        do
            local FLAGS = {
                alliance = "|TInterface\\Minimap\\POIIcons:20:20:0:0:256:256:18:36:55:73|t",
                horde    = "|TInterface\\Minimap\\POIIcons:20:20:0:0:256:256:37:55:55:73|t",
                neutral  = "|TInterface\\Addons\\DXE\\Textures\\icon_green_flag:20:20|t",
            }
            
            local TEXT_BASE = {
                alliance = "Alliance base",
                horde    = "Horde base",
                neutral  = "Spawn point",
            }
            
            local classesToUpdate = {
                alliance = {},
                horde    = {},
            }
            
            
            function FlagModule:UPDATE_BATTLEFIELD_SCORE()
                FlagModule:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
                module:ScoreFrame_Refresh()
            end
            
            function FlagModule:getClassFromScoreboard(carrier,faction)
                for i = 1, GetNumBattlefieldScores() do
                    local name, _, _, _, _, _, _, _, classToken = GetBattlefieldScore(i)
                    
                    
                    if (name and classToken and RAID_CLASS_COLORS[classToken]) then
                        if string.match(name, "-") then name = string.match(name, "([^%-]+)%-.+") end
                        if name == carrier then
                            classesToUpdate[faction][carrier] = nil
                            return classToken
                        end
                    end
                end
                
                if not classesToUpdate[faction][carrier] then
                    classesToUpdate[faction][carrier] = true
                    FlagModule:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
                    RequestBattlefieldScoreData()
                end
                
                return nil
            end
            
            function FlagModule:RefreshClasses()
                for faction,_ in pairs(FactionMap) do
                    local carrier = flagData[faction].carrier
                    if carrier and carrier.name and not carrier.class then
                        carrier.class = FlagModule:getClassFromScoreboard(carrier.name, faction)
                    end
                end
            end
            
            function FlagModule:RefreshSlots(flagData, SlotCount, SlotTexts, SlotColors, SlotFlashing, SlotActions)
                FlagModule:RefreshClasses()
                local SlotMapping = FlagModule:GetAttribute("slots")
                local slotsAreSame = SlotMapping.alliance == SlotMapping.horde
                for faction,_ in pairs(FactionMap) do
                    local otherFaction = Faction:Swap(faction)
                    local targetSlot = SlotMapping[otherFaction]
                    local state      = flagData[faction].state
                    local otherState = flagData[otherFaction].state
                    
                    local flag = slotsAreSame and FLAGS.neutral or FLAGS[otherFaction]
                    if state == FLAG_STATE.NO_FLAG then
                        if not slotsAreSame or otherState == FLAG_STATE.NO_FLAG then
                            local text = ReplaceVars(FlagModule:GetAttribute("texts","spawn") or "<Flag> <Location>",{
                                Flag = flag,
                                Location = TEXT_BASE[slotsAreSame and "neutral" or otherFaction],
                            })
                            
                            SlotTexts[targetSlot]    = text
                            SlotColors[targetSlot]   = slotsAreSame and "neutral" or otherFaction
                            SlotFlashing[targetSlot] = ""
                            SlotActions[targetSlot]  = {type = "macro", arg = ""}
                        end
                        
                    elseif state == FLAG_STATE.IN_POSSESSION then
                        local carrier = flagData[faction].carrier
                        local carrierText = (carrier and carrier.name) and format(" %s %s", carrier.name, getClassIcon(carrier.class)) or ""
                        local textReplacement = FlagModule:GetRunnableAttribute({"texts","carrier"},carrierText, carrier, faction)
                        
                        SlotTexts[targetSlot]    = format("%s%s",flag,textReplacement or carrierText or "")
                        SlotColors[targetSlot]   = faction
                        SlotFlashing[targetSlot] = faction
                        SlotActions[targetSlot]  = {type = "macro", arg = (carrier and carrier.name) and format("/targetexact %s", carrier.name) or ""}
                    elseif state == FLAG_STATE.DROPPED then
                        if not slotsAreSame or otherState ~= FLAG_STATE.IN_POSSESSION then 
                            SlotTexts[targetSlot]    = format("%s returns in %d", flag, flagData[faction].returnTime)
                            SlotColors[targetSlot]   = "neutral"
                            SlotFlashing[targetSlot] = "neutral"
                            SlotActions[targetSlot]  = {type = "macro", arg = ""}
                        end
                    elseif state == FLAG_STATE.SCORED then
                        local returnTime = flagData[faction].returnTime
                        SlotTexts[targetSlot]    = returnTime and format("%s respawns in %d", flag, returnTime) or ""
                        SlotColors[targetSlot]   = "unavailable"
                        SlotFlashing[targetSlot] = ""
                        SlotActions[targetSlot]  = {type = "macro", arg = ""}
                    end
                end
            end
        end
        
        ----------
        -- API --
        ----------
        local FlagAPI = {}
        BattlegroundAPI.Flag = FlagAPI
        
        function FlagAPI:GetFlags()
            return {
                alliance = flagData.alliance.state == FLAG_STATE.IN_POSSESSION,
                horde    = flagData.horde.state    == FLAG_STATE.IN_POSSESSION,
            }
        end
        
        local moduleData = {
            initData = FlagModule.InitData,
            updateData = FlagModule.UpdateData,
            refreshSlots = FlagModule.RefreshSlots,
            events = {
                ["FLAG_PICKED_UP"] = FlagModule.OnFlagPickedUp,
                ["FLAG_CAPTURED"] = FlagModule.OnFlagCaptured,
                ["FLAG_DROPPED"] = FlagModule.OnFlagDropped,
                ["FLAG_RESET"] = FlagModule.OnFlagReset,
                ["BOTH_FLAGS_RESET"] = FlagModule.OnFlagsReset,
            },
        }
        
        BattlegroundModules:RegisterModule("flags", FlagModule, moduleData)
    end

    ----------------
    -- POI MODULE --
    ----------------
    do
        local POIModule = BattlegroundModules:NewModule("POI Module")
        
        --------------------
        -- Data functions --
        --------------------
        local poiData
        local PATTERN_POI = "<POI>"
        
        do
            function POIModule:SetData(data)
                poiData = data
                local texts = BattlegroundAPI:GetAttribute("slots","texts")
                poiData.textsWithPOI = {}
                if not texts then return end
                for slotIndex,text in pairs(texts) do
                    if type(text) == "string" then
                        if text:find(PATTERN_POI) then
                            poiData.textsWithPOI[slotIndex] = true
                        end
                    end
                end
            end
            
            local function loadStates(data, states)
                local IndexToStatus = data.IndexToStatus
                if not states then return end
                for categoryName,categoryData in pairs(states) do
                    IndexToStatus[categoryName] = IndexToStatus[categoryName] or {}
                    
                    for stateIndex,stateData in ipairs(categoryData) do
                        IndexToStatus[categoryName][stateIndex] = stateData
                    end
                end
            end
            
            local function loadCategories(data, categories)
                if not categories then return end
                local POItoState = data.POItoState
                local SlotToPOI =  data.SlotToPOI
                local POItoSlot =  data.POItoSlot
                local POIIndexToSlot = data.POIIndexToSlot
                
                for categoryName,categoryData in pairs(categories) do
                    POItoState[categoryName] = POItoState[categoryName] or {}
                    for pointName,pointData in pairs(categoryData) do
                        -- Loading "POI > state" conversion
                        local POIs = pointData.POIs
                        if POIs then
                            for i,textureIndex in ipairs(POIs) do
                                --addon:PrintTable(data.IndexToStatus)
                                if data.IndexToStatus and data.IndexToStatus[categoryName] then
                                    local state = data.IndexToStatus[categoryName][i]
                                    POItoState[textureIndex]               = state
                                    POItoState[categoryName][textureIndex] = state
                                end
                            end
                        end
                        
                        -- Loading "Slot > POI" conversion
                        local slotIndex = pointData.slot
                        if slotIndex then
                            local landmarkIndex = pointData.landmarkIndex
                            if type(slotIndex) == "table" then
                                if type(landmarkIndex) == "table" then
                                    for i,landmarkI in ipairs(landmarkIndex) do
                                        POIIndexToSlot[landmarkI] = slotIndex[i]
                                    end
                                end
                            else
                                if type(landmarkIndex) == "number" then
                                    POIIndexToSlot[landmarkIndex] = slotIndex
                                end
                                
                                SlotToPOI[slotIndex] = pointName
                                POItoSlot[pointName] = slotIndex
                            end
                        end
                        
                    end
                end
            end
            
            function POIModule:InitData(data)
                data.POItoState = {}
                data.SlotToPOI = {}
                data.POItoSlot = {}
                data.NameToState = {}
                data.IndexToStatus = {}
                data.POIIndexToSlot = {}
                
                loadStates(data, POIModule:GetAttribute("states"))
                loadCategories(data, POIModule:GetAttribute("categories"))
            end

            function POIModule:SlotToPOI(slotIndex)
                return poiData.SlotToPOI[slotIndex]
            end
            
            function POIModule:POIIndexToSlot(poiIndex)
                return poiData.POIIndexToSlot[poiIndex]
            end
            
            function POIModule:UpdateData()
                local POItoState = poiData.POItoState
                
                for i=1, GetNumMapLandmarks(), 1 do
                    local originalName, _, originalTextureIndex = OF.GetMapLandmarkInfo(i)
                    
                    if originalName then
                        poiData.NameToState[originalName] = {
                            index = originalTextureIndex,
                            state = POItoState[originalTextureIndex],
                        }
                    else
                        local name, _, textureIndex = GetMapLandmarkInfo(i)
                        
                        poiData.NameToState[name] = {
                            index = textureIndex,
                            state = POItoState[textureIndex],
                        }
                    end
                    
                end   
            end
            
            function getPOIdata()
                return poiData
            end
        end
        
        ----------
        -- API --
        ----------
        local PoiAPI = {}
        BattlegroundAPI.POI = PoiAPI
        
        function PoiAPI:CountPOI(filter)
            local count = 0
            
            for i=1, GetNumMapLandmarks(), 1 do
                local name, _, textureIndex = OF.GetMapLandmarkInfo(i)
                local state = PoiAPI:POItoState(textureIndex)
                if state then
                    local isMatch = true
                    for filterKey,filterValue in pairs(filter) do
                        if not state[filterKey] or state[filterKey] ~= filterValue then
                            isMatch = false
                            break
                        end
                    end
                    if isMatch then count = count + 1 end
                end
            end
            
            return count
        end
        
        function PoiAPI:POItoSlot(name)
            return poiData.POItoSlot[name]
        end
        
        function PoiAPI:POItoState(poiIndex)
            return poiData.POItoState[poiIndex]
        end
        
        ------------------
        -- Slot refresh --
        ------------------
        do
            local function GetPOIIcon(textureIndex, width, height)
               local left, right, top, bottom = WorldMap_GetPOITextureCoords(textureIndex)
               width = width or 0
               height = height or 0
               return format("|T%s:%s:%s:0:0:256:256:%s:%s:%s:%s|t","Interface\\MINIMAP\\POIICONS",width,height,left*256,right*256,top*256,bottom*256)
            end
            
            PoiAPI.iconOf = GetPOIIcon
              
            function POIModule:RefreshSlots(poiData, SlotCount, SlotTexts, SlotColors, SlotFlashing, SlotActions, SlotTextOnly)
                local iconsSizes = BattlegroundAPI:GetAttribute("slots","iconSizes")
                local texts = BattlegroundAPI:GetAttribute("slots","texts")
                local textsWithPOI = poiData.textsWithPOI
                
                for i=1, GetNumMapLandmarks() do
                    local originalName, _, originalTextureIndex = OF.GetMapLandmarkInfo(i)
                    local name, _, textureIndex = GetMapLandmarkInfo(i)
                    local slotIndex = POIModule:POIIndexToSlot(i) or PoiAPI:POItoSlot(originalName or name)
                    local state = PoiAPI:POItoState(originalName and originalTextureIndex or textureIndex)
                    if slotIndex and state then
                        if ScoreSlots:IsSlotTextOnly(slotIndex) then
                            local _, _, effectiveTextureIndex = GetMapLandmarkInfo(i)
                            local size = iconsSizes and iconsSizes[slotIndex] or 20
                            
                            SlotTexts[slotIndex]    = GetPOIIcon(effectiveTextureIndex, size, size)
                        else
                            if state.flashing then
                                if state.flashing == "opposite" then
                                    local current = SlotColors[slotIndex]
                                    if FactionMap[current] then
                                        SlotFlashing[slotIndex] = Faction:Swap(current)
                                    end
                                else
                                    SlotFlashing[slotIndex] = state.flashing
                                end
                            end
                            SlotColors[slotIndex]   = state.color    or SlotColors[slotIndex]
                            
                            if textsWithPOI[slotIndex] then
                                local _, _, effectiveTextureIndex = GetMapLandmarkInfo(i)
                                local size = iconsSizes and iconsSizes[slotIndex] or 20
                                local POI = GetPOIIcon(effectiveTextureIndex, size, size)
                                SlotTexts[slotIndex] = texts[slotIndex]:gsub(PATTERN_POI, POI)
                            end
                        end
                    end
                end
            end
        end
        
        ----------
        -- Chat --
        ----------
        do
            function POIModule:SetupChatReplacements(poiData, chatReplacements)
                local categories = POIModule:GetAttribute("categories")
                for _,categoryData in pairs(categories) do
                    for pointName,pointData in pairs(categoryData) do
                        local replData = pointData.chat
                        if replData then
                            if type(replData) == "string" then
                                chatReplacements[replData] = pointName
                            elseif type(replData) == "table" then
                                chatReplacements[replData[1]] = replData[2]
                            end
                        end
                    end
                end
            end
        end
        
        local moduleData = {
            initData = POIModule.InitData,
            updateData = POIModule.UpdateData,
            refreshSlots = POIModule.RefreshSlots,
            events = {},
            setupChatReplacements = POIModule.SetupChatReplacements,
        }
        
        BattlegroundModules:RegisterModule("POI", POIModule, moduleData)
    end
    
end
