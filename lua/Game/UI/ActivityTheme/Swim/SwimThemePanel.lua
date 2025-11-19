local BasePanel = require("GameCore.UI.BasePanel")
local SwimThemePanel = class("SwimThemePanel", BasePanel)
SwimThemePanel._sUIResRootPath = "UI_Activity/"
SwimThemePanel._tbDefine = {
{sPrefabPath = "Swim/SwimThemePanel.prefab", sCtrlName = "Game.UI.ActivityTheme.Swim.SwimThemeCtrl"}
}
SwimThemePanel.Awake = function(self)
  -- function num : 0_0
end

SwimThemePanel.OnEnable = function(self)
  -- function num : 0_1
end

SwimThemePanel.OnDisable = function(self)
  -- function num : 0_2
end

SwimThemePanel.OnDestroy = function(self)
  -- function num : 0_3
end

SwimThemePanel.OnRelease = function(self)
  -- function num : 0_4
end

return SwimThemePanel

