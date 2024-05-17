local addon = DXE

local SM = addon.SM
local Media = {}
addon.Media = Media


-------------------------
-- DB
-------------------------

local pfl
local function RefreshProfile(db) 
	pfl = db.profile 
	addon:NotifyAllMedia()
end
addon:AddToRefreshProfile(RefreshProfile)

-------------------------
-- Colors
-------------------------

do
	local Colors = {
    -- [r,g,b] standard colors, [sr,sg,sb] spark colors
        BLACK =         {r=0,       g=0,      b=0,     sr=1,    sg=1,      sb=1},
        BLUE =          {r=0,       g=0,      b=1,     sr=0,    sg=0.51,   sb=1},
        BROWN =         {r=.65,     g=.165,   b=.165,  sr=1,    sg=1,      sb=0},
        CYAN =          {r=0,       g=1,      b=1,     sr=0,    sg=1,      sb=1},
        DCYAN =         {r=0,       g=.6,     b=.6,    sr=0,    sg=1,      sb=1},
        GOLD =          {r=1,       g=0.843,  b=0,     sr=1,    sg=1,      sb=1},
        LIGHTBLUE =     {r=0,       g=0.51,   b=1,     sr=0,    sg=0.51,   sb=1},
        LIGHTGREEN =    {r=0,       g=1,      b=0,     sr=0,    sg=1,      sb=0},
        GREEN =         {r=0,       g=0.5,    b=0,     sr=0,    sg=1,      sb=0},
        GREY =          {r=.3,      g=.3,     b=.3,    sr=0.5,  sg=0.5,    sb=0.5},
        INDIGO =        {r=0,       g=0.25,   b=0.71,  sr=0,    sg=0.5,    sb=1},
        MAGENTA =       {r=1,       g=0,      b=1,     sr=1,    sg=0,      sb=1},
        MIDGREY =       {r=.5,      g=.5,     b=.5,    sr=0.5,  sg=0.5,    sb=0.5},
        ORANGE =        {r=1,       g=0.5,    b=0,     sr=0.8,  sg=0.8,    sb=0},
        PEACH =         {r=1,       g=0.9,    b=0.71,  sr=0.8,  sg=0.8,    sb=0.4},
        PINK =          {r=1,       g=0.5,    b=1,     sr=1,    sg=0.5,    sb=1},
        PURPLE =        {r=0.627,   g=0.125,  b=0.941, sr=1,    sg=0,      sb=1},
        RED =           {r=0.9,     g=0,      b=0,     sr=1,    sg=0.3,    sb=0},
        TAN =           {r=0.82,    g=0.71,   b=0.55,  sr=0.82, sg=0.71,   sb=0.55},
        TEAL =          {r=0,       g=0.5,    b=0.5,   sr=0,    sg=0.7,    sb=0.7},
        TURQUOISE =     {r=.251,    g=.878,   b=.816,  sr=0.2,  sg=0.9,    sb=0.9}, 
        VIOLET =        {r=0.55,    g=0,      b=1,     sr=0.66, sg=0,      sb=0.75}, 
        WHITE =         {r=1,       g=1,      b=1,     sr=1,    sg=1,      sb=1},
        YELLOW =        {r=1,       g=1,      b=0,     sr=1,    sg=1,      sb=0},
	}
    addon.defaults.profile.Colors = Colors
	--[[
	Grabbed by Localizer

	L["BLACK"] 	L["BLUE"] 		L["BROWN"]	 	L["CYAN"]
	L["DCYAN"] 	L["GOLD"] 		L["GREEN"] 		L["GREY"]
	L["INDIGO"] L["MAGENTA"] 	L["MIDGREY"] 	L["ORANGE"]
	L["PEACH"] 	L["PINK"] 		L["PURPLE"] 	L["RED"]
	L["TAN"] 	L["TEAL"] 		L["TURQUOISE"] L["VIOLET"]
	L["WHITE"] 	L["YELLOW"]

	]]
end

-------------------------
-- Sounds
-------------------------

do
	local Sounds = {}

	local List = {
		["Bell Toll Alliance"] = "Sound\\Doodad\\BellTollAlliance.wav",
		["Bell Toll Horde"] = "Sound\\Doodad\\BellTollHorde.wav",
		["Low Mana"] = "Interface\\AddOns\\DXE\\Sounds\\LowMana.mp3",
        ["Low Health"] = "Interface\\AddOns\\DXE\\Sounds\\LowHealth.mp3",
		["Zing Alarm"] = "Interface\\AddOns\\DXE\\Sounds\\ZingAlarm.mp3",
		["Wobble"] = "Interface\\Addons\\DXE\\Sounds\\Wobble.mp3",
		["Bottle"] = "Interface\\AddOns\\DXE\\Sounds\\Bottle.mp3",
		["Lift Me"] = "Interface\\AddOns\\DXE\\Sounds\\LiftMe.mp3",
		["Neo Beep"] = "Interface\\AddOns\\DXE\\Sounds\\NeoBeep.mp3",
		["PvP Flag Taken"] = "Sound\\Spells\\PVPFlagTaken.wav",
		["Bad Press"] = "Sound\\Spells\\SimonGame_Visual_BadPress.wav",
		["Run Away"] = "Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav",
		["FF1 Victory"] = "Interface\\AddOns\\DXE\\Sounds\\FF1_Victory.mp3",
        ["FF2 Victory"] = "Interface\\AddOns\\DXE\\Sounds\\FF2_Victory.mp3",
        ["UT2K3 Victory"] = "Interface\\Addons\\DXE\\Sounds\\UT2K3_Victory1.mp3",
        ["FF1 Wipe"] = "Sound\\Creature\\YoggSaron\\UR_YoggSaron_Slay01.ogg",
        ["Minor Warning"] = "Sound\\Doodad\\BellTollNightElf.wav",
        ["Algalon Beware"] = "Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav",
        ["Shadow Dance"] = "Sound\\SPELLS\\Rogue_shadowdance_state.ogg",
        ["RunAway"] = "Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav",
        ["Countdown: Tick"] = "25477",
        ["Countdown: Go"] = "25478",
        ["LevelUp"] = "Sound\\interface\\levelup.ogg",
        ["ReadyCheck"] = "Sound\\interface\\levelup2.ogg",
        ["BGReadyCheck"] = "8463",
        ["EnteringGroup"] = "881",

		-- migrate from DBM
		["aeblood"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\aeblood.mp3",
		["aesoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\aesoon.mp3",
		["avoidslime"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\avoidslime.mp3",
		["awaycloud"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\awaycloud.mp3",
		["awayfireorb"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\awayfireorb.mp3",
		["awayflower"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\awayflower.mp3",
		["awayline"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\awayline.mp3",
		["awaymutant"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\awaymutant.mp3",
		["awayshard"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\awayshard.mp3",
		["awayspider"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\awayspider.mp3",
		["backsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\backsoon.mp3",
		["balancenow"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\balancenow.mp3",
		["bbappear"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\bbappear.mp3",
		["bigkill"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\bigkill.mp3",
		["blackorb"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\blackorb.mp3",
		["blisterling"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\blisterling.mp3",
		["bluecircle"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\bluecircle.mp3",
		["bluecircleboom"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\bluecircleboom.mp3",
		["blueessence"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\blueessence.mp3",
		["boltappear"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\boltappear.mp3",
		["boomrun"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\boomrun.mp3",
		["catalysm"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\catalysm.mp3",
		["changemt"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\changemt.mp3",
		["checkhp"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\checkhp.mp3",
		["chickenfrenzy"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\chickenfrenzy.mp3",
		["clickbravo"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\clickbravo.mp3",
		["clickshield"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\clickshield.mp3",
		["coreout"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\coreout.mp3",
		["countfive"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\countfive.mp3",
		["countfour"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\countfour.mp3",
		["countone"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\countone.mp3",
		["countthree"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\countthree.mp3",
		["counttwo"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\counttwo.mp3",
		["crystalappear"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\crystalappear.mp3",
		["dangsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\dangsoon.mp3",
		["debuffhigh"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\debuffhigh.mp3",
		["deciblade"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\deciblade.mp3",
		["deepsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\deepsoon.mp3",
		["dispelnow"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\dispelnow.mp3",
		["dragonnow"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\dragonnow.mp3",
		["drone"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\drone.mp3",
		["dshigh"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\dshigh.mp3",
		["earthquake"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\earthquake.mp3",
		["eggsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\eggsoon.mp3",
		["elementsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\elementsoon.mp3",
		["empowersulf"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\empowersulf.mp3",
		["empowersulfsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\empowersulfsoon.mp3",
		["fiend"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\fiend.mp3",
		["findmc"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\findmc.mp3",
		["findwell"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\findwell.mp3",
		["findwind"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\findwind.mp3",
		["firearound"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\firearound.mp3",
		["firebreathsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\firebreathsoon.mp3",
		["firecircle"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\firecircle.mp3",
		["firecirclesoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\firecirclesoon.mp3",
		["fireline"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\fireline.mp3",
		["firestorm"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\firestorm.mp3",
		["firestormsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\firestormsoon.mp3",
		["firewall"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\firewall.mp3",
		["flamemelee"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\flamemelee.mp3",
		["flamemiddle"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\flamemiddle.mp3",
		["flamerange"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\flamerange.mp3",
		["flamerepeat"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\flamerepeat.mp3",
		["flamesoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\flamesoon.mp3",
		["followline"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\followline.mp3",
		["fragsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\fragsoon.mp3",
		["frostflake"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\frostflake.mp3",
		["ghostsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\ghostsoon.mp3",
		["goblinappear"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\goblinappear.mp3",
		["gofirecircle"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\gofirecircle.mp3",
		["greenessence"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\greenessence.mp3",
		["gripaway"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\gripaway.mp3",
		["hammerleft"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\hammerleft.mp3",
		["hammermiddle"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\hammermiddle.mp3",
		["hammerright"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\hammerright.mp3",
		["healparasite"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\healparasite.mp3",
		["heartice"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\heartice.mp3",
		["helpkick"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\helpkick.mp3",
		["holdit"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\holdit.mp3",
		["iceball"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\iceball.mp3",
		["icetombsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\icetombsoon.mp3",
		["inferblade"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\inferblade.mp3",
		["jumpsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\jumpsoon.mp3",
		["justrun"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\justrun.mp3",
		["kickcast"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\kickcast.mp3",
		["killblack"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killblack.mp3",
		["killblue"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killblue.mp3",
		["killcrystal"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killcrystal.mp3",
		["killegg"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killegg.mp3",
		["killfireele"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killfireele.mp3",
		["killghost"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killghost.mp3",
		["killgreen"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killgreen.mp3",
		["killicetomb"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killicetomb.mp3",
		["killmeteor"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killmeteor.mp3",
		["killmixone"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killmixone.mp3",
		["killmuscle"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killmuscle.mp3",
		["killparasite"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killparasite.mp3",
		["killpurple"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killpurple.mp3",
		["killshaele"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killshaele.mp3",
		["killshield"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killshield.mp3",
		["killslime"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killslime.mp3",
		["killvoid"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killvoid.mp3",
		["killyellow"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\killyellow.mp3",
		["lavaspew"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\lavaspew.mp3",
		["leftside"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\leftside.mp3",
		["masteraura"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\masteraura.mp3",
		["meteorrun"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\meteorrun.mp3",
		["meteorsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\meteorsoon.mp3",
		["meteoryou"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\meteoryou.mp3",
		["mobsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\mobsoon.mp3",
		["nefsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\nefsoon.mp3",
		["orbrun"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\orbrun.mp3",
		["pillar"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\pillar.mp3",
		["poisoncircle"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\poisoncircle.mp3",
		["ptwo"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\ptwo.mp3",
		["purplecirclesoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\purplecirclesoon.mp3",
		["redessence"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\redessence.mp3",
		["rightside"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\rightside.mp3",
		["roarsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\roarsoon.mp3",
		["rootnow"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\rootnow.mp3",
		["runaway"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\runaway.mp3",
		["runin"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\runin.mp3",
		["runout"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\runout.mp3",
		["sacrifice"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\sacrifice.mp3",
		["safenow"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\safenow.mp3",
		["shadow3ae"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\shadow3ae.mp3",
		["shard"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\shard.mp3",
		["shattericesoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\shattericesoon.mp3",
		["shieldoff"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\shieldoff.mp3",
		["shieldsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\shieldsoon.mp3",
		["shrapnelyou"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\shrapnelyou.mp3",
		["shroud"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\shroud.mp3",
		["skinsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\skinsoon.mp3",
		["someonecaught"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\someonecaught.mp3",
		["sonicsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\sonicsoon.mp3",
		["sparksoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\sparksoon.mp3",
		["spear"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\spear.mp3",
		["specialsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\specialsoon.mp3",
		["spiderling"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\spiderling.mp3",
		["spinner"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\spinner.mp3",
		["spread"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\spread.mp3",
		["squall"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\squall.mp3",
		["stackpurple"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\stackpurple.mp3",
		["staticout"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\staticout.mp3",
		["stilldanger"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\stilldanger.mp3",
		["stompsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\stompsoon.mp3",
		["stompstart"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\stompstart.mp3",
		["stopatk"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\stopatk.mp3",
		["stopmove"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\stopmove.mp3",
		["stormpillar"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\stormpillar.mp3",
		["stunsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\stunsoon.mp3",
		["telesoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\telesoon.mp3",
		["thundershock"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\thundershock.mp3",
		["trinket"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\trinket.mp3",
		["twilighttime"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\twilighttime.mp3",
		["twkill"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\twkill.mp3",
		["volcano"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\volcano.mp3",
		["watchimpale"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\watchimpale.mp3",
		["watchwave"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\watchwave.mp3",
		["wavesoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\wavesoon.mp3",

		["attackarcane"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\attackarcane.mp3",
		["attackfire"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\attackfire.mp3",
		["attacklightning"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\attacklightning.mp3",
		["attackpoison"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\attackpoison.mp3",
		["avoidtarget"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\avoidtarget.mp3",
		["ballappear"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\ballappear.mp3",
		["blackout"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\blackout.mp3",
		["bossout"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\bossout.mp3",
		["breathsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\breathsoon.mp3",
		["causticsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\causticsoon.mp3",
		["doubleat"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\doubleat.mp3",
		["eleaesoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\eleaesoon.mp3",
		["eleaestart"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\eleaestart.mp3",
		["enoughstack"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\enoughstack.mp3",
		["firestomp"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\firestomp.mp3",
		["focusattack"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\focusattack.mp3",
		["frostappear"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\frostappear.mp3",
		["frostsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\frostsoon.mp3",
		["furysoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\furysoon.mp3",
		["gofire"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\gofire.mp3",
		["killrageface"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\killrageface.mp3",
		["mutant"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\mutant.mp3",
		["selffight"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\selffight.mp3",
		["shadowae"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\shadowae.mp3",
		["shockrun"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\shockrun.mp3",
		["targetsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\targetsoon.mp3",
		["twilighttime"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\twilighttime.mp3",
		["windblast"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\windblast.mp3",
		["windblastsoon"] = "Interface\\AddOns\\DXE\\SoundsCN\\extrasounds\\zhCN\\windblastsoon.mp3",
		
	}
	local sound_defaults = addon.defaults.profile.Sounds

	function Sounds:GetFile(id)
    if id == "None" or not id then
      return "Interface\\Quiet.mp3"
    elseif string.find(id,"\\") then
      return id
    else
        local soundSource = sound_defaults[id] and pfl.Sounds[id] or pfl.CustomSounds[id]
        if addon.db.profile.CustomSoundFiles[soundSource] then
            return addon.db.profile.CustomSoundFiles[soundSource]
        else
            return SM:Fetch("sound",soundSource)
        end
    end
  end

	Media.Sounds = Sounds
	for name,file in pairs(List) do SM:Register("sound",name,file) end
    
    function addon:IsGameSoundMuted()
        return GetCVar("Sound_EnableSFX") == "0"
    end
end

-------------------------
-- FONTS
-------------------------

do
	SM:Register("font", "Bastardus Sans", "Interface\\AddOns\\DXE\\Fonts\\BS.ttf")
	SM:Register("font", "Courier New", "Interface\\AddOns\\DXE\\Fonts\\CN.ttf")
	SM:Register("font", "Franklin Gothic Medium", "Interface\\AddOns\\DXE\\Fonts\\FGM.ttf")
end

-------------------------
-- TEXTURE ICONS 
-------------------------
do
    local TexturesIcons = {
        AchievementShield = {"\124TInterface\\ACHIEVEMENTFRAME\\UI-Achievement-TinyShield.blp:<width>:<height>:0:0:32:32:0:19:0:19\124t",12,12},
    }
    Media.TexturesIcons = TexturesIcons
    
    function addon:GetTextureIcon(key, width, height)
        local icon = Media.TexturesIcons[key]
        if not icon then return end
        
        width = width or icon[2]
        height = height or icon[3]
        return icon[1]:gsub("<width>",width):gsub("<height>",height)
    end
    
    local TI = setmetatable({}, {__index = 
        function (t, key)
            return addon:GetTextureIcon(key)
        end,
    })
    addon.TI = TI

end

-------------------------
-- GLOBALS
-------------------------
local bgBackdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", insets = {}}
local borderBackdrop = {}

function addon:NotifyAllMedia()
	addon:NotifyBarTextureChanged()
	addon:NotifyFontChanged()
	addon:NotifyBorderChanged()
	addon:NotifyBorderColorChanged()
	addon:NotifyBorderEdgeSizeChanged()
	addon:NotifyBackgroundColorChanged()
	addon:NotifyBackgroundInsetChanged()
	addon:NotifyBackgroundTextureChanged()
end

do
	local reg = {}
	function addon:RegisterFontString(fontstring,size,flags)
		reg[#reg+1] = fontstring
		fontstring:SetFont(SM:Fetch("font",pfl.Globals.Font),size,flags)
	end

	function addon:NotifyFontChanged(fontFile)
		local font = SM:Fetch("font",pfl.Globals.Font)
		for _,fontstring in ipairs(reg) do
			local _,size,flags = fontstring:GetFont()
			fontstring:SetFont(font,size,flags)
		end
	end
end

do
	local reg = {}
	function addon:RegisterTimerFontString(fontstring,size,flags)
		reg[#reg+1] = fontstring
		fontstring:SetFont(SM:Fetch("font",pfl.Globals.TimerFont),size,flags)
	end

	function addon:NotifyTimerFontChanged(fontFile)
		local font = SM:Fetch("font",fontFile)
		for _,fontstring in ipairs(reg) do 
			local _,size,flags = fontstring:GetFont()
			fontstring:SetFont(font,size,flags)
		end
	end
end

do
	local reg = {}
	function addon:RegisterStatusBar(statusbar,bartype)
		reg[#reg+1] = {statusbar,bartype}
        if not bartype then
            texture = SM:Fetch("statusbar",pfl.Globals.BarTexture)
        elseif bartype == "HealthWatcher" then
            texture = SM:Fetch("statusbar",pfl.Pane.BarTexture)
        end
		statusbar:SetStatusBarTexture(texture)
		statusbar:GetStatusBarTexture():SetHorizTile(false)
	end
    
	function addon:NotifyBarTextureChanged(name)
        local texture
		for _,regData in ipairs(reg) do
            local statusbar,bartype = unpack(regData)
            if not bartype then
                texture = SM:Fetch("statusbar",pfl.Globals.BarTexture)
            elseif bartype == "HealthWatcher" then
                texture = SM:Fetch("statusbar",pfl.Pane.BarTexture)
            end
            statusbar:SetStatusBarTexture(texture)
        end
	end   
end

do
	local reg = {}
	function addon:RegisterBorder(frame,noskin)
		reg[#reg+1] = frame
		if not noskin then
            local r,g,b,a = unpack(pfl.Globals.BorderColor)
            borderBackdrop.edgeFile = SM:Fetch("border",pfl.Globals.Border)
            borderBackdrop.edgeSize = pfl.Globals.BorderEdgeSize
            frame:SetBackdrop(borderBackdrop)
            frame:SetBackdropBorderColor(r,g,b,a)
        end
	end

	function addon:NotifyBorderChanged()
        borderBackdrop.edgeFile = SM:Fetch("border",pfl.Globals.Border)

		for _,frame in ipairs(reg) do 
			frame:SetBackdrop(borderBackdrop)
		end
		-- setting backdrop resets color
		addon:NotifyBorderColorChanged()
	end

	function addon:NotifyBorderEdgeSizeChanged()
		borderBackdrop.edgeSize = pfl.Globals.BorderEdgeSize
		for _,frame in ipairs(reg) do 
			frame:SetBackdrop(borderBackdrop)
		end
		-- setting backdrop resets color
		addon:NotifyBorderColorChanged()
	end

	function addon:NotifyBorderColorChanged()
		local r,g,b,a = unpack(pfl.Globals.BorderColor)
		for _,frame in ipairs(reg) do 
			frame:SetBackdropBorderColor(r,g,b,a)
		end
	end
end

do
	local reg = {}

	function addon:RegisterBackground(widget)
		reg[#reg+1] = widget
		local r,g,b,a = unpack(pfl.Globals.BackgroundColor)
		bgBackdrop.bgFile = SM:Fetch("background",pfl.Globals.BackgroundTexture)
		local inset = pfl.Globals.BackgroundInset
		bgBackdrop.insets.left = inset
		bgBackdrop.insets.right = inset
		bgBackdrop.insets.top = inset
		bgBackdrop.insets.bottom = inset
		if widget:IsObjectType("Frame") then
			widget:SetBackdrop(bgBackdrop)
			widget:SetBackdropColor(r,g,b,a)
		elseif widget:IsObjectType("Texture") then
			widget:SetTexture(bgBackdrop.bgFile) -- Odebere pozadí prázdného baru
			widget:SetVertexColor(r,g,b,a) -- Odebere obarvení prázdného baru
		end
	end


	function addon:NotifyBackgroundTextureChanged()
		bgBackdrop.bgFile = SM:Fetch("background",pfl.Globals.BackgroundTexture)
		for _,widget in ipairs(reg) do
			if widget:IsObjectType("Frame") then
				widget:SetBackdrop(bgBackdrop)
			elseif widget:IsObjectType("Texture") then
				widget:SetTexture(bgBackdrop.bgFile)
			end
		end
		-- setting backdrop resets color
		self:NotifyBackgroundColorChanged()
	end

	function addon:NotifyBackgroundInsetChanged()
		local inset = pfl.Globals.BackgroundInset
		bgBackdrop.insets.left = inset
		bgBackdrop.insets.right = inset
		bgBackdrop.insets.top = inset
		bgBackdrop.insets.bottom = inset
		for _,widget in ipairs(reg) do
			if widget:IsObjectType("Frame") then
				widget:SetBackdrop(bgBackdrop)
			--elseif widget:IsObjectType("Texture") then
			end
		end
		-- setting backdrop resets color
		self:NotifyBackgroundColorChanged()
	end

	function addon:NotifyBackgroundColorChanged()
		local r,g,b,a = unpack(pfl.Globals.BackgroundColor)
		for _,widget in ipairs(reg) do 
			if widget:IsObjectType("Frame") then
				widget:SetBackdropColor(r,g,b,a)
			elseif widget:IsObjectType("Texture") then
				widget:SetVertexColor(r,g,b,a)
			end
		end
	end
end
