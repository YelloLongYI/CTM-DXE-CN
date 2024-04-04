local addon = DXE;
local L = addon.L;
local gbl, pf1


local function RefreshProfile(db)
	gbl, pfl = db.global, db.profile
end
addon:AddToRefreshProfile(RefreshProfile)

---------------------------------------------
-- UTILS
---------------------------------------------

local function search(t,value,i)
	for k,v in pairs(t) do
		if i then
			if type(v) == "table" and v[i] == value then return k end
		elseif v == value then return k end
	end
end

---------------------------------------------
-- PANE
---------------------------------------------
local Pane
local PaneTextures = "Interface\\AddOns\\DXE\\Textures\\Pane\\"

function addon:ScalePaneAndCenter()
	local x,y = Pane:GetCenter()
	local escale = Pane:GetEffectiveScale()
	x,y = x*escale,y*escale
	Pane:SetScale(pfl.Pane.Scale)
	escale = Pane:GetEffectiveScale()
	x,y = x/escale,y/escale
	Pane:ClearAllPoints()
	Pane:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x,y)
	addon:SavePosition(Pane)
end

function addon:SetPaneWidth()
	Pane:SetWidth(pfl.Pane.Width)
end

function addon:UpdatePaneVisibility(enteringWorld)
    if not addon:ShouldStartTimer(addon.CE) then return end
    if addon.db.profile.Enabled and pfl.Pane.Show then
		local op = 0
		local instanceType = select(2,IsInInstance())

        op = op + (pfl.Pane.OnlyInRaid and (addon.GroupType == "RAID"	and 1  or 0) or 1)
		op = op + (pfl.Pane.OnlyInParty and ((addon.GroupType == "PARTY" or addon.GroupType == "RAID") and 2 or 0) or  2)
		op = op + (pfl.Pane.OnlyInRaidInstance	and (instanceType == "raid" and 4  or 0) or 4)
		op = op + (pfl.Pane.OnlyInPartyInstance and (instanceType == "party"	and 8  or 0) or 8)
		op = op + (pfl.Pane.OnlyIfRunning and (self:IsRunning() and 16 or 0) or 16)
        op = op + ((not pfl.Pane.ShowTest and addon:GetActiveEncounter() == "default") and 0 or 32)
        op = op + ((not pfl.Pane.ShowTest and addon:IsModuleTrash(addon.CE.key)) and 32 or 0)
    
        local show = op == 63
		Pane[show and "Show" or "Hide"](Pane)
        if show and Pane:GetAlpha() == 0 then
            local pullTime = Pane.PullTime
            if pullTime then 
                Pane.elapsedTime = GetTime() - Pane.PullTime
            end
        end
        
		-- Fading
		UIFrameFadeRemoveFrame(Pane)
		local fadeTable = Pane.fadeTable
		fadeTable.fadeTimer = 0
		local a = pfl.Pane.OnlyOnMouseover and (addon.Pane.MouseIsOver and 1 or 0) or 1
		local p_a = Pane:GetAlpha()
		if not show and p_a > 0 then
			fadeTable.startAlpha = p_a
			fadeTable.endAlpha = 0
			fadeTable.finishedFunc = Pane.Hide
			UIFrameFade(Pane,fadeTable)
		elseif show and a ~= p_a then
			fadeTable.startAlpha = p_a
			fadeTable.endAlpha = a
			UIFrameFade(Pane,fadeTable)
		end
        local oa = addon.CE.onactivate
        if enteringWorld then
            if oa then
                self:SetPhaseMarkers(oa.phasemarkers)
            else
                self:ClearAllPhaseMarkers()
            end
        end
	else
		self.Pane:SetAlpha(0)
		self.Pane:Hide()
	end
end

function addon:UpdateBestTimer(reloadSpeedkill, optionsUpdate)
    local CE = addon.CE
    if not CE or not CE.key or CE.key == "default" then
        Pane:SetHeight(25)
        self.Pane.besttimer:SetTime(0,true,2)
        self.Pane.besttimer:Hide()
        self.Pane.besttimerlabel:Hide()
        self.Pane.besttimeroffset:Hide()
        Pane.timer:ClearAllPoints()
        Pane.timer:SetPoint("BOTTOMLEFT",5-60,2)
        Pane.besttimer:ClearAllPoints()
    else
        local besttime = addon:GetBestTime(addon.CE.key)
        local formertime = addon:GetBestTime(addon.CE.key,addon:GetBestTimeKey(addon.CE.key),"formertime")
        if pfl.Pane.ShowBestTimePane then
            if besttime then
                if reloadSpeedkill or not addon.Pane.showBestTimeDiff then
                    Pane:SetHeight(50)
                    Pane.timer:ClearAllPoints()
                    Pane.timer:SetPoint("TOPLEFT",5-60,-3)
                    Pane.besttimer:ClearAllPoints()
                    Pane.besttimer:SetPoint("BOTTOMRIGHT",-5-60,0)
                    Pane.besttimer:Show()
                    
                    Pane.besttimerlabel:ClearAllPoints()
                    Pane.besttimerlabel:SetPoint("BOTTOMRIGHT",-80, -5)
                    Pane.besttimerlabel:Show()
                    
                    Pane.besttimeroffset:ClearAllPoints()
                    Pane.besttimeroffset:SetPoint("BOTTOMLEFT",-18, 5)
                    Pane.besttimeroffset:Show()
                    self.Pane.besttimer:SetTime(besttime,true,2)
                    Pane.besttimerlabel:SetText("Speed kill:")
                    addon.Pane.showBestTimeDiff = false
                    if not optionsUpdate then addon:ResetTimer() end
                    addon:UpdateBestTimeDiff()
                else
                    Pane.besttimerlabel:SetText("Former speed kill:")
                end
            else
                local groupType = select(2,GetInstanceInfo())
                if groupType ~= "none" then                
                    Pane:SetHeight(25)
                    self.Pane.besttimer:SetTime(0,true,2)
                    self.Pane.besttimer:Hide()
                    self.Pane.besttimerlabel:Hide()
                    self.Pane.besttimeroffset:Hide()
                    Pane.timer:ClearAllPoints()
                    Pane.timer:SetPoint("BOTTOMLEFT",5-60,2)
                    Pane.besttimer:ClearAllPoints()
                else
                end
            end
        else
            Pane:SetHeight(25)
            self.Pane.besttimer:Hide()
            self.Pane.besttimerlabel:Hide()
            self.Pane.besttimeroffset:Hide()
        end
    end
end

do
	local size = 20
	local buttons = {}
    local ButtonNames = {}
    addon.PaneButtonNames = ButtonNames
	--- Adds a button to the encounter pane
	-- @param normal The normal texture for the button
	-- @param highlight The highlight texture for the button
	-- @param onclick The function of the OnClick script
	-- @param anchor SetPoints the control LEFT, anchor, RIGHT
	function addon:AddPaneButton(normal,highlight,OnClick,name,text)
		local control = CreateFrame("Button",nil,self.Pane)
		control:SetWidth(size)
		control:SetHeight(size)
		control:SetPoint("LEFT",buttons[#buttons] or self.Pane.timer,"RIGHT")
        control:SetScript("OnClick",OnClick)
		control:RegisterForClicks("AnyUp")
		control:SetNormalTexture(normal)
		control:SetHighlightTexture(highlight)
		self:AddTooltipText(control,name,text)
		control:HookScript("OnEnter",function(self) addon.Pane.MouseIsOver = true; addon:UpdatePaneVisibility() end)
		control:HookScript("OnLeave",function(self) addon.Pane.MouseIsOver = false; addon:UpdatePaneVisibility()end)
        addon.defaults.profile.Pane.ButtonsVisibility[name] = addon.defaults.profile.Pane.ButtonsVisibility[name] == nil and true or addon.defaults.profile.Pane.ButtonsVisibility[name]
        ButtonNames[#ButtonNames+1] = {
            name = name,
            texture = normal,
        }
        control.name = name

		buttons[#buttons+1] = control
		return control
	end
    
    function addon:UpdatePaneButton(button)
        if button.getbuttonicon then
            local newIcon = button.getbuttonicon()
            button:SetNormalTexture(newIcon)
        end
    end
    
    function addon:UpdatePaneButtons()
        for i,button in ipairs(buttons) do
            local pflVisibility = addon.db.profile.Pane.ButtonsVisibility[button.name]
            
            if pflVisibility == nil then
                button.invisible = false
            else
                button.invisible = not pflVisibility
            end
            if not button.invisible then button:Show() else button:Hide() end
            
            button:ClearAllPoints()
            local anchor
            for j=i-1,1,-1 do
                if not buttons[j].invisible then
                    anchor = buttons[j]
                    break
                end
            end
            local offset = 0
            if not anchor then 
                anchor = self.Pane.timer
                offset = 60
            end
            
            button:SetPoint("LEFT",anchor,"RIGHT",offset,0)
        end
    end
end


-- Idea based off RDX's Pane
function addon:CreatePane()
	Pane = CreateFrame("Frame","DXEPane",UIParent)
	Pane:SetAlpha(0)
	Pane:Hide()
	Pane:SetClampedToScreen(true)
	addon:RegisterBackground(Pane)
	Pane.border = CreateFrame("Frame",nil,Pane)
	Pane.border:SetAllPoints(true)
	addon:RegisterBorder(Pane.border)
	Pane:SetWidth(pfl.Pane.Width)
	Pane:SetHeight(25) -- original 25
	Pane:EnableMouse(true)
	Pane:SetMovable(true)
	Pane:SetPoint("CENTER")
	Pane:SetScale(pfl.Pane.Scale)
	self:RegisterMoveSaving(Pane,"CENTER","UIParent","CENTER",nil,nil,true)
	self:LoadPosition("DXEPane")
	Pane:SetUserPlaced(false)
	self:AddTooltipText(Pane,"Pane",L["|cffffff00Shift + Click|r to move"])
	local function OnUpdate() addon:LayoutHealthWatchers() addon:LayoutCounters() end
	Pane:HookScript("OnMouseDown",function(self) self:SetScript("OnUpdate",OnUpdate) end)
	Pane:HookScript("OnMouseUp",function(self) self:SetScript("OnUpdate",nil) end)
	Pane:HookScript("OnEnter",function(self) self.MouseIsOver = true; addon:UpdatePaneVisibility() end)
	Pane:HookScript("OnLeave",function(self) self.MouseIsOver = false; addon:UpdatePaneVisibility() end)
	Pane.fadeTable = {timeToFade = 0.5, finishedArg1 = Pane}
  	self.Pane = Pane
    Pane.elapsedTime = 0
	Pane.timer = addon.Timer:New(Pane,19,11)
    Pane.timer:SetPoint("TOPLEFT",-65,-5)
    
    Pane.showBestTimeDiff = false
    Pane.besttimer = addon.Timer:New(Pane,19,11)
    Pane.besttimerlabel = Pane:CreateFontString(nil,"OVERLAY")
    Pane.besttimeroffset = Pane:CreateFontString(nil,"OVERLAY")
    addon:RegisterFontString(Pane.besttimerlabel,10)
    Pane.besttimerlabel:SetText("Speed kill:")
    Pane.besttimerlabel:SetJustifyH("RIGHT")
    Pane.besttimerlabel:SetWidth(100)
    Pane.besttimerlabel:SetHeight(25)
    addon:RegisterFontString(Pane.besttimeroffset,13, "OUTLINE")
    Pane.besttimeroffset:SetWidth(100)
    Pane.besttimeroffset:SetHeight(25)
    Pane.besttimeroffset:SetJustifyH("RIGHT")
                

	-- Add StartStop control
	Pane.startStop = self:AddPaneButton(
		PaneTextures.."Stop",
		PaneTextures.."Stop",
		function(self,button)
			if button == "LeftButton" then
				addon:StopEncounter()
			elseif button == "RightButton" then
				addon.Alerts:QuashByPattern("^custom")
			end
		end,
		L["Stop"],
		L["|cffffff00Click|r stops the current encounter"].."\n"..L["|cffffff00Right-Click|r stops all custom bars"]
	)

    
	-- Add Config control
	Pane.config = self:AddPaneButton(
		PaneTextures.."Menu",
		PaneTextures.."Menu",
		function() self:ToggleConfig() end,
		L["Configuration"],
		L["Toggles the settings window"]
	)

	-- Create dropdown menu for folder
	local selector = self:CreateSelectorDropDown()
	Pane.SetFolderValue = function(key)
		UIDropDownMenu_SetSelectedValue(selector,key)
	end
	-- Add Folder control
	Pane.folder = self:AddPaneButton(
		PaneTextures.."Folder",
		PaneTextures.."Folder",
		function() ToggleDropDownMenu(1,nil,selector,Pane.folder,0,0) end,
		L["Selector"],
		L["Activates an encounter"]
	)

    Pane.mute = self:AddPaneButton(
		PaneTextures.."Unmuted",
		PaneTextures.."Unmuted",
		function() self:ToggleMute() end,
		L["Mute"],
		L["Toggle mute for all sounds."]
	)

	Pane.lock = self:AddPaneButton(
		PaneTextures.."Locked",
		PaneTextures.."Locked",
		function() self:ToggleLock() end,
		L["Locking"],
		L["Toggle frame anchors"]
	)

	local windows = self:CreateWindowsDropDown()
	Pane.windows = self:AddPaneButton(
		PaneTextures.."Windows",
		PaneTextures.."Windows",
		function() ToggleDropDownMenu(1,nil,windows,Pane.windows,0,0) end,
		L["Windows"],
		L["Make windows visible"]
	)
    
    Pane.RoleCheckBtn = self:AddPaneButton(
        PaneTextures.."RoleCheck",
        PaneTextures.."RoleCheck",
        function() addon:RoleCheck() end,
        L["Role Check"],
        L["|cffffff00Click|r initiates a role check."]
    )
    
    Pane.ReadyCheckBtn = self:AddPaneButton(
		PaneTextures.."Defeat",
		PaneTextures.."Defeat",
		function(self,button)
			if button == "LeftButton" then
				addon:ReadyCheck()
			end
		end,
		L["Ready Check"],
		L["|cffffff00Click|r initiates a ready check."]
	)
    
    local pullsbreaks = self:CreatePullsBreaksDropDown()
	Pane.pull = self:AddPaneButton(
		PaneTextures.."Pull",
		PaneTextures.."Pull",
		function(self,button)
			if button == "LeftButton" then
				local time = addon.db.profile.SpecialTimers.PullTimers[addon.db.profile.SpecialTimers.PullTimerPrefered] or 10
                addon:AnnouncePull("pull "..time)
			elseif button == "RightButton" then
                ToggleDropDownMenu(1,nil,pullsbreaks,Pane.pull,0,0)
            elseif button == "MiddleButton" then
                if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
                    addon:Print("\124cffff0000You have to be member of a party or a raid group!\124r")    
                    return
                end
                if GetNumRaidMembers() > 0 and addon:GetRaidRank() < 1 then 
                    addon:Print("\124cffff0000You have insufficient permissions!\124r")    
                    return
                end
                addon:AnnouncePullCancel()
                addon:AnnounceBreakCancel()
            end
		end,
        
		L["Pull Countdown"],
		L["|cffffff00Click|r triggers the default Pull preset."].."\n"..L["|cffffff00Middle-Click|r cancels pull and break timers for everyone."].."\n"..L["|cffffff00Right-Click|r gives a list of Pull and Break presets."]
	)
    
	self:CreateHealthWatchers(Pane)
    self:CreateCounters(Pane)
	self.CreatePane = nil
    addon:UpdatePaneButtonPermission()
end

function addon:SkinPane()
	local db = pfl.Pane

	-- Health watchers
	for i,hw in ipairs(addon.HW) do
		hw:SetNeutralColor(db.NeutralColor)
		hw:SetLostColor(db.LostColor)
		hw:ApplyNeutralColor()

		hw.title:SetFont(hw.title:GetFont(),db.TitleFontSize)
		hw.title:SetVertexColor(unpack(db.FontColor))
		hw.health:SetFont(hw.health:GetFont(),db.HealthFontSize)
		hw.health:SetVertexColor(unpack(db.FontColor))
	end
end

---------------------------------------------
-- HEALTH WATCHERS
---------------------------------------------
local HW = {}
local HW_MAX = 5
addon.HW = HW
local DEAD = DEAD:upper()

-- Holds a list of tables
-- Each table t has three values
-- t[1] = npcid
-- t[2] = last known perc
local SortedCache = {}
local SeenNIDS = {}
--[===[@debug@
addon.SortedCache = SortedCache
addon.SeenNIDS = SeenNIDS
--@end-debug@]===]

-- Currently, only four are needed. We don't want to clutter the screen
local UNKNOWN = _G.UNKNOWN
function addon:CreateHealthWatchers(Pane)
	local function OnMouseDown() if IsShiftKeyDown() then Pane:StartMoving() end end
	local function OnMouseUp() Pane:StopMovingOrSizing(); addon:SavePosition(Pane) end

	local function OnAcquired(self,event,unit)
        local goal = self:GetGoal()
        if not self:IsTitleSet() then
			if type(goal) == "number" then
                -- Should only enter once per name
				local name = UnitName(unit)
				if name ~= UNKNOWN then
					gbl.L_NPC[goal] = name
					self:SetTitle(name)
				end
			elseif type(goal) == "string" then
                if string.match(goal,"^0x.+$") then -- goal is GUID
                    local uGUID = UnitGUID(unit)
                    local id = tonumber((goal):sub(-12, -9), 16)
                    if uGUID == goal then
                        local name = UnitName(unit)
                        if name ~= UNKNOWN then
                            gbl.L_NPC[id] = name
                            self:SetTitle(name)
                        end
                    end
                else -- goal is unit
                    local name = UnitName(goal)
                    if name ~= UNKNOWN then
                        local id = tonumber((UnitGUID(goal)):sub(-12, -9), 16)
                        gbl.L_NPC[id] = name
                        self:SetTitle(name)
                    end
                end
			end
		end
		addon.callbacks:Fire("HW_TRACER_ACQUIRED",unit,goal)
	end

	for i=1,HW_MAX do
		local hw = addon.HealthWatcher:New(Pane)
        hw:SkinBorder(hw.border,false)
		self:AddTooltipText(hw,"Pane",L["|cffffff00Shift + Click|r to move"])
		hw:HookScript("OnEnter",function(self) Pane.MouseIsOver = true; addon:UpdatePaneVisibility() end)
		hw:HookScript("OnLeave",function(self) Pane.MouseIsOver = false; addon:UpdatePaneVisibility()end)
		hw:SetScript("OnMouseDown",OnMouseDown)
		hw:SetScript("OnMouseUp",OnMouseUp)
		hw:SetParent(Pane)
		hw:SetCallback("HW_TRACER_ACQUIRED",OnAcquired)
        for j=1,5 do
            hw:CreatePhaseMarker(j)
        end
		HW[i] = hw
	end

	for i=1,#HW do
		HW[i]:SetCallback("HW_TRACER_UPDATE",function(self,event,unit) addon:TRACER_UPDATE(unit) end)
		HW[i]:EnableUpdates()
	end

	self.CreateHealthWatchers = nil
end

function addon:ResetHealthWatchers()
    --addon:CloseAllHW()
    if addon.CE and addon.CE.onactivate then
        local oa = addon.CE.onactivate
        addon:SetTracing(oa.tracing or oa.unittracing)
    end
end

function addon:RegisterNpcName(id,name)
    gbl.L_NPC[id] = name
end

-----------------------------------
local CT = {}
local CT_MAX = 3
addon.CT = CT

function addon:CreateCounters(Pane)
    for i=1,CT_MAX do
        local counter = addon.Counter:New(Pane)
        counter:SkinBorder(counter.border)
        counter:SetParent(Pane)
        CT[i] = counter
        counter:Hide()
    end
    addon:LayoutCounters()
end

function addon:LayoutCounters()
    local anchor = Pane
    for i,hw in pairs(self.HW) do
        if hw:IsShown() then anchor = hw end
    end
    
	local point, point2
	local relpoint, relpoint2
	local growth = pfl.Pane.BarGrowth
	local mult = 1 -- set to -1 when growing down
	if growth == "AUTOMATIC" then
		local midY = (GetScreenHeight()/2)*UIParent:GetEffectiveScale()
		local x,y = Pane:GetCenter()
		local s = Pane:GetEffectiveScale()
		x,y = x*s,y*s
		if y > midY then
			mult = -1
			point,relpoint = "TOPLEFT","BOTTOMLEFT"
			point2,relpoint2 = "TOPRIGHT","BOTTOMRIGHT"
		else
			point,relpoint = "BOTTOMLEFT","TOPLEFT"
			point2,relpoint2 = "BOTTOMRIGHT","TOPRIGHT"
		end
	elseif growth == "UP" then
		point,relpoint = "BOTTOMLEFT","TOPLEFT"
		point2,relpoint2 = "BOTTOMRIGHT","TOPRIGHT"
	elseif growth == "DOWN" then
		mult = -1
		point,relpoint = "TOPLEFT","BOTTOMLEFT"
		point2,relpoint2 = "TOPRIGHT","BOTTOMRIGHT"
	end
	for i,counter in ipairs(self.CT) do
		--counter:Show() -- keep only for testing
        --counter:SetAlpha(1) -- keep only for testing
        if counter:IsShown() then
			counter:ClearAllPoints()
			counter:SetPoint(point,anchor,relpoint,0,mult*pfl.Pane.BarSpacing)
			counter:SetPoint(point2,anchor,relpoint2,0,mult*pfl.Pane.BarSpacing)
			anchor = counter
		end
	end
end

local PrefixByDifficulty = addon.PrefixByDifficulty
local PrefixByGroupSize = addon.PrefixByGroupSize

function addon:AddCounter(counter)
    if not counter then return end
    local variable = counter.variable
    local label = counter.label or ""
    -- Minimum limit
    local minimum = counter.minimum
    if not minimum then minimum = PrefixByDifficulty(counter,"minimum") end
    if not minimum then minimum = PrefixByGroupSize(counter,"minimum") end  
    if not minimum then minimum = 0 end
    
    -- Default value
    local value = counter.value
    if not value then value = PrefixByDifficulty(counter,"value") end
    if not value then value = PrefixByGroupSize(counter,"value") end  
    if not value then value = minimum end
    
    -- Maximum limit
    local maximum = counter.maximum
    if not maximum then maximum = PrefixByDifficulty(counter,"maximum") end
    if not maximum then maximum = PrefixByGroupSize(counter,"maximum") end
    
    local pattern = counter.pattern or "%d out of %d"
    local patternExcess = counter.patternExcess or "%d"
    local difficulty = counter.difficulty
    
    local currentDifficulty = addon:GetRaidDifficulty()
    local heroic = addon:IsHeroic()
	if not difficulty or currentDifficulty == difficulty or (difficulty == 10 and not heroic) or (difficulty == 20 and heroic) then
        for i,counter in pairs(CT) do
            if not counter:IsShown() then
                counter:SetupCounter(variable, label, minimum, maximum, value, pattern, patternExcess)
                counter:Show()
                break
            end
        end
        addon:LayoutCounters()
    end
end

function addon:RemoveCounter(var)
    if not addon.CE.counters then return end
    
    local counter = addon.CE.counters[var]
    if counter then
        local variable = counter.variable
        for _,ct in pairs(CT) do
            if ct.variable == variable then
                ct:Hide()
            end
        end
    end
    
    addon:LayoutCounters()
end

function addon:CounterCheckForAllUpdates()
    
end

function addon:CounterSetValue(key, value)   
    for _,counter in pairs(CT) do
        if counter.variable == key then
            counter:SetValue(value)
        end
    end
end
function addon:SetCounters(counters)
    if not addon.CE.counters then return end
    for _,key in ipairs(counters) do
        addon:AddCounter(addon.CE.counters[key])
    end
end

function addon:ResetCounters(code)
    addon:CloseAllCT()
    if addon.CE and addon.CE.onactivate and addon.CE.onactivate.counters then
        addon:SetCounters(addon.CE.onactivate.counters)
    end
    addon:LayoutCounters()
end

function addon:CloseAllCT()
    for i=1,#CT do CT[i]:Hide() end
end

-----------------------------------
function addon:CloseAllHW()
	for i=1,#HW do HW[i]:Close(); HW[i]:Hide() end
end

function addon:ShowFirstHW()
	if not HW[1]:IsShown() then
		HW[1]:SetInfoBundle("",1,1)
		HW[1]:ApplyNeutralColor()
		HW[1]:SetTitle(addon.CE.title)
		HW[1]:Show()
	end
end

do
	local n = 0
	local handle
	local e = 1e-10
	local UNACQUIRED = 1

	--[[
	Convert percentages to negatives so we can achieve something like
		HW[4] => Neutral color
		HW[3] => DEAD
		HW[2] => DEAD
		HW[1] => 56%
	]]

	-- Stable sort by comparing npc ids
	-- When comparing two percentages we convert back to positives
	local function sortFunc(a,b)
		local v1,v2 = a[2],b[2] -- health perc
		if v1 == v2 then
			return a[1] < b[1] -- npc ids
		elseif v1 < 0 and v2 < 0 then
			return -v1 < -v2
		else
			return v1 < v2
		end
	end

	local function Execute()
		for _,unit in pairs(Roster.unit_to_unittarget) do
			-- unit could not exist and still return a valid guid
			if UnitExists(unit) then
				local npcid = NID[UnitGUID(unit)]
				if npcid then
					SeenNIDS[npcid] = true
					local k = search(SortedCache,npcid,1)
					if k then
						local h,hm = UnitHealth(unit),UnitHealthMax(unit)
						if hm == 0 then hm = 1 end
						SortedCache[k][2] = -(h / hm)
					end
				end
			end
		end

		sort(SortedCache,sortFunc)
		local flag -- Whether or not we should layout health watchers
		for i=1,n do
			if i <= #HW then
				local hw,info = HW[i],SortedCache[i]
				local npcid,perc = info[1],info[2]
				-- Conditional is entered sparsely during a fight
				if perc ~= UNACQUIRED and hw:GetGoal() ~= npcid and SeenNIDS[npcid] then
                    hw:SetTitle(gbl.L_NPC[npcid] or "...")
					-- Has been acquired
					if perc then
						if perc < 0 then
							hw:SetInfoBundle(format("%0.0f%%", -perc*100), -perc)
							hw:ApplyLostColor()
						else
							hw:SetInfoBundle(DEAD,0)
						end
					-- Hasn't been acquired
					else
						hw:SetInfoBundle("",1)
						hw:ApplyNeutralColor()
					end
					hw:Track("npcid",npcid)
					hw:Open()
					if not hw:IsShown() then
						hw:Show()
						flag = true
					end
				end
			else break end
		end
		if flag then 
            addon:LayoutHealthWatchers()
            addon:LayoutCounters()
        end
	end
    
	function addon:StartSortedTracing()
        if n == 0 or handle then return end
		handle = self:ScheduleRepeatingTimer(Execute,0.5)
	end

	function addon:StopSortedTracing()
		if not handle then return end
		self:CancelTimer(handle,true)
		handle = nil
	end

	function addon:ClearSortedTracing()
		wipe(SeenNIDS)
		for i in ipairs(SortedCache) do
			SortedCache[i][2] = UNACQUIRED
		end
	end

	function addon:ResetSortedTracing()
        wipe(SeenNIDS)
		self:StopSortedTracing()
		for i in ipairs(SortedCache) do
			SortedCache[i][1] = nil
			SortedCache[i][2] = UNACQUIRED
		end
		n = 0
	end

	function addon:SetSortedTracing(npcids)
		if not npcids then return end
		n = #npcids
		for i,npcid in ipairs(npcids) do
			SortedCache[i] = SortedCache[i] or {}
			SortedCache[i][1] = npcid
			SortedCache[i][2] = UNACQUIRED
		end
		for i=n+1,#SortedCache do SortedCache[i] = nil end
	end
end

-- Units dead
function addon:HWDead(npcid)
	-- Health watchers
	for i,hw in ipairs(HW) do
		if hw:IsOpen() and hw:GetGoal() == npcid then
			hw:SetInfoBundle(DEAD,0,0)
			local k = search(SortedCache,npcid,1)
			if k then SortedCache[k][2] = 0 end
			break
		end
	end
end

local tempRegistered = nil
function addon:IsTempRegistered()
    return tempRegistered
end

function addon:SetTempRegistered(registered)
    tempRegistered = registered
end

function addon:ProcessTempHW(deadGUID)
    local removedHW = nil
    local HW_RESTACKED = {}   
    local deadid = tonumber((deadGUID):sub(-12, -9), 16)
    
    for i,hw in ipairs(HW) do
        local goal = hw:GetGoal()
        local trackType = hw.tracer.trackType
        if not removedHW and ((trackType == "npcid" and goal == deadid)
                         or (trackType == "guid" and goal == deadGUID)
                         or (trackType == "unit" and hw.tracer.goalid == deadid)) then
            removedHW = hw
            hw:Close()
            hw:Hide()
        else
            table.insert(HW_RESTACKED, hw)
        end
    end
    if removedHW then table.insert(HW_RESTACKED,removedHW) end
    HW = HW_RESTACKED      
    addon.HW = HW
    self:LayoutHealthWatchers()
    self:LayoutCounters()
end

function addon:CloseTempHW()
    local rest = {}
    local removed = {}
    for i,hw in ipairs(HW) do
        if hw:IsTemp() then
            hw:Close()
            hw:Hide()
            removed[#removed+1] = hw
        else 
            rest[#rest+1] = hw
        end
    end
    
    for i,hw in ipairs(removed) do
        rest[#rest+1] = hw
    end
    
    HW = rest
    addon.HW = HW
    self:LayoutHealthWatchers()
    self:LayoutCounters()
end

do
    local GUIDs = {}

    function addon:GetBossByID(id)
        local ids = type(id) == "table" and id or {id} -- wrapping the id in a table
        for i=1,addon.BOSS_MAX do
            local unit = "boss"..i
            local unitid = addon.NID[UnitGUID(unit)]
            if unitid then
                for i,npcid in ipairs(ids) do
                    if unitid == npcid then
                        return unit,npcid
                    end
                end
            end
        end
    end
    
    function addon:AddTempTracing(targets)
        local n = 1
        for i=1,#HW do
            if not HW[i]:IsOpen() then
                n = i
                break
            end
        end
        if not addon:IsTempRegistered() then
            addon:SetTempRegistered(true)
        end
        
        for i,tgtData in ipairs(targets) do
            local hw = HW[n+i-1]
            local tgt
            local trackTgt
            local override = false
            local registerUnitWatching = false
            if type(tgtData) == "table" then
                override = true
                if tgtData.unit == "boss" then
                    registerUnitWatching = true
                    trackTgt,tgt = addon:GetBossByID(tgtData.npcid)
                    --[[if not trackTgt then
                        trackTgt = tgt
                    end]] -- first or an npcid (depending on npcid being a value or a table)
                    if not trackTgt then trackTgt = tgtData.npcid end
                    if not tgt then tgt = tgtData.npcid end
                else
                    tgt = tgtData.npcid
                    trackTgt = tgtData.unit
                end
            else
                tgt = tgtData
                trackTgt = tgtData
            end
            tgt = addon:ReplaceTokensM(tgt) -- may not be necessary in most cases
            
            if tgt and trackTgt and (override or hw:GetGoal() ~= tgt) then
                hw:SetTemp(true)
                if targets.powers and targets.powers[i] then
					hw:ShowPower()
				end
                -- Setting up the HW title
                if type(tgt) == "table" then
                    local flag = false
                    for i,id in ipairs(tgt) do
                        local name = gbl.L_NPC[id]
                        if name then
                            hw:SetTitle(name)
                            flag = true
                            break
                        end
                    end
                    if not flag then hw:SetTitle("...") end
                elseif type(tgt) == "string" and string.match(tgt,"^0x.+$") then
                    -- tgt is GUID
                    local playerName = select(6, GetPlayerInfoByGUID(tgt))
                    if playerName then
                        hw:SetTitle(playerName)
                    else
                        local id = tonumber((tgt):sub(-12, -9), 16)
                        hw:SetTitle(gbl.L_NPC[id] or "...")
                    end
                elseif type(tgt) == "number" then
                    -- tgt is npcID
                    hw:SetTitle(gbl.L_NPC[tgt] or "...")
                end
                hw:SetInfoBundle("",1,1)
				hw:ApplyNeutralColor()
                
                -- Setting up the HW tracking
                if type(trackTgt) == "number" then
                    hw:Track("npcid",trackTgt)
                    
				elseif type(trackTgt) == "string" then
                    if string.match(trackTgt,"^0x.+$") then
                        hw:Track("guid",trackTgt)
                    elseif UnitName(trackTgt) == trackTgt then
                        hw:Track("name",trackTgt)
                    elseif UnitExists(trackTgt) then
                        hw:Track("unit",trackTgt)    
                    end
                elseif type(trackTgt) == "table" then
                    hw:Track("npcids", trackTgt)
                end
                GUIDs[tostring(trackTgt)] = hw
                hw:Open()
                if registerUnitWatching then hw.tracer:RegisterBossUnitWatching() end
				hw:Show()
            end
        end
        self:LayoutHealthWatchers()
        self:LayoutCounters()
    end
end

do
	local registered = nil
	local units = {} -- unit => hw
    local n = 0
    
	function addon:SetTracing(targets)
        local eventModule = addon:IsModuleEvent(addon.CE.key)
        if not targets then 
            return
        end
        
        self:ResetSortedTracing()
        wipe(units)
        
        if registered then
            self:UnregisterEvent("UNIT_NAME_UPDATE")
            registered = nil
        end
        n = 0
        
		for i,tgtData in ipairs(targets) do
			-- Prevents overwriting
            local hw = HW[i]
            local tgt
            local trackTgt
            local override = false
            local registerUnitWatching = false
            if type(tgtData) == "table" then
                override = true
                if tgtData.unit == "boss" then
                    registerUnitWatching = true
                    trackTgt,tgt = addon:GetBossByID(tgtData.npcid)
                    if not tgt then tgt = tgtData.npcid end
                    if not trackTgt then trackTgt = tgtData.npcid end 
                else
                    tgt = tgtData.npcid
                    trackTgt = tgtData.unit
                end
            else
                tgt = tgtData
                trackTgt = tgtData
            end
            tgt = addon:ReplaceTokensM(tgt) -- may not be necessary in most cases
            if trackTgt and tgt and (override or hw:GetGoal() ~= tgt) then
                if targets.powers and targets.powers[i] then
					hw:ShowPower()
				end
                if targets.altpowers and targets.altpowers[i] then
					hw:ShowAltPower()
				end
                if string.match(tgt,"^0x.+$") then
                    local playerName = select(6, GetPlayerInfoByGUID(tgt))
                    if playerName then
                        hw:SetTitle(playerName)
                    else
                        local id = tonumber((tgt):sub(-12, -9), 16)
                        hw:SetTitle(gbl.L_NPC[id] or "...")
                    end
                elseif tonumber(tgt) ~= nil then
                    hw:SetTitle(gbl.L_NPC[tgt] or "...")
                -- tgt is a unit
                else
                    hw:SetTitle(UnitName(tgt))
                end
                
                hw:SetVisualMax(type(tgtData) == "table" and tgtData.vmax)
                
				hw:SetInfoBundle("",1,1)
				hw:ApplyNeutralColor()
				if type(trackTgt) == "number" then
                    hw:Track("npcid",trackTgt)
				elseif type(trackTgt) == "string" then
                    if string.match(trackTgt,"^0x.+$") then
                            hw:Track("guid",trackTgt)
                            units[trackTgt] = hw
                    else
                        if not registered then
                            self:RegisterEvent("UNIT_NAME_UPDATE")
                            registered = true
                        end
                        hw:Track("unit",trackTgt)
                        units[trackTgt] = hw
                    end
				elseif type(trackTgt) == "table" then
                    hw:Track("npcids", trackTgt)
                end
				hw:Open()
                if registerUnitWatching then hw.tracer:RegisterBossUnitWatching() end
				hw:Show()
			end
			n = n + 1
		end
		for i=n+1,#HW do
			HW[i]:Close()
			HW[i]:Hide()
		end
		self:LayoutHealthWatchers()
        self:LayoutCounters()
	end

	-- Occasionally UnitName("boss1") == UnitName("boss2")
	function addon:UNIT_NAME_UPDATE(unit)
		if units[unit] then
			--[===[@debug@
			debug("UNIT_NAME_UPDATE","unit: %s",unit)
			--@end-debug@]===]
			units[unit]:SetTitle(UnitName(unit))
		end
	end
end

function addon:LayoutHealthWatchers()
	local anchor = Pane
	local point, point2
	local relpoint, relpoint2
	local growth = pfl.Pane.BarGrowth
	local mult = 1 -- set to -1 when growing down
	if growth == "AUTOMATIC" then
		local midY = (GetScreenHeight()/2)*UIParent:GetEffectiveScale()
		local x,y = Pane:GetCenter()
		local s = Pane:GetEffectiveScale()
		x,y = x*s,y*s
		if y > midY then
			mult = -1
			point,relpoint = "TOPLEFT","BOTTOMLEFT"
			point2,relpoint2 = "TOPRIGHT","BOTTOMRIGHT"
		else
			point,relpoint = "BOTTOMLEFT","TOPLEFT"
			point2,relpoint2 = "BOTTOMRIGHT","TOPRIGHT"
		end
	elseif growth == "UP" then
		point,relpoint = "BOTTOMLEFT","TOPLEFT"
		point2,relpoint2 = "BOTTOMRIGHT","TOPRIGHT"
	elseif growth == "DOWN" then
		mult = -1
		point,relpoint = "TOPLEFT","BOTTOMLEFT"
		point2,relpoint2 = "TOPRIGHT","BOTTOMRIGHT"
	end
    for i,hw in ipairs(self.HW) do
        if hw:IsShown() then
			hw:ClearAllPoints()
			hw:SetPoint(point,anchor,relpoint,0,mult*pfl.Pane.BarSpacing)
			hw:SetPoint(point2,anchor,relpoint2,0,mult*pfl.Pane.BarSpacing)
			anchor = hw
		end
	end
end

function addon:UpdateUnitHealthWatchers()
    for i=1,#addon.HW do
        addon.HW[i]:UpdateBossUnits(i)
    end
end

do
	-- Throttling is needed because sometimes bosses pulsate in and out of combat at the start.
	-- UnitAffectingCombat can return false at the start even if the boss is moving towards a player.

	-- The time to wait (seconds) before it auto stops the encounter after auto starting
	local throttle = 5
	-- The last time the encounter was auto started + throttle time
	local last = 0
	function addon:TRACER_UPDATE(unit)
        --[[local time,running = GetTime(),self:IsRunning()
		if self:IsTracerStart() and not running and UnitIsFriend(addon.targetof[unit],"player") then
			self:StartEncounter()
			last = time + throttle
		elseif (UnitIsDead(unit) or not UnitAffectingCombat(unit)) and self:IsTracerStop() and running and last < time then
			self:StopEncounter()
		end]]
	end
end

do
	local AutoStart,AutoStop
	function addon:SetTracerStart(val)
		AutoStart = not not val
	end

	function addon:SetTracerStop(val)
		AutoStop = not not val
	end

	function addon:IsTracerStart()
		return AutoStart
	end

	function addon:IsTracerStop()
		return AutoStop
	end
end

---------------------------------------------
-- PHASE MARKERS
---------------------------------------------
function addon:SetPhaseMarkers(markerData)
    local currentDifficulty = addon:GetRaidDifficulty()
    local heroic = addon:IsHeroic()
    if currentDifficulty then 
        addon:ClearAllPhaseMarkers()
        if not markerData then return end 
        
        for hwIndex,markerSet in pairs(markerData) do
            local adjustedMarkerIndex = 1
            for markerIndex,data in ipairs(markerSet) do
                local percentPos = data[1]
                local label = data[2]
                local description = data[3]
                local difficulty = data[4]
                if not difficulty or currentDifficulty == difficulty or (difficulty == 10 and not heroic) or (difficulty == 20 and heroic) then
                    addon:AddPhaseMarker(hwIndex, adjustedMarkerIndex, percentPos, label, description)
                    adjustedMarkerIndex = adjustedMarkerIndex + 1
                end
            end
        end
    end
end

function addon:AddPhaseMarker(hwIndex, markerIndex, percentPos, label, description)
    label = label or "Phase Transition"
    description = description or ""
    if hwIndex >= #HW then
        return
    else
        HW[hwIndex]:AddPhaseMarker(markerIndex, percentPos, label, description)
    end
end

function addon:RemovePhaseMarker(hwIndex, markerIndex)
    if hwIndex >= #HW then
        return
    else
        HW[hwIndex]:RemovePhaseMarker(markerIndex)
    end
end
         
function addon:ClearPhaseMarkers(hwIndex)
    if hwIndex >= #HW then
        return
    else
        HW[hwIndex]:ClearAllPhaseMarkers()
    end
end

function addon:ClearAllPhaseMarkers()
    for _,phaseMarker in pairs(HW) do
        phaseMarker:ClearAllPhaseMarkers()
    end
end

function addon:HideAllPhaseMarkers()
    for _,phaseMarker in pairs(HW) do
        phaseMarker:HideAllPhaseMarkers()
    end
end

function addon:HidePhaseMarker(hwIndex, markerIndex)
    if hwIndex >= #HW then
        return
    else
        HW[hwIndex]:HidePhaseMarker(markerIndex)
    end
end

function addon:ShowPhaseMarker(hwIndex, markerIndex)
    if hwIndex >= #HW then
        return
    else
        HW[hwIndex]:ShowPhaseMarker(markerIndex)
    end
end

function addon:UpdatePhaseMarkersVisibility()
    local showPhaseMarkers = pfl.Pane.PhaseMarkersEnable
    for _,hw in pairs(HW) do
        hw:RefreshSpark()
        hw:UpdatePhaseMarkersVisibility(showPhaseMarkers)
    end
    
    
end

---------------------------------------------
-- LOCK
---------------------------------------------

do
	local LockableFrames = {}
    
	function addon:RegisterForLocking(frame)
		--[===[@debug@
		assert(type(frame) == "table","expected 'frame' to be a table")
		assert(frame.IsObjectType and frame:IsObjectType("Region"),"'frame' is not a blizzard frame")
		--@end-debug@]===]
		LockableFrames[frame] = true
		self:UpdateLockedFrames()
	end

	function addon:CreateLockableFrame(name,width,height,text,disableKey)
		--[===[@debug@
		assert(type(name) == "string","expected 'name' to be a string")
		assert(type(width) == "number" and width > 0,"expected 'width' to be a number > 0")
		assert(type(height) == "number" and height > 0,"expected 'height' to be a number > 0")
		assert(type(text) == "string","expected 'text' to be a string")
		--@end-debug@]===]
		local frame = CreateFrame("Frame","DXE"..name,UIParent)
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetUserPlaced(false)
		addon:RegisterBackground(frame)
		frame.border = CreateFrame("Frame",nil,frame)
		frame.border:SetAllPoints(true)
		addon:RegisterBorder(frame.border)
		frame:SetWidth(width)
		frame:SetHeight(height)
        frame.disableKey = disableKey
		LockableFrames[frame] = true
		self:UpdateLockedFrames()

		local desc = frame:CreateFontString(nil,"ARTWORK")
		desc:SetShadowOffset(1,-1)
		desc:SetPoint("BOTTOM",frame,"TOP")
		self:RegisterFontString(desc,9)
		desc:SetText(text)
		return frame
	end

	function addon:UpdateLock()
		self:UpdateLockedFrames()
		if gbl.Locked then
			self:SetLocked()
		else
			self:SetUnlocked()
		end
        
        self:ToggleEmphasisFrame(gbl.Locked)
        addon:UpdateDistanceLocks()
        addon:UpdateAlternativePowerLock(gbl.Locked)
	end
    
    function addon:UpdateDistanceLocks()
        if addon.db.profile.Windows.Proxtype == "RADAR" then
            addon:UpdateRadarLock(gbl.Locked)
            addon:UpdateProximityLock(true)
        elseif addon.db.profile.Windows.Proxtype == "TEXT" then
            addon:UpdateProximityLock(gbl.Locked)
            addon:UpdateRadarLock(true)
        end
    end

	function addon:ToggleLock()
		gbl.Locked = not gbl.Locked
		self:UpdateLock()
	end
    
	function addon:UpdateLockedFrames(func)
		func = func or (gbl.Locked and "Hide" or "Show")
		for frame in pairs(LockableFrames) do 
            if addon.Alerts.db and addon.Alerts.db.profile and frame.disableKey then
                local func2 = (not gbl.Locked and addon.Alerts.db.profile[frame.disableKey]) and "Show" or "Hide"
                frame[func2](frame)
            else
                frame[func](frame)
            end
        end
	end

	function addon:SetLocked()
		self.Pane.lock:SetNormalTexture(PaneTextures.."Locked")
		self.Pane.lock:SetHighlightTexture(PaneTextures.."Locked")
	end

	function addon:SetUnlocked()
		self.Pane.lock:SetNormalTexture(PaneTextures.."Unlocked")
		self.Pane.lock:SetHighlightTexture(PaneTextures.."Unlocked")
	end
end

---------------------------------------------
-- SELECTOR
---------------------------------------------

do
	local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
	local function closeall() CloseDropDownMenus(1) end

	local function OnClick(self)
		addon:SetActiveEncounter(self.value)
		CloseDropDownMenus()
	end

	local YELLOW = "|cffffff00"

	local work,list = {},{}
	local info

	local function Initialize(self,level)
		wipe(work)
		wipe(list)

		level = level or 1

		if level == 1 then
			info = UIDropDownMenu_CreateInfo()
			info.isTitle = true
			info.text = L["Encounter Selector"]
			info.notCheckable = true
			info.justifyH = "LEFT"
			UIDropDownMenu_AddButton(info,1)

			info = UIDropDownMenu_CreateInfo()
			info.text = L["Default"]
			info.value = "default"
			info.func = OnClick
			info.colorCode = YELLOW
			info.owner = self
			UIDropDownMenu_AddButton(info,1)

			for key,data in addon:IterateEDB() do
				work[data.category or data.zone] = true
			end
			for cat in pairs(work) do
				list[#list+1] = cat
			end

			sort(list)

			for _,cat in ipairs(list) do
				info = UIDropDownMenu_CreateInfo()
				info.text = cat
				info.value = cat
				info.hasArrow = true
				info.notCheckable = true
				info.owner = self
				UIDropDownMenu_AddButton(info,1)
			end

			info = UIDropDownMenu_CreateInfo()
			info.notCheckable = true
			info.justifyH = "LEFT"
			info.text = L["Cancel"]
			info.func = closeall
			UIDropDownMenu_AddButton(info,1)
		elseif level == 2 then
			local cat = UIDROPDOWNMENU_MENU_VALUE

			for key,data in addon:IterateEDB() do
				if (data.category or data.zone) == cat then
                    local text = format("|cfff0c502%s|r",data.name)
                    if addon:IsModuleTrash(key) then text = format("|cffdddddd%s|r",data.name) end
                    if addon:IsModuleEvent(key) then text = format("|cff84e1fd%s|r",data.name) end
                    list[data.order] = data.name
					work[data.name] = {key = key, text = text}
				end
			end

			for _,name in ipairs(list) do
				info = UIDropDownMenu_CreateInfo()
				info.hasArrow = false
				info.text = work[name].text
				info.owner = self
				info.value = work[name].key
				info.func = OnClick
				UIDropDownMenu_AddButton(info,2)
			end
		end
	end

	function addon:CreateSelectorDropDown()
		local selector = CreateFrame("Frame", "DXEPaneSelector", UIParent, "UIDropDownMenuTemplate")
		UIDropDownMenu_Initialize(selector, Initialize, "MENU")
		UIDropDownMenu_SetSelectedValue(selector,"default")
		return selector
	end
end

---------------------------------------------
-- MUTE
---------------------------------------------
do
    function addon:UpdateMute(muted)
        self.Pane.mute:SetNormalTexture(PaneTextures..(muted and "Muted" or "Unmuted"))
		self.Pane.mute:SetHighlightTexture(PaneTextures..(muted and "Muted" or "Unmuted"))
    end
    
    function addon:ToggleMute()
        addon.Alerts.db.profile.DisableSounds = not addon.Alerts.db.profile.DisableSounds
		self:UpdateMute(addon.Alerts.db.profile.DisableSounds)
    end
end

---------------------------------------------
-- READY CHECK
---------------------------------------------
do
    function addon:ReadyCheck()
        if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
            addon:Print("\124cffff0000You have to be member of a party or a raid group!\124r")    
            return
        end
        if addon:GetRaidRank() < 1 then 
            addon:Print("\124cffff0000You have insufficient permissions!\124r")    
            return
        end
        
        DoReadyCheck()
    end
end

do
    function addon:RoleCheck()
        if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
            addon:Print("\124cffff0000You have to be member of a party or a raid group!\124r")    
            return
        end
        if addon:GetRaidRank() < 1 then 
            addon:Print("\124cffff0000You have insufficient permissions!\124r")    
            return
        end
        
        InitiateRolePoll()
    end
end

---------------------------------------------
-- PANE FUNCTIONS
---------------------------------------------
do
	local isRunning

	-- @return number >= 0
	function addon:GetElapsedTime()
		return elapsedTime
	end

	--- Returns whether or not the timer is running
	-- @return A boolean
	function addon:IsRunning()
		return isRunning
	end

	local function OnUpdate(self,elapsed)
        Pane.elapsedTime = Pane.elapsedTime + elapsed
		self:SetTime(Pane.elapsedTime,true,2)
        if pfl.Pane.ShowBestTimePane then
            addon:UpdateBestTimeDiff()
        end
	end
    
    function addon:UpdateBestTimeDiff(triggeredByDefeat)
        if triggeredByDefeat then addon.Pane.showBestTimeDiff = true end
    
        local besttime = addon:GetBestTime(addon.CE.key)
        
        if besttime and Pane.elapsedTime then
            local delta = besttime - Pane.elapsedTime
            local positive = delta >= 0
            if not positive then delta = delta * (-1) end
            local int = tonumber(format("%d", delta))
            local minutes = floor(int/60)
            local sec = ceil(int % 60)
            local ms = tonumber(string.match(delta,".(%d%d)")) or 0
            local color = positive and "|cff00ff00- " or "|cffff0000+ "
            local diffText
            if addon.Pane.showBestTimeDiff or (delta ~= 0 and delta ~= besttime and minutes == 0 and positive) or not positive then
                diffText = format("%s%s%s%s|r",
                                  color,minutes > 0 and minutes..":" or "",
                                  sec > 9 and sec or (minutes > 0 and "0"..sec or sec),
                                  minutes == 0 and ("."..(ms>9 and ms or "0"..ms)) or "")
            else
                diffText = ""
            end
            Pane.besttimeroffset:SetText(diffText)
        end
    end

	--- Starts the Pane timer
	function addon:StartTimer(startTimer,initTime)
        Pane.PullTime = GetTime() - (initTime or 0)
        Pane.elapsedTime = initTime or 0
        
		if startTimer then self.Pane.timer:SetScript("OnUpdate",OnUpdate) end
		isRunning = true
        if not addon:IsModuleTrash(addon.CE.key) then self.Pane.timer:SetTextColor(1, 1, 1) end
	end

	--- Stops the Pane timer
	function addon:StopTimer()
        self.Pane.timer:SetScript("OnUpdate",nil)
		isRunning = false
        if not pfl.Pane.Show then
            local hiddenTime = GetTime() - Pane.PullTime
            Pane.elapsedTime = hiddenTime
            Pane.timer:SetTime(hiddenTime,true,2)
        end
        Pane.PullTime = nil
	end

	--- Resets the Pane timer
	function addon:ResetTimer()
        Pane.elapsedTime = 0
		self.Pane.timer:SetTime(0,true,2)
        self.Pane.timer:SetTextColor(1, 1, 1)
	end
    
    function addon:UpdatePaneButtonPermission()
        local rank = addon:GetRaidRank()
        if rank >= 1 or (GetNumPartyMembers() > 0 and GetNumRaidMembers() == 0) then
            Pane.pull:SetAlpha(1)
        else
            Pane.pull:SetAlpha(0.25)
        end
        
        if rank > 0 then
            Pane.ReadyCheckBtn:SetAlpha(1)
            Pane.RoleCheckBtn:SetAlpha(1)
        else
            Pane.ReadyCheckBtn:SetAlpha(0.25)
            Pane.RoleCheckBtn:SetAlpha(0.25)
        end
    end
end
