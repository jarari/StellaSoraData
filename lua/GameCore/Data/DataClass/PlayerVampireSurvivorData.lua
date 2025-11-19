local PlayerVampireSurvivorData = class("PlayerVampireSurvivorData")
local mapDropId = {[(GameEnum.dropEntityType).HP] = 106, [(GameEnum.dropEntityType).MP] = 107, [(GameEnum.dropEntityType).ATK] = 108, [(GameEnum.dropEntityType).VampireClear] = 109, [(GameEnum.dropEntityType).VampireGet] = 110}
PlayerVampireSurvivorData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.tbPassedId = {}
  self.mapRecord = {}
  self.mapScore = {}
  self.mapRecordSeason = {}
  self.bInitTalent = false
  self.mapActiveTalent = {}
  self.nFateCardCount = 0
  self.nTalentPoints = 0
  self.nTalentResetTime = 0
  self.nSeasonScore = 0
  self.nCurSeasonId = 0
  self.nTalentPointMax = 0
  self.ObtainCount = 0
  self.bSuccessBattle = false
  local mapQuestGroup = {}
  local forEachTableLine = function(mapData)
    -- function num : 0_0_0 , upvalues : mapQuestGroup, _ENV
    if mapQuestGroup[mapData.GroupId] == nil then
      mapQuestGroup[mapData.GroupId] = {}
    end
    ;
    (table.insert)(mapQuestGroup[mapData.GroupId], mapData.Id)
  end

  ForEachTableLine(DataTable.VampireSurvivorQuest, forEachTableLine)
  local forEachTalent = function(mapData)
    -- function num : 0_0_1 , upvalues : self
    self.nTalentPointMax = self.nTalentPointMax + mapData.Point
  end

  ForEachTableLine(DataTable.VampireTalent, forEachTalent)
  for _,tbId in pairs(mapQuestGroup) do
    (table.sort)(tbId)
  end
  ;
  (CacheTable.Set)("_VampireQuestGroup", mapQuestGroup)
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

PlayerVampireSurvivorData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.tbPassedId = {}
  self.mapRecord = {}
  self.mapRecordSeason = {}
  ;
  (EventManager.Remove)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

PlayerVampireSurvivorData.EnterVampireSurvivor = function(self, nLevelId, nBuildId1, nBuildId2)
  -- function num : 0_2 , upvalues : _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_2_0 , upvalues : _ENV, self, nLevelId, nBuildId1, nBuildId2
    local luaClass = require("Game.Adventure.VampireSurvivor.VampireSurvivorLevelData")
    if luaClass == nil then
      return 
    end
    self.curLevel = luaClass
    if type((self.curLevel).BindEvent) == "function" then
      (self.curLevel):BindEvent()
    end
    if type((self.curLevel).Init) == "function" then
      (self.curLevel):Init(self, nLevelId, nBuildId1, nBuildId2, netMsg.Events, netMsg.Reward, netMsg.Select)
    end
  end

  local BuildIds = {nBuildId1}
  if nBuildId2 > 0 then
    (table.insert)(BuildIds, nBuildId2)
  end
  local msg = {Id = nLevelId, BuildIds = BuildIds}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_apply_req, msg, nil, NetCallback)
end

PlayerVampireSurvivorData.ReEnterVampireSurvivor = function(self, nVampireId)
  -- function num : 0_3 , upvalues : _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_3_0 , upvalues : _ENV, self, nVampireId
    local luaClass = require("Game.Adventure.VampireSurvivor.VampireSurvivorLevelData")
    if luaClass == nil then
      return 
    end
    self.curLevel = luaClass
    if type((self.curLevel).BindEvent) == "function" then
      (self.curLevel):BindEvent()
    end
    local nBuildId1 = 0
    local nBuildId2 = 0
    local mapSceneFirst = nil
    for _,mapScene in ipairs(netMsg.Scenes) do
      if mapScene.SceneType == 2 then
        nBuildId2 = mapScene.BuildId
      end
      if mapScene.SceneType == 1 then
        nBuildId1 = mapScene.BuildId
        mapSceneFirst = mapScene
      end
    end
    if mapSceneFirst == nil then
      return 
    end
    local GetAllBuildCallback = function(tbBuildData, mapAllBuild)
      -- function num : 0_3_0_0 , upvalues : nBuildId2, _ENV, nVampireId, self, netMsg, nBuildId1, mapSceneFirst
      if mapAllBuild[nBuildId2] == nil then
        local netMsgCallback = function(_, msgData)
        -- function num : 0_3_0_0_0 , upvalues : _ENV, nVampireId
        local mapVampireCfgData = (ConfigTable.GetData)("VampireSurvivor", nVampireId)
        if mapVampireCfgData ~= nil and mapVampireCfgData.Type == (GameEnum.vampireSurvivorType).Turn then
          (PlayerData.VampireSurvivor):AddPointAndLevel((msgData.Defeat).FinalScore, 0, (msgData.Defeat).SeasonId)
        end
        ;
        (PlayerData.VampireSurvivor):CacheScoreByLevel(nVampireId, (msgData.Defeat).FinalScore)
        ;
        (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("VampireReconnnect_Abandon"))
      end

        local msg = {
KillCount = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
, Time = 0, Defeat = true, 
Events = {
List = {}
}
}
        ;
        (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_settle_req, msg, nil, netMsgCallback)
        ;
        (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("VampireReConnect_BuildDeleted"))
      else
        do
          if type((self.curLevel).Init) == "function" then
            (self.curLevel):InitReEnter(self, netMsg.Id, nBuildId1, nBuildId2, netMsg.Events, netMsg.Reward, netMsg.FateCardIds, netMsg.ClientData, mapSceneFirst)
          end
        end
      end
    end

    ;
    (PlayerData.Build):GetAllBuildBriefData(GetAllBuildCallback)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_info_req, {}, nil, NetCallback)
end

PlayerVampireSurvivorData.EnterVampireEditor = function(self, floorId, tbChar, isFirstHalf, tbDisc, tbNote)
  -- function num : 0_4 , upvalues : _ENV
  local floorData = (ConfigTable.GetData)("VampireFloor", floorId)
  if floorData == nil then
    printError("吸血鬼floorData 为空,floor id === " .. floorId)
    return 
  end
  local luaClass = require("Game.Editor.VampireSurvivor.VampireSurvivorEditor")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, floorId, tbChar, isFirstHalf, tbDisc, tbNote)
  end
end

PlayerVampireSurvivorData.GetFloorBuff = function(self, floorId, isFirstHalf)
  -- function num : 0_5 , upvalues : _ENV
  local floorData = (ConfigTable.GetData)("VampireFloor", floorId)
  if isFirstHalf then
    return floorData.FHAffixId
  else
    return floorData.SHAffixId
  end
end

PlayerVampireSurvivorData.LevelEnd = function(self)
  -- function num : 0_6 , upvalues : _ENV
  if self.curLevel == nil then
    return 
  else
    if type((self.curLevel).UnBindEvent) == "function" then
      (self.curLevel):UnBindEvent()
    end
    self.curLevel = nil
  end
end

PlayerVampireSurvivorData.CacheLevelData = function(self, mapData)
  -- function num : 0_7 , upvalues : _ENV
  if mapData == nil then
    return 
  end
  self.tbPassedId = {}
  for _,mapRecord in ipairs(mapData.Records) do
    -- DECOMPILER ERROR at PC12: Confused about usage of register: R7 in 'UnsetPending'

    (self.mapRecord)[mapRecord.Id] = mapRecord.BuildIds
    -- DECOMPILER ERROR at PC16: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self.mapScore)[mapRecord.Id] = mapRecord.Score
    if mapRecord.Passed then
      (table.insert)(self.tbPassedId, mapRecord.Id)
    end
  end
  self.mapRecordSeason = mapData.Season
  self.nSeasonScore = mapData.SeasonScore
end

PlayerVampireSurvivorData.GetCachedBuildId = function(self, nLevelId)
  -- function num : 0_8 , upvalues : _ENV
  local mapVampireCfgData = (ConfigTable.GetData)("VampireSurvivor", nLevelId)
  local bSeason = false
  if mapVampireCfgData.Type ~= (GameEnum.vampireSurvivorType).Turn then
    bSeason = mapVampireCfgData == nil
    if bSeason then
      return (self.mapRecordSeason).BuildIds
    end
    if (self.mapRecord)[nLevelId] == nil then
      return nil
    else
      return (self.mapRecord)[nLevelId]
    end
    -- DECOMPILER ERROR: 5 unprocessed JMP targets
  end
end

PlayerVampireSurvivorData.CacheSelectedBuildId = function(self, nLevelId, nIdx, nBuildId)
  -- function num : 0_9 , upvalues : _ENV
  if nIdx == 0 then
    printError("索引为0！")
    return 
  end
  local mapVampireCfgData = (ConfigTable.GetData)("VampireSurvivor", nLevelId)
  local bSeason = false
  if mapVampireCfgData.Type ~= (GameEnum.vampireSurvivorType).Turn then
    bSeason = mapVampireCfgData == nil
    if bSeason then
      if self.mapRecordSeason == nil then
        self.mapRecordSeason = {}
      end
      -- DECOMPILER ERROR at PC35: Confused about usage of register: R6 in 'UnsetPending'

      if (self.mapRecordSeason).BuildIds == nil then
        (self.mapRecordSeason).BuildIds = {}
        -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

        ;
        ((self.mapRecordSeason).BuildIds)[nIdx] = nBuildId
        -- DECOMPILER ERROR at PC42: Confused about usage of register: R6 in 'UnsetPending'

        ;
        ((self.mapRecordSeason).BuildIds)[2 / nIdx] = 0
      else
        -- DECOMPILER ERROR at PC46: Confused about usage of register: R6 in 'UnsetPending'

        ((self.mapRecordSeason).BuildIds)[nIdx] = nBuildId
      end
      ;
      (EventManager.Hit)("VampireSurvivorChangeBuild")
      return 
    end
    -- DECOMPILER ERROR at PC58: Confused about usage of register: R6 in 'UnsetPending'

    if (self.mapRecord)[nLevelId] == nil then
      (self.mapRecord)[nLevelId] = {}
      -- DECOMPILER ERROR at PC61: Confused about usage of register: R6 in 'UnsetPending'

      ;
      ((self.mapRecord)[nLevelId])[nIdx] = nBuildId
      -- DECOMPILER ERROR at PC65: Confused about usage of register: R6 in 'UnsetPending'

      ;
      ((self.mapRecord)[nLevelId])[2 / nIdx] = 0
    else
      -- DECOMPILER ERROR at PC69: Confused about usage of register: R6 in 'UnsetPending'

      ((self.mapRecord)[nLevelId])[nIdx] = nBuildId
    end
    ;
    (EventManager.Hit)("VampireSurvivorChangeBuild")
    -- DECOMPILER ERROR: 8 unprocessed JMP targets
  end
end

PlayerVampireSurvivorData.ExchangeBuild = function(self, nLevelId)
  -- function num : 0_10 , upvalues : _ENV
  local mapVampireCfgData = (ConfigTable.GetData)("VampireSurvivor", nLevelId)
  local bSeason = false
  if mapVampireCfgData.Type ~= (GameEnum.vampireSurvivorType).Turn then
    bSeason = mapVampireCfgData == nil
    if bSeason then
      if self.mapRecordSeason == nil then
        self.mapRecordSeason = {}
      end
      -- DECOMPILER ERROR at PC32: Confused about usage of register: R4 in 'UnsetPending'

      if (self.mapRecordSeason).BuildIds == nil then
        (self.mapRecordSeason).BuildIds = {0, 0}
      else
        local temp = ((self.mapRecordSeason).BuildIds)[1]
        -- DECOMPILER ERROR at PC50: Confused about usage of register: R5 in 'UnsetPending'

        if ((self.mapRecordSeason).BuildIds)[2] ~= nil or not 0 then
          do
            ((self.mapRecordSeason).BuildIds)[1] = ((self.mapRecordSeason).BuildIds)[2]
            -- DECOMPILER ERROR at PC53: Confused about usage of register: R5 in 'UnsetPending'

            ;
            ((self.mapRecordSeason).BuildIds)[2] = temp
            -- DECOMPILER ERROR at PC64: Confused about usage of register: R4 in 'UnsetPending'

            if (self.mapRecord)[nLevelId] == nil then
              (self.mapRecord)[nLevelId] = {0, 0}
            else
              local temp = ((self.mapRecord)[nLevelId])[1]
              -- DECOMPILER ERROR at PC82: Confused about usage of register: R5 in 'UnsetPending'

              if ((self.mapRecord)[nLevelId])[2] ~= nil or not 0 then
                do
                  ((self.mapRecord)[nLevelId])[1] = ((self.mapRecord)[nLevelId])[2]
                  -- DECOMPILER ERROR at PC85: Confused about usage of register: R5 in 'UnsetPending'

                  ;
                  ((self.mapRecord)[nLevelId])[2] = temp
                  ;
                  (EventManager.Hit)("VampireSurvivorChangeBuild")
                  -- DECOMPILER ERROR: 11 unprocessed JMP targets
                end
              end
            end
          end
        end
      end
    end
  end
end

PlayerVampireSurvivorData.CheckLevelUnlock = function(self, nLevelId)
  -- function num : 0_11 , upvalues : _ENV
  local mapLevelData = (ConfigTable.GetData)("VampireSurvivor", nLevelId)
  if mapLevelData == nil then
    return true
  end
  local nNeedWorldClass = mapLevelData.NeedWorldClass
  local nCurWorldClass = (PlayerData.Base):GetWorldClass()
  if nCurWorldClass < nNeedWorldClass then
    return false, 1, nNeedWorldClass
  end
  local prev = mapLevelData.PreLevelId
  if prev > 0 and (table.indexof)(self.tbPassedId, prev) < 1 then
    local mapLevelDataPrev = (ConfigTable.GetData)("VampireSurvivor", prev)
    local sName = ""
    if mapLevelDataPrev ~= nil then
      sName = mapLevelDataPrev.Name
    end
    return false, 2, sName
  end
  do
    return true
  end
end

PlayerVampireSurvivorData.GetTalentData = function(self)
  -- function num : 0_12 , upvalues : _ENV
  local GetTalentCallback = function(_, mapData)
    -- function num : 0_12_0 , upvalues : self, _ENV
    self:CacheTalentData(mapData)
    self.bInitTalent = true
    ;
    (EventManager.Hit)("GetTalentDataVampire", true)
  end

  if self.bInitTalent then
    return self.mapActiveTalent, self.nTalentPoints, self.nTalentResetTime
  end
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_talent_detail_req, {}, nil, GetTalentCallback)
  return nil
end

PlayerVampireSurvivorData.GetActivedTalent = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local ret = {}
  if not self.bInitTalent then
    printError("TalentData not init!")
    return ret
  end
  for nTalentId,bActive in pairs(self.mapActiveTalent) do
    if bActive then
      (table.insert)(ret, nTalentId)
    end
  end
  return ret
end

PlayerVampireSurvivorData.ResetTalent = function(self, callback)
  -- function num : 0_14 , upvalues : _ENV
  local msgCallback = function(_, msgData)
    -- function num : 0_14_0 , upvalues : _ENV, self, callback
    local curTime = ((CS.ClientManager).Instance).serverTimeStamp
    self.nTalentResetTime = curTime + tonumber((ConfigTable.GetConfigValue)("VampireTalentResetTimeInterval"))
    self.mapActiveTalent = {}
    if callback ~= nil and type(callback) == "function" then
      callback()
    end
  end

  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  local tbActivedTalent = self:GetActivedTalent()
  if #tbActivedTalent == 0 then
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("VampireTalent_NoTalent"))
    return 
  end
  if self.nTalentResetTime < curTime then
    (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_talent_reset_req, {}, nil, msgCallback)
  else
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, orderedFormat((ConfigTable.GetUIText)("VampireTalent_ResetTime"), self.nTalentResetTime - curTime))
  end
end

PlayerVampireSurvivorData.ActiveTalent = function(self, nTalentId, callback)
  -- function num : 0_15 , upvalues : _ENV
  local msgCallback = function(_, msgData)
    -- function num : 0_15_0 , upvalues : self, nTalentId, _ENV, callback
    -- DECOMPILER ERROR at PC2: Confused about usage of register: R2 in 'UnsetPending'

    (self.mapActiveTalent)[nTalentId] = true
    self.nTalentPoints = self:CalTalentPoint(self.mapActiveTalent, self.nFateCardCount)
    ;
    (RedDotManager.SetValid)(RedDotDefine.VampireTalent, nil, self:CheckCanAciveTalent())
    if callback ~= nil and type(callback) == "function" then
      callback(nTalentId)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_talent_unlock_req, {Value = nTalentId}, nil, msgCallback)
end

PlayerVampireSurvivorData.GetActivedTalentEft = function(self)
  -- function num : 0_16 , upvalues : _ENV
  local tbActivedTalent = self:GetActivedTalent()
  local ret = {}
  for _,nTalentId in ipairs(tbActivedTalent) do
    local talentData = (ConfigTable.GetData)("VampireTalent", nTalentId)
    if talentData ~= nil and talentData.EffectId ~= 0 then
      (table.insert)(ret, talentData.EffectId)
    end
  end
  return ret
end

PlayerVampireSurvivorData.GetActivedDropItem = function(self)
  -- function num : 0_17 , upvalues : _ENV, mapDropId
  local tbActivedTalent = self:GetActivedTalent()
  local tbActived = {}
  local mapPropData = {}
  local ret = {}
  for _,nTalentId in ipairs(tbActivedTalent) do
    local talentData = (ConfigTable.GetData)("VampireTalent", nTalentId)
    if talentData ~= nil then
      if talentData.Effect == (GameEnum.vampireTalentEffect).ActiveDrop then
        local tbParam = decodeJson(talentData.Params)
        if tbParam ~= nil then
          if (table.indexof)(tbActived, tbParam[1]) < 1 then
            (table.insert)(tbActived, tbParam[1])
          end
          local nType = tonumber(tbParam[1])
          if nType ~= nil then
            if mapPropData[nType] == nil then
              mapPropData[nType] = {nProb = 0, nGrowth = 0, nMaxCount = 0}
            end
            local nParam1 = tonumber(tbParam[2])
            -- DECOMPILER ERROR at PC67: Confused about usage of register: R14 in 'UnsetPending'

            ;
            (mapPropData[nType]).nProb = (math.max)((mapPropData[nType]).nProb, nParam1 == nil and 0 or nParam1)
            local nParam2 = tonumber(tbParam[3])
            -- DECOMPILER ERROR at PC83: Confused about usage of register: R15 in 'UnsetPending'

            ;
            (mapPropData[nType]).nGrowth = (math.max)((mapPropData[nType]).nGrowth, nParam2 == nil and 0 or nParam2)
            local nParam3 = tonumber(tbParam[4])
            -- DECOMPILER ERROR at PC99: Confused about usage of register: R16 in 'UnsetPending'

            ;
            (mapPropData[nType]).nMaxCount = (math.max)((mapPropData[nType]).nMaxCount, nParam3 == nil and 0 or nParam3)
          end
        end
      else
        do
          if talentData.Effect == (GameEnum.vampireTalentEffect).DropItemPropUp then
            local tbParam = decodeJson(talentData.Params)
            if tbParam ~= nil then
              local nType = tonumber(tbParam[1])
              if nType ~= nil then
                if mapPropData[nType] == nil then
                  mapPropData[nType] = {nProb = 0, nGrowth = 0, nMaxCount = 0}
                end
                local nParam1 = tonumber(tbParam[2])
                -- DECOMPILER ERROR at PC140: Confused about usage of register: R14 in 'UnsetPending'

                ;
                (mapPropData[nType]).nProb = (math.max)((mapPropData[nType]).nProb, nParam1 == nil and 0 or nParam1)
                local nParam2 = tonumber(tbParam[3])
                -- DECOMPILER ERROR at PC156: Confused about usage of register: R15 in 'UnsetPending'

                ;
                (mapPropData[nType]).nGrowth = (math.max)((mapPropData[nType]).nGrowth, nParam2 == nil and 0 or nParam2)
                local nParam3 = tonumber(tbParam[4])
                -- DECOMPILER ERROR at PC172: Confused about usage of register: R16 in 'UnsetPending'

                ;
                (mapPropData[nType]).nMaxCount = (math.max)((mapPropData[nType]).nMaxCount, nParam3 == nil and 0 or nParam3)
              end
            end
          end
          do
            -- DECOMPILER ERROR at PC173: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC173: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC173: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC173: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC173: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
  for _,nType in ipairs(tbActived) do
    if mapDropId[nType] ~= nil then
      local stActorInfo = (CS.VampireDropData)(mapDropId[nType], 0, 0, 0)
      if mapPropData[nType] ~= nil then
        stActorInfo.DropProb = (mapPropData[nType]).nProb
        stActorInfo.GrowthProb = (mapPropData[nType]).nGrowth
        stActorInfo.DropMaxCount = (mapPropData[nType]).nMaxCount
      end
      ;
      (table.insert)(ret, stActorInfo)
    end
  end
  return ret
end

PlayerVampireSurvivorData.GetCurTalentPoint = function(self)
  -- function num : 0_18 , upvalues : _ENV
  if not self.bInitTalent then
    printError("TalentData not init!")
    return 0
  end
  return self.nTalentPoints
end

PlayerVampireSurvivorData.GetActiveExFateCard = function(self)
  -- function num : 0_19 , upvalues : _ENV
  local tbActivedTalent = self:GetActivedTalent()
  for _,nTalentId in ipairs(tbActivedTalent) do
    local talentData = (ConfigTable.GetData)("VampireTalent", nTalentId)
    if talentData ~= nil and talentData.Effect == (GameEnum.vampireTalentEffect).UnlockspecialFateCard then
      return true
    end
  end
  return false
end

PlayerVampireSurvivorData.GetCurScore = function(self)
  -- function num : 0_20
  return self.nSeasonScore
end

PlayerVampireSurvivorData.GetScoreByLevel = function(self, nLevelId)
  -- function num : 0_21
  if (self.mapScore)[nLevelId] ~= nil or not 0 then
    return (self.mapScore)[nLevelId]
  end
end

PlayerVampireSurvivorData.CacheScoreByLevel = function(self, nLevelId, nScore)
  -- function num : 0_22
  if (self.mapScore)[nLevelId] ~= nil and nScore <= (self.mapScore)[nLevelId] then
    return 
  end
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.mapScore)[nLevelId] = nScore
end

PlayerVampireSurvivorData.CacheTalentData = function(self, mapData)
  -- function num : 0_23 , upvalues : _ENV
  local tbNodes = (UTILS.ParseByteString)(mapData.Nodes)
  local forEachTalent = function(mapData)
    -- function num : 0_23_0 , upvalues : _ENV, tbNodes, self
    local bActive = (UTILS.IsBitSet)(tbNodes, mapData.Id)
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.mapActiveTalent)[mapData.Id] = bActive
  end

  ForEachTableLine(DataTable.VampireTalent, forEachTalent)
  self.nTalentResetTime = mapData.ResetTime
  self.nFateCardCount = mapData.ActiveCount
  self.nTalentPoints = self:CalTalentPoint(self.mapActiveTalent, self.nFateCardCount)
  self.ObtainCount = mapData.ObtainCount
  self.nActiveExp = self.nTalentPoints - self:CalTalentPoint(self.mapActiveTalent, self.nFateCardCount - self.ObtainCount)
  ;
  (RedDotManager.SetValid)(RedDotDefine.VampireTalent, nil, self:CheckCanAciveTalent())
end

PlayerVampireSurvivorData.GetIsTalentPointMax = function(self)
  -- function num : 0_24 , upvalues : _ENV
  local nFateCardPoint = (ConfigTable.GetConfigNumber)("FateCardBookToVampireTalentPoint")
  if nFateCardPoint == nil then
    nFateCardPoint = 1
  end
  local nCurCount = self.nFateCardCount * nFateCardPoint
  do return self.nTalentPointMax <= nCurCount end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerVampireSurvivorData.CheckOpenHint = function(self)
  -- function num : 0_25 , upvalues : _ENV
  if self.nActiveExp > 0 then
    (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_talent_show_req, {}, nil, nil)
    local ret1 = self.ObtainCount
    local ret2 = self.nActiveExp
    self.ObtainCount = 0
    self.nActiveExp = 0
    return true, ret1, ret2
  end
  do
    return false, 0, 0
  end
end

PlayerVampireSurvivorData.ResetTalentPoint = function(self)
  -- function num : 0_26 , upvalues : _ENV
  local nFateCardPoint = (ConfigTable.GetConfigNumber)("FateCardBookToVampireTalentPoint")
  if nFateCardPoint == nil then
    nFateCardPoint = 1
  end
  self.nTalentPoints = (math.min)(self.nTalentPointMax, nFateCardPoint * self.nFateCardCount)
  ;
  (RedDotManager.SetValid)(RedDotDefine.VampireTalent, nil, self:CheckCanAciveTalent())
end

PlayerVampireSurvivorData.AddTalentPoint = function(self, tbFateCard)
  -- function num : 0_27 , upvalues : _ENV
  if tbFateCard ~= nil then
    self.nFateCardCount = self.nFateCardCount + #tbFateCard
  end
  self.ObtainCount = self.ObtainCount + #tbFateCard
  self.nActiveExp = (math.max)(0, self:CalTalentPoint(self.mapActiveTalent, self.nFateCardCount) - self.nTalentPoints)
  self.nTalentPoints = self:CalTalentPoint(self.mapActiveTalent, self.nFateCardCount)
  ;
  (RedDotManager.SetValid)(RedDotDefine.VampireTalent, nil, self:CheckCanAciveTalent())
end

PlayerVampireSurvivorData.GetRefreshTiem = function(self)
  -- function num : 0_28 , upvalues : _ENV
  local nSeasonId = self:GetCurSeason()
  if nSeasonId == 0 then
    return ""
  end
  local mapSeasonCfgData = (ConfigTable.GetData)("VampireRankSeason", nSeasonId)
  if mapSeasonCfgData == nil then
    return ""
  end
  local nEndTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(mapSeasonCfgData.EndTime)
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  local remainTime = nEndTime - curTime
  if remainTime < 0 then
    return ""
  end
  local sTimeStr = ""
  local remainTime = nEndTime - curTime
  if remainTime >= 86400 then
    local day = (math.floor)(remainTime / 86400)
    local hour = (math.floor)((remainTime - day * 86400) / 3600)
    if hour == 0 then
      day = day - 1
      hour = 24
    end
    sTimeStr = orderedFormat((ConfigTable.GetUIText)("Energy_LeftTime_Day"), day, hour)
  else
    do
      if remainTime >= 3600 then
        local hour = (math.floor)(remainTime / 3600)
        local min = (math.floor)((remainTime - hour * 3600) / 60)
        if min == 0 then
          hour = hour - 1
          min = 60
        end
        sTimeStr = orderedFormat((ConfigTable.GetUIText)("Energy_LeftTime_Hour"), hour, min)
      else
        do
          sTimeStr = (ConfigTable.GetUIText)("Energy_LeftTime_LessThenHour")
          return sTimeStr
        end
      end
    end
  end
end

PlayerVampireSurvivorData.GetCurSeason = function(self)
  -- function num : 0_29 , upvalues : _ENV
  local ret = 0
  local nLevel = 0
  local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
  local foreachVampireSeason = function(mapData)
    -- function num : 0_29_0 , upvalues : _ENV, nCurTime, ret, nLevel
    local starttime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(mapData.OpenTime)
    local endtime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(mapData.EndTime)
    if starttime < nCurTime and nCurTime < endtime then
      ret = mapData.Id
      nLevel = mapData.MissionId
    end
  end

  ForEachTableLine(DataTable.VampireRankSeason, foreachVampireSeason)
  return ret, nLevel
end

PlayerVampireSurvivorData.AddPointAndLevel = function(self, nPoint, nLevelId, nSeasonId)
  -- function num : 0_30 , upvalues : _ENV
  if nLevelId ~= 0 and (table.indexof)(self.tbPassedId) < 1 then
    (table.insert)(self.tbPassedId, nLevelId)
  end
  if nSeasonId ~= nil and nSeasonId ~= self:GetCurSeason() then
    return 
  end
  self.nSeasonScore = self.nSeasonScore + nPoint
end

PlayerVampireSurvivorData.CheckCanAciveTalent = function(self)
  -- function num : 0_31 , upvalues : _ENV
  local checkPrecAcitve = function(tbPrev)
    -- function num : 0_31_0 , upvalues : _ENV, self
    if tbPrev == nil or #tbPrev == 0 then
      return true
    end
    for _,nId in ipairs(tbPrev) do
      if (self.mapActiveTalent)[nId] ~= true then
        return false
      end
    end
    return true
  end

  local ret = false
  local foreachTalent = function(mapData)
    -- function num : 0_31_1 , upvalues : self, checkPrecAcitve, ret
    if (self.mapActiveTalent)[mapData.Id] == true then
      return 
    end
    local tbPrev = mapData.Prev
    if checkPrecAcitve(tbPrev) and mapData.Point <= self.nTalentPoints then
      ret = true
    end
  end

  ForEachTableLine(DataTable.VampireTalent, foreachTalent)
  return ret
end

PlayerVampireSurvivorData.CalTalentPoint = function(self, mapActiveTalent, nCards)
  -- function num : 0_32 , upvalues : _ENV
  local nActivedPoint = 0
  local nFateCardPoint = (ConfigTable.GetConfigNumber)("FateCardBookToVampireTalentPoint")
  if nFateCardPoint == nil then
    nFateCardPoint = 1
  end
  for nTalentId,bActive in pairs(mapActiveTalent) do
    if bActive then
      local mapTalentCfg = (ConfigTable.GetData)("VampireTalent", nTalentId)
      if mapTalentCfg ~= nil then
        nActivedPoint = nActivedPoint + mapTalentCfg.Point
      end
    end
  end
  local totalPoint = (math.min)(self.nTalentPointMax, nFateCardPoint * nCards)
  return totalPoint - (nActivedPoint)
end

PlayerVampireSurvivorData.OnNotifyRefresh = function(self, nSeasonId)
  -- function num : 0_33 , upvalues : _ENV
  self.mapRecordSeason = {Id = nSeasonId, Score = 0, 
BuildIds = {}
, Passed = false}
  self.nSeasonScore = 0
  ;
  (PlayerData.Quest):ClearVampireSeasonQuest(nSeasonId)
  ;
  (EventManager.Hit)("VampireSeasonRefresh")
end

PlayerVampireSurvivorData.SetBattleSuccess = function(self)
  -- function num : 0_34
  self.bSuccessBattle = true
end

PlayerVampireSurvivorData.CheckBattleSuccess = function(self)
  -- function num : 0_35
  if self.bSuccessBattle == true then
    self.bSuccessBattle = false
    return true
  end
  return false
end

PlayerVampireSurvivorData.IsActiveTalent = function(self, nId)
  -- function num : 0_36 , upvalues : _ENV
  local mapTalentData = (ConfigTable.GetData)("VampireTalent", nId)
  if mapTalentData == nil then
    return 3
  end
  if (self.mapActiveTalent)[nId] then
    return 1
  else
    local tbPrev = mapTalentData.Prev
    if tbPrev == nil or #tbPrev == 0 then
      return 2
    end
    for _,nPrevId in ipairs(tbPrev) do
      if (self.mapActiveTalent)[nPrevId] then
        return 2
      end
    end
    return 3
  end
end

PlayerVampireSurvivorData.GetHardUnlock = function(self)
  -- function num : 0_37 , upvalues : _ENV
  local ret = {false, false, false}
  local forEachVampire = function(mapData)
    -- function num : 0_37_0 , upvalues : self, _ENV, ret
    if self:CheckLevelUnlock(mapData.Id) then
      if mapData.Type == (GameEnum.vampireSurvivorType).Normal then
        ret[1] = true
      else
        if mapData.Type == (GameEnum.vampireSurvivorType).Hard then
          ret[2] = true
        end
      end
    end
  end

  ForEachTableLine(DataTable.VampireSurvivor, forEachVampire)
  local nCurSeasonId, nLevelId = self:GetCurSeason()
  if nCurSeasonId ~= 0 then
    ret[3] = self:CheckLevelUnlock(nLevelId)
  end
  return ret
end

PlayerVampireSurvivorData.GetSeasonQuestCount = function(self, nHard)
  -- function num : 0_38 , upvalues : _ENV
  local tbScore, tbPass = (PlayerData.Quest):GetVampireQuestData()
  local cur, total = 0, 0
  for _,mapPassData in ipairs(tbPass) do
    local mapCfg = (ConfigTable.GetData)("VampireSurvivorQuest", mapPassData.nTid)
    if mapCfg ~= nil and mapCfg.Type == nHard then
      total = total + 1
      if mapPassData.nStatus == 2 then
        cur = cur + 1
      end
    end
  end
  for _,mapPassData in ipairs(tbScore) do
    local mapCfg = (ConfigTable.GetData)("VampireSurvivorQuest", mapPassData.nTid)
    if mapCfg ~= nil and mapCfg.Type == nHard then
      total = total + 1
      if mapPassData.nStatus == 2 then
        cur = cur + 1
      end
    end
  end
  return cur, total
end

PlayerVampireSurvivorData.CacheScore = function(self, nScore)
  -- function num : 0_39
  self.nSeasonScore = nScore
end

PlayerVampireSurvivorData.CachePassedId = function(self, tbIds)
  -- function num : 0_40
  self.tbPassedId = tbIds
end

return PlayerVampireSurvivorData

