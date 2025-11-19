local NoteSkillInfoPanel = class("NoteSkillInfoPanel", BasePanel)
NoteSkillInfoPanel._bIsMainPanel = false
NoteSkillInfoPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
NoteSkillInfoPanel._tbDefine = {
{sPrefabPath = "NoteSkill/NoteSkillInfoPanel.prefab", sCtrlName = "Game.UI.NoteSkill.NoteSkillInfoCtrl"}
}
NoteSkillInfoPanel.Awake = function(self)
  -- function num : 0_0
end

NoteSkillInfoPanel.OnEnable = function(self)
  -- function num : 0_1
end

NoteSkillInfoPanel.OnDisable = function(self)
  -- function num : 0_2
end

NoteSkillInfoPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return NoteSkillInfoPanel

