-- RaidPanel Panel

local RaidPanel = class("RaidPanel", BasePanel)
RaidPanel._bIsMainPanel = false
-- Panel 定义
RaidPanel._tbDefine = {
    {sPrefabPath = "Raid/RaidPanel.prefab", sCtrlName = "Game.UI.Raid.RaidCtrl"},
}
-------------------- base function --------------------
function RaidPanel:Awake()
end
function RaidPanel:OnEnable()
end
function RaidPanel:OnDisable()
end
function RaidPanel:OnDestroy()
end
-------------------- callback function --------------------
return RaidPanel
