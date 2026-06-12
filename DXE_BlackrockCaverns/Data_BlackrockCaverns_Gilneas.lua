-- Data_BlackrockCaverns_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "romogg", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Quake
        quakecd = {
            varname = format(L.alert["%s CD"],SN[75272]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[75272]),
            time = 26,
            time2 = 8,
            flashtime = 5,
            color1 = "ORANGE",
            color2 = "RED",
            sound = "MINORWARNING",
            icon = ST[75272],
        },
    },
    events = {
        -- Quake
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 75272,
            execute = {
                {
                    "quash","quakecd",
                    "alert","quakecd",
                    "alert","quakewarn",
                },
            },
        },
        
        -- The Skullcracker
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 75543,
            execute = {
                {
                    "quash","quakecd",
                    "alert","skullcrackerwarn",
                    "alert",{"quakecd",time = 2},
                },
            },
        },
        
        -- Chains of Woe
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 75539,
            execute = {
                {
                    "alert","chainswarn",
                },
            },
        },
        
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 75441,
            execute = {
                {
                    "temptracing","#1#",
                    "raidicon","chainsmark",
                    "scheduletimer",{"removechains", 20},
                    
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 75539,
            execute = {
                {
                    "quash","quakecd",
                },
            },
        },
        
        -- Skullcracker kills Angered Earth - achievement [Crushing Bones and Cracking Skulls]
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 93454,
            execute = {
                {
                    "expect",{"&itemenabled|achievementcomplete&","==","true"},
                    "expect",{"#11#",">=","1"},
                    "expect",{"&npcid|#4#&","==","50376"},
                    "set",{elementalscount = "INCR|1"},
                    "expect",{"<elementalscount>",">=","10"},
                    "expect",{"<achievementwarned>","==","no"},
                    "set",{achievementwarned = "yes"},
                    "announce","achievementcomplete",
                },
            },
        },
        
    },
})

DXE:RegisterRealmPatch(realm, "corla", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        darkcommandcd = {22, 30, loop = false, type = "series"},
    },
})

DXE:RegisterRealmPatch(realm, "karsh", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "beauty", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Berserker Charge
        chargecd = {
            varname = format(L.alert["%s CD"],SN[16636]),
            text = format(L.alert["Next %s"],SN[16636]),
            time = 14,
            icon = ST[16636],
        },
        chargewarn = {
            varname = format(L.alert["%s Warning"],SN[16636]),
            time = 1,
            icon = ST[16636],
        },
        -- Flamebreak
        flamebreakcd = {
            varname = format(L.alert["%s CD"],SN[76032]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[76032]),
            time = 20,
            icon = ST[76032],
            behavior = "overwrite",
        },
        flamebreakwarn = {
            varname = format(L.alert["%s Warning"],SN[76032]),
            type = "simple",
            text = format(L.alert["%s"],SN[76032]),
            time = 1,
            icon = ST[76032],
        },
        -- Terrifying Roar
        roarcd = {
            varname = format(L.alert["%s CD"],SN[14100]),
            text = format(L.alert["Next %s"],SN[14100]),
            time = 30,
            icon = ST[14100],
        },
        roarwarn = {
            varname = format(L.alert["%s Warning"],SN[14100]),
            text = format(L.alert["%s"],SN[14100]),
            time = 1,
            icon = ST[14100],
        },
        -- Lava Drool
        lavaselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[76628]),
            text = format(L.alert["%s on %s - GET AWAY!"],SN[76628],L.alert["YOU"]),
            time = 1,
            icon = ST[76628],
            throttle = 2,
            emphasizewarning = {1,0.5},
        },
        -- Magma Spit
        spitcd = {
            varname = format(L.alert["%s CD"],SN[76628]),
            text = format(L.alert["Next %s"],SN[76628]),
            time = 10,
            icon = ST[76628],
        },
        spitwarn = {
            varname = format(L.alert["%s Warning"],SN[76628]),
            text = format(L.alert["%s"],SN[76628]),
            time = 1,
            icon = ST[76628],
        },
    },
    events = {
        -- Berserker Charge
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 16636,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{chargetext = format(L.alert["Beauty charges towards %s"],L.alert["YOU"])},
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{chargetext = format(L.alert["Beauty charges towards <%s>"],"#5#")},
                },
                {
                    "quash","chargecd",
                    "alert","chargecd",
                    "alert","chargewarn",
                },
            },
        },
        -- Flamebreak
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 76032,
            execute = {
                {
                    "alert","flamebreakwarn",
                    "alert","flamebreakcd",
                },
            },
        },
        -- Magma Spit
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 76628,
            execute = {
                {
                    "alert","spitwarn",
                    "alert","spitcd",
                },
            },
        },
        
        -- Terrifying Roar
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 14100,
            execute = {
                {
                    "quash","roarcd",
                    "alert","roarcd",
                    "alert","roarwarn",
                },
            },
        },
        -- Lava Drool
        {
            type = "combatevent",
            eventtype = "SPELL_PERIODIC_DAMAGE",
            spellname = 76628,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","lavaselfwarn",
                },
            },
        },
        
    },
})

DXE:RegisterRealmPatch(realm, "ascendantlordobsidius", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "blackrockcavernstrash", {
    windows = {
        proxwindow = false,
    },
    raidicons = {
        shacklesmark = {
            varname = format("%s {%s}",SN[76484],"PLAYER_DEBUFF"),
            texture = ST[76484],
        },
        volleymark = {
            varname = format("%s {%s-%s}",SN[76718],"ENEMY_CAST","Incediary Spark's"),
            texture = ST[76718],
        },
    },
    alerts = {
        -- Shackles
        shackleswarn = {
            varname = format(L.alert["%s Warning"],SN[76484]),
            icon = ST[76484],
        },
        -- Final Volley
        volleycd = {
            varname = format(L.alert["%s CD"],SN[76718]),
            text = format(L.alert["%s CD"],SN[76718]),
            time = 7,
            icon = ST[76718],
        },
        
    },
    events = {
        -- Shackles
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 76484,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{shacklestext = format(L.alert["%s on %s - DISPEL!"],SN[76484],L.alert["YOU"])},
                    "alert","shackleswarn",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{shacklestext = format(L.alert["%s on <%s> - DISPEL!"],SN[76484],"#5#")},
                    "alert","shackleswarn",
                },
                {
                    "raidicon","shacklesmark",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 76484,
            execute = {
                {
                    "removeraidicon","#5#",
                },
            },
        },
        -- Final Volley
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 76718,
            execute = {
                {
                    "alert","volleycd",
                    "raidicon","volleymark",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "UNIT_DIED",
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","40021"},
                    "quash",{"volleycd","#4#"},
                },
            },
        },
    },
})
