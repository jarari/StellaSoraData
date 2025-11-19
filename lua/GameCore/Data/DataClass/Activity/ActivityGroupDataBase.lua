local LocalData = require("GameCore.Data.LocalData")
local ActivityGroupDataBase = class("ActivityGroupDataBase")
ActivityGroupDataBase.ctor = function(self, mapActGroupData)
  -- function num : 0_0 , upvalues : _ENV
  self.nActGroupId = mapActGroupData.Id
  self.actGroupCfg = mapActGroupData
  self.bRedDot = false
  self.bBanner = false
  self.nOpenTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp((self.actGroupCfg).StartTime)
  self.nEndTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp((self.actGroupCfg).EndTime)
  self.nEndEnterTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp((self.actGroupCfg).EnterEndTime)
  self:Init()
end

ActivityGroupDataBase.Init = function(self)
  -- function num : 0_1
end

ActivityGroupDataBase.UpdateActivityGroupState = function(self, mapState)
  -- function num : 0_2
  self.bRedDot = mapState.RedDot
  self.bBanner = mapState.Banner
end

ActivityGroupDataBase.RefreshActivityData = function(self, mapActGroupData)
  -- function num : 0_3 , upvalues : _ENV
  self.actGroupCfg = mapActGroupData
  self.nOpenTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp((self.actGroupCfg).StartTime)
  self.nEndTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp((self.actGroupCfg).EndTime)
  self.nEndEnterTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp((self.actGroupCfg).EnterEndTime)
end

ActivityGroupDataBase.GetActGroupId = function(self)
  -- function num : 0_4
  return self.nActGroupId
end

ActivityGroupDataBase.GetActGroupCfgData = function(self)
  -- function num : 0_5
  return self.actGroupCfg
end

ActivityGroupDataBase.IsUnlock = function(self)
  -- function num : 0_6 , upvalues : _ENV
  if (self.actGroupCfg).StartCondType == (GameEnum.questAcceptCond).WorldClassSpecific then
    local nWorldCalss = (PlayerData.Base):GetWorldClass()
    if nWorldCalss < ((self.actGroupCfg).StartCondParams)[1] then
      local txtLock = orderedFormat((ConfigTable.GetUIText)("Activity_Cond_WorldClass"), ((self.actGroupCfg).StartCondParams)[1])
      return false, txtLock
    end
  end
  do
    return true
  end
end

ActivityGroupDataBase.IsUnlockShow = function(self)
  -- function num : 0_7 , upvalues : _ENV
  if (self.actGroupCfg).PreLimit == (GameEnum.activityPreLimit).WorldClass then
    local nWorldCalss = (PlayerData.Base):GetWorldClass()
    if nWorldCalss < tonumber((self.actGroupCfg).LimitParam) then
      return false
    end
  else
    do
      if (self.actGroupCfg).PreLimit == (GameEnum.activityPreLimit).questLimit then
        return (PlayerData.Avg):IsStoryReaded((self.actGroupCfg).LimitParam)
      end
      return true
    end
  end
end

ActivityGroupDataBase.CheckActivityGroupOpen = function(self)
  -- function num : 0_8 , upvalues : _ENV
  if not self:IsUnlockShow() then
    return false
  end
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  do return curTime < self.nEndTime and self.nOpenTime > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

ActivityGroupDataBase.CheckActGroupShow = function(self)
  -- function num : 0_9 , upvalues : _ENV
  if not self:IsUnlockShow() then
    return false
  end
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  do return curTime < self.nEndEnterTime end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

ActivityGroupDataBase.CheckActGroupPopUpShow = function(self)
  -- function num : 0_10 , upvalues : _ENV
  if not self:IsUnlock() then
    return false
  end
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  do return curTime < self.nEndTime end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

ActivityGroupDataBase.GetActGroupEndTime = function(self)
  -- function num : 0_11
  return self.nEndTime
end

ActivityGroupDataBase.GetActGroupEnterEndTime = function(self)
  -- function num : 0_12
  return self.nEndEnterTime
end

ActivityGroupDataBase.GetActGroupRemainTime = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  return self.nEndTime - curTime
end

ActivityGroupDataBase.GetActGroupDate = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local nOpenYear = tonumber((os.date)("%Y", self.nOpenTime))
  local nOpenMonth = tonumber((os.date)("%m", self.nOpenTime))
  local nOpenDay = tonumber((os.date)("%d", self.nOpenTime))
  local nEndYear = tonumber((os.date)("%Y", self.nEndTime))
  local nEndMonth = tonumber((os.date)("%m", self.nEndTime))
  local nEndDay = tonumber((os.date)("%d", self.nEndTime))
  return nOpenMonth, nOpenDay, nEndMonth, nEndDay, nOpenYear, nEndYear
end

ActivityGroupDataBase.CheckPopUp = function(self)
  -- function num : 0_15 , upvalues : LocalData, _ENV
  local localData = (LocalData.GetPlayerLocalData)("Act_PopUp_DontShow" .. (self.actGroupCfg).Id)
  if localData then
    return false
  end
  return (PlayerData.PopUp):IsNeedActPopUp(self.nActGroupId)
end

ActivityGroupDataBase.CheckShowBanner = function(self)
  -- function num : 0_16
  do return not self:CheckActGroupShow() or ((self.actCfg).BannerRes ~= "" and self.bBanner == false) end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

ActivityGroupDataBase.GetBannerPng = function(self)
  -- function num : 0_17
end

ActivityGroupDataBase.RefreshRedDot = function(self)
  -- function num : 0_18
end

ActivityGroupDataBase.RefreshStateData = function(self, bRedDot, bBanner)
  -- function num : 0_19
  self.bRedDot = bRedDot
  self.bBanner = bBanner
end

ActivityGroupDataBase.IsActivityInActivityGroup = function(self, nActivityId)
  -- function num : 0_20
  return false
end

return ActivityGroupDataBase

