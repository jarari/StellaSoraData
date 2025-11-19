local BasePanel = require("GameCore.UI.BasePanel")
local CharShardsConvertPanel = class("CharShardsConvertPanel", BasePanel)
CharShardsConvertPanel._bIsMainPanel = false
CharShardsConvertPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
CharShardsConvertPanel._tbDefine = {
{sPrefabPath = "Mall/CharShardsConvertPanel.prefab", sCtrlName = "Game.UI.Mall.CharShardsConvertCtrl"}
}
CharShardsConvertPanel.Awake = function(self)
  -- function num : 0_0
end

CharShardsConvertPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharShardsConvertPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharShardsConvertPanel.OnDestroy = function(self)
  -- function num : 0_3
end

CharShardsConvertPanel.OnRelease = function(self)
  -- function num : 0_4
end

return CharShardsConvertPanel

