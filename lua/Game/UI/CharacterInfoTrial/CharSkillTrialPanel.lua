local CharSkillTrialPanel = class("CharSkillTrialPanel", BasePanel)
CharSkillTrialPanel._tbDefine = {
{sPrefabPath = "CharacterInfoTrial/CharSkillTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharSkillTrialCtrl"}
}
CharSkillTrialPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.nCharId = tbParam[1]
  end
end

return CharSkillTrialPanel

