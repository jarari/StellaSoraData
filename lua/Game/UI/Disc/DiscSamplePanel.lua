local DiscSamplePanel = class("DiscSamplePanel", BasePanel)
DiscSamplePanel._bIsMainPanel = false
DiscSamplePanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
DiscSamplePanel._tbDefine = {
{sPrefabPath = "Disc/DiscSamplePanel.prefab", sCtrlName = "Game.UI.Disc.DiscSampleCtrl"}
}
DiscSamplePanel.Awake = function(self)
  -- function num : 0_0
end

DiscSamplePanel.OnEnable = function(self)
  -- function num : 0_1
end

DiscSamplePanel.OnDisable = function(self)
  -- function num : 0_2
end

DiscSamplePanel.OnDestroy = function(self)
  -- function num : 0_3
end

return DiscSamplePanel

