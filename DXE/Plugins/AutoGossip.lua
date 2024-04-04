local addon = DXE
local L = addon.L


local defaults = {
	profile = {
		Gossips = {},
        AutoGossip = true,
        PrintActivationMessages = true,
	}
}

local db,pfl,gbl

--------------------------
-- INITIALIZATION
---------------------------------------

local module = addon:NewModule("AutoGossip","AceTimer-3.0","AceEvent-3.0")
addon.AutoGossip = module
addon.AutoGossip.defaults = defaults

function module:RefreshProfile()
	pfl = db.profile
end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("AutoGossip", defaults)
	db = self.db
	pfl = db.profile
    gbl = db.global
    
	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
    
    module:RegisterEvent("GOSSIP_SHOW")
end

local gossipDB = {}
addon.AutoGossip.gossipDB = gossipDB

function addon:RegisterGossip(gossipkey, pattern, name, default)
--function addon:RegisterGossip(gossipkey, pattern, name, default, settings)
    if not gossipkey or not pattern then return end
    
    gossipDB[gossipkey] = {
        pattern = pattern,
        name = name or pattern,
        --settings = settings,
    }
    
    pfl.Gossips[gossipkey] = default or true
    
end

local ProcessGossipTimer

function module:GOSSIP_SHOW()
    if not pfl.AutoGossip then return end
    
    if ProcessGossipTimer then
        module:CancelTimer(ProcessGossipTimer, true)
        ProcessGossipTimer = nil
    end
    ProcessGossipTimer = module:ScheduleTimer("PROCESS_GOSSIP",0.01)
end



function module:PROCESS_GOSSIP()
    for gossipIndex=1,GetNumGossipOptions() do
        local gossipText,gossipType = select(gossipIndex*2-1,GetGossipOptions())
    end
    
    if (GetNumGossipAvailableQuests() > 0) or (GetNumGossipActiveQuests() > 0) then return end -- exit if the NPC offers quest interactions
    
    for gossipKey,gossipConfig in pairs(gossipDB) do
        if pfl.Gossips[gossipKey] then
            for gossipIndex=1,GetNumGossipOptions() do
                local gossipText,gossipType = select(gossipIndex*2-1,GetGossipOptions())
                if gossipType == "gossip" and gossipText:match(gossipConfig.pattern) then
                    --local block = true
                    --if gossipConfig.settings and gossipConfig.settings.one_time and gossipConfig.activated then block = false end
                    --if block then
                        SelectGossipOption(gossipIndex)
                        gossipDB[gossipKey].activated = true
                        if pfl.PrintActivationMessages then
                            addon:Print(format("|cffffff00%s|r |cffffffff%s|r",gossipDB[gossipKey].name,L["automatically selected."]))
                        end
                    --end
                end
            end
        end
    end
end
