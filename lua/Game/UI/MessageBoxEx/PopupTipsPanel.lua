-- PopupTipsPanel Panel

local PopupTipsPanel = class("PopupTipsPanel", BasePanel)
-- Panel 定义


PopupTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
PopupTipsPanel._bAddToBackHistory = false
--[[
PopupTipsPanel._bIsMainPanel = true
PopupTipsPanel._nSnapshotPrePanel = 0
]]
PopupTipsPanel._tbDefine = {
    {sPrefabPath = "PopupTips/PopupTipsPanel.prefab", sCtrlName = "Game.UI.MessageBoxEx.PopupTipsCtrl"},
}

-------------------- local function --------------------
-------------------- base function --------------------
function PopupTipsPanel:Awake()
end
function PopupTipsPanel:OnEnable()
end
function PopupTipsPanel:OnDisable()
end
function PopupTipsPanel:OnDestroy()
end
-------------------- callback function --------------------
return PopupTipsPanel
