local L,SN,ST = DXE.L,DXE.SN,DXE.ST

---------------------------------
-- CONCLAVE OF WIND
---------------------------------
do
    local data = {
        version = 9,
        key = "windconclave",
        zone = L.zone["Throne of the Four Winds"],
        category = L.zone["Throne of the Four Winds"],
        name = L.npc_throne["The Conclave of Wind"],
        lfgname = "Conclave of Wind",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Nezir.blp",
        icon2 = "Interface\\EncounterJournal\\UI-EJ-BOSS-Anshal.blp",
        triggers = {
            scan = {
                45871, -- Nezir
                45872, -- Rohash
                45870, -- Anshal
            },
            yell = {
                L.chat_throne["shall be I that earns"],
                L.chat_throne["honor of slaying the interlopers"],
                L.chat_throne["strongest wind"],
            },
        },
        onactivate = {
            tracing = {
                {unit = "boss", npcid = 45871}, -- Nezir
                {unit = "boss", npcid = 45872}, -- Rohash
                {unit = "boss", npcid = 45870}, -- Anshal
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = {
                45872, -- Rohash
                45870, -- Anshal
                45871, -- Nezir
            },
        },
        userdata = {
            -- Common abilites
            strengthtext = "",
            -- Rohash
            shieldcd = {30,0,loop = true,type = "series"},
            windblastcd = {30.5, 81, 60, loop = false,type = "series"},
            tornadoscd = {10, 21, 26, 10, loop = false, type = "series"},
            -- Anshal
            nurturecd = {30,0,loop = true,type = "series"},
            breezecd = {15,32, loop = false, type = "series"},
            -- Nezir
            chilltext = "",
        },
        onstart = {
            {
                -- Common abilites
                "alert","powercd",
                "alert","enragecd",
                
                -- Anshal
                "alert",{"nurturecd",time = 2},
                "alert",{"breezecd",time = 2},
                
                -- Nezir
                "alert",{"permafrostcd",time = 3},
                "alert",{"icepatchcd",time = 3, text = 2},
                
                -- Rohash
                "alert","windblastcd",
                "alert","tornadoscd",
                "expect",{"&difficulty&",">=","3"}, --10h&25h
                "alert","shieldcd",
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd","powercd","powerwarn","strengthwarn"},
            },
            {
                name = format("|cffffd700%s|r","Anshal"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Anshal",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"breezecd","breezewarn","nurturecd","nurturewarn","toxiccd","toxicwarn"},
            },
            {
                name = format("|cffffd700%s|r","Nezir"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Nezir",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"permafrostcd","icepatchcd","icepatchwarn","icepatchselfwarn","chillselfwarn"},
            },
            {
                name = format("|cffffd700%s|r","Rohash"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Rohash",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"tornadoscd","tornadoswarn","windblastcd","windblastwarn","windblastdur","shieldcd","shieldwarn"},
            },
        },
        
        alerts = {
            ---------------------
            -- Common abilites --
            ---------------------
            -- Berserk
            enragecd = {
                varname = format(L.alert["Berserk CD"]),
                type = "dropdown",
                -- text = format(L.alert["Berserk"]),
                text = format(L.alert["%s"], SN[26662]),
                time = 480,
                flashtime = 15,
                color1 = "RED",
                icon = ST[26662],
            },
            -- Ultimate Ability
            powercd = {
                varname = format(L.alert["Ultimate Ability CD"]),
                type = "dropdown",
                text = format(L.alert[L.spell_throne["Next Ultimate Ability"]]),
                -- text = format(L.alert["%s"], SN[84644]),
                time = 90,
                flashtime = 15,
                color1 = "YELLOW",
                sound = "RUNAWAY",
                icon = ST[84644],
            },
            powerwarn = {
                varname = format(L.alert["Ultimate Ability Duration"]),
                type = "centerpopup",
                text = format(L.alert[L.spell_throne["Ultimate Ability"]]),
                time = 15,
                flashtime = 15,
                color1 = "YELLOW",
                sound = "BEWARE",
                icon = ST[84644],
                throttle = 15,
            },
            -- Gather Strength
            strengthwarn = {
                varname = format(L.alert["%s Warning"],SN[86307]),
                type = "centerpopup",
                text = "<strengthtext>",
                time10n = 120,
                time25n = 120,
                time10h = 60,
                time25h = 60,
                flashtime = 15,
                color1 = "YELLOW",
                color2 = "RED",
                sound = "BEWARE",
                icon = ST[86307],
                audiocd = true,
            },
            ------------
            -- Rohash --
            ------------
            -- Storm Shield
            shieldcd = {
                varname = format(L.alert["%s CD"],SN[95865]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[95865]),
                time = "<shieldcd>",
                color1 = "INDIGO",
                flashtime = 10,
                icon = ST[95865],
                audiocd = true,
            },
            shieldwarn = {
                varname = format(L.alert["%s Absorbs"],SN[95865]),
                text = SN[95865].."!",
                textformat = format("%s (%%s/%%s - %%d%%%%)",L.alert["Shield"]),
                type = "absorb",
                time = 30,
                flashtime = 5,
                color1 = "BLUE",
                color2 = "CYAN",
                sound = "None",
                icon = ST[95865],
                npcid = 45872,
                values = {
                    [95865] = 450000, --25h
                    [93059] = 150000, --10h
                },
            },
            -- Wind Blast
            windblastcd = {
                varname = format(L.alert["%s CD"],SN[93138]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[93138]),
                time = "<windblastcd>",
                flashtime = 10,
                color1 = "MIDGREY",
                icon = ST[93138],
            },
            windblastwarn = {
                varname = format(L.alert["%s Warning"],SN[93138]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[93138]),
                time = 5,
                color1 = "YELLOW",
                sound = "ALERT10",
                icon = ST[93138],
            },
            windblastdur = {
                varname = format(L.alert["%s Duration"],SN[93138]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[93138]),
                time = 6,
                color1 = "YELLOW",
                icon = ST[93138],
                fillDirection = "DEPLETE",
            },
            -- Summon Tornados
            tornadoscd = {
                varname = format(L.alert["%s CD"],SN[86192]),
                type = "dropdown",
                text = format(L.alert["New %s"],SN[86192]),
                time = "<tornadoscd>",
                flashtime = 5,
                color1 = "TAN",
                sound = "MINORWARNING",
                icon = ST[86192],
            },
            tornadoswarn = {
                varname = format(L.alert["%s Warning"],SN[86192]),
                type = "centerpopup",
                text = format(L.alert["New: %s"],SN[86192]),
                time = 2,
                color1 = "TAN",
                sound = "MINORWARNING",
                icon = ST[86192],
            },
            
            ------------
            -- Anshal --
            ------------
            -- Soothing Breeze
            breezecd = {
                varname = format(L.alert["%s CD"],SN[86205]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[86205]),
                time = 30, -- post-Ultimate
                time2 = "<breezecd>", -- init + cd
                color1 = "GREEN",
                icon = ST[86205],
            },
            breezewarn = {
                varname = format(L.alert["%s Warning"],SN[86205]),
                type = "simple",
                text = format(L.alert["%s"],SN[86205]),
                time = 3,
                color1 = "CYAN",
                icon = ST[86205],
                sound = "MINORWARNING"
            },
            -- Nurture
            nurturecd = {
                varname = format(L.alert["%s CD"],SN[85422]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[85422]),
                time = 45,
                time2 = "<nurturecd>",
                color1 = "LIGHTGREEN",
                icon = ST[85422],
                flashtime = 10,
            },
            nurturewarn = {
                varname = format(L.alert["%s Warning"],SN[85422]),
                type = "simple",
                text = format(L.alert["%s"],SN[85422]),
                time = 5,
                color1 = "LIGHTGREEN",
                icon = ST[85422],
                sound = "ALERT7",
            },
            -- Toxic Spores
            toxiccd = {
                varname = format(L.alert["%s CD"],SN[86281]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[86281]),
                time = 20,
                flashtime = 5,
                color1 = "MAGENTA",
                icon = ST[86281],
                throttle = 2,
            },
            toxicwarn = {
                varname = format(L.alert["%s Warning"],SN[86281]),
                type = "simple",
                text = format(L.alert["%s"],SN[86281]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT11",
                icon = ST[86281],
            },
            
            -----------
            -- Nezir --
            -----------
            -- Wind Chill
            chillselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[84645]),
                type = "simple",
                text = "<chilltext>",
                time = 3,
                stacks = 5,
                color1 = "WHITE",
                icon = ST[84645],
                sound = "ALERT8",
            },
            -- Permafrost
            permafrostcd = {
                varname = format(L.alert["%s CD"],SN[86082]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[86082]),
                time = 14, -- post-Ultimate
                time2 = 12, -- regular CD
                time3 = 16, -- init
                flashtime = 5,
                icon = ST[86082],
                color1 = "CYAN",
                color2 = "TURQUOISE",
                sound = "MINORWARNING",     
                sticky = true,
            },
            -- Ice Patch
            icepatchcd = {
                varname = format(L.alert["%s CD"],SN[86122]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[86122]),
                text2 = format(L.alert["%s CD"],SN[86122]),
                time = 19, -- post Ultimate
                time2 = 21, -- regular CD
                time3 = 21, -- init
                flashtime = 5,
                icon = ST[86122],
                color1 = "LIGHTBLUE",
                sound = "MINORWARNING",     
                throttle = 2,
                sticky = true,
            },
            icepatchwarn = {
                varname = format(L.alert["%s Warning"],SN[86122]),
                type = "simple",
                text = format(L.alert["%s"],SN[86122]),
                time = 5,
                icon = ST[86122],
                color1 = "LIGHTBLUE",
                sound = "ALERT8",
                throttle = 2,
            },
            icepatchselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[86122]),
                type = "simple",
                text = format(L.alert["%s on YOU - MOVE AWAY!"],SN[86122]),
                time = 5,
                icon = ST[86122],
                color1 = "LIGHTBLUE",
                sound = "ALERT4",
                flashscreen = true,
                emphasizewarning = true,
            },
            
            
        },
        timers = {
            windblasttimer = {
                {
                    "quash","windblastwarn",
                    "alert","windblastdur",
                },
            },
        },
        events = {
            ---------------------
            -- Common abilites --
            ---------------------
            -- Ultimate Ability
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = {
                    84638,
                    84644,
                    84643,
                },
                execute = {
                    {
                        "alert","powerwarn",
                        "schedulealert",{"powercd",15},
                    }
                },
            },
            -- Nezir - Ultimate Ability
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 84644,
                execute = {
                    {
                        "quash","permafrostcd",
                        "quash","icepatchcd",
                        "schedulealert",{"permafrostcd",15},
                        "schedulealert",{"icepatchcd",15},
                    },
                },
            },
            -- Anshal - Ultimate Ability
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 84638,
                execute = {
                    {
                        "quash","breezecd",
                        "schedulealert",{"nurturecd",15},
                        "schedulealert",{"breezecd",15},
                    },
                },
            },
            -- Rohash - Ultimate Ability
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 84643,
                execute = {
                    {
                        "schedulealert",{"tornadoscd", 15},
                        "expect",{"&difficulty&",">=","3"}, --10h&25h
                        "schedulealert",{"shieldcd",15},
                    },
                },
            },
            -- Gather Strength
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 86307,
                execute = {
                    {
                        "set",{strengthtext = format(L.alert["%s (%s)"],SN[86307],"#2#")},
                        "alert","strengthwarn",
                    },
                    {
                        "expect",{"#2#","==","Anshal"},
                        "quash","breezecd",
                        "quash","nurturecd",
                    },
                    {
                        "expect",{"#2#","==","Nezir"},
                        "quash","permafrostcd",
                        "quash","icepatchcd",
                    },
                    {
                        "expect",{"#2#","==","Rohash"},
                        "quash","tornadoscd",
                        "quash","windblastcd",
                        "quash","shieldcd",
                    },
                },
            },
            ------------
            -- Rohash --
            ------------
            -- Wind Blast
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 86193,
                execute = {
                    {
                        "quash","windblastcd",
                        "alert","windblastwarn",
                        "scheduletimer",{"windblasttimer", 5},
                        "alert","windblastcd",
                    },
                },
            },
            -- Summon Tornados
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 86192,
                execute = {
                    {
                        "quash","tornadoscd",
                        "alert","tornadoswarn",
                    },
                },
            },
            
            -- Storm Shield (heroic)
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 95865,
                execute = {
                    {
                        "quash","shieldcd",
                        "alert","shieldcd",
                        "alert","shieldwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 95865,
                execute = {
                    {
                        "quash","shieldwarn",
                    },
                },
            },
            ------------
            -- Anshal --
            ------------
            -- Soothing Breeze
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 86205,
                execute = {
                    {
                        "quash","breezecd",
                        "alert","breezewarn",
                        "expect",{"&timeleft|powercd&",">","32"},
                        "alert","breezecd",
                        
                    },
                },
            },
            -- Nurture
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 85422,
                execute = {
                    {
                        "quash","nurturecd",
                        "alert",{"nurturecd",time = 2},
                        "alert","nurturewarn",
                        "alert","toxiccd",
                        "schedulealert",{"toxiccd",20},
                    },
                },
            },
            -- Toxic Spores
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[86290]},
                        "expect",{"#1#","find","boss"},
                        "alert","toxicwarn",
                    },
                },
            },
            
            
            -----------
            -- Nezir --
            -----------
            -- Wind Chill Stacks
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 84645,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "expect",{"#11#",">=","&stacks|chillselfwarn&"},
                        "set",{chilltext = format("%s (%s) on %s!",SN[84645],"#11#",L.alert["YOU"])},
                        "alert","chillselfwarn",
                    },
                },
            },
            -- Permafrost
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 93232,
                execute = {
                    {
                        "quash","permafrostcd",
                        "expect",{"&timeleft|powercd&",">","12"},
                        "alert",{"permafrostcd",time = 2},
                    },
                },
            },
            -- Ice Patch
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[86122]},
                        "expect",{"#1#","find","boss"},
                        "quash","icepatchcd",
                        "alert","icepatchwarn",
                        "expect",{"&timeleft|powercd&",">","21"},
                        "alert",{"icepatchcd",time = 2, text = 2},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 86111,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","icepatchselfwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- AL'AKIR
---------------------------------

do
    local data = {
        version = 9,
        key = "alakir",
        zone = L.zone["Throne of the Four Winds"],
        category = L.zone["Throne of the Four Winds"],
        name = L.npc_throne["Al'Akir"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-AlAkir.blp",
        triggers = {
            scan = {
                46753, -- Al'Akir
            },
        },
        onactivate = {
            tracing = {
                46753, -- Al'Akir
            },
            phasemarkers = {
                {
                    {0.8,"Phase 2","At 80% of Al'Akir's HP, he will no longer cast Wind Burst and Phase 2 begins."},
                    {0.25,"Phase 3","At 25% HP, Al'Akir shatters his platform and Phase 3 begins."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = {
                46753, -- Al'Akir
            },
        },
        userdata = {
            phase = "1",
            raintext = "",
            stormlingtime = {20,20,loop = false, type = "series"},
            rodtime = {5,10, loop = true, type = "series"},
            rodtime2 = 20,
            --windburstcd = 24,
            windburstcd = {21.8, 25.8, loop = false, type = "series"},
            windburstwarntime = 5,
            cloudtime = 15,
            cloudtime2 = 15,
        },
        onstart = {
            {
                "alert",{"windburstcd",text = 2},
                "alert","enragecd",
            },
            {
                "expect",{"&difficulty&",">=","3"}, --10h&25h
                "set",{
                    windburstwarntime = 4,
                    cloudtime = 10,
                },
            },
            {
                "expect",{"&difficulty&","<=","2"},
                "set",{
                    rodtime2 = 25,
                    rodtime = {5,15, loop = true, type = "series"},
                },
            },
        },
        
        announces = {
            rodsay = {
                type = "SAY",
                subtype = "self",
                spell = 93294,
                msg = format(L.alert["{skull} %s on ME! {skull}"],SN[93294]),
            },
        },
        raidicons = {
            rodmark = {
                varname = format("%s {%s}",SN[93294],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                persist = 10,
                unit = "#5#",
                icon = 1,
                texture = ST[93294],
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd","phasewarn"},
            },
            {
                phase = 1,
                alerts = {"windburstcd","windburstwarn"},
            },
            {
                phase = 2,
                alerts = {"stormlingcd","feedbackdurwarn","raincd","rainwarn"},
            },
            {
                phase = 3,
                alerts = {"rodcd","rodwarn","rodselfwarn","cloudcd","cloudwarn","cloudactivecd"},
            },
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = format(L.alert["%s CD"],SN[47008]),
                type = "dropdown",
                text = format("%s",SN[47008]),
                time = 600,
                flashtime = 30,
                color1 = "RED",
                icon = ST[47008],
            },
            -- Phase
            phasewarn = {
                varname = format(L.alert["Phase Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"<phase>"),
                time = 5,
                flashtime = 5,
                color1 = "TURQUOISE",
                sound = "ALERT2",
                icon = ST[11242],
            },
            -------------
            -- Phase 1 --
            -------------
            -- Wind Burst
            windburstcd = {
                varname = format(L.alert["%s CD"],SN[87770]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[87770]),
                text2 = format("Next %s",SN[87770]),
                time = "<windburstcd>",
                time2 = 25,
                flashtime = 5,
                color1 = "PEACH",
                icon = ST[87770],
                throttle = 2,
                sticky = true,
            },
            windburstwarn = {
                varname = format(L.alert["%s Warning"],SN[87770]),
                type = "centerpopup",
                text = format(L.alert["%s!"],SN[87770]),
                time = "<windburstwarntime>",
                color1 = "GOLD",
                sound = "BEWARE",
                icon = ST[87770],
            },
            -------------
            -- Phase 2 --
            -------------
            -- Stormling Summon
            stormlingcd = {
                varname = format(L.alert["%s CD"],SN[87919]),
                type = "dropdown",
                text = format(L.alert["New %s"],SN[87919]),
                time = "<stormlingtime>",
                flashtime = 5,
                color1 = "ORANGE",
                icon = ST[87919],
            },
            -- Feedback
            feedbackdurwarn = {
                varname = format(L.alert["%s Duration"],SN[87904]),
                type = "centerpopup",
                text = "<feedbacktext>",
                time10n = 30,
                time25n = 30,
                time10h = 20,
                time25h = 20,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "RED",
                icon = ST[87904],
                audiocd = true,
            },
            -- Acid Rain
            raincd = {
                varname = format(L.alert["%s CD"],SN[93281]),
                type = "dropdown",
                text = format("Next %s",SN[93281]),
                time = 15,
                flashtime = 7,
                color1 = "LIGHTGREEN",
                sound = "MINORWARNING",
                icon = ST[93281],
            },
            rainwarn = {
                varname = format(L.alert["%s Warning"],SN[93281]),
                type = "simple",
                text = "<raintext>",
                time = 5,
                color1 = "LIGHTGREEN",
                sound = "MINORWARNING",
                icon = ST[93281],
            },
            -------------
            -- Phase 3 --
            -------------
            -- Lightning Rod
            rodselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[93294]),
                type = "simple",
                text = format(L.alert["%s on <%s>!"],SN[93294],L.alert["YOU"]),
                time = 5,
                color1 = "GOLD",
                sound = "RUNAWAY",
                icon = ST[93294],
                emphasizewarning = true,
            },
            rodwarn = {
                varname = format(L.alert["%s Warning"],SN[93294]),
                type = "simple",
                text = format("%s on <#5#>!",SN[93294]),
                time = 5,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[93294],
            },
            rodcd = {
                varname = format(L.alert["%s CD"],SN[93294]),
                type = "dropdown",
                text = format("Next %s",SN[93294]),
                time = "<rodtime>",
                time2 = "<rodtime2>",
                flashtime = 5,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[93294],      
            },
            -- Lightning Cloud
            cloudcd = {
                varname = format(L.alert["%s CD"],SN[89588]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[89588]),
                time = "<cloudtime>",--10,
                time2 = "<cloudtime2>",
                flashtime = 5,
                color1 = "BLUE",
                icon = ST[87919],
            },
            cloudwarn = {
                varname = format(L.alert["%s Warning"],SN[89588]),
                type = "simple",
                text = format(L.alert["Lightning Cloud"],SN[89588]),
                time = 4,
                color1 = "LIGHTBLUE",
                icon = ST[87919],
                sound = "MINORWARNING",
            },
            cloudactivecd = {
                varname = format(L.alert["%s Active Countdown"],SN[89588]),
                type = "centerpopup",
                text = format(L.alert["Cloud Active in"],SN[89588]),
                time = 6,
                color1 = "LIGHTBLUE",
                icon = ST[87919],
                sound = "MINORWARNING",
            },
        },
        timers = {
            clouds = {
                {
                    "quash","cloudcd",
                    "alert","cloudcd",
                    "alert","cloudwarn",
                    "alert","cloudactivecd",
                    "scheduletimer",{"clouds","<cloudtime>"},
                },
            },
        },
        events = {
            -- Wind Burst
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 87770,
                execute = {
                    {
                        "quash","windburstcd",
                        "alert","windburstcd",
                        "alert","windburstwarn",
                    },
                },
            },
            -- Phase 2 Trigger
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = {
                    93280,
                    93281,        
                },
                execute = {
                    {
                        "expect",{"<phase>","==","1"},
                        "set", {phase = "2"},
                        "quash", "windburstcd",
                        "alert", "stormlingcd",
                        "alert", "phasewarn",            
                    },
                },
            },
            -- Feedback
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 87904,
                execute = {
                    {
                        "set",{feedbacktext = format(L.alert["%s"],SN[87904])},
                        "alert","feedbackdurwarn",
                    },
                }
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 87904,
                execute = {
                    {
                        "quash","feedbackdurwarn",
                        "set",{feedbacktext = format(L.alert["%s (#11#)"],SN[87904])},
                        "alert","feedbackdurwarn",
                    },
                }
            },
            -- Acid Raid (Debuff Application)
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 93281,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "quash","raincd",
                        "alert","raincd",
                    },
                },
            },
            -- Acid Rain (Stack Application)
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = {
                    93280,
                    93281,
                },
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "quash","raincd",
                        "alert","raincd",
                        "set",{raintext = format("%s (%s)",SN[93281],format("%s","#11#"))},            
                        "alert","rainwarn",
                    },
                },
            },
            -- Stormling Summon
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[88272]},
                        "expect",{"#1#","find","boss"},
                        "quash", "stormlingcd",
                        "alert", "stormlingcd",
                    },
                },
            },
            -- Phase 3 Trigger
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[89528]},
                        "expect",{"<phase>","==","2"},
                        "set", {phase = "3"},
            
                        "quash", "stormlingcd",
                        "quash","raincd",
                        
                        "alert","phasewarn",
                        "alert",{"cloudcd",time = 2},
                        "scheduletimer",{"clouds","<cloudtime2>"},
                        "alert",{"rodcd", time = 2},
            
                        "set",{windburstcd = 20},
                        "alert",{"windburstcd",time = 2, text = 2},
                    },        
                },
            },
            -- Wind Burst (Phase 3)
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellid = {
                    88858,
                    93286,
                    93287,
                    93288,
                },
                execute = {
                    {
                        "quash","windburstcd",
                        "alert",{"windburstcd", text = 2},
                    },
                },
            },
            -- Lightning Rod
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 93294,
                execute = {
                    {
                        "quash","rodcd",
                        "alert","rodcd",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","rodselfwarn",
                        "announce","rodsay",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "alert","rodwarn",
                    },
                    {
                        "raidicon","rodmark",
                    },
                },
            },  
        },
    }

    DXE:RegisterEncounter(data)
end


