local TrialFormationPanel = class("TrialFormationPanel", BasePanel)
TrialFormationPanel._tbDefine = {
{sPrefabPath = "Play_TrialLevelSelect/TrialFormationScenePanel.prefab", sCtrlName = "Game.UI.TrialLevelSelect.TrialFormationCtrl"}
}
TrialFormationPanel.Awake = function(self)
  -- function num : 0_0
end

TrialFormationPanel.OnEnable = function(self, bPlayFadeIn)
  -- function num : 0_1
end

TrialFormationPanel.OnDisable = function(self)
  -- function num : 0_2
end

TrialFormationPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return TrialFormationPanel

