local ActivityLevelsSelectPanel = class("ActivityLevelsSelectPanel", BasePanel)
-- Panel 定义
ActivityLevelsSelectPanel._sUIResRootPath = "UI_Activity/"
ActivityLevelsSelectPanel._tbDefine = {
    {sPrefabPath = "Swim/ActivityLevels/ActivityLevelsSelect.prefab", sCtrlName = "Game.UI.ActivityTheme.Swim.ActivityLevels.ActivityLevelsSelectCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function ActivityLevelsSelectPanel:Awake()
    -- self.nActId = nil
    -- self.actData = nil
end
function ActivityLevelsSelectPanel:OnEnable()
end
function ActivityLevelsSelectPanel:OnAfterEnter()
end
function ActivityLevelsSelectPanel:OnDisable()
end
function ActivityLevelsSelectPanel:OnDestroy()
end
function ActivityLevelsSelectPanel:OnRelease()
end
-------------------- callback function --------------------
return ActivityLevelsSelectPanel