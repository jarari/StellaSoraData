-- BuildRenamePanel Panel

local BuildRenamePanel = class("BuildRenamePanel", BasePanel)
-- Panel 定义
BuildRenamePanel._bIsMainPanel = false
BuildRenamePanel._tbDefine = {
    {sPrefabPath = "StarTowerBuild/BuildRenamePanel.prefab", sCtrlName = "Game.UI.BuildPanelEx.BuildRenameCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function BuildRenamePanel:Awake()
end
function BuildRenamePanel:OnEnable()
end
function BuildRenamePanel:OnDisable()
end
function BuildRenamePanel:OnDestroy()
end
-------------------- callback function --------------------
return BuildRenamePanel
