-- Data_Throne_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "windconclave", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "alakir", {
    windows = {
        proxwindow = false,
    },
})
