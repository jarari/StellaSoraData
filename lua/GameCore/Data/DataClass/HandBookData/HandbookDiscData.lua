local HandbookDataBase = require("GameCore.Data.DataClass.HandBookData.HandbookDataBase")
local HandbookDiscData = class("HandbookDiscData", HandbookDataBase)
HandbookDiscData.Init = function(self)
  -- function num : 0_0
  self.nDiscId = self:GetId()
end

HandbookDiscData.GetDiscId = function(self)
  -- function num : 0_1
  return self.nDiscId
end

HandbookDiscData.GetDiscCfgData = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local discCfgData = (ConfigTable.GetData)("Disc", self.nDiscId)
  if discCfgData == nil then
    printError("Get disc data fail!!! id = " .. self.nDiscId)
    return 
  end
  return discCfgData
end

HandbookDiscData.GetDiscBg = function(self)
  -- function num : 0_3 , upvalues : _ENV
  local cfgData = self:GetDiscCfgData()
  if cfgData ~= nil then
    return cfgData.DiscBg .. (AllEnum.DiscBgSurfix).Image
  end
end

HandbookDiscData.GetDiscItemCfgData = function(self)
  -- function num : 0_4 , upvalues : _ENV
  local itemCfgData = (ConfigTable.GetData_Item)(self.nDiscId)
  if itemCfgData == nil then
    printError("Get item.disc data fail!!! id = " .. self.nDiscId)
    return 
  end
  return itemCfgData
end

HandbookDiscData.GetRarity = function(self)
  -- function num : 0_5
  local discItemCfgData = self:GetDiscItemCfgData()
  if discItemCfgData ~= nil then
    return discItemCfgData.Rarity
  end
end

HandbookDiscData.GetCreateTime = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local createTime = 0
  local mapDiscData = (PlayerData.Disc):GetDiscById(self.nDiscId)
  createTime = mapDiscData == nil or mapDiscData.nCreateTime or 0
  return createTime
end

HandbookDiscData.CheckDiscL2D = function(self)
  -- function num : 0_7 , upvalues : _ENV
  return (PlayerData.Disc):CheckDiscL2D(self.nDiscId)
end

return HandbookDiscData

