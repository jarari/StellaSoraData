local TimerStatus = require("GameCore.Timer.TimerStatus")
local TimerResetType = require("GameCore.Timer.TimerResetType")
local TimerScaleType = require("GameCore.Timer.TimerScaleType")
local Time = (CS.UnityEngine).Time
local Timer = class("Timer")
Timer.ctor = function(self, mapParam)
  -- function num : 0_0 , upvalues : TimerStatus
  if mapParam.bAutoRun == true or mapParam.bAutoRun == nil then
    self._status = TimerStatus.Running
  else
    self._status = TimerStatus.ReadyToGo
  end
  self._nCreateTS = mapParam.nTs
  self._nTS = mapParam.nTs
  self._nPauseTS = 0
  self._bDestroyWhenComplete = mapParam.bDestroyWhenComplete
  self._nCurCount = 0
  self._nTargetCount = mapParam.nTargetCount
  self._nElapsed = 0
  self._nInterval = mapParam.nInterval
  self._nScaleType = mapParam.nScaleType
  self._data = mapParam.data
  self._listener = mapParam.listener
  self._callback = mapParam.callback
  self._nDelCountLimit = 10
  self._nRate = 1
  self._nRange = 0
  self._bDebugWatch = false
end

Timer._Run = function(self, nCurTS)
  -- function num : 0_1 , upvalues : _ENV, TimerStatus
  if type(self._nInterval) ~= "number" or self._nInterval <= 0 or self._callback == nil then
    self:Cancel(false)
    return 
  end
  if self._status ~= TimerStatus.Running then
    return 
  end
  self._nElapsed = self._nElapsed + (nCurTS - self._nTS)
  self._nTS = nCurTS
  local nInterval = self._nInterval / self._nRate
  do
    if self._nElapsed < nInterval then
      local nRemain = nInterval - self._nElapsed
      if nRemain > 60 then
        self._nRange = 2
      else
        if nRemain > 1 then
          self._nRange = 1
        else
          self._nRange = 0
        end
      end
      return 
    end
    local nDelCount = (math.floor)(self._nElapsed / nInterval)
    self._nElapsed = self._nElapsed - nDelCount * nInterval
    if self._nTargetCount <= 0 then
      self:_DoCallback()
    else
      if self._nTargetCount <= self._nCurCount + nDelCount then
        nDelCount = self._nTargetCount - self._nCurCount
        self._nCurCount = self._nTargetCount
        self:_Stop()
        self._nElapsed = 0
      else
        self._nCurCount = self._nCurCount + (nDelCount)
      end
      if self._nDelCountLimit <= nDelCount then
        nDelCount = 1
      end
      for i = 1, nDelCount do
        self:_DoCallback()
      end
    end
  end
end

Timer._Stop = function(self)
  -- function num : 0_2 , upvalues : TimerStatus
  if self._bDestroyWhenComplete == true then
    self._status = TimerStatus.Destroy
  else
    self._status = TimerStatus.Complete
  end
end

Timer._ResetTimeStamp = function(self, bIsPauseTS)
  -- function num : 0_3 , upvalues : _ENV, TimerScaleType, Time
  local TimerManager = require("GameCore.Timer.TimerManager")
  if bIsPauseTS == true then
    if self._nScaleType == TimerScaleType.None then
      self._nPauseTS = Time.time
    else
      if self._nScaleType == TimerScaleType.Unscaled then
        self._nPauseTS = (TimerManager.GetUnscaledTime)()
      else
        if self._nScaleType == TimerScaleType.RealTime then
          self._nPauseTS = Time.realtimeSinceStartup
        end
      end
    end
  else
    if self._nScaleType == TimerScaleType.None then
      self._nTS = Time.time
    else
      if self._nScaleType == TimerScaleType.Unscaled then
        self._nTS = (TimerManager.GetUnscaledTime)()
      else
        if self._nScaleType == TimerScaleType.RealTime then
          self._nTS = Time.realtimeSinceStartup
        end
      end
    end
    self._nCreateTS = self._nTS
  end
end

Timer._DoCallback = function(self)
  -- function num : 0_4
  if self._listener == nil then
    (self._callback)(self, self._data)
  else
    ;
    (self._callback)(self._listener, self, self._data)
  end
end

Timer.Pause = function(self, bSetPause)
  -- function num : 0_5 , upvalues : _ENV, TimerStatus, TimerScaleType, Time
  self._nRange = 0
  if type(bSetPause) ~= "boolean" then
    bSetPause = true
  end
  if bSetPause == true and self._status == TimerStatus.Running then
    self:_ResetTimeStamp(true)
    self._status = TimerStatus.Pause
  else
    if bSetPause == false then
      if self._status == TimerStatus.Pause then
        local TimerManager = require("GameCore.Timer.TimerManager")
        if self._nScaleType == TimerScaleType.None then
          self._nTS = self._nTS + (Time.time - self._nPauseTS)
        else
          if self._nScaleType == TimerScaleType.Unscaled then
            self._nTS = self._nTS + ((TimerManager.GetUnscaledTime)() - self._nPauseTS)
          else
            if self._nScaleType == TimerScaleType.RealTime then
              self._nTS = self._nTS + (Time.realtimeSinceStartup - self._nPauseTS)
            end
          end
        end
        self._nPauseTS = 0
        self._status = TimerStatus.Running
      else
        do
          if self._status == TimerStatus.ReadyToGo then
            self:_ResetTimeStamp(false)
            self._status = TimerStatus.Running
          end
        end
      end
    end
  end
end

Timer.Cancel = function(self, bInvokeCallback)
  -- function num : 0_6 , upvalues : TimerStatus
  self._status = TimerStatus.Destroy
  if bInvokeCallback == true and self._listener ~= nil and self._callback ~= nil then
    self:_DoCallback()
  end
end

Timer.Reset = function(self, nResetType, nNewInterval)
  -- function num : 0_7 , upvalues : TimerStatus, TimerResetType, _ENV
  self._nRange = 0
  if self._status == TimerStatus.Destroy then
    return 
  end
  if nResetType == nil then
    nResetType = TimerResetType.ResetAll
  end
  if nResetType == TimerResetType.ResetAll then
    self._status = TimerStatus.Running
    self._nCurCount = 0
    self._nElapsed = 0
    self._nPauseTS = 0
    self:_ResetTimeStamp(false)
  else
    if nResetType == TimerResetType.ResetCount then
      self._nCurCount = 0
    else
      if nResetType == TimerResetType.ResetElapsed then
        self._nElapsed = 0
        self._nPauseTS = 0
        self:_ResetTimeStamp(false)
      end
    end
  end
  if type(nNewInterval) == "number" then
    self._nInterval = nNewInterval
  end
end

Timer.GetRemainInterval = function(self)
  -- function num : 0_8 , upvalues : TimerStatus, _ENV, TimerScaleType, Time
  if self._status == TimerStatus.Running then
    local TimerManager = require("GameCore.Timer.TimerManager")
    if self._nScaleType == TimerScaleType.None then
      return self._nInterval - (self._nElapsed + Time.time - self._nTS)
    else
      if self._nScaleType == TimerScaleType.Unscaled then
        return self._nInterval - (self._nElapsed + (TimerManager.GetUnscaledTime)() - self._nTS)
      else
        if self._nScaleType == TimerScaleType.RealTime then
          return self._nInterval - (self._nElapsed + Time.realtimeSinceStartup - self._nTS)
        end
      end
    end
  else
    do
      if self._status == TimerStatus.Pause then
        return self._nInterval - (self._nElapsed + self._nPauseTS - self._nTS)
      else
        return 0
      end
    end
  end
end

Timer.GetRenmainTime = function(self)
  -- function num : 0_9 , upvalues : TimerStatus, _ENV, TimerScaleType, Time
  local nTotalTime = self._nTargetCount * self._nInterval
  local nPassedTime = self._nInterval * self._nCurCount + self._nElapsed
  if self._status == TimerStatus.Running then
    local TimerManager = require("GameCore.Timer.TimerManager")
    if self._nScaleType == TimerScaleType.None then
      nPassedTime = nPassedTime + (Time.time - self._nTS)
    else
      if self._nScaleType == TimerScaleType.Unscaled then
        nPassedTime = nPassedTime + ((TimerManager.GetUnscaledTime)() - self._nTS)
      else
        if self._nScaleType == TimerScaleType.RealTime then
          nPassedTime = nPassedTime + (Time.realtimeSinceStartup - self._nTS)
        end
      end
    end
    return nTotalTime - (nPassedTime)
  else
    do
      if self._status == TimerStatus.Pause then
        nPassedTime = nPassedTime + (self._nPauseTS - self._nTS)
        return nTotalTime - (nPassedTime)
      else
        return 0
      end
    end
  end
end

Timer.GetDelTS = function(self)
  -- function num : 0_10
  return self._nTS - self._nCreateTS
end

Timer.GetCreateTS = function(self)
  -- function num : 0_11
  return self._nCreateTS
end

Timer.GetCurTS = function(self)
  -- function num : 0_12
  return self._nTS
end

Timer.GetCurCount = function(self)
  -- function num : 0_13
  return self._nCurCount
end

Timer.SetSpeed = function(self, rate)
  -- function num : 0_14
  if rate <= 0 then
    return 
  end
  self._nRate = rate
  self._nRange = 0
end

Timer.IsUnused = function(self)
  -- function num : 0_15 , upvalues : TimerStatus
  do return self._status == TimerStatus.Destroy end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

Timer.PrintSelf = function(self)
  -- function num : 0_16 , upvalues : _ENV
  local tb = {["状态"] = self._status, ["创建时间"] = self._nCreateTS, ["时间戳"] = self._nTS, ["暂停时间戳"] = self._nPauseTS, ["完成时销毁"] = self._bDestroyWhenComplete, ["已触发次数"] = self._nCurCount, ["目标触发次数"] = self._nTargetCount, ["已流逝"] = self._nElapsed, ["触发间隔"] = self._nInterval, ["缩放类型"] = self._nScaleType, ["一帧里触发极限次数"] = self._nDelCountLimit, ["速率"] = self._nRate, ["精度"] = self._nRange, ["监视"] = self._bDebugWatch}
  printTable(tb)
end

return Timer

