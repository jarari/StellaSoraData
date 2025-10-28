-- ActivityShopPanel Panel

local ActivityShopPanel = class("ActivityShopPanel", BasePanel)
-- Panel 定义
ActivityShopPanel._sUIResRootPath = "UI_Activity/"
ActivityShopPanel._tbDefine = {
    {sPrefabPath = "Swim/Shop/ActivityShopPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.Swim.Shop.ActivityShopCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function ActivityShopPanel:Awake()
    self.nDefaultId = nil
    local tbParam = self:GetPanelParam()
    if type(tbParam) == "table" then
        self.nActId = tbParam[1]
        self.nDefaultId = tbParam[2]
    end

    self.actShopData = PlayerData.Activity:GetActivityDataById(self.nActId)
end
function ActivityShopPanel:OnEnable()
end
function ActivityShopPanel:OnDisable()
end
function ActivityShopPanel:OnDestroy()
end
-------------------- callback function --------------------
return ActivityShopPanel
