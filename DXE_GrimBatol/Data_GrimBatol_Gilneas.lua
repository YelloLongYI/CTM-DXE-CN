-- Data_GrimBatol_Gilneas.lua
local L, SN, ST, TI = DXE.L, DXE.SN, DXE.ST, DXE.TI
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "umbriss", {
    windows = {
        proxwindow = false,
    },
    filters = {
        bossemotes = {
            blitzemote = {
                name = "Blitz",
                pattern = "begins to cast %[Blitz%]",
                texture = ST[74670],
            },
            siegeemote = {
                name = "Ground Siege",
                pattern = "begins to cast %[Ground Siege%]",
                texture = ST[74670],
            },
        },
    },
    userdata = {
        blitzcd = {20, 23, loop = false, type = "series"},
        siegecd = {26, 26, loop = false, type = "series"},
        troggscd = {10, 32.8, loop = false, type = "series"},
        maladytext = "",
        maladywarningtext = "",
    },
    alerts = {
        -- Ground Siege
        siegecd = {
            varname = format(L.alert["%s CD"],SN[74634]),
            text = format(L.alert["Next %s"],SN[74634]),
            icon = ST[74634],
        },
        siegewarn = {
            varname = format(L.alert["%s Warning"],SN[74634]),
            text = format(L.alert["%s"],SN[74634]),
            icon = ST[74634],
        },
        -- Blitz
        blitzcd = {
            varname = format(L.alert["%s CD"],SN[74670]),
            text = format(L.alert["Next %s"],SN[74670]),
            icon = ST[74670],
        },
        blitzwarn = {
            varname = format(L.alert["%s Warning"],SN[74670]),
            text = format(L.alert["%s"],SN[74670]),
            icon = ST[74670],
        },
        blitzselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[74670]),
            text = format(L.alert["%s on %s"],SN[74670],L.alert["YOU"]),
            icon = ST[74670],
        },
        -- Frenzy soon
        frenzysoonwarn = {
            varname = format(L.alert["%s soon Warning"],SN[74853]),
            text = format(L.alert["%s soon ..."],SN[74853]),
            icon = ST[74853],
        },
        -- Frenzy
        frenzywarn = {
            varname = format(L.alert["%s Warning"],SN[74853]),
            text = format(L.alert["%s!"],SN[74853]),
            icon = ST[74853],
        },
        -- Modgud's Malice
        maladywarn = {
            varname = format(L.alert["%s %s on General Umbriss Warning"],TI["AchievementShield"],SN[74699]),
            icon = ST[74699],
        },
    },
    events = {
        -- Ground Siege
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 74634,
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
            spellname = 74670,
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
            spellname = 74699,
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","39625"},
                    "set",{
                        maladywarningtext = format(L.alert["General Umbriss is affected by %s (%s)!"],SN[74699],"1"),
                        maladytext = format(L.alert["%s (%s)"],SN[74699],"1"),
                    },
                    "quash","maladywarn",
                    "alert","maladywarn",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED_DOSE",
            spellname = 74699,
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","39625"},
                    "set",{
                        maladywarningtext = format(L.alert["General Umbriss is affected by %s (%s)!"],SN[74699],"#11#"),
                        maladytext = format(L.alert["%s (%s)"],SN[74699],"#11#"),
                    },
                    "quash","maladywarn",
                    "alert","maladywarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "throngus", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        pickweaponcd = {5, 35, loop = false, type = "series"},
        stompcd = {7, 35, loop = false, type = "series"},
    },
    grouping = DXE.Replace({
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
            icon = ST[74981],
            alerts = {"bladeswarn","bladesduration","flameswarn","roarwarn"},
        },
        {
            name = format("|cffffd700%s|r |cffffffffequipped|r","Mace"),
            icon = ST[75007],
            alerts = {"macewarn","maceduration","slamcd","slamwarn","lavaselfwarn"},
        },
    }),
    alerts = {
        ------------------------------
        -- Weapon: Personal Phalanx --
        ------------------------------
        -- Personal Phalanx

        ---------------------------------
        -- Weapon: Burning Dual Blades --
        ---------------------------------
        -- Burning Dual Blades
        bladeswarn = {
            varname = format(L.alert["%s Warning"],SN[74981]),
            text = format(L.alert["He chose %s!"],SN[74981]),
            icon = ST[74981],
        },
        bladesduration = {
            varname = format(L.alert["%s Duration"],SN[74981]),
            text = format(L.alert["%s"],SN[74981]),
            time = 30,
            icon = ST[74981],
        },
        -- Burning Flames
        flameswarn = {
            varname = format(L.alert["%s Warning"],SN[90764]),
            time = 1,
            icon = ST[90764],
        },
        -- Disorienting Roar
        roarwarn = {
            varname = format(L.alert["%s Warning"],SN[74976]),
            text = format(L.alert["%s"],SN[74976]),
            icon = ST[74976],
        },
        ---------------------------
        -- Weapon: The Huge Mace --
        ---------------------------

        -- Slam
        slamcd = {
            varname = format(L.alert["%s Warning"],SN[75057]),
            text = format(L.alert["Next %s"],SN[75057]),
            icon = ST[75057],
        },
        slamwarn = {
            varname = format(L.alert["%s Warning"],SN[75057]),
            icon = ST[75057],
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
            spellname = 74981,
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
            spellname = 74976,
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
            spellname = 75057,
            execute = {
                {
                    "quash","slamcd",
                    "alert","slamcd",
                    "set",{slamtext = format(L.alert["%s on <%s>"],SN[75057],"#5#")},
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
})

DXE:RegisterRealmPatch(realm, "drahga", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        spiritcd = {
            varname = format(L.alert["%s CD"],"Flaming Spirit"),
            text = format(L.alert["New %s"],"Flaming Spirit"),
            time = 20,
            time2 = 10.5,
            time3 = 19,
            --time = "<spiritcd>",
            icon = ST[2894],
        },
        -- Seeping Twilight
        seepingcd = {
            varname = format(L.alert["%s CD"],SN[75317]),
            text = format(L.alert["Next %s"],SN[75317]),
            time = "<seepingcd>",
            icon = ST[75271],
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
            spellname = 75271,
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
            spellname = 75317,
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
})

DXE:RegisterRealmPatch(realm, "erudax", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        galecd = {27, 35, loop = false, type = "series"},
        bindingcd = {14, 0, loop = true, type = "series"},
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
    raidicons = {
        bindingmark = {
            varname = format("%s {%s}",SN[79466],"ABILITY_TARGET_HARM"),
            type = "FRIENDLY",
            persist = 5,
            unit = "<bindingunit>",
            reset = 10,
            icon = 1,
            texture = ST[79466],
        },
    },
    alerts = {
        -- Feeble Body
        feeblewarn = {
            varname = format(L.alert["%s Warning"],SN[75792]),
            icon = ST[75792],
        },
        -- Binding Shadows
        bindingcd = {
            varname = format(L.alert["%s CD"],SN[79466]),
            text = format(L.alert["Next %s"],SN[79466]),
            time = 13,
            time2 = 9,
            time3 = 18,
            icon = ST[79466],
        },
        bindingcast = {
            varname = format(L.alert["%s Warning"],SN[79466]),
            text = format(L.alert["%s"],SN[79466]),
            time = 1.5,
            icon = ST[79466],
        },
        bindingaffectedwarn = {
            varname = format(L.alert["%s Affected Warning"],SN[79466]),
            text = format(L.alert["%s on %s"],SN[79466],"&list|binding_units&"),
            icon = ST[79466],
        },
        -- Shadow Gale
        galecd = {
            varname = format(L.alert["%s CD"],SN[75694]),
            text = format(L.alert["Next %s"],SN[75694]),
            icon = ST[75694],
        },
        galewarn = {
            varname = format(L.alert["%s Warning"],SN[75694]),
            text = format(L.alert["Charging up %s"],SN[75694]),
            icon = ST[75694],
        },
        galeduration = {
            varname = format(L.alert["%s Duration"],SN[75694]),
            text = format(L.alert["%s"],SN[75694]),
            time = 10,
            icon = ST[75694],
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
    events = {
        -- Feeble Body
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 75792,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{feebletext = format(L.alert["%s on %s"],SN[75792],L.alert["YOU"])},
                    "alert","feeblewarn",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{feebletext = format(L.alert["%s on <%s>"],SN[75792],"#5#")},
                    "alert","feeblewarn",
                },
            },
        },
        -- Binding Shadows
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = {79466, 75861, 91081},
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
                    "alert","bindingcd",
                },
            },
        },
        -- Binding Shadows (affected)
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 79466,
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
            spellname = 75694,
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
})

DXE:RegisterRealmPatch(realm, "grimbatoltrash", {
    windows = {
        proxwindow = false,
    },
    raidicons = {
        shieldmark = {
            varname = format("%s {%s-%s}",SN[76314],"ENEMY_BUFF","Crimsonborne Seer's"),
            texture = ST[76314],
        },
        visagemark = {
            varname = format("%s {%s-%s}",SN[76626],"ENEMY_CAST","Azureborne Warlord's"),
            type = "ENEMY",
            persist = 3,
            unit = "#1#",
            reset = 4,
            icon = 2,
            texture = ST[76626],
        },
    },
    alerts = {
        -- Blazing Twilight Shield
        shieldwarn = {
            varname = format(L.alert["%s Warning"],SN[76314]),
            text = format(L.alert["%s"],SN[76314]),
            time = 6,
            icon = ST[76314],
        },
        shieldcd = {
            varname = format(L.alert["%s CD"],SN[76314]),
            text = format(L.alert["Next %s"],SN[76314]),
            time = 20,
            icon = ST[76314],
        },
        -- Conjure Twisted Visage
        visagewarn = {
            varname = format(L.alert["%s Warning"],SN[76626]),
            text = format(L.alert["%s"],SN[76626]),
            time = 4,
            flashtime = 4,
            icon = ST[76626],
        },
        visagecd = {
            varname = format(L.alert["%s CD"],SN[76626]),
            text = format(L.alert["Next %s"],SN[76626]),
            time = 16,
            icon = ST[76626],
        },
    },
    events = {
        -- Blazing Twilight Shield
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 76314,
            execute = {
                {
                    "set",{shieldtext = format(L.alert["%s on %s"],SN[76314],"#5#")},
                    "alert","shieldwarn",
                    "alert","shieldcd",
                    "raidicon","shieldmark",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 76314,
            execute = {
                {
                    "expect",{"&difficulty&","==","1"},
                    "set",{shieldtext = format(L.alert["%s on %s"],SN[76314],"#5#")},
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
            spellname = 76314,
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
            spellname = 76626,
            execute = {
                {
                    "set",{visagetext = format(L.alert["%s: %s - INTERRUPT!"],"#2#",SN[76626])},
                    "alert","visagewarn",
                    "alert","visagecd",
                    "raidicon","visagemark"
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 76626,
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
})
