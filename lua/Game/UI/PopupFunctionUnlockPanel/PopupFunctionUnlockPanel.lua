local PopupFunctionUnlockPanel = class("PopupFunctionUnlockPanel", BasePanel)
PopupFunctionUnlockPanel._bIsMainPanel = false
PopupFunctionUnlockPanel._bAddToBackHistory = false
PopupFunctionUnlockPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
PopupFunctionUnlockPanel._tbDefine = {
{sPrefabPath = "PopupFunctionUnlock/PopupFunctionUnlockPanel.prefab", sCtrlName = "Game.UI.PopupFunctionUnlockPanel.PopupFunctionUnlockCtrl"}
}
PopupFunctionUnlockPanel.Awake = function(self)
  -- function num : 0_0
end

PopupFunctionUnlockPanel.OnEnable = function(self)
  -- function num : 0_1
end

PopupFunctionUnlockPanel.OnDisable = function(self)
  -- function num : 0_2
end

PopupFunctionUnlockPanel.OnDestroy = function(self)
  -- function num : 0_3
end

PopupFunctionUnlockPanel.OnRelease = function(self)
  -- function num : 0_4
end

return PopupFunctionUnlockPanel

