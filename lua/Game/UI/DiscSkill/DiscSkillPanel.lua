-- DiscSkillPanel Panel

local DiscSkillPanel = class("DiscSkillPanel", BasePanel)
-- Panel 定义
DiscSkillPanel._bIsMainPanel = false
DiscSkillPanel._tbDefine = {
    {sPrefabPath = "DiscSkill/DiscSkillPanel.prefab", sCtrlName = "Game.UI.DiscSkill.DiscSkillCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function DiscSkillPanel:Awake()
end
function DiscSkillPanel:OnEnable()
end
function DiscSkillPanel:OnDisable()
end
function DiscSkillPanel:OnDestroy()
end
-------------------- callback function --------------------
return DiscSkillPanel
