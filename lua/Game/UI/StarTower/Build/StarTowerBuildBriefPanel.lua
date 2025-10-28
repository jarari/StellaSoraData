-- build 列表

local StarTowerBuildBriefPanel = class("StarTowerBuildBriefPanel", BasePanel)

StarTowerBuildBriefPanel._tbDefine = {
    {sPrefabPath = "StarTowerBuild/StarTowerBuildBriefPanel.prefab", sCtrlName = "Game.UI.StarTower.Build.StarTowerBuildBriefCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function StarTowerBuildBriefPanel:Awake()
end
function StarTowerBuildBriefPanel:OnEnable()
end
function StarTowerBuildBriefPanel:OnDisable()
end
function StarTowerBuildBriefPanel:OnDestroy()
end
function StarTowerBuildBriefPanel:OnRelease()
end
-------------------- callback function --------------------
return StarTowerBuildBriefPanel
