-- _P("=================== KvCampEvents Server Bootstrap START")

-- PersistentVars = {}

-- Preconfigure KvShared
KVS = {}
KVS.modTableKey = "KvCampEvents"
KVS.modPrefix = "KvCE"
KVS.modVersion = "0.4"

-- KvShared
Ext.Require("KvShared/_Main.lua")

-- KvCampEvents
CampEvents = {}
Misc = {}
State = {}
Notifications = {}

Ext.Require("KvCE_Misc.lua")
Ext.Require("KvCE_Config.lua")
Ext.Require("KvCE_Notifications.lua")
Ext.Require("KvCE_Reimplementations.lua")
Ext.Require("KvCE_State.lua")
Ext.Require("KvCE_Main.lua")
-- Ext.Require("KvCE_Debugging.lua")
-- Ext.Require("KvCE_RelationshipDialogs.lua")

local kvce_initDone = false

local function LevelGameplayStarted()
    if kvce_initDone then return end
    -- _P("KvCE - LevelGameplayStarted()") -- DEBUG

    State.Init()
    CampEvents.Init()

    kvce_initDone = true
end

-- Ext.Events.SessionLoaded:Subscribe(SessionLoaded, {Priority = 100, Once = true})

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", LevelGameplayStarted)
-- Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", Mods.KvCampEvents.Misc.DumpPersistentVars) -- DEBUG

-- _P("=================== KvCampEvents Server Bootstrap END")
