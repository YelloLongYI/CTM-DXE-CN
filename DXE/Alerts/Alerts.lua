-- Based off RDX's alert system
local addon = DXE

local defaults = {
	profile = {
        BorderInset = 2,
		-- Top anchor
		TopScale = 0.9,
		TopGrowth = "DOWN",
        TopSort = "HIGH_FIRST",
		TopAlpha = 1.00,
		TopBarWidth = 250,
        TopBarHeight = 30,
        TopClickThrough = false,
        TopBarTextJustification = "LEFT",
        TopBarFontSize = 13,
        TopTextAlpha = 1,
        TopBarFontColor = {1,1,1,1},
        TopTextWidth = 210,
        TopTextWidthBonus = 0,
        TopTextHeightBonusMult = 1,
		TopTextXOffset = 10,
		TopTextYOffset = 0,    
        TopBarSpacing = 0,
            -- Timer
            TopTimerJustification = "RIGHT",
            TopTimerFontColor = {1,1,1,1},
            TopTimerXOffset = -65,
            TopTimerYOffset = 0,
            TopTimerAlpha = 1,
            TopTimerSecondsFontSize = 20,
            TopTimerDecimalFontSize = 12,
            TopScaleTimerWithBarHeight = true,
            TopDecimalYOffset = 2,
            TopShowDecimal = true,
            TopDecimalPlaces = 2,
            -- Icon
            TopIconXOffset = 0,
            TopIconYOffset = 0,
            TopIconSize = 30,
            TopSetIconToBarHeight = true,
            TopShowLeftIcon = false,
            TopShowRightIcon = true,
            TopShowIconBorder = true,
		-- Center anchor
		CenterScale = 0.9,
		CenterGrowth = "UP",
        CenterSort = "LOW_FIRST",
		CenterAlpha = 1.00,
		CenterBarWidth = 275,
        CenterBarHeight = 30,
        CenterClickThrough = false,
        CenterBarTextJustification = "RIGHT",
        CenterBarFontSize = 13,
        CenterTextAlpha = 1,
        CenterBarFontColor = {1,1,1,1},
        CenterTextWidth = 200,
        CenterTextWidthBonus = 0,
        CenterTextHeightBonusMult = 1,
		CenterTextXOffset = -50,
		CenterTextYOffset = 0,
        CenterBarSpacing = 0,
            -- Timer
            CenterTimerFontColor = {1,1,1,1},
            CenterTimerXOffset = -65,
            CenterTimerYOffset = 0,
            CenterTimerAlpha = 1,
            CenterTimerSecondsFontSize = 20,
            CenterTimerDecimalFontSize = 12,
            CenterScaleTimerWithBarHeight = true,
            CenterDecimalYOffset = 2,
            CenterShowDecimal = true,
            CenterDecimalPlaces = 2,
            -- Icon
            CenterIconXOffset = 0,
            CenterIconYOffset = 0,
            CenterIconSize = 30,
            CenterSetIconToBarHeight = true,
            CenterShowLeftIcon = false,
            CenterShowRightIcon = true,
            CenterShowIconBorder = true,
        -- Emphasis anchor
        EmphasisAnchor = true,
        EmphasisScale = 0.9,
        EmphasisGrowth = "UP",
        EmphasisSort = "LOW_FIRST",
        EmphasisAlpha = 1.00,
        EmphasisBarWidth = 250,
        EmphasisBarHeight = 30,
        EmphasisClickThrough = true,
        EmphasisBarTextJustification = "LEFT",
        EmphasisBarFontSize = 13,
        EmphasisTextAlpha = 1,
        EmphasisBarFontColor = {1,1,1,1},
        EmphasisTextWidth = 200,
        EmphasisTextWidthBonus = 0,
        EmphasisTextHeightBonusMult = 1,
		EmphasisTextXOffset = 5,
        EmphasisTextYOffset = 0,
        EmphasisBarSpacing = 0,
            -- Timer
            EmphasisTimerFontColor = {1,1,1,1},
            EmphasisTimerXOffset = -65,
            EmphasisTimerYOffset = 0,
            EmphasisTimerAlpha = 1,
            EmphasisTimerSecondsFontSize = 20,
            EmphasisTimerDecimalFontSize = 12,
            EmphasisScaleTimerWithBarHeight = true,
            EmphasisDecimalYOffset = 2,
            EmphasisShowDecimal = true,
            EmphasisDecimalPlaces = 2,
            -- Icon
            EmphasisIconXOffset = 0,
            EmphasisIconYOffset = 0,
            EmphasisIconSize = 30,
            EmphasisSetIconToBarHeight = true,
            EmphasisShowLeftIcon = true,
            EmphasisShowRightIcon = true,
            EmphasisShowIconBorder = true,
		-- Individual anchor
        IndividualScale = 1,
		IndividualAlpha = 1.00,
		IndividualBarWidth = 0,
        IndividualBarHeight = 30,
        IndividualBarXOffset = 0,
        IndividualBarYOffset = 0,
        IndividualClickThrough = false,
        IndividualBarTextJustification = "LEFT",
        IndividualBarFontSize = 12,
        IndividualTextAlpha = 1,
        IndividualBarFontColor = {1,1,1,1},
        IndividualTextWidth = 10,
        IndividualTextWidthBonus = 0,
        IndividualTextHeightBonusMult = 1,
		IndividualTextXOffset = 10,
		IndividualTextYOffset = 0,    
            -- Timer
            IndividualTimerFontColor = {1,1,1,1},
            IndividualTimerXOffset = -65,
            IndividualTimerYOffset = 0,
            IndividualTimerAlpha = 1,
            IndividualTimerSecondsFontSize = 20,
            IndividualTimerDecimalFontSize = 12,
            IndividualScaleTimerWithBarHeight = true,
            IndividualDecimalYOffset = 0,
            IndividualShowDecimal = true,
            IndividualDecimalPlaces = 2,
            -- Icon
            IndividualIconXOffset = 0,
            IndividualIconYOffset = 0,
            IndividualIconSize = 30,
            IndividualSetIconToBarHeight = true,
            IndividualShowLeftIcon = false,
            IndividualShowRightIcon = true,
            IndividualShowIconBorder = true,
        
        -- Warning Bars
		WarningBars = false,
		WarningAnchor = false,
		WarningMessages = true,
		WarningScale = 0.9,
		WarningGrowth = "DOWN",
        WarningSort = "LOW_FIRST",
		WarningAlpha = 1.00,
		WarningBarWidth = 275,
        WarningBarHeight = 30,
        WarningClickThrough = false,
        WarningBarTextJustification = "CENTER",
        WarningBarFontSize = 10,
        WarningTextAlpha = 1,
        WarningBarFontColor = {1,1,1,1},
        WarningTextWidth = 200,
        WarningTextWidthBonus = 0,
        WarningTextHeightBonusMult = 1,
        WarningTextXOffset = 5,
        WarningTextYOffset = 0,
        WarningShowIconBorder = true,
        WarningBarSpacing = 0,
            -- Icon
            WarningIconXOffset = 0,
            WarningIconYOffset = 0,
            WarningIconSize = 30,
            WarningSetIconToBarHeight = true,
            WarningShowLeftIcon = true,
            WarningShowRightIcon = true,
            WarningShowIconBorder = true,
		RedirectCenter = false,
		RedirectThreshold = 5,
		-- Warning Messages
		BeforeThreshold = 5,
		ClrWarningText = true,
		OutputType = "DXE_FRAME",
        SinkStorage = {
            sink20OutputSink = "RaidWarning",
        },
        DefaultChatOutput = false,
		SinkIconLeft = true,
        SinkIconRight = true,
		AnnounceToRaid = false,
		CdPopupMessage = false,
		CdBeforeMessage = false,
		DurPopupMessage = false,
		DurBeforeMessage = false,
		WarnPopupMessage = true,
        -- Sounds
        SoundOutputChannel = "Master",
        -- CountdownVoice = "Corsica (Female)",
        CountdownVoice = "YIKE",
        -- Animation
        AnimationTime = 0.6,
        FadeTime = 1,
        StickyBars = true,
		-- Flash
		FlashAlpha = 0.6,
		FlashDuration = 0.8,
		EnableOscillations = true,
		FlashOscillations = 2,
		FlashTexture = "Interface\\Tooltips\\UI-Tooltip-Background",
		ConstantClr = false,
		GlobalColor = {1,0,0},
		-- Bar
		BarFillDirection = "FILL",
		-- Timer
		TimerFontColor = {1,1,1,1},
		TimerXOffset = -65,
		TimerYOffset = 0,
		TimerAlpha = 1,
		TimerSecondsFontSize = 20,
		TimerDecimalFontSize = 12,
		ScaleTimerWithBarHeight = true,
		DecimalYOffset = 2,
        ShowDecimal = true,
        DecimalPlaces = 2,
		-- Toggles
		DisableDropdowns = false,
		DisableScreenFlash = false,
		Disableprototypes = false,
		ShowBarBorder = true,
        ShowSpark = true,
		-- Custom Bars
		CustomLocalClr = "TAN",
		CustomRaidClr = "TAN",
		CustomSound = "ALERT10",
        -- Announce
        AnnounceOnClick = true,
        -- Legion Frame
        LegionFrameHideEventIcons = true,
        LegionFrameHideEncounterIcons = false,
        LegionFrameYOffset = 0,
        LegionFrameScale = 1,
        -- Emphasis Frame
        EmphasisFadeIn = 3,
        EmphasisFadeTime = 1,
        EmphasisFont = "Friz Quadrata TT",
        EmphasisFontDecoration = "THICKOUTLINE",
        EmphasisFontSize = 34,
        EmphasisIcon = true,
        -- Alerts Frame
        AlertsNumSlots = 2,
        AlertsFont = "Friz Quadrata TT",
        AlertsFontSize = 24,
        AlertsFontDecoration = "OUTLINE",
        Alerts_Time_Holding = 4,
        Alerts_Time_Popping = 1/3,
        Alerts_Time_Pushing = 1/3,
        Alerts_Time_Dropping = 1/3,
        Alerts_Time_Fading = 1/3,
        AlertsDirection = "DOWN",
        -- LFG Timer
        LFGTimerEnabled = true,
        LFGTimerMainColor = "RED",
        LFGTimerFlashColor = "GOLD",
        LFGTimerAudioCDVoice = "#default#",
        LFGTimerAudioCD = true,
        LFG_MutedSound = true,
        LFGShowLeftIcon = false,
        LFGShowRightIcon = true,
        -- Entering LFG Timer
        LFGEnteringTimerMainColor = "TURQUOISE",
        LFGEnteringTimerFlashColor = "TEAL",
        LFGEnteringShowLeftIcon = false,
        LFGEnteringShowRightIcon = true,
        LFG_Entering_MutedSound = true,
        -- RBG Timer
        RBGTimerEnabled = true,
        RBGTimerMainColor = (UnitFactionGroup("player") == "Alliance") and "LIGHTBLUE" or "RED",
        RBGTimerFlashColor = (UnitFactionGroup("player") == "Alliance") and "TURQUOISE" or "ORANGE",
        RBGTimerAudioCDVoice = "#default#",
        RBGTimerAudioCD = true,
        RBG_MutedSound = true,
        RBGShowLeftIcon = true,
        RBGShowRightIcon = true,
        -- Global Resurrection Timer
        GlobalResurrectionTimerEnabled = true,
        GlobalResurrectionTimerMainColor = "RED",
        GlobalResurrectionTimerFlashColor = "ORANGE",
        GlobalResurrectionTimerFlashTime = 5,
        GlobalResurrectionTimerAudioCDVoice = "#off#",
        -- Resurrection Timer
        ResurrectTimerEnabled = true,
        ResurrectTimerMainColor = "TURQUOISE",
        ResurrectTimerFlashColor = "WHITE",
        ResurrectTimerFlashTime = 10,
        ResurrectTimerAudioCDVoice = "#off#",
        ResurrectShowLeftIcon = true,
        ResurrectShowRightIcon = true,
        ResurrectShowDecimal = true,
        ResurrectDecimalPlaces = 2,
        -- Colors
        Phrases = {
            ["Next"] = {color = "GOLD"},
            ["CD"] = {color = "None"},
            ["Big Spell Warning"] = {color = "RED"},
            ["Centerpopup Bar"] = {color = "YELLOW"},
            ["on me"] = {color = "WHITE"},
            ["in the"] = {color = "WHITE"},
            ["LOOK AWAY"] = {color = "RED"},
            ["GET AWAY"] = {color = "RED"},
            ["STOP CASTING"] = {color = "YELLOW"},
            ["STOP DPS"] = {color = "LIGHTGREEN"},
            ["SWITCH TARGET"] = {color = "YELLOW"},
            ["MOVE AWAY"] = {color = "RED"},
            ["RUN AWAY"] = {color = "RED"},
            ["KEEP CLEAR"] = {color = "TURQUOISE"},
            ["MOVE BEHIND"] = {color = "LIGHTGREEN"},
            ["Charging up"] = {color = "TURQUOISE"},
            ["on"] = {color = "WHITE"},
            ["at"] = {color = "WHITE"},
            ["near"] = {color = "WHITE"},
            ["New:"] = {color = "GOLD"},
            ["New%s+"] = {color = "LIGHTGREEN"},
            ["INTERRUPT"] = {color = "RED"},
            ["DISPEL"] = {color = "CYAN"},
            ["DECURSE"] = {color = "PURPLE"},
            ["SPELLSTEAL"] = {color = "LIGHTBLUE"},
            ["MOVE"] = {color = "YELLOW"},
            ["RUN"] = {color = "YELLOW"},
            ["AWAY"] = {color = "YELLOW"},
            ["GET"] = {color = "YELLOW"},
            ["OUT"] = {color = "YELLOW"},
            ["YOU"] = {color = "GOLD"},
            ["OVER"] = {color = "LIGHTGREEN"},
            ["SUMMONED"] = {color = "CYAN"},
            ["DESTROY"] = {color = "ORANGE"},
            ["THEM"] = {color = "ORANGE"},
            ["IT"] = {color = "ORANGE"},
            ["JUMP"] = {color = "LIGHTGREEN"},
            ["%(%d+%)"] = {color = "GOLD", note = "(NUMBER)"}, 
            ["%([%d]+ remaining%)"] = {color = "GOLD", note = "(NUMBER remaining)"}, 
            ["-"] = {color = "WHITE"},
            ["!"] = {color = "WHITE"},
        },
	}
}

local L = addon.L
local CN = addon.CN
local NID = addon.NID
local AceTimer = LibStub("AceTimer-3.0")

local GetTime,PlaySoundFile = GetTime,PlaySoundFile
local ipairs,pairs,next,remove = ipairs,pairs,next,table.remove
local util = addon.util
local find = string.find
local ANNOUNCE_FORMAT = "*** %s ***"

local db,pfl,gbl

---------------------------------------
-- INITIALIZATION
---------------------------------------

local module = addon:NewModule("Alerts","LibSink-2.0","AceHook-3.0","AceEvent-3.0","AceTimer-3.0")
addon.Alerts = module
addon.Alerts.defaults = defaults
-- Stacks
local Active = {}
local TopAlertStack = {}
local CenterAlertStack = {}
local EmphasisAlertStack = {}
local WarningAlertStack = {}
local BarPool = {}
local translatingBarsCount = {Center = 0, Emphasis = 0, Warning = 0}
local TRANSLATING = {Center = {}, Emphasis = {}, Warning = {}}
local Special = {}
local prototype = {}

-- Anchors
local TopStackAnchor,CenterStackAnchor,EmphasisStackAnchor,WarningStackAnchor,EmphasisFrameAnchor,AlertsFrameAnchor

-- Bundles
local TOP, CENTER, EMPHASIS, WARNING

function module:RefreshProfile()
    pfl = db.profile
    addon.Alerts.pfl = pfl
	self:RefreshBars()
	self:SetSinkStorage(pfl.SinkStorage)
	self:UpdateFlashSettings()
end

local function WorldStateScoreFrame_OnUpdate()
    module:SetWinScoreTextLater()
end

function module:OnInitialize()
    -- Top stack anchor
	TopStackAnchor = addon:CreateLockableFrame("AlertsTopStackAnchor",245,10,format("%s - %s",L["Alerts"],L["Bar Top Anchor"]))
	addon:RegisterMoveSaving(TopStackAnchor,"TOPLEFT","UIParent","TOPLEFT",50,-150)
	addon:LoadPosition("DXEAlertsTopStackAnchor")
    TOP = {anchor = TopStackAnchor, stack = TopAlertStack, prefix = "Top"}

	-- Center stack anchor
	CenterStackAnchor = addon:CreateLockableFrame("AlertsCenterStackAnchor",245,10,format("%s - %s",L["Alerts"],L["Bar Center Anchor"]))
	addon:RegisterMoveSaving(CenterStackAnchor,"LEFT","UIParent","LEFT",150,-100)
	addon:LoadPosition("DXEAlertsCenterStackAnchor")
    CENTER = {anchor = CenterStackAnchor, stack = CenterAlertStack, prefix = "Center"}

    -- Emphasis stack anchor
	EmphasisStackAnchor = addon:CreateLockableFrame("AlertsEmphasisStackAnchor",245,10,format("%s - %s",L["Alerts"],L["Bar Emphasis Anchor"]),"EmphasisAnchor")
	addon:RegisterMoveSaving(EmphasisStackAnchor,"CENTER","UIParent","CENTER",0,100)
	addon:LoadPosition("DXEAlertsEmphasisStackAnchor")
    EMPHASIS = {anchor = EmphasisStackAnchor, stack = EmphasisAlertStack, prefix = "Emphasis"}
    
    -- Warning anchor
	WarningStackAnchor = addon:CreateLockableFrame("AlertsWarningStackAnchor",245,10,format("%s - %s",L["Alerts"],L["Bar Warning Anchor"]),"WarningAnchor")
	addon:RegisterMoveSaving(WarningStackAnchor,"TOP","UIParent","TOP",6.428568840026856,-100.7143707275391)
	addon:LoadPosition("DXEAlertsWarningStackAnchor")
    WARNING = {anchor = WarningStackAnchor, stack = WarningAlertStack, prefix = "Warning"}
    
    EmphasisFrameAnchor = addon:CreateLockableFrame("EmphasisFrameAnchor",245,10,format("%s - %s",L["Alerts"],L["Emphasis Frame Anchor"]))
    addon:RegisterMoveSaving(EmphasisFrameAnchor,"CENTER","UIParent","CENTER",0,200)
    addon:LoadPosition("DXEEmphasisFrameAnchor")

    AlertsFrameAnchor = addon:CreateLockableFrame("AlertsFrameAnchor",245,10,format("%s - %s",L["Alerts"],L["Alerts Frame Anchor"]))
    addon:RegisterMoveSaving(AlertsFrameAnchor,"CENTER","UIParent","CENTER",0,300)
    addon:LoadPosition("DXEAlertsFrameAnchor")
    
	self.db = addon.db:RegisterNamespace("Alerts", defaults)
	db = self.db
	pfl = db.profile
    gbl = db.global
    addon.Alerts.pfl = pfl
    
	self:SetSinkStorage(pfl.SinkStorage)
	self:UpdateFlashSettings()
    self:CreateEmphasisFrame()
    self:CreateAlertsFrame()
    
	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
    
    self:LoadVoicePacks()
    self:SetupSpecialBars()
    hooksecurefunc(WorldStateScoreFrame,"Show",WorldStateScoreFrame_OnUpdate)
    module:RegisterEvent("UPDATE_BATTLEFIELD_SCORE","SetWinScoreText")
    module:RegisterEvent("UPDATE_WORLD_STATES","SetWinScoreText")
    addon:UpdateMute(addon.Alerts.db.profile.DisableSounds)
end

function module:OnDisable()
	self:QuashAll()
end

---------------------------------------
-- UTILITY
---------------------------------------

local SM = LibStub("LibSharedMedia-3.0")
local Sounds = addon.Media.Sounds
local floor = math.floor
local ceil = math.ceil
local gsub = string.gsub

function module:GetColor(color)
    return addon.db.profile.Colors[color]
end

local function GetProfileColor(c1,c2)
    local Colors = addon.db.profile.Colors
    return Colors[c1],Colors[c2]
end

local function GetMedia(sound,c1,c2)
    local c1Data,c2Data = GetProfileColor(c1,c2)
    return Sounds:GetFile(sound),c1Data,c2Data
end

function addon:GetMessageEra(id)
	local popup,before
    
	if find(id,"cd$") or find(id,"cd0x.+$") then
		popup = pfl.CdPopupMessage
		before = pfl.CdBeforeMessage
	elseif find(id,"dur$") or find(id,"dur0x.+$") then
		popup = pfl.DurPopupMessage
		before = pfl.DurBeforeMessage
	elseif find(id,"self$") or find(id,"self0x.+$") then
		popup = pfl.DurPopupMessage
	elseif find(id,"warn$") or find(id,"warn0x.+$") then
		popup = pfl.WarnPopupMessage
	end

	return popup,before
end

local function MMSS(time)
	if time < 0 then
        time = 0
    else 
        time = floor(time)
    end
    
    local min = floor(time/60)
	local sec = ceil(time % 60)
	return ("%d:%02d"):format(min,sec)
end

local function GetPrefixedVar(bar, suffix)
    if bar.data and bar.data.anchor then
        return pfl[bar.data.anchor..suffix]
    end
    
    if bar.specialtype then
        return pfl["Individual"..suffix]
    end
    
    return pfl["Top"..suffix]
end

local function GetTargetVar(bar, suffix)
    return pfl[bar.data.targetPrefix..suffix]
end

local ColorText

do
	local function colorlist(word,comma)
		return CN[word]..comma
	end

    local function helper(word)
        word = string.gsub(word, "([<>])", "")
        if find(word,"^[^ ,]+,") then
            return gsub(word,"([^ ,]+)(,?)",colorlist)
		else
            return CN[word]
		end    
	end
    
    
	function ColorText(text, color)
        local Colors = addon.db.profile.Colors
        local result
        if string.find(text,"<[%a]+>") then
          result =  gsub(text,"<([%a, <>]+)>",helper)
        else
          result = text
        end
        
        -- Saving the textures
        local textures = {}
        result = result:gsub("|T[%w\\_\-]+:%d+:%d+|t",function(fragment)
              textures[#textures+1] = fragment
              return "{"..#textures.."}"
        end)
        
        result = result:gsub("%a+",function(w) return "_"..w end)
        -- Module custom coloring rules
        
        if addon.CE and addon.CE.key ~= "default" and addon.db.profile.Encounters[addon.CE.key].phrasecolors then
            if addon.CE.phrasecolors then
                for i,phrase in ipairs(addon.CE.phrasecolors) do
                    local colorKey = phrase[1]
                    local phraseData = addon.db.profile.Encounters[addon.CE.key].phrasecolors[colorKey]
                    local mask = colorKey:gsub("%a+", function(w) return "_"..w end):gsub("%%_","%%")
                    if phraseData.color ~= "None" then
                        local color = addon.db.profile.Colors[phraseData.color]
                        local colorMask = ("|cff%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
                        result = result:gsub(mask, function(bit) 
                            return colorMask..bit:gsub("_","").."|r"
                        end)
                    end
                end
            end
            if addon.db.profile.Encounters[addon.CE.key].phrasecolors then
                for colorKey,phraseData in pairs(addon.db.profile.Encounters[addon.CE.key].phrasecolors) do
                    if phraseData.custom then
                        local mask = colorKey:gsub("%a+", function(w) return "_"..w end):gsub("%%_","%%")
                        if phraseData.color ~= "None" then
                            local color = addon.db.profile.Colors[phraseData.color]
                            local colorMask = ("|cff%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
                            result = result:gsub(mask, function(bit) return colorMask..bit:gsub("_","").."|r" end)
                        end
                    end
                end
            end
        end
        -- Global custom coloring rules
        for phrase,phraseData in pairs(pfl.Phrases) do
                local mask = phrase:gsub("%a+", function(w) return "_"..w end):gsub("%%_","%%")
            if phraseData.color ~= "None" and addon.db.profile.Colors[phraseData.color] then
                local color = addon.db.profile.Colors[phraseData.color]
                local colorMask = ("|cff%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
                result = result:gsub(mask, function(bit) 
                    return colorMask..bit:gsub("_","").."|r"
                end)
            end
        end
        
        result = result:gsub("_","")
        if color then
            local colorMask = ("|cff%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
            result = gsub(result, "|c","|p|c"):gsub("|r","|r"..colorMask):gsub("|p","|r")
            result = colorMask..result.."|r"
        end
        -- Restoring the textures
        result = result:gsub("%{%d+%}",function(fragment)
            local index = fragment:match("(%d+)")
            return textures[tonumber(index)]
        end)
        
        
        return result
        
	end
end

local ICON_PRESET = {
    ["Pour"] = {w = 20, h = 20, offX = 5, offY = 0},
    ["DXE_FRAME"] = {w = 15, h = 15, offX = 5, offY = 5},
    ["DefaultChat"] = {w = 10, h = 10, offX = 5, offY = 0},
}

local function AssambleAlertText(iconPresetName,text,icon,color,noColoring)
    local iconLeft = pfl.SinkIconLeft and icon or nil
    local iconRight = pfl.SinkIconRight and icon or nil
    
    local iconPreset = ICON_PRESET[iconPresetName]
    local sizingLeft = format(":%d:%d:-%d:%d",iconPreset.w, iconPreset.h, iconPreset.offX, iconPreset.offY)
    local sizingRight = format(":%d:%d:%d:%d",iconPreset.w, iconPreset.h, iconPreset.offX, iconPreset.offY)
    
    local result = (pfl.ClrWarningText and not noColoring) and ColorText(text,color) or text
    result = (iconLeft and ("|T"..iconLeft..sizingLeft.."|t") or "")..result..(iconRight and ("|T"..iconRight..sizingRight.."|t") or "")
    
    return result
end

local function Pour(text,icon,color,noColoring,id,idToReplace)   
    color = color or addon.db.profile.Colors.WHITE
    
    if pfl.OutputType == "DXE_FRAME" then
        module:AddAlertMessage(text,icon,color,id,idToReplace,noColoring)
    else 
        pour_text = AssambleAlertText("Pour",text,icon,color,noColoring)
        if not pfl.DefaultChatOutput or pfl.SinkStorage.sink20OutputSink ~= "Default" then
            module:Pour(pour_text,color.r,color.g,color.b,nil,nil,nil,nil,nil,nil)
        end
        
        local no_you = not find(text,L.alert["YOU"])
        if no_you and pfl.AnnounceToRaid and addon:IsPromoted() and addon.GroupType == "RAID" then
            -- color coded text disconnects the user!!!
            text = gsub(text,"|c%x%x%x%x%x%x%x%x(.-)|r","%1")
            SendChatMessage(format(ANNOUNCE_FORMAT,text),"RAID_WARNING")
        end
    end
    
    if pfl.DefaultChatOutput then
        local textToPrint = AssambleAlertText("DefaultChat",text,icon,color,noColoring)
        print(format("|cff99ff33<DXE>|r  %s",textToPrint)) -- 0.6, 1, 0.2
    end
end

function module:Sound(soundFile, channel)
    if soundFile == "None" then return end
    if(type(tonumber(soundFile)) == "number") then
        PlaySoundKitID(tonumber(soundFile),pfl.SoundOutputChannel,false)
    else
        PlaySoundFile(soundFile, pfl.SoundOutputChannel)
    end
end

---------------------------------------------
-- SCREEN FLASH
---------------------------------------------

do
	local FLASH_DURATION,PERIOD,AMP,MULT,OSC

	local flash = CreateFrame("Frame","DXEAlertsFlash",UIParent)
	flash:SetFrameStrata("BACKGROUND")
	local t = flash:CreateTexture(nil,"BACKGROUND")
	t:SetAllPoints(true)
	flash:SetAllPoints(true)
	flash:Hide()

	local counter
	local function OnUpdate(self,elapsed)
        counter = counter + elapsed
		if counter > FLASH_DURATION then self:Hide() end
		if OSC then
			local p = counter % PERIOD
			if p > AMP then p = PERIOD - p end
			self:SetAlpha(p * MULT)
		end
	end

	flash:SetScript("OnUpdate",OnUpdate)

	module.FlashTextures = {
		["Interface\\Tooltips\\UI-Tooltip-Background"] = L["Solid"],
		["Interface\\Addons\\DXE\\Textures\\LowHealthGray"] = L["Low Health"],
	}

	function module:UpdateFlashSettings()
		t:SetTexture(pfl.FlashTexture)
	end

	function module:FlashScreen(c)
		local Colors = addon.db.profile.Colors
        if pfl.DisableScreenFlash then return end
		if pfl.ConstantClr then
			local r,g,b = unpack(pfl.GlobalColor)
			t:SetVertexColor(r,g,b,pfl.FlashAlpha)
		else
			c = c or Colors.BLACK
			t:SetVertexColor(c.r,c.g,c.b,pfl.FlashAlpha)
		end
		counter = 0
		OSC = pfl.EnableOscillations
		FLASH_DURATION = pfl.FlashDuration
		PERIOD = FLASH_DURATION / pfl.FlashOscillations
		AMP = PERIOD / 2
		MULT = 1 / AMP
		flash:SetAlpha(OSC and 0 or 1)
		flash:Show()
	end
end

---------------------------------------
-- UPDATING
---------------------------------------

local function OnUpdate(self,elapsed)
    local bar = next(Active)
	if not bar then self:Hide() return end
	local time = GetTime()
	while bar do
		if bar.countFunc then bar:countFunc(time) end
		if bar.animFunc then bar:animFunc(time) end
		bar = next(Active,bar)
	end
end

local UpdateFrame = CreateFrame("Frame",nil,UIParent)
UpdateFrame:SetScript("OnUpdate",OnUpdate)
UpdateFrame:Hide()

local function UpdateTranslating(anchor)
    if not anchor then return end
    if not TRANSLATING[anchor] then return end
    translatingBarsCount[anchor] = 0
    local translatingBars = TRANSLATING[anchor]
    TRANSLATING[anchor] = {}
    for _,bar in ipairs(translatingBars) do
        bar:TranslateToAnchor(bar.data.targetStack, bar.data.targetAnchor, bar.data.targetPrefix)
    end
end

---------------------------------------
-- PROTOTYPE
---------------------------------------
local wipe = table.wipe

function prototype:SetColor(c1key,c2key)
    local c1,c2 = GetProfileColor(c1key, c2key)
    self.data.c1 = c1
	self.statusbar:SetStatusBarColor(c1.r,c1.g,c1.b)
	self.data.c2 = c2 or c1
    self.data.c1key = c1key
    self.data.c2key = c2key or c1key
end

function prototype:Destroy()
    if not self.specialtype then
        local anchor = self.data.anchor
        self:RemoveFromStacks()
        self:RemoveTranslation()
        Active[self] = nil
        BarPool[self] = true
        self:LayoutAlertBundle(TOP)
        self:LayoutAlertBundle(CENTER)
        self:LayoutAlertBundle(EMPHASIS)
        self:LayoutAlertBundle(WARNING)
        UpdateTranslating(anchor)
    end
    self:Hide()
	self:ClearAllPoints()
	self:UnregisterAllEvents()
	self:CancelAllTimers()
	self.countFunc = nil
	self.animFunc = nil
	self.statusbar:SetValue(direction and 0 or 1)
	UIFrameFadeRemoveFrame(self)
	wipe(self.data)
	self.timer:Show()
	self.lefticon:Hide()
	self.lefticon.t:SetTexture("")
	self.righticon:Hide()
	self.righticon.t:SetTexture("")
	self.bmsg = nil
	self.orig_text = nil
	self:CancelAudioCountdown()
end

do

    local SORT_MOTHOD

	local function SortDesc(a1, a2)
        if a1.sticky and pfl.StickyBars then
            return true
        elseif SORT_MOTHOD == "HIGH_FIRST" then
            return (a1.data.timeleft or 10000) > (a2.data.timeleft or 10000)
        elseif SORT_MOTHOD == "LOW_FIRST" then 
            return (a1.data.timeleft or 10000) < (a2.data.timeleft or 10000)
        end
	end

    function prototype:LayoutAlertBundle(bundle)
        local stack, anchor, prefix = bundle.stack, bundle.anchor, bundle.prefix
        self:LayoutAlertStack(stack, anchor, prefix)
    end

	function prototype:LayoutAlertStack(stack, anchor, prefix)
		local growth = pfl[prefix.."Growth"]
        local sortMethod = pfl[prefix.."Sort"]
        
        SORT_MOTHOD = sortMethod
        sort(stack, SortDesc)
		local point,relpoint,mult
		if growth == "DOWN" then
			point,relpoint,mult = "TOP","BOTTOM",-1
		elseif growth == "UP" then
			point,relpoint,mult = "BOTTOM","TOP",1
		end
		for i,bar in ipairs(stack) do
			bar:ClearAllPoints()
            bar:SetPoint(point,anchor,relpoint,0,mult*(i-1)*(bar:GetHeight() + pfl[prefix.."BarSpacing"]))
		end            
	end
end

function prototype:UpdateIconSize(size)
    if not size then
        local prefix = self.data.anchor or "Top"
        if pfl[prefix.."SetIconToBarHeight"] then
            size = pfl[prefix.."BarHeight"]
        else
            size = pfl[prefix.."IconSize"]
        end
    end
    
    
    self.lefticon:SetWidth(size)
    self.lefticon:SetHeight(size)
    self.righticon:SetWidth(size)
    self.righticon:SetHeight(size)
end

function prototype:UpdateIconPosition(offsetX, offsetY)
    offsetX = offsetX or pfl[(self.data.anchor or "Top").."IconXOffset"]
    offsetY = offsetY or pfl[(self.data.anchor or "Top").."IconYOffset"]
    
    self.lefticon:ClearAllPoints()
	self.lefticon:SetPoint("RIGHT",self,"LEFT",-offsetX,offsetY)

	self.righticon:ClearAllPoints()
	self.righticon:SetPoint("LEFT",self,"RIGHT",offsetX,offsetY)
end

function prototype:UpdateTimerSize(barHeight) 
    local DecimalPlaces = self:GetAttr("DecimalPlaces")
    local ScaleTimerWithBarHeight = self:GetAttr("ScaleTimerWithBarHeight")
    local TimerSecondsFontSize = self:GetAttr("TimerSecondsFontSize")
    local TimerDecimalFontSize = self:GetAttr("TimerDecimalFontSize")
    local DecimalYOffset = self:GetAttr("DecimalYOffset")
    local TimerXOffset = self:GetAttr("TimerXOffset")
    local TimerYOffset = self:GetAttr("TimerYOffset")
    local TimerFontColor = self:GetAttr("TimerFontColor")
    local TimerAlpha = self:GetAttr("TimerAlpha")
    
    self.timer.right:SetWidth(40 * DecimalPlaces)
    
    self.timer.right:ClearAllPoints()
	self.timer.right:SetPoint("BOTTOMLEFT",self.timer.left,"BOTTOMRIGHT",0,DecimalYOffset)
    
    self.timer:ClearAllPoints()
	self.timer:SetPoint("RIGHT",self,"RIGHT",TimerXOffset,TimerYOffset)
    self.timer.right:SetVertexColor(unpack(TimerFontColor))
	self.timer.left:SetVertexColor(unpack(TimerFontColor))
    self.timer:SetAlpha(TimerAlpha)
    if ScaleTimerWithBarHeight then
		self.timer.left:SetFont((self.timer.left:GetFont()),(0.4375*barHeight)+6.875)
		self.timer.right:SetFont((self.timer.right:GetFont()),(0.25*barHeight)+4.5)
	else
		self.timer.left:SetFont((self.timer.left:GetFont()),TimerSecondsFontSize)
		self.timer.right:SetFont((self.timer.right:GetFont()),TimerDecimalFontSize)
	end
end

function prototype:AnchorToBundle(bundle)
    local stack, anchor, prefix = bundle.stack, bundle.anchor, bundle.prefix
    self:AnchorToAnchor(stack, anchor, prefix)
end

function prototype:AnchorToAnchor(stack, anchor, prefix)
    
    if prefix ~= "Top" and self.data.sound and not pfl.DisableSounds then module:Sound(self.data.sound) end
    self.data.anchor = prefix
    
    self:SetAlpha(pfl[prefix.."Alpha"])
	self:SetScale(pfl[prefix.."Scale"])
	self:SetWidth(pfl[prefix.."BarWidth"])
    self:SetHeight(pfl[prefix.."BarHeight"])
    self:EnableMouse(not pfl[prefix.."ClickThrough"])
    self.text:SetFont(self.text:GetFont(),pfl[prefix.."BarFontSize"])
    self.text:SetAlpha(pfl[prefix.."TextAlpha"])
    self.text:SetVertexColor(unpack(pfl[prefix.."BarFontColor"]))
    local TextJustify = self:GetAttr("BarTextJustification")
    local TextOffsetX = self:GetAttr("TextXOffset")
    local TextOffsetY = self:GetAttr("TextYOffset")
    local TextWidthBonus = self:GetAttr("TextWidthBonus")
    
    local tox = TextOffsetX
    if TextJustify == "RIGHT" then
        tox = tox - TextWidthBonus
    elseif TextJustify == "CENTER" then
        tox = tox - TextWidthBonus/2
    end
    local toy = TextOffsetY
    
    self.text:SetPoint("LEFT",self,"LEFT",tox,toy)
    self.text:SetWidth(self:GetWidth() + TextWidthBonus)
    self.text:SetHeight(self:GetAttr("BarFontSize")*1.2*self:GetAttr("TextHeightBonusMult"))
    self.text:SetJustifyH(TextJustify)
    self:UpdateIconSize()
    self:UpdateIconPosition()
    if prefix ~= "Warning" then self:UpdateTimerSize(pfl[prefix.."BarHeight"]) end
    self:DisplayIcon(pfl[prefix.."ShowLeftIcon"], pfl[prefix.."ShowRightIcon"])
    
    local INSET = pfl.BorderInset
	if pfl[prefix.."ShowIconBorder"] then
		self.lefticon.border:Show()
		self.lefticon.t:SetPoint("TOPLEFT",self.lefticon,"TOPLEFT",INSET,-INSET)
		self.lefticon.t:SetPoint("BOTTOMRIGHT",self.lefticon,"BOTTOMRIGHT",-INSET,INSET)

		self.righticon.border:Show()
		self.righticon.t:SetPoint("TOPLEFT",self.righticon,"TOPLEFT",INSET,-INSET)
		self.righticon.t:SetPoint("BOTTOMRIGHT",self.righticon,"BOTTOMRIGHT",-INSET,INSET)
	else
		self.righticon.border:Hide()
		self.righticon.t:SetPoint("TOPLEFT",self.righticon,"TOPLEFT")
		self.righticon.t:SetPoint("BOTTOMRIGHT",self.righticon,"BOTTOMRIGHT")

		self.lefticon.border:Hide()
		self.lefticon.t:SetPoint("TOPLEFT",self.lefticon,"TOPLEFT")
		self.lefticon.t:SetPoint("BOTTOMRIGHT",self.lefticon,"BOTTOMRIGHT")
	end
    
    self:RemoveFromStacks()
    self:RemoveTranslation()
    stack[#stack+1] = self
    self:LayoutAlertStack(stack, anchor, prefix)
    UpdateTranslating(prefix)
end

function prototype:AnchorToTop()
    self:AnchorToBundle(TOP)
end

function prototype:AnchorToCenter()
    self:AnchorToBundle(CENTER)
end

function prototype:AnchorToEmphasis()
    self:AnchorToBundle(EMPHASIS)
end

function prototype:GetAttr(attributeName)
    if self.data and self.data.anchor then
        return pfl[self.data.anchor..attributeName]
    end
    
    if self.specialtype then
        return pfl["Individual"..attributeName]
    end
    
    return pfl["Top"..attributeName]
end

function prototype:AnchorToWarning()
    self:AnchorToBundle(WARNING)
end

do
	local UIParent = UIParent
    
    local function ProgressValue(data, attribute, perc, delta)
        local startPoint = pfl["Top"..attribute]
        local endPoint = pfl[data.targetPrefix..attribute]
        return startPoint + (endPoint - startPoint) * perc
    end
    
    local function ProgressColor(data, attribute, perc)
        local startPoint = pfl["Top"..attribute]
        local endPoint = pfl[data.targetPrefix..attribute]
        
        local r = (startPoint[1] or startPoint.r) + ((endPoint[1] or endPoint.r) - (startPoint[1] or startPoint.r)) * perc
        local g = (startPoint[2] or startPoint.g) + ((endPoint[2] or endPoint.g) - (startPoint[2] or startPoint.g)) * perc
        local b = (startPoint[3] or startPoint.b) + ((endPoint[3] or endPoint.b) - (startPoint[3] or startPoint.b)) * perc

        return r,g,b
    end
    
    local function GetOffset(bar)
        local TextJustify = bar:GetAttr("BarTextJustification")
        local TextOffsetX = bar:GetAttr("TextOffsetX")
        local TextOffsetY = bar:GetAttr("TextOffsetY")
        local TextWidthBonus = bar:GetAttr("TextWidthBonus")
        
        local offsetX, offsetY, width
        
        if TextJustify == "RIGHT" then
            offsetX = TextOffsetX - TextWidthBonus
            offsetY = TextOffsetY
            width = bar:GetWidth() + TextOffsetX + TextWidthBonus
        else
            offsetY = TextOffsetX
            offsetY = TextOffsetY
            width = bar:GetWidth() + TextWidthBonus
        end
        
        return offsetX, offsetY, width
    end
    
    
	local function AnimationFunc(self,time)
		local data = self.data
        local perc = (time - data.t0) / pfl.AnimationTime
        local posPerc = (time - data.pt0) / (pfl.AnimationTime - (data.pt0 - data.t0))
		if pfl.AnimationTime == 0 or perc < 0 or perc > 1 then
			self.animFunc = nil
			self:AnchorToAnchor(data.targetStack, data.targetAnchor, data.targetPrefix)
			if self.data.flashscreen then
				module:FlashScreen(self.data.c1)
			end
		else
            -- Dimensions animation
            self:SetAlpha(ProgressValue(data, "Alpha", perc))
			self:SetScale(ProgressValue(data, "Scale", perc))
			self:SetWidth(ProgressValue(data, "BarWidth", perc))
			local h = ProgressValue(data, "BarHeight", perc)
            self:SetHeight(h)
            
            -- Font Size
            self.text:SetFont(self.text:GetFont(), ProgressValue(data, "BarFontSize", perc))
            self.text:SetVertexColor(ProgressColor(data, "BarFontColor", perc))
            
            -- Text Position and Justification
            local OldTextJustify = pfl.TopBarTextJustification
            local TextJustify = GetTargetVar(self,"BarTextJustification")
            local stringW = self.text:GetStringWidth()
            
            local tox0, toxMax
            local toy0 = pfl.TopTextYOffset
            local toyMax = GetTargetVar(self,"TextYOffset")
            local tw0 = pfl.TopBarWidth + pfl.TopTextWidthBonus
            local twMax = GetTargetVar(self,"BarWidth") + GetTargetVar(self,"TextWidthBonus")
            
            -- Start offsets
            if TextJustify == "RIGHT" then
                if OldTextJustify == "LEFT" then
                    tox0 = pfl.TopTextXOffset - (pfl.TopBarWidth - stringW) - pfl.TopTextWidthBonus
                    toy0 = pfl.TopTextYOffset
                elseif OldTextJustify == "CENTER" then
                    tox0 = - (pfl.TopBarWidth/2 - stringW/2) - pfl.TopTextWidthBonus + pfl.TopTextXOffset
                    toy0 = pfl.TopTextYOffset
                end
            elseif TextJustify == "LEFT" then
                if OldTextJustify == "RIGHT" then
                    tox0 = pfl.TopTextXOffset + pfl.TopBarWidth - stringW
                    toy0 = pfl.TopTextYOffset
                elseif OldTextJustify == "CENTER" then
                    tox0 = pfl.TopBarWidth/2 - stringW/2 + pfl.TopTextXOffset
                    toy0 = pfl.TopTextYOffset
                end
            elseif TextJustify == "CENTER" then
                if OldTextJustify == "LEFT" then
                    tox0 = - pfl.TopBarWidth/2 + stringW/2 + pfl.TopTextXOffset - pfl.TopTextWidthBonus/2
                    toy0 = pfl.TopTextYOffset
                elseif OldTextJustify == "RIGHT" then
                    tox0 =   pfl.TopBarWidth/2 - stringW/2 + pfl.TopTextXOffset - pfl.TopTextWidthBonus/2
                    toy0 = pfl.TopTextYOffset
                end
            end
  
            -- End offsets
            if TextJustify == "LEFT" then
                toxMax = GetTargetVar(self,"TextXOffset")
                
                if TextJustify == OldTextJustify then
                    tox0 = pfl.TopTextXOffset
                end
            elseif TextJustify == "RIGHT" then
                toxMax = GetTargetVar(self,"TextXOffset") - GetTargetVar(self,"TextWidthBonus")
                
                if TextJustify == OldTextJustify then
                    tox0 = pfl.TopTextXOffset - pfl.TopTextWidthBonus
                end
            elseif TextJustify == "CENTER" then
                toxMax = GetTargetVar(self,"TextXOffset") - GetTargetVar(self,"TextWidthBonus")/2
                
                if TextJustify == OldTextJustify then
                    tox0 = pfl.TopTextXOffset - pfl.TopTextWidthBonus/2
                end
            end


            -- Start-End deltas
            local toxDelta = toxMax - tox0
            local toyDelta = toyMax - toy0
            
            if (toxDelta ~= 0) or (toyDelta ~= 0) then 
                self.text:SetPoint("LEFT",self,"LEFT",tox0 + toxDelta * perc, toy0 + toyDelta * perc)
            end
            
            local twDelta = twMax - tw0
            if twDelta ~= 0 then self.text:SetWidth(tw0 + twDelta * perc) end
            
            -- Timer animation
            local tR,tG,tB = util.blend(util.toRGBA(pfl.TopTimerFontColor), util.toRGBA(pfl[data.targetPrefix.."TimerFontColor"]), perc)
            self.timer.right:SetVertexColor(tR, tG, tB)
            self.timer.left:SetVertexColor(tR, tG, tB)
            
            local decimalYOffset = pfl.TopDecimalYOffset + ((pfl[data.targetPrefix.."DecimalYOffset"] - pfl.TopDecimalYOffset) * perc)
            self.timer.right:ClearAllPoints()
            self.timer.right:SetPoint("BOTTOMLEFT",self.timer.left,"BOTTOMRIGHT",0,decimalYOffset)
            
            local timerXOffset = ProgressValue(data, "TimerXOffset", perc)
            local timerYOffset = ProgressValue(data, "TimerYOffset", perc)
            self.timer:ClearAllPoints()
            self.timer:SetPoint("RIGHT",self,"RIGHT",timerXOffset,timerYOffset)
            
			self.timer:SetAlpha(ProgressValue(data, "TimerAlpha", perc))
            
            local timerLeftSize, timerRightSize
            local scaleTimerTop = pfl.TopScaleTimerWithBarHeight
            local scaleTimerDst = pfl[data.targetPrefix.."ScaleTimerWithBarHeight"]
            if scaleTimerTop and scaleTimerDst then
                timerLeftSize = (0.4375*h)+6.875
                timerRightSize = (0.25*h)+4.5
            else
                local topSize = scaleTimerTop and (0.4375*pfl.TopBarHeight)+6.875 or pfl.TopTimerSecondsFontSize
                local dstSize = scaleTimerDst and (0.4375*pfl[data.targetPrefix.."BarHeight"])+6.875 or pfl[data.targetPrefix.."TimerSecondsFontSize"]
                timerLeftSize = topSize + ((dstSize - topSize) * perc)
                
                local topDecSize = scaleTimerTop and (0.25*pfl.TopBarHeight)+4.5 or pfl.TopTimerDecimalFontSize
                local dstDecSize = scaleTimerDst and (0.25*pfl[data.targetPrefix.."BarHeight"])+4.5 or pfl[data.targetPrefix.."TimerDecimalFontSize"]
                timerRightSize = topDecSize + ((dstDecSize - topDecSize) * perc)
            end
            self.timer.left:SetFont((self.timer.left:GetFont()),timerLeftSize)
            self.timer.right:SetFont((self.timer.right:GetFont()),timerRightSize)
            
            -- Icon
            local rIconAlpha = (pfl.TopShowRightIcon and 1 or 0) + (pfl[data.targetPrefix.."ShowRightIcon"] and 1 or -1) * perc
            self.righticon:SetAlpha(rIconAlpha)
            local lIconAlpha = (pfl.TopShowLeftIcon and 1 or 0) + (pfl[data.targetPrefix.."ShowLeftIcon"] and 1 or -1) * perc
            self.lefticon:SetAlpha(lIconAlpha)
            
			local escale = self:GetEffectiveScale()
			local data = self.data
            local x = (data.fx + ((data.tox - data.fx) * posPerc)) / escale
			local y = (data.fy + ((data.toy - data.fy) * posPerc)) / escale
			self:ClearAllPoints()
			self:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x,y)
            data.x, data.y = self:GetCenter()
            
            -- Icon Height  
            local iconStart = pfl.TopSetIconToBarHeight and pfl.TopBarHeight or pfl.TopIconSize
            local iconEnd = pfl[data.targetPrefix.."SetIconToBarHeight"] and pfl[data.targetPrefix.."BarHeight"] or pfl[data.targetPrefix.."IconSize"]
            local iconHeight = iconStart + ((iconEnd - iconStart) * perc)
            self:UpdateIconSize(iconHeight)
            
            self:UpdateIconPosition(ProgressValue(data, "IconXOffset", perc),
                                    ProgressValue(data, "IconYOffset", perc))
            
		end
	end

    function prototype:TranslateToAnchor(stack, anchor, prefix)
        local data = self.data
        data.anchor = nil
        data.targetStack = stack
        data.targetAnchor = anchor
        data.targetPrefix = prefix
        self:RemoveFromStacks()
        local x,y = self:GetCenter()
		self:ClearAllPoints()
        self.text:SetJustifyH(pfl[prefix.."BarTextJustification"])
        self:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x,y)
        self:LayoutAlertBundle(TOP)
        local worldscale,escale = UIParent:GetEffectiveScale(),self:GetEffectiveScale()
		data.t0 = data.t0 or GetTime()
        self:SetDestination(stack, anchor, prefix)
        translatingBarsCount[prefix] = translatingBarsCount[prefix] + 1
        table.insert(TRANSLATING[prefix],self)
        self:DisplayIcon(true, true, true)
        self.animFunc = AnimationFunc
		self:LayoutAlertStack(stack, anchor, prefix)
    end
    
    function prototype:TranslateToCenter()
        self:TranslateToAnchor(CenterAlertStack, CenterStackAnchor, "Center")
    end
    
    function prototype:TranslateToEmphasis()
        self:TranslateToAnchor(EmphasisAlertStack, EmphasisStackAnchor, "Emphasis")
    end
    
    function prototype:SetDestination(AlertStack, StackAnchor, profilePrefix)
        local data = self.data
        local worldscale,escale = UIParent:GetEffectiveScale(),self:GetEffectiveScale()
        local x,y = self:GetCenter()

        local fx = data.x and data.x*escale or x*escale
        local fy = data.y and data.y*escale or y*escale
        local cx,cy = StackAnchor:GetCenter()
        local mult = pfl[profilePrefix.."Growth"] == "DOWN" and -1 or 1
        cy = cy + mult*5
        
        local offset = ((pfl[profilePrefix.."BarHeight"] + pfl[profilePrefix.."BarSpacing"]) * (#AlertStack + translatingBarsCount[profilePrefix]) + pfl[profilePrefix.."BarHeight"]/2) * (pfl[profilePrefix.."Scale"] * worldscale)
        local tox,toy = cx*worldscale,cy*worldscale
        toy = toy + mult*(offset)
        
        data.tox = tox
		data.toy = toy
        data.pt0 = GetTime()
        data.fx = fx
		data.fy = fy
    end
end

function prototype:RemoveFromStack(stack)
	for i,bar in ipairs(stack) do
		if bar == self then
			remove(stack,i)
			return
		end
	end
end

function prototype:RemoveFromStacks()
	self:RemoveFromStack(TopAlertStack)
	self:RemoveFromStack(CenterAlertStack)
	self:RemoveFromStack(WarningAlertStack)
    self:RemoveFromStack(EmphasisAlertStack)
end

function prototype:RemoveTranslation()
    local data = self.data
    if data.targetPrefix and type(data.targetPrefix) == "string" then
        translatingBarsCount[data.targetPrefix] = translatingBarsCount[data.targetPrefix] - 1
        for i,bar in ipairs(TRANSLATING[data.targetPrefix]) do
            if bar == self then
                table.remove(TRANSLATING[data.targetPrefix],i)
                break
            end
        end
    end
    data.targetStack = nil
    data.targetAnchor = nil
    data.targetPrefix = nil
    data.t0 = nil
end

do
    local sparkSize = 32
    
    local a = 0.3421875
    -- height of the spark itself (it only takes up nearly 29 % of the texture)
    local b = 0.2875000

    function prototype:RefreshSpark(self, value, rawValue)
        if (pfl.StickyBars and self.data.sticky and rawValue > 0.999)then
            self.spark:Hide()    
        else
            self.spark:ClearAllPoints()
            local w = self.bg:GetWidth()
            local h = self.bg:GetHeight()
            local INSET = pfl.BorderInset
            local H = h/b
            local offsetY = H * (b/2 - 1/2 + a)
            self.spark.t:SetPoint("LEFT", self.bg, "LEFT", 1+(value*w)-(sparkSize/2)-value*2, offsetY)
            self.spark.t:SetPoint("RIGHT", self.bg, "RIGHT", 1-w+(sparkSize/2)+(value*w)-value*2, offsetY)
            self.spark.t:SetHeight(H)
            
            self.spark.t:SetVertexColor(self.data.c1.sr, self.data.c1.sg, self.data.c1.sb)
            self.spark:Show()
        end
    end 
    
	local function CountdownFunc(self,time)
        local timeleft = self.data.endTime - time
        local data = self.data
        local ShowDecimal = self:GetAttr("ShowDecimal")
        local DecimalPlaces = self:GetAttr("DecimalPlaces")
        local direction = self.data.fillDirection == "FILL"
        
		data.timeleft = timeleft
		if timeleft < 0 then
            self.countFunc = nil
            self:RefreshSpark(self,direction and 1 or 0, 0)
            self.statusbar:SetValue(direction and 1 or 0)
            self.timer:SetTime(0, ShowDecimal, DecimalPlaces, pfl.StickyBars and self.data.sticky)
            return
		end
        
		self.timer:SetTime(timeleft, ShowDecimal, DecimalPlaces, pfl.StickyBars and self.data.sticky)
        
        local value = 1 - (timeleft / data.totalTime)
        
        -- Spark
        if not pfl.ShowSpark then
            self.spark:Hide()
        else
            self:RefreshSpark(self, ((direction or pfl.BarFillDirection == "FILL") and not (direction and pfl.BarFillDirection == "FILL")) and 1-value or value,value)
        end
        
        self.statusbar:SetValue(direction and value or 1-value)
        
		if pfl.WarningMessages and self.bmsg and timeleft <= pfl.BeforeThreshold then
			self.bmsg = nil
			Pour(self.orig_text.." - "..MMSS(timeleft),data.icon,data.c1,self.data.id)
		end
	end

	local cos = math.cos
	local function CountdownFlashFunc(self,time)
        local data = self.data
		local timeleft = data.endTime - time
		self.data.timeleft = timeleft
		
        local ShowDecimal = self:GetAttr("ShowDecimal")
        local DecimalPlaces = self:GetAttr("DecimalPlaces")
        
        if (not pfl.StickyBars or not self.data.sticky) and timeleft < 0 then
			self.countFunc = nil
			self.timer:SetTime(0, ShowDecimal, DecimalPlaces, pfl.StickyBars and self.data.sticky)
			return
		end
        self.timer:SetTime(timeleft, ShowDecimal, DecimalPlaces, pfl.StickyBars and self.data.sticky)
        local value = 1 - (timeleft / data.totalTime)
		
        local direction = self.data.fillDirection == "FILL"
        if not pfl.ShowSpark then
            self.spark:Hide()
        else
            self:RefreshSpark(self, ((direction or pfl.BarFillDirection == "FILL") and not (direction and pfl.BarFillDirection == "FILL")) and 1-value or value,value)
        end
        
        self.statusbar:SetValue(direction and value or 1-value)
		if timeleft < data.flashTime then
            self.statusbar:SetStatusBarColor(util.blend(data.c1, data.c2, 0.5*(cos(timeleft*12) + 1)))
            self.spark.t:SetVertexColor(util.blendSpark(data.c1, data.c2, 0.5*(cos(timeleft*12) + 1)))
		end

		if pfl.WarningMessages and self.bmsg and timeleft <= pfl.BeforeThreshold then
			self.bmsg = nil
			Pour(self.orig_text.." - "..MMSS(timeleft),data.icon,data.c1,self.data.id)
		end
	end

	-- for absorb bar
	local function CountdownNoSetFlashFunc(self,time)
		local data = self.data
		local timeleft = data.endTime - time
		self.data.timeleft = timeleft
		
        local ShowDecimal = self:GetAttr("ShowDecimal")
        local DecimalPlaces = self:GetAttr("DecimalPlaces")
        
        if timeleft < 0 then
			self.countFunc = nil
			self.timer:SetTime(0, ShowDecimal, DecimalPlaces)
			return
		end
		self.timer:SetTime(timeleft, ShowDecimal, DecimalPlaces, pfl.StickyBars and self.data.sticky)
        local value = data.value / data.total
        local direction = self.data.fillDirection == "FILL"
        if not pfl.ShowSpark then
            self.spark:Hide()
        else
            self:RefreshSpark(self, ((direction or pfl.BarFillDirection == "FILL") and not (direction and pfl.BarFillDirection == "FILL")) and 1-value or value,value)
        end
        
        if timeleft < data.flashTime then
			self.statusbar:SetStatusBarColor(util.blend(data.c1, data.c2, 0.5*(cos(timeleft*12) + 1)))
		end
	end

	function prototype:Countdown(timeData, flashTime, noset)
        local totalTime = type(timeData)=="table" and timeData.time or timeData
        local timemax = type(timeData)=="table" and timeData.timemax or timeData
        local endTime = GetTime() + totalTime
		self.data.endTime,self.data.totalTime = endTime, timemax
		if noset then
			self.data.flashTime = flashTime
			self.countFunc = CountdownNoSetFlashFunc
		elseif flashTime and self.data.c1 ~= self.data.c2 then
			self.data.flashTime = flashTime
			self.countFunc = CountdownFlashFunc
		else
			self.countFunc = CountdownFunc
		end
	end
end

function prototype:Fade()
	local fadeTable = self.fadeTable
    self:SetTimeleft(0)
	fadeTable.startAlpha = self:GetAlpha()
	fadeTable.fadeTimer = 0
    fadeTable.timeToFade = pfl.FadeTime
	fadeTable.finishedFunc = self.Destroy
	UIFrameFade(self,fadeTable)
end

function prototype:SetID(id)
	self.data.id = id
end

function prototype:GetID()
	return self.data.id
end

local PATTERN_VAR_TAG = "^invoker/(%w+)/?(.*)$"

function prototype:GetIDs()
    local var,tag = self:GetID():match(PATTERN_VAR_TAG)
    return var,tag
end

function prototype:SetTimeleft(timeleft)
	self.data.timeleft = timeleft
end

function prototype:SetSound(sound)
	self.data.sound = sound
end

function prototype:SetFlashScreen(flashscreen)
	self.data.flashscreen = flashscreen
end

function prototype:SetText(text,announceText)
	self.text:SetText(ColorText(text))
    self.text.announceText = announceText
	self.orig_text = text
end

function prototype:GetText()
    return self.orig_text
end

function prototype:GetAnnounceText()
    return self.text.announceText
end

function prototype:DisplayIcon(showLeft, showRight, ignorealpha)
    if showLeft then
        self.lefticon:Show()
        if not ignorealpha then self.lefticon:SetAlpha(1) end
    else
        self.lefticon:SetAlpha(0)
        self.lefticon:Hide()
    end
    
    if showRight then
        self.righticon:Show()
        if not ignorealpha then self.righticon:SetAlpha(1) end
    else
        self.righticon:SetAlpha(0)
        self.righticon:Hide()
    end
end

function prototype:SetIcon(texture, showLeft, showRight)
	if not texture then
		self.lefticon:Hide()
		self.righticon:Hide()
		return
	end
    
    self:DisplayIcon(showLeft, showRight)
	self.data.icon = texture
    self.lefticon.t:SetTexture(texture)
    self.righticon.t:SetTexture(texture)
end

function prototype:DisplayIconBorder(show)
    if show then
        local INSET = pfl.BorderInset
        self.lefticon.border:Show()
        self.lefticon.t:SetPoint("TOPLEFT",self.lefticon,"TOPLEFT",INSET,-INSET)
        self.lefticon.t:SetPoint("BOTTOMRIGHT",self.lefticon,"BOTTOMRIGHT",-INSET,INSET)

        self.righticon.border:Show()
        self.righticon.t:SetPoint("TOPLEFT",self.righticon,"TOPLEFT",INSET,-INSET)
        self.righticon.t:SetPoint("BOTTOMRIGHT",self.righticon,"BOTTOMRIGHT",-INSET,INSET)
    else
        self.righticon.border:Hide()
        self.righticon.t:SetPoint("TOPLEFT",self.righticon,"TOPLEFT")
        self.righticon.t:SetPoint("BOTTOMRIGHT",self.righticon,"BOTTOMRIGHT")

        self.lefticon.border:Hide()
        self.lefticon.t:SetPoint("TOPLEFT",self.lefticon,"TOPLEFT")
        self.lefticon.t:SetPoint("BOTTOMRIGHT",self.lefticon,"BOTTOMRIGHT")
    end
end

function prototype:FireBeforeMsg() self.bmsg = true end

local function SkinBar(bar)
	bar:SetIcon(bar.data.icon)

	bar.statusbar:SetReverseFill(pfl.BarFillDirection == "DEPLETE")
    bar.statusbar:ClearAllPoints()
	bar.lefticon.t:ClearAllPoints()
	bar.righticon.t:ClearAllPoints()
	bar.bg:ClearAllPoints()

    if pfl.ShowBarBorder then
        local INSET = pfl.BorderInset
		bar.border:Show()
		bar.bg:SetPoint("TOPLEFT",INSET,-INSET)
		bar.bg:SetPoint("BOTTOMRIGHT",-INSET,INSET)
		bar.statusbar:SetPoint("TOPLEFT",INSET,-INSET)
		bar.statusbar:SetPoint("BOTTOMRIGHT",-INSET,INSET)
	else
		bar.border:Hide()
		bar.statusbar:SetPoint("TOPLEFT")
		bar.statusbar:SetPoint("BOTTOMRIGHT")
		bar.bg:SetPoint("TOPLEFT")
		bar.bg:SetPoint("BOTTOMRIGHT")
	end
    
    local data = bar.data
	
    local barHeight = bar:GetAttr("BarHeight")
    local DecimalYOffset = bar:GetAttr("DecimalYOffset")
    local TimerXOffset = bar:GetAttr("TimerXOffset")
    local TimerYOffset = bar:GetAttr("TimerYOffset")
    local TimerFontColor = bar:GetAttr("TimerFontColor")
    local TimerAlpha = bar:GetAttr("TimerAlpha")
    local TextJustify = bar:GetAttr("BarTextJustification")
    local TextOffsetX = bar:GetAttr("TextXOffset")
    local TextOffsetY = bar:GetAttr("TextYOffset")
    local TextWidthBonus = bar:GetAttr("TextWidthBonus")
    
    if data.anchor then 
        bar:SetScale(bar:GetAttr("Scale"))
        bar:SetAlpha(bar:GetAttr("Alpha"))
        bar:SetWidth(bar:GetAttr("BarWidth"))
        bar:SetHeight(barHeight)
        
        local tox = TextOffsetX
        if TextJustify == "RIGHT" then
            tox = tox - TextWidthBonus
        elseif TextJustify == "CENTER" then
            tox = tox - TextWidthBonus/2
        end
        local toy = TextOffsetY
        bar.text:SetPoint("LEFT",bar,"LEFT", tox, toy)
        bar.text:SetWidth(bar:GetWidth() + TextWidthBonus)
        bar.text:SetHeight(bar:GetAttr("BarFontSize")*1.2*bar:GetAttr("TextHeightBonusMult"))
        bar.text:SetFont(bar.text:GetFont(),bar:GetAttr("BarFontSize"))
        bar.text:SetVertexColor(unpack(bar:GetAttr("BarFontColor")))
        bar.text:SetAlpha(bar:GetAttr("TextAlpha"))
        bar.text:SetJustifyH(TextJustify)
    end
     
    
    bar.timer.right:ClearAllPoints()
	bar.timer.right:SetPoint("BOTTOMLEFT",bar.timer.left,"BOTTOMRIGHT",0,DecimalYOffset)

	bar.timer:ClearAllPoints()
	bar.timer:SetPoint("RIGHT",bar,"RIGHT",TimerXOffset,TimerYOffset)
	if TimerFontColor then
        bar.timer.right:SetVertexColor(unpack(TimerFontColor))
        bar.timer.left:SetVertexColor(unpack(TimerFontColor))
    end
	bar.timer:SetAlpha(TimerAlpha)

    bar:UpdateIconSize()
    bar:UpdateIconPosition()
    
    local ScaleTimerWithBarHeight = pfl.TopScaleTimerWithBarHeight
    local TimerSecondsFontSize = pfl.TopTimerSecondsFontSize
    local TimerDecimalFontSize = pfl.TopTimerDecimalFontSize
    local ShowIconBorder = pfl.TopShowIconBorder
    
    if data.anchor then
        ScaleTimerWithBarHeight = pfl[data.anchor.."ScaleTimerWithBarHeight"]
        TimerSecondsFontSize = pfl[data.anchor.."TimerSecondsFontSize"]
        TimerDecimalFontSize = pfl[data.anchor.."TimerDecimalFontSize"]
        bar:DisplayIcon(pfl[data.anchor.."ShowLeftIcon"], pfl[data.anchor.."ShowRightIcon"])
        ShowIconBorder = pfl[data.anchor.."ShowIconBorder"]
    end
    
    bar:DisplayIconBorder(ShowIconBorder)
    
    if ScaleTimerWithBarHeight then
		bar.timer.left:SetFont((bar.timer.left:GetFont()),(0.4375*barHeight)+6.875)
		bar.timer.right:SetFont((bar.timer.right:GetFont()),(0.25*barHeight)+4.5)
	else
		bar.timer.left:SetFont((bar.timer.left:GetFont()),TimerSecondsFontSize)
		bar.timer.right:SetFont((bar.timer.right:GetFont()),TimerDecimalFontSize)
	end
end

function module:RefreshBarColors()
    for bar in pairs(Active) do 
        bar:SetColor(bar.data.c1key, bar.data.c2key)
    end
end

function module:RefreshBars()
    module:RefreshSpecial()
    if not next(Active) and not next(BarPool) then return end
	for bar in pairs(Active) do SkinBar(bar) end
	for bar in pairs(BarPool) do SkinBar(bar) end
    
    prototype:LayoutAlertBundle(TOP)
	prototype:LayoutAlertBundle(CENTER)
    prototype:LayoutAlertBundle(EMPHASIS)
	prototype:LayoutAlertBundle(WARNING)
end

local BarCount = 1

local function CreateBar()
    local self = CreateFrame("Button","DXEAlertBar"..BarCount,UIParent)
    self:RegisterForClicks("RightButtonUp","LeftButtonUp")
    self:SetScript("OnClick", function(info ,button,...)
        if(button == "RightButton") then
            if not IsControlKeyDown() then return end
            self:Destroy()
        else 
            --if true then return end
            if not pfl.AnnounceOnClick then return end
            if not IsControlKeyDown() then return end
            local timeleft = MMSS(info.data.timeleft)
            local text = info.text.announceText or info.text:GetText()
            
            text = gsub(text, "|cff%x%x%x%x%x%x","")
            text = gsub(text, "|r","")
            
            local instanceType = select(2, GetInstanceInfo())
            local channel
            if instanceType == "pvp" then
                channel = "BATTLEGROUND"
            elseif GetNumRaidMembers() > 0 then
                channel = "RAID"
            elseif GetNumPartyMembers() > 0 then
                channel = "PARTY"
            else
                channel = "SAY"
            end
            
            SendChatMessage(format("<DXE> %s: %s",text, timeleft),channel)
        end
    end)
    self:SetHeight(pfl.TopBarHeight)

	local bg = self:CreateTexture(nil,"BACKGROUND")
	addon:RegisterBackground(bg)
	self.bg = bg
  
    local spark = CreateFrame("Frame",nil,self)
    self.spark = spark
    spark.t = spark:CreateTexture(nil, "OVERLAY")
    spark.t:SetBlendMode("ADD");
    spark.t:SetTexture([[Interface\AddOns\DXE\Textures\Spark]])

	self.data = {}

	local statusbar = CreateFrame("StatusBar",nil,self)
	statusbar:SetMinMaxValues(0,1)
	statusbar:SetValue(0)
	addon:RegisterStatusBar(statusbar)
	self.statusbar = statusbar

	local border = CreateFrame("Frame",nil,self)
	border:SetAllPoints(true)
	border:SetFrameLevel(statusbar:GetFrameLevel()+1)
	addon:RegisterBorder(border)
	self.border = border

	local timer = addon.Timer:New(self)
	timer:SetFrameLevel(self:GetFrameLevel()+1)
	timer.left:SetShadowOffset(1,-1)
	timer.right:SetShadowOffset(1,-1)
	self.timer = timer

	local text = statusbar:CreateFontString(nil,"ARTWORK")
	text:SetShadowOffset(1,-1)
	text:SetNonSpaceWrap(true)
	addon:RegisterFontString(text,10)
	self.text = text

	local lefticon = CreateFrame("Frame",nil,self)
	self.lefticon = lefticon
	lefticon.t = lefticon:CreateTexture(nil,"BACKGROUND")
	lefticon.t:SetTexCoord(0.07,0.93,0.07,0.93)

	lefticon.border = CreateFrame("Frame",nil,lefticon)
	lefticon.border:SetAllPoints(true)
	addon:RegisterBorder(lefticon.border)

	local righticon = CreateFrame("Frame",nil,self)
	self.righticon = righticon
	righticon.t = righticon:CreateTexture(nil,"BACKGROUND")
	righticon.t:SetTexCoord(0.07,0.93,0.07,0.93)

	righticon.border = CreateFrame("Frame",nil,righticon)
	righticon.border:SetAllPoints(true)
	addon:RegisterBorder(righticon.border)

	AceTimer:Embed(self)
	for k,v in pairs(prototype) do self[k] = v end

	self.fadeTable = {mode = "OUT", timeToFade = 1, endAlpha = 0, finishedArg1 = self }

	BarCount = BarCount + 1

	SkinBar(self)

	return self
end

local function GetBar()
	local bar = next(BarPool)
	if bar then BarPool[bar] = nil
	else bar = CreateBar() end
	Active[bar] = true
	UpdateFrame:Show()
	bar:Show()

	return bar
end

---------------------------------------
-- AUDIO COUNTDOWN
---------------------------------------
local CountdownVoicesDB = {
    ["Corsica (Female)"] = {
        max = 5,
        directory = "Interface\\Addons\\DXE\\Sounds\\",
        ext = "mp3"
    },
    ["YIKE"] = {
        max = 5,
        directory = "Interface\\Addons\\DXE\\SoundsCN\\Tracy\\",
        ext = "mp3"
    },
}

addon.Alerts.CountdownVoicesDB = CountdownVoicesDB

function prototype:PlayAudioCountdown(sound)
	if not pfl.DisableSounds then module:Sound(sound) end
end

function prototype:AudioCountdown(totaltime,voicePackKey)
	local voicePack = CountdownVoicesDB[voicePackKey or pfl.CountdownVoice] or CountdownVoicesDB[defaults.profile.CountdownVoice]
    for i=1,voicePack.max do
        if totaltime - i >= 0 then
            self:ScheduleTimer("PlayAudioCountdown",totaltime - i,voicePack.directory..i.."."..(voicePack.ext or "mp3"))
        end
    end
end

function prototype:CancelAudioCountdown()
	self:CancelAllTimers()
end

function addon:GetCountdownMax()
    local voicePack = CountdownVoicesDB[voicePackKey or pfl.CountdownVoice] or CountdownVoicesDB[defaults.profile.CountdownVoice]
    return voicePack.max
end

---------------------------------------
-- API
---------------------------------------

function module:QuashAll()
	for bar in pairs(Active) do bar:Destroy() end
end

local function findinexceptions(id,exceptions)
    if not exceptions then return false end
    
    for _,exception in ipairs(exceptions) do
        if find(id,exception) then return true end
    end

    return false
end

function module:QuashByPattern(pattern,exceptions)
	for bar in pairs(Active) do
        local barid = bar:GetID()
		if barid and find(barid,pattern) and not findinexceptions(barid,exceptions) then
			bar:Destroy()
		end
	end
end

function module:GetByPattern(pattern)
    local list = {}
    for bar in pairs(Active) do
        local id = bar:GetID()
        if id:find("^invoker/"..pattern) then
            local var,tag = bar:GetIDs()
            local idData = {
                var = var,
                tag = tag
            }
            list[idData] = {
                time = bar.data.timeleft,
                timemax = bar.data.totalTime,
                text = bar:GetText(),
                announceText = bar:GetAnnounceText(),
            }
        end
    end
    
    return list
end

function module:SetTimeleft(id,time)
	for bar in pairs(Active) do
		if bar:GetID() == id then
            bar.data.endTime = GetTime() + time
            if bar.fader then bar:CancelTimer(bar.fader,true) end
            bar:ScheduleTimer("Fade", time)
		end
	end
    
    module:RefreshBars()
end

function module:GetTimeleft(id)
	for bar in pairs(Active) do
		if bar:GetID() == id then
			return bar.data.timeleft
		end
	end
	return -1
end

function module:SetText(id, text, announceText)
    for bar in pairs(Active) do
		if bar:GetID() == id then
            bar:SetText(text, announceText)
		end
	end
end

function module:IsActive(id)
	for bar in pairs(Active) do
		if bar:GetID() == id then
			return true
		end
	end
end

function module:Dropdown(id, textData, timeData, flashTime, sound, c1, c2, flashscreen, icon, audiocd, warningText, emphasizeTimer, fillDirection, sticky, idToReplace)
    local timemax = type(timeData) == "table" and (timeData.timemax or timeData.time) or timeData
    local totalTime = type(timeData) == "table" and timeData.time or timeData
    if totalTime == 0 then return end
    local text,announceText
    if type(textData) == "table" then
        text = textData.text
        announceText = textData.announceText
    else
        text = textData
    end
    
    if pfl.DisableDropdowns then self:CenterPopup(id, text, timeData, flashTime, sound, c1, c2, flashscreen, icon, audiocd, warningText, false, emphasizeTimer, fillDirection, sticky, idToReplace) return end
	local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	local bar = GetBar()
	bar:SetID(id)
	bar:SetTimeleft(totalTime)
	bar:SetText(text,announceText)
	bar:SetFlashScreen(flashscreen)
	bar:SetColor(c1,c2)
	bar:SetSound(soundFile)
	bar:Countdown(timeData,flashTime)
	bar:AnchorToTop()
    bar:SetIcon(icon, pfl[bar.data.anchor.."ShowLeftIcon"], pfl[bar.data.anchor.."ShowRightIcon"])
    bar.data.sticky = sticky
    
    bar.data.fillDirection = fillDirection or "FILL"
	if flashTime then
        local waitTime = totalTime - flashTime - pfl.AnimationTime
		if waitTime < 0 then 
            if emphasizeTimer and pfl.EmphasisAnchor then
                bar:AnchorToEmphasis()
                bar:LayoutAlertBundle(TOP)
            else 
                bar:AnchorToCenter()
                bar:LayoutAlertBundle(TOP)
            end
		else
            if flashTime > 0 then
                if emphasizeTimer and pfl.EmphasisAnchor then
                    bar:ScheduleTimer("TranslateToEmphasis",waitTime)
                else
                    bar:ScheduleTimer("TranslateToCenter",waitTime)
                end
            end
        end
	end
    
	if not pfl.StickyBars or not sticky then
        bar.fader = bar:ScheduleTimer("Fade",totalTime)
    end
    
	if pfl.WarningMessages then
		local popup,before = addon:GetMessageEra(id)
		if popup then Pour((warningText or text).." - "..MMSS(totalTime), icon, c1Data, false, id, idToReplace) end
		if before then bar:FireBeforeMsg() end
	end
    
	if audiocd and audiocd ~= "#off#" then
        if audiocd == true or audiocd == "#default#" then
            bar:AudioCountdown(totalTime)
        else
            bar:AudioCountdown(totalTime,audiocd)
        end
	end
end

function module:CenterPopup(id, textData, timeData, flashTime, sound, c1, c2, flashscreen, icon, audiocd, warningText, emphasizeWarning, emphasizeTimer, fillDirection, sticky, idToReplace)
    local timemax = type(timeData) == "table" and (timeData.timemax or timeData.time) or timeData
    local totalTime = type(timeData) == "table" and timeData.time or timeData
    if totalTime == 0 then return end
    
    local text,announceText
    if type(textData) == "table" then
        text = textData.text
        announceText = textData.announceText
    else
        text = textData
    end
    
    local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	local bar = GetBar()
	bar:SetID(id)
	bar:SetIcon(icon)
	bar:SetTimeleft(totalTime)
	bar:SetColor(c1,c2)
	bar:SetText(text)
	bar:Countdown(timeData, flashTime)
	bar:SetSound(soundFile)
    bar.data.fillDirection = fillDirection or "FILL"
    bar.data.sticky = sticky
	if pfl.WarningAnchor and pfl.RedirectCenter and totalTime <= pfl.RedirectThreshold then
		bar:AnchorToWarning()
	else
        if emphasizeTimer and pfl.EmphasisAnchor then
            bar:AnchorToEmphasis()
        else
            bar:AnchorToCenter()
        end
	end
    if not pfl.StickyBars or not sticky then
        bar:ScheduleTimer("Fade",totalTime)
    end
    
	if flashscreen then self:FlashScreen(c1Data) end
    if pfl.WarningMessages then
		local popup,before = addon:GetMessageEra(id)
        if popup then 
            if not emphasizeWarning then
                Pour(warningText or text, icon, c1Data, false, id, idToReplace)
            else
                module:EmphasisedWarning(warningText or text, c1Data, icon, emphasizeWarning)
            end
        end
        if before then bar:FireBeforeMsg() end
	end
	if audiocd and audiocd ~= "#off#" then
        if audiocd == true or audiocd == "#default#" then
            bar:AudioCountdown(totalTime)
        else
            bar:AudioCountdown(totalTime,audiocd)
        end
	end
end


function module:Simple(id, text, timeData, sound, c1, flashscreen, icon, emphasize, idToReplace)
    local totalTime = type(timeData) == "table" and timeData.time or timeData
    if totalTime == 0 then return end
    
    local soundFile,c1Data = GetMedia(sound,c1)
	if soundFile and not pfl.DisableSounds then module:Sound(soundFile) end
	if flashscreen then self:FlashScreen(c1Data) end
	if pfl.WarningBars then
		local bar = GetBar()
        bar:SetColor(c1)
        bar.statusbar:SetValue(1)
		bar:SetIcon(icon)
		bar:SetText(text)
		bar.timer:Hide()
		bar[pfl.WarningAnchor and "AnchorToWarning" or "AnchorToCenter"](bar)
		bar:ScheduleTimer("Fade",totalTime)
	end

	if pfl.WarningMessages and pfl.WarnPopupMessage then
        if not emphasize then
            Pour(warningText or text, icon, c1Data, false, id, idToReplace)
        else
            module:EmphasisedWarning(warningText or text, c1Data, icon, emphasize)
        end
    end
end

function module:Special(id, text, color, icon, outputType, noColoring, idToReplace)
    local Colors = addon.db.profile.Colors
    local _,colorData = GetMedia(nil,color)

    if outputType == "DEFAULT_OUTPUT" then
        Pour(text,icon,colorData,noColoring,id,idToReplace)
    elseif outputType == "RAID_WARNING_OUTPUT" then
        colorData = colorData or addon.db.profile.Colors.WHITE
        if icon then text = "|T"..icon..":20:20:-5|t"..text.."|T"..icon..":20:20:5|t" end
        RaidNotice_AddMessage(RaidWarningFrame, text, colorData)
    end
    
end

---------------------------------------------
-- ABSORB BARS
---------------------------------------------

local function abbrev(value)
	return value > 1000000 and ("%.2fm"):format(value / 1000000) or ("%dk"):format(value / 1000)
end

local dmg2_types = { SPELL_MISSED = true, SPELL_PERIODIC_MISSED = true, RANGE_MISSED = true }
local function Absorb_OnEvent(self,_,_,eventtype,_,_,_,_,_,dstGUID,_,_,_,misstype,_,dmg,misstype2,_,dmg2, ...)

  local data = self.data
  
  if (data.npcguid and data.npcguid == dstGUID) or (data.npcid and NID[dstGUID] == data.npcid) then
    local flag
    if misstype == "ABSORB" and eventtype == "SWING_MISSED" then  -- autoattack
      data.value = data.value + dmg
      flag = true            
    elseif misstype2 == "ABSORB" and dmg2_types[eventtype] then
      data.value = data.value + dmg2
      flag = true     
    end     
    
    if flag then
			-- reverse
			local perc = data.value / data.total
			if perc <= 0 or perc > 1 then self:Destroy() return end
			self:SetText(data.textformat:format(abbrev(data.total - data.value),data.atotal,(1-perc) * 100))
			self.statusbar:SetValue(1 - perc)
		end
    end
end

local DAMAGE_EVENTS = {
    ["SPELL_DAMAGE"] = true,
    ["SPELL_PERIODIC_DAMAGE"] = true,
    ["SWING_DAMAGE"] = true,
}

local function Inflict_OnEvent(self,_,_,eventtype,_,_,_,_,_,dstGUID,_,_,_,dmg,...)

  local data = self.data
  
  if (data.npcguid and data.npcguid == dstGUID) or (data.npcid and NID[dstGUID] == data.npcid) then
    local flag
    if DAMAGE_EVENTS[eventtype] then
        data.value = data.value + dmg
        flag = true
    end
    
    if flag then
			-- reverse
			local perc = data.value / data.total
			if perc <= 0 or perc > 1 then self:Destroy() return end
			self:SetText(data.textformat:format(abbrev(data.total - data.value),data.atotal,(1-perc) * 100))
			self.statusbar:SetValue(1 - perc)
		end
    end
end

function prototype:SetTotal(total) self.data.total,self.data.atotal = total,abbrev(total) end
function prototype:SetNPCID(npcid) self.data.npcid = npcid end
function prototype:SetNPCGUID(npcguid) self.data.npcguid = npcguid end
function prototype:SetTextFormat(textformat) self.data.textformat = textformat end
function prototype:UnregisterCLEU() self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") end

function module:Absorb(absorbtype, id, text, textFormat, totalTime, flashTime, sound, c1, c2, flashscreen, icon, total, npc, current, warningText, emphasizeWarning, emphasizeTimer)
    local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	if soundFile and not pfl.DisableSounds then module:Sound(soundFile) end
	if flashscreen then self:FlashScreen(c1Data) end
	local bar = GetBar()
	bar.data.value = current or 0
    bar.data.fillDirection = "DEPLETE"
	bar:SetID(id)
	bar:SetText(textFormat:format(abbrev(total),abbrev(total),100*(current or 0)/total))
	bar:Countdown(totalTime,flashTime,true)
	bar:SetColor(c1,c2)
    bar:SetIcon(icon)
	bar:SetTextFormat(textFormat)
    bar:SetSound(soundFile)
	bar:SetTotal(total)
    if npc then
        if npc.id then bar:SetNPCID(tonumber(npc.id)) end
        if npc.guid then bar:SetNPCGUID(npc.guid) end
	end
    
    if emphasizeTimer and pfl.EmphasisAnchor then
        bar:AnchorToEmphasis()
    else
        bar:AnchorToCenter()
    end
    if npc then
        bar:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        if absorbtype == "absorb" then
            bar:SetScript("OnEvent",Absorb_OnEvent)
        elseif absorbtype == "inflict" then
            bar:SetScript("OnEvent",Inflict_OnEvent)
        end
    end
	bar.statusbar:SetValue(1 - (bar.data.value / total))
	bar:ScheduleTimer("Fade",totalTime)
	bar:ScheduleTimer("UnregisterCLEU",totalTime)

	if c1Data then bar:SetColor(c1,c2) end
    
    if pfl.WarningMessages and pfl.WarnPopupMessage and text ~= "" then
        if not emphasizeWarning then
            Pour(warningText or text, icon, c1Data, false, id, idToReplace)
        else
            module:EmphasisedWarning(warningText or text, c1Data, icon, emphasizeWarning)
        end
    end
end



---------------------------------------------
-- HEAL ABSORB BARS
---------------------------------------------

local function AbsorbHeal_OnEvent(self,_,_,eventtype,_,_,_,_,_,dstGUID,_, _, _, _, _, _, _, _, absorbed)

    local data = self.data
    local flag
    if eventtype == "SPELL_HEAL" or eventtype == "SPELL_PERIODIC_HEAL" then
        if dstGUID == data.targetGUID then
            data.value = data.value + absorbed
            flag = true
        end
    end
    
    if flag then
        -- reverse
        local perc = data.value / data.total
        if perc <= 0 or perc > 1 then self:Destroy() return end
        self:SetText(data.textformat:format(abbrev(data.total - data.value),data.atotal,(1-perc) * 100))
        self.statusbar:SetValue(perc)
    end
end

function prototype:SetTargetGUID(targetGUID) self.data.targetGUID = targetGUID end

function module:AbsorbHeal(id, text, totalTime, flashTime, sound, c1, c2, flashscreen, icon, total, targetGUID, current, emphasizeTimer)
    local soundFile,c1Data,c2Data = GetMedia(sound,c1,c2)
	if soundFile and not pfl.DisableSounds then module:Sound(soundFile) end
	if flashscreen then self:FlashScreen(c1Data) end
	local bar = GetBar()
	bar.data.value = current or 0
    bar.data.fillDirection = "FILL"
	bar:SetID(id)
	bar:SetText(text:format(abbrev(total),abbrev(total),100))
	bar:Countdown(totalTime,flashTime,true)
	bar:SetColor(c1,c2)
    bar:SetIcon(icon)
	bar:SetTextFormat(text)
    bar:SetSound(soundFile)
	bar:SetTotal(total)
	bar:SetTargetGUID(targetGUID)
    if emphasizeTimer and pfl.EmphasisAnchor then
        bar:AnchorToEmphasis()
    else
        bar:AnchorToCenter()
    end
	bar:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	bar:SetScript("OnEvent",AbsorbHeal_OnEvent)
	bar.statusbar:SetValue(bar.data.value/total)
	bar:ScheduleTimer("Fade",totalTime)
	bar:ScheduleTimer("UnregisterCLEU",totalTime)

	if c1Data then bar:SetColor(c1,c2) end
end



---------------------------------------------
-- CUSTOM BARS
---------------------------------------------

do
	local L_ICON = "Interface\\Icons\\INV_Misc_PocketWatch_02"
	local R_ICON = "Interface\\Icons\\INV_Misc_PocketWatch_01"
	local YOU_PREFIX = L["YOU"]..": "
	local ID_PREFIX = "custom"
	local MSG_PTN = "^([%d:]+)%s+(.*)"
	local TIME_PTN = "^(%d+):(%d+)$"
	local DROPDOWN_THRES = 15
	local FORMAT_ERROR = L["Invalid input. Usage: |cffffd200%s time text|r"]
	local TIME_ERROR = L["Invalid time. The format must be |cffffd200minutes:seconds|r or |cffffd200seconds|r (e.g. 1:30 or 90)"]
	local OFFICER_ERROR = L["You need to be a raid officer"]
	local COMMTYPE = "AlertsRaidBar"

	local function fire(text,time,color,icon)
		local id = ID_PREFIX..text
		module:QuashByPattern(id)
		if time > DROPDOWN_THRES then
			module:Dropdown(id,text,time,DROPDOWN_THRES,pfl.CustomSound,color,nil,nil,icon)
		else
			module:CenterPopup(id,text,time,nil,pfl.CustomSound,color,nil,nil,icon)
		end
	end

	local helpers = {
		function() return UnitExists("target") and UnitName("target") or "<<"..L["None"]..">>" end,
	}

	local function replace(text)
		text = gsub(text,"%%t",helpers[1]())
		return text
	end

	local function parse(msg,slash)
		if type(msg) ~= "string" then addon:Print(format(FORMAT_ERROR,slash)) return end
		local time,text = msg:match(MSG_PTN)
		if not time then addon:Print(format(FORMAT_ERROR,slash)) return end
		local secs = tonumber(time)
		if not secs then
			local m,s = time:trim():match(TIME_PTN)
			if m then secs = (tonumber(m)*60) + tonumber(s)
			else addon:Print(TIME_ERROR) return end
		end
		return true,secs,replace(text)
	end

	local function LocalBarHandler(msg)
		local success,time,text = parse(msg,"/dxelb")
		if success then fire(YOU_PREFIX..text,time,pfl.CustomLocalClr,L_ICON) end
	end

	local function RaidBarHandler(msg)
		if not UnitIsRaidOfficer("player") then addon:Print(OFFICER_ERROR) return end
		local success,time,text = parse(msg,"/dxerb")
		if success then
			fire(YOU_PREFIX..text,time,pfl.CustomRaidClr,R_ICON)
			addon:SendRaidComm(COMMTYPE,time,CN[addon.PNAME]..": "..text)
		end
	end

	module["OnComm"..COMMTYPE] = function(self,event,commType,sender,time,text)
		if not UnitIsRaidOfficer(sender) then return end
		fire(text,time,pfl.CustomRaidClr,R_ICON)
	end

	addon.RegisterCallback(module,"OnComm"..COMMTYPE)

	SlashCmdList.DXEALERTLOCALBAR = LocalBarHandler
	SlashCmdList.DXEALERTRAIDBAR = RaidBarHandler

	SLASH_DXEALERTLOCALBAR1 = "/dxelb"
	SLASH_DXEALERTRAIDBAR1 = "/dxerb"
end

---------------------------------------------
-- BOSS EMOTE FILTER
---------------------------------------------
do
    local filter_registered = false
    local RaidBossEmoteFrame_OnEvent
    
    function addon:RegisterBossEmoteFilter(CE)       
        if not filter_registered then RaidBossEmoteFrame_OnEvent = RaidBossEmoteFrame:GetScript("OnEvent") end
        if not CE or CE.key == "default" or (not CE.bossmessages and (not CE.filters or not CE.filters.bossemotes)) then
            RaidBossEmoteFrame:SetScript("OnEvent", RaidBossEmoteFrame_OnEvent)
            filter_registered = false
            return
        end
        
        
        if not filter_registered then
            RaidBossEmoteFrame:SetScript("OnEvent", function(self,event,msg,...)
                if event ~= "RAID_BOSS_EMOTE" and event ~= "RAID_BOSS_WHISPER" then
                    RaidBossEmoteFrame_OnEvent(self,event,msg,...)
                else
                    local mdb = addon.db.profile.Encounters[addon.CE.key].bossmessages
                    local cleanMsg = msg
                    cleanMsg = format(cleanMsg,...) -- applying variables
                    cleanMsg = cleanMsg:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","") -- removing all coloring
                    cleanMsg = cleanMsg:gsub("|H(%a+):(%d+)|h",""):gsub("|h","") -- removing all links

                    local info = addon.CE.bossmessages or addon.CE.filters.bossemotes
                    for var,filter in pairs(info) do
                        -- Dealing with the icon
                        if filter.hasIcon and mdb[var] and mdb[var].removeIcon then
                            msg = string.gsub(msg,"|T[%a%d\\_%.]+:%d+|t[%s]?","")
                        end
                        
                        -- Dealing with the text
                        if mdb[var] and mdb[var].hide then
                            if string.find(cleanMsg, filter.pattern) then
                                return
                            end
                        end
                    end
                    
                    RaidBossEmoteFrame_OnEvent(self,event,msg,...)
                end
            end)
            filter_registered = true
        end
    end

end

---------------------------------------------
-- RAID WARNING FILTER
---------------------------------------------
do
    local RaidWarningFrame_OnEvent = RaidWarningFrame:GetScript("OnEvent")
    local filter_registered = false
    
    function addon:RegisterRaidWarningFilter(CE)
        if not CE or CE.key == "default" or not CE.filters or not CE.filters.raidwarnings then
            RaidWarningFrame:SetScript("OnEvent", RaidWarningFrame_OnEvent)
            filter_registered = false
            return
        end
        
        if not filter_registered then
            RaidWarningFrame:SetScript("OnEvent", function(self,event,msg,...)
                if event ~= "CHAT_MSG_RAID_WARNING" then
                    RaidWarningFrame_OnEvent(self,event,msg,...)
                else
                    local mdb = addon.db.profile.Encounters[addon.CE.key].raidmessages
                    local info = CE.filters.raidwarnings
                    
                    for var,filter in pairs(info) do
                        if mdb[var] and mdb[var].hide then
                            if string.find(msg, filter.pattern) then
                                return
                            end
                        end
                    end
                    RaidWarningFrame_OnEvent(self,event,msg,...)
                end
            end)
            filter_registered = true
        end
    end
end

---------------------------------------------
-- DEFEAT ANNOUNCEMENTS
---------------------------------------------
local defeatFrame
local heroicIconPath = "Interface\\Icons\\Spell_Holy_WeaponMastery"
local eventIconPath = "Interface\\Icons\\Spell_Holy_HolyGuidance"

do
    local nofade = false
    local since = 0
    local interval = 1/30
    local delay = 15
    local actualFrame
    local frame
    
    local function SetEncounterText(text)
        
        defeatFrame.encounterText:SetWidth(512)
        defeatFrame.encounterText:SetText(text)
        local textLength = text:len()
        if textLength <= 22 then
            defeatFrame.encounterText:SetFont("Fonts\\MORPHEUS.TTF", 30)
        else
            defeatFrame.encounterText:SetFont("Fonts\\MORPHEUS.TTF", math.floor((26*25)/textLength)-1)
        end
        defeatFrame.encounterText:SetWidth(defeatFrame.encounterText:GetStringWidth())
    end
    
    local function SetEncounterType(encounterType, settings)
        if encounterType == "event" or encounterType == "heroic" or encounterType == "normal" then
            local iconPath, iconPath2 = settings.iconPath, settings.iconPath2
            defeatFrame.leftIcon:SetTexture(type(iconPath) == "table" and iconPath[1] or iconPath)
            defeatFrame.rightIcon:SetTexture(type(iconPath2) == "table" and iconPath2[1] or iconPath2)
            defeatFrame.leftIcon:SetTexCoord(iconPath[2] and 1 or 0, iconPath[2] and 0 or 1,0,1)
            defeatFrame.rightIcon:SetTexCoord(iconPath[2] and 0 or 1, iconPath[2] and 1 or 0,0,1)
        end
        
        if encounterType == "event" or iconPath == heroicIconPath or iconPath == eventIconPath then
            if not pfl.LegionFrameHideEventIcons then 
                defeatFrame.leftIcon:ClearAllPoints()
                defeatFrame.rightIcon:ClearAllPoints()
                defeatFrame.leftIcon:SetPoint("CENTER",defeatFrame.encounterText,"CENTER",-220,1)
                defeatFrame.rightIcon:SetPoint("CENTER",defeatFrame.encounterText,"CENTER",220,1)
                defeatFrame.leftIcon:SetWidth(58)
                defeatFrame.leftIcon:SetHeight(58)
                defeatFrame.rightIcon:SetWidth(58)
                defeatFrame.rightIcon:SetHeight(58)
            end
        elseif encounterType == "battleground" then
            defeatFrame.leftIcon:SetTexture(nil)
            defeatFrame.rightIcon:SetTexture(nil)
        else
            defeatFrame.leftIcon:ClearAllPoints()
            defeatFrame.rightIcon:ClearAllPoints()
            defeatFrame.leftIcon:SetPoint("CENTER",defeatFrame.encounterText,"CENTER",-200,6)
            defeatFrame.rightIcon:SetPoint("CENTER",defeatFrame.encounterText,"CENTER",200,6)
            defeatFrame.leftIcon:SetWidth(128)
            defeatFrame.leftIcon:SetHeight(64)
            defeatFrame.rightIcon:SetWidth(128)
            defeatFrame.rightIcon:SetHeight(64)
        end
        if encounterType == "event" then
            defeatFrame.difficultyIcon = defeatFrame.difficultyIconEvent
            defeatFrame.defeatText:SetText("has been completed!")
        elseif encounterType == "battleground" then
            defeatFrame.defeatText:SetText(settings.victoryText or format("the Battle for %s",settings.battlegroundName))
            if settings.winningSide == "Alliance" then
                defeatFrame.difficultyIcon = defeatFrame.allianceIcon
            elseif settings.winningSide == "Horde" then
                defeatFrame.difficultyIcon = defeatFrame.hordeIcon
            end
        else
            defeatFrame.defeatText:SetText(format("%s been defeated",settings.plural and "have" or "has"))
            if encounterType == "heroic" then
                defeatFrame.difficultyIcon = defeatFrame.difficultyIconHeroic
            else
                defeatFrame.difficultyIcon = defeatFrame.difficultyIconNormal
            end
        end
        
        if encounterType == "battleground" then
            WorldStateScoreFrame:ClearAllPoints()
            WorldStateScoreFrame:SetPoint("TOP",defeatFrame,"BOTTOM",0,-25)
            defeatFrame.speedkillDivider:ClearAllPoints()
            defeatFrame.speedkillDivider:SetPoint("TOP",WorldStateScoreFrame,"BOTTOM",0,0)
            nofade = true
        else
            local delta
            if defeatAlert then
                delay = 15
                defeatFrame.speedkillEnabled = false
                delta = 0
                defeatFrame.speedkillDividerBottom:SetAlpha(0)
            else
                delta = 170
                delay = -15
            end
            defeatFrame.speedkillDivider:ClearAllPoints()
            defeatFrame.speedkillDivider:SetPoint("CENTER",defeatFrame,"CENTER",1,delta-104)
            nofade = false
        end
        
        defeatFrame.encounterType = encounterType
    end 
    
    local function SetSpeedkillRecord(recordTime)
        defeatFrame.speedkillValue:SetText(recordTime)
    end
       
    function module:HideLegionAlert()
        defeatFrame:SetScript("OnUpdate",nil)
        defeatFrame:SetAlpha(0)
        defeatFrame.defeatEnabled = false
        defeatFrame.speedkillEnabled = false
        UIErrorsFrame:SetAlpha(1)
        RaidWarningFrame:SetAlpha(1)
        RaidBossEmoteFrame:SetAlpha(1)
    end
    
    local HIGHLIGHT_DELAY = 55
    local HIGHLIGHT_DURATION = 210
    
    local frameOffset = HIGHLIGHT_DELAY + 2 * HIGHLIGHT_DURATION/5 + 1
    
    local middleSpecs = {
        [frameOffset]    = {y = -110, s = 1,    r = 0.05},
        [frameOffset+1]  = {y = -110, s = 0.98, r = 0.1},
        [frameOffset+2]  = {y = -109, s = 0.96, r = 0.15},
        [frameOffset+3]  = {y = -109, s = 0.94, r = 0},
        [frameOffset+4]  = {y = -109, s = 0.92, r = -0.05},
        [frameOffset+5]  = {y = -110, s = 0.9,  r = -0.16},
        [frameOffset+6]  = {y = -110, s = 0.88, r = -0.20},
        [frameOffset+7]  = {y = -111, s = 0.86, r = -0.32},
        [frameOffset+8]  = {y = -112, s = 0.84, r = -0.48},
        [frameOffset+9]  = {y = -113, s = 0.82, r = -0.48},
        [frameOffset+10] = {y = -114, s = 0.81, r = -0.32},
        [frameOffset+11] = {y = -114, s = 0.8,  r = -0.16}, 
        [frameOffset+12] = {y = -115, s = 0.76, r = 0}, -- low
        [frameOffset+13] = {y = -114, s = 0.82, r = 0.16},
        [frameOffset+14] = {y = -114, s = 0.94, r = 0.32},
        [frameOffset+15] = {y = -113, s = 1,    r = 0.48},
        [frameOffset+16] = {y = -113, s = 1.08, r = 0.5},
        [frameOffset+17] = {y = -113, s = 1.16, r = 0.48},
        [frameOffset+18] = {y = -112, s = 1.24, r = 0.32},
        [frameOffset+19] = {y = -112, s = 1.32, r = 0.16},
        [frameOffset+20] = {y = -112, s = 1.4,  r = 0},
        
        [frameOffset+21] = {y = -112, s = 1.4,  r = 0},
        [frameOffset+22] = {y = -112, s = 1.32, r = -0.16},
        [frameOffset+23] = {y = -112, s = 1.24, r = -0.32},
        [frameOffset+24] = {y = -113, s = 1.16, r = -0.48},
        [frameOffset+25] = {y = -113, s = 1.08, r = -0.5},
        [frameOffset+26] = {y = -113, s = 1,    r = -0.48},
        [frameOffset+27] = {y = -114, s = 0.94, r = -0.32},
        [frameOffset+28] = {y = -114, s = 0.82, r = -0.16},
        [frameOffset+29] = {y = -115, s = 0.76, r = 0.0},
        [frameOffset+30] = {y = -114, s = 0.8,  r = 0.16},
        [frameOffset+31] = {y = -114, s = 0.81, r = 0.32},
        [frameOffset+32] = {y = -113, s = 0.82, r = 0.48},
        [frameOffset+33] = {y = -113, s = 0.84, r = 0.48},
        [frameOffset+34] = {y = -112, s = 0.86, r = 0.32},
        [frameOffset+35] = {y = -111, s = 0.88, r = 0.16},
        [frameOffset+36] = {y = -110, s = 0.9,  r = 0.14},
        [frameOffset+37] = {y = -109, s = 0.92, r = 0.07},
        [frameOffset+38] = {y = -109, s = 0.94, r = -0.05},
        [frameOffset+39] = {y = -109, s = 0.96, r = -0.15},
        [frameOffset+40] = {y = -110, s = 0.98, r = -0.1},
        [frameOffset+41] = {y = -110, s = 1,    r = -0.05},
    }
    
    local function LegionAlertAnimation(self, elapsed)
        since = since + elapsed
        while(since > interval) do
            
            frame = actualFrame - delay
            if defeatFrame.defeatEnabled then
                -- Difficulty icon animation
                if frame <= 10 then
                    if frame<6 then defeatFrame.difficultyIcon:SetAlpha(frame/5) end
                    defeatFrame.difficultyIcon:SetWidth(defeatFrame.difficultyIcon.originalWidth * (1+(10-frame)))
                    defeatFrame.difficultyIcon:SetHeight(defeatFrame.difficultyIcon.originalHeight * (1+(10-frame)))
                else
                    defeatFrame.difficultyIcon:SetAlpha(1)
                    defeatFrame.difficultyIcon:SetWidth(defeatFrame.difficultyIcon.originalWidth)
                    defeatFrame.difficultyIcon:SetHeight(defeatFrame.difficultyIcon.originalHeight)
                end
                
                -- Star animation
                if frame <= 10 then
                    defeatFrame.star:SetAlpha(0)
                elseif frame <= 18 then
                    if frame < 15 then defeatFrame.star:SetAlpha(1/4*(frame-10)) end
                    defeatFrame.star:SetWidth(defeatFrame.star.originalWidth * (1+((8-(frame-10)))/3))
                    defeatFrame.star:SetHeight(defeatFrame.star.originalHeight * (1+((8-(frame-10))/3)))
                elseif frame < 37 then
                    defeatFrame.star:SetAlpha(1 - (frame-14)/17)
                    defeatFrame.star:SetWidth(defeatFrame.star.originalWidth)
                    defeatFrame.star:SetHeight(defeatFrame.star.originalHeight)
                elseif frame >= 37 then
                    defeatFrame.star:SetAlpha(0)
                end
                -- Star Wide animation
                if frame > 18 and frame < 32 then
                    defeatFrame.starWide:SetAlpha(0.6 - ((0.6*(frame-18))/13))
                    defeatFrame.starWide:SetWidth(defeatFrame.starWide.originalWidth*(1+((0.4*(frame-18))/13)))
                end
                
                -- Texture and encounter text
                if frame <= 18 then
                    defeatFrame.t:SetAlpha(0)
                    defeatFrame.encounterText:SetAlpha(0)
                    defeatFrame.defeatText:SetAlpha(0)
                    defeatFrame.leftIcon:SetAlpha(0)
                    defeatFrame.rightIcon:SetAlpha(0)
                elseif frame <= 23 then
                    defeatFrame.t:SetAlpha((frame-18)/5)
                    defeatFrame.encounterText:SetAlpha((frame-18)/5)
                    defeatFrame.defeatText:SetAlpha((frame-18)/5)
                        defeatFrame.leftIcon:SetAlpha((frame-18)/5)
                        defeatFrame.rightIcon:SetAlpha((frame-18)/5)

                else
                    defeatFrame.t:SetAlpha(1)
                    defeatFrame.encounterText:SetAlpha(1)
                    defeatFrame.defeatText:SetAlpha(1)
                    if defeatFrame.encounterType ~= "normal" then
                        defeatFrame.leftIcon:SetAlpha(1)
                        defeatFrame.rightIcon:SetAlpha(1)
                    end
                end
                
                -- Highlight
                
                defeatFrame.highlight:SetAlpha(1)
                if frame <= HIGHLIGHT_DELAY then 
                    defeatFrame.highlight:SetPoint("CENTER",defeatFrame,"TOPLEFT",90,-110)
                elseif frame <= HIGHLIGHT_DELAY + HIGHLIGHT_DURATION then
                    defeatFrame.highlight:SetPoint("CENTER",defeatFrame,"TOPLEFT",90+330*((frame-HIGHLIGHT_DELAY)/HIGHLIGHT_DURATION),middleSpecs[frame] and middleSpecs[frame].y or -110)
                    defeatFrame.highlight:SetRotation(middleSpecs[frame] and middleSpecs[frame].r or 0)
                else
                    defeatFrame.highlight:SetPoint("CENTER",defeatFrame,"TOPLEFT",420,-110)
                end
                
                if frame <= HIGHLIGHT_DELAY then
                    defeatFrame.highlight:SetAlpha(0)
                    defeatFrame.highlight:SetWidth(1)
                    defeatFrame.highlight:SetHeight(1)
                elseif frame <= HIGHLIGHT_DELAY + HIGHLIGHT_DURATION/10 then
                    defeatFrame.highlight:SetAlpha(1)
                    defeatFrame.highlight:SetWidth((256*(frame-HIGHLIGHT_DELAY))/(HIGHLIGHT_DURATION/10))
                    defeatFrame.highlight:SetHeight((256*(frame-HIGHLIGHT_DELAY))/(HIGHLIGHT_DURATION/10))
                elseif frame < HIGHLIGHT_DELAY + 2 * HIGHLIGHT_DURATION/5 then
                    defeatFrame.highlight:SetAlpha(1)
                    defeatFrame.highlight:SetWidth(256 * (1 - 0.1*math.sin((frame - HIGHLIGHT_DELAY - HIGHLIGHT_DURATION/10)/10)))
                    defeatFrame.highlight:SetHeight(256 * (1 - 0.1*math.sin((frame - HIGHLIGHT_DELAY - HIGHLIGHT_DURATION/10)/10)))
                elseif frame < HIGHLIGHT_DELAY + 2 * HIGHLIGHT_DURATION/5 + 2*HIGHLIGHT_DURATION/10 then
                    local mult = middleSpecs[frame] and middleSpecs[frame].s or 1
                    defeatFrame.highlight:SetWidth(256 * mult)
                    defeatFrame.highlight:SetHeight(256 * mult)
                elseif frame < HIGHLIGHT_DELAY + HIGHLIGHT_DURATION - HIGHLIGHT_DURATION/10 then
                    defeatFrame.highlight:SetWidth(256 * (1 - 0.1*math.sin((frame - HIGHLIGHT_DELAY - 2 * HIGHLIGHT_DURATION/5 - 2*HIGHLIGHT_DURATION/10)/10)))
                    defeatFrame.highlight:SetHeight(256 * (1 - 0.1*math.sin((frame - HIGHLIGHT_DELAY - 2 * HIGHLIGHT_DURATION/5 - 2*HIGHLIGHT_DURATION/10)/10)))
                    defeatFrame.highlight:SetAlpha(1)
                elseif frame < HIGHLIGHT_DELAY + HIGHLIGHT_DURATION then
                    defeatFrame.highlight:SetAlpha(1)
                    defeatFrame.highlight:SetWidth((256*(HIGHLIGHT_DELAY + HIGHLIGHT_DURATION + 1 -frame))/(HIGHLIGHT_DURATION/10))
                    defeatFrame.highlight:SetHeight((256*(HIGHLIGHT_DELAY + HIGHLIGHT_DURATION + 1 -frame))/(HIGHLIGHT_DURATION/10))
                else
                    defeatFrame.highlight:SetAlpha(0)
                    defeatFrame.highlight:SetWidth(1)
                    defeatFrame.highlight:SetHeight(1)
                end
                
            end
            
            if defeatFrame.speedkillEnabled then
                if frame > 30 and frame <= 40 then
                    defeatFrame.speedkillDivider:SetAlpha((frame-30)/10)
                    defeatFrame.speedkillDivider:SetWidth(defeatFrame.speedkillDivider.originalWidth*(1-(10-(frame-30))*0.08))
                    defeatFrame.speedkillDivider:SetHeight(defeatFrame.speedkillDivider.originalHeight*(1-(10-(frame-30))*0.08))
                    defeatFrame.speedkillDividerBottom:SetAlpha((frame-30)/10)
                    defeatFrame.speedkillDividerBottom:SetWidth(defeatFrame.speedkillDivider.originalWidth*(1-(10-(frame-30))*0.08))
                    defeatFrame.speedkillDividerBottom:SetHeight(defeatFrame.speedkillDivider.originalHeight*(1-(10-(frame-30))*0.08))
                end
                if frame > 40 and frame <= 60 then
                    defeatFrame.speedkillLabel:SetAlpha((frame-40)/20)
                    defeatFrame.speedkillValue:SetAlpha((frame-40)/20)
                end
            end
            
            if frame > 270 then
                if nofade then
                    defeatFrame:SetScript("OnUpdate",nil)
                else
                    defeatFrame:SetAlpha(1-((frame-270)/60))
                end
            end
            
            if frame > 330 then
                module:HideLegionAlert()
            end
            since = since - interval
            actualFrame = actualFrame + 1
        end
    end
    
    local function StartLegionAlertAnimation(defeatAlert)
        UIErrorsFrame:SetAlpha(0)
        RaidNotice_Clear(RaidWarningFrame); 
        RaidNotice_Clear(RaidBossEmoteFrame); 
        module:Alert_Clear()
        RaidWarningFrame:SetAlpha(0)
        RaidBossEmoteFrame:SetAlpha(0)
        actualFrame = 1
        since = 0
        defeatFrame.difficultyIconHeroic:SetAlpha(0)
        defeatFrame.difficultyIconNormal:SetAlpha(0)
        defeatFrame.difficultyIconEvent:SetAlpha(0)
        defeatFrame.allianceIcon:SetAlpha(0)
        defeatFrame.hordeIcon:SetAlpha(0)
        defeatFrame.t:SetAlpha(0)
        defeatFrame.encounterText:SetAlpha(0)
        defeatFrame.defeatText:SetAlpha(0)
        defeatFrame.star:SetAlpha(0)
        defeatFrame.starWide:SetAlpha(0)
        defeatFrame.leftIcon:SetAlpha(0)
        defeatFrame.rightIcon:SetAlpha(0)
        defeatFrame.speedkillDivider:SetAlpha(0)
        defeatFrame.speedkillDividerBottom:SetAlpha(0)
        defeatFrame.speedkillLabel:SetAlpha(0)
        defeatFrame.speedkillValue:SetAlpha(0)
        defeatFrame:SetAlpha(1)
        defeatFrame.defeatEnabled = defeatAlert
        local delta
        if defeatAlert then
            delay = 15
            defeatFrame.speedkillEnabled = false
            delta = 0
            defeatFrame.speedkillDividerBottom:SetAlpha(0)
        else
            delta = 170
            delay = -15
        end
        defeatFrame.speedkillDivider:SetPoint("CENTER",defeatFrame,"CENTER",1,delta-104)
        defeatFrame.speedkillDividerBottom:SetPoint("CENTER",defeatFrame.speedkillDivider,"CENTER",0,delta-86)
        defeatFrame.speedkillLabel:SetPoint("CENTER",defeatFrame.speedkillDivider,"CENTER",0,delta-26)
        defeatFrame.speedkillValue:SetPoint("CENTER",defeatFrame.speedkillDivider,"CENTER",0,delta-56)
        defeatFrame:SetScript("OnUpdate", LegionAlertAnimation)
    end
    
    function module:EncounterDefeatedAlert(CE, heroic, sound)
        local encounterName = CE.name
        local encounterIcon = CE.icon or ((outputType == "LEGION_OUTPUT" and heroic) and heroicIconPath or "")
        local encounterIcon2 = CE.icon2 or encounterIcon 
        local outputType = addon.db.profile.SpecialWarnings.SpecialOutput
        
        if not pfl.DisableSounds then module:Sound(sound) end
        if outputType == "LEGION_OUTPUT" then
            if pfl.LegionFrameHideEncounterIcons then encounterIcon = "";encounterIcon2 = "" end
            local settings = {
                iconPath = encounterIcon,
                iconPath2 = encounterIcon2,
                plural = CE.plural
            }
            
            module:UpdateDefeatAlertPosition()
            SetEncounterText(encounterName)
            SetEncounterType(heroic and "heroic" or "normal", settings)
            StartLegionAlertAnimation(true)
        else
            local prefix = heroic and "Heroic |TInterface\\EncounterJournal\\UI-EJ-HeroicTextIcon.PNG:8:8:0:2|t " or ""
            local text = format("|cffffcd04%s|r|cffffffff%s|r |cffffcd04%s|r",prefix,encounterName,"defeated!")
            module:Special("dxespecial_defeat",text,"WHITE", addon.ST[45401], outputType, true, "dxespecial_defeat")
        end
    end
    
    function module:EventCompletedAlert(CE, sound)
        local eventName = CE.name
        local encounterIcon = CE.icon or eventIconPath
        local encounterIcon2 = CE.icon2 or encounterIcon
        local outputType = addon.db.profile.SpecialWarnings.SpecialOutput
        
        if not pfl.DisableSounds then module:Sound(sound) end
        if outputType == "LEGION_OUTPUT" then
            if pfl.LegionFrameHideEventIcons then encounterIcon = "";encounterIcon2 = "" end
            local settings = {
                iconPath = encounterIcon,
                iconPath2 = encounterIcon2,
            }
            
            module:UpdateDefeatAlertPosition()
            SetEncounterText(eventName)
            SetEncounterType("event", settings)
            StartLegionAlertAnimation(true)
        else
            local text = format("|cffffffff%s|r |cffffcd04%s|r",eventName,"complete!")
            module:Special("dxespecial_complete",text,"WHITE", addon.AT[945], outputType, true, "dxespecial_complete")
        end
    end
    
    local FactionValues = {
        Alliance = {
            text = "Alliance",
            icon = "Interface\\ICONS\\PVPCurrency-Honor-Alliance",
        },
        Horde = {
            text = "Horde",
            icon = "Interface\\ICONS\\PVPCurrency-Honor-Horde",
        }
    }
    
    function module:BattlegroundWonAlert(CE, winningSide, sound)
        local outputType = addon.db.profile.SpecialWarnings.SpecialOutput
        
        if outputType == "LEGION_OUTPUT" then
            if pfl.LegionFrameHideEncounterIcons then encounterIcon = "";encounterIcon2 = "" end
            local settings = {
                winningSide = winningSide,
                battlegroundName = CE.name,
                victoryText = CE.victorytext
            }
            
            module:UpdateDefeatAlertPosition()
            SetEncounterText(format("%s wins",FactionValues[winningSide].text))
            SetEncounterType("battleground", settings)
            module:SetWinScoreTextLater()
            StartLegionAlertAnimation(true)
        else
         --   local prefix = heroic and "Heroic |TInterface\\EncounterJournal\\UI-EJ-HeroicTextIcon.PNG:8:8:0:2|t " or ""
            local text = format("%s wins!",winningSide)
            local icon = FactionValues[winningSide].icon
            module:Special("dxespecial_defeat",text,"WHITE", icon, outputType, true, "dxespecial_defeat")
        end
    end
        
    function module:SetWinScoreTextLater()
        module:ScheduleTimer("SetWinScoreText",0.01)
    end
    
    local textToSet, colorsLeftToSet, colorsRightToSet, colorsTextToSet
    
    function module:SetWinScoreText()
        if not WorldStateScoreFrame:IsShown() then return end
        if select(2,GetInstanceInfo()) ~= "pvp" then return end
                
        local scoreBoardStatusText
        
        if GetBattlefieldWinner() == 2 then
            if addon:IsRunning() then
                if BATTLEFIELD_SHUTDOWN_TIMER ~= 0 then
                    scoreBoardStatusText = "Final Score - Time out"
                    colorsLeftToSet  = {0.2, 0.2, 0.2}
                    colorsRightToSet = {0.2, 0.2, 0.2}
                    colorsTextToSet  = {1, 1, 1}
                else
                    scoreBoardStatusText = "Final Score - A draw"
                    colorsLeftToSet  = {0.57, 0.53, 0.17}
                    colorsRightToSet = {0.57, 0.53, 0.17}
                    colorsTextToSet  = {1, 1, 1}
                end
                WorldStateScoreWinnerFrameLeft:SetVertexColor(unpack(colorsLeftToSet))
                WorldStateScoreWinnerFrameRight:SetVertexColor(unpack(colorsRightToSet))
                WorldStateScoreWinnerFrameText:SetVertexColor(unpack(colorsTextToSet))
                textToSet = scoreBoardStatusText
            else
                WorldStateScoreWinnerFrameLeft:SetVertexColor(unpack(colorsLeftToSet))
                WorldStateScoreWinnerFrameRight:SetVertexColor(unpack(colorsRightToSet))
                WorldStateScoreWinnerFrameText:SetVertexColor(unpack(colorsTextToSet))
                scoreBoardStatusText = textToSet
            end
        else
            scoreBoardStatusText = "Final Score"
        end
        WorldStateScoreWinnerFrameText:SetText(scoreBoardStatusText)
    end
    
    function module:SpeedkillRecordAlert(recordTime, victoryAnnounced)
        local outputType = addon.db.profile.SpecialWarnings.SpecialOutput
        
        if outputType == "LEGION_OUTPUT" then
            SetSpeedkillRecord(recordTime)
            defeatFrame.speedkillEnabled = true
            if defeatFrame.defeatEnabled then
                defeatFrame.speedkillLabel:SetText("in a new record of")
            else
                defeatFrame.speedkillLabel:SetText("This is a new record of")
                StartLegionAlertAnimation(false)
            end
        else
            local text = format("\124cffffffffThis is a new record of \124r\124cffffd700%s\124r\124cffffffff!\124r",recordTime)
            
            module:Special("dxespecial_speedkill",text,"WHITE", not victoryAnnounced and addon.ST[93578] or nil, outputType, true, "dxespecial_speedkill")
        end
    end
    
    function module:UpdateDefeatAlertPosition()
        defeatFrame:SetPoint("TOP",UIParent,"TOP",0,-150 - pfl.LegionFrameYOffset)
        defeatFrame:SetScale(pfl.LegionFrameScale,pfl.LegionFrameScale)
    end

    -- Defeat frame setup
    defeatFrame = CreateFrame("Frame","DXE Defeat frame",UIParent)
    defeatFrame:SetFrameStrata("HIGH")
    defeatFrame:SetHeight(128)
    defeatFrame:SetWidth(512)

    defeatFrame.t = defeatFrame:CreateTexture(nil,"OVERLAY",nil,1)
    defeatFrame.t:SetTexture("Interface\\AddOns\\DXE\\Textures\\DefeatFrame\\background.tga")
    defeatFrame.t:SetPoint("TOPLEFT")
    defeatFrame.t:SetPoint("BOTTOMRIGHT")
    
    local star = defeatFrame:CreateTexture(nil,"OVERLAY",nil,3)
    star:SetTexture("Interface\\Addons\\DXE\\Textures\\DefeatFrame\\background_star_highlight.tga")
    star:SetWidth(128)
    star:SetHeight(128)
    star.originalWidth = star:GetWidth()
    star.originalHeight = star:GetHeight()
    star:SetBlendMode("ADD")
    star:SetPoint("CENTER",defeatFrame,"CENTER",0,22)
    defeatFrame.star = star

    local highlight = defeatFrame:CreateTexture(nil, "OVERLAY",nil,4)
    highlight:SetTexture("Interface\\Addons\\DXE\\Textures\\DefeatFrame\\glint.tga")
    highlight:SetWidth(256)
    highlight:SetHeight(256)
    highlight:SetPoint("CENTER",defeatFrame,"TOPLEFT",80,-57)
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0)
    defeatFrame.highlight = highlight
    
    local starWide = defeatFrame:CreateTexture(nil,"OVERLAY",nil,3)
    starWide:SetTexture("Interface\\Addons\\DXE\\Textures\\DefeatFrame\\background_star_highlight.tga")
    starWide:SetWidth(128)
    starWide:SetHeight(128)
    starWide.originalWidth = starWide:GetWidth()
    starWide.originalHeight = starWide:GetHeight()
    starWide:SetBlendMode("ADD")
    starWide:SetPoint("CENTER",defeatFrame,"CENTER",0,22)
    defeatFrame.starWide = starWide
    
    local difficultyIconHeroic = defeatFrame:CreateTexture(nil,"OVERLAY",nil,2)
    difficultyIconHeroic:SetTexture("Interface\\Addons\\DXE\\Textures\\DefeatFrame\\emblem_heroic.tga")
    difficultyIconHeroic:SetPoint("CENTER",defeatFrame,"CENTER",1,22)
    difficultyIconHeroic:SetWidth(62)
    difficultyIconHeroic:SetHeight(62)
    difficultyIconHeroic.originalWidth = difficultyIconHeroic:GetWidth()
    difficultyIconHeroic.originalHeight = difficultyIconHeroic:GetHeight()
    defeatFrame.difficultyIconHeroic = difficultyIconHeroic
    
    local difficultyIconNormal = defeatFrame:CreateTexture(nil,"OVERLAY",nil,2)
    difficultyIconNormal:SetTexture("Interface\\Addons\\DXE\\Textures\\DefeatFrame\\emblem_normal.tga")
    difficultyIconNormal:SetWidth(62)
    difficultyIconNormal:SetHeight(62)
    difficultyIconNormal:SetPoint("CENTER",defeatFrame,"CENTER",1,22)
    difficultyIconNormal.originalWidth = difficultyIconNormal:GetWidth()
    difficultyIconNormal.originalHeight = difficultyIconNormal:GetHeight()
    defeatFrame.difficultyIconNormal = difficultyIconNormal
    
    local difficultyIconEvent = defeatFrame:CreateTexture(nil,"OVERLAY",nil,3)
    difficultyIconEvent:SetTexture("Interface\\Addons\\DXE\\Textures\\DefeatFrame\\emblem_event.tga")
    difficultyIconEvent:SetWidth(62)
    difficultyIconEvent:SetHeight(62)
    difficultyIconEvent:SetPoint("CENTER",defeatFrame,"CENTER",1,22)
    difficultyIconEvent.originalWidth = difficultyIconEvent:GetWidth()
    difficultyIconEvent.originalHeight = difficultyIconEvent:GetHeight()
    defeatFrame.difficultyIconEvent = difficultyIconEvent
    difficultyIconEvent:SetAlpha(1)

    local allianceIcon = defeatFrame:CreateTexture(nil,"OVERLAY",nil,3)
    allianceIcon:SetTexture("Interface\\Addons\\DXE\\Textures\\DefeatFrame\\emblem_alliance.tga")
    allianceIcon:SetWidth(62)
    allianceIcon:SetHeight(62)
    allianceIcon:SetPoint("CENTER",defeatFrame,"CENTER",1,22)
    allianceIcon.originalWidth = allianceIcon:GetWidth()
    allianceIcon.originalHeight = allianceIcon:GetHeight()
    defeatFrame.allianceIcon = allianceIcon
    
    local hordeIcon = defeatFrame:CreateTexture(nil,"OVERLAY",nil,3)
    hordeIcon:SetTexture("Interface\\Addons\\DXE\\Textures\\DefeatFrame\\emblem_horde.tga")
    hordeIcon:SetWidth(62)
    hordeIcon:SetHeight(62)
    hordeIcon:SetPoint("CENTER",defeatFrame,"CENTER",1,22)
    hordeIcon.originalWidth = hordeIcon:GetWidth()
    hordeIcon.originalHeight = hordeIcon:GetHeight()
    defeatFrame.hordeIcon = hordeIcon
    
    local encounterText = defeatFrame:CreateFontString(nil,"OVERLAY")
    encounterText:SetFont("Fonts\\MORPHEUS.TTF", 30)
    encounterText:SetPoint("CENTER",defeatFrame,"CENTER",0,-20)
    encounterText:SetShadowColor(0.38, 0.25, 0, 0.9)
    encounterText:SetShadowOffset(1,-1)
    encounterText:SetHeight(128)
    encounterText:SetWordWrap(false)
    defeatFrame.encounterText = encounterText
    
    local defeatText = defeatFrame:CreateFontString(nil,"OVERLAY")
    defeatText:SetFont("Fonts\\FRIZQT__.ttf", 18)
    defeatText:SetPoint("CENTER",defeatFrame,"CENTER",0,-70)
    defeatText:SetTextColor(1,0.8,0.01)
    defeatText:SetShadowColor(0,0,0,0.75)
    defeatText:SetShadowOffset(2,-2)
    defeatText:SetWidth(512)
    defeatText:SetHeight(64)
    defeatFrame.defeatText = defeatText
    
    
    local leftIcon = defeatFrame:CreateTexture(nil,"OVERLAY",nil,2)
    leftIcon:SetPoint("RIGHT",encounterText,"LEFT",-10,0)
    leftIcon:SetWidth(30)
    leftIcon:SetHeight(30)
    defeatFrame.leftIcon = leftIcon

    local rightIcon = defeatFrame:CreateTexture(nil,"OVERLAY",nil,2)
    rightIcon:SetPoint("LEFT",encounterText,"RIGHT",10,0)
    rightIcon:SetWidth(30)
    rightIcon:SetHeight(30)
    defeatFrame.rightIcon = rightIcon
    
    local speedkillDivider = defeatFrame:CreateTexture(nil,"OVERLAY",nil,3)
    speedkillDivider:SetTexture("Interface\\Addons\\DXE\\Textures\\DefeatFrame\\glyph_top.tga")
    speedkillDivider:SetWidth(64)
    speedkillDivider:SetHeight(64)
    speedkillDivider.originalWidth = speedkillDivider:GetWidth()
    speedkillDivider.originalHeight = speedkillDivider:GetHeight()
    defeatFrame.speedkillDivider = speedkillDivider
    speedkillDivider:SetAlpha(1)
    
    local speedkillDividerBottom = defeatFrame:CreateTexture(nil,"OVERLAY",nil,3)
    speedkillDividerBottom:SetTexture("Interface\\Addons\\DXE\\Textures\\DefeatFrame\\glyph_bottom.tga")
    speedkillDividerBottom:SetWidth(64)
    speedkillDividerBottom:SetHeight(64)
    speedkillDividerBottom.originalWidth = speedkillDividerBottom:GetWidth()
    speedkillDividerBottom.originalHeight = speedkillDividerBottom:GetHeight()
    defeatFrame.speedkillDividerBottom = speedkillDividerBottom
    speedkillDividerBottom:SetAlpha(0)
    
    local speedkillLabel = defeatFrame:CreateFontString(nil,"OVERLAY")
    speedkillLabel:SetFont("Fonts\\FRIZQT__.ttf", 24)
    speedkillLabel:SetTextColor(1,1,1)
    speedkillLabel:SetShadowColor(0,0,0,0.75)
    speedkillLabel:SetShadowOffset(2,-2)
    speedkillLabel:SetWidth(512)
    speedkillLabel:SetHeight(64)
    defeatFrame.speedkillLabel = speedkillLabel
    
    
    local speedkillValue = defeatFrame:CreateFontString(nil,"OVERLAY")
    speedkillValue:SetFont("Interface\\Addons\\DXE\\Fonts\\FGM.ttf", 28, "OUTLINE")
    speedkillValue:SetTextColor(1,0.8,0.01)
    speedkillValue:SetShadowColor(0,0,0,0.75)
    speedkillValue:SetShadowOffset(2,-2)
    speedkillValue:SetWidth(512)
    speedkillValue:SetHeight(64)
    defeatFrame.speedkillValue = speedkillValue
    defeatFrame:SetAlpha(0)
end

---------------------------------------------
-- ALERT TESTS
---------------------------------------------
do 
    local TEST_TIME_DEFAULT = 5
    local AlertTestingRunning = false
    local TestTimers = {}

    function module:IsTestingRunning()
        return AlertTestingRunning
    end
    
    local TEST_DATA = {
        warning = {
            timemin = 2,
            timemax = 6,
            testfunc = function(alertKey, warningData)
                module:Simple(alertKey, warningData.text, 4,"None",warningData.color1, nil, warningData.icon)
            end,
            alerts = {
                {text = "Stomp",                            color1 = "YELLOW",      icon = addon.ST[103414]},
                {text = "Black Phase",                      color1 = "WHITE",       icon = addon.ST[108794]},
                {text = "Deep Corruption",                  color1 = "PURPLE",      icon = addon.ST[105171]},
                {text = "Frost Phase",                      color1 = "CYAN",        icon = addon.ST[63562]},
                {text = "Hour of Twilight",                 color1 = "RED",         icon = addon.ST[103327]},
                {text = "Twilight Onslaught",               color1 = "MAGENTA",     icon = addon.ST[106401]},
                {text = "Amalgamation gets Superheated",    color1 = "GOLD",        icon = addon.ST[105834]},
                {text = "Cataclysm",                        color1 = "GOLD",        icon = addon.ST[110044]},
                
                {text = "Hurl Spear",                       color1 = "YELLOW",      icon = addon.ST[71466]},
                {text = "The Widow's Kiss",                 color1 = "LIGHTGREEN",  icon = addon.ST[99476]},
                {text = "Heated Volcano",                   color1 = "WHITE",       icon = addon.ST[98493]},
                {text = "Firestorm",                        color1 = "YELLOW",      icon = addon.ST[100744]},
                {text = "Shards of Torment",                color1 = "MAGENTA",     icon = addon.ST[99259]},
                {text = "Searing Seeds",                    color1 = "YELLOW",     icon = addon.ST[98450]},
                {text = "Sulfuras Smash",                   color1 = "BROWN",     icon = addon.ST[100258]},
            },
        },
        dropdown = {
            timemin = 1,
            timemax = 5,
            testfunc = function(alertKey, warningData) 
                module:Dropdown(alertKey, warningData.text, warningData.time, warningData.flashtime or 5, "None", warningData.color1, warningData.color2 or warningData.color1, nil, warningData.icon)
            end,
            alerts = {
                {text = "Next Black Blood Phase",         time = 10, color1 = "BLACK",     color2 = "GREY", icon = addon.ST[103851]},
                {text = "New Void of the Unmaking",       time = 7,  color1 = "MAGENTA",                    icon = addon.ST[693]},
                {text = "Next Void Bolt",                 time = 7,  color1 = "MAGENTA",                    icon = addon.ST[108384]},
                {text = "Next Focused Assault",           time = 15, color1 = "YELLOW",    color2 = "GOLD", icon = addon.ST[107851]},
                {text = "Next Fading Light",              time = 10, color1 = "ORANGE",                     icon = addon.ST[105925]},
                {text = "Twilight Elite Slayer",          time = 8,  color1 = "GREEN",                      icon = addon.ST[80325]},
                {text = "Next Roll",                      time = 16, color1 = "ORANGE",                     icon = addon.EJST[4050]},
                {text = "New Mutated Corruption",         time = 12, color1 = "LIGHTGREEN",                 icon = addon.ST[104972]},
                
                {text = "Next Throw Crystal Prison Trap", time = 20, color1 = "TURQUOISE",                  icon = addon.ST[99836]},
                {text = "Next Smoldering Devastation",    time = 15, color1 = "ORANGE",    color2 = "RED",  icon = addon.ST[99052]},
                {text = "Next Concussive Stomp",          time = 12, color1 = "YELLOW",                     icon = addon.ST[100411]},
                {text = "Next Firestorm",                 time = 8,  color1 = "YELLOW",                     icon = addon.ST[100744]},
                {text = "Next Inferno Strike",            time = 10, color1 = "RED",                        icon = addon.ST[101002]},
                {text = "Next Leaping Flames",            time = 12, color1 = "ORANGE",                     icon = addon.ST[98535]},
                {text = "Next Magma Trap",                time = 8,  color1 = "ORANGE",                     icon = addon.ST[101233]},
            },
        },
        centerpopup = {
            timemin = 5,
            timemax = 10,
            testfunc = function(alertKey, warningData) 
                module:CenterPopup(alertKey, warningData.text, warningData.time, warningData.flashtime or 5, "None", warningData.color1, warningData.color2 or warningData.color1, nil, warningData.icon, false, nil, false, false, warningData.deplete and "DEPLETE" or "FILL")
            end,
            alerts = {
                {text = "Next Focused Anger", time = 6, color1 = "ORANGE", icon = addon.ST[104543]},
                {text = "Next Searing Bloods", time = 7, color1 = "RED", icon = addon.ST[108356]},
                {text = "Feedback ends", time = 15, flashtime = 15, color1 = "TEAL", icon = addon.ST[108934]},
                {text = "Shockwave", time = 3, color1 = "YELLOW", icon = addon.ST[108046]},
                {text = "Seal Armor closes", time = 23, color1 = "ORANGE", icon = addon.ST[105847]},
                {text = "Ember Flare", time = 6, color1 = "ORANGE", icon = addon.ST[100936]},
                {text = "The Widow's Kiss dissipates", time = 10, color1 = "RED", color2 = "ORANGE", icon = addon.ST[99476]},
                {text = "Magma Flow ends", time = 10, color1 = "PEACH", icon = addon.ST[97225]},
                {text = "Fiery Vortex", time = 10, color1 = "LIGHTBLUE", color2 = "CYAN", icon = addon.ST[99794]},
                {text = "Decimation Blade fades", time = 15, color1 = "PURPLE", deplete = true, icon = addon.ST[99352]},
                {text = "Next Flame Scythe", time = 8, color1 = "YELLOW", icon = addon.ST[100213]},
            },
        },
        emphasizedcenter = {
            timemin = 5,
            timemax = 10,
            testfunc = function(alertKey, warningData) 
                module:CenterPopup(alertKey, warningData.text, warningData.time, warningData.flashtime or 5, "None", warningData.color1, warningData.color2 or warningData.color1, nil, warningData.icon, false, nil, false, true, warningData.deplete and "DEPLETE" or "FILL")
            end,
            alerts = {
                {text = "Resonating Crystal explodes", time = 13, color1 = "MAGENTA", icon = addon.ST[103640]},
                {text = "Molten Seed", time = 12, color1 = "ORANGE", icon = addon.ST[98333]},
                {text = "Bloods: Next heal", time = 10, color1 = "RED", color2 = "ORANGE", icon = addon.ST[105937]},
            },
        },
        individual = {
            timemin = 5,
            timemax = 10,
            testfunc = function(alertKey, warningData) 
                addon:HideLFGCountdown()
                addon:HideRBGCountdown()
                addon["Show"..warningData.type.."Countdown"](addon,nil,true,true)
            end,
            alerts = {
                {type = "RBG"},
                {type = "LFG"},
            },
        },
    }
    
    local testRoster = {}
    local usedTestRoster = {}
    
    local function GetRandomTestTime(testtype)
        local info = TEST_DATA[testtype]
        if info then
            return math.random(info.timemin, info.timemax)
        else
            return TEST_TIME_DEFAULT
        end
    end
    
    local function GetRandomTestData(testtype)
        local info = TEST_DATA[testtype]

        if info then
            if #testRoster[testtype] == 0 then
                -- copy everything but the last value
                for i=1,#usedTestRoster[testtype] - 1 do
                    table.insert(testRoster[testtype], usedTestRoster[testtype][i])
                end
                
                -- remove everything but the last value
                while #usedTestRoster[testtype] > 1 do
                    table.remove(usedTestRoster[testtype], 1)
                end
            end
            
            local randomIndex = math.random(1, #testRoster[testtype])
            local alertIndex = testRoster[testtype][randomIndex]
            
            table.insert(usedTestRoster[testtype], alertIndex)
            table.remove(testRoster[testtype], randomIndex)
            
            local alerts = info.alerts
            return alerts[alertIndex]
        else
            return nil
        end
    end

    local testcounters -- a table
    
    local function IncrementCounter(testtype)
        if testcounters[testtype] then
            testcounters[testtype] = testcounters[testtype] + 1
        else
            testcounters[testtype] = 1
        end
    end
    
    local function GetTestCounterValue(testtype)
        return testcounters[testtype] or 1
    end
    
    local function InitTest(testtype)
        local warningData = TEST_DATA[testtype]
        testRoster[testtype] = {}
        for i=1,#warningData.alerts do
            table.insert(testRoster[testtype], i)
        end
        usedTestRoster[testtype] = {}
        module:TestAlert(testtype)
    end
    
    local function CancelTestTimers()
        for alertKey,timer in pairs(TestTimers) do
            module:CancelTimer(timer, true)
            module:QuashByPattern(alertKey)
        end
        
        testcounters = {}
        TestTimers = {}
        module:Alert_Clear()
        addon:HideLFGCountdown()
        addon:HideRBGCountdown()
    end
    
    function module:TestAlert(testtype)
        IncrementCounter(testtype)
        local testData = TEST_DATA[testtype]
        local warningData = GetRandomTestData(testtype)
        
        if warningData then
            local alertKey = format("alerttest%s%s",testtype,GetTestCounterValue(testtype))
            testData.testfunc(alertKey, warningData)
            TestTimers[alertKey] = module:ScheduleTimer("TestAlert",GetRandomTestTime(testtype),testtype)
        end
    end
       
    function module:BarTest()
        CancelTestTimers()
        if not AlertTestingRunning then
            AlertTestingRunning = true
            InitTest("warning")
            InitTest("dropdown")
            InitTest("centerpopup")
            InitTest("emphasizedcenter")
            InitTest("individual")
        else
            AlertTestingRunning = false
        end
        --[[
        self:CenterPopup("alerttestdur", "Centerpopup Bar", 30, 5, "None", "RED", "ORANGE", nil, addon.ST[34889], false, nil, false, false, "FILL")
        self:CenterPopup("alerttestdur", "Centerpopup Bar (Reversed)", 20, 10, "None", "DCYAN", "LIGHTBLUE", nil, addon.ST[28374], false, nil, false, false, "DEPLETE")
        self:Dropdown("alerttestcd", "Dropdown Bar", 20, 5, "None", "BLUE", "ORANGE", nil, addon.ST[64813])
        self:Dropdown("alerttestcd", "Dropdown Bar", 10, 5, "None", "LIGHTGREEN", "LIGHTBLUE", nil, addon.ST[74544])
        self:Simple("alerttestsimp1", "Big Spell Warning",3,"None","GOLD", nil, addon.ST[70063])
        self:Simple("alerttestsimp2", "Danger on YOU!",3,"None","RED", nil, addon.ST[31944],true)
        self:Dropdown("alerttestempcd", "Dropdown Bar (Emphasized)", 10, 5, "None", "INDIGO", "CYAN", nil, addon.ST[10], false, nil, true)
        self:Dropdown("alerttestdur", "Dropdown Bar", 15, 5, "None", "YELLOW", "Off", nil, addon.ST[56319])
        self:CenterPopup("alerttestempdur", "Emphasized Bar", 20, 10, "None", "LIGHTGREEN", "YELLOW", nil, addon.ST[1064], false, nil, false, true, "DEPLETE")
        ]]
        
    end

    local lookup
    function module:FlashTest()
        local Colors = addon.db.profile.Colors
        if not lookup then
            lookup = {}
            for k,v in pairs(Colors) do lookup[#lookup+1] = k end
        end
        local i = math.random(1,#lookup)
        local c = Colors[lookup[i]]
        self:FlashScreen(c)
    end
end 
---------------------------------------------
-- EMPHASIS FRAME
---------------------------------------------

do 
    local emphasisFrame
    local isFading = false
    local activationTime = 0
    
    function module:CreateEmphasisFrame()
         -- Emphasis Frame setup
        emphasisFrame = CreateFrame("Frame","DXE Emphasis frame",UIParent)
        emphasisFrame:SetFrameStrata("FULLSCREEN")
        emphasisFrame:SetHeight(512)
        emphasisFrame:SetWidth(1024)
        emphasisFrame:SetPoint("CENTER",EmphasisFrameAnchor,"Center")
        
        local emphasisTestText = EmphasisFrameAnchor:CreateFontString(nil,"OVERLAY")
        EmphasisFrameAnchor.emphasisTestText = emphasisTestText
        
        local emphasisText = emphasisFrame:CreateFontString(nil,"OVERLAY")
        emphasisFrame.emphasisText = emphasisText
        addon:UpdateEmphasisFrame()
        
        emphasisTestText:SetPoint("CENTER",EmphasisFrameAnchor,"CENTER",0,-20)
        emphasisTestText:SetShadowColor(0,0,0,0.75)
        emphasisTestText:SetShadowOffset(2,-2)
        emphasisTestText:SetHeight(512)
        emphasisTestText:SetWordWrap(false)
        emphasisTestText:SetTextColor(1,0,0)
        emphasisTestText:SetText("|cff00ff00Bad Stuff|r |cffffffffon|r |cffffd700YOU|r|cffffffff - |r|cffff0000MOVE AWAY|r|cffffffff!|r")
        
        emphasisText:SetPoint("CENTER",emphasisFrame,"CENTER",0,-20)
        emphasisText:SetShadowColor(0,0,0,0.75)
        emphasisText:SetShadowOffset(2,-2)
        emphasisText:SetHeight(512)
        emphasisText:SetWordWrap(false)
        emphasisText:SetTextColor(1,0,0) 
    end
    
    function addon:ToggleEmphasisFrame(lock)
        emphasisFrame.emphasisText:SetAlpha(lock and 1 or 0)
    end
    
    function addon:UpdateEmphasisFrame()
        EmphasisFrameAnchor.emphasisTestText:SetFont(SM:Fetch("font",pfl.EmphasisFont), pfl.EmphasisFontSize, pfl.EmphasisFontDecoration)
        emphasisFrame.emphasisText:SetFont(SM:Fetch("font",pfl.EmphasisFont), pfl.EmphasisFontSize, pfl.EmphasisFontDecoration)
    end
    
    local function EmphasisFadeAnimation()
        local diff = GetTime() - activationTime
        local fadeIn = emphasisFrame.fadein
        local fadeTime = emphasisFrame.fadetime
        if diff > fadeIn then
            local fadePhase = (fadeTime - (diff - fadeIn)) / fadeTime
            if fadePhase > 0 then
                emphasisFrame.emphasisText:SetAlpha(fadePhase)
            else
                isFading = false
                emphasisFrame.emphasisText:Hide()
                emphasisFrame:SetScript("OnUpdate",nil)
                if not gbl.Locked then
                    EmphasisFrameAnchor.emphasisTestText:Show()
                end
            end
        end
    end

    
    local r, g, b
   
    function module:EmphasisedWarning(text, color, icon, emphasizeTime)
        local Colors = addon.db.profile.Colors
        color = color or Colors.WHITE
        r = color.r or 1
        g = color.g or 1
        b = color.b or 1
        emphasisFrame.emphasisText:SetTextColor(r, g, b)
        text = (pfl.ClrWarningText and not noColoring) and ColorText(text,color) or text
        if pfl.EmphasisIcon then
            local size = pfl.EmphasisFontSize / 3
            if icon then text = "|T"..icon..":"..size..":"..size..":-5|t"..text.."|T"..icon..":"..size..":"..size..":5|t" end
        end
        if type(emphasizeTime) == "boolean" then
                emphasisFrame.fadein = pfl.EmphasisFadeIn
                emphasisFrame.fadetime = pfl.EmphasisFadeTime
        elseif type(emphasizeTime) == "number" then
            emphasisFrame.fadein = emphasizeTime
            emphasisFrame.fadetime = pfl.EmphasisFadeTime
        elseif type(emphasizeTime) == "table" then
            emphasisFrame.fadein = emphasizeTime[1]
            emphasisFrame.fadetime = emphasizeTime[2]
        else
            emphasisFrame.fadein = pfl.EmphasisFadeIn
            emphasisFrame.fadetime = pfl.EmphasisFadeTime
        end
        emphasisFrame.emphasisText:SetText(text)
        emphasisFrame.emphasisText:SetAlpha(1)
        activationTime = GetTime()
        activationTime = GetTime()
        
        if not gbl.Locked then
            EmphasisFrameAnchor.emphasisTestText:Hide()
        end
        if not isFading then
            isFading = true
            emphasisFrame.emphasisText:Show()
            emphasisFrame:SetScript("OnUpdate", EmphasisFadeAnimation)
        end
    end
end

---------------------------------------------
-- VOICE PACKS
---------------------------------------------
do
    function module:LoadVoicePacks()
        for i=1,GetNumAddOns() do
        local name = GetAddOnInfo(i)
        local unloadable = select(6,GetAddOnInfo(name))
		if not unloadable and IsAddOnLoadOnDemand(name) and not IsAddOnLoaded(name) then
			local meta = GetAddOnMetadata(i,"X-DXE-Voicepack")
			if meta and meta == "Countdown" then
                if not select(4,GetAddOnInfo(name)) then
                    EnableAddOn(name)
                end
                LoadAddOn(name) end
			end
		end
    end
end

---------------------------------------------
-- SPECIAL BARS
---------------------------------------------
do
    local SpecialUpdateFrame = CreateFrame("Frame",nil,UIParent)
    local SpecialBars = {}
    SpecialUpdateFrame:Hide()
    
    local function SpecialBars_OnUpdate(self,elapsed)
        local barsActive = false
        for key,bar in pairs(SpecialBars) do
            if bar.countFunc then
                bar:countFunc(GetTime())
            end
            barsActive = true
        end
                
        if not barsActive then SpecialUpdateFrame:Hide() end
    end
    
    SpecialUpdateFrame:SetScript("OnUpdate",SpecialBars_OnUpdate)
    
    local function MoveAnything_Override(bar)
        bar.MALockPointHook = nil
        bar.MAOrgPoint = nil
        bar.MAPoint = nil
    end

    local function SpecialBars_SkinBar(bar)
        local ShowLeftIcon = pfl[bar.specialtype.."ShowLeftIcon"]
        local ShowRightIcon = pfl[bar.specialtype.."ShowRightIcon"]
        
        if pfl.ShowBarBorder then
            local INSET = pfl.BorderInset
            bar.border:Show()
            bar.bg:SetPoint("TOPLEFT",INSET,-INSET)
            bar.bg:SetPoint("BOTTOMRIGHT",-INSET,INSET)
            bar.statusbar:SetPoint("TOPLEFT",INSET,-INSET)
            bar.statusbar:SetPoint("BOTTOMRIGHT",-INSET,INSET)
        else
            bar.border:Hide()
            bar.statusbar:SetPoint("TOPLEFT")
            bar.statusbar:SetPoint("BOTTOMRIGHT")
            bar.bg:SetPoint("TOPLEFT")
            bar.bg:SetPoint("BOTTOMRIGHT")
        end
        
        -- Bar
        local iconHeight = pfl.IndividualSetIconToBarHeight and pfl.IndividualBarHeight or pfl.IndividualIconSize
        local width = bar.anchorframe:GetWidth() - (ShowLeftIcon and iconHeight or 0) - (ShowRightIcon and iconHeight or 0) + pfl.IndividualBarWidth
        bar:SetWidth(width)
        bar:SetHeight(pfl.IndividualBarHeight)
        bar:SetAlpha(pfl.IndividualAlpha)
        bar:EnableMouse(not pfl.IndividualClickThrough)
        
        -- Text
        bar.text:SetWidth(bar:GetWidth() - bar.timer:GetWidth() + 10)
        bar.text:SetWordWrap(false)
        bar.text:ClearAllPoints()
        bar.text:SetPoint("LEFT",bar,"LEFT",pfl.IndividualTextXOffset,pfl.IndividualTextYOffset)
        
        bar.text:SetWidth(bar:GetWidth() - bar.timer:GetWidth() + pfl.IndividualTextWidth)
        bar.text:SetHeight(pfl.IndividualBarFontSize*1.2)
        bar.text:SetFont(bar.text:GetFont(),pfl.IndividualBarFontSize)
        bar.text:SetAlpha(pfl.IndividualTextAlpha)
        bar.text:SetJustifyH(pfl.IndividualBarTextJustification)
        bar.text:SetVertexColor(unpack(pfl.IndividualBarFontColor))

        -- Icon
        bar:SetIcon(bar.icon, ShowLeftIcon, ShowRightIcon)
        bar:DisplayIconBorder(pfl.IndividualShowIconBorder)
        bar:UpdateIconSize(iconHeight)
        bar:UpdateIconPosition(pfl.IndividualIconXOffset, pfl.IndividualIconYOffset)
        
        -- Timer
        bar.timer.right:ClearAllPoints()
        bar.timer.right:SetPoint("BOTTOMLEFT",bar.timer.left,"BOTTOMRIGHT",0,pfl.IndividulDecimalYOffset)
        bar.timer:ClearAllPoints()
        bar.timer:SetPoint("RIGHT",bar,"RIGHT",pfl.IndividualTimerXOffset,pfl.IndividualTimerYOffset)
        bar.timer:SetAlpha(pfl.IndividualTimerAlpha)
        bar:UpdateTimerSize(pfl.IndividualBarHeight)
    end
    
    local function SpecialBars_PlaceBar(bar)
        MoveAnything_Override(bar)
        bar:ClearAllPoints()
        if bar.anchored and bar.anchorframe then
            local iconHeight = pfl.IndividualSetIconToBarHeight and pfl.IndividualBarHeight or pfl.IndividualIconSize
            bar:SetPoint("TOPLEFT", bar.anchorframe, "BOTTOMLEFT", pfl.IndividualBarXOffset + (pfl[bar.specialtype.."ShowLeftIcon"] and iconHeight or 0), pfl.IndividualBarYOffset)
        else
            bar:SetPoint("TOP", RaidWarningFrame, "BOTTOM", pfl.IndividualBarXOffset, pfl.IndividualBarYOffset)
        end
    end
    
    function module:RefreshSpecial() 
        for bar in pairs(Special) do SpecialBars_SkinBar(bar) end
        for bar in pairs(Special) do SpecialBars_PlaceBar(bar) end
    end
    
    local function SpecialBars_RefreshText(bar,text)
        if bar.active then bar:SetText(text, nil, pfl.IndividualBarFontColor) end
    end
    
    local function SpecialBars_RefreshBar(bar)
        if not pfl[bar.specialtype.."ShowLeftIcon"] then 
            bar.lefticon:SetAlpha(0)
            bar.lefticon:Hide()
        else
            bar.lefticon:SetAlpha(1)
            bar.lefticon:Show()
        end
        if not pfl[bar.specialtype.."ShowRightIcon"] then
            bar.righticon:SetAlpha(0)
            bar.righticon:Hide()
        else
            bar.righticon:SetAlpha(1)
            bar.righticon:Show()
        end
        
        SpecialBars_SkinBar(bar)
        SpecialBars_PlaceBar(bar)
        
        bar:SetColor(pfl[bar.specialtype.."TimerMainColor"],
                     pfl[bar.specialtype.."TimerFlashColor"])
    end
    
    local function SpecialBars_Add(key, bar)
        if not SpecialBars[key] then SpecialBars[key] = bar end
        
    end
    
    
    local SPECIAL_BARS_HOOKED_FRAMES = {}
    
    local function SpecialBars_HookFrames(bar, frames, predicate)
        for i,frame in ipairs(frames) do
            local func = function()
                if predicate(frame) then SpecialBars_RefreshBar(bar) end
            end
            if not SPECIAL_BARS_HOOKED_FRAMES[frame] then
                SPECIAL_BARS_HOOKED_FRAMES[frame] = {}
            end

            if SPECIAL_BARS_HOOKED_FRAMES[frame][bar.specialtype] == nil then
                hooksecurefunc(frame,"SetPoint",func)
            end
            
            if not SPECIAL_BARS_HOOKED_FRAMES[frame][bar.specialtype] then
                SPECIAL_BARS_HOOKED_FRAMES[frame][bar.specialtype] = true
            end
        end
    end
    
    ---------------------------------------------
    -- API
    ---------------------------------------------
    function module:CreateSpecialBar(barType,anchorframe)
        local bar = CreateBar()
        Special[bar] = true
        bar.specialtype = barType
        bar.active = false
        bar.anchored = false
        bar.anchorframe = anchorframe
        bar:SetFrameStrata(anchorframe:GetFrameStrata() or "DIALOG")
        bar:SetAlpha(0)
        bar:Hide()
        SpecialBars_SkinBar(bar)
        SpecialBars_Add(barType,bar)
        
        return bar
    end
    
    function module:SetupSpecialBars()
        module:RegisterLFGBar()
        module:RegisterRBGBar()
        module:RegisterResurrectBar()
    end

    ---------------------------------------------
    -- LFG COOLDOWN
    ---------------------------------------------
 
    local LFG_ICON = "Interface\\ICONS\\Achievement_BG_grab_cap_flagunderXseconds"
    local ENTERING_LFG_ICON = "Interface\\ICONS\\Achievement_Dungeon_UlduarRaid_Misc_06"
    local LFG_COOLDOWN = 40 -- 40 seconds
    local LFG_ENTERING_COOLDOWN = 2
    local DUNGEON_TYPE = {}
    for i = 1, GetNumRandomDungeons() do
      local id, name = GetLFGRandomDungeonInfo(i)
      DUNGEON_TYPE[id] = name
    end
    
    local LFGBar, LFGBarTimer, LFGEnteringBar, LFGEnteringBarTimer
    
    local LFG_PlayerAccepted = false
    local LFG_test = false
    local LFG_startShown = false
    local function LFG_DoNothingFunction() end
    
    local function LFG_CountAccepted(numMembers)
        local numAccepted = 0
        
        for i=1, numMembers do
            local isLeader, role, level, responded, accepted, name, class = GetLFGProposalMember(i);
            if responded and accepted then numAccepted = numAccepted + 1 end
        end
        
        return numAccepted
    end
    
    function module:LFGBar_StartDungeon()
        if LFG_startShown then return end
        LFG_startShown = true
        
        addon.callbacks:Fire("RDF_START")
        local instanceType = select(2,GetInstanceInfo())
        if instanceType ~= "party" then
            addon:ShowEnteringLFGCountdown(LFGDungeonReadyPopup.dungeonID)
        end
        if pfl.LFG_Entering_MutedSound then 
            if addon:IsGameSoundMuted() then
                if not pfl.DisableSounds then
                    addon.Alerts:Sound(addon.Media.Sounds:GetFile("ENTERING_LFG"))
                end
            end
        end
    end
    
    function module:LFGBar_EventHandler(event,...)
        if event == "LFG_PROPOSAL_SHOW" then
            if pfl.LFG_MutedSound then
                if addon:IsGameSoundMuted() then
                    if not pfl.DisableSounds then
                        addon.Alerts:Sound(addon.Media.Sounds:GetFile("LFG_READY_CHECK"))
                    end
                end
            end
        
            addon:ShowLFGCountdown(LFGDungeonReadyPopup.dungeonID)
        elseif event == "LFG_PROPOSAL_FAILED" then
            addon:HideLFGCountdown()
            if HasLFGRestrictions() then module:LFGBar_StartDungeon() end
        elseif event == "LFG_PROPOSAL_SUCCEEDED" then
            addon:HideLFGCountdown()
            if HasLFGRestrictions() then module:LFGBar_StartDungeon(accepted) end
        elseif event == "LFG_PROPOSAL_UPDATE" then
            local numMembers = select(11,GetLFGProposal())
            if type(numMembers) ~= "number" then return end
            
            local accepted = LFG_CountAccepted(numMembers)
            
            if not LFGBar.active then return end
            local hasResponded = select(8,GetLFGProposal())
            if hasResponded and not LFG_PlayerAccepted then
                LFG_PlayerAccepted = true
                
                --module:LFG_PlaceBar()
                module:LFGBar_UpdateAnchor()
                module:LFGEnteringBar_UpdateAnchor()
            end
            module:LFGBar_RefreshText(accepted)
        end
    end
    
    function module:RegisterLFGBar()
        LFGBar = module:CreateSpecialBar("LFG",LFGDungeonReadyDialog)
        local predicate = function(frame)
            return frame == LFGDungeonReadyDialog or frame == LFGDungeonReadyStatus
        end
        --SpecialBars_HookFrames(LFGBar, {LFGDungeonReadyDialog, LFGDungeonReadyPopup}, predicate)
        SpecialBars_HookFrames(LFGBar, {LFGDungeonReadyDialog, LFGDungeonReadyStatus}, predicate)

        LFGEnteringBar = module:CreateSpecialBar("LFGEntering",LFGDungeonReadyStatus)
        local predicate = function(frame)
            return frame == LFGDungeonReadyDialog or frame == LFGDungeonReadyStatus
        end
        SpecialBars_HookFrames(LFGEnteringBar, {LFGDungeonReadyStatus}, predicate)

        module:RegisterEvent("LFG_PROPOSAL_SHOW", "LFGBar_EventHandler")
        module:RegisterEvent("LFG_PROPOSAL_FAILED", "LFGBar_EventHandler")
        module:RegisterEvent("LFG_PROPOSAL_SUCCEEDED", "LFGBar_EventHandler")
        module:RegisterEvent("LFG_PROPOSAL_UPDATE", "LFGBar_EventHandler")
    end
      
    function module:LFGBar_UpdateAnchor()
        
        if not LFG_test then
            LFGBar.anchored = true
            if not LFG_PlayerAccepted then
                LFGBar.anchorframe = LFGDungeonReadyDialog
            else
                --LFGBar.anchorframe = LFGDungeonReadyPopup
            end
        end
        SpecialBars_PlaceBar(LFGBar)
    end
           
    function module:LFGBar_RefreshText(acceptedCount)
        SpecialBars_RefreshText(LFGBar,
            format( "%s%s",acceptedCount > 0 and format("|cffffd700(%d/5)|r ",acceptedCount) or "",
                           LFGBar.lfgtext or ""
            )
        )
    end
    
    function module:LFGEnteringBar_UpdateAnchor()
        
        if not LFG_test then
            LFGEnteringBar.anchored = true
            LFGEnteringBar.anchorframe = LFGDungeonReadyStatus
        end
        SpecialBars_PlaceBar(LFGEnteringBar)
    end
    
    function module:LFGEnteringBar_RefreshText()
        SpecialBars_RefreshText(LFGEnteringBar, LFGEnteringBar.lfgtext or "")
    end
    
    
    function addon:ShowLFGCountdown(dungeonID, test, suppressAudioCD)
        if not pfl.LFGTimerEnabled then return end
        
        -- Resetting the LFG Frame
        addon:HideLFGCountdown()
        LFGBar.active = true
        LFG_startShown = false
        LFG_test = test
        
        
        local time, text, icon
        local isRandom = (select(3,GetLFGProposal())) == 6
        if LFG_test then
            addon:HideLFGEnteringCountdown()
            time = 8
            text = "Random Dungeon Finder"
        else
            time = LFG_COOLDOWN
            if DUNGEON_TYPE[dungeonID] then
                text = DUNGEON_TYPE[dungeonID]
            else
                text = GetLFGDungeonInfo(dungeonID) or "LFG Invite"
                LFGBar.text:SetFont(LFGBar.text:GetFont(),14)
            end
        end
        if LFG_test or (isRandom and DUNGEON_TYPE[dungeonID]) then
            icon = LFG_ICON
        else
            local dungeonIcon = select(11,GetLFGDungeonInfo(dungeonID))
            icon = dungeonIcon:len()>0 and format("Interface\\LFGFRAME\\LFGICON-%s.blp",dungeonIcon)
                or LFG_ICON
        end
        
        LFGBar.lfgtext = text
        LFGBar.icon = icon
        module:LFGBar_UpdateAnchor()
        module:LFGBar_RefreshText(0)
        SpecialBars_RefreshBar(LFGBar)
        
        LFGBar:SetTimeleft(time)
        LFGBar:Countdown(time, 8)
        LFGBarTimer = LFGBar:ScheduleTimer("Fade",time)
        
        
        if not suppressAudioCD then
            local audiocd = pfl.LFGTimerAudioCDVoice
            if audiocd and audiocd ~= "#off#" then
                if audiocd == true or audiocd == "#default#" then
                    LFGBar:AudioCountdown(time)
                else
                    LFGBar:AudioCountdown(time,audiocd)
                end
            end
        end
        
        --LFGBar:ClearAllPoints()
        --LFGBar:SetPoint("TOPLEFT", LFGDungeonReadyDialog, "BOTTOMLEFT",
--                                (pfl.LFGShowLeftIcon and LFGBar:GetHeight() or 0), 0)
        LFGBar:SetAlpha(1)
        LFGBar:Show()
        SpecialUpdateFrame:Show()
    end
    
    function addon:HideLFGCountdown()
        LFG_PlayerAccepted = false
        LFGBar.active = false
        if LFGBarTimer then
            LFGBar:CancelTimer(LFGBarTimer,true)
            LFGBarTimer = nil
        end
        LFGBar.countFunc = nil
        LFGBar:Hide()
        LFGBar:CancelAudioCountdown()
        UIFrameFadeRemoveFrame(LFGBar)
    end

    function addon:LFG_RefreshBar()
        SpecialBars_RefreshBar(LFGBar)
        SpecialBars_RefreshBar(LFGEnteringBar)
    end
    
    function addon:ShowEnteringLFGCountdown(dungeonID, test)
        if not pfl.LFGTimerEnabled then return end
        
        -- Resetting the LFG Frame
        LFGEnteringBar.active = true
        LFG_test = test
        
        
        local time = LFG_ENTERING_COOLDOWN
        local isRandom = (select(3,GetLFGProposal())) == 6
        local text = format("Entring %s ...","dungeon")
        if LFG_test then
            addon:HideLFGCountdown()
            time = 8
        end
        
        LFGEnteringBar.lfgtext = text
        LFGEnteringBar.icon = ENTERING_LFG_ICON
        module:LFGEnteringBar_UpdateAnchor()
        module:LFGEnteringBar_RefreshText()
        SpecialBars_RefreshBar(LFGEnteringBar)
        LFGEnteringBar.data.fillDirection = "FILL"
        LFGEnteringBar:SetTimeleft(time)
        LFGEnteringBar:Countdown(time, 8)
        LFGEnteringBarTimer = LFGEnteringBar:ScheduleTimer("Fade",time)
         
        LFGEnteringBar:SetAlpha(1)
        LFGEnteringBar:Show()
        SpecialUpdateFrame:Show()
    end
    
    function addon:HideLFGEnteringCountdown()
        LFGEnteringBar.active = false
        if LFGEnteringBarTimer then
            LFGEnteringBar:CancelTimer(LFGEnteringBarTimer,true)
            LFGEnteringBarTimer = nil
        end
        LFGEnteringBar.countFunc = nil
        LFGEnteringBar:Hide()
        UIFrameFadeRemoveFrame(LFGEnteringBar)
    end

    function addon:LFGEntering_RefreshBar()
        SpecialBars_RefreshBar(LFGEnteringBar)
    end
    
    ---------------------------------------------
    -- RESURRECTION TIMER
    ---------------------------------------------
    local ResurrectBar, ResurrectBarTimer
    local Resurrect_Test
    local framesHooked = {}
    local RESURRECT_ICON_UNKNOWN = addon.ST[83968]
    local RESURRECT_TEXT_UNKNOWN = "Mass Resurrection"
    
    local RESURRECT_BY_CLASS = {
        ["Priest"] = {
            nocombat = {icon = addon.ST[2006], text = addon.SN[2006]}
        },
        ["Druid"] = {
            nocombat = {icon = addon.ST[50769], text = addon.SN[50769]},
            combat = {icon = addon.ST[20484], text = addon.SN[20484]}
        },
        ["Paladin"] = {
            nocombat = {icon = addon.ST[7328], text = addon.SN[7328]}
        },
        ["Shaman"] = {
            nocombat = {icon = addon.ST[2008], text = addon.SN[2008]}
        },
        ["Death Knight"] = {
            combat = {icon = addon.ST[61999], text = addon.SN[61999]}
        },
        ["Warlock"] = {
            combat = {icon = addon.ST[20707], text = addon.SN[20707]}
        },
    }
    
    function module:RegisterResurrectBar()
        ResurrectBar = module:CreateSpecialBar("Resurrect",StaticPopup1)
        local predicate = function(staticPopup)
            return staticPopup.which == "RESURRECT_NO_TIMER"
        end
        
        local staticPopups = {}
        for i=1, STATICPOPUP_NUMDIALOGS do
            table.insert(staticPopups,_G["StaticPopup"..i])
        end
        SpecialBars_HookFrames(ResurrectBar, staticPopups, predicate)
        --module:RegisterEvent("PLAYER_ENTERING_WORLD","AoEResTimer_Hide")
    end
    
    function module:ResurrectBar_UpdateAnchor(staticPopup)
        if not Resurrect_Test and staticPopup then
            ResurrectBar.anchored = true
            ResurrectBar.anchorframe = staticPopup
        end
        SpecialBars_PlaceBar(ResurrectBar)
    end
    
    function addon:ResurrectBar_Refresh()
        SpecialBars_RefreshBar(ResurrectBar)
    end
    
    local UNKNOWN_TEXT = format("%s fades ...",RESURRECT_TEXT_UNKNOWN)
    local UNKNOWN_ICON = RESURRECT_ICON_UNKNOWN
    
    local function GetResurrectionInfo()
        local offerer = ResurrectGetOfferer()
        if not offerer then return UNKNOWN_TEXT, UNKNOWN_ICON end
        
        local class = UnitClass(offerer)
        if not class then return UNKNOWN_TEXT, UNKNOWN_ICON end
        
        local bundle = RESURRECT_BY_CLASS[class]
        if not bundle then return UNKNOWN_TEXT, UNKNOWN_ICON end
        
        local subcategory = UnitAffectingCombat(offerer) and "combat" or "nocombat"
        if bundle[subcategory] then
            return format("%s fades ...", bundle[subcategory].text),
                   bundle[subcategory].icon
        else
            return UNKNOWN_TEXT, UNKNOWN_ICON
        end
    end
    
    function addon:ShowResurrectCountdown(staticPopup, test)
        if not pfl.ResurrectTimerEnabled  then return end
        
        -- Resetting the Resurrect Frame
        addon:HideResurrectCountdown()
        ResurrectBar.active = true
        Resurrect_Test = test

        local time, text, icon
        
        if Resurrect_Test then
            text = format("%s fades ...",RESURRECT_TEXT_UNKNOWN)
            icon = RESURRECT_ICON_UNKNOWN
            time = 10
        else
            time = GetCorpseRecoveryDelay() + 60
            text, icon = GetResurrectionInfo()
        end
        
        ResurrectBar.icon = icon
        module:ResurrectBar_UpdateAnchor(staticPopup)
        SpecialBars_RefreshText(ResurrectBar,text)
        SpecialBars_RefreshBar(ResurrectBar)
        
        ResurrectBar:SetTimeleft(time)
        ResurrectBar:Countdown(time, 8)
        ResurrectBarTimer = ResurrectBar:ScheduleTimer("Fade",time)
        
        local audiocd = pfl.ResurrectTimerAudioCDVoice
        if audiocd and audiocd ~= "#off#" then
            if audiocd == true or audiocd == "#default#" then
                ResurrectBar:AudioCountdown(time)
            else
                ResurrectBar:AudioCountdown(time,audiocd)
            end
        end
        
        ResurrectBar:SetAlpha(1)
        ResurrectBar:Show()
        SpecialUpdateFrame:Show()
    end
    
    function addon:HideResurrectCountdown()
        ResurrectBar.active = false
        if ResurrectBarTimer then
            ResurrectBar:CancelTimer(ResurrectBarTimer,true)
            ResurrectBarTimer = nil
        end
        ResurrectBar.countFunc = nil
        ResurrectBar:Hide()
        ResurrectBar:CancelAudioCountdown()
        UIFrameFadeRemoveFrame(ResurrectBar)
    end
    
    function addon:Resurrect_RefreshBar()
        SpecialBars_RefreshBar(ResurrectBar)
    end
    
    function module:ResurrectBar_EventHandler(event)
        if event == "PLAYER_ALIVE" then
            if not UnitIsDeadOrGhost("player") then
                addon:HideResurrectCountdown()
            end
        end
    end
    module:RegisterEvent("PLAYER_ALIVE","ResurrectBar_EventHandler")
    
    ---------------------------------------------
    -- BATTLEGROUND COOLDOWNS
    ---------------------------------------------
    -- GLOBAL RESURRECTION TIMER
    local AoEResTimer
    local AREA_SPIRIT_HEAL_TIME = 30
    local AOERESTIMER_VAR = "alertbgglobalresurrection"
    
    local function AoEResTimer_Update(time)
        time = (time and time > 0) and time or AREA_SPIRIT_HEAL_TIME
        module:InvokeGlobalResTimer(time)
        if AoEResTimer then module:CancelTimer(AoEResTimer, true) end
        AoEResTimer = module:ScheduleTimer(AoEResTimer_Update, time)
    end
    
    function module:StartGlobalResTimer()
        if not pfl.GlobalResurrectionTimerEnabled then return end
        local instanceName, instanceType = GetInstanceInfo()
        if instanceType ~= "pvp" then return end
        
        local bt = GetBattlefieldInstanceRunTime() / 1000 -- in seconds
        local time = 30*(math.floor(bt/30) + 1) - bt
        AoEResTimer_Update(time)
    end
    
    function module:InvokeGlobalResTimer(time)
        if not time or time <= 0 then return end
        if module:GetTimeleft(AOERESTIMER_VAR) > 0 then
            module:QuashByPattern(AOERESTIMER_VAR)
        end
        
        module:Dropdown(AOERESTIMER_VAR, "Global Resurrection ", {time = time, timemax = AREA_SPIRIT_HEAL_TIME}, pfl.GlobalResurrectionTimerFlashTime or 10, "None", pfl.GlobalResurrectionTimerMainColor or "RED", pfl.GlobalResurrectionTimerFlashColor or "ORANGE", nil, "Interface\\ICONS\\Spell_Holy_Redemption", pfl.GlobalResurrectionTimerAudioCDVoice)
    end
    
    function module:AoEResTimer_Hide()
        if AoEResTimer then 
            module:CancelTimer(AoEResTimer, true)
            AoEResTimer = nil
        end
        module:QuashByPattern(AOERESTIMER_VAR)
    end

    function module:RefreshGlobalResurrectionTimer()
        if not pfl.GlobalResurrectionTimerEnabled then
            module:AoEResTimer_Hide()
        elseif not AoEResTimer then
            module:StartGlobalResTimer()
        end
    end
    
    local function ParseStaticPopup()
        for i = 1, STATICPOPUP_NUMDIALOGS do
            local popup = _G["StaticPopup"..i]
            
            popup.dxename = "StaticPopup"..i
            local which = popup.which
            local timeleft = popup.timeleft
            if which == "AREA_SPIRIT_HEAL" and pfl.GlobalResurrectionTimerEnabled then
                if popup:IsVisible() and timeleft and timeleft >= 0 then
                    local startTime = GetTime() - (AREA_SPIRIT_HEAL_TIME - timeleft)
                    AoEResTimer_Update(timeleft)
                end
            elseif which == "RESURRECT_NO_TIMER" then
                if popup:IsVisible() then
                    if UnitIsDead("player") then
                        if ResurrectGetOfferer() ~= nil then
                            addon:ShowResurrectCountdown(popup,false)
                        else
                            addon:HideResurrectCountdown()
                        end
                    end
                else
                    addon:HideResurrectCountdown()
                end
            end
            
            if which == "CONFIRM_BATTLEFIELD_ENTRY" then
                if pfl.RBG_MutedSound then
                    if addon:IsGameSoundMuted() then
                        if not pfl.DisableSounds then
                            addon.Alerts:Sound(addon.Media.Sounds:GetFile("RBG_READY_CHECK"))
                        end
                    end
                end
                addon:ShowRBGCountdown(popup)
                
            end
        end
    end

    function module:ScheduleStaticPopupCheck()
        module:ScheduleTimer(ParseStaticPopup, 0)
    end
   
    module:SecureHook("StaticPopup_Show", "ScheduleStaticPopupCheck")
    
    -- BATTLEGROUND INVITE TIMER
    local RBGBar, RBGBarTimer
    local RBG_Test
    local framesHooked = {}
    
    function module:RegisterRBGBar()
        RBGBar = module:CreateSpecialBar("RBG",StaticPopup1)
        local predicate = function(staticPopup)
            --return staticPopup.which == "CONFIRM_BINDER"
            return staticPopup.which == "CONFIRM_BATTLEFIELD_ENTRY"
        end
        
        local staticPopups = {}
        for i=1, STATICPOPUP_NUMDIALOGS do
            table.insert(staticPopups,_G["StaticPopup"..i])
        end
        SpecialBars_HookFrames(RBGBar, staticPopups, predicate)
        module:RegisterEvent("PLAYER_ENTERING_WORLD","AoEResTimer_Hide")
        module:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE")
        module:RegisterEvent("BATTLEFIELD_MGR_EJECTED")
        module:RegisterEvent("BATTLEFIELD_MGR_ENTERED")
    end
    
    local DEFAULT_BATTLEFIELD_INVITE_TIME = 10
    
    function module:BATTLEFIELD_MGR_ENTRY_INVITE(...)
        local name = select(3, ...)
        local battlefieldPopup
        local timeleft = DEFAULT_BATTLEFIELD_INVITE_TIME
        
        for i = 1, STATICPOPUP_NUMDIALOGS do
            local popup = _G["StaticPopup"..i]
            if popup then
                local which = popup.which
                if which == "BFMGR_INVITED_TO_ENTER" then
                    timeleft = popup.timeleft
                    battlefieldPopup = popup 
                    break
                end
            end
        end
        
        if not pfl.DisableSounds then
            addon.Alerts:Sound(addon.Media.Sounds:GetFile("RBG_READY_CHECK"))
        end
        
        addon:ShowBattlefieldCountdown(battlefieldPopup,name, timeleft)
    end
    
    function module:BATTLEFIELD_MGR_ENTERED(...)
        addon:HideRBGCountdown()
    end
    
    function module:BATTLEFIELD_MGR_EJECTED(...)
        addon:HideRBGCountdown()
    end
    
    function module:RBGBar_UpdateAnchor(staticPopup)
        if not RBG_test and staticPopup then
            RBGBar.anchored = true
            RBGBar.anchorframe = staticPopup
        end
        SpecialBars_PlaceBar(RBGBar)
    end
    
    local BATTLEFIELD = {
        ["Wintergrasp"] = {
            icon = addon.AT[1717],
            time = 20,
        },
        ["Tol Barad"] = {
            icon = addon.AT[5412],
            time = 20,
        },
    }
    
    function addon:ShowBattlefieldCountdown(staticPopup, name, time, test, suppressAudioCD)
        
        addon:HideRBGCountdown()
        RBGBar.active = true
        RBG_Test = test
        
        if BATTLEFIELD[name] then
            RBGBar.icon = BATTLEFIELD[name].icon
            time = BATTLEFIELD[name].time
        else
            RBGBar.icon = UnitFactionGroup("player") == "Alliance" and "Interface\\ICONS\\PVPCurrency-Honor-Alliance" or "Interface\\ICONS\\PVPCurrency-Honor-Horde"
        end
                
        module:RBGBar_UpdateAnchor(staticPopup)
        SpecialBars_RefreshText(RBGBar,name)
        SpecialBars_RefreshBar(RBGBar)
        
        RBGBar:SetTimeleft(time)
        RBGBar:Countdown(time, 10)
        RBGBarTimer = RBGBar:ScheduleTimer("Fade",time)
        
        if not suppressAudioCD then
            local audiocd = pfl.RBGTimerAudioCDVoice
            if audiocd and audiocd ~= "#off#" then
                if audiocd == true or audiocd == "#default#" then
                    RBGBar:AudioCountdown(time)
                else
                    RBGBar:AudioCountdown(time,audiocd)
                end
            end
        end
        
        RBGBar:SetAlpha(1)
        RBGBar:Show()
        SpecialUpdateFrame:Show()
    end
    
    function addon:ShowRBGCountdown(staticPopup, test, suppressAudioCD)
        if not pfl.RBGTimerEnabled then return end
        
        -- Resetting the RBG Frame
        addon:HideRBGCountdown()
        RBGBar.active = true
        RBG_Test = test

        local time, text, icon
        text = "Test"
        if RBG_Test then
            text = "Random Battleground"
            icon = "Interface\\ICONS\\PVPCurrency-Honor-Alliance"
            time = 5
        else
            for i=1, GetMaxBattlefieldID() do
                local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch, eligibleInQueue, waitingOnOtherActivity = GetBattlefieldStatus(i)
                if status == "confirm" then
                    time = GetBattlefieldPortExpiration(i)
                    text = mapName
                    icon = UnitFactionGroup("player") == "Alliance" and "Interface\\ICONS\\PVPCurrency-Honor-Alliance" or "Interface\\ICONS\\PVPCurrency-Honor-Horde"
                    break
                end
            end
        end
        
        RBGBar.icon = icon
        module:RBGBar_UpdateAnchor(staticPopup)
        SpecialBars_RefreshText(RBGBar,text)
        SpecialBars_RefreshBar(RBGBar)
        
        RBGBar:SetTimeleft(time)
        RBGBar:Countdown(time, 10)
        RBGBarTimer = RBGBar:ScheduleTimer("Fade",time)
        
        if not suppressAudioCD then
            local audiocd = pfl.RBGTimerAudioCDVoice
            if audiocd and audiocd ~= "#off#" then
                if audiocd == true or audiocd == "#default#" then
                    RBGBar:AudioCountdown(time)
                else
                    RBGBar:AudioCountdown(time,audiocd)
                end
            end
        end
        
        RBGBar:SetAlpha(1)
        RBGBar:Show()
        SpecialUpdateFrame:Show()
    end
    
    function addon:HideRBGCountdown()
        RBGBar.active = false
        if RBGBarTimer then
            RBGBar:CancelTimer(RBGBarTimer,true)
            RBGBarTimer = nil
        end
        RBGBar.countFunc = nil
        RBGBar:Hide()
        RBGBar:CancelAudioCountdown()
        UIFrameFadeRemoveFrame(RBGBar)
    end
    
    function addon:RBG_RefreshBar()
        SpecialBars_RefreshBar(RBGBar)
    end
    
    function module:RBGBar_EventHandler(event)
        if event == "UPDATE_BATTLEFIELD_STATUS" then
            addon:HideRBGCountdown()
        end
    end
    module:RegisterEvent("UPDATE_BATTLEFIELD_STATUS","RBGBar_EventHandler")
end
---------------------------------------------
-- ALERT FRAME
---------------------------------------------
do
    local alertsFrame
    local alertSlots = {}
    local DURATIONS
    
    local DEFAULT_TEST_TEXT = format("%s Sulfuras Smash %s","|T"..addon.ST[100258]..":15:15:-5:5|t","|T"..addon.ST[100258]..":15:15:5:5|t")
    local fps = 30
    local interval = 1/fps
    local DELAY = 0
    local STACK_OFFSET = 15 -- used to be -15

        
    local function Alert_RevalidatAnimation(slot)
        if slot.animating then
            if     not slot.popping
                and not slot.pushing
                and not slot.dropping 
                and not slot.fading then
                slot.animating = false
                slot:SetScript("OnUpdate", nil)
            end
        end
    end
        
    local function Alert_UpdateTestText()
        for _,slot in pairs(alertSlots) do
            if slot.taken then
                AlertsFrameAnchor.alertsTestText:SetText("")
                return
            end
        end
        AlertsFrameAnchor.alertsTestText:SetText(DEFAULT_TEST_TEXT)
    end
    
    local function AlertAnimation(self, elapsed)
        -- Pushing text towards the correct slot
        if self.pushing then
            self.pushing.since = self.pushing.since + elapsed
            
            while(self.pushing.since > interval) do
                self.pushing.frame = self.pushing.actualFrame - DELAY
                
                -- Pushing text towards the correct slot
                if pfl.AlertsDirection == "UP" then
                    self.text:SetPoint("CENTER",self,"CENTER",0,(-1+(self.pushing.frame/DURATIONS.pushing))*(self:GetHeight()+STACK_OFFSET))
                else
                    self.text:SetPoint("CENTER",self,"CENTER",0,(1-(self.pushing.frame/DURATIONS.pushing))*(self:GetHeight()+STACK_OFFSET))
                end               
                
                if self.pushing.frame >= DURATIONS.pushing then
                    self.text:SetPoint("CENTER",self,"CENTER",0,0)
                    self.pushing = nil
                    Alert_RevalidatAnimation(self)
                    break
                end
                
                self.pushing.since = self.pushing.since - interval
                self.pushing.actualFrame = self.pushing.actualFrame + 1            
            end
        end
        
        -- Popping new alert
        if self.popping then
            self.popping.since = self.popping.since + elapsed
            
            while(self.popping.since > interval) do
                self.popping.frame = self.popping.actualFrame - DELAY
                
                -- Animating popping text
                self.text:SetTextHeight(self.popping.originalHeight * (1 + 0.4*(math.sin((self.popping.frame*math.pi)/DURATIONS.popping))))
                local alpha = self.popping.frame / (DURATIONS.popping/2)
                if alpha <= 1 then
                    self.text:SetAlpha(alpha)
                end
                
                if self.popping.frame >= DURATIONS.popping then
                    self:SetScale(1)
                    self.text:SetAlpha(1)
                    self.popping = nil
                    Alert_RevalidatAnimation(self)
                    break
                end
                
                self.popping.since = self.popping.since - interval
                self.popping.actualFrame = self.popping.actualFrame + 1
            end
        end
        
        
        local alpha = self.text:GetAlpha()
        -- Dropping the alert
        if self.dropping then
            self.dropping.since = self.dropping.since + elapsed
            
            while(self.dropping.since > interval) do
                self.dropping.frame = self.dropping.actualFrame - DELAY
                
                alpha = 1 - self.dropping.frame / DURATIONS.dropping
                
                if self.dropping.frame >= DURATIONS.dropping then
                    self.text:SetAlpha(0)
                    self.text:SetText("")
                    self.id = nil
                    self.taken = false
                    Alert_UpdateTestText()
                    self.dropping = nil
                    self.fading = nil
                    Alert_RevalidatAnimation(self)
                    break
                end
                
                self.dropping.since = self.dropping.since - interval
                self.dropping.actualFrame = self.dropping.actualFrame + 1
            end
        end
        
        -- Fading out the alert
        if self.fading then
            self.fading.since = self.fading.since + elapsed
            
            while(self.fading.since > interval) do
                self.fading.frame = self.fading.actualFrame - DELAY
                
                if self.fading.frame > DURATIONS.holding then
                    if self.fading.frame < DURATIONS.holding + DURATIONS.fading then
                        alpha = 1 - (self.fading.frame-DURATIONS.holding) / DURATIONS.fading
                    else
                        self.text:SetAlpha(0)
                        self.text:SetText("")
                        self.id = nil
                        self.taken = false
                        self.fading = nil
                        Alert_RevalidatAnimation(self)
                        Alert_UpdateTestText()
                        break
                    end
                end
                
                self.fading.since = self.fading.since - interval
                self.fading.actualFrame = self.fading.actualFrame + 1
            end
        end
        self.text:SetAlpha(alpha)
    end
    
    local function Alert_Drop(slotN)
        local slot = alertSlots[slotN]
        if not slot.taken then return end
        
        slot.dropping = {
            actualFrame = 1,
            since = 0
        }
        if not slot.animating then 
            slot.animating = true
            slot:SetScript("OnUpdate", AlertAnimation) 
        end
    end
    
    local Alert_PushStack
    
    
    local function Alert_Push(slotN)
        if slotN < 1 or slotN >= #alertSlots then return end
        
        local slot = alertSlots[slotN]
        if not slot.taken then return end
        
        local nextSlot = alertSlots[slotN+1]
        if slot.fading then
            nextSlot.fading = slot.fading
            slot.fading = nil
        end
        
        -- Pre-push setup
        nextSlot.text:SetText(slot.text:GetText())
        nextSlot.id = slot.id
        nextSlot.text:SetTextColor(slot.text:GetTextColor())
        nextSlot.taken = true
        slot.taken = false
        slot.text:SetText("")
        slot.id = nil
        if pfl.AlertsDirection == "UP" then
            nextSlot.text:SetPoint("CENTER",nextSlot,"CENTER",0,-(nextSlot:GetHeight()+STACK_OFFSET))
        else
            nextSlot.text:SetPoint("CENTER",nextSlot,"CENTER",0,(nextSlot:GetHeight()+STACK_OFFSET))
        end
        
        nextSlot.pushing = {
            actualFrame = 1,
            since = 0
        }
        slot.pushing = nil
        
        if slot.popping then
            nextSlot.popping = slot.popping
            slot.popping = nil
        end
        
        Alert_RevalidatAnimation(slot)
        
        if not nextSlot.animating then 
            nextSlot.animating = true
            nextSlot:SetScript("OnUpdate", AlertAnimation) 
        end
    end
    
    local function Alert_Pop(slotN, id, text, color)
        if slotN < 1 or slotN >= #alertSlots then return end
        local slot = alertSlots[slotN]
        if slot.popping then return end

        -- Pre-pop setup
        slot.taken = true
        slot.id = id
        slot.text:SetAlpha(1)
        slot.text:SetText(text)
        slot.text:SetTextColor(color.r, color.g, color.b)
        slot.popping = {
            actualFrame = 1,
            since = 0,
            originalHeight = slot:GetHeight()
        }
        
        if not slot.animating then 
            slot.animating = true
            slot:SetScript("OnUpdate", AlertAnimation) 
        end
    end
    
    Alert_PushStack = function(lastSlot)
        local i = lastSlot
        while i > 0 do
            local slot = alertSlots[i]
            if slot.taken then Alert_Push(i,cnt) end
            i = i - 1
        end
        if lastSlot + 1 == #alertSlots then Alert_Drop(#alertSlots) end
    end
    
    local function Alert_Fade(slotN)
        if slotN < 1 or slotN > #alertSlots then return end
        local slot = alertSlots[slotN]
        slot.fading = {
            actualFrame = 1,
            since = 0
        }
        
        if not slot.animating then 
            slot.animating = true
            slot:SetScript("OnUpdate", AlertAnimation) 
        end
    end
    
    local function Alert_GetDestSlot(id)
        if not id then return #alertSlots end
        
        for i,slot in ipairs(alertSlots) do
            if slot.id == id then return i end
        end
        
        return #alertSlots
    end
    
    local function Alert_Quash(slotN)
        if slotN > #alertSlots then return end
        local slot = alertSlots[slotN]
        slot.text:SetText("")
        slot.pushing = nil
        slot.fading = nil
        slot.popping = nil
        slot.taken = false
    end
    
    function module:CreateAlertsFrame()
        local slots = pfl.AlertsNumSlots + 1 -- to include fading slot
        local alertsTestText = AlertsFrameAnchor:CreateFontString(nil,"OVERLAY")
        AlertsFrameAnchor.alertsTestText = alertsTestText
        
        local i = slots
        while i > 0 do
            local frame = CreateFrame("Frame","DXE Alert frame "..i,UIParent)
            alertSlots[i] = frame
            local text = frame:CreateFontString(nil,"OVERLAY")
            frame.text = text
            i = i - 1
        end
        
        for i=1,slots do        
            -- Alerts Frame setup
            local frame = alertSlots[i]
            frame:SetHeight(512)
            frame:SetWidth(1024)
            frame.taken = false
            frame:SetFrameStrata(i==1 and "FULLSCREEN" or "DIALOG")
        end
        
        -- Anchor Test Text
        alertsTestText:SetPoint("CENTER",AlertsFrameAnchor,"CENTER",0,-20)
        alertsTestText:SetShadowColor(0,0,0,0.75)
        alertsTestText:SetShadowOffset(2,-2)
        alertsTestText:SetWordWrap(false)
        alertsTestText:SetJustifyV("TOP")
        alertsTestText:SetJustifyH("CENTER")
        alertsTestText:SetTextColor(0.65,0.165,0.165)

        for i,slot in ipairs(alertSlots) do
            local slotText = slot.text
            slotText:SetShadowColor(0,0,0,0.75)
            slotText:SetShadowOffset(2,-2)
            slotText:SetWordWrap(false)
            slotText:SetJustifyV("TOP")
            slotText:SetJustifyH("CENTER")
            slotText:SetTextColor(0,1,0) 
            slot:SetHeight(slotText:GetStringHeight())
        end
        
        addon:UpdateAlertsFrame(true)
    end
    
    function addon:UpdateAlertsFrame(resetText)
        local slots = pfl.AlertsNumSlots + 1 -- to include fading slot
        AlertsFrameAnchor.alertsTestText:SetFont(SM:Fetch("font",pfl.AlertsFont), pfl.AlertsFontSize, pfl.AlertsFontDecoration)
        if resetText then
            AlertsFrameAnchor.alertsTestText:SetText(DEFAULT_TEST_TEXT)
        end
        AlertsFrameAnchor.alertsTestText:SetHeight(AlertsFrameAnchor.alertsTestText:GetStringHeight())
        
        for i=1,slots do
            local frame = alertSlots[i]
            if frame then
                frame:ClearAllPoints()
                if i==1 then
                    frame:SetPoint("CENTER",AlertsFrameAnchor,"CENTER",0,-20)
                else
                    if pfl.AlertsDirection == "UP" then
                        frame:SetPoint("BOTTOM",alertSlots[i-1],"TOP",0,STACK_OFFSET)
                    else -- pfl.AlertsDirection == "DOWN" (or atleast it should)
                        frame:SetPoint("TOP",alertSlots[i-1],"BOTTOM",0,-STACK_OFFSET)
                    end
                end
            end
        end
        
        for _,slot in ipairs(alertSlots) do
            slot.text:SetFont(SM:Fetch("font",pfl.AlertsFont), pfl.AlertsFontSize, pfl.AlertsFontDecoration)
            slot:SetHeight(pfl.AlertsFontSize)
            slot.text:SetPoint("CENTER",slot,"CENTER")
        end
        
        DURATIONS = {
            ["popping"] = pfl.Alerts_Time_Popping * fps,
            ["pushing"] = pfl.Alerts_Time_Pushing * fps,
            ["dropping"] = pfl.Alerts_Time_Dropping * fps,
            ["holding"] = pfl.Alerts_Time_Holding * fps,
            ["fading"] = pfl.Alerts_Time_Fading * fps,
        }
    end
        
    -----------------------
    -- API
    -----------------------
    function module:AddAlertMessage(text,icon,color,id,replaceID,noColoring)
        if not text then return end
        local pour_text = text
        local keepicons = iconLeft or iconRight
        pour_text = pour_text:gsub("|T[%w\\_\-]+:%d+:%d+|t",function(fragment)
            local texture = fragment:match("|T([%w\\_\-]+):")
            return keepicons and format("|T%s:15:15:0:5|t",texture) or ""
        end)
        pour_text = AssambleAlertText("DXE_FRAME",text,icon,color,noColoring)
        
        local destSlot = Alert_GetDestSlot(replaceID)
        if destSlot < #alertSlots then Alert_Quash(destSlot) end
        
        Alert_PushStack(destSlot-1)
        Alert_Pop(1, id, pour_text, color)
        Alert_Fade(1)
        Alert_UpdateTestText()
    end
    
    function module:Alert_Clear()
        for i,slot in ipairs(alertSlots) do
            slot:SetScript("OnUpdate",nil)
            slot.animating = false
            slot.taken = false
            slot.fading = nil
            slot.popping = nil
            slot.pushing = nil
            slot.dropping = nil
            slot.text:SetText("")
        end
    end
    
end

---------------------------------------------
-- REMOTE ALERT TRIGGER
---------------------------------------------
-- Feature allowing to remotly trigger alerts and arrows by the raid leader.
do
    local COMMTYPE  = "RAT"

	module["OnComm"..COMMTYPE] = function(self,event,commType,sender,alertType,var,...)
        if not UnitIsRaidOfficer(sender) then return end -- only the raid leader or a raid assist are allowed
        if not addon.CE or not addon:IsRunning() then return end
        
        local pfl = addon.db.profile.Encounters[addon.CE.key]
        if alertType == "alert" then
            if not addon.CE.alerts or not addon.CE.alerts[var] or not addon.CE.alerts[var].remote then return end -- only alerts that exist and are expected to be remotly triggered
            if not pfl[var].enabled then return end -- alert is disabled
            -- Setup received parameters
            local paramset = addon.CE.alerts[var].remoteparameters
            if paramset then
                local setvars = {}
                local flag = false
                for i=1,select("#",...) do
                    if paramset[i] then
                        local localparam = paramset[i]
                        local remoteparam = select(i,...)
                        setvars[localparam] = remoteparam
                        flag = true
                    else
                        break
                    end
                end
                
                if flag then 
                    local setargs = {"set"}
                    setargs[2] = setvars
                    addon.Invoker:InvokeCommands({setargs})
                end
                addon.Invoker:InvokeCommands({{"alert",{var, text = "p", replace = "RAT-"..var}}})
            else
                addon.Invoker:InvokeCommands({{"alert",var, replace = "RAT-"..var}})
            end
        elseif alertType == "arrow" then
            if not addon.CE.arrows or not addon.CE.arrows[var].remote then return end -- only arrows that are expected to be remotly triggered
            if not pfl[var].enabled then return end -- arrow is disabled
            addon.Invoker:InvokeCommands({{"arrow",var}})
        end
	end

	addon.RegisterCallback(module,"OnComm"..COMMTYPE)
end
