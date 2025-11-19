local MiningGamePanel = class("MiningGamePanel", BasePanel)
MiningGamePanel._bIsMainPanel = true
MiningGamePanel._bAddToBackHistory = true
MiningGamePanel._tbDefine = {
{sPrefabPath = "Play_Mining_400002/MiningGamePanel.prefab", sCtrlName = "Game.UI.Play_Mining_400002.MiningGameCtrl"}
}
MiningGamePanel.Awake = function(self)
  -- function num : 0_0
end

MiningGamePanel.OnEnable = function(self)
  -- function num : 0_1
end

MiningGamePanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

MiningGamePanel.OnDisable = function(self)
  -- function num : 0_3
end

MiningGamePanel.OnDestroy = function(self)
  -- function num : 0_4
end

MiningGamePanel.OnRelease = function(self)
  -- function num : 0_5
end

return MiningGamePanel

