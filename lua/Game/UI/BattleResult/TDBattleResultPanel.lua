local TDBattleResultPanel = class("TDBattleResultPanel", BasePanel)
TDBattleResultPanel._bAddToBackHistory = false
TDBattleResultPanel._tbDefine = {
{sPrefabPath = "BattleResult/TravelerDuelBattleResultPanel.prefab", sCtrlName = "Game.UI.BattleResult.TDBattleResultCtrl"}
}
TDBattleResultPanel.Awake = function(self)
  -- function num : 0_0
end

TDBattleResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

TDBattleResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

TDBattleResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return TDBattleResultPanel

