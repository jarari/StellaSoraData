local ScoreBossResultPanel = class("ScoreBossResultPanel", BasePanel)
ScoreBossResultPanel._bAddToBackHistory = false
ScoreBossResultPanel._tbDefine = {
{sPrefabPath = "Play_ScoreBoss/ScoreBossResultPanel.prefab", sCtrlName = "Game.UI.ScoreBoss.ScoreBossResultCtrl"}
}
ScoreBossResultPanel.Awake = function(self)
  -- function num : 0_0
end

ScoreBossResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

ScoreBossResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

ScoreBossResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return ScoreBossResultPanel

