local StarTowerFastBattleOptionPanel = class("StarTowerFastBattleOptionPanel", BasePanel)
StarTowerFastBattleOptionPanel._bIsMainPanel = false
StarTowerFastBattleOptionPanel._tbDefine = {
{sPrefabPath = "StarTowerFastBattle/StarTowerFastBattleOptionPanel.prefab", sCtrlName = "Game.UI.StarTowerFastBattle.StarTowerFastBattleOptionCtrl"}
}
StarTowerFastBattleOptionPanel.Awake = function(self)
  -- function num : 0_0
  self.bShop = (self:GetPanelParam())[1]
  self.bMachine = (self:GetPanelParam())[2]
  self.nMachineCount = (self:GetPanelParam())[3]
  self.nCoinCount = (self:GetPanelParam())[4]
  self.closeCallback = (self:GetPanelParam())[5]
  self.nDiscount = (self:GetPanelParam())[6]
  self.bFirstFree = (self:GetPanelParam())[7]
  self.bLastFloor = (self:GetPanelParam())[8]
end

StarTowerFastBattleOptionPanel.OnEnable = function(self)
  -- function num : 0_1
end

StarTowerFastBattleOptionPanel.OnDisable = function(self)
  -- function num : 0_2
end

StarTowerFastBattleOptionPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return StarTowerFastBattleOptionPanel

