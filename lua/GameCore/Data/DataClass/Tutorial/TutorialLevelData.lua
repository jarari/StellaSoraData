local TutorialLevelData = class("TutorialLevelData")
local AdventureModuleHelper = CS.AdventureModuleHelper
local mapEventConfig = {UpdateOperationTips = "OnEvent_UpdateTips", OpenTutorialCard = "OnEvent_OpenTutorialCard", TaskLevel_TaskFinish = "OnEvent_UpdateFinishTaskCount", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", TutorialLevelSuccess = "OnEvent_LevelSuccess", TutorialPotentialSelect = "OnEvent_PotentialSelect", TutorialRefreshNoteCount = "OnEvent_RefreshNoteCount", Trigger_Guide_Index = "OnEvent_GuideStart", GuideEnd = "OnEvent_GuideEnd", ShowTutorialButtonHint = "OnEvent_ShowButtonHint"}
TutorialLevelData.ctor = function(self)
  -- function num : 0_0
end

TutorialLevelData.InitData = function(self)
  -- function num : 0_1
  self.nlevelId = 0
  self.tbCharId = {}
  self.tbDiscId = {}
  self.CardId = 0
  self.TipsKey = ""
  self.CurQuestCount = 0
  self.MaxQuestCount = 0
  self.levelConfig = nil
  self.floorConfig = nil
end

TutorialLevelData.InitLevelData = function(self, levelId, tbCharId, tbDiscId)
  -- function num : 0_2 , upvalues : _ENV
  self:InitData()
  self:BindEvent()
  self.nlevelId = levelId
  self.levelConfig = (ConfigTable.GetData)("TutorialLevel", self.nlevelId)
  self.floorConfig = (ConfigTable.GetData)("TutorialLevelFloor", (self.levelConfig).FloorId)
  self.mapBuildData = (PlayerData.Build):GetTrialBuild((self.levelConfig).TutorialBuild)
  self.tbCharacterPotential = {}
  self.mapTalentAddLevel = {}
  self.mapCharData = {}
  self.tbCharTrialId = {}
  self.tbCharId = {}
  for _,mapChar in ipairs((self.mapBuildData).tbChar) do
    (table.insert)(self.tbCharId, mapChar.nTid)
    -- DECOMPILER ERROR at PC48: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self.tbCharTrialId)[mapChar.nTid] = mapChar.nTrialId
    -- DECOMPILER ERROR at PC56: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self.mapCharData)[mapChar.nTid] = (PlayerData.Char):GetTrialCharById(mapChar.nTrialId)
    -- DECOMPILER ERROR at PC64: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self.mapTalentAddLevel)[mapChar.nTid] = (PlayerData.Talent):GetTrialEnhancedPotential(mapChar.nTrialId)
  end
  self.mapDiscData = {}
  self.tbDiscId = {}
  for _,nDiscId in ipairs((self.mapBuildData).tbDisc) do
    if nDiscId > 0 then
      (table.insert)(self.tbDiscId, nDiscId)
      local mapCfg = (ConfigTable.GetData)("TrialDisc", nDiscId)
      -- DECOMPILER ERROR at PC97: Confused about usage of register: R10 in 'UnsetPending'

      if mapCfg then
        (self.mapDiscData)[mapCfg.DiscId] = (PlayerData.Disc):GetTrialDiscById(nDiscId)
      end
    end
  end
  self.MaxQuestCount = #(self.floorConfig).QuestFlow
end

TutorialLevelData.FinishLevel = function(self, result)
  -- function num : 0_3 , upvalues : _ENV, AdventureModuleHelper
  self:UnBindEvent()
  local nCurQuestCount = self:GetCurQuestCount() or 0
  local nMaxQuestCount = self:GetMaxQuestCount() or 0
  if not self:GetCharList() then
    local tbCharId = {}
  end
  if not result then
    (EventManager.Hit)(EventId.OpenPanel, PanelId.TutorialResult, 2, self.nlevelId, {}, nCurQuestCount, nMaxQuestCount, tbCharId, {}, false)
  else
    local tbSkin = {}
    do
      for _,nCharId in ipairs(self.tbCharId) do
        local nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
        ;
        (table.insert)(tbSkin, nSkinId)
      end
      local func_SettlementFinish = function()
    -- function num : 0_3_0
  end

      local levelEndCallback = function()
    -- function num : 0_3_1 , upvalues : _ENV, self, levelEndCallback, AdventureModuleHelper, tbSkin, func_SettlementFinish
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    local levelConfig = (ConfigTable.GetData)("TutorialLevel", self.nlevelId)
    if levelConfig == nil then
      return 
    end
    local floorConfig = (ConfigTable.GetData)("TutorialLevelFloor", levelConfig.FloorId)
    if floorConfig == nil then
      return 
    end
    local nType = floorConfig.Theme
    local sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
    print("sceneName:" .. sName)
    ;
    (AdventureModuleHelper.PlaySettlementPerform)(sName, "", tbSkin, func_SettlementFinish)
  end

      ;
      (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
      local openBattleResultPanel = function()
    -- function num : 0_3_2 , upvalues : _ENV, self, openBattleResultPanel, nCurQuestCount, nMaxQuestCount, tbCharId
    (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.TutorialResult, 1, self.nlevelId, {}, nCurQuestCount, nMaxQuestCount, tbCharId, {}, false)
    ;
    (PlayerData.Build):DeleteTrialBuild()
  end

      ;
      (EventManager.Add)("SettlementPerformLoadFinish", self, openBattleResultPanel)
      ;
      (AdventureModuleHelper.LevelStateChanged)(true)
      ;
      (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResultMask)
    end
  end
end

TutorialLevelData.GetCurDicId = function(self)
  -- function num : 0_4
  return self.CardId
end

TutorialLevelData.GetCurQuestCount = function(self)
  -- function num : 0_5
  return self.CurQuestCount
end

TutorialLevelData.GetMaxQuestCount = function(self)
  -- function num : 0_6
  return self.MaxQuestCount
end

TutorialLevelData.GetCharList = function(self)
  -- function num : 0_7
  return self.tbCharId
end

TutorialLevelData.SetDiscInfo = function(self)
  -- function num : 0_8 , upvalues : _ENV
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

TutorialLevelData.CalCharFixedEffect = function(self, nTrialId, bMainChar, tbDiscId)
  -- function num : 0_9 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterTrialAttrBattle(nTrialId, stActorInfo, bMainChar, tbDiscId, (self.levelConfig).TutorialBuild)
  return stActorInfo
end

TutorialLevelData.GetCharIdByBtnName = function(self, btnName)
  -- function num : 0_10
  if self.tbCharId == nil then
    return 
  end
  if btnName == "Fire1" or btnName == "Fire2" or btnName == "Fire3" or btnName == "Fire4" then
    return (self.tbCharId)[1]
  else
    if btnName == "ActorSwitch1" or btnName == "SwitchWithUltra1" then
      return (self.tbCharId)[2]
    else
      if btnName == "ActorSwitch2" or btnName == "SwitchWithUltra2" then
        return (self.tbCharId)[3]
      end
    end
  end
end

TutorialLevelData.GetByBtnType = function(self, btnName)
  -- function num : 0_11
  if btnName == "Fire1" or btnName == "Fire3" then
    return 1
  else
    if btnName == "ActorSwitch1" or btnName == "ActorSwitch2" or btnName == "Fire2" then
      return 2
    else
      if btnName == "SwitchWithUltra1" or btnName ~= "SwitchWithUltra2" then
        do return 4 end
      end
    end
  end
end

TutorialLevelData.OnEvent_UpdateTips = function(self, tipsKey)
  -- function num : 0_12 , upvalues : _ENV
  if tipsKey == self.TipsKey then
    return 
  end
  self.TipsKey = tipsKey
  ;
  (EventManager.Hit)("Tutorial_UpdateTips", self.TipsKey)
end

TutorialLevelData.OnEvent_OpenTutorialCard = function(self, cardId, bIsLevelStart)
  -- function num : 0_13 , upvalues : _ENV
  self.CardId = cardId
  ;
  (EventManager.Hit)("Tutorial_OpenCard", self.CardId, bIsLevelStart)
end

TutorialLevelData.OnEvent_UpdateFinishTaskCount = function(self, isLast)
  -- function num : 0_14
  self.CurQuestCount = self.CurQuestCount + 1
end

TutorialLevelData.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_15 , upvalues : _ENV
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
  (EventManager.Hit)(EventId.OpenPanel, PanelId.TutorialPanel, self.tbCharId, tbDisc, self.mapCharData, self.mapDiscData)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

TutorialLevelData.OnEvent_LevelSuccess = function(self)
  -- function num : 0_16 , upvalues : _ENV
  (EventManager.Hit)("TutorialLevel_Success")
end

TutorialLevelData.OnEvent_PotentialSelect = function(self, potentialData)
  -- function num : 0_17 , upvalues : _ENV
  local potentialList = {}
  for _,pot in pairs(potentialData) do
    (table.insert)(potentialList, pot)
  end
  local callback = function(index)
    -- function num : 0_17_0 , upvalues : potentialList, _ENV, self
    local nPotentialId = potentialList[index]
    local potConfig = (ConfigTable.GetData)("Potential", nPotentialId)
    if potConfig == nil then
      return 
    end
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R3 in 'UnsetPending'

    if (self.tbCharacterPotential)[potConfig.CharId] == nil then
      (self.tbCharacterPotential)[potConfig.CharId] = {}
    end
    local stPerkInfo = (CS.Lua2CSharpInfo_TPPerkInfo)()
    stPerkInfo.perkId = nPotentialId
    stPerkInfo.nCount = 1
    local bChange = false
    if #(self.tbCharacterPotential)[potConfig.CharId] >= 1 then
      bChange = true
    end
    safe_call_cs_func((CS.AdventureModuleHelper).ChangePersonalPerkIds, {stPerkInfo}, potConfig.CharId, bChange)
    ;
    (table.insert)((self.tbCharacterPotential)[potConfig.CharId], nPotentialId)
  end

  ;
  (EventManager.Hit)("Tutorial_PotentialSelect", potentialList, callback)
end

TutorialLevelData.OnEvent_GuideStart = function(self, index)
  -- function num : 0_18
  self.GuideIndex = index
end

TutorialLevelData.OnEvent_GuideEnd = function(self)
  -- function num : 0_19 , upvalues : _ENV
  (NovaAPI.DispatchEventWithData)("Tutorial_GuideEnd", nil, {self.GuideIndex})
end

TutorialLevelData.OnEvent_RefreshNoteCount = function(self, note, dropNote, activeSkills)
  -- function num : 0_20 , upvalues : _ENV
  local noteList = {}
  local dropNoteList = {}
  local mapChangeSecondarySkill = {}
  for id,count in pairs(note) do
    noteList[id] = count
  end
  for id,count in pairs(dropNote) do
    local bIsNew = count - noteList[id] == 0
    dropNoteList[id] = {Tid = id, LuckyLevel = 0, New = bIsNew, Qty = count}
  end
  for id,v in pairs(activeSkills) do
    local skillData = {Active = true, SecondaryId = v}
    ;
    (table.insert)(mapChangeSecondarySkill, skillData)
  end
  self:ResetNoteInfo(noteList)
  self:ResetDiscInfo(noteList)
  ;
  (EventManager.Hit)("RefreshNoteCount", noteList, dropNoteList, mapChangeSecondarySkill, false)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

TutorialLevelData.OnEvent_ShowButtonHint = function(self, btnName, isShow)
  -- function num : 0_21 , upvalues : _ENV
  local charId = self:GetCharIdByBtnName(btnName)
  local btnId = self:GetByBtnType(btnName)
  ;
  (EventManager.Hit)("Open_Ultra_Special_FX", charId * 10 + btnId, isShow)
end

TutorialLevelData.ResetNoteInfo = function(self, noteList)
  -- function num : 0_22 , upvalues : _ENV
  local tbNoteInfo = {}
  for i,v in pairs(noteList) do
    local noteInfo = (CS.Lua2CSharpInfo_NoteInfo)()
    noteInfo.noteId = i
    noteInfo.noteCount = v
    ;
    (table.insert)(tbNoteInfo, noteInfo)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetNoteInfo, tbNoteInfo)
end

TutorialLevelData.ResetDiscInfo = function(self, noteList)
  -- function num : 0_23 , upvalues : _ENV
  local tbDiscInfo = {}
  for nDiscId,mapDiscData in pairs(self.mapDiscData) do
    if (table.indexof)(self.tbDiscId, nDiscId) <= 3 and mapDiscData ~= nil then
      local discInfo = mapDiscData:GetDiscInfo(noteList)
      ;
      (table.insert)(tbDiscInfo, discInfo)
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetDiscInfo, tbDiscInfo)
end

TutorialLevelData.BindEvent = function(self)
  -- function num : 0_24 , upvalues : _ENV, mapEventConfig
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

TutorialLevelData.UnBindEvent = function(self)
  -- function num : 0_25 , upvalues : _ENV, mapEventConfig
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

return TutorialLevelData

