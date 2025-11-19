local DailyCheckInPanel = class("DailyCheckInPanel", BasePanel)
DailyCheckInPanel._bIsMainPanel = false
DailyCheckInPanel._tbDefine = {
{sPrefabPath = "CheckIn/DailyCheckInPanel.prefab", sCtrlName = "Game.UI.CheckIn.DailyCheckInCtrl"}
}
DailyCheckInPanel.Awake = function(self)
  -- function num : 0_0
end

DailyCheckInPanel.OnEnable = function(self)
  -- function num : 0_1
end

DailyCheckInPanel.OnDisable = function(self)
  -- function num : 0_2
end

DailyCheckInPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return DailyCheckInPanel

