local MiningGameQuestPanel = class("MiningGamePanel", BasePanel)
MiningGameQuestPanel._bIsMainPanel = true
MiningGameQuestPanel._tbDefine = {
{sPrefabPath = "Activity/Mining/MiningGameQuestPanel.prefab", sCtrlName = "Game.UI.Play_Mining.MiningGameQuestCtrl"}
}
MiningGameQuestPanel.Awake = function(self)
  -- function num : 0_0
end

MiningGameQuestPanel.OnEnable = function(self)
  -- function num : 0_1
end

MiningGameQuestPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

MiningGameQuestPanel.OnDisable = function(self)
  -- function num : 0_3
end

MiningGameQuestPanel.OnDestroy = function(self)
  -- function num : 0_4
end

MiningGameQuestPanel.OnRelease = function(self)
  -- function num : 0_5
end

return MiningGameQuestPanel

