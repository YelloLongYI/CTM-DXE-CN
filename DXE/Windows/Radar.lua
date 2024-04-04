--------------------------------------------
--[[
DXE Radar - a graphical proximity check.
Some of the code is straight from BigWigs. Many thanks and credits to them.
This textures used are copyright BigWigs: alert_circle.blp and dot.tga
]]
--------------------------------------------
local addon = DXE
local L = addon.L
local name_to_unit = addon.Roster.name_to_unit
local name_to_class = addon.Roster.name_to_class

local window
local pfl

--Radial upvalues
local GetPlayerMapPosition = GetPlayerMapPosition
local GetPlayerFacing = GetPlayerFacing
local format = string.format
local UnitInRange = UnitInRange
local UnitIsDead = UnitIsDead
local UnitIsUnit = UnitIsUnit
local UnitClass = UnitClass
local GetTime = GetTime
local min = math.min
local pi = math.pi
local cos = math.cos
local sin = math.sin
local tremove = table.remove
local unpack = unpack
local activeMap
local configmode = false

local titleHeight = 12
local titleBarInset = 2
local nodistancecheck = false
local RadarHideLines

local DOTSIZE
local ICONBEHAVE

---------------------------------------
-- UTILITY
---------------------------------------
local function RadarSize()

	if window then
		local content = window.content
		local container = window.container
		local faux_window = window.faux_window
		container:ClearAllPoints()
		container:SetPoint("TOPLEFT",faux_window,"TOPLEFT",1,-titleHeight-titleBarInset)
		container:SetPoint("BOTTOMRIGHT",faux_window,"BOTTOMRIGHT",-1,1)
		container:SetSize(faux_window:GetWidth()-1,faux_window:GetHeight()-titleHeight-titleBarInset)
		window:SetContentInset(1)
		content:SetSize(faux_window:GetWidth()-1,faux_window:GetHeight()-titleHeight-titleBarInset)

		local scale = faux_window:GetScale()*1.42
		local range = pfl.Proximity.Range
		local w,h = content:GetSize()
		local ppy = min(w, h) / (range * 3)
        content.rangeCircle:SetSize(ppy * range * 2 * scale, ppy * range * 2 * scale)
	end
end
local function OnSize(...)
	if window then
		RadarSize()
		if configmode then
			testDots()
		end
	end
	return true
end

local hexColors = {}
local vertexColors = {}
for k, v in pairs(RAID_CLASS_COLORS) do
	hexColors[k] = ("|cff%02x%02x%02x"):format(v.r * 255, v.g * 255, v.b * 255)
	vertexColors[k] = { v.r, v.g, v.b }
end

---------------------------------------
-- BARS
---------------------------------------
local bars = {}
local bar_pool = {}

---------------------------------------
-- WINDOW CREATION
--------------------------------------
local ProximityFuncs = addon:GetProximityFuncs()
local range -- yds
local invert
local delay
local rangefunc -- proximity function

local OnUpdate
local counter = 0

local function OnShow(self)
	counter = 0
end

local function OnHide(self)
	for i,bar in ipairs(bars) do return true end
end

local radarLocked = true
local radarShown = false

local function OnEnter(self)
    if self.parent then self = self.parent end
	
    self.titlebar:SetAlpha(1)
    self.titletext:SetAlpha(1)
    self.close:SetAlpha(1)
    if not radarLocked then self.corner:SetAlpha(1) end
    if pfl.Proximity.RadarHideTitleBar then
		if radarLocked then self.gradient:SetAlpha(0) end
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
    if not radarLocked then
        local r,g,b,a = unpack(pfl.Windows.TitleBarColor)
        self.titlebar:SetAlpha(1)
        self.gradient:SetAlpha(1)
        window.gradient:SetTexture(r,g,b,a)
        window.gradient:SetGradient("HORIZONTAL",r,g,b,0,0,0)
        self.titletext:SetAlpha(1)
        self.close:SetAlpha(1)
        
        local br,bg,bb,ba = unpack(pfl.Proximity.RadarBackgroundColor)
        self.faux_window:SetBackdropColor(br,bg,bb,ba)
        self.border:SetAlpha(1)
        self.corner:SetAlpha(1)
    else
        self.titlebar:SetAlpha(1)
        self.corner:SetAlpha(0)
        
        if not pfl.Proximity.RadarHideTitleBar then
            self.titlebar:SetAlpha(1)
            local r,g,b,a
            if pfl.Windows then
                r,g,b,a = unpack(pfl.Windows.TitleBarColor)
            else
                r,g,b,a = 1,1,1,1
            end
            self.gradient:SetAlpha(1)
            self.gradient:SetTexture(r,g,b,a)
            self.gradient:SetGradient("HORIZONTAL",r,g,b,0,0,0)
        else
            self.gradient:SetAlpha(0)
        end
        self.titletext:SetAlpha(pfl.Proximity.RadarAlwaysShowTitle and 1 or 0)
        self.close:SetAlpha(pfl.Proximity.RadarAlwaysShowCloseButton and 1 or 0)
        
        local r,g,b,a = unpack(pfl.Proximity.RadarBackgroundColor)
        self.faux_window:SetBackdropColor(r,g,b,pfl.Proximity.RadarHideBackground and 0 or a)
        self.border:SetAlpha(pfl.Proximity.RadarHideBorder and 0 or 1)
    end
end

local function UpdateTitle()
	window:SetTitle(format("%d yard%s", range, tonumber(range) > 1 and "s" or ""))
end

local function OpenOptions()
	addon:ToggleConfig()
	if not addon.Options then return end
	if LibStub("AceConfigDialog-3.0").OpenFrames.DXE then LibStub("AceConfigDialog-3.0"):SelectGroup("DXE","windows_group","proximity_group") end
end

local function IsActive()
    return radarShown
end

local function Activate()
    radarShown = true
    window:Show()
    window.content.rangeCircle:Show()
    window.content.playerDot:Show()
end

local function Deactivate()
    radarShown = false
    
    if window then
        window.content.rangeCircle:Hide()
        window.content.playerDot:Hide()
        
        
        if addon.db.global.Locked or addon.db.profile.Windows.Proxtype ~= "RADAR" then 
            window:Hide()
        end
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
    window = addon:CreateWindow(L["Radar"],110,100)
	window:SetMinResize(100, 30)
	--window:SetClampedToScreen(true)
	window.closefunc = Deactivate
    window:Hide()
	window:SetContentInset(1)

	window:RegisterCallback("OnSizeChanged",OnSize)
	window:RegisterCallback("OnScaleChanged",OnSize)
	window:SetScript("OnUpdate",OnUpdate)
	window:SetScript("OnShow",OnShow)
	window:SetScript("OnHide",OnHide)
    window:HookScript("OnUpdate",DetectMouseOver)
    
	local faux_window = window.faux_window
    faux_window.showtooltip = false
    window.corner.showtooltip = false
	local container = window.container
	container:ClearAllPoints()
	container:SetPoint("TOPLEFT",faux_window,"TOPLEFT",1,-titleHeight-titleBarInset)
	container:SetPoint("BOTTOMRIGHT",faux_window,"BOTTOMRIGHT",-1,1)
	container:SetSize(faux_window:GetWidth()-1,faux_window:GetHeight()-titleHeight-titleBarInset)

    
    
	local content = window.content

	content:SetSize(faux_window:GetWidth()-1,faux_window:GetHeight()-titleHeight-titleBarInset)
  
	local rangeCircle = faux_window:CreateTexture(nil, "OVERLAY", content, 1)
	rangeCircle:SetTexture([[Interface\AddOns\DXE\Textures\alert_circle]])
    rangeCircle:SetPoint("CENTER",content)
	rangeCircle:SetBlendMode("ADD")
	local scale = faux_window:GetScale()*1.42
	local range = pfl.Proximity.Range
	local w,h = content:GetSize()
	local ppy = min(w, h) / (range * 3)
	
    rangeCircle:SetSize(ppy * range * 2 * scale, ppy * range * 2 * scale)
	content.rangeCircle = rangeCircle

	local playerDot = faux_window:CreateTexture(nil, "OVERLAY", content, 2)
	playerDot:SetTexture([[Interface\Minimap\MinimapArrow]])
    playerDot:SetSize(32, 32)
	playerDot:SetPoint("CENTER",content)
	content.playerDot = playerDot
	window.skinfunc = OnLeave
	OnLeave(window)
    window.faux_window:EnableMouse(false)
	window:Show()
	CreateWindow = nil
end

local function ShowAnchors()
    if not window then
        CreateWindow()
        window.content.rangeCircle:Hide()
        window.content.playerDot:Hide()
    else
        RadarHideLines()
    end
    addon:UpdateRadarSettings()
    window.faux_window:EnableMouse(true)
    window:Show()
    
    
    local r,g,b,a = unpack(pfl.Windows.TitleBarColor)
    window.gradient:SetAlpha(1)
    window.gradient:SetTexture(r,g,b,a)
    window.gradient:SetGradient("HORIZONTAL",r,g,b,0,0,0)
    window.titlebar:SetAlpha(1)
    window.titlebar:EnableMouse(true)
    window.close:SetAlpha(1)
    window.titletext:SetAlpha(1)
    window.corner:SetAlpha(1)
    
    if pfl.Proximity.RadarHideBackground then
        local r,g,b,a = unpack(pfl.Proximity.RadarBackgroundColor)
        window.border:SetAlpha(1)
        window.faux_window:SetBackdropColor(r,g,b,a)
    end
    
    window.faux_window.showtooltip = true
    window.faux_window:SetMovable(true)
    window.corner.showtooltip = true
    window.corner:EnableMouse(true)
end

local function HideAnchors()
    if window then
        OnLeave(window)
        if not IsActive() then Deactivate() end
        
        window.faux_window.showtooltip = false
        window.faux_window:SetMovable(false)
        window.corner.showtooltip = false
        window.corner:EnableMouse(false)
        window.titlebar:EnableMouse(false)
        window.faux_window:EnableMouse(false)
    end
end

function addon:UpdateRadarLock(locked)
    radarLocked = locked
    
    if not locked then
        ShowAnchors()
    else
        HideAnchors()
    end
    
end

---------------------------------------
-- UPDATER
--------------------------------------

local updater = nil
local graphicalUpdater = nil
local setCircle
local hideDots, hideCircles
local CircleData = {}
local circlePersistTimers = {}

do
	local proxDots = {}
    local proxCircles = {}
	local cacheDots = {}
	local cacheIcons = {}
    local cacheCircles = {}

	function addon:DotResize(dotsize)
        DOTSIZE = dotsize
		if cacheDots then
			for i=1,#cacheDots do
				cacheDots[i]:SetSize(DOTSIZE,DOTSIZE)
			end
		end
		if proxDots then
			for i=1,#proxDots do
				proxDots[i]:SetSize(DOTSIZE,DOTSIZE)
			end
		end
		if cacheIcons then
			for i=1,8 do
				if cacheIcons[i] then
					cacheIcons[i]:SetSize(DOTSIZE,DOTSIZE)
				end
			end
		end

	end

	function addon:dotter()
		if window then
			if not configmode then
				window:SetScript("OnUpdate",nil)
                window:SetScript("OnUpdate",DetectMouseOver)
				testDots()
				configmode = true
			else
				window:SetScript("OnUpdate",OnUpdate)
                window:HookScript("OnUpdate",DetectMouseOver)
				hideDots()
				window.content.rangeCircle:SetVertexColor(0, 1, 0)
				configmode = false
			end
		end
	end

	local lastplayed = 0 -- When we last played an alarm sound for proximity.

	-- dx and dy are in yards
	-- class is player class
	-- facing is radians with 0 being north, counting up clockwise
	setDot = function(dx, dy, class, icon, alpha)
		local content = window.content
		local width, height = content:GetSize()
        width = width * 1.3
        height = height * 1.3
		-- range * 3, so we have 3x radius space
		local pixperyard = min(width, height) / (range * 3)

		-- rotate relative to player facing
		local rotangle = (2 * pi) - GetPlayerFacing()
		local x = (dx * cos(rotangle)) - (-1 * dy * sin(rotangle))
		local y = (dx * sin(rotangle)) + (-1 * dy * cos(rotangle))

		x = x * pixperyard
		y = y * pixperyard

		local dot = nil
		if #cacheDots > 0 then
			dot = tremove(cacheDots)
		else
			dot = content:CreateTexture(nil, "OVERLAY")
			dot:SetSize(DOTSIZE,DOTSIZE)
			dot:SetTexture([[Interface\AddOns\DXE\Textures\dot]])
		end
		proxDots[#proxDots + 1] = dot

		dot:ClearAllPoints()
		dot:SetPoint("CENTER", content, "CENTER", x, y)
		dot:SetVertexColor(unpack(vertexColors[class]))
		dot:SetAlpha(alpha or 1)
        dot:Show()

		-- add icon if marked
		if icon and icon > 0 and icon < 9 and ICONBEHAVE ~= "NONE" then
			if not cacheIcons[icon] then
				local iconframe = content:CreateTexture(nil, "OVERLAY")
				iconframe:SetTexture(format([[Interface\TARGETINGFRAME\UI-RaidTargetingIcon_%d.blp]], icon))
				iconframe:SetSize(DOTSIZE,DOTSIZE)
				cacheIcons[icon] = iconframe
			end
			local iconframe = cacheIcons[icon]
			iconframe:ClearAllPoints()
			iconframe:SetPoint("CENTER", content, "CENTER", x, y)
			iconframe:SetDrawLayer("OVERLAY", 1)
			if ICONBEHAVE == "ABOVE" then
				iconframe:Show()
                iconframe:SetAlpha(alpha or 1)
			elseif ICONBEHAVE == "REPLACE" then
				dot:Hide()
				iconframe:SetAlpha(alpha or 1)
                iconframe:Show()
			end
		end
	end

	hideDots = function()
		-- shuffle existing dots into cacheDots
		-- hide those cacheDots
		while #proxDots > 0 do
			proxDots[1]:Hide()
			cacheDots[#cacheDots + 1] = tremove(proxDots, 1)
		end
		-- hide marks
		for i=1,8 do
			if cacheIcons[i] then
				cacheIcons[i]:Hide()
			end
		end
	end
    
    hideCircles = function()
        while #proxCircles > 0 do
            proxCircles[1]:Hide()
            cacheCircles[#cacheCircles + 1] = tremove(proxCircles, 1)
        end
    end

    local function ResetCircles()
        CircleData = {}
        hideCircles()
    end

	testDots = function()
		local content = window.content
		hideDots()
		setDot(8, 4, "WARLOCK", 0)
		setDot(2, 10, "HUNTER", 0)
		setDot(-10, -4, "MAGE", 7)
		setDot(0, -8, "PRIEST", 0)
		RadarSize()
		content.rangeCircle:SetVertexColor(1,0,0)
		content.rangeCircle:Show()
		content.playerDot:Show()
	end

    setCircle = function(key, dx, dy, rangelimit, rangeColor, alpha)
        local content = window.content
		local width, height = content:GetSize()
        width = width * 1.3
        height = height * 1.3
		-- range * 3, so we have 3x radius space
		local pixperyard = min(width, height) / (range * 3)

		-- rotate relative to player facing
		local rotangle = (2 * pi) - GetPlayerFacing()
		local x = (dx * cos(rotangle)) - (-1 * dy * sin(rotangle))
		local y = (dx * sin(rotangle)) + (-1 * dy * cos(rotangle))

		x = x * pixperyard
		y = y * pixperyard

        local circleSize = rangelimit * pixperyard * 2 -- * 1.1
		local circle = nil
		if #cacheCircles > 0 then
			circle = tremove(cacheCircles)
		else
			circle = content:CreateTexture(nil, "OVERLAY")
            circle:SetDrawLayer("OVERLAY", -1)
			circle:SetTexture([[Interface\AddOns\DXE\Textures\radar_oval]])
            circle:SetBlendMode("BLEND")
		end
        circle:SetSize(circleSize,circleSize)
		proxCircles[#proxCircles + 1] = circle
        circle.key = key

		circle:ClearAllPoints()
		circle:SetPoint("CENTER", content, "CENTER", x, y)
		
        if rangeColor then
            circle:SetVertexColor(unpack(rangeColor))
        else
            circle:SetVertexColor(unpack(1, 1, 1, 1))
        end
        circle:SetAlpha((alpha or 1)*0.75)
		circle:Show()
    end

    ---------------------------------------------------------------
    -- Radar Lines 
    ---------------------------------------------------------------
    -- Functions HideRadarLines and RadarDrawLine borrowed from Routes addon
    
    local LineAPI = {}
    addon.LineAPI = setmetatable({},{
        __index = function(t,k)
            if type(k) ~= "string" then return nil end
            local func = LineAPI[k]
            if not func then
                return nil
            end
            return func
        end,
    })
    LineAPI.GetMapData = function()
        if not activeMap then addon:UpdateRadarMap() end
        local currentFloor = GetCurrentMapDungeonLevel()
        if currentFloor == 0 then currentFloor = 1 end
        id = activeMap[currentFloor]
        return id
    end
    
    LineAPI.GetPlayerMapCoords = function()
        local px, py = GetPlayerMapPosition("player")
        if px == 0 and py == 0 then
            SetMapToCurrentZone()
            px, py = GetPlayerMapPosition("player")
        end
        
        return LineAPI.GetMapData():ToMapCoords(px, py)
    end
    
    LineAPI.GetPlayerMapPosition = function()
        local x, y = LineAPI.GetPlayerMapCoords()
        return {x = x, y = y}
    end
    
    LineAPI.MapCoordsToRadarPoint = function(destX, destY)        
        local px, py = LineAPI.GetPlayerMapCoords()
        local dx = destX - px
        local dy = destY - py
        
        local width, height = window.content:GetSize()
        
        -- range * 3, so we have 3x radius space
        local pixperyard = min(width*1.3, height*1.3) / (range * 3)

        -- rotate relative to player facing
        local rotangle = (2 * pi) - GetPlayerFacing()
        local x = (dx * cos(rotangle)) - (-1 * dy * sin(rotangle))
        local y = (dx * sin(rotangle)) + (-1 * dy * cos(rotangle))

        x = x * pixperyard
        y = y * pixperyard
        
        x = x + width / 2
        y = y + height / 2
        
        return {x = x, y = y}
    end
    
    LineAPI.GetUnitPosition = function(unit)
        local x,y = GetPlayerMapPosition(unit)
        if x == 0 and y == 0 then
            SetMapToCurrentZone()
            x,y = GetPlayerMapPosition(unit)
        end
        
        return {x = x, y = y}
    end
    
    LineAPI.MapPosToRadarPoint = function(destination)
        return LineAPI.MapCoordsToRadarPoint(destination.x, destination.y)
    end
    
    RadarHideLines = function()
        if window and window.content.lines then
            for i = #window.content.usedlines, 1, -1 do
                window.content.usedlines[i]:Hide()
                tinsert(window.content.lines,tremove(window.content.usedlines))
            end
        end
    end


    LineAPI.RadarDrawLine = function(sx, sy, ex, ey, w, color)
        local relPoint = "BOTTOMLEFT"

        if not window.content.lines then
            window.content.lines={}
            window.content.usedlines={}
        end

        local T = tremove(window.content.lines) or window.content:CreateTexture(nil, "ARTWORK")
        T:SetTexture("Interface\\AddOns\\DXE\\textures\\line")
        tinsert(window.content.usedlines,T)

        T:SetDrawLayer("ARTWORK")
        T:SetVertexColor(color[1],color[2],color[3],color[4])

        -- Determine dimensions and center point of line
        local dx,dy = ex - sx, ey - sy;

        -- Calculate actual length of line
        local l = ((dx * dx) + (dy * dy)) ^ 0.5

        -- Quick escape if it's zero length
        if l == 0 then
            T:ClearAllPoints();
            T:SetTexCoord(0,0,0,0,0,0,0,0);
            T:SetPoint("BOTTOMLEFT", window.content, relPoint, cx, cy)
            T:SetPoint("TOPRIGHT",   window.content, relPoint, cx, cy)
            return T;
        end

        local cx,cy = (sx + ex) / 2, (sy + ey) / 2

        -- Normalize direction if necessary
        if (dx < 0) then dx,dy = -dx,-dy end

        -- Sin and Cosine of rotation, and combination (for later)
        local s,c = -dy / l, dx / l
        local sc = s * c

        -- Calculate bounding box size and texture coordinates
        local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy
        local factor = 0.51
        if (dy >= 0) then
            Bwid = ((l * c) - (w * s)) * factor
            Bhgt = ((w * c) - (l * s)) * factor
            BLx, BLy, BRy = (w / l) * sc, s * s, (l / w) * sc
            BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx
            TRy = BRx
        else
            Bwid = ((l * c) + (w * s)) * factor
            Bhgt = ((w * c) + (l * s)) * factor
            BLx, BLy, BRx = s * s, -(l / w) * sc, 1 + (w / l) * sc
            BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy
            TRx = TLy
        end

        -- Thanks Blizzard for adding (-)10000 as a hard-cap and throwing errors!
        -- The cap was added in 3.1.0 and I think it was upped in 3.1.1
        --  (way less chance to get the error)
        if TLx > 10000 then TLx = 10000 elseif TLx < -10000 then TLx = -10000 end
        if TLy > 10000 then TLy = 10000 elseif TLy < -10000 then TLy = -10000 end
        if BLx > 10000 then BLx = 10000 elseif BLx < -10000 then BLx = -10000 end
        if BLy > 10000 then BLy = 10000 elseif BLy < -10000 then BLy = -10000 end
        if TRx > 10000 then TRx = 10000 elseif TRx < -10000 then TRx = -10000 end
        if TRy > 10000 then TRy = 10000 elseif TRy < -10000 then TRy = -10000 end
        if BRx > 10000 then BRx = 10000 elseif BRx < -10000 then BRx = -10000 end
        if BRy > 10000 then BRy = 10000 elseif BRy < -10000 then BRy = -10000 end

        -- Set texture coordinates and anchors
        T:ClearAllPoints()
        T:SetTexCoord( TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy )
        T:SetPoint("BOTTOMLEFT", window.content, relPoint, cx - Bwid, cy - Bhgt);
        T:SetPoint("TOPRIGHT",   window.content, relPoint, cx + Bwid, cy + Bhgt);
        T:Show()
        return T
    end   
    
    LineAPI.GetHalfLine = function(originX, originY, directionX, directionY)
        local a = directionY - originY
        local b = originX - directionX
        local c = directionX*originY - originX*directionY
        local w = window.content:GetWidth()
        local h = window.content:GetHeight()
        
        local leftX, leftY = 0, -c/b
        local bottomX, bottomY = -c/a,0
        local rightX, rightY = w, (-c-a*w)/b
        local topX, topY = (-c-b*h)/a,h

        if a > 0 and b > 0 then                        
            return leftY <= h and leftX or topX,
                   leftY <= h and leftY or topY,
                   (originX <= w and originY >= 0) and originX or ((bottomX > w and rightY > 0) and rightX or bottomX),
                   (originX <= w and originY >= 0) and originY or ((bottomX > w and rightY > 0) and rightY or bottomY)
        elseif a == 0 then
            return directionX < originX and leftX or rightX,
                   directionX < originX and leftY or rightY,
                   originX > w and rightX or (originX < 0 and leftX or originX),
                   originX > w and rightY or (originX < 0 and leftY or originY)
        elseif a < 0 and b > 0 then
            return leftY >= 0 and leftX or bottomX,
                   leftY >= 0 and leftY or bottomY,
                   (originX <= w and originY <= h) and originX or ((topX > w and rightY < h) and rightX or topX),
                   (originX <= w and originY <= h) and originY or ((topX > w and rightY < h) and rightY or topY)
        elseif b == 0 then
            return directionY < originY and bottomX or topX,
                   directionY < originY and bottomY or topY,
                   originY > h and topX or (originX < 0 and bottomX or originX),
                   originY > h and topY or (originX < 0 and bottomY or originY)
        elseif a < 0 and b < 0 then            
            return rightY < 0 and bottomX or rightX,
                   rightY < 0 and bottomY or rightY,
                   (originX >= 0 and originY <= h) and originX or ((topX < 0 and leftY < h) and leftX or topX),
                   (originX >= 0 and originY <= h) and originY or ((topX < 0 and leftY < h) and leftY or topY)
        elseif a > 0 and b < 0 then            
            return rightY <= h and rightX or topX,
                   rightY <= h and rightY or topY,
                   (originX >= 0 and originY >= 0) and originX or ((bottomX < 0 and leftY > 0) and leftX or bottomX),
                   (originX >= 0 and originY >= 0) and originY or ((bottomX < 0 and leftY > 0) and leftY or bottomY)
        end
    end
    
    LineAPI.GetDistance = function(loc1, loc2) return math.sqrt(math.pow(loc1.x - loc2.x,2) + math.pow(loc1.y - loc2.y,2)) end
    
    LineAPI.GetPointAtAngleFromLine = function(origin, direction, angle, length, offsetX, offsetY)
        angle = math.rad(angle)
        local dist = LineAPI.GetDistance(origin, direction)
        local deltaX = math.abs(direction.x - origin.x)
        local deltaY = math.abs(direction.y - origin.y)
        
        return {x = (math.cos(angle + math.acos(deltaX / dist))*length) * ((direction.x - origin.x) / deltaX) + offsetX,
               y = (math.sin(angle + math.asin(deltaY / dist))*length) * ((direction.y - origin.y) / deltaY) + offsetY}
    end
    --[[
    Usage:
        LineAPI.GetLineSegment(20, 30, 40, 20)                      -- aka x1, y1, x2, y2 (number, number, number, number) version
        LineAPI.GetLineSegment({x = 20, y = 30}, {x = 40, y = 20)   -- aka origin, direction (table, table) version
    ]]
    
    LineAPI.GetLineSegment = function(arg1, arg2, arg3, arg4)
        local originX, originY, directionX, directionY
        if type(arg1) == "table" and type(arg2) == "table" and arg3 == nil and arg4 == nil then
            originX = arg1.x
            originY = arg1.y
            directionX = arg2.x
            directionY = arg2.y
        elseif type(arg1) == "number" and type(arg2) == "number" and type(arg3) == "number" and type(arg4) == "number" then
            originX = arg1
            originY = arg2
            directionX = arg3
            directionY = arg4
        else
            error(format("Provided arguments have the wrong type (%s,%s,%s,%s",type(arg1), type(arg2), type(arg3), type(arg4)))
            return
        end
        
        local a = directionY - originY
        local b = originX - directionX
        local c = directionX*originY - originX*directionY
        local w = window.content:GetWidth()
        local h = window.content:GetHeight()
        
        local leftX, leftY = 0, -c/b
        local bottomX, bottomY = -c/a,0
        local rightX, rightY = w, (-c-a*w)/b
        local topX, topY = (-c-b*h)/a,h

        if a > 0 and b > 0 then                        
            return (directionX >= 0 and directionY <= h) and directionX or ((topX < 0 and leftY < h) and leftX or topX),
                   (directionX >= 0 and directionY <= h) and directionY or ((topX < 0 and leftY < h) and leftY or topY),
                   (originX <= w and originY >= 0) and originX or ((bottomX > w and rightY > 0) and rightX or bottomX),
                   (originX <= w and originY >= 0) and originY or ((bottomX > w and rightY > 0) and rightY or bottomY)
        elseif a == 0 then
            return directionX < originX and leftX or rightX,
                   directionX < originX and leftY or rightY,
                   originX > w and rightX or (originX < 0 and leftX or originX),
                   originX > w and rightY or (originX < 0 and leftY or originY)
        elseif a < 0 and b > 0 then
            return (directionX >= 0 and directionY >= 0) and directionX or ((bottomX < 0 and leftY > 0) and leftX or bottomX),
                   (directionX >= 0 and directionY >= 0) and directionY or ((bottomX < 0 and leftY > 0) and leftY or bottomY),
                   (originX <= w and originY <= h) and originX or ((topX > w and rightY < h) and rightX or topX),
                   (originX <= w and originY <= h) and originY or ((topX > w and rightY < h) and rightY or topY)
        elseif b == 0 then
            return directionY < originY and bottomX or topX,
                   directionY < originY and bottomY or topY,
                   originY > h and topX or (originX < 0 and bottomX or originX),
                   originY > h and topY or (originX < 0 and bottomY or originY)
        elseif a < 0 and b < 0 then            
            return (directionX <= w and directionY >= 0) and directionX or ((bottomX > w and rightY > 0) and rightX or bottomX),
                   (directionX <= w and directionY >= 0) and directionY or ((bottomX > w and rightY > 0) and rightY or bottomY),
                   (originX >= 0 and originY <= h) and originX or ((topX < 0 and leftY < h) and leftX or topX),
                   (originX >= 0 and originY <= h) and originY or ((topX < 0 and leftY < h) and leftY or topY)
        elseif a > 0 and b < 0 then            
            return (directionX <= w and directionY <= h) and directionX or ((topX > w and rightY < h) and rightX or topX),
                   (directionX <= w and directionY <= h) and directionY or ((topX > w and rightY < h) and rightY or topY),
                   (originX >= 0 and originY >= 0) and originX or ((bottomX < 0 and leftY > 0) and leftX or bottomX),
                   (originX >= 0 and originY >= 0) and originY or ((bottomX < 0 and leftY > 0) and leftY or bottomY)
        end
    end
    
    LineAPI.GetAngle = function(origin, destination, point)
        local a = LineAPI.GetDistance(destination, point)
        local b = LineAPI.GetDistance(origin, point)
        local c = LineAPI.GetDistance(origin, destination)
        
        return math.deg(math.acos((-a^2+b^2+c^2)/(2*b*c)))
    end
        
    LineAPI.GetPointFromLineDistance = function(origin, destination, point)
        local a = destination.y - origin.y
        local b = origin.x - destination.x
        local c = destination.x * origin.y - origin.x * destination.y
        
        return math.abs(a*point.x+b*point.y+c)/math.sqrt(a^2+b^2)
    end
    
    LineAPI.IsPointAtDistanceFromLineSegment = function(origin, destination, pointQ, distance)
        local poDist = LineAPI.GetDistance(pointQ, origin) -- pointQn -> origi distance
        if poDist <= distance then return true end
        
        local pdDist = LineAPI.GetDistance(pointQ, destination) -- pointQ -> destination distance
        if pdDist <= distance then return true end
        
        -- Middle point between origin and destination
        local s = {
            x = (origin.x + destination.x) / 2,
            y = (origin.y + destination.y) / 2,
        }
        
        -- Figuring out the point C on the line origin-destination
        --                      and on the line perpendicular to it on which the point Q
        local deltaX = destination.x - origin.x
                       + ((destination.x == origin.x) and 1e-300 or 0) -- to avoid div by 0
        
        local k1 = (destination.y - origin.y) / deltaX
        local q1 = origin.y - origin.x * k1
        
        local k2 = math.tan(math.atan(k1) + math.pi / 2)
        local q2 = pointQ.y - pointQ.x * k2
        
        local cx = (q2 - q1) / (k1 - k2)
        local cy = k1*cx + q1
        
        local c = {
            x = cx,
            y = cy,
        }
        
        local qcDist = LineAPI.GetDistance(pointQ, c)
        local scDist = LineAPI.GetDistance(s, c)
        local sdDist = LineAPI.GetDistance(s, destination)
        
        return (scDist <= sdDist) and (qcDist < distance)
    end
    
    LineAPI.GetRadarRange = function()
        return range--*1.1
    end

    local RadarAPI = {}
    function RadarAPI:CountPlayersInRange(player, range, mapData, playerX, playerY)
        local upperBound = GetNumRaidMembers() == 0 and GetNumPartyMembers() or GetNumRaidMembers()
        local unitPrefix = GetNumRaidMembers() == 0 and "party" or "raid"
        if not playerX and not playerY then
            playerX, playerY = GetPlayerMapPosition(player)
        end
        
        local count = 0
        local function isUnitClose(unit)
            if not player or (not UnitIsUnit(player, unit) and not UnitIsDead(unit)) then
                local unitX, unitY = GetPlayerMapPosition(unit)
                if unitX ~= 0 and unitY ~= 0 then
                    local dx = (unitX - playerX) * mapData.w
                    local dy = (unitY - playerY) * mapData.h
                    local unitrange = (dx * dx + dy * dy) ^ 0.5
                    
                    if unitrange <= range then --* 1.1 then
                        return true
                    end
                end
            end
            
            return false
        end
        
        if GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0 then
            for i = 1, upperBound do
                if isUnitClose(format("%s%d", unitPrefix, i)) then count = count + 1 end
            end
        end
        
        if GetNumRaidMembers() == 0 then
            if isUnitClose("player") then count = count + 1 end
        end
        
        return count
    end

	local function updateProximityRadar()
		local content = window.content
		local srcX, srcY = GetPlayerMapPosition("player")
		if srcX == 0 and srcY == 0 then
			SetMapToCurrentZone()
			srcX, srcY = GetPlayerMapPosition("player")
		end

		-- XXX This could probably be checked and set when the proximity
		-- XXX display is opened? We won't change dungeon floors while
		-- XXX it is open, surely.
		local id = nil
        if activeMap then
			local currentFloor = GetCurrentMapDungeonLevel()
			if currentFloor == 0 then currentFloor = 1 end
			id = activeMap[currentFloor]
		else
            id = {w = 1500.0, h = 1000.0 }
        end
       
		local anyoneClose = nil

		-- XXX We can't show/hide dots every update, that seems excessive.
		hideDots()
        hideCircles()

        --local groupString = (GetNumRaidMembers() > 5) and "raid" or "party"
		local extraMult = ((pfl.Proximity.RadarExtraDistance + 100) / 100)
        local upperBound = GetNumRaidMembers() == 0 and GetNumPartyMembers() or GetNumRaidMembers()
        local unitPrefix = GetNumRaidMembers() == 0 and "party" or "raid"
        local proxirange = range * 1.1 -- range to make the dot appear in range of pre-set range
        local radarrange = proxirange * extraMult -- range to make the dot appear
             
        for i = 1, upperBound do
			local n = format("%s%d", unitPrefix, i)
            if not UnitIsDead(n) and not UnitIsUnit(n, "player") then
				local unitX, unitY = GetPlayerMapPosition(n)
                if unitX ~= 0 and unitY ~= 0 then
                    local dx = (unitX - srcX) * id.w
                    local dy = (unitY - srcY) * id.h
                    local prange = (dx * dx + dy * dy) ^ 0.5
                    
                    if prange < radarrange then --*1.1 then -- 1.5
                        local alpha
                        if prange <= proxirange then
                            alpha = 1
                        elseif prange <= radarrange then --* 1.1 then
                            alpha = 1 - ((prange - proxirange) / (radarrange - proxirange))
                        else
                            alpha = 0
                        end
                        local _,class = UnitClass(n)
                        setDot(dx, dy, class, GetRaidTargetIndex(n), alpha)
                        if prange <= range then --*1.09 then  -- add 10% because of mapData inaccuracies, e.g. 6 yards actually testing for 5.5 on chimaeron = ouch
                            anyoneClose = true
                        end
                    end
                end
			end
		end
        
        local customAnyoneClose = false
        local windows = addon.CE.windows
       
        if windows then
            RadarHideLines()
            if windows.radarhandler then
                local moduleHandler = addon.CE.windows.radarhandler
                if type(moduleHandler) == "function" then
                    moduleHandler(LineAPI, id)
                end
                
                customAnyoneClose = addon.CE.windows.customanyoneclose and addon.CE.windows.customanyoneclose(LineAPI, id) or false
            end

        end
        
        local circleAnyoneClose = false
        for key,info in pairs(CircleData) do
            local fixed = info.x and info.y
            
            if fixed or not UnitIsDead(info.player) then    
                local unitX, unitY
                if fixed then
                    unitX = tonumber(info.x) or info.x
                    unitY = tonumber(info.y) or info.y
                else
                    unitX, unitY = GetPlayerMapPosition(info.player)
                end
                
                if unitX ~= 0 and unitY ~= 0 then
                    if type(unitX) == "string" then error("unitX probably hasn't been set correctly (unitX = "..unitX..")") end
                    if type(unitY) == "string" then error("unitY probably hasn't been set correctly (unitY = "..unitY..")") end
                    
                    local dx = (unitX - srcX) * id.w
                    local dy = (unitY - srcY) * id.h
                    
                    local prange = (dx * dx + dy * dy) ^ 0.5
                    
                    --                        + 10 % for fading in
                    if prange <= radarrange * 1.1 then
                        local rangeColor
                        if not info.manualcheck then
                            if info.mode == "stack" then
                                local playerCount = RadarAPI:CountPlayersInRange(info.player, info.range, id, unitX, unitY)
                                if playerCount == 0 then
                                    rangeColor = addon.db.profile.Proximity.RadarCircleColorDanger
                                elseif playerCount >= info.count then
                                    rangeColor = info.color or addon.db.profile.Proximity.RadarCircleColorSafe
                                else
                                    rangeColor = addon.db.profile.Proximity.RadarCircleColorInRange
                                end
                                if fixed or not UnitIsUnit(info.player, "player") then
                                    circleAnyoneClose = circleAnyoneClose or (prange > info.range) -- * 1.1)
                                end
                            elseif info.mode == "avoid" then
                                local playerCount = RadarAPI:CountPlayersInRange(info.player, info.range, id, unitX, unitY)
                                if playerCount > 0 then
                                    rangeColor = addon.db.profile.Proximity.RadarCircleColorDanger
                                else
                                    rangeColor = info.color or addon.db.profile.Proximity.RadarCircleColorSafe
                                end
                                if fixed or not UnitIsUnit(info.player, "player") then
                                    circleAnyoneClose = circleAnyoneClose or (prange < info.range) -- * 1.1)
                                end
                            elseif info.mode == "enter" then
                                if prange >= info.range then
                                    rangeColor = addon.db.profile.Proximity.RadarCircleColorDanger
                                else
                                    rangeColor = info.color or addon.db.profile.Proximity.RadarCircleColorSafe
                                end
                            end
                        else
                            if info.inrange then
                                rangeColor = addon.db.profile.Proximity.RadarCircleColorDanger
                            else
                                rangeColor = info.color or addon.db.profile.Proximity.RadarCircleColorSafe
                            end
                        end
                        
                        local alpha
                        
                        if prange <= radarrange then
                            alpha = 1
                        elseif prange <= radarrange * 1.1 then
                            alpha = 1-((prange - radarrange) / (radarrange * 0.1))
                        else
                            alpha = 0
                        end
                        
                        if rangeColor.r and rangeColor.g and rangeColor.b then
                            rangeColor = {rangeColor.r, rangeColor.g, rangeColor.b}
                        end
                        
                        setCircle(key, dx, dy, info.range, rangeColor,alpha)
                    end
                end
            end
        end
        if (not nodistancecheck and anyoneClose) or customAnyoneClose or circleAnyoneClose then
            content.rangeCircle:SetVertexColor(1, 0, 0)
        else
            lastplayed = 0
            content.rangeCircle:SetVertexColor(0, 1, 0)
        end
	end

	local delay = 0.05

	-- 20x per second for radar mode
	function OnUpdate(self, elapsed)
		if delay > 0 then
			counter = counter + elapsed
			if counter < delay then return end
		end
		updateProximityRadar()
	end
    
    function addon:ResetRadar()
        if addon.CE.windows then
            local reset = addon.CE.windows.radarreset
            if reset then reset() end
        end
        
        ResetCircles()
    end

---------------------------------------
-- RADAR CIRCLES ----------------------
---------------------------------------
    function addon:RadarAddCircleOnPlayer(key, mode, player, range, manualcheck, inrange, persist, color)
        local circleKey = format("%s@%s",key,player)
        CircleData[circleKey] = {
            mode = mode.type,
            player = player,
            range = range,
            count = mode.count,
            manualcheck = manualcheck,
            inrange = inrange,
            persist = persist,
            color = color
        }
        
        if persist then
            if circlePersistTimers[circleKey] then
                addon:CancelTimer(circlePersistTimers[circleKey],true)
                circlePersistTimers[circleKey] = nil
            end
            circlePersistTimers[circleKey] = addon:ScheduleTimer("RemoveRadarByKey",persist,circleKey)
        end
    end
    
    function addon:RadarAddCircleAtPosition(key, mode, x, y, range, manualcheck, inrange, persist, color)
        local circleKey = format("%s@%s@%s",key,x,y)
        CircleData[circleKey] = {
            mode = mode.type,
            x = x,
            y = y,
            range = range,
            count = mode.count,
            manualcheck = manualcheck,
            inrange = inrange,
            persist = persist,
            color = color,
        }
        
        if persist then
            if circlePersistTimers[circleKey] then
                addon:CancelTimer(circlePersistTimers[circleKey],true)
                circlePersistTimers[circleKey] = nil
            end
            circlePersistTimers[circleKey] = addon:ScheduleTimer("RemoveRadarByKey",persist,circleKey)
        end
    end
    
    function addon:RemoveRadarByKey(circleKey)
        CircleData[circleKey] = nil
        local removedCircle = nil
        for i,circle in ipairs(proxCircles) do
            if circle.key == circleKey then
                removedCircle = circle
                circle.key = nil
                circle:Hide()
                tremove(proxCircles, i)
                break
            end
        end
        
        if removedCircle then
            cacheCircles[#cacheCircles + 1] = removedCircle
        end
    end
    
    function addon:RadarRemoveCircleFromPlayer(key, player)
        local circleKey = format("%s@%s",key,player)
        addon:RemoveRadarByKey(circleKey)
    end
    
    function addon:RadarRemoveCircleByKey(circleKey)
        for key,_ in pairs(CircleData) do
            if key:match(circleKey) then
                addon:RemoveRadarByKey(key)
            end
        end
    end
    
    function addon:RadarRemoveFixedCircleByPlayer(circleKey, player, range)
        if not UnitExists(player) then 
            return nil
        end
        
        local mapData = LineAPI:GetMapData()
        local playerPosition = mapData:ToMapPos(LineAPI.GetUnitPosition(player))
        local removerange = range or circle.range
        for key,circle in pairs(CircleData) do
            if string.match(key, "^"..circleKey.."@%d+%.%d+@%d+%.%d+$") then
                local circlePosition = mapData:ToMapPos({x = circle.x, y = circle.y})
                local distance = LineAPI.GetDistance(circlePosition, playerPosition)
                if distance < removerange then
                    addon:RadarRemoveCircleByKey(key)
                end
            end
        end
    end
    
    local function RadarSetCircleInRange(circleKey, inrange)
        local data = CircleData[circleKey]
        if data and data.manualcheck == true then
            CircleData[circleKey].inrange = inrange
        end
    end
    
    function addon:RadarSetRange(circleKey, range)
        for key,_ in pairs(CircleData) do
            if key:match(circleKey) then
                CircleData[key].range = range
            end
        end
    end
    
    function addon:RadarSetPlayerInRange(key, player, inrange)
        RadarSetCircleInRange(format("%s@%s",key,player), inrange)
    end
    
    function addon:RadarSetLocationInRange(key, x, y, inrange)
        RadarSetCircleInRange(format("%s@%s@%s",key,x,y), inrange)
    end
end


---------------------------------------
-- API
---------------------------------------

function addon:Radar(enc_range,disableDistanceCheck)    
    addon:HideProximity()
    RadarHideLines()
    if not window then CreateWindow() end
    addon:UpdateRadarSettings()
    
    if not radarLocked then ShowAnchors() else HideAnchors() end
    window:Show()
    
    if not IsActive() then Activate() end
    range = enc_range or pfl.Proximity.Range
    if disableDistanceCheck ~= nil then
        nodistancecheck = disableDistanceCheck
    else
        if addon.CE.windows and addon.CE.windows.nodistancecheck then
            nodistancecheck = addon.CE.windows.nodistancecheck
        end
    end
    
    local content = window.content
    content.rangeCircle:SetAlpha(nodistancecheck and pfl.Proximity.RadarNoDistanceCheckAlpha or 1)
    
	UpdateTitle()
	SetMapToCurrentZone()
    activeMap = addon:GetMapData(GetMapInfo())
	if activeMap then
		RadarSize()
		content.playerDot:Show()
		content.rangeCircle:Show()
	end
end

function addon:PopupRadar(enc_range, disableDistanceCheck)
    addon:Radar(true, enc_range, disableDistanceCheck)
end

function addon:UpdateRadarMap()   
    activeMap = addon:GetMapData(GetMapInfo())
end

function addon:HideRadar()
	Deactivate()
end

function addon:IsRadarShown()
    return IsActive() and radarLocked
end

addon:RegisterWindow(L["Radar"],function() addon:Radar() end)

---------------------------------------
-- SETTINGS
---------------------------------------

function addon:UpdateRadarSettings()    
	rows = pfl.Proximity.Rows
	range = range or pfl.Proximity.Range
	delay = pfl.Proximity.Delay
	invert = pfl.Proximity.Invert
	DOTSIZE = pfl.Proximity.DotSize
	ICONBEHAVE = pfl.Proximity.RaidIcons
	rangefunc = range <= 10 and ProximityFuncs[10] or (range <= 11 and ProximityFuncs[11] or ProximityFuncs[18])

	if window then
		UpdateTitle()
		RadarSize()
        local content = window.content
        content.rangeCircle:SetAlpha(nodistancecheck and pfl.Proximity.RadarNoDistanceCheckAlpha or 1)
		addon:DotResize(DOTSIZE)
		if (pfl.Proximity.Dummy and not configmode) or (not pfl.Proximity.Dummy and configmode) then
			addon:dotter()
		elseif pfl.Proximity.Dummy and configmode then --bad hack
			addon:dotter()
			addon:dotter()
		end
	end
end

local function RefreshProfile(db)
	pfl = db.profile
	addon:UpdateRadarSettings()
end

addon:AddToRefreshProfile(RefreshProfile)
