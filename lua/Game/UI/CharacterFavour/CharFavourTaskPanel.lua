local BasePanel = require("GameCore.UI.BasePanel")
local CharFavourTaskPanel = class("CharFavourTaskPanel", BasePanel)
CharFavourTaskPanel._bIsMainPanel = false
CharFavourTaskPanel._tbDefine = {
{sPrefabPath = "CharacterFavour/CharFavourTaskPanel.prefab", sCtrlName = "Game.UI.CharacterFavour.CharFavourTaskCtrl"}
}
CharFavourTaskPanel.Awake = function(self)
  -- function num : 0_0
end

CharFavourTaskPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharFavourTaskPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharFavourTaskPanel.OnDestroy = function(self)
  -- function num : 0_3
end

CharFavourTaskPanel.OnRelease = function(self)
  -- function num : 0_4
end

return CharFavourTaskPanel

