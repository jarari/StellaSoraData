-- 活动弹窗界面

local ActivityPopUpPanel = class("ActivityPopUpPanel", BasePanel)
ActivityPopUpPanel._bIsMainPanel = false

ActivityPopUpPanel._tbDefine = {
    {sPrefabPath = "ActivityList/ActivityPopUpPanel.prefab", sCtrlName = "Game.UI.ActivityList.ActivityPopUpCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function ActivityPopUpPanel:Awake()
end
function ActivityPopUpPanel:OnEnable()
end
function ActivityPopUpPanel:OnAfterEnter()
    
end
function ActivityPopUpPanel:OnDisable()
end
function ActivityPopUpPanel:OnDestroy()
end
function ActivityPopUpPanel:OnRelease()
end
-------------------- callback function --------------------
return ActivityPopUpPanel
