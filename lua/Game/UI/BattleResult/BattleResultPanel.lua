
local BattleResultPanel = class("BattleResultPanel", BasePanel)

BattleResultPanel._bAddToBackHistory = false

-- Panel 定义
BattleResultPanel._tbDefine = {
    {sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.BattleResult.BattleResultCtrl"}
}
-------------------- local function --------------------
-------------------- base function --------------------

function BattleResultPanel:Awake()
end
function BattleResultPanel:OnEnable()
end
function BattleResultPanel:OnDisable()
end
function BattleResultPanel:OnDestroy()
end
-------------------- callback function --------------------
return BattleResultPanel
