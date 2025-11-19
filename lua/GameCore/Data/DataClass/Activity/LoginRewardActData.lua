local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local LoginRewardActData = class("LoginRewardActData", ActivityDataBase)
LoginRewardActData.Init = function(self)
  -- function num : 0_0
  self.nCanReceives = 0
  self.nActual = 0
  self.tbRewardList = {}
  self.loginRewardActCfg = nil
  self:InitRewardList()
end

LoginRewardActData.InitRewardList = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local mapActCfg = (ConfigTable.GetData)("LoginRewardControl", self.nActId)
  if mapActCfg == nil then
    return 
  end
  self.loginRewardActCfg = mapActCfg
  local tbRewardList = (CacheTable.GetData)("_LoginRewardGroup", mapActCfg.RewardsGroup)
  if tbRewardList == nil then
    printError((string.format)("LoginRewardGroup表中不存在奖励组id为 %s 的配置！！！", mapActCfg.RewardsGroup))
    return 
  end
  ;
  (table.sort)(tbRewardList, function(a, b)
    -- function num : 0_1_0
    do return a.Order < b.Order end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  self.tbRewardList = tbRewardList
end

LoginRewardActData.RefreshLoginData = function(self, nReceive, nActual)
  -- function num : 0_2 , upvalues : _ENV
  self.nCanReceives = nReceive
  self.nActual = nActual
  for k,v in ipairs(self.tbRewardList) do
    v.Status = 0
    if k <= nReceive then
      v.Status = 1
    end
    if k <= nActual then
      v.Status = 2
    end
  end
end

LoginRewardActData.ReceiveRewardSuc = function(self)
  -- function num : 0_3
  self:RefreshLoginData(self.nCanReceives, self.nCanReceives)
end

LoginRewardActData.GetActLoginRewardList = function(self)
  -- function num : 0_4
  return self.tbRewardList
end

LoginRewardActData.GetCanReceive = function(self)
  -- function num : 0_5
  return self.nCanReceives
end

LoginRewardActData.GetReceived = function(self)
  -- function num : 0_6
  return self.nActual
end

LoginRewardActData.CheckCanReceive = function(self)
  -- function num : 0_7
  do return self.nActual < self.nCanReceives end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

LoginRewardActData.GetLoginRewardControlCfg = function(self)
  -- function num : 0_8
  return self.loginRewardActCfg
end

return LoginRewardActData

