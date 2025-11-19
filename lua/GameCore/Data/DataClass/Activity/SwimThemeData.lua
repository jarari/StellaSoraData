local ActivityGroupDataBase = require("GameCore.Data.DataClass.Activity.ActivityGroupDataBase")
local SwimThemeData = class("SwimThemeData", ActivityGroupDataBase)
SwimThemeData.Init = function(self)
  -- function num : 0_0
  self.tbAllActivity = {}
  self.nCGActivityId = 0
  self.sCGPath = ""
  self.bPlayedCG = false
  self:ParseActivity()
end

SwimThemeData.ParseActivity = function(self)
  -- function num : 0_1 , upvalues : _ENV
  if self.actGroupConfig == nil then
    self.actGroupConfig = (ConfigTable.GetData)("ActivityGroup", self.nActGroupId)
  end
  local sJson = (self.actGroupConfig).Enter
  local tbJson = decodeJson(sJson)
  for _,activity in pairs(tbJson) do
    local data = {ActivityId = activity[1], Index = activity[2], PanelId = activity[3]}
    ;
    (table.insert)(self.tbAllActivity, data)
  end
  local sCgJson = (self.actGroupConfig).CG
  if sCgJson ~= nil then
    local tbCGJson = decodeJson(sCgJson)
    self.nCGActivityId = tonumber(tbCGJson[1])
    self.sCGPath = tbCGJson[2]
  end
end

SwimThemeData.GetActivityDataByIndex = function(self, nIndex)
  -- function num : 0_2 , upvalues : _ENV
  for _,activity in pairs(self.tbAllActivity) do
    if activity.Index == nIndex then
      return activity
    end
  end
end

SwimThemeData.PlayCG = function(self)
  -- function num : 0_3
  self:SendMsg_CG_READ(self.nCGActivityId)
end

SwimThemeData.GetActivityGroupCGPlayed = function(self)
  -- function num : 0_4 , upvalues : _ENV
  if self.bPlayedCG then
    return true
  end
  return (PlayerData.Activity):IsCGPlayed(self.nCGActivityId)
end

SwimThemeData.IsActivityInActivityGroup = function(self, nActivityId)
  -- function num : 0_5 , upvalues : _ENV
  for _,activity in pairs(self.tbAllActivity) do
    if activity.ActivityId == nActivityId then
      return true, self.nActGroupId
    end
  end
  return false
end

SwimThemeData.SendMsg_CG_READ = function(self, nActivityId)
  -- function num : 0_6 , upvalues : _ENV
  local Callback = function()
    -- function num : 0_6_0 , upvalues : self
    self.bPlayedCG = true
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_cg_read_req, {nActivityId}, nil, Callback)
end

return SwimThemeData

