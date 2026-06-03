-- Data_Baradin_Gilneas.lua
local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Gilneas"

DXE:RegisterRealmPatch(realm, "argaloth", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "occuthar", {
    windows = {
        proxwindow = false,
    },
})

DXE:RegisterRealmPatch(realm, "Alizabal", {
    windows = {
        proxwindow = false,
    },
})
