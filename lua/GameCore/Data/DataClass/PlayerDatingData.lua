local PlayerDatingData = class("PlayerDatingData")

function PlayerDatingData:Init()
    self.tbDatingCharIds = 0                        -- 当天已经邀约角色ID列表
    self.nAllDatingCount = 0       
    
    self.tbLandmarkCfg = {}                         -- 地点
    self.mapCharLimitedEvent = {}                   -- 特殊事件
    self.mapCharStartEvent = {}                     -- 角色开始事件
    self.mapCharEndEvent = {}                       -- 角色结束事件
    self.mapCharLandmark = {}                       -- 特殊事件触发地点（显示红点用）
    self.nCurSelectLandmark = 0                     -- 当前选中的地点id
    self.mapDelay = nil
    EventManager.Add(EventId.IsNewDay, self, self.OnEvent_NewDay)
    self:InitConfig()
end

function PlayerDatingData:UnInit()
    EventManager.Remove(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

function PlayerDatingData:InitConfig()
    self.nAllDatingCount = ConfigTable.GetConfigNumber("Dating_Max_Daily_Count")
    local function funcForeachLandmark(mapData)
        table.insert(self.tbLandmarkCfg, mapData)
    end
    ForEachTableLine(DataTable.DatingLandmark, funcForeachLandmark)
    
    local function funcForeachCharEvent(mapData)
        if mapData.DatingEventType == GameEnum.DatingEventType.LimitedLandmark then
            local param = decodeJson(mapData.DatingEventParams)
            if mapData.DatingEventParams ~= nil and #mapData.DatingEventParams == 2 then
                local nCharId = tonumber(mapData.DatingEventParams[1])
                local nLandmark = tonumber(mapData.DatingEventParams[2])
                if self.mapCharLimitedEvent[nCharId] == nil then
                    self.mapCharLimitedEvent[nCharId] = {}
                end
                local data = {Id = mapData.Id, LandMark = nLandmark, Status = AllEnum.DatingEventStatus.Lock}
                self.mapCharLimitedEvent[nCharId][mapData.Id] = data
                RedDotManager.SetValid(RedDotDefine.Phone_Dating_Reward, {nCharId, mapData.Id}, false)

                if self.mapCharLandmark[nCharId] == nil then
                    self.mapCharLandmark[nCharId] = {}
                end
                if self.mapCharLandmark[nCharId][nLandmark] == nil then
                    self.mapCharLandmark[nCharId][nLandmark] = {}
                end
                table.insert(self.mapCharLandmark[nCharId][nLandmark], mapData.Id)
            end
        end
    end
    ForEachTableLine(ConfigTable.Get("DatingCharacterEvent"), funcForeachCharEvent)
    
    local function funcForeachStartEndEvent(mapData)
        if mapData.DatingEventType == GameEnum.DatingEventType.Start then
            local nCharId = tonumber(mapData.DatingEventParams[1])
            if self.mapCharStartEvent[nCharId] == nil then
                self.mapCharStartEvent[nCharId] = {}
            end
            table.insert(self.mapCharStartEvent[nCharId], mapData.Id)
        elseif mapData.DatingEventType == GameEnum.DatingEventType.End then
            local nCharId = tonumber(mapData.DatingEventParams[1])
            if self.mapCharEndEvent[nCharId] == nil then
                self.mapCharEndEvent[nCharId] = {}
            end
            table.insert(self.mapCharEndEvent[nCharId], mapData.Id)
        end
    end
    ForEachTableLine(ConfigTable.Get("DatingStartEndEvent"), funcForeachStartEndEvent)
    local function foreachResponse(line)
        if nil == CacheTable.GetData("_DatingCharResponse", line.CharId) then
            CacheTable.SetData("_DatingCharResponse", line.CharId, {})
        end
        CacheTable.GetData("_DatingCharResponse", line.CharId)[line.Type] = line
    end
    ForEachTableLine(DataTable.DatingCharResponse, foreachResponse)
end

function PlayerDatingData:RefreshDatingCharIds(tbChar)
    self.tbDatingCharIds = tbChar
end

function PlayerDatingData:AddDatingCharId(nCharId)
    for _, v in ipairs(self.tbDatingCharIds) do
        if v == nCharId then
            printError("重复邀约！！！")
            return
        end
    end
    table.insert(self.tbDatingCharIds, nCharId)
end

function PlayerDatingData:CacheDatingCharIds(tbChar)
    self.tbDatingCharIds = tbChar
end

------------------------- public ---------------------------
function PlayerDatingData:GetRandomLandmark()
    if #self.tbLandmarkCfg <= 3 then
        return self.tbLandmarkCfg
    end
    
    local tbResult = {}
    local tbRandom = {}
    for i = 1, #self.tbLandmarkCfg do
        tbRandom[i] = i
    end
    for i = 1, 3 do
        local randomIndex = math.random(#tbRandom)
        local nSelectIndex = tbRandom[randomIndex]
        table.insert(tbResult, self.tbLandmarkCfg[nSelectIndex])
        table.remove(tbRandom, randomIndex)
    end
    return tbResult
end

function PlayerDatingData:CheckHasNewEvent(nCharId, nLandmark)
    local charData = PlayerData.Char:GetCharDatingEvent(nCharId)
    if charData ~= nil and self.mapCharLimitedEvent[nCharId] ~= nil then
        for nEId, v in pairs(self.mapCharLimitedEvent[nCharId]) do
            if v.LandMark  == nLandmark and v.Status == AllEnum.DatingEventStatus.Lock then
                return true
            end
        end
    end
    return false
end

function PlayerDatingData:RefreshLimitedEventList(nCharId, tbDatingEventIds, tbDatingEventRewardIds)
    if self.mapCharLimitedEvent[nCharId] ~= nil then
        for nEId, v in pairs(self.mapCharLimitedEvent[nCharId]) do
            for _, nId in ipairs(tbDatingEventIds) do
                if nId == nEId and self.mapCharLimitedEvent[nCharId][nEId].Status == AllEnum.DatingEventStatus.Lock then
                    self.mapCharLimitedEvent[nCharId][nEId].Status = AllEnum.DatingEventStatus.Unlock
                    RedDotManager.SetValid(RedDotDefine.Phone_Dating_Reward, {nCharId, nEId}, true)
                    break
                end
            end

            if tbDatingEventRewardIds ~= nil then
                for _, nId in ipairs(tbDatingEventRewardIds) do
                    if nId == nEId then
                        self.mapCharLimitedEvent[nCharId][nEId].Status = AllEnum.DatingEventStatus.Received
                        RedDotManager.SetValid(RedDotDefine.Phone_Dating_Reward, {nCharId, nEId}, false)
                        break
                    end
                end
            end
        end
    end
    if PlayerData.Phone ~= nil then
        PlayerData.Phone:RefreshRedDot()
    end
end

function PlayerDatingData:GetLimitedEventList(nCharId)
    local mapData = {}
    if self.mapCharLimitedEvent[nCharId] ~= nil then
        for nEId, v in pairs(self.mapCharLimitedEvent[nCharId]) do
            table.insert(mapData, v)
        end
    end
    table.sort(mapData, function(a, b)
        return a.Id < b.Id
    end)
    return mapData
end

function PlayerDatingData:GetDatingCount()
    return #self.tbDatingCharIds, self.nAllDatingCount
end

function PlayerDatingData:CheckDating(nCharId)
    local bDating = false
    for _, v in ipairs(self.tbDatingCharIds) do
        if v == nCharId then
            bDating = true
            break
        end
    end
    return bDating
end

function PlayerDatingData:SetCurLandmarkId(nLandmarkId)
    self.nCurSelectLandmark = nLandmarkId
end

function PlayerDatingData:GetCurLandmarkId()
    return self.nCurSelectLandmark
end

function PlayerDatingData:SetCharFavourLevelUpDelay(mapData)
    self.mapDelay = mapData
end

function PlayerDatingData:GetCharFavourLevelUpDelay()
    return self.mapDelay
end

function PlayerDatingData:GetCharStartEventId(nCharId)
    if self.mapCharStartEvent[nCharId] ~= nil then
        local nRandom = math.random(1, #self.mapCharStartEvent[nCharId])
        return self.mapCharStartEvent[nCharId][nRandom]
    end
end

function PlayerDatingData:GetCharBranchEventId(nCharId, bFirstBranch)
    local nEventId = 0
    local funcForeachEvent = function(mapData)
        if #mapData.DatingEventParams > 0 and mapData.DatingEventParams[1] == self.nCurSelectLandmark then
            -- 检查事件排除角色
            for k, v in pairs(mapData.DatingEventExclude) do
                if v == nCharId then
                    return
                end
            end
            
            local last_digit = math.abs(mapData.Id) % 10
            local nBranchFlag = bFirstBranch and 0 or 1
            if last_digit == nBranchFlag then
                nEventId = mapData.Id
            end
        end
    end
    ForEachTableLine(ConfigTable.Get("DatingBranch"), funcForeachEvent)
    return nEventId
end

function PlayerDatingData:GetCharEndEventId(nCharId)
    if self.mapCharEndEvent[nCharId] ~= nil then
        local nRandom = math.random(1, #self.mapCharEndEvent[nCharId])
        return self.mapCharEndEvent[nCharId][nRandom]
    end
end

--region http
function PlayerDatingData:SendDatingLandmarkSelectMsg(nCharId, nLandmarkId, callback)
    local successCallback = function(_, msgData)
        self:SetCurLandmarkId(nLandmarkId)
        self:AddDatingCharId(nCharId)
        if callback ~= nil then
            callback(msgData)
        end
    end
    local sendData = {
        CharId = nCharId,
        LandmarkId = nLandmarkId,
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.char_dating_landmark_select_req, sendData, nil, successCallback)
end

function PlayerDatingData:SendReceiveDatingEventRewardMsg(nCharId, nEventId, callback)
    local successCallback = function(_, msgData)
        self.mapCharLimitedEvent[nCharId][nEventId].Status = AllEnum.DatingEventStatus.Received
        RedDotManager.SetValid(RedDotDefine.Phone_Dating_Reward, {nCharId, nEventId}, false)
        PlayerData.Phone:RefreshRedDot()
        UTILS.OpenReceiveByChangeInfo(msgData, callback)
    end
    local sendData = {
        CharId = nCharId,
        EventId = nEventId,
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.char_dating_event_reward_receive_req, sendData, nil, successCallback)
end

function PlayerDatingData:SendDatingSendGiftMsg(nCharId, tbItems, callback)
    local successCallback = function(_, msgData)
        if callback ~= nil then
            callback(msgData)
        end
    end
    local sendData = {
        CharId = nCharId,
        Items = tbItems,
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.char_dating_gift_send_req, sendData, nil, successCallback)
end


--endregion

function PlayerDatingData:OnEvent_NewDay()
    self.tbDatingCharIds = {}
end



return PlayerDatingData