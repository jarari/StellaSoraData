-- NoteSkillPreviewPanel Panel

local NoteSkillPreviewPanel = class("NoteSkillPreviewPanel", BasePanel)
-- Panel 定义
NoteSkillPreviewPanel._bIsMainPanel = false
NoteSkillPreviewPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
NoteSkillPreviewPanel._tbDefine = {
    {sPrefabPath = "NoteSkill/NoteSkillPreviewPanel.prefab", sCtrlName = "Game.UI.NoteSkill.NoteSkillPreviewCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function NoteSkillPreviewPanel:Awake()
end
function NoteSkillPreviewPanel:OnEnable()
end
function NoteSkillPreviewPanel:OnDisable()
end
function NoteSkillPreviewPanel:OnDestroy()
end
-------------------- callback function --------------------
return NoteSkillPreviewPanel
