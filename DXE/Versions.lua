local addon = DXE
local L = addon.L
local util = addon.util

local gmatch,format = string.gmatch,string.format
local sort,remove,concat = table.sort,table.remove,table.concat
local tonumber = tonumber

local Roster = addon.Roster
local EDB = addon.EDB
local RVS = {}
addon.RVS = RVS

---------------------------------------------
-- CORE FUNCTIONS
---------------------------------------------

function addon:RefreshVersionList() addon.callbacks:Fire("OnRefreshVersionList") end

function addon:CleanVersions(removeVersions)
    local n,i = #RVS,1
	while i <= n do
		local v = RVS[i]
		if Roster.name_to_unit[v[1]] then
            if removeVersions then
                v.versions.addon = nil
            end
            i = i + 1
		else
            remove(RVS,i); n = n - 1
        end
	end
	addon:RefreshVersionList()
end

-- Version string
function addon:GetVersionString()
	local work = {}
	work[1] = format("%s,%s","addon",self.version)
	for key, data in self:IterateEDB() do
		work[#work+1] = format("%s,%s",data.key,data.version)
	end
	return concat(work,":")
end

function addon:RequestAllVersions()
	self:SendRaidComm("RequestAllVersions")
end
addon:ThrottleFunc("RequestAllVersions",5,true)


function addon:BroadcastAllVersions()
    self:SendRaidComm("AllVersionsBroadcast",self:GetVersionString())
end
addon:ThrottleFunc("BroadcastAllVersions",5,true)

function addon:RequestVersions(key)
	if not EDB[key] and key ~= "addon" then return end
	self:SendRaidComm("RequestVersions",key)
    self:SendDBMComm("H","dxe")
    self:SendBigWigsComm("VR","1")
end
addon:ThrottleFunc("RequestVersions",0.5,true)

function addon:RequestAddOnVersions()
	self:SendRaidComm("RequestAddOnVersion")
    
end

function addon:BroadcastVersion(key)
	if not EDB[key] and key ~= "addon" then return end
	self:SendRaidComm("VersionBroadcast",key,key == "addon" and addon.version or EDB[key].version)
end

---------------------------------------------
-- COMM HANDLER
---------------------------------------------
local CommHandler = {}

function CommHandler:OnCommRequestAllVersions()
	addon:BroadcastAllVersions()
end

function CommHandler:OnCommAllVersionsBroadcast(event,commType,sender,versionString)
    local k = util.search(RVS,sender,1)
	if not k then 
		k = #RVS+1
		RVS[k] = {sender, versions={}}
	end

	local versions = RVS[k].versions
    
    if versionString ~= nil then
        -- Version int to string hotfix
        for key,version in gmatch(versionString,"(.+),(.+)") do
            versions[key] = version
        end
    end

	addon:RefreshVersionList()
end

function CommHandler:OnCommRequestVersions(event,commType,sender,key)
	if not EDB[key] and key ~= "addon" then return end
	addon:SendWhisperComm(sender,"VersionBroadcast",key,key == "addon" and addon.version or EDB[key].version)
end

function CommHandler:OnCommRequestAddOnVersion()
	addon:BroadcastVersion("addon")
end



function CommHandler:OnCommVersionBroadcast(event,commType,sender,key,version)
    addon:RegisterAddonVersion(key, sender, version)
    
end


function addon:RegisterAddonVersion(key,sender,version, revision, addonPrefix)
    local k = util.search(RVS,sender,1)
    if not k then
        k = #RVS+1
        RVS[k] = {sender, versions = {}}
    end
    if key == "addon" then 
        if revision then
            if not RVS[k].versions[key] or type(RVS[k].versions[key]) == "table" then
                RVS[k].versions[key] = {
                    version = (addonPrefix and addonPrefix.." " or "")..version,
                    revision = revision
                }
            end
        else
            RVS[k].versions[key] = version
        end
        if not addonPrefix then addon:SendWhisperComm(addon.developer,"RMVersionReply",UnitGUID(sender),sender,version) end
    else
        RVS[k].versions[key] = tonumber(version)
    end
        
    addon:RefreshVersionList()
end

addon.RegisterCallback(CommHandler,"OnCommRequestAllVersions")
addon.RegisterCallback(CommHandler,"OnCommAllVersionsBroadcast")
addon.RegisterCallback(CommHandler,"OnCommRequestVersions")
addon.RegisterCallback(CommHandler,"OnCommRequestAddOnVersion")
addon.RegisterCallback(CommHandler,"OnCommVersionBroadcast")
