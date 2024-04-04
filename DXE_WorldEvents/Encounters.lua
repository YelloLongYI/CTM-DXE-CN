local L,SN,ST,SL,AL,AT,AN,TI = DXE.L,DXE.SN,DXE.ST,DXE.SL,DXE.AL,DXE.AT,DXE.AN,DXE.TI

------------------------------------
-- AHUNE (MIDSUMMER FIRE FESTIVAL)
------------------------------------

do
    local data = {
        version = 1,
        key = "eventahune",
        zone = L.zone["The Slave Pens"],
        category = L.zone["World Events"],
        name = "Ahune",
        icon = "Interface\\Addons\\DXE_WorldEvents\\Ahune.tga",
        triggers = {
            scan = {
                25740, -- Ahune
                {40446, type = "select_only"}, -- Skar'this the Summoner},
            },
            
        },
        onpullevent = {
            {
                triggers = {
                    say = "The Ice Stone has melted",
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
                25740, -- Ahune
                25865, -- Frozen Core
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = 25865,
        },
        userdata = {
            
        },
        onstart = {
            {
                "alert","submergecd",
            },
        },
        
        phrasecolors = {
            {"Frozen Core","CYAN"},
        },
        
        timers = {
        },
        
        -- Ahune Retreats. His defenses diminish.
        -- boss1  46416 - Ahune Self Stun
        -- 60, 
        -- Ahune will soon resurface.
        -- 30,
        -- The Earthen Ring's Assault Begins. (lol)
        -- boss1  37752 - Stand
        -- nebo
        -- boss1  46402 -- Ahune Resurfaces
        alerts = {           
            -- Ahune appears
            pullcd = {
                varname = format(L.alert["%s"],"Pull Countdown"),
                type = "dropdown",
                text = format(L.alert["%s"],"Ahune appears"),
                time = 14,
                flashtime = 5,
                color1 = "TURQUOISE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[16190],
            },
            -- Submerge
            submergecd = {
                varname = format(L.alert["%s CD"],"Submerge"),
                type = "dropdown",
                text = format(L.alert["Next %s"],"Submerge"),
                time = 60,
                flashtime = 5,
                color1 = "LIGHTBLUE",
                color2 = "RED",
                sound = "MINORWARNING",
                icon = ST[83705],
                audiocd = true,
            },
            submergewarn = {
                varname = format(L.alert["%s Warning"],"Submerge"),
                type = "simple",
                text = format(L.alert["%s!"],"Attack the Frozen Core"),
                time = 1,
                color1 = "GOLD",
                sound = "ALERT10",
                icon = ST[27619],
                emphasizewarning = true,
                flashscreen = true,
            },
            -- Resurface
            resurfacecd = {
                varname = format(L.alert["%s CD"],"Resurface"),
                type = "centerpopup",
                text = format(L.alert["%s"],"Ahune resurfaces"),
                time = 30,
                flashtime = 5,
                color1 = "BLUE",
                color2 = "CYAN",
                sound = "MINORWARNING",
                icon = ST[27619],
                audiocd = true,
            },
            resurfacewarn = {
                varname = format(L.alert["%s Warning"],"Resurface"),
                type = "simple",
                text = format(L.alert["%s"],"Ahune resurfaces"),
                time = 1,
                color1 = "CYAN",
                sound = "ALERT7",
                icon = ST[1139],
            },
            
        },
        events = {
			-- Submerged
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[46416]},
                        "expect",{"#1#","==","boss1"},
                        "quash","submergecd",
                        "alert","submergewarn",
                        "alert","resurfacecd",
                    },
                },
            },
            -- Resurfaces
            {
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
                        "expect",{"#2#","==",SN[46402]},
                        "expect",{"#1#","==","boss1"},
                        "quash","resurfacecd",
                        "alert","submergecd",
                        "alert","resurfacewarn",
                    },
                },
            },
            
        },
    }

    DXE:RegisterEncounter(data)
end

---------------------------------
-- The Crown Chemical Co.
---------------------------------

do
    local data = {
        version = 1,
        key = "eventcrownchemical",
        zone = L.zone["Shadowfang Keep"],
        category = L.zone["World Events"],
        name = "The Crown Chemical Co.",
        triggers = {
            scan = {
                36296, -- Apothecary Hummel
                36565, -- Apothecary Baxter
                36272, -- Apothecary Frye
            },
        },
        onactivate = {
            tracing = {
                36296, -- Apothecary Hummel
                36565, -- Apothecary Baxter
                36272, -- Apothecary Frye
            },
            tracerstart = true,
            combatstop = true,
            combatstart = true,
            defeat = {36296,36565,36272},
        },
        onpullevent = {
            {
                triggers = {
                    say = "Did they bother to tell you",
                },
                invoke = {
                    {
                       "alert","pullcd",
                    },
                },
            },
        },
        userdata = {
            
        },
        onstart = {
            {
                "alert","baxterpullcd",
                "alert","fryepullcd",
            },
        },
        timers = {
        },
        alerts = {
            -- Pull Countdown
            pullcd = {
				varname = format(L.alert["Pull Countdown"]),
				type = "dropdown",
				text = format(L.alert["%s"],"Encounter starts"),
				time = 11,
				flashtime = 10,
				color1 = "TURQUOISE",
                icon = ST[11242],
            },
            -- Pull Countdown
            baxterpullcd = {
				varname = format(L.alert["Baxter Countdown"]),
				type = "dropdown",
				text = format(L.alert["%s"],"Baxter Joins the Fight"),
				time = 6,
				flashtime = 10,
				color1 = "GOLD",
                color2 = "YELLOW",
                icon = ST[68946],
            },
            -- Pull Countdown
            fryepullcd = {
				varname = format(L.alert["Frye Countdown"]),
				type = "dropdown",
				text = format(L.alert["%s"],"Frye Joins the Fight"),
				time = 14,
				flashtime = 10,
				color1 = "RED",
                color2 = "ORANGE",
                icon = ST[68704],
            },
        },
        events = {

        },
    }

    DXE:RegisterEncounter(data)
end
