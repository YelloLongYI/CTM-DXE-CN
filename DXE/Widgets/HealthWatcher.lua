-- Skinning is done externally
local addon = DXE

local HealthWatcher,prototype = {},{}
DXE.HealthWatcher = HealthWatcher

local UnitHealth,UnitHealthMax = UnitHealth,UnitHealthMax
local UnitPower,UnitPowerMax,UnitPowerType = UnitPower,UnitPowerMax,UnitPowerType
local PowerBarColor = PowerBarColor
local UnitIsDead = UnitIsDead
local format = string.format
local DEAD = DEAD:upper()



function HealthWatcher:New(parent)
	local hw = CreateFrame("Button",nil,parent)
    -- Embed
	for k,v in pairs(prototype) do hw[k] = v end
	hw.events = {}

	hw:SetWidth(220)
    hw:SetHeight(22)
	addon:RegisterBackground(hw)

	local healthbar = CreateFrame("StatusBar",nil,hw)
	healthbar:SetMinMaxValues(0,1)
	healthbar:SetPoint("TOPLEFT",2,-2)
	healthbar:SetPoint("BOTTOMRIGHT",-2,2)
    addon:RegisterStatusBar(healthbar,"HealthWatcher")
    healthbar.phaseMarkers = {}
	hw.healthbar = healthbar
    
    local spark = CreateFrame("Frame",nil,healthbar)
    hw.spark = spark
    spark.t = spark:CreateTexture(nil, "OVERLAY")
    spark.t:SetBlendMode("ADD");
    spark.t:SetTexture([[Interface\AddOns\DXE\Textures\Spark]])
    
	local powerbar = CreateFrame("StatusBar",nil,hw)
	powerbar:SetMinMaxValues(0,1)
	powerbar:SetPoint("BOTTOMLEFT",healthbar,"BOTTOMLEFT")
	powerbar:SetPoint("BOTTOMRIGHT",healthbar,"BOTTOMRIGHT")
	powerbar:SetHeight(5)
	powerbar:SetFrameLevel(healthbar:GetFrameLevel()+1)
	powerbar:Hide()
	addon:RegisterStatusBar(powerbar)
	hw.powerbar = powerbar
    
    local altpowerbar = CreateFrame("StatusBar",nil,hw)
	altpowerbar:SetMinMaxValues(0,1)
	altpowerbar:SetPoint("BOTTOMLEFT",healthbar,"BOTTOMLEFT")
	altpowerbar:SetPoint("BOTTOMRIGHT",healthbar,"BOTTOMRIGHT")
	altpowerbar:SetHeight(5)
	altpowerbar:SetFrameLevel(healthbar:GetFrameLevel()+1)
	altpowerbar:Hide()
	addon:RegisterStatusBar(altpowerbar)
	hw.altpowerbar = altpowerbar
	
	local border = CreateFrame("Frame",nil,hw)
	border:SetAllPoints(true)
	border:SetFrameLevel(healthbar:GetFrameLevel()+2)
	addon:RegisterBorder(border)
	hw.border = border

	-- parent for font strings so they appears above powerbar
	local region = CreateFrame("Frame",nil,healthbar)
	region:SetAllPoints(true)
	region:SetFrameLevel(healthbar:GetFrameLevel()+10)

	-- Add title text
	title = region:CreateFontString(nil,"ARTWORK")
	title:SetPoint("LEFT",healthbar,"LEFT",2,0)
	title:SetShadowOffset(1,-1)
	addon:RegisterFontString(title,10)
	hw.title = title
    hw.text = nil

	-- Add health text
	health = region:CreateFontString(nil,"ARTWORK")
	health:SetPoint("RIGHT",healthbar,"RIGHT",-2,0)
	health:SetShadowOffset(1,-1)
	addon:RegisterFontString(health,12)
	hw.health = health

	local tracer = addon.Tracer:New()
	tracer:SetCallback(hw,"TRACER_UPDATE")
	tracer:SetCallback(hw,"TRACER_LOST")
	tracer:SetCallback(hw,"TRACER_ACQUIRED")
	hw.tracer = tracer
    hw.temp = nil
    
    
	return hw
end


--------------------------
-- PROTOTYPE
--------------------------

function prototype:SetCallback(event, func) self.events[event] = func end
function prototype:Fire(event, ...) if self.events[event] then self.events[event](self,event,...) end end
function prototype:Track(trackType,goal) self.tracer:Track(trackType,goal) end
--function prototype:GetGoal() return self.tracker:GetGoal() end
function prototype:SetTitle(text) self.text = text self.title:SetText(format(" %s",text or "Unknown")) end
function prototype:GetTitle() return self.text or "..." end
function prototype:SetRaidMarker(markNumber) self.title:SetText(format("%s  %s","\124TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_"..markNumber..":18:18:0:0\124t",self:GetTitle())) end
function prototype:IsTitleSet() return self.text ~= "..."end
function prototype:IsOpen() return self.text ~= "" end
function prototype:GetGoal() return self.tracer.goal end
function prototype:EnableUpdates() self.updates = true end
function prototype:SetNeutralColor(color) self.nr,self.ng,self.nb = unpack(color) end
function prototype:SetLostColor(color) self.lr,self.lg,self.lb = unpack(color) end
function prototype:SetTemp(temp) self.temp = temp end
function prototype:IsTemp() return self.temp end
function prototype:UpdateBossUnits() self.tracer:UpdateBossUnits() end

function prototype:ApplyNeutralColor() 
    self.healthbar:SetStatusBarColor(self.nr,self.ng,self.nb) 
    self.spark.t:SetVertexColor(self.nr,self.ng,self.nb,1)
	if not self.powercolor and self.power then self.powerbar:SetStatusBarColor(self.nr,self.ng,self.nb) end
    if not self.altpowercolor and self.altpower then self.altpowerbar:SetStatusBarColor(1,1,1,1) end
    self:SkinBorder(self.border,false)
end

function prototype:ApplyLostColor()
	self.healthbar:SetStatusBarColor(self.lr,self.lg,self.lb) 
    self.spark.t:SetVertexColor(self.lr,self.lg,self.lb,1)
	if not self.powercolor and self.power then self.powerbar:SetStatusBarColor(self.lr,self.lg,self.lb) end
    if not self.altpowercolor and self.altpower then self.altpowerbar:SetStatusBarColor(1,1,1,1) end
    self:SkinBorder(self.border,false)
end

function prototype:IsOpen() return self.tracer:IsOpen() end

function prototype:ShowPower()
	self.power = true
	self.powerbar:Show()
	self.powercolor = nil
end

function prototype:ShowAltPower()
	self.altpower = true
	self.altpowerbar:Show()
	self.altpowercolor = nil
end

function prototype:Open(power)
	self.tracer:Open() 
end

function prototype:Close() 
	self:SetTemp(false)
    self.tracer:Close()
	self.title:SetText("")
	if self.power then
		self.power = nil
		self.powercolor = nil
		self.powerbar:Hide()
		self.powerbar:SetValue(0)
	end
    if self.altpower then
        self.altpower = nil
		self.altpowercolor = nil
		self.altpowerbar:Hide()
		self.altpowerbar:SetValue(0)
    end
end

function prototype:SkinBorder(frame,selected,unit)
    local borderBackdrop = {}
    if (unit == "target" or (unit and UnitIsUnit(unit,"target"))) and selected then
        borderBackdrop.edgeFile = addon.SM:Fetch("border",pfl.Pane.SelectedBorder)
		borderBackdrop.edgeSize = pfl.Pane.SelectedBorderEdgeSize
    else
		borderBackdrop.edgeFile = addon.SM:Fetch("border",pfl.Pane.Border)
		borderBackdrop.edgeSize = pfl.Pane.BorderEdgeSize
    end
    local r,g,b,a = unpack(pfl.Pane.SelectedBorderColor)
    frame:SetBackdropBorderColor(r,g,b,a)
    frame:SetBackdrop(borderBackdrop)
end

function prototype:SetInfoBundle(health,hperc,pperc,apperc,unit)
    hperc = self:convertToVisualHP(hperc)
    self.healthbar:SetValue(hperc)
    self:RefreshSpark(hperc)
	self.healthbar:SetStatusBarColor(hperc > 0.5 and ((1 - hperc) * 2) or 1, hperc > 0.5 and 1 or (hperc * 2), 0)
    self.spark.t:SetVertexColor(hperc > 0.5 and ((1 - hperc) * 2) or 1, hperc > 0.5 and 1 or (hperc * 2), 0, 1)
	self.health:SetText(health)
	if self.power and pperc then self.powerbar:SetValue(pperc) end
    if self.altpower and apperc then self.altpowerbar:SetValue(apperc) end
    self:SkinBorder(self.border,true,unit)
end

-- Events
function prototype:TRACER_LOST() self:ApplyLostColor() end

function prototype:TRACER_ACQUIRED() 
	local unit = self.tracer:First()
	self:Fire("HW_TRACER_ACQUIRED",unit)
	if not self.powercolor and self.power then
		-- Saurfang apparently returns three extra arguments
		local ix,type,r,g,b = UnitPowerType(unit)
		if r and g and b then
			self.powerbar:SetStatusBarColor(r,g,b)
		else
			-- numeric indexes are fallbacks according to blizzard
			local c = PowerBarColor[type] or PowerBarColor[ix]
			if not c then return end
			self.powerbar:SetStatusBarColor(c.r,c.g,c.b)
		end
		self.powercolor = true
	end
    if not self.altpowercolor and self.altpower then
		-- Saurfang apparently returns three extra arguments
		local ix,type,r,g,b = UnitPowerType(unit,10)
		if r and g and b then
            self.altpowerbar:SetStatusBarColor(1,1,1,1)
		else
			-- numeric indexes are fallbacks according to blizzard
			local c = PowerBarColor[type] or PowerBarColor[ix]
			if not c then return end
            self.altpowerbar:SetStatusBarColor(1,1,1,1)
		end
		self.altpowercolor = true
	end
end

function prototype:TRACER_UPDATE()
    local unit = self.tracer:First()
	if UnitIsDead(unit) then
		self:SetInfoBundle(DEAD, 0, 0, 0)
        --self:RefreshSpark(0)
	else
		local h, hm = UnitHealth(unit), UnitHealthMax(unit) 
		local hperc = h/hm
		local pperc
		if self.power then pperc = UnitPower(unit)/UnitPowerMax(unit) end
        if self.altpower then apperc = UnitPower(unit,10) / UnitPowerMax(unit,10) end
        self:SetInfoBundle(format("%0.0f%%", hperc*100), hperc, pperc, apperc, unit)
        --self:RefreshSpark(hperc)
	end
    
    local mark = GetRaidTargetIndex(unit)
    if mark then
        self:SetRaidMarker(mark)
    else
        self:SetTitle(self:GetTitle())
    end
	if self.updates then
		self:Fire("HW_TRACER_UPDATE",self.tracer:First())
	end
end

function prototype:SetVisualMax(visualmax)
    self.visualmax = visualmax
end

function prototype:convertToVisualHP(hperc)
    return hperc / (self.visualmax or 1)
end

local SEPARATOR_WIDTH = 9
local SEPARATOR_HEIGHT = 19
    
function PhaseSeparator_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(self.label);
    if pfl.Pane.PhaseMarkersShowDescription then GameTooltip:AddLine(self.description, 1, 1, 1, true) end
	GameTooltip:Show();
    self.phaseMarkerSeparatorMarker:SetVertexColor(1, 1, 0, 1)
end

function PhaseSeparator_OnLeave(self)
    self.phaseMarkerSeparatorMarker:SetVertexColor(1, 0.84, 0, 1)
    GameTooltip_Hide();
end

function prototype:CreatePhaseMarker(index)
    local phaseMarker = CreateFrame("Frame","Phase Separator Frame",self.healthbar)
    phaseMarker:SetWidth(SEPARATOR_WIDTH)
    phaseMarker:SetHeight(SEPARATOR_HEIGHT)

    
    local phaseMarkerSeparatorMarker = phaseMarker:CreateTexture("Phase phaseMarkerSeparator Marker Top","ARTWORK")
    phaseMarkerSeparatorMarker:SetTexture("Interface\\GuildFrame\\GuildFrame")
    phaseMarkerSeparatorMarker:SetTexCoord(0.38378906, 0.39257813, 0.95898438, 0.99804688)
    phaseMarkerSeparatorMarker:SetWidth(SEPARATOR_WIDTH - 2)
    phaseMarkerSeparatorMarker:SetHeight(SEPARATOR_HEIGHT)
    phaseMarkerSeparatorMarker:SetAlpha(1)
    phaseMarkerSeparatorMarker:SetDrawLayer("ARTWORK",7)
    phaseMarkerSeparatorMarker:ClearAllPoints()
    phaseMarkerSeparatorMarker:SetPoint("TOPLEFT",phaseMarker)
    phaseMarker.phaseMarkerSeparatorMarker = phaseMarkerSeparatorMarker
    
    phaseMarker:SetAlpha(1)
    phaseMarker.enabled = false
    phaseMarker.visible = false
    self.healthbar.phaseMarkers[index] = phaseMarker
end

function prototype:AddPhaseMarker(index, percentPos, label, description)
    local phaseMarker = self.healthbar.phaseMarkers[index]
    percentPos = self:convertToVisualHP(percentPos)
    phaseMarker:ClearAllPoints()
    phaseMarker:SetPoint("TOPLEFT",(self:GetWidth()-4)*percentPos-4,0)
    
    phaseMarker.label = label
    phaseMarker.description = description
    
    phaseMarker.phaseMarkerSeparatorMarker:SetVertexColor(1, 0.84, 0, 1)

    phaseMarker.enabled = true
    phaseMarker.visible = true
    if pfl.Pane.PhaseMarkersEnable then
        self:ShowPhaseMarker(index,true)
    else
        self:HidePhaseMarker(index,true)
    end
end


function prototype:HidePhaseMarker(index,optOverride)
    if type(index) == "number" then
        
        local phaseMarker = self.healthbar.phaseMarkers[index]
        phaseMarker:SetAlpha(0)
        if not optOverride then phaseMarker.visible = false end
        phaseMarker:SetScript("OnEnter", nil)
        phaseMarker:SetScript("OnLeave", nil)
        phaseMarker:EnableMouse(false)
    end
end

function prototype:ShowPhaseMarker(index,optOverride)
    if type(index) == "number" then
        
        local phaseMarker = self.healthbar.phaseMarkers[index]
        if not optOverride or phaseMarker.visible then
            phaseMarker:SetScript("OnEnter", PhaseSeparator_OnEnter)
            phaseMarker:SetScript("OnLeave", PhaseSeparator_OnLeave)
            phaseMarker:SetAlpha(1)
            phaseMarker.visible = true
            phaseMarker:EnableMouse(true)
        end
    end
end

function prototype:RemovePhaseMarker(index)
    
    local phaseMarker = self.healthbar.phaseMarkers[index]
    self:HidePhaseMarker(index)
    phaseMarker.enabled = false
end

function prototype:ClearAllPhaseMarkers()
    
    for markerIndex,v in ipairs(self.healthbar.phaseMarkers) do
        self:RemovePhaseMarker(markerIndex)
    end
end

function prototype:HideAllPhaseMarkers()
    
    for markerIndex,v in ipairs(self.healthbar.phaseMarkers) do
        self:HidePhaseMarker(markerIndex)
    end
end

function prototype:DisplayPhaseMarkers()
    
    for markerIndex,v in ipairs(self.healthbar.phaseMarkers) do
        self:ShowPhaseMarker(markerIndex)
    end
end

function prototype:RefreshSpark(value)
    local showSpark = pfl.Pane.BarShowSpark
    if not showSpark or (type(value)=="number" and (value <= 0 or value >= 1)) then
        self.spark:Hide()
    else
        if value then
            self.spark:ClearAllPoints()
            local sparkSize = 32
            local INSET = 2
            self.spark.t:SetPoint("TOPLEFT", self, "TOPLEFT", 1+(value*self:GetWidth())-(sparkSize/2)-value*2, self:GetHeight()-(pfl.ShowBarBorder and INSET or -INSET))
            self.spark.t:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",1-self:GetWidth()+(sparkSize/2)+(value*self:GetWidth())-value*2,-self:GetHeight()-(pfl.ShowBarBorder and INSET or 2*INSET))
        end
        --self.spark.t:SetVertexColor(1,1,1,1)
        --self.spark.t:SetVertexColor(self.data.c1.sr, self.data.c1.sg, self.data.c1.sb)
        self.spark:Show()
    end
end

function prototype:UpdatePhaseMarkersVisibility(showPhaseMarkers)
    for markerIndex,v in ipairs(self.healthbar.phaseMarkers) do
        local phaseMarker = self.healthbar.phaseMarkers[markerIndex]
        if phaseMarker.enabled then
            if showPhaseMarkers then
                self:ShowPhaseMarker(markerIndex,true)
            else
                self:HidePhaseMarker(markerIndex,true)
            end
        end               
    end
end
