-- Panel 模板

local TowerDefenseLevelDetailPanel = class("TowerDefenseLevelDetailPanel", BasePanel)
TowerDefenseLevelDetailPanel._bIsMainPanel = true
TowerDefenseLevelDetailPanel._bAddToBackHistory = true
-- Panel 定义
--[[
TowerDefenseLevelDetailPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
TowerDefenseLevelDetailPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
TowerDefenseLevelDetailPanel._bIsMainPanel = true
TowerDefenseLevelDetailPanel._bAddToBackHistory = true
TowerDefenseLevelDetailPanel._nSnapshotPrePanel = 0
TowerDefenseLevelDetailPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
TowerDefenseLevelDetailPanel._tbDefine = {
    {sPrefabPath = "Play_TowerDefence/TowerDefenseLevelDetailPanel.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseLevelDetailCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function TowerDefenseLevelDetailPanel:Awake()
end
function TowerDefenseLevelDetailPanel:OnEnable()
end
function TowerDefenseLevelDetailPanel:OnAfterEnter()
end
function TowerDefenseLevelDetailPanel:OnDisable()
end
function TowerDefenseLevelDetailPanel:OnDestroy()
end
function TowerDefenseLevelDetailPanel:OnRelease()
end
-------------------- callback function --------------------
return TowerDefenseLevelDetailPanel
