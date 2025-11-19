local EquipmentTipsPanel = class("EquipmentTipsPanel", BasePanel)
EquipmentTipsPanel._bIsMainPanel = false
EquipmentTipsPanel._bAddToBackHistory = false
EquipmentTipsPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
EquipmentTipsPanel._tbDefine = {
{sPrefabPath = "CommonTipsEx/EquipmentTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.EquipmentTipsCtrl"}
}
EquipmentTipsPanel.Awake = function(self)
  -- function num : 0_0
end

EquipmentTipsPanel.OnEnable = function(self)
  -- function num : 0_1
end

EquipmentTipsPanel.OnDisable = function(self)
  -- function num : 0_2
end

EquipmentTipsPanel.OnDestroy = function(self)
  -- function num : 0_3
end

EquipmentTipsPanel.OnRelease = function(self)
  -- function num : 0_4
end

return EquipmentTipsPanel

