local BattleResultMaskPanel = class("BattleResultMaskPanel", BasePanel)
BattleResultMaskPanel._bIsMainPanel = false
BattleResultMaskPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
BattleResultMaskPanel._tbDefine = {
{sPrefabPath = "BattleResult/BattleResultMaskPanel.prefab", sCtrlName = "Game.UI.BattleResult.BattleResultMaskCtrl"}
}
BattleResultMaskPanel.Awake = function(self)
  -- function num : 0_0
end

BattleResultMaskPanel.OnEnable = function(self)
  -- function num : 0_1
end

BattleResultMaskPanel.OnDisable = function(self)
  -- function num : 0_2
end

BattleResultMaskPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return BattleResultMaskPanel

