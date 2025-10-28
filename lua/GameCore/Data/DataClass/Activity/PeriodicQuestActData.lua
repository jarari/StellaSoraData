--活动：周期任务组
local ActivityDataBase = require "GameCore.Data.DataClass.Activity.ActivityDataBase"
local PeriodicQuestActData = class("PeriodicQuestActData", ActivityDataBase)
local ClientManager = CS.ClientManager.Instance

function PeriodicQuestActData:Init()
    self.tbAllQuestList = {}    --所有任务列表
    self.bFinalStatus = false   -- 最终奖励是否领取
    self.perQuestActCfg = ConfigTable.GetData("PeriodicQuestControl", self.nActId)   --周期任务活动表格数据
    self.nMaxQuestDay = self:GetMaxOpenDay()       -- 活动总任务天数
end

function PeriodicQuestActData:CreateQuest(mapQuestData)
    local tbQuestData = {}
    tbQuestData.Id = mapQuestData.Id
    if nil ~= mapQuestData.Progress[1] then
        tbQuestData.nCurProcess = mapQuestData.Progress[1].Cur
        tbQuestData.nTotalProcess = mapQuestData.Progress[1].Max
    else
        tbQuestData.nCurProcess = 0
        tbQuestData.nTotalProcess = 0
    end
   
    if mapQuestData.Status == 0 then
        tbQuestData.nStatus = AllEnum.ActQuestStatus.UnComplete
    elseif mapQuestData.Status == 1 then
        tbQuestData.nStatus = AllEnum.ActQuestStatus.Complete
    elseif mapQuestData.Status == 2 then
        tbQuestData.nStatus = AllEnum.ActQuestStatus.Received
    end
    local questCfg = ConfigTable.GetData("PeriodicQuest", mapQuestData.Id)
    local nGroupId = questCfg.Groupid
    tbQuestData.nGroupId = nGroupId
    local nDay = CacheTable.GetData("_PeriodicQuestDay", self.nActId)[nGroupId]
    tbQuestData.nDay = nDay
    return tbQuestData
end

function PeriodicQuestActData:RefreshQuestList(mapQuestList)
    for _, v in ipairs(mapQuestList) do
        local tbQuestData = self:CreateQuest(v)
        self.tbAllQuestList[v.Id] = tbQuestData
    end
    self:RefreshRedDot()
end

function PeriodicQuestActData:RefreshQuestData(questData)
    self.tbAllQuestList[questData.Id] = self:CreateQuest(questData)
    self:RefreshRedDot()
    
    local bAllQuestComplete = self:CheckAllQuestComplete()
    ---TODO 埋点
    if bAllQuestComplete then
        ---日服PC埋点---
        PlayerData.Base:UserEventUpload_PC("pc_start_mission_minerva")
        ---日服PC埋点---
    end
end 

function PeriodicQuestActData:RefreshQuestStatus(nQuestId)
    local tbQuestList = {}
    if 0 == nQuestId then
        --一键领取奖励
        for questId, v in pairs(self.tbAllQuestList) do
            if v.nStatus == AllEnum.ActQuestStatus.Complete then
                table.insert(tbQuestList, questId)
                v.nStatus = AllEnum.ActQuestStatus.Received
            end
        end
    else
        if nil ~= self.tbAllQuestList[nQuestId] then
            table.insert(tbQuestList, nQuestId)
            self.tbAllQuestList[nQuestId].nStatus = AllEnum.ActQuestStatus.Received
        end
    end
    self:RefreshRedDot()
    return tbQuestList
end

function PeriodicQuestActData:RefreshFinalStatus(bFinalStatus)
    self.bFinalStatus = bFinalStatus
    self:RefreshRedDot()
end

function PeriodicQuestActData:GetQuestListByGroup()
    local tbQuestList = {}
    for _, v in pairs(self.tbAllQuestList) do
        if nil == tbQuestList[v.nGroupId] then
            tbQuestList[v.nGroupId] = {}
        end
        table.insert(tbQuestList[v.nGroupId], v)
    end
    return tbQuestList
end

function PeriodicQuestActData:GetQuestListByDay()
    local tbQuestList = {}
    for _, v in pairs(self.tbAllQuestList) do
        if nil == tbQuestList[v.nDay] then
            tbQuestList[v.nDay] = {}
        end
        table.insert(tbQuestList[v.nDay], v)
    end
    return tbQuestList
end

--活动当前开启天数
function PeriodicQuestActData:GetCurOpenDay()
    local nMaxDay = CacheTable.GetData("_PeriodicQuestMaxDay", self.nActId)
    if nil == nMaxDay then
        printError("读取PeriodicQuestGroup配置失败！！！actId = "..tostring(self.nActId))
        return 1
    end
    local nCurTime = ClientManager.serverTimeStamp
    local nOpenTime = self.nOpenTime
    local nCurDay = 0
    local nNextRefreshTime = ClientManager:GetNextRefreshTime(nOpenTime)
    while nNextRefreshTime > nOpenTime and nOpenTime < nCurTime and nCurDay <= nMaxDay do
        nOpenTime = nNextRefreshTime
        nCurDay = nCurDay + 1
        nNextRefreshTime = ClientManager:GetNextRefreshTime(nOpenTime)
    end
    nCurDay = math.min(nCurDay, nMaxDay)
    return nCurDay
end

--活动总任务天数
function PeriodicQuestActData:GetMaxOpenDay()
    local nMaxDay = 0
    local groupCfg = CacheTable.GetData("_PeriodicQuestDay", self.nActId)
    if nil ~= groupCfg then
        for _, v in pairs(groupCfg) do
            if v > nMaxDay then
                nMaxDay = v
            end
        end
    end
    return nMaxDay
end

function PeriodicQuestActData:GetCanReceiveRewardGroup()
    local nGroupId = 0
    local nCurDay = self:GetCurOpenDay()
    for _, v in pairs(self.tbAllQuestList) do
        if v.nDay <= nCurDay and v.nStatus == AllEnum.ActQuestStatus.Complete and nGroupId < v.nGroupId then
            nGroupId = v.nGroupId
        end
    end
    return nGroupId
end

function PeriodicQuestActData:GetCanRecRewardDay()
    for _, v in pairs(self.tbAllQuestList) do
        if v.nStatus == AllEnum.ActQuestStatus.Complete then
            return v.nDay
        end
    end
    return 0
end

function PeriodicQuestActData:GetDayQuestStatus(nDay)
    local nAllQuest, nReceivedQuest = 0, 0
    for _, v in pairs(self.tbAllQuestList) do
        if v.nDay == nDay then
            nAllQuest = nAllQuest + 1
            if v.nStatus == AllEnum.ActQuestStatus.Received then
                nReceivedQuest = nReceivedQuest + 1
            end
        end
    end
    return nAllQuest, nReceivedQuest
end

function PeriodicQuestActData:GetNextDayOpenTime()
    local nextRefreshTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
    local nCurTime = CS.ClientManager.Instance.serverTimeStamp
    local nRemainTime = nextRefreshTime - nCurTime
    return math.floor(nRemainTime / 3600)
end

function PeriodicQuestActData:GetPerQuestCfg()
    return self.perQuestActCfg
end

--获取任务进度
function PeriodicQuestActData:GetQuestProgress()
    local curProgress = 0 
    local allProgress = #CacheTable.GetData("_PeriodicQuest", self.nActId)
    local canReceive = 0
    local nCurDay = self:GetCurOpenDay()
    for _, v in pairs(self.tbAllQuestList) do
        if v.nDay <= nCurDay then
            if v.nStatus == AllEnum.ActQuestStatus.Received then
                curProgress = curProgress + 1
            elseif v.nStatus == AllEnum.ActQuestStatus.Complete then
                canReceive = canReceive + 1
            end
        end
    end
    
    return curProgress, allProgress, canReceive
end

--最终奖励是否已领取
function PeriodicQuestActData:CheckFinalReward()
    return self.bFinalStatus
end

--新手引导用，活动任务是否全部完成
function PeriodicQuestActData:CheckAllQuestComplete()
    local bAllComplete = true
    for nId, v in pairs(self.tbAllQuestList) do
        if v.nStatus == AllEnum.ActQuestStatus.UnComplete then
            bAllComplete = false
            break
        end
    end
    return bAllComplete
end

--检查是否有奖励可领取，做红点显示用
function PeriodicQuestActData:RefreshRedDot()
    --检查活动是否已过期
    local bOpen = self:CheckActShow()
    local bQuestReward = false
    local tbGroupStatus = {}
    local nCurDay = self:GetCurOpenDay()
    if nil ~= next(self.tbAllQuestList) then
        for _, v in pairs(self.tbAllQuestList) do
            if v.nDay <= nCurDay then
                if nil == tbGroupStatus[v.nGroupId] then
                    tbGroupStatus[v.nGroupId] = 0
                end
                if v.nStatus == AllEnum.ActQuestStatus.Complete then
                    tbGroupStatus[v.nGroupId] = tbGroupStatus[v.nGroupId] + 1
                    bQuestReward = true
                end
            end
        end

        for group, v in pairs(tbGroupStatus) do
            RedDotManager.SetValid(RedDotDefine.Activity_Periodic_Quest_Group, {self.nActId, group},v > 0 and bOpen)
        end

        local nCur, nAll = self:GetQuestProgress()
        local bFinalReward = nCur >= nAll and not self.bFinalStatus
        RedDotManager.SetValid(RedDotDefine.Activity_Periodic_Final_Reward, self.nActId, bFinalReward and bOpen)
        RedDotManager.SetValid(RedDotDefine.Activity_Tab, self.nActId, (bQuestReward or bFinalReward) and bOpen)
    end
end

--[[
--检查活动奖励是否全部领取
function PeriodicQuestActData:CheckRewardAllReceive()
    local curProgress, allProgress = self:GetQuestProgress()
    if curProgress >= allProgress and self.bFinalStatus then
        return true
    end
    return false
end
]]

return PeriodicQuestActData