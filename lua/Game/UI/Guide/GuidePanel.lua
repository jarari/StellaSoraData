local GuidePanel = class("GuidePanel", BasePanel)
GuidePanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
GuidePanel._bAddToBackHistory = false
GuidePanel._tbDefine = {
{sPrefabPath = "Guide/GuidePanel.prefab", sCtrlName = "Game.UI.Guide.GuideCtrl"}
}
GuidePanel.Awake = function(self)
  -- function num : 0_0
end

GuidePanel.OnEnable = function(self)
  -- function num : 0_1
end

GuidePanel.OnDisable = function(self)
  -- function num : 0_2
end

GuidePanel.OnDestroy = function(self)
  -- function num : 0_3
end

return GuidePanel

