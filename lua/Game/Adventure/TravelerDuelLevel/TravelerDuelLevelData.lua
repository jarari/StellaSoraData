local TravelerDuelLevelData = class("TravelerDuelLevelData")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local AdventureModuleHelper = CS.AdventureModuleHelper
local TimerManager = require("GameCore.Timer.TimerManager")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", [EventId.AbandonBattle] = "OnEvent_AbandonBattle", TravelerDuel_Result = "OnEvent_LevelResult", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", BattlePause = "OnEvnet_Pause", Upload_Dodge_Event = "OnEvent_UploadDodgeEvent"}
TravelerDuelLevelData.Init = function(self, parent, nLevel, tbAffixes, nBuildId)
  -- function num : 0_0 , upvalues : _ENV
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local LocalData = require("GameCore.Data.LocalData")
  local sKey = (LocalData.GetPlayerLocalData)("TravelerDuelRecordKey")
  if sKey ~= nil or sKey ~= "" then
    (NovaAPI.DeleteRecFile)(sKey)
  end
  self.bEnd = false
  local ClientManager = (CS.ClientManager).Instance
  sKey = tostring(ClientManager.serverTimeStamp)
  ;
  (LocalData.SetPlayerLocalData)("TravelerDuelRecordKey", sKey)
  self.parent = parent
  self.nlevelId = nLevel
  self.tmpBuildId = nBuildId
  self.tbAffixes = tbAffixes
  local mapCfg = (ConfigTable.GetData)("TravelerDuelBossLevel", nLevel)
  if mapCfg then
    self.nTime = mapCfg.Timelimit
  end
  local GetDataCallback = function(mapBuildData)
    -- function num : 0_0_0 , upvalues : _ENV, nLevel, self, tbAffixes, sKey
    local mapLevel = (ConfigTable.GetData)("TravelerDuelBossLevel", nLevel)
    if mapLevel == nil then
      printError("TravelerDuelBossLevel missing:" .. nLevel)
      return 
    end
    self.mapBuildData = mapBuildData
    self.tbCharId = {}
    for i,v in pairs(mapBuildData.tbChar) do
      (table.insert)(self.tbCharId, v.nTid)
    end
    self.tbDiscId = {}
    for _,nDiscId in ipairs((self.mapBuildData).tbDisc) do
      if nDiscId > 0 then
        (table.insert)(self.tbDiscId, nDiscId)
      end
    end
    -- DECOMPILER ERROR at PC47: Confused about usage of register: R2 in 'UnsetPending'

    PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).TravelerDuel
    ;
    ((CS.AdventureModuleHelper).EnterTravelerDuel)(nLevel, mapLevel.FloorId, self.tbCharId, tbAffixes)
    safe_call_cs_func((CS.AdventureModuleHelper).SetDamageRecordId, sKey)
    ;
    (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
  end

  ;
  (PlayerData.Build):GetBuildDetailData(GetDataCallback, nBuildId)
end

TravelerDuelLevelData.RefreshCharDamageData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.tbCharDamage = (UTILS.GetCharDamageResult)(self.tbCharId)
end

TravelerDuelLevelData.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = (PlayerData.Build):GetBuildAllEft((self.mapBuildData).nBuildId)
  safe_call_cs_func((CS.AdventureModuleHelper).SetNoteInfo, tbNoteInfo)
  self.mapEftData = (UTILS.AddBuildEffect)(mapAllEft, mapDiscEft, mapNoteEffect)
end

TravelerDuelLevelData.OnEvent_LevelResult = function(self, bSuccess, nTime)
  -- function num : 0_3 , upvalues : _ENV, TimerManager
  if self.bEnd then
    return 
  end
  self.bEnd = true
  self:RefreshCharDamageData()
  local msgCallback = function(mapMsgData)
    -- function num : 0_3_0 , upvalues : self, _ENV, bSuccess, nTime
    self._EndTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
    local tabUpLevel = {}
    local nResult = bSuccess and "1" or "2"
    ;
    (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (table.insert)(tabUpLevel, {"game_cost_time", tostring(nTime)})
    ;
    (table.insert)(tabUpLevel, {"real_cost_time", tostring(self._EndTime - self._EntryTime)})
    ;
    (table.insert)(tabUpLevel, {"build_id", tostring((self.mapBuildData).nBuildId)})
    ;
    (table.insert)(tabUpLevel, {"battle_id", tostring(self.nlevelId)})
    ;
    (table.insert)(tabUpLevel, {"battle_result", tostring(nResult)})
    ;
    (NovaAPI.UserEventUpload)("traveler_duel_battle", tabUpLevel)
    if bSuccess then
      self:PlaySuccessPerform(mapMsgData, 3, nTime)
    else
      ;
      (EventManager.Hit)(EventId.ClosePanel, PanelId.BtnTips)
      ;
      (EventManager.Hit)(EventId.OpenPanel, PanelId.TDBattleResultPanel, false, {false, false, false}, mapMsgData.AwardItems, mapMsgData.FirstItems, {}, 0, false, nTime, self.nlevelId, self.tbCharId, self.tbAffixes, mapMsgData.TimeScore, mapMsgData.BaseScore, mapMsgData.FinalScore, mapMsgData.MaxScore < mapMsgData.FinalScore, mapMsgData.Change, mapMsgData.SurpriseItems, mapMsgData.CustomItems, self.tbCharDamage)
      ;
      (self.parent):LevelEnd()
    end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

  local nStar = 0
  if bSuccess then
    nStar = 3
  end
  local wait = function()
    -- function num : 0_3_1 , upvalues : self, nStar, nTime, msgCallback
    (self.parent):SendMsg_TravelerDuelSettle(nStar, self.nlevelId, nTime, msgCallback)
  end

  if bSuccess then
    (TimerManager.Add)(1, 2, self, wait, true, true, nil, nil)
  else
    wait()
  end
end

TravelerDuelLevelData.OnEvent_AbandonBattle = function(self)
  -- function num : 0_4
  self:OnEvent_LevelResult(false, 0)
end

TravelerDuelLevelData.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_5 , upvalues : _ENV
  (PlayerData.Achievement):SetSpecialBattleAchievement((GameEnum.levelType).TravelerDuel)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.TDBattlePanel, self.tbCharId)
  self:SetPersonalPerk()
  self:SetDiscInfo()
  for idx,nCharId in ipairs(self.tbCharId) do
    local stActorInfo = self:CalCharFixedEffect(nCharId, idx == 1, self.tbDiscId)
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

TravelerDuelLevelData.BindEvent = function(self)
  -- function num : 0_6 , upvalues : _ENV, mapEventConfig
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

TravelerDuelLevelData.UnBindEvent = function(self)
  -- function num : 0_7 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Remove)(nEventId, self, callback)
    end
  end
end

TravelerDuelLevelData.SetPersonalPerk = function(self)
  -- function num : 0_8 , upvalues : _ENV
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

TravelerDuelLevelData.SetDiscInfo = function(self)
  -- function num : 0_9 , upvalues : _ENV
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

TravelerDuelLevelData.PlaySuccessPerform = function(self, mapMsgData, nStar, nTime)
  -- function num : 0_10 , upvalues : _ENV
  local func_OpenResult = function(bSuccess)
    -- function num : 0_10_0
  end

  local tbChar = self.tbCharId
  local levelEndCallback = function()
    -- function num : 0_10_1 , upvalues : _ENV, self, levelEndCallback, tbChar, func_OpenResult
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    local nFloorId = ((ConfigTable.GetData)("TravelerDuelBossLevel", self.nlevelId)).FloorId
    local nType = ((ConfigTable.GetData)("TravelerDuelFloor", nFloorId)).Theme
    local sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
    local jumpPerform = function()
      -- function num : 0_10_1_0 , upvalues : _ENV
      (NovaAPI.DispatchEventWithData)("SKIP_SETTLEMENT_PERFORM")
    end

    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.BtnTips, jumpPerform)
    local tbSkin = {}
    for _,nCharId in ipairs(tbChar) do
      local nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
      ;
      (table.insert)(tbSkin, nSkinId)
    end
    ;
    ((CS.AdventureModuleHelper).PlaySettlementPerform)(sName, "", tbSkin, func_OpenResult)
  end

  local openBattleResultPanel = function()
    -- function num : 0_10_2 , upvalues : _ENV, self, openBattleResultPanel, mapMsgData, nTime
    (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.TDBattleResultPanel, true, {true, true, true}, mapMsgData.AwardItems, mapMsgData.FirstItems, {}, 0, false, nTime, self.nlevelId, self.tbCharId, self.tbAffixes, mapMsgData.TimeScore, mapMsgData.BaseScore, mapMsgData.FinalScore, mapMsgData.MaxScore < mapMsgData.FinalScore, mapMsgData.Change, mapMsgData.SurpriseItems, mapMsgData.CustomItems, self.tbCharDamage)
    self.bSettle = false
    ;
    (self.parent):LevelEnd()
    self:UnBindEvent()
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end

  ;
  (EventManager.Add)("SettlementPerformLoadFinish", self, openBattleResultPanel)
  ;
  (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
  ;
  ((CS.AdventureModuleHelper).LevelStateChanged)(true)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResultMask)
end

TravelerDuelLevelData.CalCharFixedEffect = function(self, nCharId, bMainChar, tbDiscId)
  -- function num : 0_11 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar, tbDiscId, (self.mapBuildData).nBuildId)
  return stActorInfo
end

TravelerDuelLevelData.OnEvnet_Pause = function(self)
  -- function num : 0_12 , upvalues : _ENV
  (EventManager.Hit)("OpenTDPause", self.nlevelId, self.tbCharId)
end

TravelerDuelLevelData.OnEvent_UploadDodgeEvent = function(self, padMode)
  -- function num : 0_13 , upvalues : _ENV
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (table.insert)(tab, {"pad_mode", padMode})
  ;
  (table.insert)(tab, {"level_type", "TravelerDuel"})
  ;
  (table.insert)(tab, {"build_id", tostring(self.tmpBuildId)})
  ;
  (table.insert)(tab, {"level_id", tostring(self.nlevelId)})
  ;
  (table.insert)(tab, {"up_time", tostring(((CS.ClientManager).Instance).serverTimeStamp)})
  ;
  (NovaAPI.UserEventUpload)("use_dodge_key", tab)
end

return TravelerDuelLevelData

