local ActivityDataBase = require "GameCore.Data.DataClass.Activity.ActivityDataBase"
local ActivityTaskData = class("ActivityTaskData", ActivityDataBase)
local MAPSTATUS = { [0] = AllEnum.ActQuestStatus.UnComplete, [1] = AllEnum.ActQuestStatus.Complete, [2] = AllEnum.ActQuestStatus.Received } -- 服务器的任务状态 0未完成 1完成未领取 2已领取

function ActivityTaskData:Init()
    self.tbActivityTaskGroupIds = {} -- 已领取“组奖励”的组Id （ActivityTaskGroup.xlsx 表中的 Id）
    self.tbActivityTaskIds = {} -- 任务Id数组
    self.mapActivityTaskDatas = {} -- 任务详细数据
    self.mapActivityTaskGroupData = {} -- 任务组数据
    
    self:InitConfig()
end

function ActivityTaskData:InitConfig()
    local function func_Parse_ActivityTaskGroup(mapData)
        if mapData.ActivityId == self.nActId then
            self.mapActivityTaskGroupData[mapData.Id] = {}
        end
    end
    ForEachTableLine(DataTable.ActivityTaskGroup, func_Parse_ActivityTaskGroup)
    
    local func_Parse_ActivityTask = function(mapData)
        local nGroupId = mapData.ActivityTaskGroupId
        local nTaskId = mapData.Id
        if self.mapActivityTaskGroupData[nGroupId] ~= nil then
            table.insert(self.mapActivityTaskGroupData[nGroupId], nTaskId)
        end
    end
    ForEachTableLine(DataTable.ActivityTask, func_Parse_ActivityTask)
end

function ActivityTaskData:CacheData(mapData) -- 详见 public.proto 中的 message ActivityTask
    for _, nActivityTaskGroupId in ipairs(mapData.GroupIds) do
        table.insert(self.tbActivityTaskGroupIds, nActivityTaskGroupId)
    end
    for _, Quest in ipairs(mapData.ActivityTasks.List) do
        local nActivityTaskId = Quest.Id
        if table.indexof(self.tbActivityTaskIds, nActivityTaskId) <= 0 then
            table.insert(self.tbActivityTaskIds, nActivityTaskId)
        end
        local _nCur, _nMax = 0, 0
        for __, QuestProgress in ipairs(Quest.Progress) do
            _nCur = _nCur + QuestProgress.Cur
            _nMax = _nMax + QuestProgress.Max
        end
        self.mapActivityTaskDatas[nActivityTaskId] = {
            nStatus = MAPSTATUS[Quest.Status],
            nExpire = Quest.Expire, -- 过期时间戳，客户端需要自行重置进度，主要用于日常和周常
            -- nType = Quest.Type, -- （似乎没太大用处所以注掉不记录了）
            nCur = (Quest.Status == 2) and _nMax or _nCur,
            nMax = _nMax,
        }
    end
    
    self:RefreshTaskRedDot()
    --[[ printLog("XIA: TEST activity task, CacheData")
    printTable(self.tbActivityTaskGroupIds)
    printTable(self.tbActivityTaskIds)
    printTable(self.mapActivityTaskDatas) ]]
end
function ActivityTaskData:RefreshSingleQuest(questData)
    if type(self.tbActivityTaskIds) ~= "table" or type(self.mapActivityTaskDatas) ~= "table" then
        return
    end
    local nActivityTaskId = questData.Id
    if table.indexof(self.tbActivityTaskIds, nActivityTaskId) <= 0 then
        table.insert(self.tbActivityTaskIds, nActivityTaskId)
    end
    local data = self.mapActivityTaskDatas[nActivityTaskId]
    if data == nil then
        return
    end
    data.nStatus = MAPSTATUS[questData.Status]
    local _nCur, _nMax = 0, 0
    for __, QuestProgress in ipairs(questData.Progress) do
        _nCur = _nCur + QuestProgress.Cur
        _nMax = _nMax + QuestProgress.Max
    end
    data.nCur = (questData.Status == 2) and _nMax or _nCur
    data.nMax = _nMax
    self:RefreshTaskRedDot()
    --[[ printLog("XIA: TEST activity task, RefreshSingleQuest")
    printTable(self.tbActivityTaskGroupIds)
    printTable(self.tbActivityTaskIds)
    printTable(self.mapActivityTaskDatas) ]]
end
--刷新红点
function ActivityTaskData:RefreshTaskRedDot()
    local bActOpen = self:CheckActivityOpen()
    for nGroupId, tbList in pairs(self.mapActivityTaskGroupData) do
        local nAllCount = #tbList
        local nReceivedCount = 0
        local nCompleteCount = 0
        for _, nTaskId in ipairs(tbList) do
            local mapData = self.mapActivityTaskDatas[nTaskId]
            if mapData ~= nil then
                if mapData.nStatus == AllEnum.ActQuestStatus.Complete then
                    nCompleteCount = nCompleteCount + 1
                elseif mapData.nStatus == AllEnum.ActQuestStatus.Received then
                    nReceivedCount = nReceivedCount + 1
                end
            end
        end
        local bTotalReceived = table.indexof(self.tbActivityTaskGroupIds, nGroupId) > 0
        local bCanReceive = nCompleteCount > 0 or (nReceivedCount == nAllCount and not bTotalReceived )
        local bInActGroup,nActGroupId = PlayerData.Activity:IsActivityInActivityGroup(self.nActId)
        local bActGroupUnlock = true
        if bInActGroup then
            local actGroupData = PlayerData.Activity:GetActivityGroupDataById(nActGroupId)
            bActGroupUnlock =  actGroupData:IsUnlock()
        end
        RedDotManager.SetValid(RedDotDefine.Activity_Group_Task_Group, {nActGroupId, self.nActId, nGroupId}, bCanReceive and bActOpen and bActGroupUnlock)
    end
end
function ActivityTaskData:SendMsg_ActivityTaskRewardReceiveReq(nActivityTaskGroupId, nActivityTaskId, nTabType, ui_ctrl_callback) -- 领取单个任务奖励
    local mapSend = {}
    mapSend.GroupId = nActivityTaskGroupId
    mapSend.TabType = nTabType -- GameEnum.ActivityTaskTabType
    mapSend.QuestId = nActivityTaskId
    local succ_cb = function(_, mapData)
        if type(ui_ctrl_callback) == "function" then ui_ctrl_callback() end
        UTILS.OpenReceiveByChangeInfo(mapData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_task_reward_receive_req, mapSend, nil, succ_cb)
end
function ActivityTaskData:SendMsg_ActivityTaskGroupRewardReceiveReq(nActivityTaskGroupId, ui_ctrl_callback) -- 领取任务组（对应一个页签）奖励
    local mapSend = {}
    mapSend.Value = nActivityTaskGroupId
    local succ_cb = function(_, mapData)
        if table.indexof(self.tbActivityTaskGroupIds, nActivityTaskGroupId) <= 0 then table.insert(self.tbActivityTaskGroupIds, nActivityTaskGroupId) end
        if type(ui_ctrl_callback) == "function" then ui_ctrl_callback() end
        UTILS.OpenReceiveByChangeInfo(mapData)
        --刷新红点
        self:RefreshTaskRedDot()
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_task_group_reward_receive_req, mapSend, nil, succ_cb)
end
function ActivityTaskData:CalcTotalProgress()
    local nDone = 0
    local nTotal = 0
    for k, v in pairs(self.mapActivityTaskDatas) do
        nTotal = nTotal + 1
        if v.nStatus == AllEnum.ActQuestStatus.Received then nDone = nDone + 1 end
    end
    -- printLog("XIA: " .. tostring(nDone) .. "," .. tostring(nTotal))
    return nDone, nTotal
end
return ActivityTaskData