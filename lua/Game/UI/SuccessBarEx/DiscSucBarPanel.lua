local DiscSucBarPanel = class("DiscSucBarPanel", BasePanel)
DiscSucBarPanel._bIsMainPanel = false
DiscSucBarPanel._tbDefine = {
{sPrefabPath = "SuccessBarEx/DiscSucBarPanel.prefab", sCtrlName = "Game.UI.SuccessBarEx.DiscSucBarCtrl"}
}
DiscSucBarPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.mapData = tbParam[1]
    self.nCurTog = tbParam[2]
    self.callback = tbParam[3]
  end
end

DiscSucBarPanel.OnEnable = function(self)
  -- function num : 0_1
end

DiscSucBarPanel.OnDisable = function(self)
  -- function num : 0_2
end

DiscSucBarPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return DiscSucBarPanel

