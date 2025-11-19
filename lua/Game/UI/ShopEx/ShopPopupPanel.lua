local ShopPopupPanel = class("ShopPopupPanel", BasePanel)
ShopPopupPanel._bIsMainPanel = false
ShopPopupPanel._tbDefine = {
{sPrefabPath = "ShopEx/ShopPopupPanel.prefab", sCtrlName = "Game.UI.ShopEx.ShopPopupCtrl"}
}
ShopPopupPanel.Awake = function(self)
  -- function num : 0_0
end

ShopPopupPanel.OnEnable = function(self)
  -- function num : 0_1
end

ShopPopupPanel.OnDisable = function(self)
  -- function num : 0_2
end

ShopPopupPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return ShopPopupPanel

