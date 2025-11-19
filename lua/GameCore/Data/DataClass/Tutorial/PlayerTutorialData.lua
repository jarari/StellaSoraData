local PlayerTutorialData = class("PlayerTutorialData")
local LevelData = require("GameCore.Data.DataClass.Tutorial.TutorialLevelData")
local LocalData = require("GameCore.Data.LocalData")
PlayerTutorialData.Init = function(self)
  -- function num : 0_0
  self.curLevelId = 0
  self.tbLevelData = {}
  self.LevelIdList = {}
end

PlayerTutorialData.CacheTutorialData = function(self, levelsData)
  -- function num : 0_1 , upvalues : _ENV, LevelData, LocalData
  local forEachTableFunc = function(config)
    -- function num : 0_1_0 , upvalues : self, _ENV
    self:UpdateLevel({nlevelId = config.Id, LevelStatus = (AllEnum.ActQuestStatus).UnComplete})
    ;
    (table.insert)(self.LevelIdList, config.Id)
  end

  ForEachTableLine(DataTable.TutorialLevel, forEachTableFunc)
  for _,level in pairs(levelsData) do
    self:UpdateLevel({nlevelId = level.LevelId, LevelStatus = self:QuestStateServer2Client(level.Passed, level.RewardReceived)})
  end
  local sortFunc = function(a, b)
    -- function num : 0_1_1
    do return a < b end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end

  ;
  (table.sort)(self.LevelIdList, sortFunc)
  self.LevelData = (LevelData.new)()
  local bIsNew = (LocalData.GetPlayerLocalData)("Tutorial_IsNew")
  if bIsNew == nil then
    bIsNew = true
  end
  local bAllComplate = true
  if self.tbLevelData ~= nil then
    for _,levelData in pairs(self.tbLevelData) do
      if levelData.LevelStatus ~= (AllEnum.ActQuestStatus).Received then
        bAllComplate = false
        break
      end
    end
  end
  do
    if bAllComplate then
      bIsNew = false
    end
    self:RefreshRedDot(bIsNew)
  end
end

PlayerTutorialData.GetLevelLockType = function(self, levelId)
  -- function num : 0_2 , upvalues : _ENV
  local levelData = self:GetLevelData(levelId)
  if levelData.LevelStatus == (AllEnum.ActQuestStatus).Complete or levelData.LevelStatus == (AllEnum.ActQuestStatus).Received then
    return (AllEnum.TutorialLevelLockType).None
  end
  local levelConfig = (ConfigTable.GetData)("TutorialLevel", levelId)
  if levelConfig == nil then
    return (AllEnum.TutorialLevelLockType).None
  end
  if (PlayerData.Base):GetWorldClass() < levelConfig.WorldClass then
    return (AllEnum.TutorialLevelLockType).WorldClass
  end
  local preLevelData = self:GetLevelData(levelConfig.PreLevelId)
  if preLevelData == nil then
    return (AllEnum.TutorialLevelLockType).None
  end
  if preLevelData.LevelStatus == (AllEnum.ActQuestStatus).UnComplete then
    return (AllEnum.TutorialLevelLockType).PreLevel
  end
  return (AllEnum.TutorialLevelLockType).None
end

PlayerTutorialData.GetLevelList = function(self)
  -- function num : 0_3
  return self.LevelIdList
end

PlayerTutorialData.UpdateLevel = function(self, levelData)
  -- function num : 0_4
  -- DECOMPILER ERROR at PC2: Confused about usage of register: R2 in 'UnsetPending'

  (self.tbLevelData)[levelData.nlevelId] = levelData
end

PlayerTutorialData.GetLevelData = function(self, levelId)
  -- function num : 0_5
  return (self.tbLevelData)[levelId]
end

PlayerTutorialData.GetProgress = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local nReceivedCount = 0
  for _,data in pairs(self.tbLevelData) do
    if data.LevelStatus == (AllEnum.ActQuestStatus).Received then
      nReceivedCount = nReceivedCount + 1
    end
  end
  return #self.LevelIdList, nReceivedCount
end

PlayerTutorialData.GetNextLevelId = function(self, levelId)
  -- function num : 0_7 , upvalues : _ENV
  local nNextlevelId = 0
  local nIndex = (table.indexof)(self.LevelIdList, levelId)
  if nIndex > 0 and nIndex + 1 <= #self.LevelIdList then
    for i = nIndex + 1, #self.LevelIdList do
      if self:GetLevelLockType((self.LevelIdList)[i]) == (AllEnum.TutorialLevelLockType).None then
        nNextlevelId = (self.LevelIdList)[i]
        break
      end
    end
  end
  do
    return nNextlevelId
  end
end

PlayerTutorialData.GetLevelReward = function(self, levelId)
  -- function num : 0_8 , upvalues : _ENV, LocalData
  local mapSendMsg = {Value = levelId}
  local succ_cb = function(_, mapData)
    -- function num : 0_8_0 , upvalues : self, levelId, _ENV, LocalData
    self:UpdateLevel({nlevelId = levelId, LevelStatus = (AllEnum.ActQuestStatus).Received})
    local bIsNew = (LocalData.GetPlayerLocalData)("Tutorial_IsNew")
    self:RefreshRedDot(bIsNew)
    ;
    (EventManager.Hit)(EventId.TutorialQuestReceived, mapData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).tutorial_level_reward_receive_req, mapSendMsg, nil, succ_cb)
end

PlayerTutorialData.EnterLevel = function(self, levelId, callback)
  -- function num : 0_9 , upvalues : _ENV
  self.curLevelId = levelId
  local levelConfig = (ConfigTable.GetData)("TutorialLevel", self.curLevelId)
  if levelConfig == nil then
    return 
  end
  local buildData = (ConfigTable.GetData)("TrialBuild", levelConfig.TutorialBuild)
  if buildData == nil then
    return 
  end
  local charIdList = {}
  local discIdList = {}
  for _,id in pairs(buildData.Char) do
    local charData = (ConfigTable.GetData)("TrialCharacter", id)
    if charData ~= nil then
      (table.insert)(charIdList, charData.CharId)
    end
  end
  for _,id in pairs(buildData.Disc) do
    local discData = (ConfigTable.GetData)("TrialDisc", id)
    if discData ~= nil then
      (table.insert)(discIdList, discData.DiscId)
    end
  end
  ;
  (self.LevelData):InitLevelData(self.curLevelId, charIdList, discIdList)
  if callback ~= nil then
    callback()
  end
end

PlayerTutorialData.FinishLevel = function(self, bResult)
  -- function num : 0_10 , upvalues : _ENV
  if not bResult then
    (self.LevelData):FinishLevel(false)
    self.curLevelId = 0
  else
    local levelData = self:GetLevelData(self.curLevelId)
    if levelData ~= nil then
      if levelData.LevelStatus == (AllEnum.ActQuestStatus).UnComplete then
        (self.LevelData):FinishLevel(true)
        local mapSendMsg = {Value = self.curLevelId}
        local func_cb = function()
    -- function num : 0_10_0 , upvalues : self, _ENV
    self:UpdateLevel({nlevelId = self.curLevelId, LevelStatus = (AllEnum.ActQuestStatus).Complete})
    self.curLevelId = 0
  end

        ;
        (HttpNetHandler.SendMsg)((NetMsgId.Id).tutorial_level_settle_req, mapSendMsg, nil, func_cb)
      else
        do
          ;
          (self.LevelData):FinishLevel(true)
          self.curLevelId = 0
        end
      end
    end
  end
end

PlayerTutorialData.GetCurDicId = function(self)
  -- function num : 0_11
  return (self.LevelData):GetCurDicId()
end

PlayerTutorialData.RefreshRedDot = function(self, bIsNew)
  -- function num : 0_12 , upvalues : _ENV, LocalData
  local bFuncUnlock = (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).TutorialLevel)
  if not bFuncUnlock then
    return 
  end
  ;
  (LocalData.SetPlayerLocalData)("Tutorial_IsNew", bIsNew)
  if bIsNew then
    (RedDotManager.SetValid)(RedDotDefine.Task_Tutorial, nil, true)
    return 
  end
  local bRedDot = false
  if self.tbLevelData ~= nil then
    for _,levelData in pairs(self.tbLevelData) do
      if levelData.LevelStatus == (AllEnum.ActQuestStatus).Complete then
        bRedDot = true
        break
      end
    end
  end
  do
    ;
    (RedDotManager.SetValid)(RedDotDefine.Task_Tutorial, nil, bRedDot)
  end
end

PlayerTutorialData.QuestStateServer2Client = function(self, Passed, RewardReceived)
  -- function num : 0_13 , upvalues : _ENV
  if not Passed then
    return (AllEnum.ActQuestStatus).UnComplete
  else
    if Passed and not RewardReceived then
      return (AllEnum.ActQuestStatus).Complete
    else
      return (AllEnum.ActQuestStatus).Received
    end
  end
end

return PlayerTutorialData

