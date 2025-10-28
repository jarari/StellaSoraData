-- Panel 模板

local DiscSkillTipsPanel = class("DiscSkillTipsPanel", BasePanel)
DiscSkillTipsPanel._bIsMainPanel = false
DiscSkillTipsPanel._bAddToBackHistory = false

DiscSkillTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
-- Panel 定义
--[[
DiscSkillTipsPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
DiscSkillTipsPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
DiscSkillTipsPanel._bIsMainPanel = true
DiscSkillTipsPanel._bAddToBackHistory = true
DiscSkillTipsPanel._nSnapshotPrePanel = 0

DiscSkillTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
DiscSkillTipsPanel._tbDefine = {
    {sPrefabPath = "CommonTipsEx/DiscSkillTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.DiscSkillTipsCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function DiscSkillTipsPanel:Awake()
end
function DiscSkillTipsPanel:OnEnable()
end
function DiscSkillTipsPanel:OnDisable()
end
function DiscSkillTipsPanel:OnDestroy()
end
function DiscSkillTipsPanel:OnRelease()
end
-------------------- callback function --------------------
return DiscSkillTipsPanel
