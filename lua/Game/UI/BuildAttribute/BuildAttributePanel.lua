local BuildAttributePanel = class("BuildAttributePanel", BasePanel)
BuildAttributePanel._bIsMainPanel = false
BuildAttributePanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
BuildAttributePanel._tbDefine = {
{sPrefabPath = "BuildAttribute/BuildAttributePanel.prefab", sCtrlName = "Game.UI.BuildAttribute.BuildAttributeCtrl"}
}
BuildAttributePanel.Awake = function(self)
  -- function num : 0_0
end

BuildAttributePanel.OnEnable = function(self)
  -- function num : 0_1
end

BuildAttributePanel.OnDisable = function(self)
  -- function num : 0_2
end

BuildAttributePanel.OnDestroy = function(self)
  -- function num : 0_3
end

return BuildAttributePanel

