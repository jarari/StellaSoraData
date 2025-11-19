local PlayerTrialData = class("PlayerTrialData")
local AdventureModuleHelper = CS.AdventureModuleHelper
PlayerTrialData.Init = function(self)
  -- function num : 0_0
  self.curLevel = nil
  self.bInSettlement = false
  self.nActId = nil
  self.nSelectTrialGroupId = nil
  self.sLevelTitle = nil
end

PlayerTrialData.SetTrialAct = function(self, nActId)
  -- function num : 0_1
  self.nActId = nActId
end

PlayerTrialData.GetTrialAct = function(self)
  -- function num : 0_2
  return self.nActId
end

PlayerTrialData.SetSelectTrialGroup = function(self, nGroupId)
  -- function num : 0_3
  self.nSelectTrialGroupId = nGroupId
end

PlayerTrialData.GetSelectTrialGroup = function(self)
  -- function num : 0_4
  return self.nSelectTrialGroupId
end

PlayerTrialData.CheckGroupReceived = function(self)
  -- function num : 0_5 , upvalues : _ENV
  if not self.nActId or not self.nSelectTrialGroupId then
    return false
  end
  local actData = (PlayerData.Activity):GetActivityDataById(self.nActId)
  if not actData then
    return false
  end
  return actData:CheckGroupReceived(self.nSelectTrialGroupId)
end

PlayerTrialData.GetNextUnreceiveGroup = function(self)
  -- function num : 0_6 , upvalues : _ENV
  if not self.nActId then
    return 
  end
  local actData = (PlayerData.Activity):GetActivityDataById(self.nActId)
  if not actData then
    return 
  end
  return actData:GetNextUnreceiveGroup()
end

PlayerTrialData.SendReceiveTrialRewardReq = function(self, callback)
  -- function num : 0_7 , upvalues : _ENV
  if not self.nActId or not self.nSelectTrialGroupId then
    callback()
    return false
  end
  local actData = (PlayerData.Activity):GetActivityDataById(self.nActId)
  if not actData then
    callback()
    return false
  end
  actData:SendActivityTrialRewardReceiveReq(self.nSelectTrialGroupId, callback)
end

PlayerTrialData.EnterTrialEditor = function(self, nFloor)
  -- function num : 0_8 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Editor.Trial.TrialEditor")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, nFloor)
  end
end

PlayerTrialData.EnterTrial = function(self, nLevelId)
  -- function num : 0_9 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Adventure.Trial.TrialLevel")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, nLevelId)
  end
end

PlayerTrialData.LevelEnd = function(self)
  -- function num : 0_10 , upvalues : _ENV
  (PlayerData.Build):DeleteTrialBuild()
  if self.curLevel ~= nil and type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
end

PlayerTrialData.GetCurLevel = function(self)
  -- function num : 0_11
  if self.curLevel == nil then
    return 0
  end
  return (self.curLevel).nLevelId
end

PlayerTrialData.SetLevelTitle = function(self, sTitle)
  -- function num : 0_12
  self.sLevelTitle = sTitle
end

PlayerTrialData.GetLevelTitle = function(self)
  -- function num : 0_13
  return self.sLevelTitle or ""
end

PlayerTrialData.SetSettlementState = function(self, bInSettlement)
  -- function num : 0_14
  self.bInSettlement = bInSettlement
end

PlayerTrialData.GetSettlementState = function(self)
  -- function num : 0_15
  return self.bInSettlement
end

return PlayerTrialData

