local SettingsPreviewPanel = class("SettingsPreviewPanel", BasePanel)
SettingsPreviewPanel._bIsMainPanel = false
local LocalSettingData = require("GameCore.Data.LocalSettingData")
SettingsPreviewPanel._tbDefine = {
{sPrefabPath = "Settings/SettingsPreviewPanel.prefab", sCtrlName = "Game.UI.Settings.SettingsPreviewCtrl"}
}
SettingsPreviewPanel.LoadLocalData = function(self, key)
  -- function num : 0_0 , upvalues : LocalSettingData
  return (LocalSettingData.GetLocalSettingData)(key)
end

SettingsPreviewPanel.SaveLocalData = function(self, subKey, value)
  -- function num : 0_1 , upvalues : LocalSettingData
  (LocalSettingData.SetLocalSettingData)(subKey, value)
end

SettingsPreviewPanel.Awake = function(self)
  -- function num : 0_2
end

SettingsPreviewPanel.OnEnable = function(self)
  -- function num : 0_3
end

SettingsPreviewPanel.OnDisable = function(self)
  -- function num : 0_4
end

SettingsPreviewPanel.OnDestroy = function(self)
  -- function num : 0_5
end

return SettingsPreviewPanel

