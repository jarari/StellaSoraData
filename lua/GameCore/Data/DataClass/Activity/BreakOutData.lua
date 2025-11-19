local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local LocalData = require("GameCore.Data.LocalData")
local BreakOutData = class("BreakOutData", ActivityDataBase)
BreakOutData.Init = function(self)
  -- function num : 0_0
  self.allLevelData = {}
end

BreakOutData.RefreshBreakOutData = function(self, actId, msgData)
  -- function num : 0_1 , upvalues : _ENV
  self:Init()
  self.nActId = actId
  self.mapActData = (PlayerData.Activity):GetActivityDataById(self.nActId)
  if not (self.mapActData):GetActEndTime() then
    self.nEndTime = self.mapActData == nil or 0
    self.nOpenTime = (self.mapActData):GetActOpenTime() or 0
    if msgData ~= nil then
      self:CacheAllLevelData(msgData.Levels)
      self:CacheAllCharacterData(msgData.Characters)
    end
  end
end

BreakOutData.CacheAllLevelData = function(self, levelListData)
  -- function num : 0_2 , upvalues : _ENV
  self.tbLevelDataList = {}
  for _,v in pairs(levelListData) do
    local levelData = {nId = v.Id, bFirstComplete = v.FirstCompelete, nDifficultyType = ((ConfigTable.GetData)("BreakOutLevel", v.Id)).Difficulty}
    ;
    (table.insert)(self.tbLevelDataList, levelData)
  end
end

BreakOutData.GetLevelData = function(self)
  -- function num : 0_3
  return self.tbLevelDataList
end

BreakOutData.GetLevelDataById = function(self, nId)
  -- function num : 0_4 , upvalues : _ENV
  local levelData = nil
  for _,v in pairs(self.tbLevelDataList) do
    if v.nId == nId then
      levelData = v
      break
    end
  end
  do
    return levelData
  end
end

BreakOutData.GetDetailLevelDataById = function(self, nId)
  -- function num : 0_5 , upvalues : _ENV
  local levelData = nil
  for _,v in pairs(self.tbLevelDataList) do
    if v.nId == nId then
      levelData = (ConfigTable.GetData)("BreakOutLevel", self.nId)
      break
    end
  end
  do
    return levelData
  end
end

BreakOutData.GetDetailLevelsDataByTab = function(self, nSelectedTabIndex)
  -- function num : 0_6 , upvalues : _ENV
  local DifficultyLevelData = {}
  for _,v in pairs(self.tbLevelDataList) do
    if v.nDifficultyType == nSelectedTabIndex then
      (table.insert)(DifficultyLevelData, (ConfigTable.GetData)("BreakOutLevel", self.nId))
    end
  end
  return DifficultyLevelData
end

BreakOutData.IsLevelUnlocked = function(self, nLevelId)
  -- function num : 0_7 , upvalues : _ENV
  local bTimeUnlock, bPreComplete = false, false
  local mapData = self:GetLevelDataById(nLevelId)
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  if not self.nOpenTime then
    local remainTime = curTime - (0 + mapData.DayOpen * 86400)
    local nPreLevelId = mapData.PreLevelId or 0
    local mapLevelStatus = self:GetLevelDataById(nPreLevelId)
    bTimeUnlock = remainTime >= 0
    if nPreLevelId ~= 0 then
      if mapLevelStatus ~= nil then
        bPreComplete = mapLevelStatus.bFirstComplete
      else
        bPreComplete = false
      end
      do return bTimeUnlock, bPreComplete end
      -- DECOMPILER ERROR: 4 unprocessed JMP targets
    end
  end
end

return DifficultyLevelData

