local ActivityLevelsInstanceResultPanel = class("ActivityLevelsInstanceResultPanel", BasePanel)
ActivityLevelsInstanceResultPanel._bAddToBackHistory = false
ActivityLevelsInstanceResultPanel._tbDefine = {
{sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.LevelCommon.ActivityLevelsInstanceResultCtrl"}
}
ActivityLevelsInstanceResultPanel.Awake = function(self)
  -- function num : 0_0
end

ActivityLevelsInstanceResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

ActivityLevelsInstanceResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

ActivityLevelsInstanceResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return ActivityLevelsInstanceResultPanel

