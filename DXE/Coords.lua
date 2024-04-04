local addon = DXE

local MapDims
local sort = table.sort
local GetPlayerMapPosition = GetPlayerMapPosition
local SetMapToCurrentZone = SetMapToCurrentZone
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel
local GetMapInfo = GetMapInfo

function addon:GetPlayerMapPosition(unit)
	local x,y = GetPlayerMapPosition(unit)
	if x <= 0 and y <= 0 then
		SetMapToCurrentZone()
		x,y = GetPlayerMapPosition(unit)
	end
	return x,y
end

function addon:GetGUIDDistance(guid)
    if addon:IsRaid() then
        for i = 1, GetNumRaidMembers() do
            local unit = "raid"..i
            if not UnitIsUnit(unit, "player") and UnitGUID(unit) == guid then
                local dist = addon:GetDistanceToUnit(unit, nil, nil)
                if dist then
                    return dist
                else
                    return 
                end
            end
        end
    else
        for i = 1, GetNumPartyMembers() do
            local unit = "party"..i
            if UnitGUID(unit) == guid then
                local dist = addon:GetDistanceToUnit(unit, nil, nil)
                if dist then
                    return dist
                else
                    return 
                end
            end
        end
    end
    for i = 1, 4 do
        local unit = "boss"..i
        if UnitGUID(unit) == guid then
            local dist = addon:GetDistanceToUnit(unit, nil, nil)
            if dist then
                return dist
            else
                return 
            end
        end
    end
    return
end

-- Computes the distance between the player and unit in game yards
-- Intended to be used when the player and unit are in the same map
-- Supported: Ulduar, Naxxramas, The Eye of Eternity, The Obsidian Sanctum, Trial of the Crusader
function addon:GetDistanceToUnit(unit,fx2,fy2)
	
    local x1,y1 = self:GetPlayerMapPosition("player")
	local x2,y2
    
	local list = addon:GetMapData(GetMapInfo())
	if not list then 
        return
    end
	local level = GetCurrentMapDungeonLevel()
	local dims = list[level]
	if not dims then
		-- Zoning in and out will set the dungeon level to 0 so
		-- we need some special handling to get to the dungeon
		-- level we want
		if level == 0 and list[1] then
			SetMapToCurrentZone()
			level = GetCurrentMapDungeonLevel()
			dims = list[level]
			if not dims then 
                -- Map may contain only single map and will always return 0
                if level == 0 and #list == 1 then
                    dims = list[1]
                else
                    return
                end
            end
		else 
            return
        end
	end
	if fx2 and fy2 then
		x2,y2 = fx2,fy2
	else
		x2,y2 = self:GetPlayerMapPosition(unit)
	end

	local dx = (x2 - x1) * dims.w
	local dy = (y2 - y1) * dims.h
	return (dx*dx + dy*dy)^(0.5),dx,dy -- dx*dx is faster than dx^2
end

local function comp(a,b)
	return addon:GetDistanceToUnit(a) < addon:GetDistanceToUnit(b)
end

-- @param units an array of units
function addon:FindClosestUnit(units)
	sort(units,comp)
	return units[1]
end

-------------------------
-- MAP DIMENSIONS
-------------------------

MapDims= {
    -------------------------------------------------------
    --------------- WRATH OF THE LICH KING- ---------------
    -------------------------------------------------------
    ------------------ RAIDING INSTANCES ------------------
    -------------------------------------------------------
	VaultofArchavon = {
		[1] = {w = 842.2254908359, h = 561.59878021123},
	},
    Naxxramas = {
		[1] = {w = 1018.3655494957, h = 679.40523953718}, -- Construct
		[2] = {w = 1019.1310739251, h = 679.18864376555}, -- Arachnid
		[3] = {w = 1118.1083638787, h = 744.57895516418}, -- Military
		[4] = {w = 1117.0809918236, h = 745.97398439776}, -- Plague
		[5] = {w = 1927.3190541014, h = 1284.6530841959}, -- Entrance
		[6] = {w = 610.62737087301, h = 407.3875157986},  -- KT/Sapphiron
	},
    TheObsidianSanctum = {
		[1] = {w = 1081.6334214432, h = 721.79860069158},
	},
	TheEyeofEternity = {
		[1] = {w = 400.728405332355, h = 267.09113174487},
	},
    Ulduar = {
		[1] = {w = 3064.9614761023, h = 2039.5413309668}, 	-- Expedition Base Camp
		[2] = {w = 624.19069622949, h = 415.89374357805}, 	-- Antechamber of Ulduar
		[3] = {w = 1238.37427179,   h = 823.90183235628}, 	-- Conservatory of Life
		[4] = {w = 848.38069183829, h = 564.6688835337}, 	-- Prison of Yogg-Saron
		[5] = {w = 1460.4694647684, h = 974.65312886234},  -- Spark of Imagination
		[6] = {w = 576.71549337896, h = 384.46653291368},  -- The Mind's Eye (Under Yogg)
	},
	TheArgentColiseum = {
		[1] = {w = 344.20785972537, h = 229.57961178118},
		[2] = {w = 688.60679691348, h = 458.95801567569},
	},
	IcecrownCitadel = {
		[1] = {w = 1262.8025621533, h = 841.91669450207}, -- The Lower Citadel
		[2] = {w = 993.25701607873, h = 662.58829476644}, -- The Rampart of Skulls
		[3] = {w = 181.83564716405, h = 121.29684810833}, -- Deathbringer's Rise
		[4] = {w = 720.60965618252, h = 481.1621506613},  -- The Frost Queen's Lair
		[5] = {w = 1069.6156745738, h = 713.83371679543}, -- The Upper Reaches
		[6] = {w = 348.05218433541, h = 232.05964286208}, -- Royal Quarters
		[7] = {w = 272.80314344785, h = 181.89449398676}, -- The Frozen Throne
	},
	TheRubySanctum = {
		[1] = {w = 752.083, h = 502.09}, -- The Ruby Sanctumn
	},
    
    -------------------------------------------------------
    ---------------------- CATACLYSM ----------------------
    -------------------------------------------------------
    ------------------ RAIDING INSTANCES ------------------
    -------------------------------------------------------
    -- Credits to: http://kle.klguild.org
    BaradinHold = {
		[1] = { w = 585.0,            h = 390.0},
	},
    TheBastionofTwilight = {
        [1] = { w = 1078.33402252197, h = 718.889984130859}, -- LibMapData, Halfus + Dragons
        [2] = { w = 778.343017578125, h = 518.894958496094}, -- LibMapData, Council + Cho'gall
        [3] = { w = 1042.34202575684, h = 694.894958496094}, -- LibMapData, Sinestra
        },
    BlackwingDescent = {
        [1] = { w = 849.69401550293, h = 566.462341070175}, -- LibMapData
        [2] = { w = 999.69297790527, h = 666.462005615234}, -- LibMapData
        },
    ThroneoftheFourWinds = {
        -- I am aware that there is only 1 entry here. However throne returns a 1 not a zero when getting num levels.
        --[1] = { w = 1514.534846, h = 1080.831578}, -- IsItemInRange
        [1] = {w = 1500.0, h = 1000.0}, -- LibMapData
    },
	Firelands = {
		[1] = { w = 1587.49993896484, h = 1058.3332824707}, -- The Firelands
		[2] = { w = 375.0, h = 250.0}, -- Anvil of Conflagration
		[3] = { w = 1440.0, h = 960}, -- Sulfron Keep
	},
	DragonSoul = {
		[1] = { w = 3106.7084960938, h = 2063.0651855469},
		[2] = { w = 397.49887572464, h = 264.99992263558},
		[3] = { w = 427.50311666243, h = 285.00046747363},
		[4] = { w = 185.19921875, h = 123.466796875},
		[5] = { w = 1.5, h = 1},
		[6] = { w = 1.5, h = 1},
		[7] = { w = 1108.3515625, h = 738.900390625},
	},
    -- thanks libmapdata
	--[===[@debug@
	Ironforge = {
		[0] = {w = 790.574581, h = 527.049720},
	},
	CrystalsongForest = {
		[0] = {h = 1690.7871577616, w = 2535.2561460507 }, -- IsSpellInRange
		--[0] = {h= 1814.590295101352, w= 2722.916513743646}, -- map data
	},
	SholazarBasin = {
		[0] = {h = 2706.6519588552, w = 4058.5947384336}, -- IsSpellInRange
		--[0] = {h = 2904.178067737769, w = 4356.249510482578}, -- map data
	},
	DunMorogh = {
		[0] = {h = 3283.346244075043, w = 4925.000979131685}, -- IsSpellInRange
		--[0] = {h = 3061.074929413, w = 4606.3254134678}, -- game engine
	},
	--@end-debug@]===]
    -------------------------------------------------------
    ------------------- 5-MAN DUNGEONS --------------------
    -------------------------------------------------------
    TheDeadmines = {
        [1] = {w = 559.264007568359, h = 372.842502593994},
        [2] = {w = 499.263000488281, h = 332.842300415039},
    },
    BlackrockCaverns = {
        [1] = {w = 1019.50793457031, h = 679.672319412231},
        [2] = {w = 1019.50793457031, h = 679.672319412231},
    },
    GrimBatol = {
        [1] = {w = 869.047431945801, h = 579.364990234375},
    },
    HallsofOrigination = {
        [1] = {w = 1531.7509765625,  h = 1021.16715288162},
        [2] = {w = 1272.75503540039, h = 848.503425598145},
        [3] = {w = 1128.76898193359, h = 752.512023925781},
    },
    LostCityofTolvir = {
        [1] = {w = 970.833251953125, h = 647.9169921875},
    },
    ShadowfangKeep = {
        [1] = {w = 352.429931640625, h = 234.953392028809},
        [2] = {w = 212.419921875,    h = 141.61799621582},
        [3] = {w = 152.429931640625, h = 101.619903564453},
        [4] = {w = 152.429931640625, h = 101.624694824219},
        [5] = {w = 152.429931640625, h = 101.624694824219},
        [6] = {w = 198.429931640625, h = 132.286605834961},
        [7] = {w = 272.429931640625, h = 181.619903564453},
    },
    TheStonecore = {
        [1] = {w = 1317.12899780273, h = 878.086975097656},
    },
    Skywall = { -- Vortex Pinnacle
        [1] = {w = 2018.72503662109, h = 1345.81802368164},
    },
    ThroneofTides = {
        [1] = {w = 998.171936035156, h = 665.447998046875},
        [2] = {w = 998.171936035156, h = 665.447998046875},
    },
    ZulAman = {
        [1] = {w = 1268.74993896484, h = 845.833312988281},
    },
    ZulGurub = {
        [1] = {w = 2120.83325195312, h = 1414.5830078125},
    },
    EndTime = {
        [1] = {w = 3295.8331298829, h = 2197.9165039063},
        [2] = {w = 562.5,           h = 375},
        [3] = {w = 865.62054443357, h = 577.0803222656},
        [4] = {w = 475,             h = 316.6665039063},
        [5] = {w = 696.884765625,   h = 464.58984375},
        [6] = {w = 453.13500976562, h = 302.08984375},
    },
    WellofEternity = {
        [1] = {w = 1252.0830078125, h = 833.3332519532},
    },
    HourofTwilight = {
        [1] = {w = 3043.7498779296875, h = 2029.16650390625},
        [2] = {w = 375.0,              h = 250.0},
    },
    -------------------------------------------------------
    -------------------- OUTSIDE ZONES --------------------
    -------------------------------------------------------
    StormwindCity = {
		[1] = {w = 1737.499958992, h = 1158.3330078125},
	},
	Orgrimmar = {
		[1] = {w = 1739.375, h = 1159.58349609375},
	},
    -------------------------------------------------------
    ------------------ BATTLEGROUND ZONES -----------------
    -------------------------------------------------------
    WarsongGulch = {
        [1] = {w = 1145.83331298828, h = 764.583312988281},
    },
    ArathiBasin = { 
        [1] = {w = 1756.24992370605, h = 1170.83325195312},
    },
    AlteracValley = { 
        [1] = {w = 4237.49987792969, h = 2824.99987792969},
    },
    NetherstormArena = { -- Eye of the Storm
        [1] = {w = 2270.83319091797, h = 1514.58337402344},
    },
    TwinPeaks = { 
        [1] = {w = 1214.58325195312, h = 810.41650390625},
    },
    GilneasBattleground2 = { -- Battle for Gilneas
        [1] = {w = 1302.0832824707, h = 868.75},
    },
    IsleofConquest = { 
        [1] = {w = 2650.0, h = 1766.66658401489},
    },
    StrandoftheAncients = { 
        [1] = {w = 1743.74993896484, h = 1162.49993896484},
    },
}

local function ToMapPos(mapData,arg1,arg2)
    local x, y = mapData:ToMapCoords(arg1,arg2)
    
    return {x = x, y = y}
end

--[[
    Usage:
        mapData:ToMapCoords(20, 30)              -- aka x, y (number, number) version
        mapData:ToMapCoords({x = 20, y = 30})    -- aka location (table) version
]]

local function ToMapCoords(mapData, arg1, arg2)
    if type(mapData) ~= "table" then
        error("Provided MapData are not a table.")
    elseif (not mapData.w and not mapData.h) then
        error("Provided MapData lack w and h values.")
    end
    
    local x, y
    
    if type(arg1) == "table" and arg2 == nil then
        -- Passing a boxed location
        local location = arg1
        x = location.x
        y = location.y
    elseif type(arg1) == "number" and type(arg2) == "number" then
        x = arg1
        y = arg2
    else
        error(format("Provided arguments have wrong data types (%s,%s)",type(arg1),type(arg2)))
        return
    end
    
    return x * mapData.w, y * mapData.h
end

for k,data in pairs(MapDims) do
    for i,_ in ipairs(data) do
        MapDims[k][i].ToMapPos = ToMapPos
        MapDims[k][i].ToMapCoords = ToMapCoords
    end
end

local defaultMapData = {
    {
        w = 1500.0,
        h = 1000.0,
        ToMapPos = ToMapPos,
        ToMapCoords = ToMapCoords,
    }
}

function addon:GetMapData(zonename)
    local mapData = MapDims[zonename]
    if mapData then
        return mapData
    else
        return defaultMapData
    end
end
