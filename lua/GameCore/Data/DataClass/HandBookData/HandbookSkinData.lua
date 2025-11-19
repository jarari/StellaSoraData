local HandbookDataBase = require("GameCore.Data.DataClass.HandBookData.HandbookDataBase")
local HandbookSkinData = class("HandbookSkinData", HandbookDataBase)
HandbookSkinData.Init = function(self)
  -- function num : 0_0
  self.nSkinId = (self.tbCfgData).SkinId
  self.nCharId = (self.tbCfgData).CharId
end

HandbookSkinData.GetSkinId = function(self)
  -- function num : 0_1
  return self.nSkinId
end

HandbookSkinData.GetSkinCfgData = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local cfgData = (ConfigTable.GetData_CharacterSkin)(self.nSkinId)
  if cfgData == nil then
    printError("Get skin cfg fail!!! charId = " .. self.nSkinId)
    return 
  end
  return cfgData
end

HandbookSkinData.GetCharId = function(self)
  -- function num : 0_3
  return self.nCharId
end

HandbookSkinData.GetCharCfgData = function(self)
  -- function num : 0_4 , upvalues : _ENV
  local cfgData = (ConfigTable.GetData_Character)(self.nCharId)
  if cfgData == nil then
    printError("Get char cfg fail!!! charId = " .. self.nCharId)
    return 
  end
  return cfgData
end

HandbookSkinData.CheckDefaultSkin = function(self)
  -- function num : 0_5 , upvalues : _ENV
  do return (self.tbCfgData).Cond == (GameEnum.handBookCond).CharacterAcquire or (self.tbCfgData).Cond == (GameEnum.handBookCond).CharacterSpecific end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

HandbookSkinData.CheckFavorCG = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local skinData = (PlayerData.CharSkin):GetSkinDataBySkinId(self.nSkinId)
  if skinData ~= nil then
    return skinData:CheckFavorCG()
  end
  return false
end

HandbookSkinData.GetCharAffinityLevel = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local nLevel = 0
  do
    if self.nCharId ~= 0 then
      local mapData = (PlayerData.Char):GetCharAffinityData(self.nCharId)
      if mapData ~= nil then
        nLevel = mapData.Level
      end
    end
    return nLevel
  end
end

return HandbookSkinData

