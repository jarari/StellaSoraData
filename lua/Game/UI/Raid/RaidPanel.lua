local RaidPanel = class("RaidPanel", BasePanel)
RaidPanel._bIsMainPanel = false
RaidPanel._tbDefine = {
{sPrefabPath = "Raid/RaidPanel.prefab", sCtrlName = "Game.UI.Raid.RaidCtrl"}
}
RaidPanel.Awake = function(self)
  -- function num : 0_0
end

RaidPanel.OnEnable = function(self)
  -- function num : 0_1
end

RaidPanel.OnDisable = function(self)
  -- function num : 0_2
end

RaidPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return RaidPanel

