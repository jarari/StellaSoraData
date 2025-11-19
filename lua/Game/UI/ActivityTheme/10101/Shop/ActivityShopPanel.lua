local ActivityShopPanel = class("ActivityShopPanel", BasePanel)
ActivityShopPanel._sUIResRootPath = "UI_Activity/"
ActivityShopPanel._tbDefine = {
{sPrefabPath = "10101/Shop/ActivityShopPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.10101.Shop.ActivityShopCtrl"}
}
ActivityShopPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.nDefaultId = nil
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.nActId = tbParam[1]
    self.nDefaultId = tbParam[2]
  end
  self.actShopData = (PlayerData.Activity):GetActivityDataById(self.nActId)
end

ActivityShopPanel.OnEnable = function(self)
  -- function num : 0_1
end

ActivityShopPanel.OnDisable = function(self)
  -- function num : 0_2
end

ActivityShopPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return ActivityShopPanel

