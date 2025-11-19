local dailycheckinctrl = require("Game.UI.CheckIn.DailyCheckInCtrl")
local DispatchData = class("DispatchData")
local tbAllDispatchData = {}
local tbWeeklyDispatchDataIds = {}
local tbCompletedDailyDispatchIds = {}
local tbCompletedWeeklyDispatchIds = {}
local bReqApplyAgent = false
local OnEvent_NewDay = function()
  -- function num : 0_0 , upvalues : tbCompletedDailyDispatchIds, _ENV
  tbCompletedDailyDispatchIds = {}
  ;
  (EventManager.Hit)("UpdateDispatchData")
end

local Init = function()
  -- function num : 0_1 , upvalues : _ENV, DispatchData, OnEvent_NewDay
  (EventManager.Add)(EventId.IsNewDay, DispatchData, OnEvent_NewDay)
end

local UnInit = function()
  -- function num : 0_2 , upvalues : _ENV, DispatchData, OnEvent_NewDay
  (EventManager.Remove)(EventId.IsNewDay, DispatchData, OnEvent_NewDay)
end

local CacheDispatchData = function(data)
  -- function num : 0_3 , upvalues : _ENV, tbAllDispatchData, tbCompletedDailyDispatchIds, tbCompletedWeeklyDispatchIds, tbWeeklyDispatchDataIds
  if data == nil or data.Infos == nil then
    return 
  end
  for k,v in pairs(data.Infos) do
    local state = (AllEnum.DispatchState).Accepting
    if v.ProcessTime * 60 + v.StartTime <= ((CS.ClientManager).Instance).serverTimeStamp then
      state = (AllEnum.DispatchState).Complete
    end
    tbAllDispatchData[v.Id] = {Data = v, State = state}
  end
  tbCompletedDailyDispatchIds = data.DailyIds
  tbCompletedWeeklyDispatchIds = data.WeeklyIds
  tbWeeklyDispatchDataIds = data.NewAgentIds
  for i = #tbWeeklyDispatchDataIds, 1, -1 do
    if (table.indexof)(tbCompletedWeeklyDispatchIds, tbWeeklyDispatchDataIds[i]) > 0 then
      (table.remove)(tbWeeklyDispatchDataIds, i)
    end
  end
end

local GetAllDispatchingData = function()
  -- function num : 0_4 , upvalues : tbAllDispatchData
  return tbAllDispatchData
end

local GetAccpectingDispatchCount = function()
  -- function num : 0_5 , upvalues : _ENV, tbAllDispatchData
  local count = 0
  for k,v in pairs(tbAllDispatchData) do
    local agentData = (ConfigTable.GetData)("Agent", (v.Data).Id)
    if agentData.Tab ~= (GameEnum.AgentType).Emergency and (v.State == (AllEnum.DispatchState).Accepting or v.State == (AllEnum.DispatchState).Complete) then
      count = count + 1
    end
  end
  return count
end

local GetDispatchState = function(dispatchId)
  -- function num : 0_6 , upvalues : tbAllDispatchData, _ENV, tbCompletedDailyDispatchIds, tbCompletedWeeklyDispatchIds
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R1 in 'UnsetPending'

  if tbAllDispatchData[dispatchId] ~= nil then
    if ((tbAllDispatchData[dispatchId]).Data).ProcessTime * 60 + ((tbAllDispatchData[dispatchId]).Data).StartTime <= ((CS.ClientManager).Instance).serverTimeStamp then
      (tbAllDispatchData[dispatchId]).State = (AllEnum.DispatchState).Complete
    end
    return (tbAllDispatchData[dispatchId]).State
  end
  if (table.indexof)(tbCompletedDailyDispatchIds, dispatchId) > 0 then
    return (AllEnum.DispatchState).Done
  end
  if (table.indexof)(tbCompletedWeeklyDispatchIds, dispatchId) > 0 then
    return (AllEnum.DispatchState).Done
  end
  return (AllEnum.DispatchState).CanAccept
end

local GetAllTabData = function()
  -- function num : 0_7 , upvalues : _ENV
  local tabDispatchData = {}
  local allTab = (ConfigTable.Get)("AgentTab")
  local foreachAgentTab = function(mapData)
    -- function num : 0_7_0 , upvalues : _ENV, tabDispatchData
    (table.insert)(tabDispatchData, mapData.Id)
  end

  ForEachTableLine(allTab, foreachAgentTab)
  return tabDispatchData
end

local GetAllDispatchItemList = function()
  -- function num : 0_8 , upvalues : _ENV, tbCompletedDailyDispatchIds, tbWeeklyDispatchDataIds, tbAllDispatchData
  local allDispatch = (ConfigTable.Get)("Agent")
  local tbDispatchList = {}
  local foreachAgent = function(mapData)
    -- function num : 0_8_0 , upvalues : _ENV, tbDispatchList, tbCompletedDailyDispatchIds
    if mapData.Tab ~= (GameEnum.AgentType).Emergency then
      if tbDispatchList[mapData.Tab] == nil then
        tbDispatchList[mapData.Tab] = {}
      end
      if mapData.RefreshType ~= (GameEnum.AgentRefreshType).Daily or (table.indexof)(tbCompletedDailyDispatchIds, mapData.Id) <= 0 then
        (table.insert)(tbDispatchList[mapData.Tab], mapData.Id)
      end
    end
  end

  ForEachTableLine(allDispatch, foreachAgent)
  tbDispatchList[(GameEnum.AgentType).Emergency] = tbWeeklyDispatchDataIds
  for k,v in pairs(tbAllDispatchData) do
    local data = (ConfigTable.GetData)("Agent", k)
    if data ~= nil and data.Tab == (GameEnum.AgentType).Emergency and (table.indexof)(tbDispatchList[(GameEnum.AgentType).Emergency], k) < 1 then
      (table.insert)(tbDispatchList[(GameEnum.AgentType).Emergency], data.Id)
    end
  end
  return tbDispatchList
end

local CheckTabUnlock = function(tabIndex, dispatchListData)
  -- function num : 0_9 , upvalues : _ENV
  local txtLockCondition = ""
  local bDispatchUnlock = false
  if dispatchListData == nil then
    dispatchListData = {}
    local foreachAgent = function(mapData)
    -- function num : 0_9_0 , upvalues : tabIndex, _ENV, dispatchListData
    if mapData.Tab == tabIndex then
      (table.insert)(dispatchListData, mapData.Id)
    end
  end

    ForEachTableLine((ConfigTable.Get)("Agent"), foreachAgent)
  end
  do
    for k,v in pairs(dispatchListData) do
      bDispatchUnlock = ((PlayerData.Dispatch).CheckDispatchItemUnlock)(v)
      if bDispatchUnlock then
        return true
      end
    end
    return bDispatchUnlock, txtLockCondition
  end
end

local GetDispatchCharList = function(dispatchId)
  -- function num : 0_10 , upvalues : tbAllDispatchData
  if tbAllDispatchData[dispatchId] then
    return ((tbAllDispatchData[dispatchId]).Data).CharIds
  end
  return {}
end

local GetDispatchBuildData = function(dispatchId, callback)
  -- function num : 0_11 , upvalues : tbAllDispatchData, _ENV
  local _mapAllBuild = {}
  local buildId = -1
  if tbAllDispatchData[dispatchId] ~= nil then
    buildId = ((tbAllDispatchData[dispatchId]).Data).BuildId
  end
  local GetDataCallback = function(tbBuildData, mapAllBuild)
    -- function num : 0_11_0 , upvalues : _mapAllBuild, callback, buildId
    _mapAllBuild = mapAllBuild
    if callback ~= nil then
      callback(_mapAllBuild[buildId])
    end
  end

  ;
  (PlayerData.Build):GetAllBuildBriefData(GetDataCallback)
end

local CheckDispatchItemUnlock = function(dispatchId)
  -- function num : 0_12 , upvalues : _ENV
  local agentData = (ConfigTable.GetData)("Agent", dispatchId)
  local tbCond = decodeJson(agentData.UnlockConditions)
  if tbCond == nil then
    return true
  else
    for _,tbCondInfo in ipairs(tbCond) do
      if tbCondInfo[1] == 1 then
        local nCondLevelId = tbCondInfo[2]
        if (table.indexof)((PlayerData.StarTower).tbPassedId, nCondLevelId) < 1 then
          return false, nCondLevelId, tbCondInfo[2]
        end
      else
        do
          if tbCondInfo[1] == 2 then
            local nWorldCalss = (PlayerData.Base):GetWorldClass()
            local nCondClass = tbCondInfo[2]
            if nWorldCalss < nCondClass then
              return false, orderedFormat((ConfigTable.GetUIText)("Agent_Cond_WorldClass"), nCondClass), tbCondInfo[2]
            end
          else
            do
              if tbCondInfo[1] == 3 then
                local nCondLevelId = tbCondInfo[2]
                if not (PlayerData.Avg):IsStoryReaded(nCondLevelId) then
                  local config = (ConfigTable.GetData)("Story", nCondLevelId)
                  return false, orderedFormat((ConfigTable.GetUIText)("Plot_Limit_MainLine") or "", config.Index), tbCondInfo[2]
                end
              end
              do
                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out IF_STMT

                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out IF_STMT

              end
            end
          end
        end
      end
    end
  end
  return true
end

local GetCharOrBuildState = function(id)
  -- function num : 0_13 , upvalues : tbAllDispatchData, _ENV
  if tbAllDispatchData ~= nil then
    for k,v in pairs(tbAllDispatchData) do
      if (v.Data).CharIds ~= nil then
        for _,charid in ipairs((v.Data).CharIds) do
          if charid == id then
            return (AllEnum.DispatchState).Accepting
          end
        end
      end
      do
        do
          if (v.Data).BuildId == id then
            return (AllEnum.DispatchState).Accepting
          end
          -- DECOMPILER ERROR at PC32: LeaveBlock: unexpected jumping out DO_STMT

        end
      end
    end
  end
  return (AllEnum.DispatchState).CanAccept
end

local GetSameTagCount = function(dispatchId, bBuild, nId, bExtra)
  -- function num : 0_14 , upvalues : _ENV
  local data = (ConfigTable.GetData)("Agent", dispatchId)
  local charTagList = {}
  local count = 0
  if bBuild then
    local _mapAllBuild = {}
    do
      local GetDataCallback = function(tbBuildData, mapAllBuild)
    -- function num : 0_14_0 , upvalues : _mapAllBuild
    _mapAllBuild = mapAllBuild
  end

      ;
      (PlayerData.Build):GetAllBuildBriefData(GetDataCallback)
      local buildData = _mapAllBuild[nId]
      for i = 1, 3 do
        if (buildData.tbChar)[i] ~= nil then
          local mapCharDescCfg = (ConfigTable.GetData)("CharacterDes", ((buildData.tbChar)[i]).nTid)
          for _,v in ipairs(mapCharDescCfg.Tag) do
            (table.insert)(charTagList, v)
          end
        end
      end
    end
  else
    do
      local mapCharDescCfg = (ConfigTable.GetData)("CharacterDes", nId)
      for _,v in ipairs(mapCharDescCfg.Tag) do
        (table.insert)(charTagList, v)
      end
      do
        if not bExtra or not data.ExtraTags then
          local tagList = data.Tags
        end
        for k,v in ipairs(tagList) do
          if (table.indexof)(charTagList, v) > 0 then
            (table.removebyvalue)(charTagList, v)
            count = count + 1
          end
        end
        return count
      end
    end
  end
end

local IsSpecialDispatch = function(dispatchId)
  -- function num : 0_15 , upvalues : _ENV, tbWeeklyDispatchDataIds, tbCompletedDailyDispatchIds, tbCompletedWeeklyDispatchIds
  if (table.indexof)(tbWeeklyDispatchDataIds, dispatchId) > 0 then
    return true
  end
  if (table.indexof)(tbCompletedDailyDispatchIds, dispatchId) > 0 then
    return true
  end
  if (table.indexof)(tbCompletedWeeklyDispatchIds, dispatchId) > 0 then
    return true
  end
  return false
end

local IsBuildDispatching = function(buildId)
  -- function num : 0_16 , upvalues : _ENV, tbAllDispatchData
  for k,v in pairs(tbAllDispatchData) do
    if (v.Data).BuildId == buildId then
      return true
    end
  end
  return false
end

local RandomSpecialPerformance = function(charIds)
  -- function num : 0_17 , upvalues : _ENV
  local tbEligible = {}
  local totalWeight = 0
  local foreachAgentSpecialPerformance = function(mapData)
    -- function num : 0_17_0 , upvalues : charIds, _ENV, totalWeight, tbEligible
    if #mapData.CharId <= #charIds then
      local hasAll = true
      for k,v in ipairs(mapData.CharId) do
        if (table.indexof)(charIds, v) <= 0 then
          hasAll = false
          break
        end
      end
      do
        if hasAll then
          totalWeight = totalWeight + mapData.Weight
          ;
          (table.insert)(tbEligible, {Id = mapData.Id, Weight = totalWeight})
        end
      end
    end
  end

  ForEachTableLine((ConfigTable.Get)("AgentSpecialPerformance"), foreachAgentSpecialPerformance)
  local randomWeight = (math.random)(1, totalWeight)
  for k,v in ipairs(tbEligible) do
    if randomWeight <= v.Weight then
      return v.Id
    end
  end
  if #tbEligible > 0 then
    return (tbEligible[1]).Id
  end
  return -1
end

local CheckReddot = function()
  -- function num : 0_18 , upvalues : _ENV, tbAllDispatchData
  for k,v in pairs(tbAllDispatchData) do
    local dispatchData = (ConfigTable.GetData)("Agent", k)
    local bComplete = (v.Data).ProcessTime * 60 + (v.Data).StartTime <= ((CS.ClientManager).Instance).serverTimeStamp
    ;
    (RedDotManager.SetValid)(RedDotDefine.Dispatch_Reward, {dispatchData.Tab, dispatchData.Id}, bComplete)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

local GetCurrentYearInfo = function(time_s)
  -- function num : 0_19 , upvalues : _ENV
  local day = (os.date)("%d", time_s)
  local weekIndex = (os.date)("%W", time_s)
  local month = (os.date)("%m", time_s)
  local yearNum = (os.date)("%Y", time_s)
  return {year = yearNum, month = month, weekIdx = weekIndex, day = day}
end

local IsSameDay = function(stampA, stampB, resetHour)
  -- function num : 0_20 , upvalues : GetCurrentYearInfo
  if not resetHour then
    resetHour = 5
  end
  local resetSeconds = resetHour * 3600
  stampA = stampA - resetSeconds
  stampB = stampB - resetSeconds
  local dateA = GetCurrentYearInfo(stampA)
  local dateB = GetCurrentYearInfo(stampB)
  do return dateA.day == dateB.day and dateA.month == dateB.month and dateA.year == dateB.year end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

local IsSameWeek = function(stampA, stampB, resetHour)
  -- function num : 0_21 , upvalues : GetCurrentYearInfo
  if not resetHour then
    resetHour = 5
  end
  local resetSeconds = resetHour * 3600
  stampA = stampA - resetSeconds
  stampB = stampB - resetSeconds
  local dateA = GetCurrentYearInfo(stampA)
  local dateB = GetCurrentYearInfo(stampB)
  do return dateA.weekIdx == dateB.weekIdx and dateA.year == dateB.year end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

local ReqApplyAgent = function(agentList, agentData, callback)
  -- function num : 0_22 , upvalues : _ENV, tbAllDispatchData, bReqApplyAgent
  local count = ((PlayerData.Dispatch).GetAccpectingDispatchCount)()
  local maxCount = tonumber((ConfigTable.GetConfigValue)("AgentMaximumQuantity"))
  if maxCount <= count then
    local agentData = agentList[1]
    if agentData ~= nil then
      local configData = (ConfigTable.GetData)("Agent", agentData.Id)
      if configData.Tab ~= (GameEnum.AgentType).Emergency then
        (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Agent_Max_Accepted"))
        return 
      end
    else
      do
        do
          ;
          (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Agent_Max_Accepted"))
          do return  end
          local func_callback = function(_, msgData)
    -- function num : 0_22_0 , upvalues : _ENV, agentData, tbAllDispatchData, callback, bReqApplyAgent
    for k,v in ipairs(msgData.Infos) do
      do
        do
          if agentData[v.Id] ~= nil then
            local agentInfo = {Id = v.Id, StartTime = v.BeginTime, CharIds = (agentData[v.Id]).CharIds, BuildId = (agentData[v.Id]).BuildId, ProcessTime = (agentData[v.Id]).ProcessTime}
            tbAllDispatchData[v.Id] = {Data = agentInfo, State = (AllEnum.DispatchState).Accepting}
          end
          if callback ~= nil then
            callback()
          end
          -- DECOMPILER ERROR at PC38: LeaveBlock: unexpected jumping out DO_STMT

        end
      end
    end
    ;
    (EventManager.Hit)(EventId.DispatchRefreshPanel, (AllEnum.DispatchState).Accepting)
    bReqApplyAgent = false
  end

          local mapData = {Apply = agentList}
          if bReqApplyAgent ~= true then
            (HttpNetHandler.SendMsg)((NetMsgId.Id).agent_apply_req, mapData, nil, func_callback)
          end
          bReqApplyAgent = true
        end
      end
    end
  end
end

local ResetReqLock = function()
  -- function num : 0_23 , upvalues : bReqApplyAgent
  bReqApplyAgent = false
end

local ReqGiveUpAgent = function(dispatchId, callback)
  -- function num : 0_24 , upvalues : tbAllDispatchData, _ENV, IsSameWeek, tbWeeklyDispatchDataIds
  local mapData = {Id = dispatchId}
  local func_callback = function(msgData)
    -- function num : 0_24_0 , upvalues : tbAllDispatchData, dispatchId, _ENV, IsSameWeek, tbWeeklyDispatchDataIds, callback
    if tbAllDispatchData[dispatchId] ~= nil then
      local dispatchData = tbAllDispatchData[dispatchId]
      local dispathcConfig = (ConfigTable.GetData)("Agent", dispatchId)
      local nTime = ((CS.ClientManager).Instance).serverTimeStamp
      if dispathcConfig.RefreshType == (GameEnum.AgentRefreshType).NonRefresh and IsSameWeek((dispatchData.Data).StartTime, nTime, 5) == false and (table.indexof)(tbWeeklyDispatchDataIds, dispatchId) > 0 then
        (table.removebyvalue)(tbWeeklyDispatchDataIds, dispatchId)
      end
      tbAllDispatchData[dispatchId] = nil
    end
    do
      if callback ~= nil then
        callback()
      end
      ;
      (EventManager.Hit)(EventId.DispatchRefreshPanel)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).agent_give_up_req, mapData, nil, func_callback)
end

local ReqReceiveReward = function(dispatchId, callback)
  -- function num : 0_25 , upvalues : _ENV, tbAllDispatchData, tbWeeklyDispatchDataIds, tbCompletedWeeklyDispatchIds, IsSameDay, tbCompletedDailyDispatchIds
  local mapData = {Id = dispatchId}
  local func_callback = function(_, msgData)
    -- function num : 0_25_0 , upvalues : _ENV, tbAllDispatchData, tbWeeklyDispatchDataIds, tbCompletedWeeklyDispatchIds, IsSameDay, tbCompletedDailyDispatchIds, callback
    local data = {}
    local tbSpecialPerformanceId = {}
    local nTime = ((CS.ClientManager).Instance).serverTimeStamp
    for k,v in ipairs(msgData.RewardShows) do
      local dispatchData = (ConfigTable.GetData)("Agent", v.Id)
      local time = tbAllDispatchData[v.Id] ~= nil and ((tbAllDispatchData[v.Id]).Data).ProcessTime or 0
      local Item = {}
      for _,item in ipairs(v.Rewards) do
        -- DECOMPILER ERROR at PC42: Confused about usage of register: R18 in 'UnsetPending'

        if Item[item.Tid] ~= nil then
          (Item[item.Tid]).nCount = (Item[item.Tid]).nCount + item.Qty
        else
          Item[item.Tid] = {nId = item.Tid, nCount = item.Qty, bBonus = false}
        end
      end
      for _,item in ipairs(v.Bonus) do
        -- DECOMPILER ERROR at PC69: Confused about usage of register: R18 in 'UnsetPending'

        if Item[item.Tid] ~= nil then
          (Item[item.Tid]).nCount = (Item[item.Tid]).nCount + item.Qty
        else
          Item[item.Tid] = {nId = item.Tid, nCount = item.Qty, bBonus = true}
        end
      end
      local rewardItem = {}
      for k,v in pairs(Item) do
        (table.insert)(rewardItem, v)
      end
      ;
      (table.insert)(data, {Id = v.Id, CharIds = ((tbAllDispatchData[v.Id]).Data).CharIds, BuildId = ((tbAllDispatchData[v.Id]).Data).BuildId, Name = dispatchData.Name, Time = time, Item = rewardItem})
      if (table.indexof)(tbWeeklyDispatchDataIds, v.Id) > 0 then
        (table.removebyvalue)(tbWeeklyDispatchDataIds, v.Id)
        ;
        (table.insert)(tbCompletedWeeklyDispatchIds, v.Id)
      end
      ;
      (RedDotManager.SetValid)(RedDotDefine.Dispatch_Reward, {dispatchData.Tab, dispatchData.Id}, false)
      if dispatchData.RefreshType == (GameEnum.AgentRefreshType).Daily and IsSameDay(((tbAllDispatchData[v.Id]).Data).StartTime, nTime, 5) then
        printLog("Dispatch:" .. "每日任务完成")
        ;
        (table.insert)(tbCompletedDailyDispatchIds, v.Id)
        ;
        (RedDotManager.UnRegisterNode)(RedDotDefine.Dispatch_Reward, {dispatchData.Tab, dispatchData.Id})
      end
      if #v.SpecialRewards > 0 then
        for _,item in ipairs(v.SpecialRewards) do
          local performanceId = ((PlayerData.Dispatch).RandomSpecialPerformance)(((tbAllDispatchData[v.Id]).Data).CharIds)
          if performanceId > 0 then
            (table.insert)(tbSpecialPerformanceId, {itemId = item.Tid, nCount = item.Qty, performanceId = performanceId})
          end
        end
      end
      do
        do
          if tbAllDispatchData[v.Id] ~= nil then
            tbAllDispatchData[v.Id] = nil
          end
          -- DECOMPILER ERROR at PC212: LeaveBlock: unexpected jumping out DO_STMT

        end
      end
    end
    ;
    (EventManager.Hit)(EventId.DispatchReceiveReward, data, tbSpecialPerformanceId)
    if callback ~= nil then
      callback()
    end
    ;
    (EventManager.Hit)(EventId.DispatchRefreshPanel)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).agent_reward_receive_req, mapData, nil, func_callback)
end

local RefreshWeeklyDispatchs = function(msgData)
  -- function num : 0_26 , upvalues : tbWeeklyDispatchDataIds, tbCompletedWeeklyDispatchIds, _ENV
  if msgData ~= nil then
    tbWeeklyDispatchDataIds = msgData
  end
  for i = #tbCompletedWeeklyDispatchIds, 1, -1 do
    if (table.indexof)(tbWeeklyDispatchDataIds, tbCompletedWeeklyDispatchIds[i]) > 0 then
      (table.remove)(tbCompletedWeeklyDispatchIds, i)
    end
  end
end

local RefreshAgentInfos = function(data)
  -- function num : 0_27 , upvalues : _ENV, tbAllDispatchData
  for k,v in pairs(data.Infos) do
    local state = (AllEnum.DispatchState).Accepting
    if v.ProcessTime * 60 + v.StartTime <= ((CS.ClientManager).Instance).serverTimeStamp then
      state = (AllEnum.DispatchState).Complete
    end
    tbAllDispatchData[v.Id] = {Data = v, State = state}
  end
end

local DispatchData = {Init = Init, UnInit = UnInit, CacheDispatchData = CacheDispatchData, GetAccpectingDispatchCount = GetAccpectingDispatchCount, GetAllDispatchingData = GetAllDispatchingData, GetDispatchState = GetDispatchState, GetAllTabData = GetAllTabData, CheckTabUnlock = CheckTabUnlock, GetAllDispatchItemList = GetAllDispatchItemList, GetDispatchCharList = GetDispatchCharList, GetDispatchBuildData = GetDispatchBuildData, CheckDispatchItemUnlock = CheckDispatchItemUnlock, GetCharOrBuildState = GetCharOrBuildState, GetSameTagCount = GetSameTagCount, IsSpecialDispatch = IsSpecialDispatch, ReqApplyAgent = ReqApplyAgent, ReqGiveUpAgent = ReqGiveUpAgent, ReqReceiveReward = ReqReceiveReward, RefreshWeeklyDispatchs = RefreshWeeklyDispatchs, RandomSpecialPerformance = RandomSpecialPerformance, IsBuildDispatching = IsBuildDispatching, CheckReddot = CheckReddot, IsSameDay = IsSameDay, IsSameWeek = IsSameWeek, ResetReqLock = ResetReqLock, RefreshAgentInfos = RefreshAgentInfos}
return DispatchData

