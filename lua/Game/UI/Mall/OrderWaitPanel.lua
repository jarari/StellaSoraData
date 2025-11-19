local OrderWaitPanel = class("OrderWaitPanel", BasePanel)
OrderWaitPanel._bAddToBackHistory = false
OrderWaitPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
OrderWaitPanel._tbDefine = {
{sPrefabPath = "Mall/OrderWaitPanel.prefab", sCtrlName = "Game.UI.Mall.OrderWaitCtrl"}
}
OrderWaitPanel.Awake = function(self)
  -- function num : 0_0
end

OrderWaitPanel.OnEnable = function(self)
  -- function num : 0_1
end

OrderWaitPanel.OnDisable = function(self)
  -- function num : 0_2
end

OrderWaitPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return OrderWaitPanel

