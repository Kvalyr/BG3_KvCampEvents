local _E = KVS.Output.Error
local _W = KVS.Output.Warning
local _I = KVS.Output.Info
local _DBG = KVS.Output.Debug
local DB = KVS.DB
local utils = KVS.Utils
-- _DBG("======== KvCE START Reimplementations")

-- Osiris Procs and Queries reimplemented as Lua functions with modifications for our needs

-- ==================================================
Reimplementations = {}
-- ==================================================

-- ================================================================
-- Main function for emulating the game's decision-making process about what camp night event(s) to choose
-- but in a read-only way, without affecting DBs or interfering with game logic.
-- ====
-- Lua reimplementation of PROC_CampNight_DecideCampNight_Recursive from GLO_CampNights.txt
-- Intended to emulate the decision-making process of 'PROC_CampNight_DecideCampNight_Recursive'
-- Notable changes from Osiris proc:
-- * Option to ignore previous 'best' event and priorities (i.e.; just determine if an event is pending at all)
-- * No writes to DB_Camp_BestCampNight -- This func is read-only
-- ====
function Reimplementations.PROC_CampNight_DecideCampNight_Recursive( currentCamp, newDialogEvent, newDialogPriority, ignorePrevious )

    -- local newDialogEvent -- _Var3
    -- local newDialogPriority -- _Var4

    -- AND NOT DB_FallbackCamp_InCamp(_, _, _, _, _)
    if not DB.IsEmpty("DB_FallbackCamp_InCamp", 1) then
        return
    end

    -- TODO: This is probably redundant? _Var2 is probably an out var, but we're passing it in as a param here anyway
    -- AND DB_ActiveCamp(_Var2, _, _, _, _)
    -- if not DB.Bool("DB_ActiveCamp", currentCamp) then return end

    -- Dialog event isn't in DB_CampNight at all
    -- AND DB_CampNight(_Var3, _Var4, _, _, _)
    if not DB.Bool("DB_CampNight", newDialogEvent, newDialogPriority) then
        return
    end

    -- Dialog event isn't valid for current camp location
    -- AND DB_CampNight_Camp(_Var3, _Var2, _, _, _)
    if not DB.Bool("DB_CampNight_Camp", newDialogEvent, currentCamp) then
        return
    end

    -- Dialog event already queued
    -- AND NOT DB_Camp_QueuedNight(_Var3, _, _, _, _)
    if DB.Bool("DB_Camp_QueuedNight", newDialogEvent) then
        return
    end

    -- Dialog event already completed
    if DB.Bool("DB_CampNight_Completed", newDialogEvent) then
        return
    end

    if not ignorePrevious then

        if not DB.Bool("DB_Camp_BestCampNight", previousBestCampNightDialog, previousBestCampNightPriority) then
            Osi.DB_Camp_BestCampNight("Fake_00000000-0000-0000-0000-000000000000", -1)
            return
        end

        local previousBestCampNightTable = Osi.DB_Camp_BestCampNight:Get(nil, nil)[1]
        local previousBestCampNightDialog = previousBestCampNightTable[1] -- _Var5
        local previousBestCampNightPriority = previousBestCampNightTable[2] -- _Var6

        -- _DBG("IsValidCampNightEvent - Previous Best: '" .. previousBestCampNightDialog .. "'")

        -- AND DB_Camp_BestCampNight(_Var5, _Var6, _, _, _)
        if not DB.Bool("DB_Camp_BestCampNight", previousBestCampNightDialog, previousBestCampNightPriority) then
            return
        end

        -- AND  newDialogPriority > previousBestCampNightPriority
        if not (newDialogPriority > previousBestCampNightPriority) then
            -- _DBG("IsValidCampNightEvent - Ignoring: '" .. newDialogEvent .. "' due to priority.")
            return
        end

    end

    -- AND NOT QRY_CampNight_HasExclusivityProblem(_Var3, _, _, _, _)
    if Osi.QRY_CampNight_HasExclusivityProblem(newDialogEvent) then
        -- _DBG("IVCNE - Skipping due to 'QRY_CampNight_HasExclusivityProblem'", newDialogEvent)
        return
    end

    -- AND NOT QRY_CampNight_HasEveningReservedSpeakerProblem(_Var3, _, _, _, _)
    if Osi.QRY_CampNight_HasEveningReservedSpeakerProblem(newDialogEvent) then
        -- _DBG("IVCNE - Skipping due to 'QRY_CampNight_HasEveningReservedSpeakerProblem'", newDialogEvent)
        return
    end

    -- AND NOT QRY_CampNight_HasSleepReservedSpeakerProblem(_Var3, _, _, _, _)
    if Osi.QRY_CampNight_HasSleepReservedSpeakerProblem(newDialogEvent) then
        -- _DBG("IVCNE - Skipping due to 'QRY_CampNight_HasSleepReservedSpeakerProblem'", newDialogEvent)
        return
    end

    -- AND NOT QRY_CampNight_HasMorningReservedSpeakerProblem(_Var3, _, _, _, _)
    if Osi.QRY_CampNight_HasMorningReservedSpeakerProblem(newDialogEvent) then
        -- _DBG("IVCNE - Skipping due to 'QRY_CampNight_HasMorningReservedSpeakerProblem'", newDialogEvent)
        return
    end

    -- AND QRY_CampNight_MeetsRequirements(_Var3, _, _, _, _)
    if not Osi.QRY_CampNight_MeetsRequirements(newDialogEvent) then
        -- _DBG("IVCNE - Skipping due to 'QRY_CampNight_MeetsRequirements'", newDialogEvent)
        return
    end

    -- AND NOT QRY_CampNight_AllSpeakersMissing(_Var3, _, _, _, _)
    if Osi.QRY_CampNight_AllSpeakersMissing(newDialogEvent) then
        -- _DBG("IVCNE - Skipping due to 'QRY_CampNight_AllSpeakersMissing'", newDialogEvent)
        return
    end

    -- THEN

    -- NOT DB_Camp_BestCampNight(_Var5, _Var6);
    -- Not needed for speculative

    -- DB_Camp_BestCampNight(_Var3, _Var4);
    -- Not needed for speculative - Return/print instead
    -- _DBG("IsValidCampNightEvent - Would add: '" .. newDialogEvent .. "' to DB_Camp_BestCampNight.")

    return true
end

-- -- Reimplmement QRY_CampNight_MeetsRequirements_Approval in Lua without checking DB_InCamp
-- local function KvCE_QRY_CampNight_MeetsRequirements_Approval(newDialogEvent)
--     local reqApprovalTable = Osi.DB_CampNight_Requirement_Approval:Get(newDialogEvent,nil,nil)
--     if #reqApprovalTable < 1 then return end
--     reqApprovalTable = reqApprovalTable[1]
--     local companionUUID = reqApprovalTable[2] -- _Var2
--     local requiredApprovalRating = reqApprovalTable[3] -- _Var3
--     local avatar = Osi.DB_Avatars:Get(nil)[1][1] -- _Var4 -- GetHostCharacter() is probably fine for our purposes
--     local currentApprovalRating = Osi.GetApprovalRating(companionUUID, avatar) -- _Var5
--     return currentApprovalRating >= requiredApprovalRating

--     -- QRY QRY_CampNight_MeetsRequirements_Approval((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
--     --     AND GetApprovalRating(_Var2, _Var4, _Var5, _Var1, _Var1)
--     --     AND _Var5 >= _Var3
--     -- THEN
--     --     DB_NOOP(1);

--     -- QRY QRY_CampNight_MeetsRequirements_Approval((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
--     --     AND DB_CampNight_Requirement_Approval(_Var1, _Var2, _Var3, _Var1, _Var1)
--     --     AND DB_InCamp(_Var2, _Var1, _Var1, _Var1, _Var1)
--     --     AND NOT DB_Avatars(_Var2, _Var1, _Var1, _Var1, _Var1)
--     --     AND DB_Avatars(_Var4, _Var1, _Var1, _Var1, _Var1)
--     --     AND DB_InCamp(_Var4, _Var1, _Var1, _Var1, _Var1)
--     --     AND NOT QRY_PreventMPDialogue(_Var2, _Var4, _Var1, _Var1, _Var1)
--     --     AND GetApprovalRating(_Var2, _Var4, _Var5, _Var1, _Var1)
--     --     AND _Var5 >= _Var3
--     -- THEN
--     --     DB_NOOP(1);

-- end

-- function Reimplementations.QRY_CampNight_MeetsRequirements_StartDating(newDialogEvent)
--     -- QRY QRY_CampNight_MeetsRequirements_StartDating((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
--     --     AND DB_CampNight_Requirement_CanStartDating(_Var1, _Var2, _Var1, _Var1, _Var1)
--     --     AND NOT DB_ORI_Dating(_, _Var2, _Var1, _Var1, _Var1)
--     --     AND DB_Avatars(_Var4, _Var1, _Var1, _Var1, _Var1)
--     --     AND DB_InCamp(_Var4, _Var1, _Var1, _Var1, _Var1)
--     --     AND NOT DB_Avatars(_Var2, _Var1, _Var1, _Var1, _Var1)
--     --     AND NOT DB_ORI_Partnered(_Var4, _, _Var1, _Var1, _Var1)
--     --     AND GetFlag(ORI_State_DoubleDating_41320aeb-8e1a-433d-a82e-3d78aff578da, _Var4, 0, _Var1, _Var1)
--     --     AND NOT DB_ORI_WasDating(_Var4, _Var2, _Var1, _Var1, _Var1)
--     --     AND NOT QRY_PreventMPDialogue(_Var2, _Var4, _Var1, _Var1, _Var1)
--     -- THEN
--     --     DB_NOOP(1);

--     -- QRY QRY_CampNight_MeetsRequirements_StartDating((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
--     --     AND NOT DB_CampNight_Requirement_CanStartDating(_Var1, _, _Var1, _Var1, _Var1)
--     -- THEN
--     --     DB_NOOP(1);
-- end

-- function Reimplementations.QRY_CampNight_MeetsRequirements(newDialogEvent)
--     -- QRY QRY_CampNight_MeetsRequirements((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
--     --     AND NOT QRY_CampNight_MeetsRequirements_IsInFallback(_Var1, _Var1, _Var1, _Var1, _Var1)
--     --     AND QRY_CampNight_MeetsRequirements_Flags(_Var1, _Var1, _Var1, _Var1, _Var1)
--     --     AND QRY_CampNight_MeetsRequirements_Approval(_Var1, _Var1, _Var1, _Var1, _Var1)
--     --     AND QRY_CampNight_MeetsRequirements_Partner(_Var1, _Var1, _Var1, _Var1, _Var1)
--     --     AND QRY_CampNight_MeetsRequirements_Dating(_Var1, _Var1, _Var1, _Var1, _Var1)
--     --     AND QRY_CampNight_MeetsRequirements_StartDating(_Var1, _Var1, _Var1, _Var1, _Var1)
--     --     AND QRY_CampNight_MeetsRequirements_SameUser(_Var1, _Var1, _Var1, _Var1, _Var1)
--     -- THEN
--     --     DB_NOOP(1);

--     -- QRY QRY_CampNight_MeetsRequirements((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
--     --     AND QRY_CampNight_MeetsRequirements_IsInFallback(_Var1, _Var1, _Var1, _Var1, _Var1)
--     --     AND QRY_FallbackCamp_CampNightMeetsRequirements(_Var1, _Var1, _Var1, _Var1, _Var1)
--     -- THEN
--     --     DB_NOOP(1);

--     -- Alternate_QRY_CampNight_MeetsRequirements(newDialogEvent) -- debug

--     if not Osi.QRY_CampNight_MeetsRequirements_IsInFallback(newDialogEvent) then
--         _DBG("KvCE_QRY_CampNight_MeetsRequirements() - NOT in fallback")
--         if not Osi.QRY_CampNight_MeetsRequirements_Flags(newDialogEvent) then return false end
--         -- Use lua reimplementation that skips DB_InCamp checks
--         -- if not Osi.QRY_CampNight_MeetsRequirements_Approval(newDialogEvent) then return false end
--         if not KvCE_QRY_CampNight_MeetsRequirements_Approval(newDialogEvent) then return false end
--         if not Osi.QRY_CampNight_MeetsRequirements_Partner(newDialogEvent) then return false end
--         if not Osi.QRY_CampNight_MeetsRequirements_Dating(newDialogEvent) then return false end
--         if not Osi.QRY_CampNight_MeetsRequirements_StartDating(newDialogEvent) then return false end
--         if not Osi.QRY_CampNight_MeetsRequirements_SameUser(newDialogEvent) then return false end
--     else
--         _DBG("KvCE_QRY_CampNight_MeetsRequirements() - in fallback")
--         if not Osi.QRY_CampNight_MeetsRequirements_IsInFallback(newDialogEvent) then return false end
--         if not Osi.QRY_FallbackCamp_CampNightMeetsRequirements(newDialogEvent) then return false end
--     end
--     return true
-- end

-- _DBG("==== KvCE END Reimplementations")
