local BtnTipsPanel = class("BtnTipsPanel", BasePanel)
BtnTipsPanel._bIsMainPanel = false
BtnTipsPanel._bAddToBackHistory = false
BtnTipsPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
BtnTipsPanel._tbDefine = {
{sPrefabPath = "CommonTipsEx/ButtonTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.BtnTipsCtrl"}
}
BtnTipsPanel.Awake = function(self)
  -- function num : 0_0
end

BtnTipsPanel.OnEnable = function(self)
  -- function num : 0_1
end

BtnTipsPanel.OnDisable = function(self)
  -- function num : 0_2
end

BtnTipsPanel.OnDestroy = function(self)
  -- function num : 0_3
end

BtnTipsPanel.OnRelease = function(self)
  -- function num : 0_4
end

return BtnTipsPanel

