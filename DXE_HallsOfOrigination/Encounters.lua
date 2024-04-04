local L,SN,ST,AL,AN,AT,TI = DXE.L,DXE.SN,DXE.ST,DXE.AL,DXE.AN,DXE.AT,DXE.TI

---------------------------------
-- TEMPLE GUARDIAN ANHUUR
---------------------------------

do
    local data = {
        version = 5,
        key = "anhuur",
        zone = L.zone["Halls of Origination"],
        category = L.zone["Halls of Origination"],
        name = "Temple Guardian Anhuur",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Temple Guardian Anhuur.blp",
        triggers = {
            scan = {
                39425, -- Temple Guardian Anhuur
            },
        },
        onactivate = {
            tracing = {
                39425,
            },
            phasemarkers = {
                {
                    {0.66, "Reverberating Hymn","At 66% of his HP, Temple Guardian Anhuur starts casting Reverberating Hymn."},
                    {0.33, "Reverberating Hymn","At 33% of his HP, Temple Guardian Anhuur starts casting Reverberating Hymn."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39425,
        },
        userdata = {
            hymn1warned = "no",
            hymn2warned = "no",
            hatethatsongfailed = "no",
            hatethatsongcomplete = "no",
            reckoningtext = "",
        },
        onstart = {
            {
                "repeattimer",{"checkhp", 1},
                "alert",{"reckoningcd",time = 2},
                "alert","lightcd",
            },
        },
        
        announces = {
            hatethatsongfailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5293,
                msg = format(L.alert["<DXE> %s: Achievement failed!"],AL[5293]),
                throttle = true,
            },
            hatethatsongcomplete = {
                varname = "%s complete",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5293,
                msg = format(L.alert["<DXE> Requirements for %s were met. You can kill the boss now."],AL[5293]),
                throttle = true,
            },
        },
        filters = {
            bossemotes = {
                hymnemote = {
                    name = "Reverberating Hymn",
                    pattern = "becomes protected by his",
                    hasIcon = false,
                    hide = true,
                    texture = ST[75322],
                },
                shielddownemote = {
                    name = "Shield disabled",
                    pattern = "is no longer protected",
                    hasIcon = false,
                    texture = ST[74938],
                },
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
        ordering = {
            alerts = {"reckoningcd","reckoningwarn","lightcd","lightwarn","lightselfwarn","hymnsoonwarn","hymnwarn","hatethatsongcd"},
        },
        
        alerts = {
            -- Divine Reckoning
            reckoningcd = {
                varname = format(L.alert["%s CD"],SN[94949]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[94949]),
                time = 21,
                time2 = 5, -- init
                time3 = 20, -- after Hymn interrupt
                flashtime = 5,
                color1 = "YELLOW",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[94949],
                throttle = 1,
                sticky = true,
            },
            reckoningwarn = {
                varname = format(L.alert["%s Warning"],SN[94949]),
                type = "simple",
                text = "<reckoningtext>",
                time = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[94949],
            },
            -- Burning Light
            lightcd = {
                varname = format(L.alert["%s CD"],SN[75115]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[75115]),
                time = 12,
                time2 = 13, -- after Hymn interrupt
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[75115],
                throttle = 1,
            },
            lightwarn = {
                varname = format(L.alert["%s Warning"],SN[75115]),
                type = "simple",
                text = format(L.alert["%s"],SN[75115]),
                time = 1,
                color1 = "TURQUOISE",
                color2 = "RED",
                sound = "ALERT8",
                icon = ST[75115],
            },
            lightselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[75115]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[75115],L.alert["YOU"]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT10",
                icon = ST[75115],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
            -- Reverberating Hymn
            hymnsoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[75322]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[75322]),
                time = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            hymnwarn = {
                varname = format(L.alert["%s Warning"],SN[75322]),
                type = "simple",
                text = format(L.alert["%s"],SN[75322]),
                time = 1, -- 180,
                color1 = "YELLOW",
                sound = "ALERT1",
                icon = ST[75322],
            },
            -- Achievement: I Hate That Song
            hatethatsongcd = {
                varname = format(L.alert["%s %s Countdown"],TI["AchievementShield"],AN[5293]),
                type = "dropdown",
                text = format(L.alert["%s window"],AN[5293]),
                time = 15,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "YELLOW",
                sound = "MINORWARNING",
                icon = AT[5293],
            },
            
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","75"},
                    "expect",{"<hymn1warned>","==","no"},
                    "set",{hymn1warned = "yes"},
                    "alert","hymnsoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","41"},
                    "expect",{"<hymn2warned>","==","no"},
                    "set",{hymn2warned = "yes"},
                    "alert","hymnsoonwarn",
                },
                {
                    "expect",{"<hymn1warned>","==","yes"},
                    "expect",{"<hymn2warned>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
            hatethatsongtimer = {
                {
                    "expect",{"<hatethatsongfailed>","==","no"},
                    "announce","hatethatsongfailed",
                    "set",{hatethatsongfailed = "yes"},
                },
            },
        },
        events = {
			-- Reverberating Hymn
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 75322,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39425"},
                        "quash","reckoningcd",
                        "quash","lightcd",
                        "alert","hymnwarn",
                        "expect",{"&difficulty&","==","2"},
                        "expect",{"<hatethatsongfailed>","==","no"},
                        "alert","hatethatsongcd",
                        "scheduletimer",{"hatethatsongtimer", 15},
                    },
                },
            },
            -- Reverberating Hymn (interrupt)
            {
                type = "event",
                event = "UNIT_SPELLCAST_CHANNEL_STOP",
                execute = {
                    {
                        "expect",{"#2#","==",SN[75322]},
                        "expect",{"#1#","find","boss"},
                        "invoke",{
                            {
                                "quash","hymnwarn",
                                "alert",{"reckoningcd",time = 3},
                                "alert",{"lightcd",time = 2},
                                "expect",{"&difficulty&","==","2"},
                                "canceltimer","hatethatsongtimer",
                            },
                            {
                                "expect",{"<hymn1warned>","==","yes"},
                                "expect",{"<hymn2warned>","==","yes"},
                                "expect",{"&difficulty&","==","2"},
                                "expect",{"<hatethatsongfailed>","==","no"},
                                "expect",{"<hatethatsongcomplete>","==","no"},
                                "set",{hatethatsongcomplete = "yes"},
                                "announce","hatethatsongcomplete",
                            },
                        },
                    },
                },
            },
            -- Divine Reckoning
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 94949,
                execute = {
                    {
                        "quash","reckoningcd",
                        "alert","reckoningcd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 94949,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{reckoningtext = format(L.alert["%s on %s - DISPEL!"],SN[94949],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{reckoningtext = format(L.alert["%s on <%s> - DISPEL!"],SN[94949],"#5#")},
                    },                    
                    {
                        "alert","reckoningwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[75115]},
                        "expect",{"#1#","==","boss1"},
                        "quash","lightcd",
                        "alert","lightcd",
                        "alert","lightwarn",
                    },
                },
            },
            -- Burning Light
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 75115,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","lightselfwarn",
                    },
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- EARTHRAGER PTAH
---------------------------------

do
    local data = {
        version = 2,
        key = "ptah",
        zone = L.zone["Halls of Origination"],
        category = L.zone["Halls of Origination"],
        name = "Earthrager Ptah",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Earthrager Ptah.blp",
        triggers = {
            scan = {
                39428, -- Earthrager Ptah
            },
        },
        onactivate = {
            tracing = {
                39428,
            },
            phasemarkers = {
                {
                    {0.5, "Tumultuous Earthstorm", "When Earthrager Ptah's HP reaches 50%, he generates a massive earthquake and disperses."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39428,
        },
        userdata = {},
        onstart = {
            {
                "repeattimer",{"checkhp", 1},
            },
        },
        ordering = {
            alerts = {"spikewarn","stormsoonwarn","stormwarn","quicksandself"},
        },
        
        alerts = {
            -- Earth Spike
            spikewarn = {
                varname = format(L.alert["%s Warning"],SN[94974]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[94974]),
                time = 4,
                color1 = "PEACH",
                sound = "ALERT7",
                icon = ST[94974],
            },
            -- Sandstorm
            stormsoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[75491]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[75491]),
                time = 1,
                color1 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[75491],
            },
            stormwarn = {
                varname = format(L.alert["%s Warning"],SN[75491]),
                type = "simple",
                text = format(L.alert["%s"],SN[75491]),
                time = 1,
                color1 = "GOLD",
                sound = "ALERT1",
                icon = ST[75491],
                -- throttle = 2,
            },
            -- Quicksand
            quicksandself = {
                varname = format(L.alert["%s on me Warning"],SN[89880]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[89880],L.alert["YOU"]),
                time = 1,
                color1 = "YELLOW",
                sound = "ALERT10",
                icon = ST[89880],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","60"},
                    "alert","stormsoonwarn",
                    "canceltimer","checkhp",
                },
            },
        },
        events = {
            -- Earth Spike
			{
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[94974]},
                        "expect",{"#1#","==","boss1"},
                        "alert","spikewarn",
                    },
                },
            },
            -- Sandstorm
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[75491]},
                        "expect",{"#1#","==","boss1"},
                        "alert","stormwarn",
                    },
                },
            },
            -- Quicksand
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 89880,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","quicksandself",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- VAULT OF LIGHTS (EVENT)
---------------------------------

do
    local data = {
        version = 3,
        key = "volevent",
        zone = L.zone["Halls of Origination"],
        category = L.zone["Halls of Origination"],
        name = "The Vault of Lights",
        icon = "Interface\\Icons\\Achievement_Dungeon_Halls of Origination",
        advanced = {
            disableAutoWipe = true,
            recordBestTime = true,
        },
        triggers = {
            say = L.chat_hallsoforigination["^That did the trick"],
        },
        onactivate ={
            tracing = {
                39800,
                39801,
                39803,
                39802,
            },
            tracerstart = true,
            combatstop = false,
            combatstart = false,
            defeat = {
                39800, -- Flame Warden
                39801, -- Earth Warden
                39802, -- Water Warden
                39803, -- Air Warden
            },
            wipe = {
                yell = L.chat_hallsoforigination["^This unit has been activated"],
            },
        },
        userdata = {
            testwarntext = "",
        },
        onstart = {
            {
                "expect",{"&difficulty&","==","2"},
                "alert","speedkillcd",
                "scheduletimer",{"speedkilltimer", 300.3},
            },
        },
        
        announces = {
            achievementfailedparty = {
                varname = "{%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5296,
                msg = format(L.alert["<DXE> %s: Achievement failed!"],AL[5296]),
                throttle = true,
            },
        },
        ordering = {
            alerts = {"rockwavewarn","rockwavecd","infernowarn","infernocd","bubblewarn","bubblecd","speedkillcd"},
        },
        
        alerts = {
            -- Faster Than the Speed of Light (achievement)
            speedkillcd = {
                varname = format(L.alert["%s %s Countdown"],TI["AchievementShield"],AN[5296]),
                type = "dropdown",
                text = format(L.alert["%s"],"Faster Than the Speed of Light"),
                time = 300,
                flashtime = 20,
                color1 = "GOLD",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[34712],
            },
            -- Rockwave
            rockwavewarn = {
                varname = format(L.alert["%s Warning"],SN[91162]),
                type = "simple",
                text = format(L.alert["%s - INTERRUPT!"],SN[91162]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[91162],
            },
            rockwavecd = {
                varname = format(L.alert["%s CD"],SN[91162]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91162]),
                time = 15,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[91162],
            },
            -- Raging Inferno
            infernocd = {
                varname = format(L.alert["%s CD"],SN[91160]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[91160]),
                time = 17,
                flashtime = 5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[91160],
            },
            infernowarn = {
                varname = format(L.alert["%s Warning"],SN[91160]),
                type = "simple",
                text = format(L.alert["%s - RUN AWAY!"],SN[91160]),
                time = 1,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "RUNAWAY",
                icon = ST[91160],
            },
            -- Bubble Bound
            bubblecd = {
                varname = format(L.alert["%s CD"],SN[77335]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[77335]),
                time = 10,
                flashtime = 5,
                color1 = "CYAN",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[77335],
            },
            bubblewarn = {
                varname = format(L.alert["%s Warning"],SN[77335]),
                type = "simple",
                text = format(L.alert["%s"],SN[77335]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT7",
                icon = ST[77335],
            },
        },
        timers = {
            speedkilltimer = {
                {
                    "announce","achievementfailedparty",
                },
            },
        },
        events = {
			-- Rockwave
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91162,
                execute = {
                    {
                        "quash","rockwavecd",
                        "alert","rockwavecd",
                        "alert","rockwavewarn",
                    },
                },
            },
            -- Raging Inferno
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91160,
                execute = {
                    {
                        "quash","infernocd",
                        "alert","infernocd",
                        "alert","infernowarn",
                    },
                },
            },
            -- Bubble Bound
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[77335]},
                        "quash","bubblecd",
                        "alert","bubblecd",
                        "alert","bubblewarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39801"},
                        "quash","rockwavecd",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","39800"},
                        "quash","infernocd",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","39802"},
                        "quash","bubblecd",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "PARTY_KILL",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39801"},
                        "quash","rockwavecd",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","39800"},
                        "quash","infernocd",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","39802"},
                        "quash","bubblecd",
                    },
                },
            },
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ANRAPHET
---------------------------------

do
    local data = {
        version = 2,
        key = "anraphet",
        zone = L.zone["Halls of Origination"],
        category = L.zone["Halls of Origination"],
        name = "Anraphet",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Anraphet.blp",
        triggers = {
            scan = {
                39788, -- Anraphet
            },
        },
        onactivate = {
            tracing = {
                39788,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39788,
        },
        userdata = {
            alphacd = {10, 40, loop = false, type = "series"},
            omegacd = {35, 50, loop = false, type = "series"},
            nemesistext = "",
        },
        onstart = {
            {
                "alert","alphacd",
                "alert","omegacd",
            },
        },
        ordering = {
            alerts = {"alphacd","alphawarn","alphaduration","alphaselfwarn","omegacd","omegawarn","omegaduration","nemesiswarn"},
        },
        
        alerts = {
            -- Alpha Beams
            alphacd = {
                varname = format(L.alert["%s CD"],SN[76184]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[76184]),
                time = "<alphacd>",
                flashtime = 5,
                color1 = "MAGENTA",
                color2 = "PURPLE",
                sound = "MINORWARNING",
                icon = ST[76184],
                sticky = true,
            },
            alphawarn = {
                varname = format(L.alert["%s Warning"],SN[76184]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[76184]),
                time = 3,
                color1 = "PURPLE",
                sound = "ALERT2",
                icon = ST[76184],
            },
            alphaduration = {
                varname = format(L.alert["%s Warning"],SN[76184]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[76184]),
                time = 12.5,
                color1 = "MAGENTA",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[76184],
            },
            alphaselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[91177]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[91177],L.alert["YOU"]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[91177],
                throttle = 2,
                emphasizewarning = true,
            },
            -- Omega Stance
            omegacd = {
                varname = format(L.alert["%s CD"],SN[91208]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[91208]),
                time = "<omegacd>",
                flashtime = 5,
                color1 = "RED",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[91208],
                sticky = true,
            },
            omegawarn = {
                varname = format(L.alert["%s Warning"],SN[91208]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[91208]),
                time = 2,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT1",
                icon = ST[91208],
            },
            omegaduration = {
                varname = format(L.alert["%s Duration"],SN[91208]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[91208]),
                time = 8,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[91208],
            },
            -- Nemesis Strike
            nemesiswarn = {
                varname = format(L.alert["%s Warning"],SN[91174]),
                type = "simple",
                text = "<nemesistext>",
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT8",
                icon = ST[91174],
            },
            
        },
        events = {
			-- Alpha Beams
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 76184,
                execute = {
                    {
                        "quash","alphacd",
                        "alert","alphacd",
                        "alert","alphawarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 76184,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39788"},
                        "alert","alphaduration",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 91177,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","alphaselfwarn",
                    },
                },
            },
            
            -- Omega Stance
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 91208,
                execute = {
                    {
                        "quash","omegacd",
                        "alert","omegacd",
                        "alert","omegawarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 91208,
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39788"},
                        "alert","omegaduration",
                    },
                },
            },
            -- Nemesis Strike
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 91174,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{nemesistext = format(L.alert["%s on %s - DISPEL!"],SN[91174],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{nemesistext = format(L.alert["%s on <%s> - DISPEL!"],SN[91174],"#5#")},
                    },
                    {
                        "alert","nemesiswarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- AMMUNAE
---------------------------------

do
    local data = {
        version = 2,
        key = "ammunae",
        zone = L.zone["Halls of Origination"],
        category = L.zone["Halls of Origination"],
        name = "Ammunae",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Ammunae.blp",
        triggers = {
            scan = {
                39731, -- Ammunae
            },
        },
        onactivate = {
            tracing = {
                39731,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39731,
        },
        userdata = {
            withertext = "",
        },
        onstart = {
            {
                "alert",{"growthcd",time = 2},
                "alert","withercd",
                "alert",{"seedcd",time = 2},
            },
        },
        ordering = {
            alerts = {"withercd","withercastwarn","witherwarn","growthcd","growthwarn","sporesselfwarn"},
        },
        
        alerts = {
            -- Wither
            withercd = {
                varname = format(L.alert["%s CD"],SN[76043]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[76043]),
                time = 20,
                flashtime = 5,
                color1 = "BROWN",
                color2 = "ORANGE",
                sound = "MINORWARNING",
                icon = ST[76043],
                sticky = true,
            },
            withercastwarn = {
                varname = format(L.alert["%s Warning"],SN[76043]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[76043]),
                time = 1.5,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT2",
                icon = ST[76043],
            },
            witherwarn = {
                varname = format(L.alert["%s Debuff Warning"],SN[76043]),
                type = "simple",
                text = "<withertext>",
                time = 1,
                color1 = "BROWN",
                sound = "ALERT8",
                icon = ST[76043],
            },
            -- Noxious Spores
            sporesselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[89889]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[89889],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[89889],
                throttle = 2,
                emphasizewarning = true,
            },
            -- Rampant Growth
            growthcd = {
                varname = format(L.alert["%s CD"],SN[89888]),
                type = "dropdown",
                text = format(L.alert["Next %s"],SN[89888]),
                time =  63,
                time2 = 70,
                flashtime = 5,
                color1 = "GREEN",
                color2 = "LIGHTGREEN",
                sound = "MINORWARNING",
                icon = ST[89888],
            },
            growthwarn = {
                varname = format(L.alert["%s Warning"],SN[89888]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[89888]),
                time = 1.5,
                color1 = "LIGHTGREEN",
                sound = "BEWARE",
                icon = ST[89888],
            },
        },
        events = {
			-- Wither
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 76043,
                execute = {
                    {
                        "quash","withercd",
                        "alert","withercd",
                        "alert","withercastwarn",
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[76043]},
                        "expect",{"#1#","find","boss"},
                        "quash","withercastwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 76043,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "set",{withertext = format(L.alert["%s on %s - DISPEL!"],SN[76043],L.alert["YOU"])},
                    },
                    {
                        "expect",{"#4#","~=","&playerguid&"},
                        "set",{withertext = format(L.alert["%s on <%s> - DISPEL!"],SN[76043],"#5#")},
                    },
                    {
                        "alert","witherwarn",
                    },
                },
            },
            -- Noxious Spores
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 89889,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","sporesselfwarn",
                    },
                },
            },
            -- Rampant Growth
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 89888,
                execute = {
                    {
                        "quash","growthcd",
                        "alert","growthcd",
                        "alert","growthwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- SETESH
---------------------------------

do
    local data = {
        version = 2,
        key = "setesh",
        zone = L.zone["Halls of Origination"],
        category = L.zone["Halls of Origination"],
        name = "Setesh",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Setesh.blp",
        triggers = {
            scan = {
                39732, -- Setesh
            },
        },
        onactivate = {
            tracing = {
                39732,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39732,
        },
        userdata = {},
        onstart = {{}},
        
        alerts = {
            -- Chaos Portal
            portalwarn = {
                varname = format(L.alert["%s Warning"],SN[76784]),
                type = "simple",
                text = format(L.alert["%s - DESTROY IT"],SN[76784]),
                time = 1,
                color1 = "PINK",
                sound = "BEWARE",
                icon = ST[57536],
                throttle = 2,
            },
            -- Chaos Burn
            burnselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[89874]),
                type = "simple",
                text = format(L.alert["%s on %s - MOVE AWAY!"],SN[89874],L.alert["YOU"]),
                time = 1,
                color1 = "MAGENTA",
                sound = "ALERT10",
                icon = ST[89874],
                throttle = 2,
                emphasizewarning = true,
            },
        },
        events = {
			-- Chaos Portal
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[76784]},
                        "expect",{"&difficulty&","==","2"},
                        "alert","portalwarn",
                    },
                },
            },
            -- Chaos Burn
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 89874,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","burnselfwarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- ISISET
---------------------------------

do
    local data = {
        version = 3,
        key = "isiset",
        zone = L.zone["Halls of Origination"],
        category = L.zone["Halls of Origination"],
        name = "Isiset",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Isiset.blp",
        triggers = {
            scan = {
                39587, -- Isiset
            },
        },
        onactivate = {
            tracing = {
                39587,
            },
            phasemarkers = {
                {
                    {0.66, "Mirror Images","At 66% of her HP, Isiset splits into three separate creatures."},
                    {0.33, "Mirror Images","At 33% of her HP, Isiset splits into two separate creatures."},
                },
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39587,
        },
        userdata = {
            veiltext = "",
            mirror1warned = "no",
            mirror2warned = "no",
            mirror1started = "no",
            mirror2started = "no",
        },
        onstart = {
            {
                "alert",{"supernovacd",time = 2},
                "repeattimer",{"checkhp", 1},
            },
        },
        
        filters = {
            bossemotes = {
                supernovaemote = {
                    name = "Supernova",
                    pattern = "begins to channel a Supernova",
                    hasIcon = false,
                    hide = true,
                    texture = ST[74136],
                },
            },
        },
        phrasecolors = {
            {"Phase","GOLD"},
            {"finished","GOLD"},
        },
        ordering = {
            
            alerts = {"supernovacd","supernovawarn","veilwarn","mirrorsoonwarn","mirrorwarn","mirroroverwarn",},
        },
        
        alerts = {
            -- Veil of Sky
            veilwarn = {
                varname = format(L.alert["%s Warning"],SN[90760]),
                type = "simple",
                text = "<veiltext>",
                time = 1,
                color1 = "LIGHTBLUE",
                sound = "ALERT8",
                icon = ST[90760],
            },
            -- Supernova
            supernovacd = {
                varname = format(L.alert["%s CD"],SN[74136]),
                type = "dropdown",
                text = format(L.alert["%s CD"],SN[74136]),
                time = 20,
                time2 = 18,
                time3 = 24,
                flashtime = 5,
                color1 = "INDIGO",
                color2 = "LIGHTBLUE",
                sound = "MINORWARNING",
                icon = ST[74136],
                throttle = 1,
                sticky = true,
            },
            supernovawarn = {
                varname = format(L.alert["%s Warning"],SN[74136]),
                type = "centerpopup",
                text = format(L.alert["%s - LOOK AWAY!"],SN[74136]),
                time = 3,
                color1 = "WHITE",
                sound = "BEWARE",
                icon = ST[74136],
            },
            -- Mirror Images
            mirrorsoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[69936]),
                type = "simple",
                text = format(L.alert["%s Phase soon ..."],SN[69936]),
                time = 1,
                color1 = "TURQUOISE",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            mirrorwarn = {
                varname = format(L.alert["%s Warning"],SN[69936]),
                type = "simple",
                text = format(L.alert["%s Phase!"],SN[69936]),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT1",
                icon = ST[69936],
                throttle = 1,
            },
            mirroroverwarn = {
                varname = format(L.alert["%s finished Warning"],SN[69936]),
                type = "centerpopup",
                warningtext = format(L.alert["%s Phase finished!"],SN[69936]),
                text = "Phase transition ...",
                time = 4.5,
                color1 = "TURQUOISE",
                sound = "ALERT7",
                icon = ST[69936],
                throttle = 1,
            },
        },
        timers = {
            checkhp = {
                {
                    "expect",{"&gethp|boss1&","<","75"},
                    "expect",{"<mirror1warned>","==","no"},
                    "set",{mirror1warned = "yes"},
                    "alert","mirrorsoonwarn",
                },
                {
                    "expect",{"&gethp|boss1&","<","42"},
                    "expect",{"<mirror2warned>","==","no"},
                    "set",{mirror2warned = "yes"},
                    "alert","mirrorsoonwarn",
                },
                {
                    "expect",{"<mirror1warned>","==","yes"},
                    "expect",{"<mirror1started>","==","no"},
                    "expect",{"&gethp|boss1&","==","-1.#IND"},
                    "set",{mirror1started = "yes"},
                    "alert","mirrorwarn",
                    "quash","supernovacd",
                },
                {
                    "expect",{"<mirror2warned>","==","yes"},
                    "expect",{"<mirror1started>","==","yes"},
                    "expect",{"<mirror2started>","==","no"},
                    "expect",{"&gethp|boss1&","==","-1.#IND"},
                    "set",{mirror2started = "yes"},
                    "alert","mirrorwarn",
                    "quash","supernovacd",
                },
                {
                    "expect",{"<mirror2started>","==","yes"},
                    "canceltimer","checkhp",
                },
            },
        },
        events = {
			-- Veil of Sky
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 90760,
                execute = {
                    {
                        "expect",{"#5#","==","Isiset"},
                        "set",{veiltext = format(L.alert["%s on %s - DISPEL!"],SN[90760],"#5#")},
                        "alert","veilwarn",
                    },
                },
            },
            -- Supernova
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 74136,
                execute = {
                    {
                        "quash","supernovacd",
                        "alert","supernovacd",
                        "alert","supernovawarn",
                    },
                },
            },
            -- Mirror Images over
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39720"},
                        "alert","mirroroverwarn",
                        "alert",{"supernovacd",time = 3},
                    },
                    {
                        "expect",{"&npcid|#4#&","==","39721"},
                        "alert","mirroroverwarn",
                        "alert",{"supernovacd",time = 3},
                    },
                    {
                        "expect",{"&npcid|#4#&","==","39722"},
                        "alert","mirroroverwarn",
                        "alert",{"supernovacd",time = 3},
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "PARTY_KILL",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","39720"},
                        "alert","mirroroverwarn",
                        "alert","supernovacd",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","39721"},
                        "alert","mirroroverwarn",
                        "alert","supernovacd",
                    },
                    {
                        "expect",{"&npcid|#4#&","==","39722"},
                        "alert","mirroroverwarn",
                        "alert","supernovacd",
                    },
                },
            },
        },
        
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- RAJH
---------------------------------

do
    local data = {
        version = 5,
        key = "rajh",
        zone = L.zone["Halls of Origination"],
        category = L.zone["Halls of Origination"],
        name = "Rajh",
        icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Rajh.blp",
        triggers = {
            scan = {
                39378, -- Rajh
            },
        },
        onactivate = {
            tracing = {
                39378,
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 39378,
        },
        userdata = {
            sonofafailed = "no",
            blessingwarned = "no",
        },
        onstart = {
            {
            },
        },
        
        announces = {
            sonofafailed = {
                varname = "%s failed",
                type = "PARTY",
                subtype = "achievement",
                achievement = 5295,
                msg = format(L.alert["<DXE> %s: Achievement failed!"],AL[5295]),
                throttle = true,
            },
        },
        ordering = {
            alerts = {"orbwarn","leapwarn","windswarn","fireselfwarn","blessingsoonwarn","blessingwarn","sonofacd"},
        },
        
        alerts = {
            -- Solar Winds
            windswarn = {
                varname = format(L.alert["%s Warning"],SN[74104]),
                type = "simple",
                text = format(L.alert["%s"],SN[74104]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT7",
                icon = ST[64724],
            },
            -- Blessing of the Sun
            blessingsoonwarn = {
                varname = format(L.alert["%s soon Warning"],SN[76352]),
                type = "simple",
                text = format(L.alert["%s soon ..."],SN[76352]),
                time = 1,
                color1 = "YELLOW",
                sound = "MINORWARNING",
                icon = ST[11242],
            },
            blessingwarn = {
                varname = format(L.alert["%s Warning"],SN[76352]),
                type = "centerpopup",
                text = format(L.alert["%s"],SN[76352]),
                time = 20,
                color1 = "GOLD",
                sound = "BEWARE",
                icon = ST[76355],
            },
            -- Achievement: Son of a
            sonofacd = {
                varname = format(L.alert["%s %s Countdown"],TI["AchievementShield"],AN[5295]),
                type = "centerpopup",
                text = format(L.alert["%s window"],AN[5295]),
                time = 20,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "None",
                icon = AT[5295],
            },
            -- Inferno Leap
            leapwarn = {
                varname = format(L.alert["%s Warning"],SN[87647]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[87647]),
                time = 1.5,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[87647],
            },
            -- Summon Sun Orb
            orbwarn = {
                varname = format(L.alert["%s Warning"],SN[80352]),
                type = "centerpopup",
                text = format(L.alert["%s - INTERRUPT!"],SN[80352]),
                time = 3,
                color1 = "ORANGE",
                color2 = "RED",
                sound = "ALERT2",
                icon = ST[80352],
            },
            -- Solar Fire
            fireselfwarn = {
                varname = format(L.alert["%s on me Warning"],SN[89878]),
                type = "simple",
                text = format(L.alert["%s on %s - GET AWAY!"],SN[89878],L.alert["YOU"]),
                time = 1,
                color1 = "ORANGE",
                sound = "ALERT10",
                icon = ST[89878],
                throttle = 2,
                emphasizewarning = {1,0.5},
            },
        },
        timers = {
            blessingends = {
                {
                    "expect",{"&difficulty&","==","2"},
                    "expect",{"<sonofafailed>","==","no"},
                    "announce","sonofafailed",
                    "set",{
                        sonofafailed = "yes",
                        blessingwarned = "no"
                    },
                },
            },
            checkenergy = {
                {
                    "expect",{"&getup|boss1&","<=","22"},
                    "expect",{"<blessingwarned>","==","no"},
                    "set",{blessingwarned = "yes"},
                    "alert","blessingsoonwarn",
                },
            },
        },
        events = {
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    -- Solar Winds
                    {
                        "expect",{"#5#","==","74104"},
                        "expect",{"#1#","==","boss1"},
                        "alert","windswarn",
                        "scheduletimer",{"checkenergy", 2},
                    },
                    -- Blessing of the Sun
                    {
                        "expect",{"#2#","==",SN[76352]},
                        "expect",{"#1#","==","boss1"},
                        "alert","blessingwarn",
                        "scheduletimer",{"blessingends", 20},
                        "expect",{"&difficulty&","==","2"},
                        "expect",{"<sonofafailed>","==","no"},
                        "alert","sonofacd",
                    },
                },
            },            
            -- Inferno Leap
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_START",
                spellname = 87653,
                execute = {
                    {
                        "alert","leapwarn",
                    },
                    {
                        "scheduletimer",{"checkenergy", 2},
                    },
                },
            },
            -- Summon Sun Orb
            {
                type = "combatevent",
                eventtype = "SPELL_CAST_SUCCESS",
                spellname = 80352,
                execute = {
                    {
                        "alert","orbwarn",
                    },
                    {
                        "scheduletimer",{"checkenergy", 2},
                    },
                },
            },
            {
                type = "event",
                event = "UNIT_SPELLCAST_INTERRUPTED",
                execute = {
                    -- Inferno Leap
                    {
                        "expect",{"#2#","==",SN[87653]},
                        "expect",{"#1#","find","boss"},
                        "quash","leapwarn",
                    },
                },
            },
            -- Summon Sun Orb
            {
                type = "event",
                event = "UNIT_SPELLCAST_CHANNEL_STOP",
                execute = {
                    {
                        "expect",{"#2#","==",SN[80352]},
                        "expect",{"#1#","find","boss"},
                        "quash","orbwarn",
                    },
                },
            },
            
            -- Solar Fire
            {
                type = "combatevent",
                eventtype = "SPELL_DAMAGE",
                spellname = 89878,
                execute = {
                    {
                        "expect",{"#4#","==","&playerguid&"},
                        "alert","fireselfwarn",
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
        key = "hootrash",
        zone = L.zone["Halls of Origination"],
        category = L.zone["Halls of Origination"],
        name = "Trash",
        triggers = {
            scan = {
                48141, -- Temple Shadowlancer
                48139, -- Temple Swiftstalker
                48140, -- Temple Runecaster
                48143, -- Temple Fireshaper
            },
        },
        onactivate = {
            tracerstart = true,
            combatstop = true,
            combatstart = true,
        },
        userdata = {},
        
        phrasecolors = {
            {"Temple Shadowlancer","GOLD"},
            {"starts channeling","WHITE"},
        },
        raidicons = {
            pactmark = {
                varname = format("%s {%s-%s}",SN[89560],"ENEMY_CAST","Temple Shadowlancer's"),
                type = "MULTIENEMY",
                persist = 6,
                unit = "#1#",
                reset = 5,
                icon = 1,
                total = 2,
                remove = true,
                texture = ST[89560],
            },
        },
        
        alerts = {
            -- Pact of Darkness
            pactwarn = {
                varname = format(L.alert["%s Warning"],SN[89560]),
                type = "centerpopup",
                warningtext = format(L.alert["%s: %s - INTERRUPT"],"Temple Shadowlancer",SN[89560]),
                text = format(L.alert["%s - INTERRUPT"],SN[89560]),
                time = 6,
                color1 = "MAGENTA",
                sound = "ALERT2",
                icon = ST[89560],
                tag = "#1#",
            },
            
        },
        events = {
            -- Pact of Darkness
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_APPLIED",
                spellname = 89560,
                execute = {
                    {
                        "alert","pactwarn",
                        "raidicon","pactmark",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "SPELL_AURA_REMOVED",
                spellname = 89560,
                execute = {
                    {
                        "expect",{"&unitisplayertype|#1#&","==","false"},
                        "quash","pactwarn",
                    },
                },
            },
            {
                type = "combatevent",
                eventtype = "UNIT_DIED",
                execute = {
                    {
                        "expect",{"&npcid|#4#&","==","48141"},
                        "quash",{"pactwarn","#4#"},
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
DXE:RegisterGossip("HoO_VaultOfLights", "We're ready! Go, Brann!", "Brann: Open the door")
