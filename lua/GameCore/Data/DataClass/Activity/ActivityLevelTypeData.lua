local ActivityDataBase = require "GameCore.Data.DataClass.Activity.ActivityDataBase"
local ActivityLevelTypeData = class("ActivityLevelTypeData", ActivityDataBase)
local newDayTime = UTILS.GetDayRefreshTimeOffset()
local LocalData = require "GameCore.Data.LocalData"

function ActivityLevelTypeData:Init()
    self.nActId = 0
    self.startTime = 0 -- 关卡开始时间
    self.startTimeRefreshTime = 0 --将开放时间调整为刷新时间，这样自然日开放计算方便
    self.exploreLevelCount = 0 -- 探索关卡数量
    self.adventureLevelCount = 0 --冒险关卡数量
    self.levelTabExplore = {} -- 探索
    self.levelTabExploreDifficulty = {}
    self.levelTabAdventure = {} --冒险
    self.levelTabAdventureDifficulty = {}

    self.tabCachedBuildId = {}
    EventManager.Add("ActivityLevels_Instance_Gameplay_Time", self, self.OnEvent_Time)
end

function ActivityLevelTypeData:OnEvent_Time(nTime)
    self._TotalTime = nTime
end

-- 获取数据的总入口
function ActivityLevelTypeData:RefreshActivityLevelGameActData(actId, msgData)
    self:Init()
    local nCurTime = CS.ClientManager.Instance.serverTimeStamp
    local isEnding = false
    if nCurTime > self.nEndTime then
        isEnding = true
    end
    local openTime = self.nOpenTime

    self.startTimeRefreshTime = CS.ClientManager.Instance:GetNextRefreshTime(openTime) - 86400
    self.nActId = actId
    local function foreach_Base(baseData)
        if actId == baseData.ActivityId then
            if baseData.Type == GameEnum.ActivityLevelType.Explore then
                self.exploreLevelCount = self.exploreLevelCount + 1
                self.levelTabExplore[baseData.Id] = {}
                self.levelTabExplore[baseData.Id].baseData = baseData
                self.levelTabExplore[baseData.Id].Star = 0
                self.levelTabExplore[baseData.Id].BuildId = 0
                self.levelTabExploreDifficulty[baseData.Difficulty] = baseData.Id
            else
                self.adventureLevelCount =  self.adventureLevelCount + 1
                self.levelTabAdventure[baseData.Id] = {}
                self.levelTabAdventure[baseData.Id].baseData = baseData
                self.levelTabAdventure[baseData.Id].Star = 0
                self.levelTabAdventure[baseData.Id].BuildId = 0
                self.levelTabAdventureDifficulty[baseData.Difficulty] = baseData.Id
            end
            self:CheckRedDot(baseData.Type,baseData.Id,baseData.DayOpen,isEnding)
        end
    end
    ForEachTableLine(DataTable.ActivityLevelsLevel,foreach_Base)
    if msgData ~= nil then
        for i, v in ipairs(msgData.levels) do
            local tmpData = ConfigTable.GetData("ActivityLevelsLevel", v.Id)
            if tmpData then
                if tmpData.Type == GameEnum.ActivityLevelType.Explore then
                    if self.levelTabExplore[v.Id] then
                        self.levelTabExplore[v.Id].Star = v.Star
                        self.levelTabExplore[v.Id].BuildId = v.BuildId
                    end
                else
                    if self.levelTabAdventure[v.Id] then
                        self.levelTabAdventure[v.Id].Star = v.Star
                        self.levelTabAdventure[v.Id].BuildId = v.BuildId
                    end
                end
            end
        end
    end
end

function ActivityLevelTypeData:CheckRedDot(nType,levelId,dayOpen,isEnding)
    local tmpKey = self.nActId .."_" ..levelId
    if isEnding then
        LocalData.SetPlayerLocalData(tmpKey,"0")
        return
    end

    local sLocalVal = LocalData.GetPlayerLocalData(tmpKey)
    local nState = tonumber(sLocalVal == nil and "0" or sLocalVal)
    if nState == 2 then
        return
    end

    if nState == 1 then
        local bInActGroup,nActGroupId = PlayerData.Activity:IsActivityInActivityGroup(self.nActId)
        if bInActGroup then
            local actGroupData = PlayerData.Activity:GetActivityGroupDataById(nActGroupId)
            local bActGroupUnlock = actGroupData:IsUnlock()
            if nType == GameEnum.ActivityLevelType.Explore then
                --printError("Explore nState == " .. levelId  .. "  " .. dayOpen)
                RedDotManager.SetValid(RedDotDefine.ActivityLevel_Explore_Level, {nActGroupId, levelId}, true and bActGroupUnlock)
            else
                --printError("Adventure nState == " .. levelId  .. "  " .. dayOpen)
                RedDotManager.SetValid(RedDotDefine.ActivityLevel_Adventure_Level, {nActGroupId, levelId}, true and bActGroupUnlock)
            end
        end
        return
    end
    --printError("levelId == " .. levelId  .. "  " .. dayOpen)
    local nCurTime = CS.ClientManager.Instance.serverTimeStamp
    local openTime = self.startTimeRefreshTime + dayOpen * 86400
    local openTimeNextDay = self.startTimeRefreshTime + dayOpen * 86400 + 86400

    if openTime <= nCurTime and nCurTime <= openTimeNextDay then
        LocalData.SetPlayerLocalData(tmpKey,"1")
        local bInActGroup,nActGroupId = PlayerData.Activity:IsActivityInActivityGroup(self.nActId)
        if bInActGroup then
            local actGroupData = PlayerData.Activity:GetActivityGroupDataById(nActGroupId)
            local bActGroupUnlock = actGroupData:IsUnlock()
            if nType == GameEnum.ActivityLevelType.Explore then
                --printError("Explore == " .. levelId  .. "  " .. dayOpen)
                RedDotManager.SetValid(RedDotDefine.ActivityLevel_Explore_Level, {nActGroupId, levelId}, true and bActGroupUnlock)
            else
                --printError("Adventure == " .. levelId  .. "  " .. dayOpen)
                RedDotManager.SetValid(RedDotDefine.ActivityLevel_Adventure_Level, {nActGroupId, levelId}, true and bActGroupUnlock)
            end
        end
    end
end

function ActivityLevelTypeData:ChangeRedDot(nType,levelId)
    local tmpKey = self.nActId .."_" ..levelId
    local sLocalVal = LocalData.GetPlayerLocalData(tmpKey)
    local nState = tonumber(sLocalVal == nil and "0" or sLocalVal)
    if nState == 1 then
        LocalData.SetPlayerLocalData(tmpKey,"2")
        local bInActGroup,nActGroupId = PlayerData.Activity:IsActivityInActivityGroup(self.nActId)
        if bInActGroup then
            if nType == GameEnum.ActivityLevelType.Explore then
                RedDotManager.SetValid(RedDotDefine.ActivityLevel_Explore_Level, {nActGroupId, levelId}, false)
            else
                RedDotManager.SetValid(RedDotDefine.ActivityLevel_Adventure_Level, {nActGroupId, levelId}, false)
            end
        end
    end
end

function ActivityLevelTypeData:ChangeAllRedHot()
    for i, v in pairs(self.levelTabExploreDifficulty) do
        self:ChangeRedDot(GameEnum.ActivityLevelType.Explore,v)
    end

    for i, v in pairs(self.levelTabAdventureDifficulty) do
        self:ChangeRedDot(GameEnum.ActivityLevelType.Adventure,v)
    end
end

--获取关卡星级信息
function ActivityLevelTypeData:GetLevelStarMsg(nType)
    if nType == GameEnum.ActivityLevelType.Explore then
        local star = 0
        for i, v in pairs(self.levelTabExplore) do
            star = star + v.Star
        end
        return self.exploreLevelCount * 3,star
    else
        local star = 0
        for i, v in pairs(self.levelTabAdventure) do
            star = star + v.Star
        end
        return self.adventureLevelCount * 3,star
    end
end

--获取关卡是否解锁 自然日
function ActivityLevelTypeData:GetLevelDayOpen(nType,id)
    if nType == GameEnum.ActivityLevelType.Explore then
        if self.levelTabExplore[id] ~= nil then
            local dayOpen = self.levelTabExplore[id].baseData.DayOpen
            local openTime = self.startTimeRefreshTime + dayOpen * 86400
            local nCurTime = CS.ClientManager.Instance.serverTimeStamp
            if nCurTime >= openTime then
                return true
            end
        end
    else
        if self.levelTabAdventure[id] ~= nil then
            local dayOpen = self.levelTabAdventure[id].baseData.DayOpen
            local openTime = self.startTimeRefreshTime + dayOpen * 86400
            local nCurTime = CS.ClientManager.Instance.serverTimeStamp
            if nCurTime >= openTime then
                return true
            end
        end
    end
    return false
end

--获取还有几日解锁
function ActivityLevelTypeData:GetUnLockDay(nType,id)
    if nType == GameEnum.ActivityLevelType.Explore then
        local dayOpen = self.levelTabExplore[id].baseData.DayOpen
        local nCurTime = CS.ClientManager.Instance.serverTimeStamp
        local nDay = math.floor((self.startTimeRefreshTime + dayOpen * 86400 - nCurTime)/86400)
        return nDay
    else
        local dayOpen = self.levelTabAdventure[id].baseData.DayOpen
        local nCurTime = CS.ClientManager.Instance.serverTimeStamp
        local nDay = math.floor((self.startTimeRefreshTime + dayOpen * 86400 - nCurTime)/86400)
        return nDay
    end
    return 1
end

function ActivityLevelTypeData:GetUnLockHour(nType,id)
    if nType == GameEnum.ActivityLevelType.Explore then
        local dayOpen = self.levelTabExplore[id].baseData.DayOpen
        local nCurTime = CS.ClientManager.Instance.serverTimeStamp
        local openTime = self.startTimeRefreshTime + dayOpen * 86400
        local nRemainTime = openTime - nCurTime
        local hour = math.floor(nRemainTime / 3600)
        local min = math.floor((nRemainTime - hour * 3600) / 60)
        local sec = nRemainTime - hour * 3600 - min * 60
        return hour,min,sec
    else
        local dayOpen = self.levelTabAdventure[id].baseData.DayOpen
        local nCurTime = CS.ClientManager.Instance.serverTimeStamp
        local openTime = self.startTimeRefreshTime + dayOpen * 86400
        local nRemainTime = openTime - nCurTime
        local hour = math.floor(nRemainTime / 3600)
        local min = math.floor((nRemainTime - hour * 3600) / 60)
        local sec = nRemainTime - hour * 3600 - min * 60
        return hour,min,sec
    end
    return 1,0,0
end

--判断关卡是否解锁（前置关卡及星级）
function ActivityLevelTypeData:GetLevelUnLock(nType,id)
    if nType == GameEnum.ActivityLevelType.Explore then
        if self.levelTabExplore[id] ~= nil then
            local preLevelId = self.levelTabExplore[id].baseData.PreLevelId
            if preLevelId == 0 then
                return true
            else
                local preLevelData = self.levelTabExplore[preLevelId]
                local preLevelStar = self.levelTabExplore[id].baseData.PreLevelStar
                if preLevelData and preLevelData.Star >= preLevelStar then
                    return true
                end
            end
        end
    else
        if self.levelTabAdventure[id] ~= nil then
            local preLevelId = self.levelTabAdventure[id].baseData.PreLevelId
            if preLevelId == 0 then
                return true
            else
                local preLevelData = self.levelTabAdventure[preLevelId]
                if preLevelData == nil then
                    preLevelData = self.levelTabExplore[preLevelId]
                end
                local preLevelStar = self.levelTabAdventure[id].baseData.PreLevelStar
                if preLevelData and preLevelData.Star >= preLevelStar then
                    return true
                end
            end
        end
    end

    return false
end

function ActivityLevelTypeData:GetDefaultSelectionDifficulty(nType)
    local index = 1
    if nType == GameEnum.ActivityLevelType.Explore then
        for i, v in pairs(self.levelTabExploreDifficulty) do
            local isOpen = self:GetLevelDayOpen(nType,v)
            local isLevelUnLock = self:GetLevelUnLock(nType,v)
            if isOpen and  isLevelUnLock then
                index = i
            end
        end
    else
        for i, v in pairs(self.levelTabAdventureDifficulty) do
            local isOpen = self:GetLevelDayOpen(nType,v)
            local isLevelUnLock = self:GetLevelUnLock(nType,v)
            if isOpen and  isLevelUnLock then
                index = i
            end
        end
    end
    return index
end

----判断关卡是否可以扫荡（探索 三星）
--function ActivityLevelTypeData:GetLevelCanSweep(nType,id)
--    if nType == GameEnum.ActivityLevelType.Explore then
--        if self.levelTabExplore[id] ~= nil then
--            if self.levelTabExplore[id].Star >= 3 then
--                return true
--            end
--        end
--    end
--    return false
--end

--判断是否首通
function ActivityLevelTypeData:GetLevelFirstPass(nType,id)
    if nType == GameEnum.ActivityLevelType.Explore then
        if self.levelTabExplore[id] ~= nil then
            if self.levelTabExplore[id].Star >= 1 then
                return true
            end
        end
    else
        if self.levelTabAdventure[id] ~= nil then
            if self.levelTabAdventure[id].Star >= 1 then
                return true
            end
        end
    end
    return false
end

--发送进入关卡消息
function ActivityLevelTypeData:SendEnterActivityLevelsApplyReq(nActivityId,nLevelId,nBuildId)
    if nActivityId ~=  self.nActId then
        return
    end
    self.entryLevelId = nLevelId
    self.entryBuildId = nBuildId
    local msg = {}
    msg.ActivityId = nActivityId
    msg.LevelId = nLevelId
    msg.BuildId = nBuildId
    self._EntryTime = CS.ClientManager.Instance.serverTimeStampWithTimeZone
    local function msgCallback(_, msgData)
        self:SetCachedSelBuildId(nBuildId,nLevelId)
        self:EnterActivityLevelInstance(nActivityId,nLevelId,nBuildId)
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(msgData)
        HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_levels_apply_req, msg, nil, msgCallback)
end

--进入关卡
function ActivityLevelTypeData:EnterActivityLevelInstance(nActivityId,nLevelId, nBuildId)
    if self.curLevel ~= nil then
        printError("当前关卡level不为空1")
        return
    end
    self._EntryTime = CS.ClientManager.Instance.serverTimeStampWithTimeZone
    local luaClass =  require "Game.Adventure.ActivityLevels.ActivityLevelsInstanceLevel"
    if luaClass == nil then
        return
    end
    self.curLevel = luaClass
    if type(self.curLevel.BindEvent) == "function" then
        self.curLevel:BindEvent()
    end
    if type(self.curLevel.Init) == "function" then
        self.curLevel:Init(self,nActivityId,nLevelId,nBuildId)
    end
end

--结算
function ActivityLevelTypeData:SendActivityLevelSettleReq(nActivityId,nStar,callback)
    if nStar > 0 then
        self:EventUpload(1)
    else
        self:EventUpload(2)
    end

    local msg = {}
    msg.ActivityId = nActivityId
    msg.Star = nStar
    msg.Events =  {List = PlayerData.Achievement:GetBattleAchievement(GameEnum.levelType.ActivityLevels,nStar > 0)}
    local function msgCallback(_, msgData)
        --self.curLevel:Init
        if callback ~= nil then
            --self.entryLevelId = nLevelId
            --self.entryBuildId = nBuildId
            if self.levelTabExplore[self.entryLevelId] then
                self.levelTabExplore[self.entryLevelId].Star = nStar > self.levelTabExplore[self.entryLevelId].Star and nStar or self.levelTabExplore[self.entryLevelId].Star
                self.levelTabExplore[self.entryLevelId].BuildId = self.entryBuildId

            end

            if self.levelTabAdventure[self.entryLevelId] then
                self.levelTabAdventure[self.entryLevelId].Star = nStar > self.levelTabAdventure[self.entryLevelId].Star and nStar or self.levelTabAdventure[self.entryLevelId].Star
                self.levelTabAdventure[self.entryLevelId].BuildId = self.entryBuildId
            end
            if callback ~= nil then
                local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(msgData.ChangeInfo)
                HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
                callback(msgData.Fixed,msgData.First,msgData.Exp, msgData.ChangeInfo)
            end
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_levels_settle_req, msg, nil, msgCallback)
end

function ActivityLevelTypeData:EventUpload(result)
    ------埋点数据------
    self._EndTime = CS.ClientManager.Instance.serverTimeStampWithTimeZone
    local tabUpLevel = {}
    table.insert(tabUpLevel,{"role_id",tostring(PlayerData.Base._nPlayerId)})
    table.insert(tabUpLevel,{"game_cost_time",tostring(self._TotalTime)})
    table.insert(tabUpLevel,{"real_cost_time",tostring(self._EndTime - self._EntryTime)})
    table.insert(tabUpLevel,{"build_id",tostring(self.entryBuildId)})
    table.insert(tabUpLevel,{"battle_id",tostring(self.entryLevelId)})
    table.insert(tabUpLevel,{"battle_result",tostring(result)})
    NovaAPI.UserEventUpload("activity_battle",tabUpLevel)
    ------埋点数据------
end

--扫荡
function ActivityLevelTypeData:SendActivityLevelsSweepReq(nActivityId,nLevelId,nTimes,callback)
    if nActivityId ~= self.nActId then
        return
    end
    local msg = {}
    msg.ActivityId = self.nActId
    msg.LevelId = nLevelId
    msg.Times = nTimes
    local function successCallback(_, mapMainData)
        --处理扫荡信息
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMainData.ChangeInfo)
        HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
        callback(mapMainData.Rewards, mapMainData.ChangeInfo)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_levels_sweep_req, msg, nil, successCallback)
end

function ActivityLevelTypeData:LevelEnd()
    self.curLevel = nil
end

function ActivityLevelTypeData:GetCachedBuildId(nLevelId)
    return self.tabCachedBuildId[nLevelId] or 0
end

function ActivityLevelTypeData:SetCachedSelBuildId(nBuildId,levelId)
    self.tabCachedBuildId[levelId] = nBuildId
end

function ActivityLevelTypeData:GetLevelBuild(nLevelId)
    if self.levelTabExplore[nLevelId] then
        if self.levelTabExplore[nLevelId].BuildId ~= 0 then
            return self.levelTabExplore[nLevelId].BuildId
        else
            local PreLevelId = self.levelTabExplore[nLevelId].baseData.PreLevelId
            if PreLevelId ~= 0 then
                return self.levelTabExplore[PreLevelId].BuildId
            end
        end
    end

    if self.levelTabAdventure[nLevelId] then
        if self.levelTabAdventure[nLevelId].BuildId ~= 0 then
            return self.levelTabAdventure[nLevelId].BuildId
        else
            local PreLevelId = self.levelTabAdventure[nLevelId].baseData.PreLevelId
            if PreLevelId ~= 0 then
                if self.levelTabAdventure[PreLevelId] then
                    return self.levelTabAdventure[PreLevelId].BuildId
                else
                    return self.levelTabExplore[PreLevelId].BuildId
                end
            end
        end
    end

    return 0
end

function ActivityLevelTypeData:GetLevelStar(nLevelId)
    if self.levelTabExplore[nLevelId] then
        return self.levelTabExplore[nLevelId].Star
    end

    if self.levelTabAdventure[nLevelId] then
        return self.levelTabAdventure[nLevelId].Star
    end

    return 0
end

return ActivityLevelTypeData