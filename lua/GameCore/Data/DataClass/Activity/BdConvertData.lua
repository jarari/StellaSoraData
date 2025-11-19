local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local BdConvertData = class("BdConvertData", ActivityDataBase)
local LocalData = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
local RedDotManager = require("GameCore.RedDot.RedDotManager")
local ClientManager = (CS.ClientManager).Instance
BdConvertData.Init = function(self)
  -- function num : 0_0
  self:InitData()
  self:AddListeners()
end

BdConvertData.InitData = function(self)
  -- function num : 0_1
  self.allQuestData = {}
  self.bdCfgData = nil
  self.tbBdData = {}
  self.AllBuild = {}
  self:InitBuildRank()
end

BdConvertData.UpdateStatus = function(self)
  -- function num : 0_2
end

BdConvertData.AddListeners = function(self)
  -- function num : 0_3
end

BdConvertData.GetActConfig = function(self)
  -- function num : 0_4 , upvalues : _ENV
  self.actCfgData = (ConfigTable.GetData)("BdConvertControl", self.nActId)
  return self.actCfgData
end

BdConvertData.GetBdConvertConfig = function(self)
  -- function num : 0_5
  return self.bdCfgData
end

BdConvertData.CreateBuildData = function(self, mapBuildMsg)
  -- function num : 0_6 , upvalues : _ENV
  if (self.AllBuild)[mapBuildMsg.Id] ~= nil then
    printLog((string.format)("编队信息重复！！！id= [%s]", mapBuildMsg.Id))
  end
  local mapBuildData = {nBuildId = (mapBuildMsg.Brief).Id, sName = (mapBuildMsg.Brief).Name, 
tbChar = {}
, nScore = (mapBuildMsg.Brief).Score, mapRank = self:CalBuildRank((mapBuildMsg.Brief).Score), bLock = (mapBuildMsg.Brief).Lock, bPreference = (mapBuildMsg.Brief).Preference, bDetail = false, tbDisc = (mapBuildMsg.Brief).DiscIds, tbSecondarySkill = (mapBuildMsg.Detail).ActiveSecondaryIds, 
tbPotentials = {}
, 
tbNotes = {}
, nTowerId = (mapBuildMsg.Brief).StarTowerId}
  for i = 1, 3 do
    (table.insert)(mapBuildData.tbChar, {nTid = (((mapBuildMsg.Brief).Chars)[i]).CharId, nPotentialCount = (((mapBuildMsg.Brief).Chars)[i]).PotentialCnt})
  end
  mapBuildData.tbDisc = (mapBuildMsg.Brief).DiscIds
  -- DECOMPILER ERROR at PC75: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.AllBuild)[(mapBuildMsg.Brief).Id] = mapBuildData
  for _,v in ipairs((mapBuildMsg.Detail).Potentials) do
    local potentialCfg = (ConfigTable.GetData)("Potential", v.PotentialId)
    if potentialCfg then
      local nCharId = potentialCfg.CharId
      -- DECOMPILER ERROR at PC103: Confused about usage of register: R10 in 'UnsetPending'

      if (((self.AllBuild)[(mapBuildMsg.Brief).Id]).tbPotentials)[nCharId] == nil then
        (((self.AllBuild)[(mapBuildMsg.Brief).Id]).tbPotentials)[nCharId] = {}
      end
      ;
      (table.insert)((((self.AllBuild)[(mapBuildMsg.Brief).Id]).tbPotentials)[nCharId], {nPotentialId = v.PotentialId, nLevel = v.Level})
    end
  end
  local tbNotes = {}
  for _,v in pairs((mapBuildMsg.Detail).SubNoteSkills) do
    tbNotes[v.Tid] = v.Qty
  end
  -- DECOMPILER ERROR at PC135: Confused about usage of register: R4 in 'UnsetPending'

  ;
  ((self.AllBuild)[(mapBuildMsg.Brief).Id]).tbNotes = tbNotes
  -- DECOMPILER ERROR at PC140: Confused about usage of register: R4 in 'UnsetPending'

  ;
  ((self.AllBuild)[(mapBuildMsg.Brief).Id]).bDetail = true
end

BdConvertData.CalBuildRank = function(self, nScore)
  -- function num : 0_7 , upvalues : _ENV
  local nMin = 1
  local nMax = self._nBuildRankCount
  local mapRank = (self._tbBuildRank)[1]
  while 1 do
    while 1 do
      while 1 do
        if nMin <= nMax then
          local nMiddle = (math.floor)((nMin + nMax) / 2)
          if nMiddle == self._nBuildRankCount or ((self._tbBuildRank)[nMiddle]).MinGrade <= nScore and nScore < ((self._tbBuildRank)[nMiddle + 1]).MinGrade then
            mapRank = (self._tbBuildRank)[nMiddle]
            -- DECOMPILER ERROR at PC28: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC28: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC28: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC28: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
      if nScore < ((self._tbBuildRank)[nMiddle]).MinGrade then
        nMax = nMiddle - 1
        -- DECOMPILER ERROR at PC35: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC35: LeaveBlock: unexpected jumping out IF_STMT

      end
    end
    nMin = nMiddle + 1
  end
  do
    return mapRank
  end
end

BdConvertData.InitBuildRank = function(self)
  -- function num : 0_8 , upvalues : _ENV
  self._tbBuildRank = {}
  local foreach = function(line)
    -- function num : 0_8_0 , upvalues : self
    -- DECOMPILER ERROR at PC2: Confused about usage of register: R1 in 'UnsetPending'

    (self._tbBuildRank)[line.Id] = line
  end

  ForEachTableLine(DataTable.StarTowerBuildRank, foreach)
  self._nBuildRankCount = #self._tbBuildRank
end

BdConvertData.GetAllBuildByOpId = function(self, nOptionId)
  -- function num : 0_9 , upvalues : _ENV
  local contentCfg = (ConfigTable.GetData)("BdConvertContent", nOptionId)
  if contentCfg == nil then
    return nil
  end
  local tbBuild = {}
  for _,mapData in pairs(self.AllBuild) do
    local bResult = true
    for _,conditionId in ipairs(contentCfg.ConvertConditionList) do
      local bPass = self:CheckBuildData(mapData, conditionId)
      if not bPass then
        bResult = false
        break
      end
    end
    do
      do
        if bResult then
          (table.insert)(tbBuild, mapData)
        end
        -- DECOMPILER ERROR at PC36: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
  return tbBuild
end

BdConvertData.CheckBuildData = function(self, mapData, nCondId)
  -- function num : 0_10 , upvalues : _ENV
  local condiCfg = (ConfigTable.GetData)("BdConvertCondition", nCondId)
  if condiCfg == nil then
    return false
  end
  local bResult = false
  local nBdRequest = condiCfg.Cond
  if (condiCfg.CondParams)[1] > mapData.nScore then
    bResult = nBdRequest ~= (GameEnum.BdRequest).BdMaxLevel
    if nBdRequest == (GameEnum.BdRequest).BdNoteAllKindNum then
      local nNoteCount = 0
      if mapData.tbNotes ~= nil then
        for _,value in pairs(mapData.tbNotes) do
          nNoteCount = nNoteCount + value
        end
      end
      bResult = (condiCfg.CondParams)[1] <= nNoteCount
    else
      -- DECOMPILER ERROR at PC57: Unhandled construct in 'MakeBoolean' P1

      if nBdRequest == (GameEnum.BdRequest).BdNoteOneKindNum and mapData.tbNotes ~= nil then
        local noteId = (condiCfg.CondParams)[1]
        local noteCount = (mapData.tbNotes)[noteId] or 0
        bResult = (condiCfg.CondParams)[2] <= noteCount
      end
    end
    do
      -- DECOMPILER ERROR at PC78: Unhandled construct in 'MakeBoolean' P1

      if nBdRequest == (GameEnum.BdRequest).BdPotentialNum and mapData.tbChar ~= nil then
        local nPotentialCount = 0
        for _,value in ipairs(mapData.tbChar) do
          nPotentialCount = nPotentialCount + value.nPotentialCount
        end
        bResult = (condiCfg.CondParams)[1] <= nPotentialCount
      end
      do
        -- DECOMPILER ERROR at PC102: Unhandled construct in 'MakeBoolean' P1

        if nBdRequest == (GameEnum.BdRequest).BdPotentialLevelNum and mapData.tbPotentials ~= nil then
          local nPotentialCount = 0
          for _,charData in pairs(mapData.tbPotentials) do
            for _,value in ipairs(charData) do
              if (condiCfg.CondParams)[2] <= value.nLevel then
                nPotentialCount = nPotentialCount + 1
              end
            end
          end
          bResult = (condiCfg.CondParams)[1] <= nPotentialCount
        end
        -- DECOMPILER ERROR at PC138: Unhandled construct in 'MakeBoolean' P1

        if nBdRequest == (GameEnum.BdRequest).BdMainCharElementNum and mapData.tbChar ~= nil then
          local mainCharId = ((mapData.tbChar)[1]).nTid
          local charCfg = (ConfigTable.GetData)("Character", mainCharId)
          if charCfg.EET ~= (condiCfg.CondParams)[1] then
            do
              bResult = charCfg == nil
              do
                -- DECOMPILER ERROR at PC162: Unhandled construct in 'MakeBoolean' P1

                if nBdRequest == (GameEnum.BdRequest).BdCharElementNum and mapData.tbChar ~= nil then
                  local nCount = 0
                  for _,charData in ipairs(mapData.tbChar) do
                    local charCfg = (ConfigTable.GetData)("Character", charData.nTid)
                    if charCfg ~= nil and charCfg.EET == (condiCfg.CondParams)[2] then
                      nCount = nCount + 1
                    end
                  end
                  bResult = (condiCfg.CondParams)[1] <= nCount
                end
                do
                  -- DECOMPILER ERROR at PC197: Unhandled construct in 'MakeBoolean' P1

                  if nBdRequest == (GameEnum.BdRequest).BdCharJobNum and mapData.tbChar ~= nil then
                    local nCount = 0
                    for _,charData in ipairs(mapData.tbChar) do
                      local charCfg = (ConfigTable.GetData)("Character", charData.nTid)
                      if charCfg ~= nil and charCfg.Class == (condiCfg.CondParams)[2] then
                        nCount = nCount + 1
                      end
                    end
                    bResult = (condiCfg.CondParams)[1] <= nCount
                  end
                  do
                    if nBdRequest == (GameEnum.BdRequest).BdActivateSkillLevelNum and mapData.tbSecondarySkill ~= nil then
                      local nCount = 0
                      for _,skillId in ipairs(mapData.tbSecondarySkill) do
                        local skillCfg = (ConfigTable.GetData)("SecondarySkill", skillId)
                        if skillCfg ~= nil and (condiCfg.CondParams)[2] <= skillCfg.Level then
                          nCount = nCount + 1
                        end
                      end
                      bResult = (condiCfg.CondParams)[1] <= nCount
                    end
                    do return bResult end
                    -- DECOMPILER ERROR: 27 unprocessed JMP targets
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

BdConvertData.ChangeBuildLock = function(self, nBuildId, bLock, callback)
  -- function num : 0_11
  self:RequestChangeBuildLock(nBuildId, bLock, callback)
end

BdConvertData.RefreshBdConvertData = function(self, actId, msgData)
  -- function num : 0_12 , upvalues : _ENV
  self:InitData()
  self.nActId = actId
  self.bdCfgData = (ConfigTable.GetData)("BdConvert", self.nActId)
  for _,optionId in ipairs((self.bdCfgData).OptionList) do
    local optionData = (ConfigTable.GetData)("BdConvertContent", optionId)
    if optionData ~= nil then
      self:UpdateBdData({nId = optionId, nCurSub = 0, nMaxSub = optionData.MaxSub, bIsOpen = true})
    end
  end
  for _,contentData in ipairs(msgData.Contents) do
    local optionData = (ConfigTable.GetData)("BdConvertContent", contentData.Id)
    if optionData ~= nil then
      self:UpdateBdData({nId = contentData.Id, nCurSub = contentData.Num, nMaxSub = optionData.MaxSub, bIsOpen = true})
    end
  end
  local foreach_questTable = function(data)
    -- function num : 0_12_0 , upvalues : self, _ENV
    if data.GroupId == (self.bdCfgData).RewardGroup then
      self:UpdateQuest({nId = data.Id, nState = (AllEnum.ActQuestStatus).UnComplete, nCur = 0, nMax = (data.CompleteCondParams)[2]})
    end
  end

  ForEachTableLine(DataTable.BdConvertRewardGroup, foreach_questTable)
  local nCur = 0
  local nMax = 0
  for _,quest in pairs(msgData.Quests) do
    if self:QuestStateServer2Client(quest.Status) == (AllEnum.ActQuestStatus).UnComplete then
      nCur = ((quest.Progress)[1]).Cur
      nMax = ((quest.Progress)[1]).Max
    else
      local questCfg = (ConfigTable.GetData)("BdConvertRewardGroup", quest.Id)
      if questCfg ~= nil then
        do
          do
            nMax = (questCfg.CompleteCondParams)[2]
            nCur = nMax
            self:UpdateQuest({nId = quest.Id, nState = self:QuestStateServer2Client(quest.Status), nCur = nCur, nMax = nMax})
            -- DECOMPILER ERROR at PC102: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC102: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC102: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC102: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC102: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
  self:RefreshRedDot()
end

BdConvertData.GetBuildCount = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local nCount = 0
  for _,data in pairs(self.AllBuild) do
    if data ~= nil then
      nCount = nCount + 1
    end
  end
  return nCount
end

BdConvertData.CheckBuildsData = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local bResult = false
  if not (PlayerData.Build):CheckHasBuild() then
    bResult = true
  else
    local callback = function(tbBuildId, _)
    -- function num : 0_14_0 , upvalues : self, bResult, _ENV
    if #tbBuildId ~= self:GetBuildCount() then
      bResult = false
    else
      for _,buildId in ipairs(tbBuildId) do
        if (self.AllBuild)[buildId] == nil then
          bResult = false
          break
        end
      end
    end
  end

    ;
    (PlayerData.Build):GetAllBuildBriefData(callback)
  end
  do
    return bResult
  end
end

BdConvertData.UpdateBdData = function(self, bdData)
  -- function num : 0_15
  -- DECOMPILER ERROR at PC2: Confused about usage of register: R2 in 'UnsetPending'

  (self.tbBdData)[bdData.nId] = bdData
end

BdConvertData.GetAllBdData = function(self)
  -- function num : 0_16
  return self.tbBdData
end

BdConvertData.GetBdDataBy = function(self, id)
  -- function num : 0_17
  return (self.tbBdData)[id]
end

BdConvertData.SubmitBuild = function(self, mapDataList)
  -- function num : 0_18
end

BdConvertData.UpdateQuest = function(self, questData)
  -- function num : 0_19 , upvalues : _ENV, RedDotManager
  local questConfig = (ConfigTable.GetData)("BdConvertRewardGroup", questData.nId)
  if questConfig == nil then
    return 
  end
  if self.allQuestData == nil then
    self.allQuestData = {}
  end
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.allQuestData)[questData.nId] = questData
  ;
  (RedDotManager.SetValid)(RedDotDefine.Activity_BdConvert_Quest, questData.nId, questData.nState == (AllEnum.ActQuestStatus).Complete)
  ;
  (EventManager.Hit)("BdConvertQuestUpdate")
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

BdConvertData.GetAllQuestCount = function(self)
  -- function num : 0_20 , upvalues : _ENV
  local nResult = 0
  for _,_ in pairs(self.allQuestData) do
    nResult = nResult + 1
  end
  return nResult
end

BdConvertData.GetAllReceivedCount = function(self)
  -- function num : 0_21 , upvalues : _ENV
  local nResult = 0
  for _,quest in pairs(self.allQuestData) do
    if quest.nState == (AllEnum.ActQuestStatus).Received then
      nResult = nResult + 1
    end
  end
  return nResult
end

BdConvertData.GetQuestIdList = function(self)
  -- function num : 0_22 , upvalues : _ENV
  local questIdList = {}
  for _,data in pairs(self.allQuestData) do
    (table.insert)(questIdList, data.nId)
  end
  local sortFunc = function(a, b)
    -- function num : 0_22_0 , upvalues : self
    local aData = self:GetQuestDataById(a)
    local bData = self:GetQuestDataById(b)
    if aData.nState >= bData.nState then
      do return aData == nil or bData == nil or aData.nState == bData.nState end
      do return a < b end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end

  ;
  (table.sort)(questIdList, sortFunc)
  return questIdList
end

BdConvertData.GetQuestDataById = function(self, nId)
  -- function num : 0_23
  return (self.allQuestData)[nId]
end

BdConvertData.GetScore = function(self)
  -- function num : 0_24 , upvalues : _ENV
  local nItemId = (self.bdCfgData).ScoreItemId
  return (PlayerData.Item):GetItemCountByID(nItemId)
end

BdConvertData.QuestStateServer2Client = function(self, nStatus)
  -- function num : 0_25 , upvalues : _ENV
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

BdConvertData.RefreshQuestData = function(self, questData)
  -- function num : 0_26 , upvalues : _ENV
  local nCur = 0
  local nMax = 0
  if self:QuestStateServer2Client(questData.Status) == (AllEnum.ActQuestStatus).UnComplete then
    nCur = ((questData.Progress)[1]).Cur
    nMax = ((questData.Progress)[1]).Max
  else
    local questCfg = (ConfigTable.GetData)("BdConvertRewardGroup", questData.Id)
    if questCfg == nil then
      return 
    end
    nMax = (questCfg.CompleteCondParams)[2]
    nCur = nMax
  end
  do
    self:UpdateQuest({nId = questData.Id, nState = self:QuestStateServer2Client(questData.Status), nCur = nCur, nMax = nMax})
    self:RefreshRedDot()
  end
end

BdConvertData.CheckHasComQuest = function(self)
  -- function num : 0_27 , upvalues : _ENV
  local bHasCompleteQuest = false
  for _,questData in pairs(self.allQuestData) do
    if questData.nState == (AllEnum.ActQuestStatus).Complete then
      bHasCompleteQuest = true
      break
    end
  end
  do
    return bHasCompleteQuest
  end
end

BdConvertData.RefreshRedDot = function(self)
  -- function num : 0_28 , upvalues : _ENV, RedDotManager
  if not self:GetPlayState() then
    return 
  end
  local bReddot = false
  for _,questData in pairs(self.allQuestData) do
    bReddot = bReddot or questData.nState == (AllEnum.ActQuestStatus).Complete
    if bReddot then
      (RedDotManager.SetValid)(RedDotDefine.Activity_Tab, self.nActId, bReddot)
      return 
    end
  end
  ;
  (RedDotManager.SetValid)(RedDotDefine.Activity_Tab, self.nActId, false)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

BdConvertData.RequestReceiveQuest = function(self, callback)
  -- function num : 0_29 , upvalues : _ENV
  local bHasCompleteQuest = self:CheckHasComQuest()
  if not bHasCompleteQuest then
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("BdConvert_NoComQuest"))
    return 
  end
  local mapMsg = {Value = self.nActId}
  local cb = function(_, mapMsgData)
    -- function num : 0_29_0 , upvalues : _ENV, self, callback
    for _,questId in pairs(mapMsgData.Ids) do
      local config = (ConfigTable.GetData)("BdConvertRewardGroup", questId)
      if config ~= nil then
        local data = {nId = questId, nState = (AllEnum.ActQuestStatus).Received, nCur = (config.CompleteCondParams)[2], nMax = (config.CompleteCondParams)[2]}
        self:UpdateQuest(data)
      end
    end
    self:RefreshRedDot()
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapMsgData.Change)
    if callback ~= nil then
      callback()
    end
    ;
    (EventManager.Hit)("BdConvertQuestReceived")
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).build_convert_group_reward_receive_req, mapMsg, nil, cb)
end

BdConvertData.RequestSubmitBuild = function(self, nContentId, tbBuildId)
  -- function num : 0_30 , upvalues : _ENV
  local mapMsg = {ActivityId = self.nActId, BuildIds = tbBuildId, ContentId = nContentId}
  local cb = function(_, mapMsgData)
    -- function num : 0_30_0 , upvalues : _ENV, tbBuildId, self, nContentId
    for _,buildId in ipairs(tbBuildId) do
      -- DECOMPILER ERROR at PC5: Confused about usage of register: R7 in 'UnsetPending'

      (self.AllBuild)[buildId] = nil
    end
    ;
    (PlayerData.Build):DeleteBuildByActivity(tbBuildId)
    local optionData = (ConfigTable.GetData)("BdConvertContent", nContentId)
    if optionData ~= nil then
      self:UpdateBdData({nId = nContentId, nCurSub = mapMsgData.Number, nMaxSub = optionData.MaxSub, bIsOpen = true})
    end
    if mapMsgData.AwardItems ~= nil then
      local tbReward = {}
      for _,reward in ipairs(mapMsgData.AwardItems) do
        (table.insert)(tbReward, {id = reward.Tid, rewardType = (AllEnum.RewardType).Three, count = reward.Qty, nHasCount = (PlayerData.Item):GetItemCountByID(reward.Tid)})
      end
      ;
      (EventManager.Hit)("BdConvert_ShowReward", mapMsgData.AwardItems, optionData.Icon)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).build_convert_submit_req, mapMsg, nil, cb)
end

BdConvertData.RequestAllBuildData = function(self, callback)
  -- function num : 0_31 , upvalues : _ENV
  local mapMsg = {}
  local cb = function(_, mapMsgData)
    -- function num : 0_31_0 , upvalues : self, _ENV, callback
    self.AllBuild = {}
    for _,buildData in pairs(mapMsgData.Details) do
      self:CreateBuildData(buildData)
    end
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).build_convert_detail_list_get_req, mapMsg, nil, cb)
end

BdConvertData.RequestChangeBuildLock = function(self, nBuildId, bLock, callback)
  -- function num : 0_32 , upvalues : _ENV
  local msg = {BuildId = nBuildId, Lock = bLock}
  local callBack = function()
    -- function num : 0_32_0 , upvalues : self, nBuildId, bLock, callback
    -- DECOMPILER ERROR at PC4: Confused about usage of register: R0 in 'UnsetPending'

    ((self.AllBuild)[nBuildId]).bLock = bLock
    if callback ~= nil then
      callback()
    end
  end

  if (PlayerData.Build):CheckHasBuild() then
    (PlayerData.Build):ChangeBuildLock(nBuildId, bLock, callBack)
  else
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_build_lock_unlock_req, msg, nil, callBack)
  end
end

return BdConvertData

