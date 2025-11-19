local AnnouncementPanel = class("AnnouncementPanel", BasePanel)
AnnouncementPanel._bIsMainPanel = false
AnnouncementPanel._tbDefine = {
{sPrefabPath = "Announcement/UIAnnouncementPanel.prefab", sCtrlName = "Game.UI.GameAnnouncement.AnnouncementCtrl"}
}
AnnouncementPanel.Awake = function(self)
  -- function num : 0_0
end

AnnouncementPanel.OnEnable = function(self)
  -- function num : 0_1
end

AnnouncementPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

AnnouncementPanel.OnDisable = function(self)
  -- function num : 0_3
end

AnnouncementPanel.OnDestroy = function(self)
  -- function num : 0_4
end

AnnouncementPanel.OnRelease = function(self)
  -- function num : 0_5
end

return AnnouncementPanel

