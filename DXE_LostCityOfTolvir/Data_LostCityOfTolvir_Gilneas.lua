-- Data_LostCityOfTolvir_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "husam", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        badtext = "",
        badcd = {20, 30, loop = false, type = "series"},
        shockwavecd = {25, 35, loop = false, type = "series"},
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
            varname = format(L.alert["%s CD"],SN[83445]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[83445]),
            time = "<shockwavecd>",
            flashtime = 5,
            color1 = "BROWN",
            color2 = "YELLOW",
            sound = "MINORWARNING",
            icon = ST[83445],
        },
        shockwavewarn = {
            varname = format(L.alert["%s Warning"],SN[83445]),
            type = "simple",
            text = format(L.alert["%s"],SN[83445]),
            time = 1,
            color1 = "YELLOW",
            sound = "ALERT2",
            icon = ST[83445],
        },
        eruptioncountdown = {
            varname = format(L.alert["%s Countdown"],SN[83445]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[83445]),
            time = 5,
            color1 = "ORANGE",
            sound = "None",
            icon = ST[83445],
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
            spellname = 83445,
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
})

DXE:RegisterRealmPatch(realm, "lockmaw", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Scent of Blood
        bloodwarn = {
            varname = format(L.alert["%s Warning"],SN[81690]),
            text = "<bloodtext>",
            icon = ST[81690],
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
            text = format(L.alert["%s"],SN[81642]),
            icon = ST[81642],
        },
        -- Frenzied Crocolisk wave
        wavecd = {
            varname = format(L.alert["%s CD"],SN[82791]),
            text = format(L.alert["New %s"],"Frenzied Crocolisks"),
            time = "<wavecd>",
            time2 = 9,
            flashtime = 5,
            icon = ST[82791],
        },
    },
    events = {
        -- Scent of Blood
        {
            tag = "scent_of_blood",
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 81690,
            execute = {
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{bloodtext = format(L.alert["%s on <%s>"],SN[81690],"#5#")},
                    "alert","bloodwarn",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{bloodtext = format(L.alert["%s on %s"],SN[81690],L.alert["YOU"])},
                    "alert","bloodwarn",
                },
            },
        },
        
    },
})

DXE:RegisterRealmPatch(realm, "augh", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Paralytic Blow Dart
        dartcd = {
            varname = format(L.alert["%s CD"],SN[84799]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[84799]),
            time = 12,
            time2 = 18,
            icon = ST[84799],
        },
        dartwarn = {
            varname = format(L.alert["%s Warning"],SN[84799]),
            text = format(L.alert["%s"],SN[84799]),
            icon = ST[84799],
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
            varname = format(L.alert["%s CD"],SN[83776]),
            text = format(L.alert["Next %s"],SN[83776]),
            time = 18,
            time2 = 19.5,
            icon = ST[83776],
        },
        breathwarn = {
            varname = format(L.alert["%s Warning"],SN[83776]),
            text = "<breathtext>",
            icon = ST[83776],
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
    events = {
        -- Paralytic Blow Dart
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 84799,
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
            spellname = 83776,
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
            spellname = 83776,
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
})

DXE:RegisterRealmPatch(realm, "barim", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "siamat", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Servant counter
        servantcountwarn = {
            varname = format(L.alert["%s counter Warning"],SN[91871]),
            text = "<servantcounttext>",
            time = 1,
            icon = ST[91871],
        },
        -- Phase 2
        phase2soonwarn = {
            varname = format(L.alert["%s soon Warning"],"Phase 2"),
            text = format(L.alert["%s soon ..."],"Phase 2"),
            icon = ST[11242],
        },
        phase2transition = {
            varname = format(L.alert["%s Transition Countdown"],"Phase 2"),
            text = format(L.alert["%s transition ..."],"Phase 2"),
            time = 6,
            icon = ST[11242],
        },
        phase2warn = {
            varname = format(L.alert["%s Warning"],"Phase 2"),
            text = format(L.alert["%s"],"Phase 2"),
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
})

DXE:RegisterRealmPatch(realm, "lostcitytrash", {
    windows = {
        proxwindow = false,
    },
})
