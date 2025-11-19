local CharSucBarPanel = class("CharSucBarPanel", BasePanel)
CharSucBarPanel._bIsMainPanel = false
CharSucBarPanel._tbDefine = {
{sPrefabPath = "SuccessBarEx/CharSucBarPanel.prefab", sCtrlName = "Game.UI.SuccessBarEx.CharSucBarCtrl"}
}
CharSucBarPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.mapData = tbParam[1]
    self.bUp = tbParam[2]
    self.callback = tbParam[3]
  end
end

CharSucBarPanel.OnEnable = function(self)
  -- function num : 0_1
end

CharSucBarPanel.OnDisable = function(self)
  -- function num : 0_2
end

CharSucBarPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return CharSucBarPanel

