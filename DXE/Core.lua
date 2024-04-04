---------------------------------------------
-- DEFAULTS
---------------------------------------------

--[===[@debug@
local debug

local debugDefaults = {
    CheckForEngage = true,
    CombatStop = false,
    CHAT_MSG_MONSTER_YELL = false,
    RAID_ROSTER_UPDATE = false,
    PARTY_MEMBERS_CHANGED = false,
    BlockBossEmotes = false,
    TriggerDefeat = false,
    UNIT_NAME_UPDATE = false,
    INSTANCE_ENCOUNTER_ENGAGE_UNIT = true,
}
--@end-debug@]===]

local defaults = {
    global = {
        Locked = true,
        AlertTestingRunning = false,
        AdvancedMode = false,
        EncounterCategories = true,
        -- NPC id -> Localized name
        L_NPC = {},
        --[===[@debug@
        debug = debugDefaults,
        --@end-debug@]===]
    },
    profile = {
        Enabled = true,
        Positions = {
            ["DXEPane"] = {
                ["point"] = "TOPRIGHT",
                ["relativePoint"] = "TOPRIGHT",
                ["xOfs"] = -200,
                ["yOfs"] = 0,
            },
            ["DXEAlertsTopStackAnchor"] = {
                ["point"] = "TOPLEFT",
                ["relativePoint"] = "TOPLEFT",
                ["xOfs"] = 50,
                ["yOfs"] = -150,
            },
            ["DXEAlertsCenterStackAnchor"] = {
                ["point"] = "LEFT",
                ["relativePoint"] = "LEFT",
                ["xOfs"] = 150,
                ["yOfs"] = -100,
            },
            ["DXEAlertsWarningStackAnchor"] = {
                ["point"] = "TOP",
                ["relativePoint"] = "TOP",
                ["xOfs"] = 6.428568840026856,
                ["yOfs"] = -100.7143707275391,
            },
            ["DXEAlertsEmphasisStackAnchor"] = {
                ["point"] = "CENTER",
                ["relativePoint"] = "CENTER",
                ["xOfs"] = 0,
                ["yOfs"] = 100,
            },
            ["DXEEmphasisFrameAnchor"] = {
                ["point"] = "CENTER",
                ["relativePoint"] = "CENTER",
                ["xOfs"] = 0,
                ["yOfs"] = 200,
            },
            ["DXEAlertsFrameAnchor"] = {
                ["point"] = "CENTER",
                ["relativePoint"] = "CENTER",
                ["xOfs"] = 0,
                ["yOfs"] = 300,
            },
            ["DXEScoreFrameAnchor"] = {
                ["point"] = "TOP",
                ["relativePoint"] = "TOP",
                ["xOfs"] = 0,
                ["yOfs"] = -35,
            },
        },
        Dimensions = {},
        Scales = {},
        Encounters = {},
        Globals = {
            BarTexture = "Blizzard",
            Font = "Franklin Gothic Medium",
            TimerFont = "Bastardus Sans",
            Border = "Blizzard Tooltip",
            BorderColor = {0.33,0.33,0.33,1},
            BorderEdgeSize = 8,
            BackgroundColor = {0,0,0,0.8},
            BackgroundInset = 2,
            BackgroundTexture = "Blizzard Tooltip",
        },
        Pane = {
            Show = true,
            Scale = 1,
            Width = 230,
            OnlyInRaid = false,
            OnlyInParty = false,
            OnlyInRaidInstance = false,
            OnlyInPartyInstance = false,
            OnlyIfRunning = false,
            OnlyOnMouseover = false,
            BarGrowth = "AUTOMATIC",
            FontColor = {1,1,1,1},
            TitleFontSize = 10,
            HealthFontSize = 12,
            NeutralColor = {1,0.6549019607843137,0,1},
            LostColor = {0.66,0.66,0.66,1},
            BarSpacing = 0,
            BarTexture = "Blizzard",
            Border = "Blizzard Tooltip",
            BorderColor = {0.33,0.33,0.33,1},
            BorderEdgeSize = 8,
            SelectedBorder = "Blizzard Tooltip",
            SelectedBorderColor = {1,1,1,1},
            SelectedBorderEdgeSize = 8,
            ShowBestTimePane = true,
            RecordBestTime = true,
            AnnounceRecordKillOnScreen = true,
            ScreenshotBestTime = false,
            BarShowSpark = true,
            PhaseMarkersShowDescription = true,
            PhaseMarkersEnable = true,
            ButtonsVisibility = {
                Stop = false,
                Configuration = false,
                Folder = false,
            }
        },
        Misc = {
            DefaultMessageLanguage = "en",
            BlockBossEmoteMessages = false,
            BlockRaidWarningMessages = false,
            BlockBossEmoteFrame = false,
            BlockRaidWarningFrame = false,
            HideBlizzardBossFrames = false,
        },
        Chat = {
            AchievementAnnouncements = true,
            AnnounceRecordKill = false,
            AnnounceRecordKillWithDiff = false,
        },
        SpecialTimers = {
            PullTimerEnabled = true, 
            PullColor1 = "GOLD",
            PullColor2 = "RED",
            PullAudioCD = true,
            PullIcon = true,
            PullTimerCancelOnPull = true,
            BreakTimerEnabled = true,
            BreakColor1 = "GOLD",
            BreakColor2 = "RED",
            BreakIcon = true,    
            PullTimers = {10,15},
            BreakTimers = {60,120,300,600,900},
            PullTimerPrefered = 1,
        },
        SpecialWarnings = {
            VictoryAnnouncementEnabled = true,
            VictorySound = true,
            VictoryScreenshot = false,
            SpecialOutput = "LEGION_OUTPUT",
        },
        Windows = {
            TitleBarColor = {0,0.317,0.537,1},
            Proxtype = "RADAR",
        },
        Proximity = {
            AutoPopup = true,
            AutoHide = true,
            BarAlpha = 0.4,
            Range = 10,
            Delay = 0.05,
            ClassFilter = {['*'] = true},
            Invert = false,
            Dummy = false,
            Rows = 5,
            NameFontSize = 9,
            TimeFontSize = 9,
            NameOffset = -12,
            NameAlignment = "CENTER",
            TimeOffset = -12,
            IconPosition = "LEFT",
            DotSize = 12,
            RaidIcons = "REPLACE",
            
            RadarBackgroundColor = {0,0,0,0.4},
            RadarHideBackground = true,
            RadarHideBorder = true,
            RadarHideTitleBar = true,
            RadarAlwaysShowTitle = false,
            RadarAlwaysShowCloseButton = false,
            RadarExtraDistance = 50,
            RadarNoDistanceCheckAlpha = 0.1,
            RadarCircleColorSafe = {0.251, 0.86, 0, 1},
            RadarCircleColorInRange = {1, 1, 0, 1},
            RadarCircleColorDanger = {1, 0, 0, 1},
            
            ProximityBackgroundColor = {0,0,0,0},
            ProximityHideBackground = false,
            ProximityHideBorder = false,
            ProximityHideTitleBar = true,
            ProximityAlwaysShowTitle = false,
            ProximityAlwaysShowCloseButton = false,
            HideOnEncounterSelection = false,
        },
        AlternatePower = {
            AutoPopup = true,
            AutoHide = true,
            BarAlpha = 0.4,
            Threshold = 1,
            Delay = 0.5, -- raised delay for less cpu pain
            ClassFilter = {['*'] = true},
            Invert = false,
            Dummy = false,
            Rows = 5,
            NameFontSize = 9,
            TimeFontSize = 9,
            NameOffset = -12,
            NameAlignment = "CENTER",
            TimeOffset = -12,
            IconPosition = "LEFT",
            BackgroundColor = {0, 0, 0, 0.5},
            HideBackground = false,
            HideBorder = false,
            HideTitleBar = true,
            AlwaysShowTitle = false,
            AlwaysShowCloseButton = false,
        },
        Sounds = {
            ALERT1 = "Bell Toll Alliance",
            ALERT2 = "Bell Toll Horde",
            ALERT3 = "Low Mana",
            ALERT4 = "Low Health",
            ALERT5 = "Zing Alarm",
            ALERT6 = "Wobble",
            ALERT7 = "Bottle",
            ALERT8 = "Lift Me",
            ALERT9 = "Neo Beep",
            ALERT10 = "PvP Flag Taken",
            ALERT11 = "Bad Press",
            ALERT12 = "Run Away",
            VICTORY_RAID = "FF2 Victory",
            VICTORY_PARTY = "UT2K3 Victory",
            WIPE = "FF1 Wipe",
            MINORWARNING = "Minor Warning",
            BURST = "Shadow Dance",
            BEWARE = "Algalon Beware",
            RUNAWAY = "RunAway", 
            COUNTDOWN_TICK = "Countdown: Tick",
            COUNTDOWN_GO = "Countdown: Go",
            ROLE_CHECK = "LevelUp",
            LFG_READY_CHECK = "ReadyCheck",
            RBG_READY_CHECK = "BGReadyCheck",
            ENTERING_LFG = "EnteringGroup"
        },
        CustomSounds = {},
        CustomSoundFiles = {},
        RoleCheck = {
            SoundThrottle = 5,
            SuppressWhenRoleSelected = true,
            AutoSelectRole = {
                ["none"] = true,
                ["party"] = true,
                ["raid"] = true,
                ["pvp"] = true,
            },
            AutoSelectRoleRespec = true,
        },
    },
}

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

local addon = LibStub("AceAddon-3.0"):NewAddon("DXE","AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
_G.DXE = addon
addon.version = "635 | 3.3 - 17"
addon.versionfull = format("|cff99ff33%s (official)|r|cffffffff | |r|cffe6cc80%s (developed by|r |cffffffffGreghouse|r|cffe6cc80)|r",635,"3.3 - 17")
addon.developer = "Greghouse"
addon.website = "http://dxe.jecool.net"
addon:SetDefaultModuleState(false)
addon.callbacks = LibStub("CallbackHandler-1.0"):New(addon)
addon.defaults = defaults
addon.pluginmodules = {}
addon.originalfunctions = {}
---------------------------------------------
-- UPVALUES
---------------------------------------------

local wipe,remove,sort = table.wipe,table.remove,table.sort
local match,find,gmatch,sub,lower = string.match,string.find,string.gmatch,string.sub,string.lower
local print,format = print,string.format
local _G,select,tostring,type,tonumber = _G,select,tostring,type,tonumber
local GetTime,GetNumRaidMembers,GetNumPartyMembers,GetRaidRosterInfo = GetTime,GetNumRaidMembers,GetNumPartyMembers,GetRaidRosterInfo
local UnitName,UnitGUID,UnitIsEnemy,UnitClass,UnitAffectingCombat,UnitHealth,UnitHealthMax,UnitIsFriend,UnitIsDead,UnitIsConnected =
        UnitName,UnitGUID,UnitIsEnemy,UnitClass,UnitAffectingCombat,UnitHealth,UnitHealthMax,UnitIsFriend,UnitIsDead,UnitIsConnected
local UnitInVehicle = UnitInVehicle
local rawget,unpack = rawget,unpack

local db,gbl,pfl

local PreventPullTimer
local DelayWipeTimer,wipeDelayed
local startedOnIEEU = "beruska"
local lastDefeatTime

---------------------------------------------
-- LIBS
---------------------------------------------

local AceTimer = LibStub("AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DXE")
local SM = LibStub("LibSharedMedia-3.0")
local LDS = LibStub("LibDualSpec-1.0",true)
local AL

-- Localized spell names
local SN = setmetatable({},{
    __index = function(t,k)
        if type(k) ~= "number" then return "nil" end
        local name = GetSpellInfo(k)
        t[k] = name
        if not name then
            geterrorhandler()("Invalid spell name attempted to be retrieved")
            return tostring(k)
        end
        return name
    end,
})

-- Spell textures - caching is unnecessary
local ST = setmetatable({},{
    __index = function(t,k)
        if type(k) ~= "number" then return "nil" end
        local texture = select(3,GetSpellInfo(k))
        if not texture then
            geterrorhandler()("Invalid spell texture attempted to be retrieved")
            return "Interface\\Buttons\\WHITE8X8"
        end
        return texture
    end,
})

-- Spell link
local SL = setmetatable({},{
    __index = function(t,k)
        if type(k) ~= "number" then return "nil" end
        local texture = select(1,GetSpellLink(k))
        if not texture then
            geterrorhandler()("Invalid spell texture attempted to be retrieved")
            return "Interface\\Buttons\\WHITE8X8"
        end
        return texture
    end,
})

-- Localized Encounter Journal Entries
-- Input: sectionID
-- Output: Localized name of section
local EJSN = setmetatable({},{
    __index = function(t,k)
        if type(k) ~= "number" then return "nil" end
        local name = select(1,EJ_GetSectionInfo(k))
        if not name then
            geterrorhandler()("Invalid EJ section attempted to be retrieved")
            return tostring(k)
        end
        return name
    end,
})
-- Encounter Journal textures
local EJST = setmetatable({},{
    __index = function(t,k)
        if type(k) ~= "number" then return "nil" end
        local texture = select(4,EJ_GetSectionInfo(k))
        if not texture then
            geterrorhandler()("Invalid spell texture attempted to be retrieved")
            return "Interface\\Buttons\\WHITE8X8"
        end
        return texture
    end,
})

-- NPC IDs
local GUID_LENGTH = 18
local UT_NPC = 3
local UT_VEHICLE = 5
addon.BOSS_MAX = 20

-- 12484 is the version that China got the new format, so doing it this way works
-- for both China and 4.0.x
local NEW_GUID_FORMAT = tonumber((select(2,GetBuildInfo()))) >= 12484

local NID = setmetatable({},{
    __index = function(t,guid)
        if type(guid) ~= "string" or #guid ~= GUID_LENGTH or not guid:find("%xx%x+") then return end
        local ut = tonumber(sub(guid,5,5),16) % 8
        local isNPC = ut == UT_NPC or ut == UT_VEHICLE
        local npcid
        if NEW_GUID_FORMAT then
            npcid = isNPC and tonumber(sub(guid,7,10),16)
        else
            npcid = isNPC and tonumber(sub(guid,9,12),16)
        end
        t[guid] = npcid
        return npcid
    end,
})

-- Color name
local class_to_color = {}
for class,color in pairs(RAID_CLASS_COLORS) do
    class_to_color[class] = ("|cff%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
end
addon.ClassToColor = class_to_color

local CN = setmetatable({}, {__index =
    function(t, unit)
        local class = select(2,UnitClass(unit))
    if not class then return unit end
        local name = UnitName(unit)
        local prev = rawget(t,name)
        if prev then return prev end
        t[name] = class_to_color[class]..name.."|r"
        return t[name]
    end,
})

-- Achievement name
local AN = setmetatable({}, {__index = 
    function (t, achievementID)
        if type(achievementID) ~= "number" then return "" end
        return select(2,GetAchievementInfo(achievementID))
    end,
})

-- Achievement link
local AL = setmetatable({}, {__index = 
    function (t, achievementID)
        if type(achievementID) ~= "number" then return "" end
        return GetAchievementLink(achievementID)
    end,
})

-- Achievement textures
local AT = setmetatable({},{
    __index = function(t,k)
        if type(k) ~= "number" then return "nil" end
        local texture = select(10,GetAchievementInfo(k))
        if not texture then
            geterrorhandler()("Invalid spell texture attempted to be retrieved")
            return "Interface\\Buttons\\WHITE8X8"
        end
        return texture
    end,
})

-- Item texture
local IT = setmetatable({},{
    __index = function(t,k)
        if type(k) ~= "number" then return "nil" end
        local texture = select(10,GetItemInfo(k))
        if not texture then
            geterrorhandler()("Invalid item texture attempted to be retrieved")
            return "Interface\\Buttons\\WHITE8X8"
        end
        return texture
    end,
})

do
    local embeds = {
        L = L,
        LDS = LDS,
        SN = SN,
        SL = SL,
        NID = NID,
        CN = CN,
        SM = SM,
        ST = ST,
        EJSN = EJSN,
        EJST = EJST,
        AL = AL,
        AT = AT,
        AN = AN,
        IT = IT,
    }
    for k,v in pairs(embeds) do addon[k] = v end
end

function addon:GetPlayerList()
    local list = {}
    if GetNumRaidMembers() > 0 then
        for i=1,GetNumRaidMembers() do
            local unit = "raid"..i
            list[unit] = CN[unit]
        end
    elseif GetNumPartyMembers() then
        for i=1,GetNumPartyMembers() do
            local unit = "party"..i
            list[unit] = CN[unit]
        end
        list["player"] = CN["player"]
    else
        list["player"] = CN["player"]
    end
    
    return list
end

function addon:GetPlayerNamedList()
    local list = {}
    if GetNumRaidMembers() > 0 then
        for i=1,GetNumRaidMembers() do
            local unit = "raid"..i
            local name = UnitName(unit)
            list[name] = CN[unit]
        end
    elseif GetNumPartyMembers() then
        for i=1,GetNumPartyMembers() do
            local unit = "party"..i
            local name = UnitName(unit)
            list[name] = CN[unit]
        end
        list[UnitName("player")] = CN["player"]
    else
        list[UnitName("player")] = CN["player"]
    end
    
    return list
end

local RoleToEnabledKeyMap = {
    TANK = "Tank",
    HEALER = "Heal",
    DAMAGER = "DPS",
}

function addon:IsRoleEnabled(enabled)
    if type(enabled) == "boolean" then
        return enabled
    elseif type(enabled) == "table" then
        local role = UnitGroupRolesAssigned("player")
        if role == "NONE" then
            return true
        else
            return enabled[RoleToEnabledKeyMap[role]]
        end
    end
end

---------------------------------------------
-- UTILITY
---------------------------------------------

local ipairs,pairs = ipairs,pairs

local util = {}
addon.util = util

local function tablesize(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local function search(t,value,i)
    for k,v in pairs(t) do
        if i then
            if type(v) == "table" and v[i] == value then return k end
        elseif v == value then return k end
    end
end

local function contains(value,t)
    for _,v in ipairs(t) do
        if value == v then return true end
    end

    return false
end

local function toRGBA(c)
    return {
        r = c[1] or 1,
        g = c[2] or 1,
        b = c[3] or 1,
        a = c[4] or 1
    }
end

local function blend(c1, c2, factor)   
    c1 = {
        r = c1.r or 1,
        g = c1.g or 1,
        b = c1.b or 1,
    }
    
    c2 = {
        r = c2.r or 1,
        g = c2.g or 1,
        b = c2.b or 1,
    }
    
    local r = (1-factor) * c1.r + factor * c2.r
    local g = (1-factor) * c1.g + factor * c2.g
    local b = (1-factor) * c1.b + factor * c2.b
    return r,g,b
end

local function blendSpark(c1, c2, factor)
    c1 = {
        sr = c1.sr or 1,
        sg = c1.sg or 1,
        sb = c1.sb or 1,
    }
    
    c2 = {
        sr = c2.sr or 1,
        sg = c2.sg or 1,
        sb = c2.sb or 1,
    }
    local r = (1-factor) * c1.sr + factor * c2.sr
    local g = (1-factor) * c1.sg + factor * c2.sg
    local b = (1-factor) * c1.sb + factor * c2.sb
    return r,g,b
end

local function safecall(func,...)
    local success,err = pcall(func,...)
    if not success then geterrorhandler()(err) end
    return success
end

function addon:CopyTable(tbl)
    if type(tbl) ~= "table" then return tbl end
    
    local newTbl = {}
    for k,v in pairs(tbl) do
        newTbl[k] = v
    end
    
    return newTbl
end

local function run(func,...)
    if func == nil then return end
    if type(func) ~= "function" then 
        error("Unable to run a function. Passed variable isn't a function It's a ."..type(func))
        return
    end
    
    return func(...)
end

local function TraverseTable(tbl, ...)       
    for i=1,select("#",...) do
        if tbl == nil or type(tbl) ~= "table" then return nil end
        tbl = tbl[select(i,...)]
    end
    
    return tbl
end

local function lookup(target, source)
    if type(source) == "table" then
        for _,item in ipairs(source) do
            if item == target then
                return true
            end
        end
    else
        return target == source
    end
end

local function capitalize(text)
    return text:gsub("^%l", string.upper)
end


util.tablesize = tablesize
util.search = search
util.contains = contains
util.blend = blend
util.toRGBA = toRGBA
util.blendSpark = blendSpark
util.safecall = safecall
util.run = run
util.TraverseTable = TraverseTable
util.lookup = lookup
util.capitalize = capitalize

---------------------------------------------
-- MODULES
---------------------------------------------

function addon:EnableAllModules()
    for name in self:IterateModules() do
        self:EnableModule(name)
    end
end

function addon:DisableAllModules()
    for name in self:IterateModules() do
        self:DisableModule(name)
    end
end

---------------------------------------------
-- PROXIMITY CHECKING
---------------------------------------------

do
    -- 18 yards
    local bandages = {
        [34722] = true, -- Heavy Frostweave Bandage
        [34721] = true, -- Frostweave Bandage
        [21991] = true, -- Heavy Netherweave Bandage
        [21990] = true, -- Netherweave Bandage
        [14530] = true, -- Heavy Runecloth Bandage
        [14529] = true, -- Runecloth Bandage
        [8545] = true, -- Heavy Mageweave Bandage
        [8544] = true, -- Mageweave Bandage
        [6451] = true, -- Heavy Silk Bandage
        [6450] = true, -- Silk Bandage
        [3531] = true, -- Heavy Wool Bandage
        [3530] = true, -- Wool Bandage
        [2581] = true, -- Heavy Linen Bandage
        [1251] = true, -- Linen Bandage
    }
    -- CheckInteractDistance(unit,i)
    -- 2 = Trade, 11.11 yards
    -- 3 = Duel, 9.9 yards
    -- 4 = Follow, 28 yards

    local IsItemInRange = IsItemInRange
    local knownBandage
    -- Keys refer to yards
    local ProximityFuncs = {
        [10] = function(unit) return CheckInteractDistance(unit,3) end,
        [11] = function(unit) return CheckInteractDistance(unit,2) end,
        [18] = function(unit)
            if knownBandage then
                return IsItemInRange(knownBandage,unit) == 1
            else
                for itemid in pairs(bandages) do
                    if IsItemInRange(itemid,unit) == 1 then
                        knownBandage = itemid
                        return true
                    end
                end
                -- default to 11
                return CheckInteractDistance(unit,2)
            end
        end,
        [28] = function(unit) return CheckInteractDistance(unit,4) end,
    }

    function addon:GetProximityFuncs()
        return ProximityFuncs
    end
end

function addon:ShowProximity(range,disableDistanceCheck)
    if not range then range = pfl.Proximity.Range end
    range = tonumber(range)
    if range < 1 or range > 100 then
        addon:Print("Proximity distance must be a number between 0 (exclusive) and 100 (inclusive).")
        
        return nil
    end
    
    addon:UpdateDistanceLocks()
    if pfl.Windows.Proxtype == "RADAR" then
        if(range) then
            addon:Radar(range, disableDistanceCheck)
        else
            addon:Radar()
        end
    else
        if(range) then
            addon:Proximity(range)
        else
            addon:Proximity()
        end
    end
end

function addon:IsRangeShown()
    return addon:IsProximityShown() or addon:IsRadarShown()
end

function addon:UpdateProximityProfile()
    if pfl.Windows.Proxtype == "RADAR" then
        addon:UpdateRadarSettings()
    else
        addon:UpdateProximitySettings()
    end
end

---------------------------------------------
-- RAID DIFFICULTY
---------------------------------------------

function addon:GetRaidDifficulty()
    local diff
    local _, type, index, _, _, heroic, dynamic = GetInstanceInfo()
    if type == "raid" then
        if dynamic then
            diff = index
            if heroic == 1 and diff <= 2 then
                diff = diff + 2
            end
        else
            diff = index
        end
    elseif type == "party" then
        diff = index
    end
    return diff
end

function addon:GetRaidSize()
    local size = select(5, GetInstanceInfo())
    return size
end

function addon:IsHeroic()
    local _, type, index, _, _, heroic, dynamic = GetInstanceInfo()
    if type == "raid" then
        return index > 2
    elseif type == "party" then
        return index == 2
    else
        return 1
    end
end

function addon:IsRaidType()
    return select(2,GetInstanceInfo()) == "raid"
end

function addon:IsPartyType()
    return select(2,GetInstanceInfo()) == "party"
end

local diff_to_key = {
    [1] = "10n",
    [2] = "25n",
    [3] = "10h",
    [4] = "25h",
}

local diff_to_dim_key = {
    [1] = "10man",
    [2] = "25man",
    [3] = "10man",
    [4] = "25man",
}

local function PrefixByDiffMap(data,prefix,map)
    local diff = addon:GetRaidDifficulty()
    local key = prefix..(map[diff] or "")
    return data[key]
end

addon.PrefixByDifficulty = function(data,prefix)
    return PrefixByDiffMap(data,prefix,diff_to_key)
end

addon.PrefixByGroupSize = function(data,prefix)
    return PrefixByDiffMap(data,prefix,diff_to_dim_key)
end

---------------------------------------------
-- FUNCTION THROTTLING
---------------------------------------------

do
    -- Error margin added to ScheduleTimer to ensure it fires after the throttling period
    local _epsilon = 0.2
    -- @param _postcall A boolean determining whether or not the function is called
    --                    after the end of the throttle period if called during it. If this
    --                         is set to true the function should not be passing in arguments
    --                      because they will be lost
    local function ThrottleFunc(_obj,_func,_time,_postcall)
        --[===[@debug@
        assert(type(_func) == "string","Expected _func to be a string")
        assert(type(_obj) == "table","Expected _obj to be a table")
        assert(type(_obj[_func]) == "function","Expected _obj[func] to be a function")
        assert(type(_time) == "number","Expected _time to be a number")
        assert(type(_postcall) == "boolean","Expected _postcall to be a boolean")
        assert(AceTimer.embeds[_obj],"Expected obj to be AceTimer embedded")
        --@end-debug@]===]
        local _old_func = _obj[_func]
        local _last,_handle = GetTime() - _time
        _obj[_func] = function(self,...)
            local _t = GetTime()
            if _last + _time > _t then
                if _postcall and not _handle then
                    _handle = self:ScheduleTimer(_func,_last + _time - _t + _epsilon)
                end
                return
            end
            _last = _t
            self:CancelTimer(_handle,true)
            _handle = nil
            return _old_func(self,...)
        end
    end

    addon.ThrottleFunc = ThrottleFunc
end

---------------------------------------------
-- ENCOUNTER MANAGEMENT
-- Credits to RDX
---------------------------------------------
local EDB = {}
addon.EDB = EDB
local CC = {} -- Category Counters
local ZONE_TO_CATEGORY = {} -- Category to Zone
addon.ZONE_TO_CATEGORY = ZONE_TO_CATEGORY
-- Current encounter data
local CE
-- Received database
local RDB

local DEFEAT_NID
local DEFEAT_NIDS

local RegisterQueue = {}
local Initialized = false
local encIterator = 1
function addon:RegisterEncounter(data)
    local key = data.key
    
    -- Convert version
    data.version = type(data.version) == "string" and tonumber(data.version:match("%d+")) or data.version

    -- Add to queue if we're not loaded yet
    if not Initialized then RegisterQueue[key] = data return end
    
    --[===[@debug@
    local success = safecall(self.ValidateData,self,data)
    if not success then return end
    --@end-debug@]===]

    -- Upgrading
    if RDB[key] and RDB[key] ~= data then
        if RDB[key].version <= data.version then
            local version = RDB[key].version
            RDB[key] = nil
            if version == data.version then
                -- Don't need to do anything
                return
            else
                self:UnregisterEncounter(key)
            end
        else
            -- RDB version is higher
            return
        end
    end

    -- Unregister before registering the same encounter
    if EDB[key] then error("Encounter "..key.." already exists - Requires unregistering") return end

    -- Only encounters with field key have options
    if key ~= "default" then
        data.order = encIterator
        encIterator = encIterator + 1
        self:AddEncounterDefaults(data)
        self:RefreshDefaults()
        self.callbacks:Fire("OnRegisterEncounter",data)
        self:UpdateTriggers()
    end

    if data and data.category then
        if data.category then
            if not ZONE_TO_CATEGORY[data.zone] then
                ZONE_TO_CATEGORY[data.zone] = {category = data.category, count = 1}
            else
                ZONE_TO_CATEGORY[data.zone].count = ZONE_TO_CATEGORY[data.zone].count + 1
            end
            if not ZONE_TO_CATEGORY[data.category] then
                ZONE_TO_CATEGORY[data.category] = {category = data.category, count = 1}
            elseif data.zone ~= data.category then
                ZONE_TO_CATEGORY[data.category].count = ZONE_TO_CATEGORY[data.category].count + 1
            end
        else
            if not ZONE_TO_CATEGORY[data.zone] then
                ZONE_TO_CATEGORY[data.zone] = {category = data.zone, count = 1}
            else
                ZONE_TO_CATEGORY[data.zone].count = ZONE_TO_CATEGORY[data.zone].count + 1
            end
        end
        
        local ckey = data.category or data.zone
        if not CC[ckey] then
            CC[ckey] = 1
        else
            CC[ckey] = CC[ckey] + 1
        end
        data.order = CC[ckey]
    end
    --addon:RegisterEncounterToGroup(data)
    EDB[key] = data
end

--- Remove an encounter previously added with RegisterEncounter.
function addon:UnregisterEncounter(key)
    if key == "default" or not EDB[key] then return end

    -- Swap to default if we're trying to unregister the current encounter
    if CE.key == key then self:SetActiveEncounter("default") end

    self:UpdateTriggers()
    self.callbacks:Fire("OnUnregisterEncounter",EDB[key])
    local category = EDB[key].category or EDB[key].zone
    
    if category and ZONE_TO_CATEGORY[category] then
        ZONE_TO_CATEGORY[category].count = ZONE_TO_CATEGORY[category].count - 1
        if ZONE_TO_CATEGORY[category].count == 0 then
            ZONE_TO_CATEGORY[category] = nil
        end
    end

    EDB[key] = nil
end

--- Get the name of the currently-active encounter
function addon:GetActiveEncounter()
    return CE and CE.key or "default"
end

function addon:SetCombat(flag,event,func)
    if flag then self:RegisterEvent(event,func) end
end

function addon:SetProximityVisible(showWindow,range,disableDistanceCheck)
    if type(showWindow) ~= "boolean" then return end
    
    if showWindow then
        self:OpenProximity(range,disableDistanceCheck)
    else
        self:CloseProximity()
    end
end

function addon:AutoOpenProximity(isPull)
    -- Not showing if the global HideOnEncounterSelection option is enabled
    if not isPull and pfl.Proximity.HideOnEncounterSelection then return false end
    
    local encdb = pfl.Encounters[CE.key]
    local proxdb = encdb and encdb.proxwindow
    
    -- Not showing if there are no module proximity settings
    if not proxdb then return false end
    
    -- Not showing if it's specifically stated by the module
    if proxdb.proxnoautostart then return false end

    return addon:OpenProximity()
end

function addon:OpenProximity(range,disableDistanceCheck)
    local proxType = pfl.Windows.Proxtype
    
    -- Not showing for Default encounter
    if not CE or not CE.key or CE.key == "default" then return false end
    
    -- Not showing if AutoPopup is disabled
    if not pfl.Proximity.AutoPopup then return false end
    
    local encdb = pfl.Encounters[CE.key]
    local proxdb = encdb and encdb.proxwindow
    
    -- Not showing if there are no module proximity settings
    if not proxdb then return false end
    
    -- Not showing if it's disabled or disabled based on role settings
    if not addon:IsRoleEnabled(proxdb.enabled) then return false end
    
    if type(range) ~= "number" then range = nil end
    range = range or (proxdb.proxoverride and proxdb.proxrange)
    
    if type(disableDistanceCheck) ~= "boolean" then disableDistanceCheck = false end
    if CE.windows then disableDistanceCheck = CE.windows.nodistancecheck or false end
    
    addon:ShowProximity(range,disableDistanceCheck)
    
    return true
end

function addon:CloseProximity()
    addon:HideProximity()
    addon:HideRadar()
end

function addon:OpenWindows(isPull)
    local encdb = pfl.Encounters[CE.key]
    
    -- Proximity window
    if not self:AutoOpenProximity(isPull) then self:CloseProximity() end
    
    -- Alternate Power Bar window
    local apbdb = encdb and encdb.apbwindow
    if apbdb and addon:IsRoleEnabled(apbdb.enabled) then
        local threshold = apbdb.apboverride and apbdb.apbthreshold
        local text = apbdb.apbtext
        self:AlternatePower(true,range,text)
    elseif pfl.AlternatePower.HideOnEncounterSelection then
        self:HideAlternatePower()
    end
end

do
    local frame = CreateFrame("Frame")
    local DEFEAT_MSG
    local DEFEAT_TBL = {}

    frame:SetScript("OnEvent",function(self,event,msg)
        local defeatMsgTbl = type(DEFEAT_MSG) == "table" and DEFEAT_MSG or {DEFEAT_MSG}
        for i,defeatMsg in ipairs(defeatMsgTbl) do
            if find(msg,defeatMsg) then
                if addon:IsModuleBattleground() then
                    local winningSide = msg:match("The (%a+) wins")
                    addon:TriggerBattlegroundVictory(winningSide)
                    return
                else
                    addon:TriggerDefeat()
                    return
                end
            end
        end
    end)

    function addon:ResetDefeat()
        wipe(DEFEAT_TBL)
        DEFEAT_NID = nil
        DEFEAT_NIDS = nil
        DEFEAT_MSG = nil
        frame:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
        frame:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")
        frame:UnregisterEvent("CHAT_MSG_MONSTER_SAY")
        frame:UnregisterEvent("CHAT_MSG_MONSTER_PARTY")
    end

    function addon:ResetDefeatTbl()
        for k in pairs(DEFEAT_TBL) do DEFEAT_TBL[k] = false end
    end   
    
    function addon:Screen()
        Screenshot()
    end
    
    function addon:TriggerDefeat()
        if addon:GetActiveEncounter() == "default" then return end
        if not self:IsRunning() then return end
        
        -- Retrieve advanced settings
        local silentDefeat
        local preventPostDefeatPull -- contains a number
        if CE.advanced then
            silentDefeat = CE.advanced.silentDefeat
            preventPostDefeatPull = CE.advanced.preventPostDefeatPull 
        end
        
        if preventPostDefeatPull then
            addon:SetPreventPull(preventPostDefeatPull)
        end
        
        -- Allow the next delayed wipe
        if DelayWipeTimer then
            self:CancelTimer(DelayWipeTimer,true)
            DelayWipeTimer = nil
        end
        wipeDelayed = false
        
        -- Handle defeat alert
        local screenTaken = false
        local isTrash = self:IsModuleTrash(CE.key)
        local isEvent = self:IsModuleEvent(CE.key)
        local heroic = self:IsHeroic()
        addon.Alerts.QuashAll()
        if pfl.SpecialWarnings.VictoryAnnouncementEnabled and not silentDefeat and not isTrash then           
            local sound = pfl.SpecialWarnings.VictorySound and addon.Media.Sounds:GetFile(addon:IsRaidType() and "VICTORY_RAID" or "VICTORY_PARTY") or "None"
            if not isEvent then
                addon.Alerts:EncounterDefeatedAlert(CE, heroic, sound)
            else
                addon.Alerts:EventCompletedAlert(CE, sound)
            end
            
            -- A defeat screenshot
            if pfl.SpecialWarnings.VictoryScreenshot and not silentDefeat then
                screenTaken = true
                self:ScheduleTimer("Screen",3)
            end
        end
        
        
        
        -- Stop the encounter
        self.callbacks:Fire("TriggerDefeat",CE)
        self:StopEncounter()

        if pfl.Proximity.AutoHide then
            self:CloseProximity()
        end
        
        if pfl.AlternatePower.AutoHide then
            self:HideAlternatePower()
        end
        
        -- Speed kill record
        local override
        lastDefeatTime = GetTime()
        if CE.advanced and CE.advanced.recordBestTime then override = CE.advanced.recordBestTime end
        if (not isTrash and not isEvent) or override then
            local oldTime = addon:GetBestTime(CE.key)
            local newTime = addon.Pane.timer:GetTime()
            
            addon:UpdateBestTimeDiff(true)
            
            if pfl.Pane.RecordBestTime then
                if newTime > 1 and (not oldTime or newTime < oldTime) then
                    addon:SetNewBestTime(newTime,CE.key)
                    if not isTrash then
                        if oldTime then addon.Pane.timer:SetTextColor(0.13, 0.57, 1) else addon.Pane.timer:SetTextColor(0, 1, 0) end
                        addon.Pane.besttimerlabel:SetText("Former speed kill:")
                        local recordTime = addon:TimeToText(newTime)
                        if pfl.Pane.AnnounceRecordKillOnScreen and not silentDefeat then
                            addon.Alerts:SpeedkillRecordAlert(recordTime,pfl.SpecialWarnings.VictoryAnnouncementEnabled)
                        end
                        local dim,diff = addon:GetRaidInfo()
                        local difficultyFull = format("%s-Player %s", dim, diff)
                        if pfl.Chat.AnnounceRecordKill then
                            local channel = ((GetNumRaidMembers() == 0) and (GetNumPartyMembers() == 0 and "SAY" or "PARTY")) or "RAID"
                            local timeImprovement = ""
                            if pfl.Chat.AnnounceRecordKillWithDiff and oldTime then
                                local totalImprovement = oldTime - newTime
                                if totalImprovement >= 0.001 then
                                    timeImprovement = format(" (an improvement of %s)",addon:TimeToText(oldTime - newTime, true))
                                else
                                    timeImprovement = " (an improvement of {STAR} LESS THAN A MILLISECOND {STAR})"
                                end
                            end
                            local completionLabel = isEvent and "time" or "kill"
                            local recordMsg = format("A new fastest %s for %s (%s) is now %s%s!",completionLabel,CE.name,difficultyFull,recordTime,timeImprovement)
                            SendChatMessage(format("<DXE> %s",recordMsg),channel)
                        end
                        addon:Print(format("%s (%s) defeated in a new fastest time of %s.", CE.name, difficultyFull, recordTime))
                        if pfl.Pane.ScreenshotBestTime and not screenTaken then
                            self:ScheduleTimer("Screen",3)
                        end
                    end
                else
                    addon.Pane.timer:SetTextColor(1, 0, 0)
                end
            end
        end
        
        --[===[@debug@
        debug("TriggerDefeat","key: %s",CE.key)
        --@end-debug@]===]
    end

    function addon:SetDefeat(defeat)
        if not defeat then return end
        if type(defeat) == "number" then
            DEFEAT_NID = defeat
        elseif type(defeat) == "string" then
            DEFEAT_MSG = defeat
        elseif type(defeat) == "table" then
            for k,v in ipairs(defeat) do
                if type(v) == "number" then
                    DEFEAT_TBL[v] = false
                elseif type(v) == "string" then
                    if DEFEAT_MSG == nil then DEFEAT_MSG = {} end
                    DEFEAT_MSG[#DEFEAT_MSG+1] = v
                end
            end
            DEFEAT_NIDS = DEFEAT_TBL
        end

        if DEFEAT_MSG then 
            frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
            frame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
            frame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
            frame:RegisterEvent("CHAT_MSG_MONSTER_PARTY")
            frame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
        end
    end
    
    local WIPE_YELL = nil -- Yell activations for a raid wipe. Source: data.onactivate.wipe.yell
    
    local wipeDummyframe = CreateFrame("Frame")
    wipeDummyframe:SetScript("OnEvent",function(self,event,msg)
        addon:CheckForMessageWipe(event, msg)
    end)
    
    function addon:SetWipe(wipe)
        if not wipe then return end
        
        if type(wipe) == "table" then
            local yell = wipe.yell
            if yell then
                WIPE_YELL = yell
                wipeDummyframe:RegisterEvent("CHAT_MSG_MONSTER_YELL")
                wipeDummyframe:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
                wipeDummyframe:RegisterEvent("CHAT_MSG_MONSTER_SAY")
                wipeDummyframe:RegisterEvent("CHAT_MSG_MONSTER_PARTY")
                wipeDummyframe:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
            end
        end
    end
    
    function addon:CheckForMessageWipe(event, msg)
        if     event == "CHAT_MSG_MONSTER_YELL"
            or event == "CHAT_MSG_MONSTER_EMOTE"
            or event == "CHAT_MSG_MONSTER_SAY" 
            or event == "CHAT_MSG_MONSTER_PARTY"
            or event == "CHAT_MSG_MONSTER_WHISPER" then
            if WIPE_YELL then
                local wipeFlag = false
                if type(WIPE_YELL) == "table" then
                    for _,fragment in ipairs(WIPE_YELL) do
                        if find(msg,fragment) then
                            wipeFlag = true
                            break
                        end
                    end
                else
                    if find(msg,WIPE_YELL) then wipeFlag = true end
                end
                if wipeFlag then
                    if not find(CE.key,"trash$") then
                        if(UnitHealth("player") <= 0) then
                            if not addon.Alerts.pfl.DisableSounds then addon.Alerts:Sound(addon.Media.Sounds:GetFile("WIPE")) end
                        end
                    end
                    if ConfirmWipeTimer then
                        self:CancelTimer(ConfirmWipeTimer,true)
                        ConfirmWipeTimer = nil
                    end
                    self.callbacks:Fire("RaidWipe",CE)
                    self:StopEncounter()
                end
            end
        end
    end
    
    function addon:ResetWipeTriggers()
        wipeDummyframe:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
        wipeDummyframe:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")
        wipeDummyframe:UnregisterEvent("CHAT_MSG_MONSTER_SAY")
        wipeDummyframe:UnregisterEvent("CHAT_MSG_MONSTER_PARTY")
        wipeDummyframe:UnregisterEvent("CHAT_MSG_MONSTER_WHISPER")
    end
end

--- Change the currently-active encounter.
function addon:SetActiveEncounter(key, autoStartTrash)
    --[===[@debug@
    assert(type(key) == "string","String expected in SetActiveEncounter")
    --@end-debug@]===]
    -- Check the new encounter
    if not EDB[key] then return end
    -- Already set to this encounter
    if CE and CE.key == key then
        if autoStartTrash and UnitAffectingCombat("player") then
            self:StartEncounter()
        end
        return
    end

    CE = EDB[key]
    addon.CE = CE

    self:SetTracerStart(false)
    self:SetTracerStop(false)
    self:StopEncounter()

    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")

    self.Pane.SetFolderValue(key)

    self:OpenWindows(false)

    if not find(CE.key,"trash$") then -- trash loadfix Alpha
        self:CloseAllHW()
    end
    self:ResetSortedTracing()
    self:ResetDefeat()

    if CE.onactivate then
        local oa = CE.onactivate
       self:SetTracerStart(oa.tracerstart)
       self:SetTracerStop(oa.tracerstop)

        -- Either could exist but not both
        self:SetSortedTracing(oa.sortedtracing)
        self:SetTracing(oa.tracing or oa.unittracing)
        self:SetPhaseMarkers(oa.phasemarkers)
        self:SetCombat(oa.combatstop,"PLAYER_REGEN_ENABLED","CombatStop")
        self:SetCombat(oa.combatstart,"PLAYER_REGEN_DISABLED","CombatStart")

        self:SetDefeat(oa.defeat)
    end

    self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
    self:RegisterBossEmoteFilter(CE)
    self:RegisterRaidWarningFilter(CE)
    self:RegisterModuleFunctions(CE)
    self:ArrangeThrottling(CE)
    
    if not self:IsModuleTrash(CE.key) then -- trash loadfix Alpha
        addon:UpdatePaneVisibility()
        -- For the empty encounter
        addon:UpdateBestTimer(true)
        self.Pane.timer:SetTextColor(1, 1, 1)
        if not self:IsModuleEvent(CE.key) and (not CE.onactivate or (CE.onactivate and ((CE.onactivate.tracing and #CE.onactivate.tracing > 0) or (CE.onactivate.unittracing and #CE.onactivate.unittracing > 0)))) then self:ShowFirstHW() end -- long story short, if the module specifies that tracing = {} or unittracing = {} and it's not an event than the first HW is shown
        self:LayoutHealthWatchers()
        self:ResetCounters(2)
    end
    
    self.callbacks:Fire("SetActiveEncounter",CE)
    
    -- trash loadfix Alpha (will only start encounter with trash after scan)
    if autoStartTrash and UnitAffectingCombat("player") and self:IsModuleTrash(CE.key) then 
        self:StartEncounter() 
    end
end

function addon:IsWipeDelayed()
    return DelayWipeTimer ~= nil
end

function addon:TriggerDelayedWipe(postDelayFunction)
    self:CancelTimer(DelayWipeTimer,true)
    DelayWipeTimer = nil
    wipeDelayed = true
    if postDelayFunction then postDelayFunction() end
end

local function BossesPartOfCE(bosses)
    for i=1,addon.BOSS_MAX do
        if CE.name == bosses["boss"..i].name then
            return true
        end 
    end

    if CE and CE.triggers then
        if CE.triggers.scan then
            local info = CE.triggers.scan
            if type(info) == "table" then
                for _,id in ipairs(info) do
                    for i=1,addon.BOSS_MAX do
                        if id == bosses["boss"..i].id then
                            return true
                        end 
                    end
                end
            else
                for i=1,addon.BOSS_MAX do
                    if info == bosses["boss"..i].id then
                        return true
                    end
                end
            end
        end
        
        if CE.triggers.keepalive then
            local info = CE.triggers.keepalive
            if type(info) == "table" then
                for _,id in ipairs(info) do
                    for i=1,addon.BOSS_MAX do
                        if id == bosses["boss"..i].id then
                            return true
                        end 
                    end
                end
            else
                for i=1,addon.BOSS_MAX do
                    if info == bosses["boss"..i].id then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function BossesExist(bosses)
    for i=1,addon.BOSS_MAX do
        local guid = bosses["boss"..i].guid
        if guid then return true end
    end
    
    return false
end

local function GetBosses()
    local bosses = {}
    for i=1,addon.BOSS_MAX do 
        local bossIndex = "boss"..i
        local boss = {}
        boss.name = UnitName(bossIndex)
        boss.guid = UnitGUID(bossIndex)
        if boss.guid then boss.id = tonumber((UnitGUID(bossIndex)):sub(7, 10), 16) else boss.id = -1 end
        bosses[bossIndex] = boss;
    end
    
    return bosses
end
function addon:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
    if not addon.db.profile.Enabled then
        return
    end
    addon:UpdateUnitHealthWatchers()
    -- Auto-wipe delay
    if self:IsRunning() then
        if DelayWipeTimer then
            return
        elseif InCinematic() then
            return
        --[[
        else
            if not wipeDelayed and CE.advanced and CE.advanced.delayWipe then
                local wipeDelay = CE.advanced.delayWipe
                if wipeDelay > 0 and wipeDelay < 180 then
                    DelayWipeTimer = self:ScheduleTimer("TriggerDelayedWipe", wipeDelay, function() addon:INSTANCE_ENCOUNTER_ENGAGE_UNIT() end)
                    return
                end
            end
        ]]
        end
    end
    
    
    -- Boss auto-pull prevention
    if PreventPullTimer then
        return
    end
        
    local bosses = GetBosses()
    
    if not BossesExist(bosses) then
        if self:IsRunning() then
            if not wipeDelayed and CE.advanced and CE.advanced.delayWipe then
                local wipeDelay = CE.advanced.delayWipe
                if wipeDelay > 0 and wipeDelay < 180 then
                    DelayWipeTimer = self:ScheduleTimer("TriggerDelayedWipe", wipeDelay, function() addon:INSTANCE_ENCOUNTER_ENGAGE_UNIT() end)
                    return true
                end
            end
            
            if not find(CE.key,"trash$") then
                if(UnitHealth("player") <= 0) then
                    if not addon.Alerts.pfl.DisableSounds then addon.Alerts:Sound(addon.Media.Sounds:GetFile("WIPE")) end
                end
            end
            self.callbacks:Fire("RaidWipe",CE)
            self:StopEncounter()
            if ConfirmWipeTimer then
                self:CancelTimer(ConfirmWipeTimer,true)
                ConfirmWipeTimer = nil
            end
        else
        end
    else
        if BossesPartOfCE(bosses) then
            if not self:IsRunning() then
                self:StartEncounter(true)
            else
                -- Encounter probably already started by CombatStart()
                if not CE.advanced or not CE.advanced.advancedwipedetection then startedOnIEEU = true end
            end
        else
            local function add_data(tbl,info,key)
                if type(info) == "table" then
                    -- Info contains ids
                    for _,id in ipairs(info) do
                        tbl[id] = key
                    end
                else
                    -- Info is the id
                    tbl[info] = key
                end
            end

            local EDBids = {}
            for key, data in addon:IterateEDB() do
                if data.triggers then
                    local scan = data.triggers.scan
                    if scan then
                        add_data(EDBids,scan,key)
                    end
                end
            end
            
            local function GetEncounterKey(bosses)
                -- Check for bosses with known names
                for bossIndex,boss in pairs(bosses) do
                    if boss.name and boss.name ~= "Unknown" then
                        local key = EDBids[boss.id]
                        if key then return key,false end
                    end
                end
                
                -- Check for bosses with "Unknown" names
                for bossIndex,boss in pairs(bosses) do
                    if boss.name and boss.name == "Unknown" then
                        local key = EDBids[boss.id]
                        if key then return key,true end
                    end
                end
                
                return nil
            end
            
            local key,unknown = GetEncounterKey(bosses)
            if key then
                if self:IsModuleEvent(CE.key) then
                    addon:TriggerDefeat()
                end
                if not unknown or not self:IsRunning() then
                    self:SetActiveEncounter(key)
                    self:StopEncounter()
                    self:StartEncounter(true)
                    return true
                end
            end
            
            if self:IsRunning() then
                if not wipeDelayed and CE.advanced and CE.advanced.delayWipe then
                    local wipeDelay = CE.advanced.delayWipe
                    if wipeDelay > 0 and wipeDelay < 180 then
                        DelayWipeTimer = self:ScheduleTimer("TriggerDelayedWipe", wipeDelay, function() addon:INSTANCE_ENCOUNTER_ENGAGE_UNIT() end)
                    end
                else
                    if not find(CE.key,"trash$") then
                        if(UnitHealth("player") <= 0) then
                            if not addon.Alerts.pfl.DisableSounds then addon.Alerts:Sound(addon.Media.Sounds:GetFile("WIPE")) end
                        end
                    end
                    self.callbacks:Fire("RaidWipe",CE)
                    self:StopEncounter()
                end
            end
        end
    end
end

function addon:ShouldStartTimer(data)
    if data.advanced and data.advanced.notimer then
        return not data.advanced.notimer
    else
        return not addon:IsModuleTrash(data.key)
    end
end

-- Start the current encounter
function addon:StartEncounter(IEEUstart, ...)
    local lastDefeatDelta = GetTime() - (lastDefeatTime or 0)
    if lastDefeatDelta < 3 then
        if not CE.advanced or not CE.advanced.allowinstantrepull then
            return
        end
    end
    
    if CE.advanced and CE.advanced.advancedwipedetection then
        startedOnIEEU = false
    else
        startedOnIEEU = IEEUstart
    end
    if self:IsRunning() then return end
    if addon:GetActiveEncounter() == "default" then return end
    
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    if not self:IsModuleTrash(CE.key) then addon:ResetCounters(1) end
    if pfl.SpecialTimers.PullTimerCancelOnPull then
        addon:CancelPull()
        addon:CancelBreak()
    end

    self.callbacks:Fire("StartEncounter",CE)
    self:StartTimer(addon:ShouldStartTimer(CE))
    addon:ArrangeThrottling(CE, true)
    if not self:IsModuleTrash(CE.key) then
        addon:UpdateBestTimer(true)
        self:StartSortedTracing()
        self:UpdatePaneVisibility()
        self:PauseScanning()
        self:SetWipe(CE.onactivate.wipe)
        self:OpenWindows(true)
    end
end

function addon:ResetTimer()
    self:StartTimer()
end

-- Stop the current encounter
function addon:StopEncounter()
    if not self:IsRunning() then return end
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.callbacks:Fire("StopEncounter")
    self:ClearSortedTracing()
    self:StopSortedTracing()
    self:CloseTempHW()
    self:ResetHealthWatchers()
    self:ResetCounters(4)
    self:StopTimer()
    self:ResetRadar()
    if pfl.Proximity.HideOnEncounterSelection then self:CloseProximity() end
    
    if not self:IsModuleTrash(CE.key) then
        self:UpdatePaneVisibility()
    end
    
    self:ResumeScanning()
    self:ResetDefeatTbl()
    self:ResetWipeTriggers()
    
    -- Allow the next delayed wipe
    wipeDelayed = false
end

do
    local function iter(t,i)
        local k,v = next(t,i)
        if k == "default" then return next(t,k)
        else return k,v end
    end

    function addon:IterateEDB()
        return iter,EDB
    end
end


-- Mechanic to prevent garbage events and combat pull CE after it's been already defeated.

function addon:SetPreventPull(timer)
    if PreventPullTimer then
        self:CancelTimer(PreventPullTimer,true)
        PreventPullTimer = nil
    end
    if timer and timer > 0 then
        PreventPullTimer = self:ScheduleTimer("SetPreventPull", timer, false)
    end
end

---------------------------------------------
-- ROSTER
---------------------------------------------
local Roster = {}
addon.Roster = Roster

local rID,pID = {},{}
for i=1,40 do
    rID[i] = "raid"..i
    if i <= 4 then
        pID[i] = "party"..i
    end
end

local targetof = setmetatable({},{
    __index = function(t,k)
        if type(k) ~= "string" then return end
        t[k] = k.."target"
        return t[k]
    end
})
addon.targetof = targetof

local refreshFuncs = {
    name_to_unit = function(t,id)
        t[UnitName(id)] = id
    end,
    guid_to_unit = function(t,id)
        local guid = id == "player" and addon.PGUID or UnitGUID(id)
        t[guid] = id
    end,
    unit_to_unittarget = function(t,id)
        t[id] = targetof[id]
    end,
    name_to_class = function(t,id)
        t[UnitName(id)] = select(2,UnitClass(id))
    end,
}

for k in pairs(refreshFuncs) do
    Roster[k] = {}
end

local numOnline = 0
local numMembers = 0
local prevGroupType = "NONE"
local RosterHandle
addon.GroupType = "NONE"
function addon:RAID_ROSTER_UPDATE()
    --[===[@debug@
    debug("RAID_ROSTER_UPDATE","Invoked")
    --@end-debug@]===]
    addon:UpdatePaneButtonPermission()
    
    local tmpOnline,tmpMembers = 0,GetNumRaidMembers()
    local _, instanceType = GetInstanceInfo()
    
    if tmpMembers > 0 then
        if instanceType == "pvp" then
            addon.GroupType = "BATTLEGROUND"
        else
            addon.GroupType = "RAID"
        end
    else
        tmpMembers = GetNumPartyMembers()
        addon.GroupType = tmpMembers > 0 and "PARTY" or "NONE"
    end

    -- Switches to default if we leave a group
    if prevGroupType ~= "NONE" and addon.GroupType == "NONE" then
        if addon:IsModuleBattleground() then addon:StopBattleground(true) end
        self:SetActiveEncounter("default")
    end
    prevGroupType = addon.GroupType

    if not RosterHandle and tmpMembers > 0 then
        -- Refresh roster tables every half minute to detect offline players
        RosterHandle = self:ScheduleRepeatingTimer("RAID_ROSTER_UPDATE",30)
    elseif tmpMembers == 0 then
        self:CancelTimer(RosterHandle,true)
        RosterHandle = nil
    end

    for k,t in pairs(Roster) do
        wipe(t)
        refreshFuncs[k](t,"player")
    end

    if addon.GroupType == "RAID" then
        for i=1,tmpMembers do
            local name, rank, _, _, _, _, _, online = GetRaidRosterInfo(i)
            if online then
                local unit = rID[i]
                tmpOnline = tmpOnline + 1
                for k,t in pairs(Roster) do
                    refreshFuncs[k](t,unit)
                end
            end
        end
    elseif addon.GroupType == "PARTY" then
        for i=1,tmpMembers do
            local name,online = UnitName(pID[i]),UnitIsConnected(pID[i])
            if online then
                local unit = pID[i]
                --[===[@debug@
                debug("PARTY_MEMBERS_CHANGED","name: %s unit: %s guid: %s",name,unit,UnitGUID(unit))
                --@end-debug@]===]
                tmpOnline = tmpOnline + 1
                for k,t in pairs(Roster) do
                    refreshFuncs[k](t,unit)
                end
            end
        end
    end

    --- Number of member differences
    if tmpMembers ~= numMembers then
        if not CE or not find(CE.key,"trash$") then
            self:UpdatePaneVisibility()
        end
        self:RefreshVersionList()
    end

    numMembers = tmpMembers

    if tmpOnline < numOnline then
        self:CleanVersions()
    end

    numOnline = tmpOnline
    
    addon:UpdateThrottlingScores()
end

function addon:IsPromoted()
    return IsRaidLeader() or IsRaidOfficer()
end

function addon:IsRaid() 
    return GetNumRaidMembers() > 0
end

function addon:IsParty()
    return GetNumRaidMembers() == 0 and GetNumPartyMembers() >= 1
end

function addon:IsGroup()
    return addon:IsParty() or addon:IsRaid()
end

function addon:VehicleNames()
    local names = {}
    for name in pairs(Roster.name_to_unit) do
        if UnitInVehicle(name) then
            names[#names+1] = name
        end
    end
    return names
end

---------------------------------------------
-- TRIGGERING
---------------------------------------------
local TRGS = {}
local triggerCategories = {
  ["scan"] = {}, -- NPC ids activations. Source: data.triggers.scan
  ["scan_only"] = {}, -- NPC ids activations. Source: data.triggers.scan_only
  ["yell"] = {        event = "CHAT_MSG_MONSTER_YELL",     func = "ProcessMsgInTriggers"}, -- Monster yell activations. Source: data.triggers.yell
  ["say"] = {         event = "CHAT_MSG_MONSTER_SAY",      func = "ProcessMsgInTriggers"}, -- Monster say activations. Source: data.triggers.say
  ["party"] = {       event = "CHAT_MSG_MONSTER_PARTY",    func = "ProcessMsgInTriggers"}, -- Monster party activations. Source: data.triggers.party
  ["whisper"] = {     event = "CHAT_MSG_MONSTER_WHISPER",  func = "ProcessMsgInTriggers"}, -- Monster whisper activations. Source: data.triggers.whisper
  ["emote"] = {       event = "CHAT_MSG_MONSTER_EMOTE",    func = "ProcessMsgInTriggers"}, -- Monster emote activations. Source: data.triggers.emote
  ["boss_whisper"] = {event = "CHAT_MSG_RAID_BOSS_WHISPER",func = "ProcessMsgInTriggers"}, -- Boss whisper activations. Source: data.triggers.boss_whisper
  ["boss_emote"] = {  event = "CHAT_MSG_RAID_BOSS_EMOTE",  func = "ProcessMsgInTriggers"}, -- Boss emote activations. Source: data.triggers.boss_emote
  ["bg_neutral"] = {  event = "CHAT_MSG_BG_SYSTEM_NEUTRAL",func = "ProcessMsgInTriggers"}, -- Battleground neutral activations. Source: data.triggers.bg_neutral
  ["UNIT_SPELLCAST_SUCCEEDED"] = {event = "UNIT_SPELLCAST_SUCCEEDED", func = "ProcessUnitEvent"}, -- UNIT_SPELLCAST_SUCCEEDED event
  ["UNIT_SPELLCAST_FAILED"] = {event = "UNIT_SPELLCAST_FAILED", func = "ProcessUnitEvent"}, -- UNIT_SPELLCAST_FAILED event
  ["UNIT_SPELLCAST_STOP"] = {event = "UNIT_SPELLCAST_STOP", func = "ProcessUnitEvent"}, -- UNIT_SPELLCAST_STOP event
  ["UNIT_SPELLCAST_INTERRUPTED"] = {event = "UNIT_SPELLCAST_INTERRUPTED", func = "ProcessUnitEvent"}, -- UNIT_SPELLCAST_INTERRUPTED event
}

do
    local function add_data(tbl,key,data)
        if type(key) == "table" then
            -- key contains ids
            for _,id in ipairs(key) do
                if type(id) == "table" and type(id[1]) == "number" and id.type and type(id.type) == "string" then
                    tbl[id[1]] = {
                        key = data.key,
                        type = id.type
                    }
                else
                    tbl[id] = data
                end
            end
            -- add additional data
            if type(key[1]) == "string" then 
                for k,v in pairs(key) do
                    if type(k) == "string" then
                        tbl[key[1]][k] = v
                    end
                end
            end
            
        else
            -- key is the id
            tbl[key] = data
        end
    end

    local function BuildTriggerLists()
        local zone = GetRealZoneText()
        local instanceName, instanceType = GetInstanceInfo()
        if instanceType == "pvp" then
            zone = instanceName
        end
        
        local triggerFlags = {}
        for k,_ in pairs(triggerCategories) do
            triggerFlags[k] = false
        end
            
        TRGS = {}
        for key, data in addon:IterateEDB() do
            if data.zone == zone then
                -- Handling pull chat triggers
                if data.triggers then
                    for triggerKey,triggerInfo in pairs(triggerCategories) do
                        local triggerSnippets = data.triggers[triggerKey]
                        if triggerSnippets then
                                if not TRGS[triggerKey] then
                                    TRGS[triggerKey] = {}
                                end
                                local trigger_data = {
                                    key = key,
                                    type = "pull_trigger",
                                }
                                add_data(TRGS[triggerKey], triggerSnippets, trigger_data)
                                triggerFlags[triggerKey] = true
                            end
                    end
                end

                -- Handling pre-pull event chat triggers
                if data.onpullevent then
                    for triggerKey,triggerInfo in pairs(triggerCategories) do
                        for i,eventData in ipairs(data.onpullevent) do
                            local triggerSnippets = eventData.triggers[triggerKey]
                            if triggerSnippets then
                                if not TRGS[triggerKey] then
                                    TRGS[triggerKey] = {}
                                end
                                local trigger_data = {
                                    key = key,
                                    type = "pre_pull_event",
                                    invoke = eventData.invoke
                                }
                                add_data(TRGS[triggerKey], triggerSnippets, trigger_data)
                                triggerFlags[triggerKey] = true
                            end
                        end
                    end
                end
            end
        end
        return triggerFlags
    end

    local ScanHandle
    function addon:PauseScanning()
        if ScanHandle then self:CancelTimer(ScanHandle); ScanHandle = nil end
    end

    function addon:ResumeScanning()
        if not ScanHandle then ScanHandle = self:ScheduleRepeatingTimer("ScanUpdate",5) end
    end

    function addon:UpdateTriggers()
        -- Clear trigger tables
        for triggerKey,triggerInfo in pairs(triggerCategories) do
            if type(TRGS[triggerKey]) == "table" then
                wipe(TRGS[triggerKey])
            elseif TRGS[triggerKey] == nil then
                TRGS[triggerKey] = {}
            end
            if triggerInfo.event then
                self:UnregisterEvent(triggerInfo.event,"ProcessTriggerEvent")
            end
        end
        self:CancelTimer(ScanHandle,true)
        ScanHandle = nil
        -- Build trigger lists
        local triggerFlags = BuildTriggerLists()
        if triggerFlags.scan then
            ScanHandle = self:ScheduleRepeatingTimer("ScanUpdate",5)
        end
        local zoneFlag = false
        for triggerKey,triggerInfo in pairs(triggerCategories) do
            zoneFlag = zoneFlag or triggerFlags[triggerKey]
            if triggerFlags[triggerKey] and triggerInfo.event then
                self:RegisterEvent(triggerInfo.event,"ProcessTriggerEvent")
            end
        end
        self.TriggerZone = zoneFlag
    end
    addon:ThrottleFunc("UpdateTriggers",1,true)
end
local TRIGGER_FUNCTIONS = {}
TRIGGER_FUNCTIONS.ProcessMsgInTriggers = function(source, TRGS_ARRAY, ...)
    local msg = select(1, ...)
    if not pfl.Enabled then return end
    msg = msg:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","") -- removing all coloring
    msg = msg:gsub("|H(%a+):(%d+)|h",""):gsub("|h","") -- removing all links
    for fragment,triggerData in pairs(TRGS_ARRAY) do
        if find(msg,fragment) then
            if triggerData.type == "pull_trigger" then
                if addon:IsModuleBattleground(triggerData.key) then
                    addon:SetActiveEncounter(triggerData.key)
                    addon:StartBattleground()
                elseif not addon:IsModuleTrash(triggerData.key) then
                    addon:SetActiveEncounter(triggerData.key)
                    if not addon:IsRunning() then
                        addon:StopEncounter()
                        addon:StartEncounter()
                    end
                end
            elseif triggerData.type == "pre_pull_event" then
                addon:SetActiveEncounter(triggerData.key)
                if triggerData.invoke then
                    addon.Invoker:InvokeCommands(triggerData.invoke)
                end
            end
        end
    end
end
TRIGGER_FUNCTIONS.ProcessUnitEvent = function(event, TRGS_ARRAY, ...)
    local unit,spellname,_,_,spellid = select(1,...)
    if not pfl.Enabled then return end
    for _,triggerData in pairs(TRGS_ARRAY) do
        if triggerData.spellid and triggerData.spellid ~= spellid then return end
        if triggerData.spellname and triggerData.spellname ~= spellname then return end
        if triggerData.unit and not find(unit,triggerData.unit) then return end
        if addon:IsModuleTrash(triggerData.key) then return end
        if triggerData.type == "pull_trigger" then
            addon:SetActiveEncounter(triggerData.key)
            if not addon:IsRunning() then
                addon:StopEncounter()
                addon:StartEncounter()
            end
        elseif triggerData.type == "pre_pull_event" then
            addon:SetActiveEncounter(triggerData.key)
            if triggerData.invoke then
                addon.Invoker:InvokeCommands(triggerData.invoke)
            end
        end
    end
end
function addon:ProcessTriggerEvent(event, ...)
    for triggerKey,triggerInfo in pairs(triggerCategories) do
        if triggerInfo.event and triggerInfo.event == event then
            if triggerInfo.func then
                TRIGGER_FUNCTIONS[triggerInfo.func](event, TRGS[triggerKey], ...)
            end
        end
    end
end


function addon:Scan(encounterStart)
    local trashKeys = {}
    local trashFound = false
    if not TRGS["scan"] then return end
    
    for _,unit in pairs(Roster.unit_to_unittarget) do
        if UnitExists(unit) then
            local guid = UnitGUID(unit)
            local npcid = NID[guid]      
            if npcid then
                local triggerData = TRGS["scan"][npcid]
                if triggerData and ((triggerData.type == "select_only" and not encounterStart) or triggerData.type == "pull_trigger") then
                    local scan_key = TRGS["scan"][npcid].key
                    if scan_key and not UnitIsDead(unit) then
                        if not encounterStart or (encounterStart and UnitAffectingCombat(unit)) then
                            if not self:IsModuleTrash(scan_key) then
                                return scan_key
                            else
                                trashFound = true
                                if not trashKeys[scan_key] then
                                    trashKeys[scan_key] = 1
                                else
                                    trashKeys[scan_key] = trashKeys[scan_key] + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if trashFound then
        local highKey
        local highCount = 0
        for k,v in pairs(trashKeys) do
            if v > highCount then
                highKey = k
                highCount = v
            end
        end
        if highKey then
            return highKey
        end
    end
end

function addon:IsModuleTrash(key)
    return find(key,"trash$")
end

function addon:IsModuleEvent(key)
    return find(key,"event$")
end

function addon:RaidWipe()
    if not self:IsRunning() then return end
    ConfirmWipeTimer = nil
    if not find(CE.key,"trash$") then
        if(UnitHealth("player") <= 0) then
            if not addon.Alerts.pfl.DisableSounds then addon.Alerts:Sound(addon.Media.Sounds:GetFile("WIPE")) end
        end
    end
    self.callbacks:Fire("RaidWipe",CE)
    self:StopEncounter()
end

local ConfirmWipeTimer
function addon:ConfirmWipe(scheduleCheck)
    if not self:IsRunning() then return end
    if ConfirmWipeTimer then
        self:CancelTimer(ConfirmWipeTimer,true)
        ConfirmWipeTimer = nil
    end
    local wipeKey,overrideSchedule = self:ScanForWipe()
    if wipeKey then
        self:ScheduleTimer("RaidWipe",1)
    else
        if scheduleCheck and not overrideSchedule then
            ConfirmWipeTimer = self:ScheduleTimer("ConfirmWipe",5,true)
        end
    end
end

function addon:ScanForWipe()
    if startedOnIEEU then
        return false,true
    elseif CE.advanced and CE.advanced.disableAutoWipe then
        return false,true
    else
        local uId = ((GetNumRaidMembers() == 0) and "party") or "raid"
        local combatFlag = false
        for i = 0, math.max(GetNumRaidMembers(), GetNumPartyMembers()) do
            local id = (i == 0 and "player") or uId..i
            if not UnitIsDeadOrGhost(id) and UnitAffectingCombat(id) then
                combatFlag = true
            end
        end
        if not combatFlag then
            return true
        else
            if CE and CE.triggers and CE.triggers.scan then
                local info = CE.triggers.scan
                local unitPartOfCE = nil
                for i = 0, math.max(GetNumRaidMembers(), GetNumPartyMembers()) do
                    local unit = (i == 0 and "playertarget") or uId..i.."target"
                    if UnitExists(unit) then
                        local unitID = tonumber((UnitGUID(unit)):sub(7, 10), 16)
                        if type(info) == "table" then
                            for _,id in ipairs(info) do
                                if unitID == id then
                                    unitPartOfCE = unit
                                    break
                                end
                            end
                        elseif unitID == info then
                            unitPartOfCE = unit
                        end
                        if unitPartOfCE then
                            if UnitAffectingCombat(unitPartOfCE) then
                                return false,false
                            else
                                return true
                            end
                        end
                    end
                end
                return false,false
            else
                return false,false
            end
        end
    end
end

function addon:ScanUpdate()
    local key = self:Scan()
    if key and addon:IsEnabled() then self:SetActiveEncounter(key, self:IsModuleTrash(key)) end
end

---------------------------------------------
-- PLAYER CONSTANTS
---------------------------------------------

function addon:SetPGUID(n)
    if n == 0 then return end
    self.PGUID = UnitGUID("player")
    if not self.PGUID then self:ScheduleTimer("SetPGUID",1,n-1) end
end

function addon:SetPlayerConstants()
    self.PGUID = UnitGUID("player")
    -- Just to be safe
    if not self.PGUID then self:ScheduleTimer("SetPGUID",1,5) end
    self.PNAME = UnitName("player")
end

---------------------------------------------
-- GENERIC EVENTS
---------------------------------------------

function addon:PLAYER_ENTERING_WORLD()
    addon:UpdateBestTimer(false)
    self:UpdatePaneVisibility(true)
    self:UpdateTriggers()
    addon:UpdateRadarMap()
    self:StopEncounter()
    addon.Countdown:UpdateCountdown()
end

---------------------------------------------
-- WARNING BLOCKS
-- Credits: BigWigs
---------------------------------------------

local forceBlockDisable
addon.forceBlockDisable = forceBlockDisable

function addon:AddMessageFilters()
    local OTHER_BOSS_MOD_PTN = "%*%*%*"
    local OTHER_BOSS_MOD_PTN2 = "DBM"
    local OTHER_BOSS_MOD_PTN3 = "<BW>"

    local RaidWarningFrame_OnEvent = RaidWarningFrame:GetScript("OnEvent")
    RaidWarningFrame:SetScript("OnEvent", function(self,event,msg,...)
        if not forceBlockDisable and pfl.Misc.BlockRaidWarningFrame and
            type(msg) == "string" and (find(msg,OTHER_BOSS_MOD_PTN) or find(msg,OTHER_BOSS_MOD_PTN2) or find(msg,OTHER_BOSS_MOD_PTN3))then
            -- Do nothing
        else
            return RaidWarningFrame_OnEvent(self,event,msg,...)
        end
    end)

    local RaidBossEmoteFrame_OnEvent = RaidBossEmoteFrame:GetScript("OnEvent")
    RaidBossEmoteFrame:SetScript("OnEvent", function(self,event,msg,name,...)
        if not forceBlockDisable and pfl.Misc.BlockBossEmoteFrame
            and type(name) == "string" and addon.TriggerZone then
            -- Do nothing
        else
            return RaidBossEmoteFrame_OnEvent(self,event,msg,name,...)
        end
    end)

    local function OTHER_BOSS_MOD_FILTER(self,event,msg)
        if not forceBlockDisable and pfl.Misc.BlockRaidWarningMessages
            and type(msg) == "string" and (find(msg,OTHER_BOSS_MOD_PTN) or find(msg,OTHER_BOSS_MOD_PTN2) or find(msg,OTHER_BOSS_MOD_PTN3)) then
            return true
        end
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", OTHER_BOSS_MOD_FILTER)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", OTHER_BOSS_MOD_FILTER)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", OTHER_BOSS_MOD_FILTER)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", OTHER_BOSS_MOD_FILTER)

    local function RAID_BOSS_FILTER(self,event,msg,name)
        if not forceBlockDisable and pfl.Misc.BlockBossEmoteMessages
            and type(name) == "string" and addon.TriggerZone then
            return true
        end
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_EMOTE",RAID_BOSS_FILTER)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_BOSS_WHISPER",RAID_BOSS_FILTER)

    self.AddMessageFilters = nil
end

---------------------------------------------
-- HIDING BLIZZARD BOSS FRAMES
---------------------------------------------

function addon:SetupBlizzardBossFrames()
    if pfl.Misc.HideBlizzardBossFrames then
        for i=1,MAX_BOSS_FRAMES do
            local frame = _G["Boss"..i.."TargetFrame"]
            frame:UnregisterAllEvents()
            frame:Hide()
        end
    end
end

---------------------------------------------
-- CHECK FOR UPDATES
---------------------------------------------
function addon:CheckForUpdates()
    self:SendWhisperComm(addon.developer,"CheckForUpdates",UnitGUID("player"),tostring(addon.version))
end


function addon:DisplayNewVersion(newVersion)
    local newVersionNumber = addon:ParseVersion(newVersion)
    local lastUpdateNumber = addon:ParseVersion(gbl.lastUpdateShown)
    
    if self:IsRunning() ~= true then
        if lastUpdateNumber < newVersionNumber then
            local msg = format("|cff99ff33Deus Vox Encounters|r\n\n A new version |cffffec00%s|r is now available.\n\nVisit |cffffec00%s|r to download\nthe most recent version.\n\nYou may copy the website link\nfrom the box below:",newVersion,addon.website)
            StaticPopupDialogs["DXE_UPDATE"] = {
                text = "%s",
                button1 = "I understand",
                OnAccept = function()
                    gbl.lastUpdateShown = newVersion
                    return
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                hasEditBox = 1,
                editBoxWidth = 400,
                OnShow = function(frame)
                    local box = _G[frame:GetName().."EditBox"]
                    if box then
                        box:SetText(addon.website)
                        box:SetFocus()
                        box:HighlightText(0)
                    end
                end,
                EditBoxOnEscapePressed = function(frame) 
                    gbl.lastUpdateShown = newVersion
                    frame:GetParent():Hide()
                end,
            }
            StaticPopup_Show("DXE_UPDATE",msg)
        end
    end
end

--[[
---------------------------------------------
-- MotD
---------------------------------------------

function addon:DisplayMOTD()
    local really = false
    if not really then return end

    local lastv = gbl.motd_read_v
    local motd_text = "This is the release version for Patch 4.3. All Dragon Soul encounters are included. Some timers may be incorrect due to changes from ptr to live.\n\n If you forcefully load the Dragon Soul encounter files before 4.3 is live, expect to see some errors."
    local motd = format("|cff99ff33DXE Information|r\n Welcome to DXE v%s.\n\n %s \n\n This message will only display once.",addon.version,motd_text)
    if not lastv or lastv < addon.version then
        StaticPopupDialogs["DXE_MOTD"] = {
        text = "%s",
        button1 = "ok",
        OnAccept = function()
            gbl.motd_read_v = addon.version
            return
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        }
        StaticPopup_Show("DXE_MOTD",motd)
    end
end
]]

---------------------------------------------
-- MAIN
---------------------------------------------


-- Replace default Print
function addon:Print(s)
    print(format("|cff99ff33DXE|r: %s",s)) -- 0.6, 1, 0.2
end

do
    local funcs = {}
    function addon:AddToRefreshProfile(func)
        --[===[@debug@
        assert(type(func) == "function")
        --@end-debug@]===]
        funcs[#funcs+1] = func
    end

    function addon:RefreshProfilePointers()
        for k,func in ipairs(funcs) do func(db) end
    end

    function addon:RefreshProfile()
        pfl = db.profile
        -- Has to go before pointers are refreshed
        self:LoadAllScales()
        self:LoadAllDimensions()

        self:RefreshProfilePointers()

        self:LoadAllPositions()
        self.Pane:SetScale(pfl.Pane.Scale)
        self:LayoutHealthWatchers()
        self:LayoutCounters()
        self:SkinPane()
        self:UpdatePaneVisibility()
        self:UpdateWindowSettings()

        self[pfl.Enabled and "Enable" or "Disable"](self)
    end
end

-- Initialization
function addon:OnInitialize()
    Initialized = true

    -- Database
    self.db = LibStub("AceDB-3.0"):New("DXEDB",self.defaults)
    if LDS then LDS:EnhanceDatabase(self.db,"DXE") end
    db = self.db
    gbl,pfl = db.global,db.profile

    self:RefreshProfilePointers()

    -- Options
    db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
    db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
    db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
    --[===[@debug@
    debug = self:CreateDebugger("Core",gbl,debugDefaults)
    --@end-debug@]===]

    -- Received database
    RDB = self.db:RegisterNamespace("RDB", {global = {}}).global
    self.RDB = RDB

    -- Pane
    self:CreatePane()
    self:SkinPane()
    self:UpdatePaneButtons()

    self:SetupSlashCommands()

    -- The default encounter
    self:RegisterEncounter({key = "default", name = L["Default"], title = L["Default"]})
    self:SetActiveEncounter("default")
    addon.defaults.global.lastUpdateShown = addon.version
  
    -- Register DBM prefix and handle its addon comunication
    RegisterAddonMessagePrefix("D4")
    RegisterAddonMessagePrefix("BigWigs")
    self:RegisterEvent("CHAT_MSG_ADDON","HandleAddonMsg")
    self:RegisterEvent("ROLE_POLL_BEGIN")
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    --[===[@debug@
    -- Register addon/received encounter data
    for key,data in pairs(RegisterQueue) do
        if RDB[key] and RDB[key].version > data.version then
            self:RegisterEncounter(RDB[key])
        else
            self:RegisterEncounter(data)
            RDB[key] = nil
        end

        RegisterQueue[key] = nil
    end
    --@end-debug@]===]

    -- The rest that don't exist
    for key,data in pairs(RDB) do
        -- nil out old RDB data that uses data.name as the key
        if key:find("[A-Z]") then
            RDB[key] = nil
        elseif not EDB[key] then
            self:RegisterEncounter(data)
        end
    end

    RegisterQueue = nil

    self:AddMessageFilters()
    self:FixPopupDialogs()
    self:SetupBlizzardBossFrames()
    
    self:SetEnabledState(pfl.Enabled)
    self:Print(L["Loaded - Type |cffffff00/dxe|r to toggle Options or |cffffff00/dxe help|r for slash commands."])
    self.OnInitialize = nil
end

local AddonMsgHandlers = {}

local DBM_TIMERS = {
    Pull = {
        msgfilter = "Pull in",
        settingsVar = "PullTimerEnabled",
        timerKey = "DBMpull",
        cancelMsgFormat = "%s has canceled the pull timer.",
        timerFunc = "PullTimer",
    },
    Break = {
        msgfilter = "Break",
        settingsVar = "BreakTimerEnabled",
        timerKey = "DBMbreak",
        cancelMsgFormat = "%s has canceled the break timer.",
        timerFunc = "BreakTimer",
    }
}

AddonMsgHandlers["U"] = function(sender, channel, prefix, time, msg)
    time = tonumber(time)
    if not time then return end
    
    for _,preset in pairs(DBM_TIMERS) do
        if find(msg, preset.msgfilter) then
            if (GetNumRaidMembers() > 0 and addon:GetRaidRank(sender)>0) or GetNumRaidMembers() == 0 then
                if not pfl.SpecialTimers[preset.settingsVar] then return end
                if time <= 0.1 and addon.Alerts:GetTimeleft(preset.timerKey) ~= -1 then
                    addon:Print(format(preset.cancelMsgFormat, CN[sender]))
                end
                addon[preset.timerFunc](addon,time)
            end
        end
    end
end

AddonMsgHandlers["H"] = function(sender, channel, prefix, msg) -- DBM asks for our DBM version
    -- we happily reply
    if msg ~= "dxe" then -- unless it's DXE who asks
        addon:SendDBMComm(format("%s\t%d\t%s\t%s%s\t%s","V",tonumber(addon:ParseVersion(addon.version)),"0","|cffffffffDXE: |r",addon.versionfull, GetLocale()), channel)
    end
end

AddonMsgHandlers["V"] = function(sender, channel, prefix, revision, version, displayVersion, locale) -- DBM gives us their version
    addon:RegisterAddonVersion("addon", sender, displayVersion, revision, "|cffeeeeeeDBM|r")
end

AddonMsgHandlers["OOD"] = function(sender, channel, prefix, version)
    addon:RegisterAddonVersion("addon", sender, format("rev. %s",version), version, "|cffff8000BigWigs|r")
end

function addon:HandleAddonMsg(evt, addonPrefix, msg, channel, sender, ...)
    
    if not self:IsRunning() then 
        if find(msg,"DXEusers") then
            local _,name = match(msg,"(DXEusers) (.+)")
            if not name then
                addon:SendDBMComm("DXEusers "..UnitName("player"),channel)
            end
        end
    else
        return -- ignore msg handling during the pull (for now)
    end
    
    if addonPrefix == "D4" then
        local prefix = strsplit("\t", msg)
        local handler = AddonMsgHandlers[prefix]
        if handler then handler(sender, channel, strsplit("\t", msg)) end
    elseif addonPrefix == "BigWigs" then
        local prefix = strsplit(":", msg)
        local handler = AddonMsgHandlers[prefix]
    if handler then handler(sender, channel, strsplit(":", msg)) end
    end
    
    
end

function addon:SendDBMComm(prefix,msg,channel)
    msg = msg or ""
    if not channel then
        channel = GetNumRaidMembers() == 0 and "PARTY" or "RAID"
    end
    
    SendAddonMessage("D4",("%s\t%s"):format(prefix,msg),channel) 
end

function addon:SendBigWigsComm(prefix,msg,channel)
    msg = msg or ""
    if not channel then
        channel = GetNumRaidMembers() == 0 and "PARTY" or "RAID"
    end
    SendAddonMessage("BigWigs",("%s:%s"):format(prefix,msg),channel) 
end

function addon:PullTimer(pullTime)
    addon.Alerts:QuashByPattern(DBM_TIMERS.Pull.timerKey)
    addon.Alerts:Dropdown(DBM_TIMERS.Pull.timerKey, "Pull in", pullTime, 10, nil, pfl.SpecialTimers.PullColor1, pfl.SpecialTimers.PullColor2, nil, pfl.SpecialTimers.PullIcon and addon.ST[52795] or nil, pfl.SpecialTimers.PullAudioCD and addon.Countdown.db.profile.CountdownVoice or false)
    if pullTime > 0.1 then
        if addon.Countdown.db.profile.Enabled then addon.Countdown:StartTimer(pullTime) end
    else
        addon:CancelPull()
    end
end

function addon:BreakTimer(breakTime)
    addon.Alerts:QuashByPattern(DBM_TIMERS.Break.timerKey)
    addon.Alerts:Dropdown(DBM_TIMERS.Break.timerKey, "Break time!", breakTime, 10, nil, pfl.SpecialTimers.BreakColor1, pfl.SpecialTimers.BreakColor2, nil, pfl.SpecialTimers.BreakIcon and addon.ST[97183] or nil, false)  
end

function addon:OnEnable()
    -- Patch to refresh Pane texture
    self:NotifyAllMedia()

    forceBlockDisable = false
    self:SetPlayerConstants()
    self:UpdateTriggers()
    addon:UpdateLock()
    self:LayoutHealthWatchers()
    self:LayoutCounters()
    
    -- Events
    self:RegisterEvent("RAID_ROSTER_UPDATE")
    self:RegisterEvent("PARTY_MEMBERS_CHANGED","RAID_ROSTER_UPDATE")
    self:RAID_ROSTER_UPDATE()
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA","UpdateTriggers")
    self:RegisterEvent("ZONE_CHANGED","UpdateTriggers")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    self:SetActiveEncounter("default")
    self:EnableAllModules()
    self:RegisterComm("DXE")
    self:UpdatePaneVisibility()
    self:BroadcastAllVersions()
    self:ScheduleTimer("CheckForUpdates",5)
end

function addon:OnDisable()
    forceBlockDisable = true
    self:UpdateLockedFrames("Hide")
    self:StopEncounter()
    self:SetActiveEncounter("default")
    self.Pane:Hide()
    self:DisableAllModules()
    RosterHandle = nil
end

function addon:RefreshDefaults()
    self.db:RegisterDefaults(defaults)
    addon.Alerts:RefreshBarColors()
end

---------------------------------------------
-- SCALES
---------------------------------------------

do
    local frameNames = {}

    function addon:SaveScale(f)
        pfl.Scales[f:GetName()] = f:GetScale()
    end

    -- Used after the profile is changed
    function addon:LoadAllScales()
        for name in pairs(frameNames) do
            self:LoadScale(name)
        end
    end

    function addon:LoadScale(name)
        local f = _G[name]
        if not f then return end
        frameNames[name] = true
    f:SetScale(pfl.Scales[name] or 1)
    end

    function addon:RegisterDefaultScale(f)
        defaults.profile.Scales[f:GetName()] = f:GetScale()
        self:RefreshDefaults()
    end
end

---------------------------------------------
-- DIMENSIONS
---------------------------------------------

do
    local frameNames = {}

    function addon:SaveDimensions(f)
        local name = f:GetName()
        local dims = pfl.Dimensions[name]
        dims.width = f:GetWidth()
        dims.height = f:GetHeight()
    end

    -- Used after the profile is changed
    function addon:LoadAllDimensions()
        for name in pairs(frameNames) do
            self:LoadDimensions(name)
        end
    end

    function addon:LoadDimensions(name)
        local f = _G[name]
        if not f then return end
        frameNames[name] = true
        local dims = pfl.Dimensions[name]
        if not dims then
            pfl.Dimensions[name] = {
                width = f:GetWidth(),
                height = f:GetHeight(),
            }
        else
            f:SetWidth(dims.width)
            f:SetHeight(dims.height)
        end
    end

    function addon:RegisterDefaultDimensions(f)
        local dims = {}
        dims.width = f:GetWidth()
        dims.height = f:GetHeight()
        defaults.profile.Dimensions[f:GetName()] = dims
        self:RefreshDefaults()
    end
end

---------------------------------------------
-- POSITIONING
---------------------------------------------

do
    local frameNames = {}

    function addon:SavePosition(f)
        local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
        local name = f:GetName()
        local pos = pfl.Positions[name]
        pos.point = point
        pos.relativeTo = relativeTo and relativeTo:GetName()
        pos.relativePoint = relativePoint
        pos.xOfs = xOfs
        pos.yOfs = yOfs
        f:SetUserPlaced(false)
    end

    -- Used after the profile is changed
    function addon:LoadAllPositions()
        for name in pairs(frameNames) do
            self:LoadPosition(name)
        end
    end

    function addon:LoadPosition(name)
        local f = _G[name]
        if not f then return end
        frameNames[name] = true
        f:ClearAllPoints()
        local pos = pfl.Positions[name]
        if not pos then
            f:SetPoint("CENTER",UIParent,"CENTER",0,0)
            pfl.Positions[name] = {
                point = "CENTER",
                relativeTo = "UIParent",
                relativePoint = "CENTER",
                xOfs = 0,
                yOfs = 0,
            }
        else
            f:SetPoint(pos.point,_G[pos.relativeTo] or UIParent,pos.relativePoint,pos.xOfs,pos.yOfs)
        end
    end

    local function StartMovingShift(self)
        if not self:IsMovable() then return end
        if IsShiftKeyDown() then
            if self.__redirect then
                self.__redirect:StartMoving()
            else
                self:StartMoving()
            end
        end
    end

    local function StartMoving(self)
        if not self:IsMovable() then return end
        if self.__redirect then
            self.__redirect:StartMoving()
        else
            self:StartMoving()
        end
    end

    local function StopMoving(self)
        if self.__redirect then
            self.__redirect:StopMovingOrSizing()
            addon:SavePosition(self.__redirect)
        else
            self:StopMovingOrSizing()
            addon:SavePosition(self)
        end
    end

    -- Registers saving positions in database
    function addon:RegisterMoveSaving(frame,point,relativeTo,relativePoint,xOfs,yOfs,withShift,redirect)
        --[===[@debug@
        assert(type(frame) == "table","expected 'frame' to be a table")
        assert(frame.IsObjectType and frame:IsObjectType("Region"),"'frame' is not a blizzard frame")
        if redirect then
            assert(type(redirect) == "table","expected 'redirect' to be a table")
            assert(redirect.IsObjectType and redirect:IsObjectType("Region"),"'frame' is not a blizzard frame")
        end
        --@end-debug@]===]
        
        frame.__redirect = redirect
        if withShift then
            frame:SetScript("OnMouseDown",StartMovingShift)
        else
            frame:SetScript("OnMouseDown",StartMoving)
        end
        frame:SetScript("OnMouseUp",StopMoving)

        -- Add default position
        local pos = {
            point = point,
            relativeTo = relativeTo,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs,
        }

        defaults.profile.Positions[redirect and redirect:GetName() or frame:GetName()] = pos
        self:RefreshDefaults()
        
    end
end

---------------------------------------------
-- TOOLTIP TEXT
---------------------------------------------

do
    local function OnEnter(self)
        if self.showtooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self._ttTitle then GameTooltip:AddLine(self._ttTitle,nil,nil,nil,true) end
            if self._ttText then GameTooltip:AddLine(self._ttText,1,1,1,true) end
            GameTooltip:Show()
        end
    end

    local function OnLeave(self)
        if self.showtooltip then
            GameTooltip:Hide()
        end
    end

    function addon:AddTooltipText(obj,title,text)
        obj._ttTitle = title
        obj._ttText = text
        obj.showtooltip = true
        if not obj:GetScript("OnEnter") then
            obj:SetScript("OnEnter", OnEnter)
        else
            obj:HookScript("OnEnter", OnEnter)
        end
        
        if not obj:GetScript("OnLeave") then
            obj:SetScript("OnLeave", OnLeave)
        else
            obj:HookScript("OnLeave", OnLeave)
        end
    end
end

---------------------------------------------
-- CONFIG
---------------------------------------------

function addon:ToggleConfig()
    if not addon.Options then
        if select(6,GetAddOnInfo("DXE_Options")) == "MISSING" then self:Print((L["Missing %s"]):format("DXE_Options")) return end
        if not IsAddOnLoaded("DXE_Options") then self.Loader:Load("DXE_Options") end
    end
    addon.Options:ToggleConfig()
end

---------------------------------------------
-- COMMS
---------------------------------------------

function addon:SendWhisperComm(target,commType,...)
    --[===[@debug@
    assert(type(target) == "string")
    assert(type(commType) == "string")
    --@end-debug@]===]
    self:SendCommMessage("DXE",self:Serialize(commType,...),"WHISPER",target)
end

function addon:SendRaidComm(commType,...)
    --[===[@debug@
    assert(type(commType) == "string")
    --@end-debug@]===]
    if addon.GroupType == "NONE" then return end
    self:SendCommMessage("DXE",self:Serialize(commType,...),addon.GroupType)
end

function addon:OnCommReceived(prefix, msg, dist, sender)

    if addon:IsThrottleRequestMatch(msg) then
        addon:ProvideThrottleData(sender, msg, CE)
    elseif addon:IsThrottleProvideMatch(msg) then
        addon:UpdateThrottlingData(sender, msg)
    else  
        if (dist ~= "RAID" and dist ~= "PARTY" and dist ~= "PARTY" and dist ~= "BATTLEGROUND" and dist ~= "WHISPER") or sender == self.PNAME then return end
        if (dist == "PARTY" or dist == "RAID" or dist == "WHISPER" or dist == "BATTLEGROUND") then
            local _,request = self:Deserialize(msg)
            if request == "NewUpdate" then
                local newVersion = select(3,self:Deserialize(msg))
                addon:DisplayNewVersion(newVersion)
            end
        end
        self:DispatchComm(sender, self:Deserialize(msg))
    end
end

function addon:DispatchComm(sender,success,commType,...)
    if success then
        local callback = "OnComm"..commType
        self.callbacks:Fire(callback,commType,sender,...)
    end
end

---------------------------------------------
-- ENCOUNTER DEFAULTS
---------------------------------------------

do
    local EncDefaults = {
        alerts = {
            L = L["Bars"],
            order = 100,
            defaultEnabled = true ,
            defaults = {
                color1 = "Clear",
                color2 = "Off",
                sound = "None",
                flashscreen = false,
                counter = false,
                flashtime = 5,
                audiocd = "#off#",
                emphasizewarning = false,
                emphasizetimer = false,
                stacks = 0,
            },
        },
        raidicons = {
            L = L["Raid Icons"],
            order = 200,
            defaultEnabled = true,
            defaults = {
                throttle = true,
            },
        },
        arrows = {
            L = L["Arrows"],
            order = 300,
            defaultEnabled = true,
            defaults = {
                sound = "None",
            },
        },
        announces = {
            L = L["Announces"],
            order = 400,
            defaultEnabled = true,
            defaults = {
                throttle = false,
            },
        },

        -- always add options
        windows = {
            L = L["Windows"],
            order = 800,
            override = true,
            list = {
                proxwindow = {
                    defaultEnabled = false,
                    varname = L["Proximity"],
                    order = 100,
                    options = {
                        -- var => default value
                        proxoverride = false,
                        proxrange = 10,
                        proxnoauto = false,
                        proxnoautostart = false,
                    },
                },
                apbwindow = {
                    defaultEnabled = false,
                    varname = L["Alternate Power"],
                    order = 200,
                    options = {
                        -- var => default value
                        apboverride = false,
                        apbthreshold = 10,
                        apbtext = "AlternatePower",
                    },
                },
            }
        },
    }

    addon.EncDefaults = EncDefaults

    function addon:AddEncounterDefaults(data)
        local defaults = {}
        self.defaults.profile.Encounters[data.key] = defaults

        ------------------------------------------------------------
        -- Sound upgrading from versions < 375
        if pfl.Encounters[data.key] then
            for var,info in pairs(pfl.Encounters[data.key]) do
                if type(info) == "table" then
                    if info.sound and info.sound:find("^DXE ALERT%d+") then
                        info.sound = (info.sound:gsub("DXE ",""))
                    end
                elseif type(info) == "boolean" then
                    -- It should never be a boolean
                    pfl.Encounters[data.key][var] = nil
                end
            end
        end
        ------------------------------------------------------------

        for optionType,optionInfo in pairs(EncDefaults) do
            local optionData = data[optionType]
            if optionData and not optionInfo.override then
                for var,info in pairs(optionData) do
                    defaults[var] = {}
                    -- Add setting defaults
                    -- also alert can be disabled by the module by default
                    if info.enabled == false then
                        defaults[var].enabled = false
                    elseif info.enabled then
                        defaults[var].enabled = info.enabled
                    else
                        defaults[var].enabled = optionInfo.defaultEnabled
                    end
                    
                    ----------------------------------------------------
                    -- Special case
                    -- When an alert with type 'simple' is changed to 'centerpopup', color1 can get "stuck" on 'Clear'
                    -- Reset color1 if this happens
                    if optionType == "alerts" then
                        local db = pfl.Encounters[data.key]
                        if db and db[var]
                            and (info.type == "centerpopup" or info.type == "dropdown")
                            and db[var].color1 == "Clear" then
                            db[var].color1 = nil
                        end
                    end
                    ----------------------------------------------------
                    if optionType == "raidicons" then
                        if info.type == "ENEMY" or info.type == "FRIENDLY" then
                            local markVar = "mark1"
                            defaults[var][markVar] = "preset"..info.icon
                        elseif info.type == "MULTIENEMY" or info.type == "MULTIFRIENDLY" then
                            for n=1,info.total or 1 do
                                local markVar = "mark"..n
                                defaults[var][markVar] = "preset"..(info.icon + n - 1)
                            end
                        end
                    end
                    
                    for k,varDefault in pairs(EncDefaults[optionType].defaults) do
                        defaults[var][k] = info[k] or varDefault
                    end
                end
            end
        end
        for var,winData in pairs(EncDefaults.windows.list) do
            defaults[var] = {}
            if data.windows and data.windows[var] then
                defaults[var].enabled = data.windows[var]
            else
                defaults[var].enabled = winData.defaultEnabled
            end

            -- options
            if winData.options then
                for optvar,value in pairs(winData.options) do
                    if data.windows and data.windows[optvar] then
                        defaults[var][optvar] = data.windows[optvar]
                    else
                        defaults[var][optvar] = value
                    end
                end
            end
        end
        
        -- Defaults for my other categories because I don't like the way other default are handled in combination with Options
        if not pfl.Encounters then pfl.Encounters = {} end
        if not pfl.Encounters[data.key] then pfl.Encounters[data.key] = {} end
        
        -- Boss Emotes (filter)
        if data.bossmessages or (data.filters and data.filters.bossemotes) then
            if not defaults.bossmessages then defaults.bossmessages = {} end
            local filterdata = data.bossmessages or data.filters.bossemotes
            for var,info in pairs(filterdata) do
                if not defaults.bossmessages[var] then
                    defaults.bossmessages[var] = {
                        hide = info.hide or false,
                        removeIcon = false,
                    }
                end
            end
        end
        
        -- Raid Warnings (filter)
        if data.filters and data.filters.raidwarnings then
            if not defaults.raidmessages then defaults.raidmessages = {} end
            local filterdata = data.filters.raidwarnings
            for var,info in pairs(filterdata) do
                if not defaults.raidmessages[var] then
                    defaults.raidmessages[var] = {
                        hide = info.hide or false,
                    }
                end
            end
        end
        
        -- Phrase Colors
        if data.phrasecolors then
            if not defaults.phrasecolors then defaults.phrasecolors = {} end
            for n,coloring in ipairs(data.phrasecolors) do
                if not defaults.phrasecolors[coloring[1]] then defaults.phrasecolors[coloring[1]] = {color = coloring[2]} end
            end
        end
        
        -- Miscellaneous
        if data.misc then addon:AddMiscDefaults(data.key, data.misc.args) end
        
        -- Battlegrounds
        if addon:IsModuleBattleground(data.key) then
            defaults.battleground = {}
            addon:InstallBattlegroundDefaults(data, defaults.battleground)
        end
        
        -- Radar Circles
        if data.radars then
            for key,info in pairs(data.radars) do
                if not defaults.radars then defaults.radars = {} end
                defaults.radars[key] = info.color or "1-Default"
            end
        end
    end
end

local function AddMiscProfileValues(profileTable, args)
    if not args then return end
    
    if not profileTable.misc then profileTable.misc = {} end
    if type(args) ~= "table" then return end
    
    for key,item in pairs(args) do
        if item.type ~= "execute" or item.name ~= "Reset" then
            if profileTable.misc[key] == nil then profileTable.misc[key] = {} end
            if profileTable.misc[key].value == nil then
                if item.type == "toggle" then
                    profileTable.misc[key].value = item.default or false
                elseif item.type == "select" then
                    local miscValues = type(item.values) == "function" and item.values() or item.values
                    if item.default then
                        profileTable.misc[key].value = item.default
                    elseif #miscValues > 0 then
                        profileTable.misc[key].value = 1
                    else
                        local def_key, def_val = next(miscValues)
                        profileTable.misc[key].value = def_key
                    end
                elseif item.type == "range" then
                    profileTable.misc[key].value = item.default or item.min or 1
                elseif item.type == "input" then
                    if not item.default then
                        local langKey = pfl.Misc.DefaultMessageLanguage
                        profileTable.misc[key].value = item["default_"..langKey] or ""
                    else
                        profileTable.misc[key].value = item.default or ""
                    end
                end
            end
        end
    end
end

function addon:AddMiscDefaults(enckey, args)
    local defaults = addon.defaults.profile.Encounters[enckey]
    local profile = pfl.Encounters[enckey]
    AddMiscProfileValues(defaults, args)
    AddMiscProfileValues(profile, args)
end

local LANG_CODE_TO_LANG_NAME = {
    ["en"] = "English",
    ["cs"] = "Cestina",
}

function addon:genmisclangreset(order, textpattern, lang, ...)
    local keystoreset = {}
    for i=1,select("#",...) do
        local item = select(i,...)
        table.insert(keystoreset,item)
    end
    
    local resetitem = {
        type = "execute",
        name = format(textpattern,LANG_CODE_TO_LANG_NAME[lang]) or "Reset",
        func = function(info) 
            for i,var in ipairs (keystoreset) do
                local langString = EDB[info[3]].misc.args[var]["default_"..lang]
                if langString then
                    addon.db.profile.Encounters[info[#info-2]].misc[var].value = langString
                else
                    local defaultLang = EDB[info[3]].misc.args[var].defaultlang
                    langString = EDB[info[3]].misc.args[var]["default_"..defaultLang]
                    if langString then
                        addon.db.profile.Encounters[info[#info-2]].misc[var].value = langString
                    end
                end
                --addon:PrintTable(info)
                
                --addon.db.profile.Encounters[info[#info-2]].misc[var].value = addon.defaults.profile.Encounters[info[#info-2]].misc[var].value
            end
        end,
        width = "half",
        order = order,
    }
    
    if resetitem.name:len() > 10 then resetitem.width = "regular" end
    
    return resetitem
end

function addon:genmiscreset(order, ...)
    local keystoreset = {}
    for i=1,select("#",...) do
        local item = select(i,...)
        table.insert(keystoreset,item)
    end
    
    local resetitem = {
        type = "execute",
        name = "Reset",
        func = function(info) 
            for i,var in ipairs (keystoreset) do
                addon.db.profile.Encounters[info[#info-2]].misc[var].value = addon.defaults.profile.Encounters[info[#info-2]].misc[var].value
            end
        end,
        width = "half",
        order = order,
    }
    
    return resetitem
end

---------------------------------------------
-- REGEN START/STOPPING
---------------------------------------------

--local startedOnIEEU = false
do
    -- PLAYER_REGEN_ENABLED
    function addon:CombatStop()
        if not self:IsRunning() then
            return
        elseif not startedOnIEEU then
            -- Auto-wipe delay
            if self:IsRunning() then
                if DelayWipeTimer then
                    return
                else
                    if not wipeDelayed and CE.advanced and CE.advanced.delayWipe then
                        local wipeDelay = CE.advanced.delayWipe
                        if wipeDelay > 0 and wipeDelay < 180 then
                            DelayWipeTimer = self:ScheduleTimer("TriggerDelayedWipe", wipeDelay, function() addon:ConfirmWipe(true) end)
                            return
                        end
                    else
                        self:ConfirmWipe(true)
                    end
                end
            end
        end
    end

    -- PLAYER_REGEN_DISABLED
    function addon:CombatStart()
        if self:IsRunning() then
            if not startedOnIEEU then
                if ConfirmWipeTimer then
                    self:CancelTimer(ConfirmWipeTimer,true)
                    ConfirmWipeTimer = nil
                end
            end
        else
            if PreventPullTimer then
                return
            end
            
            local key = self:Scan(true)
            if key then
                self:SetActiveEncounter(key);
                self:StartEncounter(false)
            end
        end
    end
end

---------------------------------------------
-- SHARED EVENTS
---------------------------------------------

local weare42 = tonumber((select(4, GetBuildInfo()))) > 40100
function addon:COMBAT_LOG_EVENT_UNFILTERED(_, _,eventtype, _, ...)
    if eventtype ~= "UNIT_DIED" and eventtype ~= "PARTY_KILL" then return end
    if addon:IsTempRegistered() then
        addon:ProcessTempHW(select(5,...))
    end

    local dstGUID,destName
    if weare42 then dstGUID,destName = select(5, ...) else dstGUID,destName = select(4, ...) end     
    
    local npcid = NID[dstGUID]

    if not npcid then 
        if self:IsRunning() then self:ConfirmWipe() end
        return
    end
    -- Update HWs
    self:HWDead(npcid)
    
    if not DEFEAT_NID then
        if DEFEAT_NIDS and DEFEAT_NIDS[npcid] == false then
            DEFEAT_NIDS[npcid] = true
            local flag = true
            for k,v in pairs(DEFEAT_NIDS) do
                if not v then flag = false; break end
            end
            if flag then
                addon:TriggerDefeat()
            end
        end
    elseif DEFEAT_NID == npcid then
        addon:TriggerDefeat()
    end  
end


---------------------------------------------
-- SLASH COMMANDS
---------------------------------------------

function addon:SetupSlashCommands()
    DXE_SLASH_HANDLER = function(msg)
        local cmd = msg:match("[^ ]*"):lower()
        if cmd == L["enable"]:lower() then
            addon.db.profile.Enabled = true
            addon:Enable()
            local ACR = LibStub("AceConfigRegistry-3.0",true)
            if ACR then ACR:NotifyChange("DXE") end
        elseif cmd == L["disable"]:lower() then
            addon.db.profile.Enabled = false
            addon:Disable()
            local ACR = LibStub("AceConfigRegistry-3.0",true)
            if ACR then ACR:NotifyChange("DXE") end
        elseif cmd == "" or cmd == L["config"]:lower() then
            addon:ToggleConfig()
        elseif cmd == L["version"]:lower() then
            addon:VersionCheck()
        elseif cmd == L["proximity"]:lower() or cmd == "range" or cmd == "distance" then
            local range = match(msg,"%d+")
            addon:ShowProximity(range) 
        elseif cmd == "pull" then
          addon:AnnouncePull(msg)
        elseif cmd == "break" then
          addon:AnnounceBreak(msg)
        elseif cmd == "leave" then
            LeaveParty()
        elseif cmd == "disband" then
            addon:DisbandGroup()
        elseif cmd == "ress" then
            AcceptResurrect()
            StaticPopup1:Hide()
        elseif cmd == "repop" then
            RepopMe()
        elseif cmd == "autorepop" then
            addon.PvP:ToggleAutoRelease()
        else
            addon:PrintCommands()     
        end
    end
    self.SetupSlashCommands = nil
end

function addon:PrintCommands()
    ChatFrame1:AddMessage("|cff99ff33"..L["DXE Slash Commands"].."|r: |cffffff00/dxe|r |cffffd200<"..L["option"]..">|r")
    ChatFrame1:AddMessage(" |cffffd200"..L["enable"].."|r - "..L["Enable addon"])
    ChatFrame1:AddMessage(" |cffffd200"..L["disable"].."|r - "..L["Disable addon"])
    ChatFrame1:AddMessage(" |cffffd200"..L["config"].."|r - "..L["Toggles configuration"])
    ChatFrame1:AddMessage(" |cffffd200"..L["version"].."|r - "..L["Show version check window"])
    ChatFrame1:AddMessage(" |cffffd200"..L["proximity"].."|r / |cffffd200range|r / |cffffd200distance|r |cff00d200number|r".." - "..L["Show proximity window with number of yards."])
    ChatFrame1:AddMessage(" |cffffd200".."pull|r |cff00d200number|r - ".."Announce pull in number of seconds.")
    ChatFrame1:AddMessage(" |cffffd200".."break|r |cff00d200number|r - ".."Announce break for number of minutes.")      
    ChatFrame1:AddMessage(" |cffffd200".."leave|r - ".."Leaves the current party / raid group.")      
    ChatFrame1:AddMessage(" |cffffd200".."disband|r - ".."Removes all members from the current party / raid group.")
    ChatFrame1:AddMessage(" |cffffd200".."ress|r - ".."Accepts the ressurection proposal.")      
    ChatFrame1:AddMessage(" |cffffd200".."repop|r - ".."Releases your spirit to the nearest graveyard.") 
    ChatFrame1:AddMessage(" |cffffd200".."autorepop|r - ".."|cff0482ffPvP|r: Toggles Automatic Release of Spirit while in a battleground.") 
end


---------------------------------------------
-- "DBM" PULL
---------------------------------------------
local PULL_ANNOUNCE_OFFSETS = {10,7,5,4,3,2,1,0} -- in seconds
local PULL_LABEL = "PullWarning"

function addon:AnnouncePull(msg)
    if addon:IsRunning() then return end
    
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
        addon:Print("\124cffff0000You have to be member of a party or a raid group!\124r")    
        return
    end
    
    if GetNumRaidMembers() > 0 and addon:GetRaidRank() < 1 then 
        addon:Print("\124cffff0000You have insufficient permissions!\124r")    
        return
    end
    
    local time = tonumber(match(msg,"%d+"))
    if not time then
        addon:Print("\124cffff0000Pull time has to be a valid number!\124r")    
        return
    end
    
    if time < 5 and time ~= 0 then
        addon:Print("\124cffff0000Pull has to be at least 5 seconds or to cancel the timer use 0 seconds.\124r")    
        return
    end
    
    if time > 604800 then
        addon:Print("\124cffff0000Pulls longer than a week are not allowed!\124r")    
        return
    end
    
    local channel = ((GetNumRaidMembers() == 0) and "PARTY") or "RAID_WARNING"
  
    addon:CancelSpecialTimers(PULL_LABEL)
    if time <= 0 then
        self:AnnouncePullCancel()
        return
    end
    
    addon:SendDBMComm(format("U\t%s\tPull in",time))
    if pfl.SpecialTimers.PullTimerEnabled then self:PullTimer(time) end
    SendChatMessage("Pull in "..time.." second"..(time>1 and "s" or ""),channel)
  
    for _,offset in ipairs(PULL_ANNOUNCE_OFFSETS) do
        if time > offset then addon:ScheduleSpecialTimer(PULL_LABEL,time-offset, offset) end
    end
end

function addon:PullWarning(time)
    local text = (time > 0) and ("Pull in "..time) or "Pull NOW!"
    addon:Warning(text)
end

function addon:AnnouncePullCancel()
    addon:SendDBMComm(format("U\t%s\tPull in",0.1))
    addon:CancelPull()
end

local function InsertTimerRegistry(name, dbtable, command)
    
    local registry = {}
    for i,time in ipairs(dbtable) do
        local name = addon:TimeToText(time)
        local data = {}
        data.name = name
        if command == "pull" then
            data.func = function() addon:AnnouncePull("pull "..(time)) end
        elseif command == "break" then
            data.func = function() addon:AnnounceBreak("break "..(time/60)) end
        end
        registry[i] = data
    end
    
    local info = UIDropDownMenu_CreateInfo()
    info.isTitle = true 
    info.text = L[name]
    info.notCheckable = true 
    info.justifyH = "LEFT"
    UIDropDownMenu_AddButton(info,1)
    
    for i,data in ipairs(registry) do
        info = UIDropDownMenu_CreateInfo()
        info.text = data.name
        info.notCheckable = true
        info.func = data.func
        info.owner = self
        info.justifyH = "CENTER"
        UIDropDownMenu_AddButton(info,1)
    end
end

local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
	local info

	local function Initialize(self,level)
		level = 1
		if level == 1 then
			InsertTimerRegistry("Initiate Pull in", pfl.SpecialTimers.PullTimers, "pull")
            InsertTimerRegistry("Initiate Break for", pfl.SpecialTimers.BreakTimers, "break")
		end
	end

function addon:CreatePullsBreaksDropDown()
    local pullsbreaks = CreateFrame("Frame", "DXEPanePulls", UIParent, "UIDropDownMenuTemplate") 
    UIDropDownMenu_Initialize(pullsbreaks, Initialize, "MENU")
    return pullsbreaks
end

function addon:CancelPull()
    addon:CancelSpecialTimers(PULL_LABEL)
    addon.Alerts:QuashByPattern(DBM_TIMERS.Pull.timerKey)
    addon.Countdown:StopTimer()
end


---------------------------------------------
-- "DBM" BREAK
---------------------------------------------
local BREAK_ANNOUNCE_OFFSETS = {10,5,3,2,1,0.5,1/6,0} -- in minutes
local BREAK_LABEL = "BreakWarning"

function addon:AnnounceBreak(msg)
    if addon:IsRunning() then return end
    
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
        addon:Print("\124cffff0000You have to be member of a party or a raid group!\124r")    
        return
    end
    
    if GetNumRaidMembers() > 0 and addon:GetRaidRank() < 1 then
        addon:Print("\124cffff0000You have insufficient permissions!\124r")
        return
    end
    
    local time = tonumber(match(msg,"%d+"))
    if time <= 0 then
        addon:AnnounceBreakCancel()
        return
    end
    
    local channel = ((GetNumRaidMembers() == 0) and "PARTY") or "RAID_WARNING"
    
    addon:CancelSpecialTimers(BREAK_LABEL)
    addon:SendDBMComm(format("U\t%s\tBreak time!",time*60))
    SendChatMessage(format("Break for %d minute%s, starting NOW!",time,(time > 1 and "s" or "")),channel)
    if pfl.SpecialTimers.BreakTimerEnabled then self:BreakTimer(time*60) end
    
    for _,offset in ipairs(BREAK_ANNOUNCE_OFFSETS) do
        if time > offset then addon:ScheduleSpecialTimer(BREAK_LABEL,(time-offset)*60, offset*60) end
    end
end

function addon:BreakWarning(time)
    local text = (time > 0) and (format("Break ends in %d %s%s!",(time>=60) and (time/60) or time, (time >= 60 and "minute" or "second"), (time == 60 or time == 1) and "" or "s")) or "Break time is over!"
    addon:Warning(text)
end

function addon:CancelBreak()
    addon:CancelSpecialTimers(BREAK_LABEL)
    addon.Alerts:QuashByPattern(DBM_TIMERS.Break.timerKey)
end

function addon:AnnounceBreakCancel()
    addon:SendDBMComm(format("U\t%s\tBreak time!",0.1))
    addon:CancelBreak()
end

---------------------------------------------
-- SPECIAL TIMERS
---------------------------------------------
local specialTimers = {}

function addon:Warning(text)
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then return end
    local channel = ((GetNumRaidMembers() == 0) and "PARTY") or "RAID_WARNING"
    SendChatMessage(text,channel)
end

function addon:ScheduleSpecialTimer(label, time, ...)
    local timer = self:ScheduleTimer(label, time, ...)
    if not specialTimers.label then specialTimers.label = {} end
    table.insert(specialTimers.label, #specialTimers.label + 1, timer)
end

function addon:CancelSpecialTimers(label)
    if specialTimers.label then
        for _,t in ipairs(specialTimers.label) do self:CancelTimer(t, true) end
    end
    specialTimers.label = {}

end

---------------------------------------------
-- RAID RANK
---------------------------------------------
-- Raid Leader  - 2
-- Raid Assist  - 1
-- Party Leader - 1
-- Member       - 0
function addon:GetRaidRank(unit)
    if GetNumRaidMembers() <= 1 then
        if GetNumPartyMembers() > 0 then
            if not unit or (unit == "player") or (UnitName("player") == unit) then
                return IsPartyLeader() or 0
            else
                return UnitIsPartyLeader(unit) or 0
            end
        else
            return 0
        end
    end
    
    if GetNumRaidMembers() > 1 then
        for i = 1, GetNumRaidMembers() do
            local name, rank = GetRaidRosterInfo(i)      
            if name == (unit or UnitName("player")) then
                return rank
            end
        end 
    end    
    return 0
end

---------------------------------------------
-- LIST OF CLASS
-- Returns a list of units that match the class and if given role requirements)
---------------------------------------------
addon.ListOfClass = function(class,role)
    local list = {}
    if GetNumRaidMembers() > 1 then
        for i=1,GetNumRaidMembers() do
            local unit = "raid"..i
            if UnitClass(unit) == class then
                if not role or role == "ANY" or UnitGroupRolesAssigned(unit) == role then
                    list[#list+1] = unit
                end
            end
        end
        
        return list
    elseif GetNumPartyMembers() > 0 then
        for i=1,GetNumPartyMembers() do
            local unit = "party"..i
            if UnitClass(unit) == class then
                if not role or role == "ANY" or UnitGroupRolesAssigned(unit) == role then
                    list[#list+1] = unit
                end
            end
        end
    end
    unit = "player"
    
    if UnitClass(unit) == class then
        if not role or role == "ANY" or UnitGroupRolesAssigned(unit) == role then
            list[#list+1] = unit
        end
    end
    
    return list
end

addon.NamedListOfClass = function(class,role)
    local list = addon.ListOfClass(class,role)
    for i=1,#list do
        list[i] = UnitName(list[i])
    end
        
    return list
end


---------------------------------------------
-- SPEED KILLS
---------------------------------------------
function addon:GetBestTimeKey(key)
    if addon:IsModuleBattleground(key) then
        return addon.Faction.Map[addon.Faction:Of("player")].capital
    else
        local dim,diff = addon:GetRaidInfo()
        return format("%s-player-%s", dim, diff:lower())
    end
end

function addon:GetBestTime(key,diffKey,dataKey)
    if key == "default" then return end
    
    local besttimeCateg = db.profile.Encounters[key]["besttime"]
    if not besttimeCateg then return nil end
    local data = besttimeCateg[diffKey or addon:GetBestTimeKey(key)]
    return data and data[dataKey or "time"]
end

function addon:SetNewBestTime(newTime, key, diffKey)
    key = key or CE.key
    diffKey = diffKey or addon:GetBestTimeKey(key)
    
    
    local bestOldTime = addon:GetBestTime(key, diffKey)
    local besttimeData
    if addon:IsModuleBattleground(key) then
        besttimeData = {
        time = newTime,
        formertime = bestOldTime
    }
    else
        local dim,diff = addon:GetRaidInfo()
        besttimeData = {
            raidsize = dim,
            difficulty = diff,
            time = newTime,
            formertime = bestOldTime
        }
    end
    
    
    if not db.profile.Encounters[key]["besttime"] then
        db.profile.Encounters[key]["besttime"] = {}
    end
    db.profile.Encounters[key]["besttime"][diffKey] = besttimeData
end

function addon:TimeToText(time,includeMilliseconds)
   local text = ""
   if time < 0 then
      text = " - "
      time = -time
   end
   local m = floor(time / 60)
   local s = tonumber(format("%d",time % 60))
   local ms = floor((time - m*60 - s) * 1000)
   
   
   
   if m > 0 then
      text = format("%s%d minute%s", text, m, m == 1 and "" or "s")
      if s > 0 or ms > 0 then text = text.." " end
   end
   
   if s > 0 then
      text = format("%s%d second%s", text, s, s == 1 and "" or "s")
   end
   
   if includeMilliseconds and ms > 0 then
      text = format("%s%s%d millisecond%s",
         text,
         (m > 0 or s > 0) and " " or "",
         ms,
      ms == 1 and "" or "s")
   end
   
   return text
end

---------------------------------------------
-- RAID DISBANDING
---------------------------------------------
function addon:DisbandGroup()
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
        addon:Print("You are not in a party nor a raid group.")
        return
    elseif GetNumRaidMembers() > 0 and addon:GetRaidRank() < 2 then
        addon:Print("\124cffff0000You have insufficient permissions (Raid Leader required)!\124r")    
        return
    elseif GetNumRaidMembers() == 0 and addon:GetRaidRank() ~= 1 then
        addon:Print("\124cffff0000You have insufficient permissions (Party Leader required)!\124r")    
        return
    end
    addon:Print("Disbanding group.")
    local playersToKick = {}
    if GetNumRaidMembers() > 0 then
        for i=1,GetNumRaidMembers() do
            local name = UnitName("raid"..i)
            if name ~= UnitName("player") then
                playersToKick[i] = name
            end
        end
    else
        for i=1,GetNumPartyMembers() do
            playersToKick[i] = UnitName("party"..i)
        end
    end
    
    for _,name in ipairs(playersToKick) do
        UninviteUnit(name,"<DXE> Disbanding group.")
    end
end

---------------------------------------------
-- ROLE CHECK PROTECTION
---------------------------------------------
local ROLEINDEX_TO_BUTTON_INDEX = {
    "Tank","Healer","DPS",
}

local BUTTON_INDEX_TO_ROLE_NAME = {
    ["Tank"] = "TANK",
    ["Healer"] = "HEALER",
    ["DPS"] = "DAMAGER",
}

local CLASS_TO_SPEC_TO_ROLEINDEX = {
    ["Paladin"] = {2,1,3},
    ["Priest"] = {2,2,3},
    ["Death Knight"] = {1,3,3},
    ["Warrior"] = {3,3,1},
    ["Shaman"] = {3,3,2},
}

local DPS_CLASSES = {"Warlock","Rogue","Mage","Hunter"}
local OBVIOUS_CLASSES = {"Paladin","Priest","Death Knight","Warrior","Shaman"}

local lastRoleCheck = 0

local function GetRoleButtonByTalentSpec()
    local class = UnitClass("player")
    -- Classes that only have dps
    if util.contains(class, DPS_CLASSES) then
        return "DPS"
    -- Classes for which we can determine role by their basic talent tree selection
    elseif util.contains(class, OBVIOUS_CLASSES) then
        local talentIndex = GetPrimaryTalentTree(0)
        if talentIndex then
            return ROLEINDEX_TO_BUTTON_INDEX[CLASS_TO_SPEC_TO_ROLEINDEX[class][GetPrimaryTalentTree(0)]]
        else
            return nil
        end
    -- Druids are special case as they can be both Tank and DPS in Feral talents :-)
    elseif class == "Druid" then
        local treeIndex = GetPrimaryTalentTree(0)
        if treeIndex == 1 then
            return "DPS"
        elseif treeIndex == 3 then
            return "Healer"
        elseif treeIndex == 2 then
            if select(5,GetTalentInfo(2,21)) == 1 then
                return "Tank"
            else
                return "DPS"
            end
        end
    end
end

function addon:ManageRoleSelection(event)
    local buttonIndex = GetRoleButtonByTalentSpec()
    local pollRole = RolePollPopup.role
    
    if not buttonIndex then return end
    
    if event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "ROLE_POLL_BEGIN" then
        local instanceType = select(2,GetInstanceInfo())
        
        -- Select correspoding role
        if event == "ACTIVE_TALENT_GROUP_CHANGED" or
            pfl.RoleCheck.AutoSelectRole[instanceType] then
            if BUTTON_INDEX_TO_ROLE_NAME[buttonIndex] ~= pollRole then
                _G["RolePollPopupRoleButton"..buttonIndex]:Click()
            end
        end
        
        -- Confirm the role selection
        if event == "ACTIVE_TALENT_GROUP_CHANGED" or    pfl.RoleCheck.SuppressWhenRoleSelected then
            RolePollPopupAcceptButton:Click()
        end
    end
end

function addon:ROLE_POLL_BEGIN(event,init)
    addon:Print(format("%s has initiated a role check.",CN[init]))
    if(addon:GetRaidRank(init) == 0) then
        RolePollPopupAcceptButton:Click()
    else 
        addon:ManageRoleSelection("ROLE_POLL_BEGIN")
        
        if (lastRoleCheck == 0 or (GetTime() - lastRoleCheck) > pfl.RoleCheck.SoundThrottle) and UnitName("player") ~= init then
            if not addon.Alerts.pfl.DisableSounds then addon.Alerts:Sound(addon.Media.Sounds:GetFile("ROLE_CHECK")) end
        end
    end
    lastRoleCheck = GetTime()    
end

function addon:ACTIVE_TALENT_GROUP_CHANGED(event, currentTree, prevTree)
    if pfl.RoleCheck.AutoSelectRoleRespec then
        addon:ManageRoleSelection("ACTIVE_TALENT_GROUP_CHANGED")
    end
end

---------------------------------------------
-- POPUP DIALOG FIX
---------------------------------------------

function addon:FixPopupDialogs()
    if UnitIsDead("player") and not InCinematic() then
        if ResurrectGetOfferer() then
            StaticPopup_Show("RESURRECT_NO_TIMER",ResurrectGetOfferer())          
        else
            if GetReleaseTimeRemaining() == 0 then
                local dialog = StaticPopup_Show("DEATH")
                dialog.text:SetText("You have died. Release to the nearest graveyard?")
                StaticPopup_Resize(dialog, "DEATH")
            end
        end
    end
end

---------------------------------------------
-- OPTIONS HELPERS
---------------------------------------------
addon.TraversOptions = function(options,path,levels,current)
   if not current then current = 1 end
   if current == levels+1 then
      return options
   elseif type(options) ~= "table" or not options.args then
      return nil
   else
      return addon.TraversOptions(options.args[path[current]],path,levels,current+1)
   end
end
