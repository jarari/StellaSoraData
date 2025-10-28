local TimerScaleType = 
{
    None = 0,       -- UnityEngine.Time.time 受时间缩放影响，暂停或挂起后不累加时间。
    Unscaled = 1,   -- Lua 中累加的 UnityEngine.Time.unscaledDeltaTime 不受时间缩放影响，暂停或挂起后不累加时间。
    RealTime = 2,   -- UnityEngine.Time.realtimeSinceStartup 不受时间缩放影响，暂停或挂起后累加时间，即真实时间，恢复时若超过多个间隔时长将只增加回调触发次数，实际只触发一次回调。
}
return TimerScaleType
