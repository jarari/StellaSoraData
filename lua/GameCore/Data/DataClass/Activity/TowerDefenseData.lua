local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local TowerDefenseData = class("TowerDefenseData", ActivityDataBase)
local LocalData = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
local RedDotManager = require("GameCore.RedDot.RedDotManager")
local ClientManager = (CS.ClientManager).Instance
local TowerDefenseLevelData = require("GameCore.Data.DataClass.Activity.TowerDefenseLevelData")
TowerDefenseData.Init = function(self)
  -- function num : 0_0
  self:InitData()
  self:AddListeners()
end

TowerDefenseData.InitData = function(self)
  -- function num : 0_1 , upvalues : TowerDefenseLevelData
  self.allLevelData = {}
  self.teamData = {}
  self.allQuestData = {}
  self.allStoryData = {}
  self.guideData = {}
  self.cacheEnterLevelList = {}
  self.TowerDefenseLevelData = (TowerDefenseLevelData.new)()
  self.TempLevelTeamData = {}
end

TowerDefenseData.UpdateStatus = function(self)
  -- function num : 0_2 , upvalues : _ENV, RedDotManager
  for _,levelData in pairs(self.allLevelData) do
    local levelConfig = (ConfigTable.GetData)("TowerDefenseLevel", levelData.nLevelId)
    if levelConfig ~= nil and self:IsLevelUnlock(levelData.nLevelId) then
      (RedDotManager.SetValid)(RedDotDefine.Activity_TowerDefense_Level, {levelConfig.LevelPage, levelData.nLevelId}, self:GetlevelIsNew(levelData.nLevelId))
    end
  end
  for _,storyData in pairs(self.allStoryData) do
    (RedDotManager.SetValid)(RedDotDefine.Activity_TowerDefense_Story, {storyData.nId}, self:GetStoryIsNew(storyData.nId))
  end
  self:RefreshRedDot()
end

TowerDefenseData.AddListeners = function(self)
  -- function num : 0_3 , upvalues : _ENV
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

TowerDefenseData.GetActConfig = function(self)
  -- function num : 0_4 , upvalues : _ENV
  self.actCfgData = (ConfigTable.GetData)("TowerDefenseControl", self.nActId)
  return self.actCfgData
end

TowerDefenseData.RefreshTowerDefenseActData = function(self, actId, msgData)
  -- function num : 0_5 , upvalues : LocalData, _ENV
  self:InitData()
  self.nActId = actId
  local sJson = (LocalData.GetPlayerLocalData)("TowerDefenseLevel")
  local tb = decodeJson(sJson)
  if type(tb) == "table" then
    self.cacheEnterLevelList = tb
  end
  for _,level in pairs(msgData.Levels) do
    self:UpdateLevelData(level)
  end
  local curActLevelIds = {}
  local foreachTable = function(data)
    -- function num : 0_5_0 , upvalues : self, _ENV, curActLevelIds
    if data.activityId == self.nActId then
      (table.insert)(curActLevelIds, data.Id)
    end
  end

  ForEachTableLine(DataTable.TowerDefenseLevel, foreachTable)
  for _,levelId in pairs(curActLevelIds) do
    if (self.allLevelData)[levelId] == nil then
      self:UpdateLevelData({Id = levelId, Star = 0})
    end
  end
  local allStoryConfigList = {}
  local foreach_storyTable = function(data)
    -- function num : 0_5_1 , upvalues : self, _ENV, allStoryConfigList
    if data.ActivityIdId == self.nActId then
      (table.insert)(allStoryConfigList, data.Id)
    end
  end

  ForEachTableLine(DataTable.TowerDefenseStory, foreach_storyTable)
  local tempStoryData = {}
  for _,value in pairs(allStoryConfigList) do
    tempStoryData[value] = {nId = value, bIsRead = false}
  end
  for _,value in pairs(msgData.Stories) do
    tempStoryData[value] = {nId = value, bIsRead = true}
  end
  for _,value in pairs(tempStoryData) do
    self:UpdateStoryData(value)
  end
  local foreach_questGroupTable = function(data)
    -- function num : 0_5_2 , upvalues : self
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

    if data.ActivityId == self.nActId then
      (self.allQuestData)[data.Id] = {}
    end
  end

  ForEachTableLine(DataTable.TowerDefenseQuestGroup, foreach_questGroupTable)
  local foreach_questTable = function(data)
    -- function num : 0_5_3 , upvalues : self, _ENV
    if (self.allQuestData)[data.QuestGroupId] ~= nil then
      local nMax = 1
      if data.QuestType == (GameEnum.towerDefenseCond).TowerDefenseClear then
        nMax = 1
      else
        if data.QuestType == (GameEnum.towerDefenseCond).TowerDefenseClearSpecificStar then
          nMax = 1
        end
      end
      local progressData = {}
      ;
      (table.insert)(progressData, {Cur = 0, Max = nMax})
      self:UpdateQuest({nId = data.Id, nState = (AllEnum.ActQuestStatus).UnComplete, progress = progressData})
    end
  end

  ForEachTableLine(DataTable.TowerDefenseQuest, foreach_questTable)
  for _,quest in pairs(msgData.Quests) do
    self:UpdateQuest({nId = quest.Id, nState = self:QuestStateServer2Client(quest.Status), progress = quest.Progress})
  end
  self:RefreshRedDot()
end

TowerDefenseData.GetLevelStartTime = function(self, levelId)
  -- function num : 0_6 , upvalues : _ENV, ClientManager
  local levelConfig = (ConfigTable.GetData)("TowerDefenseLevel", levelId)
  if levelConfig == nil then
    return 0
  end
  local openActDayNextTime = ClientManager:GetNextRefreshTime(self.nOpenTime)
  local nTempDay = 0
  if self.nOpenTime < openActDayNextTime then
    nTempDay = 1
  end
  local nDay = (ClientManager.serverTimeStamp - openActDayNextTime) // 86400 + nTempDay
  if levelConfig.ActiveTime <= nDay then
    return 0
  end
  local openDayNextTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
  return openDayNextTime + (levelConfig.ActiveTime - nDay - 1) * 86400
end

TowerDefenseData.UpdateLevelData = function(self, levelData)
  -- function num : 0_7 , upvalues : _ENV, RedDotManager
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

  (self.allLevelData)[levelData.Id] = {nLevelId = levelData.Id, nStar = levelData.Star}
  local levelConfig = (ConfigTable.GetData)("TowerDefenseLevel", levelData.Id)
  if levelConfig == nil then
    return 
  end
  if self:GetPlayState() and self:IsLevelUnlock(levelData.Id) then
    (RedDotManager.SetValid)(RedDotDefine.Activity_TowerDefense_Level, {levelConfig.LevelPage, levelData.Id}, self:GetlevelIsNew(levelData.Id))
  end
  ;
  (EventManager.Hit)("TowerDefenseLevelUpdate")
end

TowerDefenseData.GetAllLevelData = function(self)
  -- function num : 0_8
  return self.allLevelData
end

TowerDefenseData.GetLevelsByTab = function(self, nTabIndex)
  -- function num : 0_9 , upvalues : _ENV
  local levelsData = {}
  for _,level in pairs(self.allLevelData) do
    local config = (ConfigTable.GetData)("TowerDefenseLevel", level.nLevelId)
    if config.LevelPage == nTabIndex then
      (table.insert)(levelsData, level)
    end
  end
  return levelsData
end

TowerDefenseData.GetLevelData = function(self, levelId)
  -- function num : 0_10
  return (self.allLevelData)[levelId]
end

TowerDefenseData.IsLevelPass = function(self, levelId)
  -- function num : 0_11
  local bResult = false
  local levelData = self:GetLevelData(levelId)
  if levelData ~= nil and levelData.nStar > 0 then
    bResult = true
  end
  return bResult
end

TowerDefenseData.IsLevelUnlock = function(self, levelId)
  -- function num : 0_12 , upvalues : _ENV
  if levelId == 0 then
    return true
  end
  local bResult = false
  local levelData = self:GetLevelData(levelId)
  local time = ((CS.ClientManager).Instance).serverTimeStamp
  if levelData ~= nil and self:GetLevelStartTime(levelData.nLevelId) <= time then
    bResult = true
  end
  return bResult
end

TowerDefenseData.IsPreLevelPass = function(self, levelId)
  -- function num : 0_13 , upvalues : _ENV
  if levelId == 0 then
    return true
  end
  local bResult = false
  local levelConfig = (ConfigTable.GetData)("TowerDefenseLevel", levelId)
  if levelConfig == nil then
    return bResult
  end
  local preLevelId = levelConfig.PreLevel
  if preLevelId == 0 then
    bResult = true
  else
    local levelData = self:GetLevelData(preLevelId)
    if levelData ~= nil and levelData.nStar > 0 then
      bResult = true
    end
  end
  do
    return bResult
  end
end

TowerDefenseData.GetlevelIsNew = function(self, levelId)
  -- function num : 0_14 , upvalues : _ENV
  local bResult = false
  local levelData = self:GetLevelData(levelId)
  if levelData ~= nil and levelData.nStar == 0 and (table.indexof)(self.cacheEnterLevelList, levelId) == 0 then
    bResult = true
  end
  return bResult
end

TowerDefenseData.EnterLevelSelect = function(self, levelId)
  -- function num : 0_15 , upvalues : _ENV, RedDotManager, LocalData, RapidJson
  local levelConfig = (ConfigTable.GetData)("TowerDefenseLevel", levelId)
  if levelConfig == nil then
    return 
  end
  if (table.indexof)(self.cacheEnterLevelList, levelId) == 0 then
    (table.insert)(self.cacheEnterLevelList, levelId)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Activity_TowerDefense_Level, {levelConfig.LevelPage, levelId}, false)
    ;
    (LocalData.SetPlayerLocalData)("TowerDefenseLevel", (RapidJson.encode)(self.cacheEnterLevelList))
    self:RefreshRedDot()
  end
end

TowerDefenseData.RefreshRedDotbyTab = function(self, nTabIndex)
  -- function num : 0_16 , upvalues : _ENV, RedDotManager, LocalData, RapidJson
  for levelId,_ in pairs(self.allLevelData) do
    local levelConfig = (ConfigTable.GetData)("TowerDefenseLevel", levelId)
    if levelConfig == nil then
      return 
    end
    if levelConfig.LevelPage == nTabIndex and (table.indexof)(self.cacheEnterLevelList, levelId) == 0 then
      (table.insert)(self.cacheEnterLevelList, levelId)
      ;
      (RedDotManager.SetValid)(RedDotDefine.Activity_TowerDefense_Level, {levelConfig.LevelPage, levelId}, false)
    end
  end
  ;
  (LocalData.SetPlayerLocalData)("TowerDefenseLevel", (RapidJson.encode)(self.cacheEnterLevelList))
  self:RefreshRedDot()
end

TowerDefenseData.GetNextLevelUnlockTime = function(self)
  -- function num : 0_17 , upvalues : _ENV
  local nextlevelStartTime = 9999999999
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  for _,level in pairs(self.allLevelData) do
    local startTime = self:GetLevelStartTime(level.nLevelId)
    if curTime < startTime then
      nextlevelStartTime = (math.min)(nextlevelStartTime, startTime)
    end
  end
  nextlevelStartTime = 0
  return nextlevelStartTime
end

TowerDefenseData.GetLevelTempTeamData = function(self, levelId)
  -- function num : 0_18
  return (self.TempLevelTeamData)[levelId]
end

TowerDefenseData.SetLevelTeamData = function(self, levelId, tbCharGuideId, itemGuideId)
  -- function num : 0_19
  -- DECOMPILER ERROR at PC4: Confused about usage of register: R4 in 'UnsetPending'

  (self.TempLevelTeamData)[levelId] = {tbCharGuideId = tbCharGuideId, itemGuideId = itemGuideId}
end

TowerDefenseData.UpdateStoryData = function(self, storyData)
  -- function num : 0_20 , upvalues : RedDotManager, _ENV
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

  (self.allStoryData)[storyData.nId] = {nId = storyData.Id, bIsRead = storyData.bIsRead}
  if self:GetPlayState() then
    (RedDotManager.SetValid)(RedDotDefine.Activity_TowerDefense_Story, {storyData.Id}, self:GetStoryIsNew(storyData.nId))
  end
  ;
  (EventManager.Hit)("TowerDefenseStoryUpdate")
end

TowerDefenseData.GetAllStoryData = function(self)
  -- function num : 0_21
  return self.allStoryData
end

TowerDefenseData.GetStoryData = function(self, storyId)
  -- function num : 0_22
  return (self.allStoryData)[storyId]
end

TowerDefenseData.IsStoryUnlock = function(self, storyId)
  -- function num : 0_23 , upvalues : _ENV
  local bResult = false
  local storyConfig = (ConfigTable.GetData)("TowerDefenseStory", storyId)
  if storyConfig == nil then
    return bResult
  end
  if storyConfig.LevelId == 0 then
    return true
  end
  if self:IsLevelUnlock(storyConfig.LevelId) then
    local blevelConditionPass = self:IsPreLevelPass(storyConfig.LevelId)
  end
  bResult = blevelConditionPass
  return bResult
end

TowerDefenseData.GetStoryIsNew = function(self, storyId)
  -- function num : 0_24
  local bResult = false
  local storyData = self:GetStoryData(storyId)
  if storyData ~= nil and not storyData.bIsRead and self:IsStoryUnlock(storyId) and self:IsPreStoryRead(storyId) then
    bResult = true
  end
  return bResult
end

TowerDefenseData.IsPreStoryRead = function(self, storyId)
  -- function num : 0_25 , upvalues : _ENV
  local bResult = false
  local storyConfig = (ConfigTable.GetData)("TowerDefenseStory", storyId)
  if storyConfig == nil then
    return bResult
  end
  local preStoryId = storyConfig.PreStoryId
  if preStoryId == 0 then
    bResult = true
  else
    local preStoryData = self:GetStoryData(preStoryId)
    if preStoryData ~= nil and preStoryData.bIsRead then
      bResult = true
    end
  end
  do
    return bResult
  end
end

TowerDefenseData.PlayAvg = function(self, storyId, avgId)
  -- function num : 0_26 , upvalues : _ENV
  local avgEndCallback = function()
    -- function num : 0_26_0 , upvalues : _ENV, self, avgEndCallback, storyId
    (EventManager.Remove)("StoryDialog_DialogEnd", self, avgEndCallback)
    if ((self.allStoryData)[storyId]).bIsRead == false then
      self:RequestReadAVG(storyId)
    end
  end

  ;
  (EventManager.Add)("StoryDialog_DialogEnd", self, avgEndCallback)
  ;
  (EventManager.Hit)("StoryDialog_DialogStart", avgId)
end

TowerDefenseData.UpdateQuest = function(self, questData)
  -- function num : 0_27 , upvalues : _ENV, RedDotManager
  local questConfig = (ConfigTable.GetData)("TowerDefenseQuest", questData.nId)
  if questConfig == nil then
    return 
  end
  -- DECOMPILER ERROR at PC16: Confused about usage of register: R3 in 'UnsetPending'

  if (self.allQuestData)[questConfig.QuestGroupId] == nil then
    (self.allQuestData)[questConfig.QuestGroupId] = {}
  end
  local progress = {}
  local progressData = {}
  if questData.nState == (AllEnum.ActQuestStatus).Complete or questData.nState == (AllEnum.ActQuestStatus).Received then
    if questConfig.QuestType == (GameEnum.towerDefenseCond).TowerDefenseClear then
      progressData.Cur = 1
      progressData.Max = 1
    else
      if questConfig.QuestType == (GameEnum.towerDefenseCond).TowerDefenseClearSpecificStar then
        progressData.Cur = 1
        progressData.Max = 1
      else
        progressData.Cur = (questConfig.QuestParam)[2]
        progressData.Max = (questConfig.QuestParam)[2]
      end
    end
    ;
    (table.insert)(progress, progressData)
    -- DECOMPILER ERROR at PC70: Confused about usage of register: R5 in 'UnsetPending'

    ;
    ((self.allQuestData)[questConfig.QuestGroupId])[questData.nId] = {nId = questData.nId, nState = questData.nState, progress = progress}
  else
    -- DECOMPILER ERROR at PC83: Confused about usage of register: R5 in 'UnsetPending'

    ;
    ((self.allQuestData)[questConfig.QuestGroupId])[questData.nId] = {nId = questData.nId, nState = questData.nState, progress = questData.progress}
  end
  ;
  (RedDotManager.SetValid)(RedDotDefine.Activity_TowerDefense_Quest, {questConfig.QuestGroupId, questData.nId}, questData.nState == (AllEnum.ActQuestStatus).Complete)
  ;
  (EventManager.Hit)("TowerDefenseQuestUpdate")
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

TowerDefenseData.GetQuestbyGroupId = function(self, nGroupId)
  -- function num : 0_28
  return (self.allQuestData)[nGroupId]
end

TowerDefenseData.GetGroupQuestReceiveCount = function(self, nGroupId)
  -- function num : 0_29 , upvalues : _ENV
  local nResult = 0
  if (self.allQuestData)[nGroupId] == nil then
    return nResult
  end
  for _,quest in pairs((self.allQuestData)[nGroupId]) do
    if quest.nState == (AllEnum.ActQuestStatus).Received then
      nResult = nResult + 1
    end
  end
  return nResult
end

TowerDefenseData.GetAllQuestCount = function(self)
  -- function num : 0_30 , upvalues : _ENV
  local nResult = 0
  for _,groupQuestList in pairs(self.allQuestData) do
    for key,value in pairs(groupQuestList) do
      nResult = nResult + 1
    end
  end
  return nResult
end

TowerDefenseData.GetAllReceivedCount = function(self)
  -- function num : 0_31 , upvalues : _ENV
  local nResult = 0
  for _,groupQuestList in pairs(self.allQuestData) do
    for _,quest in pairs(groupQuestList) do
      if quest.nState == (AllEnum.ActQuestStatus).Received then
        nResult = nResult + 1
      end
    end
  end
  return nResult
end

TowerDefenseData.QuestStateServer2Client = function(self, nStatus)
  -- function num : 0_32 , upvalues : _ENV
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

TowerDefenseData.RefreshQuestData = function(self, questData)
  -- function num : 0_33
  self:UpdateQuest({nId = questData.Id, nState = self:QuestStateServer2Client(questData.Status), progress = questData.Progress})
  self:RefreshRedDot()
end

TowerDefenseData.InitTeam = function(self, levelId)
  -- function num : 0_34
  self.teamData = {
characterList = {}
, itemId = 0}
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R3 in 'UnsetPending'

  -- DECOMPILER ERROR at PC16: Confused about usage of register: R2 in 'UnsetPending'

  if self:IsLockTeam(levelId) then
    (self.teamData).characterList = self:GetLockCharacterAndItem(levelId)
  end
end

TowerDefenseData.IsLockTeam = function(self, levelId)
  -- function num : 0_35 , upvalues : _ENV
  local bResult = false
  local levelConfig = (ConfigTable.GetData)("TowerDefenseLevel", levelId)
  if levelConfig == nil then
    return bResult
  end
  local floorConfig = (ConfigTable.GetData)("TowerDefenseFloor", levelConfig.FloorId)
  if floorConfig == nil then
    return bResult
  end
  bResult = floorConfig.TeamGroup ~= nil and #floorConfig.TeamGroup > 0
  do return bResult end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

TowerDefenseData.GetLockCharacterAndItem = function(self, levelId)
  -- function num : 0_36 , upvalues : _ENV
  local characterList = {}
  local itemId = 0
  local levelConfig = (ConfigTable.GetData)("TowerDefenseLevel", levelId)
  if levelConfig == nil then
    return characterList, itemId
  end
  local floorConfig = (ConfigTable.GetData)("TowerDefenseFloor", levelConfig.FloorId)
  if floorConfig == nil then
    return characterList, itemId
  end
  if not floorConfig.TeamGroup then
    characterList = {}
  end
  itemId = floorConfig.ItemID
  return characterList, itemId
end

TowerDefenseData.RefreshRedDot = function(self)
  -- function num : 0_37 , upvalues : _ENV, RedDotManager
  if not self:GetPlayState() then
    return 
  end
  local bReddot = false
  for _,levelData in pairs(self.allLevelData) do
    if self:IsLevelUnlock(levelData.nLevelId) then
      if not bReddot then
        bReddot = self:GetlevelIsNew(levelData.nLevelId)
      end
      if bReddot then
        (RedDotManager.SetValid)(RedDotDefine.Activity_Tab, self.nActId, bReddot)
        return 
      end
    end
  end
  for _,questGroupData in pairs(self.allQuestData) do
    for _,questData in pairs(questGroupData) do
      bReddot = bReddot or questData.nState == (AllEnum.ActQuestStatus).Complete
      if bReddot then
        (RedDotManager.SetValid)(RedDotDefine.Activity_Tab, self.nActId, bReddot)
        return 
      end
    end
  end
  for _,storyData in pairs(self.allStoryData) do
    if not bReddot then
      bReddot = self:GetStoryIsNew(storyData.nId)
    end
    if bReddot then
      (RedDotManager.SetValid)(RedDotDefine.Activity_Tab, self.nActId, bReddot)
      return 
    end
  end
  ;
  (RedDotManager.SetValid)(RedDotDefine.Activity_Tab, self.nActId, bReddot)
  -- DECOMPILER ERROR: 6 unprocessed JMP targets
end

TowerDefenseData.RequestEnterLevel = function(self, levelId, characterList, itemId, callback)
  -- function num : 0_38 , upvalues : _ENV
  local mapMsg = {Level = levelId, Characters = characterList, ItemId = itemId}
  local cb = function()
    -- function num : 0_38_0 , upvalues : callback, self, levelId
    if callback ~= nil then
      callback()
    end
    local result = {action = 1, nActId = self.nActId, nlevelId = levelId, nStar = 0, nHp = 0, bIsFirstPass = false}
    self:EventUpload(result)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_tower_defense_level_apply_req, mapMsg, nil, cb)
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R7 in 'UnsetPending'

  ;
  (self.TempLevelTeamData)[levelId] = {charList = clone(characterList), itemId = itemId}
end

TowerDefenseData.RequestFinishLevel = function(self, levelId, bResult, nHp, cb)
  -- function num : 0_39 , upvalues : _ENV
  local levelData = self:GetLevelData(levelId)
  do
    if not bResult then
      local mapMsg = {LevelId = levelId, Star = 0}
      ;
      (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_tower_defense_level_settle_req, mapMsg, nil, function()
    -- function num : 0_39_0 , upvalues : cb, levelData, self, levelId
    if cb ~= nil then
      cb(levelData.nStar, levelData.nStar)
    end
    local result = {action = 5, nActId = self.nActId, nlevelId = levelId, nStar = 0, nHp = 0, bIsFirstPass = false}
    self:EventUpload(result)
  end
)
      return 
    end
    local nStar = 1
    local config = (ConfigTable.GetData)("TowerDefenseLevel", levelId)
    if config.Condition2 < nHp then
      nStar = nStar + 1
    end
    if config.Condition3 < nHp then
      nStar = nStar + 1
    end
    local mapMsg = {LevelId = levelId, Star = nStar}
    local oldStar = levelData.nStar
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_tower_defense_level_settle_req, mapMsg, nil, function(_, mapMsgData)
    -- function num : 0_39_1 , upvalues : cb, nStar, levelData, self, levelId, _ENV, nHp, oldStar
    cb(nStar, levelData.nStar, mapMsgData)
    self:UpdateLevelData({Id = levelId, Star = (math.max)(nStar, levelData.nStar)})
    local result = {action = 2, nActId = self.nActId, nlevelId = levelId, nStar = nStar, nHp = nHp}
    if oldStar == 0 and levelData.nStar > 0 then
      result.bIsFirstPass = true
    else
      result.bIsFirstPass = false
    end
    self:EventUpload(result)
  end
)
  end
end

TowerDefenseData.EventUpload = function(self, result)
  -- function num : 0_40 , upvalues : _ENV
  local tabUpLevel = {}
  ;
  (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (table.insert)(tabUpLevel, {"action", tostring(result.action)})
  ;
  (table.insert)(tabUpLevel, {"activity_id", tostring(result.nActId)})
  ;
  (table.insert)(tabUpLevel, {"battle_id", tostring(result.nlevelId)})
  ;
  (table.insert)(tabUpLevel, {"first_clear", tostring(result.bIsFirstPass and 1 or 0)})
  ;
  (table.insert)(tabUpLevel, {"result_star", tostring(result.nStar)})
  ;
  (table.insert)(tabUpLevel, {"hp_result", tostring(result.nHp)})
  ;
  (NovaAPI.UserEventUpload)("activity_tower_defense", tabUpLevel)
end

TowerDefenseData.RequestReadAVG = function(self, storyId)
  -- function num : 0_41 , upvalues : _ENV
  local mapMsg = {Value = storyId}
  local cb = function(_, mapMsgData)
    -- function num : 0_41_0 , upvalues : storyId, self, _ENV
    local data = {nId = storyId, bIsRead = true}
    self:UpdateStoryData(data)
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
    ;
    (UTILS.OpenReceiveByDisplayItem)(mapDecodedChangeInfo["proto.Res"], mapMsgData)
    self:RefreshRedDot()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_tower_defense_story_reward_receive_req, mapMsg, nil, cb)
end

TowerDefenseData.RequestReceiveQuest = function(self, nGroupId, nQuestId)
  -- function num : 0_42 , upvalues : _ENV
  local mapMsg = {ActivityId = self.nActId, GroupId = nQuestId == 0 and nGroupId or 0, QuestId = nQuestId}
  local cb = function(_, mapMsgData)
    -- function num : 0_42_0 , upvalues : nQuestId, self, nGroupId, _ENV
    if nQuestId == 0 then
      local quests = self:GetQuestbyGroupId(nGroupId)
      for _,quest in pairs(quests) do
        if quest.nState == (AllEnum.ActQuestStatus).Complete then
          local config = (ConfigTable.GetData)("TowerDefenseQuest", quest.nId)
          local progress = {}
          local progressData = {}
          if config.QuestType == (GameEnum.towerDefenseCond).TowerDefenseClear then
            progressData.Cur = 1
            progressData.Max = 1
          else
            if config.QuestType == (GameEnum.towerDefenseCond).TowerDefenseClearSpecificStar then
              progressData.Cur = 1
              progressData.Max = 1
            else
              progressData.Cur = (config.QuestParam)[2]
              progressData.Max = (config.QuestParam)[2]
            end
          end
          ;
          (table.insert)(progress, progressData)
          local data = {nId = quest.nId, nState = (AllEnum.ActQuestStatus).Received, progress = progress}
          self:UpdateQuest(data)
        end
      end
    else
      do
        local config = (ConfigTable.GetData)("TowerDefenseQuest", nQuestId)
        local progress = {}
        local progressData = {}
        if config.QuestType == (GameEnum.towerDefenseCond).TowerDefenseClear then
          progressData.Cur = 1
          progressData.Max = 1
        else
          if config.QuestType == (GameEnum.towerDefenseCond).TowerDefenseClearSpecificStar then
            progressData.Cur = 1
            progressData.Max = 1
          else
            progressData.Cur = (config.QuestParam)[2]
            progressData.Max = (config.QuestParam)[2]
          end
        end
        ;
        (table.insert)(progress, progressData)
        do
          local data = {nId = nQuestId, nState = (AllEnum.ActQuestStatus).Received, progress = progress}
          self:UpdateQuest(data)
          self:RefreshRedDot()
          ;
          (UTILS.OpenReceiveByChangeInfo)(mapMsgData)
          ;
          (EventManager.Hit)("TowerDefenseQuestReceived")
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_tower_defense_quest_reward_receive_req, mapMsg, nil, cb)
end

return TowerDefenseData

