local defaults = {
	profile = {
		Enabled = false,
        DisplayBound = 5,
        LargeNumbersBound = 5,
        AllowGlow = false,
        FilterRaidWarning = false,
        MutePullSound = false,
        CountdownVoice = "#default#",
	}
}

local addon = DXE
local L = addon.L
local SM = addon.SM
local db,pfl
local module = addon:NewModule("Countdown")
addon.Countdown = module
local Alerts = addon.Alerts
local Sounds = addon.Media.Sounds
local find = string.find

local timer
local isTimerRunning = false
local updateInterval = 10

TIMER_NUMBERS_SETS = {}
TIMER_NUMBERS_SETS["BigGold"]  = {
    texture = "Interface\\Timer\\BigTimerNumbers", 
	w = 256,
    h = 170,
    texW = 1024,
    texH = 512,
	numberHalfWidths = {
        --0,   1,   2,   3,   4,   5,   6,   7,   8,   9,
		35/128, 14/128, 33/128, 32/128, 36/128, 32/128, 33/128, 29/128, 31/128, 31/128,
	}
}

function module:RefreshProfile()
	pfl = db.profile
    
    if timer.style then
        if pfl.AllowGlow then
            timer.glow1:SetTexture(timer.style.texture.."Glow");
            timer.glow2:SetTexture(timer.style.texture.."Glow");
        else
            timer.glow1:SetTexture("");
            timer.glow2:SetTexture("");
        end
    end
end

function module:UpdateCountdown()
    timer.time = nil;
    timer.type = nil;
    timer.isFree = true;
    timer:SetScript("OnUpdate", nil);
    timer.fadeBarOut:Stop();
    timer.fadeBarIn:Stop();
    timer.startNumbers:Stop();
    timer.GoTextureAnim:Stop();
    timer.digit1:SetAlpha(0)
    timer.digit2:SetAlpha(0)
    timer.glow1:SetAlpha(0)
    timer.glow2:SetAlpha(0)
    isTimerRunning = false
end

function module:OnInitialize()
    self.db = addon.db:RegisterNamespace("Countdown",defaults)
    db = self.db
    pfl = db.profile
    
    db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
	addon.RegisterCallback(self, "StartEncounter", "StartEncounter")
    timer = CreateFrame("FRAME", "DXE Big Numbers Countdown", UIParent, "DXE_PullTimerBar")
    local RaidWarningFrame_OnEvent = RaidWarningFrame:GetScript("OnEvent")
    RaidWarningFrame:SetScript("OnEvent", function(self,event,msg,...)
        if not addon.forceBlockDisable and 
           type(msg) == "string" and (find(msg:lower(),"pull in") or find(msg:lower(),"pull now")) then
            if not pfl.FilterRaidWarning then
                if pfl.MutePullSound then
                    RaidNotice_AddMessage(RaidWarningFrame,msg,ChatTypeInfo["RAID_WARNING"])
                else
                    return RaidWarningFrame_OnEvent(self,event,msg,...)
                end
            end
        else
            RaidWarningFrame_OnEvent(self,event,msg,...)
        end
    end)
end



function DXE_PullTimerBar_OnShow(self)
	self.time = self.endTime - GetTime();
	if self.time <= 0 then
		self:Hide();
		self.isFree = true;
	elseif self.startNumbers:IsPlaying() then
		self.startNumbers:Stop();
		self.startNumbers:Play();
	end
end

local OFFSET = 0

function DXE_PullTimerBar_BigNumberOnUpdate(self, elapsed)
    self.time = self.endTime - GetTime();
	self.updateTime = self.updateTime - elapsed;
    if self.time  + OFFSET < (pfl.DisplayBound + 1) then
        self.anchorCenter = false;
		if self.time  + OFFSET < (pfl.LargeNumbersBound + 1) then
			DXE_PullTimerBar_SwitchToLargeDisplay(self);
		end
		self:SetScript("OnUpdate", nil);
		if ( self.barShowing ) then
			self.barShowing = false;
			self.fadeBarOut:Play();
		else
			self.startNumbers:Play();
		end
	elseif not self.barShowing then
        self.fadeBarIn:Play();
		self.barShowing = true;
	elseif self.updateTime <= 0 then
		self.updateTime = updateInterval;
	end
end

function DXE_PullTimerBar_BarOnlyOnUpdate(self, elapsed)
	self.time = self.endTime - GetTime();
	
	if self.time < 0 then
		self:SetScript("OnUpdate", nil);
		self.barShowing = false;
		self.isFree = true;
		self:Hide();
	end
	
	if not self.barShowing then
		self.fadeBarIn:Play();
		self.barShowing = true;
	end
end

function DXE_PullTimerBar_SetTexNumbers(self, ...)
	local digits = {...}
	local timeDigits = floor(self.time);
	local digit;
	local style = self.style;
	local i = 1;
	
	local texCoW = style.w/style.texW;
	local texCoH = style.h/style.texH;
	local l,r,t,b;
	local columns = floor(style.texW/style.w);
	local numberOffset = 0;
	local numShown = 0;

	while digits[i] do -- THIS WILL DISPLAY SECOND AS A NUMBER 2:34 would be 154
		if timeDigits > 0 then
			digit = mod(timeDigits, 10);
			
			digits[i].hw = style.numberHalfWidths[digit+1]*digits[i].width;
			numberOffset  = numberOffset + digits[i].hw;
			
			l = mod(digit, columns) * texCoW;
			r = l + texCoW;
			t = floor(digit/columns) * texCoH;
			b = t + texCoH;
			digits[i]:SetTexCoord(l,r,t,b);
			digits[i].glow:SetTexCoord(l,r,t,b);
			
			timeDigits = floor(timeDigits/10);	
			numShown = numShown + 1;			
		else
			digits[i]:SetTexCoord(0,0,0,0);
			digits[i].glow:SetTexCoord(0,0,0,0);
		end
		i = i + 1;
	end
	
	if numberOffset > 0 then
        if not addon.Alerts.pfl.DisableSounds then
            Alerts:Sound(Sounds:GetFile("COUNTDOWN_TICK"))
        end
		digits[1]:ClearAllPoints();
		if self.anchorCenter then
			digits[1]:SetPoint("CENTER", UIParent, "CENTER", numberOffset - digits[1].hw, 0);
		else
			digits[1]:SetPoint("CENTER", self, "CENTER", numberOffset - digits[1].hw, 0);
		end
		
		for i=2,numShown do
			digits[i]:ClearAllPoints();
			digits[i]:SetPoint("CENTER", digits[i-1], "CENTER", -(digits[i].hw + digits[i-1].hw), 0)
			i = i + 1;
		end
	end
end

function DXE_PullTimerBar_NumberAnimOnFinished(self)
	self.time = self.time - 1;
	if self.time > 0 then
        if self.time + OFFSET < (pfl.LargeNumbersBound + 1) then
			DXE_PullTimerBar_SwitchToLargeDisplay(self);
		end	
		self.startNumbers:Play();
	else
		self.anchorCenter = false;
		self.isFree = true;
        if not addon.Alerts.pfl.DisableSounds then
            Alerts:Sound(Sounds:GetFile("COUNTDOWN_GO"))
        end
        self.digit1:SetAlpha(0)
        self.glow1:SetAlpha(0)
        self.digit2:SetAlpha(0)
        self.glow2:SetAlpha(0)
        isTimerRunning = false
	end
end

function DXE_PullTimerBar_SwitchToLargeDisplay(self)
	if not self.anchorCenter then
		self.anchorCenter = true;
		--This is to compensate texture size not affecting GetWidth() right away.
		self.digit1.width, self.digit2.width = self.style.w, self.style.w;
		self.digit1:SetSize(self.style.w, self.style.h);
		self.digit2:SetSize(self.style.w, self.style.h);
	end
end


---------------------------------------
-- API
---------------------------------------
function module:StartTimer(timeSeconds)
	if isTimerRunning then self:UpdateCountdown() end
    
    --[[if isTimerRunning then
        -- don't interupt the final count down
        if timer.startNumbers:IsPlaying() then
            timer.time = timeSeconds;
            timer.endTime = GetTime() + timeSeconds;
        end
    else]]
        isTimerRunning = true
        timer:ClearAllPoints();
        timer:SetPoint("TOP", 0, -179);
        
        timer.isFree = false;
        timer.time = timeSeconds;
        timer.startTime = GetTime()
        timer.endTime = GetTime() + timeSeconds;
        timer.style = TIMER_NUMBERS_SETS["BigGold"];
        
        timer.digit1:SetTexture(timer.style.texture);
        timer.digit2:SetTexture(timer.style.texture);
        timer.digit1:SetSize(timer.style.w/2, timer.style.h/2);
        timer.digit2:SetSize(timer.style.w/2, timer.style.h/2);
        --This is to compensate texture size not affecting GetWidth() right away.
        timer.digit1.width, timer.digit2.width = timer.style.w/2, timer.style.w/2;
        
        timer.digit1.glow = timer.glow1;
        timer.digit2.glow = timer.glow2;
        if pfl.AllowGlow then
            timer.glow1:SetTexture(timer.style.texture.."Glow");
            timer.glow2:SetTexture(timer.style.texture.."Glow");
        else
            timer.glow1:SetTexture("");
            timer.glow2:SetTexture("");
        end
        timer.updateTime = updateInterval;
        timer:SetScript("OnUpdate", DXE_PullTimerBar_BigNumberOnUpdate);
        timer:Show();
    --end
end

function module:StopTimer()
	timer:SetScript("OnUpdate",nil)
	timer:Hide()
end

function module:IsTimerRunning()
    return isTimerRunning
end

function module:StartEncounter()
	if addon.db.profile.SpecialTimers.PullTimerCancelOnPull then
		self:StopTimer()
	end
end
