local PotentialDetailPanel = class("PotentialDetailPanel", BasePanel)
PotentialDetailPanel._bIsMainPanel = false
PotentialDetailPanel._bAddToBackHistory = false
PotentialDetailPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
PotentialDetailPanel._tbDefine = {
{sPrefabPath = "PotentialDetail/PotentialDetailPanel.prefab", sCtrlName = "Game.UI.PotentialDetail.PotentialDetailCtrl"}
}
PotentialDetailPanel.Awake = function(self)
  -- function num : 0_0
end

PotentialDetailPanel.OnEnable = function(self)
  -- function num : 0_1
end

PotentialDetailPanel.OnDisable = function(self)
  -- function num : 0_2
end

PotentialDetailPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return PotentialDetailPanel

