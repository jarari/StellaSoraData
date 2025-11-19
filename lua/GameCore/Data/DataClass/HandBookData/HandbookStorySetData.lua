local HandbookDataBase = require("GameCore.Data.DataClass.HandBookData.HandbookDataBase")
local HandbookStorySetData = class("HandbookStorySetData", HandbookDataBase)
HandbookStorySetData.Init = function(self)
  -- function num : 0_0
  self.nStorySetId = self:GetId()
end

HandbookStorySetData.GetPlotId = function(self)
  -- function num : 0_1
  return self.nStorySetId
end

HandbookStorySetData.GetPlotCfgData = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local plotCfgData = (ConfigTable.GetData)("MainScreenCG", self.nStorySetId)
  if plotCfgData == nil then
    printError("Get plot data fail!!! id = " .. self.nStorySetId)
    return 
  end
  return plotCfgData
end

HandbookStorySetData.CheckPlotL2d = function(self)
  -- function num : 0_3
  local config = self:GetPlotCfgData()
  if config == nil then
    return false
  end
  if config.FullScreenL2D == "" then
    return false
  end
  return true
end

return HandbookStorySetData

