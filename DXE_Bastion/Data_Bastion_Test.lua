-- Data_Bastion_Test.lua
-- Test realm patch for verifying the realm patching mechanism

local L, SN, ST = DXE.L, DXE.SN, DXE.ST
local realm = "Test"

DXE:RegisterRealmPatch(realm, "halfus", {
    alerts = DXE.Replace({
        enragecd = {
            varname = L.alert["Berserk CD"],
            type = "dropdown",
            text = L.alert["Berserk"],
            time = 999,
            flashtime = 10,
            color1 = "RED",
            icon = ST[12317],
        },
        novacd = {
            varname = "novacd test 86168",
            type = "dropdown",
            text = format(L.alert["Next %s"], SN[86168]),
            time = 12,
            time2 = 11,
            time3 = "<novadelayed>",
            flashtime = 3,
            color1 = "MAGENTA",
            sound = "MINORWARNING",
            icon = ST[86168],
        },
    }),
})
