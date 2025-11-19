local BasePanel = require("GameCore.UI.BasePanel")
local CharFavourExpUpPanel = class("CharFavourExpUpPanel", BasePanel)
CharFavourExpUpPanel._bIsMainPanel = false
CharFavourExpUpPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
CharFavourExpUpPanel._tbDefine = {
{sPrefabPath = "CharacterFavour/CharFavourExpUpPanel.prefab", sCtrlName = "Game.UI.CharacterFavour.CharFavourExpUpCtrl"}
}
CharFavourExpUpPanel.Awake = function(self)
  -- function num : 0_0
end

CharFavourExpUpPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharFavourExpUpPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharFavourExpUpPanel.OnDestroy = function(self)
  -- function num : 0_3
end

CharFavourExpUpPanel.OnRelease = function(self)
  -- function num : 0_4
end

return CharFavourExpUpPanel

