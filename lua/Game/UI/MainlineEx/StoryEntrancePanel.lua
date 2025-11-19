local BasePanel = require("GameCore.UI.BasePanel")
local StoryEntrancePanel = class("StoryEntrancePanel", BasePanel)
StoryEntrancePanel._tbDefine = {
{sPrefabPath = "MainlineEx/StoryEntrancePanel.prefab", sCtrlName = "Game.UI.MainlineEx.StoryEntranceCtrl"}
}
StoryEntrancePanel.Awake = function(self)
  -- function num : 0_0
end

StoryEntrancePanel.OnEnable = function(self)
  -- function num : 0_1
end

StoryEntrancePanel.OnDisable = function(self)
  -- function num : 0_2
end

StoryEntrancePanel.OnDestroy = function(self)
  -- function num : 0_3
end

StoryEntrancePanel.OnRelease = function(self)
  -- function num : 0_4
end

return StoryEntrancePanel

