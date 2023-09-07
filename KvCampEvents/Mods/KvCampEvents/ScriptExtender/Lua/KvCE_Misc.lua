local _E = KVS.Output.Error
local _W = KVS.Output.Warning
local _I = KVS.Output.Info
local _DBG = KVS.Output.Debug
local DB = KVS.DB
local Utils = KVS.Utils
local Table = KVS.Table

-- _DBG("======== KvCE START Notifications")

local RE = Reimplementations
local State = State

-- ==================================================
-- ==================================================

function Misc.DumpState()
    _D(Mods.KvCampEvents.PersistentVars)
end

function Misc.DumpConfig()
    _D(Mods.KvCampEvents.PersistentVars)
end

-- Mods.KvCampEvents.Misc.DumpPersistentVars()
function Misc.DumpPersistentVars(...)
    -- _P("Mods.KvCampEvents.Misc.DumpPersistentVars()", ...)
    _D(Mods.KvCampEvents.PersistentVars)
end


-- Mods.KvCampEvents.Misc.DumpVars()
function Misc.DumpVars()
    Misc.DumpState()
end

-- Mods.KvCampEvents.Misc.TestPersist()
function Misc.TestPersist()

    -- Mods.KvCampEvents.KVS.Persist.JSON_LoadPVars()
    -- Mods.KvCampEvents.KVS.Persist.JSON_WritePVars(Mods.KvCampEvents.KVS.Persist.GetPersistentVarsTableForMod(true))
    -- Mods.KvCampEvents.KVS.JSON.LuaTableFromFile(Mods.KvCampEvents.KVS.Persist.JSONFilePath)

    PersistentVars["derp"] = "herp"
    Mods.KvCampEvents.PersistentVars["derp"] = "herp"
    Mods.KvCampEvents.KVS.Output.SetLogLevel(3)
    _D(Mods.KvCampEvents.PersistentVars)
end

-- _D(Osi.DB_Avatars:Get(), 1)

-- _DBG("==== KvCE END Notifications")
