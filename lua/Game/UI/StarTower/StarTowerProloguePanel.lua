local StarTowerProloguePanel = class("StarTowerProloguePanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
StarTowerProloguePanel.OpenMinMap = false
StarTowerProloguePanel._bAddToBackHistory = false
StarTowerProloguePanel._tbDefine = {
{sPrefabPath = "RoguelikeItemTip/RoguelikeItemTipPanel.prefab", sCtrlName = "Game.UI.RoguelikeItemTips.RoguelikeItemTipsCtrl"}
, 
{sPrefabPath = "Battle/BattleDashboard.prefab", sCtrlName = "Game.UI.Battle.BattleDashboardCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/AdventureMainUI.prefab", sCtrlName = "Game.UI.Battle.MainBattleCtrl"}
, 
{sPrefabPath = "Battle/SkillHintIndicators.prefab", sCtrlName = "Game.UI.Battle.SkillHintIndicator.HintIndicators"}
, 
{sPrefabPath = "Battle/SubSkillDisplay.prefab", sCtrlName = "Game.UI.Battle.SubSkillDisplay.SubSkillDisplayCtrl"}
, 
{sPrefabPath = "StarTower/StarTowerMenu.prefab", sCtrlName = "Game.UI.StarTower.StarTowerMenuCtrl"}
, 
{sPrefabPath = "StarTower/StarTowerRoomInfo.prefab", sCtrlName = "Game.UI.StarTower.StarTowerRoomInfo"}
, 
{sPrefabPath = "StarTower/PotentialSelectPanel.prefab", sCtrlName = "Game.UI.StarTower.Potential.PotentialSelectCtrl"}
, 
{sPrefabPath = "StarTower/FateCardSelectPanel.prefab", sCtrlName = "Game.UI.StarTower.FateCard.FateCardSelectCtrl"}
, 
{sPrefabPath = "GuideProloguel/GuideProloguelPanel.prefab", sCtrlName = "Game.UI.GuideProloguel.GuideProloguelCtrl"}
, 
{sPrefabPath = "Battle/AdventureMainUI/BattlePopupTips.prefab", sCtrlName = "Game.UI.Battle.BattlePopupTipsCtrl"}
}
StarTowerProloguePanel.SetTop = function(self, goCanvas)
  -- function num : 0_0 , upvalues : _ENV
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

StarTowerProloguePanel.CheckMainChar = function(self, nCharId)
  -- function num : 0_1 , upvalues : _ENV
  if self.tbTeam ~= nil then
    for k,v in ipairs(self.tbTeam) do
      if k ~= 1 then
        do
          do return v ~= nCharId end
          -- DECOMPILER ERROR at PC14: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC14: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  do return false end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

StarTowerProloguePanel.GetSkillLevel = function(self, nCharId)
  -- function num : 0_2 , upvalues : _ENV
  local mapChar = (self.mapCharData)[nCharId]
  local tbList = {}
  tbList[(GameEnum.skillSlotType).NORMAL] = mapChar and (mapChar.tbSkillLvs)[1] or 1
  tbList[(GameEnum.skillSlotType).B] = mapChar and (mapChar.tbSkillLvs)[2] or 1
  tbList[(GameEnum.skillSlotType).C] = mapChar and (mapChar.tbSkillLvs)[3] or 1
  tbList[(GameEnum.skillSlotType).D] = mapChar and (mapChar.tbSkillLvs)[4] or 1
  return tbList
end

StarTowerProloguePanel.Awake = function(self)
  -- function num : 0_3 , upvalues : _ENV, GamepadUIManager
  self.BattleType = (GameEnum.worldLevelType).PrologueBattleLevel
  self.trUIRoot = ((GameObject.Find)("---- UI ----")).transform
  self.tbTeam = (self._tbParam)[1]
  self.tbDisc = (self._tbParam)[2]
  self.mapCharData = (self._tbParam)[3]
  self.mapDiscData = (self._tbParam)[4]
  self.mapPotentialAddLevel = (self._tbParam)[5]
  self.nStarTowerId = (self._tbParam)[6]
  self.nLastStarTowerId = (self._tbParam)[7]
  self.tbShowNote = {}
  ;
  (EventManager.Add)(EventId.HideProloguePanle, self, self.SetProloguePanleVisible)
  ;
  (GamepadUIManager.EnterAdventure)()
  ;
  (GamepadUIManager.EnableGamepadUI)("BattleMenu", {})
end

StarTowerProloguePanel.OnEnable = function(self)
  -- function num : 0_4 , upvalues : _ENV
  local wait = function()
    -- function num : 0_4_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.Hud)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.MainlineFormation)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.MainlineFormationDisc)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.RegionBossFormation)
  end

  ;
  (cs_coroutine.start)(wait)
end

StarTowerProloguePanel.OnAfterEnter = function(self)
  -- function num : 0_5 , upvalues : _ENV
  (EventManager.Hit)(EventId.SubSkillDisplayInit, self.tbTeam)
end

StarTowerProloguePanel.OnDisable = function(self)
  -- function num : 0_6 , upvalues : _ENV, GamepadUIManager
  (EventManager.Remove)(EventId.HideProloguePanle, self, self.SetProloguePanleVisible)
  ;
  (GamepadUIManager.DisableGamepadUI)("BattleMenu")
  ;
  (GamepadUIManager.QuitAdventure)()
end

StarTowerProloguePanel.SetProloguePanleVisible = function(self, bVisible)
  -- function num : 0_7 , upvalues : _ENV
  local SetVisible = function(_tb)
    -- function num : 0_7_0 , upvalues : _ENV, bVisible
    for k,ctrlObjInstance in pairs(_tb) do
      (ctrlObjInstance.gameObject):SetActive(bVisible == true)
    end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

  SetVisible(self._tbObjCtrl)
  SetVisible(self._tbObjChildCtrl)
  SetVisible(self._tbObjDyncChildCtrl)
  ;
  (NovaAPI.DispatchEventWithData)("BlockTouchEffect", nil, {bVisible})
end

return StarTowerProloguePanel

