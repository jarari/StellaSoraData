local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local PeriodicQuestActData = class("PeriodicQuestActData", ActivityDataBase)
local ClientManager = (CS.ClientManager).Instance
PeriodicQuestActData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.tbAllQuestList = {}
  self.bFinalStatus = false
  self.perQuestActCfg = (ConfigTable.GetData)("PeriodicQuestControl", self.nActId)
  self.nMaxQuestDay = self:GetMaxOpenDay()
end

PeriodicQuestActData.CreateQuest = function(self, mapQuestData)
  -- function num : 0_1 , upvalues : _ENV
  local tbQuestData = {}
  tbQuestData.Id = mapQuestData.Id
  if (mapQuestData.Progress)[1] ~= nil then
    tbQuestData.nCurProcess = ((mapQuestData.Progress)[1]).Cur
    tbQuestData.nTotalProcess = ((mapQuestData.Progress)[1]).Max
  else
    tbQuestData.nCurProcess = 0
    tbQuestData.nTotalProcess = 0
  end
  if mapQuestData.Status == 0 then
    tbQuestData.nStatus = (AllEnum.ActQuestStatus).UnComplete
  else
    if mapQuestData.Status == 1 then
      tbQuestData.nStatus = (AllEnum.ActQuestStatus).Complete
    else
      if mapQuestData.Status == 2 then
        tbQuestData.nStatus = (AllEnum.ActQuestStatus).Received
      end
    end
  end
  local questCfg = (ConfigTable.GetData)("PeriodicQuest", mapQuestData.Id)
  local nGroupId = questCfg.Groupid
  tbQuestData.nGroupId = nGroupId
  local nDay = ((CacheTable.GetData)("_PeriodicQuestDay", self.nActId))[nGroupId]
  tbQuestData.nDay = nDay
  return tbQuestData
end

PeriodicQuestActData.RefreshQuestList = function(self, mapQuestList)
  -- function num : 0_2 , upvalues : _ENV
  for _,v in ipairs(mapQuestList) do
    local tbQuestData = self:CreateQuest(v)
    -- DECOMPILER ERROR at PC9: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self.tbAllQuestList)[v.Id] = tbQuestData
  end
  self:RefreshRedDot()
end

PeriodicQuestActData.RefreshQuestData = function(self, questData)
  -- function num : 0_3 , upvalues : _ENV
  -- DECOMPILER ERROR at PC5: Confused about usage of register: R2 in 'UnsetPending'

  (self.tbAllQuestList)[questData.Id] = self:CreateQuest(questData)
  self:RefreshRedDot()
  local bAllQuestComplete = self:CheckAllQuestComplete()
  if bAllQuestComplete then
    (PlayerData.Base):UserEventUpload_PC("pc_start_mission_minerva")
  end
end

PeriodicQuestActData.RefreshQuestStatus = function(self, nQuestId)
  -- function num : 0_4 , upvalues : _ENV
  local tbQuestList = {}
  if nQuestId == 0 then
    for questId,v in pairs(self.tbAllQuestList) do
      if v.nStatus == (AllEnum.ActQuestStatus).Complete then
        (table.insert)(tbQuestList, questId)
        v.nStatus = (AllEnum.ActQuestStatus).Received
      end
    end
  else
    do
      if (self.tbAllQuestList)[nQuestId] ~= nil then
        (table.insert)(tbQuestList, nQuestId)
        -- DECOMPILER ERROR at PC39: Confused about usage of register: R3 in 'UnsetPending'

        ;
        ((self.tbAllQuestList)[nQuestId]).nStatus = (AllEnum.ActQuestStatus).Received
      end
      self:RefreshRedDot()
      return tbQuestList
    end
  end
end

PeriodicQuestActData.RefreshFinalStatus = function(self, bFinalStatus)
  -- function num : 0_5
  self.bFinalStatus = bFinalStatus
  self:RefreshRedDot()
end

PeriodicQuestActData.GetQuestListByGroup = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local tbQuestList = {}
  for _,v in pairs(self.tbAllQuestList) do
    if tbQuestList[v.nGroupId] == nil then
      tbQuestList[v.nGroupId] = {}
    end
    ;
    (table.insert)(tbQuestList[v.nGroupId], v)
  end
  return tbQuestList
end

PeriodicQuestActData.GetQuestListByDay = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local tbQuestList = {}
  for _,v in pairs(self.tbAllQuestList) do
    if tbQuestList[v.nDay] == nil then
      tbQuestList[v.nDay] = {}
    end
    ;
    (table.insert)(tbQuestList[v.nDay], v)
  end
  return tbQuestList
end

PeriodicQuestActData.GetCurOpenDay = function(self)
  -- function num : 0_8 , upvalues : _ENV, ClientManager
  local nMaxDay = (CacheTable.GetData)("_PeriodicQuestMaxDay", self.nActId)
  if nMaxDay == nil then
    printError("读取PeriodicQuestGroup配置失败！！！actId = " .. tostring(self.nActId))
    return 1
  end
  local nCurTime = ClientManager.serverTimeStamp
  local nOpenTime = self.nOpenTime
  local nCurDay = 0
  local nNextRefreshTime = ClientManager:GetNextRefreshTime(nOpenTime)
  while nOpenTime < nNextRefreshTime and nOpenTime < nCurTime and nCurDay <= nMaxDay do
    nOpenTime = nNextRefreshTime
    nCurDay = nCurDay + 1
    nNextRefreshTime = ClientManager:GetNextRefreshTime(nOpenTime)
  end
  nCurDay = (math.min)(nCurDay, nMaxDay)
  return nCurDay
end

PeriodicQuestActData.GetMaxOpenDay = function(self)
  -- function num : 0_9 , upvalues : _ENV
  local nMaxDay = 0
  local groupCfg = (CacheTable.GetData)("_PeriodicQuestDay", self.nActId)
  if groupCfg ~= nil then
    for _,v in pairs(groupCfg) do
      if nMaxDay < v then
        nMaxDay = v
      end
    end
  end
  do
    return nMaxDay
  end
end

PeriodicQuestActData.GetCanReceiveRewardGroup = function(self)
  -- function num : 0_10 , upvalues : _ENV
  local nGroupId = 0
  local nCurDay = self:GetCurOpenDay()
  for _,v in pairs(self.tbAllQuestList) do
    if v.nDay <= nCurDay and v.nStatus == (AllEnum.ActQuestStatus).Complete and nGroupId < v.nGroupId then
      nGroupId = v.nGroupId
    end
  end
  return nGroupId
end

PeriodicQuestActData.GetCanRecRewardDay = function(self)
  -- function num : 0_11 , upvalues : _ENV
  for _,v in pairs(self.tbAllQuestList) do
    if v.nStatus == (AllEnum.ActQuestStatus).Complete then
      return v.nDay
    end
  end
  return 0
end

PeriodicQuestActData.GetDayQuestStatus = function(self, nDay)
  -- function num : 0_12 , upvalues : _ENV
  local nAllQuest, nReceivedQuest = 0, 0
  for _,v in pairs(self.tbAllQuestList) do
    if v.nDay == nDay then
      nAllQuest = nAllQuest + 1
      if v.nStatus == (AllEnum.ActQuestStatus).Received then
        nReceivedQuest = nReceivedQuest + 1
      end
    end
  end
  return nAllQuest, nReceivedQuest
end

PeriodicQuestActData.GetNextDayOpenTime = function(self)
  -- function num : 0_13 , upvalues : ClientManager, _ENV
  local nextRefreshTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
  local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
  local nRemainTime = nextRefreshTime - nCurTime
  return (math.floor)(nRemainTime / 3600)
end

PeriodicQuestActData.GetPerQuestCfg = function(self)
  -- function num : 0_14
  return self.perQuestActCfg
end

PeriodicQuestActData.GetQuestProgress = function(self)
  -- function num : 0_15 , upvalues : _ENV
  local curProgress = 0
  local allProgress = #(CacheTable.GetData)("_PeriodicQuest", self.nActId)
  local canReceive = 0
  local nCurDay = self:GetCurOpenDay()
  for _,v in pairs(self.tbAllQuestList) do
    if v.nDay <= nCurDay then
      if v.nStatus == (AllEnum.ActQuestStatus).Received then
        curProgress = curProgress + 1
      else
        if v.nStatus == (AllEnum.ActQuestStatus).Complete then
          canReceive = canReceive + 1
        end
      end
    end
  end
  return curProgress, allProgress, canReceive
end

PeriodicQuestActData.CheckFinalReward = function(self)
  -- function num : 0_16
  return self.bFinalStatus
end

PeriodicQuestActData.CheckAllQuestComplete = function(self)
  -- function num : 0_17 , upvalues : _ENV
  local bAllComplete = true
  for nId,v in pairs(self.tbAllQuestList) do
    if v.nStatus == (AllEnum.ActQuestStatus).UnComplete then
      bAllComplete = false
      break
    end
  end
  do
    return bAllComplete
  end
end

PeriodicQuestActData.RefreshRedDot = function(self)
  -- function num : 0_18 , upvalues : _ENV
  local bOpen = self:CheckActShow()
  local bQuestReward = false
  local tbGroupStatus = {}
  local nCurDay = self:GetCurOpenDay()
  if next(self.tbAllQuestList) ~= nil then
    for _,v in pairs(self.tbAllQuestList) do
      if v.nDay <= nCurDay then
        if tbGroupStatus[v.nGroupId] == nil then
          tbGroupStatus[v.nGroupId] = 0
        end
        if v.nStatus == (AllEnum.ActQuestStatus).Complete then
          tbGroupStatus[v.nGroupId] = tbGroupStatus[v.nGroupId] + 1
          bQuestReward = true
        end
      end
    end
    for group,v in pairs(tbGroupStatus) do
      (RedDotManager.SetValid)(RedDotDefine.Activity_Periodic_Quest_Group, {self.nActId, group}, (v > 0 and bOpen))
    end
    local nCur, nAll = self:GetQuestProgress()
    local bFinalReward = (nAll <= nCur and not self.bFinalStatus)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Activity_Periodic_Final_Reward, self.nActId, not bFinalReward or bOpen)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Activity_Tab, self.nActId, not bQuestReward and not bFinalReward or bOpen)
  end
  -- DECOMPILER ERROR: 9 unprocessed JMP targets
end

return PeriodicQuestActData

