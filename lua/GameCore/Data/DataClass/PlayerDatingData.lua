local PlayerDatingData = class("PlayerDatingData")
PlayerDatingData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.tbDatingCharIds = 0
  self.nAllDatingCount = 0
  self.tbLandmarkCfg = {}
  self.mapCharLimitedEvent = {}
  self.mapCharStartEvent = {}
  self.mapCharEndEvent = {}
  self.mapCharLandmark = {}
  self.nCurSelectLandmark = 0
  self.mapDelay = nil
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  self:InitConfig()
end

PlayerDatingData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

PlayerDatingData.InitConfig = function(self)
  -- function num : 0_2 , upvalues : _ENV
  self.nAllDatingCount = (ConfigTable.GetConfigNumber)("Dating_Max_Daily_Count")
  local funcForeachLandmark = function(mapData)
    -- function num : 0_2_0 , upvalues : _ENV, self
    (table.insert)(self.tbLandmarkCfg, mapData)
  end

  ForEachTableLine(DataTable.DatingLandmark, funcForeachLandmark)
  local funcForeachCharEvent = function(mapData)
    -- function num : 0_2_1 , upvalues : _ENV, self
    if mapData.DatingEventType == (GameEnum.DatingEventType).LimitedLandmark then
      local param = decodeJson(mapData.DatingEventParams)
      if mapData.DatingEventParams ~= nil and #mapData.DatingEventParams == 2 then
        local nCharId = tonumber((mapData.DatingEventParams)[1])
        local nLandmark = tonumber((mapData.DatingEventParams)[2])
        -- DECOMPILER ERROR at PC30: Confused about usage of register: R4 in 'UnsetPending'

        if (self.mapCharLimitedEvent)[nCharId] == nil then
          (self.mapCharLimitedEvent)[nCharId] = {}
        end
        local data = {Id = mapData.Id, LandMark = nLandmark, Status = (AllEnum.DatingEventStatus).Lock}
        -- DECOMPILER ERROR at PC42: Confused about usage of register: R5 in 'UnsetPending'

        ;
        ((self.mapCharLimitedEvent)[nCharId])[mapData.Id] = data
        ;
        (RedDotManager.SetValid)(RedDotDefine.Phone_Dating_Reward, {nCharId, mapData.Id}, false)
        -- DECOMPILER ERROR at PC59: Confused about usage of register: R5 in 'UnsetPending'

        if (self.mapCharLandmark)[nCharId] == nil then
          (self.mapCharLandmark)[nCharId] = {}
        end
        -- DECOMPILER ERROR at PC68: Confused about usage of register: R5 in 'UnsetPending'

        if ((self.mapCharLandmark)[nCharId])[nLandmark] == nil then
          ((self.mapCharLandmark)[nCharId])[nLandmark] = {}
        end
        ;
        (table.insert)(((self.mapCharLandmark)[nCharId])[nLandmark], mapData.Id)
      end
    end
  end

  ForEachTableLine((ConfigTable.Get)("DatingCharacterEvent"), funcForeachCharEvent)
  local funcForeachStartEndEvent = function(mapData)
    -- function num : 0_2_2 , upvalues : _ENV, self
    if mapData.DatingEventType == (GameEnum.DatingEventType).Start then
      local nCharId = tonumber((mapData.DatingEventParams)[1])
      -- DECOMPILER ERROR at PC16: Confused about usage of register: R2 in 'UnsetPending'

      if (self.mapCharStartEvent)[nCharId] == nil then
        (self.mapCharStartEvent)[nCharId] = {}
      end
      ;
      (table.insert)((self.mapCharStartEvent)[nCharId], mapData.Id)
    else
      do
        if mapData.DatingEventType == (GameEnum.DatingEventType).End then
          local nCharId = tonumber((mapData.DatingEventParams)[1])
          -- DECOMPILER ERROR at PC40: Confused about usage of register: R2 in 'UnsetPending'

          if (self.mapCharEndEvent)[nCharId] == nil then
            (self.mapCharEndEvent)[nCharId] = {}
          end
          ;
          (table.insert)((self.mapCharEndEvent)[nCharId], mapData.Id)
        end
      end
    end
  end

  ForEachTableLine((ConfigTable.Get)("DatingStartEndEvent"), funcForeachStartEndEvent)
  local foreachResponse = function(line)
    -- function num : 0_2_3 , upvalues : _ENV
    if (CacheTable.GetData)("_DatingCharResponse", line.CharId) == nil then
      (CacheTable.SetData)("_DatingCharResponse", line.CharId, {})
    end
    ;
    ((CacheTable.GetData)("_DatingCharResponse", line.CharId))[line.Type] = line
  end

  ForEachTableLine(DataTable.DatingCharResponse, foreachResponse)
end

PlayerDatingData.RefreshDatingCharIds = function(self, tbChar)
  -- function num : 0_3
  self.tbDatingCharIds = tbChar
end

PlayerDatingData.AddDatingCharId = function(self, nCharId)
  -- function num : 0_4 , upvalues : _ENV
  for _,v in ipairs(self.tbDatingCharIds) do
    if v == nCharId then
      printError("重复邀约！！！")
      return 
    end
  end
  ;
  (table.insert)(self.tbDatingCharIds, nCharId)
end

PlayerDatingData.CacheDatingCharIds = function(self, tbChar)
  -- function num : 0_5
  self.tbDatingCharIds = tbChar
end

PlayerDatingData.GetRandomLandmark = function(self)
  -- function num : 0_6 , upvalues : _ENV
  if #self.tbLandmarkCfg <= 3 then
    return self.tbLandmarkCfg
  end
  local tbResult = {}
  local tbRandom = {}
  for i = 1, #self.tbLandmarkCfg do
    tbRandom[i] = i
  end
  for i = 1, 3 do
    local randomIndex = (math.random)(#tbRandom)
    local nSelectIndex = tbRandom[randomIndex]
    ;
    (table.insert)(tbResult, (self.tbLandmarkCfg)[nSelectIndex])
    ;
    (table.remove)(tbRandom, randomIndex)
  end
  return tbResult
end

PlayerDatingData.CheckHasNewEvent = function(self, nCharId, nLandmark)
  -- function num : 0_7 , upvalues : _ENV
  local charData = (PlayerData.Char):GetCharDatingEvent(nCharId)
  if charData ~= nil and (self.mapCharLimitedEvent)[nCharId] ~= nil then
    for nEId,v in pairs((self.mapCharLimitedEvent)[nCharId]) do
      if v.LandMark == nLandmark and v.Status == (AllEnum.DatingEventStatus).Lock then
        return true
      end
    end
  end
  do
    return false
  end
end

PlayerDatingData.RefreshLimitedEventList = function(self, nCharId, tbDatingEventIds, tbDatingEventRewardIds)
  -- function num : 0_8 , upvalues : _ENV
  if (self.mapCharLimitedEvent)[nCharId] ~= nil then
    for nEId,v in pairs((self.mapCharLimitedEvent)[nCharId]) do
      for _,nId in ipairs(tbDatingEventIds) do
        -- DECOMPILER ERROR at PC30: Confused about usage of register: R14 in 'UnsetPending'

        if nId == nEId and (((self.mapCharLimitedEvent)[nCharId])[nEId]).Status == (AllEnum.DatingEventStatus).Lock then
          (((self.mapCharLimitedEvent)[nCharId])[nEId]).Status = (AllEnum.DatingEventStatus).Unlock
          ;
          (RedDotManager.SetValid)(RedDotDefine.Phone_Dating_Reward, {nCharId, nEId}, true)
          break
        end
      end
      do
        if tbDatingEventRewardIds ~= nil then
          for _,nId in ipairs(tbDatingEventRewardIds) do
            -- DECOMPILER ERROR at PC58: Confused about usage of register: R14 in 'UnsetPending'

            if nId == nEId then
              (((self.mapCharLimitedEvent)[nCharId])[nEId]).Status = (AllEnum.DatingEventStatus).Received
              ;
              (RedDotManager.SetValid)(RedDotDefine.Phone_Dating_Reward, {nCharId, nEId}, false)
              break
            end
          end
        end
        do
          -- DECOMPILER ERROR at PC72: LeaveBlock: unexpected jumping out DO_STMT

        end
      end
    end
  end
  if PlayerData.Phone ~= nil then
    (PlayerData.Phone):RefreshRedDot()
  end
end

PlayerDatingData.GetLimitedEventList = function(self, nCharId)
  -- function num : 0_9 , upvalues : _ENV
  local mapData = {}
  if (self.mapCharLimitedEvent)[nCharId] ~= nil then
    for nEId,v in pairs((self.mapCharLimitedEvent)[nCharId]) do
      (table.insert)(mapData, v)
    end
  end
  do
    ;
    (table.sort)(mapData, function(a, b)
    -- function num : 0_9_0
    do return a.Id < b.Id end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
    return mapData
  end
end

PlayerDatingData.GetDatingCount = function(self)
  -- function num : 0_10
  return #self.tbDatingCharIds, self.nAllDatingCount
end

PlayerDatingData.CheckDating = function(self, nCharId)
  -- function num : 0_11 , upvalues : _ENV
  local bDating = false
  for _,v in ipairs(self.tbDatingCharIds) do
    if v == nCharId then
      bDating = true
      break
    end
  end
  do
    return bDating
  end
end

PlayerDatingData.SetCurLandmarkId = function(self, nLandmarkId)
  -- function num : 0_12
  self.nCurSelectLandmark = nLandmarkId
end

PlayerDatingData.GetCurLandmarkId = function(self)
  -- function num : 0_13
  return self.nCurSelectLandmark
end

PlayerDatingData.SetCharFavourLevelUpDelay = function(self, mapData)
  -- function num : 0_14
  self.mapDelay = mapData
end

PlayerDatingData.GetCharFavourLevelUpDelay = function(self)
  -- function num : 0_15
  return self.mapDelay
end

PlayerDatingData.GetCharStartEventId = function(self, nCharId)
  -- function num : 0_16 , upvalues : _ENV
  if (self.mapCharStartEvent)[nCharId] ~= nil then
    local nRandom = (math.random)(1, #(self.mapCharStartEvent)[nCharId])
    return ((self.mapCharStartEvent)[nCharId])[nRandom]
  end
end

PlayerDatingData.GetCharBranchEventId = function(self, nCharId, bFirstBranch)
  -- function num : 0_17 , upvalues : _ENV
  local nEventId = 0
  local funcForeachEvent = function(mapData)
    -- function num : 0_17_0 , upvalues : self, _ENV, nCharId, bFirstBranch, nEventId
    if #mapData.DatingEventParams > 0 and (mapData.DatingEventParams)[1] == self.nCurSelectLandmark then
      for k,v in pairs(mapData.DatingEventExclude) do
        if v == nCharId then
          return 
        end
      end
      local last_digit = (math.abs)(mapData.Id) % 10
      local nBranchFlag = bFirstBranch and 0 or 1
      if last_digit == nBranchFlag then
        nEventId = mapData.Id
      end
    end
  end

  ForEachTableLine((ConfigTable.Get)("DatingBranch"), funcForeachEvent)
  return nEventId
end

PlayerDatingData.GetCharEndEventId = function(self, nCharId)
  -- function num : 0_18 , upvalues : _ENV
  if (self.mapCharEndEvent)[nCharId] ~= nil then
    local nRandom = (math.random)(1, #(self.mapCharEndEvent)[nCharId])
    return ((self.mapCharEndEvent)[nCharId])[nRandom]
  end
end

PlayerDatingData.SendDatingLandmarkSelectMsg = function(self, nCharId, nLandmarkId, callback)
  -- function num : 0_19 , upvalues : _ENV
  local successCallback = function(_, msgData)
    -- function num : 0_19_0 , upvalues : self, nLandmarkId, nCharId, callback
    self:SetCurLandmarkId(nLandmarkId)
    self:AddDatingCharId(nCharId)
    if callback ~= nil then
      callback(msgData)
    end
  end

  local sendData = {CharId = nCharId, LandmarkId = nLandmarkId}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_dating_landmark_select_req, sendData, nil, successCallback)
end

PlayerDatingData.SendReceiveDatingEventRewardMsg = function(self, nCharId, nEventId, callback)
  -- function num : 0_20 , upvalues : _ENV
  local successCallback = function(_, msgData)
    -- function num : 0_20_0 , upvalues : self, nCharId, nEventId, _ENV, callback
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R2 in 'UnsetPending'

    (((self.mapCharLimitedEvent)[nCharId])[nEventId]).Status = (AllEnum.DatingEventStatus).Received
    ;
    (RedDotManager.SetValid)(RedDotDefine.Phone_Dating_Reward, {nCharId, nEventId}, false)
    ;
    (PlayerData.Phone):RefreshRedDot()
    ;
    (UTILS.OpenReceiveByChangeInfo)(msgData, callback)
  end

  local sendData = {CharId = nCharId, EventId = nEventId}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_dating_event_reward_receive_req, sendData, nil, successCallback)
end

PlayerDatingData.SendDatingSendGiftMsg = function(self, nCharId, tbItems, callback)
  -- function num : 0_21 , upvalues : _ENV
  local successCallback = function(_, msgData)
    -- function num : 0_21_0 , upvalues : callback
    if callback ~= nil then
      callback(msgData)
    end
  end

  local sendData = {CharId = nCharId, Items = tbItems}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_dating_gift_send_req, sendData, nil, successCallback)
end

PlayerDatingData.OnEvent_NewDay = function(self)
  -- function num : 0_22
  self.tbDatingCharIds = {}
end

return PlayerDatingData

