-- Panel 模板

local SubSkillDisplayPanel = class("SubSkillDisplayPanel", BasePanel)
SubSkillDisplayPanel._bIsMainPanel = false
-- Panel 定义
--[[
SubSkillDisplayPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
SubSkillDisplayPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
SubSkillDisplayPanel._bIsMainPanel = true
SubSkillDisplayPanel._bAddToBackHistory = true
SubSkillDisplayPanel._nSnapshotPrePanel = 0
SubSkillDisplayPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
SubSkillDisplayPanel._tbDefine = {
    {sPrefabPath = "Battle/SubSkillDisplay_forActor2dEditor.prefab"},
    {sPrefabPath = "Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"},
}
if RUNNING_ACTOR2D_EDITOR ~= true then
    table.remove(SubSkillDisplayPanel._tbDefine, 1)
end
-------------------- local function --------------------

-------------------- base function --------------------
function SubSkillDisplayPanel:Awake()
end
function SubSkillDisplayPanel:OnEnable()
end
function SubSkillDisplayPanel:OnAfterEnter()
end
function SubSkillDisplayPanel:OnDisable()
end
function SubSkillDisplayPanel:OnDestroy()
end
function SubSkillDisplayPanel:OnRelease()
end
-------------------- callback function --------------------
return SubSkillDisplayPanel
