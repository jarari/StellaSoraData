local InfinityTowerLevel = class("InfinityTowerLevel")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", InfinityTowerEnd = "OnEvent_InfinityTowerEnd", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", BattlePause = "OnEvnet_Pause", [EventId.AbandonBattle] = "OnEvent_AbandonBattle", Infinity_Tower_RunTime = "OnEvent_InfinityTowerRunTime", ADVENTURE_LEVEL_UNLOAD_COMPLETE = "OnEvent_UnloadComplete"}
InfinityTowerLevel.Init = function(self, parent, floorId, nBuildId, againOrNextLv, isContinue)
  -- function num : 0_0 , upvalues : _ENV
  self.parent = parent
  self.floorId = floorId
  self.lvRunTime = 0
  local GetBuildCallback = function(mapBuildData)
    -- function num : 0_0_0 , upvalues : self, _ENV, isContinue, againOrNextLv
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

    PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).InfinityTower
    ;
    ((CS.AdventureModuleHelper).EnterInfinityTowerFloor)(self.floorId, self.tbCharId, isContinue)
    if againOrNextLv == 0 then
      (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
    else
      self:OnEvent_AdventureModuleEnter()
    end
    ;
    (EventManager.Hit)("Infinity_Refresh_Msg")
    -- DECOMPILER ERROR: 4 unprocessed JMP targets
  end

  ;
  (PlayerData.Build):GetBuildDetailData(GetBuildCallback, nBuildId)
end

InfinityTowerLevel.CalCharFixedEffect = function(self, nCharId, bMainChar, tbDiscId)
  -- function num : 0_1 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar, tbDiscId, (self.mapBuildData).nBuildId)
  return stActorInfo
end

InfinityTowerLevel.BindEvent = function(self)
  -- function num : 0_2 , upvalues : _ENV, mapEventConfig
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

InfinityTowerLevel.UnBindEvent = function(self)
  -- function num : 0_3 , upvalues : _ENV, mapEventConfig
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

InfinityTowerLevel.OnEvent_InfinityTowerEnd = function(self, state)
  -- function num : 0_4 , upvalues : _ENV
  if state == 1 then
    (self.parent):ITSettleReq(2, self.lvRunTime, self.tbCharId)
  else
    if state == 2 then
      (self.parent):ITSettleReq(1, self.lvRunTime, self.tbCharId)
    else
      if state == 3 then
        (self.parent):ITSettleReq(3, self.lvRunTime, self.tbCharId)
      end
    end
  end
  ;
  (EventManager.Hit)("Infinity_Hide_Time")
  ;
  (EventManager.Hit)("ResetBossHUD")
end

InfinityTowerLevel.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_5 , upvalues : _ENV
  (PlayerData.Achievement):SetSpecialBattleAchievement((GameEnum.levelType).InfinityTower)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.InfinityTowerBattlePanel, self.tbCharId)
  local wait = function()
    -- function num : 0_5_0 , upvalues : _ENV
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.Hud)
  end

  ;
  (cs_coroutine.start)(wait)
  self:SetPersonalPerk()
  self:SetDiscInfo()
  for idx,nCharId in ipairs(self.tbCharId) do
    local stActorInfo = self:CalCharFixedEffect(nCharId, idx == 1, self.tbDiscId)
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

InfinityTowerLevel.SetPersonalPerk = function(self)
  -- function num : 0_6 , upvalues : _ENV
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

InfinityTowerLevel.SetDiscInfo = function(self)
  -- function num : 0_7 , upvalues : _ENV
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

InfinityTowerLevel.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_8 , upvalues : _ENV
  (EventManager.Hit)("MainBattleMenuBtnPauseActive", true)
  local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = (PlayerData.Build):GetBuildAllEft((self.mapBuildData).nBuildId)
  safe_call_cs_func((CS.AdventureModuleHelper).SetNoteInfo, tbNoteInfo)
  self.mapEftData = (UTILS.AddBuildEffect)(mapAllEft, mapDiscEft, mapNoteEffect)
  local tabAddAffixBuff = (PlayerData.InfinityTower):GetFloorAffixBuff(self.tbCharId, self.floorId)
  safe_call_cs_func((CS.AdventureModuleHelper).InfinityTowerFloorEffects, tabAddAffixBuff)
end

InfinityTowerLevel.OnEvent_UnloadComplete = function(self)
  -- function num : 0_9
  (self.parent):EnterInfinityTowerAgainNext()
end

InfinityTowerLevel.OnEvnet_Pause = function(self)
  -- function num : 0_10 , upvalues : _ENV
  (EventManager.Hit)("show_Infinity_Pause", self.lvRunTime, self.tbCharId)
end

InfinityTowerLevel.OnEvent_AbandonBattle = function(self)
  -- function num : 0_11
  self:OnEvent_InfinityTowerEnd(3)
end

InfinityTowerLevel.OnEvent_InfinityTowerRunTime = function(self, rTime)
  -- function num : 0_12
  self.lvRunTime = rTime
end

return InfinityTowerLevel

