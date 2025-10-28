local StarTowerFastBattleOptionPanel = class("StarTowerFastBattleOptionPanel", BasePanel)
-- Panel 定义

StarTowerFastBattleOptionPanel._bIsMainPanel = false

StarTowerFastBattleOptionPanel._tbDefine = {
    {sPrefabPath = "StarTowerFastBattle/StarTowerFastBattleOptionPanel.prefab", sCtrlName = "Game.UI.StarTowerFastBattle.StarTowerFastBattleOptionCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function StarTowerFastBattleOptionPanel:Awake()
    self.bShop = self:GetPanelParam()[1]
    self.bMachine = self:GetPanelParam()[2]
    self.nMachineCount = self:GetPanelParam()[3]
    self.nCoinCount = self:GetPanelParam()[4]
    self.closeCallback = self:GetPanelParam()[5]
    self.nDiscount = self:GetPanelParam()[6]
    self.bFirstFree = self:GetPanelParam()[7]
    self.bLastFloor = self:GetPanelParam()[8]
end
function StarTowerFastBattleOptionPanel:OnEnable()
end
function StarTowerFastBattleOptionPanel:OnDisable()
end
function StarTowerFastBattleOptionPanel:OnDestroy()
end
-------------------- callback function --------------------
return StarTowerFastBattleOptionPanel
