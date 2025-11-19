local TutorialResultPanel = class("TutorialResultPanel", BasePanel)
TutorialResultPanel._bAddToBackHistory = false
TutorialResultPanel._tbDefine = {
{sPrefabPath = "Tutorial/TutorialResultPanel.prefab", sCtrlName = "Game.UI.Tutorial.TutorialResultCtrl"}
}
TutorialResultPanel.Awake = function(self)
  -- function num : 0_0
end

TutorialResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

TutorialResultPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

TutorialResultPanel.OnDisable = function(self)
  -- function num : 0_3
end

TutorialResultPanel.OnDestroy = function(self)
  -- function num : 0_4
end

TutorialResultPanel.OnRelease = function(self)
  -- function num : 0_5
end

return TutorialResultPanel

