local RogueBossResultPanel = class("RogueBossResultPanel", BasePanel)
RogueBossResultPanel._bAddToBackHistory = false
RogueBossResultPanel._tbDefine = {
{sPrefabPath = "RogueBossResult/RogueBossResultPanel.prefab", sCtrlName = "Game.UI.RogueBossResult.RogueBossResultCtrl"}
}
RogueBossResultPanel.Awake = function(self)
  -- function num : 0_0
end

RogueBossResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

RogueBossResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

RogueBossResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return RogueBossResultPanel

