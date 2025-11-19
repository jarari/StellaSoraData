local ConfigData = require("GameCore.Data.ConfigData")
local AchievementChecker = require("Game.Adventure.AchievementCheck.AchievementChecker")
local PlayerAchievementData = class("PlayerAchievementData")
local Status = {Unreceived = 1, Uncompleted = 2, Received = 3}
PlayerAchievementData.Init = function(self)
  -- function num : 0_0
  self._tbAchievementList = {}
  self._tbTypeCount = {}
  self._tbBattleAchievement = {}
  self._bNeedUpdate = true
  self._tbUnreceivedCountList = {}
  self:InitAchievementData()
end

PlayerAchievementData.InitAchievementData = function(self)
  -- function num : 0_1 , upvalues : Status, _ENV
  local func_ForEach = function(mapCfg)
    -- function num : 0_1_0 , upvalues : self, Status, _ENV
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if not (self._tbAchievementList)[mapCfg.Type] then
      (self._tbAchievementList)[mapCfg.Type] = {}
    end
    local bTime = true
    -- DECOMPILER ERROR at PC27: Confused about usage of register: R2 in 'UnsetPending'

    if bTime then
      ((self._tbAchievementList)[mapCfg.Type])[mapCfg.Id] = {sTime = "", nId = mapCfg.Id, nCur = 0, nMax = mapCfg.AimNumShow, nStatus = Status.Uncompleted, bHide = mapCfg.Hide}
      -- DECOMPILER ERROR at PC52: Confused about usage of register: R2 in 'UnsetPending'

      if not (self._tbTypeCount)[mapCfg.Type] then
        (self._tbTypeCount)[mapCfg.Type] = {nCompleted = 0, nTotal = 0, 
tbRarity = {[(GameEnum.itemRarity).SSR] = 0, [(GameEnum.itemRarity).SR] = 0, [(GameEnum.itemRarity).R] = 0}
}
      end
      -- DECOMPILER ERROR at PC64: Confused about usage of register: R2 in 'UnsetPending'

      if not mapCfg.Hide then
        ((self._tbTypeCount)[mapCfg.Type]).nTotal = ((self._tbTypeCount)[mapCfg.Type]).nTotal + 1
      end
    end
  end

  ForEachTableLine(DataTable.Achievement, func_ForEach)
end

PlayerAchievementData.CacheBattleAchievementData = function(self, sByte)
  -- function num : 0_2 , upvalues : _ENV
  self.tbSpecialBattle = nil
  local tbList = {}
  local tbSpecialBattle = {}
  local tbData = (UTILS.ParseByteString)(sByte)
  local func_ForEach = function(mapLineData)
    -- function num : 0_2_0 , upvalues : _ENV, tbData, tbSpecialBattle, tbList
    do
      if mapLineData.CompleteCondClient > 999 then
        local bCompleted = (UTILS.IsBitSet)(tbData, mapLineData.Id)
        if not bCompleted then
          (table.insert)(tbSpecialBattle, mapLineData.Id)
        end
      end
      if #mapLineData.LevelType > 1 and (table.indexof)(mapLineData.LevelType, (GameEnum.levelType).All) > 0 then
        printError("禁止全部类型和其它关卡类型同时配置！该成就不生效！ID:" .. mapLineData.Id)
      else
        if mapLineData.CompleteCond == (GameEnum.achievementCond).ClientReport and #mapLineData.LevelType > 0 then
          local bCompleted = (UTILS.IsBitSet)(tbData, mapLineData.Id)
          if not bCompleted then
            (table.insert)(tbList, mapLineData.Id)
          end
        end
      end
    end
  end

  ForEachTableLine(DataTable.Achievement, func_ForEach)
  for _,nId in pairs(tbList) do
    local mapCfg = (ConfigTable.GetData)("Achievement", nId)
    for _,nLevelType in ipairs(mapCfg.LevelType) do
      -- DECOMPILER ERROR at PC32: Confused about usage of register: R17 in 'UnsetPending'

      if not (self._tbBattleAchievement)[nLevelType] then
        (self._tbBattleAchievement)[nLevelType] = {}
      end
      ;
      (table.insert)((self._tbBattleAchievement)[nLevelType], nId)
    end
  end
  self.tbSpecialBattle = tbSpecialBattle
end

PlayerAchievementData.SetSpecialBattleAchievement = function(self, nLevelType)
  -- function num : 0_3 , upvalues : _ENV
  local tbCond = {}
  if self.tbSpecialBattle == nil then
    return 
  end
  for _,nId in ipairs(self.tbSpecialBattle) do
    local mapCfg = (ConfigTable.GetData)("Achievement", nId)
    if mapCfg ~= nil and ((table.indexof)(mapCfg.LevelType, (GameEnum.levelType).All) > 0 or (table.indexof)(mapCfg.LevelType, nLevelType) > 0) and (table.indexof)(tbCond, mapCfg.CompleteCondClient) < 1 then
      (table.insert)(tbCond, mapCfg.CompleteCondClient)
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetUnFinishedAchievementInfo, tbCond)
end

PlayerAchievementData.CacheAchievementData = function(self, mapMsgData)
  -- function num : 0_4 , upvalues : _ENV, Status
  self._tbUnreceivedCountList = {}
  for _,mapAchievement in pairs(mapMsgData.List) do
    local mapCfg = (ConfigTable.GetData)("Achievement", mapAchievement.Id)
    local nStatus = self:SetStatus(mapAchievement.Status)
    local nBeforeStatus = (((self._tbAchievementList)[mapCfg.Type])[mapAchievement.Id]).nStatus
    -- DECOMPILER ERROR at PC58: Confused about usage of register: R10 in 'UnsetPending'

    if ((#mapAchievement.Progress <= 0 or not ((mapAchievement.Progress)[1]).Cur) and #mapAchievement.Progress <= 0) or not ((mapAchievement.Progress)[1]).Max then
      ((self._tbAchievementList)[mapCfg.Type])[mapAchievement.Id] = {sTime = (os.date)("%Y/%m/%d", mapAchievement.Completed), nId = mapAchievement.Id, nCur = mapCfg.AimNumShow, nMax = mapCfg.AimNumShow, nStatus = nStatus, bHide = mapCfg.Hide}
      local mapCur = ((self._tbAchievementList)[mapCfg.Type])[mapAchievement.Id]
      -- DECOMPILER ERROR at PC78: Confused about usage of register: R11 in 'UnsetPending'

      if nBeforeStatus ~= nStatus then
        if mapCur.nStatus == Status.Received then
          ((self._tbTypeCount)[mapCfg.Type]).nCompleted = ((self._tbTypeCount)[mapCfg.Type]).nCompleted + 1
          -- DECOMPILER ERROR at PC91: Confused about usage of register: R11 in 'UnsetPending'

          ;
          (((self._tbTypeCount)[mapCfg.Type]).tbRarity)[mapCfg.Rarity] = (((self._tbTypeCount)[mapCfg.Type]).tbRarity)[mapCfg.Rarity] + 1
        end
        -- DECOMPILER ERROR at PC107: Confused about usage of register: R11 in 'UnsetPending'

        if mapCur.bHide and mapCur.nStatus ~= Status.Uncompleted then
          ((self._tbTypeCount)[mapCfg.Type]).nTotal = ((self._tbTypeCount)[mapCfg.Type]).nTotal + 1
        end
        if not (self._tbUnreceivedCountList)[mapCfg.Type] then
          local nCount = mapCur.nStatus ~= Status.Unreceived or 0
        end
        nCount = nCount + 1
        -- DECOMPILER ERROR at PC121: Confused about usage of register: R12 in 'UnsetPending'

        ;
        (self._tbUnreceivedCountList)[mapCfg.Type] = nCount
      end
      do
        -- DECOMPILER ERROR at PC122: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC122: LeaveBlock: unexpected jumping out IF_STMT

      end
    end
  end
end

PlayerAchievementData.GetBattleAchievement = function(self, nLevelType, bBattleSuccess)
  -- function num : 0_5 , upvalues : AchievementChecker, _ENV
  local tbRet = {}
  if (self._tbBattleAchievement)[nLevelType] and #(self._tbBattleAchievement)[nLevelType] > 0 then
    AchievementChecker:CheckBattleAchievement((self._tbBattleAchievement)[nLevelType], tbRet, bBattleSuccess)
  end
  if (self._tbBattleAchievement)[(GameEnum.levelType).All] and #(self._tbBattleAchievement)[(GameEnum.levelType).All] > 0 then
    AchievementChecker:CheckBattleAchievement((self._tbBattleAchievement)[(GameEnum.levelType).All], tbRet, bBattleSuccess)
  end
  return tbRet
end

PlayerAchievementData.GetAchievementTypeCount = function(self, nType)
  -- function num : 0_6
  return (self._tbTypeCount)[nType]
end

PlayerAchievementData.GetAchievementAllTypeCount = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local ret = {nTotal = 0, nCompleted = 0, nSSR = 0, nSR = 0, nR = 0}
  for _,mapCount in pairs(self._tbTypeCount) do
    ret.nTotal = ret.nTotal + mapCount.nTotal
    ret.nCompleted = ret.nCompleted + mapCount.nCompleted
    ret.nSSR = ret.nSSR + (mapCount.tbRarity)[(GameEnum.itemRarity).SSR]
    ret.nSR = ret.nSR + (mapCount.tbRarity)[(GameEnum.itemRarity).SR]
    ret.nR = ret.nR + (mapCount.tbRarity)[(GameEnum.itemRarity).R]
  end
  return ret
end

PlayerAchievementData.GetAchievementTypeList = function(self, nType)
  -- function num : 0_8
  return (self._tbAchievementList)[nType]
end

PlayerAchievementData.GetReceiveList = function(self, nType)
  -- function num : 0_9 , upvalues : _ENV, Status
  local tbId = {}
  for _,mapData in pairs((self._tbAchievementList)[nType]) do
    if mapData.nStatus == Status.Unreceived then
      (table.insert)(tbId, mapData.nId)
    end
  end
  return tbId
end

PlayerAchievementData.JudgeHide = function(self, nType, mapData)
  -- function num : 0_10 , upvalues : Status, _ENV
  local bUncompleted = mapData.nStatus == Status.Uncompleted
  if not bUncompleted then
    return false
  end
  local mapCfg = (ConfigTable.GetData)("Achievement", mapData.nId)
  local bHide = mapData.bHide
  local bPreReceived = true
  if mapCfg ~= nil and #mapCfg.Prerequisites > 0 then
    for _,nId in ipairs(mapCfg.Prerequisites) do
      if (self._tbAchievementList)[nType] == nil or ((self._tbAchievementList)[nType])[nId] == nil then
        printError("AchievementCfg Missing:" .. nId .. "," .. nType)
        break
      end
      if (((self._tbAchievementList)[nType])[nId]).nStatus ~= Status.Received then
        bPreReceived = false
        break
      end
    end
  end
  if not bHide then
    do return not bPreReceived end
    -- DECOMPILER ERROR: 7 unprocessed JMP targets
  end
end

PlayerAchievementData.ChangeAchievementData = function(self, mapAchievement)
  -- function num : 0_11 , upvalues : Status, _ENV
  self:ChangeBattleAchievementData(mapAchievement.Id, mapAchievement.Status)
  local nStatus = self:SetStatus(mapAchievement.Status)
  if nStatus ~= Status.Uncompleted then
    (PlayerData.SideBanner):AddAchievement(mapAchievement.Id)
  end
  if #mapAchievement.Progress == 0 then
    self._bNeedUpdate = true
    return 
  end
  if self._bNeedUpdate then
    return 
  end
  local mapCfg = (ConfigTable.GetData)("Achievement", mapAchievement.Id)
  if mapCfg == nil then
    return 
  end
  -- DECOMPILER ERROR at PC41: Confused about usage of register: R4 in 'UnsetPending'

  if not (self._tbAchievementList)[mapCfg.Type] then
    (self._tbAchievementList)[mapCfg.Type] = {}
  end
  -- DECOMPILER ERROR at PC66: Confused about usage of register: R4 in 'UnsetPending'

  ;
  ((self._tbAchievementList)[mapCfg.Type])[mapAchievement.Id] = {sTime = (os.date)("%Y/%m/%d", mapAchievement.Completed), nId = mapAchievement.Id, nCur = ((mapAchievement.Progress)[1]).Cur, nMax = ((mapAchievement.Progress)[1]).Max, nStatus = nStatus, bHide = mapCfg.Hide}
  local mapCur = ((self._tbAchievementList)[mapCfg.Type])[mapAchievement.Id]
  -- DECOMPILER ERROR at PC96: Confused about usage of register: R5 in 'UnsetPending'

  if not (self._tbTypeCount)[mapCfg.Type] then
    (self._tbTypeCount)[mapCfg.Type] = {nCompleted = 0, nTotal = 0, 
tbRarity = {[(GameEnum.itemRarity).SSR] = 0, [(GameEnum.itemRarity).SR] = 0, [(GameEnum.itemRarity).R] = 0}
}
  end
  -- DECOMPILER ERROR at PC108: Confused about usage of register: R5 in 'UnsetPending'

  if mapCur.bHide then
    ((self._tbTypeCount)[mapCfg.Type]).nTotal = ((self._tbTypeCount)[mapCfg.Type]).nTotal + 1
  end
  if not (self._tbUnreceivedCountList)[mapCfg.Type] then
    local nCount = nStatus ~= Status.Unreceived or 0
  end
  nCount = nCount + 1
  -- DECOMPILER ERROR at PC121: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (self._tbUnreceivedCountList)[mapCfg.Type] = nCount
end

PlayerAchievementData.ChangeBattleAchievementData = function(self, nId, nStatus)
  -- function num : 0_12 , upvalues : Status, _ENV
  if nStatus ~= Status.Unreceived then
    return 
  end
  local mapCfg = (ConfigTable.GetData)("Achievement", nId)
  if mapCfg == nil then
    return 
  end
  if mapCfg.CompleteCond ~= (GameEnum.achievementCond).ClientReport or #mapCfg.LevelType == 0 then
    return 
  end
  do
    if mapCfg.CompleteCondClient > 999 then
      local nIdx = (table.indexof)(self.tbSpecialBattle, nId)
      if nIdx > 0 then
        (table.remove)(self.tbSpecialBattle, nIdx)
      end
    end
    for _,nType in ipairs(mapCfg.LevelType) do
      if (self._tbBattleAchievement)[nType] then
        for key,value in pairs((self._tbBattleAchievement)[nType]) do
          if value == nId then
            (table.remove)((self._tbBattleAchievement)[nType], key)
            break
          end
        end
      end
    end
  end
end

PlayerAchievementData.CheckReddot = function(self)
  -- function num : 0_13 , upvalues : _ENV
  do
    if not (PlayerData.State).bNewAchievement then
      local bRedddot = not self._bNeedUpdate or false
    end
    ;
    (RedDotManager.SetValid)(RedDotDefine.Achievement_Tab, {(GameEnum.achievementType).Overview}, bRedddot)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Achievement_Tab, {(GameEnum.achievementType).Overview}, false)
    for k,v in pairs(self._tbUnreceivedCountList) do
      local bRedddot = v > 0
      ;
      (RedDotManager.SetValid)(RedDotDefine.Achievement_Tab, {k}, bRedddot)
    end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end
end

PlayerAchievementData.CheckAchieveId = function(self, nId)
  -- function num : 0_14 , upvalues : _ENV, Status
  for nAchieveType,mapAchieveInfo in pairs(self._tbAchievementList) do
    for nAchieveId,mapInfo in pairs(mapAchieveInfo) do
      if nAchieveId == nId and mapInfo.nStatus ~= Status.Uncompleted then
        return true
      end
    end
  end
  return false
end

PlayerAchievementData.CheckAchieveIds = function(self, tbIds)
  -- function num : 0_15 , upvalues : _ENV
  local bResult = true
  local mapAchieveInfo = {}
  if tbIds == nil then
    return bResult, mapAchieveInfo
  end
  if #tbIds <= 0 then
    return bResult, mapAchieveInfo
  end
  for i,nId in ipairs(tbIds) do
    mapAchieveInfo[nId] = self:CheckAchieveId(nId)
    bResult = bResult == true and mapAchieveInfo[nId] == true
  end
  do return bResult, mapAchieveInfo end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerAchievementData.GetTimeLimit = function(self, sStart, sEnd)
  -- function num : 0_16
end

PlayerAchievementData.SetStatus = function(self, nStatus)
  -- function num : 0_17 , upvalues : Status
  if nStatus == 0 then
    nStatus = Status.Uncompleted
  else
    if nStatus == 1 then
      nStatus = Status.Unreceived
    else
      if nStatus == 2 then
        nStatus = Status.Received
      end
    end
  end
  return nStatus
end

PlayerAchievementData.UpdateStatus = function(self, tbId, nType)
  -- function num : 0_18 , upvalues : _ENV, Status
  for _,nId in pairs(tbId) do
    local mapCfg = (ConfigTable.GetData)("Achievement", nId)
    -- DECOMPILER ERROR at PC13: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (((self._tbAchievementList)[nType])[nId]).nStatus = Status.Received
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R9 in 'UnsetPending'

    ;
    ((self._tbTypeCount)[nType]).nCompleted = ((self._tbTypeCount)[nType]).nCompleted + 1
    -- DECOMPILER ERROR at PC31: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (((self._tbTypeCount)[nType]).tbRarity)[mapCfg.Rarity] = (((self._tbTypeCount)[nType]).tbRarity)[mapCfg.Rarity] + 1
    local nCount = (self._tbUnreceivedCountList)[nType]
    nCount = (math.max)(0, nCount - 1)
    -- DECOMPILER ERROR at PC41: Confused about usage of register: R10 in 'UnsetPending'

    ;
    (self._tbUnreceivedCountList)[nType] = nCount
  end
end

PlayerAchievementData.SendAchievementInfoReq = function(self, callback)
  -- function num : 0_19 , upvalues : _ENV
  if self._bNeedUpdate then
    self._bNeedUpdate = false
    local successCallback = function(_, mapMainData)
    -- function num : 0_19_0 , upvalues : self, callback
    self:CacheAchievementData(mapMainData)
    callback(mapMainData)
  end

    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).achievement_info_req, {}, nil, successCallback)
  else
    do
      callback()
    end
  end
end

PlayerAchievementData.SendAchievementRewardReq = function(self, tbId, nType, callback)
  -- function num : 0_20 , upvalues : _ENV
  local msgData = {Ids = tbId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_20_0 , upvalues : _ENV, self, tbId, nType, callback
    (UTILS.OpenReceiveByChangeInfo)(mapMainData)
    self:UpdateStatus(tbId, nType)
    ;
    (EventManager.Hit)("AchievementRefresh")
    if callback then
      callback(mapMainData)
    end
    self:CheckReddot()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).achievement_reward_receive_req, msgData, nil, successCallback)
end

return PlayerAchievementData

