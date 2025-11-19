local VampireSurvivorLevelData = class("VampireSurvivorLevelData")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", Vampire_Monster_DeclareDeath = "OnEvent_MonsterDied", Vampire_Drop = "OnEvent_LevelDrop", takeEffect = "OnEvent_TakeEffect", LevelStateChanged = "OnEvent_LevelResult", VampireSurvivor_Time = "OnEvent_Time", Vampire_Boss_Spawn = "OnEvent_BossSpawn", BattlePause = "OnEvent_BattlePause", BattleDepot = "OnEvent_OpenDepot", AbandonVampireSurvivor = "OnEvent_Abandon", VampireBattleSuccess = "OnEvent_BattleEnd", Kill_SpecialType = "OnEvent_EventTips", VampireAddFateCard = "OnEvent_AddFateCard"}
VampireSurvivorLevelData.Init = function(self, parent, nLevelId, nBuildId1, nBuildId2, tbEvent, tbReward, tbExReward)
  -- function num : 0_0 , upvalues : _ENV
  self.parent = parent
  self.nLevelId = nLevelId
  self.floorId = 0
  self.nBuildId1 = nBuildId1
  self.nBuildId2 = nBuildId2
  self.isFirstHalf = true
  self.mapActorInfo = {}
  self.mapLevel = {}
  self.nCurLevel = 1
  self.nCurExp = 0
  self.nCurTotalTime = 0
  self.nCurTotalTimeFateCard = 0
  self.nBossTime = 0
  self.bBoss = false
  self.bHandleFateCard = false
  self.nPendingLevelUp = 0
  self.bHandleChest = false
  self.tbChest = {}
  self.mapFateCard = {}
  self.mapFateCardEft = {}
  self.mapFateCardEftCount = {}
  self.mapFateCardTimeLimit = {}
  self.mapFateCardTheme = {}
  self.tbCharDamageSecond = {}
  self.tbCharDamageFirst = {}
  self.nFirstBossTime = 60
  self.bFirstHalfEnd = false
  self.bHalfBattle = false
  self.bBattleEnd = false
  self.cachedFirstFateCard = {
mapFateCard = {}
, 
mapFateCardEft = {}
, 
mapFateCardEftCount = {}
, 
mapFateCardTimeLimit = {}
, 
mapFateCardTheme = {}
}
  self.cachedFirstFateCard = {nCurLevel = self.nCurLevel, nCurExp = self.nCurExp, mapNextReward = self.mapNextReward, mapFateCard = clone(self.mapFateCard), mapFateCardEftCount = clone(self.mapFateCardEftCount), mapFateCardTimeLimit = clone(self.mapFateCardTimeLimit), mapFateCardTheme = clone(self.mapFateCardTheme), nCurTotalTimeFateCard = self.nCurTotalTimeFateCard, nScoreShow = self.nScoreShow}
  self.tbActivedTalentEft = parent:GetActivedTalentEft()
  local mapVampireLevelData = (ConfigTable.GetData)("VampireSurvivor", nLevelId)
  if mapVampireLevelData == nil then
    return 
  end
  self.bHalfBattle = mapVampireLevelData.Mode == (GameEnum.vampireSurvivorMode).Single
  local nFloorId = mapVampireLevelData.FloorId
  local mapVampireFloorData = (ConfigTable.GetData)("VampireFloor", nFloorId)
  if mapVampireFloorData ~= nil then
    local nPoolId = mapVampireFloorData.FirstHalfPoolId
    do
      local forEachPool = function(mapData)
    -- function num : 0_0_0 , upvalues : nPoolId, _ENV, self
    if mapData.PoolId == nPoolId and mapData.PoolType == (GameEnum.poolType).Boss then
      self.nFirstBossTime = mapData.WaveKeepTime
    end
  end

      ForEachTableLine(DataTable.VampireFloor, forEachPool)
    end
  end
  self.floorId = mapVampireLevelData.FloorId
  local nLevelGroup = mapVampireLevelData.LevelGroupId
  local forEachExp = function(mapData)
    -- function num : 0_0_1 , upvalues : nLevelGroup, self
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

    if mapData.GroupID == nLevelGroup then
      (self.mapLevel)[mapData.Level] = mapData.Exp
    end
  end

  ForEachTableLine(DataTable.VampireSurvivorLevel, forEachExp)
  local mapVampireFloorData = (ConfigTable.GetData)("VampireFloor", self.floorId)
  if mapVampireFloorData == nil then
    return 
  end
  local tbWaveCount = mapVampireFloorData.WaveCount
  self.nBonusTime = 0
  self.tbBonusRank = {}
  self.tbBonusPower = {}
  local sBonusConfig = (ConfigTable.GetConfigValue)("VampireBonusConfig")
  if sBonusConfig ~= nil then
    local tbBonusConfig = decodeJson(sBonusConfig)
    if tbBonusConfig ~= nil then
      for _,tbData in ipairs(tbBonusConfig) do
        (table.insert)(self.tbBonusRank, tbData[1])
        ;
        (table.insert)(self.tbBonusPower, tbData[2])
      end
    end
  end
  local sBonusTime = (ConfigTable.GetConfigValue)("VampireBonusTime")
  do
    if sBonusTime ~= nil then
      local nTime = tonumber(sBonusTime)
      if nTime ~= nil then
        self.nBonusTime = nTime
      end
    end
    self.nScoreShow = 0
    self.tbFirstHalfEventType1 = {}
    self.tbFirstHalfEventType2 = {}
    self.tbSecondHalfEventType1 = {}
    self.tbSecondHalfEventType2 = {}
    self.tbFirstHalfCount = {}
    self.tbSecondHalfCount = {}
    self.tbBonusKillFirstHalf = {}
    self.tbBonusKillEliteFirstHalf = {}
    self.tbBonusKill = {0, 0, 0}
    self.tbBonusKillElite = {0, 0, 0}
    self.nCurBonusCount = 0
    self.nBonusExpireTime = 0
    self.nMonsterCount = 0
    self.nEliteMonsterCount = 0
    self.nLordCount = 0
    self.nBossCount = 0
    self.mapNextReward = tbReward
    self.mapExReward = tbExReward
    for _,mapEvent in ipairs(tbEvent) do
      if mapEvent.EventType == 1 then
        for _,nWave in ipairs(mapEvent.Numbers) do
          if tbWaveCount[1] - nWave >= 0 then
            (table.insert)(self.tbFirstHalfEventType1, nWave)
          else
            (table.insert)(self.tbSecondHalfEventType1, nWave - tbWaveCount[1])
          end
        end
      else
        for _,nWave in ipairs(mapEvent.Numbers) do
          if tbWaveCount[1] - nWave >= 0 then
            (table.insert)(self.tbFirstHalfEventType2, nWave)
          else
            (table.insert)(self.tbSecondHalfEventType2, nWave - tbWaveCount[1])
          end
        end
      end
    end
    local GetBuildCallback = function(mapBuildData)
    -- function num : 0_0_2 , upvalues : self, _ENV
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
    self.tbPotentials = (self.mapBuildData).tbPotentials
    self.mapActorInfo = {}
    for idx,nTid in ipairs(self.tbCharId) do
      local stActorInfo = self:CalCharFixedEffect(nTid, idx == 1, self.tbDiscId)
      -- DECOMPILER ERROR at PC50: Confused about usage of register: R7 in 'UnsetPending'

      ;
      (self.mapActorInfo)[nTid] = stActorInfo
    end
    local tbActivedDropData = (PlayerData.VampireSurvivor):GetActivedDropItem()
    ;
    ((CS.AdventureModuleHelper).EnterVampireFloor)(self.floorId, self.tbCharId, true, self.tbFirstHalfEventType1, self.tbFirstHalfEventType2, self.bHalfBattle, tbActivedDropData)
    ;
    (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.VampireSurvivorBattlePanel, self.tbCharId, self.nLevelId)
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

    ;
    (PlayerData.Build):GetBuildDetailData(GetBuildCallback, nBuildId1)
    -- DECOMPILER ERROR: 12 unprocessed JMP targets
  end
end

VampireSurvivorLevelData.InitReEnter = function(self, parent, nLevelId, nBuildId1, nBuildId2, tbEvent, tbReward, tbFateCard, mapClientData, mapFirst)
  -- function num : 0_1 , upvalues : _ENV
  self.parent = parent
  self.nLevelId = nLevelId
  self.floorId = 0
  self.nBuildId1 = nBuildId1
  self.nBuildId2 = nBuildId2
  self.isFirstHalf = false
  self.mapActorInfo = {}
  self.mapLevel = {}
  self.nCurLevel = mapClientData.Level
  self.nCurExp = mapClientData.Exp
  self.nCurTotalTime = 0
  self.nCurTotalTimeFateCard = mapClientData.FateCardTimer
  self.nBossTime = 0
  self.bBoss = false
  self.bHandleFateCard = false
  self.nPendingLevelUp = 0
  self.bHandleChest = false
  self.tbChest = {}
  self.mapFateCard = {}
  self.tbCharDamageSecond = {}
  self.tbCharDamageFirst = {}
  local mapFateCardTimeLimit = {}
  for _,mapLimit in pairs(mapClientData.Limits) do
    do
      mapFateCardTimeLimit[mapLimit.Id] = mapLimit.TimeLimit
    end
  end
  for _,nFateCardId in ipairs(tbFateCard) do
    local nTime = -1
    if mapFateCardTimeLimit[nFateCardId] ~= nil then
      nTime = mapFateCardTimeLimit[nFateCardId]
    end
    -- DECOMPILER ERROR at PC50: Confused about usage of register: R17 in 'UnsetPending'

    ;
    (self.mapFateCard)[nFateCardId] = nTime
  end
  self.mapFateCardEft = {}
  self.mapFateCardEftCount = {}
  for _,mapEft in pairs(mapClientData.Efts) do
    -- DECOMPILER ERROR at PC69: Confused about usage of register: R16 in 'UnsetPending'

    if (self.mapFateCardEftCount)[mapEft.EftId] == nil then
      (self.mapFateCardEftCount)[mapEft.EftId] = {}
    end
    -- DECOMPILER ERROR at PC75: Confused about usage of register: R16 in 'UnsetPending'

    ;
    ((self.mapFateCardEftCount)[mapEft.EftId])[mapEft.Id] = mapEft.Count
  end
  self.mapFateCardTimeLimit = {}
  for _,mapLimit in pairs(mapClientData.Limits) do
    -- DECOMPILER ERROR at PC92: Confused about usage of register: R16 in 'UnsetPending'

    if (self.mapFateCardTimeLimit)[mapLimit.TimeLimit] == nil then
      (self.mapFateCardTimeLimit)[mapLimit.TimeLimit] = {}
    end
    ;
    (table.insert)((self.mapFateCardTimeLimit)[mapLimit.TimeLimit], mapLimit.Id)
  end
  self.mapFateCardTheme = {}
  local AddFateCardTheme = function(nFateCardId)
    -- function num : 0_1_0 , upvalues : _ENV, self
    local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
    if mapFateCardCfgData == nil then
      return 
    end
    local operateType = 1
    if mapFateCardCfgData.ThemeType ~= (GameEnum.fateCardTheme).NoType then
      local tbTriggerType = mapFateCardCfgData.ThemeTriggerType
      local nCurLevel = nil
      if (self.mapFateCardTheme)[mapFateCardCfgData.ThemeType] ~= nil then
        nCurLevel = ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).nCurLevel
      end
      if nCurLevel == nil then
        operateType = 1
        -- DECOMPILER ERROR at PC40: Confused about usage of register: R5 in 'UnsetPending'

        if (self.mapFateCardTheme)[mapFateCardCfgData.ThemeType] == nil then
          (self.mapFateCardTheme)[mapFateCardCfgData.ThemeType] = {nCurLevel = 0, 
tbTriggerType = {}
}
        end
        -- DECOMPILER ERROR at PC45: Confused about usage of register: R5 in 'UnsetPending'

        ;
        ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).nCurLevel = mapFateCardCfgData.ThemeValue
        -- DECOMPILER ERROR at PC52: Confused about usage of register: R5 in 'UnsetPending'

        ;
        ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType = clone(tbTriggerType)
      else
        if nCurLevel == (GameEnum.fateCardThemeRank).Base and nCurLevel < mapFateCardCfgData.ThemeValue then
          operateType = 2
          -- DECOMPILER ERROR at PC67: Confused about usage of register: R5 in 'UnsetPending'

          ;
          ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).nCurLevel = mapFateCardCfgData.ThemeValue
          for _,triggerType in ipairs(tbTriggerType) do
            if (table.indexof)(((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType, triggerType) < 1 then
              (table.insert)(((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType, triggerType)
            end
          end
        else
          do
            if (nCurLevel == (GameEnum.fateCardThemeRank).ProA and mapFateCardCfgData.ThemeValue == (GameEnum.fateCardThemeRank).ProB) or nCurLevel == (GameEnum.fateCardThemeRank).ProB and mapFateCardCfgData.ThemeValue == (GameEnum.fateCardThemeRank).ProA then
              operateType = 2
              -- DECOMPILER ERROR at PC122: Confused about usage of register: R5 in 'UnsetPending'

              ;
              ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).nCurLevel = (GameEnum.fateCardThemeRank).Super
              for _,triggerType in ipairs(tbTriggerType) do
                if (table.indexof)(((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType, triggerType) < 1 then
                  (table.insert)(((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType, triggerType)
                end
              end
            else
              do
                do return  end
              end
            end
          end
        end
      end
    end
  end

  for _,nFateCardId in ipairs(tbFateCard) do
    AddFateCardTheme(nFateCardId)
  end
  self.nFirstBossTime = 60
  self.bFirstHalfEnd = true
  self.bHalfBattle = false
  self.bBattleEnd = false
  self.mapNextReward = tbReward
  self.cachedFirstFateCard = {nCurLevel = self.nCurLevel, nCurExp = self.nCurExp, mapNextReward = self.mapNextReward, mapFateCard = clone(self.mapFateCard), mapFateCardEftCount = clone(self.mapFateCardEftCount), mapFateCardTimeLimit = clone(self.mapFateCardTimeLimit), mapFateCardTheme = clone(self.mapFateCardTheme), nCurTotalTimeFateCard = self.nCurTotalTimeFateCard, nScoreShow = self.nScoreShow}
  self.tbActivedTalentEft = parent:GetActivedTalentEft()
  local mapVampireLevelData = (ConfigTable.GetData)("VampireSurvivor", nLevelId)
  if mapVampireLevelData == nil then
    return 
  end
  self.bHalfBattle = mapVampireLevelData.Mode == (GameEnum.vampireSurvivorMode).Single
  local nFloorId = mapVampireLevelData.FloorId
  local mapVampireFloorData = (ConfigTable.GetData)("VampireFloor", nFloorId)
  if mapVampireFloorData ~= nil then
    local nPoolId = mapVampireFloorData.FirstHalfPoolId
    local forEachPool = function(mapData)
    -- function num : 0_1_1 , upvalues : nPoolId, _ENV, self
    if mapData.PoolId == nPoolId and mapData.PoolType == (GameEnum.poolType).Boss then
      self.nFirstBossTime = mapData.WaveKeepTime
    end
  end

    ForEachTableLine(DataTable.VampireFloor, forEachPool)
  end
  self.floorId = mapVampireLevelData.FloorId
  local nLevelGroup = mapVampireLevelData.LevelGroupId
  local forEachExp = function(mapData)
    -- function num : 0_1_2 , upvalues : nLevelGroup, self
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

    if mapData.GroupID == nLevelGroup then
      (self.mapLevel)[mapData.Level] = mapData.Exp
    end
  end

  ForEachTableLine(DataTable.VampireSurvivorLevel, forEachExp)
  local mapVampireFloorData = (ConfigTable.GetData)("VampireFloor", self.floorId)
  if mapVampireFloorData == nil then
    return 
  end
  local tbWaveCount = mapVampireFloorData.WaveCount
  self.nBonusTime = 0
  self.tbBonusRank = {}
  self.tbBonusPower = {}
  local sBonusConfig = (ConfigTable.GetConfigValue)("VampireBonusConfig")
  if sBonusConfig ~= nil then
    local tbBonusConfig = decodeJson(sBonusConfig)
    if tbBonusConfig ~= nil then
      for _,tbData in ipairs(tbBonusConfig) do
        (table.insert)(self.tbBonusRank, tbData[1])
        ;
        (table.insert)(self.tbBonusPower, tbData[2])
      end
    end
  end
  local sBonusTime = (ConfigTable.GetConfigValue)("VampireBonusTime")
  do
    if sBonusTime ~= nil then
      local nTime = tonumber(sBonusTime)
      if nTime ~= nil then
        self.nBonusTime = nTime
      end
    end
    self.tbFirstHalfEventType1 = {}
    self.tbFirstHalfEventType2 = {}
    self.tbSecondHalfEventType1 = {}
    self.tbSecondHalfEventType2 = {}
    self.tbBonusKillFirstHalf = clone(self.tbBonusKill)
    self.tbBonusKillEliteFirstHalf = clone(self.tbBonusKillElite)
    self.tbFirstHalfCount = {}
    for i = 1, 3 do
      (table.insert)(self.tbFirstHalfCount, (mapFirst.KillCount)[i] or 0)
    end
    -- DECOMPILER ERROR at PC279: Confused about usage of register: R21 in 'UnsetPending'

    ;
    (self.tbFirstHalfCount)[4] = mapFirst.Time
    self.tbSecondHalfCount = {}
    self.tbBonusKillFirstHalf = {}
    for i = 5, 8 do
      (table.insert)(self.tbBonusKillFirstHalf, (mapFirst.KillCount)[i] or 0)
    end
    self.tbBonusKillEliteFirstHalf = {}
    for i = 9, 12 do
      (table.insert)(self.tbBonusKillEliteFirstHalf, (mapFirst.KillCount)[i] or 0)
    end
    self.tbBonusKill = {0, 0, 0}
    self.tbBonusKillElite = {0, 0, 0}
    self.nCurBonusCount = 0
    self.nBonusExpireTime = 0
    self.nMonsterCount = 0
    self.nEliteMonsterCount = 0
    self.nLordCount = 0
    self.nBossCount = 0
    self.mapExReward = {}
    self.nScoreShow = self:CalCurScore()
    for _,mapEvent in ipairs(tbEvent) do
      if mapEvent.EventType == 1 then
        for _,nWave in ipairs(mapEvent.Numbers) do
          if tbWaveCount[1] - nWave >= 0 then
            (table.insert)(self.tbFirstHalfEventType1, nWave)
          else
            (table.insert)(self.tbSecondHalfEventType1, nWave - tbWaveCount[1])
          end
        end
      else
        for _,nWave in ipairs(mapEvent.Numbers) do
          if tbWaveCount[1] - nWave >= 0 then
            (table.insert)(self.tbFirstHalfEventType2, nWave)
          else
            (table.insert)(self.tbSecondHalfEventType2, nWave - tbWaveCount[1])
          end
        end
      end
    end
    local GetBuildCallback = function(mapBuildData)
    -- function num : 0_1_3 , upvalues : self, _ENV
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
    self.tbPotentials = (self.mapBuildData).tbPotentials
    self.mapActorInfo = {}
    for idx,nTid in ipairs(self.tbCharId) do
      local stActorInfo = self:CalCharFixedEffect(nTid, idx == 1, self.tbDiscId)
      -- DECOMPILER ERROR at PC50: Confused about usage of register: R7 in 'UnsetPending'

      ;
      (self.mapActorInfo)[nTid] = stActorInfo
    end
    local tbActivedDropData = (PlayerData.VampireSurvivor):GetActivedDropItem()
    ;
    ((CS.AdventureModuleHelper).EnterVampireFloor)(self.floorId, self.tbCharId, false, self.tbSecondHalfEventType1, self.tbSecondHalfEventType2, self.bHalfBattle, tbActivedDropData)
    ;
    (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.VampireSurvivorBattlePanel, self.tbCharId, self.nLevelId)
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

    ;
    (PlayerData.Build):GetBuildDetailData(GetBuildCallback, nBuildId2)
    -- DECOMPILER ERROR: 15 unprocessed JMP targets
  end
end

VampireSurvivorLevelData.BindEvent = function(self)
  -- function num : 0_2 , upvalues : _ENV, mapEventConfig
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

VampireSurvivorLevelData.UnBindEvent = function(self)
  -- function num : 0_3 , upvalues : _ENV, mapEventConfig
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

VampireSurvivorLevelData.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_4 , upvalues : _ENV
  (PlayerData.Achievement):SetSpecialBattleAchievement((GameEnum.levelType).VampireInstance)
  ;
  (EventManager.Hit)("CacheInstanceHud", 100)
  self:ResetFateCardThemeInfo()
  self:SetPersonalPerk()
  self:SetDiscInfo()
  safe_call_cs_func((CS.AdventureModuleHelper).SetBuildLevel, ((self.mapBuildData).mapRank).Id)
  for nCharId,stActorInfo in pairs(self.mapActorInfo) do
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
  self:AddExp(0)
  ;
  (EventManager.Hit)("VampireScoreChange", self.nScoreShow)
  ;
  (EventManager.Hit)("VampireBonusExpire")
end

VampireSurvivorLevelData.CalCharFixedEffect = function(self, nCharId, bMainChar, tbDiscId)
  -- function num : 0_5 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar, tbDiscId, (self.mapBuildData).nBuildId)
  return stActorInfo
end

VampireSurvivorLevelData.OpenFateCardSelect = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local SelectCallback = function(nIdx, nId, panelCallback, bReRoll, bReward)
    -- function num : 0_6_0 , upvalues : self, _ENV
    local CheckChest = function()
      -- function num : 0_6_0_0 , upvalues : self, _ENV
      if #self.tbChest > 0 then
        local tbParam = (table.remove)(self.tbChest, 1)
        self:GetChest(tbParam[1], tbParam[2])
      end
    end

    do
      if nIdx == -1 then
        local wait = function()
      -- function num : 0_6_0_1 , upvalues : self, CheckChest
      self.bHandleFateCard = false
      CheckChest()
    end

        ;
        (cs_coroutine.start)(wait)
        return 
      end
      if nIdx == -2 then
        self.mapNextReward = nil
        self.nPendingLevelUp = self.nPendingLevelUp - 1
        local wait = function()
      -- function num : 0_6_0_2 , upvalues : self, CheckChest
      self.bHandleFateCard = false
      CheckChest()
    end

        ;
        (cs_coroutine.start)(wait)
        return 
      end
      do
        local msg = {}
        msg.Id = nId
        msg.SelectReq = {}
        if bReRoll then
          msg.ReRoll = true
        else
          msg.Index = nIdx - 1
        end
        if self.nPendingLevelUp > 0 then
          if ((self.mapNextReward).Pkg).ReRoll <= 0 then
            panelCallback(1, ((self.mapNextReward).Pkg).Cards, {CanReRoll = not bReward, ReRollPrice = ((self.mapNextReward).Pkg).ReRoll}, 0, false, self.mapFateCard)
            panelCallback(0, {}, {CanReRoll = false, ReRollPrice = ((self.mapNextReward).Pkg).ReRoll}, 0, false, self.mapFateCard)
            do return  end
            local InteractiveCallback = function(_, callbackMsg)
      -- function num : 0_6_0_3 , upvalues : self, panelCallback, _ENV
      if callbackMsg.Resp ~= nil and (callbackMsg.Resp).Reward ~= nil then
        self.mapNextReward = (callbackMsg.Resp).Reward
        self.nPendingLevelUp = self.nPendingLevelUp - 1
        if self:AddFateCard((callbackMsg.Resp).FateCardId) then
          self:AddFateCardEft((callbackMsg.Resp).FateCardId)
          self:AddFateCardTheme((callbackMsg.Resp).FateCardId)
        end
        if (callbackMsg.Resp).ExtraCards ~= nil and #(callbackMsg.Resp).ExtraCards > 0 then
          panelCallback(1, (callbackMsg.Resp).ExtraCards, {CanReRoll = false, ReRollPrice = 0}, 0, true, self.mapFateCard)
          for index,value in ipairs((callbackMsg.Resp).ExtraCards) do
            if self:AddFateCard(value.Id) then
              self:AddFateCardEft(value.Id)
              self:AddFateCardTheme(value.Id)
            end
          end
          return 
        end
        if ((self.mapNextReward).Pkg).ReRoll <= 0 then
          panelCallback(1, ((self.mapNextReward).Pkg).Cards, {CanReRoll = self.nPendingLevelUp <= 0, ReRollPrice = ((self.mapNextReward).Pkg).ReRoll}, 0, false, self.mapFateCard)
          panelCallback(0, {}, {CanReRoll = false, ReRollPrice = ((self.mapNextReward).Pkg).ReRoll}, 0, false, self.mapFateCard)
          if callbackMsg ~= nil then
            self.mapNextReward = callbackMsg
            panelCallback(1, ((self.mapNextReward).Pkg).Cards, {CanReRoll = ((self.mapNextReward).Pkg).ReRoll > 0, ReRollPrice = ((self.mapNextReward).Pkg).ReRoll}, 0, false, self.mapFateCard)
          end
          -- DECOMPILER ERROR: 5 unprocessed JMP targets
        end
      end
    end

            ;
            (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_reward_select_req, msg, nil, InteractiveCallback)
            -- DECOMPILER ERROR: 4 unprocessed JMP targets
          end
        end
      end
    end
  end

  do
    if self.mapNextReward ~= nil then
      local nCoin = 0
      self.bHandleFateCard = true
      ;
      (EventManager.Hit)("VampireSelectFateCard", 1, ((self.mapNextReward).Pkg).Cards, SelectCallback, {CanReRoll = ((self.mapNextReward).Pkg).ReRoll > 0, ReRollPrice = ((self.mapNextReward).Pkg).ReRoll}, 0, false, self.mapFateCard)
    end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end
end

VampireSurvivorLevelData.OpenExFateCardSelect = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local SelectCallback = function(nIdx, nId, panelCallback, bReRoll)
    -- function num : 0_7_0 , upvalues : self, _ENV
    do
      if nIdx == -1 then
        local wait = function()
      -- function num : 0_7_0_0 , upvalues : self
      self.bHandleFateCard = false
    end

        ;
        (cs_coroutine.start)(wait)
        return 
      end
      if nIdx == -2 then
        self.mapExReward = nil
        local wait = function()
      -- function num : 0_7_0_1 , upvalues : self
      self.bHandleFateCard = false
    end

        ;
        (cs_coroutine.start)(wait)
        return 
      end
      do
        local msg = {}
        msg.Id = nId
        msg.SelectReq = {}
        if bReRoll then
          msg.ReRoll = true
        else
          msg.Index = nIdx - 1
        end
        local InteractiveCallback = function(_, callbackMsg)
      -- function num : 0_7_0_2 , upvalues : self, panelCallback
      self.mapExReward = nil
      panelCallback(0, {}, {}, {CanReRoll = false, ReRollPrice = 0}, 0, false, self.mapFateCard)
    end

        ;
        (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_extra_reward_select_req, msg, nil, InteractiveCallback)
      end
    end
  end

  do
    if self.mapExReward ~= nil then
      local nCoin = 0
      self.bHandleFateCard = true
      ;
      (EventManager.Hit)("VampireSelectFateCard", 1, ((self.mapExReward).Pkg).Cards, SelectCallback, {CanReRoll = (self.mapExReward).ReRoll > 0, ReRollPrice = (self.mapExReward).ReRoll}, 0, false, self.mapFateCard)
    end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end
end

VampireSurvivorLevelData.AddFateCard = function(self, nFateCardId)
  -- function num : 0_8 , upvalues : _ENV
  local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R3 in 'UnsetPending'

  if mapFateCardCfgData == nil then
    (self.mapFateCard)[nFateCardId] = 0
    return false
  end
  if mapFateCardCfgData == nil or mapFateCardCfgData.Duration == nil or mapFateCardCfgData.Duration == 0 then
    printError("FateCardCfgData Missing or no Duration Time:" .. nFateCardId)
    -- DECOMPILER ERROR at PC25: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self.mapFateCard)[nFateCardId] = 0
    return false
  end
  -- DECOMPILER ERROR at PC32: Confused about usage of register: R3 in 'UnsetPending'

  if mapFateCardCfgData.Duration == -1 then
    (self.mapFateCard)[nFateCardId] = -1
  else
    local limitTime = self.nCurTotalTimeFateCard + mapFateCardCfgData.Duration
    -- DECOMPILER ERROR at PC43: Confused about usage of register: R4 in 'UnsetPending'

    if (self.mapFateCardTimeLimit)[limitTime] == nil then
      (self.mapFateCardTimeLimit)[limitTime] = {}
    end
    ;
    (table.insert)((self.mapFateCardTimeLimit)[limitTime], nFateCardId)
    -- DECOMPILER ERROR at PC51: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self.mapFateCard)[nFateCardId] = limitTime
  end
  do
    local stFateCard = (CS.Lua2CSharpInfo_FateCardInfo)()
    stFateCard.fateCardId = nFateCardId
    stFateCard.Remain = 0
    stFateCard.Room = 0
    safe_call_cs_func((CS.AdventureModuleHelper).UpdateFateCardInfos, {stFateCard})
    return true
  end
end

VampireSurvivorLevelData.AddFateCardEft = function(self, nFateCardId)
  -- function num : 0_9 , upvalues : _ENV
  local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
  if mapFateCardCfgData == nil then
    return 
  end
  -- DECOMPILER ERROR at PC19: Confused about usage of register: R3 in 'UnsetPending'

  if (self.mapFateCardEft)[mapFateCardCfgData.ClientEffect] == nil then
    (self.mapFateCardEft)[mapFateCardCfgData.ClientEffect] = {nFateCardId = nFateCardId, 
tbEftUid = {}
}
  end
  for _,nEftId in ipairs(mapFateCardCfgData.ClientExEffect) do
    -- DECOMPILER ERROR at PC33: Confused about usage of register: R8 in 'UnsetPending'

    if (self.mapFateCardEft)[nEftId] == nil then
      (self.mapFateCardEft)[nEftId] = {nFateCardId = nFateCardId, 
tbEftUid = {}
}
    end
  end
  if mapFateCardCfgData.ClientEffect ~= 0 then
    local nRemainCount = mapFateCardCfgData.Count
    -- DECOMPILER ERROR at PC56: Confused about usage of register: R4 in 'UnsetPending'

    if nRemainCount > 0 then
      if (self.mapFateCardEftCount)[mapFateCardCfgData.ClientEffect] ~= nil then
        if ((self.mapFateCardEftCount)[mapFateCardCfgData.ClientEffect])[nFateCardId] == nil then
          ((self.mapFateCardEftCount)[mapFateCardCfgData.ClientEffect])[nFateCardId] = nRemainCount
        end
        nRemainCount = ((self.mapFateCardEftCount)[mapFateCardCfgData.ClientEffect])[nFateCardId]
        if nRemainCount < 1 then
          print("命运卡效果次数为0" .. nFateCardId)
          return 
        end
      else
        -- DECOMPILER ERROR at PC73: Confused about usage of register: R4 in 'UnsetPending'

        ;
        (self.mapFateCardEftCount)[mapFateCardCfgData.ClientEffect] = {}
        -- DECOMPILER ERROR at PC77: Confused about usage of register: R4 in 'UnsetPending'

        ;
        ((self.mapFateCardEftCount)[mapFateCardCfgData.ClientEffect])[nFateCardId] = nRemainCount
      end
    end
    for _,nCharId in ipairs(self.tbCharId) do
      local nUid = (UTILS.AddFateCardEft)(nCharId, mapFateCardCfgData.ClientEffect, nRemainCount)
      ;
      (table.insert)(((self.mapFateCardEft)[mapFateCardCfgData.ClientEffect]).tbEftUid, {nUid, nCharId})
      for _,nEftId in ipairs(mapFateCardCfgData.ClientExEffect) do
        local nUid = (UTILS.AddFateCardEft)(nCharId, nEftId, -1)
        ;
        (table.insert)(((self.mapFateCardEft)[nEftId]).tbEftUid, {nUid, nCharId})
      end
    end
    print("添加命运卡效果：" .. nFateCardId)
  end
end

VampireSurvivorLevelData.AddFateCardTheme = function(self, nFateCardId)
  -- function num : 0_10 , upvalues : _ENV
  local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
  if mapFateCardCfgData == nil then
    return 
  end
  local operateType = 1
  if mapFateCardCfgData.ThemeType ~= (GameEnum.fateCardTheme).NoType then
    local tbTriggerType = mapFateCardCfgData.ThemeTriggerType
    local nCurLevel = nil
    if (self.mapFateCardTheme)[mapFateCardCfgData.ThemeType] ~= nil then
      nCurLevel = ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).nCurLevel
    end
    if nCurLevel == nil then
      operateType = 1
      -- DECOMPILER ERROR at PC40: Confused about usage of register: R6 in 'UnsetPending'

      if (self.mapFateCardTheme)[mapFateCardCfgData.ThemeType] == nil then
        (self.mapFateCardTheme)[mapFateCardCfgData.ThemeType] = {nCurLevel = 0, 
tbTriggerType = {}
}
      end
      -- DECOMPILER ERROR at PC45: Confused about usage of register: R6 in 'UnsetPending'

      ;
      ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).nCurLevel = mapFateCardCfgData.ThemeValue
      -- DECOMPILER ERROR at PC52: Confused about usage of register: R6 in 'UnsetPending'

      ;
      ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType = clone(tbTriggerType)
    else
      if nCurLevel == (GameEnum.fateCardThemeRank).Base and nCurLevel < mapFateCardCfgData.ThemeValue then
        operateType = 2
        -- DECOMPILER ERROR at PC67: Confused about usage of register: R6 in 'UnsetPending'

        ;
        ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).nCurLevel = mapFateCardCfgData.ThemeValue
        for _,triggerType in ipairs(tbTriggerType) do
          if (table.indexof)(((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType, triggerType) < 1 then
            (table.insert)(((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType, triggerType)
          end
        end
      else
        do
          if (nCurLevel == (GameEnum.fateCardThemeRank).ProA and mapFateCardCfgData.ThemeValue == (GameEnum.fateCardThemeRank).ProB) or nCurLevel == (GameEnum.fateCardThemeRank).ProB and mapFateCardCfgData.ThemeValue == (GameEnum.fateCardThemeRank).ProA then
            operateType = 2
            -- DECOMPILER ERROR at PC122: Confused about usage of register: R6 in 'UnsetPending'

            ;
            ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).nCurLevel = (GameEnum.fateCardThemeRank).Super
            for _,triggerType in ipairs(tbTriggerType) do
              if (table.indexof)(((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType, triggerType) < 1 then
                (table.insert)(((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType, triggerType)
              end
            end
          else
            do
              do return  end
              local fcInfo = (CS.Lua2CSharpInfo_FateCardThemeInfo)()
              fcInfo.theme = mapFateCardCfgData.ThemeType
              fcInfo.rank = ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).nCurLevel
              fcInfo.triggerTypes = ((self.mapFateCardTheme)[mapFateCardCfgData.ThemeType]).tbTriggerType
              fcInfo.operateType = operateType
              safe_call_cs_func((CS.AdventureModuleHelper).SetFateCardThemes, {fcInfo})
            end
          end
        end
      end
    end
  end
end

VampireSurvivorLevelData.ResetFateCardThemeInfo = function(self)
  -- function num : 0_11 , upvalues : _ENV
  local tbFCInfo = {}
  for nThemeType,mapData in pairs(self.mapFateCardTheme) do
    local fcInfo = (CS.Lua2CSharpInfo_FateCardThemeInfo)()
    fcInfo.theme = nThemeType
    fcInfo.rank = mapData.nCurLevel
    fcInfo.triggerTypes = mapData.tbTriggerType
    fcInfo.operateType = 1
    ;
    (table.insert)(tbFCInfo, fcInfo)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetFateCardThemes, tbFCInfo)
end

VampireSurvivorLevelData.RemoveFateCardEft = function(self, nFateCardId)
  -- function num : 0_12 , upvalues : _ENV
  local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
  if mapFateCardCfgData == nil then
    printError("FateCardCfgData Missing:" .. nFateCardId)
  else
    print("移除命运卡效果：" .. nFateCardId)
    local nEftId = mapFateCardCfgData.ClientEffect
    if (self.mapFateCardEft)[nEftId] ~= nil and ((self.mapFateCardEft)[nEftId]).tbEftUid ~= nil then
      for _,tbUid in ipairs(((self.mapFateCardEft)[nEftId]).tbEftUid) do
        (UTILS.RemoveEffect)(tbUid[1], tbUid[2])
      end
      -- DECOMPILER ERROR at PC42: Confused about usage of register: R4 in 'UnsetPending'

      ;
      (self.mapFateCardEft)[nEftId] = nil
    end
    for _,nExEftId in ipairs(mapFateCardCfgData.ClientExEffect) do
      if (self.mapFateCardEft)[nExEftId] ~= nil and ((self.mapFateCardEft)[nExEftId]).tbEftUid ~= nil then
        for _,tbUid in ipairs(((self.mapFateCardEft)[nExEftId]).tbEftUid) do
          (UTILS.RemoveEffect)(tbUid[1], tbUid[2])
        end
        -- DECOMPILER ERROR at PC70: Confused about usage of register: R9 in 'UnsetPending'

        ;
        (self.mapFateCardEft)[nExEftId] = nil
      end
    end
  end
end

VampireSurvivorLevelData.AbandonBattle = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local netMsgCallback = function(_, msgData)
    -- function num : 0_13_0 , upvalues : _ENV, self
    local mapFirst = {}
    local mapSecond = {}
    local maplevelData = (ConfigTable.GetData)("VampireSurvivor", self.nLevelId)
    if maplevelData == nil then
      return 
    end
    if not self.bFirstHalfEnd or not 1 then
      local nBossCount = not self.isFirstHalf or 0
    end
    local nBossTime = self.bFirstHalfEnd and self.nBossTime or 0
    do
      local nBossScore = self.bFirstHalfEnd and maplevelData.BossScore1 or 0
      mapFirst.KillCount = {self.nMonsterCount, self.nEliteMonsterCount, self.nLordCount, nBossCount}
      mapFirst.KillScore = {self.nMonsterCount * maplevelData.NormalScore1, (self.nEliteMonsterCount + self.nLordCount) * maplevelData.EliteScore1, 0, nBossScore}
      for i = 1, #self.tbBonusPower do
        (table.insert)(mapFirst.KillCount, (self.tbBonusKill)[i])
        ;
        (table.insert)(mapFirst.KillScore, (math.floor)(((self.tbBonusKill)[i] or 0) * (((self.tbBonusPower)[i] - 100) / 100) * maplevelData.NormalScore1))
      end
      for i = 1, #self.tbBonusPower do
        (table.insert)(mapFirst.KillCount, (self.tbBonusKillElite)[i])
        ;
        (table.insert)(mapFirst.KillScore, (math.floor)(((self.tbBonusKillElite)[i] or 0) * (((self.tbBonusPower)[i] - 100) / 100) * maplevelData.EliteScore1))
      end
      mapFirst.BossTime = nBossTime
      mapFirst.Score = (msgData.Defeat).FinalScore
      mapFirst.KillCount = {(self.tbFirstHalfCount)[1], (self.tbFirstHalfCount)[2], (self.tbFirstHalfCount)[3], 1}
      mapFirst.KillScore = {(self.tbFirstHalfCount)[1] * maplevelData.NormalScore1, ((self.tbFirstHalfCount)[2] + (self.tbFirstHalfCount)[3]) * maplevelData.EliteScore1, 0, maplevelData.BossScore1}
      for i = 1, #self.tbBonusPower do
        ;
        (table.insert)(mapFirst.KillCount, (self.tbBonusKillFirstHalf)[i] or 0)
        ;
        (table.insert)(mapFirst.KillScore, (math.floor)(((self.tbBonusKillFirstHalf)[i] or 0) * (((self.tbBonusPower)[i] - 100) / 100) * maplevelData.NormalScore1))
      end
      for i = 1, #self.tbBonusPower do
        (table.insert)(mapFirst.KillCount, (self.tbBonusKillEliteFirstHalf)[i])
        ;
        (table.insert)(mapFirst.KillScore, (math.floor)(((self.tbBonusKillEliteFirstHalf)[i] or 0) * (((self.tbBonusPower)[i] - 100) / 100) * maplevelData.EliteScore1))
      end
      mapFirst.BossTime = (self.tbFirstHalfCount)[4]
      local nTimeScore = (math.floor)((self.nFirstBossTime - (self.tbFirstHalfCount)[4]) / self.nFirstBossTime * maplevelData.TimeScore1)
      do
        local nFinalScore = 0
        for _,nScore in ipairs(mapFirst.KillScore) do
          nFinalScore = nFinalScore + nScore
        end
        mapFirst.Score = nTimeScore + (nFinalScore)
        mapSecond.KillCount = {self.nMonsterCount, self.nEliteMonsterCount, self.nLordCount, 0}
        mapSecond.KillScore = {self.nMonsterCount * maplevelData.NormalScore2, (self.nEliteMonsterCount + self.nLordCount) * maplevelData.EliteScore2, 0, 0}
        for i = 1, #self.tbBonusPower do
          ;
          (table.insert)(mapSecond.KillCount, (self.tbBonusKill)[i] or 0)
          ;
          (table.insert)(mapSecond.KillScore, (math.floor)(((self.tbBonusKill)[i] or 0) * (((self.tbBonusPower)[i] - 100) / 100) * maplevelData.NormalScore2))
        end
        for i = 1, #self.tbBonusPower do
          ;
          (table.insert)(mapSecond.KillCount, (self.tbBonusKillElite)[i] or 0)
          ;
          (table.insert)(mapSecond.KillScore, (math.floor)(((self.tbBonusKillElite)[i] or 0) * (((self.tbBonusPower)[i] - 100) / 100) * maplevelData.EliteScore2))
        end
        mapSecond.BossTime = 0
        mapSecond.Score = (msgData.Defeat).FinalScore - mapFirst.Score
        local mapLevelData = (ConfigTable.GetData)("VampireSurvivor", self.nLevelId)
        if mapLevelData ~= nil and mapLevelData.Type == (GameEnum.vampireSurvivorType).Turn then
          (self.parent):AddPointAndLevel((msgData.Defeat).FinalScore, 0, (msgData.Defeat).SeasonId)
        end
        local nOldScore = (PlayerData.VampireSurvivor):GetScoreByLevel(self.nLevelId)
        ;
        (PlayerData.VampireSurvivor):CacheScoreByLevel(self.nLevelId, (msgData.Defeat).FinalScore)
        self:OpenVampireSettle(false, mapFirst, mapSecond, (msgData.Defeat).FinalScore, nOldScore < (msgData.Defeat).FinalScore)
        -- DECOMPILER ERROR: 1 unprocessed JMP targets
      end
    end
  end

  local nBossCount = 0
  local nBossTime = 0
  if self.isFirstHalf then
    self.tbCharDamageFirst = self:RefreshCharDamageData()
    nBossCount = self.bFirstHalfEnd and 1 or 0
    nBossTime = self.bFirstHalfEnd and self.nBossTime or 0
  else
    if self.isFirstHalf == false and self.bHalfBattle == false then
      self.tbCharDamageSecond = self:RefreshCharDamageData()
    end
  end
  local tbKillCount = {self.nMonsterCount, self.nEliteMonsterCount, self.nLordCount, nBossCount}
  for i = 1, #self.tbBonusPower do
    ;
    (table.insert)(tbKillCount, (self.tbBonusKill)[i] or 0)
  end
  for i = 1, #self.tbBonusPower do
    ;
    (table.insert)(tbKillCount, (self.tbBonusKillElite)[i] or 0)
  end
  local msg = {KillCount = tbKillCount, Time = nBossTime, Defeat = true, 
Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).VampireInstance, false)}
}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_settle_req, msg, nil, netMsgCallback)
  self.bBattleEnd = true
end

VampireSurvivorLevelData.BattleSuccess = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local netMsgCallback = function(_, msgData)
    -- function num : 0_14_0 , upvalues : self, _ENV
    (self.parent):SetBattleSuccess()
    local mapLevelData = (ConfigTable.GetData)("VampireSurvivor", self.nLevelId)
    if mapLevelData ~= nil then
      if mapLevelData.Type == (GameEnum.vampireSurvivorType).Turn then
        (self.parent):AddPointAndLevel((msgData.Victory).FinalScore, self.nLevelId, (msgData.Victory).SeasonId)
      else
        ;
        (self.parent):AddPointAndLevel(0, self.nLevelId, (msgData.Victory).SeasonId)
      end
    end
    local nOldScore = (PlayerData.VampireSurvivor):GetScoreByLevel(self.nLevelId)
    ;
    (PlayerData.VampireSurvivor):CacheScoreByLevel(self.nLevelId, (msgData.Victory).FinalScore)
    self:OpenVampireSettle(true, ((msgData.Victory).Infos)[1], ((msgData.Victory).Infos)[2], (msgData.Victory).FinalScore, nOldScore < (msgData.Victory).FinalScore)
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end

  local tbKillCount = {self.nMonsterCount, self.nEliteMonsterCount, self.nLordCount, 1}
  for i = 1, #self.tbBonusPower do
    ;
    (table.insert)(tbKillCount, (self.tbBonusKill)[i] or 0)
  end
  for i = 1, #self.tbBonusPower do
    ;
    (table.insert)(tbKillCount, (self.tbBonusKillElite)[i] or 0)
  end
  local msg = {KillCount = tbKillCount, Time = self.nBossTime, Defeat = false, 
Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).VampireInstance, true)}
}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_settle_req, msg, nil, netMsgCallback)
  self.bBattleEnd = true
end

VampireSurvivorLevelData.ChangeArea = function(self)
  -- function num : 0_15 , upvalues : _ENV
  local netMsgCallback = function(_, msgData)
    -- function num : 0_15_0 , upvalues : self, _ENV
    local GetBuildCallback = function(mapBuildData)
      -- function num : 0_15_0_0 , upvalues : self, _ENV
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
      self.isFirstHalf = false
      local tbActivedDropData = (PlayerData.VampireSurvivor):GetActivedDropItem()
      ;
      ((CS.AdventureModuleHelper).EnterVampireFloor)(self.floorId, self.tbCharId, self.isFirstHalf, self.tbSecondHalfEventType1, self.tbSecondHalfEventType2, false, tbActivedDropData)
      local levelEndCallback = function()
        -- function num : 0_15_0_0_0 , upvalues : _ENV, self, levelEndCallback
        (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
        self.bHandleFateCard = false
        self.nPendingLevelUp = 0
        self.nBossTime = 0
        self.nMonsterCount = 0
        self.nEliteMonsterCount = 0
        self.nLordCount = 0
        self.nBossCount = 0
        self.bBoss = false
        self.mapFateCardEft = {}
        self.bBattleEnd = false
        self.tbBonusKill = {}
        self.tbBonusKillElite = {}
        self.nCurBonusCount = 0
        self.nBonusExpireTime = 0
        self.nScoreShow = self:CalCurScore()
        ;
        (EventManager.Hit)("VampireScoreChange", self.nScoreShow)
        self.cachedFirstFateCard = {nCurLevel = self.nCurLevel, nCurExp = self.nCurExp, mapNextReward = self.mapNextReward, mapFateCard = clone(self.mapFateCard), mapFateCardEftCount = clone(self.mapFateCardEftCount), mapFateCardTimeLimit = clone(self.mapFateCardTimeLimit), mapFateCardTheme = clone(self.mapFateCardTheme), nCurTotalTimeFateCard = self.nCurTotalTimeFateCard, nScoreShow = self.nScoreShow}
        self:SetPersonalPerk()
        self:SetDiscInfo()
        self:ResetFateCardThemeInfo()
        safe_call_cs_func((CS.AdventureModuleHelper).SetBuildLevel, ((self.mapBuildData).mapRank).Id)
        for idx,nCharId in ipairs(self.tbCharId) do
          local stActorInfo, nHeartStoneLevel = self:CalCharFixedEffect(nCharId, idx == 1)
          safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
        end
        -- DECOMPILER ERROR: 2 unprocessed JMP targets
      end

      ;
      (EventManager.Hit)("VampireSurvivorChangeArea", self.tbCharId)
      ;
      (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
      ;
      (NovaAPI.DispatchEventWithData)("Level_Restart", nil, {})
      local wait = function()
        -- function num : 0_15_0_0_1 , upvalues : _ENV
        (PanelManager.InputEnable)()
        ;
        (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
        ;
        (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
        ;
        ((CS.AdventureModuleHelper).LevelStateChanged)(false)
      end

      ;
      (cs_coroutine.start)(wait)
      -- DECOMPILER ERROR: 2 unprocessed JMP targets
    end

    ;
    (PlayerData.Build):GetBuildDetailData(GetBuildCallback, self.nBuildId2)
  end

  local tbKillCount = {self.nMonsterCount, self.nEliteMonsterCount, self.nLordCount, 1}
  for i = 1, #self.tbBonusPower do
    ;
    (table.insert)(tbKillCount, (self.tbBonusKill)[i] or 0)
  end
  for i = 1, #self.tbBonusPower do
    ;
    (table.insert)(tbKillCount, (self.tbBonusKillElite)[i] or 0)
  end
  local tbFateCardEft = {}
  for nEftId,mapFateCardEft in pairs(self.mapFateCardEftCount) do
    for nFateCardId,nRemainCount in pairs(mapFateCardEft) do
      (table.insert)(tbFateCardEft, {Id = nFateCardId, EftId = nEftId, Count = nRemainCount})
    end
  end
  local tbFateCardTime = {}
  for nTimeLimit,tbFateCard in pairs(self.mapFateCardTimeLimit) do
    for _,nFateCardId in ipairs(tbFateCard) do
      (table.insert)(tbFateCardTime, {Id = nFateCardId, TimeLimit = nTimeLimit})
    end
  end
  local clientData = {Efts = tbFateCardEft, Limits = tbFateCardTime, FateCardTimer = self.nCurTotalTimeFateCard, Level = self.nCurLevel, Exp = self.nCurExp}
  local msg = {KillCount = tbKillCount, Time = self.nBossTime, 
Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).VampireInstance, true)}
, ClientData = clientData}
  self.tbFirstHalfCount = {self.nMonsterCount, self.nEliteMonsterCount, self.nLordCount, self.nBossTime}
  self.tbBonusKillFirstHalf = clone(self.tbBonusKill)
  self.tbBonusKillEliteFirstHalf = clone(self.tbBonusKillElite)
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_area_change_req, msg, nil, netMsgCallback)
  self.bBattleEnd = true
end

VampireSurvivorLevelData.SetDiscInfo = function(self)
  -- function num : 0_16 , upvalues : _ENV
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

VampireSurvivorLevelData.SetPersonalPerk = function(self)
  -- function num : 0_17 , upvalues : _ENV
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

VampireSurvivorLevelData.BonusKill = function(self, nType)
  -- function num : 0_18 , upvalues : _ENV
  if self.nBonusTime == 0 then
    return 
  end
  self.nBonusExpireTime = self.nCurTotalTime + self.nBonusTime
  self.nCurBonusCount = self.nCurBonusCount + 1
  ;
  (EventManager.Hit)("VampireBonusKill", self.nCurBonusCount)
  local nRank = 0
  if nType == 0 or nType == nil then
    return 
  end
  for i = #self.tbBonusRank, 1, -1 do
    -- DECOMPILER ERROR at PC39: Confused about usage of register: R7 in 'UnsetPending'

    if (self.tbBonusRank)[i] <= self.nCurBonusCount then
      if nType == 1 then
        if (self.tbBonusKill)[i] == nil then
          (self.tbBonusKill)[i] = 0
        end
        -- DECOMPILER ERROR at PC44: Confused about usage of register: R7 in 'UnsetPending'

        ;
        (self.tbBonusKill)[i] = (self.tbBonusKill)[i] + 1
      else
        -- DECOMPILER ERROR at PC51: Confused about usage of register: R7 in 'UnsetPending'

        if (self.tbBonusKillElite)[i] == nil then
          (self.tbBonusKillElite)[i] = 0
        end
        -- DECOMPILER ERROR at PC56: Confused about usage of register: R7 in 'UnsetPending'

        ;
        (self.tbBonusKillElite)[i] = (self.tbBonusKillElite)[i] + 1
      end
      nRank = i
      break
    end
  end
  do
    return nRank
  end
end

VampireSurvivorLevelData.ReTry = function(self)
  -- function num : 0_19 , upvalues : _ENV
  (PanelManager.InputDisable)()
  if self.isFirstHalf then
    local NetCallback = function(_, netMsg)
    -- function num : 0_19_0 , upvalues : self, _ENV
    self.nCurLevel = 1
    self.nCurExp = 0
    self.nCurTotalTime = 0
    self.nCurTotalTimeFateCard = 0
    self.nBossTime = 0
    self.bBoss = false
    self.bHandleFateCard = false
    self.nPendingLevelUp = 0
    self.bHandleChest = false
    self.tbChest = {}
    self.mapFateCard = {}
    self.mapFateCardEft = {}
    self.mapFateCardEftCount = {}
    self.mapFateCardTimeLimit = {}
    self.mapFateCardTheme = {}
    self.nFirstBossTime = 60
    self.bFirstHalfEnd = false
    self.bBattleEnd = false
    self.tbFirstHalfEventType1 = {}
    self.tbFirstHalfEventType2 = {}
    self.tbSecondHalfEventType1 = {}
    self.tbSecondHalfEventType2 = {}
    self.tbFirstHalfCount = {}
    self.tbSecondHalfCount = {}
    self.tbBonusKillFirstHalf = {}
    self.tbBonusKill = {}
    self.tbBonusKillElite = {}
    self.nCurBonusCount = 0
    self.nBonusExpireTime = 0
    self.nScoreShow = 0
    self.nMonsterCount = 0
    self.nEliteMonsterCount = 0
    self.nLordCount = 0
    self.nBossCount = 0
    self.mapNextReward = netMsg.Reward
    self.mapExReward = netMsg.Select
    local mapVampireFloorData = (ConfigTable.GetData)("VampireFloor", self.floorId)
    if mapVampireFloorData == nil then
      return 
    end
    local tbWaveCount = mapVampireFloorData.WaveCount
    for _,mapEvent in ipairs(netMsg.Events) do
      if mapEvent.EventType == 1 then
        for _,nWave in ipairs(mapEvent.Numbers) do
          if tbWaveCount[1] - nWave >= 0 then
            (table.insert)(self.tbFirstHalfEventType1, nWave)
          else
            ;
            (table.insert)(self.tbSecondHalfEventType1, nWave - tbWaveCount[1])
          end
        end
      else
        do
          for _,nWave in ipairs(mapEvent.Numbers) do
            if tbWaveCount[1] - nWave >= 0 then
              (table.insert)(self.tbFirstHalfEventType2, nWave)
            else
              ;
              (table.insert)(self.tbSecondHalfEventType2, nWave - tbWaveCount[1])
            end
          end
          do
            -- DECOMPILER ERROR at PC114: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC114: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC114: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
    local tbActivedDropData = (PlayerData.VampireSurvivor):GetActivedDropItem()
    ;
    ((CS.AdventureModuleHelper).EnterVampireFloor)(self.floorId, self.tbCharId, true, self.tbFirstHalfEventType1, self.tbFirstHalfEventType2, self.bHalfBattle, tbActivedDropData)
    local levelEndCallback = function()
      -- function num : 0_19_0_0 , upvalues : self, _ENV, levelEndCallback
      self:AddExp(0)
      ;
      (EventManager.Hit)("VampireScoreChange", self.nScoreShow)
      ;
      (EventManager.Hit)("VampireBonusExpire")
      ;
      (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
      self:SetPersonalPerk()
      self:SetDiscInfo()
      self:ResetFateCardThemeInfo()
      safe_call_cs_func((CS.AdventureModuleHelper).SetBuildLevel, ((self.mapBuildData).mapRank).Id)
      for idx,nCharId in ipairs(self.tbCharId) do
        local stActorInfo, nHeartStoneLevel = self:CalCharFixedEffect(nCharId, idx == 1)
        safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
      end
      -- DECOMPILER ERROR: 2 unprocessed JMP targets
    end

    ;
    (EventManager.Hit)("BattleRestart")
    ;
    (EventManager.Hit)("VampireSurvivorChangeArea", self.tbCharId)
    ;
    (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    ;
    (NovaAPI.DispatchEventWithData)("Level_Restart", nil, {})
    local wait = function()
      -- function num : 0_19_0_1 , upvalues : _ENV
      (PanelManager.InputEnable)()
      ;
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      ((CS.AdventureModuleHelper).LevelStateChanged)(false)
    end

    ;
    (cs_coroutine.start)(wait)
  end

    local BuildIds = {self.nBuildId1}
    if self.nBuildId2 > 0 then
      (table.insert)(BuildIds, self.nBuildId2)
    end
    local msg = {Id = self.nLevelId, BuildIds = BuildIds}
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_apply_req, msg, nil, NetCallback)
  else
    do
      local NetCallback = function(_, netMsg)
    -- function num : 0_19_1 , upvalues : _ENV, self
    local tbActivedDropData = (PlayerData.VampireSurvivor):GetActivedDropItem()
    ;
    ((CS.AdventureModuleHelper).EnterVampireFloor)(self.floorId, self.tbCharId, self.isFirstHalf, self.tbSecondHalfEventType1, self.tbSecondHalfEventType2, false, tbActivedDropData, true)
    local levelEndCallback = function()
      -- function num : 0_19_1_0 , upvalues : _ENV, self, levelEndCallback
      (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
      self.nBossTime = 0
      self.nMonsterCount = 0
      self.nEliteMonsterCount = 0
      self.nLordCount = 0
      self.nBossCount = 0
      self.bBoss = false
      self.mapFateCardEft = {}
      self.bBattleEnd = false
      self.tbBonusKill = {}
      self.tbBonusKillElite = {}
      self.nCurBonusCount = 0
      self.nBonusExpireTime = 0
      self.nCurLevel = (self.cachedFirstFateCard).nCurLevel
      self.nCurExp = (self.cachedFirstFateCard).nCurExp
      self.mapNextReward = (self.cachedFirstFateCard).mapNextReward
      self.mapFateCard = clone((self.cachedFirstFateCard).mapFateCard)
      self.mapFateCardEftCount = clone((self.cachedFirstFateCard).mapFateCardEftCount)
      self.mapFateCardTimeLimit = clone((self.cachedFirstFateCard).mapFateCardTimeLimit)
      self.mapFateCardTheme = clone((self.cachedFirstFateCard).mapFateCardTheme)
      self.nCurTotalTimeFateCard = clone((self.cachedFirstFateCard).nCurTotalTimeFateCard)
      self.nScoreShow = self:CalCurScore()
      self:AddExp(0)
      ;
      (EventManager.Hit)("VampireScoreChange", self.nScoreShow)
      ;
      (EventManager.Hit)("VampireBonusExpire")
      self:SetPersonalPerk()
      self:SetDiscInfo()
      self:ResetFateCardThemeInfo()
      safe_call_cs_func((CS.AdventureModuleHelper).SetBuildLevel, ((self.mapBuildData).mapRank).Id)
      for idx,nCharId in ipairs(self.tbCharId) do
        local stActorInfo, nHeartStoneLevel = self:CalCharFixedEffect(nCharId, idx == 1)
        safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
      end
      -- DECOMPILER ERROR: 2 unprocessed JMP targets
    end

    ;
    (EventManager.Hit)("VampireSurvivorChangeArea", self.tbCharId)
    ;
    (EventManager.Hit)("BattleRestart")
    ;
    (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    ;
    (NovaAPI.DispatchEventWithData)("Level_Restart", nil, {})
    local wait = function()
      -- function num : 0_19_1_1 , upvalues : _ENV
      (PanelManager.InputEnable)()
      ;
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      ((CS.AdventureModuleHelper).LevelStateChanged)(false)
    end

    ;
    (cs_coroutine.start)(wait)
  end

      do
        local msg = {}
        ;
        (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_restart_req, msg, nil, NetCallback)
        self.bHandleFateCard = false
        self.nPendingLevelUp = 0
      end
    end
  end
end

VampireSurvivorLevelData.CalCurScore = function(self)
  -- function num : 0_20 , upvalues : _ENV
  local nScore = 0
  local maplevelData = (ConfigTable.GetData)("VampireSurvivor", self.nLevelId)
  if maplevelData ~= nil then
    if self.isFirstHalf then
      local bonusKill = 0
      for nRank,nBonusCount in ipairs(self.tbBonusKill) do
        bonusKill = bonusKill + nBonusCount
        local nPower = (self.tbBonusPower)[nRank]
        if nPower == nil then
          nPower = 1
        end
        nScore = nScore + (math.floor)(nBonusCount * (nPower / 100) * maplevelData.NormalScore1)
      end
      nScore = nScore + (math.max)(self.nMonsterCount - (bonusKill), 0) * maplevelData.NormalScore1
      local bonusKillElite = 0
      for nRank,nBonusCount in ipairs(self.tbBonusKillElite) do
        bonusKillElite = bonusKillElite + nBonusCount
        local nPower = (self.tbBonusPower)[nRank]
        if nPower == nil then
          nPower = 1
        end
        nScore = nScore + (math.floor)(nBonusCount * (nPower / 100) * maplevelData.EliteScore1)
      end
      nScore = nScore + (math.max)(self.nEliteMonsterCount - (bonusKillElite), 0) * maplevelData.EliteScore1
      nScore = nScore + self.nLordCount * maplevelData.EliteScore1
      if self.bFirstHalfEnd then
        nScore = nScore + maplevelData.BossScore1
        local nTimeScore = (math.floor)((self.nFirstBossTime - self.nBossTime) / self.nFirstBossTime * maplevelData.TimeScore1)
        nScore = nScore + nTimeScore
      end
    else
      do
        local bonusKill = 0
        for nRank,nBonusCount in ipairs(self.tbBonusKillFirstHalf) do
          bonusKill = bonusKill + nBonusCount
          local nPower = (self.tbBonusPower)[nRank]
          if nPower == nil then
            nPower = 1
          end
          nScore = nScore + (math.floor)(nBonusCount * (nPower / 100) * maplevelData.NormalScore1)
        end
        nScore = nScore + (math.max)((self.tbFirstHalfCount)[1] - (bonusKill), 0) * maplevelData.NormalScore1
        local bonusKillElite = 0
        for nRank,nBonusCount in ipairs(self.tbBonusKillEliteFirstHalf) do
          bonusKillElite = bonusKillElite + nBonusCount
          local nPower = (self.tbBonusPower)[nRank]
          if nPower == nil then
            nPower = 1
          end
          nScore = nScore + (math.floor)(nBonusCount * (nPower / 100) * maplevelData.EliteScore1)
        end
        nScore = nScore + (math.max)((self.tbFirstHalfCount)[2] - (bonusKillElite), 0) * maplevelData.EliteScore1
        nScore = nScore + (self.tbFirstHalfCount)[3] * maplevelData.EliteScore1
        nScore = nScore + maplevelData.BossScore1
        bonusKill = 0
        for nRank,nBonusCount in ipairs(self.tbBonusKill) do
          bonusKill = bonusKill + nBonusCount
          local nPower = (self.tbBonusPower)[nRank]
          if nPower == nil then
            nPower = 1
          end
          nScore = nScore + (math.floor)(nBonusCount * (nPower / 100) * maplevelData.NormalScore2)
        end
        nScore = nScore + (math.max)(self.nMonsterCount - (bonusKill), 0) * maplevelData.NormalScore2
        bonusKillElite = 0
        for nRank,nBonusCount in ipairs(self.tbBonusKillElite) do
          bonusKillElite = bonusKillElite + nBonusCount
          local nPower = (self.tbBonusPower)[nRank]
          if nPower == nil then
            nPower = 1
          end
          nScore = nScore + (math.floor)(nBonusCount * (nPower / 100) * maplevelData.EliteScore2)
        end
        nScore = nScore + (math.max)(self.nEliteMonsterCount - (bonusKillElite), 0) * maplevelData.EliteScore2
        nScore = nScore + self.nLordCount * maplevelData.EliteScore2
        do
          local nTimeScore = (math.floor)((self.nFirstBossTime - (self.tbFirstHalfCount)[4]) / self.nFirstBossTime * maplevelData.TimeScore1)
          nScore = nScore + nTimeScore
          nScore = (math.floor)(nScore)
          return nScore
        end
      end
    end
  end
end

VampireSurvivorLevelData.OpenVampireSettle = function(self, bSuccess, mapFirstInfo, mapSecondInfo, nTotalScore, bNew)
  -- function num : 0_21 , upvalues : _ENV
  local nFateCardCount = 0
  for _,_ in pairs(self.mapFateCard) do
    nFateCardCount = nFateCardCount + 1
  end
  local callback = function()
    -- function num : 0_21_0 , upvalues : _ENV, self
    local levelEndCallback = function()
      -- function num : 0_21_0_0 , upvalues : _ENV, self, levelEndCallback
      (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
      ;
      (self.parent):LevelEnd()
      ;
      (NovaAPI.EnterModule)("MainMenuModuleScene", true, 17)
    end

    ;
    (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    local wait = function()
      -- function num : 0_21_0_1 , upvalues : _ENV
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (PanelManager.InputEnable)(nil, true)
      ;
      ((CS.AdventureModuleHelper).LevelStateChanged)(true, 0, true)
    end

    ;
    (cs_coroutine.start)(wait)
  end

  if mapSecondInfo == nil then
    mapSecondInfo = 
  end
  ;
  (({}).Hit)(EventId.OpenPanel, PanelId.VampireSurvivorSettle, bSuccess, self.nLevelId, nFateCardCount, mapFirstInfo, mapSecondInfo, nTotalScore, bNew, callback, self.tbCharDamageFirst, self.tbCharDamageSecond)
end

VampireSurvivorLevelData.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_22 , upvalues : _ENV
  if self.mapExReward ~= nil and (self.mapExReward).Ids ~= nil and #(self.mapExReward).Ids > 0 then
    self:OpenExFateCardSelect()
  end
  local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = (PlayerData.Build):GetBuildAllEft((self.mapBuildData).nBuildId)
  safe_call_cs_func((CS.AdventureModuleHelper).SetNoteInfo, tbNoteInfo)
  self.mapEftData = (UTILS.AddBuildEffect)(mapAllEft, mapDiscEft, mapNoteEffect)
  local tabFloorBuff = (PlayerData.VampireSurvivor):GetFloorBuff(self.floorId, self.isFirstHalf)
  safe_call_cs_func((CS.AdventureModuleHelper).VampireFloorEffects, tabFloorBuff)
  for nFateCardId,nTime in pairs(self.mapFateCard) do
    if nTime ~= 0 then
      self:AddFateCardEft(nFateCardId)
    end
  end
  for _,nEftId in pairs(self.tbActivedTalentEft) do
    for _,nCharId in pairs(self.tbCharId) do
      (UTILS.AddEffect)(nCharId, nEftId, 0, 0)
    end
  end
  local tbFateCardInfo = {}
  for nId,_ in pairs(self.mapFateCard) do
    local stFateCard = (CS.Lua2CSharpInfo_FateCardInfo)()
    stFateCard.fateCardId = nId
    stFateCard.Remain = 0
    stFateCard.Room = 0
    ;
    (table.insert)(tbFateCardInfo, stFateCard)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetFateCardInfos, tbFateCardInfo)
end

VampireSurvivorLevelData.OnEvent_BattleEnd = function(self)
  -- function num : 0_23 , upvalues : _ENV
  self.bFirstHalfEnd = true
  self.nCurBonusCount = 0
  self.nBonusExpireTime = 0
  self.nScoreShow = (math.floor)(self:CalCurScore())
  ;
  (EventManager.Hit)("VampireScoreChange", self.nScoreShow)
  ;
  (EventManager.Hit)("VampireBonusExpire")
end

VampireSurvivorLevelData.OnEvent_MonsterDied = function(self, nType)
  -- function num : 0_24 , upvalues : _ENV
  local nScore = 0
  local maplevelData = (ConfigTable.GetData)("VampireSurvivor", self.nLevelId)
  if maplevelData == nil then
    return 
  end
  if nType == (GameEnum.monsterEpicType).NORMAL then
    self.nMonsterCount = self.nMonsterCount + 1
    local nRank = self:BonusKill(1)
    local nPower = 1
    if nRank ~= 0 then
      nPower = (self.tbBonusPower)[nRank] / 100
    end
    if not self.isFirstHalf or not maplevelData.NormalScore1 then
      do
        nScore = maplevelData.NormalScore2 * (nPower)
        if nType == (GameEnum.monsterEpicType).ELITE then
          self.nEliteMonsterCount = self.nEliteMonsterCount + 1
          local nRank = self:BonusKill(2)
          local nPower = 1
          if nRank ~= 0 then
            nPower = (self.tbBonusPower)[nRank] / 100
          end
          if not self.isFirstHalf or not maplevelData.EliteScore1 then
            do
              nScore = maplevelData.EliteScore2 * (nPower)
              if nType == (GameEnum.monsterEpicType).LEADER then
                self:BonusKill()
                self.nLordCount = self.nLordCount + 1
                if not self.isFirstHalf or not maplevelData.EliteScore1 then
                  nScore = maplevelData.EliteScore2
                  if nType == (GameEnum.monsterEpicType).LORD then
                    self:BonusKill()
                    self.nBossCount = self.nBossCount + 1
                    if not self.isFirstHalf or not maplevelData.BossScore1 then
                      nScore = maplevelData.BossScore2
                    end
                  end
                  self.nScoreShow = self.nScoreShow + nScore
                  ;
                  (EventManager.Hit)("VampireScoreChange", self.nScoreShow)
                end
              end
            end
          end
        end
      end
    end
  end
end

VampireSurvivorLevelData.OnEvent_Time = function(self, nTime)
  -- function num : 0_25 , upvalues : _ENV
  if self.bBoss then
    self.nBossTime = self.nBossTime + 1
  else
    self.nCurTotalTimeFateCard = self.nCurTotalTimeFateCard + 1
    if (self.mapFateCardTimeLimit)[self.nCurTotalTimeFateCard] ~= nil then
      local tbRemoveFateCard = {}
      for _,nFateCardId in ipairs((self.mapFateCardTimeLimit)[self.nCurTotalTimeFateCard]) do
        self:RemoveFateCardEft(nFateCardId)
        ;
        (table.insert)(tbRemoveFateCard, {nTid = nFateCardId, nCount = 0})
        -- DECOMPILER ERROR at PC37: Confused about usage of register: R8 in 'UnsetPending'

        if (self.mapFateCard)[nFateCardId] ~= nil then
          (self.mapFateCard)[nFateCardId] = 0
        end
      end
      ;
      (EventManager.Hit)("VampireFateCardTips", tbRemoveFateCard)
      -- DECOMPILER ERROR at PC47: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (self.mapFateCardTimeLimit)[self.nCurTotalTimeFateCard] = nil
    end
  end
  do
    self.nCurTotalTime = self.nCurTotalTime + 1
    if self.nBonusExpireTime > 0 and self.nBonusExpireTime <= self.nCurTotalTime then
      self.nCurBonusCount = 0
      self.nBonusExpireTime = 0
      ;
      (EventManager.Hit)("VampireBonusExpire")
    end
  end
end

VampireSurvivorLevelData.OnEvent_BattlePause = function(self)
  -- function num : 0_26 , upvalues : _ENV
  local nScore = self:CalCurScore()
  ;
  (EventManager.Hit)("OpenVampirePause", self.nLevelId, self.tbCharId, self.nCurTotalTime, nScore)
end

VampireSurvivorLevelData.OnEvent_Abandon = function(self)
  -- function num : 0_27 , upvalues : _ENV
  self:AbandonBattle()
  ;
  (PanelManager.InputDisable)()
end

VampireSurvivorLevelData.OnEvent_BossSpawn = function(self)
  -- function num : 0_28
  self.bBoss = true
end

VampireSurvivorLevelData.OnEvent_OpenDepot = function(self)
  -- function num : 0_29 , upvalues : _ENV
  local mapFateCard = {}
  for nFateCardId,nTime in pairs(self.mapFateCard) do
    if nTime > 0 then
      mapFateCard[nFateCardId] = nTime - self.nCurTotalTimeFateCard
    else
      mapFateCard[nFateCardId] = nTime
    end
  end
  ;
  (EventManager.Hit)("VampireDepotOpen", mapFateCard, 1, 0)
end

VampireSurvivorLevelData.OnEvent_TakeEffect = function(self, nCharId, EffectId)
  -- function num : 0_30 , upvalues : _ENV
  if (self.mapFateCardEftCount)[EffectId] ~= nil then
    local tbRemoveFateCard = {}
    for nFateCardId,nRemainCount in pairs((self.mapFateCardEftCount)[EffectId]) do
      nRemainCount = nRemainCount - 1
      if nRemainCount < 1 then
        self:RemoveFateCardEft(nFateCardId)
        ;
        (table.insert)(tbRemoveFateCard, {nTid = nFateCardId, nCount = 0})
        -- DECOMPILER ERROR at PC28: Confused about usage of register: R9 in 'UnsetPending'

        if (self.mapFateCard)[nFateCardId] ~= nil then
          (self.mapFateCard)[nFateCardId] = 0
        end
      end
      -- DECOMPILER ERROR at PC31: Confused about usage of register: R9 in 'UnsetPending'

      ;
      ((self.mapFateCardEftCount)[EffectId])[nFateCardId] = nRemainCount
    end
    ;
    (EventManager.Hit)("VampireFateCardTips", tbRemoveFateCard)
  end
end

VampireSurvivorLevelData.OnEvent_EventTips = function(self, nType, nMonsterId)
  -- function num : 0_31 , upvalues : _ENV
  nType = (math.abs)(nType)
  if nType < 1 or nType > 4 then
    return 
  end
  ;
  (EventManager.Hit)("VampireEventTips", nType, nMonsterId)
end

VampireSurvivorLevelData.OnEvent_LevelDrop = function(self, nType, nParam1, nParam2)
  -- function num : 0_32
  if self.bBattleEnd then
    return 
  end
  if nType == 1 then
    self:AddExp(nParam1)
  else
    if nType == 2 then
      self:GetChest(nParam1, nParam2)
    end
  end
end

VampireSurvivorLevelData.AddExp = function(self, nExp)
  -- function num : 0_33 , upvalues : _ENV
  self.nCurExp = self.nCurExp + nExp
  while (self.mapLevel)[self.nCurLevel + 1] ~= nil and (self.mapLevel)[self.nCurLevel + 1] < self.nCurExp and (self.mapLevel)[self.nCurLevel + 1] ~= nil and (self.mapLevel)[self.nCurLevel + 1] < self.nCurExp do
    self.nCurExp = self.nCurExp - (self.mapLevel)[self.nCurLevel + 1]
    self.nCurLevel = self.nCurLevel + 1
    self.nPendingLevelUp = self.nPendingLevelUp + 1
  end
  local bMaxLevel = (self.mapLevel)[self.nCurLevel + 1] == nil
  if not bMaxLevel or not 0 then
    local nAllExp = (self.mapLevel)[self.nCurLevel + 1]
  end
  ;
  (EventManager.Hit)("Vampire_Exp_Change", self.nCurExp, nAllExp, self.nCurLevel, bMaxLevel)
  if self.nPendingLevelUp > 0 and not self.bHandleFateCard and not self.bHandleChest then
    self:OpenFateCardSelect()
  end
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

VampireSurvivorLevelData.GetChest = function(self, nType, nWave)
  -- function num : 0_34 , upvalues : _ENV
  if not self.isFirstHalf and nType > -3 then
    local mapVampireFloorData = (ConfigTable.GetData)("VampireFloor", self.floorId)
    if mapVampireFloorData == nil then
      return 
    end
    local tbWaveCount = mapVampireFloorData.WaveCount
    nWave = nWave + tbWaveCount[1]
  end
  do
    if self.bHandleChest or self.bHandleFateCard then
      (table.insert)(self.tbChest, {nType, nWave})
      return 
    end
    local mapRewardCard = nil
    local SelectCallback = function(nIdx, nId, panelCallback, bReRoll)
    -- function num : 0_34_0 , upvalues : self, _ENV, mapRewardCard
    do
      if nIdx == -1 then
        local wait = function()
      -- function num : 0_34_0_0 , upvalues : self
      self.bHandleChest = false
      self:AddExp(0)
    end

        ;
        (cs_coroutine.start)(wait)
        return 
      end
      if mapRewardCard ~= nil and #mapRewardCard > 0 then
        panelCallback(1, mapRewardCard, {CanReRoll = false, ReRollPrice = 0}, 0, true, self.mapFateCard)
        for index,value in ipairs(mapRewardCard) do
          if self:AddFateCard(value.Id) then
            self:AddFateCardEft(value.Id)
            self:AddFateCardTheme(value.Id)
          end
        end
        mapRewardCard = nil
        return 
      end
      if #self.tbChest > 0 then
        local tbParam = (table.remove)(self.tbChest, 1)
        local msg = {EventType = 0 - tbParam[1], Number = tbParam[2]}
        local netMsgCallback = function(_, msgData)
      -- function num : 0_34_0_1 , upvalues : panelCallback, _ENV, self
      if panelCallback ~= nil and type(panelCallback) == "function" then
        panelCallback(1, msgData.ChestCards, {CanReRoll = false, ReRollPrice = 0}, 0, true, self.mapFateCard)
      end
      for index,value in ipairs(msgData.ChestCards) do
        if self:AddFateCard(value.Id) then
          self:AddFateCardEft(value.Id)
          self:AddFateCardTheme(value.Id)
        end
      end
    end

        ;
        (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_reward_chest_req, msg, nil, netMsgCallback)
        return 
      else
        do
          if panelCallback ~= nil and type(panelCallback) == "function" then
            panelCallback(0, {}, {CanReRoll = false, ReRollPrice = 0}, 0, false, self.mapFateCard)
          end
          do return  end
        end
      end
    end
  end

    local msg = {EventType = 0 - nType, Number = nWave}
    local msgCallback = function(_, msgData)
    -- function num : 0_34_1 , upvalues : mapRewardCard, _ENV, SelectCallback, self
    mapRewardCard = msgData.ExtraCards
    ;
    (EventManager.Hit)("VampireSelectFateCard", 1, msgData.ChestCards, SelectCallback, {CanReRoll = false, ReRollPrice = 0}, 0, true, self.mapFateCard)
    for index,value in ipairs(msgData.ChestCards) do
      if self:AddFateCard(value.Id) then
        self:AddFateCardEft(value.Id)
        self:AddFateCardTheme(value.Id)
      end
    end
  end

    self.bHandleChest = true
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_reward_chest_req, msg, nil, msgCallback)
    ;
    (EventManager.Hit)("VampireSelectFateCard", 1, {}, SelectCallback, {CanReRoll = false, ReRollPrice = 0}, 0, true, self.mapFateCard)
  end
end

VampireSurvivorLevelData.RefreshCharDamageData = function(self)
  -- function num : 0_35 , upvalues : _ENV
  local tbCharDamage = (UTILS.GetCharDamageResult)(self.tbCharId)
  return tbCharDamage
end

VampireSurvivorLevelData.OnEvent_LevelResult = function(self, nState)
  -- function num : 0_36 , upvalues : _ENV
  if nState == 1 then
    local ConfirmCallback = function()
    -- function num : 0_36_0 , upvalues : _ENV, self
    (PanelManager.InputEnable)()
    self:ReTry()
  end

    local CancelCallback = function()
    -- function num : 0_36_1 , upvalues : self
    self:AbandonBattle()
  end

    local data = {nType = (AllEnum.MessageBox).Confirm, sContent = (ConfigTable.GetUIText)("Startower_ReBattleHint"), sContentSub = "", callbackConfirm = ConfirmCallback, callbackCancel = CancelCallback}
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, data)
  else
    do
      if self.bHalfBattle then
        self.tbCharDamageFirst = self:RefreshCharDamageData()
        self:BattleSuccess()
      else
        if self.isFirstHalf then
          self.tbCharDamageFirst = self:RefreshCharDamageData()
          self:ChangeArea()
        else
          self.tbCharDamageSecond = self:RefreshCharDamageData()
          self:BattleSuccess()
        end
      end
      ;
      (EventManager.Hit)("VampireBattleEnd")
      ;
      (PanelManager.InputDisable)()
    end
  end
end

VampireSurvivorLevelData.OnEvent_AddFateCard = function(self, nFateCardId)
  -- function num : 0_37
  if self:AddFateCard(nFateCardId) then
    self:AddFateCardEft(nFateCardId)
    self:AddFateCardTheme(nFateCardId)
  end
end

return VampireSurvivorLevelData

