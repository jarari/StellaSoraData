local MallPanel = class("MallPanel", BasePanel)
MallPanel._tbDefine = {
{sPrefabPath = "Mall/MallPanel.prefab", sCtrlName = "Game.UI.Mall.MallCtrl"}
}
MallPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.nCurTog = nil
  self.nDefaultId = nil
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.nCurTog = tbParam[1]
    self.nDefaultId = tbParam[2]
    self.nTabParam = tbParam[3]
  end
end

MallPanel.OnEnable = function(self)
  -- function num : 0_1
end

MallPanel.OnDisable = function(self)
  -- function num : 0_2
end

MallPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return MallPanel

