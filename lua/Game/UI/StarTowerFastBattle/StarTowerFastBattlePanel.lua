local StarTowerFastBattlePanel = class("StarTowerFastBattlePanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
StarTowerFastBattlePanel._tbDefine = {
{sPrefabPath = "StarTowerFastBattle/StarTowerFastBattlePanel.prefab", sCtrlName = "Game.UI.StarTowerFastBattle.StarTowerFastBattleCtrl"}
, 
{sPrefabPath = "StarTower/PotentialSelectPanel.prefab", sCtrlName = "Game.UI.StarTower.Potential.PotentialSelectCtrl"}
, 
{sPrefabPath = "StarTower/PotentialLevelUpPanel.prefab", sCtrlName = "Game.UI.StarTower.Potential.PotentialLevelUpCtrl"}
, 
{sPrefabPath = "StarTower/FateCardSelectPanel.prefab", sCtrlName = "Game.UI.StarTower.FateCard.FateCardSelectCtrl"}
, 
{sPrefabPath = "StarTower/DiscSkillActivePanel.prefab", sCtrlName = "Game.UI.StarTower.DiscTips.DiscSkillActiveCtrl"}
, 
{sPrefabPath = "StarTower/StarTowerNotePanel.prefab", sCtrlName = "Game.UI.StarTower.StarTowerNoteCtrl"}
, 
{sPrefabPath = "StarTower/StarTowerDepotPanel.prefab", sCtrlName = "Game.UI.StarTower.Depot.StarTowerDepotCtrl"}
}
StarTowerFastBattlePanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV, GamepadUIManager
  self.trUIRoot = ((GameObject.Find)("---- UI ----")).transform
  local tbStarTowerInfo = (self:GetPanelParam())[1]
  local luaClass = require("Game.Adventure.StarTower.StarTowerSweepData")
  self.LevelData = (luaClass.new)((tbStarTowerInfo.Meta).Id)
  ;
  (self.LevelData):Init(tbStarTowerInfo.Meta, tbStarTowerInfo.Room, tbStarTowerInfo.Bag)
  ;
  (EventManager.Hit)("SetStarTowerSweepData", self.LevelData)
  self.tbTeam = (self.LevelData).tbTeam
  self.tbDisc = (self.LevelData).tbDisc
  self.mapCharData = (self.LevelData).mapCharData
  self.mapDiscData = (self.LevelData).mapDiscData
  self.mapPotentialAddLevel = (self.LevelData).mapPotentialAddLevel
  self.nStarTowerId = (self.LevelData).nTowerId
  self.tbShowNote = {}
  local mapCfg = (ConfigTable.GetData)("StarTower", self.nStarTowerId)
  if mapCfg ~= nil then
    local nDropGroup = mapCfg.SubNoteSkillDropGroupId
    local tbNoteDrop = (CacheTable.GetData)("_SubNoteSkillDropGroup", nDropGroup)
    if tbNoteDrop ~= nil then
      for _,v in ipairs(tbNoteDrop) do
        (table.insert)(self.tbShowNote, v.SubNoteSkillId)
      end
    end
  end
  do
    ;
    (table.sort)(self.tbShowNote, function(a, b)
    -- function num : 0_0_0
    do return a < b end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
    ;
    (GamepadUIManager.EnterAdventure)(true)
  end
end

StarTowerFastBattlePanel.SetTop = function(self, goCanvas)
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

StarTowerFastBattlePanel.CheckMainChar = function(self, nCharId)
  -- function num : 0_2 , upvalues : _ENV
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

StarTowerFastBattlePanel.GetSkillLevel = function(self, nCharId)
  -- function num : 0_3 , upvalues : _ENV
  local mapChar = (self.mapCharData)[nCharId]
  local tbList = {}
  tbList[(GameEnum.skillSlotType).NORMAL] = mapChar and (mapChar.tbSkillLvs)[1] or 1
  tbList[(GameEnum.skillSlotType).B] = mapChar and (mapChar.tbSkillLvs)[2] or 1
  tbList[(GameEnum.skillSlotType).C] = mapChar and (mapChar.tbSkillLvs)[3] or 1
  tbList[(GameEnum.skillSlotType).D] = mapChar and (mapChar.tbSkillLvs)[4] or 1
  return tbList
end

StarTowerFastBattlePanel.OnEnable = function(self)
  -- function num : 0_4 , upvalues : _ENV
  (PlayerData.State):SetStarTowerSweepState(true)
  local wait = function()
    -- function num : 0_4_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
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

StarTowerFastBattlePanel.OnDisable = function(self)
  -- function num : 0_5 , upvalues : _ENV, GamepadUIManager
  (PlayerData.State):SetStarTowerSweepState(false)
  ;
  (GamepadUIManager.QuitAdventure)()
end

StarTowerFastBattlePanel.OnDestroy = function(self)
  -- function num : 0_6 , upvalues : _ENV
  (self.LevelData):UnBindEvent()
  ;
  (EventManager.Hit)("SetStarTowerSweepData")
end

StarTowerFastBattlePanel.OnRelease = function(self)
  -- function num : 0_7
end

StarTowerFastBattlePanel.OnAfterEnter = function(self)
  -- function num : 0_8
end

return StarTowerFastBattlePanel

