local PopUpData = class("PopUpData")
local LocalData = require("GameCore.Data.LocalData")
PopUpData.Init = function(self)
  -- function num : 0_0
  self.tbPopUpConfig = {}
  self.tbPopUpData = {}
  self.tbCachedPopUpData = {}
  self:ParseConfig()
end

PopUpData.ParseConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local foreachPopup = function(mapData)
    -- function num : 0_1_0 , upvalues : self
    self:CachedPopUpConfig(mapData)
  end

  ForEachTableLine((ConfigTable.Get)("PopUp"), foreachPopup)
end

PopUpData.CachedPopUpConfig = function(self, mapData)
  -- function num : 0_2 , upvalues : _ENV
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R2 in 'UnsetPending'

  if mapData.PopUpType == (GameEnum.PopUpType).Activity or mapData.PopUpType == (GameEnum.PopUpType).ActivityGroup then
    (self.tbPopUpConfig)[mapData.ActivityId] = mapData.Id
  else
    -- DECOMPILER ERROR at PC26: Confused about usage of register: R2 in 'UnsetPending'

    if mapData.PopUpType == (GameEnum.PopUpType).OwnPopUP then
      (self.tbPopUpConfig)[mapData.Id] = mapData.Id
    end
  end
end

PopUpData.RefreshPopUp = function(self)
  -- function num : 0_3 , upvalues : _ENV
  for k,v in pairs(self.tbPopUpConfig) do
    local cfg = (ConfigTable.GetData)("PopUp", v)
    if cfg.PopUpType == (GameEnum.PopUpType).OwnPopUP and self:CheckPopUpOpen(cfg) and self:IsNeedOwnPopUp(cfg.Id) and (table.indexof)(self.tbPopUpData, cfg.Id) <= 0 and (table.indexof)(self.tbCachedPopUpData, v) <= 0 then
      (table.insert)(self.tbPopUpData, cfg.Id)
      ;
      (table.insert)(self.tbCachedPopUpData, cfg.Id)
    end
  end
  if #self.tbPopUpData > 0 then
    (table.sort)(self.tbPopUpData, function(a, b)
    -- function num : 0_3_0 , upvalues : self, _ENV
    if (self.tbPopUpConfig)[a] ~= nil and (self.tbPopUpConfig)[b] ~= nil then
      local cfgA = (ConfigTable.GetData)("PopUp", (self.tbPopUpConfig)[a])
      local cfgB = (ConfigTable.GetData)("PopUp", (self.tbPopUpConfig)[b])
      return cfgA.SortId < cfgB.SortId
    end
    do return false end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end
)
    ;
    (PopUpManager.PopUpEnQueue)((GameEnum.PopUpSeqType).ActivityFaceAnnounce, self.tbPopUpData)
    self.tbPopUpData = {}
  end
end

PopUpData.CheckPopUpOpen = function(self, mapData)
  -- function num : 0_4 , upvalues : _ENV
  local bUnlock = false
  if mapData.StartCondType == (GameEnum.activityAcceptCond).WorldClassSpecific then
    local nWorldCalss = (PlayerData.Base):GetWorldClass()
    if (mapData.StartCondParams)[1] <= nWorldCalss then
      bUnlock = true
    end
  else
    do
      bUnlock = true
      if bUnlock then
        local bOpen = false
        local nStartTime = 0
        local nEndTime = 0
        local curTime = ((CS.ClientManager).Instance).serverTimeStamp
        if mapData.StartType == (GameEnum.PopUpOpenType).Date then
          nStartTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(mapData.StartTime)
        else
          bOpen = true
        end
        if mapData.EndType == (GameEnum.PopUpEndType).Date then
          nEndTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(mapData.EndTime)
        else
          if mapData.EndType == (GameEnum.activityEndType).TimeLimit then
            nEndTime = nStartTime + mapData.EndDuration * 86400
          else
            bOpen = true
          end
        end
        if nStartTime > 0 and nEndTime > 0 and nStartTime <= curTime and curTime <= nEndTime then
          bOpen = true
        end
        return bOpen
      end
      do
        return false
      end
    end
  end
end

PopUpData.InsertPopUpQueue = function(self, tbPopUpList)
  -- function num : 0_5 , upvalues : _ENV
  for k,v in pairs(tbPopUpList) do
    if (table.indexof)(self.tbPopUpData, v) <= 0 and (table.indexof)(self.tbCachedPopUpData, v) <= 0 then
      (table.insert)(self.tbPopUpData, v)
      ;
      (table.insert)(self.tbCachedPopUpData, v)
    end
  end
  self:RefreshPopUp()
end

local GetCurrentYearInfo = function(time_s)
  -- function num : 0_6 , upvalues : _ENV
  local day = (os.date)("%d", time_s)
  local weekIndex = (os.date)("%W", time_s)
  local month = (os.date)("%m", time_s)
  local yearNum = (os.date)("%Y", time_s)
  return {year = yearNum, month = month, weekIdx = weekIndex, day = day}
end

PopUpData.IsNeedActPopUp = function(self, actId)
  -- function num : 0_7 , upvalues : LocalData
  if (self.tbPopUpConfig)[actId] ~= nil then
    local popupId = (self.tbPopUpConfig)[actId]
    local localData = (LocalData.GetPlayerLocalData)("Act_PopUp" .. actId)
    return self:IsNeedPopUp(popupId, localData)
  end
  do
    return false
  end
end

PopUpData.IsNeedOwnPopUp = function(self, popUpId)
  -- function num : 0_8 , upvalues : LocalData
  do
    if (self.tbPopUpConfig)[popUpId] ~= nil then
      local localData = (LocalData.GetPlayerLocalData)("Act_PopUp" .. popUpId)
      return self:IsNeedPopUp(popUpId, localData)
    end
    return false
  end
end

PopUpData.IsNeedPopUp = function(self, popupId, localData)
  -- function num : 0_9 , upvalues : _ENV, GetCurrentYearInfo
  local cfg = (ConfigTable.GetData)("PopUp", popupId)
  if localData == nil then
    if cfg.PopUpRes == nil then
      do return cfg.PopRefreshType ~= (GameEnum.PopRefreshType).WholeFirst end
      do return false end
      if localData == nil then
        if cfg.PopUpRes == nil then
          do return cfg.PopRefreshType ~= (GameEnum.PopRefreshType).DailyFirst end
          local dateA = GetCurrentYearInfo(tonumber(localData))
          local dateB = GetCurrentYearInfo()
          do
            local isSameDay = dateA.day == dateB.day and dateA.month == dateB.month and dateA.year == dateB.year
            do return not isSameDay and cfg.PopUpRes ~= nil end
            if localData == nil then
              if cfg.PopUpRes == nil then
                do return cfg.PopRefreshType ~= (GameEnum.PopRefreshType).WeeklyFirst end
                local nextTime = tonumber(localData)
                do
                  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
                  do return nextTime <= curTime end
                  do return cfg.PopUpRes ~= nil end
                  -- DECOMPILER ERROR: 15 unprocessed JMP targets
                end
              end
            end
          end
        end
      end
    end
  end
end

PopUpData.GetPopUpConfigData = function(self, actId)
  -- function num : 0_10 , upvalues : _ENV
  do
    if (self.tbPopUpConfig)[actId] ~= nil then
      local cfg = (ConfigTable.GetData)("PopUp", (self.tbPopUpConfig)[actId])
      return cfg
    end
    return nil
  end
end

PopUpData.ReleaseCachedPopUpData = function(self, popupId)
  -- function num : 0_11 , upvalues : _ENV
  for i,v in ipairs(self.tbCachedPopUpData) do
    if v == popupId then
      (table.remove)(self.tbCachedPopUpData, i)
      break
    end
  end
end

return PopUpData

