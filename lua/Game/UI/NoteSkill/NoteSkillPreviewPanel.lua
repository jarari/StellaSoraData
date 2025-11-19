local NoteSkillPreviewPanel = class("NoteSkillPreviewPanel", BasePanel)
NoteSkillPreviewPanel._bIsMainPanel = false
NoteSkillPreviewPanel._sSortingLayerName = (AllEnum.SortingLayerName).UI_Top
NoteSkillPreviewPanel._tbDefine = {
{sPrefabPath = "NoteSkill/NoteSkillPreviewPanel.prefab", sCtrlName = "Game.UI.NoteSkill.NoteSkillPreviewCtrl"}
}
NoteSkillPreviewPanel.Awake = function(self)
  -- function num : 0_0
end

NoteSkillPreviewPanel.OnEnable = function(self)
  -- function num : 0_1
end

NoteSkillPreviewPanel.OnDisable = function(self)
  -- function num : 0_2
end

NoteSkillPreviewPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return NoteSkillPreviewPanel

