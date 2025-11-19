local BasePanel = require("GameCore.UI.BasePanel")
local DispatchPanel = class("DispatchPanel", BasePanel)
DispatchPanel._tbDefine = {
{sPrefabPath = "Dispatch/DispatchPanel.prefab", sCtrlName = "Game.UI.Dispatch.DispatchCtrl"}
}
DispatchPanel.Awake = function(self)
  -- function num : 0_0
end

DispatchPanel.OnEnable = function(self)
  -- function num : 0_1
end

DispatchPanel.OnDisable = function(self)
  -- function num : 0_2
end

DispatchPanel.OnDestroy = function(self)
  -- function num : 0_3
end

DispatchPanel.OnRelease = function(self)
  -- function num : 0_4
end

return DispatchPanel

