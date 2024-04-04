--[[
	The contents of this file are auto-generated using the WoWAce localization application
	Please go to http://www.wowace.com/projects/deus-vox-encounters/localization/ to update translations.
	Anyone with a wowace/curseforge account can edit them. 
]] 

local AL = LibStub("AceLocale-3.0")

local silent = true

local L = AL:GetLocale("DXE")
if not L then
    local L = AL:NewLocale("DXE", "enUS", true, silent)
end

if L then

-- Chat triggers
local chat_bastion = AL:NewLocale("DXE Chat Bastion", "enUS", true, silent)
AL:GetLocale("DXE").chat_bastion = AL:GetLocale("DXE Chat Bastion")
-- NPC names
local npc_bastion = AL:NewLocale("DXE NPC Bastion", "enUS", true, silent)
AL:GetLocale("DXE").npc_bastion = AL:GetLocale("DXE NPC Bastion")
if GetLocale() == "enUS" or GetLocale() == "enGB" then return end
end

local L = AL:NewLocale("DXE", "deDE")
if L then

-- Chat triggers
local chat_bastion = AL:NewLocale("DXE Chat Bastion", "deDE")
-- chat_bastion["^Enough of this foolishness"] = ""
chat_bastion["^Enough!"] = "^Genug!"
chat_bastion["^Feed, children"] = "^Fresst, Kinder"
chat_bastion["^You dare invade"] = "^Ihr dringt in das"
-- chat_bastion["^You mistake this for weakness?"] = ""

AL:GetLocale("DXE").chat_bastion = AL:GetLocale("DXE Chat Bastion")
-- NPC names
local npc_bastion = AL:NewLocale("DXE NPC Bastion", "deDE")
npc_bastion["Arion"] = "Arion"
npc_bastion["Cho'gall"] = "Cho'gall"
npc_bastion["Halfus Wyrmbreaker"] = "Halfus Wyrmbrecher"
npc_bastion["Lady Sinestra"] = "Lady Sinestra"
npc_bastion["The Ascendant Council"] = "Rat der Aszendenten"
npc_bastion["Valiona & Theralion"] = "Valiona & Theralion"

AL:GetLocale("DXE").npc_bastion = AL:GetLocale("DXE NPC Bastion")
return
end

local L = AL:NewLocale("DXE", "esES")
if L then

-- Chat triggers
local chat_bastion = AL:NewLocale("DXE Chat Bastion", "esES")
chat_bastion["^Enough of this foolishness"] = "^¡Basta de tonterías!"
chat_bastion["^Enough!"] = "^¡Basta!"
chat_bastion["^Feed, children"] = "^¡Comed, hijos!"
chat_bastion["^You dare invade"] = "^¿Os atrevéis a invadir"
chat_bastion["^You mistake this for weakness?"] = "^¿Confundes esto con debilidad?"

AL:GetLocale("DXE").chat_bastion = AL:GetLocale("DXE Chat Bastion")
-- NPC names
local npc_bastion = AL:NewLocale("DXE NPC Bastion", "esES")
npc_bastion["Arion"] = "Arion"
npc_bastion["Cho'gall"] = "Cho'gall"
npc_bastion["Halfus Wyrmbreaker"] = "Halfus Rompevermis"
npc_bastion["Lady Sinestra"] = "Lady Sinestra"
npc_bastion["The Ascendant Council"] = "Consejo de ascendientes"
npc_bastion["Valiona & Theralion"] = "Valiona & Theralion"

AL:GetLocale("DXE").npc_bastion = AL:GetLocale("DXE NPC Bastion")
return
end

local L = AL:NewLocale("DXE", "esMX")
if L then

-- Chat triggers
local chat_bastion = AL:NewLocale("DXE Chat Bastion", "esMX")
-- chat_bastion["^Enough of this foolishness"] = ""
-- chat_bastion["^Enough!"] = ""
-- chat_bastion["^Feed, children"] = ""
-- chat_bastion["^You dare invade"] = ""
-- chat_bastion["^You mistake this for weakness?"] = ""

AL:GetLocale("DXE").chat_bastion = AL:GetLocale("DXE Chat Bastion")
-- NPC names
local npc_bastion = AL:NewLocale("DXE NPC Bastion", "esMX")
-- npc_bastion["Arion"] = ""
-- npc_bastion["Cho'gall"] = ""
-- npc_bastion["Halfus Wyrmbreaker"] = ""
-- npc_bastion["Lady Sinestra"] = ""
-- npc_bastion["The Ascendant Council"] = ""
-- npc_bastion["Valiona & Theralion"] = ""

AL:GetLocale("DXE").npc_bastion = AL:GetLocale("DXE NPC Bastion")
return
end

local L = AL:NewLocale("DXE", "frFR")
if L then
	
-- Chat triggers
local chat_bastion = AL:NewLocale("DXE Chat Bastion", "frFR")
chat_bastion["^Enough of this foolishness"] = "^Que cessent ces stupidités"
chat_bastion["^Enough!"] = "^Assez !"
chat_bastion["^Feed, children"] = "^Mangez, mes enfants !"
chat_bastion["^You dare invade"] = "^Vous osez envahir"
chat_bastion["^You mistake this for weakness?"] = "^Vous avez cru à une marque de faiblesse ?"

AL:GetLocale("DXE").chat_bastion = AL:GetLocale("DXE Chat Bastion")
-- NPC names
local npc_bastion = AL:NewLocale("DXE NPC Bastion", "frFR")
npc_bastion["Arion"] = "Arion"
npc_bastion["Cho'gall"] = "Cho'gall"
npc_bastion["Halfus Wyrmbreaker"] = "Halfus Brise-wyrm"
npc_bastion["Lady Sinestra"] = "Dame Sinestra"
npc_bastion["The Ascendant Council"] = "Conseil d'ascendants"
npc_bastion["Valiona & Theralion"] = "Valiona & Theralion"

AL:GetLocale("DXE").npc_bastion = AL:GetLocale("DXE NPC Bastion")
return
end

local L = AL:NewLocale("DXE", "koKR")
if L then

-- Chat triggers
local chat_bastion = AL:NewLocale("DXE Chat Bastion", "koKR")
chat_bastion["^Enough of this foolishness"] = "^우리가 �??대�?겠다"
chat_bastion["^Enough!"] = "^그만!"
chat_bastion["^Feed, children"] = "^�?들아, 먹어�?워라"
chat_bastion["^You dare invade"] = "^성소를 침범해"
chat_bastion["^You mistake this for weakness?"] = "^이게 약해지는 걸로 보이�?�???"

AL:GetLocale("DXE").chat_bastion = AL:GetLocale("DXE Chat Bastion")
-- NPC names
local npc_bastion = AL:NewLocale("DXE NPC Bastion", "koKR")
npc_bastion["Arion"] = "아리�?�"
npc_bastion["Cho'gall"] = "�?�?"
npc_bastion["Halfus Wyrmbreaker"] = "할푸스 웜브�?이커"
npc_bastion["Lady Sinestra"] = "시네스트라"
npc_bastion["The Ascendant Council"] = "승천 �?회"
npc_bastion["Valiona & Theralion"] = "발리�?��?와 테랄리�?�"

AL:GetLocale("DXE").npc_bastion = AL:GetLocale("DXE NPC Bastion")
return
end

local L = AL:NewLocale("DXE", "ruRU")
if L then

-- Chat triggers
local chat_bastion = AL:NewLocale("DXE Chat Bastion", "ruRU")
chat_bastion["^Enough of this foolishness"] = "^Закончим этот фар�?"
chat_bastion["^Enough!"] = "^Довольно!"
chat_bastion["^Feed, children"] = "^Е�?ьте, дети мои "
chat_bastion["^You dare invade"] = "^Вы заплатите жизнями"
chat_bastion["^You mistake this for weakness?"] = "^Ты так в этом �?верен?"

AL:GetLocale("DXE").chat_bastion = AL:GetLocale("DXE Chat Bastion")
-- NPC names
local npc_bastion = AL:NewLocale("DXE NPC Bastion", "ruRU")
npc_bastion["Arion"] = "�?эрон"
npc_bastion["Cho'gall"] = "Чо'Галл"
npc_bastion["Halfus Wyrmbreaker"] = "Халфий Змеерез"
npc_bastion["Lady Sinestra"] = "Сине�?тра"
npc_bastion["The Ascendant Council"] = "Совет Перерожденных"
npc_bastion["Valiona & Theralion"] = "Валиона и Тералион"

AL:GetLocale("DXE").npc_bastion = AL:GetLocale("DXE NPC Bastion")
return
end

local L = AL:NewLocale("DXE", "zhCN")
if L then

-- Chat triggers
local chat_bastion = AL:NewLocale("DXE Chat Bastion", "zhCN")
chat_bastion["^Enough of this foolishness"] = "^�?�止你的愚行"
chat_bastion["^Enough!"] = "^够了"
chat_bastion["^Feed, children"] = "^�??�?�，孩�?们�?尽�?�享用他们肥美的躯壳�?��?"
chat_bastion["^You dare invade"] = "^你们竟敢"
chat_bastion["^You mistake this for weakness?"] = "^你以为就这�?简单"

AL:GetLocale("DXE").chat_bastion = AL:GetLocale("DXE Chat Bastion")
-- NPC names
local npc_bastion = AL:NewLocale("DXE NPC Bastion", "zhCN")
npc_bastion["Arion"] = "艾里�?�"
npc_bastion["Cho'gall"] = "古加尔"
npc_bastion["Halfus Wyrmbreaker"] = "�?尔弗斯·碎龙者"
npc_bastion["Lady Sinestra"] = "希�?丝特拉"
npc_bastion["The Ascendant Council"] = "升腾者议会"
npc_bastion["Valiona & Theralion"] = "瓦里�?�娜和瑟纳�?��?�"

AL:GetLocale("DXE").npc_bastion = AL:GetLocale("DXE NPC Bastion")
return
end

local L = AL:NewLocale("DXE", "zhTW")
if L then

-- Chat triggers
local chat_bastion = AL:NewLocale("DXE Chat Bastion", "zhTW")
chat_bastion["^Enough of this foolishness"] = "^�?�們�?解決他們!"
-- chat_bastion["^Enough!"] = ""
-- chat_bastion["^Feed, children"] = ""
-- chat_bastion["^You dare invade"] = ""
-- chat_bastion["^You mistake this for weakness?"] = ""

AL:GetLocale("DXE").chat_bastion = AL:GetLocale("DXE Chat Bastion")
-- NPC names
local npc_bastion = AL:NewLocale("DXE NPC Bastion", "zhTW")
npc_bastion["Arion"] = "艾�?�奧"
npc_bastion["Cho'gall"] = "�?加�?�"
npc_bastion["Halfus Wyrmbreaker"] = "�?福斯•破龍者"
npc_bastion["Lady Sinestra"] = "賽絲特拉女士"
npc_bastion["The Ascendant Council"] = "卓越者議�?"
npc_bastion["Valiona & Theralion"] = "瓦莉�?娜和瑟拉里�?�"

AL:GetLocale("DXE").npc_bastion = AL:GetLocale("DXE NPC Bastion")
return
end
