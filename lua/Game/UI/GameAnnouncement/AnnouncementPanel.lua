-- Panel 模板

local AnnouncementPanel = class("AnnouncementPanel", BasePanel)
-- Panel 定义
AnnouncementPanel._bIsMainPanel = false
--[[
AnnouncementPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
AnnouncementPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
AnnouncementPanel._bIsMainPanel = true
AnnouncementPanel._bAddToBackHistory = true
AnnouncementPanel._nSnapshotPrePanel = 0
AnnouncementPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
AnnouncementPanel._tbDefine = {
    {sPrefabPath = "Announcement/UIAnnouncementPanel.prefab", sCtrlName = "Game.UI.GameAnnouncement.AnnouncementCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function AnnouncementPanel:Awake()
end
function AnnouncementPanel:OnEnable()
end
function AnnouncementPanel:OnAfterEnter()
end
function AnnouncementPanel:OnDisable()
end
function AnnouncementPanel:OnDestroy()
end
function AnnouncementPanel:OnRelease()
end
-------------------- callback function --------------------
return AnnouncementPanel
