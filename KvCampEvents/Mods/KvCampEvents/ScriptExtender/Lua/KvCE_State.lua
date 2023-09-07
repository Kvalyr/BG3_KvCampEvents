local _E = KVS.Output.Error
local _W = KVS.Output.Warning
local _I = KVS.Output.Info
local _DBG = KVS.Output.Debug
local DB = KVS.DB
local Utils = KVS.Utils
local Table = KVS.Table
local Output = KVS.Output
local Config = KVS.Config

-- ==================================================
-- ==================================================

local State = State

State.INSTALL_STATE_KEY = "KVCE_INSTALL_STATE"

local enum_InstallStates = {}
enum_InstallStates["INIT"] = "INIT"
enum_InstallStates["INSTALLED"] = "INSTALLED"
enum_InstallStates["UNINSTALLED"] = "UNINSTALLED"

-- _P(Mods.KvCampEvents.State.GetInstallState())
function State.GetInstallState()
    return Config.GetValue(State.INSTALL_STATE_KEY)
end

function State.SetInstallState( newState )
    if not enum_InstallStates[newState] then
        _E("State.SetInstallState() - Invalid install state: '" .. (newState or "") .. "' (type: '" .. type(newState) .. "')")
    end
    return Config.SetValue(State.INSTALL_STATE_KEY, newState)
end

function State.IsInstalled()
    return State.GetInstallState() == enum_InstallStates["INSTALLED"]
end

function State.IsUninstalled()
    return State.GetInstallState() == enum_InstallStates["UNINSTALLED"]
end

function State.Init()
    local install_state = State.GetInstallState()
    if not install_state then
        _I("-- Fresh Installation --")
        install_state = enum_InstallStates["INIT"]
        State.Install()
    else
        _I("State:", install_state or "INIT")
    end
end

-- Mods.KvCampEvents.State.Install()
function State.Install()
    _I("-- Installing --")
    -- Installation init, callbacks, etc. here
    State.SetInstallState(enum_InstallStates["INSTALLED"])
end

-- Mods.KvCampEvents.State.Uninstall()
function State.Uninstall()
    _I("-- Uninstalling --")
    -- TODO: Uninstallation cleanup, callbacks, etc. here
    CampEvents.Cleanup()
    State.SetInstallState(enum_InstallStates["UNINSTALLED"])
    Output.MessageBox("KvCampEvents Uninstalled. You can now safely remove the mod.")
end
