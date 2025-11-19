local TimerManager = require("GameCore.Timer.TimerManager")
local TimerScaleType = require("GameCore.Timer.TimerScaleType")
local ClientManager = (CS.ClientManager).Instance
local _bManual = false
local _nDailyCheckInIndex = 0
local templateDailyCheckInData = nil
local ProcessMonthlyCard = function(mapMsgData)
  -- function num : 0_0 , upvalues : _ENV
  local mapReward = (PlayerData.Item):ProcessRewardChangeInfo(mapMsgData.Change)
  local nEndTime = mapMsgData.EndTime
  local nId = mapMsgData.Id
  local mapNext = {mapReward = mapReward, nEndTime = nEndTime, nRemaining = mapMsgData.Remaining, nId = nId}
  ;
  (PopUpManager.PopUpEnQueue)((GameEnum.PopUpSeqType).MonthlyCard, mapNext)
end

local CacheDailyCheckIn = function(nIndex)
  -- function num : 0_1 , upvalues : _nDailyCheckInIndex
  if nIndex == nil then
    return 
  end
  _nDailyCheckInIndex = nIndex
end

local ProcessDailyCheckIn = function(mapMsgData)
  -- function num : 0_2 , upvalues : _nDailyCheckInIndex, _ENV, templateDailyCheckInData
  _nDailyCheckInIndex = mapMsgData.Index
  if not (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).SignIn) then
    templateDailyCheckInData = mapMsgData
    return 
  end
  local mapReward = (PlayerData.Item):ProcessRewardChangeInfo(mapMsgData.Change)
  ;
  (PopUpManager.PopUpEnQueue)((GameEnum.PopUpSeqType).DailyCheckIn, mapReward)
end

local CheckDailyCheckIn = function()
  -- function num : 0_3 , upvalues : _ENV, templateDailyCheckInData
  local bOpen = (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).SignIn)
  if templateDailyCheckInData ~= nil and bOpen then
    local mapReward = (PlayerData.Item):ProcessRewardChangeInfo(templateDailyCheckInData.Change)
    ;
    (PopUpManager.PopUpEnQueue)((GameEnum.PopUpSeqType).DailyCheckIn, mapReward)
    templateDailyCheckInData = nil
  end
end

local GetDailyCheckInList = function(nDays)
  -- function num : 0_4 , upvalues : _ENV
  local tbReward = (CacheTable.GetData)("_SignIn", nDays)
  if not tbReward then
    printError("当前月的天数是" .. nDays .. "，没有相关配置，拿31天的数据顶了")
    tbReward = (CacheTable.GetData)("_SignIn", 31)
  end
  return tbReward
end

local GetMonthAndDays = function()
  -- function num : 0_5 , upvalues : ClientManager, _ENV
  local nServerTimeStampWithTimeZone = ClientManager.serverTimeStampWithTimeZone
  local nYear = tonumber((os.date)("!%Y", nServerTimeStampWithTimeZone))
  local nMonth = tonumber((os.date)("!%m", nServerTimeStampWithTimeZone))
  local nDay = tonumber((os.date)("!%d", nServerTimeStampWithTimeZone))
  local nHour = tonumber((os.date)("!%H", nServerTimeStampWithTimeZone))
  if nDay == 1 and nHour < 5 and (nMonth ~= 1 or not 12) then
    nMonth = nMonth - 1
  end
  local nNextMonthTime = (os.time)({year = tostring(nYear), month = nMonth + 1, day = 0})
  local nDays = tonumber((os.date)("!%d", nNextMonthTime))
  return nMonth, nDays
end

local GetDailyCheckInIndex = function()
  -- function num : 0_6 , upvalues : _nDailyCheckInIndex, _ENV
  if _nDailyCheckInIndex == 0 then
    printError("签到：没有签到数据，不知道是签到第几天")
  end
  return _nDailyCheckInIndex
end

local ProcessTableData = function()
  -- function num : 0_7 , upvalues : _ENV
  local _SignIn = {}
  local func_ForEach = function(mapLineData)
    -- function num : 0_7_0 , upvalues : _SignIn
    local mapLine = {ItemId = mapLineData.ItemId, ItemQty = mapLineData.ItemQty}
    if not _SignIn[mapLineData.Group] then
      _SignIn[mapLineData.Group] = {}
    end
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (_SignIn[mapLineData.Group])[mapLineData.Day] = mapLine
  end

  ForEachTableLine(DataTable.SignIn, func_ForEach)
  ;
  (CacheTable.Set)("_SignIn", _SignIn)
end

local Init = function()
  -- function num : 0_8 , upvalues : _bManual, _nDailyCheckInIndex, ProcessTableData
  _bManual = false
  _nDailyCheckInIndex = 0
  ProcessTableData()
end

local UnInit = function()
  -- function num : 0_9 , upvalues : _bManual, _nDailyCheckInIndex
  _bManual = false
  _nDailyCheckInIndex = 0
end

local CacheDailyData = function(nIndex)
  -- function num : 0_10 , upvalues : CacheDailyCheckIn
  CacheDailyCheckIn(nIndex)
end

local SetManualPanel = function(state)
  -- function num : 0_11 , upvalues : _bManual
  _bManual = state
end

local PlayerDailyData = {Init = Init, UnInit = UnInit, GetMonthAndDays = GetMonthAndDays, GetDailyCheckInIndex = GetDailyCheckInIndex, GetDailyCheckInList = GetDailyCheckInList, SetManualPanel = SetManualPanel, CacheDailyData = CacheDailyData, ProcessMonthlyCard = ProcessMonthlyCard, ProcessDailyCheckIn = ProcessDailyCheckIn, CheckDailyCheckIn = CheckDailyCheckIn}
return PlayerDailyData

