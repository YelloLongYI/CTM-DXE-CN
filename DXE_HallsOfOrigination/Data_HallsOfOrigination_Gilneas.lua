-- Data_HallsOfOrigination_Gilneas.lua
local L, SN, ST, TI, AN, AT = DXE.L, DXE.SN, DXE.ST, DXE.TI, DXE.AN, DXE.AT
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "anhuur", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Divine Reckoning
        reckoningcd = {
            varname = format(L.alert["%s CD"],SN[75592]),
            text = format(L.alert["%s CD"],SN[75592]),
            time = 21,
            time2 = 5, -- init
            time3 = 20, -- after Hymn interrupt
            icon = ST[75592],
        },
        reckoningwarn = {
            varname = format(L.alert["%s Warning"],SN[75592]),
            icon = ST[75592],
        },
        -- Burning Light
        lightcd = {
            varname = format(L.alert["%s CD"],SN[75115]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[75115]),
            time = 12,
            time2 = 13, -- after Hymn interrupt
            flashtime = 5,
            color1 = "LIGHTBLUE",
            color2 = "CYAN",
            sound = "MINORWARNING",
            icon = ST[75115],
            throttle = 1,
        },
        lightwarn = {
            varname = format(L.alert["%s Warning"],SN[75115]),
            type = "simple",
            text = format(L.alert["%s"],SN[75115]),
            time = 1,
            color1 = "TURQUOISE",
            color2 = "RED",
            sound = "ALERT8",
            icon = ST[75115],
        },
        lightselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[75115]),
            type = "simple",
            text = format(L.alert["%s on %s - GET AWAY!"],SN[75115],L.alert["YOU"]),
            time = 1,
            color1 = "CYAN",
            sound = "ALERT10",
            icon = ST[75115],
            throttle = 2,
            emphasizewarning = {1,0.5},
        },
        -- Reverberating Hymn
        hymnsoonwarn = {
            varname = format(L.alert["%s soon Warning"],SN[75322]),
            type = "simple",
            text = format(L.alert["%s soon ..."],SN[75322]),
            time = 1,
            color1 = "YELLOW",
            sound = "MINORWARNING",
            icon = ST[11242],
        },
        hymnwarn = {
            varname = format(L.alert["%s Warning"],SN[75322]),
            type = "simple",
            text = format(L.alert["%s"],SN[75322]),
            time = 1, -- 180,
            color1 = "YELLOW",
            sound = "ALERT1",
            icon = ST[75322],
        },
        -- Achievement: I Hate That Song
        hatethatsongcd = {
            varname = format(L.alert["%s %s Countdown"],TI["AchievementShield"],AN[5293]),
            type = "dropdown",
            text = format(L.alert["%s window"],AN[5293]),
            time = 15,
            flashtime = 5,
            color1 = "ORANGE",
            color2 = "YELLOW",
            sound = "MINORWARNING",
            icon = AT[5293],
        },
        
    },
    events = {
        -- Reverberating Hymn
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 75322,
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","39425"},
                    "quash","reckoningcd",
                    "quash","lightcd",
                    "alert","hymnwarn",
                    "expect",{"&difficulty&","==","2"},
                    "expect",{"<hatethatsongfailed>","==","no"},
                    "alert","hatethatsongcd",
                    "scheduletimer",{"hatethatsongtimer", 15},
                },
            },
        },
        -- Reverberating Hymn (interrupt)
        {
            type = "event",
            event = "UNIT_SPELLCAST_CHANNEL_STOP",
            execute = {
                {
                    "expect",{"#2#","==",SN[75322]},
                    "expect",{"#1#","find","boss"},
                    "invoke",{
                        {
                            "quash","hymnwarn",
                            "alert",{"reckoningcd",time = 3},
                            "alert",{"lightcd",time = 2},
                            "expect",{"&difficulty&","==","2"},
                            "canceltimer","hatethatsongtimer",
                        },
                        {
                            "expect",{"<hymn1warned>","==","yes"},
                            "expect",{"<hymn2warned>","==","yes"},
                            "expect",{"&difficulty&","==","2"},
                            "expect",{"<hatethatsongfailed>","==","no"},
                            "expect",{"<hatethatsongcomplete>","==","no"},
                            "set",{hatethatsongcomplete = "yes"},
                            "announce","hatethatsongcomplete",
                        },
                    },
                },
            },
        },
        -- Divine Reckoning
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 75592,
            execute = {
                {
                    "quash","reckoningcd",
                    "alert","reckoningcd",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 75592,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{reckoningtext = format(L.alert["%s on %s - DISPEL!"],SN[75592],L.alert["YOU"])},
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{reckoningtext = format(L.alert["%s on <%s> - DISPEL!"],SN[75592],"#5#")},
                },                    
                {
                    "alert","reckoningwarn",
                },
            },
        },
        {
            type = "event",
            event = "UNIT_SPELLCAST_SUCCEEDED",
            execute = {
                {
                    "expect",{"#2#","==",SN[75115]},
                    "expect",{"#1#","==","boss1"},
                    "quash","lightcd",
                    "alert","lightcd",
                    "alert","lightwarn",
                },
            },
        },
        -- Burning Light
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 75115,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","lightselfwarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "ptah", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Earth Spike
        spikewarn = {
            varname = format(L.alert["%s Warning"],SN[75339]),
            text = format(L.alert["%s"],SN[75339]),
            icon = ST[75339],
        },
        -- Quicksand
        quicksandself = {
            varname = format(L.alert["%s on me Warning"],SN[75547]),
            text = format(L.alert["%s on %s - GET AWAY!"],SN[75547],L.alert["YOU"]),
            icon = ST[75547],
        },
    },
    events = {
        -- Earth Spike
        {
            type = "event",
            event = "UNIT_SPELLCAST_SUCCEEDED",
            execute = {
                {
                    "expect",{"#2#","==",SN[75339]},
                    "expect",{"#1#","==","boss1"},
                    "alert","spikewarn",
                },
            },
        },
        -- Sandstorm
        {
            type = "event",
            event = "UNIT_SPELLCAST_SUCCEEDED",
            execute = {
                {
                    "expect",{"#2#","==",SN[75491]},
                    "expect",{"#1#","==","boss1"},
                    "alert","stormwarn",
                },
            },
        },
        -- Quicksand
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 75547,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","quicksandself",
                },
            },
        },
        
    },
})

DXE:RegisterRealmPatch(realm, "volevent", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "anraphet", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        alphawarn = {
            varname = format(L.alert["%s Warning"],SN[76184]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[76184]),
            time = 3,
            color1 = "PURPLE",
            sound = "ALERT2",
            icon = ST[76184],
        },
        alphaduration = {
            varname = format(L.alert["%s Warning"],SN[76184]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[76184]),
            time = 12.5,
            color1 = "MAGENTA",
            color2 = "RED",
            sound = "MINORWARNING",
            icon = ST[76184],
        },
        alphaselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[76184]),
            type = "simple",
            text = format(L.alert["%s on %s - GET AWAY!"],SN[76184],L.alert["YOU"]),
            icon = ST[76184],
        },
        -- Omega Stance
        omegacd = {
            varname = format(L.alert["%s CD"],SN[75623]),
            text = format(L.alert["%s CD"],SN[75623]),
            icon = ST[75623],
        },
        omegawarn = {
            varname = format(L.alert["%s Warning"],SN[75623]),
            text = format(L.alert["%s"],SN[75623]),
            icon = ST[75623],
        },
        omegaduration = {
            varname = format(L.alert["%s Duration"],SN[75623]),
            text = format(L.alert["%s"],SN[75623]),
            time = 8,
            icon = ST[75623],
        },
        -- Nemesis Strike
        nemesiswarn = {
            varname = format(L.alert["%s Warning"],SN[75604]),
            icon = ST[75604],
        },
        
    },
    events = {
        -- Alpha Beams
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 76184,
            execute = {
                {
                    "quash","alphacd",
                    "alert","alphacd",
                    "alert","alphawarn",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 76184,
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","39788"},
                    "alert","alphaduration",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 76184,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","alphaselfwarn",
                },
            },
        },
        
        -- Omega Stance
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 75623,
            execute = {
                {
                    "quash","omegacd",
                    "alert","omegacd",
                    "alert","omegawarn",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 75623,
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","39788"},
                    "alert","omegaduration",
                },
            },
        },
        -- Nemesis Strike
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 75604,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{nemesistext = format(L.alert["%s on %s - DISPEL!"],SN[75604],L.alert["YOU"])},
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{nemesistext = format(L.alert["%s on <%s> - DISPEL!"],SN[75604],"#5#")},
                },
                {
                    "alert","nemesiswarn",
                },
            },
        },
        
    },
})

DXE:RegisterRealmPatch(realm, "ammunae", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Noxious Spores
        sporesselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[75702]),
            text = format(L.alert["%s on %s - GET AWAY!"],SN[75702],L.alert["YOU"]),
            icon = ST[75702],
        },
        -- Rampant Growth
        growthcd = {
            varname = format(L.alert["%s CD"],SN[75790]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[75790]),
            time =  63,
            time2 = 70,
            icon = ST[75790],
        },
        growthwarn = {
            varname = format(L.alert["%s Warning"],SN[75790]),
            text = format(L.alert["%s"],SN[75790]),
            icon = ST[75790],
        },
    },
    events = {
        -- Wither
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 76043,
            execute = {
                {
                    "quash","withercd",
                    "alert","withercd",
                    "alert","withercastwarn",
                },
            },
        },
        {
            type = "event",
            event = "UNIT_SPELLCAST_INTERRUPTED",
            execute = {
                {
                    "expect",{"#2#","==",SN[76043]},
                    "expect",{"#1#","find","boss"},
                    "quash","withercastwarn",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 76043,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{withertext = format(L.alert["%s on %s - DISPEL!"],SN[76043],L.alert["YOU"])},
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{withertext = format(L.alert["%s on <%s> - DISPEL!"],SN[76043],"#5#")},
                },
                {
                    "alert","witherwarn",
                },
            },
        },
        -- Noxious Spores
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 75702,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","sporesselfwarn",
                },
            },
        },
        -- Rampant Growth
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 75790,
            execute = {
                {
                    "quash","growthcd",
                    "alert","growthcd",
                    "alert","growthwarn",
                },
            },
        },
        
    },
})

DXE:RegisterRealmPatch(realm, "setesh", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Chaos Portal
        portalwarn = {
            varname = format(L.alert["%s Warning"],SN[76784]),
            type = "simple",
            text = format(L.alert["%s - DESTROY IT"],SN[76784]),
            time = 1,
            color1 = "PINK",
            sound = "BEWARE",
            icon = ST[57536],
            throttle = 2,
        },
        -- Chaos Burn
        burnselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[76681]),
            type = "simple",
            text = format(L.alert["%s on %s - MOVE AWAY!"],SN[76681],L.alert["YOU"]),
            icon = ST[76681],
        },
    },
    events = {
        -- Chaos Portal
        {
            type = "event",
            event = "UNIT_SPELLCAST_SUCCEEDED",
            execute = {
                {
                    "expect",{"#2#","==",SN[76784]},
                    "expect",{"&difficulty&","==","2"},
                    "alert","portalwarn",
                },
            },
        },
        -- Chaos Burn
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 76681,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","burnselfwarn",
                },
            },
        },
        
    },
})

DXE:RegisterRealmPatch(realm, "isiset", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "rajh", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "hootrash", {
    windows = {
        proxwindow = false,
    },
})
