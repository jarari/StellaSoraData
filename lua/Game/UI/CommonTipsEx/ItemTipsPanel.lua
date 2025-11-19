local ItemTipsPanel = class("ItemTipsPanel", BasePanel)
ItemTipsPanel._bIsMainPanel = false
ItemTipsPanel._bAddToBackHistory = false
ItemTipsPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
ItemTipsPanel._tbDefine = {
{sPrefabPath = "CommonTipsEx/ItemTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.ItemTipsCtrl"}
}
ItemTipsPanel.Awake = function(self)
  -- function num : 0_0
end

ItemTipsPanel.OnEnable = function(self)
  -- function num : 0_1
end

ItemTipsPanel.OnDisable = function(self)
  -- function num : 0_2
end

ItemTipsPanel.OnDestroy = function(self)
  -- function num : 0_3
end

ItemTipsPanel.OnRelease = function(self)
  -- function num : 0_4
end

return ItemTipsPanel

