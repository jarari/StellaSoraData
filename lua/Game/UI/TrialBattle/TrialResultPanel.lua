
local TrialResultPanel = class("TrialResultPanel", BasePanel)

TrialResultPanel._bAddToBackHistory = false

-- Panel 定义
TrialResultPanel._tbDefine = {
    {sPrefabPath = "Play_TrialBattle/TrialResultPanel.prefab", sCtrlName = "Game.UI.TrialBattle.TrialResultCtrl"}
}
-------------------- local function --------------------
-------------------- base function --------------------

function TrialResultPanel:Awake()
end
function TrialResultPanel:OnEnable()
end
function TrialResultPanel:OnDisable()
end
function TrialResultPanel:OnDestroy()
end
-------------------- callback function --------------------
return TrialResultPanel
