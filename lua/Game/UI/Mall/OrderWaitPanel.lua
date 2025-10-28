-- OrderWaitPanel Panel

local OrderWaitPanel = class("OrderWaitPanel", BasePanel)
-- Panel 定义
OrderWaitPanel._bAddToBackHistory = false
OrderWaitPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
OrderWaitPanel._tbDefine = {
    {sPrefabPath = "Mall/OrderWaitPanel.prefab", sCtrlName = "Game.UI.Mall.OrderWaitCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function OrderWaitPanel:Awake()
end
function OrderWaitPanel:OnEnable()
end
function OrderWaitPanel:OnDisable()
end
function OrderWaitPanel:OnDestroy()
end
-------------------- callback function --------------------
return OrderWaitPanel
