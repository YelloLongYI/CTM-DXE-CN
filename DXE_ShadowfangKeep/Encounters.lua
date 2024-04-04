local L,SN,ST,AL,AN,AT,TI = DXE.L,DXE.SN,DXE.ST,DXE.AL,DXE.AN,DXE.AT,DXE.TI

---------------------------------
-- BARON ASHBURY
---------------------------------

do
    local data = {
        version = 4,
        key = "baronashbury",
        zone = L.zone["Shadowfang Keep"],
        category = L.zone["Shadowfang Keep"],
        name = "Baron Ashbury",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Baron Ashbury.blp",
        triggers = {
            scan = {
                46962, -- Baron Ashbury
            },
        },
        onactivate = {
            tracing = {
                46962,
            },
            phasemarkers = {
                {
                    {0.25, "Dark Archangel Form", "At 25% of his HP, Baron Ashbury takes the form of a Dark Archangel.",2}, -- heroic
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 46962,
        },
        userdata = {
            paincd = {5, 21, loop = false, type = "series"},
            asphyxiatecd = {18,45, loop = false, type = "series"},
            painttext = "",
            asphyxiatewarned = "no",
            pardonfailed = "no",
        },
        onstart = {
            {
                "alert","paincd",
                "alert","asphyxiatecd",
                "expect",{"&difficulty&","==","2"}, --5h
                "repeattimer",{"checkhp",1},
            },
        },
        
        raidicons = {
            painmark = {
                varname = format("%s {%s}",SN[93581],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                persist = 6,
                unit = "#4#",
                reset = 6,
                icon = 2,
                texture = ST[93581],
            },
        },
        announces = {
            pardonfailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5503,
                msg = format(L.alert["<DXE> %s: Achievement failed!"],AL[5503]),
                throttle = true,
            },
        },
        filters = {
            bossemotes = {
                stayemote = {
                    name = "Stay of Execution",
                    pattern = "begins to cast %[Stay of Execution%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[93468],
                },
            },
        },
        ordering = {
            alerts = {"paincd","painwarn","asphyxiatecd","asphyxiatewarn","staycast","staykickwarn","darkangelsoonwarn","darkangelwarn"},
        },
        
        alerts = {
            -- Pain and Suffering
            paincd = {
                varname = format(L.alert["%s CD"],SN[93581]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[93581]),
                time = "<paincd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[93581],
            },
            painwarn = {
                varname = format(L.alert["%s Warning"],SN[93581]),
                type = "simple",
                text = "<painttext>",
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[93581],
            },
            -- Asphyxiate
            asphyxiatecd = {
                varname = format(L.alert["%s CD"],SN[93710]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[93710]),
                time = "<asphyxiatecd>",
                flashtime = 10,
                color1 = "PURPLE",
                color2 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[93710],
            },
            asphyxiatewarn = {
                varname = format(L.alert["%s Warning"],SN[93710]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[93710]),
                time = 6,
                color1 = "PINK",
                sound = "ALERT9",
                icon = ST[93710],
            },
            -- Stay of Execution
            staycast = {
                varname = format(L.alert["%s Cast"],SN[93468]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[93468]),
                time = 8,
                color1 = "YELLOW",
                sound = "ALERT7",
                icon = ST[93468],
            },
            staykickwarn = {
                varname = format(L.alert["%s interrupt Warning"],SN[93468]),
                type = "simple",
                text = format(L.alert["%s - INTERRUPT!"],SN[93468]),
                time = 8,
                color1 = "YELLOW",
                sound = "ALERT7",
                icon = ST[93468],
            },
            -- Dark Archangel Form soon
            darkangelsoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[93757]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[93757]),
                time = 1,
                flashtime = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[93757],
            },
            -- Dark Archangel Form
            darkangelwarn = {
                varname = format(L.alert["%s Warning"],SN[93757]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[93757]),
                time = 3,
                flashtime = 5,
                color1 = "CYAN",
                sound = "BEWARE",
                icon = ST[93757],
            },
        },
        timers = {
            checkhp = {
				{
					"expect",{"&gethp|boss1&","<","30"},
					"alert","darkangelsoonwarn",
                    "canceltimer","checkhp",
				},
            },
            resetasphyxiate = {
                {
                    "set",{asphyxiatewarned = "no"},
                },
            },
            staykick = {
                {
                    "alert","staykickwarn",
                },
            },
        },
        events = {
            -- Pain and Suffering
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 93712,
				execute = {
					{
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{painttext = format(L.alert["%s on %s"],SN[93712],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{painttext = format(L.alert["%s on <%s>"],SN[93712],"#5#")},
                    },
                    {
						"quash","paincd",
                        "alert","paincd",
                        "alert","painwarn",
                        "raidicon","painmark",
					},
				},
			},
            -- Asphyxiate
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 93423,
				execute = {
					{
                        "expect",{"<asphyxiatewarned>","==","no"},
						"set",{asphyxiatewarned = "yes"},
                        "quash","asphyxiatecd",
						"alert","asphyxiatecd",
						"alert","asphyxiatewarn",
					},
				},
			},
            -- Asphyxiate (removed)
            {
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 93423,
				execute = {
					{
                        "quash","asphyxiatewarn",
                        "expect",{"<asphyxiatewarned>","==","yes"},
						"scheduletimer",{"resetasphyxiate",3},
					},
				},
			},
            -- Stay of Execution
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 93705,
				execute = {
					{
                        "expect",{"&difficulty&","==","2"}, --5h
						"alert","staycast",
                        "scheduletimer",{"staykick",4},
					},
				},
			},
            -- Stay of Execution
            {
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 93705,
				execute = {
					{
						"quash","staycast",
                        "canceltimer","staykick",
					},
				},
			},
            -- Dark Archangel Form
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 93757,
				execute = {
					{
						"alert","darkangelwarn",
                        "quash","asphyxiatecd",
                        "quash","paincd",
					},
				},
			},
            -- Stay of Execution (boss healed)
            {
                type = "combatevent",
                eventtype = "SPELL_HEAL",
                spellname = 93706,
                execute = {
                    {
                        "expect",{"&difficulty&","==","2"},
                        "expect",{"&npcid|#1#&","==","46962"},
                        "expect",{"&npcid|#4#&","==","46962"},
                        "expect",{"<pardonfailed>","==","no"},
                        "announce","pardonfailed",
                        "set",{pardonfailed = "yes"},
                    },
                },
            },
            
            
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- BARON SILVERLAINE
---------------------------------

do
    local data = {
        version = 2,
        key = "baronsilverlaine",
        zone = L.zone["Shadowfang Keep"],
        category = L.zone["Shadowfang Keep"],
        name = "Baron Silverlaine",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Baron Silverlaine.blp",
        triggers = {
            scan = {
                3887, -- Baron Silverlaine
            },
        },
        onactivate = {
            tracing = {
                3887,
            },
            phasemarkers = {
                {
                    {0.7, "Summon Worgen Spirit", "Baron Silverlaine summons one of four random Worgen Spirits.", 1}, -- normal
                    {0.35, "Summon Worgen Spirit", "Baron Silverlaine summons one of four random Worgen Spirits.", 1}, -- normal
                    {0.9, "Summon Worgen Spirit", "Baron Silverlaine summons one of four random Worgen Spirits.", 2}, -- heroic
                    {0.6, "Summon Worgen Spirit", "Baron Silverlaine summons one of four random Worgen Spirits.", 2}, -- heroic
                    {0.3, "Summon Worgen Spirit", "Baron Silverlaine summons one of four random Worgen Spirits.", 2}, -- heroic
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 3887,
        },
        userdata = {
            cursedveilcd = {6, 25, loop = false, type = "series"},
            firstworgenwarned = "no",
            secondworgenwarned = "no",
            thirdworgenwarned = "no",
        },
        onstart = {
            {
                "alert","cursedveilcd",
                "repeattimer",{"checkhp",1},
            },
        },
        ordering = {
            alerts = {"cursedveilcd","cursedveilwarn","worgensoonwarn","summonwarn","spawningcountdown"},
        },
        
        alerts = {
            -- Cursed Veil 
            cursedveilcd = {
                varname = format(L.alert["%s CD"],SN[93956]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[93956]),
                time = "<cursedveilcd>",
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "PINK",
                sound = "MINORWARNING",
                icon = ST[93956],
            },
            cursedveilwarn = {
                varname = format(L.alert["%s Warning"],SN[93956]),
                type = "simple",
                text = format(L.alert["%s"],SN[93956]),
                time = 1.5,
                color1 = "TURQUOISE",
                sound = "ALERT8",
                icon = ST[93956],
            },
            -- Summon Worgen Spirit
            worgensoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[93857]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[93857]),
                time = 1,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            summonwarn = {
                varname = format(L.alert["%s Warning"],SN[93857]),
                type = "simple",
                text = format(L.alert["New: %s"],"Worgen Spirit"),
                time = 2,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[93857],
            },
            spawningcountdown = {
                varname = L.alert["Worgen Spirit Spawning Countdown"],
                type = "centerpopup",
                text = "Worgen spawning in",
                time = 4,
                color1 = "YELLOW",
                sound = "ALERT7",
                icon = ST[93857],
            },
        },
        timers = {
            checkhp = {
				{
					"expect",{"&gethp|boss1&","<","95"},
                    "expect",{"<firstworgenwarned>","==","no"},
                    "set",{firstworgenwarned = "yes"},
					"alert","worgensoonwarn",
				},
                {
					"expect",{"&gethp|boss1&","<","70"},
                    "expect",{"<secondworgenwarned>","==","no"},
                    "set",{secondworgenwarned = "yes"},
					"alert","worgensoonwarn",
				},
                {
					"expect",{"&gethp|boss1&","<","40"},
                    "expect",{"<thirdworgenwarned>","==","no"},
                    "set",{thirdworgenwarned = "yes"},
					"alert","worgensoonwarn",
				},
                {
                    "expect",{"<firstworgenwarned>","==","yes"},
                    "expect",{"<secondworgenwarned>","==","yes"},
                    "expect",{"<thirdworgenwarned>","==","yes"},
                    "canceltimer","checkhp",
                },
            }
        },
        events = {
            -- Cursed Veil
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 93956,
                execute = {
                    {
                        "quash","cursedveilcd",
                        "alert","cursedveilcd",
                        "alert","cursedveilwarn",
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
                        "schedulealert",{"spawningcountdown",2},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- COMMANDER SPRINGVALE
---------------------------------

do
    local data = {
        version = 4,
        key = "commanderspringvale",
        zone = L.zone["Shadowfang Keep"],
        category = L.zone["Shadowfang Keep"],
        name = "Commander Springvale",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Commander Springvale.blp",
        triggers = {
            scan = {
                4278, -- Commander Springvale
            },
        },
        onactivate = {
            tracing = {
                4278,
            },
            counters = {"powercounter"},
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 4278,
        },
        userdata = {
            -- Timers
            desecrationcd = {15,20, loop = false, type = "series"},
            
            -- Texts
            unholyemptext = "",
            forsakentext = "",
            wordofshametext = "",
            
            -- Counters
            unholypowercount = 0,
            
            -- Switches
            groundfailed = "no",
        },
        onstart = {
            {
                "alert","desecrationcd",
                "expect",{"&difficulty&","==","2"}, --5h
                "alert","officersincommingcd",
                "scheduletimer",{"officersincomming",40},
            },
        },
        
        announces = {
            groundfailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5504,
                msg = format(L.alert["<DXE> %s: Achievement failed!"],AL[5504]),
                throttle = true,
            },
        },
        counters = {
            powercounter = {
                variable = "unholypowercount",
                label = "Unholy Power",
                value = 0,
                minimum = 0,
                maximum = 3,
            },
        },
        phrasecolors = {
            {"Tormented Officer:","GOLD"},
            {"Wailing Guardsman:","GOLD"},
        },
        ordering = {
            alerts = {"desecrationcd","desecrationwarn","desecrationselfwarn","unholyempwarn","wordofshamewarn","officersincommingcd","officersincommingwarn"},
        },
        
        alerts = {
            -- Desecration 
            desecrationcd = {
                varname = format(L.alert["%s CD"],SN[93687]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[93687]),
                time = "<desecrationcd>",
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "PINK",
                sound = "MINORWARNING",
                icon = ST[93687],
            },
            desecrationwarn = {
                varname = format(L.alert["%s Warning"],SN[93687]),
                type = "simple",
                text = format(L.alert["%s"],SN[93687]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT8",
                icon = ST[93687],
            },
            -- Unholy Empowerment
            unholyempwarn = {
                varname = format(L.alert["%s Warning"],SN[93844]),
                type = "centerpopup",
                warningtext = "<unholyemptext>",
                text = format(L.alert["%s - INTERRUPT!"],SN[93844]),
                time = 2.5,
                color1 = "CYAN",
                sound = "ALERT2",
                icon = ST[93844],
                tag = "#1#",
            },
            -- Word of Shame
            wordofshamewarn = {
                varname = format(L.alert["%s Warning"],SN[93852]),
                type = "simple",
                text = "<wordofshametext>",
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT5",
                icon = ST[93852],
            },
            -- Officers wave
            officersincommingwarn = {
                varname = format(L.alert["%s Warning"],"Tormented Officers"),
                type = "simple",
                text = L.alert["New: Tormented Officers"],
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT9",
                icon = ST[469],
            },
            officersincommingcd = {
                varname = format(L.alert["%s CD"],"Tormented Officers"),
                type = "dropdown",
                text = L.alert["New Tormented Officers"],
                time = 40,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[469],
            },
            -- Desecration
            desecrationselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[94370]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[94370],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                icon = ST[94370],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
        },
        timers = {
            officersincomming = {
                {
                    "alert","officersincommingwarn",
                    "alert","officersincommingcd",
                    "scheduletimer",{"officersincomming",40},
                }
            }
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
                spellname = 94370,
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
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- LORD WALDEN
---------------------------------

do
    local data = {
        version = 1,
        key = "lordwalden",
        zone = L.zone["Shadowfang Keep"],
        category = L.zone["Shadowfang Keep"],
        name = "Lord Walden",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Lord Walden.blp",
        triggers = {
            scan = {
                46963, -- Lord Walden
            },
        },
        onactivate = {
            tracing = {
                46963,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 46963,
        },
        userdata = {
            mixturecd = {10, 15, loop = false, type = "series"},
            coagualntwarned = "no"
        },
        onstart = {},
        ordering = {
            alerts = {"shardswarn","mysterytoxinwarn","coagulentwarn","catalystwarn"},
        },
        
        alerts = {
            -- Ice Shards
            shardswarn = {
                varname = format(L.alert["%s Warning"],SN[93703]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[93703]),
                time = 5,
                flashtime = 5,
                color1 = "TURQUOISE",
                sound = "ALERT9",
                icon = ST[93703],
            },
            -- Toxic Coagulent 
            coagulentwarn = {
                varname = format(L.alert["%s Warning"],SN[93617]),
                type = "simple",
                text = format(L.alert["%s - KEEP MOVING"],SN[93617]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                icon = ST[93617],
                emphasizewarning = true,
            },
            -- Conjure Mystery Toxin
            mysterytoxinwarn = {
                varname = format(L.alert["%s Warning"],SN[93562]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[93562]),
                time = 11,
                color1 = "LIGHTGREEN",
                sound = "MINORWARNING",
                icon = ST[31228],
            },
            -- Toxic Catalyst
            catalystwarn = {
                varname = format(L.alert["%s Warning"],SN[93689]),
                type = "simple",
                text = format(L.alert["%s - EXECUTE!"],SN[93689]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "BURST",
                icon = ST[93689],
                throttle = 30,
            },
        },
        timers = {
            coagualntreset = {
                {
                    "set",{coagualntwarned = "no"},
                },
            },
        },
        events = {
            -- Ice Shards
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 93703,
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
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- LORD GODFREY
---------------------------------

do
    local data = {
        version = 3,
        key = "lordgodfrey",
        zone = L.zone["Shadowfang Keep"],
        category = L.zone["Shadowfang Keep"],
        name = "Lord Godfrey",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Lord Godfrey.blp",
        triggers = {
            scan = {
                46964, -- Lord Godfrey
            },
        },
        onactivate = {
            tracing = {
                46964,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 46964,
        },
        userdata = {
            ghoulscd = {10,30, loop = false, type = "series"},
        },
        onstart = {
            {
                "alert","barragecd",
                "alert","ghoulscd",
            },
        },
        ordering = {
            alerts = {"bulletswarn","ghoulscd","ghoulswarn","barragecd","barragewarn","barragedur","barrageselfwarn"},
        },
        
        alerts = {
            -- Pistol Barrage
            barragewarn = {
                varname = format(L.alert["%s Warning"],SN[93520]),
                type = "centerpopup",
                text = format(L.alert["Preparing for %s"],SN[93520]),
                time = 2,
                flashtime = 5,
                color1 = "TURQUOISE",
                sound = "ALERT9",
                icon = ST[93520],
                throttle = 2,
            },
            barragedur = {
                varname = format(L.alert["%s Duration"],SN[93520]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[93520]),
                time = 6,
                flashtime = 10,
                color1 = "LIGHTBLUE",
                sound = "ALERT9",
                icon = ST[93520],
                fillDirection = "DEPLETE",
            },
            barragecd = {
                varname = format(L.alert["%s CD"],SN[93520]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[93520]),
                time = 30,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[93520],
            },
            barrageselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[93520]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[93520],L.alert["YOU"]),
                time = 1,
                flashtime = 5,
                color1 = "TURQUOISE",
                sound = "ALERT10",
                icon = ST[93520],
                emphasizewarning = true,
            },
            -- Summon Bloodthirsty Ghouls
            ghoulscd = {
                varname = format(L.alert["%s CD"],SN[93707]),
                type = "dropdown",
                text = format(L.alert["New %s"],"Bloodthirsty Ghouls"),
                time = "<ghoulscd>",
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[93707],
            },
            ghoulswarn = {
                varname = format(L.alert["%s Warning"],SN[93707]),
                type = "centerpopup",
                text = format(L.alert["New: %s"],"Bloodthirsty Ghouls"),
                time = 3,
                flashtime = 5,
                color1 = "ORANGE",
                sound = "ALERT9",
                icon = ST[93707],
            },
            -- Cursed Bullets
            bulletswarn = {
                varname = format(L.alert["%s Warning"],SN[93761]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[93761]),
                time = 1,
                flashtime = 1,
                color1 = "CYAN",
                sound = "ALERT2",
                icon = ST[93761],
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
                        "alert","barragecd",
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
                spellname = 93761,
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
                        "expect",{"#2#","==",SN[93761]},
                        "expect",{"#1#","find","boss"},
                        "quash","bulletswarn",
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
        key = "sfktrash",
        zone = L.zone["Shadowfang Keep"],
        category = L.zone["Shadowfang Keep"],
        name = "Trash",
        triggers = {
            scan = {
                47135, -- Fetid Ghoul
                47140, -- Sorcerous Skeleton
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {},
        
        alerts = {
            -- Fetid Cloud
            cloudselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[91554]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[91554],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[91554],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
            
        },
        events = {
            -- Fetid Cloud
            {
                type = "combatevent",
                eventtype = "SPELL_PERIODIC_DAMAGE",
                spellname = 91554,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","cloudselfwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- Gossips
---------------------------------
do
    DXE:RegisterGossip("Love_EventActivation", "Begin the battle", "Crown Chemical Co. activation")
end
