print("======== KvCE START Main")

local DB = KVS.DB
local utils = KVS.Utils


local function GetActiveCamp()
    return Osi.DB_ActiveCamp:Get(nil)[1][1]
end

local function GetPossibleCampNightEventsForCamp(campsite_str)
    return Osi.DB_CampNight_Camp:Get(nil, campsite_str)
end
local function GetPossibleCampNightEventsForCamp_Current()
    return GetPossibleCampNightEventsForCamp(GetActiveCamp())
end
CampEvents.GetActiveCamp = GetActiveCamp
CampEvents.GetPossibleCampNightEventsForCamp = GetPossibleCampNightEventsForCamp
CampEvents.GetPossibleCampNightEventsForCamp_Current = GetPossibleCampNightEventsForCamp_Current


-- ================================================================
--
function IsValidCampNightEvent(newDialogEvent, newDialogPriority, ignorePrevious)
    if ignorePriority == nil then ignorePriority = false end
    local currentCamp = GetActiveCamp()  -- _Var2
    -- local newDialogEvent -- _Var3
    -- local newDialogPriority -- _Var4

    -- AND NOT DB_FallbackCamp_InCamp(_, _, _, _, _)
    if not DB.IsEmpty("DB_FallbackCamp_InCamp", 1) then return end

    -- TODO: This is probably redundant? Likely only part of the Osiris proc for sanity-checking
    -- AND DB_ActiveCamp(_Var2, _, _, _, _)
    if not DB.Bool("DB_ActiveCamp", currentCamp) then return end

    -- Dialog event isn't in DB_CampNight at all
    -- AND DB_CampNight(_Var3, _Var4, _, _, _)
    if not DB.Bool("DB_CampNight", newDialogEvent, newDialogPriority) then return end

    -- Dialog event isn't valid for current camp location
    -- AND DB_CampNight_Camp(_Var3, _Var2, _, _, _)
    if not DB.Bool("DB_CampNight_Camp", newDialogEvent, currentCamp) then return end

    -- Dialog event already queued
    -- AND NOT DB_Camp_QueuedNight(_Var3, _, _, _, _)
    if DB.Bool("DB_Camp_QueuedNight", newDialogEvent) then return end

    -- Dialog event already completed
    if DB.Bool("DB_CampNight_Completed", newDialogEvent) then return end

    if not ignorePrevious then

        if not DB.Bool("DB_Camp_BestCampNight", previousBestCampNightDialog, previousBestCampNightPriority ) then
            Osi.DB_Camp_BestCampNight("Fake_00000000-0000-0000-0000-000000000000", -1)
            return
        end

        local previousBestCampNightTable = Osi.DB_Camp_BestCampNight:Get(nil,nil)[1]
        local previousBestCampNightDialog = previousBestCampNightTable[1] -- _Var5
        local previousBestCampNightPriority = previousBestCampNightTable[2] -- _Var6

        _P("IsValidCampNightEvent - Previous Best: '" .. previousBestCampNightDialog .. "'")

        -- AND DB_Camp_BestCampNight(_Var5, _Var6, _, _, _)
        if not DB.Bool("DB_Camp_BestCampNight", previousBestCampNightDialog, previousBestCampNightPriority ) then return end

        -- AND  newDialogPriority > previousBestCampNightPriority
        if not (newDialogPriority > previousBestCampNightPriority) then
            _P("IsValidCampNightEvent - Ignoring: '" .. newDialogEvent .. "' due to priority.")
            return
        end

    end

    -- AND NOT QRY_CampNight_HasExclusivityProblem(_Var3, _, _, _, _)
    if Osi.QRY_CampNight_HasExclusivityProblem(newDialogEvent) then return end

    -- AND NOT QRY_CampNight_HasEveningReservedSpeakerProblem(_Var3, _, _, _, _)
    if Osi.QRY_CampNight_HasEveningReservedSpeakerProblem(newDialogEvent) then return end

    -- AND NOT QRY_CampNight_HasSleepReservedSpeakerProblem(_Var3, _, _, _, _)
    if Osi.QRY_CampNight_HasSleepReservedSpeakerProblem(newDialogEvent) then return end

    -- AND NOT QRY_CampNight_HasMorningReservedSpeakerProblem(_Var3, _, _, _, _)
    if Osi.QRY_CampNight_HasMorningReservedSpeakerProblem(newDialogEvent) then return end

    -- AND QRY_CampNight_MeetsRequirements(_Var3, _, _, _, _)
    if not Osi.QRY_CampNight_MeetsRequirements(newDialogEvent) then return end

    -- AND NOT QRY_CampNight_AllSpeakersMissing(_Var3, _, _, _, _)
    if Osi.QRY_CampNight_AllSpeakersMissing(newDialogEvent) then return end

    -- THEN

    -- NOT DB_Camp_BestCampNight(_Var5, _Var6);
    -- Not needed for speculative

    -- DB_Camp_BestCampNight(_Var3, _Var4);
    -- Not needed for speculative - Return/print instead
    -- _P("IsValidCampNightEvent - Would add: '" .. newDialogEvent .. "' to DB_Camp_BestCampNight.")

    return true
end
CampEvents.IsValidCampNightEvent = IsValidCampNightEvent

local function IsNightMode()
    return DB.Bool("DB_Camp_NightMode", 1)
end


-- ================================================================
-- Player Exclamation effects
local function AddExclamationOverCharacter(character_uuid)
    if not character_uuid then
        character_uuid = GetHostCharacter()
    end

    local existingLoopEffectHandler = CampEvents.GetExclamationLoopEffectHandle()
    if not existingLoopEffectHandler then
        Osi.PROC_LoopEffect("EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80", character_uuid, "RelationshipMarker", "__ANY__", "Dummy_OverheadFX");
    end
end
CampEvents.AddExclamationOverCharacter = AddExclamationOverCharacter


local function GetExclamationLoopEffectHandle(character_uuid)
    local loopEffectTable = Osi.DB_LoopEffect:Get(
        character_uuid,
        nil,
        "RelationshipMarker",
        nil,
        "EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80",
        "Dummy_OverheadFX",
        nil
    )

    if not loopEffectTable then
        -- _P("GetExclamationLoopEffectHandle", "not loopEffectTable") -- DEBUG
        return
    end
    loopEffectTable = loopEffectTable[1]
    if not loopEffectTable then
        -- _P("GetExclamationLoopEffectHandle", "not loopEffectTable[1]") -- DEBUG
        return
    end
    local loop_effect_handle = loopEffectTable[2]
    if not loop_effect_handle then
        -- _P("GetExclamationLoopEffectHandle", "not loop_effect_handle") -- DEBUG
        return
    end

    return loop_effect_handle
end
CampEvents.GetExclamationLoopEffectHandle = GetExclamationLoopEffectHandle

local function RemoveExclamationOverCharacter(character_uuid, loop_effect_handle)
    if not character_uuid then
        character_uuid = GetHostCharacter()
    end

    if not loop_effect_handle then
        loop_effect_handle = GetExclamationLoopEffectHandle(character_uuid)
    end

    if loop_effect_handle ~= nil then
        Osi.PROC_StopLoopEffect(loop_effect_handle)

        Osi.DB_LoopEffect:Delete(
            character_uuid,
            loop_effect_handle,
            "RelationshipMarker",
            "__ANY__",
            "EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80",
            "Dummy_OverheadFX",
            1.0
        )
    end

end
CampEvents.RemoveExclamationOverCharacter = RemoveExclamationOverCharacter
-- ================================

-- ================
-- NotifyPlayer
local function NotifyPlayer()
    _P("CampEvents.NotifyPlayer")  -- DEBUG
    local character_uuid = GetHostCharacter()
    -- TODO: Differentiate between Camp Events and Relationship Dialogs
    Osi.ApplyStatus(character_uuid, "KvCampEvents_Notification_CampNightEvents", -1)
    -- Osi.ApplyStatus(character_uuid, "KvCampEvents_Notification_RelationshipDialogues", -1)
    AddExclamationOverCharacter()
end
CampEvents.NotifyPlayer = NotifyPlayer

--  Osi.ApplyStatus(GetHostCharacter(), "KvCampEvents_Notification_CampNightEvents", -1)

-- ================
-- Cleanup
local function Cleanup()
    _P("CampEvents.Cleanup")  -- DEBUG
    local character_uuid = GetHostCharacter()
    RemoveExclamationOverCharacter(character_uuid)
    -- TODO: Differentiate between Camp Events and Relationship Dialogs
    Osi.RemoveStatus(character_uuid, "KvCampEvents_Notification_CampNightEvents")
    -- Osi.RemoveStatus(character_uuid, "KvCampEvents_Notification_RelationshipDialogues")
end
CampEvents.Cleanup = Cleanup


-- Mods.KvCampEvents.CampEvents.FindValidNightEvents()
-- ================
-- FindValidNightEvents
local function FindValidNightEvents(doDebug)
    if doDebug == nil then doDebug = false end

    local eventsInDB = DB.GetRows("DB_CampNight", 2)
    local numEvents = #eventsInDB

    local validEvents = {}

    for idx, subTable in pairs(eventsInDB) do
        local subTableLen = #subTable
        local eventUUID = subTable[1]
        local eventPriority = subTable[2]
        local ignorePrevious = true

        if CampEvents.IsValidCampNightEvent(eventUUID, eventPriority, ignorePrevious) then
            table.insert(validEvents, eventUUID)
        end
    end
    if doDebug then
        _P("FindValidNightEvents() - Events:")
        _D(validEvents)
    end
    return validEvents
end
CampEvents.FindValidNightEvents = FindValidNightEvents


-- Mods.KvCampEvents.CampEvents.CheckNotifyNightEvents()
-- ================
-- CheckNotifyNightEvents
local function CheckNotifyNightEvents(doDebug)

    if IsNightMode() then
        _P("CheckNotifyNightEvents - Skipping due to DB_Camp_NightMode(1) ")
        CampEvents.Cleanup()
        return
    end

    local validEvents = CampEvents.FindValidNightEvents(true)
    local numValidEvents = #validEvents or 0

    _P("Number of Camp Night Events waiting to play: " .. (numValidEvents))  -- DEBUG

    if numValidEvents > 0 then
        CampEvents.NotifyPlayer()
    else
        CampEvents.Cleanup()
    end
end
CampEvents.CheckNotifyNightEvents = CheckNotifyNightEvents

function RegisterNightEventsCheck(proc_event, num_params, before_or_after)
    if num_params == nil then num_params = 0 end
    if not before_or_after then before_or_after = "after" end

    Ext.Osiris.RegisterListener(proc_event, num_params, before_or_after, function (who, ...)
        -- if not string.find(who, GetHostCharacter(), _, true) then return end
        if proc_event == "PROC_Subregion_Entered" and not utils.IsUUIDPlayer(who) then return end

        _P(proc_event, who, ..., " CampEvents.CheckNotifyNightEvents")
        CampEvents.CheckNotifyNightEvents(true)
    end)
end
CampEvents.RegisterNightEventsCheck = RegisterNightEventsCheck


local function Init()
    -- RegisterNightEventsCheck("SetFlag", 2, "after")
    -- RegisterNightEventsCheck("ClearFlag", 2, "after")
    RegisterNightEventsCheck("PROC_Subregion_Entered", 2, "after")
    RegisterNightEventsCheck("SavegameLoaded", 0, "after")
    RegisterNightEventsCheck("DialogEnded", 2, "after")
    -- RegisterNightEventsCheck("PROC_Camp_SwitchNightMode", 0, "after")
    -- RegisterNightEventsCheck("DB_Camp_NightMode", 0, "after")

    RegisterNightEventsCheck("PROC_Camp_PlayCampNight", 0, "after")
    -- RegisterNightEventsCheck("PROC_CampNight_LastDialogPlayed", nil, "after")
    -- RegisterNightEventsCheck("PROC_CampNight_ForceComplete", 1, "after")
    RegisterNightEventsCheck("PROC_CampNight_ClearCampNight", 1, "after")

end
CampEvents.Init = Init


print("==== KvCE END Main")
