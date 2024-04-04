local L,SN,ST,SL,AL,AT,TI = DXE.L,DXE.SN,DXE.ST,DXE.SL,DXE.AL,DXE.AT,DXE.TI

---------------------------------
-- CORBORUS
---------------------------------

do
    local data = {
        version = 2,
        key = "corborus",
        zone = L.zone["The Stonecore"],
        category = L.zone["The Stonecore"],
        name = "Corborus",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Corborus.blp",
        triggers = {
            scan = {
                43438, -- Corborus
            },
        },
        onactivate = {
            tracing = {
                43438,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 43438,
        },
        userdata = {
            barragecasting = "no",
        },
        onstart = {
            {
                "alert",{"burrowcd",time = 2},
                "alert",{"emergecd",time = 2},
                "alert",{"barragecd",time = 2},
                "alert","wavecd",
            },
        },
        
        arrows = {
            barragearrow = {
                varname = format("%s",SN[92648]),
                unit = "#5#",
                persist = 5,
                action = "TOWARD",
                msg = L.alert["Crystal Shards"],
                spell = SN[92648],
                sound = "None",
                rangeStay = 5,
                range1 = 15,
                fixed = true,
                texture = ST[92648],
            }
        },
        raidicons = {
            barragemark = {
                varname = format("%s {%s}",SN[92648],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 5,
                unit = "#5#",
                reset = 7,
                icon = 1,
                texture = ST[92648],
            },
        },
        phrasecolors = {
            {"Corborus","GOLD"},
        },
        ordering = {
            alerts = {"wavecd","wavewarn","barragecd","barragewarn","barragemovewarn","burrowcd","burrowwarn","emergecd","emergewarn"},
        },
        
        alerts = {
            -- Burrow
            burrowcd = {
                varname = format(L.alert["%s CD"],"Burrow"),
                type = "dropdown",
                text = format(L.alert["%s"],"Burrow"),
                time = 60,
                time2 = 32,
                flashtime = 5,
                color1 = "BROWN",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[103180],
                sticky = true,
            },
            burrowwarn = {
                varname = format(L.alert["%s Warning"],"Burrow"),
                type = "simple",
                text = format(L.alert["%s"],"Corborus has burrowed!"),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT7",
                icon = ST[103180],
            },
            -- Emerge
            emergecd = {
                varname = format(L.alert["%s CD"],"Emerge"),
                type = "dropdown",
                text = format(L.alert["%s"],"Emerge"),
                time = 60,
                time2 = 63.6,
                flashtime = 10,
                color1 = "BROWN",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[2062],
                sticky = true,
            },
            emergewarn = {
                varname = format(L.alert["%s Warning"],"Emerge"),
                type = "simple",
                text = format(L.alert["%s"],"Corborus has emerged!"),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT8",
                icon = ST[2062],
            },
            -- Crystal Barrage
            barragecd = {
                varname = format(L.alert["%s CD"],SN[92648]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[92648]),
                text2 = format(L.alert["Next %s"],SN[92648]),
                time = {16, 0, loop = true, type = "series"}, -- regular CD
                time2 = 11, -- initial
                time3 = 31.7, -- after Burrow
                flashtime = 5,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[92648],
                sticky = true,
            },
            barragewarn = {
                varname = format(L.alert["%s Warning"],SN[92648]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[92648]),
                time = 4,
                color1 = "RED",
                sound = "ALERT2",
                icon = ST[92648],
            },
            barragemovewarn = {
                varname = format(L.alert["%s on me Warning"],SN[92648]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[92648],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[92648],
                throttle = 2,
                emphasizewarning = {2,0.5},
            },
            -- Dampening Wave
            wavecd = {
                varname = format(L.alert["%s CD"],SN[92650]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92650]),
                time = 10,
                time2 = 7.5,
                time3 = 4,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[92650],
                sticky = true,
            },
            wavewarn = {
                varname = format(L.alert["%s Warning"],SN[92650]),
                type = "simple",
                text = format(L.alert["%s"],SN[92650]),
                time = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[92650],
                throttle = 5,
            },
        },
        timers = {
            barragetimer = {
                {
                    "set",{barragecasting = "no"},
                },
            },
        },
        events = {
			-- Crystal Barrage
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 92648,
                execute = {
                    {
                        "quash","barragecd",
                        "alert","barragecd",
                        "alert","barragewarn",
                        "invoke",{
                            {
                                "expect",{"&timeleft|burrowcd&",">","5"},
                                "expect",{"&timeleft|wavecd&","<","4"},
                                "quash","wavecd",
                                "alert",{"wavecd",time = 3},
                            },
                            {
                                "expect",{"&timeleft|burrowcd&","<","5"},
                                "quash","wavecd",
                            },
                        }, 
                        "set",{barragecasting = "yes"},
                        "scheduletimer",{"barragetimer", 5},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 92648,
                execute = {
                    {
                        "expect",{"<barragecasting>","==","yes"},
                        "set",{barragecasting = "no"},
                        "canceltimer","barragetimer",
                        "raidicon","barragemark",
                        "expect",{"&difficulty&","==","2"},
                        "arrow","barragearrow",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","barragemovewarn",
                    },
                },
            },
            -- Burrow
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[81629]},
                        "expect",{"#1#","==","boss1"},
                        "quash","burrowcd",
                        "quash","wavecd",
                        "quash","barragecd",
                        "alert","burrowwarn",
                        "alert","burrowcd",
                        "alert",{"barragecd",time = 3, text = 2},
                    },
                },
            },
            -- Emerge
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[81948]},
                        "expect",{"#1#","==","boss1"},
                        "quash","emergecd",
                        "alert","emergewarn",
                        "alert",{"wavecd",time = 2},
                        "alert","emergecd",
                    },
                },
            },
            
            
            -- Dampening Wave
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 92650,
                execute = {
                    {
                        "quash","wavecd",
                        "alert","wavecd",
                        "alert","wavewarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- SLABHIDE
---------------------------------

do
    local data = {
        version = 5,
        key = "slabhide",
        zone = L.zone["The Stonecore"],
        category = L.zone["The Stonecore"],
        name = "Slabhide",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Slabhide.blp",
        triggers = {
            scan = {
                43214, -- Slabhide
            },
        },
        onactivate = {
            tracing = {
                43214,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 43214,
        },
        userdata = {
            stormcd = {30.5, 60, loop = false, type = "series"},
            lavacd = {6.4, 0, loop = false, type = "series"},
            lavatimer = {6.4, 10, loop = false, type = "series"},
            sandcd = {8, 0, loop = false, type = "series"},
            lavaspawntime = 5,
        },
        onstart = {
            {
                "alert","lavacd",
                "alert","sandcd",
                "scheduletimer",{"airphasetimer", 12.5},
                "alert",{"airphasecd",time = 2},
            },
            {
                "expect",{"&difficulty&","==","2"}, --5 heroic
                "set",{lavaspawntime = 3},
                "alert","stormcd",
            },
        },
        
        phrasecolors = {
            {"spawning","YELLOW"},
            {"incoming","GOLD"},
        },
        windows = {
            proxwindow = true,
            proxrange = 5,
            proxoverride = true,
        },
        ordering = {
            alerts = {"lavacd","lavaspawnwarn","lavawarn","sandcd","airphasecd","airphaswarn","airphaseduration","stormcd","stormwarn","stormduration"},
        },
        
        alerts = {
            -- Lava Fissure
            lavacd = {
                varname = format(L.alert["%s CD"],SN[80803]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[80803]),
                time = "<lavacd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[80803],
            },
            lavaspawnwarn = {
                varname = format(L.alert["%s spawning Warning"],SN[80803]),
                type = "centerpopup",
                text = format(L.alert["%s spawning"],SN[80803]),
                warningtext = format(L.alert["%s"],SN[80803]),
                time = "<lavaspawntime>",
                color1 = "RED",
                sound = "ALERT8",
                icon = ST[80803],
            },
            lavawarn = {
                varname = format(L.alert["%s Warning"],SN[80803]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[80803],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[80803],
                emphasizewarning = {1,0.5},
                throttle = 1,
            },
            -- Sand Blast
            sandcd = {
                varname = format(L.alert["%s CD"],SN[92656]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92656]),
                time = "<sandcd>",
                time2 = 23,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[92656],
            },
            -- Stalactite (Air Phase)
            airphasecd = {
                varname = format(L.alert["%s CD"],SN[80656]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[80656]),
                time = 47.5,
                time2 = 12.5,
                flashtime = 5,
                color1 = "WHITE",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[103176],
            },
            airphaseduration = {
                varname = format(L.alert["%s Duration"],SN[80656]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[80656]),
                fillDirection = "DEPLETE",
                time = 12.5,
                flashtime = 5,
                color1 = "TEAL",
                color2 = "ORANGE",
                icon = ST[103176],
            },
            airphaswarn = {
                varname = format(L.alert["%s Warning"],SN[80656]),
                type = "simple",
                text = format(L.alert["%s"],SN[80656]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT9",
                icon = ST[103176],
            },
            -- Crystal Storm
            stormcd = {
                varname = format(L.alert["%s CD"],SN[92265]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92265]),
                time = "<stormcd>",
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[92265],
            },
            stormwarn = {
                varname = format(L.alert["%s Warning"],SN[92265]),
                type = "centerpopup",
                warningtext = format(L.alert["%s incoming"],SN[92265]),
                text = format(L.alert["%s"],SN[92265]),
                time = 2.5,
                color1 = "LIGHTBLUE",
                sound = "BEWARE",
                icon = ST[92265],
            },
            stormduration = {
                varname = format(L.alert["%s Duration"],SN[92265]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s"],SN[92265]),
                time = 6,
                color1 = "CYAN",
                color2 = "INDIGO",
                sound = "Nne",
                icon = ST[92265],
            },
        },
        events = {
			-- Lava Fissure
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[80803]},
                        "expect",{"#1#","==","boss1"},
                        "quash","lavacd",
                        "alert","lavacd",
                        "alert","lavaspawnwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = {80800,80801},
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","lavawarn",
                    },
                },
            },
            -- Sand Blast
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 92656,
                execute = {
                    {
                        "quash","sandcd",
                        "alert","sandcd",
                    },
                },
            },
            -- Crystal Storm
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92265,
                execute = {
                    {
                        "quash","stormcd",
                        "alert","stormcd",
                        "alert","stormwarn",
                        "scheduletimer",{"stormtimer", 2.5},
                    },
                },
            },
        },
        timers = {
            -- Stalactite (air phase) duration
            airphasetimer = {
                {
                    "scheduletimer",{"airphasetimer", 60},
                    "alert","airphaseduration",
                    "alert","airphaswarn",
                    "scheduletimer",{"airphasecdtimer", 12.5},
                    "quash","lavacd",
                    "quash","sandcd",
                },
            },
            -- after the Stalactite (air phase)
            airphasecdtimer = {
                {
                    "alert","airphasecd",
                    "set",{lavacd = {11, 10.5, 10.5, 10.5, 0, loop = false, type = "series"}},
                    "alert","lavacd",
                },
                {
                    "expect",{"&difficulty&","==","1"}, --5 normal
                    "set",{sandcd = {8, 8, 8, 8, 8, 8, 0, loop = false, type = "series"}},
                    "alert","sandcd",
                },
                {
                    "expect",{"&difficulty&","==","2"}, --5 heroic
                    "set",{sandcd = {21, 8, 8, 8, 8, 8, 0, loop = false, type = "series"}},
                    "alert","sandcd",
                },
            },
            stormtimer = {
                {
                    "quash","stormwarn",
                    "alert","stormduration",
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- OZRUK
---------------------------------

do
    local data = {
        version = 3,
        key = "ozruk",
        zone = L.zone["The Stonecore"],
        category = L.zone["The Stonecore"],
        name = "Ozruk",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Ozruk.blp",
        triggers = {
            scan = {
                42188, -- Ozruk
            },
        },
        onactivate = {
            tracing = {
                42188,
            },
            phasemarkers = {
                {
                    {0.25, "Enrage","At 25% of his HP, Ozruk enrages."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 42188,
        },
        userdata = {
            slamcd = {12, 21, loop = false, type = "series"},
            shattercd = {20, 21, loop = false, type = "series"},
        },
        onstart = {
            {
                "alert",{"bulwarkcd",time = 2},
                "alert","slamcd",
                "alert","shattercd",
                "repeattimer",{"checkhp", 1},
                "expect",{"&difficulty&","==","2"},
                "alert",{"paralyzecd",time = 2},
            },
        },

        filters = {
            bossemotes = {
                bulwarkemote = {
                    name = "Elementium Bulwark",
                    pattern = "casts %[Elementium Bulwark%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[92659],
                },
                enrageemote = {
                    name = "Enrage",
                    pattern = "becomes enraged",
                    hasIcon = false,
                    hide = true,
                    texture = ST[80467],
                },
            },
        },
        ordering = {
            alerts = {"bulwarkcd","slamcd","slamwarn","paralyzecd","paralyzewarn","shattercd","shatterwarn","enragesoonwarn","enragewarn"},
        },
        
        alerts = {
            -- Elementium Bulwark
            bulwarkcd = {
                varname = format(L.alert["%s CD"],SN[92659]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92659]),
                time = 24,
                time2 = 7,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[92659],
                sticky = true,
            },
            -- Ground Slam
            slamcd = {
                varname = format(L.alert["%s CD"],SN[92410]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92410]),
                time = "<slamcd>",
                flashtime = 5,
                color1 = "BROWN",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[92410],
            },
            slamwarn = {
                varname = format(L.alert["%s Warning"],SN[92410]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[92410]),
                time = 3,
                color1 = "ORANGE",
                sound = "ALERT1",
                icon = ST[92410],
            },
            -- Paralyze
            paralyzecd = {
                varname = format(L.alert["%s CD"],SN[92426]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92426]),
                --time = "<paralyzecd>",
                time = 21,
                time2 = 18,
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[92426],
            },
            paralyzewarn = {
                varname = format(L.alert["%s Warning"],SN[92426]),
                type = "simple",
                text = format(L.alert["%s"],SN[92426]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT7",
                icon = ST[92426],
            },
            -- Shatter
            shattercd = {
                varname = format(L.alert["%s CD"],SN[92662]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[92662]),
                time = "<shattercd>",
                flashtime = 5,
                color1 = "RED",
                color2 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[92662],
            },
            shatterwarn = {
                varname = format(L.alert["%s Warning"],SN[92662]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[92662]),
                warningtext = format(L.alert["%s - RUN AWAY!"],SN[92662]),
                time = 3,
                color1 = "RED",
                sound = "RUNAWAY",
                icon = ST[92662],
            },
            -- Enrage
            enragesoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[80467]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[80467]),
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                texture = ST[80467],
            },
            enragewarn = {
                varname = format(L.alert["%s Warning"],SN[80467]),
                type = "simple",
                text = format(L.alert["%s"],SN[80467]),
                time = 1,
                color1 = "RED",
                sound = "BEWARE",
                icon = ST[80467],
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","35"},
                    "alert","enragesoonwarn",
                    "canceltimer","checkhp",
                },
            },
        },
        events = {
			-- Elementium Bulwark
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 92659,
                execute = {
                    {
                        "quash","bulwarkcd",
                        "alert","bulwarkcd",
                    },
                },
            },
            -- Ground Slam
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92410,
                execute = {
                    {
                        "quash","slamcd",
                        "alert","slamcd",
                        "alert","slamwarn",
                    },
                },
            },
            -- Paralyze
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92426,
                execute = {
                    {
                        "quash","paralyzecd",
                        "alert","paralyzecd",
                        "alert","paralyzewarn",
                    },
                },
            },
            -- Shatter
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92662,
                execute = {
                    {
                        "quash","shattercd",
                        "alert","shattercd",
                        "alert","shatterwarn",
                    },
                },
            },
            -- Enrage
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 80467,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","42188"},
                        "alert","enragewarn",
                    },
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- HIGH PRIESTESS AZIL
---------------------------------

do
    local data = {
        version = 4,
        key = "azil",
        zone = L.zone["The Stonecore"],
        category = L.zone["The Stonecore"],
        name = "High Priestess Azil",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-High Priestess Azil.blp",
        triggers = {
            scan = {
                42333, -- High Priestess Azil
            },
        },
        onactivate = {
            tracing = {
                42333,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 42333,
        },
        userdata = {
            gripcd = {15, 25, 0, loop = false, type = "series"},
            wellcd = {12, 8, 8, 8, 8, 0, loop = false, type = "series"},
            firstshield = "no",
        },
        onstart = {
            {
                "alert","gripcd",
                "alert","wellcd",
                "alert",{"phaseduration",time = 1, text = 2},
            },
        },
        
        phrasecolors = {
            {"spawning","YELLOW"},
        },
        ordering = {
            alerts = {"phasewarn","phaseduration","wellcd","wellwarn","gripcd","gripwarn","newadswarn","shieldcast"},
        },
        
        alerts = {
            -- Force Grip
            gripcd = {
                varname = format(L.alert["%s CD"],SN[79351]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[79351]),
                time = "<gripcd>",
                flashtime = 5,
                color1 = "INDIGO",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[79351],
            },
            gripwarn = {
                varname = format(L.alert["%s Warning"],SN[79351]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[79351]),
                time = 1.5,
                color1 = "TURQUOISE",
                sound = "ALERT2",
                icon = ST[79351],
            },
            -- Gravity Well
            wellcd = {
                varname = format(L.alert["%s CD"],SN[79340]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[79340]),
                time = "<wellcd>",
                flashtime = 5,
                color1 = "DCYAN",
                color2 = "LIGHTGREEN",
                sound = "MINORWARNING",
                icon = ST[79340],
            },
            wellwarn = {
                varname = format(L.alert["%s Warning"],SN[79340]),
                type = "centerpopup",
                warningtext = format(L.alert["%s"],"Gravity Well"),
                text = format(L.alert["%s spawning"],"Gravity Well"),
                time = 4,
                color1 = "TURQUOISE",
                sound = "ALERT8",
                icon = ST[79340],
            },
            -- Energy Shield
            phasewarn = {
                varname = format(L.alert["Phase Warning"]),
                type = "simple",
                text = format(L.alert["Phase 1"]),
                text2 = format(L.alert["Phase 2"]),
                time = 1,
                --time = 3,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[82858],
            },
            phaseduration = {
                varname = format(L.alert["%s Duration"],"Phase"),
                type = "dropdown",
                text = format(L.alert["%s"],"Phase 1"),
                text2 = format(L.alert["%s"],"Phase 2"),
                time = 50, -- Phase 1 duration
                time2 = 31, -- Phase 2 duration
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[82858],
            },
            shieldcast = {
                varname = format(L.alert["%s Cast"],SN[82858]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[82858]),
                time = 2,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[82858],
            },
            -- Followers Wave
            newadswarn = {
                varname = format(L.alert["Summon %s Warning"],"Devout Followers"),
                type = "simple",
                text = format(L.alert["New: %s"],"Devout Followers"),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT9",
                icon = ST[29888],
                throttle = 1,
            },
        },
        events = {
			-- Force Grip
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 79351,
                execute = {
                    {
                        "quash","gripcd",
                        "alert","gripcd",
                        "alert","gripwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[79351]},
                        "expect",{"#1#","find","boss"},
                        "quash","gripwarn",
                    },
                },
            },
            
            -- Gravity Well
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 79340,
                execute = {
                    {
                        "quash","wellcd",
                        "alert","wellcd",
                        "alert","wellwarn",
                    },
                },
            },
            -- Energy Shield
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 82858,
                execute = {
                    {
                        "expect",{"<firstshield>","==","yes"},
                        "alert","shieldcast",
                        "alert",{"phasewarn",text = 2},
                        "quash","wellcd",
                        "quash","gripcd",
                    },
                    {
                        "expect",{"<firstshield>","==","no"},
                        "set",{firstshield = "yes"},
                    },
                },
            },
            -- Seismic Shard
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 79002,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","42333"},
                        "expect",{"&npcid|#4#&","==","42333"},
                        "alert",{"phaseduration",time = 2, text = 1},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 79002,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","42333"},
                        "expect",{"&npcid|#4#&","==","42333"},
                        "alert",{"phasewarn",text = 1},
                        "alert",{"phaseduration",time = 1, text = 2},
                        "set",{
                            wellcd = {12, 8, 8, 8, 8, 0, loop = false, type = "series"},
                            gripcd = {38, 0, loop = false, type = "series"},
                        },
                        "alert","wellcd",
                        "alert","gripcd",
                        
                    },
                },
            },
            -- Followers
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[79199]},
                        "expect",{"#1#","find","boss"},
                        "alert","newadswarn",
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
        version = 3,
        key = "stonecoretrash",
        zone = L.zone["The Stonecore"],
        category = L.zone["The Stonecore"],
        name = "Trash",
        triggers = {
            scan = {
                42810, -- Crystalspawn Giant *
                42808, -- Stonecore Flayer *
                
                43430, -- Stonecore Berserker *
                43537, -- Stonecore Earthshaper *
                43391, -- Millhouse Manastorm
                42696, -- Stonecore Warbringer
                
                42691, -- Stonecore Rift Conjurer
                42789, -- Stonecore Magmalord
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
            {"Crystalspawn Giant","GOLD"},
            {"begins casting","WHITE"},
            {"Stonecore Magmalord:","GOLD"},
        },
        raidicons = {
            earthshapermark = {
                varname = format("%s {%s-%s}",SN[81459],"ENEMY_CAST","Stonecore Earthshaper's"),
                type = "ENEMY",
                persist = 5,
                unit = "#1#",
                icon = 1,
                texture = ST[81459],
            },
            magmamark = {
                varname = format("%s {%s-%s}",SN[80038],"ENEMY_CAST","Stonecore Magmalord's"),
                type = "MULTIENEMY",
                persist = 3,
                unit = "#1#",
                reset = 6,
                icon = 1,
                total = 2,
                texture = ST[80038],
            },
        },
        ordering = {
            alerts = {"slashselfwarn","quakewarn","quakecast","quakejumpwarn","flayselfwarn","magmawarn"},
        },
        
        alerts = {
            -- Quake
            quakewarn = {
                varname = format(L.alert["%s Warning"],SN[92631]),
                type = "simple",
                text = format(L.alert["%s: %s"],"Crystalspawn Giant",SN[92631]),
                time = 2,
                color1 = "YELLOW",
                sound = "None",
                icon = ST[92631],
            },
            quakecast = {
                varname = format(L.alert["%s Cast"],SN[92631]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[92631]),
                time = 2,
                color1 = "ORANGE",
                sound = "ALERT1",
                icon = ST[92631],
                tag = "#1#",
            },
            quakejumpwarn = {
                varname = format(L.alert["%s (jump) Warning"],SN[92631]),
                type = "simple",
                text = format(L.alert["JUMP - to avoid Quake damage!"]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT7",
                icon = ST[101848],
            },
            -- Flay
            flayselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[79923]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[79923],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                icon = ST[79923],
                throttle = 2,
                emphasizewarning = true,
            },
            -- Spinning Slash
            slashselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[92623]),
                type = "simple",
                emphasizewarning = true,
                text = format(L.alert["%s on %s - GET AWAY!"],SN[92623],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[92623],
                throttle = 1,
                emphasizewarning = {1,0.5},
            },
            -- Magma Eruption
            magmawarn = {
                varname = format(L.alert["%s Warning"],SN[80038]),
                type = "centerpopup",
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Stonecore Magmalord",SN[80038]),
                text = format(L.alert["%s - INTERRUPT"],SN[80038]),
                time = 3,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[80038],
                tag = "#1#",
            },
            
        },
        events = {
			-- Quake
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 92631,
                execute = {
                    {
                        "alert","quakewarn",
                        "alert","quakecast",
                        "schedulealert",{"quakejumpwarn", 1.25},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","42810"},
                        "quash",{"quakecast","#4#"},
                    },
                },
            },
            -- Flay
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 79923,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","flayselfwarn",
                    },
                },
            },            
            -- Spinning Slash
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 92623,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","slashselfwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 92623,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","slashselfwarn",
                    },
                },
            },
            -- Force of Earth
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 81459,
                execute = {
                    {
                        "raidicon","earthshapermark",
                    },
                },
            },
            -- Magma Eruption
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 80038,
                execute = {
                    {
                        "alert","magmawarn",
                        "raidicon","magmamark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 80038,
                execute = {
                    {
                        "quash","magmawarn",
                    },
                },
            },
            
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","42789"},
                        "quash",{"magmawarn","#4#"},
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end
