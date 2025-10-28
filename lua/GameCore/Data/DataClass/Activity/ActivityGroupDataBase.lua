local LocalData = require("GameCore.Data.LocalData")
local ActivityGroupDataBase = class("ActivityGroupDataBase")

---@diagnostic disable-next-line: duplicate-set-field
function ActivityGroupDataBase:ctor(mapActGroupData)
    self.nActGroupId = mapActGroupData.Id             -- 活动id
    self.actGroupCfg = mapActGroupData                  --活动表格数据
    self.bRedDot = false
    self.bBanner = false
    self.nOpenTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(self.actGroupCfg.StartTime)
    self.nEndTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(self.actGroupCfg.EndTime)
    self.nEndEnterTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(self.actGroupCfg.EnterEndTime)
    self:Init()
end

function ActivityGroupDataBase:Init()
end

function ActivityGroupDataBase:UpdateActivityGroupState(mapState)
    self.bRedDot = mapState.RedDot        --首屏红点（true显示）
    self.bBanner = mapState.Banner        --banner图（true：移除banner图）
end

function ActivityGroupDataBase:RefreshActivityData(mapActGroupData)
    self.actGroupCfg = mapActGroupData
    self.nOpenTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(self.actGroupCfg.StartTime)
    self.nEndTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(self.actGroupCfg.EndTime)
    self.nEndEnterTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(self.actGroupCfg.EnterEndTime)
end

function ActivityGroupDataBase:GetActGroupId()
    return self.nActGroupId
end

function ActivityGroupDataBase:GetActGroupCfgData()
    return self.actGroupCfg
end

function ActivityGroupDataBase:IsUnlock()
    if self.actGroupCfg.StartCondType == GameEnum.questAcceptCond.WorldClassSpecific then
        local nWorldCalss = PlayerData.Base:GetWorldClass()
        if nWorldCalss < self.actGroupCfg.StartCondParams[1] then
            local txtLock = orderedFormat(ConfigTable.GetUIText("Activity_Cond_WorldClass"), self.actGroupCfg.StartCondParams[1])
            return false,txtLock
        end
    end
    return true
end

function ActivityGroupDataBase:IsUnlockShow()
    if self.actGroupCfg.PreLimit == GameEnum.activityPreLimit.WorldClass then
        local nWorldCalss = PlayerData.Base:GetWorldClass()
        if nWorldCalss < tonumber(self.actGroupCfg.LimitParam) then
            return false
        end
    elseif self.actGroupCfg.PreLimit == GameEnum.activityPreLimit.questLimit then
        return PlayerData.Avg:IsStoryReaded(self.actGroupCfg.LimitParam)
    end
    return true
end

--检查活动是否开启
function ActivityGroupDataBase:CheckActivityGroupOpen()
    if not self:IsUnlockShow() then
        return false
    end
    local curTime = CS.ClientManager.Instance.serverTimeStamp
    return curTime < self.nEndTime and self.nOpenTime > 0
end

--判断活动是否显示
function ActivityGroupDataBase:CheckActGroupShow()
    if not self:IsUnlockShow() then
        return false
    end
    local curTime = CS.ClientManager.Instance.serverTimeStamp
    return curTime < self.nEndEnterTime
end

--判断活动开屏弹窗是否显示（活动结束时间过期后就不再显示）
function ActivityGroupDataBase:CheckActGroupPopUpShow()
    if not self:IsUnlock() then
        return false
    end
    local curTime = CS.ClientManager.Instance.serverTimeStamp
    return curTime < self.nEndTime
end

--获取活动结束时间
function ActivityGroupDataBase:GetActGroupEndTime()
    return self.nEndTime
end

--获取活动剩余时间
function ActivityGroupDataBase:GetActGroupRemainTime()
    local curTime = CS.ClientManager.Instance.serverTimeStamp
    return self.nEndTime - curTime
end

--获取活动持续日期
function ActivityGroupDataBase:GetActGroupDate()
    local nOpenYear = tonumber(os.date("%Y", self.nOpenTime))
    local nOpenMonth = tonumber(os.date("%m", self.nOpenTime))
    local nOpenDay = tonumber(os.date("%d", self.nOpenTime))
    local nEndYear = tonumber(os.date("%Y", self.nEndTime))
    local nEndMonth = tonumber(os.date("%m", self.nEndTime))
    local nEndDay = tonumber(os.date("%d", self.nEndTime))

    return nOpenMonth, nOpenDay, nEndMonth, nEndDay, nOpenYear, nEndYear
end

--是否有开屏展示
function ActivityGroupDataBase:CheckPopUp()
    local localData = LocalData.GetPlayerLocalData("Act_PopUp_DontShow"..self.actGroupCfg.Id)
    if localData then
        return false
    end
    return PlayerData.PopUp:IsNeedPopUp(self.nActGroupId)
end

--是否显示主界面banner
function ActivityGroupDataBase:CheckShowBanner()
    return self:CheckActGroupShow() and self.actCfg.BannerRes ~= "" and self.bBanner == false
end

function ActivityGroupDataBase:GetBannerPng()
    
end

function ActivityGroupDataBase:RefreshRedDot()
    
end

function ActivityGroupDataBase:RefreshStateData(bRedDot, bBanner)
    self.bRedDot = bRedDot
    self.bBanner = bBanner
end

function ActivityGroupDataBase:IsActivityInActivityGroup(nActivityId)
    return false
end

return ActivityGroupDataBase