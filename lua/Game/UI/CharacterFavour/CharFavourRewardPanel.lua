local BasePanel = require("GameCore.UI.BasePanel")
local CharFavourRewardPanel = class("CharFavourRewardPanel", BasePanel)
CharFavourRewardPanel._bIsMainPanel = false
CharFavourRewardPanel._tbDefine = {
{sPrefabPath = "CharacterFavour/CharFavourRewardPanel.prefab", sCtrlName = "Game.UI.CharacterFavour.CharFavourRewardCtrl"}
}
CharFavourRewardPanel.Awake = function(self)
  -- function num : 0_0
end

CharFavourRewardPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharFavourRewardPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharFavourRewardPanel.OnDestroy = function(self)
  -- function num : 0_3
end

CharFavourRewardPanel.OnRelease = function(self)
  -- function num : 0_4
end

return CharFavourRewardPanel

