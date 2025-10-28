local JointDrilRankDetailPanel = class("JointDrilRankDetailPanel", BasePanel)

JointDrilRankDetailPanel._bIsMainPanel = false

JointDrilRankDetailPanel._tbDefine = {
    {sPrefabPath = "Play_JointDrill/JointDrillRankDetailPanel.prefab", sCtrlName = "Game.UI.JointDrill.JointDrillRankDetailCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function JointDrilRankDetailPanel:Awake()
end
function JointDrilRankDetailPanel:OnEnable()
end
function JointDrilRankDetailPanel:OnAfterEnter()
end
function JointDrilRankDetailPanel:OnDisable()
end
function JointDrilRankDetailPanel:OnDestroy()
end
function JointDrilRankDetailPanel:OnRelease()
end
-------------------- callback function --------------------
return JointDrilRankDetailPanel
