local SettingsPanel = class("SettingsPanel", BasePanel)
SettingsPanel._bAddToBackHistory = false
SettingsPanel._nSnapshotPrePanel = 1
local LocalSettingData = require("GameCore.Data.LocalSettingData")
SettingsPanel._tbDefine = {
{sPrefabPath = "Settings/SettingsPanel.prefab", sCtrlName = "Game.UI.Settings.SettingsCtrl"}
}
SettingsPanel.LoadLocalData = function(self, key)
  -- function num : 0_0 , upvalues : LocalSettingData
  return (LocalSettingData.GetLocalSettingData)(key)
end

SettingsPanel.SaveLocalData = function(self, subKey, value)
  -- function num : 0_1 , upvalues : LocalSettingData
  (LocalSettingData.SetLocalSettingData)(subKey, value)
end

SettingsPanel.Awake = function(self)
  -- function num : 0_2
  self.mapKeyboardBind = {}
  self.mapGamepadBind = {}
  self.Action = {"Fire1", "Fire2", "Fire4", "Interactive", "ActorSwitch1", "ActorSwitch2", "SwitchWithUltra1", "SwitchWithUltra2"}
  self.Move = {"Up", "Down", "Left", "Right"}
  self.ControlType = {Gamepad = 0, Keyboard = 1}
end

SettingsPanel.OnEnable = function(self)
  -- function num : 0_3
end

SettingsPanel.OnDisable = function(self)
  -- function num : 0_4
end

SettingsPanel.OnDestroy = function(self)
  -- function num : 0_5
end

return SettingsPanel

