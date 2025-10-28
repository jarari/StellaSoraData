local TimerStatus = require "GameCore.Timer.TimerStatus"
local TimerResetType = require "GameCore.Timer.TimerResetType"
local TimerScaleType = require "GameCore.Timer.TimerScaleType"
local Time = CS.UnityEngine.Time
local Timer = class("Timer")
---@diagnostic disable-next-line: duplicate-set-field
function Timer:ctor(mapParam)
    if mapParam.bAutoRun == true or mapParam.bAutoRun == nil then
        self._status = TimerStatus.Running -- 创建后运行
    else
        self._status = TimerStatus.ReadyToGo -- 创建后暂停（通过Pause(false)启动）
    end
    self._nCreateTS = mapParam.nTs
    self._nTS = mapParam.nTs -- 时间戳，非创建后即运行的计时器，会在正式启动运行后刷新时间戳。
    self._nPauseTS = 0 -- 暂停时间戳
    self._bDestroyWhenComplete = mapParam.bDestroyWhenComplete -- 标记是否完成后就销毁该计时器
    self._nCurCount = 0 -- 当前回调已触发的次数
    self._nTargetCount = mapParam.nTargetCount -- 回调总共设定触发几次，<=0表示无限循环
    self._nElapsed = 0 -- 当前累计的已流逝时长，累计达到间隔时长后，会减去间隔时长（时间单位：秒）
    self._nInterval = mapParam.nInterval -- 间隔时长，每间隔多久触发一次回调（时间单位：秒）
    self._nScaleType = mapParam.nScaleType -- 计时器受时间缩放影响的类型
    self._data = mapParam.data -- 透传参数，在回调中可能需要使用
    self._listener = mapParam.listener
    self._callback = mapParam.callback
    self._nDelCountLimit = 10 -- 某一帧里判断到连续触发超过一定次数时，即调整为只触发一次。
    self._nRate = 1 -- 速率，实际间隔 = 设定间隔 / 倍率，如：间隔3秒触发一次回调的计时器，在速率=2时，实际是1.5秒触发一次回调。
    self._nRange = 0 -- 0每帧，1每秒，2每分钟
end
function Timer:_Run(nCurTS)
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
    if self._nElapsed < nInterval then
        local nRemain = nInterval - self._nElapsed -- 根据剩余时间动态调整，大于1分钟则每分钟检查，小于60秒大于1秒则每秒检查，小于1秒则每帧检查
        if nRemain > 60 then
            self._nRange = 2
        elseif nRemain > 1 then
            self._nRange = 1
        else
            self._nRange = 0
        end
        -- printLog("计时器检查频率：" .. tostring(self._nRange))
        return
    end
    local nDelCount = math.floor(self._nElapsed / nInterval)
    self._nElapsed = self._nElapsed - (nDelCount * nInterval)
    if self._nTargetCount <= 0 then
        self:_DoCallback()
    else
        if self._nCurCount + nDelCount >= self._nTargetCount then
            nDelCount = self._nTargetCount - self._nCurCount
            self._nCurCount = self._nTargetCount
            self:_Stop()
            self._nElapsed = 0
        else
            self._nCurCount = self._nCurCount + nDelCount
        end
        if nDelCount >= self._nDelCountLimit then
            nDelCount = 1
        end
        for i = 1, nDelCount, 1 do
            self:_DoCallback()
        end
    end
end
function Timer:_Stop()
    if self._bDestroyWhenComplete == true then
        self._status = TimerStatus.Destroy
    else
        self._status = TimerStatus.Complete
    end
end
function Timer:_ResetTimeStamp(bIsPauseTS)
    local TimerManager = require "GameCore.Timer.TimerManager"
    if bIsPauseTS == true then
        if self._nScaleType == TimerScaleType.None then
            self._nPauseTS = Time.time
        elseif self._nScaleType == TimerScaleType.Unscaled then
            self._nPauseTS = TimerManager.GetUnscaledTime()
        elseif self._nScaleType == TimerScaleType.RealTime then
            self._nPauseTS = Time.realtimeSinceStartup
        end
    else
        if self._nScaleType == TimerScaleType.None then
            self._nTS = Time.time
        elseif self._nScaleType == TimerScaleType.Unscaled then
            self._nTS = TimerManager.GetUnscaledTime()
        elseif self._nScaleType == TimerScaleType.RealTime then
            self._nTS = Time.realtimeSinceStartup
        end
        self._nCreateTS = self._nTS
    end
end
function Timer:_DoCallback()
    if self._listener == nil then
        self._callback(self, self._data)
    else
        self._callback(self._listener, self, self._data)
    end
    -- printLog(string.format("计时器执行回调, 频率: %s, 已触发次数: %s", tostring(self._nRange), tostring(self._nCurCount)))
end
-------------------- public function --------------------
-- bSetPause = true 暂停计时，bSetPause = false 恢复计时，不填默认为 true
function Timer:Pause(bSetPause)
    self._nRange = 0
    if type(bSetPause) ~= "boolean" then
        bSetPause = true
    end
    if bSetPause == true and self._status == TimerStatus.Running then
        self:_ResetTimeStamp(true)
        self._status = TimerStatus.Pause
    elseif bSetPause == false then
        if self._status == TimerStatus.Pause then
            local TimerManager = require "GameCore.Timer.TimerManager"
            if self._nScaleType == TimerScaleType.None then
                self._nTS = self._nTS + (Time.time - self._nPauseTS)
            elseif self._nScaleType == TimerScaleType.Unscaled then
                self._nTS = self._nTS + (TimerManager.GetUnscaledTime() - self._nPauseTS)
            elseif self._nScaleType == TimerScaleType.RealTime then
                self._nTS = self._nTS + (Time.realtimeSinceStartup - self._nPauseTS)
            end
            self._nPauseTS = 0
            self._status = TimerStatus.Running
        elseif self._status == TimerStatus.ReadyToGo then
            self:_ResetTimeStamp(false)
            self._status = TimerStatus.Running
        end
    end
end
-- 取消计时，无法被再次使用，bInvokeCallback 默认为 false，传 true 时会立即执行一下回调。
function Timer:Cancel(bInvokeCallback)
    self._status = TimerStatus.Destroy
    if bInvokeCallback == true and self._listener ~= nil and self._callback ~= nil then
        self:_DoCallback()
    end
end
-- 复位计时器，详见复位类型说明 TimerResetType
function Timer:Reset(nResetType, nNewInterval)
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
    elseif nResetType == TimerResetType.ResetCount then
        self._nCurCount = 0
    elseif nResetType == TimerResetType.ResetElapsed then
        self._nElapsed = 0
        self._nPauseTS = 0
        self:_ResetTimeStamp(false)
    end
    if type(nNewInterval) == "number" then
        self._nInterval = nNewInterval
    end
end
-- 获取距下一次回调剩余时间
function Timer:GetRemainInterval()
    if self._status == TimerStatus.Running then
        local TimerManager = require "GameCore.Timer.TimerManager"
        if self._nScaleType == TimerScaleType.None then
            return self._nInterval - (self._nElapsed + Time.time - self._nTS)
        elseif self._nScaleType == TimerScaleType.Unscaled then
            return self._nInterval - (self._nElapsed + TimerManager.GetUnscaledTime() - self._nTS)
        elseif self._nScaleType == TimerScaleType.RealTime then
            return self._nInterval - (self._nElapsed + Time.realtimeSinceStartup - self._nTS)
        end
    elseif self._status == TimerStatus.Pause then
        return self._nInterval - (self._nElapsed + self._nPauseTS - self._nTS)
    else
        return 0
    end
end
-- 获取计时器剩余时间
function Timer:GetRenmainTime()
    local nTotalTime = self._nTargetCount * self._nInterval
    local nPassedTime = self._nInterval * self._nCurCount + self._nElapsed
    if self._status == TimerStatus.Running then
        local TimerManager = require "GameCore.Timer.TimerManager"
        if self._nScaleType == TimerScaleType.None then
            nPassedTime = nPassedTime + (Time.time - self._nTS)
        elseif self._nScaleType == TimerScaleType.Unscaled then
            nPassedTime = nPassedTime + (TimerManager.GetUnscaledTime() - self._nTS)
        elseif self._nScaleType == TimerScaleType.RealTime then
            nPassedTime = nPassedTime + (Time.realtimeSinceStartup - self._nTS)
        end
        return nTotalTime - nPassedTime
    elseif self._status == TimerStatus.Pause then
        nPassedTime = nPassedTime + (self._nPauseTS - self._nTS)
        return nTotalTime - nPassedTime
    else
        return 0
    end
end
function Timer:GetDelTS()
    return self._nTS - self._nCreateTS
end
function Timer:GetCreateTS()
    return self._nCreateTS
end
function Timer:GetCurTS()
    return self._nTS
end
function Timer:GetCurCount()
    return self._nCurCount
end
function Timer:SetSpeed(rate)
    -- 注意慎用：与服务器时间有同步关系的计时器，不应设置计时器速率，仅客户端本地表现用的才可以。
    if rate <= 0 then return end
    self._nRate = rate
    self._nRange = 0
end
function Timer:IsUnused()
    return self._status == TimerStatus.Destroy
end
return Timer
