-- Panel 模板

local MiningGamePanel = class("MiningGamePanel", BasePanel)
-- Panel 定义
MiningGamePanel._bIsMainPanel = true
MiningGamePanel._tbDefine = {
    {sPrefabPath = "Play_Mining/MiningGamePanel.prefab", sCtrlName = "Game.UI.Play_Mining.MiningGameCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function MiningGamePanel:Awake()
    -- self.nActId = nil
    -- self.actData = nil
end
function MiningGamePanel:OnEnable()
end
function MiningGamePanel:OnAfterEnter()
end
function MiningGamePanel:OnDisable()
end
function MiningGamePanel:OnDestroy()
end
function MiningGamePanel:OnRelease()
end
-------------------- callback function --------------------
return MiningGamePanel
