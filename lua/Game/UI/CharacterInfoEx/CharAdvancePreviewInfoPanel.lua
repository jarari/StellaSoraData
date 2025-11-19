local BasePanel = require("GameCore.UI.BasePanel")
local CharAdvancePreviewInfoPanel = class("CharAdvancePreviewInfoPanel", BasePanel)
CharAdvancePreviewInfoPanel._bIsMainPanel = false
CharAdvancePreviewInfoPanel._tbDefine = {
{sPrefabPath = "CharacterInfoEx/CharAdvancePreviewInfoPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharAdvancePreviewInfoCtrl"}
}
CharAdvancePreviewInfoPanel.Awake = function(self)
  -- function num : 0_0
end

CharAdvancePreviewInfoPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharAdvancePreviewInfoPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharAdvancePreviewInfoPanel.OnDestroy = function(self)
  -- function num : 0_3
end

CharAdvancePreviewInfoPanel.OnRelease = function(self)
  -- function num : 0_4
end

return CharAdvancePreviewInfoPanel

