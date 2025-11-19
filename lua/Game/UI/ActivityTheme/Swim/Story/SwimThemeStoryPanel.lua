local BasePanel = require("GameCore.UI.BasePanel")
local SwimThemeStoryPanel = class("SwimThemeStoryPanel", BasePanel)
SwimThemeStoryPanel._sUIResRootPath = "UI_Activity/"
SwimThemeStoryPanel._tbDefine = {
{sPrefabPath = "Swim/Story/SwimThemeStoryPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.Swim.Story.SwimThemeStoryCtrl"}
}
SwimThemeStoryPanel.Awake = function(self)
  -- function num : 0_0
end

SwimThemeStoryPanel.OnEnable = function(self)
  -- function num : 0_1
end

SwimThemeStoryPanel.OnDisable = function(self)
  -- function num : 0_2
end

SwimThemeStoryPanel.OnDestroy = function(self)
  -- function num : 0_3
end

SwimThemeStoryPanel.OnRelease = function(self)
  -- function num : 0_4
end

return SwimThemeStoryPanel

