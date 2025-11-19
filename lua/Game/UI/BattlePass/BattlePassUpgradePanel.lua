local BattlePassUpgradePanel = class("BattlePassUpgradePanel", BasePanel)
BattlePassUpgradePanel._bIsMainPanel = false
BattlePassUpgradePanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
BattlePassUpgradePanel._tbDefine = {
{sPrefabPath = "BattlePass/BattlePassUpgradePanel.prefab", sCtrlName = "Game.UI.BattlePass.BattlePassUpgradeCtrl"}
}
BattlePassUpgradePanel.Awake = function(self)
  -- function num : 0_0
end

BattlePassUpgradePanel.OnEnable = function(self)
  -- function num : 0_1
end

BattlePassUpgradePanel.OnDisable = function(self)
  -- function num : 0_2
end

BattlePassUpgradePanel.OnDestroy = function(self)
  -- function num : 0_3
end

return BattlePassUpgradePanel

