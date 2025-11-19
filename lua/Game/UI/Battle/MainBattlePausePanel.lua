local MainBattlePausePanel = class("MainBattlePausePanel", BasePanel)
MainBattlePausePanel._bIsMainPanel = false
MainBattlePausePanel._tbDefine = {
{sPrefabPath = "Battle/MainBattlePausePanel.prefab", sCtrlName = "Game.UI.Battle.MainBattlePauseCtrl"}
}
MainBattlePausePanel.Awake = function(self)
  -- function num : 0_0
end

MainBattlePausePanel.OnEnable = function(self)
  -- function num : 0_1
end

MainBattlePausePanel.OnDisable = function(self)
  -- function num : 0_2
end

MainBattlePausePanel.OnDestroy = function(self)
  -- function num : 0_3
end

return MainBattlePausePanel

