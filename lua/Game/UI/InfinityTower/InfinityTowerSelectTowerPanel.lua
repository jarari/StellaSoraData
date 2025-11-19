local InfinityTowerSelectTowerPanel = class("InfinityTowerSelectTowerPanel", BasePanel)
InfinityTowerSelectTowerPanel._tbDefine = {
{sPrefabPath = "InfinityTower/InfinityTowerSelectT.prefab", sCtrlName = "Game.UI.InfinityTower.InfinityTowerSelectTowerCtrl"}
}
InfinityTowerSelectTowerPanel.Awake = function(self)
  -- function num : 0_0
  self.openTowerId = nil
  local tbParam = self:GetPanelParam()
  if tbParam[1] then
    self.openTowerId = tbParam[1]
  end
end

InfinityTowerSelectTowerPanel.OnEnable = function(self)
  -- function num : 0_1
end

InfinityTowerSelectTowerPanel.OnDisable = function(self)
  -- function num : 0_2
end

InfinityTowerSelectTowerPanel.OnDestroy = function(self)
  -- function num : 0_3
end

InfinityTowerSelectTowerPanel.OnRelease = function(self)
  -- function num : 0_4
end

return InfinityTowerSelectTowerPanel

