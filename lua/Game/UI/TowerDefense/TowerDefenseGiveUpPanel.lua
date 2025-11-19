local TowerDefenseGiveUpPanel = class("TowerDefenseGiveUpPanel", BasePanel)
TowerDefenseGiveUpPanel._bIsMainPanel = true
TowerDefenseGiveUpPanel._bAddToBackHistory = true
TowerDefenseGiveUpPanel._tbDefine = {
{sPrefabPath = "Play_TowerDefence/TowerDefenseGiveUpPanel.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseGiveUpCtrl"}
}
TowerDefenseGiveUpPanel.Awake = function(self)
  -- function num : 0_0
end

TowerDefenseGiveUpPanel.OnEnable = function(self)
  -- function num : 0_1
end

TowerDefenseGiveUpPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

TowerDefenseGiveUpPanel.OnDisable = function(self)
  -- function num : 0_3
end

TowerDefenseGiveUpPanel.OnDestroy = function(self)
  -- function num : 0_4
end

TowerDefenseGiveUpPanel.OnRelease = function(self)
  -- function num : 0_5
end

return TowerDefenseGiveUpPanel

