
local StarTowerResultPanel = class("StarTowerResultPanel", BasePanel)

StarTowerResultPanel._bAddToBackHistory = false

-- Panel 定义
StarTowerResultPanel._tbDefine = {
    {sPrefabPath = "StarTower/StarTowerResultPanel.prefab", sCtrlName = "Game.UI.StarTower.StarTowerResultCtrl"}
}
-------------------- local function --------------------
-------------------- base function --------------------

function StarTowerResultPanel:Awake()
end
function StarTowerResultPanel:OnEnable()
end
function StarTowerResultPanel:OnDisable()
end
function StarTowerResultPanel:OnDestroy()
end
-------------------- callback function --------------------
return StarTowerResultPanel
