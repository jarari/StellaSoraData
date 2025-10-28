--玩家任务数据
local statusOrder = {
    [0] = 1,
    [1] = 2,
    [2] = 0,
}
local PlayerQuestData = class("PlayerQuestData")
local QuestType  = {
    ["Unknown"] = 0,  --无效
    ["TourGuide"] = 1,  --手册任务
    ["Daily"] = 2,  --日常任务
    ["TravelerDuel"] = 3, --旅人对决任务
    ["TravelerDuelChallenge"] = 4, --旅人对决挑战任务
    ["Affinity"] = 5,  --角色好感度任务
    ["BattlePassDaily"] = 6, --战令任务
    ["BattlePassWeekly"] = 7, --战令任务
    ["VampireSurvivorNormal"] = 8; -- 吸血鬼模式普通任务
    ["VampireSurvivorSeason"] = 9; -- 吸血鬼模式赛季任务
    ["Tower"] = 10, --星塔任务
    ["Demon"] = 11, --世界等级突破任务
    ["TowerEvent"] = 12, --星塔事典任务
  }

local QuestRedDotType = {
    ["TourGuide"] = RedDotDefine.Task_Guide,
    ["Daily"] = RedDotDefine.Task_Daily,
    ["TravelerDuel"] = RedDotDefine.Task_Duel,
    ["TravelerDuelChallenge"] = RedDotDefine.Task_Season,
    ["Affinity"] = RedDotDefine.Role_AffinityTask,
    ["Tower"] = RedDotDefine.StarTowerQuest,
}

--    mapQuest = {
--        nTid = number (任务id)
--        nGoal = number (目标数量)
--        nCurProgress = number(当前进度)
--        nStatus = number(0未完成，1已完成，可领取,2已领取奖励)
--        nExpire = number(任务过期时间)
--   }

function PlayerQuestData:Init()
    self._mapQuest = {}
    self.tbDailyActives = {}
    self.nCurTourGroupOrderIndex = 0     -- 当前开放的奖励组Order Index
    self.nMaxTourGroupOrderIndex = 0
    self.tbTourGuideGroup = {}
    self.tbTourGuide = {}
    self:InitConfig()
    EventManager.Add(EventId.IsNewDay, self, self.HandleExpire)
    EventManager.Add(EventId.UpdateWorldClass, self, self.UpdateDailyQuestRedDot)      -- 刷新每日任务红点
end

function PlayerQuestData:UnInit()
    EventManager.Remove(EventId.IsNewDay, self, self.HandleExpire)
    EventManager.Remove(EventId.UpdateWorldClass, self, self.UpdateDailyQuestRedDot)      -- 刷新每日任务红点
end

function PlayerQuestData:InitConfig()
    local function foreachDailyActive(mapData)
        self.tbDailyActives[mapData.Id] = {bReward = false, nActive = mapData.Active}
    end
    ForEachTableLine(DataTable.DailyQuestActive, foreachDailyActive)

    local function foreachTourGroup(mapData)
        table.insert(self.tbTourGuideGroup, mapData)
    end
    ForEachTableLine(DataTable.TourGuideQuestGroup, foreachTourGroup)
    table.sort(self.tbTourGuideGroup, function(a, b)
        return a.Order < b.Order
    end)
    self.nMaxTourGroupOrderIndex = #self.tbTourGuideGroup

    local function foreachTourQuest(mapData)
        if nil == self.tbTourGuide[mapData.Order] then
            self.tbTourGuide[mapData.Order] = {}
        end
        table.insert(self.tbTourGuide[mapData.Order], mapData)
    end
    ForEachTableLine(DataTable.TourGuideQuest, foreachTourQuest)

    local function foreachDemonQuest(line)
        if nil == CacheTable.GetData("_DemonQuest", line.AdvanceGroup) then
            CacheTable.SetData("_DemonQuest", line.AdvanceGroup, {})
        end
        CacheTable.InsertData("_DemonQuest", line.AdvanceGroup, line)
    end
    ForEachTableLine(ConfigTable.Get("DemonQuest"), foreachDemonQuest)
end
function PlayerQuestData:GetAllQuestData()
    local retDaily = {}
    local function sortDaily(a,b)
        if a.nStatus ~= b.nStatus then
            return statusOrder[a.nStatus] > statusOrder[b.nStatus]
        end
        local mapQuestA = ConfigTable.GetData("DailyQuest", a.nTid)
        local mapQuestB = ConfigTable.GetData("DailyQuest", b.nTid)
        return mapQuestA.Order < mapQuestB.Order
    end
    if self._mapQuest[2] ~= nil then
        for _, mapQuest in pairs(self._mapQuest[2]) do
            table.insert(retDaily,mapQuest)
        end
        if #retDaily > 0 then
            table.sort(retDaily,sortDaily)
        end
    end
    
    if self._mapQuest[QuestType["TourGuide"]] == nil and self.nCurTourGroupOrderIndex >= self.nMaxTourGroupOrderIndex then
        --填充最后一组任务数据
        self._mapQuest[QuestType["TourGuide"]] = {}
        local nGroupId = self.tbTourGuideGroup[self.nMaxTourGroupOrderIndex].Id
        local tbQuest = self.tbTourGuide[nGroupId]
        if nil ~= tbQuest then
            for _, v in ipairs(tbQuest) do
                self._mapQuest[QuestType["TourGuide"]][v.Id] = {
                    nTid = v.Id,
                    nGoal = 1,
                    nCurProgress = 1,
                    nStatus = 2,
                    nExpire = 0,
                }
            end
        end
    end
    return retDaily, self._mapQuest[QuestType["TourGuide"]]
end
function PlayerQuestData:CheckTourGroupReward(nIndex)
    return self.nCurTourGroupOrderIndex >= nIndex
end
function PlayerQuestData:GetTourGuideQuestRewardId()
    local tbQuest = self._mapQuest[QuestType["TourGuide"]]
    if tbQuest ~= nil then
        for nId, v in pairs(tbQuest) do
            if v.nStatus == 1 then
                return nId
            end
        end
    end
    return 0
end
function PlayerQuestData:CheckDailyActiveReceive(nActiveId)
    if self.tbDailyActives[nActiveId] ~= nil then
        return self.tbDailyActives[nActiveId].bReward
    end
    return false
end
function PlayerQuestData:GetTravelerDuelQuestData()
    if self._mapQuest[3] == nil then
        self._mapQuest[3] = {}
    end
    return self._mapQuest[3],self._mapQuest[4]
end
function PlayerQuestData:GetBattlePassQuestData()
    if self._mapQuest[6] == nil then
        self._mapQuest[6] = {}
    end
    if self._mapQuest[7] == nil then
        self._mapQuest[7] = {}
    end
    return self._mapQuest[6],self._mapQuest[7]
end
function PlayerQuestData:GetStarTowerBookQuestData()
    if self._mapQuest[12] == nil then
        self._mapQuest[12] = {}
    end
    return self._mapQuest[12]
end
function PlayerQuestData:GetCurTourGroup()
    if self._mapQuest[QuestType["TourGuide"]] == nil then
        return 0
    end
    local nCurIndex = math.min(self.nCurTourGroupOrderIndex + 1, self.nMaxTourGroupOrderIndex)
    local mapCurGroup = self.tbTourGuideGroup[nCurIndex]
    return mapCurGroup.Id
end
function PlayerQuestData:GetCurTourGroupOrder()
    if self._mapQuest[QuestType["TourGuide"]] == nil then
        return 0
    end
    local nCurIndex = math.min(self.nCurTourGroupOrderIndex + 1, self.nMaxTourGroupOrderIndex)
    local mapCurGroup = self.tbTourGuideGroup[nCurIndex]
    return mapCurGroup.Order
end
function PlayerQuestData:GetMaxTourGroup()
    return self.tbTourGuideGroup[self.nMaxTourGroupOrderIndex].Id
end
function PlayerQuestData:GetAffinityQuestData(questId)
    if self._mapQuest[QuestType["Affinity"]] ~= nil then
        if self._mapQuest[QuestType["Affinity"]][questId] ~= nil then
            return self._mapQuest[QuestType["Affinity"]][questId]
        end
    end
    return nil
end
function PlayerQuestData:GetStarTowerQuestData()
    local tbCore, tbNormal = {}, {}
    if not self._mapQuest[QuestType["Tower"]] then
        return tbCore, tbNormal
    end
    for nId, v in pairs(self._mapQuest[QuestType["Tower"]]) do
        local mapCfg = ConfigTable.GetData("StarTowerQuest", nId)
        if mapCfg then
            if v.nStatus ~= 2 then -- 星塔任务不显示已完成的
                if mapCfg.TowerQuestType == GameEnum.TowerQuestType.Core then
                    table.insert(tbCore, v)
                elseif mapCfg.TowerQuestType == GameEnum.TowerQuestType.Normal then
                    table.insert(tbNormal, v)
                end
            end
        end
    end
    local function sort(a,b)
        if a.nStatus ~= b.nStatus then
            return statusOrder[a.nStatus] > statusOrder[b.nStatus]
        elseif a.nTid ~= b.nTid then
            return a.nTid < b.nTid
        end
    end
    if #tbNormal > 0 then
        table.sort(tbNormal, sort)
    end
    return tbCore, tbNormal
end

function PlayerQuestData:ReceiveDemonQuest(nGroupId)
    if self._mapQuest[QuestType["Demon"]] ~= nil then
        for nId, v in pairs(self._mapQuest[QuestType["Demon"]]) do
            local mapCfg = ConfigTable.GetData("DemonQuest", nId)
            if mapCfg ~= nil and mapCfg.AdvanceGroup == nGroupId then
                v.nStatus = 2
            end
        end
    end
end

function PlayerQuestData:GetDemonQuestData(nGroupId, nStageId)
    local tbQuest = {}
    if self._mapQuest[QuestType["Demon"]] == nil then
        self._mapQuest[QuestType["Demon"]] = {}
    end
    for nId, v in pairs(self._mapQuest[QuestType["Demon"]]) do
        local mapCfg = ConfigTable.GetData("DemonQuest", nId)
        if mapCfg ~= nil and mapCfg.AdvanceGroup == nGroupId then
            table.insert(tbQuest, v)
        end
    end

    if #tbQuest == 0 then
        local nCurStageId = PlayerData.Base:GetCurWorldClassStageId()
        local tbAllQuest = CacheTable.GetData("_DemonQuest", nGroupId)
        if tbAllQuest ~= nil and #tbAllQuest > 0 then
            for _, v in ipairs(tbAllQuest) do
                table.insert(tbQuest, {
                    nTid = v.Id,
                    nGoal = 1,
                    nCurProgress = 0,
                    nStatus = nCurStageId > nStageId and 2 or 0,
                    nExpire = 0,
                })
            end
        end
    end
    table.sort(tbQuest, function(a, b)
        if a.nStatus == b.nStatus then
            return a.nTid < b.nTid
        end
        return a.nStatus < b.nStatus
    end)
    return tbQuest
end

function PlayerQuestData:OnQuestProgressChanged(mapData)
    local nCur = mapData.Progress[1] == nil and 0 or mapData.Progress[1].Cur
    print(string.format("任务进度变更 ID:%d 当前进度:%d 当前状态:%d",mapData.Id,nCur,mapData.Status))
    if QuestType[mapData.Type] == nil then 
        return
    end
    if self._mapQuest[QuestType[mapData.Type]] == nil then
        self._mapQuest[QuestType[mapData.Type]] = {}
    end
    if #mapData.Progress == 0 then
        printError("没有任务进度：" .. mapData.Id)
        return
    end
    self._mapQuest[QuestType[mapData.Type]][mapData.Id] = {
        nTid = mapData.Id,
        nGoal = mapData.Progress[1].Max,
        nCurProgress = mapData.Status ~= 2 and mapData.Progress[1].Cur or mapData.Progress[1].Max,
        nStatus = mapData.Status,
        nExpire = mapData.Expire,
    }
    EventManager.Hit(EventId.QuestDataRefresh, mapData.Type)
end
function PlayerQuestData:ReceiveTourReward(nTid,callback)
    local msg = {Value = nTid}

    local tbReceivedId = {}
    if nTid == 0 then
        for nId, mapQuestData in pairs(self._mapQuest[QuestType["TourGuide"]]) do
            if mapQuestData.nStatus == 1 then
                table.insert(tbReceivedId,nId)
            end
        end
    end
    local function Callback(_,mapMsgData)
        if nTid == 0 then
            for _, nQuestId in ipairs(tbReceivedId) do
                self._mapQuest[QuestType["TourGuide"]][nQuestId].nStatus = 2
                self._mapQuest[QuestType["TourGuide"]][nQuestId].nCurProgress = 1
                self._mapQuest[QuestType["TourGuide"]][nQuestId].nGoal = 1
            end
        else
            self._mapQuest[QuestType["TourGuide"]][nTid].nStatus = 2
            self._mapQuest[QuestType["TourGuide"]][nTid].nCurProgress = 1
            self._mapQuest[QuestType["TourGuide"]][nTid].nGoal = 1
        end
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
        if callback ~= nil then
            callback(mapMsgData)
        end
        EventManager.Hit(EventId.TourQuestReceived, mapMsgData.Rewards, mapMsgData.Change)
        --刷新红点
        self:UpdateQuestRedDot("TourGuide")
    end
    --领取奖励前清空奖励溢出状态
    PlayerData.State:SetMailOverflow(false)
    HttpNetHandler.SendMsg(NetMsgId.Id.quest_tour_guide_reward_receive_req,msg,nil,Callback)
end
function PlayerQuestData:ReceiveTourGroupReward(callback)
    local function Callback(_, mapMsgData)
        self.nCurTourGroupOrderIndex = self.nCurTourGroupOrderIndex + 1
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
        if callback ~= nil then
            callback(mapMsgData)
        end
        EventManager.Hit(EventId.TourGroupReceived, mapMsgData.Rewards, mapMsgData.Change)
        --刷新红点
        self:UpdateQuestRedDot("TourGuide")
    end
    --领取奖励前清空奖励溢出状态
    PlayerData.State:SetMailOverflow(false)
    HttpNetHandler.SendMsg(NetMsgId.Id.quest_tour_guide_group_reward_receive_req, {}, nil, Callback)
end
function PlayerQuestData:ReceiveDailyReward(nTid, callback)
    local msg = {Value = nTid}
    local tbReceivedId = {}
    for nId, mapQuestData in pairs(self._mapQuest[QuestType["Daily"]]) do
        local questCfg = ConfigTable.GetData("DailyQuest", nId)
        if nil ~= questCfg then
            if nTid == 0 then
                if mapQuestData.nStatus == 1 then
                    table.insert(tbReceivedId, nId)
                end
            end
        end
    end
    local function Callback(_, mapMsgData)
        if nTid == 0 then
            for _, nId in ipairs(tbReceivedId) do
                if self._mapQuest[QuestType["Daily"]][nId].nStatus == 1 then
                    self._mapQuest[QuestType["Daily"]][nId].nStatus = 2
                    self._mapQuest[QuestType["Daily"]][nId].nCurProgress = 1
                    self._mapQuest[QuestType["Daily"]][nId].nGoal = 1
                end
            end
        else
            self._mapQuest[QuestType["Daily"]][nTid].nStatus = 2
            self._mapQuest[QuestType["Daily"]][nTid].nCurProgress = 1
            self._mapQuest[QuestType["Daily"]][nTid].nGoal = 1
            table.insert(tbReceivedId,nTid)
        end

        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
        HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
        if callback ~= nil then
            callback()
        end

        EventManager.Hit(EventId.DailyQuestReceived, mapMsgData)

        --刷新红点
        self:UpdateQuestRedDot("Daily")
    end
    --领取奖励前清空奖励溢出状态
    PlayerData.State:SetMailOverflow(false)
    HttpNetHandler.SendMsg(NetMsgId.Id.quest_daily_reward_receive_req,msg,nil,Callback)
end
function PlayerQuestData:ReceiveDailyActiveReward(callBack)
    local callback = function(_, mapMsgData)
        local tbReward = {}
        for _, v in ipairs(mapMsgData.ActiveIds) do
            self.tbDailyActives[v].bReward = true
            local mapCfg = ConfigTable.GetData("DailyQuestActive", v)
            if mapCfg ~= nil then
                for i = 1, 2 do
                    if mapCfg["ItemTid" .. i] ~= 0 then
                        if tbReward[mapCfg["ItemTid" .. i]] == nil then
                            tbReward[mapCfg["ItemTid" .. i]] = 0
                        end
                        tbReward[mapCfg["ItemTid" .. i]] = tbReward[mapCfg["ItemTid" .. i]] + mapCfg["Number" .. i]
                    end
                end
            end
        end
        self:UpdateDailyQuestRedDot()
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
        if callBack ~= nil then
            callBack()
        end
        local tbShowReward = {}
        for id, count in pairs(tbReward) do
            table.insert(tbShowReward, {id = id, count = count})
        end
        EventManager.Hit(EventId.DailyQuestActiveReceived, tbShowReward)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.quest_daily_active_reward_receive_req, {}, nil, callback)
end
function PlayerQuestData:ReceiveTravelerDuelReward(nTid,callback)
    local msg = {Id = nTid,Type = 3}
    local tbReceivedId = {}
    if nTid == 0 then
        for nId, mapQuestData in pairs(self._mapQuest[QuestType["TravelerDuel"]]) do
            if mapQuestData.nStatus == 1 then
                table.insert(tbReceivedId,nId)
            end
        end
    end
    local function Callback(_,mapMsgData)
        if nTid == 0 then
            for _, nId in ipairs(tbReceivedId) do
                if self._mapQuest[QuestType["TravelerDuel"]][nId].nStatus == 1 then
                    self._mapQuest[QuestType["TravelerDuel"]][nId].nStatus = 2
                    self._mapQuest[QuestType["TravelerDuel"]][nId].nCurProgress = 1
                    self._mapQuest[QuestType["TravelerDuel"]][nId].nGoal = 1
                end
            end
        else
            self._mapQuest[QuestType["TravelerDuel"]][nTid].nStatus = 2
            self._mapQuest[QuestType["TravelerDuel"]][nTid].nCurProgress = 1
            self._mapQuest[QuestType["TravelerDuel"]][nTid].nGoal = 1
            table.insert(tbReceivedId,nTid)
        end
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
        if callback~= nil then
            callback()
        end
        EventManager.Hit(EventId.TRNormalQusetReceived,mapMsgData.QuestRewards,tbReceivedId, mapMsgData.Change)
        self:UpdateQuestRedDot("TravelerDuel")
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.traveler_duel_quest_reward_receive_req,msg,nil,Callback)
end
function PlayerQuestData:ReceiveTravelerDuelChallengeReward(nTid,callback)
    local msg = {Id = nTid,Type = 4}
    local tbReceivedId = {}
    if nTid == 0 then
        for nId, mapQuestData in pairs(self._mapQuest[QuestType["TravelerDuelChallenge"]]) do
            if mapQuestData.nStatus == 1 then
                table.insert(tbReceivedId,nId)
            end
        end
    end
    local function Callback(_,mapMsgData)
        if nTid == 0 then
            for _, nId in ipairs(tbReceivedId) do
                if self._mapQuest[QuestType["TravelerDuelChallenge"]][nId].nStatus == 1 then
                    self._mapQuest[QuestType["TravelerDuelChallenge"]][nId].nStatus = 2
                    self._mapQuest[QuestType["TravelerDuelChallenge"]][nId].nCurProgress = 1
                    self._mapQuest[QuestType["TravelerDuelChallenge"]][nId].nGoal = 1
                end
            end
        else
            self._mapQuest[QuestType["TravelerDuelChallenge"]][nTid].nStatus = 2
            self._mapQuest[QuestType["TravelerDuelChallenge"]][nTid].nCurProgress = 1
            self._mapQuest[QuestType["TravelerDuelChallenge"]][nTid].nGoal = 1
            table.insert(tbReceivedId,nTid)
        end
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
        if callback~= nil then
            callback()
        end
        EventManager.Hit(EventId.TRChallengeQusetReceived,mapMsgData.QuestRewards,tbReceivedId, mapMsgData.Change)
        self:UpdateQuestRedDot("TravelerDuelChallenge")
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.traveler_duel_quest_reward_receive_req,msg,nil,Callback)
end
function PlayerQuestData:ReceiveBattlePassQuestData(nTid,callback)
    local function msgCallback(_,msgData)
        if nTid == 0 then
            for _, mapQuest in pairs(self._mapQuest[6]) do
                if mapQuest.nStatus == 1 then
                    mapQuest.nStatus = 2
                end
            end
            for _, mapQuest in pairs(self._mapQuest[7]) do
                if mapQuest.nStatus == 1 then
                    mapQuest.nStatus = 2
                end
            end
        else
            local mapQuestCfgData = ConfigTable.GetData("BattlePassQuest", nTid)
            if mapQuestCfgData ~= nil then
                if mapQuestCfgData.Type == GameEnum.battlePassQuestType.DAY then
                    if self._mapQuest[6][nTid] ~= nil then
                        self._mapQuest[6][nTid].nStatus = 2
                    end
                else
                    if self._mapQuest[7][nTid] ~= nil then
                        self._mapQuest[7][nTid].nStatus = 2
                    end
                end
            end
        end
        EventManager.Hit("BattlePassQuestReceive",msgData)
        if callback ~= nil and type(callback) == "function" then
            callback()
        end
        self:UpdateBattlePassRedDot()
    end
    local msg = {
        Value = nTid
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.battle_pass_quest_reward_receive_req,msg,nil,msgCallback)
end
function PlayerQuestData:ReceiveAffinityReward(questIds, curCharId, callback)
    local msg = {
        CharId = curCharId,
        QuestId = 0
    }
    local function Callback(_,mapMsgData)
        if self._mapQuest[QuestType["Affinity"]] == nil then
            self._mapQuest[QuestType["Affinity"]] = {}
        end
        for k,v in ipairs(questIds) do
            if self._mapQuest[QuestType["Affinity"]][v] ~= nil then
                self._mapQuest[QuestType["Affinity"]][v].nStatus = 2
            else
                local data = {
                    nTid = v,
                    nGoal = 1,
                    nCurProgress = 1,
                    nStatus = 2,
                }
                self._mapQuest[QuestType["Affinity"]][v] = data
            end
        end
        if callback ~= nil then
            callback()
        end
        self:UpdateCharAffinityRedDot()
        EventManager.Hit(EventId.AffinityQuestReceived)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.char_affinity_quest_reward_receive_req, msg, nil, Callback)
end
function PlayerQuestData:ReceiveStarTowerReward(nTid, callback)
    local msg = {Value = nTid}
    local tbReceivedId = {}
    if nTid == 0 then
        for nId, mapQuestData in pairs(self._mapQuest[QuestType["Tower"]]) do
            if mapQuestData.nStatus == 1 then
                table.insert(tbReceivedId,nId)
            end
        end
    end
    local function Callback(_, mapMsgData)
        if nTid == 0 then
            for _, nId in ipairs(tbReceivedId) do
                if self._mapQuest[QuestType["Tower"]][nId].nStatus == 1 then
                    self._mapQuest[QuestType["Tower"]][nId].nStatus = 2
                    self._mapQuest[QuestType["Tower"]][nId].nCurProgress = 1
                    self._mapQuest[QuestType["Tower"]][nId].nGoal = 1
                end
            end
        else
            self._mapQuest[QuestType["Tower"]][nTid].nStatus = 2
            self._mapQuest[QuestType["Tower"]][nTid].nCurProgress = 1
            self._mapQuest[QuestType["Tower"]][nTid].nGoal = 1
            table.insert(tbReceivedId,nTid)
        end

        UTILS.OpenReceiveByChangeInfo(mapMsgData, function ()
            if callback ~= nil then
                callback()
            end
            EventManager.Hit("StarTowerQuestReceived")
        end)

        --刷新红点
        self:UpdateQuestRedDot("Tower")
    end
    --领取奖励前清空奖励溢出状态
    PlayerData.State:SetMailOverflow(false)
    HttpNetHandler.SendMsg(NetMsgId.Id.quest_tower_reward_receive_req,msg,nil,Callback)
end
function PlayerQuestData:ReceiveStarTowerEventReward(nTid, callback)
    local sucCall = function(_, mapMsgData)
        for _, v in ipairs(mapMsgData.ReceivedIds) do
            if self._mapQuest[12] ~= nil and self._mapQuest[12][v] ~= nil then
                self._mapQuest[12][v].nStatus = 2
                self._mapQuest[12][v].nCurProgress = 0
                self._mapQuest[12][v].nGoal = 0
            end
            RedDotManager.SetValid(RedDotDefine.StarTowerBook_Event_Reward, v, false)
        end
        --显示奖励弹窗
        UTILS.OpenReceiveByChangeInfo(mapMsgData.Change, callback)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_book_event_reward_receive_req, {Value = nTid}, nil, sucCall)
end
function PlayerQuestData:CacheAllQuest(tbQuests)
    local tbQuestType = {}
    for _, mapQuest in pairs(tbQuests) do
        self:OnQuestProgressChanged(mapQuest)
        if nil == tbQuestType[mapQuest.Type] then
            tbQuestType[mapQuest.Type] = 1
        end
    end
    for questType, v in pairs(tbQuestType) do
        self:UpdateQuestRedDot(questType)
    end
end
function PlayerQuestData:CacheDailyActiveIds(tbIds)
    for _, v in ipairs(tbIds) do
        self.tbDailyActives[v].bReward = true
    end
    self:UpdateDailyQuestRedDot()
end
function PlayerQuestData:CacheTourGroupOrder(nIndex)
    self.nCurTourGroupOrderIndex = nIndex
end
function PlayerQuestData:CheckClientType(nEventType)
    local tbQuestId = {}
    for nQuestType, tbQuestList in pairs(self._mapQuest) do
        for _, mapQuest in pairs(tbQuestList) do
            local nClientType
            if nQuestType == QuestType["Daily"] then
                local mapQuestCfg = ConfigTable.GetData("DailyQuest", mapQuest.nTid)
                if mapQuestCfg ~= nil then
                    nClientType = mapQuestCfg.CompleteCondClient
                end
            end

            if nClientType == nEventType and mapQuest.nStatus == 0 then
                table.insert(tbQuestId, mapQuest.nTid)
            end
        end
    end
    return tbQuestId
end
function PlayerQuestData:HandleExpire()
    local curTime = CS.ClientManager.Instance.serverTimeStamp
    local tbExpire = {}

    if self._mapQuest[2] ~= nil then
        for nTid, mapQuest in pairs(self._mapQuest[2]) do
            if mapQuest.nExpire > 0 and mapQuest.nExpire <= curTime then
                table.insert(tbExpire,nTid)
            end
        end
        for _, nTid in ipairs(tbExpire) do
            self._mapQuest[2][nTid] = nil
        end
    end
    
    tbExpire = {}
    if self._mapQuest[6] ~= nil then
        for nTid, mapQuest in pairs(self._mapQuest[6]) do
            if mapQuest.nExpire > 0 and mapQuest.nExpire <= curTime then
                table.insert(tbExpire,nTid)
            end
        end
        for _, nTid in ipairs(tbExpire) do
            self._mapQuest[6][nTid] = nil
        end
    end
    
    tbExpire = {}
    if self._mapQuest[7] ~= nil then
        for nTid, mapQuest in pairs(self._mapQuest[7]) do
            if mapQuest.nExpire > 0 and mapQuest.nExpire <= curTime then
                table.insert(tbExpire,nTid)
            end
        end
        for _, nTid in ipairs(tbExpire) do
            self._mapQuest[7][nTid] = nil
        end
    end

    for _, v in pairs(self.tbDailyActives) do
        v.bReward = false
    end

    self:UpdateDailyQuestRedDot()
    self:UpdateBattlePassRedDot()
    self:UpdateVampireQuestRedDot()
end
--返回对应的任务是否已经被领取
function PlayerQuestData:IsQuestHasReceived(nType,nQuestId)
    if self._mapQuest[nType] == nil then
        printError("没有记录的任务类型数据：" .. nQuestId)
        return false
    end
    if self._mapQuest[nType][nQuestId] == nil then
        printError("没有记录的任务组数据：" .. nQuestId)
        return false
    end
    return self._mapQuest[nType][nQuestId].nStatus == 2
end
function PlayerQuestData:SendClientEvent(nEventType, nCount)
    if nCount == nil then
        nCount = 1
    end
    local tbQuestId = self:CheckClientType(nEventType)
    if #tbQuestId > 0 then
        local tbSendData = {}
        for _, v in ipairs(tbQuestId) do
            table.insert(tbSendData, {Id = GameEnum.eventTypes.eClient, Data = {nCount, v}})
        end
        local msgData = {
            List = tbSendData,
        }
        HttpNetHandler.SendMsg(NetMsgId.Id.client_event_report_req,msgData,nil,nil)
    end
end
---------------- 红点相关 --------------
function PlayerQuestData:UpdateServerQuestRedDot(mapMsgData)
    if nil == mapMsgData then
        return
    end
    local redDotType = QuestRedDotType[mapMsgData.Type]
    if nil ~= redDotType then
        RedDotManager.SetValid(redDotType, nil, mapMsgData.New)
    end
end
function PlayerQuestData:UpdateQuestRedDot(questType)
    if nil == questType then
        return
    end
    if questType == "Daily" then
        self:UpdateDailyQuestRedDot()
    elseif questType == "TourGuide" then
        self:UpdateTourGuideQuestRedDot()
    elseif questType == "Affinity" then
        self:UpdateCharAffinityRedDot()
    elseif questType == "TravelerDuel" or questType == "TravelerDuelChallenge" then
        self:UpdateDuelQuestRedDot(questType)
    elseif questType == "BattlePassDaily" or questType == "BattlePassWeekly" then
        self:UpdateBattlePassRedDot()
    elseif questType == "Tower" then
        self:UpdateStarTowerQuestRedDot()
    elseif questType == "Demon" then
        PlayerData.Base:RefreshWorldClassRedDot()
    elseif questType == "VampireSurvivorSeason" or questType == "VampireSurvivorNormal" then
        self:UpdateVampireQuestRedDot()
    elseif questType == "TowerEvent" then
        self:UpdateStarTowerBookQuestRedDot()
    end
end
--有可领取的任务奖励时对应的页签显示红点
function PlayerQuestData:UpdateDailyQuestRedDot()
    local bCanReceive = false
    local bActiveReward = false
    local nTotalActiveCount = 0
    local questList = self._mapQuest[QuestType["Daily"]]
    if nil ~= questList then
        for _, v in pairs(questList) do
            --0:未完成  1:已完成可领取
            if v.nStatus == 1 then
                bCanReceive = true
            elseif v.nStatus == 2 then
                local questCfg = ConfigTable.GetData("DailyQuest", v.nTid)
                if questCfg ~= nil then
                    nTotalActiveCount = nTotalActiveCount + questCfg.Active
                end
            end
        end
    end
    for _, v in pairs(self.tbDailyActives) do
        bActiveReward = bActiveReward or (v.nActive <= nTotalActiveCount and v.bReward == false)
    end
    local bFuncUnlock = PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.DailyQuest, false)
    RedDotManager.SetValid(RedDotDefine.Task_Daily, nil, (bCanReceive or bActiveReward) and bFuncUnlock)
end
--手册任务
function PlayerQuestData:UpdateTourGuideQuestRedDot()
    local bCanReceive = false
    local bAllReceive = true
    local nCurGroupId = self:GetCurTourGroup()
    local questList = self._mapQuest[QuestType["TourGuide"]]
    if nil ~= questList then
        for _, v in pairs(questList) do
            --0:未完成  1:已完成可领取
            if v.nStatus == 1 then
                local questCfg = ConfigTable.GetData("TourGuideQuest", v.nTid)
                if nil ~= questCfg and nCurGroupId == questCfg.Order then
                    bCanReceive = true
                    break
                end
            end

            if v.nStatus ~= 2 then
                bAllReceive = false
            end
        end
    end
    local bGroupReceived = self:CheckTourGroupReward(self:GetCurTourGroupOrder())
    local bChapterCanReceive = bAllReceive and not bGroupReceived
    RedDotManager.SetValid(RedDotDefine.Task_Guide, nil, bCanReceive or bChapterCanReceive)
end
--旅人对决任务
function PlayerQuestData:UpdateDuelQuestRedDot(questType)
    local bCanReceive = false
    local questList = self._mapQuest[QuestType[questType]]
    if nil ~= questList then
        for _, v in pairs(questList) do
            --0:未完成  1:已完成可领取
            if v.nStatus == 1 then
                bCanReceive = true
                break
            end
        end
    end
    RedDotManager.SetValid(QuestRedDotType[questType], nil, bCanReceive)
end
--角色好感度任务
function PlayerQuestData:UpdateCharAffinityRedDot() 
     if self.tbCharQuest == nil then
         self.tbCharQuest = {}
     end
     local questList = self._mapQuest[QuestType["Affinity"]]
     if nil ~= questList then
         for k,v in pairs(questList) do
             local data = ConfigTable.GetData("AffinityQuest", v.nTid)
             if data ~= nil then
                 if self.tbCharQuest[data.CharId] == nil then
                     self.tbCharQuest[data.CharId] = {}
                 end
                 table.insert(self.tbCharQuest[data.CharId], v)
             end
         end
         local tbCharList = {}
         for k, list in pairs(self.tbCharQuest) do
             for i = 1, #list do
                 local state = list[i].nStatus
                 if state == 1 then 
                     tbCharList[k] = true
                     break
                 else
                     tbCharList[k] = false
                 end
             end
         end
         for k,v in pairs(tbCharList) do
             RedDotManager.SetValid(RedDotDefine.Role_AffinityTask, k, v)
         end
     end
end
--角色战令任务
function PlayerQuestData:UpdateBattlePassRedDot()
    local bCanDailyReceive = false
    local bCanWeekReceive = false
    local questList = self._mapQuest[6]
    if nil ~= questList then
        for _, v in pairs(questList) do
            --0:未完成  1:已完成可领取
            if v.nStatus == 1 then
                bCanDailyReceive = true
                break
            end
        end
    end
    questList = self._mapQuest[7]
    if nil ~= questList then
        for _, v in pairs(questList) do
            --0:未完成  1:已完成可领取
            if v.nStatus == 1 then
                bCanWeekReceive = true
                break
            end
        end
    end
    PlayerData.BattlePass:UpdateQuestRedDot(bCanDailyReceive, bCanWeekReceive)
end
--星塔任务
function PlayerQuestData:UpdateStarTowerQuestRedDot()
    local bCanReceive = false
    local questList = self._mapQuest[QuestType["Tower"]]
    if nil ~= questList then
        for _, v in pairs(questList) do
            --0:未完成  1:已完成可领取
            if v.nStatus == 1 then
                bCanReceive = true
                break
            end
        end
    end
    RedDotManager.SetValid(QuestRedDotType["Tower"], nil, bCanReceive)
end
--星塔图鉴任务
function PlayerQuestData:UpdateStarTowerBookQuestRedDot()
    local questList = self._mapQuest[QuestType["TowerEvent"]]
    if nil ~= questList then
        for _, v in pairs(questList) do
            --0:未完成  1:已完成可领取
            if v.nStatus == 1 then
                RedDotManager.SetValid(RedDotDefine.StarTowerBook_Event_Reward, v.nTid, true)
            else
                RedDotManager.SetValid(RedDotDefine.StarTowerBook_Event_Reward, v.nTid, false)
            end
        end
    end
end
--吸血鬼任务
function PlayerQuestData:GetVampireQuestData()
    local tbScore, tbPass = {}, {}
    if self._mapQuest[QuestType["VampireSurvivorSeason"]] ~= nil then
        for nId, v in pairs(self._mapQuest[QuestType["VampireSurvivorSeason"]]) do
            table.insert(tbScore, v)
        end
    end

    if self._mapQuest[QuestType["VampireSurvivorNormal"]] ~= nil then
        for nId, v in pairs(self._mapQuest[QuestType["VampireSurvivorNormal"]]) do
            table.insert(tbPass, v)
        end
    end

    -- local function sort(a,b)
    --     if a.nStatus ~= b.nStatus then
    --         return statusOrder[a.nStatus] > statusOrder[b.nStatus]
    --     elseif a.nTid ~= b.nTid then
    --         return a.nTid < b.nTid
    --     end
    -- end
    -- if #tbScore > 0 then
    --     table.sort(tbScore, sort)
    -- end
    -- if #tbPass > 0 then
    --     table.sort(tbPass, sort)
    -- end
    return tbScore, tbPass
end
function PlayerQuestData:GetVampireQuestStatusById(nId)
    if nId == nil then
        return 0 
    end
    if self._mapQuest[QuestType["VampireSurvivorSeason"]] ~= nil then
        if self._mapQuest[QuestType["VampireSurvivorSeason"]][nId] ~= nil then
            return self._mapQuest[QuestType["VampireSurvivorSeason"]][nId].nStatus
        end
    end
    if self._mapQuest[QuestType["VampireSurvivorNormal"]] ~= nil then
        if self._mapQuest[QuestType["VampireSurvivorNormal"]][nId] ~= nil then
            return self._mapQuest[QuestType["VampireSurvivorNormal"]][nId].nStatus
        end
    end
    return 0
end
function PlayerQuestData:ReceiveVampireQuest(nType,tbList,callback)
    local msg = {
        QuestType = nType - 7,
        QuestIds = tbList
    }
    local function Callback(_,mapMsgData)
        for _, nTid in ipairs(tbList) do
            if self._mapQuest[8][nTid] ~= nil then
                self._mapQuest[8][nTid].nStatus = 2
            end
            if self._mapQuest[9] ~= nil then
                if self._mapQuest[9][nTid] ~= nil then
                    self._mapQuest[9][nTid].nStatus = 2
                end
            end
        end
        self:UpdateVampireQuestRedDot()
        HttpNetHandler.ProcChangeInfo(mapMsgData)
        EventManager.Hit("VampireQuestRefresh")
        if callback ~= nil then
            callback(mapMsgData)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.vampire_survivor_quest_reward_receive_req, msg, nil, Callback)
end
function PlayerQuestData:UpdateVampireQuestRedDot()
    local bCanNormalReceive = false
    local bCanHardReceive = false
    local bCanSeasonReceive = false
    local questList = self._mapQuest[8]
    if nil ~= questList then
        for _, v in pairs(questList) do
            --0:未完成  1:已完成可领取
            if v.nStatus == 1 then
                local mapQusetData = ConfigTable.GetData("VampireSurvivorQuest",v.nTid)
                if mapQusetData ~= nil then
                    if mapQusetData.Type == GameEnum.vampireSurvivorType.Normal then
                        bCanNormalReceive = true
                    elseif mapQusetData.Type == GameEnum.vampireSurvivorType.Hard then
                        bCanHardReceive = true
                    elseif mapQusetData.Type == GameEnum.vampireSurvivorType.Turn then
                        bCanSeasonReceive = true
                    end
                end
            end
        end
    end
    questList = self._mapQuest[9]
    if nil ~= questList then
        for _, v in pairs(questList) do
            --0:未完成  1:已完成可领取
            if v.nStatus == 1 then
                local mapQusetData = ConfigTable.GetData("VampireSurvivorQuest",v.nTid)
                if mapQusetData ~= nil then
                    if mapQusetData.Type == GameEnum.vampireSurvivorType.Normal then
                        bCanNormalReceive = true
                    elseif mapQusetData.Type == GameEnum.vampireSurvivorType.Hard then
                        bCanHardReceive = true
                    elseif mapQusetData.Type == GameEnum.vampireSurvivorType.Turn then
                        bCanSeasonReceive = true
                    end
                end
             end
        end
    end
    RedDotManager.SetValid(RedDotDefine.VampireQuest_Normal, nil, bCanNormalReceive)
    RedDotManager.SetValid(RedDotDefine.VampireQuest_Hard, nil, bCanHardReceive)
    RedDotManager.SetValid(RedDotDefine.VampireQuest_Season, nil, bCanSeasonReceive)
end
function PlayerQuestData:ClearVampireSeasonQuest(nCurSeason)
    local mapSeasonData = ConfigTable.GetData("VampireRankSeason",nCurSeason)
    local tbRemove = {}
    if mapSeasonData ~= nil then
        local nSeasonGroupId = mapSeasonData.QuestGroup
        for nTid, mapQuest in pairs(self._mapQuest[9]) do
            local mapQuestCfgData = ConfigTable.GetData("VampireRankSeason",nTid)
            if mapQuestCfgData ~= nil then
                if mapQuestCfgData.GroupId ~= nSeasonGroupId then
                    table.insert(tbRemove,nTid)
                end
            end
        end
        for _ , nQuestId in ipairs(tbRemove) do
            if self._mapQuest[9][nQuestId] ~= nil then
                self._mapQuest[9][nQuestId] = nil
            end
        end
    end

end
return PlayerQuestData