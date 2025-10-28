-- MainViewSidePanel Panel

local MainViewSidePanel = class("MainViewSidePanel", BasePanel)
-- Panel 定义
MainViewSidePanel._nSnapshotPrePanel = 3
MainViewSidePanel._tbDefine = {
    {sPrefabPath = "MainViewEx/MainViewSidePanel.prefab", sCtrlName = "Game.UI.MainViewEx.MainViewSideCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function MainViewSidePanel:Awake()
end
function MainViewSidePanel:OnEnable()
end
function MainViewSidePanel:OnDisable()
end
function MainViewSidePanel:OnDestroy()
end
-------------------- callback function --------------------
return MainViewSidePanel
