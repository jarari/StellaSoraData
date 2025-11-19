local HandbookDataBase = class("HandbookDataBase")
HandbookDataBase.ctor = function(self, id, unlock)
  -- function num : 0_0 , upvalues : _ENV
  self.nId = id
  self.tbCfgData = (ConfigTable.GetData)("Handbook", self.nId)
  self.nUnlock = unlock
  if self.tbCfgData == nil then
    printError("Get handbook data fail!!! id = " .. id)
    return 
  end
  self.nIndex = (self.tbCfgData).Index
  self:Init()
end

HandbookDataBase.UpdateUnlockState = function(self, unlock)
  -- function num : 0_1
  self.nUnlock = unlock
end

HandbookDataBase.GetType = function(self)
  -- function num : 0_2
  return (self.tbCfgData).Type
end

HandbookDataBase.GetId = function(self)
  -- function num : 0_3
  return self.nId
end

HandbookDataBase.CheckUnlock = function(self)
  -- function num : 0_4
  do return self.nUnlock == 1 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

return HandbookDataBase

