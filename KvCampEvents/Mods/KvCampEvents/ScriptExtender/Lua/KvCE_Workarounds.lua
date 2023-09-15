local _E = KVS.Output.Error
local _W = KVS.Output.Warning
local _I = KVS.Output.Info
local _DBG = KVS.Output.Debug
local DB = KVS.DB
local Utils = KVS.Utils
local Table = KVS.Table
local Config = KVS.Config

local CampEvents = CampEvents

-- ==================================================
local Workarounds = Workarounds
-- ==================================================


-- ==================================================
-- Minthara Loop Workaround
-- TODO: This is probably caused by DB_InCamp manipulations in v0.4.0 -- Verify if still necessary
local minthara = "S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b"

local moonrise_interior = "S_MOO_MainFloorInterior_SUB_429a55cc-58d2-4469-9577-852131e1fff3"
local moonrise_tower = "S_MOO_MoonriseTower_SUB_14187ad9-cf83-44f9-81bf-bb46cb4cd8e6"
local moonrise_prison = "S_MOO_Prison_SUB_b262cbea-f40c-47da-9f34-ba8ce5bf782b"
local moonrise_docks = "S_MOO_Docks_SUB_b4608370-46b8-4ba3-a3e7-192a6aa509ee"
local moonrise_upperfloor = "S_MOO_UpperFloorInterior_SUB_93c522d3-04c4-4f71-a1dc-043478c51301"
-- local moonrise_roof = "S_MOO_Roof_SUB_77c94e75-2924-4ca3-b7bd-d631b18d6c73"
-- local moonrise_oubliette = "S_MOO_Oubliette_SUB_c6f54de0-1c8f-4cf8-bcf9-b13c8f53b05b"
-- local moonrise_kitchen = "S_MOO_Kitchen_SUB_b50b8553-0064-41d0-8595-266f69e35c33"

local minthara_checkregions = {}
minthara_checkregions[moonrise_interior] = true
minthara_checkregions[moonrise_tower] = true
minthara_checkregions[moonrise_prison] = true
minthara_checkregions[moonrise_docks] = true
minthara_checkregions[moonrise_upperfloor] = true
-- minthara_checkregions[moonrise_kitchen] = true

local function OnlyIfPlayerOrMintharaNotInMoonrise()
    -- Not needed if Minthara already recruited
    if (not Config.GetValue("Workarounds.MintharaAtMoonrise")) or DB.Bool("DB_PartOfTheTeam", minthara) then
        return true
    end

    local player = Utils.GetPlayer()
    local player_subregion = Utils.GetSubregionForCharacter(player)
    local minthara_subregion = Utils.GetSubregionForCharacter(minthara)

    if minthara_checkregions[player_subregion] then
        _DBG("Blocking due to player in Moonrise subregion:", player_subregion)
        return false
    end
    if minthara_checkregions[minthara_subregion] then
        _DBG("Blocking due to Minthara in Moonrise subregion:", minthara_subregion)
        return false
    end

    return true
end

CampEvents.AddProceedCheck("Minthara_NotMoonrise", OnlyIfPlayerOrMintharaNotInMoonrise)


-- No followers workaround provided by Elys @ NexusMods ( https://www.nexusmods.com/users/532478 )
local function OnlyIfNoFollowersAround()
    local partyFollowers = DB.Flatten(Osi.DB_PartyFollowers:Get(nil))
    if Table.IsEmpty(partyFollowers) then
        return true
    end

    return false
end

CampEvents.AddProceedCheck("NoFollowersAround", OnlyIfNoFollowersAround)
