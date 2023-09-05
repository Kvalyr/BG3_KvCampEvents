_P("=================== KvCampEvents Server Bootstrap START")

PersistentVars = {}

-- KvShared
Ext.Require("KvShared/Main.lua")
KVS.modPrefix = "KvCE"
KVS.modVersion = "0.2"

-- KvCampEvents
CampEvents = {}

Ext.Require("KvCE_Main.lua")
Ext.Require("KvCE_Debugging.lua")
-- Ext.Require("KvCE_RelationshipDialogs.lua")

CampEvents.Init()

KVS.Output.Info("=================== KvCampEvents Server Bootstrap END")
