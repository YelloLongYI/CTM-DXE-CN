local L,SN,ST,SL,AL,AT,AN,TI = DXE.L,DXE.SN,DXE.ST,DXE.SL,DXE.AL,DXE.AT,DXE.AN,DXE.TI

---------------------------------
-- GENERAL HUSAM
---------------------------------

do
    local data = {
        version = 4,
        key = "husam",
        zone = L.zone["Lost City of the Tol'vir"],
        category = L.zone["Lost City of the Tol'vir"],
        name = "General Husam",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-General Husam.blp",
        triggers = {
            scan = {
                44577, -- General Husam
            },
        },
        onactivate = {
            tracing = {
                44577,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 44577,
        },
        userdata = {
            badtext = "",
            badcd = {20, 30, loop = false, type = "series"},
            shockwavecd = {25, 35, loop = false, type = "series"},
        },
        onstart = {
            {
                "alert","badcd",
                "alert","shockwavecd",
            },
        },
        
        filters = {
            bossemotes = {
                shockwaveemote = {
                    name = "Shockwave",
                    pattern = "begins to cast %[Shockwave%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[91257],
                },
            },
        },
        ordering = {
            alerts = {"badcd","badwarn","shockwavecd","shockwavewarn","eruptioncountdown","trapscd"},
        },
        
        alerts = {
            -- Bad Intentions
            badcd = {
                varname = format(L.alert["%s CD"],SN[83113]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[83113]),
                time = "<badcd>",
                flashtime = 5,
                color1 = "WHITE",
                color2 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[83113],
            },
            badwarn = {
                varname = format(L.alert["%s Warning"],SN[83113]),
                type = "simple",
                text = "<badtext>",
                time = 1,
                color1 = "WHITE",
                sound = "ALERT7",
                icon = ST[83113],
            },
            -- Detonate Traps
            trapscd = {
                varname = format(L.alert["%s CD"],SN[91263]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91263]),
                time = "<trapscd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[91263],
            },
            -- Shockwave
            shockwavecd = {
                varname = format(L.alert["%s CD"],SN[91257]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91257]),
                time = "<shockwavecd>",
                flashtime = 5,
                color1 = "BROWN",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[91257],
            },
            shockwavewarn = {
                varname = format(L.alert["%s Warning"],SN[91257]),
                type = "simple",
                text = format(L.alert["%s"],SN[91257]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[91257],
            },
            eruptioncountdown = {
                varname = format(L.alert["%s Countdown"],SN[91257]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[91257]),
                time = 5,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[91257],
            },
        },
        events = {
			-- Bad Intentions
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 83113,
                execute = {
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{badtext = format(L.alert["%s on <%s>"],SN[83113],"#5#")},
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{badtext = format(L.alert["%s on <%s>"],SN[83113],L.alert["YOU"])},
                    },
                    {
                        "quash","badcd",
                        "alert","badcd",
                        "alert","badwarn",
                    },
                },
            },
            -- Shockwave
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91257,
                execute = {
                    {
                        "quash","shockwavecd",
                        "alert","shockwavecd",
                        "alert","eruptioncountdown",
                        "alert","shockwavewarn",
                    },
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- LOCKMAW
---------------------------------

do
    local data = {
        version = 3,
        key = "lockmaw",
        zone = L.zone["Lost City of the Tol'vir"],
        category = L.zone["Lost City of the Tol'vir"],
        name = "Lockmaw",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Lockmaw.blp",
        triggers = {
            scan = {
                43614, -- Lockmaw
            },
        },
        onactivate = {
            tracing = {
                43614,
            },
            phasemarkers = {
                {
                    {0.3, "Venomous Rage", "At 30% of his HP, Lockmaw enters a Venomous Rage."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 43614,
        },
        userdata = {
            bloodtext = "",
            flailcd = {14.3, 25, loop = false, type = "series"},
            --wavetimer = {20, 25, loop = false, type = "series"},
            wavetimer = {38, 31, 31, loop = true, type = "series"},
            --wavecd = {20, 25, loop = false, type = "series"},
            wavecd = {38, 31, 31, loop = true, type = "series"},
            crocoliskcount = 0,
            crocoliskwarned = "no",
        },
        onstart = {
            {
                "alert","flailcd",
                "alert",{"wavecd", time = 2},
                "scheduletimer",{"wavetimer", 9},
                "repeattimer",{"checkhp", 1},
            },
            {
                "expect",{"&difficulty&","==","2"},
                "silentdefeat",true,
                "expect",{"&itemenabled|achievementcomplete&","==","true"},
                "counter","crocoliskcounter",
            },
        },
        
        announces = {
            achievementcomplete = {
                varname = "%s complete",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5291,
                msg = format(L.alert["<DXE> Enough Crocolisks %s have spawned. You can kill them now."],AL[5291]),
                throttle = true,
            },
        },
        filters = {
            bossemotes = {
                enrageemote = {
                    name = "Venomous Rage",
                    pattern = "becomes enraged",
                    hasIcon = false,
                    hide = true,
                    texture = ST[81706],
                },
            },
        },
        counters = {
            crocoliskcounter = {
                variable = "crocoliskcount",
                label = format("%s Frenzied Crocolisks alive",TI["AchievementShield"]),
                pattern = "%d",
                value = 0,
                minimum = 0,
                maximum = 20,
                difficulty = 2,
            },
        },
        ordering = {
            alerts = {"bloodwarn","wavecd","wavewarn","flailcd","flailwarn","ragesoonwarn","ragewarn"},
        },
        
        alerts = {
            -- Scent of Blood
            bloodwarn = {
                varname = format(L.alert["%s Warning"],SN[89998]),
                type = "simple",
                text = "<bloodtext>",
                time = 1,
                color1 = "RED",
                sound = "ALERT7",
                icon = ST[89998],
                throttle = 2,
            },
            -- Dust Flail
            flailcd = {
                varname = format(L.alert["%s CD"],SN[81642]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[81642]),
                time = "<flailcd>",
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[81642],
            },
            flailwarn = {
                varname = format(L.alert["%s Warning"],SN[81642]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[81642]),
                time = 5,
                color1 = "LIGHTGREEN",
                sound = "ALERT2",
                icon = ST[81642],
            },
            -- Frenzied Crocolisk wave
            wavecd = {
                varname = format(L.alert["%s CD"],SN[82791]),
                type = "dropdown",
                text = format(L.alert["New %s"],"Frenzied Crocolisks"),
                time = "<wavecd>",
                time2 = 9,
                flashtime = 5,
                color1 = "PEACH",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[82791],
            },
            wavewarn = {
                varname = format(L.alert["%s Warning"],SN[82791]),
                type = "simple",
                text = format(L.alert["New: %s"],"Frenzied Crocolisks"),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT9",
                icon = ST[82791],
            },
            -- Venomous Rage
            ragesoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[81706]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[81706]),
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[81706],
            },
            ragewarn = {
                varname = format(L.alert["%s Warning"],SN[81706]),
                type = "simple",
                text = format(L.alert["%s"],SN[81706]),
                time = 1,
                color1 = "RED",
                sound = "BEWARE",
                icon = ST[81706],
            },
        },
        timers = {
            wavetimer = {
                {
                    "quash","wavecd",
                    "alert","wavecd",
                    "alert","wavewarn",
                    "scheduletimer",{"wavetimer", "<wavetimer>"},
                    "set",{crocoliskcount = "INCR|4"},
                    "expect",{"<crocoliskcount>",">=","20"},
                    "expect",{"<crocoliskwarned>","==","no"},
                    "announce","achievementcomplete",
                    "set",{crocoliskwarned = "yes"},
                },
            },
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","40"},
                    "alert","ragesoonwarn",
                    "canceltimer","checkhp",
                },
            },
        },
        events = {
			-- Scent of Blood
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 89998,
                execute = {
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{bloodtext = format(L.alert["%s on <%s>"],SN[89998],"#5#")},
                        "alert","bloodwarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{bloodtext = format(L.alert["%s on %s"],SN[89998],L.alert["YOU"])},
                        "alert","bloodwarn",
                    },
                },
            },
            -- Dust Flail
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = 81642,
                execute = {
                    {
                        "quash","flailcd",
                        "alert","flailcd",
                        "alert","flailwarn",
                    },
                },
            },
            -- Venomous Rage
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 81706,
                execute = {
                    {
                        "alert","ragewarn",
                    },
                },
            },
            -- Crocolisk dies
            {
                type = "combatevent",
                eventtype = "PARTY_KILL",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","43658"},
                        "set",{crocoliskcount = "DECR|1"},
                        "expect",{"<crocoliskcount>","<=","20"},
                        "set",{crocoliskwarned = "no"},
                    },
                },
            },
            
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- AUGH
---------------------------------

do
    local data = {
        version = 3,
        key = "augh",
        zone = L.zone["Lost City of the Tol'vir"],
        category = L.zone["Lost City of the Tol'vir"],
        name = "Augh",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Augh.blp",
        triggers = {
            scan = {
                49045, -- Augh
            },
        },
        onactivate = {
            tracing = {
                49045,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 49045,
        },
        userdata = {
            smoketext = "",
            smoke_units = {type = "container", wipein = 3},
            breathtext = "",
            breath_units = {type = "container", wipein = 3},
        },
        onstart = {
            {
                "alert",{"dartcd", time = 2},
                "alert",{"whirlwindcd", time = 2},
                "alert",{"smokecd", time = 2},
                "alert",{"breathcd", time = 2},
            },
        },
        ordering = {
            alerts = {"whirlwindcd","whirlwindwarn","dartcd","dartwarn","breathcd","breathwarn","smokecd","smokewarn","frenzywarn"},
        },
        
        alerts = {
            -- Paralytic Blow Dart
            dartcd = {
                varname = format(L.alert["%s CD"],SN[89989]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[89989]),
                time = 12,
                time2 = 18,
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[89989],
            },
            dartwarn = {
                varname = format(L.alert["%s Warning"],SN[89989]),
                type = "simple",
                text = format(L.alert["%s"],SN[89989]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT7",
                icon = ST[89989],
            },
            -- Whirlwind
            whirlwindcd = {
                varname = format(L.alert["%s CD"],SN[91408]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91408]),
                time = 33,
                time2 = 10,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[91408],
                throttle = 10,
            },
            whirlwindwarn = {
                varname = format(L.alert["%s Warning"],SN[91408]),
                type = "simple",
                text = format(L.alert["%s"],SN[91408]),
                time = 1,
                color1 = "WHITE",
                sound = "RUNAWAY",
                icon = ST[91408],
                throttle = 10,
            },
            -- Smoke Bomb
            smokecd = {
                varname = format(L.alert["%s CD"],SN[91409]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91409]),
                time = 20,
                time2 = 19.5,
                flashtime = 5,
                color1 = "PEACH",
                color2 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[91409],
            },
            smokewarn = {
                varname = format(L.alert["%s Warning"],SN[91409]),
                type = "simple",
                text = "<smoketext>",
                time = 1,
                color1 = "MIDGREY",
                sound = "MINORWARNING",
                icon = ST[91409],
            },
            -- Dragon's Breath
            breathcd = {
                varname = format(L.alert["%s CD"],SN[90026]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[90026]),
                time = 18,
                time2 = 19.5,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[90026],
            },
            breathwarn = {
                varname = format(L.alert["%s Warning"],SN[90026]),
                type = "simple",
                text = "<breathtext>",
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[90026],
            },
            -- Frenzy
            frenzywarn = {
                varname = format(L.alert["%s Warning"],SN[91415]),
                type = "simple",
                text = format(L.alert["%s"],SN[91415]),
                time = 1,
                color1 = "RED",
                sound = "BEWARE",
                icon = ST[91415],
            },
        },
        timers = {
            breathtimer = {
                {
                    "set",{breathtext = format(L.alert["%s on %s"],SN[90026],"&list|breath_units&")},
                    "alert","breathwarn",
                },
            },
            smoketimer = {
                {
                    "set",{smoketext = format(L.alert["%s on %s"],SN[91409],"&list|smoke_units&")},
                    "alert","smokewarn",
                },
            },
        },
        events = {
			-- Paralytic Blow Dart
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 89989,
                execute = {
                    {
                        "quash","dartcd",
                        "alert","dartcd",
                        "alert","dartwarn",
                    },
                },
            },
            -- Whirlwind
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 91408,
                execute = {
                    {
                        "quash","whirlwindcd",
                        "alert","whirlwindcd",
                        "alert","whirlwindwarn",
                    },
                },
            },
            -- Smoke Bomb
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 91409,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "insert",{"smoke_units",L.alert["YOU"]},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "insert",{"smoke_units","#5#"},
                    },
                    {
                        "expect",{"&listsize|smoke_units&","==","1"},
                        "scheduletimer",{"smoketimer", 1},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[91409]},
                        "expect",{"#1#","==","boss1"},
                        "quash","smokecd",
                        "alert","smokecd",
                    },
                },
            },
            
            -- Frenzy
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 91415,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","49045"},
                        "alert","frenzywarn",
                    },
                },
            },
            -- Dragon's Breath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 90026,
                execute = {
                    {
                        "quash","breathcd",
                        "alert","breathcd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 90026,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "insert",{"breath_units",L.alert["YOU"]},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "insert",{"breath_units","#5#"},
                    },
                    {
                        "expect",{"&listsize|breath_units&","==","1"},
                        "scheduletimer",{"breathtimer", 1},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- HIGH PROPHET BARIM
---------------------------------

do
    local data = {
        version = 4,
        key = "barim",
        zone = L.zone["Lost City of the Tol'vir"],
        category = L.zone["Lost City of the Tol'vir"],
        name = "High Prophet Barim",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-High Prophet Barim.blp",
        triggers = {
            scan = {
                43612, -- High Prophet Barim
            },
        },
        onactivate = {
            tracing = {
                43612,
            },
            phasemarkers = {
                {
                    {0.5, "Phase 2", "When High Prophet Barim's HP reaches 50%, he pulls every player to him and forces them to kneel for 6 seconds."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 43612,
        },
        userdata = {
            furycd = 16;
            harbingeradded = "no",
            lastphase = "no",
            severtext = "",
            
            phasetransitioncd = 8,
            phase = "1",
        },
        onstart = {
            {
                "alert","furycd",
                "scheduletimer",{"furytimer", "<furycd>"},
                "repeattimer",{"checkhp", 1},
            },
        },
        
        raidicons = {
            harbingermark = {
                varname = format("%s {%s}","Harbinger of Darkness","NPC_ENEMY"),
                type = "ENEMY",
                persist = 10,
                unit = "#1#",
                reset = 60,
                icon = 1,
                texture = ST[88990],
            },
            severmark = {
                varname = format("%s {%s}",SN[82255],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                persist = 5,
                unit = "#5#",
                reset = 8,
                icon = 4,
                texture = ST[82255],
            },
        },
        ordering = {
            alerts = {"furycd","furyselfwarn", "blazeselfwarn","phase2soonwarn","phase2warn","phasetransition","severcd","severwarn","phase1warn"},
        },
        
        alerts = {
            -- Heaven's Fury
            furycd = {
                varname = format(L.alert["%s CD"],SN[90040]),
                type = "dropdown", 
                text = format(L.alert["Next %s"],SN[90040]),
                time = "<furycd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[53563],
            },
            furyselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[90040]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[90040],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[53563],
                throttle = 1,
                emphasizewarning = {1,0.5},
            },
            -- Repentance
            --[[
            repentancesoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[82320]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[82320]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT7",
                icon = ST[82320],
            },
            repentancewarn = {
                varname = format(L.alert["%s phase Warning"],SN[82320]),
                type = "centerpopup",
                text = format(L.alert["%s phase"],SN[82320]),
                time = 6,
                color1 = "YELLOW",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[82320],
                throttle = 3,
            },
            repentanceoverwarn = {
                varname = format(L.alert["%s over Warning"],SN[82320]),
                type = "simple",
                text = format(L.alert["%s phase over - FINISH HIM!"],SN[82320]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT7",
                icon = ST[82320],
            },
            ]]
            -- Phase 1 & 2
            phase1warn = {
                varname = format(L.alert["Phase 1 Warning"]),
                type = "simple",
                text = format(L.alert["Phase 1"]),
                time = 3,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            phase2warn = {
                varname = format(L.alert["Phase 2 Warning"]),
                type = "simple",
                text = format(L.alert["Phase 2"]),
                time = 3,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[11242],
            },
            -- Phase 2 soon
            phase2soonwarn = {
                varname = format(L.alert["%s soon Warning"],"Phase 2"),
                type = "simple",
                text = format(L.alert["%s soon ..."],"Phase 2"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[78832],
            },
            phasetransition = {
                varname = format(L.alert["Phase Transition Countdown"]),
                type = "centerpopup",
                text = format(L.alert["Phase %s transition"],"<phase>"),
                time = "<phasetransitioncd>",
                color1 = "TURQUOISE",
                flashtime = 8,
                sound = "ALERT7",
                icon = ST[78832],
            },
            -- Soul Sever
            severcd = {
                varname = format(L.alert["%s CD"],SN[82255]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[82255]),
                time = 15,
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "PINK",
                sound = "MINORWARNING",
                icon = ST[82255],
            },
            severwarn = {
                varname = format(L.alert["%s Warning"],SN[82255]),
                type = "centerpopup",
                text = "<severtext>",
                time = 4,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[82255],
            },
            -- Blaze of Heavens
            blazeselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[91196]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[91196],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[91196],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
        },
        timers = {
            furytimer = {
                {
                    "alert","furycd",
                    "scheduletimer",{"furytimer", "<furycd>"},
                },
            },
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","60"},
                    "alert","phase2soonwarn",
                    "canceltimer","checkhp",
                },
            },
        },
        events = {
			-- Heaven's Fury
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 90040,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","furyselfwarn",
                    },
                },
            },
            -- Blaze of Heavens
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 91196,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","blazeselfwarn",
                    },
                },
            },
            
            -- Repentance
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = 82320,
                execute = {
                    {
                        --"alert","repentancewarn",
                        "set",{phase = "2"},
                        "alert","phasetransition",
                        "schedulealert",{"phase2warn", 8},
                        "quash","furycd",
                        "canceltimer","furytimer",
                    },
                },
            },
            -- Harbinger of Darkness
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 90038,
                execute = {
                    {
                        "expect",{"<harbingeradded>","==","no"},
                        "set",{harbingeradded = "yes"},
                        "temptracing","#1#",
                        "raidicon","harbingermark",
                    },
                },
            },
            -- Last Phase
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","43927"},
                        "set",{
                            phase = "1",
                            phasetransitioncd = 2,
                        },
                        "alert","phasetransition",
                    },
                },
            },
            
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 82320,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","43612"},
                        "expect",{"<lastphase>","==","no"},
                        "set",{lastphase = "yes"},
                        "quash","severcd",
                        --"alert","repentanceoverwarn",
                        "alert","phase1warn",
                        "alert","furycd",
                        "scheduletimer",{"furytimer", "<furycd>"},
                        "closetemptracing",true,
                    },
                },
            },
            -- Soul Sever
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 82255,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{severtext = format(L.alert["%s on %s"],SN[82255],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{severtext = format(L.alert["%s on <%s>"],SN[82255],"#5#")},
                    },
                    {
                        "quash","severcd",
                        "alert","severcd",
                        "alert","severwarn",
                        "raidicon","severmark",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- SIAMAT
---------------------------------

do
    local data = {
        version = 2,
        key = "siamat",
        zone = L.zone["Lost City of the Tol'vir"],
        category = L.zone["Lost City of the Tol'vir"],
        name = "Siamat",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Siamat.blp",
        triggers = {
            scan = {
                44819, -- Siamat
            },
        },
        onactivate = {
            tracing = {44819},
            counters = {"servantcounter"},
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 44819,
        },
        userdata = {
            phase2warned = "no",
            servantcount = 0,
        },
        onstart = {
            {
            },
        },
        
        counters = {
            servantcounter = {
                variable = "servantcount",
                label = "Servants killed",
                value = 0,
                minimum = 0,
                maximum = 3,
            },
        },
        ordering = {
            alerts = {"servantcountwarn","phase2soonwarn","phase2warn","phase2transition"},
        },
        
        alerts = {
            -- Servant counter
            servantcountwarn = {
                varname = format(L.alert["%s counter Warning"],SN[90014]),
                type = "simple",
                text = "<servantcounttext>",
                time = 1,
                color1 = "RED",
                sound = "MINORWARNING",
                icon = ST[90014],
            },
            -- Phase 2
            phase2soonwarn = {
                varname = format(L.alert["%s soon Warning"],"Phase 2"),
                type = "simple",
                text = format(L.alert["%s soon ..."],"Phase 2"),
                time = 2,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            phase2transition = {
                varname = format(L.alert["%s Transition Countdown"],"Phase 2"),
                type = "centerpopup",
                text = format(L.alert["%s transition ..."],"Phase 2"),
                time = 6,
                color1 = "TURQUOISE",
                sound = "BEWARE",
                icon = ST[11242],
            },
            phase2warn = {
                varname = format(L.alert["%s Warning"],"Phase 2"),
                type = "simple",
                text = format(L.alert["%s"],"Phase 2"),
                time = 1,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[11242],
            },
        },
        events = {
			-- Lightning Charge cast
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91872,
                execute = {
                    {
                        "expect",{"<servantcount>","==","2"},
                        "expect",{"<phase2warned>","==","no"},
                        "set",{phase2warned = "yes"},
                        "alert","phase2soonwarn",
                    },
                },
            },
            -- Phase 2 (Yell trigger)
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_lostcityoftolvir["^Cower before"]},
                        "schedulealert",{"phase2warn", 6},
                        "alert","phase2transition",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","45259"},
                        "set",{servantcount = "INCR|1"},
                        "set",{servantcounttext = format("Servant of Siamat dead (%s)","<servantcount>")},
                        "alert","servantcountwarn",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","45268"},
                        "set",{servantcount = "INCR|1"},
                        "set",{servantcounttext = format("Servant of Siamat dead (%s)","<servantcount>")},
                        "alert","servantcountwarn",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","45269"},
                        "set",{servantcount = "INCR|1"},
                        "set",{servantcounttext = format("Servant of Siamat dead (%s)","<servantcount>")},
                        "alert","servantcountwarn",
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
        version = 1,
        key = "lostcitytrash",
        zone = L.zone["Lost City of the Tol'vir"],
        category = L.zone["Lost City of the Tol'vir"],
        name = "Trash",
        triggers = {
            scan = {
                45122, -- Oathsworn Captain
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {},
        
        alerts = {
            -- Earthquake
            quakeselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[84251]),
                type = "simple",
                emphasizewarning = true,
                text = format(L.alert["%s on %s - GET AWAY!"],SN[84251],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[84251],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
            
        },
        events = {
            -- Earthquake
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 84251,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","quakeselfwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end
