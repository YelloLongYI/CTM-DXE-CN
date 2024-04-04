local L,SN,ST,AL,AN,AT,TI = DXE.L,DXE.SN,DXE.ST,DXE.AL,DXE.AN,DXE.AT,DXE.TI

---------------------------------
-- HIGH PRIEST VENOXIS 
---------------------------------

do
    local data = {
        version = 7,
        key = "venoxis",
        zone = L.zone["Zul'Gurub"],
        category = L.zone["Zul'Gurub"],
        name = "High Priest Venoxis",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-High Priest Venoxis.blp",
        triggers = {
            scan = {
                52155, -- High Priest Venoxis 
            },
        },
        onactivate = {
            tracing = {
                52155,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 52155,
        },
        userdata = {
            whisperscd = {7, 9, 8, 0, loop = true, type = "series"},
            linkcd = {10, 10, 0, loop = true, type = "series"},
            breathcd = {5, 13, 0, loop = true, type = "series"},
            phase = 2,
        },
        onstart = {
            {
                "alert",{"whisperscd",time = 2},
                "alert","linkcd",
                "alert","phasecd",
            },
        },
        
        raidicons = {
            linkmark = {
                varname = format("%s {%s}",SN[96477],"PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 10,
                unit = "#4#",
                reset = 10,
                icon = 1,
                total = 2,
                texture = ST[96477],
            },
        },
        filters = {
            bossemotes = {
                bloodvenomemote = {
                    name = "Bloodvenom",
                    pattern = "begins casting %[Bloodvenom%]",
                    hasIcon = true,
                    texture = ST[96842],
                },
                exhaustemote = {
                    name = "Exhausted",
                    pattern = "is exhausted",
                    hasIcon = false,
                    texture = ST[54477],
                },
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"phasecd","phasewarn"},
            },
            {
                phase = 1,
                alerts = {"whisperscd","whispersinterruptwarn","linkcd","linkselfwarn","acridselfwarn",},
            },
            {
                phase = 2,
                alerts = {"breathcd","breathwarn","breathcastwarn","venomselfwarn"},
            },
            {
                phase = 3,
                alerts = {"bloodvenomduration","withdrawalduration",""},
            },
        },
        
        alerts = {
            -- Whispers of Hethiss
            whisperscd = {
                varname = format(L.alert["%s CD"],SN[97094]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97094]),
                time = "<whisperscd>",
                time2 = 6,
                flashtime = 5,
                color1 = "TEAL",
                color2 = "GREEN",
                sound = "MINORWARNING",
                icon = ST[97094],
            },
            whispersinterruptwarn = {
                varname = format(L.alert["%s interrupt Warning"],SN[97094]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s"],SN[97094]),
                time = 8,
                color1 = "LIGHTGREEN",
                sound = "ALERT7",
                icon = ST[97094],
            },
            -- Toxic Link
            linkcd = {
                varname = format(L.alert["%s CD"],SN[96477]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96477]),
                time = "<linkcd>",
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "GREEN",
                sound = "MINORWARNING",
                icon = ST[96477],
            },
            linkselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[96477]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[96477],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT2",
                icon = ST[96477],
                emphasizewarning = true,
            },
            -- Phase transitions
            phasecd = {
                varname = format(L.alert["%s CD"],"Phase"),
                type = "dropdown",
                text = format(L.alert["Phase %s"],"<phase>"),
                time = 30,
                flashtime = 10,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[78832],
            },
            phasewarn = {
                varname = format(L.alert["%s Warning"],"Phase"),
                type = "simple",
                text = format(L.alert["Phase %s"],"<phase>"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT1",
                icon = ST[78832],
            },
            -- Breath of Hethiss
            breathcd = {
                varname = format(L.alert["%s CD"],SN[96509]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96509]),
                time = "<breathcd>",
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "GREEN",
                sound = "MINORWARNING",
                icon = ST[96509],
            },
            breathcastwarn = {
                varname = format(L.alert["%s Cast Warning"],SN[96509]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[96509]),
                time = 1.5,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[96509],
            },
            breathwarn = {
                varname = format(L.alert["%s Channel Warning"],SN[96509]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s"],SN[96509]),
                time = 3.5,
                color1 = "LIGHTGREEN",
                sound = "ALERT7",
                icon = ST[96509],
            },
            -- Bloodvenom
            bloodvenomduration = {
                varname = format(L.alert["%s Warning"],SN[96842]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[96842]),
                time = 14,
                color1 = "LIGHTGREEN",
                sound = "ALERT9",
                icon = ST[96842],
            },
            -- Venom Withdrawal
            withdrawalduration = {
                varname = format(L.alert["%s Duration"],SN[96653]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[96653]),
                time = 10,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[96653],
            },
            -- Venomous Effusion
            venomselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[97338]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[97338],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                icon = ST[97338],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
            -- Pool of Acrid Tears
            acridselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[97089]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[97089],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                icon = ST[97089],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
        },
        timers = {
            phase1timer = {
                {
                    "set",{phase = 1},
                    "alert","phasewarn",
                    "set",{phase = 2},
                    "alert","phasecd",
                    "alert","whisperscd",
                    "alert","linkcd",
                }
            },
        },
        events = {
			-- Whispers of Hethiss
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96466,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","52155"},
                        "quash","whisperscd",
                        "alert","whisperscd",
                        "alert","whispersinterruptwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 96466,
                execute = {
                    {
                        "quash","whispersinterruptwarn",
                    },
                },
            },
            -- Toxic Link
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96475,
                execute = {
                    {
                        "quash","linkcd",
                        "alert","linkcd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96477,
                execute = {
                    {
                        "raidicon","linkmark",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","linkselfwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 96477,
                execute = {
                    {
                        "removeraidicon","linkmark",
                    },
                },
            },
            -- Phase 2 start
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 97354,
                execute = {
                    {
                        "quash","whisperscd",
                        "quash","linkcd",
                        "alert","phasewarn",
                        "set",{phase = 3},
                        "alert","phasecd",
                        "alert","breathcd",
                    },
                },
            },
            -- Breath of Hethiss
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96509,
                execute = {
                    {
                        "quash","breathcd",
                        "alert","breathcd",
                        "alert","breathcastwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96509,
                execute = {
                    {
                        "quash","breathcastwarn",
                        "alert",{"breathwarn", replace = "breathcastwarn"},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 96509,
                execute = {
                    {
                        "quash","breathwarn",
                    },
                },
            },
            
            -- Phase 3
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96842,
                execute = {
                    {
                        "alert","phasewarn",
                    },
                },
            },
            -- Bloodvenom
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[96842]},
                        "expect",{"#1#","==","boss1"},
                        "alert","bloodvenomduration",
                    },
                },
            },
            -- Venom Withdrawal
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[96653]},
                        "expect",{"#1#","==","boss1"},
                        "alert","withdrawalduration",
                        "scheduletimer",{"phase1timer", 10},
                    },
                },
            },            
            -- Venomous Effusion
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 97338,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","venomselfwarn",
                    },
                },
            },
            -- Pool of Acrid Tears
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 97089,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","acridselfwarn",
                    },
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- BLOODLORD MANDOKIR
---------------------------------

do
    local data = {
        version = 8,
        key = "mandokir",
        zone = L.zone["Zul'Gurub"],
        category = L.zone["Zul'Gurub"],
        name = "Bloodlord Mandokir",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Bloodlord Mandokir.blp",
        triggers = {
            scan = {
                52151, -- Bloodlord Mandokir
            },
        },
        onactivate = {
            tracing = {
                52151,
            },
            phasemarkers = {
                {
                    {0.2, "Frenzy", "At 20% of his HP, Bloodlord Mandokir enters a frenzy."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 52151,
        },
        userdata = {
            decapitatecd = {10, 32, loop = false, type = "series"},
            bloodcd = {15, 27, loop = false, type = "series"},
            bloodtext = "",
            slamcd = {25, 37, loop = false, type = "series"},
            ohganguid = "",
            firstohgandead = "no",
            sofastfailed = "no",
        },
        onstart = {
            {
                "alert",{"decapitatecd",time = 2},
                "alert","bloodcd",
                "alert","slamcd",
                "repeattimer",{"checkhp", 1},
                "scheduletimer",{"ohgansummontimer", 20},
                "alert","ohganactivatedcd",
            },
        },
        
        announces = {
            sofastfailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5762,
                msg = format(L.alert["<DXE> %s: Achievement failed!"],AL[5762]),
                throttle = true,
            },
        },
        raidicons = {
            bloodmark = {
                varname = format("%s {%s}",SN[96776],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                persist = 10,
                unit = "#5#",
                reset = 10,
                icon = 2,
                texture = ST[96776],
            },
            ohganmark = {
                varname = format("%s {%s}","Ohgan","NPC_ENEMY"),
                type = "ENEMY",
                persist = 15,
                unit = "<ohganguid>",
                reset = 60,
                icon = 1,
                texture = ST[84751],
            },
        },
        filters = {
            bossemotes = {
                slamemote = {
                    name = "Devastating Slam",
                    pattern = "Bloodlord Mandokir begins to cast %[Devastating Slam%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[96740],
                },
            },
        },
        ordering = {
            alerts = {"decapitatecd","bloodcd","bloodwarn","slamcd","slamwarn","ohganactivatedcd","reanimatecd","reanimatewarn","frenzysoonwarn","frenzywarn"},
        },
        
        alerts = {
            -- Decapitate
            decapitatecd = {
                varname = format(L.alert["%s CD"],SN[96682]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96682]),
                time = 30,
                time2 = 10,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[96684],
            },
            -- Bloodletting
            bloodcd = {
                varname = format(L.alert["%s CD"],SN[96776]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96776]),
                time = "<bloodcd>",
                flashtime = 5,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[96776],
            },
            bloodwarn = {
                varname = format(L.alert["%s Warning"],SN[96776]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = "<bloodtext>",
                time = 10,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[96776],
            },
            -- Devastating Slam
            slamcd = {
                varname = format(L.alert["%s CD"],SN[96740]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96740]),
                time = "<slamcd>",
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[96740],
            },
            slamwarn = {
                varname = format(L.alert["%s Warning"],SN[96740]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[96740]),
                time = 4,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[96740],
            },
            -- Frenzy
            frenzysoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[96800]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[96800]),
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[96800],
            },
            frenzywarn = {
                varname = format(L.alert["%s Warning"],SN[96800]),
                type = "simple",
                text = format(L.alert["%s"],SN[96800]),
                time = 1,
                color1 = "RED",
                sound = "BEWARE",
                icon = ST[96800],
            },
            -- Ohgan activated
            ohganactivatedcd = {
                varname = format(L.alert["%s CD"],"Ohgan activated"),
                type = "dropdown",
                text = format(L.alert["%s in"],"Ohgan activates"),
                time = 20,
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[96724],
            },
            -- Reanimate Ohgan
            reanimatecd = {
                varname = format(L.alert["%s CD"],SN[96724]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[96724]),
                time = 24,
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[96724],
                throttle = 10,
                sticky = true,
            },
            reanimatewarn = {
                varname = format(L.alert["%s Warning"],"Ohgan active"),
                type = "simple",
                text = format(L.alert["%s!"],"Ohgan active"),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT9",
                icon = ST[96724],
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","30"},
                    "alert","frenzysoonwarn",
                    "canceltimer","checkhp",
                },
            },
            ohgantimer = {
                {
                    "set",{ohganguid = "&unitguid|boss1target&"},
                    "temptracing","&unitguid|boss1target&",
                    "raidicon","ohganmark",
                },
            },
            ohgansummontimer = {
                {
                    "set",{ohganguid = "52157"},
                    "tracing",{52151,52157},
                    "raidicon","ohganmark",
                    "alert","reanimatewarn",
                },
            },
        },
        events = {
			-- Decapitate
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[96682]},
                        "expect",{"#1#","==","boss1"},
                        "quash","decapitatecd",
                        "alert","decapitatecd",
                    },
                },
            },
            -- Bloodletting
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96776,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{bloodtext = format(L.alert["%s on %s!"],SN[96776],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{bloodtext = format(L.alert["%s on <%s>!"],SN[96776],"#5#")},
                    },
                    {
                        "quash","bloodcd",
                        "alert","bloodcd",
                        "alert","bloodwarn",
                        "raidicon","bloodmark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 96776,
                execute = {
                    {
                        "removeraidicon","bloodmark",
                        "quash","bloodwarn",
                    },
                },
            },
            
            -- Devastating Slam
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96740,
                execute = {
                    {
                        "quash","slamcd",
                        "alert","slamcd",
                        "alert","slamwarn",
                    },
                },
            },
            -- Frenzy
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96800,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","52151"},
                        "alert","frenzywarn",
                        "quash","slamcd",
                        "quash","bloodcd",
                        "set",{decapitatecd = 15},
                    },
                },
            },
            -- Reanimate Ohgan
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96724,
                execute = {
                    {
                        "quash","reanimatecd",
                        "scheduletimer",{"ohgantimer", 0.5},
                        "schedulealert",{"reanimatewarn", 2.5},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","52157"},
                        "alert","reanimatecd",
                        
                        "expect",{"<firstohgandead>","==","no"},
                        "set",{firstohgandead = "yes"},
                        "tracing",{52151},
                    },
                    {
                        "expect",{"&npcid|#4#&","==","52157"},
                        "expect",{"<sofastfailed>","==","no"},
                        "set",{
                            sofastfailed = "yes",
                        },
                        "announce","sofastfailed",
                    },
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end


---------------------------------
------- ARCHEOLOGY BOSSES -------
---------------------------------
-- GRI'LEK
---------------------------------

do
    local data = {
        version = 4,
        key = "grilek",
        groupkey = "cacheofmadness",
        zone = L.zone["Zul'Gurub"],
        category = L.zone["Zul'Gurub"],
        name = "Gri'lek",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Grilek.blp",
        triggers = {
            scan = {
                52258, -- Gri'lek
            },
        },
        onactivate = {
            tracing = {
                52258,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 52258,
        },
        userdata = {
            pursuitcd = {15, 45, loop = false, type = "series"},
            pursuittext = "",
            rootstext = "",
        },
        onstart = {
            {
                "alert","pursuitcd",
            },
        },
        
        raidicons = {
            pursuitmark = {
                varname = format("%s {%s}",SN[96631],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 5,
                unit = "&unitname|boss1target&",
                reset = 16,
                icon = 1,
                texture = ST[96631],
            },
        },
        filters = {
            bossemotes = {
                chasedemote = {
                    name = "Gri'lek chasing you",
                    pattern = "is chasing you",
                    hasIcon = false,
                    texture = ST[96631],
                },
            },
        },
        ordering = {
            alerts = {"pursuitcd","pursuitwarn","pursuitduration","pursuitselfwarn","avatarduration","rootscd","rootswarn"},
        },
        
        alerts = {
            -- Pursuit
            pursuitcd = {
                varname = format(L.alert["%s CD"],SN[96631]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96631]),
                time = "<pursuitcd>",
                flashtime = 5,
                color1 = "CYAN",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[96631],
            },
            pursuitduration = {
                varname = format(L.alert["%s Duration"],SN[96631]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s ends"],SN[96631]),
                time = 13,
                color1 = "LIGHTGREEN",
                sound = "None",
                icon = ST[96631],
            },
            pursuitselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[96631]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[96631],L.alert["YOU"]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT10",
                icon = ST[96631],
                throttle = 2,
                emphasizewarning = true,
            },
            pursuitwarn = {
                varname = format(L.alert["%s Warning"],SN[96631]),
                type = "simple",
                text = "<pursuittext>",
                time = 1,
                color1 = "CYAN",
                sound = "ALERT1",
                icon = ST[96631],
            },
            -- Entangling Roots
            rootscd = {
                varname = format(L.alert["%s CD"],SN[96636]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96636]),
                time = 5,
                flashtime = 5,
                color1 = "BROWN",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[96636],
            },
            rootswarn = {
                varname = format(L.alert["%s Warning"],SN[96636]),
                type = "simple",
                text = "<rootstext>",
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT8",
                icon = ST[96636],
            },
            avatarduration = {
                varname = format(L.alert["%s Duration"],SN[96618]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s ends"],SN[96618]),
                time = 18,
                color1 = "RED",
                sound = "BEWARE",
                icon = ST[96618],
            },
        },
        timers = {
            pursuittimer = {
                {
                    "expect",{"&unitisunit|boss1target|player&","==","true"},
                    "alert","pursuitselfwarn",
                    "raidicon","pursuitmark",
                },
                {
                    "expect",{"&unitisunit|boss1target|player&","~=","true"},
                    "set",{pursuittext = format(L.alert["%s on <%s>!"],SN[96631],"&unitname|boss1target&")},
                    "alert","pursuitwarn",
                    "raidicon","pursuitmark",
                },
            },
        },
        events = {
			-- Pursuit
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96631,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","52258"},
                        "quash","pursuitcd",
                        "alert","pursuitcd",
                        "schedulealert",{"pursuitduration", 3},
                        "scheduletimer",{"pursuittimer", 0.05},
                        "alert","rootscd",
                    },
                },
            },
            -- Entangling Roots
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96636,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","52258"},
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{rootstext = format(L.alert["%s on %s - DISPEL!"],SN[96636],L.alert["YOU"])},
                        "alert","rootswarn",
                    },
                    {
                        "expect",{"&npcid|#1#&","==","52258"},
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{rootstext = format(L.alert["%s on <%s> - DISPEL!"],SN[96636],"#5#")},
                        "alert","rootswarn",
                    },
                },
            },
            -- Avatar
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96618,
                execute = {
                    {
                        "alert","avatarduration",
                    },
                },
            },
            
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- RENATAKI
---------------------------------

do
    local data = {
        version = 2,
        key = "renataki",
        groupkey = "cacheofmadness",
        zone = L.zone["Zul'Gurub"],
        category = L.zone["Zul'Gurub"],
        name = "Renataki",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Renataki.blp",
        triggers = {
            scan = {
                52269, -- Renataki
            },
        },
        onactivate = {
            tracing = {
                52269,
            },
            phasemarkers = {
                {
                    {0.3, "Frenzy","At 30% of his HP, Renataki enters a frenzy."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 52269,
        },
        userdata = {
            vanishcd = {15, 45, loop = false, type = "series"},
            bladescd = {34, 45, loop = false, type = "series"},
        },
        onstart = {
            {
                "alert","vanishcd",
                "alert","bladescd",
                "repeattimer",{"checkhp", 1},
            },
        },
        ordering = {
            alerts = {"vanishcd","vanishwarn","ambushcountdown","bladescd","bladeswarn","bladesduration","frenzysoonwarn","frenzywarn"},
        },
        
        alerts = {
            -- Vanish
            vanishcd = {
                varname = format(L.alert["%s CD"],SN[96639]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96639]),
                time = "<vanishcd>",
                flashtime = 5,
                color1 = "WHITE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[96639],
            },
            vanishwarn = {
                varname = format(L.alert["%s Warning"],SN[96639]),
                type = "simple",
                text = format(L.alert["%s"],SN[96639]),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT7",
                icon = ST[96639],
            },
            -- Ambush
            ambushcountdown = {
                varname = format(L.alert["%s Countdown"],SN[96640]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[96640]),
                time = 2.65,
                color1 = "YELLOW",
                sound = "None",
                icon = ST[96640],
            },
            -- Thousand Blades
            bladescd = {
                varname = format(L.alert["%s CD"],SN[96646]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96646]),
                time = "<bladescd>",
                flashtime = 5,
                color1 = "TEAL",
                color2 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[96646],
            },
            bladeswarn = {
                varname = format(L.alert["%s Warning"],SN[96646]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[96646]),
                time = 3,
                color1 = "TURQUOISE",
                sound = "ALERT1",
                icon = ST[96646],
            },
            bladesduration = {
                varname = format(L.alert["%s Duration"],SN[96646]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s"],SN[96646]),
                time = 6,
                color1 = "YELLOW",
                sound = "None",
                icon = ST[96646],
            },
            -- Frenzy
            frenzysoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[8269]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[8269]),
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[8269],
            },
            frenzywarn = {
                varname = format(L.alert["%s Warning"],SN[8269]),
                type = "simple",
                text = format(L.alert["%s"],SN[8269]),
                time = 1,
                color1 = "RED",
                sound = "BEWARE",
                icon = ST[8269],
            },
            
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","40"},
                    "alert","frenzysoonwarn",
                    "canceltimer","checkhp",
                },
            },
            
        },
        events = {
			-- Vanish
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 96639,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","52269"},
                        "quash","vanishcd",
                        "alert","vanishcd",
                        "alert","vanishwarn",
                        "alert","ambushcountdown",
                    },
                },
            },
            -- Ambush
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96640,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","52269"},
                        "quash","ambushcountdown",
                    },
                },
            },
            -- Thousand Blades
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96646,
                execute = {
                    {
                        "quash","bladescd",
                        "alert","bladescd",
                        "alert","bladeswarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96646,
                execute = {
                    {
                        "quash","bladeswarn",
                        "alert","bladesduration",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 96646,
                execute = {
                    {
                        "quash","bladesduration",
                    },
                },
            },
            -- Frenzy
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 8269,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","52269"},
                        "alert","frenzywarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- HAZZA'RAH
---------------------------------

do
    local data = {
        version = 3,
        key = "hazzarah",
        groupkey = "cacheofmadness",
        zone = L.zone["Zul'Gurub"],
        category = L.zone["Zul'Gurub"],
        name = "Hazza'rah",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Hazzarah.blp",
        triggers = {
            scan = {
                52271, -- Hazza'rah
            },
        },
        onactivate = {
            tracing = {
                52271,
            },
            phasemarkers = {
                {
                    {0.66, "Sleep","At 66% of his HP, Hazza'rah places all but one player to sleep."},
                    {0.33, "Sleep","At 33% of his HP, Hazza'rah places all but one player to sleep."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 52271,
        },
        userdata = {
            nightmare1warned = "no",
            nightmare2warned = "no",
        },
        onstart = {
            {
                "repeattimer",{"checkhp", 1},
            },
        },
        
        raidicons = {
            nightmaremark = {
                varname = format("%s {%s}",SN[96757],"PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 15,
                unit = "#5#",
                reset = 20,
                icon = 1,
                total = 4,
                texture = ST[96757],
            },
        },
        ordering = {
            alerts = {"nightmaresoonwarn","nightmarewarn","awakenselfwarn"},
        },
        
        alerts = {
            -- Walking Nightmare
            nightmaresoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[96757]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[96757]),
                time = 1,
                color1 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[96757],
            },
            nightmarewarn = {
                varname = format(L.alert["%s Warning"],SN[96757]),
                type = "simple",
                text = format(L.alert["%s"],SN[96757]),
                time = 1,
                color1 = "GOLD",
                sound = "BEWARE",
                icon = ST[96757],
            },
            awakenselfwarn = {
                varname = format(L.alert["%s Warning"],"Kill Illusions"),
                type = "simple",
                text = format(L.alert["%s - KILL ILLUSIONS!"],SN[96658]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT10",
                icon = ST[96658],
                emphasizewarning = true,
            },
            
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","76"},
                    "expect",{"<nightmare1warned>","==","no"},
                    "set",{nightmare1warned = "yes"},
                    "alert","nightmaresoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","43"},
                    "expect",{"<nightmare2warned>","==","no"},
                    "set",{nightmare2warned = "yes"},
                    "alert","nightmaresoonwarn",
                },
                {
                    "expect",{"<nightmare1warned>","==","yes"},
                    "expect",{"<nightmare2warned>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
            awakentimer = {
                {
                    "alert","awakenselfwarn",
                },
            },
        },
        events = {
			-- Walking Nightmare
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_zulgurub["^Slumber"]},
                        "alert","nightmarewarn",
                        "set",{sleepcount = 0},
                        "scheduletimer",{"awakentimer", 0.5},
                    },
                    {
                        "expect",{"#1#","find",L.chat_zulgurub["^Let's see which"]},
                        "alert","nightmarewarn",
                        "set",{sleepcount = 0},
                        "scheduletimer",{"awakentimer", 0.5},
                    },
                    {
                        "expect",{"#1#","find",L.chat_zulgurub["^Let us see"]},
                        "alert","nightmarewarn",
                        "set",{sleepcount = 0},
                        "scheduletimer",{"awakentimer", 0.5},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96757,
                execute = {
                    {
                        "raidicon","nightmaremark",
                        "set",{sleepcount = "INCR|1"},
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "canceltimer","awakentimer",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 96757,
                execute = {
                    {
                        "removeraidicon","nightmaremark",
                        "set",{sleepcount = "DECR|1"},
                        "expect",{"#4#","==","&playerguid&"},
                        "expect",{"<sleepcount>",">","0"},
                        "alert","awakenselfwarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- WUSHOOLAY
---------------------------------

do
    local data = {
        version = 8,
        key = "wushoolay",
        groupkey = "cacheofmadness",
        zone = L.zone["Zul'Gurub"],
        category = L.zone["Zul'Gurub"],
        name = "Wushoolay",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Wushoolay.blp",
        triggers = {
            scan = {
                52286, -- Wushoolay
            },
        },
        onactivate = {
            tracing = {
                52286,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 52286,
        },
        userdata = {
            rushcd = {15, 25, loop = false, type = "series"},
        },
        onstart = {
            {
                "alert","rushcd",
            },
        },

        filters = {
            bossemotes = {
                rodemote = {
                    name = "Lightning Rod",
                    pattern = "is about to blast you with lightning",
                    hasIcon = false,
                    hide = true,
                    texture = ST[96699],
                },
            },
        },
        ordering = {
            alerts = {"rushcd","rushwarn","rodwarn","cloudselfwarn","cloudclosewarn"},
        },
        
        alerts = {
            -- Lightning Cloud
            cloudselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[96711]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[96711],L.alert["YOU"]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT10",
                icon = ST[96711],
                throttle = 2,
                emphasizewarning = {2,0.5},
            },
            cloudclosewarn = {
                varname = format(L.alert["%s near me Warning"],SN[96711]),
                type = "simple",
                text = format(L.alert["%s near %s - GET AWAY!"],SN[96711],L.alert["YOU"]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT10",
                icon = ST[96711],
                throttle = 2,
                emphasizewarning = {2,0.5},
            },
            -- Lightning Rush
            rushcd = {
                varname = format(L.alert["%s CD"],SN[96697]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96697]),
                time = "<rushcd>",
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[96697],
            },
            rushwarn = {
                varname = format(L.alert["%s Warning"],SN[96697]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[96697]),
                time = 2.5 ,
                color1 = "CYAN",
                sound = "BEWARE",
                icon = ST[96697],
            },
            -- Lightning Rod
            rodwarn = {
                varname = format(L.alert["%s Warning"],SN[96699]),
                type = "centerpopup",
                text = format(L.alert["%s - RUN AWAY!"],SN[96699]),
                time = 3,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "RUNAWAY",
                icon = ST[96699],
            },
        },
        events = {
			-- Lightning Cloud
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96711,
                dstisplayertype = true,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","cloudselfwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "expect",{"&getdistance|#4#&","<=",10},
                        "alert","cloudclosewarn",
                    },
                },
            },
            
            -- Lightning Rush
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96697,
                execute = {
                    {
                        "quash","rushcd",
                        "alert","rushcd",
                        "alert","rushwarn",
                    },
                },
            },
            -- Lightning Rod
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96699,
                execute = {
                    {
                        "alert","rodwarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end


---------------------------------
-- HIGH PRIESTESS KILNARA
---------------------------------

do
    local data = {
        version = 3,
        key = "kilnara",
        zone = L.zone["Zul'Gurub"],
        category = L.zone["Zul'Gurub"],
        name = "High Priestess Kilnara",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-High Priestess Kilnara.blp",
        triggers = {
            scan = {
                52059, -- High Priestess Kilnara
            },
        },
        onactivate = {
            tracing = {
                52059,
            },
            phasemarkers = {
                {
                    {0.5, "Phase 2","At 50% of her HP, Kilnara transforms ino the Avatar of Bethekk and awakens any remaining sleeping panthers."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 52059,
        },
        userdata = {
            lashtext = "",
        },
        onstart = {
            {
                "repeattimer",{"checkhp", 1},
            },
        },
        
        ordering = {
            alerts = {"tearswarn","lashwarn","wavewarn","phase2soonwarn","phase2warn","camouflagecd","camouflagewarn"},
        },
        
        alerts = {
            -- Tears of Blood
            tearswarn = {
                varname = format(L.alert["%s Warning"],SN[96435]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s - INTERRUPT!"],SN[96435]),
                time = 6,
                color1 = "MAGENTA",
                sound = "ALERT2",
                icon = ST[96435],
            },
            -- Lash of Anguish
            lashwarn = {
                varname = format(L.alert["%s Warning"],SN[96958]),
                type = "simple",
                text = "<lashtext>",
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT8",
                icon = ST[96958],
            },
            -- Wave of Agony
            wavewarn = {
                varname = format(L.alert["%s Warning"],SN[98270]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[98270]),
                time = 4,
                color1 = "RED",
                sound = "ALERT5",
                icon = ST[98270],
            },
            -- Phase 2
            phase2soonwarn = {
                varname = format(L.alert["%s soon Warning"],"Phase 2"),
                type = "simple",
                text = format(L.alert["%s soon ..."],"Phase 2"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[78832],
            },
            phase2warn = {
                varname = format(L.alert["%s Warning"],"Phase 2"),
                type = "centerpopup",
                warningtext = format(L.alert["%s"],"Phase 2"),
                text = format(L.alert["%s transition"],"Phase 2"),
                time = 6,
                color1 = "TURQUOISE",
                sound = "ALERT1",
                icon = ST[78832],
            },
            -- Camouflage
            camouflagecd = {
                varname = format(L.alert["%s CD"],SN[96594]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96594]),
                time = 24.5,
                flashtime = 5,
                color1 = "WHITE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[96594],
            },
            camouflagewarn = {
                varname = format(L.alert["%s Warning"],SN[96594]),
                type = "simple",
                text = format(L.alert["%s"],SN[96594]),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT7",
                icon = ST[96594],
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","60"},
                    "alert","phase2soonwarn",
                    "canceltimer","checkhp",
                },
            },
            
        },
        events = {
			-- Tears of Blood
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96435,
                execute = {
                    {
                        "alert","tearswarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 96435,
                execute = {
                    {
                        "quash","tearswarn",
                    },
                },
            },
            -- Lash of Anguish
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96958,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{lashtext = format(L.alert["%s on %s - DISPEL!"],SN[96958],L.alert["YOU"])},
                        "alert","lashwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{lashtext = format(L.alert["%s on <%s> - DISPEL!"],SN[96958],"#5#")},
                        "alert","lashwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    -- Wave of Agony
                    {
                        "expect",{"#5#","==","98270"},
                        "expect",{"#1#","==","boss1"},
                        "alert","wavewarn",
                    },
                    -- Phase 2
                    {
                        "expect",{"#2#","==",SN[97380]},
                        "expect",{"#1#","==","boss1"},
                        "alert","phase2warn",
                        "schedulealert",{"camouflagecd", 6},
                    },
                    -- Camouflage
                    {
                        "expect",{"#2#","==",SN[96594]},
                        "expect",{"#1#","==","boss1"},
                        "quash","camouflagecd",
                        "alert","camouflagecd",
                        "alert","camouflagewarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ZANZIL
---------------------------------

do
    local data = {
        version = 1,
        key = "zanzil",
        zone = L.zone["Zul'Gurub"],
        category = L.zone["Zul'Gurub"],
        name = "Zanzil",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Zanzil the Outcast.blp",
        triggers = {
            scan = {
                52053, -- Zanzil
            },
        },
        onactivate = {
            tracing = {
                52053,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 52053,
        },
        userdata = {},
        onstart = {
            {
                "alert","firecd",
                "alert","secretcd",
            },
        },
        
        arrows = {
            berserkerarrow = {
                varname = format("%s",SN[96325]),
                unit = "player",
                persist = 15,
                action = "TOWARD",
                msg = L.alert["For freezing Zanzili Berserker"],
                spell = SN[96325],
                fixed = true,
                xpos = 0.3163953423,
                ypos = 0.2738853693,
                sound = "None",
                cancelrange = 8,
                range1 = 10,
                range2 = 20,
                range3 = 30,
                texture = ST[96325],
            },
            zombiesarrow = {
                varname = format("%s",SN[96330]),
                unit = "player",
                persist = 15,
                action = "TOWARD",
                msg = L.alert["For killing Zanzili Zombies"],
                spell = SN[96330],
                fixed = true,
                xpos = 0.3303298354,
                ypos = 0.2445115447,
                sound = "None",
                cancelrange = 8,
                range1 = 10,
                range2 = 20,
                range3 = 30,
                texture = ST[96326],
            },
            gasarrow = {
                varname = format("%s",SN[96328]),
                unit = "player",
                persist = 15,
                action = "TOWARD",
                msg = L.alert["To survive Graveyard Gas"],
                spell = SN[96328],
                fixed = true,
                xpos = 0.3046608567,
                ypos = 0.2397549748,
                sound = "None",
                cancelrange = 8,
                range1 = 10,
                range2 = 20,
                range3 = 30,
                texture = ST[96328],
            }
        },
        filters = {
            bossemotes = {
                zombiesemote = {
                    name = "Zombies summon",
                    pattern = "to resurrect a swarm",
                    hasIcon = false,
                    texture = ST[96319],
                },
                gasemote = {
                    name = "Toxic Gas",
                    pattern = "fills the area with a",
                    hasIcon = false,
                    texture = ST[96338],
                },
                berserkeremote = {
                    name = "Zanzili Berserker",
                    pattern = "begins to resurrect a Zanzili",
                    hasIcon = false,
                    texture = ST[96316],
                },
                chasingemote = {
                    name = "Berserker chasing you",
                    pattern = "is chasing you. Run",
                    hasIcon = false,
                    texture = ST[96631],
                },
            },
        },
        ordering = {
            alerts = {"firecd","firewarn","secretcd"},
        },
        
        alerts = {
            -- Zanzili Fire
            firecd = {
                varname = format(L.alert["%s CD"],SN[96914]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[96914]),
                time = 13,
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[96914],
            },
            firewarn = {
                varname = format(L.alert["%s Warning"],SN[96914]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[96914]),
                time = 1.5,
                color1 = "MAGENTA",
                sound = "ALERT2",
                icon = ST[96914],
            },
            -- Zanzil's Secret Technique
            secretcd = {
                varname = format(L.alert["%s CD"],"Zanzil's Secret Technique"),
                type = "dropdown",
                text = format(L.alert["Next %s"],"Zanzil's Secret Technique"),
                time = 30,
                flashtime = 10,
                color1 = "LIGHTGREEN",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[80856],
            },
        },
        events = {
			-- Zanzili Fire
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96914,
                execute = {
                    {
                        "quash","firecd",
                        "alert","firecd",
                        "alert","firewarn",
                    },
                },
            },
            -- Zanzil's Secret Technique
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = 96316, -- Zanzil's Resurrection Elixir (Zanzili Berserker)
                execute = {
                    {
                        "quash","secretcd",
                        "alert","secretcd",
                        "arrow","berserkerarrow",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = 96319, -- Zanzil's Resurrection Elixir (Zanzili Zombies)
                execute = {
                    {
                        "quash","secretcd",
                        "alert","secretcd",
                        "arrow","zombiesarrow",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96338, -- Zanzil's Graveyard Gas
                execute = {
                    {
                        "quash","secretcd",
                        "alert","secretcd",
                        "arrow","gasarrow",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- JIN'DO THE GODBREAKER
---------------------------------

do
    local data = {
        version = 11,
        key = "jindo",
        zone = L.zone["Zul'Gurub"],
        category = L.zone["Zul'Gurub"],
        name = "Jin'do the Godbreaker",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Jindo the Godbreaker.blp",
        triggers = {
            scan = {
                52148, -- Jin'do the Godbreaker
            },
        },
        onactivate = {
            tracing = {
                52148,
            },
            phasemarkers = {
                {
                    {0.7, "Phase 2","At 70% of his HP, Jin'do drags the players into the spirit world."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 52148,
        },
        userdata = {
            spiritcd = {3, 10, loop = false, type = "series"},
            spirittwisterannounced = "no",
            isDeadzoned = "no",
            gazetext = "",
            chainscount = 0,
            spiritcount = 0,
            
        },
        onstart = {
            {
                "alert","shadowscd",
                "repeattimer",{"checkhp", 1},
            },
        },
        
        announces = {
            spirittwister = {
                varname = "%s complete",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5759,
                msg = format(L.alert["<DXE> There are enough Twisted Spirits spawned to complete %s. Kill them within 15 seconds to receive the achievement."],AL[5759]),
                throttle = true,
            },
        },
        raidicons = {
            slammark = {
                varname = format("%s {%s}",SN[97198],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 10,
                unit = "#5#",
                reset = 5,
                icon = 1,
                texture = ST[97198],
            },
            chainsmark = {
                varname = format("%s {%s-%s}","Weakened Chains","ENEMY_DEBUFF",SN[97091]),
                type = "MULTIENEMY",
                persist = 10,
                unit = "#4#",
                reset = 60,
                icon = 2,
                total = 3,
                texture = ST[97091],
            },
        },
        filters = {
            bossemotes = {
                chasedemote = {
                    name = "Shadows of Hakkar",
                    pattern = "charges his weapon with the",
                    hasIcon = false,
                    texture = ST[97172],
                },
            },
        },
        counters = {
            chainscounter = {
                variable = "chainscount",
                label = "Hakkar's Chains desstroyed",
                pattern = "%d / %d",
                value = 0,
                minimum = 0,
                maximum = 3,
            },
            spiritcounter = {
                variable = "spiritcount",
                label = format("%s Twisted Spirits spawned",TI["AchievementShield"]),
                pattern = "%d / %d",
                value = 0,
                minimum = 0,
                maximum = 20,
                difficulty = 20,
            },
        },
        phrasecolors = {
            {"Hakkar's Chains","GOLD"},
            {"GO NEAR CHAINS","CYAN"},
        },
        ordering = {
            alerts = {"shadowscd","shadowswarn","shadowsduration","phase2soonwarn","phase2warn","slamwarn","slamcd","slamselfwarn","chainsweakenedwarn","chainsdestroyedwarn"},
        },
        
        alerts = {
            -- Shadows of Hakkar
            shadowscd = {
                varname = format(L.alert["%s CD"],SN[97172]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97172]),
                time = 20,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[97172],
            },
            shadowswarn = {
                varname = format(L.alert["%s Warning"],SN[97172]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[97172]),
                time = 3,
                time2 = 5.7,
                color1 = "MAGENTA",
                color2 = "RED",
                sound = "ALERT2",
                icon = ST[97172],
            },
            shadowsduration = {
                varname = format(L.alert["%s Duration"],SN[97172]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s"],SN[97172]),
                time = 8,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT8",
                icon = ST[97172],
            },
            -- Phase 2
            phase2soonwarn = {
                varname = format(L.alert["%s soon Warning"],"Phase 2"),
                type = "simple",
                text = format(L.alert["%s soon ..."],"Phase 2"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[78832],
            },
            phase2warn = {
                varname = format(L.alert["%s Warning"],"Phase 2"),
                type = "simple",
                text = format(L.alert["%s"],"Phase 2"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT1",
                icon = ST[78832],
            },
            -- Body Slam
            slamcd = {
                varname = format(L.alert["%s CD"],SN[97198]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[97198]),
                time = 20,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[97198],
                tag = "#1#",
            },
            slamwarn = {
                varname = format(L.alert["%s Warning"],SN[97198]),
                type = "simple",
                text = "<gazetext>",
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[97198],
            },
            slamselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[97198]),
                type = "simple",
                text = format(L.alert["%s on %s - GO NEAR CHAINS!"],SN[97198],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "BEWARE",
                icon = ST[97198],
                emphasizewarning = true,
            },
            -- Chains weakened
            chainsweakenedwarn = {
                varname = format(L.alert["%s weakened Warning"],SN[97091]),
                type = "simple",
                text = format(L.alert["%s weakened - DESTROY THEM!"],SN[97091]),
                time = 1,
                color1 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[97091],
            },
            -- Chains Destroyed
            chainsdestroyedwarn = {
                varname = format(L.alert["%s destroyed Warning"],SN[97091]),
                type = "simple",
                text = format(L.alert["%s destroyed (%s remaining)"],SN[97091],"&substract|3|<chainscount>&"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[97091],
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","80"},
                    "alert","phase2soonwarn",
                    "canceltimer","checkhp",
                },
            },
            spirittimer = {
                {
                    "set",{spiritcount = "INCR|1"},
                    "scheduletimer",{"spirittimer", "<spiritcd>"},
                    "expect",{"<spiritcount>",">=",20},
                    "expect",{"<spirittwisterannounced>","==","no"},
                    "expect",{"&itemenabled|spirittwister&","==","true"},
                    "announce","spirittwister",
                    "set",{spirittwisterannounced = "yes"},
                },
            },
        },
        events = {
            -- Deadzone on Jin'do
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 97600,
                execute = {
                    {
                        "expect",{"#4#","==","&unitguid|boss1&"},
                        "set",{isDeadzoned = "yes"},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 97600,
                execute = {
                    {
                        "expect",{"#4#","==","&unitguid|boss1&"},
                        "set",{isDeadzoned = "no"},
                    },
                },
            },
			-- Shadows of Hakkar
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 97172,
                execute = {
                    {
                        "quash","shadowscd",
                        "alert","shadowscd",
                    },
                    {
                        "expect",{"<isDeadzoned>","==","no"},
                        "alert","shadowswarn",
                    },
                    {
                        "expect",{"<isDeadzoned>","==","yes"},
                        "alert",{"shadowswarn",time = 2},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 97172,
                execute = {
                    {
                        "expect",{"#4#","==","&unitguid|boss1&"},
                        "alert","shadowsduration",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 97172,
                execute = {
                    {
                        "expect",{"#4#","==","&unitguid|boss1&"},
                        "quash","shadowsduration",
                    },
                },
            },
            
            -- Phase 2
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[98861]},
                        "expect",{"#1#","==","boss1"},
                        "alert","phase2warn",
                        "quash","shadowscd",
                        "quash","shadowswarn",
                        "quash","shadowsduration",
                        "tracing",{},
                        "removephasemarker",{1,1},
                        "counter","chainscounter",
                        "scheduletimer",{"spirittimer", "<spiritcd>"},
                        "expect",{"&itemenabled|spirittwister&","==","true"},
                        "counter","spiritcounter",
                    },
                },
            },
            -- Twisted Spirit dies
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","52624"},
                        "set",{spiritcount = "DECR|1"},
                        "expect",{"<spiritcount>","<",20},
                        "set",{spirittwisterannounced = "no"},
                    },
                },
            },
            -- Spirit Warrior's Gaze
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 97597,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","slamselfwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{gazetext = format(L.alert["%s on <%s>!"],SN[97198],"#5#")},
                        "alert","slamwarn",
                    },
                    {
                        "raidicon","slammark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 97597,
                execute = {
                    {
                        "removeraidicon","slammark",
                    },
                },
            },
            -- Body Slam
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 97198,
                execute = {
                    {
                        "alert","slamcd",
                    },
                },
            },
            -- Chains Weakened
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 97417,
                execute = {
                    {
                        "alert","chainsweakenedwarn",
                        "raidicon","chainsmark",
                        "temptracing","#4#",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellid = 97091,
                execute = {
                    {
                        "removeraidicon","chainsmark",
                        "set",{chainscount = "INCR|1"},
                        "alert","chainsdestroyedwarn",
                    },
                },
            },  
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","52730"},
                        "quash",{"slamcd","#4#"},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- TRASH
---------------------------------

do
    local data = {
        version = 1,
        key = "zulgurubtrash",
        zone = L.zone["Zul'Gurub"],
        category = L.zone["Zul'Gurub"],
        name = "Trash",
        triggers = {
            scan = {
                52381, -- Venomacer T'Kulu * 
                52311, -- Venomguard Destoyer
                52974, -- Zandalari Juggernaut * 
                
                52076, -- Gurubashi Cauldron-Mixer
                52606, -- Gurubashi Warmonger
                
                52968, -- Zandalari Archon
                52339, -- Lesser Priest of Bethekk
                52325, -- Gurubashi Blood Drinker * 
                
                52956, -- Zandalari Juggernaut (2) * 
                52958, -- Zandalari Hierophant
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {
            otherlink = "",
            linkonme = "no",
            guardiantext = "",
        },
        arrows = {
            linkarrow = {
                varname = format("%s",SN[97092]),
                unit = "<otherlink>",
                persist = 10,
                action = "AWAY",
                msg = L.alert["Move AWAY!"],
                spell = SN[97092],
                sound = "None",
                range1 = 5,
                range2 = 15,
                range3 = 30,
                texture = ST[97092],
            },
        },
        raidicons = {
            linkmark = {
                varname = format("%s {%s}",SN[97092],"PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 6,
                unit = "#5#",
                reset = 5,
                icon = 1,
                total = 2,
                texture = ST[97092],
            },
            bloodleechmark = {
                varname = format("%s {%s}",SN[96952],"PLAYER_DEBUFF"),
                type = "MULTIENEMY",
                persist = 6,
                unit = "#1#",
                reset = 6,
                icon = 1,
                total = 2,
                texture = ST[96952],
            },
        },
        phrasecolors = {
            {"Gurubashi Blood Drinker","GOLD"},
            {"Zandalari Juggernaut","GOLD"},
            {"Zandalari Hierophant","GOLD"},
            {"DON'T KILL HIM","RED"},
        },
        ordering = {
            alerts = {"linkcasting","linkselfwarn","poolselfwarn","quakeselfwarn","bloodleechwarn","guardianwarn"},
        },
        
        alerts = {
            -- Toxic Link
            linkselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[97092]),
                type = "simple",
                text = format(L.alert["%s on %s!"],SN[97092],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                icon = ST[97092],
                throttle = 2,
                emphasizewarning = true,
            },
            linkcasting = {
                varname = format(L.alert["%s Casting"],SN[96475]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[96475]),
                time = 2,
                color1 = "LIGHTGREEN",
                sound = "None",
                icon = ST[96475],
                tag = "#1#",
            },
            -- Pool of Acrid Tears
            poolselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[97085]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[97085],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                icon = ST[97085],
                throttle = 2,
                emphasizewarning = true,
            },
            -- Minor Quake
            quakeselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[97988]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[97988],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[97988],
                throttle = 2,
                emphasizewarning = true,
            },
            -- Blood Leech
            bloodleechwarn = {
                varname = format(L.alert["%s Warning"],SN[96952]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Gurubashi Blood Drinker",SN[96952]),
                text = format(L.alert["%s - INTERRUPT"],SN[96952]),
                time = 6,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[96952],
                tag = "#1#",
            },
            -- Ancient Guardian
            guardianwarn = {
                varname = format(L.alert["%s Warning"],SN[97978]),
                type = "centerpopup",
                warningtext = "<guardiantext>",
                text = format(L.alert["%s fades"],SN[97978]),
                time = 15,
                color1 = "YELLOW",
                sound = "BEWARE",
                icon = ST[97978],
            },
            
        },
        timers = {
            linktimer = {
                {
                    "expect",{"<linkonme>","==","yes"},
                    "expect",{"<otherlink>","~=",""},
                    "arrow","linkarrow",
                },
            },
        },
        events = {
            -- Toxic Link
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 96477,
                execute = {
                    {
                        "raidicon","linkmark",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{otherlink = "#5#"},
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","linkselfwarn",
                        "set",{linkonme = "yes"},
                        "scheduletimer",{"linktimer", 0.5},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 96475,
                execute = {
                    {
                        "alert","linkcasting",
                    },
                },
            },
            
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 96477,
                execute = {
                    {
                        "removeraidicon","#5#",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "removearrow","<otherlink>",
                        "set",{
                            linkonme = "no",
                            otherlink = "",
                        },
                    },
                },
            },
            -- Pool of Acrid Tears
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 97085,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","poolselfwarn",
                    },
                },
            },
            -- Minor Quake
            {
                type = "combatevent",
                eventtype = "SPELL_PERIODIC_DAMAGE",
                spellname = 97988,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","quakeselfwarn",
                    },
                },
            },
            -- Blood Leech
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 96952,
                execute = {
                    {
                        "alert","bloodleechwarn",
                        "raidicon","bloodleechmark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 96952,
                execute = {
                    {
                        "quash","bloodleechwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","52325"},
                        "quash",{"bloodleechwarn","#4#"},
                    },
                    {
                        "expect",{"&npcid|#4#&","==","52381"},
                        "quash",{"linkcasting","#4#"},
                    },
                },
            },
            -- Ancient Guardian
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 97978,
                execute = {
                    {
                        "set",{guardiantext = format(L.alert["%s on %s - DON'T KILL HIM!"],SN[97978],"#5#")},
                        "alert","guardianwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 97978,
                execute = {
                    {
                        "quash","guardianwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

do
    local data = {
        key = "cacheofmadness",
        name = "Cache of Madness",
        zone = L.zone["Zul'Gurub"],
    }

    DXE:RegisterEncounterGroup(data)
end
