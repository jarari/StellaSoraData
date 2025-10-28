-- SettingsPreviewPanel Panel

local SettingsPreviewPanel = class("SettingsPreviewPanel", BasePanel)
-- Panel 定义
SettingsPreviewPanel._bIsMainPanel = false

local LocalSettingData = require "GameCore.Data.LocalSettingData"

SettingsPreviewPanel._tbDefine = {
    {sPrefabPath = "Settings/SettingsPreviewPanel.prefab", sCtrlName = "Game.UI.Settings.SettingsPreviewCtrl"},
}
-------------------- local function --------------------
function SettingsPreviewPanel:LoadLocalData(key)
    return LocalSettingData.GetLocalSettingData(key)
end

function SettingsPreviewPanel:SaveLocalData(subKey, value)
    LocalSettingData.SetLocalSettingData(subKey, value)
end
-------------------- base function --------------------
function SettingsPreviewPanel:Awake()
end
function SettingsPreviewPanel:OnEnable()
end
function SettingsPreviewPanel:OnDisable()
end
function SettingsPreviewPanel:OnDestroy()
end
-------------------- callback function --------------------
return SettingsPreviewPanel
