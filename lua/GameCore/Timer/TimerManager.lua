local Timer = require("GameCore.Timer.Timer")
local TimerStatus = require("GameCore.Timer.TimerStatus")
local TimerScaleType = require("GameCore.Timer.TimerScaleType")
local Time = (CS.UnityEngine).Time
local TimerManager = {}
local MAX_TIMER_COUNT = 500
local tbTimer, tbTempAddTimer = nil, nil
local nDelUnscaledTime = 0
local nUnscaledTime = 0
local bCheckRange1 = false
local bCheckRange2 = false
local nLastTS_Range1 = 0
local nLastTS_Range2 = 0
local bForceFrameUpdate = false
local CheckRange = function()
  -- function num : 0_0 , upvalues : nUnscaledTime, nLastTS_Range1, bCheckRange1, nLastTS_Range2, bCheckRange2
  if nUnscaledTime - nLastTS_Range1 >= 1 then
    nLastTS_Range1 = nUnscaledTime
    bCheckRange1 = true
  else
    bCheckRange1 = false
  end
  if nUnscaledTime - nLastTS_Range2 >= 60 then
    nLastTS_Range2 = nUnscaledTime
    bCheckRange2 = true
  else
    bCheckRange2 = false
  end
end

local ProcAddTimer = function()
  -- function num : 0_1 , upvalues : tbTimer, _ENV, tbTempAddTimer
  if tbTimer == nil then
    return 
  end
  if type(tbTempAddTimer) ~= "table" or #tbTempAddTimer <= 0 then
    return 
  end
  for i,timer in ipairs(tbTempAddTimer) do
    (table.insert)(tbTimer, timer)
  end
  tbTempAddTimer = {}
end

local ProcUpdateTimer = function()
  -- function num : 0_2 , upvalues : tbTimer, CheckRange, _ENV, bForceFrameUpdate, bCheckRange1, bCheckRange2, TimerScaleType, Time, nUnscaledTime
  if tbTimer == nil then
    return 
  end
  CheckRange()
  for i,timer in ipairs(tbTimer) do
    if bForceFrameUpdate == true or ((timer._nRange == 1 and bCheckRange1 == true) or timer._nRange ~= 2 or bCheckRange2 == true) then
      if timer._nScaleType == TimerScaleType.None then
        timer:_Run(Time.time)
      else
        if timer._nScaleType == TimerScaleType.Unscaled then
          timer:_Run(nUnscaledTime)
        else
          if timer._nScaleType == TimerScaleType.RealTime then
            timer:_Run(Time.realtimeSinceStartup)
          else
            ;
            (timer._Stop)()
          end
        end
      end
    end
  end
end

local ProcRemoveTimer = function()
  -- function num : 0_3 , upvalues : tbTimer, TimerStatus, _ENV
  if tbTimer == nil then
    return 
  end
  local nCount = #tbTimer
  for i = nCount, 1, -1 do
    local timer = tbTimer[i]
    if timer._status == TimerStatus.Destroy then
      (table.remove)(tbTimer, i)
    end
  end
end

TimerManager.MonoUpdate = function()
  -- function num : 0_4 , upvalues : nDelUnscaledTime, Time, nUnscaledTime, ProcAddTimer, ProcUpdateTimer, ProcRemoveTimer
  nDelUnscaledTime = Time.unscaledDeltaTime
  if Time.maximumDeltaTime < nDelUnscaledTime then
    nDelUnscaledTime = Time.maximumDeltaTime
  end
  nUnscaledTime = nUnscaledTime + nDelUnscaledTime
  ProcAddTimer()
  ProcUpdateTimer()
  ProcRemoveTimer()
end

local UnInit = function()
  -- function num : 0_5 , upvalues : tbTimer, tbTempAddTimer, _ENV, TimerManager, UnInit
  tbTimer = nil
  tbTempAddTimer = nil
  ;
  (EventManager.Remove)(EventId.CSLuaManagerShutdown, TimerManager, UnInit)
end

TimerManager.Init = function()
  -- function num : 0_6 , upvalues : tbTimer, tbTempAddTimer, _ENV, TimerManager, UnInit
  tbTimer = {}
  tbTempAddTimer = {}
  ;
  (EventManager.Add)(EventId.CSLuaManagerShutdown, TimerManager, UnInit)
end

TimerManager.Add = function(nTargetCount, nInterval, listener, callback, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
  -- function num : 0_7 , upvalues : tbTempAddTimer, tbTimer, MAX_TIMER_COUNT, _ENV, TimerScaleType, Time, nUnscaledTime, Timer
  if tbTempAddTimer == nil then
    return 
  end
  local nTotalCount = #tbTimer + #tbTempAddTimer
  if MAX_TIMER_COUNT <= nTotalCount then
    print("lua timer count reach max.")
    return nil
  end
  if callback == nil then
    print("lua timer need a callback.")
    return 
  end
  if nScaleType == true then
    nScaleType = TimerScaleType.Unscaled
  else
    if nScaleType == false then
      nScaleType = TimerScaleType.RealTime
    else
      nScaleType = TimerScaleType.None
    end
  end
  local mapParam = {}
  mapParam.bAutoRun = bAutoRun
  mapParam.bDestroyWhenComplete = bDestroyWhenComplete
  mapParam.nTargetCount = nTargetCount
  mapParam.nInterval = nInterval
  mapParam.nScaleType = nScaleType
  mapParam.data = tbParam
  mapParam.listener = listener
  mapParam.callback = callback
  if nScaleType == TimerScaleType.None then
    mapParam.nTs = Time.time
  else
    if nScaleType == TimerScaleType.Unscaled then
      mapParam.nTs = nUnscaledTime
    else
      if nScaleType == TimerScaleType.RealTime then
        mapParam.nTs = Time.realtimeSinceStartup
      end
    end
  end
  local timer = (Timer.new)(mapParam)
  ;
  (table.insert)(tbTempAddTimer, timer)
  return timer
end

TimerManager.Remove = function(timer, bInvokeCallback)
  -- function num : 0_8
  if timer ~= nil then
    timer:Cancel(bInvokeCallback)
  end
end

TimerManager.GetUnscaledTime = function()
  -- function num : 0_9 , upvalues : nUnscaledTime
  return nUnscaledTime
end

TimerManager.ForceFrameUpdate = function(bEnable)
  -- function num : 0_10 , upvalues : bForceFrameUpdate
  bForceFrameUpdate = bEnable == true
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

return TimerManager

