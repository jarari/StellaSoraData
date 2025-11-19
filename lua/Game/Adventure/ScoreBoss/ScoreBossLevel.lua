local ScoreBossLevel = class("ScoreBossLevel")
local LocalData = require("GameCore.Data.LocalData")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", BattlePause = "OnEvent_Pause", [EventId.AbandonBattle] = "OnEvent_AbandonBattle", ScoreBossLevelGameEnd = "OnEvent_LevelResult", BossRush_Spawn_Id = "OnEvent_BossRushSpawnId", ScoreBoss_Result_Time = "ScoreBossResultTime", LevelStateChanged = "ScoreBossResult", ScoreBoss_BehaviorScore = "OnEvent_ControlScore", ScoreBossSettleSuccess = "OnEvent_ScoreBossSettleSuccess", ScoreBossSettleGiveUp = "OnEvent_ScoreBossSettleGiveUp", Upload_Dodge_Event = "OnEvent_UploadDodgeEvent"}
ScoreBossLevel.Init = function(self, parent, nLevelId, nBuildId)
  -- function num : 0_0 , upvalues : _ENV, LocalData
  self.isSettlement = false
  self.parent = parent
  self.LevelId = nLevelId
  self.tmpBuildId = nBuildId
  self.BossId = 0
  self.BossMaxHp = 0
  self.BossCurLvMinHp = -1
  self.BossCurLvTotalChangeHp = 0
  self.BattleLv = 1
  self.nTime = 0
  local leveData = (ConfigTable.GetData)("ScoreBossLevel", nLevelId)
  if leveData == nil then
    printError("ScoreBossLevel 表不存在 id ==== " .. nLevelId)
    return 
  end
  local getControlData = (ConfigTable.GetData)("ScoreBossGetControl", leveData.NonDamageScoreGet)
  if getControlData == nil then
    printError("ScoreBossGetControl 表不存在 id ==== " .. leveData.NonDamageScoreGet)
    return 
  end
  self.totalControlScore = 0
  self.OnceControlScore = getControlData.OnceScore
  self.MaxControlScore = getControlData.MaxLimit
  self.ScoreBossBehavior = getControlData.ScoreBossBehavior
  self.ScoreGetSwitchGroupId = leveData.ScoreGetSwitchGroup
  self.SwitchRate = 300
  local getSwitchData = (ConfigTable.GetData)("ScoreGetSwitch", self.ScoreGetSwitchGroupId * 1000 + 1)
  if getSwitchData ~= nil then
    self.SwitchRate = getSwitchData.SwitchRate
  end
  local GetBuildCallback = function(mapBuildData)
    -- function num : 0_0_0 , upvalues : self, _ENV, LocalData
    self.mapBuildData = mapBuildData
    self.tbCharId = {}
    for _,mapChar in ipairs((self.mapBuildData).tbChar) do
      (table.insert)(self.tbCharId, mapChar.nTid)
    end
    self.tbDiscId = {}
    for _,nDiscId in ipairs((self.mapBuildData).tbDisc) do
      if nDiscId > 0 then
        (table.insert)(self.tbDiscId, nDiscId)
      end
    end
    self.mapActorInfo = {}
    for idx,nTid in ipairs(self.tbCharId) do
      local stActorInfo = self:CalCharFixedEffect(nTid, idx == 1, self.tbDiscId)
      -- DECOMPILER ERROR at PC47: Confused about usage of register: R7 in 'UnsetPending'

      ;
      (self.mapActorInfo)[nTid] = stActorInfo
    end
    ;
    (self.parent):CacheBuildCharTid(self.tbCharId)
    -- DECOMPILER ERROR at PC58: Confused about usage of register: R1 in 'UnsetPending'

    PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).ScoreBoss
    ;
    ((CS.AdventureModuleHelper).EnterScoreBossFloor)(self.LevelId, self.tbCharId)
    local sKey = (LocalData.GetPlayerLocalData)("ScoreBossRecordKey")
    safe_call_cs_func((CS.AdventureModuleHelper).SetDamageRecordId, sKey)
    ;
    (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

  ;
  (PlayerData.Build):GetBuildDetailData(GetBuildCallback, nBuildId)
end

ScoreBossLevel.CalCharFixedEffect = function(self, nCharId, bMainChar, tbDiscId)
  -- function num : 0_1 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar, tbDiscId, (self.mapBuildData).nBuildId)
  return stActorInfo
end

ScoreBossLevel.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = (PlayerData.Build):GetBuildAllEft((self.mapBuildData).nBuildId)
  safe_call_cs_func((CS.AdventureModuleHelper).SetNoteInfo, tbNoteInfo)
  self.mapEftData = (UTILS.AddBuildEffect)(mapAllEft, mapDiscEft, mapNoteEffect)
  ;
  (PlayerData.Build):SetBuildReportInfo((self.mapBuildData).nBuildId)
end

ScoreBossLevel.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_3 , upvalues : _ENV
  (PlayerData.Achievement):SetSpecialBattleAchievement((GameEnum.levelType).ScoreBoss)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.ScoreBossBattlePanel, self.tbCharId)
  self:SetPersonalPerk()
  self:SetDiscInfo()
  for idx,nCharId in ipairs(self.tbCharId) do
    local stActorInfo = self:CalCharFixedEffect(nCharId, idx == 1, self.tbDiscId)
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

ScoreBossLevel.SetPersonalPerk = function(self)
  -- function num : 0_4 , upvalues : _ENV
  if self.mapBuildData ~= nil then
    for nCharId,tbPerk in pairs((self.mapBuildData).tbPotentials) do
      local mapAddLevel = (PlayerData.Char):GetCharEnhancedPotential(nCharId)
      local tbPerkInfo = {}
      for _,mapPerkInfo in ipairs(tbPerk) do
        local nAddLv = mapAddLevel[mapPerkInfo.nPotentialId] or 0
        local stPerkInfo = (CS.Lua2CSharpInfo_TPPerkInfo)()
        stPerkInfo.perkId = mapPerkInfo.nPotentialId
        stPerkInfo.nCount = mapPerkInfo.nLevel + nAddLv
        ;
        (table.insert)(tbPerkInfo, stPerkInfo)
      end
      safe_call_cs_func((CS.AdventureModuleHelper).ChangePersonalPerkIds, tbPerkInfo, nCharId)
    end
  end
end

ScoreBossLevel.SetDiscInfo = function(self)
  -- function num : 0_5 , upvalues : _ENV
  local tbDiscInfo = {}
  for k,nDiscId in ipairs((self.mapBuildData).tbDisc) do
    if k <= 3 then
      local discInfo = (PlayerData.Disc):CalcDiscInfoInBuild(nDiscId, (self.mapBuildData).tbSecondarySkill)
      ;
      (table.insert)(tbDiscInfo, discInfo)
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetDiscInfo, tbDiscInfo)
end

ScoreBossLevel.OnEvent_Pause = function(self)
  -- function num : 0_6 , upvalues : _ENV
  (EventManager.Hit)("OpenScoreBossPause", self.LevelId, self.tbCharId)
end

ScoreBossLevel.OnEvent_AbandonBattle = function(self)
  -- function num : 0_7
  (self.parent):QuiteLevel()
end

ScoreBossLevel.OnEvent_LevelResult = function(self, tbStar, bAbandon)
  -- function num : 0_8
  (self.parent):LevelEnd()
end

ScoreBossLevel.OnEvent_BossRushSpawnId = function(self, bossId)
  -- function num : 0_9 , upvalues : _ENV
  self.BossId = bossId
  ;
  (EventManager.AddEntityEvent)("HpChanged", self.BossId, self, self.OnEvent_HpChanged)
  ;
  (EventManager.AddEntityEvent)("BossRushMonsterLevelChanged", self.BossId, self, self.OnEvent_BossRushMonsterLevelChanged)
  ;
  (EventManager.AddEntityEvent)("BossRushMonsterBattleAttrChanged", self.BossId, self, self.OnEvent_BossRushMonsterBattleAttrChanged)
end

ScoreBossLevel.OnEvent_HpChanged = function(self, hp, hpMax)
  -- function num : 0_10
  if self.isSettlement then
    return 
  end
  if self.isDontChangeHp then
    return 
  end
  self.BossMaxHp = hpMax
  if self.BossCurLvMinHp == -1 then
    self.BossCurLvMinHp = hp
    ;
    (self.parent):DamageToScore(hpMax - hp, self.SwitchRate, self.BattleLv)
  end
  if hp < self.BossCurLvMinHp then
    self.BossCurLvMinHp = hp
    ;
    (self.parent):DamageToScore(hpMax - hp, self.SwitchRate, self.BattleLv)
  end
end

ScoreBossLevel.OnEvent_BossRushMonsterLevelChanged = function(self, oldLevel, battleLevel)
  -- function num : 0_11 , upvalues : _ENV
  if self.isSettlement then
    return 
  end
  self.isDontChangeHp = true
  self.BossCurLvTotalChangeHp = self.BossCurLvTotalChangeHp + self.BossCurLvMinHp
  self.BossCurLvMinHp = -1
  self.BattleLv = battleLevel
  ;
  (self.parent):DamageToScore(self.BossMaxHp, self.SwitchRate, self.BattleLv)
  self.BossCurLvTotalChangeHp = 0
  do
    if battleLevel <= 100 then
      local getSwitchData = (ConfigTable.GetData)("ScoreGetSwitch", self.ScoreGetSwitchGroupId * 1000 + battleLevel)
      if getSwitchData ~= nil then
        self.SwitchRate = getSwitchData.SwitchRate
      end
    end
    ;
    (self.parent):HPLevelChanged()
  end
end

ScoreBossLevel.OnEvent_BossRushMonsterBattleAttrChanged = function(self)
  -- function num : 0_12
  self.isDontChangeHp = false
end

ScoreBossLevel.ScoreBossResultTime = function(self, nTime)
  -- function num : 0_13
  self.nTime = nTime
end

ScoreBossLevel.ScoreBossResult = function(self, levelState, totalTime)
  -- function num : 0_14
  if self.isSettlement then
    return 
  end
  self.isSettlement = true
  ;
  (self.parent):SendScoreBossSettleReq(self.nTime)
end

ScoreBossLevel.PlaySuccessPerform = function(self, entryLevelId, totalScore, totalStar)
  -- function num : 0_15 , upvalues : _ENV
  local tbChar = {}
  self:RefreshCharDamageData()
  for _,nCharId in ipairs(self.tbCharId) do
    (table.insert)(tbChar, nCharId)
  end
  local func_SettlementFinish = function(bSuccess)
    -- function num : 0_15_0
  end

  local levelEndCallback = function()
    -- function num : 0_15_1 , upvalues : _ENV, self, levelEndCallback, tbChar, func_SettlementFinish
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    local nLevelData = (ConfigTable.GetData)("ScoreBossLevel", self.LevelId)
    local nType = ((ConfigTable.GetData)("ScoreBossFloor", nLevelData.FloorId)).Theme
    local sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
    print("sceneName:" .. sName)
    local tbSkin = {}
    for _,nCharId in ipairs(tbChar) do
      local nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
      ;
      (table.insert)(tbSkin, nSkinId)
    end
    ;
    ((CS.AdventureModuleHelper).PlaySettlementPerform)(sName, "", tbSkin, func_SettlementFinish)
  end

  ;
  (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
  local openBattleResultPanel = function()
    -- function num : 0_15_2 , upvalues : _ENV, self, openBattleResultPanel, entryLevelId, totalScore, totalStar
    (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.ScoreBossResult, entryLevelId, totalScore, totalStar, self.tbCharDamage)
  end

  ;
  (EventManager.Add)("SettlementPerformLoadFinish", self, openBattleResultPanel)
  ;
  ((CS.AdventureModuleHelper).LevelStateChanged)(true)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResultMask)
end

ScoreBossLevel.RefreshCharDamageData = function(self)
  -- function num : 0_16 , upvalues : _ENV
  self.tbCharDamage = (UTILS.GetCharDamageResult)(self.tbCharId)
end

ScoreBossLevel.OnEvent_ControlScore = function(self, Id, nBehavior)
  -- function num : 0_17
  if self.isSettlement then
    return 
  end
  if self.BossId == Id and nBehavior == self.ScoreBossBehavior and self.totalControlScore < self.MaxControlScore then
    self.totalControlScore = self.totalControlScore + self.OnceControlScore
    ;
    (self.parent):BehaviorToScore(self.totalControlScore)
  end
end

ScoreBossLevel.OnEvent_ScoreBossSettleSuccess = function(self, entryLevelId, totalScore, totalStar)
  -- function num : 0_18
  self:PlaySuccessPerform(entryLevelId, totalScore, totalStar)
end

ScoreBossLevel.OnEvent_ScoreBossSettleGiveUp = function(self, totalScore, totalStar)
  -- function num : 0_19
  (self.parent):LevelEnd()
end

ScoreBossLevel.BindEvent = function(self)
  -- function num : 0_20 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Add)(nEventId, self, callback)
    end
  end
end

ScoreBossLevel.UnBindEvent = function(self)
  -- function num : 0_21 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Remove)(nEventId, self, callback)
    end
  end
  if self.BossId then
    (EventManager.RemoveEntityEvent)("HpChanged", self.BossId, self, self.OnEvent_HpChanged)
    ;
    (EventManager.RemoveEntityEvent)("BossRushMonsterLevelChanged", self.BossId, self, self.OnEvent_BossRushMonsterLevelChanged)
    ;
    (EventManager.RemoveEntityEvent)("BossRushMonsterBattleAttrChanged", self.BossId, self, self.OnEvent_BossRushMonsterBattleAttrChanged)
    self.BossId = nil
  end
end

ScoreBossLevel.OnEvent_UploadDodgeEvent = function(self, padMode)
  -- function num : 0_22 , upvalues : _ENV
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (table.insert)(tab, {"pad_mode", padMode})
  ;
  (table.insert)(tab, {"level_type", "ScoreBoss"})
  ;
  (table.insert)(tab, {"build_id", tostring(self.tmpBuildId)})
  ;
  (table.insert)(tab, {"level_id", tostring(self.LevelId)})
  ;
  (table.insert)(tab, {"up_time", tostring(((CS.ClientManager).Instance).serverTimeStamp)})
  ;
  (NovaAPI.UserEventUpload)("use_dodge_key", tab)
end

return ScoreBossLevel

