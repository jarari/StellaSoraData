local SkillInstanceResultPanel = class("SkillInstanceResultPanel", BasePanel)
SkillInstanceResultPanel._bAddToBackHistory = false
SkillInstanceResultPanel._tbDefine = {
{sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.BattleResult.SkillInstanceResultCtrl"}
}
SkillInstanceResultPanel.Awake = function(self)
  -- function num : 0_0
end

SkillInstanceResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

SkillInstanceResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

SkillInstanceResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return SkillInstanceResultPanel

