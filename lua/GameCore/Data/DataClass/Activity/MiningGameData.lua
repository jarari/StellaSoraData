local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local LocalData = require("GameCore.Data.LocalData")
local MiningGameData = class("MiningGameData", ActivityDataBase)
MiningGameData.Init = function(self)
  -- function num : 0_0
  self.tbQuestDataList = {}
  self.bIsFirst = true
  self.nScore = 0
  self.tbGridDataList = {}
  self.nCurLevel = 0
  self.tbCurReward = {}
  self.bCanGoNext = false
  self.tbSupList = {}
  self.nAddAxeCount_Daliy = 0
  self.nAddAxeCount_LongTime = 0
  self.tbConfig = {}
  self.nConfigId = 0
  self.tbCurDicGroupId = {}
  self.tbCurStoryGroupData = {}
  self.tbCurStoryListData = {}
  self.nAxeId = 0
  self:AddListeners()
end

MiningGameData.AddListeners = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  ;
  (EventManager.Add)("Mining_Daily_Reward", self, self.On_DailyReward_Update)
  ;
  (EventManager.Add)("Mining_Supplement_Reward", self, self.On_SupplementReward_Update)
  ;
  (EventManager.Add)("Mining_UpdateLevelData", self, self.OnEvent_Mining_UpdateLevelData)
  ;
  (EventManager.Add)("Mining_UpdateRigResult", self, self.OnEvent_Mining_UpdateDigResult)
end

MiningGameData.OnEvent_NewDay = function(self)
  -- function num : 0_2
  self.nAddAxeCount = 0
end

MiningGameData.CacheAllQuestData = function(self, questListData)
  -- function num : 0_3 , upvalues : _ENV
  self.tbQuestDataList = {}
  for _,v in pairs(questListData) do
    local questData = {nId = v.Id, nStatus = self:QuestServer2Client(v.Status), progress = v.Progress}
    ;
    (table.insert)(self.tbQuestDataList, questData)
  end
  self:RefreshQuestReddot()
end

MiningGameData.GetAllQuestData = function(self)
  -- function num : 0_4
  return self.tbQuestDataList
end

MiningGameData.GetQuestData = function(self, nQuestId)
  -- function num : 0_5 , upvalues : _ENV
  local questData = nil
  for _,v in pairs(self.tbQuestDataList) do
    if v.nId == nQuestId then
      questData = v
    end
  end
  return questData
end

MiningGameData.GetCompleteCount = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local nCount = 0
  for _,v in pairs(self.tbQuestDataList) do
    if v.nStatus == (AllEnum.ActQuestStatus).Complete or v.nStatus == (AllEnum.ActQuestStatus).Received then
      nCount = nCount + 1
    end
  end
  return nCount
end

MiningGameData.RefreshQuestData = function(self, questData)
  -- function num : 0_7
end

MiningGameData.RefreshQuestReddot = function(self)
  -- function num : 0_8 , upvalues : _ENV
  local bTabReddot = false
  if next(self.tbQuestDataList) ~= nil then
    for _,v in pairs(self.tbQuestDataList) do
      local bReddot = v.nStatus == (AllEnum.ActQuestStatus).Complete
      ;
      (RedDotManager.SetValid)(RedDotDefine.Activity_Mining_Quest, v.nId, bReddot)
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

MiningGameData.HasFinishQuest = function(self, ...)
  -- function num : 0_9 , upvalues : _ENV
  local bHasFinish = false
  for _,v in pairs(self.tbQuestDataList) do
    if v.nStatus == (AllEnum.ActQuestStatus).Complete then
      bHasFinish = true
      break
    end
  end
  do
    return bHasFinish
  end
end

MiningGameData.QuestServer2Client = function(self, nStatus)
  -- function num : 0_10 , upvalues : _ENV
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

MiningGameData.InitCurDicData = function(self)
  -- function num : 0_11 , upvalues : _ENV
  local GetRewardsByGroupId = function(lineData)
    -- function num : 0_11_0 , upvalues : self, _ENV
    if lineData.ActivityId == self.nActId then
      (table.insert)(self.tbCurDicGroupId, lineData.Id)
    end
  end

  ForEachTableLine(DataTable.MiningTreasure, GetRewardsByGroupId)
end

MiningGameData.GetDicGroupId = function(self)
  -- function num : 0_12
  return self.tbCurDicGroupId
end

MiningGameData.InitStoryData = function(self, readStoryList)
  -- function num : 0_13 , upvalues : _ENV
  local GetRewardsByGroupId = function(lineData)
    -- function num : 0_13_0 , upvalues : self, _ENV, readStoryList
    if lineData.ActivityId == self.nActId then
      (table.insert)(self.tbCurStoryListData, {nId = lineData.Id, config = lineData})
      local isRead = function(id)
      -- function num : 0_13_0_0 , upvalues : _ENV, readStoryList
      for _,v in ipairs(readStoryList) do
        if v == id then
          return true
        end
      end
      return false
    end

      -- DECOMPILER ERROR at PC29: Confused about usage of register: R2 in 'UnsetPending'

      ;
      (self.tbCurStoryGroupData)[lineData.Id] = {self.nCurLevel < lineData.UnlockLayer; nId = lineData.Id, bIsRead = isRead(lineData.Id)}
    end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

  ForEachTableLine(DataTable.MiningStory, GetRewardsByGroupId)
  ;
  (table.sort)(self.tbCurStoryListData, function(a, b)
    -- function num : 0_13_1
    do return (a.config).UnlockLayer < (b.config).UnlockLayer end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
end

MiningGameData.GetGroupStoryData = function(self)
  -- function num : 0_14
  return self.tbCurStoryGroupData
end

MiningGameData.GetStoryConfigIdList = function(self)
  -- function num : 0_15
  return self.tbCurStoryListData
end

MiningGameData.UpdateStoryLockState = function(self, ...)
  -- function num : 0_16 , upvalues : _ENV
  for k,v in pairs(self.tbCurStoryGroupData) do
    if v.bIsLock then
      local config = (DataTable.GetData)("MiningStory", v.id)
      if config.UnlockLayer <= self.nCurLevel then
        v.bIsLock = false
      end
    end
  end
end

MiningGameData.ChangeStoryState = function(self, storyId)
  -- function num : 0_17
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbCurStoryGroupData)[storyId] ~= nil then
    ((self.tbCurStoryGroupData)[storyId]).bIsRead = true
  end
end

MiningGameData.GetSupDataList = function(self)
  -- function num : 0_18
  return self.tbSupList
end

MiningGameData.GetCellData = function(self)
  -- function num : 0_19
  return self.tbGridDataList
end

MiningGameData.RefreshMiningGameActData = function(self, actId, msgData)
  -- function num : 0_20 , upvalues : _ENV, LocalData
  self:Init()
  self.nActId = actId
  self.nCurLevel = msgData.Layer
  self.tbConfig = (ConfigTable.GetData)("MiningControl", self.nActId)
  self.nAxeId = (self.tbConfig).DigConsumeItemId
  local sKey = tostring(self.nActId) .. "IsFirst"
  self.bIsFirst = (LocalData.GetPlayerLocalData)(sKey)
  if self.bIsFirst == nil then
    self.bIsFirst = true
  end
  self:InitCurDicData()
  self.nScore = msgData.Score
end

MiningGameData.GetIsFirstIn = function(self)
  -- function num : 0_21
  return self.bIsFirst
end

MiningGameData.SetIsFirstIn = function(self)
  -- function num : 0_22 , upvalues : _ENV, LocalData
  self.bIsFirst = false
  local sKey = tostring(self.nActId) .. "IsFirst"
  ;
  (LocalData.SetPlayerLocalData)(sKey, self.bIsFirst)
end

MiningGameData.GetLevel = function(self, ...)
  -- function num : 0_23
  return self.nCurLevel
end

MiningGameData.GetCurLevelRewardData = function(self)
  -- function num : 0_24
  return self.tbCurReward
end

MiningGameData.GetCanGoNext = function(self, ...)
  -- function num : 0_25
  return self.bCanGoNext
end

MiningGameData.GetMiningCfg = function(self, ...)
  -- function num : 0_26 , upvalues : _ENV
  if not self.tbConfig then
    self.tbConfig = (ConfigTable.GetData)("MiningControl", self.nActId)
  end
  return self.tbConfig
end

MiningGameData.GetScore = function(self)
  -- function num : 0_27
  return self.nScore
end

MiningGameData.AddScore = function(self, addValue)
  -- function num : 0_28 , upvalues : _ENV
  self.nScore = self.nScore + addValue
  ;
  (EventManager.Hit)("MiningGameUpdateScore", self.nScore)
end

MiningGameData.ResponseLevelData = function(self, msgData, callback)
  -- function num : 0_29 , upvalues : _ENV
  local layer = msgData.Layer
  self.nCurLevel = layer.Layer
  self.nMapId = (layer.Map).Id
  self.tbGridDataList = {}
  for _,v in pairs((layer.Map).Grids) do
    local cellData = {nId = v.Id, nIndex = v.PosIndex + 1, nStatus = (GameEnum.miningGridType)[v.GridType], bMark = v.Marked}
    ;
    (table.insert)(self.tbGridDataList, v.PosIndex + 1, cellData)
  end
  self.tbCurlevelEnterChange = msgData.MiningChangeInfo
  self.tbCurReward = {}
  for _,v in pairs((layer.Map).Treasures) do
    local tbPosIndex = {}
    for _,n in pairs(v.PosIndex) do
      (table.insert)(tbPosIndex, n + 1)
    end
    local rewardData = {nId = v.Id, bIsGet = v.Received, tbPosIndex = tbPosIndex}
    ;
    (table.insert)(self.tbCurReward, rewardData)
  end
  self.tbSupList = {}
  for _,v in pairs(layer.Supports) do
    (table.insert)(self.tbSupList, {nId = v.Id})
  end
  ;
  (EventManager.Hit)("MiningUpdateLevel")
  if callback ~= nil then
    callback()
  end
end

MiningGameData.DoEnterResult = function(self)
  -- function num : 0_30
  self:DoResult(self.tbCurlevelEnterChange)
end

MiningGameData.DoResult = function(self, changeInfo)
  -- function num : 0_31 , upvalues : _ENV
  if changeInfo == nil then
    return 
  end
  local tbSkillData = {}
  for k,v in pairs(changeInfo.Processes) do
    local tbUpdateGrid = {}
    for _,m in pairs(v.EffectedGrids) do
      -- DECOMPILER ERROR at PC21: Confused about usage of register: R14 in 'UnsetPending'

      ((self.tbGridDataList)[m.PosIndex + 1]).nStatus = (GameEnum.miningGridType)[m.GridType]
      -- DECOMPILER ERROR at PC27: Confused about usage of register: R14 in 'UnsetPending'

      ;
      ((self.tbGridDataList)[m.PosIndex + 1]).bMark = m.Marked
      ;
      (table.insert)(tbUpdateGrid, {nIndex = m.PosIndex + 1, nStatus = (GameEnum.miningGridType)[m.GridType], bMark = m.Marked})
    end
    local skillData = {nEffectType = v.EffectType, tbUpdateGrid = tbUpdateGrid}
    ;
    (table.insert)(tbSkillData, skillData)
  end
  for k,v in pairs(changeInfo.ReceivedTreasures) do
    self:UpdateReward(v)
  end
  self:UpdateAxe()
  self:AddScore(changeInfo.Score)
  ;
  (EventManager.Hit)("MiningKnockResult", tbSkillData)
end

MiningGameData.UpdateReward = function(self, nId)
  -- function num : 0_32 , upvalues : _ENV
  for key,value in pairs(self.tbCurReward) do
    if nId == value.nId then
      value.bIsGet = true
    end
  end
  ;
  (EventManager.Hit)("MiningUpdateReward", nId)
end

MiningGameData.GetAxeId = function(self)
  -- function num : 0_33
  return self.nAxeId
end

MiningGameData.GetAxeCount = function(self, ...)
  -- function num : 0_34 , upvalues : _ENV
  return (PlayerData.Item):GetItemCountByID(self.nAxeId)
end

MiningGameData.UpdateAxe = function(self, ...)
  -- function num : 0_35 , upvalues : _ENV
  (EventManager.Hit)("MiningAxeUpdate", (PlayerData.Item):GetItemCountByID(self.nAxeId))
end

MiningGameData.GetPassAllLevelResult = function(self)
  -- function num : 0_36 , upvalues : _ENV
  local nMaxLevel = (self.tbConfig).ConfigMaxLayer
  if self.nCurLevel < nMaxLevel then
    return false
  end
  for _,data in pairs(self.tbCurReward) do
    if not data.bIsGet then
      return false
    end
  end
  return true
end

MiningGameData.On_DailyReward_Update = function(self, msgData)
  -- function num : 0_37 , upvalues : _ENV
  local tbItemList = (PlayerData.Item):ProcessRewardChangeInfo(msgData)
  for _,v in pairs(tbItemList) do
    if v.nId == self.nAxeId then
      self.nAddAxeCount_Daliy = v.nCount
      break
    end
  end
end

MiningGameData.On_SupplementReward_Update = function(self, msgData)
  -- function num : 0_38 , upvalues : _ENV
  local tbItemList = (PlayerData.Item):ProcessRewardChangeInfo(msgData)
  for _,v in pairs(tbItemList) do
    if v.nId == self.nAxeId then
      self.nAddAxeCount_LongTime = v.nCount
      break
    end
  end
end

MiningGameData.GetAddAxeCount = function(self)
  -- function num : 0_39
  return self.nAddAxeCount_Daliy + self.nAddAxeCount_LongTime
end

MiningGameData.ResetAddAxeCount = function(self)
  -- function num : 0_40
  self.nAddAxeCount_Daliy = 0
  self.nAddAxeCount_LongTime = 0
end

MiningGameData.OnEvent_Mining_UpdateLevelData = function(self, mapMsgData)
  -- function num : 0_41
  self:ResponseLevelData(mapMsgData)
end

MiningGameData.OnEvent_Mining_UpdateDigResult = function(self, mapMsgData)
  -- function num : 0_42
  self:DoResult(mapMsgData.MiningChangeInfo)
end

MiningGameData.RequestLevelData = function(self, nStatus, callback)
  -- function num : 0_43 , upvalues : _ENV
  if nStatus == 0 then
    local callbackFunc = function(_, msgData)
    -- function num : 0_43_0 , upvalues : self, callback
    self:ResponseLevelData(msgData, callback)
  end

    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_mining_apply_req, {ActivityId = self.nActId}, nil, callbackFunc)
  else
    do
      if nStatus == 1 then
        local callbackFunc = function(_, msgData)
    -- function num : 0_43_1 , upvalues : self
    self:ResponseLevelData(msgData)
  end

        ;
        (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_mining_move_to_next_layer_req, {ActivityId = self.nActId}, nil, callbackFunc)
      end
    end
  end
end

MiningGameData.RequestKnockCell = function(self, nId)
  -- function num : 0_44 , upvalues : _ENV
  local nAxeCount = (PlayerData.Item):GetItemCountByID(self.nAxeId)
  if nAxeCount <= 0 then
    return 
  end
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_mining_dig_req, {ActivityId = self.nActId, GridId = nId}, nil, nil)
end

MiningGameData.RequestFinishAvg = function(self, storyId, callback)
  -- function num : 0_45 , upvalues : _ENV
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_45_0 , upvalues : self, storyId, _ENV, callback
    self:ChangeStoryState(storyId)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.PureAvgStory)
    if callback ~= nil then
      callback(mapMsgData)
    end
    ;
    (EventManager.Hit)("MiningStoryFinish")
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_mining_story_reward_receive_req, {ActivityId = self.nActId, StoryId = storyId}, nil, msgCallback)
end

MiningGameData.SendQuestReceive = function(self, nQuestId)
  -- function num : 0_46 , upvalues : _ENV
  local callback = function(_, msgData)
    -- function num : 0_46_0 , upvalues : _ENV, nQuestId, self
    (UTILS.OpenReceiveByChangeInfo)(msgData.ChangeInfo, nil)
    if nQuestId == 0 then
      for _,v in pairs(self.tbQuestDataList) do
        if v.nStatus == (AllEnum.ActQuestStatus).Complete then
          v.nStatus = (AllEnum.ActQuestStatus).Received
        end
      end
    else
      do
        do
          local questData = self:GetQuestData(nQuestId)
          if questData then
            questData.nStatus = (AllEnum.ActQuestStatus).Received
          end
          ;
          (EventManager.Hit)("MiningQuestUpdate")
          self:RefreshQuestReddot()
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_mining_quest_reward_receive_req, {ActivityId = self.nActId, QuestId = nQuestId}, nil, callback)
end

return MiningGameData

