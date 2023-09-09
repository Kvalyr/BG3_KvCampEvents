-- _P("=================== KvCampEvents Server Bootstrap START")

-- PersistentVars = {}


-- Preconfigure KvShared
KVS = {}
KVS.modTableKey = "KvCampEvents"
KVS.modPrefix = "KvCE"
KVS.modVersion = {major="0.4", minor="3"}

-- KvShared
Ext.Require("KvShared/_Main.lua")

-- KvCampEvents
CampEvents = {}
Misc = {}
State = {}
Notifications = {}
Workarounds = {}

Ext.Require("KvCE_Misc.lua")
Ext.Require("KvCE_Config.lua")
Ext.Require("KvCE_OverheadMarkers.lua")
Ext.Require("KvCE_Notifications.lua")
Ext.Require("KvCE_Reimplementations.lua")
Ext.Require("KvCE_State.lua")
Ext.Require("KvCE_Main.lua")
Ext.Require("KvCE_Workarounds.lua")
-- Ext.Require("KvCE_Debugging.lua")
-- Ext.Require("KvCE_RelationshipDialogs.lua")

local kvce_initDone = false

local function LevelGameplayStarted()
    if kvce_initDone then return end
    -- _P("KvCE - LevelGameplayStarted()") -- DEBUG

    State.Init()
    CampEvents.Init()

    kvce_initDone = true
    KVS.Output.Info("Log Level at:", KVS.Output.GetLogLevel(), "("..KVS.Output.GetLogLevelAsStr()..")")
end

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", LevelGameplayStarted)
