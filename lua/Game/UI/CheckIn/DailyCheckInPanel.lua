-- DailyCheckInPanel Panel

local DailyCheckInPanel = class("DailyCheckInPanel", BasePanel)
-- Panel 定义
DailyCheckInPanel._bIsMainPanel = false
DailyCheckInPanel._tbDefine = {
    {sPrefabPath = "CheckIn/DailyCheckInPanel.prefab", sCtrlName = "Game.UI.CheckIn.DailyCheckInCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function DailyCheckInPanel:Awake()
end
function DailyCheckInPanel:OnEnable()
end
function DailyCheckInPanel:OnDisable()
end
function DailyCheckInPanel:OnDestroy()
end
-------------------- callback function --------------------
return DailyCheckInPanel
