local TrialResultPanel = class("TrialResultPanel", BasePanel)
TrialResultPanel._bAddToBackHistory = false
TrialResultPanel._tbDefine = {
{sPrefabPath = "Play_TrialBattle/TrialResultPanel.prefab", sCtrlName = "Game.UI.TrialBattle.TrialResultCtrl"}
}
TrialResultPanel.Awake = function(self)
  -- function num : 0_0
end

TrialResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

TrialResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

TrialResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return TrialResultPanel

