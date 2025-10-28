-- Panel 模板

local JointDrillResultPanel = class("JointDrillResultPanel", BasePanel)

JointDrillResultPanel._tbDefine = {
    {sPrefabPath = "Play_JointDrill/JointDrillResultPanel.prefab", sCtrlName = "Game.UI.JointDrill.JointDrillResultCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function JointDrillResultPanel:Awake()
end
function JointDrillResultPanel:OnEnable()
end
function JointDrillResultPanel:OnAfterEnter()
end
function JointDrillResultPanel:OnDisable()
end
function JointDrillResultPanel:OnDestroy()
end
function JointDrillResultPanel:OnRelease()
end
-------------------- callback function --------------------
return JointDrillResultPanel
