local addon,L = DXE,DXE.L
local EDB = addon.EDB
local module = addon:NewModule("Options")
addon.Options = module

local db
local opts
local opts_args

local DEFAULT_WIDTH = 1005
local DEFAULT_HEIGHT = 675

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local SM = LibStub("LibSharedMedia-3.0")


local function genblank(order) return {type = "description", name = "", order = order} end
addon.Options.genblank = genblank

local TraversOptions = addon.TraversOptions

local function GetColors(excludeNone,showCustom)
    local colors = {}
    for k,c in pairs(addon.db.profile.Colors) do
        local isCustom = (showCustom and not addon.defaults.profile.Colors[k]) and "*" or ""
        local hex = ("%s|cff%02x%02x%02x%s|r%s"):format(isCustom, c.r*255,c.g*255,c.b*255,L[k],isCustom)
        colors[k] = hex
    end
    
    if not excludeNone then colors["Off"] = "Off" end
        
    return colors
end

local RaidIcons = addon.RaidIcons    
local function GetRaidIcons(includeIconPresets)
    local raidIcons = {}
    for iconIndex,iconData in pairs(RaidIcons.iconsList) do
        raidIcons["custom"..iconIndex] = format("|cff%s%s (%s)|r", iconData.color or "ffffff", iconData.name, iconData.texture)
    end
    
    if includeIconPresets then
        for i=1,8 do
            local iconData = RaidIcons.iconsList[RaidIcons.db.profile[i]]
            raidIcons["preset"..i] = format("|cff%s%s (%s)", iconData.color, "Icon Preset "..i, iconData.texture)
        end
    end
    
    return raidIcons
end

local SwapMode
local pull_timer_colors_args, break_timer_colors_args, lfg_timer_colors_args

-- Initializes the DXE options configuration by setting up various option groups and their settings.
-- This includes:
-- - General addon settings (enabled state, version info)
-- - Alert configurations (bars, sounds, colors)
-- - Encounter-specific settings
-- - Window settings (proximity, alternate power)
-- - Sound configurations
-- - Debug options (when in debug mode)
-- The function organizes options into logical groups with proper ordering and hierarchy.
local function InitializeOptions()
	opts = {
		type = "group",
		name = "DXE",
		handler = addon,
		disabled = function() return not db.profile.Enabled end,
		args = {
			dxe_header = {
				type = "header",
				name = format("%s - %s",L.loader["Deus Vox Encounters"],L.options["Version"])..format(": %s",addon.versionfull),
				order = 1,
				width = "full",
			},
			Enabled = {
				type = "toggle",
				order = 100,
				name = L.options["Enabled"],
				get = "IsEnabled",
				width = "half",
				set = function(info,val) db.profile.Enabled = val
						if val then addon:Enable()
						else addon:Disable() end
				end,
				disabled = function() return false end,
			},
			ToggleLock = {
				type = "execute",
				order = 200,
				name = function() return db.global.Locked and L.options["Show Anchors"] or L.options["Hide Anchors"] end,
				desc = L.options["Toggle frame anchors. You can also toggle this by clicking on the pane's pad lock icon"],
				func = function() addon:ToggleLock() end,
			},
            BarTest = {
                type = "execute",
                name = function() return not addon.Alerts:IsTestingRunning() and L.options["Start Test Alerts"] or L.options["Stop Test Alerts"] end,
                desc = L.options["Fires a dropdown, center popup, and simple alert bars"],
                order = 250,
                func = function() addon.Alerts:BarTest() end,
			},
		},
	}

	module.opts = opts

	opts_args = opts.args

	-- Minimap
	if LibStub("LibDBIcon-1.0",true) then
		local LDBIcon = LibStub("LibDBIcon-1.0")
		opts_args.ShowMinimap = {
			type = "toggle",
			order = 150,
			name = L.options["Minimap"],
			desc = L.options["Show minimap icon"],
			get = function() return not DXEIconDB.hide end,
			set = function(info,v) DXEIconDB.hide = not v; LDBIcon[DXEIconDB.hide and "Hide" or "Show"](LDBIcon,"DXE") end,
			width = "half",
		}
	end
    
    opts_args.AutoLoad = {
        type = "toggle",
        order = 155,
        name = L.options["Auto-Load"],
        desc = L.options["Allows DXE the be loaded automatically upon loading UI."],
        get = function() return DXEAutoLoad end,
        set = function(info,v) DXEAutoLoad = v end,
    }

	---------------------------------------------
	-- UTILITY
	---------------------------------------------

	local GetSounds

	do
		local sounds = {}
		function GetSounds(includeModuleSpecific, key)
			table.wipe(sounds)
			for id,name in pairs(db.profile.Sounds) do
				-- if id:find("^ALERT") or id == "VICTORY" then sounds[id] = id end
                sounds[id] = format("|cff00ff00%s|r",id)
			end
			for id,name in pairs(db.profile.CustomSounds) do
				sounds[id] = format("|cff2fbbff%s|r",id)
			end
			sounds["None"] = L.options["None"]
            if includeModuleSpecific then
                if key and not db.profile.Sounds[key] and not db.profile.CustomSounds[key] then
                    sounds["#ModuleSpecific#"] = L.options["|cffffc600(Module Specific)|r"]
                end
            end
			return sounds
		end
	end

	---------------------------------------------
	-- GENERAL
	---------------------------------------------

	do
		local globals_group = {
			type = "group",
			name = L.options["Globals"],
			order = 50,
			get = function(info)
				local var = info[#info]
				if var:find("Color") then return unpack(db.profile.Globals[var])
				else return db.profile.Globals[var] end
			end,
			set = function(info,v,v2,v3,v4)
				local var = info[#info]
				if var:find("Color") then
					local t = db.profile.Globals[var]
					t[1],t[2],t[3],t[4] = v,v2,v3,v4
					addon["Notify"..var.."Changed"](addon,v,v2,v3,v4)
				else
					db.profile.Globals[var] = v
					addon["Notify"..var.."Changed"](addon,v)
				end
			end,
			args = {
				BarTexture = {
					type = "select",
					order = 100,
					name = L.options["Bar Texture"],
					desc = L.options["Bar texture used throughout the addon"],
					values = SM:HashTable("statusbar"),
					dialogControl = "LSM30_Statusbar",
				},
				Font = {
					order = 200,
					type = "select",
					name = L.options["Main Font"],
					desc = L.options["Font used throughout the addon"],
					values = SM:HashTable("font"),
					dialogControl = "LSM30_Font",
				},
				TimerFont = {
					order = 250,
					type = "select",
					name = L.options["Timer Font"],
					desc = L.options["Font used for timers"],
					values = SM:HashTable("font"),
					dialogControl = "LSM30_Font",
				},
				BackgroundTexture = {
					order = 260,
					type = "select",
					name = L.options["Background Texture"],
					desc = L.options["Background texture used throughout the addon"],
					values = SM:HashTable("background"),
					dialogControl = "LSM30_Background",
				},
				BackgroundInset = {
					order = 280,
					type = "range",
					name = L.options["Background Inset"],
					desc = L.options["How far in or out the background is from the edges"],
					min = -20,
					max = 20,
					step = 0.1,
				},
				Border = {
					order = 300,
					type = "select",
					name = L.options["Border"],
					desc = L.options["Border used throughout the addon"],
					values = SM:HashTable("border"),
					dialogControl = "LSM30_Border",
				},
				BorderEdgeSize = {
					order = 310,
					type = "range",
					name = L.options["Border Edge Size"],
					desc = L.options["Border size used througout the addon"],
					min = 0.1,
					max = 20,
					step = 0.1,
				},
				blank = genblank(350),
				BackgroundColor = {
					order = 400,
					type = "color",
					name = L.options["Background Color"],
					desc = L.options["Background color used throughout the addon"],
					hasAlpha = true,
				},
				BorderColor = {
					order = 500,
					type = "color",
					name = L.options["Border Color"],
					desc = L.options["Border color used throughout the addon"],
					hasAlpha = true,
				},
                EncounterCategories = {
                    order = 600,
                    type = "toggle",
                    name = L.options["Extra Encounter Subcategories"],
					desc = L.options["Some encounters have alerts divided into categories based on the Phase or the Boss to make the bosses with a lot of alerts more arranged."],
                    get = function(info) return db.global[info[#info]] end,
                    set = function(info,v) 
                        if db.global[info[#info]] ~= v then
                            db.global[info[#info]] = v
                            SwapMode(db.global.OptMode)
                        end
                    end,
                    width = "double",
                },
                Realm = {
					order = 620,
					type = "select",
					name = L.options["Realm Name"],
					desc = L.options["Realm Server Name"],
					values = {
						Apollo = L.options["Apollo"],
						JRG = L.options["Jingrange"],
                        Hongxi = L.options["Hongxi"],
					},
                    -- get = function(info) return db.profile.GENERAL.Realm end,
                    -- set = function(info,v)
					-- 	db.profile.GENERAL.Realm = v                       
					-- end,
				},
			},
		}

		opts_args.globals_group = globals_group

	end

	---------------------------------------------
	-- PANE
	---------------------------------------------

	do
		local pane_group = {
			type = "group",
			name = L.options["Pane"],
			order = 100,
            childGroups = "tab",
			get = function(info)
				local var = info[#info]
				if var:find("Color") then return unpack(db.profile.Pane[var])
				else return db.profile.Pane[var] end end,
			set = function(info,v) db.profile.Pane[info[#info]] = v end,
			args = {}
		}
		opts_args.pane_group = pane_group

		local pane_args = pane_group.args
		do
			local visual_group = {
                type = "group",
                name = "Display",
                order = 100,
                args = {},
            }
            
            pane_args.visual_group = visual_group
            
            local visibility_group = {
                type = "group",
                name = "",
                inline = true,
                order = 100,
                set = function(info,v)
                    db.profile.Pane[info[#info]] = v
                    addon:UpdatePaneVisibility()
                end,
                disabled = function() return not db.profile.Pane.Show end,
                args = {
                    Show = {
                        order = 100,
                        type = "toggle",
                        name = L.options["Show Pane"],
                        desc = L.options["Toggle the visibility of the pane"],
                        disabled = function() return false end,
                    },
                    ShowTest = {
                        order = 125,
                        type = "toggle",
                        name = L.options["Show Test Pane"],
                        desc = L.options["Toggle the visibility of the pane with 'default' encounter."],
                        disabled = function() return not db.profile.Pane.Show end,
                    },
                    showpane_desc = {
                        order = 150,
                        type = "description",
                        name = L.options["Show Pane"].."...",
                        fontSize = "large",
                    },
                    OnlyIfRunning = {
                        order = 210,
                        type = "toggle",
                        name = L.options["During an encounter"],
                        desc = L.options["Show the pane only if an encounter is running"],
                    },
                    OnlyInParty = {
                        order = 220,
                        type = "toggle",
                        name = L.options["While in a party group"],
                        desc = L.options["Show the pane only in party"],
                    },
                    OnlyInPartyInstance = {
                        order = 230,
                        type = "toggle",
                        name = L.options["While inside a party instance"],
                        desc = L.options["Show the pane only in party instances"],
                        width = "double",
                    },
                    show_pane_blank1 = genblank(235),
                    OnlyOnMouseover = {
                        order = 240,
                        type = "toggle",
                        name = L.options["On mouseover"],
                        desc = L.options["Show the pane only if the mouse is over it"],
                    },
                    OnlyInRaid = {
                        order = 250,
                        type = "toggle",
                        name = L.options["While in a raid group"],
                        desc = L.options["Show the pane only in raids"],
                    },
                    OnlyInRaidInstance = {
                        order = 260,
                        type = "toggle",
                        name = L.options["While inside a raid instance"],
                        desc = L.options["Show the pane only in raid instances"],
                        width = "double",
                    },
                },
            }
            
            local visual_args = visual_group.args
            visual_args.visibility_group = visibility_group
            
            local skin_group = {
                type = "group",
                name = "",
                order = 200,
                inline = true,
                set = function(info,v,v2,v3,v4)
                    local var = info[#info]
                    if var:find("Color") then db.profile.Pane[var] = {v,v2,v3,v4}
                    else db.profile.Pane[var] = v
                    end
                    addon:SkinPane()
                end,
                args = {
                    BarGrowth = {
                        order = 200,
                        type = "select",
                        name = L.options["Bar Growth"],
                        desc = L.options["Direction health watcher bars grow. If set to automatic, they grow based on where the pane is"],
                        values = {AUTOMATIC = L.options["Automatic"], UP = L.options["Up"], DOWN = L.options["Down"]},
                        set = function(info,v)
                            db.profile.Pane.BarGrowth = v
                            addon:LayoutHealthWatchers()
                        end,
                        disabled = function() return not db.profile.Pane.Show end,
                    },
                    Scale = {
                        order = 300,
                        type = "range",
                        name = L.options["Scale"],
                        desc = L.options["Adjust the scale of the pane"],
                        set = function(info,v)
                            db.profile.Pane.Scale = v
                            addon:ScalePaneAndCenter()
                        end,
                        min = 0.1,
                        max = 2,
                        step = 0.1,
                    },
                    Width = {
                        order = 310,
                        type = "range",
                        name = L.options["Width"],
                        desc = L.options["Adjust the width of the pane"],
                        set = function(info, v)
                            db.profile.Pane.Width = v
                            addon:SetPaneWidth()
                        end,
                        min = 175,
                        max = 500,
                        step = 1,
                    },
                    BarSpacing = {
                        order = 320,
                        type = "range",
                        name = L.options["Bar Spacing"],
                        desc = L.options["How far apart health bars are"],
                        set = function(info, v)
                            db.profile.Pane.BarSpacing = v
                            addon:LayoutHealthWatchers()
                        end,
                        min = 0,
                        max = 50,
                        step = 0.1,
                    },
                    font_header = {
                        type = "header",
                        name = L.options["Font"],
                        order = 900,
                    },
                    TitleFontSize = {
                        order = 901,
                        type = "range",
                        name = L.options["Title Font Size"],
                        desc = L.options["Select a font size used on health watchers"],
                        min = 8,
                        max = 20,
                        step = 1,
                    },
                    HealthFontSize = {
                        order = 1000,
                        type = "range",
                        name = L.options["Health Font Size"],
                        desc = L.options["Select a font size used on health watchers"],
                        min = 8,
                        max = 20,
                        step = 1,
                    },
                    FontColor = {
                        order = 1100,
                        type = "color",
                        name = L.options["Font Color"],
                        desc = L.options["Set a font color used on health watchers"],
                    },
                    misc_header = {
                        type = "header",
                        name = L.options["Visuals"],
                        order = 1200,
                    },
                    BarTexture = {
                        type = "select",
                        order = 1225,
                        name = L.options["Bar Texture"],
                        desc = L.options["Bar texture used for Health Bars."],
                        values = SM:HashTable("statusbar"),
                        dialogControl = "LSM30_Statusbar",
                        set = function(info,v) 
                            db.profile.Pane.BarTexture = v
                            addon["NotifyBarTextureChanged"](addon,v)
                        end
                    },
                    blank1 = genblank(600),
                    Border = {
                        order = 1250,
                        type = "select",
                        name = L.options["Border for the Pane"],
                        desc = L.options["Border used for Pane and its Health Bars."],
                        values = SM:HashTable("border"),
                        dialogControl = "LSM30_Border",
                    },
                    BorderEdgeSize = {
                        order = 1260,
                        type = "range",
                        name = L.options["Border Edge Size"],
                        desc = L.options["Border size used for Pane's Health Bar."],
                        min = 1,
                        max = 20,
                        step = 0.1,
                    },
                    BorderColor = {
                        order = 1270,
                        type = "color",
                        name = L.options["Border Color"],
                        desc = L.options["The color of the health bar's border."],
                    },
                    blank2 = genblank(350),
                    SelectedBorder = {
                        order = 1280,
                        type = "select",
                        name = L.options["Border for the Pane"],
                        desc = L.options["Border used for Pane's Health Bar that is selected."],
                        values = SM:HashTable("border"),
                        dialogControl = "LSM30_Border",
                    },
                    SelectedBorderEdgeSize = {
                        order = 1285,
                        type = "range",
                        name = L.options["Selected Border Edge Size"],
                        desc = L.options["Border size used for Pane's Health Bar that is selected."],
                        min = 1,
                        max = 20,
                        step = 0.1,
                    },
                    SelectedBorderColor = {
                        order = 1290,
                        type = "color",
                        name = L.options["Selected Border Color"],
                        desc = L.options["The color of the selected health bar."],
                    },
                    blank3 = genblank(350),
                    NeutralColor = {
                        order = 1300,
                        type = "color",
                        name = L.options["Neutral Color"],
                        desc = L.options["The color of the health bar when first shown"],
                    },
                    LostColor = {
                        order = 1400,
                        type = "color",
                        name = L.options["Lost Color"],
                        desc = L.options["The color of the health bar after losing the mob."],
                    },
                    BarShowSpark = {
                        type = "toggle",
                        name = L.options["Show spark"],
                        desc = L.options["Enables displaying of sparks"],
                        order = 1450,
                        get = function(info) return db.profile.Pane["BarShowSpark"] end,
                        set = function(info,v) db.profile.Pane["BarShowSpark"] = v addon:UpdatePhaseMarkersVisibility() end,
                    },
                },
            }
            
            visual_args.skin_group = skin_group
            
            local buttons_group = {
                type = "group",
                name = "Buttons",
                order = 150,
                args = {
                    
                },
            }
            pane_args.buttons_group = buttons_group
            for i,data in ipairs(addon.PaneButtonNames) do
                buttons_group.args[data.name] = {
                    type = "toggle",
                    name = format("|T%s:16:16|t %s", data.texture, data.name),
                    order = i*50,
                    get = function(info) return addon.db.profile.Pane.ButtonsVisibility[info[#info]] end,
                    set = function(info,value) addon.db.profile.Pane.ButtonsVisibility[info[#info]] = value;addon:UpdatePaneButtons() end,
                }
            end
            
            local speedkill_group = {
                type = "group",
                name = "Speed kills",
                order = 200,
                args = {
                    ShowBestTimePane = {
                        type = "toggle",
                        name = L.options["Display Speed kill record on Pane"],
                        desc = L.options["Enabling this option will extend the Pane to show information concerning the speed kill record."],
                        width = "double",
                        order = 710,
                        get = function(info) return db.profile.Pane["ShowBestTimePane"] end,
                        set = function(info,v) db.profile.Pane["ShowBestTimePane"] = v addon:UpdateBestTimer(true, true) end,
                    },
                    RecordBestTime = {
                        type = "toggle",
                        name = L.options["Record speed kills"],
                        desc = L.options["Enable recording of the best speed kill time."],
                        width = "double",
                        order = 720,
                        get = function(info) return db.profile.Pane["RecordBestTime"] end,
                        set = function(info,v) db.profile.Pane["RecordBestTime"] = v end,
                    },
                    AnnounceRecordKillOnScreen = {
                        type = "toggle",
                        name = L.options["Display speed kill record on screen"],
                        desc = L.options["Enable displaying alert of a new speed kill record."],
                        width = "double",
                        order = 750,
                        get = function(info) return db.profile.Pane["AnnounceRecordKillOnScreen"] end,
                        set = function(info,v) db.profile.Pane["AnnounceRecordKillOnScreen"] = v end,
                    },
                    ScreenshotBestTime = {
                        type = "toggle",
                        name = L.options["Speed kill screenshot"],
                        desc = L.options["Enable taking screenshot everytime you break your speed kill record."],
                        width = "double",
                        order = 760,
                        get = function(info) return db.profile.Pane["ScreenshotBestTime"] end,
                        set = function(info,v) db.profile.Pane["ScreenshotBestTime"] = v end,
                    },
                    
                },
            }
            
            pane_args.speedkill_group = speedkill_group
            
            local phasemarkers_group = {
                type = "group",
                name = "Phase Markers",
                order = 300,
                args = {
                    PhaseMarkersEnable = {
                        type = "toggle",
                        name = L.options["Enable Phase Markers"],
                        desc = L.options["Enable displaying of markers on HealthWatchers that denote important milestones of bosses HP."],
                        width = "double",
                        order = 801,
                        get = function(info) return db.profile.Pane["PhaseMarkersEnable"] end,
                        set = function(info,v) db.profile.Pane["PhaseMarkersEnable"] = v addon:UpdatePhaseMarkersVisibility() end,
                    },
                    PhaseMarkersShowDescription = {
                        type = "toggle",
                        name = L.options["Show Phase Markers description"],
                        desc = L.options["Show Phase Marker description in its tooltip."],
                        width = "double",
                        order = 802,
                        get = function(info) return db.profile.Pane["PhaseMarkersShowDescription"] end,
                        set = function(info,v) db.profile.Pane["PhaseMarkersShowDescription"] = v end,
                    },
                },
            }
            
            pane_args.phasemarkers_group = phasemarkers_group
            local pull_selected = db.profile.SpecialTimers.PullTimerPrefered
            local break_selected = 1
            local pull_add_value
            local break_add_value
            local pullbreaks_group = {
                type = "group",
                name = "Pulls & Breaks",
                order = 400,
                args = {
                    pulls_list = {
                        type = "select",
                        name = L.options["Pull Presets"],
                        desc = L.options["List of pull pre-sets that can be activated from Pane."],
                        order = 11,
                        values = function() 
                            local list = {}
                            for i,time in ipairs(db.profile.SpecialTimers.PullTimers) do
                                if i == db.profile.SpecialTimers.PullTimerPrefered then
                                    list[i] = format("|cff00ff00%s|r",addon:TimeToText(time))
                                else
                                    list[i] = addon:TimeToText(time)
                                end
                            end
                            
                            return list
                        end,
                        get = function(info) return pull_selected end,
                        set = function(info, v) pull_selected = v end,
                    },
                    pulls_prefered = {
                        type = "execute",
                        name = L.options["Set as default"],
                        desc = L.options["Sets the seleced Pull time as default for Pane Pull button."],
                        order = 21,
                        func = function() db.profile.SpecialTimers.PullTimerPrefered = pull_selected end,
                        disabled = function() return db.profile.SpecialTimers.PullTimerPrefered == pull_selected end,
                    },
                    pulls_remove_button = {
                        type = "execute",
                        name = L.options["Remove"],
                        order = 31,
                        func = function()
                            local PullTimers = db.profile.SpecialTimers.PullTimers
                            if #PullTimers > 1 then
                                local defaultPreset = PullTimers[db.profile.SpecialTimers.PullTimerPrefered]
                                local defaultFound = false
                                table.remove(PullTimers, pull_selected)
                                pull_selected = next(PullTimers)
                                for i,preset in ipairs(PullTimers) do
                                    if preset == defaultPreset then
                                        db.profile.SpecialTimers.PullTimerPrefered = i
                                        defaultFound = true
                                        break
                                    end
                                end
                                
                                if not defaultFound then
                                    db.profile.SpecialTimers.PullTimerPrefered = 1
                                end
                            else
                                addon:Print("At least 1 Pull Pre-set has to be present.")
                            end
                        end,
                        disabled = function() return not pull_selected end,
                    },
                    pulls_add = {
                        type = "input",
                        name = L.options["Pre-set to add"],
                        desc = L.options["Type the number of seconds for the new pull pre-set."],
                        order = 41,
                        get = function(info) return pull_add_value and tostring(pull_add_value) or "" end,
                        set = function(info, v) if type(tonumber(v)) == "number" then pull_add_value = math.floor(tonumber(v)) end end,
                    },
                    pulls_add_button = {
                        type = "execute",
                        name = L.options["Add"],
                        order = 51,
                        func = function()
                            if pull_add_value then
                                local PullTimers = db.profile.SpecialTimers.PullTimers
                                local defaultPreset = PullTimers[db.profile.SpecialTimers.PullTimerPrefered]
                                local presetFound = false
                                for i,preset in ipairs(PullTimers) do
                                    if preset == pull_add_value then
                                        presetFound = true
                                        break
                                    end
                                end
                                if not presetFound then                                
                                    PullTimers[#PullTimers+1] = pull_add_value
                                    table.sort(PullTimers)
                                    local selectSet = false
                                    local defaultSet = false
                                    for i,preset in ipairs(PullTimers) do
                                        if selectSet and defaultSet then break end
                                        if preset == pull_add_value then 
                                            pull_selected = i
                                            selectSet = true
                                        end
                                        if preset == defaultPreset then
                                            db.profile.SpecialTimers.PullTimerPrefered = i
                                            defaultSet = true
                                        end
                                    end
                                else
                                    addon:Print(format("%s is already on the list.", pull_add_value))
                                end
                                pull_add_value = nil
                            end
                        end,
                        disabled = function() return not pull_add_value end,
                    },
                    pulls_blank = genblank(13),
                    pulls_blank2 = genblank(23),
                    pulls_blank3 = genblank(33),
                    pulls_blank4 = genblank(43),
                    pulls_blank6 = genblank(53),
                    breaks_list = {
                        type = "select",
                        name = L.options["Break Presets"],
                        desc = L.options["List of break presets that can be activated from Pane."],
                        order = 12,
                        values = function() 
                            local list = {}
                            
                            for i,time in ipairs(db.profile.SpecialTimers.BreakTimers) do
                                list[i] = addon:TimeToText(time)
                            end
                            
                            return list
                        end,
                        get = function(info) return break_selected end,
                        set = function(info, v) break_selected = v end,
                    },
                    breaks_prefered = genblank(22),
                    breaks_remove_button = {
                        type = "execute",
                        name = L.options["Remove"],
                        order = 32,
                        func = function()
                            local BreakTimers = db.profile.SpecialTimers.BreakTimers
                            if #BreakTimers > 1 then
                                local defaultPreset = BreakTimers[db.profile.SpecialTimers.BreakTimerPrefered]
                                table.remove(BreakTimers, break_selected)
                                break_selected = next(BreakTimers)
                                local defaultFound = false
                                for i,preset in ipairs(BreakTimers) do
                                    if preset == defaultPreset then
                                        db.profile.SpecialTimers.BreakTimerPrefered = i
                                        defaultFound = true
                                        break
                                    end
                                end
                                if not defaultFound then
                                    db.profile.SpecialTimers.BreakTimerPrefered = 1
                                end
                            else
                                addon:Print("At least 1 Break Pre-set has to be present.")
                            end
                        end,
                        disabled = function() return not break_selected end,
                    },
                    breaks_add = {
                        type = "input",
                        name = L.options["Pre-set to add"],
                        desc = L.options["Type the number of seconds for the new break pre-set."],
                        order = 42,
                        get = function(info) return break_add_value and tostring(break_add_value) or "" end,
                        set = function(info, v) if type(tonumber(v)) == "number" then break_add_value = math.floor(tonumber(v)) end end,
                    },
                    breaks_add_button = {
                        type = "execute",
                        name = L.options["Add"],
                        order = 52,
                        func = function()
                            if break_add_value then
                                local BreakTimers = db.profile.SpecialTimers.BreakTimers
                                local defaultPreset = BreakTimers[db.profile.SpecialTimers.BreakTimerPrefered]
                                
                                local presetFound = false
                                for i,preset in ipairs(BreakTimers) do
                                    if preset == break_add_value*60 then
                                        presetFound = true
                                        break
                                    end
                                end
                                
                                if not presetFound then
                                    BreakTimers[#BreakTimers+1] = break_add_value*60
                                    table.sort(BreakTimers)
                                    local selectSet = false
                                    local defaultSet = false
                                    for i,preset in ipairs(BreakTimers) do
                                        if selectSet and defaultSet then break end
                                        if preset == break_add_value then 
                                            break_selected = i
                                            selectSet = true
                                        end
                                        if preset == defaultPreset then
                                            db.profile.SpecialTimers.BreakTimerPrefered = i
                                            defaultSet = true
                                        end
                                    end                                
                                else
                                    addon:Print(format("%s is already on the list.", break_add_value))
                                end
                                break_add_value = nil
                            end
                        end,
                        disabled = function() return not break_add_value end,
                    },
                },
            }
            
            pane_args.pullbreaks_group = pullbreaks_group
        end
	end

	---------------------------------------------
	-- MISCELLANEOUS
	---------------------------------------------
	do
        local selected_cinematic
        local selected_gossip
		local features_group = {
            type = "group",
            name = L.options["Features"],
            order = 300,
            childGroups = "tab",
            args = {
                misc_group = {
                    type = "group",
                    name = L.options["Miscellaneous"],
                    get = function(info) return db.profile.Misc[info[#info]] end,
                    set = function(info,v) db.profile.Misc[info[#info]] = v end,
                    order = 400,
                    args = {
                        BlockRaidWarningFrame = {
                            type = "toggle",
                            name = L.options["Block raid warning frame messages from other boss mods"],
                            order = 100,
                            width = "full",
                        },
                        BlockRaidWarningMessages = {
                            type = "toggle",
                            name = L.options["Block raid warning messages, in the chat log, from other boss mods"],
                            order = 200,
                            width = "full",
                        },
                        BlockBossEmoteFrame = {
                            type = "toggle",
                            name = L.options["Block boss emote frame messages"],
                            order = 300,
                            width = "full",
                        },
                        BlockBossEmoteMessages = {
                            type = "toggle",
                            name = L.options["Block boss emote messages in the chat log"],
                            order = 400,
                            width = "full",
                        },
                        HideBlizzardBossFrames = {
                            type = "toggle",
                            name = L.options["Hide the default Blizzard boss frames"],
                            desc = L.options["Hiding the frames is possible only outside of combat. Showing the frames on the other hand will not take effect until the UI is reloaded."],
                            order = 450,
                            width = "full",
                            disabled = function() addon:SetupBlizzardBossFrames() return false end,
                        },
                    },
                },
                autogossip_group = {
                    type = "group",
                    name = L.options["Auto Gossip"],
                    order = 200,
                    get = function(info) return addon.AutoGossip.db.profile[info[#info]] end,
                    set = function(info,v) addon.AutoGossip.db.profile[info[#info]] = v end,
                    args = {
                        AutoGossip = {
                            type = "toggle",
                            name = L.options["Automatically Activate Gossips"],
                            desc = L.options["Automatically activates predefined gossips."],
                            order = 200,
                            width = "double",
                        },
                        PrintActivationMessages = {
                            type = "toggle",
                            name = L.options["Print Activation Message"],
                            desc = L.options["Prints a message informing about the activated gossip."],
                            order = 300,
                            width = "double",
                        },
                        SelectGossip = {
                            type = "select",
                            name = L.options["Select Cinematic / Movie"],
                            order = 400,
                            width = "double",
                            values = function() 
                                local values = {}
                                for gossipKey,gossipData in pairs(addon.AutoGossip.gossipDB) do
                                    local color = addon.AutoGossip.db.profile.Gossips[gossipKey] and "00ff00" or "ff0000"
                                    values[gossipKey] = format("|cff%s%s|r",color,gossipData.name)
                                end
                                
                                if not selected_gossip then selected_gossip = next(values) end
                                
                                return values
                            end,
                            set = function(info,v) selected_gossip = v end,
                            get = function(info) return selected_gossip end,
                        },
                        ToggleGossip = {
                            type = "execute",
                            name = function() return not addon.AutoGossip.db.profile.Gossips[selected_gossip] and "Enable" or "Disable" end,
                            order = 500,
                            func = function() addon.AutoGossip.db.profile.Gossips[selected_gossip] = not addon.AutoGossip.db.profile.Gossips[selected_gossip] end,
                            disabled = function() return not selected_gossip end,
                        },
                    },
                },
                cinemablock_group = {
                    type = "group",
                    name = L.options["Cinematics Blocker"],
                    order = 300,
                    get = function(info) return addon.CinemaBlock.db.profile[info[#info]] end,
                    set = function(info,v) addon.CinemaBlock.db.profile[info[#info]] = v end,
                    args = {
                        SkipCinematics = {
                            type = "toggle",
                            name = L.options["Automatically Skip Cinematics"],
                            desc = L.options["Automatically skips cinematics that you've already watched at least once."],
                            order = 200,
                            width = "double",
                        },
                        PrintSkipMessages = {
                            type = "toggle",
                            name = L.options["Print Skip Message"],
                            desc = L.options["Prints a message informing about the skipped cinematic."],
                            order = 300,
                            width = "double",
                        },
                        FixCinematicsInDeath = {
                            type = "toggle",
                            name = L.options["Fix Cinematics While Dead"],
                            desc = L.options["When the player's dead the CinematicFrame will not show leaving you having to watch the entire cinematic. If enabled cinematics should behave the same as you were alive."],
                            order = 350,
                            width = "double",
                        },
                        SkipMovies = {
                            type = "toggle",
                            name = L.options["Automatically Skip Movies"],
                            desc = L.options["Automatically skips movies that you've already watched at least once."],
                            order = 225,
                            width = "double",
                        },
                        blankcinema = genblank(375),
                        SelectCinematic = {
                            type = "select",
                            name = L.options["Select Cinematic / Movie"],
                            order = 400,
                            width = "double",
                            values = function() 
                                local values = {}
                                for k,v in pairs(addon.CinemaBlock.cinematicsDB) do values[k] = v.name end
                                for k,v in pairs(addon.CinemaBlock.movieDB) do values[tostring(k)] = v.name end
                                return values
                            end,
                            set = function(info,v) selected_cinematic = v end,
                            get = function(info) return selected_cinematic end,
                        },
                        CinematicStatus = {
                            type = "description",
                            order = 500,
                            name = function()
                                if not selected_cinematic then
                                    return "   |cffff0000Please make a selection|r"
                                else
                                    local cpfl = addon.CinemaBlock.db.profile
                                    local WatchStatus = addon.CinemaBlock.WatchStatus
                                    local status
                                    local cinematicStatus = cpfl.WatchedCinematics[selected_cinematic]
                                    local movieStatus = cpfl.WatchedMovies[tonumber(selected_cinematic)]
                                    
                                    if cinematicStatus then
                                        status = WatchStatus[cinematicStatus]
                                    elseif movieStatus then
                                        status = WatchStatus[movieStatus]
                                    else
                                        status = WatchStatus[WatchStatus.HAVE_NOT_SEEN]
                                    end
                                    
                                    return format("   Status: |cffffff00%s|r",status)
                                end
                            end,
                            fontSize = "medium",
                            width = "double",
                        },
                        SelectCinematicLabel = {
                            type = "description",
                            name = L.options["The list only includes Cinematics / Movies from the |cffffff00Loaded instance modules|r.\nIf the list doesn't contain the requested Cinematic / Movie load the module via |cffffff00Encounters tab|r on the left."],
                            order = 700,
                            width = "full",
                        },
                        SetToHaveNotSeen = {
                            type = "execute",
                            name = L.options["Set to 'Have Not Seen'"],
                            desc = L.options["Sets the settings for the selected cinematic so that you can watch it next time but everytime after that it will be skipped."],
                            order = 800,
                            disabled = function() return not selected_cinematic end,
                            func = function() 
                                if not selected_cinematic then return end
                                
                                if tonumber(selected_cinematic) ~= "nil" then
                                    addon.CinemaBlock.db.profile.WatchedMovies[tonumber(selected_cinematic)] = addon.CinemaBlock.WatchStatus.HAVE_NOT_SEEN
                                else
                                    addon.CinemaBlock.db.profile.WatchedCinematics[selected_cinematic] = addon.CinemaBlock.WatchStatus.HAVE_NOT_SEEN
                                end
                            end,
                        },
                        SetToAlreadyHaveSeen = {
                            type = "execute",
                            name = L.options["Set to 'Already Have Seen'"],
                            desc = L.options["Sets the settings for the selected cinematic so that it will be skipped everytime."],
                            order = 900,
                            width = "double",
                            disabled = function() return not selected_cinematic end,
                            func = function() 
                                if not selected_cinematic then return end
                                
                                if tonumber(selected_cinematic) ~= "nil" then
                                    addon.CinemaBlock.db.profile.WatchedMovies[tonumber(selected_cinematic)] = addon.CinemaBlock.WatchStatus.HAVE_SEEN
                                else
                                    addon.CinemaBlock.db.profile.WatchedCinematics[selected_cinematic] = addon.CinemaBlock.WatchStatus.HAVE_SEEN
                                end
                            end,
                        },
                        SetToIgnore = {
                            type = "execute",
                            name = L.options["Set to 'Ignore'"],
                            desc = L.options["Sets the settings for the selected cinematic so that you can watch it everytime."],
                            order = 1000,
                            disabled = function() return not selected_cinematic end,
                            func = function() 
                                if not selected_cinematic then return end
                                
                                if tonumber(selected_cinematic) ~= nil then
                                    addon.CinemaBlock.db.profile.WatchedMovies[tonumber(selected_cinematic)] = addon.CinemaBlock.WatchStatus.IGNORE
                                else
                                    addon.CinemaBlock.db.profile.WatchedCinematics[selected_cinematic] = addon.CinemaBlock.WatchStatus.IGNORE
                                end
                            end,
                        },
                        PlayMovie = {
                            type = "execute",
                            name = L.options["Play Movie"],
                            desc = L.options["Plays the selected movie."],
                            order = 1100,
                            disabled = function() return tonumber(selected_cinematic) == nil end,
                            func = function()
                                MovieFrame_PlayMovie(MovieFrame, tonumber(selected_cinematic))
                            end,
                        },
                        
                    },
                },
                rolecheck_group = {
                    type = "group",
                    name = L.options["Role Check Assistant"],
                    order = 100,
                    get = function(info) return addon.db.profile.RoleCheck[info[#info]] end,
                    set = function(info,v) addon.db.profile.RoleCheck[info[#info]] = v end,
                    args = {
                        SoundThrottle = {
                            type = "range",
                            name = L.options["Sound Throttle Time"],
                            desc = L.options["Minimum number of seconds between two DXE role check sounds."],
                            order = 200,
                        },
                        SuppressWhenRoleSelected = {
                            type = "toggle",
                            name = L.options["Accept Redundant Role Check"],
                            desc = L.options["Automatically selects the role you have already chosen when additional role check is shown."],
                            order = 300,
                            width = "double",
                        },
                        AutoSelectRoleRespec = {
                            type = "toggle",
                            name = L.options["Auto-Select Role After Talent Tree Change"],
                            desc = L.options["Automatically performs the role selection process after you switch between your primary and secondary talent tree."],
                            order = 400,
                            width = "double",
                        },
                        autoselectrole_group = {
                            type = "group",
                            name = "",
                            inline = true,
                            order = 500,
                            get = function(info) return addon.db.profile.RoleCheck.AutoSelectRole[info[#info]] end,
                            set = function(info,v) addon.db.profile.RoleCheck.AutoSelectRole[info[#info]] = v end,
                            args = {
                                label = {
                                    type = "description",
                                    name = "Auto-Select Your Role:",
                                    order = 50,
                                    width = "double",
                                },
                                label_blank = genblank(75),
                                none = {
                                    type = "toggle",
                                    name = L.options["Outside Any Instance"],
                                    desc = L.options["Automatically selects the role depending on your talent specs if you are not in any instance.."],
                                    order = 100,
                                    width = "double",
                                },
                                party = {
                                    type = "toggle",
                                    name = L.options["In a 5-player Dungeon"],
                                    desc = L.options["Automatically selects the role depending on your talent specs if you are inside a 5-player dungeon."],
                                    order = 200,
                                    width = "double",
                                },
                                raid = {
                                    type = "toggle",
                                    name = L.options["In a Raid Instance"],
                                    desc = L.options["Automatically selects the role depending on your talent specs if you are inside a raid instance."],
                                    order = 300,
                                    width = "double",
                                },
                                pvp = {
                                    type = "toggle",
                                    name = L.options["In a Battleground"],
                                    desc = L.options["Automatically selects the role depending on your talent specs if you are inside a Battleground."],
                                    order = 400,
                                    width = "double",
                                },
                            },
                        },
                    },
                },
            }
        }
        
		opts_args.features_group = features_group
	end
  
  	---------------------------------------------
	-- SPECIAL TIMERS & WARNINGS
	---------------------------------------------
	do
    local handler = {}
    local special_timers_group = {
        type = "group",
        name = L.options["Special Alerts"],
        handler = handler,
        order = 350,
        childGroups = "tab",
        args = {
            ----------------
            -- PULL TIMER --
            ----------------
            pull_timer_group = {
                type = "group",
                name = L.options["Pull timer"],
                order = 100,
                args = {
                    PullTimerEnabled = {
                        type = "toggle",
                        name = L.options["Enabled"],
                        width = "half",
                        order = 318,
                        get = function(info) return db.profile.SpecialTimers["PullTimerEnabled"] end,
                        set = function(info,v) db.profile.SpecialTimers["PullTimerEnabled"] = v if not v then addon.Alerts:QuashByPattern("DBMpull") end end,
                    },
                    pull_timer_colors_group = {
                        type = "group",
                        name = L.options["Options"],
                        order = 320,
                        inline = true,
                        args = {
                            PullColor1 = {
                                type = "select",
                                name = L.options["Main Color"],
                                order = 321,
                                handler = Alerts,
                                values = GetColors(true),
                                disabled = function(info) return not db.profile.SpecialTimers["PullTimerEnabled"] end,
                                get = function(info) return db.profile.SpecialTimers["PullColor1"] end,
                                set = function(info,v) db.profile.SpecialTimers["PullColor1"] = v end, 
                            },
                            PullColor2 = {
                                type = "select",
                                name = L.options["Flash Color"],
                                order = 322,
                                handler = Alerts,
                                values = GetColors(false),
                                disabled = function(info) return not db.profile.SpecialTimers["PullTimerEnabled"] end,
                                get = function(info) return db.profile.SpecialTimers["PullColor2"] end,
                                set = function(info,v) db.profile.SpecialTimers["PullColor2"] = v end,
                            },
                            TestPullTimer = {
                                type = "execute",
                                name = L.options["Test"],
                                desc = "Tests the pull timer with selected options.",
                                order = 323,
                                func = function() 
                                    addon:PullTimer(15)
                                end,
                                width = "half",
                            },
                            countdown_voice_identifier = {
                                type = "select",
                                name = L.options["Countdown Voice"],
                                order = 325,
                                width = "double",
                                get = function()
                                    local alertsPfl = addon.Countdown.db.profile
                                    if alertsPfl.CountdownVoice == "#off#" or alertsPfl.CountdownVoice == "#default#" then
                                        return alertsPfl.CountdownVoice
                                    elseif addon.Alerts.CountdownVoicesDB[alertsPfl.CountdownVoice] then
                                        return alertsPfl.CountdownVoice
                                    else
                                        return "#default#"
                                    end
                                end,
                                set = function(info,v) addon.Countdown.db.profile.CountdownVoice = v end,
                                values = function() 
                                    local voiceList = {}
                                    voiceList["#off#"] = format("|cffffffff%s|r","|cffffff00Disabled|r")
                                    voiceList["#default#"] = format("|cffffff00Default voice|r (%s)",addon.Alerts.db.profile.CountdownVoice)
                                    for k,v in pairs(addon.Alerts.CountdownVoicesDB) do
                                        voiceList[k] = k
                                    end
                                    return voiceList
                                end
                            },
                            CancelOnPull = {
                                type = "toggle",
                                name = L.options["Cancel on pull"],
                                desc = L.options["Cancels and hides the pull timer and grand countdown on encounter pull."],
                                width = "full",
                                order = 328,
                                get = function() return db.profile.SpecialTimers.PullTimerCancelOnPull end,
                                set = function(info,v) db.profile.SpecialTimers.PullTimerCancelOnPull = v end
                            },
                            BigCountdownEnabled = {
                                type = "toggle",
                                name = L.options["Enable Grand Countdown"],
                                desc = L.options["Displays the countdown in the style of battleground countdown."],
                                width = "double",
                                order = 330,
                                disabled = function(info) return not db.profile.SpecialTimers["PullTimerEnabled"] end,
                                get = function(info) return addon.Countdown.db.profile["Enabled"] end,
                                set = function(info,v) addon.Countdown.db.profile["Enabled"] = v end,
                            },
                            pull_blank1 = genblank(326),
                            big_numbers_countdown_group = {
                                type = "group",
                                name = L.options["Grand Countdown"],
                                order = 340,
                                disabled = function(info) return not db.profile.SpecialTimers["PullTimerEnabled"] or not addon.Countdown.db.profile["Enabled"] end,
                                set = function(info,v) addon.Countdown.db.profile[info[#info]] = v;addon.Countdown:RefreshProfile() end,
                                get = function(info) return addon.Countdown.db.profile[info[#info]] end,
                                args = {
                                    DisplayBound = {
                                        type = "range",
                                        name = L.options["Display limit"],
                                        desc = "Sets at how many seconds left on pull timer the timer should start displaying.",
                                        order = 100,
                                        min = 1,
                                        max = 15,
                                        step = 1,
                                    },
                                    LargeNumbersBound = {
                                        type = "range",
                                        name = L.options["Lower bound"],
                                        desc = "Sets at how many seconds left on pull timer the timer is displayed in big-sized numbers",
                                        order = 200,
                                        min = 1,
                                        max = 15,
                                        step = 1,
                                    },
                                    AllowGlow = {
                                        type = "toggle",
                                        name = L.options["Allow Glow"],
                                        desc = L.options["Turns on the digit's glow."],
                                        order = 300,
                                    },
                                    grand_countdown_blank1 = genblank(350),
                                    FilterRaidWarning = {
                                        type = "toggle",
                                        name = L.options["Filter Raid Warning Frame"],
                                        desc = L.options["Filters Raid Warning frame messages announcing the pull."],
                                        width = "double",
                                        order = 400,
                                    },
                                    MutePullSound = {
                                        type = "toggle",
                                        name = L.options["Disable Pull Raid Warning Sound"],
                                        desc = L.options["Filters Raid Warning sound for pull countdown."],
                                        width = "double",
                                        order = 500,
                                        disabled = function() return not db.profile.SpecialTimers["PullTimerEnabled"] or not addon.Countdown.db.profile["Enabled"] or addon.Countdown.db.profile.FilterRaidWarning end,
                                    },
                                },
                            },
                        },
                    },
                },
            },
            -----------------
            -- BREAK TIMER --
            -----------------
            break_timer_group = {
                type = "group",
                name = L.options["Break timer"],
                order = 200,
                args = {
                    BreakTimerEnabled = {
                        type = "toggle",
                        name = L.options["Enabled"],
                        width = "half",
                        order = 331,
                        get = function(info) return db.profile.SpecialTimers["BreakTimerEnabled"] end,
                        set = function(info,v) db.profile.SpecialTimers["BreakTimerEnabled"] = v if not v then addon.Alerts:QuashByPattern("DBMbreak") end end,
                    }, 
                    break_timer_colors_group = {
                        type = "group",
                        name = L.options["Options"],
                        order = 332,
                        inline = true,
                        args = {
                            BreakColor1 = {
                                type = "select",
                                name = L.options["Main Color"],
                                order = 333,
                                handler = Alerts,
                                values = GetColors(true),
                                disabled = function(info) return not db.profile.SpecialTimers["BreakTimerEnabled"] end,
                                get = function(info) return db.profile.SpecialTimers["BreakColor1"] end,
                                set = function(info,v) db.profile.SpecialTimers["BreakColor1"] = v end, 
                            },
                            BreakColor2 = {
                                type = "select",
                                name = L.options["Flash Color"],
                                order = 334,
                                handler = Alerts,
                                values = GetColors(false),
                                disabled = function(info) return not db.profile.SpecialTimers["BreakTimerEnabled"] end,
                                get = function(info) return db.profile.SpecialTimers["BreakColor2"] end,
                                set = function(info,v) db.profile.SpecialTimers["BreakColor2"] = v end,
                            },  
                            TestBreakTimer = {
                                type = "execute",
                                name = L.options["Test"],
                                desc = "Tests the break timer with selected options.",
                                order = 335,
                                func = function() 
                                    addon:BreakTimer(15)
                                end,
                                width = "half",
                            },
                        },
                    },
                },
            },
            -----------------
            -- LFG TIMER --
            -----------------
            lfg_timer_group = {
                type = "group",
                name = L.options["LFG timer"],
                order = 300,
                set = function(info,v) addon.Alerts.db.profile[info[#info]] = v;addon:LFG_RefreshBar() end,
                get = function(info) return addon.Alerts.db.profile[info[#info]] end,
                args = {
                    LFGTimerEnabled = {
                        type = "toggle",
                        name = L.options["Enabled"],
                        width = "half",
                        order = 100,
                    }, 
                    lfg_timer_colors_group = {
                        type = "group",
                        name = L.options["Invitation Options"],
                        order = 332,
                        inline = true,
                        disabled = function(info) return not addon.Alerts.db.profile.LFGTimerEnabled end,
                        args = {
                            LFGTimerMainColor = {
                                type = "select",
                                name = L.options["Main Color"],
                                order = 333,
                                handler = Alerts,
                                values = GetColors(true),
                            },
                            LFGTimerFlashColor = {
                                type = "select",
                                name = L.options["Flash Color"],
                                order = 334,
                                handler = Alerts,
                                values = GetColors(false),
                            },
                            LFG_blank = genblank(339),
                            LFGShowLeftIcon = {
                                order = 340,
                                type = "toggle",
                                name = L.options["Show Left Icon"],
                                desc = L.options["Shows an icon on the left side of the bar"],
                            },
                            LFGShowRightIcon = {
                                order = 345,
                                type = "toggle",
                                name = L.options["Show Right Icon"],
                                desc = L.options["Shows an icon on the right side of the bar"],
                            },
                            LFG_blank2 = genblank(349),
                            lfg_voice_identifier = {
                                type = "select",
                                name = L.options["Countdown Voice"],
                                order = 350,
                                width = "double",
                                get = function()
                                    local alertsPfl = addon.Alerts.db.profile
                                    if not alertsPfl.LFGTimerAudioCDVoice or alertsPfl.LFGTimerAudioCDVoice == false then
                                        return "#off#"
                                    elseif alertsPfl.LFGTimerAudioCDVoice == "#off#" or alertsPfl.LFGTimerAudioCDVoice == "#default#" then
                                        return alertsPfl.LFGTimerAudioCDVoice
                                    elseif addon.Alerts.CountdownVoicesDB[alertsPfl.LFGTimerAudioCDVoice] then
                                        return alertsPfl.LFGTimerAudioCDVoice
                                    else
                                        return "#default#"
                                    end
                                end,
                                set = function(info,v) addon.Alerts.db.profile.LFGTimerAudioCDVoice = v end,
                                values = function() 
                                    local voiceList = {}
                                    voiceList["#off#"] = format("|cffffffff%s|r","|cffffff00Disabled|r")
                                    voiceList["#default#"] = format("|cffffff00Default voice|r (%s)",addon.Alerts.db.profile.CountdownVoice)
                                    for k,v in pairs(addon.Alerts.CountdownVoicesDB) do
                                        voiceList[k] = k
                                    end
                                    return voiceList
                                end
                            },
                            TestLFGTimer = {
                                type = "execute",
                                name = L.options["Test"],
                                desc = "Tests the LFG timer with selected options.",
                                order = 335,
                                func = function() 
                                    addon:ShowLFGCountdown(301,true)
                                end,
                                width = "half",
                            },
                            LFG_MutedSound = {
                                type = "toggle",
                                name = L.options["Master channel for |cff00ff00LFG Ready Check|r sound"],
                                desc = L.options["Plays the |cff00ff00LFG_READY_CHECK|r sound for LFG even if you disable sounds."],
                                order = 380,
                                disabled = function(info) return not addon.Alerts.db.profile.LFGTimerEnabled end,
                            },
                        },
                    },
                    lfg_entering_timer_colors_group = {
                        type = "group",
                        name = L.options["Entering Dungeon Options"],
                        order = 334,
                        inline = true,
                        disabled = function(info) return not addon.Alerts.db.profile.LFGTimerEnabled end,
                        args = {
                            LFGEnteringTimerMainColor = {
                                type = "select",
                                name = L.options["Main Color"],
                                order = 333,
                                handler = Alerts,
                                values = GetColors(true),
                            },
                            LFGEnteringTimerFlashColor = {
                                type = "select",
                                name = L.options["Flash Color"],
                                order = 334,
                                handler = Alerts,
                                values = GetColors(false),
                            },
                            LFG_blank = genblank(339),
                            LFGEnteringShowLeftIcon = {
                                order = 340,
                                type = "toggle",
                                name = L.options["Show Left Icon"],
                                desc = L.options["Shows an icon on the left side of the bar"],
                            },
                            LFGEnteringShowRightIcon = {
                                order = 345,
                                type = "toggle",
                                name = L.options["Show Right Icon"],
                                desc = L.options["Shows an icon on the right side of the bar"],
                            },
                            LFG_blank2 = genblank(349),
                            TestLFGEnteringTimer = {
                                type = "execute",
                                name = L.options["Test"],
                                desc = "Tests the Entering LFG timer with selected options.",
                                order = 335,
                                func = function() 
                                    addon:ShowEnteringLFGCountdown(301,true)
                                end,
                                width = "half",
                            },
                            LFG_Entering_MutedSound = {
                                type = "toggle",
                                name = L.options["Master channel for |cff00ff00Entering LFG|r sound"],
                                desc = L.options["Plays the |cff00ff00ENTERING_LFG|r sound for LFG even if you disable sounds."],
                                order = 350,
                                disabled = function(info) return not addon.Alerts.db.profile.LFGTimerEnabled end,
                            },
                        },
                    },
                
                },
            },
            ------------------------
            -- RESURRECTION TIMER --
            ------------------------
            resurrection_timer_group = {
                type = "group",
                name = L.options["Resurrection timer"],
                order = 350,
                set = function(info,v) addon.Alerts.db.profile[info[#info]] = v;addon:ResurrectBar_Refresh() end,
                get = function(info) return addon.Alerts.db.profile[info[#info]] end,
                args = {
                    ResurrectTimerEnabled = {
                        type = "toggle",
                        name = L.options["Enabled"],
                        width = "half",
                        order = 318,
                        get = function(info) return addon.Alerts.db.profile["ResurrectTimerEnabled"] end,
                        set = function(info,v) addon.Alerts.db.profile["ResurrectTimerEnabled"] = v if not v then addon.Alerts:QuashByPattern("DBMpull") end end,
                    },
                    pull_timer_colors_group = {
                        type = "group",
                        name = L.options["Options"],
                        order = 320,
                        inline = true,
                        args = {
                            ResurrectTimerMainColor = {
                                type = "select",
                                name = L.options["Main Color"],
                                order = 321,
                                handler = Alerts,
                                values = GetColors(true),
                                disabled = function(info) return not addon.Alerts.db.profile["ResurrectTimerEnabled"] end,
                            },
                            ResurrectTimerFlashColor = {
                                type = "select",
                                name = L.options["Flash Color"],
                                order = 322,
                                handler = Alerts,
                                values = GetColors(false),
                                disabled = function(info) return not addon.Alerts.db.profile["ResurrectTimerEnabled"] end,
                            },
                            TestResurrectTimer = {
                                type = "execute",
                                name = L.options["Test"],
                                desc = "Tests the pull timer with selected options.",
                                order = 323,
                                func = function() 
                                    addon:ShowResurrectCountdown(nil, true)
                                end,
                                width = "half",
                            },
                            Resurrect_blank1 = genblank(324),
                            ResurrectShowLeftIcon = {
                                order = 325,
                                type = "toggle",
                                name = L.options["Show Left Icon"],
                                desc = L.options["Shows an icon on the left side of the bar"],
                            },
                            ResurrectShowRightIcon = {
                                order = 326,
                                type = "toggle",
                                name = L.options["Show Right Icon"],
                                desc = L.options["Shows an icon on the right side of the bar"],
                            },
                            Resurrect_blank2 = genblank(327),
                            countdown_voice_identifier = {
                                type = "select",
                                name = L.options["Countdown Voice"],
                                order = 328,
                                width = "double",
                                get = function()
                                    local alertsPfl = addon.Alerts.db.profile
                                    if alertsPfl.ResurrectTimerAudioCDVoice == "#off#" or alertsPfl.ResurrectTimerAudioCDVoice == "#default#" then
                                        return alertsPfl.ResurrectTimerAudioCDVoice
                                    elseif addon.Alerts.CountdownVoicesDB[alertsPfl.ResurrectTimerAudioCDVoice] then
                                        return alertsPfl.ResurrectTimerAudioCDVoice
                                    else
                                        return "#default#"
                                    end
                                end,
                                set = function(info,v) addon.Alerts.db.profile.ResurrectTimerAudioCDVoice = v end,
                                values = function() 
                                    local voiceList = {}
                                    voiceList["#off#"] = format("|cffffffff%s|r","|cffffff00Disabled|r")
                                    voiceList["#default#"] = format("|cffffff00Default voice|r (%s)",addon.Alerts.db.profile.ResurrectTimerAudioCDVoice)
                                    for k,v in pairs(addon.Alerts.CountdownVoicesDB) do
                                        voiceList[k] = k
                                    end
                                    return voiceList
                                end
                            },
                        },
                    },
                },
            },
            ---------------------------
            -- VICTORY ANNOUNCEMENTS --
            ---------------------------
            victory_announcement_group = {
                type = "group",
                name = L.options["Victory Announcement"],
                order = 400,
                args = {
                    SpecialOutput = {
                        type = "select",
                        name = L.options["Victory Announcement output"],
                        desc = L.options["Determines where special announcements such as Victory announcement or New speed kill record announcement will be output.\n\nDEFAULT output - The output you selected in Alerts - Warning Messages - Output section of the Options.\n|cffff4700RAID WARNING|r Frame - Frame used for Raid Warnings\n|cff00cea5LEGION|r Frame - A replica of Legion-style boss defeat frame."],
                        order = 100,
                        values = {
                            DEFAULT_OUTPUT = "DEFAULT output",
                            RAID_WARNING_OUTPUT = "|cffff4700RAID WARNING|r Frame",
                            LEGION_OUTPUT = "|cff00CEA5LEGION|r Frame",
                        },
                        get = function(info) return db.profile.SpecialWarnings["SpecialOutput"] end,
                        set = function(info,v) db.profile.SpecialWarnings["SpecialOutput"] = v end,
                    },
                    test_special_output = {
                        type = "execute",
                        name = L.options["Test output"],
                        desc = "Test the selected output to see which you prefer.",
                        order = 150,
                        func = function() 
                            RaidNotice_Clear(RaidWarningFrame)
                            addon.Alerts:HideLegionAlert()
                            local encounter = {}
                            encounter.name = "The Mystery Boss"
                            encounter.icon = "Interface\\EncounterJournal\\UI-EJ-BOSS-Default.blp"
                            encounter.key = "mysteryboss"
                            if addon:IsModuleEvent(encounter.key) then
                                addon.Alerts:EventCompletedAlert(encounter, "None")
                            elseif addon:IsModuleBattleground(encounter.key) then
                                addon.Alerts:BattlegroundWonAlert(encounter, UnitFactionGroup("player"), "None")
                            else
                                addon.Alerts:EncounterDefeatedAlert(encounter, true, "None")
                            end
                        end,
                    },
                    special_output_blank = genblank(200),
                    VictoryAnnouncementEnabled = {
                        type = "toggle",
                        name = L.options["Enable Victory Announcement In Raids and Dungeons"],
                        width = "full",
                        order = 250,
                        get = function(info) return db.profile.SpecialWarnings["VictoryAnnouncementEnabled"] end,
                        set = function(info,v) db.profile.SpecialWarnings["VictoryAnnouncementEnabled"] = v end,
                    },
                    VictorySound = {
                        type = "toggle",
                        name = L.options["Play the Victory sound"],
                        width = "full",
                        order = 352,
                        disabled = function(info) return not db.profile.SpecialWarnings["VictoryAnnouncementEnabled"] end,
                        get = function(info) return db.profile.SpecialWarnings["VictorySound"] end,
                        set = function(info,v) db.profile.SpecialWarnings["VictorySound"] = v end,
                    },
                    victory_sound_desc = {
                        type = "description",
                        name = L.options["You can also change a victory soundfile in Sound Labels section under the name of 'VICTORY'."],
                        order = 353,
                    },
                    VictoryScreenshot = {
                        type = "toggle",
                        name = L.options["Take a victory screenshot."],
                        width = "full",
                        order = 354,
                        disabled = function(info) return not db.profile.SpecialWarnings["VictoryAnnouncementEnabled"] end,
                        get = function(info) return db.profile.SpecialWarnings["VictoryScreenshot"] end,
                        set = function(info,v) db.profile.SpecialWarnings["VictoryScreenshot"] = v end,
                    },
                    legion_frame_group = {
                        type = "group",
                        name = L.options["Legion Frame"],
                        order = 400,
                        inline = true,
                        set = function(info,v) addon.Alerts.db.profile[info[#info]] = v end,
                        get = function(info) return addon.Alerts.db.profile[info[#info]] end,
                        args = {
                            LegionFrameHideEncounterIcons = {
                                type = "toggle",
                                name = L.options["Hide icons for the Encounters."],
                                width = "full",
                                order = 410,
                            },
                            LegionFrameHideEventIcons = {
                                type = "toggle",
                                name = L.options["Hide icons for the Events."],
                                width = "full",
                                order = 420,
                            },
                            LegionFrameYOffset = {
                                type = "range",
                                name = L.options["Y axis offset"],
                                desc = "Sets the Y axis offset of the Legion Frame.",
                                disabled = function() addon.Alerts:UpdateDefeatAlertPosition();return false end,
                                order = 440,
                                min = -300,
                                max = 1000,
                                step = 1,
                            },
                            LegionFrameScale = {
                                type = "range",
                                name = L.options["Scale Factor"],
                                desc = "Sets the scale factor of the Legion Frame.",
                                disabled = function() addon.Alerts:UpdateDefeatAlertPosition();return false end,
                                order = 450,
                                min = 0.5,
                                max = 2,
                                step = 0.1,
                            },
                        },
                    },
                },
            },
        }
    }
    
    pull_timer_colors_args = special_timers_group.args.pull_timer_group.args.pull_timer_colors_group.args
    opts_args.special_timers_group = special_timers_group
    break_timer_colors_args = special_timers_group.args.break_timer_group.args.break_timer_colors_group.args
    lfg_timer_colors_args = special_timers_group.args.lfg_timer_group.args.lfg_timer_colors_group.args
    
end

	---------------------------------------------
	-- WHISPERS (formally only Auto Responder)
	---------------------------------------------
	do
		local AutoResponder = addon.AutoResponder
        local RaidStatus = addon.RaidStatus
        local responder_group = {
            type = "group",
            name = "Chat & Whispers",
            childGroups = "tab",
            order = 400,
            args = {
                DefaultMessageLanguage = {
                    type = "select",
                    name = L.options["Default language for multi-language text presets."],
                    desc = L.options["Set the default language for texts that have multiple language variants."],
                    order = 250,
                    width = "double",
                    values = {
                        cs = "Cestina",
                        en = "English",
                    },
                    get = function(info) return db.profile.Misc[info[#info]] end,
                    set = function(info,v) db.profile.Misc[info[#info]] = v end,
                },
                chat_announces_group = {
                    type = "group",
                    name = "",
                    get = function(info) return db.profile.Chat[info[#info]] end,
                    set = function(info,v) db.profile.Chat[info[#info]] = v end,
                    order = 300,
                    inline = true,
                    args = {
                        header = {
                            type = "header",
                            name = L.options["Chat Announcments"],
                            order = 100,
                        },
                        AchievementAnnouncements = {
                            type = "toggle",
                            name = L.options["Enable Achievement Announcements"],
                            desc = L.options["Globally disables achievement failed, achievement completed and such announcements in chat."],
                            order = 150,
                            width = "full",
                        },
                        AnnounceRecordKill = {
                            type = "toggle",
                            name = L.options["Enable Speedkill Record Announcements"],
                            desc = L.options["Enable announcing a new speed kill record to the chat."],
                            width = "double",
                            order = 200,
                        },
                        AnnounceRecordKillWithDiff = {
                            type = "toggle",
                            name = L.options["Include time improvement"],
                            desc = L.options["Enable including the time improvement over the last record in chat message."],
                            width = "double",
                            order = 250,
                        },
                    },
                },
                AR_group = {
                    type = "group",
                    name = "",
                    get = function(info) return AutoResponder.db.profile[info[#info]] end,
                    set = function(info,v) AutoResponder.db.profile[info[#info]] = v end,
                    order = 400,
                    inline = true,
                    args = {
                        header = {
                            type = "header",
                            name = L.options["Auto Responder"],
                            order = 1200,
                        },
                        desc = {
                            type = "description",
                            name = L.options["Activates the automatic responder for whispers during boss encounters. Players who whisper the player will then receive a message informing them about the current encounter status."],
                            order = 1300,
                            width = "full",
                            fontSize = "medium",
                        },
                        enabled = {
                            type = "toggle",
                            name = L.options["Enable Auto Responder"],
                            order = 1400,
                            width = "full",
                        },
                        details = {
                            type = "toggle",
                            name = L.options["Include the encounter details"],
                            desc = "Besides the encounter name and difficulty also include the time elapsed, the number of people alive and boss health percentage.",
                            order = 1401,
                            width = "full",
                            disabled = function(info) return not AutoResponder.db.profile["enabled"] end,
                        },
                        announcewipe = {
                            type = "toggle",
                            name = L.options["Announce a wipe"],
                            desc = "Announce a wipe to all people who sent a whisper to the player during the encounter.",
                            order = 1402,
                            width = "full",
                            disabled = function(info) return not AutoResponder.db.profile["enabled"] end,
                        },
                        announcedefeat = {
                            type = "toggle",
                            name = L.options["Announce a defeat"],
                            desc = "Announce a defeat to all people who sent a whisper to the player during the encounter.",
                            order = 1403,
                            width = "full",
                            disabled = function(info) return not AutoResponder.db.profile["enabled"] end,
                        },
                        interval = {
                            type = "range",
                            name = L.options["Throttle interval"],
                            desc = "Sets for how many seconds the AutoResponder stops responding after the initial whisper.",
                            order = 1404,
                            width = "double",
                            disabled = function(info) return not AutoResponder.db.profile["enabled"] end,
                            min = 1,
                            max = 60,
                            step = 1,
                        },
                        updatethrottle = {
                            type = "toggle",
                            name = L.options["Update throttle timer"],
                            desc = "Updates a throttle timer so that the time for which AutoResponder stops responding is extended after every received message within the active throttle.",
                            order = 1405,
                            width = "full",
                            disabled = function(info) return not AutoResponder.db.profile["enabled"] end,
                        },
                    },
                },
                RS_group = {
                    type = "group",
                    name = "",
                    get = function(info) return RaidStatus.db.profile[info[#info]] end,
                    set = function(info,v) RaidStatus.db.profile[info[#info]] = v end,
                    order = 500,
                    inline = true,
                    args = {
                        header = {
                            type = "header",
                            name = L.options["Raid Status"],
                            order = 1200,
                        },
                        desc = {
                            type = "description",
                            name = L.options["Activates the extended automatic responder for whispers. When the player gets whispered during the raid phrase '|cffffff00dxestatus|r' or '|cffffff00dxes|r' it will automatically respond to sender with the overview of the ongoing raid progress (a list of bosses with an icon indicating that the boss is still alive, being fought or defeated)."],
                            order = 1300,
                            width = "full",
                            fontSize = "medium",
                        },
                        enabled = {
                            type = "toggle",
                            name = L.options["Enable Raid Status"],
                            order = 1400,
                            width = "full",
                        },
                        interval = {
                            type = "range",
                            name = L.options["Throttle interval"],
                            desc = "Sets for how many seconds the Raid Status stops responding after the initial whisper.",
                            order = 1404,
                            width = "double",
                            disabled = function(info) return not RaidStatus.db.profile["enabled"] end,
                            min = 15,
                            max = 60,
                            step = 1,
                        },
                        spamCap = {
                            type = "range",
                            name = L.options["Spam Cap"],
                            desc = "Maximum number of messages until the DXE spam filter is triggered to prevent in-game spam filter to activate.",
                            order = 1405,
                            width = "double",
                            disabled = function(info) return not RaidStatus.db.profile["enabled"] end,
                            min = 3,
                            max = 9,
                            step = 1,
                        },
                        filterPhrases = {
                            type = "toggle",
                            name = L.options["Filter phrases"],
                            desc = "Filters out phrases 'dxestatus' and 'dxes' from whispers even when the Raid Status is disabled.",
                            order = 1406,
                            width = "full",
                            disabled = function(info) return RaidStatus.db.profile["enabled"] end,
                        },
                    },
                },
            },
		}

        --responder_group.args["AR_group"] = AR_group
        opts_args.responder_group = responder_group
		--opts_args.AR_group = AR_group
        --opts_args.RS_group = RS_group
	end

	---------------------------------------------
	-- ABOUT
	---------------------------------------------

	do
		local about_group = {
			type = "group",
			name = function() 
                if addon:ParseVersion(addon.db.global.lastUpdateShown) > addon:ParseVersion(addon.version) then
                    return format("|cff99ff33[%s]|r","Update Available")
                else
                    return L.options["About"]
                end
            end,
			order = -2,
			args = {
                authors_title = {
                    type = "description",
                    name = format("%s:", L.options["Authors"]),
                    order = 100,
                    fontSize = "large",
                    width = "half",
                },
                atuhors_list = {
                    type = "description",
                    name = "|cffffd200Kollektiv|r, |cffffd200Fariel|r",
                    fontSize = "large",
                    width = "fill",
                    order = 150,
                },
				blank1 = genblank(175),
				created_desc = {
					type = "description",
					name = format(L.options["Created for use by %s on %s."],"|cffffd200Deus Vox|r","|cffffff78US-Laughing Skull|r"),
                    fontSize = "large",
                    order = 200,
				},
				blank2 = genblank(250),
				-- Addon's original website, seems offline at the moment.
                visit_desc = {
					type = "description",
					name = format("%s: %s",L.options["Website"],"|cffffd244http://www.deusvox.net|r"),
                    fontSize = "large",
                    order = 300,
				},
                blank3 = genblank(350),
				visit_desc = {
					type = "description",
					name = format("For %s (%s) developed by %s.",
                                format("|cffffd200%s|r",L.options["Twinstar-WoW"]),
                                format("|cffffff78%s|r %s",L.options["Apollo"],L.options["realms"]),
                                format("|cffffd200%s|r","Greghouse")),
                    fontSize = "large",
					order = 400,
				},
                download_desc = {
					type = "input",
					name = format("%s:",L.options["|cffffffffTo |rdownload |cffffffffthe most recent version visit|r"]),
                    get = function() return addon.website end,
                    width = "double",
					order = 450,
				},
                new_version_desc = {
					type = "description",
					name = function()
                        if addon:ParseVersion(addon.db.global.lastUpdateShown) > addon:ParseVersion(addon.version) then
                            return format("A new version |cff99ff33%s|r has been released!",addon.db.global.lastUpdateShown)
                        else
                            return nil
                        end
                    end,
                    fontSize = "large",
					order = 430,
				},
			},
		}
		opts_args.about_group = about_group
	end

	---------------------------------------------
	-- ENCOUNTERS
	---------------------------------------------

    local AdvancedItems
    
	do
		local loadselect
		local handler = {}
        local categList = {}
        local function populateCategoryList()
            local i = 1
            categList = {}
            for key,name in pairs(addon.Loader.Z_MODS_LIST) do
                categList[i] = name
                i = i + 1
            end
            table.sort(categList)
        end
        
        --[[
            Raid Icon Types are listed below. Pattern property is used to put text in [] behind the main raid icon name.
            
            E.g.    varname = format("%s {%s}",SN[109457],"DEBUFF_PLAYER"),
                translated into:
                    varname = "Fiery Grip {DEBUFF_PLAYER}",
                will result in variable label in options:
                    Fiery Grip [player debuff]
                    
            To specify an NPC name to mark having a debuff you can follow a VARTYPE constant with a paramter after a - symbol.
            
            E.g.    varname = format("%s {%s-%s}",SN[105834],"ENEMY_DEBUFF","Hideous Amalgamation"),
                translated into:
                    varname = "Superheated Nucleus {ENEMY_DEBUFF-Hideous Amalgamation}",
                will result in variable lable in options:
                    Superheated Nucleus [Hideous Amalgamation debuff]
                    
            Using |o inside the pattern property makes it get replaced with the original vartype coloring and thus allows
            you to color freely inside the pattern.
            E.g.    player debuff
                would normally be colored as
                    |cffff632fplayer debuff|r
                however we can add "with" + white coloring
                    player|r |cffffffffwith|r |odebuff
                to get 
                    |cffff632fplayer|r |cffffffffwith|r |cffff632fdebuff|r
                Notice that in pattern we first terminate the original coloring with |r (right after 'player' word)
                do our own text and coloring and then resume to original coloring with |o (right before 'debuff' word)
        ]]
        
        local VARTYPE_DB = {
            ["PLAYER_DEBUFF"] =         {pattern = "player debuff",                             color = "ffff00"},
            ["ABILITY_TARGET_HARM"] =   {pattern = "ability target",                            color = "66beff"},
            ["NPC_ENEMY"] =             {pattern = "enemy NPC",                                 color = "ff0000"},
            ["ENEMY_CAST"] =            {pattern = "|cffffdb00%s|r|o cast",                     color = "ff632f"},
            ["ENEMY_DEBUFF"] =          {pattern = "|cffffdb00%s|r|o debuff",                   color = "00d5df"},
            ["ENEMY_BUFF"] =            {pattern = "|cffffdb00%s|r|o buff",                     color = "b300df"},
        }
        
        local PATTERNS_ALERTS = {
            ["CD"] =        {pattern = "^(.+) CD$", color = "ff8000", text = "[Cooldown]"},
            ["Cooldown"] =        {pattern = "^(.+) Cooldown$", color = "ff8000", text = "[Cooldown]"},
            ["Countdown"] =        {pattern = "^(.+) Countdown$", color = "ffaa00", text = "[Countdown]"},
            ["Warning"] =   {pattern = "^(.+) Warning$", color = "00c6ff", text = "[Warning]"},
            ["Duration"] =        {pattern = "^(.+) Duration$", color = "ffec00", text = "[Duration]"},
            ["Cast"] =        {pattern = "^(.+) Cast$", color = "ff0000", text = "[Cast]"},
            ["Casting"] =        {pattern = "^(.+) Casting$", color = "ff0000", text = "[Cast]"},
            ["Absorbs"] =        {pattern = "^(.+) Absorbs$", color = "00ff00", text = "[Absorbs]"},
        }
        local PATTERN_ALERTS_CD = "^(.+) CD$"
        local PATTERN_ALERTS_WARNING = "^(.+) Warning$"
               
        local function GetColoredVarName(info, vartype, icon)
            local varname = info.varname
            if vartype == "raidicons" then
                local name,varTypeID = varname:match("^(.+)%{([%w_]+).*%}$")
                local param = varname:match("^.+%{[%w_]+%-(.+)%}$")
                local varType = VARTYPE_DB[varTypeID]

                if varType then
                  return icon..gsub(format("%s|cff%s[%s]|r",name,varType.color,format(varType.pattern,param)),"|o","|cff"..varType.color)
                else
                  return icon..varname
                end
            elseif vartype == "announces" then
                local channel = info.type
                local subtype = info.subtype
                if subtype == "self" then
                    local spell
                    if type(info.spell) == "number" then
                        local spellID = tonumber(info.spell)
                        local icon = info.icon or addon.ST[spellID]
                        local spellLink = format("|cff71d5ff[%s]|r",addon.SN[spellID])
                        spell = format("|T%s:16:16|t %s",icon, info.varname and format(info.varname,spellLink) or spellLink)
                    elseif type(info.spell) == "string" then
                        local spellLink = format("|cff71d5ff[%s]|r",info.spell)
                        local icon = info.icon and format("|T%s:16:16|t",info.icon) or ""
                        spell = format("%s %s",icon, info.varname and format(info.varname,spellLink) or spellLink)
                    end
                    
                    return format("%s: %s on me", Chat_GetColoredChatName(channel:upper()), spell)
                elseif subtype == "spell" then
                    local spell
                    if type(info.spell) == "number" then
                        local spellID = tonumber(info.spell)
                        local icon = info.icon or addon.ST[spellID]
                        local spellLink = format("|cff71d5ff[%s]|r",addon.SN[spellID])
                        spell = format("|T%s:16:16|t %s",icon, info.varname and format(info.varname,spellLink) or spellLink)
                    elseif type(info.spell) == "string" then
                        local spellLink = format("|cff71d5ff[%s]|r",info.spell)
                        local icon = info.icon and format("|T%s:16:16|t",info.icon) or ""
                        spell = format("%s %s",icon, info.varname and format(info.varname,spellLink) or spellLink)
                    end
                    
                    return format("%s: %s", Chat_GetColoredChatName(channel), spell)
                elseif subtype == "achievement" then
                    local icon = format("|T%s:16:16|t",info.icon or select(10,GetAchievementInfo(info.achievement)))
                    local achievementLink = format("%s |cffffff00[%s]|r",icon,addon.AN[info.achievement])
                    local achievement = format("%s %s",addon.TI["AchievementShield"],info.varname and format(info.varname,achievementLink) or achievementLink)
                    return format("%s: %s",Chat_GetColoredChatName(channel:upper()), achievement)
                else
                    local icon = info.icon and format("|T%s:16:16|t",info.icon) or ""
                    return format("%s: %s%s", Chat_GetColoredChatName(channel:upper()), icon,info.varname)
                end
                --[[local channel, infoType, params = varname:match("^{(%w+)} {(%w+)} (.+)$")
                if infoType == "achievement" then
                    local achievementID, pattern = params:match("^{(%d+)} (.+)$")
                    achievementID = tonumber(achievementID)
                    return format("%s: %s %s",
                                   Chat_GetColoredChatName(channel:upper()),
                                   addon.TI["AchievementShield"],
                                   format(pattern, "|cffffff00["..addon.AN[achievementID].."]|r"))
                elseif infoType == "self" then
                    local spellID = params:match("^{([%w%s]+)}")
                    local customicon = params:match("^{[%w%s]+} {([%w%s]+)}")
                    local spell
                    if not tonumber(spellID) then
                        local spellName = spellID
                        spellID = tonumber(params:match("^{[%w%s]+} {(%d+)}$"))
                        spell = format("|T%s:16:16|t |cff71d5ff[%s]|r",customicon or addon.ST[spellID], spellName)
                    else
                        spellID = tonumber(spellID)
                        spell = format("|T%s:16:16|t |cff71d5ff[%s]|r",addon.ST[spellID], addon.SN[spellID])
                    end
                    return format("%s: %s on me", Chat_GetColoredChatName(channel:upper()), spell)
                elseif infoType == "spell" then
                    local spellID = params:match("^{([%w%s]+)}")
                    
                    local amendment
                    local spell
                    
                    if not tonumber(spellID) then
                        local spellName = spellID
                        spellID = tonumber(params:match("^{[%w%s]+} {(%d+)}"))
                        spell = format("|T%s:16:16|t |cff71d5ff[%s]|r",addon.ST[spellID], spellName)
                        amendment = params:match("^{[%w%s]+} {[%w%s]+} (.+)")
                    else
                        spellID = tonumber(spellID)
                        spell = format("|T%s:16:16|t |cff71d5ff[%s]|r",addon.ST[spellID], addon.SN[spellID])
                        amendment = params:match("^{[%w%s]+} (.+)")
                    end
                    return format("%s: %s%s", Chat_GetColoredChatName(CHANNELTYPE_TO_CHANNEL[channel]), spell, amendment and " "..amendment or "")
                elseif infoType == "other" then
                    return format("%s: %s", Chat_GetColoredChatName(CHANNELTYPE_TO_CHANNEL[channel]), params)
                else
                    return icon..varname
                end]]
            elseif vartype == "alerts" then
                for _,patternInfo in pairs(PATTERNS_ALERTS) do
                    if varname:find(patternInfo.pattern) then
                        varname = varname:match(patternInfo.pattern)
                        return format("%s%s |cff%s%s|r",icon or "",varname,patternInfo.color,patternInfo.text)
                    end
                end
                
                return (icon or "")..varname
            elseif vartype == "radars" then
                local icon = ""
                if info.icon then
                    icon = format("|T%s:16:16|t ",info.icon)
                end
                return format("%s%s",icon,varname or "Radar Circle")
            else
                return (icon or "")..varname
            end
        end
        local ST = addon.ST
        local GENERAL_ICON = format("|T%s:16:16|t","Interface\\TARGETINGFRAME\\UI-PhasingIcon")
        
        local function GetPhaseName(info, isAdvanced)
            if info.phase then
                local iconL,iconR
                if info.iconfull then
                    iconL = info.iconfull
                    iconR = info.iconfull
                else
                    local aspect = info.sizing and (info.sizing.aspect or 1) or 1
                    iconL = format("|T%s:%d:%d|t",info.icon or ST[11242],16,16*aspect)
                    if info.sizing and info.sizing.w and info.sizing.h then
                        iconR = format("|T%s:%d:%d:0:0:%d:%d:%d:0:0:%d|t",info.icon or ST[11242],16,16*aspect,info.sizing.w,info.sizing.h,info.sizing.w,info.sizing.h)
                    else
                        iconR = format("|T%s:%d:%d|t",info.icon or ST[11242],16,16*aspect)
                    end
                end
                if isAdvanced then
                    if type(info.phase) == "number" then
                        return format("%s  |cffffffff%s|r |cffffd700%s|r", iconL, "Phase", info.phase)
                    elseif type(info.phase) == "string" then
                        return format("%s  %s", iconL, info.phase)
                    end
                else
                    if type(info.phase) == "number" then
                        return format("%s  |cffffffff%s|r |cffffd700%s|r  %s", iconL, "Phase", info.phase, iconR)
                    elseif type(info.phase) == "string" then
                        return format("%s  %s  %s", iconL, info.phase, iconR)
                    end
                end
            elseif info.general and info.general == true then
                if isAdvanced then
                    return format("%s  |cffffffff%s|r",GENERAL_ICON,"General")
                else
                    return format("%s  |cffffffff%s|r  %s",GENERAL_ICON,"General",GENERAL_ICON)
                end
            elseif info.name then
                local iconL,iconR
                if info.iconfull then
                    iconL = info.iconfull
                    iconR = info.iconfull
                else
                    local aspect = info.sizing and (info.sizing.aspect or 1) or 1
                    if info.icon then
                        iconL = format("|T%s:%d:%d|t",info.icon,16,16*aspect)
                        if info.sizing and info.sizing.w and info.sizing.h then
                            iconR = format("|T%s:%d:%d:0:0:%d:%d:%d:0:0:%d|t",info.icon or ST[11242],16,16*aspect,info.sizing.w,info.sizing.h,info.sizing.w,info.sizing.h)
                        else
                            iconR = format("|T%s:%d:%d|t",info.icon,16,16*aspect)
                        end
                    end
                end
                if isAdvanced then
                    return format("%s|cffffffff%s|r", (iconL and iconL.."  " or ""), info.name)
                else
                    return format("%s|cffffffff%s|r%s", (iconL and (iconL.."  ") or ""), info.name, (iconR and ("  "..iconR) or ""))
                end
            else
                return "Error"
            end
        end
        
        local encs_args
        local function areEncountersLoaded()
            for catkey in pairs(encs_args) do
                if encs_args[catkey].type == "group" then
                    return true
                end
            end
            
            return false
        end
        
		local encs_group = {
			type = "group",
			name = L.options["Encounters"],
			order = 200,
			childGroups = "tab",
			handler = handler,
			args = {
                modules = {
					type = "select",
					name = L.options["Modules"],
					order = 1,
					get = function()
                        loadselect = type(loadselect) == "number" and loadselect or 1
                        return loadselect end,
					set = function(info,v) loadselect = v end,
					values = function() 
                        populateCategoryList()
                        return categList
                    end,
					disabled = function() return #categList==0 end,
                    width = "double",
				},
				load = {
					type = "execute",
					name = L.options["Load"],
					order = 2,
					func  = function() 
                        local loadIndex = loadselect
                        for index,name in ipairs(categList) do
                            if loadselect == name then
                                loadIndex = index
                            end
                        end
                        for key, name in pairs(addon.Loader.Z_MODS_LIST) do
                            if name == categList[loadselect] then
                                addon.Loader:Load(key)
                                break
                            end
                        end
                        populateCategoryList()
                        if loadIndex > #categList then loadIndex = #categList end
                        loadselect = loadIndex
                    end,
					disabled = function() return loadselect == nil or #categList == 0 end,
                    width = "half",
				},
				simple_mode = {
					type = "execute",
					name = "|cffccff9dSimple|r |cffffffffMode|r",
					desc = L.options["This mode only allows you to enable or disable"],
					order = 3,
					func = "SimpleMode",
                    width = "fill",
                    disabled = function() return not areEncountersLoaded() end,
				},
				advanced_mode = {
					type = "execute",
					name = "|cffffa824Advanced|r |cffffffffMode|r",
					desc = L.options["This mode has customization options"],
					order = 4,
					func = "AdvancedMode",
                    width = "fill",
                    disabled = function() return not areEncountersLoaded() end,
				},
			},
		}

		function handler:OnLoadZoneModule() loadselect = next(addon.Loader.Z_MODS_LIST) end
		addon.RegisterCallback(handler,"OnLoadZoneModule")

		opts_args.encs_group = encs_group
		encs_args = encs_group.args
        
        encs_args.load_hint = {
            type = "description",
            name = function(info)
                if areEncountersLoaded() then
                    return ""
                else
                    return "\n\n\n\n\n\n\n\n\n\n\n\n\n\n                                      Select a module and use Load button to view its options."
                end
            end,
            order = 5,
            fontSize = "large",
            width = "full",
        }

		-- SIMPLE MODE
		function handler:GetSimpleEnable(info) 
            local enabled = db.profile.Encounters[info[#info-2]][info[#info]].enabled
            if type(enabled) == "boolean" then
                return enabled
            else
                return false
            end
        end
		function handler:SetSimpleEnable(info,v) 
            db.profile.Encounters[info[#info-2]][info[#info]].enabled = v
            if info[#info-1] == "announces" and addon:IsRunning() then
                addon:BroadcastAnnounceInfoUpdate(EDB[info[#info-2]], info[#info])
            end
        end
        
        local function ConvertToTime(besttime)
            if not besttime then besttime = 0 end
            local minutes = math.floor(besttime / 60)
            local seconds = math.floor(besttime - minutes * 60)
            local miliseconds = tonumber(format("%s",(besttime - minutes * 60 - seconds)*100):match("(%d%d).")) or 0
            
            return format("%s:%s.%s", minutes, seconds>9 and seconds or "0"..seconds, miliseconds > 9 and miliseconds or "0"..miliseconds)
        end
               
        local function GetBestTimeOpt(info)
            local i = 1
            local data = info["options"]["args"]
            while data do
                local tmp = data[info[i]]["args"]
                if tmp then
                    data = tmp
                    i = i + 1
                else 
                    break
                end
            end
            
            return data
        end
        
        local bgCategory = {
            ["Alliance"] = "|TInterface\\WorldStateFrame\\AllianceIcon:0:0|t Alliance",
            ["Horde"] = "|TInterface\\WorldStateFrame\\HordeIcon:0:0|t Horde",
        }
        
        local function InjectSimpleItem(option_args,var,info,optionType,order)
            local icon = ""
            if optionType == "alerts" then
                if info.texture then
                    icon = format("|T%s:16:16|t ",info.texture)
                elseif info.icon then
                    if info.icon:match("^<.+>$") then
                        icon = format("|T%s:16:16|t ","Interface\\ICONS\\INV_Misc_QuestionMark")
                    else
                        icon = format("|T%s:16:16|t ",info.icon)
                    end
                end
            elseif optionType == "raidicons" and info.texture then
                icon = format("|T%s:16:16|t ",info.texture)
            elseif optionType == "arrows" and info.texture then
                icon = format("|T%s:16:16|t ",info.texture)
            end

            option_args[var] = option_args[var] or {
                name = GetColoredVarName(info, optionType, icon),
                width = "full",
            }
            option_args[var].type = "toggle"
            option_args[var].args = nil
            option_args[var].order = order
            option_args[var].set = "SetSimpleEnable"
            option_args[var].get = "GetSimpleEnable"
            option_args[var].disabled = function() 
                if optionType == "announces" and info.subtype == "achievement" then
                    return not db.profile.Chat.AchievementAnnouncements
                else
                    return false
                end
            end
        end
        
		-- Can only enable/disable outputs
        local function InjectSimpleOptions(data,enc_args)
            local optionType = "besttime"
            local besttime_data = db.profile.Encounters[data.key][optionType] or {}
            local showCategory = false
            for _,_ in pairs(besttime_data) do
                showCategory = true
                break
            end
            if showCategory then
                if not enc_args[optionType] then
                    enc_args[optionType] = {
                        type = "group",
                        name = "Speed kills",
                        order = 700,
                        inline = true,
                        childGroups = nil,
                        args = {
                            customToggleInfoHeader = {
                                type = "header",
                                name = L.options["There are no speed kill times for this boss."].."\n",
                                order = 123,
                            }
                        },
                        disabled = function() 
                            for _,_ in pairs(besttime_data) do
                                return false
                            end
                            return true
                        end,
                    }
                    for _,_ in pairs(besttime_data) do
                        enc_args[optionType]["args"]={}
                        break
                    end
                    
                    for key,categoryKeyData in pairs(besttime_data) do
                        local speedkillOrder, speedkillName
                        
                        if addon:IsModuleBattleground(data.key) then
                            local faction = UnitFactionGroup("player")
                            speedkillOrder = (key == faction) and 1 or 2
                            speedkillName = format("Victory as %s", bgCategory[key])
                        else
                            local raidsize = categoryKeyData["raidsize"]
                            local difficulty = categoryKeyData["difficulty"]
                            speedkillOrder = raidsize + (difficulty == "Normal" and 0 or 1)
                            speedkillName = format("%s-Player (%s)", raidsize, difficulty)
                        end                        
                        
                        enc_args[optionType]["args"][key] = {
                            type = "group",
                            name = speedkillName,
                            order = speedkillOrder,
                            inline = true,
                            args = {
                                header = {
                                    type = "header",
                                    name = function(info) return format("The current best time:   |cffffffff%s|r", ConvertToTime(addon:GetBestTime(info[3],info[5]) or 0) or "None") end,
                                    order = 1,
                                    width = "full",
                                },
                                resetbtn = {
                                    type = "execute",
                                    name = L.options["Reset time"],
                                    desc = L.options["Deletes the records of your fastest time for the boss on this difficulty.\n\nWARNING:\nThis action cannot be reverted! \n(unless you edit the settings file by hand - DUH!)"],
                                    order = 2,
                                    func = function(info)
                                        local bestTimeOpt = GetBestTimeOpt(info)
                                        bestTimeOpt["header"].name = format("%s:   |cffffffff%s|r", L.options["The current best time"], "None")
                                        db.profile.Encounters[info[3]]["besttime"][info[5]] = nil
                                        addon:UpdateBestTimer(true,true)
                                    end,
                                    disabled = function(info) local bestTimeOpt=GetBestTimeOpt(info);return bestTimeOpt["header"].name == format("%s:   |cffffffff%s|r",L.options["The current best time"], "None") end,
                                },
                                revertbtn = {
                                    type = "execute",
                                    name = function(info)
                                        local categData = db.profile.Encounters[info[3]]["besttime"][info[5]]
                                        if not categData then return L.options["Revert unavailable"] end
                                        local revTime = categData["formertime"]
                                        if revTime ~= nil then
                                            return format("%s |cffffffff%s|r", L.options["Revert to"], ConvertToTime(revTime))
                                        else
                                            return L.options["Revert unavailable"]
                                        end
                                    end,
                                    desc = L.options["Allows you to revert to your former best time should an incorrect speed run time be recorded."],
                                    order = 3,
                                    func = function(info) 
                                        local revTime = db.profile.Encounters[info[3]]["besttime"][info[5]]["formertime"]
                                        local bestTimeOpt = GetBestTimeOpt(info)
                                        bestTimeOpt["header"].name = format("%s:   |cffffffff%s|r", L.options["The current best time"], ConvertToTime(revTime))
                                        addon:SetNewBestTime(revTime, info[3],info[5])
                                        db.profile.Encounters[info[3]]["besttime"][info[5]]["formertime"] = nil
                                        addon:UpdateBestTimer(true)
                                    end,
                                    disabled = function(info)
                                        local categData = db.profile.Encounters[info[3]]["besttime"][info[5]]
                                        if not categData then return true end
                                        local revTime = categData["formertime"]
                                        return revTime == nil
                                    end,
                                },
                            },
                        }
                    end
                else
                    enc_args[optionType].inline = true
                    enc_args[optionType].childGroups = nil
                end
            else
                enc_args[optionType] = nil
            end
            
            --------------------------------------------------------------
            -- Text Frame Filters --------------------------------------------------------------
            optionType = "filters"
            if data.filters or data.bossmessages then
                if data.bossmessages or data.filters.bossemotes or data.filters.raidwarnings then
                    enc_args[optionType] = {
                        type = "group",
                        name = "Filters",
                        order = 500,
                        inline = true,
                        childGroups = nil,
                        args = {},
                    }
                    
                    local filters_args = enc_args[optionType].args
                    
                    -- Boss Emotes (filter)
                    local filterorder = 1
                    if (data.filters and data.filters.bossemotes) or data.bossmessages then
                        local filterdata = data.bossmessages or data.filters.bossemotes
                        filters_args["bossemotes_header"] = {
                            type = "header",
                            name = "Boss Emotes",
                            order = filterorder,
                        }
                        filterorder = filterorder + 1
                        for var,info in pairs(filterdata) do
                            local icon = info.texture and format("|T%s:16:16|t ",info.texture) or ""
                            filters_args[var] = {
                                type = "toggle",
                                name = icon..info.name,
                                order = filterorder,
                                width = "full",
                                set = function(info,v) db.profile.Encounters[info[#info-2]].bossmessages[info[#info]].hide = v end,
                                get = function(info) return db.profile.Encounters[info[#info-2]].bossmessages[info[#info]].hide end
                            }
                            filterorder = filterorder + 1
                        end
                    end
                    
                    -- Raid Warnings (filter)
                    if data.filters and data.filters.raidwarnings then
                        local filterdata = data.filters.raidwarnings
                        filters_args["raidwarning_header"] = {
                            type = "header",
                            name = "Raid Warnings",
                            order = filterorder,
                        }
                        filterorder = filterorder + 1
                        for var,info in pairs(filterdata) do
                            local icon = info.texture and format("|T%s:16:16|t ",info.texture) or ""
                            filters_args[var] = {
                                type = "toggle",
                                name = icon..info.name,
                                order = filterorder,
                                width = "full",
                                set = function(info,v) db.profile.Encounters[info[#info-2]].raidmessages[info[#info]].hide = v end,
                                get = function(info) return db.profile.Encounters[info[#info-2]].raidmessages[info[#info]].hide end
                            }
                            filterorder = filterorder + 1
                        end
                    end
                end
            end
            
            
            -- Phrase Coloring --------------------------------------------------------------
            optionType = "phrasecolors"
            if data[optionType] then
                if not enc_args[optionType] or enc_args[optionType].args["phrasecolorsinfo"] then
                    enc_args[optionType] = {
                        type = "group",
                        name = "Phrase Coloring",
                        order = 900,
                        inline = true,
                        childGroups = nil,
                        disabled = function(info) 
                            local phrasecolors = addon.db.profile.Encounters[#info-1].phrasecolors
                            if not phrasecolors then
                                return true
                            else
                                for _,_ in pairs(phrasecolors) do
                                    return false
                                end
                                
                                return true
                            end
                        end,
                        args = {
                            customToggleInfoHeader = {
                                type = "header",
                                name = L.options["Toggle to Advanced to change the settings."].."\n",
                                order = 123,
                            },
                        },
                    }
                    local phrasecolors_args = enc_args[optionType].args
                else
                    enc_args[optionType].inline = true
                    enc_args[optionType].childGroups = nil
                    local phrasecolors_args = enc_args[optionType].args
                end
            else
                enc_args[optionType] = nil
            end
            -- Miscellaneous --------------------------------------------------------------
            optionType = "misc"
            if data[optionType] then
                enc_args[optionType] = {
                    type = "group",
                    name = data.misc_name or "Miscellaneous",
                    order = 600,
                    inline = true,
                    childGroups = nil,
                    args = {
                        header = {
                            type = "header",
                            name = L.options["Toggle to Advanced to change the settings."].."\n",
                            order = 123,
                        }
                    },
                }
            else
                enc_args[optionType] = nil
            end
            -------------------------------------------------------------------------------
            -- Battleground ---------------------------------------------------------------
            -------------------------------------------------------------------------------
            if addon:IsModuleBattleground(data.key) then
                optionType = "battleground"
                if enc_args[optionType] then
                    enc_args[optionType].inline = true
                else
                    local battleground_group = {
                        type = "group",
                        name = "Battleground",
                        order = 550,
                        inline = true,
                        childGroups = nil,
                        get = function(info) 
                            return db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]] end,
                        set = function(info,v) db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]] = v;addon.PvPScore:ScoreFrame_UpdateFrames() end,
                        args = {
                            color_presets_header = {
                                type = "header",
                                name = L.options["Battleground Score"].."\n",
                                order = 50,
                            },
                            ShowScoreSlots = {
                                type = "toggle",
                                name = "Show Score Slots",
                                desc = "Sets whether or not to show Score Slots for this particular battleground module.",
                                order = 100,
                            },
                        },
                    }
                    
                    if not addon.util.TraverseTable(data,"battleground","slots","disallowFactionSwitching") then
                        battleground_group.args.DisableSlotFactionSwitching = {
                            type = "toggle",
                            name = "Disable Slot Reversing",
                            desc = "Disables slot reversing according to faction.",
                            order = 150,
                        }
                    end
                    
                    enc_args[optionType] = battleground_group
                end
            end
            -----------------------------------------------------------------------------
            -- Other categories ---------------------------------------------------------
            for optionType,optionInfo in pairs(addon.EncDefaults) do
                local encData = data[optionType]
                local override = optionInfo.override
                if encData or override then
                    enc_args[optionType] = enc_args[optionType] or {
                        type = "group",
                        name = optionInfo.L,
                        order = optionInfo.order,
                        args = {},
                    }
                    enc_args[optionType].inline = true
                    enc_args[optionType].childGroups = nil

                    local option_args = enc_args[optionType].args
                    local customOrder = 1
                    
                    -- Custom Grouping
                    local keyList = {}
                    if not override then
                        for var,info in pairs(encData) do
                            keyList[var] = info
                        end                        
                    end
                    
                    local grouping = data.grouping
                    local order = data.ordering
                    local encounterCategories = addon.db.global.EncounterCategories
                    if grouping and type(grouping) == "table" then
                        for groupIndex,groupData in ipairs(grouping) do
                            if groupData[optionType] then
                                -- Adding the custom group
                                local var = format("%d_custom_group",groupIndex)
                                if encounterCategories then
                                    local GroupHeader = option_args[var] or {
                                        order = groupIndex*10000 + customOrder,
                                        width = "full",
                                    }
                                    GroupHeader.type = "header"
                                    GroupHeader.name = GetPhaseName(groupData,false)
                                    GroupHeader.args = nil
                                    option_args[var] = GroupHeader
                                    customOrder = customOrder + 1
                                else
                                    option_args[var] = nil
                                end
                                
                                -- Adding other elements
                                for _,groupVar in ipairs(groupData[optionType]) do
                                    local info = encData[groupVar]
                                    if info then
                                        keyList[groupVar] = nil
                                        InjectSimpleItem(option_args,groupVar,info,optionType,groupIndex*10000 + customOrder)
                                        customOrder = customOrder + 1
                                    end
                                end
                            end
                        end
                        
                        if customOrder > 1 then
                            local stuffToAdd = true
                            if next(keyList) == nil then stuffToAdd = false end
                            if stuffToAdd then
                                -- Adding the remaining spells group
                                local var = format("%d_custom_group",(#grouping+1))
                                if encounterCategories then
                                    local GroupHeader = option_args[var] or {
                                        order = customOrder,
                                        width = "full",
                                    }
                                    GroupHeader.type = "header"
                                    GroupHeader.name = format("%s  |cffffffff%s|r  %s",GENERAL_ICON,"Ungrouped",GENERAL_ICON)
                                    GroupHeader.args = nil
                                    option_args[var] = GroupHeader
                                    customOrder = customOrder + 1
                                else
                                    option_args[var] = nil
                                end
                                -- Adding the remaining spells
                                for var,info in pairs(keyList) do
                                    InjectSimpleItem(option_args,var,info,optionType,customOrder)
                                    customOrder = customOrder + 1
                                end
                            end
                        end    
                    -- Custom ordering
                    elseif order and type(order) == "table" then
                        for orderKey,orderData in pairs(order) do
                            if orderKey == optionType then
                                for i,var in ipairs(orderData) do
                                    local info = encData[var]
                                    if info then
                                        keyList[var] = nil
                                        InjectSimpleItem(option_args,var,info,optionType,customOrder)
                                        customOrder = customOrder + 1
                                    end
                                end
                            end
                        end
                        -- Adding the remaining spells
                        for var,info in pairs(keyList) do
                            InjectSimpleItem(option_args,var,info,optionType,customOrder)
                            customOrder = customOrder + 1
                        end
                    end
                    if customOrder == 1 then -- no custom-order alerts inserter
                        for var,info in pairs(override and optionInfo.list or encData) do
                            InjectSimpleItem(option_args,var,info,optionType)
                        end
                    end
                end
			end
		end
        
		-- ADVANCED MODE
        local cTank1,cTank2,cTank3,cTank4 = GetTexCoordsForRole("TANK")
        local cHeal1,cHeal2,cHeal3,cHeal4 = GetTexCoordsForRole("HEALER")
        local cDPS1,cDPS2,cDPS3,cDPS4 = GetTexCoordsForRole("DAMAGER")
        local iconRoleTank = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\LFGFRAME\\UI-LFG-ICON-ROLES",16,16,256,256,cTank1*256,cTank2*256,cTank3*256,cTank4*256)
        local iconRoleHeal = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\LFGFRAME\\UI-LFG-ICON-ROLES",16,16,256,256,cHeal1*256,cHeal2*256,cHeal3*256,cHeal4*256)
        local iconRoleDPS = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t","Interface\\LFGFRAME\\UI-LFG-ICON-ROLES",16,16,256,256,cDPS1*256,cDPS2*256,cDPS3*256,cDPS4*256)
        
        local function EnableForRole(info,v)
            local enabled = db.profile.Encounters[info[3]][info[#info-1]].enabled
            if type(enabled) == "table" then
                enabled[info[#info]] = v
                if not enabled.Tank and not enabled.Heal and not enabled.DPS then
                    db.profile.Encounters[info[3]][info[#info-1]].enabled = false
                end
            elseif type(enabled) == "boolean" then
                db.profile.Encounters[info[3]][info[#info-1]].enabled = {
                    [info[#info]] = true,
                }
            end
        end
        
        local function IsEnabledForRole(info)
            local enabled = db.profile.Encounters[info[3]][info[#info-1]].enabled
            if type(enabled) == "boolean" then
                return false
            elseif type(enabled) == "table" then
                return enabled[info[#info]]
            end
        end

        AdvancedItems = {
			VersionHeader = {
				type = "header",
				name = function(info)
					local version = EDB[info[#info-1]].version or "|cff808080"..L.options["Unknown"].."|r"
					return L.options["Version"]..": |cff99ff33"..version.."|r"
				end,
				order = 1,
				width = "full",
			},
			EnabledToggle = {
				type = "toggle",
				name = L.options["Enabled"],
				width = "half",
				order = 1,										-- data.key     -- info.var
				set = function(info,v) 
                    db.profile.Encounters[info[3]][info[#info-1]].enabled = v 
                    if addon:IsRunning() then addon:BroadcastThrottlingInfoUpdate(info[#info-2],EDB[info[3]], info[#info-1]) end
                end,
				get = function(info) 
                    local enabled = db.profile.Encounters[info[3]][info[#info-1]].enabled
                    if type(enabled) == "boolean" then
                        return enabled
                    else
                        return false
                    end
                end,
			},
            EnabledRole = {
                Tank = {
                    type = "toggle",
                    name = format("%s %s",iconRoleTank,L.options["Tank"]),
                    width = "half",
                    order = 2,
                    set = EnableForRole,
                    get = IsEnabledForRole,
                },
                Heal = {
                    type = "toggle",
                    name = format("%s %s",iconRoleHeal,L.options["Heal"]),
                    width = "half",
                    order = 3,
                    set = EnableForRole,
                    get = IsEnabledForRole,
                },
                DPS = {
                    type = "toggle",
                    name = format("%s %s",iconRoleDPS,L.options["DPS"]),
                    width = "half",
                    order = 4,
                    set = EnableForRole,
                    get = IsEnabledForRole,
                },
            },
			Options = {
				alerts = {
					header = {
						type = "header",
						--[[name = function(info)
							local key,var = info[3],info[5]
							return (EDB[key].alerts[var].icon and format("|T%s:16:16|t ",EDB[key].alerts[var].icon) or "")..EDB[key].alerts[var].varname
						end,]]
                        name = function(info) return TraversOptions(info.options,info,#info-2).name end,
						order = 90,
						width = "full",
					},
					color1 = {
						type = "select",
						name = L.options["Main Color"],
						order = 100,
						values = GetColors(true,false,"original color 1"),
					},
					color2 = {
						type = "select",
						name = L.options["Flash Color"],
						order = 200,
						values = GetColors(false,false,"original color 2"),
						disabled = function(info)
							local key,var = info[3],info[#info-2]
							return (not db.profile.Encounters[key][var].enabled) or (EDB[key].alerts[var].type == "simple")
						end,
					},
					sound = {
						type = "select",
						name = L.options["Sound"],
						order = 300,
						values = function(info) return GetSounds(true,EDB[info[3]].alerts[info[#info-2]].sound) end,
                        get = function(info) 
                            local key,var = info[3],info[#info-2]
                            local v = db.profile.Encounters[key][var].sound
                            if not v or v == "None" then
                                return "None"
                            elseif not db.profile.Sounds[v] and not db.profile.CustomSounds[v] then
                                return "#ModuleSpecific#"
                            else
                                return v
                            end
                        end,
                        set = function(info,v)
                            local key,var = info[3],info[#info-2]
                            if v == "#ModuleSpecific#" then 
                                db.profile.Encounters[key][var].sound = EDB[key].alerts[var].sound
                            else
                                db.profile.Encounters[key][var].sound = v
                            end
                        end,
					},
					--blank = genblank(350),
					flashtime = {
						type = "range",
						name = L.options["Flashtime"],
						desc = L.options["Flashtime in seconds left on alert"],
						order = 340,
						min = 1,
						max = 60,
						step = 1,
						disabled = function(info)
							local key,var = info[3],info[#info-2]
							return not ((EDB[key].alerts[var].type == "dropdown") or (EDB[key].alerts[var].type == "centerpopup"))
						end,
					},
                    audiocd = {
                        type = "select",
                        name = L.options["Audio Countdown"],
                        order = 335,
                        get = function(info) 
                            local key,var = info[3],info[#info-2]
                            local v = db.profile.Encounters[key][var].audiocd
                            if not v or v == false or v == "#off#" then
                                return "#off#"
                            else
                                if v == true then
                                    return "#default#"
                                else
                                    return v
                                end
                            end
                        end,
                        set = function(info,v)
                            local key,var = info[3],info[#info-2]
                            db.profile.Encounters[key][var].audiocd = v
                        end,
                        values = function() 
                            local voiceList = {}
                            voiceList["#off#"] = format("|cffffffff%s|r","|cffffff00Disabled|r")
                            voiceList["#default#"] = format("|cffffff00Default|r (%s)",addon.Alerts.db.profile.CountdownVoice)
                            for k,v in pairs(addon.Alerts.CountdownVoicesDB) do
                                voiceList[k] = k
                            end
                            return voiceList
                        end,
                        disabled = function(info)
							local key,var = info[3],info[#info-2]
							return not ((EDB[key].alerts[var].type == "dropdown") or (EDB[key].alerts[var].type == "centerpopup"))
						end,
                    },
                    --[[
                    audiocd = {
						type = "toggle",
						name = L.options["Audio Countdown"],
						order = 350,
						disabled = function(info)
							local key,var = info[3],info[5]
							return not ((EDB[key].alerts[var].type == "dropdown") or (EDB[key].alerts[var].type == "centerpopup"))
						end,
					},]]--
					flashscreen = {
						type = "toggle",
						name = L.options["Flash screen"],
						order = 400,
					},
                    emphasizewarning = {
                        type = "toggle",
						name = L.options["Emphasize warning"],
                        desc = L.options["Displays the warning text in the Emphasized Warnings frame instead of regular warning output."],
						order = 500,
                        disabled = function(info) return not addon:GetMessageEra(info[#info-2]) end,
                    },
                    emphasizetimer = {
                        type = "toggle",
						name = L.options["Emphasize timer"],
                        desc = L.options["The bar will end up in the Emphasis anchor stack."],
						order = 550,
                        disabled = function(info)
							local key,var = info[3],info[#info-2]
							return (not db.profile.Encounters[key][var].enabled) or (EDB[key].alerts[var].type == "simple")
						end,
                    },
                    counter = {
						type = "toggle",
						name = L.options["Counter"],
                        desc = L.options["Adds a counter to the alert text in the parentheses.\n\ne.g., Fire Breath |cffffd700(1)|r"],
						order = 600,
					},
                    stacks = {
                        type = "range",
                        name = L.options["Stacks"],
                        desc = L.options["Number of stacks at which alert activates."],
                        order = 590,
                        min = 2,
                        max = 100,
                        step = 1,
                        disabled = function(info) return not EDB[info[3]].alerts[info[#info-2]].stacks end,
                    },

                    blank = genblank(650),
					test = {
						type = "execute",
						name = L.options["Test"],
						order = 650,
						func = "TestAlert",
					},
					reset = {
						type = "execute",
						name = L.options["Reset"],
						order = 700,
						func = function(info)
							local key,var = info[3],info[#info-2]
							local defaults = addon.defaults.profile.Encounters[key][var]
							local vardb = db.profile.Encounters[key][var]
							for k,v in pairs(defaults) do vardb[k] = v end
						end,
					},
				},
				raidicons = {
					--[[desc = {
						type = "description",
						order = 100,
						name = function(info)
							local key,var = info[3],info[5]
							local varData = EDB[key].raidicons[var]
							local type = varData.type
                            
                            if type == "FRIENDLY" or type == "ENEMY" then
								return format(L.options["Uses  %s  (|cffffd200Icon %s|r)"],GetRaidIcon(varData.icon),varData.icon)
							elseif type == "MULTIFRIENDLY" or type == "MULTIENEMY" then
								return format(L.options["Uses %s (|cffffd200Icon %s|r to |cffffd200Icon %s|r)"],GetRaidIcon(varData.icon, varData.icon + varData.total - 1),varData.icon,varData.icon + varData.total - 1)
							end
						end,
					},]]
                    header = {
						type = "header",
						name = function(info) return TraversOptions(info.options,info,5).name end,
						order = 1,
						width = "full",
					},
                    throttle_blank = genblank(150),
                    throttle = {
						type = "toggle",
						name = L.options["Reduce spam"],
                        desc = L.options["Should multiple people mark using this icon, DXE will automatically determine the one person in the group to do it.\n\nThe raid leader will have priority followed by the raid assists and then by regular players."],
						order = 200,
                        get = function(info)
                            if EDB[info[3]].raidicons[info[5]].throttle == false then
                                return false
                            else
                                return db.profile.Encounters[info[3]][info[5]].throttle
                            end
                        end,
                        disabled = function(info) 
                            return EDB[info[3]].raidicons[info[5]].throttle == false
                        end,
					},
				},
				arrows = {
                    header = {
						type = "header",
						name = function(info) return TraversOptions(info.options,info,5).name end,
						order = 1,
						width = "full",
					},
					sound = {
						type = "select",
						name = L.options["Sound"],
						order = 100,
                        values = function(info) return GetSounds(true, EDB[info[3]].arrows[info[5]].sound) end,
                        get = function(info) 
                            local v = db.profile.Encounters[info[3]][info[5]].sound
                            if not v or v == "None" then
                                return "None"
                            elseif not db.profile.Sounds[v] and not db.profile.CustomSounds[v] then
                                return "#ModuleSpecific#"
                            else
                                return v
                            end
                        end,
                        set = function(info,v)
                            if v == "#ModuleSpecific#" then 
                                db.profile.Encounters[info[3]][info[5]].sound = EDB[info[3]].arrows[info[5]].sound
                            else
                                db.profile.Encounters[info[3]][info[5]].sound = v
                            end
                        end,
					},
				},
				windows = {
					-- prefix options with (%w+)window
					proxoverride = {
						type = "toggle",
						name = L.options["Custom range"],
						order = 100,
					},
					proxrange = {
						type = "range",
						name = L.options["Range"],
						order = 200,
						min = 1,
						max = 100,
						step = 1,
						disabled = function(info)
							local key = info[3]
							return not (db.profile.Encounters[key]["proxwindow"].enabled and db.profile.Encounters[key]["proxwindow"].proxoverride)
						end,
					},
					apboverride = {
						type = "toggle",
						name = L.options["Custom threshold"],
						order = 100,
					},
					apbthreshold = {
						type = "range",
						name = L.options["Threshold"],
						order = 200,
						min = 1,
						max = 99,
						step = 1,
						disabled = function(info)
							local key = info[3]
							return not (db.profile.Encounters[key]["apbwindow"].enabled and db.profile.Encounters[key]["apbwindow"].apboverride)
						end,
					},
				},
                announces = {
                    header = {
						type = "header",
						name = function(info) return TraversOptions(info.options,info,5).name end,
						order = 1,
						width = "full",
					},
                    throttle = {
						type = "toggle",
						name = L.options["Reduce spam"],
                        desc = L.options["Should multiple people announce this message, DXE will automatically determine the one person in the group to do it.\n\nThe raid leader will have priority followed by the raid assists and then by regular players."],
						order = 100,
                        get = function(info)
                            if EDB[info[3]].announces[info[5]].throttle == false then
                                return false
                            else
                                return db.profile.Encounters[info[3]][info[5]].throttle
                            end
                        end,
                        disabled = function(info) 
                            if type(EDB[info[3]].announces[info[5]].throttle) ~= "boolean" then
                                return true
                            elseif EDB[info[3]].announces[info[5]].throttle == false then
                                return true
                            else
                                return false
                            end
                        end,
					},
                },
            }
		}

		do
			local info_n = 7						 -- var
			local info_n_MINUS_4 = info_n - 4 -- type
			local info_n_MINUS_2 = info_n - 2 -- key


			function handler:DisableSettings(info)
				return not db.profile.Encounters[info[3]][info[#info-2]].enabled
			end

			function handler:GetOption(info)
				return db.profile.Encounters[info[3]][info[#info-2]][info[#info]]
			end

			function handler:SetOption(info,v)
                db.profile.Encounters[info[3]][info[#info-2]][info[#info]] = v
			end

            local function abbrev(value)
                return value > 1000000 and ("%.2fm"):format(value / 1000000) or ("%dk"):format(value / 1000)
            end

			function handler:TestAlert(info)
                local key,var = info[3],info[#info-2]
				local info = EDB[key].alerts[var]
				local stgs = db.profile.Encounters[key][var]
                local text = info.varname:gsub("\124T(.+)\124t","");
                local emphasizewarning = stgs.emphasizewarning or false
                local emphasizetimer = stgs.emphasizetimer or false
                if stgs.counter then
                    text = format("%s (%s)",text,1)
                end
                local fillDirection = info.fillDirection or "FILL"
                if info.type == "dropdown" then
					addon.Alerts:Dropdown(var,text,10,5,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,info.icon,stgs.audiocd,nil,emphasizetimer,fillDirection)
				elseif info.type == "centerpopup" then
					addon.Alerts:CenterPopup(var,text,10,5,stgs.sound,stgs.color1,stgs.color2,stgs.flashscreen,info.icon,stgs.audiocd,nil,emphasizewarning,emphasizetimer,fillDirection)
				elseif info.type == "simple" then
                    addon.Alerts:Simple(var,text,5,stgs.sound,stgs.color1,stgs.flashscreen,info.icon,emphasizewarning)
				elseif info.type == "absorb" or info.type == "inflict" then
                    local total = next(info.values)
                    addon.Alerts:Absorb(info.type,var, text, info.textformat, 10, 5, stgs.sound, stgs.color1, stgs.color2, stgs.flashscreen, info.icon, total, nil, total/2,text,stgs.emphasizewarning,emphasizetimer)
                elseif info.type == "absorbheal" then
                    local total = next(info.values)
                    text = format(info.text:gsub("#%d#",addon.PNAME)..(stgs.counter and " (1)" or ""), abbrev(total/2), total, 0)
                    addon.Alerts:AbsorbHeal(var, text, 10, 5, stgs.sound, stgs.color1, stgs.color2, stgs.flashscreen, info.icon, total, nil, total/2, emphasizetimer)
                end
			end
		end
        
        local RadarColors = {}
            for k,c in pairs(addon.db.profile.Colors) do
                local hex = ("|cff%02x%02x%02x%s|r"):format(c.r*255,c.g*255,c.b*255,L[k])
                RadarColors[k] = hex
            end
            RadarColors["0-Off"] = "Off"
            RadarColors["1-Default"] = "Default"
        
        local GetRadarOption = function(info)
            return db.profile.Encounters[info[3]]["radars"][info[#info]]
        end
        
        local SetRadarOption = function(info,v)
            db.profile.Encounters[info[3]]["radars"][info[#info]] = v
        end
        
        local function InjectAdvancedItem(option_args,subgroup_args,var,info,optionType,order,fullinfo)
            local icon = ""
            if optionType == "alerts" then
                if info.texture then
                    icon = format("|T%s:16:16|t ",info.texture) 
                elseif info.icon then
                    if info.icon:match("^<.+>$") then
                        icon = format("|T%s:16:16|t ","Interface\\ICONS\\INV_Misc_QuestionMark")
                    else
                        icon = format("|T%s:16:16|t ",info.icon)
                    end
                end
            elseif optionType == "raidicons" and info.texture then
                icon = format("|T%s:16:16|t ",info.texture)
            elseif optionType == "arrows" and info.texture then
                icon = format("|T%s:16:16|t ",info.texture)
            end
            subgroup_args[var] = option_args[var] or subgroup_args[var] or {
                name = GetColoredVarName(info,optionType,icon),
                width = "full",
            }
            if option_args ~= subgroup_args then option_args[var] = nil end

            subgroup_args[var].type = "group"
            subgroup_args[var].args = {}
            subgroup_args[var].get = nil
            subgroup_args[var].set = nil
            subgroup_args[var].order = order

            local item_args = subgroup_args[var].args
            item_args.enabled = AdvancedItems.EnabledToggle
            item_args.Tank = AdvancedItems.EnabledRole.Tank
            item_args.Heal = AdvancedItems.EnabledRole.Heal
            item_args.DPS = AdvancedItems.EnabledRole.DPS

            if AdvancedItems.Options[optionType] then
                item_args.settings = {
                    type = "group",
                    name = L.options["Settings"],
                    order = 5,
                    inline = true,
                    disabled = "DisableSettings",
                    get = "GetOption",
                    set = "SetOption",
                    args = {}
                }

                local settings_args = item_args.settings.args
                
                for k,item in pairs(AdvancedItems.Options[optionType]) do
                    -- special handling for windows since not all windows share the same options
                    if optionType == "windows" then
                        -- prefix needs to match
                        if k:find("^"..var:match("(%w+)window")) then
                            settings_args[k] = item
                        end
                    else
                        settings_args[k] = item
                    end
                    
                end
                if optionType == "windows" and var:match("(%w+)window") == "prox" then
                    if fullinfo.radars then
                        item_args.radars = {
                            type = "group",
                            name = "Radar Circles",
                            order = 300,
                            inline = true,
                            childGroups = "tab",
                            args = {},
                        }
                        for key,radarinfo in pairs(fullinfo.radars) do
                            local radarGroup = {
                                type = "select",
                                name = GetColoredVarName(radarinfo, "radars"),
                                values = RadarColors,
                                get = GetRadarOption,
                                set = SetRadarOption,
                            }
                            item_args.radars.args[key] = radarGroup
                        end
                    end
                end
                
                if optionType == "raidicons" then
                    local markMax = 0
                    local orderOffset = 10
                    if info.type == "ENEMY" or info.type == "FRIENDLY" then
                        markMax = 1
                    elseif info.type == "MULTIENEMY" or info.type == "MULTIFRIENDLY" then
                        markMax = info.total or 1
                    end
                    for n=1,info.total or 1 do
                        local markVar = "mark"..n
                        settings_args[markVar] = {
                            type = "select",
                            name = format("%s %d",L.options["Icon"],n),
                            order = n+orderOffset,
                            values = GetRaidIcons(true),
                        }
                    end
                end
                
                if optionType == "announces" then
                    subgroup_args[var].disabled = function() 
                        if optionType == "announces" and info.subtype == "achievement" then
                            return not db.profile.Chat.AchievementAnnouncements
                        else
                            return false
                        end
                    end
                end
            end
        end

		local function InjectAdvancedOptions(data,enc_args)
			-- Add output options
			-- Speed kills ---------------------------------------------------------------
            local optionType = "besttime"
            -- Get a list of all speed kill time variables
            local besttime_data = db.profile.Encounters[data.key]["besttime"] or {}
            local showCategory = false
            for _,_ in pairs(besttime_data) do
                showCategory = true
                break
            end
            if showCategory then
                if not enc_args[optionType] then
                    enc_args[optionType] = {
                        type = "group",
                        name = "Speed kills",
                        order = 700,
                        args = {
                            customToggleInfoHeader = {
                                type = "header",
                                name = L.options["There are no speed kill times for this boss."].."\n",
                                order = 123,
                            }
                        },
                        disabled = function()
                            for _,_ in pairs(besttime_data) do
                                return false
                            end
                            return true
                        end,
                    }
                    for _,_ in pairs(besttime_data) do
                        enc_args[optionType]["args"]={}
                        break
                    end
                    
                    
                    for key,categoryKeyData in pairs(besttime_data) do
                        local speedkillOrder, speedkillName
                        
                        if addon:IsModuleBattleground(data.key) then
                            local faction = addon.Faction:Of("player")
                            speedkillOrder = (key == faction) and 1 or 2
                            speedkillName = format("Victory as %s", bgCategory[key])
                        else
                            local raidsize = categoryKeyData["raidsize"]
                            local difficulty = categoryKeyData["difficulty"]
                            speedkillOrder = raidsize + (difficulty == "Normal" and 0 or 1)
                            speedkillName = format("%s-Player (%s)", raidsize, difficulty)
                        end  
                        
                        enc_args[optionType]["args"][key] = {
                            type = "group",
                            name = speedkillName,
                            order = speedkillOrder,
                            inline = true,
                            args = {
                                header = {
                                    type = "header",
                                    name = function(info) return format("The current best time:   |cffffffff%s|r", ConvertToTime(addon:GetBestTime(info[3],info[5]) or 0) or "None") end,
                                    order = 1,
                                    width = "full",
                                },
                                resetbtn = {
                                    type = "execute",
                                    name = L.options["Reset time"],
                                    desc = L.options["Deletes the records of your fastest time for the boss on this difficulty.\n\nWARNING:\nThis action cannot be reverted! \n(unless you edit the settings file by hand - DUH!)"],
                                    order = 2,
                                    func = function(info)
                                        local bestTimeOpt = GetBestTimeOpt(info)
                                        bestTimeOpt["header"].name = format("%s:   |cffffffff%s|r", L.options["The current best time"], "None")
                                        db.profile.Encounters[info[3]]["besttime"][info[5]] = nil
                                        addon:UpdateBestTimer(true,true)
                                    end,
                                    disabled = function(info) local bestTimeOpt=GetBestTimeOpt(info);return bestTimeOpt["header"].name == format("%s:   |cffffffff%s|r",L.options["The current best time"], "None") end,
                                },
                                revertbtn = {
                                    type = "execute",
                                    name = function(info)
                                        local categData = db.profile.Encounters[info[3]]["besttime"][info[5]]
                                        if not categData then return L.options["Revert unavailable"] end
                                        local revTime = categData["formertime"]
                                        if revTime ~= nil then
                                            return format("%s |cffffffff%s|r", L.options["Revert to"], ConvertToTime(revTime))
                                        else
                                            return L.options["Revert unavailable"]
                                        end
                                    end,
                                    desc = L.options["Allows you to revert to your former best time should an incorrect speed run time be recorded."],
                                    order = 3,
                                    func = function(info) 
                                        local revTime = db.profile.Encounters[info[3]]["besttime"][info[5]]["formertime"]
                                        local bestTimeOpt = GetBestTimeOpt(info)
                                        bestTimeOpt["header"].name = format("%s:   |cffffffff%s|r", L.options["The current best time"], ConvertToTime(revTime))
                                        addon:SetNewBestTime(revTime, info[3],info[5])
                                        db.profile.Encounters[info[3]]["besttime"][info[5]]["formertime"] = nil
                                        addon:UpdateBestTimer(true)
                                    end,
                                    disabled = function(info)
                                        local categData = db.profile.Encounters[info[3]]["besttime"][info[5]]
                                        if not categData then return true end
                                        local revTime = categData["formertime"]
                                        return revTime == nil
                                    end,
                                },
                            },
                        }
                    end
                else
                    enc_args[optionType].inline = false
                end
            else
                enc_args[optionType] = nil
            end
            --------------------------------------------------------------
            -- Text Frame Filters --------------------------------------------------------------
            optionType = "filters"
            if data.filters or data.bossmessages then
                if data.bossmessages or data.filters.bossemotes or data.filters.raidwarnings then
                    enc_args[optionType] = {
                        type = "group",
                        name = "Filters",
                        order = 500,
                        inline = false,
                        childGroups = "tab",
                        args = {},
                    }
                    
                    local filters_args = enc_args[optionType].args
                    
                    -- Boss Emotes (filter)
                    local filterorder = 1
                    if (data.filters and data.filters.bossemotes) or data.bossmessages then
                        local filterinfo = data.bossmessages or data.filters.bossemotes
                        filters_args["bossemotes_header"] = {
                            type = "header",
                            name = "Boss Emotes",
                            order = filterorder,
                        }
                        filterorder = filterorder + 1
                        
                        for var,filterdata in pairs(filterinfo) do
                            local icon = filterdata.texture and format("|T%s:16:16|t ",filterdata.texture) or ""
                            filters_args[var] = {
                                type = "group",
                                name = icon..filterdata.name,
                                order = filterorder,
                                width = "full",
                                inline = true,
                                set = function(info,v) db.profile.Encounters[info[#info-3]].bossmessages[info[#info-1]][info[#info]] = v end,
                                get = function(info) return db.profile.Encounters[info[#info-3]].bossmessages[info[#info-1]][info[#info]] end,
                                args = {
                                    hide = {
                                        type = "toggle",
                                        name = "Hide",
                                        order = 1,
                                    },
                                    removeIcon = {
                                        type = "toggle",
                                        name = "Remove icon",
                                        order = 2,
                                        disabled = function(info) return db.profile.Encounters[info[#info-3]].bossmessages[info[#info-1]].hide or not filterdata.hasIcon end
                                    }
                                }
                            }
                            filterorder = filterorder + 1
                        end
                    end
                    
                    -- Raid Warnings (filter)
                    if data.filters and data.filters.raidwarnings then
                        local filterdata = data.filters.raidwarnings
                        filters_args["raidwarning_header"] = {
                            type = "header",
                            name = "Raid Warnings",
                            order = filterorder,
                        }
                        
                        filterorder = filterorder + 1
                        
                        for var,filterdata in pairs(filterdata) do
                            local icon = filterdata.texture and format("|T%s:16:16|t ",filterdata.texture) or ""
                            filters_args[var] = {
                                type = "group",
                                name = icon..filterdata.name,
                                order = filterorder,
                                width = "full",
                                inline = true,
                                set = function(info,v) db.profile.Encounters[info[#info-3]].raidmessages[info[#info-1]][info[#info]] = v end,
                                get = function(info) return db.profile.Encounters[info[#info-3]].raidmessages[info[#info-1]][info[#info]] end,
                                args = {
                                    hide = {
                                        type = "toggle",
                                        name = "Hide",
                                        order = 1,
                                    },
                                }
                            }
                            
                            filterorder = filterorder + 1
                        end
                    end
                end
            end
            -------------------------------------------------------------------------------
            -- Phrase Coloring --------------------------------------------------------------
            optionType = "phrasecolors"
            local selectedModulePhrase = nil
            local modulePhraseMode = "select"
            
            local ModulePhrasePattern_Select,ModulePhrasePattern_Edit,ModulePhrasePattern_New
            
            local function ModulePhraseMode(info,mode)
                if mode == "select" then
                    modulePhraseMode = mode
                    encs_args[info[#info-3]].args[info[#info-2]].args.phrasecolors.args["ModulePhrase"] = ModulePhrasePattern_Select
                elseif mode == "edit" then
                    modulePhraseMode = mode
                    encs_args[info[#info-3]].args[info[#info-2]].args.phrasecolors.args["ModulePhrase"] = ModulePhrasePattern_Edit
                elseif mode == "new" then
                    modulePhraseMode = mode
                    selectedPhrase = ""
                    encs_args[info[#info-3]].args[info[#info-2]].args.phrasecolors.args["ModulePhrase"] = ModulePhrasePattern_New
                end
            end
            
            local function GetModulePhrases(info)
                local modulePhrases = {}
                if addon.db.profile.Encounters[info[#info-2]].phrasecolors then
                    for k,v in pairs(addon.db.profile.Encounters[info[#info-2]].phrasecolors) do
                        local found = false
                        if EDB[info[3]].phrasecolors then
                            for _,phraseData in ipairs(EDB[info[3]].phrasecolors) do
                                if k == phraseData[1] then
                                    found = true
                                    break
                                end
                            end
                        end
                        
                        if found then
                            modulePhrases[k] = format("|cff00ff00%s|r",k)
                        else
                            modulePhrases[k] = format("|cff2fbbff%s|r",k)
                        end
                    end
                end
                table.sort(modulePhrases)
                if not selectedModulePhrase then selectedModulePhrase = next(modulePhrases) end
                
                return modulePhrases
            end
            
            ModulePhrasePattern_Select = {
                type = "select",
                name = L.options["Phrase Pattern"],
                desc = L.options["Select a phrase pattern for coloring."],
                order = 125,
                values = GetModulePhrases,
                set = function(info,v) selectedModulePhrase = v end,
                get = function() return selectedModulePhrase end ,
            }
            ModulePhrasePattern_Edit = {
                type = "input",
                name = L.options["Phrase Pattern"],
                desc = L.options["Edit a phrase pattern for coloring."],
                get = function() return selectedModulePhrase end,
                set = function(info,v)
                    if not v or v == "" then
                        ModulePhraseMode(info,"select")
                    else
                        if v ~= selectedModulePhrase then
                            addon.db.profile.Encounters[info[3]].phrasecolors[v] = addon.db.profile.Encounters[info[3]].phrasecolors[selectedModulePhrase]
                            addon.db.profile.Encounters[info[3]].phrasecolors[selectedModulePhrase] = nil
                            selectedModulePhrase = v
                        end
                        ModulePhraseMode(info,"select")
                    end
                end,
                order = 125,
            }
            ModulePhrasePattern_New = {
                type = "input",
                name = L.options["Phrase Pattern"],
                desc = L.options["Add a new phrase pattern for coloring."],
                get = function() return selectedModulePhrase end,
                set = function(info,v)
                    if v == "" then return end
                    --addon.db.profile.Encounters[info[3]].phrasecolors[selectedModulePhrase][2] = EDB[info[3]].phrasecolors[selectedModulePhrase][2]
                    --addon.db.profile.Encounters[info[#info-2]]
                    if not addon.db.profile.Encounters[info[#info-2]].phrasecolors then
                        addon.db.profile.Encounters[info[#info-2]].phrasecolors = {}
                    elseif addon.db.profile.Encounters[info[#info-2]].phrasecolors[v] then
                        addon:Print("Phrase |cffffff00"..v.."|r is already defined among |cff00ff00Phrase patterns.|r")
                        selectedModulePhrase = v
                        ModulePhraseMode(info,"select")
                        return
                    end
                    
                    local phraseData = {}
                    phraseData.color = "WHITE"
                    phraseData.custom = true
                    addon.db.profile.Encounters[info[#info-2]].phrasecolors[v] = phraseData
                    selectedModulePhrase = v
                    ModulePhraseMode(info,"select")
                end,
                order = 125,
            }
            
            
            local colors = {}
            for k,c in pairs(addon.db.profile.Colors) do
                local hex = ("|cff%02x%02x%02x%s|r"):format(c.r*255,c.g*255,c.b*255,L[k])
                colors[k] = hex
            end
            colors["Off"] = "Off"
            --if data[optionType] then
                if not enc_args[optionType] or enc_args[optionType].args["customToggleInfoHeader"] then
                    enc_args[optionType] = {
                        type = "group",
                        name = "Phrase Coloring",
                        order = 900,
                        inline = false,
                        childGroups = nil,
                        args = {
                        },
                    }
                        enc_args[optionType].args = {
                            phrasecolorsinfo = {
                                type = "description",
                                name = L.options["Here you can change specific coloring settings for this boss module."].."\n",
                                order = 123,
                            },
                            ModulePhrase = {
                                type = "select",
                                name = L.options["Phrase Pattern"],
                                desc = L.options["Select a phrase for coloring."],
                                order = 125,
                                values = GetModulePhrases,
                                set = function(info,v) selectedModulePhrase = v end,
                                get = function() return selectedModulePhrase end ,
                            },
                            ModulePhraseColor = {
                                type = "select",
                                name = L.options["Phrase Color"],
                                desc = L.options["The color of selected phrase"],
                                order = 130,
                                values = colors,
                                disabled = function() return modulePhraseMode ~= "select" end,
                                get = function(info) if selectedModulePhrase then 
                                    return addon.db.profile.Encounters[info[3]].phrasecolors[selectedModulePhrase].color end
                                end,
                                set = function(info,v)
                                    if selectedModulePhrase then
                                        addon.db.profile.Encounters[info[3]].phrasecolors[selectedModulePhrase]["color"] = v
                                    end
                                end, 
                            },
                            ModulePhraseResetColor = {
                                type = "execute",
                                name = L.options["Reset"],
                                desc = L.options["Resets the selected phrase coloring setttings to its default value."],
                                order = 135,
                                disabled = function(info) 
                                    if modulePhraseMode ~= "select" then return true end
                                    if EDB[info[3]].phrasecolors then
                                        for i,phraseData in ipairs(EDB[info[3]].phrasecolors) do
                                            if selectedModulePhrase == phraseData[1] then return false end
                                        end
                                    end
                                    
                                    return true
                                end,
                                func = function(info)
                                    for i,phraseData in ipairs(EDB[info[3]].phrasecolors) do
                                        if phraseData[1] == selectedModulePhrase then
                                            addon.db.profile.Encounters[info[3]].phrasecolors[selectedModulePhrase]["color"] = phraseData[2]
                                            break
                                        end
                                    end
                                end,
                            },
                            ModulePhraseResetAllColors = {
                                type = "execute",
                                name = L.options["Reset All"],
                                desc = L.options["Resets all global phrase coloring setttings to their default values."],
                                order = 140,
                                disabled = function(info) 
                                    if modulePhraseMode ~= "select" then return true end
                                    if EDB[info[3]].phrasecolors then
                                        for i,phraseData in ipairs(EDB[info[3]].phrasecolors) do
                                            if selectedModulePhrase == phraseData[1] then return false end
                                        end
                                    end
                                    return true
                                end,
                                func = function(info)
                                    for k,c in pairs(addon.db.profile.Encounters[info[3]].phrasecolors) do
                                        for i,phraseData in ipairs(EDB[info[3]].phrasecolors) do
                                            if phraseData[1] == k then
                                                addon.db.profile.Encounters[info[3]].phrasecolors[k]["color"] = phraseData[2]
                                                break
                                            end
                                        end
                                    end
                                end,
                                confirm = true,
                            },
                            ModulePhraseEdit = {
                                type = "execute",
                                name = L.options["Edit"],
                                disabled = function(info) 
                                    if modulePhraseMode ~= "select" then return true end
                                    if selectedModulePhrase then
                                        if EDB[info[3]].phrasecolors then
                                            for i,phraseData in ipairs(EDB[info[3]].phrasecolors) do
                                                if selectedModulePhrase == phraseData[1] then return true end
                                            end
                                        else
                                            return false
                                        end
                                    else
                                        return true
                                    end
                                end,
                                order = 138,
                                width = "half",
                                func = function(info) 
                                    ModulePhraseMode(info,"edit")
                                end,
                            },
                            modulephrase_blank1 = genblank(137),
                            ModulePhraseRemove = {
                                type = "execute",
                                name = L.options["Remove"],
                                disabled = function(info) 
                                    if modulePhraseMode ~= "select" then return true end
                                    if selectedModulePhrase then
                                        if EDB[info[3]].phrasecolors then
                                            for i,phraseData in ipairs(EDB[info[3]].phrasecolors) do
                                                if selectedModulePhrase == phraseData[1] then return true end
                                            end
                                        else
                                            return false
                                        end
                                    else
                                        return true
                                    end
                                end,
                                order = 139,
                                width = "half",
                                func = function(info) 
                                    if not EDB[info[3]].phrasecolors or not EDB[info[3]].phrasecolors[selectedModulePhrase] then 
                                        addon.db.profile.Encounters[info[3]].phrasecolors[selectedModulePhrase] = nil
                                        selectedModulePhrase = nil
                                    end
                                end,
                                confirm = true,
                                confirmText = format("Are you sure you want to remove %s?",selectedPhrase or "this pattern"),
                            },
                            ModulePhraseNew = {
                                type = "execute",
                                name = L.options["New"],
                                disabled = function() return modulePhraseMode ~= "select" end,
                                order = 134,
                                func = function(info) 
                                    if modulePhraseMode == "select" then
                                        ModulePhraseMode(info,"new")
                                    end
                                end,
                            },
                        }
                else
                   enc_args[optionType].inline = false
                    local phrasecolors_args = enc_args[optionType].args
                end
            -------------------------------------------------------------------------------
            
            -------------------------------------------------------------------------------
            -- Miscellaneous --------------------------------------------------------------
            -------------------------------------------------------------------------------
            local updatemiscitems
            optionType = "misc"
            if data[optionType] then
                local miscrefreshfunc
                local misc_group
                misc_group = {
                    type = "group",
                    name = data.misc.name or "Miscellaneous",
                    order = 600,
                    inline = false,
                    childGroups = nil,
                    disabled = function(info) 
                        if miscrefreshfunc then
                            misc_group.args = miscrefreshfunc()
                            updatemiscitems(misc_group.args)
                            addon:AddMiscDefaults(data.key,misc_group.args)
                        end
                        if not data["misc"] then
                            return true
                        else
                            for k,_ in pairs(data["misc"]) do
                                return false
                            end
                        end
                        return true
                    end,
                    args = {},
                }
                enc_args[optionType] = misc_group
                local miscellaneous_args = enc_args[optionType].args
                if data[optionType].args then
                    local miscargs = data[optionType].args
                    if type(miscargs) == "table" then
                        for var,data in pairs(miscargs) do
                            local item
                            local misc_disabled = function()
                                if data.disabled then
                                    return type(data.disabled) == "function" and data.disabled() or data.disabled
                                else
                                    return false
                                end
                            end
                            
                            if data.type == "toggle" then
                                item = {
                                    type = "toggle",
                                    name = data.name,
                                    desc = data.desc,
                                    order = data.order,
                                    width = "full",
                                    get = function(info) return db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value end,
                                    set = function(info,v) db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value = v end,
                                    disabled = misc_disabled
                                }
                            elseif data.type == "select" then
                                item = {
                                    type = "select",
                                    name = data.name,
                                    desc = data.desc,
                                    order = data.order,
                                    values = data.values,
                                    width = data.width or "fill",
                                    get = function(info) return db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value end,
                                    set = function(info,v) 
                                        db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value = v
                                        addon:BroadcastThrottlingInfoUpdate(info[#info-1],EDB[info[3]], info[#info])
                                    end,
                                    disabled = misc_disabled
                                }
                            elseif data.type == "range" then
                                item = {
                                    type = "range",
                                    name = data.name,
                                    desc = data.desc,
                                    order = data.order,
                                    min = data.min or 0,
                                    max = data.max or 100,
                                    step = data.step or 1,
                                    width = data.width,
                                    get = function(info) return db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value end,
                                    set = function(info,v) db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value = v end,
                                    disabled = misc_disabled
                                }
                            elseif data.type == "input" then
                                item = {
                                    type = "input",
                                    name = data.name,
                                    desc = data.desc,
                                    order = data.order,
                                    width = data.width,
                                    get = function(info) return db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value end,
                                    set = function(info,v) db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value = v end,
                                    disabled = misc_disabled,
                                }
                            elseif data.type == "description" then
                                item = {
                                    type = "description",
                                    name = data.name,
                                    order = data.order,
                                    fontSize = data.fontSize,
                                }
                            elseif data.type == "execute" then
                                item = {
                                    type = "execute",
                                    name = data.name,
                                    desc = data.desc or "",
                                    order = data.order,
                                    func = data.func,
                                    width = data.width or "half",
                                    disabled = misc_disabled
                                }
                            elseif data.type == "header" then
                                item = {
                                    type = "header",
                                    name = data.name,
                                    desc = data.desc or "",
                                    order = data.order,
                                }
                            elseif data.type == "blank" then
                                item = genblank(data.order)
                            end
                            
                            if item then miscellaneous_args[var] = item end
                        end
                    elseif type(miscargs) == "function" then
                        miscrefreshfunc = miscargs
                    end
                end
                
            else
                enc_args[optionType] = nil
            end
            
            -------------------------------------------------------------------------------
            -- Battleground ---------------------------------------------------------------
            -------------------------------------------------------------------------------
            if addon:IsModuleBattleground(data.key) then
                optionType = "battleground"
                if enc_args[optionType] then
                    enc_args[optionType].inline = false
                else
                    local battleground_group = {
                        type = "group",
                        name = "Battleground",
                        order = 550,
                        inline = false,
                        childGroups = nil,
                        get = function(info) 
                            return db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]] end,
                        set = function(info,v) db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]] = v;addon.PvPScore:ScoreFrame_UpdateFrames() end,
                        args = {
                            color_presets_header = {
                                type = "header",
                                name = L.options["Battleground Score"].."\n",
                                order = 50,
                            },
                            ShowScoreSlots = {
                                type = "toggle",
                                name = "Show Score Slots",
                                desc = "Sets whether or not to show Score Slots for this particular battleground module.",
                                order = 100,
                            },
                        },
                    }
                    
                    if not addon.util.TraverseTable(data,"battleground","slots","disallowFactionSwitching") then
                        battleground_group.args.DisableSlotFactionSwitching = {
                            type = "toggle",
                            name = "Disable Slot Reversing",
                            desc = "Disables slot reversing according to faction.",
                            order = 150,
                        }
                    end
                    
                    enc_args[optionType] = battleground_group
                end
            end
            
            updatemiscitems = function(args)
                for key,item in pairs(args) do
                    if item.type == "execute" or item.type == "toggle" or item.type == "select" or item.type == "range" then
                        if not item.get then
                            item.get = function(info) 
                                return db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value
                            end
                        end       
                        if not item.set then item.set = function(info,v)
                            db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value = v end
                        end
                    end
                end
                
                local orderedArgs = {}
                for key,item in pairs(args) do
                    orderedArgs[item.order] = item
                end
                
                for order,item in ipairs(orderedArgs) do
                    if item.type == "select" and item.validate then
                        item.get = function(info,external)
                            if not external then
                                local values = info.option.values
                                local valueSet
                                if type(values) == "table" then
                                    valueSet = values
                                elseif type(values) == "function" then
                                    valueSet = values(info)
                                end
                                local value = db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value

                                if not valueSet[value] then
                                    db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value = item.default or next(valueSet)
                                end
                            end
                            
                            return db.profile.Encounters[info[#info-2]][info[#info-1]][info[#info]].value
                        end
                    end
                end
            end
            
            
            for optionType,optionInfo in pairs(addon.EncDefaults) do
                local encData = data[optionType]
				local override = optionInfo.override
                local include = true
                
				if (encData or override) and include then
                    enc_args[optionType] = enc_args[optionType] or {
						type = "group",
						name = optionInfo.L,
						order = optionInfo.order,
						args = {},
					}
					enc_args[optionType].inline = nil
					enc_args[optionType].childGroups = "select"

					local option_args = enc_args[optionType].args
                    local customOrder = 1
                    local customOrdering = false
                    
                    local keyList = {}
                    if not override then
                        for var,info in pairs(encData) do
                            keyList[var] = info
                        end                        
                    end
                    
                    -- Custom Grouping
                    local grouping = data.grouping
                    local ordering = data.ordering
                    local encounterCategories = addon.db.global.EncounterCategories
                    
                    if grouping and type(grouping) == "table" then
                        for groupIndex,groupData in ipairs(grouping) do
                            if groupData[optionType] then
                                -- Adding the phase group
                                local var = format("%d_custom_group",groupIndex)
                                local CustomGroup_args
                                if encounterCategories then
                                    local CustomGroup = option_args[var] or {
                                        order = groupIndex*10000 + customOrder,
                                        width = "full",
                                    }
                                    CustomGroup.type = "group"
                                    CustomGroup.name = GetPhaseName(groupData,true)
                                    CustomGroup.childGroups = "select"
                                    CustomGroup.args = {}
                                    option_args[var] = CustomGroup
                                    CustomGroup_args = CustomGroup.args
                                    customOrder = customOrder + 1
                                else
                                    option_args[var] = nil
                                end
                                -- Adding other elements
                                for _,phaseVar in ipairs(groupData[optionType]) do
                                    local info = encData[phaseVar]
                                    if info then
                                        keyList[phaseVar] = nil
                                        if encounterCategories then
                                            InjectAdvancedItem(option_args,CustomGroup_args,phaseVar,info,optionType,customOrder)
                                        else
                                            InjectAdvancedItem(option_args,option_args,phaseVar,info,optionType,customOrder)
                                        end
                                        customOrder = customOrder + 1
                                    end
                                end
                            end
                        end
                    
                        -- Adding the remaining spells group
                        if customOrder > 1 then
                            local stuffToAdd = true
                            if next(keyList) == nil then stuffToAdd = false end
                            if stuffToAdd then
                                local var = format("%d_custom_group",(#grouping+1))
                                local CustomGroup_args
                                if encounterCategories then
                                    local CustomGroup = option_args[var] or {
                                        order = customOrder,
                                        width = "full",
                                    }
                                    CustomGroup.type = "group"
                                    CustomGroup.name = format("%s  |cffffffff%s|r",GENERAL_ICON,"Ungrouped")
                                    CustomGroup.childGroups = "select"
                                    CustomGroup.args = {}
                                    option_args[var] = CustomGroup
                                    CustomGroup_args = CustomGroup.args
                                    customOrder = customOrder + 1
                                else
                                    option_args[var] = nil
                                end
                                -- Adding the remaining spells
                                for var,info in pairs(keyList) do
                                    if encounterCategories then
                                        InjectAdvancedItem(option_args,CustomGroup_args,var,info,optionType,customOrder)
                                    else
                                        InjectAdvancedItem(option_args,option_args,var,info,optionType,customOrder)
                                    end
                                    customOrder = customOrder + 1
                                end
                            end
                        end                            
                    -- Custom ordering
                    elseif ordering and type(ordering) == "table" then
                        customOrdering = true
                        for orderKey,orderData in pairs(ordering) do
                            if orderKey == optionType then
                                for i,var in ipairs(orderData) do
                                    local info = encData[var]
                                    if info then
                                        keyList[var] = nil
                                        InjectAdvancedItem(option_args,option_args,var,info,optionType,customOrder)
                                        customOrder = customOrder + 1
                                    end
                                end
                            end
                        end
                        -- Adding the remaining spells
                        for var,info in pairs(keyList) do
                            InjectAdvancedItem(option_args,option_args,var,info,optionType,customOrder)
                            customOrder = customOrder + 1
                        end
                    end
                    if customOrder > 1 then
                        if customOrdering or not encounterCategories then
                            enc_args[optionType].childGroups = "select"
                        else
                            enc_args[optionType].childGroups = "tab"
                        end
                    else
                        
                        for var,info in pairs(override and optionInfo.list or encData) do
                            InjectAdvancedItem(option_args,option_args,var,info,optionType,info.order,data)
                        end
                    end
				end
			end
		end

		-- MODE SWAPPING
        SwapMode = function(newMode)
            db.global.OptMode = newMode
            for catkey in pairs(encs_args) do
				if encs_args[catkey].type == "group" then
					local cat_args = encs_args[catkey].args
					for key in pairs(cat_args) do
						local data = EDB[key]
						local enc_args = cat_args[key].args
                        cat_args[key]["key"] = key
						if db.global.OptMode == "AdvancedMode" then
							InjectAdvancedOptions(data,enc_args)
						elseif db.global.OptMode == "SimpleMode" then
							InjectSimpleOptions(data,enc_args)
                        end
					end
				end
			end
		end
        
		function handler:SimpleMode()
            SwapMode("SimpleMode")
		end

		function handler:AdvancedMode()
            SwapMode("AdvancedMode")
            
		end
        
		-- ADDITIONS/REMOVALS

		local function formatkey(str) return str:gsub(" ",""):lower() end

		local function AddEncounterOptions(data)
			-- Add a zone group if it doesn't exist. category supersedes zone
			local catkey = data.category and formatkey(data.category) or formatkey(data.zone)
			encs_args[catkey] = encs_args[catkey] or {type = "group", name = data.category or data.zone, args = {}}
			-- Update args pointer
			local cat_args = encs_args[catkey].args
			-- Exists, delete args
			if cat_args[data.key] then
				cat_args[data.key].args = {}
			else
                local name = data.name
                if addon:IsModuleTrash(data.key) then name = format("|cffdddddd%s|r",data.name) end
                if addon:IsModuleEvent(data.key) then name = format("|cff84e1fd%s|r",data.name) end
				-- Add the encounter group
                cat_args[data.key] = {
					type = "group",
					name = name,
					childGroups = "tab",
                    order = data.order,
					args = {
						version_header = AdvancedItems.VersionHeader,
					},
				}
			end
			-- Set pointer to the correct encounter group
			local enc_args = cat_args[data.key].args
            --cat_args[data.key]["key"] = data.key
            if db.global.OptMode == "AdvancedMode" then
				InjectAdvancedOptions(data,enc_args)
			else
				InjectSimpleOptions(data,enc_args)
			end
		end


		local function RemoveEncounterOptions(data)
			local catkey = data.category and formatkey(data.category) or formatkey(data.zone)
			encs_args[catkey].args[data.key] = nil
			-- Remove category if there are no more encounters in it
			if not next(encs_args[catkey].args) then
				encs_args[catkey] = nil
			end
		end

		function handler:OnRegisterEncounter(event,data) AddEncounterOptions(data); ACR:NotifyChange("DXE") end
		function handler:OnUnregisterEncounter(event,data) RemoveEncounterOptions(data); ACR:NotifyChange("DXE") end

		addon.RegisterCallback(handler,"OnRegisterEncounter")
		addon.RegisterCallback(handler,"OnUnregisterEncounter")

		function module:FillEncounters() for key,data in addon:IterateEDB() do AddEncounterOptions(data) end end
	end

	---------------------------------------------
	-- ALERTS
	---------------------------------------------

	do
		local Alerts = addon.Alerts

		local function SetNoRefresh(info,v,v2,v3,v4)
            local var = info[#info]
			if var:find("Color") then
				local c = Alerts.db.profile[var]
				c[1],c[2],c[3],c[4] = v,v2,v3,v4
			else Alerts.db.profile[var] = v end
		end

		local alerts_group = {
			type = "group",
			name = L.options["Alerts"],
			order = 200,
			handler = Alerts,
			childGroups = "tab",
			get = function(info)
				local var = info[#info]
				if var:find("Color") then return unpack(Alerts.db.profile[var])
				else return Alerts.db.profile[var] end
			end,
			set = function(info,v,v2,v3,v4)
				local var = info[#info]
				if var:find("Color") then
					local c = Alerts.db.profile[var]
					c[1],c[2],c[3],c[4] = v,v2,v3,v4
				else Alerts.db.profile[var] = v end
				Alerts:RefreshBars()
			end,
			args = {}
		}

		opts_args.alerts_group = alerts_group
		local alerts_args = alerts_group.args

		local bars_group = {
			type = "group",
			name = L.options["Bars"],
            childGroups = "tab",
			order = 100,
			args = {
				DisableDropdowns = {
					order = 100,
					type = "toggle",
					name = L.options["Disable Dropdowns"],
					desc = L.options["Anchor bars onto the center anchor only"],
					set = SetNoRefresh,
				},
				ShowBarBorder = {
					order = 105,
					type = "toggle",
					name = L.options["Show Bar Border"],
					desc = L.options["Display a border around bars"],
				},
                ShowSpark = {
					order = 110,
					type = "toggle",
					name = L.options["Show Spark"],
					desc = L.options["Enables display of spark of bars."],
				},
                StickyBars = {
					order = 115,
					type = "toggle",
					name = L.options["Allow Sticky Bars"],
					desc = L.options["A few cooldown timer bars are marked as 'sticky' which means they won't automatically fade after the timer runs out but rather wait until the spell in question is cast or it's no loger viable to show it (like a phase change).\n\nDisabling this feature will make these kinds of bars fade as usual."],
				},
                BarFillDirection = {
					order = 125,
					type = "select",
					name = L.options["Bar Fill Direction"],
					desc = L.options["The direction bars fill"],
					values = {
						FILL = L.options["Left to Right"],
						DEPLETE = L.options["Right to Left"],
					},
				},
                BorderInset = {
					order = 127,
					type = "range",
					name = L.options["Background Inset"],
					desc = L.options["How far in or out the background is from the edges."],
					min = -20,
					max = 20,
					step = 0.1,
				},
                AnimationTime = {
					order = 130,
					type = "range",
					name = L.options["Translation Time"],
					desc = L.options["How long the translate animation is."],
					min = 0,
					max = 3,
					step = 0.1,
				},
                FadeTime = {
					order = 135,
					type = "range",
					name = L.options["Fade Time"],
					desc = L.options["How long it takes for terminated bars to fade."],
					min = 0,
					max = 3,
					step = 0.1,
				},
			},
		}

		alerts_args.bars_group = bars_group
		local bars_args = bars_group.args
        
        local selectedPhrase = nil
        
        local function GetPhrases()
            local phrases = {}
            for k,phraseData in pairs(addon.Alerts.db.profile.Phrases) do
                if addon.Alerts.defaults.profile.Phrases[k] then 
                    phrases[k] = format("|cff00ff00%s|r",k)
                else
                    phrases[k] = format("|cff2fbbff%s|r",k)
                end
            end
            table.sort(phrases)
            
            if not selectedPhrase then selectedPhrase = next(phrases) end
            
            return phrases
        end
        
        
        local phraseMode = "select"
        local testAlertText = "Test Alert Text"
        
        local PhrasePattern_Select
        local PhrasePattern_Edit
        local PhrasePattern_New
        
        local coloring_group_args
        
        local function PhraseMode(mode)
            if mode == "select" then
                phraseMode = mode
                coloring_group_args["PhrasePattern"] = PhrasePattern_Select
            elseif mode == "edit" then
                phraseMode = mode
                coloring_group_args["PhrasePattern"] = PhrasePattern_Edit
            elseif mode == "new" then
                phraseMode = mode
                selectedPhrase = ""
                coloring_group_args["PhrasePattern"] = PhrasePattern_New
            end
        end
        
        PhrasePattern_Select = {
            type = "select",
            name = L.options["Phrase Pattern"],
            desc = L.options["Select a phrase pattern for coloring."],
            order = 123,
            values = GetPhrases,
            set = function(info,v) selectedPhrase = v end,
            get = function() return selectedPhrase end ,
        }
        PhrasePattern_Edit = {
            type = "input",
            name = L.options["Phrase Pattern"],
            desc = L.options["Edit a phrase pattern for coloring."],
            get = function() return selectedPhrase end,
            set = function(info,v)
                if v ~= selectedPhrase then
                    addon.Alerts.db.profile.Phrases[v] = addon.Alerts.db.profile.Phrases[selectedPhrase]
                    if not addon.Alerts.defaults.profile.Phrases[selectedPhrase] then 
                        addon.Alerts.db.profile.Phrases[selectedPhrase] = nil
                    end
                    selectedPhrase = v
                end
                PhraseMode("select")
            end,
            order = 123,
        }
        PhrasePattern_New = {
            type = "input",
            name = L.options["Phrase Pattern"],
            desc = L.options["Add a new phrase pattern for coloring."],
            get = function() return selectedPhrase end,
            set = function(info,v)
                if v == "" then return end
                if addon.Alerts.db.profile.Phrases[v] then 
                    addon:Print("Phrase |cffffff00"..v.."|r is already defined among |cff00ff00Phrase patterns.|r")
                else
                    addon.Alerts.db.profile.Phrases[v] = {}
                    addon.Alerts.db.profile.Phrases[v].color = "Off"
                end
                selectedPhrase = v
                PhraseMode("select")
            end,
            order = 123,
        }
        local selectedColorPreset
        local colorMode = "select"
        
        local ColorPresetName_Select

        
        local function UpdateColorLists()
            -- Phrase Color selection
            coloring_group_args["PhraseColor"] = {
                type = "select",
                name = L.options["Phrase Color"],
                desc = L.options["The color of selected phrase"],
                order = 130,
                disabled = function() return phraseMode ~= "select" end,
                values = GetColors(false),
                get = function(info)
                    if selectedPhrase and selectedPhrase ~= "" then
                        return addon.Alerts.db.profile.Phrases[selectedPhrase].color
                    end
                end,
                set = function(info,v)
                    addon.Alerts.db.profile.Phrases[selectedPhrase].color = v;
                end, 
            }
            
            -- Advanced Encounter Settings Color selections
            AdvancedItems.Options.alerts["color1"] = {
                type = "select",
                name = L.options["Main Color"],
                order = 100,
                values = GetColors(true),
            }
            AdvancedItems.Options.alerts["color2"] = {
                type = "select",
                name = L.options["Flash Color"],
                order = 200,
                values = GetColors(false),
                disabled = function(info)
                    local key,var = info[3],info[5]
                    return (not db.profile.Encounters[key][var].enabled) or (EDB[key].alerts[var].type == "simple")
                end,
            }
            SwapMode(db.global.OptMode)
            
            -- Pull Timer Color selection
            pull_timer_colors_args["PullColor1"] = {
                type = "select",
                name = L.options["Main Color"],
                order = 321,
                handler = Alerts,
                values = GetColors(true),
                disabled = function(info) return not db.profile.SpecialTimers["PullTimerEnabled"] end,
                get = function(info) return db.profile.SpecialTimers["PullColor1"] end,
                set = function(info,v) db.profile.SpecialTimers["PullColor1"] = v end, 
            }
            pull_timer_colors_args["PullColor2"] = {
                type = "select",
                name = L.options["Flash Color"],
                order = 322,
                handler = Alerts,
                values = GetColors(false),
                disabled = function(info) return not db.profile.SpecialTimers["PullTimerEnabled"] end,
                get = function(info) return db.profile.SpecialTimers["PullColor2"] end,
                set = function(info,v) db.profile.SpecialTimers["PullColor2"] = v end,
            }
            
            -- Break Timer Color selection
            break_timer_colors_args["BreakColor1"] = {
                type = "select",
                name = L.options["Main Color"],
                order = 333,
                handler = Alerts,
                values = GetColors(true),
                disabled = function(info) return not db.profile.SpecialTimers["BreakTimerEnabled"] end,
                get = function(info) return db.profile.SpecialTimers["BreakColor1"] end,
                set = function(info,v) db.profile.SpecialTimers["BreakColor1"] = v end, 
            }
            break_timer_colors_args["BreakColor2"] = {
                type = "select",
                name = L.options["Flash Color"],
                order = 334,
                handler = Alerts,
                values = GetColors(false),
                disabled = function(info) return not db.profile.SpecialTimers["BreakTimerEnabled"] end,
                get = function(info) return db.profile.SpecialTimers["BreakColor2"] end,
                set = function(info,v) db.profile.SpecialTimers["BreakColor2"] = v end,
            }
            
            -- LFG Timer Color selection
            lfg_timer_colors_args["LFGTimerMainColor"] = {
                type = "select",
                name = L.options["Main Color"],
                order = 333,
                handler = Alerts,
                values = GetColors(true),
                disabled = function(info) return not addon.Alerts.db.profile.LFGTimerEnabled end,
            }
            lfg_timer_colors_args["LFGTimerFlashColor"] = {
                type = "select",
                name = L.options["Flash Color"],
                order = 334,
                handler = Alerts,
                values = GetColors(false),
                disabled = function(info) return not addon.Alerts.db.profile.LFGTimerEnabled end,
            }
        end
        
        
        local function ColorMode(mode)
            if mode == "select" then
                coloring_group_args["ColorPresetName"] = {
                    type = "select",
                    name = L.options["Color Preset"],
                    desc = L.options["The color preset"],
                    order = 22,
                    -- values = GetColors(true,true),
                    values = function()
                        local colors = GetColors(true,true)
                        if not selectedColorPreset then selectedColorPreset = next(colors) end
                        return colors
                    end,
                    disabled = function() GetColors(true);return false end,
                    get = function(info) return selectedColorPreset end,
                    set = function(info,v) selectedColorPreset = v end, 
                }
                colorMode = mode
            elseif mode == "new" then
                selectedColorPreset = ""
                coloring_group_args["ColorPresetName"] = {
                    type = "input",
                    name = L.options["Color Preset"],
                    desc = L.options["The name of a new color preset"],
                    order = 22,
                    get = function(info) return selectedColorPreset end,
                    set = function(info,v) 
                        v = string.upper(v)
                        if v:find("^%w+$") then
                            if not addon.db.profile.Colors[v] then
                                addon.db.profile.Colors[v] = {
                                    r = 1, g = 1, b = 1,
                                    sr = 1, sg = 1, sb = 1
                                }
                                selectedColorPreset = v
                                ColorMode("select")
                                UpdateColorLists()
                            end
                        else
                            addon:Print(format("|cffffff00%s|r must only contain letters!",v))
                        end
                    end
                }
                colorMode = mode
            end
        end
            
        local coloring_group = {
            type = "group",
			name = L.options["Coloring"],
			order = 560,
			args = {
                -- Color presets
                color_presets_header = {
					type = "header",
					name = L.options["Color presets"].."\n",
					order = 21,
				},
                ColorPresetNew = {
                    type = "execute",
                    name = L.options["New"],
                    desc = L.options["Create a new color preset."],
                    order = 22,
                    width = "half",
                    disabled = function() return colorMode == "new" end,
                    func = function() ColorMode("new") end,
                },
                ColorPresetRemove = {
                    type = "execute",
                    name = L.options["Remove"],
                    desc = L.options["Removes the selected color preset."],
                    order = 23,
                    width = "half",
                    disabled = function() return colorMode == "new" or addon.defaults.profile.Colors[selectedColorPreset] end,
                    func = function()
                        addon.db.profile.Colors[selectedColorPreset] = nil
                        selectedColorPreset = nil
                        ColorMode("select")
                        UpdateColorLists()
                    end,
                },
                color_presets_blank = genblank(52),
                ColorPresetColor = {
                    type = "color",
                    name = L.options["Preset Color"],
                    desc = L.options["The main color of the selected preset."],
                    order = 53,
                    get = function() 
                        if selectedColorPreset and selectedColorPreset ~= "" then
                            local c = addon.db.profile.Colors[selectedColorPreset]
                            return c.r, c.g, c.b
                        else
                            return 1, 1, 1
                        end
                    end,
                    set = function(info, r, g, b, a)
                        if selectedColorPreset and selectedColorPreset ~= "" then
                            local c = addon.db.profile.Colors[selectedColorPreset]
                            c.r, c.g, c.b = r, g, b
                            addon.db.profile.Colors[selectedColorPreset] = c
                            ColorMode(colorMode)
                            UpdateColorLists()
                        end
                    end,
                },
                ColorPresetColorReset = {
                    type = "execute",
                    name = L.options["Reset"],
                    desc = L.options["Reset the main color of the selected preset to its default value."],
                    order = 54,
                    width = "half",
                    disabled = function() return not addon.defaults.profile.Colors[selectedColorPreset] end,
                    func = function() 
                        local c = addon.defaults.profile.Colors[selectedColorPreset]
                        addon.db.profile.Colors[selectedColorPreset].r = c.r
                        addon.db.profile.Colors[selectedColorPreset].g = c.g
                        addon.db.profile.Colors[selectedColorPreset].b = c.b
                        ColorMode(colorMode)
                    end,
                },
                color_presets_blank2 = genblank(63),                
                ColorPresetSparkColor = {
                    type = "color",
                    name = L.options["Spark Color"],
                    desc = L.options["The spark color of the selected preset."],
                    order = 64,
                    get = function() 
                        if selectedColorPreset and selectedColorPreset ~= "" then
                            local c = addon.db.profile.Colors[selectedColorPreset]
                            return c.sr, c.sg, c.sb
                        else
                            return 1, 1, 1
                        end
                    end,
                    set = function(info, r, g, b, a)
                        if selectedColorPreset and selectedColorPreset ~= "" then
                            local c = addon.db.profile.Colors[selectedColorPreset]
                            c.sr, c.sg, c.sb = r, g, b
                            addon.db.profile.Colors[selectedColorPreset] = c
                            ColorMode(colorMode)
                            UpdateColorLists()
                        end
                    end,
                },
                ColorPresetSparkColorReset = {
                    type = "execute",
                    name = L.options["Reset"],
                    desc = L.options["Reset the spark color of the selected preset to its default value."],
                    order = 65,
                    width = "half",
                    disabled = function() return not addon.defaults.profile.Colors[selectedColorPreset] end,
                    func = function()
                        local c = addon.defaults.profile.Colors[selectedColorPreset]
                        addon.db.profile.Colors[selectedColorPreset].sr = c.sr
                        addon.db.profile.Colors[selectedColorPreset].sg = c.sg
                        addon.db.profile.Colors[selectedColorPreset].sb = c.sb
                        ColorMode(colorMode)
                    end,
                },
                -- Phrase Coloring
                phrase_coloring_header = {
					type = "header",
					name = L.options["Phrase coloring"].."\n",
					order = 121,
				},
                phrase_coloring_desc = {
                    type = "description",
                    name = L.options["This feature allows you to specify which words, phrases or regular expressions will be colored in a specified way not taking into account module settings."].."\n",
                    order = 122,
                },
                PhrasePattern = nil,
                PhraseColor = {
                    type = "select",
                    name = L.options["Phrase Color"],
                    desc = L.options["The color of selected phrase"],
                    order = 130,
                    disabled = function() return phraseMode ~= "select" end,
                    values = GetColors(false),
                    get = function(info)
                        if selectedPhrase and selectedPhrase ~= "" and addon.db.profile.Colors[addon.Alerts.db.profile.Phrases[selectedPhrase].color] then
                            return addon.Alerts.db.profile.Phrases[selectedPhrase].color
                        else
                            return "Off"
                        end
                    end,
                    set = function(info,v)
                        addon.Alerts.db.profile.Phrases[selectedPhrase].color = v;
                    end, 
                },
                PhraseNote = {
                    type = "input",
                    name = L.options["Phrase Note"],
                    desc = "Just a little text that helps you remember what was the pattern useful for if you can't figure it out by the pattern itself.",
                    order = 135,
                    get = function(info) 
                        if selectedPhrase and selectedPhrase ~= "" then
                            return addon.Alerts.db.profile.Phrases[selectedPhrase].note
                        end
                    end,
                    set = function(info,v) 
                        if v == "" then
                            addon.Alerts.db.profile.Phrases[selectedPhrase].note = nil
                        else
                            addon.Alerts.db.profile.Phrases[selectedPhrase].note = v
                        end
                    end,
                },
                coloring_blank = genblank(136),
                PhraseEdit = {
                    type = "execute",
                    name = L.options["Edit"],
                    disabled = function() return not selectedPhrase or addon.Alerts.defaults.profile.Phrases[selectedPhrase] or phraseMode ~= "select" end,
                    order = 141,
                    width = "half",
                    func = function() 
                        PhraseMode("edit")
                    end,
                },
                PhraseRemove = {
                    type = "execute",
                    name = L.options["Remove"],
                    disabled = function() return phraseMode ~= "select" or not selectedPhrase or addon.Alerts.defaults.profile.Phrases[selectedPhrase] end,
                    order = 142,
                    width = "half",
                    func = function() 
                        if not addon.Alerts.defaults.profile.Phrases[selectedPhrase] then 
                            addon.Alerts.db.profile.Phrases[selectedPhrase] = nil
                            selectedPhrase = nil
                        end
                    end,
                    confirm = true,
                    confirmText = format("Are you sure you want to remove %s?",selectedPhrase or "this pattern"),
                },
                PhraseNew = {
                    type = "execute",
                    name = L.options["New"],
                    disabled = function() return phraseMode ~= "select" end,
                    order = 137,
                    func = function() 
                        if phraseMode == "select" then
                            PhraseMode("new")
                        end
                    end,
                },
                coloring_blank2 = genblank(140),
                PhraseResetColor = {
                    type = "execute",
                    name = L.options["Reset"],
                    desc = L.options["Resets the selected phrase coloring setttings to its default value."],
                    width = "half",
                    disabled = function() return not selectedPhrase or not addon.Alerts.defaults.profile.Phrases[selectedPhrase] or addon.Alerts.db.profile.Phrases[selectedPhrase].color == addon.Alerts.defaults.profile.Phrases[selectedPhrase].color end,
                    order = 138,
                    func = function(info)
                        addon.Alerts.db.profile.Phrases[selectedPhrase].color = addon.Alerts.defaults.profile.Phrases[selectedPhrase].color
                    end,
                },
                PhraseResetAllColors = {
                    type = "execute",
                    name = L.options["Reset All"],
                    desc = L.options["Resets all built-in phrase coloring setttings to their default values."],
                    width = "half",
                    order = 139,
                    func = function(info)
                        for phrase,phraseData in pairs(addon.Alerts.db.profile.Phrases) do
                            if addon.Alerts.defaults.profile.Phrases[phrase] then
                                addon.Alerts.db.profile.Phrases[phrase].color = addon.Alerts.defaults.profile.Phrases[phrase].color
                            end
                        end
                    end,
                    confirm = true,
                },
                coloring_test_header = {
					type = "header",
					name = L.options["Coloring Test"].."\n",
					order = 145,
				},
                coloring_test_desc = {
                    type = "description",
                    name = L.options["You can test your pattern coloring settings by changing the test alert text and using the 'Show test alert' button below."].."\n",
                    order = 146,
                },
                coloring_test_text = {
                    type = "input",
                    name = L.options["Test Alert Text"],
                    width = "full",
                    order = 147,
                    get = function() return testAlertText end,
                    set = function(info,v) if v ~= "" then testAlertText = v end end,
                },
                coloring_test_fire = {
                    type = "execute",
                    name = L.options["Show Test Alert"],
                    order = 149,
                    func = function() 
                        addon.Alerts:CenterPopup("testAlertwarn",testAlertText, 5, 5, "None", selectedColorPreset, "Off", false, addon.ST[491], false)
                    end
                },
            },
        }
        
        alerts_args.coloring_group = coloring_group
        coloring_group_args = coloring_group.args
        
        PhraseMode("select")
        ColorMode("select")
        
		local general_group = {
			type = "group",
			name = L.options["General"],
			order = 100,
			args = {

			},
		}
        
        
        --[[bars_args.bar_anchors = {
            type = "group",
            inline = true,
			name = "",
            childGroups = "tab",
			order = 140,
			args = {

			},
        }]]
      
        --local bar_anchors_args = bars_args.bar_anchors.args
        
        local top_group = {
			type = "group",
			name = L.options["|cffffff00Top Anchored Bars|r"],
			order = 145,
            inline = false,
			disabled = function() return Alerts.db.profile.DisableDropdowns end,
			args = {
				top_bars_desc = {
					type = "header",
					name = L.options["|cff00ff00Bar settings|r"].."\n",
					order = 1,
				},
				TopScale = {
					type = "range",
					name = L.options["Bar Scale"],
					desc = L.options["Adjust the size of top bars"],
                    order = 2,
					min = 0.5,
					max = 3.5,
					step = 0.05,
				},
				TopBarWidth = {
					type = "range",
					name = L.options["Bar Width"],
					desc = L.options["Adjust the width of top bars"],
                    order = 3,
					min = 10,
					max = 2000,
					step = 1,
				},
                TopBarHeight = {
					type = "range",
					name = L.options["Bar Height"],
					desc = L.options["Adjust the height of top bars"],
                    order = 4,
					min = 5,
					max = 200,
					step = 1,
				},
                TopAlpha = {
					type = "range",
					name = L.options["Bar Alpha"],
					desc = L.options["Adjust the transparency of top bars"],
					order = 5,
					min = 0.1,
					max = 1,
					step = 0.05,
				},
                TopBarSpacing = {
					order = 6,
					type = "range",
					name = L.options["Bar Spacing"],
					desc = L.options["How far apart the bars are spaced vertically"],
					min = -20,
					max = 300,
					step = 1,
				},
				TopGrowth = {
					type = "select",
					name = L.options["Bar Growth"],
					desc = L.options["The direction top bars grow"],
                    order = 7,
					values = {DOWN = L.options["Down"], UP = L.options["Up"]},
				},
                TopSort = {
					type = "select",
					name = L.options["Bar Sort Method"],
					desc = L.options["The sort method for top bars"],
                    order = 8,
					values = {HIGH_FIRST = L.options["High First"], LOW_FIRST = L.options["Low First"]},
				},
                TopClickThrough = {
					type = "toggle",
					name = L.options["Make bars click-through"],
                    order = 9,
				},
                --------------------- Text settings --------------------
                top_text_desc = {
					type = "header",
					name = L.options["|cff00ff00Text settings|r"].."\n",
					order = 10,
				},
                TopTextWidthBonus = {
					type = "range",
					name = L.options["Text Width Bonus"],
					desc = L.options["Bonus to the bar width given to the text for top bars"],
					order = 11,
					min = -1000,
					max = 1000,
					step = 1,
				},
                TopTextHeightBonusMult = {
                    type = "range",
					name = L.options["Text Height Multiplier"],
					desc = L.options["Bonus to the bar height multiplied by font size given to the text for top bars"],
					order = 12,
					min = 1,
					max = 4,
					step = 1,
                },
                TopTextXOffset = {
                    type = "range",
                    name = L.options["Horizontal Offset"],
                    desc = L.options["The horizontal position of the bar text"],
                    order = 13,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                TopTextYOffset = {
                    type = "range",
                    name = L.options["Vertical Offset"],
                    desc = L.options["The vertical position of the bar text"],
                    order = 14,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                TopBarFontSize = {
                    type = "range",
                    name = L.options["Font Size"],
                    desc = L.options["Select a font size used on bar text"],
                    order = 15,
                    min = 8,
                    max = 20,
                    step = 1,
                },
                TopTextAlpha = {
                    type = "range",
                    name = L.options["Alpha"],
                    desc = L.options["Adjust the transparency of bar text"],
                    order = 16,
                    min = 0.1,
                    max = 1,
                    step = 0.05,
                },
                TopBarTextJustification = {
                    type = "select",
                    name = L.options["Justification"],
                    desc = L.options["Select a text justification."],
                    order = 17,
                    values = {
                        LEFT = L.options["Left"],
                        CENTER = L.options["Center"],
                        RIGHT = L.options["Right"],
                    },
                },
                TopBarFontColor = {
                    type = "color",
                    name = L.options["Font Color"],
                    desc = L.options["Set a font color used on bar text"],
                    order = 18,
                },
                --------------------- Tímer settings --------------------
                top_timer_desc = {
					type = "header",
					name = L.options["|cff00ff00Timer settings|r"].."\n",
					order = 21,
				},
                TopTimerJustification = {
                    type = "select",
                    name = L.options["Justification"],
                    desc = L.options["Select the timer justification."],
                    order = 22,
                    values = {
                        LEFT = L.options["Left"],
                        RIGHT = L.options["Right"],
                    },
                },
                TopTimerXOffset = {
                    type = "range",
                    name = L.options["Horizontal Offset"],
                    desc = L.options["The horizontal position of the timer text"],
                    order = 23,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                TopTimerYOffset = {
                    type = "range",
                    name = L.options["Vertical Offset"],
                    desc = L.options["The vertical position of the timer text"],
                    order = 24,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                TopTimerAlpha = {
                    type = "range",
                    name = L.options["Alpha"],
                    desc = L.options["Adjust the transparency of timer text"],
                    order = 25,
                    min = 0.1,
                    max = 1,
                    step = 0.05,
                },
                TopShowDecimal = {
                    type = "toggle",
                    name = L.options["Show decimal"],
                    desc = L.options["Enables display of decimal numbers for timer."],
                    order = 26,
                },
                TopDecimalPlaces = {
                    type = "range",
                    name = L.options["Number of decimal places"],
                    desc = L.options["Sets the number of decimal place for the timer."],
                    order = 27,
                    min = 1,
                    max = 3,
                    step = 1,
                    disabled = function() return not Alerts.db.profile.TopShowDecimal end,
                },
                TopDecimalYOffset = {
                    type = "range",
                    name = L.options["Decimal Vertical Offset"],
                    desc = L.options["The vertical position of a timer's decimal text in relation to its second's text"],
                    order = 28,
                    min = -10,
                    max = 10,
                    step = 1,
                    disabled = function() return not Alerts.db.profile.TopShowDecimal end,
                },
                TopScaleTimerWithBarHeight = {
                    type = "toggle",
                    --width = "full",
                    name = L.options["Scale with bar height"],
                    desc = L.options["Automatically resizes timer font sizes when the bar height is adjusted"],
                    order = 29,
                },
                TopTimerSecondsFontSize = {
                    type = "range",
                    name = L.options["Seconds' Font Size"],
                    desc = L.options["Select a font size used on a timer's seconds' text"],
                    order = 30,
                    min = 8,
                    max = 30,
                    step = 1,
                    disabled = function() return Alerts.db.profile.TopScaleTimerWithBarHeight end,
                },
                TopTimerDecimalFontSize = {
                    type = "range",
                    name = L.options["Decimal Font Size"],
                    desc = L.options["Select a font size used on a timer's decimal text"],
                    order = 31,
                    min = 8,
                    max = 24,
                    step = 1,
                    disabled = function() return Alerts.db.profile.TopScaleTimerWithBarHeight end,
                },
                TopTimerFontColor = {
                    type = "color",
                    name = L.options["Font Color"],
                    desc = L.options["Set a font color used on bar timers"],
                    order = 32,
                },
                --------------------- Icon settings --------------------
                top_icon_desc = {
					type = "header",
					name = L.options["|cff00ff00Icon settings|r"].."\n",
					order = 41,
				},
				TopShowLeftIcon = {
					type = "toggle",
					name = L.options["Show Left Icon"],
					desc = L.options["Shows a spell icon on the left side of the bar"],
                    order = 42,
                },
				TopShowRightIcon = {
					type = "toggle",
					name = L.options["Show Right Icon"],
					desc = L.options["Shows a spell icon on the right side of the bar"],
                    order = 43,
				},
				TopShowIconBorder = {
					type = "toggle",
					name = L.options["Show Icon Border"],
					desc = L.options["Display a border around icons"],
                    order = 44,
				},
				blank = genblank(45),
				TopIconXOffset = {
					type = "range",
					name = L.options["Icon X Offset"],
					desc = L.options["Horizontal position of the icon"],
					order = 46,
					min = -200,
					max = 200,
					step = 0.1,
				},
				TopIconYOffset = {
					type = "range",
					name = L.options["Icon Y Offset"],
					desc = L.options["Vertical position of the icon"],
					order = 47,
					min = -200,
					max = 200,
					step = 0.1,
				},
				TopSetIconToBarHeight = {
					type = "toggle",
					order = 48,
					width = "full",
					name = L.options["Scale with bar height"],
					desc = L.options["Automatically resizes the icon when the bar height is adjusted"],
				},
				TopIconSize = {
					type = "range",
					name = L.options["Icon Size"],
					desc = L.options["How big the icon is in width and height"],
					order = 49,
					min = 10,
					max = 100,
					step = 1,
					disabled = function() return Alerts.db.profile.TopSetIconToBarHeight end,
				},
			},
		}
		bars_args.top_group = top_group
        
        local center_group = {
			type = "group",
			name = L.options["|cffffff00Center Anchored Bars|r"],
			order = 150,
            inline = false,
			args = {
                --------------------- Bar settings --------------------
				center_bars_desc = {
					type = "header",
					name = L.options["|cff00ff00Bar settings|r"].."\n",
					order = 1,
				},
				CenterScale = {
					type = "range",
					name = L.options["Bar Scale"],
					desc = L.options["Adjust the size of center bars"],
					order = 2,
					min = 0.5,
					max = 3.5,
					step = 0.05,
				},
				CenterBarWidth = {
					type = "range",
					name = L.options["Bar Width"],
					desc = L.options["Adjust the width of center bars"],
					order = 3,
					min = 10,
					max = 2000,
					step = 1,
				},
                CenterBarHeight = {
					type = "range",
					name = L.options["Bar Height"],
					desc = L.options["Adjust the height of center bars"],
					order = 4,
					min = 5,
					max = 200,
					step = 1,
				},
                CenterAlpha = {
					type = "range",
					name = L.options["Bar Alpha"],
					desc = L.options["Adjust the transparency of center bars"],
					order = 5,
					min = 0.1,
					max = 1,
					step = 0.05,
				},
                CenterBarSpacing = {
					order = 6,
					type = "range",
					name = L.options["Bar Spacing"],
					desc = L.options["How far apart the bars are spaced vertically"],
					min = -20,
					max = 300,
					step = 1,
				},
				CenterGrowth = {
					type = "select",
					name = L.options["Bar Growth"],
					desc = L.options["The direction center bars grow"],
					order = 7,
					values = {DOWN = L.options["Down"], UP = L.options["Up"]},
				},
                CenterSort = {
					type = "select",
					name = L.options["Bar Sort Method"],
					desc = L.options["The sort method for center bars"],
                    order = 8,
					values = {HIGH_FIRST = L.options["High First"], LOW_FIRST = L.options["Low First"]},
				},
                CenterClickThrough = {
					type = "toggle",
					order = 9,
					name = L.options["Make bars click-through"],
				},
                --------------------- Text settings --------------------
                center_text_desc = {
					type = "header",
					name = L.options["|cff00ff00Text settings|r"].."\n",
					order = 10,
				},
                CenterTextWidthBonus = {
					type = "range",
					name = L.options["Text Width Bonus"],
					desc = L.options["Bonus to the bar width given to the text for center bars"],
					order = 11,
					min = -1000,
					max = 1000,
					step = 1,
				},
                CenterTextHeightBonusMult = {
                    type = "range",
					name = L.options["Text Height Multiplier"],
					desc = L.options["Bonus to the bar height multiplied by font size given to the text for center bars"],
					order = 12,
					min = 1,
					max = 4,
					step = 1,
                },
                CenterTextXOffset = {
                    type = "range",
                    name = L.options["Horizontal Offset"],
                    desc = L.options["The horizontal position of the bar text"],
                    order = 13,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                CenterTextYOffset = {
                    type = "range",
                    name = L.options["Vertical Offset"],
                    desc = L.options["The vertical position of the bar text"],
                    order = 14,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                CenterBarFontSize = {
                    type = "range",
                    name = L.options["Font Size"],
                    desc = L.options["Select a font size used on bar text"],
                    order = 15,
                    min = 8,
                    max = 20,
                    step = 1,
                },
                CenterTextAlpha = {
                    type = "range",
                    name = L.options["Alpha"],
                    desc = L.options["Adjust the transparency of bar text"],
                    order = 16,
                    min = 0.1,
                    max = 1,
                    step = 0.05,
                },
                CenterBarTextJustification = {
                    type = "select",
                    name = L.options["Justification"],
                    desc = L.options["Select a text justification."],
                    order = 17,
                    values = {
                        LEFT = L.options["Left"],
                        CENTER = L.options["Center"],
                        RIGHT = L.options["Right"],
                    },
                },
                CenterBarFontColor = {
                    type = "color",
                    name = L.options["Font Color"],
                    desc = L.options["Set a font color used on bar text"],
                    order = 18,
                },
                --------------------- Tímer settings --------------------
                center_timer_desc = {
					type = "header",
					name = L.options["|cff00ff00Timer settings|r"].."\n",
					order = 19,
				},
                CenterTimerXOffset = {
                    type = "range",
                    name = L.options["Horizontal Offset"],
                    desc = L.options["The horizontal position of the timer text"],
                    order = 22,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                CenterTimerYOffset = {
                    type = "range",
                    name = L.options["Vertical Offset"],
                    desc = L.options["The vertical position of the timer text"],
                    order = 23,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                CenterTimerAlpha = {
                    type = "range",
                    name = L.options["Alpha"],
                    desc = L.options["Adjust the transparency of timer text"],
                    order = 24,
                    min = 0.1,
                    max = 1,
                    step = 0.05,
                },
                CenterShowDecimal = {
                    type = "toggle",
                    name = L.options["Show decimal"],
                    desc = L.options["Enables display of decimal numbers for timer."],
                    order = 25,
                },
                CenterDecimalPlaces = {
                    type = "range",
                    name = L.options["Number of decimal places"],
                    desc = L.options["Sets the number of decimal place for the timer."],
                    order = 26,
                    min = 1,
                    max = 3,
                    step = 1,
                    disabled = function() return not Alerts.db.profile.CenterShowDecimal end,
                },
                CenterDecimalYOffset = {
                    type = "range",
                    name = L.options["Decimal Vertical Offset"],
                    desc = L.options["The vertical position of a timer's decimal text in relation to its second's text"],
                    order = 27,
                    min = -10,
                    max = 10,
                    step = 1,
                    disabled = function() return not Alerts.db.profile.CenterShowDecimal end,
                },
                CenterScaleTimerWithBarHeight = {
                    type = "toggle",
                    --width = "full",
                    name = L.options["Scale with bar height"],
                    desc = L.options["Automatically resizes timer font sizes when the bar height is adjusted"],
                    order = 28,
                },
                CenterTimerSecondsFontSize = {
                    type = "range",
                    name = L.options["Seconds' Font Size"],
                    desc = L.options["Select a font size used on a timer's seconds' text"],
                    order = 29,
                    min = 8,
                    max = 30,
                    step = 1,
                    disabled = function() return Alerts.db.profile.CenterScaleTimerWithBarHeight end,
                },
                CenterTimerDecimalFontSize = {
                    type = "range",
                    name = L.options["Decimal Font Size"],
                    desc = L.options["Select a font size used on a timer's decimal text"],
                    order = 30,
                    min = 8,
                    max = 24,
                    step = 1,
                    disabled = function() return Alerts.db.profile.CenterScaleTimerWithBarHeight end,
                },
                CenterTimerFontColor = {
                    type = "color",
                    name = L.options["Font Color"],
                    desc = L.options["Set a font color used on bar timers"],
                    order = 31,
                },
                --------------------- Icon settings --------------------
                center_icon_desc = {
					type = "header",
					name = L.options["|cff00ff00Icon settings|r"].."\n",
					order = 41,
				},
				CenterShowLeftIcon = {
					type = "toggle",
					name = L.options["Show Left Icon"],
					desc = L.options["Shows a spell icon on the left side of the bar"],
                    order = 42,
                },
				CenterShowRightIcon = {
					type = "toggle",
					name = L.options["Show Right Icon"],
					desc = L.options["Shows a spell icon on the right side of the bar"],
                    order = 43,
				},
				CenterShowIconBorder = {
					type = "toggle",
					name = L.options["Show Icon Border"],
					desc = L.options["Display a border around icons"],
                    order = 44,
				},
				blank = genblank(45),
				CenterIconXOffset = {
					type = "range",
					name = L.options["Icon X Offset"],
					desc = L.options["Horizontal position of the icon"],
					order = 46,
					min = -200,
					max = 200,
					step = 0.1,
				},
				CenterIconYOffset = {
					type = "range",
					name = L.options["Icon Y Offset"],
					desc = L.options["Vertical position of the icon"],
					order = 47,
					min = -200,
					max = 200,
					step = 0.1,
				},
				CenterSetIconToBarHeight = {
					type = "toggle",
					order = 48,
					width = "full",
					name = L.options["Scale with bar height"],
					desc = L.options["Automatically resizes the icon when the bar height is adjusted"],
				},
				CenterIconSize = {
					type = "range",
					name = L.options["Icon Size"],
					desc = L.options["How big the icon is in width and height"],
					order = 49,
					min = 10,
					max = 100,
					step = 1,
					disabled = function() return Alerts.db.profile.CenterSetIconToBarHeight end,
				},
			},
		}
		bars_args.center_group = center_group
        
        local emphasis_group = {
			type = "group",
			name = L.options["|cffffff00Emphasis Anchored Bars|r"],
			order = 155,
            inline = false,
			args = {
                EmphasisAnchor = {
					type = "toggle",
					order = 100,
					name = L.options["Enable Emphasis Anchor"],
					set = SetNoRefresh,
                    width = "double",
				},
                emphasis_bars = {
					type = "group",
					name = L.options["Emphasis Anchor"],
					order = 200,
					inline = true,
					disabled = function() addon:UpdateLockedFrames();return not Alerts.db.profile.EmphasisAnchor end,
					args = {
                        --------------------- Bar settings --------------------
                        emphasis_bars_desc = {
                            type = "header",
                            name = L.options["|cff00ff00Bar settings|r"].."\n",
                            order = 1,
                        },
                        EmphasisScale = {
                            type = "range",
                            name = L.options["Bar Scale"],
                            desc = L.options["Adjust the size of emphasis bars"],
                            order = 2,
                            min = 0.5,
                            max = 3.5,
                            step = 0.05,
                        },
                        EmphasisBarWidth = {
                            type = "range",
                            name = L.options["Bar Width"],
                            desc = L.options["Adjust the width of emphasis bars"],
                            order = 3,
                            min = 10,
                            max = 2000,
                            step = 1,
                        },
                        EmphasisBarHeight = {
                            type = "range",
                            name = L.options["Bar Height"],
                            desc = L.options["Adjust the height of emphasis bars"],
                            order = 4,
                            min = 5,
                            max = 200,
                            step = 1,
                        },
                        EmphasisAlpha = {
                            type = "range",
                            name = L.options["Bar Alpha"],
                            desc = L.options["Adjust the transparency of emphasis bars"],
                            order = 5,
                            min = 0.1,
                            max = 1,
                            step = 0.05,
                        },
                        EmphasisBarSpacing = {
                            order = 6,
                            type = "range",
                            name = L.options["Bar Spacing"],
                            desc = L.options["How far apart the bars are spaced vertically"],
                            min = -20,
                            max = 300,
                            step = 1,
                        },
                        EmphasisGrowth = {
                            type = "select",
                            name = L.options["Bar Growth"],
                            desc = L.options["The direction emphasis bars grow"],
                            order = 7,
                            values = {DOWN = L.options["Down"], UP = L.options["Up"]},
                        },
                        EmphasisSort = {
                            type = "select",
                            name = L.options["Bar Sort Method"],
                            desc = L.options["The sort method for emphasis bars"],
                            order = 8,
                            values = {HIGH_FIRST = L.options["High First"], LOW_FIRST = L.options["Low First"]},
                        },
                        EmphasisClickThrough = {
                            type = "toggle",
                            order = 9,
                            name = L.options["Make bars click-through"],
                        },
                        --------------------- Text settings --------------------
                        emphasis_text_desc = {
                            type = "header",
                            name = L.options["|cff00ff00Text settings|r"].."\n",
                            order = 10,
                        },
                        EphasisTextWidthBonus = {
                            type = "range",
                            name = L.options["Text Width Bonus"],
                            desc = L.options["Bonus to the bar width given to the bar text"],
                            order = 11,
                            min = -1000,
                            max = 1000,
                            step = 1,
                        },
                        EphasisTextHeightBonusMult = {
                            type = "range",
                            name = L.options["Text Height Multiplier"],
                            desc = L.options["Bonus to the bar height multiplied by font size given to the bar text"],
                            order = 12,
                            min = 1,
                            max = 4,
                            step = 1,
                        },
                        EmphasisTextXOffset = {
							type = "range",
							name = L.options["Horizontal Offset"],
							desc = L.options["The horizontal position of the bar text"],
							order = 13,
							min = -1000,
							max = 1000,
							step = 1,
						},
						EmphasisTextYOffset = {
							type = "range",
							name = L.options["Vertical Offset"],
							desc = L.options["The vertical position of the bar text"],
							order = 14,
							min = -1000,
							max = 1000,
							step = 1,
						},
						EmphasisBarFontSize = {
							type = "range",
							name = L.options["Font Size"],
							desc = L.options["Select a font size used on bar text"],
							order = 15,
							min = 8,
							max = 20,
							step = 1,
						},
						EmphasisTextAlpha = {
							type = "range",
							name = L.options["Alpha"],
							desc = L.options["Adjust the transparency of bar text"],
							order = 16,
							min = 0.1,
							max = 1,
							step = 0.05,
						},
                        EmphasisBarTextJustification = {
							type = "select",
							name = L.options["Justification"],
							desc = L.options["Select a text justification."],
							order = 17,
							values = {
								LEFT = L.options["Left"],
								CENTER = L.options["Center"],
								RIGHT = L.options["Right"],
							},
						},
						EmphasisBarFontColor = {
							type = "color",
							name = L.options["Font Color"],
							desc = L.options["Set a font color used on bar text"],
                            order = 18,
						},
                        --------------------- Tímer settings --------------------
                        emphasis_timer_desc = {
                            type = "header",
                            name = L.options["|cff00ff00Timer settings|r"].."\n",
                            order = 21,
                        },
                        EmphasisTimerXOffset = {
                            type = "range",
                            name = L.options["Horizontal Offset"],
                            desc = L.options["The horizontal position of the timer text"],
                            order = 22,
                            min = -1000,
                            max = 1000,
                            step = 1,
                        },
                        EmphasisTimerYOffset = {
                            type = "range",
                            name = L.options["Vertical Offset"],
                            desc = L.options["The vertical position of the timer text"],
                            order = 23,
                            min = -1000,
                            max = 1000,
                            step = 1,
                        },
                        EmphasisTimerAlpha = {
                            type = "range",
                            name = L.options["Alpha"],
                            desc = L.options["Adjust the transparency of timer text"],
                            order = 24,
                            min = 0.1,
                            max = 1,
                            step = 0.05,
                        },
                        EmphasisShowDecimal = {
                            type = "toggle",
                            name = L.options["Show decimal"],
                            desc = L.options["Enables display of decimal numbers for timer."],
                            order = 25,
                        },
                        EmphasisDecimalPlaces = {
                            type = "range",
                            name = L.options["Number of decimal places"],
                            desc = L.options["Sets the number of decimal place for the timer."],
                            order = 26,
                            min = 1,
                            max = 3,
                            step = 1,
                            disabled = function() return not Alerts.db.profile.EmphasisShowDecimal end,
                        },
                        EmphasisDecimalYOffset = {
                            type = "range",
                            name = L.options["Decimal Vertical Offset"],
                            desc = L.options["The vertical position of a timer's decimal text in relation to its second's text"],
                            order = 27,
                            min = -10,
                            max = 10,
                            step = 1,
                            disabled = function() return not Alerts.db.profile.EmphasisShowDecimal end,
                        },
                        EmphasisScaleTimerWithBarHeight = {
                            type = "toggle",
                            --width = "full",
                            name = L.options["Scale with bar height"],
                            desc = L.options["Automatically resizes timer font sizes when the bar height is adjusted"],
                            order = 28,
                        },
                        EmphasisTimerSecondsFontSize = {
                            type = "range",
                            name = L.options["Seconds' Font Size"],
                            desc = L.options["Select a font size used on a timer's seconds' text"],
                            order = 29,
                            min = 8,
                            max = 30,
                            step = 1,
                            disabled = function() return Alerts.db.profile.EmphasisScaleTimerWithBarHeight end,
                        },
                        EmphasisTimerDecimalFontSize = {
                            type = "range",
                            name = L.options["Decimal Font Size"],
                            desc = L.options["Select a font size used on a timer's decimal text"],
                            order = 30,
                            min = 8,
                            max = 24,
                            step = 1,
                            disabled = function() return Alerts.db.profile.EmphasisScaleTimerWithBarHeight end,
                        },
                        EmphasisTimerFontColor = {
                            type = "color",
                            name = L.options["Font Color"],
                            desc = L.options["Set a font color used on bar timers"],
                            order = 31,
                        },
                        --------------------- Icon settings --------------------
                        emphasis_icon_desc = {
                            type = "header",
                            name = L.options["|cff00ff00Icon settings|r"].."\n",
                            order = 41,
                        },
                        EmphasisShowLeftIcon = {
                            type = "toggle",
                            name = L.options["Show Left Icon"],
                            desc = L.options["Shows a spell icon on the left side of the bar"],
                            order = 42,
                        },
                        EmphasisShowRightIcon = {
                            type = "toggle",
                            name = L.options["Show Right Icon"],
                            desc = L.options["Shows a spell icon on the right side of the bar"],
                            order = 43,
                        },
                        EmphasisShowIconBorder = {
                            type = "toggle",
                            name = L.options["Show Icon Border"],
                            desc = L.options["Display a border around icons"],
                            order = 44,
                        },
                        blank = genblank(45),
                        EmphasisIconXOffset = {
                            type = "range",
                            name = L.options["Icon X Offset"],
                            desc = L.options["Horizontal position of the icon"],
                            order = 46,
                            min = -200,
                            max = 200,
                            step = 0.1,
                        },
                        EmphasisIconYOffset = {
                            type = "range",
                            name = L.options["Icon Y Offset"],
                            desc = L.options["Vertical position of the icon"],
                            order = 47,
                            min = -200,
                            max = 200,
                            step = 0.1,
                        },
                        EmphasisSetIconToBarHeight = {
                            type = "toggle",
                            order = 48,
                            width = "full",
                            name = L.options["Scale with bar height"],
                            desc = L.options["Automatically resizes the icon when the bar height is adjusted"],
                        },
                        EmphasisIconSize = {
                            type = "range",
                            name = L.options["Icon Size"],
                            desc = L.options["How big the icon is in width and height"],
                            order = 49,
                            min = 10,
                            max = 100,
                            step = 1,
                            disabled = function() return Alerts.db.profile.EmphasisSetIconToBarHeight end,
                        },
                    },
                },
			},
		}
		bars_args.emphasis_group = emphasis_group
        
        local special_group = {
			type = "group",
			name = L.options["|cff53cfffSpecial Anchored Bars|r"],
			order = 160,
            inline = false,
			args = {
                --------------------- Bar settings --------------------
                Individual_bars_desc = {
                    type = "header",
                    name = L.options["|cff00ff00Bar settings|r"].."\n",
                    order = 1,
                },
                IndividualBarWidth = {
                    type = "range",
                    name = L.options["Bar Width Bonus"],
                    desc = L.options["Adjust the with bonus of Individual bars"],
                    order = 2,
                    min = -1000,
                    max = 2000,
                    step = 1,
                },
                IndividualBarHeight = {
                    type = "range",
                    name = L.options["Bar Height"],
                    desc = L.options["Adjust the height of Individual bars"],
                    order = 4,
                    min = 5,
                    max = 200,
                    step = 1,
                },
                IndividualBarXOffset = {
                    type = "range",
                    name = L.options["Horizontal Offset"],
                    desc = L.options["The horizontal offset of the bar's position."],
                    order = 5,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                IndividualBarYOffset = {
                    type = "range",
                    name = L.options["Vertical Offset"],
                    desc = L.options["The vertical offset of the bar's position"],
                    order = 6,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                IndividualAlpha = {
                    type = "range",
                    name = L.options["Bar Alpha"],
                    desc = L.options["Adjust the transparency of Individual bars"],
                    order = 7,
                    min = 0.1,
                    max = 1,
                    step = 0.05,
                },
                IndividualClickThrough = {
                    type = "toggle",
                    order = 9,
                    name = L.options["Make bars click-through"],
                },
                --------------------- Text settings --------------------
                Individual_text_desc = {
                    type = "header",
                    name = L.options["|cff00ff00Text settings|r"].."\n",
                    order = 10,
                },
                IndividualTextWidthBonus = {
                    type = "range",
                    name = L.options["Text Width Bonus"],
                    desc = L.options["Bonus to the bar width given to the bar text"],
                    order = 11,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                IndividualTextHeightBonusMult = {
                    type = "range",
                    name = L.options["Text Height Multiplier"],
                    desc = L.options["Bonus to the bar height multiplied by font size given to the bar text"],
                    order = 12,
                    min = 1,
                    max = 4,
                    step = 1,
                },
                IndividualTextXOffset = {
                    type = "range",
                    name = L.options["Horizontal Offset"],
                    desc = L.options["The horizontal position of the bar text"],
                    order = 13,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                IndividualTextYOffset = {
                    type = "range",
                    name = L.options["Vertical Offset"],
                    desc = L.options["The vertical position of the bar text"],
                    order = 14,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                IndividualBarFontSize = {
                    type = "range",
                    name = L.options["Font Size"],
                    desc = L.options["Select a font size used on bar text"],
                    order = 15,
                    min = 8,
                    max = 20,
                    step = 1,
                },
                IndividualTextAlpha = {
                    type = "range",
                    name = L.options["Alpha"],
                    desc = L.options["Adjust the transparency of bar text"],
                    order = 16,
                    min = 0.1,
                    max = 1,
                    step = 0.05,
                },
                IndividualBarTextJustification = {
                    type = "select",
                    name = L.options["Justification"],
                    desc = L.options["Select a text justification."],
                    order = 17,
                    values = {
                        LEFT = L.options["Left"],
                        CENTER = L.options["Center"],
                        RIGHT = L.options["Right"],
                    },
                },
                IndividualBarFontColor = {
                    type = "color",
                    name = L.options["Font Color"],
                    desc = L.options["Set a font color used on bar text"],
                    order = 18,
                },
                --------------------- Tímer settings --------------------
                Individual_timer_desc = {
                    type = "header",
                    name = L.options["|cff00ff00Timer settings|r"].."\n",
                    order = 21,
                },
                IndividualTimerXOffset = {
                    type = "range",
                    name = L.options["Horizontal Offset"],
                    desc = L.options["The horizontal position of the timer text"],
                    order = 22,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                IndividualTimerYOffset = {
                    type = "range",
                    name = L.options["Vertical Offset"],
                    desc = L.options["The vertical position of the timer text"],
                    order = 23,
                    min = -1000,
                    max = 1000,
                    step = 1,
                },
                IndividualTimerAlpha = {
                    type = "range",
                    name = L.options["Alpha"],
                    desc = L.options["Adjust the transparency of timer text"],
                    order = 24,
                    min = 0.1,
                    max = 1,
                    step = 0.05,
                },
                IndividualShowDecimal = {
                    type = "toggle",
                    name = L.options["Show decimal"],
                    desc = L.options["Enables display of decimal numbers for timer."],
                    order = 25,
                },
                IndividualDecimalPlaces = {
                    type = "range",
                    name = L.options["Number of decimal places"],
                    desc = L.options["Sets the number of decimal place for the timer."],
                    order = 26,
                    min = 1,
                    max = 3,
                    step = 1,
                    disabled = function() return not Alerts.db.profile.IndividualShowDecimal end,
                },
                IndividualDecimalYOffset = {
                    type = "range",
                    name = L.options["Decimal Vertical Offset"],
                    desc = L.options["The vertical position of a timer's decimal text in relation to its second's text"],
                    order = 27,
                    min = -10,
                    max = 10,
                    step = 1,
                    disabled = function() return not Alerts.db.profile.IndividualShowDecimal end,
                },
                IndividualScaleTimerWithBarHeight = {
                    type = "toggle",
                    --width = "full",
                    name = L.options["Scale with bar height"],
                    desc = L.options["Automatically resizes timer font sizes when the bar height is adjusted"],
                    order = 28,
                },
                IndividualTimerSecondsFontSize = {
                    type = "range",
                    name = L.options["Seconds' Font Size"],
                    desc = L.options["Select a font size used on a timer's seconds' text"],
                    order = 29,
                    min = 8,
                    max = 30,
                    step = 1,
                    disabled = function() return Alerts.db.profile.IndividualScaleTimerWithBarHeight end,
                },
                IndividualTimerDecimalFontSize = {
                    type = "range",
                    name = L.options["Decimal Font Size"],
                    desc = L.options["Select a font size used on a timer's decimal text"],
                    order = 30,
                    min = 8,
                    max = 24,
                    step = 1,
                    disabled = function() return Alerts.db.profile.IndividualScaleTimerWithBarHeight end,
                },
                IndividualTimerFontColor = {
                    type = "color",
                    name = L.options["Font Color"],
                    desc = L.options["Set a font color used on bar timers"],
                    order = 31,
                },
                --------------------- Icon settings --------------------
                Individual_icon_desc = {
                    type = "header",
                    name = L.options["|cff00ff00Icon settings|r"].."\n",
                    order = 41,
                },
                IndividualShowIconBorder = {
                    type = "toggle",
                    name = L.options["Show Icon Border"],
                    desc = L.options["Display a border around icons"],
                    order = 44,
                },
                IndividualIconXOffset = {
                    type = "range",
                    name = L.options["Icon X Offset"],
                    desc = L.options["Horizontal position of the icon"],
                    order = 46,
                    min = -200,
                    max = 200,
                    step = 0.1,
                },
                IndividualIconYOffset = {
                    type = "range",
                    name = L.options["Icon Y Offset"],
                    desc = L.options["Vertical position of the icon"],
                    order = 47,
                    min = -200,
                    max = 200,
                    step = 0.1,
                },
                IndividualSetIconToBarHeight = {
                    type = "toggle",
                    order = 48,
                    name = L.options["Scale with bar height"],
                    desc = L.options["Automatically resizes the icon when the bar height is adjusted"],
                },
                IndividualIconSize = {
                    type = "range",
                    name = L.options["Icon Size"],
                    desc = L.options["How big the icon is in width and height"],
                    order = 49,
                    min = 10,
                    max = 100,
                    step = 1,
                    disabled = function() return Alerts.db.profile.IndividualSetIconToBarHeight end,
                },
			},
		}
		bars_args.special_group = special_group
        
        local warning_bar_group = {
			type = "group",
			name = L.options["|cffffffffWarning Bars|r"],
			order = 165,
            inline = false,
			args = {
				WarningBars = {
					type = "toggle",
					order = 100,
					name = L.options["Enable Warning Bars"],
					set = SetNoRefresh,
				},
				warning_bars = {
					type = "group",
					name = L.options["Warning Anchor"],
					order = 200,
					inline = true,
					disabled = function() addon:UpdateLockedFrames();return not Alerts.db.profile.WarningBars end,
					args = {
						WarningAnchor = {
							order = 100,
							type = "toggle",
							name = L.options["Enable Warning Anchor"],
							desc = L.options["Anchors all warning bars to the warning anchor instead of the center anchor"],
							width = "full",
						},
					}
				},
			},
		}
		bars_args.warning_bar_group = warning_bar_group
		
        do
			local warning_bars_args = warning_bar_group.args.warning_bars.args

			local warning_settings_group = {
				type = "group",
				name = "",
				order = 300,
				disabled = function() return not Alerts.db.profile.WarningAnchor or not Alerts.db.profile.WarningBars end,
				args = {
                    warning_bars_desc = {
                        type = "header",
                        name = L.options["|cff00ff00Bar settings|r"].."\n",
                        order = 1,
                    },
					WarningScale = {
						type = "range",
						name = L.options["Bar Scale"],
						desc = L.options["Adjust the size of warning bars"],
						order = 2,
						min = 0.5,
						max = 3.5,
						step = 0.05,
					},
					WarningBarWidth = {
						type = "range",
						name = L.options["Bar Width"],
						desc = L.options["Adjust the width of warning bars"],
						order = 3,
						min = 10,
						max = 1000,
						step = 1,
					},
                    WarningBarHeight = {
                        type = "range",
                        name = L.options["Bar Height"],
                        desc = L.options["Adjust the height of warning bars"],
                        order = 4,
                        min = 5,
                        max = 200,
                        step = 1,
                    },
                    WarningAlpha = {
						type = "range",
						name = L.options["Bar Alpha"],
						desc = L.options["Adjust the transparency of warning bars"],
						order = 5,
						min = 0.1,
						max = 1,
						step = 0.05,
					},
                    WarningBarSpacing = {
                        order = 6,
                        type = "range",
                        name = L.options["Bar Spacing"],
                        desc = L.options["How far apart the bars are spaced vertically"],
                        min = -20,
                        max = 300,
                        step = 1,
                    },
					WarningGrowth = {
						type = "select",
						name = L.options["Bar Growth"],
						desc = L.options["The direction warning bars grow"],
						order = 7,
						values = {DOWN = L.options["Down"], UP = L.options["Up"]},
					},
                    WarningSort = {
                        type = "select",
                        name = L.options["Bar Sort Method"],
                        desc = L.options["The sort method for warning bars"],
                        order = 8,
                        values = {HIGH_FIRST = L.options["High First"], LOW_FIRST = L.options["Low First"]},
                    },
					RedirectCenter = {
						type = "toggle",
						name = L.options["Redirect center bars"],
						desc = L.options["Anchor a center bar to the warnings anchor if its duration is less than or equal to threshold time"],
						order = 9,
						width = "full",
					},
					RedirectThreshold = {
						type = "range",
						name = L.options["Threshold time"],
						desc = L.options["If a center bar's duration is less than or equal to this then it anchors to the warnings anchor"],
						order = 10,
						min = 1,
						max = 15,
						step = 1,
						disabled = function() return not Alerts.db.profile.WarningBars or not Alerts.db.profile.WarningAnchor or not Alerts.db.profile.RedirectCenter end
					},
                    WarningClickThrough = {
                        type = "toggle",
                        name = L.options["Make bars click-through"],
                        order = 11,
                    },
                    warning_text_desc = {
                        type = "header",
                        name = L.options["|cff00ff00Text settings|r"].."\n",
                        order = 12,
                    },
                    WarningTextWidthBonus = {
                        type = "range",
                        name = L.options["Text Width Bonus"],
                        desc = L.options["Bonus to the bar width given to the bar text"],
                        order = 13,
                        min = -1000,
                        max = 1000,
                        step = 1,
                    },
                    WarningTextHeightBonusMult = {
                        type = "range",
                        name = L.options["Text Height Multiplier"],
                        desc = L.options["Bonus to the bar height multiplied by font size given to the bar text"],
                        order = 14,
                        min = 1,
                        max = 4,
                        step = 1,
                    },
                    WarningTextXOffset = {
                        type = "range",
                        name = L.options["Horizontal Offset"],
                        desc = L.options["The horizontal position of the bar text"],
                        order = 15,
                        min = -1000,
                        max = 1000,
                        step = 1,
                    },
                    WarningTextYOffset = {
                        type = "range",
                        name = L.options["Vertical Offset"],
                        desc = L.options["The vertical position of the bar text"],
                        order = 16,
                        min = -1000,
                        max = 1000,
                        step = 1,
                    },
                    WarningBarFontSize = {
                        type = "range",
                        name = L.options["Font Size"],
                        desc = L.options["Select a font size used on bar text"],
                        order = 17,
                        min = 8,
                        max = 20,
                        step = 1,
                    },
                    WarningTextAlpha = {
                        type = "range",
                        name = L.options["Alpha"],
                        desc = L.options["Adjust the transparency of bar text"],
                        order = 18,
                        min = 0.1,
                        max = 1,
                        step = 0.05,
                    },
                    WarningBarTextJustification = {
                        type = "select",
                        name = L.options["Justification"],
                        desc = L.options["Select a text justification."],
                        order = 19,
                        values = {
                            LEFT = L.options["Left"],
                            CENTER = L.options["Center"],
                            RIGHT = L.options["Right"],
                        },
                    },
                    WarningBarFontColor = {
                        type = "color",
                        name = L.options["Font Color"],
                        desc = L.options["Set a font color used on bar text"],
                        order = 20,
                    },
                    --------------------- Icon settings --------------------
                    Warning_icon_desc = {
                        type = "header",
                        name = L.options["|cff00ff00Icon settings|r"].."\n",
                        order = 41,
                    },
                    WarningShowLeftIcon = {
                        type = "toggle",
                        name = L.options["Show Left Icon"],
                        desc = L.options["Shows a spell icon on the left side of the bar"],
                        order = 42,
                    },
                    WarningShowRightIcon = {
                        type = "toggle",
                        name = L.options["Show Right Icon"],
                        desc = L.options["Shows a spell icon on the right side of the bar"],
                        order = 43,
                    },
                    WarningShowIconBorder = {
                        type = "toggle",
                        name = L.options["Show Icon Border"],
                        desc = L.options["Display a border around icons"],
                        order = 44,
                    },
                    WarningIconXOffset = {
                        type = "range",
                        name = L.options["Icon X Offset"],
                        desc = L.options["Horizontal position of the icon"],
                        order = 46,
                        min = -200,
                        max = 200,
                        step = 0.1,
                    },
                    WarningIconYOffset = {
                        type = "range",
                        name = L.options["Icon Y Offset"],
                        desc = L.options["Vertical position of the icon"],
                        order = 47,
                        min = -200,
                        max = 200,
                        step = 0.1,
                    },
                    WarningSetIconToBarHeight = {
                        type = "toggle",
                        order = 48,
                        name = L.options["Scale with bar height"],
                        desc = L.options["Automatically resizes the icon when the bar height is adjusted"],
                    },
                    WarningIconSize = {
                        type = "range",
                        name = L.options["Icon Size"],
                        desc = L.options["How big the icon is in width and height"],
                        order = 49,
                        min = 10,
                        max = 100,
                        step = 1,
                        disabled = function() return Alerts.db.profile.WarningSetIconToBarHeight end,
                    },
				},
			}
			warning_bars_args.warning_settings_group = warning_settings_group
		end
        
        do
			local colors = {}
			for k,c in pairs(addon.db.profile.Colors) do
				local hex = ("|cff%02x%02x%02x%s|r"):format(c.r*255,c.g*255,c.b*255,L[k])
				colors[k] = hex
			end

			local intro_desc = L.options["You can fire local or raid bars. Local bars are only seen by you. Raid bars are seen by you and raid members; You have to be a raid officer to fire raid bars"]
			local howto_desc = L.options["Slash commands: |cffffff00/dxelb time text|r (local bar) or |cffffff00/dxerb time text|r (raid bar): |cffffff00time|r can be in the format |cffffd200minutes:seconds|r or |cffffd200seconds|r"]
			local example1 = "/dxerb 15 Pulling in..."
			local example2 = "/dxelb 6:00 Pizza Timer"

			local custom_group = {
				type = "group",
				name = L.options["|cffffffffCustom Bars|r"],
				order = 400,
				args = {
					intro_desc = {
						type = "description",
						name = intro_desc,
						order = 1,
					},
					CustomLocalClr = {
						order = 2,
						type = "select",
						name = L.options["Local Bar Color"],
						desc = L.options["The color of local bars that you fire"],
						values = colors,
					},
					CustomRaidClr = {
						order = 3,
						type = "select",
						name = L.options["Raid Bar Color"],
						desc = L.options["The color of broadcasted raid bars fired by you or a raid member"],
						values = colors,
					},
					CustomSound = {
						order = 4,
						type = "select",
						name = L.options["Sound"],
						desc = L.options["The sound that plays when a custom bar is fired"],
						values = GetSounds,
					},
					howto_desc = {
						type = "description",
						name = "\n"..howto_desc,
						order = 5,
					},
					examples_desc = {
						type = "description",
						order = 6,
						name = "\n"..L.options["Examples"]..":\n\n   "..example1.."\n   "..example2,
					},
				},
			}

			bars_args.custom_group = custom_group
		end
        
--[[ Text
		local font_group = {
			type = "group",
			name = L.options["Text"],
			order = 400,
            childGroups = "tab",
			args = {
				font_desc = {
					type = "header",
					name = L.options["Adjust the text used on timer bars"].."\n",
					order = 1,
				},
                timertext_group = {
					type = "group",
					name = L.options["Timer Text"],
					order = 250,
					args = {
						timer_desc = {
							type = "description",
							name = L.options["Timer font sizes are determined by bar height"].."\n",
							order = 1,
						},
						TimerFontColor = {
							order = 50,
							type = "color",
							name = L.options["Font Color"],
							desc = L.options["Set a font color used on bar timers"],
							width = "full",
						},
						TimerXOffset = {
							order = 100,
							type = "range",
							name = L.options["Horizontal Offset"],
							desc = L.options["The horizontal position of the timer text"],
							min = -1000,
							max = 1000,
							step = 1,
						},
						TimerYOffset = {
							order = 200,
							type = "range",
							name = L.options["Vertical Offset"],
							desc = L.options["The vertical position of the timer text"],
							min = -1000,
							max = 1000,
							step = 1,
						},
                        ShowDecimal = {
                            order = 225,
                            type = "toggle",
                            name = L.options["Show decimal"],
                            desc = L.options["Enables display of decimal numbers for timer."],
                        },
                        DecimalPlaces = {
							order = 250,
							type = "range",
							name = L.options["Number of decimal places"],
							desc = L.options["Sets the number of decimal place for the timer."],
							min = 1,
							max = 3,
							step = 1,
                            disabled = function() return not Alerts.db.profile.ShowDecimal end,
						},
						DecimalYOffset = {
							order = 300,
							type = "range",
							name = L.options["Decimal Vertical Offset"],
							desc = L.options["The vertical position of a timer's decimal text in relation to its second's text"],
							min = -10,
							max = 10,
							step = 1,
                            disabled = function() return not Alerts.db.profile.ShowDecimal end,
						},
						TimerAlpha = {
							type = "range",
							name = L.options["Alpha"],
							desc = L.options["Adjust the transparency of timer text"],
							order = 305,
							min = 0.1,
							max = 1,
							step = 0.05,
						},
						ScaleTimerWithBarHeight = {
							order = 307,
							type = "toggle",
							width = "full",
							name = L.options["Scale with bar height"],
							desc = L.options["Automatically resizes timer font sizes when the bar height is adjusted"],
						},
						TimerSecondsFontSize = {
							order = 310,
							type = "range",
							name = L.options["Seconds' Font Size"],
							desc = L.options["Select a font size used on a timer's seconds' text"],
							min = 8,
							max = 30,
							step = 1,
							disabled = function() return Alerts.db.profile.ScaleTimerWithBarHeight end,
						},
						TimerDecimalFontSize = {
							order = 320,
							type = "range",
							name = L.options["Decimal Font Size"],
							desc = L.options["Select a font size used on a timer's decimal text"],
							min = 8,
							max = 10,
							step = 1,
							disabled = function() return Alerts.db.profile.ScaleTimerWithBarHeight end,
						},
					},
				},
			},
		}

		bars_args.font_group = font_group
]]
--[[ Icons
		local icon_group = {
			type = "group",
			name = L.options["Icon"],
			order = 500,
			args = {
				icon_desc = {
					type = "header",
					name = L.options["Adjust the spell icon on timer bars"].."\n",
					order = 1,
				},
				ShowLeftIcon = {
					order = 100,
					type = "toggle",
					name = L.options["Show Left Icon"],
					desc = L.options["Shows a spell icon on the left side of the bar"],
				},
				ShowRightIcon = {
					order = 125,
					type = "toggle",
					name = L.options["Show Right Icon"],
					desc = L.options["Shows a spell icon on the right side of the bar"],
				},
				ShowIconBorder = {
					order = 150,
					type = "toggle",
					name = L.options["Show Icon Border"],
					desc = L.options["Display a border around icons"],
				},
				blank = genblank(200),
				IconXOffset = {
					order = 300,
					type = "range",
					name = L.options["Icon X Offset"],
					desc = L.options["Horizontal position of the icon"],
					min = -200,
					max = 200,
					step = 0.1,
				},
				IconYOffset = {
					order = 400,
					type = "range",
					name = L.options["Icon Y Offset"],
					desc = L.options["Vertical position of the icon"],
					min = -200,
					max = 200,
					step = 0.1,
				},
				SetIconToBarHeight = {
					order = 450,
					type = "toggle",
					width = "full",
					name = L.options["Scale with bar height"],
					desc = L.options["Automatically resizes the icon when the bar height is adjusted"],
				},
				IconSize = {
					order = 500,
					type = "range",
					name = L.options["Icon Size"],
					desc = L.options["How big the icon is in width and height"],
					min = 10,
					max = 100,
					step = 1,
					disabled = function() return Alerts.db.profile.SetIconToBarHeight end,
				},
			},
		}

		bars_args.icon_group = icon_group
]]
--[[ Top
		local top_group = {
			type = "group",
			name = L.options["Top Anchored Bars"],
			order = 600,
			disabled = function() return Alerts.db.profile.DisableDropdowns end,
			args = {
				top_desc = {
					type = "header",
					name = L.options["Adjust settings related to the top anchor"].."\n",
					order = 1,
				},
				TopScale = {
					order = 100,
					type = "range",
					name = L.options["Bar Scale"],
					desc = L.options["Adjust the size of top bars"],
					min = 0.5,
					max = 1.5,
					step = 0.05,
				},
				TopAlpha = {
					type = "range",
					name = L.options["Bar Alpha"],
					desc = L.options["Adjust the transparency of top bars"],
					order = 200,
					min = 0.1,
					max = 1,
					step = 0.05,
				},
				TopBarWidth = {
					order = 300,
					type = "range",
					name = L.options["Bar Width"],
					desc = L.options["Adjust the width of top bars"],
					min = 220,
					max = 2000,
					step = 1,
				},
                TopBarHeight = {
					order = 350,
					type = "range",
					name = L.options["Bar Height"],
					desc = L.options["Adjust the height of top bars"],
					min = 5,
					max = 200,
					step = 1,
				},
				TopGrowth = {
					order = 400,
					type = "select",
					name = L.options["Bar Growth"],
					desc = L.options["The direction top bars grow"],
					values = {DOWN = L.options["Down"], UP = L.options["Up"]},
				},
				TopTextWidth = {
					order = 500,
					type = "range",
					name = L.options["Text Width"],
					desc = L.options["The width of the text for top bars"],
					min = 50,
					max = 1000,
					step = 1,
				},
                TopClickThrough = {
					type = "toggle",
					order = 600,
					name = L.options["Make bars click-through"],
				},
			},
		}
		bars_args.top_group = top_group
]]
--[[ Center
        local center_group = {
			type = "group",
			name = L.options["Center Anchored Bars"],
			order = 700,
			args = {
				center_desc = {
					type = "header",
					name = L.options["Adjust settings related to the center anchor"].."\n",
					order = 1,
				},
				CenterScale = {
					order = 100,
					type = "range",
					name = L.options["Bar Scale"],
					desc = L.options["Adjust the size of center bars"],
					min = 0.5,
					max = 1.5,
					step = 0.05,
				},
				CenterAlpha = {
					type = "range",
					name = L.options["Bar Alpha"],
					desc = L.options["Adjust the transparency of center bars"],
					order = 200,
					min = 0.1,
					max = 1,
					step = 0.05,
				},
				CenterBarWidth = {
					order = 300,
					type = "range",
					name = L.options["Bar Width"],
					desc = L.options["Adjust the width of center bars"],
					min = 220,
					max = 2000,
					step = 1,
				},
                CenterBarHeight = {
					order = 350,
					type = "range",
					name = L.options["Bar Height"],
					desc = L.options["Adjust the height of center bars"],
					min = 5,
					max = 200,
					step = 1,
				},
				CenterGrowth = {
					order = 400,
					type = "select",
					name = L.options["Bar Growth"],
					desc = L.options["The direction center bars grow"],
					values = {DOWN = L.options["Down"], UP = L.options["Up"]},
				},
				CenterTextWidth = {
					order = 500,
					type = "range",
					name = L.options["Text Width"],
					desc = L.options["The width of the text for center bars"],
					min = 50,
					max = 1000,
					step = 1,
				},
                CenterClickThrough = {
					type = "toggle",
					order = 600,
					name = L.options["Make bars click-through"],
				},
			},
		}

		bars_args.center_group = center_group
]]
--[[ Emphasis
        local emphasis_group = {
			type = "group",
			name = L.options["Emphasis Anchored Bars"],
			order = 720,
			args = {
                EmphasisAnchor = {
					type = "toggle",
					order = 100,
					name = L.options["Enable Emphasis Anchor"],
					set = SetNoRefresh,
                    width = "double",
				},
                emphasis_bars = {
					type = "group",
					name = L.options["Emphasis Anchor"],
					order = 200,
					inline = true,
					disabled = function() addon:UpdateLockedFrames();return not Alerts.db.profile.EmphasisAnchor end,
					args = {
                        emphasis_desc = {
                            type = "header",
                            name = L.options["Adjust settings related to the emphasis anchor"].."\n",
                            order = 1,
                        },
                        EmphasisScale = {
                            order = 100,
                            type = "range",
                            name = L.options["Bar Scale"],
                            desc = L.options["Adjust the size of emphasis bars"],
                            min = 0.5,
                            max = 1.5,
                            step = 0.05,
                        },
                        EmphasisAlpha = {
                            type = "range",
                            name = L.options["Bar Alpha"],
                            desc = L.options["Adjust the transparency of emphasis bars"],
                            order = 200,
                            min = 0.1,
                            max = 1,
                            step = 0.05,
                        },
                        EmphasisBarWidth = {
                            order = 300,
                            type = "range",
                            name = L.options["Bar Width"],
                            desc = L.options["Adjust the width of emphasis bars"],
                            min = 220,
                            max = 2000,
                            step = 1,
                        },
                        EmphasisBarHeight = {
                            order = 350,
                            type = "range",
                            name = L.options["Bar Height"],
                            desc = L.options["Adjust the height of emphasis bars"],
                            min = 5,
                            max = 200,
                            step = 1,
                        },
                        EmphasisGrowth = {
                            order = 400,
                            type = "select",
                            name = L.options["Bar Growth"],
                            desc = L.options["The direction emphasis bars grow"],
                            values = {DOWN = L.options["Down"], UP = L.options["Up"]},
                        },
                        EmphasisTextWidth = {
                            order = 500,
                            type = "range",
                            name = L.options["Text Width"],
                            desc = L.options["The width of the text for emphasis bars"],
                            min = 50,
                            max = 1000,
                            step = 1,
                        },
                        EmphasisClickThrough = {
                            type = "toggle",
                            order = 600,
                            name = L.options["Make bars click-through"],
                        },
                    },
                },
			},
		}

		bars_args.emphasis_group = emphasis_group
]]        
--[[ Custom
        do
			local colors = {}
			for k,c in pairs(addon.db.profile.Colors) do
				local hex = ("|cff%02x%02x%02x%s|r"):format(c.r*255,c.g*255,c.b*255,L[k])
				colors[k] = hex
			end

			local intro_desc = L.options["You can fire local or raid bars. Local bars are only seen by you. Raid bars are seen by you and raid members; You have to be a raid officer to fire raid bars"]
			local howto_desc = L.options["Slash commands: |cffffff00/dxelb time text|r (local bar) or |cffffff00/dxerb time text|r (raid bar): |cffffff00time|r can be in the format |cffffd200minutes:seconds|r or |cffffd200seconds|r"]
			local example1 = "/dxerb 15 Pulling in..."
			local example2 = "/dxelb 6:00 Pizza Timer"

			local custom_group = {
				type = "group",
				name = L.options["Custom Bars"],
				order = 750,
				args = {
					intro_desc = {
						type = "description",
						name = intro_desc,
						order = 1,
					},
					CustomLocalClr = {
						order = 2,
						type = "select",
						name = L.options["Local Bar Color"],
						desc = L.options["The color of local bars that you fire"],
						values = colors,
					},
					CustomRaidClr = {
						order = 3,
						type = "select",
						name = L.options["Raid Bar Color"],
						desc = L.options["The color of broadcasted raid bars fired by you or a raid member"],
						values = colors,
					},
					CustomSound = {
						order = 4,
						type = "select",
						name = L.options["Sound"],
						desc = L.options["The sound that plays when a custom bar is fired"],
						values = GetSounds,
					},
					howto_desc = {
						type = "description",
						name = "\n"..howto_desc,
						order = 5,
					},
					examples_desc = {
						type = "description",
						order = 6,
						name = "\n"..L.options["Examples"]..":\n\n   "..example1.."\n   "..example2,
					},
				},
			}

			bars_args.custom_group = custom_group
		end
]]
--[[ Warning
		-- WARNINGS
		local warning_bar_group = {
			type = "group",
			name = L.options["Warning Bars"],
			order = 800,
			args = {
				WarningBars = {
					type = "toggle",
					order = 100,
					name = L.options["Enable Warning Bars"],
					set = SetNoRefresh,
				},
				warning_bars = {
					type = "group",
					name = L.options["Warning Anchor"],
					order = 200,
					inline = true,
					disabled = function() addon:UpdateLockedFrames();return not Alerts.db.profile.WarningBars end,
					args = {
						WarningAnchor = {
							order = 100,
							type = "toggle",
							name = L.options["Enable Warning Anchor"],
							desc = L.options["Anchors all warning bars to the warning anchor instead of the center anchor"],
							width = "full",
						},
					}
				},
			},
		}

		bars_args.warning_bar_group = warning_bar_group

		do
			local warning_bars_args = warning_bar_group.args.warning_bars.args

			local warning_settings_group = {
				type = "group",
				name = "",
				order = 300,
				disabled = function() return not Alerts.db.profile.WarningAnchor or not Alerts.db.profile.WarningBars end,
				args = {
					WarningScale = {
						order = 100,
						type = "range",
						name = L.options["Bar Scale"],
						desc = L.options["Adjust the size of warning bars"],
						min = 0.5,
						max = 1.5,
						step = 0.05,
					},
					WarningAlpha = {
						type = "range",
						name = L.options["Bar Alpha"],
						desc = L.options["Adjust the transparency of warning bars"],
						order = 200,
						min = 0.1,
						max = 1,
						step = 0.05,
					},
					WarningBarWidth = {
						order = 300,
						type = "range",
						name = L.options["Bar Width"],
						desc = L.options["Adjust the width of warning bars"],
						min = 220,
						max = 1000,
						step = 1,
					},
                    WarningBarHeight = {
                        order = 320,
                        type = "range",
                        name = L.options["Bar Height"],
                        desc = L.options["Adjust the height of warning bars"],
                        min = 5,
                        max = 200,
                        step = 1,
                    },
					WarningTextWidth = {
						order = 350,
						type = "range",
						name = L.options["Text Width"],
						desc = L.options["The width of the text for warning bars"],
						min = 50,
						max = 1000,
						step = 1,
					},
					WarningGrowth = {
						order = 400,
						type = "select",
						name = L.options["Bar Growth"],
						desc = L.options["The direction warning bars grow"],
						values = {DOWN = L.options["Down"], UP = L.options["Up"]},
					},
					RedirectCenter = {
						order = 500,
						type = "toggle",
						name = L.options["Redirect center bars"],
						desc = L.options["Anchor a center bar to the warnings anchor if its duration is less than or equal to threshold time"],
						width = "full",
					},
					RedirectThreshold = {
						order = 600,
						type = "range",
						name = L.options["Threshold time"],
						desc = L.options["If a center bar's duration is less than or equal to this then it anchors to the warnings anchor"],
						min = 1,
						max = 15,
						step = 1,
						disabled = function() return not Alerts.db.profile.WarningBars or not Alerts.db.profile.WarningAnchor or not Alerts.db.profile.RedirectCenter end
					},
                    WarningClickThrough = {
                        type = "toggle",
                        order = 700,
                        name = L.options["Make bars click-through"],
                    },
				},
			}
			warning_bars_args.warning_settings_group = warning_settings_group
		end
]]
		local warning_message_group = {
			type = "group",
			name = L.options["Warning Messages"],
			order = 140,
			args = {
                WarningMessages = {
                    type = "toggle",
                    name = L.options["Enable Warning Messages"],
                    desc = L.options["Output to an additional interface"],
                    order = 1,
                    width = "full",
                },
                warning_desc = {
                    type = "description",
                    name = L.options["Alerts are split into three categories: cooldowns, durations, and warnings. Cooldown and duration alerts can fire a message before they end and when they popup. Warning alerts can only fire a message when they popup. Alerts suffixed self can only fire a popup message even if it is a duration"].."\n",
                    order = 2,
                },
                AnnounceToRaid = {
                    order = 2.5,
                    type = "toggle",
                    name = L.options["Announce to raid"],
                    desc = L.options["Announce warning messages through raid warning chat"],
                    --width = "full",
                    disabled = function() return not Alerts.db.profile.WarningMessages end,
                },
                AnnounceOnClick = {
                    order = 2.7,
                    type = "toggle",
                    name = L.options["Announce on click"],
                    desc = L.options["Announce timer to the raid / party chat after clicking on timer bar while holding Control key."],
                    --width = "full",
                    disabled = function() return not Alerts.db.profile.WarningMessages end,
                },
                ClrWarningText = {
                    order = 3,
                    type = "toggle",
                    name = L.options["Color Text"],
                    desc = L.options["Class colors text"],
                    --width = "full",
                    disabled = function() return not Alerts.db.profile.WarningMessages end,
                },
                SinkIconLeft = {
                    order = 4,
                    type = "toggle",
                    name = L.options["Show Left Icon"],
                    desc = L.options["Display an icon to the left of a warning message"],
                    --width = "full",
                    disabled = function() return not Alerts.db.profile.WarningMessages end,
                },
                SinkIconRight = {
                    order = 5,
                    type = "toggle",
                    name = L.options["Show Right Icon"],
                    desc = L.options["Display an icon to the right of a warning message"],
                    --width = "full",
                    disabled = function() return not Alerts.db.profile.WarningMessages end,
                },
                BeforeThreshold = {
                    order = 6,
                    type = "range",
                    name = L.options["Before End Threshold"],
                    desc = L.options["How many seconds before an alert ends to fire a warning message. This only applies to cooldown and duration type alerts"],
                    min = 1,
                    max = 15,
                    step = 1,
                    disabled = function() return not Alerts.db.profile.WarningMessages end,
                },
                inner_group = {
                    type = "group",
                    name = "",
                    disabled = function() return not Alerts.db.profile.WarningMessages end,
                    order = 150,
                    childGroups = "tab",
                    inline = true,
                    args = {
                        warning_alert_group = {
                            type = "group",
                                order = 7,
                                name = L.options["DXE Alerts Frame"],
                                inline = false,
                                get = function(info) return Alerts.db.profile[info[#info]] end,
                                set = function(info, value) Alerts.db.profile[info[#info]] = value;addon:UpdateAlertsFrame() end,
                                args = {
                                    AlertsDirection = {
                                        order = 10,
                                        type = "select",
                                        name = L.options["Flow Direction"],
                                        desc = L.options["The direction in which the warning messages flow after being pushed."],
                                        values = {
                                            UP = "UP",
                                            DOWN = "DOWN",
                                        },
                                    },
                                    AlertsFont = {
                                        order = 50,
                                        type = "select",
                                        name = L.options["Font"],
                                        desc = L.options["Font used for the Alerts Frame."],
                                        values = SM:HashTable("font"),
                                        dialogControl = "LSM30_Font",
                                    },
                                    AlertsFontSize = {
                                        order = 60,
                                        type = "range",
                                        name = L.options["Font size"],
                                        desc = L.options["Font size use for the Alerts Frame."],
                                        min = 12,
                                        max = 34,
                                        step = 1,
                                    },
                                    AlertsFontDecoration = {
                                        order = 70,
                                        type = "select",
                                        name = L.options["Font decoration"],
                                        desc = L.options["Font decoration used for the Alerts Frame."],
                                        values = {
                                            OUTLINE = "OUTLINE",
                                            THICKOUTLINE = "THICKOUTLINE",
                                        },
                                    },
                                    AlertsNumSlots = {
                                        order = 20,
                                        type = "range",
                                        name = L.options["Number of slots"],
                                        desc = L.options["Sets the number of warnings that are displayed.\n\n|cffff0000Requires UI reload.|r"],
                                        min = 1,
                                        max = 4,
                                        step = 1,
                                    },
                                    alertframe_blank = genblank(25),
                                    Alerts_Time_Holding = {
                                        order = 30,
                                        type = "range",
                                        name = L.options["Wait Time"],
                                        desc = L.options["Sets the delay (in seconds) after which the alert starts fading."],
                                        min = 1,
                                        max = 15,
                                        step = 0.1,
                                    },
                                    Alerts_Time_Fading = {
                                        order = 40,
                                        type = "range",
                                        name = L.options["Fade Time"],
                                        desc = L.options["Sets the delay (in seconds) after which the alert starts fading."],
                                        min = 0.1,
                                        max = 5,
                                        step = 0.01,
                                    },
                                    alertframe_blank2 = genblank(45),
                                },
                        },
                        warning_emphasize_group = {
                            type = "group",
                            order = 8,
                            name = L.options["Emphasis Warning Frame"],
                            inline = false,
                            get = function(info) return Alerts.db.profile[info[#info]] end,
                            set = function(info, value) Alerts.db.profile[info[#info]] = value;addon:UpdateEmphasisFrame() end,
                            args = {
                                EmphasisFont = {
                                    order = 10,
                                    type = "select",
                                    name = L.options["Font"],
                                    desc = L.options["Font used for the Emphasis Warning Frame."],
                                    values = SM:HashTable("font"),
                                    dialogControl = "LSM30_Font",
                                },
                                EmphasisFontSize = {
                                    order = 20,
                                    type = "range",
                                    name = L.options["Font size"],
                                    desc = L.options["Font size use for the Emphasis Warning Frame."],
                                    min = 12,
                                    max = 34,
                                    step = 1,
                                },
                                EmphasisFontDecoration = {
                                    order = 30,
                                    type = "select",
                                    name = L.options["Font decoration"],
                                    desc = L.options["Font decoration  used for the emphasized warning Frame."],
                                    values = {
                                        OUTLINE = "OUTLINE",
                                        THICKOUTLINE = "THICKOUTLINE",
                                    },
                                },
                                emphasis_blank = genblank(35),
                                EmphasisFadeIn = {
                                    order = 40,
                                    type = "range",
                                    name = L.options["Fade-out delay"],
                                    desc = L.options["Delay in seconds after which the emphasized warning starts to fade out."],
                                    min = 0,
                                    max = 10,
                                    step = 0.5,
                                },
                                EmphasisFadeTime = {
                                    order = 50,
                                    type = "range",
                                    name = L.options["Fade duration"],
                                    desc = L.options["A duration of the emphasized warning fade."],
                                    min = 1,
                                    max = 5,
                                    step = 0.5,
                                },
                            },
                        },
                        filter_group = {
                            type = "group",
                            order = 40,
                            name = L.options["Show messages for"].." ...",
                            inline = false,
                            args = {
                                filter_desc = {
                                    type = "description",
                                    name = L.options["Enabling |cffffd200X popups|r will make it fire a message on appearance. Enabling |cffffd200X before ending|r will make it fire a message before ending based on before end threshold"],
                                    order = 1,
                                },
                                CdPopupMessage = {type = "toggle", name = L.options["Cooldown popups"], order = 2, width = "full"},
                                CdBeforeMessage = {type = "toggle", name = L.options["Cooldowns before ending"], order = 3, width = "full"},
                                DurPopupMessage = {type = "toggle", name = L.options["Duration popups"], order = 4, width = "full"},
                                DurBeforeMessage = {type = "toggle", name = L.options["Durations before ending"], order = 5, width = "full"},
                                WarnPopupMessage = {type = "toggle", name = L.options["Warning popups"], order = 6, width = "full"},
                            }
                        },
                        output_desc = {
                            type = "description",
                            order = 10,
                            name = L.options["You can output warning messages many different ways and they will only be seen by you. If you don't want to see these then click |cffffd200'None'|r"],
                        },
                        OutputType = {
                            type = "select",
                            name = L.options["Output Type"],
                            desc = L.options["Determines where warning messages get outputted."],
                            order = 20,
                            values = {
                                DXE_FRAME = "|cff11caffDXE Alerts|r Frame",
                                ACE3 = "Ace3 Output",
                            },
                            --get = function(info) return db.profile.SpecialWarnings["SpecialOutput"] end,
                            --set = function(info,v) db.profile.SpecialWarnings["SpecialOutput"] = v end,
                        },
                        outputblank = genblank(21),
                        DefaultChatOutput = {
                            type = "toggle",
                            name = L.options["+ Default Chat Frame"],
                            desc = L.options["Include warning message text in the Default Chat Frame."],
                            order = 25,
                        },
                        Ace3Output = Alerts:GetSinkAce3OptionsDataTable(),
                    },
                },
			},
		}
        
		alerts_args.warning_message_group = warning_message_group
		warning_message_group.args.inner_group.args.Ace3Output.disabled = function() return not Alerts.db.profile.WarningMessages end
		warning_message_group.args.inner_group.args.Ace3Output.inline = false
		warning_message_group.args.inner_group.args.Ace3Output.name = L.options["Ace3 Output"]
        warning_message_group.args.inner_group.args.Ace3Output.disabled = function() return Alerts.db.profile.OutputType ~= "ACE3" end
        warning_message_group.args.inner_group.args.Ace3Output.order = -1
        

		local flash_group = {
			type = "group",
			name = L.options["Screen Flash"],
			order = 200,
			args = {
				flash_desc = {
					type = "description",
					name = L.options["The color of the flash becomes the main color of the alert. Colors for each alert are set in the Encounters section. If the color is set to 'Clear' it defaults to black"].."\n",
					order = 50,
				},
				DisableScreenFlash = {
					order = 75,
					type = "toggle",
					name = L.options["Disable Screen Flash"],
					desc = L.options["Turns off all alert screen flashes"],
					set = SetNoRefresh,
					width = "full",
				},
				flash_inner_group = {
					name = "",
					type = "group",
					order = 100,
					inline = true,
					disabled = function() return Alerts.db.profile.DisableScreenFlash end,
					args = {
						FlashTest = {
							type = "execute",
							name = L.options["Test Flash"],
							desc = L.options["Fires a flash using a random color"],
							order = 100,
							func = "FlashTest",
						},
						FlashTexture = {
							type = "select",
							name = L.options["Texture"],
							desc = L.options["Select a background texture"],
							order = 120,
							values = Alerts.FlashTextures,
							set = function(info,v) Alerts.db.profile.FlashTexture = v; Alerts:UpdateFlashSettings() end,
						},
						FlashAlpha = {
							type = "range",
							name = L.options["Alpha"],
							desc = L.options["Adjust the transparency of the flash"],
							order = 200,
							min = 0.1,
							max = 1,
							step = 0.05,
						},
						FlashDuration = {
							type = "range",
							name = L.options["Duration"],
							desc = L.options["Adjust how long the flash lasts"],
							order = 300,
							min = 0.2,
							max = 3,
							step = 0.05,
						},
						EnableOscillations = {
							type = "toggle",
							name = L.options["Enable Oscillations"],
							desc = L.options["Enables the strobing effect"],
							order = 350,
						},
						FlashOscillations = {
							type = "range",
							name = L.options["Oscillations"],
							desc = L.options["Adjust how many times the flash fades in and out"],
							order = 400,
							min = 1,
							max = 10,
							step = 1,
							disabled = function() return Alerts.db.profile.DisableScreenFlash or not Alerts.db.profile.EnableOscillations end,
						},
						blank = genblank(450),
						ConstantClr = {
							type = "toggle",
							name = L.options["Use Constant Color"],
							desc = L.options["Make the screen flash always be the global color. It will not become the main color of the alert."],
							order = 500,
						},
						GlobalColor = {
							type = "color",
							name = L.options["Global Color"],
							order = 600,
							disabled = function() return Alerts.db.profile.DisableScreenFlash or not Alerts.db.profile.ConstantClr end,
						},
					},
				},
			},
		}

		alerts_args.flash_group = flash_group

		local Arrows = addon.Arrows
		local arrows_group = {
			name = L.options["Arrows"],
			type = "group",
			order = 120,
			get = function(info) return Arrows.db.profile[info[#info]] end,
			set = function(info,v) Arrows.db.profile[info[#info]] = v; Arrows:RefreshArrows() end,
			args = {
				Enable = {
					type = "toggle",
					name = L.options["Enable"],
					desc = L.options["Enable the use of directional arrows"],
					order = 1,
				},
				enable_group = {
					type = "group",
					order = 2,
					name = "",
					inline = true,
					disabled = function() return not Arrows.db.profile.Enable end,
					args = {
						TestArrows = {
							name = L.options["Test Arrows"],
							type = "execute",
							order = 1,
							desc = L.options["Displays all arrows and then rotates them for ten seconds"],
							func = function()
								for k,arrow in ipairs(addon.Arrows.frames) do
									arrow:Test()
								end
							end,
						},
						Scale = {
							name = L.options["Scale"],
							desc = L.options["Adjust the scale of arrows"],
							type = "range",
							min = 0.3,
							max = 2,
							step = 0.1
						},
					},
				},
			},
		}

		alerts_args.arrows_group = arrows_group

		local RaidIcons = addon.RaidIcons

		local raidicons_group = {
			type = "group",
			name = L.options["Raid Icons"],
			order = 121,
			get = function(info) return RaidIcons.db.profile[tonumber(info[#info])] end,
			set = function(info,v) RaidIcons.db.profile[tonumber(info[#info])] = v end,
			args = {
				Enabled = {
					type = "toggle",
					get = function(info) return RaidIcons.db.profile.Enabled end,
					set = function(info,v) RaidIcons.db.profile.Enabled = v end,
					name = L.options["Enable"],
					desc = L.options["Enable raid icon marking. If this is disabled then you will not mark targets even if you have raid assist and raid icons enabled in encounters"],
					order = 0.1,
				},
                EnabledPartyLeaderBypass = {
					type = "toggle",
                    width = "double",
					get = function(info) return RaidIcons.db.profile.EnabledPartyLeaderBypass end,
					set = function(info,v) RaidIcons.db.profile.EnabledPartyLeaderBypass = v end,
					name = L.options["Enable bypassing party leader"],
					desc = L.options["Enables you to automatically mark targets in 5-man dungeons regardless of being Party Leader or Dungeon Guide."],
					order = 0.2,
				},
			}
		}

		do
			local raidicons_args = raidicons_group.args

			local desc = {
				type = "description",
				name = L.options["Most encounters only use |cffffd200Preset 1|r and |cffffd200Preset 2|r. Additional icon presets are used for abilities that require multi-marking (e.g. Anub'arak's Penetrating Cold). If you change an icon, make sure all icons are different from one another"],
				order = 0.5,
			}

			raidicons_args.desc = desc

			local dropdown = {
				type = "select",
				name = function(info) return format(L.options["Color Preset %s"],info[#info]) end,
				order = function(info) return tonumber(info[#info]) end,
				width = double,
				values = {
					format(" %s (%s)",format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",1),L.options["Star"]),
                    format(" %s (%s)",format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",2),L.options["Circle"]),
                    format(" %s (%s)",format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",3),L.options["Diamond"]),
                    format(" %s (%s)",format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",4),L.options["Triangle"]),
                    format(" %s (%s)",format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",5),L.options["Moon"]),
                    format(" %s (%s)",format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",6),L.options["Square"]),
                    format(" %s (%s)",format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",7),L.options["Cross"]),
                    format(" %s (%s)",format("\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%s:12:12:0:0\124t",8),L.options["Skull"]),
				},
			}

			for i=1,8 do raidicons_args[tostring(i)] = dropdown end
		end

		alerts_args.raidicons_group = raidicons_group

	end

    ---------------------------------------------
	-- PVP
	---------------------------------------------
    do
        local PvP = addon.PvP
        local PvPScore = addon.PvPScore
        
        local pvp_group = {
			type = "group",
			name = L.options["Player vs. Player"],
			order = 250,
            childGroups = "tab",
			args = {
                ScoreFrame = {
                    type = "group",
                    name = L.options["Score Frame"],
                    order = 100,
                    get = function(info) return PvPScore.db.profile[info[#info]] end,
                    set = function(info,v) PvPScore.db.profile[info[#info]] = v;PvPScore:ScoreFrame_UpdateFrames() end,
                    args = {
                        Enabled = {
                            type = "toggle",
                            name = L.options["Show |cffffff00Score Frame|r (Hide |cffffff00WorldStateScoreFrame|r)"],
                            desc = L.options["Enables the |cffffff00Score Frame|r while hiding |cffffff00WorldStateScoreFrame|r (the Blizzard score frame)"],
                            width = "double",
                            order = 100,
                        },
                        HomeTeamLocation = {
                            type = "select",
                            name = L.options["Home Team Location"],
                            desc = L.options["Select on which side the home team is located."],
                            get = function(info) return PvP.db.profile[info[#info]] end,
                            set = function(info,v)
                                PvP.db.profile[info[#info]] = v
                                PvPScore:ScoreFrame_UpdateFrames()
                            end,
                            order = 110,
                            values = {
                                LEFT = "On the LEFT",
                                RIGHT = "On the RIGHT",
                            },
                        },
                        FactionMode = {
                            type = "select",
                            name = L.options["Faction Mode"],
                            desc = L.options["Select a way to determine the home team's 'identity'. The player's team is always the home team. Faction mode allows the home team to identify as:\n|cffffff00Current|r = The assigned side\nActual = Your real faction\n|cff007dfbAlliance|r = Always the Alliance\n|cffff0000Horde|r = Always the Horde"],
                            get = function(info) return PvP.db.profile[info[#info]] end,
                            set = function(info,v)
                                PvP.db.profile[info[#info]] = v
                                PvPScore:ScoreFrame_UpdateFrames()
                                PvP:UpdateMinimapIcons()
                            end,
                            order = 120,
                            values = {
                                CURRENT = format("|cffffff00%s|r",L.options["Current"]),
                                ACTUAL = format("|cff%s%s|r",UnitFactionGroup("player") == "Alliance" and "007dfb" or "ff0000", L.options["Actual"]),
                                ALLIANCE = format("|cff007dfb%s|r",L.options["Alliance"]),
                                HORDE = format("|cffff0000%s|r",L.options["Horde"]),
                            },
                        },
                        general_header = {
                            type = "header",
                            name = L.options["|cff00ff00General settings|r"].."\n",
                            order = 200,
                        },
                        TestScore = {
                            type = "execute",
                            order = 210,
                            name = function() return not addon:IsScoreVisible() and L.options["Show Score Frame"] or L.options["Hide Score Frame"] end,
                            desc = L.options["Toggles the Test Score Frame mode."],
                            func = function() addon:TestScore() end,
                            disabled = function() return addon:IsModuleBattleground(CE and CE.key) end,
                        },
                        Scale = {
                            type = "range",
                            name = "Scale",
                            order = 220,
                            min = 0.1,
                            max = 2,
                            step = 0.01,
                        },
                        TimerFont = {
                            order = 230,
                            type = "select",
                            name = L.options["Timer Font"],
                            desc = L.options["Font used for the Score Frame's timer text."],
                            values = SM:HashTable("font"),
                            dialogControl = "LSM30_Font",
                        },
                        score_header = {
                            type = "header",
                            name = L.options["|cff00ff00Score settings|r"].."\n",
                            order = 300,
                        },
                        ScoreTexture = {
                            type = "select",
                            order = 310,
                            name = L.options["Background Texture"],
                            desc = L.options["A texture used as a backdrop for Score Frame."],
                            values = SM:HashTable("statusbar"),
                            dialogControl = "LSM30_Statusbar",
                        },
                        ScoreBorder = {
                            order = 320,
                            type = "select",
                            name = L.options["Border"],
                            desc = L.options["A border used for Score Frame."],
                            values = SM:HashTable("border"),
                            dialogControl = "LSM30_Border",
                        },
                        ScoreBorderEdge = {
                            type = "range",
                            name = L.options["Border Edge"],
                            order = 330,
                            min = 1,
                            max = 100,
                            step = 1,
                        },
                        ScoreFont = {
                            order = 340,
                            type = "select",
                            name = L.options["Font"],
                            desc = L.options["Font used for the Score Frame's score texts."],
                            values = SM:HashTable("font"),
                            dialogControl = "LSM30_Font",
                        },
                        score_progress_bar_blank = genblank(345),
                        ScoreProgressTexture = {
                            type = "select",
                            order = 350,
                            name = L.options["Progress Background Texture"],
                            desc = L.options["A texture used as a backdrop for Score Frame."],
                            values = SM:HashTable("statusbar"),
                            dialogControl = "LSM30_Statusbar",
                        },
                        ScoreProgressAlpha = {
                            type = "range",
                            name = "Progress Background Alpha",
                            order = 360,
                            min = 0,
                            max = 1,
                            step = 0.01,
                        },
                        ShowScoreProgress = {
                            type = "toggle",
                            name = L.options["Show Score Progress"],
                            desc = L.options["Enables showing of score progress highlight."],
                            width = "double",
                            order = 370,
                        },
                        slots_header = {
                            type = "header",
                            name = L.options["|cff00ff00Slots settings|r"].."\n",
                            order = 500,
                        },
                        ShowSlots = {
                            type = "toggle",
                            name = L.options["Show Slots"],
                            desc = L.options["Enables the displaying of Score Frame slots."],
                            order = 510,
                            width = "full",
                        },
                        ScoreSlotsTexture = {
                            type = "select",
                            order = 520,
                            name = L.options["Texture"],
                            desc = L.options["A texture used as a backdrop for Score Frame slots under the score."],
                            values = SM:HashTable("statusbar"),
                            dialogControl = "LSM30_Statusbar",
                            disabled = function() return not PvPScore.db.profile.ShowSlots end,
                        },
                        ScoreSlotsBorder = {
                            order = 530,
                            type = "select",
                            name = L.options["Border"],
                            desc = L.options["A border used for Score Frame slots under the score."],
                            values = SM:HashTable("border"),
                            dialogControl = "LSM30_Border",
                            disabled = function() return not PvPScore.db.profile.ShowSlots end,
                        },
                        ScoreSlotsBorderEdge = {
                            type = "range",
                            name = L.options["Border Edge"],
                            order = 540,
                            min = 1,
                            max = 100,
                            step = 1,
                            disabled = function() return not PvPScore.db.profile.ShowSlots end,
                        },
                        ScoreSlotsFont = {
                            order = 550,
                            type = "select",
                            name = L.options["Font"],
                            desc = L.options["Font used for the Score Frame slots texts."],
                            values = SM:HashTable("font"),
                            dialogControl = "LSM30_Font",
                            disabled = function() return not PvPScore.db.profile.ShowSlots end,
                        },
                        ScoreSlotsTextureAlpha = {
                            type = "range",
                            name = "Texture Alpha",
                            order = 560,
                            min = 0,
                            max = 1,
                            step = 0.01,
                            disabled = function() return not PvPScore.db.profile.ShowSlots end,
                        },
                        ScoreSlotsBorderAlpha = {
                            type = "range",
                            name = "Border Alpha",
                            order = 570,
                            min = 0,
                            max = 1,
                            step = 0.01,
                            disabled = function() return not PvPScore.db.profile.ShowSlots end,
                        },
                        ScoreSlotBorderColor = {
                            type = "color",
                            name = L.options["Border Color"],
                            order = 580,
                            set = function(info,v,v2,v3,v4)
                                local t = PvPScore.db.profile.ScoreSlotBorderColor
                                t[1],t[2],t[3],t[4] = v,v2,v3,v4
                                PvPScore:ScoreFrame_UpdateFrames()
                            end,
                            get = function(info) return unpack(PvPScore.db.profile.ScoreSlotBorderColor) end,
                            hasAlpha = false,
                            disabled = function() return PvPScore.db.profile.ScoreBorderUpdateColors end,
                            disabled = function() return not PvPScore.db.profile.ShowSlots end,
                        },
                        ScoreBorderUpdateColors = {
                            type = "toggle",
                            name = L.options["Auto Border Color"],
                            desc = L.options["Automatically update border color same way the slot's background color is updated."],
                            order = 590,
                            disabled = function() return not PvPScore.db.profile.ShowSlots end,
                        },
                        capture_bar_header = {
                            type = "header",
                            name = L.options["|cff00ff00Caputre Bar settings|r"].."\n",
                            order = 600,
                        },
                        EnableCaptureBar = {
                            type = "toggle",
                            name = L.options["Enable Capture Bar"],
                            desc = L.options["Enables the displaying of Score Frame's |cffffff00Capture Bar|r while hiding |cffffff00WorldStateCaptureBar|r (Blizzard's default)"],
                            order = 610,
                            width = "full",
                        },
                        CaptureBarTexture = {
                            type = "select",
                            order = 620,
                            name = L.options["Texture"],
                            desc = L.options["A texture used as a backdrop for Capture Bar."],
                            values = SM:HashTable("statusbar"),
                            dialogControl = "LSM30_Statusbar",
                            disabled = function() return not PvPScore.db.profile.EnableCaptureBar end,
                        },
                        CaptureBarBorder = {
                            order = 630,
                            type = "select",
                            name = L.options["Border"],
                            desc = L.options["A border used for Capture Bar."],
                            values = SM:HashTable("border"),
                            dialogControl = "LSM30_Border",
                            disabled = function() return not PvPScore.db.profile.EnableCaptureBar end,
                        },
                        CaptureBarBorderEdge = {
                            type = "range",
                            name = L.options["Border Edge"],
                            desc = L.options["Border Edge used for Capture Bar."],
                            order = 640,
                            min = 1,
                            max = 100,
                            step = 1,
                            disabled = function() return not PvPScore.db.profile.EnableCaptureBar end,
                        },
                    },
                },
                score_slots_group = {
                    type = "group",
                    name = L.options["Score Slots"],
                    order = 200,
                    args = {
                        helpcallaction_header = {
                            type = "header",
                            name = L.options["|cff00ff00Help Call Action settings|r"].."\n",
                            order = 100,
                        },
                        helpcallaction_desc = {
                            type = "description",
                            name = L.options["Score Slots displaying the status of bases have usually a Help Call function attached to them. That means if you click on a slot with a mouse button it sends a particular chat message to the battleground chat:\n|cff00e6ffLEFT CLICK|r - Enemies INCOMING (multiple clicks specify how many, 2 clicks = 2 players)\n|cff00e6ffMIDDLE CLICK|r - Base is UNDER ATTACK\n|cff00e6ffRIGHT CLICK|r - Base is SAFE"],
                            order = 150,
                        },
                        Incoming = {
                            type = "input",
                            name = L.options["Incoming Pattern"],
                            order = 200,
                            get = function(info) return PvPScore.db.profile.Pattern[info[#info]] end,
                            set = function(info,v) PvPScore.db.profile.Pattern[info[#info]] = v end,
                            width = "full",
                        },
                        IncomingSpecific = {
                            type = "input",
                            name = L.options["Incoming (Player Specific) Pattern"],
                            order = 250,
                            get = function(info) return PvPScore.db.profile.Pattern[info[#info]] end,
                            set = function(info,v) PvPScore.db.profile.Pattern[info[#info]] = v end,
                            width = "full",
                        },
                        Safe = {
                            type = "input",
                            name = L.options["Safe Pattern"],
                            order = 300,
                            get = function(info) return PvPScore.db.profile.Pattern[info[#info]] end,
                            set = function(info,v) PvPScore.db.profile.Pattern[info[#info]] = v end,
                            width = "full",
                        },
                        UnderAttack = {
                            type = "input",
                            name = L.options["Under Attack Pattern"],
                            order = 350,
                            get = function(info) return PvPScore.db.profile.Pattern[info[#info]] end,
                            set = function(info,v) PvPScore.db.profile.Pattern[info[#info]] = v end,
                            width = "full",
                        },
                        colors_header = {
                            type = "header",
                            name = L.options["|cff00ff00Colors settings|r"].."\n",
                            order = 400,
                        },
                    },
                },
                faction_swaping_group = {
                    type = "group",
                    name = L.options["Faction Swaping"],
                    order = 150,
                    set = function(info,v) PvP.db.profile.FactionSwap[info[#info]] = v;addon.BattlegroundAPI:RefreshSlots() end,
                    get = function(info) return PvP.db.profile.FactionSwap[info[#info]] end,
                    args = {
                        WorldMapPOIs = {
                            type = "toggle",
                            name = L.options["Enable POI Swapping for |cffffff00World Map|r and |cffffff00Battlefield Minimap|r"],
                            desc = L.options["If enabled when player's effective faction is different from the preferred faction the POI icons are swapped for the other faction."],
                            width = "full",
                            order = 100,
                        },
                        Minimap = {
                            type = "toggle",
                            name = L.options["Enable POI Swapping for |cffffff00Minimap|r"],
                            desc = L.options["If enabled when player's effective faction is different from the preferred faction the POI icons are swapped for the other faction."],
                            set = function(info,v) print(info[#info]);PvP.db.profile.FactionSwap[info[#info]] = v;PvP:UpdateMinimapIcons() end,
                            width = "full",
                            order = 150,
                        },
                        BattlegroundChat = {
                            type = "toggle",
                            name = L.options["Enable Faction Swapping for |cffffff00Battleground Chat|r"],
                            desc = L.options["If enabled when player's effective faction is different from the preferred faction the words 'Alliance' and 'Horde' produced by Battleground |cff00aeefAlliance|r / |cffff0000Horde|r / |cffff780aNeutral|r chats and also boss emote frame that is used sometimes."],
                            width = "full",
                            order = 200,
                        },
                        BattlefieldScore = {
                            type = "toggle",
                            name = L.options["Enable Faction Swapping for |cffffff00Battlefield Score|r"],
                            desc = L.options["If enabled when player's effective faction is different from the preferred faction-based the values for Battlefield Score will be swapped."],
                            width = "full",
                            order = 250,
                        },
                    },
                },
                pvp_timer_group = {
                    type = "group",
                    name = L.options["Special Timers"],
                    order = 300,
                    args = {
                        rbg_invite_timer_group = {
                            type = "group",
                            name = L.options["Battleground Invitation"],
                            inline = true,
                            order = 350,
                            set = function(info,v) addon.Alerts.db.profile[info[#info]] = v;addon:RBG_RefreshBar() end,
                            get = function(info) return addon.Alerts.db.profile[info[#info]] end,
                            args = {
                                RBGTimerEnabled = {
                                    type = "toggle",
                                    name = L.options["Enabled"],
                                    width = "half",
                                    order = 100,
                                }, 
                                rbg_timer_settings_group = {
                                    type = "group",
                                    name = L.options["Options"],
                                    order = 332,
                                    disabled = function(info) return not addon.Alerts.db.profile.RBGTimerEnabled end,
                                    args = {
                                        RBGTimerMainColor = {
                                            type = "select",
                                            name = L.options["Main Color"],
                                            order = 333,
                                            handler = Alerts,
                                            values = GetColors(true),
                                        },
                                        RBGTimerFlashColor = {
                                            type = "select",
                                            name = L.options["Flash Color"],
                                            order = 334,
                                            handler = Alerts,
                                            values = GetColors(false),
                                        },
                                        RBGShowLeftIcon = {
                                            order = 340,
                                            type = "toggle",
                                            name = L.options["Show Left Icon"],
                                            desc = L.options["Shows an icon on the left side of the bar"],
                                        },
                                        RBGShowRightIcon = {
                                            order = 345,
                                            type = "toggle",
                                            name = L.options["Show Right Icon"],
                                            desc = L.options["Shows an icon on the right side of the bar"],
                                        },
                                        rbg_voice_identifier = {
                                            type = "select",
                                            name = L.options["Countdown Voice"],
                                            order = 350,
                                            width = "double",
                                            get = function()
                                                local alertsPfl = addon.Alerts.db.profile
                                                if not alertsPfl.RBGTimerAudioCDVoice or alertsPfl.RBGTimerAudioCDVoice == false then
                                                    return "#off#"
                                                elseif alertsPfl.RBGTimerAudioCDVoice == "#off#" or alertsPfl.RBGTimerAudioCDVoice == "#default#" then
                                                    return alertsPfl.RBGTimerAudioCDVoice
                                                elseif addon.Alerts.CountdownVoicesDB[alertsPfl.RBGTimerAudioCDVoice] then
                                                    return alertsPfl.RBGTimerAudioCDVoice
                                                else
                                                    return "#default#"
                                                end
                                            end,
                                            set = function(info,v) addon.Alerts.db.profile.RBGTimerAudioCDVoice = v end,
                                            values = function() 
                                                local voiceList = {}
                                                voiceList["#off#"] = format("|cffffffff%s|r","|cffffff00Disabled|r")
                                                voiceList["#default#"] = format("|cffffff00Default voice|r (%s)",addon.Alerts.db.profile.CountdownVoice)
                                                for k,v in pairs(addon.Alerts.CountdownVoicesDB) do
                                                    voiceList[k] = k
                                                end
                                                return voiceList
                                            end
                                        },
                                        TestRBGTimer = {
                                            type = "execute",
                                            name = L.options["Test RBG Timer"],
                                            desc = "Tests the RBG timer with selected options.",
                                            order = 335,
                                            func = function() 
                                                addon:ShowRBGCountdown(nil,true)
                                            end,
                                        },
                                        RBG_MutedSound = {
                                            type = "toggle",
                                            name = L.options["Master channel for |cff00ff00RBG Ready Check|r sound"],
                                            desc = L.options["Plays the |cff00ff00RBG_READY_CHECK|r sound for RBG even if you disable sounds."],
                                            order = 380,
                                        },
                                    },
                                },
                            },
                        },
                        global_res_timer_group = {
                            type = "group",
                            name = L.options["Global resurrection"],
                            inline = true,
                            order = 360,
                            set = function(info,v) addon.Alerts.db.profile[info[#info]] = v;addon.Alerts:RefreshGlobalResurrectionTimer() end,
                            get = function(info) return addon.Alerts.db.profile[info[#info]] end,
                            args = {
                                GlobalResurrectionTimerEnabled = {
                                    type = "toggle",
                                    name = L.options["Enabled"],
                                    width = "half",
                                    order = 100,
                                }, 
                                global_res_timer_settings_group = {
                                    type = "group",
                                    name = L.options["Options"],
                                    order = 100,
                                    disabled = function(info) return not addon.Alerts.db.profile.GlobalResurrectionTimerEnabled end,
                                    args = {
                                        GlobalRessurectionTimerMainColor = {
                                            type = "select",
                                            name = L.options["Main Color"],
                                            order = 100,
                                            handler = Alerts,
                                            values = GetColors(true),
                                        },
                                        GlobalRessurectionTimerFlashColor = {
                                            type = "select",
                                            name = L.options["Flash Color"],
                                            order = 200,
                                            handler = Alerts,
                                            values = GetColors(false),
                                        },
                                        GlobalRessurectionTimerFlashTime = {
                                            type = "range",
                                            name = L.options["Flashtime"],
                                            desc = L.options["Flashtime in seconds left on alert"],
                                            order = 300,
                                            min = 1,
                                            max = 60,
                                            step = 1,
                                        },
                                        global_res_blank1 = genblank(400),
                                        GlobalRessurectionTimerAudioCDVoice = {
                                            type = "select",
                                            name = L.options["Countdown Voice"],
                                            order = 500,
                                            width = "double",
                                            get = function()
                                                local alertsPfl = addon.Alerts.db.profile
                                                if not alertsPfl.GlobalRessurectionTimerAudioCDVoice or alertsPfl.GlobalRessurectionTimerAudioCDVoice == false then
                                                    return "#off#"
                                                elseif alertsPfl.GlobalRessurectionTimerAudioCDVoice == "#off#" or alertsPfl.GlobalRessurectionTimerAudioCDVoice == "#default#" then
                                                    return alertsPfl.GlobalRessurectionTimerAudioCDVoice
                                                elseif addon.Alerts.CountdownVoicesDB[alertsPfl.GlobalRessurectionTimerAudioCDVoice] then
                                                    return alertsPfl.GlobalRessurectionTimerAudioCDVoice
                                                else
                                                    return "#default#"
                                                end
                                            end,
                                            set = function(info,v) addon.Alerts.db.profile.GlobalRessurectionTimerAudioCDVoice = v end,
                                            values = function() 
                                                local voiceList = {}
                                                voiceList["#off#"] = format("|cffffffff%s|r","|cffffff00Disabled|r")
                                                voiceList["#default#"] = format("|cffffff00Default voice|r (%s)",addon.Alerts.db.profile.CountdownVoice)
                                                for k,v in pairs(addon.Alerts.CountdownVoicesDB) do
                                                    voiceList[k] = k
                                                end
                                                return voiceList
                                            end
                                        },
                                        TestGlobalResTimer = {
                                            type = "execute",
                                            name = L.options["Test Timer"],
                                            desc = "Tests the Global Resurrection timer with selected options.",
                                            order = 600,
                                            func = function() 
                                                addon.Alerts:InvokeGlobalResTimer(5)
                                            end,
                                        },
                                        
                                    },
                                },
                            },
                        },
                    },
                },
                victory_announcement_group = {
                    type = "group",
                    name = L.options["Victory Announcement"],
                    order = 400,
                    args = {
                        VictoryAnnouncementEnabled = {
                            type = "toggle",
                            name = L.options["Enable Victory Announcement"],
                            desc = L.options["Displays Victory Announcement when you win or loose a battleground."],
                            order = 100,
                            width = "full",
                            get = function(info) return PvP.db.profile[info[#info]] end,
                            set = function(info,v) PvP.db.profile[info[#info]] = v end,
                        },
                        VictoryScreenshot = {
                            type = "toggle",
                            name = L.options["Take Victory Screenshot"],
                            desc = L.options["Automatically takes a screenshot when you win a battleground."],
                            order = 200,
                            width = "full",
                            get = function(info) return PvP.db.profile[info[#info]] end,
                            set = function(info,v) PvP.db.profile[info[#info]] = v end,
                        },
                        HideVictoryFrameOnLeaving = {
                            type = "toggle",
                            name = L.options["Hide Victory Frame On Leaving Battleground"],
                            desc = L.options["Hides the Legion-style Victory Frame after you leave the battleground."],
                            order = 300,
                            width = "full",
                            get = function(info) return PvP.db.profile[info[#info]] end,
                            set = function(info,v) PvP.db.profile[info[#info]] = v end,
                        },
                    },
                },
                Features = {
                    type = "group",
                    name = L.options["Other Features"],
                    order = 500,
                    args = {
                        AutoRelease = {
                            type = "toggle",
                            name = L.options["Enable Automatic Release of Spirit"],
                            desc = L.options["Enables automatic releasing of spirit when you die during a battleground battle."],
                            order = 100,
                            width = "full",
                            get = function(info) return PvP.db.profile[info[#info]] end,
                            set = function(info,v) PvP.db.profile[info[#info]] = v end,
                        },
                        pull_header = {
                            type = "header",
                            name = L.options["|cff00ff00Battleground Start countdown|r"].."\n",
                            order = 200,
                        },
                        HideBlizzTimers = {
                            type = "toggle",
                            name = L.options["Hide Blizzard's Battleground Start Timers"],
                            desc = L.options["Hides the mini timers counting down the battleground start and also hides the big countdown."],
                            order = 210,
                            width = "full",
                            get = function(info) return PvPScore.db.profile[info[#info]] end,
                            set = function(info,v) PvPScore.db.profile[info[#info]] = v end,
                        },
                        ShowGrandCountdown = {
                            type = "toggle",
                            name = L.options["Show DXE Grand Countdown instead"],
                            desc = L.options["Shows the DXE's version of big countdown isteand of the Blizzard's which is only different in that it's missing the faction logo at the end and doesn't bug out when reloading on warm-up."],
                            order = 220,
                            width = "full",
                            get = function(info) return PvPScore.db.profile[info[#info]] end,
                            set = function(info,v) PvPScore.db.profile[info[#info]] = v end,
                            disabled = function() return not PvPScore.db.profile.HideBlizzTimers end,
                        },
                    },
                },
            }
        }
        do 
            local colorOrder = 410
            for colorName,color in pairs(PvPScore.defaults.profile.Colors) do
                pvp_group.args.score_slots_group.args[colorName] = {
                    type = "color",
                    name = format(L.options["%s (Slot Color)"],addon.util.capitalize(colorName)),
                    hasAlpha = false,
                    order = colorOrder + 1,
                    set = function(info,v,v2,v3,v4)
                        local t = PvPScore.db.profile.Colors[colorName]
                        t.r, t.g, t.b, t.a = v,v2,v3,v4
                        PvPScore:ScoreFrame_UpdateFrames()
                    end,
                    get = function(info)
                        local t = PvPScore.db.profile.Colors[colorName]
                        return t.r, t.g, t.b, t.a
                    end,
                }
                
                if PvPScore.defaults.profile.FlashColors[colorName] then
                    pvp_group.args.score_slots_group.args["flash_"..colorName] = {
                        type = "color",
                        name = format(L.options["%s (Flash Color)"],addon.util.capitalize(colorName)),
                        hasAlpha = false,
                        order = colorOrder + 2,
                        set = function(info,v,v2,v3,v4)
                            local t = PvPScore.db.profile.FlashColors[colorName]
                            t.r, t.g, t.b, t.a = v,v2,v3,v4
                            PvPScore:ScoreFrame_UpdateFrames()
                        end,
                        get = function(info)
                            local t = PvPScore.db.profile.FlashColors[colorName]
                            return t.r, t.g, t.b, t.a
                        end,
                    }
                end
                
                pvp_group.args.score_slots_group.args["reset_"..colorName] = {
                    type = "execute",
                    name = L.options["Reset"],
                    order = colorOrder,
                    func = function()
                        PvPScore.db.profile.Colors[colorName] = PvPScore.defaults.profile.Colors[colorName]
                        PvPScore.db.profile.FlashColors[colorName] = PvPScore.defaults.profile.FlashColors[colorName]
                        PvPScore:ScoreFrame_UpdateFrames()
                    end,
                    width = "half",
                }
                
                pvp_group.args.score_slots_group.args["blank_"..colorName] = genblank(colorOrder + 3)
                colorOrder = colorOrder + 10
            end
        end
        
        opts_args.pvp_group = pvp_group
    end
    
	---------------------------------------------
	-- DISTRIBUTOR
	---------------------------------------------

	do
		local list,names = {},{}
		local ListSelect,PlayerSelect
		local Distributor = addon.Distributor
		local dist_group = {
			type = "group",
			name = L.options["Distributor"],
			order = 350,
			get = function(info) return Distributor.db.profile[info[#info]] end,
			set = function(info,v) Distributor.db.profile[info[#info]] = v end,
			args = {
				AutoAccept = {
					type = "toggle",
					name = L.options["Auto accept"],
					desc = L.options["Automatically accepts encounters sent by players"],
					order = 50,
				},
				first_desc = {
					type = "description",
					order = 75,
					name = format(L.options["You can send encounters to the entire raid or to a player. You can check versions by typing |cffffd200/dxe %s|r or by opening the version checker from the pane"],L.options["version"]),
				},
				raid_desc = {
					type = "description",
					order = 90,
					name = "\n"..L.options["If you want to send an encounter to the raid, select an encounter, and then press '|cffffd200Send to raid|r'"],
				},
				ListSelect = {
					type = "select",
					order = 100,
					name = L.options["Select an encounter"],
					get = function() return ListSelect end,
					set = function(info,value) ListSelect = value end,
					values = function()
						wipe(list)
						for k in addon:IterateEDB() do list[k] = addon.EDB[k].name end
						return list
					end,
				},
				DistributeToRaid = {
					type = "execute",
					name = L.options["Send to raid"],
					order = 200,
					func = function() Distributor:Distribute(ListSelect) end,
					disabled = function() return GetNumRaidMembers() == 0 or not ListSelect  end,
				},
				player_desc = {
					type = "description",
					order = 250,
					name = "\n\n"..L.options["If you want to send an encounter to a player, select an encounter, select a player, and then press '|cffffd200Send to player|r'"],
				},
				PlayerSelect = {
					type = "select",
					order = 300,
					name = L.options["Select a player"],
					get = function() return PlayerSelect end,
					set = function(info,value) PlayerSelect = value end,
					values = function()
						wipe(names)
						for name in pairs(addon.Roster.name_to_unit) do
							if name ~= addon.PNAME then names[name] = name end
						end
						return names
					end,
					disabled = function() return GetNumRaidMembers() == 0 or not ListSelect end,
				},
				DistributeToPlayer = {
					type = "execute",
					order = 400,
					name = L.options["Send to player"],
					func = function() Distributor:Distribute(ListSelect, PlayerSelect) end,
					disabled = function() return not PlayerSelect end,
				},
			},
		}

		opts_args.dist_group = dist_group
	end
    
	---------------------------------------------
	-- WINDOWS
	---------------------------------------------

	do
		windows_group = {
			type = "group",
			name = L.options["Windows"],
			order = 290,
			childGroups = "tab",
			args = {
				TitleBarColor = {
					order = 100,
					type = "color",
					set = function(info,v,v2,v3,v4)
						local t = db.profile.Windows.TitleBarColor
						t[1],t[2],t[3],t[4] = v,v2,v3,v4
						addon:UpdateWindowSettings()
					end,
					get = function(info) return unpack(db.profile.Windows.TitleBarColor) end,
					name = L.options["Title Bar Color"],
					desc = L.options["Title bar color used throughout the addon"],
					hasAlpha = true,
				},
				Proxtype = {
					type = "select",
					order = 110,
					get = function(info) return db.profile.Windows.Proxtype end,
					set = function(info,v)
						db.profile.Windows.Proxtype = v
						addon:UpdateProximityProfile()
                        addon:UpdateDistanceLocks()
                        if addon:IsRangeShown() then 
                            addon:ShowProximity() 
                        else
                            addon:HideProximity()
                            addon:HideRadar()
                        end
                        
					end,
					name = L.options["Proximity Display"],
					desc = L.options["The type of the proximity window, radar or text-based"],
					values = {
						RADAR = L.options["Radar"],
						TEXT = L.options["Text-based"],
					},
				},
			},
		}

		opts_args.windows_group = windows_group
		local windows_args = windows_group.args

		local proximity_group = {
			type = "group",
			name = L.options["Proximity"],
			order = 150,
			get = function(info) return db.profile.Proximity[info[#info]] end,
			set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateProximityProfile() end,
            childGroups = "tab",
			args = {
				header_desc = {
					type = "description",
					order = 100,
					name = L.options["The proximity window uses map coordinates of players to calculate distances. This relies on knowing the dimensions, in game yards, of each map. If the dimension of a map is not known, it will default to the closest range rounded up to 10, 11, or 18 game yards"].."\n",
				},
                Range = {
                    type = "range",
                    order = 200,
                    name = L.options["Range"],
                    desc = L.options["The distance (game yards) a player has to be within to appear in the proximity window"],
                    min = 1,
                    max = 100,
                    step = 1,
                },
                ProximityToggle = {
					type = "execute",
					name = function() 
                        local tbl = {
                            RADAR = L.options["Radar Window"],
                            TEXT = L.options["Text-based Window"],
                        }
                        return L.options["Show "]..tbl[db.profile.Windows.Proxtype]
                    end,
					desc = L.options["Shows a proximity window."],
                    width = "double",
					order = 300,
					func = function() addon:ShowProximity() end,
				},
                general_group = {
                    name = L.options["General"],
                    type = "group",
                    order = 400,
                    args = {
                        AutoPopup = {
                            type = "toggle",
                            order = 420,
                            name = L.options["Auto Show"],
                            --desc = L.options["Automatically show the proximity window if the option is enabled in an encounter (Encounters > ... > Windows                            > Proximity)"],
                            desc = L.options["Automatically shows the proximity window when:\n- The encounter is loaded.\n- When the boss is pulled\n- During the encounter when required"],
                        },
                        AutoHide = {
                            type = "toggle",
                            order = 430,
                            name = L.options["Auto Hide"],
                            desc = L.options["Automatically hide the proximity window when an encounter is defeated"],
                        },
                        HideOnEncounterSelection = {
                            type = "toggle",
                            order = 440,
                            name = L.options["Hide on Encounter Load"],
                            desc = L.options["Automatically hide the proximity window when an encounter is loaded"],
                        },
                        Invert = {
                            type = "toggle",
                            order = 450,
                            name = L.options["Invert Bars"],
                            desc = L.options["Inverts all range bars"],
                        },
                        Dummy = {
                            type = "toggle",
                            order = 460,
                            name = L.options["Dummy Bars/Dots"],
                            desc = L.options["Displays dummy bars or dots on the radar that can be useful for configuration"],
                        },
                        Delay = {
                            type = "range",
                            order = 470,
                            name = L.options["Delay"],
                            desc = L.options["The proximity window refresh rate (seconds). Increase to improve performance. |cff99ff330|r refreshes every frame"],
                            min = 0,
                            max = 1,
                            step = 0.05,
                        },
                    },
                },
                radar_group = {
                    name = L.options["Radar settings"],
                    type = "group",
                    order = 500,
                    args = {
                        RadarAlwaysShowTitle = {
                            type = "toggle",
                            order = 540,
                            name = L.options["Always Show Title"],
                            desc = L.options["Enabled: Always shows the radar title.\nDisabled: Shows the radar title only on mouseover."],
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateWindowSettings() end,
                        },
                        RadarAlwaysShowCloseButton = {
                            type = "toggle",
                            order = 545,
                            name = L.options["Always Show Close Button"],
                            desc = L.options["Enabled: Always shows the radar close button.\nDisabled: Shows the radar close button only on mouseover."],
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateWindowSettings() end,
                        },
                        RadarHideTitleBar = {
                            type = "toggle",
                            order = 530,
                            name = L.options["Hide Title Bar"],
                            desc = L.options["Hides the radar title bar."],
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateWindowSettings() end,
                        },
                        RadarHideBackground = {
                            type = "toggle",
                            order = 520,
                            name = L.options["Hide Background"],
                            desc = L.options["Hides the radar background."],
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateWindowSettings() end,
                        },
                        RadarHideBorder = {
                            type = "toggle",
                            order = 525,
                            name = L.options["Hide Border"],
                            desc = L.options["Hides radar border."],
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateWindowSettings() end,
                        },
                        RadarBackgroundColor = {
                            type = "color",
                            order = 535,
                            name = L.options["Background Color"],
                            desc = L.options["Sets the background color for the proximity radar."],
                            hasAlpha = true,
                            set = function(info,v,v2,v3,v4)
                                local t = db.profile.Proximity.RadarBackgroundColor
                                t[1],t[2],t[3],t[4] = v,v2,v3,v4
                                addon:UpdateWindowSettings()
                            end,
                            get = function(info) return unpack(db.profile.Proximity.RadarBackgroundColor) end,
                        },
                        DotSize = {
                            type = "range",
                            order = 550,
                            name = L.options["Dot Size"],
                            desc = L.options["The size of the dots and icons in the radar window"],
                            min = 5,
                            max = 20,
                            step = 1,
                        },
                        RadarExtraDistance = {
                            type = "range",
                            order = 560,
                            name = L.options["Extra % of Distance"],
                            desc = L.options["Extra % ot detection distance under which the dots start showing on radar.\n\nPlayer will not show above 40y though."],
                            min = 0,
                            max = 500,
                            step = 1,
                        },
                        RadarNoDistanceCheckAlpha = {
                            type = "range",
                            order = 560,
                            name = L.options["No Distance Check Alpha"],
                            desc = L.options["Alpha of the Radar background when no distance checking is performed."],
                            min = 0,
                            max = 1,
                            step = 0.01,
                        },
                        RaidIcons = {
                            type = "select",
                            order = 570,
                            name = L.options["Raidicon Display"],
                            desc = L.options["Set the visibilty of raidicons: None, Above the dots, Replace the dots"],
                            values = {
                                NONE = L.options["None"],
                                ABOVE = L.options["Above"],
                                REPLACE = L.options["Replace"],
                            },
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateRadarSettings() end,
                        },
                        circles_header = {
                            type = "header",
                            name = L.options["Radar Circles"],
                            order = 700,
                        },
                        RadarCircleColorSafe = {
                            order = 710,
                            type = "color",
                            set = function(info,v,v2,v3,v4)
                                local t = db.profile.Proximity[info[#info]]
                                t[1],t[2],t[3],t[4] = v,v2,v3,v4
                            end,
                            get = function(info) return unpack(db.profile.Proximity[info[#info]]) end,
                            name = L.options["Color (safe)"],
                            desc = L.options["Color of radar circle when no player is in range."],
                            hasAlpha = true,
                        },
                        RadarCircleColorInRange = {
                            order = 720,
                            type = "color",
                            set = function(info,v,v2,v3,v4)
                                local t = db.profile.Proximity[info[#info]]
                                t[1],t[2],t[3],t[4] = v,v2,v3,v4
                            end,
                            get = function(info) return unpack(db.profile.Proximity[info[#info]]) end,
                            name = L.options["Color (under threshold)"],
                            desc = L.options["Color of radar circle when less than necessary players are in range."],
                            hasAlpha = true,
                        },
                        RadarCircleColorDanger = {
                            order = 730,
                            type = "color",
                            set = function(info,v,v2,v3,v4)
                                local t = db.profile.Proximity[info[#info]]
                                t[1],t[2],t[3],t[4] = v,v2,v3,v4
                            end,
                            get = function(info) return unpack(db.profile.Proximity[info[#info]]) end,
                            name = L.options["Color (over threshold)"],
                            desc = L.options["Color of radar circle when too many players are in range."],
                            hasAlpha = true,
                        },
                    },
                },
                proxi_group = {
                    name = L.options["Text-based settings"],
                    type = "group",
                    order = 600,
                    args = {
                        ProximityAlwaysShowTitle = {
                            type = "toggle",
                            order = 635,
                            name = L.options["Always Show Title"],
                            desc = L.options["Enabled: Always shows the proximity window title.\nDisabled: Shows the proximity window title only on mouseover."],
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateWindowSettings() end,
                        },
                        ProximityAlwaysShowCloseButton = {
                            type = "toggle",
                            order = 640,
                            name = L.options["Always Show Close Button"],
                            desc = L.options["Enabled: Always shows the proximity window close button.\nDisabled: Shows the proximity window close button only on mouseover."],
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateWindowSettings() end,
                        },
                        ProximityHideTitleBar = {
                            type = "toggle",
                            order = 625,
                            name = L.options["Hide Title Bar"],
                            desc = L.options["Hides the proximity window title bar."],
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateWindowSettings() end,
                        },
                        ProximityHideBackground = {
                            type = "toggle",
                            order = 615,
                            name = L.options["Hide Background"],
                            desc = L.options["Hides the proximity window background."],
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateWindowSettings() end,
                        },
                        ProximityHideBorder = {
                            type = "toggle",
                            order = 620,
                            name = L.options["Hide Border"],
                            desc = L.options["Hides the proximity window border."],
                            get = function(info) return db.profile.Proximity[info[#info]] end,
                            set = function(info,v) db.profile.Proximity[info[#info]] = v; addon:UpdateWindowSettings() end,
                        },
                        ProximityBackgroundColor = {
                            type = "color",
                            order = 630,
                            name = L.options["Background Color"],
                            desc = L.options["Sets the background color for the proximity radar."],
                            hasAlpha = true,
                            set = function(info,v,v2,v3,v4)
                                local t = db.profile.Proximity.ProximityBackgroundColor
                                t[1],t[2],t[3],t[4] = v,v2,v3,v4
                                addon:UpdateWindowSettings()
                            end,
                            get = function(info) return unpack(db.profile.Proximity.ProximityBackgroundColor) end,
                        },
                        Rows = {
                            type = "range",
                            order = 645,
                            name = L.options["Rows"],
                            desc = L.options["The number of bars to show"],
                            min = 1,
                            max = 15,
                            step = 1,
                        },
                        BarAlpha = {
                            type = "range",
                            order = 650,
                            name = L.options["Bar Alpha"],
                            desc = L.options["Adjust the transparency of range bars"],
                            min = 0.1,
                            max = 1,
                            step = 0.1,
                        },
                        
                        IconPosition = {
                            type = "select",
                            order = 655,
                            name = L.options["Icon Position"],
                            desc = L.options["The position of the class icon"],
                            values = {
                                LEFT = L.options["Left"],
                                RIGHT = L.options["Right"],
                            },
                        },
                        NameFontSize = {
                            order = 660,
                            type = "range",
                            name = L.options["Name Font Size"],
                            desc = L.options["Select a font size used on name text"],
                            min = 7,
                            max = 30,
                            step = 1,
                        },
                        NameOffset = {
                            order = 665,
                            type = "range",
                            name = L.options["Name Horizontal Offset"],
                            desc = L.options["The horizontal position of name text"],
                            min = -175,
                            max = 175,
                            step = 1,
                        },
                        NameAlignment = {
                            order = 670,
                            type = "select",
                            name = L.options["Name Alignment"],
                            desc = L.options["The text alignment of the name text"],
                            values = {
                                LEFT = L.options["Left"],
                                CENTER = L.options["Center"],
                                RIGHT = L.options["Right"],
                            },
                        },
                        TimeFontSize = {
                            order = 675,
                            type = "range",
                            name = L.options["Distance Font Size"],
                            desc = L.options["Select a font size used on time text"],
                            min = 7,
                            max = 30,
                            step = 1,
                        },
                        TimeOffset = {
                            order = 680,
                            type = "range",
                            name = L.options["Distance Horizontal Offset"],
                            desc = L.options["The horizontal position of time text"],
                            min = -220,
                            max = 175,
                            step = 1,
                        },
                    },
                },
                classfilter_group = {
                    name = L.options["Class Filter"],
                    type = "group",
                    order = 700,
                    args = {
                        ClassFilter = {
                            type = "multiselect",
                            order = 720,
                            name = function() return "" end,
                            get = function(info,v) return db.profile.Proximity.ClassFilter[v] end,
                            set = function(info,v,v2) db.profile.Proximity.ClassFilter[v] = v2 end,
                            values = LOCALIZED_CLASS_NAMES_MALE,
                        }, 
                    },
                },
                             				
			},
		}

		windows_args.proximity_group = proximity_group

		local alternatepower_group = {
			type = "group",
			name = L.options["AlternatePower"],
			order = 250,
			get = function(info) return db.profile.AlternatePower[info[#info]] end,
			set = function(info,v) db.profile.AlternatePower[info[#info]] = v; addon:UpdateAlternatePowerSettings() end,
            childGroups = "tab",
			args = {
				header_desc = {
					type = "description",
					order = 110,
					name = L.options["The alternate power window tracks the 'alternate power' of players for certain fights ie- Cho'gall and Atremedes"].."\n",
				},
                AltPowerToggle = {
					type = "execute",
					name = L.options["Show Window"],
					desc = L.options["Shows an alternate power window."],
					order = 120,
					func = function() addon:ShowAlternatePower() end,
				},
                alternative_toggles_header = {
                    type = "header",
                    name = L.options["Toggles settings"],
                    order = 210,
                },
                AutoPopup = {
                    type = "toggle",
                    order = 220,
                    name = L.options["Auto Popup"],
                    desc = L.options["Automatically show the alternate power window if the option is enabled in an encounter (Encounters > ... > Windows > AlternatePower)"],
                },
                AutoHide = {
                    type = "toggle",
                    order = 230,
                    name = L.options["Auto Hide"],
                    desc = L.options["Automatically hide the alternate power window when an encounter is defeated"],
                },
                HideOnEncounterSelection = {
                    type = "toggle",
                    order = 240,
                    name = L.options["Hide on Encounter Load"],
                    desc = L.options["Automatically hide the proximity window when an encounter is loaded"],
                },
                Invert = {
                    type = "toggle",
                    order = 250,
                    name = L.options["Invert Bars"],
                    desc = L.options["Inverts all power bars"],
                },
                Dummy = {
                    type = "toggle",
                    order = 260,
                    name = L.options["Dummy Bars"],
                    desc = L.options["Displays dummy bars that can be useful for configuration"],
                },
                alternative_general_header = {
                    type = "header",
                    name = L.options["General settings"],
                    order = 310,
                },
                AlwaysShowTitle = {
                    type = "toggle",
                    order = 335,
                    name = L.options["Always Show Title"],
                    desc = L.options["Enabled: Always shows alternate power window title.\nDisabled: Shows alternate power window title only on mouseover."],
                    get = function(info) return db.profile.AlternatePower[info[#info]] end,
                    set = function(info,v) db.profile.AlternatePower[info[#info]] = v; addon:UpdateWindowSettings() end,
                },
                AlwaysShowCloseButton = {
                    type = "toggle",
                    order = 340,
                    name = L.options["Always Show Close Button"],
                    desc = L.options["Enabled: Always shows alternate power window close button.\nDisabled: Shows alternate power window close button only on mouseover."],
                    get = function(info) return db.profile.AlternatePower[info[#info]] end,
                    set = function(info,v) db.profile.AlternatePower[info[#info]] = v; addon:UpdateWindowSettings() end,
                },
                HideTitleBar = {
                    type = "toggle",
                    order = 325,
                    name = L.options["Hide Title Bar"],
                    desc = L.options["Hides alternate power window title bar."],
                    get = function(info) return db.profile.AlternatePower[info[#info]] end,
                    set = function(info,v) db.profile.AlternatePower[info[#info]] = v; addon:UpdateWindowSettings() end,
                },
                HideBackground = {
                    type = "toggle",
                    order = 315,
                    name = L.options["Hide Background"],
                    desc = L.options["Hides alternate power window background."],
                    get = function(info) return db.profile.AlternatePower[info[#info]] end,
                    set = function(info,v) db.profile.AlternatePower[info[#info]] = v; addon:UpdateWindowSettings() end,
                },
                HideBorder = {
                    type = "toggle",
                    order = 320,
                    name = L.options["Hide Border"],
                    desc = L.options["Hides alternate power window border."],
                    get = function(info) return db.profile.AlternatePower[info[#info]] end,
                    set = function(info,v) db.profile.AlternatePower[info[#info]] = v; addon:UpdateWindowSettings() end,
                },
                BackgroundColor = {
                    type = "color",
                    order = 330,
                    name = L.options["Background Color"],
                    desc = L.options["Sets the background color for the alternate power window."],
                    hasAlpha = true,
                    set = function(info,v,v2,v3,v4)
                        local t = db.profile.AlternatePower.BackgroundColor
                        t[1],t[2],t[3],t[4] = v,v2,v3,v4
                        addon:UpdateWindowSettings()
                    end,
                    get = function(info) return unpack(db.profile.AlternatePower.BackgroundColor) end,
                },
				Threshold = {
                    type = "range",
                    order = 350,
                    name = L.options["Power Threshold"],
                    desc = L.options["A minimum amount of alternate power a player must have to be displayed."],
                    min = 1,
                    max = 99,
                    step = 1,
                },
                Delay = {
                    type = "range",
                    order = 360,
                    name = L.options["Delay"],
                    desc = L.options["The alternatePower window refresh rate (seconds). Increase to improve performance. |cff99ff330|r refreshes every frame"],
                    min = 0,
                    max = 1,
                    step = 0.05,
                },
                BarAlpha = {
                    type = "range",
                    order = 370,
                    name = L.options["Bar Alpha"],
                    desc = L.options["Adjust the transparency of range bars"],
                    min = 0.1,
                    max = 1,
                    step = 0.1,
                },
                Rows = {
                    type = "range",
                    order = 380,
                    name = L.options["Rows"],
                    desc = L.options["The number of bars to show"],
                    min = 1,
                    max = 15,
                    step = 1,
                },
                IconPosition = {
                    type = "select",
                    order = 390,
                    name = L.options["Icon Position"],
                    desc = L.options["The position of the class icon"],
                    values = {
                        LEFT = L.options["Left"],
                        RIGHT = L.options["Right"],
                    },
                },
                alternative_text_header = {
                    type = "header",
                    name = L.options["Text settings"],
                    order = 410,
                },
                NameFontSize = {
                    order = 420,
                    type = "range",
                    name = L.options["Name Font Size"],
                    desc = L.options["Select a font size used on name text"],
                    min = 7,
                    max = 30,
                    step = 1,
                },
                NameOffset = {
                    order = 430,
                    type = "range",
                    name = L.options["Name Horizontal Offset"],
                    desc = L.options["The horizontal position of name text"],
                    min = -175,
                    max = 175,
                    step = 1,
                },
                NameAlignment = {
                    order = 440,
                    type = "select",
                    name = L.options["Name Alignment"],
                    desc = L.options["The text alignment of the name text"],
                    values = {
                        LEFT = L.options["Left"],
                        CENTER = L.options["Center"],
                        RIGHT = L.options["Right"],
                    },
                },
                blank = genblank(445),
                TimeFontSize = {
                    order = 450,
                    type = "range",
                    name = L.options["Power Font Size"],
                    desc = L.options["Select a font size used on power text"],
                    min = 7,
                    max = 30,
                    step = 1,
                },
                TimeOffset = {
                    order = 460,
                    type = "range",
                    name = L.options["Power Horizontal Offset"],
                    desc = L.options["The horizontal position of power text"],
                    min = -220,
                    max = 175,
                    step = 1,
                },
                alternative_classfilter_header = {
                    type = "header",
                    name = L.options["Class Filter settings"],
                    order = 510,
                },
				ClassFilter = {
					type = "multiselect",
					order = 520,
					name = function() return "" end,
					get = function(info,v) return db.profile.AlternatePower.ClassFilter[v] end,
					set = function(info,v,v2) db.profile.AlternatePower.ClassFilter[v] = v2 end,
					values = LOCALIZED_CLASS_NAMES_MALE,
				},
			},
		}

		windows_args.alternatepower_group = alternatepower_group
	end

	---------------------------------------------
	-- SOUNDS
	---------------------------------------------

	do
		local sounds = {}
		-- Same function at the very top of this function, without adding None
		local function GetSounds()
			table.wipe(sounds)
			for id,name in pairs(db.profile.Sounds) do
				-- if id:find("^ALERT") or id == "VICTORY" then sounds[id] = id end
                sounds[id] = format("|cff00ff00%s|r",id)
			end
			for id,name in pairs(db.profile.CustomSounds) do
				sounds[id] = format("|cff2fbbff%s|r",id)
			end
			return sounds
		end


		local label = "ALERT1"
		local add_sound_label = ""
		local remove_sound_label = ""
		local remove_list = {}
        local SelectedEncounter
		local EncounterList = {}
        
		local sound_defaults = addon.defaults.profile.Sounds
        local customSoundFile_URL = ""
        local customSoundFile_Label = ""
        local customSoundFile_Selected = ""
        
		local sounds_group = {
			type = "group",
			name = L.options["Sounds"],
			order = 295,
            childGroups = "tab",
			args = {               
				--[[sounds_group = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 100,
                    set = SetNoRefresh,
                    --childGroups = "tab",
                    args = {]]
                        sound_general_group = {
                            type = "group",
                            name = L.options["General"],
                            order = 100,
                            args = {
                                sound_general_header = {
                                    type = "header",
                                    name = L.options["General settings"],
                                    order = 120,
                                },
                                DisableSounds = {
                                    order = 140,
                                    type = "toggle",
                                    name = L.options["Mute all"],
                                    desc = L.options["Silences all the DXE sounds"],
                                    get = function() return addon.Alerts.db.profile.DisableSounds end,
                                    set = function(info, v) addon.Alerts.db.profile.DisableSounds = v end,
                                },
                                SoundOutputChannel = {
                                    type = "select",
                                    order = 160,
                                    name = L.options["Output Sound Channel"],
                                    desc = L.options["Select the sound channel that will be used to output the alert and arrow sounds.\n\n|cff00ff00A TIP:|r Master plays the sounds even with the game sounds disabled."],
                                    values = {
                                        Master = L.options["Master"],
                                        SFX = L.options["Sound Effects"],
                                        Ambience = L.options["Ambience"],
                                        Music = L.options["Music"],
                                    },
                                    get = function() return addon.Alerts.db.profile.SoundOutputChannel end,
                                    set = function(info, v) addon.Alerts.db.profile.SoundOutputChannel = v end,
                                },
                                ---------------------------------------------------------------------------------------------
                                sound_label_assoc_header = {
                                    type = "header",
                                    name = L.options["Sound Label / Sound File association"],
                                    order = 200,
                                },
                                sound_label_assoc_desc1 = {
                                    type = "description",
                                    name = L.options["You can change the sound labels (ALERT1, ALERT2, etc.) to any sound file in SharedMedia. First, select one to change"].."\n",
                                    order = 210,
                                },
                                identifier = {
                                    type = "select",
                                    name = L.options["Sound Label"],
                                    order = 220,
                                    get = function() return label end,
                                    set = function(info,v) label = v end,
                                    values = GetSounds,
                                },
                                sound_equals1 = {
                                    type = "description",
                                    name = "|TInterface\\MONEYFRAME\\Arrow-Right-Down.blp:12:12:32:0:16:16|t",
                                    fontSize = "large",
                                    order = 230,
                                    width = "half",
                                },
                                choose = {
                                    name = function() return format(L.options["Sound File for %s"],label) end,
                                    order = 240,
                                    type = "select",
                                    get = function(info) return sound_defaults[label] and db.profile.Sounds[label] or db.profile.CustomSounds[label] end,
                                    set = function(info,v)
                                        if sound_defaults[label] then
                                            db.profile.Sounds[label] = v
                                        else
                                            db.profile.CustomSounds[label] = v
                                        end
                                    end,
                                    dialogControl = "LSM30_Sound",
                                    values = function() 
                                        local soundList = {}
                                        if addon.SM:HashTable("sound") then
                                            for fileName,fileURL in pairs(addon.SM:HashTable("sound")) do
                                                soundList[fileName] = fileURL
                                            end
                                        end
                                        if db.profile.CustomSoundFiles then
                                            for fileName,fileURL in pairs(db.profile.CustomSoundFiles) do
                                                if not soundList[fileName] then
                                                    soundList[fileName] = fileURL
                                                end
                                            end
                                        end
                                        return soundList
                                    end,
                                },
                                reset = {
                                    type = "execute",
                                    name = L.options["Reset to default"],
                                    desc = L.options["Sets the selected sound label back to its default value"],
                                    func = function()
                                        if sound_defaults[label] then
                                            db.profile.Sounds[label] = sound_defaults[label]
                                        else
                                            db.profile.CustomSounds[label] = "None"
                                        end
                                    end,
                                    order = 250
                                },
                                sound_label_assoc_desc2 = {
                                    type = "description",
                                    name = "\n"..L.options["|cff00ff00SYSTEM LABELS|r - are always colored green and are named in uppercase."]
                                            .."\n"..L.options["|cff2fbbffCustom labels|r - are colored blue and are named by the user."]
                                            .."\n"..L.options["Now change the sound to what you want. Sounds can be tested by clicking on the speaker icons within the dropdown"].."\n",
                                    order = 260,
                                },
                                ----------------------------------------------------------------------------------------------
                                sound_voices_countdown_header = {
                                    type = "header",
                                    name = L.options["Countdown Voices"],
                                    order = 300,
                                },
                                voice_identifier = {
                                    type = "select",
                                    name = L.options["Default Countdown Voice"],
                                    desc = L.options["Sets the default countdown voice for all timers set to the default countdown voice."],
                                    order = 310,
                                    width = "double",
                                    get = function()
                                        local alertsPfl = addon.Alerts.db.profile
                                        if addon.Alerts.CountdownVoicesDB[alertsPfl.CountdownVoice] then
                                            return alertsPfl.CountdownVoice
                                        else
                                            return "#default#"
                                        end
                                    end,
                                    set = function(info,v) addon.Alerts.db.profile.CountdownVoice = v end,
                                    values = function() 
                                        local voiceList = {}
                                        if not addon.Alerts.CountdownVoicesDB[addon.Alerts.db.profile.CountdownVoice] then
                                            local defaultValue = format("|cffffff00Default:|r %s (|cffff0000%s|r not found)",addon.Alerts.defaults.profile.CountdownVoice,addon.Alerts.db.profile.CountdownVoice)
                                            voiceList["#default#"] = defaultValue
                                        end
                                        for k,v in pairs(addon.Alerts.CountdownVoicesDB) do
                                            voiceList[k] = k
                                        end
                                        return voiceList
                                    end
                                },
                                voice_countdown_test = {
                                    type = "execute",
                                    name = L.options["Test AudioCD"],
                                    order = 320,
                                    func = function()
                                        addon.Alerts:QuashByPattern("audiocdtest")
                                        local time = addon:GetCountdownMax() or 5
                                        addon.Alerts:Dropdown("audiocdtest","Audio Countdown Test",time,time,"None","LIGHTBLUE","CYAN",false,addon.ST[80353],true)
                                    end,
                                },
                            },
                        },
                        sound_custom_group = {
                            type = "group",
                            name = L.options["Custom sounds"],
                            order = 200,
                            args = {
                                sound_label_header = {
                                    type = "header",
                                    name = L.options["Custom Sound Labels"],
                                    order = 300,
                                },
                                add_desc = {
                                    type = "description",
                                    name = L.options["You can add your own sound label. Each sound label is associated with a certain sound file. Consult SharedMedia's documentation if you would like to add your own sound file. After adding a sound label, it will appear in the Sound Label list. You can then select a sound file to associate with it. Subsequently, the sound label will be available in the encounter options"],
                                    order = 310,
                                },
                                sound_label_input = {
                                    type = "input",
                                    name = L.options["Label name"],
                                    order = 320,
                                    get = function(info) return add_sound_label end,
                                    set = function(info,v) 
                                        if not db.profile.CustomSounds[v] then
                                            add_sound_label = v
                                        else
                                            add_sound_label = v
                                            addon:Print("Label |cffffff00"..v.."|r is already defined among |cff00ff00Custom Sound Labels.|r")
                                        end
                                    end,
                                },
                                sound_label_add = {
                                    type = "execute",
                                    name = L.options["Add"],
                                    order = 330,
                                    func = function()
                                        db.profile.CustomSounds[add_sound_label] = "None"
                                        label = add_sound_label
                                        remove_sound_label = label
                                        add_sound_label = ""
                                    end,
                                    disabled = function() return add_sound_label == "" or db.profile.CustomSounds[add_sound_label] end
                                },
                                sound_label_list = {
                                    type = "select",
                                    order = 350,
                                    name = L.options["Custom Sound Labels"],
                                    get = function()
                                        return remove_sound_label
                                    end,
                                    set = function(info,v)
                                        remove_sound_label = v
                                    end,
                                    values = function()
                                        table.wipe(remove_list)
                                        for k,v in pairs(db.profile.CustomSounds) do remove_list[k] = format("|cff2fbbff%s|r",k) end
                                        return remove_list
                                    end,
                                },
                                sound_label_remove = {
                                    type = "execute",
                                    name = L.options["Remove"],
                                    order = 360,
                                    func = function()
                                        db.profile.CustomSounds[remove_sound_label] = nil
                                        if label == remove_sound_label then
                                            label = "ALERT1"
                                        end
                                        remove_sound_label = ""
                                    end,
                                    disabled = function() return remove_sound_label == "" end,
                                },
                                custom_sound_files_header = {
                                    type = "header",
                                    name = L.options["Custom Sound Files"],
                                    order = 400,
                                },
                                custom_sound_files_desc1 = {
                                    type = "description",
                                    name = L.options["You can add a custom sound file to the Sound File list by inputting its URL within the game's directory or SoundKitID structure.\nE.g. 1: |cff04c7ffPvP FlagTaken|r sound file has a URL |cffffff00Sound\\Spells\\PVPFlagTaken.wav|r\nE.g. 2: |cff04c7ffPVPFlagTakenHordeMono|r sound file has a SoundKitID |cffffff009379|r (can be found on WoWHead.com)"],
                                    order = 410,
                                    fontSize = "medium",
                                    width = "full",
                                },
                                custom_sound_file_name = {
                                    type = "input",
                                    name = L.options["File label"],
                                    desc = L.options["Label used in the Sound File list. You can use a different name than the file name itsself."],
                                    order = 420,
                                    get = function(info) return customSoundFile_Label end,
                                    set = function(info,v)
                                        if not db.profile.CustomSoundFiles then
                                            db.profile.CustomSoundFiles = {}
                                        end
                                        local soundList = addon.SM:HashTable("sound")
                                        if soundList[v] then
                                            addon:Print("Label |cffffff00"..v.."|r is already defined among |cff00ff00SharedMedia|r.")
                                        elseif db.profile.CustomSoundFiles[v] then
                                            customSoundFile_Label = v
                                            customSoundFile_URL = db.profile.CustomSoundFiles[v]
                                            customSoundFile_Selected = v
                                        else
                                            customSoundFile_Label = v
                                        end
                                    end,
                                },
                                custom_sound_file_url = {
                                    type = "input",
                                    name = L.options["File URL / SoundKitID"],
                                    order = 430,
                                    width = "double",
                                    get = function(info) return customSoundFile_URL end,
                                    set = function(info,v)
                                        local soundList = addon.SM:HashTable("sound")
                                        local customSoundList = db.profile.CustomSoundFiles
                                        customSoundFile_URL = v
                                        if soundList then
                                            for fileName,fileURL in pairs(soundList) do
                                                if customSoundFile_URL == fileURL then
                                                       addon:Print(format("\124cffffff00%s\124r is already mapped to a label \124cffffff00%s (\124cff00ff00%s\124r)!\124r",v, fileName,"SharedMedia"))
                                                end
                                            end
                                        end
                                        if customSoundList then
                                            for fileName,fileURL in pairs(customSoundList) do
                                                if customSoundFile_URL == fileURL then
                                                       addon:Print(format("\124cffffff00%s\124r is already mapped to a label \124cffffff00%s (\124cff00ff00%s\124r)!\124r",v, fileName,"Custom Sound Files"))
                                                end
                                            end
                                        end
                                    end,
                                },
                                custom_sound_file_play = {
                                    order = 440,
                                    type = "execute",
                                    name = L.options["Play"],
                                    desc = L.options["Plays the sound given by the URL or SoundKitID."],
                                    func = function(info)
                                        if(type(tonumber(customSoundFile_URL)) == "number") then
                                            PlaySoundKitID(tonumber(customSoundFile_URL),"Master")
                                        else
                                            PlaySoundFile(customSoundFile_URL,"Master")
                                        end
                                    end,
                                    disabled = function() return customSoundFile_URL == "" end,
                                },
                                custom_sound_file_blank1 = genblank(445),
                                custom_sound_file_add = {
                                    order = 450,
                                    type = "execute",
                                    --name = L.options["Add to the list"],
                                    name = function() if db.profile.CustomSoundFiles[customSoundFile_Label] then
                                            return L.options["Save"]
                                        else
                                            return L.options["Add to the list"]
                                        end
                                    end,
                                    desc = L.options["Adds the custom file to the Sound Files list."],
                                    func = function()
                                        local soundList = addon.SM:HashTable("sound")
                                        if not db.profile.CustomSoundFiles then db.profile.CustomSoundFiles = {} end
                                        local customSoundList = db.profile.CustomSoundFiles
                                        customSoundList[customSoundFile_Label] = customSoundFile_URL
                                        customSoundFile_Selected = customSoundFile_Label
                                        customSoundFile_Label = ""
                                        customSoundFile_URL = ""
                                    end,
                                    disabled = function() return customSoundFile_URL == "" or customSoundFile_Label == "" end,
                                },
                                custom_sound_equals1 = {
                                    type = "description",
                                    name = "|TInterface\\MONEYFRAME\\Arrow-Right-Down.blp:12:12:80:0:16:16|t",
                                    fontSize = "large",
                                    order = 460,
                                    width = "fill",
                                },
                                custom_sound_file_list = {
                                    type = "select",
                                    order = 470,
                                    name = L.options["Custom Sound Files"],
                                    get = function() return customSoundFile_Selected end,
                                    set = function(info,v) 
                                        customSoundFile_Selected = v
                                        customSoundFile_Label = v
                                        customSoundFile_URL = db.profile.CustomSoundFiles[v]
                                    end,
                                    values = function() return db.profile.CustomSoundFiles end,
                                    dialogControl = "LSM30_Sound",
                                },
                                custom_sound_file_remove = {
                                    type = "execute",
                                    name = L.options["Remove"],
                                    order = 480,
                                    func = function()
                                        for k,v in pairs(db.profile.Sounds) do
                                            if v == customSoundFile_Selected then
                                                 if sound_defaults[k] then
                                                    db.profile.Sounds[k] = sound_defaults[k]
                                                    addon:Print(format("Sound label \124cffffff00%s\124r has been reset to \124cffffff00%s\124r",k,sound_defaults[k]))
                                                else
                                                    db.profile.CustomSounds[k] = "None"
                                                    addon:Print(format("Custom Sound label \124cffffff00%s\124r has been reset to \124cffffff00%s\124r",k,"\"None\""))
                                                end
                                            end
                                        end
                                        for k,v in pairs(db.profile.CustomSounds) do
                                            if v == customSoundFile_Selected then
                                                db.profile.CustomSounds[k] = "None"
                                                addon:Print(format("Custom Sound label \124cffffff00%s\124r has been reset to \124cffffff00%s\124r",k,"\"None\""))
                                            end
                                        end
                                        db.profile.CustomSoundFiles[customSoundFile_Selected] = nil
                                        customSoundFile_Selected = ""
                                    end,
                                    disabled = function() return customSoundFile_Selected == "" end,
                                    confirm = true,
                                    confirmText = format("Are you sure you want to remove %s from the Custom Sound Files list? All Sound Labels mapped to the file will be reset to their default values.",customSoundFile_Selected),
                                },
                            },
                        },
                        sound_encounters_group = {
                            type = "group",
                            name = L.options["Encounters"],
                            order = 300,
                            args = {
                                bulk_sound_mod_header = {
                                    type = "header",
                                    name = L.options["Bulk encounter profile modifications"],
                                    order = 500,
                                },
                                bulk_sound_mod_desc1 = {
                                    type = "description",
                                    name = L.options["All alerts & arrows sound settings: "],
                                    order = 510,
                                    fontSize = "medium",
                                    width = "double",
                                },
                                DisableAll = {
                                    order = 520,
                                    type = "execute",
                                    name = L.options["Set to 'None'"],
                                    desc = L.options["Sets the sound of every alert and arrow to None.\n\nThis affects currently loaded encounters!"],
                                    func = function()
                                        for key,tbl in pairs(db.profile.Encounters) do
                                            for var,stgs in pairs(tbl) do
                                                if stgs.sound then stgs.sound = "None" end
                                            end
                                        end
                                    end,
                                    confirm = true,
                                },
                                SelectedEncounter = {
                                    order = 530,
                                    type = "select",
                                    width = "double",
                                    name = L.options["Select encounter (from the list of loaded encounters)"],
                                    desc = L.options["The encounter to change"],
                                    get = function() return SelectedEncounter end,
                                    set = function(info,value) SelectedEncounter = value end,
                                    values = function()
                                        wipe(EncounterList)
                                        for k in addon:IterateEDB() do
                                            EncounterList[k] = addon.EDB[k].name
                                        end
                                        return EncounterList
                                    end,
                                },
                                DisableSelected = {
                                    order = 540,
                                    type = "execute",
                                    name = L.options["Mute selected"],
                                    desc = L.options["Sets every alert's sound in the selected encounter to None"],
                                    disabled = function() return not SelectedEncounter end,
                                    confirm = true,
                                    func = function()
                                        for var,stgs in pairs(db.profile.Encounters[SelectedEncounter]) do
                                            if stgs.sound then stgs.sound = "None" end
                                        end
                                    end,
                                },
                                ResetSelected = {
                                    order = 550,
                                    type = "execute",
                                    name = L.options["Reset selected"],
                                    desc = L.options["Resets sound for every alert and arrow in the selected encounter to its default sound."],
                                    disabled = function() return not SelectedEncounter end,
                                    confirm = true,
                                    func = function()
                                        for var,stgs in pairs(db.profile.Encounters[SelectedEncounter]) do
                                            if stgs.sound then
                                                for optionType,optionInfo in pairs(addon.EncDefaults) do
                                                    if addon.EDB[SelectedEncounter][optionType] and addon.EDB[SelectedEncounter][optionType][var] then
                                                        stgs.sound = addon.EDB[SelectedEncounter][optionType][var].sound or "None"
                                                        break
                                                    end
                                                end

                                            end
                                        end
                                    end,
                                },
                                bulk_sound_mod_desc2 = {
                                    type = "description",
                                    name = L.options["With this tool you can modify all sounds in a specific encounter."].."\n",
                                    order = 560,
                                },
                            },
                        },
                    --},
                --},
			},
		}
		opts_args.sounds_group = sounds_group
	end
   
	---------------------------------------------
	-- DEBUG
	---------------------------------------------
  
	--[===[@debug@
	local debug_group = {
		type = "group",
		order = -2,
		name = "Debug",
		args = {},
	}
	opts_args.debug_group = debug_group
	addon:AddDebugOptions(debug_group.args)
	--@end-debug@]===]
    
end

---------------------------------------------
-- INITIALIZATION
---------------------------------------------

function module:OnInitialize()
	db = addon.db
	InitializeOptions()
	InitializeOptions = nil
	self:FillEncounters()

	opts_args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(db)
	if addon.LDS then addon.LDS:EnhanceOptions(opts_args.profile,db) end
	opts_args.profile.order = -10

	AC:RegisterOptionsTable("DXE", opts)
	ACD:SetDefaultSize("DXE", DEFAULT_WIDTH, DEFAULT_HEIGHT)
    ACD:SelectGroup("DXE","encs_group")
end

function module:ToggleConfig() ACD[ACD.OpenFrames.DXE and "Close" or "Open"](ACD,"DXE") end
