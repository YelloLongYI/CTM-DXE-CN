-- Data_ShadowfangKeep_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "baronashbury", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        paincd = {6, 23, loop = false, type = "series"},
        asphyxiatecd = {20.5,47, loop = false, type = "series"},
    },
    alerts = {
        -- Asphyxiate
        asphyxiatecd = {
            varname = format(L.alert["%s CD"],SN[93423]),
            text = format(L.alert["Next %s"],SN[93423]),
            time = "<asphyxiatecd>",
            icon = ST[93423],
        },
        asphyxiatewarn = {
            varname = format(L.alert["%s Warning"],SN[93423]),
            text = format(L.alert["%s"],SN[93423]),
            icon = ST[93423],
        },
    },
})

DXE:RegisterRealmPatch(realm, "baronsilverlaine", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        cursedveilcd = {5.5, 26.8, loop = false, type = "series"},
    },
    alerts = {
        -- Cursed Veil 
        cursedveilcd = {
            varname = format(L.alert["%s CD"],SN[93956]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[93956]),
            time = "<cursedveilcd>",
            icon = ST[93956],
        },
    },
})

DXE:RegisterRealmPatch(realm, "commanderspringvale", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        -- Timers
        desecrationcd = {9.5,29, loop = false, type = "series"},
    },
    alerts = {
        -- Desecration 
        desecrationcd = {
            varname = format(L.alert["%s CD"],SN[93687]),
            text = format(L.alert["Next %s"],SN[93687]),
            icon = ST[93687],
        },
        desecrationwarn = {
            varname = format(L.alert["%s Warning"],SN[93687]),
            text = format(L.alert["%s"],SN[93687]),
            icon = ST[93687],
        },
        desecrationselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[93687]),
            text = format(L.alert["%s on %s - GET AWAY!"],SN[93687],L.alert["YOU"]),
            icon = ST[93687],
        },
    },
    events = {
        -- Desecration 
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 93687,
            execute = {
                {
                    "quash","desecrationcd",
                    "alert","desecrationcd",
                    "alert","desecrationwarn",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = {94370, 93687},
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","desecrationselfwarn",
                },
            },
        },
        
        -- Summon Worgen Spirit
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 93857,
            execute = {
                {
                    "alert","summonwarn",
                    "scheduletimer",{"spawningcountdown",2},
                },
            },
        },
        -- Unholy Empowerment
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 93844,
            execute = {
                {
                    "set",{unholyemptext = format(L.alert["%s: %s - INTERRUPT!"],"#2#",SN[93844])},
                    "alert","unholyempwarn",
                },
            }
        },
        -- Unholy Empowerment
        {
            type = "combatevent",
            eventtype = "SPELL_HEAL",
            spellname = 93844,
            execute = {
                {
                    "expect",{"<groundfailed>","==","no"},
                    "expect",{"&npcid|#4#&","==","4278"},
                    "announce","groundfailed",
                    "set",{groundfailed = "yes"},
                },
            },
        },
        {
            type = "event",
            event = "UNIT_SPELLCAST_INTERRUPTED",
            execute = {
                {
                    "expect",{"#2#","==",SN[93844]},
                    "expect",{"&unitisplayertype|#1#&","==","false"},
                    "quash",{"unholyempwarn","&unitguid|#1#&"},
                    
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "UNIT_DIED",
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","50613"},
                    "quash",{"unholyempwarn","#4#"},
                },
                {
                    "expect",{"&npcid|#4#&","==","50615"},
                    "quash",{"unholyempwarn","#4#"},
                },
            },
        },
        -- Unholy Power = 1
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 93735,
            execute = {
                {
                    "set",{unholypowercount = "INCR|1"},
                },
            },
        },
        -- Unholy Power > 1
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED_DOSE",
            spellname = 93686,
            execute = {
                {
                    "set",{unholypowercount = "INCR|1"},
                },
            },
        },
        -- Word of Shame
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 93852,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{wordofshametext = format(L.alert["%s on %s"],SN[93852],L.alert["YOU"])},
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{wordofshametext = format(L.alert["%s on <%s>"],SN[93852],"#5#")},
                },
                {
                    "alert","wordofshamewarn",
                    "set",{unholypowercount = 0},
                },
            },
        },
        -- Shield of the Perfidious
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 93736,
            execute = {
                {
                    "set",{unholypowercount = 0},
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "lordwalden", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Ice Shards
        shardswarn = {
            varname = format(L.alert["%s Warning"],SN[93527]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[93527]),
            icon = ST[93527],
        },
    },
    events = {
        -- Ice Shards
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 93527,
            execute = {
                {
                    "alert","shardswarn",
                },
            },
        },
        -- Next possible mixture (Conjure Poisonous Mixture)
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 93704,
            execute = {
                {
                    --"alert","possiblemixturecd",
                },
            },
        },
        -- Next possible mixture (Conjure Frost Mixture)
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 93702,
            execute = {
                {
                    --"alert","possiblemixturecd",
                },
            },
        },
        -- Conjure Mystery Toxin Warning
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 93562,
            execute = {
                {
                    "alert","mysterytoxinwarn",
                },
            },
        },
        
        -- Toxic Coagulent 
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 93617,
            execute = {
                {
                    "expect",{"coagualntwarned","==","no"},
                    "set",{coagualntwarned = "yes"},
                    "scheduletimer",{"coagualntreset",10},
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","coagulentwarn",
                },
            },
        },
        -- Toxic Catalyst
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 93689,
            execute = {
                {
                    "alert","catalystwarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "lordgodfrey", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        ghoulscd = {6,30, loop = false, type = "series"},
    },
    alerts = {
        -- Pistol Barrage
        barragecd = {
            varname = format(L.alert["%s CD"],SN[93520]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[93520]),
            time = 11.5,
            time2 = 30
            color1 = "YELLOW",
            sound = "MINORWARNING",
            icon = ST[93520],
        },
        -- Summon Bloodthirsty Ghouls
        ghoulscd = {
            varname = format(L.alert["%s CD"],SN[93707]),
            text = format(L.alert["New %s"],"Bloodthirsty Ghouls"),
            time = "<ghoulscd>",
            icon = ST[93707],
        },
        -- Cursed Bullets
        bulletswarn = {
            varname = format(L.alert["%s Warning"],SN[93629]),
            type = "centerpopup",
            text = format(L.alert["%s - INTERRUPT!"],SN[93629]),
            time = 1,
            flashtime = 1,
            color1 = "CYAN",
            sound = "ALERT2",
            icon = ST[93629],
        },
    },
    events = {
        -- Pistol Barrage
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 93520,
            execute = {
                {
                    "quash","barragecd",
                    "alert",{"barragecd",time = 2},
                    "alert","barragewarn",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 93520,
            execute = {
                {
                    "alert","barragedur",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 93784,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","barrageselfwarn",
                },
            },
        },
        
        -- Summon Bloodthirsty Ghouls
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 93707,
            execute = {
                {
                    "quash","ghoulscd",
                    "alert","ghoulscd",
                    "alert","ghoulswarn",
                },
            },
        },
        -- Cursed Bullets
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 93629,
            execute = {
                {
                    "alert","bulletswarn",
                },
            },
        },
        -- Cursed Bullets - Interrupt
        {
            type = "event",
            event = "UNIT_SPELLCAST_INTERRUPTED",
            execute = {
                {
                    "expect",{"#2#","==",SN[93629]},
                    "expect",{"#1#","find","boss"},
                    "quash","bulletswarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "sfktrash", {
    windows = {
        proxwindow = false,
    },
})
