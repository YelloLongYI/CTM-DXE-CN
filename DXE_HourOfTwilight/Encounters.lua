local L,SN,ST,SL,AL,AT,AN,TI = DXE.L,DXE.SN,DXE.ST,DXE.SL,DXE.AL,DXE.AT,DXE.AN,DXE.TI
---------------------------------
-- ARCURION
---------------------------------

do
    local data = {
        version = 1,
        key = "arcurion",
        zone = L.zone["Hour of Twilight"],
        category = L.zone["Hour of Twilight"],
        name = "Arcurion",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Arcurion.blp",
        triggers = {
            scan = {
                54590, -- Arcurion
            },
        },
        onpullevent = {
            {
                triggers = {
                    say = L.chat_houroftwilight["Show yourself"],
                },
                invoke = {
                    {
                       "alert","pullcd",
                    },
                },
            },
        },
        onactivate = {
            tracing = {
                54590,
            },
            phasemarkers = {
                {
                    {0.30,"Torrent of Frost","At 30% HP, Arcurion unleashes Torrent of Frost dealing AoE damage for the rest of the fight."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 54590,
        },
        userdata = {
            
        },
        onstart = {
            {
                "alert","tombcd",
                "repeattimer",{"checkhp", 1},
            },
        },
        
        arrows = {
            icetombarrow = {
                varname = format("%s",SN[103252]),
                unit = "player",
                persist = 5,
                action = "TOWARD",
                msg = L.alert["Free Thrall"],
                spell = SN[103252],
                fixed = true,
                xpos = 0.56309604644775,
                ypos = 0.26620334386826,
                sound = "None",
                cancelrange = 10,
                range1 = 15,
                range2 = 20,
                range3 = 30,
                texture = ST[103251],
            },
        },
        filters = {
            bossemotes = {
                newforcesemote = {
                    name = "Twilight forces appear",
                    pattern = "Twilight forces begin to appear",
                    hasIcon = false,
                    hide = true,
                    texture = ST[11242],
                },
                icytombemote = {
                    name = "Icy Tomb",
                    pattern = "Arcurion begins to freeze Thrall",
                    hasIcon = false,
                    hide = true,
                    texture = ST[103251],
                },
            },
        },
        phrasecolors = {
            {"FREE Thrall","GOLD"}
        },
        ordering = {
            alerts = {"pullcd","chainswarn","tombcd","tombwarn","torrentsoonwarn","torrentwarn"},
        },
        
        alerts = {
            -- Pull Countdown
            pullcd = {
				varname = format(L.alert["Pull Countdown"]),
				type = "dropdown",
				text = format(L.alert["%s"],"Encounter starts"),
				time = 23.5,
				flashtime = 10,
				color1 = "TURQUOISE",
                icon = ST[11242],
            },
            -- Icy Tomb
            tombcd = {
                varname = format(L.alert["%s CD"],SN[103252]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[103252]),
                time = 30,
                flashtime = 5,
                color1 = "CYAN",
                color2 = "INDIGO",
                sound = "MINORWARNING",
                icon = ST[103251],
            },
            tombwarn = {
                varname = format(L.alert["%s Warning"],SN[103252]),
                type = "simple",
                text = format(L.alert["%s - FREE Thrall!"],SN[103252]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT10",
                icon = ST[103251],
                emphasize = true,
            },
            -- Chains of Frost
            chainswarn = {
                varname = format(L.alert["%s Warning"],SN[102582]),
                type = "simple",
                text = format(L.alert["%s"],SN[102582]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT7",
                icon = ST[102582],
            },
            -- Torrent of Frost
            torrentsoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[104050]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[104050]),
                time = 1,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[104050],
            },
            torrentwarn = {
                varname = format(L.alert["%s Warning"],SN[104050]),
                type = "simple",
                text = format(L.alert["%s"],SN[104050]),
                time = 1,
                color1 = "YELLOW",
                sound = "BEWARE",
                icon = ST[104050],
            },
        },
        timers = {
            checkhp = {
				{
					"expect",{"&gethp|boss1&","<","40"},
					"alert","torrentsoonwarn",
                    "canceltimer","checkhp",
				},
            },
        },
        events = {
            
			-- Icy Tomb
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 103252,
                execute = {
                    {
                        "alert","tombwarn",
                        "arrow","icetombarrow",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","54995"}, -- Icy Tomb destroyed
                        "alert","tombcd",
                    },
                },
            },
            -- Chains of Frost
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 102582,
                execute = {
                    {
                        "alert","chainswarn",
                    },
                },
            },
            -- Torrent of Frost
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 104050,
                execute = {
                    {
                        "alert","torrentwarn",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ASIRA DAWNSLAYER
---------------------------------

do
    local data = {
        version = 1,
        key = "asiradownslayer",
        zone = L.zone["Hour of Twilight"],
        category = L.zone["Hour of Twilight"],
        name = "Asira Dawnslayer",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Asira Dawnslayer.blp",
        triggers = {
            scan = {
                54968, -- Asira Dawnslayer
            },
        },
        onpullevent = {
            {
                triggers = {
                    say = L.chat_houroftwilight["Up there, above us"],
                },
                invoke = {
                    {
                       "alert","roleplayduration",
                    },
                },
            },
        },
        onactivate = {
            tracing = {
                54968,
            },
            phasemarkers = {
                {
                    {0.30,"Blade Barrier","At 30% HP, Asira starts reducing attacks that are less than 40k damage to 1."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 54968,
        },
        userdata = {
            marktext = "",
            player_units = {type = "container", wipein = 3},
            meleemarksplaced = "no",
            
        },
        onstart = {
            {
                "alert",{"bombcd",time = 2},
                "alert",{"totemcd",time = 2},
                "insert",{"player_units","{party}"},
                "expect",{"&itemvalue|mos_mode&","==","melee"},
                "scheduletimer",{"meleemarktimer", 1},
            },
        },
        
        raidicons = {
            markmark_ranged = {
                varname = format("%s {%s}",SN[102726].." - ranged","PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 300,
                unit = "#5#",
                reset = 2,
                icon = 3,
                total = 4,
                texture = ST[102726],
            },
            markmark_melee = {
                varname = format("%s {%s}",SN[102726].." - melee","PLAYER_DEBUFF"),
                type = "MULTIFRIENDLY",
                persist = 300,
                unit = "{player_units}",
                reset = 2,
                icon = 3,
                total = 4,
                texture = ST[102726],
            },
        },
        misc = {
            args = {
                mos_mode = {
                    name = L.chat_houroftwilight["Mark fo Silence mode"],
                    type = "select",
                    values = {
                        melee = "Mark melees and tank",
                        ranged = "Mark ranged and healers",
                    },
                    width = "full",
                    default = "melee",
                },
            },
        },
        ordering = {
            alerts = {"roleplayduration","bombcd","bombwarn","totemcd","totemwarn","barrierwarn","lesserbarrierwarn"},
        },
        
        alerts = {
            -- Role-play (Intro)
            roleplayduration = {
                varname = format(L.alert["%s Duration"],"Role-play"),
                type = "dropdown",
                text = format(L.alert["%s"],"Role-play"),
                time = 46,
                flashtime = 10,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            -- Choking Smoke Bomb
            bombcd = {
                varname = format(L.alert["%s CD"],SN[103558]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[103558]),
                time = 24,
                time2 = 15,
                flashtime = 5,
                color1 = "TEAL",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[103558],
            },
            bombwarn = {
                varname = format(L.alert["%s Warning"],SN[103558]),
                type = "simple",
                text = format(L.alert["%s"],SN[103558]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT8",
                icon = ST[103558],
            },
            -- Rising Fire Totem
            totemcd = {
                varname = format(L.alert["%s CD"],SN[108374]),
                type = "dropdown",
                text = format(L.alert["New %s"],SN[108374]),
                time = 23,
                time2 = 26,
                flashtime = 5,
                color1 = "RED",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[108374],
            },
            totemwarn = {
                varname = format(L.alert["%s Warning"],SN[108374]),
                type = "simple",
                text = format(L.alert["New: %s"],SN[108374]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT9",
                icon = ST[108374],
            },
            -- Blade Barrier
            barrierwarn = {
                varname = format(L.alert["%s Warning"],SN[103419]),
                type = "simple",
                text = format(L.alert["%s"],SN[103419]),
                time = 1,
                color1 = "WHITE",
                sound = "ALERT1",
                icon = ST[103419],
            },
            -- Lesser Blade Barrier
            lesserbarrierwarn = {
                varname = format(L.alert["%s Warning"],SN[103562]),
                type = "simple",
                text = format(L.alert["%s"],SN[103562]),
                time = 1,
                color1 = "TAN",
                sound = "ALERT2",
                icon = ST[103562],
            },
        },
        timers = {
            meleemarktimer = {
                {
                    "raidicon","markmark_melee",
                    "set",{meleemarksplaced = "yes"},
                },
            },
        },
        events = {
			-- Choking Smoke Bomb
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 103558,
                execute = {
                    {
                        "quash","bombcd",
                        "alert","bombcd",
                        "alert","bombwarn",
                    },
                },
            },
            -- Rising Fire Totem
            {
                type = "combatevent",
                eventtype = "SPELL_SUMMON",
                spellname = 108374,
                execute = {
                    {
                        "quash","totemcd",
                        "alert","totemcd",
                        "alert","totemwarn",
                    },
                },
            },
            -- Blade Barrier
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 103419,
                execute = {
                    {
                        "alert","barrierwarn",
                    },
                },
            },
            -- Lesser Blade Barrier
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 103562,
                execute = {
                    {
                        "alert","lesserbarrierwarn",
                    },
                },
            },
            -- Mark of Silence
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 102726,
                execute = {
                    {
                        "expect",{"&itemvalue|mos_mode&","==","ranged"},
                        "raidicon","markmark_ranged",
                    },
                    {
                        "expect",{"&itemvalue|mos_mode&","==","melee"},
                        "expect",{"<meleemarksplaced>","==","no"},
                        "remove",{"player_units","#5#"},
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ARCHBISHOP BENEDICTUS
---------------------------------

do
    local data = {
        version = 1,
        key = "archbishopbenedictus",
        zone = L.zone["Hour of Twilight"],
        category = L.zone["Hour of Twilight"],
        name = "Archbishop Benedictus",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Archbishop Benedictus.blp",
        triggers = {
            scan = {
                54938, -- Archbishop Benedictus
            },
        },
        onpullevent = {
            {
                triggers = {
                    say = L.chat_houroftwilight["you will give the Dragon Soul"],
                },
                invoke = {
                    {
                       "alert","roleplayduration",
                    },
                },
            },
        },
        onactivate = {
            tracing = {
                54938,
            },
            phasemarkers = {
                {
                    {0.60,"Phase 2","At 60% HP, Archbishop Benedictus casts Twilight Epiphany and Phase 2 begins."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 54938,
        },
        userdata = {
            rightsheartext = "",
            rightshearwarntext = "",
            twsheartext = "",
            twshearwarntext = "",
            sparkcount = 0,
        },
        onstart = {
            {
                "alert",{"wavevirtuecd",time = 2},
                "repeattimer",{"checkhp", 1},
            },
        },
        
        raidicons = {
            rightshearmark = {
                varname = format("%s {%s}",SN[103151].." / "..SN[103363],"PLAYER_DEBUFF"),
                type = "FRIENDLY",
                unit = "#5#",
                persist = 30,
                icon = 2,
                texture = ST[103151],
            },
        },
        filters = {
            bossemotes = {
                wavevirtueemote = {
                    name = "Wave of Virtue",
                    pattern = "summons a %[Wave of Virtue%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[103678],
                },
                wavetwighlightemote = {
                    name = "Wave of Twilight",
                    pattern = "summons a %[Wave of Twilight%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[103780],
                },
                phase2emote = {
                    name = "Phase 2",
                    pattern = "begins to cast %[Twilight Epiphany%]",
                    hasIcon = true,
                    hide = true,
                    texture = ST[103754],
                },
                cleansespiritemote = {
                    name = "Cleanse Spirit",
                    pattern = "casts %[Cleanse Spirit%]",
                    hasIcon = true,
                    texture = ST[51886],
                },
            },
        },
        windows = {
            proxwindow = true,
            proxrange = 10,
            proxoverride = true,
        },
        counters = {
            sparkcounter = {
                variable = "sparkcount",
                label = format("%s Twilight Sparks dead",TI["AchievementShield"]),
                pattern = "%d / %d",
                value = 0,
                minimum = 0,
                maximum = 10,
            },
        },
        announces = {
            eclipsecompleted = {
                varname = "%s complete",
                type = "PARTY",
                subtype = "achievement",
                achievement = 6132,
                msg = format(L.alert["<DXE> Requirements for %s were met. You can kill the boss now."],AL[6132]),
                throttle = true,
            },
        },
        grouping = {
            {
                general = true,
                alerts = {"roleplayduration","phasesoonwarn","phasewarn"},
            },
            {
                phase = format("|cffffff7d%s|r |cffffffff%s|r","Light","Phase"),
                alerts = {"rightshearwarn","purelightwarn","purelightselfwarn","wavevirtuecd","wavevirtuewarn"},
            },
            {
                phase = format("|cffa704ff%s|r |cffffffff%s|r","Twilight","Phase"),
                alerts = {"twshearwarn","twilightwarn","twilightselfwarn","wavetwilightcd","wavetwilightwarn"},
            }
        },
        
        alerts = {
            -- Role-play (Intro)
            roleplayduration = {
                varname = format(L.alert["%s Duration"],"Role-play"),
                type = "dropdown",
                text = format(L.alert["%s"],"Role-play"),
                time = 51.75,
                flashtime = 10,
                color1 = "GOLD",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            -------------------------------------------------------
            ------------------------ Phase 1 ----------------------
            -------------------------------------------------------
            -- Righteous Shear
            rightshearwarn = {
                varname = format(L.alert["%s Warning"],SN[103151]),
                type = "centerpopup",
                text = "<rightsheartext>",
                warningtext = "<rightshearwarntext>",
                time = 30,
                color1 = "YELLOW",
                sound = "ALERT8",
                icon = ST[103151],
            },
            -- Purifying Light
            purelightwarn = {
                varname = format(L.alert["%s Warning"],SN[103565]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[103565]),
                time = 8,
                color1 = "ORANGE",
                sound = "ALERT2",
                icon = ST[103565],
            },
            -- Purified
            purelightselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[103653]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[103653],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[103653],
                throttle = 2,
                emphasizewarning = true,
                flashscreen = true,
            },
            -- Wave of Virtue
            wavevirtuecd = {
                varname = format(L.alert["%s CD"],SN[103677]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[103677]),
                time = 46,
                time2 = 27,
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[103678],
                throttle = 1,
            },
            wavevirtuewarn = {
                varname = format(L.alert["%s Warning"],SN[103677]),
                type = "simple",
                text = format(L.alert["%s"],SN[103677]),
                time = 1,
                color1 = "YELLOW",
                sound = "BEWARE",
                icon = ST[103678],
                throttle = 1,
            },
            -------------------------------------------------------
            ------------------------ Phase 2 ----------------------
            -------------------------------------------------------
            -- Phase 2
            phasewarn = {
                varname = format(L.alert["Phase 2 Warning"]),
                type = "centerpopup",
                text = format(L.alert["Phase %s  transition"], 2),
                warningtext = format(L.alert["Phase %s"], 2),
                time = 5,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[11242],
            },
            phasesoonwarn = {
                varname = format(L.alert["%s soon Warning"],"Phase 2"),
                type = "simple",
                text = format(L.alert["%s soon ..."],"Phase 2"),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            -- Twilight Shear
            twshearwarn = {
                varname = format(L.alert["%s Warning"],SN[103363]),
                type = "centerpopup",
                text = "<twsheartext>",
                warningtext = "<twshearwarntext>",
                time = 30,
                color1 = "MAGENTA",
                sound = "ALERT8",
                icon = ST[103363],
            },
            -- Corrupting Twilight
            twilightwarn = {
                varname = format(L.alert["%s Warning"],SN[103767]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[103767]),
                time = 8,
                color1 = "CYAN",
                sound = "ALERT2",
                icon = ST[103767],
            },
            -- Twilight
            twilightselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[103775]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[103775],L.alert["YOU"]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT10",
                icon = ST[103775],
                throttle = 2,
                flashscreen = true,
                emphasizewarning = true,
            },
            -- Wave of Twilight
            wavetwilightcd = {
                varname = format(L.alert["%s CD"],SN[103782]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[103782]),
                time = 46,
                time2 = 27,
                flashtime = 5,
                color1 = "MAGENTA",
                color2 = "PINK",
                sound = "MINORWARNING",
                icon = ST[103780],
                throttle = 1,
            },
            wavetwilightwarn = {
                varname = format(L.alert["%s Warning"],SN[103782]),
                type = "simple",
                text = format(L.alert["%s"],SN[103782]),
                time = 1,
                color1 = "MAGENTA",
                sound = "BEWARE",
                icon = ST[103780],
                throttle = 1,
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","70"},
                    "alert","phasesoonwarn",
                    "canceltimer","checkhp",
                },
            },
            phase2timer = {
                {
                    "alert",{"wavetwilightcd",time = 2},
                    "counter","sparkcounter",
                },
            },
        },
        events = {
            -------------------------------------------------------
            ------------------------ Phase 1 ----------------------
            -------------------------------------------------------
			-- Righteous Shear
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 103151,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{
                            rightsheartext = format(L.alert["%s on <%s>"],SN[103151],L.alert["YOU"]),
                            rightshearwarntext = format(L.alert["%s on <%s> - DISPEL!"],SN[103151],L.alert["YOU"])
                        },
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{
                            rightsheartext = format(L.alert["%s on <#5#>"],SN[103151]),
                            rightshearwarntext = format(L.alert["%s on <#5#> - DISPEL!"],SN[103151])
                        },
                    },
                    {
                        "alert","rightshearwarn",
                        "raidicon","rightshearmark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 103151,
                execute = {
                    {
                        "removeraidicon","#5#",
                        "quash","rightshearwarn",
                    },
                },
            },
            -- Purifying Light
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 103565,
                execute = {
                    {
                        "alert","purelightwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 103653,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","purelightselfwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_MISSED",
                spellname = 103653,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","purelightselfwarn",
                    },
                },
            },
            -- Wave of Virtue
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[103677]},
                        "expect",{"#1#","==","boss1"},
                        "quash","wavevirtuecd",
                        "alert","wavevirtuecd",
                        "alert","wavevirtuewarn",
                    },
                    {
                        "expect",{"#2#","==",SN[103680]},
                        "expect",{"#1#","==","boss1"},
                    },
                    {
                        "expect",{"#2#","==",SN[103681]},
                        "expect",{"#1#","==","boss1"},
                    },
                },
            },
            -------------------------------------------------------
            ------------------------ Phase 2 ----------------------
            -------------------------------------------------------
            -- Phase 2 transition
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 103754,
                execute = {
                    {
                        "alert","phasewarn",
                        "quash","wavevirtuecd",
                        "scheduletimer",{"phase2timer", 5},
                    },
                },
            },
            -- Twilight Shear
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 103363,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{
                            twsheartext = format(L.alert["%s on <%s>"],SN[103363],L.alert["YOU"]),
                            twshearwarntext = format(L.alert["%s on <%s> - DISPEL!"],SN[103363],L.alert["YOU"])
                        },
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{
                            twsheartext = format(L.alert["%s on <#5#>"],SN[103363]),
                            twshearwarntext = format(L.alert["%s on <#5#> - DISPEL!"],SN[103363])
                        },
                    },
                    {
                        "alert","twshearwarn",
                        "raidicon","rightshearmark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 103363,
                execute = {
                    {
                        "removeraidicon","#5#",
                        "quash","twshearwarn",
                    },
                },
            },
            -- Corrupting Twilight
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 103767,
                execute = {
                    {
                        "alert","twilightwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 103775,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","twilightselfwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_MISSED",
                spellname = 103775,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","twilightselfwarn",
                    },
                },
            },
            -- Wave of Twilight
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[103782]},
                        "expect",{"#1#","==","boss1"},
                        "quash","wavetwilightcd",
                        "alert","wavetwilightcd",
                        "alert","wavetwilightwarn",
                    },
                    {
                        "expect",{"#2#","==",SN[103783]},
                        "expect",{"#1#","==","boss1"},
                    },
                    {
                        "expect",{"#2#","==",SN[103784]},
                        "expect",{"#1#","==","boss1"},
                    },
                },
            },
            -- Eclipse (achievement)
            {
                type = "combatevent",
                eventtype = "PARTY_KILL",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","55466"},
                        "expect",{"<sparkcount>","<","10"},
                        "set",{sparkcount = "INCR|1"},
                        "expect",{"<sparkcount>","==","10"},
                        "announce","eclipsecompleted",
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
        key = "hottrash",
        zone = L.zone["Hour of Twilight"],
        category = L.zone["Hour of Twilight"],
        name = "Trash",
        triggers = {
            scan = {
                54633, -- Faceless Shadow Weaver
                54686, -- Shadow Borer
                54632, -- Faceless Brute
                55111, -- Twilight Thug
                55109, -- Twilight Shadow-Walker
                55112, -- Twilight Bruiser
                55107, -- Twilight Ranger
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {
            squeezetext = "",
            shadowstext = "",
        },
        customcolors = {
            
        },
        windows = {
			proxwindow = true,
            enabled = false,
			proxrange = 30,
			proxoverride = true,
            nodistancecheck = true,
            proxnoautostart = true,
		},
        radars = {
            shadowsradar = {
                varname = SN[102984],
                type = "circle",
                player = "#5#",
                range = 8,
                mode = "avoid",
                color = "MAGENTA",
                icon = ST[102984],
            },
        },
        raidicons = {
            shadowsmark = {
                varname = format("%s {%s}",SN[102984],"ABILITY_TARGET_HARM"),
                type = "FRIENDLY",
                persist = 4,
                unit = "#5#",
                reset = 4,
                icon = 1,
                texture = ST[102984],
            },
        },
        announces = {
            squeezesay = {
                type = "SAY",
                subtype = "self",
                spell = 102861,
                msg = format(L.alert["%s on ME!"],SN[102861]),
            },
            freezingtrapsay = {
                type = "SAY",
                subtype = "self",
                spell = 43415,
                msg = format(L.alert["%s on ME!"],SN[43415]),
            },
        },
        ordering = {
            alerts = {"freezingtrapwarn","squeezewarn","shadowswarn"},
        },
        
        alerts = {
            -- Squeeze Lifeless
            squeezewarn = {
                varname = format(L.alert["%s Absorbs"],SN[102861]),
                type = "absorb",
                text = "<squeezetext>",
                textformat = format("%s (%%s/%%s - %%d%%%%)",L.alert["Shield"]),
                time = 20,
                color1 = "RED",
                sound = "ALERT2",
                icon = ST[102861],
                npcid = 54632,
                values = {
                    [102861] = 150000,
                },
            },
            -- Seeking Shadows
            shadowswarn = {
                varname = format(L.alert["%s Warning"],SN[102984]),
                type = "centerpopup",
                text = "<shadowstext>",
                time = 4,
                color1 = "PURPLE",
                sound = "ALERT5",
                icon = ST[102984],
            },
            -- Freezing Trap
            freezingtrapwarn = {
                varname = format(L.alert["%s Warning"],SN[43415]),
                type = "simple",
                text = "<freezingtraptext>",
                time = 1,
                color1 = "CYAN",
                sound = "ALERT11",
                icon = ST[43415],
            },
            
        },
        events = {
            -- Freezing Trap
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 43415,
                dstisplayertype = true,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{freezingtraptext = format(L.alert["%s on <%s>"],SN[43415],L.alert["YOU"])},
                        "announce","freezingtrapsay",
                        "alert","freezingtrapwarn",
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{freezingtraptext = format(L.alert["%s on <%s>"],SN[43415],"#5#")},
                        "alert","freezingtrapwarn",
                    },
                },
            },
            -- Squeeze Lifeless
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 102861,
                execute = {
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{squeezetext = format(L.alert["%s on <%s>"],SN[102861],"#5#")},
                        "alert","squeezewarn",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{squeezetext = format(L.alert["%s on <%s>"],SN[102861],L.alert["YOU"])},
                        "alert","squeezewarn",
                        "announce","squeezesay",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[102861]},
                        "quash","squeezewarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_CHANNEL_STOP",
                execute = {
                    {
                        "expect",{"#2#","==",SN[102861]},
                        "quash","squeezewarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_TARGET",
                execute = {
                    {
                        "expect",{"&npcid|&unitguid|#1#target&&","==","54632"},
                        "expect",{"&ischannelingspell|#1#target|Squeeze Lifeless&","==","false"},
                        "quash","squeezewarn",
                    },
                },
            },
            
            -- Seeking Shadows
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 102984,
                execute = {
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{shadowstext = format(L.alert["%s on <%s>"],SN[102984],"#5#")},
                        "alert","shadowswarn",
                        "raidicon","shadowsmark",
                        "range",{true},
                        "radar","shadowsradar",
                    },
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{shadowstext = format(L.alert["%s on <%s>"],SN[102984],L.alert["YOU"])},
                        "alert","shadowswarn",
                        "raidicon","shadowsmark",
                        "range",{true},
                        "radar","shadowsradar",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 102984,
                execute = {
                    {
                        "range",{false},
                        "removeraidicon","#5#",
                        "removeradar",{"shadowsradar", player = "#5#"},
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
DXE:RegisterGossip("HoT_Trash1", "Yes Thrall", "Thrall: Continue")
DXE:RegisterGossip("HoT_ArcurionDefeated", "Lead the way", "Thrall: Arcurion defeated")
