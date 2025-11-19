local MessageBoxPanel = class("MessageBoxPanel", BasePanel)
MessageBoxPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
MessageBoxPanel._bAddToBackHistory = false
MessageBoxPanel._tbDefine = {
{sPrefabPath = "MessageBoxEx/MessageBoxPanel.prefab", sCtrlName = "Game.UI.MessageBoxEx.MessageBoxCtrl"}
}
MessageBoxPanel.SetTop = function(self, goCanvas)
  -- function num : 0_0
end

MessageBoxPanel.Awake = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.bBlur = true
  self.trUIRoot = ((GameObject.Find)("---- UI TOP ----")).transform
end

MessageBoxPanel.OnEnable = function(self)
  -- function num : 0_2
end

MessageBoxPanel.OnDisable = function(self)
  -- function num : 0_3
end

MessageBoxPanel.OnDestroy = function(self)
  -- function num : 0_4
end

return MessageBoxPanel

