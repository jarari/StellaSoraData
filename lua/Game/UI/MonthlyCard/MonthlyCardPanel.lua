-- MonthlyCardPanel Panel

local MonthlyCardPanel = class("MonthlyCardPanel", BasePanel)
-- Panel 定义
MonthlyCardPanel._bIsMainPanel = false
MonthlyCardPanel._tbDefine = {
    {sPrefabPath = "MonthlyCard/MonthlyCardPanel.prefab", sCtrlName = "Game.UI.MonthlyCard.MonthlyCardCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function MonthlyCardPanel:Awake()
end
function MonthlyCardPanel:OnEnable()
end
function MonthlyCardPanel:OnDisable()
end
function MonthlyCardPanel:OnDestroy()
end
-------------------- callback function --------------------
return MonthlyCardPanel
