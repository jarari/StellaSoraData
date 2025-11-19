local ActivityPopUpPanel = class("ActivityPopUpPanel", BasePanel)
ActivityPopUpPanel._bIsMainPanel = false
ActivityPopUpPanel._tbDefine = {
{sPrefabPath = "ActivityList/ActivityPopUpPanel.prefab", sCtrlName = "Game.UI.ActivityList.ActivityPopUpCtrl"}
}
ActivityPopUpPanel.Awake = function(self)
  -- function num : 0_0
end

ActivityPopUpPanel.OnEnable = function(self)
  -- function num : 0_1
end

ActivityPopUpPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

ActivityPopUpPanel.OnDisable = function(self)
  -- function num : 0_3
end

ActivityPopUpPanel.OnDestroy = function(self)
  -- function num : 0_4
end

ActivityPopUpPanel.OnRelease = function(self)
  -- function num : 0_5
end

return ActivityPopUpPanel

