-- Panel 模板

local MiningGameQuestPanel = class("MiningGamePanel", BasePanel)
-- Panel 定义
MiningGameQuestPanel._bIsMainPanel = true
MiningGameQuestPanel._tbDefine = {
    {sPrefabPath = "Activity/Mining/MiningGameQuestPanel.prefab", sCtrlName = "Game.UI.Play_Mining.MiningGameQuestCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function MiningGameQuestPanel:Awake()
    -- self.nActId = nil
    -- self.actData = nil
end
function MiningGameQuestPanel:OnEnable()
end
function MiningGameQuestPanel:OnAfterEnter()
end
function MiningGameQuestPanel:OnDisable()
end
function MiningGameQuestPanel:OnDestroy()
end
function MiningGameQuestPanel:OnRelease()
end
-------------------- callback function --------------------
return MiningGameQuestPanel
