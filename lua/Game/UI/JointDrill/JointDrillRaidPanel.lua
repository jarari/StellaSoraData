local JointDrillRaidPanel = class("JointDrillRaidPanel", BasePanel)

JointDrillRaidPanel._bIsMainPanel = false

JointDrillRaidPanel._tbDefine = {
    {sPrefabPath = "Play_JointDrill/JointDrillRaidPanel.prefab", sCtrlName = "Game.UI.JointDrill.JointDrillRaidCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function JointDrillRaidPanel:Awake()
end
function JointDrillRaidPanel:OnEnable()
end
function JointDrillRaidPanel:OnAfterEnter()
end
function JointDrillRaidPanel:OnDisable()
end
function JointDrillRaidPanel:OnDestroy()
end
function JointDrillRaidPanel:OnRelease()
end
-------------------- callback function --------------------
return JointDrillRaidPanel
