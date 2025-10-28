-- Panel 模板

local BattlePassPanel = class("BattlePassPanel", BasePanel)

-- Panel 定义
--[[
BattlePassPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
BattlePassPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
BattlePassPanel._bIsMainPanel = true
BattlePassPanel._bAddToBackHistory = true
BattlePassPanel._nSnapshotPrePanel = 0
BattlePassPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
BattlePassPanel._tbDefine = {
    {sPrefabPath = "BattlePass/BattlePassPanel.prefab", sCtrlName = "Game.UI.BattlePass.BattlePassCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function BattlePassPanel:Awake()
end
function BattlePassPanel:OnEnable()
end
function BattlePassPanel:OnAfterEnter()
end
function BattlePassPanel:OnDisable()
end
function BattlePassPanel:OnDestroy()
end
function BattlePassPanel:OnRelease()
end
-------------------- callback function --------------------
return BattlePassPanel
