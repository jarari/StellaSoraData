local RapidJson = require("rapidjson")
local ClientManager = CS.ClientManager
local PlayerMainlineDataEx = class("PlayerMainlineDataEx")
PlayerMainlineDataEx.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  (EventManager.Add)(EventId.SendMsgEnterBattle, self, self.OnEvent_EnterMainline)
  self._mapStar = {}
  self._mapChapters = {}
  self._nSelectId = 0
  self._tbCharId = nil
  self.nCurTeamIndex = 1
  self._mainlineData = nil
  self:ProcessMainlineData()
  self._mainlineLevel = nil
  self.bUseOldMainline = false
end

PlayerMainlineDataEx.CacheMainline = function(self, mapData, Chapters)
  -- function num : 0_1 , upvalues : _ENV
  for k,v in pairs(mapData) do
    local mapMainline = (ConfigTable.GetData_Mainline)(v.Id)
    if mapMainline ~= nil then
      local nChapterId = mapMainline.ChapterId
      -- DECOMPILER ERROR at PC17: Confused about usage of register: R10 in 'UnsetPending'

      if (self._mapStar)[nChapterId] == nil then
        (self._mapStar)[nChapterId] = {}
      end
      local b1 = 1
      local b2 = 2
      local b3 = 4
      local t1 = v.Star & b1 > 0
      local t2 = v.Star & b2 > 0
      local t3 = v.Star & b3 > 0
      local nStar = (self.CalStar)(v.Star)
      -- DECOMPILER ERROR at PC53: Confused about usage of register: R17 in 'UnsetPending'

      ;
      ((self._mapStar)[nChapterId])[v.Id] = {nStar = nStar, 
tbTarget = {t1, t2, t3}
}
    end
  end
  if Chapters ~= nil then
    for _,v in pairs(Chapters) do
      -- DECOMPILER ERROR at PC65: Confused about usage of register: R8 in 'UnsetPending'

      (self._mapChapters)[v.Id] = v.Idx
    end
  end
  self:UpdateRewardRedDot()
  -- DECOMPILER ERROR: 6 unprocessed JMP targets
end

PlayerMainlineDataEx.IsMainlineChapterUnlock = function(self, nChapterId)
  -- function num : 0_2 , upvalues : _ENV
  local mapMainlineData = (ConfigTable.GetData)("Chapter", nChapterId)
  if not self.bUseOldMainline then
    mapMainlineData = (ConfigTable.GetData)("StoryChapter", nChapterId)
  end
  if mapMainlineData == nil then
    return false
  end
  local nWorldClass = mapMainlineData.WorldClass
  local nCurWorldClass = (PlayerData.Base):GetWorldClass()
  if nCurWorldClass < nWorldClass then
    return false
  end
  local tbPrevId = nil
  if self.bUseOldMainline then
    tbPrevId = mapMainlineData.PrevMainlines
  else
    tbPrevId = mapMainlineData.PrevStories
  end
  for _,nPrevId in ipairs(tbPrevId) do
    local mapMainline = (ConfigTable.GetData_Mainline)(nPrevId)
    local nPrevIdChapter = mapMainline.ChapterId
    if (self._mapStar)[nPrevIdChapter] == nil or ((self._mapStar)[nPrevIdChapter])[nPrevId] == nil or (((self._mapStar)[nPrevIdChapter])[nPrevId]).nStar == 0 then
      return false
    end
  end
  return true
end

PlayerMainlineDataEx.IsMainlineLevelUnlock = function(self, nLevelId)
  -- function num : 0_3 , upvalues : _ENV
  local mapMainlineData = (ConfigTable.GetData_Mainline)(nLevelId)
  if mapMainlineData == nil then
    return false
  end
  local tbPrevId = mapMainlineData.Prev
  for __,nPrevId in ipairs(tbPrevId) do
    local mapMainline = (ConfigTable.GetData_Mainline)(nPrevId)
    if mapMainline == nil then
      return false
    end
    if (self._mapStar)[mapMainline.ChapterId] == nil or ((self._mapStar)[mapMainline.ChapterId])[nPrevId] == nil or (((self._mapStar)[mapMainline.ChapterId])[nPrevId]).nStar == 0 then
      return false
    end
  end
  do
    local bCoinUnlock = (self._mapStar)[mapMainlineData.ChapterId] ~= nil and ((self._mapStar)[mapMainlineData.ChapterId])[nLevelId] ~= nil
    do return true, bCoinUnlock end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
end

PlayerMainlineDataEx.GetChapterStars = function(self, nChapterId)
  -- function num : 0_4 , upvalues : _ENV
  local ret = 0
  local ret1 = 0
  if (self._mapStar)[nChapterId] == nil then
    return ret
  end
  for mainlinId,mapChapterStar in pairs((self._mapStar)[nChapterId]) do
    local mapData = (ConfigTable.GetData_Mainline)(mainlinId)
    local nStar = mapChapterStar.nStar
    if mapData.AvgId == "" then
      ret = ret + nStar
    end
    ret1 = ret1 + nStar
  end
  return ret, ret1
end

PlayerMainlineDataEx.GetChapterTotalStar = function(self, nChapterId)
  -- function num : 0_5 , upvalues : _ENV
  local ret = 0
  for _,_ in pairs((self._mainlineData)[nChapterId]) do
    ret = ret + 3
  end
  return ret
end

PlayerMainlineDataEx.GetChapterAward = function(self, nChapterId)
  -- function num : 0_6
  if (self._mapChapters)[nChapterId] == nil then
    return 0
  end
  return (self._mapChapters)[nChapterId]
end

PlayerMainlineDataEx.GetMianlineLevelStar = function(self, nLevelId)
  -- function num : 0_7 , upvalues : _ENV
  local mapMainlinData = (ConfigTable.GetData_Mainline)(nLevelId)
  if mapMainlinData == nil then
    return 0, {false, false, false}
  end
  local nChapterId = mapMainlinData.ChapterId
  if (self._mapStar)[nChapterId] == nil then
    return 0, {false, false, false}
  end
  if ((self._mapStar)[nChapterId])[nLevelId] == nil then
    return 0, {false, false, false}
  end
  return (((self._mapStar)[nChapterId])[nLevelId]).nStar, (((self._mapStar)[nChapterId])[nLevelId]).tbTarget
end

PlayerMainlineDataEx.ProcessMainlineData = function(self)
  -- function num : 0_8 , upvalues : _ENV
  self._mainlineData = {}
  local forEachTableMainline = function(mapData)
    -- function num : 0_8_0 , upvalues : self, _ENV
    local nChapter = mapData.ChapterId
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

    if (self._mainlineData)[nChapter] == nil then
      (self._mainlineData)[nChapter] = {}
    end
    -- DECOMPILER ERROR at PC18: Confused about usage of register: R2 in 'UnsetPending'

    if ((self._mainlineData)[nChapter])[mapData.Id] == nil then
      ((self._mainlineData)[nChapter])[mapData.Id] = {}
    end
    -- DECOMPILER ERROR at PC23: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (((self._mainlineData)[nChapter])[mapData.Id]).data = mapData
    -- DECOMPILER ERROR at PC29: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (((self._mainlineData)[nChapter])[mapData.Id]).Prev = mapData.Prev
    for _,prevId in pairs(mapData.Prev) do
      local mapPrevData = (ConfigTable.GetData_Mainline)(prevId)
      if mapPrevData ~= nil then
        local nChapterPrev = mapPrevData.ChapterId
        -- DECOMPILER ERROR at PC47: Confused about usage of register: R9 in 'UnsetPending'

        if (self._mainlineData)[nChapterPrev] == nil then
          (self._mainlineData)[nChapterPrev] = {}
        end
        -- DECOMPILER ERROR at PC56: Confused about usage of register: R9 in 'UnsetPending'

        if ((self._mainlineData)[nChapterPrev])[prevId] == nil then
          ((self._mainlineData)[nChapterPrev])[prevId] = {}
        end
        -- DECOMPILER ERROR at PC67: Confused about usage of register: R9 in 'UnsetPending'

        if (((self._mainlineData)[nChapterPrev])[prevId]).After == nil then
          (((self._mainlineData)[nChapterPrev])[prevId]).After = {}
        end
        ;
        (table.insert)((((self._mainlineData)[nChapterPrev])[prevId]).After, mapData.Id)
        ;
        (table.sort)((((self._mainlineData)[nChapterPrev])[prevId]).After)
      end
    end
  end

  ForEachTableLine(DataTable.Mainline, forEachTableMainline)
end

PlayerMainlineDataEx.GetAllMainlineChapter = function(self, nChapterId)
  -- function num : 0_9 , upvalues : _ENV
  local ret = {}
  local idx = 1
  local retIdx = nil
  local forEachTableChapter = function(mapData)
    -- function num : 0_9_0 , upvalues : nChapterId, retIdx, idx, self, _ENV, ret
    if nChapterId ~= nil and nChapterId == mapData.Id then
      retIdx = idx
    end
    local isUnlock = self:IsMainlineChapterUnlock(mapData.Id)
    local nStar, nAvgStar = self:GetChapterStars(mapData.Id)
    local nAwardIdx = self:GetChapterAward(mapData.Id)
    local TotalStar = self:GetChapterTotalStar(mapData.Id)
    ;
    (table.insert)(ret, {nId = mapData.Id, nStar = nStar, bUnlock = isUnlock, nAwardIdx = nAwardIdx, bComplete = TotalStar == nAvgStar})
    idx = idx + 1
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end

  ForEachTableLine(DataTable.Chapter, forEachTableChapter)
  return ret, retIdx
end

PlayerMainlineDataEx.GetAllLevelByChapter = function(self, nChapterId)
  -- function num : 0_10 , upvalues : _ENV
  if (self._mainlineData)[nChapterId] == nil then
    printError("没有章节数据：" .. nChapterId)
    return {}
  end
  local tbId = {}
  local mapId = {}
  local ret = {}
  for nId,_ in pairs((self._mainlineData)[nChapterId]) do
    (table.insert)(tbId, nId)
    mapId[nId] = false
  end
  ;
  (table.sort)(tbId)
  local AddMainline = function(nId)
    -- function num : 0_10_0 , upvalues : mapId, _ENV, self, ret, AddMainline
    if nId == nil then
      return 
    end
    if mapId[nId] == nil or mapId[nId] == true then
      return 
    end
    local levelData = (ConfigTable.GetData_Mainline)(nId)
    if levelData == nil then
      printError("关卡数据不存在" .. nId)
      return 
    end
    local ChapterId = levelData.ChapterId
    local nStar, tbTarget = self:GetMianlineLevelStar(nId)
    ;
    (table.insert)(ret, {nId = nId, nStar = nStar, tbTarget = tbTarget, bUnlock = self:IsMainlineLevelUnlock(nId)})
    mapId[nId] = true
    if ((self._mainlineData)[ChapterId])[nId] == nil then
      return 
    end
    local tbAfter = (((self._mainlineData)[ChapterId])[nId]).After
    if tbAfter == nil then
      return 
    end
    for _,nLevelId in ipairs(tbAfter) do
      AddMainline(nLevelId)
    end
  end

  local isStartLevel = function(nMainline)
    -- function num : 0_10_1 , upvalues : _ENV
    local mapMainline = (ConfigTable.GetData_Mainline)(nMainline)
    if mapMainline == nil then
      return false
    end
    local mapChapter = (ConfigTable.GetData)("Chapter", mapMainline.ChapterId)
    local tbPrevMainlines = mapChapter.PrevMainlines
    if mapMainline.Prev == nil or #mapMainline.Prev == 0 or (table.indexof)(mapMainline.Prev, tbPrevMainlines[1]) > 0 then
      return true
    else
      return false
    end
  end

  for _,nId in ipairs(tbId) do
    if isStartLevel(nId) then
      AddMainline(nId)
    end
  end
  return ret
end

PlayerMainlineDataEx.GetBanedCharId = function(self)
  -- function num : 0_11 , upvalues : _ENV
  if type(self._nSelectId) == "number" and self._nSelectId > 0 then
    local data = (ConfigTable.GetData_Mainline)(self._nSelectId)
    if data ~= nil then
      if type(data.CharBanned) == "table" then
        return data.CharBanned
      else
        return nil
      end
    else
      return nil
    end
  else
    do
      do return nil end
    end
  end
end

PlayerMainlineDataEx.GetBeforeBattleAvg = function(self)
  -- function num : 0_12 , upvalues : _ENV
  local sAvgId = ((ConfigTable.GetData_Mainline)(self._nSelectId)).BeforeAvgId
  if sAvgId == "" then
    return false
  end
  return sAvgId
end

PlayerMainlineDataEx.CalStar = function(nOrigin)
  -- function num : 0_13
  nOrigin = (nOrigin & 1431655765) + (nOrigin >> 1 & 1431655765)
  nOrigin = (nOrigin & 858993459) + (nOrigin >> 2 & 858993459)
  nOrigin = (nOrigin & 252645135) + (nOrigin >> 4 & 252645135)
  nOrigin = (nOrigin) * 16843009 >> 24
  return nOrigin
end

PlayerMainlineDataEx.GetAfterBattleAvg = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if not self.bUseOldMainline then
    return false
  end
  local sAvgId = ((ConfigTable.GetData_Mainline)(self._nSelectId)).AfterAvgId
  if sAvgId == "" then
    return false
  end
  return sAvgId
end

PlayerMainlineDataEx.GetCurChapter = function(self)
  -- function num : 0_15 , upvalues : _ENV
  if self._nSelectId == 0 then
    local curChapter = 1
    do
      local forEachChapter = function(mapData)
    -- function num : 0_15_0 , upvalues : self, curChapter
    if self:IsMainlineChapterUnlock(mapData.Id) and curChapter < mapData.Id then
      curChapter = mapData.Id
    end
  end

      ForEachTableLine(DataTable.Chapter, forEachChapter)
      return curChapter
    end
  else
    do
      local mapMainline = (ConfigTable.GetData_Mainline)(self._nSelectId)
      if mapMainline == nil then
        return 1
      end
      do return mapMainline.ChapterId end
    end
  end
end

PlayerMainlineDataEx.GetChapterCount = function(self)
  -- function num : 0_16 , upvalues : _ENV
  local count = 0
  if self.bUseOldMainline then
    local forEachChapter = function(mapData)
    -- function num : 0_16_0 , upvalues : count
    count = count + 1
  end

    ForEachTableLine(DataTable.Chapter, forEachChapter)
  else
    do
      do
        local forEachChapter = function(mapData)
    -- function num : 0_16_1 , upvalues : count
    count = count + 1
  end

        ForEachTableLine(DataTable.StoryChapter, forEachChapter)
        return count
      end
    end
  end
end

PlayerMainlineDataEx.GetSelectId = function(self)
  -- function num : 0_17
  return self._nSelectId
end

PlayerMainlineDataEx.GetCurLevelChar = function(self)
  -- function num : 0_18
  if self._mainlineLevel ~= nil and (self._mainlineLevel).tbChar ~= nil then
    return (self._mainlineLevel).tbChar
  end
  return {}
end

PlayerMainlineDataEx.EnterTest = function(self, nMainlineId, nTeamId)
  -- function num : 0_19 , upvalues : _ENV
  if self._mainlineLevel ~= nil then
    printError("当前关卡level不为空2")
    return 
  end
  if type(((ConfigTable.GetData_Mainline)(nMainlineId)).AvgId) == "string" and ((ConfigTable.GetData_Mainline)(nMainlineId)).AvgId ~= "" then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("MainlineData_Avg")})
    return 
  end
  local tbCharId = (PlayerData.Team):GetTeamCharId(nTeamId)
  self._nSelectId = nMainlineId
  -- DECOMPILER ERROR at PC49: Confused about usage of register: R4 in 'UnsetPending'

  PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).Mainline
  if #tbCharId == 0 then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("MainlineData_FormationError")})
    return 
  end
  local luaClass = require("Game.Editor.MainlineLevel.MainlineEditor")
  if luaClass == nil then
    return 
  end
  self._mainlineLevel = luaClass
  if type((self._mainlineLevel).Init) == "function" then
    (self._mainlineLevel):Init(self, nMainlineId, nTeamId, {}, {})
  end
end

PlayerMainlineDataEx.EnterMainlineEditor = function(self, nMainlineId, tbTeamCharId, tbTalentSkillAI, tbDisc, tbNote, tbSkinId)
  -- function num : 0_20 , upvalues : _ENV
  if self._mainlineLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Editor.MainlineLevel.MainlineEditor")
  if luaClass == nil then
    return 
  end
  self._mainlineLevel = luaClass
  if type((self._mainlineLevel).InitBootConfig) == "function" then
    (self._mainlineLevel):InitBootConfig(self, nMainlineId, tbTeamCharId, {}, {}, tbTalentSkillAI, tbDisc, tbNote, tbSkinId)
  end
end

PlayerMainlineDataEx.EnterPreviewEditor = function(self, nLevelType, nLevelId, bView, nStarTowerFloorSetId, nPrefabID, nPrefabExtension, nPlayType, nSceneMir)
  -- function num : 0_21 , upvalues : _ENV
  if self._mainlineLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Adventure.MainlineLevel.PreviewLevel")
  if luaClass == nil then
    return 
  end
  self._mainlineLevel = luaClass
  if type((self._mainlineLevel).Init) == "function" then
    (self._mainlineLevel):Init(nLevelType, nLevelId, bView, nStarTowerFloorSetId, nPrefabID, nPrefabExtension, nPlayType, nSceneMir, self)
  end
end

PlayerMainlineDataEx.EnterTestBattleComboClipEditor = function(self, nMainlineId, tbTeamCharId, tbTalentSkillAI, tbDisc, tbNote, tbSkinId)
  -- function num : 0_22 , upvalues : _ENV
  if self._mainlineLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Editor.MainlineLevel.BattleTestComboClipEditor")
  if luaClass == nil then
    return 
  end
  self._mainlineLevel = luaClass
  if type((self._mainlineLevel).InitBootConfig) == "function" then
    (self._mainlineLevel):InitBootConfig(self, nMainlineId, tbTeamCharId, {}, {}, tbTalentSkillAI, tbDisc, tbNote, tbSkinId)
  end
end

PlayerMainlineDataEx.LevelEnd = function(self)
  -- function num : 0_23 , upvalues : _ENV
  (PlayerData.Char):DeleteTrialChar()
  if type((self._mainlineLevel).UnBindEvent) == "function" then
    (self._mainlineLevel):UnBindEvent()
  end
  self._mainlineLevel = nil
end

PlayerMainlineDataEx.UpdateMainlineStar = function(self, nMainlineId, nStar)
  -- function num : 0_24 , upvalues : _ENV
  local mapMainline = (ConfigTable.GetData_Mainline)(nMainlineId)
  local nChapter = mapMainline.ChapterId
  -- DECOMPILER ERROR at PC11: Confused about usage of register: R5 in 'UnsetPending'

  if (self._mapStar)[nChapter] == nil then
    (self._mapStar)[nChapter] = {}
  end
  local sumStar = (self.CalStar)(nStar)
  local b1 = 1
  local b2 = 2
  local b3 = 4
  local t1 = nStar & b1 > 0
  local t2 = nStar & b2 > 0
  local t3 = nStar & b3 > 0
  local tbTarget = {t1, t2, t3}
  if sumStar > 0 and (((self._mapStar)[nChapter])[nMainlineId] == nil or (((self._mapStar)[nChapter])[nMainlineId]).nStar == 0) then
    (PlayerData.Base):CheckNewFuncUnlockMainlinePass(nMainlineId)
  end
  -- DECOMPILER ERROR at PC61: Confused about usage of register: R13 in 'UnsetPending'

  ;
  ((self._mapStar)[nChapter])[nMainlineId] = {nStar = sumStar, tbTarget = tbTarget}
  self:UpdateRewardRedDot()
  -- DECOMPILER ERROR: 5 unprocessed JMP targets
end

PlayerMainlineDataEx.UpdateMainlineChapterReward = function(self, chapterId, nIdx)
  -- function num : 0_25
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self._mapChapters)[chapterId] = nIdx
  self:UpdateRewardRedDot()
end

PlayerMainlineDataEx.OnEvent_EnterMainline = function(self, nTeamId)
  -- function num : 0_26 , upvalues : _ENV
  local mapMainline = (ConfigTable.GetData_Mainline)(self._nSelectId)
  if mapMainline == nil then
    return 
  end
  local nStar = 0
  if (self._mapStar)[mapMainline.ChapterId] ~= nil and ((self._mapStar)[mapMainline.ChapterId])[self._nSelectId] ~= nil then
    nStar = (((self._mapStar)[mapMainline.ChapterId])[self._nSelectId]).nStar
  end
  if (nStar == nil or nStar == 0 or mapMainline.Energy < 1) and (PlayerData.Base):CheckEnergyEnough(self._nSelectId) == false then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("MainlineData_Energy")})
    return 
  end
  self:NetMsg_EnterMainline(self._nSelectId, nTeamId, nil)
end

PlayerMainlineDataEx.NetMsg_GetMainlineAward = function(self, nChapterId, callback, rewardIdx)
  -- function num : 0_27 , upvalues : _ENV
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_27_0 , upvalues : _ENV, self, nChapterId, rewardIdx, callback
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self._mapChapters)[nChapterId] = rewardIdx
    if callback ~= nil then
      callback(mapMsgData.Items, mapMsgData.Change)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).chapter_reward_receive_req, {Value = nChapterId}, nil, msgCallback)
end

PlayerMainlineDataEx.NetMsg_EnterMainline = function(self, nMainlineId, nTeamIdx, callback)
  -- function num : 0_28 , upvalues : _ENV
  if self._mainlineLevel ~= nil then
    printError("当前关卡level不为空3")
    return 
  end
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_28_0 , upvalues : callback, _ENV, nMainlineId, self, nTeamIdx
    if callback ~= nil then
      callback(mapMsgData)
    end
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    local mapMainline = (ConfigTable.GetData_Mainline)(nMainlineId)
    if mapMainline == nil then
      printError("主线数据不存在：" .. nMainlineId)
      return 
    end
    if mapMainline.AvgId ~= nil and mapMainline.AvgId ~= "" then
      local luaClass = require("Game.Adventure.MainlineLevel.MainlineAvgLevel")
      if luaClass == nil then
        return 
      end
      self._mainlineLevel = luaClass
      if type((self._mainlineLevel).Init) == "function" then
        (self._mainlineLevel):Init(self, nMainlineId)
      end
    else
      do
        local luaClass = require("Game.Adventure.MainlineLevel.MainlineBattleLevel")
        if luaClass == nil then
          return 
        end
        self._mainlineLevel = luaClass
        if type((self._mainlineLevel).Init) == "function" then
          (self._mainlineLevel):Init(self, nMainlineId, nTeamIdx, mapMsgData.OpenMinChests, mapMsgData.OpenMaxChests)
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mainline_apply_req, {ID = nMainlineId, FormationId = nTeamIdx}, nil, msgCallback)
end

PlayerMainlineDataEx.NetMsg_UnlockMainline = function(self, nMainlineId, callback)
  -- function num : 0_29 , upvalues : _ENV
  local msg = {Value = nMainlineId}
  local msgCallback = function()
    -- function num : 0_29_0 , upvalues : _ENV, nMainlineId, self, callback
    local mapMainline = (ConfigTable.GetData_Mainline)(nMainlineId)
    -- DECOMPILER ERROR at PC14: Confused about usage of register: R1 in 'UnsetPending'

    if mapMainline ~= nil then
      if (self._mapStar)[mapMainline.ChapterId] == nil then
        (self._mapStar)[mapMainline.ChapterId] = {}
      end
      -- DECOMPILER ERROR at PC20: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self._mapStar)[mapMainline.ChapterId])[nMainlineId] = {}
      -- DECOMPILER ERROR at PC26: Confused about usage of register: R1 in 'UnsetPending'

      ;
      (((self._mapStar)[mapMainline.ChapterId])[nMainlineId]).nStar = 0
      -- DECOMPILER ERROR at PC37: Confused about usage of register: R1 in 'UnsetPending'

      ;
      (((self._mapStar)[mapMainline.ChapterId])[nMainlineId]).tbTarget = {false, false, false}
    else
      printError("Mainline Data Missing:" .. nMainlineId)
    end
    if type(callback) == "function" then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mainline_unlock_req, msg, nil, msgCallback)
end

PlayerMainlineDataEx.EnterPrologue = function(self)
  -- function num : 0_30 , upvalues : _ENV
  if self._mainlineLevel ~= nil then
    printError("当前关卡level不为空3")
    return 
  end
  -- DECOMPILER ERROR at PC11: Confused about usage of register: R1 in 'UnsetPending'

  PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).Prologue
  local luaClass = require("Game.Adventure.MainlineLevel.MainlinePrologueLevel")
  if luaClass == nil then
    return 
  end
  self._mainlineLevel = luaClass
  if type((self._mainlineLevel).Init) == "function" then
    (self._mainlineLevel):Init(self)
  end
end

PlayerMainlineDataEx.UpdateRewardRedDot = function(self)
  -- function num : 0_31 , upvalues : _ENV
  for chapterId,v in pairs(self._mapStar) do
    local allStar = 0
    local canReceive = false
    for id,data in pairs(v) do
      local mapData = (ConfigTable.GetData_Mainline)(id)
      if mapData.AvgId == "" then
        allStar = allStar + data.nStar
      end
    end
    local chapterCfg = (ConfigTable.GetData)("Chapter", chapterId)
    if chapterCfg ~= nil then
      local tbReward = decodeJson(chapterCfg.CompleteRewards)
      local tbSortReward = {}
      for star,reward in pairs(tbReward) do
        (table.insert)(tbSortReward, {nStar = tonumber(star)})
      end
      ;
      (table.sort)(tbSortReward, function(a, b)
    -- function num : 0_31_0
    do return a.nStar < b.nStar end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
      local receivedRewardIdx = (self._mapChapters)[chapterId] or 0
      for idx,v in ipairs(tbSortReward) do
        if v.nStar <= allStar and receivedRewardIdx < idx then
          canReceive = true
          break
        end
      end
    end
    do
      do
        ;
        (RedDotManager.SetValid)(RedDotDefine.Map_MainLine_Reward, chapterId, canReceive)
        -- DECOMPILER ERROR at PC77: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
end

return PlayerMainlineDataEx

