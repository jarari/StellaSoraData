-- 活动界面

local ActivityListPanel = class("ActivityListPanel", BasePanel)
ActivityListPanel._tbDefine = {
    {sPrefabPath = "ActivityList/ActivityListPanel.prefab", sCtrlName = "Game.UI.ActivityList.ActivityListCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function ActivityListPanel:Awake()
    self.nSelectGroup = nil
end
function ActivityListPanel:OnEnable()
end
function ActivityListPanel:OnAfterEnter()
    
end
function ActivityListPanel:OnDisable()
end
function ActivityListPanel:OnDestroy()
    self.nSelectGroup = nil
end
function ActivityListPanel:OnRelease()
end
-------------------- callback function --------------------
return ActivityListPanel
