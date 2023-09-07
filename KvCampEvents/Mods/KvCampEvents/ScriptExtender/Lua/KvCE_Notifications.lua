local _E = KVS.Output.Error
local _W = KVS.Output.Warning
local _I = KVS.Output.Info
local _DBG = KVS.Output.Debug
local DB = KVS.DB
local Utils = KVS.Utils
local Table = KVS.Table

-- _DBG("======== KvCE START Notifications")

local Cfg = Config
local RE = Reimplementations
local State = State

-- ==================================================
-- ==================================================

-- ================================================================
-- Add exclamation mark loopeffect on character (Camp Night Events)
function Notifications.AddExclamationOverCharacter_CampNightEvents( character_uuid )
    if not Cfg.GetValue("Notifications.CNE_UseExclamation") then
        return
    end
    return Notifications.AddExclamationOverCharacter(character_uuid)
end

-- ================================================================
-- Add exclamation mark loopeffect on character (Relationship Dialogs)
function Notifications.AddExclamationOverCharacter_RelationshipDialogues( character_uuid )
    if not Cfg.GetValue("Notifications.RD_UseExclamation") then
        return
    end
    return Notifications.AddExclamationOverCharacter(character_uuid)
end

-- ================================================================
-- Add exclamation mark loopeffect on character
function Notifications.AddExclamationOverCharacter( character_uuid )
    if not Cfg.GetValue("Notifications.CNE_UseExclamation") then
        return
    end
    if not character_uuid then
        character_uuid = Utils.GetPlayer()
    end

    local existingLoopEffectHandler = Notifications.GetExclamationLoopEffectHandle()
    if not existingLoopEffectHandler then
        Osi.PROC_LoopEffect(
            "EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80", character_uuid, "RelationshipMarker", "__ANY__",
                "Dummy_OverheadFX"
        );
    end
end

-- ================================================================
-- Try to get the handle for any existing exclamation mark loopeffect on character
function Notifications.GetExclamationLoopEffectHandle( character_uuid )
    local loopEffectTable = Osi.DB_LoopEffect:Get(
        character_uuid, nil, "RelationshipMarker", nil, "EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80",
            "Dummy_OverheadFX", nil
    )

    -- TODO: This is messy
    if not loopEffectTable then
        -- _DBG("GetExclamationLoopEffectHandle", "not loopEffectTable") -- DEBUG
        return
    end
    loopEffectTable = loopEffectTable[1]
    if not loopEffectTable then
        -- _DBG("GetExclamationLoopEffectHandle", "not loopEffectTable[1]") -- DEBUG
        return
    end
    local loop_effect_handle = loopEffectTable[2]
    if not loop_effect_handle then
        -- _DBG("GetExclamationLoopEffectHandle", "not loop_effect_handle") -- DEBUG
        return
    end

    return loop_effect_handle
end

-- ================================================================
-- Remove any exclamation mark loopeffect on character
function Notifications.RemoveExclamationOverCharacter( character_uuid, loop_effect_handle )
    if not character_uuid then
        character_uuid = Utils.GetPlayer()
    end

    if not loop_effect_handle then
        loop_effect_handle = Notifications.GetExclamationLoopEffectHandle(character_uuid)
    end

    if loop_effect_handle ~= nil then
        Osi.PROC_StopLoopEffect(loop_effect_handle)

        Osi.DB_LoopEffect:Delete(
            character_uuid, loop_effect_handle, "RelationshipMarker", "__ANY__",
                "EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80", "Dummy_OverheadFX", 1.0
        )
    end

end

function Notifications.AddStatusEffect_CampNightEvents( character_uuid )
    if not Cfg.GetValue("Notifications.CNE_UseStatus") then
        return
    end
    Osi.ApplyStatus(character_uuid, "KvCE_Notification_CampNightEvents_NoOverhead", -1)
end

function Notifications.AddStatusEffect_RelationshipDialogues( character_uuid )
    if not Cfg.GetValue("Notifications.RD_UseStatus") then
        return
    end
    Osi.ApplyStatus(character_uuid, "KvCE_Notification_RelationshipDialogues_NoOverhead", -1)
end

function Notifications.RemoveStatusEffect_CampNightEvents( character_uuid )
    Osi.RemoveStatus(character_uuid, "KvCampEvents_Notification_CampNightEvents")
    Osi.RemoveStatus(character_uuid, "KvCE_Notification_CampNightEvents_NoOverhead")
end

function Notifications.RemoveStatusEffect_RelationshipDialogues( character_uuid )
    Osi.RemoveStatus(character_uuid, "KvCampEvents_Notification_RelationshipDialogues")
    Osi.RemoveStatus(character_uuid, "KvCE_Notification_RelationshipDialogues_NoOverhead")
end

-- _DBG("==== KvCE END Notifications")

-- ==================================================
-- Convenience Functions
-- Mods.KvCampEvents.Notifications.Cfg_Enable_OverheadExclamations()
-- Mods.KvCampEvents.Notifications.Cfg_Disable_OverheadExclamations()
-- Mods.KvCampEvents.Notifications.Cfg_Enable_Statuses()
-- Mods.KvCampEvents.Notifications.Cfg_Disable_Statuses()
function Notifications.Cfg_Enable_OverheadExclamations()
    Config.SetValue("Notifications.CNE_UseExclamation", true)
    Config.SetValue("Notifications.RD_UseExclamation", true)
end
function Notifications.Cfg_Disable_OverheadExclamations()
    Config.SetValue("Notifications.CNE_UseExclamation", false)
    Config.SetValue("Notifications.RD_UseExclamation", false)
end
function Notifications.Cfg_Enable_Statuses()
    Config.SetValue("Notifications.CNE_UseStatus", true)
    Config.SetValue("Notifications.RD_UseStatus", true)
end
function Notifications.Cfg_Disable_Statuses()
    Config.SetValue("Notifications.CNE_UseStatus", false)
    Config.SetValue("Notifications.RD_UseStatus", false)
end
-- ==================================================
