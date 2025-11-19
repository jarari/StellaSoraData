local NoteSkillPanel = class("NoteSkillPanel", BasePanel)
NoteSkillPanel._bIsMainPanel = false
NoteSkillPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
NoteSkillPanel._tbDefine = {
{sPrefabPath = "NoteSkill/NoteSkillPanel.prefab", sCtrlName = "Game.UI.NoteSkill.NoteSkillCtrl"}
}
NoteSkillPanel.Awake = function(self)
  -- function num : 0_0
end

NoteSkillPanel.OnEnable = function(self)
  -- function num : 0_1
end

NoteSkillPanel.OnDisable = function(self)
  -- function num : 0_2
end

NoteSkillPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return NoteSkillPanel

