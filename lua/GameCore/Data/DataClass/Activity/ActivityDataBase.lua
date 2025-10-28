local ActivityDataBase = class("ActivityDataBase")
local LocalData = require "GameCore.Data.LocalData"

---@diagnostic disable-next-line: duplicate-set-field
function ActivityDataBase:ctor(mapActData)
    self.nActId = mapActData.Id             -- 活动id
    self.actCfg = nil                       --活动表格数据
    self.nOpenTime = mapActData.StartTime   --活动开启时间（0表示活动没有开始）
    self.nEndTime = mapActData.EndTime      --活动结束时间（-1表示活动永不结束）
    self.bRedDot = false
    self.bBanner = false
    
    self.actCfg = ConfigTable.GetData("Activity", self.nActId)
    self:Init()
end

function ActivityDataBase:Init()
    
end

function ActivityDataBase:UpdateActivityState(mapState)
    self.bRedDot = mapState.RedDot        --首屏红点（true显示）
    self.bBanner = mapState.Banner        --banner图（true：移除banner图）
end

function ActivityDataBase:RefreshActivityData(mapActData)
    self.nOpenTime = mapActData.StartTime   
    self.nEndTime = mapActData.EndTime      
end

function ActivityDataBase:GetActId()
    return self.nActId
end

function ActivityDataBase:GetActCfgData()
    return self.actCfg
end

--活动类型
function ActivityDataBase:GetActType()
    return self.actCfg.ActivityType
end

--检查活动是否开启
function ActivityDataBase:CheckActivityOpen()
    local curTime = CS.ClientManager.Instance.serverTimeStamp
    if self.actCfg.EndType == GameEnum.activityEndType.NoLimit then
        return self.nOpenTime > 0
    else
        return curTime < self.nEndTime and self.nOpenTime > 0
    end
end

--判断活动是否显示
function ActivityDataBase:CheckActShow()
    --检查是否达到显示条件
    if self.actCfg.PreLimit == GameEnum.activityPreLimit.WorldClass then
        local nCurWorldClass = PlayerData.Base:GetWorldClass()
        local nNeedWorldClass = tonumber(self.actCfg.LimitParam)
        if nCurWorldClass < nNeedWorldClass then
            return false
        end
    elseif self.actCfg.PreLimit == GameEnum.activityPreLimit.questLimit then
        local nStoryId = tonumber(self.actCfg.LimitParam)
        local bReaded = PlayerData.Avg:IsStoryReaded(nStoryId)
        if not bReaded then
            return false
        end
    end
    
    --活动结束类型为不结束的活动需判断奖励是否全部领取，全部领取就不显示活动
    if self.actCfg.EndType == GameEnum.activityEndType.NoLimit then
        return (not self.bBanner) and self:CheckActivityOpen()
    else
        return self:CheckActivityOpen()
    end
end

--判断活动是否可玩
function ActivityDataBase:CheckActPlay()
    --检查是否达到显示条件
    if self.actCfg.PlayCond == GameEnum.activityPreLimit.WorldClass then
        local nCurWorldClass = PlayerData.Base:GetWorldClass()
        local nNeedWorldClass = tonumber(self.actCfg.PlayCondParams)
        if nCurWorldClass < nNeedWorldClass then
            return false
        end
    elseif self.actCfg.PlayCond == GameEnum.activityPreLimit.questLimit then
        local nStoryId = tonumber(self.actCfg.PlayCondParams)
        local bReaded = PlayerData.Avg:IsStoryReaded(nStoryId)
        if not bReaded then
            return false
        end
    end

    --活动结束类型为不结束的活动需判断奖励是否全部领取，全部领取就不显示活动
    if self.actCfg.EndType == GameEnum.activityEndType.NoLimit then
        return (not self.bBanner) and self:CheckActivityOpen()
    else
        return self:CheckActivityOpen()
    end
end

--检查活动开放条件类型（活动可见但不能跳转）
function ActivityDataBase:CheckActJumpCond(bShowTips)
    local bPlayCond = true
    local sTips = ""
    if self.actCfg.PlayCond == GameEnum.activityPreLimit.WorldClass then
        local nCurWorldClass = PlayerData.Base:GetWorldClass()
        local nNeedWorldClass = tonumber(self.actCfg.PlayCondParams)
        if nCurWorldClass < nNeedWorldClass then
            bPlayCond = false
            sTips = orderedFormat(ConfigTable.GetUIText("Activity_Play_Cond_Tip_1"), nNeedWorldClass) 
        end
    elseif self.actCfg.PlayCond == GameEnum.activityPreLimit.questLimit then
        local nStoryId = tonumber(self.actCfg.LimitParam)
        local bReaded = PlayerData.Avg:IsStoryReaded(nStoryId)
        if not bReaded then
            bPlayCond = false
            local cfgData = ConfigTable.GetData_Story(nStoryId)
            local sName = ""
            if cfgData ~= nil then
                sName = cfgData.Title
            end
            sTips = orderedFormat(ConfigTable.GetUIText("Activity_Play_Cond_Tip_2"), sName)
        end
    end
    if not bPlayCond and bShowTips then
        EventManager.Hit(EventId.OpenMessageBox, sTips)
    end
    return bPlayCond, sTips
end

function ActivityDataBase:CheckRewardAllReceive()
    return false
end

--活动奖励是否全部领取
function ActivityDataBase:GetActivityRedDot()
    return self.bRedDot
end

--获取活动结束时间
function ActivityDataBase:GetActEndTime()
    return self.nEndTime
end

--获取活动排序id
function ActivityDataBase:GetActSortId()
    return self.actCfg.SortId
end

--是否有开屏展示
function ActivityDataBase:CheckPopUp()
    local localData = LocalData.GetPlayerLocalData("Act_PopUp_DontShow" .. self.nActId)
    if localData then
        return false
    end
    return PlayerData.PopUp:IsNeedPopUp(self.nActId)
end

--是否显示主界面banner
function ActivityDataBase:CheckShowBanner()
    return self:CheckActPlay() and self.actCfg.BannerRes ~= "" and self.bBanner == false
end

function ActivityDataBase:GetBannerPng()
    return self.actCfg.BannerRes
end

function ActivityDataBase:RefreshRedDot()
    
end

function ActivityDataBase:RefreshStateData(bRedDot, bBanner)
    self.bRedDot = bRedDot
    self.bBanner = bBanner
end

return ActivityDataBase