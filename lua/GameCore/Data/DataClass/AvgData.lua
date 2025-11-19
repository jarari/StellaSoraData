local AvgData = class("AvgData")
local RapidJson = require("rapidjson")
local LocalData = require("GameCore.Data.LocalData")
local TimerManager = require("GameCore.Timer.TimerManager")
local File = ((CS.System).IO).File
AvgData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.CFG_ChapterStoryNumIds = {}
  self.CFG_Story = {}
  self.CFG_StoryCondition = {}
  self.CFG_StoryEvidence = {}
  self.CFG_ConditionStoryNumIds = {}
  local forEachLine_Story = function(mapLineData)
    -- function num : 0_0_0 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC3: Confused about usage of register: R1 in 'UnsetPending'

    (self.CFG_Story)[mapLineData.StoryId] = mapLineData.Id
    -- DECOMPILER ERROR at PC12: Confused about usage of register: R1 in 'UnsetPending'

    if (self.CFG_ChapterStoryNumIds)[mapLineData.Chapter] == nil then
      (self.CFG_ChapterStoryNumIds)[mapLineData.Chapter] = {}
    end
    -- DECOMPILER ERROR at PC24: Confused about usage of register: R1 in 'UnsetPending'

    if mapLineData.ConditionId ~= "" then
      if (self.CFG_ConditionStoryNumIds)[mapLineData.ConditionId] == nil then
        (self.CFG_ConditionStoryNumIds)[mapLineData.ConditionId] = {}
      end
      ;
      (table.insert)((self.CFG_ConditionStoryNumIds)[mapLineData.ConditionId], mapLineData.Id)
    end
    ;
    (table.insert)((self.CFG_ChapterStoryNumIds)[mapLineData.Chapter], mapLineData.Id)
  end

  local forEachLine_StoryCondition = function(mapLineData)
    -- function num : 0_0_1 , upvalues : self
    -- DECOMPILER ERROR at PC3: Confused about usage of register: R1 in 'UnsetPending'

    (self.CFG_StoryCondition)[mapLineData.ConditionId] = mapLineData.Id
  end

  local forEachLine_StoryEvidence = function(mapLineData)
    -- function num : 0_0_2 , upvalues : self
    -- DECOMPILER ERROR at PC3: Confused about usage of register: R1 in 'UnsetPending'

    (self.CFG_StoryEvidence)[mapLineData.EvId] = mapLineData.Id
  end

  ForEachTableLine(DataTable.Story, forEachLine_Story)
  ForEachTableLine(DataTable.StoryCondition, forEachLine_StoryCondition)
  ForEachTableLine(DataTable.StoryEvidence, forEachLine_StoryEvidence)
  self.tbStoryIds = {}
  self.tbTempStoryIds = {}
  self.tbEvIds = {}
  self.tbTempEvIds = {}
  self.mapChosen = {}
  self.mapTempCL = {}
  self.mapLatest = {}
  self.mapTempLatestCnt = {}
  self.mapPersonality = {}
  self.mapPersonalityFactor = {}
  self.mapTempPersonality = {}
  self.mapTempPersonalityFactor = {}
  self.mapTempPersonalityCnt = {}
  local y, n = true, false
  self.__data = {
[0] = {n, n, n}
, 
[1] = {y, n, n}
, 
[2] = {n, y, n}
, 
[3] = {y, y, n}
, 
[4] = {n, n, y}
, 
[5] = {y, n, y}
, 
[6] = {n, y, y}
, 
[7] = {y, y, y}
}
  self.CURRENT_STORY_ID = 0
  self:CacheEvData()
  ;
  (EventManager.Add)(EventId.UpdateWorldClass, self, self.CheckNewStoryRedDot)
  if AVG_EDITOR == true then
    (EventManager.Add)("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
  end
end

AvgData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)(EventId.UpdateWorldClass, self, self.CheckNewStoryRedDot)
  if AVG_EDITOR == true then
    (EventManager.Remove)("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
  end
end

AvgData.ClearTempData = function(self)
  -- function num : 0_2
  self.tbTempStoryIds = {}
  self.tbTempEvIds = {}
  self.mapTempCL = {}
  self.mapTempLatestCnt = {}
  self.mapTempPersonality = {}
  self.mapTempPersonalityFactor = {}
  self.mapTempPersonalityCnt = {}
  self.CURRENT_STORY_ID = 0
end

AvgData.SafeCheck = function(self)
  -- function num : 0_3 , upvalues : _ENV
  if type(self.tbTempStoryIds) ~= "table" then
    return false
  end
  if #self.tbTempStoryIds <= 0 then
    return false
  end
  local _sStoryId = (self.tbTempStoryIds)[1]
  if type(_sStoryId) ~= "string" then
    return false
  end
  local _nStoryId = (self.CFG_Story)[_sStoryId]
  if type(_nStoryId) ~= "number" then
    return false
  end
  if type(self.CURRENT_STORY_ID) ~= "number" then
    return false
  end
  if _nStoryId ~= self.CURRENT_STORY_ID then
    return false
  end
  local cfgdata = (ConfigTable.GetData_Story)(_nStoryId)
  if cfgdata == nil then
    return false
  end
  return true
end

AvgData.CacheAvgData = function(self, StoryInfo)
  -- function num : 0_4 , upvalues : _ENV, LocalData
  self.tbStoryIds = {}
  self.tbTempStoryIds = {}
  self.tbEvIds = {}
  self.tbTempEvIds = {}
  self.mapChosen = {}
  self.mapTempCL = {}
  self.mapLatest = {}
  self.mapTempLatestCnt = {}
  self.mapPersonality = {}
  self.mapTempPersonality = {}
  self.mapPersonalityFactor = {}
  self.mapTempPersonalityFactor = {}
  self.mapTempPersonalityCnt = {}
  if StoryInfo == nil then
    return 
  end
  if StoryInfo.BuildId then
    self:SetSelBuildId(StoryInfo.BuildId)
  end
  for i,nEvId in ipairs(StoryInfo.Evidences) do
    local cfgData_Evidence = (ConfigTable.GetData)("StoryEvidence", nEvId)
    if cfgData_Evidence ~= nil then
      local sEvid = cfgData_Evidence.EvId
      if (table.indexof)(self.tbEvIds, sEvid) <= 0 then
        (table.insert)(self.tbEvIds, sEvid)
      end
    end
  end
  local func_Parse = function(uint32Value, nType)
    -- function num : 0_4_0
    if nType == 1 then
      return uint32Value & 15
    else
      if nType == 2 then
        return (uint32Value & 240) >> 4
      else
        if nType == 3 then
          return (uint32Value & 3840) >> 8
        else
          return 0
        end
      end
    end
  end

  for _,Story in pairs(StoryInfo.Stories) do
    local mapCfgDataStory = (ConfigTable.GetData_Story)(Story.Idx)
    if mapCfgDataStory == nil then
      printError("Stroy Cfg Missing:" .. Story.Idx)
    else
      ;
      (table.insert)(self.tbStoryIds, mapCfgDataStory.StoryId)
      local sAvgId = mapCfgDataStory.AvgLuaName
      for __,StoryChoice in pairs(Story.Major) do
        -- DECOMPILER ERROR at PC94: Confused about usage of register: R15 in 'UnsetPending'

        if (self.mapChosen)[sAvgId] == nil then
          (self.mapChosen)[sAvgId] = {}
        end
        -- DECOMPILER ERROR at PC101: Confused about usage of register: R15 in 'UnsetPending'

        if (self.mapLatest)[sAvgId] == nil then
          (self.mapLatest)[sAvgId] = {}
        end
        -- DECOMPILER ERROR at PC109: Confused about usage of register: R15 in 'UnsetPending'

        ;
        ((self.mapChosen)[sAvgId])[StoryChoice.Group] = func_Parse(StoryChoice.Value, 1)
        -- DECOMPILER ERROR at PC117: Confused about usage of register: R15 in 'UnsetPending'

        ;
        ((self.mapLatest)[sAvgId])[StoryChoice.Group] = func_Parse(StoryChoice.Value, 2)
      end
      for __,StoryChoice in pairs(Story.Personality) do
        -- DECOMPILER ERROR at PC130: Confused about usage of register: R15 in 'UnsetPending'

        if (self.mapPersonality)[sAvgId] == nil then
          (self.mapPersonality)[sAvgId] = {}
        end
        -- DECOMPILER ERROR at PC137: Confused about usage of register: R15 in 'UnsetPending'

        if (self.mapPersonalityFactor)[sAvgId] == nil then
          (self.mapPersonalityFactor)[sAvgId] = {}
        end
        -- DECOMPILER ERROR at PC145: Confused about usage of register: R15 in 'UnsetPending'

        ;
        ((self.mapPersonality)[sAvgId])[StoryChoice.Group] = func_Parse(StoryChoice.Value, 2)
        -- DECOMPILER ERROR at PC153: Confused about usage of register: R15 in 'UnsetPending'

        ;
        ((self.mapPersonalityFactor)[sAvgId])[StoryChoice.Group] = func_Parse(StoryChoice.Value, 3)
      end
    end
  end
  do
    if not decodeJson((LocalData.GetPlayerLocalData)("RecentStoryId")) then
      self.mapRecentStoryId = {}
      self:CheckNewStoryRedDot()
    end
  end
end

AvgData.GetChapterStoryNumIds = function(self, nChapterId)
  -- function num : 0_5
  return (self.CFG_ChapterStoryNumIds)[nChapterId]
end

AvgData.GetStoryCfgData = function(self, storyId)
  -- function num : 0_6 , upvalues : _ENV
  local nId = (self.CFG_Story)[storyId]
  return (ConfigTable.GetData_Story)(nId)
end

AvgData.AvgLuaNameToStoryId = function(self, sAvgId)
  -- function num : 0_7 , upvalues : _ENV
  local nId, storyId = nil, nil
  for k,v in pairs(self.CFG_Story) do
    local data = (ConfigTable.GetData_Story)(v)
    if data.AvgLuaName == sAvgId then
      nId = data.Id
      storyId = data.StoryId
      break
    end
  end
  do
    return nId, storyId
  end
end

AvgData.CheckIfTrue = function(self, bIsMajor, sAvgId, nGroupId, nIndex, nCheckount)
  -- function num : 0_8 , upvalues : _ENV
  local n, sCheckTarget = self:AvgLuaNameToStoryId(sAvgId)
  if (table.indexof)(self.tbTempStoryIds, sCheckTarget) > 0 then
    return self:CheckIfTrue_Client(bIsMajor, sAvgId, nGroupId, nIndex, nCheckount)
  else
    return self:CheckIfTrue_Srv(bIsMajor, sAvgId, nGroupId, nIndex)
  end
end

AvgData.CheckIfTrue_Srv = function(self, bIsMajor, sAvgId, nGroupId, nIndex)
  -- function num : 0_9 , upvalues : _ENV
  if AVG_EDITOR == true then
    if self.mapAvgEditorTempData_IsTrueData == nil then
      self.mapAvgEditorTempData_IsTrueData = {}
    end
    local mapA = (self.mapAvgEditorTempData_IsTrueData)[sAvgId]
    if mapA == nil then
      return false
    end
    local sKey = bIsMajor == true and "L" or "X"
    mapA = mapA[sKey]
    if mapA == nil then
      return false
    end
    local _nIndex = mapA[nGroupId]
    if _nIndex == nil then
      return false
    end
    return nIndex == _nIndex
  end
  if bIsMajor ~= true or not self.mapLatest then
    local mapData = self.mapPersonality
  end
  local mapA = mapData[sAvgId]
  if mapA == nil then
    return false
  end
  local nLatestChosenIndex = mapA[nGroupId]
  if nLatestChosenIndex == nil then
    return false
  end
  do return nIndex == nLatestChosenIndex end
  -- DECOMPILER ERROR: 7 unprocessed JMP targets
end

AvgData.CheckIfTrue_Client = function(self, bIsMajor, sAvgId, nGroupId, nIndex, nCheckount)
  -- function num : 0_10
  if bIsMajor ~= true or not self.mapTempLatestCnt then
    local mapData = self.mapTempPersonalityCnt
  end
  local mapA = mapData[sAvgId]
  if mapA == nil then
    return false
  end
  mapA = mapA[nGroupId]
  if mapA == nil then
    return false
  end
  local nCount = mapA[nIndex] or 0
  do return nCheckount <= nCount end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

AvgData.IsUnlock = function(self, sConditionId)
  -- function num : 0_11 , upvalues : _ENV
  if type(sConditionId) == "string" and sConditionId == "" then
    return true
  end
  if AVG_EDITOR == true then
    if self.tbAvgEditorTempData_Unlocked_sConditionIds == nil then
      self.tbAvgEditorTempData_Unlocked_sConditionIds = {}
    end
    return (table.indexof)(self.tbAvgEditorTempData_Unlocked_sConditionIds, sConditionId) > 0
  end
  local nConditionIntId = (self.CFG_StoryCondition)[sConditionId]
  if nConditionIntId == nil then
    printError("Avg数据判断是否解锁时，传了一个excel表里没有的 string id:" .. tostring(sConditionId))
    return false
  end
  local cfgData = (ConfigTable.GetData)("StoryCondition", nConditionIntId)
  if cfgData == nil then
    printError("Avg数据判断是否解锁时，传了一个excel表里没有的 number id:" .. tostring(nConditionIntId))
    return false
  end
  local func_Check = function(tbRequire, tbPlayerData, tbPlayerTempData, bMust)
    -- function num : 0_11_0 , upvalues : _ENV
    if tbRequire == nil then
      return true
    end
    if #tbRequire <= 0 then
      return true
    end
    local bCheckResult, bCheckTempResult, tbCheckResultInfo = bMust, bMust, {}
    for i,v in ipairs(tbRequire) do
      local _b = (table.indexof)(tbPlayerData, v) > 0
      if bCheckResult ~= true or _b ~= true then
        do
          bCheckResult = bMust ~= true
          bCheckResult = bCheckResult == true or _b == true
          tbCheckResultInfo[v] = _b
          -- DECOMPILER ERROR at PC41: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC41: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
    if bCheckResult == false then
      for i,v in ipairs(tbRequire) do
        if (table.indexof)(tbPlayerTempData, v) <= 0 then
          local _b = tbCheckResultInfo[v] == true
          if bCheckTempResult ~= true or _b ~= true then
            do
              bCheckTempResult = bMust ~= true
              bCheckTempResult = bCheckTempResult == true or _b == true
              tbCheckResultInfo[v] = _b
              -- DECOMPILER ERROR at PC77: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC77: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC77: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC77: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
      return bCheckTempResult, tbCheckResultInfo
    else
      return bCheckResult, tbCheckResultInfo
    end
    -- DECOMPILER ERROR: 16 unprocessed JMP targets
  end

  local bMustEvIds, mapMustEvIds = func_Check(cfgData.EvIds_a, self.tbEvIds, self.tbTempEvIds, true)
  local bOneOfEvIds, mapOneOfEvIds = func_Check(cfgData.EvIds_b, self.tbEvIds, self.tbTempEvIds, false)
  local bMustStoryIds, mapMustStoryIds = func_Check(cfgData.StoryId_a, self.tbStoryIds, self.tbTempStoryIds, true)
  local bOneOfStoryIds, mapOneOfStoryIds = func_Check(cfgData.StoryId_b, self.tbStoryIds, self.tbTempStoryIds, false)
  local nNeedWorldLevel = cfgData.PlayerWorldLevel or 0
  local bNeedLv = nNeedWorldLevel <= (PlayerData.Base):GetWorldClass()
  local bMustAchievementIds, mapAchieveInfo = (PlayerData.Achievement):CheckAchieveIds(cfgData.AchieveIds)
  local tbResult = {
{bMustStoryIds, mapMustStoryIds}
, 
{bOneOfStoryIds, mapOneOfStoryIds}
, 
{bMustEvIds, mapMustEvIds}
, 
{bOneOfEvIds, mapOneOfEvIds}
, 
{bNeedLv, nNeedWorldLevel}
, 
{bMustAchievementIds, mapAchieveInfo}
}
  local bResult = bMustEvIds == true and bOneOfEvIds == true and bMustStoryIds == true and bOneOfStoryIds == true and bNeedLv == true and bMustAchievementIds == true
  do return bResult, tbResult end
  -- DECOMPILER ERROR: 8 unprocessed JMP targets
end

AvgData.MarkStoryId = function(self, sAvgId)
  -- function num : 0_12 , upvalues : _ENV
  if AVG_EDITOR ~= true or type(self.CURRENT_STORY_ID) == "number" then
    local cfgdata = (ConfigTable.GetData_Story)(self.CURRENT_STORY_ID)
    if cfgdata == nil then
      return 
    end
  else
    do
      do return  end
      local nId, storyId = self:AvgLuaNameToStoryId(sAvgId)
      if storyId == nil then
        return 
      end
      if (table.indexof)(self.tbTempStoryIds, storyId) <= 0 then
        (table.insert)(self.tbTempStoryIds, storyId)
      end
    end
  end
end

AvgData.MarkEvId = function(self, sId)
  -- function num : 0_13 , upvalues : _ENV
  if (table.indexof)(self.tbTempEvIds, sId) <= 0 and (table.indexof)(self.tbEvIds, sId) <= 0 then
    (table.insert)(self.tbTempEvIds, sId)
  end
end

AvgData.IsChosen = function(self, sAvgId, nGroupId, nIndex)
  -- function num : 0_14 , upvalues : _ENV
  if (self.mapChosen)[sAvgId] == nil then
    return false
  end
  if ((self.mapChosen)[sAvgId])[nGroupId] == nil then
    return false
  end
  local nCurrent = ((self.mapChosen)[sAvgId])[nGroupId]
  local bIsChosen = ((self.__data)[nCurrent])[nIndex]
  -- DECOMPILER ERROR at PC25: Confused about usage of register: R6 in 'UnsetPending'

  if (self.mapTempCL)[sAvgId] == nil then
    (self.mapTempCL)[sAvgId] = {}
  end
  -- DECOMPILER ERROR at PC34: Confused about usage of register: R6 in 'UnsetPending'

  if ((self.mapTempCL)[sAvgId])[nGroupId] == nil then
    ((self.mapTempCL)[sAvgId])[nGroupId] = {}
  end
  local bIsChosen_Temp = (table.indexof)(((self.mapTempCL)[sAvgId])[nGroupId], nIndex) > 0
  do return bIsChosen, bIsChosen_Temp end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

AvgData.MarkChosen = function(self, sAvgId, nGroupId, nIndex)
  -- function num : 0_15 , upvalues : _ENV
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R4 in 'UnsetPending'

  if (self.mapTempCL)[sAvgId] == nil then
    (self.mapTempCL)[sAvgId] = {}
  end
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R4 in 'UnsetPending'

  if ((self.mapTempCL)[sAvgId])[nGroupId] == nil then
    ((self.mapTempCL)[sAvgId])[nGroupId] = {}
  end
  local nTableIndex = (table.indexof)(((self.mapTempCL)[sAvgId])[nGroupId], nIndex)
  if nTableIndex > 0 then
    (table.remove)(((self.mapTempCL)[sAvgId])[nGroupId], nTableIndex)
  end
  ;
  (table.insert)(((self.mapTempCL)[sAvgId])[nGroupId], nIndex)
  -- DECOMPILER ERROR at PC45: Confused about usage of register: R5 in 'UnsetPending'

  if (self.mapTempLatestCnt)[sAvgId] == nil then
    (self.mapTempLatestCnt)[sAvgId] = {}
  end
  -- DECOMPILER ERROR at PC54: Confused about usage of register: R5 in 'UnsetPending'

  if ((self.mapTempLatestCnt)[sAvgId])[nGroupId] == nil then
    ((self.mapTempLatestCnt)[sAvgId])[nGroupId] = {}
  end
  local nCurCnt = (((self.mapTempLatestCnt)[sAvgId])[nGroupId])[nIndex] or 0
  nCurCnt = nCurCnt + 1
  -- DECOMPILER ERROR at PC66: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (((self.mapTempLatestCnt)[sAvgId])[nGroupId])[nIndex] = nCurCnt
end

AvgData.IsEvidenceUnlock = function(self, evidenceId)
  -- function num : 0_16 , upvalues : _ENV
  for k,v in ipairs(self.tbEvIds) do
    if v == evidenceId then
      return true
    end
  end
  return false
end

AvgData.IsStoryReaded = function(self, nStoryId)
  -- function num : 0_17 , upvalues : _ENV
  local cfgData = (ConfigTable.GetData_Story)(nStoryId)
  if cfgData == nil then
    return false
  end
  if (table.indexof)(self.tbStoryIds, cfgData.StoryId) > 0 or (table.indexof)(self.tbTempStoryIds, cfgData.StoryId) > 0 then
    return true
  end
  return false
end

AvgData.GetHistoryChoosedPersonality = function(self, sAvgId, nGroupId)
  -- function num : 0_18 , upvalues : _ENV
  if (self.mapPersonality)[sAvgId] == nil then
    return nil
  end
  if ((self.mapPersonality)[sAvgId])[nGroupId] == nil then
    return nil
  end
  local nValue = ((self.mapPersonality)[sAvgId])[nGroupId]
  local tbData = (self.__data)[nValue]
  for i,v in ipairs(tbData) do
    if v == true then
      return i
    end
  end
  return 0
end

AvgData.MarkChoosedPersonality = function(self, sAvgId, nGroupId, nIndex, nFactor)
  -- function num : 0_19
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R5 in 'UnsetPending'

  if (self.mapTempPersonality)[sAvgId] == nil then
    (self.mapTempPersonality)[sAvgId] = {}
  end
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R5 in 'UnsetPending'

  if (self.mapTempPersonalityFactor)[sAvgId] == nil then
    (self.mapTempPersonalityFactor)[sAvgId] = {}
  end
  local n = 0
  if nIndex == 1 then
    n = 1
  else
    if nIndex == 2 then
      n = 2
    else
      if nIndex == 3 then
        n = 4
      end
    end
  end
  -- DECOMPILER ERROR at PC28: Confused about usage of register: R6 in 'UnsetPending'

  ;
  ((self.mapTempPersonality)[sAvgId])[nGroupId] = n
  -- DECOMPILER ERROR at PC31: Confused about usage of register: R6 in 'UnsetPending'

  ;
  ((self.mapTempPersonalityFactor)[sAvgId])[nGroupId] = nFactor
  -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

  if (self.mapTempPersonalityCnt)[sAvgId] == nil then
    (self.mapTempPersonalityCnt)[sAvgId] = {}
  end
  -- DECOMPILER ERROR at PC47: Confused about usage of register: R6 in 'UnsetPending'

  if ((self.mapTempPersonalityCnt)[sAvgId])[nGroupId] == nil then
    ((self.mapTempPersonalityCnt)[sAvgId])[nGroupId] = {}
  end
  local nCurCnt = (((self.mapTempPersonalityCnt)[sAvgId])[nGroupId])[nIndex] or 0
  nCurCnt = nCurCnt + 1
  -- DECOMPILER ERROR at PC59: Confused about usage of register: R7 in 'UnsetPending'

  ;
  (((self.mapTempPersonalityCnt)[sAvgId])[nGroupId])[nIndex] = nCurCnt
end

AvgData.CalcPersonality = function(self, nId)
  -- function num : 0_20 , upvalues : _ENV
  local cfgData_SRP = (ConfigTable.GetData)("StoryRolePersonality", nId)
  local tbPersonalityBaseNum = cfgData_SRP.BaseValue
  local nTotalCount = tbPersonalityBaseNum[1] + tbPersonalityBaseNum[2] + tbPersonalityBaseNum[3]
  local tbPData = {
{nIndex = 1, nCount = tbPersonalityBaseNum[1], nPercent = 0}
, 
{nIndex = 2, nCount = tbPersonalityBaseNum[2], nPercent = 0}
, 
{nIndex = 3, nCount = tbPersonalityBaseNum[3], nPercent = 0}
}
  local tbPersonality = self.mapPersonality
  local tbPersonalityFactor = self.mapPersonalityFactor
  local nFactor = 1
  for sAvgId,v in pairs(tbPersonality) do
    for nGroupId,vv in pairs(v) do
      nFactor = 1
      nFactor = tbPersonalityFactor[sAvgId] == nil or (tbPersonalityFactor[sAvgId])[nGroupId] or 1
      nTotalCount = nTotalCount + (nFactor)
      local _idx = vv
      if _idx == 4 then
        _idx = 3
      end
      -- DECOMPILER ERROR at PC57: Confused about usage of register: R20 in 'UnsetPending'

      ;
      (tbPData[_idx]).nCount = (tbPData[_idx]).nCount + (nFactor)
    end
  end
  for i,v in ipairs(tbPData) do
    -- DECOMPILER ERROR at PC70: Confused about usage of register: R14 in 'UnsetPending'

    (tbPData[i]).nPercent = (tbPData[i]).nCount / (nTotalCount)
  end
  local tbRetPercent = {(tbPData[1]).nPercent, (tbPData[2]).nPercent, (tbPData[3]).nPercent}
  local sTitle, sFace, sHead = nil, nil, nil
  ;
  (table.sort)(tbPData, function(a, b)
    -- function num : 0_20_0
    do return b.nCount < a.nCount end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  local nMaxIndex = (tbPData[1]).nIndex
  local nMaxPercent = (tbPData[1]).nPercent
  if nMaxPercent >= 0.9 then
    local tbTitle = {cfgData_SRP.Amax, cfgData_SRP.Bmax, cfgData_SRP.Cmax}
    local tbFace = {cfgData_SRP.AmaxFace, cfgData_SRP.BmaxFace, cfgData_SRP.CmaxFace}
    local tbHead = {cfgData_SRP.AmaxHead, cfgData_SRP.BmaxHead, cfgData_SRP.CmaxHead}
    sTitle = tbTitle[nMaxIndex]
    sFace = tbFace[nMaxIndex]
    sHead = tbHead[nMaxIndex]
  else
    do
      if nMaxPercent >= 0.5 then
        local tbTitle = {cfgData_SRP.Aplus, cfgData_SRP.Bplus, cfgData_SRP.Cplus}
        local tbFace = {cfgData_SRP.AplusFace, cfgData_SRP.BplusFace, cfgData_SRP.CplusFace}
        local tbHead = {cfgData_SRP.AplusHead, cfgData_SRP.BplusHead, cfgData_SRP.CplusHead}
        sTitle = tbTitle[nMaxIndex]
        sFace = tbFace[nMaxIndex]
        sHead = tbHead[nMaxIndex]
      else
        do
          if (math.abs)((tbPData[2]).nPercent - (tbPData[3]).nPercent) < 0.1 then
            sTitle = cfgData_SRP.Normal
            sFace = cfgData_SRP.NormalFace
            sHead = cfgData_SRP.NormalHead
          else
            local tbTitleFace = {
{
tbIdxs = {1, 2}
, sTitle = cfgData_SRP.Ab, sFace = cfgData_SRP.AbFace, sHead = cfgData_SRP.AbHead}
, 
{
tbIdxs = {1, 3}
, sTitle = cfgData_SRP.Ac, sFace = cfgData_SRP.AcFace, sHead = cfgData_SRP.AcHead}
, 
{
tbIdxs = {2, 3}
, sTitle = cfgData_SRP.Bc, sFace = cfgData_SRP.BcFace, sHead = cfgData_SRP.BcHead}
}
            local nBiggerIndex = (tbPData[2]).nIndex
            for i,v in ipairs(tbTitleFace) do
              if (table.indexof)(v.tbIdxs, nMaxIndex) > 0 and (table.indexof)(v.tbIdxs, nBiggerIndex) > 0 then
                sTitle = v.sTitle
                sFace = v.sFace
                sHead = v.sHead
                break
              end
            end
          end
          do
            return tbRetPercent, sTitle, sFace, tbPData, nTotalCount, sHead
          end
        end
      end
    end
  end
end

AvgData.SetSelBuildId = function(self, nBuildId)
  -- function num : 0_21
  self.selBuildId = nBuildId
end

AvgData.GetCachedBuildId = function(self)
  -- function num : 0_22
  return self.selBuildId
end

AvgData.GetChapterCount = function(self)
  -- function num : 0_23 , upvalues : _ENV
  local count = 0
  local data = {}
  local forEachChapter = function(mapData)
    -- function num : 0_23_0 , upvalues : count, _ENV, data
    count = count + 1
    ;
    (table.insert)(data, mapData)
  end

  ForEachTableLine(DataTable.StoryChapter, forEachChapter)
  return count, data
end

AvgData.IsStoryChapterUnlock = function(self, nChapterId)
  -- function num : 0_24 , upvalues : _ENV
  local mapStoryData = (ConfigTable.GetData)("StoryChapter", nChapterId)
  if mapStoryData == nil then
    return false
  end
  local nWorldClass = mapStoryData.WorldClass
  local nCurWorldClass = (PlayerData.Base):GetWorldClass()
  if not (ConfigTable.GetUIText)("Story_UnlockWorldLv") then
    do return false, orderedFormat(nCurWorldClass >= nWorldClass or "", nWorldClass) end
    local tbPrevId = nil
    tbPrevId = mapStoryData.PrevStories
    for __,nPrevId in ipairs(tbPrevId) do
      if not self:IsStoryReaded((self.CFG_Story)[nPrevId]) then
        local cfgData = (ConfigTable.GetData_Story)((self.CFG_Story)[nPrevId])
        return false, orderedFormat((ConfigTable.GetUIText)("Story_UnlockPreId") or "", cfgData.Title)
      end
    end
    return true
  end
end

AvgData.SendMsg_STORY_ENTER = function(self, nStoryId, nBuildId, bNewestStory)
  -- function num : 0_25 , upvalues : _ENV, File
  if type(nStoryId) == "string" then
    nStoryId = (self.CFG_Story)[nStoryId]
    if type(nStoryId) ~= "number" then
      return 
    end
  end
  if type(nStoryId) == "number" then
    local cfgdata = (ConfigTable.GetData_Story)(nStoryId)
    if cfgdata == nil then
      return 
    end
  else
    do
      do return  end
      if nBuildId == nil then
        nBuildId = 0
      end
      local func_cb = function()
    -- function num : 0_25_0 , upvalues : self, bNewestStory, nStoryId, nBuildId, _ENV, File
    self:ClearTempData()
    if bNewestStory == true then
      self:SetRecentStoryId(nStoryId)
    end
    if nBuildId ~= 0 then
      self.selBuildId = nBuildId
    end
    self.CURRENT_STORY_ID = nStoryId
    local mapCfgData_Story = (ConfigTable.GetData_Story)(nStoryId)
    if mapCfgData_Story.IsBattle == true then
      local luaClass = require("Game.Adventure.Story.StoryLevel")
      if luaClass == nil then
        return 
      end
      self.curLevel = luaClass
      if type((self.curLevel).BindEvent) == "function" then
        (self.curLevel):BindEvent()
      end
      if type((self.curLevel).Init) == "function" then
        (self.curLevel):Init(self, nStoryId, nBuildId)
      end
      printLog("进战斗关卡了")
    else
      do
        if (NovaAPI.IsEditorPlatform)() == true then
          local nLanIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
          local sRequireRootPath = GetAvgLuaRequireRoot(nLanIdx) .. "Config/"
          local filePath = NovaAPI.ApplicationDataPath .. "/../Lua/" .. sRequireRootPath .. mapCfgData_Story.AvgLuaName .. ".lua"
          if not (File.Exists)(filePath) then
            (EventManager.Hit)(EventId.OpenMessageBox, "找不到AVG配置文件,请检查配置表！，Avg名：" .. mapCfgData_Story.AvgLuaName)
            printError("找不到AVG配置文件,请检查配置表！，Avg名：" .. mapCfgData_Story.AvgLuaName)
            return 
          end
        end
        do
          printLog("进AVG演出了 " .. mapCfgData_Story.AvgLuaName)
          ;
          (EventManager.Add)("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
          ;
          (EventManager.Hit)("StoryDialog_DialogStart", mapCfgData_Story.AvgLuaName, nil, nil, nil, nil, mapCfgData_Story.AvgMotion)
        end
      end
    end
  end

      ;
      (HttpNetHandler.SendMsg)((NetMsgId.Id).story_apply_req, {Idx = nStoryId, BuildId = nBuildId}, nil, func_cb)
    end
  end
end

AvgData.SendMsg_STORY_DONE = function(self, callBack, tbBattleEvents)
  -- function num : 0_26 , upvalues : _ENV, TimerManager
  local mapSendMsgData = {
List = {}
, 
Evidences = {}
, Events = tbBattleEvents == nil and {
List = {}
} or tbBattleEvents}
  local mapStoryCfg = (ConfigTable.GetData_Story)(self.CURRENT_STORY_ID)
  local bBattle = mapStoryCfg.IsBattle
  -- DECOMPILER ERROR at PC25: Confused about usage of register: R6 in 'UnsetPending'

  if bBattle then
    (mapSendMsgData.List)[1] = {Idx = self.CURRENT_STORY_ID}
    if (table.indexof)(self.tbTempStoryIds, mapStoryCfg.StoryId) <= 0 then
      (table.insert)(self.tbTempStoryIds, mapStoryCfg.StoryId)
    end
  else
    if self:SafeCheck() ~= true then
      self:ClearTempData()
      local sErrorLog = "error:"
      for i,v in ipairs(self.tbTempStoryIds) do
        sErrorLog = sErrorLog .. tostring(v) .. ","
      end
      sErrorLog = sErrorLog .. tostring(self.CURRENT_STORY_ID)
      printError(sErrorLog)
      local msg = {nType = (AllEnum.MessageBox).Desc, sContent = sErrorLog, callbackConfirm = nil, bBlur = false}
      ;
      (EventManager.Hit)(EventId.OpenMessageBox, msg)
      return 
    end
    do
      if #self.tbTempStoryIds > 0 then
        for i,sStoryId in ipairs(self.tbTempStoryIds) do
          local nStoryId = (self.CFG_Story)[sStoryId]
          -- DECOMPILER ERROR at PC98: Confused about usage of register: R12 in 'UnsetPending'

          ;
          (mapSendMsgData.List)[i] = {Idx = nStoryId, 
Major = {}
, 
Personality = {}
}
          local mapStoryCfg = (ConfigTable.GetData_Story)(nStoryId)
          if mapStoryCfg ~= nil then
            local sAvgId = mapStoryCfg.AvgLuaName
            local mapGroupData = (self.mapTempCL)[sAvgId]
            if mapGroupData ~= nil then
              for nGroupId,tbChosen in pairs(mapGroupData) do
                for _,nChoiceIndex in ipairs(tbChosen) do
                  local n = 0
                  if nChoiceIndex == 1 then
                    n = 1
                  else
                    if nChoiceIndex == 2 then
                      n = 2
                    else
                      if nChoiceIndex == 3 then
                        n = 4
                      end
                    end
                  end
                  ;
                  (table.insert)(((mapSendMsgData.List)[i]).Major, {Group = nGroupId, Choice = n, Factor = 0})
                end
              end
            end
            do
              mapGroupData = (self.mapTempPersonality)[sAvgId]
              if mapGroupData ~= nil then
                for nGroupId,nLatest in pairs(mapGroupData) do
                  local nFactor = 0
                  nFactor = (self.mapTempPersonalityFactor)[sAvgId] == nil or ((self.mapTempPersonalityFactor)[sAvgId])[nGroupId] or 0
                  ;
                  (table.insert)(((mapSendMsgData.List)[i]).Personality, {Group = nGroupId, Choice = nLatest, Factor = nFactor})
                end
              end
              do
                -- DECOMPILER ERROR at PC175: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC175: LeaveBlock: unexpected jumping out IF_THEN_STMT

                -- DECOMPILER ERROR at PC175: LeaveBlock: unexpected jumping out IF_STMT

              end
            end
          end
        end
      end
      if #self.tbTempEvIds > 0 then
        for _,sEvId in ipairs(self.tbTempEvIds) do
          (table.insert)(mapSendMsgData.Evidences, (self.CFG_StoryEvidence)[sEvId])
        end
      end
      do
        self:CheckNewStoryRedDot()
        do
          local tbPassId = {}
          for _,v in ipairs(mapSendMsgData.List) do
            (table.insert)(tbPassId, v.Idx)
          end
          ;
          (PlayerData.Char):StoryPass(tbPassId)
          local func_merge = function(tbSrc, tbTarget)
    -- function num : 0_26_0 , upvalues : _ENV
    for i,v in ipairs(tbSrc) do
      if (table.indexof)(tbTarget, v) <= 0 then
        (table.insert)(tbTarget, v)
      end
    end
  end

          local func_overwrite = function(tbSrc, tbTarget)
    -- function num : 0_26_1 , upvalues : _ENV
    for sAvgId,v in pairs(tbSrc) do
      if tbTarget[sAvgId] == nil then
        tbTarget[sAvgId] = {}
      end
      for nGroupId,vv in pairs(v) do
        -- DECOMPILER ERROR at PC14: Confused about usage of register: R12 in 'UnsetPending'

        (tbTarget[sAvgId])[nGroupId] = vv
      end
    end
  end

          local func_succ = function(_, mapChangeInfo)
    -- function num : 0_26_2 , upvalues : mapStoryCfg, _ENV, self, func_merge, func_overwrite, callBack, bBattle, TimerManager
    if mapStoryCfg.Chapter == 1 and mapStoryCfg.IsLast and mapChangeInfo and mapChangeInfo.Props and #mapChangeInfo.Props > 0 then
      (PlayerData.Base):UserEventUpload_PC("pc_mainstory_1_clear")
    end
    do
      if mapStoryCfg.Chapter == 2 and mapStoryCfg.IsLast and mapChangeInfo and mapChangeInfo.Props and #mapChangeInfo.Props > 0 then
        local tab = {}
        ;
        (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
        ;
        (NovaAPI.UserEventUpload)("chapter2_complete", tab)
        ;
        (PlayerData.Base):UserEventUpload_PC("pc_mainstory_2_clear")
      end
      do
        if #self.tbTempStoryIds > 1 then
          local nRecentChapterId = (self.CFG_Story)[(self.tbTempStoryIds)[#self.tbTempStoryIds]]
          do
            self:SetRecentStoryId(nRecentChapterId)
          end
        end
        func_merge(self.tbTempStoryIds, self.tbStoryIds)
        self.tbTempStoryIds = {}
        func_merge(self.tbTempEvIds, self.tbEvIds)
        self.tbTempEvIds = {}
        for sAvgId,mapGroupData in pairs(self.mapTempCL) do
          -- DECOMPILER ERROR at PC94: Confused about usage of register: R7 in 'UnsetPending'

          if (self.mapChosen)[sAvgId] == nil then
            (self.mapChosen)[sAvgId] = {}
          end
          for nGroupId,tbChosen in pairs(mapGroupData) do
            -- DECOMPILER ERROR at PC106: Confused about usage of register: R12 in 'UnsetPending'

            if ((self.mapChosen)[sAvgId])[nGroupId] == nil then
              ((self.mapChosen)[sAvgId])[nGroupId] = 0
            end
            local nLen = #tbChosen
            for _,nChoiceIndex in ipairs(tbChosen) do
              local n = 0
              if nChoiceIndex == 1 then
                n = 1
              else
                if nChoiceIndex == 2 then
                  n = 2
                else
                  if nChoiceIndex == 3 then
                    n = 4
                  end
                end
              end
              local nCur = ((self.mapChosen)[sAvgId])[nGroupId]
              -- DECOMPILER ERROR at PC130: Confused about usage of register: R20 in 'UnsetPending'

              ;
              ((self.mapChosen)[sAvgId])[nGroupId] = nCur | n
              -- DECOMPILER ERROR at PC139: Confused about usage of register: R20 in 'UnsetPending'

              if _ == nLen then
                if (self.mapLatest)[sAvgId] == nil then
                  (self.mapLatest)[sAvgId] = {}
                end
                -- DECOMPILER ERROR at PC142: Confused about usage of register: R20 in 'UnsetPending'

                ;
                ((self.mapLatest)[sAvgId])[nGroupId] = n
              end
            end
          end
        end
        self.mapTempCL = {}
        self.mapTempLatestCnt = {}
        func_overwrite(self.mapTempPersonality, self.mapPersonality)
        self.mapTempPersonality = {}
        self.mapTempPersonalityCnt = {}
        func_overwrite(self.mapTempPersonalityFactor, self.mapPersonalityFactor)
        self.mapTempPersonalityFactor = {}
        if callBack ~= nil then
          callBack(mapChangeInfo)
        end
        local bHasReward = not bBattle and not mapChangeInfo or not mapChangeInfo.Props or #mapChangeInfo.Props > 0
        if bHasReward then
          local tbItem = {}
          local tbRewardDisplay = (UTILS.DecodeChangeInfo)(mapChangeInfo)
          for _,v in pairs(tbRewardDisplay) do
            for k,value in pairs(R11_PC200) do
              (table.insert)(tbItem, {Tid = value.Tid, Qty = value.Qty, rewardType = (AllEnum.RewardType).First})
            end
          end
          local AfterRewardDisplay = function()
      -- function num : 0_26_2_0 , upvalues : _ENV
      (EventManager.Hit)("Story_RewardClosed")
    end

          local delayOpen = function()
      -- function num : 0_26_2_1 , upvalues : _ENV, tbItem, mapChangeInfo, AfterRewardDisplay
      (UTILS.OpenReceiveByDisplayItem)(tbItem, mapChangeInfo, AfterRewardDisplay)
    end

          local nDelayTime = 1.5
          ;
          (EventManager.Hit)(EventId.TemporaryBlockInput, nDelayTime)
          ;
          (TimerManager.Add)(1, nDelayTime, self, delayOpen, true, true, true)
        end
        ;
        (EventManager.Hit)("Story_Done", bHasReward)
        printLog("通关结算完成")
        -- DECOMPILER ERROR: 5 unprocessed JMP targets
      end
    end
  end

          printLog("发送通关消息")
          ;
          (HttpNetHandler.SendMsg)((NetMsgId.Id).story_settle_req, mapSendMsgData, nil, func_succ)
          self.CURRENT_STORY_ID = 0
        end
      end
    end
  end
end

AvgData.OnEvent_AvgSTEnd = function(self)
  -- function num : 0_27 , upvalues : _ENV
  if AVG_EDITOR == true then
    self.tbTempStoryIds = {}
    self.tbTempEvIds = {}
    self.mapTempCL = {}
    self.mapTempLatestCnt = {}
    self.mapTempPersonality = {}
    self.mapTempPersonalityCnt = {}
    self.mapTempPersonalityFactor = {}
    return 
  end
  self:SendMsg_STORY_DONE()
  ;
  (EventManager.Remove)("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
end

AvgData.LevelEnd = function(self)
  -- function num : 0_28 , upvalues : _ENV
  (PlayerData.Build):DeleteTrialBuild()
  if type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
end

AvgData.GetLastestStoryId = function(self)
  -- function num : 0_29 , upvalues : _ENV
  local nMax = 101
  for k,v in pairs(self.tbStoryIds) do
    local curIdx = (self.CFG_Story)[v]
    if nMax < curIdx then
      nMax = curIdx
    end
  end
  for k,v in pairs(self.tbTempStoryIds) do
    local curIdx = (self.CFG_Story)[v]
    if nMax < curIdx then
      nMax = curIdx
    end
  end
  return nMax
end

AvgData.GetRecentStoryId = function(self, nChapterId)
  -- function num : 0_30 , upvalues : _ENV
  local nStoryId = (self.mapRecentStoryId)[tostring(nChapterId)]
  if nStoryId == nil then
    local tbChapterList = (self.CFG_ChapterStoryNumIds)[nChapterId]
    if tbChapterList ~= nil then
      (table.sort)(tbChapterList, function(a, b)
    -- function num : 0_30_0
    do return a < b end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
      for i = #tbChapterList, 1, -1 do
        local v = tbChapterList[i]
        if (self.tbStoryIds)[v] then
          nStoryId = v
          break
        end
      end
      do
        do
          local chapterConfig = (ConfigTable.GetData)("StoryChapter", nChapterId)
          nStoryId = chapterConfig.UnlockShowStoryId
          return nStoryId
        end
      end
    end
  end
end

AvgData.SetRecentStoryId = function(self, nStoryId)
  -- function num : 0_31 , upvalues : _ENV, RapidJson, LocalData
  local cfgData = (ConfigTable.GetData_Story)(nStoryId)
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R3 in 'UnsetPending'

  if cfgData ~= nil then
    (self.mapRecentStoryId)[tostring(cfgData.Chapter)] = nStoryId
    local sJson = (RapidJson.encode)(self.mapRecentStoryId)
    printLog(sJson)
    ;
    (LocalData.SetPlayerLocalData)("RecentStoryId", sJson)
  end
end

AvgData.GetRecentChapterId = function(self)
  -- function num : 0_32 , upvalues : _ENV
  local nRecentChapterId = 1
  for k,v in pairs(self.mapRecentStoryId) do
    if nRecentChapterId < tonumber(k) then
      nRecentChapterId = tonumber(k)
    end
  end
  return nRecentChapterId
end

AvgData.CheckNewStoryRedDot = function(self)
  -- function num : 0_33 , upvalues : _ENV
  local _, data = self:GetChapterCount()
  for k,v in ipairs(data) do
    local bHasNew = false
    if self:IsStoryChapterUnlock(v.Id) then
      local tbStoryIds = self:CheckNewStory(v.Id)
      for k,v in pairs(tbStoryIds) do
        if v == true then
          bHasNew = true
          break
        end
      end
    end
    do
      do
        ;
        (RedDotManager.SetValid)(RedDotDefine.Map_MainLine_Chapter, v.Id, bHasNew)
        -- DECOMPILER ERROR at PC32: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
end

AvgData.CheckNewStory = function(self, nChapterId)
  -- function num : 0_34 , upvalues : _ENV
  local tbNewUnlockStorys = {}
  for k,v in ipairs((self.CFG_ChapterStoryNumIds)[nChapterId]) do
    local config = (ConfigTable.GetData)("Story", v)
    local bUnlock = self:IsUnlock(config.ConditionId)
    if bUnlock then
      local bReaded = self:IsStoryReaded(v)
      if not bReaded then
        tbNewUnlockStorys[v] = true
      end
    end
  end
  return tbNewUnlockStorys
end

AvgData.SetNewLockChapterIndex = function(self, chapterIndex)
  -- function num : 0_35
  self.nNewLockChapterIndex = chapterIndex
end

AvgData.GetNewLockChapterIndex = function(self)
  -- function num : 0_36
  if self.nNewLockChapterIndex == nil then
    self.nNewLockChapterIndex = -1
  end
  local tempIndex = self.nNewLockChapterIndex
  self.nNewLockChapterIndex = -1
  return tempIndex
end

AvgData.AvgEditorTempData = function(self, sConditionIds, bAdd)
  -- function num : 0_37 , upvalues : _ENV
  if self.tbAvgEditorTempData_Unlocked_sConditionIds == nil then
    self.tbAvgEditorTempData_Unlocked_sConditionIds = {}
  end
  -- DECOMPILER ERROR at PC10: Unhandled construct in 'MakeBoolean' P1

  if sConditionIds == "all" and bAdd == false then
    self.tbAvgEditorTempData_Unlocked_sConditionIds = {}
  end
  local tbIds = (string.split)(sConditionIds, ",")
  for i,v in ipairs(tbIds) do
    -- DECOMPILER ERROR at PC34: Unhandled construct in 'MakeBoolean' P1

    if bAdd == true and (table.indexof)(self.tbAvgEditorTempData_Unlocked_sConditionIds, v) <= 0 then
      (table.insert)(self.tbAvgEditorTempData_Unlocked_sConditionIds, v)
    end
    local n = (table.indexof)(self.tbAvgEditorTempData_Unlocked_sConditionIds, v)
    if n > 0 then
      (table.remove)(self.tbAvgEditorTempData_Unlocked_sConditionIds, n)
    end
  end
end

AvgData.AvgEditorTempIfTrueData = function(self, sData, bAdd)
  -- function num : 0_38 , upvalues : _ENV
  if self.mapAvgEditorTempData_IsTrueData == nil then
    self.mapAvgEditorTempData_IsTrueData = {}
  end
  -- DECOMPILER ERROR at PC10: Unhandled construct in 'MakeBoolean' P1

  if sData == "all" and bAdd == false then
    self.mapAvgEditorTempData_IsTrueData = {}
  end
  local tbCell = (string.split)(sData, ",")
  local tbChoice = {"A", "B", "C"}
  for i,v in ipairs(tbCell) do
    if v ~= nil and v ~= "" then
      local tbData = (string.split)(v, "-")
      if tbData ~= nil and #tbData == 4 then
        local sAvgId = tbData[1]
        local sKey = tbData[2]
        local nGroupId = tonumber(tbData[3])
        local nIndex = (table.indexof)(tbChoice, tbData[4])
        -- DECOMPILER ERROR at PC56: Confused about usage of register: R15 in 'UnsetPending'

        if (self.mapAvgEditorTempData_IsTrueData)[sAvgId] == nil then
          (self.mapAvgEditorTempData_IsTrueData)[sAvgId] = {}
        end
        -- DECOMPILER ERROR at PC65: Confused about usage of register: R15 in 'UnsetPending'

        if ((self.mapAvgEditorTempData_IsTrueData)[sAvgId])[sKey] == nil then
          ((self.mapAvgEditorTempData_IsTrueData)[sAvgId])[sKey] = {}
        end
        -- DECOMPILER ERROR at PC69: Confused about usage of register: R15 in 'UnsetPending'

        ;
        (((self.mapAvgEditorTempData_IsTrueData)[sAvgId])[sKey])[nGroupId] = nIndex
      end
    end
  end
end

AvgData.CacheEvData = function(self)
  -- function num : 0_39 , upvalues : _ENV
  self.tbEvData = {}
  local forEachLine_Story = function(storConfig)
    -- function num : 0_39_0 , upvalues : self, _ENV
    local sConditionId = storConfig.ConditionId
    if sConditionId == nil then
      return 
    end
    if (self.CFG_StoryCondition)[sConditionId] == nil then
      return 
    end
    local nConditionId = (self.CFG_StoryCondition)[sConditionId]
    local mapConditionData = (ConfigTable.GetData)("StoryCondition", nConditionId)
    local tbEvIds = {}
    if #mapConditionData.EvIds_a > 0 then
      for k,v in ipairs(mapConditionData.EvIds_a) do
        (table.insert)(tbEvIds, v)
      end
    end
    do
      if #mapConditionData.EvIds_b > 0 then
        for k,v in ipairs(mapConditionData.EvIds_b) do
          (table.insert)(tbEvIds, v)
        end
      end
      do
        if #tbEvIds == 0 then
          return 
        end
        for i,v in ipairs(tbEvIds) do
          -- DECOMPILER ERROR at PC61: Confused about usage of register: R10 in 'UnsetPending'

          if (self.tbEvData)[v] == nil then
            (self.tbEvData)[v] = {}
          end
          ;
          (table.insert)((self.tbEvData)[v], storConfig.StoryId)
        end
      end
    end
  end

  ForEachTableLine(DataTable.Story, forEachLine_Story)
end

return AvgData

