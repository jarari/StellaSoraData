local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
local DatingPanel = class("DatingPanel", BasePanel)
DatingPanel._tbDefine = {
{sPrefabPath = "Phone/DatingPanel.prefab", sCtrlName = "Game.UI.Phone.Dating.DatingCtrl"}
}
DatingPanel.Awake = function(self)
  -- function num : 0_0
end

DatingPanel.OnEnable = function(self)
  -- function num : 0_1
end

DatingPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

DatingPanel.OnDisable = function(self)
  -- function num : 0_3
end

DatingPanel.OnDestroy = function(self)
  -- function num : 0_4 , upvalues : GameResourceLoader
  (GameResourceLoader.Unload)("ImageAvg")
end

DatingPanel.OnRelease = function(self)
  -- function num : 0_5
end

return DatingPanel

