local TDBattlePanel = class("TDBattlePanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
TDBattlePanel.OpenMinMap = true
TDBattlePanel._bAddToBackHistory = false
TDBattlePanel._tbDefine = {
{sPrefabPath = "RoguelikeItemTip/RoguelikeItemTipPanel.prefab", sCtrlName = "Game.UI.RoguelikeItemTips.RoguelikeItemTipsCtrl"}
, 
{sPrefabPath = "Battle/BattleDashboard.prefab", sCtrlName = "Game.UI.Battle.BattleDashboardCtrl"}
, 
{sPrefabPath = "Battle/MainBattleMenu.prefab", sCtrlName = "Game.UI.Battle.MainBattleMenuCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab", sCtrlName = "Game.UI.Battle.MainBattleCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab", sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl"}
, 
{sPrefabPath = "TDRoomInfo/TDRoomInfo.prefab", sCtrlName = "Game.UI.TravelerDuelRoomInfo.TDRoomInfoCtrl"}
, 
{sPrefabPath = "Battle/SkillHintIndicators.prefab", sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators"}
, 
{sPrefabPath = "Battle/CommonBattlePausePanel.prefab", sCtrlName = "Game.UI.TravelerDuelRoomInfo.TDPauseCtrl"}
, 
{sPrefabPath = "Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"}
}
TDBattlePanel.Awake = function(self)
  -- function num : 0_0 , upvalues : GamepadUIManager, _ENV
  (GamepadUIManager.EnterAdventure)()
  ;
  (GamepadUIManager.EnableGamepadUI)("BattleMenu", {})
  self.BattleType = (GameEnum.worldLevelType).TravelerDuel
end

TDBattlePanel.OnEnable = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local wait = function()
    -- function num : 0_1_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    local mapLevel = (ConfigTable.GetData)("TravelerDuelBossLevel", (PlayerData.TravelerDuel).entryLevelId)
    if mapLevel then
      local FloorId = mapLevel.FloorId
      local floorData = (ConfigTable.GetData)("TravelerDuelFloor", FloorId)
      if floorData and floorData.IntroCutscene ~= "" then
        (EventManager.Hit)(EventId.BattleDashboardVisible, false)
      end
    end
    do
      ;
      (EventManager.Hit)(EventId.OpenPanel, PanelId.Hud)
      ;
      (EventManager.Hit)(EventId.ClosePanel, PanelId.MainlineFormation)
      ;
      (EventManager.Hit)(EventId.ClosePanel, PanelId.RegionBossFormation)
    end
  end

  ;
  (cs_coroutine.start)(wait)
end

TDBattlePanel.OnAfterEnter = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Hit)(EventId.SubSkillDisplayInit, (self._tbParam)[1])
end

TDBattlePanel.OnDisable = function(self)
  -- function num : 0_3 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("BattleMenu")
  ;
  (GamepadUIManager.QuitAdventure)()
end

return TDBattlePanel

