local SubSkillDisplayPanel = class("SubSkillDisplayPanel", BasePanel)
SubSkillDisplayPanel._bIsMainPanel = false
SubSkillDisplayPanel._tbDefine = {
{sPrefabPath = "Battle/SubSkillDisplay_forActor2dEditor.prefab"}
, 
{sPrefabPath = "Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"}
}
if RUNNING_ACTOR2D_EDITOR ~= true then
  (table.remove)(SubSkillDisplayPanel._tbDefine, 1)
end
SubSkillDisplayPanel.Awake = function(self)
  -- function num : 0_0
end

SubSkillDisplayPanel.OnEnable = function(self)
  -- function num : 0_1
end

SubSkillDisplayPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

SubSkillDisplayPanel.OnDisable = function(self)
  -- function num : 0_3
end

SubSkillDisplayPanel.OnDestroy = function(self)
  -- function num : 0_4
end

SubSkillDisplayPanel.OnRelease = function(self)
  -- function num : 0_5
end

return SubSkillDisplayPanel

