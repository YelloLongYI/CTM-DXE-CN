-- Skinning is done externally
local addon = DXE

local Counter,prototype = {},{}
DXE.Counter = Counter

function Counter:New(parent)
    local counter = CreateFrame("Button",nil,parent)
    -- Embed
    for k,v in pairs(prototype) do counter[k] = v end
    counter.events = {}
    
    counter:SetWidth(220)
    counter:SetHeight(22)
    addon:RegisterBackground(counter)
    
    local counterbar = CreateFrame("StatusBar",nil,counter)
    counterbar:SetPoint("TOPLEFT",2,-2)
	counterbar:SetPoint("BOTTOMRIGHT",-2,2)
    addon:RegisterStatusBar(counterbar,"HealthWatcher")
    counter.counterbar = counterbar
    
    -- Border
    local border = CreateFrame("Frame",nil,counter)
	border:SetAllPoints(true)
	border:SetFrameLevel(counterbar:GetFrameLevel()+2)
	addon:RegisterBorder(border)
	counter.border = border
    
    local region = CreateFrame("Frame",nil,counterbar)
	region:SetAllPoints(true)
	region:SetFrameLevel(counterbar:GetFrameLevel()+10)

    -- Spark
    local spark = CreateFrame("Frame",nil,counterbar)
    counter.spark = spark
    spark.t = spark:CreateTexture(nil, "OVERLAY")
    spark.t:SetBlendMode("ADD");
    spark.t:SetTexture([[Interface\AddOns\DXE\Textures\Spark]])
    spark:Show()
    
	-- Title text
	title = region:CreateFontString(nil,"ARTWORK")
	title:SetPoint("LEFT",counterbar,"LEFT",6,0)
	title:SetShadowOffset(1,-1)
	addon:RegisterFontString(title,10)
    counter.title = title
    counter.text = nil

	-- Value
	countertext = region:CreateFontString(nil,"ARTWORK")
	countertext:SetPoint("RIGHT",counterbar,"RIGHT",-2,0)
	countertext:SetShadowOffset(1,-1)
	addon:RegisterFontString(countertext,12)
	counter.countertext = countertext

    counter.variable = nil
    counter.pattern = ""
    counter.patternExcess = ""
    
    return counter
end

--------------------------
-- PROTOTYPE
--------------------------
function prototype:SkinBorder(frame)
    local borderBackdrop = {}
    borderBackdrop.edgeFile = addon.SM:Fetch("border",pfl.Pane.Border)
    local r,g,b,a = unpack(pfl.Pane.SelectedBorderColor)
    frame:SetBackdropBorderColor(r,g,b,a)
    frame:SetBackdrop(borderBackdrop)
end

function prototype:SetupCounter(var, label, minimum, maximum, value, pattern, patternExcess)
    self.variable = var
    self.title:SetText(label)
    self.pattern = pattern
    self.patternExcess = patternExcess
    self.counterbar:SetReverseFill(minimum > maximum)
    if minimum > maximum then
        self.counterbar:SetMinMaxValues(maximum,minimum)
    else
        self.counterbar:SetMinMaxValues(minimum,maximum)
    end
    self:SetValue(0)
    local data = {counter = self,value = value}
    addon:ScheduleTimer("CounterRefresh", 0.1, data)
end

function addon:CounterRefresh(data)
    local counter = data.counter
    local value = data.value
    counter:SetValue(value)
    
end

function prototype:SetValue(value)
    local minimum,maximum = self.counterbar:GetMinMaxValues()
    local vperc = (value - minimum) / (maximum - minimum)
    local pattern = self.pattern
    local patternExcess = self.patternExcess
    -- Set bar values
    self.counterbar:SetValue(value)
    self:RefreshSpark(value)
    if value >= minimum and value <= maximum then
        self.countertext:SetText(format(pattern,value,maximum))
    else
        self.countertext:SetText(format(patternExcess, value))
    end
    
    -- Update bar colors
    self.counterbar:SetStatusBarColor(vperc > 0.5 and ((1 - vperc) * 2) or 1, vperc > 0.5 and 1 or (vperc * 2), 0)
    self.spark.t:SetVertexColor(vperc > 0.5 and ((1 - vperc) * 2) or 1, vperc > 0.5 and 1 or (vperc * 2), 0, 1)
end

function prototype:RefreshSpark(value)
    local showSpark = pfl.Pane.BarShowSpark
    local minimum,maximum = self.counterbar:GetMinMaxValues()
    if not showSpark or (type(value)=="number" and (value <= minimum or value >= maximum)) then
        self.spark:Hide()
    else
        if value then
            self.spark:ClearAllPoints()
            local sparkSize = 32
            local INSET = 2
            value = (value - minimum) / (maximum - minimum)
            value = self.counterbar:GetReverseFill() and 1-value or value
self.spark.t:SetPoint("TOPLEFT",    self,"TOPLEFT",    1+(value*self:GetWidth())-(sparkSize/2)-value*2, self:GetHeight()-(pfl.ShowBarBorder and INSET or -INSET))
self.spark.t:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",1-self:GetWidth()+(sparkSize/2)+(value*self:GetWidth())-value*2,-self:GetHeight()-(pfl.ShowBarBorder and INSET or 2*INSET))
        end
        --self.spark.t:SetVertexColor(1,1,1,1)
        --self.spark.t:SetVertexColor(self.data.c1.sr, self.data.c1.sg, self.data.c1.sb)
        self.spark:Show()
    end
end

