-- Data_VortexPinnacle_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "ertan", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        cyclonescd = {12, 30, loop = false, type = "series"},
    },
})

DXE:RegisterRealmPatch(realm, "altairus", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        breathcd = {26.5, 13.5, loop = false, type = "series"},
    },
})

DXE:RegisterRealmPatch(realm, "asaad", {
    windows = {
        proxwindow = false,
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
        staticcd = {
            varname = format(L.alert["%s CD"],SN[87618]),
            text = format(L.alert["Next %s"],SN[87618]),
            time = 10,
            time2 = 17,
            time3 = 24,
            flashtime = 5,
            icon = ST[87618],
        },
        -- Unstable Grounding Field
        fieldcd = {
            varname = format(L.alert["%s CD"],SN[86911]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[86911]),
            time = 18,
            time2 = 45,
            flashtime = 5,
            icon = ST[86911],
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
                    "quash","staticcd",
                    "alert",{"staticcd", time = 2},
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
                    "quash", "staticcd",
                    "alert", {"staticcd", time = 3},
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
})

DXE:RegisterRealmPatch(realm, "vortexpinnacletrash", {
    windows = {
        proxwindow = false,
    },
})
