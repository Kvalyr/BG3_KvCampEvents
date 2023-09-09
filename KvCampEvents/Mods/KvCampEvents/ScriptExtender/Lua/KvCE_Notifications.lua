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
local Notifications = Notifications
local DB_LoopEffect = Notifications.DB_LoopEffect

local EFFECT_RESOURCES = DB_LoopEffect.EFFECT_RESOURCES
local EFFECT_TAGS = DB_LoopEffect.EFFECT_TAGS
local EFFECT_TAGS_OLD = DB_LoopEffect.EFFECT_TAGS_OLD

-- ==================================================

-- ================================================================
-- Add exclamation mark loopeffect on character (Camp Night Events)
function Notifications.ExclamationOverCharacter_Add_CNE( character_uuid )
    if not Cfg.GetValue("Notifications.CNE_UseExclamation") then
        return
    end
    return Notifications.CharacterOverheadMarker_Add(character_uuid, EFFECT_RESOURCES["RelationshipExclamation"], EFFECT_TAGS["CampEvents"], false)
end
-- Remove exclamation mark loopeffect from character (Camp Night Events)
function Notifications.ExclamationOverCharacter_Remove_CNE( character_uuid )
    return Notifications.CharacterOverheadMarker_Remove(character_uuid, EFFECT_TAGS["CampEvents"])
end

-- ================================================================
-- Add exclamation mark loopeffect on character (Relationship Dialogs)
function Notifications.ExclamationOverCharacter_Add_RD( character_uuid )
    if not Cfg.GetValue("Notifications.RD_UseExclamation") then
        return
    end
    return Notifications.CharacterOverheadMarker_Add(
        character_uuid, EFFECT_RESOURCES["RelationshipExclamation"], EFFECT_TAGS["RelationshipDialogs"], false
    )
end
-- Remove exclamation mark loopeffect from character (Relationship Dialogs)
function Notifications.ExclamationOverCharacter_Remove_RD( character_uuid )
    return Notifications.CharacterOverheadMarker_Remove(character_uuid, EFFECT_TAGS["RelationshipDialogs"])
end

-- ================================================================
-- Add exclamation mark loopeffect on character
-- Mods.KvCampEvents.Notifications.CharacterOverheadMarker_Add( GetHostCharacter(), "VFX_Script_Bhaals_Blood_Droplets_Root_01_437788a3-d32b-1b63-26d7-0ae76c67daa2", "KvCE_Misc", false )
-- Mods.KvCampEvents.Notifications.CharacterOverheadMarker_Add( "S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12", true )
function Notifications.CharacterOverheadMarker_Add( character_uuid, effectResource, effectTag, allowNonPlayer )
    if not Cfg.GetValue("Notifications.CNE_UseExclamation") then
        return
    end
    Utils.assertIsStr(character_uuid, "Notifications.CharacterOverheadMarker_Remove() called with invalid character_uuid")
    Utils.assertIsStr(effectResource, "N.CharacterOverheadMarker_Add() - Call attempted with invalid effectResource")
    Utils.assertIsStr(effectTag, "N.CharacterOverheadMarker_Add() - Call attempted with invalid effectTag")

    -- _DBG("Notifications.CharacterOverheadMarker_Add()\n", character_uuid, effectResource, effectTag)

    if not Utils.IsUUIDPlayer(character_uuid) then
        Utils.assertNotNil(
            allowNonPlayer, "N.CharacterOverheadMarker_Add() - Call attempted on non-player UUID with nil allowNonPlayer: " .. character_uuid
        )

        _W("N.CharacterOverheadMarker_Add() - Call on non-player UUID:", character_uuid)
    end

    local existingLoopEffectHandler = DB_LoopEffect.GetOverheadMarkerHandle(character_uuid, effectTag, effectResource)
    if not existingLoopEffectHandler then
        Osi.PROC_LoopEffect(effectResource, character_uuid, effectTag, "__ANY__", "Dummy_OverheadFX");
    end
end

-- ================================================================
-- Remove any exclamation mark loopeffect on character
-- Mods.KvCampEvents.Notifications.RemoveExclamationOverCharacter( character_uuid, loop_effect_handle )
-- function Notifications.RemoveExclamationOverCharacter( character_uuid, loop_effect_handle )
-- function Notifications.CharacterOverheadMarker_Remove( character_uuid, loop_effect_handle )
function Notifications.CharacterOverheadMarker_Remove( character_uuid, effectTag )
    -- TODO: by effectTag instead of by handle
    Utils.assertIsStr(character_uuid, "Notifications.CharacterOverheadMarker_Remove() called with invalid character_uuid")

    -- Need to get all rows and call StopLoopEffect on each; can't just delete all matching in the DB
    local rows = DB_LoopEffect.GetRows(character_uuid, loop_effect_handle, effectTag, effectResource)
    for k, v in pairs(rows) do
        local loop_effect_handle = v[2]
        StopLoopEffect(loop_effect_handle)
        -- DB_LoopEffect.DeleteRow( character_uuid, handle, effectTag, nil )
    end

    -- Now we can safely delete all matching by character and tag
    DB_LoopEffect.DeleteRow(character_uuid, nil, effectTag, nil)
end

-- ==================================================

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

-- ==================================================
-- Convenience Functions for Users
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

function Notifications.CleanupOldVersions()
    _I("Checking for leftovers from older versions and running cleanup..")
    Notifications.CleanupNonPlayer()

    local player = Utils.GetPlayer()
    local effectResource = nil -- Any
    for key, effectTag in pairs(EFFECT_TAGS) do
        Notifications.DB_LoopEffect.CleanupDuplicates(player, effectTag, effectResource, true)
    end
    for key, effectTag in pairs(EFFECT_TAGS_OLD) do
        Notifications.DB_LoopEffect.CleanupDuplicates(player, effectTag, effectResource, true)
    end
    _DBG("Notifications.CleanupOldVersions() - Done")
end

-- Mods.KvCampEvents.Notifications.CleanupNonPlayer()
function Notifications.CleanupNonPlayer()
    -- v0.4.x Onwards:
    local exclamationEffectsFromDB_current = DB_LoopEffect.GetRows_WithEffectTag(EFFECT_TAGS["CampEvents"])
    local numRows_current = #exclamationEffectsFromDB_current
    -- if numRows_current > 0 then
    --     _D(exclamationEffectsFromDB_current)
    -- end

    local nonPlayerRows = {}

    for _, row in pairs(exclamationEffectsFromDB_current) do
        local character_uuid = row[1]
        if not Utils.IsUUIDPlayer(character_uuid) then
            _W("Non-player UUID with exclamation LoopEffect found: ", character_uuid)
            table.insert(nonPlayerRows, row)
        end
    end

    -- Cleanup of exclamations from versions older than v0.4.x
    for _, v in pairs(EFFECT_TAGS_OLD) do
        local exclamationEffectsFromDB_old = DB_LoopEffect.GetRows_WithEffectTag(v)
        local numRows_old = #exclamationEffectsFromDB_old
        if numRows_old > 0 then
            _W("Notifications.CleanupNonPlayer() - Old Markers:")
            _D(exclamationEffectsFromDB_old)
        end
    end
end

-- Mods.KvCampEvents.Notifications.DumpInfo()
function Notifications.DumpInfo()
    _I("======== ======== Notifications.DumpInfo() ======== ========")

    _I("======== Exclamation DB_LoopEffect handlers on characters ========")
    local origins = DB.GetRowsFlattened("DB_Origins")
    for _, v in pairs(origins) do
        local effectHandle = DB_LoopEffect.GetOverheadMarkerHandle(v)
        _I("N.DumpInfo() - Origin: ", v, "LoopEffect Handle (if any):", tostring(effectHandle))
    end

    local playerUUID = Utils.GetPlayer()
    local playerEffectHandle = DB_LoopEffect.GetOverheadMarkerHandle(playerUUID)
    _I("N.DumpInfo() - Player: ", playerUUID, "LoopEffect Handle (if any):", tostring(playerEffectHandle))

    _I("======== Exclamation DB_LoopEffects in DB ========")
    local exclamationEffectsFromDB = DB.Get("DB_LoopEffect"):Get(
        nil, -- character_uuid
        nil, -- loop_effect_handle
        nil, -- "RelationshipMarker", -- "RelationshipMarker"
        nil, -- "__ANY__"
        EFFECT_RESOURCES["RelationshipExclamation"], -- EffectResource
        nil, -- "Dummy_OverheadFX"
        nil -- 1.0 -- Scale?
    )
    for k, v in pairs(exclamationEffectsFromDB) do
        -- local character_uuid = v[1]
        -- local loop_effect_handle = v[2]
        _I("DB_LoopEffect Row: ", k, table.unpack(v))
    end
end

-- Mods.KvCampEvents.Notifications.ForceCleanup()
function Notifications.ForceCleanup()
    Notifications.CleanupOldVersions()

    -- TODO: Add overhead marker to all origins/companions to force it to be current
    -- TODO: Remove overhead marker from all origins/companions
    local exclamationEffectsFromDB = DB.Get("DB_LoopEffect"):Get(
        nil, -- character_uuid
        nil, -- loop_effect_handle
        nil, -- "RelationshipMarker", -- "RelationshipMarker"
        nil, -- "__ANY__"
        EFFECT_RESOURCES["RelationshipExclamation"], -- EffectResource
        nil, -- "Dummy_OverheadFX"
        nil -- 1.0 -- Scale?
    )
    -- Call StopLoopEffect on all exclamation effect handles
    for k, v in pairs(exclamationEffectsFromDB) do
        local loop_effect_handle = v[2]
        _I("DB_LoopEffect Row: ", k, table.unpack(v))
        StopLoopEffect(loop_effect_handle)
    end
    -- Delete all rows matching exclamation effect resource
    Osi.DB_LoopEffect:Delete(nil, nil, nil, nil, EFFECT_RESOURCES["RelationshipExclamation"], nil, nil)

    _I("Notifications.ForceCleanup() - Result:")
    Notifications.DumpInfo()
end
