-- Data_Bastion_Test.lua
-- Test realm patch for verifying the realm patching mechanism
if DXE.db.profile.Globals.Realm ~= "Test" then return end

DXE:RegisterRealmPatch("halfus", {
    alerts = {
        enragecd = { time = 999 },
        novacd = {
            varname = "test nova 86168",
        },
    },
})
