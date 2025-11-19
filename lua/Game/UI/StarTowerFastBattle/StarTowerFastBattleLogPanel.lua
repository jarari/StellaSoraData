local StarTowerFastBattleLogPanel = class("StarTowerFastBattleLogPanel", BasePanel)
StarTowerFastBattleLogPanel._bIsMainPanel = false
StarTowerFastBattleLogPanel._tbDefine = {
{sPrefabPath = "StarTowerFastBattle/StarTowerFastBattleLogPanel.prefab", sCtrlName = "Game.UI.StarTowerFastBattle.StarTowerFastBattleLogCtrl"}
}
StarTowerFastBattleLogPanel.Awake = function(self)
  -- function num : 0_0
  self.tbHistoryLog = (self:GetPanelParam())[1]
end

StarTowerFastBattleLogPanel.OnEnable = function(self)
  -- function num : 0_1
end

StarTowerFastBattleLogPanel.OnDisable = function(self)
  -- function num : 0_2
end

StarTowerFastBattleLogPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return StarTowerFastBattleLogPanel

