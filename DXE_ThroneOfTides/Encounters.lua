local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- LADY NAZ'JAR
---------------------------------

do
    local data = {
        version = 3,
        key = "ladynazjar",
        zone = L.zone["Throne of Tides"],
        category = L.zone["Throne of the Tides"],
        name = "Lady Naz'jar",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Lady NazJar.blp",
        triggers = {
            scan = {
                40586, -- Lady Naz'jar
            },
        },
        onactivate = {
            tracing = {
                40586,
            },
            phasemarkers = {
                {
                    {0.66, "Waterspout","At 66% of her HP, Lady Naz'jar begins to channel Waterspout."},
                    {0.33, "Waterspout","At 33% of her HP, Lady Naz'jar begins to channel Waterspout."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 40586,
        },
        userdata = {
            waterspout1warned = "no",
            waterspout2warned = "no",
            geyserclosetext = "",
        },
        onstart = {
            {
                "alert","blastcd",
                "repeattimer",{"checkhp", 1},
            },
        },
        ordering = {
            alerts = {"sporesselfwarn","geyserselfwarn","geyserclosewarn","blastcd","blastwarn","waterspoutsoonwarn","waterspoutwarn"},
        },
        
        alerts = {
            -- Fungal Spores
            sporesselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[76001]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[76001],L.alert["YOU"]),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT8",
                icon = ST[76001],
            },
            -- Summon Geyser
            geyserselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[75722]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[75722],L.alert["YOU"]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT10",
                icon = ST[75722],
                emphasizewarning = true,
            },
            geyserclosewarn = {
                varname = format(L.alert["%s near me Warning"],SN[75722]),
                type = "simple",
                text = format(L.alert["%s near %s - MOVE AWAY!"],SN[75722],L.alert["YOU"]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT10",
                icon = ST[75722],
            },
            -- Shock Blast
            blastcd = {
                varname = format(L.alert["%s CD"],SN[91477]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91477]),
                time = 12,
                flashtime = 5,
                color1 = "INDIGO",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[91477],
            },
            blastwarn = {
                varname = format(L.alert["%s Warning"],SN[91477]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[91477]),
                time = 2,
                color1 = "CYAN",
                sound = "ALERT2",
                icon = ST[91477],
            },
            -- Waterspout
            waterspoutsoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[75683]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[75683]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            waterspoutwarn = {
                varname = format(L.alert["%s Warning"],SN[75683]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[75683]),
                time = 60,
                color1 = "CYAN",
                color2 = "ORANGE",
                sound = "ALERT1",
                icon = ST[75683],
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","70"},
                    "expect",{"<waterspout1warned>","==","no"},
                    "set",{waterspout1warned = "yes"},
                    "alert","waterspoutsoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","40"},
                    "expect",{"<waterspout2warned>","==","no"},
                    "set",{waterspout2warned = "yes"},
                    "alert","waterspoutsoonwarn",
                },
                {
                    "expect",{"<waterspout1warned>","==","yes"},
                    "expect",{"<waterspout2warned>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
        },
        events = {
			-- Fungal Spores
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 76001,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","sporesselfwarn",
                    },
                },
            },
            -- Summon Geyser
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 75722,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","geyserselfwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "expect",{"&getdistance|#4#&","<", 5},
                        "alert","geyserclosewarn",
                    },
                },
            },
            -- Shock Blast
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91477,
                execute = {
                    {
                        "quash","blastcd",
                        "alert","blastcd",
                        "alert","blastwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[91477]},
                        "expect",{"#1#","find","boss"},
                        "quash","blastwarn",
                    },
                },
            },
            -- Waterspout
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 75683,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","40586"},
                        "quash","blastcd",
                        "alert","waterspoutwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 75683,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","40586"},
                        "quash","waterspoutwarn",
                        "alert","blastcd",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- COMMANDER ULTHOK
--    the Festering Prince
---------------------------------

do
    local data = {
        version = 2,
        key = "ulthok",
        zone = L.zone["Throne of Tides"],
        category = L.zone["Throne of the Tides"],
        name = "Commander Ulthok",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Commander Ulthok.blp",
        triggers = {
            scan = {
                40765, -- Commander Ulthok,
            },
        },
        onactivate = {
            tracing = {
                40765,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 40765,
        },
        userdata = {
            fissurecd = {10, 20, loop = false, type = "series"},
            enragecd = {20, 10, loop = false, type = "series"},
            squeezetext = "",
        },
        onstart = {
            {
                "alert","fissurecd",
                "alert","enragecd",
                "alert","squeezecd",
            },
        },
        ordering = {
            alerts = {"fissurecd","fissurewarn","fissureselfwarn","enragecd","enragewarn","squeezecd","squeezedurwarn"},
        },
        
        alerts = {
            -- Dark Fissure
            fissurecd = {
                varname = format(L.alert["%s CD"],SN[96311]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96311]),
                time = "<fissurecd>",
                flashtime = 5,
                color1 = "VIOLET",
                color2 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[96311],
            },
            fissurewarn = {
                varname = format(L.alert["%s Warning"],SN[96311]),
                type = "simple",
                text = format(L.alert["%s"],SN[96311]),
                time = 1,
                color1 = "VIOLET",
                sound = "ALERT2",
                icon = ST[96311],
            },
            fissureselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[76085]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[76085], L.alert["YOU"]),
                time = 1,
                color1 = "PINK",
                sound = "ALERT10",
                icon = ST[76085],
                throttle = 2,
                emphasizewarning = true,
            },
            -- Enrage
            enragecd = {
                varname = format(L.alert["%s CD"],SN[76100]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[76100]),
                time = "<enragecd>",
                flashtime = 5,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[76100],
            },
            enragewarn = {
                varname = format(L.alert["%s Warning"],SN[76100]),
                type = "simple",
                text = format(L.alert["%s"],SN[76100]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT7",
                icon = ST[76100],
            },
            -- Squeeze
            squeezecd = {
                varname = format(L.alert["%s CD"],SN[91484]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91484]),
                time = 30,
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[91484],
            },
            squeezedurwarn = {
                varname = format(L.alert["%s Duration"],SN[91484]),
                type = "centerpopup",
                text = "<squeezetext>",
                time = 6,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[91484],
            },
        },
        events = {
			-- Dark Fissure
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96311,
                execute = {
                    {
                        "quash","fissurecd",
                        "alert","fissurecd",
                        "alert","fissurewarn",
                    },
                },
            },
            -- Enrage
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 76100,
                execute = {
                    {
                        "quash","enragecd",
                        "alert","enragecd",
                        "alert","enragewarn",
                    },
                },
            },
            -- Squeeze
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91484,
                execute = {
                    {
                        "quash","squeezecd",
                        "alert","squeezecd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 91484,
                execute = {
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{squeezetext = format(L.alert["%s on <%s>"],SN[91484],"#5#")},
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{squeezetext = format(L.alert["%s on %s"],SN[91484],L.alert["YOU"])},
                    },
                    {
                        "alert","squeezedurwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 91484,
                execute = {
                    {
                        "quash","squeezedurwarn",
                    },
                },
            },
           
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 76085,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","fissureselfwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- MINDBENDER GHUR'SHA
---------------------------------

do
    local data = {
        version = 4,
        key = "ghursha",
        zone = L.zone["Throne of Tides"],
        category = L.zone["Throne of the Tides"],
        name = "Mindbender Ghur'sha",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Mindbender Ghursha.blp",
        advanced = {
            advancedwipedetection = true,
        },
        triggers = {
            scan = {
                40825, -- Erunak Stonespeaker
                40788, -- Mindbender Ghur'sha
            },
        },
        onactivate = {
            tracing = {
                40825,
            },
            phasemarkers = {
                {
                    {0.5, "Mindbender Ghur'sha detaches","At 50% of Erunak's HP, Mindbender Ghur'sha detaches."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 40788,
        },
        userdata = {
            boltcd = {8, 10, loop = false, type = "series"},
            erunakGUID = "none",
            absorbcd = {12, 20, loop = false, type = "series"},
            enslaveduration = 60,
            enslavetext = "",
            enslavedurationtext = "",
            enslave2cd = 10,
            lookingforhost = "no",
        },
        onstart = {
            {
                "alert","boltcd",
                "repeattimer",{"checkhp", 1},
                
            },
            {
                "expect",{"&difficulty&","==","2"},
                "set",{enslaveduration = 30},
                "set",{enslave2cd = 8},
            },
        },
        phrasecolors = {
            {"Mindbender Ghur'sha","GOLD"},
        },
        ordering = {
            alerts = {"boltcd","boltwarn","detachsoonwarn","detachwarn","enslavecd","enslavewarn","enslaveduration","absorbcd","absorbwarn","absorbduration","fogselfwarn"},
        },
        
        alerts = {
            -- Lava Bolt
            boltcd = {
                varname = format(L.alert["%s CD"],SN[76171]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[76171]),
                time = "<boltcd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[76171],
            },
            boltwarn = {
                varname = format(L.alert["%s Warning"],SN[76171]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[76171]),
                time = 3,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[76171],
            },
            -- Mindbender Ghur'sha detachment
            detachsoonwarn = {
                varname = format(L.alert["%s soon Warning"],"Mindbender Ghur'sha detaches"),
                type = "simple",
                text = format(L.alert["%s soon ..."],"Mindbender Ghur'sha detaches"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[56129],
            },
            detachwarn = {
                varname = format(L.alert["%s Warning"],"Mindbender Ghur'sha detached"),
                type = "simple",
                text = format(L.alert["%s!"],"Mindbender Ghur'sha detached"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT1",
                icon = ST[11242],
                throttle = 5,
            },
            -- Enslave
            enslavecd = {
                varname = format(L.alert["%s CD"],SN[76207]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[76207]),
                time = 60,
                time2 = "<enslave2cd>",
                flashtime = 5,
                color1 = "VIOLET",
                color2 = "PINK",
                sound = "MINORWARNING",
                icon = ST[76207],
                throttle = 5,
            },
            enslavewarn = {
                varname = format(L.alert["%s Warning"],SN[76207]),
                type = "simple",
                text = "<enslavetext>",
                time = 1,
                color1 = "MAGENTA",
                color2 = "GOLD",
                sound = "BURST",
                icon = ST[76207],
            },
            enslaveduration = {
                varname = format(L.alert["%s Duration"],SN[76207]),
                type = "centerpopup",
                text = "<enslavedurationtext>",
                time = "<enslaveduration>",
                color1 = "MAGENTA",
                color2 = "GOLD",
                sound = "None",
                icon = ST[76207],
            },
            -- Absorb Magic
            absorbcd = {
                varname = format(L.alert["%s CD"],SN[76307]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[76307]),
                time = "<absorbcd>",
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "LIGHTGREEN",
                sound = "MINORWARNING",
                icon = ST[76307],
                throttle = 5,
            },
            absorbwarn = {
                varname = format(L.alert["%s Warning"],SN[76307]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[76307]),
                time = 1.5,
                color1 = "YELLOW",
                sound = "BEWARE",
                icon = ST[76307],
            },
            absorbduration = {
                varname = format(L.alert["%s Duration"],SN[76307]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[76307]),
                time = 3,
                color1 = "GOLD",
                sound = "None",
                icon = ST[76307],
            },
            fogselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[76230]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[76230],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                icon = ST[76230],
                throttle = 1.5,
                emphasizewarning = true,
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"<erunakGUID>","~=","none"},
                    "expect",{"&getguidhp|<erunakGUID>&","<","60"},
                    "alert","detachsoonwarn",
                    "canceltimer","checkhp",
                },
            },
            
        },
        events = {
			-- Lava Bolt
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 76171,
                execute = {
                    {
                        "quash","boltcd",
                        "alert","boltcd",
                        "alert","boltwarn",
                    },
                    {
                        "expect",{"<erunakGUID>","==","none"},
                        "set",{erunakGUID = "#1#"},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_FAILED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[76171]},
                        "quash","boltwarn",
                    },
                },
            },
            -- Mindbender Ghur'sha detached
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"<lookingforhost>","==","no"},
                        "expect",{"#1#","find",L.chat_throneoftides["^A new host must be found"]},
                        "set",{lookingforhost = "yes"},
                        "quash","boltcd",
                        "alert","detachwarn",
                        "tracing",{40788},
                        "alert","absorbcd",
                        "alert",{"enslavecd",time = 2},
                    },
                },
            },
            -- Absorb Magic
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 76307,
                execute = {
                    {
                        "quash","absorbcd",
                        "alert","absorbcd",
                        "alert","absorbwarn",
                        "schedulealert",{"absorbduration", 1.5},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_PERIODIC_DAMAGE",
                spellname = 76230,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","fogselfwarn",
                    },
                },
            },
            -- Enslave
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 91413,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{enslavetext = format(L.alert["%s on %s!"],SN[91413],L.alert["YOU"])},
                        "set",{enslavedurationtext = format(L.alert["%s on <%s>"],SN[91413],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{enslavetext = format(L.alert["%s on <%s> - BEAT HIM/HER TO 50%%!"],SN[91413],"#5#")},
                        "set",{enslavedurationtext = format(L.alert["%s on <%s>"],SN[91413],"#5#")},
                    },
                    {
                        "quash","absorbcd",
                        "set",{absorbcd = {12, 20, loop = false, type = "series"}},
                        "quash","enslavecd",
                        "alert","enslavewarn",
                        "alert","enslaveduration",
                        "temptracing","#4#",
                        "addphasemarker",{2, 1, 0.5, "Mindbender Gur'sha let's go","Mindbender Gur'sha controls the player until brought under 50% of player's HP."},
                    },
                },
            },
            -- Enslave ends
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 76207,
                execute = {
                    {
                        "set",{lookingforhost = "no"},
                        "quash","enslaveduration",
                        "alert","enslavecd",
                        "alert","absorbcd",
                        "closetemptracing",true,
                        "removephasemarker",{2,1},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- OZUMAT
---------------------------------

do
    local data = {
        version = 8,
        key = "ozumat",
        zone = L.zone["Throne of Tides"],
        category = L.zone["Throne of the Tides"],
        name = "Ozumat",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Ozumat.blp",
        advanced = {
            preventPostDefeatPull = 15,
            delayWipe = 6,
        },
        triggers = {
            scan = {
                40792, -- Neptulon
            },
            yell = {
                --L.chat_throneoftides["^You may yet regret"],
                --L.chat_throneoftides["my fearless assistants"],
            },
        },
        onactivate = {
            tracing = {
                40792, 
            },
            tracerstart = true,
            combatstop = true,
            combatstart = false,
            defeat = 44566,
            wipe = {
                yell = L.chat_throneoftides["^Your kind"],
            },
        },
        userdata = {
            sappers_units = {type = "container", wipein = 10},
            sappers_traced = "no",
        },
        onstart = {
            {
                "alert","phase1duration",
            },
        },
        
        raidicons = {
            sappersmark = {
                varname = format("%s {%s}","Faceless Sappers","NPC_ENEMY"),
                type = "MULTIENEMY",
                persist = 60,
                unit = "#1#",
                reset = 300,
                icon = 1,
                total = 3,
                texture = ST[49671],
            },
        },
        ordering = {
            alerts = {"phase1duration","phase2warn","dreadselfwarn","phase3warn"},
        },
        
        alerts = {
            -- Phase 1
            phase1duration = {
                varname = format(L.alert["%s Duration"],"Phase 1"),
                type = "dropdown",
                text = format(L.alert["%s"],"Phase 2"),
                time = 100,
                flashtime = 10,
                color1 = "TURQUOISE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            -- Phase 2
            phase2warn = {
                varname = format(L.alert["%s Warning"],"Phase 2"),
                type = "simple",
                text = format(L.alert["%s"],"Phase 2"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT1",
                icon = ST[11242],
            },
            -- Phase 3
            phase3warn = {
                varname = format(L.alert["%s Warning"],"Phase 3"),
                type = "simple",
                text = format(L.alert["%s"],"Phase 3"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "BURST",
                icon = ST[11242],
            },
            -- Aura of Dread
            dreadselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[83971]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[83971],L.alert["YOU"]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT8",
                icon = ST[83971],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
        },
        events = {
			-- Faceless Sappers tracing
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 83463,
                execute = {
                    {
                        "expect",{"<sappers_traced>","==","no"},
                        "raidicon","sappersmark",
                        "insert",{"sappers_units","#1#"},
                        "expect",{"&listsize|sappers_units&","==","3"},
                        "set",{sappers_traced = "yes"},
                        "temptracing","<sappers_units>",
                    },
                },
            },
            -- Phase 2
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_throneoftides["^The beast has returned"]},
                        "quash","phase1duration",
                        "alert","phase2warn",
                    },
                },
            },
            
            -- Aura of Dread
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED", -- nebo změnit zpět na SPELL_DAMAGE
                spellname = 83971,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","dreadselfwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 83971,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","dreadselfwarn",
                    },
                },
            },
            -- Phase 3
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_throneoftides["^Behold the power"]},
                        "alert","phase3warn",
                        "tracing",{44566,40792},
                    },
                    {
                        "expect",{"#1#","find",L.chat_throneoftides["^My waters are cleansed"]},
                        "alert","phase3warn",
                        "tracing",{44566,40792},
                    },
                },
            },
            -- Encounter defeat trigger
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 83672,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","44566"},
                        "expect",{"&npcid|#4#&","==","44566"},
                        "triggerdefeat",true,
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- TRASH
---------------------------------

do
    local data = {
        version = 2,
        key = "tottrash",
        zone = L.zone["Throne of Tides"],
        category = L.zone["Throne of the Tides"],
        name = "Trash",
        triggers = {
            scan = {
                40577, -- Naz'jar Sentinel
                41096, -- Naz'jar Spiritmender
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {},
        
        phrasecolors = {
            {"Naz'jar Spiritmender","GOLD"},
        },
        ordering = {
            alerts = {"healingwavewarn","mireselfwarn"},
        },
        
        alerts = {
            -- Noxious Mire
            mireselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[91446]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[91446],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                emphasizewarning = {1,0.5},
                icon = ST[91446],
                throttle = 2,
            },
            -- Healing Wave
            healingwavewarn = {
                varname = format(L.alert["%s Warning"],SN[91437]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[91437]),
                warningtext = format("Naz'jar Spiritmender: %s - INTERRUPT",SN[91437]),
                time = 2,
                color1 = "LIGHTGREEN",
                sound = "ALERT8",
                icon = ST[91437],
                tag = "#1#",
            },           
        },
        events = {
            -- Noxious Mire
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 91446,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","mireselfwarn",
                    },
                },
            },
            -- Healing Wave
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91437,
                srcisnpctype = true,
                execute = {
                    {
                        "alert","healingwavewarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_FAILED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[91437]},
                        "expect",{"&unitisplayertype|#1#&","==","false"},
                        "quash",{"healingwavewarn","&unitguid|#1#&"},
                        
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","41096"},
                        "quash",{"healingwavewarn","#4#"},
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- Cinematics & Movies
---------------------------------
do
    DXE:RegisterCinematic("Throne of the Tides","Ozumat flees",767,2)
end
