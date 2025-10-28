
local TDBattleResultPanel = class("TDBattleResultPanel", BasePanel)

TDBattleResultPanel._bAddToBackHistory = false

-- Panel 定义
TDBattleResultPanel._tbDefine = {
    {sPrefabPath = "BattleResult/TravelerDuelBattleResultPanel.prefab", sCtrlName = "Game.UI.BattleResult.TDBattleResultCtrl"}
}
-------------------- local function --------------------
-------------------- base function --------------------

function TDBattleResultPanel:Awake()
end
function TDBattleResultPanel:OnEnable()
end
function TDBattleResultPanel:OnDisable()
end
function TDBattleResultPanel:OnDestroy()
end
-------------------- callback function --------------------
return TDBattleResultPanel
