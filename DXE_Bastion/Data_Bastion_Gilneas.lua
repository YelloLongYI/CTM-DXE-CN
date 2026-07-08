-- Data_Bastion_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

if DXE.db.profile.Globals.Realm == realm and L.chat_bastion then
    for k in pairs(L.chat_bastion) do
        L.chat_bastion[k] = k
    end
end

DXE:RegisterRealmPatch(realm, "halfus", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        scorchingbreathcd = {11, 23, 21, loop = false, type = "series"},
        whelpsreleased = "no",
        furiouscount = 0,
        novacast = 0.25,
    },
    alerts = {
        -- Shadow Nova
        novacd = {
            varname = format(L.alert["%s CD"],SN[38627]),
            text = format(L.alert["Next %s"],SN[38627]),
            time = 12,
            time2 = 8,
            time3 = "<novadelayed>",
            icon = ST[38627],
        },
        novawarn = {
            varname = format(L.alert["%s Warning"],SN[38627]),
            text = format(L.alert["%s - INTERRUPT"],SN[38627]),
            icon = ST[38627],
        },
        novacast = {
            varname = format(L.alert["%s Cast"],SN[38627]),
            text = format(L.alert["%s"],SN[38627]),
            time = "<novacast>",
            icon = ST[38627],
        },
        -- Scorching Breath
        scorchingbreathdurwarn = {
            varname = format(L.alert["%s Duration"], SN[83707]),
            text = format(L.alert["%s"], SN[83707]),
            time = 8,
            icon = ST[83707],
        },
        scorchingbreathcd = {
            varname = format(L.alert["%s CD"], SN[83707]),
            text = format(L.alert["%s CD"], SN[83707]),
            time = 6,
            time2 = 20,
            icon = ST[83707],
        },
        -- Furious Roar
        furiouscd = {
            varname = format(L.alert["%s CD"],SN[83710]),
            text = format(L.alert["Next %s"],SN[83710]),
            time = 23.5,
            flashtime = 10,
            icon = ST[83710],
        },
        furiouswarn = {
            varname = format(L.alert["%s Cast Warning"],SN[83710]),
            text = format(L.alert["%s"],SN[83710]),
            time = 6.5,
            icon = ST[83710],
        },
        -- Bind Will
        bindwarn = {
            varname = format(L.alert["%s Warning"],SN[83432]),
            text = "<bindtext>",
            time = 1,
            icon = "<bindicon>",
            tag = "#4#",
        },
        
        -- Paralysis
        paralysiswarn = {
            varname = format(L.alert["%s Duration"],SN[84030]),
            warningtext = format(L.alert["%s"],SN[84030]),
            text = format(L.alert["%s fades"],SN[84030]),
            time = 12,
            icon = ST[84030],
        },
    },
    events = {
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 83432, -- Bind Will
            execute = {
                -- Releasing Storm Rider
                {
                    "expect",{"#5#","==","Storm Rider"},
                    "set",{bindicon = "Interface\\ICONS\\inv_misc_stormdragonpale"},
                    "set",{novacast = 3},
                    "expect",{"&difficulty&","<=","2"},
                    "alert","novacd",
                },
                -- Releasing Time Warden
                {
                    "expect",{"#5#","==","Time Warden"},
                    "set",{bindicon = "Interface\\ICONS\\Ability_Mount_Drake_Bronze"},
                },
                -- Releasing Slate Dragon
                {
                    "expect",{"#5#","==","Slate Dragon"},
                    "set",{bindicon = "Interface\\ICONS\\inv_misc_stonedragonblue"},
                },
                -- Releasing Nether Scion
                {
                    "expect",{"#5#","==","Nether Scion"},
                    "set",{bindicon = "Interface\\ICONS\\Ability_Mount_NetherdrakePurple"},
                },
                -- Releasing Orphaned Emerald Whelps
                {
                    "expect",{"#5#","==","Orphaned Emerald Whelp"},
                    "expect",{"<whelpsreleased>","==","no"},
                    "set",{
                        whelpsreleased = "yes",
                        whelpscount = 8,
                        bindicon = "Interface\\ICONS\\INV_Misc_Head_Dragon_Green",
                    },
                    "set",{bindtext = format(L.alert["%s: Released!"],"Orphaned Emerald Whelps")},
                    "alert","bindwarn",
                    "counter","whelpscounter",
                    "expect",{"&difficulty&","<=","2"},
                    "alert","scorchingbreathcd",
                },
                -- Dragon's tracing
                {
                    "expect",{"#5#","~=","Orphaned Emerald Whelp"},
                    "set",{bindtext = format(L.alert["%s: Released!"],"#5#")},
                    "alert","bindwarn",
                    "temptracing","#4#",
                },
            },
        },
        -- Scorching Breath
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 83707,
            execute = {
                {
                    "quash","scorchingbreathcd",
                    -- "schedulealert",{"scorchingbreathcd",2},
                    "alert", {"scorchingbreathcd", time = 2},
                    "schedulealert",{"scorchingbreathdurwarn",2}
                },
            },
        },
        -- Shadow Nova
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 38627,
            execute = {
                {
                    "quash","novacd",
                    "alert","novacd",
                    "alert","novawarn",                        
                    "alert","novacast",
                },
            },
        },
        -- Orphaned Emerald Whelp dies
        {
            type = "combatevent",
            eventtype = "UNIT_DIED",
            execute = {
                {
                    "expect",{"#5#","==","Orphaned Emerald Whelp"},
                    "set",{whelpscount = "DECR|1"},
                },
                {
                    "expect",{"<whelpscount>","==","0"},
                    "removecounter","whelpscounter",
                },
            },
        },
        -- Furious Roar
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 83710,
            execute = {
                {
                    "set",{furiouscount = "INCR|1"},
                    "expect",{"<furiouscount>","==","3"},
                    "set",{furiouscount = 0},
                    "schedulealert",{"furiouscd", 1.5},
                },
                {
                    "expect",{"<furiouscount>","==","1"},
                    "alert","furiouswarn",
                },
            },
        },
        -- Paralysis
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 84030,
            execute = {
                {
                    "expect",{"&npcid|#1#&","==","44600"},
                    "expect",{"&npcid|#4#&","==","44600"},
                    "alert","paralysiswarn",
                    "expect",{"&timeleft|novacd&",">","0"},
                    "set",{novadelayed = "&timeleft|paralysiswarn&"},
                    "quash","novacd",
                    "alert",{"novacd",time = 3},
                },
            },
        },
        
    },
})

DXE:RegisterRealmPatch(realm, "valther", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        blackoutcd = {45.5, 45.5, 0, loop = false, type = "series"},
        dazzlecd = {80, 82.35, loop = false, type = "series"},
    },
    raidicons = {
        blackoutmark = {
            varname = format("%s {%s}",SN[86788],"PLAYER_DEBUFF"),
            type = "FRIENDLY",
            total = 3,
            persist = 15,
            unit = "#5#",
            icon = 1,
            texture = ST[86788],
        },
        engulfmark = {
            varname = format("%s {%s}",SN[86622],"PLAYER_DEBUFF"),
            type = "MULTIFRIENDLY",
            persist = 20,
            unit = "#5#",
            icon = 2,
            reset = 3, -- Looks like 2 on 25 man, TODO: Check for 10 man count
            total = 3,
            texture = ST[86622],
        },
    },
    alerts = {
        -- Twilight Shift
        shiftcd = {
            varname = format(L.alert["%s CD"],SN[93051]),
            type = "dropdown",
            text = "<shifttext>",
            time = 20,
            flashtime = 5,
            color1 = "PINK",
            icon = ST[93051],
        },
        -- Berserk
        enragecd = {
            varname = L.alert["Berserk CD"],
            type = "dropdown",
            text = L.alert["Berserk"],
            time = 600,
            flashtime = 10,
            color1 = "RED",
            icon = ST[12317],
        },
        ------------------------
        -- Theralion Airborne --
        ------------------------
        -- Blackout
        blackoutcd = {
            varname = format(L.alert["%s CD"],SN[86788]),
            text = format(L.alert["Next %s"],SN[86788]),
            time = "<blackoutcd>",
            time2 = 10.7,
            time3 = 9,
            icon = ST[86788],
        },
        blackoutselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[86788]),
            warningtext = format("%s on %s!",SN[86788],L.alert["YOU"]),
            text = format("%s on %s",SN[86788],L.alert["YOU"]),
            time = 15,
            icon = ST[86788],
        },
        blackoutdurationwarn = {
            varname = format(L.alert["%s Warning"],SN[86788]),
            text = format("%s on <#5#>!",SN[86788]),
            time = 15,
            icon = ST[86788],
        },
        -- Devouring Flames
        flamewarn = {
            varname = format(L.alert["%s Casting"],SN[86840]),
            type = "centerpopup",
            text = format(L.alert["%s"],SN[86840]),
            time = 2.5,
            flashtime = 2.5,
            icon = ST[86840],
        },
        flamecd = {
            varname = format(L.alert["%s CD"],SN[86840]),
            type = "dropdown",
            text = format(L.alert["%s CD"],SN[86840]),
            time = 40,
            time2 = 25.75,
            flashtime = 5,
            icon = ST[86840],
        },
        -- Dazzling Destruction
        dazzlewarn = {
            varname = format(L.alert["%s Casting"],SN[86406]),
            text = format(L.alert["Theralion: %s"],SN[86406]),
            icon = ST[86406],
        },
        dazzlecd = {
            varname = format(L.alert["%s CD"],SN[86406]),
            text = format(L.alert["Next %s"],SN[86406]),
            time = "<dazzlecd>",
            icon = ST[86406],
        },
        ----------------------
        -- Valiona Airborne --
        ----------------------
        -- Deep Breath
        breathcd = {
            varname = format(L.alert["%s CD"],SN[86059]),
            type = "dropdown",
            text = format(L.alert["%s CD"],SN[86059]),
            time = 129,
            flashtime = 0,
            icon = ST[85664],
        },
        breathwarn = {
            varname = format(L.alert["%s Warning"],SN[86059]),
            text = format(L.alert["Valiona is preparing for %s"],SN[86059]),
            time = 5,
            icon = ST[85664],
        },
        -- Engulfing Magic
        engulfcd = {
            varname = format(L.alert["%s CD"],SN[86622]),
            text = format(L.alert["%s CD"],SN[86622]),
            time = 35,
            time2 = 31,
            icon = ST[86622],
        },
        engulfselfduration = {
            varname = format(L.alert["%s on me Duration"],SN[86622]),
            text = format("%s on %s",SN[86622],L.alert["YOU"]),
            time = 20,
            icon = ST[86622],
        },
        engulfwarn = {
            varname = format(L.alert["%s Warning"],SN[86622]),
            text = format(L.alert["%s on %s"],SN[86622],"&list|engulfunits&"),
            time = 20,
            icon = ST[86622],
        },
        -- Twilight Meteorite
        meteoriteselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[88518]),
            text = format(L.alert["%s on %s"],SN[88518],L.alert["YOU"]),
            time = 6,
            icon = ST[88518],
        },
        -- Fabulous Flames
        fabulousselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[86505]),
            text = format(L.alert["%s on %s - GET AWAY!"],SN[86505],L.alert["YOU"]),
            icon = ST[86505],
        },
    },
    events = {
        -- Twilight Shift on Tanks
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = 93051,
            execute = {
                {
                    "quash","shiftcd",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{shifttext = format("%s on <%s>",SN[93051],L.alert["YOU"])},
                    "alert","shiftcd",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{shifttext = format("%s on <#5#>",SN[93051])},
                    "alert","shiftcd",
                },
            },
        },
        -- Twilight Shift Dose on Tanks
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED_DOSE",
            spellid = 93051,
            execute = {
                {
                    "quash","shiftcd",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{shifttext = format("%s (%s) on %s",SN[93051],"#11#",L.alert["YOU"])},
                    "alert","shiftcd",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{shifttext = format("%s (%s) on <%s>",SN[93051],"#11#","#5#")},
                    "alert","shiftcd",
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
                    "alert","flamewarn",
                    "set",{breathwarned = "no"},
                    "quash","flamecd",
                    "alert","flamecd",
                    "expect",{"<dazzlingwarned>","==","yes"},
                    "set",{dazzlingwarned = "no"},
                },
            },
        },
        -- Dazzling Destruction
        {                                             
            type = "combatevent",
            -- eventtype = "SPELL_CAST_START",
            eventtype = "SPELL_CAST_SUCCESS", --TODO: need confirm
            spellname = {86408, 86406},
            execute = {
                {
                    "expect",{"<dazzlingwarned>","==","no"},
                    "set",{dazzlingwarned = "yes"},
                    "quash","flamecd",
                    "quash","dazzlecd",
                    "alert","dazzlewarn",
                    "expect",{"<breathwarned>","==","no"},
                    "alert","breathcd",
                    "set",{breathwarned = "yes"},
                    "alert",{"engulfcd",time = 2},
                },
            },
        },
        -- Engulfing Magic
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 86622,
            execute = {
                {
                    "raidicon","engulfmark",
                    "radar","engulfradar",
                    "expect",{"&timeleft|engulfcd&","<","1"},
                    "quash","engulfcd",
                    "alert","engulfcd",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "insert",{"engulfunits","#5#"},
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "insert",{"engulfunits",L.alert["YOU"]},
                },
                {
                    "expect",{"&listsize|engulfunits&","==","1"},
                    "scheduletimer",{"engulftimer",2},
                },
                {
                    "expect",{"&listsize|engulfunits&","==","<engulfmax>"},
                    "canceltimer","engulftimer",
                    "alert","engulfwarn",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","engulfselfduration",
                },
            },
        },
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 86622,
            execute = {
                {
                    "removeradar",{"engulfradar", player = "#5#"},
                    "removeraidicon",{"#5#"}
                },
            },
        },
        {
            type = "event",
            event = "EMOTE",
            execute = {
                {
                    "expect",{"#1#","find",L.chat_bastion["begins to cast .+%[Engulfing Magic%].+"]},
                    "expect",{"&timeleft|engulfcd&","<","1"},
                    "quash","engulfcd",
                    "alert","engulfcd",
                },
            },
        },
        -- Blackout
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 86788,
            execute = {
                {
                    "raidicon","blackoutmark",
                    "quash","blackoutcd",
                    "alert","blackoutcd",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","blackoutselfwarn",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "alert","blackoutdurationwarn",
                    "arrow","blackoutarrow",
                },
            },
        },
        -- Blackout removal
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 86788,
            execute = {
                {
                    "quash","blackoutdurationwarn",
                    "quash","blackoutselfwarn",
                    "removeraidicon","#5#",
                    "removearrow","#5#",
                    "removeradar",{"blackoutradar", player = "#5#"},
                },
            },
        },
        -- Twilight Meteorite
        {
            type = "event",
            event = "UNIT_AURA",
            execute = {
                {
                    "expect",{"#1#","==","player"},
                    "scheduletimer",{"firemeteorite",0.1},
                },
            },
        },
        -- Twilight Blast
        {
            type = "event",
            event = "UNIT_SPELLCAST_START",
            execute = {
                {
                    "expect",{"#2#","==",SN[86369]},
                    "expect",{"#1#","find","boss"},
                    "set",{
                        castingblast = "yes",
                        blastsource = "#1#",
                    },
                    "scheduletimer",{"blasttimer", 0.5},
                    "expect",{"<firstblastcast>","==","no"},
                    "set",{firstblastcast = "yes"},
                    "alert","dazzlecd",
                    "quash","engulfcd",
                    "expect",{"&timeleft|blackoutcd&","==","-1"},
                    "alert",{"blackoutcd",time = 3},
                },
            },
        },
        {
            type = "event",
            event = "UNIT_TARGET",
            execute = {
                {
                    "expect",{"<castingblast>","==","yes"},
                    "expect",{"#1#","==","<blastsource>"},
                    "expect",{"&unitguid|<blastsource>target&","==","&playerguid&"},
                    "canceltimer","blasttimer",
                    "announce","blastsay",
                    "set",{castingblast = "no"},
                },
            },
        },
        -- Deep Breath
        {
            type = "event",
            event = "YELL",
            execute = {
                {
                    "expect",{"#1#","find","I will engulf the Hallway"},
                    "alert","breathwarn",
                    "set",{
                        firstblastcast = "no",
                        blackoutcd = {45.5, 0, loop = false, type = "series"}
                    },
                },
            },
        },
        -- Fabulous Flames
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 86505,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","fabulousselfwarn",
                },
            },
        },
        
    },
})

DXE:RegisterRealmPatch(realm, "ascendcouncil", {
    windows = {
        proxwindow = false,
    },
    arrows = {
        blinkarrow = {
            varname = format("%s %s",L.npc_bastion["Arion"],SN[83070]),
            spell = SN[83070],
            texture = ST[83070],
        },
        overloadgravityarrow = {
            varname = format("%s / %s partner", "Overload", "Gravity"),
            unit = "<firstOverloadGravity>",
            persist = 30,
            action = "TOWARD",
            msg = L.alert["MOVE TOWARD"],
            spell = "<overloadGravitySpellName>",
            texture = ST[92067],
        },
    },
    onstart = {
        {
            "expect",{"&difficulty&",">=","3"}, --10h&25h
            "set",{
                coretext = "",
                overloadtext = "",
                beacontext = "",
            },
        },
        {
            "expect",{"&difficulty&","==","2"},
            "set",{
                rodmax = 3,
                crushmax = 3,
            },
        },
        {
            "expect",{"&difficulty&","==","4"},
            "set",{
                rodmax = 3,
                crushmax = 3,
            },
        },
        {
            "set",{phase = 1},
            "alert",{"aegiscd",time = 2},
            "alert",{"waterbombcd",time = 2, text = 2},
        },
    },
    alerts = {
        -- Phase 3 transition
        phasetransition = {
            varname = format(L.alert["%s Transition Countdown"],"Phase 3"),
            text = format(L.alert["%s transition"],"Phase 3"),
            time = 14.8,
            icon = ST[11242],
        },
        
        -----------------------
        ------- Phase 1 -------
        -----------------------
        -- Burning Blood
        bloodwarn = {
            varname = format(L.alert["%s Warning"],SN[82660]),
            text = "<bloodtext>",
            time = 30,
            flashtime = 30,
            icon = ST[82660],
        },
        -- Heart of Ice
        icewarn = {
            varname = format(L.alert["%s Warning"],SN[82665]),
            text = "<icetext>",
            time = 30,
            flashtime = 30,
            icon = ST[82665],
        },
        -- Water Bomb
        waterbombcd = {
            varname = format(L.alert["%s CD"], SN[82699]),
            text = format(L.alert["%s CD"], SN[82699]),
            text2 = format(L.alert["Next %s"], SN[82699]),
            time = 28,
            time2 = 15.5,
            flashtime = 5,
            icon = ST[82699],
        },
        waterbombwarn = {
            varname = format(L.alert["%s Warning"], SN[82699]),
            text = format(L.alert["%s"], SN[82699]).."s",
            icon = ST[82699],        
        },
        -- Waterlogged
        waterlogged = {
            varname = format(L.alert["%s on me Warning"],SN[82762]),
            text = format(L.alert["%s on %s"],SN[82762],L.alert["YOU"]),
            time = 5,
            icon = ST[82762],
        },
        -- Glaciate
        glaciatewarn = {
            varname = format(L.alert["%s Casting"],SN[82746]),
            text = format(L.alert["%s"],SN[82746]),
            icon = ST[82746],
        },
        glaciatecd = {
            varname = format(L.alert["%s CD"],SN[82746]),
            text = format(L.alert["Next %s"],SN[82746]),
            time = 15,
            icon = ST[82746],
        },
        -- Aegis of Flame
        aegiswarn = {
            varname = format(L.alert["%s Warning"],SN[82631]),
            type = "simple",
            text = format(L.alert["%s"],SN[82631]),
            time = 10,
            icon = ST[82631],
        },
        aegiscd = {
            varname = format(L.alert["%s CD"],SN[82631]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[82631]),
            time = 60,
            time2 = 30,
            icon = ST[82631],
        },
        aegisabsorb = {
            varname = format(L.alert["%s Absorbs"],SN[82631]),
            text = "",
            textformat = format("%s (%%s/%%s - %%d%%%%)","Shield"),
            time = 21.5,
            icon = ST[82631],
            npcid = 43686,
            values = {
                -- [82631] = "<aegisamount>", --10n
                -- [92513] = "<aegisamount>", --10h
                -- [92512] = "<aegisamount>", --25n
                -- [92514] = "<aegisamount>", --25h
                [82631] = 500000, --10n
                [92513] = 700000, --10h
                [92512] = 1500000, --25n
                [92514] = 2000000, --25h
            },
        },
        risingflameskickwarn = {
            varname = format(L.alert["%s Interrupt Warning"],SN[82643]),
            text = format(L.alert["%s: %s - INTERRUPT"],"Ignacious", SN[82643]),
            icon = ST[82643],
        },      
        frostboltwarn = {
            varname = format(L.alert["%s Casting"],SN[82752]),
            text = format(L.alert["%s"],SN[82752]),
            icon = ST[82752],
            enabled = {
                Tank = true,
            },
        },    
        -----------------------
        ------- Phase 2 -------
        -----------------------
        -- Harden Skin
        hardencd = {
            varname = format(L.alert["%s CD"],SN[83718]),
            text = format(L.alert["%s CD"],SN[83718]),
            time = 40,
            time2 = 5,
            icon = ST[83718],
        },
        hardenkickwarn = {
            varname = format(L.alert["%s Interrupt Warning"],SN[83718]),
            text = format(L.alert["%s: %s - INTERRUPT"],"Terrastra",SN[83718]),
            icon = ST[83718],
        },
        -- Lightning Blast
        lightningkickwarn = {
            varname = format(L.alert["%s Interrupt Warning"],SN[83070]),
            text = format(L.alert["%s: %s - INTERRUPT"],"Arion",SN[83070]),
            time = 2.5,
            icon = ST[83070],
        },
        -- Lightning Rod
        rodwarn = {
            varname = format(L.alert["%s Warning"],SN[83099]),
            text = format(L.alert["%s on %s"],SN[83099],"&list|rodunits&"),
            icon = ST[83099],
        },
        rodself = {
            varname = format(L.alert["%s Warning on me Warning"],SN[83099]),
            text = format(L.alert["%s on <%s>"],SN[83099],L.alert["YOU"]),
            time = 15,
            flashtime = 15,
            icon = ST[83099],
        },
        -- Quake
        quakecd = {
            varname = format(L.alert["%s CD"],SN[83565]),
            time = 65, -- TODO Need confirm
            time2 = 30,
            flashtime = 7.5,
            icon = ST[83565],
        },
        getwindswarn = {
            varname = "Get Winds Warning",
            text = "Get Winds!",
            time = 5,
            icon = ST[8385],
        },
        -- Thundershock
        shockcd = {
            varname = format(L.alert["%s CD"],SN[83067]),
            text = "Get Grounded",
            time = 30,
            flashtime = 7.5,
            icon = ST[83067],
        },
        getgroundedwarn = {
            varname = "Get Grounded Warning",
            text = "Get Grounded!",
            time = 5,
            icon = ST[1604],
        },
        -----------------------
        ------- Phase 3 -------
        -----------------------
        -- Gravity Crush
        crushcd = {
            varname = format(L.alert["%s CD"],SN[84948]),
            text = format(L.alert["%s CD"],SN[84948]),
            time = 24,
            time2 = 39,
            icon = ST[84948],
        },
        crushwarn = {
            varname = format(L.alert["%s Warning"],SN[84948]),
            text = format(L.alert["%s on %s"],SN[84948],"&list|crushunits&"),
            time = 6.5,
            icon = ST[84948],
        },
        crushduration = {
            varname = format(L.alert["%s Duration"],SN[84948]),
            text = format(L.alert["%s"],SN[84948]),
            icon = ST[84948],
        },
        -- Lava Seed
        lavaseedcd = {
            varname = format(L.alert["%s CD"], SN[84913]),
            text = format(L.alert["%s CD"], SN[84913]),
            time = 22,
            time2 = 31,
            flashtime = 5,
            icon = ST[84913],
        },
        lavaseedwarn = {
            varname = format(L.alert["%s Warning"], SN[84913]),
            text = format(L.alert["%s"], SN[84913]).."!",
            time = 2,
            icon = ST[84913],
        },
        -------------------------------
        ---- Heroic mode - Phase 1 ----
        -------------------------------

        -- Static Overload
        overloadwarn = {
            varname = format(L.alert["%s Warning"],SN[92067]),
            type = "centerpopup",
            text = "<overloadtext>",
            time = 10,
            color1 = "YELLOW",
            icon = ST[92067],
            sound = "ALERT4",
        },
        overloadselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[92067]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[92067],L.alert["YOU"]),
            time = 10,
            color1 = "YELLOW",
            icon = ST[92067],
            sound = "ALERT1",
            flashscreen = true,
            emphasizewarning = true,
        },
        -- Gravity Core
        corewarn = {
            varname = format(L.alert["%s Warning"],SN[92075]),
            type = "centerpopup",
            text = "<coretext>",
            time = 10,
            color1 = "YELLOW",
            icon = ST[92075],
            sound = "MINORWARNING",
        },
        coreselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[92075]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[92075],L.alert["YOU"]),
            time = 10,
            color1 = "WHITE",
            icon = ST[92075],
            sound = "ALERT1",
            flashscreen = true,
            emphasizewarning = true,
        },
        -------------------------------
        ---- Heroic mode - Phase 2 ----
        -------------------------------
        -- Frost Beacon
        beaconwarn = {
            varname = format(L.alert["%s Warning"],SN[92307]),
            type = "simple",
            text = "<beacontext>",
            time = 5,
            color1 = "GOLD",
            icon = ST[92307],
            sound = "MINORWARNING",
        },
        beaconselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[92307]),
            type = "simple",
            text = format(L.alert["%s on %s"],SN[92307],L.alert["YOU"]),
            time = 5,
            color1 = "GOLD",
            icon = ST[92307],
            sound = "RUNAWAY",
            flashscreen = true,
            emphasizewarning = true,
        },
    },
    events = {
        -- Ignacious
        -- Burning Blood
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 82660,
            srcisnpctype = true,
            execute = {
                {
                    "raidicon","bloodmark",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{bloodtext = format(L.alert["%s on <%s>"],SN[82660],L.alert["YOU"])},
                    "alert","bloodwarn",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{bloodtext = format(L.alert["%s on <%s>"],SN[82660],"#5#")},
                    "alert","bloodwarn",
                },
            },
        },
        -- Burning Blood removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 82660,
            execute = {
                {
                    "removeraidicon","#5#",
                    "quash","bloodwarn",
                },
            },
        },
        -- Aegis (Shield)
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = {92512, 82631},
            execute = {
                -- {
                --     "expect",{"&difficulty&","==","1"},
                --     "set",{aegisamount = 500000},
                -- },
                -- {
                --     "expect",{"&difficulty&","==","2"},
                --     "set",{aegisamount = 1500000},
                -- },
                -- {
                --     "expect",{"&difficulty&","==","3"},
                --     "set",{aegisamount = 700000},
                -- },
                -- {
                --     "expect",{"&difficulty&","==","4"},
                --     "set",{aegisamount = 2000000},
                -- },
                {
                    "quash","aegiscd",
                    "alert","aegiswarn",
                    "alert","aegisabsorb",
                    "alert","aegiscd",
                },
            },
        },
        -- Aegis removed -> Kick
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = {92512, 82631},
            execute = {
                {
                    "quash","aegiswarn",
                    "quash","aegisabsorb",
                    "alert","risingflameskickwarn",
                },
            },
        },
        -- Water Bomb
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 82699,
            execute = {
                {
                    "alert","waterbombwarn",
                    "quash","waterbombcd",
                    "alert","waterbombcd",
                    "alert","glaciatecd",
                },
            },
        },
        -- Feludius
        -- Heart of Ice
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 82665,
            execute = {
                {
                    "raidicon","icemark",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{icetext = format(L.alert["%s on <%s>"],SN[82665],L.alert["YOU"])},
                    "alert","icewarn",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{icetext = format(L.alert["%s on <%s>"],SN[82665],"#5#")},
                    "alert","icewarn",
                },
            },
        },
        -- Heart of Ice removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 82665,
            execute = {
                {
                    "removeraidicon","#5#",
                    "quash","icewarn",
                },
            },
        },
        -- Waterlogged self
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 82762,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","waterlogged",
                },
            },
        },
        -- Glaciate
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 82746,
            execute = {
                {
                    "quash","glaciatecd",
                    "alert","glaciatewarn"
                },
            },
        },
        
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 82752,
            execute = {
                {
                    "alert","frostboltwarn"
                },
            },
        },
        -- Phase 2 Trigger
        {
            type = "event",
            event = "YELL",
            execute = {
                {
                    "expect",{"#1#","find",L.chat_bastion["^Enough of this foolishness"]},
                    "set",{phase = 2},
                    "alert","phasewarn",
                    "quash","aegiscd",
                    "quash","glaciatecd",
                    "quash","waterbombcd",
                    "alert",{"quakecd",time = 2},
                    "alert",{"hardencd",time = 2},
                    "schedulealert",{"getwindswarn",15}
                },
            },
        },
        -- Terrastra
        -- Harden Skin
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 83718,
            execute = {
                {
                    "quash","hardencd",
                    "alert","hardenkickwarn",
                    "alert","hardencd",
                },
            },
        },
        -- Quake
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = {92544, 83565},
            execute = {
                {
                    "quash","quakecd",
                    "alert","shockcd",
                    "schedulealert",{"getgroundedwarn",5}
                },
            },
        },
        -- Arion
        -- Lightning Rod
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 83099,
            execute = {
                {
                    "raidicon","rodmark",
                    "radar","rodradar",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "insert",{"rodunits",L.alert["YOU"]},
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "insert",{"rodunits","#5#"},
                },
                {
                    "expect",{"&listsize|rodunits&","==","1"},
                    "scheduletimer",{"rodtimer",1},
                }, 
                {
                    "expect",{"&listsize|rodunits&","==","<rodmax>"},
                    "canceltimer","rodtimer",
                    "alert","rodwarn",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "announce","rodsay",
                    "alert","rodself",
                },
            },
        },
        -- Lightning Rod removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 83099,
            execute = {
                {
                    "removeraidicon","#5#",
                    "removeradar",{"rodradar", player = "#5#"},
                },
            },
        },
        -- Thundershock
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = {92469, 83067},
            execute = {
                {
                    "quash","shockcd",
                    "alert","quakecd",
                    "schedulealert",{"getwindswarn",5}
                },
            },
        },
        -- Lightning Blast (only Arrow)
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 83087,
            execute = {
                {
                    "schedulealert",{"lightningkickwarn", 1.5},
                    "scheduletimer",{"blink",2},
                },
            },
        },
        -- Phase 3 Trigger
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 82285,
            execute = {
                {
                    "expect",{"<phase>","<","3"},
                    "quashall",true,
                    "set",{phase = 3},
                    "alert","phasetransition",
                },
            },
        },
        {
            type = "event",
            event = "YELL",
            execute = {
                {
                    "expect",{"#1#","find",L.chat_bastion["^BEHOLD YOUR DOOM"]},
                    "alert",{"crushcd",time = 2},
                    "alert",{"lavaseedcd",time = 2},
                    "alert","phasewarn",
                    "tracing",{43735}, -- Monstrosity
                    "hidephasemarker",{1,1},
                },
            },
        },
        
        -- Gravity Crush
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = {92486, 84948}, -- need confirm
            execute = {
                {
                    "raidicon","crushmark",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "insert",{"crushunits",L.alert["YOU"]},
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "insert",{"crushunits","#5#"},
                },
                {
                    "expect",{"&listsize|crushunits&","==","1"},
                    "scheduletimer",{"crushtimer",1},
                    "quash","crushcd",
                    "alert","crushduration",
                    "alert","crushcd",
                },
                {
                    "expect",{"&listsize|crushunits&","==","<crushmax>"},
                    "canceltimer","crushtimer",
                    "alert","crushwarn",
                },
            },
        },
        -- Gravity crush removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 92486,
            execute = {
                {
                    "removeraidicon","#5#",
                },
            },
        },
        -- Lava Seed
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 84913,
            execute = {
                {
                    "alert","lavaseedwarn",
                    "quash","lavaseedcd",
                    "alert","lavaseedcd",
                },
            },
        },
    
        -- Heroic Events
        -- Static Overload
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = 92067,
            srcisnpctype = true,
            execute = {
                {
                    "expect",{"<firstOverloadGravityGUID>","==","&playerguid&"},
                    "set",{firstOverloadGravity = "#5#"},
                    "set",{overloadGravitySpellName = format("%s",SN[92067])},
                    "arrow","overloadgravityarrow",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "expect",{"<firstOverloadGravityGUID>","~=",""},
                    "set",{overloadGravitySpellName = format("%s",SN[92075])},
                    "arrow","overloadgravityarrow",
                },
                {
                    "set",{firstOverloadGravityGUID = "#4#"},
                    "set",{firstOverloadGravity = "#5#"},
                    "raidicon","overloadmark",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","overloadselfwarn",
                    "announce","overloadsay",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{overloadtext = format("%s on <#5#>!",SN[92067])},
                    "alert","overloadwarn",
                },
            },
        },
        -- Static Overload removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellid = 92067,
            execute = {
                {
                    "removeraidicon","#5#",
                    "quash","overloadwarn",
                    "set",{firstOverloadGravity = ""},
                    "set",{firstOverloadGravityGUID = ""},
                    "removearrow","#5#",
                },
            },
        },
        -- Gravity Core
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = 92075,
            srcisnpctype = true,
            execute = {
                {
                    "expect",{"<firstOverloadGravityGUID>","==","&playerguid&"},
                    "set",{firstOverloadGravity = "#5#"},
                    "set",{overloadGravitySpellName = format("%s",SN[92075])},
                    "arrow","overloadgravityarrow",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "expect",{"<firstOverloadGravityGUID>","~=",""},
                    "set",{overloadGravitySpellName = format("%s",SN[92067])},
                    "arrow","overloadgravityarrow",
                },
                {
                    "set",{firstOverloadGravityGUID = "#4#"},
                    "set",{firstOverloadGravity = "#5#"},
                    "raidicon","coremark",
                    "radar","coreradar",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","coreselfwarn",
                    "announce","coresay",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{coretext = format("%s on <#5#>!",SN[92075])},
                    "alert","corewarn",
                },
            },
        },
        -- Gravity Core removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellid = 92075,
            execute = {
                {
                    "removeraidicon","#5#",
                    "quash","corewarn",
                    "set",{firstOverloadGravity = ""},
                    "set",{firstOverloadGravityGUID = ""},
                    "removearrow","#5#",
                    "removeradar",{"coreradar", player = "#5#"},
                },
            },
        },
        -- Frost Beacon
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = 92307,
            execute = {
                {
                    "raidicon","beaconmark",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","beaconselfwarn",
                    "announce","beaconsay",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "set",{beacontext = format("%s on <#5#>!",SN[92307])},
                    "alert","beaconwarn",
                },
            },
        },
        -- Frost Beacon removed
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 92307,
            execute = {
                {
                    "removeraidicon","#5#",
                    "quash","beaconwarn",
                    "quash","beaconselfwarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "chogall", {
    windows = {
        proxwindow = false,
    },
    userdata = {
        adherenttime = {62, 91, loop = false, type = "series"},
        depravitycd = {19, 12, loop = false, type = "series"},
        crashcd = {12, 10, loop = false, type = "series"},
        creationstime = {5, 30, loop = false, type = "series"},
        conversiontime = 20,
        adherenttext = "Corrupting Adherent",
        firstfury = "yes",
        phase = 1,
        conversionmax = 2,
        conversionunits = {type = "container", wipein = 3},
    },
    triggers = {
        scan = {
            43324, -- Cho'gall
        },
        yell = "^Enough!",
    },
    onstart = {
        {
            "set",{phase = 1},
            "alert","enragecd",
            "alert", {"furycd", time = 2},
            "expect",{"&difficulty&",">=","3"}, --10h&25h
            "set",{
                adherenttime = {64, 92 ,loop = false, type = "series"},
                furycd = {63, 47, loop = false, type = "series"}
            },
        },
        {
            "alert", {"furycd", time = 2},
            "expect",{"&difficulty&","<","3"}, --10h&25h
            "set",{
                adherenttime = {64, 92 ,loop = false, type = "series"},
                furycd = {37.5, 45, loop = false, type = "series"}
            },
        },
        {
            "expect",{"&difficulty&","==","2"},
            "set",{conversionmax = 5},
        },
        {
            "expect",{"&difficulty&","==","4"},
            "set",{conversionmax = 5},
            adherenttext = "Corrupting Adherents",
        },
        {
            "alert",{"conversioncd",time = 2, text = 2},
            "repeattimer",{"checkhp", 1},
        },
    },
    grouping = {
        {
            general = true,
            alerts = {"enragecd","phasewarn"},
        },
        {
            name = format("|cffffd700%s|r","Cho'gall"),
            icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Chogall",
            sizing = {aspect = 2, w = 128, h = 64},
            alerts = {"conversioncd","conversionwarn","fireaddwarn","blazewarnself","shadowaddwarn","furysoon","furycd","furywarn","adherentcd","adherentwarn","festerbloodcd","festerbloodwarn",
                        "creationscd","creationswarn"}
        },
        {
            name = format("|cffffd700%s|r","Corrupting Adherent"),
            icon = "Interface\\ICONS\\Achievement_Boss_HeraldVolazj",
            alerts = {"crashcd","crashwarn","crashclosewarn","crashselfwarn","crashdmg","depravitycd","depravitywarn"},
        },
    },
    alerts = {       
        -- Fury of Cho'gall
        furycd = {
            varname = format(L.alert["%s CD"],SN[82524]),
            text = format(L.alert["Next %s"], SN[82524]),
            -- time = 47,
            -- time2 = 63,
            time = "<furycd>",
            icon = ST[82524],
        },
        furywarn = {
            varname = format(L.alert["%s Warning"],SN[82524]),
            text = format("%s!",SN[82524]),
            icon = ST[82524],
        },
        -----------------------
        ------- Phase 1 -------
        -----------------------
        -- Flaming Destruction
        fireaddwarn = {
            varname = format(L.alert["%s Warning"],SN[81194]),
            text = SN[81194],
            time10n = 10,
            time25n = 10,
            time10h = 10,
            time25h = 20.5,
            icon = ST[81194],
        },
        -- Empowered Shadows
        shadowaddwarn = {
            varname = format(L.alert["%s Warning"],SN[81572]),
            text = SN[81572],
            time10n = 9,
            time25n = 9,
            time10h = 9,
            time25h = 20.5,
            icon = ST[81572],
        },
        -- Blaze
        blazewarnself = {
            varname = format(L.alert["%s on me Warning"],SN[81538]),
            text = format("%s on %s - %s!",SN[81538],L.alert["YOU"],L.alert["MOVE AWAY"]),
            icon = ST[81538],
        },
        -- Conversion
        conversioncd = {
            varname = format(L.alert["%s CD"],SN[91303]),
            text = format(L.alert["%s CD"],SN[91303]),
            text2 = format(L.alert["Next %s"],SN[91303]),
            time = "<conversiontime>",
            time2 = 11.3,
            time3 = 11,
            icon = ST[91303],
            -- audiocd = true,
        },
        conversionwarn = {
            varname = format(L.alert["%s Warning"],SN[91303]),
            text = format(L.alert["%s on %s"],SN[91303],"&list|conversionunits&"),
            icon = ST[91303],
        },
        -- Summon Corrupting Adherent
        adherentcd = {
            varname = format(L.alert["%s CD"],SN[81628]),
            type = "dropdown",
            text = format("New %s CD","<adherenttext>"),
            --time = "<adherenttime>",
            time = 92,
            time2 = 5.8,
            icon = ST[81628],
            enabled = {
            },
        },
        adherentwarn = {
            varname = format(L.alert["%s Warning"],SN[81628]),
            text = format("New: %s","<adherenttext>"),
            icon = ST[81628],
            enabled = {
            },
        },
        furysoon = {
            varname = format(L.alert["%s soon"],SN[82524]),
            type = "simple",
            text = format(L.alert["%s soon"],SN[82524]),
            time = 5,
            icon = ST[82524],
            enabled = {
            },
        },
        -- Fester Blood
        festerbloodcd = {
            varname = format(L.alert["%s CD"],SN[82299]),
            type = "dropdown",
            text = format(L.alert["Next %s"],SN[82299]),
            time = 40,
            flashtime = 5,
            color1 = "MAGENTA",
            icon = ST[82299],
        },
        festerbloodwarn = {
            varname = format(L.alert["%s Warning"],SN[82299]),
            type = "simple",
            text = SN[82299].."!",
            color1 = "RED",
            sound = "MINORWARNING",
            time = 3,
            flashtime = 3,
            icon = ST[82299],
        },
        -- Corrupting Crash
        crashcd = {
            varname = format(L.alert["%s CD"],SN[81689]),
            text = format(L.alert["Next %s"],SN[81689]),
            time = "<crashcd>",
            icon = ST[81689],
        },
        crashwarn = {
            varname = format(L.alert["%s Warning"],SN[81689]),
            text = format("%s on <%s>",SN[81689],"#5#"),
            icon = ST[81689],
        },
        crashselfwarn = {
            varname = format(L.alert["%s on me Warning"],SN[81689]),
            text = format("%s on <%s>!",SN[81689],L.alert["YOU"]),
            icon = ST[81689],
        },
        crashclosewarn = {
            varname = format(L.alert["%s near me Warning"],SN[81689]),
            text = format(L.alert["%s near %s - MOVE AWAY!"],SN[81689],L.alert["YOU"]),
            icon = ST[81689],
        },
        -- Depravity
        depravitywarn = {
            varname = format(L.alert["%s Warning"],SN[81713]),
            warningtext = format("%s: %s - INTERRUPT!","Corrupting Adherent",SN[81713]),
            text = format("%s: %s","Corrupting Adherent",SN[81713]),
            icon = ST[81713],
        },
        depravitycd = {
            varname = format(L.alert["%s CD"],SN[81713]),
            text = format(L.alert["Next %s"],SN[81713]),
            time = "<depravitycd>",
            icon = ST[81713],
        },
        -----------------------
        ------- Phase 2 -------
        -----------------------
        creationscd = {
            varname = format(L.alert["%s CD"],SN[82414]),
            text = format(L.alert["New %s"],SN[82414]),
            time = "<creationstime>",
            icon = ST[82414],
        },
        creationswarn = {
            varname = format(L.alert["%s Warning"],SN[82414]),
            text = format("New: %s",SN[82414]),
            icon = ST[82414],
        },
        
    },
    events = {
        -- Summon Corrupting Adherent
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 81628,
            execute = {
                {
                    -- "set",{
                    --     -- conversiontime = 37, -- TODO: need confirm
                    --     crashcd = {12, 10, loop = false, type = "series"},
                    --     depravitycd = {9, 12, loop = false, type = "series"},
                    -- },
                    "quash","adherentcd",
                    "alert","adherentcd",
                    "alert","adherentwarn",
                    "alert","festerbloodcd",
                    "alert","depravitycd",
                    "alert","crashcd",
                },
            },
        },
        -- Shadow Crash
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 81689,
            execute = {
                {
                    "alert","crashcd",          
                    "raidicon","crashmark",
                    "radar","crashradar",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","crashselfwarn",
                    "announce","crashsay",
                },
                {
                    "expect",{"#4#","~=","&playerguid&"},
                    "alert","crashwarn",
                    "expect",{"&getdistance|#4#&","<=",10},
                    "alert","crashclosewarn",
                },
            },
        },
        -- Depravity
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellid = {
                81713,
                93175,
                93176,
                93177,
            },
            execute = {
                {
                    "invoke",{
                        {
                            "expect",{"&itemvalue|depravitytargetonly&","==","false"},
                            "alert","depravitywarn",
                            "alert","depravitycd",
                        },
                        {
                            "expect",{"&itemvalue|depravitytargetonly&","==","true"},
                            "expect",{"#1#","==","&unitguid|target&",
                                    "OR","#1#","==","&unitguid|focus&"},
                            "alert","depravitywarn",
                            "alert","depravitycd",
                        },
                    },
                },
            },
        },
        {
            type = "event",
            event = "UNIT_SPELLCAST_INTERRUPTED",
            execute = {
                {
                    "expect",{"#2#","==",SN[93176]},
                    "quash",{"depravitywarn","&unitguid|#1#&"},
                },
            },
        },
        
        -- Corrupting Adherent's Death
        {
            type = "combatevent",
            eventtype = "UNIT_DIED",
            execute = {
                {
                    "expect",{"&npcid|#4#&","==","43622"},
                    "quash",{"crashcd","#4#"},
                    "quash",{"depravitycd","#4#"},
                    "quash",{"depravitywarn","#4#"},
                },
            },
        },
        
        -- Fury of Cho'gall
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 82524,
            execute = {
                {
                    "alert","furywarn",
                    "quash","furycd",          
                    "alert","furycd",
                },
                {
                    "expect",{"<firstfury>","==","yes"},
                    "set",{firstfury = "no"},
                    "set",{
                        conversiontime = 35, -- TODO: need confirm
                        crashcd = {12, 10, loop = false, type = "series"},
                        depravitycd = {9, 12, loop = false, type = "series"},
                    },
                    "alert",{"adherentcd", time = 2},
                    "quash","conversioncd",
                    -- "alert",{"conversioncd",time = 2, text = 2}, -- TODO: need confirm
                    "alert","conversioncd",
                    "alert","depravitycd",
                    "alert","crashcd",
                },
            },
        },
        -- Festerblood
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 82299,
            execute = {
                {
                    "quash","festerbloodcd",
                    "alert","festerbloodwarn",
                },
            },
        },
        -- Conversion / Worshipping
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellname = {93367, 91317},
            srcisplayertype = true,
            execute = {
                {
                    "raidicon","worshipmark",
                    "insert",{"conversionunits","#5#"},
                },
                {
                    "expect",{"&listsize|conversionunits&","==","1"},
                    "scheduletimer",{"conversiontimer",1},
                    "quash","conversioncd",          
                    "alert","conversioncd",
                },
                {
                    "expect",{"&listsize|conversionunits&","==","<conversionmax>"},
                    "canceltimer","conversiontimer",
                    "alert","conversionwarn",
                },
            },
        },
        -- Blaze
        {
            type = "combatevent",
            eventtype = "SPELL_DAMAGE",
            spellname = 81538,
            execute = {
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "alert","blazewarnself",
                },
            },
        },
        -- Phase 2 (Consume Blood of the Old God)
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 82630,
            execute = {
                {
                    "quashall",{"enragecd","furycd"},
                    "set",{phase = 2},
                    "alert","phasewarn",
                    "alert","creationscd",
                },
            },
        },
        -- Darkened Creations
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellid = {
                82414,
                93160,
                93161,
                93162,
            },
            execute = {
                {
                    "alert","creationswarn",          
                    "quash","creationscd",
                    "alert","creationscd",
                },
            },
        },
        -- Flame Orders
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = {
                81194,
                93264,
                93265,
                93266,
            },
            execute = {
                {
                    "alert","fireaddwarn",
                },
            },
        },
        -- Shadow Orders
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = {
                81572,
                93218,
                93219,
                93220,           
            },
            execute = {
                {
                    "alert","shadowaddwarn",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "sinestra", {
    windows = {
        proxwindow = false,
    },
    alerts = {
        breathcd = {
            varname = format(L.alert["%s CD"],SN[90125]),
            type = "dropdown",
            text = format(L.alert["%s CD"],SN[90125]),
            time = 21,
            flashtime = 10,
            icon = ST[90125],
        },
        breathwarn = {
            varname = format(L.alert["%s Warning"],SN[90125]),
            text = format(L.alert["%s"],SN[90125]),
            time = 3,
            icon = ST[90125],
        },
        slicercd = {
            varname = format(L.alert["%s CD"],SN[92852]),
            text = format(L.alert["Next Shadow Orbs"],SN[92852]),
            time = "<slicercd>",
            time2 = 10,
            icon = ST[92852],
        },
        slicerwarn = {
            varname = format(L.alert["%s Warning"],SN[92852]),
            type = "simple",
            text = format(L.alert["Shadow Orbs imminent!"],SN[92852]),
            time = 3,
            icon = ST[92852],
        },
        wrackcd = {
            varname = format(L.alert["%s CD"],SN[89421]),
            text = format(L.alert["Next %s"],SN[89421]),
            time = 70,
            time2 = 15,
            icon = ST[89421],
        },
        wrackwarn = {
            varname = format(L.alert["%s Warning"],SN[89421]),
            text = "<wracktext>",
            time = 3,
            icon = ST[89421],
        },
        phasewarn = {
            varname = format(L.alert["Phase Warning"]),
            type = "simple",
            text = format(L.alert["Phase %s"],"<phase>"),
            time = 5,
            flashtime = 5,
            icon = ST[11242],
            color1 = "TURQUOISE",
            sound = "BEWARE",
        },
        eggwarn = {
            varname = format(L.alert["Eggs Vulnerable Warning"]),
            type = "centerpopup",
            text = format(L.alert["Eggs vulnerable"]),
            time = 30,
            flashtime = 5,
            color1 = "PINK",
            sound = "ALERT10",
            icon = ST[87654],
            throttle = 2,
            emphasizewarning = true,
        },
        whelpscd = {
            varname = format(L.alert["%s CD"],"Twilight Whelps"),
            type = "dropdown",
            text = format(L.alert["New Twilight Whelps"]),
            time = 50,
            time2= 16,
            flashtime = 5,
            color1 = "PURPLE",
            sound = "MINORWARNING",
            icon = ST[10695],
        },
        essencecountdown = {
            varname = format(L.alert["%s Countdown"],SN[87946]),
            type = "dropdown",
            text = format(L.alert["%s applied in"],SN[87946]),
            time = 22,
            flashtime = 10,
            color1 = "GOLD",
            icon = ST[87946],      
        },
        essencewarn = {
            varname = format(L.alert["%s Warning"],SN[87946]),
            type = "dropdown",
            text = format(L.alert["%s"],SN[87946]),
            time = 180,
            flashtime = 20,
            color1 = "RED",
            icon = ST[87946],
        },
    },
    events = {
        -- Flame Breath
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 90125,
            execute = {
                {
                    "quash","breathcd",
                    "alert","breathcd",
                    "alert","breathwarn",
                },
            },
        },
        -- Wrack
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_APPLIED",
            spellid = {89421},
            execute = {
                {
                    "alert","wrackcd",
                },
                {
                    "expect",{"#4#","==","&playerguid&"},
                    "set",{wracktext = format(L.alert["%s on <%s>"],SN[89421],L.alert["YOU"])},
                    "alert","wrackwarn",
                },
            },
        },
        -- Mana Barrier == Phase 2 starting
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_START",
            spellname = 87299,
            execute = {
                {
                    "batchquash",{"breathcd","slicercd","whelpscd"},
                    "canceltimer","slicer",
                    "set",{phase = "2"},
                    "alert","phasewarn",
                    "removephasemarker",{1,1},
                },
            },
        },
        -- Eggs vulnerable
        {
            type = "combatevent",
            eventtype = "SPELL_AURA_REMOVED",
            spellname = 87654,
            execute = {
                {
                    "alert","eggwarn",
                },
            },
        },
        -- Essence of the Red
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 87946,
            execute = {
                {
                    "alert","essencewarn",
                },
            },
        },
        -- Twilight Pulsing Eggs tracing
        {
            type = "combatevent",
            eventtype = "SPELL_CAST_SUCCESS",
            spellname = 87654,
            execute = {
                {
                    "expect",{"#2#","==","Pulsing Twilight Egg"},
                    "raidicon","eggsmark",
                    "expect",{"<eggstraced>","==","no"},
                    "insert",{"eggsunits","#1#"},
                    "expect",{"&listsize|eggsunits&","==","2"},
                    "set",{eggstraced = "yes"},
                    "scheduletimer",{"eggstimer",1},
                },
            },
        },
        {
            type = "event",
            event = "YELL",
            execute = {
                -- Summoning Whelps
                {
                    "expect",{"#1#","find",L.chat_bastion["^Feed, children"]},
                    "alert","whelpscd",
                },
                -- Phase 3 trigger
                {
                    "expect",{"#1#","find",L.chat_bastion["^Enough!"]},
                    "quash","eggwarn",
                    "set",{phase = "3"},
                    "alert","phasewarn",
                    "set",{slicercd = {30,28, loop = false, type = "series"}},
                    "set",{slicerdelay = {30,28, loop = false, type = "series"}},            
                    "alert","slicercd",
                    "scheduletimer",{"slicer","<slicerdelay>"},
                    "alert","breathcd",
                    "alert","essencecountdown",
                },
            },
        },
    },
})

DXE:RegisterRealmPatch(realm, "bottrash", {
    windows = {
        proxwindow = false,
    },
})
