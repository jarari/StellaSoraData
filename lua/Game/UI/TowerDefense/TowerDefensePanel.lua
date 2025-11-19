local TowerDefensePanel = class("TowerDefensePanel", BasePanel)
TowerDefensePanel._bIsMainPanel = true
TowerDefensePanel._sSortingLayerName = (AllEnum.SortingLayerName).UI
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
TowerDefensePanel._tbDefine = {
{sPrefabPath = "Play_TowerDefence/TowerDefensePanel.prefab", sCtrlName = "Game.UI.TowerDefense.TowerDefenseCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab", sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl"}
}
TowerDefensePanel.Awake = function(self)
  -- function num : 0_0 , upvalues : GamepadUIManager
  (GamepadUIManager.EnterAdventure)(true)
  ;
  (GamepadUIManager.EnableGamepadUI)("TowerDefense", {}, nil, true)
end

TowerDefensePanel.OnEnable = function(self)
  -- function num : 0_1
end

TowerDefensePanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

TowerDefensePanel.OnDisable = function(self)
  -- function num : 0_3
end

TowerDefensePanel.OnDestroy = function(self)
  -- function num : 0_4 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("TowerDefense")
  ;
  (GamepadUIManager.QuitAdventure)()
end

TowerDefensePanel.OnRelease = function(self)
  -- function num : 0_5
end

return TowerDefensePanel

