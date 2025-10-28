local StarTowerGrowthPanel = class("StarTowerGrowthPanel", BasePanel)

StarTowerGrowthPanel._bAddToBackHistory = false

StarTowerGrowthPanel._tbDefine = {
    {sPrefabPath = "StarTowerGrowth/StarTowerGrowthPanel.prefab", sCtrlName = "Game.UI.StarTowerGrowth.StarTowerGrowthCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function StarTowerGrowthPanel:Awake()
end
function StarTowerGrowthPanel:OnEnable()
end
function StarTowerGrowthPanel:OnAfterEnter()
end
function StarTowerGrowthPanel:OnDisable()
end
function StarTowerGrowthPanel:OnDestroy()
end
function StarTowerGrowthPanel:OnRelease()
end
-------------------- callback function --------------------
return StarTowerGrowthPanel