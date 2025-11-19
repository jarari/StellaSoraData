local BasePanel = require("GameCore.UI.BasePanel")
local CharacterStoryPanel = class("CharacterStoryPanel", BasePanel)
CharacterStoryPanel._bIsMainPanel = false
CharacterStoryPanel._tbDefine = {
{sPrefabPath = "CharacterInfoEx/CharacterStoryPanel.prefab", sCtrlName = "Game.UI.CharacterRecord.CharacterStoryCtrl"}
}
CharacterStoryPanel.Awake = function(self)
  -- function num : 0_0
end

CharacterStoryPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharacterStoryPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharacterStoryPanel.OnDestroy = function(self)
  -- function num : 0_3
end

CharacterStoryPanel.OnRelease = function(self)
  -- function num : 0_4
end

return CharacterStoryPanel

