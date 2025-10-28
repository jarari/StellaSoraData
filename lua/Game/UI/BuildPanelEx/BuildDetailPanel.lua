-- Panel 模板

local BuildDetailPanel = class("BuildDetailPanel", BasePanel)

-- Panel 定义
--[[
BuildDetailPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
BuildDetailPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
BuildDetailPanel._bIsMainPanel = true
BuildDetailPanel._bAddToBackHistory = true
BuildDetailPanel._nSnapshotPrePanel = 0

BuildDetailPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
BuildDetailPanel._tbDefine = {
    {sPrefabPath = "RoguelikeBuildEX/RoguelikeBuildDetailPanel.prefab", sCtrlName = "Game.UI.BuildPanelEx.BuildDetailCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function BuildDetailPanel:Awake()
end
function BuildDetailPanel:OnEnable()
end
function BuildDetailPanel:OnDisable()
end
function BuildDetailPanel:OnDestroy()
end
function BuildDetailPanel:OnRelease()
end
-------------------- callback function --------------------
return BuildDetailPanel
