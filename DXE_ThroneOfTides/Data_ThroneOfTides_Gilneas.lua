-- Data_ThroneOfTides_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

if DXE.db.profile.Globals.Realm == realm and L.chat_throneoftides then
    for k in pairs(L.chat_throneoftides) do
        L.chat_throneoftides[k] = k
    end
end

DXE:RegisterRealmPatch(realm, "ladynazjar", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Shock Blast
        blastcd = {
            varname = format(L.alert["%s CD"],SN[76008]),
            text = format(L.alert["Next %s"],SN[76008]),
            time = 11.5,
            flashtime = 5,
            icon = ST[76008],
        },
        blastwarn = {
            varname = format(L.alert["%s Warning"],SN[76008]),
            text = format(L.alert["%s - INTERRUPT!"],SN[76008]),
            icon = ST[76008],
        },
    },
    events = {
        -- Shock Blast
        {
            tag = "shock_blast_cast",
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 76008,
            execute = {
                {
                    "quash","blastcd",
                    "alert","blastcd",
                    "alert","blastwarn",
                },
            },
        },
        {
            tag = "shock_blast_kick",
            type = "event",
            event = "UNIT_SPELLCAST_INTERRUPTED",
            execute = {
                {
                    "expect",{"#2#","==",SN[76008]},
                    "expect",{"#1#","find","boss"},
                    "quash","blastwarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "ulthok", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        fissurecd = {7, 21, loop = false, type = "series"},
    },
    alerts = {
        -- Dark Fissure
        fissurecd = {
            varname = format(L.alert["%s CD"],SN[76047]),
            text = format(L.alert["Next %s"],SN[76047]),
            time = "<fissurecd>",
            icon = ST[76047],
        },
        fissurewarn = {
            varname = format(L.alert["%s Warning"],SN[76047]),
            text = format(L.alert["%s"],SN[76047]),
            icon = ST[76047],
        },

        -- Enrage
        enragecd = {
            varname = format(L.alert["%s CD"],SN[76100]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[76100]),
            time = 32.5,
            icon = ST[76100],
        },
        -- Squeeze
        squeezecd = {
            varname = format(L.alert["%s CD"],SN[76026]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[76026]),
            time = 13.2,
            time2 = 20,
            icon = ST[76026],
        },
        squeezedurwarn = {
            varname = format(L.alert["%s Duration"],SN[76026]),
            icon = ST[76026],
        },
    },
    events = {
        -- Dark Fissure
        {
            tag = "dark_fissure",
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 76047,
            execute = {
                {
                    "quash","fissurecd",
                    "alert","fissurecd",
                    "alert","fissurewarn",
                },
            },
        },
        -- Squeeze
        {
            tag = "squeeze_start",
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 76026,
            execute = {
                {
                    "quash","squeezecd",
                    "alert",{"squeezecd", time=2},
                },
            },
        },
        {
            tag = "squeeze_apply",
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 76026,
            execute = {
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{squeezetext = format(L.alert["%s on <%s>"],SN[76026],"#5#")},
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{squeezetext = format(L.alert["%s on %s"],SN[76026],L.alert["YOU"])},
                },
                {
                    "alert","squeezedurwarn",
                },
            },
        },
        {
            tag = "squeeze_remove",
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 76026,
            execute = {
                {
                    "quash","squeezedurwarn",
                },
            },
        },
        
    },
})

DXE:RegisterRealmPatch(realm, "ghursha", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "ozumat", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "tottrash", {
    windows = {
        proxwindow = false,
    },
})
