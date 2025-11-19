local BasePanel = require("GameCore.UI.BasePanel")
local OurRegimentThemePanel = class("OurRegimentThemePanel", BasePanel)
OurRegimentThemePanel._sUIResRootPath = "UI_Activity/"
OurRegimentThemePanel._tbDefine = {
{sPrefabPath = "10101/OurRegimentThemePanel.prefab", sCtrlName = "Game.UI.ActivityTheme.10101.OurRegimentThemeCtrl"}
}
OurRegimentThemePanel.Awake = function(self)
  -- function num : 0_0
end

OurRegimentThemePanel.OnEnable = function(self)
  -- function num : 0_1
end

OurRegimentThemePanel.OnDisable = function(self)
  -- function num : 0_2
end

OurRegimentThemePanel.OnDestroy = function(self)
  -- function num : 0_3
end

OurRegimentThemePanel.OnRelease = function(self)
  -- function num : 0_4
end

return OurRegimentThemePanel

