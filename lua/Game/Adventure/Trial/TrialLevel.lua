local TrialLevel = class("TrialLevel")
local TimerManager = require("GameCore.Timer.TimerManager")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", [EventId.AbandonBattle] = "OnEvent_AbandonBattle", TrialGameEnd = "OnEvent_LevelResult", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", BattlePause = "OnEvent_Pause", TrialDepot = "OnEvent_Depot", TaskLevel_InitTask = "OnEvent_InitQuest", Trial_QuestComplete = "OnEvent_QuestComplete", Trial_Time = "OnEvent_Time"}
TrialLevel.Init = function(self, parent, nLevelId)
  -- function num : 0_0 , upvalues : _ENV
  self.parent = parent
  self.nLevelId = nLevelId
  self.mapChangeInfo = {}
  self.mapLevelCfg = (ConfigTable.GetData)("TrialFloor", nLevelId)
  if not self.mapLevelCfg then
    return 
  end
  self.mapBuildData = (PlayerData.Build):GetTrialBuild((self.mapLevelCfg).TrialBuild)
  self.mapTalentAddLevel = {}
  self.mapCharData = {}
  self.tbCharTrialId = {}
  self.tbCharId = {}
  for _,mapChar in ipairs((self.mapBuildData).tbChar) do
    (table.insert)(self.tbCharId, mapChar.nTid)
    -- DECOMPILER ERROR at PC42: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self.tbCharTrialId)[mapChar.nTid] = mapChar.nTrialId
    -- DECOMPILER ERROR at PC50: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self.mapCharData)[mapChar.nTid] = (PlayerData.Char):GetTrialCharById(mapChar.nTrialId)
    -- DECOMPILER ERROR at PC58: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self.mapTalentAddLevel)[mapChar.nTid] = (PlayerData.Talent):GetTrialEnhancedPotential(mapChar.nTrialId)
  end
  self.mapDiscData = {}
  self.tbDiscId = {}
  for _,nDiscId in ipairs((self.mapBuildData).tbDisc) do
    if nDiscId > 0 then
      (table.insert)(self.tbDiscId, nDiscId)
      local mapCfg = (ConfigTable.GetData)("TrialDisc", nDiscId)
      -- DECOMPILER ERROR at PC91: Confused about usage of register: R9 in 'UnsetPending'

      if mapCfg then
        (self.mapDiscData)[mapCfg.DiscId] = (PlayerData.Disc):GetTrialDiscById(nDiscId)
      end
    end
  end
  self:ParseDepotData()
  self.mapActorInfo = {}
  for idx,nTid in ipairs(self.tbCharId) do
    local stActorInfo = self:CalCharFixedEffect((self.tbCharTrialId)[nTid], idx == 1, self.tbDiscId)
    -- DECOMPILER ERROR at PC112: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self.mapActorInfo)[nTid] = stActorInfo
  end
  -- DECOMPILER ERROR at PC119: Confused about usage of register: R3 in 'UnsetPending'

  PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).Trial
  local params = (NovaAPI.GetDynamicLevelParamsBootConfig)()
  ;
  ((CS.AdventureModuleHelper).EnterDynamic)(nLevelId, self.tbCharId, (GameEnum.dynamicLevelType).Trial, params)
  ;
  (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

TrialLevel.ParseDepotData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.tbDepotPotential = {}
  for nCharId,tbPerk in pairs((self.mapBuildData).tbPotentials) do
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R6 in 'UnsetPending'

    if (self.tbCharTrialId)[nCharId] then
      if not (self.tbDepotPotential)[nCharId] then
        (self.tbDepotPotential)[nCharId] = {}
      end
      for _,v in ipairs(tbPerk) do
        -- DECOMPILER ERROR at PC26: Confused about usage of register: R11 in 'UnsetPending'

        ((self.tbDepotPotential)[nCharId])[v.nPotentialId] = v.nLevel
      end
    else
      do
        do
          printError("体验build内，有多余角色的潜能" .. nCharId)
          -- DECOMPILER ERROR at PC35: LeaveBlock: unexpected jumping out DO_STMT

          -- DECOMPILER ERROR at PC35: LeaveBlock: unexpected jumping out IF_ELSE_STMT

          -- DECOMPILER ERROR at PC35: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
end

TrialLevel.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = (PlayerData.Build):GetTrialBuildAllEft()
  safe_call_cs_func((CS.AdventureModuleHelper).SetNoteInfo, tbNoteInfo)
  self.mapEftData = (UTILS.AddBuildEffect)(mapAllEft, mapDiscEft, mapNoteEffect)
  ;
  (EventManager.Hit)("OpenTrialInfo", self.nQuestId)
end

TrialLevel.RefreshCharDamageData = function(self)
  -- function num : 0_3 , upvalues : _ENV
  self.tbCharDamage = (UTILS.GetCharDamageResult)(self.tbCharId)
end

TrialLevel.OnEvent_LevelResult = function(self, nLevelTime)
  -- function num : 0_4 , upvalues : _ENV
  self:RefreshCharDamageData()
  local bReceived = (PlayerData.Trial):CheckGroupReceived()
  local bAbandon = not bReceived
  ;
  (EventManager.Hit)("TrialBattleEnd")
  if (self.parent):GetSettlementState() then
    printError("试玩关结算流程重复进入，本次退出")
    return 
  end
  ;
  (self.parent):SetSettlementState(true)
  if bAbandon then
    (EventManager.Hit)("TrialLevelEnd", self.nLevelId)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.BtnTips)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.TrialResult, false, nLevelTime or 0, self.tbCharId, (self.parent).nActId, {}, self.tbCharDamage)
    ;
    (self.parent):LevelEnd()
    return 
  end
  ;
  (EventManager.Hit)("TrialLevelEnd", self.nLevelId)
  self:PlaySuccessPerform(nLevelTime)
end

TrialLevel.OnEvent_AbandonBattle = function(self)
  -- function num : 0_5
  self:OnEvent_LevelResult(self.nLevelTime)
end

TrialLevel.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_6 , upvalues : _ENV
  self:SetPersonalPerk()
  self:SetDiscInfo()
  for idx,nCharId in ipairs(self.tbCharId) do
    local stActorInfo = self:CalCharFixedEffect((self.tbCharTrialId)[nCharId], idx == 1, self.tbDiscId)
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
  local tbDisc = {}
  for _,v in ipairs(self.tbDiscId) do
    local mapCfg = (ConfigTable.GetData)("TrialDisc", v)
    if mapCfg then
      (table.insert)(tbDisc, mapCfg.DiscId)
    end
  end
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.TrialBattlePanel, self.tbCharId, tbDisc, self.mapCharData, self.mapDiscData, self.mapTalentAddLevel)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

TrialLevel.BindEvent = function(self)
  -- function num : 0_7 , upvalues : _ENV, mapEventConfig
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

TrialLevel.UnBindEvent = function(self)
  -- function num : 0_8 , upvalues : _ENV, mapEventConfig
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

TrialLevel.PlaySuccessPerform = function(self, nLevelTime)
  -- function num : 0_9 , upvalues : _ENV
  local func_SettlementFinish = function(bSuccess)
    -- function num : 0_9_0
  end

  local tbChar = self.tbCharId
  local levelEndCallback = function()
    -- function num : 0_9_1 , upvalues : _ENV, self, levelEndCallback, tbChar, func_SettlementFinish
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    local nType = (self.mapLevelCfg).Theme
    local sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
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
    -- function num : 0_9_2 , upvalues : _ENV, self, openBattleResultPanel, nLevelTime
    (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.TrialResult, true, nLevelTime or 0, self.tbCharId, (self.parent).nActId, self.mapChangeInfo, self.tbCharDamage)
    self.bSettle = false
    ;
    (self.parent):LevelEnd()
    self:UnBindEvent()
  end

  ;
  (EventManager.Add)("SettlementPerformLoadFinish", self, openBattleResultPanel)
  ;
  ((CS.AdventureModuleHelper).LevelStateChanged)(true)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResultMask)
end

TrialLevel.SetCharFixedAttribute = function(self)
  -- function num : 0_10 , upvalues : _ENV
  for nCharId,stActorInfo in pairs(self.mapActorInfo) do
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
end

TrialLevel.CalCharFixedEffect = function(self, nTrialId, bMainChar, tbDiscId)
  -- function num : 0_11 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterTrialAttrBattle(nTrialId, stActorInfo, bMainChar, tbDiscId, (self.mapLevelCfg).TrialBuild)
  return stActorInfo
end

TrialLevel.SetPersonalPerk = function(self)
  -- function num : 0_12 , upvalues : _ENV
  if self.mapBuildData ~= nil then
    for nCharId,tbPerk in pairs((self.mapBuildData).tbPotentials) do
      local mapTalentAddLevel = {}
      if (self.tbCharTrialId)[nCharId] then
        mapTalentAddLevel = (PlayerData.Talent):GetTrialEnhancedPotential((self.tbCharTrialId)[nCharId])
      else
        printError("体验build内，有多余角色的潜能" .. nCharId)
      end
      local tbPerkInfo = {}
      for _,mapPerkInfo in ipairs(tbPerk) do
        local nAddLv = mapTalentAddLevel[mapPerkInfo.nPotentialId] or 0
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

TrialLevel.SetDiscInfo = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local tbDiscInfo = {}
  for k,nDiscId in ipairs((self.mapBuildData).tbDisc) do
    if k <= 3 then
      local discInfo = (PlayerData.Disc):CalcTrialInfoInBuild(nDiscId, (self.mapBuildData).tbSecondarySkill)
      ;
      (table.insert)(tbDiscInfo, discInfo)
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetDiscInfo, tbDiscInfo)
end

TrialLevel.OnEvent_InitQuest = function(self, nQuestId)
  -- function num : 0_14
  self.nQuestId = nQuestId
end

TrialLevel.OnEvent_QuestComplete = function(self)
  -- function num : 0_15 , upvalues : _ENV
  local bReceived = (PlayerData.Trial):CheckGroupReceived()
  if not bReceived then
    (PanelManager.InputDisable)()
    local callback = function(mapChangeInfo)
    -- function num : 0_15_0 , upvalues : _ENV, self
    (PanelManager.InputEnable)()
    if not mapChangeInfo then
      self.mapChangeInfo = {}
    end
  end

    ;
    (self.parent):SendReceiveTrialRewardReq(callback)
  end
  do
    self:ShowTeleportIndicator()
  end
end

TrialLevel.ShowTeleportIndicator = function(self)
  -- function num : 0_16 , upvalues : _ENV
  local tbTeleports = ((CS.AdventureModuleHelper).GetLevelTeleporters)()
  if tbTeleports ~= nil then
    for i = 0, tbTeleports.Count - 1 do
      (EventManager.Hit)("SetIndicator", 2, tbTeleports[i], Vector3.zero, nil)
    end
  end
end

TrialLevel.OnEvent_Time = function(self, nTime)
  -- function num : 0_17
  self.nLevelTime = nTime
end

TrialLevel.OnEvent_Pause = function(self)
  -- function num : 0_18 , upvalues : _ENV
  (EventManager.Hit)("OpenTrialPause", self.tbCharId, self.mapCharData, (self.mapLevelCfg).TrialChar)
end

TrialLevel.OnEvent_Depot = function(self)
  -- function num : 0_19 , upvalues : _ENV
  local tbDisc = {}
  for _,v in ipairs(self.tbDiscId) do
    local mapCfg = (ConfigTable.GetData)("TrialDisc", v)
    if mapCfg then
      (table.insert)(tbDisc, mapCfg.DiscId)
    end
  end
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.TrialDepot, self.tbCharId, tbDisc, self.mapCharData, self.mapDiscData, self.mapTalentAddLevel, self.tbDepotPotential, (self.mapBuildData).tbNotes, true)
end

return TrialLevel

