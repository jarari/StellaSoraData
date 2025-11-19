local BasePanel = require("GameCore.UI.BasePanel")
local StoryChapterPanel = class("StoryChapterPanel", BasePanel)
StoryChapterPanel._tbDefine = {
{sPrefabPath = "MainlineEx/StoryChapterPanel.prefab", sCtrlName = "Game.UI.MainlineEx.StoryChapterCtrl"}
}
StoryChapterPanel.Awake = function(self)
  -- function num : 0_0
end

StoryChapterPanel.OnEnable = function(self)
  -- function num : 0_1
end

StoryChapterPanel.OnDisable = function(self)
  -- function num : 0_2
end

StoryChapterPanel.OnDestroy = function(self)
  -- function num : 0_3
end

StoryChapterPanel.OnRelease = function(self)
  -- function num : 0_4
end

return StoryChapterPanel

