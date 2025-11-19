local VampireSurvivorBattlePanel = class("VampireSurvivorBattlePanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
VampireSurvivorBattlePanel.OpenMinMap = true
VampireSurvivorBattlePanel._bAddToBackHistory = false
VampireSurvivorBattlePanel._tbDefine = {
{sPrefabPath = "Battle/BattleDashboard.prefab", sCtrlName = "Game.UI.Battle.BattleDashboardCtrl"}
, 
{sPrefabPath = "VampireBattle/VampireMenu.prefab", sCtrlName = "Game.UI.VampireSurvivor.VampireMenuCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab", sCtrlName = "Game.UI.Battle.MainBattleCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab", sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl"}
, 
{sPrefabPath = "Battle/SkillHintIndicators.prefab", sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators"}
, 
{sPrefabPath = "Battle/CommonMonsterWarning.prefab", sCtrlName = "Game.UI.Battle.CommonMonsterWarningCtrl"}
, 
{sPrefabPath = "RegionBossTimeEx/RegionBossTime.prefab", sCtrlName = "Game.UI.VampireSurvivor.VampireSurvivorTimeCtrl"}
, 
{sPrefabPath = "VampireBattle/VampireFateCardSelectPanel.prefab", sCtrlName = "Game.UI.VampireSurvivor.VampireFateCardSelect"}
, 
{sPrefabPath = "VampireBattle/VampireRoomInfo.prefab", sCtrlName = "Game.UI.VampireSurvivor.VampireSurvivorRoomInfo"}
, 
{sPrefabPath = "VampireBattle/VampirePausePanel.prefab", sCtrlName = "Game.UI.VampireSurvivor.VampireSurvivorPauseCtrl"}
, 
{sPrefabPath = "VampireBattle/VampireDepotPanel.prefab", sCtrlName = "Game.UI.VampireSurvivor.VampireDepotCtrl"}
, 
{sPrefabPath = "Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"}
}
VampireSurvivorBattlePanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV, GamepadUIManager
  self.BattleType = (GameEnum.worldLevelType).VampireInstance
  self.trUIRoot = ((GameObject.Find)("---- UI ----")).transform
  ;
  (EventManager.Add)("VampireSurvivorChangeArea", self, self.OnEvent_ChangeArea)
  ;
  (GamepadUIManager.EnterAdventure)()
  ;
  (GamepadUIManager.EnableGamepadUI)("BattleMenu", {})
  self.tbTeam = (self._tbParam)[1]
  self.nLevelId = (self._tbParam)[2]
  self.mapCharData = {}
  for _,nCharId in ipairs(self.tbTeam) do
    -- DECOMPILER ERROR at PC42: Confused about usage of register: R6 in 'UnsetPending'

    (self.mapCharData)[nCharId] = clone((PlayerData.Char):GetCharDataByTid(nCharId))
  end
end

VampireSurvivorBattlePanel.SetTop = function(self, goCanvas)
  -- function num : 0_1 , upvalues : _ENV
  local nTopLayer = 0
  if self.trUIRoot ~= nil then
    local nChildCount = (self.trUIRoot).childCount
    local trChild = nil
    for i = 1, nChildCount do
      trChild = (self.trUIRoot):GetChild(i - 1)
      nTopLayer = (math.max)(nTopLayer, (NovaAPI.GetCanvasSortingOrder)(trChild:GetComponent("Canvas")))
    end
  end
  do
    if nTopLayer > 0 then
      (NovaAPI.SetCanvasSortingOrder)(goCanvas, nTopLayer + 1)
    end
  end
end

VampireSurvivorBattlePanel.OnEnable = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local wait = function()
    -- function num : 0_2_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.Hud, true, true)
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

VampireSurvivorBattlePanel.OnAfterEnter = function(self)
  -- function num : 0_3 , upvalues : _ENV
  (EventManager.Hit)(EventId.SubSkillDisplayInit, (self._tbParam)[1])
end

VampireSurvivorBattlePanel.OnDisable = function(self)
  -- function num : 0_4 , upvalues : _ENV, GamepadUIManager
  (EventManager.Remove)("VampireSurvivorChangeArea", self, self.OnEvent_ChangeArea)
  ;
  (GamepadUIManager.DisableGamepadUI)("BattleMenu")
  ;
  (GamepadUIManager.QuitAdventure)()
end

VampireSurvivorBattlePanel.OnEvent_ChangeArea = function(self, tbTeam)
  -- function num : 0_5 , upvalues : _ENV
  self.tbTeam = tbTeam
  self.mapCharData = {}
  for _,nCharId in ipairs(self.tbTeam) do
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R7 in 'UnsetPending'

    (self.mapCharData)[nCharId] = clone((PlayerData.Char):GetCharDataByTid(nCharId))
  end
end

return VampireSurvivorBattlePanel

