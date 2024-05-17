local L,SN,ST = DXE.L,DXE.SN,DXE.ST

------------------------
-- SHANNOX
------------------------
do
	local data = {
		version = 13,
		key = "Shannox",
		zone = L.zone["Firelands"],
		category = L.zone["Firelands"],
		name = L.npc_firelands["Shannox"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Shannox.blp",
        icon2 = "Interface\\EncounterJournal\\UI-EJ-BOSS-Rageface.blp",
		triggers = {
			scan = {
				53691, -- Shannox
			},
			yell = L.chat_firelands["A-hah! The interlopers"],
		},
		onactivate = {
			tracing = {
				53691, -- Shannox
				53694, -- Riplimb
				53695, -- Rageface
			},
			tracerstart = true,
			combatstop = true,
			defeat = 53691,
		},
		userdata = {
            -- Timers
            throwcrystaltrapcd = 25,
            spearcd = {20,42, loop = false, type = "series"},
			magmacd = 15,
            
            -- Texts
            jaggedtext = "",
			crystaltraptext = "",
			throwcrystaltraptext = "",
            throwimmotraptext = "",
            teartext = "",
		},
		onstart = {
			{
                "alert","enragecd",
				"alert","spearcd",
				"alert","throwcrystaltrapcd",
                "alert","throwimmotrapcd",
                "alert",{"faceragecd",time = 2},
			},
		},
		
        arrows = {
			crystaltraparrow = {
				varname = format(L.npc_firelands["Crystal Prison"]),
				unit = "#5#",
				persist = 30,
				action = "TOWARD",
				msg = L.alert[L.announce_firelands["Free him!"]],
				spell = SN[98159],
				sound = "ALERT5",
                texture = ST[99837],
			},
            faceragearrow = {
                varname = format("%s",SN[99947]),
                unit = "#5#",
                persist = 30,
                action = "TOWARD",
                msg = L.alert[L.announce_firelands["Help him!"]],
                spell = SN[99947],
                sound = "None",
                range1 = 15,
                range2 = 20,
                range3 = 30,
            }
		},
		announces = {
			immotrapsay = {
				type = "SAY",
                subtype = "self",
                spell = 13795,
				-- msg = format(L.alert["{circle} %s on ME! {circle}"],"Immolation Trap"),
                msg = format(L.alert[L.announce_firelands["{circle} %s on ME! {circle}"]],SN[99839]),
			},
			crystaltrapsay = {
				type = "SAY",
                subtype = "self",
                spell = "Crystal Prison Trap",
                icon = ST[99837],
				-- msg = format(L.alert["{square} %s on ME! {square}"],"Crystal Prison Trap"),
                msg = format(L.alert[L.announce_firelands["{square} %s on ME! {square}"]],SN[99836]),
			},
		},
		raidicons = {
			crystaltrapmark = {
                varname = format("%s {%s}",SN[99836],"ABILITY_TARGET_HARM"),
				type = "FRIENDLY",
				persist = 30,
				reset = 29,
				unit = "#5#",
				icon = 2,
                texture = ST[99836],
			},
			faceragemark = {
                varname = format("%s {%s}",SN[99947],"ABILITY_TARGET_HARM"),
				type = "FRIENDLY",
				persist = 15,
				reset = 2,
				unit = "#5#",
				icon = 1,
                texture = ST[99947],
			},
            ragemark = {
                varname = format("%s {%s}",SN[100415],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 15,
                unit = "#5#",
                reset = 15,
                icon = 3,
                texture = ST[100415],
            },
		},
		filters = {
            bossemotes = {
                enrageemote = {
                    name = "Shannox enrages",
                    pattern = "becomes enraged at seeing one of his",
                    hasIcon = false,
                    texture = ST[8599],
                },
                riplimbdeademote = {
                    name = "Riplimb dies",
                    pattern = "Riplimb collapses into a smouldering",
                    hasIcon = false,
                    texture = ST[38601],
                },
            },
        },
        radars = {
            crystaltrapradar = {
                varname = SN[99836],
                type = "circle",
                player = "#5#",
                fixed = true,
                range = 3,
                mode = "avoid",
                color = "CYAN",
                persist = 15,
                icon = ST[99837],
            },
        },
        windows = {
			proxwindow = true,
			proxrange = 15,
			proxoverride = true,
            nodistancecheck = true,
		},        
        grouping = {
            {
                general = true,
                alerts = {"enragecd"},
            },
            {
                name = format("|cffffd700%s|r","Shannox"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Shannox",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"tearduration","tearwarn","spearcd","spearwarn","magmacd","magmawarn"},
            },
            {
                name = format("|cffffd700%s|r","Traps"),
                icon = "Interface\\ICONS\\Ability_Hunter_TrapLauncher",
                alerts = {"throwcrystaltrapcd","throwcrystaltrapwarn","throwcrystaltrapselfwarn","crystaltrapwarn","cattrappedduration","throwimmotrapcd","throwimmotrapselfwarn"},
            },
            {
                name = format("|cffffd700%s|r","Hounds"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Riplimb",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"faceragecd","faceragewarn","faceragedur","rageselfduration","separationAnxietywarn","riplimbcd"},
            },
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                -- text = L.alert["Berserk"],
                text = format(L.alert["%s"], SN[12317]),
                time = 600,
                flashtime = 30,
                color1 = "RED",
                icon = ST[12317],
            },
            ---------------------------
            ---------- TRAPS ----------
            ---------------------------
            -- Throw Crystal Prison Trap
            throwcrystaltrapcd = {
				varname = format(L.alert["%s CD"],SN[99836]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[99836]),
				time = "<throwcrystaltrapcd>",
				flashtime = 5,
				color1 = "TURQUOISE",
				icon = ST[99837],
			},
            throwcrystaltrapwarn = {
                varname = format(L.alert["%s Warning"],SN[99836]),
                type = "simple",
                text = "<throwcrystaltraptext>",
                time = 1,
                color1 = "TAN",
                sound = "MINORWARNING",
                icon = ST[99837],
            },
            throwcrystaltrapselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[99836]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[99836],L.alert["YOU"]),
                time = 1,
                color1 = "YELLOW",
                sound = "RUNAWAY",
                icon = ST[99837],
                emphasizewarning = true,
            },
            -- Crystal Prison Trap
			crystaltrapwarn = {
				varname = format(L.alert["%s Warning"],"Crystal Trap"),
				type = "simple",
				text = "<crystaltraptext>",
				time = 5,
				flashtime = 5,
				color1 = "CYAN",
				sound = "ALERT3",
				icon = ST[99837],
			},
            -- Throw Immolation Trap
            throwimmotrapcd = {
                varname = format(L.alert["%s CD"],SN[99839]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[99839]),
                time = 40, --15
                flashtime = 5,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[51740],
            },
            throwimmotrapselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[99839]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[99839],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[51740],
                emphasizewarning = true,
            },
            cattrappedduration = {
                varname = format(L.alert["%s Duration"],"Trapped Cat"),
                type = "centerpopup",
                text = "<cattrappedtext>",
                time = 10,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[101216],
            },
            ---------------------------
            ---------- CATS ----------
            ---------------------------
            -- Face Rage
            faceragecd = {
                varname = format(L.alert["%s CD"],SN[99947]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[99947]),
                time = 30,
                time2 = 10,
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "GREEN",
                sound = "MINORWARNING",
                icon = ST[99947],
            },
            faceragewarn = {
                varname = format(L.alert["%s Warning"],SN[99947]),
                type = "simple",
                text = format(L.alert["%s on <%s>"],SN[99947],"#5#"),
                time = 1,
                color1 = "YELLOW",
                color2 = "RED",
                sound = "ALERT5",
                icon = ST[99947],
            },
            faceragedur = {
				varname = format(L.alert["%s Duration"],SN[99947]),
				type = "centerpopup",
				text = format(L.alert["%s on <%s>"],SN[99947],"#5#"),
				time = 30,
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[99947],
                sound = "None",
			},
            -- Rage
            rageselfduration = {
                varname = format(L.alert["%s Duration"],SN[100415]),
                type = "centerpopup",
                text = format(L.alert["%s on %s"],SN[100415],L.alert["YOU"]),
                time = 15,
                color1 = "RED",
                sound = "None",
                icon = ST[100415],
            },
            -- Separation Anxiety
			separationAnxietywarn = {
				varname = format(L.alert["%s Warning"],SN[99835]),
				type = "simple",
				text = format(L.alert["%s Warning"],SN[99835]),
				time = 5,
				color1 = "RED",
				icon = ST[99835],
                sound = "BEWARE",
				throttle = 5,
			},
            -- Riplimb reanimates (heroic)
			riplimbcd = {
				varname = format(L.alert["%s Resurrection Cooldown"],L.npc_firelands["Riplimb"]),
				type = "dropdown",
				text = format(L.alert["%s Resurrection"],L.npc_firelands["Riplimb"]),
				time = 30,
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[38601],
				sound = "ALERT9",
			},
            -- Hurl Spear
			spearcd = {
				varname = format(L.alert["%s CD"],SN[100002]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100002]),
				time = "<spearcd>",
				flashtime = 5,
				color1 = "PEACH",
                color2 = "RED",
                sound = "MINORWARNING",
				icon = ST[71466],
			},
			spearwarn = {
				varname = format(L.alert["%s Warning"],SN[100002]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[100002]),
				time = 2,
				color1 = "YELLOW",
				sound = "ALERT1",
				icon = ST[71466],
			},
            -- Magma Rupture
			magmacd = {
				varname = format(L.alert["%s CD"],SN[99840]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[99840]),
				time = "<magmacd>",
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[99840],
			},
			magmawarn = {
				varname = format(L.alert["%s Warning"],SN[99840]),
				type = "simple",
				text = format(L.alert["%s"],SN[99840]),
				time = 3,
				flashtime = 3,
				color1 = "ORANGE",
				sound = "ALERT8",
				icon = ST[99840],
			},
            -- Jagged Tear
            tearduration = {
                varname = format(L.alert["%s Duration"],SN[101219]),
                type = "dropdown",
                text = "<teartext>",
                time = 30,
                flashtime = 5,
                color1 = "RED",
                color2 = "YELLOW",
                sound = "None",
                icon = ST[101219],
            },
            tearwarn = {
                varname = format(L.alert["%s Warning"],SN[101219]),
                type = "simple",
                text = "<teartext>",
                time = 1,
                color1 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[101219],
            },
		},
		events = {
            -----------
            -- TRAPS --
            -----------
            -- Throw Immolation Trap
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 99839,
                execute = {
                    {
                        "alert","throwimmotrapcd",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","throwimmotrapselfwarn",
                        "announce","immotrapsay",
                    },
                },
            },
            -- Throw Crystal Prison Trap
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 99836,
                execute = {
                    {
                        "quash","throwcrystaltrapcd",
						"alert","throwcrystaltrapcd",
                        "radar","crystaltrapradar",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{throwcrystaltraptext = format(L.alert["%s on <%s>"],SN[99836],"#5#")},
                        "alert","throwcrystaltrapwarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","throwcrystaltrapselfwarn",
                        "announce","crystaltrapsay",
                    },
                },
            },
            -- This may not work
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_FAILED",
                spellname = 99836,
                execute = {
                    {
                        "quash","throwcrystaltrapcd",
						"alert","throwcrystaltrapcd",
                        "radar","crystaltrapradar",
                    },
                    {
                        "set",{throwcrystaltraptext = format(L.alert["%s CAST FAILED"],SN[99836])},
                        "alert","throwcrystaltrapwarn",
                    },
                },
            },
			-- Crystal Prison Trap
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 99837,
				dstisplayertype = true,
				execute = {
					{
						"raidicon","crystaltrapmark",
						"arrow","crystaltraparrow",
                        "removeradar",{"crystaltrapradar", atplayer = "#5#", range  = 3.2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{crystaltraptext = format(L.alert["%s on <%s>"],"Crystal Prison","#5#")},
						"alert","crystaltrapwarn",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
                        "set",{crystaltraptext = format(L.alert["%s on %s"],"Crystal Prison",L.alert["YOU"])},
                        "alert","crystaltrapwarn",
					},
				},
			},
			-- Crystal Prison Trap (removed)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 99837,
				dstisplayertype = true,
				execute = {
					{
						"removeraidicon","#5#",
						"removearrow","#5#",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","crystaltrapwarn",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","crystaltrapwarn",
					},
				},
			},
            -- Cat trapped
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 99837,
                dstisnpctype = true,
                execute = {
                    {
                        "set",{cattrappedtext = format("%s is trapped","#5#")},
                        "alert","cattrappedduration",
                    },
                    {
                        "expect",{"#5#","==","Rageface"},
                        "expect",{"&timeleft|faceragecd&","<","10"},
                        "schedulealert",{"faceragecd", "&timeleft|faceragecd&"},
                        "quash","faceragecd",
                    },
                },
            },
            
			-- Face Rage
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 99945,
                srcisnpctype = true,
                execute = {
                    {
                        "quash","faceragecd",
                        "alert","faceragecd",
                    },
                },
            },
            
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 99947,
				dstisplayertype = true,
				execute = {
					{
						"raidicon","faceragemark",
						"alert","faceragedur",
                        "alert","faceragewarn",
                        "arrow","faceragearrow",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 99947,
				execute = {
					{
						"removeraidicon","#5#",
                        "removearrow","#5#",
						"quash","faceragedur",
					},
				},
			},
            -- Rage
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 100415,
                execute = {
                    {
                        "raidicon","ragemark",
                        "expect",{"#4#","==","&playerguid&"},
                        "quash","rageselfduration",
                        "alert","rageselfduration",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REFRESH",
                spellid = 100415,
                execute = {
                    {
                        "raidicon","ragemark",
                        "expect",{"#4#","==","&playerguid&"},
                        "quash","rageselfduration",
                        "alert","rageselfduration",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellid = 100415,
                execute = {
                    {
                        "quash","rageselfduration",
                        "removeraidicon","#5#",
                    },
                },
            },
			-- Hurl Spear
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 100002,
				execute = {
					{
						"quash","spearcd",
						"alert","spearwarn",
						"alert","spearcd",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
                    -- Riplimb dies
					{
						"expect",{"&npcid|#4#&","==","53694"},
                        "expect",{"&difficulty&",">=","3"}, --10h&25h
						"quash","spearcd",
						"alert","riplimbcd",
					},
                    -- Rageface dies
                    {
                        "expect",{"&npcid|#4#&","==","53695"},
                        "quash","faceragecd",
                    },
				},
			},
            -- Magma Rupture
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 99840,
				execute = {
					{
						"quash","spearcd",
						"alert","magmacd",
						"alert","magmawarn",
					},
				},
			},
			-- Separation Anxiety
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 99835,
				dstnpcid = 53691, -- Shannox
				execute = {
					{
						"alert","separationAnxietywarn",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 99835,
				dstnpcid = 53691, -- Shannox
				execute = {
					{
						"quash","separationAnxietywarn",
					},
				},
			},
            -- Jagged Tear
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 101219,
                execute = {
                    {
                        "quash","tearduration",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{teartext = format("%s (%s) on <%s>",SN[101219],"1","#5#")},
                        "alert","tearduration",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{teartext = format("%s (%s) on %s",SN[101219],"1",L.alert["YOU"])},
                        "alert","tearduration",
                    },
                    {
                        "alert","tearwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 101219,
                execute = {
                    {
                        "quash","tearduration",
                    },
                                        {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{teartext = format("%s (%s) on <%s>",SN[101219],"#11#","#5#")},
                        "alert","tearduration",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{teartext = format("%s (%s) on %s",SN[101219],"#11#",L.alert["YOU"])},
                        "alert","tearduration",
                    },
                                        {
                        "alert","tearwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 101219,
                execute = {
                    {
                        "quash","tearduration",
                    },
                },
            },
		},
        
    }

	DXE:RegisterEncounter(data)
end


------------------------
-- BETH'TILAC
------------------------
do
	local data = {
		version = 15,
		key = "Beth'tilac",
		zone = L.zone["Firelands"],
		category = L.zone["Firelands"],
		name = L.npc_firelands["Beth'tilac"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Bethtilac The Red Widow.blp",
		triggers = {
			scan = {
				52498, -- Beth'tilac
			},
		},
		onactivate = {
			tracing = {52498,powers={true}}, -- Beth'tilac
			tracerstart = true,
			combatstop = true,
			defeat = 52498,
		},
		userdata = {
            -- Timers
            spinnerscd = {9, 10, 10, 0, loop = true, type = "series"},
			spiderlingscd = {10,30, loop = false, type = "series"},
			dronescd = {45,60, loop = false, type = "series"},
            kisscd = {35.5, 32, loop = false, type = "series"},
            
            -- Texts
            kisstext = "",
			fixatetext = "",
            
            -- Counter
			devastationcount = 0,
			phase = 0,
            
            -- Switches
            devastationwarned = "no",
		},
		onstart = {
			{
				"scheduletimer",{"energy",15},
				"set",{phase = 1},
				"batchalert",{"spinnerscd","dronescd","spiderlingscd","devastationcd"},
				"scheduletimer",{"dronestimer",45},
			},
		},
		
        announces = {
			fixatesay = {
				type = "SAY",
                subtype = "self",
                spell = 99559,
				msg = format(L.alert["%s on ME!"],SN[99559]).."!",
			},
		},
		raidicons = {
			fixateicon = {
                varname = format("%s {%s}",SN[99559],"PLAYER_DEBUFF"),
				type = "FRIENDLY",
				persist = 10, --???
				reset = 9,
				unit = "#5#",
				icon = 1,
                texture = ST[99559],
			},
		},
		filters = {
            bossemotes = {
                spinnersemote = {
                    name = "Cinderweb Spinners",
                    pattern = "dangle from above",
                    hasIcon = false,
                    texture = ST[97503],
                    hide = true,
                },
                spiderlingsemote = {
                    name = "Cinderweb Spiderlings",
                    pattern = "have been roused from their",
                    hasIcon = false,
                    texture = ST[87084],
                    hide = true,
                },
                devastationemote = {
                    name = "Smoldering Devastation",
                    pattern = "smoldering body begins to",
                    hasIcon = false,
                    texture = ST[99052],
                    hide = true,
                },
            },
        },
        radars = {
            kissradar = {
                varname = SN[99476],
                type = "circle",
                player = "#5#",
                range = 10,
                mode = "avoid",
                icon = ST[99476],
            },
        },
        windows = {
			proxwindow = true,
			proxrange = 20,
			proxoverride = true,
            proxnoautostart = true,
            nodistancecheck = true,
		},
        grouping = {
            {
                general = true,
                alerts = {"phasesoonwarn","phasewarn"},
            },
            {
                phase = 1,
                alerts = {"spinnerscd","spinnerswarn","spiderlingscd","spiderlingswarn","dronescd","droneswarn","fixatewarn","fixateselfwarn","poisonselfwarn","devastationcd","devastationsoon","devastationwarn"},
            },
            {
                phase = 2,
                alerts = {"flarecd","kisscd","kisswarn","kissduration"},
            },
        },        
        
        alerts = {
            -----------------------------
            ---------- Phase 1 ----------
            -----------------------------
            -- Cinderweb Spinners
            spinnerscd = {
				varname = format("%s Cooldown",L.npc_firelands["Cinderweb Spinners"]),
				type = "dropdown",
				text = format("New %s",L.npc_firelands["Cinderweb Spinners"]),
				time = "<spinnerscd>",
				flashtime = 5,
				color1 = "PINK",
				-- sound = "ALERT4",
                icon = ST[97503],
			},
            spinnerswarn = {
                varname = format("%s Warning",L.npc_firelands["Cinderweb Spinners"]),
                type = "simple",
                text = format("New: %s",L.npc_firelands["Cinderweb Spinners"]),
                time = 1,
                color1 = "MAGENTA",
                color2 = "Off",
                -- sound = "ALERT7",
                sound = "spinner",
                icon = ST[97503],
            },
            
            -- Cinderweb Spiderlings
			spiderlingscd = {
				varname = format("%s Cooldown",L.npc_firelands["Cinderweb Spiderlings"]),
				type = "dropdown",
				text = format("New %s",L.npc_firelands["Cinderweb Spiderlings"]),
				time = "<spiderlingscd>",
				flashtime = 5,
				color1 = "TEAL",
				-- sound = "ALERT5",
                icon = ST[87084],
			},     
            spiderlingswarn = {
                varname = format("%s Warning",L.npc_firelands["Cinderweb Spiderlings"]),
                type = "simple",
                text = format("New: %s",L.npc_firelands["Cinderweb Spiderlings"]),
                time = 1,
                color1 = "TEAL",
                color2 = "Off",
                -- sound = "ALERT9",
                sound = "spiderling",
                icon = ST[87084],
            },
            -- Cinderweb Drone
			dronescd = {
				varname = format("%s Cooldown",L.npc_firelands["Cinderweb Drone"]),
				type = "dropdown",
				text = format("New %s", L.npc_firelands["Cinderweb Drone"]),
				time = "<dronescd>",
				flashtime = 5,
				color1 = "YELLOW",
				-- sound = "ALERT6",
                icon = ST[81302],
			},
            droneswarn = {
                varname = format("%s Warning",L.npc_firelands["Cinderweb Drone"]),
                type = "simple",
                text = format("New: %s", L.npc_firelands["Cinderweb Drone"]),
                time = 1,
                color1 = "YELLOW",
                color2 = "Off",
                sound = "drone",
                icon = ST[81302],
            },
            
            -- Smoldering Devastation
			devastationcd = {
                varname = format(L.alert["%s CD"],SN[99048]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[99048]),
                time = 82,
                flashtime = 10,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[99052],
                counter = true,
                sticky = true,
            },
            devastationsoon = {
				varname = format(L.alert["%s soon Warning"],SN[99048]),
				type = "simple",
				text = format(L.alert["%s soon ..."],SN[99048]),
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[99052],
				sound = "ALERT2",
			},
            devastationwarn = {
				varname = format(L.alert["%s Warning"],SN[99048]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[99048]),
				time = 8,
				flashtime = 8,
				color1 = "ORANGE",
				icon = ST[99052],
                counter = true,
				sound = "RUNAWAY",
			},
            ------------
            -- Heroic --
            ------------
            -- Fixate
            fixatewarn = {
				varname = format(L.alert["%s Warning"],SN[99559]),
				type = "centerpopup",
				text = "<fixatetext>",
				time = 10,
				flashtime = 3,
				color1 = "BROWN",
				icon = ST[99559],
				sound = "ALERT7",
                tag = "#1#",
			},
			fixateselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[99559]),
				type = "centerpopup",
				text = format(L.alert["%s on %s"],SN[99559],L.alert["YOU"]),
				time = 10,
				flashtime = 3,
				color1 = "BROWN",
				icon = ST[99559],
				sound = "ALERT10",
				flashscreen = true,
                tag = "#1#",
			},
            -- Volatile Poison
            poisonselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[99278]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[99278],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                icon = ST[99278],
                throttle = 2,
                emphasizewarning = {2,0.5},
            },
            -----------------------------
            ---------- Phase 2 ----------
            -----------------------------
            -- Phase 2 soon
            phasesoonwarn = {
				varname = format(L.alert["Phase soon Warning"]),
				type = "simple",
				text = format(L.alert["Phase %s incoming"],"<phase>"),
				time = 3,
				flashtime = 3,
				color1 = "GOLD",
				icon = ST[99076],
				sound = "ALERT1",
			},
            -- Phase 2
            phasewarn = {
				varname = format(L.alert["Phase Warning"]),
				type = "simple",
				text = format(L.alert["Phase %s"],"<phase>"),
				time = 3,
				flashtime = 3,
				color1 = "TURQUOISE",
				icon = ST[11242],
				sound = "MINORWARNING",
			},
            -- Ember Flare
            flarecd = {
				varname = format(L.alert["%s CD"],SN[100936]),
				type = "centerpopup",
				text = format(L.alert["Next %s"],SN[100936]),
				time = 6,
				flashtime = 6,
				color1 = "ORANGE",
				icon = ST[100936],
			},
            -- The Widow's Kiss
			kisscd = {
				varname = format(L.alert["%s CD"],SN[99476]),
				type = "dropdown",
				text = format(L.alert["Next %s"],"Widow's Kiss"),
				time = "<kisscd>",
				flashtime = 5,
				color1 = "LIGHTGREEN",
                sound = "MINORWARNING",
				icon = ST[99476],
			},
            kisswarn = {
				varname = format(L.alert["%s Warning"],SN[99476]),
				type = "simple",
				text = "<kisstext>",
				time = 3,
				color1 = "LIGHTGREEN",
				icon = ST[99476],
				sound = "ALERT7",
			},
            kissduration = {
                varname = format(L.alert["%s Duration"],SN[99476]),
                type = "centerpopup",
                text = format(L.alert["%s dissipates"],SN[99476]),
                time = 26,
                flashtime = 5,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "None",
                icon = ST[99476],
            },
		},
		timers = {
			energy = {
				{
					"expect",{"&getup|boss&","<","13"},
					"expect",{"<devastationwarned>","==","no"},
					"alert","devastationsoon",
					"set",{devastationwarned = "yes"},
				},
				{
					"scheduletimer",{"energy",1},
				},
			},
			dronestimer = {
				{
					"alert","dronescd",
                    "alert","droneswarn",
					"scheduletimer",{"dronestimer",60},
				},
			},
            spinnerstimer = {
                {
                    "alert","spinnerscd",
                },
            },
		},
		events = {
			-----------------------------
            ---------- Phase 1 ----------
            -----------------------------
			-- Smoldering Devastation
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 99048,
				execute = {
					{
						"canceltimer","energy",
						"alert","devastationwarn",
                        "quash","flarecd",
						"set",{devastationcount = "INCR|1"},
						"set",{devastationwarned = "no"},
						"scheduletimer",{"energy",15},
						"set",{spinnerscd = {4, 7, 10, 0, loop = true, type = "series"}},
                        "scheduletimer",{"spinnerstimer", 8},
                        "quash","devastationcd",
					},
                    {
                        "expect",{"<devastationcount>","<","3"},
                        "schedulealert",{"devastationcd", 8},
                    },
                    -- Phaase 2 trigger
					{
						"expect",{"<devastationcount>","==","3"}, --perhaps a yell might be better trigger?
						"canceltimer","energy",
						"canceltimer","dronestimer",
                        "canceltimer","spinnerstimer",
						"quashall",{"devastationwarn"},
						"set",{phase = 2},
						"schedulealert",{"phasesoonwarn", 1},
                        "schedulealert",{"phasewarn", 8},
                        "schedulealert",{"kisscd", 8},
					},
				},
			},
            -- Ember Flare (Phase 1)
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 100936,
				execute = {
					{
						"expect",{"<phase>","==","1"},
                        "expect",{"&unitname|playertarget&","==","Beth'tilac"},
                        
						"quash","flarecd",
                        "alert","flarecd",
					},
				},
			},
            -- Emotes
			{
				type = "event",
				event = "EMOTE",
				execute = {
					-- Spiderlings
					{
						"expect",{"#1#","find",L.chat_firelands["^Spiderlings have been roused from their nest"]},
                        "quash","spiderlingscd",
                        "alert","spiderlingscd",
                        "alert","spiderlingswarn",
					},
                    -- Spinners
                    {
                        "expect",{"#1#","find",L.chat_firelands["^Cinderweb Spinners dangle from above"]},
                        "quash","spinnerscd",
                        "alert","spinnerscd",
                        "alert","spinnerswarn",
                    },
				},
			},
            ------------
            -- Heroic --
            ------------
            -- Fixate
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 99559,
				srcisnpctype = true,
				execute = {
					{
						"raidicon","fixateicon",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{fixatetext = format(L["%s on <%s>"],SN[99559],"#5#")},
						"alert","fixatewarn",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","fixateselfwarn",
						"announce","fixatesay",
					},
				},
			},
            {
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 99559,
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    -- Drone dies
                    {
                        "expect",{"&npcid|#4#&","==","52581"},
                        "quash",{"fixatewarn","#4#"},
                        "quash",{"fixateselfwarn","#4#"},
                    },
                },
            },
            -- Volatile Poison
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 99278,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","poisonselfwarn",
                    },
                },
            },
			-----------------------------
            ---------- Phase 2 ----------
            -----------------------------
			-- The Widow's Kiss
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 99476,
				dstisplayertype = true,
				execute = {
					{
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{kisstext = format(L["%s on %s"],SN[99506],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{kisstext = format(L["%s on <%s>"],SN[99506],"#5#")},
                    },
                    {
                        "quash","kisscd",
						"alert","kisswarn",
						"alert","kisscd",
                        "alert","kissduration",
                        "range",{true},
                        "radar","kissradar"
					},
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 99476,
                execute = {
                    {
                        "range",{false},
                        "removeradar",{"kissradar", player = "#5#"},
                    },
                },
            },
            
			-- Ember Flare (Phase 2)
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 100936,
				execute = {
					{
						"expect",{"<phase>","==","2"},
						"quash","flarecd",
                        "alert","flarecd",
					},
				},
			},
		},
    }

	DXE:RegisterEncounter(data)
end


------------------------
-- LORD RHYOLITH
------------------------
do
	local data = {
		version = 16,
		key = "Rhyolith",
		zone = L.zone["Firelands"],
		category = L.zone["Firelands"],
		name = L.npc_firelands["Lord Rhyolith"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Lord Rhyolith.blp",
		triggers = {
			scan = {
				52558, -- Lord Rhyolith
                52577, -- Left
				53087, -- Right
			},
			yell = L.chat_firelands["^Hah? Hruumph?"],
		},
		onactivate = {
			tracing = {
				52577, -- Left foot
				53087, -- Right foot
			},
			tracerstart = true,
			combatstop = true,
			defeat = 52558,
		},
		userdata = {
            -- Timers
			stompcd = {15.8, 30, loop = false, type = "series"},
			volcanocd = {30, 25, loop = false, type = "series"},
            -- Counters
            fragments = 1,
            
            -- Switches
            fragmentsthrottle = "no",
		},
		onstart = {
			{
                "alert","fragmentscd",
				"alert","stompcd",
				"alert","volcanocd",
                "expect",{"&difficulty&","<=","2"},
                "alert","superheatedcd",
            },
            {
                "expect",{"&difficulty&",">=","3"},
                "alert",{"superheatedcd",time = 2},
			},
		},

        filters = {
            bossemotes = {
                drinkingemote = {
                    name = "Drinking the magma",
                    pattern = "begins to drink from the magma",
                    hasIcon = false,
                    texture = ST[57634],
                },
                armoremote = {
                    name = "Weakened armor",
                    pattern = "armor is weakened by the active",
                    hasIcon = false,
                    texture = ST[98632],
                    hide = true,
                },
                armorshatteredemote = {
                    name = "Shattered armor",
                    pattern = "stumbles as his armor is shattered",
                    hasIcon = false,
                    texture = ST[98632],
                    hide = true
                },
                superheatedemote = {
                    name = "Superheated",
                    pattern = "grows impatient and becomes",
                    hasIcon = false,
                    texture = ST[101305],
                },
            },
        },
        ordering = {
            alerts = {"stompcd","stompwarn","fragmentscd","volcanocd","volcanowarn","volcanoduration",
                      "superheatedcd","lavawarn","lavaduration",
                      "sparkcd","sparkwarn","phasewarn"},
        },
        
        alerts = {
            -------------
            -- Phase 1 --
            -------------
            -- Concussive Stomp
			stompcd = {
				varname = format(L.alert["%s CD"],SN[100411]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100411]),
				time = "<stompcd>",
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[100411],
                sound = "MINORWARNING",
			},
			stompwarn = {
				varname = format(L.alert["%s Warning"],SN[100411]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[100411]),
				time = 3,
				flashtime = 3,
				color1 = "ORANGE",
				icon = ST[100411],
				sound = "ALERT2",
			},
            -- Heated Volcano
            volcanocd = {
				varname = format(L.alert["%s CD"],SN[98493]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[98493]),
				time = "<volcanocd>",
				flashtime = 3,
				color1 = "WHITE",
				icon = ST[98493],
				sound = "MINORWARNING",
			},
            volcanowarn = {
                varname = format(L.alert["%s Warning"],SN[98493]),
                type = "simple",
                text = format(L.alert["%s"],SN[98493]),
                time = 1,
                color1 = "ORANGE",
                -- sound = "ALERT9",
                sound = "volcano",
                icon = ST[98493],
            },
            volcanoduration = {
                varname = format(L.alert["%s Duration"],SN[98493]),
                type = "dropdown",
                text = format(L.alert["%s fades"],SN[98493]),
                time = 82,
                flashtime = 5,
                color1 = "CYAN",
                sound = "None",
                icon = ST[98493],
                tag = "#1#",
            },
            -- Magma Flow (aka Lava Line)
            lavawarn = {
				varname = format(L.alert["%s Warning"],SN[97225]),
                type = "simple",
				text = format(L.alert["%s"],SN[97225]),
				time = 1,
				flashtime = 3,
				color1 = "PEACH",
				icon = ST[97225],
				-- sound = "ALERT7",
                sound = "fireline",
			},
            lavaduration = {
                varname = format(L.alert["%s Duration"],SN[97225]),
                type = "centerpopup",
                text = format(L.alert["%s ends"],SN[97225]),
                time = 10,
                color1 = "PEACH",
                sound = "MINORWARNING",
                icon = ST[97225],
            },
            -- Fragment of Rhyolith
            fragmentscd = {
				varname = format(L.alert["%s CD"],SN[98136]),
				type = "dropdown",
				text = format(L.alert["New %s"],L.npc_firelands["Fragments of Rhyolith"]),
				time = 23,
				flashtime = 5,
				color1 = "BROWN",
				icon = ST[98136],
				sound = "ALERT3",
                throttle = 10,
			},
            -- Spark of Rhyolith
			sparkcd = {
				varname = format(L.alert["%s CD"],SN[98552]),
				type = "dropdown",
				text = format(L.alert["New %s"], L.npc_firelands["Spark of Rhyolith"]),
				time = 23,
				flashtime = 5,
				color1 = "VIOLET",
				icon = ST[99262],
				sound = "sparksoon",
                throttle = 10,
			},
			sparkwarn = {
				varname = format(L.alert["%s Warning"],SN[98552]),
				type = "simple",
				text = format(L.alert["%s"],SN[98552]),
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[99262],
				sound = "ALERT8",
			},
            -- Superheated
			superheatedcd = {
				varname = format(L.alert["%s CD"],SN[101305]),
				type = "dropdown",
				text = format(L.alert["%s"],SN[101305]),
				time = 360,
                time2 = 300,
				flashtime = 10,
				color1 = "RED",
				icon = ST[101305],
				sound = "ALERT9",
			},
            -------------
            -- Phase 2 --
            -------------
            -- Phase Warning
            phasewarn = {
				varname = format(L.alert["Phase 2 Warning"]),
				type = "simple",
				text = format(L.alert["Phase %s"],"2"),
				time = 3,
				flashtime = 3,
				color1 = "TURQUOISE",
				sound = "BEWARE",
                icon = ST[11242],
			},
		},
		timers = {
            resetfragmentstimer = {
                {
                    "set",{fragmentsthrottle = "no"},
                },
            },
        },
		events = {
            -------------
			-- Phase 1 --
            -------------
            -- Stomp
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 100411,
				execute = {
					{
						"quash","stompcd",
						"alert","stompcd",
						"alert","stompwarn",
					},
				},
			},
			-- Fragment
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 98135,
                execute = {
                    {
                        "expect",{"<fragmentsthrottle>","==","no"},
                        "set",{fragments = "INCR|1"},
                        "expect",{"<fragments>","<","2"},
                        "alert","fragmentscd",
                    },
                    {
                        "expect",{"<fragmentsthrottle>","==","no"},
                        "expect",{"<fragments>","==","2"},
                        "set",{fragments = 0},
                        "alert","sparkcd",
                    },
                    {    
                        "expect",{"<fragmentsthrottle>","==","no"},
                        "set",{fragmentsthrottle = "yes"},
                        "scheduletimer",{"resetfragmentstimer", 10},
                    },
                },
            },
			-- Spark
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 98553,
                execute = {
                    {
                        "alert","fragmentscd",
                        
                    },
                },
            },
			-- Magma Flow (Lava Line)
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 97225,
                execute = {
                    {
                        "alert","lavawarn",
                        "alert","lavaduration",
                    },
                },
            },
            
			-- Heated Volcano
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 98493,
				execute = {
					{
						"quash","volcanocd",
						"alert","volcanocd",
                        "alert","volcanowarn",
					},
				},
			},
			-- Emotes
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_firelands["stumbles as his armor is shattered"]},
						"batchquash",{"sparkcd","fragmentscd","stompcd"},
                        "tracing",{52558},
                        "set",{stompcd = {7,13, loop = false, type = "series"}},
                        "alert","stompcd",
						"alert","phasewarn",
					},
				},
			},
		},
        
    }

	DXE:RegisterEncounter(data)
end


------------------------
-- ALYSRAZOR
------------------------
do
	local data = {
		version = 21,
		key = "Alysrazor",
		zone = L.zone["Firelands"],
		category = L.zone["Firelands"],
		name = L.npc_firelands["Alysrazor"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Alysrazor.blp",
		triggers = {
			scan = {
				52530, -- Alysrazor
				54015, -- Staghelm (to trigger first encounter)
			},
			yell = L.chat_firelands["^I serve a new master now"],
		},
        onpullevent = {
            {
                triggers = {
                    yell = L.chat_firelands["visitors to our kingdom in the Firelands"],
                },
                invoke = {
                    {
                       "alert","pullcd",
                    },
                },
            },
        },
		onactivate = {
			tracing = {52530}, -- Alysrazor
			tracerstart = true,
			combatstop = true,
			defeat = 52530,
		},
		userdata = {
			-- Timers
            tantrumcd = 15,
            phasedur = {179, 167, loop = false, type = "series"},
            firestormcd = {92, 72, 0, loop = false, type = "series"},
            cataclysmcd = {28, 30, 0, 9, 30, 0, 20, 0, loop = false, type = "series"},
            wormscd = {56, 62, 0, loop = false, type = "series"},
            
            
            -- Texts
            imprintedtext = "",
			woundtext = "",
			woundremovedtext = "",
            
            -- Counters
            phase = 0,
            rotationCounter = 1,
            
            -- GUIDs
            hatchling1GUID = "",
            hatchling2GUID = "",
		},
		onstart = {
			{
				"expect",{"&difficulty&",">=","3"}, --10h&25h
				"set",{
                    phasedur = {238, 219, loop = false, type = "series"},
                    wormscd = {36, 83, 80, 0, loop = false, type = "series"},
                    tantrumcd = 10,
                },
				"alert","firestormcd",
                "alert","cataclysmcd",
			},
            {
                "quash","pullcd",
                "set",{phase = 1},
				"alert","phasewarn",
                "alert","phasedur",
                "alert","wormscd",
            },
		},
		
        filters = {
            bossemotes = {
                cataclysmemote = {
                    name = "Cataclysm casting",
                    pattern = "Herald of the Burning End begins casting",
                    hasIcon = true,
                    texture = ST[100761],
                    hide = true,
                },
                eggsmemote = {
                    name = "Molten Eggs hatching",
                    pattern = "The Molten Eggs begin",
                    hasIcon = false,
                    texture = ST[87863],
                    hide = true,
                },
                wormsemote = {
                    name = "Fiery Lava Worms eruption",
                    pattern = "Fiery Lava Worms erupt from",
                    hasIcon = false,
                    texture = ST[92235],
                    hide = true,
                },
                firestormemote = {
                    name = "Firestorm charg up",
                    pattern = "begins to charge up",
                    hasIcon = true,
                    texture = ST[100744],
                    hide = true,
                },
                vortexemote = {
                    name = "Fiery Vortex formation",
                    pattern = "The harsh winds form",
                    hasIcon = false,
                    texture = ST[99794],
                    hide = true,
                },
                burnoutemote = {
                    name = SN[99432],
                    pattern = "Alysrazor's fire",
                    hasIcon = true,
                    texture = ST[99432],
                    hide = true,
                },
                reigniteemote = {
                    name = "Alysrazor Re-Ignites",
                    pattern = "Alysrazor's firey core",
                    hasIcon = true,
                    textures = ST[99922],
                },
                circleemote = {
                    name = "Alysrazor starts flying rapidly",
                    pattern = "begins to fly in a rapid circle",
                    hasIcon = false,
                    hide = true,
                },
                fullpoweremote = {
                    name = "Alysrazor's full power",
                    pattern = "Alysrazor is at ",
                    hasIcon = true,
                },
                burnemote = {
                    name = "Alysrazor's soft enrage",
                    pattern = "is unable to fully",
                    hasIcon = false,
                },
            },
        },
        phrasecolors = {
            {"Herald:","GOLD"},
        },
        grouping = {
            {
                general = true,
                alerts = {"pullcd","phasewarn","phasedur","wingsselfwarn","wingsduration","blazingpowerwarn","enragecd"},
            },
            {
                phase = 1,
                alerts = {"fieroblastkickwarn","cataclysmcd","cataclysmwarn","cataclysmcast","meteowarn","eggscd","imprinted","wormscd","wormswarn","tantrumcd","tantrumwarn","firestormcd","firestormwarn","firestormcast","firestormduration"},
            },
            {
                phase = 2,
                alerts = {"vortexinc","vortexdur"},
            },
        },
        
        alerts = {
            -- Phase
			phasedur = {
				varname = format(L.alert["Phase Duration"]),
				type = "dropdown",
				text = format(L.alert["Phase %s"],"&sum|<phase>|1&"),
				time = "<phasedur>",
				time2 = 21.4,
				flashtime = 10,
				color1 = "TURQUOISE",
                icon = ST[11242],
			},
			phasewarn = {
				varname = format(L.alert["Phase Warning"]),
				type = "simple",
				text = format(L.alert["Phase %s"],"<phase>"),
				time = 3,
				color1 = "TURQUOISE",
				sound = "ALERT1",
                icon = ST[11242],
			},
            -- Pull Countdown
            pullcd = {
				varname = format(L.alert["Pull Countdown"]),
				type = "dropdown",
				text = format(L.alert["%s"],"Encounter starts"),
				time = 38,
				flashtime = 10,
				color1 = "TURQUOISE",
                icon = ST[11242],
			},
            -- Soft Enrage
            enragecd = {
                varname = L.alert["Soft Enrage Countdown"],
                type = "dropdown",
                text = L.alert["Soft Enrage"],
                time = 21.4,
                flashtime = 10,
                color1 = "RED",
                color2 = "GOLD",
                icon = ST[12317],
                sound = "ALERT10",
            },
            ------------------------------------------
            ----------------- Phase 1 ----------------
            ------------------------------------------
            wingsduration = {
				varname = format(L.alert["%s Duration"],SN[98619]),
				type = "centerpopup",
				text = format(L.alert["%s dissipates"],SN[98619]),
				time = 30,
                time2 = 30,
				flashtime = 5,
				color1 = "GOLD",
				icon = ST[98619],
			},
            wingsselfwarn = {
				varname = format(L.alert["%s Warning"],SN[98619]),
				type = "simple",
				text = format(L.alert["%s"],SN[98619]),
				time = 1,
				color1 = "GOLD",
				icon = ST[98619],
                sound = "ALERT8",
			},
            -- Blazing Power
            blazingpowerwarn = {
                varname = format(L.alert["%s on me Warning"],SN[99461]),
                type = "simple",
                text = "<blazingpowertext>",
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT8",
                icon = ST[99461],
            },
            ---------- The adds section ----------
            --------------------------------------
            -- Fieroblast
            fieroblastkickwarn = {
                varname = format(L.alert["%s Warning"],SN[101295]),
                type = "simple",
                text = format(L.alert["%s - INTERRUPT"],SN[101295]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT11",
                icon = ST[101295],
                throttle = 1,
            },
            -------- Voracious Hatchlings --------
            eggscd = {
				varname = format(L.alert["%s Cooldown"],SN[100363]),
				type = "centerpopup",
				text = format("New %s","Voracious Hatchlings"),
				time = 5, -- 6
				flashtime = 6,
				color1 = "ORANGE",
				icon = ST[87863],
				sound = "ALERT7",
			},
            -- Imprinted
            imprinted = {
				varname = format(L.alert["%s Warning"],SN[100360]),
				type = "simple",
				text = "<imprintedtext>",
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[100360],
				sound = "ALERT3",
			},
            -- Satitated
            tantrumcd = {
				varname = format(L.alert["%s Duration"],SN[100852]),
				type = "centerpopup",
				text = format(L.alert["%s dissipates"],SN[100852]),
				time = "<tantrumcd>",
				flashtime = 15,
				color1 = "YELLOW",
				icon = ST[100852],
				throttle = 2, --possbily
			},
            -- China customize
            tantrumwarn = {
				varname = format(L.alert["%s Warning"],SN[99362]),
				type = "simple",
				-- text = format(L.alert["%s dissipates"],SN[99362]),
                text = format(L.alert["%s"],SN[99362]),
				time = 1,
				flashtime = 15,
				color1 = "VIOLET",
                sound = "chickenfrenzy",
				icon = ST[99362],
			},
            ------------- Lava Worm ------------
            wormscd = {
                varname = format(L.alert["%s CD"],"Summon Lava Worms"),
                type = "dropdown",
                text = format(L.alert["New %s"],"Lava Worms"),
                time = "<wormscd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[92235],
            },
            wormswarn = {
                varname = format(L.alert["%s Warning"],"Summon Lava Worms"),
                type = "simple",
                text = format(L.alert["New: %s"],"Lava Worms"),
                time = 1,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[92235],
            },
            ----------- Heroic difficulty ------------
            -- Cataclysm
            cataclysmcast = {
				varname = format(L.alert["%s Casting"],SN[100761]),
				type = "dropdown",
				text = format(L.alert["%s"],SN[100761]),
				time = 5,
				flashtime = 3,
				color1 = "LIGHTBLUE",
                color2 = "CYAN",
				icon = ST[100761],
				-- sound = "ALERT2",
                sound = "catalysm",
                audiocd = true,
			},
            cataclysmwarn = {
                varname = format(L.alert["%s Warning"],SN[100761]),
                type = "simple",
                text = format(L.alert["Herald: %s"],SN[100761]),
                time = 1,
                color1 = "LIGHTBLUE",
                -- sound = "None",
                -- sound = "catalysm",
                icon = ST[100761],
            },
			cataclysmcd = {
				varname = format(L.alert["%s CD"],SN[100761]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100761]),
				time = "<cataclysmcd>",
				flashtime = 5,
				color1 = "BROWN",
				icon = ST[100761],
			},
            meteowarn = {
                varname = format(L.alert["%s Warning"],"molten-meteor"),
                type = "simple",
                text = format(L.alert["New: %s"],"molten-meteor"),
                time = 1,
                color1 = "LIGHTBLUE",
                icon = ST[100761],
                sound = "killmeteor",
            },
            -- Firestorm
            firestormcd = {
				varname = format(L.alert["%s CD"],SN[100744]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100744]),
				time = "<firestormcd>",
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[100744],
			},
            firestormwarn = {
                varname = format(L.alert["%s Warning"],SN[100744]),
                type = "simple",
                text = format(L.alert["%s incoming"],SN[100744]),
                time = 1,
                color1 = "YELLOW",
                sound = "None",
                icon = ST[100744],
            },
			firestormcast = {
				varname = format(L.alert["%s Casting"],SN[100744]),
				type = "centerpopup",
				text = format(L.alert["%s incoming"],SN[100744]),
				time = 5,
				flashtime = 5,
				color1 = "YELLOW",
				color2 ="RED",
				icon = ST[100744],
				sound = "BEWARE",
			},
            firestormduration = {
                varname = format(L.alert["%s Duration"],SN[100744]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[100744]),
                time = 5,
				flashtime = 5,
				color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "ALERT7",
                icon = ST[100744],
                fillDirection = "DEPLETE",
            },
            ------------------------------------------
            ----------------- Phase 2 ----------------
            ------------------------------------------
			-- Fiery Vortex
            vortexinc = {
				varname = format(L.alert["%s Countdown"],SN[99794]),
				type = "centerpopup",
				text = format(L.alert["%s incoming"],SN[99794]),
				time = 10,
				flashtime = 5,
                color1 = "YELLOW",
                color2 = "ORANGE",
				icon = ST[99794],
			},
			vortexdur = {
				varname = format(L.alert["%s Duration"],SN[99794]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[99794]),
				time = 23,
				flashtime = 23,
				color1 = "LIGHTBLUE",
                color2 = "CYAN",
				icon = ST[99794],
			},
		},
		timers = {
            vortextimer = {
                {
                    "quash","vortexinc",
                    "alert","vortexdur",
                },
            },
        },
        events = {
            ------------------------------------------
            ----------------- Phase 1 ----------------
            ------------------------------------------
            -- Wings of Flame (self only)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname= 98619,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert",{"wingsduration",time=2},
                        "alert","wingsselfwarn",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REFRESH",
				spellname= 98619,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","wingsduration",
                        "alert",{"wingsduration"},
					},
				},
			},
            -- Blazing Power
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 99461,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{blazingpowertext = format(L.alert["%s (%d)"],SN[99461],1)},
                        "alert","blazingpowerwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 99461,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{blazingpowertext = format(L.alert["%s (%s)"],SN[99461],"#11#")},
                        "alert","blazingpowerwarn",
                    },
                },
            },
            
            
            ---------- Voracious Hatchlings ----------
            -- Summon Voracious Hatchlings
            {
				type = "event",
				event = "EMOTE",
				execute = {
					-- Eggs
					{
						"expect",{"#1#","find",L.chat_firelands["^The Molten Eggs begin to hatch"]},
						"alert","eggscd",
                        "set",{
                            hatchling1GUID = "",
                            hatchling2GUID = "",
                        },
					},
				},
			},
            -- Imprinted
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = {99389,100359,99390,100360},
                execute = {
                    {
						"expect",{"#4#","~=","&playerguid&"},
                        "set",{imprintedtext = format(L.alert["%s on <%s>"],SN[100360],"#5#")},
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{imprintedtext = format(L.alert["%s on %s"],SN[100360],L.alert["YOU"])},
                    },
                    {
                        "alert","imprinted",
                    },
                },
            },
            {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 100360,
				execute = {
                    {
                        "expect",{"<hatchling1GUID>","==",""},
                        "set",{hatchling1GUID = "#1#"},
                        "temptracing","#1#",
                    },
                    {
                        "expect",{"<hatchling1GUID>","~=",""},
                        "expect",{"<hatchling1GUID>","~=","#1#"},
                        "expect",{"<hatchling2GUID>","==",""},
                        "set",{hatchling2GUID = "#1#"},
                        "temptracing","#1#",
                    },
				},
			},
			-- Satiated
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 99359,
				execute = {
					{
						"expect",{"&guidisplayertarget|#1#&","==","true"},
						"alert","tantrumcd",
					},
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REFRESH",
                spellname = 99359,
                execute = {
                    {
                        "expect",{"&guidisplayertarget|#1#&","==","true"},
                        "quash","tantrumcd",
						"alert","tantrumcd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 99359,
                execute = {
                    {
                        "expect",{"&guidisplayertarget|#1#&","==","true"},
                        "quash","tantrumcd",
                    },
                },
            },
            -- China customize
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 99362,
                execute = {
                    {
                        "expect",{"&guidisplayertarget|#1#&","==","true"},
                        "alert","tantrumwarn",
                    },
                },
            },
            -- Fieroblast
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 101295,
                execute = {
                    {
                        "expect",{"&guidisplayertarget|#1#&","==","true"},
                        "alert","fieroblastkickwarn",
                    },
                },
            },
            ---------- Heroic difficulty ----------
            -- Cataclysm
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 102111,
				srcisnpctype = true,
				execute = {
					{
						"alert","cataclysmcast",
                        "alert","cataclysmwarn",
						"alert","cataclysmcd",
					},
				},
			},
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 102111,
				srcisnpctype = true,
				execute = {
					{
						"alert","meteowarn",
					},
				},
			},
            
			-- Firestorm
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 100744,
				execute = {
					{
                        "quash","firestormcd",
                        "alert","firestormwarn",
						"alert","firestormcast",
						"schedulealert",{"firestormcd", 10},
                        "schedulealert",{"cataclysmcd", 10},
					},
				},
			},
            -- Firestorm (duration)
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#1#","find","boss"},
                        "expect",{"#5#","==","100744"},
                        "quash","firestormcast",
                        "alert","firestormduration",
                    },
                },
            },
			------------------------------------------
            ----------------- Phase 3 ----------------
            ------------------------------------------
			{
				type = "event",
				event = "YELL",
				execute = {
                    -- Phase 1
					{
                        "expect",{"#1#","find",L.chat_firelands["^I will burn you from the sky"]},
                        "set",{phase = 1},
                        "alert","phasewarn",
                        "alert","phasedur",
                        "alert","wormscd",
                        "expect",{"&difficulty&",">=","3"},
                        "alert","firestormcd",
                        "alert","cataclysmcd",
                    },
					-- Phase 2
					{
						"expect",{"#1#","find",L.chat_firelands["^These skies are MINE!"]},
						"quash","phasedur",
                        "alert","vortexinc",
                        "scheduletimer",{"vortextimer", 10},
						"set",{phase = 2},
						"alert","phasewarn",
					},
					-- Phase 3
					{
						"expect",{"#1#","find",L.chat_firelands["^Fire..."]},
						"set",{phase = 3},
						"alert","phasewarn",
					},
                    -- Phase 4
					{
						"expect",{"#1#","find",L.chat_firelands["^Reborn in flame"]},
						"set",{
                            phase = 4,
                            firestormcd = {75, 70, 0, loop = false, type = "series"},
                            cataclysmcd = {19, 30, 0, 7, 25, 0, 15, 0, loop = false, type = "series"},
                            rotationCounter = "INCR|1",
                        },
                    },
                    {
                        "expect",{"#1#","find",L.chat_firelands["^Reborn in flame"]},
                        "expect",{"<rotationCounter>","<","4"},
                        "alert","phasewarn",
                        "set",{phase = 0},
                        "alert",{"phasedur",time = 2},
                    },
                    {
                        "expect",{"#1#","find",L.chat_firelands["^Reborn in flame"]},
                        "expect",{"<rotationCounter>",">=","4"},
                        "alert","enragecd",
                    },
                    {
                        "expect",{"#1#","find",L.chat_firelands["^Reborn in flame"]},
                        "expect",{"&difficulty&","<=","2"},
                        "set",{wormscd = {47, 62, 0, loop = false, type = "series"}},
					},
                    {
                        "expect",{"#1#","find",L.chat_firelands["^Reborn in flame"]},
                        "expect",{"&difficulty&",">","2"},
                        "set",{wormscd = {27, 74, 81, 0, loop = false, type = "series"}},
                    },
				},
			},
            {
                type = "event",
                event = "CHAT_MSG_RAID_BOSS_EMOTE",
                execute = {
                    -- Lava Worms
                    {
                        "expect",{"#1#","find",L.chat_firelands["^Fiery Lava Worms erupt"]},
                        "quash","wormscd",
                        "alert","wormscd",
                        "alert","wormswarn",
                    },
                },
            },
		},
        
    }

	DXE:RegisterEncounter(data)
end


------------------------
-- BALEROC
------------------------
do
	local data = {
		version = 15,
		key = "Baleroc",
		zone = L.zone["Firelands"],
		category = L.zone["Firelands"],
		name = L.npc_firelands["Baleroc"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Baleroc.blp",
        triggers = {
			scan = {
				53494, -- Baleroc
			},
		},
		onactivate = {
			tracing = {53494}, -- Baleroc
			tracerstart = true,
			combatstop = true,
			defeat = 53494,
		},
		userdata = {
			-- Texts
            tormenttext = "",
            tormentedtext = "",
			blazetext = "",
            countdownother = "",
            
            -- Counters
            countdownmax = 2,
            strikecount = 0,
            decimatingstrikemax = 2,
            decimatingstrikecdnodebuff = 5,
            decimatingstrikecddebuff = 6,
            infernostrikecdnodebuff = 2,
            infernostrikecddebuff = 2.4,
            
            -- Lists
			countdownunits = {type = "container", wipein = 3},

		},
		onstart = {
            {
				"expect",{"&difficulty&",">=","3"}, --10h&25h
				"alert",{"countdowncd",time = 2},
			},
			{
                "alert","enragecd",
				"alert",{"bladecd",time = 2},
				"alert",{"shardcd",time = 2},
			},
            {
                "expect",{"&difficulty&","==","2"},
                "set",{
                    decimatingstrikemax = 5,
                    decimatingstrikecddebuff = 3,
                    decimatingstrikecdnodebuff = 2.5,
                },
            },
            {
                "expect",{"&difficulty&","==","4"},
                "set",{
                    decimatingstrikemax = 5,
                    decimatingstrikecddebuff = 3,
                    decimatingstrikecdnodebuff = 2.5,
                },
            },
            {
                "set",{
                    decimatingstrikecd = "<decimatingstrikecdnodebuff>",
                    infernostrikecd = "<infernostrikecdnodebuff>",
                },
            }
		},

		arrows = {
			countdownarrow = {
				varname = format("%s",SN[99516]),
				unit = "<countdownother>",
				persist = 10,
				action = "TOWARD",
				msg = L.alert["MOVE TOWARD"],
				spell = SN[99516],
                texture = ST[99516],
			},
		},
		announces = {
			countdownsay = {
				type = "SAY",
                subtype = "self",
                spell = 99516,
				msg = format(L.alert["%s on Me"],SN[99516]),
			},
		},
		raidicons = {
			countdownicon = {
                varname = format("%s {%s}",SN[99516],"PLAYER_DEBUFF"),
				type = "MULTIFRIENDLY",
				persist = 8,
				reset = 2,
				unit = "#5#",
				icon = 1,
				total = 2,
                texture = ST[99516],
			},
		},
		filters = {
            bossemotes = {
                infernobladeemote = {
                    name = "Inferno Blade",
                    pattern = "Inferno Blade",
                    hasIcon = true,
                    texture = ST[99350],
                    hide = true,
                },
                decimationbladeemote = {
                    name = "Decimation Blade",
                    pattern = "Decimation Blade",
                    hasIcon = true,
                    texture = ST[99352],
                    hide = true,
                },
            },
        },
        radars = {
            tormentedradar = {
                varname = SN[99257],
                type = "circle",
                player = "#5#",
                range = 2,
                mode = "avoid",
                color = "MAGENTA",
                icon = ST[99257],
            },
        },
        windows = {
			proxwindow = true,
			proxrange = 15,
			proxoverride = true,
            nodistancecheck = true,
		},
        ordering = {
            alerts = {"enragecd","shardcd","shardwarn","tormentwarn","tormentedcd","tormentedwarn","bladecd",
            "decimationbladewarn","decimationbladecast","decimationbladedur","decimatingstrikecd",
            "infernobladewarn","infernobladecast","infernobladedur","infernostrikecd",
            "countdowncd","countdownwarn","countdownself"},
        },
		
        alerts = {           
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time = 360,
                flashtime = 30,
                color1 = "RED",
                icon = ST[12317],
            },
            -- Blades of Baleroc
			bladecd = {
				varname = format(L.alert["%s CD"],SN[99342]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[99342]),
				time = 47,
				time2 = 30,
				flashtime = 10,
				color1 = "ORANGE",
				icon = ST[99352],
				sound = "MINORWARNING",
			},
            -- Decimation Blade
            decimationbladewarn = {
                varname = format(L.alert["%s Warning"],SN[99352]),
                type = "simple",
                text = format(L.alert["%s"],SN[99352]),
                time = 1,
                color1 = "PURPLE",
                sound = "None",
                icon = ST[99352],
            },
            decimationbladecast = {
				varname = format(L.alert["%s Cast"],SN[99352]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[99352]),
				time = 1.5,
				flashtime = 3,
				color1 = "PURPLE",
				icon = ST[99352],
				sound = "BEWARE",
			},
			decimationbladedur = {
				varname = format(L.alert["%s Duration"],SN[99352]),
				type = "centerpopup",
                fillDirection = "DEPLETE",
				text = format(L.alert["%s fades"],SN[99352]),
				time = 15,
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[99352],
			},
            -- Decimating Strike
            decimatingstrikecd = {
                varname = format(L.alert["%s CD"],SN[99353]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[99353]),
                time = "<decimatingstrikecd>",
                color1 = "MAGENTA",
                sound = "None",
                icon = ST[99353],
                behavior = "overwrite",
                counter = true,
            },
            -- Inferno Blade
            infernobladewarn = {
                varname = format(L.alert["%s Warning"],SN[99350]),
                type = "simple",
                text = format(L.alert["%s"],SN[99350]),
                time = 1,
                color1 = "YELLOW",
                sound = "None",
                icon = ST[99350],
            },
            infernobladecast = {
				varname = format(L.alert["%s Cast"],SN[99350]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[99350]),
				time = 1.5,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[99350],
				sound = "ALERT1",
			},
			infernobladedur = {
				varname = format(L.alert["%s Duration"],SN[99350]),
				type = "centerpopup",
                fillDirection = "DEPLETE",
				text = format(L.alert["%s fades"],SN[99350]),
				time = 15,
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[99350],
			},
            -- Inferno Strike
            infernostrikecd = {
                varname = format(L.alert["%s CD"],SN[101002]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[101002]),
                time = "<infernostrikecd>",
                color1 = "RED",
                sound = "None",
                icon = ST[101002],
                behavior = "overwrite",
                counter = true,
            },
            -- Shards of Torment
			shardcd = {
				varname = format(L.alert["%s CD"],SN[99259]),
				type = "dropdown",
                text = format(L.alert["Next %s"],SN[99259]),
				time = 34,
				time2 = 6,
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[99259],
				sound = "ALERT3",
                counter = true,
			},
			shardwarn = {
				varname = format(L.alert["%s Warning"],SN[99259]),
				type = "simple",
                text = format(L.alert["%s"],SN[99259]),
				time = 1.5,
				flashtime = 3,
				color1 = "MAGENTA",
				icon = ST[99259],
				sound = "ALERT2",
                counter = true,
			},
			tormentwarn = {
				varname = format(L.alert["%s Warning"],SN[99256]),
				type = "simple",
				text = "<tormenttext>",
				time = 3,
                stacks = 10,
				icon = ST[99256],
				color1 = "CYAN",
                sound = "ALERT8",
			},
            -- Tormented
            tormentedcd = {
                varname = format(L.alert["%s Duration"],SN[99257]),
                type = "dropdown",
                text = "<tormentedtext>",
                time10n = 20,
                time10h = 40,
                time25n = 30,
                time25h = 60,
                flashtime = 5,
                color1 = "MAGENTA",
                color2 = "PURPLE",
                sound = "MINORWARNING",
                icon = ST[99257],
                tag = "#1#",
            },
            tormentedwarn = {
                varname = format(L.alert["%s Warning"],SN[99257]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[99257],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT9",
                icon = ST[99257],
                throttle = 3,
            },
            ------------
			-- Heroic --
            ------------
            -- Countdown
			countdowncd = {
				varname = format(L.alert["%s CD"],SN[99516]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[99516]),
				time = 47,
				time2 = 25,
				flashtime = 10,
				color1 = "PEACH",
				icon = ST[99516],
				sound = "ALERT4",
			},
			countdownwarn = {
				varname = format(L.alert["%s Warning"],SN[99516]),
				type = "simple",
				text = format(L.alert["%s on %s"],SN[99516],"&list|countdownunits&"),
				time = 3,
				flashtime = 3,
				color1 = "ORANGE",
				icon = ST[99516],
				sound = "ALERT5",
			},
			countdownself = {
				varname = format(L.alert["%s on me Warning"],SN[99516]),
				type = "centerpopup",
				text = format(L.alert["%s on %s"],SN[99516],L.alert["YOU"]),
				time = 8,
				flashtime = 8,
				color1 = "ORANGE",
				icon = ST[99516],
				sound = "ALERT1",
				flashscreen = true,
                audiocd = true,
			},
		},
		timers = {
			countdowntimer = {
				{
                    "expect",{"&listsize|countdownunits&",">","0"},
					"alert","countdownwarn",
				},
			},
			firearrow = {
				{
					"arrow","countdownarrow",
				},
			},
		},
        events = {
			-- Decimation Blade
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 99352,
				execute = {
					{
						"quash","bladecd",
						"alert","bladecd",
						"alert","decimationbladewarn",
                        "alert","decimationbladecast",
					},
				},
			},
            -- Decimation Strike
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 99405,
                execute = {
                    {
                        "resetalertcounter","decimatingstrikecd",
                        "set",{strikecount = "1"},
                        "quash","decimationbladecast",
                        "alert","decimationbladedur",
                        "alert","decimatingstrikecd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 99405,
                execute = {
                    {
                        "quash","decimatingstrikecd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 99353,
                execute = {
                    {
                        "set",{strikecount = "INCR|1"},
                    },
                    {
                        "expect",{"<strikecount>","<=","<decimatingstrikemax>"},
                        "alert","decimatingstrikecd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_MISSED",
                spellname = 99353,
                execute = {
                    {
                        "set",{strikecount = "INCR|1"},
                    },
                    {
                        "expect",{"<strikecount>","<=","<decimatingstrikemax>"},
                        "alert","decimatingstrikecd",
                    },
                },
            },
			-- Inferno Blade
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 99350,
				execute = {
					{
						"quash","bladecd",
						"alert","bladecd",
						"alert","infernobladewarn",
                        "alert","infernobladecast",
					},
				},
			},
            -- Inferno Strike
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 99350,
                execute = {
                    {
                        "resetalertcounter","infernostrikecd",
                        "set",{strikecount = "1"},
                        "quash","infernobladecast",
                        "alert","infernobladedur",
                        "alert","infernostrikecd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 99350,
                execute = {
                    {
                        "quash","infernostrikecd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 101002,
                execute = {
                    {
                        "set",{strikecount = "INCR|1"},
                    },
                    {
                        "expect",{"<strikecount>","<=","7"},
                        "alert","infernostrikecd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_MISSED",
                spellname = 101002,
                execute = {
                    {
                        "set",{strikecount = "INCR|1"},
                    },
                    {
                        "expect",{"<strikecount>","<=","7"},
                        "alert","infernostrikecd",
                    },
                },
            },
			-- Shards of Torment
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 99259,
				execute = {
					{
                        "quash","shardcd",
						"alert","shardcd",
						"alert","shardwarn",
					},
				},
			},
			-- Torment
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {99256,100230,100231,100232},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
                        "expect",{"#11#",">=","&stacks|tormentwarn&"},
						"set",{tormenttext = format("%s (%s) on %s!",SN[99256],"#11#",L.alert["YOU"])},
						"quash", "tormentwarn",
						"alert","tormentwarn",
					},
				},
			},
            -- Tormented
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 99403,
                execute = {
                    {
                        "radar","tormentedradar",
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{tormentedtext = format(L.alert["%s (%s)"],SN[99257],L.alert["YOU"])},
                        "quash","tormentedcd",
                        "alert","tormentedcd",
                        "alert","tormentedwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 99403,
                execute = {
                    {
                        "removeradar",{"tormentedradar", player = "#5#"},
                    },
                },
            },
            
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REFRESH",
                spellname = 99403,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "quash","tormentedcd",
                        "alert","tormentedcd",
                        "alert","tormentedwarn",
                    },
                },
            },
			-- Countdown heroic
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 99516,
				execute = {
					{
                        "expect",{"#4#","==","&playerguid&"},
                        "insert",{"countdownunits",L.alert["YOU"]},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "insert",{"countdownunits","#5#"},
                    },
                    {
                        "raidicon","countdownicon",
                        "expect",{"&listsize|countdownunits&","==","1"},
						"scheduletimer",{"countdowntimer",1},
                        "quash","countdowncd",
                        "alert","countdowncd",
					},
                    {
                        "expect",{"&listsize|countdownunits&","==","<countdownmax>"},
                        "canceltimer","countdowntimer",
                        "alert","countdownwarn",
                    },
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{countdownother = "#5#"},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"announce","countdownsay",
						"alert","countdownself",
						"scheduletimer",{"firearrow",0.2},
					},
				},
			},
			-- Countdown removed
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 99516,
				execute = {
					{
						"removeraidicon","#5#",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","countdownself",
						"removearrow","<countdownother>",
					},
				},
			},
            -- Melee swing speed debuff on Baleroc
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
                        "expect",{"&npcid|#4#&","==","53494"},
                        "set",{
                            decimatingstrikecd = "<decimatingstrikecddebuff>",
                            infernostrikecd = "<infernostrikecddebuff>"
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
                        "expect",{"&npcid|#4#&","==","53494"},
                        "set",{
                            decimatingstrikecd = "<decimatingstrikecdnodebuff>",
                            infernostrikecd = "<infernostrikecdnodebuff>",
                        },
                    },
                },
            },
		},
        
    }

	DXE:RegisterEncounter(data)
end


-------------------------------
-- MAJORDOMO FANDRAL STAGHELM
-------------------------------
do
	local data = {
		version = 14,
		key = "Staghelm",
		zone = L.zone["Firelands"],
		category = L.zone["Firelands"],
		name = L.npc_firelands["Majordomo Staghelm"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Fandral Staghelm.blp",
		triggers = {
			scan = {
				52571, -- Majordomo Fandral Staghelm
			},
		},
		onactivate = {
			tracing = {52571,powers={true}}, -- Majordomo Fandral Staghelm
			tracerstart = true,
			combatstop = true,
			defeat = 52571,
		},
		userdata = {
            -- Timers
            seedtime = 0,

            -- Texts
			adrenalinetext = "",
			form = "",
            orbtext = "",
		},
		onstart = {
            {
                "alert","enragecd",
            },
        },
		
        filters = {
            bossemotes = {
                catemote = {
                    name = "Cat transformation",
                    pattern = "transforms into a %[Cat%]",
                    hasIcon = true,
                    texture = ST[98374],
                    hide = true,
                },
                schorpionemote = {
                    name = "Scorpion transformation",
                    pattern = "transforms into a %[Scorpion%]",
                    hasIcon = true,
                    texture = ST[98379],
                    hide = true,
                },
            },
        },
        windows = {
			proxwindow = true,
			proxrange = 42,
			proxoverride = true,
            nodistancecheck = true,
		},
        radars = {
            seedradar = {
                varname = SN[98450],
                type = "circle",
                player = "#5#",
                range = 20,
                mode = "avoid",
                color = "GOLD",
                icon = ST[98450],
            },
        },
        
        grouping = {
            {
                general = true,
                alerts = {"enragecd"},
            },
            {
                name = format("|cffffd700%s|r |cffffffffform|r","Cat"),
                icon = ST[98374],
                alerts = {"catwarn","adrenalinewarn","jumpcd","jumpselfwarn","leapingflamesselfwarn","seedswarn","seedsselfwarn"},
            },
            {
                name = format("|cffffd700%s|r |cffffffffform|r","Scorpion"),
                icon = ST[98379],
                alerts = {"scorpionwarn","cleavecd","orbswarn","orbsdur","orbselfwarn"},
            },
        },
        
		alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time = 600,
                flashtime = 30,
                color1 = "RED",
                icon = ST[12317],
            },
            -- Cat Form
			catwarn = {
				varname = format(L.alert["%s Warning"],SN[98374]),
				type = "simple",
				text = format(L.alert["%s"],SN[98374]),
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[98374],
				sound = "ALERT1",
			},
            -- Scorpion Form
			scorpionwarn = {
				varname = format(L.alert["%s Warning"],SN[98379]),
				type = "simple",
				text = format(L.alert["%s"],SN[98379]),
				time = 3,
				flashtime = 3,
				color1 = "BROWN",
				icon = ST[98379],
				sound = "ALERT2",
			},
			adrenalinewarn = {
				varname = format(L.alert["%s Warning"],SN[97238]),
				type = "simple",
				text = "<adrenalinetext>",
				time = 2,
				flashtime = 2,
				color1 = "YELLOW",
				icon = ST[97238],
				sound = "ALERT5",
			},
			orbswarn = {
				varname = format(L.alert["%s Warning"],SN[98451]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[98451]),
				time = 4,
				flashtime = 4,
				color1 = "ORANGE",
				icon = ST[98451],
				sound = "ALERT2",
			},
			orbsdur = {
				varname = format(L.alert["%s Duration"],SN[98451]),
				type = "dropdown",
				text = format(L.alert["%s disappear"],SN[98451]),
				time = 60,
				flashtime = 10,
				color1 = "ORANGE",
				icon = ST[98451],
			},
			seedswarn = {
				varname = format(L.alert["%s Warning"],SN[98450]),
				type = "simple",
				text = format(L.alert["%s"],SN[98450]),
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[98450],
				sound = "ALERT2",
			},
			seedsselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[98450]),
				type = "dropdown",
				text = format(L.alert["%s on %s"],SN[98450],L.alert["YOU"]),
				time = "<seedtime>",
				flashtime = 10,
				color1 = "PURPLE",
                color2 = "RED",
				icon = ST[98450],
				-- sound = "ALERT10",
                sound = "runout",
                audiocd = true,
			},
			jumpselfwarn = {
				varname = format(L.alert["%s at me Warning"],SN[100207]),
				type = "simple",
				text = format(L.alert["%s at %s"],SN[100207],L.alert["YOU"]),
				time = 3,
				flashtime = 3,
				color1 = "ORANGE",
				icon = ST[100207],
				sound = "ALERT12",
				flashscreen = true,
                emphasizewarning = true,
			},
			jumpcd = {
				varname = format(L.alert["%s CD"],SN[98535]),
				type = "centerpopup",
				text = format(L.alert["Next %s"],SN[98535]),
				time = "<abilitycd>",
				color1 = "ORANGE",
				icon = ST[98535],
				sound = "ALERT7",
			},
			cleavecd = {
				varname = format(L.alert["%s CD"],SN[100213]),
				type = "centerpopup",
				text = format(L.alert["Next %s"],SN[100213]),
				time = "<abilitycd>",
				color1 = "YELLOW",
				icon = ST[100213],
				sound = "ALERT7",
			},
            -- Leaping Flames
            leapingflamesselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[98535]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[98535],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[98535],
                throttle = 2,
            },
            -- Burning Orb
            orbselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[98584]),
                type = "simple",
                text = "<orbtext>",
                time = 1,
                stacks = 4,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[98584],
            },
		},
		events = {
			-- Burning Orbs
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 98451,
				execute = {
					{
                        "quash","cleavecd",
						"alert","orbswarn",
						"schedulealert",{"orbsdur",4}
					},
				},
			},
			-- Searing Seeds
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 98450,
				execute = {
					{
                        "quash","jumpcd",
						"alert","seedswarn",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 98450,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{seedtime = "&playerdebuffdur|"..SN[98450].."&"},
						"alert","seedsselfwarn",
					},
                    {
                        "radar","seedradar",
                    },
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 98450,
                execute = {
                    {
                        "removeradar",{"seedradar", player = "#5#"},
                    },
                },
            },
            
			-- Leaping Flames
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 98476,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","jumpselfwarn",
					},
				},
			},
			-- Cat Form
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 98374,
				srcnpcid = 52571, -- Staghelm
				execute = {
					{
						"set",{
							abilitycd = {16.75, 15, 13.8, 12.8, 9.6, 9.5, 7.4, 8.3, 7.3, 6.2, 6.3, 6.3, 5.3, 4,2, 5.2, 5.2, 4.2, 3.2, loop = false, type = "series"},
                            form = "kitty",
						},
						"quash","cleavecd",
						"alert","catwarn",
						"alert","jumpcd",
					},
				},
			},
			-- Scorpion Form
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 98379,
				srcnpcid = 52571, -- Staghelm
				execute = {
					{
						"set",{
                            abilitycd = {16.75, 15, 13,8, 12.8, 9.6, 9.5, 7.4, 8.3, 7.3, 6.2, 6.3, 6.3, 5.3, 4,2, 5.2, 5.2, 4.2, 3.2, loop = false, type = "series"},
							form = "scorpion",
						},
						"quash","jumpcd",
						"alert","scorpionwarn",
						"alert","cleavecd",
					},
				},
			},
			-- Adrenaline
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 97238,
				srcnpcid = 52571, -- Staghelm
				execute = {
					{
						"set",{adrenalinetext = format(L.alert["%s"],SN[97238])},
						"alert","adrenalinewarn",
						"invoke",{
							{
								"expect",{"<form>","==","kitty"},
								"quash","jumpcd",
                                "alert","jumpcd",
							},
							{
								"expect",{"<form>","==","scorpion"},
								"quash","cleavecd",
                                "alert","cleavecd",
							},
						},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 97238,
				srcnpcid = 52571, -- Staghelm
				execute = {
					{
						"set",{adrenalinetext = format(L.alert["%s (%s)"],SN[97238],"#11#")},
						"alert","adrenalinewarn",
						"invoke",{
							{
								"expect",{"<form>","==","kitty"},
								"quash","jumpcd",
                                "alert","jumpcd",
							},
							{
								"expect",{"<form>","==","scorpion"},
								"quash","cleavecd",
                                "alert","cleavecd",
							},
						},
					},
				},
			},
            -- Leaping Flames
            {
                type = "combatevent",
                eventtype = "SPELL_PERIODIC_DAMAGE",
                spellname = 98535,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","leapingflamesselfwarn",
                    },
                },
            },
            -- Burning Orb            
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 98584,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "expect",{"#11#",">=","&stacks|orbselfwarn&"},
                        "set",{orbtext = format(L.alert["%s (%s) on %s!"],SN[98584],"#11#",L.alert["YOU"])},
                        "alert","orbselfwarn",
                    },
                },
            },
		},
        
    }

	DXE:RegisterEncounter(data)
end


------------------------
-- RAGNAROS
------------------------
do
	local data = {
		version = 36,
		key = "Ragnaros",
		zone = L.zone["Firelands"],
		category = L.zone["Firelands"],
		name = L.npc_firelands["Ragnaros"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Ragnaros.blp",
        advanced = {
            delayWipe = 1,
        },
		triggers = {
			scan = {
				52409 , -- Ragnaros
			},
		},
		onactivate = {
			tracing = {52409 }, -- Ragnaros
            phasemarkers = {
                {
                    {0.7,"Phase 2","At 70% of Ragnaros' HP starts the 1st Intermission followed by the Phase 2."},
                    {0.40, "Phase 3","At 40% of Ragnaros' HP starts the 2nd Intermission followed by the Phase 3."},
                    {0.1, "Defeated","At 10% of his HP, Ragnaros is defeated!", 10},
                    {0.1, "Phase 4","At 10% of his HP, Ragnaros stands up and Phase 4 begins.", 20},
                },
            },
			tracerstart = true,
			combatstop = true,
			defeat = {52409,L.chat_firelands["^Too soon!"]},
		},
		userdata = {
			-- Timers
            trapcd = {15, 25, 26, 30, loop = false, type = "series"},
			smashcd = 30,
			flamescd = {45, 40, loop = false, type = "series"},
			wrathcd = {5, 37, 30, loop = false, type = "series"},
			empowercd = {68.3, 56, loop = false, type = "series"},
			rootscd = {53, 56, loop = false, type = "series"},
            dreadflamecd = {34, 40, 35, 30, 25, 20, 15, loop = false, type = "series"},
            
            -- Texts
            heattext = "",
			woundtext = "",
            woundselftext = "",
			engulfingspecial = "",
            superheatedselftext = "",
            phasetext = "",
            intermissiontext = "",
            flamestext = "",
            flamescdtext = format(L.alert["Next %s"],SN[100172]),
            
            -- Switches
            flameswarned = "no",
			seedwarned = "no",
			meteorwarned = "no",
			phaseactivated = "no",
            intermission1warned = "no",
            intermission2warned = "no",
            intermission2triggered = "no",
            
            -- Counters
            phase = 1,
			intermissioncount = 0,
            sonscount = 8,
            
            -- Report
            meteor1guid = "",
            meteor2guid = "",
            meteor1attacker = "",
            meteor2attacker = "",
            meteor1spellid = "",
            meteor2spellid = "",
            meteor1spellname = "",
            hammersidetext = "",
            hammersideicon = "",
            meteor2spellname = "",
            skipmeteor = "no",
            testtext = "",
		},
		onstart = {
			{
				"set",{
					phase = 1,
                    intermissioncount = 0,
				},
                "alert","enragecd",
				"alert","smashcd",
				"alert","trapcd",
				"alert","handcd",
				"alert","wrathcd",
                "repeattimer",{"checkhp", 1},
			},
            {
                "expect",{"&difficulty&",">=","3"},
                "set",{
                    flamescd = {45,60, loop = false, type = "series"},
                    flamescdtext = format(L.alert["Next %s"],SN[100171]),
                },
            },
		},
        
        announces = {
			-- Magma Trap
            trapsay = {
				type = "SAY",
                subtype = "self",
                spell = 98159,
				msg = format(L.alert["%s on Me"],SN[98159]).."!",
                icon = ST[101233],
			},
			heatsay = {
				type = "SAY",
                subtype = "self",
                spell = 100981,
				msg = format(L.alert["%s on Me"],SN[100981]).."!",
			},
			fixatesay = {
				type = "SAY",
                subtype = "self",
                spell = 99849,
				msg = format(L.alert["%s on Me"],SN[99849]).."!",
			},
            meteorsay = {
                type = "SAY",
                subtype = "self",
                spell = 99267,
                icon = ST[99268],
                msg = format(L.alert["%s on Me"],SN[99267]).."!",
            },
            meteorknockbackraid = {
                varname = "%s knockback source",
                type = "RAID",
                subtype = "spell",
                spell = 99268,
                msg = "<testtext>",
                throttle = true,
            }
		},
		raidicons = {
			trapmark = {
                varname = format("%s {%s}",SN[98159],"ABILITY_TARGET_HARM"),
				type = "FRIENDLY",
				persist = 6,
				reset = 5,
                unit = "#5#",
				icon = 1,
				total = 1,
                texture = ST[101233],
			},
			heatmark = {
                varname = format("%s {%s}",SN[100981],"PLAYER_DEBUFF"),
				type = "MULTIFRIENDLY",
				persist = 10,
				reset = 9,
				unit = "#5#",
				icon = 2,
				total = 2,
                texture = ST[100981],
			},
            meteormark = {
                varname = format("%s {%s}",SN[100989],"ABILITY_TARGET_HARM"),
                type = "MULTIENEMY",
                persist = 15,
                unit = "#4#",
                icon = 3,
                total = 4,
                texture = ST[100989],
            },
		},
		filters = {
            bossemotes = {
                trapemote = { -- OK
                    name = "Magma Trap",
                    pattern = "casts %[Magma Trap%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[101233],
                },
                smashemote = { -- OK
                    name = "Sulfuras Smash",
                    pattern = "begins to cast %[Sulfuras Smash%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[100258],
                },
                splittingblowemote = { -- OK
                    name = "Splitting Blow",
                    pattern = "begins to cast %[Splitting Blow%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[98953],
                },
                emergeemote = { -- OK
                    name = "Emerge",
                    pattern = "is about to Emerge",
                    hasIcon = false,
                    hide = true,
                    texture = ST[20568],
                },
                engulfingflamesemote = {
                    name = "Engulfing Flames",
                    pattern = "begins to cast %[Engulfing Flames%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[100172],
                },
                worldinflamesemote = {
                    name = "World in Flames",
                    pattern = "begins to cast %[World In Flames%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[100171],
                },
                dreadflameemote = {
                    name = "Dreadflame",
                    pattern = "casts %[Dreadflame%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[100941],
                },
                empsulfurasemote = {
                    name = "Empowered Sulfuras",
                    pattern = "begins to cast %[Empower Sulfuras%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[100997],
                },
                heatemote = {
                    name = "Blazing Heat",
                    pattern = "You are about to burst into",
                    hasIcon = true,
                    hide = true,
                    texture = ST[100460],
                },
            },
        },
        counters = {
            sonscounter = {
                variable = "sonscount",
                label = "Sons of Flame",
                value = 8,
                minimum = 0,
                maximum = 8,
            },
        },
		phrasecolors = {
            {"Son[s]? of Flame left","WHITE"},
            {"FRONT","RED"},
            {"MIDDLE","ORANGE"},
            {"BACK","YELLOW"},
        },
        misc = {
            args = {
                flamescountdownhc = {
                    name = format(L.chat_firelands["Show |T%s:16:16|t |cffffd600Engulfing Flames|r countdown on Heroic difficulty."],ST[100172]),
                    type = "toggle",
                    order = 1,
                    default = true,
                },
            },
        },
        windows = {
			proxwindow = true,
			proxrange = 6,
			proxoverride = true,
		},
		grouping = {
            {
                general = true,
                alerts = {"enragecd","phasewarn","woundwarn","woundselfwarn","smashcd","smashwarn",
                },
            },
            {
                phase = 1,
                alerts = {"handcd","wrathcd","wrathwarn","trapcd","trapwarn","trapclosewarn","trapself",},
            },
            {
                phase = format("|cffffd700Intermission|r |cffffffffPhase|r"),
                alerts = {"intermissionsoonwarn","splitcast","hammersidewarn","intermissionduration","sonkilledwarn","heatwarn","heatselfwarn"},
            },
            {
                phase = 2,
                alerts = {"seedcd","seedwarn","flamescd","flameswarn","flamesduration","worldinflamesduration",},
            },
            {
                phase = 3,
                alerts = {"meteorcd","meteorwarn","meteorselfwarn","fixateselfwarn"},
            },
            {
                phase = 4,
                alerts = {"frostcd","frostwarn","rootscd","rootswarn","rootsduration","empowercd","empowerwarn","empowerdur","dreadflameselfwarn","dreadflamecd","dreadflamewarn","cloudburstcd","cloudburstwarn","superheatedselfwarn"},
            },
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                -- text = L.alert["Berserk"],
                text = format(L.alert["%s"], SN[12317]),
                time = 1080,
                flashtime = 30,
                color1 = "RED",
                icon = ST[12317],
            },
            -- Phase
            intermissionduration = {
				varname = format(L.alert["Intermission Duration"]),
				type = "dropdown",
				text = "<intermissiontext>",
                time = 57, -- 45,
				time10h = 57, -- 48
				time25h = 57, -- 48
                time2 = 14.1,
				flashtime = 10,
				color1 = "TURQUOISE",
                icon = ST[11242],
                behavior = "singleton",
			},
            phasewarn = {
                varname = format(L.alert["Phase Warning"]),
                type = "simple",
                text = "<phasetext>",
                time = 3,
                flashtime = 3,
                color1 = "TURQUOISE",
                color2 = "CYAN",
                sound = "ALERT1",
                icon = ST[11242],
            },
            intermissionsoonwarn = {
                varname = format(L.alert["Intermission soon Warning"]),
                type = "simple",
                text = format(L.alert["Intermission %s soon ..."],"&sum|<intermissioncount>|1&"),
                time = 3,
                flashtime = 3,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            -- Hammer side
            hammersidewarn = {
                varname = format(L.alert["%s Side Warning"],SN[98951]),
                type = "simple",
                text = "<hammersidetext>",
                time = 1,
                color1 = "ORANGE",
                sound = "None",
                icon = "<hammersideicon>",
                texture = ST[98953],
            },
            -- Sons of Flame killed
            sonkilledwarn = {
                varname = format(L.alert["%s Warning"],"Son of Flame killed"),
                type = "simple",
                text = "<sonstext>",
                time = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[2894],
            },
            
            
            ----------------------
            ----- All Phases -----
            ----------------------
            -- Burning Wound
			woundwarn = {
				varname = format(L.alert["%s Warning"],SN[101238]),
				type = "simple",
				text = "<woundtext>",
				time = 3,
                stacks = 4,
				color1 = "BLACK",
				sound = "MINORWARNING",
				icon = ST[101238],
			},
            woundselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[101238]),
				type = "simple",
				text = "<woundselftext>",
				time = 3,
                stacks = 4,
				color1 = "BLACK",
				sound = "ALERT10",
				icon = ST[101238],
			},
            -- Sulfuras Smash
            smashcd = {
				varname = format(L.alert["%s CD"],SN[100258]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100258]),
				time = "<smashcd>",
				flashtime = 5,
				color1 = "BROWN",
				icon = ST[100258],
			},
            smashwarn = {
				varname = format(L.alert["%s Warning"],SN[100258]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[100258]),
				time = 2.5,
				flashtime = 2.5,
				color1 = "BROWN",
				icon = ST[100258],
				sound = "ALERT2",
			},
            -------------------
            ----- Phase 1 -----
            -------------------
            -- Hand of Ragnaros
            handcd = {
				varname = format(L.alert["%s CD"],SN[100383]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100383]),
				time = 26,
				flashtime = 5,
				color1 = "BLUE",
				icon = ST[100383],
                throttle = 6,
                behavior = "overwrite",
			},
            -- Wrath of Ragnaros
            wrathcd = {
				varname = format(L.alert["%s CD"],SN[100115]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100115]),
				time = "<wrathcd>",
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[100115],
			},
            wrathwarn = {
				varname = format(L.alert["%s Warning"],SN[100115]),
				type = "simple",
				text = format(L.alert["%s"],SN[100115]),
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[100115],
				sound = "ALERT4",
				throttle = 1,
			},
            -- Magma Trap
			trapcd = {
				varname = format(L.alert["%s CD"],SN[101233]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[101233]),
				time = "<trapcd>",
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[101233],
			},
            trapwarn = {
				varname = format(L.alert["%s Warning"],SN[101233]),
				type = "simple",
                text = format("%s on <%s>!",SN[101233],"#5#"),
				text2 = format(L.alert["%s Casting"],SN[101233]),
				time = 3,
				color1 = "ORANGE",
				-- sound = "ALERT1",
				icon = ST[101233],
			},
			trapself = {
				varname = format(L.alert["%s on me Warning"],SN[101233]),
				type = "simple",
				text = format("%s on %s!",SN[101233],L.alert["YOU"]),
				time = 3,
				color1 = "ORANGE",
				sound = "ALERT12",
				icon = ST[101233],
				flashscreen = true,
                emphasizewarning = true,
			},
            trapclosewarn = {
                varname = format(L.alert["%s near me Warning"],SN[101233]),
                type = "simple",
                text = format(L.alert["%s near %s - MOVE AWAY!"],SN[101233],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[101233],
            },
            -------------------
            ----- Phase 2 -----
            -------------------
            -- Molten Seed
			seedcd = {
				varname = format(L.alert["%s CD"],SN[98333]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[98333]),
				time = 60,
				time2 = 22,
				time3 = 16,
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[98333],
			},
			seedwarn = {
				varname = format(L.alert["%s Warning"],SN[98333]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[98333]),
				time = 12,
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[98333],
			},
            -- Engulfing Flames
			flamescd = {
				varname = format(L.alert["%s CD"],SN[100172]),
				type = "dropdown",
				text = "<flamescdtext>",
				time = "<flamescd>",
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[100172],
			},
            flameswarn = {
				varname = format(L.alert["%s Warning"],SN[100172]),
				type = "simple",
				text = "<flamestext>",
				time = 1,
				color1 = "YELLOW",
				icon = ST[100172],
                enabled = false,
			},
            flamesduration = {
                varname = format(L.alert["%s Duration"],SN[100172]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[100172]),
                time10n = 3,
                time25n = 3,
                time10h = 2.5,
                time25h = 2.5,
                color1 = "RED",
                sound = "None",
                icon = ST[100172],
            },
            worldinflamesduration = {
                varname = format(L.alert["%s Duration"],SN[100171]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[100171]),
                time = 11.6,
                flashtime = 2,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "None",
                icon = ST[100171],
            },
            -------------------
            ----- Phase 3 -----
            -------------------
			-- Living Meteor
			meteorcd = {
				varname = format(L.alert["%s CD"],SN[100989]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100989]),
				time = 45,
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[100989],
				behavior = "overwrite",
			},
            meteorwarn = {
				varname = format(L.alert["%s Warning"],SN[100989]),
				type = "simple",
				text = format(L.alert["%s on <%s>"],SN[100989],"#5#"),
				time = 3,
				color1 = "ORANGE",
				sound = "ALERT1",
				icon = ST[100989],
			},
            meteorselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[100989]),
                type = "simple",
                text = format(L.alert["%s on %s!"],SN[100989],L.alert["YOU"]),
                time = 3,
                color1 = "ORANGE",
                sound = "RUNAWAY",
                icon = ST[100989],
                emphasizewarning = true,
            },
            fixateselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[99849]),
				type = "simple",
				text = format("%s on %s!",SN[99849],L.alert["YOU"]),
				time = 3,
				flashtime = 3,
				color1 = "RED",
				sound = "ALERT12",
				icon = ST[99849],
				flashscreen = true,
                emphasizewarning = true,
			},
            ------------------------------
            ----- Intermission Phase -----
            ------------------------------
            -- Splitting Blow
            splitcast = {
                varname = format(L.alert["%s Cast"],SN[98953]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[98953]),
                time = 8,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[98953],
            },          
            -- Sons of Flame Dead
            
            -- Blazing Heat
            heatwarn = {
				varname = format(L.alert["%s Warning"],SN[100981]),
				type = "simple",
				text = "<heattext>",
				time = 3,
				color1 = "RED",
				sound = "ALERT1",
				icon = ST[100981],
			},
			heatselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[100981]),
				type = "centerpopup",
				text = format("%s on %s!",SN[100981],L.alert["YOU"]),
				time = 13,
				flashtime = 13,
				color1 = "RED",
				sound = "ALERT12",
				icon = ST[100981],
				flashscreen = true,
                emphasizewarning = true,
			},
			----------------------------
            ----- Phase 4 (heroic) -----
            ----------------------------
            -- Breadth of Frost
			frostcd = {
				varname = format(L.alert["%s CD"],SN[100479]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100479]),
				time = 45,
                time2 = 19,
				flashtime = 5,
				color1 = "CYAN",
				icon = ST[100479],
			},
			frostwarn = {
				varname = format(L.alert["%s Warning"],SN[100479]),
				type = "simple",
				text = format(L.alert["%s"],SN[100479]),
				time = 3,
				flashtime = 3,
				color1 = "CYAN",
				sound = "ALERT2",
				icon = ST[100479],
			},
            -- Entrapping Roots
			rootscd = {
				varname = format(L.alert["%s CD"],SN[100646]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100646]),
				time = "<rootscd>",
				flashtime = 5,
				color1 = "GREEN",
				icon = ST[100646],
			},
			rootswarn = {
				varname = format(L.alert["%s Warning"],SN[100646]),
				type = "simple",
				text = format(L.alert["%s"],SN[100646]),
				time = 3,
				flashtime = 3,
				color1 = "LIGHTGREEN",
				sound = "ALERT3",
				icon = ST[100646],
			},
            rootsduration = {
                varname = format(L.alert["%s Duration"],SN[100653]),
                type = "centerpopup",
                text = format(L.alert["%s ends"],SN[100653]),
                time = 10,
                color1 = "LIGHTGREEN",
                sound = "None",
                icon = ST[100653],
                audiocd = true,
            },
            -- Empowered Sulfuras
			empowercd = {
				varname = format(L.alert["%s CD"],SN[100997]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[100997]),
				time = "<empowercd>",
				flashtime = 10,
				color1 = "ORANGE",
				icon = ST[100997],
			},
			empowerwarn = {
				varname = format(L.alert["%s Warning"],SN[100997]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[100997]),
				time = 5,
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[100997],
				sound = "ALERT1",
			},
			empowerdur = {
				varname = format(L.alert["%s Duration"],SN[100997]),
				type = "centerpopup",
				text = format(L.alert["%s ends"],SN[100997]),
				time = 10,
				flashtime = 10,
				color1 = "ORANGE",
                color2 = "RED",
				icon = ST[100997],
			},
            -- Dreadflame
            dreadflameselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[100941]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[100941],L.alert["YOU"]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT10",
                icon = ST[100941],
                throttle = 2,
                emphasizewarning = {2,0.5},
            },
            dreadflamecd = {
                varname = format(L.alert["%s CD"],SN[100675]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[100675]),
                time = "<dreadflamecd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[100675],
                throttle = 2,
            },
            dreadflamewarn = {
                varname = format(L.alert["%s Warning"],SN[100675]),
                type = "simple",
                text = format(L.alert["%s"],SN[100675]),
                time = 1,
                color1 = "RED",
                sound = "ALERT8",
                icon = ST[100675],
                throttle = 2,
            },
            -- Cloudburst
            cloudburstcd = {
                varname = format(L.alert["%s CD"],SN[100758]),
                type = "dropdown",
                text = format(L.alert["New %s"],SN[100758]),
                time = 37,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[100758],
            },
            cloudburstwarn = {
                varname = format(L.alert["%s Warning"],SN[100758]),
                type = "simple",
                text = format(L.alert["New: %s"],SN[100758]),
                time = 1,
                color1 = "LIGHTBLUE",
                sound = "ALERT9",
                icon = ST[100758],
            },
            superheatedselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[100594]),
				type = "simple",
				text = "<superheatedselftext>",
				time = 3,
                throttle = 2,
                stacks = 15,
				color1 = "ORANGE",
				sound = "ALERT10",
				icon = ST[100594],
                flashscreen = true,
                emphasizewarning = true,
			},
		},
		timers = {
			seedreset = {
				{
					"set",{seedwarned = "no"},
				},
			},
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","75"},
                    "expect",{"<intermission1warned>","==","no"},
                    "set",{intermission1warned = "yes"},
                    "alert","intermissionsoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","45"},
                    "expect",{"<intermission2warned>","==","no"},
                    "set",{intermission2warned = "yes"},
                    "alert","intermissionsoonwarn",
                },
                {
                    "expect",{"<intermission1warned>","==","yes"},
                    "expect",{"<intermission2warned>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
            phase4start = {
                {
                    "alert",{"frostcd", time = 2},
                    "alert","empowercd",
                    "alert","rootscd",
                    "alert","phasewarn",
                    "alert","dreadflamecd",
                    "alert","cloudburstcd",
                },
            },
            confirmmeteor1 = {
                {
                    "set",{testtext = format("%s knocked %s %s back using %s (%s)","<meteor1attacker>","&getraidtargetchatbyguid|<meteor1guid>&","Living Meteor","<meteor1spellname>","<meteor1spellid>")},
                    "announce","meteorknockbackraid",
                },
            },
            confirmmeteor2 = {
                {
                    "set",{testtext = format("%s knocked %s %s back using %s (%s)","<meteor2attacker>","&getraidtargetchatbyguid|<meteor2guid>&","Living Meteor","<meteor2spellname>","<meteor2spellid>")},
                    "announce","meteorknockbackraid",
                },
            },
		},
		events = {
            ----------------------
            ----- All Phases -----
            ----------------------
			-- Burning Wound (on tanks)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 101238,
				execute = {
					{
						"expect",{"#11#",">=","&stacks|woundwarn&"},
                        "expect",{"#4#","~=","&playerguid&"},
						"set",{woundtext = format(L.alert["%s (%s) on <%s>"],SN[101238],"#11#","#5#")},
						"alert","woundwarn",
					},
                    {
						"expect",{"#11#",">=","&stacks|woundselfwarn&"},
                        "expect",{"#4#","==","&playerguid&"},
						"set",{woundselftext = format(L.alert["%s (%s) on %s"],SN[101238],"#11#",L.alert["YOU"])},
						"alert","woundselfwarn",
					},
				},
			},
            -- Sulfuras Smash
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 100258,
				execute = {
					{
						"quash","smashcd",
						"alert","smashwarn",
						"alert","smashcd",
					},
				},
			},
            -------------------
            ----- Phase 1 -----
            -------------------
			-- Hand of Ragnaros
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 100383,
                srcisnpctype = true,
				execute = {
					{
						"alert","handcd",
					},
				},
			},
            -- Wrath of Ragnaros
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[98259]},
                        "expect",{"#1#","find","boss"},
                        "quash","wrathcd",
						"alert","wrathwarn",
						"alert","wrathcd",
                    },
                },
            },
            -- Magma Trap
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 98164,
				execute = {
					{
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","trapself",
                        "announce","trapsay",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "expect",{"&getdistance|#4#&","<=", 10},
                        "alert","trapclosewarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "expect",{"&getdistance|#4#&",">", 10},
                        "alert","trapwarn",
                    },
                    {
                        "raidicon","trapmark",
						"alert","trapcd",
					},
				},
			},
			-------------------
            ----- Phase 2 -----
            -------------------
			-- Molten Seed
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					{
						"expect",{"#2#","==",SN[98498]}, --"Molten Seed"
                        "expect",{"#1#","find","boss"},
						"quash","seedwarn",
						"alert","seedwarn",
                        "quash","seedcd",
						"alert","seedcd",
					},
				},
			},
            -- Engulfing Flames
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 100172, -- 99172
				execute = {
					{
						"expect",{"&difficulty&","<","3"},
						"quash","flamescd",
						"alert","flamescd",
					},
                    {
						"expect",{"&difficulty&","<","3",
                             "OR","&itemvalue|flamescountdownhc&","==","true"}, --10n&25n
                        "quash","flamesduration",
                        "alert","flamesduration",
					},
				},
			},
            -- World in Flames
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 100171,
                execute = {
                    {
                        "quash","flamescd",
						"alert","flamescd",
                        "alert","worldinflamesduration",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = {
                    99172, -- normal 10
                    100176, -- heroic 10
                    100175, -- normal 25
                    100177, -- heroic 25
                },
                execute = {
                    {
                        "set",{flamestext = format(L.alert["%s in the FRONT !"],SN[100172])},
                        "alert","flameswarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = {
                    99235, -- normal 10
                    100178, -- heroic 10 & normal 25
                    100180, -- heroic 25
                },
                execute = {
                    {
                        "set",{flamestext = format(L.alert["%s in the MIDDLE !"],SN[100172])},
                        "alert","flameswarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = {
                    99236, -- normal 10
                    100182, -- heroic 10
                    100181, -- normal 25
                    100183, -- heroic 25
                },
                execute = {
                    {
                        "set",{flamestext = format(L.alert["%s in the BACK !"],SN[100172])},
                        "alert","flameswarn",
                    },
                },
            },
            -------------------
            ----- Phase 3 -----
            -------------------
            -- Meteor Summon
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 99267,
                execute = {
                    {
                        "alert","meteorcd",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","meteorselfwarn",
                        "announce","meteorsay",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
						"alert","meteorwarn",
                    },
                },
            },
            
			-- Meteor fixate
			{
				type = "event",
				event = "UNIT_AURA",
				execute = {
                    {
                        "expect",{"<intermission2warned>","==","yes"},
                        "expect",{"#1#","==","player"},
                        "invoke",{
                            {
                                "expect",{"&playerdebuff|"..SN[99849].."&","==","true"},
                                "expect",{"<meteorwarned>","==","no"},
                                "alert","fixateselfwarn",
                                "announce","fixatesay",
                                "set",{meteorwarned = "yes"},
                            },
                            {
                                "expect",{"&playerdebuff|"..SN[99849].."&","==","false"},
                                "expect",{"<meteorwarned>","==","yes"},
                                "set",{meteorwarned = "no"},
                            },
                        },
                    },
				},
			},
            ------------------------------
            ----- Intermission Phase -----
            ------------------------------
            -- Splitting Blow
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 100885,
				execute = {
					{
						"batchquash",{"smashcd","trapcd","flamescd","seedcd","handcd","wrathcd"},
                        "alert","splitcast",
                        "set",{intermissioncount = "INCR|1"},
						"set",{
                            phasetext = format(L.alert["Intermission %s"],"<intermissioncount>"),
                            intermissiontext = format(L.alert["Phase %s"],"&sum|<phase>|1&"),
                            phaseactivated = "no",
                            sonscount = 8,
                        },
                        "alert","intermissionduration",
                        "alert","phasewarn",
                        "counter","sonscounter",
					},
				},
			},
            -- Splitting Blow (west side)
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = {98951, 100883, 100884, 100885},
                execute = {
                    {
                        "set",{
                            hammersidetext = "Left side",
                            hammersideicon = "Interface\\ICONS\\misc_arrowleft.blp"
                        },
                        "alert","hammersidewarn",
                    },
                },
            },
            -- Splitting Blow (east side)
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = {98953, 100880, 100881, 100882},
                execute = {
                    {
                        "set",{
                            hammersidetext = "Right side",
                            hammersideicon = "Interface\\ICONS\\misc_arrowright.blp"
                        },
                        "alert","hammersidewarn",
                    },
                },
            },
            -- Splitting Blow (center)
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = {98952, 100877, 100878, 100879},
                execute = {
                    {
                        "set",{
                            hammersidetext = "Center",
                            hammersideicon = "Interface\\ICONS\\misc_arrowlup.blp"
                        },
                        "alert","hammersidewarn",
                    },
                },
            },
            
			-- Blazing Heat
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 100981,
				srcisnpctype = true,
				execute = {
					{
						"raidicon","heatmark",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"set",{heattext = format(L.alert["%s on <%s>"],SN[100981],"#5#")},
						"alert","heatwarn",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","heatselfwarn",
						"announce","heatsay",
					},
				},
			},
			-- Blazing Heat removed
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 100981,
				srcisnpctype = false,
				execute = {
					{
						"removeraidicon","#5#",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","heatselfwarn",
					},
				},
			},
            ----------------------------
            ----- Phase 4 (heroic) -----
            ----------------------------
			
            -- Breadth of Frost
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 100479,
				execute = {
					{
						"quash","frostcd",
						"alert","frostcd",
						"alert","frostwarn",
					},
				},
			},
			-- Entrapping Roots
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 100646,
				execute = {
					{
						"quash","rootscd",
						"alert","rootscd",
						"alert","rootswarn",
					},
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 100653,
                execute = {
                    {
                        "quash","rootsduration",
                        "alert","rootsduration",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 100653,
                execute = {
                    {
                        "quash","rootsduration",
                    },
                },
            },
			-- Empower Sulfuras
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 100604,
				execute = {
					{
						"quash","empowercd",
						"alert","empowercd",
						"alert","empowerwarn",
						"schedulealert",{"empowerdur",5},
					},
				},
			},
            -- Dreadflame
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 100941,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","dreadflameselfwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#5#","==","100675"},
                        "expect",{"#1#","find","boss"},
                        "alert","dreadflamecd",
                        "alert","dreadflamewarn",
                    },
                },
            },
            -- Superheated
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 100594,
                execute = {
                    {
                        "expect",{"#11#",">=","&stacks|superheatedselfwarn&"},
                        "expect",{"#4#","==","&playerguid&"},
						"set",{superheatedselftext = format(L.alert["%s (%s) on %s"],SN[100594],"#11#",L.alert["YOU"])},
						"alert","superheatedselfwarn",
                    },
                },
            },
            -- Cloudburst
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 100758,
                execute = {
                    {
                        "quash","cloudburstcd",
                        "alert","cloudburstwarn",
                    },
                },
            },
            
            
            -------------------------
            ----- Phase Changes -----
            -------------------------
			-- Yells
			{
				type = "event",
				event = "YELL",
				execute = {
                    -- Next Phase Activation Yells
					{
						"expect",{"#1#","find",L.chat_firelands["^Enough"]},
						"set",{
							phase = "INCR|1",
							phaseactivated = "yes",
						},
						"quash","intermissionduration",
					},
					{
						"expect",{"#1#","find",L.chat_firelands["^Fall to your knees"]},
						"set",{
							phase = "INCR|1",
							phaseactivated = "yes",
						},
						"quash","intermissionduration",
					},
					{
						"expect",{"#1#","find",L.chat_firelands["^Sulfuras will be your end"]},
						"set",{
							phase = "INCR|1",
							phaseactivated = "yes",
						},
						"quash","intermissionduration",
					},
                    -- Phase 2
					{
                        "expect",{"<phase>","==","2"},
                        "expect",{"<phaseactivated>","==","yes"},
                        "removephasemarker",{1,1},
                        "removecounter","sonscounter",
                        "invoke",{
							{
								"expect",{"&difficulty&","<","3"},
								"set",{
									smashcd = {15,40, loop = false, type = "series"},
								},
								"alert","smashcd",
								"alert","flamescd",
								"alert",{"seedcd",time = 2},
							},
							{
								"expect",{"&difficulty&",">=","3"},
								"set",{
									smashcd = {6,50.5,40, loop = false, type = "series"},
								},
								"alert","smashcd",
								"alert","flamescd",
								"alert",{"seedcd",time = 3},
							},
						},
						"set",{
							phaseactivated = "no",
                            phasetext = format(L.alert["Phase %s"],"<phase>"),
						},
                        "alert","phasewarn",
                    },
					-- Phase 3
                    {
						"expect",{"<phase>","==","3"},
						"expect",{"<phaseactivated>","==","yes"},
						"removephasemarker",{1,2},
                        "removecounter","sonscounter",
                        "set",{
							smashcd = {16,30, loop = false, type = "series"},
						},
                        "invoke",{
                            {
                                "expect",{"&difficulty&","<","3"},
                                "set",{flamescd = {35, 30, loop = false, type = "series"}},
                            },
                            {
                                "expect",{"&difficulty&",">=","3"},
                                "set",{flamescd = {30, loop = false, type = "series"}},
                            },
                        },
						"alert","smashcd",
						"alert","flamescd",
						"alert",{"meteorcd", time = 2},
						"set",{
							phaseactivated = "no",
                            phasetext = format(L.alert["Phase %s"],"<phase>"),
						},
                        "alert","phasewarn",
					},
                    {
						"expect",{"#1#","find",L.chat_firelands["^No, fiend"]},
						"set",{
							phase = "INCR|1",
							phaseactivated = "yes",
						},
					},
                    -- Defeat
                    {
                        "expect",{"&difficulty&","<=","2"},
                        "expect",{"#1#","find",L.chat_firelands["^Too soon"]},
                        "triggerdefeat",true,
                    },
				},
			},
            -- Phase 4
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"&difficulty&",">=","3"},
                        "expect",{"#2#","==",SN[100312]},
                        "expect",{"#1#","find","boss"},
                        "set",{
                            intermissiontext = format(L.alert["Phase %s"],"&sum|<phase>|1&"),
                            phasetext = format(L.alert["Phase %s"],"&sum|<phase>|1&"),
                        },
                        "alert",{"intermissionduration", time = 2},
                        "batchquash",{"flamescd", "smashcd", "meteorcd"},
                        "scheduletimer",{"phase4start", 14.1},
                        "removephasemarker",{1,3},
                    },
                },
            },
            -- Son's of Flame death
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"#5#","==","Son of Flame"},
                        "set",{sonscount = "DECR|1"},
                        "invoke",{
                            {
                                "expect",{"<sonscount>","==","1"},
                                "set",{
                                    sonstext = format("%s Son of Flame left","<sonscount>"),
                                },
                                "alert","sonkilledwarn",
                            },
                            {
                                "expect",{"<sonscount>",">","1"},
                                "set",{
                                    sonstext = format("%s Sons of Flame left","<sonscount>"),
                                },
                                "alert","sonkilledwarn",
                            }
                        }
                    },
                },
            },  
            -- Record meteor guid
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 100990,
                execute = {
                    {
                        "raidicon","meteormark",
                    },
                    {
                        "expect",{"<meteor1guid>","==",""},
                        "set",{
                            meteor1guid = "#4#",
                            skipmeteor = "yes",
                        },
                    },
                    {
                        "expect",{"<meteor1guid>","~=",""},
                        "expect",{"<meteor2guid>","==",""},
                        "expect",{"<skipmeteor>","==","no"},
                        "set",{meteor2guid = "#4#"},
                    },
                    {
                        "set",{skipmeteor = "no"},
                    },
                },
            },
            -- Record last dmg
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                execute = {
                    {
                        "expect",{"#5#","==","Living Meteor"},
                        "expect",{"#4#","==","<meteor1guid>"},
                        "set",{
                            meteor1spellid = "#7#",
                            meteor1spellname = "#8#",
                            meteor1attacker = "#2#",
                        },
                    },
                    {
                        "expect",{"#5#","==","Living Meteor"},
                        "expect",{"#4#","==","<meteor2guid>"},
                        "set",{
                            meteor2spellid = "#7#",
                            meteor2spellname = "#8#",
                            meteor2attacker = "#2#",
                        },
                    },
                },
            },
            -- Schedule knockback report
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellid = 100277,
                execute = {
                    {
                        "expect",{"<meteor1guid>","==","#1#"},
                        "set",{
                            delayedmeteor2spellid = "<meteor2spellid>",
                            delayedmeteor2spellname = "<meteor2spellname>",
                            delayedmeteor2attacker = "<meteor2attacker>",
                        },
                        "scheduletimer",{"confirmmeteor1", 0.5},
                    },
                    {
                        "expect",{"<meteor2guid>","==","#1#"},
                        "set",{
                            delayedmeteor2spellid = "<meteor2spellid>",
                            delayedmeteor2spellname = "<meteor2spellname>",
                            delayedmeteor2attacker = "<meteor2attacker>",
                        },
                        "scheduletimer",{"confirmmeteor2", 0.5},
                    },
                },
            },
            -- Cancel knockback report
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 100567,
                execute = {
                    {
                        "expect",{"#4#","==","<meteor1guid>"},
                        "canceltimer","confirmmeteor1",
                    },
                    {
                        "expect",{"#4#","==","<meteor2guid>"},
                        "canceltimer","confirmmeteor2",
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
        version = 2,
        key = "firelandstrash",
        zone = L.zone["Firelands"],
        category = L.zone["Firelands"],
        name = "Trash",
        triggers = {
            scan = {
                53121, -- Flamewaker Cauterizer *
                53119, -- Flamewaker Forward Guard
                53120, -- Flamewaker Pathfinder
                
                54161, -- Flame Archon *
                54143, -- Molten Flamefather *
                
                53793, -- Harbinger of Flame *
                53795, -- Egg Pile
                53791, -- Blazing Monstrosity
                
                53096, -- Fire Turtle Hatchling
                53095, -- Matriarch Fire Turtle
                53094, -- Patriarch Fire Turtle
                
                53575, -- Lava Wielder
                
                53619, -- Druid of the Flame
                
                53616, -- Kar the Everburning
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {
            tormenttext = "",
            tormentwarntext = "",
            leaptext = "",
            leaptarget = "",
            reactivewarntext = "",
            reactivetext = "",
        },
        
        phrasecolors = {
            {"Flamewaker Cauterizer:","GOLD"},
            {"Patriarch Fire Turtle:","GOLD"},
            {"Kar the Everburning","GOLD"},
        },
        raidicons = {
            cauterizemark = {
                varname = format("%s {%s-%s}",SN[99618],"ENEMY_CAST","Flamewaker Cauterizer's"),
                type = "MULTIENEMY",
                persist = 60,
                unit = "#1#",
                reset = 55,
                icon = 1,
                total = 2,
                texture = ST[99618],
            },
            conduitmark = {
                varname = format("%s {%s}","Magma Conduit","NPC_ENEMY"),
                type = "MULTIENEMY",
                persist = 30,
                unit = "#4#",
                reset = 20,
                icon = 1,
                total = 2,
                texture = ST[100732],
            },
            barragemark = {
                varname = format("%s {%s-%s}",SN[100095],"ENEMY_CAST","Harbinger of Flame's"),
                type = "MULTIENEMY",
                persist = 5,
                unit = "#1#",
                reset = 5,
                icon = 1,
                total = 2,
                texture = ST[100095],
            },
            leapmark = {
                varname = format("%s {%s-%s}",SN[99629],"ENEMY_CAST","Druid of the Flame's"),
                type = "MULTIFRIENDLY",
                persist = 10,
                unit = "<leaptarget>",
                reset = 12,
                icon = 3,
                total = 2,
                texture = ST[99629],
            },
            lavaspawnmark = {
                varname = format("%s {%s}",SN[99575],"ABILITY_TARGET_HARM"),
                type = "MULTIENEMY",
                persist = 120,
                unit = "#4#",
                reset = 100,
                icon = 1,
                total = 2,
                texture = ST[99575],
            },
        },
        
        alerts = {
            -- Cauterize
            cauterizewarn = {
                varname = format(L.alert["%s Warning"],SN[99618]),
                type = "centerpopup",
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Flamewaker Cauterizer",SN[99618]),
                text = format(L.alert["%s - INTERRUPT"],SN[99618]),
                time = 1.96,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[99618],
            },
            -- Fiery Torment
            tormentwarn = {
                varname = format(L.alert["%s Warning"],SN[100802]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[100802]),
                time = 20,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "BEWARE",
                icon = ST[100802],
                throttle = 2,
            },
            tormentselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[100797]),
                type = "centerpopup",
                text = "<tormenttext>",
                warningtext = "<tormentwarntext>",
                time = 20,
                stacks = 5,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[100797],
                behavior = "overwrite",
                throttle = 1,
            },
            -- Earthquake
            earthquakewarn = {
                varname = format(L.alert["%s Warning"],SN[100724]),
                type = "centerpopup",
                text = format(L.alert["%s - STOP CASTING!"],SN[100724]),
                time = 1.5,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[100724],
            },
            earthquakecd = {
                varname = format(L.alert["%s CD"],SN[100724]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[100724]),
                time = 31,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[100724],
                tag = "#1#",
            },
            
            -- Magma Conduit
            conduitwarn = {
                varname = format(L.alert["%s Warning"],SN[100732]),
                type = "simple",
                text = format(L.alert["%s"],SN[100732]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT7",
                icon = ST[100732],
                throttle = 1,
            },
            conduitcd = {
                varname = format(L.alert["%s CD"],SN[100732]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[100732]),
                time = 25,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[100732],
                tag = "#1#",
            },
            -- Fieroclast Barrage
            barragewarn = {
                varname = format(L.alert["%s Warning"],SN[100095]),
                type = "simple",
                text = format(L.alert["%s - INTERRUPT"],SN[100095]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[100095],
            },
            -- Shell Shield
            shellshieldwarn = {
                varname = format(L.alert["%s Warning"],SN[100842]),
                type = "simple",
                text = format(L.alert["%s: %s"],"Patriarch Fire Turtle",SN[100842]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[100842],
            },
            -- Lava
            lavaselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[99510]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[99510],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[99510],
                throttle = 2,
            },
            -- Reckless Leap
            leapwarn = {
                varname = format(L.alert["%s Warning"],SN[99629]),
                type = "centerpopup",
                text = "<leaptext>",
                time = 3,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[99629],
            },
            -- Reactive Flames
            reactiveselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[99650]),
                type = "centerpopup",
                warningtext = "<reactivewarntext>",
                text = "<reactivetext>",
                time = 5,
                stacks = 3,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[99650],
                behavior = "overwrite",
            },
            -- Summon Volcano
            volcanowarn = {
                varname = format(L.alert["%s Warning"],SN[99571]),
                type = "simple",
                text = format(L.alert["%s summons %s"],"Kar the Everburning",SN[99571]),
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[99571],
            },
            -- Summon Lava Spawn
            lavaspawncd = {
                varname = format(L.alert["%s CD"],SN[99575]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[99575]),
                time = 16,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[99575],
            },
            lavaspawnwarn = {
                varname = format(L.alert["%s Warning"],SN[99575]),
                type = "simple",
                text = format(L.alert["New: %s"],"Lava Spawn"),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[99575],
            },
            
            
        },
        timers = {
            leaptimer = {
                {
                    "expect",{"&gettarget|#1#&","~=","nil"},
                    "expect",{"&gettarget|#1#&","~=","0"},
                    "set",{leaptarget = "&gettarget|#1#&"},
                    "invoke",{
                        {
                            "expect",{"<leaptarget>","==","&playername&"},
                            "set",{leaptext = format(L.alert["%s on %s"],SN[99629],L.alert["YOU"])},
                        },
                        {
                            "expect",{"<leaptarget>","~=","&playername&"},
                            "set",{leaptext = format(L.alert["%s on <%s>"],SN[99629],"<leaptarget>")},
                        },
                        {
                            "alert","leapwarn",
                            "raidicon","leapmark",
                        },
                    },
                },
            },
        },
        events = {
            -- Cauterize
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 99618,
                execute = {
                    {
                        "raidicon","cauterizemark",
                        "expect",{"#1#","==","&unitguid|target&",
                             "OR","#1#","==","&unitguid|focus&"},
                        "expect",{"&npcid|#1#&","==","53121"},
                        "alert","cauterizewarn",
                    },
                },
            },
            -- Fiery Torment
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = 100797,
                execute = {
                    {
                        "alert","tormentwarn",
                        
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 100802,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "expect",{"#11#",">=","&stacks|tormentselfwarn&"},
                        "set",{
                            tormenttext = format(L.alert["%s (%s) on %s"],SN[100797],"#11#",L.alert["YOU"]),
                            tormentwarntext = format(L.alert["%s (%s) on %s - GET AWAY!"],SN[100797],"#11#",L.alert["YOU"]),
                        },
                        "alert","tormentselfwarn",
                    },
                },
            },
            -- Earthquake
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 100724,
                execute = {
                    {
                        "alert","earthquakewarn",
                        "alert","earthquakecd",
                    },
                },
            },
            -- Magma Conduit
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 100732,
                execute = {
                    {
                        "alert","conduitwarn",
                        "alert","conduitcd",
                        "raidicon","conduitmark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","54143"},
                        "quash",{"conduitcd","#4#"},
                        "quash",{"earthquakecd","#4#"},
                    },
                },
            },
            -- Fieroclast Barrage
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 100095,
                execute = {
                    {
                        "alert","barragewarn",
                        "raidicon","barragemark",
                    },
                },
            },
            -- Shell Shield
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 100842,
                execute = {
                    {
                        "alert","shellshieldwarn",
                    },
                },
            },
            -- Lava
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 99510,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","lavaselfwarn",
                    },
                },
            },
            -- Reckless Leap
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 99629,
                execute = {
                    {
                        "scheduletimer",{"leaptimer", 0.3},
                    },
                },
            },
            -- Reactive Flames
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 99649,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "expect",{"#11#",">=","&stacks|reactiveselfwarn&"},
                        "set",{
                            reactivewarntext = format(L.alert["%s (%s) on %s - STOP DPS!"],SN[99650],"#11#",L.alert["YOU"]),
                            reactivetext = format(L.alert["%s (%s) on %s"],SN[99650],"#11#",L.alert["YOU"]),
                        },
                        "alert","reactiveselfwarn",
                    },
                },
            },
            -- Summon Volcano
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 99571,
                execute = {
                    {
                        "alert","volcanowarn",
                    },
                },
            },
            -- Summon Lava Spawn
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 99575,
                execute = {
                    {
                        "alert","lavaspawnwarn",
                        "alert","lavaspawncd",
                        "raidicon","lavaspawnmark",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- VOLCANUS
---------------------------------

do
    local data = {
        version = 1,
        key = "volcanustrash",
        zone = L.zone["Firelands"],
        category = L.zone["Firelands"],
        name = "Volcanus",
        advanced = {
            delayWipe = 40,
        },
        triggers = {
        },
        onactivate = {
            tracing = {
                53825, -- Sormented Protector
            },
            phasemarkers = {
                {
                    {0.26, "Sormented Protector forfeit"},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 53833, -- Volcanus
        },
        userdata = {
            
        },
        onstart = {
            {
                "alert","protectorspawncd",
                "alert",{"rootscd",time = 2},
            },
        },
        
        filters = {
            bossemotes = {
                treantsemote = {
                    name = "Burning Treants",
                    pattern = "^Burning Treants erupt from",
                    hasIcon = false,
                },
            },
        },
        
        alerts = {
            -- Sormented Protector spawn
            protectorspawncd = {
                varname = format(L.alert["%s CD"],"Sormented Protector spawn"),
                type = "centerpopup",
                text = format(L.alert["%s"],"Sormented Protector spawns"),
                time = 10,
                flashtime = 5,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[33831],
            },
            -- Volcanus spawn
            volcanusspawncd = {
                varname = format(L.alert["%s CD"],"Volcanus spawn"),
                type = "centerpopup",
                text = format(L.alert["%s"],"Volcanus spawns"),
                time = 34,
                flashtime = 5,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[2894],
                audiocd = true,
            },
            -- Smouldering Roots
            rootscd = {
                varname = format(L.alert["%s CD"],SN[100146]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[100146]),
                time = 23,
                time2 = 17,
                flashtime = 5,
                color1 = "BROWN",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[100146],
            },
            rootswarn = {
                varname = format(L.alert["%s Warning"],SN[100146]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[100146]),
                time = 2,
                color1 = "LIGHTGREEN",
                color2 = "RED",
                sound = "RUNAWAY",
                icon = ST[100146],
            },
            -- Blazing Stomp
            stompwarn = {
                varname = format(L.alert["%s Warning"],SN[100156]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[100156]),
                time = 3,
                color1 = "YELLOW",
                sound = "BEWARE",
                icon = ST[100156],
            },
            -- Burning Treants
            treantswarn = {
                varname = format(L.alert["%s Warning"],"Burning Treants"),
                type = "simple",
                text = format(L.alert["New: %s"],"Burning Treants"),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT9",
                icon = ST[100146],
            },
            
            
        },
        events = {
			-- Smouldering Roots
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 100146,
                execute = {
                    {
                        "quash","rootscd",
                        "alert","rootscd",
                        "alert","rootswarn",
                    },
                },
            },
            -- Blazing Stomp
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 100156,
                execute = {
                    {
                        "alert","stompwarn",
                    },
                },
            },
            -- Burning Treants
            {
                type = "event",
                event = "CHAT_MSG_RAID_BOSS_EMOTE",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_firelands["^Burning Treants erupt from"]},
                        "alert","treantswarn",
                    },
                },
            },
            -- Sormented Protector forfeits
            {
                type = "event",
                event = "CHAT_MSG_RAID_BOSS_EMOTE",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_firelands["^The fires consuming the"]},
                        "alert","volcanusspawncd",
                        "quash","rootscd",
                    },
                },
            },
            -- Volcanus appears
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_firelands["^Come, kindling"]},
                        "tracing",{53833},
                    },
                },
            },
            
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- Cinematics & Movies
---------------------------------
do
    DXE:RegisterCinematic("Firelands","Sulfuron Span",800,1)
    DXE:RegisterGossip("FL_BridgeActivation", "Pick up the orb and shake it", "Bridge activation")
end
