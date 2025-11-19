local TowerDefenseLevelDetailPanel = class("TowerDefenseLevelDetailPanel", BasePanel)
TowerDefenseLevelDetailPanel._bIsMainPanel = true
TowerDefenseLevelDetailPanel._bAddToBackHistory = true
TowerDefenseLevelDetailPanel._tbDefine = {
{sPrefabPath = "Play_TowerDefence/TowerDefenseLevelDetailPanel.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseLevelDetailCtrl"}
}
TowerDefenseLevelDetailPanel.Awake = function(self)
  -- function num : 0_0
end

TowerDefenseLevelDetailPanel.OnEnable = function(self)
  -- function num : 0_1
end

TowerDefenseLevelDetailPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

TowerDefenseLevelDetailPanel.OnDisable = function(self)
  -- function num : 0_3
end

TowerDefenseLevelDetailPanel.OnDestroy = function(self)
  -- function num : 0_4
end

TowerDefenseLevelDetailPanel.OnRelease = function(self)
  -- function num : 0_5
end

return TowerDefenseLevelDetailPanel

