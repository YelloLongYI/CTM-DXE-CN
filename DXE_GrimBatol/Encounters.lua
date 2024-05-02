local L,SN,ST,SL,AL,AT,TI = DXE.L,DXE.SN,DXE.ST,DXE.SL,DXE.AL,DXE.AT,DXE.TI

---------------------------------
-- GENERAL UMBRISS
---------------------------------

do
    local data = {
        version = 3,
        key = "umbriss",
        zone = L.zone["Grim Batol"],
        category = L.zone["Grim Batol"],
        name = L.npc_grimbatol["General Umbriss"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-General Umbriss.blp",
        triggers = {
            scan = {
                39625, -- General Umbriss
            },
        },
        onactivate = {
            tracing = {
                39625,
            },
            phasemarkers = {
                {
                    {0.3, "Frenzy","When General Umbriss reaches 30% of his HP, he enters a frenzy."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39625,
        },
        userdata = {
            blitzcd = {10, 15, loop = false, type = "series"},
            siegecd = {18, 15, loop = false, type = "series"},
            troggscd = {7, 30, loop = false, type = "series"},
            maladytext = "",
            maladywarningtext = "",
        },
        onstart = {
            {
                "alert","blitzcd",
                "alert","siegecd",
                "alert","troggscd",
                "repeattimer",{"checkhp",1},
            },
        },
        
        phrasecolors = {
            {"is affected by","WHITE"},
        },
        filters = {
            bossemotes = {
                blitzemote = {
                    name = "Blitz",
                    pattern = "begins to cast %[Blitz%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[90250],
                },
                siegeemote = {
                    name = "Ground Siege",
                    pattern = "begins to cast %[Ground Siege%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[90249],
                },
            },
        },
        ordering = {
            alerts = {"troggscd","troggwarn","blitzcd","blitzwarn","blitzselfwarn","siegecd","siegewarn","frenzysoonwarn","frenzywarn","maladywarn"},
        },
        
        alerts = {
            -- Ground Siege
            siegecd = {
                varname = format(L.alert["%s CD"],SN[90249]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[90249]),
                time = "<siegecd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[90249],
            },
            siegewarn = {
                varname = format(L.alert["%s Warning"],SN[90249]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[90249]),
                time = 2,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[90249],
            },
            -- Blitz
            blitzcd = {
                varname = format(L.alert["%s CD"],SN[90250]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[90250]),
                time = "<blitzcd>",
                flashtime = 5,
                color1 = "RED",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[90250],
            },
            blitzwarn = {
                varname = format(L.alert["%s Warning"],SN[90250]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[90250]),
                time = 3,
                color1 = "WHITE",
                sound = "ALERT1",
                icon = ST[90250],
            },
            blitzselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[90250]),
                type = "centerpopup",
                text = format(L.alert["%s on %s"],SN[90250],L.alert["YOU"]),
                time = 3,
                color1 = "WHITE",
                sound = "ALERT1",
                icon = ST[90250],
                emphasizewarning = true,
            },
            -- New Trogg Wave
            troggscd = {
                varname = format(L.alert["%s CD"],"New Trogg wave"),
                type = "dropdown",
                text = format(L.alert["%s"],"New Trogg wave"),
                time = "<troggscd>",
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[19884],
            },
            troggwarn = {
                varname = format(L.alert["%s Warning"],"New Trogg wave"),
                type = "simple",
                text = format(L.alert["%s"],"New: Trogg wave"),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT7",
                icon = ST[19884],
            },
            -- Frenzy soon
            frenzysoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[74853]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[74853]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[74853],
            },
            -- Frenzy
            frenzywarn = {
                varname = format(L.alert["%s Warning"],SN[74853]),
                type = "simple",
                text = format(L.alert["%s!"],SN[74853]),
                time = 1,
                color1 = "ORANGE",
                sound = "BEWARE",
                icon = ST[74853],
            },
            -- Modgud's Malice
            maladywarn = {
                varname = format(L.alert["%s %s on General Umbriss Warning"],TI["AchievementShield"],SN[90170]),
                type = "centerpopup",
                warningtext = "<maladywarningtext>",
                text = "<maladytext>",
                time = 20,
                color1 = "LIGHTBLUE",
                sound = "ALERT10",
                icon = ST[90170],
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
            -- Ground Siege
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 90249,
				execute = {
					{
						"quash","siegecd",
						"alert","siegecd",
						"alert","siegewarn",
					},
				},
			},
            -- Blitz
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 90250,
				execute = {
					{
						"quash","blitzcd",
						"alert","blitzcd",
					},
				},
			},           
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    -- Blitz
                    {
                        "expect",{"#1#","find",L.chat_grimbatol["sets his eyes on"]},
                        "set",{blitzonplayer = "no"},
                        "invoke",{
                            {
                                "expect",{"#1#","find","sets his eyes on |cFFFF0000&playername&|r and begins to cast"},
                                "set",{blitzonplayer = "yes"},
                                "alert","blitzselfwarn",
                            },
                            {
                                "expect",{"<blitzonplayer>","==","no"},
                                "alert","blitzwarn",
                            },
                        },
                    },
                },
            },
            
            {
                type = "event",
                event = "YELL",
                execute = {
                    -- New Trogg Wave
                    {
                        "expect",{"#1#","find",L.chat_grimbatol["^Attack you"]},
                        "quash","troggscd",
                        "alert","troggscd",
                        "alert","troggwarn",
                    },
                },
            },
            -- Frenzy
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 74853,
                execute = {
                    {
                        "alert","frenzywarn",
                    },
                },
            },
            -- Modgud's Malice
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 90170,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39625"},
                        "set",{
                            maladywarningtext = format(L.alert["General Umbriss is affected by %s (%s)!"],SN[90170],"1"),
                            maladytext = format(L.alert["%s (%s)"],SN[90170],"1"),
                        },
                        "quash","maladywarn",
                        "alert","maladywarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 90170,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39625"},
                        "set",{
                            maladywarningtext = format(L.alert["General Umbriss is affected by %s (%s)!"],SN[90170],"#11#"),
                            maladytext = format(L.alert["%s (%s)"],SN[90170],"#11#"),
                        },
                        "quash","maladywarn",
                        "alert","maladywarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- FORGEMASTER THRONGUS
---------------------------------

do
    local data = {
        version = 3,
        key = "throngus",
        zone = L.zone["Grim Batol"],
        category = L.zone["Grim Batol"],
        name = L.npc_grimbatol["Forgemaster Throngus"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Forgemaster Throngus.blp",
        triggers = {
            scan = {
                40177, -- Forgemaster Throngus
            },
        },
        onactivate = {
            tracing = {
                40177,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 40177,
        },
        userdata = {
            pickweaponcd = {12, 35, loop = false, type = "series"},
            stompcd = {7, 15, loop = false, type = "series"},
            slamcd = {10, 12, 0, loop = true, type = "series"},
            flamestext = "",
            slamtext = "",
        },
        onstart = {
            {
                "alert","pickweaponcd",
                "alert","stompcd",
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"stompcd","stompwarn","caveinselfwarn","pickweaponcd","pickweaponwarn","pickweaponcasting"},
            },
            {
                name = format("|cffffd700%s|r |cffffffffequipped|r","Shield"),
                icon = ST[74908],
                alerts = {"phalanxwarn","phalanxduration"},
            },
            {
                name = format("|cffffd700%s|r |cffffffffequipped|r","Swords"),
                icon = ST[90738],
                alerts = {"bladeswarn","bladesduration","flameswarn","roarwarn"},
            },
            {
                name = format("|cffffd700%s|r |cffffffffequipped|r","Mace"),
                icon = ST[75007],
                alerts = {"macewarn","maceduration","slamcd","slamwarn","lavaselfwarn"},
            },
        },
        
        alerts = {
            -- Mighty Stomp
            stompwarn = {
                varname = format(L.alert["%s Warning"],SN[74984]),
                type = "simple",
                text = format(L.alert["%s"],SN[74984]),
                time = 0.85,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[74984],
            },
            stompcd = {
                varname = format(L.alert["%s CD"],SN[74984]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[74984]),
                time = "<stompcd>",
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[74984],
            },
            -- Cave In
            caveinselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[74987]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[74987],L.alert["YOU"]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT10",
                icon = ST[74987],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
            -- Pick Weapon
            pickweaponcd = {
                varname = format(L.alert["%s CD"],SN[75000]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[75000]),
                time = "<pickweaponcd>",
                flashtime = 5,
                color1 = "RED",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[75000],
            },
            pickweaponwarn = {
                varname = format(L.alert["%s Warning"],SN[75000]),
                type = "simple",
                text = L.alert["Forgemaster Throngus is picking a weapon!"],
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT2",
                icon = ST[75000],
            },
            pickweaponcasting = {
                varname = format(L.alert["%s Casting"],SN[75000]),
                type = "centerpopup",
                text = L.alert["Picking weapon!"],
                time = 2,
                color1 = "RED",
                sound = "None",
                icon = ST[75000],
            },
            ------------------------------
            -- Weapon: Personal Phalanx --
            ------------------------------
            -- Personal Phalanx
            phalanxwarn = {
                varname = format(L.alert["%s Warning"],SN[74908]),
                type = "simple",
                text = format(L.alert["He chose the %s!"],SN[74908]),
                time = 1,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[74908],
            },
            phalanxduration = {
                varname = format(L.alert["%s Duration"],SN[74908]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[74908]),
                time = 30,
                flashtime = 10,
                color1 = "ORANGE",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[74908],
            },
            ---------------------------------
            -- Weapon: Burning Dual Blades --
            ---------------------------------
            -- Burning Dual Blades
            bladeswarn = {
                varname = format(L.alert["%s Warning"],SN[90738]),
                type = "simple",
                text = format(L.alert["He chose %s!"],SN[90738]),
                time = 1,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[90738],
            },
            bladesduration = {
                varname = format(L.alert["%s Duration"],SN[90738]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[90738]),
                time = 30,
                flashtime = 10,
                color1 = "ORANGE",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[90738],
            },
            -- Burning Flames
            flameswarn = {
                varname = format(L.alert["%s Warning"],SN[90764]),
                type = "simple",
                text = "<flamestext>",
                time = 1,
                stacks = 5,
                color1 = "ORANGE",
                sound = "ALERT11",
                icon = ST[90764],
                throttle = 3,
            },
            -- Disorienting Roar
            roarwarn = {
                varname = format(L.alert["%s Warning"],SN[90737]),
                type = "simple",
                text = format(L.alert["%s"],SN[90737]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[90737],
                throttle = 10,
            },
            ---------------------------
            -- Weapon: The Huge Mace --
            ---------------------------
            -- Encumbered
            macewarn = {
                varname = format(L.alert["%s Warning"],SN[75007]),
                type = "simple",
                text = format(L.alert["He chose %s!"],"The Mace"),
                time = 1,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[75007],
            },
            maceduration = {
                varname = format(L.alert["%s Duration"],SN[75007]),
                type = "dropdown",
                text = format(L.alert["%s"],SN[75007]),
                time = 30,
                flashtime = 10,
                color1 = "BROWN",
                color2 = "PEACH",
                sound = "MINORWARNING",
                icon = ST[75007],
            },
            -- Slam
            slamcd = {
                varname = format(L.alert["%s Warning"],SN[90756]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[90756]),
                time = "<slamcd>",
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[90756],
            },
            slamwarn = {
                varname = format(L.alert["%s Warning"],SN[90756]),
                type = "simple",
                text = "<slamtext>",
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[90756],
            },
            -- Lava Patch
            lavaselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[90754]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[90754],L.alert["YOU"]),
                time = 1,
                emphasizewarning = {1,0.5},
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[90754],
                throttle = 2,
            },
            
        },
        events = {
            -- Mighty Stomp
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 74984,
                execute = {
                    {
                        "alert","stompwarn",
                        "quash","stompcd",
                        "alert","stompcd",
                    },
                },
            },
            -- Cave In
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 74987,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","caveinselfwarn",
                    },
                },
            },
			-- Pick Weapon
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 75000,
                execute = {
                    {
                        "quash","pickweaponcd",
                        "alert","pickweaponcd",
                        "alert","pickweaponwarn",
                        "alert","pickweaponcasting"
                    },
                },
            },
            -- Personal Phalanx 
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 74908,
                execute = {
                    {
                        "alert","phalanxwarn",
                        "alert","phalanxduration",
                    },
                },
            },
            -- Burning Dual Blades
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 90738,
                execute = {
                    {
                        "alert","bladeswarn",
                        "alert","bladesduration",
                        "quash","stompcd",
                        "alert","stompcd",
                    },
                },
            },
            -- Burning Flames
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED_DOSE",
                spellname = 90764,
                execute = {
                    {
                        "expect",{"#11#",">=","&stacks|flameswarn&"},
                        "invoke",{
                            {
                                "expect",{"#4#","==","&playerguid&"},
                                "set",{flamestext = format(L.alert["%s (%s) on %s!"],SN[90764],"#11#",L.alert["YOU"])},
                            },
                            {
                                "expect",{"#4#","~=","&playerguid&"},
                                "set",{flamestext = format(L.alert["%s (%s) on <%s>!"],SN[90764],"#11#","#5#")},
                            },
                        },
                        "alert","flameswarn",
                    },
                },
            },
            -- Disorienting Roar
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 90737,
                execute = {
                    {
                        "alert","roarwarn",
                    },
                },
            },
            -- Encumbered
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 75007,
                execute = {
                    {
                        "alert","macewarn",
                        "alert","maceduration",
                        "quash","stompcd",
                        "alert","stompcd",
                        "quash","stompcd",
                        "alert","slamcd",
                    },
                },
            }, 
            -- Slam
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 90756,
                execute = {
                    {
                        "quash","slamcd",
                        "alert","slamcd",
                        "set",{slamtext = format(L.alert["%s on <%s>"],SN[90756],"#5#")},
                        "alert","slamwarn",
                    },
                },
            },
            -- Lava Patch
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 90754,
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
-- DRAHGA SHADOWBURNER
---------------------------------

do
    local data = {
        version = 4,
        key = "drahga",
        zone = L.zone["Grim Batol"],
        category = L.zone["Grim Batol"],
        name = L.npc_grimbatol["Drahga Shadowburner"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Drahga Shadowburner.blp",
        icon2 = "Interface\\EncounterJournal\\UI-EJ-BOSS-Valiona Dungeon.blp",
        triggers = {
            scan = {
                40319, -- Drahga Shadowburner
            },
        },
        onactivate = {
            tracing = {
                40319,
            },
            phasemarkers = {
                {
                    {0.3, "Valiona called","At 30% HP, Drahga calls Valiona to join the fight."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 40319,
        },
        userdata = {
            --spiritcd = {8,20, loop = false, type = "series"},
            seepingcd = {18,20, loop = false, type = "series"},
            flamecd = {7, 20, loop = false, type = "series"},
            phase = 0,
            phase2warned = "no",
            phase3warned = "no",
            valionaGUID = "none",
        },
        onstart = {
            {
                "set",{phase = 1},
                "alert",{"spiritcd",time = 2},
                "repeattimer",{"checkhp",1},
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"phasesoonwarn","phasewarn","spiritcd","spiritwarn","fixateselfwarn","valionaincomming"},
            },
            {
                phase = 2,
                alerts = {"valflamecd","valflamewarn","flamecd","flamewarn","flameduration","seepingcd","seepingwarn"},
            },
        },
        
        alerts = {
            -- Flaming Spirit
            spiritcd = {
                varname = format(L.alert["%s CD"],"Flaming Spirit"),
                type = "dropdown",
                text = format(L.alert["New %s"],"Flaming Spirit"),
                time = 20,
                time2 = 8,
                time3 = 19,
                --time = "<spiritcd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[2894],
            },
            -- Flaming Spirit Spawning
            spiritwarn = {
                varname = format(L.alert["%s Warning"],"Flaming Spirit"),
                type = "centerpopup",
                text = format(L.alert["New: %s"],"Flaming Spirit"),
                time = 5.1,
                color1 = "ORANGE",
                sound = "ALERT7",
                icon = ST[8985],
            },
            -- Flaming Spirit Fixate
            fixateselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[82850]),
                type = "simple",
                text = format(L.alert["%s on %s - RUN!"],SN[82850],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "RUNAWAY",
                icon = ST[82850],
                throttle = 2,
                emphasizewarning = true,
            },
            
            -- Phase transition
            phasewarn = {
                varname = format(L.alert["Phase Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"<phase>"),
                time = 3,
                color1 = "TURQUOISE",
                icon = ST[11242],
                sound = "MINORWARNING",
            },
            -- Phase 2 soon
            phasesoonwarn = {
                varname = format(L.alert["Phase Transition soon Warning"]),
                type = "simple",
                text = L.alert["Phase Transition soon"],
                time = 1,
                color1 = "TURQUOISE",
                icon = ST[11242],
                sound = "MINORWARNING",
            },
            -- Phase 2 countdown
            valionaincomming = {
                varname = format(L.alert["Valiona incoming Warning"]),
                type = "dropdown",
                text = format(L.alert["%s"],"Valiona incoming"),
                time = 18,
                flashtime = 10,
                color1 = "MAGENTA",
                color2 = "TEAL",
                icon = ST[39255],
                sound = "ALERT2",
            },
            -- Devouring Flame
            flamecd = {
                varname = format(L.alert["%s CD"],SN[86840]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[86840]),
                time = "<flamecd>",
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "PINK",
                sound = "MINORWARNING",
                icon = ST[86840],
            },
            flamewarn = {
                varname = format(L.alert["%s Warning"],SN[86840]),
                type = "centerpopup",
                text = format(L.alert["Charging up %s"],SN[86840]),
                time = 2.5,
                color1 = "PINK",
                sound = "BEWARE",
                icon = ST[86840],
            },
            -- Valiona's Flame
            valflamecd = {
                varname = format(L.alert["%s CD"],SN[75321]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[75321]),
                time = "<flamecd>",
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "PINK",
                sound = "MINORWARNING",
                icon = ST[75321],
            },
            valflamewarn = {
                varname = format(L.alert["%s Warning"],SN[75321]),
                type = "centerpopup",
                text = format(L.alert["Charging up %s"],SN[75321]),
                time = 2.5,
                color1 = "PINK",
                sound = "BEWARE",
                icon = ST[75321],
            },
            flameduration = {
                varname = format(L.alert["%s Duration"],SN[86840]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[86840]),
                time = 5,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[86840],
                fillDirection = "DEPLETE",
            },
            -- Seeping Twilight
            seepingcd = {
                varname = format(L.alert["%s CD"],SN[90964]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[90964]),
                time = "<seepingcd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[90966],
            },
            seepingwarn = {
                varname = format(L.alert["%s Warning"],SN[90964]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[90964],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[90966],
                throttle = 3,
            },            
        },
        timers = {
            checkhp = {
				{
					"expect",{"&gethp|boss1&","<","45"},
					"expect",{"<phase2warned>","==","no"},
                    "set",{phase2warned = "yes"},
                    "alert","phasesoonwarn",
				},
                {
                    "expect",{"<valionaGUID>","~=","none"},
                    "expect",{"&getguidhp|<valionaGUID>&","<","25"},
					"expect",{"<phase3warned>","==","no"},
                    "set",{phase3warned = "yes"},
                    "alert","phasesoonwarn",
                },
                {
                    "expect",{"<phase3warned>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
            phase2start = {
                {
                    -- Phase setup
                    "set",{phase = 2},
                    "alert","phasewarn",
                    "addphasemarker",{1, 1, 0.2, "Valiona leaves","At 20% of her HP, Valiona leaves the fight."},
                    
                    -- Flaming Spirit
                    "alert","seepingcd",
                },
                {
                    -- Valiona's Flame
                    "expect",{"&difficulty&","==","1"},
                    "alert","valflamecd",
                },
                {
                    -- Devouring Flame
                    "expect",{"&difficulty&","==","2"},
                    "alert","flamecd",
                },
            },
            fixatetimer = {
                {
                    "expect",{"&playerdebuff|Flaming Fixate&","==","true"},
                    "alert","fixateselfwarn",
                },
            },
            flametimer = {
                {
                    "alert",{"spiritcd",time = 3},
                    "canceltimer","flametimer",
                    "scheduletimer",{"flametimer", 20},
                },
            },
        },
        events = {
            {
                type = "event",
                event = "YELL",
                execute = {
                    -- Phase 2 trigger
                    {
                        "expect",{"#1#","find",L.chat_grimbatol["^Dragon"]},
                        "quash","spiritcd",
                        "alert","valionaincomming",
                        "scheduletimer",{"phase2start",18},
                        "tracing",{40320},
                        "clearphasemarkers",{1},
                    },
                    -- Phase 3 trigger
                    {
                        "expect",{"#1#","find",L.chat_grimbatol["^I will not die"]},
                        "set",{phase = 3},
                        "alert","phasewarn",
                        "tracing",{40319},
                        "clearphasemarkers",{1},
                    },
                },
            },
            -- Ground Siege
            {
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 90249,
				execute = {
					{
						"quash","siegecd",
						"alert","siegecd",
						"alert","siegewarn",
					},
				},
			},
            -- Devouring Flames
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 86840,
                execute = {
                    {
                        "quash","flamecd",
                        "alert","flamecd",
                        "alert","flamewarn",
                    },
                    {
                        "expect",{"<valionaGUID>","==","none"},
                        "set",{valionaGUID = "#1#"},
                    },
                },
            },
            -- Valiona's Flame
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 75321,
                execute = {
                    {
                        "quash","valflamecd",
                        "alert","valflamecd",
                        "alert","valflamewarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 86840,
                execute = {
                    {
                        "quash","flamewarn",
                        "alert","flameduration",
                    },
                },
            },
            -- Seeping Twilight
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 90966,
                execute = {
                    {
                        "quash","seepingcd",
                        "alert","seepingcd",
                    },
                },
            },
            -- Seeping Twilight (damage)
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 90964,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","seepingwarn",
                    },
                },
            },
            -- Invocation of Flame
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[75218]},
                        "expect",{"#1#","==","boss1"},
                        "quash","spiritcd",
                        "alert","spiritwarn",
                        "alert","spiritcd",
                        "scheduletimer",{"fixatetimer", 5.2},
                        "canceltimer","flametimer",
                        "scheduletimer",{"flametimer", 21},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ERUDAX
---------------------------------

do
    local data = {
        version = 3,
        key = "erudax",
        zone = L.zone["Grim Batol"],
        category = L.zone["Grim Batol"],
        name = L.npc_grimbatol["Erudax"],
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Erudax.blp",
        triggers = {
            scan = {
                40484, -- Erudax
            },
        },
        onactivate = {
            tracing = {
                40484,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 40484,
        },
        userdata = {
            galecd = {15, 34, loop = false, type = "series"},
            bindingcd = {14, 0, loop = true, type = "series"},
            
            feebletext = "",
            bindingunit = "",
            corruptortext = "Faceless Corruptor",
            
            feebletime = 3,
            
            pullbinding = "yes",
            achievementfailed = "no",
            
            binding_units = {type = "container", wipein = 3},
        },
        onstart = {
            {
                "alert",{"bindingcd",time = 2},
                "alert","galecd",
            },
            {
                "expect",{"&difficulty&","==","2"},
                "set",{
                    feebletime = 3,
                    corruptortext = "Faceless Corruptors",
                },
            },
        },
        
        announces = {
            achievementfailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5298,
                msg = format(L.alert["<DXE> %s: Achievement failed!"],AL[5298]),
                throttle = true,
            },
        },
        raidicons = {
            bindingmark = {
                varname = format("%s {%s}",SN[91081],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 5,
                unit = "<bindingunit>",
                reset = 10,
                icon = 1,
                texture = ST[91081],
            },
        },
        ordering = {
            alerts = {"feeblewarn","bindingcd","bindingcast","bindingaffectedwarn","galecd","galewarn","galeduration","summoncorruptorwarn"},
        },
        
        alerts = {
            -- Feeble Body
            feeblewarn = {
                varname = format(L.alert["%s Warning"],SN[91092]),
                type = "centerpopup",
                text = "<feebletext>",
                time = "<feebletime>",
                color1 = "LIGHTBLUE",
                color2 = "INDIGO",
                sound = "ALERT8",
                icon = ST[91092],
            },
            -- Binding Shadows
            bindingcd = {
                varname = format(L.alert["%s CD"],SN[91081]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91081]),
                time = "<bindingcd>",
                time2 = {8,0, loop = false, type = "series"},
                time3 = 15,
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[91081],
            },
            bindingcast = {
                varname = format(L.alert["%s Warning"],SN[91081]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[91081]),
                time = 1.5,
                color1 = "MAGENTA",
                sound = "ALERT2",
                icon = ST[91081],
            },
            bindingaffectedwarn = {
                varname = format(L.alert["%s Affected Warning"],SN[91081]),
                type = "simple",
                text = format(L.alert["%s on %s"],SN[91081],"&list|binding_units&"),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[91081],
            },
            -- Shadow Gale
            galecd = {
                varname = format(L.alert["%s CD"],SN[91086]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91086]),
                time = "<galecd>",
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "MAGENTA",
                sound = "MINORWARNING",
                icon = ST[91086],
            },
            galewarn = {
                varname = format(L.alert["%s Warning"],SN[91086]),
                type = "centerpopup",
                text = format(L.alert["Charging up %s"],SN[91086]),
                time = 5,
                color1 = "MAGENTA",
                color2 = "RED",
                sound = "BEWARE",
                icon = ST[91086],
            },
            galeduration = {
                varname = format(L.alert["%s Duration"],SN[91086]),
                type = "centerpopup",
                fillDirection = "DEPLETE",
                text = format(L.alert["%s"],SN[91086]),
                time = 10,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "None",
                icon = ST[91086],
            },
            -- Summon Faceless Corruptor
            summoncorruptorwarn = {
                varname = format(L.alert["%s Warning"],SN[75704]),
                type = "simple",
                text = format(L.alert["New: %s"],"<corruptortext>"),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT9",
                icon = ST[75640],
            },
            
        },
        timers = {
            bindingcasttimer = {
                {
                    "set",{bindingunit = "&unitname|boss1target&"},
                    "raidicon","bindingmark",
                },
            },
            binding_timer = {
                {
                    "expect",{"&listsize|binding_units&",">","0"},
                    "alert","bindingaffectedwarn",
                },
            },
            galedurationtimer = {
                {
                    "alert","galeduration",
                },
            },
        },
        events = {
			-- Feeble Body
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 91092,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{feebletext = format(L.alert["%s on %s"],SN[91092],L.alert["YOU"])},
                        "alert","feeblewarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{feebletext = format(L.alert["%s on <%s>"],SN[91092],"#5#")},
                        "alert","feeblewarn",
                    },
                },
            },
            -- Binding Shadows
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91081,
                execute = {
                    {
                        "quash","bindingcd",
                        "alert","bindingcast",
                        "scheduletimer",{"bindingcasttimer", 0.2},
                    },
                    {
                        "expect",{"<pullbinding>","==","no"},
                        "alert","bindingcd",
                    },
                    {
                        "expect",{"<pullbinding>","==","yes"},
                        "set",{pullbinding = "no"},
                        "alert",{"bindingcd",time = 2},
                    },
                },
            },
            -- Binding Shadows (affected)
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 91081,
                execute = {
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "insert",{"binding_units","#5#"},
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "insert",{"binding_units",L.alert["YOU"]},
                    },
                    {
                        "expect",{"&listsize|binding_units&","==","1"},
                        "scheduletimer",{"binding_timer",1},
                    },
                },
            },
            -- Shadow Gale
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91086,
                execute = {
                    {
                        "quash","galecd",
                        "alert","galecd",
                        "alert","galewarn",
                        "scheduletimer",{"galedurationtimer", 5},
                        "alert",{"bindingcd",time = 3},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[75664]},
                        "expect",{"#1#","find","boss"},
                        "canceltimer","galedurationtimer",
                        "quash","galewarn",
                        "quash","galeduration",
                    },
                },
            },
            -- Summon Faceless Corruptor
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[75704]},
                        "expect",{"#1#","==","boss1"},
                        "alert","summoncorruptorwarn",
                    },
                },
            },
            
            -- Achievement:  Don't Need to Break Eggs to Make an Omelet
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 91049,
                execute = {
                    {
                        "expect",{"&difficulty&","==","2"},
                        "expect",{"<achievementfailed>","==","no"},
                        "set",{achievementfailed = "yes"},
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
        version = 2,
        key = "grimbatoltrash",
        zone = L.zone["Grim Batol"],
        category = L.zone["Grim Batol"],
        name = "Trash",
        triggers = {
            scan = {
                39381, -- Crimsonborne Guardian
                39854, -- Azureborne Guardian
                39855, -- Azureborne Seer
                39405, -- Crimsonborne Seer
                39956, -- Twilight Enforcer
                39954, -- Twilight Shadow Weaver
                40953, -- Khaaphom
                39909, -- Azureborne Warlord
                39626, -- Crimsonborne Warlord
                40290, -- Crimsonborne Seer
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {
            -- Texts
            shieldtext = "",
            visagetext = "",
        },
        
        raidicons = {
            shieldmark = {
                varname = format("%s {%s-%s}",SN[90308],"ENEMY_BUFF","Crimsonborne Seer's"),
                type = "ENEMY",
                persist = 5,
                unit = "#4#",
                reset = 6,
                icon = 3,
                texture = ST[90308],
            },
            visagemark = {
                varname = format("%s {%s-%s}",SN[90695],"ENEMY_CAST","Azureborne Warlord's"),
                type = "ENEMY",
                persist = 3,
                unit = "#1#",
                reset = 4,
                icon = 2,
                texture = ST[90695],
            },
        },
        phrasecolors = {
            {"Azureborne [^%s]+","GOLD"},
            {"Crimsonborne [^%s]+","GOLD"},
            {"Twilight Shadow Weaver+","GOLD"},
            {"Twilight Enforcer+","GOLD"},
            {"Khaaphom","GOLD"},
            {"starts channeling","WHITE"},
        },
        
        alerts = {
            -- Blazing Twilight Shield
            shieldwarn = {
                varname = format(L.alert["%s Warning"],SN[90308]),
                type = "centerpopup",
                warningtext = "<shieldtext>",
                text = format(L.alert["%s"],SN[90308]),
                time = 6,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[90308],
            },
            shieldcd = {
                varname = format(L.alert["%s CD"],SN[90308]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[90308]),
                time = 20,
                flashtime = 5,
                color1 = "PURPLE",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[90308],
                tag = "#1#",
            },
            -- Conjure Twisted Visage
            visagewarn = {
                varname = format(L.alert["%s Warning"],SN[90695]),
                type = "centerpopup",
                warningtext = "<visagetext>",
                text = format(L.alert["%s"],SN[90695]),
                time = 4,
                flashtime = 4,
                color1 = "CYAN",
                color2 = "MAGENTA",
                sound = "ALERT2",
                icon = ST[90695],
                tag = "#1#",
            },
            visagecd = {
                varname = format(L.alert["%s CD"],SN[90695]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[90695]),
                time = 16,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[90695],
                tag = "#1#",
            },
        },
        events = {
			-- Blazing Twilight Shield
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 90308,
                execute = {
                    {
                        "set",{shieldtext = format(L.alert["%s on %s"],SN[90308],"#5#")},
                        "alert","shieldwarn",
                        "alert","shieldcd",
                        "raidicon","shieldmark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 90308,
                execute = {
                    {
                        "expect",{"&difficulty&","==","1"},
                        "set",{shieldtext = format(L.alert["%s on %s"],SN[90308],"#5#")},
                        "alert","shieldwarn",
                        "alert","shieldcd",
                        "raidicon","shieldmark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "PARTY_KILL",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39405"},
                        "quash",{"shieldcd","#4#"},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 90308,
                execute = {
                    {
                        "quash","shieldwarn",
                        "removeraidicon","shieldmark",
                    },
                },
            },
            -- Conjure Twisted Visage
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 90695,
                execute = {
                    {
                        "set",{visagetext = format(L.alert["%s: %s - INTERRUPT!"],"#2#",SN[90695])},
                        "alert","visagewarn",
                        "alert","visagecd",
                        "raidicon","visagemark"
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 90695,
                execute = {
                    {
                        "quash","visagewarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39909"},
                        "quash",{"visagewarn","#4#"},
                        "quash",{"visagecd","#4#"},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "PARTY_KILL",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39909"},
                        "quash",{"visagewarn","#4#"},
                        "quash",{"visagecd","#4#"},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end
