local PlayerTalentData = class("PlayerTalentData")
local TimerManager = require("GameCore.Timer.TimerManager")
PlayerTalentData.Init = function(self)
  -- function num : 0_0
  self._tbCharTalentGroup = {}
  self._tbCharTalentNode = {}
  self._tbCharEnhancedSkill = {}
  self._tbCharEnhancedPotential = {}
  self._tbCharFateTalent = {}
  self._tbTalentBgIndex = {}
  self:ProcessTableData()
end

PlayerTalentData.ProcessTableData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local func_ForEach_Group = function(mapData)
    -- function num : 0_1_0 , upvalues : _ENV
    (CacheTable.SetField)("_TalentGroup", mapData.CharId, mapData.Id, mapData)
  end

  ForEachTableLine(DataTable.TalentGroup, func_ForEach_Group)
  local func_ForEach_Line = function(mapData)
    -- function num : 0_1_1 , upvalues : _ENV
    (CacheTable.SetField)("_Talent", mapData.GroupId, mapData.Id, mapData)
    local nCharId = ((ConfigTable.GetData)("TalentGroup", mapData.GroupId)).CharId
    ;
    (CacheTable.SetField)("_TalentByIndex", nCharId, mapData.Index, mapData)
  end

  ForEachTableLine(DataTable.Talent, func_ForEach_Line)
  self.FragmentsToChar = {}
  local func_ForEach_Char = function(mapData)
    -- function num : 0_1_2 , upvalues : self
    -- DECOMPILER ERROR at PC3: Confused about usage of register: R1 in 'UnsetPending'

    (self.FragmentsToChar)[mapData.FragmentsId] = mapData.Id
  end

  ForEachTableLine(DataTable.Character, func_ForEach_Char)
end

PlayerTalentData.CreateNewTalentData = function(self, nCharId, tbActive)
  -- function num : 0_2 , upvalues : _ENV
  local tbActiveTalent = {}
  local nMaxNormalCount = 0
  local groupData = {}
  local nFirstGroup = 0
  local tbGroupCfg = (CacheTable.GetData)("_TalentGroup", nCharId)
  if not tbGroupCfg then
    printError("TalentGroup表找不到该角色" .. nCharId)
    tbGroupCfg = {}
  end
  for nGroupId,mapGroup in pairs(tbGroupCfg) do
    if not groupData[nGroupId] then
      local mapCurGroup = self:CreateTalentGroup(nGroupId)
    end
    groupData[nGroupId] = mapCurGroup
    if mapGroup.PreGroup ~= 0 then
      local mapPreGroup = groupData[mapGroup.PreGroup]
      if not mapPreGroup then
        mapPreGroup = self:CreateTalentGroup(mapGroup.PreGroup)
        groupData[mapGroup.PreGroup] = mapPreGroup
      end
      mapPreGroup.nNext = nGroupId
    else
      do
        nFirstGroup = nGroupId
        nMaxNormalCount = nMaxNormalCount + mapGroup.NodeLimit
        if not (CacheTable.GetData)("_Talent", nGroupId) then
          local tbTalent = {}
        end
        for _,v in pairs(tbTalent) do
          -- DECOMPILER ERROR at PC67: Confused about usage of register: R20 in 'UnsetPending'

          if v.Type == (GameEnum.talentType).KeyNode then
            (groupData[nGroupId]).nKeyTalent = v.Id
            break
          end
        end
        do
          -- DECOMPILER ERROR at PC71: LeaveBlock: unexpected jumping out DO_STMT

          -- DECOMPILER ERROR at PC71: LeaveBlock: unexpected jumping out IF_ELSE_STMT

          -- DECOMPILER ERROR at PC71: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  if type(tbActive) == "table" then
    for _,nTalentId in pairs(tbActive) do
      tbActiveTalent[nTalentId] = true
      local mapCfg = (ConfigTable.GetData)("Talent", nTalentId)
      local nType = mapCfg.Type
      -- DECOMPILER ERROR at PC100: Confused about usage of register: R15 in 'UnsetPending'

      if nType == (GameEnum.talentType).OrdinaryNode then
        (groupData[mapCfg.GroupId]).nNormalCount = (groupData[mapCfg.GroupId]).nNormalCount + 1
      end
    end
  end
  do
    local nAllCount = 0
    for _,v in pairs(groupData) do
      nAllCount = nAllCount + v.nNormalCount
    end
    local talentData = {nMaxNormalCount = nMaxNormalCount, nFirstGroup = nFirstGroup, tbActiveTalent = tbActiveTalent, nAllNormalCount = nAllCount}
    return talentData, groupData
  end
end

PlayerTalentData.CreateTalentGroup = function(self, nId)
  -- function num : 0_3
  return {nId = nId, nNext = 0, nKeyTalent = 0, bLock = true, nNormalCount = 0}
end

PlayerTalentData.UpdateTalentGroupLock = function(self, nCharId)
  -- function num : 0_4
  local bPreGroupLock = false
  local bPreKeyLock = false
  local nGroupId = ((self._tbCharTalentNode)[nCharId]).nFirstGroup
  local mapCurGroup = ((self._tbCharTalentGroup)[nCharId])[nGroupId]
  while mapCurGroup do
    local nKeyTalent = mapCurGroup.nKeyTalent
    local bLock = bPreGroupLock or bPreKeyLock
    -- DECOMPILER ERROR at PC18: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (((self._tbCharTalentGroup)[nCharId])[mapCurGroup.nId]).bLock = bLock
    mapCurGroup = ((self._tbCharTalentGroup)[nCharId])[mapCurGroup.nNext]
    bPreKeyLock = not (((self._tbCharTalentNode)[nCharId]).tbActiveTalent)[nKeyTalent]
    bPreGroupLock = bLock
  end
end

PlayerTalentData.CreateEnhancedSkill = function(self, nCharId, tbTalentId)
  -- function num : 0_5 , upvalues : _ENV
  local charCfgData = (ConfigTable.GetData_Character)(nCharId)
  if not charCfgData then
    printError("Character表找不到该角色" .. nCharId)
    return {}
  end
  local mapSkill = {[charCfgData.NormalAtkId] = 0, [charCfgData.SkillId] = 0, [charCfgData.AssistSkillId] = 0, [charCfgData.UltimateId] = 0}
  for _,v in pairs(tbTalentId) do
    local mapCfg = (ConfigTable.GetData)("Talent", v)
    local nSkillId = mapCfg.EnhanceSkillId
    if nSkillId > 0 and mapSkill[nSkillId] then
      mapSkill[nSkillId] = mapSkill[nSkillId] + mapCfg.EnhanceSkillLevel
    end
  end
  return mapSkill
end

PlayerTalentData.CreateEnhancedPotential = function(self, tbTalentId)
  -- function num : 0_6 , upvalues : _ENV
  local mapPotential = {}
  for _,v in pairs(tbTalentId) do
    local mapCfg = (ConfigTable.GetData)("Talent", v)
    local nPotentialId = mapCfg.EnhancePotentialId
    if nPotentialId > 0 then
      if not mapPotential[nPotentialId] then
        mapPotential[nPotentialId] = 0
      end
      mapPotential[nPotentialId] = mapPotential[nPotentialId] + mapCfg.EnhancePotentialLevel
    end
  end
  return mapPotential
end

PlayerTalentData.CreateFateTalent = function(self, tbAllTalent)
  -- function num : 0_7 , upvalues : _ENV
  local nFateCount = 0
  local tbFateTypeTalent = {}
  for nIndex,v in pairs(tbAllTalent) do
    if v.Type == (GameEnum.talentType).KeyNode and v.SubType > 0 then
      nFateCount = nFateCount + 1
      tbFateTypeTalent[v.SubType] = v.Id
    end
  end
  local tbFateTalent = {}
  for i = 1, nFateCount do
    local nId = tbFateTypeTalent[(GameEnum.talentSubType)["Fate" .. i]]
    tbFateTalent[i] = nId
  end
  return tbFateTalent
end

PlayerTalentData.CacheTalentData = function(self, mapMsgData, nTalentResetTime)
  -- function num : 0_8 , upvalues : _ENV
  if self._tbCharTalentNode == nil then
    self._tbCharTalentNode = {}
  end
  if self._tbCharTalentGroup == nil then
    self._tbCharTalentGroup = {}
  end
  for _,mapCharInfo in ipairs(mapMsgData) do
    local nCharId = mapCharInfo.Tid
    local tbTalent = (CacheTable.GetData)("_TalentByIndex", nCharId)
    if tbTalent == nil then
      printError("Talent表找不到该角色" .. nCharId)
      tbTalent = {}
    end
    local tbActive = {}
    local tbNodes = (UTILS.ParseByteString)(mapCharInfo.TalentNodes)
    for nIndex,v in pairs(tbTalent) do
      local bActive = (UTILS.IsBitSet)(tbNodes, nIndex)
      if bActive then
        (table.insert)(tbActive, v.Id)
      end
    end
    local talentData, groupData = self:CreateNewTalentData(nCharId, tbActive)
    -- DECOMPILER ERROR at PC57: Confused about usage of register: R14 in 'UnsetPending'

    ;
    (self._tbCharTalentNode)[nCharId] = talentData
    -- DECOMPILER ERROR at PC59: Confused about usage of register: R14 in 'UnsetPending'

    ;
    (self._tbCharTalentGroup)[nCharId] = groupData
    -- DECOMPILER ERROR at PC65: Confused about usage of register: R14 in 'UnsetPending'

    ;
    (self._tbCharEnhancedSkill)[nCharId] = self:CreateEnhancedSkill(nCharId, tbActive)
    -- DECOMPILER ERROR at PC70: Confused about usage of register: R14 in 'UnsetPending'

    ;
    (self._tbCharEnhancedPotential)[nCharId] = self:CreateEnhancedPotential(tbActive)
    -- DECOMPILER ERROR at PC75: Confused about usage of register: R14 in 'UnsetPending'

    ;
    (self._tbCharFateTalent)[nCharId] = self:CreateFateTalent(tbTalent)
    -- DECOMPILER ERROR at PC78: Confused about usage of register: R14 in 'UnsetPending'

    ;
    (self._tbTalentBgIndex)[nCharId] = mapCharInfo.TalentBackground
    self:UpdateTalentGroupLock(nCharId)
  end
end

PlayerTalentData.ResetTalentEnhanceLevel = function(self, nCharId, mapCfg)
  -- function num : 0_9
  local nSkillId = mapCfg.EnhanceSkillId
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R4 in 'UnsetPending'

  if nSkillId > 0 and ((self._tbCharEnhancedSkill)[nCharId])[nSkillId] then
    ((self._tbCharEnhancedSkill)[nCharId])[nSkillId] = ((self._tbCharEnhancedSkill)[nCharId])[nSkillId] - mapCfg.EnhanceSkillLevel
  end
  local nPotentialId = mapCfg.EnhancePotentialId
  -- DECOMPILER ERROR at PC31: Confused about usage of register: R5 in 'UnsetPending'

  if nPotentialId > 0 and ((self._tbCharEnhancedPotential)[nCharId])[nPotentialId] then
    ((self._tbCharEnhancedPotential)[nCharId])[nPotentialId] = ((self._tbCharEnhancedPotential)[nCharId])[nPotentialId] - mapCfg.EnhancePotentialLevel
  end
end

PlayerTalentData.ResetTalentNode = function(self, nCharId, nTalentId, bResetKey)
  -- function num : 0_10 , upvalues : _ENV
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R4 in 'UnsetPending'

  ((self._tbCharTalentNode)[nCharId]).nAllNormalCount = ((self._tbCharTalentNode)[nCharId]).nAllNormalCount - 1
  local mapCfg = (ConfigTable.GetData)("Talent", nTalentId)
  local nGroupId = mapCfg.GroupId
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (((self._tbCharTalentGroup)[nCharId])[nGroupId]).nNormalCount = (((self._tbCharTalentGroup)[nCharId])[nGroupId]).nNormalCount - 1
  -- DECOMPILER ERROR at PC31: Confused about usage of register: R6 in 'UnsetPending'

  if (((self._tbCharTalentNode)[nCharId]).tbActiveTalent)[nTalentId] then
    (((self._tbCharTalentNode)[nCharId]).tbActiveTalent)[nTalentId] = false
    self:ResetTalentEnhanceLevel(nCharId, mapCfg)
  end
  if bResetKey then
    local tbTalent = (CacheTable.GetData)("_Talent", nGroupId)
    for k,v in pairs(tbTalent) do
      -- DECOMPILER ERROR at PC62: Confused about usage of register: R12 in 'UnsetPending'

      if v.Type == (GameEnum.talentType).KeyNode and (((self._tbCharTalentNode)[nCharId]).tbActiveTalent)[k] then
        (((self._tbCharTalentNode)[nCharId]).tbActiveTalent)[k] = false
        self:ResetTalentEnhanceLevel(nCharId, v)
      end
    end
  end
  do
    self:UpdateTalentGroupLock(nCharId)
  end
end

PlayerTalentData.ResetTalent = function(self, nCharId, nGroupId)
  -- function num : 0_11 , upvalues : _ENV
  local tbTalent = (CacheTable.GetData)("_Talent", nGroupId)
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R4 in 'UnsetPending'

  ;
  ((self._tbCharTalentNode)[nCharId]).nAllNormalCount = ((self._tbCharTalentNode)[nCharId]).nAllNormalCount - (((self._tbCharTalentGroup)[nCharId])[nGroupId]).nNormalCount
  -- DECOMPILER ERROR at PC19: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (((self._tbCharTalentGroup)[nCharId])[nGroupId]).nNormalCount = 0
  for nTalentId,v in pairs(tbTalent) do
    -- DECOMPILER ERROR at PC33: Confused about usage of register: R9 in 'UnsetPending'

    if (((self._tbCharTalentNode)[nCharId]).tbActiveTalent)[nTalentId] then
      (((self._tbCharTalentNode)[nCharId]).tbActiveTalent)[nTalentId] = false
      self:ResetTalentEnhanceLevel(nCharId, v)
    end
  end
  self:UpdateTalentGroupLock(nCharId)
end

PlayerTalentData.ResetAllTalent = function(self, nCharId)
  -- function num : 0_12 , upvalues : _ENV
  local tbGroup = (CacheTable.GetData)("_TalentGroup", nCharId)
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R3 in 'UnsetPending'

  ;
  ((self._tbCharTalentNode)[nCharId]).nAllNormalCount = 0
  -- DECOMPILER ERROR at PC11: Confused about usage of register: R3 in 'UnsetPending'

  ;
  ((self._tbCharTalentNode)[nCharId]).tbActiveTalent = {}
  for nId,_ in pairs(tbGroup) do
    -- DECOMPILER ERROR at PC19: Confused about usage of register: R8 in 'UnsetPending'

    (((self._tbCharTalentGroup)[nCharId])[nId]).nNormalCount = 0
  end
  self:UpdateTalentGroupLock(nCharId)
  for k,_ in pairs((self._tbCharEnhancedSkill)[nCharId]) do
    -- DECOMPILER ERROR at PC32: Confused about usage of register: R8 in 'UnsetPending'

    ((self._tbCharEnhancedSkill)[nCharId])[k] = 0
  end
  for k,_ in pairs((self._tbCharEnhancedPotential)[nCharId]) do
    -- DECOMPILER ERROR at PC42: Confused about usage of register: R8 in 'UnsetPending'

    ((self._tbCharEnhancedPotential)[nCharId])[k] = 0
  end
end

PlayerTalentData.UnlockTalent = function(self, nCharId, nTalentId)
  -- function num : 0_13 , upvalues : _ENV
  -- DECOMPILER ERROR at PC3: Confused about usage of register: R3 in 'UnsetPending'

  (((self._tbCharTalentNode)[nCharId]).tbActiveTalent)[nTalentId] = true
  local mapCfg = (ConfigTable.GetData)("Talent", nTalentId)
  local nGroupId = mapCfg.GroupId
  if mapCfg.Type == (GameEnum.talentType).KeyNode then
    self:UpdateTalentGroupLock(nCharId)
  else
    -- DECOMPILER ERROR at PC28: Confused about usage of register: R5 in 'UnsetPending'

    ;
    (((self._tbCharTalentGroup)[nCharId])[nGroupId]).nNormalCount = (((self._tbCharTalentGroup)[nCharId])[nGroupId]).nNormalCount + 1
    -- DECOMPILER ERROR at PC35: Confused about usage of register: R5 in 'UnsetPending'

    ;
    ((self._tbCharTalentNode)[nCharId]).nAllNormalCount = ((self._tbCharTalentNode)[nCharId]).nAllNormalCount + 1
  end
  local nSkillId = mapCfg.EnhanceSkillId
  -- DECOMPILER ERROR at PC46: Confused about usage of register: R6 in 'UnsetPending'

  if nSkillId > 0 then
    if not ((self._tbCharEnhancedSkill)[nCharId])[nSkillId] then
      ((self._tbCharEnhancedSkill)[nCharId])[nSkillId] = 0
    end
    -- DECOMPILER ERROR at PC54: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self._tbCharEnhancedSkill)[nCharId])[nSkillId] = ((self._tbCharEnhancedSkill)[nCharId])[nSkillId] + mapCfg.EnhanceSkillLevel
  end
  local nPotentialId = mapCfg.EnhancePotentialId
  -- DECOMPILER ERROR at PC65: Confused about usage of register: R7 in 'UnsetPending'

  if nPotentialId > 0 then
    if not ((self._tbCharEnhancedPotential)[nCharId])[nPotentialId] then
      ((self._tbCharEnhancedPotential)[nCharId])[nPotentialId] = 0
    end
    -- DECOMPILER ERROR at PC73: Confused about usage of register: R7 in 'UnsetPending'

    ;
    ((self._tbCharEnhancedPotential)[nCharId])[nPotentialId] = ((self._tbCharEnhancedPotential)[nCharId])[nPotentialId] + mapCfg.EnhancePotentialLevel
  end
end

PlayerTalentData.SetTimer = function(self, nTime)
  -- function num : 0_14 , upvalues : TimerManager
  if nTime <= 0 then
    return 
  end
  local stopcd = function()
    -- function num : 0_14_0 , upvalues : self
    if self.timercd ~= nil then
      (self.timercd):Cancel(false)
      self.timercd = nil
    end
    self.nCd = 0
  end

  self.bTalentResetCD = true
  if self.timer ~= nil then
    (self.timer):Cancel(false)
    self.timer = nil
    stopcd()
  end
  self.nCd = nTime
  self.timer = (TimerManager.Add)(1, nTime, self, function()
    -- function num : 0_14_1 , upvalues : self, stopcd
    self.bTalentResetCD = false
    stopcd()
  end
, true, true, false)
  self.timercd = (TimerManager.Add)(0, 1, self, function()
    -- function num : 0_14_2 , upvalues : self
    self.nCd = self.nCd - 1
  end
, true, true, false)
end

PlayerTalentData.GetTalentNode = function(self, nCharId)
  -- function num : 0_15
  return (self._tbCharTalentNode)[nCharId]
end

PlayerTalentData.GetTalentGroup = function(self, nCharId)
  -- function num : 0_16
  return (self._tbCharTalentGroup)[nCharId]
end

PlayerTalentData.GetTalentBg = function(self, nCharId)
  -- function num : 0_17
  return (self._tbTalentBgIndex)[nCharId]
end

PlayerTalentData.GetSortedTalentGroup = function(self, nCharId)
  -- function num : 0_18 , upvalues : _ENV
  local tbSorted = {}
  local nFirstGroup = ((self._tbCharTalentNode)[nCharId]).nFirstGroup
  local mapCurGroup = ((self._tbCharTalentGroup)[nCharId])[nFirstGroup]
  while mapCurGroup do
    (table.insert)(tbSorted, mapCurGroup)
    mapCurGroup = ((self._tbCharTalentGroup)[nCharId])[mapCurGroup.nNext]
  end
  return tbSorted
end

PlayerTalentData.GetEnhancedSkill = function(self, nCharId)
  -- function num : 0_19
  return (self._tbCharEnhancedSkill)[nCharId]
end

PlayerTalentData.GetEnhancedPotential = function(self, nCharId)
  -- function num : 0_20
  return (self._tbCharEnhancedPotential)[nCharId]
end

PlayerTalentData.GetFateTalent = function(self, nCharId)
  -- function num : 0_21 , upvalues : _ENV
  local tbFate = {}
  if not (self._tbCharFateTalent)[nCharId] then
    return tbFate
  end
  for i,v in ipairs((self._tbCharFateTalent)[nCharId]) do
    tbFate[i] = self:CheckTalentActive(nCharId, v)
  end
  return tbFate
end

PlayerTalentData.GetFateTalentByTalentNodes = function(self, nCharId, tbActive)
  -- function num : 0_22 , upvalues : _ENV
  local tbFate = {}
  if not (self._tbCharFateTalent)[nCharId] then
    return tbFate
  end
  for i,v in ipairs((self._tbCharFateTalent)[nCharId]) do
    tbFate[i] = (table.indexof)(tbActive, v) > 0
  end
  do return tbFate end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerTalentData.GetFragmentsToChar = function(self, nFragmentsId)
  -- function num : 0_23
  return (self.FragmentsToChar)[nFragmentsId]
end

PlayerTalentData.GetOverFragments = function(self, nCharId)
  -- function num : 0_24 , upvalues : _ENV
  local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
  local mapGradeCfg = (ConfigTable.GetData)("CharGrade", mapCharCfg.Grade)
  local mapChar = (PlayerData.Char):GetCharDataByTid(nCharId)
  local nCompositeFragments = 0
  if mapChar == nil then
    nCompositeFragments = mapCharCfg.RecruitmentQty
  end
  local nNodeFragments = mapGradeCfg.FragmentsQty
  local mapTalent = (self._tbCharTalentNode)[nCharId]
  local nNodeCount = 0
  if mapTalent then
    nNodeCount = mapTalent.nMaxNormalCount - mapTalent.nAllNormalCount
  end
  local nHas = (PlayerData.Item):GetItemCountByID(mapCharCfg.FragmentsId)
  local nOverflow = nHas - (nNodeCount) * nNodeFragments - nCompositeFragments
  return nOverflow > 0 and nOverflow or 0
end

PlayerTalentData.GetRemainFragments = function(self, nCharId, nHas)
  -- function num : 0_25 , upvalues : _ENV
  local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
  local mapGradeCfg = (ConfigTable.GetData)("CharGrade", mapCharCfg.Grade)
  local nNodeFragments = mapGradeCfg.FragmentsQty
  local nMaxNormalCount = 0
  local tbGroupCfg = (CacheTable.GetData)("_TalentGroup", nCharId)
  if not tbGroupCfg then
    printError("TalentGroup表找不到该角色" .. nCharId)
    tbGroupCfg = {}
  end
  for _,mapGroup in pairs(tbGroupCfg) do
    nMaxNormalCount = nMaxNormalCount + mapGroup.NodeLimit
  end
  if not nHas then
    nHas = (PlayerData.Item):GetItemCountByID(mapCharCfg.FragmentsId)
  end
  local mapTalent = self:GetTalentNode(nCharId)
  local nCompositeFragments = mapCharCfg.RecruitmentQty
  if not mapTalent or not (nMaxNormalCount - mapTalent.nAllNormalCount) * nNodeFragments - nHas then
    local nRemain = (nMaxNormalCount) * nNodeFragments + nCompositeFragments - nHas
  end
  do return nRemain, mapTalent == nil end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerTalentData.CheckTalentActive = function(self, nCharId, nTalentId)
  -- function num : 0_26
  if (self._tbCharTalentNode)[nCharId] and (((self._tbCharTalentNode)[nCharId]).tbActiveTalent)[nTalentId] then
    return true
  end
  return false
end

PlayerTalentData.GetTalentEffect = function(self, nCharId)
  -- function num : 0_27 , upvalues : _ENV
  local mapTalent = (self._tbCharTalentNode)[nCharId]
  local tbEffect = {}
  if mapTalent then
    for nTalentId,bActive in pairs(mapTalent.tbActiveTalent) do
      if bActive then
        local mapCfg = (ConfigTable.GetData)("Talent", nTalentId)
        for _,nEffectId in pairs(mapCfg.EffectId) do
          (table.insert)(tbEffect, nEffectId)
        end
      end
    end
  end
  do
    return tbEffect
  end
end

PlayerTalentData.GetTalentAttributeDesc = function(self, nTalentId)
  -- function num : 0_28 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("Talent", nTalentId)
  local tbDesc = {}
  for _,nEffectId in pairs(mapCfg.EffectId) do
    local configEffect = (ConfigTable.GetData_Effect)(nEffectId)
    local config = (ConfigTable.GetData)("EffectValue", nEffectId)
    local bAttrFix = config.EffectType == (GameEnum.effectType).ATTR_FIX or config.EffectType == (GameEnum.effectType).PLAYER_ATTR_FIX
    if bAttrFix and configEffect.Trigger == (GameEnum.trigger).NOTHING then
      local nEffectDescId = (GameEnum.effectType).ATTR_FIX * 10000 + config.EffectTypeFirstSubtype * 10 + config.EffectTypeSecondSubtype
      local configDesc = (ConfigTable.GetData)("EffectDesc", nEffectDescId)
      local nValue = tonumber(config.EffectTypeParam1) or 0
      ;
      (table.insert)(tbDesc, {nEftDescId = nEffectDescId, nValueNum = nValue})
    end
  end
  do return tbDesc end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

PlayerTalentData.UpdateAllCharTalentRedDot = function(self)
  -- function num : 0_29 , upvalues : _ENV
  for charId,v in pairs(self._tbCharTalentNode) do
    self:UpdateCharTalentRedDot(charId)
  end
end

PlayerTalentData.UpdateCharTalentRedDotByItem = function(self, mapChange)
  -- function num : 0_30 , upvalues : _ENV
  for _,v in ipairs(mapChange) do
    local charId = (self.FragmentsToChar)[v.Tid]
    if charId and v.Qty > 0 then
      self:UpdateCharTalentRedDot(charId)
    end
  end
end

PlayerTalentData.UpdateCharTalentRedDot = function(self, nCharId)
  -- function num : 0_31 , upvalues : _ENV
  local mapTalent = (self._tbCharTalentNode)[nCharId]
  if not mapTalent then
    return 
  end
  local bValid = false
  if mapTalent.nAllNormalCount < mapTalent.nMaxNormalCount then
    local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
    local mapGradeCfg = (ConfigTable.GetData)("CharGrade", mapCharCfg.Grade)
    local nFragmentCount = (PlayerData.Item):GetItemCountByID(mapCharCfg.FragmentsId)
    if mapGradeCfg.FragmentsQty <= nFragmentCount then
      bValid = true
    end
  end
  do
    ;
    (RedDotManager.SetValid)(RedDotDefine.Role_Talent, nCharId, bValid)
  end
end

PlayerTalentData.SendTalentUnlockReq = function(self, nCharId, nTalentId, callback)
  -- function num : 0_32 , upvalues : _ENV
  local msgData = {Value = nTalentId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_32_0 , upvalues : self, nCharId, _ENV, nTalentId, callback
    local bKey = false
    if mapMainData.TalentId and mapMainData.TalentId > 0 then
      self:UnlockTalent(nCharId, mapMainData.TalentId)
      bKey = true
      local mapCfg = (ConfigTable.GetData)("Talent", nTalentId)
      if mapCfg then
        local mapGroup = (ConfigTable.GetData)("TalentGroup", mapCfg.GroupId)
        -- DECOMPILER ERROR at PC30: Confused about usage of register: R5 in 'UnsetPending'

        if mapGroup then
          (self._tbTalentBgIndex)[nCharId] = mapGroup.Background
        end
      end
    end
    do
      self:UnlockTalent(nCharId, nTalentId)
      self:UpdateCharTalentRedDot(nCharId)
      callback(bKey)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).talent_unlock_req, msgData, nil, successCallback)
end

PlayerTalentData.SendTalentResetReq = function(self, nCharId, nGroupId, callback)
  -- function num : 0_33 , upvalues : _ENV
  if self.bTalentResetCD then
    (EventManager.Hit)(EventId.OpenMessageBox, orderedFormat((ConfigTable.GetUIText)("CharTalent_CD"), self.nCd))
    return 
  end
  local msgData = {CharId = nCharId, GroupId = nGroupId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_33_0 , upvalues : self, _ENV, nGroupId, nCharId, callback
    self:SetTimer((ConfigTable.GetConfigNumber)("TalentResetTimeInterval") * 60)
    if nGroupId == 0 then
      self:ResetAllTalent(nCharId)
    else
      self:ResetTalent(nCharId, nGroupId)
    end
    self:UpdateCharTalentRedDot(nCharId)
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapMainData, nil, (ConfigTable.GetUIText)("CharTalent_ResetReceiveTip"))
    callback()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).talent_reset_req, msgData, nil, successCallback)
end

PlayerTalentData.SendTalentNodeResetReq = function(self, nCharId, nId, callback)
  -- function num : 0_34 , upvalues : _ENV
  local msgData = {Value = nId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_34_0 , upvalues : self, nCharId, nId, _ENV, callback
    self:ResetTalentNode(nCharId, nId, mapMainData.ResetKeyNode)
    self:UpdateCharTalentRedDot(nCharId)
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapMainData.Change, callback, (ConfigTable.GetUIText)("CharTalent_ResetReceiveTip"))
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).talent_node_reset_req, msgData, nil, successCallback)
end

PlayerTalentData.SendTalentBackgroundSetReq = function(self, nCharId, nGroupId, callback)
  -- function num : 0_35 , upvalues : _ENV
  local msgData = {GroupId = nGroupId, CharId = nCharId}
  if nGroupId ~= 0 then
    msgData.CharId = 0
  end
  local successCallback = function(_, mapMainData)
    -- function num : 0_35_0 , upvalues : nGroupId, self, nCharId, _ENV, callback
    -- DECOMPILER ERROR at PC5: Confused about usage of register: R2 in 'UnsetPending'

    if nGroupId == 0 then
      (self._tbTalentBgIndex)[nCharId] = 0
    else
      local mapGroup = (ConfigTable.GetData)("TalentGroup", nGroupId)
      -- DECOMPILER ERROR at PC17: Confused about usage of register: R3 in 'UnsetPending'

      if mapGroup then
        (self._tbTalentBgIndex)[nCharId] = mapGroup.Background
      end
    end
    do
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).talent_background_set_req, msgData, nil, successCallback)
end

PlayerTalentData.SendTalentGroupUnlockSetReq = function(self, nCharId, nGroupId, callback)
  -- function num : 0_36 , upvalues : _ENV
  local msgData = {Value = nGroupId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_36_0 , upvalues : _ENV, nGroupId, self, nCharId, callback
    local mapGroup = (ConfigTable.GetData)("TalentGroup", nGroupId)
    -- DECOMPILER ERROR at PC10: Confused about usage of register: R3 in 'UnsetPending'

    if mapGroup then
      (self._tbTalentBgIndex)[nCharId] = mapGroup.Background
    end
    for _,v in pairs(mapMainData.Nodes) do
      self:UnlockTalent(nCharId, v)
    end
    self:UpdateCharTalentRedDot(nCharId)
    callback()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).talent_group_unlock_req, msgData, nil, successCallback)
end

PlayerTalentData.CreateTrialData = function(self, tbTrialId)
  -- function num : 0_37 , upvalues : _ENV
  self._tbTrialTalentNode = {}
  self._tbTrialEnhancedSkill = {}
  self._tbTrialEnhancedPotential = {}
  self._tbTrialFateTalent = {}
  for _,nTrialId in ipairs(tbTrialId) do
    local mapCfg = (ConfigTable.GetData)("TrialCharacter", nTrialId)
    if mapCfg == nil then
      printError("体验角色数据没有找到：" .. nTrialId)
      return 
    end
    local nCharId = mapCfg.CharId
    local tbActive = mapCfg.Talent
    -- DECOMPILER ERROR at PC29: Confused about usage of register: R10 in 'UnsetPending'

    ;
    (self._tbTrialTalentNode)[nTrialId] = {}
    for _,v in ipairs(tbActive) do
      -- DECOMPILER ERROR at PC36: Confused about usage of register: R15 in 'UnsetPending'

      ((self._tbTrialTalentNode)[nTrialId])[v] = true
    end
    -- DECOMPILER ERROR at PC44: Confused about usage of register: R10 in 'UnsetPending'

    ;
    (self._tbTrialEnhancedSkill)[nTrialId] = self:CreateEnhancedSkill(nCharId, tbActive)
    -- DECOMPILER ERROR at PC49: Confused about usage of register: R10 in 'UnsetPending'

    ;
    (self._tbTrialEnhancedPotential)[nTrialId] = self:CreateEnhancedPotential(tbActive)
    local tbTalent = (CacheTable.GetData)("_TalentByIndex", nCharId)
    if tbTalent == nil then
      printError("Talent表找不到该角色" .. nCharId)
      tbTalent = {}
    end
    -- DECOMPILER ERROR at PC68: Confused about usage of register: R11 in 'UnsetPending'

    ;
    (self._tbTrialFateTalent)[nTrialId] = self:CreateFateTalent(tbTalent)
  end
end

PlayerTalentData.DeleteTrialData = function(self)
  -- function num : 0_38
  self._tbTrialTalentNode = {}
  self._tbTrialEnhancedSkill = {}
  self._tbTrialEnhancedPotential = {}
  self._tbTrialFateTalent = {}
end

PlayerTalentData.GetTrialEnhancedSkill = function(self, nTrialId)
  -- function num : 0_39
  return (self._tbTrialEnhancedSkill)[nTrialId]
end

PlayerTalentData.GetTrialEnhancedPotential = function(self, nTrialId)
  -- function num : 0_40
  return (self._tbTrialEnhancedPotential)[nTrialId]
end

PlayerTalentData.GetTrialFateTalent = function(self, nTrialId)
  -- function num : 0_41 , upvalues : _ENV
  local tbFate = {}
  if not (self._tbTrialFateTalent)[nTrialId] then
    return tbFate
  end
  for i,v in ipairs((self._tbTrialFateTalent)[nTrialId]) do
    if (self._tbTrialTalentNode)[nTrialId] and ((self._tbTrialTalentNode)[nTrialId])[v] then
      tbFate[i] = true
    else
      tbFate[i] = false
    end
  end
  return tbFate
end

PlayerTalentData.GetTrialTalentEffect = function(self, nTrialId)
  -- function num : 0_42 , upvalues : _ENV
  local mapTalent = (self._tbTrialTalentNode)[nTrialId]
  local tbEffect = {}
  if mapTalent then
    for nTalentId,bActive in pairs(mapTalent) do
      if bActive then
        local mapCfg = (ConfigTable.GetData)("Talent", nTalentId)
        for _,nEffectId in pairs(mapCfg.EffectId) do
          (table.insert)(tbEffect, nEffectId)
        end
      end
    end
  end
  do
    return tbEffect
  end
end

return PlayerTalentData

