local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local AdvertiseActData = class("AdvertiseActData", ActivityDataBase)
AdvertiseActData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.nStatus = 0
  self.jointDrillActCfg = nil
  self.bIsMove = ((ConfigTable.GetData)("AdControl", (self.actCfg).Id)).IsMove
  self:InitConfig()
end

AdvertiseActData.InitConfig = function(self)
  -- function num : 0_1
end

AdvertiseActData.RefreshInfinityTowerActData = function(self, msgData)
  -- function num : 0_2
end

AdvertiseActData.GetActOpenTime = function(self)
  -- function num : 0_3
  return self.nOpenTime
end

AdvertiseActData.GetActCloseTime = function(self)
  -- function num : 0_4
  return self.nEndTime
end

AdvertiseActData.GetActSortId = function(self)
  -- function num : 0_5
  if self.bIsMove and self:isFinishAllTasks() then
    return 9999
  else
    return (self.actCfg).SortId
  end
end

AdvertiseActData.isFinishAllTasks = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local nTotalCount, nReceivedCount = (PlayerData.TutorialData):GetProgress()
  local bHasReceiveAllGroup = (PlayerData.Quest):CheckTourGroupReward((PlayerData.Quest):GetMaxTourGroupOrderIndex())
  if bHasReceiveAllGroup and nTotalCount == nReceivedCount then
    return true
  end
  return false
end

return AdvertiseActData

