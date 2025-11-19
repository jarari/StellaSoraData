local WorldClassUpgradePanel = class("WorldClassUpgradePanel", BasePanel)
WorldClassUpgradePanel._bIsMainPanel = false
WorldClassUpgradePanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
WorldClassUpgradePanel._tbDefine = {
{sPrefabPath = "WorldClassEx/WorldClassUpgradePanel.prefab", sCtrlName = "Game.UI.WorldClassEx.WorldClassUpgradeCtrl"}
}
WorldClassUpgradePanel.Awake = function(self)
  -- function num : 0_0
end

WorldClassUpgradePanel.OnEnable = function(self)
  -- function num : 0_1
end

WorldClassUpgradePanel.OnDisable = function(self)
  -- function num : 0_2
end

WorldClassUpgradePanel.OnDestroy = function(self)
  -- function num : 0_3
end

return WorldClassUpgradePanel

