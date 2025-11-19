local TowerDefenseLevelData = class("TowerDefenseLevelData")
local mapEventConfig = {LoadLevelRefresh = "OnEvent_LoadLevelRefresh", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", BattlePause = "OnEvent_Pause", JointDrill_StartTiming = "OnEvent_BattleStart", JointDrill_MonsterSpawn = "OnEvent_MonsterSpawn", JointDrill_BattleLvsToggle = "OnEvent_BattleLvsToggle", ADVENTURE_LEVEL_UNLOAD_COMPLETE = "OnEvent_UnloadComplete", JointDrill_Gameplay_Time = "OnEvent_JointDrill_Gameplay_Time", JointDrill_DamageValue = "OnEvent_GiveUpBattle", RestartJointDrill = "OnEvent_RestartJointDrill", RetreatJointDrill = "OnEvent_RetreatJointDrill", JointDrill_Result = "OnEvent_JointDrill_Result", InputEnable = "OnEvent_InputEnable"}
TowerDefenseLevelData.ctor = function(self)
  -- function num : 0_0
end

TowerDefenseLevelData.InitData = function(self, nLevelId, tbCharacter, nItemId, nActId)
  -- function num : 0_1
  self.nLevelId = nLevelId
  self.tbCharacterData = {}
  self.nActId = nActId
  self.tbCharacterId = tbCharacter
  self.nItemId = nItemId
  self.bRestart = false
  self:BindEvent()
end

TowerDefenseLevelData.Restart = function(self)
  -- function num : 0_2
  self.tbCharacterData = {}
  self.bRestart = true
end

TowerDefenseLevelData.AddCharacter = function(self, nCharacterId, nEntityId)
  -- function num : 0_3 , upvalues : _ENV
  local characterData = {nCharacterId = nCharacterId, nEntityId = nEntityId, nLevel = 1, 
tbPotentialList = {}
, nCD = ((ConfigTable.GetData)("TowerDefenseCharacter", nCharacterId)).SkillCd // 10000}
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.tbCharacterData)[nCharacterId] = characterData
end

TowerDefenseLevelData.CharacterLevelUp = function(self, nCharacterId)
  -- function num : 0_4 , upvalues : _ENV
  if (self.tbCharacterData)[nCharacterId] == nil then
    return 
  end
  local nLevel = ((self.tbCharacterData)[nCharacterId]).nLevel
  nLevel = (math.min)(6, nLevel + 1)
  -- DECOMPILER ERROR at PC16: Confused about usage of register: R3 in 'UnsetPending'

  ;
  ((self.tbCharacterData)[nCharacterId]).nLevel = nLevel
  ;
  (EventManager.Hit)("TowerDefenseChar_levelUp", nCharacterId, ((self.tbCharacterData)[nCharacterId]).nLevel)
end

TowerDefenseLevelData.AddPotential = function(self, nCharacterId, nPotentialId)
  -- function num : 0_5 , upvalues : _ENV
  if (self.tbCharacterData)[nCharacterId] == nil then
    return 
  end
  local stPerkInfo = (CS.Lua2CSharpInfo_TPPerkInfo)()
  stPerkInfo.perkId = nPotentialId
  stPerkInfo.nCount = 1
  local bChange = false
  if #((self.tbCharacterData)[nCharacterId]).tbPotentialList >= 1 then
    bChange = true
  end
  safe_call_cs_func((CS.AdventureModuleHelper).ChangePersonalPerkIds, {stPerkInfo}, nCharacterId, bChange)
  ;
  (table.insert)(((self.tbCharacterData)[nCharacterId]).tbPotentialList, nPotentialId)
end

TowerDefenseLevelData.RefreshCharSkillCd = function(self, nCharacterId, nCD)
  -- function num : 0_6
  if (self.tbCharacterData)[nCharacterId] == nil then
    return 
  end
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R3 in 'UnsetPending'

  ;
  ((self.tbCharacterData)[nCharacterId]).nCD = nCD
end

TowerDefenseLevelData.GetCharSkillCD = function(self, nCharacterId)
  -- function num : 0_7
  if (self.tbCharacterData)[nCharacterId] == nil then
    return nil
  end
  return ((self.tbCharacterData)[nCharacterId]).nCD
end

TowerDefenseLevelData.GetPotentialByChar = function(self, nCharacterId)
  -- function num : 0_8
  if (self.tbCharacterData)[nCharacterId] == nil then
    return nil
  end
  return ((self.tbCharacterData)[nCharacterId]).tbPotentialList
end

TowerDefenseLevelData.GetCharacterLevel = function(self, nCharacterId)
  -- function num : 0_9
  if (self.tbCharacterData)[nCharacterId] == nil then
    return nil
  end
  return ((self.tbCharacterData)[nCharacterId]).nLevel
end

TowerDefenseLevelData.GetCharacterEntityId = function(self, nCharacterId)
  -- function num : 0_10
  if (self.tbCharacterData)[nCharacterId] == nil then
    return nil
  end
  return ((self.tbCharacterData)[nCharacterId]).nEntityId
end

TowerDefenseLevelData.OnEvent_UnloadComplete = function(self)
  -- function num : 0_11 , upvalues : _ENV
  if not self.bRestart then
    (NovaAPI.EnterModule)("MainMenuModuleScene", true)
    self:UnBindEvent()
    return 
  end
  if self.nLevelId == 0 or self.nLevelId == nil then
    return 
  end
  self.bRestart = false
  local levelConfig = (ConfigTable.GetData)("TowerDefenseLevel", self.nLevelId)
  if levelConfig == nil then
    return 
  end
  ;
  (EventManager.Hit)(EventId.ClosePanel, PanelId.TowerDefensePanel)
  local sItem = tostring(self.nItemId)
  local sChar = ""
  for index,value in ipairs(self.tbCharacterId) do
    sChar = sChar .. tostring(value)
    if index ~= #self.tbCharacterId then
      sChar = sChar .. ","
    end
  end
  local param = {}
  ;
  (table.insert)(param, sItem)
  ;
  (table.insert)(param, sChar)
  ;
  ((CS.AdventureModuleHelper).EnterTowerDefenseLevel)(levelConfig.FloorId, param)
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.TowerDefensePanel, self.nActId, self.nLevelId)
end

TowerDefenseLevelData.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_12 , upvalues : _ENV
  (EventManager.Hit)(EventId.OpenPanel, PanelId.TowerDefensePanel, self.nActId, self.nLevelId)
end

TowerDefenseLevelData.BindEvent = function(self)
  -- function num : 0_13 , upvalues : _ENV, mapEventConfig
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

TowerDefenseLevelData.UnBindEvent = function(self)
  -- function num : 0_14 , upvalues : _ENV, mapEventConfig
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

return TowerDefenseLevelData

