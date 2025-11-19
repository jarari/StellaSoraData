local BasePanel = require("GameCore.UI.BasePanel")
local ExchangeCodePanel = class("ExchangeCodePanel", BasePanel)
ExchangeCodePanel._bIsMainPanel = false
ExchangeCodePanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
ExchangeCodePanel._tbDefine = {
{sPrefabPath = "ExchangeCode/ExchangeCodePanel.prefab", sCtrlName = "Game.UI.ExchangeCode.ExchangeCodeCtrl"}
}
ExchangeCodePanel.Awake = function(self)
  -- function num : 0_0
end

ExchangeCodePanel.OnEnable = function(self)
  -- function num : 0_1
end

ExchangeCodePanel.OnDisable = function(self)
  -- function num : 0_2
end

ExchangeCodePanel.OnDestroy = function(self)
  -- function num : 0_3
end

ExchangeCodePanel.OnRelease = function(self)
  -- function num : 0_4
end

return ExchangeCodePanel

