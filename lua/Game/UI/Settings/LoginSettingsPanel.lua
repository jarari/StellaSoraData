local LoginSettingsPanel = class("LoginSettingsPanel", BasePanel)
LoginSettingsPanel._bAddToBackHistory = false
LoginSettingsPanel._nSnapshotPrePanel = 1
LoginSettingsPanel._bIsMainPanel = false
local LocalSettingData = require("GameCore.Data.LocalSettingData")
LoginSettingsPanel._tbDefine = {
{sPrefabPath = "Settings/LoginSettingsPanel.prefab", sCtrlName = "Game.UI.Settings.LoginSettingsCtrl"}
}
LoginSettingsPanel.LoadLocalData = function(self, key)
  -- function num : 0_0 , upvalues : LocalSettingData
  return (LocalSettingData.GetLocalSettingData)(key)
end

LoginSettingsPanel.SaveLocalData = function(self, subKey, value)
  -- function num : 0_1 , upvalues : LocalSettingData
  (LocalSettingData.SetLocalSettingData)(subKey, value)
end

LoginSettingsPanel.Awake = function(self)
  -- function num : 0_2
  self.mapKeyboardBind = {}
  self.mapGamepadBind = {}
  self.Action = {"Fire1", "Fire2", "Fire4", "Interactive", "ActorSwitch1", "ActorSwitch2", "SwitchWithUltra1", "SwitchWithUltra2"}
  self.Move = {"Up", "Down", "Left", "Right"}
  self.ControlType = {Gamepad = 0, Keyboard = 1}
  self.ShowUserCenter = false
end

LoginSettingsPanel.OnEnable = function(self)
  -- function num : 0_3
end

LoginSettingsPanel.OnDisable = function(self)
  -- function num : 0_4
end

LoginSettingsPanel.OnDestroy = function(self)
  -- function num : 0_5
end

return LoginSettingsPanel

