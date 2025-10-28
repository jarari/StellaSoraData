-- NoteSkillPanel Panel

local NoteSkillPanel = class("NoteSkillPanel", BasePanel)
-- Panel 定义
NoteSkillPanel._bIsMainPanel = false
NoteSkillPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
NoteSkillPanel._tbDefine = {
    {sPrefabPath = "NoteSkill/NoteSkillPanel.prefab", sCtrlName = "Game.UI.NoteSkill.NoteSkillCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function NoteSkillPanel:Awake()
end
function NoteSkillPanel:OnEnable()
end
function NoteSkillPanel:OnDisable()
end
function NoteSkillPanel:OnDestroy()
end
-------------------- callback function --------------------
return NoteSkillPanel
