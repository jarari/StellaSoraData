-- Panel 模板

local BuildSavePanel = class("BuildSavePanel", BasePanel)

-- Panel 定义
--[[
BuildSavePanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
BuildSavePanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
BuildSavePanel._bIsMainPanel = true
BuildSavePanel._bAddToBackHistory = true
BuildSavePanel._nSnapshotPrePanel = 0

BuildSavePanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
BuildSavePanel._tbDefine = {
    {sPrefabPath = "RoguelikeBuildEX/RoguelikeBuildSavePanel.prefab", sCtrlName = "Game.UI.BuildPanelEx.BuildSaveCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function BuildSavePanel:Awake()
end
function BuildSavePanel:OnEnable()
end
function BuildSavePanel:OnDisable()
end
function BuildSavePanel:OnDestroy()
end
function BuildSavePanel:OnRelease()
end
-------------------- callback function --------------------
return BuildSavePanel
