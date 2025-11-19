local EquipmentInstanceResultPanel = class("EquipmentInstanceResultPanel", BasePanel)
EquipmentInstanceResultPanel._bAddToBackHistory = false
EquipmentInstanceResultPanel._tbDefine = {
{sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.BattleResult.EquipmentInstanceResultCtrl"}
}
EquipmentInstanceResultPanel.Awake = function(self)
  -- function num : 0_0
end

EquipmentInstanceResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

EquipmentInstanceResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

EquipmentInstanceResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return EquipmentInstanceResultPanel

