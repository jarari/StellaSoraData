local StoryLevel = class("StoryLevel")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local mapEventConfig = {LevelStateChanged = "OnEvent_SendMsgFinishBattle", [EventId.AbandonBattle] = "OnEvent_AbandonBattle", LoadLevelRefresh = "OnEvent_LoadLevelRefresh", Mainline_Time_CountUp = "OnEvent_Time", BattlePause = "OnEvnet_Pause", AdventureModuleEnter = "OnEvent_AdventureModuleEnter"}
StoryLevel.Init = function(self, parent, nLevelId, nBuildId)
  -- function num : 0_0 , upvalues : _ENV
  self.bSettle = false
  self.parent = parent
  self.nMainLineTime = 0
  self.nCacheFloorTime = 0
  self.nLevelId = nLevelId
  self.curFloorIdx = 1
  self.mapCharacterTempData = {}
  local mapStory = (ConfigTable.GetData_Story)(nLevelId)
  if mapStory == nil then
    printError("mapStory is nil,id = " .. nLevelId)
    return 
  end
  self.bTrialLevel = mapStory.TrialBuild ~= nil and nBuildId == 0
  local GetBuildCallback = function(mapBuildData)
    -- function num : 0_0_0 , upvalues : self, _ENV, mapStory
    self.mapBuildData = mapBuildData
    self.tbCharTrialId = {}
    self.tbCharId = {}
    for _,mapChar in ipairs((self.mapBuildData).tbChar) do
      (table.insert)(self.tbCharId, mapChar.nTid)
      -- DECOMPILER ERROR at PC18: Confused about usage of register: R6 in 'UnsetPending'

      ;
      (self.tbCharTrialId)[mapChar.nTid] = mapChar.nTrialId
    end
    self.tbDiscId = {}
    for _,nDiscId in ipairs((self.mapBuildData).tbDisc) do
      if nDiscId > 0 then
        (table.insert)(self.tbDiscId, nDiscId)
      end
    end
    -- DECOMPILER ERROR at PC41: Confused about usage of register: R1 in 'UnsetPending'

    PlayerData.nCurGameType = (AllEnum.WorldMapNodeType).Mainline
    ;
    ((CS.AdventureModuleHelper).EnterMainlineMap)((mapStory.FloorId)[1], self.tbCharId, {})
    ;
    (NovaAPI.EnterModule)("AdventureModuleScene", true, 17)
  end

  if self.bTrialLevel then
    local mapBuildData = (PlayerData.Build):GetTrialBuild(mapStory.TrialBuild)
    GetBuildCallback(mapBuildData)
  else
    (PlayerData.Build):GetBuildDetailData(GetBuildCallback, nBuildId)
  end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

StoryLevel.RefreshCharDamageData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.tbCharDamage = (UTILS.GetCharDamageResult)(self.tbCharId)
end

StoryLevel.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local mapAllEft, mapDiscEft, mapNoteEffect, tbNoteInfo = {}, {}, {}, {}
  if self.bTrialLevel then
    mapAllEft = (PlayerData.Build):GetTrialBuildAllEft()
  else
    -- DECOMPILER ERROR at PC22: Overwrote pending register: R4 in 'AssignReg'

    -- DECOMPILER ERROR at PC23: Overwrote pending register: R3 in 'AssignReg'

    -- DECOMPILER ERROR at PC24: Overwrote pending register: R2 in 'AssignReg'

    mapAllEft = (PlayerData.Build):GetBuildAllEft((self.mapBuildData).nBuildId)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetNoteInfo, tbNoteInfo)
  self.mapEftData = (UTILS.AddBuildEffect)(mapAllEft, mapDiscEft, mapNoteEffect)
  self:ResetCharacter()
end

StoryLevel.OnEvent_SendMsgFinishBattle = function(self, LevelResult, FadeTime, sVideoName)
  -- function num : 0_3 , upvalues : _ENV
  if self.bSettle == true then
    print("已在结算流程中！")
    return 
  end
  self.bSettle = true
  print("OnEvent_SendMsgFinishBattle")
  local fadeT = 0
  if FadeTime ~= nil then
    fadeT = FadeTime
  end
  if LevelResult == (AllEnum.LevelResult).Failed then
    self:OnEvent_AbandonBattle()
    return 
  end
  local mapStory = (ConfigTable.GetData_Story)(self.nLevelId)
  if self.curFloorIdx < #mapStory.FloorId then
    self:ChangeFloor()
    return 
  end
  local func_cbFinishSucc = function(mapChangeInfo)
    -- function num : 0_3_0 , upvalues : self, fadeT, sVideoName
    self:PlaySuccessPerform(fadeT, mapChangeInfo, sVideoName)
  end

  print("====== 当前通关主线关卡ID：" .. self.nLevelId .. " ======")
  local events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).Mainline, LevelResult ~= (AllEnum.LevelResult).Failed)}
  ;
  (PlayerData.Avg):SendMsg_STORY_DONE(func_cbFinishSucc, events)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

StoryLevel.OnEvent_AbandonBattle = function(self)
  -- function num : 0_4 , upvalues : _ENV
  self:RefreshCharDamageData()
  if self.nLevelId > 0 then
    local nMainlineId = self.nLevelId
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResult, false, 0, {}, {}, {}, 0, false, "", "", nMainlineId, self.tbCharId, {}, self.tbCharDamage)
    self:UnBindEvent()
    ;
    (self.parent):LevelEnd()
  end
end

StoryLevel.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_5 , upvalues : _ENV
  (PlayerData.Achievement):SetSpecialBattleAchievement((GameEnum.levelType).Mainline)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.Adventure, self.tbCharId)
  self:SetPersonalPerk()
  self:SetDiscInfo()
  for idx,nCharId in ipairs(self.tbCharId) do
    local nTrialOrCharId = self.bTrialLevel and (self.tbCharTrialId)[nCharId] or nCharId
    local stActorInfo = self:CalCharFixedEffect(nTrialOrCharId, idx == 1, self.tbDiscId, self.bTrialLevel)
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

StoryLevel.BindEvent = function(self)
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

StoryLevel.UnBindEvent = function(self)
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

StoryLevel.PlaySuccessPerform = function(self, FadeTime, mapChangeInfo, sVideoName)
  -- function num : 0_8 , upvalues : _ENV
  local func_SettlementFinish = function(bSuccess)
    -- function num : 0_8_0
  end

  local bHasReward = not mapChangeInfo or not mapChangeInfo.Props or #mapChangeInfo.Props > 0
  local FirstRewardItems = {}
  if bHasReward then
    local tbRewardDisplay = (UTILS.DecodeChangeInfo)(mapChangeInfo)
    for _,v in pairs(tbRewardDisplay) do
      for k,value in pairs(v) do
        (table.insert)(FirstRewardItems, {Tid = value.Tid, Qty = value.Qty, rewardType = (AllEnum.RewardType).First})
      end
    end
  end
  local tbChar = self.tbCharId
  self:RefreshCharDamageData()
  local openBattleResultPanel = function()
    -- function num : 0_8_1 , upvalues : _ENV, self, openBattleResultPanel, FirstRewardItems, mapChangeInfo
    (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
    local sLarge, sSmall = "", ""
    if not FirstRewardItems then
      (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResult, true, 3, {}, {}, {}, 0, false, sLarge, sSmall, self.nLevelId, self.tbCharId, mapChangeInfo, self.tbCharDamage)
      self.bSettle = false
      ;
      (self.parent):LevelEnd()
      self:UnBindEvent()
    end
  end

  local levelEndCallback = function()
    -- function num : 0_8_2 , upvalues : _ENV, self, levelEndCallback, openBattleResultPanel, tbChar, func_SettlementFinish, sVideoName
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    ;
    (EventManager.Hit)(EventId.SetTransition)
    local videoCallback = function()
      -- function num : 0_8_2_0 , upvalues : _ENV, self, videoCallback, openBattleResultPanel, tbChar, func_SettlementFinish
      (EventManager.Remove)("VIDEO_END", self, videoCallback)
      ;
      (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResultMask)
      local nFloorCount = #((ConfigTable.GetData_Story)(self.nLevelId)).FloorId
      local nMapId = (((ConfigTable.GetData_Story)(self.nLevelId)).FloorId)[nFloorCount]
      local nType = ((ConfigTable.GetData)("MainlineFloor", nMapId)).Theme
      local sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
      ;
      (EventManager.Add)("SettlementPerformLoadFinish", self, openBattleResultPanel)
      local tbSkin = {}
      for _,nCharId in ipairs(tbChar) do
        local nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
        ;
        (table.insert)(tbSkin, nSkinId)
      end
      ;
      ((CS.AdventureModuleHelper).PlaySettlementPerform)(sName, "", tbSkin, func_SettlementFinish)
    end

    if sVideoName ~= nil and sVideoName ~= "" then
      (EventManager.Add)("VIDEO_END", self, videoCallback)
      ;
      (EventManager.Hit)(EventId.OpenPanel, PanelId.ProVideoGUI, sVideoName, true, 0.5, false, 0, true)
    else
      videoCallback()
    end
  end

  ;
  (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
  ;
  ((CS.AdventureModuleHelper).LevelStateChanged)(true, FadeTime or 0.5)
  -- DECOMPILER ERROR: 6 unprocessed JMP targets
end

StoryLevel.CalCharFixedEffect = function(self, nTrialOrCharId, bMainChar, tbDiscId, bTrialLevel)
  -- function num : 0_9 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  if bTrialLevel then
    (PlayerData.Char):CalCharacterTrialAttrBattle(nTrialOrCharId, stActorInfo, bMainChar, tbDiscId, (self.mapBuildData).nBuildId)
  else
    ;
    (PlayerData.Char):CalCharacterAttrBattle(nTrialOrCharId, stActorInfo, bMainChar, tbDiscId, (self.mapBuildData).nBuildId)
  end
  return stActorInfo
end

StoryLevel.SetPersonalPerk = function(self)
  -- function num : 0_10 , upvalues : _ENV
  if self.mapBuildData ~= nil then
    for nCharId,tbPerk in pairs((self.mapBuildData).tbPotentials) do
      local mapAddLevel = {}
      if self.bTrialLevel then
        if (self.tbCharTrialId)[nCharId] then
          mapAddLevel = (PlayerData.Talent):GetTrialEnhancedPotential((self.tbCharTrialId)[nCharId])
        else
          printError("体验build内，有多余角色的潜能" .. nCharId)
        end
      else
        mapAddLevel = (PlayerData.Char):GetCharEnhancedPotential(nCharId)
      end
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

StoryLevel.SetDiscInfo = function(self)
  -- function num : 0_11 , upvalues : _ENV
  local tbDiscInfo = {}
  for k,nDiscId in ipairs((self.mapBuildData).tbDisc) do
    if k <= 3 then
      local discInfo = nil
      if self.bTrialLevel then
        discInfo = (PlayerData.Disc):CalcTrialInfoInBuild(nDiscId, (self.mapBuildData).tbSecondarySkill)
      else
        discInfo = (PlayerData.Disc):CalcDiscInfoInBuild(nDiscId, (self.mapBuildData).tbSecondarySkill)
      end
      ;
      (table.insert)(tbDiscInfo, discInfo)
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetDiscInfo, tbDiscInfo)
end

StoryLevel.OnEvent_Time = function(self, nTime)
  -- function num : 0_12
  self.nMainLineTime = self.nCacheFloorTime + nTime
end

StoryLevel.OnEvnet_Pause = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local sAim = ((ConfigTable.GetData_Story)(self.nLevelId)).Aim
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.MainBattlePause, self.nMainLineTime or 0, (self.mapBuildData).tbChar, sAim)
end

StoryLevel.ChangeFloor = function(self)
  -- function num : 0_14 , upvalues : _ENV
  self:CacheTempData()
  local mapStory = (ConfigTable.GetData_Story)(self.nLevelId)
  self.curFloorIdx = self.curFloorIdx + 1
  self.nCacheFloorTime = self.nMainLineTime
  local levelUnloadCallback = function()
    -- function num : 0_14_0 , upvalues : _ENV, self, levelUnloadCallback
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelUnloadCallback)
    self:SetPersonalPerk()
    self:SetDiscInfo()
    for idx,nCharId in ipairs(self.tbCharId) do
      local nTrialOrCharId = self.bTrialLevel and (self.tbCharTrialId)[nCharId] or nCharId
      local stActorInfo = self:CalCharFixedEffect(nTrialOrCharId, idx == 1, self.tbDiscId, self.bTrialLevel)
      safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, stActorInfo)
    end
    self:SetCharStatus()
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

  ;
  (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelUnloadCallback)
  ;
  ((CS.AdventureModuleHelper).EnterMainlineMap)((mapStory.FloorId)[self.curFloorIdx], self.tbCharId, {})
  ;
  ((CS.AdventureModuleHelper).LevelStateChanged)(false)
  self.bSettle = false
end

StoryLevel.SetCharStatus = function(self)
  -- function num : 0_15 , upvalues : _ENV
  local nStatus = 0
  local nStatusTime = 0
  local tbActorInfo = {}
  for _,nTid in pairs(self.tbCharId) do
    local stCharInfo = (CS.Lua2CSharpInfo_ActorStatus)()
    if (self.mapCharacterTempData).stateInfo ~= nil and ((self.mapCharacterTempData).stateInfo)[nTid] ~= nil then
      nStatus = (((self.mapCharacterTempData).stateInfo)[nTid]).nState
      nStatusTime = (((self.mapCharacterTempData).stateInfo)[nTid]).nStateTime
    end
    stCharInfo.actorID = nTid
    stCharInfo.status = nStatus
    stCharInfo.specialStatusTime = nStatusTime
    ;
    (table.insert)(tbActorInfo, stCharInfo)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetActorStatus, tbActorInfo)
end

StoryLevel.ResetCharacter = function(self)
  -- function num : 0_16 , upvalues : _ENV
  do
    if (self.mapCharacterTempData).hpInfo ~= nil then
      local tbActorInfo = {}
      for nTid,nHp in pairs((self.mapCharacterTempData).hpInfo) do
        local stCharInfo = (CS.Lua2CSharpInfo_ActorAttribute)()
        stCharInfo.actorID = nTid
        stCharInfo.curHP = nHp
        ;
        (table.insert)(tbActorInfo, stCharInfo)
      end
      safe_call_cs_func((CS.AdventureModuleHelper).ResetActorAttributes, tbActorInfo)
    end
    do
      if (self.mapCharacterTempData).skillInfo ~= nil then
        local tbSkillInfos = {}
        for _,skillInfo in ipairs((self.mapCharacterTempData).skillInfo) do
          local stSkillInfo = (CS.Lua2CSharpInfo_ResetSkillInfo)()
          stSkillInfo.skillId = skillInfo.nSkillId
          stSkillInfo.currentSectionAmount = skillInfo.nSectionAmount
          stSkillInfo.cd = skillInfo.nCd
          stSkillInfo.currentResumeTime = skillInfo.nSectionResumeTime
          stSkillInfo.currentUseTimeHint = skillInfo.nUseTimeHint
          stSkillInfo.energy = skillInfo.nEnergy
          if tbSkillInfos[skillInfo.nCharId] == nil then
            tbSkillInfos[skillInfo.nCharId] = {}
          end
          ;
          (table.insert)(tbSkillInfos[skillInfo.nCharId], stSkillInfo)
        end
        safe_call_cs_func((CS.AdventureModuleHelper).ResetActorSkillInfo, tbSkillInfos)
      end
      if (self.mapCharacterTempData).buffInfo ~= nil then
        local tbBuffinfo = {}
        for nCharId,mapBuff in pairs((self.mapCharacterTempData).buffInfo) do
          if mapBuff.mapBuff ~= nil then
            for _,mapBuffInfo in pairs(mapBuff.mapBuff) do
              local stBuffInfo = (CS.Lua2CSharpInfo_ResetBuffInfo)()
              stBuffInfo.Id = mapBuffInfo.Id
              stBuffInfo.Cd = mapBuffInfo.CD
              stBuffInfo.buffNum = mapBuffInfo.nNum
              if tbBuffinfo[nCharId] == nil then
                tbBuffinfo[nCharId] = {}
              end
              ;
              (table.insert)(tbBuffinfo[nCharId], stBuffInfo)
            end
          end
        end
        safe_call_cs_func((CS.AdventureModuleHelper).ResetBuff, tbBuffinfo)
      end
    end
  end
end

StoryLevel.CacheTempData = function(self)
  -- function num : 0_17 , upvalues : _ENV
  local FP = (CS.TrueSync).FP
  self.mapCharacterTempData = {}
  local AdventureModuleHelper = CS.AdventureModuleHelper
  local id = (AdventureModuleHelper.GetCurrentActivePlayer)()
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).curCharId = ((CS.AdventureModuleHelper).GetCharacterId)(id)
  -- DECOMPILER ERROR at PC18: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).skillInfo = {}
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).effectInfo = {}
  -- DECOMPILER ERROR at PC24: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).buffInfo = {}
  -- DECOMPILER ERROR at PC27: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).hpInfo = {}
  -- DECOMPILER ERROR at PC30: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).stateInfo = {}
  local playerids = (AdventureModuleHelper.GetCurrentGroupPlayers)()
  local Count = playerids.Count - 1
  for i = 0, Count do
    local charTid = (AdventureModuleHelper.GetCharacterId)(playerids[i])
    local clsSkillId = (AdventureModuleHelper.GetPlayerSkillCd)(playerids[i])
    local nStatus = (AdventureModuleHelper.GetPlayerActorStatus)(playerids[i])
    local nStatusTime = (AdventureModuleHelper.GetPlayerActorSpecialStatusTime)(playerids[i])
    -- DECOMPILER ERROR at PC56: Confused about usage of register: R14 in 'UnsetPending'

    ;
    ((self.mapCharacterTempData).hpInfo)[charTid] = (AdventureModuleHelper.GetEntityHp)(playerids[i])
    if clsSkillId ~= nil then
      local tbSkillInfos = clsSkillId.skillInfos
      local nSkillCount = tbSkillInfos.Count - 1
      for j = 0, nSkillCount do
        local clsSkillInfo = tbSkillInfos[j]
        local mapSkill = (ConfigTable.GetData_Skill)(clsSkillInfo.skillId)
        if mapSkill.Type == (GameEnum.skillType).ULTIMATE then
          (table.insert)((self.mapCharacterTempData).skillInfo, {nCharId = charTid, nSkillId = clsSkillInfo.skillId, nCd = (clsSkillInfo.currentUseInterval).RawValue, nSectionAmount = clsSkillInfo.currentSectionAmount, nSectionResumeTime = (clsSkillInfo.currentResumeTime).RawValue, nUseTimeHint = (clsSkillInfo.currentUseTimeHint).RawValue, nEnergy = (clsSkillInfo.currentEnergy).RawValue})
        end
      end
      -- DECOMPILER ERROR at PC106: Confused about usage of register: R16 in 'UnsetPending'

      ;
      ((self.mapCharacterTempData).effectInfo)[charTid] = {
mapEffect = {}
}
      local tbClsEfts = (AdventureModuleHelper.GetEffectList)(playerids[i])
      if tbClsEfts ~= nil then
        local nEftCount = tbClsEfts.Count - 1
        for k = 0, nEftCount do
          local eftInfo = tbClsEfts[k]
          local mapEft = (ConfigTable.GetData_Effect)((eftInfo.effectConfig).Id)
          local nCd = (eftInfo.CD).RawValue
          -- DECOMPILER ERROR at PC140: Confused about usage of register: R25 in 'UnsetPending'

          if mapEft.Remove and nCd > 0 then
            ((((self.mapCharacterTempData).effectInfo)[charTid]).mapEffect)[(eftInfo.effectConfig).Id] = {nCount = 0, nCd = nCd}
          end
        end
      end
      do
        local tbBuffInfo = (AdventureModuleHelper.GetEntityBuffList)(playerids[i])
        -- DECOMPILER ERROR at PC150: Confused about usage of register: R18 in 'UnsetPending'

        ;
        ((self.mapCharacterTempData).buffInfo)[charTid] = {
mapBuff = {}
}
        if tbBuffInfo ~= nil then
          local nBuffCount = tbBuffInfo.Count - 1
          for l = 0, nBuffCount do
            local eftInfo = tbBuffInfo[l]
            local mapBuff = (ConfigTable.GetData_Buff)((eftInfo.buffConfig).Id)
            if mapBuff.NotRemove then
              (table.insert)((((self.mapCharacterTempData).buffInfo)[charTid]).mapBuff, {Id = (eftInfo.buffConfig).Id, CD = (eftInfo:GetBuffLeftTime()).RawValue, nNum = eftInfo:GetBuffNum()})
            end
          end
        end
        do
          do
            -- DECOMPILER ERROR at PC192: Confused about usage of register: R14 in 'UnsetPending'

            ;
            ((self.mapCharacterTempData).stateInfo)[charTid] = {nState = nStatus, nStateTime = nStatusTime}
            -- DECOMPILER ERROR at PC193: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC193: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC193: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC193: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
end

return StoryLevel

