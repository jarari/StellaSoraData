local ActivityDataBase = class("ActivityDataBase")
local LocalData = require("GameCore.Data.LocalData")
ActivityDataBase.ctor = function(self, mapActData)
  -- function num : 0_0 , upvalues : _ENV
  self.nActId = mapActData.Id
  self.actCfg = nil
  self.nOpenTime = mapActData.StartTime
  self.nEndTime = mapActData.EndTime
  self.bRedDot = false
  self.bBanner = false
  self.actCfg = (ConfigTable.GetData)("Activity", self.nActId)
  self.bPlay = self:CheckActPlay()
  self:Init()
end

ActivityDataBase.Init = function(self)
  -- function num : 0_1
end

ActivityDataBase.UpdateActivityState = function(self, mapState)
  -- function num : 0_2
  self.bRedDot = mapState.RedDot
  self.bBanner = mapState.Banner
end

ActivityDataBase.RefreshActivityData = function(self, mapActData)
  -- function num : 0_3
  self.nOpenTime = mapActData.StartTime
  self.nEndTime = mapActData.EndTime
end

ActivityDataBase.GetActId = function(self)
  -- function num : 0_4
  return self.nActId
end

ActivityDataBase.GetActCfgData = function(self)
  -- function num : 0_5
  return self.actCfg
end

ActivityDataBase.GetActType = function(self)
  -- function num : 0_6
  return (self.actCfg).ActivityType
end

ActivityDataBase.CheckActivityOpen = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  if self.nOpenTime <= 0 then
    do return (self.actCfg).EndType ~= (GameEnum.activityEndType).NoLimit end
    do return curTime < self.nEndTime and self.nOpenTime > 0 end
    -- DECOMPILER ERROR: 5 unprocessed JMP targets
  end
end

ActivityDataBase.CheckActShow = function(self)
  -- function num : 0_8 , upvalues : _ENV
  if (self.actCfg).PreLimit == (GameEnum.activityPreLimit).WorldClass then
    local nCurWorldClass = (PlayerData.Base):GetWorldClass()
    local nNeedWorldClass = tonumber((self.actCfg).LimitParam)
    if nCurWorldClass < nNeedWorldClass then
      return false
    end
  else
    do
      if (self.actCfg).PreLimit == (GameEnum.activityPreLimit).questLimit then
        local nStoryId = tonumber((self.actCfg).LimitParam)
        local bReaded = (PlayerData.Avg):IsStoryReaded(nStoryId)
        if not bReaded then
          return false
        end
      end
      do
        do return (not self.bBanner and self:CheckActivityOpen()) end
        do return self:CheckActivityOpen() end
        -- DECOMPILER ERROR: 4 unprocessed JMP targets
      end
    end
  end
end

ActivityDataBase.GetPlayState = function(self)
  -- function num : 0_9
  return self.bPlay
end

ActivityDataBase.RefreshPlayState = function(self)
  -- function num : 0_10
  self.bPlay = self:CheckActPlay()
end

ActivityDataBase.CheckActPlay = function(self)
  -- function num : 0_11 , upvalues : _ENV
  if (self.actCfg).PlayCond == (GameEnum.activityPreLimit).WorldClass then
    local nCurWorldClass = (PlayerData.Base):GetWorldClass()
    local nNeedWorldClass = tonumber((self.actCfg).PlayCondParams)
    if nCurWorldClass < nNeedWorldClass then
      return false
    end
  else
    do
      if (self.actCfg).PlayCond == (GameEnum.activityPreLimit).questLimit then
        local nStoryId = tonumber((self.actCfg).PlayCondParams)
        local bReaded = (PlayerData.Avg):IsStoryReaded(nStoryId)
        if not bReaded then
          return false
        end
      end
      do
        do return (not self.bBanner and self:CheckActivityOpen()) end
        do return self:CheckActivityOpen() end
        -- DECOMPILER ERROR: 4 unprocessed JMP targets
      end
    end
  end
end

ActivityDataBase.CheckActJumpCond = function(self, bShowTips)
  -- function num : 0_12 , upvalues : _ENV
  local bPlayCond = true
  local sTips = ""
  if (self.actCfg).PlayCond == (GameEnum.activityPreLimit).WorldClass then
    local nCurWorldClass = (PlayerData.Base):GetWorldClass()
    local nNeedWorldClass = tonumber((self.actCfg).PlayCondParams)
    if nCurWorldClass < nNeedWorldClass then
      bPlayCond = false
      sTips = orderedFormat((ConfigTable.GetUIText)("Activity_Play_Cond_Tip_1"), nNeedWorldClass)
    end
  else
    do
      if (self.actCfg).PlayCond == (GameEnum.activityPreLimit).questLimit then
        local nStoryId = tonumber((self.actCfg).LimitParam)
        local bReaded = (PlayerData.Avg):IsStoryReaded(nStoryId)
        if not bReaded then
          bPlayCond = false
          local cfgData = (ConfigTable.GetData_Story)(nStoryId)
          local sName = ""
          if cfgData ~= nil then
            sName = cfgData.Title
          end
          sTips = orderedFormat((ConfigTable.GetUIText)("Activity_Play_Cond_Tip_2"), sName)
        end
      end
      do
        if not bPlayCond and bShowTips then
          (EventManager.Hit)(EventId.OpenMessageBox, sTips)
        end
        return bPlayCond, sTips
      end
    end
  end
end

ActivityDataBase.CheckRewardAllReceive = function(self)
  -- function num : 0_13
  return false
end

ActivityDataBase.GetActivityRedDot = function(self)
  -- function num : 0_14
  return self.bRedDot
end

ActivityDataBase.GetActEndTime = function(self)
  -- function num : 0_15
  return self.nEndTime
end

ActivityDataBase.GetActSortId = function(self)
  -- function num : 0_16
  return (self.actCfg).SortId
end

ActivityDataBase.CheckPopUp = function(self)
  -- function num : 0_17 , upvalues : LocalData, _ENV
  local localData = (LocalData.GetPlayerLocalData)("Act_PopUp_DontShow" .. self.nActId)
  if localData then
    return false
  end
  return (PlayerData.PopUp):IsNeedActPopUp(self.nActId)
end

ActivityDataBase.CheckShowBanner = function(self)
  -- function num : 0_18
  do return not self:CheckActPlay() or ((self.actCfg).BannerRes ~= "" and self.bBanner == false) end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

ActivityDataBase.GetBannerPng = function(self)
  -- function num : 0_19
  return (self.actCfg).BannerRes
end

ActivityDataBase.RefreshRedDot = function(self)
  -- function num : 0_20
end

ActivityDataBase.RefreshStateData = function(self, bRedDot, bBanner)
  -- function num : 0_21
  self.bRedDot = bRedDot
  self.bBanner = bBanner
end

ActivityDataBase.UpdateStatus = function(self)
  -- function num : 0_22
end

return ActivityDataBase

