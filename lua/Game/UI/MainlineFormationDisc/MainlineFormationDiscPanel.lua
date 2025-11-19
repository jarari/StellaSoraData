local MainlineFormationDiscPanel = class("MainlineFormationDiscPanel", BasePanel)
MainlineFormationDiscPanel._tbDefine = {
{sPrefabPath = "MainlineFormationDisc/MainlineFormationDiscPanelEx.prefab", sCtrlName = "Game.UI.MainlineFormationDiscEx.MainlineFormationDiscCtrl"}
}
MainlineFormationDiscPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.curRoguelikeId = nil
  self.nTeamIndex = nil
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.curRoguelikeId = tbParam[1]
    self.nTeamIndex = tbParam[2]
    self.bSweep = tbParam[3]
  end
end

MainlineFormationDiscPanel.OnEnable = function(self)
  -- function num : 0_1
end

MainlineFormationDiscPanel.OnDisable = function(self)
  -- function num : 0_2
end

MainlineFormationDiscPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return MainlineFormationDiscPanel

