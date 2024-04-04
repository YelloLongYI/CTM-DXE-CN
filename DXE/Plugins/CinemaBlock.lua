local addon = DXE
local format = string.format

local defaults = {
	profile = {
		SkipCinematics = true,
        SkipMovies = true,
        WatchedCinematics = {},
        WatchedMovies = {},
        PrintSkipMessages = true,
        FixCinematicsInDeath = true,
	}
}

local L = addon.L

local db,pfl,gbl


---------------------------------------
-- INITIALIZATION
---------------------------------------

local module = addon:NewModule("CinemaBlock","AceTimer-3.0","AceEvent-3.0")
addon.CinemaBlock = module
addon.CinemaBlock.defaults = defaults

local cinematicsDB = {}
local movieDB = {}

local WatchStatus = {
    [0] = "|cffffff00HAVE NOT SEEN|r",
    [1] = "|cff00ff00ALREADY HAVE SEEN|r",
    [2] = "|cff8000ffIGNORE|r",
    HAVE_NOT_SEEN = 0,
    HAVE_SEEN = 1,
    IGNORE = 2,
}
addon.CinemaBlock.WatchStatus = WatchStatus

function module:RefreshProfile()
	pfl = db.profile
end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("CinemaBlock", defaults)
	db = self.db
	pfl = db.profile
    gbl = db.global
    
	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
    
    module:RegisterEvent("CINEMATIC_START")
    module:RegisterEvent("CINEMATIC_STOP")
    module:SetupMovieHook()
    
    addon.CinemaBlock.cinematicsDB = cinematicsDB
    addon.CinemaBlock.movieDB = movieDB
end

do 
    function module:getCinematicID(areaId, areaLevel)
        return ("%d:%d"):format(areaId, areaLevel)
    end

    function module:CINEMATIC_START(...)
        if pfl.FixCinematicsInDeath and UnitIsDead("player") and InCinematic() then
            UIErrorsFrame:Clear()
            UIParent:Hide()
            CinematicFrame:Show()
        end
        if pfl.SkipCinematics then
            SetMapToCurrentZone()
            local areaId = GetCurrentMapAreaID() or 0
            local areaLevel = GetCurrentMapDungeonLevel() or 0
            local id = module:getCinematicID(areaId, areaLevel)
            
            if cinematicsDB[id] then
                if pfl.WatchedCinematics[id] then
                    if pfl.WatchedCinematics[id] == WatchStatus.HAVE_SEEN then
                        if pfl.PrintSkipMessages then
                            addon:Print(format("|cffffff00%s|r: |cffffffff%s|r",cinematicsDB[id].name,L["The cinematic has been automatically skipped."]))
                        end
                        CinematicFrame_CancelCinematic()
                    elseif pfl.WatchedCinematics[id] == WatchStatus.HAVE_NOT_SEEN then
                        pfl.WatchedCinematics[id] = WatchStatus.HAVE_SEEN
                    end
                else
                    pfl.WatchedCinematics[id] = WatchStatus.HAVE_SEEN
                end
            end
        else
            addon:FixPopupDialogs()
        end
    end
    
    function module:CINEMATIC_STOP(...)
        if pfl.FixCinematicsInDeath then UIParent:Show() end
        addon:FixPopupDialogs()
    end
    
    local StopMovieTimer
    
    -- ZONE_CHANGED
    local blizzMovieHandler = MovieFrame:GetScript("OnEvent")
    function module:SetupMovieHook()
        MovieFrame:SetScript("OnEvent", module.PLAY_MOVIE)
    end
    
    -- Had to do it the BigWigs way. The RegisterEvent way was way too unstable.
    function module:PLAY_MOVIE(event, movieID, ...)
        if event == "PLAY_MOVIE" then
            if pfl.SkipMovies then
                if movieDB[movieID] then
                    if pfl.WatchedMovies[movieID] then
                        if pfl.WatchedMovies[movieID] == WatchStatus.HAVE_SEEN then
                            if pfl.PrintSkipMessages then
                                addon:Print(format("|cffffff00%s|r: |cffffffff%s|r",movieDB[movieID].name,L["The movie has been automatically skipped."]))
                            end
                            return MovieFrame_OnMovieFinished(MovieFrame)
                        elseif pfl.WatchedMovies[movieID] == WatchStatus.HAVE_NOT_SEEN then
                            pfl.WatchedMovies[movieID] = WatchStatus.HAVE_SEEN
                        end
                    else
                        pfl.WatchedMovies[movieID] = WatchStatus.HAVE_SEEN
                    end
                end
            end
        end
        
        blizzMovieHandler(MovieFrame, event, movieID, ...)
    end    
end


---------------------------------------
-- API
---------------------------------------
function addon:RegisterCinematic(instance, name, areaId, areaLevel)
    local id = module:getCinematicID(areaId, areaLevel)
    if not cinematicsDB[id] then
        cinematicsDB[id] = {
            name = format("|cffffff00%s|r: %s",instance,name) or "Unknown",
        }
    end
end 

function addon:RegisterMovie(instance, name, movieID)
    if not movieDB[movieID] then
        movieDB[movieID] = {
            name = format("|cffff2200%s|r: %s",instance,name) or "Unknown",
        }
    end
end
