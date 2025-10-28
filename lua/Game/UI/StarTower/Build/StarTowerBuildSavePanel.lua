
local StarTowerBuildSavePanel = class("StarTowerBuildSavePanel", BasePanel)

StarTowerBuildSavePanel._bAddToBackHistory = false

-- Panel 定义
StarTowerBuildSavePanel._tbDefine = {
    {sPrefabPath = "StarTowerBuild/StarTowerBuildSavePanel.prefab", sCtrlName = "Game.UI.StarTower.Build.StarTowerBuildSaveCtrl"}
}
-------------------- local function --------------------
-------------------- base function --------------------

function StarTowerBuildSavePanel:Awake()
end
function StarTowerBuildSavePanel:OnEnable()
end
function StarTowerBuildSavePanel:OnDisable()
end
function StarTowerBuildSavePanel:OnDestroy()
end
-------------------- callback function --------------------
return StarTowerBuildSavePanel
