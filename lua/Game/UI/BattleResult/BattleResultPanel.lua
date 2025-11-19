local BattleResultPanel = class("BattleResultPanel", BasePanel)
BattleResultPanel._bAddToBackHistory = false
BattleResultPanel._tbDefine = {
{sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.BattleResult.BattleResultCtrl"}
}
BattleResultPanel.Awake = function(self)
  -- function num : 0_0
end

BattleResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

BattleResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

BattleResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return BattleResultPanel

