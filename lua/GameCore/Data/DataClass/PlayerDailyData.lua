--玩家每日数据
------------------------------ local ------------------------------
local TimerManager = require "GameCore.Timer.TimerManager"
local TimerScaleType = require "GameCore.Timer.TimerScaleType"
local ClientManager = CS.ClientManager.Instance

-------------------------------------------------------------------
local _bManual = false
local _nDailyCheckInIndex = 0
local templateDailyCheckInData = nil

------------------------------ 月卡 -------------------------------
-- 这里只有每日领取管理，商品月卡数据在商店相关货物下发内
local function ProcessMonthlyCard(mapMsgData)
    local mapReward = PlayerData.Item:ProcessRewardChangeInfo(mapMsgData.Change)
    local nEndTime = mapMsgData.EndTime
    local nId = mapMsgData.Id
    local mapNext = {
        mapReward = mapReward,
        nEndTime = nEndTime,
        nRemaining = mapMsgData.Remaining,
        nId = nId
    }
    PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.MonthlyCard, mapNext)
end
------------------------------ 签到 -------------------------------
local function CacheDailyCheckIn(nIndex)
    if nIndex == nil then
        return
    end
    _nDailyCheckInIndex = nIndex
end

local function ProcessDailyCheckIn(mapMsgData)
    _nDailyCheckInIndex = mapMsgData.Index
    if not PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.SignIn) then
        templateDailyCheckInData = mapMsgData
        return
    end
    local mapReward = PlayerData.Item:ProcessRewardChangeInfo(mapMsgData.Change)
    PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.DailyCheckIn, mapReward)
end

local function CheckDailyCheckIn()
    local bOpen = PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.SignIn)
    if templateDailyCheckInData ~= nil and bOpen then
        local mapReward = PlayerData.Item:ProcessRewardChangeInfo(templateDailyCheckInData.Change)
        PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.DailyCheckIn, mapReward)
        templateDailyCheckInData = nil
    end
end

local function GetDailyCheckInList(nDays)
    local tbReward = CacheTable.GetData("_SignIn", nDays)
    if not tbReward then
        printError("当前月的天数是" .. nDays .. "，没有相关配置，拿31天的数据顶了")
        tbReward = CacheTable.GetData("_SignIn", 31)
    end
    return tbReward
end
local function GetMonthAndDays()
    local nServerTimeStampWithTimeZone = ClientManager.serverTimeStampWithTimeZone
    local nYear = tonumber(os.date("!%Y", nServerTimeStampWithTimeZone))
    local nMonth = tonumber(os.date("!%m", nServerTimeStampWithTimeZone))
    local nDay = tonumber(os.date("!%d", nServerTimeStampWithTimeZone))
    local nHour = tonumber(os.date("!%H", nServerTimeStampWithTimeZone))

    if nDay == 1 and nHour < 5 then
        nMonth = nMonth == 1 and 12 or nMonth - 1
    end

    local nNextMonthTime = os.time({year = tostring(nYear), month = nMonth + 1, day = 0})
    local nDays = tonumber(os.date("!%d", nNextMonthTime))

    return nMonth, nDays
end

local function GetDailyCheckInIndex()
    if _nDailyCheckInIndex == 0 then
        printError("签到：没有签到数据，不知道是签到第几天")
    end
    return _nDailyCheckInIndex
end
-------------------------------------------------------------------

------------------------------ public -----------------------------

local function ProcessTableData()
    local _SignIn = {}
    local function func_ForEach(mapLineData)
        local mapLine = {
            ItemId = mapLineData.ItemId,
            ItemQty = mapLineData.ItemQty
        }
        if not _SignIn[mapLineData.Group] then
            _SignIn[mapLineData.Group] = {}
        end
        _SignIn[mapLineData.Group][mapLineData.Day] = mapLine
    end
    ForEachTableLine(DataTable.SignIn, func_ForEach)
    CacheTable.Set("_SignIn", _SignIn)
end

local function Init()
    _bManual = false
    _nDailyCheckInIndex = 0
    ProcessTableData()
end

local function UnInit()
    _bManual = false
    _nDailyCheckInIndex = 0
end


local function CacheDailyData(nIndex)
    CacheDailyCheckIn(nIndex)
end

local function SetManualPanel(state)
    _bManual = state
end

local PlayerDailyData = {
    Init = Init,
    UnInit = UnInit,
    GetMonthAndDays = GetMonthAndDays,
    GetDailyCheckInIndex = GetDailyCheckInIndex,
    GetDailyCheckInList = GetDailyCheckInList,
    SetManualPanel = SetManualPanel,
    CacheDailyData = CacheDailyData,
    ProcessMonthlyCard = ProcessMonthlyCard,
    ProcessDailyCheckIn = ProcessDailyCheckIn,
    CheckDailyCheckIn = CheckDailyCheckIn, 
}

return PlayerDailyData