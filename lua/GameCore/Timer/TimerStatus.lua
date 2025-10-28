local TimerStatus = 
{
    ReadyToGo = 0, -- 创建计时器后并非立即开始运行，待开始运行时刷新一下启动时的时间戳
    Running = 1, -- 正常运行中
    Pause = 2, -- 暂停挂起中
    Complete = 3, -- 完成（但不销毁，可再次启用）
    Destroy = 4, -- 可以销毁（从管理器队列中移除）
}
return TimerStatus
