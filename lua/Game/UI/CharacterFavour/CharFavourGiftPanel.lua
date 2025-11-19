local BasePanel = require("GameCore.UI.BasePanel")
local CharFavourGiftPanel = class("CharFavourGiftPanel", BasePanel)
CharFavourGiftPanel._tbDefine = {
{sPrefabPath = "CharacterFavour/CharFavourGiftPanel.prefab", sCtrlName = "Game.UI.CharacterFavour.CharFavourGiftCtrl"}
}
CharFavourGiftPanel.Awake = function(self)
  -- function num : 0_0
end

CharFavourGiftPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharFavourGiftPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharFavourGiftPanel.OnDestroy = function(self)
  -- function num : 0_3
end

CharFavourGiftPanel.OnRelease = function(self)
  -- function num : 0_4
end

return CharFavourGiftPanel

