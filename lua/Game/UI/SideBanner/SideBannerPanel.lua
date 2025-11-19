local SideBanner = class("SideBanner", BasePanel)
SideBanner._sSortingLayerName = (AllEnum.SortingLayerName).Overlay
SideBanner._bAddToBackHistory = false
SideBanner._tbDefine = {
{sPrefabPath = "SideBanner/SideBannerPanel.prefab", sCtrlName = "Game.UI.SideBanner.SideBannerCtrl"}
}
SideBanner.Awake = function(self)
  -- function num : 0_0
end

SideBanner.OnEnable = function(self)
  -- function num : 0_1
end

SideBanner.OnDisable = function(self)
  -- function num : 0_2
end

SideBanner.OnDestroy = function(self)
  -- function num : 0_3
end

return SideBanner

