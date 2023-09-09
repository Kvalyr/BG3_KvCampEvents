local _E = KVS.Output.Error
local _W = KVS.Output.Warning
local _I = KVS.Output.Info
local _DBG = KVS.Output.Debug
local DB = KVS.DB
local utils = KVS.Utils

-- Osiris Procs and Queries reimplemented as Lua functions with modifications for our needs
-- Very WIP

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
    -- if not Osi.QRY_CampNight_MeetsRequirements(newDialogEvent) then
    -- Use Lua reimp
    if not Reimplementations.QRY_CampNight_MeetsRequirements(newDialogEvent) then
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

-- Calls to check for subcalls to DB_InCamp():
--[[
    QRY_CampNight_HasExclusivityProblem
        QRY_CampNight_HasEveningDialogs
            CLEAR

    QRY_CampNight_HasEveningReservedSpeakerProblem
        QRY_CampNight_HasEveningExclusiveDialogs
            CLEAR

    QRY_CampNight_HasSleepReservedSpeakerProblem
        CLEAR

    QRY_CampNight_HasMorningReservedSpeakerProblem
        QRY_CampNight_HasMorningExclusiveDialogs
            CLEAR

    QRY_CampNight_MeetsRequirements
        QRY_CampNight_MeetsRequirements_IsInFallback
            CLEAR

        QRY_CampNight_MeetsRequirements_Flags
            CLEAR

        QRY_CampNight_MeetsRequirements_Approval
            HAS DB_InCamp

        QRY_CampNight_MeetsRequirements_Partner
            HAS DB_InCamp

        QRY_CampNight_MeetsRequirements_Dating
            HAS DB_InCamp

        QRY_CampNight_MeetsRequirements_StartDating
            HAS DB_InCamp

        QRY_CampNight_MeetsRequirements_SameUser
            CLEAR

        QRY_FallbackCamp_CampNightMeetsRequirements
            CLEAR




    QRY_CampNight_AllSpeakersMissing
        QRY_CampNight_AtLeastOneCompanionAvailableForCRD
            HAS DB_InCamp
            QRY_SpeakerIsAvailable
                QRY_SpeakerIsInDialogRange
                    CLEAR
                QRY_SpeakerIsInCurrentLevel
                    CLEAR

        QRY_CampNight_AtLeastOneAvatarAvailableForSoloDream
            HAS DB_InCamp
        QRY_CampNight_AtLeastOneCompanionAvailableForRomanceMoment
            HAS DB_InCamp

--]]--


function Reimplementations.QRY_CampNight_MeetsRequirements(newDialogEvent)
    -- QRY QRY_CampNight_MeetsRequirements((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
    --     AND NOT QRY_CampNight_MeetsRequirements_IsInFallback(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_CampNight_MeetsRequirements_Flags(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_CampNight_MeetsRequirements_Approval(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_CampNight_MeetsRequirements_Partner(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_CampNight_MeetsRequirements_Dating(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_CampNight_MeetsRequirements_StartDating(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_CampNight_MeetsRequirements_SameUser(_Var1, _Var1, _Var1, _Var1, _Var1)
    -- THEN
    --     DB_NOOP(1);

    -- QRY QRY_CampNight_MeetsRequirements((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
    --     AND QRY_CampNight_MeetsRequirements_IsInFallback(_Var1, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_FallbackCamp_CampNightMeetsRequirements(_Var1, _Var1, _Var1, _Var1, _Var1)
    -- THEN
    --     DB_NOOP(1);

    -- Alternate_QRY_CampNight_MeetsRequirements(newDialogEvent) -- debug

    if not Osi.QRY_CampNight_MeetsRequirements_IsInFallback(newDialogEvent) then
        -- _DBG("QRY_CampNight_MeetsRequirements() - NOT in fallback")
        if not Osi.QRY_CampNight_MeetsRequirements_Flags(newDialogEvent) then return false end

        -- Use lua reimplementation that skips DB_InCamp checks
        if not Osi.QRY_CampNight_MeetsRequirements_Approval(newDialogEvent) then return false end
        -- if not Reimplementations.QRY_CampNight_MeetsRequirements_Approval(newDialogEvent) then return false end

        if not Osi.QRY_CampNight_MeetsRequirements_Partner(newDialogEvent) then return false end
        if not Osi.QRY_CampNight_MeetsRequirements_Dating(newDialogEvent) then return false end
        if not Osi.QRY_CampNight_MeetsRequirements_StartDating(newDialogEvent) then return false end
        if not Osi.QRY_CampNight_MeetsRequirements_SameUser(newDialogEvent) then return false end
    else
        -- _DBG("QRY_CampNight_MeetsRequirements() - in fallback")
        if not Osi.QRY_CampNight_MeetsRequirements_IsInFallback(newDialogEvent) then return false end
        if not Osi.QRY_FallbackCamp_CampNightMeetsRequirements(newDialogEvent) then return false end
    end
    return true
end

-- function Reimplementations.QRY_CampNight_MeetsRequirements_IsInFallback(newDialogEvent)

--     -- FLAG, string, int, int
--     -- local row_DB_CampNight_ForceOnLevelSwap = Osi.DB_CampNight_ForceOnLevelSwap(newDialogEvent, _Var2, _, 1, _Var1) -- _Var2
--     -- local var2 = row_DB_CampNight_ForceOnLevelSwap[2]

--     -- Osi.DB_FallbackCamp_InCamp(var2)

--     -- QRY QRY_CampNight_MeetsRequirements_IsInFallback((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
--     --     AND DB_CampNight_ForceOnLevelSwap(_Var1, _Var2, _, 1, _Var1)
--     --     AND DB_FallbackCamp_InCamp(_Var2, _Var1, _Var1, _Var1, _Var1)
--     -- THEN
--     --     DB_NOOP(1);
-- end

-- TODO: Reimplementations without DB_InCamp() by priority
-- QRY_CampNight_MeetsRequirements      DONE
-- QRY_CampNight_MeetsRequirements_IsInFallback
-- QRY_CampNight_MeetsRequirements_Approval     DONE
-- QRY_CampNight_MeetsRequirements_Partner
-- QRY_CampNight_MeetsRequirements_Dating
-- QRY_CampNight_MeetsRequirements_StartDating
-- QRY_CampNight_AllSpeakersMissing
-- QRY_CampNight_AtLeastOneCompanionAvailableForCRD
-- QRY_CampNight_AtLeastOneAvatarAvailableForSoloDream
-- QRY_CampNight_AtLeastOneCompanionAvailableForRomanceMoment


-- TODO: Reimplementations for multi-event
-- PROC_CampNight_StartSelected
-- PROC_CampNight_StartSelected_CRDs



-- QRY QRY_CampNight_MeetsRequirements_Partner((FLAG)_Var1, (FLAG)_Var1, (FLAG)_Var1, (FLAG)_Var1, (FLAG)_Var1)
--     AND DB_CampNight_Requirement_Partner(_Var1, _Var2, _Var1, _Var1, _Var1)
--     AND DB_ORI_Partnered(_Var3, _Var2, _Var1, _Var1, _Var1)
--     AND DB_InCamp(_Var3, _Var1, _Var1, _Var1, _Var1)
--     AND NOT QRY_PreventMPDialogue(_Var2, _Var3, _Var1, _Var1, _Var1)
-- THEN
--     DB_NOOP(1);


-- Reimplmements QRY_CampNight_MeetsRequirements_Approval in Lua without checking DB_InCamp
function Reimplementations.QRY_CampNight_MeetsRequirements_Approval(newDialogEvent)
    local reqApprovalTable = Osi.DB_CampNight_Requirement_Approval:Get(newDialogEvent,nil,nil)
    if #reqApprovalTable < 1 then return end
    reqApprovalTable = reqApprovalTable[1]
    local companionUUID = reqApprovalTable[2] -- _Var2
    local requiredApprovalRating = reqApprovalTable[3] -- _Var3
    local avatar = Osi.DB_Avatars:Get(nil)[1][1] -- _Var4 -- Utils.GetPlayer() is probably fine for our purposes

    -- if not DB.Bool("DB_InCamp", companionUUID) then return end -- Skip this check, as we want results regardless of player being in camp or not
    -- if not DB.Bool("DB_InCamp", avatar) then return end -- Skip this check, as we want results regardless of player being in camp or not

    if Osi.QRY_PreventMPDialogue(companionUUID, avatar) then return end

    local currentApprovalRating = Osi.GetApprovalRating(companionUUID, avatar) -- _Var5
    return currentApprovalRating >= requiredApprovalRating

    -- QRY QRY_CampNight_MeetsRequirements_Approval((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
    --     AND GetApprovalRating(_Var2, _Var4, _Var5, _Var1, _Var1)
    --     AND _Var5 >= _Var3
    -- THEN
    --     DB_NOOP(1);

    -- QRY QRY_CampNight_MeetsRequirements_Approval((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
    --     AND DB_CampNight_Requirement_Approval(_Var1, _Var2, _Var3, _Var1, _Var1)
    --     AND DB_InCamp(_Var2, _Var1, _Var1, _Var1, _Var1)
    --     AND NOT DB_Avatars(_Var2, _Var1, _Var1, _Var1, _Var1)
    --     AND DB_Avatars(_Var4, _Var1, _Var1, _Var1, _Var1)
    --     AND DB_InCamp(_Var4, _Var1, _Var1, _Var1, _Var1)
    --     AND NOT QRY_PreventMPDialogue(_Var2, _Var4, _Var1, _Var1, _Var1)
    --     AND GetApprovalRating(_Var2, _Var4, _Var5, _Var1, _Var1)
    --     AND _Var5 >= _Var3
    -- THEN
    --     DB_NOOP(1);
end


-- function Reimplementations.QRY_CampNight_AllSpeakersMissing(dialogEvent)

--     -- Flag, DialogResource
--     -- AND NOT DB_CampNight_CFM(_Var1, _, _Var1, _Var1, _Var1)
--     if DB.Bool("DB_CampNight_CFM", dialogEvent, nil) then return end

--     -- AND NOT DB_CampNight_IVB(_Var1, _, _, _Var1, _Var1)
--     -- AND NOT DB_CampNight_SCO(_Var1, _, _Var1, _Var1, _Var1)
--     -- AND NOT DB_CampNight_AvatarDream(_Var1, _, _Var1, _Var1, _Var1)
--     -- AND NOT DB_CampNight_MorningIVB(_Var1, _, _, _Var1, _Var1)
--     -- AND NOT DB_CampNight_MorningCFM(_Var1, _, _Var1, _Var1, _Var1)
--     -- AND NOT QRY_CampNight_AtLeastOneCompanionAvailableForCRD(_Var1, _Var1, _Var1, _Var1, _Var1)
--     if Reimplementations.QRY_CampNight_AtLeastOneCompanionAvailableForCRD(dialogEvent) then return end

--     -- AND NOT QRY_CampNight_AtLeastOneAvatarAvailableForSoloDream(_Var1, _Var1, _Var1, _Var1, _Var1)
--     -- AND NOT QRY_CampNight_AtLeastOneCompanionAvailableForRo


-- -- QRY QRY_CampNight_AllSpeakersMissing((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
-- --     AND NOT DB_CampNight_CFM(_Var1, _, _Var1, _Var1, _Var1)
-- --     AND NOT DB_CampNight_IVB(_Var1, _, _, _Var1, _Var1)
-- --     AND NOT DB_CampNight_SCO(_Var1, _, _Var1, _Var1, _Var1)
-- --     AND NOT DB_CampNight_AvatarDream(_Var1, _, _Var1, _Var1, _Var1)
-- --     AND NOT DB_CampNight_MorningIVB(_Var1, _, _, _Var1, _Var1)
-- --     AND NOT DB_CampNight_MorningCFM(_Var1, _, _Var1, _Var1, _Var1)
-- --     AND NOT QRY_CampNight_AtLeastOneCompanionAvailableForCRD(_Var1, _Var1, _Var1, _Var1, _Var1)

-- --     AND NOT QRY_CampNight_AtLeastOneAvatarAvailableForSoloDream(_Var1, _Var1, _Var1, _Var1, _Var1)
-- --     AND NOT QRY_CampNight_AtLeastOneCompanionAvailableForRomanceMoment(_Var1, _Var1, _Var1, _Var1, _Var1)
-- -- THEN
-- --     DB_NOOP(1);
-- end


function Reimplementations.QRY_CampNight_AtLeastOneCompanionAvailableForCRD(dialogEvent)

    -- _Var1 : dialogEvent
    -- _Var2 : Character

    --     AND DB_CampNight_CRD(_Var1, _Var2, _, _, _Var1)
    local row_DB_CampNight_CRD = Osi.DB_CampNight_CRD:Get(dialogEvent)
    local character = row_DB_CampNight_CRD[1] and row_DB_CampNight_CRD[1][2]

    -- AND NOT DB_Avatars(_Var2, _Var1, _Var1, _Var1, _Var1)
    if DB.Bool("DB_Avatars", character) then return end

    -- AND DB_InCamp(_Var2, _Var1, _Var1, _Var1, _Var1)
    -- Skip

    -- AND NOT DB_CantTalk(_Var2, _Var1, _Var1, _Var1, _Var1)
    if DB.Bool("DB_CantTalk", character) then return end


    -- AND QRY_SpeakerIsAvailable(_Var2, _Var1, _Var1, _Var1, _Var1)
    if not Osi.QRY_SpeakerIsAvailable(character) then return end

    return true

    -- QRY QRY_CampNight_AtLeastOneCompanionAvailableForCRD((GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1, (GUIDSTRING)_Var1)
    --     AND DB_CampNight_CRD(_Var1, _Var2, _, _, _Var1)
    --     AND NOT DB_Avatars(_Var2, _Var1, _Var1, _Var1, _Var1)
    --     AND DB_InCamp(_Var2, _Var1, _Var1, _Var1, _Var1)
    --     AND NOT DB_CantTalk(_Var2, _Var1, _Var1, _Var1, _Var1)
    --     AND QRY_SpeakerIsAvailable(_Var2, _Var1, _Var1, _Var1, _Var1)
    -- THEN
    --     DB_NOOP(1);
end


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


-- _DBG("==== KvCE END Reimplementations")
