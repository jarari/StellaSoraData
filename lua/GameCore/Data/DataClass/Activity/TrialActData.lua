local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local TrialActData = class("TrialActData", ActivityDataBase)
local LocalData = require("GameCore.Data.LocalData")
TrialActData.Init = function(self)
  -- function num : 0_0
  self.mapTrialActCfg = nil
  self.tbCompleteGroupId = {}
  self:ParseConfig()
end

TrialActData.ParseConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("TrialControl", self.nActId)
  if not mapCfg then
    return 
  end
  self.mapTrialActCfg = mapCfg
end

TrialActData.GetTrialControlCfg = function(self)
  -- function num : 0_2
  return self.mapTrialActCfg
end

TrialActData.RefreshTrialActData = function(self, msgData)
  -- function num : 0_3
  self.tbCompleteGroupId = msgData.CompletedGroupIds
end

TrialActData.CheckGroupReceived = function(self, nGroupId)
  -- function num : 0_4 , upvalues : _ENV
  do return (table.indexof)(self.tbCompleteGroupId, nGroupId) > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

TrialActData.GetNextUnreceiveGroup = function(self)
  -- function num : 0_5 , upvalues : _ENV
  local tbGroup = (self.mapTrialActCfg).GroupIds
  for _,v in ipairs(tbGroup) do
    local bReceived = self:CheckGroupReceived(v)
    if not bReceived then
      return v
    end
  end
end

TrialActData.SendActivityTrialRewardReceiveReq = function(self, nGroupId, callback)
  -- function num : 0_6 , upvalues : _ENV
  if self:CheckGroupReceived(nGroupId) then
    printError("试玩奖励已领取过" .. nGroupId)
    callback()
    return 
  end
  local msgData = {ActivityId = self.nActId, GroupId = nGroupId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_6_0 , upvalues : _ENV, self, nGroupId, callback
    (table.insert)(self.tbCompleteGroupId, nGroupId)
    if callback then
      callback(mapMainData)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_trial_reward_receive_req, msgData, nil, successCallback)
end

return TrialActData

