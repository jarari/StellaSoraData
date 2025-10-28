local Timer = require "GameCore.Timer.Timer"
local TimerStatus = require "GameCore.Timer.TimerStatus"
local TimerScaleType = require "GameCore.Timer.TimerScaleType"
local Time = CS.UnityEngine.Time
local TimerManager = {}
local MAX_TIMER_COUNT = 500 -- 暂时强制做个实例数量限制
local tbTimer = nil -- timer 实例数组（有数量限制）
local tbTempAddTimer = nil -- 待加入 timer 实例数组的临时数组

--[[
    经测试 UnityEngine.Time.unscaledTime 并非是一个不受 Time.timeScale 影响的 Time.time
    在 Unity Editor 下暂停或 App 被挂起时 Time.unscaledTime 仍然在累加时间（Time.time 不会累加）
    Lua 里自行累加 Time.unscaledDeltaTime
]]
local nDelUnscaledTime = 0
local nUnscaledTime = 0

-- 计时器按已流逝时长与间隔时长相差幅度来决定计时器轮询计算频率，暂定三档：每帧、每秒、每分钟。
local bCheckRange1 = false -- 是否检查“每秒”计时器
local bCheckRange2 = false -- 是否检查“每分钟”计时器
local nLastTS_Range1 = 0
local nLastTS_Range2 = 0
local bForceFrameUpdate = false

local function CheckRange()
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

local function ProcAddTimer()
    if tbTimer == nil then return end
    if type(tbTempAddTimer) ~= "table" or #tbTempAddTimer <= 0 then
        return
    end
    for i, timer in ipairs(tbTempAddTimer) do
        table.insert(tbTimer, timer)
    end
    tbTempAddTimer={}
end

local function ProcUpdateTimer()
    if tbTimer == nil then return end
    CheckRange()
    for i, timer in ipairs(tbTimer) do
        if bForceFrameUpdate == true or (timer._nRange == 0) or
            (timer._nRange == 1 and bCheckRange1 == true) or
            (timer._nRange == 2 and bCheckRange2 == true) then
            if timer._nScaleType == TimerScaleType.None then
                timer:_Run(Time.time)
            elseif timer._nScaleType == TimerScaleType.Unscaled then
                timer:_Run(nUnscaledTime)
            elseif timer._nScaleType == TimerScaleType.RealTime then
                timer:_Run(Time.realtimeSinceStartup)
            else
                timer._Stop()
            end
        end
    end
end

local function ProcRemoveTimer()
    if tbTimer == nil then
        return
    end
    local nCount = #tbTimer
    for i = nCount, 1, -1 do
        local timer = tbTimer[i]
        if timer._status == TimerStatus.Destroy then
            table.remove(tbTimer, i)
        end
    end
end

function TimerManager.MonoUpdate()
    nDelUnscaledTime = Time.unscaledDeltaTime
    if nDelUnscaledTime > Time.maximumDeltaTime then
        nDelUnscaledTime = Time.maximumDeltaTime
    end
    nUnscaledTime = nUnscaledTime + nDelUnscaledTime
    ProcAddTimer()
    ProcUpdateTimer()
    ProcRemoveTimer()
end

local function UnInit()
    tbTimer = nil
    tbTempAddTimer = nil
    EventManager.Remove(EventId.CSLuaManagerShutdown, TimerManager, UnInit)
end

function TimerManager.Init()
    tbTimer = {}
    tbTempAddTimer = {}
    EventManager.Add(EventId.CSLuaManagerShutdown, TimerManager, UnInit)
end

-------------------- public function --------------------
function TimerManager.Add(nTargetCount, nInterval, listener, callback, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
    if tbTempAddTimer == nil then return end
    local nTotalCount = #tbTimer + #tbTempAddTimer
    if nTotalCount >= MAX_TIMER_COUNT then
        print("lua timer count reach max.")
        return nil
    end
    if callback == nil then
        print("lua timer need a callback.")
        return
    end
    if nScaleType == true then
        nScaleType = TimerScaleType.Unscaled
    elseif nScaleType == false then
        nScaleType = TimerScaleType.RealTime
    else
        nScaleType = TimerScaleType.None
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
    elseif nScaleType == TimerScaleType.Unscaled then
        mapParam.nTs = nUnscaledTime
    elseif nScaleType == TimerScaleType.RealTime then
        mapParam.nTs = Time.realtimeSinceStartup
    end
    local timer = Timer.new(mapParam)
    table.insert(tbTempAddTimer, timer) -- 不直接加入管理列表中，在MonoUpdate中才真正加入。
    return timer
end

function TimerManager.Remove(timer, bInvokeCallback)
    if timer ~= nil then
        timer:Cancel(bInvokeCallback) -- 仅标记不直接移除，在MonoUpdate中才真正移除。
    end
end

function TimerManager.GetUnscaledTime()
    return nUnscaledTime
end

function TimerManager.ForceFrameUpdate(bEnable)
    bForceFrameUpdate = bEnable == true
end
return TimerManager
