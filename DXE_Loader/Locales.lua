--[[
	The contents of this file are auto-generated using the WoWAce localization application
	Please go to http://www.wowace.com/projects/deus-vox-encounters/localization/ to update translations.
	Anyone with a wowace/curseforge account can edit them. 
]] 

local AL = LibStub("AceLocale-3.0")

local silent = true

L = AL:NewLocale("DXE", "enUS", true, silent)

if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "enUS", true, silent)
AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "enUS", true, silent)
AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

if GetLocale() == "enUS" or GetLocale() == "enGB" then return end
end

local L = AL:NewLocale("DXE", "deDE")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "deDE")
zone["Baradin"] = "Baradin"
zone["Baradin Hold"] = "Baradinfestung"
zone["Bastion"] = "Bastion"
zone["Blackwing Descent"] = "Pechschwingenabstieg"
zone["Descent"] = "Abstieg"
-- zone["Dragon Soul"] = ""
zone["Firelands"] = "Feuerlande"
zone["The Bastion of Twilight"] = "Die Bastion des Zwielichts"
-- zone["The Dragon Wastes"] = ""
zone["Throne"] = "Thron"
zone["Throne of the Four Winds"] = "Thron der Vier Winde"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "deDE")
loader["Deus Vox Encounters"] = "Deus Vox Encounters"
loader["|cffffff00Click|r to load"] = " |cffffff00Klicken|r, zum Laden"
loader["|cffffff00Click|r to toggle the settings window"] = "|cffffff00Klicken|r, um das Einstellungsfenster anzuzeigen"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "esES")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "esES")
zone["Baradin"] = "Baradin"
zone["Baradin Hold"] = "Bastión de Baradin"
zone["Bastion"] = "Bastión"
zone["Blackwing Descent"] = "Descenso de Alanegra"
zone["Descent"] = "Descenso"
zone["Dragon Soul"] = "Alma de Dragón"
zone["Firelands"] = "Tierras de Fuego"
zone["The Bastion of Twilight"] = "El Bastión del Crepúsculo"
-- zone["The Dragon Wastes"] = ""
zone["Throne"] = "Trono"
zone["Throne of the Four Winds"] = "Trono de los Cuatro Vientos"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "esES")
loader["Deus Vox Encounters"] = "Deus Vox Encounters"
loader["|cffffff00Click|r to load"] = "|cffffff00Click|r para cargar"
loader["|cffffff00Click|r to toggle the settings window"] = "|cffffff00Click|r para mostrar la ventana de opciones"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "esMX")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "esMX")
-- zone["Baradin"] = ""
-- zone["Baradin Hold"] = ""
-- zone["Bastion"] = ""
-- zone["Blackwing Descent"] = ""
-- zone["Descent"] = ""
-- zone["Dragon Soul"] = ""
-- zone["Firelands"] = ""
-- zone["The Bastion of Twilight"] = ""
-- zone["The Dragon Wastes"] = ""
-- zone["Throne"] = ""
-- zone["Throne of the Four Winds"] = ""

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "esMX")
-- loader["Deus Vox Encounters"] = ""
-- loader["|cffffff00Click|r to load"] = ""
-- loader["|cffffff00Click|r to toggle the settings window"] = ""

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "frFR")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "frFR")
zone["Baradin"] = "Baradin"
zone["Baradin Hold"] = "Bastion de Baradin"
zone["Bastion"] = "Bastion"
zone["Blackwing Descent"] = "Descente de l'Aile noire"
zone["Descent"] = "Descente"
zone["Dragon Soul"] = "L'Âme des dragons" -- Needs review
zone["Firelands"] = "Terres de Feu"
zone["The Bastion of Twilight"] = "Le bastion du Crépuscule"
zone["The Dragon Wastes"] = "Le désert des Dragons" -- Needs review
zone["Throne"] = "Trône"
zone["Throne of the Four Winds"] = "Trône des quatre vents"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "frFR")
loader["Deus Vox Encounters"] = "Deus Vox Encounters"
loader["|cffffff00Click|r to load"] = "|cffffff00Clic gauche|r pour charger."
loader["|cffffff00Click|r to toggle the settings window"] = "|cffffff00Clic gauche|r pour afficher/cacher la fenêtre des paramètres."

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "koKR")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "koKR")
zone["Baradin"] = "바라�?"
zone["Baradin Hold"] = "바라�? 요�??"
zone["Bastion"] = "요�??"
zone["Blackwing Descent"] = "검은날개 강림지"
zone["Descent"] = "강림지"
-- zone["Dragon Soul"] = ""
zone["Firelands"] = "�?�? 땅"
zone["The Bastion of Twilight"] = "황�?��? 요�??"
-- zone["The Dragon Wastes"] = ""
zone["Throne"] = "왕좌"
zone["Throne of the Four Winds"] = "네 바람�? 왕좌"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "koKR")
loader["Deus Vox Encounters"] = "Deus Vox Encounters"
loader["|cffffff00Click|r to load"] = "�?러 �?�려면 |cffffff00�?�릭|r "
loader["|cffffff00Click|r to toggle the settings window"] = "설정 창을 열거�? 닫으려면 |cffffff00�?�릭|r "

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "ruRU")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "ruRU")
zone["Baradin"] = "Барадин"
zone["Baradin Hold"] = "Крепо�?ть Барадин"
zone["Bastion"] = "Ба�?тион"
zone["Blackwing Descent"] = "Твердыня Крыла Тьмы"
zone["Descent"] = "Твердыня"
zone["Dragon Soul"] = "Д�?�?а Дракона"
zone["Firelands"] = "Огненные Про�?торы"
zone["The Bastion of Twilight"] = "С�?меречный ба�?тион"
zone["The Dragon Wastes"] = "Драконьи п�?�?то�?и"
zone["Throne"] = "Трон"
zone["Throne of the Four Winds"] = "Трон Четырех Ветров"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "ruRU")
loader["Deus Vox Encounters"] = "Deus Vox Encounters"
loader["|cffffff00Click|r to load"] = " |cffffff00Кликните|r для загр�?зки"
loader["|cffffff00Click|r to toggle the settings window"] = " |cffffff00Кликните|r для показа окна на�?троек"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "zhCN")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "zhCN")
zone["Baradin"] = "巴拉�?海湾"
zone["Baradin Hold"] = "巴拉�?监狱"
zone["Bastion"] = "暮光堡垒"
zone["Blackwing Descent"] = "黑翼血环"
zone["Descent"] = "黑翼血环"
zone["Dragon Soul"] = "巨龙之魂"
zone["Firelands"] = "�?�焰之地"
zone["The Bastion of Twilight"] = "暮光堡垒"
-- zone["The Dragon Wastes"] = ""
zone["Throne"] = "风神王座"
zone["Throne of the Four Winds"] = "风神王座"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "zhCN")
loader["Deus Vox Encounters"] = "Deus Vox �??斗警报"
loader["|cffffff00Click|r to load"] = "|cffffff00点击|r加载"
loader["|cffffff00Click|r to toggle the settings window"] = "|cffffff00点击|r�?�换设置窗口"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "zhTW")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "zhTW")
zone["Baradin"] = "巴拉�?"
zone["Baradin Hold"] = "巴拉�?堡"
zone["Bastion"] = "暮光堡�?"
zone["Blackwing Descent"] = "黑翼陷窟"
zone["Descent"] = "黑翼陷窟"
-- zone["Dragon Soul"] = ""
zone["Firelands"] = "�?��?之界"
zone["The Bastion of Twilight"] = "暮光堡�?"
-- zone["The Dragon Wastes"] = ""
zone["Throne"] = "四風王座"
zone["Throne of the Four Winds"] = "四風王座"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "zhTW")
loader["Deus Vox Encounters"] = "Deus Vox 首�?�?�鬥"
loader["|cffffff00Click|r to load"] = "|cffffff00點擊|r加載"
loader["|cffffff00Click|r to toggle the settings window"] = "|cffffff00點擊|r打開設定視窗"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end
