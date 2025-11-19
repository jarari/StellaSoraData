local SkinData = class("SkinData")
SkinData.ctor = function(self, skinId, handbookId, unlock)
  -- function num : 0_0 , upvalues : _ENV
  self.nId = skinId
  self.nHandbookId = handbookId
  self.tbCfgData = (ConfigTable.GetData_CharacterSkin)(skinId)
  if self.tbCfgData == nil then
    printError("Get skinData fail!!! skinId = " .. skinId)
    return 
  end
  self.nCharId = (self.tbCfgData).CharId
  self.nUnlock = unlock
  self.tbSkinExtraTag = (self.tbCfgData).SkinExtraTag
end

SkinData.UpdateUnlockState = function(self, nUnlock)
  -- function num : 0_1
  self.nUnlock = nUnlock
end

SkinData.GetId = function(self)
  -- function num : 0_2
  return self.nId
end

SkinData.GetCharId = function(self)
  -- function num : 0_3
  return self.nCharId
end

SkinData.GetHandbookId = function(self)
  -- function num : 0_4
  return self.nHandbookId
end

SkinData.GetSkinExtraTags = function(self)
  -- function num : 0_5
  return self.tbSkinExtraTag
end

SkinData.GetCfgData = function(self)
  -- function num : 0_6
  return self.tbCfgData
end

SkinData.CheckSkinShow = function(self)
  -- function num : 0_7
  return (self.tbCfgData).IsShow
end

SkinData.CheckUnlock = function(self)
  -- function num : 0_8
  do return self.nUnlock == 1 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

SkinData.CheckFavorCG = function(self)
  -- function num : 0_9 , upvalues : _ENV
  local nCGId = (self.tbCfgData).CharacterCG
  local cfgCG = (ConfigTable.GetData)("CharacterCG", nCGId)
  if cfgCG == nil then
    printError((string.format)("读取CharacterCG配置失败！！！id = [%s]", nCGId))
  else
    if cfgCG.UnlockPlot > 0 then
      return (PlayerData.Char):IsCharPlotFinish(self.nCharId, cfgCG.UnlockPlot)
    end
  end
  return true
end

SkinData.GetUnlockPlot = function(self)
  -- function num : 0_10 , upvalues : _ENV
  local nCGId = (self.tbCfgData).CharacterCG
  local cfgCG = (ConfigTable.GetData)("CharacterCG", nCGId)
  if cfgCG == nil then
    printError((string.format)("读取CharacterCG配置失败！！！id = [%s]", nCGId))
    return 0
  end
  return cfgCG.UnlockPlot
end

return SkinData

