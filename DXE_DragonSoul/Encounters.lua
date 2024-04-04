local addon = DXE
local L,SN,ST,AL,AN,AT,TI,EJSN,EJST,CN = addon.L,addon.SN,addon.ST,addon.AL,addon.AN,addon.AT,addon.TI,addon.EJSN,addon.EJST,addon.CN
local LineAPI = addon.LineAPI
local ItemValue,ItemEnabled = addon.ItemValue,addon.ItemEnabled
local TraversOptions = addon.TraversOptions
local GetPlayerList = addon.GetPlayerNamedList
local ValuePriorityPlayer = addon.ValuePriorityPlayer
----------------------------
-- MORCHOK
----------------------------
do
	local data = {
		version = 10,
		key = "morchok",
		zone = L.zone["Dragon Soul"],
		category = L.zone["Dragon Soul"],
		name = L.npc_dragonsoul["Morchok"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Morchok.blp",
		advanced = {
            delayWipe = 1,
        },
        triggers = {
			scan = {
				55265, --Morchok
			},
		},
		onactivate = {
			tracing = {
				55265, --Morchok
			},
            phasemarkers = {
                {
                    {0.20,"Furious","At 20% HP, Morchok increases his attack speed by 30% and his damage by 20%."},
                    {0.90,"Split","At 90% HP, Morchok tears himself in half creating his twin Kohcrom.",3},
                    {0.90,"Split","At 90% HP, Morchok tears himself in half creating his twin Kohcrom.",4},
                },
                {
                    {0.20,"Furious","At 20% HP, Kohcrom increases his attack speed by 30% and his damage by 20%."},
                },
            },
			tracerstart = true,
			combatstop = true,
			defeat = 55265, --Morchok
		},
		userdata = {
			-- Texts
            crushtext = "",
            crushselftext = "",
            crushdurationtext = "",
			stomptag = "Morchok",
            
            -- Switches
            heroic = "false",
            postsplit = "no",
            orbemp = "default",
		},
        onstart = {
			{
                "alert","enragecd",
				"alert",{"bloodcd",time = 2},
				"alert",{"stompcd",text = 2},
                "repeattimer",{"checkhp", 1},
			},
		},
		
        filters = {
            bossemotes = {
                crystalemote = {
                    name = SN[103640],
                    pattern = "summons a Resonating Crystal",
                    hasIcon = false,
                    hide = true,
                    texture = ST[103640],
                },
                oozeemote = {
                    name = SN[103851],
                    pattern = "out of the black ooze",
                    hasIcon = false,
                    hide = true,
                    texture = ST[103851],
                },
            },
        },
		phrasecolors = {
            {":","WHITE"},
            {"Morchok","TURQUOISE"},
            {"Kohcrom","RED"},
        },
        misc = {
            name = format("|T%s:16:16|t %s & |T%s:16:16|t %s",ST[103414],L.chat_dragonsoul["Stomps"],ST[103640],L.chat_dragonsoul["Crystals"]),
            args = {
                showbothstomps = {
                    name = format(L.chat_dragonsoul["Show |T%s:16:16|t |cffffd600Stomps|r of both Morchok and Kohcrom."],ST[103414]),
                    type = "toggle",
                    order = 1,
                    default = false,
                },
                showbothcrystals = {
                    name = format(L.chat_dragonsoul["Show |T%s:16:16|t |cffffd600Resonating Crystals|r of both Morchok and Kohcrom."],ST[103640]),
                    type = "toggle",
                    order = 2,
                    default = false,
                },
                ignorefocusedstomps = {
                    name = format(L.chat_dragonsoul["Ignore the focused boss for |T%s:16:16|t |cffffd600Stomps|r."],ST[103414]),
                    type = "toggle",
                    order = 3,
                    default = false,
                },
                ignorefocusedcrystals = {
                    name = format(L.chat_dragonsoul["Ignore the focused boss for |T%s:16:16|t |cffffd600Resonating Crystals|r."],ST[103640]),
                    type = "toggle",
                    order = 4,
                    default = false,
                },
                empsinglecrystals = {
                    name = format(L.chat_dragonsoul["Emphasize |T%s:16:16|t |cffffd600Resonating Crystals|r |cff00c6ffWarning|r (temporary)"],ST[103640]),
                    type = "toggle",
                    desc = format(L.chat_dragonsoul["Emphasize |T%s:16:16|t |cffffd600Resonating Crystals Warning|r that comes after the last |T%s:16:16|t |cffffd600Stomp|r before the |T%s:16:16|t |cffffd600Black Blood Phase|r."],ST[103640],ST[103414],ST[103851]),
                    order = 5,
                    default = false,
                },
                reset_button = addon:genmiscreset(10,"showbothstomps","showbothcrystals","ignorefocusedstomps","ignorefocusedcrystals","empsinglecrystals"),
            },
        },
        ordering = {
            alerts = {"enragecd","crushwarn","crushduration","crushselfwarn",
                      "stompcd","stompwarn","orbwarn",
                      "bloodcd","fragmentswarn","bloodwarn","bloodduration","bloodselfwarn",
                      "furioussoonwarn","furiouswarn"},
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time10n = 420,
                time25n = 420,
                time10h = 420,
                time25h = 420,
                flashtime = 60,
                color1 = "RED",
                sound = "MINORWARNING",
                icon = ST[12317],
            },
            -- Furious
            furioussoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[103846]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[103846]),
                time = 1,
                color1 = "PEACH",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[103846],
            },
            furiouswarn = {
                varname = format(L.alert["%s Warning"],SN[103846]),
                type = "simple",
                text = format(L.alert["%s"],SN[103846]),
                time = 1,
                color1 = "ORANGE",
                sound = "BEWARE",
                icon = ST[103846],
                throttle = 2,
            },
            
            -------------
            -- Phase 1 --
            -------------
			-- Crush Armor
            crushwarn = {
				varname = format(L.alert["%s Warning"],SN[103687]),
				type = "simple",
				text = "<crushtext>",
				time = 3,
				color1 = "WHITE",
                sound = "ALERT8",
				icon = ST[103687],
                stacks = 2,
			},
            crushselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[103687]),
				type = "simple",
				text = "<crushselftext>",
				time = 3,
				color1 = "WHITE",
                sound = "ALERT8",
				icon = ST[103687],
                stacks = 2,
			},
            crushduration = {
                varname = format(L.alert["%s Duration"],SN[103687]),
                type = "centerpopup",
                text = "<crushdurationtext>",
                time = 20,
                color1 = "BROWN",
                sound = "None",
                icon = ST[103687],
                fillDirection = "DEPLETE",
                tag = "#4#",
                behavior = "overwrite",
            },
            
            -- Stomp
			stompwarn = {
				varname = format(L.alert["%s Warning"],SN[103414]),
				type = "simple",
				text = format("%s",SN[103414]),
                text2 = format("%s: %s","#2#",SN[103414]),
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
                sound = "ALERT1",
				icon = ST[103414],
			},
			stompcd = {
				varname = format(L.alert["%s CD"],SN[103414]),
				type = "dropdown",
				text = format(L.alert["%s CD"],SN[103414]),
                text2 = format(L.alert["Next %s"],SN[103414]),
				text3 = L.npc_dragonsoul["Morchok:"].." "..format(L.alert["%s CD"],SN[103414]),
				text4 = L.npc_dragonsoul["Kohcrom:"].." "..format(L.alert["Next %s"],SN[103414]),
                text5 = L.npc_dragonsoul["Morchok:"].." "..format(L.alert["Next %s"],SN[103414]),
                time = 12, -- next CD
                time2 = 12, -- init
                time3 = 18, -- post-phase
                time4 = 5, -- Kohcrom CD
				flashtime = 5,
				color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
				icon = ST[103414],
                sticky = true,
                tag = "<stomptag>",
			},
            -- Resonating Crystal
			orbwarn = {
				varname = format(L.alert["%s Duration"],SN[103640]),
				type = "centerpopup",
				warningtext = format("%s: %s","#2#",SN[103640]),
                warningtext2 = format("%s",SN[103640]),
                text = format("%s: %s explodes","#2#",L.chat_dragonsoul["Crystal"]),
                text2 = format("%s explodes",SN[103640]),
				time = 13, -- 12
				color1 = "MAGENTA",
				icon = ST[103640],
				sound = "ALERT2",
                emphasizewarning = "<orbemp>",
			},
            --------------------------------------
            -- Black Blood of the Earth (Phase) --
            --------------------------------------
			-- Black Blood of the Earth
            bloodcd = {
				varname = format(L.alert["%s CD"],"Black Blood Phase"),
				type = "dropdown",
                text = format(L.alert["Next %s"],"Black Blood Phase"),
				time = 95,
                time2 = 56,
				flashtime = 5,
				color1 = "BLACK",
                color2 = "GREY",
				icon = ST[103851],
			},
			bloodwarn = {
				varname = format(L.alert["%s Warning"],"Black Blood"),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[103851]),
				time = 2,
				flashtime = 3,
				color1 = "TURQUOISE",
				icon = ST[103851],
				sound = "RUNAWAY",
                fillDirection = "DEPLETE",
			},
			bloodduration = {
				varname = format(L.alert["%s Duration"],"Black Blood"),
				type = "centerpopup",
				text = format(L.alert["%s ends"],L.chat_dragonsoul["Black Blood"]),
				time = 15,
				flashtime = 5,
				color1 = "BLACK",
				icon = ST[103851],
			},
            bloodselfwarn = {
                varname = format(L.alert["%s on me Warning"],"Black Blood"),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[103785],L.alert["YOU"]),
                time = 1,
                color1 = "MIDGREY",
                sound = "ALERT10",
                icon = ST[103785],
                emphasizewarning = true,
                throttle = 1,
            },
            fragmentswarn = {
                varname = format(L.alert["%s Duration"],SN[103176]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[103176]),
                time = 5,
                color1 = "INDIGO",
                sound = "BEWARE",
                icon = ST[103176],
            },
            
		},
		timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","35"},
                    "alert","furioussoonwarn",
                    "canceltimer","checkhp",
                },
            },
            bloodtimer = {
                {
                    "quash","bloodwarn",
                    "alert","bloodduration",
                },
            },           
        },
        events = {
			-- Split (Heroic)
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellname = 109017,
				execute = {
					{
						"set",{heroic = "true"},
                        "set",{postsplit = "yes"},
                        "quash","stompcd",
                        "alert",{"stompcd",text = 5},
						"tracing",{
							55265, --Morchok
							57773, --Kohcrom
						},
                        "removephasemarker",{1,2},
                        "removephasemarker",{1,3},
					},
				},
			},
			-- Crush Armor on Tanks
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 103687,
				execute = {
					{
                        "expect",{"#4#","==","&playerguid&"},
						"expect",{"#11#",">=","&stacks|crushselfwarn&"},
                        
						"set",{
                            crushselftext = format("%s (%s) on <%s>",SN[103687],"#11#",L.alert["YOU"]),
                            crushdurationtext = format("%s (%s) on <%s>",SN[103687],"#11#",L.alert["YOU"]),
                        },
						"alert","crushselfwarn",
					},
                    {
                        "expect",{"#4#","~=","&playerguid&"},
						"expect",{"#11#",">=","&stacks|crushwarn&"},
						"set",{
                            crushtext = format("%s (%s) on <%s>",SN[103687],"#11#","#5#"),
                            crushdurationtext = format("%s (%s) on <%s>",SN[103687],"#11#","#5#")
                        },
						"alert","crushwarn",
                    },
                    {
                        "expect",{"#11#",">=","&stacks|crushduration&"},
                        "alert","crushduration",
                    },
				},
			},
			-- Stomp
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = {103414, 108571, 109033, 109034},
				execute = {
                    {
                        "expect",{"#2#","==",L.npc_dragonsoul["Morchok"]},
                        "expect",{"<postsplit>","==","no"},
                        "quash","stompcd",
                        "expect",{"&timeleft|bloodcd&",">","21.5"},
                        "alert","stompcd",
                    },
                    {
                        "expect",{"#2#","==",L.npc_dragonsoul["Morchok"]},
                        "expect",{"<postsplit>","==","yes"},
                        "quash",{"stompcd","Morchok"},
                        "invoke",{
                            {
                                "expect",{"&timeleft|bloodcd&",">","21.5"},
                                "alert",{"stompcd",text = 3},
                            },
                            {
                                "expect",{"&timeleft|bloodcd&",">","0",
                                    "AND","&timeleft|bloodcd&","<=","21.5"},
                                "expect",{"&itemvalue|empsinglecrystals&","==","true"},
                                "set",{orbemp = "true"},
                            },
                        }
                    },
                    {
                        "expect",{"#2#","==",L.npc_dragonsoul["Kohcrom"]},
                        "quash",{"stompcd","Kohcrom"},
                    },
                    {
						"expect",{"<postsplit>","==","no"},
						"alert","stompwarn",
					},
                    {
                        "expect",{"<postsplit>","==","yes"},
                        "invoke",{
                            {
                                "expect",{"&itemvalue|showbothstomps&","==","true"},
                                "alert",{"stompwarn",text = 2},
                            },
                            {
                                "expect",{"&itemvalue|showbothstomps&","==","false",
                                          "AND","&npcid|&unitguid|target&&","~=","55265",
                                          "AND","&npcid|&unitguid|target&&","~=","57773",
                                          "AND","&npcid|&unitguid|focus&&","~=","55265",
                                          "AND","&npcid|&unitguid|focus&&","~=","57773"},
                                "alert",{"stompwarn",text = 2},
                            },
                            {
                                "expect",{"&itemvalue|showbothstomps&","==","false"},
                                "expect",{"&unitguid|target&","==","#1#"},
                                "expect",{"&npcid|&unitguid|target&&","==","55265",
                                     "OR","&npcid|&unitguid|target&&","==","57773"},
                                "alert",{"stompwarn",text = 2},
                            },
                            {
                                "expect",{"&itemvalue|showbothstomps&","==","false"},
                                "expect",{"&unitguid|focus&","==","#1#",
                                    "AND","&unitguid|target&","~=","#1#"},
                                "expect",{"&itemvalue|ignorefocusedstomps&",  "==","false",
                                    "AND","&npcid|&unitguid|focus&&",         "==","55265",
                                     "OR","&npcid|&unitguid|focus&&",         "==","57773",
                                    "AND","&itemvalue|ignorefocusedstomps&",  "==","false"},
                                "alert",{"stompwarn",text = 2},
                            },
                        },
                    },
                    {
                        "expect",{"#2#","==",L.npc_dragonsoul["Morchok"]},
                        "expect",{"<postsplit>","==","yes"},
                        "expect",{"&timeleft|bloodcd&",">=","15.5"},
                        "set",{stomptag = "Kohcrom"},
                        "alert",{"stompcd",time = 4, text = 4},
                        "set",{stomptag = "Morchok"},
                    },
				},
			},
			-- Twilight Orb Summon
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellname = 103639,
				execute = {
					{
                        "expect",{"<postsplit>","==","no"},
						"alert",{"orbwarn",text = 2, warningtext = 2},
					},
                    {
                        "expect",{"<postsplit>","==","yes"},
                        "invoke",{
                            {
                                "expect",{"&itemvalue|showbothcrystals&","==","true"},
                                "alert","orbwarn",
                            },
                            {
                                "expect",{"&itemvalue|showbothcrystals&","==","false"},
                                "expect",{"&npcid|&unitguid|target&&","~=","55265",
                                          "AND","&npcid|&unitguid|target&&","~=","57773",
                                          "AND","&npcid|&unitguid|focus&&","~=","55265",
                                          "AND","&npcid|&unitguid|focus&&","~=","57773"},
                                "alert","orbwarn",
                            },
                            {
                                "expect",{"&itemvalue|showbothcrystals&","==","false"},
                                "expect",{"&unitguid|target&","==","#1#"},
                                "expect",{"&npcid|&unitguid|target&&","==","55265",
                                     "OR","&npcid|&unitguid|target&&","==","57773"},
                                "alert","orbwarn",
                            },
                            {
                                "expect",{"&itemvalue|showbothcrystals&","==","false"},
                                "expect",{"&unitguid|focus&","==","#1#",
                                    "AND","&unitguid|target&","~=","#1#"},
                                "expect",{"&itemvalue|ignorefocusedcrystals&","==","false",
                                    "AND","&npcid|&unitguid|focus&&",         "==","55265",
                                     "OR","&npcid|&unitguid|focus&&",         "==","57773",
                                    "AND","&itemvalue|ignorefocusedcrystals&","==","false"},
                                "alert","orbwarn",
                            },
                        },
					},
				},
			},
			-- Falling Fragments +stompcd after
            {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 103176,
				dstnpcid = 55265, -- once is enough
				execute = {
					{
                        "quash","stompcd",
                        "quash",{"stompcd","Morchok"},
                        "quash",{"stompcd","Kohcrom"},
						"alert","bloodcd",
                        "alert","fragmentswarn",
                        "scheduletimer",{"bloodtimer", 7},
					},
				},
			},
            -- Black Blood
			{
				type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 103851,
                srcnpcid = 55265, -- once is enough
				execute = {
					{
                        "quash","fragmentswarn",
						"alert","bloodwarn",
						"set",{orbemp = "default"},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 103851,
				dstnpcid = 55265, -- once is enough
				execute = {
					{
                        "expect",{"<postsplit>","==","no"},
                        "alert",{"stompcd",time = 3, text = 2},
					},
                    {
                        "expect",{"<postsplit>","==","yes"},
                        "alert",{"stompcd",time = 3, text = 5},
                    },
				},
			},
            -- Black Blood of the Earth
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 103785,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","bloodselfwarn",
                    },
                },
            },
            
            -- Furious
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 103846,
                execute = {
                    {
                        "alert","furiouswarn",
                        "removephasemarker",{1,1},
                    },
                },
            },
            
		},
	}

	DXE:RegisterEncounter(data)
end

----------------------------
-- WARLORD ZON'OZZ
----------------------------
do
	local data = {
		version = 13,
		key = "zonozz",
		zone = L.zone["Dragon Soul"],
		category = L.zone["Dragon Soul"],
		name = L.npc_dragonsoul["Warlord Zon'ozz"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Warlord Zonozz.blp",
		triggers = {
			scan = {
				55308, --Warlord Zon'ozz
			},
		},
		onactivate = {
			tracing = {
				55308, --Warlord Zon'ozz
			},
			tracerstart = true,
			combatstop = true,
			defeat = 55308,
		},
		userdata = {
            -- Timers
            voidcd = 36,
            enragecd = 360,
            draincd3 = 32.85,
            
            -- Texts
            angertext = "",
            angercdtext = format(L.alert["Next %s (1)"],SN[104543]),
            
            -- Switches
            phase = 1,
            voidcdoverridden = "no",
            pingpongcomplete = "no",
            
            -- Counters
            bouncecount = 0,
            
            -- Lists
            shadowunits = {type = "container", wipein = 3},            
        },
		onstart = {
			{
                "alert","enragecd",
				"alert",{"draincd",time = 2},
				"alert",{"voidcd",time = 2},
                "alert",{"shadowcd",time = 2},
                "alert",{"angercd",time = 2},
			},
            {
                "expect",{"&difficulty&",">=","3"}, -- HC
                "set",{
                    voidcd = 46,
                    draincd3 = 22.85,
                },
            },
		},
		
        announces = {
			shadowsay = {
				type = "SAY",
                subtype = "self",
                spell = 104600,
				msg = format(L.alert["%s on ME!"],SN[104600]),
			},
            pingpongcomplete = {
                varname = "%s complete",
                type = "RAID",
                subtype = "achievement",
                achievement = 6128,
                msg = format(L.alert["<DXE> Requirements for %s were met. You can kill the boss now."],AL[6128]),
                throttle = true,
            },
		},
		raidicons = {
			shadowicon = {
				varname = format("%s {%s}",SN[104600],"PLAYER_DEBUFF"),
				type = "MULTIFRIENDLY",
				persist = 10,
				reset = 2,
				unit = "#5#",
				icon = 1,
				total = 8,
                texture = ST[104600],
			},
		},
		windows = {
			proxwindow = true,
			proxrange = 30,
			proxoverride = true,
            nodistancecheck = true
		},
        radars = {
            shadowradar = {
                varname = SN[104600],
                type = "circle",
                player = "#5#",
                range = 10,
                mode = "avoid",
                icon = ST[104600],
            },
        },
        ordering = {
            alerts = {"enragecd","voidcd","voidwarn","bouncewarn","angercd","angerwarn","draincd","shadowcd","shadowwarn","shadowselfwarn","bloodwarn","bloodduration","activecd","pingpongphasewarn"},
        },        
		
        alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time = "<enragecd>",
                flashtime = 60,
                color1 = "RED",
                sound = "MINORWARNING",
                icon = ST[12317],
            },
            -------------
            -- Phase 1 --
            -------------
            -- Ping Pong Phase
            pingpongphasewarn = {
                varname = format(L.alert["%s Warning"],"Phase 1"),
                type = "simple",
                text = format(L.alert["%s"],"Phase 1"),
                time = 1,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[77487],
            },
            -- Void of the Unmaking
			voidcd = {
				varname = format(L.alert["%s Cooldown"],SN[104002]),
				type = "dropdown",
				text = format(L.alert["New %s"],SN[104002]),
				time = 90,
				time2 = 6,
                time3 = "<voidcd>",
				flashtime = 5,
				color1 = "MAGENTA",
				icon = ST[693],
			},
			voidwarn = {
				varname = format(L.alert["%s Warning"],SN[104002]),
				type = "centerpopup",
				text = format(L.alert["New: %s"],SN[104002]),
				time = 4,
				flashtime = 3,
				color1 = "MAGENTA",
				icon = ST[693],
				sound = "ALERT9",
				throttle = 1,
			},
            -- Ball bouncing
            bouncewarn = {
                varname = format(L.alert["%s Warning"],"Void Bounce"),
                type = "simple",
                text = format(L.alert["%s (%s)"],"Void Bounce","<bouncecount>"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[36473],
            },
            -- Focused Anger
            angercd = {
                varname = format(L.alert["%s CD"],SN[104543]),
                type = "centerpopup",
                text = "<angercdtext>",
                time = 6,
                time2 = 12,
                time3 = 5.88,
                flashtime = 5,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[104543],
                enabled = false,
            },
            angerwarn = {
                varname = format(L.alert["%s Warning"],SN[104543]),
                type = "simple",
                text = "<angertext>",
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[104543],
                enabled = false,
            },
            -- Psychic Drain
			draincd = {
				varname = format(L.alert["%s CD"],SN[104322]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[104322]),
                text2 = format(L.alert["%s CD"],SN[104322]),
				time = 21,
                time2 = 19,
                time3 = "<draincd3>",
				flashtime = 5,
				color1 = "BROWN",
                color2 = "RED",
				icon = ST[104322],
                sticky = true,
			},
            -- Disrupting Shadows
			shadowcd = {
				varname = format(L.alert["%s Cooldown"],SN[104600]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[104600]),
				time = 25,
                time2 = 24,
                time3 = 16,
				flashtime = 5,
				color1 = "PURPLE",
                color2 = "MAGENTA",
				sound = "MINORWARNING",
                icon = ST[104600],
                sticky = true,
			},
			shadowwarn = {
				varname = format(L.alert["%s Warning"],SN[104600]),
				type = "simple",
                text = format(L.alert["%s - DISPEL"],SN[104600]),
				time = 3,
				flashtime = 3,
				color1 = "MAGENTA",
				icon = ST[104600],
			},
			shadowselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[104600]),
				type = "simple",
				text = format(L.alert["%s on <%s>"],SN[104600],L.alert["YOU"]),
				time = 3,
				flashtime = 3,
				color1 = "PURPLE",
				icon = ST[104600],
				sound = "ALERT2",
                emphasizewarning = true,
			},
            -------------
            -- Phase 2 --
            -------------
            -- Black Blood of Go'rath
			bloodwarn = {
				varname = format(L.alert["%s Warning"],"Black Phase"),
				type = "simple",
				text = format(L.alert["%s"],"Black Phase"),
				time = 1,
				flashtime = 5,
				color1 = "WHITE",
				icon = ST[108794],
				sound = "BEWARE",
			},
            bloodduration = {
                varname = format(L.alert["%s Duration"],SN[104378]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[104378]),
                time = 30,
				flashtime = 5,
				color1 = "BLACK",
                color2 = "GREY",
                sound = "None",
                icon = ST[104378],
            },
            -- Active
            activecd = {
                varname = format(L.alert["%s Countdown"],"Zon'ozz active"),
                type = "centerpopup",
                text = format(L.alert["Warlord Zon'ozz active"],AT[6110]),
                time = 11,
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = AT[6110],
            },
            
		},
        timers = {
            phase1timer = {
                {
                    "expect",{"<phase>","==","2"},
                    "set",{phase = 1},
                    "quash","bloodduration",
                    "alert",{"shadowcd",time = 3},
                    "alert",{"draincd",time = 3},
                    "alert",{"angercd",time = 3},
                    "alert","pingpongphasewarn",
                },
            },
        },
		events = {
            -------------
            -- Phase 1 --
            -------------
            -- Void of the Unmaking summon
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					{
                        "expect",{"#5#","==","103946"}, -- new ID
                        "expect",{"#1#","find","boss"},
                        "quash","voidcd",
                        "alert","voidwarn",
                        "alert","voidcd",
                        "set",{bouncecount = 0},
					},
				},
			},
            -- Void Bounce
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 106836,
                dstnpcid = 55334,
                execute = {
                    {
                        "set",{bouncecount = "INCR|1"},
                        "alert","bouncewarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 106836,
                dstnpcid = 55334,
                execute = {
                    {
                        "set",{bouncecount = "INCR|1"},
                        "alert","bouncewarn",
                    },
                    {
                        "expect",{"<pingpongcomplete>","==","no"},
                        "expect",{"<bouncecount>","==","10"},
                        "set",{pingpongcomplete = "yes"},
                        "announce","pingpongcomplete",
                    },
                },
            },
            -- Focused Anger
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = {104543, 109409, 109410, 109411},
                execute = {
                    {
                        "set",{
                            angertext = format(L.alert["%s (1)"],SN[104543]),
                            angercdtext = format(L.alert["Next %s (2)"],SN[104543]),
                        },
                        "quash","angercd",
                        "alert","angercd",
                        "alert","angerwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellid = {104543, 109409, 109410, 109411},
                execute = {
                    {
                        "set",{
                            angertext = format(L.alert["%s (%s)"],SN[104543],"#11#"),
                            angercdtext = format(L.alert["Next %s (%s)"],SN[104543],"&sum|#11#|1&"),
                        },
                        "quash","angercd",
                        "alert","angercd",
                        "alert","angerwarn",
                    },
                },
            },
            -- Psychic Drain
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 104322,
				execute = {
					{
						"quash","draincd",
                        "alert",{"draincd",text = 2},
					},
				},
			},
            -- Disrupting Shadows
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {103434,104599,104600,104601},
				execute = {
					{
						"quash","shadowcd",
						"alert","shadowcd",
                        "alert","shadowwarn",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 104601,
				execute = {
					{
						"raidicon","shadowicon",
                        "radar","shadowradar",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"announce","shadowsay",
						"alert","shadowselfwarn",
					},
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 104601,
                execute = {
                    {
                        "removeraidicon","#5#",
                        "removeradar",{"shadowradar", player = "#5#"},
                    },
                },
            },
            
            -------------
            -- Phase 2 --
            -------------
			-- Black blood
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[109878]}, -- Zon’ozz Whisper: Phase
                        "expect",{"#1#","find","boss"},
                        "expect",{"<phase>","==","1"},
                        "set",{phase = 2},
						"quash","draincd",
                        "quash","shadowcd",
                        "quash","angercd",
                        "alert","bloodwarn",
                        "alert","bloodduration",
                        "alert","activecd",
                        "scheduletimer",{"phase1timer", 30},
                        "set",{enragecd = "&timeleft|enragecd&"},
                        "set",{enragecd = "INCR|5"},
                        "quash","enragecd",
                        "alert","enragecd",
                        "invoke",{
                            {
                                "expect",{"&timeleft|voidcd&","<","<voidcd>"},
                                "set",{voidcdoverridden = "yes"},
                                "quash","voidcd",
                                "alert",{"voidcd",time = 3},
                            },
                            {
                                "expect",{"<voidcdoverridden>","==","no"},
                                "expect",{"&timeleft|voidcd&",">=","<voidcd>"},
                                "settimeleft",{"voidcd","&sum|5|&timeleft|voidcd&&"},
                            },
                        },
                        "set",{voidcdoverridden = "no"},
                    },
                },
            },
			-- Zon'ozz catches the ball
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 104031,
				dstnpcid = 55308, --only on Zon'ozz
				execute = {
					{
                        "quash","draincd",
                        "quash","shadowcd",
                        "quash","angercd",
					},
				},
			},
            {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 104031,
				dstnpcid = 55308, --only on Zon'ozz
				execute = {
					{
                        "quash","draincd",
                        "quash","shadowcd",
                        "quash","angercd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

----------------------------
-- YOR'SAHJ THE UNSLEEPING
----------------------------
do
	local data = {
		version = 5,
		key = "yorsahj",
		zone = L.zone["Dragon Soul"],
		category = L.zone["Dragon Soul"],
		name = L.npc_dragonsoul["Yor'sahj the Unsleeping"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Yorsahj the Unsleeping.blp",
		advanced = {
            autosyncoptions = true,
        },
        triggers = {
			scan = {
				55312, --Yor'sahj
			},
		},
		onactivate = {
			
            tracing = {
                {unit = "boss", npcid = 55312}, -- Yor'sahj
			},
			tracerstart = true,
			combatstop = true,
			defeat = 55312,
		},
		userdata = {
			-- Timers
            slimecd = 90,
            searingcd = 7,
            acidcd = 8,
            
            -- Texts
            voidtext = "",
            slimetext = "",
            oozeswitchcolor = "",
            oozeswitchicon = "",
            oozeprioritiestext = "",
            
            -- Switches
            globulekilled = "no",
            slimetimerscheduled = "no",
            
            -- Lists
            bloodlist = {type = "container", wipein = 10},
            summonedcombo = "",
            absorbedcombo = "",
            
            -- Constants
            bloodmax = 3,
		},
		onstart = {
			{
                "expect",{"&difficulty&",">=","3"},
                "set",{
                    slimecd = 78,
                    bloodmax = 4,
                },
            },
            {
                "alert","enragecd",
				"alert",{"slimecd",time = 2},
                "scheduletimer",{"slimetimer", 22},
                "alert","voidcd",
			},
		},
        arrows = {
            purplearrow = {
                varname = format("%s","Purple Ooze"),
                unit = "player",
                persist = 15,
                action = "TOWARD",
                msg = L.alert["|cffa020f0Purple Ooze|r"],
                sound = "None",
                fixed = true,
                xpos = 0.57,
                ypos = 0.13,
                cancelrange = 30,
                range1 = 30,
                range2 = 40,
                range3 = 50,
                remote = true,
                texture = ST[104896],
            },
            greenarrow = {
                varname = format("%s","Green Ooze"),
                unit = "player",
                persist = 15,
                action = "TOWARD",
                msg = L.alert["|cff00ff00Green Ooze|r"],
                sound = "None",
                fixed = true,
                xpos = 0.22,
                ypos = 0.34,
                cancelrange = 30,
                range1 = 30,
                range2 = 40,
                range3 = 50,
                remote = true,
                texture = ST[104898],
            },
            yellowarrow = {
                varname = format("%s","Yellow Ooze"),
                unit = "player",
                persist = 15,
                action = "TOWARD",
                msg = L.alert["|cffffff00Yellow Ooze|r"],
                sound = "None",
                fixed = true,
                xpos = 0.37,
                ypos = 0.85,
                cancelrange = 30,
                range1 = 30,
                range2 = 40,
                range3 = 50,
                remote = true,
                texture = ST[104901],
            },
            bluearrow = {
                varname = format("%s","Blue Ooze"),
                unit = "player",
                persist = 15,
                action = "TOWARD",
                msg = L.alert["|cff3e9effBlue Ooze|r"],
                sound = "None",
                fixed = true,
                xpos = 0.71,
                ypos = 0.34,
                cancelrange = 30,
                range1 = 30,
                range2 = 40,
                range3 = 50,
                remote = true,
                texture = ST[104900],
            },
            redarrow = {
                varname = format("%s","Red Ooze"),
                unit = "player",
                persist = 15,
                action = "TOWARD",
                msg = L.alert["|cffff0000Red Ooze|r"],
                sound = "None",
                fixed = true,
                xpos = 0.37,
                ypos = 0.12,
                cancelrange = 30,
                range1 = 30,
                range2 = 40,
                range3 = 50,
                remote = true,
                texture = ST[104897],
            },
            blackarrow = {
                varname = format("%s","Black Ooze"),
                unit = "player",
                persist = 15,
                action = "TOWARD",
                msg = L.alert["|cffaaaaaaBlack Ooze|r"],
                sound = "None",
                fixed = true,
                xpos = 0.71,
                ypos = 0.65,
                cancelrange = 30,
                range1 = 30,
                range2 = 40,
                range3 = 50,
                remote = true,
                texture = ST[104894],
            },
        },
        filters = {
            bossemotes = {
                callemote = {
                    name = "Call Blood of Shu'ma",
                    pattern = "calls upon the",
                    hasIcon = false,
                    hide = true,
                    texture = "Interface\\Icons\\inv_ore_arcanite_01",
                },
            },
            raidwarnings = {
                oozeprioritiesrw = {
                    name = "Ooze Priorities",
                    pattern = "Switch to {",
                    hide = true,
                    texture = "Interface\\Icons\\inv_ore_arcanite_01",
                },
            },
        },
        announces = {
            oozepriorities_znone = {
                varname = "%s (Ooze Priorities)",
                type = "RAID_WARNING",
                subtype = "spell",
                spell = "No Switch",
                icon = ST[674],
                msg = "! NO SWITCH !",
                enabled = true,
                throttle = false,
            },
            oozepriorities_red = {
                varname = "%s (Ooze Priorities)",
                type = "RAID_WARNING",
                subtype = "spell",
                spell = "Switch to Red",
                icon = ST[104897],
                msg = "Switch to {cross} RED {cross}",
                enabled = true,
                throttle = false,
            },
            oozepriorities_yellow = {
                varname = "%s (Ooze Priorities)",
                type = "RAID_WARNING",
                subtype = "spell",
                spell = "Switch to Yellow",
                icon = ST[104901],
                msg = "Switch to {star} YELLOW {star}",
                enabled = true,
                throttle = false,
            },
            oozepriorities_purple = {
                varname = "%s (Ooze Priorities)",
                type = "RAID_WARNING",
                subtype = "spell",
                spell = "Switch to Purple",
                icon = ST[104896],
                msg = "Switch to {diamond} PURPLE {diamond}",
                enabled = true,
                throttle = false,
            },
            oozepriorities_blue = {
                varname = "%s (Ooze Priorities)",
                type = "RAID_WARNING",
                subtype = "spell",
                spell = "Switch to Blue",
                icon = ST[104900],
                msg = "Switch to {square} BLUE {square}",
                enabled = true,
                throttle = false,
            },
            oozepriorities_green = {
                varname = "%s (Ooze Priorities)",
                type = "RAID_WARNING",
                subtype = "spell",
                spell = "Switch to Green",
                icon = ST[104898],
                msg = "Switch to {triangle} GREEN {triangle}",
                enabled = true,
                throttle = false,
            },
            oozepriorities_black = {
                varname = "%s (Ooze Priorities)",
                type = "RAID_WARNING",
                subtype = "spell",
                spell = "Switch to Black",
                icon = ST[104894],
                msg = "Switch to {skull} BLACK {skull}",
                enabled = true,
                throttle = false,
            },
            comboinstructionsrw = {
                varname = "Ooze Priorities Instructions",
                type = "RAID_WARNING",
                msg = "<comboinstructionstext>",
                enabled = true,
                throttle = true,
            },
        },
        phrasecolors = {
            {"Red","RED"},
            {"Purple","PURPLE"},
            {"Green","LIGHTGREEN"},
            {"Blue","LIGHTBLUE"},
            {"Black","MIDGREY"},
            {"Yellow","YELLOW"},
            {"NA SEBE","GOLD"},
            {"HEAL STACKUJE","PURPLE"},
            {"MANA VOID","LIGHTBLUE"},
            {"ROZESTUPY","LIGHTGREEN"},
            {"ADDKY","MIDGREY"}
        },
        windows = {
			proxwindow = true,
			proxrange = 4,
			proxoverride = true,
            proxnoauto = true,
            proxnoautostart = true,
		},
        misc = {
            name = format("%s %s","|TInterface\\Icons\\inv_ore_arcanite_01:16:16|t",L.chat_dragonsoul["Ooze Priorities"]),
            args = {
                priority_distribution_header = {
                    name = L.chat_dragonsoul["Priority Distribution"],
                    type = "header",
                    order = 1,
                },
                priority_description = {
                    name = L.chat_dragonsoul[""],
                    type = "description",
                    order = 2,
                },
                priority_announcer = {
                    name = function() 
                        local player = ValuePriorityPlayer("misc","priority_distribution_mode","send")
                        if not player then
                            return format("|cffffff00%s|r (%s).",L.chat_dragonsoul["No announcer selected yet"],L.chat_dragonsoul["return to this tab later"])
                        else
                            return format(L.chat_dragonsoul["%s is the announcer."],CN[player])
                        end
                    end,
                    type = "description",
                    order = 3,
                    fontSize = "medium",
                },
                priority_distribution_mode = {
                    name = L.chat_dragonsoul["Priority Distribution Mode"],
                    type = "select",
                    values = {
                        send = "Send Ooze priorities to other DXE users in the raid.",
                        receive = "Receive Ooze priorities from the dedicated raid officer.",
                        self = "Trigger Ooze priorities set by you only for you.",
                        
                    },
                    width = "full",
                    default = "receive",
                    sync = true,
                    throttle = true,
                    order = 4,
                },
                normal_header = {
                    name = L.chat_dragonsoul["Normal"],
                    type = "header",
                    order = 5,
                },
                combo_normal_105420 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cff00ff00Green|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", purple = "|cffa020f0Purple|r", green = "|cff00ff00Green|r", blue = "|cff3399ffBlue|r"},
                    default = "green",
                    order = 6,
                },
                combo_normal_105435 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffff0000Red|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", green = "|cff00ff00Green|r", red = "|cffff0000Red|r", black = "|cffaaaaaaBlack|r"},
                    default = "green",
                    order = 7,
                },
                combo_normal_105436 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffffff00Yellow|r / |cffff0000Red|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", green = "|cff00ff00Green|r", yellow = "|cffffff00Yellow|r", red = "|cffff0000Red|r"},
                    default = "green",
                    order = 8,
                },
                combo_normal_105437 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffffff00Yellow|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", purple = "|cffa020f0Purple|r", yellow = "|cffffff00Yellow|r", blue = "|cff3399ffBlue|r"},
                    default = "yellow",
                    order = 9,
                },
                combo_normal_105439 = {
                    name = L.chat_dragonsoul["|cffffff00Yellow|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", yellow = "|cffffff00Yellow|r", black = "|cffaaaaaaBlack|r", blue = "|cff3399ffBlue|r"},
                    default = "yellow",
                    order = 10,
                },
                combo_normal_105440 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffff0000Red|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", purple = "|cffa020f0Purple|r", red = "|cffff0000Red|r",black = "|cffaaaaaaBlack|r"},
                    default = "purple",
                    order = 11,
                },
                normal_reset = addon:genmiscreset(12,"combo_normal_105420","combo_normal_105435","combo_normal_105436","combo_normal_105437","combo_normal_105439","combo_normal_105440"),
                heroic_header = {
                    name = L.chat_dragonsoul["Heroic"],
                    type = "header",
                    order = 30,
                },
                combo_heroic_105420 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cff00ff00Green|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", purple = "|cffa020f0Purple|r", green = "|cff00ff00Green|r", black = "|cffaaaaaaBlack|r", blue = "|cff3399ffBlue|r"},
                    default = "green",
                    order = 31,
                },
                combo_heroic_105435 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffff0000Red|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", green = "|cff00ff00Green|r", red = "|cffff0000Red|r", black = "|cffaaaaaaBlack|r", blue = "|cff3399ffBlue|r"},
                    default = "green",
                    order = 32,
                },
                combo_heroic_105436 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffffff00Yellow|r / |cffff0000Red|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", green = "|cff00ff00Green|r", yellow = "|cffffff00Yellow|r", red = "|cffff0000Red|r", black = "|cffaaaaaaBlack|r"},
                    default = "yellow",
                    order = 33,
                },
                combo_heroic_105437 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cff00ff00Green|r / |cffffff00Yellow|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", purple = "|cffa020f0Purple|r", green = "|cff00ff00Green|r", yellow = "|cffffff00Yellow|r", blue = "|cff3399ffBlue|r"},
                    default = "yellow",
                    order = 34,
                },
                combo_heroic_105439 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffffff00Yellow|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", purple = "|cffa020f0Purple|r", yellow = "|cffffff00Yellow|r", black = "|cffaaaaaaBlack|r", blue = "|cff3399ffBlue|r"},
                    default = "yellow",
                    order = 35,
                },
                combo_heroic_105440 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffffff00Yellow|r / |cffff0000Red|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Select the ooze to kill for this combination."],
                    type = "select",
                    values = {znone = "None", purple = "|cffa020f0Purple|r", yellow = "|cffffff00Yellow|r", red = "|cffff0000Red|r",black = "|cffaaaaaaBlack|r"},
                    default = "yellow",
                    order = 36,
                },
                heroic_reset = addon:genmiscreset(40,"combo_heroic_105420","combo_heroic_105435","combo_heroic_105436","combo_heroic_105437","combo_heroic_105439","combo_heroic_105440"),
                instructions_desc = {
                    type = "description",
                    name = L.chat_dragonsoul["Here you can edit instructions given to deal with the leftover combination of color buffs after killing one Ooze or after letting boss absorb all of the Oozes."],
                    order = 50,
                },
                
                ----------------------------------- 2 Oozes ----------------------------------
                instruction_header_2 = {
                    name = L.chat_dragonsoul["Dealing with a combination of |cffffffff2 Oozes|r"],
                    type = "header",
                    order = 1000,
                },
                instructions_2oozes_reset_en = addon:genmisclangreset(1001,"2 Oozes To %s","en","instructions_5","instructions_17","instructions_33","instructions_9","instructions_3","instructions_34","instructions_6","instructions_18","instructions_10","instructions_24","instructions_12","instructions_36","instructions_20","instructions_48"),
                instructions_2oozes_reset_cs = addon:genmisclangreset(1002,"2 Oozes To %s","cs","instructions_5","instructions_17","instructions_33","instructions_9","instructions_3","instructions_34","instructions_6","instructions_18","instructions_10","instructions_24","instructions_12","instructions_36","instructions_20","instructions_48"),
                instructions_5 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffffff00Yellow|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK & {diamond} HEALING DEBUFF",
                    default_cs = "{star} NA KOPU a {diamond} HEALING DEBUFF",
                    order = 1010,
                    width = "double",
                },
                instructions_5_reset_en = addon:genmisclangreset(1015,"%s","en","instructions_5"),
                instructions_5_reset_cs = addon:genmisclangreset(1016,"%s","cs","instructions_5"),
                instructions_17 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{diamond} HEALING DEBUFF & {skull} AOE ADDS",
                    default_cs = "{diamond} HEALING DEBUFF a {skull} ZPLOŠNIT ADDKY",
                    order = 1020,
                    width = "double",
                },
                instructions_17_reset_en = addon:genmisclangreset(1021,"%s","en","instructions_17"),
                instructions_17_reset_cs = addon:genmisclangreset(1022,"%s","cs","instructions_17"),
                instructions_33 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{diamond} HEALING DEBUFF & {square} MANA VOID",
                    default_cs = "{diamond} HEALING DEBUFF a {square} MANA VOIDA",
                    order = 1030,
                    width = "double",
                },
                instructions_33_reset_en = addon:genmisclangreset(1031,"%s","en","instructions_33"),
                instructions_33_reset_cs = addon:genmisclangreset(1032,"%s","cs","instructions_33"),
                instructions_9 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffff0000Red|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{cross} STACK & {diamond} HEALING DEBUFF",
                    default_cs = "{cross} NA KOPU a {diamond} HEALING DEBUFF",
                    order = 1040,
                    width = "double",
                },
                instructions_9_reset_en = addon:genmisclangreset(1041,"%s","en","instructions_9"),
                instructions_9_reset_cs = addon:genmisclangreset(1042,"%s","cs","instructions_9"),
                instructions_3 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cff00ff00Green|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE & {diamond} HEALING DEBUFF",
                    default_cs = "{triangle} ROZESTUPY a {diamond} HEALING DEBUFF",
                    order = 1050,
                    width = "double",
                },
                instructions_3_reset_en = addon:genmisclangreset(1055,"%s","en","instructions_3"),
                instructions_3_reset_cs = addon:genmisclangreset(1056,"%s","cs","instructions_3"),
                instructions_34 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE & {square} MANA VOID",
                    default_cs = "{triangle} ROZESTUPY a {square} MANA VOIDA",
                    order = 1060,
                    width = "double",
                },
                instructions_34_reset_en = addon:genmisclangreset(1065,"%s","en","instructions_34"),
                instructions_34_reset_cs = addon:genmisclangreset(1066,"%s","cs","instructions_34"),
                instructions_6 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffffff00Yellow|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE & {star} AOE OVERHEAL",
                    default_cs = "{triangle} ROZESTUPY a {star} PLOŠNÝ OVERHEAL",
                    order = 1070,
                    width = "double",
                },
                instructions_6_reset_en = addon:genmisclangreset(1075,"%s","en","instructions_6"),
                instructions_6_reset_cs = addon:genmisclangreset(1076,"%s","cs","instructions_6"),
                instructions_18 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE & {skull} AOE ADDS",
                    default_cs = "{triangle} ROZESTUPY a {skull} ZPLOŠNIT ADDKY",
                    order = 1080,
                    width = "double",
                },
                instructions_18_reset_en = addon:genmisclangreset(1085,"%s","en","instructions_18"),
                instructions_18_reset_cs = addon:genmisclangreset(1089,"%s","cs","instructions_18"),
                instructions_10 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffff0000Red|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE but {cross} CLOSE TO THE BOSS",
                    default_cs = "{triangle} ROZESTUPY ale {cross} BLÍZKO BOSSE",
                    order = 1090,
                    width = "double",
                },
                instructions_10_reset_en = addon:genmisclangreset(1095,"%s","en","instructions_10"),
                instructions_10_reset_cs = addon:genmisclangreset(1096,"%s","cs","instructions_10"),
                instructions_24 = {
                    name = L.chat_dragonsoul["|cffff0000Red|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{cross} STACK & {skull} AOE ADDS",
                    default_cs = "{cross} NA KOPU a {skull} ZPLOŠNIT ADDKY",
                    order = 1100,
                    width = "double",
                },
                instructions_24_reset_en = addon:genmisclangreset(1105,"%s","en","instructions_24"),
                instructions_24_reset_cs = addon:genmisclangreset(1106,"%s","cs","instructions_24"),
                instructions_12 = {
                    name = L.chat_dragonsoul["|cffffff00Yellow|r / |cffff0000Red|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK {cross} AOE HEALING",
                    default_cs = "{star} NA KOPU {cross} PLOŠNÝ HEAL",
                    order = 1110,
                    width = "double",
                },
                instructions_12_reset_en = addon:genmisclangreset(1115,"%s","en","instructions_12"),
                instructions_12_reset_cs = addon:genmisclangreset(1116,"%s","cs","instructions_12"),
                instructions_36 = {
                    name = L.chat_dragonsoul["|cffffff00Yellow|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK & {square} MANA VOID",
                    default_cs = "{star} NA KOPU a {square} MANA VOIDA",
                    order = 1120,
                    width = "double",
                },
                instructions_36_reset_en = addon:genmisclangreset(1125,"%s","en","instructions_36"),
                instructions_36_reset_cs = addon:genmisclangreset(1126,"%s","cs","instructions_36"),
                instructions_20 = {
                    name = L.chat_dragonsoul["|cffffff00Yellow|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK & {skull} AOE ADDS",
                    default_cs = "{star} NA KOPU a {skull} ZPLOŠNIT ADDKY",
                    order = 1130,
                    width = "double",
                },
                instructions_20_reset_en = addon:genmisclangreset(1135,"%s","en","instructions_20"),
                instructions_20_reset_cs = addon:genmisclangreset(1136,"%s","cs","instructions_20"),
                instructions_48 = {
                    name = L.chat_dragonsoul["|cff3399ffBlue|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{square} MANA VOID & {skull} AOE ADDS",
                    default_cs = "{square} MANA VOIDA a {skull} ZPLOŠNIT ADDKY",
                    order = 1140,
                    width = "double",
                },
                instructions_48_reset_en = addon:genmisclangreset(1145,"%s","en","instructions_48"),
                instructions_48_reset_cs = addon:genmisclangreset(1146,"%s","cs","instructions_48"),
                ----------------------------------- 3 Oozes ----------------------------------
                instruction_header_3 = {
                    name = L.chat_dragonsoul["Dealing with a combination of |cffffffff3 Oozes|r"],
                    type = "header",
                    order = 2000,
                },
                instructions_3oozes_reset_en = addon:genmisclangreset(2001,"3 Oozes To %s","en","instructions_13","instructions_21","instructions_37","instructions_7","instructions_19","instructions_25","instructions_35","instructions_49","instructions_14","instructions_22","instructions_38","instructions_26","instructions_42","instructions_50","instructions_28","instructions_52","instructions_56"),
                instructions_3oozes_reset_cs = addon:genmisclangreset(2002,"3 Oozes To %s","cs","instructions_13","instructions_21","instructions_37","instructions_7","instructions_19","instructions_25","instructions_35","instructions_49","instructions_14","instructions_22","instructions_38","instructions_26","instructions_42","instructions_50","instructions_28","instructions_52","instructions_56"),
                instructions_13 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffffff00Yellow|r / |cffff0000Red|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK {cross} DIRECT HEALING & {diamond} HEALING DEBUFF",
                    default_cs = "{star} NA KOPU {cross} DIRECT HEAL a {diamond} HEALING DEBUFF",
                    order = 2010,
                    width = "double",
                },
                instructions_13_reset_en = addon:genmisclangreset(2015,"%s","en","instructions_13"),
                instructions_13_reset_cs = addon:genmisclangreset(2016,"%s","cs","instructions_13"),
                instructions_21 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffffff00Yellow|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK {diamond} HEALING DEBUFF & {skull} KILL ADDS",
                    default_cs = "{star} NA KOPU {diamond} HEALING DEBUFF a {skull} ZABÍT ADDKY",
                    order = 2020,
                    width = "double",
                },
                instructions_21_reset_en = addon:genmisclangreset(2025,"%s","en","instructions_21"),
                instructions_21_reset_cs = addon:genmisclangreset(2026,"%s","cs","instructions_21"),
                instructions_37 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffffff00Yellow|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK {diamond} HEALING DEBUFF & {square} MANA VOID",
                    default_cs = "{star} NA KOPU {diamond} HEALING DEBUFF a {square} MANA VOIDA",
                    order = 2030,
                    width = "double",
                },
                instructions_37_reset_en = addon:genmisclangreset(2035,"%s","en","instructions_37"),
                instructions_37_reset_cs = addon:genmisclangreset(2036,"%s","cs","instructions_37"),
                instructions_7 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffffff00Yellow|r / |cff00ff00Green|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE {star} DIRECT HEALING & {diamond} HEALING DEBUFF",
                    default_cs = "{triangle} ROZESTUPY {star} DIRECT HEAL a {diamond} HEALING DEBUFF",
                    order = 2040,
                    width = "double",
                },
                instructions_7_reset_en = addon:genmisclangreset(2045,"%s","en","instructions_7"),
                instructions_7_reset_cs = addon:genmisclangreset(2046,"%s","cs","instructions_7"),
                instructions_19 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cff00ff00Green|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE {diamond} HEALING DEBUFF & {skull} KILL ADDS",
                    default_cs = "{triangle} ROZESTUPY {diamond} HEALING DEBUFF a {skull} ZABÍT ADDKY",
                    order = 2050,
                    width = "double",
                },
                instructions_19_reset_en = addon:genmisclangreset(2055,"%s","en","instructions_19"),
                instructions_19_reset_cs = addon:genmisclangreset(2056,"%s","cs","instructions_19"),
                instructions_25 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffff0000Red|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{cross} STACK {diamond} HEALING DEBUFF & {skull} KILL ADDS",
                    default_cs = "{cross} NA KOPU {diamond} HEALING DEBUFF a {skull} ZABÍT ADDKY",
                    order = 2060,
                    width = "double",
                },
                instructions_25_reset_en = addon:genmisclangreset(2065,"%s","en","instructions_25"),
                instructions_25_reset_cs = addon:genmisclangreset(2066,"%s","cs","instructions_25"),
                instructions_35 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cff00ff00Green|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE {diamond} HEALING DEBUFF & {square} MANA VOID",
                    default_cs = "{triangle} ROZESTUPY {diamond} HEALING DEBUFF a {square} MANA VOIDA",
                    order = 2070,
                    width = "double",
                },
                instructions_35_reset_en = addon:genmisclangreset(2075,"%s","en","instructions_35"),
                instructions_35_reset_cs = addon:genmisclangreset(2076,"%s","cs","instructions_35"),
                instructions_49 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{diamond} HEALING DEBUFF {square} MANA VOID & {skull} AOE ADDS",
                    default_cs = "{diamond} HEALING DEBUFF {square} MANA VOIDA a {skull} ZPLOŠNIT ADDKY",
                    order = 2080,
                    width = "double",
                },
                instructions_49_reset_en = addon:genmisclangreset(2085,"%s","en","instructions_49"),
                instructions_49_reset_cs = addon:genmisclangreset(2086,"%s","cs","instructions_49"),
                instructions_14 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffffff00Yellow|r / |cffff0000Red|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE but {cross} CLOSE TO THE BOSS {star} AOE OVERHEAL!",
                    default_cs = "{triangle} ROZESTUPY ale {cross} BLÍZKO BOSSE {star} PLOŠNÝ OVERHEAL!",
                    order = 2090,
                    width = "double",
                },
                instructions_14_reset_en = addon:genmisclangreset(2095,"%s","en","instructions_14"),
                instructions_14_reset_cs = addon:genmisclangreset(2096,"%s","cs","instructions_14"),
                instructions_22 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffffff00Yellow|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE {star} AOE OVERHEAL & {skull} KILL ADDS",
                    default_cs = "{triangle} ROZESTUPY {star} PLOŠNÝ OVERHEAL a {skull} ZABÍT ADDKY",
                    order = 2100,
                    width = "double",
                },
                instructions_22_reset_en = addon:genmisclangreset(2105,"%s","en","instructions_22"),
                instructions_22_reset_cs = addon:genmisclangreset(2106,"%s","cs","instructions_22"),
                instructions_38 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffffff00Yellow|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE {star} AOE OVERHEAL & {square} MANA VOID",
                    default_cs = "{triangle} ROZESTUPY {star} PLOŠNÝ OVERHEAL a {square} MANA VOIDA",
                    order = 2110,
                    width = "double",
                },
                instructions_38_reset_en = addon:genmisclangreset(2115,"%s","en","instructions_38"),
                instructions_38_reset_cs = addon:genmisclangreset(2116,"%s","cs","instructions_38"),
                instructions_26 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffff0000Red|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE but {cross} CLOSE TO THE BOSS & {skull} KILL ADDS",
                    default_cs = "{triangle} ROZESTUPY ale {cross} BLÍZKO BOSSE a {skull} ZABÍT ADDKY",
                    order = 2120,
                    width = "double",
                },
                instructions_26_reset_en = addon:genmisclangreset(2125,"%s","en","instructions_26"),
                instructions_26_reset_cs = addon:genmisclangreset(2126,"%s","cs","instructions_26"),
                instructions_42 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffff0000Red|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE but {cross} CLOSE TO THE BOSS & {square} MANA VOID",
                    default_cs = "{triangle} ROZESTUPY ale {cross} BLÍZKO BOSSE a {square} MANA VOIDA",
                    order = 2130,
                    width = "double",
                },
                instructions_42_reset_en = addon:genmisclangreset(2135,"%s","en","instructions_42"),
                instructions_42_reset_cs = addon:genmisclangreset(2136,"%s","cs","instructions_42"),
                instructions_50 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE {square} MANA VOID & {skull} AOE ADDS",
                    default_cs = "{triangle} ROZESTUPY {square} MANA VOIDA a {skull} ZPLOŠNIT ADDKY",
                    order = 2140,
                    width = "double",
                },
                instructions_50_reset_en = addon:genmisclangreset(2145,"%s","en","instructions_50"),
                instructions_50_reset_cs = addon:genmisclangreset(2146,"%s","cs","instructions_50"),
                instructions_28 = {
                    name = L.chat_dragonsoul["|cffffff00Yellow|r / |cffff0000Red|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK {cross} AOE HEALING & {skull} KILL ADDS",
                    default_cs = "{star} NA KOPU {cross} PLOŠNÝ HEAL a {skull} ZABÍT ADDKY",
                    order = 2150,
                    width = "double",
                },
                instructions_28_reset_en = addon:genmisclangreset(2155,"%s","en","instructions_28"),
                instructions_28_reset_cs = addon:genmisclangreset(2156,"%s","cs","instructions_28"),
                instructions_52 = {
                    name = L.chat_dragonsoul["|cffffff00Yellow|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK + AOE HEALING {square} MANA VOID & {skull} AOE ADDS",
                    default_cs = "{star} NA KOPU + PLOŠNÝ HEAL {square} MANA VOIDA a {skull} ZPLOŠNIT ADDKY",
                    order = 2160,
                    width = "double",
                },
                instructions_52_reset_en = addon:genmisclangreset(2165,"%s","en","instructions_52"),
                instructions_52_reset_cs = addon:genmisclangreset(2166,"%s","cs","instructions_52"),
                instructions_56 = {
                    name = L.chat_dragonsoul["|cffff0000Red|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{cross} STACK + AOE HEALING {square} MANA VOID & {skull} AOE ADDS",
                    default_cs = "{cross} NA KOPU + PLOŠNÝ HEAL {square} MANA VOIDA a {skull} ZPLOŠNIT ADDKY",
                    order = 2170,
                    width = "double",
                },
                instructions_56_reset_en = addon:genmisclangreset(2175,"%s","en","instructions_56"),
                instructions_56_reset_cs = addon:genmisclangreset(2176,"%s","cs","instructions_56"),
                ----------------------------------- 4 Oozes ----------------------------------
                instruction_header_4 = {
                    name = L.chat_dragonsoul["Dealing with a combination of |cffffffff4 Oozes|r"],
                    type = "header",
                    order = 3000,
                },
                instructions_4oozes_reset_en = addon:genmisclangreset(3001,"4 Oozes To %s","en","instructions_51","instructions_39","instructions_29","instructions_53","instructions_30","instructions_58"),
                instructions_4oozes_reset_cs = addon:genmisclangreset(3002,"4 Oozes To %s","cs","instructions_51","instructions_39","instructions_29","instructions_53","instructions_30","instructions_58"),
                instructions_51 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cff00ff00Green|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE {diamond} HEALING DEBUFF {square} MANA VOID & {skull} ADDS",
                    default_cs = "{triangle} ROZESTUPY {diamond} HEALING DEBUFF {square} MANA VOIDA a {skull} ADDKY",
                    order = 3010,
                    width = "double",
                },
                instructions_51_reset_en = addon:genmisclangreset(3015,"%s","en","instructions_51"),
                instructions_51_reset_cs = addon:genmisclangreset(3016,"%s","cs","instructions_51"),
                instructions_39 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cff00ff00Green|r / |cffffff00Yellow|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE {star} DIRECT HEALING {diamond} HEALING DEBUFF {square} MANA VOID",
                    default_cs = "{triangle} ROZESTUPY {star} DIRECT HEAL {diamond} HEALING DEBUFF {square} MANA VOIDA",
                    order = 3020,
                    width = "double",
                },
                instructions_39_reset_en = addon:genmisclangreset(3025,"%s","en","instructions_39"),
                instructions_39_reset_cs = addon:genmisclangreset(3026,"%s","cs","instructions_39"),
                instructions_29 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffffff00Yellow|r / |cffff0000Red|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK {cross} USE DMG REDUCTION {diamond} HEALING DEBUFF & {skull} ADDS",
                    default_cs = "{star} NA KOPU {cross} POUŽÍVAT DMG REDUKCE {diamond} HEALING DEBUFF a {skull} ADDKY",
                    order = 3030,
                    width = "double",
                },
                instructions_29_reset_en = addon:genmisclangreset(3035,"%s","en","instructions_29"),
                instructions_29_reset_cs = addon:genmisclangreset(3036,"%s","cs","instructions_29"),
                instructions_53 = {
                    name = L.chat_dragonsoul["|cffa020f0Purple|r / |cffffff00Yellow|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{star} STACK {diamond} HEALING DEBUFF {square} MANA VOID & {skull} ADDS",
                    default_cs = "{star} NA KOPU {diamond} HEALING DEBUFF {square} MANA VOIDA a {skull} ADDKY",
                    order = 3040,
                    width = "double",
                },
                instructions_53_reset_en = addon:genmisclangreset(3045,"%s","en","instructions_53"),
                instructions_53_reset_cs = addon:genmisclangreset(3046,"%s","cs","instructions_53"),
                instructions_30 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffffff00Yellow|r / |cffff0000Red|r / |cffaaaaaaBlack|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE {cross} CLOSE TO THE BOSS {star} USE DMG REDUCTION {skull} ADDS",
                    default_cs = "{triangle} ROZESTUPY {cross} BLÍZKO BOSSE {star} POUŽÍVAT DMG REDUKCE {skull} ADDKY",
                    order = 3050,
                    width = "double",
                },
                instructions_30_reset_en = addon:genmisclangreset(3055,"%s","en","instructions_30"),
                instructions_30_reset_cs = addon:genmisclangreset(3056,"%s","cs","instructions_30"),
                instructions_58 = {
                    name = L.chat_dragonsoul["|cff00ff00Green|r / |cffff0000Red|r / |cffaaaaaaBlack|r / |cff3399ffBlue|r"],
                    desc = L.chat_dragonsoul["Write the instructions for this combination."],
                    type = "input",
                    default_en = "{triangle} KEEP DISTANCE {cross} CLOSE TO THE BOSS {square} MANA VOID {skull} ADDS",
                    default_cs = "{triangle} ROZESTUPY {cross} BLÍZKO BOSSE {square} MANA VOIDA {skull} ADDKY",
                    order = 3060,
                    width = "double",
                },
                instructions_58_reset_en = addon:genmisclangreset(3065,"%s","en","instructions_58"),
                instructions_58_reset_cs = addon:genmisclangreset(3066,"%s","cs","instructions_58"),
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd","voidcd","voidwarn","voidselfwarn",},
            },
            {
                name = format("|cffffd700%s|r |cffffffff%s|r","Ooze","selection"),
                icon = "Interface\\Icons\\inv_ore_arcanite_01",
                alerts = {"slimecd","slimewarn","bloodsimmunewarn","bloodabsorbedwarn"},
            },
            {
                name = format("|cffffd700%s|r |cffffffff%s|r","Ooze","switching"),
                icon = ST[104901],
                alerts = {"switchznonewarn","switchblackwarn","switchbluewarn","switchgreenwarn","switchpurplewarn","switchredwarn","switchyellowwarn"},
            },
            {
                name = format("|cffffd700%s|r |cffffffff%s|r","Ooze","abilies"),
                icon = "Interface\\Icons\\Ability_Racial_BetterLivingThroughChemistry",
                alerts = {"searingcd","manavoidwarn","manavoidduration","corruptcd","corruptwarn","acidcd"},
            },
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time10n = 600,
                time25n = 600,
                time10h = 600,
                time25h = 600,
                flashtime = 60,
                color1 = "RED",
                sound = "MINORWARNING",
                icon = ST[12317],
            },
			-- Call Blood of Shu’ma
            slimecd = {
				varname = format(L.alert["%s CD"],L.chat_dragonsoul["Call Blood of Shu’ma"]),
				type = "dropdown",
				text = format(L.alert["Next %s"],L.chat_dragonsoul["Call Blood of Shu’ma"]),
				time = "<slimecd>",
				time2 = 22,
				flashtime = 5,
				color1 = "BLUE",
				icon = "Interface\\Icons\\inv_ore_arcanite_01",
                remote = true,
			},
            slimewarn = {
                varname = format(L.alert["%s Warning"],L.chat_dragonsoul["Call Blood of Shu’ma"]),
                type = "simple",
                text = "<slimetext>",
                time = 1,
                color1 = "PEACH",
                sound = "BEWARE",
                icon = "Interface\\Icons\\inv_ore_arcanite_01",
            },
            -- Blood Absorbed
            bloodabsorbedwarn = {
                varname = format(L.alert["%s Warning"],"Blood Absorbed"),
                type = "simple",
                text = format(L.alert["Absorbed: %s"],"&list|bloodlist&"),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT1",
                icon = ST[29444],
            },
            -- Bloods Immune
            bloodsimmunewarn = {
                varname = format(L.alert["%s Warning"],"Globules Immune"),
                type = "simple",
                text = format(L.alert["%s"],"Globules Immune"),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT7",
                icon = ST[20925],
            },
            -- No switch
            switchznonewarn = {
                varname = format(L.alert["%s Warning"],"No Switch"),
                type = "simple",
                text = "No switch!",
                time = 1,
                color1 = "PEACH",
                sound = "ALERT12",
                icon = ST[674],
                remote = true,
            },
            -- Ooze switch (Purple)
            switchpurplewarn = {
                varname = format(L.alert["%s Warning"],"Switch To Purple"),
                type = "simple",
                text = format("Kill %s Ooze!","Purple"),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT7",
                icon = ST[104896],
                remote = true,
            },
            -- Ooze switch (Green)
            switchgreenwarn = {
                varname = format(L.alert["%s Warning"],"Switch To Green"),
                type = "simple",
                text = format("Kill %s Ooze!","Green"),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT7",
                icon = ST[104898],
                remote = true,
            },
            -- Ooze switch (Yellow)
            switchyellowwarn = {
                varname = format(L.alert["%s Warning"],"Switch To Yellow"),
                type = "simple",
                text = format("Kill %s Ooze!","Yellow"),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT7",
                icon = ST[104901],
                remote = true,
            },
            -- Ooze switch (Blue)
            switchbluewarn = {
                varname = format(L.alert["%s Warning"],"Switch To Blue"),
                type = "simple",
                text = format("Kill %s Ooze!","Blue"),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT7",
                icon = ST[104900],
                remote = true,
            },
            -- Ooze switch (Red)
            switchredwarn = {
                varname = format(L.alert["%s Warning"],"Switch To Red"),
                type = "simple",
                text = format("Kill %s Ooze!","Red"),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT7",
                icon = ST[104897],
                remote = true,
            },
            -- Ooze switch (Black)
            switchblackwarn = {
                varname = format(L.alert["%s Warning"],"Switch To Black"),
                type = "simple",
                text = format("Kill %s Ooze!","Black"),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT7",
                icon = ST[104894],
                remote = true,
            },
            -- Void Bolt
			voidwarn = {
				varname = format(L.alert["%s Warning"],SN[104849]),
				type = "dropdown",
				text = "<voidtext>",
				time = 20,
				color1 = "PINK",
				icon = ST[104849],
                stacks = 3,
                tag = "#4#",
			},
            voidselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[104849]),
                type = "simple",
                text = "<voidtext>",
                time = 1,
                color1 = "PINK",
                sound = "ALERT10",
                icon = ST[104849],
                throttle = 2,
                stacks = 3,
            },
            voidcd = {
                varname = format(L.alert["%s CD"],SN[108384]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[108384]),
                time = 6,
                time2 = 7.37,
                flashtime = 6,
                color1 = "MAGENTA",
                sound = "None",
                icon = ST[108384],
            },
            -- Searing Bloods
            searingcd = {
                varname = format(L.alert["%s CD"],SN[108356]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[108356]),
                time = "<searingcd>",
                flashtime = 5,
                color1 = "RED",
                sound = "None",
                icon = ST[108356],
            },
            -- Mana Void
            manavoidwarn = {
                varname = format(L.alert["%s Warning"],SN[105530]),
                type = "simple",
                text = format(L.alert["%s"],SN[105530]),
                time = 1,
                color1 = "LIGHTBLUE",
                sound = "ALERT5",
                icon = ST[105530],
            },
            manavoidduration = {
                varname = format(L.alert["%s Duration"],SN[105530]),
                type = "centerpopup",
                text = format(L.alert["%s ends"],SN[105530]),
                time = 4,
                color1 = "INDIGO",
                sound = "None",
                icon = ST[105530],
            },
            -- Deep Corruption
            corruptwarn = {
                varname = format(L.alert["%s Warning"],SN[105171]),
                type = "simple",
                text = format(L.alert["%s"],SN[105171]),
                time = 1,
                color1 = "PURPLE",
                sound = "ALERT10",
                icon = ST[105171],
            },
            corruptcd = {
                varname = format(L.alert["%s CD"],SN[105171]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[105171]),
                time = {25, 0, loop = true, type = "series"},
                color1 = "PURPLE",
                sound = "None",
                behavior = "overwrite",
                icon = ST[105171],
            },
            -- Digestive Acid
            acidcd = {
                varname = format(L.alert["%s CD"],SN[105031]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[105031]),
                time = "<acidcd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "None",
                icon = ST[105031],
            },
		},
        batches = {
            bloodcheck = {
                {
                    "expect",{"&listsize|bloodlist&","==","<bloodmax>"},
                    "alert","bloodabsorbedwarn",
                    "closetemptracing",true,
                    "invoke",{
                        {
                            "expect",{"<globulekilled>","==","no"},
                            "set",{comboinstructionstext = "&itemvalue|instructions_<absorbedcombo>&"},
                            "announce","comboinstructionsrw",
                        },
                        {
                            "expect",{"<globulekilled>","==","yes"},
                            "set",{globulekilled = "no"},
                            "invoke",{
                                {
                                    "expect",{"&difficulty&",">=","3"}, -- HC
                                    "set",{bloodmax = 4},
                                },
                                {
                                    "expect",{"&difficulty&","<=","2"}, -- normal
                                    "set",{bloodmax = 3},
                                },
                            },
                            "alert",{"voidcd",time = 2},
                        },
                    },
                },
            },
        },
        timers = {
            slimetimer = {
                {
                    "quash","slimecd",
                    "alert","slimecd",
                },
                {
                    "expect",{"<slimetimerscheduled>","==","no"},
                    "set",{slimetimerscheduled = "yes"},
                    "repeattimer",{"slimetimer", "<slimecd>"},
                },
            },
            comboinstructionstimer = {
                {
                    "set",{comboinstructionstext = "&itemvalue|instructions_<summonedcombo>&"},
                    "announce","comboinstructionsrw",
                },
            },
        },
		events = {
			-- Void Bolt
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {104849, 108383, 108384, 108385},
				execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "expect",{"#11#",">=","&stacks|voidselfwarn&"},
                        "set",{voidtext = format(L.alert["%s (%s) on <%s>"],SN[104849],"#11#",L.alert["YOU"])},
                        "alert","voidselfwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "expect",{"#11#",">=","&stacks|voidwarn&"},
                        "quash",{"voidwarn","#4#"},
                        "set",{voidtext = format(L.alert["%s (%s) on <%s>"],SN[104849],"#11#","#5#")},
                        "alert","voidwarn",
                        
                    },
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = {104849,108383,108384,108385},
                execute = {
                    {
                        "expect",{"&timeleft|slimecd&",">","6"},
                        "quash","voidcd",
                        "alert","voidcd",
                    },
                },
            },
            
			-- Call Blood of Shu’ma
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#5#","==","105420"},
                        "expect",{"#1#","find","boss"},
                        "invoke",{
                            {
                                "expect",{"&difficulty&",">=","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s,%s","Purple","Green","Black","Blue"),
                                    oozeswitchcolor = "&itemvalue|combo_heroic_105420&",
                                    summonedcombo = 51,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55863}, -- Purple
                                    {unit = "boss", npcid = 55862}, -- Green
                                    {unit = "boss", npcid = 55867}, -- Black
                                    {unit = "boss", npcid = 55866}, -- Blue
                                },
                            },
                            {
                                "expect",{"&difficulty&","<","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s","Purple","Green","Blue"),
                                    oozeswitchcolor = "&itemvalue|combo_normal_105420&",
                                    summonedcombo = 35,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55863}, -- Purple
                                    {unit = "boss", npcid = 55862}, -- Green
                                    {unit = "boss", npcid = 55866}, -- Blue
                                },
                            },
                        },
                        
                    },
                    {
                        "expect",{"#5#","==","105435"},
                        "expect",{"#1#","find","boss"},
                        "invoke",{
                            {
                                "expect",{"&difficulty&",">=","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s,%s","Green","Red","Black","Blue"),
                                    oozeswitchcolor = "&itemvalue|combo_heroic_105435&",
                                    summonedcombo = 58,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55862}, -- Green
                                    {unit = "boss", npcid = 55865}, -- Red
                                    {unit = "boss", npcid = 55867}, -- Black
                                    {unit = "boss", npcid = 55866}, -- Blue
                                },
                            },
                            {
                                "expect",{"&difficulty&","<","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s","Green","Red","Black"),
                                    oozeswitchcolor = "&itemvalue|combo_normal_105435&",
                                    summonedcombo = 26,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55862}, -- Green
                                    {unit = "boss", npcid = 55865}, -- Red
                                    {unit = "boss", npcid = 55867}, -- Black
                                },
                            },
                        },
                    },
                    {
                        "expect",{"#5#","==","105436"},
                        "expect",{"#1#","find","boss"},
                        "invoke",{
                            {
                                "expect",{"&difficulty&",">=","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s,%s","Green","Yellow","Black","Red"),
                                    oozeswitchcolor = "&itemvalue|combo_heroic_105436&",
                                    summonedcombo = 30,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55862}, -- Green
                                    {unit = "boss", npcid = 55864}, -- Yellow
                                    {unit = "boss", npcid = 55867}, -- Black
                                    {unit = "boss", npcid = 55865}, -- Red
                                },
                            },
                            {
                                "expect",{"&difficulty&","<","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s","Green","Yellow","Red"),
                                    oozeswitchcolor = "&itemvalue|combo_normal_105436&",
                                    summonedcombo = 14,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55862}, -- Green
                                    {unit = "boss", npcid = 55864}, -- Yellow
                                    {unit = "boss", npcid = 55865}, -- Red
                                },
                            },
                        },
                    },
                    {
                        "expect",{"#5#","==","105437"},
                        "expect",{"#1#","find","boss"},
                        "invoke",{
                            {
                                "expect",{"&difficulty&",">=","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s,%s","Purple","Green","Yellow","Blue"),
                                    oozeswitchcolor = "&itemvalue|combo_heroic_105437&",
                                    summonedcombo = 39,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55863}, -- Purple
                                    {unit = "boss", npcid = 55862}, -- Green
                                    {unit = "boss", npcid = 55864}, -- Yellow
                                    {unit = "boss", npcid = 55866}, -- Blue
                                },
                            },
                            {
                                "expect",{"&difficulty&","<","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s","Purple","Yellow","Blue"),
                                    oozeswitchcolor = "&itemvalue|combo_normal_105437&",
                                    summonedcombo = 37,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55863}, -- Purple
                                    {unit = "boss", npcid = 55864}, -- Yellow
                                    {unit = "boss", npcid = 55866}, -- Blue
                                },
                            },
                        },
                    },
                    {
                        "expect",{"#5#","==","105439"},
                        "expect",{"#1#","find","boss"},
                        "invoke",{
                            {
                                "expect",{"&difficulty&",">=","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s,%s","Purple","Yellow","Black","Blue"),
                                    oozeswitchcolor = "&itemvalue|combo_heroic_105439&",
                                    summonedcombo = 53,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55863}, -- Purple
                                    {unit = "boss", npcid = 55864}, -- Yellow
                                    {unit = "boss", npcid = 55867}, -- Black
                                    {unit = "boss", npcid = 55866}, -- Blue
                                },
                            },
                            {
                                "expect",{"&difficulty&","<","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s","Yellow","Black","Blue"),
                                    oozeswitchcolor = "&itemvalue|combo_normal_105439&",
                                    summonedcombo = 52,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55864}, -- Yellow
                                    {unit = "boss", npcid = 55867}, -- Black
                                    {unit = "boss", npcid = 55866}, -- Blue
                                },
                            },
                        },
                    },
                    {
                        "expect",{"#5#","==","105440"},
                        "expect",{"#1#","find","boss"},
                        "invoke",{
                            {
                                "expect",{"&difficulty&",">=","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s,%s","Purple","Yellow","Red","Black"),
                                    oozeswitchcolor = "&itemvalue|combo_heroic_105440&",
                                    summonedcombo = 29,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55863}, -- Purple
                                    {unit = "boss", npcid = 55864}, -- Yellow
                                    {unit = "boss", npcid = 55865}, -- Red
                                    {unit = "boss", npcid = 55867}, -- Black
                                },
                            },
                            {
                                "expect",{"&difficulty&","<","3"},
                                "set",{
                                    slimetext = format("Calling: %s,%s,%s","Purple","Red","Black"),
                                    oozeswitchcolor = "&itemvalue|combo_normal_105440&",
                                    summonedcombo = 25,
                                },
                                "temptracing",{
                                    {unit = "boss", npcid = 55863}, -- Purple
                                    {unit = "boss", npcid = 55865}, -- Red
                                    {unit = "boss", npcid = 55867}, -- Black
                                },
                            },
                        },
                    },
                    {
                        "expect",{"#1#","find","boss"},
                        "expect",{"#2#","==",SN[105420]},
                        "alert","slimewarn",
                        "quash","searingcd",
                        "quash","acidcd",
                        "quash","voidcd",
                        "set",{absorbedcombo = 0},
                    },
                    {
                        "expect",{"#1#","find","boss"},
                        "expect",{"#2#","==",SN[105420]},
                    },
                    -- Send Ooze mode
                    {
                        "expect",{"#1#","find","boss"},
                        "expect",{"#2#","==",SN[105420]},
                        "expect",{"&itemvalue|priority_distribution_mode&","==","send"},
                        "expect",{"&valuepriority|priority_distribution_mode|send&","==","true"},
                        "announce","oozepriorities_<oozeswitchcolor>",
                        "alert","switch<oozeswitchcolor>warn",
                        "broadcast",{"alert","switch<oozeswitchcolor>warn"},
                        "expect",{"<oozeswitchcolor>","~=","znone"},
                        "broadcast",{"arrow","<oozeswitchcolor>arrow"},
                        "arrow","<oozeswitchcolor>arrow",
                    },
                    -- Trigger Ooze mode
                    {
                        "expect",{"#1#","find","boss"},
                        "expect",{"#2#","==",SN[105420]},
                        "expect",{"&itemvalue|priority_distribution_mode&","==","self"},
                        "alert","switch<oozeswitchcolor>warn",
                        "expect",{"<oozeswitchcolor>","~=","znone"},
                        "arrow","<oozeswitchcolor>arrow",
                    },
                },
            },
            -- Blood killed
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#5#","==","105904"},
                        "expect",{"<globulekilled>","==","no"},
                        "set",{globulekilled = "yes"},
                        "alert","bloodsimmunewarn",
                        "closetemptracing",true,
                        "invoke",{
                            {
                                "expect",{"&difficulty&",">=","3"}, -- HC
                                "set",{bloodmax = 3},
                            },
                            {
                                "expect",{"&difficulty&","<=","2"}, -- normal
                                "set",{bloodmax = 2},
                            },
                        },
                        
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "invoke",{
                            {
                                "expect",{"&npcid|#4#&","==","55863"}, -- Purple
                                "set",{summonedcombo = "DECR|1"},
                                "scheduletimer",{"comboinstructionstimer", 0},
                            },
                            {
                                "expect",{"&npcid|#4#&","==","55862"}, -- Green
                                "set",{summonedcombo = "DECR|2"},
                                "scheduletimer",{"comboinstructionstimer", 0},
                            },
                            {
                                "expect",{"&npcid|#4#&","==","55864"}, -- Yellow
                                "set",{summonedcombo = "DECR|4"},
                                "scheduletimer",{"comboinstructionstimer", 0},
                            },
                            {
                                "expect",{"&npcid|#4#&","==","55865"}, -- Red
                                "set",{summonedcombo = "DECR|8"},
                                "scheduletimer",{"comboinstructionstimer", 0},
                            },
                            {
                                "expect",{"&npcid|#4#&","==","55867"}, -- Black
                                "set",{summonedcombo = "DECR|16"},
                                "scheduletimer",{"comboinstructionstimer", 0},
                            },
                            {
                                "expect",{"&npcid|#4#&","==","55866"}, -- Blue
                                "set",{summonedcombo = "DECR|32"},
                                "scheduletimer",{"comboinstructionstimer", 0},
                            },
                        },
                    },
                },
            },
            
            -- Blood Absorbtion
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                dstnpcid = 55312,
                execute = {
                    -- Glowing Blood of Shu'ma
                    {
                        "expect",{"#7#","==","104901"},
                        "set",{
                            searingcd = 3.5,
                            acidcd = 4,
                            absorbedcombo = "INCR|4",
                        },
                        "insert",{"bloodlist","Yellow"},
                        "run","bloodcheck",
                        
                    },
                    -- Shadowed Blood of Shu'ma
                    {
                        "expect",{"#7#","==","104896"},
                        "set",{absorbedcombo = "INCR|1",},
                        "insert",{"bloodlist","Purple"},
                        "run","bloodcheck",
                    },
                    -- Cobalt Blood of Shu'ma
                    {
                        "expect",{"#7#","==","105027"},
                        "set",{absorbedcombo = "INCR|32",},
                        "insert",{"bloodlist","Blue"},
                        "run","bloodcheck",
                    },
                    -- Crimson Blood of Shu'ma
                    {
                        "expect",{"#7#","==","104897"},
                        "set",{absorbedcombo = "INCR|8",},
                        "insert",{"bloodlist","Red"},
                        "run","bloodcheck",
                    },
                    -- Black Blood of Shu'ma
                    {
                        "expect",{"#7#","==","104894"},
                        "set",{absorbedcombo = "INCR|16",},
                        "insert",{"bloodlist","Black"},
                        "run","bloodcheck",
                    },
                    -- Acidic Blood of Shu'ma
                    {
                        "expect",{"#7#","==","104898"},
                        "range",{true},
                        "set",{absorbedcombo = "INCR|2",},
                        "insert",{"bloodlist","Green"},
                        "run","bloodcheck",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                dstnpcid = 55312,
                execute = {
                    {
                        "expect",{"#7#","==","104898"},
                        "range",{false},
                    },
                    {
                        "expect",{"#7#","==","104901"},
                        "set",{
                            searingcd = 7,
                            acidcd = 8,
                        },
                    },
                },
            },
            -- Searing Blood
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 108356,
                execute = {
                    {
                        "quash","searingcd",
                        "expect",{"&timeleft|slimecd&",">=","<searingcd>"},
                        "alert","searingcd",
                    },
                },
            },
            -- Mana Void
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 105530,
                execute = {
                    {
                        "alert","manavoidwarn",
                        "alert","manavoidduration",
                    },
                },
            },
            -- Deep Corruption
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 105171,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","corruptwarn",
                        "alert","corruptcd",
                    },
                },
            },
            -- Digestive Acid
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 108351,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "quash","acidcd",
                        "expect",{"&timeleft|slimecd&",">=","1"},
                        "expect",{"&timeleft|slimecd&","<","60"},
                        "alert","acidcd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_MISSED",
                spellname = 108351,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "quash","acidcd",
                        "expect",{"&timeleft|slimecd&",">=","8"},
                        "alert","acidcd",
                    },
                },
            },
            
		},
	}

	DXE:RegisterEncounter(data)
end

----------------------------
-- HAGARA THE STORMBINDER
----------------------------
do
	local data = {
		version = 6,
		key = "hagara",
		zone = L.zone["Dragon Soul"],
		category = L.zone["Dragon Soul"],
		name = L.npc_dragonsoul["Hagara the Stormbinder"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Hagara.blp",
		advanced = {
            delayWipe = 1,
        },
        triggers = {
			scan = {
				55689, --Hagara
			},
		},
		onactivate = {
			tracing = {
				55689, --Hagara
			},
			tracerstart = true,
			combatstop = true,
			defeat = 55689,
		},
		userdata = {
            -- Texts
            overloadtext = "",
            
            -- Switches
            phase = "1",
            firstlance = "no",
            
            -- Lists
            lanceunits = {type = "container", wipein = 3},
            tombunits = {type = "container", wipein = 3},
		},
		onstart = {
			{
                "alert","enragecd",
				"alert","nextphasecd",
                "alert",{"lancecd",time = 2},
                "alert",{"assaultcd",time = 2},
			},
		},
		
        announces = {
            flakesay = {
                type = "SAY",
                subtype = "self",
                spell = 109325,
                msg = format(L.alert["%s on ME!"],SN[109325]),
            },
            
        },
        raidicons = {
			tombmark = {
                varname = format("%s {%s}",SN[104451],"PLAYER_DEBUFF"),
				type = "MULTIFRIENDLY",
				persist = 30,
				reset = 5,
				unit = "#5#",
				icon = 2,
				total = 6,
                texture = ST[104451],
			},
			flakemark = {
                varname = format("%s {%s}",SN[109325],"PLAYER_DEBUFF"),
				type = "MULTIFRIENDLY",
				reset = 6,
				unit = "#5#",
				icon = 1,
				total = 2,
                texture = ST[109325],
			},
		},
		filters = {
            bossemotes = {
                overloademote = {
                    name = "Crystal Conductor overloaded",
                    pattern = "conducting crystal overloads",
                    hasIcon = false,
                    hide = true,
                    texture = ST[109201],
                },
            },
        },
		phrasecolors = {
            {"Conductor[s]? left","WHITE"},
            {"Crystal[s]? left","WHITE"},
        },
        windows = {
			proxwindow = true,
			proxrange = 10,
			proxoverride = true,
		},
        radars = {
            flakeradar = {
                varname = SN[109325],
                type = "circle",
                player = "#5#",
                range = 10,
                mode = "avoid",
                rangecheck = "manual",
                color = "CYAN",
                icon = ST[109325],
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd","phase1warn","nextphasecd","tempestcd","shieldcd",},
            },
            {
                phase = 1,
                alerts = {"lancecd","lancewarn","lanceduration","lanceselfwarn","assaultcd","assaultwarn","assaultselfwarn","feedbackdur","tombcd","tombcastwarn","tombwarn","icecd"},
            },
            {
                name = format("|cff00d9ff%s|r |cffffffff%s|r","Frost","Phase"),
                icon = ST[63562],
                alerts = {"tempestwarn","crystalkilledwarn","flakecd","flakeselfwarn","flakeselfduration"},
            },
            {
                name = format("|cffc0c0c0%s|r |cffffffff%s|r","Lightning","Phase"),
                icon = ST[105343],
                alerts = {"shieldwarn","overloadwarn","pillarscd","pillarselfwarn"},
            },
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time10n = 480,
                time25n = 480,
                time10h = 480,
                time25h = 480,
                flashtime = 60,
                color1 = "RED",
                sound = "MINORWARNING",
                icon = ST[12317],
            },
            -------------
            -- Phase 1 --
            -------------
            -- Phase 1
            phase1warn = {
                varname = format(L.alert["Phase 1 Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"1"),
                time = 3,
                color1 = "TURQUOISE",
                sound = "ALERT1",
                icon = ST[11242],
            },
            -- Frost / Lightning Phase
            nextphasecd = {
                varname = format(L.alert["%s CD"],"Frost / Lightning Phase"),
                type = "dropdown",
                text = format(L.alert["Next %s"],"Frost / Lightning Phase"),
                time = 30,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[34202],
                sticky = true,
            },
            -- Ice Lance
            lancecd = {
                varname = format(L.alert["%s CD"],SN[105297]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[105297]),
                time = 30,
                time2 = 12,
                flashtime = 5,
                color1 = "CYAN",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[105297],
                behavior = "overwrite",
            },
            lancewarn = {
                varname = format(L.alert["%s Warning"],SN[105297]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[105297],"&list|lanceunits&"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[105297],
            },
            lanceselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[105297]),
				type = "simple",
				text = format(L.alert["%s (%s) on <%s>"],SN[105297],"#11#",L.alert["YOU"]),
				time = 3,
				flashtime = 3,
				color1 = "YELLOW",
				icon = ST[105297],
				sound = "ALERT3",
                emphasizewarning = true,
                stacks = 2,
                throttle = 2,
			},
            lanceduration = {
                varname = format(L.alert["%s Duration"],SN[105297]),
                type = "centerpopup",
                text = format(L.alert["%s fades"],SN[105297]),
                time = 15,
                color1 = "TURQUOISE",
                sound = "None",
                icon = ST[105297],
                behavior = "singleton",
            },
            -- Focused Assault
            assaultcd = {
                varname = format(L.alert["%s CD"],SN[107851]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[107851]),
                time = 15,
                time2 = 3,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[107851],
                sticky = true,
            },
            assaultwarn = {
                varname = format(L.alert["%s Warning"],SN[107851]),
                type = "simple",
                text = format(L.alert["%s"],SN[107851]),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT10",
                icon = ST[107851],
            },
            assaultselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[107851]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[107851],L.alert["YOU"]),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT10",
                icon = ST[107851],
                throttle = 2,
                emphasizewarning = true,
            },
            -- Feedback
            feedbackdur = {
				varname = format(L.alert["%s Duration"],SN[108934]),
				type = "centerpopup",
				text = format(L.alert["%s ends"],SN[108934]),
				time = 15,
				flashtime = 15,
				color1 = "TEAL",
				icon = ST[108934],
				sound = "BURST",
			},
            -- Ice Tomb
            tombcastwarn = {
				varname = format(L.alert["%s Cast"],SN[104448]),
				type = "centerpopup",
                warningtext = format(L.alert["%s"],SN[104448]),
				text = format(L.alert["%s lands"],SN[104448]),
				time = 8,
				flashtime = 8,
				color1 = "LIGHTBLUE",
				icon = ST[104448],
				sound = "ALERT2",
			},
            tombwarn = {
                varname = format(L.alert["%s Warning"],SN[104451]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[104451],"&list|tombunits&"),
                time = 1,
                color1 = "LIGHTBLUE",
                sound = "ALERT7",
                icon = ST[99247],
            },
			tombcd = {
				varname = format(L.alert["%s CD"],SN[104448]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[104448]),
				time = 21,
				flashtime = 5,
				color1 = "WHITE",
				icon = ST[104448],
			},
            -- Shattered Ice
            icecd = {
                varname = format(L.alert["%s CD"],SN[105289]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[105289]),
                time = 10.5,
                time2 = 22,
                flashtime = 5,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[105289],
                sticky = true,
                enabled = false,
            },
            -----------------
            -- Frost Phase --
            -----------------
            -- Frost Phase starts (Frozen Tempest)
            tempestcd = {
				varname = format(L.alert["%s CD"],"Frost Phase"),
				type = "dropdown",
				text = format(L.alert["Next %s"],"Frost Phase"),
				time = 62,
				flashtime = 5,
				color1 = "CYAN",
				--icon = ST[109552],
                icon = ST[63562],
                sticky = true,
			},
			tempestwarn = {
				varname = format(L.alert["%s Warning"],"Frost Phase"),
				type = "simple",
				text = format(L.alert["%s"],"Frost Phase"),
				time = 3,
				flashtime = 3,
				color1 = "CYAN",
				--icon = ST[109552],
                icon = ST[63562],
				sound = "ALERT1",
			},
            flakeselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[109325]),
				type = "simple",
				text = format(L.alert["%s on <%s>"],SN[109325],L.alert["YOU"]),
				time = 3,
				flashtime = 3,
				color1 = "TURQUOISE",
				icon = ST[109325],
				sound = "ALERT4",
				flashscreen = true,
                emphasizewarning = true,
			},
            flakeselfduration = {
                varname = format(L.alert["%s on me Duration"],SN[109325]),
                type = "centerpopup",
                text = format(L.alert["%s fades"],SN[109325]),
                time = 15,
                flashtime = 15,
                color1 = "TURQUOISE",
                color2 = "Off",
                sound = "MINORWARNING",
                icon = ST[109325],
                behavior = "overwrite",
            },
            flakecd = {
                varname = format(L.alert["%s CD"],SN[109325]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[109325]),
                time = 5,
                time2 = 6,
                flashtime = 5,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[109325],
            },
            -- Frozen Binding Crystal
            crystalkilledwarn = {
                varname = format(L.alert["%s Warning"],"Crystal Killed"),
                type = "simple",
                text = "<crystalkilledtext>",
                time = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[25953],
            },
            
            ---------------------
            -- Lightning Phase --
            ---------------------
			-- Lightning Phase starts (Water Shield)
            shieldcd = {
				varname = format(L.alert["%s CD"],"Lightning Phase"),
				type = "dropdown",
				text = format(L.alert["Next %s"],"Lightning Phase"),
				time = 62,
				flashtime = 5,
				color1 = "MIDGREY",
				--icon = ST[109560],
                icon = ST[18980],
                sticky = true,
			},
			shieldwarn = {
				varname = format(L.alert["%s Warning"],"Lightning Phase"),
				type = "simple",
				text = format(L.alert["%s"],"Lightning Phase"),
				time = 3,
				flashtime = 3,
				color1 = "WHITE",
				icon = ST[18980],
				sound = "ALERT1",
			},
            -- Crystal Conductor overloaded
            overloadwarn = {
                varname = format(L.alert["%s Warning"],"Conductor Overloaded"),
                type = "simple",
                text = "<overloadtext>",
                time = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[83099],
            },
            -- Storm Pillars
            pillarscd = {
                varname = format(L.alert["%s CD"],SN[109557]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[109557]),
                time = 5,
                time2 = 7,
                flashtime = 5,
                color1 = "TEAL",
                sound = "MINORWARNING",
                icon = ST[109565],
            },
            pillarselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[109565]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[109565],L.alert["YOU"]),
                time = 1,
                color1 = "LIGHTBLUE",
                sound = "ALERT10",
                icon = ST[109565],
                throttle = 2,
                emphasizewarning = true,
            },
		},
		timers = {
            lancetimer = {
                {
                    "set",{firstlance = "yes"},
                    "alert","lancewarn",
                },
            },
            tombtimer = {
                {
                    "alert","tombwarn",
                },
            },
            phase1timer = {
                {
                    "expect",{"&iswipedelayed&","==","false"},
                    "set",{phase = "1"},
                    "alert","phase1warn",
                    "alert","tombcd",
                    "alert","feedbackdur",
                    "alert",{"lancecd",time = 2},
                    "alert",{"icecd",time = 2},
                    "alert","assaultcd",
                },
            },
            crystaltimer = {
                {
                    "expect",{"&iswipedelayed&","==","false"},
                    "alert","crystalkilledwarn",
                },
            },
            overloadtimer = {
                {
                    "expect",{"&iswipedelayed&","==","false"},
                    "alert","overloadwarn",
                },
            },
        },
		events = {
            -------------
            -- Phase 1 --
            -------------
            -- Ice Lance
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = 105297,
				execute = {
					{
						"insert",{"lanceunits","#2#"},
                        "canceltimer","lancetimer",
                        "scheduletimer",{"lancetimer", 0.5},
                        "alert","lanceduration",
                        "expect",{"<firstlance>","==","yes"},
                        "alert","lancecd",
					},
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 105316,
                srcnpcid = 56108,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "expect",{"#11#",">=","&stacks|lanceselfwarn&"},
						"alert","lanceselfwarn",
                    },
                },
            },
            -- Focused Assault
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                srcnpcid = 55689,
                spellname = 107850,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "expect",{"&difficulty&","<=","2"}, -- normal only
                        "alert","assaultselfwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 107851,
                execute = {
                    {
                        "alert","assaultwarn",
                        "quash","assaultcd",
                        "expect",{"&timeleft|nextphasecd&",">","15",
                                 "OR","&timeleft|tempestcd&",">","15",
                                 "OR","&timeleft|shieldcd&",">","15"},
                        "alert","assaultcd",
                    },
                },
            },
            
            -- Ice Tomb
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 104448 ,
				execute = {
					{
						"alert","tombcastwarn",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 104451,
				execute = {
					{
						"raidicon","tombmark",
                        "expect",{"&listcontains|tombunits|#5#&","==","false"},
                        "insert",{"tombunits","#5#"},
                        "canceltimer","tombtimer",
                        "scheduletimer",{"tombtimer", 0.5},
					},
				},
			},
            -- Shattered Ice
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 105289,
                execute = {
                    {
                        "quash","icecd",
                        "alert","icecd",
                    },
                },
            },
            
            -----------------
            -- Frost Phase --
            -----------------
            -- Frost Phase starts (Frozen Tempest)
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				srcnpcid = 55689,
				spellname = 109552,
				execute = {
					{
                        "set",{
                            phase = "frost",
                            crystalcount = 4,
                        },
                        "quash","nextphasecd",
                        "quash","tempestcd",
                        "quash","icecd",
                        "quash","shieldcd",
						"alert","tempestwarn",
                        "range",{true,42,true},
					},
                    {
                        "expect",{"&difficulty&",">=","3"}, -- heroic
                        "alert",{"flakecd",time = 2},
                    },
				},
			},
            -- Frost Phase ends ( Frozen Tempest)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				srcnpcid = 55689,
				spellname = 109552,
				execute = {
					{
                        "closetemptracing",true,
						"alert","shieldcd",
                        "quash","flakecd",
                        "scheduletimer",{"phase1timer", 0.01},
                        "range",{true,nil,false},
                        "removeradar",{"flakeradar"},
					},
				},
			},
            -- Register Frozne Binding Crystals
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 105311,
                execute = {
                    {
                        "expect",{"<phase>","==","frost"},
                        "temptracing","#1#",
                    },
                },
            },
            
            -- Frostflake (heroic)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 109325,
				execute = {
					{
						"raidicon","flakemark",
                        "quash","flakecd",
                        "alert","flakecd",
                        "removeradar",{"flakeradar", player = "#5#"},
                        "radar",{"flakeradar","&neg|&debuff|#5#|Watery Entrenchment&&"},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","flakeselfwarn",
                        "alert","flakeselfduration",
                        "announce","flakesay",
					},
				},
			},
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REFRESH",
                spellname = 109325,
                execute = {
                    {
                        "alert","flakecd",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
						"alert","flakeselfwarn",
                        "alert","flakeselfduration",
                    },
                },
            },
            
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 109325,
                execute = {
                    {
                        "removeraidicon","#5#",
                        "removeradar",{"flakeradar", player = "#5#"},
                        "quash","flakeselfduration",
                    },
                },
            },
            -- Watery Entrenchment
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 110317,
                execute = {
                    {
                        "radarsetinrange",{"flakeradar","#5#",false},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 110317,
                execute = {
                    {
                        "radarsetinrange",{"flakeradar","#5#",true},
                    },
                },
            },
            
            -- Frozen Binding Crystal killed
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellid = 105311,
                dstnpcid = 55689,
                execute = {
                    {
                        "set",{crystalcount = "DECR|1"},
                        "expect",{"<crystalcount>",">","0"},
                        "invoke",{
                            {
                                "expect",{"<crystalcount>","==","1"},
                                "set",{crystalkilledtext = format(L.alert["%s Crystal left"],"<crystalcount>")},
                            },
                            {
                                "expect",{"<crystalcount>",">","1"},
                                "set",{crystalkilledtext = format(L.alert["%s Crystals left"],"<crystalcount>")},
                            },
                        },
                        "scheduletimer",{"crystaltimer", 0.01},
                    },
                },
            },
            
            ---------------------
            -- Lightning Phase --
            ---------------------
			-- Lightning Phase starts (Water Shield)
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				srcnpcid = 55689,
				spellname = 109560,
				execute = {
					{
                        "set",{phase = "lightning"},
                        "quash","nextphasecd",
                        "quash","tempestcd",
                        "quash","icecd",
                        "quash","shieldcd",
						"alert","shieldwarn",
					},
                    {
                        "expect",{"&difficulty&",">=","3"}, -- HC
                        "alert",{"pillarscd",time = 2},
                    },
                    {
                        "expect",{"&difficulty&","==","3"}, -- 10HC
                        "set",{conductorcount = 8},
                    },
                    {
                        "expect",{"&difficulty&","~=","3"}, -- normal
                        "set",{conductorcount = 4},
                    },
				},
			},
			-- Lightning Phase ends
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				srcnpcid = 55689,
				spellname = 109560,
				execute = {
					{
                        -- Lightning
						"alert","tempestcd",
                        "quash","pillarscd",
                        "scheduletimer",{"phase1timer", 0.01},
					},
				},
			},
			-- Crystal Conductor overloaded
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellid = 105482,
                dstnpcid = 55689,
                execute = {
                    {
                        "set",{conductorcount = "DECR|1"},
                        "expect",{"<conductorcount>",">","0"},
                        "invoke",{
                            {
                                "expect",{"<conductorcount>","==","1"},
                                "set",{overloadtext = format(L.alert["%s Conductor left"],"<conductorcount>")},
                            },
                            {
                                "expect",{"<conductorcount>",">","1"},
                                "set",{overloadtext = format(L.alert["%s Conductors left"],"<conductorcount>")},
                            },
                        },
                        "scheduletimer",{"overloadtimer", 0.01},
                    },
                },
            },
            -- Storm Pillars
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 109557,
                execute = {
                    {
                        "quash","pillarscd",
                        "alert","pillarscd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 109565,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","pillarselfwarn",
                    },
                },
            },
            
			
		},
	}

	DXE:RegisterEncounter(data)
end

----------------------------
-- WYRMREST SUMMIT
----------------------------

do
    local data = {
        version = 1,
        key = "sumitevent",
        zone = L.zone["The Dragon Wastes"],
		category = L.zone["Dragon Soul"],
        name = "Wyrmrest Summit",
        icon = "Interface\\Icons\\Achievement_Reputation_WyrmrestTemple",
        advanced = {
            silentDefeat = true,
            notimer = true,
        },
        triggers = {
            yell = L.chat_dragonsoul["^It is good to see you again"],
            UNIT_SPELLCAST_SUCCEEDED = {"Post-Wipe-Trigger",spellid = 108161},
            UNIT_SPELLCAST_FAILED = {"Bugged-Encounter-Trigger",spellid = 108492},
            UNIT_SPELLCAST_STOP = {"Bugged-Encounter-Trigger",spellid = 108492},
            
        },
        onpullevent = {
        },
        onactivate ={
            tracerstart = true,
            combatstop = false,
            combatstart = false,
            defeat = {
                L.chat_dragonsoul["Mere whelps, experiments, a means"],
            },
            wipe = {
                yell = L.chat_dragonsoul["^They have failed us sister"],
            },
        },
        userdata = {
            -- Counters
            drakecount = 15,
            
            -- Lists
            drakeunits = {type = "container"},
        },
        onstart = {
            {
                "alert","escapecd",
                "schedulealert",{"escapewarn", 270},
            },
        },
        
        phrasecolors = {
            {"Twilight Assaulter[s]? left","WHITE"},
        },
        ordering = {
            alerts = {"drakekilledwarn","flamesselfwarn","escapecd","escapewarn"},
        },
        
        alerts = {
            -- Twilight Escape
            escapecd = {
                varname = format(L.alert["%s CD"],SN[109904]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[109904]),
                --time = 270,
                time = 231,
                flashtime = 10,
                color1 = "MAGENTA",
                color2 = "PURPLE",
                sound = "MINORWARNING",
                icon = ST[61248],
            },
            escapewarn = {
                varname = format(L.alert["%s Warning"],SN[109904]),
                type = "simple",
                text = format(L.alert["%s"],SN[109904]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT1",
                icon = ST[109904],
            },
            -- Twilight Drake killed
            drakekilledwarn = {
                varname = format(L.alert["%s Warning"],"Twilight Assaulter Killed"),
                type = "simple",
                text = "<drakekilledtext>",
                time = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[61248],
            },
            -- Twilight Flames
            flamesselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[105579]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[105579],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[105579],
                throttle = 2,
                emphasizewarning = true,
            },
        },
        timers = {
            draketimer = {
                {
                    "invoke",{
                        {
                            "expect",{"<drakecount>","==","1"},
                            "set",{drakekilledtext = format(L.alert["%s Twilight Assaulter left"],"<drakecount>")},
                        },
                        {
                            "expect",{"<drakecount>",">","1"},
                            "set",{drakekilledtext = format(L.alert["%s Twilight Assaulters left"],"<drakecount>")},
                        },
                    },
                    "alert","drakekilledwarn",
                },
            },
        },
        events = {
			-- Twilight Drake killed
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","57281",
                                  "OR","&npcid|#4#&","==","56249",
                                  "OR","&npcid|#4#&","==","56250",
                                  "OR","&npcid|#4#&","==","56251",
                                  "OR","&npcid|#4#&","==","56252",
                                  "OR","&npcid|#4#&","==","57795"},
                        "expect",{"&listcontains|drakeunits|#4#&","==","false"},
                        "insert",{"drakeunits","#4#"},
                        "set",{drakecount = "DECR|1"},
                        "expect",{"<drakecount>",">=","0"},
                        "scheduletimer",{"draketimer", 0.01},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "PARTY_KILL",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","57281",
                                  "OR","&npcid|#4#&","==","56249",
                                  "OR","&npcid|#4#&","==","56250",
                                  "OR","&npcid|#4#&","==","56251",
                                  "OR","&npcid|#4#&","==","56252",
                                  "OR","&npcid|#4#&","==","57795"},
                        "expect",{"&listcontains|drakeunits|#4#&","==","false"},
                        "insert",{"drakeunits","#4#"},
                        "set",{drakecount = "DECR|1"},
                        "expect",{"<drakecount>",">","0"},
                        "scheduletimer",{"draketimer", 0.01},
                    },
                },
            },
            -- Twilight Flames
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 105579,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","flamesselfwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

----------------------------
-- ULTRAXION
----------------------------
do
    local UnitGroupRolesAssigned,UnitClass,UnitIsUnit = UnitGroupRolesAssigned,UnitClass,UnitIsUnit
    local ListOfClass = addon.NamedListOfClass
    local GetRaidDifficulty = addon.GetRaidDifficulty
    local GetNumRaidMembers = GetNumRaidMembers
    local ipairs,pairs = ipairs,pairs
    
    local hot_priorities_disabled = function() return not ItemEnabled("hotpriorities", "ultraxion") end
    
    local COOLDOWN_COMBINATIONS = {
        ------------------------
        -- Personal cooldowns --
        ------------------------
        {primary   = {class = "Paladin",      role = "ANY",    spell = 642}}, -- Divine Shield
        {primary   = {class = "Paladin",      role = "TANK",   spell = 31850}}, -- Ardent Defender
        {primary   = {class = "Paladin",      role = "TANK",   spell = 86150}}, -- Guardian of Ancient Kings
        {primary   = {class = "Priest",       role = "DAMAGER",spell = 47585}}, -- Dispersion
        
        {primary   = {class = "Rogue",        role = "ANY",    spell = 31224}}, -- Cloak of Shadows
        {primary   = {class = "Rogue",        role = "ANY",    spell = 1966}}, -- Feint
        {primary   = {class = "Death Knight", role = "ANY",    spell = 31662}}, -- Anti-Magic Shell
        {primary   = {class = "Death Knight", role = "TANK",   spell = 48792}}, -- Icebound Fortitude
        {primary   = {class = "Mage",         role = "ANY",    spell = 87023}}, -- Cauterize
        {primary   = {class = "Mage",         role = "ANY",    spell = 27619}}, -- Ice Block
        {primary   = {class = "Druid",        role = "ANY",   spell = 61336}}, -- Survival Instincts
        {primary   = {class = "Shaman",       role = "ANY",    spell = 20608}}, -- Reincarnation
        
        {primary   = {class = "Hunter",       role = "ANY",    spell = 19263}}, -- Deterrence
        {primary   = {class = "Warrior",      role = "ANY",    spell = 871}}, -- Shield Wall
        
        ------------------------
        -- External cooldowns --
        ------------------------
        {secondary = {class = "Priest",       role = "HEALER", spell = 47788}},                 -- Guardian Spirit
        {secondary = {class = "Warlock",      role = "ANY",    spell = 6203}},                     -- Soulstone
        {secondary = {class = "Druid",        role = "ANY",    spell = 20484, cond = "NON-SELF"}}, -- Rebirth
        {secondary = {class = "Death Knight", role = "ANY",    spell = 61999, cond = "NON-SELF"}}, -- Raise Ally
        
        --------------------------------------------------
        -- Personal cooldown + external cooldown combos --
        --------------------------------------------------
        -- Divine Protection + other
        {primary   = {class = "Paladin",      role = "ANY",       spell = 498},                        -- Divine Protection
         secondary = {class = "Paladin",      role = "ANY",       spell = 6940,   cond = "NON-SELF"}}, -- Hand of Sacrifice
        
        {primary   = {class = "Paladin",      role = "ANY",       spell = 498},                        -- Divine Protection
         secondary = {class = "Priest",       role = "HEALER",    spell = 33206}},                     -- Pain Suppression
        
        {primary   = {class = "Paladin",      role = "ANY",       spell = 498},                        -- Divine Protection
         secondary = {class = "Priest",       role = "HEALER",    spell = 62618}},                     -- Power Word: Barrier
        
        {primary   = {class = "Paladin",      role = "ANY",       spell = 498},                        -- Divine Protection
         secondary = {class = "Warrior",      role = "ANY",       spell = 97462}},                     -- Rallying Cry
         
        -- Barkskin + other
        {primary   = {class = "Druid",        role = "DAMAGER",   spell = 22812},                      -- Barkskin
         secondary = {class = "Paladin",      role = "ANY",       spell = 6940}},                      -- Hand of Sacrifice
        {primary   = {class = "Druid",        role = "HEALER",    spell = 22812},                      -- Barkskin
         secondary = {class = "Paladin",      role = "ANY",       spell = 6940}},                       -- Hand of Sacrifice
        
        {primary   = {class = "Druid",        role = "DAMAGER",   spell = 22812},                      -- Barkskin
         secondary = {class = "Priest",       role = "HEALER",    spell = 33206}},                     -- Pain Suppression
        {primary   = {class = "Druid",        role = "HEALER",    spell = 22812},                      -- Barkskin
         secondary = {class = "Priest",       role = "HEALER",    spell = 33206}},                     -- Pain Suppression        
        
        {primary   = {class = "Druid",        role = "DAMAGER",   spell = 22812},                      -- Barkskin
         secondary = {class = "Priest",       role = "HEALER",    spell = 62618}},                     -- Power Word: Barrier
        {primary   = {class = "Druid",        role = "HEALER",    spell = 22812},                      -- Barkskin
         secondary = {class = "Priest",       role = "HEALER",    spell = 62618}},                     -- Power Word: Barrier
        
        {primary   = {class = "Druid",        role = "HEALER",    spell = 22812},                      -- Barkskin
         secondary = {class = "Warrior",      role = "ANY",       spell = 97462,}},                    -- Rallying Cry
        {primary   = {class = "Druid",        role = "DAMAGER",   spell = 22812},                      -- Barkskin
         secondary = {class = "Warrior",      role = "ANY",       spell = 97462,}},                    -- Rallying Cry

        -- Soul Link + other
        {primary   = {class = "Warlock",      role = "ANY",       spell = 79957},                      -- Soul Link
         secondary = {class = "Paladin",      role = "ANY",       spell = 6940}},                      -- Hand of Sacrifice
        
        {primary   = {class = "Warlock",      role = "ANY",       spell = 79957},                      -- Soul Link
         secondary = {class = "Priest",       role = "HEALER",    spell = 33206}},                     -- Pain Suppression
        
        {primary   = {class = "Warlock",      role = "ANY",       spell = 79957},                      -- Soul Link
        secondary =  {class = "Priest",       role = "HEALER",    spell = 62618}},                     -- Power Word: Barrier
        
        {primary   = {class = "Warlock",      role = "ANY",       spell = 79957},                      -- Soul Link
         secondary = {class = "Warrior",      role = "ANY",       spell = 97462,}},                    -- Rallying Cry
        
        -- Shield Wall + other
        {primary   = {class = "Warrior",      role = "ANY",       spell = 871},                        -- Shield Wall
         secondary = {class = "Priest",       role = "HEALER",    spell = 33206}},                     -- Pain Suppression
        
        {primary   = {class = "Warrior",      role = "ANY",       spell = 871},                        -- Shield Wall
         secondary = {class = "Paladin",      role = "ANY",       spell = 6940}},                      -- Hand of Sacrifice
        
        {primary   = {class = "Warrior",      role = "ANY",       spell = 871},                        -- Shield Wall
         secondary = {class = "Priest",       role = "HEALER",    spell = 62618}},                     -- Power Word: Barrier
        
        -- Feint + other
        {primary   = {class = "Rogue",        role = "ANY",       spell = 1966},                       -- Feint
         secondary = {class = "Paladin",      role = "ANY",       spell = 6940}},                      -- Hand of Sacrifice
        
        
        --------------------------
        -- 2 Personal cooldowns --
        --------------------------
        {primary   = {class = "Death Knight",  role = "DAMAGER",   spell = 31662},                 -- Anti-Magic Shell
         secondary = {class = "Death Knight",  role = "DAMAGER",   spell = 48792, cond = "SELF"}}, -- Icebound Fortitude
        {primary   = {class = "Warrior",       role = "TANK",      spell = 871},                   -- Shield Wall
         secondary = {class = "Warrior",       role = "TANK",      spell = 12975, cond = "SELF"}}, -- Last Stand
        
        ------------------------------------------
        -- 2 External cooldowns (single source) --
        ------------------------------------------
        {primary   = {class = "Priest",        role = "HEALER",    spell = 62618, cond = "EXT"}, -- Power Word: Barrier
         secondary = {class = "Priest",        role = "HEALER",    spell = 33206}},              -- Pain Suppression
        
        ---------------------------------------
        -- 2 External cooldowns (two people) --
        ---------------------------------------
        {secondary = {class = "Paladin",       role = "ANY",       spell = 6940, cond = "NON-SELF"}, -- Hand of Sacrifice
         tertiary   = {class = "Priest",        role = "HEALER",   spell = 33206, cond = "EXT"}},    -- Pain Suppression
        {secondary = {class = "Paladin",       role = "ANY",       spell = 6940, cond = "NON-SELF"}, -- Hand of Sacrifice
         tertiary   = {class = "Warrior",        role = "ANY",     spell = 97462}},                  -- Rallying Cry
    }
    
    local function ProcessCooldownCombinations()
        local combos = {}
        for _,combo in ipairs(COOLDOWN_COMBINATIONS) do
            if combo.primary and combo.secondary then
                if combo.primary.cond and combo.primary.cond == "EXT" then
                    combos[format("%d+%d",combo.primary.spell,combo.secondary.spell)] = combo
                else
                    combos[format("%dx%d",combo.primary.spell,combo.secondary.spell)] = combo
                end
            elseif combo.primary and not combo.secondary then
                combos[format("%d",combo.primary.spell)] = combo
            elseif not combo.primary and combo.secondary and not combo.tertiary then
                combos[format("x%d",combo.secondary.spell)] = combo
            elseif not combo.primary and combo.secondary and combo.tertiary then
                combos[format("%da%d",combo.secondary.spell,combo.tertiary.spell)] = combo
            end
        end
        COOLDOWN_COMBINATIONS = combos
    end
    ProcessCooldownCombinations()
    
    local getnextselfcd = function(values)
        local firstCombinded
        for k,v in pairs(values) do
            if type(tonumber(k)) == "number" then return k end
            if not firstCombinded then firstCombinded = k end
        end
        
        return firstCombinded
    end
    
    local lastnumspells
    local getcooldowns = function(info) 
        local values = {}
        local numspells = 0
        if info then
            local spell = info[#info]
            local person = string.match(info[#info],"(hot_%d_%d)_cd")
            local unitOption = TraversOptions(info.options,info,4).args[person]
            info[#info] = person
            local unit = unitOption.get(info,true)
            if unit then
                for comboKey,combo in pairs(COOLDOWN_COMBINATIONS) do
                    if combo.primary and not combo.secondary then
                        local role = UnitGroupRolesAssigned(unit)
                        if (combo.primary.role == "ANY" or role == combo.primary.role) -- Role matches
                            and combo.primary.class == UnitClass(unit) then            -- Class matches
                            local spellid = combo.primary.spell
                            values[comboKey] = format("|T%s:16:16|t %s",ST[spellid], SN[spellid])
                            numspells = numspells + 1
                        end
                    elseif not combo.primary and combo.secondary and not combo.tertiary then
                        if #ListOfClass(combo.secondary.class, combo.secondary.role) > 0 then
                            local flag = true
                            if combo.secondary.cond and combo.secondary.cond == "NON-SELF" then
                                local class = UnitClass(unit)
                                if UnitClass(unit) == combo.secondary.class and #ListOfClass(class) < 2 then
                                    flag = false
                                end
                            end
                            if flag then
                                local spellid = combo.secondary.spell
                                values[comboKey] = format("|T%s:16:16|t %s",ST[spellid], SN[spellid])
                                numspells = numspells + 1
                            end
                        end
                    elseif not combo.primary and combo.secondary and combo.tertiary then
                        local flag = true
                        if combo.secondary.cond and combo.secondary.cond == "NON-SELF" then
                            if UnitClass(unit) == combo.secondary.class and #ListOfClass(combo.secondary.class) < 2 then flag = false end
                        end
                        
                        if flag and combo.tertiary.cond and combo.tertiary.cond == "NON-SELF" then
                            if UnitClass(unit) == combo.tertiary.class and #ListOfClass(combo.tertiary.class) < 2 then flag = false end
                        end
                        if flag and #ListOfClass(combo.secondary.class, combo.secondary.role) < 1 then flag = false end
                        if flag and #ListOfClass(combo.tertiary.class, combo.tertiary.role) < 1 then flag = false end
                        if flag then
                            local spellid1 = combo.secondary.spell
                            local spellid2 = combo.tertiary.spell
                            values[comboKey] = format("|T%s:16:16|t %s + |T%s:16:16|t %s", ST[spellid1], SN[spellid1], ST[spellid2], SN[spellid2])
                            numspells = numspells + 1
                        end
                    else
                        local flag = true
                        local p_spellid = combo.primary.spell
                        local s_spellid = combo.secondary.spell
                        local role = UnitGroupRolesAssigned(unit)
                        
                        if (combo.primary.role ~= "ANY" and role ~= combo.primary.role) or UnitClass(unit) ~= combo.primary.class then
                            flag = false
                        end
                        
                        if #ListOfClass(combo.secondary.class) < 1 then
                            flag = false
                        end
                        
                        if combo.secondary.cond and combo.secondary.cond == "NON-SELF" then
                            local class = UnitClass(unit)
                            if UnitClass(unit) == combo.secondary.class and #ListOfClass(class) < 2 then -- Only unit's class available for the CD and can't be casted on self
                                flag = false
                            end
                        elseif #ListOfClass(combo.secondary.class, combo.secondary.role) < 1 then
                            flag = false
                        end
                        
                        if combo.primary.cond and combo.primary.cond == "EXT" then
                            if #ListOfClass(combo.primary.class, combo.primary.role) > 0 then
                                flag = true
                            else
                                flag = false
                            end
                        end
                        
                        if flag then
                            values[comboKey] = format("|T%s:16:16|t %s + |T%s:16:16|t %s", ST[p_spellid], SN[p_spellid], ST[s_spellid], SN[s_spellid])
                            numspells = numspells + 1
                        end
                    end
                end
                
                local currentCooldown = addon.db.profile.Encounters[info[#info-2]].misc[spell]["value"] 
                if not currentCooldown or not values[currentCooldown] then
                    addon.db.profile.Encounters[info[#info-2]].misc[spell]["value"] = getnextselfcd(values)
                end
                --[[
                -- Personal cooldowns
                if UnitGroupRolesAssigned(unit) == "TANK" and  UnitClass(unit) == "Paladin" then
                    --values[#values] = format("|T%s:16:16|t %s",ST[642], SN[642]) -- Divine Shield
                    values["642"] = format("|T%s:16:16|t %s",ST[642], SN[642]) -- Divine Shield
                elseif UnitClass(unit) == "Priest" then
                    values["47585"] = format("|T%s:16:16|t %s",ST[47585], SN[47585]) -- Dispersion
                end
                -- Other people's cooldowns
                local paladins = ListOfClasses("Paladin")
                if #paladins > 0 then
                    if UnitClass(unit) == "Druid" then
                        values["22812x6940"] = format("|T%s:16:16|t %s + |T%s:16:16|t %s", ST[22812], SN[22812], ST[6940], SN[6940]) -- Barkskin + Hand of Sacrifice
                    elseif UnitClass(unit) == "Priest" then
                        values["47585x6940"] = format("|T%s:16:16|t %s + |T%s:16:16|t %s", ST[47585], SN[47585], ST[6940], SN[6940]) -- Dispersion + Hand of Sacrifice
                    end
                end]]
            end
        end
        lastnumspells = numspells
        return values
    end
    
    local lastinfo, lastinfo2, lastnumcasters, lastnumcasters2
    
    local getoffcaster = function(info)
        local numcasters = 0
        if info then
            local former = info[#info]
            local prefix = string.match(info[#info],"(hot_%d_%d_cd)_caster")
            info[#info] = prefix
            getcooldowns(info)
            info[#info] = former
            
            lastinfo = info
            local caster = info[#info]
            local person = string.match(info[#info],"(hot_%d_%d)_cd_caster")
            local spell = string.match(info[#info],"(hot_%d_%d_cd)_caster")
            local unitOption = TraversOptions(info.options,info,4).args[person]
            info[#info] = person
            local unit = unitOption.get(info,true)
            if unit then
                local spellOption = TraversOptions(info.options,info,4).args[spell]
                info[#info] = spell
                local spellid = spellOption.get(info,true)
                if spellid then
                    if type(tonumber(spellid)) == "number" then
                        addon.db.profile.Encounters[info[#info-2]].misc[caster]["value"] = unit
                        lastnumcasters = 1
                        return {[unit] = addon.CN[unit]}
                    else
                        local casterclass = COOLDOWN_COMBINATIONS[spellid].secondary.class
                        local casterrole = COOLDOWN_COMBINATIONS[spellid].secondary.role
                        local castercond = COOLDOWN_COMBINATIONS[spellid].secondary.cond
                        local candidates
                        if castercond == "SELF" then
                            candidates = {[unit] = addon.CN[unit]}
                        else
                            candidates = ListOfClass(casterclass)
                            local newcandidates = {}
                            for _,candunit in ipairs(candidates) do
                                if (casterrole == "ANY" or UnitGroupRolesAssigned(candunit) == casterrole) and (castercond ~= "NON-SELF" or not UnitIsUnit(unit,candunit)) then
                                    newcandidates[candunit] = addon.CN[candunit]
                                    numcasters = numcasters + 1
                                end
                            end
                            candidates = newcandidates
                        end
                        local currentCaster = addon.db.profile.Encounters[info[#info-2]].misc[caster]["value"] 
                        if not currentCaster or not candidates[currentCaster] then
                            addon.db.profile.Encounters[info[#info-2]].misc[caster]["value"] = next(candidates)
                        end
                        lastnumcasters = numcasters
                        return candidates
                    end
                end
            end
        end
        
        return {}
    end
    
    local offcaster_disabled = function()
        if hot_priorities_disabled() then return true end
        local info = lastinfo
        if info then
            local caster = info[#info]
            local spell = string.match(info[#info],"(hot_%d_%d_cd)_caster")
            local spellOption = TraversOptions(info.options,info,4).args[spell]
            info[#info] = spell
            local spellid = spellOption.get(info,true)
            if not spellid then return true end -- no cooldown selected
            if type(tonumber(spellid)) == "number" then return true end -- spell is self buff
            if lastnumcasters < 2 then return true end
        end
        
        return false
    end
    
    local getsecondoffcaster = function(info)       
        local numcasters = 0
        
        if info then
            lastinfo2 = info
            local caster2 = info[#info]
            local person = string.match(info[#info],"(hot_%d_%d)_cd_caster2")
            local spell = string.match(info[#info],"(hot_%d_%d_cd)_caster2")
            local unitOption = TraversOptions(info.options,info,4).args[person]
            info[#info] = person
            local unit = unitOption.get(info,true)
            if unit then
                local spellOption = TraversOptions(info.options,info,4).args[spell]
                info[#info] = spell
                local spellid = spellOption.get(info,true)
                if spellid then
                    if not COOLDOWN_COMBINATIONS[spellid].tertiary then
                        addon.db.profile.Encounters[info[#info-2]].misc[spell].value = nil
                        return {}
                    end
                    local caster2class = COOLDOWN_COMBINATIONS[spellid].tertiary.class
                    local caster2role = COOLDOWN_COMBINATIONS[spellid].tertiary.role
                    local caster2cond = COOLDOWN_COMBINATIONS[spellid].tertiary.cond
                    --addon.db.profile.Encounters[info[#info-2]].misc[caster2]["value"] = nil
                    local candidates = ListOfClass(caster2class)
                    local newcandidates = {}
                    for _,candunit in ipairs(candidates) do
                        if (caster2role == "ANY" or UnitGroupRolesAssigned(candunit) == caster2role) and (caster2cond ~= "NON-SELF" or not UnitIsUnit(unit,candunit)) then
                            newcandidates[candunit] = addon.CN[candunit]
                            numcasters = numcasters + 1
                        end
                    end
                    candidates = newcandidates
                    local currentCaster = addon.db.profile.Encounters[info[#info-2]].misc[caster2]["value"] 
                    if not currentCaster or not candidates[currentCaster] then
                        addon.db.profile.Encounters[info[#info-2]].misc[caster2]["value"] = next(candidates)
                    end
                    lastnumcasters2 = numcasters
                    return candidates
                end
            end
        end
        
        return {}
    end
    
    local secondoffcaster_disabled = function()
        if hot_priorities_disabled() then return true end
        
        local info = lastinfo2
        
        if info then
            local caster = info[#info]
            local spell = string.match(info[#info],"(hot_%d_%d_cd)_caster")
            local spellOption = TraversOptions(info.options,info,4).args[spell]
            info[#info] = spell
            local spellid = spellOption.get(info,true)
            if not spellid then return true end -- no cooldown selected
            if type(tonumber(spellid)) == "number" then return true end -- spell is self buff
            if lastnumcasters2 < 2 then return true end
        end
        
        return false
    end
    
    local cooldown_disabled = function()
        if hot_priorities_disabled() then return true end
        return lastnumspells == 0
    end

    local function get_hot_args()
        local HOT_DIFF_TO_SOAKERS = {
            [1] = 1,
            [2] = 3,
            [3] = 2,
            [4] = 5,
        }
        
        local diff = GetRaidDifficulty()
        if not diff then
            if GetNumRaidMembers() > 14 then
                diff = 4
            else
                diff = 3
            end
        end

        local soakermax = HOT_DIFF_TO_SOAKERS[diff]
        
        local args = {
            hot_priorities_desc = {
                type = "description",
                name = function() local diff = GetRaidDifficulty();return L.chat_dragonsoul["Groups of people chosen below will be announced through Raid Warning messages and DXE alerts will be sent to them to indicate they should soak the next Hour of Twilight."] end,
                order = 1,
            },
            enable_desc = {
                type = "description",
                name = function() 
                    if not ItemEnabled("hotpriorities", "ultraxion") then
                        return "|cffff0000To enable |r|cffffff00Hour of Twilight Priorities|r|cffff0000, enable |r|cffffff00RW:Hour of Twilight Priorities|r|cffff0000 in |r|cffffff00Announces|r|cffff0000 section above.|r"
                    else
                        return ""
                    end
                end,
                order = 2,
                fontSize = "medium",
            },
            warning_desc = {
                type = "description",
                name = function() 
                    local raidN = GetNumRaidMembers()
                    if raidN < 2 then
                        return ""
                    else
                        local withoutRoles = {}
                        for i=1,raidN do
                            local role = UnitGroupRolesAssigned("raid"..i)
                            if role == "NONE" then
                                withoutRoles[#withoutRoles+1] = i
                            end
                        end
                        if #withoutRoles > 0 then
                            local buffer = ""
                            for i,raidIndex in ipairs(withoutRoles) do
                                buffer = buffer..CN["raid"..raidIndex]
                                if i < #withoutRoles then buffer = buffer.."," end
                            end
                            
                            return format("%s |cffff0000%s have any role set!|r",buffer,#withoutRoles == 1 and "doesn't" or "don't")
                        else
                            return ""
                        end
                    end
                end,
                order = 3,
                fontSize = "medium",
            },
            timing_header = {
                type = "header",
                name = "Timing",
                order = 4,
            },
            precast_timing = {
                name = L.chat_dragonsoul["Pre-cast Timing"],
                desc = L.chat_dragonsoul["Time in seconds before the Hour of Twilight cast starts the priorities should be announced."],
                type = "range",
                min = 1,
                max = 10,
                step = 1,
                order = 5,
                default = 3,
                width = "full",
                disabled = hot_priorities_disabled,
            },
            hot_priorities_announce = {
                name = L.chat_dragonsoul["Send Setup Priorities as a Raid message"],
                desc = L.chat_dragonsoul["By clicking the button you can send the priorities setup as a raid message so that the raid members can see what selection you have made."],
                type = "execute",
                func = function() 
                    local SendChatMessage,UnitName = SendChatMessage,UnitName
                    SendChatMessage(format("{diamond}{diamond}{diamond} %s Priorities: {diamond}{diamond}{diamond}",GetSpellLink(103327)),"RAID")
                    local marks = {"{circle}","{square}","{star}","{triangle}","{diamond}","{cross}","{moon}"}
                    for hotI=1,7 do
                        local msg = format("%d %s ",hotI, marks[hotI])
                        local people = 0
                        for personI=1,soakermax do
                            local name = UnitName(ItemValue("hot_"..hotI.."_"..personI, "ultraxion"))
                            if name then
                                msg = msg..(personI>1 and ", " or "")..name
                                people = people + 1
                            end
                        end
                        if people > 0 then SendChatMessage(msg,"RAID") end
                    end
                end,
                order = 6,
                width = "full",
                disabled = hot_priorities_disabled,
            },
        }
        

        local orderIndex = 7
        for hotIndex=1,7 do
            args[format("hot_%d_header",hotIndex)] = {
                type = "header",
                name = format("Hour of Twilight #%d",hotIndex),
                order = orderIndex,
            }
            orderIndex = orderIndex + 1
            for soakerIndex=1,soakermax do
                args[format("hot_%d_%d",hotIndex,soakerIndex)] = {
                    name = soakerIndex == 1 and L.chat_dragonsoul["Soaking Person"] or function() return "" end,
                    desc = L.chat_dragonsoul["Select the player to be announced."],
                    type = "select",
                    values = function() return GetPlayerList() end,
                    order = orderIndex,
                    validate = true,
                    disabled = hot_priorities_disabled,
                }
                args[format("hot_%d_%d_cd",hotIndex,soakerIndex)] = {
                    name = function() return "" end,
                    desc = L.chat_dragonsoul["Cooldown to be used."],
                    type = "select",
                    values = getcooldowns,
                    order = orderIndex + 3,
                    width = "double",
                    disabled = cooldown_disabled,
                }
                args[format("hot_%d_%d_cd_caster",hotIndex,soakerIndex)] = {
                    name = soakerIndex == 1 and L.chat_dragonsoul["External Cooldown Caster"] or function() return "" end,
                    desc = L.chat_dragonsoul["Caster of the second cooldown person is to receive."],
                    type = "select",
                    values = getoffcaster,
                    order = orderIndex + 1,
                    disabled = offcaster_disabled,
                }
                if addon.db.profile.Encounters.ultraxion.misc then
                    if addon.db.profile.Encounters.ultraxion.misc and addon.db.profile.Encounters.ultraxion.misc["hot_"..hotIndex.."_"..soakerIndex.."_cd"] then
                        local cooldown = addon.db.profile.Encounters.ultraxion.misc["hot_"..hotIndex.."_"..soakerIndex.."_cd"].value
                        if cooldown and (cooldown):match("%d*.*%d+a%d+") then
                            args[format("hot_%d_%d_cd_caster2",hotIndex,soakerIndex)] = {
                            name = soakerIndex == 1 and L.chat_dragonsoul["External Cooldown Caster 2"] or function() return "" end,
                            desc = L.chat_dragonsoul["Caster of the other cooldown person is to receive."],
                            type = "select",
                            values = getsecondoffcaster,
                            order = orderIndex + 2,
                            disabled = secondoffcaster_disabled,
                        }
                        end
                    end
                end
                args[format("hot_%d_%d_blank",hotIndex,soakerIndex)] = addon.Options.genblank(orderIndex + 4)
                orderIndex = orderIndex + 5
            end
        end
        
        return args
    end

    
	local data = {
		version = 7,
		key = "ultraxion",
		zone = L.zone["The Dragon Wastes"],
		category = L.zone["Dragon Soul"],
		name = L.npc_dragonsoul["Ultraxion"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Ultraxion.blp",
		triggers = {
			scan = {
				55294, -- Ultraxion
			},
		},
        onpullevent = {
            {
                triggers = {
                    yell = L.chat_dragonsoul["I am the beginning of the end"],
                },
                invoke = {
                    {
                       "alert","landscd",
                    },
                },
            },
        },
		onactivate = {
			tracing = {
				55294, -- Ultraxion
			},
			tracerstart = true,
			combatstop = true,
			defeat = 55294,
		},
		userdata = {
			-- Texts
            hotprioritiestext = "",
            hot_player1 = "",
            hot_player2 = "",
            hot_player3 = "",
            hot_player4 = "",
            hot_player5 = "",
            
            -- Counters
            hotcounter = 1,
            
            -- Timers
            lightdur = "",
            
            -- Switches
            midnightfailedannounced = "no",
            
            -- Lists
            lightunits = {type = "container", wipein = 3},
            hourunits = {type = "container"},
            midnightfailerunits = {type = "container"},
            
            -- Maps
            hotsoakerlimits = {
                type = "map", ["1"] = 1, ["2"] = 3, ["3"] = 2, ["4"] = 5,
            },
		},
		onstart = {
            {
                "set",{hotsoakersmax = "&mapget|hotsoakerlimits|&difficulty&&"},
                "alert","eruptioncd",
                "alert","defendercd",
				"alert","hourcd",
				"alert","unstablecd",
                "alert","giftcd",
                "alert","sourcecd",
                "alert","essencecd",
                "alert","timeloopcd",
                "expect",{"&itemvalue|precast_timing&","~=","nil"}, -- nil check
                "scheduletimer",{"hotprioritiestimer", "&substract|46|&itemvalue|precast_timing&&"},
			},
		},
		
        raidicons = {
			lighticon = {
                varname = format("%s {%s}",SN[105925],"PLAYER_DEBUFF"),
				type = "MULTIFRIENDLY",
				persist = 10,
				reset = 2,
				unit = "#5#",
				icon = 1,
				total = 6,
                texture = ST[105925],
			},
		},
		announces = {
            midnightfailed = {
                varname = "%s failed ",
                type = "RAID",
                subtype = "achievement",
                achievement = 6084,
                msg = format(L.alert["<DXE> %s: Achievement failed! (%s)"],AL[6084],"&list|midnightfailerunits|true&"),
                throttle = true,
            },
            hotpriorities = {
                varname = "%s Priorities",
                type = "RAID_WARNING",
                subtype = "spell",
                spell = 103327,
                msg = "<hotprioritiestext>",
                enabled = false,
            },
        },
        filters = {
            bossemotes = {
                defenderemote = {
                    name = "Last Defender of Azeroth",
                    pattern = "imbues the tanks with the strength",
                    hasIcon = true,
                    texture = ST[106080],
                },
                houremote = {
                    name = "Hour of Twilight",
                    pattern = "begins casting %[Hour of Twilight%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[103327],
                },
                unstableemote = {
                    name = "Unstable Monstrosity",
                    pattern = "becomes %[More Unstable%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[106377],
                },
                giftemote = {
                    name = "Gift of Life",
                    pattern = "summons forth the %[Gift of Life%]",
                    hasIcon = true,
                    texture = ST[105896],
                },
                sourceemote = {
                    name = "Source of Magic",
                    pattern = "summons forth the %[Source of Magic%]",
                    hasIcon = true,
                    texture = ST[105903],
                },
                essenceemote = {
                    name = "Essence of Dreams",
                    pattern = "summons forth the %[Essence of Dreams%]",
                    hasIcon = true,
                    texture = ST[105900],
                },
                timeloopemote = {
                    name = "Timeloop",
                    pattern = "imbues you with a %[Timeloop%]",
                    hasIcon = true,
                    texture = ST[105984],
                },
            },
            raidwarnings = {
                soakrwfilter = {
                    name = "Soak Filter",
                    pattern = " {circle} ",
                    hide = true,
                },
                soakrwfilter_others = {
                    name = "Soak Filter (other players only)",
                    pattern = UnitName("player").." {circle} ",
                },
            },
        },
		misc = {
            name = format("|T%s:16:16|t %s",ST[103327],L.chat_dragonsoul["Hour of Twilight Priorities"]),
            args = get_hot_args,
        },
        phrasecolors = {
            {"HoT","MAGENTA"},
            -- Paladin
            {SN[642],"YELLOW"}, -- Divine Shield
            {SN[498],"YELLOW"}, -- Divine Protection
            {SN[31850],"YELLOW"}, -- Ardent Defender
            {SN[6940],"YELLOW"}, -- Hand of Sacrifice
            {SN[86150],"YELLOW"}, -- Guardian of Ancient Kings
            -- Priest
            {SN[47585],"YELLOW"}, -- Dispersion
            {SN[33206],"YELLOW"}, -- Pain Suppression
            {SN[47788],"YELLOW"}, -- Guardian Spirit
            {SN[62618],"YELLOW"}, -- Power Word: Barrier
            
            -- Warlock
            {SN[6203],"YELLOW"}, -- Soulstone
            {SN[79957],"YELLOW"}, -- Soul Link
            
            -- Death Knight
            {SN[31662],"YELLOW"}, -- Anti-Magic Shell
            {SN[48792],"YELLOW"}, -- Icebound Fortitude
            {SN[61999],"YELLOW"}, -- Raise Ally
            
            -- Mage
            {SN[86948],"YELLOW"}, -- Cauterize
            {SN[27619],"YELLOW"}, -- Ice Block
            
            -- Hunter
            {SN[19263],"YELLOW"}, -- Deterrence
            
            -- Druid
            {SN[22812],"YELLOW"}, -- Barkskin
            {SN[50322],"YELLOW"}, -- Survival Instincts
            {SN[20484],"YELLOW"}, -- Rebirth
            
            -- Warrior
            {SN[871],"YELLOW"}, -- Shield Wall
            {SN[12975],"YELLOW"}, -- Last Stand
            {SN[97462],"YELLOW"}, -- Rallying Cry
            
            -- Rogue
            {SN[31224], "YELLOW"}, -- Cloak of Shadows
            {SN[1966], "YELLOW"}, -- Feint
            
            -- Shaman
            {SN[20608], "YELLOW"}, -- Reincarnation
        },
        grouping = {
            {
                general = true,
                alerts = {"landscd"},
            },
            {
                name = format("|cffffd700%s|r","Ultraxion"),
                icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Ultraxion",
                sizing = {aspect = 2, w = 128, h = 64},
                alerts = {"eruptioncd","eruptionwarn","hourcd","hourwarn","hourcasting","soakwarn","buffwarn","unstablecd","unstablewarn","lightcd","lightwarn","lightselfwarn"},
            },
            {
                name = format("|cffffd700%s|r","Protection of the Aspects"),
                icon = "Interface\\ICONS\\INV_Misc_Gem_Variety_01",
                alerts = {"defendercd","giftcd","essencecd","sourcecd","timeloopcd"},
            },            
        },
        
        alerts = {
            -- Ultraxion lands
            landscd = {
                varname = format(L.alert["%s CD"],"Ultraxion attackable"),
                type = "dropdown",
                text = format(L.alert["%s"],"Ultraxion attackable"),
                time = 29,
                flashtime = 10,
                color1 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[106080],
            },
            -- Twilight Eruption
            eruptioncd = {
                varname = format(L.alert["%s CD"],SN[106388]),
                type = "dropdown",
                text = format(L.alert["%s (Berserk)"],SN[106388]),
                time = 360,
                flashtime = 5,
                color1 = "RED",
                sound = "MINORWARNING",
                icon = ST[106388],
            },
            eruptionwarn = {
                varname = format(L.alert["%s Warning"],SN[106388]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[106388]),
                time = 5,
                color1 = "MAGENTA",
                sound = "BEWARE",
                icon = ST[106388],
            },
            -- Last Defender of Azeroth
            defendercd = {
                varname = format(L.alert["%s CD"],SN[106080]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[106080]),
                time = 10,
                flashtime = 5,
                color1 = "PURPLE",
                sound = "MINORWARNING",
                icon = ST[106080],
            },
            -- Hour of Twilight
			hourcd = {
				varname = format(L.alert["%s CD"],SN[103327]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[103327]),
				time = 46,
				flashtime = 10,
				color1 = "INDIGO",
				icon = ST[103327],
                counter = true,
			},
            hourwarn = {
                varname = format(L.alert["%s Warning"],SN[103327]),
                type = "simple",
                text = format(L.alert["%s"],SN[103327]),
                time = 1,
                color1 = "RED",
                sound = "BEWARE",
                icon = ST[103327],
                counter = true,
            },
			hourcasting = {
				varname = format(L.alert["%s Casting"],SN[103327]),
				type = "centerpopup",
				text = format(L.alert["%s"],SN[103327]),
				time = 5,
				time10n = 5,
				time10h = 3, -- ???
				time25n = 5,
				time25h = 3, -- ???
				color1 = "MAGENTA",
				icon = ST[103327],
				sound = "None",
                audiocd = true,
			},
            -- Soak Hour of Twilight (Heroic)
            soakwarn = {
                varname = format(L.alert["%s (%s) Warning"],SN[103327],"Soaker"),
                type = "simple",
                text = "<soaktext>",
                textp = "<soaktext>",
                remoteparameters = {"soaktext"},
                remote = true,
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "None",
                texture = ST[103327],
            },
            -- Buff the Soaker of Hour of Twilight (Heroic)
            buffwarn = {
                varname = format(L.alert["%s Warning"],"Buff Soaker of "..SN[103327]),
                type = "simple",
                text = "<bufftext>",
                textp = "<bufftext>",
                remoteparameters = {"bufftext"},
                remote = true,
                time = 1,
                color1 = "WHITE",
                sound = "None",
                texture = ST[103327]
            },
            --[[soakselfwarn = {
                varname = format(L.alert["%s Warning"],"Hour of Twilight Soak"),
                type = "simple",
                text = format(L.alert["<%s> soak the next HoT"],L.alert["YOU"]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[72055],
                remote = true,
            },]]
            -- Fading Light
			lightselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[105925]),
				type = "centerpopup",
				text = format(L.alert["%s on %s"],SN[105925],L.alert["YOU"]),
				time = "<lightdur>",
				flashtime = 5,
				color1 = "GOLD",
				icon = ST[105925],
				flashscreen = true,
                emphasizewarning = true,
                audiocd = true,
			},
			lightwarn = {
				varname = format(L.alert["%s Warning"],SN[105925]),
				type = "simple",
				text = format(L.alert["%s on %s"],SN[105925],"&list|lightunits&"),
				time = 3,
				flashtime = 3,
				color1 = "GOLD",
				icon = ST[105925],
				sound = "ALERT1",
				throttle = 1.5,
			},
            lightcd = {
                varname = format(L.alert["%s CD"],SN[105925]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[105925]),
                time = 15, -- normal
                time2 = 10, -- hc
                time3 = 20, -- normal (HoT)
                time4 = 13, -- hc (HoT)
                flashtime = 5,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[105925],
            },
            -- Unstable Monstrosity
			unstablecd = {
				varname = format(L.alert["%s CD"],SN[106377]),
				type = "dropdown",
				text = format(L.alert["Next %s"],SN[106377]),
				time = 60,
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[106377],
                counter = true,
			},
			unstablewarn = {
				varname = format(L.alert["%s Warning"],SN[106377]),
				type = "simple",
				text = format(L.alert["%s"],SN[106377]),
				time = 3,
				color1 = "PURPLE",
				icon = ST[106377],
				sound = "ALERT2",
                counter = true,
			},
            -- Gift of Life
            giftcd = {
                varname = format(L.alert["%s CD"],SN[105896]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[105896]),
                time = 80,
                flashtime = 5,
                color1 = "RED",
                sound = "MINORWARNING",
                icon = ST[105896],
            },
            -- Essence of Dreams
            essencecd = {
                varname = format(L.alert["%s CD"],SN[105900]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[105900]),
                time = 146,
                flashtime = 5,
                color1 = "LIGHTGREEN",
                sound = "MINORWARNING",
                icon = ST[105900],
            },
            -- Source of Magic
            sourcecd = {
                varname = format(L.alert["%s CD"],SN[105903]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[105903]),
                time = 206,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[105903],
            },
            -- Timeloop
            timeloopcd = {
                varname = format(L.alert["%s CD"],SN[105984]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[105984]),
                time = 291,
                flashtime = 5,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[105984],
            },
		},
        timers = {
            lighttimer = {
                {
                    "alert","lightwarn",
                },
            },
            midnightfailedtimer = {
                {
                    "set",{midnightfailedannounced = "yes"},
                    "announce","midnightfailed",
                },
            },
            hotprioritiestimer = {
                {
                    "expect",{"&itemenabled|hotpriorities&","==","true"},
                    "expect",{"<hotcounter>","<","8"},
                    "forloop",{
                        {"hotsoakercounter",1,"<hotsoakersmax>"},
                        {
                            "run","hotpriorities",
                        },
                    },
                    "set",{hotcounter = "INCR|1"},
                },
            },
        },
        batches = {
            hotpriorities = {
                {
                    "expect",{"&itemenabled|hotpriorities&","==","true"},
                    -- ==================== THE RAID WARNING PART ====================
                    "set",{
                        hotplayer = "&unitname|&itemvalue|hot_<hotcounter>_<hotsoakercounter>&&",
                        hotcds = "&itemvalue|hot_<hotcounter>_<hotsoakercounter>_cd&",
                        hotcaster = "&unitname|&itemvalue|hot_<hotcounter>_<hotsoakercounter>_cd_caster&&",
                    },
                    "invoke",{
                        {
                            "expect",{"&isnumber|<hotcds>&","==","true"},
                            "set",{hotcdname = format("%s", "&sl|<hotcds>&")}, -- CD is a single ID
                            "set",{hotprioritiestext = format("%s {circle} %s","<hotplayer>","<hotcdname>")},
                        },
                        {
                            "expect",{"&isnumber|<hotcds>&","==","false"}, -- CDs are a combination
                            "set",{
                                hotcd1id = "&match|<hotcds>|^(%d+)x%d+$&", -- matching first cooldown ID
                                hotcd2id = "&match|<hotcds>|^%d*x(%d+)$&", -- matching second cooldown ID (first not required)
                            },
                            "invoke",{
                                {
                                    "expect",{"<hotcd1id>","~=","nil","OR","<hotcd2id>","~=","nil"},
                                    "set",{
                                        hotcd1name = format("%s","&sl|<hotcd1id>&"), -- nil if there is no CD #1
                                        hotcd2name = format("%s","&sl|<hotcd2id>&")
                                    },
                                    "invoke",{
                                        {   -- 2 personal cooldowns
                                            "expect",{"<hotplayer>","==","<hotcaster>"},
                                            "expect",{"<hotcd1id>","~=","nil"},
                                            "set",{hotprioritiestext = format("%s {circle} %s + %s","<hotplayer>","<hotcd1name>","<hotcd2name>")},
                                        },
                                        {   -- 1 personal and 1 external cooldown
                                            "expect",{"<hotplayer>","~=","<hotcaster>"},
                                            "expect",{"<hotcd1id>","~=","nil"},
                                            "set",{hotprioritiestext = format("%s {circle} %s + %s (%s)","<hotplayer>","<hotcd1name>","<hotcd2name>","<hotcaster>")},
                                        },
                                        {   -- 1 personal cooldown
                                            "expect",{"<hotplayer>","==","<hotcaster>"},
                                            "expect",{"<hotcd1id>","==","nil"},
                                            "set",{hotprioritiestext = format("%s {circle} %s","<hotplayer>","<hotcd2name>")},
                                        },
                                        {   -- 1 external cooldown
                                            "expect",{"<hotplayer>","~=","<hotcaster>"},
                                            "expect",{"<hotcd1id>","==","nil"},
                                            "set",{hotprioritiestext = format("%s {circle} %s (%s)","<hotplayer>","<hotcd2name>","<hotcaster>")},
                                        },
                                    },
                                },
                                {
                                    "expect",{"<hotcd1id>","==","nil","AND","<hotcd2id>","==","nil"},
                                    "invoke",{
                                        {   -- 2 ext. CDs from the same person
                                            "expect",{"&match|<hotcds>|^(%d+)+%d+$&","~=","nil"},
                                            "set",{
                                                hotcd1id = "&match|<hotcds>|^(%d+)%+%d+$&", -- matching first cooldown ID
                                                hotcd2id = "&match|<hotcds>|^%d+%+(%d+)$&", -- matching second cooldown ID
                                            },
                                            "set",{
                                                hotcd1name = format("%s","&sl|<hotcd1id>&"), -- nil if there is no CD #1
                                                hotcd2name = format("%s","&sl|<hotcd2id>&")
                                            },
                                            "invoke",{
                                                {
                                                    "expect",{"<hotplayer>","==","<hotcaster>"},
                                                    "set",{hotprioritiestext = format("%s {circle} %s + %s","<hotplayer>","<hotcd1name>","<hotcd2name>")},
                                                },
                                                {
                                                    "expect",{"<hotplayer>","~=","<hotcaster>"},
                                                    "set",{hotprioritiestext = format("%s {circle} %s (%s) + %s (%s)","<hotplayer>","<hotcd1name>","<hotcaster>","<hotcd2name>","<hotcaster>")},
                                                },
                                            },
                                        },
                                        {    -- 2 ext. CDs from different people
                                            "expect",{"&match|<hotcds>|^(%d+)a%d+$&","~=","nil"},
                                            "set",{
                                                hotcd1id = "&match|<hotcds>|^(%d+)a%d+$&", -- matching first cooldown ID
                                                hotcd2id = "&match|<hotcds>|^%d+a(%d+)$&", -- matching second cooldown ID
                                                hotsecondcaster = "&unitname|&itemvalue|hot_<hotcounter>_<hotsoakercounter>_cd_caster2&&",
                                            },
                                            "set",{
                                                hotcd1name = format("%s","&sl|<hotcd1id>&"),
                                                hotcd2name = format("%s","&sl|<hotcd2id>&")
                                            },
                                            "invoke",{
                                                {
                                                    "expect",{"<hotplayer>","~=","<hotcaster>"},
                                                    "expect",{"<hotplayer>","~=","<hotsecondcaster>"},
                                                    "set",{hotprioritiestext = format("%s {circle} %s (%s) + %s (%s)","<hotplayer>","<hotcd1name>","<hotcaster>","<hotcd2name>","<hotsecondcaster>")},
                                                },
                                                {
                                                    "expect",{"<hotplayer>","==","<hotcaster>"},
                                                    "expect",{"<hotplayer>","~=","<hotsecondcaster>"},
                                                    "set",{hotprioritiestext = format("%s {circle} %s + %s (%s)","<hotplayer>","<hotcd1name>","<hotcd2name>","<hotsecondcaster>")},
                                                },
                                                {
                                                    "expect",{"<hotplayer>","~=","<hotcaster>"},
                                                    "expect",{"<hotplayer>","==","<hotsecondcaster>"},
                                                    "set",{hotprioritiestext = format("%s {circle} %s + %s (%s)","<hotplayer>","<hotcd2name>","<hotcd1name>","<hotcaster>")},
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                    "announce","hotpriorities",
                },
                {
                    "expect",{"&itemenabled|hotpriorities&","==","true"},
                    -- ==================== THE DXE WARNING PART ====================
                    "set",{
                        hotcd = "&itemvalue|hot_<hotcounter>_<hotsoakercounter>_cd&",
                        hotplayer = "&unitname|&itemvalue|hot_<hotcounter>_<hotsoakercounter>&&",
                        hotcaster = "&unitname|&itemvalue|hot_<hotcounter>_<hotsoakercounter>_cd_caster&&",
                    },
                    "invoke",{
                        {
                            "expect",{"<hotplayer>","==","&playername&"},
                            "set",{hotcdname = ""},
                            "invoke",{
                                {
                                    "expect",{"&isnumber|<hotcd>&","==","false"},
                                    "invoke",{
                                        {
                                            "expect",{"<hotplayer>","==","<hotcaster>"},
                                            "invoke",{
                                                {
                                                    "expect",{"&match|<hotcd>|^%d*x%d+$&","~=","nil"},
                                                    "set",{hotcd1id = "&match|<hotcd>|^(%d+)x%d+$&"},
                                                    "set",{hotcd2id = "&match|<hotcd>|^%d*x(%d+)$&"},
                                                    "invoke",{
                                                        {   -- 2 personal cooldowns
                                                            "expect",{"<hotcd1id>","~=","nil"},
                                                            "set",{
                                                                hotcd1icon = "&st|<hotcd1id>&",
                                                                hotcd1name = "&sn|<hotcd1id>&",
                                                                hotcd2icon = "&st|<hotcd2id>&",
                                                                hotcd2name = "&sn|<hotcd2id>&",
                                                            },
                                                            "set",{
                                                                hotcdname = format("|T%s:16:16|t%s + |T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>","<hotcd2icon>","<hotcd2name>"),
                                                            },
                                                        },
                                                        {   -- 1 external cooldown (from player himself)
                                                            "expect",{"<hotcd1id>","==","nil"},
                                                            "expect",{"<hotcaster>","==","&playername&"},
                                                            "set",{
                                                                hotcd2name = "&sn|<hotcd2id>&",
                                                                hotcd2icon = "&st|<hotcd2id>&",
                                                            },
                                                            "set",{
                                                                hotcdname = format("|T%s:16:16|t%s","<hotcd2icon>","<hotcd2name>"),
                                                            },
                                                        },
                                                    },
                                                },
                                                {
                                                    "expect",{"&match|<hotcd>|^%d+%+%d+$&","~=","nil"},
                                                    "set",{hotcd1id = "&match|<hotcd>|^(%d+)%+%d+$&"},
                                                    "set",{hotcd2id = "&match|<hotcd>|^%d+%+(%d+)$&"},
                                                    "set",{
                                                        hotcd1icon = "&st|<hotcd1id>&",
                                                        hotcd1name = "&sn|<hotcd1id>&",
                                                        hotcd2icon = "&st|<hotcd2id>&",
                                                        hotcd2name = "&sn|<hotcd2id>&",
                                                    },
                                                    "set",{
                                                        hotcdname = format("|T%s:16:16|t%s + |T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>","<hotcd2icon>","<hotcd2name>"),
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            "expect",{"&match|<hotcd>|^%d+a%d+$&","~=","nil"},
                                            "set",{hotcd1id = "&match|<hotcd>|^(%d+)a%d+$&"},
                                            "set",{hotcd2id = "&match|<hotcd>|^%d+a(%d+)$&"},
                                            "set",{
                                                hotcd1icon = "&st|<hotcd1id>&",
                                                hotcd1name = "&sn|<hotcd1id>&",
                                                hotcd2icon = "&st|<hotcd2id>&",
                                                hotcd2name = "&sn|<hotcd2id>&",
                                            },
                                            "set",{
                                                hotsecondcaster = "&unitname|&itemvalue|hot_<hotcounter>_<hotsoakercounter>_cd_caster2&&",
                                            },
                                            "invoke",{
                                                {   -- Player soaks with the first CD from combo of different players
                                                    "expect",{"<hotplayer>","==","<hotcaster>"},
                                                    "set",{
                                                        hotcdname = format("|T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>"),
                                                    },
                                                },
                                                {   -- Player soaks with the second CD from combo of different players
                                                    "expect",{"<hotplayer>","==","<hotsecondcaster>"},
                                                    "set",{
                                                        hotcdname = format("|T%s:16:16|t%s","<hotcd2icon>","<hotcd2name>"),
                                                    },
                                                },
                                            },
                                        },
                                        {   -- 1 personal cooldown (from a combo)
                                            "expect",{"&match|<hotcd>|^%d+x%d+$&","~=","nil"},
                                            "expect",{"<hotplayer>","~=","<hotcaster>"},
                                            "set",{hotcd1id = "&match|<hotcd>|^(%d+)x%d+$&"},
                                            "expect",{"<hotcd1id>","~=","nil"},
                                            "set",{
                                                hotcd1name = "&sn|<hotcd1id>&",
                                                hotcd1icon = "&st|<hotcd1id>&",
                                            },
                                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>")},
                                        },
                                    },
                                },
                            },
                            "invoke",{
                                {   -- 1 personal cooldown only
                                    "expect",{"&isnumber|<hotcd>&","==","true"},
                                    "set",{
                                        hotcdicon = "&st|<hotcd>&",
                                        hotcdname = "&sn|<hotcd>&",
                                    },
                                    "set",{hotcdname = format("|T%s:16:16|t%s","<hotcdicon>","<hotcdname>")},
                                },
                            },
                            "invoke",{
                                {
                                    "expect",{"<hotcdname>","~=",""},
                                    "set",{soaktext = format(L.alert["<%s> soak the next HoT (%s)"],L.alert["YOU"],"<hotcdname>")},
                                },
                                {
                                    "expect",{"<hotcdname>","==",""},
                                    "set",{hoticon = "&st|47573&"},
                                    "set",{soaktext = format(L.alert["|T%s:16:16|t <%s> soak the next HoT |T%s:16:16|t"],"<hoticon>",L.alert["YOU"],"<hoticon>")},
                                },
                            },
                            "alert","soakwarn",
                        },
                        {
                            "expect",{"<hotplayer>","~=","&playername&"},
                            "set",{hotcdname = ""},
                            "invoke",{
                                {
                                    "expect",{"&match|<hotcd>|^%d+a%d+$&","==","nil"},
                                    "expect",{"<hotcaster>","==","&playername&"},
                                    "set",{hotcd2id = "&match|<hotcd>|^%d*x(%d+)$&"},
                                    "invoke",{
                                        {
                                            "expect",{"<hotcd2id>","~=","nil"},
                                            "set",{
                                                hotcd2name = "&sn|<hotcd2id>&",
                                                hotcd2icon = "&st|<hotcd2id>&",
                                            },
                                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd2icon>","<hotcd2name>")},
                                        },
                                        {
                                            "expect",{"<hotcd2id>","==","nil"},
                                            "set",{
                                                hotcd1id = "&match|<hotcd>|^(%d+)%+%d+$&",
                                                hotcd2id = "&match|<hotcd>|^%d+%+(%d+)$&",
                                            },
                                            "set",{
                                                hotcd1name = "&sn|<hotcd1id>&",
                                                hotcd1icon = "&st|<hotcd1id>&",
                                                hotcd2name = "&sn|<hotcd2id>&",
                                                hotcd2icon = "&st|<hotcd2id>&",
                                            },
                                            "set",{hotcdname = format("|T%s:16:16|t%s + |T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>","<hotcd2icon>","<hotcd2name>")},
                                            
                                        },
                                    },
                                    "set",{bufftext = format(L.alert["Use %s on <%s> next HoT."],"<hotcdname>","<hotplayer>")},
                                    "alert","buffwarn",
                                },
                                {
                                    "expect",{"&match|<hotcd>|^%d+a%d+$&","~=","nil"},
                                    "set",{
                                        hotsecondcaster = "&unitname|&itemvalue|hot_<hotcounter>_<hotsoakercounter>_cd_caster2&&",
                                    },
                                    "invoke",{
                                        {
                                            "expect",{"<hotcaster>","==","&playername&"},
                                            "set",{hotcd1id = "&match|<hotcd>|^(%d+)a%d+$&"},
                                            "set",{
                                                hotcd1name = "&sn|<hotcd1id>&",
                                                hotcd1icon = "&st|<hotcd1id>&",
                                            },
                                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>")},
                                        },
                                        {
                                            "set",{hotcd2id = "&match|<hotcd>|^%d+a(%d+)$&"},
                                            "set",{
                                                hotcd2name = "&sn|<hotcd2id>&",
                                                hotcd2icon = "&st|<hotcd2id>&",
                                            },
                                            "expect",{"<hotsecondcaster>","==","&playername&"},
                                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd2icon>","<hotcd2name>")},
                                        },
                                    },
                                    "expect",{"<hotcdname>","~=",""},
                                    "set",{bufftext = format(L.alert["Use %s on <%s> next HoT."],"<hotcdname>","<hotplayer>")},
                                    "alert","buffwarn",
                                },
                            },
                        },
                    },
                    -- ==================== THE REMOTE ALERTS PART ====================
                    "set",{
                        soaktext = "",
                        bufftext = "",
                    },
                    "invoke",{
                        {   -- personal CD of another player
                            "expect",{"&isnumber|<hotcd>&","==","true"},
                            "expect",{"<hotplayer>","~=","&playername&"},
                            "set",{
                                hotcd1name = "&sn|<hotcd>&",
                                hotcd1icon = "&st|<hotcd>&",
                            },
                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>")},
                            "set",{
                                soaktext = format("<%s> soak the next HoT (%s)",L.alert["YOU"],"<hotcdname>"),
                                soakplayername = "<hotplayer>",
                            },
                            "invoke",{
                                {
                                    "expect",{"<soaktext>","~=",""},
                                    "send",{"alert","soakwarn","<soakplayername>","<soaktext>"},
                                },
                                {
                                    "expect",{"<bufftext>","~=",""},
                                    "send",{"alert","buffwarn","<buffplayername>","<bufftext>"},
                                },
                            },
                        },
                        {
                            "expect",{"&isnumber|<hotcd>&","~=","true"},
                            "invoke",{
                                {
                                    "expect",{"&match|<hotcd>|^x%d+$&","~=","nil"},
                                    "set",{hotcd2id = "&match|<hotcd>|^x(%d+)$&"},
                                    "invoke",{
                                        {
                                            "expect",{"<hotcaster>","~=","&playername&"},
                                            "invoke",{
                                                {   -- external CD from another player to himself
                                                    "expect",{"<hotcaster>","==","<hotplayer>"},
                                                    "set",{
                                                        hotcd2name = "&sn|<hotcd2id>&",
                                                        hotcd2icon = "&st|<hotcd2id>&",
                                                    },
                                                    "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd2icon>","<hotcd2name>")},
                                                    "set",{
                                                        soaktext = format("<%s> soak the next HoT (%s)",L.alert["YOU"],"<hotcdname>"),
                                                        soakplayername = "<hotplayer>",
                                                    },
                                                },
                                                {   -- external CD from another player to a different player
                                                    "expect",{"<hotcaster>","~=","<hotplayer>"},
                                                    "set",{
                                                        hotcd2name = "&sn|<hotcd2id>&",
                                                        hotcd2icon = "&st|<hotcd2id>&",
                                                    },
                                                    "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd2icon>","<hotcd2name>")},
                                                    "set",{
                                                        bufftext = format("Use %s on <%s> next HoT","<hotcdname>","<hotplayer>"),
                                                        buffplayername = "<hotcaster>",
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            "expect",{"<hotplayer>","~=","&playername&"},
                                            "expect",{"<hotcaster>","~=","<hotplayer>"},
                                            "set",{hoticon = "&st|47573&"},
                                            "set",{
                                                soaktext = format("|T%s:16:16|t <%s> soak the next HoT |T%s:16:16|t","<hoticon>",L.alert["YOU"],"<hoticon>"),
                                                soakplayername = "<hotplayer>",
                                            },
                                        },
                                    },
                                    "invoke",{
                                        {
                                            "expect",{"<soaktext>","~=",""},
                                            "send",{"alert","soakwarn","<soakplayername>","<soaktext>"},
                                        },
                                        {
                                            "expect",{"<bufftext>","~=",""},
                                            "send",{"alert","buffwarn","<buffplayername>","<bufftext>"},
                                        },
                                    },
                                },
                                {   -- Combo (1 personal + 1 external)
                                    "expect",{"&match|<hotcd>|^%d+x%d+$&","~=","nil"},
                                    "set",{hotcd1id = "&match|<hotcd>|^(%d+)x%d+$&"},
                                    "set",{hotcd2id = "&match|<hotcd>|^%d*x(%d+)$&"},
                                    "set",{
                                        hotcd1name = "&sn|<hotcd1id>&",
                                        hotcd1icon = "&st|<hotcd1id>&",
                                        hotcd2name = "&sn|<hotcd2id>&",
                                        hotcd2icon = "&st|<hotcd2id>&",
                                    },
                                    "invoke",{
                                        {
                                            "expect",{"<hotplayer>","==","<hotcaster>"},
                                            "expect",{"<hotplayer>","~=","&playername&"},
                                            "set",{hotcdname = format("|T%s:16:16|t%s + |T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>","<hotcd2icon>","<hotcd2name>")},
                                            "set",{
                                                soaktext = format("<%s> soak the next HoT (%s)",L.alert["YOU"],"<hotcdname>"),
                                                soakplayername = "<hotplayer>",
                                            },
                                        },
                                        {
                                            "expect",{"<hotplayer>","~=","<hotcaster>"},
                                            "invoke",{
                                                {
                                                    "expect",{"<hotplayer>","~=","&playername&"},
                                                    "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>")},
                                                    "set",{
                                                        soaktext = format("<%s> soak the next HoT (%s)",L.alert["YOU"],"<hotcdname>"),
                                                        soakplayername = "<hotplayer>",
                                                    },
                                                },
                                                {
                                                    "expect",{"<hotcaster>","~=","&playername&"},
                                                    "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd2icon>","<hotcd2name>")},
                                                    "set",{
                                                        bufftext = format("Use %s on <%s> next HoT","<hotcdname>","<hotplayer>"),
                                                        buffplayername = "<hotcaster>",
                                                    },
                                                    
                                                },
                                            },
                                        },
                                    },
                                    "invoke",{
                                        {
                                            "expect",{"<soaktext>","~=",""},
                                            "send",{"alert","soakwarn","<soakplayername>","<soaktext>"},
                                        },
                                        {
                                            "expect",{"<bufftext>","~=",""},
                                            "send",{"alert","buffwarn","<buffplayername>","<bufftext>"},
                                        },
                                    },
                                },
                                {   -- Two external CDs
                                    "expect",{"&match|<hotcd>|^%d+%+%d+$&","~=","nil"},
                                    "set",{hotcd1id = "&match|<hotcd>|^(%d+)%+%d+$&"},
                                    "set",{hotcd2id = "&match|<hotcd>|^%d+%+(%d+)$&"},
                                    "set",{
                                        hotcd1name = "&sn|<hotcd1id>&",
                                        hotcd1icon = "&st|<hotcd1id>&",
                                        hotcd2name = "&sn|<hotcd2id>&",
                                        hotcd2icon = "&st|<hotcd2id>&",
                                    },
                                    "invoke",{
                                        {
                                            "expect",{"<hotplayer>","==","<hotcaster>"},
                                            "set",{hotcdname = format("|T%s:16:16|t%s + |T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>","<hotcd2icon>","<hotcd2name>")},
                                            "set",{
                                                soaktext = format("<%s> soak the next HoT (%s)",L.alert["YOU"],"<hotcdname>"),
                                                soakplayername = "<hotplayer>",
                                            },
                                        },
                                        {
                                            "expect",{"<hotplayer>","~=","<hotcaster>"},
                                            "set",{hotcdname = format("|T%s:16:16|t%s + |T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>","<hotcd2icon>","<hotcd2name>")},
                                            "set",{hoticon = "&st|47573&"},
                                            "set",{
                                                bufftext = format("Use %s on <%s> next HoT","<hotcdname>","<hotplayer>"),
                                                buffplayername = "<hotcaster>",
                                                soaktext = format("|T%s:16:16|t <%s> soak the next HoT |T%s:16:16|t","<hoticon>",L.alert["YOU"],"<hoticon>"),
                                                soakplayername = "<hotplayer>",
                                            },
                                        },
                                    },
                                    "invoke",{
                                        {
                                            "expect",{"<soaktext>","~=",""},
                                            "send",{"alert","soakwarn","<soakplayername>","<soaktext>"},
                                        },
                                        {
                                            "expect",{"<bufftext>","~=",""},
                                            "send",{"alert","buffwarn","<buffplayername>","<bufftext>"},
                                        },
                                    },
                                },
                                {
                                    "expect",{"&match|<hotcd>|^%d+a%d+$&","~=","nil"},
                                    "set",{
                                        hotcd1id = "&match|<hotcd>|^(%d+)a%d+$&",
                                        hotcd2id = "&match|<hotcd>|^%d+a(%d+)$&"},
                                        hotsecondcaster = "&unitname|&itemvalue|hot_<hotcounter>_<hotsoakercounter>_cd_caster2&&",
                                    "set",{
                                        hotcd1name = "&sn|<hotcd1id>&",
                                        hotcd1icon = "&st|<hotcd1id>&",
                                        hotcd2name = "&sn|<hotcd2id>&",
                                        hotcd2icon = "&st|<hotcd2id>&",
                                    },
                                    "invoke",{
                                        {
                                            "expect",{"<hotplayer>","~=","<hotcaster>"},
                                            "expect",{"<hotplayer>","~=","<hotsecondcaster>"},
                                            -- Soak send
                                            "set",{hoticon = "&st|47573&"},
                                            "set",{
                                                soaktext = format("%s <%s> soak the next HoT %s","<hoticon>",L.alert["YOU"],"<hoticon>"),
                                                soakplayername = "<hotplayer>",
                                            },
                                            "send",{"alert","soakwarn","<soakplayername>","<soaktext>"},
                                            -- Cooldown Buff 1 send
                                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>")},
                                            "set",{
                                                bufftext = format("Use %s on <%s> next HoT","<hotcdname>","<hotplayer>"),
                                                buffplayername = "<hotcaster>",
                                            },
                                            "send",{"alert","buffwarn","<buffplayername>","<bufftext>"},
                                            -- Cooldown Buff 2 send
                                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd2icon>","<hotcd2name>")},
                                            "set",{
                                                bufftext = format("Use %s on <%s> next HoT","<hotcdname>","<hotplayer>"),
                                                buffplayername = "<hotsecondcaster>",
                                            },
                                            "send",{"alert","buffwarn","<buffplayername>","<bufftext>"},
                                        },
                                        {   -- Cooldown 1 is soaker's (soak)
                                            "expect",{"<hotplayer>","==","<hotcaster>"},
                                            "expect",{"<hotplayer>","~=","<hotsecondcaster>"},
                                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>")},
                                            "set",{
                                                soaktext = format("<%s> soak the next HoT (%s)",L.alert["YOU"],"<hotcdname>"),
                                                soakplayername = "<hotplayer>",
                                            },
                                            "send",{"alert","soakwarn","<soakplayername>","<soaktext>"},
                                            -- Cooldown 2 is a buff
                                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd2icon>","<hotcd2name>")},
                                            "set",{
                                                bufftext = format("Use %s on <%s> next HoT","<hotcdname>","<hotplayer>"),
                                                buffplayername = "<hotsecondcaster>",
                                            },
                                            "send",{"alert","buffwarn","<buffplayername>","<bufftext>"},
                                        },
                                        {   -- Cooldown 2 is soaker's
                                            "expect",{"<hotplayer>","~=","<hotcaster>"},
                                            "expect",{"<hotplayer>","==","<hotsecondcaster>"},
                                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd2icon>","<hotcd2name>")},
                                            "set",{
                                                soaktext = format("<%s> soak the next HoT (%s)",L.alert["YOU"],"<hotcdname>"),
                                                soakplayername = "<hotplayer>",
                                            },
                                            "send",{"alert","soakwarn","<soakplayername>","<soaktext>"},
                                            -- Cooldown 1 is a buff
                                            "set",{hotcdname = format("|T%s:16:16|t%s","<hotcd1icon>","<hotcd1name>")},
                                            "set",{
                                                bufftext = format("Use %s on <%s> next HoT","<hotcdname>","<hotplayer>"),
                                                buffplayername = "<hotcaster>",
                                            },
                                            "send",{"alert","buffwarn","<buffplayername>","<bufftext>"},
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
		events = {
            -- Twilight Eruption
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = 106388,
                execute = {
                    {
                        "quash","eruptioncd",
                        "alert","eruptionwarn",
                    },
                },
            },
			-- Hour of Twilight
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 103327,
				execute = {
					{
						"quash","hourcd",
						"alert","hourcd",
                        "alert","hourwarn",
						"alert","hourcasting",
                        "invoke",{
                            {
                                "expect",{"&difficulty&",">=","3"}, -- hc
                                "alert",{"lightcd",time = 4},
                            },
                            {
                                "expect",{"&difficulty&","<=","2"}, -- normal
                                "alert",{"lightcd",time = 3},
                            },
                        },
                        "expect",{"&itemvalue|precast_timing&","~=","nil"}, -- nil check
                        "scheduletimer",{"hotprioritiestimer", "&substract|46|&itemvalue|precast_timing&&"},
					},
				},
			},
            -- Minutes to Midnight
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 103327,
                execute = {
                    {
                        "expect",{"&itemenabled|midnightfailed&","==","true"},
                        "invoke",{
                            {
                                "expect",{"<midnightfailedannounced>","==","no"},
                                "expect",{"&listcontains|hourunits|#4#&","==","true"},
                                "insert",{"midnightfailerunits","#5#"},
                                "canceltimer","midnightfailedtimer",
                                "scheduletimer",{"midnightfailedtimer", 2},
                            },
                            {
                                "expect",{"<midnightfailedannounced>","==","no"},
                                "expect",{"&listcontains|hourunits|#4#&","==","false"},
                                "insert",{"hourunits","#4#"},
                            },
                        },
                    },
                },
            },
			-- Fading Light
			{
				type = "combatevent",
				eventtype = {"SPELL_AURA_APPLIED","SPELL_AURA_REFRESH"},
				spellname = 105925,
				execute = {
					{
						"raidicon","lighticon",
                        "insert",{"lightunits","#5#"},
                        "canceltimer","lighttimer",
                        "scheduletimer",{"lighttimer", 0.1},
                        "expect",{"&timeleft|lightcd&","<","1"},
                        "quash","lightcd",
                        "invoke",{
                            {
                                "expect",{"&difficulty&",">=","3"}, -- hc
                                "expect",{"&timeleft|hourcd&",">=","15"},
                                "alert",{"lightcd",time = 2},
                            },
                            {
                                "expect",{"&difficulty&","<=","2"}, -- normal
                                "expect",{"&timeleft|hourcd&",">=","15"},
                                "alert",{"lightcd",time = 1},
                            },
                        },
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{lightdur = "&playerdebuffdur|"..SN[105925].."&"},
						"quash","lightselfwarn",
                        "alert","lightselfwarn",
					},
				},
			},
			-- Unstable Monster
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 106377,
                dstnpcid = 55294,
				execute = {
					{
						"quash","unstablecd",
						"alert","unstablecd",
						"alert","unstablewarn",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end

----------------------------
-- WARMASTER BLACKHORN
----------------------------
do
    local onslaught_priorities_disabled = function() return not ItemEnabled("onslaughtpriorities", "blackhorn") end

    local COOLDOWN_COMBINATIONS = {
        {class = "Death Knight", role = "TANK",    spell = 55233}, -- Vampiric Blood
        {class = "Druid",        role = "TANK",    spell = 22842}, -- Frenzied Regeneration
        {class = "Druid",        role = "HEALER",  spell = 33891}, -- Tree of Life
        {class = "Druid",        role = "ANY",     spell = 740},   -- Tranquility
        {class = "Mage",         role = "ANY",     spell = 87023}, -- Cauterize
        {class = "Paladin",      role = "TANK",    spell = 70940}, -- Divine Guardian
        {class = "Paladin",      role = "HEALER",  spell = 31884}, -- Avenging Wrath
        {class = "Paladin",      role = "HEALER",  spell = 31821}, -- Aura Mastery
        {class = "Priest",       role = "DAMAGER", spell = 47585}, -- Dispersion
        {class = "Priest",       role = "ANY",     spell = 64843}, -- Divine Hymn
        {class = "Priest",       role = "HEALER",  spell = 62618}, -- Power Word: Barrier
        {class = "Shaman",       role = "HEALER",  spell = 98007}, -- Spirit Link Totem
        {class = "Warrior",      role = "TANK",    spell = 871},   -- Shield Wall
    }
    
    local lastnumspells
    local UnitClass,UnitGroupRolesAssigned,UnitName,GetSpellLink,SendChatMessage = UnitClass,UnitGroupRolesAssigned,UnitName,GetSpellLink,SendChatMessage
    
    local getcooldowns = function(info) 
        local values = {}
        local numspells = 0
        if info then
            local spell = info[#info]
            local person = string.match(info[#info],"(onslaught_%d)_cd") or string.match(info[#info],"(onslaught_%d)")
            local unitOption = TraversOptions(info.options,info,4).args[person]
            info[#info] = person
            local unit = unitOption.get(info,true)
            if unit and unit ~= "NONE" then
                for comboKey,combo in pairs(COOLDOWN_COMBINATIONS) do
                    if UnitClass(unit) == combo.class and (combo.role == "ANY" or UnitGroupRolesAssigned(unit) == combo.role) then
                        values[combo.spell] = format("|T%s:16:16|t %s",ST[combo.spell], SN[combo.spell])
                        numspells = numspells + 1
                    end
                end
                
                local currentCooldown = addon.db.profile.Encounters[info[#info-2]].misc[spell]["value"] 
                if not currentCooldown or not values[currentCooldown] then
                    addon.db.profile.Encounters[info[#info-2]].misc[spell]["value"] = next(values)
                end
            end
        end
        lastnumspells = numspells
        return values
    end
    
    local cooldown_disabled = function()
        return onslaught_priorities_disabled() or lastnumspells == 0
    end
    
    local lastinfo, lastnumcasters
       
    local getcaster = function(info)
        local candidates = {["NONE"] = "None"}
        local numcasters = 0
        if info then
            lastinfo = info
            for unit,name in pairs(GetPlayerList()) do
                for comboKey,combo in pairs(COOLDOWN_COMBINATIONS) do
                    if (UnitClass(unit) == combo.class) and (combo.role == "ANY" or UnitGroupRolesAssigned(unit) == combo.role) then
                        candidates[unit] = name
                        numcasters = numcasters + 1
                        break
                    end
                end
            end
        end
        
        lastnumcasters = numcasters
        
        return candidates
    end
    
    local casters_disabled = function()
        return onslaught_priorities_disabled() or lastnumcasters == 0
    end
    
    local SendPrioritiesToRaid = function()
        local FORMAT_PLAYER_SPELL = "%d - %s - %s"
        local FORMAT_NO_SPELL = "%d - {cross} No cooldown {cross}"
        local msgs = {}
        local continue = false
        
        for i=8,1,-1 do
            local key = ItemValue("onslaught_"..i, "blackhorn")
            if key ~= "NONE" or continue then
                if key == "NONE" then
                    msgs[i] = format(FORMAT_NO_SPELL,i)
                else
                    local name = UnitName(key) or "<Select again>"
                    if not continue then continue = true end
                    local spellID = tonumber(ItemValue("onslaught_"..i.."_cd", "blackhorn"))
                    
                    local spell = GetSpellLink(spellID)
                    msgs[i] = format(FORMAT_PLAYER_SPELL, i, name, spell)
                end
            end
        end
        if #msgs > 0 then 
            SendChatMessage(format("{diamond}{diamond}{diamond} %s Priorities: {diamond}{diamond}{diamond}",GetSpellLink(106401)),"RAID")
            for i,msg in ipairs(msgs) do
                SendChatMessage(msg,"RAID")
            end
        end
    end

    local function get_onslaught_args()
        local args = {            
            projectedtextures = {
                name = L.chat_dragonsoul["Projected Textures"],
                desc = L.chat_dragonsoul["Projected textures are disabled in Phase 1 and enabled in Phase 2."],
                type = "toggle",
                default = false,
                order = 1,
            },
            onslaught_priorities_desc = {
                type = "description",
                name = function() local diff = GetRaidDifficulty();return L.chat_dragonsoul["People and spells chosen below will be announced through Raid Warning messages and DXE alerts will be sent to the to indicate they should use the spell for the next Twilight Onslaught.\n\nTo enable |cffffff00Twilight Onslaught Priorities|r, enable |cffffff00RW:Twilight Onslaught Priorities|r in |cffffff00Announces|r section.\n\n|cffff0000Make sure the raid members have their roles assigned!|r"] end,
                order = 2,
            },
            enable_desc = {
                type = "description",
                name = function() 
                    if not ItemEnabled("onslaughtpriorities", "blackhorn") then
                        return "|cffff0000To enable |r|cffffff00Twilight Onslaught Priorities|r|cffff0000, enable |r|cffffff00RW:Twilight Onslaught Priorities|r|cffff0000 in |r|cffffff00Announces|r|cffff0000 section above.|r"
                    else
                        return ""
                    end
                end,
                order = 3,
                fontSize = "medium",
            },
            timing_header = {
                type = "header",
                name = "Timing",
                order = 4,
            },
            precast_timing = {
                name = L.chat_dragonsoul["Pre-cast Timing"],
                desc = L.chat_dragonsoul["Time in seconds before the Twilight Onslaught cast starts the priorities should be announced."],
                type = "range",
                min = 1,
                max = 10,
                step = 1,
                order = 5,
                default = 5,
                width = "full",
                disabled = onslaught_priorities_disabled,
            },
            send_priorities = {
                name = L.chat_dragonsoul["Send Setup Priorities as a Raid message"],
                desc = L.chat_dragonsoul["By clicking the button you can send the priorities setup as a raid message so that the raid members can see what selection you have made."],
                type = "execute",
                func = SendPrioritiesToRaid,
                order = 6,
                width = "full",
                disabled = onslaught_priorities_disabled,
            },
        }
        
        local orderIndex = 6
        for onslaughtIndex=1,8 do
            args[format("onslaught_%d",onslaughtIndex)] = {
                name = format("Twilight Onslaught #%d",onslaughtIndex),
                desc = L.chat_dragonsoul["Select the player to be announced."],
                type = "select",
                values = getcaster,
                order = orderIndex + (2 * (onslaughtIndex-1)) + 1,
                default = "NONE",
                disabled = casters_disabled,
                validate = true,
            }
            args[format("onslaught_%d_cd",onslaughtIndex)] = {
                name = function() return "" end,
                desc = L.chat_dragonsoul["Cooldown to be used."],
                type = "select",
                values = getcooldowns,
                order = orderIndex + (2 * (onslaughtIndex-1)) + 2,
                disabled = cooldown_disabled,
            }
            
            if addon.db.profile.Encounters.blackhorn.misc then
                if addon.db.profile.Encounters.blackhorn.misc and addon.db.profile.Encounters.blackhorn.misc["onslaught_"..onslaughtIndex.."_cd"] then
                    local cooldown = addon.db.profile.Encounters.blackhorn.misc["onslaught_"..onslaughtIndex.."_cd"].value
                end
            end
        end
        
        return args
    end

	local data = {
		version = 8,
		key = "blackhorn",
		zone = L.zone["Dragon Soul"],
		category = L.zone["Dragon Soul"],
		name = L.npc_dragonsoul["Warmaster Blackhorn"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-WarmasterBlackhorn.blp",
        advanced = {
            preventPostDefeatPull = 5,
        },
		triggers = {
			scan = {
				56598,56781, -- The Skyfire
			},
		},
		onactivate = {
			tracing = {
				{unit = "boss", npcid = 56598}, -- The Skyfire
			},
            phasemarkers = {
                {
                    {0.75,"Deck Fire","At 75% of ship's HP the first deck fire appears.",20},
                    {0.50,"Deck Fire","At 50% of ship's HP the first deck fire appears.",20},
                    {0.25,"Deck Fire","At 25% of ship's HP the first deck fire appears.",20},
                },
                {
                    {0.2,"Gariona Flees","At 20% of her HP Gariona flees the encounter."},
                    {0.8,"Gariona Lands","At 80% of her HP Gariona lands.",20},
                },
            },
			tracerstart = true,
			combatstop = true,
			defeat = 56427, -- Blackhorn
		},
		userdata = {
            -- Timers
            slayercd = {3.5, 1, 2.5, 0, loop = false, type = "series"},
            dreadbladecd = {23, 59, 63.5, 0, loop = false, type = "series"},
            dreadbladetimer = {23, 59, 63.5, 0, loop = false, type = "series"},
            
            -- Texts
			sundertext = "",
            harpoonsidetext = "",
            onslaughtprioritiestext = "",
            raidcdtext = "",
            
            -- Switches
            deckdefenderfailed = "no",
            
            -- Counters
            drakecount = 0, -- up to 6
            dreadbladecount = 0,
            phase = 1,
            onslaughtcounter = 1,
            
            -- GUIDs
            harpoongun1guid = "nil",
            harpoongun2guid = "nil",
            barrageunit = "",
		},
		onstart = {
			{
                "alert","pullcd",
				"alert",{"dreadbladecd",time = 2},
                "scheduletimer",{"dreadbladetimer", "<dreadbladetimer>"},
                "alert",{"onslaughtcd",time = 2},
                "alert",{"sappercd",time = 2},
                "scheduletimer",{"sappertimer", 70},
                "counter","drakecounter",
                "schedulealert",{{"barragecd", time = 2}, 5},
                "schedulealert",{{"barragecd", time = 2}, 8.5},
                "schedulealert",{{"barragecd", time = 2}, 64},
                "schedulealert",{{"barragecd", time = 2}, 65.5},
                "schedulealert",{{"barragecd", time = 2}, 127.5},
                "schedulealert",{{"barragecd", time = 2}, 130.5},
                "expect",{"&itemvalue|precast_timing&","~=","nil"}, -- nil check
                "scheduletimer",{"onslaughtprioritiestimer", "&substract|47|&itemvalue|precast_timing&&"},
			},
            {
                "expect",{"&itemvalue|projectedtextures&","==","true"},
                "setcvar",{"projectedTextures",0},
            },
        },        
		announces = {
			shockwavesay = {
				type = "SAY",
                subtype = "self",
                spell = 108046,
				msg = format(L.alert["%s on ME"],SN[108046]).."!",
			},
            deckdefenderfailed = {
                varname = "%s failed ",
                type = "RAID",
                subtype = "achievement",
                achievement = 6105,
                msg = format(L.alert["<DXE> %s: Achievement failed!"],AL[6105]),
                throttle = true,
            },
            onslaughtpriorities = {
                varname = "%s Priorities",
                type = "RAID_WARNING",
                subtype = "spell",
                spell = 106401,
                msg = "<onslaughtprioritiestext>",
                enabled = false,
            },
		},
        raidicons = {
            sappermark = {
                varname = format("%s {%s}","Twilight Sapper","NPC_ENEMY"),
                type = "ENEMY",
                persist = 15,
                unit = "56923",
                reset = 14,
                icon = 1,
                texture = ST[91981],
            },
            shockwavemark = {
                varname = format("%s {%s}",SN[108046],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 3,
                unit = "&upvalue&",
                reset = 2.5,
                icon = 1,
                texture = ST[108046],
            },
        },
        filters = {
            bossemotes = {
                onslaughtemote = {
                    name = "Twilight Onslaught",
                    pattern = "prepares to unleash a %[Twilight Onslaught%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[106401],
                },
                sapperemote = {
                    name = "Twilight Sapper",
                    pattern = "drake swoops down to drop",
                    hasIcon = false,
                    hide = true,
                    texture = ST[91981],
                },
                garionafleesemote = {
                    name = "Gariona flees",
                    pattern = "screeches in pain and retreats",
                    hasIcon = false,
                    texture = ST[83412],
                },
            },
            raidwarnings = {
                onslaughtsoakrwfilter = {
                    name = "Twilight Onslaught (Soak Filter)",
                    pattern = "^{circle} %w+%, use .+ for .+ {circle}$",
                    hide = true,
                    texture = ST[106401],
                },
            },
        },
        counters = {
            drakecounter = {
                variable = "drakecount",
                label = "Twilight Drakes killed",
                value = 0,
                minimum = 0,
                maximum = 6,
            },
        },
		phrasecolors = {
            {"Right.?","YELLOW"},
            {"Left.?","CYAN"},
            {"Harpoon Gun:","WHITE"},
            {"Twilight Drake[s]? left","WHITE"},
            {"Twilight Assault Drake[s]?","GOLD"},
            {"Twilight Onslaught","MAGENTA"},
            {SN[55233],"YELLOW"}, -- Vampiric Blood
            {SN[22842],"YELLOW"}, -- Frenzied Regeneration
            {SN[33891],"YELLOW"}, -- Tree of Life
            {SN[47585],"YELLOW"}, -- Dispersion
            {SN[62618],"YELLOW"}, -- Power Word: Barrier
            {SN[64843],"YELLOW"}, -- Divine Hymn
            {SN[86948],"YELLOW"}, -- Cauterize
            {SN[871],  "YELLOW"}, -- Shield Wall
            {SN[70940],"YELLOW"}, -- Divine Guardian
            {SN[31884],"YELLOW"}, -- Avenging Wrath
            {SN[31821],"YELLOW"}, -- Aura Mastery
            {SN[98007],"YELLOW"}, -- Spirit Link Totem
        },
		misc = {
            name = format("|T%s:16:16|t %s",ST[106401],L.chat_dragonsoul["Twilight Onslaught Priorities"]),
            args = get_onslaught_args,
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd","pullcd"},
            },
            {
                phase = 1,
                alerts = {"dreadbladecd","slayercd","sappercd","sapperwarn","releasecd","harpoonwarn","reloadcd","reloadwarn","drakewarn","onslaughtcd","onslaughtwarn","onslaughtraidcdwarn","barragecd","barragewarn"},
            },
            {
                phase = 2,
                alerts = {"landscd","phase2warn","shockwavecd","shockwavewarn","shockwaveselfwarn","roarcd","flamescd","flamesselfwarn","sunderwarn","sunderduration","devastatecd","breathcd","breathwarn","shroudcd","shroudwarn"},
            },
        },
        
        alerts = {
            -- Berserk
            enragecd = {
                varname = format(L.alert["%s CD"],SN[26662]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[26662]),
                time = 255,
                flashtime = 60,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[26662],
            },
            -- Pull Countdown
            pullcd = {
				varname = format(L.alert["Pull Countdown"]),
				type = "dropdown",
				text = format(L.alert["%s"],"Encounter starts"),
				time = 20,
				flashtime = 10,
				color1 = "TURQUOISE",
                icon = ST[11242],
			},
            -------------
            -- Phase 1 --
            -------------
            -- Twilight Elite Dreadblade Landing
			dreadbladecd = {
				varname = format(L.alert["%s CD"],L.npc_dragonsoul["Twilight Elite Dreadblade"]),
				type = "dropdown",
				text =  format(L.alert["%s"],L.npc_dragonsoul["Twilight Elite Dreadblade"]),
				time = "<dreadbladecd>",
				flashtime = 5,
				color1 = "BROWN",
				icon = ST[29723],
			},
            -- Twilight Elite Slayer Landing
            slayercd = {
				varname = format(L.alert["%s CD"],L.npc_dragonsoul["Twilight Elite Slayer"]),
				type = "centerpopup",
				text =  format(L.alert["%s"],L.npc_dragonsoul["Twilight Elite Slayer"]),
				time = "<slayercd>",
				flashtime = 5,
				color1 = "GREEN",
				icon = ST[80325],
			},
            -- Twilight Sapper
            sappercd = {
                varname = format(L.alert["%s CD"],"Twilight Sapper"),
                type = "dropdown",
                text = format(L.alert["%s"],"Twilight Sapper"),
                time = 40,
                time2 = 70,
                flashtime = 5,
                color1 = "RED",
                color2 = "BROWN",
                sound = "MINORWARNING",
                icon = ST[91981],
            },
            sapperwarn = {
                varname = format(L.alert["%s Warning"],"Twilight Sapper"),
                type = "simple",
                text = format(L.alert["%s - SWITCH TARGET!"],"Twilight Sapper"),
                time = 1,
                color1 = "RED",
                sound = "ALERT10",
                icon = ST[91981],
                emphasizewarning = true,
            },
            -- Harpoon (Release)
            releasecd = {
                varname = format(L.alert["%s Release CD"],SN[108038]),
                type = "centerpopup",
                text = format(L.alert["%s %s Release CD"],"<harpoonsidetext>",SN[108038]),
                time = 20,
                flashtime = 0,
                color1 = "BROWN",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[76859],
                tag = "#1#",
                sticky = true,
            },
            harpoonwarn = {
                varname = format(L.alert["%s Warning"],SN[108038]),
                type = "simple",
                text = format(L.alert["%s %s on %s"],"<harpoonsidetext>",SN[108038],"Twilight Assault Drake"),
                time = 1,
                color1 = "PEACH",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[76859],
            },
            -- Reloading Harpoon
            reloadcd = {
                varname = format(L.alert["%s Duration"],SN[108039]),
                type = "centerpopup",
                text = format(L.alert["%s Harpoon Gun: %s"],"<harpoonsidetext>",SN[108039]),
                time = 11,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "RED",
                sound = "None",
                icon = ST[108039],
            },
            reloadwarn = {
                varname = format(L.alert["%s Warning"],SN[108039]),
                type = "simple",
                text = format(L.alert["%s Harpoon Gun: %s"],"<harpoonsidetext>",SN[108039]),
                time = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[108039],
            },
            -- Twilight Assault Drake killed
            drakewarn = {
                varname = format(L.alert["%s Warning"],"Twilight Drake Killed"),
                type = "simple",
                text = "<draketext>",
                time = 1,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[59650],
            },
            -- Twilight Onslaught
			onslaughtwarn = {
				varname = format(L.alert["%s Warning"],SN[106401]),
				type = "simple",
				text =  format(L.alert["%s"],SN[106401]),
				time = 3,
				color1 = "MAGENTA",
				icon = ST[106401],
				sound = "BEWARE",
			},
			onslaughtcd = {
				varname = format(L.alert["%s CD"],SN[106401]),
				type = "dropdown",
				text =  format(L.alert["Next %s"],SN[106401]),
				time = 35,
				time2 = 47,
				flashtime = 7.5,
				color1 = "PURPLE",
				icon = ST[106401],
			},
            -- Twilight Onslaught Raid Cooldown (Heroic)
            onslaughtraidcdwarn = {
                varname = format(L.alert["%s Raid Cooldown Warning"],SN[106401]),
                type = "simple",
                text = "<raidcdtext>",
                textp = "<raidcdtext>",
                remoteparameters = {"raidcdtext"},
                remote = true,
                time = 1,
                color1 = "PEACH",
                sound = "MINORWARNING",
                texture = ST[106401]
            },
            -- Twilight Barrage
            barragecd = {
                varname = format(L.alert["%s CD"],SN[107501]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[107501]),
                time = 13,
                time2 = 35,
                flashtime = 15,
                color1 = "MAGENTA",
                color2 = "PINK",
                sound = "MINORWARNING",
                icon = ST[107501],
                tag = "<barrageunit>",
            },
            barragewarn = {
                varname = format(L.alert["%s Warning"],SN[107501]),
                type = "simple",
                text = format(L.alert["%s"],SN[107501]),
                time = 1,
                color1 = "MAGENTA",
                sound = "None",
                icon = ST[107501],
                tag = "#1#",
            },
            
            -------------
            -- Phase 2 --
            -------------
            -- Warmaster Lands
            landscd = {
                varname = format(L.alert["%s CD"],"Warmaster Lands"),
                type = "centerpopup",
                text = format(L.alert["%s"],"Warmaster lands"),
                time = 12,
                color1 = "TURQUOISE",
                sound = "None",
                icon = ST[11242],
            },
            -- Phase 2
            phase2warn = {
                varname = format(L.alert["Phase 2 Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"2"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT1",
                icon = ST[11242],
            },
            -- Shockwave
            shockwavecd = {
				varname = format(L.alert["%s CD"],SN[108046]),
				type = "dropdown",
				text =  format(L.alert["%s CD"],SN[108046]),
				time = 22, -- seen 25-28
				time2 = 16,
				flashtime = 5,
				color1 = "YELLOW",
				icon = ST[108046],
                sticky = true,
			},
            shockwavewarn = {
				varname = format(L.alert["%s Warning"],SN[108046]),
				type = "centerpopup",
				text =  format(L.alert["%s"],SN[108046]),
				time = 2.5,
				color1 = "YELLOW",
				icon = ST[108046],
				sound = "RUNAWAY",
			},
			shockwaveselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[108046]),
				type = "simple",
				text =  format(L.alert["%s on <%s> - GET AWAY!"],SN[108046],L.alert["YOU"]),
				time = 3,
				color1 = "YELLOW",
				icon = ST[108046],
				flashscreen = true,
                emphasizewarning = true,
			},
            -- Disrupting Roar
			roarcd = {
				varname = format(L.alert["%s CD"],SN[108044]),
				type = "dropdown",
				text =  format(L.alert["%s CD"],SN[108044]),
				time = 21, -- seen 19.5-23
				time2 = 13,
				flashtime = 5,
				color1 = "BROWN",
				icon = ST[108044],
                sticky = true,
			},
            -- Twilight Flames
			flamescd = {
				varname = format(L.alert["%s CD"],SN[109216]),
				type = "dropdown",
				text =  format(L.alert["Next %s"],SN[109216]),
				time = 8,
				time2 = 17.5,
				flashtime = 5,
				color1 = "PURPLE",
				icon = ST[109216],
			},
			flamesselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[109216]),
				type = "simple",
				text =  format(L.alert["%s on <%s> - GET AWAY!"],SN[109216],L.alert["YOU"]),
				time = 2,
				color1 = "PURPLE",
				icon = ST[109216],
				sound = "ALERT4",
				flashscreen = true,
				throttle = 2,
                emphasizewarning = true,
			},
            -- Sunder Armor
			sunderwarn = {
				varname = format(L.alert["%s Warning"],SN[108043]),
				type = "simple",
				text =  "<sundertext>",
				time = 3,
				color1 = "WHITE",
				icon = ST[108043],
				sound = "ALERT5",
                stacks = 2,
                enabled = false,
			},
            sunderduration = {
                varname = format(L.alert["%s Duration"],SN[108043]),
                type = "centerpopup",
                text = "<sundertext>",
                time = 30,
                color1 = "BROWN",
                sound = "None",
                icon = ST[108043],
                tag = "#4#",
                stacks = 2,
                audiocd = true,
            },
            -- Devastate
            devastatecd = {
                varname = format(L.alert["%s CD"],SN[108042]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[108042]),
                time = 8.5,
                time2 = 6,
                flashtime = 5,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[108042],
            },
            -- Twilight Breath
            breathcd = {
                varname = format(L.alert["%s CD"],SN[110212]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[110212]),
                time = 21,
                flashtime = 5,
                color1 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[110212],
                sticky = true,
            },
            breathwarn = {
                varname = format(L.alert["%s Warning"],SN[110212]),
                type = "simple",
                text = format(L.alert["%s"],SN[110212]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT1",
                icon = ST[110212],
            },
            -- Consuming Shroud
            shroudcd = {
                varname = format(L.alert["%s CD"],SN[110214]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[110214]),
                time = 32,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[110214],
            },
            shroudwarn = {
                varname = format(L.alert["%s Warning"],SN[110214]),
                type = "simple",
                text = "<shroudtext>",
                time = 1,
                color1 = "TURQUOISE",
                sound = "ALERT1",
                icon = ST[110214],
            },
            
		},
		timers = {
            dreadbladetimer = {
                {
                    "set",{dreadbladecount = "INCR|1"},
                    "quash","dreadbladecd",
                    "alert","slayercd",
                    "expect",{"<dreadbladecount>","<","3"},
                    "alert","dreadbladecd",
                    "scheduletimer",{"dreadbladetimer", "<dreadbladetimer>"},
                },
            },
            sappertimer = {
                {
                    "expect",{"<phase>","==","1"},
                    "alert","sapperwarn",
                    "raidicon","sappermark",
                    "alert","sappercd",
                    "repeattimer",{"sappertimer", 40},
                },
            },
            onslaughtprioritiestimer = {
                {
                    "expect",{"&itemenabled|onslaughtpriorities&","==","true"},
                    "expect",{"<onslaughtcounter>","<=","8"},
                    "expect",{"&itemvalue|onslaught_<onslaughtcounter>&","~=","NONE",
                         "OR","&itemvalue|onslaught_<onslaughtcounter>&","~=","nil"},
                    "set",{
                        onslaughtplayer = "&unitname|&itemvalue|onslaught_<onslaughtcounter>&&",
                        onslaughtcds = "&itemvalue|onslaught_<onslaughtcounter>_cd&",
                    },
                    "set",{onslaughtcdname = format("%s", "&sl|<onslaughtcds>&")},
                    "set",{onslaughtprioritiestext = format("{circle} %s, use %s for %s {circle}","<onslaughtplayer>","<onslaughtcdname>","&sl|106401&")},
                    "announce","onslaughtpriorities",
                    "set",{
                        onslaughtcdname = format("%s", "&sn|<onslaughtcds>&"),
                        onslaughtcdicon = format("%s", "&st|<onslaughtcds>&"),
                    },
                    "set",{onslaughtcdname = format("|T%s:16:16|t%s","<onslaughtcdicon>","<onslaughtcdname>")},
                    "set",{
                        twilighticon = format("|T%s:16:16|t","&st|106401&"),
                        twilightname = "&sn|106401&"},
                    "set",{raidcdtext = format(L.alert["Use %s for %s%s."],"<onslaughtcdname>","<twilighticon>","<twilightname>")},
                    "invoke",{
                        {
                            "expect",{"<onslaughtplayer>","==","&playername&"},
                            "alert","onslaughtraidcdwarn",
                        },
                        {
                            "expect",{"<onslaughtplayer>","~=","&playername&"},
                            "send",{"alert","onslaughtraidcdwarn","<onslaughtplayer>","<raidcdtext>"},
                        },
                    },
                },
            },
        },
		events = {
            -------------
            -- Phase 1 --
            -------------
            -- Harpoon (release)
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 108038,
                execute = {
                    -- Register the left harpoon gun
                    {
                        "expect",{"<harpoongun1guid>","~=","nil",
                                  "AND","<harpoongun2guid>","==","nil"},
                        "set",{harpoongun2guid = "#1#"},
                        
                    },
                    -- Register the right harpoon gun
                    {
                        "expect",{"<harpoongun1guid>","==","nil"},
                        "set",{harpoongun1guid = "#1#"},
                    },
                    {
                        "expect",{"#1#","==","<harpoongun1guid>"},
                        "set",{harpoonsidetext = "Right"},
                    },
                    {
                        "expect",{"#1#","==","<harpoongun2guid>"},
                        "set",{harpoonsidetext = "Left"},
                    },
                    {
                        "alert","releasecd",
                        "alert","harpoonwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellid = 108038,
                execute = {
                    {
                        "quash",{"releasecd","#1#"},
                    },
                },
            },
            -- Reloading
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 108039,
                execute = {
                    {
                        "expect",{"#1#","==","<harpoongun1guid>"},
                        "set",{harpoonsidetext = "Right"},
                    },
                    {
                        "expect",{"#1#","==","<harpoongun2guid>"},
                        "set",{harpoonsidetext = "Left"},
                    },
                    {
                        "alert","reloadwarn",
                        "alert","reloadcd",
                    },
                },
            },
			-- Twilight Onslaught
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 106401,
				execute = {
					{
						"quash","onslaughtcd",
						"alert","onslaughtcd",
						"alert","onslaughtwarn",
                        "set",{
                            onslaughtcounter = "INCR|1",
                        },
                        "expect",{"&itemvalue|precast_timing&","~=","nil"}, -- nil check
                        "scheduletimer",{"onslaughtprioritiestimer", "&substract|35|&itemvalue|precast_timing&&"},
					},
				},
			},
            -- Twilight Barrage
            {
                type = "combatevent", 
                eventtype = "SPELL_CAST_START",
                spellname = 107286,
                execute = {
                    {
                        "quash",{"barragecd","#1#"},
                        "set",{barrageunit = "#1#"},
                        "alert","barragecd",
                        "alert","barragewarn",
                    },
                },
            },
            
			-- Twilight Assault Drake killed
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","56855",
                                  "OR","&npcid|#4#&","==","56587"},
                        "invoke",{
                            {
                                "set",{
                                    drakecount = "INCR|1",
                                },
                                "quash",{"barragecd","#4#"},
                            },
                            {
                                "expect",{"<drakecount>","<","5"},
                                "set",{draketext = format("%s %s left","&substract|6|<drakecount>&","Twilight Drakes")},
                            },
                            {
                                "expect",{"<drakecount>","==","5"},
                                "set",{draketext = format("%s %s left","&substract|6|<drakecount>&","Twilight Drake")},
                            },
                            {
                                "expect",{"<drakecount>","<","6"},
                                "alert","drakewarn",
                            },
                            -- Phase 2 transition
                            {
                                "expect",{"<drakecount>","==","6"},
                                "alert","landscd",
                                "quash","onslaughtcd",
                                "canceltimer","onslaughtprioritiestimer",
                                "set",{phase = 2},
                                "expect",{"&timeleft|sappercd&",">","18"},
                                "quash","sappercd",
                                "canceltimer","sappertimer",
                            },
                        },
                    },
                },
            },
            -- Deck Defender (achievement)
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 107501,
                dstnpcid = 56598,
                execute = {
                    {
                        "expect",{"<deckdefenderfailed>","==","no"},
                        "set",{deckdefenderfailed = "yes"},
                        "announce","deckdefenderfailed",
                    },
                },
            },
            
            -------------
            -- Phase 2 --
            -------------
            -- Phase 2 (Vengeance)
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = 108045,
				execute = {
					{
                        "quash","landscd",
                        "alert","phase2warn",
						"alert",{"roarcd",time = 2},
						"alert",{"shockwavecd",time = 2},
						"alert",{"flamescd",time = 2},
                        "alert",{"devastatecd",time = 2},
                        "alert","enragecd",
						"tracing",{
							56427, -- Blackhorn
							56781, -- Goriona
						},
                        "removecounter","drakecounter",
                        "clearphasemarkers",{1}
					},
                    {
                        "expect",{"&itemenabled|projectedtextures&","==","true"},
                        "setcvar",{"projectedTextures",1},
                    },
				},
			},
            -- Shockwave
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = 108046,
				srcisnpctype = true,
				execute = {
					{
						"quash","shockwavecd",
						"alert","shockwavecd",
						"alert","shockwavewarn",
					},
					{
						"target",{
							source = "#1#",
							wait = 0.1,
							announce = "shockwavesay",
                            raidicon = "shockwavemark",
							alerts = {
								self = "shockwaveselfwarn",
							},
						},
					},
				},
			},
			-- Disrupting Roar
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 108044,
				execute = {
					{
						"quash","roarcd",
						"alert","roarcd",
					},
				},
			},
			-- Sunder Armor on Tanks
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				srcisnpctype = true,
				spellid = 108043,
				execute = {
					{
						"expect",{"#11#",">=","&stacks|sunderwarn&"},
                        "invoke",{
                            {
                                "expect",{"#4#","~=","&playerguid&"},
                                "set",{sundertext = format("%s (%s) on <%s>",SN[108043],"#11#","#5#")},
                            },
                            {
                                "expect",{"#4#","==","&playerguid&"},
                                "set",{sundertext = format("%s (%s) on <%s>",SN[108043],"#11#",L.alert["YOU"])},
                            },
                        },
                        "alert","sunderwarn",
					},
                    {
                        "expect",{"#11#",">=","&stacks|sunderduration&"},
                        "quash",{"sunderduration","#4#"},
                        "alert","sunderduration",
                    },
				},
			},
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                dstisplayertype = true,
                execute = {
                    {
                        "quash",{"sunderduration","#4#"},
                    },
                },
            },
            
            -- Devastate
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = 108042,
                srcnpcid = 56427,
                execute = {
                    {
                        "quash","devastatecd",
                        "alert","devastatecd",
                    },
                },
            },
			-- Twilight Flames
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellname = 109216,
				execute = {
					{
						"quash","flamescd",
						"alert","flamescd",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 109216,
				execute = {
					{
                        "expect",{"#4#","==","&playerguid&"},
						"alert","flamesselfwarn",
					},
				},
			},
            -- Gariona flees
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_dragonsoul["screeches in pain and retreats"]},
                        "quash","flamescd",
                        "quash","breathcd",
                        "tracing",{
							56427, -- Blackhorn
						},
                    },
                },
            },
            -- Twilight Breath
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = 110212,
                execute = {
                    {
                        "quash","breathcd",
                        "alert","breathcd",
                        "alert","breathwarn",
                    },
                },
            },
            -- Consuming Shroud
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 110214,
                execute = {
                    {
                        "quash","shroudcd",
                        "alert","shroudcd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 110214,
                execute = {
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{shroudtext = format(L.alert["%s on <%s>"],SN[110214],"#5#")},
                        "alert","shroudwarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{shroudtext = format(L.alert["%s on <%s>"],SN[110214],L.alert["YOU"])},
                        "alert","shroudwarn",
                    },
                },
            },
            
            
		},
	}

	DXE:RegisterEncounter(data)
end

----------------------------
-- SPINE OF DEATHWING
----------------------------
do
	local data = {
		version = 5,
		key = "spineofdeathwing",
		zone = L.zone["Dragon Soul"],
		category = L.zone["Dragon Soul"],
		name = L.npc_dragonsoul["Spine of Deathwing"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Deathwing.blp",
		advanced = {
            delayWipe = 3,
        },
        triggers = {
			scan = {
				53879, -- Deathwing
			},
            yell = {
                L.chat_dragonsoul["He's coming apart"],
                L.chat_dragonsoul["worry about me"],
            },
		},
		onactivate = {
            tracing = {},
            counters = {"platescounter","residuecounter"},
			tracerstart = true,
			combatstop = true,
			defeat = 53879,
		},
		userdata = {
            -- Texts
			griptext = "",
            bloodtext = "",
            deathtext = "",
            earthtext = "",
            
            -- Counters
            platescount = 3,
            residuecount = 0,
            
            -- Lists
            corruptions_map = {type = "map"},
            grip_units = {type = "container"},
            
            -- Timers
            gripcd = 0,
            searcast = 8,
		},
		onstart = {
            {
            },
        },
        
        raidicons = {
			heated = {
                varname = format("%s {%s-%s}",SN[105834],"ENEMY_DEBUFF","Hideous Amalgamation's"),
				type = "ENEMY",
				persist = 10,
				reset = 1,
				unit = "#4#",
				icon = 1,
				total = 1,
                texture = ST[105834],
			},
			grip = {
                varname = format("%s {%s}",SN[109457],"PLAYER_DEBUFF"),
				type = "MULTIFRIENDLY",
				persist = 10,
				reset = 9,
				unit = "#5#",
				icon = 2,
				total = 7,
                texture = ST[109457],
			},
		},
        filters = {
            bossemotes = {
                rollemote = {
                    name = "Roll",
                    pattern = "He's about to roll",
                    hasIcon = false,
                    hide = true,
                    texture = EJST[4050],
                },
                rollsemote = {
                    name = "Rolling",
                    pattern = "Deathwing rolls",
                    hasIcon = false,
                    hide = true,
                    texture = EJST[4050],
                },
                blastemote = {
                    name = "Nuclear Blast",
                    pattern = "is casting %[Nuclear Blast%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[105845],
                },
                badexplosionemote = {
                    name = "Amalgamation death",
                    pattern = "absorb enough Corrupted Blood",
                    hasIcon = false,
                    hide = true,
                    texture = ST[99598],
                },
            },
        },
        counters = {
            platescounter = {
                variable = "platescount",
                label = "Back Plates",
                value = 3,
                minimum = 0,
                maximum = 3,
            },
            residuecounter = {
                variable = "residuecount",
                label = "Blood Residue",
                value = 0,
                minimum = 0,
                maximum = 9,
            },
        },
        phrasecolors = {
            {"NOT","RED"},
            {"Amalgamation","ORANGE"},
            {"Death","RED"},
            {"Earth","LIGHTGREEN"},
            {"Back Plate","PEACH"},
        },
        misc = {
            args = {
                disableplasmaon25 = {
                    name = format(L.chat_dragonsoul["Disable |T%s:16:16|t |cffffd600Searing Plasma|r |cff00ff00[Absorbs]|r on 25-man."],ST[105479]),
                    type = "toggle",
                    order = 1,
                    default = true,
                },
            },
        },
        ordering = {
            alerts = {"rollcd","rollwarn","graspwarn","plasmaabsorb","gripcd","gripwarn","gripselfwarn","amalgamationwarn","residuewarn","bloodwarn","superheatwarn","blastwarn","breachwarn","breachduration","plateswarn","deathwarn","earthwarn","neltwarn"},
        },
        
		alerts = {
            -- Amalgamation summon
            amalgamationwarn = {
                varname = format(L.alert["Summon %s Warning"],"Amalgamation"),
                type = "simple",
                text = format(L.alert["New: %s"],"Amalgamation"),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT9",
                icon = ST[99598],
            },
            -- Fiery Grip
            gripcd = {
                varname = format(L.alert["%s CD"],SN[105490]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[105490]),
                time = "<gripcd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[105490],
                tag = "#1#",
            },
            gripwarn = {
                varname = format(L.alert["%s Warning"],SN[105490]),
                type = "simple",
                text = format("%s on <%s>",SN[105490],"&list|grip_units&"),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT6",
                icon = ST[105490],
            },
            gripselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[105490]),
                type = "simple",
                text = format(L.alert["%s on %s!"],SN[105490],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[105490],
                emphasizewarning = true,
                flashscreen = true,
            },
            gripabsorb = {
                varname = format(L.alert["%s Absorbs"],SN[105490]),
                text = "",
                textformat = format("%s (%%s / %%s)","Inflict"),
                type = "inflict",
                time = 30,
                color1 = "TURQUOISE",
                sound = "None",
                icon = ST[105490],
                npcguid = "#1#",
                tag = "#1#",
                values = {
                    [105490] = 91561, --10n
                    [109458] = 160275, --10h
                    [109457] = 283788, --25n
                    [109459] = 496800, --25h
                },
            },
            -- Roll
            rollcd = {
                varname = format(L.alert["%s CD"],EJSN[4050]),
                type = "dropdown",
                text = format(L.alert["Next %s"],EJSN[4050]),
                time = 16,
                flashtime = 5,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = EJST[4050],
            },
            rollwarn = {
				varname = format(L.alert["%s Warning"],EJSN[4050]),
				type = "centerpopup",
				text =  "<rolltext>",
				time = 7,
				color1 = "GOLD",
				icon = EJST[4050],
				sound = "ALERT3",
			},
            -- Grasping Tendrils (missing)
            graspwarn = {
				varname = format(L.alert["%s Missing Warning"],SN[109455]),
				type = "simple",
				text =  format(L.alert["You are NOT HOOKED!"]),
				time = 1,
				color1 = "YELLOW",
				icon = ST[109455],
				sound = "ALERT7",
                emphasizewarning = true,
			},
            -- Residue
            residuewarn = {
                varname = format(L.alert["%s Warning"],SN[105223]),
                type = "simple",
                text = format(L.alert["%s (%s)"],SN[105223],"<residuecount>"),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "MINORWARNING",
                icon = ST[105223],
            },
            -- Absorbed Blood
            bloodwarn = {
				varname = format(L.alert["%s Warning"],SN[105248]),
				type = "simple",
				text = "<bloodtext>",
				time = 2,
				color1 = "RED",
				icon = ST[105248],
				sound = "MINORWARNING",
                stacks = 2,
			},
            -- Superheated Nucleus
			superheatwarn = {
				varname = format(L.alert["%s Warning"],SN[105834]),
				type = "simple",
				text =  format(L.alert["%s gets Superheated"],L.npc_dragonsoul["Amalgamation"]),
				time = 1,
				color1 = "GOLD",
				icon = ST[105834],
				sound = "ALERT2",
			},
            -- Nuclear Blast
            blastwarn = {
                varname = format(L.alert["%s Warning"],SN[105845]),
                type = "centerpopup",
                text = format(L.alert["%s - KEEP CLEAR!"],SN[105845]),
                time = 5,
                color1 = "YELLOW",
                sound = "BEWARE",
                icon = ST[105845],
            },
            -- Seal Armor Breach
			breachwarn = {
				varname = format(L.alert["%s Warning"],SN[105847]),
				type = "simple",
				text =  format(L.alert["%s"],SN[105847]),
                time = 1,
				color1 = "TURQUOISE",
				--icon = ST[105847],
                icon = ST[105363],
				sound = "ALERT1",
			},
			breachduration = {
                varname = format(L.alert["%s Duration"],SN[105847]),
                type = "centerpopup",
                text = format("%s closes","Seal Armor"),
                time = 23,
                flashtime = 5,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[105847],
            },
            -- Back Plate removed
            plateswarn = {
                varname = format(L.alert["%s Warning"],"Back Plate Removed"),
                type = "simple",
                text = "<platestext>",
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[50913],
            },
            -- Searing Plasma
            plasmaabsorb = {
                varname = format(L.alert["%s Absorbs"],SN[105479]),
                text = format("%s - %%s to heal","<#5#>"),
                type = "absorbheal",
                time = 300,
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "YELLOW",
                sound = "ALERT3",
                icon = ST[105479],
                target = "#4#",
                values = {
                    [105479] = 200000, --10n
                    [109363] = 280000, --10h
                    [109362] = 300000, --25n
                    [109364] = 420000, --25h
                },
                tag = "#4#",
            },
            ------------
            -- Heroic --
            ------------
            -- Blood Corruption: Death
            deathwarn = {
                varname = format(L.alert["%s Warning"],SN[106199]),
                type = "centerpopup",
                text = "<deathtext>",
                timemax = 16,
                color1 = "MAGENTA",
                sound = "ALERT8",
                icon = ST[106199],
                tag = "#4#",
            },
            -- Blood Corruption: Earth
            earthwarn = {
                varname = format(L.alert["%s Warning"],SN[106200]),
                type = "centerpopup",
                text = "<earthtext>",
                timemax = 16,
                color1 = "PEACH",
                sound = "ALERT2",
                icon = ST[106200],
                tag = "#4#"
            },
            -- Blood of Neltharion
            neltwarn = {
                varname = format(L.alert["%s Warning"],SN[106213]),
                type = "simple",
                text = "<nelttext>",
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT8",
                icon = ST[106213],
            },
            
		},
		timers = {
			rollcheck = {
				{
					"expect",{"&playerdebuff|"..SN[109455].."&","==","false"},
					"alert","graspwarn",
					"scheduletimer",{"rollcheck",1}
				},
			},
			rolldone = {
				{
					"canceltimer","rollcheck",
				},
			},
            breachtimer = {
                {
                    "set",{platescount = "DECR|1"},
                    "quash","breachduration",
                },
                {
                    "expect",{"<platescount>","==","2"},
                    "set",{platestext = format("1st Back Plate removed (2 remaining)")},
                    "alert","plateswarn",
                },
                {
                    "expect",{"<platescount>","==","1"},
                    "set",{platestext = format("2nd Back Plate removed (1 remaining)")},
                    "alert","plateswarn",
                },
                {
                    "expect",{"<platescount>","==","0"},
                    "triggerdefeat",true,
                },
            },
            bufftimer = {
                {
                    "expect",{"#7#","==","106199"},
                    "invoke",{
                        {
                            "expect",{"#4#","==","&playerguid&"},
                            "set",{deathtext = format("%s on <%s>","BC: Death",L.alert["YOU"])},
                        },
                        {
                            "expect",{"#4#","~=","&playerguid&"},
                            "set",{deathtext = format("%s on <%s>","BC: Death","#5#")},
                        },
                    },
                    "quash",{"deathwarn","#4#"},
                    "expect",{format("&debuffhasdur|%s|%s&","#5#",SN[106199]),"==","true"},
                    "set",{bloodtime = format("&debuffdur|%s|%s&","#5#",SN[106199])},
                    "alert","deathwarn",
                },
                {
                    "expect",{"#7#","==","106200"},
                    "invoke",{
                        {
                            "expect",{"#4#","==","&playerguid&"},
                            "set",{earthtext = format("%s on <%s>","BC: Earth",L.alert["YOU"])},
                        },
                        {
                            "expect",{"#4#","~=","&playerguid&"},
                            "set",{earthtext = format("%s on <%s>","BC: Earth","#5#")},
                        },
                    },
                    "quash",{"earthwarn","#4#"},
                    "expect",{format("&debuffhasdur|%s|%s&","#5#",SN[106200]),"==","true"},
                    "set",{bloodtime = format("&debuffdur|%s|%s&","#5#",SN[106200])},
                    "alert","earthwarn",
                },
            },
            griptimer = {
                {
                    "alert","gripwarn",
                    "wipe","grip_units",
                },
            },
        },
        events = {
            -- Amalgamation (summon)
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","56161",
                                  "OR","&npcid|#4#&","==","56162",
                                  "OR","&npcid|#4#&","==","53891"},
                        "schedulealert",{"amalgamationwarn§#4#", 4},
                        "map",{"corruptions_map","#4#",nil},
                        "quash",{"gripcd","#4#"},
                        "quash",{"gripabsorb","#4#"},
                    },
                },
            },
            -- Burst (Corrupted Blood dies)
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 105219,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","53889"},
                        "set",{residuecount = "INCR|1"},
                        "alert","residuewarn",
                    },
                },
            },
            -- Searing Plazma
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 109379,
                execute = {
                    {
                        "expect",{"&mapget|corruptions_map|#1#&","==","nil"},
                        "invoke",{
                            {
                                "expect",{"&difficulty&","==","1",
                                      "OR","&difficulty&","==","3",},
                                "map",{"corruptions_map","#1#",5},
                            },
                            {
                                "expect",{"&difficulty&","==","2",
                                      "OR","&difficulty&","==","4",},
                                "map",{"corruptions_map","#1#",3},
                            },
                        },
                        
                    },
                    {
                        "map",{"corruptions_map","#1#","DECR|1"},
                        "expect",{"&mapget|corruptions_map|#1#&",">","0"},
                        "set",{gripcd = "&mult|&mapget|corruptions_map|#1#&|<searcast>&"}, -- gripcd = casts_left * searcast
                        "invoke",{
                            {
                                "expect",{"&difficulty&","==","1",
                                      "OR","&difficulty&","==","3",},
                                "invoke",{
                                    {
                                        "expect",{"&mapget|corruptions_map|#1#&","==","4"},
                                        "quash",{"gripcd","#1#"},
                                        "alert","gripcd",
                                    },
                                    {
                                        "expect",{"&mapget|corruptions_map|#1#&","<","4"},
                                        "settimeleft",{"gripcd","<gripcd>"},
                                    },
                                }
                            },
                            {
                                "expect",{"&difficulty&","==","2",
                                      "OR","&difficulty&","==","4",},
                                "invoke",{
                                    {
                                        "expect",{"&mapget|corruptions_map|#1#&","==","2"},
                                        "quash",{"gripcd","#1#"},
                                        "alert","gripcd",
                                    },
                                    {
                                        "expect",{"&mapget|corruptions_map|#1#&","<","2"},
                                        "settimeleft",{"gripcd","<gripcd>"},
                                    },
                                }
                            },
                            
                        },                        
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 109363,
                execute = {
                    {
                        "expect",{"&difficulty&","==","1",
                             "OR","&difficulty&","==","3",
                             "OR","&itemvalue|disableplasmaon25&","==","false"},
                        "alert","plasmaabsorb",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 109363,
                execute = {
                    {
                        "quash",{"plasmaabsorb","#4#"},
                    },
                },
            },
            
            -- Fiery Grip
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 105490,
                dstisplayertype = true,
                execute = {
                    {
                        "raidicon","grip",
                        "map",{"corruptions_map","#1#",nil},
                        "quash",{"gripcd","#1#"},
                        
                        "alert","gripabsorb",
                    },
                    {

                        "expect",{"&listcontains|grip_units|#5#&","==","false"},
                        "insert",{"grip_units","#5#"},
                        "scheduletimer",{"griptimer", 0.3},
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","gripselfwarn",
                    },
                },
            },
            -- Barrel Roll
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_dragonsoul["He's about to roll right"]},
						"set",{
                            rolltext = "Roll to the Right!",
                        },
					},
                    {
						"expect",{"#1#","find",L.chat_dragonsoul["He's about to roll left"]},
						"set",{
                            rolltext = "Roll to the Left!",
                        },
					},
                    {
						"expect",{"#1#","find",L.chat_dragonsoul["He's about to roll"]},
						"quash","rollwarn",
                        "quash","rollcd",
                        "alert","rollwarn",
                        "alert","rollcd",
						"scheduletimer",{"rollcheck",0.1},
						"scheduletimer",{"rolldone",7},
					},
				},
			},
            -- Levels out
			{
				type = "event",
				event = "EMOTE",
				execute = {
					{
						"expect",{"#1#","find",L.chat_dragonsoul["levels out"]},
						"canceltimer","rollcheck",
                        "quash","rollwarn",
                        "quash","rollcd",
					},
				},
			},
            -- Absorb Blood Stacks
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 105248,
                execute = {
                    {
                        "set",{residuecount = "DECR|1"},
                    },
                },
            },
            
            {
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 105248,
				execute = {
					{
                        "set",{residuecount = "DECR|1"},
						"expect",{"#11#",">=","&stacks|bloodwarn&"},
                        "expect",{"#11#","<","9"},
						"set",{bloodtext = format("%s (%s) on %s",SN[105248],"#11#","Amalgamation")},
						"alert","bloodwarn",
					},
				},
			},
            -- Superheated
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 105834,
				execute = {
					{
						"alert","superheatwarn",
						"raidicon","heated",
					},
				},
			},
            -- Nuclear Blast
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 105845,
                execute = {
                    {
                        "alert","blastwarn",
                    },
                },
            },
			-- Seal Armor Breach
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 105847,
				execute = {
					{
						"alert","breachwarn",
                        "alert","breachduration",
                        "closetemptracing",true,
                        "temptracing",{
                            {
                                unit = "boss",
                                npcid = {57884,57887,57886,57889,57885,56341,56575,57888} -- IDs from all difficulties :lol:
                            },
                        },
					},
				},
			},	
            ------------
            -- Heroic --
            ------------
            -- Blood Corruption: Death
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 106199,
                execute = {
                    {
                        "scheduletimer",{"bufftimer", 0.01},
                    },
                    --[[{
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{
                            deathtext = format("%s on <%s>","BC: Death",L.alert["YOU"]),
                        },
                        "quash",{"deathwarn","#4#"},
                        "alert","deathwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{
                            deathtext = format("%s on <%s>","BC: Death","#5#"),
                        },
                        "quash",{"deathwarn","#4#"},
                        "alert","deathwarn",
                    },]]
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 106199,
                execute = {
                    {
                        "quash",{"deathwarn","#4#"},
                    },
                },
            },
            -- Blood Corruption: Earth
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 106200,
                execute = {
                    {
                        "scheduletimer",{"bufftimer", 0.01},
                    },
                    --[[{
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{
                            earthtext = format("%s on <%s>","BC: Earth",L.alert["YOU"]),
                        },
                        "quash",{"earthwarn","#4#"},
                        "alert","earthwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{
                            earthtext = format("%s on <%s>","BC: Earth","#5#"),
                        },
                        "quash",{"earthwarn","#4#"},
                        "alert","earthwarn",
                    },]]
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 106200,
                execute = {
                    {
                        "quash",{"earthwarn","#4#"},
                    },
                },
            },
            -- Seal Armor Breached
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[105847]},
                        "expect",{"#1#","find","boss"},
                        "canceltimer","breachtimer",
                        "scheduletimer",{"breachtimer", 1},
                    },
                },
            },
            -- Blood of Neltharion
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 106213,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{nelttext = format(L.alert["%s on <%s>"],SN[106213],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{nelttext = format(L.alert["%s on <%s>"],SN[106213],"#5#")},
                    },
                    {
                        "alert","neltwarn",
                    },
                },
            },
            
		},
	}

	DXE:RegisterEncounter(data)
end

------------------------
-- MADNESS OF DEATHWING
------------------------
do
    local GetNumRaidMembers = GetNumRaidMembers
    local UnitIsDead,UnitIsUnit,tostring,tonumber = UnitIsDead,UnitIsUnit,tostring,tonumber
    local ipairs,pairs = ipairs,pairs
    local GetRaidDifficulty = addon.GetRaidDifficulty
    
    local platform
    local corruptionLocation = nil
    local globalMinimum = 10000000
    local corruptionLocked = false
    local CORRUPTION_CRUSH_THRESHOLD = 5 -- degrees
    
    local CORRUPTION_YSERA_LEFT = {x = 0.3333198428154,  y = 0.844105601310729}
    local CORRUPTION_YSERA_RIGHT = {x = 0.30088406801224, y = 0.80033808946609}
    local CORRUPTION_KALECGOS = {x = 0.43161910772324, y = 0.87278389930725}
    local CORRUPTION_NOZDORMU_LEFT = {x = 0.27773332595825, y = 0.7665581703186}
    local CORRUPTION_NOZDORMU_RIGHT = {x = 0.24347460269928, y = 0.69407141208649}
    local CORRUPTION_ALEXTRASZA_LEFT = {x = 0.22484916448593, y = 0.64629662036896}
    local CORRUPTION_ALEXTRASZA_RIGHT = {x = 0.21437734365463, y = 0.55916863679886}
    
    local CorruptionDistances = {
        [CORRUPTION_YSERA_LEFT] = 0, -- YSERA_(LEFT)
        [CORRUPTION_YSERA_RIGHT] = 0, -- YSERA (RIGHT)
        [CORRUPTION_KALECGOS] = 0, -- KALECGOS
        [CORRUPTION_NOZDORMU_LEFT] = 0, -- NOZDORMU (LEFT)
        [CORRUPTION_NOZDORMU_RIGHT] = 0, -- NOZDORMU (RIGHT)
        [CORRUPTION_ALEXTRASZA_LEFT] = 0, -- ALEXTRASZA (LEFT)
        [CORRUPTION_ALEXTRASZA_RIGHT] = 0, -- ALEXTRASZA (RIGHT)
    }
    
    local CORRUPTIONLIMIT = {
        --["Ysera"] = 24.177906159178,
        ["Ysera"] = 30,
        ["Nozdormu"] = 32.827204004472,
        ["Alexstrasza"] = 32.708381174325,
        ["Kalecgos"] = 24.620442546719
    }
    local LIMIT_DEDUCTION = 0
    
    local function getCorruptionLimit()
        if globalMinimum < 200 then
            return globalMinimum
        else
            return CORRUPTIONLIMIT[platform]
        end
    end
    
    local function resetCorruption() 
        corruptionLocation = nil
        globalMinimum = 10000000
        corruptionLocked = false
    end
    
    local function lockCorruption()
        if corruptionLocation and not corruptionLocked then
            corruptionLocked = true
        end
    end
    
    local function isCorruptionLocked()
        return tostring(corruptionLocked)
    end
    
    local function getClosestCorruption()
        local min = 1000000
        local minCorruptionLocation = nil
        for corruptionLocation,dist in pairs(CorruptionDistances) do
            if dist < min then
                min = dist
                minCorruptionLocation = corruptionLocation
            end
        end
        
        return minCorruptionLocation, min
    end
    
    local function setPlatform(newPlatform)
        platform = newPlatform
    end
    
    local function updateCorruptionLocation(destPlayer)
        local mapData = LineAPI.GetMapData()
        local playerPosition = mapData:ToMapPos(LineAPI.GetUnitPosition(destPlayer))
        for corruptionLocation,_ in pairs(CorruptionDistances) do
            CorruptionDistances[corruptionLocation] = LineAPI.GetDistance(mapData:ToMapPos(corruptionLocation),
                                                                          playerPosition)
        end
        
        local location,distance = getClosestCorruption()
        if (not corruptionLocked) and (distance <= CORRUPTIONLIMIT[platform]*(1-LIMIT_DEDUCTION)) and (distance < globalMinimum) then
            corruptionLocation = location
            globalMinimum = distance
        end
    end
    
    local function updatecorruptionline(API, mapData)
        if corruptionLocation and ItemValue("radarlines","madnessofdeathwing") == "true" then
            local lineThickness = tonumber(ItemValue("linethickness","madnessofdeathwing"))
            local maxStackSize = tonumber(ItemValue(format("stacksize%s",addon:GetRaidDifficulty()),"madnessofdeathwing"))
            local corruptPosition = mapData:ToMapPos(corruptionLocation)
            local playerPosition = mapData:ToMapPos(API.GetUnitPosition("player"))

            for i = 1, GetNumRaidMembers() do
                local unit = format("%s%d", "raid", i)

                if not UnitIsDead(unit) and not UnitIsUnit(unit, "player") then
                    local unitLocation = API.GetUnitPosition(unit)
                    
                    if unitLocation.x ~= 0 and unitLocation.y ~= 0 then
                        local unitPosition = mapData:ToMapPos(unitLocation)
                        local dist = API.GetPointFromLineDistance(corruptPosition, unitPosition, playerPosition)
                        
                        if dist < API.GetRadarRange() then
                            local unitLoc = API.MapPosToRadarPoint(unitPosition)
                            local origin = API.MapPosToRadarPoint(corruptPosition)
                            local x1, y1, x2, y2 = API.GetHalfLine(origin.x, origin.y, unitLoc.x, unitLoc.y)
                            
                            local count = 1
                            
                            for j = 1, GetNumRaidMembers() do
                                local unit = format("%s%d", "raid", j)
                                if i ~= j and not UnitIsDead(unit) then
                                    local destLocation = API.GetUnitPosition(unit)
                                    if destLocation.x ~= 0 and destLocation.y ~= 0 then
                                        local destPosition = mapData:ToMapPos(destLocation)
                                        local angle = API.GetAngle(corruptPosition, unitPosition, destPosition)
                                        if angle < CORRUPTION_CRUSH_THRESHOLD then count = count + 1 end
                                    end
                                end
                            end
                            
                            local red = (count - 1) / maxStackSize
                            local green = (maxStackSize - count + 1) / maxStackSize
                            local blue = 0
                            
                            API.RadarDrawLine(x1, y1, x2, y2, lineThickness, {red, green, blue, 1})
                        end
                    end
                end
            end
        end
    end

    local function anyoneClose(API, mapData)
        local playerPosition = mapData:ToMapPos(API.GetUnitPosition("player"))
        
        if corruptionLocation and ItemValue("radarlines","madnessofdeathwing") == "true" then
            local corruptPosition = mapData:ToMapPos(corruptionLocation)
            local maxStackSize = tonumber(ItemValue(format("stacksize%s",GetRaidDifficulty()),"madnessofdeathwing"))
            
            for i = 1, GetNumRaidMembers() do
                local unit = format("%s%d", "raid", i)
                if not UnitIsDead(unit) and not UnitIsUnit(unit, "player") then
                    local destLocation = API.GetUnitPosition(unit)
                    if destLocation.x ~= 0 and destLocation.y ~= 0 then
                        local destPosition = mapData:ToMapPos(destLocation)
                        local angle = API.GetAngle(corruptPosition, destPosition, playerPosition)
                        if angle < CORRUPTION_CRUSH_THRESHOLD then
                            if maxStackSize == 1 then
                                return true
                            else
                                local count = 2
                                
                                for j = 1, GetNumRaidMembers() do
                                    local unit = format("%s%d", "raid", j)
                                    if i ~= j and not UnitIsDead(unit) and not UnitIsUnit(unit, "player") then
                                        local destLocation = API.GetUnitPosition(unit)
                                        if destLocation.x ~= 0 and destLocation.y ~= 0 then
                                            local destPosition = mapData:ToMapPos(destLocation)
                                            local angle = API.GetAngle(corruptPosition, destPosition, playerPosition)
                                            if angle < CORRUPTION_CRUSH_THRESHOLD then count = count + 1 end
                                        end
                                    end
                                end
                                
                                return count > maxStackSize
                            end
                        end
                    end
                end
            end
        end
        
        return false
    end
    
	local data = {
		version = 8,
		key = "madnessofdeathwing",
		zone = L.zone["Dragon Soul"],
		category = L.zone["Dragon Soul"],
		name = L.npc_dragonsoul["Madness of Deathwing"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Corrupted Deathwing.blp",
		advanced = {
            delayWipe = 5,
        },
        triggers = {
			scan = {
				{56103, type = "select_only"}, -- Thrall
                56173, -- Deathwing
			},
			yell = L.chat_dragonsoul["^You have done NOTHING"],
		},
		onactivate = {
            tracing = {
                {unit = "boss", npcid = 56173}, -- Madness
            },
			tracerstart = true,
			combatstop = true,
			defeat = {
                "I will realign the flow of mana", -- Kalecgos
                "The fire of my heart glows", -- Alexstrasza
                "I will expend everything to bind", -- Nozdormu
                "transcendent power of the Emerald Dream", -- Ysera
            },
		},
		userdata = {
			-- Timers
            tentaclecd = {10.5,18, loop = false, type = "series"},
            boltcd = {40.5, 57.5, loop = false, type = "series"},
            hemocd = {84, 102, loop = false, type = "series"},
            cataclysmcd = {175, 192, loop = false, type = "series"},
            
            -- Texts
            assaulttext = "",
            parasiteguid = "",
            parasitetext = "",
            parasitecountdowntext = "",
            impaletext = "",
            
            -- Switches
            phase = "1",
            firstaspect = "yes",
            shieldenabled = "yes",
            
            -- Counters
            bloodskilled = 0,
            parasitetimermax = 80,
            
            -- Lists
            shrapnel_units = {type = "container", wipein = 3},
		},
        onstart = {
			{
                "alert","enragecd",
            },
            {
                "expect",{"&difficulty&",">=","3"},
                "set",{hemocd = {55, 72, loop = false, type = "series"}},
			},
		},
		
        announces = {
            parasitesay = {
                type = "SAY",
                subtype = "self",
                spell = 108649,
                msg = format(L.alert["%s on ME!"],SN[108649]),
            },
            
        },
        raidicons = {
            parasitemark = {
                varname = format("%s {%s}",SN[108649],"PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 10,
                unit = "#5#",
                reset = 10,
                icon = 3,
                total = 3,
                texture = ST[108649],
            },
            shrapnelmark = {
                varname = format("%s {%s}",SN[110141],"ABILITY_TARGET_HARM"),
                type = "MULTIFRIENDLY",
                persist = 6,
                unit = "#5#",
                reset = 6,
                icon = 1,
                total = 8,
                texture = ST[110141],
            },
        },
		filters = {
            bossemotes = {
                assaultemote = {
                    name = "Assault Aspects cast",
                    pattern = "begins to cast %[Assault Aspects%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[107018],
                },
                assaultsemote = {
                    name = "Assaults Aspect",
                    pattern = "assaults %[",
                    hasIcon = false,
                    hide = true,
                    texture = ST[107018],
                },
                elementiumboltemote = {
                    name = "Elementium Bolt",
                    pattern = "begins to cast %[Elementium Bolt%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[105651],
                },
                hemorrhageemote = {
                    name = "Hemorrhage",
                    pattern = "begins to %[Hemorrhage%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[105863],
                },
                cataclysmemote = {
                    name = "Cataclysm",
                    pattern = "begins to cast %[Cataclysm%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[110044],
                },
                impaleaspectemote = {
                    name = "Impale on Aspect",
                    pattern = "begins to impale the Aspect",
                    hasIcon = false,
                    texture = ST[106400],
                },
                blisteringtentaclesemote = {
                    name = "Blistering Tentacles",
                    pattern = "is injured and sprouts",
                    hasIcon = true,
                    hide = true,
                    texture = ST[46856],
                },
                cauterizeemote = {
                    name = "Cauterize",
                    pattern = "begins to cast %[Cauterize%]",
                    hasIcon = true,
                    texture = ST[64422],
                },
                phase2emote = {
                    name = "Phase 2 emote",
                    pattern = "Deathwing falls forward",
                    hasIcon = true,
                    hide = true,
                    texture = ST[11242],
                },
            },
        },
        counters = {
            bloodscounter = {
                variable = "bloodskilled",
                label = "Bloods killed",
                value = 0,
                minimum = 0,
                maximum = 6,
            },
        },
		windows = {
			proxwindow = true,
			proxrange = 42,
			proxoverride = true,
            proxnoauto = true,
            radarhandler = updatecorruptionline,
            customanyoneclose = anyoneClose,
            radarreset = resetCorruption,
            nodistancecheck = true,
		},
        misc = {
            name = format("|T%s:16:16|t %s",ST[6711],"Radar Lines"),
            args = {
                radarlines = {
                    name = format(L.chat_dragonsoul["Show Radar Lines for |T%s:16:16|t |cffffd600Crush|r"],ST[109629]),
                    type = "toggle",
                    order = 1,
                    default = true,
                },
                linethickness = {
                    name = L.chat_dragonsoul["Line Thickness"],
                    type = "range",
                    width = "full",
                    order = 2,
                    default = 50,
                    min = 10,
                    max = 120,
                    step = 1,
                },
                stack_size_header = {
                    type = "header",
                    name = "Stack Size",
                    order = 3,
                },
                stacksize1 = {
                    name = L.chat_dragonsoul["10-Player (Normal)"],
                    desc = L.chat_dragonsoul["How many players can be stacked for a single Crush."],
                    type = "range",
                    order = 4,
                    default = 2,
                    min = 1,
                    max = 5,
                    step = 1,
                },
                stacksize3 = {
                    name = L.chat_dragonsoul["10-Player (Heroic)"],
                    desc = L.chat_dragonsoul["How many players can be stacked for a single Crush."],
                    type = "range",
                    order = 5,
                    default = 1,
                    min = 1,
                    max = 5,
                    step = 1,
                },
                stacksize2 = {
                    name = L.chat_dragonsoul["Stack Size (25-Player Normal)"],
                    desc = L.chat_dragonsoul["How many players can be stacked for a single Crush."],
                    type = "range",
                    order = 6,
                    default = 3,
                    min = 1,
                    max = 5,
                    step = 1,
                },
                stacksize4 = {
                    name = L.chat_dragonsoul["25-Player (Heroic)"],
                    desc = L.chat_dragonsoul["How many players can be stacked for a single Crush."],
                    type = "range",
                    order = 6,
                    default = 2,
                    min = 1,
                    max = 5,
                    step = 1,
                },
            },
        },
        functions = {
            resetcorruption = resetCorruption,
            updatecorruptionlocation = updateCorruptionLocation,
            lockcorruption = lockCorruption,
            iscorruptionlocked = isCorruptionLocked,
            setplatform = setPlatform,
            getcorruptionlimit = getCorruptionLimit,
        },
        radars = {
            parasiteradar = {
                varname = SN[108649],
                type = "circle",
                player = "#5#",
                range = 10,
                mode = "avoid",
                color = "GREEN",
                icon = ST[108649],
            },
            corruptionradar = {
                varname = "Mutated Corruption",
                type = "circle",
                x = "<corruptX>",
                y = "<corruptY>",
                range = "&getcorruptionlimit&",
                exactrange = true,
                mode = "enter",
                icon = "Interface\\ICONS\\ability_deathwing_grasping_tendrils",
            },
            
        },
        grouping = {
            {
                general = true,
                alerts = {"enragecd"},
            },
            {
                phase = 1,
                alerts = {"assaultedwarn","assaultwarn","parasitecd","parasitewarn","parasiteselfwarn","parasitecountdown","corruptionwarn","tentaclecd","tentaclewarn","crushcd","impalecd","impalewarn","impaleselfwarn","boltcd","boltwarn","boltlandingcd","hemocd","hemowarn","hemocountdown","regeneratecd","tentacleswarn","cataclysmcd","cataclysmwarn","paindur",},
            },
            {
                phase = 2,
                alerts = {"phase2warn","fragmentscd","fragmentswarn","fragmentcountdown","shrapnelwarn","shrapnelselfwarn","terrorcd","terrorwarn","terrorcountdown","bloodwarn"},
            },
        },
        
        alerts = {            
            -- Crush
            crushcd = {
                varname = format(L.alert["%s CD"],SN[109629]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[109629]),
                time = 7, -- regular
                time2 = 8.5,  -- after Impale
                time3 = 6.5,  -- after Summon Tail
                flashtime = 10,
                color1 = "CYAN",
                color2 = "Off",
                sound = "None",
                icon = ST[109629],
                behavior = "singleton",
            },
            -- Berserk
            enragecd = {
                varname = L.alert["Berserk CD"],
                type = "dropdown",
                text = L.alert["Berserk"],
                time10n = 900,
                time25n = 900,
                time10h = 900,
                time25h = 900,
                flashtime = 60,
                color1 = "RED",
                sound = "MINORWARNING",
                icon = ST[12317],
            },
            -------------
            -- Phase 1 --
            -------------
            -- Assault Aspects
            assaultwarn = {
                varname = format(L.alert["%s Cast"],SN[107018]),
                type = "simple",
                text = format(L.alert["Assaulting an Aspect"]),
                time = 10,
                flashtime = 5,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[107018],
            },
            assaultedwarn = {
                varname = format(L.alert["%s Warning"],SN[107018]),
                type = "simple",
                text = "<assaulttext>",
                time = 1,
                color1 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[107018],
            },
            
            -- Corrupting Parasite
            parasitecd = {
                varname = format(L.alert["%s CD"],SN[108649]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[108649]),
                time = "<parasitecd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[108649],
            },
            parasitewarn = {
                varname = format(L.alert["%s Warning"],SN[108649]),
                type = "simple",
                text = "<parasitetext>",
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[108649],
            },
            parasiteselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[108649]),
                type = "centerpopup",
                text = format(L.alert["%s on %s"],SN[108649],L.alert["YOU"]),
                time = 10,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[108649],
                emphasizewarning = true,
            },
            parasitecountdown = {
                varname = format(L.alert["%s Countdown"],SN[108649]),
                type = "centerpopup",
                text = "<parasitecountdowntext>",
                time = 10,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[108649],
            },
            -- Unstable Corruption
            corruptionwarn = {
                varname = format(L.alert["%s Warning"],SN[108813]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[108813]),
                time = 10,
                time2 = 15,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[108813],
                tag = "#1#",
            },
            -- Summon Tentacle
			tentaclecd = {
				varname = format(L.alert["%s CD"],SN[105535]),
				type = "dropdown",
				text =  format(L.alert["New %s"],"Mutated Corruption"),
				time = "<tentaclecd>",
				flashtime = 5,
				color1 = "LIGHTGREEN",
				icon = ST[104972],
				sound = "ALERT5",
			},
            tentaclewarn = {
                varname = format(L.alert["%s Warning"],SN[105535]),
                type = "simple",
                text = format(L.alert["%s - SWITCH TARGET!"],"Mutated Corruption"),
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT10",
                icon = ST[104972],
            },
            -- Impale
            impalecd = {
				varname = format(L.alert["%s CD"],SN[106400]),
				type = "dropdown",
				text =  format(L.alert["Next %s"],SN[106400]),
                text2 =  format(L.alert["%s CD"],SN[106400]),
				time = 36,
				time2 = 10, -- seen 9-11, perhaps %based
				flashtime = 5,
				color1 = "BROWN",
                color2 = "RED",
				icon = ST[106400],
                sound = "MINORWARNING",
                sticky = true,
			},
			impalewarn = {
				varname = format(L.alert["%s Warning"],SN[106400]),
				type = "centerpopup",
				text =  "<impaletext>",
				time = 4,
				flashtime = 4,
				color1 = "YELLOW",
				icon = ST[106400],
				sound = "ALERT5",
				throttle = 6, -- should do the trick
			},
            impaleselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[106400]),
				type = "centerpopup",
				text =  "<impaletext>",
				time = 4,
				flashtime = 4,
				color1 = "YELLOW",
				icon = ST[106400],
				sound = "ALERT5",
				throttle = 6, -- should do the trick
                emphasizewarning = true,
			},
            -- Elementium Bolt
            boltcd = {
				varname = format(L.alert["%s CD"],SN[105651]),
				type = "dropdown",
				text =  format(L.alert["Next %s"],SN[105651]),
				time = "<boltcd>",
				flashtime = 10,
				color1 = "YELLOW",
				icon = ST[105651],
                sound = "MINORWARNING",
			},
            boltwarn = {
				varname = format(L.alert["%s Warning"],SN[105651]),
				type = "simple",
				text =  format(L.alert["%s"],SN[105651]),
				time = 3,
				color1 = "YELLOW",
				icon = ST[105651],
				sound = "ALERT1",
			},
            boltlandingcd = {
                varname = format(L.alert["%s Landing Countdown"],SN[105651]),
                type = "dropdown",
                text = format(L.alert["%s landing"],SN[105651]),
                time = "<boltlandingcd>",
                flashtime = 10,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[105651],
                audiocd = true,
            },
            -- Hemorrhage
			hemocd = {
				varname = format(L.alert["%s CD"],SN[105863]),
				type = "dropdown",
				text =  format(L.alert["New %s"],"Regenerative Bloods"),
				time = "<hemocd>",
				flashtime = 5,
				color1 = "ORANGE",
				icon = ST[105863],
			},
			hemowarn = {
				varname = format(L.alert["%s Warning"],SN[105863]),
				type = "simple",
				text =  format(L.alert["New: %s"],"Regenerative Bloods"),
				time = 3,
				color1 = "RED",
				icon = ST[105863],
				sound = "ALERT9",
			},
            hemocountdown = {
                varname = format(L.alert["%s Cast"],"Summon Regenerative Bloods"),
                type = "centerpopup",
                text = format(L.alert["summoning %s"],"Bloods"),
                time = 3.1,
                color1 = "RED",
                fillDirection = "DEPLETE",
                sound = "ALERT7",
                icon = ST[61618],
            },
            -- Regenerate Blood
            regeneratecd = {
                varname = format(L.alert["%s CD"],"Bloods' Heal"),
                type = "centerpopup",
                text = format(L.alert["%s"],"Bloods: Next heal"),
                time = 10,
                flashtime = 5,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "ALERT8",
                icon = ST[105937],
                throttle = 2,
                audiocd = true,
            },
            -- Blistering Tentacles
            tentacleswarn = {
                varname = format(L.alert["%s Warning"],"Blistering Tentacles"),
                type = "simple",
                text = format(L.alert["New: %s"],"Blistering Tentacles"),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = "Interface\\Icons\\ability_warrior_bloodnova",
            },
            
			-- Cataclysm
            cataclysmwarn = {
				varname = format(L.alert["%s Warning"],SN[110044]),
				type = "simple",
				text =  format(L.alert["%s!"],SN[110044]),
				time = 60,
				flashtime = 10,
				color1 = "GOLD",
				icon = ST[110044],
				sound = "BEWARE",
			},
			cataclysmcd = {
				varname = format(L.alert["%s CD"],SN[110044]),
				type = "dropdown",
				text =  format(L.alert["%s comes!"],SN[110044]),
				time = "<cataclysmcd>",--30,
				flashtime = 30,
				color1 = "RED",
				icon = ST[110044],
                sound = "MINORWARNING",
			},
            -- Agonizing Pain
			paindur = {
				varname = format(L.alert["%s Duration"],SN[106548]),
				type = "centerpopup",
				text =  format(L.alert["%s fades"],SN[106548]),
				time = 6.5,
				flashtime = 6.5,
				color1 = "TURQUOISE",
                color2 = "LIGHTBLUE",
				icon = ST[106548],
			},
            -------------
            -- Phase 2 --
            -------------
            phase2warn = {
                varname = format(L.alert["Phase 2 Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"2"),
                time = 1,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[11242],
            },
            -- Elementium Fragments
            fragmentswarn = {
                varname = format(L.alert["Summon %s Warning"],"Elementium Fragments"),
                type = "simple",
                text = format(L.alert["New: %s"],"Elementium Fragments"),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT9",
                icon = ST[61618],
            },
            fragmentscd = {
                varname = format(L.alert["%s CD"],"Summon Elementium Fragments"),
                type = "dropdown",
                text = format(L.alert["New %s"],"Elementium Fragments"),
                time = 90,
                time2 = 10.5,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[61618],
            },
            fragmentcountdown = {
                varname = format(L.alert["%s Cast"],"Summon Elementium Fragments"),
                type = "centerpopup",
                text = format(L.alert["summoning %s"],"Fragments"),
                time = 3.1,
                color1 = "RED",
                fillDirection = "DEPLETE",
                sound = "ALERT7",
                icon = ST[61618],
            },
            -- Shrapnel
			shrapnelselfwarn = {
				varname = format(L.alert["%s on me Warning"],SN[110141]),
				type = "centerpopup",
				text = format(L.alert["%s on %s"],SN[110141],L.alert["YOU"]),
				time = 6,
				flashtime = 5,
				color1 = "GOLD",
				sound = "ALERT4",
				icon = ST[110141],
				flashscreen = true,
                emphasizewarning = true,
                tag = "#1#"
			},
            shrapnelwarn = {
                varname = format(L.alert["%s Warning"],SN[110141]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[110141],"&list|shrapnel_units&"),
                time = 1,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[110141],
            },
			-- Elementium Terror
			terrorcd = {
				varname = format(L.alert["%s CD"],"Summon Elementium Terrors"),
				type = "dropdown",
				text =  format(L.alert["New %s"],"Elementium Terrors"),
				time = 90,
                time2 = 35.5,
				flashtime = 5,
				color1 = "YELLOW",
                color2 = "ORANGE",
				icon = ST[106766],
			},
            terrorwarn = {
                varname = format(L.alert["Summon %s Warning"],"Elementium Terrors"),
                type = "simple",
                text = format(L.alert["New: %s"],"Elementium Terrors"),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT9",
                icon = ST[106766],
            },
            terrorcountdown = {
                varname = format(L.alert["%s Cast"],"Summon Elementium Terrors"),
                type = "centerpopup",
                text = format(L.alert["summoning %s"],"Terrors"),
                time = 3.1,
                color1 = "RED",
                fillDirection = "DEPLETE",
                sound = "ALERT7",
                icon = ST[106766],
            },
            -- Congealing Blood
            bloodwarn = {
                varname = format(L.alert["%s Warning"],SN[109091]),
                type = "simple",
                text = format(L.alert["New: %s"],SN[109091]),
                time = 1,
                color1 = "RED",
                color2 = "RED",
                sound = "ALERT10",
                icon = ST[109089],
            },
            
		},
		timers = {
            shrapneltimer = {
                {
                    "alert","shrapnelwarn",
                },
            },
            parasitetimer = {
                {
                    "set",{parasitetimercounter = "INCR|1"},
                    "expect",{"<parasitetimercounter>","<","<parasitetimermax>"}, -- and yes I have seen DBM's implementation of this
                    "set",{parasiteunit = "&unitbyguid|<parasiteguid>&"},
                    "invoke",{
                        {
                            "expect",{"<parasiteunit>","~=","nil"},
                            "invoke",{
                                {
                                    "expect",{"&buff|<parasiteunit>|Time Zone&","==","true"},
                                    "quash","corruptionwarn",
                                    "alert",{"corruptionwarn",time = 2},
                                },
                            },
                            "settimeleft",{"corruptionwarn","&casttimeleft|<parasiteunit>&"},
                        },
                        {
                            "expect",{"<parasiteunit>","==","nil"},
                            "scheduletimer",{"parasitetimer", 0.1},
                        },
                    },
                },
            },
        },
        events = {
            -- Assault Aspects
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 107018,
                execute = {
                    {
                        "batchquash",{"cataclysmcd","cataclysmwarn", "hemocd"},
                        "alert","tentaclecd",
						"alert","boltcd",
                        "alert","hemocd",
                        "alert","cataclysmcd",
                        "alert","assaultwarn",
                    },
                    {
                        "expect",{"&difficulty&",">=","3"}, -- HC only
                        "invoke",{
                            {
                                "expect",{"<firstaspect>","==","no"},
                                "set",{parasitecd = {22, 60, 0, loop = false, type = "series"}},
                                "alert","parasitecd",
                            },
                            {
                                "expect",{"<firstaspect>","==","yes"},
                                "set",{firstaspect = "no"},
                                "set",{parasitecd = {11, 60, 0, loop = false, type = "series"}},
                                "alert","parasitecd",
                            },
                        },
                    },
                },
            },
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_dragonsoul["^.+assaults.+Kalecgos.+$"]},
                        "set",{assaulttext = format("Defend %s","|cff5858faKalecgos|r")},
                        "execute",{"setplatform","Kalecgos"},
                        "alert","assaultedwarn",
                        "temptracing",{{unit = "boss", npcid = 56168}},
                        "addphasemarker",{2, 1, 0.70, "Blistering Tentacles","At 70% remaining HP several Blistering Tentacles immune to AoE appear."},
                        "addphasemarker",{2, 2, 0.40, "Blistering Tentacles","At 40% remaining HP several Blistering Tentacles immune to AoE appear."},
                        "invoke",{
                            {
                                "expect",{"<shieldenabled>","==","yes"},
                                "set",{boltlandingcd = 14.4},
                            },
                            {
                                "expect",{"<shieldenabled>","==","no"},
                                "set",{boltlandingcd = 6.4},
                            },
                        },
                        "expect",{"&unitrole|player&","==","TANK"},
                        "set",{corruptX = CORRUPTION_KALECGOS.x},
                        "set",{corruptY = CORRUPTION_KALECGOS.y},
                        "radar","corruptionradar",
                    },
                    {
                        "expect",{"#1#","find",L.chat_dragonsoul["^.+assaults.+Ysera.+$"]},
                        "set",{assaulttext = format("Defend %s","|cff04fc32Ysera|r")},
                        "execute",{"setplatform","Ysera"},
                        "alert","assaultedwarn",
                        "temptracing",{{unit = "boss", npcid = 56167}},
                        "addphasemarker",{2, 1, 0.70, "Blistering Tentacles","At 70% remaining HP several Blistering Tentacles immune to AoE appear."},
                        "addphasemarker",{2, 2, 0.40, "Blistering Tentacles","At 40% remaining HP several Blistering Tentacles immune to AoE appear."},
                        "invoke",{
                            {
                                "expect",{"<shieldenabled>","==","yes"},
                                "set",{boltlandingcd = 14.2},
                            },
                            {
                                "expect",{"<shieldenabled>","==","no"},
                                "set",{boltlandingcd = 6.7},
                            },
                        },
                        "expect",{"&unitrole|player&","==","TANK"},
                        "set",{corruptX = CORRUPTION_YSERA_LEFT.x},
                        "set",{corruptY = CORRUPTION_YSERA_LEFT.y},
                        "radar","corruptionradar",
                        "set",{corruptX = CORRUPTION_YSERA_RIGHT.x},
                        "set",{corruptY = CORRUPTION_YSERA_RIGHT.y},
                        "radar","corruptionradar",
                    },
                    {
                        "expect",{"#1#","find",L.chat_dragonsoul["^.+assaults.+Nozdormu.+$"]},
                        "set",{assaulttext = format("Defend %s","|cffffff00Nozdormu|r")},
                        "execute",{"setplatform","Nozdormu"},
                        "alert","assaultedwarn",
                        "temptracing",{{unit = "boss", npcid = 56846}},
                        "addphasemarker",{2, 1, 0.70, "Blistering Tentacles","At 70% remaining HP several Blistering Tentacles immune to AoE appear."},
                        "addphasemarker",{2, 2, 0.40, "Blistering Tentacles","At 40% remaining HP several Blistering Tentacles immune to AoE appear."},
                        "set",{
                            boltlandingcd = 14.3,
                            shieldenabled = "no",
                        },
                        "expect",{"&unitrole|player&","==","TANK"},
                        "set",{corruptX = CORRUPTION_NOZDORMU_LEFT.x},
                        "set",{corruptY = CORRUPTION_NOZDORMU_LEFT.y},
                        "radar","corruptionradar",
                        "set",{corruptX = CORRUPTION_NOZDORMU_RIGHT.x},
                        "set",{corruptY = CORRUPTION_NOZDORMU_RIGHT.y},
                        "radar","corruptionradar",
                    },
                    {
                        "expect",{"#1#","find",L.chat_dragonsoul["^.+assaults.+Alexstrasza.+$"]},
                        "set",{assaulttext = format("Defend %s","|cffff0000Alexstrasza|r")},
                        "execute",{"setplatform","Alexstrasza"},
                        "alert","assaultedwarn",
                        "temptracing",{{unit = "boss", npcid = 56168}},
                        "addphasemarker",{2, 1, 0.70, "Blistering Tentacles","At 70% remaining HP several Blistering Tentacles immune to AoE appear."},
                        "addphasemarker",{2, 2, 0.40, "Blistering Tentacles","At 40% remaining HP several Blistering Tentacles immune to AoE appear."},
                        "invoke",{
                            {
                                "expect",{"<shieldenabled>","==","yes"},
                                "set",{boltlandingcd = 14.8},
                            },
                            {
                                "expect",{"<shieldenabled>","==","no"},
                                "set",{boltlandingcd = 7.2},
                            },
                        },
                        "expect",{"&unitrole|player&","==","TANK"},
                        "set",{corruptX = CORRUPTION_ALEXTRASZA_LEFT.x},
                        "set",{corruptY = CORRUPTION_ALEXTRASZA_LEFT.y},
                        "radar","corruptionradar",
                        "set",{corruptX = CORRUPTION_ALEXTRASZA_RIGHT.x},
                        "set",{corruptY = CORRUPTION_ALEXTRASZA_RIGHT.y},
                        "radar","corruptionradar",
                    },
                    {
                        "expect",{"#1#","find",L.chat_dragonsoul["is injured and sprouts"]},
                        "alert","tentacleswarn",
                        
                    },
                },
            },
            
            -- Corrupting Parasite
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[108597]},
                        "expect",{"#1#","find","boss"},
                        "alert","parasitecd",
                        "expect",{"&itemvalue|radarlines&","==","false"},
                        "range",{true},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 108649,
                execute = {
                    {
                        "raidicon","parasitemark",
                        "radar","parasiteradar",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "invoke",{
                            {
                                "expect",{"&itemenabled|parasiteselfwarn&","==","true"},
                                "alert","parasiteselfwarn",
                            },
                            {
                                "expect",{"&itemenabled|parasiteselfwarn&","==","false"},
                                "set",{
                                    parasitetext = format(L.alert["%s on <%s>"],SN[108649],L.alert["YOU"]),
                                    parasitecountdowntext = format(L.alert["%s on <%s>"],"Parasite",L.alert["YOU"])},
                                "alert","parasitewarn",
                                "alert","parasitecountdown",
                            },
                        },
                        "announce","parasitesay",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{
                            parasitetext = format(L.alert["%s on <%s>"],SN[108649],"#5#"),
                            parasitecountdowntext = format(L.alert["%s on <%s>"],"Parasite","#5#")},
                        "alert","parasitewarn",
                        "alert","parasitecountdown",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellid = 108649,
                execute = {
                    {
                        "removeradar",{"parasiteradar", player = "#5#"},
                    },
                },
            },
            
            -- Unstable Corruption
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = 108813,
                execute = {
                    {
                        "quash","corruptionwarn",
                        "alert","corruptionwarn",
                        "set",{
                            parasiteguid = "#1#",
                            parasitetimercounter = 0,
                        },
                        "scheduletimer",{"parasitetimer", 0.1},
                        "expect",{"&itemvalue|radarlines&","==","false"},
                        "range",{false},
                    },
                },
            },
            -- Summon Mutated Corrupted (Summon Tail)
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[106239]},
                        "expect",{"#1#","find","boss"},
                        "alert","tentaclewarn",
                        "quash","crushcd",
                        "alert",{"crushcd",time = 3},
                        "temptracing",{{unit = "boss", npcid = 56471}},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    -- Mutated Corruption dies
                    {
                        "expect",{"&npcid|#4#&","==","56471"},
                        "quash","impalecd",
                        "quash","crushcd",
                        "execute","resetcorruption",
                    },
                    -- Elementium Fragment dies
                    {
                        "expect",{"&npcid|#4#&","==","56724"},
                        "quash",{"shrapnelselfwarn","#4#"},
                    },
                    -- Corrupting Parasite dies
                    {
                        "expect",{"&npcid|#4#&","==","57479"},
                        "quash",{"corruptionwarn","#4#"},
                    },
                    -- Regenerative Blood killed
                    {
                        "expect",{"&npcid|#4#&","==","56263"},
                        "set",{bloodskilled = "INCR|1"},
                        "expect",{"<bloodskilled>","==","6"},
                        "quash","regeneratecd",
                        "removecounter","bloodscounter",
                    },
                    -- Elementium Bolt dies
                    {
                        "expect",{"&npcid|#4#&","==","56262"},
                        "quash","boltlandingcd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "PARTY_KILL",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","56262"},
                        "quash","boltlandingcd",
                    },
                },
            },
            
            -- Summon Tail (1st Impale CD)
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[106239]},
                        "expect",{"#1#","find","boss"},
                        "alert",{"impalecd",time = 2, text = 2},
                    },
                },
            },
            -- Impale
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 106400,
                dstisplayertype = true,
				execute = {
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{impaletext = format("%s on <%s>",SN[106400],"#5#")},
						"alert","impalewarn",
					},
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{impaletext = format("%s on <%s>",SN[106400],L.alert["YOU"])},
						"alert","impaleselfwarn",
					},
				},
			},
            -- Mutated Corruption identification
            {
                type = "combatevent",
                eventtype = {"SWING_DAMAGE","SWING_MISSED"},
                execute = {
                    {
                        "expect",{"&unitrole|#5#&","==","TANK"},
                        "expect",{"&npcid|#1#&","==","56471"}, -- Mutated Corruption
                        "execute",{"updatecorruptionlocation","#5#"},
                        "radarcirclerange",{"corruptionradar","&getcorruptionlimit&"},
                    },
                },
            },
            -- Crush
            {
                type = "combatevent",
                eventtype = {"SPELL_DAMAGE","SPELL_MISSED"},
                spellname = 109629,
                execute = {
                    {
                        "quash","crushcd",
                        "expect",{"&timeleft|impalecd&",">","7"},
                        "alert","crushcd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = 106400,
                execute = {
                    {
                        "expect",{"&unitrole|#5#&","==","TANK"},
                        "expect",{"&iscorruptionlocked&","==","false"},
                        "execute","lockcorruption",
                        "expect",{"&iscorruptionlocked&","==","true"},
                        "removeradar","corruptionradar",
                    },
                    {
                        "quash","impalecd",
                        "alert","impalecd",
                        "quash","crushcd",
                        "alert",{"crushcd",time = 2},
                    },
                },
            },
            -- Elementium Bolt
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 105651,
				execute = {
					{
						"quash","boltcd",
						"alert","boltwarn",
                        "alert","boltlandingcd",
					},
				},
			},
			-- Hemorrhage
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_dragonsoul["Hemorrhage"]},
                        "quash","hemocd",
                        "alert","hemowarn",
                        "alert","hemocountdown",
                    },
                },
            },
            -- Summon Regenerative Blood
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#5#","==","105932"},
                        "expect",{"#1#","find","boss"},
                        "set",{bloodskilled = 0},
                        "alert","regeneratecd",
                        "counter","bloodscounter",
                    },
                },
            },
            -- Regenerate Blood
            {
                type = "combatevent",
                eventtype = "SPELL_HEAL",
                spellid = {
                    105937, -- 10n
                    110209, -- 10h
                    110210, -- 25n
                    110208, -- 25h
                },
                execute = {
                    {
                        "expect",{"<bloodskilled>","<","6"},
                        "expect",{"&timeleft|regeneratecd&","<","2"},
                        "quash","regeneratecd",
                    },
                    {
                        "expect",{"<bloodskilled>","<","6"},
                        "alert","regeneratecd",
                    },
                },
            },   
            -- Cataclysm
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 110044,
				srcisnpctype = true,
				execute = {
					{
						"alert","cataclysmwarn",
                        "settimeleft",{"cataclysmcd",60},
					},
				},
			},
			-- Agonizing Pain
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 106548,
				execute = {
					{
                        "quash","cataclysmcd",
                        "quash","hemocd",
                        "quash","cataclysmwarn",
						"alert","paindur",
					},
				},
			},
            -------------
            -- Phase 2 --
            -------------
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_dragonsoul["^I AM DEATHWING"]},
                        "batchquash",{"cataclysmcd","cataclysmwarn", "hemocd"},
                        "set",{phase = "2"},
                        "alert","phase2warn",
                        "alert",{"fragmentscd",time = 2},
                        "alert",{"terrorcd",time = 2},
                        "tracing",{
                            {unit = "boss", npcid = 57962, vmax = 0.2}, -- Deathwing's Head
                        },
                        "addphasemarker",{1, 1, 0.01, "Deathwing defeated","At 1% of his HP, Deathwing is defeated."},
                        "expect",{"&difficulty&",">=","3"},
                        "addphasemarker",{1, 2, 0.06, "Congealing Blood","At 6% of his HP, Deathwing spawns Congealing Bloods that move towards him to heal him."},
                        "addphasemarker",{1, 3, 0.11, "Congealing Blood","At 11% of his HP, Deathwing spawns Congealing Bloods that move towards him to heal him."},
                        "addphasemarker",{1, 4, 0.16, "Congealing Blood","At 16% of his HP, Deathwing spawns Congealing Bloods that move towards him to heal him."},
                    },
                },
            },
            -- Summon Elementium Fragments
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"<phase>","==","2"},
                        "expect",{"#2#","==",SN[106775]},
                        "expect",{"#1#","find","boss"},
                        "quash","fragmentscd",
                        "alert","fragmentscd",
                        "alert","fragmentcountdown",
                        "schedulealert",{"fragmentswarn§&gettime&", 3.1},
                    },
                },
            },
            -- Summon Elementium Terror
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"<phase>","==","2"},
                        "expect",{"#2#","==",SN[106765]},
                        "expect",{"#1#","find","boss"},
                        "quash","terrorcd",
                        "alert","terrorcd",
                        "alert","terrorcountdown",
                        "schedulealert",{"terrorwarn§&gettime&", 3.1},
                    },
                },
            },
			-- Shrapnel
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 110141,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","shrapnelselfwarn",
					},
                    {
                        "expect",{"&listcontains|shrapnel_units|#5#&","==","false"},
                        "insert",{"shrapnel_units","#5#"},
                        "raidicon","shrapnelmark",
                        "canceltimer","shrapneltimer",
                        "scheduletimer",{"shrapneltimer", 0.5},
                    },
				},
			},
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    -- Congealing Blood
                    {
                        "expect",{"<phase>","==","2"},
                        "expect",{"&difficulty&",">=","3"},
                        "expect",{"#1#","find",L.chat_dragonsoul["begins to cast .+%[Cauterize%].+"]},
                        "alert","bloodwarn",
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
        key = "dragonsoultrash",
        zone = L.zone["Dragon Soul"],
        category = L.zone["Dragon Soul"],
        name = "Trash",
        triggers = {
            scan = {
                57158, -- Earthen Destroyer
                57160, -- Ancient Water Lord
            },
        },
        
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        
        userdata = {
            bouldertarget = "",
        },
        customcolors = {
            
        },
        alerts = {},
        raidicons = {
            bouldermark = {
                varname = format("%s {%s}",SN[107597],"ABILITY_TARGET_HARM"),
                type = "MULTIFRIENDLY",
                persist = 7,
                unit = "<bouldertarget>",
                reset = 7,
                total = 3,
                icon = 1,
                texture = ST[107597],
            },
        },
        announces = {
			bouldersay = {
				type = "SAY",
                subtype = "self",
                spell = 107597,
				msg = format(L.alert["%s on ME!"],SN[107597]),
			},
        },
        timers = {
            bouldertimer = {
                {
                    "set",{bouldertarget = "&gettarget|#1#&"},
                    "raidicon","bouldermark",
                    "expect",{"<bouldertarget>","==","&unitname|player&"},
                    "announce","bouldersay",
                },
            },
        },
        events = {
            -- Boulder Smash
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 107597,
                srcisnpctype = true,
                execute = {
                    {
                        "scheduletimer",{"bouldertimer", 0.5},
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
    DXE:RegisterMovie("Dragon Soul", "Ultraxion defeated", 73)
    DXE:RegisterMovie("Dragon Soul", "Spine of Deathwing pull", 74)
    DXE:RegisterMovie("Dragon Soul", "Spine of Deathwing defeated", 75)
    DXE:RegisterMovie("Dragon Soul", "Madness of Deathwing defeated", 76)
end

---------------------------------
-- Gossips
---------------------------------
do 
    DXE:RegisterGossip("DS_PostHagara", "We were successful", "Kalecgos: After Hagara")
    DXE:RegisterGossip("DS_PreUltraxionTrash", "You may begin your ritual", "Thrall: Ultraxion trash")
    DXE:RegisterGossip("DS_PreUltraxionActivation", "You may continue your ritual", "Thrall: Ultraxion activation")
    DXE:RegisterGossip("DS_SkyfireDeckTeleport", "We are always ready", "Swayze: Skyfire Deck teleport")
    DXE:RegisterGossip("DS_BlackhornPull", "Bring us in closer", "Swayze: Warmaster Blackhorn pull")
    DXE:RegisterGossip("DS_SpinePull_Alliance", "JUSTICE AND GLORY", "Swayze: Spine of Deathwing pull (alliance)")
    DXE:RegisterGossip("DS_SpinePull_Horde", "FOR THE HORDE!", "Swayze: Spine of Deathwing pull (horde)")
    DXE:RegisterGossip("DS_SpineDefeat", "We defeated the Destroyer", "Thrall: Spine of Deathwing defeat")
    DXE:RegisterGossip("DS_MadnessPull", "He couldn't possibly be alive", "Thrall: Madness of Deathwing pull")
end 
                                                          
