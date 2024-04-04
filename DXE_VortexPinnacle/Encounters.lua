local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- GRAND VIZIER ERTAN
---------------------------------

do
    local data = {
        version = 3,
        key = "ertan",
        zone = L.zone["The Vortex Pinnacle"],
        category = L.zone["The Vortex Pinnacle"],
        name = "Grand Vizier Ertan",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Grand Vizier Ertan.blp",
        triggers = {
            scan = {
                43878, -- Grand Vizier Ertan
            },
        },
        onactivate = {
            tracing = {
                43878,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 43878,
        },
        userdata = {
            cyclonescd = {12, 30, loop = false, type = "series"},
        },
        onstart = {
            {
                "alert","cyclonescd",
            },
        },
        
        filters = {
            bossemotes = {
                shieldemote = {
                    name = "Cyclone Shield retracted",
                    pattern = "retracts its cyclone shield",
                    hasIcon = false,
                    hide = true,
                    texture = ST[83612],
                },
            },
        },
        ordering = {
            alerts = {"tempestwarn","cyclonescd","cycloneswarn","cycloneduration"},
        },
        
        alerts = {            
            -- Call Cyclones
            cyclonescd = {
                varname = format(L.alert["%s CD"],SN[83612]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[83612]),
                time = "<cyclonescd>",
                flashtime = 5,
                color1 = "TEAL",
                color2 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[83612],
            },
            cycloneswarn = {
                varname = format(L.alert["%s Warning"],SN[83612]),
                type = "simple",
                text = format(L.alert["%s"],SN[83612]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT2",
                icon = ST[83612],
            },
            cycloneduration = {
                varname = format(L.alert["%s Duration"],SN[83612]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[83612]),
                time = 9,
                flashtime = 5,
                color1 = "CYAN",
                sound = "None",
                icon = ST[83612],
            },
            -- Summon Tempest
            tempestwarn = {
                varname = format(L.alert["%s Warning"],SN[86340]),
                type = "simple",
                text = format(L.alert["New: %s"],"Lurking Tempest"),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT9",
                icon = ST[86340],
            },
        },
        events = {
			-- Summon Tempest
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 86340,
                execute = {
                    {
                        "alert","tempestwarn",
                    },
                },
            },
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_vortexpinnacle["retracts its"]},
                        "alert","cyclonescd",
                        "alert","cycloneduration",
                        "alert","cycloneswarn",
                    },
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ALTAIRUS
---------------------------------

do
    local data = {
        version = 2,
        key = "altairus",
        zone = L.zone["The Vortex Pinnacle"],
        category = L.zone["The Vortex Pinnacle"],
        name = "Altairus",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Altairus.blp",
        triggers = {
            scan = {
                43873, -- Altairus
            },
        },
        onactivate = {
            tracing = {
                43873,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 43873,
        },
        userdata = {
            breathcd = {20, 7, loop = false, type = "series"},
            breathcasting = "no",
            breathunit = "",
        },
        onstart = {
            {
                "alert","breathcd",
            },
        },
        
        raidicons = {
            breathmark = {
                varname = format("%s {%s}",SN[93989],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 3,
                unit = "<breathunit>",
                reset = 3,
                icon = 1,
                texture = ST[93989],
            },
        },
        filters = {
            bossemotes = {
                windemote = {
                    name = "Wind change",
                    pattern = "wind abruptly shifts direction",
                    hasIcon = false,
                    hide = true,
                    texture = ST[52814],
                },
            },
        },
        ordering = {
            alerts = {"upwindwarn","downwindwarn","breathcd","breathwarn"},
        },
        
        alerts = {
            -- Chilling Breath
            breathcd = {
                varname = format(L.alert["%s CD"],SN[88322]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[88322]),
                time = "<breathcd>",
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[88322],
                sticky = true,
            },
            breathwarn = {
                varname = format(L.alert["%s Warning"],SN[88322]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[88322]),
                time = 2,
                color1 = "CYAN",
                sound = "ALERT8",
                icon = ST[88322],
            },
            -- Upwind of Altairus
            upwindwarn = {
                varname = format(L.alert["%s on me Warning"],SN[88282]),
                type = "simple",
                text = format(L.alert["%s"],SN[88282]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "BURST",
                icon = ST[88282],
            },
            -- Downwind of Altairus
            downwindwarn = {
                varname = format(L.alert["%s on me Warning"],SN[88286]),
                type = "simple",
                text = format(L.alert["%s"],SN[88286]),
                time = 1,
                color1 = "RED",
                sound = "ALERT2",
                icon = ST[88286],
            },
        },
        events = {
			-- Chilling Breath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 93989,
                execute = {
                    {
                        "set",{breathcasting = "yes"},
                        "quash","breathcd",
                        "alert","breathcd",
                        "alert","breathwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_TARGET",
                execute = {
                    {
                        "expect",{"#1#","==","boss1"},
                        "expect",{"<breathcasting>","==","yes"},
                        "set",{
                            breathunit = "&unitname|boss1target&",
                            breathcasting = "no",
                        },
                        "raidicon","breathmark",
                    },
                },
            },
            
            -- Upwind of Altairus
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 88282,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","upwindwarn",
                    },
                },
            },
            -- Downwind of Altairus
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 88286,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","downwindwarn",
                    },
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ASAAD
---------------------------------

do
    local data = {
        version = 3,
        key = "asaad",
        zone = L.zone["The Vortex Pinnacle"],
        category = L.zone["The Vortex Pinnacle"],
        name = "Asaad",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Asaad.blp",
        triggers = {
            scan = {
                43875, -- Asaad, Caliph of Zephyrs
            },
        },
        onactivate = {
            tracing = {
                43875,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 43875,
        },
        userdata = {
            fieldcd = {20, 24.5, loop = false, type = "series"},
            secondstorm = "no",
        },
        onstart = {
            {
                "alert","fieldcd",
            },
        },
        
        filters = {
            bossemotes = {
                fieldmsg = {
                    name = "Unstable Grounding Field",
                    pattern = "Asaad conjures a temporary",
                    hasIcon = false,
                    hide = true,
                    texture = ST[86911],
                },
            },
        },
        ordering = {
            alerts = {"staticwarn","fieldcd","fieldwarn","stormwarn","stormduration"},
        },
        
        alerts = {
            -- Static Cling
            staticwarn = {
                varname = format(L.alert["%s Warning"],SN[87618]),
                type = "centerpopup",
                text = format(L.alert["%s - JUMP!"],SN[87618]),
                time = 1.25,
                color1 = "ORANGE",
                sound = "ALERT8",
                icon = ST[87618],
                emphasizewarning = true,
            },
            -- Unstable Grounding Field
            fieldcd = {
                varname = format(L.alert["%s CD"],SN[86911]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[86911]),
                time = "<fieldcd>",
                flashtime = 5,
                color1 = "TEAL",
                color2 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[86911],
            },
            fieldwarn = {
                varname = format(L.alert["%s Warning"],SN[86911]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[86911]),
                time = 10, -- 7.75,
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "RED",
                sound = "BEWARE",
                icon = ST[86911],
                audiocd = true,
            },
            -- Supremacy of the Storm
            stormwarn = {
                varname = format(L.alert["%s Warning"],SN[86930]),
                type = "simple",
                text = format(L.alert["%s"],SN[86930]),
                time = 6,
                color1 = "LIGHTBLUE",
                sound = "ALERT2",
                icon = ST[86930],
            },
            stormduration = {
                varname = format(L.alert["%s Duration"],SN[86930]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[86930]),
                time = 6,
                color1 = "LIGHTBLUE",
                sound = "None",
                icon = ST[86930],
            },
        },
        timers = {
            disablestorm = {
                {
                    "set",{secondstorm = "yes"},
                },
            },
        },
        events = {
            -- Static Cling
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 87618,
                execute = {
                    {
                        "alert","staticwarn",
                    },
                },
            },
            -- Unstable Grounding Field
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 86911,
                execute = {
                    {
                        "quash","fieldcd",
                        "alert","fieldwarn",
                        "schedulealert",{"fieldcd", 26},
                    },
                },
            },
            -- Supremacy of the Storm
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = 86930,
                execute = {
                    {
                        "alert","stormwarn",
                        "alert","stormduration",
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
        key = "vortexpinnacletrash",
        zone = L.zone["The Vortex Pinnacle"],
        category = L.zone["The Vortex Pinnacle"],
        name = "Trash",
        triggers = {
            scan = {
                45924, -- Turbulent Squall
                45935, -- Temple Adept
                45930, -- Minister of Air
                45926, -- Servant of Asaad
                45928, -- Executor of the Caliph
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {},
        
        raidicons = {
            cloudburstmark = {
                varname = format("%s {%s-%s}",SN[92760],"ENEMY_CAST","Turbulent Squall's"),
                type = "MULTIENEMY",
                persist = 10,
                unit = "#1#",
                reset = 6,
                icon = 1,
                total = 4,
                texture = ST[92760],
            },
        },
        phrasecolors = {
            {"Turbulent Squall:","GOLD"},
            {"Temple Adept:","GOLD"},
        },
        
        alerts = {
            -- Cloudburst
            cloudburstwarn = {
                varname = format(L.alert["%s Warning"],SN[92760]),
                type = "simple",
                text = format(L.alert["%s: %s - INTERRUPT"],"Turbulent Squall",SN[92760]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT2",
                icon = ST[92760],
                throttle = 1,
            },
            cloudburstcast = {
                varname = format(L.alert["%s Cast"],SN[92760]),
                type = "dropdown",
                text = format(L.alert["%s - INTERRUPT"],SN[92760]),
                time = 4,
                color1 = "CYAN",
                sound = "None",
                icon = ST[92760],
                tag = "#1#",
            },
            -- Greater Heal
            greaterhealwarn = {
                varname = format(L.alert["%s Warning"],SN[92770]),
                type = "centerpopup",
                warningtext = format(L.alert["%s: %s - INTERRUPT!"],"Temple Adept",SN[92770]),
                text = format(L.alert["%s - INTERRUPT!"],SN[92770]),
                time = 2.5,
                color1 = "WHITE",
                color2 = "YELLOW",
                sound = "ALERT2",
                icon = ST[92770],
                tag = "#1#",
            },
        },
        events = {
            -- Cloudburst
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92760,
                execute = {
                    {
                        "alert","cloudburstwarn",
                        "alert","cloudburstcast",
                        "raidicon","cloudburstmark",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[92760]},
                        "expect",{"&unitisplayertype|#1#&","==","false"},
                        "quash",{"cloudburstcast","&unitguid|#1#&"},
                        "removeraidicon","#1#",
                        
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[92760]},
                        "expect",{"&unitisplayertype|#1#&","==","false"},
                        "removeraidicon","#1#",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","45924"},
                        "quash",{"cloudburstcast","#4#"},
                    },
                },
            },
            -- Greater Heal
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92770,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","45935"},
                        "alert","greaterhealwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[92770]},
                        "expect",{"&unitisplayertype|#1#&","==","false"},
                        "quash",{"greaterhealwarn","&unitguid|#1#&"},
                        
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","45935"},
                        "quash",{"greaterhealwarn","#4#"},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end
