-- CharSucBarPanel Panel

local CharSucBarPanel = class("CharSucBarPanel", BasePanel)
-- Panel 定义




CharSucBarPanel._bIsMainPanel = false

CharSucBarPanel._tbDefine = {
    {sPrefabPath = "SuccessBarEx/CharSucBarPanel.prefab", sCtrlName = "Game.UI.SuccessBarEx.CharSucBarCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function CharSucBarPanel:Awake()
    local tbParam = self:GetPanelParam()
    if type(tbParam) == "table" then
        self.mapData = tbParam[1]
        self.bUp = tbParam[2]
        self.callback = tbParam[3]
    end
end
function CharSucBarPanel:OnEnable()
end
function CharSucBarPanel:OnDisable()
end
function CharSucBarPanel:OnDestroy()
end
-------------------- callback function --------------------
return CharSucBarPanel
