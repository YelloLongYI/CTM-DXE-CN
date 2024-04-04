local addon = DXE

local SM = addon.SM
local Media = {}
addon.Media = Media


-------------------------
-- DB
-------------------------

local pfl
local function RefreshProfile(db) 
	pfl = db.profile 
	addon:NotifyAllMedia()
end
addon:AddToRefreshProfile(RefreshProfile)

-------------------------
-- Colors
-------------------------

do
	local Colors = {
    -- [r,g,b] standard colors, [sr,sg,sb] spark colors
        BLACK =         {r=0,       g=0,      b=0,     sr=1,    sg=1,      sb=1},
        BLUE =          {r=0,       g=0,      b=1,     sr=0,    sg=0.51,   sb=1},
        BROWN =         {r=.65,     g=.165,   b=.165,  sr=1,    sg=1,      sb=0},
        CYAN =          {r=0,       g=1,      b=1,     sr=0,    sg=1,      sb=1},
        DCYAN =         {r=0,       g=.6,     b=.6,    sr=0,    sg=1,      sb=1},
        GOLD =          {r=1,       g=0.843,  b=0,     sr=1,    sg=1,      sb=1},
        LIGHTBLUE =     {r=0,       g=0.51,   b=1,     sr=0,    sg=0.51,   sb=1},
        LIGHTGREEN =    {r=0,       g=1,      b=0,     sr=0,    sg=1,      sb=0},
        GREEN =         {r=0,       g=0.5,    b=0,     sr=0,    sg=1,      sb=0},
        GREY =          {r=.3,      g=.3,     b=.3,    sr=0.5,  sg=0.5,    sb=0.5},
        INDIGO =        {r=0,       g=0.25,   b=0.71,  sr=0,    sg=0.5,    sb=1},
        MAGENTA =       {r=1,       g=0,      b=1,     sr=1,    sg=0,      sb=1},
        MIDGREY =       {r=.5,      g=.5,     b=.5,    sr=0.5,  sg=0.5,    sb=0.5},
        ORANGE =        {r=1,       g=0.5,    b=0,     sr=0.8,  sg=0.8,    sb=0},
        PEACH =         {r=1,       g=0.9,    b=0.71,  sr=0.8,  sg=0.8,    sb=0.4},
        PINK =          {r=1,       g=0.5,    b=1,     sr=1,    sg=0.5,    sb=1},
        PURPLE =        {r=0.627,   g=0.125,  b=0.941, sr=1,    sg=0,      sb=1},
        RED =           {r=0.9,     g=0,      b=0,     sr=1,    sg=0.3,    sb=0},
        TAN =           {r=0.82,    g=0.71,   b=0.55,  sr=0.82, sg=0.71,   sb=0.55},
        TEAL =          {r=0,       g=0.5,    b=0.5,   sr=0,    sg=0.7,    sb=0.7},
        TURQUOISE =     {r=.251,    g=.878,   b=.816,  sr=0.2,  sg=0.9,    sb=0.9}, 
        VIOLET =        {r=0.55,    g=0,      b=1,     sr=0.66, sg=0,      sb=0.75}, 
        WHITE =         {r=1,       g=1,      b=1,     sr=1,    sg=1,      sb=1},
        YELLOW =        {r=1,       g=1,      b=0,     sr=1,    sg=1,      sb=0},
	}
    addon.defaults.profile.Colors = Colors
	--[[
	Grabbed by Localizer

	L["BLACK"] 	L["BLUE"] 		L["BROWN"]	 	L["CYAN"]
	L["DCYAN"] 	L["GOLD"] 		L["GREEN"] 		L["GREY"]
	L["INDIGO"] L["MAGENTA"] 	L["MIDGREY"] 	L["ORANGE"]
	L["PEACH"] 	L["PINK"] 		L["PURPLE"] 	L["RED"]
	L["TAN"] 	L["TEAL"] 		L["TURQUOISE"] L["VIOLET"]
	L["WHITE"] 	L["YELLOW"]

	]]
end

-------------------------
-- Sounds
-------------------------

do
	local Sounds = {}

	local List = {
		["Bell Toll Alliance"] = "Sound\\Doodad\\BellTollAlliance.wav",
		["Bell Toll Horde"] = "Sound\\Doodad\\BellTollHorde.wav",
		["Low Mana"] = "Interface\\AddOns\\DXE\\Sounds\\LowMana.mp3",
        ["Low Health"] = "Interface\\AddOns\\DXE\\Sounds\\LowHealth.mp3",
		["Zing Alarm"] = "Interface\\AddOns\\DXE\\Sounds\\ZingAlarm.mp3",
		["Wobble"] = "Interface\\Addons\\DXE\\Sounds\\Wobble.mp3",
		["Bottle"] = "Interface\\AddOns\\DXE\\Sounds\\Bottle.mp3",
		["Lift Me"] = "Interface\\AddOns\\DXE\\Sounds\\LiftMe.mp3",
		["Neo Beep"] = "Interface\\AddOns\\DXE\\Sounds\\NeoBeep.mp3",
		["PvP Flag Taken"] = "Sound\\Spells\\PVPFlagTaken.wav",
		["Bad Press"] = "Sound\\Spells\\SimonGame_Visual_BadPress.wav",
		["Run Away"] = "Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav",
		["FF1 Victory"] = "Interface\\AddOns\\DXE\\Sounds\\FF1_Victory.mp3",
        ["FF2 Victory"] = "Interface\\AddOns\\DXE\\Sounds\\FF2_Victory.mp3",
        ["UT2K3 Victory"] = "Interface\\Addons\\DXE\\Sounds\\UT2K3_Victory1.mp3",
        ["FF1 Wipe"] = "Sound\\Creature\\YoggSaron\\UR_YoggSaron_Slay01.ogg",
        ["Minor Warning"] = "Sound\\Doodad\\BellTollNightElf.wav",
        ["Algalon Beware"] = "Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav",
        ["Shadow Dance"] = "Sound\\SPELLS\\Rogue_shadowdance_state.ogg",
        ["RunAway"] = "Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav",
        ["Countdown: Tick"] = "25477",
        ["Countdown: Go"] = "25478",
        ["LevelUp"] = "Sound\\interface\\levelup.ogg",
        ["ReadyCheck"] = "Sound\\interface\\levelup2.ogg",
        ["BGReadyCheck"] = "8463",
        ["EnteringGroup"] = "881",
	}
	local sound_defaults = addon.defaults.profile.Sounds

	function Sounds:GetFile(id)
    if id == "None" or not id then
      return "Interface\\Quiet.mp3"
    elseif string.find(id,"\\") then
      return id
    else
        local soundSource = sound_defaults[id] and pfl.Sounds[id] or pfl.CustomSounds[id]
        if addon.db.profile.CustomSoundFiles[soundSource] then
            return addon.db.profile.CustomSoundFiles[soundSource]
        else
            return SM:Fetch("sound",soundSource)
        end
    end
  end

	Media.Sounds = Sounds
	for name,file in pairs(List) do SM:Register("sound",name,file) end
    
    function addon:IsGameSoundMuted()
        return GetCVar("Sound_EnableSFX") == "0"
    end
end

-------------------------
-- FONTS
-------------------------

do
	SM:Register("font", "Bastardus Sans", "Interface\\AddOns\\DXE\\Fonts\\BS.ttf")
	SM:Register("font", "Courier New", "Interface\\AddOns\\DXE\\Fonts\\CN.ttf")
	SM:Register("font", "Franklin Gothic Medium", "Interface\\AddOns\\DXE\\Fonts\\FGM.ttf")
end

-------------------------
-- TEXTURE ICONS 
-------------------------
do
    local TexturesIcons = {
        AchievementShield = {"\124TInterface\\ACHIEVEMENTFRAME\\UI-Achievement-TinyShield.blp:<width>:<height>:0:0:32:32:0:19:0:19\124t",12,12},
    }
    Media.TexturesIcons = TexturesIcons
    
    function addon:GetTextureIcon(key, width, height)
        local icon = Media.TexturesIcons[key]
        if not icon then return end
        
        width = width or icon[2]
        height = height or icon[3]
        return icon[1]:gsub("<width>",width):gsub("<height>",height)
    end
    
    local TI = setmetatable({}, {__index = 
        function (t, key)
            return addon:GetTextureIcon(key)
        end,
    })
    addon.TI = TI

end

-------------------------
-- GLOBALS
-------------------------
local bgBackdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", insets = {}}
local borderBackdrop = {}

function addon:NotifyAllMedia()
	addon:NotifyBarTextureChanged()
	addon:NotifyFontChanged()
	addon:NotifyBorderChanged()
	addon:NotifyBorderColorChanged()
	addon:NotifyBorderEdgeSizeChanged()
	addon:NotifyBackgroundColorChanged()
	addon:NotifyBackgroundInsetChanged()
	addon:NotifyBackgroundTextureChanged()
end

do
	local reg = {}
	function addon:RegisterFontString(fontstring,size,flags)
		reg[#reg+1] = fontstring
		fontstring:SetFont(SM:Fetch("font",pfl.Globals.Font),size,flags)
	end

	function addon:NotifyFontChanged(fontFile)
		local font = SM:Fetch("font",pfl.Globals.Font)
		for _,fontstring in ipairs(reg) do
			local _,size,flags = fontstring:GetFont()
			fontstring:SetFont(font,size,flags)
		end
	end
end

do
	local reg = {}
	function addon:RegisterTimerFontString(fontstring,size,flags)
		reg[#reg+1] = fontstring
		fontstring:SetFont(SM:Fetch("font",pfl.Globals.TimerFont),size,flags)
	end

	function addon:NotifyTimerFontChanged(fontFile)
		local font = SM:Fetch("font",fontFile)
		for _,fontstring in ipairs(reg) do 
			local _,size,flags = fontstring:GetFont()
			fontstring:SetFont(font,size,flags)
		end
	end
end

do
	local reg = {}
	function addon:RegisterStatusBar(statusbar,bartype)
		reg[#reg+1] = {statusbar,bartype}
        if not bartype then
            texture = SM:Fetch("statusbar",pfl.Globals.BarTexture)
        elseif bartype == "HealthWatcher" then
            texture = SM:Fetch("statusbar",pfl.Pane.BarTexture)
        end
		statusbar:SetStatusBarTexture(texture)
		statusbar:GetStatusBarTexture():SetHorizTile(false)
	end
    
	function addon:NotifyBarTextureChanged(name)
        local texture
		for _,regData in ipairs(reg) do
            local statusbar,bartype = unpack(regData)
            if not bartype then
                texture = SM:Fetch("statusbar",pfl.Globals.BarTexture)
            elseif bartype == "HealthWatcher" then
                texture = SM:Fetch("statusbar",pfl.Pane.BarTexture)
            end
            statusbar:SetStatusBarTexture(texture)
        end
	end   
end

do
	local reg = {}
	function addon:RegisterBorder(frame,noskin)
		reg[#reg+1] = frame
		if not noskin then
            local r,g,b,a = unpack(pfl.Globals.BorderColor)
            borderBackdrop.edgeFile = SM:Fetch("border",pfl.Globals.Border)
            borderBackdrop.edgeSize = pfl.Globals.BorderEdgeSize
            frame:SetBackdrop(borderBackdrop)
            frame:SetBackdropBorderColor(r,g,b,a)
        end
	end

	function addon:NotifyBorderChanged()
        borderBackdrop.edgeFile = SM:Fetch("border",pfl.Globals.Border)

		for _,frame in ipairs(reg) do 
			frame:SetBackdrop(borderBackdrop)
		end
		-- setting backdrop resets color
		addon:NotifyBorderColorChanged()
	end

	function addon:NotifyBorderEdgeSizeChanged()
		borderBackdrop.edgeSize = pfl.Globals.BorderEdgeSize
		for _,frame in ipairs(reg) do 
			frame:SetBackdrop(borderBackdrop)
		end
		-- setting backdrop resets color
		addon:NotifyBorderColorChanged()
	end

	function addon:NotifyBorderColorChanged()
		local r,g,b,a = unpack(pfl.Globals.BorderColor)
		for _,frame in ipairs(reg) do 
			frame:SetBackdropBorderColor(r,g,b,a)
		end
	end
end

do
	local reg = {}

	function addon:RegisterBackground(widget)
		reg[#reg+1] = widget
		local r,g,b,a = unpack(pfl.Globals.BackgroundColor)
		bgBackdrop.bgFile = SM:Fetch("background",pfl.Globals.BackgroundTexture)
		local inset = pfl.Globals.BackgroundInset
		bgBackdrop.insets.left = inset
		bgBackdrop.insets.right = inset
		bgBackdrop.insets.top = inset
		bgBackdrop.insets.bottom = inset
		if widget:IsObjectType("Frame") then
			widget:SetBackdrop(bgBackdrop)
			widget:SetBackdropColor(r,g,b,a)
		elseif widget:IsObjectType("Texture") then
			widget:SetTexture(bgBackdrop.bgFile) -- Odebere pozadí prázdného baru
			widget:SetVertexColor(r,g,b,a) -- Odebere obarvení prázdného baru
		end
	end


	function addon:NotifyBackgroundTextureChanged()
		bgBackdrop.bgFile = SM:Fetch("background",pfl.Globals.BackgroundTexture)
		for _,widget in ipairs(reg) do
			if widget:IsObjectType("Frame") then
				widget:SetBackdrop(bgBackdrop)
			elseif widget:IsObjectType("Texture") then
				widget:SetTexture(bgBackdrop.bgFile)
			end
		end
		-- setting backdrop resets color
		self:NotifyBackgroundColorChanged()
	end

	function addon:NotifyBackgroundInsetChanged()
		local inset = pfl.Globals.BackgroundInset
		bgBackdrop.insets.left = inset
		bgBackdrop.insets.right = inset
		bgBackdrop.insets.top = inset
		bgBackdrop.insets.bottom = inset
		for _,widget in ipairs(reg) do
			if widget:IsObjectType("Frame") then
				widget:SetBackdrop(bgBackdrop)
			--elseif widget:IsObjectType("Texture") then
			end
		end
		-- setting backdrop resets color
		self:NotifyBackgroundColorChanged()
	end

	function addon:NotifyBackgroundColorChanged()
		local r,g,b,a = unpack(pfl.Globals.BackgroundColor)
		for _,widget in ipairs(reg) do 
			if widget:IsObjectType("Frame") then
				widget:SetBackdropColor(r,g,b,a)
			elseif widget:IsObjectType("Texture") then
				widget:SetVertexColor(r,g,b,a)
			end
		end
	end
end
