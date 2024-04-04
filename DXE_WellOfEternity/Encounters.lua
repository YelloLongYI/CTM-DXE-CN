local L,SN,ST,SL,AL,AT,AN,TI = DXE.L,DXE.SN,DXE.ST,DXE.SL,DXE.AL,DXE.AT,DXE.AN,DXE.TI

---------------------------------
-- PEROTH'ARN
---------------------------------

do
    local data = {
        version = 1,
        key = "perotharn",
        zone = L.zone["Well of Eternity"],
        category = L.zone["Well of Eternity"],
        name = "Peroth'arn",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Perotharn.blp",
        triggers = {
            scan = {
                55085, -- Peroth'arn
            },
        },
        onactivate = {
            tracing = {
                55085,
            },
            phasemarkers = {
                {
                    {0.60, "Drain Essence", "At 60% HP, Peroth’arn stuns all enemies and inflicts Shadow damage every second for 4 sec."},
                    {0.20, "Endless Frenzy", "At 20% HP, Peroth’arn frenzies and increases his damage by 25%."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 55085,
        },
        userdata = {
            flamescast = "no",
            lazyeyetext = "",
            
            flamestext = "",
            decaytext = "",
            
            flamesunit = "",
            decayunit = "",
            
            essencewarned = "no",
            frenzywarned = "no",
            intermission = "no",
        },
        onstart = {
            {
                "alert",{"flamescd",time = 2},
                "alert",{"decaycd",time = 2},
                "repeattimer",{"checkhp", 1},
            },
        },
        announces = {
            lazyeyefailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 6127,
                msg = "<lazyeyetext>",
                throttle = true,
            },
        },
        raidicons = {
            flamesmark = {
                varname = format("%s {%s}",SN[108141],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 5,
                unit = "<flamesunit>",
                reset = 10,
                icon = 1,
                texture = ST[108141],
            },
            decaymark = {
                varname = format("%s {%s}",SN[105544],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                persist = 5,
                unit = "#5#",
                reset = 11,
                icon = 2,
                texture = ST[105544],
            },
        },
        windows = {
            proxwindow = true,
            proxrange = 25,
            proxoverride = true,
            nodistancecheck = true
        },
        radars = {
            flamesradar = {
                varname = SN[108141],
                type = "circle",
                player = "<flamesunit>",
                fixed = true,
                range = 5.5,
                mode = "avoid",
                persist = 33,
                color = "GREEN",
                icon = ST[108141],
            },
        },
        ordering = {
            alerts = {"flamescd","flameswarn","flamesselfwarn","decaycd","decaywarn","decayduration","essencesoonwarn","essencewarn","hideduration","enfeebledwarn","quickeningwarn","frenzysoonwarn","frenzywarn"},
        },
        
        alerts = {
            -- Fel Flames
            flamescd = {
                varname = format(L.alert["%s CD"],SN[108141]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[108141]),
                time = 8,
                time2 = 5,
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "GREEN",
                sound = "None",
                icon = ST[108141],
            },
            flameswarn = {
                varname = format(L.alert["%s Warning"],SN[108141]),
                type = "simple",
                text = "<flamestext>",
                time = 1,
                color1 = "LIGHTGREEN",
                sound = "ALERT7",
                icon = ST[108141],
            },
            flamesselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[108141]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[108141],L.alert["YOU"]),
                time = 1,
                color1 = "TEAL",
                sound = "ALERT10",
                icon = ST[108141],
                throttle = 2,
                emphasizewarning = true,
            },
            
            -- Fel Decay
            decaycd = {
                varname = format(L.alert["%s CD"],SN[105544]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[105544]),
                time = 17,
                time2 = 8,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[105544],
            },
            decaywarn = {
                varname = format(L.alert["%s Warning"],SN[105544]),
                type = "simple",
                text = "<decaytext>",
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[105544],
            },
            decayduration = {
                varname = format(L.alert["%s Duration"],SN[105544]),
                type = "centerpopup",
                text = "<decaytext>",
                time = 10,
                color1 = "ORANGE",
                sound = "None",
                icon = ST[105544],
            },
            -- Fel Quickening
            quickeningwarn = {
                varname = format(L.alert["%s Warning"],SN[105526]),
                type = "centerpopup",
                warningtext = format(L.alert["%s"],SN[105526]),
                text = format(L.alert["%s fades"],SN[105526]),
                time = 15,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "BEWARE",
                icon = ST[105526],
            },
            -- Enfeebled
            enfeebledwarn = {
                varname = format(L.alert["%s Warning"],SN[105442]),
                type = "centerpopup",
                warningtext = format(L.alert["%s"],SN[105442]),
                text = format(L.alert["%s fades"],SN[105442]),
                time = 15,
                color1 = "GOLD",
                color2 = "INDIGO",
                sound = "BURST",
                icon = ST[105442],
            },
            -- Drain Essence
            essencesoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[104905]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[104905]),
                time = 1,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[104905],
            },
            essencewarn = {
                varname = format(L.alert["%s Warning"],SN[104905]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[104905]),
                time = 4,
                color1 = "YELLOW",
                sound = "ALERT9",
                icon = ST[104905],
            },
            -- Endless Frenzy
            frenzysoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[105521]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[105521]),
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[105521],
            },
            frenzywarn = {
                varname = format(L.alert["%s Warning"],SN[105521]),
                type = "simple",
                text = format(L.alert["%s"],SN[105521]),
                time = 1,
                color1 = "GOLD",
                sound = "BEWARE",
                icon = ST[105521],
            },
            -- Hide from Eyes
            hideduration = {
                varname = format(L.alert["%s Duration"],"Hide-and-seek"),
                type = "dropdown",
                text = format(L.alert["%s"],"Hide-and-seek"),
                time = 40,
                flashtime = 5,
                color1 = "TEAL",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[6920],
                audiocd = true,
            },
        },
        timers = {
            flamestimer = {
                {
                    "expect",{"<flamescast>","==","yes"},
                    "invoke",{
                        {
                            "expect",{"&unitguid|boss1target&","==","&playerguid&"},
                            "set",{flamestext = format(L.alert["%s on <%s>"],SN[108141],L.alert["YOU"])},
                            "alert","flameswarn",
                        },
                        {
                            "expect",{"&unitguid|boss1target&","~=","&playerguid&"},
                            "set",{flamestext = format(L.alert["%s on <%s>"],SN[108141],"&unitname|boss1target&")},
                            "alert","flameswarn",
                        },
                    },
                    "set",{
                        flamesunit = "&unitname|boss1target&",
                        flamescast = "no",
                    },
                    "raidicon","flamesmark",
                },
            },
            checkhp = {
				{
					"expect",{"&gethp|boss1&","<","70"},
                    "expect",{"<essencewarned>","==","no"},
                    "set",{essencewarned = "yes"},
					"alert","essencesoonwarn",
                    "canceltimer","checkhp",
				},
				{
                    "expect",{"&gethp|boss1&","<","30"},
                    "alert","frenzysoonwarn",
                    "canceltimer","checkhp",
				},
            },
            hidetimer = {
                {
                    "alert","hideduration",
                    "set",{intermission = "no"},
                },
            },
        },
        events = {
			-- Fel Flames
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 108141,
                execute = {
                    {
                        "expect",{"<intermission>","==","no"},
                        "quash","flamescd",
                        "alert","flamescd",
                        "set",{flamescast = "yes"},
                        "scheduletimer",{"flamestimer", 0.3},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_TARGET",
                execute = {
                    {
                        "expect",{"#1#","==","boss1"},
                        "expect",{"<flamescast>","==","yes"},
                        "invoke",{
                            {
                                "expect",{"&unitguid|boss1target&","==","&playerguid&"},
                                "set",{flamestext = format(L.alert["%s on <%s>"],SN[108141],L.alert["YOU"])},
                                "alert","flameswarn",
                            },
                            {
                                "expect",{"&unitguid|boss1target&","~=","&playerguid&"},
                                "set",{flamestext = format(L.alert["%s on <%s>"],SN[108141],"&unitname|boss1target&")},
                                "alert","flameswarn",
                            },
                            {
                                "set",{flamesunit = "&unitname|boss1target&"},
                                "raidicon","flamesmark",
                            },
                        },
                        "set",{flamescast = "no"},
                        "canceltimer","flamestimer",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[108141]},
                        "expect",{"#1#","find","boss"},
                        "radar","flamesradar",
                    },
                },
            },
            
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 108217,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","flamesselfwarn",
                    },
                },
            },
            
            -- Fel Decay
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 105544,
                execute = {
                    {
                        "quash","decaycd",
                        "alert","decaycd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 105544,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{decaytext = format(L.alert["%s on <%s>"],SN[105544],L.alert["YOU"])},
                        "alert","decaywarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{decaytext = format(L.alert["%s on <%s>"],SN[105544],"#5#")},
                        "alert","decaywarn",
                    },
                    {
                        "alert","decayduration",
                        "raidicon","decaymark",
                    },
                },
            },
            -- Fel Quickening
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 105526,
                execute = {
                    {
                        "quash","hideduration",
                        "alert","quickeningwarn",
                        "repeattimer",{"checkhp", 1},
                    },
                },
            },
            -- Lazy Eye (achievement)
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellid = 105493,
                execute = {
                    {
                        "expect",{"&itemenabled|lazyeyefailed&","==","true"},
                        "set",{lazyeyetext = format(L.alert["<DXE> %s: Achievement failed (%s)."],AL[6127],"#5#")},
                        "announce","lazyeyefailed",
                    },
                },
            },
            
            -- Enfeebled
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 105442,
                execute = {
                    {
                        "quash","hideduration",
                        "alert","enfeebledwarn",
                        "repeattimer",{"checkhp", 1},
                    },
                },
            },
            -- Drain Essence
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[104905]},
                        "expect",{"#1#","==","boss1"},
                        "quash","flamescd",
                        "quash","decaycd",
                        "set",{intermission = "yes"},
                        "alert","essencewarn",
                        "removeradar","flamesradar",
                    },
                },
            },
            -- Endless Frenzy
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 105521,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","55085"},
                        "alert","frenzywarn",
                    },
                },
            },
            -- Hide-and-seek
            {
                type = "event",
                event = "EMOTE",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_wellofeternity["vanishes into the shadows"]},
                        "scheduletimer",{"hidetimer", 7},
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- QUEEN AZSHARA
---------------------------------

do
    local data = {
        version = 1,
        key = "queenazshara",
        zone = L.zone["Well of Eternity"],
        category = L.zone["Well of Eternity"],
        name = "Queen Azshara",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-QueenAzshara.blp",
        advanced = {
            delayWipe = 1,
        },
        triggers = {
            scan = {
                54853, -- Queen Azshara
            },
        },
        onactivate = {
            tracing = {
            },
            counters = {"wavescounter"},
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = L.chat_wellofeternity["Enough! As much as I adore playing hostess, I have more pressing matters to attend to."],
        },
        userdata = {
            wave1mage1guid = "nil",
            wave1mage2guid = "nil",
            wave2mage1guid = "nil",
            wave2mage2guid = "nil",
            
            magusGUID = "",
            sourceunit = "",
            targetID = "",
            handunit = "",
            magicount = 6,
            magitext = "",
            
            handcount = 0,
        },
        onstart = {
            {
                "alert","obediencecd",
                "alert",{"servantcd",time = 2},               
                "alert",{"callmagicd",time = 2},
            },
        },
        filters = {
            bossemotes = {
                obedienceemote = {
                    name = "Total Obedience",
                    pattern = "begins to transform everybody into puppets",
                    hasIcon = false,
                    hide = true,
                    texture = ST[59752],
                },
            },
        },
        phrasecolors = {
            {"%(.+%)","YELLOW"},
            {"Magi left","WHITE"},
            {"Magus left","WHITE"},
        },
        announces = {
            handsay = {
                type = "SAY",
                subtype = "self",
                spell = 102334,
                msg = format(L.alert["%s on ME!"],"Hand of the Queen"),
            },
            
        },
        raidicons = {
            wave1mage1mark = {
                varname = format("%s {%s}","1st mage (Wave 1)","NPC_ENEMY"),
                type = "ENEMY",
                persist = 15,
                unit = "<wave1mage1guid>",
                icon = 1,
                texture = ST[66],
            },
            wave1mage2mark = {
                varname = format("%s {%s}","2nd mage (Wave 1)","NPC_ENEMY"),
                type = "ENEMY",
                persist = 15,
                unit = "<wave1mage2guid>",
                icon = 2,
                texture = ST[66],
            },
            wave2mage1mark = {
                varname = format("%s {%s}","3rd mage (Wave 2)","NPC_ENEMY"),
                type = "ENEMY",
                persist = 15,
                unit = "<wave2mage1guid>",
                icon = 3,
                texture = ST[66],
            },
            wave2mage2mark = {
                varname = format("%s {%s}","4th mage (Wave 2)","NPC_ENEMY"),
                type = "ENEMY",
                persist = 15,
                unit = "<wave2mage2guid>",
                icon = 4,
                texture = ST[66],
            },
            handmark = {
                varname = format("%s {%s}",SN[102334],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                persist = 15,
                unit = "<handunit>",
                reset = 15,
                icon = 7,
                texture = ST[102334],
            },
        },
        windows = {
            proxwindow = true,
            proxrange = 10,
            proxoverride = true,
        },
        arrows = {
            handarrow = {
                varname = format("%s","Hand of the Queen"),
                unit = "<handunit>",
                persist = 30,
                action = "TOWARD",
                msg = L.alert["Kill the hand!"],
                spell = SN[102334],
                sound = "None",
                cancelrange = 5,
                range1 = 10,
                range2 = 20,
                range3 = 30,
                texture = ST[102334],
            }
        },
        counters = {
            wavescounter = {
                variable = "magicount",
                label = "Magi to defeat",
                value = 6,
                minimum = 0,
                maximum = 6,
            },
        },
        ordering = {
            alerts = {"callmagicd","callmagiwarn","magiwarn","servantcd","servantwarn","coldflameselfwarn","obediencecd","obediencewarn"},
        },
        
        alerts = {
            -- Call Magi
            callmagicd = {
                varname = format(L.alert["%s CD"],"Call Magi"),
                type = "dropdown",
                text = format(L.alert["New %s"],"Magi volunteers"),
                time = 7, -- next wave
                time2 = 17, -- Wave 1 CD
                time3 = 36, -- Wave 2 CD
                time4 = 36, -- Wave 3 CD
                flashtime = 8,
                color1 = "TURQUOISE",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[66],
                sticky = true,
            },
            callmagiwarn = {
                varname = format(L.alert["%s Warning"],"Call Magi"),
                type = "simple",
                text = "<callmagitext>",
                time = 1,
                color1 = "CYAN",
                sound = "ALERT9",
                icon = ST[66],
            },
            -- Total Obedience
            obediencecd = {
                varname = format(L.alert["%s CD"],SN[103241]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[103241]),
                time = 36,
                flashtime = 5,
                color1 = "MAGENTA",
                color2 = "PURPLE",
                sound = "MINORWARNING",
                icon = ST[59752],
            },
            obediencewarn = {
                varname = format(L.alert["%s Warning"],SN[103241]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[103241]),
                time = 10,
                color1 = "PINK",
                sound = "BEWARE",
                icon = ST[59752],
            },
            -- Servant of the Queen
            servantcd = {
                varname = format(L.alert["%s CD"],SN[102334]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[102334]),
                time = 26,
                time2 = 24,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "WHITE",
                sound = "MINORWARNING",
                icon = ST[102334],
                behavior = "overwrite",
            },
            servantwarn = {
                varname = format(L.alert["%s Warning"],SN[102334]),
                type = "simple",
                text = format(L.alert["%s on <%s>"],"Hand of the Queen","<servantunit>"),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[102334],
                throttle = 2,
            },
            -- Magi left
            magiwarn = {
                varname = format(L.alert["%s Warning"],"Magi Left"),
                type = "simple",
                text = "<magitext>",
                time = 1,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[1953],
            },
            
            -- Coldflame
            coldflameselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[102466]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[102466],L.alert["YOU"]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT10",
                icon = ST[102466],
                throttle = 2,
                emphasizewarning = true,
            },
            
            
        },
        timers = {
            recordmagus = {
                {
                    "expect",{"<wave1mage1guid>","==","nil"},
                    "set",{wave1mage1guid = "<magusGUID>"},
                    "raidicon","wave1mage1mark",
                },
                {
                    "expect",{"<wave1mage2guid>","==","nil"},
                    "expect",{"<wave1mage1guid>","~=","nil"},
                    "expect",{"<wave1mage1guid>","~=","<magusGUID>"},
                    "set",{wave1mage2guid = "<magusGUID>"},
                    "raidicon","wave1mage2mark",
                },
                {
                    "expect",{"<wave2mage1guid>","==","nil"},
                    "expect",{"<wave1mage1guid>","~=","nil"},
                    "expect",{"<wave1mage1guid>","~=","<magusGUID>"},
                    "expect",{"<wave1mage2guid>","~=","nil"},
                    "expect",{"<wave1mage2guid>","~=","<magusGUID>"},
                    "set",{wave2mage1guid = "<magusGUID>"},
                    "raidicon","wave2mage1mark",
                },
                {
                    "expect",{"<wave2mage2guid>","==","nil"},
                    "expect",{"<wave1mage1guid>","~=","nil"},
                    "expect",{"<wave1mage1guid>","~=","<magusGUID>"},
                    "expect",{"<wave1mage2guid>","~=","nil"},
                    "expect",{"<wave1mage2guid>","~=","<magusGUID>"},
                    "expect",{"<wave2mage1guid>","~=","nil"},
                    "expect",{"<wave2mage1guid>","~=","<magusGUID>"},
                    "set",{wave2mage2guid = "<magusGUID>"},
                    "raidicon","wave2mage2mark",
                },
            },
            handtimer = {
                { -- Hand of the Queen (on player)
                    "set",{handcheckunit = "player"},
                    "run","handcheck",
                },
                { -- Hand of the Queen (on other party members)
                    "forloop",{
                        {"partyIndex",1,4},
                        {
                            "set",{handcheckunit = "party<partyIndex>"},
                            "run","handcheck",
                        },
                    },
                },
            },
        },
        batches = {
            handcheck = {
                {
                    "expect",{"&unitreaction|<handcheckunit>|boss1&","==","4"}, -- neutral
                    "set",{
                        handunit = "&unitname|<handcheckunit>&",
                        handcount = "INCR|1",
                    },
                    "invoke",{
                        {
                            "expect",{"<handcheckunit>","~=","player"},
                            "set",{servantunit = "<handunit>"},
                        },
                        {
                            "expect",{"<handcheckunit>","==","player"},
                            "set",{servantunit = L.alert["YOU"],},
                        },
                    },
                    "raidicon","handmark",
                    "alert","servantwarn",
                    
                    "expect",{"<handcheckunit>","~=","player"},
                    "arrow","handarrow",
                },
            },
        },
        events = {
			-- Total Obedience
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 103241,
                execute = {
                    {
                        "quash","obediencecd",
                        "alert","obediencecd",
                        "alert","obediencewarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[103241]},
                        "expect",{"#1#","find","boss"},
                        "quash","obediencewarn",
                    },
                },
            },
            -- Servant of the Queen
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[102334]},
                        "expect",{"#1#","find","boss"},
                        "quash","servantcd",
                        "alert","servantcd",
                        "scheduletimer",{"handtimer", 0.1},
                    },
                    
                },
            },
            -- Hand of the Queen
            {
                type = "combatevent",
                eventtype = "PARTY_KILL",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","54728"},
                        "set",{handcount = "DECR|1"},
                        "expect",{"<handcount>","==","0"},
                        "removeallarrows",true,
                    },
                },
            },
            -- Call Magi
            {
                type = "event",
                event = "YELL",
                execute = {
                    -- Wave 1 begins
                    {
                        "expect",{"#1#","find",L.chat_wellofeternity["^I pray that the Light of a Thousand Moons"]},
                        "set",{callmagitext = format(L.alert["New: %s (1st out of 3)"],"Magi")},
                        "quash","callmagicd",
                        "alert","callmagiwarn",
                        "alert",{"callmagicd",time = 3},
                    },
                    -- Wave 2 begins
                    {
                        "expect",{"#1#","find",L.chat_wellofeternity["Light of Lights"]},
                        "set",{callmagitext = format(L.alert["New: %s (2nd out of 3)"],"Magi")},
                        "quash","callmagicd",
                        "alert",{"callmagicd",time = 3},
                    },
                    -- Wave 3 begins
                    {
                        "expect",{"#1#","find",L.chat_wellofeternity["^The Flower of Life calls upon me"]},
                        "set",{callmagitext = format(L.alert["New: %s (3rd out of 3)"],"Magi")},
                        "quash","callmagicd",
                        "alert","callmagiwarn",
                    },
                    -- Wave 2 or 3 is called
                    {
                        "expect",{
                            "#1#","find",L.chat_wellofeternity["^I have no time for"],
                            "OR",
                            "#1#","find",L.chat_wellofeternity["^Still these strangers would oppose"],
                            "OR",
                            "#1#","find",L.chat_wellofeternity["^I beseech of you"]},
                        "quash","callmagicd",
                        "alert","callmagicd",
                    },
                },
            },
            -- Big Mage Hunt (looking for Enchanted Magus GUIDs)
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = {102478, 102465, 102265},
                execute = {
                    {
                        "set",{magusGUID = "#1#"},
                        "scheduletimer",{"recordmagus", 0},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellid = {102467, 102482, 102483, 102463},
                execute = {
                    {
                        "set",{magusGUID = "#1#"},
                        "scheduletimer",{"recordmagus", 0},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_TARGET",
                execute = {
                    {
                        "expect",{"&unitisplayertype|#1#&","==","true"},
                        "set",{magusGUID = "&unitguid|#1#target&"},
                        "set",{targetID = "&npcid|<magusGUID>&"},
                        "expect",{
                                "<targetID>","==","54882", -- Fire Magus
                                "OR",
                                "<targetID>","==","54883", -- Frost Magus
                                "OR",
                                "<targetID>","==","54884"}, -- Arcane Magus
                        "expect",{"&unitcombat|#1#target&","==","true"},
                        "scheduletimer",{"recordmagus", 0},
                    },
                },
            },
            -- Coldflame
            {
                type = "combatevent",
                eventtype = "SPELL_PERIODIC_DAMAGE",
                spellid = 102466,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","coldflameselfwarn",
                    },
                },
            },
            -- Magus dies
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","54882",
                                "OR","&npcid|#4#&","==","54883",
                                "OR","&npcid|#4#&","==","54884",
                        },
                        "set",{magicount = "DECR|1"},
                        "invoke",{
                            {
                                "expect",{"<magicount>",">","1"},
                                "set",{magitext = format(L.alert["%s Magi left"],"<magicount>")},
                            },
                            {
                                "expect",{"<magicount>","==","1"},
                                "set",{magitext = format(L.alert["%s Magus left"],"<magicount>")},
                            },
                        },
                        "expect",{"<magicount>",">","0"},
                        "alert","magiwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- MANNOROTH AND VARO'THEN
---------------------------------

do
    local data = {
        version = 1,
        key = "mannorothvarothen",
        zone = L.zone["Well of Eternity"],
        category = L.zone["Well of Eternity"],
        name = "Mannoroth and Varo'then",
        lfgname = "Mannoroth",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Mannoroth.blp",
        icon2 = "Interface\\EncounterJournal\\UI-EJ-BOSS-Varothen.blp",
        advanced = {
            delayWipe = 5,
        },
        plural = true,
        triggers = {
            scan = {
                54969, -- Mannoroth
                55419, -- Captain Varo'then
            },
        },
        onactivate = {
            tracing = {
                54969, -- Mannoroth
                55419, -- Captain Varo'then
            },
            phasemarkers = {
                {
                    {0.90,TI["AchievementShield"].." [That's Not Canon!]","At 90% of Mannoroth's HP, he will sacrifice Varo'then."},
                    {0.5,"Inferno!","Mannoroth calls down a hail of infernals!"},
                    {0.25,"Victory","At 25% HP, Mannoroth is defeated."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = L.chat_wellofeternity["Malfurion, he has done it! The portal is collapsing!"],
        },
        userdata = {
            -- Counters
            phase = 1,
            debilitatorsmarked = 0,
            
            -- Switches
            achievementcompleted = "no",
        },
        onstart = {
            {
                "alert","guidancecd",
                "alert",{"firestormcd",time = 2},
            },
        },
        
        phrasecolors = {
            {"Tyrande","GOLD"},
            {"Illidan","GOLD"},
            {"Magical Sword","GOLD"},
        },
        filters = {
            bossemotes = {
                firestormemote = {
                    name = "Fel Firestorm",
                    pattern = "begins to cast %[Fel Firestorm%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[103888],
                },
                tyrandeoverwhelmedemote = {
                    name = "|cffffd700Tyrande|r is overwhelmed",
                    pattern = "Tyrande is overwhelmed",
                    hasIcon = false,
                    hide = true,
                    texture = ST[97062],
                },
                swordemote = {
                    name = "|cffffd700Magical Sword|r falls to the ground",
                    pattern = "magical sword falls to the ground",
                    hasIcon = false,
                    hide = true,
                    texture = ST[104820],
                },
                tyrandecanholdemote = {
                    name = "|cffffd700Tyrande|r can hold her own",
                    pattern = "Tyrande can hold her own once again",
                    hasIcon = false,
                    hide = true,
                    texture = ST[97062],
                },
                massiveportalemote = {
                    name = "Massive demonic portal opens nearby",
                    pattern = "massive demonic portal opens",
                    hasIcon = false,
                    hide = true,
                    texture = ST[105041],
                },
                tyrandeshininglightemote = {
                    name = "|cffffd700Tyrande|r is imbued with the shining light",
                    pattern = "is imbued with the shining light",
                    hasIcon = false,
                    hide = true,
                    texture = ST[105072],
                },
                felguardemote = {
                    name = "Felguard spawn",
                    pattern = "Felguard pour forth from the demon portal",
                    hasIcon = false,
                    hide = true,
                    texture = ST[30146],
                },
                doomguardemote = {
                    name = "Doomguard spawn",
                    pattern = "Doomguard pour forth from the demon portal",
                    hasIcon = false,
                    hide = true,
                    texture = ST[18540],
                },
                infernalsemote = {
                    name = SN[105141],
                    pattern = "Infernals rain from the sky",
                    hasIcon = false,
                    hide = true,
                    texture = ST[105141],
                },
                tyrandecollapsesemote = {
                    name = "|cffffd700Tyrande|r collapses",
                    pattern = "Tyrande collapses",
                    hasIcon = false,
                    hide = true,
                    texture = ST[97062],
                },
            },
        },
        announces = {
            canonfailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 6070,
                msg = format(L.alert["<DXE> %s: Achievement failed!"],AL[6070]),
                throttle = true,
            },
            canoncompleted = {
                varname = "%s complete",
                type = "PARTY",
                subtype = "achievement",
                achievement = 6070,
                msg = format(L.alert["<DXE> Requirements for %s were met. You can kill the boss now."],AL[6070]),
                throttle = true,
            },
        },
        raidicons = {
            debilitatormark = {
                varname = format("%s {%s}","Dreadlord Debilitators","NPC_ENEMY"),
                type = "MULTIENEMY",
                persist = 15,
                unit = "#1#",
                icon = 1,
                total = 2,
                texture = ST[104678],
            },
        },
        ordering = {
            alerts = {"firestormcd","firestormwarn","firestormduration","felflamespatchcd","flamesselfwarn","swordwarn","guidancecd","guidancewarn","debilitatorswarn","phasewarn","infernocast","infernowarn","giftcd"},
        },
        
        alerts = {
            -- Magical Sword
            swordwarn = {
                varname = format(L.alert["%s Warning"],"Magical Sword"),
                type = "simple",
                text = format(L.alert["Click on %s near Varo'then's body"],"Magical Sword"),
                time = 1,
                color1 = "PEACH",
                sound = "ALERT7",
                icon = ST[104820],
            },
            
            -- Lunar Guidance
            guidancecd = {
                varname = format(L.alert["%s CD"],SN[102472]),
                type = "dropdown",
                text = format(L.alert["%s: %s"],"Tyrande",SN[102472]),
                time = 82,
                flashtime = 5,
                color1 = "GOLD",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[102472],
            },
            guidancewarn = {
                varname = format(L.alert["%s Warning"],SN[102472]),
                type = "simple",
                text = format(L.alert["%s"],SN[102472]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[102472],
            },
            -- Fel Firestorm
            firestormcd = {
                varname = format(L.alert["%s CD"],SN[103888]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[103888]),
                time = {29, 0, loop = false, type = "series"},
                time2 = 15,
                time3 = 24, -- 29 (offi)
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "GREEN",
                sound = "MINORWARNING",
                icon = ST[103888],
            },
            firestormwarn = {
                varname = format(L.alert["%s Warning"],SN[103888]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[103888]),
                time = 3,
                color1 = "YELLOW",
                sound = "BEWARE",
                icon = ST[103888],
            },
            firestormduration = {
                varname = format(L.alert["%s Duration"],SN[103888]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[103888]),
                time = 12,
                color1 = "ORANGE",
                sound = "ALERT8",
                icon = ST[103888],
                fillDirection = "DEPLETE",
                audiocd = true,
            },
            -- Fire Patch
            felflamespatchcd = {
                varname = format(L.alert["%s Patch CD"],SN[103891]),
                type = "centerpopup",
                text = format(L.alert["Next %s Patch"],SN[103891]),
                time = 2,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[103891],
            },
            -- Fel Flames
            flamesselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[103891]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[103891],L.alert["YOU"]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT10",
                icon = ST[103891],
                throttle = 2,
                emphasizewarning = {1,0.5},
                flashscreen = true,
            },
            -- Dreadlord Debilitators
            debilitatorswarn = {
                varname = format(L.alert["%s Warning"],"Dreadlord Debilitators"),
                type = "simple",
                text = format(L.alert["%s - SWITCH TARGET!"],"Dreadlord Debilitators"),
                time = 1,
                color1 = "PURPLE",
                sound = "ALERT10",
                icon = ST[104678],
            },
            -- Inferno!
            infernocast = {
                varname = format(L.alert["%s Cast"],SN[105141]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[105141]),
                time = 14,
                flashtime = 5,
                color1 = "LIGHTGREEN",
                color2 = "RED",
                sound = "None",
                icon = ST[105141],
            },
            infernowarn = {
                varname = format(L.alert["%s Warning"],SN[105141]),
                type = "simple",
                text = format(L.alert["%s"],SN[105141]),
                time = 1,
                color1 = "YELLOW",
                color2 = "Off",
                sound = "ALERT17",
                icon = ST[105141],
            },
            
            phasewarn = {
                varname = format(L.alert["Phase Warning"]),
                type = "simple",
                text = format(L.alert["Phase %s"],"<phase>"),
                time = 3,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[11242],
            },
            -- Gift of Sargeras
            giftcd = {
                varname = format(L.alert["%s Cast"],SN[104998]),
                type = "dropdown",
                text = format(L.alert["Illidan: %s"],SN[104998]),
                time = 30,
                flashtime = 10,
                color1 = "MAGENTA",
                color2 = "PURPLE",
                sound = "MINORWARNING",
                icon = ST[104998],
            },
            
        },
        timers = {
            firestormtimer = {
                {
                    "quash","firestormwarn",
                    "alert","firestormduration",
                },
            },
            flamestimer = {
                {
                    "quash","felflamespatchcd",
                    "alert","felflamespatchcd",
                    "set",{flamescount = "INCR|1"},
                    "expect",{"<flamescount>",">","5"},
                    "canceltimer","flamestimer",
                },
            },
        },
        events = {
			-- Fel Firestorm
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 103888,
                execute = {
                    {
                        "quash","firestormcd",
                        "alert","firestormcd",
                        "alert","firestormwarn",
                        "scheduletimer",{"firestormtimer", 3},
                    },
                },
            },
            -- Fel Flames
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellid = 103891,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","flamesselfwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[103888]},
                        "expect",{"#1#","find","boss"},
                        "alert","felflamespatchcd",
                        "set",{flamescount = 1},
                        "repeattimer",{"flamestimer", 2},
                        --"scheduletimer",{"flamestimer", 2},
                    },
                },
            },
            
            -- Dreadlord Debilitators
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellid = 104678,
                execute = {
                    {
                        "expect",{"<debilitatorsmarked>","<","1"},
                        "alert","debilitatorswarn",
                    },
                    {
                        "expect",{"<debilitatorsmarked>","<","2"},
                        "set",{debilitatorsmarked = "INCR|1"},
                        "raidicon","debilitatormark",
                    },
                },
            },
            
            -- Nether Tear
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#1#","==","boss1"},
                        "expect",{"#2#","==",SN[105041]},
                        "alert",{"firestormcd",time = 3},
                    },
                },
            },
            -- Blessing of Elune
            {
                type = "event",
                event = "YELL",
                execute = {
                    {
                        "expect",{"#1#","find",L.chat_wellofeternity["^Light of Elune"]},
                        "alert","guidancewarn",
                    },
                },
            },
            -- Fel Drain (Varo'then sacrificed - achievement)
            {
                type = "combatevent",
                eventtype = "SPELL_INSTAKILL",
                spellid = 104961,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","54969"},
                        "expect",{"&npcid|#4#&","==","55419"},
                        "set",{achievementcompleted = "yes"},
                        "announce","canoncompleted",
                    },
                },
            },
            -- Varo'then dies
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","55419"},
                        "removephasemarker",{1,1},
                        "alert","swordwarn",
                        "expect",{"<achievementcompleted>","==","no"},
                        "announce","canonfailed",
                    },
                },
            },
            -- Inferno!
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 105141,
                execute = {
                    {
                        "alert","infernocast",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[105141]},
                        "expect",{"#1#","find","boss"},
                        "alert","infernowarn",
                    },
                },
            },
            
            -- Phase 2            
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[104820]},
                        "expect",{"#1#","find","boss"},
                        "expect",{"<phase>","==","1"},
                        "set",{phase = 2},
                        "alert","phasewarn",
                    },
                },
            },
            -- Gift of Sargeras
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 104998,
                execute = {
                    {
                        "alert","giftcd",
                    },
                },
            },
            
            -- Phase 3
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 104998,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","55532"},
                        "expect",{"<phase>","==","2"},
                        "set",{phase = 3},
                        "alert","phasewarn",
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
        key = "wellofeternitytrash",
        zone = L.zone["Well of Eternity"],
        category = L.zone["Well of Eternity"],
        name = "Trash",
        triggers = {
            scan = {
                55503, -- Legion Demon
                54612, -- Eternal Champion
                55654, -- Corrupted Arcanist
                55656, -- Dreadlord Defender
                55453, -- Shadowbat
            },
        },
        onpullevent = {
            -- Role-Play before Manoroth and Varothen - Part I
            {
                triggers = {say = L.chat_wellofeternity["Can you close the portal"]},
                invoke = {
                    {
                        "set",{blessingofelunecd = 40},
                        "alert","blessingofelunecd",
                    },
                },
            },
            {
                triggers = {say = L.chat_wellofeternity["It is being maintained by the will"]},
                invoke = {
                    {
                        "set",{blessingofelunecd = 34},
                        "alert","blessingofelunecd",
                    },
                },
            },
            {
                triggers = {say = L.chat_wellofeternity["cannot break his will alone"]},
                invoke = {
                    {
                        "set",{blessingofelunecd = 28},
                        "alert","blessingofelunecd",
                    },
                },
            },
            {
                triggers = {say = L.chat_wellofeternity["we shall break it for you"]},
                invoke = {
                    {
                        "set",{blessingofelunecd = 24},
                        "alert","blessingofelunecd",
                    },
                },
            },
            {
                triggers = {say = L.chat_wellofeternity["He knows what we attempt"]},
                invoke = {
                    {
                        "set",{blessingofelunecd = 18},
                        "alert","blessingofelunecd",
                    },
                },
            },
            {
                triggers = {say = L.chat_wellofeternity["Let them come"]},
                invoke = {
                    {
                        "set",{blessingofelunecd = 12},
                        "alert","blessingofelunecd",
                    },
                },
            },
            {
                triggers = {say = L.chat_wellofeternity["guide us through this darkness"]},
                invoke = {
                    {
                        "set",{blessingofelunecd = 7},
                        "alert","blessingofelunecd",
                    },
                },
            },
            {
                triggers = {boss_emote = L.chat_wellofeternity["Tyrande gains the %[Blessing of Elune%]"]},
                invoke = {
                    {
                        "scheduletimer",{"blessingofelunetimer", 2},
                    },
                },
            },
            {
                triggers = {say = L.chat_wellofeternity["Hardly worthy of being called a legion"]},
                invoke = {
                    {
                        "quash","blessingofelunewarn",
                    },
                },
            },
            -- Role-Play before Manoroth and Varothen - Part II
            {
                triggers = {say = L.chat_wellofeternity["Oh this will be fun"]},
                invoke = {
                    {
                        "set",{watersofeternitycd = 20},
                        "alert","watersofeternitycd",
                    },
                    {
                        "set",{doombringerattackablecd = 24},
                        "alert","doombringerattackablecd",
                    },
                },
            },
            {
                triggers = {say = L.chat_wellofeternity["I have an idea"]},
                invoke = {
                    {
                        "set",{watersofeternitycd = 15},
                        "alert","watersofeternitycd",
                    },
                    {
                        "set",{doombringerattackablecd = 19},
                        "alert","doombringerattackablecd",
                    },
                },
            },
            {
                triggers = {say = L.chat_wellofeternity["what is in that vial"]},
                invoke = {
                    {
                        "set",{watersofeternitycd = 7.5},
                        "alert","watersofeternitycd",
                    },
                    {
                        "set",{doombringerattackablecd = 11.5},
                        "alert","doombringerattackablecd",
                    },
                },
            },
            {
                triggers = {say = L.chat_wellofeternity["What our people could not"]},
                invoke = {
                    {
                        "set",{watersofeternitycd = 5},
                        "alert","watersofeternitycd",
                    },
                    {
                        "set",{doombringerattackablecd = 9},
                        "alert","doombringerattackablecd",
                    },
                },
            },
            {
                triggers = {boss_emote = L.chat_wellofeternity["Illidan douses himself with the %[Waters of Eternity%]"]},
                invoke = {
                    {
                        "scheduletimer",{"watersofeternitytimer", 2},
                    },
                },
            },
            
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {

        },
        
        phrasecolors = {
            {"Eternal Champion:","GOLD"},
            {"Tyrande:","GOLD"},
            {"Doombringer:","GOLD"},
            {"Shadowbat","GOLD"},
            {"Illidan:","GOLD"},
        },
        raidicons = {
            arcanistmark = {
                varname = format("%s {%s}","Corrupted Arcanist","NPC_ENEMY"),
                type = "ENEMY",
                persist = 5,
                unit = "<arcanistunit>",
                icon = 1,
                texture = ST[1953],
            },
        },
        filters = {
            bossemotes = {
                blessingofelune = {
                    name = "Blessing of Elune",
                    pattern = "Tyrande gains the %[Blessing of Elune%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[103917],
                },
                watersofeternity = {
                    name = "Waters of Eternity",
                    pattern = "Illidan douses himself with the %[Waters of Eternity%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[103952],
                },
            },
        },
        ordering = {
            alerts = {"strikecd","sheenwarn","sheencd","blessingofelunecd","blessingofelunewarn","doombringerattackablecd","watersofeternitycd","watersofeternitywarn","displacementwarn"},
        },
        
        alerts = {
            -- Strike Fear
            strikecd = {
                varname = format(L.alert["%s CD"],SN[103913]),
                type = "centerpopup",
                text = format(L.alert["Next %s"],SN[103913]),
                time = 7,
                flashtime = 7,
                color1 = "PURPLE",
                sound = "None",
                icon = ST[103913],
                tag = "#1#",
            },
            -- Sheen of Elune
            sheencd = {
                varname = format(L.alert["%s CD"],SN[102259]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[102259]),
                time = 35,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[102259],
                tag = "#1#",
            },
            sheenwarn = {
                varname = format(L.alert["%s Warning"],SN[102259]),
                type = "simple",
                text = format("%s on %s - DISPEL!",SN[102259],"#2#"),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT10",
                icon = ST[102259],
            },
            -- Blessing of Elune
            blessingofelunecd = {
                varname = format(L.alert["%s CD"],SN[103917]),
                type = "dropdown",
                text = format(L.alert["Tyrande: %s"],SN[103917]),
                time = "<blessingofelunecd>",
                flashtime = 5,
                color1 = "WHITE",
                color2 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[103917],
                behavior = "singleton",
            },
            blessingofelunewarn = {
                varname = format(L.alert["%s Warning"],SN[103917]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[103917]),
                time = 41,
                color1 = "YELLOW",
                sound = "ALERT2",
                icon = ST[103917],
            },
            -- Waters of Eternity
            watersofeternitycd = {
                varname = format(L.alert["%s CD"],SN[103952]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[103952]),
                time = "<watersofeternitycd>",
                flashtime = 5,
                color1 = "CYAN",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[103952],
                behavior = "singleton",
            },
            watersofeternitywarn = {
                varname = format(L.alert["%s Warning"],SN[103952]),
                type = "simple",
                text = format(L.alert["Illidan: %s"],SN[103952]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT1",
                icon = ST[103952],
            },
            -- Abyssal Doombringer attackable
            doombringerattackablecd = {
                varname = format(L.alert["%s CD"],"Doombringer attackable"),
                type = "dropdown",
                text = format(L.alert["%s"],"Doombringer attackable"),
                time = "<doombringerattackablecd>",
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "Off",
                sound = "MINORWARNING",
                icon = "Interface\\ICONS\\Ability_Warlock_FireandBrimstone",
                behavior = "singleton",
            },
            -- Displacement
            displacementwarn = {
                varname = format(L.alert["%s Warning"],SN[103763]),
                type = "simple",
                text = format(L.alert["%s on Shadowbat - Use AoE Ability!"],SN[103763]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT8",
                icon = ST[103763],
            },
            
        },
        timers = {
            blessingofelunetimer = {
                {
                    "quash","blessingofelunecd",
                    "alert","blessingofelunewarn",
                },
            },
            watersofeternitytimer = {
                {
                    "quash","watersofeternitycd",
                    "alert","watersofeternitywarn",
                },
            },
        },
        events = {
            -- Strike Fear
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 103913,
                execute = {
                    {
                        "quash",{"strikecd","#1#"},
                        "alert","strikecd",
                    },
                },
            },
            -- Sheen of Elune
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 102259,
                execute = {
                    {
                        "quash",{"sheencd","#1#"},
                        "alert","sheencd",
                        "alert","sheenwarn",
                    },
                },
            },
            
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    -- Legion Demon
                    {
                        "expect",{"&npcid|#4#&","==","55503"},
                        "quash",{"strikecd","#4#"},
                    },
                },
            },
            -- Arcane Annihilation
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 107865,
                execute = {
                    {
                        "set",{arcanistunit = "#1#"},
                        "raidicon","arcanistmark",
                    },
                },
            },
            -- Displacement
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 103763,
                execute = {
                    {
                        "expect",{"&npcid|#1#&","==","55453"},
                        "alert","displacementwarn",
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
DXE:RegisterGossip("WoE_Greetings", "I am ready to be hidden by your shadowcloak", "Illidan: Greetings")
DXE:RegisterGossip("WoE_Roleplay", "Let's go", "Illidan: Role-play")
DXE:RegisterGossip("WoE_Leaving", "Farewell, and good luck", "Illidan: Peroth’arn defeated")
