local StarTowerBookPanel = class("StarTowerBookPanel", BasePanel)
StarTowerBookPanel._tbDefine = {
{sPrefabPath = "StarTowerBook/StarTowerBookPanel.prefab", sCtrlName = "Game.UI.StarTowerBook.StarTowerBookCtrl"}
}
StarTowerBookPanel.Awake = function(self)
  -- function num : 0_0
  self.nPanelType = 0
end

StarTowerBookPanel.OnEnable = function(self)
  -- function num : 0_1
end

StarTowerBookPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

StarTowerBookPanel.OnDisable = function(self)
  -- function num : 0_3
end

StarTowerBookPanel.OnDestroy = function(self)
  -- function num : 0_4
end

StarTowerBookPanel.OnRelease = function(self)
  -- function num : 0_5
end

return StarTowerBookPanel

