-- MallPanel Panel

local MallPanel = class("MallPanel", BasePanel)
-- Panel 定义
MallPanel._tbDefine = {
    {sPrefabPath = "Mall/MallPanel.prefab", sCtrlName = "Game.UI.Mall.MallCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function MallPanel:Awake()
    self.nCurTog = nil
    self.nDefaultId = nil
    local tbParam = self:GetPanelParam()
    if type(tbParam) == "table" then
        self.nCurTog = tbParam[1]
        self.nDefaultId = tbParam[2]
        self.nTabParam = tbParam[3]
    end
end
function MallPanel:OnEnable()
end
function MallPanel:OnDisable()
end
function MallPanel:OnDestroy()
end
-------------------- callback function --------------------
return MallPanel
