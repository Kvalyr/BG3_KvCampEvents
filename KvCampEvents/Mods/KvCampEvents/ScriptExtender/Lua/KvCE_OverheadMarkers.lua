local _E = KVS.Output.Error
local _W = KVS.Output.Warning
local _I = KVS.Output.Info
local _DBG = KVS.Output.Debug
local DB = KVS.DB
local Utils = KVS.Utils
local Table = KVS.Table

-- ==================================================

local Cfg = Config
local RE = Reimplementations
local State = State

-- ==================================================
local Notifications = Notifications
-- ==================================================
local EFFECT_RESOURCES = {}
EFFECT_RESOURCES["RelationshipExclamation"] = "EFFECTRESOURCEGUID_VFX_UI_ExclamationMark_01_a3018cf0-3a25-06ee-206a-3dd079332d80"
EFFECT_RESOURCES["BhaalBlood"] = "VFX_Script_Bhaals_Blood_Droplets_Root_01_437788a3-d32b-1b63-26d7-0ae76c67daa2"
EFFECT_RESOURCES["Underdark_Mushroom_Circle"] = "VFX_Environment_Underdark_Mushroom_Circle_Green_01_4fc789aa-358b-6ca6-1906-c6d11f367948"
EFFECT_RESOURCES["Shar_Moon_Full"] = "VFX_Script_PUZ_Temple_Shar_Moon_Full_A_01_31b64b6c-918e-451f-91d5-bbda02959246"
EFFECT_RESOURCES["RiteOfThorns"] = "VFX_Script_DEN_RiteOfThorns_Idol_DruidRitual_01_2ebc09c6-1909-4bbc-84b2-66e44378eeb2"

-- Tags used from v0.4.3 onwards
local EFFECT_TAGS = {}
EFFECT_TAGS["Misc"] = "KvCE_Misc"
EFFECT_TAGS["CampEvents"] = "KvCE_CampEvents"
EFFECT_TAGS["RelationshipDialogs"] = "KvCE_RelationshipDialogs"

-- Tags used prior to v0.4.3
local EFFECT_TAGS_OLD = {}
EFFECT_TAGS_OLD[1] = "RelationshipMarker"

-- ==================================================
local DB_LoopEffect = {}
DB_LoopEffect.EFFECT_RESOURCES = EFFECT_RESOURCES
DB_LoopEffect.EFFECT_TAGS = EFFECT_TAGS
DB_LoopEffect.EFFECT_TAGS_OLD = EFFECT_TAGS_OLD
Notifications.DB_LoopEffect = DB_LoopEffect
-- ==================================================

-- Params can be nil to match any per Osiris query logic
function DB_LoopEffect.GetRows( character_uuid, loop_effect_handle, effectTag, effectResource )
    return Osi.DB_LoopEffect:Get(character_uuid, loop_effect_handle, effectTag, nil, effectResource, nil, nil)
end

function DB_LoopEffect.CountRows( character_uuid, loop_effect_handle, effectTag, effectResource )
    return Osi.DB_LoopEffect:Get(character_uuid, loop_effect_handle, effectTag, nil, effectResource, nil, nil)
end

-- Delete row matching params
-- Params can be nil to match any per Osiris query logic
function DB_LoopEffect.DeleteRow( character_uuid, loop_effect_handle, effectTag, effectResource )
    Osi.DB_LoopEffect:Delete(character_uuid, loop_effect_handle, effectTag, nil, effectResource, nil, nil)
end

function DB_LoopEffect.StopAndDeleteRow( character_uuid, loop_effect_handle, effectTag, effectResource )

    DB_LoopEffect.DeleteRow( character_uuid, loop_effect_handle, effectTag, effectResource )
end

function DB_LoopEffect.GetRows_WithEffectTag( effectTag )
    return DB.Get("DB_LoopEffect"):Get(
        nil, -- character_uuid
        nil, -- loop_effect_handle
        effect_tag or EFFECT_TAGS["CampEvents"], -- "RelationshipMarker"
        nil, -- "__ANY__"
        EFFECT_RESOURCES["RelationshipExclamation"], -- EffectResource
        nil, -- "Dummy_OverheadFX"
        nil -- 1.0
    )
end

-- function DB_LoopEffect.DeleteRow_WithEffectTag( character_uuid, effectTag )
--     DB_LoopEffect.DeleteRow(character_uuid, nil, effectTag, nil)
-- end

-- function DB_LoopEffect.DeleteRow_AnyExclamation( character_uuid, loop_effect_handle )
--     DB_LoopEffect.DeleteRow(character_uuid, loop_effect_handle, EFFECT_TAGS["CampEvents"], EFFECT_RESOURCES["RelationshipExclamation"])
-- end

function DB_LoopEffect.GetOverheadMarkerHandle( character_uuid, effectTag, effectResource )
    local rows = DB_LoopEffect.GetRows(character_uuid, nil, effectTag, effectResource)
    return rows and rows[1] and rows[1][2] or nil
end
function DB_LoopEffect.GetOverheadMarkerHandleCount( character_uuid, effectTag, effectResource )
    local rows = DB_LoopEffect.GetRows(character_uuid, nil, effectTag, effectResource)
    return rows and #rows or 0
end

-- Mods.KvCampEvents.Notifications.DB_LoopEffect.CleanupDuplicates(GetHostCharacter())
function DB_LoopEffect.CleanupDuplicates( character_uuid, effectTag, effectResource, includingFirst )
    local rows = DB_LoopEffect.GetRows(character_uuid, nil, effectTag, effectResource)
    local numRows = #rows
    if numRows > 1 then
        _W("Duplicates ( " .. numRows .. " ) in DB_LoopEffect for character, effectTag, effectResource:\n", character_uuid, effectTag, effectResource)
        for k, row in pairs(rows) do
            if includingFirst or k ~= 1 then
                local loop_effect_handle = row[2]
                _DBG("DB_LoopEffect.CleanupDuplicates() - Cleaning up duplicate:", character_uuid, loop_effect_handle, effectTag, effectResource)
                StopLoopEffect(loop_effect_handle)
                DB_LoopEffect.DeleteRow(character_uuid, loop_effect_handle, effectTag, effectResource)
            end
        end
        _W(
            "DB_LoopEffect.CleanupDuplicates() - Count after cleanup:",
                DB_LoopEffect.GetOverheadMarkerHandleCount(character_uuid, effectTag, effectResource)
        )

    end
end
