local TalentPanel = class("TalentPanel", BasePanel)
TalentPanel._tbDefine = {
{sPrefabPath = "CharSkill/CharSkillPanel.prefab", sCtrlName = "Game.UI.CharSkill.CharSkillCtrl"}
}
TalentPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.nCharId = tbParam[1]
  end
end

return TalentPanel

