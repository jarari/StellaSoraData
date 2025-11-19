local SkillInstanceLevel = class("SkillInstanceLevel")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local AdventureModuleHelper = CS.AdventureModuleHelper
local TimerManager = require("GameCore.Timer.TimerManager")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", [EventId.AbandonBattle] = "OnEvent_AbandonBattle", SkillInstanceGameEnd = "OnEvent_LevelResult", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", BattlePause = "OnEvent_Pause"}
SkillInstanceLevel.Init = function(self, parent, nLevelId, nBuildId)
  -- function num : 0_0 , upvalues : _ENV
  self.parent = parent
  self.nLevelId = nLevelId
  local GetBuildCallback = function(mapBuildData)
    -- function num : 0_0_0 , upvalues : self, _ENV, nLevelId
    self.mapBuildData = mapBuildData
    self.tbCharId = {}
    for _,mapChar in ipairs((self.mapBuildData).tbChar) do
      (table.insert)(self.tbCharId, mapChar.nTid)
    end
    self.tbDiscId = {}
    for _,nDiscId in ipairs((self.mapBuildData).tbDisc) do
      if nDiscId > 0 then
        (table.insert)(self.tbDiscId, nDiscId)
      end
    end
    self.mapActorInfo = {}
    for idx,nTid in ipairs(self.tbCharId) do
      local stActorInfo = self:CalCharFixedEffect(nTid, idx == 1, self.tbDiscId)
      -- DECOMPILER ERROR at PC47: Confused about usage of register: R7 in 'UnsetPending'

      ;
      (self.mapActorInfo)[nTid] = stActorInfo
    end
    -- DECOMPILER ERROR at PC54: Confused about usage of register: R1 in 'UnsetPending'

    PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).SkillInstance
    ;
    ((CS.AdventureModuleHelper).EnterSkillInstanceMap)(nLevelId, self.tbCharId)
    ;
    (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

  ;
  (PlayerData.Build):GetBuildDetailData(GetBuildCallback, nBuildId)
end

SkillInstanceLevel.RefreshCharDamageData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.tbCharDamage = (UTILS.GetCharDamageResult)(self.tbCharId)
end

SkillInstanceLevel.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = (PlayerData.Build):GetBuildAllEft((self.mapBuildData).nBuildId)
  safe_call_cs_func((CS.AdventureModuleHelper).SetNoteInfo, tbNoteInfo)
  self.mapEftData = (UTILS.AddBuildEffect)(mapAllEft, mapDiscEft, mapNoteEffect)
  ;
  (EventManager.Hit)("OpenSkillInstanceRoomInfo", ((ConfigTable.GetData)("SkillInstance", self.nLevelId)).FloorId, self.nLevelId)
end

SkillInstanceLevel.OnEvent_LevelResult = function(self, tbStar, bAbandon)
  -- function num : 0_3 , upvalues : _ENV, TimerManager
  (EventManager.Hit)("SkillInstanceBattleEnd")
  if (self.parent):GetSettlementState() then
    printError("技能素材副本结算流程重复进入，本次退出")
    return 
  end
  self:RefreshCharDamageData()
  ;
  (self.parent):SetSettlementState(true)
  local mapDILevelCfgData = (ConfigTable.GetData)("SkillInstance", self.nLevelId)
  local nStar = 0
  local nStarCount = 0
  -- DECOMPILER ERROR at PC47: Unhandled construct in 'MakeBoolean' P3

  -- DECOMPILER ERROR at PC47: Unhandled construct in 'MakeBoolean' P3

  if ((((not tbStar[0] or not 1) and not tbStar[1])) or tbStar[2]) then
    for i = 0, 2 do
      if tbStar[i] then
        nStarCount = nStarCount + 1
      end
    end
    local callback = function(tbStarReward, tbFirstReward, tbThreeStarItems, tbSurpriseItems, nExp, mapChangeInfo)
    -- function num : 0_3_0 , upvalues : _ENV, nStar, self, tbStar, mapDILevelCfgData, bAbandon, TimerManager
    local waitCallback = function()
      -- function num : 0_3_0_0 , upvalues : _ENV, nStar, self, tbFirstReward, tbStarReward, tbThreeStarItems, tbSurpriseItems, nExp, tbStar, mapChangeInfo
      (NovaAPI.InputEnable)()
      if nStar > 0 then
        self:PlaySuccessPerform(tbFirstReward, tbStarReward, tbThreeStarItems, tbSurpriseItems, nExp, tbStar, mapChangeInfo)
      else
        ;
        (EventManager.Hit)(EventId.ClosePanel, PanelId.BtnTips)
        local sLarge, sSmall = "", ""
        ;
        (EventManager.Hit)(EventId.OpenPanel, PanelId.SkillInstanceResult, false, tbStar, {}, {}, {}, 0, false, sLarge, sSmall, self.nLevelId, self.tbCharId, mapChangeInfo, {}, self.tbCharDamage)
        ;
        (self.parent):LevelEnd()
      end
    end

    ;
    (EventManager.Hit)("SkillInstanceLevelEnd", mapDILevelCfgData.FloorId)
    if bAbandon then
      waitCallback()
    else
      ;
      (TimerManager.Add)(1, 2, self, waitCallback, true, true, true, nil)
    end
  end

    ;
    (NovaAPI.InputDisable)()
    ;
    (self.parent):MsgSettleSkillInstance(self.nLevelId, (self.mapBuildData).nBuildId, nStar, callback)
  end
end

SkillInstanceLevel.OnEvent_AbandonBattle = function(self)
  -- function num : 0_4
  self:OnEvent_LevelResult({false, false, false}, true)
end

SkillInstanceLevel.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_5 , upvalues : _ENV
  (PlayerData.Achievement):SetSpecialBattleAchievement((GameEnum.levelType).SkillInstance)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.SkillInstanceBattlePanel, self.tbCharId)
  self:SetPersonalPerk()
  self:SetDiscInfo()
  for idx,nCharId in ipairs(self.tbCharId) do
    local stActorInfo = self:CalCharFixedEffect(nCharId, idx == 1, self.tbDiscId)
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

SkillInstanceLevel.BindEvent = function(self)
  -- function num : 0_6 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Add)(nEventId, self, callback)
    end
  end
end

SkillInstanceLevel.UnBindEvent = function(self)
  -- function num : 0_7 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Remove)(nEventId, self, callback)
    end
  end
end

SkillInstanceLevel.PlaySuccessPerform = function(self, FirstRewardItems, tbStarReward, tbThreeStarItems, tbSurpriseItems, nExp, tbStar, mapChangeInfo)
  -- function num : 0_8 , upvalues : _ENV
  local func_SettlementFinish = function(bSuccess)
    -- function num : 0_8_0
  end

  local tbChar = self.tbCharId
  local levelEndCallback = function()
    -- function num : 0_8_1 , upvalues : _ENV, self, levelEndCallback, tbChar, func_SettlementFinish
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    local nType = ((ConfigTable.GetData)("SkillInstanceFloor", ((ConfigTable.GetData)("SkillInstance", self.nLevelId)).FloorId)).Theme
    local sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
    local tbSkin = {}
    for _,nCharId in ipairs(tbChar) do
      local nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
      ;
      (table.insert)(tbSkin, nSkinId)
    end
    ;
    ((CS.AdventureModuleHelper).PlaySettlementPerform)(sName, "", tbSkin, func_SettlementFinish)
  end

  ;
  (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
  local openBattleResultPanel = function()
    -- function num : 0_8_2 , upvalues : _ENV, self, openBattleResultPanel, tbStar, tbStarReward, FirstRewardItems, tbThreeStarItems, nExp, mapChangeInfo, tbSurpriseItems
    (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
    local sLarge, sSmall = "", ""
    if not tbSurpriseItems then
      (EventManager.Hit)(EventId.OpenPanel, PanelId.SkillInstanceResult, true, tbStar, {}, {}, {}, ((not tbStarReward and FirstRewardItems) or not tbThreeStarItems) and nExp or 0, false, sLarge, sSmall, self.nLevelId, self.tbCharId, mapChangeInfo, {}, self.tbCharDamage)
      self.bSettle = false
      ;
      (self.parent):LevelEnd()
      self:UnBindEvent()
    end
  end

  ;
  (EventManager.Add)("SettlementPerformLoadFinish", self, openBattleResultPanel)
  ;
  ((CS.AdventureModuleHelper).LevelStateChanged)(true)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResultMask)
end

SkillInstanceLevel.SetCharFixedAttribute = function(self)
  -- function num : 0_9 , upvalues : _ENV
  for nCharId,stActorInfo in pairs(self.mapActorInfo) do
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
end

SkillInstanceLevel.CalCharFixedEffect = function(self, nCharId, bMainChar, tbDiscId)
  -- function num : 0_10 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar, tbDiscId, (self.mapBuildData).nBuildId)
  return stActorInfo
end

SkillInstanceLevel.SetPersonalPerk = function(self)
  -- function num : 0_11 , upvalues : _ENV
  if self.mapBuildData ~= nil then
    for nCharId,tbPerk in pairs((self.mapBuildData).tbPotentials) do
      local mapAddLevel = (PlayerData.Char):GetCharEnhancedPotential(nCharId)
      local tbPerkInfo = {}
      for _,mapPerkInfo in ipairs(tbPerk) do
        local nAddLv = mapAddLevel[mapPerkInfo.nPotentialId] or 0
        local stPerkInfo = (CS.Lua2CSharpInfo_TPPerkInfo)()
        stPerkInfo.perkId = mapPerkInfo.nPotentialId
        stPerkInfo.nCount = mapPerkInfo.nLevel + nAddLv
        ;
        (table.insert)(tbPerkInfo, stPerkInfo)
      end
      safe_call_cs_func((CS.AdventureModuleHelper).ChangePersonalPerkIds, tbPerkInfo, nCharId)
    end
  end
end

SkillInstanceLevel.SetDiscInfo = function(self)
  -- function num : 0_12 , upvalues : _ENV
  local tbDiscInfo = {}
  for k,nDiscId in ipairs((self.mapBuildData).tbDisc) do
    if k <= 3 then
      local discInfo = (PlayerData.Disc):CalcDiscInfoInBuild(nDiscId, (self.mapBuildData).tbSecondarySkill)
      ;
      (table.insert)(tbDiscInfo, discInfo)
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetDiscInfo, tbDiscInfo)
end

SkillInstanceLevel.OnEvent_Pause = function(self)
  -- function num : 0_13 , upvalues : _ENV
  (EventManager.Hit)("OpenSkillInstancePause", self.nLevelId, self.tbCharId)
end

return SkillInstanceLevel

