-- Data_Stonecore_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "corborus", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        stormcd = {38, 60.5, loop = false, type = "series"},
        lavacd = {6.4, 0, loop = false, type = "series"},
        lavatimer = {6.4, 10, loop = false, type = "series"},
        sandcd = {8, 0, loop = false, type = "series"},
        lavaspawntime = 5,
    },
    alerts = {
        -- Burrow
        burrowcd = {
            time = 60,
            time2 = 32,
        },
        -- Emerge
        emergecd = {
            time = 60,
            time2 = 63.6,
        },
        -- Crystal Barrage
        barragecd = {
            varname = format(L.alert["%s CD"],SN[86881]),
            text = format(L.alert["%s CD"],SN[86881]),
            text2 = format(L.alert["Next %s"],SN[86881]),
            time = {16, 0, loop = true, type = "series"}, -- regular CD
            time2 = 11, -- initial
            time3 = 31.7, -- after Burrow
            icon = ST[86881],
        },
        barragewarn = {
            varname = format(L.alert["%s Warning"],SN[86881]),
            text = format(L.alert["%s"],SN[86881]),
            icon = ST[86881],
        },
        barragemovewarn = {
            varname = format(L.alert["%s on me Warning"],SN[86881]),
            text = format(L.alert["%s on %s - GET AWAY!"],SN[86881],L.alert["YOU"]),
            icon = ST[86881],
        },
        -- Dampening Wave
        wavecd = {
            varname = format(L.alert["%s CD"],SN[82415]),
            text = format(L.alert["Next %s"],SN[82415]),
            time = 10,
            time2 = 7.5,
            time3 = 4,
            icon = ST[82415],
        },
        wavewarn = {
            varname = format(L.alert["%s Warning"],SN[82415]),
            text = format(L.alert["%s"],SN[82415]),
            icon = ST[82415],
        },
    },
    events = {
        -- Crystal Barrage
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 86881,
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
            spellname = 86881,
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
            spellname = 82415,
            execute = {
                {
                    "quash","wavecd",
                    "alert","wavecd",
                    "alert","wavewarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "slabhide", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Lava Fissure
        lavacd = {
            varname = format(L.alert["%s CD"],SN[80803]),
            text = format(L.alert["Next %s"],SN[80803]),
            time = "<lavacd>",
            icon = ST[80803],
        },
        lavaspawnwarn = {
            varname = format(L.alert["%s spawning Warning"],SN[80803]),
            text = format(L.alert["%s spawning"],SN[80803]),
            warningtext = format(L.alert["%s"],SN[80803]),
            time = "<lavaspawntime>",
            icon = ST[80803],
        },
        lavawarn = {
            varname = format(L.alert["%s Warning"],SN[80803]),
            text = format(L.alert["%s on %s - GET AWAY!"],SN[80803],L.alert["YOU"]),
            icon = ST[80803],
        },
        -- Sand Blast
        sandcd = {
            varname = format(L.alert["%s CD"],SN[26102]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[26102]),
            time = "<sandcd>",
            time2 = 23,
            icon = ST[26102],
        },
        -- Stalactite (Air Phase)
        airphasecd = {
            varname = format(L.alert["%s CD"],SN[80656]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[80656]),
            time = 47.5,
            time2 = 12.5,
            icon = ST[103176],
        },
        airphaseduration = {
            varname = format(L.alert["%s Duration"],SN[80656]),
            text = format(L.alert["%s"],SN[80656]),
            time = 12.5,
            icon = ST[103176],
        },
        airphaswarn = {
            varname = format(L.alert["%s Warning"],SN[80656]),
            text = format(L.alert["%s"],SN[80656]),
            icon = ST[103176],
        },
        -- Crystal Storm
        stormcd = {
            varname = format(L.alert["%s CD"],SN[92265]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[92265]),
            time = "<stormcd>",
            icon = ST[92265],
        },
        stormwarn = {
            varname = format(L.alert["%s Warning"],SN[92265]),
            warningtext = format(L.alert["%s incoming"],SN[92265]),
            text = format(L.alert["%s"],SN[92265]),
            icon = ST[92265],
        },
        stormduration = {
            varname = format(L.alert["%s Duration"],SN[92265]),
            text = format(L.alert["%s"],SN[92265]),
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
            spellname = 26102,
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
})

DXE:RegisterRealmPatch(realm, "ozruk", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Elementium Bulwark
        bulwarkcd = {
            varname = format(L.alert["%s CD"],SN[78939]),
            text = format(L.alert["Next %s"],SN[78939]),
            time = 24,
            time2 = 7,
            icon = ST[78939],
        },
        -- Ground Slam
        slamcd = {
            varname = format(L.alert["%s CD"],SN[78903]),
            text = format(L.alert["Next %s"],SN[78903]),
            time = "<slamcd>",
            icon = ST[78903],
        },
        slamwarn = {
            varname = format(L.alert["%s Warning"],SN[78903]),
            text = format(L.alert["%s"],SN[78903]),
            icon = ST[78903],
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
            varname = format(L.alert["%s CD"],SN[78807]),
            text = format(L.alert["Next %s"],SN[78807]),
            time = "<shattercd>",
            icon = ST[78807],
        },
        shatterwarn = {
            varname = format(L.alert["%s Warning"],SN[78807]),
            text = format(L.alert["%s"],SN[78807]),
            warningtext = format(L.alert["%s - RUN AWAY!"],SN[78807]),
            icon = ST[78807],
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
    events = {
        -- Elementium Bulwark
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 78939,
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
            spellname = 78903,
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
            spellname = 78807,
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
})

DXE:RegisterRealmPatch(realm, "azil", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        gripcd = {9, 14, loop = false, type = "series"},
        wellcd = {16, 14, loop = false, type = "series"},
    },
    alerts = {
        -- Force Grip
        gripcd = {
            varname = format(L.alert["%s CD"],SN[79351]),
            text = format(L.alert["Next %s"],SN[79351]),
            time = "<gripcd>",
            icon = ST[79351],
        },
        -- Gravity Well
        wellcd = {
            varname = format(L.alert["%s CD"],SN[79340]),
            text = format(L.alert["Next %s"],SN[79340]),
            time = "<wellcd>",
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
            icon = ST[82858],
        },
        phaseduration = {
            varname = format(L.alert["%s Duration"],"Phase"),
            text = format(L.alert["%s"],"Phase 1"),
            text2 = format(L.alert["%s"],"Phase 2"),
            time = 50, -- Phase 1 duration
            time2 = 31, -- Phase 2 duration
            icon = ST[82858],
        },
    },
    events = {
        {
            tag = "p2_end",
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
                        wellcd = {16, 14, loop = false, type = "series"},
                        gripcd = {9, 14, loop = false, type = "series"},
                    },
                    "alert","wellcd",
                    "alert","gripcd",
                    
                },
            },
        },  
    },
})

DXE:RegisterRealmPatch(realm, "stonecoretrash", {
    windows = {
        proxwindow = false,
    },
})
