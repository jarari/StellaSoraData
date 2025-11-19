local ActivityListPanel = class("ActivityListPanel", BasePanel)
ActivityListPanel._tbDefine = {
{sPrefabPath = "ActivityList/ActivityListPanel.prefab", sCtrlName = "Game.UI.ActivityList.ActivityListCtrl"}
}
ActivityListPanel.Awake = function(self)
  -- function num : 0_0
  self.nSelectGroup = nil
end

ActivityListPanel.OnEnable = function(self)
  -- function num : 0_1
end

ActivityListPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

ActivityListPanel.OnDisable = function(self)
  -- function num : 0_3
end

ActivityListPanel.OnDestroy = function(self)
  -- function num : 0_4
  self.nSelectGroup = nil
end

ActivityListPanel.OnRelease = function(self)
  -- function num : 0_5
end

return ActivityListPanel

