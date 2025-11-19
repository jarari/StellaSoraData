local FilterPopupPanel = class("FilterPopupPanel", BasePanel)
FilterPopupPanel._bIsMainPanel = false
FilterPopupPanel._tbDefine = {
{sPrefabPath = "Filter/FilterPopupPanel.prefab", sCtrlName = "Game.UI.Filter.FilterPopupCtrl"}
}
FilterPopupPanel.Awake = function(self)
  -- function num : 0_0
end

FilterPopupPanel.OnEnable = function(self)
  -- function num : 0_1
end

FilterPopupPanel.OnDisable = function(self)
  -- function num : 0_2
end

FilterPopupPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return FilterPopupPanel

