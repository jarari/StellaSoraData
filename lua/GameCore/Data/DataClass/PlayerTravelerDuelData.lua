local PlayerTravelerDuelData = class("PlayerTravelerDuelData")
PlayerTravelerDuelData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.rankingRefreshTime = 610
  self.bClassChange = false
  self.oldLevel = 0
  self.oldExp = 0
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  self.bHasData = false
  self.curLevel = nil
  self.nDuelLevel = 0
  self.selBuildId = 0
  self.nDuelExp = 0
  self.mapBossLevel = {}
  self.RankingData = {}
  self.SelfRankingData = {}
  self.LastRankingRefreshTime = 0
  self.UploadRemainTimes = 0
  self.mapCurChallenge = {bLock = false, nIdx = 0, nOpenTime = 0, nCloseTime = 0}
end

PlayerTravelerDuelData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

PlayerTravelerDuelData.CacheTravelerDuelData = function(self, mapDuelData)
  -- function num : 0_2 , upvalues : _ENV
  self.nDuelLevel = mapDuelData.DuelLevel
  self.nDuelExp = mapDuelData.DuelExp
  self.WeeklyAwardTimes = mapDuelData.WeeklyAwardTimes
  self:CacheTravelerDuelLevelData(mapDuelData)
  -- DECOMPILER ERROR at PC12: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (self.mapCurChallenge).bUnlock = (mapDuelData.Challenge).Unlock
  if (mapDuelData.Challenge).Id == 0 then
    printError("season idx == 0")
  else
    -- DECOMPILER ERROR at PC24: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.mapCurChallenge).nIdx = (mapDuelData.Challenge).Id
  end
  -- DECOMPILER ERROR at PC28: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (self.mapCurChallenge).nOpenTime = (mapDuelData.Challenge).OpenTime
  -- DECOMPILER ERROR at PC32: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (self.mapCurChallenge).nCloseTime = (mapDuelData.Challenge).CloseTime
  ;
  (PlayerData.Quest):CacheAllQuest((mapDuelData.Quests).List)
end

PlayerTravelerDuelData.CacheTravelerDuelLevelData = function(self, mapDuelData)
  -- function num : 0_3 , upvalues : _ENV
  for _,mapBossLevel in ipairs(mapDuelData.Levels) do
    -- DECOMPILER ERROR at PC13: Confused about usage of register: R7 in 'UnsetPending'

    (self.mapBossLevel)[mapBossLevel.Id] = {nStar = mapBossLevel.Star, nLastBuildId = mapBossLevel.BuildId, nMaxDifficulty = mapBossLevel.Difficulty}
  end
end

PlayerTravelerDuelData.CacheTravelerDuelRankingData = function(self, mapDuelData)
  -- function num : 0_4 , upvalues : _ENV
  self.SelfRankingData = mapDuelData.Self
  self.RankingData = mapDuelData.Rank
  self.LastRankingRefreshTime = mapDuelData.LastRefreshTime
  self.UploadRemainTimes = mapDuelData.UploadRemainTimes
  -- DECOMPILER ERROR at PC16: Confused about usage of register: R2 in 'UnsetPending'

  if self.SelfRankingData ~= nil then
    (self.SelfRankingData).nRewardIdx = self:GetRewardIdx((self.SelfRankingData).Rank)
  end
  local nSelfuid = (PlayerData.Base):GetPlayerId()
  for _,mapRankingData in ipairs(self.RankingData) do
    mapRankingData.nRewardIdx = self:GetRewardIdx(mapRankingData.Rank)
    mapRankingData.bSelf = nSelfuid == mapRankingData.Id
    mapRankingData.nBuildRank = self:GetBuildRank(mapRankingData.BuildScore)
    if mapRankingData.TitlePrefix == 0 then
      mapRankingData.TitlePrefix = 1
    end
    if mapRankingData.TitleSuffix == 0 then
      mapRankingData.TitleSuffix = 2
    end
  end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

PlayerTravelerDuelData.GetTDRankingData = function(self)
  -- function num : 0_5
  return self.SelfRankingData, self.RankingData, self.LastRankingRefreshTime, self.UploadRemainTimes
end

PlayerTravelerDuelData.GetTravelerDuelLevel = function(self)
  -- function num : 0_6
  return self.nDuelLevel, self.nDuelExp
end

PlayerTravelerDuelData.GetTravelerDuelChallenge = function(self)
  -- function num : 0_7
  return self.mapCurChallenge
end

PlayerTravelerDuelData.GetCachedBuildId = function(self, nLevelId)
  -- function num : 0_8
  do
    if self.selBuildId ~= 0 and self.selBuildId ~= nil then
      local ret = self.selBuildId
      return ret
    end
    if (self.mapBossLevel)[nLevelId] ~= nil then
      return ((self.mapBossLevel)[nLevelId]).nLastBuildId
    end
    return 0
  end
end

PlayerTravelerDuelData.SetCacheAffixids = function(self, tbAffixes, nBossId)
  -- function num : 0_9
  if tbAffixes ~= nil then
    self.CachedAffixes = tbAffixes
    self.curCachedAffixesBoss = nBossId
  end
  self.CachedBossId = nBossId
end

PlayerTravelerDuelData.GetCacheAffixids = function(self)
  -- function num : 0_10
  return self.CachedAffixes, self.CachedBossId
end

PlayerTravelerDuelData.SetSelBuildId = function(self, nBuildId)
  -- function num : 0_11
  self.selBuildId = nBuildId
end

PlayerTravelerDuelData.EnterTravelerDuel = function(self, nLevel, nBuildId, tbAffixes)
  -- function num : 0_12 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Adventure.TravelerDuelLevel.TravelerDuelLevelData")
  if luaClass == nil then
    return 
  end
  self.entryLevelId = nLevel
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, nLevel, tbAffixes, nBuildId)
  end
end

PlayerTravelerDuelData.EnterTravelerDuelEditor = function(self, nLevel, tbChar, tbAffixes, tbDisc, tbNote)
  -- function num : 0_13 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Adventure.TravelerDuelLevel.TravelerDuelLevelEditorData")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, nLevel, tbAffixes, tbChar, tbDisc, tbNote)
  end
end

PlayerTravelerDuelData.LevelEnd = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
end

PlayerTravelerDuelData.SendMsg_EnterTravelerDuel = function(self, nLevelId, nBuildId, tbAffixes)
  -- function num : 0_15 , upvalues : _ENV
  local msgData = {Id = nLevelId, BuildId = nBuildId, AffixIds = tbAffixes}
  local Callback = function()
    -- function num : 0_15_0 , upvalues : self, nLevelId, nBuildId, tbAffixes
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R0 in 'UnsetPending'

    if (self.mapBossLevel)[nLevelId] == nil then
      (self.mapBossLevel)[nLevelId] = {nStar = 0, nLastBuildId = 0, nMaxDifficulty = 0}
    end
    -- DECOMPILER ERROR at PC16: Confused about usage of register: R0 in 'UnsetPending'

    ;
    ((self.mapBossLevel)[nLevelId]).nLastBuildId = nBuildId
    self:EnterTravelerDuel(nLevelId, nBuildId, tbAffixes)
  end

  self.LevelId = nLevelId
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).traveler_duel_level_apply_req, msgData, nil, Callback)
end

PlayerTravelerDuelData.SendMsg_UplodeTravelerDuelRanking = function(self, tbChar, Score, callback)
  -- function num : 0_16 , upvalues : _ENV
  local oldScore = 0
  local oldRank = 0
  if self.SelfRankingData ~= nil then
    oldScore = (self.SelfRankingData).Score
  end
  local LocalData = require("GameCore.Data.LocalData")
  local sKey = (LocalData.GetPlayerLocalData)("TravelerDuelRecordKey")
  local bSuccess, nCheckSum = (NovaAPI.GetRecorderKey)(sKey)
  local msgCallback = function(_, mapValue)
    -- function num : 0_16_0 , upvalues : self, tbChar, Score, oldRank, _ENV, oldScore, callback, bSuccess, sKey, LocalData
    if self.SelfRankingData == nil then
      self.SelfRankingData = {}
    end
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.SelfRankingData).Chars = tbChar
    -- DECOMPILER ERROR at PC10: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.SelfRankingData).Score = Score
    -- DECOMPILER ERROR at PC13: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.SelfRankingData).Rank = mapValue.New
    oldRank = mapValue.Old
    self.UploadRemainTimes = self.UploadRemainTimes - 1
    local curIdx = -1
    local minLower = -1
    local forEachReward = function(mapData)
      -- function num : 0_16_0_0 , upvalues : self, minLower, curIdx
      if (self.SelfRankingData).Rank <= mapData.RankUpper and (mapData.RankUpper < minLower or minLower < 0) then
        curIdx = mapData.Id
        minLower = mapData.RankUpper
      end
    end

    ForEachTableLine(DataTable.TravelerDuelChallengeRankReward, forEachReward)
    if curIdx < 0 then
      curIdx = 4
    end
    -- DECOMPILER ERROR at PC31: Confused about usage of register: R5 in 'UnsetPending'

    ;
    (self.SelfRankingData).nRewardIdx = curIdx
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.TravelerDuelRankUploadSuccess, oldScore, Score, oldRank, (self.SelfRankingData).Rank, curIdx)
    if callback ~= nil and type(callback) == "function" then
      callback()
    end
    if bSuccess and mapValue.Token ~= nil and mapValue.Token ~= "" and sKey ~= nil and sKey ~= "" then
      (NovaAPI.UploadStartowerFile)(mapValue.Token, sKey)
      ;
      (LocalData.SetPlayerLocalData)("TravelerDuelRecordKey", "")
    else
      ;
      (NovaAPI.DeleteRecFile)(sKey)
    end
  end

  local tbSamples = (UTILS.GetBattleSamples)()
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).traveler_duel_rank_upload_req, {Sample = tbSamples, Checksum = nCheckSum}, nil, msgCallback)
end

PlayerTravelerDuelData.SendMsg_TravelerDuelSettle = function(self, nStar, nLevelId, nTime, callback)
  -- function num : 0_17 , upvalues : _ENV
  local Events = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).TravelerDuel, nStar > 0)
  local msgData = {Star = nStar, Time = nTime, 
Events = {List = Events}
}
  local Callback = function(_, netMsgData)
    -- function num : 0_17_0 , upvalues : _ENV, nLevelId, nStar, self, callback
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(netMsgData.Change)
    local nBossId = ((ConfigTable.GetData)("TravelerDuelBossLevel", nLevelId)).BossId
    if nStar > 0 then
      if self.nDuelLevel ~= netMsgData.DuelLevel then
        self.bClassChange = true
        self.oldLevel = self.nDuelLevel
        self.oldExp = self.nDuelExp
      end
      self.nDuelLevel = netMsgData.DuelLevel
      self.nDuelExp = netMsgData.DuelExp
      -- DECOMPILER ERROR at PC38: Confused about usage of register: R4 in 'UnsetPending'

      if (self.mapBossLevel)[nLevelId] == nil then
        (self.mapBossLevel)[nLevelId] = {nStar = nStar, nLastBuildId = 0, nMaxDifficulty = 0}
      else
        if ((self.mapBossLevel)[nLevelId]).nStar > 0 then
          self.WeeklyAwardTimes = self.WeeklyAwardTimes + 1
        end
        -- DECOMPILER ERROR at PC60: Confused about usage of register: R4 in 'UnsetPending'

        if ((self.mapBossLevel)[nLevelId]).nStar < nStar then
          ((self.mapBossLevel)[nLevelId]).nStar = nStar
        end
      end
    end
    if netMsgData.Affinities ~= nil then
      for k,v in pairs(netMsgData.Affinities) do
        (PlayerData.Char):ChangeCharAffinityValue(v)
      end
    end
    do
      ;
      (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
      if callback ~= nil then
        callback(netMsgData)
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).traveler_duel_level_settle_req, msgData, nil, Callback)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerTravelerDuelData.SendMsg_GetTravelerDuelRanking = function(self, callback)
  -- function num : 0_18 , upvalues : _ENV
  local msgCallback = function()
    -- function num : 0_18_0 , upvalues : callback, _ENV
    if callback ~= nil and type(callback) == "function" then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).traveler_duel_rank_req, {}, nil, msgCallback)
end

PlayerTravelerDuelData.OnEvent_NewDay = function(self)
  -- function num : 0_19
  self.bHasData = false
end

PlayerTravelerDuelData.GetTravelerDuelData = function(self, callback)
  -- function num : 0_20 , upvalues : _ENV
  if self.bHasData and callback ~= nil then
    callback()
    return 
  end
  local Callback = function(_, netMsgData)
    -- function num : 0_20_0 , upvalues : self, _ENV, callback
    self:CacheTravelerDuelData(netMsgData)
    local nCurChallengeBossId = 0
    local mapSeasonCfg = (ConfigTable.GetData)("TravelerDuelChallengeSeason", (self.mapCurChallenge).nIdx)
    if mapSeasonCfg ~= nil then
      nCurChallengeBossId = mapSeasonCfg.BossId
    end
    if nCurChallengeBossId ~= self.curCachedAffixesBoss then
      self.CachedBossId = nil
      self.CachedAffixes = nil
      self.curCachedAffixesBoss = nil
    end
    self.bHasData = true
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).traveler_duel_info_req, {}, nil, Callback)
end

PlayerTravelerDuelData.GetTravelerDuelLevelUnlock = function(self, nLevelId)
  -- function num : 0_21 , upvalues : _ENV
  if nLevelId == 0 then
    return false, 0
  end
  local mapBossLevel = (ConfigTable.GetData)("TravelerDuelBossLevel", nLevelId)
  if mapBossLevel == nil then
    return false, (ConfigTable.GetUIText)("RegusBoss_Unlock_Rank")
  end
  if (self.mapBossLevel)[mapBossLevel.PreLevelId] == nil or ((self.mapBossLevel)[mapBossLevel.PreLevelId]).nStar <= 0 then
    do
      local bPreLevelId = mapBossLevel.PreLevelId == 0
      if not bPreLevelId then
        return false, (ConfigTable.GetUIText)("RegusBoss_Unlock_Rank")
      end
      if mapBossLevel.UnlockWorldClass ~= 0 then
        local nCurWorldClass = (PlayerData.Base):GetWorldClass()
        local bUnlockWorldClass = mapBossLevel.UnlockWorldClass <= nCurWorldClass
        if not bUnlockWorldClass then
          return false, orderedFormat((ConfigTable.GetUIText)("TravelerDuel_Unlock_WorldClass"), mapBossLevel.UnlockWorldClass)
        end
      end
      if mapBossLevel.UnlockDuelLevel ~= 0 then
        local nDuelLevel = self.nDuelLevel
        local bDuelLevel = mapBossLevel.UnlockDuelLevel <= nDuelLevel
        if not bDuelLevel then
          return false, orderedFormat((ConfigTable.GetUIText)("TravelerDuel_Unlock_DuelRank"), mapBossLevel.UnlockDuelLevel)
        end
      end
      do return true, 0 end
      -- DECOMPILER ERROR: 6 unprocessed JMP targets
    end
  end
end

PlayerTravelerDuelData.GetTravelerDuelLevelRewardCount = function(self, nBossId)
  -- function num : 0_22
  if self.WeeklyAwardTimes == nil then
    return 0
  end
  return self.WeeklyAwardTimes
end

PlayerTravelerDuelData.GetTravelerDuelLevelStar = function(self, nLevelId)
  -- function num : 0_23
  if (self.mapBossLevel)[nLevelId] == nil then
    return 0
  else
    return ((self.mapBossLevel)[nLevelId]).nStar
  end
end

PlayerTravelerDuelData.GetTravelerDuelAffixUnlock = function(self, nAffixId)
  -- function num : 0_24 , upvalues : _ENV
  local mapAffixCfgData = (ConfigTable.GetData)("TravelerDuelChallengeAffix", nAffixId)
  if mapAffixCfgData.UnlockWorldClass > 0 or mapAffixCfgData.UnlockDuelLevel > 0 or mapAffixCfgData.UnlockDifficulty > 0 then
    local nWorldClass = (PlayerData.Base):GetWorldClass()
    if nWorldClass < mapAffixCfgData.UnlockWorldClass then
      return false, 1, mapAffixCfgData.UnlockWorldClass
    else
      if self.nDuelLevel < mapAffixCfgData.UnlockDuelLevel then
        return false, 2, mapAffixCfgData.UnlockDuelLevel
      else
        return false, 3, mapAffixCfgData.UnlockDifficulty
      end
    end
  else
    do
      do return true, 0, 0 end
    end
  end
end

PlayerTravelerDuelData.GetTravelerChallengeUnlock = function(self)
  -- function num : 0_25 , upvalues : _ENV
  local nNeedWorldLevel = 0
  local nNeedDuelLevel = 0
  local mapOpenFunc = (ConfigTable.GetData)("OpenFunc", (GameEnum.OpenFuncType).TravelerDuelChallenge)
  if mapOpenFunc ~= nil then
    nNeedWorldLevel = mapOpenFunc.NeedWorldClass
    nNeedDuelLevel = 0
  end
  local nDuelLevel = self.nDuelLevel
  local nWorldClass = (PlayerData.Base):GetWorldClass()
  local sDesc = ""
  if nWorldClass < nNeedWorldLevel then
    sDesc = orderedFormat((ConfigTable.GetUIText)("TD_Lock_WorldClass"), nNeedWorldLevel)
  else
    if nDuelLevel < nNeedDuelLevel then
      sDesc = orderedFormat((ConfigTable.GetUIText)("TD_Lock_DuelLevel"), nNeedDuelLevel)
    end
  end
  do return nNeedWorldLevel <= nWorldClass and nNeedDuelLevel <= nDuelLevel, sDesc end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerTravelerDuelData.GetCurLevel = function(self)
  -- function num : 0_26
  if self.curLevel == nil then
    return 0
  end
  return (self.curLevel).nlevelId
end

PlayerTravelerDuelData.TryOpenTDUpgradePanel = function(self, callback)
  -- function num : 0_27 , upvalues : _ENV
  if self.bClassChange then
    (EventManager.Hit)(EventId.OpenPanel, PanelId.TDLevelUpgrade, callback)
    self.bClassChange = false
  end
end

PlayerTravelerDuelData.GetOldTDLevelData = function(self)
  -- function num : 0_28
  return self.oldLevel, self.oldExp
end

PlayerTravelerDuelData.GetBuildRank = function(self, nScore)
  -- function num : 0_29
  local curIdx = -1
  local minLower = -1
  if curIdx < 0 then
    curIdx = 1
  end
  return curIdx
end

PlayerTravelerDuelData.GetRewardIdx = function(self, nScore)
  -- function num : 0_30 , upvalues : _ENV
  local curIdx = -1
  local minLower = -1
  local forEachReward = function(mapData)
    -- function num : 0_30_0 , upvalues : nScore, minLower, curIdx
    if nScore < mapData.RankUpper and (mapData.RankUpper < minLower or minLower < 0) then
      curIdx = mapData.Id - 1
      minLower = mapData.RankUpper
    end
  end

  ForEachTableLine(DataTable.TravelerDuelChallengeRankReward, forEachReward)
  if curIdx < 0 then
    curIdx = 4
  end
  return curIdx
end

return PlayerTravelerDuelData

