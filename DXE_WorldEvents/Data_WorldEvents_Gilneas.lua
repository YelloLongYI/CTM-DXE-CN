-- Data_WorldEvents_Gilneas.lua
if DXE.db.profile.Globals.Realm ~= "Gilneas" then return end

local L, SN, ST = DXE.L, DXE.SN, DXE.ST

DXE:RegisterRealmPatch("eventahune", {})
DXE:RegisterRealmPatch("eventcrownchemical", {})
