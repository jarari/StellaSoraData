-- Panel 模板

local TowerDefensePanel = class("TowerDefensePanel", BasePanel)
TowerDefensePanel._bIsMainPanel = true
TowerDefensePanel._sSortingLayerName = AllEnum.SortingLayerName.UI
local GamepadUIManager = require "GameCore.Module.GamepadUIManager"
-- Panel 定义
--[[
TowerDefensePanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
TowerDefensePanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
TowerDefensePanel._bIsMainPanel = true
TowerDefensePanel._bAddToBackHistory = true
TowerDefensePanel._nSnapshotPrePanel = 0
TowerDefensePanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
TowerDefensePanel._tbDefine = {
    {sPrefabPath = "Play_TowerDefence/TowerDefensePanel.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseCtrl"},
}
-------------------- local function --------------------

-------------------- base function --------------------
function TowerDefensePanel:Awake()
    GamepadUIManager.EnterAdventure(true) -- 塔防的重开是靠重新打开panel，此时无法监听到关卡的firstInputEnable,这里手动开启，初始的屏蔽操作则靠对应ctrl内awake的关闭对应按钮
    GamepadUIManager.EnableGamepadUI("TowerDefense", {}, nil, true) -- 塔防的主要战斗界面在OnEnable的时候会添加节点
end
function TowerDefensePanel:OnEnable()
end
function TowerDefensePanel:OnAfterEnter()
end
function TowerDefensePanel:OnDisable()
end
function TowerDefensePanel:OnDestroy()
    GamepadUIManager.DisableGamepadUI("TowerDefense")
    GamepadUIManager.QuitAdventure()
end
function TowerDefensePanel:OnRelease()
end
-------------------- callback function --------------------
return TowerDefensePanel
