print("=================== KvCampEvents Server Bootstrap START")

PersistentVars = {}

-- KvShared
Ext.Require("KvShared/Main.lua")

-- KvCampEvents
CampEvents = {}
Ext.Require("KvCE_Main.lua")
Ext.Require("KvCE_Debugging.lua")
-- Ext.Require("KvCE_RelationshipDialogs.lua")

CampEvents.Init()

print("=================== KvCampEvents Server Bootstrap END")
