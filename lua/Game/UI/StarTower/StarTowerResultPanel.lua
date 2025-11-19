local StarTowerResultPanel = class("StarTowerResultPanel", BasePanel)
StarTowerResultPanel._bAddToBackHistory = false
StarTowerResultPanel._tbDefine = {
{sPrefabPath = "StarTower/StarTowerResultPanel.prefab", sCtrlName = "Game.UI.StarTower.StarTowerResultCtrl"}
}
StarTowerResultPanel.Awake = function(self)
  -- function num : 0_0
end

StarTowerResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

StarTowerResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

StarTowerResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return StarTowerResultPanel

