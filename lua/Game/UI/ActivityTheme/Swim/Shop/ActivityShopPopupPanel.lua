-- ActivityShopPopupPanel Panel

local ActivityShopPopupPanel = class("ActivityShopPopupPanel", BasePanel)
-- Panel 定义
ActivityShopPopupPanel._sUIResRootPath = "UI_Activity/"
ActivityShopPopupPanel._bIsMainPanel = false
ActivityShopPopupPanel._tbDefine = {
    {sPrefabPath = "Swim/Shop/ActivityShopPopupPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.Swim.Shop.ActivityShopPopupCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function ActivityShopPopupPanel:Awake()
end
function ActivityShopPopupPanel:OnEnable()
end
function ActivityShopPopupPanel:OnDisable()
end
function ActivityShopPopupPanel:OnDestroy()
end
-------------------- callback function --------------------
return ActivityShopPopupPanel
