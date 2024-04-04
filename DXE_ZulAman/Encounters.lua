local L,SN,ST,SL,AL,AT,AN,TI = DXE.L,DXE.SN,DXE.ST,DXE.SL,DXE.AL,DXE.AT,DXE.AN,DXE.TI
local addon = DXE
---------------------------------
-- AKIL'ZON
---------------------------------

do
    local data = {
        version = 3,
        key = "akilzon",
        zone = L.zone["Zul'Aman"],
        category = L.zone["Zul'Aman"],
        name = "Akil'zon",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Akilzon.blp",
        advanced = {
            delayWipe = 5,
        },
        triggers = {
            scan = {
                23574, -- Akil'zon
            },
        },
        onactivate = {
            tracing = {
                23574,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 23574,
        },
        userdata = {
            kidnappercd = {10, 24, loop = false, type = "series"},
            stormcd = {47, 55, loop = false, type = "series"},
            kidnappertext = "",
            stormtext = "",
        },
        onstart = {
            {
                "alert","kidnappercd",
                "alert","stormcd",
            },
        },
        
        arrows = {
            stormarrow = {
                varname = format("%s",SN[43648]),
                unit = "#5#",
                persist = 8,
                action = "TOWARD",
                msg = L.alert["Hide!"],
                spell = SN[43648],
                sound = "None",
                rangeStay = 15,
                range1 = 10,
                range2 = 14,
                range3 = 12,
                texture = ST[43648],
            },
        },
        announces = {
            kidnapparty = {
                varname = "%s target",
                type = "PARTY",
                subtype = "spell",
                spell = "Kidnapped",
                icon = ST[97318],
                msg = format(L.alert["<DXE> %s will get kidnapped!"],"#2#"),
                throttle = false
            },
        },
        raidicons = {
            kidnappermark = {
                varname = format("%s {%s}","Amani Kidnapper","NPC_ENEMY"),
                type = "ENEMY",
                persist = 20,
                unit = "#4#",
                reset = 20,
                icon = 1,
                texture = ST[96503],
            },
            kidnappedmark = {
                varname = format("%s {%s}","Kidnapped","ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 20,
                unit = "#2#",
                reset = 10,
                icon = 2,
                texture = ST[97318],
            },
        },
        phrasecolors = {
            {"Amani Kidnapper","GOLD"},
        },
        windows = {
			proxwindow = true,
			proxrange = 42,
			proxoverride = true,
            proxnoauto = false,
            nodistancecheck = true,
		},
        radars = {
            stormradar = {
                varname = SN[43648],
                type = "circle",
                player = "#5#",
                range = 10,
                mode = "enter",
                icon = ST[43648],
            },
        },
        ordering = {
            alerts = {"kidnappercd","kidnapperwarn","stormcd","stormwarn"},
        },
        
        alerts = {
            -- Amani Kidnapper
            kidnappercd = {
                varname = format(L.alert["%s CD"],"Amani Kidnapper"),
                type = "dropdown",
                text = format(L.alert["Next %s"],"Amani Kidnapper"),
                time = "<kidnappercd>",
                flashtime = 5,
                color1 = "CYAN",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[97318],
            },
            kidnapperwarn = {
                varname = format(L.alert["%s Warning"],"Amani Kidnapper"),
                type = "simple",
                text = "<kidnappertext>",
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[97318],
            },
            -- Electrical Storm
            stormcd = {
                varname = format(L.alert["%s CD"],SN[43648]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43648]),
                time = "<stormcd>",
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[43648],
            },
            stormwarn = {
                varname = format(L.alert["%s Warning"],SN[43648]),
                type = "centerpopup",
                text = "<stormtext>",
                time = 8,
                color1 = "CYAN",
                sound = "BEWARE",
                icon = ST[43648],
            },
            
        },
        events = {           
			-- Amani Kidnapper
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 97316,
                execute = {
                    {
                        "quash","kidnappercd",
                        "alert","kidnappercd",
                    },
                    {
                        "expect",{"#1#","==","&playerguid&"},
                        "set",{kidnappertext = format(L.alert["%s will kidnap %s!"],"Amani Kidnapper",L.alert["YOU"])},
                    },
                    {
                        "expect",{"#1#","~=","&playerguid&"},
                        "set",{kidnappertext = format(L.alert["%s will kidnap <%s>!"],"Amani Kidnapper","#2#")},
                    },
                    {
                        "alert","kidnapperwarn",
                        "raidicon","kidnappermark",
                        "raidicon","kidnappedmark",
                        "announce","kidnapparty",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 97318,
                execute = {
                    {
                        "removeicon","#5#",
                    },
                },
            },
            
            -- Electrical Storm
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43648,
                execute = {
                    {
                        "quash","stormcd",
                        "alert","stormcd",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{stormtext = format(L.alert["%s on %s!"],SN[43648],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{stormtext = format(L.alert["%s on <%s>!"],SN[43648],"#5#")},
                        "arrow","stormarrow",
                    },
                    {
                        "radar","stormradar",
                        "alert","stormwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 43648,
                execute = {
                    {
                        "removearrow","#5#",
                        "removeradar","stormradar",
                    },
                },
            },            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- NALORAKK
---------------------------------

do
    local data = {
        version = 3,
        key = "nalorakk",
        zone = L.zone["Zul'Aman"],
        category = L.zone["Zul'Aman"],
        name = "Nalorakk",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Nalorakk.blp",
        advanced = {
            delayWipe = 5,
        },
        triggers = {
            scan = {
                23576, -- Nalorakk
            },
        },
        onactivate = {
            tracing = {
                23576,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 23576,
        },
        userdata = {
            surgecd = {8, 8, 0, loop = true, type = "series"},
            surgetext = "",
        },
        onstart = {
            {
                "alert",{"surgecd", time = 2},
                "alert","bearcd",
            },
        },
        
        filters = {
            bossemotes = {
                surgeemote = {
                    name = "Surge",
                    pattern = "surges towards the most",
                    hasIcon = false,
                    hide = true,
                    texture = ST[42402],
                },
                bearemote = {
                    name = "Bear transformation",
                    pattern = "transforms into a bear",
                    hasIcon = false,
                    hide = true,
                    texture = ST[42594],
                },
            },
        },
        phrasecolors = {
            {"charges towards","WHITE"},
        },
        ordering = {
            alerts = {"surgecd","surgewarn","bearcd","bearwarn","bearduration","roarcd","roarwarn"},
        },
        
        alerts = {
            -- Surge
            surgecd = {
                varname = format(L.alert["%s CD"],SN[42402]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[42402]),
                time = "<surgecd>",
                time2 = 8,
                time3 = 9.3,
                flashtime = 5,
                color1 = "RED",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[42402],
            },
            surgewarn = {
                varname = format(L.alert["%s Warning"],SN[42402]),
                type = "simple",
                text = "<surgetext>",
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT7",
                icon = ST[42402],
            },
            -- Shape of the Bear
            bearcd = {
                varname = format(L.alert["%s CD"],SN[42377]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[42377]),
                time = 31,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "LIGHTGREEN",
                sound = "MINORWARNING",
                icon = ST[42594],
            },
            bearduration = {
                varname = format(L.alert["%s Duration"],SN[42377]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[42377]),
                time = 29,
                flashtime = 10,
                color1 = "YELLOW",
                color2 = "ORANGE",
                sound = "None",
                icon = ST[42594],
            },
            bearwarn = {
                varname = format(L.alert["%s Warning"],SN[42377]),
                type = "simple",
                text = format(L.alert["%s"],SN[42377]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT1",
                icon = ST[42594],
            },
            -- Deafening Roar
            roarcd = {
                varname = format(L.alert["%s CD"],SN[42398]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[42398]),
                time = 11.2,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[42398],
            },
            roarwarn = {
                varname = format(L.alert["%s Warning"],SN[42398]),
                type = "simple",
                text = format(L.alert["%s"],SN[42398]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[42398],
            },
        },
        events = {
			-- Surge
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 42402,
                execute = {
                    {
                        "quash","surgecd",
                        "alert","surgecd",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{surgetext = format(L.alert["%s charges towards %s"],"Nalorakk",L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{surgetext = format(L.alert["%s charges towards <%s>"],"Nalorakk","#5#")},
                    },
                    {
                        "alert","surgewarn",
                    },
                },
            },
            -- Shape of the Bear
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[42377]},
                        "expect",{"#1#","==","boss1"},
                        "quash","bearcd",
                        "alert","bearduration",
                        "alert","roarcd",
                    },
                },
            },
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_zulaman["^Make way for"]},
                        "alert","bearcd",
                        "alert",{"surgecd", time = 3},
                    },
                },
            },
            -- Deafening Roar
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 42398,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","23576"},
                        "quash","roarcd",
                        "alert","roarwarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- JAN'ALAI
---------------------------------

do
    local data = {
        version = 5,
        key = "janalai",
        zone = L.zone["Zul'Aman"],
        category = L.zone["Zul'Aman"],
        name = "Jan'alai",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Janalai.blp",
        triggers = {
            scan = {
                23578, -- Jan'alai
            },
        },
        onactivate = {
            tracing = {
                23578,
            },
            phasemarkers = {
                {
                    {0.35, "Hatch All Eggs","At 35% of his HP, Jan'alai hatches all remaining Dragonhawk Eggs."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 23578,
        },
        userdata = {
            breathcasting = "no",
            breathonme = "no",
            breathtext = "",
            bombcasting = "no",
        },
        onstart = {
            {
                "alert","breathcd",
                "alert","bombcd",
            },
        },
        ordering = {
            alerts = {"breathcd","breathwarn","bombcd","bombwarn","hatchwarn"},
        },
        
        alerts = {
            -- Flame Breath
            breathcd = {
                varname = format(L.alert["%s CD"],SN[97855]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97855]),
                time = 8,
                time2 = 7.8,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[97855],
            },
            breathwarn = {
                varname = format(L.alert["%s Warning"],SN[97855]),
                type = "simple",
                text = format(L.alert["%s"],SN[97855]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[97855],
            },
            -- Fire Bomb
            bombcd = {
                varname = format(L.alert["%s CD"],SN[42621]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[42621]),
                time = 56,
                flashtime = 5,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[42621],
            },
            bombwarn = {
                varname = format(L.alert["%s Warning"],SN[42621]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[42621]),
                time = 10,
                color1 = "YELLOW",
                color2 = "ORANGE",
                sound = "BEWARE",
                icon = ST[42621],
                audiocd = true,
            },
            -- Hatch All Eggs Warning
            hatchwarn = {
                varname = format(L.alert["%s Warning"],SN[43144]),
                type = "simple",
                text = format(L.alert["%s hatches all remaining eggs"],"Jan'alai"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT9",
                icon = ST[36031],
            },
        },
        events = {
			-- Flame Breath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 97855,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","23578"},
                        "quash","breathcd",
                        "alert","breathcd",
                        "alert","breathwarn",
                    },
                },
            },
            -- Fire Bomb
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_zulaman["^I burn ya now"]},
                        "set",{bombcasting = "yes"},
                        "quash","bombcd",
                        "alert","bombwarn",
                    },
                },
            },
            -- Hatch All Eggs
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43144]},
                        "expect",{"#1#","==","boss1"},
                        "alert","hatchwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- HALAZZI
---------------------------------

do
    local data = {
        version = 6,
        key = "halazzi",
        zone = L.zone["Zul'Aman"],
        category = L.zone["Zul'Aman"],
        name = "Halazzi",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Halazzi.blp",
        triggers = {
            scan = {
                23577, -- Halazzi
            },
        },
        onactivate = {
            tracing = {
                23577,
            },
            phasemarkers = {
                {
                    {0.6, "Split","At 60% of his HP, Halazzi splits into two beings."},
                    {0.3, "Split","At 30% of his HP, Halazzi splits into two beings."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 23577,
        },
        userdata = {
            enragecd = {16, 18, loop = false, type = "series"},
            lightningcd = {10, 17, loop = false, type = "series"},
            shocktext = "",
            split1warned = "no",
            split2warned = "no",
            transform1warned = "no",
            transform2warned = "no",
            transformwarnbreak = "yes",
            spiritadded = "no",
            tunnelvisionfailed = "no",
            tunnelvisionfailer = "",
            phase = "1",
        },
        onstart = {
            {
                "alert","enragecd",
                "repeattimer",{"checkhp", 1},
            },
        },

        announces = {
            tunnelvisionfailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5750,
                msg = format(L.alert["<DXE> %s: Achievement failed! (%s)"],AL[5750],"<tunnelvisionfailer>"),
                throttle = true,
            },
        },
        raidicons = {
            lightningmark = {
                varname = format("%s {%s}","Lightning Totem","NPC_ENEMY"),
                type = "ENEMY",
                persist = 30,
                unit = "#4#",
                reset = 20,
                icon = 1,
                texture = ST[97492],
            },
        },
        phrasecolors = {
            {"Halazzi","GOLD"},
        },
        ordering = {
            alerts = {"waterwarn","enragecd","enragewarn","splitsoonwarn","splitwarn","lightningcd","lightningwarn","shockcd","shockwarn","transformsoonwarn","transformwarn"},
        },
        
        alerts = {
            -- Water Totem
            waterwarn = {
                varname = format(L.alert["%s Warning"],SN[97500]),
                type = "simple",
                text = format(L.alert["%s"],SN[97500]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT9",
                icon = ST[97500],
            },
            -- Enrage
            enragecd = {
                varname = format(L.alert["%s CD"],SN[43139]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43139]),
                time = "<enragecd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43139],
            },
            enragewarn = {
                varname = format(L.alert["%s Warning"],SN[43139]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[43139]),
                time = 6,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT7",
                icon = ST[43139],
            },
            -- Lightning Totem
            lightningcd = {
                varname = format(L.alert["%s CD"],SN[97492]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97492]),
                time = "<lightningcd>",
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[97492],
            },
            lightningwarn = {
                varname = format(L.alert["%s Warning"],SN[97492]),
                type = "simple",
                text = format(L.alert["%s - DESTROY IT"],SN[97492]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT10",
                icon = ST[97492],
            },
            -- Flame Shock
            shockcd = {
                varname = format(L.alert["%s CD"],SN[97490]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97490]),
                time = 15,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[97490],
            },
            shockwarn = {
                varname = format(L.alert["%s Warning"],SN[97490]),
                type = "simple",
                text = "<shocktext>",
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT8",
                icon = ST[97490],
            },
            -- Split
            splitsoonwarn = {
                varname = format(L.alert["%s soon Warning"],"Split"),
                type = "simple",
                text = format(L.alert["%s soon ..."],"Split"),
                time = 1,
                color1 = "TAN",
                sound = "MINORWARNING",
                icon = ST[42607],
            },
            splitwarn = {
                varname = format(L.alert["%s Warning"],"Split"),
                type = "simple",
                text = L.alert["Halazzi split into two beings!"],
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT1",
                icon = ST[42607],
            },
            -- Transform
            transformsoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[43145]),
                type = "simple",
                text = L.alert["Halazzi will transform soon ..."],
                time = 1,
                color1 = "TAN",
                sound = "MINORWARNING",
                icon = ST[42607],
            },
            transformwarn = {
                varname = format(L.alert["%s Warning"],SN[43145]),
                type = "simple",
                text = "Halazzi reverted into his true form",
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT1",
                icon = ST[42607],
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","70"},
                    "expect",{"<split1warned>","==","no"},
                    "expect",{"<phase>","==","1"},
                    "set",{split1warned = "yes"},
                    "alert","splitsoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","40"},
                    "expect",{"<split2warned>","==","no"},
                    "expect",{"<phase>","==","1"},
                    "set",{split2warned = "yes"},
                    "alert","splitsoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","40"},
                    "expect",{"<transform1warned>","==","no"},
                    "expect",{"<phase>","==","2"},
                    "set",{transform1warned = "yes"},
                    "alert","transformsoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","40"},
                    "expect",{"<transformwarnbreak>","==","no"},
                    "expect",{"<transform1warned>","==","yes"},
                    "expect",{"<transform2warned>","==","no"},
                    "expect",{"<phase>","==","2"},
                    "set",{transform2warned = "yes"},
                    "alert","transformsoonwarn",
                },
                {
                    "expect",{"<split1warned>","==","yes"},
                    "expect",{"<split2warned>","==","yes"},
                    "expect",{"<transform1warned>","==","yes"},
                    "expect",{"<transform2warned>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
        },
        events = {
			-- Water Totem
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 97500,
                execute = {
                    {
                        "alert","waterwarn",
                    },
                },
            },
            -- Enrage
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43139,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","23577"},
                        "quash","enragecd",
                        "alert","enragecd",
                        "alert","enragewarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 43139,
                execute = {
                    {
                        "quash","enragewarn",
                    },
                },
            },
            -- Lightning Totem
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 97492,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","23577"},
                        "quash","lightningcd",
                        "alert","lightningcd",
                        "alert","lightningwarn",
                        
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 97492,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","23577"},
                        "raidicon","lightningmark",
                    },
                },
            },
            -- Flame Shock
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 97490,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","23577"},
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{shocktext = format(L.alert["%s on %s - DISPEL"],SN[97490],L.alert["YOU"])},
                    },
                    {
                        "expect",{"&npcid|#1#&","==","23577"},
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{shocktext = format(L.alert["%s on <%s> - DISPEL"],SN[97490],"#5#")},
                    },
                    {
                        "expect",{"&npcid|#1#&","==","23577"},
                        "quash","shockcd",
                        "alert","shockcd",
                        "alert","shockwarn",
                    },
                },
            },
            -- Split
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_zulaman["^I fight"]},
                        "set",{phase = "2"},
                        "alert","splitwarn",
                        "set",{lightningcd = {10, 17, loop = false, type = "series"}},
                        "alert","lightningcd",
                        "alert","shockcd",
                        "quash","enragecd",
                        "hidephasemarker",{1,1},
                        "hidephasemarker",{1,2},
                        "temptracing","24143",
                    },
                    {
                        "expect",{"#1#","find",L.chat_zulaman["^I fight"]},
                        "expect",{"<split1warned>","==","yes"},
                        "expect",{"<split2warned>","==","no"},
                        "addphasemarker",{1, 3, 0.2, "Merge","At 20% of his HP, Halazzi merges again."},
                    },
                    {
                        "expect",{"#1#","find",L.chat_zulaman["^I fight"]},
                        "expect",{"<split1warned>","==","yes"},
                        "expect",{"<split2warned>","==","yes"},
                        "showphasemarker",{1,3},
                    },
                },
            },
            -- Transform
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43145]},
                        "expect",{"#1#","==","boss1"},
                        "expect",{"<transform1warned>","==","yes"},
                        "expect",{"<transform2warned>","==","no"},
                        "set",{phase = "1"},
                        "alert","transformwarn",
                        "quash","lightningcd",
                        "quash","shockcd",
                        "set",{enragecd = {16, 18, loop = false, type = "series"}},
                        "alert","enragecd",
                        "set",{transformwarnbreak = "no"},
                        "hidephasemarker",{1,3},
                        "showphasemarker",{1,2},
                        "closetemptracing",true,
                        "expect",{"<spiritadded>","==","yes"},
                        "set",{spiritadded = "no"},
                    },
                    {
                        "expect",{"#2#","==",SN[43145]},
                        "expect",{"#1#","==","boss1"},
                        "expect",{"<transform1warned>","==","yes"},
                        "expect",{"<transform2warned>","==","yes"},
                        "set",{phase = "1"},
                        "alert","transformwarn",
                        "quash","lightningcd",
                        "quash","shockcd",
                        "set",{lightningcd = {14.5, 17, loop = false, type = "series"}},
                        "alert","lightningcd",
                        "set",{enragecd = {16, 18, loop = false, type = "series"}},
                        "alert","enragecd",
                        "hidephasemarker",{1,3},
                        "closetemptracing",true,
                        "expect",{"<spiritadded>","==","yes"},
                        "set",{spiritadded = "no"},
                    },
                },
            },
            -- Temptracing for Spirit of the Lynx
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = 43243,
                execute = {
                    {
                        "expect",{"<spiritadded>","==","no"},
                        "set",{spiritadded = "yes"},
                        "temptracing","#1#",
                    },
                },
            },
            -- Tunnel Vision (achievement)
            {
                type = "combatevent",
                eventtype = "PARTY_KILL",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","52755"},
                        "expect",{"<tunnelvisionfailed>","==","no"},
                        "set",{
                            tunnelvisionfailed = "yes",
                            tunnelvisionfailer = "#2#",
                        },
                        "announce","tunnelvisionfailed",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","24224"},
                        "expect",{"<tunnelvisionfailed>","==","no"},
                        "set",{
                            tunnelvisionfailed = "yes",
                            tunnelvisionfailer = "#2#",
                        },
                        "announce","tunnelvisionfailed",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- HEX LORD MALACRASS
---------------------------------

do
    local data = {
        version = 7,
        key = "malacrass",
        zone = L.zone["Zul'Aman"],
        category = L.zone["Zul'Aman"],
        name = "Hex Lord Malacrass",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Hex Lord Malacrass.blp",
        triggers = {
            scan = {
                24239, -- Hex Lord Malacrass
            },
        },
        onactivate = {
            tracing = {
                24239,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 24239,
        },
        userdata = {
            boltscd = {15, 36, loop = false, type = "series"},
            siphoncd = {20, 36, loop = false, type = "series"},
            siphontext = "",
            
            -- Mage
            frostnovacd = {3, 15, loop = false, type = "series"},

            -- Priest
            leapoffaithcd = {6, 20, 0, loop = false, type = "series"},
            leapoffaithtext = "",
            flashhealcd = {12, 10, 0, loop = false, type = "series"},
            
            -- Shaman
            firetotemcd = {6, 0, loop = true, type = "series"},
            chainlightningcd = {7, 10, 10, 0, loop = false, type = "series"},
            healingwavecd = {10, 10, 10, 0, loop = false, type = "series"},
            
            -- Druid
            lifebloomcd = {11, 10, 0, loop = false, type = "series"},
            typhooncd = {12, 10, 0, loop = false, type = "series"},
            
            -- Rogue
            smokebombcd = {8, 15, 0, loop = false, type = "series"},
            
            -- Paladin
            holylightcd = {12, 10, 0, loop = false, type = "series"},
            avengingwrathcd = {11, 10, 0, loop = false, type = "series"},
            
            -- Death Knight
            deathanddecaycd = {15, 15, 0, loop = false, type = "series"},
            bloodwormscd = {20, 0, loop = false, type = "series"},
            deathanddecaytext = "",
            
            -- Warrior
            spellreflectioncd = {11, 10, 0, loop = false, type = "series"},
            heroicleapcd = {6, 15, 0, loop = false, type = "series"},
            
            -- Warlock
            doomcd = {10, 0, loop = false, type = "series"},
            doomtext = "",
            unstablecd = {12, 10, 0, loop = false, type = "series"},
            unstabletext = "",
        },
        onstart = {
            {
                "alert","boltscd",
                "alert","siphoncd",
            },
        },
        
        raidicons = {
            firetotemmark = {
                varname = format("%s {%s}","Fire Totem","NPC_ENEMY"),
                type = "ENEMY",
                persist = 20,
                unit = "#4#",
                reset = 24,
                icon = 1,
                texture = ST[43436],
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"boltscd","boltswarn","siphoncd","siphonwarn",},
            },
            {
                name = format("%s%s|r",addon.ClassToColor["DEATHKNIGHT"],"Death Knight"),
                iconfull = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\TARGETINGFRAME\\UI-Classes-Circles",16,16,64,64,64*CLASS_ICON_TCOORDS["DEATHKNIGHT"][1],64*CLASS_ICON_TCOORDS["DEATHKNIGHT"][2],64*CLASS_ICON_TCOORDS["DEATHKNIGHT"][3],64*CLASS_ICON_TCOORDS["DEATHKNIGHT"][4]),
                alerts = {"deathanddecaycd","deathanddecaywarn","deathanddecayselfwarn","bloodwormscd","bloodwormswarn"},
            },
            {
                name = format("%s%s|r",addon.ClassToColor["DRUID"],"Druid"),
                iconfull = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\TARGETINGFRAME\\UI-Classes-Circles",16,16,64,64,64*CLASS_ICON_TCOORDS["DRUID"][1],64*CLASS_ICON_TCOORDS["DRUID"][2],64*CLASS_ICON_TCOORDS["DRUID"][3],64*CLASS_ICON_TCOORDS["DRUID"][4]),
                alerts = {"lifebloomcd","lifebloomwarn","typhooncd","typhoonwarn"},
            },
            {
                name = format("%s%s|r",addon.ClassToColor["HUNTER"],"Hunter"),
                iconfull = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\TARGETINGFRAME\\UI-Classes-Circles",16,16,64,64,64*CLASS_ICON_TCOORDS["HUNTER"][1],64*CLASS_ICON_TCOORDS["HUNTER"][2],64*CLASS_ICON_TCOORDS["HUNTER"][3],64*CLASS_ICON_TCOORDS["HUNTER"][4]),
                alerts = {"explosivewarn","freezingtrapwarn","snakewarn"},
            },
            {
                name = format("%s%s|r",addon.ClassToColor["MAGE"],"Mage"),
                iconfull = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\TARGETINGFRAME\\UI-Classes-Circles",16,16,64,64,64*CLASS_ICON_TCOORDS["MAGE"][1],64*CLASS_ICON_TCOORDS["MAGE"][2],64*CLASS_ICON_TCOORDS["MAGE"][3],64*CLASS_ICON_TCOORDS["MAGE"][4]),
                alerts = {"frostnovacd","frostnovawarn"},
            },
            {
                name = format("%s%s|r",addon.ClassToColor["PALADIN"],"Paladin"),
                iconfull = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\TARGETINGFRAME\\UI-Classes-Circles",16,16,64,64,64*CLASS_ICON_TCOORDS["PALADIN"][1],64*CLASS_ICON_TCOORDS["PALADIN"][2],64*CLASS_ICON_TCOORDS["PALADIN"][3],64*CLASS_ICON_TCOORDS["PALADIN"][4]),
                alerts = {"holylightcd","holylightwarn","avengingwrathcd","avengingwrathwarn"},
            },
            {
                name = format("%s%s|r",addon.ClassToColor["PRIEST"],"Priest"),
                iconfull = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\TARGETINGFRAME\\UI-Classes-Circles",16,16,64,64,64*CLASS_ICON_TCOORDS["PRIEST"][1],64*CLASS_ICON_TCOORDS["PRIEST"][2],64*CLASS_ICON_TCOORDS["PRIEST"][3],64*CLASS_ICON_TCOORDS["PRIEST"][4]),
                alerts = {"leapoffaithcd","leapoffaithwarn","flashhealcd","flashhealwarn","screamcd","screamwarn"},
            },
            {
                name = format("%s%s|r",addon.ClassToColor["ROGUE"],"Rogue"),
                iconfull = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\TARGETINGFRAME\\UI-Classes-Circles",16,16,64,64,64*CLASS_ICON_TCOORDS["ROGUE"][1],64*CLASS_ICON_TCOORDS["ROGUE"][2],64*CLASS_ICON_TCOORDS["ROGUE"][3],64*CLASS_ICON_TCOORDS["ROGUE"][4]),
                alerts = {"smokebombcd","smokebombwarn","smokebombselfwarn"},
            },
            {
                name = format("%s%s|r",addon.ClassToColor["SHAMAN"],"Shaman"),
                iconfull = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\TARGETINGFRAME\\UI-Classes-Circles",16,16,64,64,64*CLASS_ICON_TCOORDS["SHAMAN"][1],64*CLASS_ICON_TCOORDS["SHAMAN"][2],64*CLASS_ICON_TCOORDS["SHAMAN"][3],64*CLASS_ICON_TCOORDS["SHAMAN"][4]),
                alerts = {"firetotemcd","firetotemwarn","chainlightningcd","chainlightningwarn","healingwavecd","healingwavewarn"},
            },
            {
                name = format("%s%s|r",addon.ClassToColor["WARLOCK"],"Warlock"),
                iconfull = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\TARGETINGFRAME\\UI-Classes-Circles",16,16,64,64,64*CLASS_ICON_TCOORDS["WARLOCK"][1],64*CLASS_ICON_TCOORDS["WARLOCK"][2],64*CLASS_ICON_TCOORDS["WARLOCK"][3],64*CLASS_ICON_TCOORDS["WARLOCK"][4]),
                alerts = {"doomcd","doomwarn","unstablecd","unstablewarn","raincd","rainselfwarn"},
            },
            {
                name = format("%s%s|r",addon.ClassToColor["WARRIOR"],"Warrior"),
                iconfull = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\TARGETINGFRAME\\UI-Classes-Circles",16,16,64,64,64*CLASS_ICON_TCOORDS["WARRIOR"][1],64*CLASS_ICON_TCOORDS["WARRIOR"][2],64*CLASS_ICON_TCOORDS["WARRIOR"][3],64*CLASS_ICON_TCOORDS["WARRIOR"][4]),
                alerts = {"spellreflectioncd","spellreflectionwarn","heroicleapcd","heroicleapwarn"},
            },
        },
        
        alerts = {
            -------------------------------
            -- Malacrass' Base Abilities --
            -------------------------------
            -- Spirit Bolts
            boltscd = {
                varname = format(L.alert["%s CD"],SN[43383]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43383]),
                time = "<boltscd>",
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[43383],
            },
            boltswarn = {
                varname = format(L.alert["%s Warning"],SN[43383]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[43383]),
                time = 5,
                color1 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[43383],
            },
            -- Siphon Soul
            siphoncd = {
                varname = format(L.alert["%s CD"],SN[43501]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43501]),
                time = "<siphoncd>",
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[43501],
            },
            siphonwarn = {
                varname = format(L.alert["%s Warning"],SN[43501]),
                type = "simple",
                text = "<siphontext>",
                time = 1, -- 30,
                color1 = "TURQUOISE",
                sound = "ALERT1",
                icon = ST[43501],
            },
            ----------------------------
            -- Death Knight Abilities --
            ----------------------------
            -- Death and Decay
            deathanddecaycd = {
                varname = format(L.alert["%s CD"],SN[61603]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[61603]),
                time = "<deathanddecaycd>",
                flashtime = 5,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[61603],
            },
            deathanddecaywarn = {
                varname = format(L.alert["%s Warning"],SN[61603]),
                type = "simple",
                text = "<deathanddecaytext>",
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT8",
                icon = ST[61603],
            },
            deathanddecayselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[61603]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[61603],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[61603],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
            -- Blood Worms
            bloodwormscd = {
                varname = format(L.alert["%s CD"],SN[97628]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97628]),
                time = "<bloodwormscd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[97628],
            },
            bloodwormswarn = {
                varname = format(L.alert["%s Warning"],SN[97628]),
                type = "simple",
                text = format(L.alert["%s"],SN[97628]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT9",
                icon = ST[97628],
            },
            
            ----------------------------
            ----- Druid Abilities ------
            ----------------------------
            -- Lifebloom
            lifebloomcd = {
                varname = format(L.alert["%s CD"],SN[43421]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43421]),
                time = "<lifebloomcd>",
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "GREEN",
                sound = "MINORWARNING",
                icon = ST[43421],
            },
            lifebloomwarn = {
                varname = format(L.alert["%s Warning"],SN[43421]),
                type = "simple",
                text = format(L.alert["%s - DISPEL!"],SN[43421]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT2",
                icon = ST[43421],
            },
            -- Typhoon
            typhooncd = {
                varname = format(L.alert["%s CD"],SN[97637]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97637]),
                time = "<typhooncd>",
                flashtime = 5,
                color1 = "MAGENTA",
                color2 = "PURPLE",
                sound = "MINORWARNING",
                icon = ST[97637],
            },
            typhoonwarn = {
                varname = format(L.alert["%s Warning"],SN[97637]),
                type = "simple",
                text = format(L.alert["%s"],SN[97637]),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT7",
                icon = ST[97637],
            },
            
            ----------------------------
            ----- Hunter Abilities -----
            ----------------------------
            -- Explosive Trap
            explosivewarn = {
                varname = format(L.alert["%s Warning"],SN[43444]),
                type = "simple",
                text = format(L.alert["%s"],SN[43444]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT8",
                icon = ST[43444],
            },
            -- Freezing Trap
            freezingtrapwarn = {
                varname = format(L.alert["%s Warning"],SN[43447]),
                type = "simple",
                text = format(L.alert["%s"],SN[43447]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT9",
                icon = ST[43447],
            },
            -- Snake Trap
            snakewarn = {
                varname = format(L.alert["%s Warning"],SN[43449]),
                type = "simple",
                text = format(L.alert["%s"],SN[43449]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT2",
                icon = ST[43449],
            },
            
            ----------------------------
            ------ Mage Abilities ------
            ----------------------------
            -- Frost Nova
            frostnovacd = {
                varname = format(L.alert["%s CD"],SN[43426]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43426]),
                time = "<frostnovacd>",
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[43426],
            },
            frostnovawarn = {
                varname = format(L.alert["%s Warning"],SN[43426]),
                type = "simple",
                text = format(L.alert["%s"],SN[43426]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT8",
                icon = ST[43426],
            },
            
            ----------------------------
            ----- Paladin Abilities ----
            ----------------------------
            -- Holy Lightning
            holylightcd = {
                varname = format(L.alert["%s CD"],SN[43451]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43451]),
                time = "<holylightcd>",
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43451],
            },
            holylightwarn = {
                varname = format(L.alert["%s Warning"],SN[43451]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[43451]),
                time = 2,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[43451],
            },
            -- Avenging Wrath
            avengingwrathcd = {
                varname = format(L.alert["%s CD"],SN[43430]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43430]),
                time = "<avengingwrathcd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43430],
            },
            avengingwrathwarn = {
                varname = format(L.alert["%s Warning"],SN[43430]),
                type = "simple",
                text = format(L.alert["%s"],SN[43430]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "BEWARE",
                icon = ST[43430],
            },
            
            ----------------------------
            ----- Priest Abilities -----
            ----------------------------
            -- Leap of Faith
            leapoffaithcd = {
                varname = format(L.alert["%s CD"],SN[97817]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97817]),
                time = "<leapoffaithcd>",
                flashtime = 5,
                color1 = "PEACH",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[97817],
            },
            leapoffaithwarn = {
                varname = format(L.alert["%s Warning"],SN[97817]),
                type = "simple",
                text = "<leapoffaithtext>",
                time = 1,
                color1 = "PEACH",
                sound = "ALERT7",
                icon = ST[97817],
            },
            -- Flash Heal
            flashhealcd = {
                varname = format(L.alert["%s CD"],SN[43431]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43431]),
                time = "<flashhealcd>",
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43431],
            },
            flashhealwarn = {
                varname = format(L.alert["%s Warning"],SN[43431]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[43431]),
                time = 2,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[43431],
            },
            -- Psychic Scream
            screamcd = {
                varname = format(L.alert["%s CD"],SN[43432]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43432]),
                time = 20,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[43432],
            },
            screamwarn = {
                varname = format(L.alert["%s Warning"],SN[43432]),
                type = "simple",
                text = format(L.alert["%s"],SN[43432]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT8",
                icon = ST[43432],
            },
            
            ----------------------------
            ------ Rogue Abilities -----
            ----------------------------
            -- Smoke Bomb
            smokebombcd = {
                varname = format(L.alert["%s CD"],SN[97643]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97643]),
                time = "<smokebombcd>",
                flashtime = 5,
                color1 = "WHITE",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[97643],
            },
            smokebombselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[97644]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[97644],L.alert["YOU"]),
                time = 1,
                color1 = "TAN",
                sound = "ALERT10",
                icon = ST[97644],
                throttle = 2,
            },
            smokebombwarn = {
                varname = format(L.alert["%s Warning"],SN[97643]),
                type = "simple",
                text = format(L.alert["%s"],SN[97643]),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT7",
                icon = ST[97643],
            },
            
            ----------------------------
            ----- Shaman Abilities -----
            ----------------------------
            -- Fire Nova Totem
            firetotemcd = {
                varname = format(L.alert["%s CD"],SN[43436]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43436]),
                time = "<firetotemcd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43436],
            },
            firetotemwarn = {
                varname = format(L.alert["%s Warning"],SN[43436]),
                type = "simple",
                text = format(L.alert["%s"],SN[43436]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT9",
                icon = ST[43436],
            },
            -- Chain Lightning
            chainlightningcd = {
                varname = format(L.alert["%s CD"],SN[43435]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43435]),
                time = "<chainlightningcd>",
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[43435],
            },
            chainlightningwarn = {
                varname = format(L.alert["%s Warning"],SN[43435]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[43435]),
                time = 2,
                color1 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[43435],
            },
            -- Healing Wave
            healingwavecd = {
                varname = format(L.alert["%s CD"],SN[43548]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43548]),
                time = 10,
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "GREEN",
                sound = "MINORWARNING",
                icon = ST[43548],
            },
            healingwavewarn = {
                varname = format(L.alert["%s Warning"],SN[43548]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[43548]),
                time = 2,
                color1 = "LIGHTGREEN",
                sound = "ALERT2",
                icon = ST[43548],
            },
            
            ----------------------------
            ----- Warlock Abilities ----
            ----------------------------
            -- Bane of Doom
            doomcd = {
                varname = format(L.alert["%s CD"],SN[43439]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43439]),
                time = "<doomcd>",
                flashtime = 5,
                color1 = "WHITE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43439],
            },
            doomwarn = {
                varname = format(L.alert["%s Warning"],SN[43439]),
                type = "simple",
                text = "<doomtext>",
                time = 1,
                color1 = "WHITE",
                sound = "ALERT8",
                icon = ST[43439],
            },
            -- Unstable Affliction
            unstablecd = {
                varname = format(L.alert["%s CD"],SN[43522]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43522]),
                time = "<unstablecd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43522],
            },
            unstablewarn = {
                varname = format(L.alert["%s Warning"],SN[43522]),
                type = "simple",
                text = "<unstabletext>",
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[43522],
            },
            -- Rain of Fire
            raincd = {
                varname = format(L.alert["%s CD"],SN[43440]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43440]),
                time = 6,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43440],
            },
            rainselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[43440]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[43440],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[43440],
                throttle = 2,
            },
            
            ----------------------------
            ----- Warrior Abilities ----
            ----------------------------
            -- Spell Reflection
            spellreflectioncd = {
                varname = format(L.alert["%s CD"],SN[43443]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43443]),
                time = "<spellreflectioncd>",
                flashtime = 5,
                color1 = "PEACH",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43443],
            },
            spellreflectionwarn = {
                varname = format(L.alert["%s Warning"],SN[43443]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[43443]),
                time = 5,
                color1 = "PEACH",
                sound = "BEWARE",
                icon = ST[43443],
            },
            -- Heroic Leap
            heroicleapcd = {
                varname = format(L.alert["%s CD"],SN[97521]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97521]),
                time = "<heroicleapcd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[97521],
            },
            heroicleapwarn = {
                varname = format(L.alert["%s Warning"],SN[97521]),
                type = "simple",
                text = format(L.alert["%s"],SN[97521]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT7",
                icon = ST[97521],
            },
        },
        events = {
            -------------------------------
            -- Malacrass' Base Abilities --
            -------------------------------
			-- Spirit Bolts
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43383,
                execute = {
                    {
                        "quash","boltscd",
                        "alert","boltscd",
                        "alert","boltswarn",
                    },
                },
            },
            -- Siphon Soul
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43501,
                execute = {
                    {
                        "quash","siphoncd",
                        "alert","siphoncd",
                        "set",{siphontext = format(L.alert["Malacrass siphons powers from <%s>"],"#5#")},
                        "alert","siphonwarn",
                        "batchquash",{"deathanddecaycd","bloodwormscd","lifebloomcd","typhooncd","leapoffaithcd","flashhealcd","screamcd","firetotemcd","chainlightningcd","healingwavecd","smokebombcd","holylightcd","avengingwrathcd","frostnovacd","spellreflectioncd","heroicleapcd"},
                    },
                    -- Death Knight abilities
                    {
                        "expect",{"&unitclass|#5#&","==","Death Knight"},
                        "set",{deathanddecaycd = {15, 15, 0, loop = false, type = "series"}},
                        "set",{bloodwormscd = {20, 0, loop = false, type = "series"}},
                        "alert","deathanddecaycd",
                        "alert","bloodwormscd",
                    },
                    -- Druid abilities
                    {
                        "expect",{"&unitclass|#5#&","==","Druid"},
                        "set",{lifebloomcd = {11, 10, 0, loop = false, type = "series"}},
                        "set",{typhooncd = {12, 10, 0, loop = false, type = "series"}},
                        "alert","lifebloomcd",
                        "alert","typhooncd",
                    },
                    -- Hunter abilities
                    {
                        "expect",{"&unitclass|#5#&","==","Hunter"},
                    },
                    -- Mage abilities
                    {
                        "expect",{"&unitclass|#5#&","==","Mage"},
                        "set",{frostnovacd = {3, 15, loop = false, type = "series"}},
                        "alert","frostnovacd",
                    },
                    -- Paladin abilities
                    {
                        "expect",{"&unitclass|#5#&","==","Paladin"},
                        "set",{holylightcd = {12, 10, 0, loop = false, type = "series"}},
                        "set",{avengingwrathcd = {11, 10, 0, loop = false, type = "series"}},
                        "alert","holylightcd",
                        "alert","avengingwrathcd",
                    },
                    -- Priest abilities
                    {
                        "expect",{"&unitclass|#5#&","==","Priest"},
                        "set",{leapoffaithcd = {6, 20, 0, loop = false, type = "series"}},
                        "set",{flashhealcd = {12, 10, 0, loop = false, type = "series"}},
                        "alert","leapoffaithcd",
                        "alert","flashhealcd",
                    },
                    -- Rogue abilities
                    {
                        "expect",{"&unitclass|#5#&","==","Rogue"},
                        "set",{smokebombcd = {8, 15, 0, loop = false, type = "series"}},
                        "alert","smokebombcd",
                    },
                    -- Shaman abilities
                    {
                        "expect",{"&unitclass|#5#&","==","Shaman"},
                        "set",{firetotemcd = {6, 0, loop = true, type = "series"}},
                        "set",{chainlightningcd = {7, 10, 10, 0, loop = false, type = "series"}},
                        "set",{healingwavecd = {10, 10, 10, 0, loop = false, type = "series"}},
                        "alert","firetotemcd",
                        "alert","chainlightningcd",
                        "alert","healingwavecd",
                    },
                    -- Warlock abilities
                    {
                        "expect",{"&unitclass|#5#&","==","Warlock"},
                        "set",{doomcd = {10, 0, loop = false, type = "series"}},
                        "set",{unstablecd = {12, 10, 0, loop = false, type = "series"}},
                        "alert","doomcd",
                        "alert","unstablecd",
                        "alert","raincd",
                    },
                    -- Warrior abilities
                    {
                        "expect",{"&unitclass|#5#&","==","Warrior"},
                        "set",{spellreflectioncd = {11, 10, 0, loop = false, type = "series"}},
                        "alert","spellreflectioncd",
                        "set",{heroicleapcd = {6, 15, 0, loop = false, type = "series"}},
                        "alert","heroicleapcd",
                    },
                },
            },
            
            ----------------------------
            -- Death Knight Abilities --
            ----------------------------
            -- Death and Decay
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 61603,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","deathanddecaycd",
                        "alert","deathanddecaycd",
                    },
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","deathanddecayselfwarn",
                    },
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{deathanddecaytext = format(L.alert["%s on <%s>"],SN[61603],"#5#")},
                        "alert","deathanddecaywarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_PERIODIC_DAMAGE",
                spellname = 61603,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","deathanddecayselfwarn",
                    },
                },
            },
            -- Blood Worms
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[97628]},
                        "expect",{"#1#","==","boss1"},
                        "quash","bloodwormscd",
                        "alert","bloodwormscd",
                        "alert","bloodwormswarn",
                    },
                },
            },
            
            ----------------------------
            ----- Druid Abilities ------
            ----------------------------
            -- Lifebloom
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43421,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","lifebloomcd",
                        "alert","lifebloomcd",
                        "alert","lifebloomwarn",
                    },
                },
            },
            -- Typhoon
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[97637]},
                        "expect",{"#1#","==","boss1"},
                        "quash","typhooncd",
                        "alert","typhooncd",
                        "alert","typhoonwarn",
                    },
                },
            },
            
            
            ----------------------------
            ----- Hunter Abilities -----
            ----------------------------
            -- Explosive Trap
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43444]},
                        "expect",{"#1#","==","boss1"},
                        "alert","explosivewarn",
                    },
                },
            },
            -- Snake Trap
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43449,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "alert","snakewarn",
                    },
                },
            },
            -- Freezing Trap
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43447,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "alert","freezingtrapwarn",
                    },
                },
            },
            
            
            ----------------------------
            ------ Mage Abilities ------
            ----------------------------
            -- Frost Nova
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43426]},
                        "expect",{"#1#","==","boss1"},
                        "quash","frostnovacd",
                        "alert","frostnovawarn",
                    },
                },
            },
            
            
            ----------------------------
            ----- Paladin Abilities ----
            ----------------------------
            -- Holy Light
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 43451,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","holylightcd",
                        "alert","holylightcd",
                        "alert","holylightwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43451]},
                        "expect",{"#1#","find","boss"},
                        "quash","holylightwarn",
                    },
                },
            },
            
            -- Avenging Wrath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43430,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","avengingwrathcd",
                        "alert","avengingwrathcd",
                        "alert","avengingwrathwarn",
                    },
                },
            },
            
            
            ----------------------------
            ----- Priest Abilities -----
            ----------------------------
            -- Leap of Faith
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 97817,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","24239"},
                        "quash","leapoffaithcd",
                        "alert","leapoffaithcd",
                        "set",{leapoffaithtext = format(L.alert["Malacrass uses %s on %s"],SN[97817],"#2#")},
                        "alert","leapoffaithwarn",
                    },
                },
            },
            -- Flash Heal
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 43431,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","flashhealcd",
                        "alert","flashhealcd",
                        "alert","flashhealwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43431]},
                        "expect",{"#1#","find","boss"},
                        "quash","flashhealwarn",
                    },
                },
            },
            
            -- Psychic Scream
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43432,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","screamcd",
                        "alert","screamcd",
                        "alert","screamwarn",
                    },
                },
            },
            
            ----------------------------
            ------ Rogue Abilities -----
            ----------------------------
            -- Smoke Bomb
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 97643,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","smokebombcd",
                        "alert","smokebombcd",
                        "alert","smokebombwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 97644,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","smokebombselfwarn",
                    },
                },
            },
            
            ----------------------------
            ----- Shaman Abilities -----
            ----------------------------
            -- Fire Nova Totem
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 43436,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","firetotemcd",
                        "alert","firetotemcd",
                        "alert","firetotemwarn",
                        "raidmark","firetotemmark",
                    },
                },
            },
            -- Chain Lightning
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 43435,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","chainlightningcd",
                        "alert","chainlightningcd",
                        "alert","chainlightningwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43435]},
                        "expect",{"#1#","find","boss"},
                        "quash","chainlightningwarn",
                    },
                },
            },
            
            -- Healing Wave
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 43548,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","healingwavecd",
                        "alert","healingwavecd",
                        "alert","healingwavewarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43548]},
                        "expect",{"#1#","find","boss"},
                        "quash","healingwave",
                    },
                },
            },
            
            ----------------------------
            ----- Warlock Abilities ----
            ----------------------------
            -- Bane of Doom
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43439,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{doomtext = format(L.alert["%s on %s - DISPEL!"],SN[43439],L.alert["YOU"])},
                        "quash","doomcd",
                        "alert","doomcd",
                        "alert","doomwarn",
                    },
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{doomtext = format(L.alert["%s on <%s> - DISPEL!"],SN[43439],"#5#")},
                        "quash","doomcd",
                        "alert","doomcd",
                        "alert","doomwarn",
                    },
                },
            },
            -- Unstable Affliction
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43522,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{unstabletext = format(L.alert["%s on %s"],SN[43522],L.alert["YOU"])},
                        "quash","unstablecd",
                        "alert","unstablecd",
                        "alert","unstablewarn",
                    },
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{unstabletext = format(L.alert["%s on <%s>"],SN[43522],"#5#")},
                        "quash","unstablecd",
                        "alert","unstablecd",
                        "alert","unstablewarn",
                    },
                },
            },
            -- Rain of Fire
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43440,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","raincd",
                        "alert","raincd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_PERIODIC_DAMAGE",
                spellname = 43440,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","rainselfwarn",
                    },
                },
            },
            
            ----------------------------
            ----- Warrior Abilities ----
            ----------------------------
            -- Spell Reflection
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43443,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","spellreflectioncd",
                        "alert","spellreflectioncd",
                        "alert","spellreflectionwarn",
                    },
                },
            },
            -- Heroic Leap
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 97521,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","24239"},
                        "quash","heroicleapcd",
                        "alert","heroicleapcd",
                        "alert","heroicleapwarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- DAAKARA
---------------------------------

do
    local data = {
        version = 4,
        key = "daakara",
        zone = L.zone["Zul'Aman"],
        category = L.zone["Zul'Aman"],
        name = "Daakara",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Daakara.blp",
        triggers = {
            scan = {
                23863, -- Daakara
            },
        },
        onactivate = {
            tracing = {
                23863,
            },
            phasemarkers = {
                {
                    {0.8, "Phase 2","At 80% of HP, Daakara transforms to either Bear or Lynx."},
                    {0.4, "Phase 3","At 40% of HP, Daakara transforms to either Eagle or Dragonhawk."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 23863,
        },
        userdata = {
            throwcd = {10, 15, loop = false, type = "series"},
            paralysiscd = {3, 27, loop = false, type = "series"},
            surgecd = {12, 8.5, loop = false, type = "series"},
            rushcd = {27.4, 23.15, loop = false, type = "series"},
            ragecd = {19, 22, loop = false, type = "series"},
            lightningtotemcd = {11.38, 18, loop = false, type = "series"},
            windscd = {11.38, 9, loop = false, type = "series"},
            flamewhirlcd = {8, 12, loop = false, type = "series"},
            breathcd = {10, 12, loop = false, type = "series"},
            pillarcd = {13, 6, loop = false, type = "series"},
            throwtext = "",
            surgetext = "",
            phase2warned = "no",
            phase3warned = "no",
            nextphase = "2",
        },
        onstart = {
            {
                "alert","throwcd",
                "alert","whirlwindcd",
                "repeattimer",{"checkhp", 1},
            },
        },
        
        raidicons = {
            lightningtotemmark = {
                varname = format("%s {%s}","Lightning Totem","NPC_ENEMY"),
                type = "ENEMY",
                persist = 10,
                unit = "#4#",
                reset = 16,
                icon = 1,
                texture = ST[97930],
            },
            ragemark = {
                varname = format("%s {%s}",SN[42583],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 5,
                unit = "&unitname|boss1target&",
                reset = 10,
                icon = 1,
                texture = ST[42583],
            },
        },
        phrasecolors = {
            {"Daakara","GOLD"},
        },
        grouping = {
            {
                phase = 1,
                alerts = {"throwcd","throwwarn","whirlwindcd","whirlwindwarn","phasesoonwarn"},
            },
            {
                name = format("|cffffd700%s|r |cffffffff%s|r","Bear","form"),
                icon = ST[42594],
                alerts = {"bearshapewarn","paralysiscd","paralysiswarn","surgecd","surgewarn"},
            },
            {
                name = format("|cffffd700%s|r |cffffffff%s|r","Lynx","form"),
                icon = ST[42607],
                alerts = {"lynxshapewarn","rushcd","rushwarn","ragecd","ragewarn"},
            },
            {
                name = format("|cffffd700%s|r |cffffffff%s|r","Eagle","form"),
                icon = ST[42606],
                alerts = {"eagleshapewarn","lightningtotemcd","lightningtotemwarn","windscd"},
            },
            {
                name = format("|cffffd700%s|r |cffffffff%s|r","Dragonhawk","form"),
                icon = ST[42608],
                alerts = {"dragonhawkshapewarn","flamewhirlcd","breathcd","breathwarn","pillarcd","pillarselfwarn"},
            },
            
        },
        
        alerts = {
            -- Grievous Throw
            throwcd = {
                varname = format(L.alert["%s CD"],SN[97639]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97639]),
                time = "<throwcd>",
                flashtime = 5,
                color1 = "TAN",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[97639],
            },
            throwwarn = {
                varname = format(L.alert["%s Warning"],SN[97639]),
                type = "simple",
                text = "<throwtext>",
                time = 1,
                color1 = "TAN",
                sound = "ALERT8",
                icon = ST[97639],
            },
            -- Whirlwind
            whirlwindcd = {
                varname = format(L.alert["%s CD"],SN[17207]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[17207]),
                time = 15,
                flashtime = 5,
                color1 = "CYAN",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[17207],
            },
            whirlwindwarn = {
                varname = format(L.alert["%s Warning"],SN[17207]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[17207]),
                time = 2,
                color1 = "CYAN",
                sound = "ALERT2",
                icon = ST[17207],
            },
            -- Phase
            phasesoonwarn = {
                varname = format(L.alert["%s soon Warning"],"Phase"),
                type = "simple",
                text = format(L.alert["%s %s soon ..."],"Phase","<nextphase>"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[78832],
            },
            -------------------------
            -- Essence of the Bear --
            -------------------------
            -- Shape of the Bear
            bearshapewarn = {
                varname = format(L.alert["%s Warning"],SN[42594]),
                type = "simple",
                text = format(L.alert["%s"],SN[42594]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT1",
                icon = ST[42594],
            },
            -- Creeping Paralysis
            paralysiscd = {
                varname = format(L.alert["%s CD"],SN[43095]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43095]),
                time = "<paralysiscd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43095],
            },
            paralysiswarn = {
                varname = format(L.alert["%s Warning"],SN[43095]),
                type = "centerpopup",
                text = format(L.alert["%s - DISPEL!"],SN[43095]),
                time = 6,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT8",
                icon = ST[43095],
            },
            -- Surge
            surgecd = {
                varname = format(L.alert["%s CD"],SN[44019]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[44019]),
                time = "<surgecd>",
                flashtime = 5,
                color1 = "RED",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[44019],
            },
            surgewarn = {
                varname = format(L.alert["%s Warning"],SN[44019]),
                type = "simple",
                text = "<surgetext>",
                time = 1,
                color1 = "TAN",
                sound = "ALERT7",
                icon = ST[44019],
            },
            -------------------------
            -- Essence of the Lynx --
            -------------------------
            -- Shape of the Lynx
            lynxshapewarn = {
                varname = format(L.alert["%s Warning"],SN[42607]),
                type = "simple",
                text = format(L.alert["%s"],SN[42607]),
                time = 1,
                color1 = "TAN",
                sound = "ALERT1",
                icon = ST[42607],
            },
            -- Lynx Rush
            rushcd = {
                varname = format(L.alert["%s CD"],SN[43152]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43152]),
                time = "<rushcd>",
                flashtime = 5,
                color1 = "RED",
                color2 = "TAN",
                sound = "MINORWARNING",
                icon = ST[43153],
                throttle = 20,
            },
            rushwarn = {
                varname = format(L.alert["%s Warning"],SN[43152]),
                type = "simple",
                text = format(L.alert["%s"],SN[43152]),
                time = 1,
                color1 = "RED",
                sound = "ALERT7",
                icon = ST[43153],
                throttle = 20,
            },
            -- Claw Rage
            ragecd = {
                varname = format(L.alert["%s CD"],SN[43149]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43149]),
                time = "<ragecd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[43149],
                throttle = 15,
            },
            ragewarn = {
                varname = format(L.alert["%s Warning"],SN[43149]),
                type = "simple",
                text = format(L.alert["%s"],SN[43149]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[43149],
                throttle = 20,
            },
            --------------------------
            -- Essence of the Eagle --
            --------------------------
            -- Shape of the Eagle
            eagleshapewarn = {
                varname = format(L.alert["%s Warning"],SN[42606]),
                type = "simple",
                text = format(L.alert["%s"],SN[42606]),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT1",
                icon = ST[42606],
            },
            -- Lightning Totem
            lightningtotemcd = {
                varname = format(L.alert["%s CD"],SN[97930]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97930]),
                time = "<lightningtotemcd>",
                flashtime = 5,
                color1 = "CYAN",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[97930],
            },
            lightningtotemwarn = {
                varname = format(L.alert["%s Warning"],SN[97930]),
                type = "simple",
                text = format(L.alert["%s - DESTROY IT"],SN[97930]),
                time = 1,
                color1 = "CYAN",
                color2 = "RED",
                sound = "ALERT10",
                icon = ST[97930],
            },
            -- Sweeping Winds
            windscd = {
                varname = format(L.alert["%s CD"],SN[97647]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97647]),
                time = "<windscd>",
                flashtime = 5,
                color1 = "MAGENTA",
                color2 = "PURPLE",
                sound = "MINORWARNING",
                icon = ST[97647],
            },
            -------------------------------
            -- Essence of the Dragonhawk --
            -------------------------------
            -- Shape of the Dragonhawk
            dragonhawkshapewarn = {
                varname = format(L.alert["%s Warning"],SN[42608]),
                type = "simple",
                text = format(L.alert["%s"],SN[42608]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT1",
                icon = ST[42608],
            },
            -- Flame Whirlwind
            flamewhirlcd = {
                varname = format(L.alert["%s CD"],SN[43213]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43213]),
                time = "<flamewhirlcd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[43213],
            },
            -- Flame Breath
            breathcd = {
                varname = format(L.alert["%s CD"],SN[97855]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97855]),
                time = "<breathcd>",
                flashtime = 5,
                color1 = "RED",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[105468],
            },
            breathwarn = {
                varname = format(L.alert["%s Warning"],SN[97855]),
                type = "simple",
                text = format(L.alert["%s"],SN[97855]),
                time = 1,
                color1 = "TAN",
                sound = "ALERT2",
                icon = ST[105468],
            },
            -- Pillar of Fire
            pillarcd = {
                varname = format(L.alert["%s CD"],SN[43216]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43216]),
                time = "<pillarcd>",
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[43216],
            },
            pillarselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[43216]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[43216],L.alert["YOU"]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT10",
                icon = ST[43216],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","85"},
                    "expect",{"<phase2warned>","==","no"},
                    "set",{phase2warned = "yes"},
                    "alert","phasesoonwarn",
                    "set",{nextphase = "3"},
                },
                {
                    "expect",{"&gethp|boss1&","<","45"},
                    "expect",{"<phase3warned>","==","no"},
                    "set",{phase3warned = "yes"},
                    "alert","phasesoonwarn",
                },
                {
                    "expect",{"<phase2warned>","==","yes"},
                    "expect",{"<phase3warned>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
            ragetimer = {
                {
                    "raidicon","ragemark",
                },
            },
        },
        events = {
			-- Grievous Throw
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 97639,
                execute = {
                    {
                        "quash","throwcd",
                        "alert","throwcd",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{throwtext = format(L.alert["Daakara throws his weapon at %s"],L.alert["YOU"])},
                        "alert","throwwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{throwtext = format(L.alert["Daakara throws his weapon at <%s>"],"#5#")},
                        "alert","throwwarn",
                    },
                },
            },
            -- Whirlwind
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 17207,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","23863"},
                        "quash","whirlwindcd",
                        "alert","whirlwindcd",
                        "alert","whirlwindwarn",
                    },
                },
            },
            
            -------------------------
            -- Essence of the Bear --
            -------------------------
            -- Shape of the Bear
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_zulaman["^Got me some new tricks"]},
                        "quash","whirlwindcd",
                        "quash","throwcd",
                        "alert","bearshapewarn",
                        "alert","paralysiscd",
                        "alert","surgecd",
                    },
                },
            },
            
            -- Creeping Paralysis
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43095,
                execute = {
                    {
                        "quash","paralysiscd",
                        "alert","paralysiscd",
                        "alert","paralysiswarn",
                    },
                },
            },
            -- Surge
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[44019]},
                        "expect",{"#1#","==","boss1"},
                        "quash","surgecd",
                        "alert","surgecd",
                    },
                },
            },
            
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 42402,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{surgetext = format(L.alert["Daakara charged towards %s"],L.alert["YOU"])},
                        "alert","surgewarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{surgetext = format(L.alert["Daakara charged towards <%s>"],"#5#")},
                        "alert","surgewarn",
                    },
                },
            },
            -------------------------
            -- Essence of the Lynx --
            -------------------------
            -- Shape of the Lynx
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_zulaman["^Let me introduce to you"]},
                        "quash","whirlwindcd",
                        "quash","throwcd",
                        "alert","lynxshapewarn",
                        "alert","rushcd",
                        "alert","ragecd",
                    },
                },
            },
            -- Lynx Rush
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43152]},
                        "expect",{"#1#","==","boss1"},
                        "alert","rushcd",
                        "alert","rushwarn",
                    },
                },
            },
            -- Claw Rage
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#5#","==","42583"},
                        "expect",{"#1#","==","boss1"},
                        "alert","ragecd",
                        "alert","ragewarn",
                        "scheduletimer",{"ragetimer", 0.05},
                    },
                },
            },
            --------------------------
            -- Essence of the Eagle --
            --------------------------
            -- Shape of the Eagle
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_zulaman["^Dere be no hidin"]},
                        "batchquash",{"paralysiscd","surgecd","rushcd","ragecd"},
                        "alert","eagleshapewarn",
                        "alert","lightningtotemcd",
                        "alert","windscd",
                    },
                },
            },
            -- Lightning Totem
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 97930,
                execute = {
                    {
                        "quash","lightningtotemcd",
                        "alert","lightningtotemcd",
                        "alert","lightningtotemwarn",
                        "raidicon","lightningtotemmark",
                    },
                },
            },
            -- Sweeping Winds
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[97647]},
                        "expect",{"#1#","==","boss1"},
                        "quash","windscd",
                        "alert","windscd",
                    },
                },
            },
            -------------------------------
            -- Essence of the Dragonhawk --
            -------------------------------
            -- Shape of the Dragonhawk
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_zulaman["^Ya don"]},
                        "batchquash",{"paralysiscd","surgecd","rushcd","ragecd"},
                        "alert","dragonhawkshapewarn",
                        "alert","flamewhirlcd",
                        "alert","breathcd",
                        "alert","pillarcd",
                    },
                },
            },
            -- Flame Whirl
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 43213,
                execute = {
                    {
                        "quash","flamewhirlcd",
                        "alert","flamewhirlcd",
                    },
                },
            },
            -- Flame Breath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 97855,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","23863"},
                        "quash","breathcd",
                        "alert","breathcd",
                        "alert","breathwarn",
                    },
                },
            },
            -- Pillar of Fire
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43216]},
                        "expect",{"#1#","==","boss1"},
                        "quash","pillarcd",
                        "alert","pillarcd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 97682,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","pillarselfwarn",
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
        key = "zulamantrash",
        zone = L.zone["Zul'Aman"],
        category = L.zone["Zul'Aman"],
        name = "Trash",
        triggers = {
            scan = {
                52956, -- Zandalari Juggernaut
                52962, -- Zandalari Archon
                23597, -- Amani'shi Guardian
                23596, -- Amani'shi Flame Caster
                52958, -- Zandalari Hierophant
                24059, -- Amani’shi Beast Tamer
                23581, -- Amani'shi Medicine Man
                23542, -- Amani'shi Axe Thrower
                23582, -- Amani'shi Tribesman
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {
            blazingtext = "",
        },
        
        raidicons = {
            protectmark = {
                varname = format("%s {%s}","Protective Ward","NPC_ENEMY"),
                type = "ENEMY",
                persist = 15,
                unit = "#4#",
                reset = 120,
                icon = 1,
                texture = ST[97477],
            },
        },
        phrasecolors = {
            {"Amani'shi Flame Caster:?","GOLD"},
            {"Zandalari Hierophant:","GOLD"},
            {"Amani’shi Beast Tamer:","GOLD"},
            {"/","WHITE"},
        },
        ordering = {
            alerts = {"blazinghastewarn","volleywarn","ancientpowerwarn","quakeselfwarn","domesticatewarn","domesticatecd"},
        },
        
        alerts = {
            -- Minor Quake
            quakeselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[97988]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[97988],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[97988],
                throttle = 2,
            },
            -- Fireball Volley
            volleywarn = {
                varname = format(L.alert["%s Warning"],SN[97464]),
                type = "simple",
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Amani'shi Flame Caster",SN[97464]),
                text = format(L.alert["%s - INTERRUPT"],SN[97464]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[97464],
            },
            -- Blazing Haste
            blazinghastewarn = {
                varname = format(L.alert["%s Warning"],SN[97485]),
                type = "simple",
                text = "<blazingtext>",
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[97485],
            },
            -- Ancient Power
            ancientpowerwarn = {
                varname = format(L.alert["%s Warning"],SN[97962]),
                type = "centerpopup",
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Zandalari Hierophant",SN[97962]),
                text = format(L.alert["%s - INTERRUPT"],SN[97962]),
                time = 2.5,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[97962],
            },
            -- Domesticate
            domesticatewarn = {
                varname = format(L.alert["%s Warning"],SN[43361]),
                type = "centerpopup",
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Amani’shi Beast Tamer",SN[43361]),
                text = format(L.alert["%s - INTERRUPT"],SN[43361]),
                time = 1.5,
                color1 = "TAN",
                sound = "ALERT2",
                icon = ST[43361],
                tag = "#1#",
            },
            domesticatecd = {
                varname = format(L.alert["%s CD"],SN[43361]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[43361]),
                time = 22,
                flashtime = 5,
                color1 = "TAN",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[43361],
                tag = "#1#",
            },
            
        },
        events = {
            -- Minor Quake
            {
                type = "combatevent",
                eventtype = "SPELL_PERIODIC_DAMAGE",
                spellname = 97988,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","quakeselfwarn",
                    },
                },
            },
            -- Fireball Volley
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 97464,
                execute = {
                    {
                        "alert","volleywarn",
                    },
                },
            },
            -- Blazing Haste
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 97485,
                execute = {
                    {
                        "set",{blazingtext = format(L.alert["%s on %s - SPELLSTEAL / DISPEL!"],SN[97485],"Amani'shi Flame Caster")},
                        "alert","blazinghastewarn",
                    },
                },
            },
            -- Ancient Power
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 97962,
                execute = {
                    {
                        "alert","ancientpowerwarn",
                    },
                },
            },
            -- Domesticate
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 43361,
                execute = {
                    {
                        "alert","domesticatewarn",
                        "alert","domesticatecd",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[43361]},
                        "expect",{"&unitisplayertype|#1#&","==","false"},
                        "quash",{"domesticatewarn","&unitguid|#1#&"},
                        
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","24059"},
                        "quash",{"domesticatewarn","#4#"},
                        "quash",{"domesticatecd","#4#"},
                    },
                },
            },
            -- Protective Ward
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 97477,
                execute = {
                    {
                        "raidicon","protectmark",
                    },
                },
            },
            
            
        },
    }

    DXE:RegisterEncounter(data)
end
