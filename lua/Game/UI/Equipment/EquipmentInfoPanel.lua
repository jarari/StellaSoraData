local EquipmentSelectPanel = class("EquipmentSelectPanel", BasePanel)
EquipmentSelectPanel._bIsMainPanel = false
EquipmentSelectPanel._tbDefine = {
{sPrefabPath = "Equipment/EquipmentInfoPanel.prefab", sCtrlName = "Game.UI.Equipment.EquipmentInfoCtrl"}
}
EquipmentSelectPanel.Awake = function(self)
  -- function num : 0_0
end

EquipmentSelectPanel.OnEnable = function(self)
  -- function num : 0_1
end

EquipmentSelectPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

EquipmentSelectPanel.OnDisable = function(self)
  -- function num : 0_3
end

EquipmentSelectPanel.OnDestroy = function(self)
  -- function num : 0_4
end

EquipmentSelectPanel.OnRelease = function(self)
  -- function num : 0_5
end

return EquipmentSelectPanel

