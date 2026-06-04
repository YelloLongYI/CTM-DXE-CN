-- Data_BlackrockCaverns_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "romogg", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "corla", {
    windows = {
        proxwindow = false,
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
})
