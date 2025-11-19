local MonthlyCardPanel = class("MonthlyCardPanel", BasePanel)
MonthlyCardPanel._bIsMainPanel = false
MonthlyCardPanel._tbDefine = {
{sPrefabPath = "MonthlyCard/MonthlyCardPanel.prefab", sCtrlName = "Game.UI.MonthlyCard.MonthlyCardCtrl"}
}
MonthlyCardPanel.Awake = function(self)
  -- function num : 0_0
end

MonthlyCardPanel.OnEnable = function(self)
  -- function num : 0_1
end

MonthlyCardPanel.OnDisable = function(self)
  -- function num : 0_2
end

MonthlyCardPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return MonthlyCardPanel

