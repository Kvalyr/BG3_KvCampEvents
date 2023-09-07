local _E = KVS.Output.Error
local _W = KVS.Output.Warning
local _I = KVS.Output.Info
local _DBG = KVS.Output.Debug
local DB = KVS.DB
local Events = KVS.Events
local Utils = KVS.Utils
local Table = KVS.Table

-- _DBG("======== KvCE START Main")

local Notifications = Notifications
local RE = Reimplementations
local State = State

-- ==================================================
local CampEvents = CampEvents
-- ==================================================

function CampEvents.GetActiveCamp()
    local activeCampTable = Osi.DB_ActiveCamp:Get(nil)
    if not activeCampTable then
        return
    end
    activeCampTable = activeCampTable[1] -- [1]
    if not activeCampTable then
        return
    end
    activeCampTable = activeCampTable[1] -- [1][1]

    -- return Osi.DB_ActiveCamp:Get(nil)[1][1]
    return activeCampTable or ""
end

function CampEvents.PlayerInCamp()
    return DB.Bool("DB_PlayerInCamp", nil)
end

-- function CampEvents.GetPossibleCampNightEventsForCamp( campsite_str )
--     return Osi.DB_CampNight_Camp:Get(nil, campsite_str)
-- end
-- function CampEvents.GetPossibleCampNightEventsForCamp_Current()
--     return CampEvents.GetPossibleCampNightEventsForCamp(CampEvents.GetActiveCamp())
-- end


-- ==================================================
-- ==================================================

local DB_InCamp_TemporaryAdded = {}
local function ResetDBInCampTemporary()
    -- Empty out the temp table
    if #DB_InCamp_TemporaryAdded > 0 then
        for k in pairs(DB_InCamp_TemporaryAdded) do
            DB_InCamp_TemporaryAdded[k] = nil
        end
    end
end

local function TemporarilyAddToDBInCamp()
    if CampEvents.PlayerInCamp() then
        return
    end
    ResetDBInCampTemporary()

    local partyMembers = Utils.GetPartyMembers()
    local campMembers = Utils.GetCampMembers()
    local campMembers_inverted = Table.Invert(campMembers)

    for k, partyMemberUUID in pairs(partyMembers) do
        if not Table.HasKey(campMembers_inverted, partyMemberUUID) then
            table.insert(DB_InCamp_TemporaryAdded, partyMemberUUID)

            -- Insert to DB_InCamp
            Osi.DB_InCamp(partyMemberUUID)
        end
    end
end

local function RestoreDBInCamp()
    -- Delete our temporary additions from DB_InCamp
    for k, v in pairs(DB_InCamp_TemporaryAdded) do
        -- _DBG("Would delete from DB_InCamp:", v)
        Osi.DB_InCamp:Delete(v)
    end
    ResetDBInCampTemporary()
end

-- ==================================================
-- ==================================================

-- ================
-- Add statuses, exclamation overhead, etc.
function CampEvents.NotifyPlayer()
    _DBG("CampEvents.NotifyPlayer") -- DEBUG
    if CampEvents.CheckUninstalled("CampEvents.NotifyPlayer()") then
        return
    end

    local character_uuid = Utils.GetPlayer()
    -- TODO: Differentiate between Camp Events and Relationship Dialogs

    Notifications.AddStatusEffect_CampNightEvents(character_uuid)
    -- Notifications.AddStatusEffect_RelationshipDialogues(character_uuid)
    Notifications.AddExclamationOverCharacter(character_uuid)
end

-- ================
--
function CampEvents.Cleanup()
    _DBG("CampEvents.Cleanup") -- DEBUG
    local character_uuid = Utils.GetPlayer()

    -- TODO: Differentiate between Camp Events and Relationship Dialogs
    Notifications.RemoveStatusEffect_CampNightEvents(character_uuid)
    Notifications.RemoveStatusEffect_RelationshipDialogues(character_uuid)
    Notifications.RemoveExclamationOverCharacter(character_uuid)
end

-- Mods.KvCampEvents.CampEvents.FindValidNightEvents()
-- ================
--
function CampEvents.FindValidNightEvents()
    local eventsInDB = DB.GetRows("DB_CampNight", 2)
    local numEvents = #eventsInDB

    local validEvents = {}

    if Osi.QRY_Camp_IsPlayerBlockedFromTeleportToCamp(Utils.GetPlayer()) then
        _DBG("FindValidNightEvents() - Skipping due to QRY_Camp_IsPlayerBlockedFromTeleportToCamp == true")
        return validEvents
    end

    local currentCamp = CampEvents.GetActiveCamp() -- _Var2
    if not currentCamp or currentCamp == "" then
        _DBG("FindValidNightEvents() - Skipping due to nil currentCamp")
        return validEvents
    end

    TemporarilyAddToDBInCamp()
    for idx, subTable in pairs(eventsInDB) do
        local eventUUID = subTable[1]
        local eventPriority = subTable[2]
        local ignorePrevious = true

        if RE.PROC_CampNight_DecideCampNight_Recursive(currentCamp, eventUUID, eventPriority, ignorePrevious) then
            table.insert(validEvents, eventUUID)
        end
    end
    RestoreDBInCamp()

    if KVS.Output.GetLogLevel() >= 3 then
        _DBG("FindValidNightEvents() - Events:")
        _D(validEvents)
    end
    return validEvents
end

-- local function IsJustWokeUp()
--     return DB.Bool("DB_CAMP_JustWokeUp", 1)
-- end
local function IsNightMode()
    return DB.Bool("DB_Camp_NightMode", 1)
end

-- ================
-- Main callback triggered by game events to check for pending night events, and notify player if necessary
function CampEvents.CheckNotifyNightEvents()

    if CampEvents.CheckUninstalled("CampEvents.CheckNotifyNightEvents()") then
        return
    end

    if IsNightMode() then
        _DBG("CheckNotifyNightEvents - Skipping due to DB_Camp_NightMode(1) ")
        CampEvents.Cleanup()
        return
    end

    -- if IsJustWokeUp() then
    --     -- This remains true from waking up until requesting to end the day, outside of special circumstances - Not useful for us
    --     _DBG("CheckNotifyNightEvents - Skipping due to DB_CAMP_JustWokeUp(1) ")
    --     CampEvents.Cleanup()
    --     return
    -- end

    local validEvents = CampEvents.FindValidNightEvents()
    local numValidEvents = #validEvents or 0

    _I("Number of Camp Night Events waiting to play: " .. (numValidEvents)) -- DEBUG

    if numValidEvents > 0 then
        CampEvents.NotifyPlayer()
    else
        CampEvents.Cleanup()
    end
end

function CampEvents.RegisterNightEventsCheck( proc_event, num_params, before_or_after )
    if num_params == nil then
        num_params = 0
    end
    if not before_or_after then
        before_or_after = "after"
    end

    Ext.Osiris.RegisterListener(
        proc_event, num_params, before_or_after, function( who, ... )
            if proc_event == "PROC_Subregion_Entered" and not Utils.IsUUIDPlayer(who) then
                return
            end

            _DBG(proc_event, who, ..., " CampEvents.CheckNotifyNightEvents")
            CampEvents.CheckNotifyNightEvents()
        end
    )
end

function CampEvents.CheckUninstalled( caller )
    if State.IsUninstalled() then
        _DBG((caller or "[Unknown]") .. " - CampEvents.CheckUninstalled() - KvCE in UNINSTALLED state - Skipping to cleanup")
        CampEvents.Cleanup()
        return true
    end
    return false
end

local function PreSave_Cleanup()
    _I("Doing cleanup before save.")
    CampEvents.Cleanup()
end

local function PostSave_CheckNotify()
    _I("Checking for events after save.")
    CampEvents.CheckNotifyNightEvents()
end


function CampEvents.Init()
    if CampEvents.CheckUninstalled("CampEvents.Init()") then
        return
    end

    Events.RegisterGameStateChanged("Running", "Save", PreSave_Cleanup)
    Events.RegisterGameStateChanged("Save", "Running", PostSave_CheckNotify)

    -- CampEvents.RegisterNightEventsCheck("SetFlag", 2, "after")
    -- CampEvents.RegisterNightEventsCheck("ClearFlag", 2, "after")
    CampEvents.RegisterNightEventsCheck("PROC_Subregion_Entered", 2, "after")
    CampEvents.RegisterNightEventsCheck("LevelGameplayStarted", 2, "after")
    CampEvents.RegisterNightEventsCheck("SavegameLoaded", 0, "after")
    CampEvents.RegisterNightEventsCheck("DialogEnded", 2, "after")
    -- CampEvents.RegisterNightEventsCheck("PROC_Camp_SwitchNightMode", 0, "after")
    -- CampEvents.RegisterNightEventsCheck("DB_Camp_NightMode", 0, "after")

    CampEvents.RegisterNightEventsCheck("PROC_Camp_PlayCampNight", 0, "after")
    -- CampEvents.RegisterNightEventsCheck("PROC_CampNight_LastDialogPlayed", nil, "after")
    -- CampEvents.RegisterNightEventsCheck("PROC_CampNight_ForceComplete", 1, "after")
    CampEvents.RegisterNightEventsCheck("PROC_CampNight_ClearCampNight", 1, "after")
end

-- _DBG("==== KvCE END Main")
