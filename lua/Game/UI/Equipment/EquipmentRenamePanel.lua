local EquipmentRenamePanel = class("EquipmentRenamePanel", BasePanel)
EquipmentRenamePanel._bIsMainPanel = false
EquipmentRenamePanel._tbDefine = {
{sPrefabPath = "Equipment/EquipmentRenamePanel.prefab", sCtrlName = "Game.UI.Equipment.EquipmentRenameCtrl"}
}
EquipmentRenamePanel.Awake = function(self)
  -- function num : 0_0
end

EquipmentRenamePanel.OnEnable = function(self)
  -- function num : 0_1
end

EquipmentRenamePanel.OnDisable = function(self)
  -- function num : 0_2
end

EquipmentRenamePanel.OnDestroy = function(self)
  -- function num : 0_3
end

return EquipmentRenamePanel

