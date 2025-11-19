local DailyInstanceResultPanel = class("DailyInstanceResultPanel", BasePanel)
DailyInstanceResultPanel._bAddToBackHistory = false
DailyInstanceResultPanel._tbDefine = {
{sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.BattleResult.DailyInstanceResultCtrl"}
}
DailyInstanceResultPanel.Awake = function(self)
  -- function num : 0_0
end

DailyInstanceResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

DailyInstanceResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

DailyInstanceResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return DailyInstanceResultPanel

