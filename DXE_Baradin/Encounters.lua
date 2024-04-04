local L,SN,ST,SL = DXE.L,DXE.SN,DXE.ST,DXE.SL

---------------------------------
-- ARGALOTH
---------------------------------

do
	local data = {
		version = 4,
		key = "argaloth",
		zone = L.zone["Baradin Hold"],
		category = L.zone["Baradin Hold"],
		name = L.npc_baradin["Argaloth"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Argaloth.blp",
        triggers = {
			scan = {
				47120, -- Argaloth
			},
		},
		onactivate = {
			tracing = {
				47120, -- Argaloth
			},
            phasemarkers = {
                {
                    {0.66,"Firestorm","At 66 % of his health Argaloth will cast the first firestorm."},
                    {0.33,"Firestorm","At 33 % of his health Argaloth will cast the second firestorm."},
                },
            },
			tracerstart = true,
			combatstop = true,
            combatstart = true,
			defeat = {
				47120, -- Argaloth
			},
		},
		userdata = {
            meteortext = "",
        },
		onstart = {
            {
                "alert","consumingcd",
                "alert","enragecd",
            }
        },
        ordering = {
            alerts = {"enragecd","meteorcd","meteorwarn","consumingcd","firestormwarn","firestormdur"},
        },
        
        alerts = {
			enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time = 300,
                flashtime = 10,
                color1 = "RED",
                icon = ST[12317],
            },
            meteorcd = {
				varname = format(L.alert["%s CD"],SN[95172]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[95172]),
				time = 16.5,
				flashtime = 5,
				color1 = "LIGHTGREEN",
				icon = ST[95172],
			},
			meteorwarn = {
				varname = format(L.alert["%s Warning"],SN[95172]),
				type = "simple",
				text = "<meteortext>",
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				sound = "MINORWARNING",
				icon = ST[95172],
			},
            -- Fel Firestorm
            firestormwarn = {
				varname = format(L.alert["%s Warning"],SN[88972]),
				type = "simple",
				text = format(L.alert["%s"],SN[88972]),
				time = 3,
				sound = "BEWARE",
				color1 = "GOLD",
				throttle = 5,
				icon = ST[88972],
			},
			firestormdur = {
				varname = format(L.alert["%s Duration"],SN[88972]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[88972]),
				time = 18,
				flashtime = 5,
				color1 = "GREEN",
				icon = ST[88972],
                sound = "None",
			},
            consumingcd = {
                varname = format(L.alert["%s CD"],SN[88954]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[88954]),
				time = 22,
				flashtime = 5,
				color1 = "MAGENTA",
				icon = ST[88954],
                sound = "MINORWARNING",
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
                spellname = 95172,
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
        
    }

	DXE:RegisterEncounter(data)
end

---------------------------------
-- OCCU'THAR
---------------------------------

do
	local data = {
		version = 5,
		key = "occuthar",
		zone = L.zone["Baradin Hold"],
		category = L.zone["Baradin Hold"],
		name = L.npc_baradin["Occu'thar"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Occuthar.blp",
		triggers = {
			scan = {
				52363, -- Occu'thar
			},
		},
		onactivate = {
			tracing = {
				52363, -- Occu'thar
			},
			tracerstart = true,
            conbatstart = true,
			combatstop = true,
			defeat = {
				52363, -- Occu'thar
			},
		},
		userdata = {
            focusfirecd = 0,
            searingshadowstext = "",
            searingshadowssaytext = "",
        },
		onstart = {
			{
				"alert","enragecd",
                "alert",{"searingshadowscd", time = 2},
				"alert",{"focusfirecd", time = 2},
				"alert",{"eyescd", time = 2},
			},
		},

        announces = {
            searingshadowssay = {
                varname = "%s (multiple stacks)",
                type = "SAY",
                subtype = "spell",
                spell = 96913,
                msg = "<searingshadowssaytext>",
                throttle = true,
            },
            
        },
		filters = {
            bossemotes = {
                eyessummonemote = {
                    name = "Eyes of Occu'thar",
                    pattern = "begins to cast %[Eyes of",
                    hasIcon = true,
                    texture = ST[96920],
                },
            },
        },
        ordering = {
            alerts = {"enragecd","searingshadowscd","searingshadowswarn","searingshadowstankwarn",
                      "focusfirecd","focusfirewarn","focusfireselfwarn","eyescd","eyescast"},
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time = 300,
                flashtime = 10,
                color1 = "RED",
                icon = ST[12317],
            },
            -- Searing Shadows
			searingshadowscd = {
				varname = format(L.alert["%s CD"],SN[96913]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[96913]),
				time = 24, -- orig. 22
				time2 = 6, -- orig. 5
				flashtime = 5,
				color1 = "BLUE",
				icon = ST[96913],
			},
			searingshadowswarn = {
				varname = format(L.alert["%s Warning"],SN[96913]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[96913]),
				time = 2.5,
				flashtime = 2.5,
				color1 = "CYAN",
				sound = "ALERT1",
				icon = ST[96913],
			},
            searingshadowstankwarn = {
                varname = format(L.alert["%s Stacks Warning"],SN[96913]),
                type = "simple",
                text = "<searingshadowstext>",
                time = 1,
                stacks = 2,
                color1 = "LIGHTBLUE",
                sound = "ALERT10",
                icon = ST[96913],
            },
            -- Focused Fire
			focusfirecd = {
				varname = format(L.alert["%s CD"],SN[101004]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[101004]),
				time = "<focusfirecd>",
                time2 = 16,
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[101004],
                ---throttle = 10,
			},
			focusfirewarn = {
				varname = format(L.alert["%s Warning"],SN[101004]),
				type = "simple",
				text = format(L.alert["%s"],SN[101004]),
				time = 2.5,
				flashtime = 2.5,
				color1 = "MAGENTA",
				sound = "ALERT2",
				icon = ST[101004],
                --throttle = 10,
			},
            focusfireselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[101004]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[101004],L.alert["YOU"]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[101004],
                throttle = 2,
                emphasizewarning = true,
            },
            -- Eyes of Occu'thar
			eyescd = {
				varname = format(L.alert["%s CD"],SN[101006]),
				type = "dropdown",
				text = format(L.alert["New %s"],SN[101006]),
				time = 58, -- orig. 60,
				time2 = 23, -- orig. 30,
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[101006],
			},
			eyescast = {
				varname = format(L.alert["%s Warning"],SN[101006]),
                type = "centerpopup",
				text = format(L.alert["New: %s"],SN[101006]),
				time = 2,
				flashtime = 2,
				color1 = "YELLOW",
				sound = "ALERT2",
				icon = ST[101006],
			},
            
		},
		events = {
			-- Searing Shadows
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 96913,
				execute = {
					{
						"quash","searingshadowscd",
						"alert","searingshadowscd",
						"alert","searingshadowswarn",
					},
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 96913,
                execute = {
                    {
                        "expect",{"#11#",">=","&stacks|searingshadowstankwarn&"},
                        "invoke",{
                            {
                                "expect",{"#4#","==","&playerguid&"},
                                "set",{searingshadowstext = format(L.alert["%s (%s) on %s"],SN[96913],"#11#",L.alert["YOU"])},
                            },
                            {
                                "expect",{"#4#","~=","&playerguid&"},
                                "set",{searingshadowstext = format(L.alert["%s (%s) on <%s>"],SN[96913],"#11#","#5#")},
                            },
                        },
                        "set",{
                            searingshadowssaytext = format(L.alert["<DXE> %s has %s stacks of %s!"],"#5#","#11#",SL[96913]),
                        },
                        "announce","searingshadowssay",
                        "alert","searingshadowstankwarn",
                    },
                },
            },
            
			-- Focused Fire
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 96884,
				execute = {
                    {
						"alert","focusfirecd",
						"alert","focusfirewarn",
					},
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 96883,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","focusfireselfwarn",
                    },
                },
            },
			-- Eyes of Occu'thar
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 101006,
				execute = {
					{
						"set",{focusfirecd = {16.3, 26, 0, loop = false, type = "series"}},
						"quash","eyescd",
						"alert","eyescd",
						"alert","eyescast",
                        "alert","focusfirecd",
					},
				},
			},
        },
        
    }
	DXE:RegisterEncounter(data)
end

---------------------------------
-- ALIZABAL
---------------------------------

do
	local data = {
		version = 3,
		key = "Alizabal",
		zone = L.zone["Baradin Hold"],
		category = L.zone["Baradin Hold"],
		name = L.npc_baradin["Alizabal"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Alizabal.blp",
		triggers = {
			scan = {
				55869, -- Alizabal
			},
		},
		onactivate = {
			tracing = {
				55869, -- Alizabal
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				55869, -- Alizabal
			},
		},
		userdata = {
			skewertext = "",
            hatetext = "",
			justdanced = "yes",
            dancecount = 0,
            secondcd = {8.1, 8.46, loop = true, type = "series"},
		},
		onstart = {
			{
                "alert","enragecd",
				"alert",{"dancecd", time = 2, text = 2},
				"alert",{"firstcd",time = 2},
			}
		},
        arrows = {
            hatearrow = {
                varname = format("%s",SN[105067]),
                unit = "#5#",
                persist = 9,
                action = "TOWARD",
                msg = L.alert["Stack to split damage"],
                spell = SN[105067],
                sound = "None",
                rangeStay = 8,
                range1 = 10,
                range2 = 20,
                range3 = 30,
                texture = ST[105067],
            }
        },
        filters = {
            bossemotes = {
                skeweremote = {
                    name = "Skewer",
                    pattern = "Alizabal skewers",
                    hasIcon = false,
                    hide = true,
                    texture = ST[104936],
                },
            },
        },
        phrasecolors = {
            {"STACK ON OTHERS","YELLOW"},
            {"tick","YELLOW"}
        },
		windows = {
			proxwindow = true,
			proxrange = 25,
			proxoverride = true,
            nodistancecheck = true
		},
        radars = {
            hateradar = {
                varname = SN[105067],
                type = "circle",
                player = "#5#",
                range = 6,
                mode = "stack",
                count = 15,
                icon = SN[105067],
            },
        },
        ordering = {
            alerts = {"enragecd","firstcd","skewercd","skewerwarn","hatecd","hatewarn","hateselfwarn","hatetickcd","dancecd","dancedur"},
        },
        
		alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time = 300,
                flashtime = 60,
                color1 = "RED",
                sound = "MINORWARNING",
                icon = ST[12317],
            },
			firstcd = {
				varname = format(L.alert["%s/%s CD"],SN[104936],SN[105067]),
				type = "dropdown",
				text = format(L.alert["%s/%s CD"],SN[104936],SN[105067]),
				time = 8.2,
                time2 = 5.5,
				flashtime = 5,
				color1 = "RED",
                color2 = "GOLD",
				icon = ST[75000],
                sticky = true,
			},
            -- Skewer
			skewercd = {
				varname = format(L.alert["%s CD"],SN[104936]),
				type = "dropdown",
				text = format(L.alert["%s CD"],SN[104936]),
				time = 20.5,
				time2 = "<secondcd>",
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[104936],
			},
			skewerwarn = {
				varname = format(L.alert["%s Warning"],SN[104936]),
				type = "simple",
				text = "<skewertext>",
                text2 = format(L.alert["Next %s"],SN[104936]),
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[104936],
			},
            -- Seething Hate
			hatecd = {
				varname = format(L.alert["%s CD"],SN[105067]),
				type = "dropdown",
				text = format(L.alert["%s CD"],SN[105067]),
                text2 = format(L.alert["Next %s"],SN[105067]),
				time = 20.5,
				time2 = "<secondcd>",
				flashtime = 5,
				color1 = "RED",
				icon = ST[105067],
			},
			hatewarn = {
				varname = format(L.alert["%s Warning"],SN[105067]),
				type = "centerpopup",
				text = "<hatetext>",
				time = 9,
				flashtime = 3,
				color1 = "RED",
				icon = ST[105067],
			},
            hateselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[105067]),
                type = "centerpopup",
                warningtext = format(L.alert["%s on %s - STACK ON OTHERS!"],SN[105067],L.alert["YOU"]),
                text = format(L.alert["%s on %s"],SN[105067],L.alert["YOU"]),
                time = 9,
                color1 = "RED",
                sound = "ALERT10",
                icon = ST[105067],
                throttle = 2,
                flashscreen = true,
                emphasizewarning = true,
            },
            hatetickcd = {
                varname = format(L.alert["%s tick CD"],SN[105067]),
                type = "dropdown",
                text = format(L.alert["Next %s tick"],SN[105067]),
                time = 3,
                flashtime = 5,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[105067],
                emphasize = true,
            },
            -- Blade Dance
			dancecd = {
				varname = format(L.alert["%s CD"],SN[104995]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[104995]),
                text2 = format(L.alert["%s CD"],SN[104995]),
				time = 60,
				time2 = 25, --seen 27 to 30 to first
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[104995],
                sticky = true,
			},
			dancedur = {
				varname = format(L.alert["%s Duration"],SN[104995]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[104995]),
				time = 13.5,
				flashtime = 5,
				color1 = "ORANGE",
				sound = "ALERT12",
				icon = ST[104995],
			},
		},
		timers = {
            hateticktimer = {
                {
                    "set",{hatetickcounter = "INCR|1"},
                    "expect",{"<hatetickcounter>","<=","3"},
                    "quash","hatetickcd",
                    "alert","hatetickcd",
                    "canceltimer","hateticktimer",
                    "scheduletimer",{"hateticktimer", 3},
                },
            },
        },
        events = {
			-- Skewer on Tank
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 104936,
				execute = {
                    {
						"quash","skewercd",
						"set",{skewertext = format(L.alert["%s on <%s>"],SN[104936],"#5#")},
						"alert","skewerwarn",
					},
					{
						"expect",{"<justdanced>","==","yes"},
						"set",{justdanced = "no"},
                        "quash","firstcd",
						"alert",{"hatecd",time = 2, text = 2},
					},
					{
						"expect",{"&timeleft|dancecd&",">","21"},
                        "alert","skewercd",
					},
				},
			},
			-- Seething Hate
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 105067,
				execute = {
                    {
                        "quash","hatecd",
                        "radar","hateradar",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "arrow","hatearrow",
                        "set",{hatetext = format(L.alert["%s on <%s>"],SN[105067], "#5#")},
						"alert","hatewarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","hateselfwarn",
                        "alert","hatetickcd",
                        "set",{hatetickcounter = 1},
                        "scheduletimer",{"hateticktimer", 3},
                        "range",{true,18},
                    },
                    {
                        "expect",{"<justdanced>","==","yes"},
                        "set",{justdanced = "no"},
                        "quash","firstcd",
                        "alert",{"skewercd",time = 2, text = 2},
                    },
                    {
						"expect",{"&timeleft|dancecd&",">","21"},
                        "alert","hatecd",
					},
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 105067,
                execute = {
                    {
                        "removeradar",{"hateradar", player = "#5#"},
                        "range",{true},
                    },
                },
            },
            
			-- Blade Dance
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 105784,
                execute = {
                    {
                        "set",{dancecount = "INCR|1"},
                    },
                    {
                        "expect",{"<dancecount>","==","1"},
                        "batchquash",{"dancecd","skewercd","hatecd"},
                        "alert","dancecd",
						"alert","dancedur",
                        
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellid = 105784,
                execute = {
                    {
                        "expect",{"<dancecount>","==","3"},
                        "set",{
                            dancecount = 0,
                            justdanced = "yes",
                        },
                        "alert","firstcd",
                    },
                },
            },
            
		},
	}

	DXE:RegisterEncounter(data)
end
