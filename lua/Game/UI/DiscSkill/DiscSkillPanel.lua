local DiscSkillPanel = class("DiscSkillPanel", BasePanel)
DiscSkillPanel._bIsMainPanel = false
DiscSkillPanel._tbDefine = {
{sPrefabPath = "DiscSkill/DiscSkillPanel.prefab", sCtrlName = "Game.UI.DiscSkill.DiscSkillCtrl"}
}
DiscSkillPanel.Awake = function(self)
  -- function num : 0_0
end

DiscSkillPanel.OnEnable = function(self)
  -- function num : 0_1
end

DiscSkillPanel.OnDisable = function(self)
  -- function num : 0_2
end

DiscSkillPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return DiscSkillPanel

