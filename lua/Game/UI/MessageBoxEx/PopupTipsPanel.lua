local PopupTipsPanel = class("PopupTipsPanel", BasePanel)
PopupTipsPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
PopupTipsPanel._bAddToBackHistory = false
PopupTipsPanel._tbDefine = {
{sPrefabPath = "PopupTips/PopupTipsPanel.prefab", sCtrlName = "Game.UI.MessageBoxEx.PopupTipsCtrl"}
}
PopupTipsPanel.Awake = function(self)
  -- function num : 0_0
end

PopupTipsPanel.OnEnable = function(self)
  -- function num : 0_1
end

PopupTipsPanel.OnDisable = function(self)
  -- function num : 0_2
end

PopupTipsPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return PopupTipsPanel

