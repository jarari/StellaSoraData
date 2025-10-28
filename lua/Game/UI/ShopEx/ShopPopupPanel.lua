-- ShopPopupPanel Panel

local ShopPopupPanel = class("ShopPopupPanel", BasePanel)
-- Panel 定义
ShopPopupPanel._bIsMainPanel = false
ShopPopupPanel._tbDefine = {
    {sPrefabPath = "ShopEx/ShopPopupPanel.prefab", sCtrlName = "Game.UI.ShopEx.ShopPopupCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function ShopPopupPanel:Awake()
end
function ShopPopupPanel:OnEnable()
end
function ShopPopupPanel:OnDisable()
end
function ShopPopupPanel:OnDestroy()
end
-------------------- callback function --------------------
return ShopPopupPanel
