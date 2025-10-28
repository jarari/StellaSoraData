local PopUpData = class("PopUpData")
local LocalData = require "GameCore.Data.LocalData"

function PopUpData:Init()
    self.tbPopUpConfig = {} -- 存储PopUp类型数据的表格
    self.tbPopUpData = {} -- 等待弹出的PopUp数据
    self:ParseConfig()
end

function PopUpData:ParseConfig()
    local function foreachPopup(mapData)
        self:CachedPopUpConfig(mapData)
    end
    ForEachTableLine(ConfigTable.Get("PopUp"), foreachPopup)
end

function PopUpData:CachedPopUpConfig(mapData)
    if mapData.PopUpType == GameEnum.PopUpType.Activity or mapData.PopUpType == GameEnum.PopUpType.ActivityGroup then
        self.tbPopUpConfig[mapData.ActivityId] = mapData.Id
    elseif mapData.PopUpType == GameEnum.PopUpType.OwnPopUP then
        if self:CheckPopUpOpen(mapData) then
            self.tbPopUpData[mapData.ActivityId] = mapData.Id
        end
    end
end

function PopUpData:CheckPopUpOpen(mapData)
    if mapData.StartCondType == GameEnum.activityAcceptCond.WorldClassSpecific then
        local nWorldCalss = PlayerData.Base:GetWorldClass()
        if nWorldCalss >= mapData.StartCondParams[1] then
            local nStartTime = 0
            local nEndTime = 0
            local curTime = CS.ClientManager.Instance.serverTime
            if mapData.StartType == GameEnum.activityOpenType.Date then
                nStartTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(mapData.StartTime)
            end
            if mapData.EndType == GameEnum.activityEndType.Date then
                nEndTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(mapData.EndTime)
            elseif mapData.EndType == GameEnum.activityEndType.TimeLimit then
                nEndTime = nStartTime + mapData.EndDuration * 86400
            end
            if curTime >= nStartTime and curTime <= nEndTime then
                return true
            end
        end
        return false
    end
    return false
end

function PopUpData:InsertPopUpQueue(tbPopUpList)
    table.sort(tbPopUpList, function(a, b)
        if self.tbPopUpConfig[a] ~= nil and self.tbPopUpConfig[b] ~= nil then
            local cfgA = ConfigTable.GetData("PopUp", self.tbPopUpConfig[a])
            local cfgB = ConfigTable.GetData("PopUp", self.tbPopUpConfig[b])
            return cfgA.SortId < cfgB.SortId 
        end
        return false
    end)
    PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.ActivityFaceAnnounce, tbPopUpList)
end

local function GetCurrentYearInfo(time_s)
    local day=os.date("%d",time_s)
    local weekIndex = os.date("%W", time_s)
    local month=os.date("%m",time_s)
    local yearNum = os.date("%Y",time_s) 
    return {
        year = yearNum,
        month=month,
        weekIdx = weekIndex,
        day=day,
    }
end

function PopUpData:IsNeedPopUp(actId)
    if self.tbPopUpConfig[actId] ~= nil then
        local cfg = ConfigTable.GetData("PopUp", self.tbPopUpConfig[actId])
        local localData = LocalData.GetPlayerLocalData("Act_PopUp"..actId)
        if cfg.PopRefreshType == GameEnum.PopRefreshType.WholeFirst then
            if nil == localData then
                return cfg.PopUpRes ~= nil
            end
        elseif cfg.PopRefreshType == GameEnum.PopRefreshType.DailyFirst then
            if nil == localData then
                return cfg.PopUpRes ~= nil
            else
                local dateA = GetCurrentYearInfo(tonumber(localData))
                local dateB = GetCurrentYearInfo(CS.ClientManager.Instance.serverTimeStamp)
                local isSameDay = dateA.day == dateB.day and dateA.month==dateB.month and dateA.year == dateB.year
                return not isSameDay and cfg.PopUpRes ~= nil
            end
        end
        return cfg.PopUpRes ~= nil
    end
    return false
end

function PopUpData:GetPopUpConfigData(actId)
    if self.tbPopUpConfig[actId] ~= nil then
        local cfg = ConfigTable.GetData("PopUp", self.tbPopUpConfig[actId])
        return cfg
    end
    return nil
end

return PopUpData