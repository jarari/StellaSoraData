local EquipmentSucBarPanel = class("EquipmentSucBarPanel", BasePanel)
EquipmentSucBarPanel._bIsMainPanel = false
EquipmentSucBarPanel._tbDefine = {
{sPrefabPath = "SuccessBarEx/EquipmentSucBarPanel.prefab", sCtrlName = "Game.UI.SuccessBarEx.EquipmentSucBarCtrl"}
}
EquipmentSucBarPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.mapData = tbParam[1]
    self.callback = tbParam[2]
  end
end

EquipmentSucBarPanel.OnEnable = function(self)
  -- function num : 0_1
end

EquipmentSucBarPanel.OnDisable = function(self)
  -- function num : 0_2
end

EquipmentSucBarPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return EquipmentSucBarPanel

