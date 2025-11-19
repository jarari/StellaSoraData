local StarTowerBookData = class("StarTowerBookData")
local MAPSTATUS = {[0] = (AllEnum.BookQuestStatus).UnComplete, [1] = (AllEnum.BookQuestStatus).Complete, [2] = (AllEnum.BookQuestStatus).Received}
StarTowerBookData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV, StarTowerBookData
  self.mapPotentialBookBrief = {}
  self.mapPotentialBook = {}
  self.mapFateCardBook = {}
  self.mapPotentialQuest = {}
  self.mapFateCardQuest = {}
  self.mapEntranceCfg = {}
  self.bFateCardInit = false
  self.bEventInit = false
  ;
  (EventManager.Add)(EventId.UpdateWorldClass, StarTowerBookData, self.OnEvent_UpdateWorldClass)
  ;
  (EventManager.Add)(EventId.StarTowerPass, StarTowerBookData, self.OnEvent_StarTowerPass)
  self:InitConfig()
end

StarTowerBookData.InitConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local foreachEntranceTableLine = function(line)
    -- function num : 0_1_0 , upvalues : _ENV, self
    (table.insert)(self.mapEntranceCfg, line)
  end

  ForEachTableLine((ConfigTable.Get)("StarTowerBookEntrance"), foreachEntranceTableLine)
  local foreachPotentialTableLine = function(line)
    -- function num : 0_1_1 , upvalues : _ENV, self
    local nCharId = line.Id
    local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
    if mapCharCfg ~= nil and mapCharCfg.Available then
      local nAllCount = 0
      do
        -- DECOMPILER ERROR at PC13: Confused about usage of register: R4 in 'UnsetPending'

        (self.mapPotentialBook)[nCharId] = {}
        -- DECOMPILER ERROR at PC16: Confused about usage of register: R4 in 'UnsetPending'

        ;
        ((self.mapPotentialBook)[nCharId]).Init = false
        -- DECOMPILER ERROR at PC20: Confused about usage of register: R4 in 'UnsetPending'

        ;
        ((self.mapPotentialBook)[nCharId]).PotentialList = {}
        -- DECOMPILER ERROR at PC23: Confused about usage of register: R4 in 'UnsetPending'

        ;
        (self.mapPotentialBookBrief)[nCharId] = {}
        local addPotentialList = function(tbList)
      -- function num : 0_1_1_0 , upvalues : _ENV, nAllCount
      for _,v in pairs(tbList) do
        nAllCount = nAllCount + 1
      end
    end

        addPotentialList(line.MasterSpecificPotentialIds)
        addPotentialList(line.MasterNormalPotentialIds)
        addPotentialList(line.AssistSpecificPotentialIds)
        addPotentialList(line.AssistNormalPotentialIds)
        addPotentialList(line.CommonPotentialIds)
        -- DECOMPILER ERROR at PC42: Confused about usage of register: R5 in 'UnsetPending'

        ;
        ((self.mapPotentialBookBrief)[nCharId]).AllCount = nAllCount
        -- DECOMPILER ERROR at PC45: Confused about usage of register: R5 in 'UnsetPending'

        ;
        ((self.mapPotentialBookBrief)[nCharId]).Count = 0
        -- DECOMPILER ERROR at PC49: Confused about usage of register: R5 in 'UnsetPending'

        ;
        ((self.mapPotentialBookBrief)[nCharId]).Rarity = mapCharCfg.Grade
      end
    end
  end

  ForEachTableLine((ConfigTable.Get)("CharPotential"), foreachPotentialTableLine)
  local foreachPotentialRewardTableLine = function(line)
    -- function num : 0_1_2 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self.mapPotentialQuest)[line.CharId] == nil then
      (self.mapPotentialQuest)[line.CharId] = {}
    end
    -- DECOMPILER ERROR at PC14: Confused about usage of register: R1 in 'UnsetPending'

    ;
    ((self.mapPotentialQuest)[line.CharId])[line.Id] = {}
    -- DECOMPILER ERROR at PC23: Confused about usage of register: R1 in 'UnsetPending'

    ;
    (((self.mapPotentialQuest)[line.CharId])[line.Id]).Status = (AllEnum.BookQuestStatus).UnComplete
    local nAllProgress = 0
    local nParam = 0
    do
      if line.Cond == (GameEnum.towerBookPotentialCond).TowerBookCharPotentialQuantity then
        local params = decodeJson(line.Params)
        nParam = tonumber(params[1])
        nAllProgress = tonumber(params[2])
      end
      -- DECOMPILER ERROR at PC49: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (((self.mapPotentialQuest)[line.CharId])[line.Id]).Cond = line.Cond
      -- DECOMPILER ERROR at PC55: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (((self.mapPotentialQuest)[line.CharId])[line.Id]).Param = nParam
      -- DECOMPILER ERROR at PC61: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (((self.mapPotentialQuest)[line.CharId])[line.Id]).AllProgress = nAllProgress
      -- DECOMPILER ERROR at PC67: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (((self.mapPotentialQuest)[line.CharId])[line.Id]).CurProgress = 0
      local tbReward = {RewardId = line.ItemId, RewardCount = line.ItemQty}
      -- DECOMPILER ERROR at PC78: Confused about usage of register: R4 in 'UnsetPending'

      ;
      (((self.mapPotentialQuest)[line.CharId])[line.Id]).Reward = tbReward
      -- DECOMPILER ERROR at PC89: Confused about usage of register: R4 in 'UnsetPending'

      ;
      (((self.mapPotentialQuest)[line.CharId])[line.Id]).Desc = (UTILS.ParseParamDesc)(line.Desc, line)
    end
  end

  ForEachTableLine((ConfigTable.Get)("StarTowerBookPotentialReward"), foreachPotentialRewardTableLine)
  local foreachFateCardTableLine = function(line)
    -- function num : 0_1_3 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC12: Confused about usage of register: R1 in 'UnsetPending'

    if not line.IsBanned then
      (self.mapFateCardBook)[line.Id] = {Sort = line.SortId, Status = (AllEnum.FateCardBookStatus).Lock}
    end
  end

  ForEachTableLine((ConfigTable.Get)("StarTowerBookFateCard"), foreachFateCardTableLine)
  local foreachFateCardQuestTableLine = function(line)
    -- function num : 0_1_4 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self.mapFateCardQuest)[line.BundleId] == nil then
      (self.mapFateCardQuest)[line.BundleId] = {}
    end
    -- DECOMPILER ERROR at PC28: Confused about usage of register: R1 in 'UnsetPending'

    ;
    ((self.mapFateCardQuest)[line.BundleId])[line.Id] = {Id = line.Id, Desc = (UTILS.ParseParamDesc)(line.Desc, line), Status = (AllEnum.BookQuestStatus).UnComplete, CurProgress = 0, AllProgress = 0}
    local tbReward = {}
    for i = 1, 3 do
      if line["Tid" .. i] > 0 then
        (table.insert)(tbReward, {RewardId = line["Tid" .. i], RewardCount = line["Qty" .. i]})
      end
    end
    -- DECOMPILER ERROR at PC61: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (((self.mapFateCardQuest)[line.BundleId])[line.Id]).Reward = tbReward
    if line.FinishType == (GameEnum.towerBookFateCardFinishType).FateCardCount then
      local param = decodeJson(line.FinishParams)
      -- DECOMPILER ERROR at PC79: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (((self.mapFateCardQuest)[line.BundleId])[line.Id]).AllProgress = tonumber(param[1])
    else
      do
        if line.FinishType == (GameEnum.towerBookFateCardFinishType).FateCardCollect then
          local param = decodeJson(line.FinishParams)
          for _,id in ipairs(param) do
            -- DECOMPILER ERROR at PC106: Confused about usage of register: R8 in 'UnsetPending'

            (((self.mapFateCardQuest)[line.BundleId])[line.Id]).AllProgress = (((self.mapFateCardQuest)[line.BundleId])[line.Id]).AllProgress + 1
          end
        end
      end
    end
  end

  ForEachTableLine((ConfigTable.Get)("StarTowerBookFateCardQuest"), foreachFateCardQuestTableLine)
end

StarTowerBookData.CharPotentialBookChange = function(self, mapMsgData)
  -- function num : 0_2 , upvalues : _ENV
  for _,v in ipairs(mapMsgData.CharPotentials) do
    local nCharId = v.CharId
    local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
    local tbPotentials = v.Potentials
    if (self.mapPotentialBook)[nCharId] ~= nil then
      local mapPotentialList = ((self.mapPotentialBook)[nCharId]).PotentialList
      for _,v in ipairs(tbPotentials) do
        local nLastLevel = mapPotentialList[v.Id] or 0
        if nLastLevel == 0 and mapCharCfg ~= nil and mapCharCfg.Available then
          (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Potential_New, v.Id, true)
        end
        mapPotentialList[v.Id] = v.Level
      end
    end
  end
  self:RefreshPotentialQuest()
  for _,v in ipairs(mapMsgData.CharIds) do
    local mapCfg = (ConfigTable.GetData_Character)(v)
    if mapCfg ~= nil and mapCfg.Available then
      local nElement = mapCfg.EET
      ;
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Potential_Reward, {nElement, v}, true)
      ;
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Potential_Reward, {0, v}, true)
    end
  end
  ;
  (EventManager.Hit)("PotentialBookDataChange")
end

StarTowerBookData.RefreshPotentialQuest = function(self)
  -- function num : 0_3 , upvalues : _ENV
  for nCharId,list in pairs(self.mapPotentialQuest) do
    if (self.mapPotentialBook)[nCharId] ~= nil and ((self.mapPotentialBook)[nCharId]).Init then
      local bCanReceive = false
      local nCharPotentialCount = 0
      for _,v in pairs(((self.mapPotentialBook)[nCharId]).PotentialList) do
        nCharPotentialCount = nCharPotentialCount + 1
      end
      for nId,data in pairs(list) do
        -- DECOMPILER ERROR at PC48: Confused about usage of register: R13 in 'UnsetPending'

        if data.Status ~= (AllEnum.BookQuestStatus).Received then
          if data.Cond == (GameEnum.towerBookPotentialCond).TowerBookCharPotentialQuantity then
            if (self.mapPotentialBookBrief)[data.Param] ~= nil then
              (((self.mapPotentialQuest)[nCharId])[nId]).CurProgress = nCharPotentialCount
              if (((self.mapPotentialQuest)[nCharId])[nId]).AllProgress > (((self.mapPotentialQuest)[nCharId])[nId]).CurProgress or not (AllEnum.BookQuestStatus).Complete then
                local nStatus = (AllEnum.BookQuestStatus).UnComplete
              end
              -- DECOMPILER ERROR at PC70: Confused about usage of register: R14 in 'UnsetPending'

              ;
              (((self.mapPotentialQuest)[nCharId])[nId]).Status = nStatus
            else
              do
                do
                  -- DECOMPILER ERROR at PC78: Confused about usage of register: R13 in 'UnsetPending'

                  ;
                  (((self.mapPotentialQuest)[nCharId])[nId]).Status = (AllEnum.BookQuestStatus).UnComplete
                  if (((self.mapPotentialQuest)[nCharId])[nId]).Status == (AllEnum.BookQuestStatus).Complete then
                    bCanReceive = true
                  end
                  -- DECOMPILER ERROR at PC89: LeaveBlock: unexpected jumping out DO_STMT

                  -- DECOMPILER ERROR at PC89: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                  -- DECOMPILER ERROR at PC89: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC89: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC89: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC89: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC89: LeaveBlock: unexpected jumping out IF_STMT

                end
              end
            end
          end
        end
      end
      local mapCfg = (ConfigTable.GetData_Character)(nCharId)
      if mapCfg ~= nil and mapCfg.Available then
        local nElement = mapCfg.EET
        ;
        (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Potential_Reward, {nElement, nCharId}, bCanReceive)
        ;
        (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Potential_Reward, {0, nCharId}, bCanReceive)
      end
    end
  end
end

StarTowerBookData.GetCharPotentialBriefBook = function(self)
  -- function num : 0_4 , upvalues : _ENV
  local mapBrief = {}
  for nCharId,v in pairs(self.mapPotentialBookBrief) do
    local nUnlock = (PlayerData.Char):CheckCharUnlock(nCharId) and 1 or 0
    local mapData = {nCharId = nCharId, nCount = v.Count or 0, nAllCount = v.AllCount, nUnlock = nUnlock, nRarity = v.Rarity}
    ;
    (table.insert)(mapBrief, mapData)
  end
  ;
  (table.sort)(mapBrief, function(a, b)
    -- function num : 0_4_0
    if a.nRarity == b.nRarity then
      if a.nCharId >= b.nCharId then
        do return a.nUnlock ~= b.nUnlock end
        do return a.nRarity < b.nRarity end
        do return b.nUnlock < a.nUnlock end
        -- DECOMPILER ERROR: 5 unprocessed JMP targets
      end
    end
  end
)
  return mapBrief
end

StarTowerBookData.TryGetCharPotentialBook = function(self, nCharId, callback)
  -- function num : 0_5
  if (self.mapPotentialBook)[nCharId] == nil or not ((self.mapPotentialBook)[nCharId]).Init then
    self:SendPotentialBookMsg(nCharId, callback)
  else
    if callback ~= nil then
      callback()
    end
  end
end

StarTowerBookData.GetCharPotentialBook = function(self, nCharId)
  -- function num : 0_6
  if (self.mapPotentialBook)[nCharId] ~= nil then
    return ((self.mapPotentialBook)[nCharId]).PotentialList
  end
end

StarTowerBookData.GetAllCharPotential = function(self, nCharId)
  -- function num : 0_7 , upvalues : _ENV
  local mapAllPotential = {}
  local mapPotentialData = self:GetCharPotentialBook(nCharId)
  local mapCfg = (ConfigTable.GetData)("CharPotential", nCharId)
  do
    if mapCfg ~= nil then
      local funcSort = function(tbSort)
    -- function num : 0_7_0 , upvalues : _ENV
    (table.sort)(tbSort, function(a, b)
      -- function num : 0_7_0_0 , upvalues : _ENV
      local mapCfgA = (ConfigTable.GetData_Item)(a.nId)
      local mapCfgB = (ConfigTable.GetData_Item)(b.nId)
      if mapCfgA.Rarity == mapCfgB.Rarity then
        if a.nId >= b.nId then
          do return mapCfgA == nil or mapCfgB == nil end
          do return mapCfgA.Rarity < mapCfgB.Rarity end
          do return a.nId < b.nId end
          -- DECOMPILER ERROR: 5 unprocessed JMP targets
        end
      end
    end
)
  end

      mapAllPotential.MasterSpecificIds = {}
      for _,v in pairs(mapCfg.MasterSpecificPotentialIds) do
        ;
        (table.insert)(mapAllPotential.MasterSpecificIds, {nId = v, nLevel = mapPotentialData[v] or 0, nSpecial = 1})
      end
      funcSort(mapAllPotential.MasterSpecificIds)
      mapAllPotential.MasterNormalIds = {}
      for _,v in pairs(mapCfg.MasterNormalPotentialIds) do
        ;
        (table.insert)(mapAllPotential.MasterNormalIds, {nId = v, nLevel = mapPotentialData[v] or 0, nSpecial = 0})
      end
      mapAllPotential.AssistSpecificIds = {}
      for _,v in pairs(mapCfg.AssistSpecificPotentialIds) do
        ;
        (table.insert)(mapAllPotential.AssistSpecificIds, {nId = v, nLevel = mapPotentialData[v] or 0, nSpecial = 1})
      end
      funcSort(mapAllPotential.AssistSpecificIds)
      mapAllPotential.AssistNormalIds = {}
      for _,v in pairs(mapCfg.AssistNormalPotentialIds) do
        ;
        (table.insert)(mapAllPotential.AssistNormalIds, {nId = v, nLevel = mapPotentialData[v] or 0, nSpecial = 0})
      end
      for _,v in pairs(mapCfg.CommonPotentialIds) do
        ;
        (table.insert)(mapAllPotential.MasterNormalIds, {nId = v, nLevel = mapPotentialData[v] or 0, nSpecial = 0})
        ;
        (table.insert)(mapAllPotential.AssistNormalIds, {nId = v, nLevel = mapPotentialData[v] or 0, nSpecial = 0})
      end
      funcSort(mapAllPotential.MasterNormalIds)
      funcSort(mapAllPotential.AssistNormalIds)
    end
    return mapAllPotential
  end
end

StarTowerBookData.GetCharPotentialQuest = function(self, nCharId)
  -- function num : 0_8
  if (self.mapPotentialQuest)[nCharId] ~= nil then
    return (self.mapPotentialQuest)[nCharId]
  end
end

StarTowerBookData.GetCharPotentialCount = function(self, nCharId)
  -- function num : 0_9 , upvalues : _ENV
  if (self.mapPotentialBookBrief)[nCharId] == nil then
    return 0, 0
  end
  if (self.mapPotentialBook)[nCharId] == nil or not ((self.mapPotentialBook)[nCharId]).Init then
    return ((self.mapPotentialBookBrief)[nCharId]).Count, ((self.mapPotentialBookBrief)[nCharId]).AllCount
  end
  local nCount = 0
  for _,v in pairs(((self.mapPotentialBook)[nCharId]).PotentialList) do
    nCount = nCount + 1
  end
  return nCount, ((self.mapPotentialBookBrief)[nCharId]).AllCount
end

StarTowerBookData.TryGetFateCardBook = function(self, callback)
  -- function num : 0_10
  if not self.bFateCardInit then
    self:SendGetFateCardBookMsg(callback)
  else
    if callback ~= nil then
      callback()
    end
  end
end

StarTowerBookData.CheckFateCardBundleUnlock = function(self, nBundleId)
  -- function num : 0_11 , upvalues : _ENV
  local nWorldClass = (PlayerData.Base):GetWorldClass()
  local mapCfg = (ConfigTable.GetData)("StarTowerBookFateCardBundle", nBundleId)
  -- DECOMPILER ERROR at PC22: Unhandled construct in 'MakeBoolean' P1

  if (mapCfg.WorldClass ~= 0 or not true) and mapCfg.WorldClass > nWorldClass then
    local bWorldClass = mapCfg == nil
    if mapCfg.StarTowerId ~= 0 or not true then
      local bStarTower = (PlayerData.StarTower):CheckPassedId(mapCfg.StarTowerId)
    end
    local bCollect = true
    for _,v in pairs(mapCfg.CollectCards) do
      bCollect = not bCollect or ((self.mapFateCardBook)[v]).Status == (AllEnum.FateCardBookStatus).Collect
    end
    if bCollect then
      do
        local bUnlock = true
        for _,v in pairs(mapCfg.UnlockCards) do
          bUnlock = not bUnlock or ((self.mapFateCardBook)[v]).Status ~= (AllEnum.FateCardBookStatus).Lock
        end
        if (not bUnlock or bWorldClass) and bStarTower and bCollect and bUnlock then
          return true
        end
        do return false end
        -- DECOMPILER ERROR: 13 unprocessed JMP targets
      end
    end
  end
end

StarTowerBookData.CheckFateCardUnLock = function(self, nId)
  -- function num : 0_12 , upvalues : _ENV
  local nWorldClass = (PlayerData.Base):GetWorldClass()
  local mapCfg = (ConfigTable.GetData)("StarTowerBookFateCard", nId)
  if mapCfg ~= nil then
    local bBundleUnlock = self:CheckFateCardBundleUnlock(mapCfg.BundleId)
    if not bBundleUnlock then
      return false
    end
    local bWorldClass = (mapCfg.WorldClass == 0 and true) or mapCfg.WorldClass <= nWorldClass
    if mapCfg.StarTowerId ~= 0 or not true then
      local bStarTower = (PlayerData.StarTower):CheckPassedId(mapCfg.StarTowerId)
    end
    local bCollect = true
    for _,v in pairs(mapCfg.CollectCards) do
      bCollect = not bCollect or ((self.mapFateCardBook)[v]).Status == (AllEnum.FateCardBookStatus).Collect
    end
    if bCollect then
      do
        local bUnlock = true
        for _,v in pairs(mapCfg.UnlockCards) do
          bUnlock = not bUnlock or ((self.mapFateCardBook)[v]).Status ~= (AllEnum.FateCardBookStatus).Lock
        end
        if (not bUnlock or bWorldClass) and bStarTower and bCollect and bUnlock then
          return true
        end
        do return false end
        -- DECOMPILER ERROR: 13 unprocessed JMP targets
      end
    end
  end
end

StarTowerBookData.UpdateFateCardStatus = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local mapFateCardLock = {}
  for nId,v in pairs(self.mapFateCardBook) do
    if v.Status == (AllEnum.FateCardBookStatus).Lock then
      (table.insert)(mapFateCardLock, nId)
    end
  end
  local check = function(tbLock)
    -- function num : 0_13_0 , upvalues : _ENV, self, check
    local tempUnlock = {}
    local tempLock = {}
    for _,nId in ipairs(tbLock) do
      -- DECOMPILER ERROR at PC17: Confused about usage of register: R8 in 'UnsetPending'

      if self:CheckFateCardUnLock(nId) then
        ((self.mapFateCardBook)[nId]).Status = (AllEnum.FateCardBookStatus).UnLock
        ;
        (table.insert)(tempUnlock, nId)
      else
        ;
        (table.insert)(tempLock, nId)
      end
    end
    if #tempUnlock == 0 then
      return 
    else
      check(tempLock)
    end
  end

  check(mapFateCardLock)
  self:UpdateFateCardQuest()
end

StarTowerBookData.UpdateFateCardQuest = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local nCollectCount = 0
  local tbBundleCollect = {}
  for nId,v in pairs(self.mapFateCardBook) do
    if v.Status == (AllEnum.FateCardBookStatus).Collect then
      nCollectCount = nCollectCount + 1
      local mapCfg = (ConfigTable.GetData)("StarTowerBookFateCard", nId)
      if mapCfg ~= nil then
        local nBundleId = mapCfg.BundleId
        if tbBundleCollect[nBundleId] == nil then
          tbBundleCollect[nBundleId] = 0
        end
        tbBundleCollect[nBundleId] = tbBundleCollect[nBundleId] + 1
      end
    end
  end
  for nBundleId,list in pairs(self.mapFateCardQuest) do
    for nId,data in pairs(list) do
      if data.Status == (AllEnum.BookQuestStatus).UnComplete then
        local mapCfg = (ConfigTable.GetData)("StarTowerBookFateCardQuest", nId)
        if mapCfg ~= nil then
          if mapCfg.FinishType == (GameEnum.towerBookFateCardFinishType).FateCardCount then
            local param = decodeJson(mapCfg.FinishParams)
            local nBundleParam = 0
            if #param > 1 and param[2] ~= 0 then
              nBundleParam = param[2]
            end
            -- DECOMPILER ERROR at PC73: Confused about usage of register: R16 in 'UnsetPending'

            if nBundleParam == 0 then
              (((self.mapFateCardQuest)[nBundleId])[nId]).CurProgress = nCollectCount
            else
              -- DECOMPILER ERROR at PC82: Confused about usage of register: R16 in 'UnsetPending'

              ;
              (((self.mapFateCardQuest)[nBundleId])[nId]).CurProgress = tbBundleCollect[nBundleParam] or 0
            end
            -- DECOMPILER ERROR at PC99: Confused about usage of register: R16 in 'UnsetPending'

            if (((self.mapFateCardQuest)[nBundleId])[nId]).AllProgress <= (((self.mapFateCardQuest)[nBundleId])[nId]).CurProgress then
              (((self.mapFateCardQuest)[nBundleId])[nId]).Status = (AllEnum.BookQuestStatus).Complete
            end
          else
            do
              if mapCfg.FinishType == (GameEnum.towerBookFateCardFinishType).FateCardCollect then
                local param = decodeJson(mapCfg.FinishParams)
                local bCollect = true
                local nProgress = 0
                for _,id in ipairs(param) do
                  if ((self.mapFateCardBook)[id]).Status ~= (AllEnum.FateCardBookStatus).Collect then
                    bCollect = false
                  else
                    nProgress = nProgress + 1
                  end
                end
                -- DECOMPILER ERROR at PC132: Confused about usage of register: R17 in 'UnsetPending'

                ;
                (((self.mapFateCardQuest)[nBundleId])[nId]).CurProgress = nProgress
                -- DECOMPILER ERROR at PC141: Confused about usage of register: R17 in 'UnsetPending'

                if bCollect then
                  (((self.mapFateCardQuest)[nBundleId])[nId]).Status = (AllEnum.BookQuestStatus).Complete
                end
              end
              do
                -- DECOMPILER ERROR at PC142: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC142: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC142: LeaveBlock: unexpected jumping out IF_STMT

                -- DECOMPILER ERROR at PC142: LeaveBlock: unexpected jumping out IF_THEN_STMT

                -- DECOMPILER ERROR at PC142: LeaveBlock: unexpected jumping out IF_STMT

                -- DECOMPILER ERROR at PC142: LeaveBlock: unexpected jumping out IF_THEN_STMT

                -- DECOMPILER ERROR at PC142: LeaveBlock: unexpected jumping out IF_STMT

              end
            end
          end
        end
      end
    end
  end
end

StarTowerBookData.RefreshFateCardRedDot = function(self)
  -- function num : 0_15 , upvalues : _ENV
  for nBundleId,list in pairs(self.mapFateCardQuest) do
    local bCanReceive = false
    for _,data in pairs(list) do
      if data.Status == (AllEnum.BookQuestStatus).Complete then
        bCanReceive = true
        break
      end
    end
    do
      do
        ;
        (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_FateCard_Reward, nBundleId, bCanReceive)
        -- DECOMPILER ERROR at PC26: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
end

StarTowerBookData.FateCardBookChange = function(self, mapMsgData)
  -- function num : 0_16 , upvalues : _ENV
  for _,v in ipairs(mapMsgData.Cards) do
    -- DECOMPILER ERROR at PC13: Confused about usage of register: R7 in 'UnsetPending'

    if (self.mapFateCardBook)[v] ~= nil then
      ((self.mapFateCardBook)[v]).Status = (AllEnum.FateCardBookStatus).Collect
      ;
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_FateCard_New, v, true)
    end
  end
  self:UpdateFateCardStatus()
  self:RefreshFateCardRedDot()
end

StarTowerBookData.FateCardBookRewardChange = function(self, mapMsgData)
  -- function num : 0_17 , upvalues : _ENV
  if mapMsgData.Option then
    for _,v in ipairs(mapMsgData.List) do
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_FateCard_Reward, v, true)
    end
  else
    do
      for _,v in ipairs(mapMsgData.List) do
        (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_FateCard_Reward, v, false)
      end
    end
  end
end

StarTowerBookData.GetFateCardBundleQuest = function(self, nBundleId)
  -- function num : 0_18 , upvalues : _ENV
  local mapQuest = {}
  if (self.mapFateCardQuest)[nBundleId] ~= nil then
    for nId,data in pairs((self.mapFateCardQuest)[nBundleId]) do
      data.Id = nId
      ;
      (table.insert)(mapQuest, data)
    end
  end
  do
    return mapQuest
  end
end

StarTowerBookData.GetAllFateCardBundle = function(self)
  -- function num : 0_19 , upvalues : _ENV
  local mapBundle = {}
  local foreachTableLine = function(line)
    -- function num : 0_19_0 , upvalues : mapBundle
    mapBundle[line.Id] = {nSort = line.SortId, 
tbCardList = {}
}
  end

  ForEachTableLine(DataTable.StarTowerBookFateCardBundle, foreachTableLine)
  for nId,v in pairs(self.mapFateCardBook) do
    local mapCfg = (ConfigTable.GetData)("StarTowerBookFateCard", nId)
    if mapCfg ~= nil then
      local nBundleId = mapCfg.BundleId
      if mapBundle[nBundleId] ~= nil then
        (table.insert)((mapBundle[nBundleId]).tbCardList, {nId = nId, nStatus = v.Status, nSort = v.Sort})
      end
    end
  end
  return mapBundle
end

StarTowerBookData.GetAllEventBookData = function(self)
  -- function num : 0_20 , upvalues : _ENV, MAPSTATUS
  local mapEventBook = {}
  local mapQuestData = (PlayerData.Quest):GetStarTowerBookQuestData()
  local foreachEventRewardTableLine = function(line)
    -- function num : 0_20_0 , upvalues : mapQuestData, MAPSTATUS, _ENV, mapEventBook
    if not line.IsBanned then
      local tbData = {}
      tbData.Id = line.Id
      if mapQuestData[line.Id] == nil or not MAPSTATUS[(mapQuestData[line.Id]).nStatus] then
        tbData.Status = (AllEnum.BookQuestStatus).Received
        tbData.CfgData = line
        tbData.nGoal = mapQuestData[line.Id] ~= nil and (mapQuestData[line.Id]).nGoal or 0
        tbData.nCurProgress = mapQuestData[line.Id] ~= nil and (mapQuestData[line.Id]).nCurProgress or 0
        ;
        (table.insert)(mapEventBook, tbData)
      end
    end
  end

  ForEachTableLine((ConfigTable.Get)("StarTowerBookEventReward"), foreachEventRewardTableLine)
  ;
  (table.sort)(mapEventBook, function(a, b)
    -- function num : 0_20_1
    if (a.CfgData).Id >= (b.CfgData).Id then
      do return (a.CfgData).Sort ~= (b.CfgData).Sort end
      do return (a.CfgData).Sort < (b.CfgData).Sort end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
  return mapEventBook
end

StarTowerBookData.GetRandomEntranceCfg = function(self)
  -- function num : 0_21 , upvalues : _ENV
  local nIndex = (math.random)(1, #self.mapEntranceCfg)
  return (self.mapEntranceCfg)[nIndex]
end

StarTowerBookData.UpdateServerRedDot = function(self, msgData)
  -- function num : 0_22 , upvalues : _ENV
  for _,v in ipairs(msgData.CharIds) do
    local mapCfg = (ConfigTable.GetData_Character)(v)
    if mapCfg ~= nil and mapCfg.Available then
      local nElement = mapCfg.EET
      ;
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Potential_Reward, {nElement, v}, true)
      ;
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Potential_Reward, {0, v}, true)
    end
  end
  for _,v in ipairs(msgData.Bundles) do
    (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_FateCard_Reward, v, true)
  end
end

StarTowerBookData.SendPotentialBriefListMsg = function(self, callback)
  -- function num : 0_23 , upvalues : _ENV
  local sucCall = function(_, mapMsgData)
    -- function num : 0_23_0 , upvalues : _ENV, self, callback
    if mapMsgData.Infos ~= nil then
      for _,v in ipairs(mapMsgData.Infos) do
        local nCharId = v.CharId
        -- DECOMPILER ERROR at PC15: Confused about usage of register: R8 in 'UnsetPending'

        if (self.mapPotentialBookBrief)[nCharId] ~= nil then
          ((self.mapPotentialBookBrief)[nCharId]).Count = v.Count
        end
      end
    end
    do
      if callback ~= nil then
        callback()
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_book_potential_brief_list_get_req, {}, nil, sucCall)
end

StarTowerBookData.SendPotentialBookMsg = function(self, nCharId, callback)
  -- function num : 0_24 , upvalues : _ENV
  local sucCall = function(_, mapMsgData)
    -- function num : 0_24_0 , upvalues : self, nCharId, _ENV, callback
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R2 in 'UnsetPending'

    if mapMsgData.Potentials ~= nil then
      if (self.mapPotentialBook)[nCharId] == nil then
        (self.mapPotentialBook)[nCharId] = {}
      end
      -- DECOMPILER ERROR at PC15: Confused about usage of register: R2 in 'UnsetPending'

      ;
      ((self.mapPotentialBook)[nCharId]).Init = true
      for _,v in ipairs(mapMsgData.Potentials) do
        -- DECOMPILER ERROR at PC26: Confused about usage of register: R7 in 'UnsetPending'

        (((self.mapPotentialBook)[nCharId]).PotentialList)[v.Id] = v.Level
      end
    end
    do
      if mapMsgData.ReceivedIds ~= nil then
        for _,v in ipairs(mapMsgData.ReceivedIds) do
          local mapCfg = (ConfigTable.GetData)("StarTowerBookPotentialReward", v)
          -- DECOMPILER ERROR at PC55: Confused about usage of register: R8 in 'UnsetPending'

          if mapCfg ~= nil and (self.mapPotentialQuest)[mapCfg.CharId] ~= nil then
            (((self.mapPotentialQuest)[mapCfg.CharId])[v]).Status = (AllEnum.BookQuestStatus).Received
          end
        end
      end
      do
        self:RefreshPotentialQuest()
        if callback ~= nil then
          callback()
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_book_char_potential_get_req, {Value = nCharId}, nil, sucCall)
end

StarTowerBookData.SendReceivePotentialRewardMsg = function(self, nCharId, callback)
  -- function num : 0_25 , upvalues : _ENV
  local sucCall = function(_, mapMsgData)
    -- function num : 0_25_0 , upvalues : _ENV, self, nCharId, callback
    for _,v in ipairs(mapMsgData.ReceivedIds) do
      local mapCfg = (ConfigTable.GetData)("StarTowerBookPotentialReward", v)
      -- DECOMPILER ERROR at PC23: Confused about usage of register: R8 in 'UnsetPending'

      if mapCfg ~= nil and (self.mapPotentialQuest)[mapCfg.CharId] ~= nil then
        (((self.mapPotentialQuest)[mapCfg.CharId])[v]).Status = (AllEnum.BookQuestStatus).Received
      end
    end
    local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
    if mapCharCfg ~= nil and mapCharCfg.Available then
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Potential_Reward, {mapCharCfg.EET, nCharId}, false)
      ;
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Potential_Reward, {0, nCharId}, false)
    end
    ;
    (EventManager.Hit)("ReceivePotentialBookReward")
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapMsgData.Change, callback)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_book_potential_reward_receive_req, {Value = nCharId}, nil, sucCall)
end

StarTowerBookData.SendGetFateCardBookMsg = function(self, callback)
  -- function num : 0_26 , upvalues : _ENV
  local sucCall = function(_, mapMsgData)
    -- function num : 0_26_0 , upvalues : self, _ENV, callback
    self.bFateCardInit = true
    for _,v in ipairs(mapMsgData.Cards) do
      -- DECOMPILER ERROR at PC14: Confused about usage of register: R7 in 'UnsetPending'

      if (self.mapFateCardBook)[v] ~= nil then
        ((self.mapFateCardBook)[v]).Status = (AllEnum.FateCardBookStatus).Collect
      end
    end
    self:UpdateFateCardStatus()
    for _,v in ipairs(mapMsgData.Quests) do
      local mapCfg = (ConfigTable.GetData)("StarTowerBookFateCardQuest", v)
      if mapCfg ~= nil then
        local nBundleId = mapCfg.BundleId
        -- DECOMPILER ERROR at PC42: Confused about usage of register: R9 in 'UnsetPending'

        if (self.mapFateCardQuest)[nBundleId] ~= nil then
          (((self.mapFateCardQuest)[nBundleId])[v]).Status = (AllEnum.BookQuestStatus).Received
          ;
          (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_FateCard_Reward, nBundleId, false)
        end
      end
    end
    self:RefreshFateCardRedDot()
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).tower_book_fate_card_detail_req, {}, nil, sucCall)
end

StarTowerBookData.SendReceiveFateCardRewardMsg = function(self, nBundleId, nQuestId, callback)
  -- function num : 0_27 , upvalues : _ENV
  local sucCall = function(_, mapMsgData)
    -- function num : 0_27_0 , upvalues : self, nBundleId, _ENV, callback
    if (self.mapFateCardQuest)[nBundleId] ~= nil then
      for nId,v in pairs((self.mapFateCardQuest)[nBundleId]) do
        -- DECOMPILER ERROR at PC24: Confused about usage of register: R7 in 'UnsetPending'

        if v.Status == (AllEnum.BookQuestStatus).Complete then
          (((self.mapFateCardQuest)[nBundleId])[nId]).Status = (AllEnum.BookQuestStatus).Received
        end
      end
    end
    do
      ;
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_FateCard_Reward, nBundleId, false)
      ;
      (EventManager.Hit)("ReceiveFateCardBookReward")
      ;
      (UTILS.OpenReceiveByChangeInfo)(mapMsgData, callback)
    end
  end

  local msgData = {CardBundleId = nBundleId, QuestId = nQuestId or 0}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).tower_book_fate_card_reward_receive_req, msgData, nil, sucCall)
end

StarTowerBookData.OnEvent_UpdateWorldClass = function(self)
  -- function num : 0_28
end

StarTowerBookData.OnEvent_StarTowerPass = function(self)
  -- function num : 0_29
end

return StarTowerBookData

