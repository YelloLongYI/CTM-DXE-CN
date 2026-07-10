-- Data_Descent_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

if DXE.db.profile.Globals.Realm == realm and L.chat_descent then
    for k in pairs(L.chat_descent) do
        L.chat_descent[k] = k
    end
end

DXE:RegisterRealmPatch(realm, "magmaw", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        -- Timers
        manglecd = {89.9,95, loop = false, type = "series"},  -- 90,115,115
        slumpcd = {102,96, loop = false, type = "series"},
        constructcd = {25,31.5, loop = false, type = "series"}, --heroic only
        pillarcd = {33, 37, 0, loop = true, type = "series"},
            
        -- Switches
        parasitefailed = "no",
        lavaspewthrottle = "no",
    },
    alerts = {
        -- Berserk
        enragecd = {
            varname = format(L.alert["%s CD"],SN[26662]),
            type = "dropdown",
            text = format(L.alert["Berserk"],SN[26662]),
            time = 600,
            flashtime = 30,
            color1 = "RED",
            icon = ST[26662],
        },
        -- Lava Spew
        lavaspewcd = {
            varname = format(L.alert["%s CD"],SN[77689]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[77689]),
            time = 22,
            time2 = 36,
            time3 = 16,
            flashtime = 5,
            color1 = "YELLOW",
            sound = "MINORWARNING",
            icon = ST[77689],
            throttle = 5,
        },
        lavaspewwarn = {
            varname = format(L.alert["%s Warning"],SN[77689]),
            type = "centerpopup",
            fillDirection = "DEPLETE",
            text = format(L.alert["%s"],SN[77689]),
            time = 5,
            color1 = "ORANGE",
            sound = "ALERT4",
            icon = ST[77689],
            throttle = 5,
        },
        -- Mangle
        manglecd = {
            varname = format(L.alert["%s CD"],SN[78412]),
            text = format(L.alert["Next %s"],SN[78412]),
            time = "<manglecd>",
            flashtime = 10,
            icon = ST[78412],
        },
        manglewarn = {
            varname = format(L.alert["%s Warning"],SN[78412]),
            text = "<mangletext>",
            time = 30,
            flashtime = 30,
            icon = ST[78412],
        },
        -- Pillar of Flame
        pillarcd = {
            varname = format(L.alert["%s CD"],L.npc_descent["Lava Parasites"]),
            type = "dropdown",
            text = format(L.alert["New %s"],L.npc_descent["Lava Parasites"]),
            time = "<pillarcd>",
            time2 = 40,
            time3 = 20,
            flashtime = 5,
            sound = "ALERT4",
            color1 = "PINK",
            icon = ST[78097],
        },
        pillarwarn = {
            varname = format(L.alert["%s Warning"],L.npc_descent["Lava Parasites"]),
            type = "simple",
            text = format(L.alert["New: %s"],L.npc_descent["Lava Parasites"]),
            time = 5,
            flashtime = 5,
            color1 = "MAGENTA",
            sound = "ALERT10",
            icon = ST[78097],
        },
        -- Massive Crash
        slumpcd = {
            varname = format(L.alert["%s CD"],SN[88253]),
            text = format(L.alert["Magmaw Slumping"]),
            time = "<slumpcd>",
            time2 = 104.3,
            icon = ST[88253],
        },
        slumpwarn = {
            varname = format(L.alert["%s Warning"],SN[88253]),
            type = "simple",
            text = format(L.alert["Mount him like you mean it!"]),
            time = 5,
            icon = ST[78632],
        },
        -- Impale
        mountduration = {
            varname = format(L.alert["%s Duration"],"Magmaw Impaled"),
            type = "centerpopup",
            text = format(L.alert["%s frees himself"],"Magmaw"),
            time = 6,
            color1 = "LIGHTBLUE",
            sound = "None",
            icon = ST[78632],
        },
        -- Head Exposed
        exposeddur = {
            varname = format(L.alert["Exposed Head Duration"]),
            type = "centerpopup",
            text = format(L.alert["Exposed Head!"]),
            time = 30,
            flashtime = 30,
            color1 = "GOLD",
            sound = "BURST",
            icon = ST[79011],
            audiocd = true,
        },
        ------------
        -- Heroic --
        ------------
        -- Blazing Inferno
        constructcd = {
            varname = format(L.alert["%s CD"],SN[92154]),
            text = format(L.alert["New %s"],SN[92154]),
            time = "<constructcd>",
            flashtime = 7.5,
            icon = ST[92154],
        },
        -- Armageddon
        armageddonwarn = {
            varname = format(L.alert["%s Warning"],SN[92177]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[92177]),
            time = 8,
            flashtime = 8,
            color1 = "RED",
            sound = "BEWARE",
            icon = ST[92177],
            tag = "#1#",
        },
        -- Phase 2
        p2warn = {
            varname = format(L.alert["Phase 2 Warning"]),
            type = "simple",
            text = format(L.alert["Phase 2"]),
            time = 5,
            flashtime = 5,
            icon = ST[11242],
            color1 = "TURQUOISE",
            sound = "BEWARE",
        },
    },
    events = {
        -- Lava Spew
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 91919,
            execute = {
                {
                    "alert","lavaspewwarn",
                    "invoke",{
                        {
                            "expect",{"<lavaspewthrottle>","==","no"},
                            "set",{lavaspewthrottle = "yes"},
                            "quash","lavaspewcd",
                            "scheduletimer",{"lavaspewthrottletimer", 7},
                        },
                    },
                    "expect",{"&timeleft|manglecd&",">","22"},
                    "alert","lavaspewcd",
                },
            },
        },
        -- Pillar (New: Parasites)
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 78006,
            dstnpcid = 41570,
            execute = {
                {
                    "alert","pillarwarn",
                    "alert","pillarcd",
                },
            },
        },
        -- Mangle
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = {
                -- todo: confirm spell
                78412,
                94616,
                94617,
                89773,
            },
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{mangletext = format(L.alert["%s on %s!"],SN[78412],L.alert["YOU"])},
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{mangletext = format(L.alert["%s on <%s>"],SN[78412],"#5#")},
                },
                {
                    "alert","manglewarn",
                    "alert","manglecd",
                },
            },
        },
        {
            type = "event",
            event = "UNIT_SPELLCAST_SUCCEEDED",
            execute = {
                -- Head smashes
                {
                    "expect",{"#5#","==","88253"},
                    "expect",{"#1#","find","boss"},
                    "quash","pillarcd",
                    "alert",{"pillarcd",time = 3},
                    "set",{pillarcd = {32.5, 33.8, 0, loop = false, type = "series"}},
                    "alert","slumpwarn",
                    "quash","slumpcd",
                    "alert","slumpcd",
                    "alert","mountduration",
                    "quash","lavaspewcd",
                    "alert",{"lavaspewcd",time = 3},
                },
                -- Head is impaled
                {
                    "expect",{"#2#","==",SN[77907]},
                    "expect",{"#1#","find","boss"},
                    "tracing",{42347},
                    "scheduletimer",{"exposedtimer", 30},
                    "alert","exposeddur",
                    "quash","manglecd",
                    "quash","mountduration",
                    "alert","manglecd",
                    "quash","slumpcd",
                    "alert",{"slumpcd",time = 2},
                    "quash","pillarcd",
                    "alert",{"pillarcd",time = 2},
                    "quash","lavaspewcd",
                    "alert",{"lavaspewcd",time = 2},
                    "set",{pillarcd = {33,37, loop = true, type = "series"}},
                },
            },
        },
        -- Parasite Evening (achievement)
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 91913,
            execute = {
                {
                    "expect",{"<parasitefailed>","==","no"},
                    "set",{parasitefailed = "yes",
                        parasitefailer = "#5#",
                    },
                    "announce","parasitefailed",
                },
            },
        },
        ------------
        -- Heroic --
        ------------
        -- Blazing Inferno (New: Blazing Bone Construct)
        {
            type = "combatevent",
            eventtype = "SPELL_SUMMON",
            spellname = 92154,
            execute = {
                {
                    "quash","constructcd",
                    "alert","constructcd",
                },
            },
        },
        -- Armageddon (Blazing Bone Construct @ low HP)
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 92177,
            execute = {
                {
                    "alert","armageddonwarn",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "UNIT_DIED",
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","49416"},
                    "quash",{"armageddonwarn","#4#"},
                },
            },
        },
        -- Phase 2
        {
            type = "event",
            event = "YELL",
            execute = {
                {
                    "expect",{"#1#","find",L.chat_descent["^Incon"]},
                    "quash","constructcd",
                    "alert","p2warn",
                    "range",{true},
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "omnitron", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        -- Texts
        activetext = "",
        encasingtext = "",
        conductortext = "",
        infusiontext = "",
        fixedtext = "",
        
        -- Timers
        incinerationcd = {10,26,28.5,0, loop = true, type = "series"},
        flamethrowercd = {20,40,0, loop = true, type = "series"},
        generatorcd = {15,30,30,0, loop = true, type = "series"},
        conductorcd = {11,25,25,25,0, loop = true, type = "series"},
        poisonbombcd = {11,30,30,0, loop = true, type = "series"},  -- 15,30,30,0 
        addscd = {21,45,0, loop = true, type = "series"},
        
        -- Durations
        activetime = 45,
        conductordur = 10,
        
        -- Switches
        shadowconductorwarned = "no",
        started = "no",
    },
    alerts = {
        -- Golem Active
        activedur = {
            varname = format(L.alert["%s Duration"],SN[95016]),
            text = format(L.alert["Next Golem Activates"]),
            time = "<activetime>",
            icon = ST[95016]
        },
        activewarn = {
            varname = format(L.alert["%s Warning"],SN[95016]),
            text = "<activewarntext>",
            icon = ST[95016],
        },
        -----------------
        --- Magmatron ---
        -----------------
        -- Incineration Security Measure
        incinerationcd = {
            varname = format(L.alert["%s CD"],L.alert["Incineration"]),
            text = format(L.alert["Next %s"],L.alert["Incineration"]),
            time = "<incinerationcd>",
            icon = ST[79023]
        },
        incinerationwarn = {
            varname = format(L.alert["%s Warning"],L.alert["Incineration"]),
            text = format("%s!",L.alert["Incineration"]),
            time = 5.5,
            icon = ST[79023],
        },
        -- Flamethrower
        flamethrowercd = {
            varname = format(L.alert["%s CD"],SN[79504]),
            text = format(L.alert["Next %s"],SN[79504]),
            time = "<flamethrowercd>",
            icon = ST[79504]
        },
        flamethrowerdur = {
            -- varname = "Acquiring Target Warning",
            varname = format(L.alert["%s Warning"],SN[79504]),
            type = "centerpopup",
            text = "<flamethrowertext>",
            time = 8,
            icon = ST[79504],
        },
        flamethrowerselfwarn = {
            -- varname = "Acquiring Target on me Warning",
            varname = format(L.alert["%s on me Warning"],SN[79504]),
            text = format(L.alert["%s on <%s>!"],SN[79504],L.alert["YOU"]),
            time = 8,
            icon = ST[79504],
        },
        -- Encasing Shadows (heroic)
        encasingwarn = {
            varname = format(L.alert["%s Warning"],SN[92023]),
            type = "centerpopup",
            text = "<encasingtext>",
            time = 8,
            color1 = "GOLD",
            sound = "ALERT12",
            icon = ST[92023],
        },
        encasingselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[92023]),
            type = "centerpopup",
            text = format(L.alert["<%s> can't move!"],L.alert["YOU"]),
            time = 8,
            color1 = "PINK",
            sound = "None",
            icon = ST[92023],
            flashscreen = true,
        },
        ------------------
        --- Arcanotron ---
        ------------------
        -- Power Generator
        generatorcd = {
            varname = format(L.alert["%s CD"],SN[79624]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[79624]),
            time = "<generatorcd>",
            flashtime = 5,
            color1 = "INDIGO",
            icon = ST[79624],
            sticky = true,
        },
        -- Overcharged Power Generator (heroic)
        overcharged = {
            varname = format(L.alert["Overcharged Zone Countdown"]),
            type = "dropdown",
            text = format(L.alert["Overcharged Zone, get out!"]),
            time = 10,
            flashtime = 8,
            color1 = "WHITE",
            -- sound = "RUNAWAY",
            sound = "bluecircleboom",
            icon = ST[91857],
            throttle = 10,
        },
        -- Arcane Annihilator
        annihilatorcd = {
            varname = format(L.alert["%s CD"],SN[79710]),
            text = format(L.alert["Next %s"],SN[79710]),
            time10man = 7.2,
            time25man = 3.65,
            time2 = 3.5,
            icon = ST[79710],
        },
        annihilatorwarn = {
            varname = format(L.alert["%s Warning"],SN[79710]),
            text = format(L.alert["%s - INTERRUPT"],SN[79710]),
            icon = ST[79710],
        },
        
        ----------------
        --- Electron ---
        ----------------
        -- Lightning Conductor
        conductorcd = {
            varname = format(L.alert["%s CD"],SN[79889]),
            text = format(L.alert["Next %s"],SN[79889]),
            time = "<conductorcd>",
            icon = ST[79889],
        },
        conductorwarn = {
            varname = format(L.alert["%s Warning"],SN[79889]),
            type = "simple",
            text = "<conductortext>",
            time = "<conductordur>",
            flashtime = 16,
            icon = ST[79889]
        },
        conductorselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[79889]),
            type = "centerpopup",
            text = format("%s on <%s>",SN[79889],L.alert["YOU"]),
            time = "<conductordur>",
            flashtime = 16,
            color1 = "CYAN",
            sound = "RUNAWAY",
            icon = ST[79889]
        },
        -- Shadow Infusion (heroic)
        infusionwarn = {
            varname = format(L.alert["%s Warning"],SN[92048]),
            type = "simple",
            text = "<infusiontext>",
            time = 5,
            color1 = "MAGENTA",
            -- sound = "ALERT2",
            sound = "shadowae",
            icon = ST[92048]
        },
        infusionselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[92048]),
            type = "simple",
            text = format("Shadow Conductor on <%s>!",L.alert["YOU"]),
            time = 16,
            flashtime = 16,
            color1 = "TURQUOISE",
            sound = "RUNAWAY",
            icon = ST[92048],
        },
        infusiondur = {
            varname = format(L.alert["%s Duration"],SN[92048]),
            type = "centerpopup",
            text = format("%s incoming",SN[92051]),
            time = 5,
            flashtime = 5,
            color1 = "MAGENTA",
            sound = "None",
            icon = ST[92048],
        },
        -- Shadow Conductor (heroic)
        shadowconductordur = {
            varname = format(L.alert["%s Duration"],SN[92051]),
            type = "centerpopup",
            text = "<shadowconductortext>",
            time = 10,
            flashtime = 16,
            color1 = "TURQUOISE",
            sound = "ALERT10",
            icon = ST[92051],
            fillDirection = "DEPLETE",
        },
        ----------------
        --- Toxitron ---
        ----------------
        -- Chemical Bomb
        poisonbombcd = {
            varname = format(L.alert["Poison Cloud CD"],SN[80157]),
            type = "dropdown",
            text = format(L.alert["Next Poison Cloud"],SN[80157]),
            time = "<poisonbombcd>",
            flashtime = 5,
            color1 = "LIGHTGREEN",
            icon = ST[80157],
            sound = "MINORWARNING",
        },
        -- Poison Protocol
        addscd = {
            varname = format(L.alert["%s CD"],SN[80053]),
            text = format(L.alert["New %s"],"Poison Bombs"),
            time = "<addscd>",
            flashtime = 5,
            icon = ST[80053]
        },
        addswarn = {
            varname = format(L.alert["%s Warning"],SN[80053]),
            text = format(L.alert["New: %s"],"Poison Bombs"),
            time = 9,
            icon = ST[80053]
        },
        -- Fixate
        fixateself = {
            varname = format(L.alert["%s on me Warning"],SN[80094]),
            type = "simple",
            text = format(L.alert["%s - RUN AWAY!"],SN[80094]),
            time = 3,
            color1 = "GOLD",
            sound = "ALERT12",
            icon = ST[80094],
            flashscreen = true,
        },
        fixatewarn = {
            varname = format(L.alert["%s Warning"],SN[80094]),
            type = "simple",
            text = "<fixatetext>",
            time = 3,
            color1 = "WHITE",
            sound = "MINORWARNING",
            icon = ST[80094],
            flashscreen = true,
        },
        -- Grip of Death (heroic)
        gripwarn = {
            varname = format(L.alert["%s Warning"],SN[91849]),
            type = "centerpopup",
            text = format(L.alert["%s"], SN[91849]),
            time = 2,
            color1 = "GOLD",
            color2 = "MAGENTA",
            flashtime = 2,
            sound = "BEWARE",
            icon = ST[91849],
            flashscreen = true,
        },
        ----------------
        --- Nefarian ---
        ----------------
        nefcd = {
            varname = format(L.alert["Nefarian Ability CD"]),
            type = "dropdown",
            text = format(L.alert["Next Nefarian Action!"]),
            time = "<neftime>",
            flashtime = 7.5,
            color1 = "MAGENTA",
            sound = "ALERT9",
            icon = ST[92048],
        },
    },
    events = {
        {
            type = "event",
            event = "YELL",
            execute = {
                -- Toxitron activated
                {
                    "expect",{"#1#","find",L.chat_descent["^Toxitron unit activated"]},
                    "set",{activetext = format("%s active","Toxitron")},
                    "alert","activedur",
                    "alert","poisonbombcd",
                    "alert","addscd",
                    "invoke",{
                        {
                            "expect",{"<started>","==","yes"},
                            "set",{activewarntext = format("Switch to %s","Toxitron")},
                            "alert","activewarn",
                        },
                        {
                            "expect",{"<started>","==","no"},
                            "set",{starts = "yes"},
                        },
                    },
                },
                -- Magmatron activated
                {
                    "expect",{"#1#","find",L.chat_descent["^Magmatron unit activated"]},
                    "set",{activetext = format("%s active","Magmatron")},
                    "alert","activedur",
                    "alert","incinerationcd",
                    "alert","flamethrowercd",
                    "expect",{"<started>","==","yes"},
                    "set",{activewarntext = format("Switch to %s","Magmatron") },
                    "alert","activewarn",
                },
                -- Electron activated
                {
                    "expect",{"#1#","find",L.chat_descent["^Electron unit activated"]},
                    "set",{activetext = format("%s active","Electron")},
                    "alert","activedur",
                    "alert","conductorcd",
                    "expect",{"<started>","==","yes"},
                    "set",{activewarntext = format("Switch to %s","Electron") },
                    "alert","activewarn",
                },
                -- Arcanotron activated
                {
                    "expect",{"#1#","find",L.chat_descent["^Arcanotron unit activated"]},
                    "set",{activetext = format("%s active","Arcanotron")},
                    "alert","activedur",
                    "alert","generatorcd",
                    "alert",{"annihilatorcd",time = 2},
                    "expect",{"<started>","==","yes"},
                    "set",{activewarntext = format("Switch to %s","Arcanotron") },
                    "alert","activewarn",
                },
                {
                    "expect",{"#1#","find",L.chat_descent["unit activated"]},
                    "expect",{"<started>","==","no"},
                    "set",{started = "yes"},          
                },
            },
        },
        -- Deactivated
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 95018,
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","42178"}, -- Magmatron
                    "quash","incinerationcd",
                    "quash","flamethrowercd",
                },
                {
                    "expect",{"&npcid|#4#&","==","42166"}, -- Arcanotron
                    "quash","generatorcd",
                    "quash","annihilatorcd",
                },
                {
                    "expect",{"&npcid|#4#&","==","42179"}, -- Electron
                    "quash","conductorcd",
                },
                {
                    "expect",{"&npcid|#4#&","==","42180"}, --Toxitron
                    "quash","poisonbombcd",
                    "quash","addscd",
                },
            },
        },
        -- Incineration
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 79023,
            execute = {
                {
                    "quash","incinerationcd",
                    "alert","incinerationcd",
                    "alert","incinerationwarn",
                },
            },
        },
        -- Flame Thrower
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 79501, -- it's actually Acquiring Target
            execute = {
                {
                    "quash","flamethrowercd",
                    "alert","flamethrowercd",
                    "raidicon","flamethrowermark",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{ flamethrowertext = format(L.alert["Acquiring on <%s>"],"#5#") },
                    "alert","flamethrowerdur",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","flamethrowerselfwarn",
                },
            },
        },
        -- Encasing Shadows
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 92023,
            execute = {
                {
                    "quash","nefcd",
                    "alert","nefcd",
                    "arrow","flamesarrow",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{ encasingtext = format(L.alert["<%s> can't move!"],"#5#") },
                    "alert","encasingwarn",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","encasingselfwarn",
                    "announce","encasingsay",
                },
            },
        },
        -- Arcane Annihilator
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 79710,
            execute = {
                {
                    "quash","annihilatorcd",
                    "expect",{"&itemvalue|annihilatortargetonly&","~=","true",
                            "OR","&npcid|&unitguid|target&&","==","42166"},
                    "alert","annihilatorcd",
                    "alert","annihilatorwarn",
                },
            },
        },
        
        -- Power Generator
        {
            type ="combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellid = 79624, -- there are more spells named "power generator", so we need the id
            execute = {
                {
                    "quash","generatorcd",
                    "alert","generatorcd",
                },
            },
        },
        -- Overcharged Power Generator
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 91857,
            srcisnpctype = true,
            dstisnpctype = true,
            execute = {
                {
                    "alert","overcharged",
                    "quash","nefcd",
                    "alert","nefcd",
                },
            },
        },
        -- Lightning Conductor
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 79889,
            execute = {
                {
                    "quash","conductorcd",
                    "alert","conductorcd",
                    "raidicon","conductormark",
                    "range",{true},
                    "radar","conductorradar",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{ conductortext = format("%s on <%s>",SN[79889],"#5#") },
                    "set",{ conductortarget = "others"},
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{ conductortarget = "self"},
                },
                {
                    "scheduletimer",{"shadowcheck",0.1},
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 79889,
            execute = {
                {
                    "range",{false},
                    "removeradar",{"conductorradar",player = "#5#"},
                },
            },
        },
        
        -- Shadow Infusion
        {
            type ="combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = 92048,
            execute = {
                {
                    "set",{shadowconductorwarned = "yes"},
                    "quash","conductorwarn",
                    "removeraidicon","#5#",
                    "raidicon","infusionmark",
                    "quash","nefcd",
                    "alert","nefcd",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{ infusiontext = format("Shadow Conductor on <%s>","#5#") },
                    "alert","infusionwarn",
                    "set",{ infusiondurationtext = format("Shadow Conductor on <%s> incoming","#5#")},
                    "set",{ shadowconductortext = format("Shadow Conductor on <%s>","#5#")},
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","infusionselfwarn",
                    "announce","infusionsay",
                    "set",{ infusiondurationtext = format("Shadow Conductor on <%s> incoming",L.alert["YOU"])},
                    "set",{shadowconductortext = format("Shadow Conductor on <%s>",L.alert["YOU"])},
                },
                {
                    "alert","infusiondur",
                    "schedulealert",{"shadowconductordur",5},
                },
            },
        },
        -- Posion Cloud
        {
            type ="combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 80157,
            execute = {
                {
                    "quash","poisonbombcd",
                    "alert","poisonbombcd",
                },
            },
        },
        -- Poison Adds
        {
            type ="combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 80053,
            execute = {
                {
                    "alert","addswarn",
                    "alert","addscd",
                },
            },
        },
        {
            type ="combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 80094,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","fixateself",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{fixatetext = format(L.alert["%s on <%s>"],SN[80094],"#5#")},
                    "alert","fixatewarn",
                }
            },
        },
        -- Grip of Death
        {
            type ="combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 91849,
            execute = {
                {
                    "alert","gripwarn",
                    "quash","nefcd",
                    "alert","nefcd",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "chimaeron", {
    windows = {
        proxwindow = false,
    },
    raidicons = {
        slimemark = {
            varname = format("%s {%s}",SN[82935],"PLAYER_DEBUFF"),
            persist = 5,
            reset = 5,
            unit = "#5#",
            icon = 2,
            total = 5,
            texture = ST[82935],
        },
    },
    alerts = {
        -- Berserk
        enragecd = {
            varname = format(L.alert["%s CD"],SN[26662]),
            type = "dropdown",
            text = format(L.alert["%s"],SN[26662]),
            time = "<enragetimer>",
            color1 = "RED",
            flashtime = 10,
            icon = ST[26662],
        },
        -- Phase
        phasewarn = {
            varname = format(L.alert["Phase 2 Warning"]),
            type = "simple",
            text = format(L.alert["Phase %s"],"2"),
            time = 3,
            flashtime = 3,
            color1 = "TURQUOISE",
            icon = ST[11242],
            sound = "BEWARE",
            throttle = 60,
        },
        -- Chimaeron awakes
        pullcd = {
            varname = format(L.alert["%s"],"Pull Countdown"),
            type = "dropdown",
            text = format(L.alert["%s"],"Chimaeron awakes"),
            time = 31,
            flashtime = 5,
            color1 = "TURQUOISE",
            color2 = "CYAN",
            sound = "MINORWARNING",
            icon = ST[96573],
        },
        -- Break
        breakcd = {
            varname = format(L.alert["%s CD"],SN[82881]),
            type = "dropdown",
            text = format(L.alert["%s CD"],SN[82881]),
            time = "<breakcdonmassacre>",
            time2 = "<breakcd>",
            time3 = "<breakcdpull>",
            color1 = "RED",
            flashtime = 5,
            icon = ST[82881],
            audiocd = true,
            sticky = true,
        },
        breakwarn = {
            varname = format(L.alert["%s Warning"],SN[82881]),
            type = "simple",
            text = format(L.alert["%s!"],SN[82881]),
            time = 5,
            stacks = 4,
            color1 = "RED",
            sound = "ALERT4",
            icon = ST[82881],
            throttle = 11,
        },
        -- Caustic Slime
        slimecd = {
            varname = format(L.alert["%s CD"],SN[82935]),
            text = format(L.alert["Next %s"],SN[82935]),
            time = "<slimecd>",
            icon = ST[82935],
        },
        -- Double Attack
        doubleattackwarn = {
            varname = format(L.alert["%s Warning"],SN[88826]),
            type = "simple",
            text = format(L.alert["%s"],SN[88826]),
            time = 5,
            color1 = "YELLOW",
            flashtime = 5,
            icon = ST[88826],
            sound = "ALERT1",
        },
        -- Massacre
        massacrecd = {
            varname = format(L.alert["%s CD"],SN[82848]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[82848]),
            time = "<massacrecd>",
            color1 = "GREEN",
            flashtime = 7,
            icon = ST[82848],
        },
        massacrewarn = {
            varname = format(L.alert["%s Warning"],SN[82848]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[82848]),
            time = 4,
            color1 = "LIGHTGREEN",
            flashtime = 5,
            icon = ST[82848],
            sound = "ALERT10",
        },
        -- Feud
        feudwarn = {
            varname = format(L.alert["%s Warning"],SN[88872]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[88872]),
            time = "<feuddur>",
            color1 = "GOLD",
            flashtime = 5,
            icon = ST[88872],
            sound = "BEWARE",
        },
    },
    events = {
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = {
                55095, -- Frost Fever (Death Knight)
                58179, -- Infected Wounds (Feral Druid)
                54404, -- Dust Cloud (Hunter's pet - Tallstrider)
                90315, -- Tailspin (Hunter's pet - Fox)
                53696, -- Judgements of the Just (Paladin)
                51696, -- Waylay (Rogue)
                8042, -- Earth Shock (Shaman)
                6343, -- Thunder Clap (Protection Warrior)
            },
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","43296"},
                    "set",{
                        breakcd = 14.4,
                        breakcdonmassacre = 9.6,
                        breakcdpull = 5,
                    },
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = {
                55095, -- Frost Fever (Death Knight)
                58179, -- Infected Wounds (Feral Druid)
                54404, -- Dust Cloud (Hunter's pet - Tallstrider)
                90315, -- Tailspin (Hunter's pet - Fox)
                53696, -- Judgements of the Just (Paladin)
                51696, -- Waylay (Rogue)
                8042, -- Earth Shock (Shaman)
                6343, -- Thunder Clap (Protection Warrior)
            },
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","43296"},
                    "set",{
                        breakcd = 12,
                        breakcdonmassacre = 4,
                        breakcdpull = 4,
                    },
                },
            },
        },
        -- Break
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellid = 82881,
            execute = {
                {
                    "quash","breakcd",
                    "alert",{"breakcd",time = 2},
                    "expect",{"#11#","<=","&stacks|breakwarn&"},
                    "alert","breakwarn",
                },        
            },
        },
        -- Caustic Slime
        {
                type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 82935,
            execute = {
                {
                    "invoke",{
                        {
                            "expect",{"&timeleft|slimecd&","<","1"},
                            "quash","slimecd",
                        },
                    },
                    "alert","slimecd",
                    "raidicon","slimemark",
                },
            },
        },
        {
                type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 82935,
            execute = {
                {
                    "removeraidicon","#5#",
                },
            },
        },
        -- Double Attack
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 88826,
            execute = {
                {
                    "alert","doubleattackwarn",
                },
            },
        },
        -- Massacre
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 82848,
            execute = {
                {
                    "quash","slimecd",
                    "quash","massacrecd",
                    "quash","breakcd",
                    "alert","massacrewarn",
                    "alert","massacrecd",
                    "scheduletimer",{"massacretimer",4},
                    "schedulealert",{"breakcd", 4},
                },
            },
        },
        -- Feud
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 88872,
            execute = {
                {
                    "alert","feudwarn",
                    "expect",{"&difficulty&","<","3"},
                    "quash","breakcd",
                },
            },
        },
        -- Mortality
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = 82890,
            execute = {
                {
                    "alert","phasewarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "atramedes", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Berserk
        enragecd = {
            varname = format(L.alert["%s CD"],SN[26662]),
            type = "dropdown",
            text = format(L.alert["%s"],SN[26662]),
            time = 600,
            flashtime = 30,
            color1 = "RED",
            icon = ST[26662],
        },
        enragewarn = {
            varname = format(L.alert["%s Warning"],SN[26662]),
            type = "simple",
            text = format(L.alert["%s"],SN[26662]),
            time = 1,
            color1 = "RED",
            sound = "BEWARE",
            icon = ST[26662],
        },
        -- Gong Activation
        -- todo
        gongwarn = {
            varname = format(L.alert["%s Warning"], "Gong Activation"),
            type = "simple",
            text = "<gongtext>",
            time = 5,
            color1 = "YELLOW",
            sound = "MINORWARNING",
            texture = "Interface\\ICONS\\INV_Misc_Bell_01",
        },
        -- Vertigo
        -- todo
        gongduration = {
            varname = format(L.alert["%s Duration"],"Gong Stun"),
            type = "centerpopup",
            text = format(L.alert["Atramedes: %s"],SN[92391]),
            time = 5,
            color1 = "YELLOW",
            icon = ST[92391],
            sound = "None",
            throttle = 1,
        },
        ------------------
        -- Ground Phase --
        ------------------
        -- Ground Phase Duration
        grounddur = {
            varname = format(L.alert["Ground Phase Duration"]),
            type = "dropdown",
            text = format(L.alert["Ground Phase ends"]),
            time = "<grounddur>",
            flashtime = 5,
            color1 = "ORANGE",
            sound = "ALERT4",
            icon = ST[63532],
        },
        -- Sonar Pulse
        sonarcd = {
            varname = format(L.alert["%s CD"],SN[77672]),
            type = "dropdown",
            text = format(L.alert["%s CD"],SN[77672]),
            time = 10,--15,
            time2 = 11,
            flashtime = 5,
            color1 = "YELLOW",
            icon = ST[77672],
            sound = "MINORWARNING",
            sticky = true,
        },
        -- Modulation
        modulcd = {
            varname = format(L.alert["%s CD"],SN[77612]),
            text = format(L.alert["%s CD"],SN[77612]),
            time = 20,
            time2 = 15,
            icon = ST[77612],
        },
        -- Sonic Breath
        breathcd = {
            varname = format(L.alert["%s CD"],SN[78100]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[78100]),
            time = {41, 0, loop = true, type = "series"},
            time2 = 23,
            flashtime = 5,
            color1 = "ORANGE",
            icon = ST[78100],
            sound = "MINORWARNING",
        },
        -- Tracking
        trackingwarn = {
            varname = format(L.alert["%s Warning"],SN[78092]),
            type = "simple",
            text = "<trackingtext>",
            time = 8,
            color1 = "YELLOW",
            icon = ST[78092],
            sound = "ALERT2",
        },
        trackingselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[78092]),
            type = "simple",
            text = "<trackingtext>",
            time = 8,
            color1 = "YELLOW",
            icon = ST[78092],
            sound = "ALERT12",
            flashscreen = true,
        },
        trackingduration = {
            varname = format(L.alert["%s Duration"],SN[78092]),
            type = "centerpopup",
            text = "<trackingtext>",
            time = 8,
            color1 = "YELLOW",
            sound = "None",
            icon = ST[78092],
        },
        -- Searing Flames
        flamescd = {
            varname = format(L.alert["%s CD"],SN[77840]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[77840]),
            time = "<flamescd>",
            flashtime = 5,
            color1 = "ORANGE",
            icon = ST[77840],
        },
        flameswarn = {
            varname = format(L.alert["%s Warning"],SN[77840]),
            type = "simple",
            text = format(L.alert["%s!"],SN[77840]),
            time = 3,
            flashtime = 3,
            color1 = "ORANGE",
            icon = ST[77840],
            sound = "BEWARE",
        },
        ---------------
        -- Air Phase --
        ---------------
        -- Air Phase Duration
        airdur = {
            varname = format(L.alert["Air Phase Duration"]),
            type = "dropdown",
            text = format(L.alert["Air Phase ends"]),
            time = 31.5,
            flashtime = 10,
            color1 = "GOLD",
            sound = "ALERT4",
            icon = ST[57994],
            audiocd = true,
        },
        ------------
        -- Heroic --
        ------------
        -- Obnoxious Fiend
        fiendwarn = {
            varname = format(L.alert["%s Warning"],L.npc_descent["Obnoxious Fiend"]),
            type = "simple",
            text = format(L.alert["%s"],L.npc_descent["Obnoxious Fiend"]),
            time = 5,
            flashtime = 5,
            color1 = "LIGHTGREEN",
            icon = ST[49740],
            sound = "ALERT4",
        },
    },
    events = {
        -- Berserk
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = 26662,
            execute = {
                {
                    "alert","enragecd",
                },
            },
        },
        -- Sonar Pulse
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellid = {77672,92411,92412,92413},
            execute = {
                {
                    "quash","sonarcd",
                    "alert","sonarcd",
                },
            },   
        },
        -- Modulation
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            -- todo: collect spell id
            spellid = {77612,92452,92451,92453},
            execute = {
                {
                    "quash","modulcd",
                    "alert","modulcd",
                },
            },
        },
        -- Tracking
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 78092,
            execute = {
                {
                    "raidicon","trackingmark",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{trackingtext = format(L.alert["%s on <%s>"],SN[78092],"#5#")},
                    "alert","trackingwarn",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{trackingtext = format(L.alert["%s on <%s>"],SN[78092],L.alert["YOU"])},
                    "announce","trackingsay",
                    "alert","trackingselfwarn",
                },
                {
                    "expect",{"<phase>","==","ground"},
                    "alert","trackingduration",
                },
            },
        },
        -- Sonic Breath
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            -- todo: confirm spell id
            spellname = 92404,
            execute = {
                {
                    "quash","breathcd",
                    "alert","breathcd",          
                },
            },
        },
        -- Tracking removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 78092,
            execute = {
                {
                    "quash","trackingwarn",
                    "quash","trackingselfwarn",
                    "quash","trackingduration",
                    "removeraidicon","#5#",
                },
            },
        },
        -- Searing Flames
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 77840,
            execute = {
                {
                    "alert","flameswarn",
                },
            },
        },
        -- Gong Activation
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 77611,
            execute = {
                {
                    "set",{clickedgong = "&npcid|#1#&"},
                    "expect",{"<clickedgong>","==","41445",
                            "OR","<clickedgong>","==","42947",
                            "OR","<clickedgong>","==","42949",
                            "OR","<clickedgong>","==","42951",
                            "OR","<clickedgong>","==","42954",
                            "OR","<clickedgong>","==","42956",
                            "OR","<clickedgong>","==","42958",
                            "OR","<clickedgong>","==","42960"},
                    "expect",{"&listcontains|deadgongs|#1#&","==","false"},
                    "insert",{"deadgongs","#1#"},
                    "set",{gongcount = "DECR|1"},
                    "invoke",{
                        {
                            "expect",{"<gongcount>","==","0"},
                            "set",{gongtext = format(L.alert["Gong activated! (No gong remaining)"])},
                        },
                        {
                            "expect",{"<gongcount>","==","1"},
                            "set",{gongtext = format(L.alert["Gong activated! (%s gong remaining)"],"<gongcount>")}, 
                        },
                        {
                            "expect",{"<gongcount>",">","1"},
                            "set",{gongtext = format(L.alert["Gong activated! (%s gongs remaining)"],"<gongcount>")}, 
                        },
                    },
                    "alert","gongwarn",
                    "alert","gongduration",
                },
            },
        },
        -- Air Phase
        {
            type = "event",
            event = "YELL",
            execute = {
                {
                    "expect",{"#1#","find",L.chat_descent["^Yes, run!"]},
                    "set",{phase = "air"},
                    "alert","airdur",
                    "scheduletimer",{"groundphasetimer", 31.5},
                },
            },
        },
        -- Obnoxious Fiend
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            -- todo: confirm spell id
            spellid = 92681,
            execute = {
                {
                    "alert","fiendwarn",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 49740,
            execute = {
                {
                    "arrow","fiendarrow",
                    "raidicon","fiendmark",
                },
            },
        },
        {
            type = "event",
            event = "UNIT_AURA",
            execute = {
                {
                    "expect",{"&difficulty&",">=","3"},
                    "expect",{"#1#","==","player"},
                    "scheduletimer",{"fiend",0.1},
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "UNIT_DIED",
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","49740"},
                    "removearrow","#5#",
                    "set",{fiendwarned = "no"},
                },
                {
                    "set",{clickedgong = "&npcid|#4#&"},
                    "expect",{"<clickedgong>","==","41445",
                            "OR","<clickedgong>","==","42947",
                            "OR","<clickedgong>","==","42949",
                            "OR","<clickedgong>","==","42951",
                            "OR","<clickedgong>","==","42954",
                            "OR","<clickedgong>","==","42956",
                            "OR","<clickedgong>","==","42958",
                            "OR","<clickedgong>","==","42960"},
                    "expect",{"&listcontains|deadgongs|#4#&","==","false"},
                    "insert",{"deadgongs","#4#"},
                    "set",{gongcount = "DECR|1"},
                    "invoke",{
                        {
                            "expect",{"<gongcount>","==","0"},
                            "set",{gongtext = format(L.alert["Gong destroyed! (No gong remaining)"])},
                        },
                        {
                            "expect",{"<gongcount>","==","1"},
                            "set",{gongtext = format(L.alert["Gong destroyed! (%s gong remaining)"],"<gongcount>")}, 
                        },
                        {
                            "expect",{"<gongcount>",">","1"},
                            "set",{gongtext = format(L.alert["Gong destroyed! (%s gongs remaining)"],"<gongcount>")}, 
                        },
                    },
                    "alert","gongwarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "maloriak", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Berserk
        enragecd = {
            varname = format(L.alert["%s CD"],SN[26662]),
            type = "dropdown",
            text = format(L.alert["%s"],SN[26662]),
            time10n = 480,
            time25n = 480,
            time10h = 720,
            time25h = 720,
            color1 = "RED",
            flashtime = 15,
            icon = ST[26662],
        },
        -- First Phase Countdown
        firstphase = {
            varname = format(L.alert["%s"],L.alert["First Phase Countdown"]),
            type = "dropdown",
            text = "<firstphasetext>",
            time = 15,
            flashtime = 5,
            color1 = "MIDGREY",
            sound = "ALERT2",
            icon = "<firstphaseicon>",
            texture = ST[603],
        },
        -- Phase Warning
        phasewarn = {
            varname = format(L.alert["Phase 2 Warning"]),
            type = "simple",
            text = format(L.alert["Phase %s"],"2"),
            time = 3,
            flashtime = 3,
            color1 = "TURQUOISE",
            icon = ST[11242],
            sound = "ALERT1",
        },
        -- Remedy
        remedywarn = {
            varname = format(L.alert["%s Warning"],SN[77912]),
            type = "simple",
            text = format(L.alert["%s - DISPEL!"],SN[77912]),
            time = 5,
            color1 = "LIGHTGREEN",
            sound = "ALERT8",
            icon = ST[77912],
        },
        -- Release Aberrations
        relabercd = {
            varname = format(L.alert["%s CD"],SN[77569]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[77569]),
            time = 10,
            time2 = 16,
            color1 = "PURPLE",
            sound = "None",
            icon = ST[77569],
            sticky = true,
        },
        relaberwarn = {
            varname = format(L.alert["%s Warning"],SN[77569]),
            type = "simple",
            text = "<adstext>",
            time = 5,
            color1 = "MAGENTA",
            sound = "MINORWARNING",
            icon = ST[77569],
        },
        -- Arcane Storm
        stormcd = { 
            varname = format(L.alert["%s CD"],SN[77896]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[77896]),
            time = 10,
            time2 = 16,
            color1 = "LIGHTBLUE",
            sound = "None",
            -- sound = "kickcast",
            icon = ST[77896],  
            sticky = true,
        },
        stormwarn = {
            varname = format(L.alert["%s Warning"],SN[77896]),
            type = "simple",
            text = "<adstext>",
            time = 5,
            color1 = "MAGENTA",
            sound = "kickcast",
            icon = ST[77896],
        },
        --------------------------
        -- BLACK PHASE (HEROIC) --
        --------------------------
        -- Black Phase
        blackphasewarn = {
            varname = format(L.alert["%s Warning"],"Black Phase"),
            type = "simple",
            text = format(L.alert["%s"],"Black Phase"),
            time = 1,
            color1 = "WHITE",
            sound = "ALERT1",
            icon = ST[603],
        },
        -- Black Phase (duration)
        blackphasedur = {
            varname = format(L.alert["Black Phase Duration"]),
            type = "dropdown",
            text = format(L.alert["Black Phase"]),
            time = 92,
            color1 = "BLACK",
            flashtime = 10,
            sound = "ALERT2",
            icon = "Interface\\ICONS\\INV_Potion_90",
        },
        -- Dark Sludge
        sludgeselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[92930]),
            type = "simple",
            text = format("%s on %s - %s!",SN[92930],L.alert["YOU"],L.alert["MOVE AWAY"]),
            time = 3,
            throttle = 1,
            flashscreen = true,
            color1 = "RED",
            sound = "ALERT10",
            icon = ST[92930],
            emphasizewarning = true,
        },
        -- Engulfing Darkness
        darknesswarn = {
            varname = format(L.alert["%s Warning"],SN[92754]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[92754]),
            time = 8,
            flashtime = 8,
            color1 = "PINK",
            icon = ST[92754],
            sound = "ALERT9",
            audiocd = true,
        },
        ----------------
        -- BLUE PHASE --
        ----------------
        -- Blue Phase
        bluephasewarn = {
            varname = format(L.alert["%s Warning"],"Blue Phase"),
            type = "simple",
            text = format(L.alert["%s"],"Blue Phase"),
            time = 1,
            color1 = "WHITE",
            sound = "ALERT1",
            icon = ST[11151],
        },
        -- Blue Phase (duration)
        bluephasedur = {
            varname = format(L.alert["%s Duration"], "Blue Phase"),
            type = "dropdown",
            text = format(L.alert["Blue Phase"]),
            time = 50,
            color1 = "LIGHTBLUE",
            flashtime = 5,
            icon = "Interface\\ICONS\\INV_Potion_76",
            sound = "ALERT1",
        },
        -- Flash Freeze
        flashfreezewarn = {
            varname = format(L.alert["%s Warning"],SN[77699]),
            type = "simple",
            text = format(L.alert["%s"],SN[77699]),
            time = 10,
            color1 = "CYAN",
            icon = ST[77699],
            sound = "ALERT10",
        },
        flashfreezecd = {
            varname = format(L.alert["%s CD"],SN[77699]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[77699]),
            time = "<flashfreezecd>",
            color1 = "CYAN",
            color2 = "INDIGO",
            flashtime = 5,
            icon = ST[77699],
            sound = "ALERT4",
        },
        -- Biting Chill
        chillwarn = {
            varname = format(L.alert["%s Warning"],SN[77760]),
            type = "dropdown",
            text = format(L.alert["%s"],SN[77760]),
            time = 10,
            flashtime = 5,
            color1 = "CYAN",
            icon = ST[77760],
            sound = "ALERT3",
            throttle = 2,
        },
        chillself = {
            varname = format(L.alert["%s on me Warning"],SN[77760]),
            type = "centerpopup",
            text = format(L.alert["%s on %s"],SN[77760],L.alert["YOU"]),
            time = 10,
            flashtime = 10,
            color1 = "CYAN",
            icon = ST[77760],
            sound = "ALERT4",
            flashscreen = true,
        },
        ---------------
        -- RED PHASE --
        ---------------
        -- Red Phase
        redphasewarn = {
            varname = format(L.alert["%s Warning"],"Red Phase"),
            type = "simple",
            text = format(L.alert["%s"],"Red Phase"),
            time = 1,
            color1 = "WHITE",
            sound = "ALERT1",
            icon = ST[83619]
        },
        -- Red Phase (duration)
        redphasedur = {
            varname = format(L.alert["%s Duration"],"Red Phase"),
            type = "dropdown",
            text = format(L.alert["Red Phase"]),
            time = 50,
            color1 = "RED",
            flashtime = 5,
            sound = "ALERT2",
            icon = "Interface\\ICONS\\INV_Potion_55",
        },
        -- Scorching Blast
        breathcd = {
            varname = format(L.alert["%s CD"],SN[77679]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[77679]),
            time = "<breathcd>",
            color1 = "ORANGE",
            flashtime = 5,
            audiocd = true,
            icon = ST[77679],
            sound = "MINORWARNING",
            sticky = true,
        },
        -- Consuming Flames
        flamescd = {
            varname = format(L.alert["%s CD"],SN[77786]),
            text = format(L.alert["Next %s"],SN[77786]),
            time = "<flamescd>",
            icon = ST[77786],
        },
        flameswarn = {
            varname = format(L.alert["%s Warning"],SN[77786]),
            text = format(L.alert["%s on <#5#>"],SN[77786]),
            time = 10,
            icon = ST[77786],
        },
        flamesselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[77786]),
            text = format(L.alert["%s on %s"],SN[77786],L.alert["YOU"]),
            time = 5,
            icon = ST[77786],
        },
        -----------------
        -- GREEN PHASE --
        -----------------
        greenphasewarn = {
            varname = format(L.alert["%s Warning"],"Green Phase"),
            type = "simple",
            text = format(L.alert["Green Phase - Kill Aberrations!"]),
            time = 11,
            flashtime = 5,
            color1 = "WHITE",
            icon = ST[77912],
            sound = "None",
        },
        -- Green Phase (duration)
        greenphasedur = {
            varname = format(L.alert["%s Duration"],"Green Phase"),
            type = "dropdown",
            text = format(L.alert["Green Phase"]),
            time = 50,
            color1 = "LIGHTGREEN",
            flashtime = 5,
            audiocd = true,
            sound = "ALERT2",
            icon = "Interface\\ICONS\\INV_Potion_97",
        },
        -- Debilitating Slime
        slimedur = {
            varname = format(L.alert["%s Duration"],SN[77615]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[77615]),
            time = 15,
            flashtime = 5,
            audiocd = true,
            color1 = "LIGHTGREEN",
            icon = ST[77615],
            sound = "BURST",
        },
        -------------
        -- PHASE 2 --
        -------------
        -- Acid Nova
        acidnovawarn = {
            varname = format(L.alert["%s Warning"],SN[78225]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[78225]),
            time = 10,
            color1 = "LIGHTGREEN",
            icon = ST[78225],
            sound = "ALERT10",  
            throttle = 10,   
        },
        acidnovacd = {
            varname = format(L.alert["%s CD"],SN[78225]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[78225]),
            time = 30,
            time2 = 12,
            color1 = "LIGHTGREEN",
            flashtime = 5,
            icon = ST[78225],
            sound = "ALERT4",
        },
        -- Magma Jets
        jetscd = {
            varname = format(L.alert["%s CD"],SN[78194]),
            type = "centerpopup",
            text = format(L.alert["%s CD"],SN[78194]),
            time = "<jetscd>",
            time2 = 6.5,
            flashtime = 5,
            color1 = "RED",
            sound = "ALERT7",
            icon = ST[78194],
            sticky = true,
        },
    },
    events = {
        -- Phases
        {
            type = "event",
            event = "EMOTE",
            execute = {
                -- Red Phase
                {
                    "expect",{"#1#","find",L.chat_descent["red|r vial"]},
                    "set",{phase = "red"},
                    "alert","redphasewarn",
                    "alert","redphasedur",
                    "range",{false},
                    
                    "set",{breathcd = {20,16.75,0, loop = true, type = "series"}},
                    "alert","breathcd",
                    "alert","flamescd",
                    
                    "quash","stormcd",
                    "alert",{"stormcd",time = 2},
                    
                    "quash","relabercd",
                    "expect",{"<adscount>",">","0"},
                    "alert",{"relabercd",time = 2},
                },
                -- Blue Phase
                {
                    "expect",{"#1#","find",L.chat_descent["blue|r vial"]},
                    "set",{phase = "blue"},
                    "alert","bluephasewarn",
                    "alert","bluephasedur",
                    "range",{true},
                    
                    "alert","flashfreezecd",
                    
                    "quash","stormcd",
                    "alert",{"stormcd",time = 2},
                    
                    "quash","relabercd",
                    "expect",{"<adscount>",">","0"},
                    "alert",{"relabercd",time = 2},
                },
                -- Green Phase
                {
                    "expect",{"#1#","find",L.chat_descent["green|r vial"]},
                    "expect",{"<phase>","~=","green"},
                    "set",{phase = "green"},
                    "alert","greenphasewarn",
                    "alert","greenphasedur",
                    "range",{false},
                    
                    "alert","slimedur",
                },
            },
        },
        
        {
            type = "event",
            event = "YELL",
            execute = {
            -- Nefarian Phase
                {
                    "expect",{"#1#","find",L.chat_descent["Your mixtures"]},
                    "set",{phase = "black"},
                    "quash","stormcd",
                    "alert","blackphasewarn",
                    "alert","blackphasedur",
                },
                -- Last Phase
                {
                    "expect",{"#1#","find",L.chat_descent["^Too early"],
                            "OR","#1#","find",L.chat_descent["^Meet the brawn"],
                            "OR","#1#","find",L.chat_descent["^When pushed to the edge"]},
                    "run","lastphasetimer",
                },
            },
        },
        -- Magma Jets
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 78194,
            execute = {
                {
                    "quash","jetscd",
                    "alert","jetscd",
                },
            },
        },
        -- Consuming Flames
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 77786,
            execute = {
                {
                    "raidicon","flamesmark",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "alert","flameswarn",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "announce","flamessay",
                    "alert","flamesselfwarn",
                },
            },
        },
        -- Scorching Blast
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 92970,
            execute = {
                {
                    "quash","breathcd",
                    "alert",{"breathcd",time = 2},
                },
            },
        },
        -- Consuming Flames
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 77786,
            execute = {
                {
                    "quash","flamescd",
                    "alert","flamescd",
                },
            },
        },
        -- Flash Freeze
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = {
                77699,
                92978,
                92979,
                92980,          
            },
            execute = {
                {
                    "raidicon","freezemark",
                    "alert","flashfreezewarn",
                    "quash","flashfreezecd",
                    "alert","flashfreezecd",
                },
            },
        },
        -- Flash Freeze removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 92978,
            execute = {
                {
                    "removeraidicon","#5#",
                },
            },
        },
        -- Biting Chill
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 77760,
            execute = {
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "alert","chillwarn",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","chillself",
                },
            },
        },
        -- Biting Chill removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 77760,
            execute = {
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "quash","chillwarn",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "quash","chillself",
                },
            },
        },
        -- Debilitating Slime
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 77615,
            dstnpcid = 41378, --Maloriak
            execute = {
                {
                    "alert","greenphasewarn",
                },
            },
        },
        -- Remedy
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 77912,
            dstnpcid = 41378,
            execute = {
                {
                    "alert", "remedywarn",
                },
            },
        },
    
        -- Dark Sludge
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = {
                92930,
                92986,
                92987,
                92988,
            },
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},  
                    "alert", "sludgeselfwarn",
                },
            },
        },
    
        -- Acid Nova
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = {
                78225,
                93011,
                93012,
                93013,          
            },
            execute = {
                {
                    "alert","acidnovawarn",
                    "quash","acidnovacd",
                    "alert","acidnovacd",
                },
            },
        },
    
        -- Release Abberations
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellid = 77569,
            execute = {
                {
                    "quash","relabercd",
                    "expect",{"&timeleft|firstphase&",">","10",
                        "OR","&timeleft|redphasedur&",">","10",
                        "OR","&timeleft|bluephasedur&",">","10",
                        "OR","&timeleft|greenphasedur&",">","10"},
                    "expect",{"<adscount>",">","0"},
                    "alert","relabercd",
                },
            },
        },
        {
            type = "event",
            event = "UNIT_SPELLCAST_SUCCEEDED",
            execute = {
                {
                    "expect",{"#2#","==",SN[77569]},
                    "canceltimer","adstimer",
                    "scheduletimer",{"adstimer",0.2},
                },
            },
        },
        
        -- Arcane Storm

        -- Apollo setting

        -- {
        --     type = "combatevent",
        --     eventtype = "SPELL_CAST_START",
        --     spellid = 77896,
        --     execute = {
        --         {
        --             "quash","stormcd",
        --             "expect",{"&timeleft|firstphase&",">","10",
        --                 "OR","&timeleft|redphasedur&",">","10",
        --                 "OR","&timeleft|bluephasedur&",">","10",
        --                 "OR","&timeleft|greenphasedur&",">","10"},
        --             "alert","stormcd",
        --         },
        --     },
        -- },

        -- Jingrange JRG setting
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellid = 77896,
            execute = {
                {
                    "alert","stormwarn",
                },
            },
        },
    
        -- Engulfing Darkness (10h/25h)
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 92754,
            execute = {
                {
                    "schedulealert",{"darknesswarn",3},
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "nefarian", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        -- Berserk
        enragecd = {
            varname = format(L.alert["%s CD"],SN[26662]),
            type = "dropdown",
            text = format(L.alert["%s"],SN[26662]),
            time = 630,
            flashtime = 30,
            color1 = "RED",
            icon = ST[26662],
        },
        -------------
        -- Phase 1 --
        -------------
        -- Nefarian landing
        nefarianlands = {
            varname = format(L.alert["Nefarian Landing Countdown"]),
            type = "dropdown",
            text = format(L.alert["Nefarian landing"]),
            time = "<nefarianlanding>",
            flashtime = 5,
            color1 = "TEAL",
            icon = ST[105050],
        },
        -------------
        -- Phase 2 --
        -------------
        -- Phase Duration
        phase2timer = {
            varname = format(L.alert["Phase 2 Duration"]),
            type = "dropdown",
            text = format(L.alert["Phase 2"]),
            time = "<phase2timer>",
            flashtime = 5,
            color1 = "MIDGREY",
            icon = ST[11242],
        },
        -- Blast Nova
        blastnovacd = {
            varname = format(L.alert["%s CD"],SN[80734]),
            text = format(L.alert["Next %s"],SN[80734]),
            time = "<blastnovacd>",
            time2 = "<blastnovacd2>",
            icon = ST[80734],
        },
        blastwarn = {
            varname = format(L.alert["%s Warning"],SN[80734]),
            type = "simple",
            text = format(L.alert["%s - INTERRUPT"],SN[80734]),
            time = 1,
            icon = ST[80734],
        },
        -------------
        -- Phase 3 --
        -------------
        -- Phase Warning
        phase3warn = {
            varname = format(L.alert["Phase 3 Warning"]),
            type = "simple",
            text = format(L.alert["Phase 3"]),
            time = 5,
            color1 = "TURQUOISE",
            icon = ST[11242],
            sound = "MINORWARNING",
        },
        -- Electrocute
        electrocutewarn = {
            varname = format(L.alert["%s Warning"],SN[81198]),
            warningtext = format(L.alert["%s"],SN[81198]),
            text = format(L.alert["%s incoming"],SN[81198]),
            time = 5,
            icon = ST[81198],
        },
        -- Shadowblaze Spark
        blazecd = {
            varname = format(L.alert["%s CD"],SN[81031]),
            text = format(L.alert["Next %s"],SN[81031]),
            time = "<blazecd>",
            time2 = 29,
            time3 = "<blazecorrectedcd>",
            flashtime = 5,
            icon = ST[81031],
            sound = "ALERT8",
            sticky = true,
        },
        blazewarn = {
            varname = format(L.alert["%s Warning"],SN[81031]),
            type = "simple",
            text = "<blazetext>",
            time = 1,
            color1 = "MAGENTA",
            color2 = "RED",
            sound = "ALERT7",
            icon = ST[81031],
        },
        ------------
        -- Heroic --
        ------------
        -- Dominion
        dominionwarn = {
            varname = format(L.alert["%s Warning"],SN[79318]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[79318],"&list|dominionunits&"),
            time = 3,
            color1 = "MAGENTA",
            icon = ST[79318],
            sound = "ALERT9",
        },
        dominionself = {
            varname = format(L.alert["%s on me Warning"],SN[79318]),
            type = "centerpopup",
            text = format(L.alert["%s on <%s>"],SN[79318],L.alert["YOU"]),
            time = 20,
            flashtime = 5,
            flashscreen = true,
            color1 = "MAGENTA",
            icon = ST[79318],
            sound = "BURST",
        },
        dominioncd = {
            varname = format(L.alert["%s CD"],SN[79318]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[79318]),
            time = 15,
            time2 = 50,
            color1 = "PURPLE",
            flashtime = 5,
            icon = ST[79318],
            sound = "MINORWARNING",
            sticky = true,
        },
        -------------
        -- Phase 2 --
        -------------
        -- Explosive Cinders
        cinderwarn = {
            varname = format(L.alert["%s Warning"],SN[79339]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[79339],"&list|cinderunits&"),
            time = 8,
            color1 = "ORANGE",
            icon = ST[79339],
        },
        cinderself = {
            varname = format(L.alert["%s on me Warning"],SN[79339]),
            type = "centerpopup",
            text = format(L.alert["%s on <%s>"],SN[79339],L.alert["YOU"]),
            time = 8,
            color1 = "ORANGE",
            icon = ST[79339],
            sound = "RUNAWAY",
            flashscreen = true,
        },
        cindercd = {
            varname = format(L.alert["%s CD"],SN[79339]),
            type = "dropdown",
            text = format(L.alert["%s CD"],SN[79339]),
            text2 = format(L.alert["Next %s"],SN[79339]),
            time = 22,
            time2 = 6,
            time3 = "<cindercd>",
            color1 = "ORANGE",
            color2 = "GOLD",
            icon = ST[79339],
            sound = "MINORWARNING",
            thrtottle = 2,
            sticky = "<cindersticky>",
        },
    },
    events = {
        -- Blast Wave
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 80734,
            execute = {
                {
                    "expect",{"&npcid|&unitguid|target&&","==","41948",
                        "AND","&unitguid|target&","==","#1#",
                            "OR","&npcid|&unitguid|target&&","~=","41948"},
                    "alert","blastnovacd",
                    "alert","blastwarn",
                },
                {
                    "raidicon","prototypemark",
                    "expect",{"<prototypestraced>","==","no"},
                    "insert",{"prototypesunits","#1#"},
                    "expect",{"&listsize|prototypesunits&","==","3"},
                    "set",{prototypestraced = "yes"},
                    "scheduletimer",{"prototypestimer",1},
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "UNIT_DIED",
            execute = {
                -- Phase 2
                {
                    "expect",{"&npcid|#4#&","==","41270"},
                    "tracing",{41376},
                    "range",{true},
                    "quash","dominioncd",
                    "alert","phase2timer",
                    "alert",{"blastnovacd",time = 2},
                    "schedulealert",{"phase3warn","<phase2timer>"},
                    "expect",{"&difficulty&",">=","3"},
                    "alert",{"cindercd",time = 2, text = 2},
                },
                -- Phase 3
                {
                    "expect",{"&npcid|#4#&","==","41948"},
                    "set",{addsdead = "INCR|1"},
                    "invoke",{
                        {
                            "expect",{"&difficulty&",">=","3"},
                            "expect",{"<phase>","~=","3"},
                            "quash","phase2timer",
                            "cancelalert","phase3warn",
                            "alert","phase3warn",
                            "alert",{"blazecd",time = 2},
                            "set",{
                                cindersticky = "false",
                                cindercd = "&timeleft|cindercd&",
                            },
                            "quash","cindercd",
                            "alert",{"cindercd",time = 3},
                            "set",{phase = "3"},
                        },
                        {
                            "expect",{"&difficulty&","<","3"},
                            "expect",{"<addsdead>","==","3"},
                            "quash","phase2timer",
                            "cancelalert","phase3warn",
                            "alert","phase3warn",
                            "alert",{"blazecd",time = 2},
                            "set",{
                                cindersticky = "false",
                                cindercd = "&timeleft|cindercd&",
                            },
                            "quash","cindercd",
                            "alert",{"cindercd",time = 3},
                            "set",{phase = "3"},
                        },
                    },
                },
            },
        },
            -- Shadowblaze
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 81031,
            execute = {
                {
                    "invoke",{
                        {
                            "expect",{"<bonewarriors>","==","0"},
                            "set",{blazetext = format(L.alert["%s"],SN[81031])},
                        },
                        {
                            "expect",{"<bonewarriors>","==","1"},
                            "set",{blazetext = format(L.alert["%s - MOVE THE AD!"],SN[81031])},
                        },
                        {
                            "expect",{"<bonewarriors>",">","1"},
                            "set",{blazetext = format(L.alert["%s - MOVE THE ADS!"],SN[81031])},
                        },
                    },
                    "alert","blazewarn",
                    "quash","blazecd",
                    "alert","blazecd",
                    "expect",{"<blazecd>",">","15"},
                    "set",{blazecd = "DECR|5"},
                },
            },
        },
        -- Electrocute
        {
            type = "event",
            event = "EMOTE",
            execute = {
                {
                    "expect",{"#1#","find",L.chat_descent["^The air crackles"]},
                    "alert","electrocutewarn",
                },
            },
        },
        -- Shadowflame Breath
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 94125,
            execute = {
                {
                    "expect",{"<phase>","==","3"},
                    "expect",{"&itemvalue|postponeshadowblaze&","==","true"},
                    "expect",{"&timeleft|blazecd&","<=","2.5"},
                    "set",{blazecorrectedcd = 2.5},
                    "quash","blazecd",
                    "alert",{"blazecd",time = 3},
                },
            },
        },
        ------------
        -- Heroic --
        ------------
        -- Explosive Cinders
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 79339,
            execute = {
                {
                    "raidicon","cindermark",
                    "radar","cinderradar",
                    "insert",{"cinderunits","#5#"},
                },
                {
                    "expect",{"&listsize|cinderunits&","==","1"},
                    "quash","cindercd",
                    "alert","cindercd",
                    "scheduletimer",{"cindertimer",1},
                },
                {
                    "expect",{"&listsize|cinderunits&","==","<cindermax>"},
                    "canceltimer","cindertimer",
                    "alert","cinderwarn",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "announce","cindersay",
                    "alert","cinderself",
                },
            },
        },
        -- Explosive Cinders
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 79339,
            execute = {
                {
                    "removeraidicon","#5#",
                    "removeradar",{"cinderradar", player = "#5#"},
                },
            },
        },     
        -- Dominion
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 79318,
            execute = {
                {
                    "quash","dominioncd",
                    "alert","dominioncd",
                    "expect",{"<phase>","==","3"},
                    "expect",{"&itemvalue|postponeshadowblazebydominion&","==","true"},
                    "expect",{"&timeleft|blazecd&","<=","1.5"},
                    "set",{blazecorrectedcd = 1.5},
                    "quash","blazecd",
                    "alert",{"blazecd",time = 3},
                },
            },      
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 79318,
            execute = {
                {
                    "insert",{"dominionunits","#5#"},
                },
                {
                    "expect",{"&listsize|dominionunits&","==","1"},
                    "scheduletimer",{"dominiontimer",1},

                },
                {
                    "expect",{"&listsize|dominionunits&","==","<dominionmax>"},
                    "canceltimer","dominiontimer",
                    "alert","dominionwarn",

                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","dominionself",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 79318,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "quash","dominionself",
                },
            },
        },
        -- Animated Bone Warrior is ressurected / spawned
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 94091,
            execute = {
                {
                    "set",{bonewarriors = "INCR|1"},
                },
            },
        },
        -- Animated Bone Warrior dies
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 94091,
            execute = {
                {
                    "set",{bonewarriors = "DECR|1"},
                },
            },
        },
        
        
    },
})

DXE:RegisterRealmPatch(realm, "bwdtrash", {
    windows = {
        proxwindow = false,
    },
})
