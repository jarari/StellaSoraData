-- Panel 模板

local TowerDefenseQuestPanel = class("TowerDefenseQuestPanel", BasePanel)
TowerDefenseQuestPanel._sSortingLayerName = AllEnum.SortingLayerName.TOP
TowerDefenseQuestPanel._nSnapshotPrePanel = 1
-- Panel 定义
--[[
TowerDefenseQuestPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
TowerDefenseQuestPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
TowerDefenseQuestPanel._bIsMainPanel = true
TowerDefenseQuestPanel._bAddToBackHistory = true
TowerDefenseQuestPanel._nSnapshotPrePanel = 0
TowerDefenseQuestPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
TowerDefenseQuestPanel._tbDefine = {
    {sPrefabPath = "Play_TowerDefence/TowerDefenseQuest.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseQuestCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function TowerDefenseQuestPanel:Awake()
end
function TowerDefenseQuestPanel:OnEnable()
end
function TowerDefenseQuestPanel:OnAfterEnter()
end
function TowerDefenseQuestPanel:OnDisable()
end
function TowerDefenseQuestPanel:OnDestroy()
end
function TowerDefenseQuestPanel:OnRelease()
end
-------------------- callback function --------------------
return TowerDefenseQuestPanel
