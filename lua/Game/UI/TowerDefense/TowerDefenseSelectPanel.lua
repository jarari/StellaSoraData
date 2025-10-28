-- Panel 模板

local TowerDefenseSelectPanel = class("TowerDefenseSelectPanel", BasePanel)
TowerDefenseSelectPanel._bIsMainPanel = true
TowerDefenseSelectPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
-- Panel 定义
--[[
TowerDefenseSelectPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
TowerDefenseSelectPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
TowerDefenseSelectPanel._bIsMainPanel = true
TowerDefenseSelectPanel._bAddToBackHistory = true
TowerDefenseSelectPanel._nSnapshotPrePanel = 0
TowerDefenseSelectPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
TowerDefenseSelectPanel._tbDefine = {
    {sPrefabPath = "Play_TowerDefence/TowerDefenseSelectPanel.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseSelectCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function TowerDefenseSelectPanel:Awake()
end
function TowerDefenseSelectPanel:OnEnable()
end
function TowerDefenseSelectPanel:OnAfterEnter()
end
function TowerDefenseSelectPanel:OnDisable()
end
function TowerDefenseSelectPanel:OnDestroy()
end
function TowerDefenseSelectPanel:OnRelease()
end
-------------------- callback function --------------------
return TowerDefenseSelectPanel
