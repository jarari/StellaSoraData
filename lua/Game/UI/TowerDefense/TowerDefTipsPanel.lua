local TowerDefTipsPanel = class("TowerDefTipsPanel", BasePanel)
TowerDefTipsPanel._bIsMainPanel = false
TowerDefTipsPanel._bAddToBackHistory = false
TowerDefTipsPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
TowerDefTipsPanel._tbDefine = {
{sPrefabPath = "Play_TowerDefence/TowerDefTips.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefTipsCtrl"}
}
TowerDefTipsPanel.Awake = function(self)
  -- function num : 0_0
end

TowerDefTipsPanel.OnEnable = function(self)
  -- function num : 0_1
end

TowerDefTipsPanel.OnDisable = function(self)
  -- function num : 0_2
end

TowerDefTipsPanel.OnDestroy = function(self)
  -- function num : 0_3
end

TowerDefTipsPanel.OnRelease = function(self)
  -- function num : 0_4
end

return TowerDefTipsPanel

