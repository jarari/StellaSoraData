local BasePanel = require("GameCore.UI.BasePanel")
local ExChangePanel = class("ExChangePanel", BasePanel)
ExChangePanel._bIsMainPanel = false
ExChangePanel._tbDefine = {
{sPrefabPath = "ExChange/ExChangePanel.prefab", sCtrlName = "Game.UI.ExChange.ExChangeCtrl"}
}
ExChangePanel.Awake = function(self)
  -- function num : 0_0
end

ExChangePanel.OnEnable = function(self)
  -- function num : 0_1
end

ExChangePanel.OnDisable = function(self)
  -- function num : 0_2
end

ExChangePanel.OnDestroy = function(self)
  -- function num : 0_3
end

ExChangePanel.OnRelease = function(self)
  -- function num : 0_4
end

return ExChangePanel

