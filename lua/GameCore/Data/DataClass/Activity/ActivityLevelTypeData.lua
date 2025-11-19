local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local ActivityLevelTypeData = class("ActivityLevelTypeData", ActivityDataBase)
local newDayTime = (UTILS.GetDayRefreshTimeOffset)()
local LocalData = require("GameCore.Data.LocalData")
ActivityLevelTypeData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.nActId = 0
  self.startTime = 0
  self.startTimeRefreshTime = 0
  self.exploreLevelCount = 0
  self.adventureLevelCount = 0
  self.levelTabExplore = {}
  self.levelTabExploreDifficulty = {}
  self.levelTabAdventure = {}
  self.levelTabAdventureDifficulty = {}
  self.tabCachedBuildId = {}
  ;
  (EventManager.Add)("ActivityLevels_Instance_Gameplay_Time", self, self.OnEvent_Time)
end

ActivityLevelTypeData.OnEvent_Time = function(self, nTime)
  -- function num : 0_1
  self._TotalTime = nTime
end

ActivityLevelTypeData.RefreshActivityLevelGameActData = function(self, actId, msgData)
  -- function num : 0_2 , upvalues : _ENV
  self:Init()
  local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
  local isEnding = false
  if self.nEndTime < nCurTime then
    isEnding = true
  end
  local openTime = self.nOpenTime
  self.startTimeRefreshTime = ((CS.ClientManager).Instance):GetNextRefreshTime(openTime) - 86400
  self.nActId = actId
  local foreach_Base = function(baseData)
    -- function num : 0_2_0 , upvalues : actId, _ENV, self, isEnding
    if actId == baseData.ActivityId then
      if baseData.Type == (GameEnum.ActivityLevelType).Explore then
        self.exploreLevelCount = self.exploreLevelCount + 1
        -- DECOMPILER ERROR at PC16: Confused about usage of register: R1 in 'UnsetPending'

        ;
        (self.levelTabExplore)[baseData.Id] = {}
        -- DECOMPILER ERROR at PC20: Confused about usage of register: R1 in 'UnsetPending'

        ;
        ((self.levelTabExplore)[baseData.Id]).baseData = baseData
        -- DECOMPILER ERROR at PC24: Confused about usage of register: R1 in 'UnsetPending'

        ;
        ((self.levelTabExplore)[baseData.Id]).Star = 0
        -- DECOMPILER ERROR at PC28: Confused about usage of register: R1 in 'UnsetPending'

        ;
        ((self.levelTabExplore)[baseData.Id]).BuildId = 0
        -- DECOMPILER ERROR at PC32: Confused about usage of register: R1 in 'UnsetPending'

        ;
        (self.levelTabExploreDifficulty)[baseData.Difficulty] = baseData.Id
      else
        self.adventureLevelCount = self.adventureLevelCount + 1
        -- DECOMPILER ERROR at PC40: Confused about usage of register: R1 in 'UnsetPending'

        ;
        (self.levelTabAdventure)[baseData.Id] = {}
        -- DECOMPILER ERROR at PC44: Confused about usage of register: R1 in 'UnsetPending'

        ;
        ((self.levelTabAdventure)[baseData.Id]).baseData = baseData
        -- DECOMPILER ERROR at PC48: Confused about usage of register: R1 in 'UnsetPending'

        ;
        ((self.levelTabAdventure)[baseData.Id]).Star = 0
        -- DECOMPILER ERROR at PC52: Confused about usage of register: R1 in 'UnsetPending'

        ;
        ((self.levelTabAdventure)[baseData.Id]).BuildId = 0
        -- DECOMPILER ERROR at PC56: Confused about usage of register: R1 in 'UnsetPending'

        ;
        (self.levelTabAdventureDifficulty)[baseData.Difficulty] = baseData.Id
      end
      self:CheckRedDot(baseData.Type, baseData.Id, baseData.DayOpen, isEnding)
    end
  end

  ForEachTableLine(DataTable.ActivityLevelsLevel, foreach_Base)
  if msgData ~= nil then
    for i,v in ipairs(msgData.levels) do
      local tmpData = (ConfigTable.GetData)("ActivityLevelsLevel", v.Id)
      -- DECOMPILER ERROR at PC55: Confused about usage of register: R13 in 'UnsetPending'

      -- DECOMPILER ERROR at PC55: Unhandled construct in 'MakeBoolean' P1

      if tmpData and tmpData.Type == (GameEnum.ActivityLevelType).Explore and (self.levelTabExplore)[v.Id] then
        ((self.levelTabExplore)[v.Id]).Star = v.Star
        -- DECOMPILER ERROR at PC60: Confused about usage of register: R13 in 'UnsetPending'

        ;
        ((self.levelTabExplore)[v.Id]).BuildId = v.BuildId
      end
      -- DECOMPILER ERROR at PC71: Confused about usage of register: R13 in 'UnsetPending'

      if (self.levelTabAdventure)[v.Id] then
        ((self.levelTabAdventure)[v.Id]).Star = v.Star
        -- DECOMPILER ERROR at PC76: Confused about usage of register: R13 in 'UnsetPending'

        ;
        ((self.levelTabAdventure)[v.Id]).BuildId = v.BuildId
      end
    end
  end
end

ActivityLevelTypeData.CheckRedDot = function(self, nType, levelId, dayOpen, isEnding)
  -- function num : 0_3 , upvalues : LocalData, _ENV
  local tmpKey = self.nActId .. "_" .. levelId
  if isEnding then
    (LocalData.SetPlayerLocalData)(tmpKey, "0")
    return 
  end
  local sLocalVal = (LocalData.GetPlayerLocalData)(tmpKey)
  local nState = tonumber(sLocalVal == nil and "0" or sLocalVal)
  if nState == 2 then
    return 
  end
  if nState == 1 then
    local bInActGroup, nActGroupId = (PlayerData.Activity):IsActivityInActivityGroup(self.nActId)
    if bInActGroup then
      local actGroupData = (PlayerData.Activity):GetActivityGroupDataById(nActGroupId)
      local bActGroupUnlock = actGroupData:IsUnlock()
      if nType == (GameEnum.ActivityLevelType).Explore then
        (RedDotManager.SetValid)(RedDotDefine.ActivityLevel_Explore_Level, {nActGroupId, levelId}, bActGroupUnlock)
      else
        ;
        (RedDotManager.SetValid)(RedDotDefine.ActivityLevel_Adventure_Level, {nActGroupId, levelId}, bActGroupUnlock)
      end
    end
    do
      do
        do return  end
        local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
        local openTime = self.startTimeRefreshTime + dayOpen * 86400
        local openTimeNextDay = self.startTimeRefreshTime + dayOpen * 86400 + 86400
        if openTime <= nCurTime and nCurTime <= openTimeNextDay then
          (LocalData.SetPlayerLocalData)(tmpKey, "1")
          local bInActGroup, nActGroupId = (PlayerData.Activity):IsActivityInActivityGroup(self.nActId)
          if bInActGroup then
            local actGroupData = (PlayerData.Activity):GetActivityGroupDataById(nActGroupId)
            local bActGroupUnlock = actGroupData:IsUnlock()
            if nType == (GameEnum.ActivityLevelType).Explore then
              (RedDotManager.SetValid)(RedDotDefine.ActivityLevel_Explore_Level, {nActGroupId, levelId}, bActGroupUnlock)
            else
              ;
              (RedDotManager.SetValid)(RedDotDefine.ActivityLevel_Adventure_Level, {nActGroupId, levelId}, bActGroupUnlock)
            end
          end
        end
      end
    end
  end
end

ActivityLevelTypeData.ChangeRedDot = function(self, nType, levelId)
  -- function num : 0_4 , upvalues : LocalData, _ENV
  local tmpKey = self.nActId .. "_" .. levelId
  local sLocalVal = (LocalData.GetPlayerLocalData)(tmpKey)
  local nState = tonumber(sLocalVal == nil and "0" or sLocalVal)
  if nState == 1 then
    (LocalData.SetPlayerLocalData)(tmpKey, "2")
    local bInActGroup, nActGroupId = (PlayerData.Activity):IsActivityInActivityGroup(self.nActId)
    if bInActGroup then
      if nType == (GameEnum.ActivityLevelType).Explore then
        (RedDotManager.SetValid)(RedDotDefine.ActivityLevel_Explore_Level, {nActGroupId, levelId}, false)
      else
        ;
        (RedDotManager.SetValid)(RedDotDefine.ActivityLevel_Adventure_Level, {nActGroupId, levelId}, false)
      end
    end
  end
end

ActivityLevelTypeData.ChangeAllRedHot = function(self)
  -- function num : 0_5 , upvalues : _ENV
  local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
  local isEnding = false
  if self.nEndTime <= nCurTime then
    isEnding = true
  end
  if not isEnding then
    return 
  end
  for i,v in pairs(self.levelTabExploreDifficulty) do
    self:ChangeRedDot((GameEnum.ActivityLevelType).Explore, v)
  end
  for i,v in pairs(self.levelTabAdventureDifficulty) do
    self:ChangeRedDot((GameEnum.ActivityLevelType).Adventure, v)
  end
end

ActivityLevelTypeData.GetLevelStarMsg = function(self, nType)
  -- function num : 0_6 , upvalues : _ENV
  if nType == (GameEnum.ActivityLevelType).Explore then
    local star = 0
    for i,v in pairs(self.levelTabExplore) do
      star = star + v.Star
    end
    return self.exploreLevelCount * 3, star
  else
    do
      local star = 0
      for i,v in pairs(self.levelTabAdventure) do
        star = star + v.Star
      end
      do return self.adventureLevelCount * 3, star end
    end
  end
end

ActivityLevelTypeData.GetLevelDayOpen = function(self, nType, id)
  -- function num : 0_7 , upvalues : _ENV
  -- DECOMPILER ERROR at PC13: Unhandled construct in 'MakeBoolean' P1

  if nType == (GameEnum.ActivityLevelType).Explore and (self.levelTabExplore)[id] ~= nil then
    local dayOpen = (((self.levelTabExplore)[id]).baseData).DayOpen
    local openTime = self.startTimeRefreshTime + dayOpen * 86400
    local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
    if openTime <= nCurTime then
      return true
    end
  end
  do
    if (self.levelTabAdventure)[id] ~= nil then
      local dayOpen = (((self.levelTabAdventure)[id]).baseData).DayOpen
      local openTime = self.startTimeRefreshTime + dayOpen * 86400
      local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
      if openTime <= nCurTime then
        return true
      end
    end
    do
      return false
    end
  end
end

ActivityLevelTypeData.GetUnLockDay = function(self, nType, id)
  -- function num : 0_8 , upvalues : _ENV
  if nType == (GameEnum.ActivityLevelType).Explore then
    local dayOpen = (((self.levelTabExplore)[id]).baseData).DayOpen
    local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
    local nDay = (math.floor)((self.startTimeRefreshTime + dayOpen * 86400 - nCurTime) / 86400)
    return nDay
  else
    do
      local dayOpen = (((self.levelTabAdventure)[id]).baseData).DayOpen
      local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
      do
        local nDay = (math.floor)((self.startTimeRefreshTime + dayOpen * 86400 - nCurTime) / 86400)
        do return nDay end
        return 1
      end
    end
  end
end

ActivityLevelTypeData.GetUnLockHour = function(self, nType, id)
  -- function num : 0_9 , upvalues : _ENV
  if nType == (GameEnum.ActivityLevelType).Explore then
    local dayOpen = (((self.levelTabExplore)[id]).baseData).DayOpen
    local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
    local openTime = self.startTimeRefreshTime + dayOpen * 86400
    local nRemainTime = openTime - nCurTime
    local hour = (math.floor)(nRemainTime / 3600)
    local min = (math.floor)((nRemainTime - hour * 3600) / 60)
    local sec = nRemainTime - hour * 3600 - min * 60
    return hour, min, sec
  else
    do
      local dayOpen = (((self.levelTabAdventure)[id]).baseData).DayOpen
      local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
      local openTime = self.startTimeRefreshTime + dayOpen * 86400
      local nRemainTime = openTime - nCurTime
      local hour = (math.floor)(nRemainTime / 3600)
      local min = (math.floor)((nRemainTime - hour * 3600) / 60)
      do
        local sec = nRemainTime - hour * 3600 - min * 60
        do return hour, min, sec end
        return 1, 0, 0
      end
    end
  end
end

ActivityLevelTypeData.GetLevelUnLock = function(self, nType, id)
  -- function num : 0_10 , upvalues : _ENV
  -- DECOMPILER ERROR at PC13: Unhandled construct in 'MakeBoolean' P1

  if nType == (GameEnum.ActivityLevelType).Explore and (self.levelTabExplore)[id] ~= nil then
    local preLevelId = (((self.levelTabExplore)[id]).baseData).PreLevelId
    if preLevelId == 0 then
      return true
    else
      local preLevelData = (self.levelTabExplore)[preLevelId]
      local preLevelStar = (((self.levelTabExplore)[id]).baseData).PreLevelStar
      if preLevelData and preLevelStar <= preLevelData.Star then
        return true
      end
    end
  end
  do
    if (self.levelTabAdventure)[id] ~= nil then
      local preLevelId = (((self.levelTabAdventure)[id]).baseData).PreLevelId
      if preLevelId == 0 then
        return true
      else
        local preLevelData = (self.levelTabAdventure)[preLevelId]
        if preLevelData == nil then
          preLevelData = (self.levelTabExplore)[preLevelId]
        end
        local preLevelStar = (((self.levelTabAdventure)[id]).baseData).PreLevelStar
        if preLevelData and preLevelStar <= preLevelData.Star then
          return true
        end
      end
    end
    do
      return false
    end
  end
end

ActivityLevelTypeData.GetDefaultSelectionType = function(self)
  -- function num : 0_11 , upvalues : _ENV
  for i,v in pairs(self.levelTabAdventureDifficulty) do
    local isOpen = self:GetLevelDayOpen((GameEnum.ActivityLevelType).Adventure, v)
    local isLevelUnLock = self:GetLevelUnLock((GameEnum.ActivityLevelType).Adventure, v)
    local star = ((self.levelTabAdventure)[v]).Star
    if isOpen and isLevelUnLock and star == 0 then
      return (GameEnum.ActivityLevelType).Adventure
    end
  end
  return (GameEnum.ActivityLevelType).Explore
end

ActivityLevelTypeData.GetDefaultSelectionDifficulty = function(self, nType)
  -- function num : 0_12 , upvalues : _ENV
  local index = 1
  if nType == (GameEnum.ActivityLevelType).Explore then
    for i,v in pairs(self.levelTabExploreDifficulty) do
      local isOpen = self:GetLevelDayOpen(nType, v)
      local isLevelUnLock = self:GetLevelUnLock(nType, v)
      if isOpen and isLevelUnLock then
        index = i
      end
    end
  else
    do
      for i,v in pairs(self.levelTabAdventureDifficulty) do
        local isOpen = self:GetLevelDayOpen(nType, v)
        local isLevelUnLock = self:GetLevelUnLock(nType, v)
        if isOpen and isLevelUnLock then
          index = i
        end
      end
      do
        return index
      end
    end
  end
end

ActivityLevelTypeData.GetLevelFirstPass = function(self, nType, id)
  -- function num : 0_13 , upvalues : _ENV
  -- DECOMPILER ERROR at PC15: Unhandled construct in 'MakeBoolean' P1

  if nType == (GameEnum.ActivityLevelType).Explore and (self.levelTabExplore)[id] ~= nil and ((self.levelTabExplore)[id]).Star >= 1 then
    return true
  end
  if (self.levelTabAdventure)[id] ~= nil and ((self.levelTabAdventure)[id]).Star >= 1 then
    return true
  end
  return false
end

ActivityLevelTypeData.SendEnterActivityLevelsApplyReq = function(self, nActivityId, nLevelId, nBuildId)
  -- function num : 0_14 , upvalues : _ENV
  if nActivityId ~= self.nActId then
    return 
  end
  self.entryLevelId = nLevelId
  self.entryBuildId = nBuildId
  local msg = {}
  msg.ActivityId = nActivityId
  msg.LevelId = nLevelId
  msg.BuildId = nBuildId
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local msgCallback = function(_, msgData)
    -- function num : 0_14_0 , upvalues : self, nBuildId, nLevelId, nActivityId, _ENV
    self:SetCachedSelBuildId(nBuildId, nLevelId)
    self:EnterActivityLevelInstance(nActivityId, nLevelId, nBuildId)
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(msgData)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_levels_apply_req, msg, nil, msgCallback)
end

ActivityLevelTypeData.EnterActivityLevelInstance = function(self, nActivityId, nLevelId, nBuildId)
  -- function num : 0_15 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local luaClass = require("Game.Adventure.ActivityLevels.ActivityLevelsInstanceLevel")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, nActivityId, nLevelId, nBuildId)
  end
end

ActivityLevelTypeData.SendActivityLevelSettleReq = function(self, nActivityId, nStar, callback)
  -- function num : 0_16 , upvalues : _ENV
  if nStar > 0 then
    self:EventUpload(1)
  else
    self:EventUpload(2)
  end
  local msg = {}
  msg.ActivityId = nActivityId
  msg.Star = nStar
  msg.Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).ActivityLevels, nStar > 0)}
  local msgCallback = function(_, msgData)
    -- function num : 0_16_0 , upvalues : callback, self, nStar, _ENV
    -- DECOMPILER ERROR at PC25: Confused about usage of register: R2 in 'UnsetPending'

    if callback ~= nil then
      if (self.levelTabExplore)[self.entryLevelId] then
        if ((self.levelTabExplore)[self.entryLevelId]).Star >= nStar or not nStar then
          ((self.levelTabExplore)[self.entryLevelId]).Star = ((self.levelTabExplore)[self.entryLevelId]).Star
          -- DECOMPILER ERROR at PC30: Confused about usage of register: R2 in 'UnsetPending'

          ;
          ((self.levelTabExplore)[self.entryLevelId]).BuildId = self.entryBuildId
          -- DECOMPILER ERROR at PC53: Confused about usage of register: R2 in 'UnsetPending'

          if (self.levelTabAdventure)[self.entryLevelId] then
            if ((self.levelTabAdventure)[self.entryLevelId]).Star >= nStar or not nStar then
              ((self.levelTabAdventure)[self.entryLevelId]).Star = ((self.levelTabAdventure)[self.entryLevelId]).Star
              -- DECOMPILER ERROR at PC58: Confused about usage of register: R2 in 'UnsetPending'

              ;
              ((self.levelTabAdventure)[self.entryLevelId]).BuildId = self.entryBuildId
              if callback ~= nil then
                local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(msgData.ChangeInfo)
                ;
                (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
                callback(msgData.Fixed, msgData.First, msgData.Exp, msgData.ChangeInfo)
              end
            end
          end
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_levels_settle_req, msg, nil, msgCallback)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

ActivityLevelTypeData.EventUpload = function(self, result)
  -- function num : 0_17 , upvalues : _ENV
  self._EndTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local tabUpLevel = {}
  ;
  (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (table.insert)(tabUpLevel, {"game_cost_time", tostring(self._TotalTime)})
  ;
  (table.insert)(tabUpLevel, {"real_cost_time", tostring(self._EndTime - self._EntryTime)})
  ;
  (table.insert)(tabUpLevel, {"build_id", tostring(self.entryBuildId)})
  ;
  (table.insert)(tabUpLevel, {"battle_id", tostring(self.entryLevelId)})
  ;
  (table.insert)(tabUpLevel, {"battle_result", tostring(result)})
  ;
  (NovaAPI.UserEventUpload)("activity_battle", tabUpLevel)
end

ActivityLevelTypeData.SendActivityLevelsSweepReq = function(self, nActivityId, nLevelId, nTimes, callback)
  -- function num : 0_18 , upvalues : _ENV
  if nActivityId ~= self.nActId then
    return 
  end
  local msg = {}
  msg.ActivityId = self.nActId
  msg.LevelId = nLevelId
  msg.Times = nTimes
  local successCallback = function(_, mapMainData)
    -- function num : 0_18_0 , upvalues : _ENV, callback
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMainData.ChangeInfo)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    callback(mapMainData.Rewards, mapMainData.ChangeInfo)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_levels_sweep_req, msg, nil, successCallback)
end

ActivityLevelTypeData.LevelEnd = function(self)
  -- function num : 0_19
  self.curLevel = nil
end

ActivityLevelTypeData.GetCachedBuildId = function(self, nLevelId)
  -- function num : 0_20
  return (self.tabCachedBuildId)[nLevelId] or 0
end

ActivityLevelTypeData.SetCachedSelBuildId = function(self, nBuildId, levelId)
  -- function num : 0_21
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self.tabCachedBuildId)[levelId] = nBuildId
end

ActivityLevelTypeData.GetLevelBuild = function(self, nLevelId)
  -- function num : 0_22
  if (self.levelTabExplore)[nLevelId] then
    if ((self.levelTabExplore)[nLevelId]).BuildId ~= 0 then
      return ((self.levelTabExplore)[nLevelId]).BuildId
    else
      local PreLevelId = (((self.levelTabExplore)[nLevelId]).baseData).PreLevelId
      if PreLevelId ~= 0 then
        return ((self.levelTabExplore)[PreLevelId]).BuildId
      end
    end
  end
  do
    if (self.levelTabAdventure)[nLevelId] then
      if ((self.levelTabAdventure)[nLevelId]).BuildId ~= 0 then
        return ((self.levelTabAdventure)[nLevelId]).BuildId
      else
        local PreLevelId = (((self.levelTabAdventure)[nLevelId]).baseData).PreLevelId
        if PreLevelId ~= 0 then
          if (self.levelTabAdventure)[PreLevelId] then
            return ((self.levelTabAdventure)[PreLevelId]).BuildId
          else
            return ((self.levelTabExplore)[PreLevelId]).BuildId
          end
        end
      end
    end
    do
      return 0
    end
  end
end

ActivityLevelTypeData.GetLevelStar = function(self, nLevelId)
  -- function num : 0_23
  if (self.levelTabExplore)[nLevelId] then
    return ((self.levelTabExplore)[nLevelId]).Star
  end
  if (self.levelTabAdventure)[nLevelId] then
    return ((self.levelTabAdventure)[nLevelId]).Star
  end
  return 0
end

return ActivityLevelTypeData

