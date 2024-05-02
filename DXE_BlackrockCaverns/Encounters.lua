local L,SN,ST,SL,AL,AT,AN,TI = DXE.L,DXE.SN,DXE.ST,DXE.SL,DXE.AL,DXE.AT,DXE.AN,DXE.TI
---------------------------------
-- ROM'OGG BONECRUSHER
---------------------------------

do
    local data = {
        version = 5,
        key = "romogg",
        zone = L.zone["Blackrock Caverns"],
        category = L.zone["Blackrock Caverns"],
        name = L.npc_blackrockcaverns["Rom'ogg Bonecrusher"], -- Bonecrusher
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Romogg Bonecrusher.blp",
        triggers = {
            scan = {
                39665, -- Rom'ogg Bonecrusher
            },
        },
        onactivate = {
            tracing = {39665},
            phasemarkers = {
                {
                    {0.66, "Chains of Woe","At 66% of his HP boss immobilizes all players with his chains."},
                    {0.33, "Chains of Woe","At 33% of his HP boss immobilizes all players with his chains."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39665,
        },
        userdata = {
            skullcrackertime = 12,
            firstchainswarned = "no",
            secondchainswarned = "no",
            
            -- Crushing Bones and Cracking Skulls (achievement)
            elementalscount = 0,
            achievementwarned = "no",
        },
        onstart = {
            {
                "alert","quakecd";
                "repeattimer",{"checkhp", 1},
                "expect",{"&difficulty&","==","2"}, --5h
                "set",{skullcrackertime = 8},
            },
            {
                "expect",{"&itemenabled|achievementcomplete&","==","true"},
                "counter","elementalscounter",
            },
        },
        
        announces = {
            achievementcomplete = {
                varname = "%s complete",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5281,
                msg = format(L.alert["<DXE> Requirements for %s were met. You can kill the boss now."],AL[5281]),
                throttle = true,
            },
        },
        raidicons = {
            chainsmark = {
                varname = format("%s {%s}","Chains of Woe","NPC_ENEMY"),
                type = "ENEMY",
                persist = 15,
                unit = "#1#",
                reset = 20,
                icon = 1,
                texture = ST[75539],
            },
        },
        filters = {
            bossemotes = {
                skullcrackeremote = {
                    name = SN[75543],
                    pattern = "prepares to unleash The Skullcracker",
                    hasIcon = false,
                    hide = true,
                    texture = ST[75543],
                },
            },
        },
        counters = {
            elementalscounter = {
                variable = "elementalscount",
                label = format("%s Angered Earth skullcracked", TI["AchievementShield"]),
                pattern = "%d / %d",
                value = 0,
                minimum = 0,
                maximum = 10,
                difficulty = 2,
            },
        },
        windows = {
            proxwindow = true,
            proxrange = 10,
            proxoverride = true,
        },
        ordering = {
            alerts = {"quakecd","quakewarn","chainssoonwarn","chainswarn","skullcrackerwarn"},
        },
        
        alerts = {
            -- Quake
            quakecd = {
                varname = format(L.alert["%s CD"],SN[75272]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[75272]),
                time = 26,
                time2 = 16,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[75272],
            },
            quakewarn = {
                varname = format(L.alert["%s Warning"],SN[75272]),
                type = "simple",
                text = format(L.alert["%s"],SN[75272]),
                time = 1,
                flashtime = 5,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[75272],
            },
            -- The Skullcracker
            skullcrackerwarn = {
                varname = format(L.alert["%s Warning"],SN[75543]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[75543]),
                time = "<skullcrackertime>",
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "RUNAWAY",
                icon = ST[75543],
                audiocd = true,
            },
            -- Chains of Woe
            chainssoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[75539]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[75539]),
                time = 1,
                flashtime = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[75539],
            },
            chainswarn = {
                varname = format(L.alert["%s Warning"],SN[75539]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[75539]),
                time = 2,
                color1 = "MAGENTA",
                sound = "ALERT1",
                icon = ST[75539],
            },
        },
        timers = {
            checkhp = {
				{
					"expect",{"&gethp|boss1&","<","70"},
                    "expect",{"<firstchainswarned>","==","no"},
                    "set",{firstchainswarned = "yes"},
					"alert","chainssoonwarn",
				},
                {
					"expect",{"&gethp|boss1&","<","40"},
                    "expect",{"<secondchainswarned>","==","no"},
                    "set",{secondchainswarned = "yes"},
					"alert","chainssoonwarn",
				},
                {
                    "expect",{"<firstchainswarned>","==","yes"},
                    "expect",{"<secondchainswarned>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
            removechains = {
                {
                    "closetemptracing",true,
                },
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
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- CORLA, HERALD OF TWILIGHT
---------------------------------

do
    local data = {
        version = 8,
        key = "corla",
        zone = L.zone["Blackrock Caverns"],
        category = L.zone["Blackrock Caverns"],
        name = L.npc_blackrockcaverns["Corla, Herald of Twilight"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Corla, Herald of Twilight.blp",
        triggers = {
            scan = {
                39679, -- Corla, Herald of Twilight
            },
        },
        onactivate = {
            tracing = {
                39679,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39679,
        },
        userdata = {
            darkcommandcd = {20, 25, loop = false, type = "series"},
            evolutionselfwarntext = "",
            zealotsevolvedcount = 0,
            zealotdeadcount = 0,
        },
        onstart = {
            {
                "alert","darkcommandcd",
            },
            {
                "expect",{"&itemenabled|achievementcomplete&","==","true"},
                "counter","zealotscounter",
            },
        },
        
        announces = {
            achievementcomplete = {
                varname = "%s complete",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5282,
                msg = format(L.alert["<DXE> Requirements for %s were met. You can kill the boss now."],AL[5282]),
                throttle = true,
            },
        },
        filters = {
            bossemotes = {
                zealotevolvedemote = {
                    name = "Twilight Zealot evolved",
                    pattern = "Twilight Zealot has evolved",
                    hasIcon = false,
                    hide = true,
                    texture = ST[75608],
                },
            },
        },
        counters = {
            zealotscounter = {
                variable = "zealotdeadcount",
                label = format("%s Evolved Twilight Zealots slain",TI["AchievementShield"]),
                pattern = "%d / %d",
                value = 0,
                minimum = 0,
                maximum = 3,
                difficulty = 2,
            },
        },
        phrasecolors = {
            {"evolved","WHITE"},
            {"Twilight Drakonid:","GOLD"},
            {"Evolved Twilight Drakonid","GOLD"},
        },
        ordering = {
            alerts = {"evolutionselfduration","evolutionselfwarn","darkcommandcd","darkcommandwarn","shadowstrikewarn","drakonidreleasedwarn","zealotreleasedwarn",},
        },
        
        alerts = {
            -- Dark Command
            darkcommandcd = {
                varname = format(L.alert["%s CD"],SN[75823]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[75823]),
                time = "<darkcommandcd>",
                flashtime = 5,
                color1 = "MAGENTA",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[75823],
            },
            darkcommandwarn = {
                varname = format(L.alert["%s Warning"],SN[75823]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[75823]),
                time = 2,
                color1 = "MAGENTA",
                sound = "ALERT2",
                icon = ST[75823],
            },
            -- Shadow Strike
            shadowstrikewarn = {
                varname = format(L.alert["%s Warning"],SN[66134]),
                type = "centerpopup",
                warningtext = format(L.alert["%s: %s - INTERRUPT!"],"Twilight Drakonid", SN[66134]),
                text = format(L.alert["%s - INTERRUPT!"], SN[66134]),
                time = 2,
                color1 = "MAGENTA",
                sound = "ALERT2",
                icon = ST[66134],
                tag = "#1#",
            },
            -- Evolution
            evolutionselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[75697]),
                type = "simple",
                text = "<evolutionselfwarntext>",
                time = 1,
                stacks = 80,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                sound = "ALERT10",
                icon = ST[75697],
                throttle = 2,
                emphasizewarning = true,
            },
            evolutionselfduration = {
                varname = format(L.alert["%s on me Duration"],SN[75697]),
                type = "centerpopup",
                text = "<evolutionselfwarntext>",
                time = 15,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                sound = "None",
                icon = ST[75697],
                behavior = "overwrite",
            },
            -- Achievement: Evolution @ Twilight Zealot == 100
            zealotreleasedwarn = {
                varname = format(L.alert["%s Twilight Zealot evolved Warning"],TI["AchievementShield"]),
                type = "simple",
                text = format(L.alert["Twilight Zealot evolved (%s)!"],"<zealotsevolvedcount>"),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT7",
                icon = ST[75608],
                tag = "#4#",
            },
            -- Evolution @ a player == 100
            drakonidreleasedwarn = {
                varname = L.alert["Twilight Drakonid release Warning"],
                type = "simple",
                text = L.alert["Evolved Twilight Drakonid released!"],
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT7",
                icon = ST[75608],
            },            
        },
        events = {
            -- Dark Command
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 75823,
				execute = {
					{
						"quash","darkcommandcd",
						"alert","darkcommandcd",
						"alert","darkcommandwarn",
					},
				},
			},
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[75823]},
                        "expect",{"#1#","find","boss"},
                        "quash","darkcommandwarn",
                    },
                }
            },
            -- Evolution
            {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 75697,
				execute = {
					{
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{evolutionselfwarntext = format("%s (%s) on %s!",SN[75697],"#11#",L.alert["YOU"])},
                        "alert","evolutionselfduration",
                        "expect",{"#11#",">=","&stacks|evolutionselfwarn&"},
                        "alert","evolutionselfwarn",
					},
				},
			},
            -- Evolution @ Twilight Zealot == 100
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 75608,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","50284"},
                        "expect",{"&npcid|#4#&","==","50284"},
                        "set",{zealotsevolvedcount = "INCR|1"},
                        "schedulealert",{"zealotreleasedwarn", 0},
                    },
                },
            },
            -- Evolution @ a player == 100
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 75817,
                execute = {
                    {
                        "expect",{"#5#","==","Twilight Drakonid"},
                        "alert","drakonidreleasedwarn",
                    },
                },
            },
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 66134,
				execute = {
					{
						"alert","shadowstrikewarn",
					},
				},
			},
            -- Evolved Twilight Zealot death
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","50284"},
                        "expect",{"<zealotsevolvedcount>",">","<zealotdeadcount>"},
                        "set",{zealotdeadcount = "INCR|1"},
                        "expect",{"<zealotsevolvedcount>",">=","3"},
                        "expect",{"<zealotdeadcount>",">=","3"},
                        "announce","achievementcomplete",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","50125"},
                        "quash",{"shadowstrikewarn","#4#"},
                        
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[66134]},
                        "expect",{"&unitisplayertype|#1#&","==","false"},
                        "quash",{"shadowstrikewarn","&unitguid|#1#&"},
                        
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- KARSH STEELBENDER
---------------------------------

do
    local data = {
        version = 3,
        key = "karsh",
        zone = L.zone["Blackrock Caverns"],
        category = L.zone["Blackrock Caverns"],
        name = L.npc_blackrockcaverns["Karsh Steelbender"],
        icon = {"Interface\\EncounterJournal\\UI-EJ-BOSS-Karsh Steelbender.blp",true},
        triggers = {
            scan = {
                39698, -- Karsh Steelbender
            },
        },
        onactivate = {
            tracing = {
                39698,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39698,
        },
        userdata = {
            armortext = "",
            armorwarntext = "",
            armormet = "no",
            superheatedcount = 0,
        },
        onstart = {
            {
                "expect",{"&itemenabled|achievementcomplete&","==","true"},
                "counter","superheatedcounter",
            },
        },
        
        announces = {
            achievementcomplete = {
                varname = "%s complete",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5283,
                msg = format(L.alert["<DXE> Requirements for %s were met. Kill the boss before %s falls off!"],AL[5283],SL[75846]),
                throttle = true,
            },
            achievementfailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5283,
                msg = format(L.alert["<DXE> %s: Achievement failed. Try stacking the boss again!"],AL[5283]),
                throttle = true,
            },
        },
        counters = {
            superheatedcounter = {
                variable = "superheatedcount",
                label = format("%s Superheated Quicksilver Armor", TI["AchievementShield"]),
                pattern = "%d / %d",
                value = 0,
                minimum = 0,
                maximum = 15,
                difficulty = 2,
            },
        },
        filters = {
            bossemotes = {
                superheatedemote = {
                    name = SN[75846],
                    pattern = "armor shimmers with heat",
                    hasIcon = false,
                    hide = true,
                    texture = ST[75846],
                },
            },
        },
        ordering = {
            alerts = {"superheatedwarn","superheatedduration","quicksilverarmorwarn","achievementduration"},
        },
        
        alerts = {
            -- Superheated Quicksilver Armor
            superheatedduration = {
                varname = format(L.alert["%s Duration"],SN[75846]),
                type = "dropdown",
                text = "<armortext>",
                time = 17,
                flashtime = 10,
                color1 = "RED",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[75846],
                audiocd = true,
            },
            superheatedwarn = {
                varname = format(L.alert["%s Warning"],SN[75846]),
                type = "simple",
                text = "<armorwarntext>",
                time = 1,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[75846],
            },
            -- Achievement: Too Hot to Handle
            achievementduration = {
                varname = format(L.alert["%s %s Duration"],TI["AchievementShield"],"Too Hot to Handle"),
                type = "dropdown",
                text = "Too Hot to Handle window",
                time = 17,
                flashtime = 10,
                color1 = "GOLD",
                icon = AT[5283],
                audiocd = true,
            },
            -- Quicksilver Armor
            quicksilverarmorwarn = {
                varname = format(L.alert["%s Warning"],SN[75842]),
                type = "simple",
                text = format(L.alert["%s"],SN[75842]),
                time = 17,
                flashtime = 10,
                color1 = "WHITE",
                sound = "ALERT5",
                icon = ST[75842],
            },
        },
        timers = {
            quicksilverarmortimer = {
                {
                    "alert","quicksilverarmorwarn",
                    "expect",{"<armormet>","==","yes"},
                    "expect",{"&difficulty&","==","2"},
                    "announce","achievementfailed",
                    "set",{armormet = "no"},
                },
            },
        },
        events = {
            -- Superheated Quicksilver Armor (first stack)
            {
				type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
				spellname = 75846,
				execute = {
					{
                        "set",{
                            armortext = format(L.alert["%s (%d)"],"Superheated Armor",1),
                            armorwarntext = format(L.alert["%s (%s)"],SN[75846],1),
                            superheatedcount = 1,
                        },
                        
						"quash","superheatedduration",
						"alert","superheatedduration",
                        "alert","superheatedwarn",
					},
				},
			},
            -- Superheated Quicksilver Armor (other stacks)
            {
				type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 75846,
				execute = {
					{
                        "set",{
                            armortext = format(L.alert["%s (%s)"],"Superheated Armor","#11#"),
                            armorwarntext = format(L.alert["%s (%s)"],SN[75846],"#11#"),
                            superheatedcount = "#11#",
                        },
						"quash","superheatedduration",
						"alert","superheatedduration",
                        "alert","superheatedwarn",
                    },
                    {
                        "expect",{"&difficulty&","==","2"},
                        "invoke",{
                            {
                                "expect",{"#11#","==","15"},
                                "announce","achievementcomplete",
                                "set",{armormet = "yes"},
                            },
                            {
                                "expect",{"#11#",">=","15"},
                                "quash","achievementduration",
                                "alert","achievementduration",
                            },
                        },
                    },
				},
			}, 
            -- Quicksilver Armor
            {
				type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
				spellname = 75842,
				execute = {
					{
                        "set",{superheatedcount = 0},
						"scheduletimer",{"quicksilverarmortimer", 0.1},
					},
				},
			},            
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- BEAUTY
---------------------------------

do
    local data = {
        version = 2,
        key = "beauty",
        zone = L.zone["Blackrock Caverns"],
        category = L.zone["Blackrock Caverns"],
        name = L.npc_blackrockcaverns["Beauty"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Beauty.blp",
        triggers = {
            scan = {
                39700, -- Beauty
            },
        },
        onactivate = {
            tracing = {
                39700,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39700,
        },
        userdata = {
            chargetext = "",
        },
        onstart = {
            {
                "alert","chargecd",
                "alert","flamebreakcd",
                "alert","roarcd",
            },
        },
        phrasecolors = {
            {"Beauty","GOLD"},
        },
        ordering = {
            alerts = {"chargecd","chargewarn","flamebreakcd","flamebreakwarn","roarcd","roarwarn","lavaselfwarn","spitcd","spitwarn"},
        },
        
        alerts = {
            -- Berserker Charge
            chargecd = {
                varname = format(L.alert["%s CD"],SN[93580]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[93580]),
                time = 14,
                flashtime = 5,
                color1 = "RED",
                color2 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[93580],
            },
            chargewarn = {
                varname = format(L.alert["%s Warning"],SN[93580]),
                type = "simple",
                text = "<chargetext>",
                time = 1,
                color1 = "WHITE",
                sound = "ALERT7",
                icon = ST[93580],
            },
            -- Flamebreak
            flamebreakcd = {
                varname = format(L.alert["%s CD"],SN[93583]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[93583]),
                time = 20,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[93583],
                behavior = "overwrite",
            },
            flamebreakwarn = {
                varname = format(L.alert["%s Warning"],SN[93583]),
                type = "simple",
                text = format(L.alert["%s"],SN[93583]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[93583],
                throttle = 1,
            },
            -- Terrifying Roar
            roarcd = {
                varname = format(L.alert["%s CD"],SN[93586]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[93586]),
                time = 30,
                flashtime = 5,
                color1 = "TAN",
                color2 = "PINK",
                sound = "MINORWARNING",
                icon = ST[93586],
            },
            roarwarn = {
                varname = format(L.alert["%s Warning"],SN[93586]),
                type = "simple",
                text = format(L.alert["%s"],SN[93586]),
                time = 1,
                color1 = "TAN",
                sound = "ALERT8",
                icon = ST[93586],
            },
            -- Lava Drool
            lavaselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[93666]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[93666],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[93666],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
            -- Magma Spit
            spitcd = {
                varname = format(L.alert["%s CD"],SN[76031]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[76031]),
                time = 10,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[76031],
            },
            spitwarn = {
                varname = format(L.alert["%s Warning"],SN[76031]),
                type = "simple",
                text = format(L.alert["%s"],SN[76031]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[76031],
            },
        },
        events = {
			-- Berserker Charge
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 93580,
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
                spellname = 76031,
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
                spellname = 93586,
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
                spellname = 93666,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","lavaselfwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end


---------------------------------
-- ASCENDANT LORD OBSIDIUS
---------------------------------

do
    local data = {
        version = 5,
        key = "ascendantlordobsidius",
        zone = L.zone["Blackrock Caverns"],
        category = L.zone["Blackrock Caverns"],
        name = L.npc_blackrockcaverns["Ascendant Lord Obsidius"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Ascendant Lord Obsidius.blp",
        triggers = {
            scan = {
                39705, -- Ascendant Lord Obsidius
            },
        },
        onactivate = {
            tracing = {
                39705,
            },
            phasemarkers = {
                {
                    {0.69, SN[76274],"At 69% of his HP boss transforms into a random Shadow of Obsidius."},
                    {0.34, SN[76274],"At 34% of his HP boss transforms into a random Shadow of Obsidius."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39705,
        },
        userdata = {
            firstjumpwarned = "no",
            secondjumpwarned = "no",
            achievementfailer = "",
            achievementfailed = "no",
        },
        onstart = {
            {
                "repeattimer",{"checkhp",1},
            },
            {
                "expect",{"&difficulty&","==","2"},
                "alert","thunderclapcd",
            },
        },
        
        announces = {
            achievementfailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5284,
                msg = format(L.alert["<DXE> %s: Achievement failed - %s has reached 4 stacks of %s!"],AL[5284],"<achievementfailer>",SL[76189]),
                throttle = true,
            },
        },
        filters = {
            bossemotes = {
                teleportemote = {
                    name = SN[76274],
                    pattern = "prepares to trade places with one",
                    hasIcon = false,
                    hide = true,
                    texture = ST[76274],
                },
            },
        },
        phrasecolors = {
            {"Ascendant Lord Obsidius","GOLD"},
        },       
        ordering = {
            alerts = {"thunderclapcd","thunderclapwarn","jumpsoonwarn","switchwarn"},
        },
        
        alerts = {
            -- Thunderclap
            thunderclapcd = {
                varname = format(L.alert["%s CD"],SN[76186]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[76186]),
                time = 7,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[76186],
            },
            thunderclapwarn = {
                varname = format(L.alert["%s Warning"],SN[76186]),
                type = "simple",
                text = format(L.alert["%s"],SN[76186]),
                time = 1,
                color1 = "LIGHTBLUE",
                sound = "ALERT8",
                icon = ST[76186],
            },
            -- Teleport soon
            jumpsoonwarn = {
                varname = format(L.alert["%s soon Warning"],"Teleport"),
                type = "simple",
                text = format(L.alert["%s soon ..."],"Teleport"),
                time = 1,
                flashtime = 1,
                color1 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            -- Transformation
            switchwarn = {
                varname = format(L.alert["%s Warning"],SN[76274]),
                type = "simple",
                text = format(L.alert["%s %s"],"Ascendant Lord Obsidius","Teleported"),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT2",
                icon = ST[76242],
            },
        },
        timers = {
            checkhp = {
				{
					"expect",{"&gethp|boss1&","<","75"},
                    "expect",{"<firstjumpwarned>","==","no"},
                    "set",{firstjumpwarned = "yes"},
					"alert","jumpsoonwarn",
				},
                {
					"expect",{"&gethp|boss1&","<","40"},
                    "expect",{"<secondjumpwarned>","==","no"},
                    "set",{secondjumpwarned = "yes"},
					"alert","jumpsoonwarn",
				},
                {
                    "expect",{"<firstjumpwarned>","==","yes"},
                    "expect",{"<secondjumpwarned>","==","yes"},
                    "canceltimer","checkhp",
                },
            }
        },
        events = {
            -- Transformation (Teleport)
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_blackrockcaverns["^Earth"]},
                        "alert","switchwarn",
                    },
                },
            }, 
            -- Thunderclap
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 76186,
                execute = {
                    {
                        "quash","thunderclapcd",
                        "alert","thunderclapcd",
                        "alert","thunderclapwarn",
                    },
                },
            },
            -- Crepscular Veil
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 76189,
                dstisplayertype = true,
                execute = {
                    {
                        "expect",{"&difficulty&","==","2"},
                        "expect",{"#11#","==","4"},
                        "expect",{"<achievementfailed>","==","no"},
                        "set",{achievementfailed = "yes"},
                        "set",{achievementfailer = "#5#"},
                        "announce","achievementfailed",
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
        key = "blackrockcavernstrash",
        zone = L.zone["Blackrock Caverns"],
        category = L.zone["Blackrock Caverns"],
        name = "Trash",
        triggers = {
            scan = {
                39978, -- Twilight Torturer *
                39985, -- Mad Prisoner
                39980, -- Twilight Sadist
                39982, -- Crazed Mage
                
                40021, -- Incediary Spark *
                40019, -- Twilight Obsidian Borer
                40017, -- Twilight Element Warden
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {
            shacklestext = "",
        },
        
        raidicons = {
            shacklesmark = {
                varname = format("%s {%s}",SN[93671],"PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 8,
                unit = "#5#",
                reset = 9,
                icon = 4,
                total = 2,
                texture = ST[93671],
            },
            volleymark = {
                varname = format("%s {%s-%s}",SN[93642],"ENEMY_CAST","Incediary Spark's"),
                type = "MULTIFRIENDLY",
                persist = 60,
                unit = "#1#",
                reset = 58,
                icon = 1,
                texture = ST[93642],
            },
        },
        ordering = {
            alerts = {"shackleswarn","volleycd"},
        },
        
        alerts = {
            -- Shackles
            shackleswarn = {
                varname = format(L.alert["%s Warning"],SN[93671]),
                type = "simple",
                text = "<shacklestext>",
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT10",
                icon = ST[93671],
            },
            -- Final Volley
            volleycd = {
                varname = format(L.alert["%s CD"],SN[93642]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[93642]),
                time = 7,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[93642],
                tag = "#1#",
            },
            
        },
        events = {
            -- Shackles
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 93671,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{shacklestext = format(L.alert["%s on %s - DISPEL!"],SN[93671],L.alert["YOU"])},
                        "alert","shackleswarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{shacklestext = format(L.alert["%s on <%s> - DISPEL!"],SN[93671],"#5#")},
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
                spellname = 93671,
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
                spellname = 93642,
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
    }

    DXE:RegisterEncounter(data)
end
