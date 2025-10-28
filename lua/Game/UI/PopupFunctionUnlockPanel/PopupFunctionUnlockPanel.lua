-- Panel 模板

local PopupFunctionUnlockPanel = class("PopupFunctionUnlockPanel", BasePanel)
PopupFunctionUnlockPanel._bIsMainPanel = false
PopupFunctionUnlockPanel._bAddToBackHistory = false

PopupFunctionUnlockPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
-- Panel 定义
--[[
PopupFunctionUnlockPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
PopupFunctionUnlockPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
PopupFunctionUnlockPanel._bIsMainPanel = true
PopupFunctionUnlockPanel._bAddToBackHistory = true
PopupFunctionUnlockPanel._nSnapshotPrePanel = 0

PopupFunctionUnlockPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
PopupFunctionUnlockPanel._tbDefine = {
    {sPrefabPath = "PopupFunctionUnlock/PopupFunctionUnlockPanel.prefab", sCtrlName = "Game.UI.PopupFunctionUnlockPanel.PopupFunctionUnlockCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function PopupFunctionUnlockPanel:Awake()
end
function PopupFunctionUnlockPanel:OnEnable()
end
function PopupFunctionUnlockPanel:OnDisable()
end
function PopupFunctionUnlockPanel:OnDestroy()
end
function PopupFunctionUnlockPanel:OnRelease()
end
-------------------- callback function --------------------
return PopupFunctionUnlockPanel
