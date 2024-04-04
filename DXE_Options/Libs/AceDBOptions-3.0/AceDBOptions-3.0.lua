--- AceDBOptions-3.0 provides a universal AceConfig options screen for managing AceDB-3.0 profiles.
-- @class file
-- @name AceDBOptions-3.0
-- @release $Id: AceDBOptions-3.0.lua 938 2010-06-13 07:21:38Z nevcairiel $
local ACEDBO_MAJOR, ACEDBO_MINOR = "AceDBOptions-3.0", 12
local AceDBOptions, oldminor = LibStub:NewLibrary(ACEDBO_MAJOR, ACEDBO_MINOR)

if not AceDBOptions then return end -- No upgrade needed

-- Lua APIs
local pairs, next = pairs, next

-- WoW APIs
local UnitClass = UnitClass

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: NORMAL_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE

AceDBOptions.optionTables = AceDBOptions.optionTables or {}
AceDBOptions.handlers = AceDBOptions.handlers or {}

--[[
	Localization of AceDBOptions-3.0
]]

local L = {
	default = "Default",
	intro = "You can change the active database profile, so you can have different settings for every character.",
	reset_desc = "Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over.",
	reset = "Reset Profile",
	reset_sub = "Reset the current profile to the default",
	choose_desc = "You can either create a new profile by entering a name in the editbox, or choose one of the already existing profiles.",
	new = "New",
	new_sub = "Create a new empty profile.",
	choose = "Existing Profiles",
	choose_sub = "Select one of your currently available profiles.",
	copy_desc = "Copy the settings from one existing profile into the currently active profile.",
	copy = "Copy From",
	delete_desc = "Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file.",
	delete = "Delete a Profile",
	delete_sub = "Deletes a profile from the database.",
	delete_confirm = "Are you sure you want to delete the selected profile?",
	profiles = "Profiles",
	profiles_sub = "Manage Profiles",
	current = "Current Profile:",
}

local LOCALE = GetLocale()
if LOCALE == "deDE" then
	L["default"] = "Standard"
	L["intro"] = "Hier kannst du das aktive Datenbankprofile \195\164ndern, damit du verschiedene Einstellungen f\195\188r jeden Charakter erstellen kannst, wodurch eine sehr flexible Konfiguration m\195\182glich wird." 
	L["reset_desc"] = "Setzt das momentane Profil auf Standardwerte zur\195\188ck, f\195\188r den Fall das mit der Konfiguration etwas schief lief oder weil du einfach neu starten willst."
	L["reset"] = "Profil zur\195\188cksetzen"
	L["reset_sub"] = "Das aktuelle Profil auf Standard zur\195\188cksetzen."
	L["choose_desc"] = "Du kannst ein neues Profil erstellen, indem du einen neuen Namen in der Eingabebox 'Neu' eingibst, oder w\195\164hle eines der vorhandenen Profile aus."
	L["new"] = "Neu"
	L["new_sub"] = "Ein neues Profil erstellen."
	L["choose"] = "Vorhandene Profile"
	L["choose_sub"] = "W\195\164hlt ein bereits vorhandenes Profil aus."
	L["copy_desc"] = "Kopiere die Einstellungen von einem vorhandenen Profil in das aktive Profil."
	L["copy"] = "Kopieren von..."
	L["delete_desc"] = "L\195\182sche vorhandene oder unbenutzte Profile aus der Datenbank um Platz zu sparen und um die SavedVariables Datei 'sauber' zu halten."
	L["delete"] = "Profil l\195\182schen"
	L["delete_sub"] = "L\195\182scht ein Profil aus der Datenbank."
	L["delete_confirm"] = "Willst du das ausgew\195\164hlte Profil wirklich l\195\182schen?"
	L["profiles"] = "Profile"
	L["profiles_sub"] = "Profile verwalten"
	--L["current"] = "Current Profile:"
elseif LOCALE == "frFR" then
	L["default"] = "D\195\169faut"
	L["intro"] = "Vous pouvez changer le profil actuel afin d'avoir des param\195\168tres diff\195\169rents pour chaque personnage, permettant ainsi d'avoir une configuration tr\195\168s flexible."
	L["reset_desc"] = "R\195\169initialise le profil actuel au cas o\195\185 votre configuration est corrompue ou si vous voulez tout simplement faire table rase."
	L["reset"] = "R\195\169initialiser le profil"
	L["reset_sub"] = "R\195\169initialise le profil actuel avec les param\195\168tres par d\195\169faut."
	L["choose_desc"] = "Vous pouvez cr\195\169er un nouveau profil en entrant un nouveau nom dans la bo\195\174te de saisie, ou en choississant un des profils d\195\169j\195\160 existants."
	L["new"] = "Nouveau"
	L["new_sub"] = "Cr\195\169\195\169e un nouveau profil vierge."
	L["choose"] = "Profils existants"
	L["choose_sub"] = "Permet de choisir un des profils d\195\169j\195\160 disponibles."
	L["copy_desc"] = "Copie les param\195\168tres d'un profil d\195\169j\195\160 existant dans le profil actuellement actif."
	L["copy"] = "Copier \195\160 partir de"
	L["delete_desc"] = "Supprime les profils existants inutilis\195\169s de la base de donn\195\169es afin de gagner de la place et de nettoyer le fichier SavedVariables."
	L["delete"] = "Supprimer un profil"
	L["delete_sub"] = "Supprime un profil de la base de donn\195\169es."
	L["delete_confirm"] = "Etes-vous s\195\187r de vouloir supprimer le profil s\195\169lectionn\195\169 ?"
	L["profiles"] = "Profils"
	L["profiles_sub"] = "Gestion des profils"
	--L["current"] = "Current Profile:"
elseif LOCALE == "koKR" then
	L["default"] = "기본값"
	L["intro"] = "모든 �?릭터�? 다양한 설정과 사용중인 데이터베이스 프로필, 어�?�?이�?지 매우 다루기 쉽게 바꿀�?? �?습�?다." 
	L["reset_desc"] = "단�?��? 다시 �??롭게 구성을 �?�?는 경우, �?�재 프로필을 기본값으로 �?기화 합�?다."
	L["reset"] = "프로필 �?기화"
	L["reset_sub"] = "�?�재�? 프로필을 기본값으로 �?기화 합�?다"
	L["choose_desc"] = "�??로운 이름을 입력�?거�?, 이미 �?는 프로필중 �?�?를 선�?��?여 �??로운 프로필을 만들 �?? �?습�?다."
	L["new"] = "�??로운 프로필"
	L["new_sub"] = "�??로운 프로필을 만듭�?다."
	L["choose"] = "프로필 선�?�"
	L["choose_sub"] = "당신이 �?�재 이용할�?? �?는 프로필을 선�?�합�?다."
	L["copy_desc"] = "�?�재 사용중인 프로필�?, 선�?�한 프로필�? 설정을 복사합�?다."
	L["copy"] = "복사"
	L["delete_desc"] = "데이터베이스�? 사용중이거�? 저장�?� 프로파일 삭제로 SavedVariables 파일�? 정리와 공간 �?약이 �?��?다."
	L["delete"] = "프로필 삭제"
	L["delete_sub"] = "데이터베이스�? 프로필을 삭제합�?다."
	L["delete_confirm"] = "정�?로 선�?�한 프로필�? 삭제를 �?�?십�?까?"
	L["profiles"] = "프로필"
	L["profiles_sub"] = "프로필 설정"
	--L["current"] = "Current Profile:"
elseif LOCALE == "esES" or LOCALE == "esMX" then
	L["default"] = "Por defecto"
	L["intro"] = "Puedes cambiar el perfil activo de tal manera que cada personaje tenga diferentes configuraciones."
	L["reset_desc"] = "Reinicia el perfil actual a los valores por defectos, en caso de que se haya estropeado la configuración o quieras volver a empezar de nuevo."
	L["reset"] = "Reiniciar Perfil"
	L["reset_sub"] = "Reinicar el perfil actual al de por defecto"
	L["choose_desc"] = "Puedes crear un nuevo perfil introduciendo un nombre en el recuadro o puedes seleccionar un perfil de los ya existentes."
	L["new"] = "Nuevo"
	L["new_sub"] = "Crear un nuevo perfil vacio."
	L["choose"] = "Perfiles existentes"
	L["choose_sub"] = "Selecciona uno de los perfiles disponibles."
	L["copy_desc"] = "Copia los ajustes de un perfil existente al perfil actual."
	L["copy"] = "Copiar de"
	L["delete_desc"] = "Borra los perfiles existentes y sin uso de la base de datos para ganar espacio y limpiar el archivo SavedVariables."
	L["delete"] = "Borrar un Perfil"
	L["delete_sub"] = "Borra un perfil de la base de datos."
	L["delete_confirm"] = "¿Estas seguro que quieres borrar el perfil seleccionado?"
	L["profiles"] = "Perfiles"
	L["profiles_sub"] = "Manejar Perfiles"
	--L["current"] = "Current Profile:"
elseif LOCALE == "zhTW" then
	L["default"] = "�?設"
	L["intro"] = "你可以�?�擇一個活動的資料設定檔，這樣你的每個角色就可以�?有不�?�的設定值，可以給你的插件設定帶來極大的�?活性。" 
	L["reset_desc"] = "將當前的設定檔�?�復�?��?的�?設值，用於你的設定檔�?�壞，�?�者你只�?��?�重來的�?��?。"
	L["reset"] = "重置設定檔"
	L["reset_sub"] = "將當前的設定檔�?�復為�?設值"
	L["choose_desc"] = "你可以通�?�在文本框內輸入一個�?�字創立一個新的設定檔，也可以�?�擇一個已經�?在的設定檔。"
	L["new"] = "新建"
	L["new_sub"] = "新建一個空的設定檔。"
	L["choose"] = "現有的設定檔"
	L["choose_sub"] = "從當前可用的設定檔裏面�?�擇一個。"
	L["copy_desc"] = "從當前�?個已保�?的設定檔複製�?�當前正使用的設定檔。"
	L["copy"] = "複製自"
	L["delete_desc"] = "從資料庫裏�?�除不再使用的設定檔，以節�?空間，並且清�?�SavedVariables檔。"
	L["delete"] = "�?�除一個設定檔"
	L["delete_sub"] = "從資料庫裏�?�除一個設定檔。"
	L["delete_confirm"] = "你確定�?�?�除所�?�擇的設定檔嗎？"
	L["profiles"] = "設定檔"
	L["profiles_sub"] = "管�?�設定檔"
	--L["current"] = "Current Profile:"
elseif LOCALE == "zhCN" then
	L["default"] = "�?认"
	L["intro"] = "你可以选择一个活动的数据配置文件，这样你的每个角色就可以拥有不�?�的设置值，可以给你的插件配置带来�?大的�?�活性。" 
	L["reset_desc"] = "将当前的配置文件�?�复�?��?的�?认值，用于你的配置文件损坏，�?�者你只�?��?�重来的�?�况。"
	L["reset"] = "重置配置文件"
	L["reset_sub"] = "将当前的配置文件�?�复为�?认值"
	L["choose_desc"] = "你可以通过在文本框内输入一个�?�字�?�立一个新的配置文件，也可以选择一个已经�?在的配置文件。"
	L["new"] = "新建"
	L["new_sub"] = "新建一个空的配置文件。"
	L["choose"] = "现有的配置文件"
	L["choose_sub"] = "从当前可用的配置文件里面选择一个。"
	L["copy_desc"] = "从当前�?个已保�?的配置文件复�?��?�当前正使用的配置文件。"
	L["copy"] = "复�?�自"
	L["delete_desc"] = "从数据库里�?�除不再使用的配置文件，以节�?空间，并且清�?�SavedVariables文件。"
	L["delete"] = "�?�除一个配置文件"
	L["delete_sub"] = "从数据库里�?�除一个配置文件。"
	L["delete_confirm"] = "你确定�?�?�除所选择的配置文件�?？"
	L["profiles"] = "配置文件"
	L["profiles_sub"] = "管�?�配置文件"
	--L["current"] = "Current Profile:"
elseif LOCALE == "ruRU" then
	L["default"] = "По �?молчанию"
	L["intro"] = "�?зменяя активный профиль, вы можете задать различные на�?тройки модификаций для каждого пер�?онажа."
	L["reset_desc"] = "Е�?ли ва�?а конфиг�?рации и�?порчена или е�?ли вы хотите на�?троить в�?ё заново - �?бро�?ьте тек�?щий профиль на �?тандартные значения."
	L["reset"] = "Сбро�? профиля"
	L["reset_sub"] = "Сбро�? тек�?щего профиля на �?тандартный"
	L["choose_desc"] = "Вы можете �?оздать новый профиль, введя название в поле ввода, или выбрать один из �?же �?�?ще�?тв�?ющих профилей."
	L["new"] = "Новый"
	L["new_sub"] = "Создать новый чи�?тый профиль"
	L["choose"] = "С�?ще�?тв�?ющие профили"
	L["choose_sub"] = "Выбор одиного из �?же до�?т�?пных профилей"
	L["copy_desc"] = "Скопировать на�?тройки из выбранного профиля в активный."
	L["copy"] = "Скопировать из"
	L["delete_desc"] = "Удалить �?�?ще�?тв�?ющий и неи�?польз�?емый профиль из БД для �?охранения ме�?та, и очи�?тить SavedVariables файл."
	L["delete"] = "Удалить профиль"
	L["delete_sub"] = "Удаление профиля из БД"
	L["delete_confirm"] = "Вы �?верены, что вы хотите �?далить выбранный профиль?"
	L["profiles"] = "Профили"
	L["profiles_sub"] = "Управление профилями"
	--L["current"] = "Current Profile:"
end

local defaultProfiles
local tmpprofiles = {}

-- Get a list of available profiles for the specified database.
-- You can specify which profiles to include/exclude in the list using the two boolean parameters listed below.
-- @param db The db object to retrieve the profiles from
-- @param common If true, getProfileList will add the default profiles to the return list, even if they have not been created yet
-- @param nocurrent If true, then getProfileList will not display the current profile in the list
-- @return Hashtable of all profiles with the internal name as keys and the display name as value.
local function getProfileList(db, common, nocurrent)
	local profiles = {}
	
	-- copy existing profiles into the table
	local currentProfile = db:GetCurrentProfile()
	for i,v in pairs(db:GetProfiles(tmpprofiles)) do 
		if not (nocurrent and v == currentProfile) then 
			profiles[v] = v 
		end 
	end
	
	-- add our default profiles to choose from ( or rename existing profiles)
	for k,v in pairs(defaultProfiles) do
		if (common or profiles[k]) and not (nocurrent and k == currentProfile) then
			profiles[k] = v
		end
	end
	
	return profiles
end

--[[
	OptionsHandlerPrototype
	prototype class for handling the options in a sane way
]]
local OptionsHandlerPrototype = {}

--[[ Reset the profile ]]
function OptionsHandlerPrototype:Reset()
	self.db:ResetProfile()
end

--[[ Set the profile to value ]]
function OptionsHandlerPrototype:SetProfile(info, value)
	self.db:SetProfile(value)
end

--[[ returns the currently active profile ]]
function OptionsHandlerPrototype:GetCurrentProfile()
	return self.db:GetCurrentProfile()
end

--[[ 
	List all active profiles
	you can control the output with the .arg variable
	currently four modes are supported
	
	(empty) - return all available profiles
	"nocurrent" - returns all available profiles except the currently active profile
	"common" - returns all avaialble profiles + some commonly used profiles ("char - realm", "realm", "class", "Default")
	"both" - common except the active profile
]]
function OptionsHandlerPrototype:ListProfiles(info)
	local arg = info.arg
	local profiles
	if arg == "common" and not self.noDefaultProfiles then
		profiles = getProfileList(self.db, true, nil)
	elseif arg == "nocurrent" then
		profiles = getProfileList(self.db, nil, true)
	elseif arg == "both" then -- currently not used
		profiles = getProfileList(self.db, (not self.noDefaultProfiles) and true, true)
	else
		profiles = getProfileList(self.db)
	end
	
	return profiles
end

function OptionsHandlerPrototype:HasNoProfiles(info)
	local profiles = self:ListProfiles(info)
	return ((not next(profiles)) and true or false)
end

--[[ Copy a profile ]]
function OptionsHandlerPrototype:CopyProfile(info, value)
	self.db:CopyProfile(value)
end

--[[ Delete a profile from the db ]]
function OptionsHandlerPrototype:DeleteProfile(info, value)
	self.db:DeleteProfile(value)
end

--[[ fill defaultProfiles with some generic values ]]
local function generateDefaultProfiles(db)
	defaultProfiles = {
		["Default"] = L["default"],
		[db.keys.char] = db.keys.char,
		[db.keys.realm] = db.keys.realm,
		[db.keys.class] = UnitClass("player")
	}
end

--[[ create and return a handler object for the db, or upgrade it if it already existed ]]
local function getOptionsHandler(db, noDefaultProfiles)
	if not defaultProfiles then
		generateDefaultProfiles(db)
	end
	
	local handler = AceDBOptions.handlers[db] or { db = db, noDefaultProfiles = noDefaultProfiles }
	
	for k,v in pairs(OptionsHandlerPrototype) do
		handler[k] = v
	end
	
	AceDBOptions.handlers[db] = handler
	return handler
end

--[[
	the real options table 
]]
local optionsTable = {
	desc = {
		order = 1,
		type = "description",
		name = L["intro"] .. "\n",
	},
	descreset = {
		order = 9,
		type = "description",
		name = L["reset_desc"],
	},
	reset = {
		order = 10,
		type = "execute",
		name = L["reset"],
		desc = L["reset_sub"],
		func = "Reset",
	},
	current = {
		order = 11,
		type = "description",
		name = function(info) return L["current"] .. " " .. NORMAL_FONT_COLOR_CODE .. info.handler:GetCurrentProfile() .. FONT_COLOR_CODE_CLOSE end,
		width = "default",
	},
	choosedesc = {
		order = 20,
		type = "description",
		name = "\n" .. L["choose_desc"],
	},
	new = {
		name = L["new"],
		desc = L["new_sub"],
		type = "input",
		order = 30,
		get = false,
		set = "SetProfile",
	},
	choose = {
		name = L["choose"],
		desc = L["choose_sub"],
		type = "select",
		order = 40,
		get = "GetCurrentProfile",
		set = "SetProfile",
		values = "ListProfiles",
		arg = "common",
	},
	copydesc = {
		order = 50,
		type = "description",
		name = "\n" .. L["copy_desc"],
	},
	copyfrom = {
		order = 60,
		type = "select",
		name = L["copy"],
		desc = L["copy_desc"],
		get = false,
		set = "CopyProfile",
		values = "ListProfiles",
		disabled = "HasNoProfiles",
		arg = "nocurrent",
	},
	deldesc = {
		order = 70,
		type = "description",
		name = "\n" .. L["delete_desc"],
	},
	delete = {
		order = 80,
		type = "select",
		name = L["delete"],
		desc = L["delete_sub"],
		get = false,
		set = "DeleteProfile",
		values = "ListProfiles",
		disabled = "HasNoProfiles",
		arg = "nocurrent",
		confirm = true,
		confirmText = L["delete_confirm"],
	},
}

--- Get/Create a option table that you can use in your addon to control the profiles of AceDB-3.0.
-- @param db The database object to create the options table for.
-- @return The options table to be used in AceConfig-3.0
-- @usage 
-- -- Assuming `options` is your top-level options table and `self.db` is your database:
-- options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
function AceDBOptions:GetOptionsTable(db, noDefaultProfiles)
	local tbl = AceDBOptions.optionTables[db] or {
			type = "group",
			name = L["profiles"],
			desc = L["profiles_sub"],
		}
	
	tbl.handler = getOptionsHandler(db, noDefaultProfiles)
	tbl.args = optionsTable

	AceDBOptions.optionTables[db] = tbl
	return tbl
end

-- upgrade existing tables
for db,tbl in pairs(AceDBOptions.optionTables) do
	tbl.handler = getOptionsHandler(db)
	tbl.args = optionsTable
end
