local DailyInstanceBattlePanel = class("DailyInstanceBattlePanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
DailyInstanceBattlePanel.OpenMinMap = true
DailyInstanceBattlePanel._bAddToBackHistory = false
DailyInstanceBattlePanel._tbDefine = {
{sPrefabPath = "RoguelikeItemTip/RoguelikeItemTipPanel.prefab", sCtrlName = "Game.UI.RoguelikeItemTips.RoguelikeItemTipsCtrl"}
, 
{sPrefabPath = "Battle/BattleDashboard.prefab", sCtrlName = "Game.UI.Battle.BattleDashboardCtrl"}
, 
{sPrefabPath = "Battle/MainBattleMenu.prefab", sCtrlName = "Game.UI.Battle.MainBattleMenuCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab", sCtrlName = "Game.UI.Battle.MainBattleCtrl"}
, 
{sPrefabPath = "GuideProloguel/GuideProloguelPanel.prefab", sCtrlName = "Game.UI.GuideProloguel.GuideProloguelCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab", sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl"}
, 
{sPrefabPath = "DailyInstanceBattlePanel/DailyInstanceInfo.prefab", sCtrlName = "Game.UI.DailyInstanceRoomInfo.DailyInstanceRoomInfoCtrl"}
, 
{sPrefabPath = "Battle/SkillHintIndicators.prefab", sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators"}
, 
{sPrefabPath = "Battle/CommonBattlePausePanel.prefab", sCtrlName = "Game.UI.DailyInstanceRoomInfo.DailyInstancePauseCtrl"}
, 
{sPrefabPath = "Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"}
}
DailyInstanceBattlePanel.Awake = function(self)
  -- function num : 0_0 , upvalues : GamepadUIManager, _ENV
  (GamepadUIManager.EnterAdventure)()
  ;
  (GamepadUIManager.EnableGamepadUI)("BattleMenu", {})
  self.BattleType = (GameEnum.worldLevelType).DailyInstance
end

DailyInstanceBattlePanel.OnEnable = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local wait = function()
    -- function num : 0_1_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.Hud)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.MainlineFormation)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.RegionBossFormation)
  end

  ;
  (cs_coroutine.start)(wait)
end

DailyInstanceBattlePanel.OnAfterEnter = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Hit)(EventId.SubSkillDisplayInit, (self._tbParam)[1])
end

DailyInstanceBattlePanel.OnDisable = function(self)
  -- function num : 0_3 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("BattleMenu")
  ;
  (GamepadUIManager.QuitAdventure)()
end

return DailyInstanceBattlePanel

