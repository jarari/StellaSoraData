-- SettingsPanel Panel

local SettingsPanel = class("SettingsPanel", BasePanel)
-- Panel 定义
SettingsPanel._bAddToBackHistory = false
SettingsPanel._nSnapshotPrePanel = 1


local LocalSettingData = require "GameCore.Data.LocalSettingData"

SettingsPanel._tbDefine = {
    {sPrefabPath = "Settings/SettingsPanel.prefab", sCtrlName = "Game.UI.Settings.SettingsCtrl"},
}
-------------------- local function --------------------
function SettingsPanel:LoadLocalData(key)
    return LocalSettingData.GetLocalSettingData(key)
end

function SettingsPanel:SaveLocalData(subKey, value)
    LocalSettingData.SetLocalSettingData(subKey, value)
end
-------------------- base function --------------------
function SettingsPanel:Awake()
    self.mapKeyboardBind = {}
    self.mapGamepadBind = {}
    self.Action = {
        "Fire1",
        "Fire2",
        "Fire4",
        "Interactive",
        "ActorSwitch1",
        "ActorSwitch2",
        "SwitchWithUltra1",
        "SwitchWithUltra2",
    }
    self.Move = {
        "Up",
        "Down",
        "Left",
        "Right",
    }
    self.ControlType = { -- 和action内定义的顺序一样
        Gamepad = 0,
        Keyboard = 1,
    }
end
function SettingsPanel:OnEnable()
end
function SettingsPanel:OnDisable()
end
function SettingsPanel:OnDestroy()
end
-------------------- callback function --------------------
return SettingsPanel
