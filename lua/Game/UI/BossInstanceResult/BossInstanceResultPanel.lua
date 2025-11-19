local BossInstanceResultPanel = class("BossInstanceResultPanel", BasePanel)
BossInstanceResultPanel._bAddToBackHistory = false
BossInstanceResultPanel._tbDefine = {
{sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.BossInstanceResult.BossInstanceResultCtrl"}
}
BossInstanceResultPanel.Awake = function(self)
  -- function num : 0_0
end

BossInstanceResultPanel.OnEnable = function(self)
  -- function num : 0_1
end

BossInstanceResultPanel.OnDisable = function(self)
  -- function num : 0_2
end

BossInstanceResultPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return BossInstanceResultPanel

