local BasePanel = require("GameCore.UI.BasePanel")
local AffinityRewardPanel = class("AffinityRewardPanel", BasePanel)
AffinityRewardPanel._bIsMainPanel = false
AffinityRewardPanel._tbDefine = {
{sPrefabPath = "StarTowerBook/NpcAffinityRewardPanel.prefab", sCtrlName = "Game.UI.StarTowerBook.Affinity.AffinityRewardCtrl"}
}
AffinityRewardPanel.Awake = function(self)
  -- function num : 0_0
end

AffinityRewardPanel.OnEnable = function(self)
  -- function num : 0_1
end

AffinityRewardPanel.OnDisable = function(self)
  -- function num : 0_2
end

AffinityRewardPanel.OnDestroy = function(self)
  -- function num : 0_3
end

AffinityRewardPanel.OnRelease = function(self)
  -- function num : 0_4
end

return AffinityRewardPanel

