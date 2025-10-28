-- Panel 模板

local TowerDefenseCharacterDetailPanel = class("TowerDefenseCharacterDetailPanel", BasePanel)
TowerDefenseCharacterDetailPanel._nSnapshotPrePanel = 1
TowerDefenseCharacterDetailPanel._bIsMainPanel = false
-- Panel 定义
--[[
TowerDefenseCharacterDetailPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
TowerDefenseCharacterDetailPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
TowerDefenseCharacterDetailPanel._bIsMainPanel = true
TowerDefenseCharacterDetailPanel._bAddToBackHistory = true
TowerDefenseCharacterDetailPanel._nSnapshotPrePanel = 0
TowerDefenseCharacterDetailPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
TowerDefenseCharacterDetailPanel._tbDefine = {
    {sPrefabPath = "Play_TowerDefence/TowerDefenseCharacterDetailPanel.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseCharacterDetailCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function TowerDefenseCharacterDetailPanel:Awake()
end
function TowerDefenseCharacterDetailPanel:OnEnable()
end
function TowerDefenseCharacterDetailPanel:OnAfterEnter()
end
function TowerDefenseCharacterDetailPanel:OnDisable()
end
function TowerDefenseCharacterDetailPanel:OnDestroy()
end
function TowerDefenseCharacterDetailPanel:OnRelease()
end
-------------------- callback function --------------------
return TowerDefenseCharacterDetailPanel
