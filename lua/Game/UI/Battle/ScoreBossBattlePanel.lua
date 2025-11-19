local ScoreBossBattlePanel = class("ScoreBossBattlePanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
ScoreBossBattlePanel.OpenMinMap = true
ScoreBossBattlePanel._bAddToBackHistory = false
ScoreBossBattlePanel._tbDefine = {
{sPrefabPath = "Battle/BattleDashboard.prefab", sCtrlName = "Game.UI.Battle.BattleDashboardCtrl"}
, 
{sPrefabPath = "Battle/MainBattleMenu.prefab", sCtrlName = "Game.UI.Battle.MainBattleMenuCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab", sCtrlName = "Game.UI.Battle.MainBattleCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab", sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl"}
, 
{sPrefabPath = "Play_ScoreBoss/ScoreBossLevelInfo.prefab", sCtrlName = "Game.UI.ScoreBoss.ScoreBossLevelInfoCtrl"}
, 
{sPrefabPath = "Battle/SkillHintIndicators.prefab", sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators"}
, 
{sPrefabPath = "Play_ScoreBoss/ScoreBossPausePanel.prefab", sCtrlName = "Game.UI.ScoreBoss.ScoreBossPauseCtrl"}
, 
{sPrefabPath = "Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"}
}
ScoreBossBattlePanel.Awake = function(self)
  -- function num : 0_0 , upvalues : GamepadUIManager, _ENV
  (GamepadUIManager.EnterAdventure)()
  ;
  (GamepadUIManager.EnableGamepadUI)("BattleMenu", {})
  self.BattleType = (GameEnum.worldLevelType).ScoreBoss
end

ScoreBossBattlePanel.OnEnable = function(self)
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

ScoreBossBattlePanel.OnAfterEnter = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Hit)(EventId.SubSkillDisplayInit, (self._tbParam)[1])
end

ScoreBossBattlePanel.OnDisable = function(self)
  -- function num : 0_3 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("BattleMenu")
  ;
  (GamepadUIManager.QuitAdventure)()
end

return ScoreBossBattlePanel

