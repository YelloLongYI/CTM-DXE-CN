local addon = DXE
local floor = math.floor
local db,pfl

local Timer,prototype = {},{}
DXE.Timer = Timer

function Timer:New(parent,leftsize,rightsize)
	local timer = CreateFrame("Frame",nil,parent)
	for k,v in pairs(prototype) do timer[k] = v end

	timer:SetWidth(80); timer:SetHeight(20)

	local left = timer:CreateFontString(nil,"OVERLAY")
	left:SetPoint("LEFT",timer,"LEFT")
	left:SetWidth(120)
	left:SetHeight(20)
	left:SetJustifyH("RIGHT")
	addon:RegisterTimerFontString(left,leftsize or 20)
	timer.left = left

	local right = timer:CreateFontString(nil,"OVERLAY")
	right:SetPoint("BOTTOMLEFT",left,"BOTTOMRIGHT",0,2)
	right:SetWidth(25)
	right:SetHeight(12)
	right:SetJustifyH("LEFT")
	addon:RegisterTimerFontString(right,rightsize or 12)
	timer.right = right

	left:SetText("0:00")
	right:SetText("00")

    local currentTime = 0
    timer.currentTime = currentTime
    
	return timer
end

function prototype:SetTime(time,showDecimal,decimalPlaces,sticky)
	if time < 0 then time = 0 end
    self.currentTime = time
    
    if sticky and time == 0 then
        self.left:SetText("")
        self.right:SetText("")
        return
    end
    
    local dec
    if showDecimal then
        dec = tonumber(string.match(format(format("%%.%df",decimalPlaces), time - floor(time)),"%d.([%d]+)"))
        self.right:SetFormattedText(dec)
        self.left:SetWidth(120)
    else
        dec = (time - floor(time)) * 100
        self.right:SetText("")
        self.left:SetWidth(120)
        if time == 0 and dec == 0 then
            time = 0
        else
            time = time + 1
        end
    end
    
    local min = floor(time/60)
	local sec = time % 60
 
    if min == 0 then
        self.left:SetFormattedText("%d",sec)
    else
        self.left:SetFormattedText("%d:%02d",min,sec)
    end
end

function prototype:GetTime()
    return self.currentTime
end

function prototype:GetText()
    if showDecimal then
        return self.left:GetText().."."..self.righ:GetText()
    else
        return self.left:GetText()
    end
end

function prototype:SetTextColor(textR, textG, textB, textAlpha)
    self.left:SetTextColor(textR or 1, textG or 1, textB or 1, textAlpha or 1)
    self.right:SetTextColor(textR or 1, textG or 1, textB or 1, textAlpha or 1)
end
