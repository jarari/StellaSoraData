local TDClassUpgradePanel = class("TDClassUpgradePanel", BasePanel)
TDClassUpgradePanel._bIsMainPanel = false
TDClassUpgradePanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
TDClassUpgradePanel._tbDefine = {
{sPrefabPath = "TravelerDuelLevelSelect/TDClassUpgradePanel.prefab", sCtrlName = "Game.UI.TravelerDuelLevelSelect.TDClassUpgradeCtrl"}
}
TDClassUpgradePanel.Awake = function(self)
  -- function num : 0_0
end

TDClassUpgradePanel.OnEnable = function(self)
  -- function num : 0_1
end

TDClassUpgradePanel.OnDisable = function(self)
  -- function num : 0_2
end

TDClassUpgradePanel.OnDestroy = function(self)
  -- function num : 0_3
end

return TDClassUpgradePanel

