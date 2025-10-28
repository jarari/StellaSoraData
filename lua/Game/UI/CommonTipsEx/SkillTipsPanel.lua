-- Panel 模板

local SkillTipsPanel = class("SkillTipsPanel", BasePanel)
SkillTipsPanel._bIsMainPanel = false
SkillTipsPanel._bAddToBackHistory = false

SkillTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
-- Panel 定义
--[[
SkillTipsPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
SkillTipsPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
SkillTipsPanel._bIsMainPanel = true
SkillTipsPanel._bAddToBackHistory = true
SkillTipsPanel._nSnapshotPrePanel = 0

SkillTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
SkillTipsPanel._tbDefine = {
    {sPrefabPath = "CommonTipsEx/SkillTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.SkillTipsCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function SkillTipsPanel:Awake()
end
function SkillTipsPanel:OnEnable()
end
function SkillTipsPanel:OnDisable()
end
function SkillTipsPanel:OnDestroy()
end
function SkillTipsPanel:OnRelease()
end
-------------------- callback function --------------------
return SkillTipsPanel
