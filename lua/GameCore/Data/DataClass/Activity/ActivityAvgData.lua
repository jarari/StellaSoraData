local ActivityAvgData = class("ActivityAvgData")
local File = ((CS.System).IO).File
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
ActivityAvgData.Init = function(self)
  -- function num : 0_0
  self.tbActivityAvgList = {}
  self.tbCachedReadedActAvg = {}
  self.tbActAvgList = {}
  self:ParseConfig()
end

ActivityAvgData.ParseConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.tbFirstNode = {}
  local foreachActivityAvgLevel = function(mapData)
    -- function num : 0_1_0 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self.tbActivityAvgList)[mapData.ActivityId] == nil then
      (self.tbActivityAvgList)[mapData.ActivityId] = {}
    end
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R1 in 'UnsetPending'

    if mapData.PreLevelId == 0 then
      (self.tbFirstNode)[mapData.ActivityId] = mapData.Id
    end
    ;
    (table.insert)((self.tbActivityAvgList)[mapData.ActivityId], mapData.Id)
  end

  ForEachTableLine((ConfigTable.Get)("ActivityAvgLevel"), foreachActivityAvgLevel)
end

ActivityAvgData.CacheActivityAvgData = function(self, msgData)
  -- function num : 0_2
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbActAvgList)[msgData.Id] == nil then
    (self.tbActAvgList)[msgData.Id] = {}
  end
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R2 in 'UnsetPending'

  ;
  ((self.tbActAvgList)[msgData.Id]).nOpenTime = msgData.StartTime
  -- DECOMPILER ERROR at PC18: Confused about usage of register: R2 in 'UnsetPending'

  ;
  ((self.tbActAvgList)[msgData.Id]).nEndTime = msgData.EndTime
end

ActivityAvgData.RefreshActivityAvgData = function(self, nActId, msgData)
  -- function num : 0_3 , upvalues : _ENV
  -- DECOMPILER ERROR at PC2: Confused about usage of register: R3 in 'UnsetPending'

  (self.tbCachedReadedActAvg)[nActId] = {}
  for _,avgId in ipairs(msgData.RewardIds) do
    (table.insert)((self.tbCachedReadedActAvg)[nActId], avgId)
  end
  self:RefreshAvgRedDot()
end

ActivityAvgData.GetStoryIdListByActivityId = function(self, activityId)
  -- function num : 0_4
  if (self.tbActivityAvgList)[activityId] == nil then
    return {}
  end
  local list = self:SortStoryList(activityId)
  return list
end

ActivityAvgData.SortStoryList = function(self, activityId)
  -- function num : 0_5 , upvalues : _ENV
  local list = (self.tbActivityAvgList)[activityId]
  if (self.tbFirstNode)[activityId] == nil then
    return list
  end
  local sortedList = {}
  ;
  (table.insert)(sortedList, (self.tbFirstNode)[activityId])
  for i = 2, #list do
    for _,storyId in ipairs(list) do
      local cfg = (ConfigTable.GetData)("ActivityAvgLevel", storyId)
      if cfg.PreLevelId == sortedList[i - 1] then
        (table.insert)(sortedList, storyId)
        break
      end
    end
  end
  -- DECOMPILER ERROR at PC42: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.tbActivityAvgList)[activityId] = sortedList
  -- DECOMPILER ERROR at PC44: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.tbFirstNode)[activityId] = nil
  return sortedList
end

ActivityAvgData.CalcPersonality = function(self, nId)
  -- function num : 0_6 , upvalues : _ENV
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
    -- function num : 0_6_0
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

ActivityAvgData.IsActivityAvgReaded = function(self, activityId, storyId)
  -- function num : 0_7 , upvalues : _ENV
  if (self.tbCachedReadedActAvg)[activityId] == nil then
    return false
  end
  for _,avgId in ipairs((self.tbCachedReadedActAvg)[activityId]) do
    if avgId == storyId then
      return true
    end
  end
  return false
end

ActivityAvgData.HasActivityData = function(self, activityId)
  -- function num : 0_8
  do return (self.tbActAvgList)[activityId] ~= nil end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

ActivityAvgData.IsActivityAvgUnlock = function(self, activityId, storyId)
  -- function num : 0_9 , upvalues : _ENV
  if (self.tbActAvgList)[activityId] == nil then
    return false
  end
  local cfg = (ConfigTable.GetData)("ActivityAvgLevel", storyId)
  local isPreReaded = self:IsActivityAvgReaded(activityId, cfg.PreLevelId) or cfg.PreLevelId == 0
  local nOpenTime = ((self.tbActAvgList)[activityId]).nOpenTime
  nOpenTime = ((CS.ClientManager).Instance):GetNextRefreshTime(nOpenTime) - 86400
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  local days = (math.floor)((curTime - (nOpenTime)) / 86400)
  do return cfg.DayOpen <= days, isPreReaded, nOpenTime end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

ActivityAvgData.GetActivityOpenTime = function(self, activityId)
  -- function num : 0_10
  if (self.tbActAvgList)[activityId] == nil then
    return 0
  end
  return ((self.tbActAvgList)[activityId]).nOpenTime, ((self.tbActAvgList)[activityId]).nEndTime
end

ActivityAvgData.IsNew = function(self, activityId, storyId)
  -- function num : 0_11
  local isTimeUnlock, isPreReaded, nOpenTime = self:IsActivityAvgUnlock(activityId, storyId)
  if not isTimeUnlock or not isPreReaded then
    return false
  end
  if self:IsActivityAvgReaded(activityId, storyId) then
    return false
  end
  return true
end

ActivityAvgData.GetRecentAcvitityIndex = function(self, activityId)
  -- function num : 0_12
  local list = self:GetStoryIdListByActivityId(activityId)
  if list == nil then
    return 0
  end
  for i = 1, #list do
    if not self:IsActivityAvgReaded(activityId, list[i]) then
      return i
    end
  end
  return 1
end

ActivityAvgData.RefreshAvgRedDot = function(self)
  -- function num : 0_13 , upvalues : _ENV, LocalData
  for k,v in pairs(self.tbActivityAvgList) do
    local actId = k
    if (self.tbActAvgList)[actId] ~= nil then
      for _,avgId in pairs(v) do
        local bInActGroup, nActGroupId = (PlayerData.Activity):IsActivityInActivityGroup(actId)
        if bInActGroup then
          local isClicked = (LocalData.GetPlayerLocalData)("Act_Story_New" .. actId .. avgId)
          local isNew = self:IsNew(actId, avgId)
          local curTime = ((CS.ClientManager).Instance).serverTimeStamp
          local isOpen = curTime < ((self.tbActAvgList)[actId]).nEndTime and ((self.tbActAvgList)[actId]).nOpenTime < curTime
          local actGroupData = (PlayerData.Activity):GetActivityGroupDataById(nActGroupId)
          local bActGroupUnlock = actGroupData:IsUnlock()
          ;
          (RedDotManager.SetValid)(RedDotDefine.Activity_GroupNew_Avg_Group, {nActGroupId, actId, avgId}, isNew and ((isClicked or isOpen) and bActGroupUnlock))
        end
      end
    end
  end
  -- DECOMPILER ERROR: 5 unprocessed JMP targets
end

ActivityAvgData.EnterAvg = function(self, avgId, actId)
  -- function num : 0_14 , upvalues : _ENV, File
  self.CURRENT_STORY_ID = avgId
  self.CURRENT_ACTIVITY_ID = actId
  local mapCfgData_Story = (ConfigTable.GetData)("ActivityAvgLevel", avgId)
  if (NovaAPI.IsEditorPlatform)() == true then
    local nLanIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
    local sRequireRootPath = GetAvgLuaRequireRoot(nLanIdx) .. "Config/"
    local filePath = NovaAPI.ApplicationDataPath .. "/../Lua/" .. sRequireRootPath .. mapCfgData_Story.StoryId .. ".lua"
    if not (File.Exists)(filePath) then
      (EventManager.Hit)(EventId.OpenMessageBox, "找不到AVG配置文件,请检查配置表！，Avg名：" .. mapCfgData_Story.StoryId)
      printError("找不到AVG配置文件,请检查配置表！，Avg名：" .. mapCfgData_Story.StoryId)
      return 
    end
  end
  do
    printLog("进AVG演出了 " .. mapCfgData_Story.StoryId)
    ;
    (EventManager.Add)("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
    ;
    (EventManager.Hit)("StoryDialog_DialogStart", mapCfgData_Story.StoryId)
  end
end

ActivityAvgData.OnEvent_AvgSTEnd = function(self)
  -- function num : 0_15 , upvalues : _ENV
  if not self:IsActivityAvgReaded(self.CURRENT_ACTIVITY_ID, self.CURRENT_STORY_ID) then
    self:SendMsg_STORY_DONE(self.CURRENT_STORY_ID, self.CURRENT_ACTIVITY_ID)
  else
    ;
    (EventManager.Hit)("Activity_Story_Done", false)
  end
  ;
  (EventManager.Remove)("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
  self:RefreshAvgRedDot()
end

ActivityAvgData.SendMsg_STORY_DONE = function(self, nStoryId, nActId)
  -- function num : 0_16 , upvalues : _ENV, TimerManager
  local mapSendMsgData = {ActivityId = nActId, LevelId = nStoryId, 
Events = {
List = {}
}
}
  local func_succ = function(_, mapChangeInfo)
    -- function num : 0_16_0 , upvalues : _ENV, self, nActId, nStoryId, TimerManager
    (table.insert)((self.tbCachedReadedActAvg)[nActId], nStoryId)
    local bHasReward = not mapChangeInfo or not mapChangeInfo.Props or #mapChangeInfo.Props > 0
    if bHasReward then
      local tbItem = {}
      do
        local tbRewardDisplay = (UTILS.DecodeChangeInfo)(mapChangeInfo)
        for _,v in pairs(tbRewardDisplay) do
          for k,value in pairs(v) do
            (table.insert)(tbItem, {Tid = value.Tid, Qty = value.Qty, rewardType = (AllEnum.RewardType).First})
          end
        end
        local AfterRewardDisplay = function()
      -- function num : 0_16_0_0 , upvalues : _ENV
      (EventManager.Hit)("Activity_Story_RewardClosed")
    end

        local delayOpen = function()
      -- function num : 0_16_0_1 , upvalues : _ENV, tbItem, mapChangeInfo, AfterRewardDisplay
      (UTILS.OpenReceiveByDisplayItem)(tbItem, mapChangeInfo, AfterRewardDisplay)
    end

        local nDelayTime = 1.5
        ;
        (EventManager.Hit)(EventId.TemporaryBlockInput, nDelayTime)
        ;
        (TimerManager.Add)(1, nDelayTime, self, delayOpen, true, true, true)
      end
    end
    ;
    (EventManager.Hit)("Activity_Story_Done", bHasReward)
    printLog("通关结算完成")
    if #(self.tbCachedReadedActAvg)[nActId] == #(self.tbActivityAvgList)[nActId] then
      (EventManager.Hit)("ActivityStory_All_Complate")
    end
    self:RefreshAvgRedDot()
    -- DECOMPILER ERROR: 6 unprocessed JMP targets
  end

  printLog("发送通关消息")
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_avg_reward_receive_req, mapSendMsgData, nil, func_succ)
  self.CURRENT_STORY_ID = 0
end

return ActivityAvgData

