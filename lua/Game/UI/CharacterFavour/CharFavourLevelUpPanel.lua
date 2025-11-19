local BasePanel = require("GameCore.UI.BasePanel")
local CharFavourLevelUpPanel = class("CharFavourLevelUpPanel", BasePanel)
CharFavourLevelUpPanel._bIsMainPanel = false
CharFavourLevelUpPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
CharFavourLevelUpPanel._tbDefine = {
{sPrefabPath = "CharacterFavour/CharFavourLevelUpPanel.prefab", sCtrlName = "Game.UI.CharacterFavour.CharFavourLevelUpCtrl"}
}
CharFavourLevelUpPanel.Awake = function(self)
  -- function num : 0_0
end

CharFavourLevelUpPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharFavourLevelUpPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharFavourLevelUpPanel.OnDestroy = function(self)
  -- function num : 0_3
end

CharFavourLevelUpPanel.OnRelease = function(self)
  -- function num : 0_4
end

return CharFavourLevelUpPanel

