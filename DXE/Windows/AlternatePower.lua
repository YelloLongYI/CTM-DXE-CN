local addon = DXE
local L = addon.L
local name_to_unit = addon.Roster.name_to_unit
local name_to_class = addon.Roster.name_to_class


local window
local pfl
local customTitle = nil

---------------------------------------
-- BARS
---------------------------------------
local bars = {}
local bar_pool = {}

local function Destroy(self)
	self.destroyed = true
	self:Hide()
	self.curr = nil
	self.lastd = nil
	self.dblank = true
	self.left:SetText("")
	self.statusbar:SetValue(1)
end

local function CreateBar()
	local bar = CreateFrame("Frame",nil,window.content)
    bar:Hide()

	local icon = bar:CreateTexture(nil,"ARTWORK")
	icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
	bar.icon = icon

	local statusbar = CreateFrame("StatusBar",nil,bar)
	statusbar:SetMinMaxValues(0,1)
	addon:RegisterStatusBar(statusbar)
	bar.statusbar = statusbar

	local name = statusbar:CreateFontString(nil,"ARTWORK")
	name:SetShadowOffset(1,-1)
	addon:RegisterFontString(name,pfl.AlternatePower.NameFontSize)
	bar.name = name

	-- format "%d".."%02d"
	--         ^     ^
	--         left  right

	local left = statusbar:CreateFontString(nil,"ARTWORK")
	left:SetShadowOffset(1,-1)
	addon:RegisterFontString(left,pfl.AlternatePower.TimeFontSize)
	bar.left = left

	bar.Destroy = Destroy

	return bar
end

local function GetBar()
	local bar = next(bar_pool)
	if not bar then
		return CreateBar()
	else
		bar_pool[bar] = nil
		return bar
	end
end

---------------------------------------
-- SETTERS
--------------------------------------
local rows

local function UpdateBars()
	local content = window.content
	local width = content:GetWidth()
	local height = content:GetHeight()/rows
	for i,bar in ipairs(bars) do
		local r,g,b = bar.statusbar:GetStatusBarColor()
		bar.statusbar:SetStatusBarColor(r,g,b,pfl.AlternatePower.BarAlpha)
		bar.name:SetFont(bar.name:GetFont(),pfl.AlternatePower.NameFontSize)
		bar.left:SetFont(bar.left:GetFont(),pfl.AlternatePower.TimeFontSize)

		bar:SetWidth(width)
		bar:SetHeight(height)
		bar:SetPoint("TOP",content,"TOP",0,-(i-1)*height)
		bar.icon:SetWidth(height-2)
		bar.icon:SetHeight(height-2)
		bar.statusbar:SetHeight(height-2)

		bar.name:ClearAllPoints()
		bar.name:SetPoint(pfl.AlternatePower.NameAlignment,pfl.AlternatePower.NameOffset,0)
		bar.left:ClearAllPoints()
		bar.left:SetPoint("RIGHT",pfl.AlternatePower.TimeOffset,0)

		bar.icon:ClearAllPoints()
		bar.statusbar:ClearAllPoints()
		if pfl.AlternatePower.IconPosition == "LEFT" then
			bar.icon:SetPoint("LEFT",bar,"LEFT",2,0)
			bar.statusbar:SetPoint("LEFT",bar.icon,"RIGHT")
			bar.statusbar:SetPoint("RIGHT",bar,"RIGHT")
		elseif pfl.AlternatePower.IconPosition == "RIGHT" then
			bar.icon:SetPoint("RIGHT",bar,"RIGHT",-2,0)
			bar.statusbar:SetPoint("RIGHT",bar.icon,"LEFT")
			bar.statusbar:SetPoint("LEFT",bar,"LEFT")
		end
	end
end

local function UpdateRows()
	for i=1,rows do
		if not bars[i] then
			bars[i] = GetBar()
		end
	end

	for i=rows+1,#bars do
		local bar = bars[i]
		bar:Destroy()
		bar_pool[bar] = true
		bars[i] = nil
	end
end

---------------------------------------
-- WINDOW CREATION
--------------------------------------
local invert
local delay
local threshold = 1

local OnUpdate
local counter = 0

do
	local ICON_COORDS = {}
	local e = 0.02
	for class,coords in pairs(CLASS_ICON_TCOORDS) do
		local l,r,t,b = unpack(coords)
		ICON_COORDS[class] = {l+e,r-e,t+e,b-e}
	end

	local unpack,select = unpack,select
	local CN = addon.CN
	local RAID_CLASS_COLORS = RAID_CLASS_COLORS
	local floor = math.floor

	function OnUpdate(_,elapsed)
		if delay > 0 then
			counter = counter + elapsed
			if counter < delay then return end
		end
		counter = 0
		local n = 0
		local powers = {}
		
		for name in pairs(name_to_unit) do
			local class = name_to_class[name]
			if pfl.AlternatePower.ClassFilter[class] then
				local unit = name_to_unit[name]
				local unitPower = UnitPower(unit, ALTERNATE_POWER_INDEX)
				
				local flag = true
				flag = flag and unitPower and unitPower > threshold
				
				if flag then
					n = n + 1
					local power = {}
					powers[n] = power
					power.name = CN[name]
					power.class = class
					power.lastpower = unitPower
				end
			end
		end
		
		for i=n+1,#bars do 
			if pfl.AlternatePower.Dummy then
				local power = {}
				local bar = bars[i]
				powers[i] = power
				power.name = "Abracadabrah"
				power.class = "WARRIOR"
				power.lastpower = i-2
			end
		end
		table.sort(powers, function(a,b) return a and b and a.lastpower and b.lastpower and a.lastpower > b.lastpower end)

		for i=1,#bars do
			local power = powers[i]
			local bar = bars[i]
			if power and power.class and power.name and power.lastpower then
				bar.name:SetText(power.name)
				bar.icon:SetTexCoord(unpack(ICON_COORDS[power.class]))
				local c = RAID_CLASS_COLORS[power.class]
				bar.statusbar:SetStatusBarColor(c.r,c.g,c.b,pfl.AlternatePower.BarAlpha)
				local perc = power.lastpower / 100 -- we assume max unitPower is 100 for alternate type
				bar.statusbar:SetValue(invert and (1-perc) or perc)
				bar.destroyed = nil
				bar.left:SetFormattedText("%d",power.lastpower)
				bar.lastpower = power.lastpower
				bar:Show()
			else
				if not bar.destroyed then bar:Destroy() end
			end
			
		end
	end
end

local function UpdateTitle(text)
  if text or (not text and not customTitle) then
    customTitle = text
    window:SetTitle(format("%s", text or L["AlternatePower"]))
  end
end

local function OpenOptions()
	addon:ToggleConfig()
	if not addon.Options then return end
	if LibStub("AceConfigDialog-3.0").OpenFrames.DXE then LibStub("AceConfigDialog-3.0"):SelectGroup("DXE","windows_group","alternatepower_group") end
end

local function OnShow(self)
	counter = 0
end

local function OnHide(self)
	for i,bar in ipairs(bars) do bar:Destroy() end
end

local alternativePowerLocked = true
local alternativePowerShown = false

local function IsActive()
    return alternativePowerShown
end

local function Activate()
    alternativePowerShown = true
    window:Show()
end

local function Deactivate()
    alternativePowerShown = false
    
    if addon.db.global.Locked then
        window:Hide()
    end
end

local function OnEnter(self)
    if self.parent then self = self.parent end
	
    self.titlebar:SetAlpha(1)
    self.titletext:SetAlpha(1)
    self.close:SetAlpha(1)
    if not alternativePowerLocked then self.corner:SetAlpha(1) end
    if pfl.AlternatePower.HideTitleBar then
		if alternativePowerLocked then self.gradient:SetAlpha(0) end
    else
        self.gradient:SetAlpha(1)
        local r,g,b,a = unpack(pfl.Windows.TitleBarColor)
        self.gradient:SetTexture(r,g,b,a)
        self.gradient:SetGradient("HORIZONTAL",r,g,b,0,0,0)
    end
end

local function OnLeave(self)
    if self.parent then self = self.parent end
	self.titletext:SetAlpha(0)
    self.close:SetAlpha(0)
    if not alternativePowerLocked then
        local r,g,b,a = unpack(pfl.Windows.TitleBarColor)
        self.titlebar:SetAlpha(1)
        self.gradient:SetAlpha(1)
        window.gradient:SetTexture(r,g,b,a)
        window.gradient:SetGradient("HORIZONTAL",r,g,b,0,0,0)
        self.titletext:SetAlpha(1)
        self.close:SetAlpha(1)
        
        local br,bg,bb,ba = unpack(pfl.AlternatePower.BackgroundColor)
        self.faux_window:SetBackdropColor(br,bg,bb,ba)
        self.border:SetAlpha(1)
        self.corner:SetAlpha(1)
    else
        self.titlebar:SetAlpha(1)
        self.corner:SetAlpha(0)
        if not pfl.AlternatePower.HideTitleBar then
            self.titlebar:SetAlpha(1)
            local r,g,b,a = unpack(pfl.Windows.TitleBarColor)
            self.gradient:SetAlpha(1)
            self.gradient:SetTexture(r,g,b,a)
            self.gradient:SetGradient("HORIZONTAL",r,g,b,0,0,0)
        else
            self.gradient:SetAlpha(0)
        end
        self.titletext:SetAlpha(pfl.AlternatePower.AlwaysShowTitle and 1 or 0)
        self.close:SetAlpha(pfl.AlternatePower.AlwaysShowCloseButton and 1 or 0)
        
        local r,g,b,a = unpack(pfl.AlternatePower.BackgroundColor)
        self.faux_window:SetBackdropColor(r,g,b,pfl.AlternatePower.HideBackground and 0 or a)
        self.border:SetAlpha(pfl.AlternatePower.HideBorder and 0 or 1)
    end
end

local DetectMouseOver = function(self, elapsed) 
	if MouseIsOver(self) then
		if not self.Over then 
			self.Over = true
			OnEnter(self)
		end
	else
		if self.Over then 
			self.Over = nil
            OnLeave(self)
		end
	end
end

local function CreateWindow()
    window = addon:CreateWindow(L["AlternatePower"],110,100)
	window.closefunc = Deactivate
    window:Hide()
	window:SetContentInset(1)
	local content = window.content

	window:RegisterCallback("OnSizeChanged",UpdateBars)

	window:SetScript("OnUpdate",OnUpdate)
	window:SetScript("OnShow",OnShow)
	window:SetScript("OnHide",OnHide)
    window:HookScript("OnUpdate",DetectMouseOver)
    
    local faux_window = window.faux_window
    faux_window.showtooltip = false
    window.corner.showtooltip = false
    
    window.skinfunc = OnLeave
    OnLeave(window)
	window:Show()
	CreateWindow = nil
end

local function ShowAnchors()
    if not window then
        CreateWindow()
    end
    addon:UpdateAlternatePowerSettings()
    window.faux_window:EnableMouse(true)
    window:Show()
    
    local r,g,b,a = unpack(pfl.Windows.TitleBarColor)
    window.gradient:SetAlpha(1)
    window.gradient:SetTexture(r,g,b,a)
    window.gradient:SetGradient("HORIZONTAL",r,g,b,0,0,0)
    window.titlebar:SetAlpha(1)
    window.close:SetAlpha(1)
    window.titletext:SetAlpha(1)
    window.corner:SetAlpha(1)
    
    if pfl.AlternatePower.HideBackground then
        local r,g,b,a = unpack(pfl.AlternatePower.BackgroundColor)
        window.border:SetAlpha(1)
        window.faux_window:SetBackdropColor(r,g,b,a)
    end
    
    window.faux_window.showtooltip = true
    window.faux_window:SetMovable(true)
    --window:SetMovable(true)
    window.corner.showtooltip = true
end

local function HideAnchors()
    if window then
        OnLeave(window)
        if not IsActive() then Deactivate() end
        
        window.faux_window.showtooltip = false
        window.faux_window:SetMovable(false)
        window.corner.showtooltip = false
        window.faux_window:EnableMouse(false)
    end
end

function addon:UpdateAlternativePowerLock(locked)
    alternativePowerLocked = locked
    
    if not locked then
        ShowAnchors()
    else
        HideAnchors()
    end
end

---------------------------------------
-- API
---------------------------------------

function addon:AlternatePower(popup, enc_threshold, titleText)
	if popup and not pfl.AlternatePower.AutoPopup then return end
	if not window then CreateWindow() end
    addon:UpdateAlternatePowerSettings()
    
    if not alternativePowerLocked then ShowAnchors() else HideAnchors() end
    
    window:Show()
	if not IsActive() then Activate() end
	threshold = enc_threshold or pfl.AlternatePower.Threshold
	
	UpdateTitle(titleText)
end

function addon:ShowAlternatePower()
  if window then window:Show() else addon:AlternatePower(false) end
end

function addon:HideAlternatePower()
	if window then window:Hide() end
end

addon:RegisterWindow(L["AlternatePower"],function() addon:AlternatePower() end)

---------------------------------------
-- SETTINGS
---------------------------------------

function addon:UpdateAlternatePowerSettings()
	rows		= pfl.AlternatePower.Rows
	delay		= pfl.AlternatePower.Delay
	invert		= pfl.AlternatePower.Invert
	threshold	= pfl.AlternatePower.Threshold

	if window then
		UpdateTitle()
		UpdateRows()
		UpdateBars()
	end
end


local function RefreshProfile(db)
	pfl = db.profile
	addon:UpdateAlternatePowerSettings()
end
addon:AddToRefreshProfile(RefreshProfile)
