--活动：登录奖励
local ActivityDataBase = require "GameCore.Data.DataClass.Activity.ActivityDataBase"
local JointDrillActData = class("JointDrillActData", ActivityDataBase)

function JointDrillActData:Init()
    self.nStatus = 0                    -- 活动状态
    self.jointDrillActCfg = nil
    
    self:InitConfig()
end

function JointDrillActData:InitConfig()
    local mapActCfg = ConfigTable.GetData("JointDrillControl", self.nActId)
    if nil == mapActCfg then
        return
    end
    self.jointDrillActCfg = mapActCfg
end

function JointDrillActData:GetJointDrillActCfg()
    return self.jointDrillActCfg
end

function JointDrillActData:RefreshJointDrillActData(msgData)
    PlayerData.JointDrill:CacheJointDrillData(self.nActId, msgData)
end

--活动开始时间
function JointDrillActData:GetActOpenTime()
    return self.nOpenTime
end

--活动结束时间
function JointDrillActData:GetActCloseTime()
    return self.nEndTime
end

--挑战开始时间
function JointDrillActData:GetChallengeStartTime()
    if self.jointDrillActCfg ~= nil then
        return self.nOpenTime + self.jointDrillActCfg.DrillStartTime
    end
end

--挑战结束时间
function JointDrillActData:GetChallengeEndTime()
    if self.jointDrillActCfg ~= nil then
        return self.nOpenTime + self.jointDrillActCfg.DrillStartTime + self.jointDrillActCfg.DrillDurationTime
    end
end

return JointDrillActData
