-- DiscSucBarPanel Panel

local DiscSucBarPanel = class("DiscSucBarPanel", BasePanel)
-- Panel 定义

DiscSucBarPanel._bIsMainPanel = false

DiscSucBarPanel._tbDefine = {
    {sPrefabPath = "SuccessBarEx/DiscSucBarPanel.prefab", sCtrlName = "Game.UI.SuccessBarEx.DiscSucBarCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function DiscSucBarPanel:Awake()
    local tbParam = self:GetPanelParam()
    if type(tbParam) == "table" then
        self.mapData = tbParam[1]
        self.nCurTog = tbParam[2]
        self.callback = tbParam[3]
    end
end
function DiscSucBarPanel:OnEnable()
end
function DiscSucBarPanel:OnDisable()
end
function DiscSucBarPanel:OnDestroy()
end
-------------------- callback function --------------------
return DiscSucBarPanel
