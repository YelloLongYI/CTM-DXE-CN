local addon = DXE
local L,SN,ST,AT,IT = addon.L,addon.SN,addon.ST,addon.AT,addon.IT

local PvP       = addon.PvP
local PvPScore  = addon.PvPScore
local ItemValue,ItemEnabled = addon.ItemValue,addon.ItemEnabled

local BattlegroundAPI = addon.BattlegroundAPI
local Faction         = addon.Faction
local FactionMap      = Faction.Map
local ScoreAPI        = BattlegroundAPI.Score
local ScoreTimerAPI   = BattlegroundAPI.ScoreTimer
local FlagAPI         = BattlegroundAPI.Flag
local PoiAPI          = BattlegroundAPI.POI


------------------------------------------------------------------------------------
--------------------------------- CAPTURE THE FLAG ---------------------------------
------------------------------------------------------------------------------------
do
    local establishWinner =  function(now)            
        local predictedWinner = "unknown"
        
        for factionA,_ in pairs(FactionMap) do
            local factionB    = Faction:Swap(factionA)
            local scoreA      = ScoreAPI:GetPointsOf(factionA)
            local scoreB      = ScoreAPI:GetPointsOf(factionB)
            local scoreTimeA  = ScoreAPI:GetScoreTimeOf(factionA) or 0
            local scoreTimeB  = ScoreAPI:GetScoreTimeOf(factionB) or 0
            local lastToScore = scoreTimeA > scoreTimeB and factionA or factionB
            
            if (scoreA > scoreB) or ((scoreA == scoreB) and (lastToScore == factionA)) then
                predictedWinner = factionA
                break
            end
        end
        
        return predictedWinner
    end

    local data = {
        modules = {
            score = {
                indexes = {alliance = 2, horde = 3},
                parameterIndex = 4,
                finalScore = 3
            },
            flags = {
                chat = {
                    channel = "chat-battleground",
                    triggers = {
                        {
                            event = "FLAG_PICKED_UP",
                            pattern = "^The (%w+) [Ff]lag was picked up by (%w+)!$",
                            vars = {"_Faction_","FlagCarrier"},
                        },
                        {
                            event = "FLAG_CAPTURED",
                            pattern = "^(%w+) captured the (%w+) [Ff]lag!$",
                            vars = {"FlagCarrier","_Faction_"},
                        },
                        {
                            event = "FLAG_DROPPED",
                            pattern = "^The (%w+) [Ff]lag was dropped by (%w+)!$",
                            vars = {"_Faction_","FlagCarrier"},
                        },
                        {
                            event = "FLAG_RESET",
                            pattern = "^The (%w+) [Ff]lag was returned to its base by",
                            vars = {"_Faction_"},
                        },
                        {
                            event = "FLAG_RESET",
                            pattern = "^The (%w+) [Ff]lag is now placed at its base",
                            vars = {"_Faction_"},
                        },
                        {
                            event = "BOTH_FLAGS_RESET",
                            pattern = "^The flags are now placed at their bases",
                        },
                    },
                },
                slots = {alliance = "alliance", horde = "horde"},
            },
        },
        slots = {
            count = 2,
            textOffsets = {
                {0,0}, -- X offsets
                {-2,-2}, -- Y offsets
            },
        },
        timelimit = 25*60, -- 25 minutes in seconds
        establishWinner = {
            func = establishWinner,
        },
        canDraw = true,
        settings = {
            DisableSlotFactionSwitching = true,
        },
    }
    
    addon:RegisterBattlegroundTemplate("Capture the flag", data)
end

--------------------------------------------------------------------------------------
--------------------------------- BASE RESOURCE RACE ---------------------------------
--------------------------------------------------------------------------------------
do
    local baseData

    local function init()
        baseData = {
            alliance = {bases = 0, lastBases = 0, stableUpdate = false},
            horde =    {bases = 0, lastBases = 0, stableUpdate = false},
        }
        BattlegroundAPI:SetData("baseData",baseData)
    end
    
    local function getBaseCount(faction)
        return PoiAPI:CountPOI({faction = faction, status = "controlled"})
    end
    
    -- Points given by the next increment
    local function GetNextIncr(bases)
        return BattlegroundAPI:GetAttribute("establishWinner","pointIncrements")[bases] or 0
    end
    
    -- Delay [in seconds] between point increments
    local function GetNextTick(bases)
        local nextPoints = BattlegroundAPI:GetAttribute("establishWinner","nextPoints")
        
        if type(nextPoints) == "table" then
            return nextPoints[bases] or 1e-300 -- we don't return 0 here because of divisions later
        else
            return nextPoints or 1e-300 -- we don't return 0 here because of divisions later
        end
    end
    
    local function CalculateWinTime(faction, now, customBases)
        local finalScore = BattlegroundAPI:GetAttribute("modules","score","finalScore")
        local points     = ScoreAPI:GetPointsOf(faction)
        local scoreTime  = ScoreAPI:GetAttribute("scoreTime", faction)
        local bases      = customBases or baseData[faction].bases
        local tickRate   = GetNextTick(bases)
        local nextPoints = GetNextIncr(bases)
        
        local winTime = (ceil((finalScore - points) / nextPoints) * tickRate) - (now - (scoreTime or now))
        if winTime > 5000 then winTime = 5000 end
        
        return winTime
    end
    
    local PredictBasesToTake = function(now)
        local    myFaction = Faction:Of("player")
        local otherFaction = Faction:Swap(myFaction)
        
        local   ourBases = baseData[myFaction].bases
        local theirBases = baseData[otherFaction].bases
        
        local   ourScore = ScoreAPI:GetPointsOf(myFaction)
        local theirScore = ScoreAPI:GetPointsOf(otherFaction)
        
        local   ourTime = baseData[myFaction].winTime
        local theirTime = baseData[otherFaction].winTime
        
        local basesToAttack, basesToTake = 0, 0
        local baseCount = PoiAPI:CountPOI({})
        
        if(ourTime > theirTime) then
            local theirBasesToWin = 0
            local ourBasesToWin = 0
            local victoryFound = false
            for theirPotentialBases = theirBases, 0, -1 do
                for ourPotentialBases = ourBases, baseCount do
                    if ourPotentialBases + theirPotentialBases <= baseCount then
                        local ourTime   = CalculateWinTime(myFaction, now, ourPotentialBases)
                        local theirTime = CalculateWinTime(otherFaction, now, theirPotentialBases)
                        
                        if ourTime < theirTime then
                            ourBasesToWin = ourPotentialBases - ourBases
                            theirBasesToWin = theirBases - theirPotentialBases
                            victoryFound = true
                            break
                        end
                    end
               end
               
               if victoryFound then break end
            end
            
            if victoryFound then
                basesToAttack = theirBasesToWin
                basesToTake = ourBasesToWin
            else
                basesToAttack = 0
                basesToTake = 0
            end
        elseif ourTime == theirTime then
            basesToAttack = 0
            basesToTake = 1
        else
            basesToAttack = 0
            basesToTake = 0
        end
        
        return basesToAttack, basesToTake
    end

    local establishWinner = function(now)
        for faction,_ in pairs(FactionMap) do
            baseData[faction].lastBases = baseData[faction].bases
            baseData[faction].bases = getBaseCount(faction)
        end
        
        -- Bailing the calculation if it's a regular points increment and time has already been calculated
        -- or neither side owns any bases.
        local allianceBases     = baseData.alliance.bases
        local hordeBases        = baseData.horde.bases
        local lastAllianceBases = baseData.alliance.lastBases
        local lastHordeBases    = baseData.horde.lastBases
        
        if allianceBases + hordeBases == 0 then
            return false
        else
            local blockUpdate = true
            for faction,_ in pairs(FactionMap) do
                local bases = baseData[faction].bases
                local lastBases = baseData[faction].lastBases
                if bases == lastBases then
                    local points     = ScoreAPI:GetPointsOf(faction)
                    local lastPoints = ScoreAPI:GetAttribute("lastPoints", faction)
                    local flagPoints = BattlegroundAPI:GetAttribute("modules","flags","pointValues")
                    local flagValue = flagPoints and flagPoints[bases] or 5000
                    if points - lastPoints >= flagValue then
                        blockUpdate = blockUpdate and false
                    elseif ScoreAPI:HasFactionScored(faction) and not baseData[faction].stableUpdate then
                        baseData[faction].stableUpdate = true
                        blockUpdate = blockUpdate and false
                    elseif BattlegroundAPI:GetAttribute("establishWinner","noStableUpdate") then
                        blockUpdate = blockUpdate and false
                    else
                        blockUpdate = blockUpdate and true
                    end
                else
                    baseData[faction].stableUpdate = false
                    blockUpdate = blockUpdate and false
                end
            end
            
            if blockUpdate then return end
        end
        
        for faction,_ in pairs(FactionMap) do
            local bases     = baseData[faction].bases
            local lastBases = baseData[faction].lastBases
            
            -- Setting up a 0th tick
            if bases == 1 and lastBases == 0 then
                ScoreAPI:SetAttribute("scoreTime", faction, now)
            -- Setting up a last tick time
            elseif ScoreAPI:HasFactionScored(faction) then
                if bases > lastBases then
                    -- Adjusting the last tick time
                    local scoreTime  = ScoreAPI:GetAttribute("scoreTime", faction)
                    local tickRate   = GetNextTick(bases)
                    local adjusted = scoreTime + (tickRate*floor((now - scoreTime)/tickRate))
                    
                    ScoreAPI:SetAttribute("scoreTime", faction, adjusted)
                else
                    ScoreAPI:SetAttribute("scoreTime", faction, now)
                end
            end
            
            baseData[faction].winTime = CalculateWinTime(faction, now)
            
        end
        

        
        
        local scorePrediction
        local predictedWinner = "unknown"
        local winTime = -1
        local finalScore = BattlegroundAPI:GetAttribute("modules","score","finalScore")
        
        -- Predict the winner
        for faction,_ in pairs(FactionMap) do
            local otherFaction = Faction:Swap(faction)
            local thisTime =  baseData[faction].winTime
            local otherTime = baseData[otherFaction].winTime
            
            if thisTime < otherTime then
                predictedWinner = faction
                winTime = thisTime
                local points     = ScoreAPI:GetPointsOf(otherFaction)
                local scoreTime  = ScoreAPI:GetAttribute("scoreTime", otherFaction)
                local bases      = baseData[otherFaction].bases
                local nextPoints = GetNextIncr(bases)
                local tickRate   = GetNextTick(bases)
                
                local endPoints  = points + nextPoints * floor((winTime + (now - (scoreTime or now)))/tickRate)
                scorePrediction  = format("(%d - %d)",finalScore, endPoints)
                break
            end
        end
        
        
        -- Predicted bases to win
        local basesToAttack, basesToTake = PredictBasesToTake(now)
        
        -- Setting the module variables
        BattlegroundAPI:SetModuleVariables({
            ["ScorePrediction"] = scorePrediction,
            ["BasesToAttack"]   = basesToAttack,
            ["BasesToTake"]     = basesToTake,
        })
        
        return predictedWinner, winTime
    end
    
    local data = {
        modules = {
            score = {
                indexes = {alliance = 1, horde = 2},
                parameterIndex = 4,
            },
            POI = {
                states = {
                    bases = {
                        {faction = "none",     status = "neutral"},
                        {faction = "alliance", status = "attacked",   flashing = "alliance"},
                        {faction = "horde",    status = "attacked",   flashing = "horde"},
                        {faction = "alliance", status = "controlled", flashing = "", color = "alliance"},
                        {faction = "horde",    status = "controlled", flashing = "", color = "horde"},
                    },
                },
                chat = {
                    channel = "chat-battleground",
                    triggers = {
                        {
                            event = "BASE_CLAIMED",
                            pattern = "^(%w+) claims the ([%w ]+)! If left unchallenged, the (%w+) will control it in 1 minute!$",
                            vars = {"AssaultPlayer","Location","_Faction_"},
                        },
                        {
                            event = "BASE_ASSAULTED",
                            pattern = "^(%w+) has assaulted the ([%w ]+)$",
                            vars = {"AssaultPlayer","Location"},
                        },
                        {
                            event = "BASE_TAKEN",
                            pattern = "^The (%w+) has taken the (%w+)$",
                            vars = {"_Faction_","Location"},
                        },
                    },
                },
            },
        },
        init = init,
        establishWinner = {
            func = establishWinner,
        },
    }
    
    addon:RegisterBattlegroundTemplate("Base resource race", data)
end

-----------------------------------------------------------------------------------
--------------------------------- STRONGHOLD SIEGE --------------------------------
-----------------------------------------------------------------------------------
do
    local establishWinner = function(now)
        
        local predictedWinner = "unknown"
        
        for factionA,_ in pairs(FactionMap) do
            local factionB    = Faction:Swap(factionA)
            local scoreA      = ScoreAPI:GetPointsOf(factionA)
            local scoreB      = ScoreAPI:GetPointsOf(factionB)
            local scoreTimeA  = ScoreAPI:GetScoreTimeOf(factionA) or 0
            local scoreTimeB  = ScoreAPI:GetScoreTimeOf(factionB) or 0
            
            if (scoreA > scoreB) then
                predictedWinner = factionA
                break
            end
        end
        
        return predictedWinner
    end
    
    local data = {
        modules = {
            score = {
                indexes = {alliance = 1, horde = 2},
                parameterIndex = 4,
            },
        },
        establishWinner = {
            func = establishWinner,
        },
    }
    
    addon:RegisterBattlegroundTemplate("Stronghold siege", data)
end

---------------------------------
-- WARSONG GULCH
---------------------------------
do    
    local data = {
        version = 2,
        key = "warsonggulch",
        zone = L.zone["Warsong Gulch"],
        category = L.zone["Battlegrounds"],
        template = "Capture the flag",
        name = "Warsong Gulch",
        triggers = {
            bg_neutral = "Let the battle for Warsong Gulch begin",
        },
        
        onactivate = {
            tracerstart = false,
            combatstop = false,
            combatstart = false,
        },
        userdata = {
            flagTrigers = {
                alliance = {x = 0.53029227256775, y = 0.92676270008087}, -- Horde base
                horde    = {x = 0.4889948964119,  y = 0.11404019594193}, -- Alliance base
            }
        },
        onstart = {
            {
                "quash","bgstartcd",
            },
        },
        battleground = {
            modules = {
                score = {
                    pattern = "(%d+)/3",
                },
                flags = {
                    statesBroken = true,
                    returnTime = 10,
                    respawnTime = 23,
                },
            },
            slots = {
                height = 37,
            },
            events = {
                -- Battleground Start timer
                {
                    event = "START_TIMER_UPDATE",
                    execute = {
                        {
                            "expect",{"&timeleft|bgstartcd&","==","-1"},
                            "alert","bgstartcd",
                        },
                    },
                },
                -- Not Enough Players
                {
                    event = "NOT_ENOUGH_PLAYERS",
                    execute = {
                        {
                            "alert",{"notenougplayerscd",timeexact = "<TimeOut>"},
                        },
                    },
                },
                {
                    event = "ENOUGH_PLAYERS",
                    execute = {
                        {
                            "quash","notenougplayerscd",
                        },
                    },
                },
                -- A faction takes lead
                {
                    event = "FACTION_LEADS",
                    execute = {
                        {
                            "set",{AnnounceWinFaction = "&capitalize|<WinFactionPure>&"}
                        },
                        {
                            "expect",{"<WinFaction>","==","alliance"},
                            "expect",{"&timeleft|alliancewincd&","==","-1"},
                            "batchquash",{"bgendcd","hordewincd"},
                            "alert",{"alliancewincd", timeexact = "<WinTime>"},
                        },
                        {
                            "expect",{"<WinFaction>","==","horde"},
                            "expect",{"&timeleft|hordewincd&","==","-1"},
                            "batchquash",{"bgendcd","alliancewincd"},
                            "alert",{"hordewincd", timeexact = "<WinTime>"},
                        },
                    },
                },
                -- Draw expected
                {
                    event = "DRAW_STATE",
                    execute = {
                        {
                            "expect",{"&timeleft|bgendcd&","==","-1"},
                            "alert","bgendcd",
                            "settimeleft",{"bgendcd","<WinTime>"},
                        },
                    },
                },
                -- Flag Picked Up
                {
                    event = "FLAG_PICKED_UP",
                    execute = {
                        {
                            "arrow","flagarrow",
                            "expect",{"<FlagCarrier>","==","&playername&"},
                            "set",{
                                flagpostX = "&listget|flagTrigers|<FactionPure>|x&",
                                flagpostY = "&listget|flagTrigers|<FactionPure>|y&",
                            },
                            "range",{true},
                            "radar","flagpostradar",
                        },
                    },
                },
                -- Flag Dropped
                {
                    event = "FLAG_DROPPED",
                    execute = {
                        {
                            "removearrow","<FlagCarrier>",
                            "expect",{"<FlagCarrier>","==","&playername&"},
                            "removeradar","flagpostradar",
                            "range",{false},
                        },
                    },
                },
                -- Flag Captured
                {
                    event = "FLAG_CAPTURED",
                    execute = {
                        {
                            "removearrow","<FlagCarrier>",
                            "alert","flagsrespawncd",
                            "expect",{"<FlagCarrier>","==","&playername&"},
                            "removeradar","flagpostradar",
                            "range",{false},
                        },
                    },
                },
            },
        },
        arrows = {
			flagarrow = {
				varname = format("Own Flag Carrier"),
				unit = "<FlagCarrier>",
				persist = 3600,
				action = "TOWARD",
				msg = L.alert["Protect"],
				spell = "Flag carrier",
				sound = "None",
                range1 = 40,
                range2 = 60,
                range3 = 100,
                texture = ST[34976],
			},
		},
        radars = {
            flagpostradar = {
                varname = "Flag Post",
                type = "circle",
                x = "<flagpostX>",
                y = "<flagpostY>",
                range = 5,
                exactrange = true,
                mode = "avoid",
                icon = "Interface\\ICONS\\Achievement_BG_KillFlagCarriers_grabFlag_CapIt",
            },
        },
        windows = {
            proxwindow = true,
            proxnoauto = true,
            proxnoautostart = true,
            proxrange = 10,
            proxoverride = true,
            nodistancecheck = true,
        },
        ordering = {
            alerts = {"bgstartcd","notenougplayerscd","bgendcd","alliancewincd","hordewincd","flagsrespawncd"},
        },
        
        alerts = {
            -- Battleground Start
            bgstartcd = {
                varname = format("%s Countdown",L.alert["Battleground Start"]),
                type = "dropdown",
                text = format(L.alert["Battleground starts"]),
                time = "<StartTime>",
                flashtime = 20,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Misc_Trophy_Argent",
                behavior = "overwrite",
                audiocd = true,
            },
            -- Not Enough Players
            notenougplayerscd = {
                varname = format("%s Countdown",L.alert["Not Enough Players"]),
                type = "dropdown",
                text = format(L.alert["Not enough players"]),
                time = 300,
                flashtime = 10,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_EVERYONES A HERO_RANK2",
                behavior = "overwrite",
            },
            -- Battleground Ends In A Draw
            bgendcd = {
                varname = format(L.alert["%s Countdown"],"Battleground Draw"),
                type = "dropdown",
                text = L.alert["Battleground Draw"],
                time = 1620,
                flashtime = 10,
                color1 = "TEAL",
                color2 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Offhand_1H_UlduarRaid_D_01",
            },
            -- Alliance wins (prediction)
            alliancewincd = {
                varname = format(L.alert["%s Countdown"],"Alliance (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins"],"Alliance"),
                announcetext = format(L.alert["%s wins"],"<AnnounceWinFaction>"),
                time = 1620,
                flashtime = 10,
                color1 = "BLUE",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Alliance",
            },
            -- Horde wins (prediction)
            hordewincd = {
                varname = format(L.alert["%s Countdown"],"Horde (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins"],"Horde"),
                announcetext = format(L.alert["%s wins"],"<AnnounceWinFaction>"),
                time = 1620,
                flashtime = 10,
                color1 = "BROWN",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Horde",
            },
            -- Flags respawn
            flagsrespawncd = {
                varname = format(L.alert["%s Countdown"],"Flags' Respawn"),
                type = "dropdown",
                text = format(L.alert["%s"],"Flags respawning"),
                time = 23,
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "Off",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Ability_Racial_ShadowMeld",
            },
        },
    }
    
    addon:RegisterBattleground(data)
end

---------------------------------
-- TWIN PEAKS
---------------------------------
do    
    local data = {
        version = 2,
        key = "twinpeaks",
        zone = L.zone["Twin Peaks"],
        category = L.zone["Battlegrounds"],
        template = "Capture the flag",
        name = "Twin Peaks",
        triggers = {
            bg_neutral = "Let the battle for Twin Peaks begin",
        },
        
        onactivate = {
            tracerstart = false,
            combatstop = false,
            combatstart = false,
        },
        userdata = {
            flagTrigers = {
                alliance = {x = 0.48344230651855, y = 0.84965759515762}, -- Horde base
                horde    = {x = 0.60957944393158, y = 0.182148873806}, -- Alliance base
            }
        },
        onstart = {
            {
                "quash","bgstartcd",
            },
        },
        battleground = {
            modules = {
                score = {
                    pattern = "(%d+)/3",
                },
                flags = {
                    statesBroken = true,
                    returnTime = 10,
                    respawnTime = 23,
                },
            },
            slots = {
                height = 37,
            },
            events = {
                -- Battleground Start timer
                {
                    event = "START_TIMER_UPDATE",
                    execute = {
                        {
                            "expect",{"&timeleft|bgstartcd&","==","-1"},
                            "alert","bgstartcd",
                        },
                    },
                },
                -- Not Enough Players
                {
                    event = "NOT_ENOUGH_PLAYERS",
                    execute = {
                        {
                            "alert",{"notenougplayerscd",timeexact = "<TimeOut>"},
                        },
                    },
                },
                {
                    event = "ENOUGH_PLAYERS",
                    execute = {
                        {
                            "quash","notenougplayerscd",
                        },
                    },
                },
                -- A faction takes lead
                {
                    event = "FACTION_LEADS",
                    execute = {
                        {
                            "set",{AnnounceWinFaction = "&capitalize|<WinFactionPure>&"}
                        },
                        {
                            "expect",{"<WinFaction>","==","alliance"},
                            "expect",{"&timeleft|alliancewincd&","==","-1"},
                            "batchquash",{"bgendcd","hordewincd"},
                            "alert",{"alliancewincd", timeexact = "<WinTime>"},
                        },
                        {
                            "expect",{"<WinFaction>","==","horde"},
                            "expect",{"&timeleft|hordewincd&","==","-1"},
                            "batchquash",{"bgendcd","alliancewincd"},
                            "alert",{"hordewincd", timeexact = "<WinTime>"},
                        },
                    },
                },
                -- Draw expected
                {
                    event = "DRAW_STATE",
                    execute = {
                        {
                            "expect",{"&timeleft|bgendcd&","==","-1"},
                            "alert","bgendcd",
                            "settimeleft",{"bgendcd","<WinTime>"},
                        },
                    },
                },
                -- Flag Picked Up
                {
                    event = "FLAG_PICKED_UP",
                    execute = {
                        {
                            "arrow","flagarrow",
                            "expect",{"<FlagCarrier>","==","&playername&"},
                            "set",{
                                flagpostX = "&listget|flagTrigers|<FactionPure>|x&",
                                flagpostY = "&listget|flagTrigers|<FactionPure>|y&",
                            },
                            "range",{true},
                            "radar","flagpostradar",
                        },
                    },
                },
                -- Flag Dropped
                {
                    event = "FLAG_DROPPED",
                    execute = {
                        {
                            "removearrow","<FlagCarrier>",
                            "expect",{"<FlagCarrier>","==","&playername&"},
                            "removeradar","flagpostradar",
                            "range",{false},
                        },
                    },
                },
                -- Flag Captured
                {
                    event = "FLAG_CAPTURED",
                    execute = {
                        {
                            "removearrow","<FlagCarrier>",
                            "alert","flagsrespawncd",
                            "expect",{"<FlagCarrier>","==","&playername&"},
                            "removeradar","flagpostradar",
                            "range",{false},
                        },
                    },
                },
            },
        },
        arrows = {
			flagarrow = {
				varname = format("Own Flag Carrier"),
				unit = "<FlagCarrier>",
				persist = 3600,
				action = "TOWARD",
				msg = L.alert["Protect"],
				spell = "Flag carrier",
				sound = "None",
                range1 = 40,
                range2 = 60,
                range3 = 100,
                texture = ST[34976],
			},
		},
        radars = {
            flagpostradar = {
                varname = "Flag Post",
                type = "circle",
                x = "<flagpostX>",
                y = "<flagpostY>",
                range = 5,
                exactrange = true,
                mode = "avoid",
                icon = "Interface\\ICONS\\Achievement_BG_KillFlagCarriers_grabFlag_CapIt",
            },
        },
        windows = {
            proxwindow = true,
            proxnoauto = true,
            proxnoautostart = true,
            proxrange = 10,
            proxoverride = true,
            nodistancecheck = true,
        },
        ordering = {
            alerts = {"bgstartcd","notenougplayerscd","bgendcd","alliancewincd","hordewincd","flagsrespawncd"},
        },
        
        alerts = {
            -- Battleground Start
            bgstartcd = {
                varname = format("%s Countdown",L.alert["Battleground Start"]),
                type = "dropdown",
                text = format(L.alert["Battleground starts"]),
                time = "<StartTime>",
                flashtime = 20,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Misc_Trophy_Argent",
                behavior = "overwrite",
                audiocd = true,
            },
            -- Not Enough Players
            notenougplayerscd = {
                varname = format("%s Countdown",L.alert["Not Enough Players"]),
                type = "dropdown",
                text = format(L.alert["Not enough players"]),
                time = 300,
                flashtime = 10,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_EVERYONES A HERO_RANK2",
                behavior = "overwrite",
            },
            -- Battleground Ends In A Draw
            bgendcd = {
                varname = format(L.alert["%s Countdown"],"Battleground Draw"),
                type = "dropdown",
                text = L.alert["Battleground Draw"],
                time = 1620,
                flashtime = 10,
                color1 = "TEAL",
                color2 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Offhand_1H_UlduarRaid_D_01",
            },
            -- Alliance wins (prediction)
            alliancewincd = {
                varname = format(L.alert["%s Countdown"],"Alliance (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins"],"Alliance"),
                announcetext = format(L.alert["%s wins"],"<AnnounceWinFaction>"),
                time = 1620,
                flashtime = 10,
                color1 = "BLUE",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Alliance",
            },
            -- Horde wins (prediction)
            hordewincd = {
                varname = format(L.alert["%s Countdown"],"Horde (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins"],"Horde"),
                announcetext = format(L.alert["%s wins"],"<AnnounceWinFaction>"),
                time = 1620,
                flashtime = 10,
                color1 = "BROWN",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Horde",
            },
            -- Flags respawn
            flagsrespawncd = {
                varname = format(L.alert["%s Countdown"],"Flags' Respawn"),
                type = "dropdown",
                text = format(L.alert["%s"],"Flags respawning"),
                time = 23,
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "Off",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Ability_Racial_ShadowMeld",
            },
        },
    }
    
    addon:RegisterBattleground(data)
end

---------------------------------
-- ARATHI BASIN
---------------------------------
do
    local data = {
        version = 2,
        key = "arathibasin",
        zone = L.zone["Arathi Basin"],
        category = L.zone["Battlegrounds"],
        template = "Base resource race",
        name = "Arathi Basin",
        triggers = {
            bg_neutral = "The Battle for Arathi Basin has begun",
        },
        onactivate = {
            counters = {"basestoattackcounter","basestohavecounter"},
            tracerstart = false,
            combatstop = false,
            combatstart = false,
        },
        userdata = {
            
        },
        onstart = {
            {
                "quash","bgstartcd",
            },
        },
        battleground = {
            modules = {
                score = {
                    finalScore = 1600,
                    pattern = "(%d+)/1600",
                },
                POI = {
                    categories = {
                        bases = {
                            ["Stables"]     = {slot = 1, POIs = {36,37,39,38,40}, chat = "stables"},
                            ["Lumber Mill"] = {slot = 2, POIs = {21,22,24,23,25}, chat = "lumber mill"},
                            ["Blacksmith"]  = {slot = 3, POIs = {26,27,29,28,30}, chat = "blacksmith"},
                            ["Gold Mine"]   = {slot = 4, POIs = {16,17,19,18,20}, chat = "mine"},
                            ["Farm"]        = {slot = 5, POIs = {31,32,34,33,35}, chat = "farm"},
                        },
                    },
                },
            },  
            establishWinner = {
                pointIncrements = {10,10,10,10,30},
                nextPoints = {12,9,6,3,1},
            },
            slots = {
                count = 5,
                texts = {" Stables","LM","BS","GM"," Farm"},
                actions = {
                    {"base-help","Stables"},
                    {"base-help","Lumber Mill"},
                    {"base-help","Blacksmith"},
                    {"base-help","Gold Mine"},
                    {"base-help","Farm"},
                },
                height = 37,
            },
            events = {
                -- Battleground Start timer
                {
                    event = "START_TIMER_UPDATE",
                    execute = {
                        {
                            "expect",{"&timeleft|bgstartcd&","==","-1"},
                            "alert","bgstartcd",
                        },
                    },
                },
                -- Not Enough Players
                {
                    event = "NOT_ENOUGH_PLAYERS",
                    execute = {
                        {
                            "alert",{"notenougplayerscd",timeexact = "<TimeOut>"},
                        },
                    },
                },
                {
                    event = "ENOUGH_PLAYERS",
                    execute = {
                        {
                            "quash","notenougplayerscd",
                        },
                    },
                },
                -- A base gets claimed or assaulted
                {
                    event = {"BASE_ASSAULTED","BASE_CLAIMED"},
                    execute = {
                        {
                            "expect",{"<Faction>","==","alliance"},
                            "quash",{"hordeassaultcd","<Location>"},
                            "alert","allianceassaultcd",
                        },
                        {
                            "expect",{"<Faction>","==","horde"},
                            "quash",{"allianceassaultcd","<Location>"},
                            "alert","hordeassaultcd",
                        },
                    },
                },
                -- A base is taken
                {
                    event = "BASE_TAKEN",
                    execute = {
                        {
                            "expect",{"<Faction>","==","alliance"},
                            "quash",{"hordeassaultcd","<Location>"},
                        },
                        {
                            "expect",{"<Faction>","==","horde"},
                            "quash",{"allianceassaultcd","<Location>"},
                        },
                    },
                },
                {
                    event = "FACTION_LEADS",
                    execute = {
                        {
                            "set",{AnnounceWinFaction = "&capitalize|<WinFactionPure>&"}
                        },
                        -- Alliance takes the lead
                        {
                            "expect",{"<WinFaction>","==","alliance"},
                            "batchquash",{"alliancewincd","hordewincd"},
                            "alert",{"alliancewincd", timeexact = "<WinTime>"},
                        },
                        -- Horde takes the lead
                        {
                            "expect",{"<WinFaction>","==","horde"},
                            "batchquash",{"alliancewincd","hordewincd"},
                            "alert",{"hordewincd", timeexact = "<WinTime>"},
                        },
                    },
                },
            },
        },
        counters = {
            basestoattackcounter = {
                variable = "BasesToAttack",
                label = "Bases to attack",
                pattern = "%d",
                value = 0,
                minimum = 0,
                maximum = 0,
            },
            basestohavecounter = {
                variable = "BasesToTake",
                label = "Bases to have",
                pattern = "%d",
                value = 0,
                minimum = 0,
                maximum = 0,
            },
        },
        phrasecolors = {
            {"%(%d+","GOLD","Predicted Score (Left)"},
            {"%d+%)","GOLD","Predicted Score (Right)"},
        },
        ordering = {
            alerts = {"bgstartcd","notenougplayerscd","alliancewincd","hordewincd","allianceassaultcd","hordeassaultcd"},
        },
        
        alerts = {
            -- Battleground Start
            bgstartcd = {
                varname = format("%s Countdown",L.alert["Battleground Start"]),
                type = "dropdown",
                text = format(L.alert["Battleground starts"]),
                time = "<StartTime>",
                flashtime = 20,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Misc_Trophy_Argent",
                behavior = "overwrite",
                audiocd = true,
            },
            -- Not Enough Players
            notenougplayerscd = {
                varname = format("%s Countdown",L.alert["Not Enough Players"]),
                type = "dropdown",
                text = format(L.alert["Not enough players"]),
                time = 300,
                flashtime = 10,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_EVERYONES A HERO_RANK2",
                behavior = "overwrite",
            },
            -- Alliance wins (prediction)
            alliancewincd = {
                varname = format(L.alert["%s Countdown"],"Alliance (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins %s"],"Alliance","<ScorePrediction>"),
                announcetext = format(L.alert["%s wins %s"],"<AnnounceWinFaction>","<ScorePrediction>"),
                time = 1920, -- estimated maximum
                flashtime = 10,
                color1 = "BLUE",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Alliance",
            },
            -- Horde wins (prediction)
            hordewincd = {
                varname = format(L.alert["%s Countdown"],"Horde (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins %s"],"Horde","<ScorePrediction>"),
                announcetext = format(L.alert["%s wins %s"],"<AnnounceWinFaction>","<ScorePrediction>"),
                time = 1920, -- estimated maximum
                flashtime = 10,
                color1 = "BROWN",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Horde",
            },
            -- Alliance assaults base
            allianceassaultcd = {
                varname = format(L.alert["%s Countdown"],"Alliance Assaults Base"),
                type = "dropdown",
                text = format(L.alert["%s"],"<Location>"),
                announcetext = format(L.alert["%s captures %s"],"Alliance","<Location>"),
                time = 60,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "TURQUOISE",
                sound = "None",
                icon = "Interface\\ICONS\\Achievement_PVP_A_16",
                tag = "<Location>",
            },
            -- Horde assaults base
            hordeassaultcd = {
                varname = format(L.alert["%s Countdown"],"Horde Assaults Base"),
                type = "dropdown",
                text = format(L.alert["%s"],"<Location>"),
                announcetext = format(L.alert["%s captures %s"],"Horde","<Location>"),
                time = 60,
                flashtime = 5,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Inv_Misc_Tournaments_banner_Orc",
                tag = "<Location>",
            },
        },
    }
    
    addon:RegisterBattleground(data)
end

---------------------------------
-- THE BATTLE FOR GILNEAS
---------------------------------
do
    local data = {
        version = 2,
        key = "battleforgilneas",
        zone = L.zone["The Battle for Gilneas"],
        category = L.zone["Battlegrounds"],
        template = "Base resource race",
        name = "The Battle for Gilneas",
        victorytext = "the Battle for Gilneas",
        triggers = {
            bg_neutral = "The Battle for Gilneas has begun",
        },
        onactivate = {
            counters = {"basestoattackcounter","basestohavecounter"},
            tracerstart = false,
            combatstop = false,
            combatstart = false,
        },
        userdata = {
            
        },
        onstart = {
            {
                "quash","bgstartcd",
            },
        },
        battleground = {
            modules = {
                score = {
                    finalScore = 2000,
                    pattern = "^.+Resources: (%d+)/2000$",
                },
                POI = {
                    categories = {
                        bases = {
                            ["Lighthouse"] = {slot = 1, POIs = {6,9,12,11,10},   chat = "lighthouse"},
                            ["Waterworks"] = {slot = 2, POIs = {26,27,29,28,30}, chat = "waterworks"},
                            ["Mines"]      = {slot = 3, POIs = {16,17,19,18,20}, chat = "mine"},
                        },
                    },
                },
            },
            establishWinner = {
                pointIncrements = {10,10,30},
                nextPoints = {9,3,1},
            },
            slots = {
                count = 3,
                texts = {"Lighthouse","Waterworks","Mines"},
                actions = {
                    {"base-help","Lighthouse"},
                    {"base-help","Waterworks"},
                    {"base-help","Mines"},
                },
                height = 37,
            },
            events = {
                -- Battleground Start timer
                {
                    event = "START_TIMER_UPDATE",
                    execute = {
                        {
                            "expect",{"&timeleft|bgstartcd&","==","-1"},
                            "alert","bgstartcd",
                        },
                    },
                },
                -- Not Enough Players
                {
                    event = "NOT_ENOUGH_PLAYERS",
                    execute = {
                        {
                            "alert",{"notenougplayerscd",timeexact = "<TimeOut>"},
                        },
                    },
                },
                {
                    event = "ENOUGH_PLAYERS",
                    execute = {
                        {
                            "quash","notenougplayerscd",
                        },
                    },
                },
                -- A base gets claimed or assaulted
                {
                    event = {"BASE_ASSAULTED","BASE_CLAIMED"},
                    execute = {
                        {
                            "expect",{"<Faction>","==","alliance"},
                            "quash",{"allianceassaultcd","<Location>"},
                            "quash",{"hordeassaultcd","<Location>"},
                            "alert","allianceassaultcd",
                        },
                        {
                            "expect",{"<Faction>","==","horde"},
                            "quash",{"allianceassaultcd","<Location>"},
                            "quash",{"hordeassaultcd","<Location>"},
                            "alert","hordeassaultcd",
                        },
                    },
                },
                -- A base is taken
                {
                    event = "BASE_TAKEN",
                    execute = {
                        {
                            "expect",{"<Faction>","==","alliance"},
                            "quash",{"hordeassaultcd","<Location>"},
                        },
                        {
                            "expect",{"<Faction>","==","horde"},
                            "quash",{"allianceassaultcd","<Location>"},
                        },
                    },
                },
                {
                    event = "FACTION_LEADS",
                    execute = {
                        {
                            "set",{AnnounceWinFaction = "&capitalize|<WinFactionPure>&"}
                        },
                        -- Alliance takes the lead
                        {
                            "expect",{"<WinFaction>","==","alliance"},
                            "batchquash",{"alliancewincd","hordewincd"},
                            "alert",{"alliancewincd", timeexact = "<WinTime>"},
                        },
                        -- Horde takes the lead
                        {
                            "expect",{"<WinFaction>","==","horde"},
                            "batchquash",{"alliancewincd","hordewincd"},
                            "alert",{"hordewincd", timeexact = "<WinTime>"},
                        },
                    },
                },
            },
        },
        counters = {
            basestoattackcounter = {
                variable = "BasesToAttack",
                label = "Bases to attack",
                pattern = "%d",
                value = 0,
                minimum = 0,
                maximum = 0,
            },
            basestohavecounter = {
                variable = "BasesToTake",
                label = "Bases to have",
                pattern = "%d",
                value = 0,
                minimum = 0,
                maximum = 0,
            },
        },
        
        phrasecolors = {
            {"%(%d+","GOLD","Predicted Score (Left)"},
            {"%d+%)","GOLD","Predicted Score (Right)"},
        },
        ordering = {
            alerts = {"bgstartcd","notenougplayerscd","alliancewincd","hordewincd","allianceassaultcd","hordeassaultcd"},
        },
        
        alerts = {
            -- Battleground Start
            bgstartcd = {
                varname = format("%s Countdown",L.alert["Battleground Start"]),
                type = "dropdown",
                text = format(L.alert["Battleground starts"]),
                time = "<StartTime>",
                flashtime = 20,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Misc_Trophy_Argent",
                behavior = "overwrite",
                audiocd = true,
            },
            -- Not Enough Players
            notenougplayerscd = {
                varname = format("%s Countdown",L.alert["Not Enough Players"]),
                type = "dropdown",
                text = format(L.alert["Not enough players"]),
                time = 300,
                flashtime = 10,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_EVERYONES A HERO_RANK2",
                behavior = "overwrite",
            },
            -- Alliance wins (prediction)
            alliancewincd = {
                varname = format(L.alert["%s Countdown"],"Alliance (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins %s"],"Alliance","<ScorePrediction>"),
                announcetext = format(L.alert["%s wins %s"],"<AnnounceWinFaction>","<ScorePrediction>"),
                time = 1920, -- estimated maximum
                flashtime = 10,
                color1 = "BLUE",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Alliance",
            },
            -- Horde wins (prediction)
            hordewincd = {
                varname = format(L.alert["%s Countdown"],"Horde (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins %s"],"Horde","<ScorePrediction>"),
                announcetext = format(L.alert["%s wins %s"],"<AnnounceWinFaction>","<ScorePrediction>"),
                time = 1920, -- estimated maximum
                flashtime = 10,
                color1 = "BROWN",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Horde",
            },
            -- Alliance assaults base
            allianceassaultcd = {
                varname = format(L.alert["%s Countdown"],"Alliance Assaults Base"),
                type = "dropdown",
                text = format(L.alert["%s"],"<Location>"),
                announcetext = format(L.alert["%s captures %s"],"Alliance","<Location>"),
                time = 60,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "TURQUOISE",
                sound = "None",
                icon = "Interface\\ICONS\\Achievement_PVP_A_16",
                tag = "<Location>",
            },
            -- Horde assaults base
            hordeassaultcd = {
                varname = format(L.alert["%s Countdown"],"Horde Assaults Base"),
                type = "dropdown",
                text = format(L.alert["%s"],"<Location>"),
                announcetext = format(L.alert["%s captures %s"],"Horde","<Location>"),
                time = 60,
                flashtime = 5,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Inv_Misc_Tournaments_banner_Orc",
                tag = "<Location>",
            },
        },
    }
    
    addon:RegisterBattleground(data)
end

---------------------------------
-- EYE OF THE STORM
---------------------------------
do
    local ConstructCarrierText = function(carrierText,carrier, faction)
        local bases = BattlegroundAPI:GetData("baseData")[faction].bases
        if bases > 0 and ItemValue("showflagpoints") == "true" then
            local flagValues = BattlegroundAPI:GetAttribute("modules","flags","pointValues")
            return format("%s\n+ %d points",carrierText,flagValues[bases])
        else
            return carrierText
        end
    end
    
    local BaseIndexGuide = {1,2,3,4,5}
    local DirectionToSlotIndexSet = {
        ["N"] = {1,2,nil,4,5},
        ["S"] = {5,4,nil,2,1},
        ["W"] = {2,5,nil,1,4},
        ["E"] = {4,1,nil,5,2},
    }
    
    local direction = "N"
    
    local function UpdatePlayerFacing()
        local facing = GetPlayerFacing()
        local newDirection
        
        if (facing >= 0 and facing <= math.pi/4) or (facing <= 2*math.pi and facing > 7*math.pi/4) then
            newDirection = "N"
        elseif facing > math.pi/4 and facing <= 3*math.pi/4 then
            newDirection = "W"
        elseif facing > 3*math.pi/4 and facing <= 5*math.pi/4 then
            newDirection = "S"
        else
            newDirection = "E"
        end
        
        if direction ~= newDirection then
            direction = newDirection
            for slotIndex=1,5 do
                if ItemValue("rotatebasenames") == "true" then
                    BaseIndexGuide[slotIndex] = DirectionToSlotIndexSet[direction][slotIndex]
                else
                    BaseIndexGuide[slotIndex] = slotIndex
                end
            end
            BattlegroundAPI:RefreshSlots()
        end
    end
    
    local data = {
        version = 2,
        key = "eyeofthestorm",
        zone = L.zone["Eye of the Storm"],
        category = L.zone["Battlegrounds"],
        template = "Base resource race",
        name = "Eye of the Storm",
        triggers = {
            bg_neutral = "The Battle for Eye of the Storm has begun!",
        },
        onactivate = {
            counters = {"basestoattackcounter","basestohavecounter"},
            tracerstart = false,
            combatstop = false,
            combatstart = false,
        },
        userdata = {
            
        },
        onstart = {
            {
                "quash","bgstartcd",
                "repeattimer",{"updateplayerfacing", 0.1},
            },
        },
        battleground = {
            modules = {
                score = {
                    finalScore = 1600,
                    indexes = {alliance = 2, horde = 3},
                    pattern = "^Bases: %d  Victory Points: (%d+)/1600$",
                },
                flags = {
                    statesBroken = true,
                    singleFlag = true,
                    slots = {alliance = 3, horde = 3},
                    chat = {
                        channel = "chat-battleground",
                        triggers = {
                            {
                                event = "FLAG_PICKED_UP",
                                pattern = "^(%w+) has taken the flag!$",
                                vars = {"FlagCarrier"},
                                swapFactions = true,
                            },
                            {
                                event = "FLAG_CAPTURED",
                                pattern = "^The (%w+) have captured the [Ff]lag!$",
                                vars = {"_Faction_"},
                            },
                            {
                                event = "FLAG_DROPPED",
                                pattern = "^The [Ff]lag has been dropped.$",
                                swapFactions = true,
                            },
                            {
                                event = "FLAG_RESET",
                                pattern = "^The [Ff]lag has been reset",
                            },
                        },
                    },
                    texts = {
                        spawn = " <Flag> \n<Location>",
                        carrier = ConstructCarrierText,
                    },
                    returnTime = 8,
                    respawnTime = 8,
                    pointValues = {75,85,100,500},
                },
                POI = {
                    categories = {
                        bases = {
                            ["Mage Tower"]       = {slot = 1, POIs = {6,11,10}},
                            ["Fel Reaver Ruins"] = {slot = 2, POIs = {6,11,10}},
                            ["Draenei Ruins"]    = {slot = 4, POIs = {6,11,10}},
                            ["Blood Elf Tower"]  = {slot = 5, POIs = {6,11,10}},
                        },
                    },
                    states = {
                        bases = {
                            {faction = "none",     status = "neutral",    flashing = "opposite", color = "unknown"},
                            {faction = "alliance", status = "controlled", flashing = "",         color = "alliance"},
                            {faction = "horde",    status = "controlled", flashing = "",         color = "horde"},
                        },
                    },
                    texts = ConstructBaseText,
                },
            },  
            establishWinner = {
                pointIncrements = {1,2,5,10},
                nextPoints = 2.005,
                noStableUpdate = true,
            },
            slots = {
                count = 5,
                texts = {
                    [1] = "Mage Tower",   [2] = "Fel Reaver Ruins",
                    [4] = "Draenei Ruins",[5] = "Blood Elf Tower"
                },
                actions = {
                    [1] = {"base-help","Mage Tower"},    [2] = {"base-help","Fel Reaver Ruins"},
                    [4] = {"base-help","Draenei Ruins"}, [5] = {"base-help","Blood Elf Tower"},
                },
                indexGuide = BaseIndexGuide,
                disallowFactionSwitching = true,
                widthmult = {2,2,3,2,2},
                height = {37,37,74,37,37},
                offsetmults = {
                    {2, 0, 0, 0, -2},
                    {0,-1, 0, 0, -1},
                },
                offsets = {
                    {0, 0, 0, 0, 0},
                    {-10, -10, -10, -10, -10},
                },
            },
            events = {
                -- Battleground Start timer
                {
                    event = "START_TIMER_UPDATE",
                    execute = {
                        {
                            "expect",{"&timeleft|bgstartcd&","==","-1"},
                            "alert","bgstartcd",
                        },
                    },
                },
                -- Not Enough Players
                {
                    event = "NOT_ENOUGH_PLAYERS",
                    execute = {
                        {
                            "alert",{"notenougplayerscd",timeexact = "<TimeOut>"},
                        },
                    },
                },
                {
                    event = "ENOUGH_PLAYERS",
                    execute = {
                        {
                            "quash","notenougplayerscd",
                        },
                    },
                },
                {
                    event = "FACTION_LEADS",
                    execute = {
                        {
                            "set",{AnnounceWinFaction = "&capitalize|<WinFactionPure>&"}
                        },
                        -- Alliance takes the lead
                        {
                            "expect",{"<WinFaction>","==","alliance"},
                            "batchquash",{"alliancewincd","hordewincd"},
                            "alert",{"alliancewincd", timeexact = "<WinTime>"},
                        },
                        -- Horde takes the lead
                        {
                            "expect",{"<WinFaction>","==","horde"},
                            "batchquash",{"alliancewincd","hordewincd"},
                            "alert",{"hordewincd", timeexact = "<WinTime>"},
                        },
                    },
                },
                -- Flag Picked Up
                {
                    event = "FLAG_PICKED_UP",
                    execute = {
                        {
                            "arrow","flagarrow",
                            "expect",{"<FlagCarrier>","==","&playername&"},
                            "range",{true},
                            "radar","magetowerflagpostradar",
                            "radar","draeneiruinsflagpostradar",
                            "radar","bloodelftowerflagpostradar",
                            "radar","felreaverruinsflagpostradar",
                        },
                    },
                },
                -- Flag Dropped
                {
                    event = "FLAG_DROPPED",
                    execute = {
                        {
                            "removeallarrows",true,
                            "removeradar","magetowerflagpostradar",
                            "removeradar","draeneiruinsflagpostradar",
                            "removeradar","bloodelftowerflagpostradar",
                            "removeradar","felreaverruinsflagpostradar",
                            "range",{false},
                        },
                    },
                },
                -- Flag Captured
                {
                    event = "FLAG_CAPTURED",
                    execute = {
                        {
                            "removeallarrows",true,
                            "alert","flagsrespawncd",
                            "removeradar","magetowerflagpostradar",
                            "removeradar","draeneiruinsflagpostradar",
                            "removeradar","bloodelftowerflagpostradar",
                            "removeradar","felreaverruinsflagpostradar",
                            "range",{false},
                        },
                    },
                },
            },
        },
        
        misc = {
            name = format("|T%s:16:16|t %s",ST[2481],L.chat_battleground["Score Panel"]),
            args = {
                rotatebasenames = {
                    name = format(L.chat_battleground["|T%s:16:16|t Rotate the base names based on player's orientation."],AT[6151]),
                    type = "toggle",
                    order = 1,
                    default = true,
                },
                showflagpoints = {
                    name = format(L.chat_battleground["|T%s:16:16|t Include point gain for a flag."],"Interface\\ICONS\\Achievement_BG_3flagcap_nodeaths"),
                    type = "toggle",
                    order = 2,
                    default = true,
                },
            },
        },
        radars = {
            magetowerflagpostradar = {
                varname = "Mage Tower Flag Post",
                type = "circle",
                x = 0.40914350748062,
                y = 0.41857713460922,
                range = 3,
                exactrange = true,
                mode = "avoid",
                icon = "Interface\\ICONS\\Achievement_BG_KillFlagCarriers_grabFlag_CapIt",
            },
            draeneiruinsflagpostradar = {
                varname = "Draenei Ruins Flag Post",
                type = "circle",
                x = 0.55400657653809,
                y = 0.41740185022354,
                range = 3,
                exactrange = true,
                mode = "avoid",
                icon = "Interface\\ICONS\\Achievement_BG_KillFlagCarriers_grabFlag_CapIt",
            },
            bloodelftowerflagpostradar = {
                varname = "Blood Elf Tower Flag Post",
                type = "circle",
                x = 0.55786418914795,
                y = 0.57459366321564,
                range = 3,
                exactrange = true,
                mode = "avoid",
                icon = "Interface\\ICONS\\Achievement_BG_KillFlagCarriers_grabFlag_CapIt",
            },
            felreaverruinsflagpostradar = {
                varname = "Fel Reaver Ruins Flag Post",
                type = "circle",
                x = 0.40984362363815,
                y = 0.57755160331726,
                range = 3,
                exactrange = true,
                mode = "avoid",
                icon = "Interface\\ICONS\\Achievement_BG_KillFlagCarriers_grabFlag_CapIt",
            },
        },
        arrows = {
			flagarrow = {
				varname = format("Own Flag Carrier"),
				unit = "<FlagCarrier>",
				persist = 3600,
				action = "TOWARD",
				msg = L.alert["Protect"],
				spell = "Flag carrier",
				sound = "None",
                range1 = 40,
                range2 = 60,
                range3 = 100,
                texture = ST[34976],
			},
		},
        
        phrasecolors = {
            {"%(%d+","GOLD","Predicted Score (Left)"},
            {"%d+%)","GOLD","Predicted Score (Right)"},
        },
        windows = {
            proxwindow = true,
            proxnoauto = true,
            proxnoautostart = true,
            proxrange = 10,
            proxoverride = true,
            nodistancecheck = true,
        },
        functions = {
            updateplayerfacing = UpdatePlayerFacing,
        },
        ordering = {
            alerts = {"bgstartcd","notenougplayerscd","alliancewincd","hordewincd","flagsrespawncd"},
        },
        
        alerts = {
            -- Battleground Start
            bgstartcd = {
                varname = format("%s Countdown",L.alert["Battleground Start"]),
                type = "dropdown",
                text = format(L.alert["Battleground starts"]),
                time = "<StartTime>",
                flashtime = 20,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Misc_Trophy_Argent",
                behavior = "overwrite",
                audiocd = true,
            },
            -- Not Enough Players
            notenougplayerscd = {
                varname = format("%s Countdown",L.alert["Not Enough Players"]),
                type = "dropdown",
                text = format(L.alert["Not enough players"]),
                time = 300,
                flashtime = 10,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_EVERYONES A HERO_RANK2",
                behavior = "overwrite",
            },
            -- Alliance wins (prediction)
            alliancewincd = {
                varname = format(L.alert["%s Countdown"],"Alliance (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins %s"],"Alliance","<ScorePrediction>"),
                announcetext = format(L.alert["%s wins %s"],"<AnnounceWinFaction>","<ScorePrediction>"),
                time = 1920, -- estimated maximum
                flashtime = 10,
                color1 = "BLUE",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Alliance",
            },
            -- Horde wins (prediction)
            hordewincd = {
                varname = format(L.alert["%s Countdown"],"Horde (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins %s"],"Horde","<ScorePrediction>"),
                announcetext = format(L.alert["%s wins %s"],"<AnnounceWinFaction>","<ScorePrediction>"),
                time = 1920, -- estimated maximum
                flashtime = 10,
                color1 = "BROWN",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Horde",
            },
            -- Flags respawn
            flagsrespawncd = {
                varname = format(L.alert["%s Countdown"],"Flags' Respawn"),
                type = "dropdown",
                text = format(L.alert["%s"],"Flags respawning"),
                time = 8,
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "Off",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Ability_Racial_ShadowMeld",
            },
        },
        timers = {
            updateplayerfacing = {
                {
                    "execute","updateplayerfacing",
                },
            },
        },
    }
    
    addon:RegisterBattleground(data)
end

---------------------------------
-- ALTERAC VALLEY
---------------------------------
do
    local data = {
        version = 2,
        key = "alteracvalley",
        zone = L.zone["Alterac Valley"],
        category = L.zone["Battlegrounds"],
        template = "Stronghold siege",
        name = "Alterac Valley",
        triggers = {
            bg_neutral = "The Battle for Alterac Valley has begun",
        },
        onactivate = {
            tracerstart = false,
            combatstop = false,
            combatstart = false,
        },
        userdata = {
            AssaultedTowers = {type = "container"},
        },
        onstart = {
            {
                "quash","bgstartcd",
            },
        },
        battleground = {
            modules = {
                score = {
                    indexes = {alliance = 1, horde = 2},
                    parameterIndex = 4,
                    pattern = "Reinforcements: (%d+)",
                    statesBroken = true,
                    maxScore = 600,
                },
                POI = {
                    categories = {
                        towers = {
                            -- Alliance towers
                            ["Dun Baldar South Bunker"] = {slot = 2,  POIs = {11, 10, 6, 9, 12}, chat = {"The Dun Baldar South Bunker","Dun Baldar South Bunker (4)"}},
                            ["Dun Baldar North Bunker"] = {slot = 3,  POIs = {11, 10, 6, 9, 12}, chat = {"The Dun Baldar North Bunker","Dun Baldar North Bunker (3)"}},
                            ["Icewing Bunker"]          = {slot = 6,  POIs = {11, 10, 6, 9, 12}, chat = {"The Icewing Bunker","Icewing Bunker (2)"}},
                            ["Stonehearth Bunker"]      = {slot = 8,  POIs = {11, 10, 6, 9, 12}, chat = {"The Stonehearth Bunker","Stonehearth Bunker (1)"}},
                            
                            -- Horde towers
                            ["Iceblood Tower"]          = {slot = 10, POIs = {11, 10, 6, 9, 12}, chat = {"Iceblood Tower","Iceblood Tower (1)"}},
                            ["Tower Point"]             = {slot = 12, POIs = {11, 10, 6, 9, 12}, chat = {"Tower Point",   "Tower Point (2)"}},
                            ["West Frostwolf Tower"]    = {slot = 15, POIs = {11, 10, 6, 9, 12}, chat = {"The West Frostwolf Tower", "West Frostwolf Tower (3)"}},
                            ["East Frostwolf Tower"]    = {slot = 16, POIs = {11, 10, 6, 9, 12}, chat = {"The East Frostwolf Tower", "East Frostwolf Tower (4)"}},
                        },
                        graveyards = {
                            -- Alliance graveyards
                            ["Stormpike Aid Station"]   = {slot = 1,  POIs = {15, 13, 8, 4, 14}, chat = {"Stormpike Aid Station","Stormpike Aid Station (3)"}},
                            ["Stormpike Graveyard"]     = {slot = 4,  POIs = {15, 13, 8, 4, 14}, chat = {"Stormpike Graveyard","Stormpike Graveyard (2)"}},
                            ["Stonehearth Graveyard"]   = {slot = 7,  POIs = {15, 13, 8, 4, 14}, chat = {"Stonehearth Graveyard","Stonehearth Graveyard (1)"}},
                            
                            -- Neutral graveyard
                            ["Snowfall Graveyard"]      = {slot = 9,  POIs = {15, 13, 8, 4, 14}},
                            
                            -- Horde graveyards
                            ["Iceblood Graveyard"]      = {slot = 11, POIs = {15, 13, 8, 4, 14}, chat = {"Iceblood Graveyard","Iceblood Graveyard (1)"}},
                            ["Frostwolf Graveyard"]     = {slot = 14, POIs = {15, 13, 8, 4, 14}, chat = {"Frostwolf Graveyard","Frostwolf Graveyard (2)"}},
                            ["Frostwolf Relief Hut"]    = {slot = 17, POIs = {15, 13, 8, 4, 14}, chat = {"Frostwolf Relief Hut","Frostwolf Relief Hut (3)"}},
                            ["Frostwolf Relief Hut"]    = {slot = 17, POIs = {15, 13, 8, 4, 14}, chat = {"Frostwolf Relief Hut","Frostwolf Relief Hut (3)"}},
                        },
                        mines = {
                            ["Coldtooth Mine"]          = {slot = 13, POIs = {3, 2, 1}},
                            ["Irondeep Mine"]           = {slot = 5,  POIs = {3, 2, 1}},
                        },
                    },
                    states = {
                        towers = {
                            {faction = "alliance", status = "controlled"},
                            {faction = "horde",    status = "controlled"},
                            {faction = "none",     status = "destroyed"},
                            {faction = "alliance", status = "attacked"},
                            {faction = "horde",    status = "attacked"},
                        },
                        graveyards = {
                            {faction = "alliance", status = "controlled"},
                            {faction = "horde",    status = "controlled"},
                            {faction = "none",     status = "neutral"},
                            {faction = "alliance", status = "attacked"},
                            {faction = "horde",    status = "attacked"},
                        },
                        mines = {
                            {faction = "alliance", status = "controlled"},
                            {faction = "horde",    status = "controlled"},
                            {faction = "none",     status = "neutral"},
                        },
                    },
                    chat = {
                        channel = "yell",
                        triggers = {
                            {
                                event = "GRAVEYARD_ASSAULTED",
                                pattern = "^The ([%a ]+) is under attack!  If left unchecked, the (%w+) will capture it!$",
                                vars = {"Location","_Faction_"},
                            },
                            {
                                event = "GRAVEYARD_DEFENDED",
                                pattern = "^The ([%a ]+) was taken by the (%w+).+$",
                                vars = {"Location","_Faction_"},
                            },
                            {
                                event = "TOWER_ASSAULTED",
                                pattern = "^([%a ]+) is under attack!  If left unchecked, the (%w+) will destroy it!$",
                                vars = {"Location","_Faction_"},
                            },
                            {
                                event = "TOWER_DEFENDED",
                                pattern = "^([%a ]+) was taken by the (%w+)!$",
                                vars = {"Location","_Faction_"},
                            },
                        },
                    },
                },
            },
            slots = {
                count = 17,
                widthmult = 1.2,
                textOnly = true,
                offsets = {5,-5},
                height = 37,
            },
            events = {
                 -- Battleground Start timer
                {
                    event = "START_TIMER_UPDATE",
                    execute = {
                        {
                            "expect",{"&timeleft|bgstartcd&","==","-1"},
                            "alert","bgstartcd",
                        },
                    },
                },
                -- Not Enough Players
                {
                    event = "NOT_ENOUGH_PLAYERS",
                    execute = {
                        {
                            "alert",{"notenougplayerscd",timeexact = "<TimeOut>"},
                            "set",{
                                BattlegroundShutdown = "yes",
                                AnnounceWinFaction = "&capitalize|<WinFactionPure>&",
                            },
                            
                        },
                        {
                            "expect",{"<WinFaction>","==","alliance"},
                            "expect",{"&timeleft|alliancewincd&","==","-1"},
                            "quash","hordewincd",
                            "alert",{"alliancewincd", timeexact = "<TimeOut>"},
                        },
                        {
                            "expect",{"<WinFaction>","==","horde"},
                            "expect",{"&timeleft|hordewincd&","==","-1"},
                            "quash","alliancewincd",
                            "alert",{"hordewincd", timeexact = "<TimeOut>"},
                        },
                    },
                },
                {
                    event = "ENOUGH_PLAYERS",
                    execute = {
                        {
                            "quash","notenougplayerscd",
                            "set",{BattlegroundShutdown = "no"},
                        },
                        {
                            "quash","alliancewincd",
                            "quash","hordewincd",
                        },
                    },
                },
                -- A faction takes lead
                {
                    event = "FACTION_LEADS",
                    execute = {
                        {
                            "set",{AnnounceWinFaction = "&capitalize|<WinFactionPure>&"}
                        },
                        {
                            "expect",{"<BattlegroundShutdown>","==","yes"},
                            "expect",{"<WinFaction>","==","alliance"},
                            "expect",{"&timeleft|alliancewincd&","==","-1"},
                            "batchquash",{"bgendcd","hordewincd"},
                            "alert",{"alliancewincd", timeexact = "&getbattlegroundshutdowntime&"},
                        },
                        {
                            "expect",{"<BattlegroundShutdown>","==","yes"},
                            "expect",{"<WinFaction>","==","horde"},
                            "expect",{"&timeleft|hordewincd&","==","-1"},
                            "batchquash",{"bgendcd","alliancewincd"},
                            "alert",{"hordewincd", timeexact = "&getbattlegroundshutdowntime&"},
                        },
                    },
                },
                -- Draw expected
                {
                    event = "DRAW_STATE",
                    execute = {
                        {
                            "batchquash",{"alliancewincd","hordewincd"},
                        },
                    },
                },
                -- A graveyard is claimed or assaulted
                {
                    event = "GRAVEYARD_ASSAULTED",
                    execute = {
                        {
                            "expect",{"<Faction>","==","alliance"},
                            "quash",{"alliancegraveyardcd","<LocationPure>"},
                            "alert","hordegraveyardcd",
                        },
                        {
                            "expect",{"<Faction>","==","horde"},
                            "quash",{"hordegraveyardcd","<LocationPure>"},
                            "alert","alliancegraveyardcd",
                        },
                    },
                },
                -- A graveyard was defended
                {
                    event = "GRAVEYARD_DEFENDED",
                    execute = {
                        {
                            "expect",{"<Faction>","==","alliance"},
                            "quash",{"alliancegraveyardcd","<LocationPure>"},
                        },
                        {
                            "expect",{"<Faction>","==","horde"},
                            "quash",{"hordegraveyardcd","<LocationPure>"},
                        },
                    },
                },
                -- A base gets claimed or assaulted
                {
                    event = "TOWER_ASSAULTED",
                    execute = {
                        {
                            "expect",{"<Faction>","==","alliance"},
                            "invoke",{
                                {
                                    "expect",{"&listcontains|AssaultedTowers|<Location>&","==","true"},
                                    "alert","hordetowercd",
                                },
                                {
                                    "expect",{"&listcontains|AssaultedTowers|<Location>&","==","false"},
                                    "insert",{"AssaultedTowers","<Location>"},
                                    "alert",{"hordetowercd",time = 2},
                                },
                            },
                        },
                        {
                            "expect",{"<Faction>","==","horde"},
                            "invoke",{
                                {
                                    "expect",{"&listcontains|AssaultedTowers|<Location>&","==","true"},
                                    "alert","alliancetowercd",
                                },
                                {
                                    "expect",{"&listcontains|AssaultedTowers|<Location>&","==","false"},
                                    "insert",{"AssaultedTowers","<Location>"},
                                    "alert",{"alliancetowercd",time = 2},
                                },
                            },
                        },
                    },
                },
                {
                    event = "TOWER_DEFENDED",
                    execute = {
                        {
                            "expect",{"<Faction>","==","alliance"},
                            "quash",{"alliancetowercd","<LocationPure>"},
                        },
                        {
                            "expect",{"<Faction>","==","horde"},
                            "quash",{"hordetowercd","<LocationPure>"},
                        },
                    },
                },
            },
            canDraw = true,
        },
        
        phrasecolors = {
            {"Iceblood Tower","WHITE"}, 
            {"Tower Point","WHITE"},
            {"West Frostwolf Tower","WHITE"},
            {"East Frostwolf Tower","WHITE"},
            {"Dun Baldar North Bunker","WHITE"},
            {"Dun Baldar South Bunker","WHITE"},
            {"Icewing Bunker","WHITE"},
            {"Stonehearth Bunker","WHITE"},
            
            {"Iceblood Graveyard","GOLD"},
            {"Frostwolf Graveyard","GOLD"},
            {"Frostwolf Relief Hut","GOLD"},
            {"Stonehearth Graveyard","GOLD"},
            {"Stormpike Aid Station","GOLD"},
            {"Stormpike Graveyard","GOLD"},
            {"Snowfall Graveyard","GOLD"},
        },
        
        ordering = {
            alerts = {"bgstartcd","notenougplayerscd","alliancewincd","hordewincd","hordetowercd","alliancetowercd","hordegraveyardcd","alliancegraveyardcd"},
        },
        
        alerts = {
            -- Battleground Start
            bgstartcd = {
                varname = format("%s Countdown",L.alert["Battleground Start"]),
                type = "dropdown",
                text = format(L.alert["Battleground starts"]),
                time = "<StartTime>",
                flashtime = 20,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Misc_Trophy_Argent",
                behavior = "overwrite",
                audiocd = true,
            },
            -- Not Enough Players
            notenougplayerscd = {
                varname = format("%s Countdown",L.alert["Not Enough Players"]),
                type = "dropdown",
                text = format(L.alert["Not enough players"]),
                time = 300,
                flashtime = 10,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_EVERYONES A HERO_RANK2",
                behavior = "overwrite",
            },
            -- Alliance wins (prediction)
            alliancewincd = {
                varname = format(L.alert["%s Countdown"],"Alliance (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins"],"Alliance"),
                announcetext = format(L.alert["%s wins"],"<AnnounceWinFaction>"),
                time = 300,
                flashtime = 10,
                color1 = "BLUE",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Alliance",
            },
            -- Horde wins (prediction)
            hordewincd = {
                varname = format(L.alert["%s Countdown"],"Horde (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins"],"Horde"),
                announcetext = format(L.alert["%s wins"],"<AnnounceWinFaction>"),
                time = 300,
                flashtime = 10,
                color1 = "BROWN",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Horde",
            },
            -- Capture Horde Tower
            hordetowercd = {
                varname = format(L.alert["%s Countdown"],"Capture Horde Tower"),
                type = "dropdown",
                text = format(L.alert["%s"],"<Location>"),
                announcetext = format(L.alert["%s destroys %s"],"<FactionCapitalized>","<Location>"),
                time = 240,
                time2 = 300,
                flashtime = 20,
                color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Achievement_PVP_A_16",
                tag = "<LocationPure>",
            },
            -- Capture Alliance Tower
            alliancetowercd = {
                varname = format(L.alert["%s Countdown"],"Capture Alliance Tower"),
                type = "dropdown",
                text = format(L.alert["%s"],"<Location>"),
                announcetext = format(L.alert["%s destroys %s"],"<FactionCapitalized>","<Location>"),
                time = 240,
                time2 = 300,
                flashtime = 20,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Inv_Misc_Tournaments_banner_Orc",
                tag = "<LocationPure>",
            },
            -- Capture Horde Graveyard 
            hordegraveyardcd = {
                varname = format(L.alert["%s Countdown"],"Capture Horde Graveyard"),
                type = "dropdown",
                text = format(L.alert["%s"],"<Location>"),
                announcetext = format(L.alert["%s captures %s"],"<FactionCapitalized>","<Location>"),
                time = 240,
                flashtime = 20,
                color1 = "TURQUOISE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Inv_Misc_Tournaments_Tabard_Human",
                tag = "<LocationPure>",
            },
            -- Capture Alliance Graveyard 
            alliancegraveyardcd = {
                varname = format(L.alert["%s Countdown"],"Capture Alliance Graveyard"),
                type = "dropdown",
                text = format(L.alert["%s"],"<Location>"),
                announcetext = format(L.alert["%s captures %s"],"<FactionCapitalized>","<Location>"),
                time = 240,
                flashtime = 20,
                color1 = "ORANGE",
                color2 = "TAN",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Inv_Misc_Tournaments_Tabard_Orc",
                tag = "<LocationPure>",
            },
            
        },
    }
    
    addon:RegisterBattleground(data)
end

---------------------------------
-- ISLE OF CONQUEST
---------------------------------
do
    local data = {
        version = 2,
        key = "isleofconquest",
        zone = L.zone["Isle of Conquest"],
        category = L.zone["Battlegrounds"],
        template = "Stronghold siege",
        name = "Isle of Conquest",
        triggers = {
            bg_neutral = "The battle has begun",
        },
        onactivate = {
            tracerstart = false,
            combatstop = false,
            combatstart = false,
        },
        userdata = {
            AssaultedTowers = {type = "container"},
        },
        onstart = {
            {
                "quash","bgstartcd",
            },
        },
        battleground = {
            modules = {
                score = {
                    indexes = {alliance = 1, horde = 2},
                    parameterIndex = 4,
                    pattern = "Reinforcements: (%d+)",
                    statesBroken = true,
                    maxScore = 300,
                },
                POI = {
                    categories = {
                        gates = {
                            ["Alliance Gate"] = {slot = {4,2,3},    landmarkIndex = {1,2,3},  POIs = {80,82,77,79}},
                            ["Horde Gate"]    = {slot = {11,12,10}, landmarkIndex = {7,8,9},  POIs = {80,82,77,79}},
                        },
                        keeps = {
                            ["Alliance Keep"] = {slot = 1,          landmarkIndex = 4,        POIs = {11,10,9,12}, chat = {"the Alliance keep","Alliance keep"}},
                            ["Horde Keep"]    = {slot = 13,         landmarkIndex = 10,       POIs = {11,10,9,12}, chat = {"the Horde keep","Horde keep"}},
                        },
                        bases = {
                            ["Docks"]         = {slot = 6,          landmarkIndex = 5,        POIs = {145,147,149,146,148}},
                            ["Hangar"]        = {slot = 8,          landmarkIndex = 6,        POIs = {140,142,144,141,143}},
                            ["Quarry"]        = {slot = 9,          landmarkIndex = 11,       POIs = {16,17,19,18,20}},
                            ["Rafinery"]      = {slot = 5,          landmarkIndex = 12,       POIs = {150,152,154,151,153}},
                            ["Workshop"]      = {slot = 7,          landmarkIndex = 13,       POIs = {135,137,139,136,138}},
                        },
                    },
                    states = {
                        gates = {
                            {faction = "alliance", status = "standing"},
                            {faction = "alliance", status = "destroyed"},
                            {faction = "horde",    status = "standing"},
                            {faction = "horde",    status = "destroyed"},
                        },
                        keeps = {
                            {faction = "alliance", status = "controlled"},
                            {faction = "horde",    status = "controlled"},
                            {faction = "alliance", status = "attacked"},
                            {faction = "horde",    status = "attacked"},
                        },
                        bases = {
                            {faction = "none",     status = "neutral"},
                            {faction = "alliance", status = "attacked",   flashing = "alliance"},
                            {faction = "horde",    status = "attacked",   flashing = "horde"},
                            {faction = "alliance", status = "controlled", flashing = "", color = "alliance"},
                            {faction = "horde",    status = "controlled", flashing = "", color = "horde"},
                        },
                    },
                    chat = {
                        channel = "chat-battleground",
                        triggers = {
                            {
                                event = "POINT_ASSAULTED",
                                pattern = "^(%w+) claims the ([%a ]+)! If left unchallenged, the (%w+) will control it in 1 minute!$",
                                vars = {"AssaultPlayer","Location","_Faction_"},
                            },
                            {
                                event = "POINT_DEFENDED",
                                pattern = "^(%w+) has defended the ([%a ]+)$",
                                vars = {"Player","Location"},
                            },
                        },
                    },
                },
            },
            slots = {                
                count = 13,
                texts = {
                    [5] = "Rafinery",
                    [6] = "Docks",
                    [7] = "Workshop",
                    [8] = "Hangar",
                    [9] = "Quarry",
                },
                actions = {
                    [5] = {"base-help","Rafinery"},
                    [6] = {"base-help","Docks"},
                    [7] = {"base-help","Workshop"},
                    [8] = {"base-help","Hangar"},
                    [9] = {"base-help","Quarry"},
                },
                widthmult = {1.5,1.5,1.5,1.5,3,3,3,3,3,1.5,1.5,1.5,1.5},
                offsetmults = {
                    {[1] = 3, [13] = -3,},
                    {[1] = 1, [2] = 1, [4] = 1, [10] = 1, [12] = 1, [13] = 1},
                },
                iconSizes = {[1] = 40, [13] = 40},
                textOnly = {true,true,true,true,false,false,false,false,false,true,true,true,true},
                height = 37,
                factionSwitchingIndex = {13,10,11,12,9,8,7,6,5,2,3,4,1},
            },
            events = {
                -- Battleground Start timer
                {
                    event = "START_TIMER_UPDATE",
                    execute = {
                        {
                            "expect",{"&timeleft|bgstartcd&","==","-1"},
                            "alert","bgstartcd",
                        },
                    },
                },
                -- Not Enough Players
                {
                    event = "NOT_ENOUGH_PLAYERS",
                    execute = {
                        {
                            "alert",{"notenougplayerscd",timeexact = "<TimeOut>"},
                        },
                    },
                },
                {
                    event = "ENOUGH_PLAYERS",
                    execute = {
                        {
                            "quash","notenougplayerscd",
                        },
                    },
                },
                -- A point is claimed or assaulted
                {
                    event = "POINT_ASSAULTED",
                    execute = {
                        {
                            "expect",{"<Faction>","==","alliance"},
                            "quash",{"hordepoiassaultcd","<LocationPure>"},
                            "alert","alliancepoiassaultcd",
                        },
                        {
                            "expect",{"<Faction>","==","horde"},
                            "quash",{"alliancepoiassaultcd","<LocationPure>"},
                            "alert","hordepoiassaultcd",
                        },
                    },
                },
                -- A point was defended
                {
                    event = "POINT_DEFENDED",
                    execute = {
                        {
                            "expect",{"<Faction>","==","alliance"},
                            "quash",{"hordepoiassaultcd","<LocationPure>"},
                        },
                        {
                            "expect",{"<Faction>","==","horde"},
                            "quash",{"alliancepoiassaultcd","<LocationPure>"},
                        },
                    },
                },
            },
        },
        
        phrasecolors = {},
        ordering = {
            alerts = {"bgstartcd","notenougplayerscd","alliancepoiassaultcd","hordepoiassaultcd"},
        },
        
        alerts = {
            -- Battleground Start
            bgstartcd = {
                varname = format("%s Countdown",L.alert["Battleground Start"]),
                type = "dropdown",
                text = format(L.alert["Battleground starts"]),
                time = "<StartTime>",
                flashtime = 20,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Misc_Trophy_Argent",
                behavior = "overwrite",
                audiocd = true,
            },
            -- Not Enough Players
            notenougplayerscd = {
                varname = format("%s Countdown",L.alert["Not Enough Players"]),
                type = "dropdown",
                text = format(L.alert["Not enough players"]),
                time = 300,
                flashtime = 10,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_EVERYONES A HERO_RANK2",
                behavior = "overwrite",
            },
            -- Alliance assaults Point
            alliancepoiassaultcd = {
                varname = format(L.alert["%s Countdown"],"Alliance Assaults Point"),
                type = "dropdown",
                text = format(L.alert["%s"],"<Location>"),
                announcetext = format(L.alert["%s captures %s"],"<FactionCapitalized>","<Location>"),
                time = 60,
                flashtime = 20,
                color1 = "LIGHTBLUE",
                color2 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Achievement_PVP_A_16",
                tag = "<LocationPure>",
                behavior = "overwrite",
            },
            -- Horde assaults Point
            hordepoiassaultcd = {
                varname = format(L.alert["%s Countdown"],"Horde Assaults Point"),
                type = "dropdown",
                text = format(L.alert["%s"],"<Location>"),
                announcetext = format(L.alert["%s captures %s"],"<FactionCapitalized>","<Location>"),
                time = 60,
                flashtime = 20,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Inv_Misc_Tournaments_banner_Orc",
                tag = "<LocationPure>",
                behavior = "overwrite",
            },
        },
    }
    
    addon:RegisterBattleground(data)
end

---------------------------------
-- STRAND OF THE ANCIENTS
---------------------------------
do
    local round, roundTime, roundInProgress
    local round1EndTime
    
    local TIME_WARM_UP     =  2 * 60 --  2 minutes in seconds
    local TIME_ROUND_1_MAX = 10 * 60 -- 10 minutes in seconds
    
    local function init()
        round1EndTime = nil
    end
    
    local function getRound() return round end
    local function getRoundTime() return roundTime end
    local function getRound1EndTime() return round1EndTime end

    local function getAttacker()
        if GetMapLandmarkInfo(1) == "Alliance Defense" then
            return "horde"
        elseif GetMapLandmarkInfo(8) == "Horde Defense" then
            return "alliance"
        else
            return "none"
        end
    end
    
    local winner,adjustedWinner
    
    local function getWinnerPure()
        return winner
    end
    
    local function getWinner()
        return adjustedWinner
    end
    
    local function setWinner(newWinner)
        winner = newWinner
        adjustedWinner = Faction:Adjust(newWinner)
    end
    
    
    local function updateRoundInfo()
        local visible, _, remainingTimeText = select(2,GetWorldStateUIInfo(7))-- end round time (text)
        roundInProgress = visible == 1
        
        local minutes, seconds = remainingTimeText:match("^End of Round: (%d+):(%d+)$")
        
        local endOfRoundTime = 0
        
        if minutes and seconds then
            endOfRoundTime = minutes*60 + seconds
        end
        if roundInProgress then
            if math.abs((TIME_ROUND_1_MAX - endOfRoundTime) + TIME_WARM_UP - GetBattlefieldInstanceRunTime()/1000) < 3 then
                round = 1
                roundTime = TIME_ROUND_1_MAX - (GetBattlefieldInstanceRunTime()/1000 - TIME_WARM_UP)
            else
                round = 2
                if round1EndTime then
                    roundTime = round1EndTime - TIME_WARM_UP
                else
                    roundTime = endOfRoundTime
                end
            end
        else
            if GetBattlefieldInstanceRunTime()/1000 < TIME_WARM_UP then
                round = 1
                roundTime = 600
            else
                round = 2
                if round1EndTime then
                    roundTime = round1EndTime - TIME_WARM_UP
                else
                    roundTime = endOfRoundTime
                end
            end
        end
    end

    local function startRound()
        updateRoundInfo()
        if roundInProgress then ScoreTimerAPI:Start(roundTime) end
        if not winner then
            if round == 2 then
                if roundInProgress then
                    if roundTime == 600 then
                        setWinner("none")
                    else
                        setWinner("unknown")
                    end
                else
                    setWinner("unknown")
                end
            else
                setWinner("unknown")
            end
        end
    end
    
    local function updateScoreTimer()
        ScoreTimerAPI:SetTime(roundTime)
    end
    
    local function processEndOfRound1()
        round1EndTime = GetBattlefieldInstanceRunTime()/1000
        updateRoundInfo()
        ScoreTimerAPI:Pause()
        updateScoreTimer()
        if winner == "unknown" then setWinner("none") end
    end
    
    
        
    local function RefreshSlots(SlotCount, SlotTexts, SlotColors, SlotFlashing, SlotActions, SlotTextOnly)
        local attacker = getAttacker()
        
        for i=1, GetNumMapLandmarks(), 1 do
            local name, _, textureIndex = GetMapLandmarkInfo(i)
            local slotIndex = PoiAPI:POItoSlot(name)
            local state =     PoiAPI:POItoState(textureIndex)
            
            if slotIndex and state then                
                if state.status == "standing" or state.status == "damaged" then
                    SlotColors[slotIndex] = Faction:Swap(attacker)
                elseif state.status == "destroyed" then
                    SlotColors[slotIndex]   = attacker
                end
                
                if state.status == "damaged" then
                    SlotFlashing[slotIndex] = attacker
                else
                    SlotFlashing[slotIndex] = nil
                end
            end
        end
    end

    local data = {
        version = 2,
        key = "strandoftheancients",
        zone = L.zone["Strand of the Ancients"],
        category = L.zone["Battlegrounds"],
        name = "Strand of the Ancients",
        triggers = {
            bg_neutral = "Let the battle for Strand of the Ancients begin",
        },
        onactivate = {
            tracerstart = false,
            combatstop = false,
            combatstart = false,
        },
        userdata = {
            GateTexts = {
                type = "map",
                ["The Gate of the Green Emerald"]     = "Green gate",
                ["The Gate of the Purple Amethyst"]   = "Purple gate",
                ["The Gate of the Blue Sapphire"]     = "Blue gate",
                ["The Gate of the Red Sun"]           = "Red gate",
                ["The Gate of the Yellow Moon"]       = "Yellow gate",
                ["The Chamber of Ancient Relics"]     = "Relic gate",
            },
            GateIcons = {
                type = "map",
                ["The Gate of the Green Emerald"]     = "Interface\\ICONS\\INV_Bijou_Green",
                ["The Gate of the Purple Amethyst"]   = "Interface\\ICONS\\INV_Bijou_Purple",
                ["The Gate of the Blue Sapphire"]     = "Interface\\ICONS\\INV_Bijou_Blue",
                ["The Gate of the Red Sun"]           = "Interface\\ICONS\\INV_Bijou_Red",
                ["The Gate of the Yellow Moon"]       = "Interface\\ICONS\\INV_Bijou_Yellow",
                ["The Chamber of Ancient Relics"]     = "Interface\\ICONS\\INV_Bijou_Gold",
            },
        },
        onstart = {
            {
                "execute","init",
                "scheduletimer",{"startrounddelayed", 0},
            },
        },
        battleground = {
            init = init,
            modules = {
                POI = {
                    categories = {
                        gates = {
                            ["Gate of the Green Emerald"]   = {slot = 1, POIs = {108,109,110}},
                            ["Gate of the Purple Amethyst"] = {slot = 3, POIs = {105,106,107}},
                            ["Gate of the Blue Sapphire"]   = {slot = 4, POIs = {80,81,82}},
                            ["Gate of the Red Sun"]         = {slot = 6, POIs = {77,78,79}},
                            ["Gate of the Yellow Moon"]     = {slot = 8, POIs = {102,103,104}},
                            ["Chamber of Ancient Relics"]   = {slot = 9, POIs = {80,81,82}},
                        },
                        graveyards = {
                            ["West Graveyard"]  = {slot = 2, POIs = {15,13}},
                            ["East Graveyard"]  = {slot = 5, POIs = {15,13}},
                            ["South Graveyard"] = {slot = 7, POIs = {15,13}},
                        },
                    },
                    states = {
                        gates = {
                            {faction = "none", status = "standing"},
                            {faction = "none", status = "damaged"},
                            {faction = "none", status = "destroyed"},
                        },
                        graveyards = {
                            {faction = "alliance", status = "controlled"},
                            {faction = "horde",    status = "controlled"},
                        },
                    },
                    ignoreFactionSwapping = {
                        ["Gate of the Red Sun"] = true,
                        ["Gate of the Blue Sapphire"] = true,
                        ["Chamber of Ancient Relics"] = true,
                    },
                },
            },
            slots = {
                count = 9,
                texts = {
                    [1] = "<POI> Green", [3] = "<POI> Purple", [4] = "<POI> Blue",
                    [6] = "<POI> Red",   [8] = "<POI> Yellow", [9] = "<POI> Relic",
                },
                widthmult = {3, 1.5, 3, 3, 1.5, 3, 1.5, 3, 3},
                --height = {40,40,40,40,40,40,40,40,40},
                height = 40,
                offsetmults = {
                  {5.5, 5.5, 3,     6.5, 2, 0,      -4.5,-8.25,-8.25},
                  {1.25,1.25,0.25,  1.25,1.25,0.25, 0.25,-0.75,-0.75},
                },
                textOnly = {false, true, false, false, true, false, true, false, false},
                actions = {
                    [1] = {"base-help","Green Gate"}, [3] = {"base-help","Purple Gate"},
                    [4] = {"base-help","Blue Gate"},  [6] = {"base-help","Red Gate"},
                    [8] = {"base-help","Yellow Gate"},[9] = {"base-help","Relic Gate"},
                },
                refresh = RefreshSlots,
                disallowFactionSwitching = true,
            },
            events = {
                -- Battleground Start timer
                {
                    event = "START_TIMER_UPDATE",
                    execute = {
                        {
                            "expect",{"&timeleft|bgstartcd&","==","-1"},
                            "execute","updateroundinfo",
                            "alert","bgstartcd",
                        },
                    },
                },
                -- Not Enough Players
                {
                    event = "NOT_ENOUGH_PLAYERS",
                    execute = {
                        {
                            "alert",{"notenougplayerscd",timeexact = "<TimeOut>"},
                        },
                    },
                },
                {
                    event = "ENOUGH_PLAYERS",
                    execute = {
                        {
                            "quash","notenougplayerscd",
                        },
                    },
                },
            },
        },
        functions = {
            round = getRound,
            roundtime = getRoundTime,
            round1endtime = getRound1EndTime,
            winner = getWinner,
            winnerpure = getWinnerPure,
            setwinner = setWinner,
            startround = startRound,
            endofround1 = processEndOfRound1,
            updateroundinfo = updateRoundInfo,
            updatescoretimer = updateScoreTimer,
        },
        filters = {
            bossemotes = {
                gatedamagedemote = {
                    name = "Gate Damaged",
                    pattern = "^([%a%s]+) is under attack!$",
                    hasIcon = false,
                    hide = true,
                },
                gatedestroyedemote = {
                    name = "Gate Destroyed",
                    pattern = "^([%a%s]+) was destroyed!$",
                    hasIcon = false,
                    hide = true,
                },
                chambervulnerableemote = {
                    name = "Chamber is vulnerable",
                    pattern = "The chamber has been breached! The titan relic is vulnerable",
                    hasIcon = false,
                    hide = true,
                },
            },
        },
        phrasecolors = {
            {"Green","LIGHTGREEN"},
            {"Purple","MAGENTA"},
            {"Blue","LIGHTBLUE"},
            {"Red","RED"},
            {"Yellow","YELLOW"},
            {"Relic","GOLD"},
            {"damaged","TURQUOISE"},
            {"destroyed","RED"},
        },
        ordering = {
            alerts = {"bgstartcd","notenougplayerscd","roundcd","bgendcd","alliancewincd","hordewincd","gatedamagedwarn","gatedestroyedwarn"},
        },
        
        alerts = {
            -- Battleground Start
            bgstartcd = {
                varname = format("%s Countdown",L.alert["Round Start"]),
                type = "dropdown",
                text = format(L.alert["Round %s starts"],"&round&"),
                time = "<StartTime>",
                flashtime = 20,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Misc_Trophy_Argent",
                behavior = "overwrite",
                audiocd = true,
            },
            -- Not Enough Players
            notenougplayerscd = {
                varname = format("%s Countdown",L.alert["Not Enough Players"]),
                type = "dropdown",
                text = format(L.alert["Not enough players"]),
                time = 300,
                flashtime = 10,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_EVERYONES A HERO_RANK2",
                behavior = "overwrite",
            },
            -- Round end
            roundcd = {
                varname = format(L.alert["%s Countdown"],"Round End"),
                type = "dropdown",
                text = format(L.alert["Round %s ends"],"&round&"),
                time = 600,
                flashtime = 20,
                color1 = "TAN",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Achievement_BG_winSOA",
            },
            -- Alliance wins (prediction)
            alliancewincd = {
                varname = format(L.alert["%s Countdown"],"Alliance (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins"],"Alliance"),
                announcetext = format(L.alert["%s wins"],"&capitalize|&winnerpure&&"),
                time = "&roundtime&",
                flashtime = 10,
                color1 = "BLUE",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Alliance",
            },
            -- Horde wins (prediction)
            hordewincd = {
                varname = format(L.alert["%s Countdown"],"Horde (Predicted) Victory"),
                type = "dropdown",
                text = format(L.alert["%s wins"],"Horde"),
                announcetext = format(L.alert["%s wins"],"&capitalize|&winnerpure&&"),
                time = "&roundtime&",
                flashtime = 10,
                color1 = "BROWN",
                color2 = "Off",
                sound = "None",
                icon = "Interface\\ICONS\\PVPCurrency-Conquest-Horde",
            },
            -- Battleground Ends In A Draw
            bgendcd = {
                varname = format(L.alert["%s Countdown"],"Battleground Draw"),
                type = "dropdown",
                text = L.alert["Battleground Draw"],
                time = 600,
                flashtime = 10,
                color1 = "TEAL",
                color2 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\INV_Offhand_1H_UlduarRaid_D_01",
            },
            -- Gate Damaged
            gatedamagedwarn = {
                varname = format(L.alert["%s Warning"],"Gate Damaged"),
                type = "simple",
                text = format(L.alert["%s is damaged"],"<GateName>"),
                time = 1,
                color1 = "WHITE",
                sound = "None",
                texture = "Interface\\ICONS\\Achievement_Arena_2v2_4",
                icon = "<GateIcon>",
            },
            -- Gate Destroyed
            gatedestroyedwarn = {
                varname = format(L.alert["%s Warning"],"Gate Destroyed"),
                type = "simple",
                text = format(L.alert["%s was destroyed"],"<GateName>"),
                time = 1,
                color1 = "WHITE",
                sound = "None",
                texture = "Interface\\ICONS\\Achievement_Arena_2v2_7",
                icon = "<GateIcon>",
            },
            
        },
        batches = {
            startround = {
                {
                    "execute","startround",
                    "quash","bgstartcd",
                },
                {
                    "expect",{"&round&","==","1"},
                    "alert",{"roundcd", timeexact = "&roundtime&"},
                },
                {
                    "expect",{"&round&","==","2"},
                    "invoke",{
                        {
                            "expect",{"&winner&","==","alliance"},
                            "alert","alliancewincd",
                        },
                        {
                            "expect",{"&winner&","==","horde"},
                            "alert","hordewincd",
                        },
                        {
                            "expect",{"&winner&","==","none"},
                            "alert","bgendcd",
                        },
                        {
                            "expect",{"&winner&","==","unknown"},
                            "alert",{"roundcd", timeexact = "&roundtime&"},
                        },
                    },
                },
            },
        },
        timers = {
            -- This call must be "delayed" because at the moment of battleground start the info isn't available until the next frame.
            startrounddelayed = {
                {
                    "run","startround",
                },
            },
        },
        events = {
            {
                type = "event",
                event = "BG_NEUTRAL",
                execute = {
                    -- Alliance captures the titan portal
                    {
                        "expect",{"#1#","find","The Alliance captured the titan portal!"},
                        "execute",{"setwinner","alliance"},
                    },
                    -- Horde captures the titan portal
                    {
                        "expect",{"#1#","find","The Horde captured the titan portal!"},
                        "execute",{"setwinner","horde"},
                    },
                    -- Round 2 starts in 1 minute
                    {
                        "expect",{"#1#","find","Round 2 of the Battle for the Strand of the Ancients begins in 1 minute"},
                        "set",{StartTime = 60},
                        "alert",{"bgstartcd",time = 2},
                    },
                    -- Round 2 starts in 30 seconds
                    {
                        "expect",{"#1#","find","Round 2 begins in 30 seconds"},
                        "expect",{"&timeleft|bgstartcd&","==","-1"},
                        "set",{StartTime = 30},
                        "alert","bgstartcd",
                    },
                },
            },
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    -- End of round
                    {
                        "expect",{"#1#","find","Round 1.+finished"},
                        "quash","roundcd",
                        "execute","endofround1",
                    },
                    -- Round start
                    {
                        "expect",{"#1#","find","Let the battle for Strand of the Ancients begin"},
                        "scheduletimer",{"startrounddelayed", 0},
                    },
                    -- Gate Damaged
                    {
                        "expect",{"#1#","find",".+ is under attack!"},
                        "set",{GateNameKey = "&match|#1#|^([%a%s]+) is under attack!$&"},
                        "set",{
                            GateName = "&mapget|GateTexts|<GateNameKey>&",
                            GateIcon = "&mapget|GateIcons|<GateNameKey>&",
                        },
                        "alert","gatedamagedwarn",
                    },
                    -- Gate Destroyed
                    {
                        "expect",{"#1#","find",".+ was destroyed!"},
                        "set",{GateNameKey = "&match|#1#|^([%a%s]+) was destroyed!$&"},
                        "set",{
                            GateName = "&mapget|GateTexts|<GateNameKey>&",
                            GateIcon = "&mapget|GateIcons|<GateNameKey>&",
                        },
                        "alert","gatedestroyedwarn",
                    },
                    -- Chamber Breached
                    {
                        "expect",{"#1#","find","The chamber has been breached! The titan relic is vulnerable!"},
                        "set",{GateNameKey = "The Chamber of Ancient Relics"},
                        "set",{
                            GateName = "&mapget|GateTexts|<GateNameKey>&",
                            GateIcon = "&mapget|GateIcons|<GateNameKey>&",
                        },
                        "alert","gatedestroyedwarn",
                    },
                },
            },
            {
                type = "event",
                event = "WORLD_STATE_UI_TIMER_UPDATE",
                execute = {
                    {
                        "expect",{"&round1endtime&","==","nil",
                                    "AND","&round&","==","2",
                                    "AND","&timeleft|roundcd&",">","10"},
                        "execute","updateroundinfo",
                        "execute","updatescoretimer",
                        "expect",{"&timeleft|roundcd&","~=","-1"},
                        "settimeleft",{"roundcd","&roundtime&"},                        
                    },
                },
            },
        },
    }
    
    addon:RegisterBattleground(data)
end
