-- Panel 模板

local LampNoticePanel = class("LampNoticePanel", BasePanel)

-- Panel 定义
--[[
LampNoticePanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
LampNoticePanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
LampNoticePanel._bIsMainPanel = true
LampNoticePanel._bAddToBackHistory = true
LampNoticePanel._nSnapshotPrePanel = 0
LampNoticePanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
LampNoticePanel._bIsMainPanel = false
LampNoticePanel._sSortingLayerName = AllEnum.SortingLayerName.Overlay
LampNoticePanel._tbDefine = {
    {sPrefabPath = "LampNotice/LampNoticePanel.prefab", sCtrlName = "Game.UI.LampNotice.LampNoticeCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function LampNoticePanel:Awake()
end
function LampNoticePanel:OnEnable()
end
function LampNoticePanel:OnAfterEnter()
end
function LampNoticePanel:OnDisable()
end
function LampNoticePanel:OnDestroy()
end
function LampNoticePanel:OnRelease()
end
-------------------- callback function --------------------
return LampNoticePanel
