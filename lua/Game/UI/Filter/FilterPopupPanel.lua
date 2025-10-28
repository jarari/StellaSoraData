local FilterPopupPanel = class("FilterPopupPanel", BasePanel)
-- Panel 定义
FilterPopupPanel._bIsMainPanel = false
FilterPopupPanel._tbDefine = {
    {sPrefabPath = "Filter/FilterPopupPanel.prefab", sCtrlName = "Game.UI.Filter.FilterPopupCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function FilterPopupPanel:Awake()
end
function FilterPopupPanel:OnEnable()
end
function FilterPopupPanel:OnDisable()
end
function FilterPopupPanel:OnDestroy()
end
-------------------- callback function --------------------
return FilterPopupPanel
