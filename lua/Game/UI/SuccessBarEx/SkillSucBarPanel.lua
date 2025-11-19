local SkillSucBarPanel = class("SkillSucBarPanel", BasePanel)
SkillSucBarPanel._bIsMainPanel = false
SkillSucBarPanel._tbDefine = {
{sPrefabPath = "SuccessBarEx/SkillSucBarPanel.prefab", sCtrlName = "Game.UI.SuccessBarEx.SkillSucBarCtrl"}
}
SkillSucBarPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local tbParam = self:GetPanelParam()
  if type(tbParam) == "table" then
    self.mapData = tbParam[1]
    self.callback = tbParam[2]
  end
end

SkillSucBarPanel.OnEnable = function(self)
  -- function num : 0_1
end

SkillSucBarPanel.OnDisable = function(self)
  -- function num : 0_2
end

SkillSucBarPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return SkillSucBarPanel

