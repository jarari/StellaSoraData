-- Panel 模板

local PopupSkillPanel = class("PopupSkillPanel", BasePanel)
PopupSkillPanel._bIsMainPanel = false
PopupSkillPanel._bAddToBackHistory = false

PopupSkillPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
-- Panel 定义
--[[
PopupSkillPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
PopupSkillPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
PopupSkillPanel._bIsMainPanel = true
PopupSkillPanel._bAddToBackHistory = true
PopupSkillPanel._nSnapshotPrePanel = 0

PopupSkillPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
PopupSkillPanel._tbDefine = {
    {sPrefabPath = "CommonTipsEx/PopupSkillPanel/PopupSkillPanel.prefab", sCtrlName = "Game.UI.CommonTipsEx.PopupSkillCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function PopupSkillPanel:Awake()
end
function PopupSkillPanel:OnEnable()
end
function PopupSkillPanel:OnDisable()
end
function PopupSkillPanel:OnDestroy()
end
function PopupSkillPanel:OnRelease()
end
-------------------- callback function --------------------
return PopupSkillPanel
