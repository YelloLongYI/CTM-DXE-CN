local addon = DXE
local L,SN,ST,AL,AN,AT,TI = DXE.L,DXE.SN,DXE.ST,DXE.AL,DXE.AN,DXE.AT,DXE.TI

---------------------------------
-- MAGMAW
---------------------------------

do
    local data = {
        version = 6,
        key = "magmaw",
        zone = L.zone["Blackwing Descent"],
        category = L.zone["Blackwing Descent"],
        name = L.npc_descent["Magmaw"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Magmaw.blp",
        triggers = {
            scan = {
                41570, -- Magmaw
            },
        },
        onactivate = {
            tracing = {41570},
            phasemarkers = {
                {
                    {0.31, "Phase 2","When Magmaw reaches 30 % of his HP, Nefarian starts casting shadow volley on all players.",20}, -- heroic
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 41570,
        },
        userdata = {
            -- Texts
            mangletext = "",
            parasitefailer = "",
            
            -- Timers
            manglecd = {92.7,95, loop = false, type = "series"},  -- 90,115,115
            slumpcd = {102,96, loop = false, type = "series"},
            constructcd = {25,31.5, loop = false, type = "series"}, --heroic only
            pillarcd = {33, 37, 0, loop = true, type = "series"},
             
            -- Switches
            parasitefailed = "no",
            lavaspewthrottle = "no",
        },
        onstart = {
            {
                "alert","enragecd",
                "alert","pillarcd",
                "alert","manglecd",
                "alert","slumpcd",
                "alert","lavaspewcd",                
            },
            {
                "expect",{"&difficulty&",">=","3"}, --10h&25h
                "alert","constructcd",
            },
        },
        
        announces = {
            parasitefailed = {
                varname = "%s failed",
                type = "RAID",
                subtype = "achievement",
                achievement = 5306,
                msg = format(L.alert["<DXE> %s: Achievement failed! (%s)"],AL[5306],"<parasitefailer>"),
                throttle = true,
            },
        },
        filters = {
            bossemotes = {
                -- Mangle
                jumpemote = {
                    name = "Head exposed",
                    pattern = "are close enough to reach",
                    hasIcon = false,
                    hide = true,
                    texture = ST[78632],
                },
                slumpemote = {
                    name = SN[88253],
                    pattern = "slumps forward, exposing his pincers",
                    hasIcon = false,
                    hide = true,
                    texture = ST[88253],
                },
                pillaremote = {
                    name = "Pillar of Flame",
                    pattern = "spewing Lava Parasites",
                    hasIcon = false,
                    hide = true,
                    texture = ST[78006],
                },
                impaledemote = {
                    name = "Impale",
                    pattern = "becomes impaled on the spike",
                    hasIcon = false,
                    hide = true,
                    texture = ST[62310],
                },
            },
        },
        windows = {
			proxwindow = true,
			proxrange = 5,
			proxoverride = true,
            proxnoautostart = true,
		},
        
        ordering = {
            alerts = {"enragecd","lavaspewcd","lavaspewwarn","constructcd","armageddonwarn","pillarcd","pillarwarn","manglecd","manglewarn","slumpcd","slumpwarn","mountduration","exposeddur","p2warn"},
        },
        alerts = {
            -- Berserk
            enragecd = {
                varname = format(L.alert["%s CD"],SN[26662]),
                type = "dropdown",
                text = format(L.alert["Berserk"],SN[26662]),
                time = 600,
                flashtime = 30,
                color1 = "RED",
                icon = ST[26662],
            },
            -- Lava Spew
            lavaspewcd = {
                varname = format(L.alert["%s CD"],SN[77689]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[77689]),
                time = 22,
                time2 = 36,
                time3 = 16,
                flashtime = 5,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[77689],
                throttle = 5,
            },
            lavaspewwarn = {
                varname = format(L.alert["%s Warning"],SN[77689]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s"],SN[77689]),
                time = 5,
                color1 = "ORANGE",
                sound = "ALERT4",
                icon = ST[77689],
                throttle = 5,
            },
            -- Mangle
            manglecd = {
                varname = format(L.alert["%s CD"],SN[91912]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91912]),
                time = "<manglecd>",
                flashtime = 10,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[91912],
                flashscreen = true
            },
            manglewarn = {
                varname = format(L.alert["%s Warning"],SN[91912]),
                type = "simple",
                text = "<mangletext>",
                time = 30,
                flashtime = 30,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[91912],
            },
            -- Pillar of Flame
            pillarcd = {
                varname = format(L.alert["%s CD"],L.npc_descent["Lava Parasites"]),
                type = "dropdown",
                text = format(L.alert["New %s"],L.npc_descent["Lava Parasites"]),
                time = "<pillarcd>",
                time2 = 40,
                time3 = 20,
                flashtime = 5,
                sound = "ALERT4",
                color1 = "PINK",
                icon = ST[78097],
            },
            pillarwarn = {
                varname = format(L.alert["%s Warning"],L.npc_descent["Lava Parasites"]),
                type = "simple",
                text = format(L.alert["New: %s"],L.npc_descent["Lava Parasites"]),
                time = 5,
                flashtime = 5,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[78097],
            },
            -- Massive Crash
            slumpcd = {
                varname = format(L.alert["%s CD"],SN[91921]),
                type = "dropdown",
                text = format(L.alert["Magmaw Slumping"]),
                time = "<slumpcd>",
                time2 = 104.3,
                flashtime = 10,
                color1 = "ORANGE",
                color2 = "RED",
                icon = ST[91921],
                sound = "ALERT10",
            },
            slumpwarn = {
                varname = format(L.alert["%s Warning"],SN[91921]),
                type = "simple",
                text = format(L.alert["Mount him like you mean it!"]),
                time = 5,
                flashtime = 5,
                color1 = "GOLD",
                sound = "ALERT2",
                icon = ST[78632],
            },
            -- Impale
            mountduration = {
                varname = format(L.alert["%s Duration"],"Magmaw Impaled"),
                type = "centerpopup",
                text = format(L.alert["%s frees himself"],"Magmaw"),
                time = 6,
                color1 = "LIGHTBLUE",
                sound = "None",
                icon = ST[78632],
            },
            -- Head Exposed
            exposeddur = {
                varname = format(L.alert["Exposed Head Duration"]),
                type = "centerpopup",
                text = format(L.alert["Exposed Head!"]),
                time = 30,
                flashtime = 30,
                color1 = "GOLD",
                sound = "BURST",
                icon = ST[79011],
                audiocd = true,
            },
            ------------
            -- Heroic --
            ------------
            -- Blazing Inferno
            constructcd = {
                varname = format(L.alert["%s CD"],SN[92192]),
                type = "dropdown",
                text = format(L.alert["New %s"],SN[92192]),
                time = "<constructcd>",
                flashtime = 7.5,
                color1 = "BROWN",
                sound = "MINORWARNING",
                icon = ST[92192],
            },
            -- Armageddon
            armageddonwarn = {
                varname = format(L.alert["%s Warning"],SN[92177]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[92177]),
                time = 8,
                flashtime = 8,
                color1 = "RED",
                sound = "BEWARE",
                icon = ST[92177],
                tag = "#1#",
            },
            -- Phase 2
            p2warn = {
                varname = format(L.alert["Phase 2 Warning"]),
                type = "simple",
                text = format(L.alert["Phase 2"]),
                time = 5,
                flashtime = 5,
                icon = ST[11242],
                color1 = "TURQUOISE",
                sound = "BEWARE",
            },
        },
        timers = {
            lavaspewthrottletimer = {
                {
                    "set",{lavaspewthrottle = "no"},
                },
            },
            exposedtimer = {
                {
                    "tracing",{41570},
                },
            },
        },
        events = {
            -- Lava Spew
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 91919,
                execute = {
                    {
                        "alert","lavaspewwarn",
                        "invoke",{
                            {
                                "expect",{"<lavaspewthrottle>","==","no"},
                                "set",{lavaspewthrottle = "yes"},
                                "quash","lavaspewcd",
                                "scheduletimer",{"lavaspewthrottletimer", 7},
                            },
                        },
                        "expect",{"&timeleft|manglecd&",">","22"},
                        "alert","lavaspewcd",
                    },
                },
            },
            -- Pillar (New: Parasites)
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 78006,
                dstnpcid = 41570,
                execute = {
                    {
                        "alert","pillarwarn",
                        "alert","pillarcd",
                    },
                },
            },
            -- Mangle
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = {
                    91912,
                    94616,
                    94617,
                    89773,
                },
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{mangletext = format(L.alert["%s on %s!"],SN[91912],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{mangletext = format(L.alert["%s on <%s>"],SN[91912],"#5#")},
                    },
                    {
                        "alert","manglewarn",
                        "alert","manglecd",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    -- Head smashes
                    {
                        "expect",{"#5#","==","88253"},
                        "expect",{"#1#","find","boss"},
                        "quash","pillarcd",
                        "alert",{"pillarcd",time = 3},
                        "set",{pillarcd = {32.5, 33.8, 0, loop = false, type = "series"}},
                        "alert","slumpwarn",
                        "quash","slumpcd",
                        "alert","slumpcd",
                        "alert","mountduration",
                        "quash","lavaspewcd",
                        "alert",{"lavaspewcd",time = 3},
                    },
                    -- Head is impaled
                    {
                        "expect",{"#2#","==",SN[77907]},
                        "expect",{"#1#","find","boss"},
                        "tracing",{42347},
                        "scheduletimer",{"exposedtimer", 30},
                        "alert","exposeddur",
                        "quash","manglecd",
                        "quash","mountduration",
                        "alert","manglecd",
                        "quash","slumpcd",
                        "alert",{"slumpcd",time = 2},
                        "quash","pillarcd",
                        "alert",{"pillarcd",time = 2},
                        "quash","lavaspewcd",
                        "alert",{"lavaspewcd",time = 2},
                        "set",{pillarcd = {33,37, loop = true, type = "series"}},
                    },
                },
            },
            -- Parasite Evening (achievement)
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 91913,
                execute = {
                    {
                        "expect",{"<parasitefailed>","==","no"},
                        "set",{parasitefailed = "yes",
                            parasitefailer = "#5#",
                        },
                        "announce","parasitefailed",
                    },
                },
            },
            ------------
            -- Heroic --
            ------------
            -- Blazing Inferno (New: Blazing Bone Construct)
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 92192,
                execute = {
                    {
                        "quash","constructcd",
                        "alert","constructcd",
                    },
                },
            },
            -- Armageddon (Blazing Bone Construct @ low HP)
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 92177,
                execute = {
                    {
                        "alert","armageddonwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","49416"},
                        "quash",{"armageddonwarn","#4#"},
                    },
                },
            },
            -- Phase 2
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_descent["^Incon"]},
                        "quash","constructcd",
                        "alert","p2warn",
                        "range",{true},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- OMNOTRON DEFENSE SYSTEM
---------------------------------

do
    local data = {
        version = 11,
        key = "omnitron",
        zone = L.zone["Blackwing Descent"],
        category = L.zone["Blackwing Descent"],
        name = L.npc_descent["Omnotron Defense System"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Magmatron.blp",
        icon2 = "Interface\\EncounterJournal\\UI-EJ-BOSS-Electron.blp",
        triggers = {
            scan = {
                42166, -- Arcanotron
                42179, -- Electron
                42178, -- Magmatron
                42180, -- Toxitron
            },
        },
        onactivate = {
            tracing = {
                42166, -- Arcanotron
                42179, -- Electron
                42178, -- Magmatron
                42180, -- Toxitron
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = {
                42166, -- Arcanotron
                42179, -- Electron
                42178, -- Magmatron
                42180, -- Toxitron
            },
        },
        userdata = {
            -- Texts
            activetext = "",
            encasingtext = "",
            conductortext = "",
            infusiontext = "",
            fixedtext = "",
            
            -- Timers
            incinerationcd = {10,26,28.5,0, loop = true, type = "series"},
            flamethrowercd = {20,40,0, loop = true, type = "series"},
            generatorcd = {15,30,30,0, loop = true, type = "series"},
            conductorcd = {11,25,25,25,0, loop = true, type = "series"},
            poisonbombcd = {11,30,30,0, loop = true, type = "series"},  -- 15,30,30,0 
            addscd = {21,45,0, loop = true, type = "series"},
            
            -- Durations
            activetime = 45,
            conductordur = 10,
            
            -- Switches
            shadowconductorwarned = "no",
            started = "no",
        },
        onstart = {
            {
                "expect",{"&difficulty&",">=","3"}, --10h&25h
                "set",{
                    activetime = 30,
                    incinerationcd = {10,26,0, loop = true, type = "series"},
                    flamethrowercd = {20,27, loop = true, type = "series"},
                    generatorcd = {15,20,20,0, loop = true, type = "series"},
                    conductorcd = {15,20,20,0, loop = true, type = "series"},
                    conductordur = 16,
                    poisonbombcd = {25,30,0, loop = true, type = "series"}, 
                    addscd = {15,25,0, loop = true, type = "series"},
                    neftime = 32,
                },
            },
            {
                "alert","enragecd",
                "alert","nefcd",
            },
        },

        arrows = {
            flamesarrow = {
                varname = SN[92023],
                unit = "#5#",
                persist = 8,
                action = "AWAY",
                msg = L.alert["MOVE AWAY"],
                spell = SN[92023],
                texture = ST[92023],
            },
        },
        announces = {
            encasingsay = {
                type = "SAY",
                subtype = "self",
                spell = 92023,
                msg = format(L.alert["%s on ME"],SN[92023]).."!",
            },
            infusionsay = {
                type = "SAY",
                subtype = "self",
                spell = 92048,
                msg = format(L.alert["%s on ME"],SN[92048]).."!",
            },
            lightconductorsay = {
                type = "SAY",
                subtype = "self",
                spell = 91433,
                msg = format(L.alert["%s on ME"],SN[91433]).."!",
            },
        },
        raidicons = {
            flamethrowermark = {
                varname = format("%s {%s}",SN[92035],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 4,
                unit = "#5#",
                icon = 1,
                texture = ST[92035],
            },
            infusionmark = {
                varname = format("%s {%s}",SN[92048],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                persist = 16,
                unit = "#5#",
                icon = 2,
                texture = ST[92048],
            },
            conductormark = {
                varname = format("%s {%s}",SN[91431],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                persist = 16,
                unit = "#5#",
                icon = 3,
                texture = ST[91431],
            },
        },
        filters = {
            bossemotes = {
                conductoremote = {
                    name = "Lightning Conductor",
                    pattern = "Lightning Conductor",
                    hasIcon = true,
                    hide = true,
                    texture = ST[91433],
                },
                flameemote = {
                    name = "Acquiring Target",
                    pattern = "sets his eye on",
                    hasIcon = true,
                    hide = true,
                    texture = ST[92035],
                },
                -- Toxitron's Shield
                poisonshellemote = {
                    name = "Poison Soaked Shell",
                    pattern = "Poison Soaked Shell",
                    hasIcon = true,
                    texture = ST[79835],
                },
                -- Arcanotron's Shield
                powerconversionemote = {
                    name = "Power Conversion",
                    pattern = "Arcanotron begins to cast %[Power Conversion%]",
                    hasIcon = true,
                    texture = ST[91543],
                },
                -- Magmatron's Shield
                barrieremote = {
                    name = "Barrier",
                    pattern = "Magmatron begins to cast %[Barrier%]",
                    hasIcon = true,
                    texture = ST[79582],
                },
                -- Electron's Shield
                unstableshieldemote = {
                    name = "Unstable Shield",
                    pattern = "Electron begins to cast %[Unstable Shield%]",
                    hasIcon = true,
                    texture = ST[91447],
                },
            },
        },
        phrasecolors = {
            {"Electron","CYAN"},
            {"Toxitron","LIGHTGREEN"},
            {"Magmatron","ORANGE"},
            {"Arcanotron","MAGENTA"},
        },
        radars = {
            conductorradar = {
                varname = SN[91433],
                type = "circle",
                player = "#5#",
                range = 8,
                mode = "avoid",
                icon = ST[91433],
            },
        },
        windows = {
			proxwindow = true,
			proxrange = 30,
			proxoverride = true,
            proxnoautostart = true,
            nodistancecheck = true,
		},
        misc = {
            args = {
                annihilatortargetonly = {
                    name = format(L.chat_descent["|T%s:16:16|t |cffffd600%s|r Cooldown only for target."],ST[91542],SN[91542]),
                    desc = format("Trigger %s cooldown timer only when you have Arcanotron as your target.", SN[91542]),
                    type = "toggle",
                    order = 1,
                    default = false,
                },
                reset_button = addon:genmiscreset(10,"annihilatortargetonly"),
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd","activedur","activewarn","nefcd"},
            },
            {
                name = format("|cffffd700%s|r","Arcanotron"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Arcanotron",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"annihilatorcd","annihilatorwarn","generatorcd","overcharged"},
            },
            {
                name = format("|cffffd700%s|r","Electron"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Electron",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"conductorcd","conductorwarn","conductorselfwarn","infusionwarn","infusionselfwarn","infusiondur","shadowconductordur"},
            },
            {
                name = format("|cffffd700%s|r","Magmatron"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Magmatron",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"incinerationcd","incinerationwarn","flamethrowercd","flamethrowerdur","flamethrowerselfwarn","encasingwarn","encasingselfwarn","barrierabsorb"},
            },
            {
                name = format("|cffffd700%s|r","Toxitron"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Toxitron",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"poisonbombcd","addscd","addswarn","fixateself","fixatewarn","gripwarn"},
            },
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = format(L.alert["Berserk CD"]),
                type = "dropdown",
                text = format(L.alert["Berserk"]),
                time = 600,
                flashtime = 30,
                color1 = "RED",
                icon = ST[26662],
            },
            -- Golem Active
            activedur = {
                varname = format(L.alert["%s Duration"],SN[95016]),
                type = "dropdown",
                text = format(L.alert["Next Golem Activates"]),
                time = "<activetime>",
                flashtime = 5,
                color1 = "INDIGO",
                sound = "None",
                icon = ST[95016]
            },
            activewarn = {
                varname = format(L.alert["%s Warning"],SN[95016]),
                type = "simple",
                text = "<activewarntext>",
                time = 5,
                color1 = "GOLD",
                sound = "ALERT10",
                icon = ST[95016],
            },
            -----------------
            --- Magmatron ---
            -----------------
            -- Incineration Security Measure
            incinerationcd = {
                varname = format(L.alert["%s CD"],L.alert["Incineration"]),
                type = "dropdown",
                text = format(L.alert["Next %s"],L.alert["Incineration"]),
                time = "<incinerationcd>",
                flashtime = 5,
                color1 = "ORANGE",
                icon = ST[91521]
            },
            incinerationwarn = {
                varname = format(L.alert["%s Warning"],L.alert["Incineration"]),
                type = "simple",
                text = format("%s!",L.alert["Incineration"]),
                time = 5.5,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[91521],
            },
            -- Flamethrower
            flamethrowercd = {
                varname = format(L.alert["%s CD"],SN[91533]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91533]),
                time = "<flamethrowercd>",
                flashtime = 5,
                color1 = "RED",
                icon = ST[91533]
            },
            flamethrowerdur = {
                -- varname = "Acquiring Target Warning",
                varname = format(L.alert["%s Warning"],SN[91533]),
                type = "centerpopup",
                text = "<flamethrowertext>",
                time = 8,
                color1 = "RED",
                sound = "None",
                icon = ST[91533],
            },
            flamethrowerselfwarn = {
                -- varname = "Acquiring Target on me Warning",
                varname = format(L.alert["%s on me Warning"],SN[91533]),
                type = "centerpopup",
                text = format(L.alert["%s on <%s>!"],SN[91533],L.alert["YOU"]),
                time = 8,
                color1 = "GOLD",
                sound = "ALERT10",
                icon = ST[91533],
                flashscreen = true,
            },
            -- Encasing Shadows (heroic)
            encasingwarn = {
                varname = format(L.alert["%s Warning"],SN[92023]),
                type = "centerpopup",
                text = "<encasingtext>",
                time = 8,
                color1 = "GOLD",
                sound = "ALERT12",
                icon = ST[92023],
            },
            encasingselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[92023]),
                type = "centerpopup",
                text = format(L.alert["<%s> can't move!"],L.alert["YOU"]),
                time = 8,
                color1 = "PINK",
                sound = "None",
                icon = ST[92023],
                flashscreen = true,
            },
            ------------------
            --- Arcanotron ---
            ------------------
            -- Power Generator
            generatorcd = {
                varname = format(L.alert["%s CD"],SN[79624]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[79624]),
                time = "<generatorcd>",
                flashtime = 5,
                color1 = "INDIGO",
                icon = ST[79624],
                sticky = true,
            },
            -- Overcharged Power Generator (heroic)
            overcharged = {
                varname = format(L.alert["Overcharged Zone Countdown"]),
                type = "dropdown",
                text = format(L.alert["Overcharged Zone, get out!"]),
                time = 10,
                flashtime = 8,
                color1 = "WHITE",
                sound = "RUNAWAY",
                icon = ST[91857],
                throttle = 10,
            },
            -- Arcane Annihilator
            annihilatorcd = {
                varname = format(L.alert["%s CD"],SN[91542]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[91542]),
                time10man = 7.2,
                time25man = 3.65,
                time2 = 3.5,
                flashtime = 5,
                color1 = "INDIGO",
                color2 = "BLUE",
                sound = "None",
                icon = ST[91542],
            },
            annihilatorwarn = {
                varname = format(L.alert["%s Warning"],SN[91542]),
                type = "simple",
                text = format(L.alert["%s - INTERRUPT"],SN[91542]),
                time = 1.5,
                color1 = "TURQUOISE",
                sound = "ALERT8",
                icon = ST[91542],
            },
            
            ----------------
            --- Electron ---
            ----------------
            -- Lightning Conductor
            conductorcd = {
                varname = format(L.alert["%s CD"],SN[91433]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91433]),
                time = "<conductorcd>",
                flashtime = 5,
                color1 = "INDIGO",
                icon = ST[91433],
                sound = "None",
            },
            conductorwarn = {
                varname = format(L.alert["%s Warning"],SN[91433]),
                type = "simple",
                text = "<conductortext>",
                time = "<conductordur>",
                flashtime = 16,
                color1 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[91433]
            },
            conductorselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[91433]),
                type = "centerpopup",
                text = format("%s on <%s>",SN[91433],L.alert["YOU"]),
                time = "<conductordur>",
                flashtime = 16,
                color1 = "CYAN",
                sound = "RUNAWAY",
                icon = ST[91433]
            },
            -- Shadow Infusion (heroic)
            infusionwarn = {
                varname = format(L.alert["%s Warning"],SN[92048]),
                type = "simple",
                text = "<infusiontext>",
                time = 5,
                color1 = "MAGENTA",
                -- sound = "ALERT2",
                sound = "shadowae",
                icon = ST[92048]
            },
            infusionselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[92048]),
                type = "simple",
                text = format("Shadow Conductor on <%s>!",L.alert["YOU"]),
                time = 16,
                flashtime = 16,
                color1 = "TURQUOISE",
                sound = "RUNAWAY",
                icon = ST[92048],
            },
            infusiondur = {
                varname = format(L.alert["%s Duration"],SN[92048]),
                type = "centerpopup",
                text = format("%s incoming",SN[92051]),
                time = 5,
                flashtime = 5,
                color1 = "MAGENTA",
                sound = "None",
                icon = ST[92048],
            },
            -- Shadow Conductor (heroic)
            shadowconductordur = {
                varname = format(L.alert["%s Duration"],SN[92051]),
                type = "centerpopup",
                text = "<shadowconductortext>",
                time = 10,
                flashtime = 16,
                color1 = "TURQUOISE",
                sound = "ALERT10",
                icon = ST[92051],
                fillDirection = "DEPLETE",
            },
            ----------------
            --- Toxitron ---
            ----------------
            -- Chemical Bomb
            poisonbombcd = {
                varname = format(L.alert["Poison Cloud CD"],SN[80157]),
                type = "dropdown",
                text = format(L.alert["Next Poison Cloud"],SN[80157]),
                time = "<poisonbombcd>",
                flashtime = 5,
                color1 = "LIGHTGREEN",
                icon = ST[80157],
                sound = "MINORWARNING",
            },
            -- Poison Protocol
            addscd = {
                varname = format(L.alert["%s CD"],SN[91515]),
                type = "dropdown",
                text = format(L.alert["New %s"],"Poison Bombs"),
                time = "<addscd>",
                flashtime = 5,
                color1 = "TEAL",
                icon = ST[91515]
            },
            addswarn = {
                varname = format(L.alert["%s Warning"],SN[91515]),
                type = "simple",
                text = format(L.alert["New: %s"],"Poison Bombs"),
                time = 9,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[91515]
            },
            -- Fixate
            fixateself = {
                varname = format(L.alert["%s on me Warning"],SN[80094]),
                type = "simple",
                text = format(L.alert["%s - RUN AWAY!"],SN[80094]),
                time = 3,
                color1 = "GOLD",
                sound = "ALERT12",
                icon = ST[80094],
                flashscreen = true,
            },
            fixatewarn = {
                varname = format(L.alert["%s Warning"],SN[80094]),
                type = "simple",
                text = "<fixatetext>",
                time = 3,
                color1 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[80094],
                flashscreen = true,
            },
            -- Grip of Death (heroic)
            gripwarn = {
                varname = format(L.alert["%s Warning"],SN[91849]),
                type = "centerpopup",
                text = format(L.alert["%s"], SN[91849]),
                time = 2,
                color1 = "GOLD",
                color2 = "MAGENTA",
                flashtime = 2,
                sound = "BEWARE",
                icon = ST[91849],
                flashscreen = true,
            },
            ----------------
            --- Nefarian ---
            ----------------
            nefcd = {
                varname = format(L.alert["Nefarian Ability CD"]),
                type = "dropdown",
                text = format(L.alert["Next Nefarian Action!"]),
                time = "<neftime>",
                flashtime = 7.5,
                color1 = "MAGENTA",
                sound = "ALERT9",
                icon = ST[92048],
            },
        },
        timers = {
            shadowcheck = {
                {
                    "expect",{"<shadowconductorwarned>","==","no"},
                    "expect",{"<conductortarget>","==","self"},
                    "alert","conductorselfwarn",          
                    "announce","lightconductorsay",
                },
                {
                    "expect",{"<shadowconductorwarned>","==","no"},
                    "expect",{"<conductortarget>","==","others"},
                    "alert","conductorwarn",
                },
                {
                    "set",{shadowconductorwarned = "no"},
                },                
            },
        },
        events = {
            {
                type = "event",
                event = "YELL",
                execute = {
                    -- Toxitron activated
                    {
                        "expect",{"#1#","find",L.chat_descent["^Toxitron unit activated"]},
                        "set",{activetext = format("%s active","Toxitron")},
                        "alert","activedur",
                        "alert","poisonbombcd",
                        "alert","addscd",
                        "invoke",{
                            {
                                "expect",{"<started>","==","yes"},
                                "set",{activewarntext = format("Switch to %s","Toxitron")},
                                "alert","activewarn",
                            },
                            {
                                "expect",{"<started>","==","no"},
                                "set",{starts = "yes"},
                            },
                        },
                    },
                    -- Magmatron activated
                    {
                        "expect",{"#1#","find",L.chat_descent["^Magmatron unit activated"]},
                        "set",{activetext = format("%s active","Magmatron")},
                        "alert","activedur",
                        "alert","incinerationcd",
                        "alert","flamethrowercd",
                        "expect",{"<started>","==","yes"},
                        "set",{activewarntext = format("Switch to %s","Magmatron") },
                        "alert","activewarn",
                    },
                    -- Electron activated
                    {
                        "expect",{"#1#","find",L.chat_descent["^Electron unit activated"]},
                        "set",{activetext = format("%s active","Electron")},
                        "alert","activedur",
                        "alert","conductorcd",
                        "expect",{"<started>","==","yes"},
                        "set",{activewarntext = format("Switch to %s","Electron") },
                        "alert","activewarn",
                    },
                    -- Arcanotron activated
                    {
                        "expect",{"#1#","find",L.chat_descent["^Arcanotron unit activated"]},
                        "set",{activetext = format("%s active","Arcanotron")},
                        "alert","activedur",
                        "alert","generatorcd",
                        "alert",{"annihilatorcd",time = 2},
                        "expect",{"<started>","==","yes"},
                        "set",{activewarntext = format("Switch to %s","Arcanotron") },
                        "alert","activewarn",
                    },
                    {
                        "expect",{"#1#","find",L.chat_descent["unit activated"]},
                        "expect",{"<started>","==","no"},
                        "set",{started = "yes"},          
                    },
                },
            },
            -- Deactivated
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 95018,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","42178"}, -- Magmatron
                        "quash","incinerationcd",
                        "quash","flamethrowercd",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","42166"}, -- Arcanotron
                        "quash","generatorcd",
                        "quash","annihilatorcd",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","42179"}, -- Electron
                        "quash","conductorcd",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","42180"}, --Toxitron
                        "quash","poisonbombcd",
                        "quash","addscd",
                    },
                },
            },
            -- Incineration
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91521,
                execute = {
                    {
                        "quash","incinerationcd",
                        "alert","incinerationcd",
                        "alert","incinerationwarn",
                    },
                },
            },
            -- Flame Thrower
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 92037, -- it's actually Acquiring Target
                execute = {
                    {
                        "quash","flamethrowercd",
                        "alert","flamethrowercd",
                        "raidicon","flamethrowermark",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{ flamethrowertext = format(L.alert["Acquiring on <%s>"],"#5#") },
                        "alert","flamethrowerdur",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","flamethrowerselfwarn",
                    },
                },
            },
            -- Encasing Shadows
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 92023,
                execute = {
                    {
                        "quash","nefcd",
                        "alert","nefcd",
                        "arrow","flamesarrow",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{ encasingtext = format(L.alert["<%s> can't move!"],"#5#") },
                        "alert","encasingwarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","encasingselfwarn",
                        "announce","encasingsay",
                    },
                },
            },
            -- Arcane Annihilator
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91542,
                execute = {
                    {
                        "quash","annihilatorcd",
                        "expect",{"&itemvalue|annihilatortargetonly&","~=","true",
                             "OR","&npcid|&unitguid|target&&","==","42166"},
                        "alert","annihilatorcd",
                        "alert","annihilatorwarn",
                    },
                },
            },
            
            -- Power Generator
            {
                type ="combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = 79624, -- there are more spells named "power generator", so we need the id
                execute = {
                    {
                        "quash","generatorcd",
                        "alert","generatorcd",
                    },
                },
            },
            -- Overcharged Power Generator
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 91857,
                srcisnpctype = true,
                dstisnpctype = true,
                execute = {
                    {
                        "alert","overcharged",
                        "quash","nefcd",
                        "alert","nefcd",
                    },
                },
            },
            -- Lightning Conductor
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 91433,
                execute = {
                    {
                        "quash","conductorcd",
                        "alert","conductorcd",
                        "raidicon","conductormark",
                        "range",{true},
                        "radar","conductorradar",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{ conductortext = format("%s on <%s>",SN[91433],"#5#") },
                        "set",{ conductortarget = "others"},
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{ conductortarget = "self"},
                    },
                    {
                        "scheduletimer",{"shadowcheck",0.1},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 91433,
                execute = {
                    {
                        "range",{false},
                        "removeradar",{"conductorradar",player = "#5#"},
                    },
                },
            },
            
            -- Shadow Infusion
            {
                type ="combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 92048,
                execute = {
                    {
                        "set",{shadowconductorwarned = "yes"},
                        "quash","conductorwarn",
                        "removeraidicon","#5#",
                        "raidicon","infusionmark",
                        "quash","nefcd",
                        "alert","nefcd",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{ infusiontext = format("Shadow Conductor on <%s>","#5#") },
                        "alert","infusionwarn",
                        "set",{ infusiondurationtext = format("Shadow Conductor on <%s> incoming","#5#")},
                        "set",{ shadowconductortext = format("Shadow Conductor on <%s>","#5#")},
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","infusionselfwarn",
                        "announce","infusionsay",
                        "set",{ infusiondurationtext = format("Shadow Conductor on <%s> incoming",L.alert["YOU"])},
                        "set",{shadowconductortext = format("Shadow Conductor on <%s>",L.alert["YOU"])},
                    },
                    {
                        "alert","infusiondur",
                        "schedulealert",{"shadowconductordur",5},
                    },
                },
            },
            -- Posion Cloud
            {
                type ="combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 80157,
                execute = {
                    {
                        "quash","poisonbombcd",
                        "alert","poisonbombcd",
                    },
                },
            },
            -- Poison Adds
            {
                type ="combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 91515,
                execute = {
                    {
                        "alert","addswarn",
                        "alert","addscd",
                    },
                },
            },
            {
                type ="combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 80094,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","fixateself",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{fixatetext = format(L.alert["%s on <%s>"],SN[80094],"#5#")},
                        "alert","fixatewarn",
                    }
                },
            },
            -- Grip of Death
            {
                type ="combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91849,
                execute = {
                    {
                        "alert","gripwarn",
                        "quash","nefcd",
                        "alert","nefcd",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- CHIMAERON
---------------------------------

do
    local data = {
        version = 6,
        key = "chimaeron",
        zone = L.zone["Blackwing Descent"],
        category = L.zone["Blackwing Descent"],
        name = L.npc_descent["Chimaeron"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Chimaeron.blp",
        triggers = {
            scan = {
                43296, -- Chimaeron
            },
            -- yell = L.chat_descent["springs to life and begins"],
        },
        onpullevent = {
            {
                triggers = {
                    emote = L.chat_descent["springs to life and begins to emit a foul smelling substance"],
                },
                invoke = {
                    {
                       "alert","pullcd",
                    },
                },
            },
        },
        onactivate = {
            tracing = {43296},
            phasemarkers = {
                {
                    {0.2,"Mortality","At 20% health Chimaeron goes into a rage."},
                },
            },
            tracerstart = true,
            combatstop = true,
            --combatstart = true,
            defeat = 43296,
        },
        userdata = {
            -- Timers
            enragetimer = 450, -- 25h
            massacrecd = {26,30, loop = false, type = "series"},
            slimecd = {15,5,5,0, loop = true, type = "series"},
            breakcd = 12,
            breakcdonmassacre = 4,
            breakcdpull = 4,
            
            -- Durations
            feuddur = 26,
            
            -- Switches
            iconenabled = "yes",
        },
        onstart = {
            {
                "expect",{"&debuff|boss1|"..SN[55095].."&","==","true", -- Frost Fever (Death Knight)
                     "OR","&debuff|boss1|"..SN[58179].."&","==","true", -- Infected Wounds (Feral Druid)
                     "OR","&debuff|boss1|"..SN[54404].."&","==","true", -- Dust Cloud (Hunter's pet - Tallstrider)
                     "OR","&debuff|boss1|"..SN[90315].."&","==","true", -- Tailspin (Hunter's pet - Fox)
                     "OR","&debuff|boss1|"..SN[53696].."&","==","true", -- Judgements of the Just (Paladin)
                     "OR","&debuff|boss1|"..SN[51696].."&","==","true", -- Waylay (Rogue)
                     "OR","&debuff|boss1|"..SN[8042].."&","==","true",  -- Earth Shock (Shaman)
                     "OR","&debuff|boss1|"..SN[6343].."&","==","true"}, -- Thunder Clap (Protection Warrior)
                "set",{
                    breakcd = 14.4,
                    breakcdonmassacre = 9.6,
                    breakcdpull = 5,
                },
            },
            {
                "alert","massacrecd",
                "alert",{"breakcd",time = 3},
                "alert","slimecd",
                "quash","pullcd",
            },
            {
                "expect",{"&difficulty&",">=","3"}, --10h&25h
                "alert","enragecd",
                "set",{ feuddur = 5 },
            },
        },
        
        windows = {
            proxwindow = true,
            proxrange = 8,
            proxoverride = true,
        },
        raidicons = {
            slimemark = {
                varname = format("%s {%s}",SN[88917],"PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 5,
                reset = 5,
                unit = "#5#",
                icon = 2,
                total = 5,
                texture = ST[88917],
            },
        },
        filters = {
            bossemotes = {
                massacreemote = {
                    name = SN[82848],
                    pattern = "prepares to massacre his foes",
                    hasIcon = false,
                    hide = true,
                    texture = ST[82848],
                },
                feudstartemote = {
                    name = format("%s (start)",SN[88872]),
                    pattern = "has knocked the Bile%-O%-Tron",
                    hasIcon = false,
                    hide = true,
                    texture = ST[88872],
                },
                feudendemote = {
                    name = format("%s (end)",SN[88872]),
                    pattern = "Bile%-O%-Tron is back",
                    hasIcon = false,
                    hide = true,
                    texture = ST[88872],
                },
            },
        },
        ordering = {
            alerts = {"pullcd","enragecd","breakcd","breakwarn","doubleattackwarn","slimecd","massacrecd","massacrewarn","feudwarn","phasewarn"},
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = format(L.alert["%s CD"],SN[26662]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[26662]),
                time = "<enragetimer>",
                color1 = "RED",
                flashtime = 10,
                icon = ST[26662],
            },
            -- Phase
            phasewarn = {
                varname = format(L.alert["Phase 2 Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"2"),
                time = 3,
                flashtime = 3,
                color1 = "TURQUOISE",
                icon = ST[11242],
                sound = "BEWARE",
                throttle = 60,
            },
            -- Chimaeron awakes
            pullcd = {
                varname = format(L.alert["%s"],"Pull Countdown"),
                type = "dropdown",
                text = format(L.alert["%s"],"Chimaeron awakes"),
                time = 31,
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[96573],
            },
            -- Break
            breakcd = {
                varname = format(L.alert["%s CD"],SN[82881]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[82881]),
                time = "<breakcdonmassacre>",
                time2 = "<breakcd>",
                time3 = "<breakcdpull>",
                color1 = "RED",
                flashtime = 5,
                icon = ST[82881],
                audiocd = true,
                sticky = true,
            },
            breakwarn = {
                varname = format(L.alert["%s Warning"],SN[82881]),
                type = "simple",
                text = format(L.alert["%s!"],SN[82881]),
                time = 5,
                stacks = 4,
                color1 = "RED",
                sound = "ALERT4",
                icon = ST[82881],
                throttle = 11,
            },
            -- Caustic Slime
            slimecd = {
                varname = format(L.alert["%s CD"],SN[88917]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[88917]),
                time = "<slimecd>",
                color1 = "LIGHTGREEN",
                flashtime = 10,
                icon = ST[88917],
                throttle = 2,
            },
            -- Double Attack
            doubleattackwarn = {
                varname = format(L.alert["%s Warning"],SN[88826]),
                type = "simple",
                text = format(L.alert["%s"],SN[88826]),
                time = 5,
                color1 = "YELLOW",
                flashtime = 5,
                icon = ST[88826],
                sound = "ALERT1",
            },
            -- Massacre
            massacrecd = {
                varname = format(L.alert["%s CD"],SN[82848]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[82848]),
                time = "<massacrecd>",
                color1 = "GREEN",
                flashtime = 7,
                icon = ST[82848],
            },
            massacrewarn = {
                varname = format(L.alert["%s Warning"],SN[82848]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[82848]),
                time = 4,
                color1 = "LIGHTGREEN",
                flashtime = 5,
                icon = ST[82848],
                sound = "ALERT10",
            },
            -- Feud
            feudwarn = {
                varname = format(L.alert["%s Warning"],SN[88872]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[88872]),
                time = "<feuddur>",
                color1 = "GOLD",
                flashtime = 5,
                icon = ST[88872],
                sound = "BEWARE",
            },
        },
        timers = {
            enableicon = {
                {
                    "set",{iconenabled,"yes"},
                },
            },
            massacretimer = {
                {
                    "alert","slimecd",
                },
            },
        },
        events = {
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = {
                    55095, -- Frost Fever (Death Knight)
                    58179, -- Infected Wounds (Feral Druid)
                    54404, -- Dust Cloud (Hunter's pet - Tallstrider)
                    90315, -- Tailspin (Hunter's pet - Fox)
                    53696, -- Judgements of the Just (Paladin)
                    51696, -- Waylay (Rogue)
                    8042, -- Earth Shock (Shaman)
                    6343, -- Thunder Clap (Protection Warrior)
                },
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","43296"},
                        "set",{
                            breakcd = 14.4,
                            breakcdonmassacre = 9.6,
                            breakcdpull = 5,
                        },
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = {
                    55095, -- Frost Fever (Death Knight)
                    58179, -- Infected Wounds (Feral Druid)
                    54404, -- Dust Cloud (Hunter's pet - Tallstrider)
                    90315, -- Tailspin (Hunter's pet - Fox)
                    53696, -- Judgements of the Just (Paladin)
                    51696, -- Waylay (Rogue)
                    8042, -- Earth Shock (Shaman)
                    6343, -- Thunder Clap (Protection Warrior)
                },
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","43296"},
                        "set",{
                            breakcd = 12,
                            breakcdonmassacre = 4,
                            breakcdpull = 4,
                        },
                    },
                },
            },
            -- Break
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = 82881,
                execute = {
                    {
                        "quash","breakcd",
                        "alert",{"breakcd",time = 2},
                        "expect",{"#11#","<=","&stacks|breakwarn&"},
                        "alert","breakwarn",
                    },        
                },
            },
            -- Caustic Slime
            {
                 type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 88917,
                execute = {
                    {
                        "invoke",{
                            {
                                "expect",{"&timeleft|slimecd&","<","1"},
                                "quash","slimecd",
                            },
                        },
                        "alert","slimecd",
                        "raidicon","slimemark",
                    },
                },
            },
            {
                 type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 88917,
                execute = {
                    {
                        "removeraidicon","#5#",
                    },
                },
            },
            -- Double Attack
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 88826,
                execute = {
                    {
                        "alert","doubleattackwarn",
                    },
                },
            },
            -- Massacre
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 82848,
                execute = {
                    {
                        "quash","slimecd",
                        "quash","massacrecd",
                        "quash","breakcd",
                        "alert","massacrewarn",
                        "alert","massacrecd",
                        "scheduletimer",{"massacretimer",4},
                        "schedulealert",{"breakcd", 4},
                    },
                },
            },
            -- Feud
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 88872,
                execute = {
                    {
                        "alert","feudwarn",
                        "expect",{"&difficulty&","<","3"},
                        "quash","breakcd",
                    },
                },
            },
            -- Mortality
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 82890,
                execute = {
                    {
                        "alert","phasewarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ATRAMEDES
---------------------------------

do
    local data = {
        version = 9,
        key = "atramedes",
        zone = L.zone["Blackwing Descent"],
        category = L.zone["Blackwing Descent"],
        name = L.npc_descent["Atramedes"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Atramedes.blp",
        triggers = {
            scan = {
                41442, -- Atramedes
            },
        },
        onactivate = {
            tracing = {41442},
            counters = {"gongcounter"},
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 41442,
        },
        userdata = {
            -- Texts
            trackingtext = "",
            gongtext = format(L.alert["Gong activated! (%s gongs remaining)"],"<gongcount>"),
            
            -- Timers
            grounddur = {90,85, loop = false, type = "series"},
            groundtimerdur = {90, 85, loop = false, type = "series"},
            flamescd = 45,
            
            -- Switches
            fiendwarned = "no",
            phase = "ground",
            
            -- Counters
            gongcount = 10,
            
            -- Lists
            deadgongs = {type = "container"},
        },
        onstart = {
            {
                "set",{
                    gongcount = 10,
                },
                "alert","grounddur",
                "alert","flamescd",
                "alert",{"sonarcd",time = 2},
                "alert",{"modulcd",time = 2},
                "alert",{"breathcd",time = 2},
                "scheduletimer",{"airphasetimer", "<groundtimerdur>"},
            },
            {
                "expect",{"&difficulty&",">=","3"}, --10h&25h
                "alert","enragecd",
            },
        },
        
        arrows = {
            fiendarrow = {
                varname = L.npc_descent["Obnoxious Fiend"],
                unit = "#2#",
                persist = 20,
                action = "TOWARDS",
                msg = L.alert["KILL IT!"],
                spell = L.npc_descent["Obnoxious Fiend"],
                texture = ST[92702],
            },
        },
        announces = {
            trackingsay = {
                type = "SAY",
                subtype = "self",
                spell = 78092,
                msg = format(L.alert["%s on ME"],SN[78092]).."!",
            },
            fiendsay = {
                type = "SAY",
                subtype = "self",
                spell = 92702,
                msg = format(L.alert["%s on ME!"],L.npc_descent["Obnoxious Fiend"]),
            },
        },
        raidicons = {
            trackingmark = {
                varname = format("%s {%s}",SN[78092],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 8,
                unit = "#5#",
                icon = 1,
                texture = ST[78092],
            },
            fiendmark = {
                varname = format("%s {%s}",L.npc_descent["Obnoxious Fiend"],"NPC_ENEMY"),
                type = "ENEMY",
                persist = 30,
                unit = "#1#",
                icon = 2,
                texture = ST[92702],
            },
        },
        filters = {
            bossemotes = {
                searingemote = {
                    name = "Searing Flame",
                    pattern = "Atramedes rears back and casts %[Searing Flame%]",
                    hasIcon = true,
                    texture = ST[77840],
                    hide = true,
                },
            },
        },
        counters = {
            gongcounter = {
                variable = "gongcount",
                label = "Gongs left",
                value = 10,
                minimum = 0,
                maximum = 10,
            },
        },
        windows = {
            apbtext = "Sound",
            apbwindow = true,
        },
        ordering = {
            alerts = {"enragecd","enragewarn","grounddur","sonarcd","modulcd","breathcd","trackingwarn","trackingselfwarn","trackingduration","flamescd","flameswarn",
                      "gongwarn","gongduration","fiendwarn","airdur",},
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = format(L.alert["%s CD"],SN[26662]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[26662]),
                time = 600,
                flashtime = 30,
                color1 = "RED",
                icon = ST[26662],
            },
            enragewarn = {
                varname = format(L.alert["%s Warning"],SN[26662]),
                type = "simple",
                text = format(L.alert["%s"],SN[26662]),
                time = 1,
                color1 = "RED",
                sound = "BEWARE",
                icon = ST[26662],
            },
            -- Gong Activation
            gongwarn = {
                varname = format(L.alert["%s Warning"], "Gong Activation"),
                type = "simple",
                text = "<gongtext>",
                time = 5,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                texture = "Interface\\ICONS\\INV_Misc_Bell_01",
            },
            -- Vertigo
            gongduration = {
                varname = format(L.alert["%s Duration"],"Gong Stun"),
                type = "centerpopup",
                text = format(L.alert["Atramedes: %s"],SN[92391]),
                time = 5,
                color1 = "YELLOW",
                icon = ST[92391],
                sound = "None",
                throttle = 1,
            },
            ------------------
            -- Ground Phase --
            ------------------
            -- Ground Phase Duration
            grounddur = {
                varname = format(L.alert["Ground Phase Duration"]),
                type = "dropdown",
                text = format(L.alert["Ground Phase ends"]),
                time = "<grounddur>",
                flashtime = 5,
                color1 = "ORANGE",
                sound = "ALERT4",
                icon = ST[63532],
            },
            -- Sonar Pulse
            sonarcd = {
                varname = format(L.alert["%s CD"],SN[77672]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[77672]),
                time = 10,--15,
                time2 = 11,
                flashtime = 5,
                color1 = "YELLOW",
                icon = ST[77672],
                sound = "MINORWARNING",
                sticky = true,
            },
            -- Modulation
            modulcd = {
                varname = format(L.alert["%s CD"],SN[92452]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[92452]),
                time = 20,
                time2 = 15,
                flashtime = 5,
                color1 = "YELLOW",
                icon = ST[92452],
                sound = "MINORWARNING",
                sticky = true,
            },
            -- Sonic Breath
            breathcd = {
                varname = format(L.alert["%s CD"],SN[92408]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92408]),
                time = {41, 0, loop = true, type = "series"},
                time2 = 23,
                flashtime = 5,
                color1 = "ORANGE",
                icon = ST[92408],
                sound = "MINORWARNING",
            },
            -- Tracking
            trackingwarn = {
                varname = format(L.alert["%s Warning"],SN[78092]),
                type = "simple",
                text = "<trackingtext>",
                time = 8,
                color1 = "YELLOW",
                icon = ST[78092],
                sound = "ALERT2",
            },
            trackingselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[78092]),
                type = "simple",
                text = "<trackingtext>",
                time = 8,
                color1 = "YELLOW",
                icon = ST[78092],
                sound = "ALERT12",
                flashscreen = true,
            },
            trackingduration = {
                varname = format(L.alert["%s Duration"],SN[78092]),
                type = "centerpopup",
                text = "<trackingtext>",
                time = 8,
                color1 = "YELLOW",
                sound = "None",
                icon = ST[78092],
            },
            -- Searing Flames
            flamescd = {
                varname = format(L.alert["%s CD"],SN[77840]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[77840]),
                time = "<flamescd>",
                flashtime = 5,
                color1 = "ORANGE",
                icon = ST[77840],
            },
            flameswarn = {
                varname = format(L.alert["%s Warning"],SN[77840]),
                type = "simple",
                text = format(L.alert["%s!"],SN[77840]),
                time = 3,
                flashtime = 3,
                color1 = "ORANGE",
                icon = ST[77840],
                sound = "BEWARE",
            },
            ---------------
            -- Air Phase --
            ---------------
            -- Air Phase Duration
            airdur = {
                varname = format(L.alert["Air Phase Duration"]),
                type = "dropdown",
                text = format(L.alert["Air Phase ends"]),
                time = 31.5,
                flashtime = 10,
                color1 = "GOLD",
                sound = "ALERT4",
                icon = ST[57994],
                audiocd = true,
            },
            ------------
            -- Heroic --
            ------------
            -- Obnoxious Fiend
            fiendwarn = {
                varname = format(L.alert["%s Warning"],L.npc_descent["Obnoxious Fiend"]),
                type = "simple",
                text = format(L.alert["%s"],L.npc_descent["Obnoxious Fiend"]),
                time = 5,
                flashtime = 5,
                color1 = "LIGHTGREEN",
                icon = ST[92702],
                sound = "ALERT4",
            },
        },
        timers = {
            fiend = {
                {
                    "expect",{"&playerdebuff|"..SN[92685].."&","==","true"},
                    "expect",{"<fiendwarned>","==","no"},
                    "anounce","fiendsay",
                    "set",{fiendwarned = "yes"},
                },
            },
            groundphasetimer = {
                {
                    "set",{phase = "ground"},
                    "alert","grounddur",
                    "alert","flamescd",
                    "alert",{"modulcd",time = 2},
                    "alert",{"sonarcd",time = 2},
                    "alert",{"breathcd",time = 2},
                    "scheduletimer",{"airphasetimer", "<groundtimerdur>"},
               },
            },
            airphasetimer = {
                {
                    "quash","modulcd",
                    "quash","breathcd",
                    "quash","sonarcd",
                },
            },
        },
        events = {
            -- Berserk
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 26662,
                execute = {
                    {
                        "alert","enragecd",
                    },
                },
            },
            -- Sonar Pulse
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = {77672,92411,92412,92413},
                execute = {
                    {
                        "quash","sonarcd",
                        "alert","sonarcd",
                    },
                },   
            },
            -- Modulation
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = {77612,92452,92451,92453},
                execute = {
                    {
                        "quash","modulcd",
                        "alert","modulcd",
                    },
                },
            },
            -- Tracking
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 78092,
                execute = {
                    {
                        "raidicon","trackingmark",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{trackingtext = format(L.alert["%s on <%s>"],SN[78092],"#5#")},
                        "alert","trackingwarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{trackingtext = format(L.alert["%s on <%s>"],SN[78092],L.alert["YOU"])},
                        "announce","trackingsay",
                        "alert","trackingselfwarn",
                    },
                    {
                        "expect",{"<phase>","==","ground"},
                        "alert","trackingduration",
                    },
                },
            },
            -- Sonic Breath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92404,
                execute = {
                    {
                        "quash","breathcd",
                        "alert","breathcd",          
                    },
                },
            },
            -- Tracking removed
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 78092,
                execute = {
                    {
                        "quash","trackingwarn",
                        "quash","trackingselfwarn",
                        "quash","trackingduration",
                        "removeraidicon","#5#",
                    },
                },
            },
            -- Searing Flames
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 77840,
                execute = {
                    {
                        "alert","flameswarn",
                    },
                },
            },
            -- Gong Activation
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 77611,
                execute = {
                    {
                        "set",{clickedgong = "&npcid|#1#&"},
                        "expect",{"<clickedgong>","==","41445",
                             "OR","<clickedgong>","==","42947",
                             "OR","<clickedgong>","==","42949",
                             "OR","<clickedgong>","==","42951",
                             "OR","<clickedgong>","==","42954",
                             "OR","<clickedgong>","==","42956",
                             "OR","<clickedgong>","==","42958",
                             "OR","<clickedgong>","==","42960"},
                        "expect",{"&listcontains|deadgongs|#1#&","==","false"},
                        "insert",{"deadgongs","#1#"},
                        "set",{gongcount = "DECR|1"},
                        "invoke",{
                            {
                                "expect",{"<gongcount>","==","0"},
                                "set",{gongtext = format(L.alert["Gong activated! (No gong remaining)"])},
                            },
                            {
                                "expect",{"<gongcount>","==","1"},
                                "set",{gongtext = format(L.alert["Gong activated! (%s gong remaining)"],"<gongcount>")}, 
                            },
                            {
                                "expect",{"<gongcount>",">","1"},
                                "set",{gongtext = format(L.alert["Gong activated! (%s gongs remaining)"],"<gongcount>")}, 
                            },
                        },
                        "alert","gongwarn",
                        "alert","gongduration",
                    },
                },
            },
            -- Air Phase
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_descent["^Yes, run!"]},
                        "set",{phase = "air"},
                        "alert","airdur",
                        "scheduletimer",{"groundphasetimer", 31.5},
                    },
                },
            },
            -- Obnoxious Fiend
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 92681,
                execute = {
                    {
                        "alert","fiendwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92702,
                execute = {
                    {
                        "arrow","fiendarrow",
                        "raidicon","fiendmark",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_AURA",
                execute = {
                    {
                        "expect",{"&difficulty&",">=","3"},
                        "expect",{"#1#","==","player"},
                        "scheduletimer",{"fiend",0.1},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","49740"},
                        "removearrow","#5#",
                        "set",{fiendwarned = "no"},
                    },
                    {
                        "set",{clickedgong = "&npcid|#4#&"},
                        "expect",{"<clickedgong>","==","41445",
                             "OR","<clickedgong>","==","42947",
                             "OR","<clickedgong>","==","42949",
                             "OR","<clickedgong>","==","42951",
                             "OR","<clickedgong>","==","42954",
                             "OR","<clickedgong>","==","42956",
                             "OR","<clickedgong>","==","42958",
                             "OR","<clickedgong>","==","42960"},
                        "expect",{"&listcontains|deadgongs|#4#&","==","false"},
                        "insert",{"deadgongs","#4#"},
                        "set",{gongcount = "DECR|1"},
                        "invoke",{
                            {
                                "expect",{"<gongcount>","==","0"},
                                "set",{gongtext = format(L.alert["Gong destroyed! (No gong remaining)"])},
                            },
                            {
                                "expect",{"<gongcount>","==","1"},
                                "set",{gongtext = format(L.alert["Gong destroyed! (%s gong remaining)"],"<gongcount>")}, 
                            },
                            {
                                "expect",{"<gongcount>",">","1"},
                                "set",{gongtext = format(L.alert["Gong destroyed! (%s gongs remaining)"],"<gongcount>")}, 
                            },
                        },
                        "alert","gongwarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- MALORIAK
---------------------------------
do
    local data = {
        version = 14,
        key = "maloriak",
        zone = L.zone["Blackwing Descent"],
        category = L.zone["Blackwing Descent"],
        name = L.npc_descent["Maloriak"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Maloriak.blp",
        triggers = {
            scan = {
                41378, -- Maloriak
            },
        },
        onactivate = {
            tracing = {41378},
            counters = {"adscounter"},
            phasemarkers = {
                {
                    {0.25,"Phase 2","When Maloriak reaches 25 % of his HP, the Phase 2 begins."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 41378,
        },
        userdata = {
            phase = "none",
            
            -- Texts
            adstext = "",
            
            -- Timers
            flashfreezecd = {16,16,0, loop = true, type = "series"},
            flamescd = {17,15,14,0, loop = true, type = "series"},
            jetscd = 11,
            
            -- Counters
            adscount = 18,
        },
        onstart = {
            {
                "expect",{"&difficulty&",">=","3"}, --10h&25h
                "set",{jetscd = {6.5, 4, loop = false, type = "series"}},
                "set",{
                    firstphasetext = "Black Phase incoming",
                    firstphaseicon = ST[603],
                },
            },
            {
                "expect",{"&difficulty&","<","3"}, --10n&25n
                "set",{
                    firstphasetext = "Red / Blue Phase incoming",
                    firstphaseicon = ST[75000],
                },
            },
            {
                "alert","enragecd",
                "alert","firstphase",
                "alert","relabercd",
                "alert","stormcd",
            },  
        },
        
        announces = {
            flamessay = {
                type = "SAY",
                subtype = "self",
                spell = 92971,
                msg = format(L.alert["%s on ME!"],SN[92971]),
            },
        },
        raidicons = {
            flamesmark = {
                varname = format("%s {%s}",SN[92971],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                persist = 10,
                unit = "#5#",
                icon = 1,
                texture = ST[92971],
            },
            freezemark = {
                varname = format("%s {%s}",SN[92978],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                persist = 10,
                unit = "#5#",
                icon = 2,
                texture = ST[92978],
            },
        },
        counters = {
            adscounter = {
                variable = "adscount",
                label = "Aberrations to release",
                value = 18,
                minimum = 0,
                maximum = 18,
            },
            
        },
        filters = {
            bossemotes = {
                blackphaseemote = {
                    name = "Black Phase",
                    pattern = "throws dark magic into the cauldron",
                    hasIcon = true,
                    hide = true,
                    texture = ST[603],
                },
                redphaseemote = {
                    name = "Red Phase",
                    pattern = "throws a red vial into",
                    hasIcon = true,
                    hide = true,
                    texture = "Interface\\Icons\\INV_POTION_24",
                },
                bluephaseemote = {
                    name = "Blue Phase",
                    pattern = "throws a blue vial into",
                    hasIcon = true,
                    hide = true,
                    texture = "Interface\\Icons\\INV_POTION_20",
                },
                greenphaseemote = {
                    name = "Green Phase",
                    pattern = "throws a green vial into",
                    hasIcon = true,
                    hide = true,
                    texture = "Interface\\Icons\\INV_POTION_162",
                },
            },
        },
        windows = {
			proxwindow = true,
			proxrange = 5,
			proxoverride = true,
            proxnoautostart = true,
		},
        phrasecolors = {
            {"Red","RED"},
            {"Blue","LIGHTBLUE"},
            {"Green","LIGHTGREEN"},
            {"aberrations","GOLD"},
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd","firstphase","remedywarn","relabercd","relaberwarn","stormcd"},
            },
            {
                name = format("|cffff0000%s|r |cffffffffPhase|r","Red"),
                icon = "Interface\\ICONS\\INV_Potion_55",
                alerts = {"redphasewarn","redphasedur","flamescd","flameswarn","flamesselfwarn","breathcd"},
            },
            {
                name = format("|cff28dfff%s|r |cffffffffPhase|r","Blue"),
                icon = "Interface\\ICONS\\INV_Potion_76",
                alerts = {"bluephasewarn","bluephasedur","chillwarn","chillself","flashfreezecd","flashfreezewarn"},
            },
            {
                name = format("|cff00ff00%s|r |cffffffffPhase|r","Green"),
                icon = "Interface\\ICONS\\INV_Potion_97",
                alerts = {"greenphasewarn","greenphasedur","slimedur"},
            },
            {
                name = format("|cffaaaaaa%s|r |cffffffffPhase|r","Black"),
                icon = "Interface\\ICONS\\INV_Potion_90",
                alerts = {"firstphase","blackphasewarn","blackphasedur","sludgeselfwarn","darknesswarn"},
            },
            {
                phase = 2,
                alerts = {"phasewarn","acidnovacd","acidnovawarn","jetscd"},
            },
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = format(L.alert["%s CD"],SN[26662]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[26662]),
                time10n = 480,
                time25n = 480,
                time10h = 720,
                time25h = 720,
                color1 = "RED",
                flashtime = 15,
                icon = ST[26662],
            },
            -- First Phase Countdown
            firstphase = {
                varname = format(L.alert["%s"],L.alert["First Phase Countdown"]),
                type = "dropdown",
                text = "<firstphasetext>",
                time = 15,
                flashtime = 5,
                color1 = "MIDGREY",
                sound = "ALERT2",
                icon = "<firstphaseicon>",
                texture = ST[603],
            },
            -- Phase Warning
            phasewarn = {
                varname = format(L.alert["Phase 2 Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"2"),
                time = 3,
                flashtime = 3,
                color1 = "TURQUOISE",
                icon = ST[11242],
                sound = "ALERT1",
            },
            -- Remedy
            remedywarn = {
                varname = format(L.alert["%s Warning"],SN[77912]),
                type = "simple",
                text = format(L.alert["%s - DISPEL!"],SN[77912]),
                time = 5,
                color1 = "LIGHTGREEN",
                sound = "ALERT8",
                icon = ST[77912],
            },
            -- Release Aberrations
            relabercd = {
                varname = format(L.alert["%s CD"],SN[77569]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[77569]),
                time = 10,
                time2 = 16,
                color1 = "PURPLE",
                sound = "None",
                icon = ST[77569],
                sticky = true,
            },
            relaberwarn = {
                varname = format(L.alert["%s Warning"],SN[77569]),
                type = "simple",
                text = "<adstext>",
                time = 5,
                color1 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[77569],
            },
            -- Arcane Storm
            stormcd = { 
                varname = format(L.alert["%s CD"],SN[77896]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[77896]),
                time = 10,
                time2 = 16,
                color1 = "LIGHTBLUE",
                sound = "None",
                icon = ST[77896],  
                sticky = true,
            },
            --------------------------
            -- BLACK PHASE (HEROIC) --
            --------------------------
            -- Black Phase
            blackphasewarn = {
                varname = format(L.alert["%s Warning"],"Black Phase"),
                type = "simple",
                text = format(L.alert["%s"],"Black Phase"),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT1",
                icon = ST[603],
            },
            -- Black Phase (duration)
            blackphasedur = {
                varname = format(L.alert["Black Phase Duration"]),
                type = "dropdown",
                text = format(L.alert["Black Phase"]),
                time = 92,
                color1 = "BLACK",
                flashtime = 10,
                sound = "ALERT2",
                icon = "Interface\\ICONS\\INV_Potion_90",
            },
            -- Dark Sludge
            sludgeselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[92930]),
                type = "simple",
                text = format("%s on %s - %s!",SN[92930],L.alert["YOU"],L.alert["MOVE AWAY"]),
                time = 3,
                throttle = 1,
                flashscreen = true,
                color1 = "RED",
                sound = "ALERT10",
                icon = ST[92930],
                emphasizewarning = true,
            },
            -- Engulfing Darkness
            darknesswarn = {
                varname = format(L.alert["%s Warning"],SN[92754]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[92754]),
                time = 8,
                flashtime = 8,
                color1 = "PINK",
                icon = ST[92754],
                sound = "ALERT9",
                audiocd = true,
            },
            ----------------
            -- BLUE PHASE --
            ----------------
            -- Blue Phase
            bluephasewarn = {
                varname = format(L.alert["%s Warning"],"Blue Phase"),
                type = "simple",
                text = format(L.alert["%s"],"Blue Phase"),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT1",
                icon = ST[11151],
            },
            -- Blue Phase (duration)
            bluephasedur = {
                varname = format(L.alert["%s Duration"], "Blue Phase"),
                type = "dropdown",
                text = format(L.alert["Blue Phase"]),
                time = 50,
                color1 = "LIGHTBLUE",
                flashtime = 5,
                icon = "Interface\\ICONS\\INV_Potion_76",
                sound = "ALERT1",
            },
            -- Flash Freeze
            flashfreezewarn = {
                varname = format(L.alert["%s Warning"],SN[77699]),
                type = "simple",
                text = format(L.alert["%s"],SN[77699]),
                time = 10,
                color1 = "CYAN",
                icon = ST[77699],
                sound = "ALERT10",
            },
            flashfreezecd = {
                varname = format(L.alert["%s CD"],SN[77699]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[77699]),
                time = "<flashfreezecd>",
                color1 = "CYAN",
                color2 = "INDIGO",
                flashtime = 5,
                icon = ST[77699],
                sound = "ALERT4",
            },
            -- Biting Chill
            chillwarn = {
                varname = format(L.alert["%s Warning"],SN[77760]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[77760]),
                time = 10,
                flashtime = 5,
                color1 = "CYAN",
                icon = ST[77760],
                sound = "ALERT3",
                throttle = 2,
            },
            chillself = {
                varname = format(L.alert["%s on me Warning"],SN[77760]),
                type = "centerpopup",
                text = format(L.alert["%s on %s"],SN[77760],L.alert["YOU"]),
                time = 10,
                flashtime = 10,
                color1 = "CYAN",
                icon = ST[77760],
                sound = "ALERT4",
                flashscreen = true,
            },
            ---------------
            -- RED PHASE --
            ---------------
            -- Red Phase
            redphasewarn = {
                varname = format(L.alert["%s Warning"],"Red Phase"),
                type = "simple",
                text = format(L.alert["%s"],"Red Phase"),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT1",
                icon = ST[83619]
            },
            -- Red Phase (duration)
            redphasedur = {
                varname = format(L.alert["%s Duration"],"Red Phase"),
                type = "dropdown",
                text = format(L.alert["Red Phase"]),
                time = 50,
                color1 = "RED",
                flashtime = 5,
                sound = "ALERT2",
                icon = "Interface\\ICONS\\INV_Potion_55",
            },
            -- Scorching Blast
            breathcd = {
                varname = format(L.alert["%s CD"],SN[92968]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92968]),
                time = "<breathcd>",
                color1 = "ORANGE",
                flashtime = 5,
                audiocd = true,
                icon = ST[92968],
                sound = "MINORWARNING",
                sticky = true,
            },
            -- Consuming Flames
            flamescd = {
                varname = format(L.alert["%s CD"],SN[92971]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92971]),
                time = "<flamescd>",
                color1 = "ORANGE",
                flashtime = 5,
                icon = ST[92971],
                sound = "MINORWARNING",
            },
            flameswarn = {
                varname = format(L.alert["%s Warning"],SN[92971]),
                type = "simple",
                text = format(L.alert["%s on <#5#>"],SN[92971]),
                time = 10,
                flashtime = 10,
                color1 = "GOLD",
                icon = ST[92971],
                sound = "ALERT11",
            },
            flamesselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[92971]),
                type = "centerpopup",
                text = format(L.alert["%s on %s"],SN[92971],L.alert["YOU"]),
                time = 5,
                color1 = "RED",
                icon = ST[92971],
                sound = "ALERT12",
                flashscreen = true,
                emphasizewarning = true,
            },
            -----------------
            -- GREEN PHASE --
            -----------------
            greenphasewarn = {
                varname = format(L.alert["%s Warning"],"Green Phase"),
                type = "simple",
                text = format(L.alert["Green Phase - Kill Aberrations!"]),
                time = 11,
                flashtime = 5,
                color1 = "WHITE",
                icon = ST[77912],
                sound = "None",
            },
            -- Green Phase (duration)
            greenphasedur = {
                varname = format(L.alert["%s Duration"],"Green Phase"),
                type = "dropdown",
                text = format(L.alert["Green Phase"]),
                time = 50,
                color1 = "LIGHTGREEN",
                flashtime = 5,
                audiocd = true,
                sound = "ALERT2",
                icon = "Interface\\ICONS\\INV_Potion_97",
            },
            -- Debilitating Slime
            slimedur = {
                varname = format(L.alert["%s Duration"],SN[77615]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[77615]),
                time = 15,
                flashtime = 5,
                audiocd = true,
                color1 = "LIGHTGREEN",
                icon = ST[77615],
                sound = "BURST",
            },
            -------------
            -- PHASE 2 --
            -------------
            -- Acid Nova
            acidnovawarn = {
                varname = format(L.alert["%s Warning"],SN[78225]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[78225]),
                time = 10,
                color1 = "LIGHTGREEN",
                icon = ST[78225],
                sound = "ALERT10",  
                throttle = 10,   
            },
            acidnovacd = {
                varname = format(L.alert["%s CD"],SN[78225]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[78225]),
                time = 30,
                time2 = 12,
                color1 = "LIGHTGREEN",
                flashtime = 5,
                icon = ST[78225],
                sound = "ALERT4",
            },
            -- Magma Jets
            jetscd = {
                varname = format(L.alert["%s CD"],SN[78194]),
                type = "centerpopup",
                text = format(L.alert["%s CD"],SN[78194]),
                time = "<jetscd>",
                time2 = 6.5,
                flashtime = 5,
                color1 = "RED",
                sound = "ALERT7",
                icon = ST[78194],
                sticky = true,
            },
        },
        timers = {
            adstimer = {
                {
                    "set",{adscount = "DECR|3"},
                    "expect",{"<adscount>","==","0"},
                    "set",{adstext = "No Aberrations left!"},
                    "quash","relabercd",
                },
                {
                    "expect",{"<adscount>","~=","0"},
                    "set",{adstext = format("New: Aberrations (%s remaining)", "<adscount>")}, 
                },
                {
                    "alert","relaberwarn",        
                },
            },
        },
        batches = {
            lastphasetimer = {
                {
                    "quashall",{"enragecd","slimedur"},
                    "alert","phasewarn",
                    "alert",{"jetscd",time = 2},
                    "alert",{"acidnovacd",time = 2},
                },
            },
        },
        events = {
            -- Phases
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    -- Red Phase
                    {
                        "expect",{"#1#","find",L.chat_descent["red|r vial"]},
                        "set",{phase = "red"},
                        "alert","redphasewarn",
                        "alert","redphasedur",
                        "range",{false},
                        
                        "set",{breathcd = {20,16.75,0, loop = true, type = "series"}},
                        "alert","breathcd",
                        "alert","flamescd",
                        
                        "quash","stormcd",
                        "alert",{"stormcd",time = 2},
                        
                        "quash","relabercd",
                        "expect",{"<adscount>",">","0"},
                        "alert",{"relabercd",time = 2},
                    },
                    -- Blue Phase
                    {
                        "expect",{"#1#","find",L.chat_descent["blue|r vial"]},
                        "set",{phase = "blue"},
                        "alert","bluephasewarn",
                        "alert","bluephasedur",
                        "range",{true},
                        
                        "alert","flashfreezecd",
                        
                        "quash","stormcd",
                        "alert",{"stormcd",time = 2},
                        
                        "quash","relabercd",
                        "expect",{"<adscount>",">","0"},
                        "alert",{"relabercd",time = 2},
                    },
                    -- Green Phase
                    {
                        "expect",{"#1#","find",L.chat_descent["green|r vial"]},
                        "expect",{"<phase>","~=","green"},
                        "set",{phase = "green"},
                        "alert","greenphasewarn",
                        "alert","greenphasedur",
                        "range",{false},
                        
                        "alert","slimedur",
                    },
                },
            },
            
            {
                type = "event",
                event = "YELL",
                execute = {
                -- Nefarian Phase
                    {
                        "expect",{"#1#","find",L.chat_descent["Your mixtures"]},
                        "set",{phase = "black"},
                        "quash","stormcd",
                        "alert","blackphasewarn",
                        "alert","blackphasedur",
                    },
                    -- Last Phase
                    {
                        "expect",{"#1#","find",L.chat_descent["^Too early"],
                             "OR","#1#","find",L.chat_descent["^Meet the brawn"],
                             "OR","#1#","find",L.chat_descent["^When pushed to the edge"]},
                        "run","lastphasetimer",
                    },
                },
            },
            -- Magma Jets
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 78194,
                execute = {
                    {
                        "quash","jetscd",
                        "alert","jetscd",
                    },
                },
            },
            -- Consuming Flames
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 92971,
                execute = {
                    {
                        "raidicon","flamesmark",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "alert","flameswarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "announce","flamessay",
                        "alert","flamesselfwarn",
                    },
                },
            },
            -- Scorching Blast
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 92970,
                execute = {
                    {
                        "quash","breathcd",
                        "alert",{"breathcd",time = 2},
                    },
                },
            },
            -- Consuming Flames
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 77786,
                execute = {
                    {
                        "quash","flamescd",
                        "alert","flamescd",
                    },
                },
            },
            -- Flash Freeze
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = {
                    77699,
                    92978,
                    92979,
                    92980,          
                },
                execute = {
                    {
                        "raidicon","freezemark",
                        "alert","flashfreezewarn",
                        "quash","flashfreezecd",
                        "alert","flashfreezecd",
                    },
                },
            },
            -- Flash Freeze removed
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 92978,
                execute = {
                    {
                        "removeraidicon","#5#",
                    },
                },
            },
            -- Biting Chill
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 77760,
                execute = {
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "alert","chillwarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","chillself",
                    },
                },
            },
            -- Biting Chill removed
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 77760,
                execute = {
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "quash","chillwarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "quash","chillself",
                    },
                },
            },
            -- Debilitating Slime
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 77615,
                dstnpcid = 41378, --Maloriak
                execute = {
                    {
                        "alert","greenphasewarn",
                    },
                },
            },
            -- Remedy
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 77912,
                dstnpcid = 41378,
                execute = {
                    {
                        "alert", "remedywarn",
                    },
                },
            },
      
            -- Dark Sludge
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = {
                    92930,
                    92986,
                    92987,
                    92988,
                },
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},  
                        "alert", "sludgeselfwarn",
                    },
                },
            },
      
            -- Acid Nova
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = {
                    78225,
                    93011,
                    93012,
                    93013,          
                },
                execute = {
                    {
                        "alert","acidnovawarn",
                        "quash","acidnovacd",
                        "alert","acidnovacd",
                    },
                },
            },
      
            -- Release Abberations
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = 77569,
                execute = {
                    {
                        "quash","relabercd",
                        "expect",{"&timeleft|firstphase&",">","10",
                            "OR","&timeleft|redphasedur&",">","10",
                            "OR","&timeleft|bluephasedur&",">","10",
                            "OR","&timeleft|greenphasedur&",">","10"},
                        "expect",{"<adscount>",">","0"},
                        "alert","relabercd",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[77569]},
                        "canceltimer","adstimer",
                        "scheduletimer",{"adstimer",0.2},
                    },
                },
            },
            
            -- Arcane Storm
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = 77896,
                execute = {
                    {
                        "quash","stormcd",
                        "expect",{"&timeleft|firstphase&",">","10",
                            "OR","&timeleft|redphasedur&",">","10",
                            "OR","&timeleft|bluephasedur&",">","10",
                            "OR","&timeleft|greenphasedur&",">","10"},
                        "alert","stormcd",
                    },
                },
            },
      
            -- Engulfing Darkness (10h/25h)
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92754,
                execute = {
                    {
                        "schedulealert",{"darknesswarn",3},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- NEFARIAN
---------------------------------
do
    local data = {
        version = 12,
        key = "nefarian",
        zone = L.zone["Blackwing Descent"],
        category = L.zone["Blackwing Descent"],
        name = L.npc_descent["Nefarian"],
        lfgname = "Nefarian's End",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-NefarianBWD.blp",
        icon2 = "Interface\\EncounterJournal\\UI-EJ-BOSS-OnyxiaBWD.blp",
        triggers = {
            scan = {
                41270, -- Onyxia
                41376, -- Nef
            },
            yell = L.chat_descent["^See how the shadowflame animates the bones"],
        },
        onactivate = {
            tracing = {41270,41376,altpowers={true}},
            tracerstart = true,
            counters = {"warriorcounter"},
            combatstop = true,
            combatstart = true,
            defeat = 41376,
        },
        advanced = {
            advancedwipedetection = true,
        },
        userdata = {
            -- Timers
            phase2timer = 180, -- 25n
            nefarianlanding = 31,
            blazecd = 30,
            
            -- Switches
            prototypestraced = "no",
            cindersticky = "true",
            
            -- Counters
            phase = "0",
            addsdead = 0,
            bonewarriors = 0,
            
            -- Lists
            cinderunits = {type = "container", wipein = 3},
            dominionunits = {type = "container", wipein = 3},
            prototypesunits = {type = "container", wipein = 10},
            
        },
        onstart = {
            {
                "alert","nefarianlands",
                "alert","enragecd",
                "expect",{"&difficulty&",">=","3"},
                "alert",{"dominioncd",time = 2},
            },
            {
                "expect",{"&difficulty&","==","1"}, -- 10n
                "set",{
                    blastnovacd = 11.5,
                    blastnovacd2 = 14,
                },
            },
            {
                "expect",{"&difficulty&","==","2"}, -- 25n
                "set",{
                    blastnovacd = 7,
                    blastnovacd2 = 14,
                },
            },
            {
                "expect",{"&difficulty&","==","3"}, -- 10h
                "set",{
                    cindermax = 1,
                    dominionmax = 2,
                    blastnovacd = 11.5,
                    blastnovacd2 = 13.5,
                },                
            },
            {
                "expect",{"&difficulty&","==","4"}, -- 25h
                "set",{
                    cindermax = 3,
                    dominionmax = 5,
                    blastnovacd = 6.5,
                    blastnovacd2 = 13.5,
                },
            },
        },
        
        announces = {
            cindersay = {
                type = "SAY",
                subtype = "self",
                spell = 79339,
                msg = format(L.alert["%s on ME!"],SN[79339]),
            },
        },
        raidicons = {
            cindermark = {
                varname = format("%s {%s}",SN[79339],"PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 8,
                reset = 3,
                unit = "#5#",
                icon = 2,
                total = 3,
                texture = ST[79339],
            },
            prototypemark = {
                varname = format("%s {%s}","Chromatic Prototypes","NPC_ENEMY"),
                type = "MULTIENEMY",
                persist = 15,
                unit = "#1#",
                reset = 300,
                icon = 6,
                total = 3,
                texture = ST[101432],
            },
        },
        filters = {
            bossemotes = {
                electrocuteemote = {
                    name = "Electrocute",
                    pattern = "The air crackles with ",
                    hasIcon = false,
                    texture = ST[94088],
                    hide = true,
                },
            },
        },
        counters = {
            warriorcounter = {
                variable = "bonewarriors",
                label = "Animated Bone Warriors alive",
                maximum10man = 5,
                maximum25man = 12,
            },
        },
        radars = {
            cinderradar = {
                varname = SN[79339],
                type = "circle",
                player = "#5#",
                range = 10,
                mode = "avoid",
                icon = ST[79339],
            },
        },
        windows = {
			proxwindow = true,
			proxrange = 30,
			proxoverride = true,
            proxnoautostart = true,
            nodistancecheck = true,
		},
        phrasecolors = {
            {"MOVE THE ADS","LIGHTGREEN"},
            {"MOVE THE AD","LIGHTGREEN"},
        },
        misc = {
            args = {
                postponeshadowblaze = {
                    name = format(L.chat_descent["Postpone |T%s:16:16|t |cffffd600Shadowblaze Spark|r when |T%s:16:16|t |cffffd600Shadowflame Breath|r is cast."],ST[81031],ST[94125]),
                    type = "toggle",
                    order = 1,
                    default = true,
                },
                postponeshadowblazebydominion = {
                    name = format(L.chat_descent["Postpone |T%s:16:16|t |cffffd600Shadowblaze Spark|r when |T%s:16:16|t |cffffd600Dominion|r is cast."],ST[81031],ST[79318]),
                    type = "toggle",
                    order = 2,
                    default = true,
                },
                reset_button = addon:genmiscreset(10,"postponeshadowblaze","postponeshadowblazebydominion"),
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd"},
            },
            {
                phase = 1,
                alerts = {"nefarianlands","dominioncd","dominionwarn","dominionself"},
            },
            {
                phase = 2,
                alerts = {"phase2timer","cindercd","cinderwarn","cinderself","blastnovacd","blastwarn"},
            },
            {
                phase = 3,
                alerts = {"phase3warn","blazecd","blazewarn","electrocutewarn"},
            },
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = format(L.alert["%s CD"],SN[26662]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[26662]),
                time = 630,
                flashtime = 30,
                color1 = "RED",
                icon = ST[26662],
            },
            -------------
            -- Phase 1 --
            -------------
            -- Nefarian landing
            nefarianlands = {
                varname = format(L.alert["Nefarian Landing Countdown"]),
                type = "dropdown",
                text = format(L.alert["Nefarian landing"]),
                time = "<nefarianlanding>",
                flashtime = 5,
                color1 = "TEAL",
                icon = ST[105050],
            },
            -------------
            -- Phase 2 --
            -------------
            -- Phase Duration
            phase2timer = {
                varname = format(L.alert["Phase 2 Duration"]),
                type = "dropdown",
                text = format(L.alert["Phase 2"]),
                time = "<phase2timer>",
                flashtime = 5,
                color1 = "MIDGREY",
                icon = ST[11242],
            },
            -- Blast Nova
            blastnovacd = {
                varname = format(L.alert["%s CD"],SN[101432]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[101432]),
                time = "<blastnovacd>",
                time2 = "<blastnovacd2>",
                color1 = "ORANGE",
                icon = ST[101432],
                sound = "MINORWARNING",
                behavior = "overwrite",
            },
            blastwarn = {
                varname = format(L.alert["%s Warning"],SN[101432]),
                type = "simple",
                text = format(L.alert["%s - INTERRUPT"],SN[101432]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT10",
                icon = ST[101432],
                throttle = 2,
                emphasizewarning = true,
            },
            -------------
            -- Phase 3 --
            -------------
            -- Phase Warning
            phase3warn = {
                varname = format(L.alert["Phase 3 Warning"]),
                type = "simple",
                text = format(L.alert["Phase 3"]),
                time = 5,
                color1 = "TURQUOISE",
                icon = ST[11242],
                sound = "MINORWARNING",
            },
            -- Electrocute
            electrocutewarn = {
                varname = format(L.alert["%s Warning"],SN[94088]),
                type = "centerpopup",
                warningtext = format(L.alert["%s"],SN[94088]),
                text = format(L.alert["%s incoming"],SN[94088]),
                time = 5,
                flashtime = 5,
                color1 = "CYAN",
                icon = ST[94088],
                sound = "BEWARE",
                audiocd = true,
            },
            -- Shadowblaze Spark
            blazecd = {
                varname = format(L.alert["%s CD"],SN[81031]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[81031]),
                time = "<blazecd>",
                time2 = 29,
                time3 = "<blazecorrectedcd>",
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "GOLD",
                icon = ST[81031],
                sound = "ALERT8",
                sticky = true,
            },
            blazewarn = {
                varname = format(L.alert["%s Warning"],SN[81031]),
                type = "simple",
                text = "<blazetext>",
                time = 1,
                color1 = "MAGENTA",
                color2 = "RED",
                sound = "ALERT7",
                icon = ST[81031],
            },
            ------------
            -- Heroic --
            ------------
            -- Dominion
            dominionwarn = {
                varname = format(L.alert["%s Warning"],SN[79318]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[79318],"&list|dominionunits&"),
                time = 3,
                color1 = "MAGENTA",
                icon = ST[79318],
                sound = "ALERT9",
            },
            dominionself = {
                varname = format(L.alert["%s on me Warning"],SN[79318]),
                type = "centerpopup",
                text = format(L.alert["%s on <%s>"],SN[79318],L.alert["YOU"]),
                time = 20,
                flashtime = 5,
                flashscreen = true,
                color1 = "MAGENTA",
                icon = ST[79318],
                sound = "BURST",
            },
            dominioncd = {
                varname = format(L.alert["%s CD"],SN[79318]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[79318]),
                time = 15,
                time2 = 50,
                color1 = "PURPLE",
                flashtime = 5,
                icon = ST[79318],
                sound = "MINORWARNING",
                sticky = true,
            },
            -------------
            -- Phase 2 --
            -------------
            -- Explosive Cinders
            cinderwarn = {
                varname = format(L.alert["%s Warning"],SN[79339]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[79339],"&list|cinderunits&"),
                time = 8,
                color1 = "ORANGE",
                icon = ST[79339],
            },
            cinderself = {
                varname = format(L.alert["%s on me Warning"],SN[79339]),
                type = "centerpopup",
                text = format(L.alert["%s on <%s>"],SN[79339],L.alert["YOU"]),
                time = 8,
                color1 = "ORANGE",
                icon = ST[79339],
                sound = "RUNAWAY",
                flashscreen = true,
            },
            cindercd = {
                varname = format(L.alert["%s CD"],SN[79339]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[79339]),
                text2 = format(L.alert["Next %s"],SN[79339]),
                time = 22,
                time2 = 6,
                time3 = "<cindercd>",
                color1 = "ORANGE",
                color2 = "GOLD",
                icon = ST[79339],
                sound = "MINORWARNING",
                thrtottle = 2,
                sticky = "<cindersticky>",
            },
        },
        timers = {
            cindertimer = {
                {
                    "expect",{"&listsize|cinderunits&",">","0"},
                    "alert","cinderwarn",
                },
            },
            dominiontimer = {
                {
                    "expect",{"&listsize|dominionunits&",">","0"},
                    "alert","dominionwarn",
                },
            },
            prototypestimer = {
                {
                    "temptracing","<prototypesunits>",
                },
            },
        },
        events = {
            -- Blast Wave
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 101432,
                execute = {
                    {
                        "expect",{"&npcid|&unitguid|target&&","==","41948",
                            "AND","&unitguid|target&","==","#1#",
                             "OR","&npcid|&unitguid|target&&","~=","41948"},
                        "alert","blastnovacd",
                        "alert","blastwarn",
                    },
                    {
                        "raidicon","prototypemark",
                        "expect",{"<prototypestraced>","==","no"},
                        "insert",{"prototypesunits","#1#"},
                        "expect",{"&listsize|prototypesunits&","==","3"},
                        "set",{prototypestraced = "yes"},
                        "scheduletimer",{"prototypestimer",1},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    -- Phase 2
                    {
                        "expect",{"&npcid|#4#&","==","41270"},
                        "tracing",{41376},
                        "range",{true},
                        "quash","dominioncd",
                        "alert","phase2timer",
                        "alert",{"blastnovacd",time = 2},
                        "schedulealert",{"phase3warn","<phase2timer>"},
                        "expect",{"&difficulty&",">=","3"},
                        "alert",{"cindercd",time = 2, text = 2},
                    },
                    -- Phase 3
                    {
                        "expect",{"&npcid|#4#&","==","41948"},
                        "set",{addsdead = "INCR|1"},
                        "invoke",{
                            {
                                "expect",{"&difficulty&",">=","3"},
                                "expect",{"<phase>","~=","3"},
                                "quash","phase2timer",
                                "cancelalert","phase3warn",
                                "alert","phase3warn",
                                "alert",{"blazecd",time = 2},
                                "set",{
                                    cindersticky = "false",
                                    cindercd = "&timeleft|cindercd&",
                                },
                                "quash","cindercd",
                                "alert",{"cindercd",time = 3},
                                "set",{phase = "3"},
                            },
                            {
                                "expect",{"&difficulty&","<","3"},
                                "expect",{"<addsdead>","==","3"},
                                "quash","phase2timer",
                                "cancelalert","phase3warn",
                                "alert","phase3warn",
                                "alert",{"blazecd",time = 2},
                                "set",{
                                    cindersticky = "false",
                                    cindercd = "&timeleft|cindercd&",
                                },
                                "quash","cindercd",
                                "alert",{"cindercd",time = 3},
                                "set",{phase = "3"},
                            },
                        },
                    },
                },
            },
             -- Shadowblaze
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[81031]},
                        "expect",{"#1#","find","boss"},
                        "invoke",{
                            {
                                "expect",{"<bonewarriors>","==","0"},
                                "set",{blazetext = format(L.alert["%s"],SN[81031])},
                            },
                            {
                                "expect",{"<bonewarriors>","==","1"},
                                "set",{blazetext = format(L.alert["%s - MOVE THE AD!"],SN[81031])},
                            },
                            {
                                "expect",{"<bonewarriors>",">","1"},
                                "set",{blazetext = format(L.alert["%s - MOVE THE ADS!"],SN[81031])},
                            },
                        },
                        "alert","blazewarn",
                        "quash","blazecd",
                        "alert","blazecd",
                        "expect",{"<blazecd>",">","15"},
                        "set",{blazecd = "DECR|5"},
                    },
                },
            },
            -- Electrocute
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_descent["^The air crackles"]},
                        "alert","electrocutewarn",
                    },
                },
            },
            -- Shadowflame Breath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 94125,
                execute = {
                    {
                        "expect",{"<phase>","==","3"},
                        "expect",{"&itemvalue|postponeshadowblaze&","==","true"},
                        "expect",{"&timeleft|blazecd&","<=","2.5"},
                        "set",{blazecorrectedcd = 2.5},
                        "quash","blazecd",
                        "alert",{"blazecd",time = 3},
                    },
                },
            },
            ------------
            -- Heroic --
            ------------
            -- Explosive Cinders
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 79339,
                execute = {
                    {
                        "raidicon","cindermark",
                        "radar","cinderradar",
                        "insert",{"cinderunits","#5#"},
                    },
                    {
                        "expect",{"&listsize|cinderunits&","==","1"},
                        "quash","cindercd",
                        "alert","cindercd",
                        "scheduletimer",{"cindertimer",1},
                    },
                    {
                        "expect",{"&listsize|cinderunits&","==","<cindermax>"},
                        "canceltimer","cindertimer",
                        "alert","cinderwarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "announce","cindersay",
                        "alert","cinderself",
                    },
                },
            },
            -- Explosive Cinders
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 79339,
                execute = {
                    {
                        "removeraidicon","#5#",
                        "removeradar",{"cinderradar", player = "#5#"},
                    },
                },
            },     
            -- Dominion
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 79318,
                execute = {
                    {
                        "quash","dominioncd",
                        "alert","dominioncd",
                        "expect",{"<phase>","==","3"},
                        "expect",{"&itemvalue|postponeshadowblazebydominion&","==","true"},
                        "expect",{"&timeleft|blazecd&","<=","1.5"},
                        "set",{blazecorrectedcd = 1.5},
                        "quash","blazecd",
                        "alert",{"blazecd",time = 3},
                    },
                },      
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 79318,
                execute = {
                    {
                        "insert",{"dominionunits","#5#"},
                    },
                    {
                        "expect",{"&listsize|dominionunits&","==","1"},
                        "scheduletimer",{"dominiontimer",1},

                    },
                    {
                        "expect",{"&listsize|dominionunits&","==","<dominionmax>"},
                        "canceltimer","dominiontimer",
                        "alert","dominionwarn",

                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","dominionself",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 79318,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "quash","dominionself",
                    },
                },
            },
            -- Animated Bone Warrior is ressurected / spawned
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 94091,
                execute = {
                    {
                        "set",{bonewarriors = "INCR|1"},
                    },
                },
            },
            -- Animated Bone Warrior dies
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 94091,
                execute = {
                    {
                        "set",{bonewarriors = "DECR|1"},
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
        key = "bwdtrash",
        zone = L.zone["Blackwing Descent"],
        category = L.zone["Blackwing Descent"],
        name = "Trash",
        triggers = {
            scan = {
                -- The Broken Hall
                42800, -- Golem Sentry
                42362, -- Drakonid Drudge
                42649, -- Drakonid Chainwielder
                
                -- Vault of the Shadowflame
                42768, -- Maimgor
                42767, -- Ivoroc
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {

        },
        phrasecolors = {
            {"Maimgor","GOLD"},
        },
        raidicons = {
            rushmark = {
                varname = format("%s {%s}",SN[79630],"ABILITY_TARGET_HARM"),
				type = "MULTIFRIENDLY",
				persist = 5,
				reset = 5,
				unit = "#5#",
				icon = 1,
				total = 2,
                texture = ST[79630],
            },
        },
        announces = {
            
        },
        grouping = {
            {
                name = "The Broken Hall",
                alerts = {"rushwarn","whirlwindwarn","laserwarn","flashbombwarn","flashbombclosewarn"}
            },
            {
                name = "Vault of the Shadowflame",
                alerts = {"enragewarn","mendingwarn"},
            },
        },
        
        alerts = {
            ---------------------
            -- The Broken Hall --
            ---------------------
            -- Drakonid Rush
            rushwarn = {
                varname = format(L.alert["%s Warning"],SN[79630]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[79630],"<rushunit>"),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT7",
                icon = ST[79630],
            },
            whirlwindwarn = {
                varname = format(L.alert["%s on me Warning"],SN[79974]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE BEHIND!"],SN[79974],L.alert["YOU"]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT10",
                icon = ST[79974],
                emphasizewarning = true,
                throttle = 1,
                enabled = {
                    Heal = true,
                    DPS = true
                },
            },
            
            laserwarn = {
                varname = format(L.alert["%s on me Warning"],SN[81063]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[81063],L.alert["YOU"]),
                time = 1,
                color1 = "RED",
                sound = "ALERT10",
                icon = ST[81063],
                emphasizewarning = true,
                throttle = 2,
            },
            flashbombwarn = {
                varname = format(L.alert["%s on me Warning"],SN[81056]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[81056],L.alert["YOU"]),
                time = 1,
                color1 = "PINK",
                sound = "ALERT10",
                icon = ST[81056],
            },
            flashbombclosewarn = {
                varname = format(L.alert["%s near me Warning"],SN[81056]),
                type = "simple",
                text = format(L.alert["%s near %s - GET AWAY!"],SN[81056],L.alert["YOU"]),
                time = 1,
                color1 = "PINK",
                sound = "ALERT10",
                icon = ST[81056],
            },
            
            ------------------------------
            -- Vault of the Shadowflame --
            ------------------------------
            -- Enrage (Maimgor)
            enragewarn = {
                varname = format(L.alert["%s on Maimgor Warning"],SN[80084]),
                type = "centerpopup",
                text = format(L.alert["%s on %s - DISPEL"],SN[80084],"#5#"),
                time = 30,
                color1 = "RED",
                sound = "ALERT8",
                icon = ST[80084],
            },
            -- Curse of Mending
            mendingwarn = {
                varname = format(L.alert["%s Warning"],SN[80295]),
                type = "centerpopup",
                text = format(L.alert["%s on %s"],SN[80295],"<mendingunit>"),
                warningtext = format(L.alert["%s on %s - DECURSE"],SN[80295],"<mendingunit>"),
                time = 15,
                color1 = "LIGHTGREEN",
                sound = "ALERT8",
                icon = ST[80295],
                tag = "#4#",
            },
        },
        timers = {
            
        },
        events = {
            ---------------------
            -- The Broken Hall --
            ---------------------
            -- Drakonid Rush
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 79630,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{rushunit = format("%s",L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{rushunit = format("<%s>","#5#")},
                    },
                    {
                        "alert","rushwarn",
                        "raidicon","rushmark",
                    },
                },
            },
            -- Whirlwind
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 79974,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","whirlwindwarn",
                    },
                },
            },
            
            
            -- Laser Strike
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 81067,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","laserwarn",
                    },
                },
            },
            -- Flash Bomb
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 81056,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","flashbombwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "expect",{"&getdistance|#4#&","<=",13},
                        "alert","flashbombclosewarn",
                    },
                },
            },
            
            ------------------------------
            -- Vault of the Shadowflame --
            ------------------------------
            -- Enrage (Maimgor)
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 80084,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","42768"},
                        "alert","enragewarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 80084,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","42768"},
                        "quash","enragewarn",
                    },
                },
            },
            -- Curse of Mending
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 80295,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{mendingunit = format("%s",L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{mendingunit = format("<%s>","#5#")},
                    },
                    {
                        "alert","mendingwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 80295,
                execute = {
                    {
                        "quash",{"mendingwarn","#4#"},
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- Gossips
---------------------------------
DXE:RegisterGossip("BWD_Chim1", "I suppose you'll be needing", "Finkle: Chimaeron Pull Dialog 1")
DXE:RegisterGossip("BWD_Chim2", "You were trapped", "Finkle: Chimaeron Pull Dialog 2")
DXE:RegisterGossip("BWD_Chim3", "Gnomes in Lava Suits", "Finkle: Chimaeron Pull Dialog 3")
DXE:RegisterGossip("BWD_Chim4", "You were saying", "Finkle: Chimaeron Pull Dialog 4")
DXE:RegisterGossip("BWD_Chim5", "What restrictions", "Finkle: Chimaeron Pull Dialog 5")
DXE:RegisterGossip("BWD_Neffarian", "Place my hand on the orb", "Orb of Culmination: Activate")
