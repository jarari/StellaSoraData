local BasePanel = require("GameCore.UI.BasePanel")
local DreamThemePanel = class("DreamThemePanel", BasePanel)
DreamThemePanel._sUIResRootPath = "UI_Activity/"
DreamThemePanel._tbDefine = {
{sPrefabPath = "10102/DreamThemePanel.prefab", sCtrlName = "Game.UI.ActivityTheme.10102.DreamThemeCtrl"}
}
DreamThemePanel.Awake = function(self)
  -- function num : 0_0
end

DreamThemePanel.OnEnable = function(self)
  -- function num : 0_1
end

DreamThemePanel.OnDisable = function(self)
  -- function num : 0_2
end

DreamThemePanel.OnDestroy = function(self)
  -- function num : 0_3
end

DreamThemePanel.OnRelease = function(self)
  -- function num : 0_4
end

return DreamThemePanel

