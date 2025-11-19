local PlayerScoreBossData = class("PlayerScoreBossData")
local LocalData = require("GameCore.Data.LocalData")
PlayerScoreBossData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.BattleLv = 0
  self:InitBaseData()
  self.isGetScInfo = false
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  self:InitTableData()
  self:InitRankData()
end

PlayerScoreBossData.InitTableData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.tabScoreNeed = {}
  local foreach_Base = function(baseData)
    -- function num : 0_1_0 , upvalues : self
    -- DECOMPILER ERROR at PC3: Confused about usage of register: R1 in 'UnsetPending'

    (self.tabScoreNeed)[baseData.Star] = baseData.ScoreNeed
  end

  ForEachTableLine(DataTable.ScoreBossStar, foreach_Base)
  self.maxStarNeed = 0
  self.tabScoreBossReward = {}
  local foreach_Base = function(baseData)
    -- function num : 0_1_1 , upvalues : self
    -- DECOMPILER ERROR at PC2: Confused about usage of register: R1 in 'UnsetPending'

    (self.tabScoreBossReward)[baseData.Id] = baseData
    if self.maxStarNeed < baseData.StarNeed then
      self.maxStarNeed = baseData.StarNeed
    end
  end

  ForEachTableLine(DataTable.ScoreBossReward, foreach_Base)
end

PlayerScoreBossData.UnInit = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Remove)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

PlayerScoreBossData.InitBaseData = function(self)
  -- function num : 0_3
  self.ControlId = 0
  self.Score = 0
  self.Star = 0
  self.tabStarRewards = {}
  self.tabScoreBossLevel = {}
  self.OpenLevelGroup = {}
  self.StartTime = 0
  self.EndTime = 0
  self.tabCachedBuildId = {}
end

PlayerScoreBossData.GetInitInfoState = function(self)
  -- function num : 0_4 , upvalues : _ENV
  if self.ControlId ~= 0 then
    local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
    local tmpControl = (ConfigTable.GetData)("ScoreBossControl", self.ControlId + 1)
    if tmpControl then
      local startTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(tmpControl.StartTime)
      if startTime <= nCurTime then
        self.isGetScInfo = false
      end
    end
  end
  do
    return self.isGetScInfo
  end
end

PlayerScoreBossData.GetScoreBossInstanceData = function(self, openPanelCallBack)
  -- function num : 0_5 , upvalues : _ENV
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_5_0 , upvalues : self, openPanelCallBack
    self:CacheScoreBossInstanceData(mapMsgData, openPanelCallBack)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).score_boss_info_req, {}, nil, msgCallback)
end

PlayerScoreBossData.CacheScoreBossInstanceData = function(self, mapMsgData, openPanelCallBack)
  -- function num : 0_6 , upvalues : _ENV
  self:InitBaseData()
  if mapMsgData == nil or mapMsgData.ControlId == 0 then
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("ScoreBoss_Season_Error"))
    return 
  end
  self.ControlId = mapMsgData.ControlId
  self.Score = mapMsgData.Score
  self.Star = mapMsgData.Star
  for i,v in pairs(mapMsgData.StarRewards) do
    (table.insert)(self.tabStarRewards, v)
  end
  self.maxRankCount = 0
  local foreach_Base = function(baseData)
    -- function num : 0_6_0 , upvalues : self
    if baseData.SeasonId == self.ControlId then
      self.maxRankCount = self.maxRankCount + 1
    end
  end

  ForEachTableLine(DataTable.ScoreBossRank, foreach_Base)
  local scoreBossControl = (ConfigTable.GetData)("ScoreBossControl", self.ControlId)
  if scoreBossControl ~= nil then
    local levelGroup = scoreBossControl.LevelGroup
    if #levelGroup > 0 then
      for i = 1, #levelGroup do
        (table.insert)(self.OpenLevelGroup, levelGroup[i])
        local tab = {}
        tab.LevelId = levelGroup[i]
        tab.BuildId = 0
        tab.CharId = {0, 0, 0}
        tab.Score = 0
        tab.Star = 0
        tab.SkillScore = 0
        -- DECOMPILER ERROR at PC76: Confused about usage of register: R11 in 'UnsetPending'

        ;
        (self.tabScoreBossLevel)[levelGroup[i]] = tab
      end
    end
    do
      do
        self.StartTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(scoreBossControl.StartTime)
        self.EndTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(scoreBossControl.EndTime) - (ConfigTable.GetConfigNumber)("SeasonEndThreshold")
        for i,v in pairs(mapMsgData.Levels) do
          -- DECOMPILER ERROR at PC110: Confused about usage of register: R10 in 'UnsetPending'

          if (self.tabScoreBossLevel)[v.LevelId] then
            ((self.tabScoreBossLevel)[v.LevelId]).BuildId = v.BuildId
            for i1 = 1, #v.CharIds do
              -- DECOMPILER ERROR at PC122: Confused about usage of register: R14 in 'UnsetPending'

              (((self.tabScoreBossLevel)[v.LevelId]).CharId)[i1] = (v.CharIds)[i1]
            end
            -- DECOMPILER ERROR at PC128: Confused about usage of register: R10 in 'UnsetPending'

            ;
            ((self.tabScoreBossLevel)[v.LevelId]).Score = v.Score
            -- DECOMPILER ERROR at PC133: Confused about usage of register: R10 in 'UnsetPending'

            ;
            ((self.tabScoreBossLevel)[v.LevelId]).Star = v.Star
            -- DECOMPILER ERROR at PC138: Confused about usage of register: R10 in 'UnsetPending'

            ;
            ((self.tabScoreBossLevel)[v.LevelId]).SkillScore = v.SkillScore
          else
            printError("ScoreBossControl 下发数据和配置数据对不上")
          end
        end
        if not self.isGetScInfo then
          (EventManager.Hit)("Get_ScoreBoss_InfoReq")
        end
        self.isGetScInfo = true
        self:RefreshRedMsg()
        if openPanelCallBack then
          openPanelCallBack()
        end
      end
    end
  end
end

PlayerScoreBossData.RefreshRedMsg = function(self)
  -- function num : 0_7 , upvalues : _ENV
  self.isHave = false
  for i,v in ipairs(self.tabScoreBossReward) do
    if v.StarNeed <= self.Star and (table.indexof)(self.tabStarRewards, v.StarNeed) == 0 then
      self.isHave = true
      break
    end
  end
  do
    ;
    (RedDotManager.SetValid)(RedDotDefine.Map_ScoreBossStar, nil, self.isHave)
  end
end

PlayerScoreBossData.UpdateRedDot = function(self, mapMsgData)
  -- function num : 0_8 , upvalues : _ENV
  if mapMsgData == nil then
    return 
  end
  ;
  (RedDotManager.SetValid)(RedDotDefine.Map_ScoreBossStar, nil, mapMsgData.New)
end

PlayerScoreBossData.ChangeTabScoreBossLevel = function(self, nLevelId, nBuildId, nScore, nStar, nBehaviorScore, isReplace, tabOtherLevelId)
  -- function num : 0_9 , upvalues : _ENV
  -- DECOMPILER ERROR at PC4: Confused about usage of register: R8 in 'UnsetPending'

  if isReplace then
    ((self.tabScoreBossLevel)[nLevelId]).BuildId = nBuildId
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R8 in 'UnsetPending'

    ;
    ((self.tabScoreBossLevel)[nLevelId]).CharId = self.entryLevelChar
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R8 in 'UnsetPending'

    ;
    ((self.tabScoreBossLevel)[nLevelId]).Score = nScore
    -- DECOMPILER ERROR at PC14: Confused about usage of register: R8 in 'UnsetPending'

    ;
    ((self.tabScoreBossLevel)[nLevelId]).Star = nStar
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R8 in 'UnsetPending'

    ;
    ((self.tabScoreBossLevel)[nLevelId]).SkillScore = nBehaviorScore
  else
    -- DECOMPILER ERROR at PC26: Confused about usage of register: R8 in 'UnsetPending'

    if ((self.tabScoreBossLevel)[nLevelId]).Score <= nScore then
      ((self.tabScoreBossLevel)[nLevelId]).BuildId = nBuildId
      -- DECOMPILER ERROR at PC30: Confused about usage of register: R8 in 'UnsetPending'

      ;
      ((self.tabScoreBossLevel)[nLevelId]).CharId = self.entryLevelChar
      -- DECOMPILER ERROR at PC33: Confused about usage of register: R8 in 'UnsetPending'

      ;
      ((self.tabScoreBossLevel)[nLevelId]).Score = nScore
      -- DECOMPILER ERROR at PC36: Confused about usage of register: R8 in 'UnsetPending'

      ;
      ((self.tabScoreBossLevel)[nLevelId]).Star = nStar
      -- DECOMPILER ERROR at PC39: Confused about usage of register: R8 in 'UnsetPending'

      ;
      ((self.tabScoreBossLevel)[nLevelId]).SkillScore = nBehaviorScore
    end
  end
  if #tabOtherLevelId > 0 then
    for i,v in pairs(tabOtherLevelId) do
      local tmpLevelId = v
      -- DECOMPILER ERROR at PC50: Confused about usage of register: R14 in 'UnsetPending'

      ;
      ((self.tabScoreBossLevel)[tmpLevelId]).BuildId = 0
      -- DECOMPILER ERROR at PC58: Confused about usage of register: R14 in 'UnsetPending'

      ;
      ((self.tabScoreBossLevel)[tmpLevelId]).CharId = {0, 0, 0}
      -- DECOMPILER ERROR at PC61: Confused about usage of register: R14 in 'UnsetPending'

      ;
      ((self.tabScoreBossLevel)[tmpLevelId]).Score = 0
      -- DECOMPILER ERROR at PC64: Confused about usage of register: R14 in 'UnsetPending'

      ;
      ((self.tabScoreBossLevel)[tmpLevelId]).Star = 0
      -- DECOMPILER ERROR at PC67: Confused about usage of register: R14 in 'UnsetPending'

      ;
      ((self.tabScoreBossLevel)[tmpLevelId]).SkillScore = 0
    end
  end
  do
    local _totalStar = 0
    local _totalScore = 0
    for i,v in pairs(self.tabScoreBossLevel) do
      _totalStar = _totalStar + v.Star
      _totalScore = _totalScore + v.Score
    end
    self.Score = _totalScore
    self.Star = _totalStar
    self:RefreshRedMsg()
  end
end

PlayerScoreBossData.OnEvent_NewDay = function(self)
  -- function num : 0_10 , upvalues : _ENV
  local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
  if self.EndTime ~= 0 and self.EndTime < nCurTime then
    self:GetScoreBossInstanceData(nil)
    self:SendScoreBossApplyReq(function()
    -- function num : 0_10_0
  end
)
  end
end

PlayerScoreBossData.SendEnterScoreBossApplyReq = function(self, nLevelId, nBuildId)
  -- function num : 0_11 , upvalues : _ENV, LocalData
  local msg = {}
  msg.LevelId = nLevelId
  msg.BuildId = nBuildId
  local msgCallback = function()
    -- function num : 0_11_0 , upvalues : self, _ENV, LocalData, nLevelId, nBuildId
    self.CurHPLvScore = 0
    self.HPLvScore = 0
    self.CurHPDamage = 0
    self.BehaviorScore = 0
    self.BehaviorScoreCount = 0
    local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
    local sKey = (LocalData.GetPlayerLocalData)("ScoreBossRecordKey")
    if sKey ~= nil and sKey ~= "" then
      (NovaAPI.DeleteRecFile)(sKey)
    end
    sKey = tostring(curTimeStamp)
    ;
    (LocalData.SetPlayerLocalData)("ScoreBossRecordKey", sKey)
    self:EnterScoreBossInstance(nLevelId, nBuildId)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).score_boss_apply_req, msg, nil, msgCallback)
end

PlayerScoreBossData.EnterScoreBossInstance = function(self, nLevelId, nBuildId)
  -- function num : 0_12 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  self.entryLevelId = nLevelId
  self.entryBuild = nBuildId
  local luaClass = require("Game.Adventure.ScoreBoss.ScoreBossLevel")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, nLevelId, nBuildId)
  end
end

PlayerScoreBossData.EnterScoreBossInstanceEditor = function(self, nLevelId, tbChar, tbDisc, tbNote)
  -- function num : 0_13 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  self.entryLevelId = nLevelId
  self.CurHPLvScore = 0
  self.HPLvScore = 0
  self.CurHPDamage = 0
  self.BehaviorScore = 0
  self.BehaviorScoreCount = 0
  local luaClass = require("Game.Editor.ScoreBoss.ScoreBossEditor")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, nLevelId, tbChar, tbDisc, tbNote)
  end
end

PlayerScoreBossData.LevelEnd = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if self.curLevel ~= nil and type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
end

PlayerScoreBossData.CacheBuildCharTid = function(self, tab)
  -- function num : 0_15
  self.entryLevelChar = tab
end

PlayerScoreBossData.GetEntryBuildCharTid = function(self)
  -- function num : 0_16
  return self.entryLevelChar
end

PlayerScoreBossData.SetSelBuildId = function(self, nBuildId, levelId)
  -- function num : 0_17
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self.tabCachedBuildId)[levelId] = nBuildId
end

PlayerScoreBossData.GetCachedBuild = function(self, levelId)
  -- function num : 0_18
  return (self.tabCachedBuildId)[levelId] or 0
end

PlayerScoreBossData.GetLevelBuild = function(self, levelId)
  -- function num : 0_19
  if (self.tabScoreBossLevel)[levelId] and ((self.tabScoreBossLevel)[levelId]).BuildId ~= 0 then
    return ((self.tabScoreBossLevel)[levelId]).BuildId
  end
  return 0
end

PlayerScoreBossData.GetLevelData = function(self, levelId)
  -- function num : 0_20
  if (self.tabScoreBossLevel)[levelId] then
    return (self.tabScoreBossLevel)[levelId]
  end
  return nil
end

PlayerScoreBossData.GetBuildChar = function(self, buildId, callBack)
  -- function num : 0_21 , upvalues : _ENV
  local GetDataCallback = function(tbBuildData, mapAllBuild)
    -- function num : 0_21_0 , upvalues : buildId, _ENV, callBack
    local mapBuild = mapAllBuild[buildId]
    local tbCharId = {}
    if mapBuild ~= nil then
      for _,mapChar in ipairs(mapBuild.tbChar) do
        (table.insert)(tbCharId, mapChar.nTid)
      end
    end
    do
      callBack(tbCharId)
    end
  end

  ;
  (PlayerData.Build):GetAllBuildBriefData(GetDataCallback)
end

PlayerScoreBossData.JudgeOtherLevelHaveSameChar = function(self, entryLevelId, entryBuildId, callBack)
  -- function num : 0_22 , upvalues : _ENV
  local otherLevelId = {}
  local GetDataCallback = function(tbBuildData, mapAllBuild)
    -- function num : 0_22_0 , upvalues : entryBuildId, _ENV, self, entryLevelId, otherLevelId, callBack
    local entryBuild = mapAllBuild[entryBuildId]
    local entryChar = {}
    for _,mapChar in ipairs(entryBuild.tbChar) do
      (table.insert)(entryChar, mapChar.nTid)
    end
    for i,v in pairs(self.OpenLevelGroup) do
      if v ~= entryLevelId and (self.tabScoreBossLevel)[v] and (((self.tabScoreBossLevel)[v]).CharId)[1] ~= 0 then
        for i1,v1 in pairs(((self.tabScoreBossLevel)[v]).CharId) do
          local idx = (table.indexof)(entryChar, v1)
          if idx ~= 0 then
            (table.insert)(otherLevelId, ((self.tabScoreBossLevel)[v]).LevelId)
            break
          end
        end
      end
    end
    callBack(otherLevelId)
  end

  ;
  (PlayerData.Build):GetAllBuildBriefData(GetDataCallback)
end

PlayerScoreBossData.JudgeLevelCacheOtherChar = function(self, entryLevelId, entryBuildId, callBack)
  -- function num : 0_23 , upvalues : _ENV
  local tmpBuild = self:GetLevelBuild(entryLevelId)
  if tmpBuild == 0 or tmpBuild == entryBuildId then
    callBack(false)
    return 
  end
  if (((self.tabScoreBossLevel)[entryLevelId]).CharId)[1] ~= 0 then
    for i,v in pairs(((self.tabScoreBossLevel)[entryLevelId]).CharId) do
      local idx = (table.indexof)(self.entryLevelChar, v)
      if idx == 0 then
        callBack(true)
        return 
      end
    end
    callBack(false)
  else
    callBack(false)
  end
end

PlayerScoreBossData.DamageToScore = function(self, damageValue, SwitchRate, battleLv)
  -- function num : 0_24 , upvalues : _ENV
  self.CurHPDamage = damageValue
  self.CurHPLvScore = (math.floor)(damageValue / SwitchRate)
  self.BattleLv = battleLv
  ;
  (EventManager.Hit)("ScoreBoss_Score_Change")
end

PlayerScoreBossData.HPLevelChanged = function(self)
  -- function num : 0_25 , upvalues : _ENV
  self.HPLvScore = self.HPLvScore + self.CurHPLvScore
  self.CurHPLvScore = 0
  self.CurHPDamage = 0
  ;
  (EventManager.Hit)("ScoreBoss_Score_Change")
end

PlayerScoreBossData.BehaviorToScore = function(self, nScore)
  -- function num : 0_26 , upvalues : _ENV
  self.BehaviorScore = nScore
  self.BehaviorScoreCount = self.BehaviorScoreCount + 1
  ;
  (EventManager.Hit)("ScoreBoss_Score_Change")
  ;
  (EventManager.Hit)("ScoreBoss_Score_SkillChange")
end

PlayerScoreBossData.GetTotalScore = function(self)
  -- function num : 0_27
  local totalScore = self.HPLvScore + self.CurHPLvScore + self.BehaviorScore
  return totalScore
end

PlayerScoreBossData.GetBehaviorScore = function(self)
  -- function num : 0_28
  return self.BehaviorScore, self.BehaviorScoreCount
end

PlayerScoreBossData.GetDamageScore = function(self)
  -- function num : 0_29
  return self.HPLvScore + self.CurHPLvScore
end

PlayerScoreBossData.ScoreToStar = function(self)
  -- function num : 0_30 , upvalues : _ENV
  local tmpStar = 0
  local totalScore = self.HPLvScore + self.CurHPLvScore + self.BehaviorScore
  for i,v in pairs(self.tabScoreNeed) do
    if v <= totalScore and tmpStar < i then
      tmpStar = i
    end
  end
  return tmpStar
end

PlayerScoreBossData.QuiteLevel = function(self)
  -- function num : 0_31 , upvalues : _ENV
  self:LevelEnd()
  local wait = function()
    -- function num : 0_31_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    ;
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    ;
    ((CS.WwiseAudioManager).Instance):PostEvent("ui_loading_combatSFX_mute", nil, false)
  end

  ;
  (cs_coroutine.start)(wait)
  ;
  ((CS.AdventureModuleHelper).ResumeLogic)()
  local levelEndCallback = function()
    -- function num : 0_31_1 , upvalues : _ENV, self, levelEndCallback
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    ;
    (NovaAPI.EnterModule)("MainMenuModuleScene", true)
  end

  ;
  (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
  ;
  ((CS.AdventureModuleHelper).LevelStateChanged)(true, 0, true)
end

PlayerScoreBossData.SureScoreBossSettleReq = function(self, totalStar, totalScore, isReplace, tabOtherLevelId)
  -- function num : 0_32 , upvalues : _ENV, LocalData
  (NovaAPI.StopRecord)()
  local tbSamples = (UTILS.GetBattleSamples)()
  local sKey = (LocalData.GetPlayerLocalData)("ScoreBossRecordKey")
  local bSuccess, nCheckSum = (NovaAPI.GetRecorderKey)(sKey)
  local tbSendSample = {Sample = tbSamples, Checksum = nCheckSum}
  local msg = {}
  msg.Star = totalStar
  msg.Score = totalScore
  msg.sample = tbSendSample
  msg.DamageScore = (math.floor)(self.HPLvScore + self.CurHPLvScore)
  msg.SkillScore = self.BehaviorScore
  msg.BossResultLevel = self.BattleLv
  msg.Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).ScoreBoss, true)}
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_32_0 , upvalues : self, totalScore, totalStar, isReplace, tabOtherLevelId, _ENV
    local oldRank = mapMsgData.oldRank
    local newRank = mapMsgData.newRank
    self:UploadRecordFile(mapMsgData.token)
    self:ChangeTabScoreBossLevel(self.entryLevelId, self.entryBuild, totalScore, totalStar, self.BehaviorScore, isReplace, tabOtherLevelId)
    ;
    ((CS.AdventureModuleHelper).ResumeLogic)()
    ;
    (EventManager.Hit)("ScoreBossSettleSuccess", self.entryLevelId, totalScore, totalStar)
    self:LevelEnd()
    self._EndTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
    local leveData = (ConfigTable.GetData)("ScoreBossLevel", self.entryLevelId)
    local tabUpLevel = {}
    ;
    (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (table.insert)(tabUpLevel, {"game_cost_time", tostring(self.TotalTime)})
    ;
    (table.insert)(tabUpLevel, {"real_cost_time", tostring(self._EndTime - self._EntryTime)})
    ;
    (table.insert)(tabUpLevel, {"build_id", tostring(self.entryBuild)})
    ;
    (table.insert)(tabUpLevel, {"battle_id", tostring(leveData.MonsterId)})
    ;
    (table.insert)(tabUpLevel, {"total_score", tostring(totalScore)})
    ;
    (table.insert)(tabUpLevel, {"boss_result_level", tostring(self.BattleLv)})
    ;
    (NovaAPI.UserEventUpload)("boss_rush", tabUpLevel)
    self.isLevelClear = true
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).score_boss_settle_req, msg, nil, msgCallback)
end

PlayerScoreBossData.UploadRecordFile = function(self, sToken)
  -- function num : 0_33 , upvalues : LocalData, _ENV
  local sKey = (LocalData.GetPlayerLocalData)("ScoreBossRecordKey") or ""
  if sKey ~= nil and sKey ~= "" then
    if sToken ~= nil and sToken ~= "" then
      (NovaAPI.UploadStartowerFile)(sToken, sKey)
    else
      ;
      (NovaAPI.DeleteRecFile)(sKey)
    end
  end
  ;
  (LocalData.SetPlayerLocalData)("ScoreBossRecordKey", "")
end

PlayerScoreBossData.SendScoreBossSettleReq = function(self, totalTime)
  -- function num : 0_34 , upvalues : _ENV
  self.TotalTime = totalTime
  ;
  ((CS.AdventureModuleHelper).PauseLogic)()
  local JudgeOther = function(otherLevelId)
    -- function num : 0_34_0 , upvalues : self, _ENV
    local totalScore = self.HPLvScore + self.CurHPLvScore + self.BehaviorScore
    local totalStar = self:ScoreToStar()
    if #otherLevelId == 0 then
      local judgeCache = function(isReplace)
      -- function num : 0_34_0_0 , upvalues : self, totalStar, totalScore, _ENV
      if isReplace then
        local ConfirmCb = function()
        -- function num : 0_34_0_0_0 , upvalues : self, totalStar, totalScore
        self:SureScoreBossSettleReq(totalStar, totalScore, true, {})
      end

        local CancelCb = function()
        -- function num : 0_34_0_0_1 , upvalues : self
        self:QuiteLevel()
      end

        ;
        (EventManager.Hit)(EventId.OpenPanel, PanelId.ScoreBossReplaceBD, self.entryLevelId, ConfirmCb, CancelCb)
      else
        do
          self:SureScoreBossSettleReq(totalStar, totalScore, false, {})
        end
      end
    end

      self:JudgeLevelCacheOtherChar(self.entryLevelId, self.entryBuild, judgeCache)
    else
      do
        local judgeCache = function(isReplace)
      -- function num : 0_34_0_1 , upvalues : self, totalStar, totalScore, otherLevelId, _ENV
      if isReplace then
        local ConfirmCb = function()
        -- function num : 0_34_0_1_0 , upvalues : self, totalStar, totalScore, otherLevelId, _ENV
        local ConfirmClearCb = function()
          -- function num : 0_34_0_1_0_0 , upvalues : self, totalStar, totalScore, otherLevelId
          self:SureScoreBossSettleReq(totalStar, totalScore, true, otherLevelId)
        end

        local CancelClearCb = function()
          -- function num : 0_34_0_1_0_1 , upvalues : self
          self:QuiteLevel()
        end

        ;
        (EventManager.Hit)(EventId.OpenPanel, PanelId.ScoreBossClearBD, otherLevelId, ConfirmClearCb, CancelClearCb)
      end

        local CancelCb = function()
        -- function num : 0_34_0_1_1 , upvalues : self
        self:QuiteLevel()
      end

        ;
        (EventManager.Hit)(EventId.OpenPanel, PanelId.ScoreBossReplaceBD, self.entryLevelId, ConfirmCb, CancelCb)
      else
        do
          local ConfirmClearCb = function()
        -- function num : 0_34_0_1_2 , upvalues : self, totalStar, totalScore, otherLevelId
        self:SureScoreBossSettleReq(totalStar, totalScore, true, otherLevelId)
      end

          local CancelClearCb = function()
        -- function num : 0_34_0_1_3 , upvalues : self
        self:QuiteLevel()
      end

          ;
          (EventManager.Hit)(EventId.OpenPanel, PanelId.ScoreBossClearBD, otherLevelId, ConfirmClearCb, CancelClearCb)
        end
      end
    end

        self:JudgeLevelCacheOtherChar(self.entryLevelId, self.entryBuild, judgeCache)
      end
    end
  end

  self:JudgeOtherLevelHaveSameChar(self.entryLevelId, self.entryBuild, JudgeOther)
end

PlayerScoreBossData.SendScoreBossStarRewardReceiveReq = function(self, cb, star)
  -- function num : 0_35 , upvalues : _ENV
  local msg = {}
  msg.Star = star
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_35_0 , upvalues : star, _ENV, self, cb
    if star ~= 0 then
      (table.insert)(self.tabStarRewards, star)
    else
      self.tabStarRewards = {}
      for i,v in pairs(self.tabScoreBossReward) do
        if v.StarNeed <= self.Star then
          (table.insert)(self.tabStarRewards, v.StarNeed)
        end
      end
    end
    do
      local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
      ;
      (UTILS.OpenReceiveByDisplayItem)(mapDecodedChangeInfo["proto.Res"], mapMsgData)
      cb()
      self:RefreshRedMsg()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).score_boss_star_reward_receive_req, msg, nil, msgCallback)
end

PlayerScoreBossData.SendScoreBossApplyReq = function(self, cb)
  -- function num : 0_36 , upvalues : _ENV
  self:InitRankData()
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_36_0 , upvalues : self, cb
    self:SetRankMsg(mapMsgData, cb)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).score_boss_rank_req, {}, nil, msgCallback)
end

PlayerScoreBossData.InitRankData = function(self)
  -- function num : 0_37
  self.RankLastRefreshTime = 0
  self.RankSelfMsg = nil
  self.RankPlayerMsg = {}
  self.RankBorder = {}
  self.nRankTotalCount = 0
end

PlayerScoreBossData.SetRankMsg = function(self, mapMsgData, cb)
  -- function num : 0_38 , upvalues : _ENV
  self.RankLastRefreshTime = mapMsgData.LastRefreshTime
  if mapMsgData.Self then
    self.RankSelfMsg = mapMsgData.Self
  end
  if mapMsgData.Rank then
    for i,v in pairs(mapMsgData.Rank) do
      (table.insert)(self.RankPlayerMsg, v)
    end
  end
  do
    if mapMsgData.Border then
      for i,v in pairs(mapMsgData.Border) do
        (table.insert)(self.RankBorder, v)
      end
    end
    do
      if mapMsgData.Total then
        self.nRankTotalCount = mapMsgData.Total
      end
      cb()
    end
  end
end

PlayerScoreBossData.CheckRankDataLastest = function(self)
  -- function num : 0_39
  if self.RankSelfMsg == nil or (self.RankSelfMsg).Rank == 0 then
    return true
  end
  local mapSelfDataInList = nil
  if (self.RankSelfMsg).Rank <= #self.RankPlayerMsg then
    mapSelfDataInList = (self.RankPlayerMsg)[(self.RankSelfMsg).Rank]
  else
    return false
  end
  if mapSelfDataInList == nil or mapSelfDataInList.NickName ~= (self.RankSelfMsg).NickName or mapSelfDataInList.Score ~= (self.RankSelfMsg).Score then
    return false
  end
  return true
end

PlayerScoreBossData.GetRankSelfMsg = function(self)
  -- function num : 0_40
  return self.RankSelfMsg
end

PlayerScoreBossData.GetSelfRankIndex = function(self)
  -- function num : 0_41
  if self.RankSelfMsg then
    return (self.RankSelfMsg).Rank
  end
  return 0
end

PlayerScoreBossData.GetRankBorderCount = function(self, index)
  -- function num : 0_42
  return (self.RankBorder)[index] or 0
end

PlayerScoreBossData.GetSelfBorderIndex = function(self)
  -- function num : 0_43 , upvalues : _ENV
  for i,v in pairs(self.RankBorder) do
    if v <= (self.RankSelfMsg).Score then
      return i
    end
  end
  return 1
end

PlayerScoreBossData.GetRankPlayerCount = function(self)
  -- function num : 0_44
  return self.nRankTotalCount or 0
end

PlayerScoreBossData.GetRankTableCount = function(self)
  -- function num : 0_45
  return #self.RankPlayerMsg or 0
end

PlayerScoreBossData.GetPlayerRankMsg = function(self, index)
  -- function num : 0_46
  return (self.RankPlayerMsg)[index] or nil
end

PlayerScoreBossData.GetVoiceKey = function(self)
  -- function num : 0_47 , upvalues : _ENV
  local isFirst = false
  if not self.isFirstVoice then
    isFirst = true
    self.isFirstVoice = true
  end
  local timeNow = ((CS.ClientManager).Instance).serverTimeStamp
  local nHour = tonumber((os.date)("%H", timeNow))
  if nHour >= 6 and nHour < 12 then
    return isFirst, "greetmorn_npc"
  else
    if nHour >= 12 and nHour < 18 then
      return isFirst, "greetnoon_npc"
    else
      return isFirst, "greetnight_npc"
    end
  end
end

return PlayerScoreBossData

