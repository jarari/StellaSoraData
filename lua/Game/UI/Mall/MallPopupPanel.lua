-- MallPopupPanel Panel

local MallPopupPanel = class("MallPopupPanel", BasePanel)
-- Panel 定义
MallPopupPanel._bIsMainPanel = false
MallPopupPanel._tbDefine = {
    {sPrefabPath = "Mall/MallPopupPanel.prefab", sCtrlName = "Game.UI.Mall.MallPopupCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function MallPopupPanel:Awake()
end
function MallPopupPanel:OnEnable()
end
function MallPopupPanel:OnDisable()
end
function MallPopupPanel:OnDestroy()
end
-------------------- callback function --------------------
return MallPopupPanel
