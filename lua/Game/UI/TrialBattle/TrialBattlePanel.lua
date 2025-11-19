local TrialBattlePanel = class("TrialBattlePanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
TrialBattlePanel.OpenMinMap = true
TrialBattlePanel._bAddToBackHistory = false
TrialBattlePanel._tbDefine = {
{sPrefabPath = "RoguelikeItemTip/RoguelikeItemTipPanel.prefab", sCtrlName = "Game.UI.RoguelikeItemTips.RoguelikeItemTipsCtrl"}
, 
{sPrefabPath = "Battle/BattleDashboard.prefab", sCtrlName = "Game.UI.Battle.BattleDashboardCtrl"}
, 
{sPrefabPath = "Play_TrialBattle/TrialMenu.prefab", sCtrlName = "Game.UI.TrialBattle.TrialMenuCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab", sCtrlName = "Game.UI.Battle.MainBattleCtrl"}
, 
{sPrefabPath = "GuideProloguel/GuideProloguelPanel.prefab", sCtrlName = "Game.UI.GuideProloguel.GuideProloguelCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab", sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl"}
, 
{sPrefabPath = "Play_TrialBattle/TrialInfo.prefab", sCtrlName = "Game.UI.TrialBattle.TrialInfoCtrl"}
, 
{sPrefabPath = "Battle/SkillHintIndicators.prefab", sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators"}
, 
{sPrefabPath = "FixedRoguelikeEx/FRIndicators.prefab", sCtrlName = "Game.UI.FixedRoguelikeEx.FRIndicators"}
, 
{sPrefabPath = "Play_TrialBattle/TrialPausePanel.prefab", sCtrlName = "Game.UI.TrialBattle.TrialPauseCtrl"}
, 
{sPrefabPath = "Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"}
}
TrialBattlePanel.Awake = function(self)
  -- function num : 0_0 , upvalues : GamepadUIManager, _ENV
  (GamepadUIManager.EnterAdventure)()
  ;
  (GamepadUIManager.EnableGamepadUI)("BattleMenu", {})
  self.BattleType = (GameEnum.worldLevelType).Dynamic
  self.DynamicType = (GameEnum.dynamicLevelType).Trial
  self.tbTeam = (self._tbParam)[1]
  self.tbDisc = (self._tbParam)[2]
  self.mapCharData = (self._tbParam)[3]
  self.mapDiscData = (self._tbParam)[4]
  self.mapPotentialAddLevel = (self._tbParam)[5]
end

TrialBattlePanel.OnEnable = function(self)
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
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.TrialFormation)
  end

  ;
  (cs_coroutine.start)(wait)
end

TrialBattlePanel.OnAfterEnter = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Hit)(EventId.SubSkillDisplayInit, (self._tbParam)[1])
end

TrialBattlePanel.OnDisable = function(self)
  -- function num : 0_3 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("BattleMenu")
  ;
  (GamepadUIManager.QuitAdventure)()
end

return TrialBattlePanel

