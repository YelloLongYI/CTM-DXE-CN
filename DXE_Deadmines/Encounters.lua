local L,SN,ST,SL,AL,AT,AN,TI = DXE.L,DXE.SN,DXE.ST,DXE.SL,DXE.AL,DXE.AT,DXE.AN,DXE.TI

---------------------------------
-- GLUBTOK
---------------------------------

do
    local data = {
        version = 2,
        key = "glubtok",
        zone = L.zone["The Deadmines"],
        category = L.zone["The Deadmines"],
        name = L.npc_deadmines["Glubtok"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Glubtok.blp",
        triggers = {
            scan = {
                47162, -- Glubtok
            },
        },
        onactivate = {
            tracing = {
                47162,
            },
            phasemarkers = {
                {
                    {0.5, "Phase 2","At 50% of his HP, the boss teleports to the middle of the room and Phase 2 begins."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 47162,
        },
        userdata = {
            blinkcd = {17, 14, loop = false, type = "series"},
            flamecd = {5, 26, loop = false, type = "series"},
            frostcd = {19, 26, loop = false, type = "series"},            
        },
        onstart = {
            {
                "alert","blinkcd",
                "alert","flamecd",
                "alert","frostcd",
                "repeattimer",{"checkhp", 1},
            },
        },
        
        filters = {
            bossemotes = {
                firewallemote = {
                    name = "Fire Wall",
                    pattern = "Glubtok creates a moving %[Fire Wall%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[2120],
                },
            },
        },
        ordering = {
            alerts = {"flamecd","flamewarn","frostcd","frostwarn","blinkcd","blinkwarn","phase2soonwarn","phase2warn","firewallcountdown"},
        },
        
        alerts = {           
            -- Blink
            blinkcd = {
                varname = format(L.alert["%s CD"],SN[87925]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[87925]),
                time = "<blinkcd>",
                color1 = "MAGENTA",
                color2 = "PINK",
                sound = "MINORWARNING",
                icon = ST[87925],
            },
            blinkwarn = {
                varname = format(L.alert["%s Warning"],SN[87925]),
                type = "simple",
                text = format(L.alert["%s"],SN[87925]),
                time = 1,
                color1 = "PINK",
                sound = "ALERT7",
                icon = ST[87925],
            },
            -- Fists of Flame
            flamecd = {
                varname = format(L.alert["%s CD"],SN[87859]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[87859]),
                time = "<flamecd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[87859],
            },
            flamewarn = {
                varname = format(L.alert["%s Warning"],SN[87859]),
                type = "simple",
                text = format(L.alert["%s"],SN[87859]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[87859],
            },
            -- Fists of Frost
            frostcd = {
                varname = format(L.alert["%s CD"],SN[87861]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[87861]),
                time = "<frostcd>",
                flashtime = 5,
                color1 = "CYAN",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[87861],
            },
            frostwarn = {
                varname = format(L.alert["%s Warning"],SN[87861]),
                type = "simple",
                text = format(L.alert["%s"],SN[87861]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT2",
                icon = ST[87861],
            },
            -- Phase 2
            phase2soonwarn = {
                varname = format(L.alert["%s soon Warning"],"Phase 2"),
                type = "simple",
                text = format(L.alert["%s soon ..."],"Phase 2"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[88009],
            },
            phase2warn = {
                varname = format(L.alert["%s Warning"],"Phase 2"),
                type = "simple",
                text = format(L.alert["%s"],"Phase 2"),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT1",
                icon = ST[88009],
            },
            -- Fire Wall
            firewallcountdown = {
                varname = format(L.alert["%s activation Countdown"],"Fire Wall"),
                type = "centerpopup",
                text = format(L.alert["%s activates"],"Fire Wall"),
                time = 4,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[2120],
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","60"},
                    "alert","phase2soonwarn",
                    "canceltimer","checkhp",
                },
            },
        },
        events = {
			-- Blink
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 87925,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","47162"},
                        "quash","blinkcd",
                        "alert","blinkcd",
                        "alert","blinkwarn",
                    },
                },
            },
            -- Fists of Flame
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 87859,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","47162"},
                        "quash","flamecd",
                        "alert","flamecd",
                        "alert","flamewarn",
                    },
                },
            },
            -- Fists of Frost
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 87861,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","47162"},
                        "quash","frostcd",
                        "alert","frostcd",
                        "alert","frostwarn",
                    },
                },
            },
            -- Phase 2
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_deadmines["^Glubtok ready"]},
                        "alert","phase2warn",
                        "quash","flamecd",
                        "quash","frostcd",
                        "quash","blinkcd",
                        "expect",{"&difficulty&","==","2"},
                        "schedulealert",{"firewallcountdown", 5},
                    },
                },
            },           
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- HELIX GEARBREAKER
---------------------------------

do
    local data = {
        version = 3,
        key = "helix",
        zone = L.zone["The Deadmines"],
        category = L.zone["The Deadmines"],
        name = L.npc_deadmines["Helix Gearbreaker"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Helix Gearbreaker.blp",
        icon2 = "Interface\\EncounterJournal\\UI-EJ-BOSS-Lumbering Oaf.blp",
        triggers = {
            scan = {
                47297,  -- Lumbering Oaf
                47296, -- Helix Gearbreaker
            },
        },
        onactivate = {
            tracing = {
                47297, -- Lumbering Oaf
            },
            tracerstart = true,
            combatstop = true,
            combatstart = false,
            defeat = 47296, -- Helix Gearbreaker
        },
        userdata = {
            chargecd = {15, 50, loop = false, type = "series"},
            chargetext = "",
            helixjumpcd = {35, 52, loop = false, type = "series"},
            helixjumptext = "",
        },
        onstart = {
            {
                "alert","chargecd",
                "alert","helixjumpcd",
            },
        },
        
        filters = {
            bossemotes = {
                bombemote = {
                    name = SN[88352],
                    pattern = "attaches a bomb to",
                    hasIcon = false,
                    texture = ST[88352],
                },
            },
        },
        windows = {
			proxwindow = true,
			proxrange = 18,
            proxnoauto = true,
			proxoverride = true,
            nodistancecheck = true
		},
        radars = {
            bombradar = {
                varname = SN[88352],
                type = "circle",
                player = "#5#",
                range = 6,
                mode = "avoid",
                icon = SN[88352],
            },
        },
        ordering = {
            alerts = {"chargecd","chargewarn","helixjumpcd","helixjumpwarn","helixattachedduration","chestbombwarn","chestbombduration","phase2warn"},
        },

        alerts = {
            -- Charge
            chargecd = {
                varname = format(L.alert["%s CD"],SN[88288]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[88288]),
                time = "<chargecd>",
                flashtime = 5,
                color1 = "WHITE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[88288],
            },
            chargewarn = {
                varname = format(L.alert["%s Warning"],SN[88288]),
                type = "simple",
                text = "<chargetext>",
                time = 1,
                color1 = "WHITE",
                sound = "ALERT2",
                icon = ST[88288],
            },
            -- Helix Jump
            helixjumpcd = {
                varname = format(L.alert["%s CD"],"Helix Jump"),
                type = "dropdown",
                text = format(L.alert["Next %s"],"Helix's jump"),
                time = "<helixjumpcd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "PEACH",
                sound = "MINORWARNING",
                icon = ST[6544],
            },
            helixjumpwarn = {
                varname = format(L.alert["%s Warning"],"Helix Jump"),
                type = "simple",
                text = "<helixjumptext>",
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT1",
                icon = ST[6544],
            },
            helixattachedduration = {
                varname = format(L.alert["%s Duration"],"Helix attached"),
                type = "centerpopup",
                text = format(L.alert["%s"],"Helix attached"),
                time = 10,
                color1 = "PURPLE",
                sound = "None",
                icon = ST[60533],
            },
            -- Chest Bomb
            chestbombwarn = {
                varname = format(L.alert["%s Warning"],SN[88352]),
                type = "simple",
                text = "<chestbombtext>",
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT8",
                icon = ST[88352],
            },
            chestbombduration = {
                varname = format(L.alert["%s Countdown"],SN[88352]),
                type = "centerpopup",
                text = "<chestbombtext>",
                time = 10,
                color1 = "YELLOW",
                sound = "None",
                icon = ST[88352],
            },
            phase2warn = {
                varname = format(L.alert["Phase 2 Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"2"),
                time = 1,
                color1 = "TURQUOISE",
                icon = ST[11242],
                sound = "MINORWARNING",
            },
        },
        events = {
			-- Charge
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 88288,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","47297"},
                        "quash","chargecd",
                        "alert","chargecd",
                        "set",{chargetext = format(L.alert["Lumbering Oaf picks up <%s>"],"#5#")},
                        "alert","chargewarn",
                    },
                },
            },
            -- Helix throw
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_deadmines["^Ready Oafie"]},
                        "quash","helixjumpcd",
                        "alert","helixjumpcd",
                        "set",{helixjumptext = format(L.alert["%s"],"Oaf throws Helix!")},
                        "alert","helixjumpwarn",
                        "alert","helixattachedduration",
                    },
                },
            },
            -- Chest Bomb
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 88352,
                execute = {
                    {
                        "set",{chestbombtext = format(L.alert["%s puts %s on <%s>"],"Helix", SN[88352], "#5#")},
                        "alert","chestbombwarn",
                        "set",{chestbombtext = format(L.alert["%s on <%s>"],SN[88352],"#5#")},
                        "alert","chestbombduration",
                        "range",{true},
                        "radar","bombradar",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 88352,
                execute = {
                    {
                        "removeradar",{"bombradar", player = "#5#"},
                        "range",{false},
                    },
                },
            },
            
            -- Phase 2
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_deadmines["^I didn't need him"]},
                        "alert","phase2warn",
                        "tracing",{47296},
                        "quash","helixjumpcd",
                        "quash","chargecd",
                    },
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- FOE REAPER 5000
---------------------------------

do
    local data = {
        version = 3,
        key = "foereaper",
        zone = L.zone["The Deadmines"],
        category = L.zone["The Deadmines"],
        name = L.npc_deadmines["Foe Reaper 5000"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Foe Reaper 5000.blp",
        triggers = {
            scan = {
                43778, -- Foe Reaper 5000
            },
        },
        onactivate = {
            tracing = {
                43778,
            },
            phasemarkers = {
                {
                    {0.30, "Safety Restrictions Off-line","At 30% of his HP, the boss will increase his damage by 100%."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 43778,
        },
        userdata = {
            harvestcd = {15, 40, loop = false, type = "series"},
            harvestcasttext = "",
            harvestcasting = "no",
            harvesttargetGUID = "",
            harvesttargetName = "",
            overdrivecd = {25, 50, loop = false, type = "series"},
        },
        onstart = {
            {
                "alert","harvestcd",
                "alert","overdrivecd",
            },
        },

        arrows = {
            harvestarrow = {
                varname = format("%s",SN[88495]),
                unit = "<harvesttargetName>",
                persist = 10,
                action = "AWAY",
                msg = L.alert["STAY AWAY"],
                spell = SN[88495],
                sound = "None",
                rangeStay = 20,
                range1 = 0,
                range2 = 10,
                range3 = 15,
                texture = ST[88495],
            }
        },
        raidicons = {
            harvestmark = {
                varname = format("%s {%s}",SN[88495],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 5,
                unit = "<harvesttargetName>",
                reset = 10,
                icon = 1,
                texture = ST[88495],
            },
            slagmarkmark = {
                varname = format("%s {%s}","Molten Slag","NPC_ENEMY"),
                type = "ENEMY",
                persist = 5,
                unit = "#1#",
                reset = 20,
                icon = 2,
                texture = ST[63536],
            },
        },
        filters = {
            bossemotes = {
                overdriveemote = {
                    name = "Overdrive",
                    pattern = "begins to activate %[Overdrive%]",
                    hasIcon = true,
                    texture = ST[88481],
                },
                moltenslugemote = {
                    name = "Molten Slug",
                    pattern = "molten slag begins to bubble",
                    hasIcon = false,
                    texture = ST[63536],
                },
                enrageemote = {
                    name = "Safety Restrictions Off-line",
                    pattern = "Foe Reaper 5000 %[Safety Restrictions are Off%-line%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[91720],
                },
            },
        },
        ordering = {
            alerts = {"harvestcd","harvestcast","harvestselfwarn","harvestclosewarn","overdrivecd","overdriveduration","safetywarn"},
        },

        alerts = {
            -- Harvest
            harvestcd = {
                varname = format(L.alert["%s CD"],SN[88495]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[88495]),
                time = "<harvestcd>",
                flashtime = 5,
                color1 = "BROWN",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[88495],
            },
            harvestcast = {
                varname = format(L.alert["%s Cast"],SN[88495]),
                type = "centerpopup",
                text = "<harvestcasttext>",
                time = 5,
                color1 = "ORANGE",
                sound = "ALERT1",
                icon = ST[88495],
            },
            harvestselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[88495]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[88495],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[88495],
                emphasizewarning = true,
            },
            harvestclosewarn = {
                varname = format(L.alert["%s near me Warning"],SN[88495]),
                type = "simple",
                text = format(L.alert["%s near %s - GET AWAY!"],SN[88495],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[88495],
            },
            -- Overdrive
            overdrivecd = {
                varname = format(L.alert["%s CD"],SN[88481]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[88481]),
                time = "<overdrivecd>",
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[88481],
            },
            overdriveduration = {
                varname = format(L.alert["%s Warning"],SN[88481]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[88481]),
                time = 13,
                color1 = "CYAN",
                sound = "BEWARE",
                icon = ST[88481],
            },
            -- Safety Restrictions Off-line
            safetywarn = {
                varname = format(L.alert["%s Warning"],SN[91720]),
                type = "simple",
                text = format(L.alert["%s"],SN[91720]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT7",
                icon = ST[91720],
            },
            
        },
        timers = {
            harvesttimer = {
                {
                    "expect",{"<harvestcasting>","==","yes"},
                    "set",{harvesttargetGUID = "&unitguid|boss1target&"},
                    "set",{harvesttargetName = "&unitname|boss1target&"},
                    "raidicon","harvestmark",
                    "arrow","harvestarrow",
                },
                {
                    "expect",{"<harvestcasting>","==","yes"},
                    "expect",{"<harvesttargetGUID>","==","&playerguid&"},
                    "set",{harvestcasttext = format(L.alert["%s on %s"],SN[88495],L.alert["YOU"])},
                    "alert","harvestselfwarn",
                },
                {
                    "expect",{"<harvestcasting>","==","yes"},
                    "expect",{"<harvesttargetGUID>","~=","&playerguid&"},
                    "set",{harvestcasttext = format(L.alert["%s on <%s>"],SN[88495],"<harvesttargetName>")},
                    "expect",{"&getdistance|<harvesttargetGUID>&","<=",10},
                    "alert","harvestclosewarn",
                },
                {
                    "expect",{"<harvestcasting>","==","yes"},
                    "alert","harvestcast",
                    "set",{harvestcasting = "no"},
                },
            },
        },
        events = {
			-- Harvest
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 88495,
                execute = {
                    {
                        "set",{harvestcasting = "yes"},
                        "scheduletimer",{"harvesttimer", 0.3},
                    },
                    {
                        "quash","harvestcd",
                        "alert","harvestcd",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_TARGET",
                execute = {
                    {
                        "expect",{"<harvestcasting>","==","yes"},
                        "expect",{"#1#","==","boss1"},
                        "set",{harvesttargetGUID = "&unitguid|boss1target&"},
                        "set",{harvesttargetName = "&unitname|boss1target&"},
                        "raidicon","harvestmark",
                        "arrow","harvestarrow",
                    },
                    {
                        "expect",{"<harvestcasting>","==","yes"},
                        "expect",{"#1#","==","boss1"},
                        "expect",{"<harvesttargetGUID>","==","&playerguid&"},
                        "set",{harvestcasttext = format(L.alert["%s on %s"],SN[88495],L.alert["YOU"])},
                        "alert","harvestselfwarn",
                    },
                    {
                        "expect",{"<harvestcasting>","==","yes"},
                        "expect",{"#1#","==","boss1"},
                        "expect",{"<harvesttargetGUID>","~=","&playerguid&"},
                        "set",{harvestcasttext = format(L.alert["%s on <%s>"],SN[88495],"<harvesttargetName>")},
                        "expect",{"&getdistance|<harvesttargetGUID>&","<=",10},
                        "alert","harvestclosewarn",
                    },
                    {
                        "expect",{"<harvestcasting>","==","yes"},
                        "expect",{"#1#","==","boss1"},
                        "alert","harvestcast",
                        "set",{harvestcasting = "no"},
                        "canceltimer","harvesttimer",
                    },
                },
            },
            -- Harvest (finish)
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[88497]},
                        "expect",{"#1#","find","boss"},
                        "removearrow","<harvesttargetName>",
                    },
                },
            },
            
            
            -- Molten Slag marking & tracing
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 91815,
                execute = {
                    {
                        "temptracing","#1#",
                        "raidicon","slagmarkmark",
                    },
                },
            },
            -- Overdrive
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 88481,
                execute = {
                    {
                        "quash","overdrivecd",
                        "alert","overdrivecd",
                        "alert","overdriveduration",
                    },
                },
            },
            -- Safety Restrictions Off-line
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 91720,
                execute = {
                    {
                        "alert","safetywarn",
                    },
                },
            },
            
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ADMIRAL RIPSNARL
---------------------------------

do
    local data = {
        version = 5,
        key = "ripsnarl",
        zone = L.zone["The Deadmines"],
        category = L.zone["The Deadmines"],
        name = L.npc_deadmines["Admiral Ripsnarl"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Admiral Ripsnarl.blp",
        triggers = {
            scan = {
                47626, -- Admiral Ripsnarl
            },
        },
        onactivate = {
            tracing = {
                47626,
            },
            phasemarkers = {
                {
                    {0.75, "The Fog","At 75% of his HP, the boss disappears into the fog for a short amount of time."},
                    {0.50, "The Fog","At 50% of his HP, the boss disappears into the fog for a short amount of time."},
                    {0.25, "The Fog","At 25% of his HP, the boss disappears into the fog for a short amount of time."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 47626,
        },
        userdata = {
            fog1warned = "no",
            fog2warned = "no",
            fog3warned = "no",
            vaporcount = 0,
        },
        onstart = {
            {
                "repeattimer",{"checkhp", 1},
                "counter","vaporcounter",
            },
        },
        
        raidicons = {
            vapormark = {
                varname = format("%s {%s-%s}",SN[92042],"ENEMY_CAST","Swirling Vapor's"),
                type = "MULTIENEMY",
                persist = 10,
                unit = "#1#",
                reset = 10,
                icon = 6,
                total = 3,
                texture = ST[92042],
            },
        },
        counters = {
            vaporcounter = {
                variable = "vaporcount",
                label = format("%s Swirling Vapors coalesced",TI["AchievementShield"]),
                pattern = "%d / %d",
                value = 0,
                minimum = 0,
                maximum = 3,
                difficulty = 2,
            },
        },
        phrasecolors = {
            {"Swirling Vapor","GOLD"},
        },
        ordering = {
            alerts = {"vanishsoonwarn","vanishwarn","coalescewarn"},
        },
        
        alerts = {
            -- The Fog soon
            vanishsoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[88840]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[88840]),
                time = 1,
                color1 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[88840],
            },
            -- Vanish
            vanishwarn = {
                varname = format(L.alert["%s Warning"],SN[88840]),
                type = "simple",
                text = format(L.alert["%s"],SN[88840]),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT7",
                icon = ST[88840],
            },
            -- Coalesce
            coalescewarn = {
                varname = format(L.alert["%s Warning"],SN[92042]),
                type = "centerpopup",
                warningtext = format(L.alert["Swirling Vapor begins to %s"],SN[92042]),
                text =  format(L.alert["%s"],SN[92042]),
                time = 5,
                color1 = "WHITE",
                sound = "ALERT10",
                icon = ST[92042],
                tag = "#1#",
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","80"},
                    "expect",{"<fog1warned>","==","no"},
                    "set",{fog1warned = "yes"},
                    "alert","vanishsoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","55"},
                    "expect",{"<fog2warned>","==","no"},
                    "set",{fog2warned = "yes"},
                    "alert","vanishsoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","30"},
                    "expect",{"<fog3warned>","==","no"},
                    "set",{fog3warned = "yes"},
                    "alert","vanishsoonwarn",
                },
                {
                    "expect",{"<fog1warned>","==","yes"},
                    "expect",{"<fog2warned>","==","yes"},
                    "expect",{"<fog3warned>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
        },
        events = {
            -- Vanish
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[88840]},
                        "expect",{"#1#","==","boss1"},
                        "alert","vanishwarn",
                    },
                },
            },
            -- Coalesce
            {
                type = "combatevent",
                eventtype = "SPELL_INSTAKILL",
                spellname = 92042,
                execute = {
                    {
                        "set",{vaporcount = "INCR|1"},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92042,
                execute = {
                    {
                        "alert","coalescewarn",
                        "raidicon","vapormark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","47714"},
                        "quash",{"coalescewarn","#4#"},
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- "CAPTAIN" COOKIE
---------------------------------

do
    local data = {
        version = 1,
        key = "cookie",
        zone = L.zone["The Deadmines"],
        category = L.zone["The Deadmines"],
        name = L.npc_deadmines["\"Captain\" Cookie"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Captain Cookie.blp",
        triggers = {
            scan = {
                47739, -- "Captain" Cookie
            },
        },
        onactivate = {
            tracing = {
                47739,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 47739,
        },
        userdata = {},
        onstart = {},
        
        alerts = {
            -- Rotten Aura
            rottenselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[92065]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[92065],L.alert["YOU"]),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT10",
                icon = ST[92065],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
        },
        events = {
			-- Rotten Aura
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 92065,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","rottenselfwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- VANESSA VANCLEEF
---------------------------------

do
    local data = {
        version = 2,
        key = "vanessa",
        zone = L.zone["The Deadmines"],
        category = L.zone["The Deadmines"],
        name = L.npc_deadmines["Vanessa VanCleef"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Vanessa VanCleef.blp",
        triggers = {
            scan = {
                49541, -- Vanessa Van Cleef
            },
        },
        onactivate = {
            tracing = {
                49541,
            },
            phasemarkers = {
                {
                    {0.5, "Fiery Blaze","At 50% of her HP, Vanessa leaps to the top of the ship and detonates explosives all around the ship."},
                    {0.25, "Fiery Blaze","At 25% of her HP, Vanessa leaps to the top of the ship and detonates explosives all around the ship."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 49541,
        },
        userdata = {
            deflectioncd = {10, 50, loop = false, type = "series"},
            blaze1warned = "no",
            blaze2warned = "no",
        },
        onstart = {
            {
                "alert","deflectioncd",
                "repeattimer",{"checkhp", 1},
            },
        },
        
        filters = {
            bossemotes = {
                explosivesemote = {
                    name = "Fiery Blaze",
                    pattern = "This entire ship is rigged with explosives",
                    hasIcon = false,
                    texture = ST[93484],
                },
                detonatingemote = {
                    name = "Deatonating charges",
                    pattern = "is detonating more charges",
                    hasIcon = false,
                    texture = ST[52417],
                },
                finalbombemote = {
                    name = "Final bomb",
                    pattern = "pulls out a final barrel",
                    hasIcon = false,
                    texture = ST[52417],
                },
            },
        },
        ordering = {
            alerts = {"deflectioncd","deflectionwarn","blazesoonwarn"},
        },
        
        alerts = {
            -- Deflection
            deflectioncd = {
                varname = format(L.alert["%s CD"],SN[92614]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92614]),
                time = "<deflectioncd>",
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[92614],
            },
            deflectionwarn = {
                varname = format(L.alert["%s Warning"],SN[92614]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s"],SN[92614]),
                time = 10,
                color1 = "LIGHTBLUE",
                sound = "ALERT6",
                icon = ST[92614],
            },
            -- Fiery Blaze
            blazesoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[6297]),
                type = "simple",
                emphasizewarning = true,
                text = format(L.alert["%s soon, get ready for ropes"],SN[6297]),
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[6297],
            },           
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","60"},
                    "expect",{"<blaze1warned>","==","no"},
                    "set",{blaze1warned = "yes"},
                    "alert","blazesoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","35"},
                    "expect",{"<blaze2warned>","==","no"},
                    "set",{blaze2warned = "yes"},
                    "alert","blazesoonwarn",
                },
                {
                    "expect",{"<blaze1warned>","==","yes"},
                    "expect",{"<blaze2warned>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
        },
        events = {
			-- Deflection
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 92614,
                execute = {
                    {
                        "quash","deflectioncd",
                        "alert","deflectioncd",
                        "alert","deflectionwarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- VANESSA VANCLEEF (GAUNTLET)
---------------------------------

do
    local data = {
        version = 1,
        key = "vanessaevent",
        zone = L.zone["The Deadmines"],
        category = L.zone["The Deadmines"],
        name = "The Nightmare",
        icon = {"Interface\\ICONS\\Achievement_Boss_EdwinVancleef",true},
        icon2 = {"Interface\\ICONS\\Achievement_Boss_Bazil_Thredd",true},
        advanced = {
            disableAutoWipe = true,
        },
        triggers = {
            boss_emote = L.chat_deadmines["^Vanessa injects you with the"],
        },
        onactivate = {
            tracerstart = false,
            combatstop = false,
            combatstart = false,
        },
        userdata = {},
        onstart = {
            {
                "alert","vindicatorcd",
                "scheduletimer",{"vindicatortimer", 300},
            },
        },
        
        announces = {
            vindicatorfailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5371,
                msg = format(L.alert["<DXE> %s: Achievement failed!"],AL[5371]),
                throttle = true,
            },
        },
        
        alerts = {
            --  Vigorous VanCleef Vindicator
            vindicatorcd = {
                varname = format(L.alert["%s %s Countdown"],TI["AchievementShield"],AN[5371]),
                type = "dropdown",
                text = format(L.alert["%s"],AN[5371]),
                time = 300,
                flashtime = 20,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = AT[5371],
                audiocd = true,
            },
            
        },
        timers = {
            vindicatortimer = {
                {
                    "announce","vindicatorfailed",
                },
            },
        },
        events = {},
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- TRASH
---------------------------------

do
    local data = {
        version = 2,
        key = "deadminestrash",
        zone = L.zone["The Deadmines"],
        category = L.zone["The Deadmines"],
        name = "Trash",
        triggers = {
            scan = {
                -- Pre-FoeReaper Trash
                48418, -- Defias Envoker
                48419, -- Defias Miner
                48421, -- Defias Overseer
                
                -- Boat Trash
                48521, -- Defias Squallshaper
                48522, -- Defias Pirate
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {},
        
        raidicons = {
            holyfiremark = {
                varname = format("%s {%s-%s}",SN[91005],"ENEMY_CAST","Defias Evoker's"),
                type = "MULTIENEMY",
                unit = "#1#",
                reset = 60,
                icon = 1,
                total = 2,
                remove = true,
                texture = ST[91005],
            },
            seaswellmark = {
                varname = format("%s {%s-%s}",SN[90912],"ENEMY_CAST","Defias Squallshaper's"),
                type = "MULTIENEMY",
                unit = "#1#",
                reset = 60,
                icon = 1,
                total = 2,
                texture = ST[90912],
            },
        },
        phrasecolors = {
            {"Defias Envoker","GOLD"},
            {"Defias Squallshaper","GOLD"},
        },
        ordering = {
            alerts = {"holyfirewarn","seaswellwarn"},
        },
        
        alerts = {
            -- Holy Fire
            holyfirewarn = {
                varname = format(L.alert["%s Warning"],SN[91005]),
                type = "centerpopup",
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Defias Envoker",SN[91005]),
                text = format(L.alert["%s - INTERRUPT"],SN[91005]),
                time = 5,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[91005],
                tag = "#1#",
            },
            -- Seaswell
            seaswellwarn = {
                varname = format(L.alert["%s Warning"],SN[90912]),
                type = "centerpopup",
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Defias Squallshaper", SN[90912]),
                text = format(L.alert["%s - INTERRUPT"],SN[90912]),
                time = 3,
                color1 = "CYAN",
                sound = "ALERT2",
                icon = ST[90912],
                tag = "#1#",
            },
        },
        events = {
            -- Holy Fire
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91005,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","48418"},
                        "alert","holyfirewarn",
                        "raidicon","holyfiremark",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[91005]},
                        "expect",{"&unitisplayertype|#1#&","==","false"},
                        "quash",{"holyfirewarn","&unitguid|#1#&"},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","48418"},
                        "quash",{"holyfirewarn","#4#"},
                    },
                },
            },
            
            -- Seaswell
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 90912,
                execute = {
                    {
                        "alert","seaswellwarn",
                        "raidicon","seaswellmark",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[90912]},
                        "expect",{"&unitisplayertype|#1#&","==","false"},
                        "quash",{"seaswellwarn","&unitguid|#1#&"},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","48521"},
                        "quash",{"seaswellwarn","#4#"},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end
