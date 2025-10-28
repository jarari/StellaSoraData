
local BattleResultMaskPanel = class("BattleResultMaskPanel", BasePanel)

BattleResultMaskPanel._bIsMainPanel = false
BattleResultMaskPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top

-- Panel 定义
BattleResultMaskPanel._tbDefine = {
    {sPrefabPath = "BattleResult/BattleResultMaskPanel.prefab", sCtrlName = "Game.UI.BattleResult.BattleResultMaskCtrl"}
}
-------------------- local function --------------------
-------------------- base function --------------------

function BattleResultMaskPanel:Awake()
end
function BattleResultMaskPanel:OnEnable()
end
function BattleResultMaskPanel:OnDisable()
end
function BattleResultMaskPanel:OnDestroy()
end
-------------------- callback function --------------------
return BattleResultMaskPanel
