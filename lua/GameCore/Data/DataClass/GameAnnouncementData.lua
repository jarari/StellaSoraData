local GameAnnouncementData = class("GameAnnouncementData")
local LocalData = require("GameCore.Data.LocalData")
local AnnServerChannel_CN = {[1] = "cn_android_official", [2] = "cn_ios_official", [4] = "cn_android_bilibili", [8] = "cn_harmony_official", [16] = "cn_pc_official", [32] = "cn_pc_bilibili"}
local AnnServerChannel_JP = {[1] = "jp_android_official", [2] = "jp_ios_official", [4] = "jp_android_onestore", [8] = "jp_pc_official"}
local AnnServerChannel_US = {[1] = "us_android_official", [2] = "us_ios_official", [4] = "us_android_onestore", [8] = "us_pc_official"}
local AnnServerChannel_KR = {[1] = "kr_android_official", [2] = "kr_ios_official", [4] = "kr_android_onestore", [8] = "kr_pc_official"}
local AnnServerChannel_TW = {[1] = "tw_android_official", [2] = "tw_ios_official", [4] = "tw_android_onestore", [8] = "tw_pc_official"}
local htmlConfigId = 1
GameAnnouncementData.ctor = function(self)
  -- function num : 0_0
end

GameAnnouncementData.Init = function(self)
  -- function num : 0_1 , upvalues : LocalData, _ENV
  if not (LocalData.GetLocalData)("Announcement_", "LastList") then
    self.tbLastAnnList = {}
    self.tbCurAnnList = {}
    ;
    (EventManager.Add)("AllAnnDataRequestDone", self, self.AllAnnResponse)
    ;
    (EventManager.Add)("AnnContentRequestDone", self, self.AnnContentResponse)
    ;
    (EventManager.Add)("AllAnnDataRequestFail", self, self.AllAnnResponse_Fail)
  end
end

GameAnnouncementData.ClearCache = function(self)
  -- function num : 0_2
  self.tbTypeList = {}
  self.tbAnnBaseInfo = {}
  self.tbAnnContentCache = {}
end

GameAnnouncementData.SetAutoOpen = function(self, autoOpen)
  -- function num : 0_3 , upvalues : LocalData
  (LocalData.SetLocalData)("Announcement_", "AutoOpen", autoOpen)
end

GameAnnouncementData.GetAutoOpen = function(self)
  -- function num : 0_4 , upvalues : LocalData, _ENV
  local bAutoOpen = true
  if (LocalData.GetLocalData)("Announcement_", "AutoOpen") == nil then
    bAutoOpen = true
  else
    bAutoOpen = (LocalData.GetLocalData)("Announcement_", "AutoOpen")
  end
  local nTime = ((CS.ClientManager).Instance).serverTimeStamp
  local nLastTime = (LocalData.GetLocalData)("Announcement_", "Time") or 0
  if nLastTime < nTime then
    if not self:IsSameWeek(nTime, nLastTime) then
      bAutoOpen = true
    end
    ;
    (LocalData.SetLocalData)("Announcement_", "Time", nTime)
  end
  return bAutoOpen
end

GameAnnouncementData.GetTodayisOpen = function(self)
  -- function num : 0_5 , upvalues : _ENV, LocalData
  local bTodayIsOpen = false
  local nTime = ((CS.ClientManager).Instance).serverTimeStamp
  local nLastOpenTime = (LocalData.GetLocalData)("Announcement_", "LastOpenTime") or 0
  if self:IsSameDay(nTime, nLastOpenTime) then
    if (LocalData.GetLocalData)("Announcement_", "TodayOpened") == nil then
      bTodayIsOpen = false
    else
      bTodayIsOpen = (LocalData.GetLocalData)("Announcement_", "TodayOpened")
    end
  else
    bTodayIsOpen = false
  end
  return bTodayIsOpen
end

GameAnnouncementData.GetIsNeedAutoOpen = function(self)
  -- function num : 0_6
  local bHasNew = self:CheckHasNewAnn()
  if bHasNew then
    return true
  end
  if self:GetAutoOpen() then
    return not self:GetTodayisOpen()
  end
end

GameAnnouncementData.GetAnnInfoByType = function(self, nType)
  -- function num : 0_7
  if (self.tbTypeList)[nType] == nil then
    return nil
  end
  return (self.tbTypeList)[nType]
end

GameAnnouncementData.HasAnnouncement = function(self)
  -- function num : 0_8
  if self.tbTypeList == {} or self.tbTypeList == nil then
    return false
  end
  if #self.tbTypeList > 4 or #self.tbTypeList < 2 then
    return false
  end
  return true
end

GameAnnouncementData.GetHtmlData = function(self, nId)
  -- function num : 0_9
  if (self.tbAnnContentCache)[nId] ~= nil then
    return (self.tbAnnContentCache)[nId]
  else
    self:SendAnnContentQuest(nId)
    return nil
  end
end

GameAnnouncementData.SetAnnRead = function(self, nType, nId)
  -- function num : 0_10 , upvalues : _ENV, LocalData
  if nId == 0 then
    local list = (self.tbTypeList)[nType]
    if list ~= nil then
      for _,v in pairs(list) do
        (RedDotManager.SetValid)(RedDotDefine.Announcement_Content, {nType, v.Id}, false)
        ;
        (LocalData.SetLocalData)("AnnouncementIsRead", tostring(v.Id), true)
      end
    end
  else
    do
      ;
      (RedDotManager.SetValid)(RedDotDefine.Announcement_Content, {nType, nId}, false)
      ;
      (LocalData.SetLocalData)("AnnouncementIsRead", tostring(nId), true)
    end
  end
end

GameAnnouncementData.UpdateLastAnnData = function(self)
  -- function num : 0_11 , upvalues : LocalData, _ENV
  self.tbLastAnnList = self.tbCurAnnList
  ;
  (LocalData.SetLocalData)("Announcement_", "LastList", self.tbLastAnnList)
  ;
  (LocalData.SetLocalData)("Announcement_", "TodayOpened", true)
  local nTime = ((CS.ClientManager).Instance).serverTimeStamp
  ;
  (LocalData.SetLocalData)("Announcement_", "LastOpenTime", nTime)
end

GameAnnouncementData.CheckHasNewAnn = function(self)
  -- function num : 0_12 , upvalues : _ENV
  if self.tbCurAnnList == nil then
    return false
  end
  for _,value in pairs(self.tbCurAnnList) do
    if (table.keyof)(self.tbLastAnnList, value) == nil then
      return true
    end
  end
  return false
end

GameAnnouncementData.AllAnnResponse = function(self, listData)
  -- function num : 0_13 , upvalues : _ENV, LocalData
  self.tbAnnBaseInfo = {}
  self.tbTypeList = {}
  self.tbAnnContentCache = {}
  self.tbCurAnnList = {}
  for i = 0, (listData.System).Length - 1 do
    local v = (listData.System)[i]
    -- DECOMPILER ERROR at PC33: Confused about usage of register: R7 in 'UnsetPending'

    if (UTILS.CheckChannelList)(v.Channel) and v.ContentUrl ~= "" then
      (self.tbAnnBaseInfo)[v.Id] = {info = v, nType = (AllEnum.AnnType).SystemAnn}
      if (self.tbTypeList)[(AllEnum.AnnType).SystemAnn] == nil then
        local list = {}
        ;
        (table.insert)(list, v)
        -- DECOMPILER ERROR at PC51: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self.tbTypeList)[(AllEnum.AnnType).SystemAnn] = list
      else
        do
          ;
          (table.insert)((self.tbTypeList)[(AllEnum.AnnType).SystemAnn], v)
          do
            local bIsRead = false
            if (LocalData.GetLocalData)("AnnouncementIsRead", tostring(v.Id)) == nil then
              bIsRead = false
            else
              bIsRead = (LocalData.GetLocalData)("AnnouncementIsRead", tostring(v.Id))
            end
            ;
            (RedDotManager.SetValid)(RedDotDefine.Announcement_Content, {(AllEnum.AnnType).SystemAnn, v.Id}, not bIsRead)
            ;
            (table.insert)(self.tbCurAnnList, v.Id)
            -- DECOMPILER ERROR at PC97: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC97: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC97: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC97: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC97: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
  for i = 0, (listData.Activity).Length - 1 do
    local v = (listData.Activity)[i]
    -- DECOMPILER ERROR at PC123: Confused about usage of register: R7 in 'UnsetPending'

    if (UTILS.CheckChannelList)(v.Channel) and v.ContentUrl ~= "" then
      (self.tbAnnBaseInfo)[v.Id] = {info = v, nType = (AllEnum.AnnType).ActivityAnn}
      if (self.tbTypeList)[(AllEnum.AnnType).ActivityAnn] == nil then
        local list = {}
        ;
        (table.insert)(list, v)
        -- DECOMPILER ERROR at PC141: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self.tbTypeList)[(AllEnum.AnnType).ActivityAnn] = list
      else
        do
          ;
          (table.insert)((self.tbTypeList)[(AllEnum.AnnType).ActivityAnn], v)
          do
            do
              local bIsRead = false
              if (LocalData.GetLocalData)("AnnouncementIsRead", tostring(v.Id)) == nil then
                bIsRead = false
              else
                bIsRead = (LocalData.GetLocalData)("AnnouncementIsRead", tostring(v.Id))
              end
              ;
              (RedDotManager.SetValid)(RedDotDefine.Announcement_Content, {(AllEnum.AnnType).ActivityAnn, v.Id}, not bIsRead)
              ;
              (table.insert)(self.tbCurAnnList, v.Id)
              -- DECOMPILER ERROR at PC187: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC187: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC187: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC187: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC187: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC187: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
  for i = 0, (listData.Other1).Length - 1 do
    local v = (listData.Other1)[i]
    -- DECOMPILER ERROR at PC213: Confused about usage of register: R7 in 'UnsetPending'

    if (UTILS.CheckChannelList)(v.Channel) and v.ContentUrl ~= "" then
      (self.tbAnnBaseInfo)[v.Id] = {info = v, nType = (AllEnum.AnnType).Other1}
      if (self.tbTypeList)[(AllEnum.AnnType).Other1] == nil then
        local list = {}
        ;
        (table.insert)(list, v)
        -- DECOMPILER ERROR at PC231: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self.tbTypeList)[(AllEnum.AnnType).Other1] = list
      else
        do
          ;
          (table.insert)((self.tbTypeList)[(AllEnum.AnnType).Other1], v)
          do
            do
              local bIsRead = false
              if (LocalData.GetLocalData)("AnnouncementIsRead", tostring(v.Id)) == nil then
                bIsRead = false
              else
                bIsRead = (LocalData.GetLocalData)("AnnouncementIsRead", tostring(v.Id))
              end
              ;
              (RedDotManager.SetValid)(RedDotDefine.Announcement_Content, {(AllEnum.AnnType).Other1, v.Id}, not bIsRead)
              ;
              (table.insert)(self.tbCurAnnList, v.Id)
              -- DECOMPILER ERROR at PC277: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC277: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC277: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC277: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC277: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC277: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
  for i = 0, (listData.Other2).Length - 1 do
    local v = (listData.Other2)[i]
    -- DECOMPILER ERROR at PC303: Confused about usage of register: R7 in 'UnsetPending'

    if (UTILS.CheckChannelList)(v.Channel) and v.ContentUrl ~= "" then
      (self.tbAnnBaseInfo)[v.Id] = {info = v, nType = (AllEnum.AnnType).Other2}
      if (self.tbTypeList)[(AllEnum.AnnType).Other2] == nil then
        local list = {}
        ;
        (table.insert)(list, v)
        -- DECOMPILER ERROR at PC321: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self.tbTypeList)[(AllEnum.AnnType).Other2] = list
      else
        do
          ;
          (table.insert)((self.tbTypeList)[(AllEnum.AnnType).Other2], v)
          do
            do
              local bIsRead = false
              if (LocalData.GetLocalData)("AnnouncementIsRead", tostring(v.Id)) == nil then
                bIsRead = false
              else
                bIsRead = (LocalData.GetLocalData)("AnnouncementIsRead", tostring(v.Id))
              end
              ;
              (RedDotManager.SetValid)(RedDotDefine.Announcement_Content, {(AllEnum.AnnType).Other2, v.Id}, not bIsRead)
              ;
              (table.insert)(self.tbCurAnnList, v.Id)
              -- DECOMPILER ERROR at PC367: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC367: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC367: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC367: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC367: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC367: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
  if self.requestAllDataCallback then
    (self.requestAllDataCallback)()
    self.requestAllDataCallback = nil
  end
  self.bLoadAllData = false
  ;
  (EventManager.Hit)("AnnAllDataReady")
end

GameAnnouncementData.AllAnnResponse_Fail = function(self)
  -- function num : 0_14
  if self.requestAllDataCallback then
    (self.requestAllDataCallback)()
    self.requestAllDataCallback = nil
  end
  self.bLoadAllData = false
end

GameAnnouncementData.AnnContentResponse = function(self, nId, content)
  -- function num : 0_15 , upvalues : _ENV
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self.tbAnnContentCache)[nId] = content
  ;
  (EventManager.Hit)("AnnContentReady", nId)
end

GameAnnouncementData.SendAllDataQuest = function(self, callback_success)
  -- function num : 0_16 , upvalues : _ENV
  if self.bLoadAllData then
    return 
  end
  self.bLoadAllData = true
  self.requestAllDataCallback = callback_success
  ;
  (CS.HttpNetworkManager):RequestAllAnnData()
end

GameAnnouncementData.SendAnnContentQuest = function(self, nId)
  -- function num : 0_17 , upvalues : _ENV
  local annInfo = (self.tbAnnBaseInfo)[nId]
  ;
  ((CS.HttpNetworkManager).RequestAnnContent)(nId, (annInfo.info).ContentUrl)
end

GameAnnouncementData.GetHtmlFrame = function(self)
  -- function num : 0_18 , upvalues : _ENV, htmlConfigId
  local htmlFrame = (ConfigTable.GetData)("HtmlConfig", htmlConfigId)
  if htmlFrame ~= nil then
    return htmlFrame.HtmlFrame
  end
  return ""
end

local GetCurrentYearInfo = function(time_s)
  -- function num : 0_19 , upvalues : _ENV
  local day = (os.date)("%d", time_s)
  local weekIndex = (os.date)("%W", time_s)
  local month = (os.date)("%m", time_s)
  local yearNum = (os.date)("%Y", time_s)
  return {year = yearNum, month = month, weekIdx = weekIndex, day = day}
end

GameAnnouncementData.IsSameDay = function(self, stampA, stampB, resetHour)
  -- function num : 0_20 , upvalues : _ENV, GetCurrentYearInfo
  if not resetHour then
    resetHour = 5
  end
  local resetSeconds = resetHour * 3600
  stampA = stampA - resetSeconds
  stampB = stampB - resetSeconds
  stampA = (math.max)(stampA, 0)
  stampB = (math.max)(stampB, 0)
  local dateA = GetCurrentYearInfo(stampA)
  local dateB = GetCurrentYearInfo(stampB)
  do return dateA.day == dateB.day and dateA.month == dateB.month and dateA.year == dateB.year end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

GameAnnouncementData.IsSameWeek = function(self, stampA, stampB, resetHour)
  -- function num : 0_21 , upvalues : _ENV, GetCurrentYearInfo
  if not resetHour then
    resetHour = 5
  end
  local resetSeconds = resetHour * 3600
  stampA = stampA - resetSeconds
  stampB = stampB - resetSeconds
  stampA = (math.max)(stampA, 0)
  stampB = (math.max)(stampB, 0)
  local dateA = GetCurrentYearInfo(stampA)
  local dateB = GetCurrentYearInfo(stampB)
  do return dateA.weekIdx == dateB.weekIdx and dateA.year == dateB.year end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

return GameAnnouncementData

