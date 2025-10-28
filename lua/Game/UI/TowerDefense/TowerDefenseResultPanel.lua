-- Panel 模板

local TowerDefenseResultPanel = class("TowerDefenseResultPanel", BasePanel)
TowerDefenseResultPanel._nSnapshotPrePanel = 1
-- Panel 定义
--[[
AAAPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
AAAPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
AAAPanel._bIsMainPanel = true
AAAPanel._bAddToBackHistory = true
AAAPanel._nSnapshotPrePanel = 0
AAAPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
TowerDefenseResultPanel._tbDefine = {
    {sPrefabPath = "Play_TowerDefence/TowerDefenseResultPanel.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseResultCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function TowerDefenseResultPanel:Awake()
end
function TowerDefenseResultPanel:OnEnable()
end
function TowerDefenseResultPanel:OnAfterEnter()
end
function TowerDefenseResultPanel:OnDisable()
end
function TowerDefenseResultPanel:OnDestroy()
end
function TowerDefenseResultPanel:OnRelease()
end
-------------------- callback function --------------------
return TowerDefenseResultPanel
