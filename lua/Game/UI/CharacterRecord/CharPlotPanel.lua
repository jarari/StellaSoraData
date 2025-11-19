local BasePanel = require("GameCore.UI.BasePanel")
local CharPlotPanel = class("CharPlotPanel", BasePanel)
CharPlotPanel._bIsMainPanel = false
CharPlotPanel._tbDefine = {
{sPrefabPath = "CharacterInfoEx/CharPlotPanel.prefab", sCtrlName = "Game.UI.CharacterRecord.CharPlotCtrl"}
}
CharPlotPanel.Awake = function(self)
  -- function num : 0_0
end

CharPlotPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharPlotPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharPlotPanel.OnDestroy = function(self)
  -- function num : 0_3
end

CharPlotPanel.OnRelease = function(self)
  -- function num : 0_4
end

return CharPlotPanel

