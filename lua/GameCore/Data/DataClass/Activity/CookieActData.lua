local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local CookieActData = class("CookieActData", ActivityDataBase)
local LocalData = require("GameCore.Data.LocalData")
local newDayTime = (UTILS.GetDayRefreshTimeOffset)()
local nLastPath = 0
CookieActData.GetCookieControlCfg = function(self, ...)
  -- function num : 0_0 , upvalues : _ENV
  if not self.tbConfig then
    self.tbConfig = (ConfigTable.GetData)("CookieControl", self.nActId)
  end
  return self.tbConfig
end

CookieActData.GetLevelCfg = function(self, nPlayGroupId)
  -- function num : 0_1 , upvalues : _ENV
  local mapConfig = (ConfigTable.GetData)("CookieLevel", nPlayGroupId)
  if mapConfig == nil then
    return nil
  end
  return mapConfig
end

CookieActData.Init = function(self)
  -- function num : 0_2
  self.nTotalScore = 0
  self.nActCredit = 0
  self.nActId = 0
  self.nNightmareModeHighScore = 0
  self.tbLevelScore = {}
  self.tbLevelBox = {}
  self.tbModeComp = {}
  self.tbModeBox = {}
  self.tbModePerfect = {}
  self.tbModeExcellent = {}
  self.tbModeCookie = {}
  self:AddListeners()
end

CookieActData.AddListeners = function(self)
  -- function num : 0_3 , upvalues : _ENV
  (EventManager.Add)("Cookie_Game_Complete", self, self.OnEvent_GameComplete)
  ;
  (EventManager.Add)("Cookie_Quest_Claim", self, self.OnEvent_QuestClaim)
end

CookieActData.RefreshCookieGameActData = function(self, actId, msgData)
  -- function num : 0_4 , upvalues : _ENV
  self:Init()
  self.nActId = actId
  self.mapActData = (PlayerData.Activity):GetActivityDataById(self.nActId)
  if not (self.mapActData):GetActEndTime() then
    self.nEndTime = self.mapActData == nil or 0
    self.nOpenTime = (self.mapActData):GetActOpenTime() or 0
    if msgData ~= nil then
      self:CacheAllQuestData(msgData.Quests)
      self:CacheAllLevelData(msgData.Levels)
    end
  end
end

CookieActData.CacheAllQuestData = function(self, questListData)
  -- function num : 0_5 , upvalues : _ENV
  self.tbQuestDataList = {}
  for _,v in pairs(questListData) do
    local questData = {nId = v.Id, nStatus = self:QuestServer2Client(v.Status), 
progress = {Cur = #v.Progress > 0 and ((v.Progress)[1]).Cur or 1, Max = #v.Progress > 0 and ((v.Progress)[1]).Max or 1}
}
    ;
    (table.insert)(self.tbQuestDataList, questData)
  end
end

CookieActData.GetQuestData = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local tbData = {}
  for _,v in pairs(self.tbQuestDataList) do
    (table.insert)(tbData, v)
  end
  return tbData
end

CookieActData.CacheAllLevelData = function(self, levelListData)
  -- function num : 0_7 , upvalues : _ENV
  self.tbLevelDataList = {}
  for _,v in pairs(levelListData) do
    local levelData = {nId = v.LevelId, nMaxScore = v.MaxScore or 0, bFirstComplete = v.FirstComplete}
    ;
    (table.insert)(self.tbLevelDataList, levelData)
  end
end

CookieActData.GetLevelData = function(self)
  -- function num : 0_8
  return self.tbLevelDataList
end

CookieActData.GetLevelDataById = function(self, nId)
  -- function num : 0_9 , upvalues : _ENV
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

CookieActData.SetLevelData = function(self, nLevelId, nLevelScore)
  -- function num : 0_10 , upvalues : _ENV
  local oldLevelData = self:GetLevelDataById(nLevelId)
  if oldLevelData == nil then
    return 
  end
  oldLevelData.nMaxScore = (math.max)(oldLevelData.nMaxScore or 0, nLevelScore or 0)
  local mapCfg = self:GetLevelCfg(nLevelId)
  local bFirstComplete = mapCfg and mapCfg.FirstCompletionScore or 0 <= nLevelScore
  oldLevelData.bFirstComplete = oldLevelData.bFirstComplete or bFirstComplete
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

CookieActData.GetQuestDataById = function(self, nId)
  -- function num : 0_11 , upvalues : _ENV
  local questData = nil
  if self.tbQuestDataList ~= nil then
    for _,v in pairs(self.tbQuestDataList) do
      if v.nId == nId then
        questData = v
        break
      end
    end
  end
  do
    return questData
  end
end

CookieActData.RefreshQuestData = function(self, questData)
  -- function num : 0_12 , upvalues : _ENV
  local oldQuestData = self:GetQuestDataById(questData.Id)
  if oldQuestData == nil then
    return 
  end
  oldQuestData.nStatus = self:QuestServer2Client(questData.Status)
  oldQuestData.progress = {Cur = ((questData.Progress)[1]).Cur, Max = ((questData.Progress)[1]).Max}
  ;
  (EventManager.Hit)("CookieQuestUpdate")
end

CookieActData.RefreshQuestReddot = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local bTabReddot = false
  if next(self.tbQuestDataList) ~= nil then
    for _,v in pairs(self.tbQuestDataList) do
      local bReddot = v.nStatus == (AllEnum.ActQuestStatus).Complete
      ;
      (RedDotManager.SetValid)(RedDotDefine.Activity_Cookie_Quest, v.nId, bReddot)
      if not bTabReddot then
        bTabReddot = bReddot
      end
    end
  end
  if not bTabReddot then
    (RedDotManager.SetValid)(RedDotDefine.Activity_Tab, self.nActId, self.bIsFirst)
    -- DECOMPILER ERROR: 4 unprocessed JMP targets
  end
end

CookieActData.SendQuestReceive = function(self, nQuestId)
  -- function num : 0_14 , upvalues : _ENV
  local callback = function(_, msgData)
    -- function num : 0_14_0 , upvalues : _ENV, nQuestId, self
    (UTILS.OpenReceiveByChangeInfo)(msgData, nil)
    if nQuestId == 0 then
      for _,v in pairs(self.tbQuestDataList) do
        if v.nStatus == (AllEnum.ActQuestStatus).Complete then
          v.nStatus = (AllEnum.ActQuestStatus).Received
        end
      end
    else
      do
        do
          local questData = self:GetQuestDataById(nQuestId)
          if questData then
            questData.nStatus = (AllEnum.ActQuestStatus).Received
          end
          ;
          (EventManager.Hit)("CookieQuestUpdate")
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_cookie_quest_reward_receive_req, {ActivityId = self.nActId, QuestId = nQuestId}, nil, callback)
end

CookieActData.QuestServer2Client = function(self, nStatus)
  -- function num : 0_15 , upvalues : _ENV
  if nStatus == 0 then
    return (AllEnum.ActQuestStatus).UnComplete
  else
    if nStatus == 1 then
      return (AllEnum.ActQuestStatus).Complete
    else
      return (AllEnum.ActQuestStatus).Received
    end
  end
end

CookieActData.IsLevelUnlocked = function(self, nLevelId)
  -- function num : 0_16 , upvalues : _ENV
  local bTimeUnlock, bPreComplete = false, false
  local mapData = self:GetLevelCfg(nLevelId)
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  local openTime = ((CS.ClientManager).Instance):GetNextRefreshTime(self.nOpenTime) - 86400
  local remainTime = openTime + mapData.DayOpen * 86400 - curTime
  local nPreLevelId = mapData.PreLevelId or 0
  local mapLevelStatus = self:GetLevelDataById(nPreLevelId)
  bTimeUnlock = remainTime <= 0
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

CookieActData.GetActEndTime = function(self)
  -- function num : 0_17
  return self.nEndTime
end

CookieActData.GetActOpenTime = function(self)
  -- function num : 0_18
  return self.nOpenTime
end

CookieActData.SetLevelReward = function(self, changeInfo)
  -- function num : 0_19
  if changeInfo ~= nil and #changeInfo.Props > 0 then
    self.tbLevelReward = changeInfo
  else
    self.tbLevelReward = nil
  end
end

CookieActData.GetLevelReward = function(self)
  -- function num : 0_20
  return self.tbLevelReward
end

CookieActData.GetNMHighScoreToday = function(self)
  -- function num : 0_21 , upvalues : LocalData, _ENV, newDayTime
  local bToday = false
  local TipsTime = (LocalData.GetPlayerLocalData)("Cookie_Nightmare_HighScoreDay")
  local _tipDay = 0
  if TipsTime ~= nil then
    _tipDay = tonumber(TipsTime)
  end
  local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local fixedTimeStamp = curTimeStamp - newDayTime * 3600
  local nYear = tonumber((os.date)("!%Y", fixedTimeStamp))
  local nMonth = tonumber((os.date)("!%m", fixedTimeStamp))
  local nDay = tonumber((os.date)("!%d", fixedTimeStamp))
  local nowD = nYear * 366 + nMonth * 31 + nDay
  if nowD == _tipDay then
    bToday = true
  end
  return bToday
end

CookieActData.SetNMHighScoreDay = function(self)
  -- function num : 0_22 , upvalues : _ENV, newDayTime, LocalData
  local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local fixedTimeStamp = curTimeStamp - newDayTime * 3600
  local nYear = tonumber((os.date)("!%Y", fixedTimeStamp))
  local nMonth = tonumber((os.date)("!%m", fixedTimeStamp))
  local nDay = tonumber((os.date)("!%d", fixedTimeStamp))
  local nDayCount = nYear * 366 + nMonth * 31 + nDay
  ;
  (LocalData.SetPlayerLocalData)("Cookie_Nightmare_HighScoreDay", nDayCount)
end

CookieActData.RequestLevelResult = function(self, nLevelId, nScore, nBoxCount, nCookieCount, nGoodCount, nPerfectCount, nExcellentCount, nMissCount, callback)
  -- function num : 0_23 , upvalues : _ENV
  local callbackFunc = function(_, msgData)
    -- function num : 0_23_0 , upvalues : self, nLevelId, nScore, callback
    self:SetLevelData(nLevelId, nScore)
    self:SetLevelReward(msgData)
    if callback then
      callback(msgData)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_cookie_settle_req, {ActivityId = self.nActId, LevelId = nLevelId, Score = nScore, PackageNum = nBoxCount, CookieNum = nCookieCount, PerfectNum = nPerfectCount, ExcellentNum = nExcellentCount, MissNum = nMissCount, Good = nGoodCount}, nil, callbackFunc)
end

CookieActData.OnEvent_GameComplete = function(self, nLevelId, nScore, nBoxCount, nCookieCount, nGoodCount, nPerfectCount, nExcellentCount, nMissCount, callback)
  -- function num : 0_24
  self:RequestLevelResult(nLevelId, nScore, nBoxCount, nCookieCount, nGoodCount, nPerfectCount, nExcellentCount, nMissCount, callback)
end

CookieActData.OnEvent_QuestClaim = function(self, nQuestId)
  -- function num : 0_25
  self:SendQuestReceive(nQuestId)
end

return CookieActData

