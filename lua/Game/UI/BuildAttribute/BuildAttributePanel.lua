-- BuildAttributePanel Panel

local BuildAttributePanel = class("BuildAttributePanel", BasePanel)
-- Panel 定义
BuildAttributePanel._bIsMainPanel = false
BuildAttributePanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
BuildAttributePanel._tbDefine = {
    {sPrefabPath = "BuildAttribute/BuildAttributePanel.prefab", sCtrlName = "Game.UI.BuildAttribute.BuildAttributeCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function BuildAttributePanel:Awake()
end
function BuildAttributePanel:OnEnable()
end
function BuildAttributePanel:OnDisable()
end
function BuildAttributePanel:OnDestroy()
end
-------------------- callback function --------------------
return BuildAttributePanel
