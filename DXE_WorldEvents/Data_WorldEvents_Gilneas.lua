-- Data_WorldEvents_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "eventahune", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "eventcrownchemical", {
    windows = {
        proxwindow = false,
    },
})
