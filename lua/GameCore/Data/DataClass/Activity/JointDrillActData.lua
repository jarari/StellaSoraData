local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local JointDrillActData = class("JointDrillActData", ActivityDataBase)
JointDrillActData.Init = function(self)
  -- function num : 0_0
  self.nStatus = 0
  self.jointDrillActCfg = nil
  self:InitConfig()
end

JointDrillActData.InitConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local mapActCfg = (ConfigTable.GetData)("JointDrillControl", self.nActId)
  if mapActCfg == nil then
    return 
  end
  self.jointDrillActCfg = mapActCfg
end

JointDrillActData.GetJointDrillActCfg = function(self)
  -- function num : 0_2
  return self.jointDrillActCfg
end

JointDrillActData.RefreshJointDrillActData = function(self, msgData)
  -- function num : 0_3 , upvalues : _ENV
  (PlayerData.JointDrill):CacheJointDrillData(self.nActId, msgData)
end

JointDrillActData.GetActOpenTime = function(self)
  -- function num : 0_4
  return self.nOpenTime
end

JointDrillActData.GetActCloseTime = function(self)
  -- function num : 0_5
  return self.nEndTime
end

JointDrillActData.GetChallengeStartTime = function(self)
  -- function num : 0_6
  if self.jointDrillActCfg ~= nil then
    return self.nOpenTime + (self.jointDrillActCfg).DrillStartTime
  end
end

JointDrillActData.GetChallengeEndTime = function(self)
  -- function num : 0_7
  if self.jointDrillActCfg ~= nil then
    return self.nOpenTime + (self.jointDrillActCfg).DrillStartTime + (self.jointDrillActCfg).DrillDurationTime
  end
end

return JointDrillActData

