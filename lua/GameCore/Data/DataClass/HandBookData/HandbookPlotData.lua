local HandbookDataBase = require("GameCore.Data.DataClass.HandBookData.HandbookDataBase")
local HandbookPlotData = class("HandbookPlotData", HandbookDataBase)
HandbookPlotData.Init = function(self)
  -- function num : 0_0
  self.nPlotId = self:GetId()
end

HandbookPlotData.GetPlotId = function(self)
  -- function num : 0_1
  return self.nPlotId
end

HandbookPlotData.GetPlotCfgData = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local plotCfgData = (ConfigTable.GetData)("MainScreenCG", self.nPlotId)
  if plotCfgData == nil then
    printError("Get plot data fail!!! id = " .. self.nPlotId)
    return 
  end
  return plotCfgData
end

HandbookPlotData.CheckPlotL2d = function(self)
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

return HandbookPlotData

