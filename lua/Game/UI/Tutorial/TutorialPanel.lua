local TutorialPanel = class("TutorialPanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
TutorialPanel._bAddToBackHistory = false
TutorialPanel.OpenMinMap = false
TutorialPanel._tbDefine = {
{sPrefabPath = "Battle/BattleDashboard.prefab", sCtrlName = "Game.UI.Battle.BattleDashboardCtrl"}
, 
{sPrefabPath = "Tutorial/TutorialMenu.prefab", sCtrlName = "Game.UI.Tutorial.TutorialMenuCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab", sCtrlName = "Game.UI.Battle.MainBattleCtrl"}
, 
{sPrefabPath = "Battle/SkillHintIndicators.prefab", sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators"}
, 
{sPrefabPath = "FixedRoguelikeEx/FRIndicators.prefab", sCtrlName = "Game.UI.FixedRoguelikeEx.FRIndicators"}
, 
{sPrefabPath = "StarTower/PotentialSelectPanel.prefab", sCtrlName = "Game.UI.Tutorial.TutorialPotentialSelectCtrl"}
, 
{sPrefabPath = "StarTower/DiscSkillActivePanel.prefab", sCtrlName = "Game.UI.Tutorial.TutorialDiscSkillActiveCtrl"}
, 
{sPrefabPath = "StarTower/StarTowerNotePanel.prefab", sCtrlName = "Game.UI.Tutorial.TutorialNoteCtrl"}
, 
{sPrefabPath = "Tutorial/TutorialInfo.prefab", sCtrlName = "Game.UI.Tutorial.TutorialInfoCtrl"}
, 
{sPrefabPath = "Tutorial/TutorialPause.prefab", sCtrlName = "Game.UI.Tutorial.TutorialPauseCtrl"}
, 
{sPrefabPath = "GuideProloguel/GuideProloguelPanel.prefab", sCtrlName = "Game.UI.GuideProloguel.GuideProloguelCtrl"}
, 
{sPrefabPath = "Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"}
}
TutorialPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV, GamepadUIManager
  self.trUIRoot = ((GameObject.Find)("---- UI ----")).transform
  self.tbTeam = (self._tbParam)[1]
  self.tbDisc = (self._tbParam)[2]
  self.mapCharData = (self._tbParam)[3]
  self.mapDiscData = (self._tbParam)[4]
  self.BattleType = (GameEnum.worldLevelType).Dynamic
  self.DynamicType = (GameEnum.dynamicLevelType).Tutorial
  ;
  (GamepadUIManager.EnterAdventure)()
  ;
  (GamepadUIManager.EnableGamepadUI)("BattleMenu", {})
end

TutorialPanel.OnEnable = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local wait = function()
    -- function num : 0_1_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.Hud, false, true)
  end

  ;
  (cs_coroutine.start)(wait)
end

TutorialPanel.OnAfterEnter = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Hit)(EventId.SubSkillDisplayInit, (self._tbParam)[1])
end

TutorialPanel.OnDisable = function(self)
  -- function num : 0_3 , upvalues : GamepadUIManager
  (GamepadUIManager.DisableGamepadUI)("BattleMenu")
  ;
  (GamepadUIManager.QuitAdventure)()
end

TutorialPanel.OnDestroy = function(self)
  -- function num : 0_4
end

TutorialPanel.OnRelease = function(self)
  -- function num : 0_5
end

TutorialPanel.SetTop = function(self, goCanvas)
  -- function num : 0_6 , upvalues : _ENV
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

TutorialPanel.GetSkillLevel = function(self, nCharId)
  -- function num : 0_7 , upvalues : _ENV
  local mapChar = (self.mapCharData)[nCharId]
  local tbList = {}
  tbList[(GameEnum.skillSlotType).NORMAL] = mapChar and (mapChar.tbSkillLvs)[1] or 1
  tbList[(GameEnum.skillSlotType).B] = mapChar and (mapChar.tbSkillLvs)[2] or 1
  tbList[(GameEnum.skillSlotType).C] = mapChar and (mapChar.tbSkillLvs)[3] or 1
  tbList[(GameEnum.skillSlotType).D] = mapChar and (mapChar.tbSkillLvs)[4] or 1
  return tbList
end

return TutorialPanel

