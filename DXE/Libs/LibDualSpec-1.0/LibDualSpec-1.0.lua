--[[
LibDualSpec-1.0 - Adds dual spec support to individual AceDB-3.0 databases
Copyright (C) 2009-2011 Adirelle

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Redistribution of a stand alone version is strictly prohibited without
      prior written authorization from the LibDualSpec project manager.
    * Neither the name of the LibDualSpec authors nor the names of its contributors
      may be used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

local MAJOR, MINOR = "LibDualSpec-1.0", 8
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

-- ----------------------------------------------------------------------------
-- Library data
-- ----------------------------------------------------------------------------

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")

lib.registry = lib.registry or {}
lib.options = lib.options or {}
lib.mixin = lib.mixin or {}

-- ----------------------------------------------------------------------------
-- Locals
-- ----------------------------------------------------------------------------

local registry = lib.registry
local options = lib.options
local mixin = lib.mixin

-- "Externals"
local AceDB3 = LibStub('AceDB-3.0', true)
local AceDBOptions3 = LibStub('AceDBOptions-3.0', true)

-- ----------------------------------------------------------------------------
-- Localization
-- ----------------------------------------------------------------------------

local L_DUALSPEC_DESC, L_ENABLED, L_ENABLED_DESC, L_DUAL_PROFILE, L_DUAL_PROFILE_DESC

do
	L_DUALSPEC_DESC = "When enabled, this feature allow you to select a different "..
			"profile for each talent spec. The dual profile will be swapped with the "..
			"current profile each time you switch from a talent spec to the other."
	L_ENABLED = 'Enable dual profile'
	L_ENABLED_DESC = 'Check this box to automatically swap profiles on talent switch.'
	L_DUAL_PROFILE = 'Dual profile'
	L_DUAL_PROFILE_DESC = 'Select the profile to swap with on talent switch.'

	local locale = GetLocale()
	if locale == "frFR" then
		L_DUALSPEC_DESC = "Lorsqu'elle est activée, cette fonctionnalité vous permet de choisir un profil différent pour chaque spécialisation de talents.  Le second profil sera échangé avec le profil courant chaque fois que vous passerez d'une spécialisation à l'autre."
		L_DUAL_PROFILE = "Second profil"
		L_DUAL_PROFILE_DESC = "Sélectionnez le profil à échanger avec le profil courant lors du changement de spécialisation."
		L_ENABLED = "Activez le second profil"
		L_ENABLED_DESC = "Cochez cette case pour échanger automatiquement les profils lors d'un changement de spécialisation."
	elseif locale == "deDE" then
		L_DUALSPEC_DESC = "Wenn aktiv, wechselt dieses Feature bei jedem Wechsel der dualen Talentspezialisierung das Profil. Das duale Profil wird beim Wechsel automatisch mit dem derzeit aktiven Profil getauscht."
		L_DUAL_PROFILE = "Duales Profil"
		L_DUAL_PROFILE_DESC = "Wähle das Profil, das beim Wechsel der Talente aktiviert wird."
		L_ENABLED = "Aktiviere Duale Profile"
		L_ENABLED_DESC = "Aktiviere diese Option, um beim Talentwechsel automatisch zwischen den Profilen zu wechseln."
	elseif locale == "koKR" then
		L_DUALSPEC_DESC = "가능�?면 사용합�?다. 이중 특성�? �?�?여 다른 프로필을 선�?�할 �?? �?게 �?�?다. 이중 프로필은 �?�재 프로필과 �?�?아서 특성이 변경�?� 때 같이 �?용�?��?다."
		L_DUAL_PROFILE = "이중 프로필"
		L_DUAL_PROFILE_DESC = "특성이 바뀔 때 프로필을 선�?�합�?다."
		L_ENABLED = "이중 프로필 사용"
		L_ENABLED_DESC = "특성이 변경 �?�때 �?동으로 프로필을 변경�?도록 선�?�합�?다."
	elseif locale == "ruRU" then
		L_DUALSPEC_DESC = "Двойной профиль позволяет вам выбрать различные профили для каждой ра�?кладки талантов. Профили б�?д�?т переключать�?я каждый раз, когда вы переключаете ра�?кладк�? талантов."
		L_DUAL_PROFILE = "Второй профиль"
		L_DUAL_PROFILE_DESC = "Выберите профиль, который необходимо активировать при переключениии талантов."
		L_ENABLED = "Включить двойной профиль"
		L_ENABLED_DESC = "Включите эт�? опцию для автоматиче�?кого переключения межд�? профилями при переключении ра�?кладки талантов."
	elseif locale == "zhCN" then
		L_DUALSPEC_DESC = "�?�时，你可以为你的双天赋设定另一组配置文件，你的双重配置文件将在你转换天赋时自动与目前使用配置文件交换。"
		L_DUAL_PROFILE = "双重配置文件"
		L_DUAL_PROFILE_DESC = "选择转换天赋时所�?使用的配置文件"
		L_ENABLED = "开�?�双重配置文件"
		L_ENABLED_DESC = "勾选以便转换天赋时自动交换配置文件。"
	elseif locale == "zhTW" then
		L_DUALSPEC_DESC = "啟用時，你可以為你的雙天賦設定另一組設定檔。你的雙設定檔將在你轉換天賦時自動�?�目前使用設定檔交換。"
		L_DUAL_PROFILE = "雙設定檔"
		L_DUAL_PROFILE_DESC = "�?�擇轉換天賦後所�?使用的設定檔"
		L_ENABLED = "啟用雙設定檔"
		L_ENABLED_DESC = "勾�?�以在轉換天賦時自動交換設定檔"
	elseif locale == "esES" then
		L_DUALSPEC_DESC = "Si está activa, esta característica te permite seleccionar un perfil distinto para cada configuración de talentos. El perfil secundario será intercambiado por el activo cada vez que cambies de una configuración de talentos a otra."
		L_DUAL_PROFILE = "Perfil secundario"
		L_DUAL_PROFILE_DESC = "Elige el perfil secundario que se usará cuando cambies de talentos."
		L_ENABLED = "Activar perfil secundario"
		L_ENABLED_DESC = "Activa esta casilla para alternar automáticamente entre prefiles cuando cambies de talentos."
	end
end

-- ----------------------------------------------------------------------------
-- Mixin
-- ----------------------------------------------------------------------------

--- Get dual spec feature status.
-- @return (boolean) true is dual spec feature enabled.
-- @name enhancedDB:IsDualSpecEnabled
function mixin:IsDualSpecEnabled()
	return registry[self].db.char.enabled
end

--- Enable/disabled dual spec feature.
-- @param enabled (boolean) true to enable dual spec feature, false to disable it.
-- @name enhancedDB:SetDualSpecEnabled
function mixin:SetDualSpecEnabled(enabled)
	local db = registry[self].db
	if enabled and not db.char.talentGroup then
		db.char.talentGroup = lib.talentGroup
		db.char.profile = self:GetCurrentProfile()
		db.char.enabled = true
	else
		db.char.enabled = enabled
		self:CheckDualSpecState()
	end
end

--- Get the alternate profile name.
-- Defaults to the current profile.
-- @return (string) Alternate profile name.
-- @name enhancedDB:GetDualSpecProfile
function mixin:GetDualSpecProfile()
	return registry[self].db.char.profile or self:GetCurrentProfile()
end

--- Set the alternate profile name.
-- No validation are done to ensure the profile is valid.
-- @param profileName (string) the profile name to use.
-- @name enhancedDB:SetDualSpecProfile
function mixin:SetDualSpecProfile(profileName)
	registry[self].db.char.profile = profileName
end

--- Check if a profile swap should occur.
-- Do nothing if the dual spec feature is disabled. In the other
-- case, if the internally stored talent spec is different from the
-- actual active talent spec, the database swaps to the alternate profile.
-- There is normally no reason to call this method directly as LibDualSpec
-- takes care of calling it at appropriate times.
-- @name enhancedDB:CheckDualSpecState
function mixin:CheckDualSpecState()
	local db = registry[self].db
	if lib.talentsLoaded and db.char.enabled and db.char.talentGroup ~= lib.talentGroup then
		local currentProfile = self:GetCurrentProfile()
		local newProfile = db.char.profile
		db.char.talentGroup = lib.talentGroup
		if newProfile ~= currentProfile then
			self:SetProfile(newProfile)
			db.char.profile = currentProfile
		end
	end
end

-- ----------------------------------------------------------------------------
-- AceDB-3.0 support
-- ----------------------------------------------------------------------------

local function EmbedMixin(target)
	for k,v in pairs(mixin) do
		rawset(target, k, v)
	end
end

-- Upgrade existing mixins
for target in pairs(registry) do
	EmbedMixin(target)
end

-- Actually enhance the database
-- This is used on first initialization and everytime the database is reset using :ResetDB
function lib:_EnhanceDatabase(event, target)
	registry[target].db = target:GetNamespace(MAJOR, true) or target:RegisterNamespace(MAJOR)
	EmbedMixin(target)
	target:CheckDualSpecState()
end

--- Embed dual spec feature into an existing AceDB-3.0 database.
-- LibDualSpec specific methods are added to the instance.
-- @name LibDualSpec:EnhanceDatabase
-- @param target (table) the AceDB-3.0 instance.
-- @param name (string) a user-friendly name of the database (best bet is the addon name).
function lib:EnhanceDatabase(target, name)
	AceDB3 = AceDB3 or LibStub('AceDB-3.0', true)
	if type(target) ~= "table" then
		error("Usage: LibDualSpec:EnhanceDatabase(target, name): target should be a table.", 2)
	elseif type(name) ~= "string" then
		error("Usage: LibDualSpec:EnhanceDatabase(target, name): name should be a string.", 2)
	elseif not AceDB3 or not AceDB3.db_registry[target] then
		error("Usage: LibDualSpec:EnhanceDatabase(target, name): target should be an AceDB-3.0 database.", 2)
	elseif target.parent then
		error("Usage: LibDualSpec:EnhanceDatabase(target, name): cannot enhance a namespace.", 2)
	elseif registry[target] then
		return
	end
	registry[target] = { name = name }
	lib:_EnhanceDatabase("EnhanceDatabase", target)
	target.RegisterCallback(lib, "OnDatabaseReset", "_EnhanceDatabase")
end

-- ----------------------------------------------------------------------------
-- AceDBOptions-3.0 support
-- ----------------------------------------------------------------------------

local function NoDualSpec()
	return GetNumTalentGroups() == 1
end

options.dualSpecDesc = {
	name = L_DUALSPEC_DESC,
	type = 'description',
	order = 40.1,
	hidden = NoDualSpec,
}

options.enabled = {
	name = L_ENABLED,
	desc = L_ENABLED_DESC,
	type = 'toggle',
	order = 40.2,
	get = function(info) return info.handler.db:IsDualSpecEnabled() end,
	set = function(info, value) info.handler.db:SetDualSpecEnabled(value) end,
	hidden = NoDualSpec,
}

options.dualProfile = {
	name = L_DUAL_PROFILE,
	desc = L_DUAL_PROFILE_DESC,
	type = 'select',
	order = 40.3,
	get = function(info) return info.handler.db:GetDualSpecProfile() end,
	set = function(info, value) info.handler.db:SetDualSpecProfile(value) end,
	values = "ListProfiles",
	arg = "common",
	hidden = NoDualSpec,
	disabled = function(info) return not info.handler.db:IsDualSpecEnabled() end,
}

--- Embed dual spec options into an existing AceDBOptions-3.0 option table.
-- @name LibDualSpec:EnhanceOptions
-- @param optionTable (table) The option table returned by AceDBOptions-3.0.
-- @param target (table) The AceDB-3.0 the options operate on.
function lib:EnhanceOptions(optionTable, target)
	AceDBOptions3 = AceDBOptions3 or LibStub('AceDBOptions-3.0', true)
	if type(optionTable) ~= "table" then
		error("Usage: LibDualSpec:EnhanceOptions(optionTable, target): optionTable should be a table.", 2)
	elseif type(target) ~= "table" then
		error("Usage: LibDualSpec:EnhanceOptions(optionTable, target): target should be a table.", 2)
	elseif not (AceDBOptions3 and AceDBOptions3.optionTables[target]) then
		error("Usage: LibDualSpec:EnhanceOptions(optionTable, target): optionTable is not an AceDBOptions-3.0 table.", 2)
	elseif optionTable.handler.db ~= target then
		error("Usage: LibDualSpec:EnhanceOptions(optionTable, target): optionTable must be the option table of target.", 2)
	elseif not registry[target] then
		error("Usage: LibDualSpec:EnhanceOptions(optionTable, target): EnhanceDatabase should be called before EnhanceOptions(optionTable, target).", 2)
	elseif optionTable.plugins and optionTable.plugins[MAJOR] then
		return
	end
	if not optionTable.plugins then
		optionTable.plugins = {}
	end
	optionTable.plugins[MAJOR] = options
end

-- ----------------------------------------------------------------------------
-- Inspection
-- ----------------------------------------------------------------------------

local function iterator(registry, key)
	local data
	key, data = next(registry, key)
	if key then
		return key, data.name
	end
end

--- Iterate through enhanced AceDB3.0 instances.
-- The iterator returns (instance, name) pairs where instance and name are the
-- arguments that were provided to lib:EnhanceDatabase.
-- @name LibDualSpec:IterateDatabases
-- @return Values to be used in a for .. in .. do statement.
function lib:IterateDatabases()
	return iterator, lib.registry
end

-- ----------------------------------------------------------------------------
-- Switching logic
-- ----------------------------------------------------------------------------

lib.eventFrame:RegisterEvent('PLAYER_TALENT_UPDATE')
lib.eventFrame:SetScript('OnEvent', function()
	lib.talentsLoaded = true
	local newTalentGroup = GetActiveTalentGroup()
	if lib.talentGroup ~= newTalentGroup then
		lib.talentGroup = newTalentGroup
		for target in pairs(registry) do
			target:CheckDualSpecState()
		end
	end
end)


