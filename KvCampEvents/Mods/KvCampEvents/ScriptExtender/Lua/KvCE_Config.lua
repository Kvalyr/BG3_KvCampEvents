local _E = KVS.Output.Error
local _W = KVS.Output.Warning
local _I = KVS.Output.Info
local _DBG = KVS.Output.Debug

Config = KVS.Config -- Note: Making KVS.Config a global of the mod's scope
-- ==================================================
Config.AddDefaultValue("Notifications.CNE_UseExclamation", true)
Config.AddDefaultValue("Notifications.CNE_UseStatus", true)
Config.AddDefaultValue("Notifications.RD_UseExclamation", true)
Config.AddDefaultValue("Notifications.RD_UseStatus", true)

Config.AddDefaultValue("DBs.AllowMutate", false)
Config.AddDefaultValue("DBs.Mutate_DB_InCamp", false)

Config.AddDefaultValue("Workarounds.MintharaAtMoonrise", false)

-- ==================================================
