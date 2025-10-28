
local DailyInstanceResultPanel = class("DailyInstanceResultPanel", BasePanel)

DailyInstanceResultPanel._bAddToBackHistory = false

-- Panel 定义
DailyInstanceResultPanel._tbDefine = {
    {sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.BattleResult.DailyInstanceResultCtrl"}
}
-------------------- local function --------------------
-------------------- base function --------------------

function DailyInstanceResultPanel:Awake()
end
function DailyInstanceResultPanel:OnEnable()
end
function DailyInstanceResultPanel:OnDisable()
end
function DailyInstanceResultPanel:OnDestroy()
end
-------------------- callback function --------------------
return DailyInstanceResultPanel
