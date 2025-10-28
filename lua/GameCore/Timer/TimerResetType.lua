local TimerResetType = 
{
    ResetAll = 1, -- 完全重置
    ResetCount = 2, -- 仅重置当前已触发回调次数
    ResetElapsed = 3, -- 仅重置当前累计计时
}
return TimerResetType
