-- Data_Baradin_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "argaloth", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        meteorcd = {
            varname = format(L.alert["%s CD"],SN[45150]),
            text = format(L.alert["Next %s"],SN[45150]),
            time = 16.5,
            icon = ST[45150],
        },
        meteorwarn = {
            varname = format(L.alert["%s Warning"],SN[45150]),
            text = "<meteortext>",
            time = 3,
            icon = ST[45150],
        },
        -- Fel Firestorm
        firestormwarn = {
            varname = format(L.alert["%s Warning"],SN[88972]),
            text = format(L.alert["%s"],SN[88972]),
            time = 3,
            icon = ST[88972],
        },
        firestormdur = {
            varname = format(L.alert["%s Duration"],SN[88972]),
            text = format(L.alert["%s"],SN[88972]),
            time = 18,
            flashtime = 5,
            icon = ST[88972],
        },
        consumingcd = {
            varname = format(L.alert["%s CD"],SN[88954]),
            text = format(L.alert["Next %s"],SN[88954]),
            time = 22,
            flashtime = 5,
            icon = ST[88954],
        },
    },  
    events = {
    -- Consuming Darkness
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 95173,       
            execute = {
                {
                "quash","consumingcd",
                "alert","consumingcd",
                },
            },              
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 88954,
            execute = {
                {
                "quash","consumingcd",
                "alert","consumingcd",
                },
            },              
        },
        -- Meteor Slash
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 45150,
            execute = {
                {
                    "quash","meteorcd",
                    "alert","meteorcd",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 88942,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{meteortext = format("%s (%s) on %s",SN[88942],"1",L.alert["YOU"])},
                    "alert","meteorwarn",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED_DOSE",
            spellname = 88942,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{meteortext = format("%s (%s) on %s",SN[88942],"#11#",L.alert["YOU"])},
                    "alert","meteorwarn",
                },
            },
        },
        
        
        -- Fel Firestorm
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 88972,
            execute = {
                {
                    "quash","meteorcd",
                    "alert","firestormdur",
                    "alert","firestormwarn",
                },
            },
        },
    }, 
})

DXE:RegisterRealmPatch(realm, "occuthar", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "Alizabal", {
    windows = {
        proxwindow = false,
    },
})
