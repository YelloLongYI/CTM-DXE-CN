-- Data_Bastion_JRG.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "JRG"

DXE:RegisterRealmPatch(realm, "halfus", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "valther", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "ascendcouncil", {
    windows = {
        proxwindow = false,
    },
    version = 18,
    key = "ascendcouncil",
    zone = L.zone["The Bastion of Twilight"],
    category = L.zone["The Bastion of Twilight"],
    name = L.npc_bastion["Ascendant Council"],
    icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Arion.blp",
    icon2 = "Interface\\EncounterJournal\\UI-EJ-BOSS-Ignacious.blp",
    advanced = {
        preventPostDefeatPull = 1,
    },
    triggers = {
        scan = {
            43687, -- Feludius
            43686, -- Ignacious

            43688, -- Arion
            43689, -- Terrastra
        },
        keepalive = {
            43691, -- Ascendant Council Controller -- may be obsolete after the update
            43735, -- Elementium Monstrosity
        },
        yell = L.chat_bastion["^You dare invade"],
    },
    onactivate = {
        tracing = {
            43687, -- Feludius
            43686, -- Ignacious
            43688, -- Arion
            43689, -- Terrastra
        },
        phasemarkers = {
            {{0.25, "Phase 2 push"}},
            {{0.25, "Phase 2 push"}},
            {{0.25, "Phase 3 push"}},
            {{0.25, "Phase 3 push"}},
        },
        tracerstart = true,
        combatstop = true,
        combatstart = true,
        defeat = {
            43735 -- Elementium Monstrosity
        },
    },
    userdata = {
        bloodtext = "",
        icetext = "",
        firstOverloadGravity = "",
        overloadGravitySpellName = "",
        firstOverloadGravityGUID = "",
        phase = 0,
        rodmax = 1,
        crushmax = 1,
        rodunits = {type = "container", wipein = 3},
        crushunits = {type = "container", wipein = 3},
    },
    onstart = {
        {
            "expect",{"&difficulty&",">=","3"}, --10h&25h
            "set",{
                coretext = "",
                overloadtext = "",
                beacontext = "",
            },
        },
        {
            "expect",{"&difficulty&","==","2"},
            "set",{
                rodmax = 3,
                crushmax = 3,
            },
        },
        {
            "expect",{"&difficulty&","==","4"},
            "set",{
                rodmax = 3,
                crushmax = 3,
            },
        },
        {
            "set",{phase = 1},
            "alert",{"aegiscd",time = 2},
            "alert",{"waterbombcd",time = 2, text = 2},

            "alert",{"glaciatecd",time = 3},
            "alert",{"lavaseedcd",time = 3}, -- This only for Jingrange JRG setting
            "alert",{"crushcd",time = 3}, -- This only for Jingrange JRG setting
        },
    },
    
    arrows = {
        blinkarrow = {
            varname = format("%s %s",L.npc_bastion["Arion"],SN[92456]),
            unit = "&tft3_unitname&",
            persist = 6,
            action = "TOWARD",
            msg = L.alert["Interrupt!"],
            spell = SN[92456],
            sound = "ALERT5",
            texture = ST[92456],
        },
        overloadgravityarrow = {
            varname = format("%s / %s partner", "Overload", "Gravity"),
            unit = "<firstOverloadGravity>",
            persist = 30,
            action = "TOWARD",
            msg = L.alert["MOVE TOWARD"],
            spell = "<overloadGravitySpellName>",
            texture = ST[92067],
        },
    },
    announces = {
        rodsay = {
            type = "SAY",
            subtype = "self",
            spell = 83099,
            msg = format(L.alert["%s on ME!"],SN[83099]),
        },
        coresay = {
            type = "SAY",
            subtype = "self",
            spell = 92075,
            msg = format(L.alert["%s on ME!"],SN[92075]),
        },
        overloadsay = {
            type = "SAY",
            subtype = "self",
            spell = 92067,
            msg = format(L.alert["%s on ME!"],SN[92067]),
        },
        beaconsay = {
            type = "SAY",
            subtype = "self",
            spell = 92307,
            msg = format(L.alert["%s on ME!"],SN[92307]),
        },
    },
    raidicons = {
        bloodmark = {
            varname = format("%s {%s}",SN[82660],"PLAYER_DEBUFF"),
            type = "FRIENDLY",
            persist = 15,
            unit = "#5#",
            icon = 5,
            texture = ST[82660],
        },
        icemark = {
            varname = format("%s {%s}",SN[82665],"PLAYER_DEBUFF"),
            type = "FRIENDLY",
            persist = 15,
            unit = "#5#",
            icon = 3,
            texture = ST[82665],
        },
        rodmark = {
            varname = format("%s {%s}",SN[83099],"PLAYER_DEBUFF"),
            type = "MULTIFRIENDLY",
            persist = 15,
            unit = "#5#",
            icon = 4,
            reset = 3,
            total = 3,
            texture = ST[83099],
        },
        crushmark = {
            varname = format("%s {%s}",SN[92486],"PLAYER_DEBUFF"),
            type = "MULTIFRIENDLY",
            persist = 6.5,
            unit = "#5#",
            icon = 4,
            reset = 5,
            total = 4,
            texture = ST[92486],
        },
        overloadmark = {
            varname = format("%s {%s}",SN[92067],"PLAYER_DEBUFF"),
            type = "FRIENDLY",
            persist = 10,
            unit = "#5#",
            icon = 1,
            texture = ST[92067],
        },
        coremark = {
            varname = format("%s {%s}",SN[92075],"PLAYER_DEBUFF"),
            type = "FRIENDLY",
            persist = 5,
            unit = "#5#",
            icon = 2,
            texture = ST[92075],
        },
        beaconmark = {
            varname = format("%s {%s}",SN[92307],"PLAYER_DEBUFF"),
            type = "FRIENDLY",
            persist = 20,
            unit = "#5#",
            icon = 1,
            texture = ST[92307],
        },
    },
    filters = {
        bossemotes = {
            glaciateemote = {
                name = "Glaciate",
                pattern = "begins to cast Glaciate",
                hasIcon = false,
                texture = ST[92506],
                hide = true,
            },
            flamesemote = {
                name = "Rising Flames",
                pattern = "begins to cast Rising Flames",
                hasIcon = false,
                texture = ST[82636],
            },
            eruptionemote = {
                name = "Eruption",
                pattern = "ground beneath you rumbles",
                hasIcon = false,
                texture = ST[83692],
            },
            thundershockpreemote = {
                name = "Thundershock (pre-emote)",
                pattern = "The surrounding air crackles",
                hasIcon = false,
                texture = ST[83067],
                hide = true,
            },
            thundershockemote = {
                name = "Thundershock",
                pattern = "begins to cast Thundershock",
                hasIcon = false,
                texture = ST[83067],
            },
            quakeemote = {
                name = "Quake",
                pattern = "begins to cast Quake",
                hasIcon = false,
                texture = ST[83565],
            },
            rodemote = {
                name = "Lightning Rod",
                pattern = "air around you crackles with",
                hasIcon = false,
                texture = ST[83099],
            },
            beaconemote = {
                name = "Frost Beacon",
                pattern = "Frozen Orb begins to pursue",
                hasIcon = false,
                texture = ST[92307],
                hide = true,
            },
        },
    },
    phrasecolors = {
        {"Ignacious","GOLD"},
        {"Arion","GOLD"},
        {"Terrastra","GOLD"},
    },
    windows = {
        proxwindow = true,
        proxrange = 20,
        proxoverride = true,
    },
    radars = {
        rodradar = {
            varname = SN[83099],
            type = "circle",
            player = "#5#",
            range = 15,
            mode = "avoid",
            color = "GREY",
            icon = ST[83099],
        },
        coreradar = {
            varname = SN[92075],
            type = "circle",
            player = "#5#",
            range = 10,
            mode = "avoid",
            color = "TURQUOISE",
            icon = ST[92075],
        },
    },
    grouping = {
        {
            general = true,
            alerts = {"phasewarn"},
        },
        {
            phase = 1,
            alerts = {"bloodwarn","aegiscd","aegiswarn","aegisabsorb","risingflameskickwarn", -- Ignacious
                        "icewarn","waterbombcd","waterbombwarn","waterlogged","glaciatecd","glaciatewarn","frostboltwarn", -- Feludius
                        "corewarn","coreselfwarn", -- Terrastra
                        "overloadwarn","overloadselfwarn"} -- Arion
                    --   "lavaseedcd", "crushcd"}  -- Jingrange JRG setting 
        },
        {
            phase = 2,
            alerts = {"rodwarn","rodself","lightningkickwarn","getgroundedwarn","shockcd", -- Arion
                        "hardencd","hardenkickwarn","getwindswarn","quakecd", -- Terrastra
                        "beaconwarn","beaconselfwarn"} -- Feludius
        },
        {
            phase = 3,
            alerts = {"phasetransition","lavaseedcd","lavaseedwarn","crushcd","crushwarn","crushduration"},
        },
    },
    
    alerts = {
        -- Phase
        phasewarn = {
            varname = format(L.alert["Phase Warning"]),
            type = "simple",
            text = format(L.alert["Phase %s"],"<phase>"),
            time = 3,
            flashtime = 3,
            color1 = "TURQUOISE",
            icon = ST[11242],
            sound = "MINORWARNING",
        },
        -- Phase 3 transition
        phasetransition = {
            varname = format(L.alert["%s Transition Countdown"],"Phase 3"),
            type = "centerpopup",
            text = format(L.alert["%s transition"],"Phase 3"),
            time = 14.8,
            color1 = "TURQUOISE",
            sound = "None",
            icon = ST[11242],
        },
        
        -----------------------
        ------- Phase 1 -------
        -----------------------
        -- Burning Blood
        bloodwarn = {
            varname = format(L.alert["%s Warning"],SN[82660]),
            type = "centerpopup",
            text = "<bloodtext>",
            time = 30,
            flashtime = 30,
            color1 = "ORANGE",
            sound = "ALERT3",
            icon = ST[82660],
        },
        -- Heart of Ice
        icewarn = {
            varname = format(L.alert["%s Warning"],SN[82665]),
            type = "centerpopup",
            text = "<icetext>",
            time = 30,
            flashtime = 30,
            color1 = "BLUE",
            sound = "ALERT3",
            icon = ST[82665],
        },
        -- Water Bomb
        waterbombcd = {
            varname = format(L.alert["%s CD"], SN[82699]),
            type = "dropdown",
            text = format(L.alert["%s CD"], SN[82699]),
            text2 = format(L.alert["Next %s"], SN[82699]),
            -- time = 28, -- Apollo setting
            time = 33, -- Jingrange JRG setting
            time2 = 15,
            flashtime = 5,
            color1 = "CYAN",
            color2 = "LIGHTBLUE",
            sound = "MINORWARNING",
            icon = ST[82699],
            sticky = true,
        },
        waterbombwarn = {
            varname = format(L.alert["%s Warning"], SN[82699]),
            type = "simple",
            text = format(L.alert["%s"], SN[82699]).."s",
            time = 3,
            color1 = "CYAN",
            sound = "ALERT5",
            icon = ST[82699],        
        },
        -- Waterlogged
        waterlogged = {
            varname = format(L.alert["%s on me Warning"],SN[82762]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[82762],L.alert["YOU"]),
            time = 5,
            flashtime = 5,
            color1 = "CYAN",
            color2 = "GREEN",
            sound = "ALERT2",
            icon = ST[82762],
            throttle = 2,
        },
        -- Glaciate
        glaciatewarn = {
            varname = format(L.alert["%s Casting"],SN[92506]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[92506]),
            time = 3,
            flashtime = 3,
            color1 = "GOLD",
            sound = "RUNAWAY",
            icon = ST[92506],
        },
        glaciatecd = {
            varname = format(L.alert["%s CD"],SN[92506]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[92506]),
            time = 15, -- Apollo setting(trigger by water bomb)
            time2 = 37, -- Jingrange JRG setting(trigger as series)
            time3 = 30, -- Jingrange JRG setting(trigger as series)
            flashtime = 7.5,
            color1 = "BLUE",
            color2 = "TURQUOISE",
            icon = ST[92506],
            sticky = true,
        },
        -- Aegis of Flame
        aegiswarn = {
            varname = format(L.alert["%s Warning"],SN[82631]),
            type = "simple",
            text = format(L.alert["%s"],SN[82631]),
            time = 10,
            flashtime = 10,
            color1 = "GOLD",
            sound = "BEWARE",
            icon = ST[82631],
        },
        aegiscd = {
            varname = format(L.alert["%s CD"],SN[82631]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[82631]),
            -- time = 60, -- Apollo setting
            time = 63, -- Jingrange JRG setting
            time2 = 30,
            flashtime = 5,
            color1 = "RED",
            color2 = "ORANGE",
            icon = ST[82631],
            sticky = true,
        },
        aegisabsorb = {
            varname = format(L.alert["%s Absorbs"],SN[82631]),
            text = "",
            textformat = format("%s (%%s/%%s - %%d%%%%)","Shield"),
            type = "absorb",
            time = 21.5,
            color1 = "GOLD",
            sound = "BEWARE",
            icon = ST[82631],
            npcid = 43686,
            values = {
                [82631] = 500000, --10n
                [92513] = 700000, --10h
                [92512] = 1500000, --25n
                [92514] = 2000000, --25h
            },
        },
        risingflameskickwarn = {
            varname = format(L.alert["%s Interrupt Warning"],SN[82643]),
            type = "simple",
            text = format(L.alert["%s: %s - INTERRUPT"],"Ignacious", SN[82643]),
            time = 1,
            color1 = "YELLOW",
            -- sound = "ALERT10",
            sound = "kickcast",
            icon = ST[82643],
        },
        frostboltwarn = {
            varname = format(L.alert["%s Casting"],SN[82752]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[82752]),
            time = 3,
            flashtime = 3,
            color1 = "GREEN",
            sound = "ALERT10",
            icon = ST[82752],
            enabled = {
                Tank = true,
            },
        },
        -----------------------
        ------- Phase 2 -------
        -----------------------
        -- Harden Skin
        hardencd = {
            varname = format(L.alert["%s CD"],SN[92541]),
            type = "dropdown",
            text = format(L.alert["%s CD"],SN[92541]),
            -- time = 42, -- Apollo setting
            -- time2 = 21, -- Apollo setting
            time = 43, -- Jingrange JRG setting
            time2 = 27, -- Jingrange JRG setting
            flashtime = 7.5,
            color1 = "CYAN",
            icon = ST[92541],
            sticky = true,
        },
        hardenkickwarn = {
            varname = format(L.alert["%s Interrupt Warning"],SN[92541]),
            type = "simple",
            text = format(L.alert["%s: %s - INTERRUPT"],"Terrastra",SN[92541]),
            time = 2.5,
            color1 = "WHITE",
            sound = "ALERT10",
            icon = ST[92541],
        },
        -- Lightning Blast
        lightningkickwarn = {
            varname = format(L.alert["%s Interrupt Warning"],SN[92456]),
            type = "simple",
            text = format(L.alert["%s: %s - INTERRUPT"],"Arion",SN[92456]),
            time = 2.5,
            color1 = "CYAN",
            color2 = "RED",
            sound = "ALERT10",
            icon = ST[92456],
        },
        -- Lightning Rod
        rodwarn = {
            varname = format(L.alert["%s Warning"],SN[83099]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[83099],"&list|rodunits&"),
            time = 5,
            color1 = "ORANGE",
            icon = ST[83099],
            throttle = 2,
        },
        rodself = {
            varname = format(L.alert["%s Warning on me Warning"],SN[83099]),
            type = "centerpopup",
            text = format(L.alert["%s on <%s>"],SN[83099],L.alert["YOU"]),
            time = 15,
            flashtime = 15,
            color1 = "ORANGE",
            sound = "RUNAWAY",
            icon = ST[83099],
            flashscreen = true,
        },
        -- Quake
        quakecd = {
            varname = format(L.alert["%s CD"],SN[83565]),
            type = "dropdown",
            text = "Get Winds!",
            -- time = 31, -- 65 -- Apollo setting
            -- time2 = 27, -- 30 -- Apollo setting
            time = 35, -- Jingrange JRG setting
            time2 = 30, -- Jingrange JRG setting
            flashtime = 7.5,
            audiocd = true,
            color1 = "BROWN",
            color2 = "RED",
            icon = ST[83565],
            sticky = true,
        },
        getwindswarn = {
            varname = "Get Winds Warning",
            type = "simple",
            emphasizewarning = true,
            text = "Get Winds!",
            time = 5,
            color1 = "GOLD",
            -- sound = "ALERT10",
            sound = "findwind",
            icon = ST[8385],
        },
        -- Thundershock
        shockcd = {
            varname = format(L.alert["%s CD"],SN[83067]),
            type = "dropdown",
            text = "Get Grounded",
            -- time = 36, -- Apollo setting
            time = 35, -- Jingrange JRG setting
            flashtime = 7.5,
            audiocd = true,
            color1 = "INDIGO",
            color2 = "TURQUOISE",
            icon = ST[83067],
            sticky = true,
        },
        getgroundedwarn = {
            varname = "Get Grounded Warning",
            type = "simple",
            emphasizewarning = true,
            text = "Get Grounded!",
            time = 5,
            color1 = "GOLD",
            -- sound = "ALERT10",
            sound = "findwell",
            icon = ST[1604],
        },
        -----------------------
        ------- Phase 3 -------
        -----------------------
        -- Gravity Crush
        crushcd = {
            varname = format(L.alert["%s CD"],SN[92488]),
            type = "dropdown",
            text = format(L.alert["%s CD"],SN[92488]),
            time = 23, -- Apollo setting
            time2 = 24, -- Apollo setting
            time3 = 26, -- Jingrange JRG setting
            time4 = 24, -- Jingrange JRG setting
            flashtime = 5,
            color1 = "TAN",
            icon = ST[92488],
            sound = "MINORWARNING",
            throttle = 2,
            sticky = true,
        },
        crushwarn = {
            varname = format(L.alert["%s Warning"],SN[92488]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[92488],"&list|crushunits&"),
            time = 6.5,
            color1 = "ORANGE",
            icon = ST[92488],
            sound = "ALERT2",
        },
        crushduration = {
            varname = format(L.alert["%s Duration"],SN[92488]),
            type = "centerpopup",
            fillDirection = "DEPLETE",
            text = format(L.alert["%s"],SN[92488]),
            time = 6.5,
            color1 = "ORANGE",
            icon = ST[92488],
            sound = "None",
            throttle = 2,
        },
        -- Lava Seed
        lavaseedcd = {
            varname = format(L.alert["%s CD"], SN[84913]),
            type = "dropdown",
            text = format(L.alert["%s CD"], SN[84913]),
            time = 23, -- Apollo setting
            time2 = 16, -- Apollo setting
            time3 = 13,  -- Jingrange JRG setting
            time4 = 22,  -- Jingrange JRG setting
            flashtime = 5,
            color1 = "RED",
            sound = "ALERT4",
            icon = ST[84913],
            sticky = true,
        },
        lavaseedwarn = {
            varname = format(L.alert["%s Warning"], SN[84913]),
            type = "centerpopup",
            text = format(L.alert["%s"], SN[84913]).."!",
            time = 2,
            color1 = "RED",
            sound = "BEWARE",
            icon = ST[84913],
        },
        -------------------------------
        ---- Heroic mode - Phase 1 ----
        -------------------------------

        -- Static Overload
        overloadwarn = {
            varname = format(L.alert["%s Warning"],SN[92067]),
            type = "centerpopup",
            text = "<overloadtext>",
            time = 10,
            color1 = "YELLOW",
            icon = ST[92067],
            sound = "ALERT4",
        },
        overloadselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[92067]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[92067],L.alert["YOU"]),
            time = 10,
            color1 = "YELLOW",
            icon = ST[92067],
            sound = "ALERT1",
            flashscreen = true,
            emphasizewarning = true,
        },
        -- Gravity Core
        corewarn = {
            varname = format(L.alert["%s Warning"],SN[92075]),
            type = "centerpopup",
            text = "<coretext>",
            time = 10,
            color1 = "YELLOW",
            icon = ST[92075],
            sound = "MINORWARNING",
        },
        coreselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[92075]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[92075],L.alert["YOU"]),
            time = 10,
            color1 = "WHITE",
            icon = ST[92075],
            sound = "ALERT1",
            flashscreen = true,
            emphasizewarning = true,
        },
        -------------------------------
        ---- Heroic mode - Phase 2 ----
        -------------------------------
        -- Frost Beacon
        beaconwarn = {
            varname = format(L.alert["%s Warning"],SN[92307]),
            type = "simple",
            text = "<beacontext>",
            time = 5,
            color1 = "GOLD",
            icon = ST[92307],
            sound = "MINORWARNING",
        },
        beaconselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[92307]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[92307],L.alert["YOU"]),
            time = 5,
            color1 = "GOLD",
            icon = ST[92307],
            sound = "RUNAWAY",
            flashscreen = true,
            emphasizewarning = true,
        },
    },
    timers = {
        blink = {
            {
                "arrow","blinkarrow",
            },
        },
        rodtimer = {
            {
                "expect",{"&listsize|rodunits&",">","0"},
                "alert","rodwarn",
            },
        },
        crushtimer = {
            {
                "expect",{"&listsize|crushunits&",">","0"},
                "alert","crushwarn",
            },
            },
    },
    events = {
        -- Ignacious
        -- Burning Blood
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 82660,
            srcisnpctype = true,
            execute = {
                {
                    "raidicon","bloodmark",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{bloodtext = format(L.alert["%s on <%s>"],SN[82660],L.alert["YOU"])},
                    "alert","bloodwarn",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{bloodtext = format(L.alert["%s on <%s>"],SN[82660],"#5#")},
                    "alert","bloodwarn",
                },
            },
        },
        -- Burning Blood removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 82660,
            execute = {
                {
                    "removeraidicon","#5#",
                    "quash","bloodwarn",
                },
            },
        },
        -- Aegis (Shield)
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 92512,
            execute = {
                {
                    "quash","aegiscd",
                    "alert","aegiswarn",
                    "alert","aegisabsorb",
                    "alert","aegiscd",
                },
            },
        },
        -- Aegis removed -> Kick
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 92512,
            execute = {
                {
                    "quash","aegiswarn",
                    "quash","aegisabsorb",
                    "alert","risingflameskickwarn",
                },
            },
        },
        -- Water Bomb
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 82699,
            execute = {
                {
                    "alert","waterbombwarn",
                    "quash","waterbombcd",
                    "quash","lavaseedcd", -- Jingrange JRG setting
                    "quash","crushcd", -- Jingrange JRG setting
                    "crushcd","waterbombcd",
                    -- "alert","glaciatecd", -- Apollo setting
                },
            },
        },
        -- Feludius
        -- Heart of Ice
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 82665,
            execute = {
                {
                    "raidicon","icemark",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{icetext = format(L.alert["%s on <%s>"],SN[82665],L.alert["YOU"])},
                    "alert","icewarn",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{icetext = format(L.alert["%s on <%s>"],SN[82665],"#5#")},
                    "alert","icewarn",
                },
            },
        },
        -- Heart of Ice removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 82665,
            execute = {
                {
                    "removeraidicon","#5#",
                    "quash","icewarn",
                },
            },
        },
        -- Waterlogged self
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 82762,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","waterlogged",
                },
            },
        },
        -- Glaciate
        -- Apollo setting block
        -- {
        --     type = "combatevent",
        --     eventtype = "SPELL_CAST_START",
        --     spellname = 82746,
        --     execute = {
        --         {
        --             "quash","glaciatecd",
        --             "alert","glaciatewarn",
        --         },
        --     },
        -- },

        -- Jingrange JRG setting
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 82746,
            execute = {
                {
                    "quash","glaciatecd",
                    "alert","glaciatewarn",
                    "alert",{"glaciatecd",time = 2},
                },
            },
        },

        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 82752,
            execute = {
                {
                    "alert","frostboltwarn"
                },
            },
        },
        -- Phase 2 Trigger
        {
            type = "event",
            event = "YELL",
            execute = {
                {
                    "expect",{"#1#","find",L.chat_bastion["^Enough of this foolishness"]},
                    "set",{phase = 2},
                    "alert","phasewarn",
                    "quash","aegiscd",
                    "quash","glaciatecd",
                    "quash","waterbombcd",
                    "alert",{"quakecd",time = 2},
                    "alert",{"hardencd",time = 2},
                    "schedulealert",{"getwindswarn",15}
                },
            },
        },
        -- Terrastra
        -- Harden Skin
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 92541,
            execute = {
                {
                    "quash","hardencd",
                    "alert","hardenkickwarn",
                    "alert","hardencd",
                },
            },
        },
        -- Quake
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 92544,
            execute = {
                {
                    "quash","quakecd",
                    "alert","shockcd",
                    "schedulealert",{"getgroundedwarn",5}
                },
            },
        },
        -- Arion
        -- Lightning Rod
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 83099,
            execute = {
                {
                    "raidicon","rodmark",
                    "radar","rodradar",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "insert",{"rodunits",L.alert["YOU"]},
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "insert",{"rodunits","#5#"},
                },
                {
                    "expect",{"&listsize|rodunits&","==","1"},
                    "scheduletimer",{"rodtimer",1},
                }, 
                {
                    "expect",{"&listsize|rodunits&","==","<rodmax>"},
                    "canceltimer","rodtimer",
                    "alert","rodwarn",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "announce","rodsay",
                    "alert","rodself",
                },
            },
        },
        -- Lightning Rod removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 83099,
            execute = {
                {
                    "removeraidicon","#5#",
                    "removeradar",{"rodradar", player = "#5#"},
                },
            },
        },
        -- Thundershock
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 92469,
            execute = {
                {
                    "quash","shockcd",
                    "alert","quakecd",
                    "schedulealert",{"getwindswarn",5}
                },
            },
        },
        -- Lightning Blast (only Arrow)
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 83087,
            execute = {
                {
                    "schedulealert",{"lightningkickwarn", 1.5},
                    "scheduletimer",{"blink",2},
                },
            },
        },
        -- Phase 3 Trigger
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 82285,
            execute = {
                -- Apollo setting block
                -- {
                --     "expect",{"<phase>","<","3"},
                --     "quashall",true,
                --     "set",{phase = 3},
                --     "alert","phasetransition",
                --     "alert",{"lavaseedcd",time = 3}, -- This only for Jingrange JRG setting
                --     "alert",{"crushcd",time = 3}, -- This only for Jingrange JRG setting
                --     "tracing",{43735}, -- Monstrosity This only for Jingrange JRG setting
                -- },

                -- Jingrange JRG setting block
                {
                    -- "quashall",true,
                    "set",{phase = 3},
                    "alert","phasetransition",
                    "alert",{"lavaseedcd",time = 3}, -- This only for Jingrange JRG setting
                    "alert",{"crushcd",time = 3}, -- This only for Jingrange JRG setting
                    "tracing",{43735}, -- Monstrosity This only for Jingrange JRG setting
                },
            },
        },
        {
            type = "event",
            event = "YELL",
            execute = {
                {
                    "expect",{"#1#","find",L.chat_bastion["^BEHOLD YOUR DOOM"]},
                    "alert",{"crushcd",time = 2},
                    "alert",{"lavaseedcd",time = 2},
                    "alert","phasewarn",
                    "tracing",{43735}, -- Monstrosity
                    "hidephasemarker",{1,1},
                },
            },
        },
        
        -- Gravity Crush
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 92486,
            execute = {
                {
                    "raidicon","crushmark",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "insert",{"crushunits",L.alert["YOU"]},
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "insert",{"crushunits","#5#"},
                },
                {
                    "expect",{"&listsize|crushunits&","==","1"},
                    "scheduletimer",{"crushtimer",1},
                    "quash","crushcd",
                    "alert","crushduration",
                    -- "alert","crushcd", -- Apollo setting
                    "alert",{"crushcd",time = 4}, -- Jingrange JRG setting
                },
                {
                    "expect",{"&listsize|crushunits&","==","<crushmax>"},
                    "canceltimer","crushtimer",
                    "alert","crushwarn",
                },
            },
        },
        -- Gravity crush removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 92486,
            execute = {
                {
                    "removeraidicon","#5#",
                },
            },
        },
        -- Lava Seed
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 84913,
            execute = {
                {
                    "alert","lavaseedwarn",
                    "quash","lavaseedcd",

                    -- "alert","lavaseedcd", -- Apollo setting
                    "alert",{"lavaseedcd",time = 4}, -- Jingrange JRG setting

                    "quash","waterbombcd", -- This only for Jingrange JRG setting(quash due to trigger p1 alert)
                    "quash","aegiscd", -- This only for Jingrange JRG setting(quash due to trigger p1 alert)
                },
            },
        },
            
        -- Heroic Events
        -- Static Overload
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = 92067,
            srcisnpctype = true,
            execute = {
                {
                    "expect",{"<firstOverloadGravityGUID>","==","&playerguid&"},
                    "set",{firstOverloadGravity = "#5#"},
                    "set",{overloadGravitySpellName = format("%s",SN[92067])},
                    "arrow","overloadgravityarrow",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "expect",{"<firstOverloadGravityGUID>","~=",""},
                    "set",{overloadGravitySpellName = format("%s",SN[92075])},
                    "arrow","overloadgravityarrow",
                },
                {
                    "set",{firstOverloadGravityGUID = "#4#"},
                    "set",{firstOverloadGravity = "#5#"},
                    "raidicon","overloadmark",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","overloadselfwarn",
                    "announce","overloadsay",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{overloadtext = format("%s on <#5#>!",SN[92067])},
                    "alert","overloadwarn",
                },
            },
        },
        -- Static Overload removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellid = 92067,
            execute = {
                {
                    "removeraidicon","#5#",
                    "quash","overloadwarn",
                    "set",{firstOverloadGravity = ""},
                    "set",{firstOverloadGravityGUID = ""},
                    "removearrow","#5#",
                },
            },
        },
        -- Gravity Core
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = 92075,
            srcisnpctype = true,
            execute = {
                {
                    "expect",{"<firstOverloadGravityGUID>","==","&playerguid&"},
                    "set",{firstOverloadGravity = "#5#"},
                    "set",{overloadGravitySpellName = format("%s",SN[92075])},
                    "arrow","overloadgravityarrow",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "expect",{"<firstOverloadGravityGUID>","~=",""},
                    "set",{overloadGravitySpellName = format("%s",SN[92067])},
                    "arrow","overloadgravityarrow",
                },
                {
                    "set",{firstOverloadGravityGUID = "#4#"},
                    "set",{firstOverloadGravity = "#5#"},
                    "raidicon","coremark",
                    "radar","coreradar",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","coreselfwarn",
                    "announce","coresay",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{coretext = format("%s on <#5#>!",SN[92075])},
                    "alert","corewarn",
                },
            },
        },
        -- Gravity Core removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellid = 92075,
            execute = {
                {
                    "removeraidicon","#5#",
                    "quash","corewarn",
                    "set",{firstOverloadGravity = ""},
                    "set",{firstOverloadGravityGUID = ""},
                    "removearrow","#5#",
                    "removeradar",{"coreradar", player = "#5#"},
                },
            },
        },
        -- Frost Beacon
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 92307,
            execute = {
                {
                    "raidicon","beaconmark",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","beaconselfwarn",
                    "announce","beaconsay",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{beacontext = format("%s on <#5#>!",SN[92307])},
                    "alert","beaconwarn",
                },
            },
        },
        -- Frost Beacon removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 92307,
            execute = {
                {
                    "removeraidicon","#5#",
                    "quash","beaconwarn",
                    "quash","beaconselfwarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "chogall", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "sinestra", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "bottrash", {
    windows = {
        proxwindow = false,
    },
})
