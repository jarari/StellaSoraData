local ActivityLevelsBattlePanel = class("ActivityLevelsBattlePanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
ActivityLevelsBattlePanel._sUIResRootPath = ""
ActivityLevelsBattlePanel.OpenMinMap = true
ActivityLevelsBattlePanel._bAddToBackHistory = false
ActivityLevelsBattlePanel._tbDefine = {
{sPrefabPath = "UI/RoguelikeItemTip/RoguelikeItemTipPanel.prefab", sCtrlName = "Game.UI.RoguelikeItemTips.RoguelikeItemTipsCtrl"}
, 
{sPrefabPath = "UI/Battle/BattleDashboard.prefab", sCtrlName = "Game.UI.Battle.BattleDashboardCtrl"}
, 
{sPrefabPath = "UI/Battle/MainBattleMenu.prefab", sCtrlName = "Game.UI.Battle.MainBattleMenuCtrl"}
, 
{sPrefabPath = "UI/Battle/AdventureMainUI/AdventureMainUI.prefab", sCtrlName = "Game.UI.Battle.MainBattleCtrl"}
, 
{sPrefabPath = "UI/Battle/AdventureMainUI/BattlePopupTips.prefab", sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl"}
, 
{sPrefabPath = "UI/ActivityLevelCommon/ActivityLevelsInstanceInfo.prefab", sCtrlName = "Game.UI.ActivityTheme.LevelCommon.ActivityLevelsInstanceRoomInfo"}
, 
{sPrefabPath = "UI/Battle/SkillHintIndicators.prefab", sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators"}
, 
{sPrefabPath = "UI/Battle/CommonBattlePausePanel.prefab", sCtrlName = "Game.UI.ActivityTheme.LevelCommon.ActivityLevelsInstancePauseCtrl"}
, 
{sPrefabPath = "UI/Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"}
}
ActivityLevelsBattlePanel.Awake = function(self)
  -- function num : 0_0 , upvalues : GamepadUIManager, _ENV
  (GamepadUIManager.EnterAdventure)()
  ;
  (GamepadUIManager.EnableGamepadUI)("BattleMenu", {})
  self.BattleType = (GameEnum.worldLevelType).ActivityLevels
end

ActivityLevelsBattlePanel.OnEnable = function(self)
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

ActivityLevelsBattlePanel.OnAfterEnter = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Hit)(EventId.SubSkillDisplayInit, (self._tbParam)[1])
end

ActivityLevelsBattlePanel.OnDisable = function(self)
  -- function num : 0_3 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("BattleMenu")
  ;
  (GamepadUIManager.QuitAdventure)()
end

return ActivityLevelsBattlePanel

