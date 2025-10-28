-- Panel 模板

local GachaPreviewPanel = class("GachaPreviewPanel", BasePanel)
GachaPreviewPanel._bIsMainPanel = false
-- Panel 定义
--[[
GachaPreviewPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
GachaPreviewPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
GachaPreviewPanel._bIsMainPanel = true
GachaPreviewPanel._bAddToBackHistory = true
GachaPreviewPanel._nSnapshotPrePanel = 0
GachaPreviewPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
GachaPreviewPanel._tbDefine = {
    {sPrefabPath = "GachaEx/GachaCharInfoPanel.prefab", sCtrlName = "Game.UI.GachaEx.GachaPreview.GachaPreviewCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function GachaPreviewPanel:Awake()
end
function GachaPreviewPanel:OnEnable()
end
function GachaPreviewPanel:OnDisable()
end
function GachaPreviewPanel:OnDestroy()
end
function GachaPreviewPanel:OnRelease()
end
-------------------- callback function --------------------
return GachaPreviewPanel
