
local ActivityLevelsInstanceResultPanel = class("ActivityLevelsInstanceResultPanel", BasePanel)

ActivityLevelsInstanceResultPanel._bAddToBackHistory = false

-- Panel 定义
ActivityLevelsInstanceResultPanel._tbDefine = {
    {sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.Swim.ActivityLevels.ActivityLevelsInstanceResultCtrl"}
}
-------------------- local function --------------------
-------------------- base function --------------------

function ActivityLevelsInstanceResultPanel:Awake()
end
function ActivityLevelsInstanceResultPanel:OnEnable()
end
function ActivityLevelsInstanceResultPanel:OnDisable()
end
function ActivityLevelsInstanceResultPanel:OnDestroy()
end
-------------------- callback function --------------------
return ActivityLevelsInstanceResultPanel