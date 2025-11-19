local BattleDamagePanel = class("BattleDamagePanel", BasePanel)
BattleDamagePanel._bIsMainPanel = false
BattleDamagePanel._tbDefine = {
{sPrefabPath = "BattleResult/BattleDamagePanel.prefab", sCtrlName = "Game.UI.BattleResult.BattleDamageCtrl"}
}
BattleDamagePanel.Awake = function(self)
  -- function num : 0_0
end

BattleDamagePanel.OnEnable = function(self)
  -- function num : 0_1
end

BattleDamagePanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

BattleDamagePanel.OnDisable = function(self)
  -- function num : 0_3
end

BattleDamagePanel.OnDestroy = function(self)
  -- function num : 0_4
end

BattleDamagePanel.OnRelease = function(self)
  -- function num : 0_5
end

return BattleDamagePanel

