local EnergyBuyPanel = class("EnergyBuyPanel", BasePanel)
EnergyBuyPanel._bIsMainPanel = false
EnergyBuyPanel._tbDefine = {
{sPrefabPath = "EnergyBuy/EnergyBuyPanel.prefab", sCtrlName = "Game.UI.EnergyBuy.EnergyBuyCtrl"}
}
EnergyBuyPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  if not (self._tbParam)[1] then
    self.nPanelType = (AllEnum.EnergyPanelType).Main
    self.mapItemData = (self._tbParam)[2]
    self.bBlur = (self._tbParam)[3]
    self.nMaxEnergy = (ConfigTable.GetConfigNumber)("EnergyObtainLimit")
    self.callback = (self._tbParam)[4]
  end
end

return EnergyBuyPanel

