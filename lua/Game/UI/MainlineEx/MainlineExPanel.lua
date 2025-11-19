local BasePanel = require("GameCore.UI.BasePanel")
local MainlineExPanel = class("MainlineExPanel", BasePanel)
MainlineExPanel._tbDefine = {
{sPrefabPath = "MainlineEx/MainlineExPanel.prefab", sCtrlName = "Game.UI.MainlineEx.MainlineExCtrl"}
}
MainlineExPanel.Awake = function(self)
  -- function num : 0_0
end

MainlineExPanel.OnEnable = function(self)
  -- function num : 0_1
end

MainlineExPanel.OnDisable = function(self)
  -- function num : 0_2
end

MainlineExPanel.OnDestroy = function(self)
  -- function num : 0_3
end

MainlineExPanel.OnRelease = function(self)
  -- function num : 0_4
end

return MainlineExPanel

