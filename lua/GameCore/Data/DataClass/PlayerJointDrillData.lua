local PlayerJointDrillData = class("PlayerJointDrillData")
local ConfigData = require("GameCore.Data.ConfigData")
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
local ClientManager = (CS.ClientManager).Instance
local ListInt = ((((CS.System).Collections).Generic).List)((CS.System).Int32)
PlayerJointDrillData.Init = function(self)
  -- function num : 0_0
  self.nActId = 0
  self.actTimer = nil
  self.nActStatus = 0
  self.tbPassedLevels = {}
  self.bInBattle = false
  self.curLevel = nil
  self.nCurLevelId = 0
  self.nCurLevel = 1
  self.nStartTime = 0
  self.nGameTime = 0
  self._EntryTime = 0
  self._EndTime = 0
  self.mapBossInfo = {}
  self.record = nil
  self.bSimulate = false
  self.tbTeams = {}
  self.nSelectBuildId = 0
  self.nChallengeCount = 0
  self.tbRecordFloors = {}
  self.tbQuests = {}
  self.nTotalScore = 0
  self.nLastRefreshRankTime = 0
  self.nRankingRefreshTime = 600
  self.mapSelfRankData = nil
  self.mapRankList = nil
  self.nTotalRank = 0
  self:InitConfig()
end

PlayerJointDrillData.UnInit = function(self)
  -- function num : 0_1
end

PlayerJointDrillData.InitConfig = function(self)
  -- function num : 0_2 , upvalues : _ENV
  self.nMaxChallengeTime = (ConfigTable.GetConfigNumber)("JointDrill_Challenge_Time_Max")
  self.nOverFlowChallengeTime = (ConfigTable.GetConfigNumber)("JointDrill_Challenge_Time_OverFlow")
  local funcForeachMonsterValueTemplete = function(line)
    -- function num : 0_2_0 , upvalues : _ENV
    (CacheTable.SetField)("_MonsterValueTemplete", line.TemplateId, line.Lv, line)
  end

  ForEachTableLine((ConfigTable.Get)("MonsterValueTemplete"), funcForeachMonsterValueTemplete)
  local funcForeachJointDrillLevel = function(line)
    -- function num : 0_2_1 , upvalues : _ENV
    (CacheTable.SetField)("_JointDrillLevel", line.DrillLevelGroupId, line.Difficulty, line)
  end

  ForEachTableLine((ConfigTable.Get)("JointDrillLevel"), funcForeachJointDrillLevel)
  local funcForeachJointDrillLevel = function(line)
    -- function num : 0_2_2 , upvalues : _ENV
    (CacheTable.SetField)("_JointDrillFloor", line.FloorId, line.BattleLvs, line)
  end

  ForEachTableLine((ConfigTable.Get)("JointDrillFloor"), funcForeachJointDrillLevel)
  local funcForeachJointDrillQuest = function(line)
    -- function num : 0_2_3 , upvalues : _ENV
    if (CacheTable.GetData)("_JointDrillQuest", line.GroupId) == nil then
      (CacheTable.SetData)("_JointDrillQuest", line.GroupId, {})
    end
    ;
    (CacheTable.InsertData)("_JointDrillQuest", line.GroupId, line)
  end

  ForEachTableLine((ConfigTable.Get)("JointDrillQuest"), funcForeachJointDrillQuest)
  self.nRankCount = 0
  local funcForeachJointDrillRank = function(line)
    -- function num : 0_2_4 , upvalues : self
    self.nRankCount = self.nRankCount + 1
  end

  ForEachTableLine((ConfigTable.Get)("JointDrillRank"), funcForeachJointDrillRank)
end

local EncodeTempDataJson = function(mapData)
  -- function num : 0_3 , upvalues : _ENV
  local stTempData = (CS.JointDrillTempData)(1)
  if mapData.mapCharacterTempData ~= nil and next(mapData.mapCharacterTempData) ~= nil then
    local mapCharacterTempData = mapData.mapCharacterTempData
    local stCharacter = {}
    local tbHp = mapCharacterTempData.hpInfo
    for nCharId,mapEffect in pairs(mapCharacterTempData.effectInfo) do
      if stCharacter[nCharId] == nil then
        stCharacter[nCharId] = (CS.JointDrillCharacter)(nCharId, tbHp[nCharId])
      end
      for nEtfId,mapEft in pairs(mapEffect.mapEffect) do
        ((stCharacter[nCharId]).tbEffect):Add((CS.StarTowerEffect)(nEtfId, mapEft.nCount, mapEft.nCd))
      end
    end
    for nCharId,mapBuff in pairs(mapCharacterTempData.buffInfo) do
      if stCharacter[nCharId] == nil then
        stCharacter[nCharId] = (CS.JointDrillCharacter)(nCharId, tbHp[nCharId])
      end
      for _,buffInfo in ipairs(mapBuff) do
        ((stCharacter[nCharId]).tbBuff):Add((CS.StarTowerBuffInfo)(buffInfo.Id, buffInfo.CD, buffInfo.nNum))
      end
    end
    for nCharId,mapStatus in pairs(mapCharacterTempData.stateInfo) do
      if stCharacter[nCharId] == nil then
        stCharacter[nCharId] = (CS.JointDrillCharacter)(nCharId, tbHp[nCharId])
      end
      -- DECOMPILER ERROR at PC96: Confused about usage of register: R10 in 'UnsetPending'

      ;
      (stCharacter[nCharId]).stateInfo = (CS.StarTowerState)(mapStatus.nState, mapStatus.nStateTime)
    end
    for nCharId,mapAmmoInfo in pairs(mapCharacterTempData.ammoInfo) do
      if stCharacter[nCharId] == nil then
        stCharacter[nCharId] = (CS.JointDrillCharacter)(nCharId, tbHp[nCharId])
      end
      -- DECOMPILER ERROR at PC123: Confused about usage of register: R10 in 'UnsetPending'

      ;
      (stCharacter[nCharId]).ammoInfo = (CS.StarTowerAmmoInfo)(mapAmmoInfo.nCurAmmo, mapAmmoInfo.nAmmo1, mapAmmoInfo.nAmmo2, mapAmmoInfo.nAmmo3, mapAmmoInfo.nAmmoMax1, mapAmmoInfo.nAmmoMax2, mapAmmoInfo.nAmmoMax3)
    end
    for _,skill in ipairs(mapCharacterTempData.skillInfo) do
      (stTempData.skillInfo):Add((CS.StarTowerSkill)(skill.nCharId, skill.nSkillId, skill.nCd, skill.nSectionAmount, skill.nSectionResumeTime, skill.nUseTimeHint, skill.nEnergy))
    end
    stTempData.summonMonsterInfo = mapCharacterTempData.sommonInfo
    for _,st in pairs(stCharacter) do
      (stTempData.characterInfo):Add(st)
    end
  end
  do
    local mapBossTempData = mapData.mapBossTempData
    stTempData.bossInfo = mapBossTempData
    local jsonData, length = (NovaAPI.ParseJointDrillDataCompressed)(stTempData)
    return jsonData, length
  end
end

local DecodeTempDataJson = function(sData)
  -- function num : 0_4 , upvalues : _ENV
  local tempData = {}
  tempData.mapCharacterTempData = {}
  tempData.mapBossTempData = {}
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (tempData.mapCharacterTempData).skillInfo = {}
  local stData = (NovaAPI.DecodeJointDrillDataCompressed)(sData)
  local nCount = (stData.skillInfo).Count
  for index = 0, nCount - 1 do
    local stSkill = (stData.skillInfo)[index]
    ;
    (table.insert)((tempData.mapCharacterTempData).skillInfo, {nCharId = stSkill.nCharId, nSkillId = stSkill.nSkillId, nCd = stSkill.nCd, nSectionAmount = stSkill.nSectionAmount, nSectionResumeTime = stSkill.nSectionResumeTime, nUseTimeHint = stSkill.nUseTimeHint, nEnergy = stSkill.nEnergy})
  end
  local nCharCount = (stData.characterInfo).Count
  for index = 0, nCharCount - 1 do
    local stChar = (stData.characterInfo)[index]
    local nCharId = stChar.nCharId
    local nHp = stChar.nHp
    -- DECOMPILER ERROR at PC57: Confused about usage of register: R12 in 'UnsetPending'

    if (tempData.mapCharacterTempData).hpInfo == nil then
      (tempData.mapCharacterTempData).hpInfo = {}
    end
    -- DECOMPILER ERROR at PC60: Confused about usage of register: R12 in 'UnsetPending'

    ;
    ((tempData.mapCharacterTempData).hpInfo)[nCharId] = nHp
    local nEffectCount = (stChar.tbEffect).Count
    -- DECOMPILER ERROR at PC69: Confused about usage of register: R13 in 'UnsetPending'

    if (tempData.mapCharacterTempData).effectInfo == nil then
      (tempData.mapCharacterTempData).effectInfo = {}
    end
    -- DECOMPILER ERROR at PC80: Confused about usage of register: R13 in 'UnsetPending'

    if ((tempData.mapCharacterTempData).effectInfo)[nCharId] == nil then
      ((tempData.mapCharacterTempData).effectInfo)[nCharId] = {
mapEffect = {}
}
    end
    for e = 0, nEffectCount - 1 do
      local stEffect = (stChar.tbEffect)[e]
      -- DECOMPILER ERROR at PC97: Confused about usage of register: R18 in 'UnsetPending'

      ;
      ((((tempData.mapCharacterTempData).effectInfo)[nCharId]).mapEffect)[stEffect.nId] = {nCount = stEffect.nCount, nCd = stEffect.nCd}
    end
    local nBuffCount = (stChar.tbBuff).Count
    -- DECOMPILER ERROR at PC107: Confused about usage of register: R14 in 'UnsetPending'

    if (tempData.mapCharacterTempData).buffInfo == nil then
      (tempData.mapCharacterTempData).buffInfo = {}
    end
    -- DECOMPILER ERROR at PC116: Confused about usage of register: R14 in 'UnsetPending'

    if ((tempData.mapCharacterTempData).buffInfo)[nCharId] == nil then
      ((tempData.mapCharacterTempData).buffInfo)[nCharId] = {}
    end
    for b = 0, nBuffCount - 1 do
      local stBuff = (stChar.tbBuff)[b]
      ;
      (table.insert)(((tempData.mapCharacterTempData).buffInfo)[nCharId], {Id = stBuff.Id, CD = stBuff.CD, nNum = stBuff.nNum})
    end
    -- DECOMPILER ERROR at PC146: Confused about usage of register: R14 in 'UnsetPending'

    if stChar.stateInfo ~= nil then
      if (tempData.mapCharacterTempData).stateInfo == nil then
        (tempData.mapCharacterTempData).stateInfo = {}
      end
      -- DECOMPILER ERROR at PC157: Confused about usage of register: R14 in 'UnsetPending'

      ;
      ((tempData.mapCharacterTempData).stateInfo)[nCharId] = {jsonStr = "", nState = (stChar.stateInfo).nState, nStateTime = (stChar.stateInfo).nStateTime}
    end
    -- DECOMPILER ERROR at PC167: Confused about usage of register: R14 in 'UnsetPending'

    if stChar.ammoInfo ~= nil then
      if (tempData.mapCharacterTempData).ammoInfo == nil then
        (tempData.mapCharacterTempData).ammoInfo = {}
      end
      -- DECOMPILER ERROR at PC192: Confused about usage of register: R14 in 'UnsetPending'

      ;
      ((tempData.mapCharacterTempData).ammoInfo)[nCharId] = {nCurAmmo = (stChar.ammoInfo).nCurAmmo, nAmmo1 = (stChar.ammoInfo).nAmmo1, nAmmo2 = (stChar.ammoInfo).nAmmo2, nAmmo3 = (stChar.ammoInfo).nAmmo3, nAmmoMax1 = (stChar.ammoInfo).nAmmoMax1, nAmmoMax2 = (stChar.ammoInfo).nAmmoMax2, nAmmoMax3 = (stChar.ammoInfo).nAmmoMax3}
    end
  end
  -- DECOMPILER ERROR at PC203: Confused about usage of register: R5 in 'UnsetPending'

  if stData.summonMonsterInfo ~= nil and (tempData.mapCharacterTempData).sommonInfo == nil then
    (tempData.mapCharacterTempData).sommonInfo = stData.summonMonsterInfo
  end
  tempData.mapBossTempData = stData.bossInfo
  return tempData
end

PlayerJointDrillData.EncodeTempDataJson = function(self, mapData)
  -- function num : 0_5 , upvalues : EncodeTempDataJson
  return EncodeTempDataJson(mapData)
end

PlayerJointDrillData.DecodeTempDataJson = function(self)
  -- function num : 0_6 , upvalues : DecodeTempDataJson
  if self.record ~= nil then
    return DecodeTempDataJson(self.record)
  end
end

PlayerJointDrillData.CacheJointDrillData = function(self, nActId, msgData)
  -- function num : 0_7
  self.nActId = nActId
  self.tbPassedLevels = msgData.PassedLevels
  if (msgData.Meta).LevelId == 0 then
    self.bInBattle = msgData.Meta == nil
    self.nCurLevelId = (msgData.Meta).LevelId
    self.nCurLevel = (msgData.Meta).Floor
    -- DECOMPILER ERROR at PC22: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self.mapBossInfo).nHp = (msgData.Meta).BossHP
    -- DECOMPILER ERROR at PC26: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self.mapBossInfo).nHpMax = (msgData.Meta).BossHPMax
    self.nStartTime = (msgData.Meta).StartTime
    self.record = (msgData.Meta).Record
    self.tbTeams = (msgData.Meta).Teams
    self.bSimulate = (msgData.Meta).Simulate
    self._EntryTime = (msgData.Meta).StartTime
    if self.bInBattle then
      self:StartChallengeTime()
    else
      self:ChallengeEnd()
    end
    self.nTotalScore = (msgData.Meta).TotalScore
    if msgData.Quests ~= nil then
      self.tbQuests = msgData.Quests
    end
    self:RefreshJointDrillQuestRedDot()
    self:StartActTimer()
    -- DECOMPILER ERROR: 5 unprocessed JMP targets
  end
end

PlayerJointDrillData.CheckPassedId = function(self, nLevelId)
  -- function num : 0_8 , upvalues : _ENV
  if self.tbPassedLevels ~= nil then
    for _,v in ipairs(self.tbPassedLevels) do
      if v.LevelId == nLevelId then
        return true
      end
    end
  end
  do
    return false
  end
end

PlayerJointDrillData.IsJointDrillUnlock = function(self, nLevelId)
  -- function num : 0_9 , upvalues : _ENV
  local mapLevelCfg = (ConfigTable.GetData)("JointDrillLevel", nLevelId)
  if mapLevelCfg == nil then
    return false
  end
  local nPreLevelId = mapLevelCfg.PreLevelId
  if nPreLevelId == 0 then
    return true
  end
  return self:CheckPassedId(nPreLevelId)
end

PlayerJointDrillData.GetMonsterMaxHp = function(self, nMonsterId, nDifficulty)
  -- function num : 0_10 , upvalues : _ENV, ConfigData
  local nMaxHp = 0
  local mapMonsterCfg = (ConfigTable.GetData)("Monster", nMonsterId)
  if mapMonsterCfg == nil then
    return 0
  end
  local mapAdjustCfg = (ConfigTable.GetData)("MonsterValueTempleteAdjust", mapMonsterCfg.Templete)
  if mapAdjustCfg == nil then
    return 0
  end
  local mapCfgList = (CacheTable.GetData)("_MonsterValueTemplete", mapAdjustCfg.TemplateId)
  if mapCfgList == nil then
    return 0
  end
  local mapCfg = mapCfgList[nDifficulty]
  if mapCfg == nil then
    return 0
  end
  local nValue = mapCfg.Hp
  local nRatio = mapAdjustCfg.HpRatio
  local nFix = mapAdjustCfg.HpFix
  nMaxHp = (math.floor)(nValue * (1 + nRatio * ConfigData.IntFloatPrecision) + nFix)
  return nMaxHp
end

PlayerJointDrillData.GetMonsterName = function(self, nMonsterId)
  -- function num : 0_11 , upvalues : _ENV
  local mapMonsterCfg = (ConfigTable.GetData)("Monster", nMonsterId)
  if mapMonsterCfg ~= nil then
    local nSkinId = mapMonsterCfg.FAId
    local mapSkinCfg = (ConfigTable.GetData)("MonsterSkin", nSkinId)
    if mapSkinCfg ~= nil then
      local nManualId = mapSkinCfg.MonsterManual
      local mapManualCfg = (ConfigTable.GetData)("MonsterManual", nManualId)
      if mapManualCfg ~= nil then
        return mapManualCfg.Name
      end
    end
  end
  do
    return ""
  end
end

PlayerJointDrillData.StartChallengeTime = function(self)
  -- function num : 0_12 , upvalues : _ENV, TimerManager
  if self.challengeTimer ~= nil then
    (self.challengeTimer):Cancel()
    self.challengeTimer = nil
  end
  local nOpenTime = self.nStartTime
  local refreshTime = function()
    -- function num : 0_12_0 , upvalues : _ENV, self, nOpenTime
    local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
    local nTime = self.nMaxChallengeTime - (nCurTime - nOpenTime)
    if nTime >= 0 then
      (EventManager.Hit)("RefreshChallengeTime", nTime)
    end
    return nTime
  end

  local nTime = refreshTime()
  if nTime > 0 then
    self.challengeTimer = (TimerManager.Add)(0, 1, nil, function()
    -- function num : 0_12_1 , upvalues : refreshTime, self
    local nTime = refreshTime()
    if nTime <= 0 then
      (self.challengeTimer):Cancel()
      self.challengeTimer = nil
      if self.curLevel ~= nil then
        (self.curLevel):JointDrillTimeOut()
      end
    end
  end
, true, true, true)
  end
end

PlayerJointDrillData.StartActTimer = function(self)
  -- function num : 0_13 , upvalues : _ENV, ClientManager, TimerManager
  if self.actTimer ~= nil then
    (self.actTimer):Cancel()
    self.actTimer = nil
  end
  local actData = (PlayerData.Activity):GetActivityDataById(self.nActId)
  if actData ~= nil then
    local nChallengeStartTime = actData:GetChallengeStartTime()
    do
      local nChallengeEndTime = actData:GetChallengeEndTime()
      local nActEndTime = actData:GetActCloseTime()
      self.nActStatus = 0
      local refreshTime = function()
    -- function num : 0_13_0 , upvalues : ClientManager, nChallengeStartTime, self, _ENV, nChallengeEndTime, nActEndTime
    local nRemainTime = 0
    local nCurTime = ClientManager.serverTimeStamp
    if nCurTime < nChallengeStartTime then
      self.nActStatus = (AllEnum.JointDrillActStatus).WaitStart
      nRemainTime = nChallengeStartTime - nCurTime
    else
      if nCurTime <= nChallengeEndTime then
        self.nActStatus = (AllEnum.JointDrillActStatus).Start
        nRemainTime = nChallengeEndTime - nCurTime
      else
        if nChallengeEndTime < nCurTime and nCurTime < nActEndTime then
          self.nActStatus = (AllEnum.JointDrillActStatus).WaitClose
          nRemainTime = nActEndTime - nCurTime
        else
          if nActEndTime <= nCurTime then
            self.nActStatus = (AllEnum.JointDrillActStatus).Closed
            nRemainTime = 0
          end
        end
      end
    end
    ;
    (EventManager.Hit)("RefreshJointDrillActTime", self.nActStatus, nRemainTime)
    if nRemainTime <= 0 and self.actTimer ~= nil and self.nActStatus == (AllEnum.JointDrillActStatus).Closed then
      (self.actTimer):Cancel()
      self.actTimer = nil
      return 
    end
  end

      refreshTime()
      if self.actTimer == nil then
        self.actTimer = (TimerManager.Add)(0, 1, nil, refreshTime, true, true, true)
      end
    end
  end
end

PlayerJointDrillData.RefreshJointDrillQuestRedDot = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local bHasReward = false
  for _,v in ipairs(self.tbQuests) do
    if v.Status == 1 then
      bHasReward = true
      break
    end
  end
  do
    ;
    (RedDotManager.SetValid)(RedDotDefine.JointDrillQuest, nil, bHasReward)
  end
end

PlayerJointDrillData.EnterJointDrill = function(self, nLevelId, nBuildId, bSimulate, bChangeLevel, nCurLevel)
  -- function num : 0_15 , upvalues : _ENV, DecodeTempDataJson, LocalData
  local mapLevelCfg = (ConfigTable.GetData)("JointDrillLevel", nLevelId)
  if mapLevelCfg == nil then
    printError("找不到总力战关卡数据！！！levelId = " .. tostring(nLevelId))
    return 
  end
  local nHp, nHpMax = 0, 0
  if self.record == nil or self.record == "" then
    nHpMax = self:GetMonsterMaxHp(mapLevelCfg.BossId, mapLevelCfg.Difficulty)
    nHp = nHpMax
  else
    local mapTemp = DecodeTempDataJson(self.record)
    if mapTemp ~= nil and mapTemp.mapBossTempData ~= nil and (mapTemp.mapBossTempData).nBossId ~= 0 then
      nHpMax = (mapTemp.mapBossTempData).nHpMax
      nHp = (mapTemp.mapBossTempData).nHp
    end
  end
  do
    if nHpMax == 0 then
      printError((string.format)("[总力战]获取boss血量失败！！！ levelId = %s, bossId = %s", nLevelId, mapLevelCfg.BossId))
      return 
    end
    local enterLevel = function(mapNetData)
    -- function num : 0_15_0 , upvalues : self, _ENV, nLevelId, bSimulate, nHp, nHpMax, nCurLevel, LocalData, nBuildId, bChangeLevel
    do
      if self.curLevel == nil then
        local luaClass = require("Game.Adventure.JointDrill.JointDrillLevelData")
        if luaClass == nil then
          return 
        end
        self.curLevel = luaClass
        if type((self.curLevel).BindEvent) == "function" then
          (self.curLevel):BindEvent()
        end
      end
      self.nCurLevelId = nLevelId
      self.bInBattle = true
      self.bSimulate = bSimulate
      self.mapBossInfo = {}
      -- DECOMPILER ERROR at PC28: Confused about usage of register: R1 in 'UnsetPending'

      ;
      (self.mapBossInfo).nHp = nHp
      -- DECOMPILER ERROR at PC31: Confused about usage of register: R1 in 'UnsetPending'

      ;
      (self.mapBossInfo).nHpMax = nHpMax
      if nCurLevel == nil then
        nCurLevel = self.nCurLevel
      end
      if mapNetData ~= nil then
        self.nStartTime = mapNetData.StarTime
        self._EntryTime = mapNetData.StarTime
        local sKey = (LocalData.GetPlayerLocalData)("JointDrillRecordKey") or ""
        if sKey ~= nil and sKey ~= "" then
          (NovaAPI.DeleteRecFile)(sKey)
        end
        sKey = tostring(mapNetData.StarTime)
        ;
        (LocalData.SetPlayerLocalData)("JointDrillRecordKey", sKey)
        ;
        (LocalData.SetPlayerLocalData)("JointDrillRecordFloorId", 0)
        ;
        (LocalData.SetPlayerLocalData)("JointDrillRecordExcludeId", 0)
        self:EventUpload(1)
      end
      do
        self:StartChallengeTime()
        if type((self.curLevel).Init) == "function" then
          (self.curLevel):Init(self, nLevelId, nBuildId, nCurLevel, bChangeLevel)
        end
      end
    end
  end

    local netCallback = function(_, netMsg)
    -- function num : 0_15_1 , upvalues : enterLevel
    enterLevel(netMsg)
  end

    if self.bInBattle and not bChangeLevel then
      self:ContinueJointDrill(nBuildId, enterLevel)
    else
      if not bChangeLevel then
        local msg = {LevelId = nLevelId, BuildId = nBuildId, BossHp = nHp, BossHpMax = nHpMax, Simulate = bSimulate}
        ;
        (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_apply_req, msg, nil, netCallback)
      else
        do
          enterLevel()
        end
      end
    end
  end
end

PlayerJointDrillData.ChangeLevel = function(self, nLevel)
  -- function num : 0_16
  self:EnterJointDrill(self.nCurLevelId, self.nSelectBuildId, self.bSimulate, true, nLevel)
end

PlayerJointDrillData.RestartBattle = function(self)
  -- function num : 0_17
  self:EnterJointDrill(self.nCurLevelId, self.nSelectBuildId, self.bSimulate, true, self.nCurLevel)
end

PlayerJointDrillData.ContinueJointDrill = function(self, nBuildId, callback)
  -- function num : 0_18 , upvalues : LocalData, _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_18_0 , upvalues : LocalData, _ENV, self, callback
    local sKey = (LocalData.GetPlayerLocalData)("JointDrillRecordKey") or ""
    if sKey == "" or sKey ~= tostring(self.nStartTime) then
      if sKey ~= "" then
        (NovaAPI.DeleteRecFile)(sKey)
      end
      sKey = tostring(self.nStartTime)
      ;
      (LocalData.SetPlayerLocalData)("JointDrillRecordKey", self.nStartTime)
    end
    if callback ~= nil then
      callback()
    end
  end

  local msg = {BuildId = nBuildId}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_continue_req, msg, nil, NetCallback)
end

PlayerJointDrillData.JointDrillGameOver = function(self, callback, bSettle)
  -- function num : 0_19 , upvalues : ClientManager, _ENV
  self:SetRecorderExcludeIds()
  self:StopRecord()
  self._EndTime = ClientManager.serverTimeStamp
  local NetCallback = function(_, netMsg)
    -- function num : 0_19_0 , upvalues : self, _ENV, callback, bSettle
    local nScoreOld = 0
    if self.mapSelfRankData ~= nil then
      nScoreOld = (self.mapSelfRankData).Score
    end
    if netMsg.Old ~= netMsg.New then
      self:SendJointDrillRankMsg()
    end
    self:UploadRecordFile(netMsg.Token)
    if not self.bSimulate then
      self.nTotalScore = self.nTotalScore + netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
    end
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.JointDrillBuildList)
    ;
    (EventManager.Hit)("RefreshJointDrillLevel")
    if callback ~= nil then
      callback(netMsg)
    end
    if bSettle then
      local nResultType = (AllEnum.JointDrillResultType).ChallengeEnd
      local mapScore = {}
      local nTotalScore = (PlayerData.JointDrill):GetTotalRankScore()
      local mapChange, mapItems = {}, {}
      local nOld, nNew = 0, 0
      if netMsg ~= nil then
        if not netMsg.Change then
          mapChange = {}
        end
        if not netMsg.Items then
          mapItems = {}
        end
        local nScore = netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
        mapScore = {FightScore = netMsg.FightScore, HpScore = netMsg.HpScore, DifficultyScore = netMsg.DifficultyScore, nTotalScore = nTotalScore, nScore = nScore, nScoreOld = nScoreOld}
        nOld = netMsg.Old
        nNew = netMsg.New
      end
      do
        do
          ;
          (EventManager.Hit)(EventId.OpenPanel, PanelId.JointDrillResult, nResultType, self.nCurLevel, 0, self.nCurLevelId, self.mapBossInfo, mapScore, mapItems, mapChange, nOld, nNew, self.bSimulate, #self.tbTeams)
          self:EventUpload(4, 0)
          self:ChallengeEnd()
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_game_over_req, {}, nil, NetCallback)
end

PlayerJointDrillData.JointDrillGiveUp = function(self, nFloor, nTime, nDamage, nBossHp, sRecord, mapBuild, callback)
  -- function num : 0_20 , upvalues : _ENV
  self:SetRecorderExcludeIds()
  self:StopRecord()
  local NetCallback = function(_, netMsg)
    -- function num : 0_20_0 , upvalues : self, sRecord, nFloor, nBossHp, callback
    self.record = sRecord
    self.nCurLevel = nFloor
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.mapBossInfo).nHp = nBossHp
    if callback ~= nil then
      callback(netMsg)
    end
    if netMsg.Old ~= netMsg.New then
      self:SendJointDrillRankMsg()
    end
  end

  local msg = {Floor = nFloor, Time = nTime, Damage = nDamage, BossHp = nBossHp, Record = sRecord}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_give_up_req, msg, nil, NetCallback)
end

PlayerJointDrillData.JointDrillRetreat = function(self, mapBuild, callback)
  -- function num : 0_21 , upvalues : _ENV
  self:SetRecorderExcludeIds(true)
  self:StopRecord()
  local NetCallback = function(_, netMsg)
    -- function num : 0_21_0 , upvalues : self, mapBuild, callback
    self:RemoveJointDrillTeam(mapBuild)
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_retreat_req, {}, nil, NetCallback)
end

PlayerJointDrillData.JointDrillSettle = function(self, mapBuild, nTime, nDamage, callback)
  -- function num : 0_22 , upvalues : ClientManager, _ENV, LocalData
  self:SetRecorderExcludeIds()
  self:StopRecord()
  self:AddJointDrillTeam(mapBuild, nTime, nDamage)
  self._EndTime = ClientManager.serverTimeStamp
  local NetCallback = function(_, netMsg)
    -- function num : 0_22_0 , upvalues : self, _ENV, callback
    self:UploadRecordFile(netMsg.Token)
    do
      if not self.bSimulate then
        local nScore = netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
        self.nTotalScore = self.nTotalScore + nScore
        ;
        (table.insert)(self.tbPassedLevels, {LevelId = self.nCurLevelId, Score = nScore})
      end
      ;
      (EventManager.Hit)(EventId.ClosePanel, PanelId.JointDrillBuildList)
      if callback ~= nil then
        callback(netMsg)
      end
      if netMsg.Old ~= netMsg.New then
        self:SendJointDrillRankMsg()
      end
      self:EventUpload(4, 1)
    end
  end

  local tbSamples = (UTILS.GetBattleSamples)()
  local sKey = (LocalData.GetPlayerLocalData)("JointDrillRecordKey") or ""
  local bSuccess, nCheckSum = (NovaAPI.GetRecorderKey)(sKey)
  local tbSendSample = {Sample = tbSamples, Checksum = nCheckSum}
  local msg = {Time = nTime, Damage = nDamage, sample = tbSendSample, 
Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).JointDrill, true)}
}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_settle_req, msg, nil, NetCallback)
end

PlayerJointDrillData.JointDrillSync = function(self, nFloor, nTime, nDamage, nBossHp, nBossHpMax, sRecord, callback)
  -- function num : 0_23 , upvalues : _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_23_0 , upvalues : self, sRecord, nBossHp, nBossHpMax, callback
    self.record = sRecord
    -- DECOMPILER ERROR at PC4: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.mapBossInfo).nHp = nBossHp
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.mapBossInfo).nHpMax = nBossHpMax
    if callback ~= nil then
      callback()
    end
  end

  local msg = {Floor = nFloor, Time = nTime, Damage = nDamage, BossHp = nBossHp, BossHpMax = nBossHpMax, Record = sRecord}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_sync_req, msg, nil, NetCallback)
end

PlayerJointDrillData.LevelEnd = function(self, nType)
  -- function num : 0_24 , upvalues : _ENV
  if self.curLevel ~= nil and type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
  self.nGameTime = 0
  if nType ~= (AllEnum.JointDrillResultType).Retreat then
    self.nSelectBuildId = 0
  end
end

PlayerJointDrillData.ChallengeEnd = function(self)
  -- function num : 0_25 , upvalues : _ENV
  if self.curLevel ~= nil and type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.bInBattle = false
  self.curLevel = nil
  self.nCurLevelId = 0
  self.nCurLevel = 1
  self.nStartTime = 0
  self.nGameTime = 0
  self.bSimulate = false
  self.record = nil
  self.tbTeams = {}
  self.nSelectBuildId = 0
  self.tbRecordFloors = {}
  if self.challengeTimer ~= nil then
    (self.challengeTimer):Cancel()
    self.challengeTimer = nil
  end
  self._EntryTime = 0
  self._EndTime = 0
end

PlayerJointDrillData.ResetRecord = function(self, sRecord)
  -- function num : 0_26
  self.record = sRecord
end

PlayerJointDrillData.GetJointDrillLevelId = function(self)
  -- function num : 0_27
  return self.nCurLevelId
end

PlayerJointDrillData.GetJointDrillCurLevel = function(self)
  -- function num : 0_28
  return self.nCurLevel
end

PlayerJointDrillData.GetJointDrillStartTime = function(self)
  -- function num : 0_29
  return self.nStartTime
end

PlayerJointDrillData.GetJointDrillBossInfo = function(self)
  -- function num : 0_30
  return self.mapBossInfo
end

PlayerJointDrillData.GetJointDrillBuildList = function(self)
  -- function num : 0_31
  return self.tbTeams
end

PlayerJointDrillData.GetJointDrillBattleCount = function(self)
  -- function num : 0_32
  return #self.tbTeams
end

PlayerJointDrillData.CheckChallengeCount = function(self)
  -- function num : 0_33 , upvalues : _ENV
  do
    if self.nCurLevelId ~= 0 then
      local mapLevelCfg = (ConfigTable.GetData)("JointDrillLevel", self.nCurLevelId)
      if mapLevelCfg ~= nil then
        if #self.tbTeams < mapLevelCfg.MaxBattleNum then
          return true
        else
          ;
          (EventManager.Hit)(EventId.ClosePanel, PanelId.JointDrillBuildList)
          self:JointDrillGameOver()
          return false
        end
      end
      return false
    end
    return true
  end
end

PlayerJointDrillData.CheckJointDrillInBattle = function(self)
  -- function num : 0_34
  return self.bInBattle
end

PlayerJointDrillData.GetMaxChallengeCount = function(self, nLevelId)
  -- function num : 0_35 , upvalues : _ENV
  local mapLevelCfg = (ConfigTable.GetData)("JointDrillLevel", nLevelId)
  if mapLevelCfg ~= nil then
    return mapLevelCfg.MaxBattleNum
  end
  return 0
end

PlayerJointDrillData.SetSelBuildId = function(self, nBuildId)
  -- function num : 0_36
  self.nSelectBuildId = nBuildId
end

PlayerJointDrillData.GetCachedBuild = function(self)
  -- function num : 0_37
  return self.nSelectBuildId
end

PlayerJointDrillData.GetBossHpBarNum = function(self)
  -- function num : 0_38 , upvalues : _ENV
  do
    if self.nCurLevelId ~= nil then
      local mapCfg = (ConfigTable.GetData)("JointDrillLevel", self.nCurLevelId)
      if mapCfg ~= nil then
        return mapCfg.HpBarNum
      end
    end
    return 40
  end
end

PlayerJointDrillData.AddJointDrillTeam = function(self, mapBuildData, nTime, nDamage)
  -- function num : 0_39 , upvalues : _ENV
  local bInsert = false
  for _,v in ipairs(self.tbTeams) do
    if v.BuildId == mapBuildData.nBuildId then
      bInsert = true
      v.Damage = nDamage
      v.Time = nTime
      break
    end
  end
  do
    if not bInsert then
      local tbChar = {}
      for _,mapChar in ipairs(mapBuildData.tbChar) do
        local nCharId = mapChar.nTid
        local nLv = (PlayerData.Char):GetCharLv(nCharId)
        ;
        (table.insert)(tbChar, {CharId = nCharId, CharLevel = nLv})
      end
      local teamData = {Chars = tbChar, BuildScore = mapBuildData.nScore, Damage = nDamage, Time = nTime, BuildId = mapBuildData.nBuildId}
      ;
      (table.insert)(self.tbTeams, teamData)
    end
  end
end

PlayerJointDrillData.RemoveJointDrillTeam = function(self, mapBuildData)
  -- function num : 0_40 , upvalues : _ENV
  local nIndex = 0
  for k,v in ipairs(self.tbTeams) do
    if v.BuildId == mapBuildData.nBuildId then
      nIndex = k
      break
    end
  end
  do
    if nIndex ~= 0 then
      (table.remove)(self.tbTeams, nIndex)
    end
  end
end

PlayerJointDrillData.SetGameTime = function(self, nTime)
  -- function num : 0_41
  self.nGameTime = nTime
end

PlayerJointDrillData.GetGameTime = function(self)
  -- function num : 0_42
  return self.nGameTime
end

PlayerJointDrillData.GetBattleSimulate = function(self)
  -- function num : 0_43
  return self.bSimulate
end

PlayerJointDrillData.AddRecordFloorList = function(self)
  -- function num : 0_44 , upvalues : LocalData, _ENV
  local nValue = (LocalData.GetPlayerLocalData)("JointDrillRecordFloorId") or 0
  nValue = nValue + 1
  ;
  (table.insert)(self.tbRecordFloors, nValue)
  ;
  (LocalData.SetPlayerLocalData)("JointDrillRecordFloorId", nValue)
  ;
  (NovaAPI.SetRecorderFloorId)(nValue)
end

PlayerJointDrillData.AddRecordExcludeId = function(self, nId)
  -- function num : 0_45 , upvalues : LocalData
  local nValue = (LocalData.GetPlayerLocalData)("JointDrillRecordExcludeId") or 0
  nValue = 1 << nId - 1 | nValue
  ;
  (LocalData.SetPlayerLocalData)("JointDrillRecordExcludeId", nValue)
end

PlayerJointDrillData.SetRecorderExcludeIds = function(self, bRemove)
  -- function num : 0_46 , upvalues : ListInt, _ENV, LocalData
  local tbFloorId = ListInt()
  if bRemove then
    for _,v in ipairs(self.tbRecordFloors) do
      self:AddRecordExcludeId(v)
    end
  end
  do
    local nExcludeValue = (LocalData.GetPlayerLocalData)("JointDrillRecordExcludeId") or 0
    if nExcludeValue > 0 then
      local tbTemp = {}
      while nExcludeValue > 0 do
        (table.insert)(tbTemp, 1, nExcludeValue % 2)
        nExcludeValue = (math.floor)(nExcludeValue / 2)
      end
      printTable(tbTemp)
      for k,v in ipairs(tbTemp) do
        if v == 1 then
          tbFloorId:Add(#tbTemp - k + 1)
        end
      end
    end
    do
      self.tbRecordFloors = {}
      ;
      (NovaAPI.SetRecorderExcludeIds)(tbFloorId)
    end
  end
end

PlayerJointDrillData.StopRecord = function(self)
  -- function num : 0_47 , upvalues : _ENV
  (NovaAPI.StopRecord)()
end

PlayerJointDrillData.UploadRecordFile = function(self, sToken)
  -- function num : 0_48 , upvalues : LocalData, _ENV
  local sKey = (LocalData.GetPlayerLocalData)("JointDrillRecordKey") or ""
  if sKey ~= nil and sKey ~= "" then
    if sToken ~= nil and sToken ~= "" then
      (NovaAPI.UploadStartowerFile)(sToken, sKey)
    else
      ;
      (NovaAPI.DeleteRecFile)(sKey)
    end
  end
  ;
  (LocalData.SetPlayerLocalData)("JointDrillRecordKey", "")
end

PlayerJointDrillData.CheckActChallengeTime = function(self)
  -- function num : 0_49 , upvalues : _ENV, ClientManager
  local actData = (PlayerData.Activity):GetActivityDataById(self.nActId)
  if actData ~= nil then
    local nChallengeEndTime = actData:GetChallengeEndTime()
    local nCurTime = ClientManager.serverTimeStamp
    if nChallengeEndTime <= nCurTime then
      return false
    end
    return true
  end
  do
    return false
  end
end

PlayerJointDrillData.GetActStatus = function(self)
  -- function num : 0_50
  return self.nActStatus
end

PlayerJointDrillData.SendJointDrillRankMsg = function(self)
  -- function num : 0_51 , upvalues : _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_51_0 , upvalues : self, _ENV
    self.nLastRefreshRankTime = netMsg.LastRefreshTime
    self.mapSelfRankData = netMsg.Self
    self.mapRankList = netMsg.Rank
    self.nTotalRank = netMsg.Total or 0
    ;
    (EventManager.Hit)("GetJointDrillRankSuc")
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_rank_req, {}, nil, NetCallback)
end

PlayerJointDrillData.GetSelfRankData = function(self)
  -- function num : 0_52
  return self.mapSelfRankData
end

PlayerJointDrillData.GetRankList = function(self)
  -- function num : 0_53
  return self.mapRankList
end

PlayerJointDrillData.GetRankRewardCount = function(self)
  -- function num : 0_54
  return self.nRankCount
end

PlayerJointDrillData.GetTotalRankCount = function(self)
  -- function num : 0_55
  return self.nTotalRank
end

PlayerJointDrillData.GetLastRankRefreshTime = function(self)
  -- function num : 0_56
  return self.nLastRefreshRankTime, self.nRankingRefreshTime
end

PlayerJointDrillData.GetTotalRankScore = function(self)
  -- function num : 0_57
  return self.nTotalScore
end

PlayerJointDrillData.SendJointDrillSweepMsg = function(self, nLevelId, nCount, callback)
  -- function num : 0_58 , upvalues : _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_58_0 , upvalues : _ENV, callback, self
    (EventManager.Hit)("JointDrillRaidSuccess", netMsg)
    if callback ~= nil then
      callback(netMsg)
    end
    self.nTotalScore = netMsg.Score
    self:EventUpload(5)
  end

  local msg = {LevelId = nLevelId, Count = nCount}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_sweep_req, msg, nil, NetCallback)
end

PlayerJointDrillData.SendReceiveQuestReward = function(self, callback)
  -- function num : 0_59 , upvalues : _ENV
  local NetCallback = function(_, netMsg)
    -- function num : 0_59_0 , upvalues : _ENV, callback
    (UTILS.OpenReceiveByChangeInfo)(netMsg, function()
      -- function num : 0_59_0_0 , upvalues : callback
      if callback ~= nil then
        callback()
      end
    end
)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).joint_drill_quest_reward_receive_req, {}, nil, NetCallback)
end

PlayerJointDrillData.RefreshQuestData = function(self, questData)
  -- function num : 0_60 , upvalues : _ENV
  local bHasData = false
  for k,v in ipairs(self.tbQuests) do
    -- DECOMPILER ERROR at PC10: Confused about usage of register: R8 in 'UnsetPending'

    if v.Id == questData.Id then
      (self.tbQuests)[k] = questData
      bHasData = true
      break
    end
  end
  do
    if not bHasData then
      (table.insert)(self.tbQuests, questData)
    end
    self:RefreshJointDrillQuestRedDot()
  end
end

PlayerJointDrillData.GetRewardQuestList = function(self)
  -- function num : 0_61 , upvalues : _ENV
  local tbQuests = {}
  for _,v in ipairs(self.tbQuests) do
    local nSortStatus = 0
    if v.Status == 0 then
      nSortStatus = 1
    else
      if v.Status == 1 then
        nSortStatus = 0
      else
        if v.Status == 2 then
          nSortStatus = 2
        end
      end
    end
    v.SortStatus = nSortStatus
    ;
    (table.insert)(tbQuests, v)
  end
  return tbQuests
end

PlayerJointDrillData.EventUpload = function(self, action, result)
  -- function num : 0_62 , upvalues : _ENV
  if not result then
    result = ""
  end
  local nCostTime = 0
  if action == 4 then
    nCostTime = self._EndTime - self._EntryTime
  end
  local tabUpLevel = {}
  ;
  (table.insert)(tabUpLevel, {"action", tostring(action)})
  ;
  (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (table.insert)(tabUpLevel, {"game_cost_time", tostring(nCostTime)})
  ;
  (table.insert)(tabUpLevel, {"battle_id", tostring(self.nCurLevelId)})
  ;
  (table.insert)(tabUpLevel, {"battle_result", tostring(result)})
  ;
  (table.insert)(tabUpLevel, {"team_num", tostring(#self.tbTeams)})
  ;
  (table.insert)(tabUpLevel, {"simulate", tostring(self.bSimulate and 1 or 0)})
  ;
  (NovaAPI.UserEventUpload)("joint_drill_battle", tabUpLevel)
end

return PlayerJointDrillData

