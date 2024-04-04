local L,SN,ST,SL,AL,AT,AN,TI = DXE.L,DXE.SN,DXE.ST,DXE.SL,DXE.AL,DXE.AT,DXE.AN,DXE.TI

---------------------------------
-- ECHO OF BAINE
---------------------------------

do
    local data = {
        version = 1,
        key = "echobaine",
        groupkey = "echoofthepast",
        zone = L.zone["End Time"],
        category = L.zone["End Time"],
        name = "Echo of Baine",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-BaineBloodhoof.blp",
        triggers = {
            scan = {
                54431, -- Echo of Baine
            },
        },
        onactivate = {
            tracing = {
                54431,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 54431,
        },
        userdata = {
            blasttext = "",
            throwtotembacktext = "",
        },
        onstart = {
            {
                "alert",{"throwtotemcd",time = 2},
                "alert",{"pulverizecd",time = 2},
            },
        },
        
        filters = {
            bossemotes = {
                pulverizeemote = {
                    name = "Pulverize",
                    pattern = "Echo of Baine casts %[Pulverize%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[101626],
                },
            },
        },
        phrasecolors = {
            {"Baine","GOLD"},
        },
        ordering = {
            alerts = {"throwtotemcd","throwtotemwarn","throwtotembackcd","throwtotemdebuff","pulverizecd","pulverizewarn","blastwarn","blastduration"},
        },
        
        alerts = {
            -- Molten Blast
            blastduration = {
                varname = format(L.alert["%s Duration"],SN[101840]),
                type = "centerpopup",
                text = "<blasttext>",
                time = 10,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[101840],
                tag = "#4#",
                fillDirection = "DEPLETE",
            },
            blastwarn = {
                varname = format(L.alert["%s Warning"],SN[101840]),
                type = "simple",
                text = "<blasttext>",
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT8",
                icon = ST[101840],
                throttle = 3,
            },
            -- Pulverize
            pulverizecd = {
                varname = format(L.alert["%s CD"],SN[101625]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[101625]),
                time = 40,
                time2 = 30,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[101626],
                behavior = "overwrite",
                audiocd = true,
            },
            pulverizewarn = {
                varname = format(L.alert["%s Warning"],SN[101625]),
                type = "simple",
                text = format(L.alert["%s"],SN[101625]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT1",
                icon = ST[101626],
                throttle = 3,
            },
            -- Throw Totem
            throwtotemcd = {
                varname = format(L.alert["%s CD"],SN[101615]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[101615]),
                time = 25,
                time2 = 10,
                flashtime = 5,
                color1 = "CYAN",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[101615],
            },
            throwtotemwarn = {
                varname = format(L.alert["%s Warning"],SN[101615]),
                type = "simple",
                text = format(L.alert["%s"],SN[101615]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT2",
                icon = ST[101615],
            },
            -- Throw Totem Back
            throwtotembackcd = {
                varname = format(L.alert["%s CD"],SN[107837]),
                type = "centerpopup",
                text = "<throwtotembacktext>",
                time = 10,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[107837],
            },
            -- Throw Totem (debuf)
            throwtotemdebuff = {
                varname = format(L.alert["%s Duration"],SN[101602]),
                type = "centerpopup",
                text = format(L.alert["%s on Baine"],SN[101602]),
                time = 6,
                color1 = "TURQUOISE",
                sound = "BURST",
                icon = ST[101602],
            },
            
        },
        events = {
			-- Throw Totem
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 101615,
                execute = {
                    {
                        "quash","throwtotemcd",
                        "alert","throwtotemcd",
                        "alert","throwtotemwarn",
                        
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 101602,
                execute = {
                    {
                        "alert","throwtotemdebuff",
                    },
                },
            },
            -- Throw Totem back
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 107837,
                execute = {
                    {
                        "set",{
                            throwtotembacktext = format(L.alert["%s: %s!"],"<#5#>",SN[107837])
                        },
                        "alert","throwtotembackcd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 107837,
                execute = {
                    {
                        "quash","throwtotembackcd",
                    },
                },
            },
            
            -- Molten Blast
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 101840,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{blasttext = format(L.alert["%s on <%s>"],SN[101840],L.alert["YOU"])},
                        "quash",{"blastduration","#4#"},
                        "alert","blastduration",
                        "alert","blastwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{blasttext = format(L.alert["%s on <#5#>"],SN[101840])},
                        "quash",{"blastduration","#4#"},
                        "alert","blastduration",
                        "alert","blastwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REFRESH",
                spellname = 101840,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{blasttext = format(L.alert["%s (1) on <%s>"],SN[101840],L.alert["YOU"])},
                        "quash",{"blastduration","#4#"},
                        "alert","blastduration",
                        "alert","blastwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{blasttext = format(L.alert["%s (1) on <#5#>"],SN[101840])},
                        "quash",{"blastduration","#4#"},
                        "alert","blastduration",
                        "alert","blastwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 101840,
                execute = {
                    {
                        "quash",{"blastduration","#4#"},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 101840,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{blasttext = format(L.alert["%s (%s) on <%s>"],SN[101840],"#11#",L.alert["YOU"])},
                        "quash",{"blastduration","#4#"},
                        "alert","blastduration",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{blasttext = format(L.alert["%s (%s) on <#5#>"],SN[101840],"#11#")},
                        "quash",{"blastduration","#4#"},
                        "alert","blastduration",
                    },
                },
            },
            -- Pulverize
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = 101625,
                execute = {
                    {
                        "alert","pulverizecd",
                        "alert","pulverizewarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ECHO OF JAINA
---------------------------------

do
    local data = {
        version = 1,
        key = "echojaina",
        groupkey = "echoofthepast",
        zone = L.zone["End Time"],
        category = L.zone["End Time"],
        name = "Echo of Jaina",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-JainaProudmoore.blp",
        triggers = {
            scan = {
                54445, -- Echo of Jaina
            },
        },
        onactivate = {
            tracing = {
                54445,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 54445,
        },
        userdata = {
            corecd = {16.5, 27, loop = false, type = "series"},
        },
        onstart = {
            {
                "alert",{"corecd",time = 2},
                "alert",{"bladescd",time = 2},
            },
        },
        ordering = {
            alerts = {"corecd","corewarn","coreduration","bladescd","bladeswarn","volleywarn"},
        },
 
        alerts = {
            -- Flarecore
            corecd = {
                varname = format(L.alert["%s CD"],SN[101927]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[101927]),
                time = "<corecd>", --20,
                time2 = 14, --16,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[101927],
            },
            corewarn = {
                varname = format(L.alert["%s Warning"],SN[101927]),
                type = "simple",
                text = format(L.alert["%s"],SN[101927]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT10",
                icon = ST[101927],
                emphasizewarning = true,
            },
            coreduration = {
                varname = format(L.alert["%s Duration"],SN[101927]),
                type = "centerpopup",
                text = format(L.alert["%s explodes in"],SN[101927]),
                time = 11,
                flashtime = 5,
                color1 = "GOLD",
                color2 = "RED",
                sound = "None",
                icon = ST[101927],
            },
            -- Frost Blades
            bladescd = {
                varname = format(L.alert["%s CD"],SN[101339]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[101339]),
                time = 27, -- 25,
                time2 = 18, -- 21,
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[101339],
            },
            bladeswarn = {
                varname = format(L.alert["%s Warning"],SN[101339]),
                type = "simple",
                text = format(L.alert["%s"],SN[101339]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT7",
                icon = ST[101339],
            },
            -- Frostbolt Volley
            volleywarn = {
                varname = format(L.alert["%s Warning"],SN[101810]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT"],SN[101810]),
                time = 2,
                color1 = "CYAN",
                sound = "ALERT2",
                icon = ST[101810],
                counter = true,
            },
            
        },
        events = {
			-- Flarecore
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 101927,
                execute = {
                    {
                        "alert","corewarn",
                        "alert","coreduration",
                        "quash","corecd",
                        "alert","corecd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 101980,
                execute = {
                    {
                        "quash","coreduration",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_MISSED",
                spellname = 101980,
                execute = {
                    {
                        "quash","coreduration",
                    },
                },
            },
            
            -- Frost Blades
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 101812,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","54445"},
                        "quash","bladescd",
                        "alert","bladescd",
                        "alert","bladeswarn",
                        "resetalertcounter","volleywarn",
                    },
                },
            },
            -- Frostbolt Volley
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 101810,
                execute = {
                    {
                        "quash","volleywarn",
                        "alert","volleywarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[101810]},
                        "expect",{"#1#","find","boss"},
                        "quash","volleywarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ECHO OF SYLVANAS
---------------------------------

do
    local data = {
        version = 1,
        key = "echosylvanas",
        groupkey = "echoofthepast",
        zone = L.zone["End Time"],
        category = L.zone["End Time"],
        name = "Echo of Sylvanas",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-SylvanasWindrunner.blp",
        triggers = {
            scan = {
                54123, -- Echo of Sylvanas
            },
        },
        onactivate = {
            tracing = {
                54123,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 54123,
        },
        userdata = {
            shriektext = "",
            ghoulscount = 0,
            severedtiescompleted = "no",
        },
        onstart = {
            {
                "alert",{"callingcd",time = 2},
                "alert",{"arrowscd",time = 2},
                "alert",{"shriekcd",time = 2},
            },
            {
                "expect",{"&itemenabled|severedtiescompleted&","==","true"},
                "counter","ghoulscounter",
            },
        },
        
        counters = {
            ghoulscounter = {
                variable = "ghoulscount",
                label = format("%s Risen Ghouls killed",TI["AchievementShield"]),
                pattern = "%d / %d",
                value = 0,
                minimum = 0,
                maximum = 2,
                difficulty = 20,
            },
        },
        announces = {
            severedtiescompleted = {
                varname = "%s complete",
                type = "PARTY",
                subtype = "achievement",
                achievement = 6130,
                msg = format(L.alert["<DXE> Requirements for %s were met. You can kill the boss now."],AL[6130]),
                throttle = true,
            },
        },
        windows = {
            proxwindow = true,
            proxrange = 10,
            proxoverride = true,
        },
        ordering = {
            alerts = {"arrowscd","arrowsselfwarn","shriekcd","shriekwarn","callingcd","callingwarn","gripcd","sacrificecd","sacrificewarn"},
        },
        
        alerts = {
            -- Blighted Arrows
            arrowscd = {
                varname = format(L.alert["%s CD"],SN[101567]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[101567]),
                time = 27.6,
                time2 = 16,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[101567],
            },
            arrowsselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[103171]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[103171],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[103171],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
            -- Shriek of the Highborne
            shriekcd = {
                varname = format(L.alert["%s CD"],SN[101412]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[101412]),
                time = 11,
                time2 = 31, -- after pull
                time3 = 20.1, -- after Sacrifice
                flashtime = 5,
                color1 = "CYAN",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[101412],
            },
            shriekwarn = {
                varname = format(L.alert["%s Warning"],SN[101412]),
                type = "simple",
                text = "<shriektext>",
                time = 1,
                color1 = "CYAN",
                sound = "ALERT8",
                icon = ST[101412],
            },
            -- Calling of the Highborne
            callingcd = {
                varname = format(L.alert["%s CD"],SN[100686]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[100686]),
                time = 45.5,
                time2 = 37.5,
                flashtime = 5,
                color1 = "MAGENTA",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[100686],
                behavior = "overwrite",
                audiocd = true,
            },
            callingwarn = {
                varname = format(L.alert["%s Warning"],SN[100686]),
                type = "simple",
                text = format(L.alert["%s"],SN[100686]),
                time = 1,
                color1 = "MAGENTA",
                sound = "BEWARE",
                icon = ST[100686],
                throttle = 2,
            },
            -- Sacrifice
            sacrificecd = {
                varname = format(L.alert["%s Countdown"],SN[101348]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[101348]),
                time = 26.50, -- 30
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[101348],
                audiocd = true,
            },
            sacrificewarn = {
                varname = format(L.alert["%s Warning"],SN[101348]),
                type = "simple",
                text = format(L.alert["%s"],SN[101348]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT7",
                icon = ST[101348],
            },
            -- Death Grip
            gripcd = {
                varname = format(L.alert["%s CD"],SN[101397]),
                type = "centerpopup",
                text = format(L.alert["Mass %s"],SN[101397]),
                time = 4.5,
                color1 = "YELLOW",
                sound = "None",
                icon = ST[101397],
            },
            
        },
        events = {
			-- Shriek of the Highborne
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 101412,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{shriektext = format(L.alert["%s on <%s> - DISPEL!"],SN[101412],L.alert["YOU"])},
                        "quash","shriekcd",
                        "alert","shriekcd",
                        "alert","shriekwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{shriektext = format(L.alert["%s on <#5#> - DISPEL!"],SN[101412])},
                        "quash","shriekcd",
                        "alert","shriekcd",
                        "alert","shriekwarn",
                    },
                },
            },
            
            -- Calling of the Highborne
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 100686,
                execute = {
                    {
                        "alert","callingwarn",
                        "quash","callingcd",
                        "quash","shriekcd",
                        "alert","sacrificecd",
                        "alert","arrowscd",
                        "alert","gripcd",
                    },
                    {
                        "expect",{"&itemenabled|severedtiescompleted&","==","true"},
                        "expect",{"<severedtiescompleted>","==","no"},
                        "set",{ghoulscount = 0},
                    },
                },
            },
            -- Sacrifice
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 101348,
                execute = {
                    {
                        "quash","sacrificecd",
                        "alert","sacrificewarn",
                        "alert","callingcd",
                        "alert",{"shriekcd",time = 3},
                    },
                },
            },
            -- Blighted Arrows
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 103171,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","arrowsselfwarn",
                    },
                },
            },
            -- Severed Ties (achievement)
            {
                type = "combatevent",
                eventtype = "PARTY_KILL", -- Risen Ghoul dies
                execute = {
                    {
                        "expect",{"&itemenabled|severedtiescompleted&","==","true"},
                        "expect",{"&npcid|#4#&","==","54191"},
                        "set",{ghoulscount = "INCR|1"},
                    },
                    {
                        "expect",{"&itemenabled|severedtiescompleted&","==","true"},
                        "expect",{"<ghoulscount>","==","2"},
                        "expect",{"<severedtiescompleted>","==","no"},
                        "set",{severedtiescompleted = "yes"},
                        "announce","severedtiescompleted",
                    },
                },
            },
            
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ECHO OF TYRANDE
---------------------------------

do
    local TYRANDE_LOCATION = {x = 0.50760787725449, y = 0.44372451305389}
    local EYES_END_LOCATION_1 = {x = 0.49652934074402, y = 0.38761454820633}
    local EYES_END_LOCATION_2 = {x = 0.51670682430267, y = 0.50362956523895}
    local EYES_LINE_RANGE = 5 -- yards
    
    local EYES_INACTIVE = 1
    local EYES_ACTIVE = 2
    
    local eyesMode = EYES_INACTIVE
    local linesShown = false
    
    local MOON_LANCE_RANGE = 3 -- yards
    local MOON_LANCE_SEARCHING = 1
    local MOON_LANCE_CHARGING = 2
    local MOON_LANCE_SHOOTING = 3
    
    local moonlanceMode = MOON_LANCE_SEARCHING
    local moonlanceTarget
    local ACTIVE = {
        color = {1, 1, 0, 1},
        thickness = 75,
    }
    
    local INACTIVE = {
        color = {0.3868, 0.949, 1, 1},
        thickness = 25,
    }
    
    local TOUCHING = {
        color = {1, 0, 0, 1},
        thickness = 100,
    }
    
    local function setEyesMode(mode)
        eyesMode = mode
    end
    
    local function getFurthestPlayer(API,mapData)
        local playerLocation = API.GetUnitPosition("player")
        local maxPos = mapData:ToMapPos(playerLocation)
        local tyrandePos = mapData:ToMapPos(TYRANDE_LOCATION)
        local maxDist = API.GetDistance(maxPos, tyrandePos)
        
        if GetNumRaidMembers() == 0 then
            for i=1,GetNumPartyMembers() do
                local partyPos = mapData:ToMapPos(GetPlayerMapPosition("party"..i))
                if partyPos.x ~= 0 and partyPos.y ~= 0 then
                    
                    local dist = API.GetDistance(partyPos, tyrandePos)
                    if dist > maxDist then
                        maxDist = dist
                        maxPos = partyPos
                    end
                end
            end
        else
            for i=1,GetNumRaidMembers() do
                local raidPos = mapData:ToMapPos(GetPlayerMapPosition("raid"..i))
                if raidPos.x ~= 0 and raidPos.y ~= 0 then
                    local dist = API.GetDistance(raidPos, tyrandePos)
                    if dist > maxDist then
                        maxDist = dist
                        maxPos = raidPos
                    end
                end
            end
        end
        
        return maxPos
    end
    
    local function resetMoonlanceTarget()
        moonlanceTarget = nil
    end
    
    local function setMoonlanceMode(mode)
        moonlanceMode = mode
    end
    
    local eyesInPlayerRange = false
    local moonlanceMainInPlayerRange = false
    local moonlanceBranch1InPlayerRange = false
    local moonlanceBranch2InPlayerRange = false
    
    local GetPlayerMapPosition,UnitName = GetPlayerMapPosition,UnitName
    
    local updateeyelines = function(API, mapData)
        if not linesShown then return end
        
        ---------- Eyes of the Goddess line ----------
        local playerPosition = mapData:ToMapPos(API.GetUnitPosition("player"))
        local eyesInRadarRange = API.IsPointAtDistanceFromLineSegment(mapData:ToMapPos(EYES_END_LOCATION_1),
                                                                      mapData:ToMapPos(EYES_END_LOCATION_2),
                                                                      playerPosition, 
                                                                      API.GetRadarRange())
                                                                      
        if eyesInRadarRange then        
            local lineThickness, lineColor
            
            eyesInPlayerRange = API.IsPointAtDistanceFromLineSegment(
                mapData:ToMapPos(EYES_END_LOCATION_1), mapData:ToMapPos(EYES_END_LOCATION_2),
                playerPosition, EYES_LINE_RANGE)
            if eyesMode == EYES_INACTIVE then
                lineColor = INACTIVE.color
                lineThickness = INACTIVE.thickness
            elseif eyesMode == EYES_ACTIVE then
                if eyesInPlayerRange then
                    lineColor = TOUCHING.color
                    lineThickness = TOUCHING.thickness
                else
                    lineColor = ACTIVE.color
                    lineThickness = ACTIVE.thickness
                end
            end
        
            local x1, y1, x2, y2 = API.GetLineSegment(API.MapPosToRadarPoint(mapData:ToMapPos(EYES_END_LOCATION_1)),
                                                      API.MapPosToRadarPoint(mapData:ToMapPos(EYES_END_LOCATION_2)))
            
            API.RadarDrawLine(x1, y1, x2, y2, lineThickness, lineColor)
        end
        
        ---------- Moonlance lines ----------
        local tyrandePos = mapData:ToMapPos(TYRANDE_LOCATION)
        if moonlanceMode == MOON_LANCE_SEARCHING then
            local target = getFurthestPlayer(API,mapData)
            local x1,y1,x2,y2 = API.GetLineSegment(API.MapPosToRadarPoint(tyrandePos),
                                                       API.MapPosToRadarPoint(target))
            API.RadarDrawLine(x1, y1, x2, y2, INACTIVE.thickness, INACTIVE.color)
        else
            local target, lineThickness, regularLineColor
            if moonlanceMode == MOON_LANCE_CHARGING then
                local x,y = GetPlayerMapPosition(UnitName("boss1target"))
                if x == 0 and y == 0 then
                    SetMapToCurrentZone()
                    x,y = GetPlayerMapPosition(UnitName("boss1target"))
                end
                moonlanceTarget = {x = x, y = y}
                
                target = mapData:ToMapPos(moonlanceTarget)
                lineThickness = INACTIVE.thickness
                regularLineColor = INACTIVE.color
            elseif moonlanceMode == MOON_LANCE_SHOOTING then
            -- Moonlance - main line
                target = mapData:ToMapPos(moonlanceTarget.x, moonlanceTarget.y)
                lineThickness = ACTIVE.thickness
                regularLineColor = ACTIVE.color
            else
                return nil
            end
            local moonLanceLength = 52 -- in yards
            do
                local mainEndPoistion = API.GetPointAtAngleFromLine(tyrandePos, target, 0,
                                              moonLanceLength, tyrandePos.x, tyrandePos.y)
                local x1,y1,x2,y2 = API.GetLineSegment(API.MapPosToRadarPoint(tyrandePos),
                                                       API.MapPosToRadarPoint(mainEndPoistion))
                moonlanceMainInPlayerRange = API.IsPointAtDistanceFromLineSegment(
                    tyrandePos, mainEndPoistion, playerPosition, MOON_LANCE_RANGE)
                
                local lineColor = (moonlanceMainInPlayerRange and moonlanceMode == MOON_LANCE_SHOOTING) and TOUCHING.color or regularLineColor
                API.RadarDrawLine(x1, y1, x2, y2, lineThickness, lineColor)
            end
            
            -- Moonlance - branch #1
            local splitDistance = 12 -- in yards
            local branchLen = 40 -- in yards
            local extraAngle = 42 -- in degrees
            
            
            local dist = API.GetDistance(tyrandePos,target)
            local kx = tyrandePos.x + (splitDistance / dist) * (target.x - tyrandePos.x)
            local ky = tyrandePos.y + (splitDistance / dist) * (target.y - tyrandePos.y)
            local k = {x = kx, y = ky}
            do
                local x1, y1, qx, qy
                local q = API.GetPointAtAngleFromLine(tyrandePos, target, extraAngle, branchLen, kx, ky)
                x1,y1,qx,qy = API.GetLineSegment(API.MapPosToRadarPoint(k),
                                                 API.MapPosToRadarPoint(q))
                moonlanceBranch1InPlayerRange = API.IsPointAtDistanceFromLineSegment(
                    k, q, playerPosition, MOON_LANCE_RANGE)
                
                local lineColor = (moonlanceBranch1InPlayerRange and moonlanceMode == MOON_LANCE_SHOOTING) and TOUCHING.color or regularLineColor
                API.RadarDrawLine(x1, y1, qx, qy, lineThickness, lineColor)
            end
            
            -- Moonlance - branch #2
            do
                local x1, y1, qx, qy
                local q = API.GetPointAtAngleFromLine(tyrandePos, target, -extraAngle, branchLen, kx, ky)
                x1,y1,qx,qy = API.GetLineSegment(API.MapPosToRadarPoint(k),
                                                 API.MapPosToRadarPoint(q))
                moonlanceBranch2InPlayerRange = API.IsPointAtDistanceFromLineSegment(
                    k, q, playerPosition, MOON_LANCE_RANGE)
                
                local lineColor = (moonlanceBranch2InPlayerRange and moonlanceMode == MOON_LANCE_SHOOTING) and TOUCHING.color or regularLineColor
                API.RadarDrawLine(x1, y1, qx, qy, lineThickness, lineColor)
            end
        end
    end
    
    local function anyoneClose(API, mapData)
        if not linesShown then return false end
        
        return eyesInPlayerRange or moonlanceMainInPlayerRange or moonlanceBranch1InPlayerRange or moonlanceBranch2InPlayerRange
    end
    
    local function resetLines()
        linesShown = false
    end
    
    local function showLines()
        linesShown = true
        moonlanceMode = MOON_LANCE_SEARCHING
    end
    
    local data = {
        version = 1,
        key = "echotyrande",
        groupkey = "echoofthepast",
        zone = L.zone["End Time"],
        category = L.zone["End Time"],
        name = "Echo of Tyrande",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-TyrandeWhisperwind.blp",
        triggers = {
            scan = {
                54544, -- Echo of Tyrande
            },
        },
        onactivate = {
            tracing = {
                54544,
            },
            phasemarkers = {
                {
                    {0.80, "Lunar Guidance","At 80 % HP, Tyrande starts casting 25% faster."},
                    {0.55, "Lunar Guidance","At 55 % HP, Tyrande starts casting 50% faster."},
                    {0.30, "Tears of Elune","At 30 % HP, Tears of Elune begin to rain from the sky."}
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 54544,
        },
        userdata = {
            -- Counters
            moonlancetime = 2,
            stardusttime = 3,
            guidancestacks = "0",
            
            -- Units
            moonlanceunit = "",
            
            -- Texts
            guidancetext = "",
            
            -- Switches
            moonlancecast = "no",
        },
        onstart = {
            {
                "repeattimer",{"checkhp", 1},
                "execute","showlines",
            },
        },
        
        filters = {
            bossemotes = {
                tearsemote = {
                    name = "Tears of Elune",
                    pattern = "%[Tears of Elune%] begin to rain from the sky.",
                    hasIcon = true,
                    hide = true,
                    texture = ST[102241],
                },
                guidanceemote = {
                    name = "Lunar Guidance",
                    pattern = "Tyrande gains %[Lunar Guidance%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[102472],
                },
            },
        },
        raidicons = {
            moonlancemark = {
                varname = format("%s {%s}",SN[102151],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 7,
                unit = "<moonlanceunit>",
                reset = 7,
                icon = 7,
                texture = ST[102151],
            },
        },
        functions = {
            showlines = showLines,
            seteyesmode = setEyesMode,
            setmoonlancemode = setMoonlanceMode,
            resetmoonlancetarget = resetMoonlanceTarget,
        },
        windows = {
			proxwindow = true,
			proxrange = 25,
			proxoverride = true,
            radarhandler = updateeyelines,
            nodistancecheck = true,
            customanyoneclose = anyoneClose,
            radarreset = resetLines,
		},
        radars = {
            eyesradar = {
                varname = SN[102606],
                type = "circle",
                x = 0.50746643543243,
                y = 0.44367617368698,
                range = 6,
                mode = "avoid",
                persist = 5,
                icon = ST[102606],
            },
        },
        ordering = {
            alerts = {"stardustwarn","moonlancewarn","eyeswarn","guidancewarn","tearssoonwarn","tearswarn"},
        },
        
        alerts = {            
            -- Stardust
            stardustwarn = {
                varname = format(L.alert["%s interrupt Warning"],SN[102173]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT"],SN[102173]),
                time = "<stardusttime>",
                color1 = "WHITE",
                sound = "ALERT2",
                icon = ST[102173],
                emphasizewarning = true,
            },
            -- Lunar Guidance
            guidancewarn = {
                varname = format(L.alert["%s Warning"],SN[102472]),
                type = "simple",
                text = "<guidancetext>",
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT1",
                icon = ST[102472],
            },
            -- Tears of Elune
            tearssoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[102241]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[102241]),
                time = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[102241],
            },
            tearswarn = {
                varname = format(L.alert["%s Warning"],SN[102241]),
                type = "simple",
                text = format(L.alert["%s"],SN[102241]),
                time = 1,
                color1 = "WHITE",
                sound = "BEWARE",
                icon = ST[102241],
            },
            -- Moonlance
            moonlancewarn = {
                varname = format(L.alert["%s Warning"],SN[102151]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[102151]),
                time = "<moonlancetime>",
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[102151],
            },
            -- Eyes of the Goddess
            eyeswarn = {
                varname = format(L.alert["%s Warning"],SN[102606]),
                type = "simple",
                text = format(L.alert["%s"],SN[102606]),
                time = 1,
                color1 = "BLUE",
                sound = "ALERT10",
                icon = ST[102606],
            },
            
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","40"},
                    "alert","tearssoonwarn",
                    "canceltimer","checkhp",
                },
            },
            moonlancetimer = {
                {
                    "raidicon","moonlancemark",
                    "set",{moonlancecast = "no"},
                    "canceltimer","moonlancetimer",
                },
            },
            deactivateeyeslinetimer = {
                {
                    "execute",{"seteyesmode",EYES_INACTIVE},
                },
            },
            moonlanceexpiretimer = {
                {
                    "execute",{"setmoonlancemode",MOON_LANCE_SEARCHING},
                    "execute","resetmoonlancetarget",
                },
            },
        },
        events = {
			-- Stardust
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 102173,
                execute = {
                    {
                        "alert","stardustwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[102173]},
                        "expect",{"#1#","find","boss"},
                        "quash","stardustwarn",
                    },
                },
            },
            -- Lunar Guidance
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 102472,
                execute = {
                    {
                        "set",{guidancestacks = "INCR|1"},
                        "set",{guidancetext = format(L.alert["%s (%s)"],SN[102472],"<guidancestacks>")},
                        "alert","guidancewarn",
                    },
                    {
                        "expect",{"<guidancestacks>","==","1"},
                        "set",{
                            stardusttime = 2.4,
                            moonlancetime = 1.6
                        },
                    },
                    {
                        "expect",{"<guidancestacks>","==","2"},
                        "set",{
                            stardusttime = 2,
                            moonlancetime = 1.333,
                        },
                    },
                },
            },
            -- Moonlance
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 102151,
                execute = {
                    {
                        "set",{
                            moonlanceunit = "&unitname|boss1target&",
                            moonlancecast = "yes",
                        },
                        "scheduletimer",{"moonlancetimer", 1},
                        "execute",{"setmoonlancemode",MOON_LANCE_CHARGING},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_TARGET",
                execute = {
                    {
                        "expect",{"<moonlancecast>","==","yes"},
                        "expect",{"#1#","==","boss1"},
                        "set",{moonlanceunit = "&unitname|boss1target&"}
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[102151]},
                        "expect",{"#1#","find","boss"},
                        "execute",{"setmoonlancemode",MOON_LANCE_SHOOTING},
                        "scheduletimer",{"moonlanceexpiretimer", 6.5},
                    },
                },
            },
            
            -- Eyes of the Goddess
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 102606,
                execute = {
                    {
                        "alert","eyeswarn",
                        "radar","eyesradar",
                        "execute",{"seteyesmode",EYES_ACTIVE},
                        "scheduletimer",{"deactivateeyeslinetimer", 7},
                    },
                },
            },
            
            -- Tears of Elune
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 102241,
                execute = {
                    {
                        "alert","tearswarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- MUROZOND
---------------------------------

do
    local data = {
        version = 2,
        key = "murozond",
        zone = L.zone["End Time"],
        category = L.zone["End Time"],
        name = "Murozond",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Murozond.blp",
        triggers = {
            scan = {
                54432, -- Murozond
            },
        },
        onactivate = {
            tracing = {
                54432,
            },
            counters = {"hourglasscounter"},
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 54432,
        },
        userdata = {
            hourglasscount = 5,
        },
        onstart = {
            {
                "alert","blastcd",
                "alert",{"breathcd",time = 2},
            },
        },
        
        counters = {
            hourglasscounter = {
                variable = "hourglasscount",
                label = "Rewind Time uses",
                value = 5,
                minimum = 0,
                maximum = 5,
            },
        },
        ordering = {
            alerts = {"blastcd","blastwarn","breathcd","breathwarn","bombselfwarn","rewindwarn","rewindduration","hourglassleftwarn"},
        },
 
        alerts = {
            -- Temporal Blast
            blastcd = {
                varname = format(L.alert["%s CD"],SN[102381]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[102381]),
                time = 12,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "LIGHTGREEN",
                sound = "MINORWARNING",
                icon = ST[102381],
                behavior = "overwrite",
            },
            blastwarn = {
                varname = format(L.alert["%s Warning"],SN[102381]),
                type = "simple",
                text = format(L.alert["%s"],SN[102381]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT7",
                icon = ST[102381],
            },
            -- Infinite Breath
            breathcd = {
                varname = format(L.alert["%s CD"],SN[102569]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[102569]),
                time = 22,
                time2 = 14,
                flashtime = 5,
                color1 = "MAGENTA",
                color2 = "VIOLET",
                sound = "MINORWARNING",
                icon = ST[102569],
                behavior = "overwrite",
                sticky = true,
            },
            breathwarn = {
                varname = format(L.alert["%s Warning"],SN[102569]),
                type = "simple",
                text = format(L.alert["%s"],SN[102569]),
                time = 1,
                color1 = "PINK",
                sound = "ALERT8",
                icon = ST[102569],
            },
            -- Rewind Time
            rewindwarn = {
                varname = format(L.alert["%s Warning"],SN[101591]),
                type = "simple",
                text = format(L.alert["%s"],SN[101591]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT9",
                icon = ST[101591],
                throttle = 1,
            },
            rewindduration = {
                varname = format(L.alert["%s Duration"],SN[101590]),
                type = "centerpopup",
                text = format(L.alert["%s"],"Rewinding time ..."),
                time = 5,
                color1 = "GOLD",
                sound = "None",
                icon = ST[101591],
                throttle = 1,
            },
            -- Hourglasses Left Warning
            hourglassleftwarn = {
                varname = format(L.alert["%s Warning"],"Hourglasses Left"),
                type = "simple",
                text = "<hourglasslefttext>",
                time = 1,
                color1 = "GOLD",
                sound = "MINORWARNING",
                texture = "Interface\\ICONS\\INV_Relics_Hourglass",
            },
            
            -- Distortion Bomb
            bombselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[101984]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[101984],L.alert["YOU"]),
                time = 1,
                color1 = "GOLD",
                sound = "ALERT10",
                icon = ST[101984],
                throttle = 2,
                emphasizewarning = true,
            },
        },
        timers = {
            rewindtimer = {
                {
                    "set",{hourglasscount = "DECR|1"},
                },
                {
                    "expect",{"<hourglasscount>",">","1"},
                    "set",{hourglasslefttext = format(L.alert["(%s %s)"],"<hourglasscount>","uses left")},
                },
                {
                    "expect",{"<hourglasscount>","==","1"},
                    "set",{hourglasslefttext = format(L.alert["(%s %s)"],"<hourglasscount>","use left")},
                },
                {
                    "expect",{"<hourglasscount>","==","0"},
                    "set",{hourglasslefttext = format(L.alert["(%s)"],"No uses left")},
                },
                {
                    "alert","hourglassleftwarn",
                },
            },
        },
        events = {
			-- Temporal Blast
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 102381,
                execute = {
                    {
                        "quash","blastcd",
                        "alert","blastcd",
                        "alert","blastwarn",
                    },
                },
            },
            -- Infinite Breath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 102569,
                execute = {
                    {
                        "quash","breathcd",
                        "alert","breathcd",
                        "alert","breathwarn",
                    },
                },
            },
            -- Rewind Time
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 101591,
                execute = {
                    {
                        "canceltimer","rewindtimer",
                        "scheduletimer",{"rewindtimer", 1},
                        "alert","rewindwarn",
                        "alert","rewindduration",
                        "alert","blastcd",
                    },
                },
            },
            -- Distortion Bomb
            {
                type = "combatevent",
                eventtype = "SPELL_PERIODIC_DAMAGE",
                spellname = 101984,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","bombselfwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- Trash
---------------------------------

do
    local data = {
        version = 1,
        key = "ettrash",
        zone = L.zone["End Time"],
        category = L.zone["End Time"],
        name = "Trash",
        triggers = {
            scan = {
                54552, -- Time-Twisted Breaker
                54543, -- Time-Twisted Drake
                54553, -- Time-Twisted Seer
                54920, -- Infinite Suppressor
                54923, -- Infinite Warden
                -- ID TRASHE U JAINY ------------------------------------------------
                54691, -- Time-Twisted Sorceress
                54690, -- Time-Twisted Priest
                54687, -- Time-Twisted Footman
                54693, -- Time-Twisted Rifleman
                
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {},

        raidicons = {
            suppressormark = {
                varname = format("%s {%s}","Infinite Suppressor","NPC_ENEMY"),
                type = "MULTIENEMY",
                persist = 5,
                unit = "<suppressorunit>",
                icon = 1,
                total = 4,
                texture = ST[102601],
            },
            sorceressmark = {
                varname = format("%s {%s}","Time-Twisted Sorceress","NPC_ENEMY"),
                type = "MULTIENEMY",
                persist = 5,
                unit = "<sorceressunit>",
                icon = 1,
                total = 2,
                texture = ST[101816],
            },
        },

        alerts = {
            -- Rupture Ground
            rupturewarn = {
                varname = format(L.alert["%s Warning"],SN[102124]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT"],SN[102124]),
                time = 4,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[102124],
                tag = "#1#",
            },
            
        },
        events = {
            -- Rupture Ground
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 102124,
                execute = {
                    {
                        "alert","rupturewarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    -- Time-Twisted Breaker dies
                    {
                        "expect",{"&npcid|#4#&","==","54552"},
                        "quash",{"rupturewarn","#4#"},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    -- Rupture Ground (interrupted)
                    {
                        "expect",{"#2#","==",SN[102124]},
                        "quash",{"rupturewarn","&unitguid|#1#&"},
                    },
                },
            },
            -- Arcane Wave
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 102601,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","54920"},
                        "set",{suppressorunit = "#1#"},
                        "raidicon","suppressormark",
                    },
                },
            },
            -- Arcane Blast
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 101816,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","54691"},
                        "set",{sorceressunit = "#1#"},
                        "raidicon","sorceressmark",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------
-- Instance Status Group --
---------------------------

do
    local data = {
        key = "echoofthepast",
        labels = {"First Echo","Second Echo"},
    }

    DXE:RegisterEncounterGroup(data)
end
