-- BattleSettingsPanel Panel

local BattleSettingsPanel = class("BattleSettingsPanel", BasePanel)
-- Panel 定义
BattleSettingsPanel._bIsMainPanel = false

local LocalSettingData = require "GameCore.Data.LocalSettingData"

BattleSettingsPanel._tbDefine = {
    {sPrefabPath = "Settings/BattleSettingsPanel.prefab", sCtrlName = "Game.UI.Settings.BattleSettingsCtrl"},
}
-------------------- local function --------------------
function BattleSettingsPanel:LoadLocalData(key)
    return LocalSettingData.GetLocalSettingData(key)
end

function BattleSettingsPanel:SaveLocalData(subKey, value)
    LocalSettingData.SetLocalSettingData(subKey, value)
end
-------------------- base function --------------------
function BattleSettingsPanel:Awake()
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
function BattleSettingsPanel:OnEnable()
end
function BattleSettingsPanel:OnDisable()
end
function BattleSettingsPanel:OnDestroy()
end
-------------------- callback function --------------------
return BattleSettingsPanel
