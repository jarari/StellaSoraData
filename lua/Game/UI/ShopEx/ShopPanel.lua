local ShopPanel = class("ShopPanel", BasePanel)
ShopPanel._tbDefine = {
{sPrefabPath = "ShopEx/ShopPanel.prefab", sCtrlName = "Game.UI.ShopEx.ShopCtrl"}
}
ShopPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.nDefaultId = nil
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.nDefaultId = tbParam[1]
  end
end

ShopPanel.OnEnable = function(self)
  -- function num : 0_1
end

ShopPanel.OnDisable = function(self)
  -- function num : 0_2
end

ShopPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return ShopPanel

