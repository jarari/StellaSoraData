-- Panel 模板

local SkillInstanceLevelSelectPanel = class("SkillInstanceLevelSelectPanel", BasePanel)

SkillInstanceLevelSelectPanel._tbDefine = {
    {sPrefabPath = "SkillInstanceLevelSelect/SkillInstanceLevelSelect.prefab", sCtrlName = "Game.UI.SkillInstanceLevelSelect.SkillInstanceLevelSelectCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function SkillInstanceLevelSelectPanel:Awake()
end
function SkillInstanceLevelSelectPanel:OnEnable()
end
function SkillInstanceLevelSelectPanel:OnDisable()
end
function SkillInstanceLevelSelectPanel:OnDestroy()
end
function SkillInstanceLevelSelectPanel:OnRelease()
end
-------------------- callback function --------------------
return SkillInstanceLevelSelectPanel
