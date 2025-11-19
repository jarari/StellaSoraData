local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local ActivityTaskData = class("ActivityTaskData", ActivityDataBase)
local MAPSTATUS = {[0] = (AllEnum.ActQuestStatus).UnComplete, [1] = (AllEnum.ActQuestStatus).Complete, [2] = (AllEnum.ActQuestStatus).Received}
ActivityTaskData.Init = function(self)
  -- function num : 0_0
  self.tbActivityTaskGroupIds = {}
  self.tbActivityTaskIds = {}
  self.mapActivityTaskDatas = {}
  self.mapActivityTaskGroupData = {}
  self:InitConfig()
end

ActivityTaskData.InitConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local func_Parse_ActivityTaskGroup = function(mapData)
    -- function num : 0_1_0 , upvalues : self
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

    if mapData.ActivityId == self.nActId then
      (self.mapActivityTaskGroupData)[mapData.Id] = {}
    end
  end

  ForEachTableLine(DataTable.ActivityTaskGroup, func_Parse_ActivityTaskGroup)
  local func_Parse_ActivityTask = function(mapData)
    -- function num : 0_1_1 , upvalues : self, _ENV
    local nGroupId = mapData.ActivityTaskGroupId
    local nTaskId = mapData.Id
    if (self.mapActivityTaskGroupData)[nGroupId] ~= nil then
      (table.insert)((self.mapActivityTaskGroupData)[nGroupId], nTaskId)
    end
  end

  ForEachTableLine(DataTable.ActivityTask, func_Parse_ActivityTask)
end

ActivityTaskData.CacheData = function(self, mapData)
  -- function num : 0_2 , upvalues : _ENV, MAPSTATUS
  for _,nActivityTaskGroupId in ipairs(mapData.GroupIds) do
    (table.insert)(self.tbActivityTaskGroupIds, nActivityTaskGroupId)
  end
  for _,Quest in ipairs((mapData.ActivityTasks).List) do
    local nActivityTaskId = Quest.Id
    if (table.indexof)(self.tbActivityTaskIds, nActivityTaskId) <= 0 then
      (table.insert)(self.tbActivityTaskIds, nActivityTaskId)
    end
    local _nCur, _nMax = 0, 0
    for __,QuestProgress in ipairs(Quest.Progress) do
      _nCur = _nCur + QuestProgress.Cur
      _nMax = _nMax + QuestProgress.Max
    end
    do
      do
        -- DECOMPILER ERROR at PC56: Confused about usage of register: R10 in 'UnsetPending'

        ;
        (self.mapActivityTaskDatas)[nActivityTaskId] = {nStatus = MAPSTATUS[Quest.Status], nExpire = Quest.Expire, nCur = Quest.Status == 2 and _nMax or _nCur, nMax = _nMax}
        -- DECOMPILER ERROR at PC57: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
  self:RefreshTaskRedDot()
end

ActivityTaskData.RefreshSingleQuest = function(self, questData)
  -- function num : 0_3 , upvalues : _ENV, MAPSTATUS
  if type(self.tbActivityTaskIds) ~= "table" or type(self.mapActivityTaskDatas) ~= "table" then
    return 
  end
  local nActivityTaskId = questData.Id
  if (table.indexof)(self.tbActivityTaskIds, nActivityTaskId) <= 0 then
    (table.insert)(self.tbActivityTaskIds, nActivityTaskId)
  end
  local data = (self.mapActivityTaskDatas)[nActivityTaskId]
  if data == nil then
    local _nCur, _nMax = 0, 0
    for __,QuestProgress in ipairs(questData.Progress) do
      _nCur = _nCur + QuestProgress.Cur
      _nMax = _nMax + QuestProgress.Max
    end
    do
      do
        -- DECOMPILER ERROR at PC55: Confused about usage of register: R6 in 'UnsetPending'

        ;
        (self.mapActivityTaskDatas)[nActivityTaskId] = {nStatus = MAPSTATUS[questData.Status], nExpire = questData.Expire, nCur = questData.Status == 2 and _nMax or _nCur, nMax = _nMax}
        data = (self.mapActivityTaskDatas)[nActivityTaskId]
        data.nStatus = MAPSTATUS[questData.Status]
        local _nCur, _nMax = 0, 0
        for __,QuestProgress in ipairs(questData.Progress) do
          _nCur = _nCur + QuestProgress.Cur
          _nMax = _nMax + QuestProgress.Max
        end
        do
          data.nCur = questData.Status == 2 and _nMax or _nCur
          data.nMax = _nMax
          self:RefreshTaskRedDot()
        end
      end
    end
  end
end

ActivityTaskData.RefreshTaskRedDot = function(self)
  -- function num : 0_4 , upvalues : _ENV
  local bActOpen = self:CheckActivityOpen()
  for nGroupId,tbList in pairs(self.mapActivityTaskGroupData) do
    local nAllCount = #tbList
    local nReceivedCount = 0
    local nCompleteCount = 0
    for _,nTaskId in ipairs(tbList) do
      local mapData = (self.mapActivityTaskDatas)[nTaskId]
      if mapData ~= nil then
        if mapData.nStatus == (AllEnum.ActQuestStatus).Complete then
          nCompleteCount = nCompleteCount + 1
        else
          if mapData.nStatus == (AllEnum.ActQuestStatus).Received then
            nReceivedCount = nReceivedCount + 1
          end
        end
      end
    end
    local bTotalReceived = (table.indexof)(self.tbActivityTaskGroupIds, nGroupId) > 0
    local bHasReward = false
    local mapGroupCfg = (ConfigTable.GetData)("ActivityTaskGroup", nGroupId)
    if mapGroupCfg ~= nil then
      for i = 1, 6 do
        local nTid = mapGroupCfg["Reward" .. i]
        local nCount = mapGroupCfg["RewardQty" .. i]
        if nTid ~= 0 and nCount > 0 then
          bHasReward = true
          break
        end
      end
    end
    if bHasReward == false then
      bTotalReceived = true
    end
    local bCanReceive = nCompleteCount <= 0 and ((nReceivedCount == nAllCount and not bTotalReceived))
    local bInActGroup, nActGroupId = (PlayerData.Activity):IsActivityInActivityGroup(self.nActId)
    local bActGroupUnlock = true
    do
      do
        if bInActGroup then
          local actGroupData = (PlayerData.Activity):GetActivityGroupDataById(nActGroupId)
          bActGroupUnlock = actGroupData:IsUnlock()
        end
        ;
        (RedDotManager.SetValid)(RedDotDefine.Activity_Group_Task_Group, {nActGroupId, self.nActId, nGroupId}, not bCanReceive or not bActOpen or bActGroupUnlock)
        -- DECOMPILER ERROR at PC112: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
  -- DECOMPILER ERROR: 10 unprocessed JMP targets
end

ActivityTaskData.SendMsg_ActivityTaskRewardReceiveReq = function(self, nActivityTaskGroupId, nActivityTaskId, nTabType, ui_ctrl_callback)
  -- function num : 0_5 , upvalues : _ENV
  local mapSend = {}
  mapSend.GroupId = nActivityTaskGroupId
  mapSend.TabType = nTabType
  mapSend.QuestId = nActivityTaskId
  local succ_cb = function(_, mapData)
    -- function num : 0_5_0 , upvalues : _ENV, ui_ctrl_callback
    local receiveCallback = function()
      -- function num : 0_5_0_0 , upvalues : _ENV, ui_ctrl_callback
      if type(ui_ctrl_callback) == "function" then
        ui_ctrl_callback()
      end
    end

    ;
    (UTILS.OpenReceiveByChangeInfo)(mapData, receiveCallback)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_task_reward_receive_req, mapSend, nil, succ_cb)
end

ActivityTaskData.SendMsg_ActivityTaskGroupRewardReceiveReq = function(self, nActivityTaskGroupId, ui_ctrl_callback)
  -- function num : 0_6 , upvalues : _ENV
  local mapSend = {}
  mapSend.Value = nActivityTaskGroupId
  local succ_cb = function(_, mapData)
    -- function num : 0_6_0 , upvalues : _ENV, self, nActivityTaskGroupId, ui_ctrl_callback
    if (table.indexof)(self.tbActivityTaskGroupIds, nActivityTaskGroupId) <= 0 then
      (table.insert)(self.tbActivityTaskGroupIds, nActivityTaskGroupId)
    end
    if type(ui_ctrl_callback) == "function" then
      ui_ctrl_callback()
    end
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapData)
    self:RefreshTaskRedDot()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_task_group_reward_receive_req, mapSend, nil, succ_cb)
end

ActivityTaskData.CalcTotalProgress = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local nDone = 0
  local nTotal = 0
  for k,v in pairs(self.mapActivityTaskDatas) do
    nTotal = nTotal + 1
    if v.nStatus == (AllEnum.ActQuestStatus).Received then
      nDone = nDone + 1
    end
  end
  return nDone, nTotal
end

ActivityTaskData.GetAllTaskList = function(self)
  -- function num : 0_8
  return self.mapActivityTaskGroupData, self.mapActivityTaskDatas
end

return ActivityTaskData

