local JointDrillBattlePanel = class("JointDrillBattlePanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
JointDrillBattlePanel.OpenMinMap = true
JointDrillBattlePanel._bAddToBackHistory = false
JointDrillBattlePanel._tbDefine = {
{sPrefabPath = "Battle/BattleDashboard.prefab", sCtrlName = "Game.UI.Battle.BattleDashboardCtrl"}
, 
{sPrefabPath = "Play_JointDrill/JointDrillMenu.prefab", sCtrlName = "Game.UI.JointDrill.JointDrillMenuCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab", sCtrlName = "Game.UI.Battle.MainBattleCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab", sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl"}
, 
{sPrefabPath = "Battle/SkillHintIndicators.prefab", sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators"}
, 
{sPrefabPath = "Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"}
, 
{sPrefabPath = "Battle/CommonMonsterWarning.prefab", sCtrlName = "Game.UI.Battle.CommonMonsterWarningCtrl"}
, 
{sPrefabPath = "Play_JointDrill/JointDrillBossTime.prefab", sCtrlName = "Game.UI.JointDrill.JintDrillTimeCtrl"}
, 
{sPrefabPath = "Play_JointDrill/JointDrillPausePanel.prefab", sCtrlName = "Game.UI.JointDrill.JointDrillPauseCtrl"}
}
JointDrillBattlePanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV, GamepadUIManager
  self.BattleType = (GameEnum.worldLevelType).Dynamic
  self.DynamicType = (GameEnum.dynamicLevelType).JointDrill
  self.trUIRoot = ((GameObject.Find)("---- UI ----")).transform
  ;
  (GamepadUIManager.EnterAdventure)()
  ;
  (GamepadUIManager.EnableGamepadUI)("BattleMenu", {})
  self.tbTeam = (self._tbParam)[1]
  self.nLevelId = (self._tbParam)[2]
  self.mapCharData = {}
  for _,nCharId in ipairs(self.tbTeam) do
    -- DECOMPILER ERROR at PC40: Confused about usage of register: R6 in 'UnsetPending'

    (self.mapCharData)[nCharId] = clone((PlayerData.Char):GetCharDataByTid(nCharId))
  end
end

JointDrillBattlePanel.OnEnable = function(self)
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
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
  end

  ;
  (cs_coroutine.start)(wait)
end

JointDrillBattlePanel.OnAfterEnter = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Hit)(EventId.SubSkillDisplayInit, (self._tbParam)[1])
end

JointDrillBattlePanel.OnDisable = function(self)
  -- function num : 0_3 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("BattleMenu")
  ;
  (GamepadUIManager.QuitAdventure)()
end

return JointDrillBattlePanel

