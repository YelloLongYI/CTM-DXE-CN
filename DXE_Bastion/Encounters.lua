local addon = DXE
local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- HALFUS WYRMBREAKER
---------------------------------

do
    local data = {
        version = 7,
        key = "halfus",
        zone = L.zone["The Bastion of Twilight"],
        category = L.zone["The Bastion of Twilight"],
        name = L.npc_bastion["Halfus Wyrmbreaker"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Halfus Wyrmbreaker.blp",
        triggers = {
            scan = {
                44600, -- Halfus Wyrmbreaker
                44650, -- Storm Rider
                44645, -- Nether Scion
                44797, -- Time Warden
                44652, -- Slate Dragon
            },
        },
        onactivate = {
            tracing = {
                44600, -- Halfus Wyrmbreaker
            },
            phasemarkers = {
                {
                    {0.50,"Furious Roar","At 50% HP, Halfus starts periodically casting Furious Roar."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = {
                44600, -- Halfus Wyrmbreaker
            },
        },
        userdata = {
            scorchingbreathcd = {11, 23, 21, loop = false, type = "series"},
            whelpsreleased = "no",
            furiouscount = 0,
            novacast = 0.25,
        },
        onstart = {
            {
                "alert","enragecd",
                "expect",{"&difficulty&",">=","3"}, --10h&25h
                "alert",{"novacd",time = 2},
                "alert","scorchingbreathcd",
            },
        },
        
        filters = {
            bossemotes = {
                timewardenemote = {
                    name = "Time Warden release",
                    pattern = "binds the Time Warden",
                    hasIcon = false,
                    texture = "Interface\\ICONS\\Ability_Mount_Drake_Bronze",
                    hide = true,
                },
                stormrideremote = {
                    name = "Storm Rider release",
                    pattern = "binds the Storm Rider",
                    hasIcon = false,
                    texture = "Interface\\ICONS\\inv_misc_stormdragonpale",
                    hide = true,
                },
                slatedragonemote = {
                    name = "Slate Dragon release",
                    pattern = "binds the Slate Dragon",
                    hasIcon = false,
                    texture = "Interface\\ICONS\\inv_misc_stonedragonblue",
                    hide = true,
                },
                netherscionemote = {
                    name = "Nether Scion release",
                    pattern = "binds the Nether Scion",
                    hasIcon = false,
                    texture = "Interface\\ICONS\\Ability_Mount_NetherdrakePurple",
                    hide = true,
                },
                whelpsemote = {
                    name = "Emerald Whelps release",
                    pattern = "binds the Orphaned",
                    hasIcon = false,
                    texture = "Interface\\ICONS\\INV_Misc_Head_Dragon_Green",
                    hide = true,
                },
                roaremote = {
                    name = "Furious Roar",
                    pattern = "roars furiously",
                    hasIcon = false,
                    hide = true,
                    texture = ST[86169],
                    hide = true,
                },
            },
        },
        counters = {
            whelpscounter = {
                variable = "whelpscount",
                label = "Emerald Whelps",
                value = 8,
                minimum = 0,
                maximum = 8,
            },
        },
        phrasecolors = {
            {"Time Warden:","GOLD"},
            {"Orphaned Emerald Whelps:","GOLD"},
            {"Storm Rider:","GOLD"},
            {"Slate Dragon:","GOLD"},
            {"Nether Scion:","GOLD"},
        },
        ordering = {
            alerts = {"enragecd","novacd","novawarn","novacast","bindwarn","scorchingbreathcd","scorchingbreathdurwarn","furiouscd","furiouswarn","paralysiswarn"}
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time = 360,
                flashtime = 10,
                color1 = "RED",
                icon = ST[12317],
            },
            -- Shadow Nova
            novacd = {
                varname = format(L.alert["%s CD"],SN[86168]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[86168]),
                time = 12,
                time2 = 11,
                time3 = "<novadelayed>",
                flashtime = 3,
                color1 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[86168],
            },
            novawarn = {
                varname = format(L.alert["%s Warning"],SN[86168]),
                type = "simple",
                text = format(L.alert["%s - INTERRUPT"],SN[86168]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[86168],
            },
            novacast = {
                varname = format(L.alert["%s Cast"],SN[86168]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[86168]),
                time = "<novacast>",
                color1 = "MAGENTA",
                sound = "None",
                icon = ST[86168],
            },
            -- Scorching Breath
            scorchingbreathdurwarn = {
                varname = format(L.alert["%s Duration"], SN[83707]),
                type = "centerpopup",
                text = format(L.alert["%s"], SN[83707]),
                time = 8,
                flashtime = 6,
                color1 = "ORANGE",
                icon = ST[83707],
                throttle = 6,   
                behavior = "overwrite",
            },
            scorchingbreathcd = {
                varname = format(L.alert["%s CD"], SN[83707]),
                type = "dropdown",
                text = format(L.alert["%s CD"], SN[83707]),
                time = "<scorchingbreathcd>",
                flashtime = 15,
                color1 = "RED",
                color2 = "ORANGE",
                icon = ST[83707],
                throttle = 2,
                behavior = "overwrite",
                sticky = true,
            },
            -- Furious Roar
            furiouscd = {
                varname = format(L.alert["%s CD"],SN[86169]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[86169]),
                time = 23.5,
                flashtime = 10,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[86169],
                audiocd = true,
                throttle = 10,
            },
            furiouswarn = {
                varname = format(L.alert["%s Cast Warning"],SN[86169]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[86169]),
                time = 6.5,
                sound = "MINORWARNING",
                color1 = "GOLD",
                throttle = 5,
                icon = ST[86169],
                throttle = 10,
                emphasizetimer = true,
            },
            -- Bind Will
            bindwarn = {
                varname = format(L.alert["%s Warning"],SN[83432]),
                type = "simple",
                text = "<bindtext>",
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = "<bindicon>",
                tag = "#4#",
            },
            
            -- Paralysis
            paralysiswarn = {
                varname = format(L.alert["%s Duration"],SN[84030]),
                type = "centerpopup",
                warningtext = format(L.alert["%s"],SN[84030]),
                text = format(L.alert["%s fades"],SN[84030]),
                time = 12,
                flashtime = 5,
                color1 = "MIDGREY",
                color2 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[84030],
            },
        },
        events = {
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 83432, -- Bind Will
                execute = {
                    -- Releasing Storm Rider
                    {
                        "expect",{"#5#","==","Storm Rider"},
                        "set",{bindicon = "Interface\\ICONS\\inv_misc_stormdragonpale"},
                        "set",{novacast = 3},
                        "expect",{"&difficulty&","<=","2"},
                        "alert","novacd",
                    },
                    -- Releasing Time Warden
                    {
                        "expect",{"#5#","==","Time Warden"},
                        "set",{bindicon = "Interface\\ICONS\\Ability_Mount_Drake_Bronze"},
                    },
                    -- Releasing Slate Dragon
                    {
                        "expect",{"#5#","==","Slate Dragon"},
                        "set",{bindicon = "Interface\\ICONS\\inv_misc_stonedragonblue"},
                    },
                    -- Releasing Nether Scion
                    {
                        "expect",{"#5#","==","Nether Scion"},
                        "set",{bindicon = "Interface\\ICONS\\Ability_Mount_NetherdrakePurple"},
                    },
                    -- Releasing Orphaned Emerald Whelps
                    {
                        "expect",{"#5#","==","Orphaned Emerald Whelp"},
                        "expect",{"<whelpsreleased>","==","no"},
                        "set",{
                            whelpsreleased = "yes",
                            whelpscount = 8,
                            bindicon = "Interface\\ICONS\\INV_Misc_Head_Dragon_Green",
                        },
                        "set",{bindtext = format(L.alert["%s: Released!"],"Orphaned Emerald Whelps")},
                        "alert","bindwarn",
                        "counter","whelpscounter",
                        "expect",{"&difficulty&","<=","2"},
                        "alert","scorchingbreathcd",
                    },
                    -- Dragon's tracing
                    {
                        "expect",{"#5#","~=","Orphaned Emerald Whelp"},
                        "set",{bindtext = format(L.alert["%s: Released!"],"#5#")},
                        "alert","bindwarn",
                        "temptracing","#4#",
                    },
                },
            },
            -- Scorching Breath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 83707,
                execute = {
                    {
                        "quash","scorchingbreathcd",
                        "schedulealert",{"scorchingbreathcd",2},
                        "schedulealert",{"scorchingbreathdurwarn",2}
                    },
                },
            },
            -- Shadow Nova
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 86168,
                execute = {
                    {
                        "quash","novacd",
                        "alert","novacd",
                        "alert","novawarn",                        
                        "alert","novacast",
                    },
                },
            },
            -- Orphaned Emerald Whelp dies
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"#5#","==","Orphaned Emerald Whelp"},
                        "set",{whelpscount = "DECR|1"},
                    },
                    {
                        "expect",{"<whelpscount>","==","0"},
                        "removecounter","whelpscounter",
                    },
                },
            },
            -- Furious Roar
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 86169,
                execute = {
                    {
                        "set",{furiouscount = "INCR|1"},
                        "expect",{"<furiouscount>","==","3"},
                        "set",{furiouscount = 0},
                        "schedulealert",{"furiouscd", 1.5},
                    },
                    {
                        "expect",{"<furiouscount>","==","1"},
                        "alert","furiouswarn",
                    },
                },
            },
            -- Paralysis
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 84030,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","44600"},
                        "expect",{"&npcid|#4#&","==","44600"},
                        "alert","paralysiswarn",
                        "expect",{"&timeleft|novacd&",">","0"},
                        "set",{novadelayed = "&timeleft|paralysiswarn&"},
                        "quash","novacd",
                        "alert",{"novacd",time = 3},
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- VALIONA & THERALION
---------------------------------

do
    local data = {
        version = 18,
        key = "valther",
        zone = L.zone["The Bastion of Twilight"],
        category = L.zone["The Bastion of Twilight"],
        name = L.npc_bastion["Valiona & Theralion"],
        lfgname = "Theralion and Valiona",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Valiona Raid.blp",
        icon2 = "Interface\\EncounterJournal\\UI-EJ-BOSS-Theralion.blp",
        plural = true,
        triggers = {
            scan = {
                45992, -- Valiona
                45993, -- Theralion
            },
        },
        onactivate = {
            tracing = {
                45992, -- Valiona
                45993, -- Theralion
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = {
                45992, -- Valiona
                45993, -- Theralion
            },
        },
        userdata = {
            blackoutcd = {45.5, 45.5, 0, loop = false, type = "series"},
            dazzlecd = {80, 82.35, loop = false, type = "series"},
            shifttext = "",
            breathwarned = "no",
            meteoritewarned = "no",
            dazzlingwarned = "no",
            castingblast = "no",
            firstblastcast = "no",
            engulfmax = 1,
            engulfunits = {type = "container", wipein = 3},
        },
        onstart = {
            {
                "alert","enragecd",
                "alert",{"blackoutcd",time = 2},
                "alert",{"flamecd",time = 2},        
            },
            {
                "expect",{"&difficulty&","==","2"},
                "set",{engulfmax = 3},
            },
            {
                "expect",{"&difficulty&","==","4"},
                "set",{engulfmax = 3},
            },
        },
        
        announces = {
            blastsay = {
                type = "SAY",
                subtype = "self",
                spell = 86369,
                msg = format(L.alert["%s on ME!"],SN[86369]),
                enabled = false,
            },
        },
        arrows = {
            blackoutarrow = {
                varname = SN[92876],
                unit = "#5#",
                persist = 15,
                action = "TOWARD",
                msg = L.alert["MOVE TOWARD"],
                spell = SN[92876],
                texture = ST[92876],
            },
        },
        raidicons = {
            blackoutmark = {
                varname = format("%s {%s}",SN[92876],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                total = 3,
                persist = 15,
                unit = "#5#",
                icon = 1,
                texture = ST[92876],
            },
            engulfmark = {
                varname = format("%s {%s}",SN[95639],"PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 20,
                unit = "#5#",
                icon = 2,
                reset = 3, -- Looks like 2 on 25 man, TODO: Check for 10 man count
                total = 3,
                texture = ST[95639],
            },
        },
        filters = {
            bossemotes = {
                blackoutemote = {
                    name = "Blackout",
                    pattern = "Valiona casts %[Blackout%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[92876],
                },
                dazzlingemote = {
                    name = "Dazzling Destruction",
                    pattern = "Theralion begins to cast %[Dazzling Destruction%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[86408],
                },
                engulfemote = {
                    name = "Engulfing Magic",
                    pattern = "Theralion begins to cast %[Engulfing Magic%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[95639],
                },
            },
        },
        phrasecolors = {
            {"Valiona:","GOLD"},
            {"Theralion:","GOLD"},
            {"is preparing for","WHITE"},
        },
        windows = {
            proxwindow = true,
            proxrange = 20,
            proxoverride = true,
            nodistancecheck = true
        },
        radars = {
            blackoutradar = {
                varname = SN[92876],
                type = "circle",
                player = "#5#",
                range = 8,
                mode = "stack",
                count = 5,
                color = "MAGENTA",
                icon = ST[92876],
            },
            engulfradar = {
                varname = SN[95639],
                type = "circle",
                player = "#5#",
                range = 10,
                mode = "avoid",
                color = "TURQUOISE",
                icon = ST[95639],
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd"},
            },
            {
                name = "|cffffd700Valiona|r |cffffffffgrounded|r",
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Valiona Raid",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"shiftcd","blackoutcd","blackoutdurationwarn","blackoutselfwarn","flamecd","flamewarn","dazzlecd","dazzlewarn"}
            },
            {
                name = "|cffffd700Theralion|r |cffffffffgrounded|r",
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Theralion",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"fabulousselfwarn","meteoriteselfwarn","engulfcd","engulfwarn","engulfselfduration","breathcd","breathwarn"},
            },
        },
        
        alerts = {
            -- Twilight Shift
            shiftcd = {
                varname = format(L.alert["%s CD"],SN[93051]),
                type = "dropdown",
                text = "<shifttext>",
                time = 20,
                flashtime = 5,
                color1 = "PINK",
                icon = ST[93051],
            },
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time = 600,
                flashtime = 10,
                color1 = "RED",
                icon = ST[12317],
            },
            ------------------------
            -- Theralion Airborne --
            ------------------------
            -- Blackout
            blackoutcd = {
                varname = format(L.alert["%s CD"],SN[92876]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92876]),
                time = "<blackoutcd>",
                time2 = 10.7,
                time3 = 9,
                flashtime = 10,
                color1 = "VIOLET",
                icon = ST[92876],
                sound = "MINORWARNING",
            },
            blackoutselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[92876]),
                type = "centerpopup",
                warningtext = format("%s on %s!",SN[92876],L.alert["YOU"]),
                text = format("%s on %s",SN[92876],L.alert["YOU"]),
                time = 15,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[92876],
                flashscreen = true,
                emphasizewarning = true,
            },
            blackoutdurationwarn = {
                varname = format(L.alert["%s Warning"],SN[92876]),
                type = "centerpopup",
                text = format("%s on <#5#>!",SN[92876]),
                time = 15,
                color1 = "MAGENTA",
                icon = ST[92876],
            },
            -- Devouring Flames
            flamewarn = {
                varname = format(L.alert["%s Casting"],SN[86840]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[86840]),
                time = 2.5,
                flashtime = 2.5,
                color1 = "ORANGE",
                sound = "BEWARE",
                icon = ST[86840],
            },
            flamecd = {
                varname = format(L.alert["%s CD"],SN[86840]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[86840]),
                time = 40,
                time2 = 25.75,
                flashtime = 5,
                color1 = "MAGENTA",
                icon = ST[86840],
                sticky = true,
            },
            -- Dazzling Destruction
            dazzlewarn = {
                varname = format(L.alert["%s Casting"],SN[86408]),
                type = "simple",
                text = format(L.alert["Theralion: %s"],SN[86408]),
                time = 4,
                flashtime = 4,
                color1 = "RED",
                sound = "BEWARE",
                icon = ST[86408],
                throttle = 1,
            },
            dazzlecd = {
                varname = format(L.alert["%s CD"],SN[86408]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[86408]),
                time = "<dazzlecd>",
                flashtime = 5,
                color1 = "PINK",
                color2 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[86408],
            },
            ----------------------
            -- Valiona Airborne --
            ----------------------
            -- Deep Breath
            breathcd = {
                varname = format(L.alert["%s CD"],SN[86059]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[86059]),
                time = 108,
                flashtime = 0,
                color1 = "PINK",
                icon = ST[85664],
                audiocd = true,
                sound = "Sound\\Creature\\Valiona\\VO_BT_Valiona_Event05.ogg",
            },
            breathwarn = {
                varname = format(L.alert["%s Warning"],SN[86059]),
                type = "simple",
                text = format(L.alert["Valiona is preparing for %s"],SN[86059]),
                time = 5,
                color1 = "PINK",
                icon = ST[85664],
            },
            -- Engulfing Magic
            engulfcd = {
                varname = format(L.alert["%s CD"],SN[95639]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[95639]),
                time = 35,
                time2 = 31,
                flashtime = 5,
                color1 = "CYAN",
                icon = ST[95639],
                sticky = true,
            },
            engulfselfduration = {
                varname = format(L.alert["%s on me Duration"],SN[95639]),
                type = "centerpopup",
                text = format("%s on %s",SN[95639],L.alert["YOU"]),
                time = 20,
                color1 = "MAGENTA",
                color2 = "CYAN",
                icon = ST[95639],
                flashscreen = true,
                sound = "BURST",
                emphasizewarning = true,
            },
            engulfwarn = {
                varname = format(L.alert["%s Warning"],SN[95639]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[95639],"&list|engulfunits&"),
                time = 20,
                color1 = "MAGENTA",
                icon = ST[95639],
                sound = "ALERT5",
            },
            -- Twilight Meteorite
            meteoriteselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[88518]),
                type = "centerpopup",
                text = format(L.alert["%s on %s"],SN[88518],L.alert["YOU"]),
                time = 6,
                flashtime = 6,
                color1 = "PURPLE",
                icon = ST[88518],
                sound = "ALERT10",
                flashscreen = true,
                emphasizewarning = true,
            },
            -- Fabulous Flames
            fabulousselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[86505]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[86505],L.alert["YOU"]),
                time = 1,
                color1 = "PURPLE",
                sound = "ALERT10",
                icon = ST[86505],
                throttle = 2,
                emphasizewarning = true,
            },
        },
        timers = {
            firemeteorite = {
                {
                    "expect",{"&playerdebuff|"..SN[88518].."&","==","true"},
                    "expect",{"<meteoritewarned>","==","no"},
                    "alert","meteoriteselfwarn",
                    "set",{meteoritewarned = "yes"},
                    "scheduletimer",{"teardownmeteorite",6},
                },
            },
            teardownmeteorite = {
                {
                    "set",{meteoritewarned = "no"},
                },
            },
            engulftimer = {
                {
                    "expect",{"&listsize|engulfunits&",">","0"},
                    "alert","engulfwarn",
                },
            },
            blasttimer = {
                {
                    "expect",{"<castingblast>","==","yes"},
                    "expect",{"&unitguid|<blastsource>target&","==","&playerguid&"},
                    "announce","blastsay",
                    "set",{castingblast = "no"},
                },
            },
        },
        events = {
            -- Twilight Shift on Tanks
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 93051,
                execute = {
                    {
                        "quash","shiftcd",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{shifttext = format("%s on <%s>",SN[93051],L.alert["YOU"])},
                        "alert","shiftcd",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{shifttext = format("%s on <#5#>",SN[93051])},
                        "alert","shiftcd",
                    },
                },
            },
            -- Twilight Shift Dose on Tanks
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellid = 93051,
                execute = {
                    {
                        "quash","shiftcd",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{shifttext = format("%s (%s) on %s",SN[93051],"#11#",L.alert["YOU"])},
                        "alert","shiftcd",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{shifttext = format("%s (%s) on <%s>",SN[93051],"#11#","#5#")},
                        "alert","shiftcd",
                    },
                },
            },
            -- Devouring Flames
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 86840,
                execute = {
                    {
                        "alert","flamewarn",
                        "set",{breathwarned = "no"},
                        "quash","flamecd",
                        "alert","flamecd",
                        "expect",{"<dazzlingwarned>","==","yes"},
                        "set",{dazzlingwarned = "no"},
                    },
                },
            },
            -- Dazzling Destruction
            {                                             
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 86408,
                execute = {
                    {
                        "expect",{"<dazzlingwarned>","==","no"},
                        "set",{dazzlingwarned = "yes"},
                        "quash","flamecd",
                        "quash","dazzlecd",
                        "alert","dazzlewarn",
                        "expect",{"<breathwarned>","==","no"},
                        "alert","breathcd",
                        "set",{breathwarned = "yes"},
                        "alert",{"engulfcd",time = 2},
                    },
                },
            },
            -- Engulfing Magic
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 95639,
                execute = {
                    {
                        "raidicon","engulfmark",
                        "radar","engulfradar",
                        "expect",{"&timeleft|engulfcd&","<","1"},
                        "quash","engulfcd",
                        "alert","engulfcd",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "insert",{"engulfunits","#5#"},
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "insert",{"engulfunits",L.alert["YOU"]},
                    },
                    {
                        "expect",{"&listsize|engulfunits&","==","1"},
                        "scheduletimer",{"engulftimer",2},
                    },
                    {
                        "expect",{"&listsize|engulfunits&","==","<engulfmax>"},
                        "canceltimer","engulftimer",
                        "alert","engulfwarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","engulfselfduration",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 95639,
                execute = {
                    {
                        "removeradar",{"engulfradar", player = "#5#"},
                        "removeraidicon",{"#5#"}
                    },
                },
            },
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_bastion["begins to cast .+%[Engulfing Magic%].+"]},
                        "expect",{"&timeleft|engulfcd&","<","1"},
                        "quash","engulfcd",
                        "alert","engulfcd",
                    },
                },
            },
            -- Blackout
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 92876,
                execute = {
                    {
                        "raidicon","blackoutmark",
                        "quash","blackoutcd",
                        "alert","blackoutcd",
                        "radar","blackoutradar",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","blackoutselfwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "alert","blackoutdurationwarn",
                        "arrow","blackoutarrow",
                    },
                },
            },
            -- Blackout removal
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 92876,
                execute = {
                    {
                        "quash","blackoutdurationwarn",
                        "quash","blackoutselfwarn",
                        "removeraidicon","#5#",
                        "removearrow","#5#",
                        "removeradar",{"blackoutradar", player = "#5#"},
                    },
                },
            },
            -- Twilight Meteorite
            {
                type = "event",
                event = "UNIT_AURA",
                execute = {
                    {
                        "expect",{"#1#","==","player"},
                        "scheduletimer",{"firemeteorite",0.1},
                    },
                },
            },
            -- Twilight Blast
            {
                type = "event",
                event = "UNIT_SPELLCAST_START",
                execute = {
                    {
                        "expect",{"#2#","==",SN[86369]},
                        "expect",{"#1#","find","boss"},
                        "set",{
                            castingblast = "yes",
                            blastsource = "#1#",
                        },
                        "scheduletimer",{"blasttimer", 0.5},
                        "expect",{"<firstblastcast>","==","no"},
                        "set",{firstblastcast = "yes"},
                        "alert","dazzlecd",
                        "quash","engulfcd",
                        "expect",{"&timeleft|blackoutcd&","==","-1"},
                        "alert",{"blackoutcd",time = 3},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_TARGET",
                execute = {
                    {
                        "expect",{"<castingblast>","==","yes"},
                        "expect",{"#1#","==","<blastsource>"},
                        "expect",{"&unitguid|<blastsource>target&","==","&playerguid&"},
                        "canceltimer","blasttimer",
                        "announce","blastsay",
                        "set",{castingblast = "no"},
                    },
                },
            },
            -- Deep Breath
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_bastion["I will engulf the hallway"]},
                        "alert","breathwarn",
                        "set",{
                            firstblastcast = "no",
                            blackoutcd = {45.5, 0, loop = false, type = "series"}
                        },
                    },
                },
            },
            -- Fabulous Flames
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 86505,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","fabulousselfwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ASCENDANT COUNCIL
---------------------------------
do
    local data = {
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
                          "icewarn","waterbombcd","waterbombwarn","waterlogged","glaciatecd","glaciatewarn", -- Feludius
                          "corewarn","coreselfwarn", -- Terrastra
                          "overloadwarn","overloadselfwarn"} -- Arion
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
                time = 28,
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
                time = 15,
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
                time = 60,
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
                sound = "ALERT10",
                icon = ST[82643],
            },          
            -----------------------
            ------- Phase 2 -------
            -----------------------
            -- Harden Skin
            hardencd = {
                varname = format(L.alert["%s CD"],SN[92541]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[92541]),
                time = 42,
                time2 = 21,
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
                time = 31, -- 65
                time2 = 27, -- 30
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
                sound = "ALERT10",
                icon = ST[8385],
            },
            -- Thundershock
            shockcd = {
                varname = format(L.alert["%s CD"],SN[83067]),
                type = "dropdown",
                text = "Get Grounded",
                time = 36,
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
                sound = "ALERT10",
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
                time = 23,
                time2 = 24,
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
                time = 23,
                time2 = 16,
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
                        "alert","waterbombcd",
                        "alert","glaciatecd",
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
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 82746,
                execute = {
                    {
                        "quash","glaciatecd",
                        "alert","glaciatewarn",y
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
                    {
                        "expect",{"<phase>","<","3"},
                        "quashall",true,
                        "set",{phase = 3},
                        "alert","phasetransition",
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
                        "alert","crushcd",
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
                        "alert","lavaseedcd",
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
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- CHO'GALL
---------------------------------

do
    local data = {
        version = 13,
        key = "chogall",
        zone = L.zone["The Bastion of Twilight"],
        category = L.zone["The Bastion of Twilight"],
        name = L.npc_bastion["Cho'gall"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Chogall.blp",
        advanced = {
            preventPostDefeatPull = 5,
        },
        triggers = {
            scan = {
                43324, -- Cho'gall
            },
        },
        onactivate = {
            tracing = {43324},
            phasemarkers = {
                {
                    {0.85,"Fury of Cho'gall","The first Fury of Cho'gall cast."},
                    {0.25, "Phase 2","At 25 % of Cho'gall's health Phase 2 begins."},
                    {0.03, "Boss defeated","At 3 % of his health, Cho'gall is defeated.", 20},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 43324,
        },
        userdata = {
            adherenttime = {62, 91, loop = false, type = "series"},
            depravitycd = {19, 12, loop = false, type = "series"},
            crashcd = {12, 10, loop = false, type = "series"},
            creationstime = {6, 40, loop = false, type = "series"},
            conversiontime = 21,
            adherenttext = "Corrupting Adherent",
            firstfury = "yes",
            phase = 1,
            conversionmax = 2,
            conversionunits = {type = "container", wipein = 3},
        },
        onstart = {
            {
                "set",{phase = 1},
                "alert","enragecd",
                "expect",{"&difficulty&",">=","3"}, --10h&25h
                "set",{
                    adherenttime = {64, 92 ,loop = false, type = "series"},
                },
            },
            {
                "expect",{"&difficulty&","==","2"},
                "set",{conversionmax = 5},
            },
            {
                "expect",{"&difficulty&","==","4"},
                "set",{conversionmax = 5},
                adherenttext = "Corrupting Adherents",
            },
            {
                "alert",{"conversioncd",time = 2, text = 2},
                "repeattimer",{"checkhp", 1},
            },
        },
        announces = {
            crashsay = {
                type = "SAY",
                subtype = "self",
                spell = 93180,
                msg = format(L.alert["%s on ME!"],SN[93180]).."!",
            },
        },
        raidicons = {
            worshipmark = {
                varname = format("%s {%s}",SN[91317],"PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 5,
                reset = 5,
                unit = "#5#",
                icon = 1,
                total = 4,
                texture = ST[91317],
            },
            crashmark = {
                varname = format("%s {%s}",SN[93180],"ABILITY_TARGET_HARM"),
                type = "MULTIFRIENDLY",
                persist = 6,
                reset = 5,
                unit = "&upvalue&",
                icon = 5,
                total = 2,
                texture = ST[93180],
            },
        },
        filters = {
            bossemotes = {
                conversionemote = {
                    name = "Conversion",
                    pattern = "Cho'gall beckons and casts %[Conversion%]",
                    hasIcon = false,
                    hide = true,
                    texture = ST[91303],
                },
                summonadherentemote = {
                    name = "Summon Corrupting Adherent",
                    pattern = "Cho'gall begins to summon Corrupt",
                    hasIcon = true,
                    hide = true,
                    texture = ST[81628],
                },
                festerbloodemote = {
                    name = "Fester Blood",
                    pattern = "Cho'gall begins to cast %[Fester Blood%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[82299],
                },
                darkenedcreationsemote = {
                    name = "Summon Darkened Creations",
                    pattern = "Cho'gall begins to summon Darkened Creations",
                    hasIcon = true,
                    hide = true,
                    texture = ST[82414],
                },
            },
        },
        phrasecolors = {
            {"Corrupting Adherent:","GOLD"},
        },
        windows = {
            apbtext = "Corrupted Blood",
            apbwindow = true,
            proxwindow = true,
            proxrange = 30,
            proxoverride = true,
            nodistancecheck = true
        },
        radars = {
            crashradar = {
                varname = SN[93180],
                type = "circle",
                player = "#5#",
                fixed = true,
                range = 8,
                mode = "avoid",
                persist = 4,
                color = "MAGENTA",
                icon = ST[93180],
            },
        },
        misc = {
            args = {
                depravitytargetonly = {
                    name = format(L.chat_bastion["Show |T%s:16:16|t |cffffd600Depravity|r for target / focus only"],ST[81713]),
                    desc = format(L.chat_bastion["Show |T%s:16:16|t |cffffd600Depravity|r cooldown and warning only for the |cffffd600Corrupting Adherent|r in your target or focus."],ST[81713]),
                    type = "toggle",
                    order = 1,
                    default = true,
                },
                reset_button = addon:genmiscreset(10,"depravitytargetonly"),
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd","phasewarn"},
            },
            {
                name = format("|cffffd700%s|r","Cho'gall"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Chogall",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"conversioncd","conversionwarn","fireaddwarn","blazewarnself","shadowaddwarn","furysoon","furycd","furywarn","adherentcd","adherentwarn","festerbloodcd","festerbloodwarn",
                         "creationscd","creationswarn"}
            },
            {
                name = format("|cffffd700%s|r","Corrupting Adherent"),
                icon = "Interface\\ICONS\\Achievement_Boss_HeraldVolazj",
                alerts = {"crashcd","crashwarn","crashclosewarn","crashselfwarn","crashdmg","depravitycd","depravitywarn"},
            },
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time = 600,
                flashtime = 10,
                color1 = "RED",
                icon = ST[12317],
            },           
           -- Phases
            phasewarn = {
                varname = format(L.alert["Phase Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"<phase>"),
                time = 3,
                flashtime = 3,
                color1 = "TURQUOISE",
                icon = ST[11242],
                sound = "BEWARE",
            },
            -- Fury of Cho'gall
            furycd = {
                varname = format(L.alert["%s CD"],SN[82524]),
                type = "dropdown",
                text = format(L.alert["Next %s"], SN[82524]),
                time = 47,
                flashtime = 10,
                color1 = "CYAN",
                color2 = "TURQUOISE",
                icon = ST[82524],
                sticky = true,
            },
            furywarn = {
                varname = format(L.alert["%s Warning"],SN[82524]),
                type = "simple",
                text = format("%s!",SN[82524]),
                time = 3,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[82524],
            },
            -----------------------
            ------- Phase 1 -------
            -----------------------
            -- Flaming Destruction
            fireaddwarn = {
                varname = format(L.alert["%s Warning"],SN[93266]),
                type = "centerpopup",
                text = SN[93266],
                time10n = 10,
                time25n = 10,
                time10h = 10,
                time25h = 20.5,
                flashtime = 5,
                color1 = "ORANGE",
                sound = "ALERT1",
                icon = ST[93266],
            },
            -- Empowered Shadows
            shadowaddwarn = {
                varname = format(L.alert["%s Warning"],SN[93220]),
                type = "centerpopup",
                text = SN[93220],
                time10n = 9,
                time25n = 9,
                time10h = 9,
                time25h = 20.5,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                sound = "ALERT1",
                icon = ST[93220],
            },
            -- Blaze
            blazewarnself = {
                varname = format(L.alert["%s on me Warning"],SN[81538]),
                type = "simple",
                text = format("%s on %s - %s!",SN[81538],L.alert["YOU"],L.alert["MOVE AWAY"]),
                time = 3,
                flashtime = 3,
                throttle = 3,
                flashscreen = true,
                color1 = "RED",
                sound = "ALERT10",
                icon = ST[81538],
                emphasizewarning = true,
            },
            -- Conversion
            conversioncd = {
                varname = format(L.alert["%s CD"],SN[91303]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[91303]),
                text2 = format(L.alert["Next %s"],SN[91303]),
                time = "<conversiontime>",
                time2 = 10,
                time3 = 11,
                flashtime = 5,
                color1 = "YELLOW",
                icon = ST[91303],
                audiocd = true,
                sticky = true,
            },
            conversionwarn = {
                varname = format(L.alert["%s Warning"],SN[91303]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[91303],"&list|conversionunits&"),
                time = 3,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[91303],
            },
            -- Summon Corrupting Adherent
            adherentcd = {
                varname = format(L.alert["%s CD"],SN[81628]),
                type = "dropdown",
                text = format("New %s CD","<adherenttext>"),
                --time = "<adherenttime>",
                time = 92,
                time2 = 5.8,
                flashtime = 5,
                color1 = "CYAN",
                color2 = "BLUE",
                icon = ST[81628],
                sticky = true,
            },
            adherentwarn = {
                varname = format(L.alert["%s Warning"],SN[81628]),
                type = "simple",
                text = format("New: %s","<adherenttext>"),
                time = 3,
                flashtime = 3,
                color1 = "RED",
                sound = "ALERT2",
                icon = ST[81628],
            },
            furysoon = {
                varname = format(L.alert["%s soon"],SN[82524]),
                type = "simple",
                text = format(L.alert["%s soon"],SN[82524]),
                time = 5,
                flashtime = 5,
                color1 = "CYAN",
                sound = "ALERT3",
                icon = ST[82524],
            },
            -- Fester Blood
            festerbloodcd = {
                varname = format(L.alert["%s CD"],SN[82299]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[82299]),
                time = 40,
                flashtime = 5,
                color1 = "MAGENTA",
                icon = ST[82299],
            },
            festerbloodwarn = {
                varname = format(L.alert["%s Warning"],SN[82299]),
                type = "simple",
                text = SN[82299].."!",
                color1 = "RED",
                sound = "MINORWARNING",
                time = 3,
                flashtime = 3,
                icon = ST[82299],
            },
            -- Corrupting Crash
            crashcd = {
                varname = format(L.alert["%s CD"],SN[93180]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[93180]),
                time = "<crashcd>",
                flashtime = 5,
                color1 = "PINK",
                icon = ST[93180],
                tag = "#1#",
            },
            crashwarn = {
                varname = format(L.alert["%s Warning"],SN[93180]),
                type = "simple",
                text = format("%s on <%s>",SN[93180],"#5#"),
                time = 4,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[93180],
                tag = "#1#",
            },
            crashselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[93180]),
                type = "simple",
                text = format("%s on <%s>!",SN[93180],L.alert["YOU"]),
                time = 4,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[93180],
                emphasizewarning = true,
            },
            crashclosewarn = {
                varname = format(L.alert["%s near me Warning"],SN[93180]),
                type = "simple",
                text = format(L.alert["%s near %s - MOVE AWAY!"],SN[93180],L.alert["YOU"]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT10",
                icon = ST[93180],
            },
            -- Depravity
            depravitywarn = {
                varname = format(L.alert["%s Warning"],SN[81713]),
                type = "centerpopup",
                warningtext = format("%s: %s - INTERRUPT!","Corrupting Adherent",SN[81713]),
                text = format("%s: %s","Corrupting Adherent",SN[81713]),
                time = 1.5,
                color1 = "GOLD",
                sound = "ALERT10",
                icon = ST[81713],
                tag = "#1#",
            },
            depravitycd = {
                varname = format(L.alert["%s CD"],SN[81713]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[81713]),
                time = "<depravitycd>",
                flashtime = 3,
                color1 = "PINK",
                icon = ST[81713],
                tag = "#1#",
            },
            -----------------------
            ------- Phase 2 -------
            -----------------------
            creationscd = {
                varname = format(L.alert["%s CD"],SN[82414]),
                type = "dropdown",
                text = format(L.alert["New %s"],SN[82414]),
                time = "<creationstime>",
                flashtime = 5,
                color1 = "PURPLE",
                icon = ST[82414],
            },
            creationswarn = {
                varname = format(L.alert["%s Warning"],SN[82414]),
                type = "simple",
                text = format("New: %s",SN[82414]),
                time = 3,
                flashtime = 3,
                color1 = "MAGENTA",
                sound = "ALERT1",
                icon = ST[82414],
            },
            
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","88"},
                    "alert","furysoon",
                    "canceltimer","checkhp",
                },
            },
            conversiontimer = {
                {
                    "expect",{"&listsize|conversionunits&",">","0"},
                    "alert","conversionwarn",
                },
            },
        },
        events = {
            -- Summon Corrupting Adherent
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 81628,
                execute = {
                    {
                        "set",{
                            conversiontime = 37,
                            crashcd = {12, 10, loop = false, type = "series"},
                            depravitycd = {9, 12, loop = false, type = "series"},
                        },
                        "quash","adherentcd",
                        "alert","adherentcd",
                        "alert","adherentwarn",
                        "alert","festerbloodcd",
                        "alert","depravitycd",
                        "alert","crashcd",
                    },
                },
            },
            -- Shadow Crash
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 93180,
                execute = {
                    {
                        "alert","crashcd",          
                        "raidicon","crashmark",
                        "radar","crashradar",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","crashselfwarn",
                        "announce","crashsay",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "alert","crashwarn",
                        "expect",{"&getdistance|#4#&","<=",10},
                        "alert","crashclosewarn",
                    },
                },
            },
            -- Depravity
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = {
                    81713,
                    93175,
                    93176,
                    93177,
                },
                execute = {
                    {
                        "invoke",{
                            {
                                "expect",{"&itemvalue|depravitytargetonly&","==","false"},
                                "alert","depravitywarn",
                                "alert","depravitycd",
                            },
                            {
                                "expect",{"&itemvalue|depravitytargetonly&","==","true"},
                                "expect",{"#1#","==","&unitguid|target&",
                                     "OR","#1#","==","&unitguid|focus&"},
                                "alert","depravitywarn",
                                "alert","depravitycd",
                            },
                        },
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[93176]},
                        "quash",{"depravitywarn","&unitguid|#1#&"},
                    },
                },
            },
            
            -- Corrupting Adherent's Death
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","43622"},
                        "quash",{"crashcd","#4#"},
                        "quash",{"depravitycd","#4#"},
                        "quash",{"depravitywarn","#4#"},
                    },
                },
            },
            
            -- Fury of Cho'gall
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 82524,
                execute = {
                    {
                        "alert","furywarn",
                        "quash","furycd",          
                        "alert","furycd",
                    },
                    {
                        "expect",{"<firstfury>","==","yes"},
                        "set",{firstfury = "no"},
                        "alert",{"adherentcd", time = 2},
                        "quash","conversioncd",
                        "alert",{"conversioncd",time = 2, text = 2},
                    },
                },
            },
            -- Festerblood
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 82299,
                execute = {
                    {
                        "quash","festerbloodcd",
                        "alert","festerbloodwarn",
                    },
                },
            },
            -- Conversion / Worshipping
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 93367,
                srcisplayertype = true,
                execute = {
                    {
                        "raidicon","worshipmark",
                        "insert",{"conversionunits","#5#"},
                    },
                    {
                        "expect",{"&listsize|conversionunits&","==","1"},
                        "scheduletimer",{"conversiontimer",1},
                        "quash","conversioncd",          
                        "alert","conversioncd",
                    },
                    {
                        "expect",{"&listsize|conversionunits&","==","<conversionmax>"},
                        "canceltimer","conversiontimer",
                        "alert","conversionwarn",
                    },
                },
            },
            -- Blaze
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 81538,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","blazewarnself",
                    },
                },
            },
            -- Phase 2 (Consume Blood of the Old God)
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 82630,
                execute = {
                    {
                        "quashall",{"enragecd","furycd"},
                        "set",{phase = 2},
                        "alert","phasewarn",
                        "alert","creationscd",
                    },
                },
            },
            -- Darkened Creations
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = {
                    82414,
                    93160,
                    93161,
                    93162,
                },
                execute = {
                    {
                        "alert","creationswarn",          
                        "quash","creationscd",
                        "alert","creationscd",
                    },
                },
            },
            -- Flame Orders
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = {
                    81194,
                    93264,
                    93265,
                    93266,
                },
                execute = {
                    {
                        "alert","fireaddwarn",
                    },
                },
            },
            -- Shadow Orders
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = {
                    81572,
                    93218,
                    93219,
                    93220,           
                },
                execute = {
                    {
                        "alert","shadowaddwarn",
                    },
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- LADY SINESTRA
---------------------------------

do
    local data = {
        version = 3,
        key = "sinestra",
        zone = L.zone["The Bastion of Twilight"],
        category = L.zone["The Bastion of Twilight"],
        name = L.npc_bastion["Lady Sinestra"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Sinestra.blp",
        advanced = {
            preventPostDefeatPull = 5,
        },
        triggers = {
            scan = {
                45213, -- Sinestra
            },
        },
        onactivate = {
            tracing = {45213},
            phasemarkers = {
                {
                    {0.3,"Phase 2","At 30% of Sinestra's HP, she protects herself with a shield and Phase 2 begins."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 45213,
        },
        userdata = {
            slicercd = {27,27, loop = false, type = "series"},
            slicerdelay = {27,27, loop = false, type = "series"}, 
            wracktext = "",
            phase = "",
            eggstraced = "no",
            eggsunits = {type = "container", wipein = 10},
        },
        onstart = {
            {
                "alert",{"whelpscd",time = 2},
                "alert","breathcd",
                "alert","slicercd",
                "scheduletimer",{"slicer","<slicerdelay>"},
                "alert",{"wrackcd",time = 2},
                "set",{phase = "1"},
            },
        },
        
        raidicons = {
            eggsmark = {
                varname = format("%s {%s}","Twilight Pulsing Eggs","NPC_ENEMY"),
                type = "MULTIENEMY",
                persist = 60,
                unit = "#1#",
                reset = 300,
                icon = 5,
                total = 2,
                texture = ST[87654],
            },
        },
        phrasecolors = {
            {"imminent","LIGHTGREEN"},
        },
        ordering = {
            alerts = {"phasewarn","wrackcd","wrackwarn","whelpscd","breathcd","breathwarn","slicercd","slicerwarn","eggwarn","essencecountdown","essencewarn"}
        },
        
        alerts = {
            breathcd = {
                varname = format(L.alert["%s CD"],SN[92944]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[92944]),
                time = 21,
                flashtime = 10,
                flashscreen = true,
                color1 = "ORANGE",
                color2 = "RED",
                icon = ST[92944],
                sound = "MINORWARNING",
                sticky = true,
            },
            breathwarn = {
                varname = format(L.alert["%s Warning"],SN[92944]),
                type = "simple",
                text = format(L.alert["%s"],SN[92944]),
                time = 3,
                flashtime = 3,
                color1 = "ORANGE",
                icon = ST[92944],
                sound = "ALERT1",
            },
            slicercd = {
                varname = format(L.alert["%s CD"],SN[92954]),
                type = "dropdown",
                text = format(L.alert["Next Shadow Orbs"],SN[92954]),
                time = "<slicercd>",
                time2 = 10,
                flashtime = 5,
                audiocd = true,
                color1 = "PURPLE",
                icon = ST[92954],
            },
            slicerwarn = {
                varname = format(L.alert["%s Warning"],SN[92954]),
                type = "simple",
                text = format(L.alert["Shadow Orbs imminent!"],SN[92954]),
                time = 3,
                flashtime = 3,
                color1 = "MAGENTA",
                icon = ST[92954],
                sound = "ALERT2",
            },
            wrackcd = {
                varname = format(L.alert["%s CD"],SN[92955]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92955]),
                time = 70,
                time2 = 15,
                flashtime = 5,
                color1 = "BLACK",
                icon = ST[92955],
            },
            wrackwarn = {
                varname = format(L.alert["%s Warning"],SN[92955]),
                type = "simple",
                text = "<wracktext>",
                time = 3,
                flashtime = 3,
                color1 = "BLACK",
                icon = ST[92955],
                sound = "ALERT3",
            },
            phasewarn = {
                varname = format(L.alert["Phase Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"<phase>"),
                time = 5,
                flashtime = 5,
                icon = ST[11242],
                color1 = "TURQUOISE",
                sound = "BEWARE",
            },
            eggwarn = {
                varname = format(L.alert["Eggs Vulnerable Warning"]),
                type = "centerpopup",
                text = format(L.alert["Eggs vulnerable"]),
                time = 30,
                flashtime = 5,
                color1 = "PINK",
                sound = "ALERT10",
                icon = ST[87654],
                throttle = 2,
                emphasizewarning = true,
            },
            whelpscd = {
                varname = format(L.alert["%s CD"],"Twilight Whelps"),
                type = "dropdown",
                text = format(L.alert["New Twilight Whelps"]),
                time = 50,
                time2= 16,
                flashtime = 5,
                color1 = "PURPLE",
                sound = "MINORWARNING",
                icon = ST[10695],
            },
            essencecountdown = {
                varname = format(L.alert["%s Countdown"],SN[87946]),
                type = "dropdown",
                text = format(L.alert["%s applied in"],SN[87946]),
                time = 22,
                flashtime = 10,
                color1 = "GOLD",
                icon = ST[87946],      
            },
            essencewarn = {
                varname = format(L.alert["%s Warning"],SN[87946]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[87946]),
                time = 180,
                flashtime = 20,
                color1 = "RED",
                icon = ST[87946],
            },
        },
        timers = {
            slicer = {
                {
                    "alert","slicercd",
                    "alert","slicerwarn",
                    "scheduletimer",{"slicer","<slicerdelay>"},
                },
            },
            spitecaller = {
                {
                    "alert","spiteinc",
                    "scheduletimer",{"spitecaller",22},
                },
            },
            eggstimer = {
                {
                    "temptracing","<eggsunits>",
                },
            },
        },
        events = {
            -- Flame Breath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92944,
                execute = {
                    {
                        "quash","breathcd",
                        "alert","breathcd",
                        "alert","breathwarn",
                    },
                },
            },
            -- Wrack
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = {89421},
                execute = {
                    {
                        "alert","wrackcd",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{wracktext = format(L.alert["%s on <%s>"],SN[92955],L.alert["YOU"])},
                        "alert","wrackwarn",
                    },
                },
            },
            -- Mana Barrier == Phase 2 starting
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 87299,
                execute = {
                    {
                        "batchquash",{"breathcd","slicercd","whelpscd"},
                        "canceltimer","slicer",
                        "set",{phase = "2"},
                        "alert","phasewarn",
                        "removephasemarker",{1,1},
                    },
                },
            },
            -- Eggs vulnerable
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 87654,
                execute = {
                    {
                        "alert","eggwarn",
                    },
                },
            },
            -- Essence of the Red
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 87946,
                execute = {
                    {
                        "alert","essencewarn",
                    },
                },
            },
            -- Twilight Pulsing Eggs tracing
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 87654,
                execute = {
                    {
                        "expect",{"#2#","==","Pulsing Twilight Egg"},
                        "raidicon","eggsmark",
                        "expect",{"<eggstraced>","==","no"},
                        "insert",{"eggsunits","#1#"},
                        "expect",{"&listsize|eggsunits&","==","2"},
                        "set",{eggstraced = "yes"},
                        "scheduletimer",{"eggstimer",1},
                    },
                },
            },
            {
                type = "event",
                event = "YELL",
                execute = {
                    -- Summoning Whelps
                    {
                        "expect",{"#1#","find",L.chat_bastion["^Feed, children"]},
                        "alert","whelpscd",
                    },
                    -- Phase 3 trigger
                    {
                        "expect",{"#1#","find",L.chat_bastion["^Enough!"]},
                        "quash","eggwarn",
                        "set",{phase = "3"},
                        "alert","phasewarn",
                        "set",{slicercd = {30,28, loop = false, type = "series"}},
                        "set",{slicerdelay = {30,28, loop = false, type = "series"}},            
                        "alert","slicercd",
                        "scheduletimer",{"slicer","<slicerdelay>"},
                        "alert","breathcd",
                        "alert","essencecountdown",
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
        key = "bottrash",
        zone = L.zone["The Bastion of Twilight"],
        category = L.zone["The Bastion of Twilight"],
        name = "Trash",
        triggers = {
            scan = {
                -- Bastion Antechamber
                45261, -- Twlight Shadow Knight
                45264, -- Twilight Crossfire
                45265, -- Twilight Soul Blade
                45266, -- Twilight Dark Mender
                
                -- The Burning Corridor
                47087, -- Azureborne Destroyer
                47086, -- Crimsonborne Firestarter
                47161, -- Twilight Brute
                
                47150, -- Earth Ravager
                47152, -- Twilight Elementalist
                47081, -- Elemental Firelord
                47151, -- Wind Breaker
            
                -- Sanctum of the Ascended
                49821, -- Bound Zephyr
                49825, -- Bound Deluge
                49817, -- Bound Inferno
                49826, -- Bound Rumbler
                
                -- Throne of the Apocalypse
                45687, -- Twilight-Shifter
                45699, -- Twilight Shadow Mender
                45700, -- Twilight Portal Shaper
                45703, -- Faceless Minion
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
            {"Twilight Dark Mender:","GOLD"},
            {"Crimsonborne Firestarter:","GOLD"},
            {"PULL","YELLOW"},
            {"Azureborne Destroyer","GOLD"},
            {"Crimsonborne Firestarter","GOLD"},
            {"Twilight Brute","GOLD"},
            {"Twilight Portal Shaper:","GOLD"},
            {"Twilight%-","GOLD"},
            {"Shifter","GOLD"},
        },
        raidicons = {
            flamestrikemark = {
                varname = format("%s {%s}",SN[93362],"ABILITY_TARGET_HARM"),
                type = "MULTIFRIENDLY",
                persist = 5,
                unit = "<flamestriketarget>",
                reset = 5,
                total = 3,
                icon = 1,
                texture = ST[93362],
            },
        },
        announces = {
            flamestrikesay = {
				type = "SAY",
                subtype = "self",
                spell = 93362,
				msg = format(L.alert["{circle} %s on ME! {circle}"],SN[93362]),
			},
        },
        grouping = {
            {
                name = "Bastion Antechamber",
                alerts = {"darkpoolwarn","dismantleselfwarn","dismantlewarn","mendingwarn","hungerwarn"}
            },
            {
                name = "The Burning Corridor",
                alerts = {"crimsonflameswarn","crimsonflamescast","crimsonflamestankwarn","crimsonflameselfwarn","whirlingbladesselfwarn","petrifywarn"}
            },
            {
                name = "Throne of the Apocalypse",
                alerts = {"shapeportalwarn","shapeportalcast","twilightshiftwarn","twilightshiftduration"},
            },
        },
        
        alerts = {
            darkpoolwarn = {
                varname = format(L.alert["%s on me Warning"],SN[84853]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[84853],L.alert["YOU"]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[84853],
                emphasizewarning = true,
                throttle = 2,
            },
            -- Dismantle
            dismantleselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[84832]),
                type = "centerpopup",
                text = format(L.alert["%s on %s"],SN[84832],L.alert["YOU"]),
                time = 6,
                color1 = "ORANGE",
                sound = "ALERT11",
                icon = ST[84832],
                throttle = 2,
            },
            dismantlewarn = {
                varname = format(L.alert["%s Warning"],SN[84832]),
                type = "centerpopup",
                text = format(L.alert["%s on <%s>"],SN[84832],"#5#"),
                time = 6,
                color1 = "ORANGE",
                sound = "ALERT11",
                icon = ST[84832],
                tag = "#4#",
                enabled = {
                    Heal = true,
                    Tank = true,
                },
            },
            -- Dark Mending
            mendingwarn = {
                varname = format(L.alert["%s Warning"],SN[84855]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT"],SN[84855]),
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Twilight Dark Mender",SN[84855]),
                time = 2,
                color1 = "TURQUOISE",
                sound = "ALERT2",
                icon = ST[84855],
                tag = "#1#",
            },
            -- Hungering Shadows
            hungerwarn = {
                varname = format(L.alert["%s Warning"],SN[84856]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT"],SN[84856]),
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Twilight Dark Mender",SN[84856]),
                time = 4,
                color1 = "INDIGO",
                sound = "ALERT7",
                icon = ST[84856],
                tag = "&unitguid|#1#&",
            },
            --------------------------
            -- The Burning Corridor --
            --------------------------
            -- Crimson Flames
            crimsonflameswarn = {
                varname = format(L.alert["%s Warning"],SN[88226]),
                type = "simple",
                text = format(L.alert["%s: %s - INTERRUPT"],"Crimsonborne Firestarter",SN[88226]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT2",
                icon = ST[88226],
            },
            crimsonflamescast = {
                varname = format(L.alert["%s Cast"],SN[88226]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT"],SN[88226]),
                time = 1.5,
                color1 = "MAGENTA",
                sound = "None",
                icon = ST[88226],
                tag = "#1#",
            },
            crimsonflameselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[88226]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[88226],L.alert["YOU"]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[88226],
                emphasizewarning = true,
                throttle = 2,
            },
            crimsonflamestankwarn = {
                varname = format(L.alert["%s on mobs Warning"],SN[88226]),
                type = "simple",
                text = format(L.alert["%s - PULL %s AWAY"],SN[88226],"#5#"),
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[88226],
                throttle = 2,
            },
            whirlingbladesselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[88136]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[88136],L.alert["YOU"]),
                time = 1,
                color1 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[88136],
                emphasizewarning = true,
                throttle = 2,
                enabled = {DPS = true, Heal = true},
            },
            -- Petrify Skin
            petrifywarn = {
                varname = format(L.alert["%s Warning"],SN[87917]),
                type = "centerpopup",
                text = format(L.alert["%s on %s"],SN[87917],"<petrifyunit>"),
                warningtext = format(L.alert["%s on %s - DISPEL"],SN[87917],"<petrifyunit>"),
                time = 10,
                color1 = "ORANGE",
                sound = "ALERT8",
                icon = ST[87917],
                tag = "#4#",
            },
            ------------------------------
            -- Throne of the Apocalypse --
            ------------------------------
            -- Shape Portal
            shapeportalwarn = {
                varname = format(L.alert["%s Warning"],SN[85529]),
                type = "simple",
                text = format(L.alert["%s: %s - INTERRUPT"],"Twilight Portal Shaper",SN[85529]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT9",
                icon = ST[85529],
            },
            shapeportalcast = {
                varname = format(L.alert["%s Cast"],SN[85529]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT"],SN[85529]),
                time = 10,
                color1 = "MAGENTA",
                sound = "None",
                icon = ST[85529],
                tag = "#4#",
            },
            -- Twilight Shift
            twilightshiftwarn = {
                varname = format(L.alert["%s Warning"],SN[85556]),
                type = "simple",
                text = format(L.alert["%s on %s - DISPEL"],SN[85556],"#5#"),
                time = 1,
                color1 = "PURPLE",
                sound = "ALERT8",
                icon = ST[85556],
            },
            twilightshiftduration = {
                varname = format(L.alert["%s Duration"],SN[85556]),
                type = "centerpopup",
                text = format(L.alert["%s on %s"],SN[85556],"#5#"),
                time = 15,
                color1 = "MAGENTA",
                sound = "None",
                icon = ST[85556],
                tag = "#4#",
            },
            
        },
        timers = {
            flamestriketimer = {
                {
                    "set",{flamestriketarget = "&gettarget|#1#&"},
                    "raidicon","flamestrikemark",
                    "expect",{"<flamestriketarget>","==","&unitname|player&"},
                    "announce","flamestrikesay",
                },
            },
        },
        events = {
            -------------------------
            -- Bastion Antechamber --
            -------------------------
            -- Dark Pool
            {
                type = "combatevent",
                eventtype = "SPELL_PERIODIC_DAMAGE",
                spellname = 84853,
                dstisplayertype = true,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","darkpoolwarn",
                    },
                },
            },
            -- Dismantle
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 84832,
                dstisplayertype = true,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "quash",{"dismantleselfwarn","#4#"},
                        "alert","dismantleselfwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "quash",{"dismantlewarn","#4#"},
                        "alert","dismantlewarn",
                    },
                },
            },
            -- Dark Mending
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 84855,
                execute = {
                    {
                        "alert","mendingwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_STOP",
                execute = {
                    {
                        "expect",{"#2#","==",SN[84855]},
                        "quash",{"mendingwarn","&unitguid|#1#&"},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[84855]},
                        "quash",{"mendingwarn","&unitguid|#1#&"},
                    },
                },
            },
            
            -- Hungering Shadows
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[84856]},
                        "expect",{"#1#","==","target"},
                        "alert","hungerwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_CHANNEL_STOP",
                execute = {
                    {
                        "expect",{"#2#","==",SN[84856]},
                        "quash",{"hungerwarn","&unitguid|#1#&"},
                    },
                },
            },
            
            --------------------------
            -- The Burning Corridor --
            --------------------------
            -- Crimson Flames
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 88226,
                execute = {
                    {
                        "alert","crimsonflameswarn",
                        "alert","crimsonflamescast",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_STOP",
                execute = {
                    {
                        "expect",{"#2#","==",SN[88226]},
                        "quash",{"crimsonflamescast","&unitguid|#1#&"},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[88226]},
                        "quash",{"crimsonflamescast","&unitguid|#1#&"},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 88232,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","crimsonflameselfwarn",
                    },
                },
            },
            
            {
                type = "combatevent",
                eventtype = "SPELL_HEAL",
                spellname = 93349,
                execute = {
                    {
                        "alert","crimsonflamestankwarn",
                    },
                },
            },
            -- Whirling Blades
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 88136,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","whirlingbladesselfwarn",
                    },
                },
            },
            -- Petrify Skin
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 87917,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{petrifyunit = format("%s",L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{petrifyunit = format("<%s>","#5#")},
                    },
                    {
                        "alert","petrifywarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REFRESH",
                spellname = 87917,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{petrifyunit = format("%s",L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{petrifyunit = format("<%s>","#5#")},
                    },
                    {
                        "quash",{"petrifywarn","#4#"},
                        "alert","petrifywarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 87917,
                execute = {
                    {
                        "quash",{"petrifywarn","#4#"},
                    },
                },
            },
            
            -----------------------------
            -- Sanctum of the Ascended --
            -----------------------------
            -- Flamestrike
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 93362,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","49817"},
                        "scheduletimer",{"flamestriketimer", 0.1},
                    },
                },
            },
            
            ------------------------------
            -- Throne of the Apocalypse --
            ------------------------------
            -- Shape Portal
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 85529,
                execute = {
                    {
                        "alert","shapeportalwarn",
                        "alert","shapeportalcast",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 85529,
                execute = {
                    {
                        "quash",{"shapeportalcast","#4#"},
                    },
                },
            },
            -- Twilight Shift
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 85556,
                execute = {
                    {
                        "alert","twilightshiftwarn",
                        "alert","twilightshiftduration",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 85556,
                execute = {
                    {
                        "quash",{"twilightshiftduration","#4#"},
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end
