local TowerDefenseSelectPanel = class("TowerDefenseSelectPanel", BasePanel)
TowerDefenseSelectPanel._bIsMainPanel = true
TowerDefenseSelectPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
TowerDefenseSelectPanel._tbDefine = {
{sPrefabPath = "Play_TowerDefence/TowerDefenseSelectPanel.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseSelectCtrl"}
}
TowerDefenseSelectPanel.Awake = function(self)
  -- function num : 0_0
end

TowerDefenseSelectPanel.OnEnable = function(self)
  -- function num : 0_1
end

TowerDefenseSelectPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

TowerDefenseSelectPanel.OnDisable = function(self)
  -- function num : 0_3
end

TowerDefenseSelectPanel.OnDestroy = function(self)
  -- function num : 0_4
end

TowerDefenseSelectPanel.OnRelease = function(self)
  -- function num : 0_5
end

return TowerDefenseSelectPanel

