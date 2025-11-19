local RapidJson = require("rapidjson")
local LocalData = require("GameCore.Data.LocalData")
local CharacterAttrData = require("GameCore.Data.DataClass.CharacterAttrData")
local PlayerCharData = class("PlayerCharData")
local ConfigData = require("GameCore.Data.ConfigData")
local AttrConfig = require("GameCore.Common.AttrConfig")
local TimerManager = require("GameCore.Timer.TimerManager")
PlayerCharData.Init = function(self)
  -- function num : 0_0 , upvalues : LocalData, _ENV
  self._mapChar = nil
  self._mapTrialChar = {}
  if (LocalData.GetLocalData)("Char_", "CharPanel_IsSimpleDesc") == nil then
    local defaultValue = (ConfigTable.GetConfigValue)("SkillShowDetail")
    self.bCharPanel_IsSimpleDesc = defaultValue ~= "1"
  else
    self.bCharPanel_IsSimpleDesc = (LocalData.GetLocalData)("Char_", "CharPanel_IsSimpleDesc")
  end
  if (LocalData.GetLocalData)("Char_", "TipsPanel_IsSimpleDesc") == nil then
    local defaultValue = (ConfigTable.GetConfigValue)("SkillShowDetail")
    self.bTipsPanel_IsSimpleDesc = defaultValue ~= "1"
  else
    self.bTipsPanel_IsSimpleDesc = (LocalData.GetLocalData)("Char_", "TipsPanel_IsSimpleDesc")
  end
  self:ProcessTableData()
  self:ProcessCharExpItem()
  -- DECOMPILER ERROR: 6 unprocessed JMP targets
end

PlayerCharData.ProcessTableData = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self._CharSkillUpgrade = {}
  local func_ForEach_Node = function(mapLineData)
    -- function num : 0_1_0 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self._CharSkillUpgrade)[mapLineData.Group] == nil then
      (self._CharSkillUpgrade)[mapLineData.Group] = {}
    end
    ;
    (table.insert)((self._CharSkillUpgrade)[mapLineData.Group], {nId = mapLineData.Id, nReqCharAdvNum = mapLineData.AdvanceNum, nReqGold = mapLineData.GoldQty, 
tbReqItem = {
{mapLineData.Tid1, mapLineData.Qty1}
, 
{mapLineData.Tid2, mapLineData.Qty2}
, 
{mapLineData.Tid3, mapLineData.Qty3}
, 
{mapLineData.Tid4, mapLineData.Qty4}
}
})
  end

  ForEachTableLine(DataTable.CharacterSkillUpgrade, func_ForEach_Node)
  for nGroupId,tbUpgradeReq in pairs(self._CharSkillUpgrade) do
    (table.sort)((self._CharSkillUpgrade)[nGroupId], function(a, b)
    -- function num : 0_1_1
    do return a.nId < b.nId end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  end
  local func_ForEach_CharSkill = function(mapLineData)
    -- function num : 0_1_2 , upvalues : _ENV
    (CacheTable.SetField)("_TalentSkillAI", mapLineData.ActorId, mapLineData.TalentId, {NormalAtkId = mapLineData.NormalAtkId, DodgeId = mapLineData.DodgeId, SpecialSkillId = mapLineData.SpecialSkillId, UltimateId = mapLineData.UltimateId, aiId = mapLineData.AiId, SkillId = mapLineData.SkillId})
  end

  ForEachTableLine(DataTable.TalentSkillAI, func_ForEach_CharSkill)
  local func_ForEach_EffectDesc = function(mapData)
    -- function num : 0_1_3 , upvalues : _ENV
    (CacheTable.SetData)("_AttributeDesc", mapData.Attribute, mapData)
    if mapData.Attribute ~= nil and mapData.Attribute ~= "" then
      (CacheTable.SetData)("_AttributeDescByType", mapData.TypeID, mapData)
    end
  end

  ForEachTableLine(DataTable.EffectDesc, func_ForEach_EffectDesc)
  local foreachCG = function(mapData)
    -- function num : 0_1_4 , upvalues : _ENV
    if mapData.UnlockPlot ~= 0 then
      (CacheTable.SetData)("_CharacterCG", mapData.UnlockPlot, mapData.Id)
    end
  end

  ForEachTableLine(DataTable.CharacterCG, foreachCG)
  local forEachAffinityLevel = function(mapData)
    -- function num : 0_1_5 , upvalues : _ENV
    (CacheTable.SetField)("_AffinityLevel", mapData.TemplateId, mapData.AffinityLevel, mapData)
  end

  ForEachTableLine(DataTable.AffinityLevel, forEachAffinityLevel)
  local forEachRaritySequence = function(mapData)
    -- function num : 0_1_6 , upvalues : _ENV
    (CacheTable.SetField)("_CharRaritySequence", mapData.Grade, mapData.AdvanceLvl, mapData)
  end

  ForEachTableLine(DataTable.CharRaritySequence, forEachRaritySequence)
  self._tbArchiveUpdate = {}
  local foreachCharArchive = function(mapData)
    -- function num : 0_1_7 , upvalues : self, _ENV
    local nContentId = mapData.RecordId
    local nCharId = mapData.CharacterId
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R3 in 'UnsetPending'

    if (self._tbArchiveUpdate)[nCharId] == nil then
      (self._tbArchiveUpdate)[nCharId] = {}
    end
    local contentCfg = (ConfigTable.GetData)("CharacterArchiveContent", nContentId)
    -- DECOMPILER ERROR at PC19: Confused about usage of register: R4 in 'UnsetPending'

    if contentCfg ~= nil then
      ((self._tbArchiveUpdate)[nCharId])[nContentId] = {}
      -- DECOMPILER ERROR at PC24: Confused about usage of register: R4 in 'UnsetPending'

      ;
      (((self._tbArchiveUpdate)[nCharId])[nContentId]).UpdateAff1 = contentCfg.UpdateAff1
      -- DECOMPILER ERROR at PC29: Confused about usage of register: R4 in 'UnsetPending'

      ;
      (((self._tbArchiveUpdate)[nCharId])[nContentId]).UpdatePlot1 = contentCfg.UpdatePlot1
      -- DECOMPILER ERROR at PC34: Confused about usage of register: R4 in 'UnsetPending'

      ;
      (((self._tbArchiveUpdate)[nCharId])[nContentId]).UpdateStory1 = contentCfg.UpdateStory1
      if contentCfg.UpdateContent1 ~= "" then
        local nValue = 0
        if contentCfg.UpdateAff1 == 0 then
          nValue = 1
        end
        if contentCfg.UpdatePlot1 == 0 then
          nValue = 2 | nValue
        end
        if contentCfg.UpdateStory1 == 0 then
          nValue = 4 | (nValue)
        end
        -- DECOMPILER ERROR at PC54: Confused about usage of register: R5 in 'UnsetPending'

        ;
        (((self._tbArchiveUpdate)[nCharId])[nContentId]).nValue = nValue
      else
        do
          -- DECOMPILER ERROR at PC59: Confused about usage of register: R4 in 'UnsetPending'

          ;
          (((self._tbArchiveUpdate)[nCharId])[nContentId]).nValue = -1
        end
      end
    end
  end

  ForEachTableLine((ConfigTable.Get)("CharacterArchive"), foreachCharArchive)
  self._tbArchiveBaseUpdate = {}
  local foreachCharArchiveBaseInfo = function(mapData)
    -- function num : 0_1_8 , upvalues : self
    local nCharId = mapData.CharacterId
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

    if (self._tbArchiveBaseUpdate)[nCharId] == nil then
      (self._tbArchiveBaseUpdate)[nCharId] = {}
    end
    -- DECOMPILER ERROR at PC12: Confused about usage of register: R2 in 'UnsetPending'

    ;
    ((self._tbArchiveBaseUpdate)[nCharId])[mapData.Id] = {}
    -- DECOMPILER ERROR at PC18: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (((self._tbArchiveBaseUpdate)[nCharId])[mapData.Id]).UpdateAff1 = mapData.UpdateAff1
    -- DECOMPILER ERROR at PC24: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (((self._tbArchiveBaseUpdate)[nCharId])[mapData.Id]).UpdatePlot1 = mapData.UpdatePlot1
    -- DECOMPILER ERROR at PC30: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (((self._tbArchiveBaseUpdate)[nCharId])[mapData.Id]).UpdateStory1 = mapData.UpdateStory1
    if mapData.UpdateContent1 ~= "" then
      local nValue = 0
      if mapData.UpdateAff1 == 0 then
        nValue = 1
      end
      if mapData.UpdatePlot1 == 0 then
        nValue = 2 | nValue
      end
      if mapData.UpdateStory1 == 0 then
        nValue = 4 | (nValue)
      end
      -- DECOMPILER ERROR at PC51: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (((self._tbArchiveBaseUpdate)[nCharId])[mapData.Id]).nValue = nValue
    else
      do
        -- DECOMPILER ERROR at PC57: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (((self._tbArchiveBaseUpdate)[nCharId])[mapData.Id]).nValue = -1
      end
    end
  end

  ForEachTableLine((ConfigTable.Get)("CharacterArchiveBaseInfo"), foreachCharArchiveBaseInfo)
  local foreachPlot = function(mapData)
    -- function num : 0_1_9 , upvalues : _ENV
    if (CacheTable.GetData)("_Plot", mapData.Char) == nil then
      (CacheTable.SetData)("_Plot", mapData.Char, {})
    end
    ;
    (CacheTable.InsertData)("_Plot", mapData.Char, mapData)
  end

  ForEachTableLine((ConfigTable.Get)("Plot"), foreachPlot)
  self._tbCharPotential = {}
  local foreachPotential = function(mapData)
    -- function num : 0_1_10 , upvalues : self, _ENV
    local nCharId = mapData.Id
    -- DECOMPILER ERROR at PC3: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self._tbCharPotential)[nCharId] = {}
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

    ;
    ((self._tbCharPotential)[nCharId]).master = {}
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R2 in 'UnsetPending'

    ;
    ((self._tbCharPotential)[nCharId]).assist = {}
    local addPotential = function(tbPotentialId, insertTb)
      -- function num : 0_1_10_0 , upvalues : _ENV
      for _,v in ipairs(tbPotentialId) do
        local mapCfg = (ConfigTable.GetData)("Potential", v)
        local mapItemCfg = (ConfigTable.GetData)("Item", v)
        if mapCfg ~= nil and mapItemCfg ~= nil then
          if insertTb[mapCfg.Build] == nil then
            insertTb[mapCfg.Build] = {}
          end
          local data = {nId = v, nSpecial = mapItemCfg.Stype == (GameEnum.itemStype).SpecificPotential and 1 or 0, nRarity = mapItemCfg.Rarity}
          ;
          (table.insert)(insertTb[mapCfg.Build], data)
        end
      end
    end

    addPotential(mapData.MasterSpecificPotentialIds, ((self._tbCharPotential)[nCharId]).master)
    addPotential(mapData.AssistSpecificPotentialIds, ((self._tbCharPotential)[nCharId]).assist)
    addPotential(mapData.CommonPotentialIds, ((self._tbCharPotential)[nCharId]).master)
    addPotential(mapData.CommonPotentialIds, ((self._tbCharPotential)[nCharId]).assist)
    addPotential(mapData.MasterNormalPotentialIds, ((self._tbCharPotential)[nCharId]).master)
    addPotential(mapData.AssistNormalPotentialIds, ((self._tbCharPotential)[nCharId]).assist)
    for _,data in pairs((self._tbCharPotential)[nCharId]) do
      for nType,list in pairs(data) do
        (table.sort)(list, function(a, b)
      -- function num : 0_1_10_1
      if a.nRarity == b.nRarity then
        if a.nId >= b.nId then
          do return a.nSpecial ~= b.nSpecial end
          do return a.nRarity < b.nRarity end
          do return b.nSpecial < a.nSpecial end
          -- DECOMPILER ERROR: 5 unprocessed JMP targets
        end
      end
    end
)
      end
    end
  end

  ForEachTableLine((ConfigTable.Get)("CharPotential"), foreachPotential)
  self.tbHonorTitle = {}
  local foreachHonorCharacter = function(mapData)
    -- function num : 0_1_11 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self.tbHonorTitle)[mapData.CharId] == nil then
      (self.tbHonorTitle)[mapData.CharId] = {}
    end
    ;
    (table.insert)((self.tbHonorTitle)[mapData.CharId], mapData)
  end

  ForEachTableLine((ConfigTable.Get)("HonorCharacter"), foreachHonorCharacter)
end

PlayerCharData.ProcessCharExpItem = function(self)
  -- function num : 0_2 , upvalues : _ENV
  self.tbItemExp = {}
  local foreachCharacterItemExp = function(mapData)
    -- function num : 0_2_0 , upvalues : _ENV, self
    (table.insert)(self.tbItemExp, {nItemId = mapData.ItemId, nExpValue = mapData.ExpValue})
  end

  ForEachTableLine(DataTable.CharItemExp, foreachCharacterItemExp)
  local sort = function(a, b)
    -- function num : 0_2_1
    do return b.nExpValue < a.nExpValue end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end

  ;
  (table.sort)(self.tbItemExp, sort)
  for key,value in pairs(self.tbItemExp) do
  end
  self.goldperExp = (ConfigTable.GetConfigNumber)("CharUpgradeGoldPerExp") / 1000
end

PlayerCharData.CreateNewChar = function(self, msgData)
  -- function num : 0_3 , upvalues : _ENV
  local charData = {}
  local nCharId = msgData.Tid
  local tbTempUseSkill = (self.tbTempSaveCharSkill)[tostring(nCharId)]
  -- DECOMPILER ERROR at PC16: Confused about usage of register: R5 in 'UnsetPending'

  if tbTempUseSkill == nil then
    (self.tbTempSaveCharSkill)[tostring(nCharId)] = {bBranch1 = false, bBranch2 = false}
    tbTempUseSkill = (self.tbTempSaveCharSkill)[tostring(nCharId)]
  end
  if msgData.AffinityQuests ~= nil and (msgData.AffinityQuests).List ~= nil and #(msgData.AffinityQuests).List > 0 then
    (PlayerData.Quest):CacheAllQuest((msgData.AffinityQuests).List)
  end
  if not msgData.ArchiveRewardIds then
    charData = {nId = nCharId, nRankExp = msgData.Exp, tbDatingEventIds = msgData.DatingEventIds, tbDatingEventRewardIds = msgData.DatingEventRewardIds, nFavor = msgData.Favor, nSkinId = msgData.Skin, nLevel = msgData.Level, nCreateTime = msgData.CreateTime, nAdvance = msgData.Advance, tbSkillLvs = msgData.SkillLvs, bUseSkillWhenActive_Branch1 = tbTempUseSkill.bBranch1, bUseSkillWhenActive_Branch2 = tbTempUseSkill.bBranch2, tbPlot = msgData.Plots, nAffinityExp = msgData.AffinityExp, nAffinityLevel = msgData.AffinityLevel, tbAffinityQuests = msgData.AffinityQuests, 
tbArchiveRewardIds = {}
}
    if msgData.DatingEventIds ~= nil and msgData.DatingEventRewardIds ~= nil then
      (PlayerData.Dating):RefreshLimitedEventList(nCharId, msgData.DatingEventIds, msgData.DatingEventRewardIds)
    end
    self:InitCharArchiveContentUpdateRedDot(nCharId)
    return charData
  end
end

PlayerCharData.CacheCharacters = function(self, mapData)
  -- function num : 0_4 , upvalues : _ENV, LocalData
  if self._mapChar == nil then
    self._mapChar = {}
  end
  local tb = decodeJson((LocalData.GetPlayerLocalData)("TempSaveCharSkill"))
  if tb ~= nil then
    self.tbTempSaveCharSkill = tb
  else
    self.tbTempSaveCharSkill = {}
  end
  if mapData == nil then
    return 
  end
  for _,mapCharInfo in ipairs(mapData) do
    local nCharId = mapCharInfo.Tid
    -- DECOMPILER ERROR at PC28: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self._mapChar)[nCharId] = self:CreateNewChar(mapCharInfo)
  end
  ;
  (PlayerData.Talent):CacheTalentData(mapData)
  ;
  (PlayerData.Equipment):CacheEquipmentData(mapData)
end

PlayerCharData.GetCharUsedSkinId = function(self, nCharId)
  -- function num : 0_5
  if (self._mapChar)[nCharId] == nil then
    return 0
  end
  return ((self._mapChar)[nCharId]).nSkinId
end

PlayerCharData.GetCreateTime = function(self, nCharId)
  -- function num : 0_6
  return ((self._mapChar)[nCharId]).nCreateTime
end

PlayerCharData.GetSkillIds = function(self, nCharId)
  -- function num : 0_7 , upvalues : _ENV
  local tbSkillList = {}
  local charCfgData = (ConfigTable.GetData_Character)(nCharId)
  if charCfgData == nil then
    return tbSkillList
  end
  tbSkillList[1] = charCfgData.NormalAtkId
  tbSkillList[2] = charCfgData.SkillId
  tbSkillList[3] = charCfgData.AssistSkillId
  tbSkillList[4] = charCfgData.UltimateId
  return tbSkillList
end

PlayerCharData.GetSkillLevel = function(self, nCharId)
  -- function num : 0_8 , upvalues : _ENV
  local mapTrialInfo = nil
  for _,v in pairs(self._mapTrialChar) do
    if v.nId == nCharId then
      mapTrialInfo = v
      break
    end
  end
  do
    local mapChar = nil
    if mapTrialInfo then
      mapChar = mapTrialInfo
    else
      mapChar = (self._mapChar)[nCharId]
    end
    local tbList = {}
    tbList[(GameEnum.skillSlotType).NORMAL] = mapChar and (mapChar.tbSkillLvs)[1] or 1
    tbList[(GameEnum.skillSlotType).B] = mapChar and (mapChar.tbSkillLvs)[2] or 1
    tbList[(GameEnum.skillSlotType).C] = mapChar and (mapChar.tbSkillLvs)[3] or 1
    tbList[(GameEnum.skillSlotType).D] = mapChar and (mapChar.tbSkillLvs)[4] or 1
    return tbList
  end
end

PlayerCharData.GetTalentSkillId = function(self, nCharId)
  -- function num : 0_9 , upvalues : _ENV
  local charCfgData = (ConfigTable.GetData_Character)(nCharId)
  if charCfgData ~= nil then
    return charCfgData.TalentSkillId
  end
end

PlayerCharData.GetUseSkillWhenActive = function(self, nCharId, nBranchIndex)
  -- function num : 0_10
  local mapData = (self._mapChar)[nCharId]
  if nBranchIndex == nil then
    nBranchIndex = self:CalcCharBranchIndex(nCharId)
  end
  if nBranchIndex == 1 then
    return mapData.bUseSkillWhenActive_Branch1
  else
    if nBranchIndex == 2 then
      return mapData.bUseSkillWhenActive_Branch2
    end
  end
end

PlayerCharData.SetUseSkillWhenActive = function(self, nCharId, nBranchIndex, bUse)
  -- function num : 0_11 , upvalues : _ENV, LocalData, RapidJson
  local mapData = (self._mapChar)[nCharId]
  if nBranchIndex == 1 then
    mapData.bUseSkillWhenActive_Branch1 = bUse
    -- DECOMPILER ERROR at PC10: Confused about usage of register: R5 in 'UnsetPending'

    ;
    ((self.tbTempSaveCharSkill)[tostring(nCharId)]).bBranch1 = bUse
  else
    if nBranchIndex == 2 then
      mapData.bUseSkillWhenActive_Branch2 = bUse
      -- DECOMPILER ERROR at PC20: Confused about usage of register: R5 in 'UnsetPending'

      ;
      ((self.tbTempSaveCharSkill)[tostring(nCharId)]).bBranch2 = bUse
    end
  end
  ;
  (LocalData.SetPlayerLocalData)("TempSaveCharSkill", (RapidJson.encode)(self.tbTempSaveCharSkill))
end

PlayerCharData.GetCharSkillUpgradeData = function(self, nCharId)
  -- function num : 0_12 , upvalues : _ENV
  local tbSkillList = {}
  local tbSkillIds = self:GetSkillIds(nCharId)
  local mapCfgData_Character = (ConfigTable.GetData_Character)(nCharId)
  if mapCfgData_Character == nil then
    return tbSkillList
  end
  local mapTalentEnhanceSkill = (PlayerData.Talent):GetEnhancedSkill(nCharId)
  local mapEquipmentEnhanceSkill = (PlayerData.Equipment):GetEnhancedSkill(nCharId)
  for i = 1, 4 do
    local nAdd = 0
    if mapTalentEnhanceSkill and mapTalentEnhanceSkill[tbSkillIds[i]] then
      nAdd = nAdd + mapTalentEnhanceSkill[tbSkillIds[i]]
    end
    if mapEquipmentEnhanceSkill and mapEquipmentEnhanceSkill[tbSkillIds[i]] then
      nAdd = nAdd + mapEquipmentEnhanceSkill[tbSkillIds[i]]
    end
    local skill = {}
    skill.nId = tbSkillIds[i]
    local nLv = 1
    if (self._mapChar)[nCharId] ~= nil and (((self._mapChar)[nCharId]).tbSkillLvs)[i] ~= nil then
      nLv = (((self._mapChar)[nCharId]).tbSkillLvs)[i]
    end
    skill.nLv = nLv
    skill.nAddLv = nAdd
    local nUpgradeGroup = (mapCfgData_Character.SkillsUpgradeGroup)[i]
    skill.nMaxLv = (table.nums)((self._CharSkillUpgrade)[nUpgradeGroup])
    if skill.nMaxLv >= nLv + 1 or not -1 then
      do
        skill.mapReq = ((self._CharSkillUpgrade)[nUpgradeGroup])[nLv + 1]
        tbSkillList[i] = skill
        -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out IF_STMT

      end
    end
  end
  return tbSkillList
end

PlayerCharData.GetCharPotentialList = function(self, nCharId)
  -- function num : 0_13
  return (self._tbCharPotential)[nCharId]
end

PlayerCharData.GetCharEnhancedPotential = function(self, nCharId)
  -- function num : 0_14 , upvalues : _ENV
  local mapAddLevel = {}
  local add = function(mapAdd)
    -- function num : 0_14_0 , upvalues : _ENV, mapAddLevel
    if not mapAdd then
      return 
    end
    for nPotentialId,nAdd in pairs(mapAdd) do
      if not mapAddLevel[nPotentialId] then
        mapAddLevel[nPotentialId] = 0
      end
      mapAddLevel[nPotentialId] = mapAddLevel[nPotentialId] + nAdd
    end
  end

  local mapTalentAddLevel = (PlayerData.Talent):GetEnhancedPotential(nCharId)
  local mapEquipmentAddLevel = (PlayerData.Equipment):GetEnhancedPotential(nCharId)
  add(mapTalentAddLevel)
  add(mapEquipmentAddLevel)
  return mapAddLevel
end

PlayerCharData.GetCharSkillMaxLevel = function(self, nCharId, nSlot)
  -- function num : 0_15 , upvalues : _ENV
  local maxLevel = 0
  local mapCfgData_Character = (ConfigTable.GetData_Character)(nCharId)
  if mapCfgData_Character == nil then
    return maxLevel
  end
  local nUpgradeGroup = (mapCfgData_Character.SkillsUpgradeGroup)[nSlot]
  if nUpgradeGroup ~= nil then
    maxLevel = (table.nums)((self._CharSkillUpgrade)[nUpgradeGroup])
  end
  return maxLevel
end

PlayerCharData.GetCharSkillAddedLevel = function(self, nCharId)
  -- function num : 0_16 , upvalues : _ENV
  local mapChar = (self._mapChar)[nCharId]
  if mapChar == nil then
    printError("没有该角色数据" .. nCharId)
    mapChar = {nLevel = 1, nAdvance = 0, 
tbSkillLvs = {1, 1, 1, 1}
}
  end
  local tbSkillLevel = {}
  local tbSkillIds = self:GetSkillIds(nCharId)
  local mapTalentEnhanceSkill = (PlayerData.Talent):GetEnhancedSkill(nCharId)
  local mapEquipmentEnhanceSkill = (PlayerData.Equipment):GetEnhancedSkill(nCharId)
  for i = 1, 4 do
    local nSkillId = tbSkillIds[i]
    local nAdd = 0
    if mapTalentEnhanceSkill and mapTalentEnhanceSkill[nSkillId] then
      nAdd = nAdd + mapTalentEnhanceSkill[nSkillId]
    end
    if mapEquipmentEnhanceSkill and mapEquipmentEnhanceSkill[nSkillId] then
      nAdd = nAdd + mapEquipmentEnhanceSkill[nSkillId]
    end
    local nLv = (mapChar.tbSkillLvs)[i] + (nAdd)
    ;
    (table.insert)(tbSkillLevel, nLv)
  end
  return tbSkillLevel
end

PlayerCharData.GetTrialCharSkillAddedLevel = function(self, nTrialId)
  -- function num : 0_17 , upvalues : _ENV
  local mapChar = (self._mapTrialChar)[nTrialId]
  if mapChar == nil then
    printError("没有该角色数据" .. nTrialId)
    return {1, 1, 1, 1}
  end
  local nCharId = mapChar.nId
  local tbSkillLevel = {}
  local tbSkillIds = self:GetSkillIds(nCharId)
  local mapTalentEnhanceSkill = (PlayerData.Talent):GetTrialEnhancedSkill(nTrialId)
  for i = 1, 4 do
    local nSkillId = tbSkillIds[i]
    local nAdd = 0
    if mapTalentEnhanceSkill then
      nAdd = mapTalentEnhanceSkill[nSkillId]
    end
    local nLv = (mapChar.tbSkillLvs)[i] + nAdd
    ;
    (table.insert)(tbSkillLevel, nLv)
  end
  return tbSkillLevel
end

PlayerCharData.EnterCharPlotAvg = function(self, nCharId, nPlotId, callback, bShowReward)
  -- function num : 0_18 , upvalues : _ENV, TimerManager
  local bGetReward = self:IsCharPlotFinish(nCharId, nPlotId)
  local mapPlot = (ConfigTable.GetData)("Plot", nPlotId)
  if mapPlot == nil then
    return 
  end
  local Callback = function()
    -- function num : 0_18_0 , upvalues : bGetReward, bShowReward, TimerManager, self, mapPlot, _ENV, callback, nCharId, nPlotId
    if not bGetReward then
      local finishCallBack = function(mapMsgData, nCharId)
      -- function num : 0_18_0_0 , upvalues : bShowReward, TimerManager, self, mapPlot, _ENV, callback
      if bShowReward then
        (TimerManager.Add)(1, 1.3, self, function()
        -- function num : 0_18_0_0_0 , upvalues : mapMsgData, mapPlot, _ENV, nCharId
        local rewardFunc = function()
          -- function num : 0_18_0_0_0_0 , upvalues : mapMsgData, mapPlot, _ENV
          local bHasReward = not mapMsgData or not mapMsgData.Props or #mapMsgData.Props > 0
          local tbItem = {}
          if bHasReward then
            local sRewardDisplay = mapPlot.Rewards
            local tbRewardDisplay = decodeJson(sRewardDisplay)
            for k,v in pairs(tbRewardDisplay) do
              (table.insert)(tbItem, {Tid = tonumber(k), Qty = v, rewardType = (AllEnum.RewardType).First})
            end
            ;
            (UTILS.OpenReceiveByDisplayItem)(tbItem, mapMsgData)
          end
          -- DECOMPILER ERROR: 4 unprocessed JMP targets
        end

        if (CacheTable.GetData)("_CharacterCG", mapPlot.Id) ~= nil then
          local tbRewardList = {}
          ;
          (table.insert)(tbRewardList, {nId = (CacheTable.GetData)("_CharacterCG", mapPlot.Id), nCharId = nCharId, bNew = true, 
tbItemList = {}
, bCG = true, callBack = rewardFunc})
          ;
          (EventManager.Hit)(EventId.OpenPanel, PanelId.ReceiveSpecialReward, tbRewardList)
        else
          do
            rewardFunc()
          end
        end
      end
, true, true)
      end
      if callback ~= nil then
        callback(nCharId)
      end
    end

      self:CharPlotFinish(nCharId, nPlotId, finishCallBack)
    else
      do
        if callback ~= nil then
          callback(nCharId)
        end
      end
    end
  end

  local mapData = {nType = (AllEnum.StoryAvgType).Plot, sAvgId = mapPlot.AvgId, nNodeId = nil, callback = Callback}
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.PureAvgStory, mapData)
end

PlayerCharData.IsCharPlotFinish = function(self, nCharId, nPlotId)
  -- function num : 0_19 , upvalues : _ENV
  local mapChar = (self._mapChar)[nCharId]
  if mapChar == nil then
    return false
  end
  if mapChar.tbPlot == nil then
    return false
  end
  do return (table.indexof)(mapChar.tbPlot, nPlotId) > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerCharData.GetNewChar = function(self, mapData)
  -- function num : 0_20 , upvalues : _ENV
  if mapData == nil then
    return 
  end
  local func_ForEach_InsertNewChar = function(ChangeInfo)
    -- function num : 0_20_0 , upvalues : self, _ENV
    local charID = ChangeInfo.Tid
    if (self._mapChar)[charID] ~= nil then
      printLog("获取重复角色:" .. charID)
      return 
    end
    local nCharId = charID
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self._mapChar)[nCharId] = self:CreateNewChar(ChangeInfo)
  end

  for _,charData in pairs(mapData) do
    func_ForEach_InsertNewChar(charData)
  end
  ;
  (PlayerData.Talent):CacheTalentData(mapData)
  ;
  (PlayerData.Equipment):CacheEquipmentData(mapData)
end

PlayerCharData.GetCharByEET = function(self, tbEET)
  -- function num : 0_21 , upvalues : _ENV
  local tbChar = {}
  local ntbEETLength = #tbEET
  for nCharId,data in pairs(self._mapChar) do
    if (table.indexof)(tbEET, ((ConfigTable.GetData_Character)(nCharId)).EET) > 0 or ntbEETLength == 0 then
      (table.insert)(tbChar, data)
    end
  end
  return tbChar
end

PlayerCharData.GetAdvanceLevelTable = function(self)
  -- function num : 0_22 , upvalues : _ENV
  if self._AdvanceLevelConfig == nil then
    self._AdvanceLevelConfig = {}
    local foreachCharRaritySequence = function(mapData)
    -- function num : 0_22_0 , upvalues : self, _ENV
    local grade = mapData.Grade
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

    if (self._AdvanceLevelConfig)[grade] == nil then
      (self._AdvanceLevelConfig)[grade] = {}
    end
    ;
    (table.insert)((self._AdvanceLevelConfig)[grade], tonumber(mapData.LvLimit))
  end

    ForEachTableLine(DataTable.CharRaritySequence, foreachCharRaritySequence)
  end
  do
    return self._AdvanceLevelConfig
  end
end

PlayerCharData.GetCharAdvancePreview = function(self, nCharId, nAdvance)
  -- function num : 0_23 , upvalues : _ENV
  local mapAdvancePre = {}
  local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
  if mapCharCfg ~= nil then
    local nGrade = mapCharCfg.Grade
    local mapRaritySequence = (CacheTable.GetData)("_CharRaritySequence", nGrade)
    do
      if mapRaritySequence ~= nil and mapRaritySequence[nAdvance] ~= nil then
        local nMaxLevel = (mapRaritySequence[nAdvance]).LvLimit
        ;
        (table.insert)(mapAdvancePre, {nType = (AllEnum.CharAdvancePreview).LevelMax, nMaxLevel = nMaxLevel})
      end
      local nUpgradeGroup = (mapCharCfg.SkillsUpgradeGroup)[1]
      local nMaxSkillLevel = 0
      for i = #(self._CharSkillUpgrade)[nUpgradeGroup], 1, -1 do
        if (((self._CharSkillUpgrade)[nUpgradeGroup])[i]).nReqCharAdvNum == nAdvance then
          nMaxSkillLevel = i
          break
        end
      end
      do
        do
          if nMaxSkillLevel > 0 then
            (table.insert)(mapAdvancePre, {nType = (AllEnum.CharAdvancePreview).SkillLevelMax, nMaxSkillLevel = nMaxSkillLevel})
          end
          if mapCharCfg.AdvanceSkinUnlockLevel == nAdvance then
            (table.insert)(mapAdvancePre, {nType = (AllEnum.CharAdvancePreview).SkinUnlock})
          end
          return mapAdvancePre
        end
      end
    end
  end
end

PlayerCharData.CreateTrialChar = function(self, tbTrialId)
  -- function num : 0_24 , upvalues : _ENV
  for _,nTrialId in ipairs(tbTrialId) do
    if nTrialId > 0 then
      local mapTrialData = (ConfigTable.GetData)("TrialCharacter", nTrialId)
      if mapTrialData == nil then
        printError("体验角色数据没有找到：" .. nTrialId)
        return 
      end
      -- DECOMPILER ERROR at PC34: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (self._mapTrialChar)[nTrialId] = {nId = mapTrialData.CharId, nTrialId = nTrialId, sName = mapTrialData.Name, nSkinId = mapTrialData.CharacterSkin, nLevel = mapTrialData.Level, nAdvance = mapTrialData.Break, tbSkillLvs = mapTrialData.SkillLevel}
    end
  end
  ;
  (PlayerData.Talent):CreateTrialData(tbTrialId)
  return self._mapTrialChar
end

PlayerCharData.DeleteTrialChar = function(self)
  -- function num : 0_25 , upvalues : _ENV
  self._mapTrialChar = {}
  ;
  (PlayerData.Talent):DeleteTrialData()
end

PlayerCharData.GetTrialCharById = function(self, nTrialId)
  -- function num : 0_26 , upvalues : _ENV
  local mapTrialChar = (self._mapTrialChar)[nTrialId]
  if mapTrialChar == nil then
    printError("没有该试用角色数据:" .. nTrialId)
  end
  return mapTrialChar
end

PlayerCharData.GetTrialCharByCharId = function(self, nCharId)
  -- function num : 0_27 , upvalues : _ENV
  for _,v in pairs(self._mapTrialChar) do
    if v.nId == nCharId then
      return v
    end
  end
end

PlayerCharData.GetCharPlotDataById = function(self, charId)
  -- function num : 0_28 , upvalues : _ENV
  return (CacheTable.GetData)("_Plot", charId)
end

PlayerCharData.IsPlotUnlock = function(self, plotId, charId)
  -- function num : 0_29 , upvalues : _ENV
  local data = (ConfigTable.GetData)("Plot", plotId)
  local bLock = false
  local locktxt = ""
  if data == nil then
    return bLock, locktxt
  end
  for _,nMainlineId in ipairs(data.Mainlines) do
    local nStar = (PlayerData.Mainline):GetMianlineLevelStar(nMainlineId)
    if nStar <= 0 then
      local mapMainline = (ConfigTable.GetData_Mainline)(nMainlineId)
      locktxt = orderedFormat((ConfigTable.GetUIText)("Plot_Limit_MainLine") or "", mapMainline.Name)
      bLock = true
      break
    end
  end
  do
    if not bLock then
      local mapCharAdvanceCond = decodeJson(data.CharAdvanceCond)
      if mapCharAdvanceCond ~= nil then
        for sCharId,nAdvance in pairs(mapCharAdvanceCond) do
          local mapCondChar = self:GetCharDataByTid(tonumber(sCharId))
          if mapCondChar ~= nil and mapCondChar.nAdvance < nAdvance then
            local sName = ((ConfigTable.GetData_Character)(tonumber(sCharId))).Name
            locktxt = orderedFormat((ConfigTable.GetUIText)("Plot_Limit_Advance") or "", sName, nAdvance)
            bLock = true
            break
          end
        end
      end
    end
    do
      if (self:GetCharAffinityData(charId)).Level >= data.UnlockAffinityLevel then
        bLock = bLock
        if not (ConfigTable.GetUIText)("Affinity_UnLock_Level") then
          locktxt = orderedFormat(not bLock or "", data.UnlockAffinityLevel)
          if not bLock and data.PrePlot ~= nil and data.PrePlot ~= 0 then
            bLock = not self:IsCharPlotFinish(charId, data.PrePlot)
            if bLock then
              local nIndex = 0
              local plotData = self:GetCharPlotDataById(charId)
              ;
              (table.sort)(plotData, function(a, b)
    -- function num : 0_29_0
    do return a.Id < b.Id end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
              for k,v in ipairs(plotData) do
                if v.Id == data.PrePlot then
                  nIndex = k
                  break
                end
              end
              locktxt = orderedFormat((ConfigTable.GetUIText)("Affinity_UnLock_PrePlot") or "", nIndex)
            end
          end
          do return bLock, locktxt end
          -- DECOMPILER ERROR: 7 unprocessed JMP targets
        end
      end
    end
  end
end

PlayerCharData.GetCharAffinityData = function(self, charId)
  -- function num : 0_30
  local mapData = (self._mapChar)[charId]
  if mapData == nil then
    return nil
  end
  local data = {}
  data.Exp = mapData.nAffinityExp
  data.Level = mapData.nAffinityLevel
  data.Quest = mapData.tbAffinityQuests
  return data
end

PlayerCharData.ChangeCharAffinityValue = function(self, msgData)
  -- function num : 0_31 , upvalues : _ENV
  local blevelUp = false
  if msgData ~= nil and (self._mapChar)[msgData.CharId] ~= nil then
    local lastLevel = ((self._mapChar)[msgData.CharId]).nAffinityLevel
    if ((self._mapChar)[msgData.CharId]).nAffinityLevel < msgData.AffinityLevel then
      blevelUp = true
    end
    local lastExp = ((self._mapChar)[msgData.CharId]).nAffinityExp
    -- DECOMPILER ERROR at PC28: Confused about usage of register: R5 in 'UnsetPending'

    ;
    ((self._mapChar)[msgData.CharId]).nAffinityExp = msgData.AffinityExp
    -- DECOMPILER ERROR at PC33: Confused about usage of register: R5 in 'UnsetPending'

    ;
    ((self._mapChar)[msgData.CharId]).nAffinityLevel = msgData.AffinityLevel
    if blevelUp then
      self:UpdateCharRecordInfoReddot(msgData.CharId, false, lastLevel, msgData.AffinityLevel)
      self:UpdateCharArchiveContentUpdateRedDot(msgData.CharId, 1, msgData.AffinityLevel, lastLevel)
    end
    -- DECOMPILER ERROR at PC54: Confused about usage of register: R5 in 'UnsetPending'

    if lastLevel < msgData.AffinityLevel then
      ((self._mapChar)[msgData.CharId]).bNeedShowAffinityLevelUp = true
      -- DECOMPILER ERROR at PC58: Confused about usage of register: R5 in 'UnsetPending'

      ;
      ((self._mapChar)[msgData.CharId]).nAffinityLastLevel = lastLevel
      -- DECOMPILER ERROR at PC62: Confused about usage of register: R5 in 'UnsetPending'

      ;
      ((self._mapChar)[msgData.CharId]).nAffinityLastExp = lastExp
    else
      -- DECOMPILER ERROR at PC70: Confused about usage of register: R5 in 'UnsetPending'

      if lastExp ~= msgData.AffinityExp then
        ((self._mapChar)[msgData.CharId]).bAffinityExpUp = true
      end
    end
    ;
    (EventManager.Hit)(EventId.AffinityChange, msgData.CharId, msgData.AffinityLevel, lastLevel, msgData.AffinityExp, lastExp)
    if msgData.AffinityLevel <= lastLevel and (PanelManager.CheckPanelOpen)(PanelId.CharFavourLevelUp) == false then
      (PlayerData.SideBanner):AddFavour(msgData.CharId)
    end
  end
end

PlayerCharData.GetIsNeedShowAffinityLevelUp = function(self, charId)
  -- function num : 0_32
  local mapData = (self._mapChar)[charId]
  if mapData ~= nil and mapData.bNeedShowAffinityLevelUp ~= nil and mapData.bNeedShowAffinityLevelUp == true then
    return mapData.nAffinityLastLevel, mapData.nAffinityLastExp
  end
  return -1
end

PlayerCharData.ChangeShowAffinityLevelUpState = function(self, charId)
  -- function num : 0_33
  local mapData = (self._mapChar)[charId]
  if mapData ~= nil and mapData.bNeedShowAffinityLevelUp ~= nil then
    mapData.bNeedShowAffinityLevelUp = false
  end
end

PlayerCharData.GetIsAffinityExpUp = function(self, charId)
  -- function num : 0_34
  local mapData = (self._mapChar)[charId]
  if mapData ~= nil and mapData.bAffinityExpUp ~= nil and mapData.bAffinityExpUp == true then
    mapData.bAffinityExpUp = false
    return true
  end
  return false
end

PlayerCharData.GetMaxAffinityLevel = function(self, templateId)
  -- function num : 0_35 , upvalues : _ENV
  local maxLevel = 0
  if not (CacheTable.GetData)("_AffinityLevel", templateId) then
    for k,v in pairs({}) do
      if maxLevel < v.AffinityLevel then
        maxLevel = v.AffinityLevel
      end
    end
    return maxLevel
  end
end

PlayerCharData.CheckCharArchiveBaseContentUpdate = function(self, nCharId, nBaseInfoId)
  -- function num : 0_36 , upvalues : _ENV
  local bUpdate = false
  local nValue = 0
  local contentData = (ConfigTable.GetData)("CharacterArchiveBaseInfo", nBaseInfoId)
  if contentData ~= nil and contentData.UpdateContent1 ~= "" then
    bUpdate = true
    if contentData.UpdateAff1 ~= 0 then
      local mapData = self:GetCharAffinityData(nCharId)
      local nCurLevel = mapData ~= nil and mapData.Level or 0
      bUpdate = not bUpdate or contentData.UpdateAff1 <= nCurLevel
      if contentData.UpdateAff1 <= nCurLevel then
        nValue = nValue | 1
      end
    else
      nValue = nValue | 1
    end
    if contentData.UpdatePlot1 ~= 0 then
      local bUnlock = self:IsCharPlotFinish(nCharId, contentData.UpdatePlot1)
      if bUpdate then
        bUpdate = bUnlock
      end
      if bUnlock then
        nValue = 2 | (nValue)
      end
    else
      nValue = 2 | (nValue)
    end
    if contentData.UpdateStory1 ~= 0 then
      local bReaded = (PlayerData.Avg):IsStoryReaded(contentData.UpdateStory1)
      if bUpdate then
        bUpdate = bReaded
      end
      if bReaded then
        nValue = 4 | (nValue)
      end
    else
      nValue = 4 | (nValue)
    end
  end
  do return bUpdate, nValue end
  -- DECOMPILER ERROR: 10 unprocessed JMP targets
end

PlayerCharData.CheckCharArchiveContentUpdate = function(self, nCharId, nArchiveContentId)
  -- function num : 0_37 , upvalues : _ENV
  local bUpdate = false
  local nValue = 0
  local contentData = (ConfigTable.GetData)("CharacterArchiveContent", nArchiveContentId)
  if contentData ~= nil and contentData.UpdateContent1 ~= "" then
    bUpdate = true
    if contentData.UpdateAff1 ~= 0 then
      local mapData = self:GetCharAffinityData(nCharId)
      local nCurLevel = mapData ~= nil and mapData.Level or 0
      bUpdate = not bUpdate or contentData.UpdateAff1 <= nCurLevel
      if contentData.UpdateAff1 <= nCurLevel then
        nValue = nValue | 1
      end
    else
      nValue = nValue | 1
    end
    if contentData.UpdatePlot1 ~= 0 then
      local bUnlock = self:IsCharPlotFinish(nCharId, contentData.UpdatePlot1)
      if bUpdate then
        bUpdate = bUnlock
      end
      if bUnlock then
        nValue = 2 | (nValue)
      end
    else
      nValue = 2 | (nValue)
    end
    if contentData.UpdateStory1 ~= 0 then
      local bReaded = (PlayerData.Avg):IsStoryReaded(contentData.UpdateStory1)
      if bUpdate then
        bUpdate = bReaded
      end
      if bReaded then
        nValue = 4 | (nValue)
      end
    else
      nValue = 4 | (nValue)
    end
  end
  do return bUpdate, nValue end
  -- DECOMPILER ERROR: 10 unprocessed JMP targets
end

PlayerCharData.CheckCharUnlock = function(self, nCharId)
  -- function num : 0_38
  do return (self._mapChar)[nCharId] ~= nil end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerCharData.CheckCharArchiveReward = function(self, nCharId, nArchiveId)
  -- function num : 0_39 , upvalues : _ENV
  local bReceived = false
  if (self._mapChar)[nCharId] ~= nil then
    local tbReceivedIds = ((self._mapChar)[nCharId]).tbArchiveRewardIds
    for _,v in ipairs(tbReceivedIds) do
      if v == nArchiveId then
        bReceived = true
        break
      end
    end
  end
  do
    return bReceived
  end
end

PlayerCharData.GetCharHonorTitleData = function(self, charId)
  -- function num : 0_40 , upvalues : _ENV
  if (self.tbHonorTitle)[charId] == nil then
    return nil
  end
  local tbData = {}
  local maxLevel = 0
  for k,v in ipairs((self.tbHonorTitle)[charId]) do
    tbData[v.Level] = v
    if maxLevel < v.Level then
      maxLevel = v.Level
    end
  end
  return tbData, maxLevel
end

PlayerCharData.TempCreateCharDataForBattleTest = function(self, tbTeamCharId, advances, cLevels)
  -- function num : 0_41 , upvalues : _ENV
  if self._mapChar == nil then
    self._mapChar = {}
  end
  for i,nCharId in ipairs(tbTeamCharId) do
    -- DECOMPILER ERROR at PC23: Confused about usage of register: R9 in 'UnsetPending'

    (self._mapChar)[nCharId] = {nRankExp = 0, nFavor = 1, nSkinId = nil, nCreateTime = 0, nLevel = 1, nAdvance = 0, 
tbSkillLvs = {[1] = 1, [2] = 1, [3] = 1, [4] = 1}
}
    -- DECOMPILER ERROR at PC29: Confused about usage of register: R9 in 'UnsetPending'

    if advances ~= nil then
      ((self._mapChar)[nCharId]).nAdvance = advances[i]
    end
    -- DECOMPILER ERROR at PC38: Confused about usage of register: R9 in 'UnsetPending'

    if cLevels ~= nil and cLevels[i] ~= 0 then
      ((self._mapChar)[nCharId]).nLevel = cLevels[i]
    end
  end
end

PlayerCharData.TempGetCharInfoData = function(self)
  -- function num : 0_42
  return self.nTempCharInfoData
end

PlayerCharData.TempSetCharInfoData = function(self, nTempCharId)
  -- function num : 0_43
  self.nTempCharInfoData = nTempCharId
end

PlayerCharData.TempClearCharInfoData = function(self)
  -- function num : 0_44
  self.nTempCharInfoData = nil
end

PlayerCharData.GetCharDataByTid = function(self, nTid)
  -- function num : 0_45
  if (self._mapChar)[nTid] == nil then
    return nil
  else
    return (self._mapChar)[nTid]
  end
end

PlayerCharData.GetCharIdList = function(self)
  -- function num : 0_46 , upvalues : _ENV
  local tbChar = {}
  for nCharId,data in pairs(self._mapChar) do
    (table.insert)(tbChar, data)
  end
  ;
  (table.sort)(tbChar, function(dataA, dataB)
    -- function num : 0_46_0
    do return dataA.nId < dataB.nId end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return tbChar
end

PlayerCharData.GetCharCfgAttr = function(self, tbPropertyIndexList, nCharId, nAdvance, nLevel)
  -- function num : 0_47 , upvalues : _ENV, ConfigData
  local mapAttr = {}
  local nAttrBaseId = (UTILS.GetCharacterAttributeId)(nCharId, nAdvance, nLevel)
  local mapAttribute = (ConfigTable.GetData_Attribute)(tostring(nAttrBaseId))
  if type(mapAttribute) == "table" then
    for i = 1, #tbPropertyIndexList do
      local nindex = tbPropertyIndexList[i]
      local mapCharAttr = (AllEnum.CharAttr)[nindex]
      local nParamValue = mapAttribute[mapCharAttr.sKey] or 0
      mapAttr[mapCharAttr.sKey] = {Key = mapCharAttr.sKey, Value = mapCharAttr.bPercent and nParamValue * ConfigData.IntFloatPrecision * 100 or nParamValue, CfgValue = mapAttribute[mapCharAttr.sKey] or 0}
    end
  else
    do
      printError("角色属性配置错误：" .. nAttrBaseId)
      for i = 1, #tbPropertyIndexList do
        local nindex = tbPropertyIndexList[i]
        local mapCharAttr = (AllEnum.CharAttr)[nindex]
        mapAttr[mapCharAttr.sKey] = {Key = mapCharAttr.sKey, Value = 0, CfgValue = 0}
      end
      do
        return mapAttr
      end
    end
  end
end

PlayerCharData.GetUpgradeMatList = function(self)
  -- function num : 0_48 , upvalues : _ENV
  local tbMat = {}
  for _,value in ipairs(self.tbItemExp) do
    (table.insert)(tbMat, {nItemId = value.nItemId, nExpValue = value.nExpValue, nCost = 0})
  end
  ;
  (table.sort)(tbMat, function(a, b)
    -- function num : 0_48_0
    do return b.nExpValue < a.nExpValue end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return tbMat
end

PlayerCharData.CalCostProportion = function(self, nTarget, tbMatType, tbHas)
  -- function num : 0_49 , upvalues : _ENV
  local nTypeCount = #tbMatType
  local GetProportionedSum = function(tbProportioned)
    -- function num : 0_49_0 , upvalues : nTypeCount, tbMatType
    local nSum = 0
    for i = 1, nTypeCount do
      nSum = nSum + tbMatType[i] * tbProportioned[i]
    end
    return nSum
  end

  local tbCost = tbHas
  local nMinTarget = GetProportionedSum(tbHas)
  if nMinTarget <= nTarget then
    return tbHas
  end
  local tbSumOfTypeFollowing = {}
  tbSumOfTypeFollowing[nTypeCount + 1] = 0
  for i = nTypeCount, 1, -1 do
    local nCurTypeSum = tbMatType[i] * tbHas[i]
    tbSumOfTypeFollowing[i] = nCurTypeSum + tbSumOfTypeFollowing[i + 1]
  end
  local GetLargeFaceValue = function(tbCost1, tbCost2)
    -- function num : 0_49_1
    for i = 1, #tbCost1 do
      if tbCost2[i] < tbCost1[i] then
        return tbCost1
      else
        if tbCost1[i] < tbCost2[i] then
          return tbCost2
        end
      end
    end
    return tbCost1
  end

  local Proportion = function(tbProportioned, nCurMatType, nRemain)
    -- function num : 0_49_2 , upvalues : nTypeCount, GetProportionedSum, nTarget, nMinTarget, tbCost, GetLargeFaceValue, _ENV, tbMatType, tbHas, Proportion
    if nTypeCount < nCurMatType or nRemain <= 0 then
      local nSum = GetProportionedSum(tbProportioned)
      if nTarget <= nSum then
        if nSum < nMinTarget then
          nMinTarget = nSum
          tbCost = tbProportioned
        else
          if nSum == nMinTarget then
            tbCost = GetLargeFaceValue(tbCost, tbProportioned)
          end
        end
      end
    else
      do
        local nMaxUse = (math.ceil)(nRemain / tbMatType[nCurMatType])
        nMaxUse = (math.min)(nMaxUse, tbHas[nCurMatType])
        local nMinUse = (math.max)(nMaxUse - 1, 0)
        for i = nMaxUse, nMinUse, -1 do
          local tbCopy = {(table.unpack)(tbProportioned)}
          tbCopy[nCurMatType] = i
          local nSum = GetProportionedSum(tbCopy)
          if nMinTarget < nSum then
            return 
          end
          local nNextRemain = nRemain - i * tbMatType[nCurMatType]
          Proportion(tbCopy, nCurMatType + 1, nNextRemain)
        end
      end
    end
  end

  local tbProportioned = {}
  for i = 1, nTypeCount do
    tbProportioned[i] = 0
  end
  Proportion(tbProportioned, 1, nTarget)
  return tbCost
end

PlayerCharData.CalUpgradeExp = function(self, Grade, nStartLevel, nTargetLevel, nStartExp)
  -- function num : 0_50 , upvalues : _ENV
  local nTotalExp = 0
  for i = nStartLevel, nTargetLevel - 1 do
    local nUpgradeId = 10000 + Grade * 1000 + i + 1
    local mapUpgrade = (ConfigTable.GetData)("CharacterUpgrade", nUpgradeId, true)
    local nExp = 0
    if mapUpgrade then
      nExp = mapUpgrade.Exp
    end
    nTotalExp = nTotalExp + nExp
  end
  nTotalExp = nTotalExp - nStartExp
  return nTotalExp
end

PlayerCharData.CalUpgradeMat = function(self, nTargetExp)
  -- function num : 0_51 , upvalues : _ENV
  local tbMatType, tbHas = {}, {}
  for _,value in ipairs(self.tbItemExp) do
    (table.insert)(tbMatType, value.nExpValue)
    ;
    (table.insert)(tbHas, (PlayerData.Item):GetItemCountByID(value.nItemId))
  end
  local tbCostCount = self:CalCostProportion(nTargetExp, tbMatType, tbHas)
  local tbMat = {}
  for nIndex,value in ipairs(self.tbItemExp) do
    (table.insert)(tbMat, {nItemId = value.nItemId, nExpValue = value.nExpValue, nCost = tbCostCount[nIndex]})
  end
  return tbMat
end

PlayerCharData.GetCustomizeLevelExp = function(self, nCharId, nLevel)
  -- function num : 0_52 , upvalues : _ENV
  local mapChar = (self._mapChar)[nCharId]
  if not mapChar then
    return 0
  end
  local Grade = ((ConfigTable.GetData_Character)(nCharId)).Grade
  local nNextExp = self:CalUpgradeExp(Grade, mapChar.nLevel, nLevel, mapChar.nRankExp)
  return nNextExp
end

PlayerCharData.GetMaxLevelExp = function(self, nCharId, MaxLevel)
  -- function num : 0_53 , upvalues : _ENV
  local mapChar = (self._mapChar)[nCharId]
  if not mapChar then
    return 0
  end
  local Grade = ((ConfigTable.GetData_Character)(nCharId)).Grade
  local nNextExp = self:CalUpgradeExp(Grade, mapChar.nLevel, MaxLevel, mapChar.nRankExp)
  return nNextExp
end

PlayerCharData.GetMaxMatCost = function(self, nCharId, tbMat, mapMat, MaxLevel)
  -- function num : 0_54 , upvalues : _ENV
  local nMatExp = mapMat.nExpValue
  local nMaxExp = self:GetMaxLevelExp(nCharId, MaxLevel)
  local nHasExp = self:GetMatExp(tbMat)
  local nCount = (math.ceil)((nMaxExp - nHasExp) / nMatExp)
  return nCount
end

PlayerCharData.GetMatExp = function(self, tbMat)
  -- function num : 0_55 , upvalues : _ENV
  local nTotalExp = 0
  for _,mapMat in ipairs(tbMat) do
    nTotalExp = nTotalExp + mapMat.nExpValue * mapMat.nCost
  end
  return nTotalExp
end

PlayerCharData.GetCustomizeLevelDataAndCost = function(self, nCharId, nLevel, nMaxLevel)
  -- function num : 0_56
  local nTargetExp = self:GetCustomizeLevelExp(nCharId, nLevel)
  local tbMat = self:CalUpgradeMat(nTargetExp)
  local mapTargetLevel, nGoldCost = self:GetLevelDataAndCostByMat(nCharId, tbMat, nMaxLevel)
  return mapTargetLevel, tbMat, nGoldCost
end

PlayerCharData.GetMaxLevelDataAndCost = function(self, nCharId, nMaxLevel)
  -- function num : 0_57
  local nTargetExp = self:GetMaxLevelExp(nCharId, nMaxLevel)
  local tbMat = self:CalUpgradeMat(nTargetExp)
  local mapTargetLevel, nGoldCost = self:GetLevelDataAndCostByMat(nCharId, tbMat, nMaxLevel)
  return mapTargetLevel, tbMat, nGoldCost
end

PlayerCharData.GetLevelDataAndCostByMat = function(self, nCharId, tbMat, nMaxLevel)
  -- function num : 0_58 , upvalues : _ENV
  local mapChar = (self._mapChar)[nCharId]
  if not mapChar then
    return nil
  end
  local nMatExp = self:GetMatExp(tbMat)
  local nGoldCost = nMatExp * self.goldperExp
  local nTotalExp = nMatExp + mapChar.nRankExp
  local Grade = ((ConfigTable.GetData_Character)(nCharId)).Grade
  local nStartLevel = mapChar.nLevel
  local nTargetLevel = nStartLevel
  for i = nStartLevel, nMaxLevel - 1 do
    local nUpgradeId = 10000 + Grade * 1000 + i + 1
    local mapUpgrade = (ConfigTable.GetData)("CharacterUpgrade", nUpgradeId, true)
    local nExp = 0
    if mapUpgrade then
      nExp = mapUpgrade.Exp
    end
    if nExp <= nTotalExp then
      nTotalExp = nTotalExp - nExp
      nTargetLevel = nTargetLevel + 1
    else
      break
    end
  end
  do
    if nTargetLevel == nMaxLevel then
      nGoldCost = nGoldCost - (nTotalExp) * self.goldperExp
      nMatExp = nMatExp - (nTotalExp)
      nTotalExp = 0
    end
    local mapLevelData = {nLevel = nTargetLevel, nExp = nTotalExp, nMaxLevel = nMaxLevel, nMaxExp = self:GetMaxExp(Grade, nTargetLevel), nMatExp = nMatExp}
    self.nMaxLevel = nMaxLevel
    return mapLevelData, nGoldCost
  end
end

PlayerCharData.GetMaxExp = function(self, Grade, nTargetLevel)
  -- function num : 0_59 , upvalues : _ENV
  local retExp = 99999
  local nUpgradeId = 10000 + Grade * 1000 + nTargetLevel + 1
  local mapUpgrade = (ConfigTable.GetData)("CharacterUpgrade", nUpgradeId, true)
  if mapUpgrade == nil then
    return retExp
  end
  return mapUpgrade.Exp
end

PlayerCharData.GetAllCharCount = function(self)
  -- function num : 0_60 , upvalues : _ENV
  local nChar = 0
  for _,_ in pairs(self._mapChar) do
    nChar = nChar + 1
  end
  return nChar
end

PlayerCharData.GetDataForCharList = function(self)
  -- function num : 0_61 , upvalues : _ENV
  local mapChar = {}
  for nCharId,data in pairs(self._mapChar) do
    local mapCfg = (ConfigTable.GetData_Character)(nCharId)
    if mapCfg ~= nil then
      mapChar[nCharId] = {}
      -- DECOMPILER ERROR at PC14: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (mapChar[nCharId]).nId = nCharId
      -- DECOMPILER ERROR at PC17: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (mapChar[nCharId]).Name = mapCfg.Name
      -- DECOMPILER ERROR at PC20: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (mapChar[nCharId]).Rare = mapCfg.Grade
      -- DECOMPILER ERROR at PC23: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (mapChar[nCharId]).Class = mapCfg.Class
      -- DECOMPILER ERROR at PC26: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (mapChar[nCharId]).EET = mapCfg.EET
      -- DECOMPILER ERROR at PC31: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (mapChar[nCharId]).Level = self:GetCharLv(nCharId)
      -- DECOMPILER ERROR at PC34: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (mapChar[nCharId]).CreateTime = data.nCreateTime
      -- DECOMPILER ERROR at PC39: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (mapChar[nCharId]).Advance = self:GetCharAdvance(nCharId)
      -- DECOMPILER ERROR at PC45: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (mapChar[nCharId]).Favorability = (self:GetCharAffinityData(nCharId)).Level
    else
      printError(nCharId .. "角色数据不存在")
    end
  end
  return mapChar
end

PlayerCharData.GetCharDataById = function(self, nCharId)
  -- function num : 0_62 , upvalues : _ENV
  local tbCharData = {}
  local cfgChar = (ConfigTable.GetData_Character)(nCharId)
  if (self._mapChar)[nCharId] ~= nil and cfgChar ~= nil then
    tbCharData.nId = nCharId
    tbCharData.Name = cfgChar.Name
    tbCharData.Rare = cfgChar.Grade
    tbCharData.Class = cfgChar.Class
    tbCharData.EET = cfgChar.EET
    tbCharData.Level = self:GetCharLv(nCharId)
    tbCharData.CreateTime = ((self._mapChar)[nCharId]).nCreateTime
    tbCharData.Advance = self:GetCharAdvance(nCharId)
    tbCharData.Favorability = (self:GetCharAffinityData(nCharId)).Level
  end
  return tbCharData
end

PlayerCharData.GetCharLv = function(self, nCharId)
  -- function num : 0_63 , upvalues : _ENV
  local mapTrialInfo = nil
  for k,v in pairs(self._mapTrialChar) do
    local mapCfgData_TrialCharacter = (ConfigTable.GetData)("TrialCharacter", k)
    if mapCfgData_TrialCharacter ~= nil and mapCfgData_TrialCharacter.CharId == nCharId then
      mapTrialInfo = v
      break
    end
  end
  do
    if mapTrialInfo == nil then
      local mapCharInfo = (self._mapChar)[nCharId]
      if mapCharInfo == nil then
        return nil
      else
        if type(mapCharInfo.nLevel) ~= "number" then
          mapCharInfo.nLevel = 1
        end
        return mapCharInfo.nLevel
      end
    else
      do
        do return mapTrialInfo.nLevel end
      end
    end
  end
end

PlayerCharData.CalCharMaxLevel = function(self, nCharId, nAdvance)
  -- function num : 0_64 , upvalues : _ENV
  local mapCharInfo = (self._mapTrialChar)[nCharId]
  if mapCharInfo == nil then
    mapCharInfo = (self._mapChar)[nCharId]
    if mapCharInfo == nil then
      return nil
    end
  end
  if nAdvance == nil then
    nAdvance = mapCharInfo.nAdvance
  end
  local MaxLevel = 0
  local tbAdvanceLevel = self:GetAdvanceLevelTable()
  local Grade = ((ConfigTable.GetData_Character)(nCharId)).Grade
  local curGradeLevelArr = tbAdvanceLevel[Grade]
  local maxAdvance = 0
  for i = 1, #curGradeLevelArr do
    maxAdvance = maxAdvance + 1
    if nAdvance + 1 == i then
      MaxLevel = curGradeLevelArr[nAdvance + 1]
      return MaxLevel
    end
  end
  MaxLevel = mapCharInfo.nLevel
  return MaxLevel
end

PlayerCharData.GetCharSkinId = function(self, nCharId)
  -- function num : 0_65 , upvalues : _ENV
  local mapTrialInfo = nil
  for k,v in pairs(self._mapTrialChar) do
    local mapCfgData_TrialCharacter = (ConfigTable.GetData)("TrialCharacter", k)
    if mapCfgData_TrialCharacter ~= nil and mapCfgData_TrialCharacter.CharId == nCharId then
      mapTrialInfo = v
      break
    end
  end
  do
    if mapTrialInfo == nil then
      local mapCharInfo = (self._mapChar)[nCharId]
      if mapCharInfo ~= nil then
        if type(mapCharInfo.nSkinId) ~= "number" then
          mapCharInfo.nSkinId = ((ConfigTable.GetData_Character)(nCharId)).DefaultSkinId
        end
        return mapCharInfo.nSkinId
      else
        local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
        if mapCharCfg == nil then
          return 0
        else
          return mapCharCfg.DefaultSkinId
        end
      end
    else
      do
        do return mapTrialInfo.nSkinId end
        return 0
      end
    end
  end
end

PlayerCharData.SetCharSkinId = function(self, nCharId, nSkinId)
  -- function num : 0_66 , upvalues : _ENV
  local mapCharInfo = (self._mapChar)[nCharId]
  if mapCharInfo == nil then
    return 
  else
    if type(nSkinId) == "number" then
      mapCharInfo.nSkinId = nSkinId
    else
      mapCharInfo.nSkinId = ((ConfigTable.GetData_Character)(nCharId)).DefaultSkinId
    end
  end
  ;
  (EventManager.Hit)(EventId.CharacterSkinChange, nCharId, nSkinId)
end

PlayerCharData.CalcAffinityEffect = function(self, nCharId)
  -- function num : 0_67 , upvalues : _ENV
  local tbEfts = (PlayerData.Char):GetCharAffinityEffects(nCharId)
  if tbEfts == nil then
    return 
  end
  return tbEfts
end

PlayerCharData.CalcTalentEffect = function(self, nCharId)
  -- function num : 0_68 , upvalues : _ENV
  local tbEfts = (PlayerData.Talent):GetTalentEffect(nCharId)
  if tbEfts == nil then
    return {1130101}
  end
  return tbEfts
end

PlayerCharData.GetCharFavorability = function(self, nCharId)
  -- function num : 0_69
  return 1
end

PlayerCharData.GetCharAdvance = function(self, nCharId)
  -- function num : 0_70
  local mapData = (self._mapChar)[nCharId]
  if mapData ~= nil then
    return mapData.nAdvance
  else
    return 0
  end
end

PlayerCharData.GetCharAffinityEffects = function(self, nCharId)
  -- function num : 0_71 , upvalues : _ENV
  local mapData = (self._mapChar)[nCharId]
  local effectIds = {}
  if mapData ~= nil then
    local mapCfg = (ConfigTable.GetData)("CharAffinityTemplate", nCharId)
    do
      if not mapCfg then
        return effectIds
      end
      local templateId = mapCfg.TemplateId
      local forEachAffinityLevel = function(affinityData)
    -- function num : 0_71_0 , upvalues : templateId, mapData, _ENV, effectIds
    if affinityData.TemplateId == templateId and mapData.nAffinityLevel ~= nil and affinityData.AffinityLevel == mapData.nAffinityLevel and affinityData.Effect ~= nil and #affinityData.Effect > 0 then
      for k,v in ipairs(affinityData.Effect) do
        (table.insert)(effectIds, v)
      end
    end
  end

      ForEachTableLine(DataTable.AffinityLevel, forEachAffinityLevel)
    end
  end
  do
    return effectIds
  end
end

PlayerCharData.CharUpgrade = function(self, nCharId, tbMat, mapTargetLevel, callback)
  -- function num : 0_72 , upvalues : _ENV
  local tbItems = {}
  for _,mapMat in pairs(tbMat) do
    if mapMat.nCost > 0 then
      (table.insert)(tbItems, {Id = 0, Qty = mapMat.nCost, Tid = mapMat.nItemId})
    end
  end
  local mapMsg = {CharId = nCharId, Items = tbItems}
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_72_0 , upvalues : _ENV, self, nCharId, mapTargetLevel, callback
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    -- DECOMPILER ERROR at PC12: Confused about usage of register: R3 in 'UnsetPending'

    ;
    ((self._mapChar)[nCharId]).nLevel = mapTargetLevel.nLevel
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R3 in 'UnsetPending'

    ;
    ((self._mapChar)[nCharId]).nRankExp = mapTargetLevel.nExp
    if callback ~= nil then
      callback(mapMsgData.Level, mapMsgData.Exp)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_upgrade_req, mapMsg, nil, msgCallback)
end

PlayerCharData.CharAdvance = function(self, nCharId, callback)
  -- function num : 0_73 , upvalues : _ENV
  local mapMsg = {Value = nCharId}
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_73_0 , upvalues : _ENV, self, nCharId, callback
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    -- DECOMPILER ERROR at PC16: Confused about usage of register: R3 in 'UnsetPending'

    ;
    ((self._mapChar)[nCharId]).nAdvance = ((self._mapChar)[nCharId]).nAdvance + 1
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_advance_req, mapMsg, nil, msgCallback)
end

PlayerCharData.CharAdvanceReward = function(self, nCharId, nAdvance, callback)
  -- function num : 0_74 , upvalues : _ENV
  local mapMsg = {CharId = nCharId, Advance = nAdvance}
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_74_0 , upvalues : callback, _ENV
    if callback ~= nil then
      (UTILS.OpenReceiveByChangeInfo)(mapMsgData.Change)
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_advance_reward_receive_req, mapMsg, nil, msgCallback)
end

PlayerCharData.CharPlotFinish = function(self, nCharId, nPlotId, callback)
  -- function num : 0_75 , upvalues : _ENV
  local mapMsg = {Value = nPlotId}
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_75_0 , upvalues : _ENV, self, nCharId, nPlotId, callback
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
    self:ChangeCharPlotState(nCharId, nPlotId)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    ;
    (EventManager.Hit)(EventId.ClosePanel, PanelId.PureAvgStory)
    if callback ~= nil then
      callback(mapMsgData, nCharId)
    end
    self:UpdateCharPlotReddot(nCharId)
    self:UpdateCharArchiveContentUpdateRedDot(nCharId, 2, nPlotId)
    self:UpdateCharVoiceReddot(nCharId, false, nil, nil, nPlotId)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).plot_reward_receive_req, mapMsg, nil, msgCallback)
end

PlayerCharData.ChangeCharPlotState = function(self, nCharId, nPlotId)
  -- function num : 0_76 , upvalues : _ENV
  if (self._mapChar)[nCharId] == nil then
    return 
  end
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R3 in 'UnsetPending'

  if ((self._mapChar)[nCharId]).tbPlot == nil then
    ((self._mapChar)[nCharId]).tbPlot = {}
  end
  ;
  (table.insert)(((self._mapChar)[nCharId]).tbPlot, nPlotId)
end

PlayerCharData.SendCharArchiveRewardReceive = function(self, nCharId, nArchiveId, callback)
  -- function num : 0_77 , upvalues : _ENV
  local mapMsg = {ArchiveId = nArchiveId}
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_77_0 , upvalues : self, nCharId, _ENV, nArchiveId, callback
    if (self._mapChar)[nCharId] ~= nil and ((self._mapChar)[nCharId]).tbArchiveRewardIds ~= nil then
      (table.insert)(((self._mapChar)[nCharId]).tbArchiveRewardIds, nArchiveId)
    end
    self:UpdateCharArchiveRewardRedDot(nCharId)
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapMsgData)
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_archive_reward_receive_req, mapMsg, nil, msgCallback)
end

PlayerCharData.CharSkillUpgrade = function(self, nCharId, nSkillIdx, callback)
  -- function num : 0_78 , upvalues : _ENV
  local mapMsg = {CharId = nCharId, Index = nSkillIdx}
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_78_0 , upvalues : _ENV, self, nCharId, nSkillIdx, callback
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (((self._mapChar)[nCharId]).tbSkillLvs)[nSkillIdx] = (((self._mapChar)[nCharId]).tbSkillLvs)[nSkillIdx] + 1
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_skill_upgrade_req, mapMsg, nil, msgCallback)
end

PlayerCharData.ReqCharFragmentRecruit = function(self, nCharId, callBack)
  -- function num : 0_79 , upvalues : _ENV
  local mapMsg = {Value = nCharId}
  local successCallback = function(_, mapChangeInfo)
    -- function num : 0_79_0 , upvalues : nCharId, _ENV, callBack
    local tbSpReward = {}
    local rewardData = {nId = nCharId, nType = (GameEnum.itemType).Char, bNew = true}
    ;
    (table.insert)(tbSpReward, rewardData)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.ReceiveSpecialReward, tbSpReward, callBack)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_recruitment_req, mapMsg, nil, successCallback)
end

PlayerCharData.QueryLevelInfo = function(self, nId, nType, nParam1, nParam2)
  -- function num : 0_80 , upvalues : _ENV
  local useSkillLevel = function(tbSkillLevel)
    -- function num : 0_80_0 , upvalues : nParam1, nParam2, _ENV
    if nParam1 == nil then
      return tbSkillLevel[1]
    else
      if nParam1 == 2 then
        if nParam2 == (GameEnum.MainOrSupport).SUPPORT then
          return tbSkillLevel[3]
        else
          return tbSkillLevel[2]
        end
      else
        if nParam1 == 4 then
          return tbSkillLevel[4]
        else
          if nParam1 == 5 then
            return tbSkillLevel[1]
          else
            return tbSkillLevel[1]
          end
        end
      end
    end
  end

  if nType == (GameEnum.levelTypeData).None then
    return 0
  else
    if nType == (GameEnum.levelTypeData).Exclusive then
      return 1
    else
      if nType == (GameEnum.levelTypeData).Actor then
        local mapTrialChar = self:GetTrialCharByCharId(nId)
        if mapTrialChar then
          return mapTrialChar.nLevel
        end
        if (self._mapChar)[nId] == nil then
          return 1
        end
        return ((self._mapChar)[nId]).nLevel
      else
        do
          if nType == (GameEnum.levelTypeData).SkillSlot then
            local mapTrialChar = self:GetTrialCharByCharId(nId)
            do
              if mapTrialChar then
                local tbSkillLevel = self:GetTrialCharSkillAddedLevel(mapTrialChar.nTrialId)
                return useSkillLevel(tbSkillLevel)
              end
              if (self._mapChar)[nId] == nil then
                return 1
              end
              do
                local tbSkillLevel = self:GetCharSkillAddedLevel(nId)
                do return useSkillLevel(tbSkillLevel) end
                do
                  if nType == (GameEnum.levelTypeData).BreakCount then
                    local mapTrialChar = self:GetTrialCharByCharId(nId)
                    if mapTrialChar then
                      return mapTrialChar.nAdvance + 1
                    end
                    if (self._mapChar)[nId] == nil then
                      return 1
                    end
                    return ((self._mapChar)[nId]).nAdvance + 1
                  end
                  return 1
                end
              end
            end
          end
        end
      end
    end
  end
end

PlayerCharData.GetCharDatingEvent = function(self, nChar)
  -- function num : 0_81
  local data = {}
  if (self._mapChar)[nChar] ~= nil then
    if not ((self._mapChar)[nChar]).tbDatingEventIds then
      data.tbDatingEventIds = {}
      if not ((self._mapChar)[nChar]).tbDatingEventRewardIds then
        data.tbDatingEventRewardIds = {}
        return data
      end
    end
  end
end

PlayerCharData.CalCharacterAttrBattle = function(self, nCharId, stAttr, bMainChar, tbDiscId, nBuildId)
  -- function num : 0_82 , upvalues : _ENV, ConfigData, AttrConfig
  local mapChar = (self._mapChar)[nCharId]
  if mapChar == nil then
    printError("没有该角色数据" .. nCharId)
    mapChar = {nLevel = 1, nAdvance = 0, 
tbSkillLvs = {1, 1, 1, 1}
}
  end
  local nLevel = mapChar.nLevel
  local nAdvance = mapChar.nAdvance
  local nAttrId = (UTILS.GetCharacterAttributeId)(nCharId, nAdvance, nLevel)
  local mapCharAttrCfg = (ConfigTable.GetData_Attribute)(tostring(nAttrId))
  if mapCharAttrCfg == nil then
    printError("属性配置不存在:" .. nAttrId)
    return {}
  end
  local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
  if mapCharCfg == nil then
    printError("角色配置不存在:" .. nCharId)
    return {}
  end
  for _,v in ipairs(AllEnum.AttachAttr) do
    if v.bPlayer and mapCharCfg[v.sKey] ~= nil then
      mapCharAttrCfg[v.sKey] = mapCharCfg[v.sKey]
    end
  end
  local mapDiscAttr = {}
  for _,v in ipairs(AllEnum.AttachAttr) do
    mapDiscAttr[v.sKey] = {Key = v.sKey, Value = 0, CfgValue = 0}
  end
  if tbDiscId ~= nil then
    for _,nDiscId in ipairs(tbDiscId) do
      local mapDisc = (PlayerData.Disc):GetDiscById(nDiscId)
      if mapDisc and mapDisc.mapAttrBase then
        for _,v in ipairs(AllEnum.AttachAttr) do
          -- DECOMPILER ERROR at PC120: Confused about usage of register: R24 in 'UnsetPending'

          (mapDiscAttr[v.sKey]).CfgValue = (mapDiscAttr[v.sKey]).CfgValue + ((mapDisc.mapAttrBase)[v.sKey]).CfgValue
        end
      else
        do
          do
            printError("星盘数据有误id:" .. nDiscId)
            -- DECOMPILER ERROR at PC129: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC129: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC129: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
  local mapBuildAttr = {}
  if nBuildId ~= nil then
    mapBuildAttr = (PlayerData.Build):GetBuildAttrBase(nBuildId)
  else
    for _,v in ipairs(AllEnum.AttachAttr) do
      mapBuildAttr[v.sKey] = {Key = v.sKey, Value = 0, CfgValue = 0}
    end
  end
  do
    local tbSkillLevel = self:GetCharSkillAddedLevel(nCharId)
    if bMainChar == true then
      (table.remove)(tbSkillLevel, 3)
    else
      ;
      (table.remove)(tbSkillLevel, 2)
    end
    local mapCharAttr = {}
    for _,v in ipairs(AllEnum.AttachAttr) do
      mapCharAttr[v.sKey] = mapCharAttrCfg[v.sKey] + (mapDiscAttr[v.sKey]).CfgValue + (mapBuildAttr[v.sKey]).CfgValue
      mapCharAttr["_" .. v.sKey] = mapCharAttr[v.sKey]
      mapCharAttr["_" .. v.sKey .. "PercentAmend"] = 0
      mapCharAttr["_" .. v.sKey .. "Amend"] = 0
    end
    local AddAttrEffect_AllEffectSub = function(nSubType, nValue, mapAttr)
    -- function num : 0_82_0 , upvalues : _ENV, ConfigData, mapCharAttr
    local value = tonumber(nValue) or 0
    if nSubType == (GameEnum.parameterType).BASE_VALUE then
      if not mapAttr.bPercent or not value then
        local nAdd = value * ConfigData.IntFloatPrecision
      end
      mapCharAttr["_" .. mapAttr.sKey] = mapCharAttr["_" .. mapAttr.sKey] + nAdd
    end
  end

    local tbRandomAttr = (PlayerData.Equipment):GetCharEquipmentRandomAttr(nCharId)
    if tbRandomAttr ~= nil then
      for nAttrValueId,v in pairs(tbRandomAttr) do
        local mapAttrCfg = (ConfigTable.GetData)("CharGemAttrValue", nAttrValueId)
        if mapAttrCfg then
          local attrType = mapAttrCfg.AttrType
          local attrSubType1 = mapAttrCfg.AttrTypeFirstSubtype
          local attrSubType2 = mapAttrCfg.AttrTypeSecondSubtype
          local bAttrFix = attrType == (GameEnum.effectType).ATTR_FIX or attrType == (GameEnum.effectType).PLAYER_ATTR_FIX
          if bAttrFix then
            local mapAttr = (AttrConfig.GetAttrByEffectType)(attrType, attrSubType1)
            if mapAttr == nil then
              printError((string.format)("【装备随机属性】lua属性配置中没找到对应配置!!! attrId = %s", nAttrValueId))
            else
              AddAttrEffect_AllEffectSub(attrSubType2, v.CfgValue, mapAttr)
            end
          end
        end
      end
    end
    for _,v in ipairs(AllEnum.AttachAttr) do
      mapCharAttr[v.sKey] = mapCharAttr["_" .. v.sKey] * (1 + mapCharAttr["_" .. v.sKey .. "PercentAmend"] / 100) + mapCharAttr["_" .. v.sKey .. "Amend"]
      mapCharAttr[v.sKey] = (math.floor)(mapCharAttr[v.sKey])
    end
    local tbTalent = (PlayerData.Talent):GetFateTalent(nCharId)
    stAttr.actorLevel = nLevel
    stAttr.breakCount = mapChar.nAdvance
    stAttr.activeTalentInfos = tbTalent
    stAttr.Atk = mapCharAttr.Atk
    stAttr.Hp = mapCharAttr.Hp
    stAttr.Def = mapCharAttr.Def
    stAttr.CritRate = mapCharAttr.CritRate
    stAttr.CritResistance = mapCharAttr.CritResistance
    stAttr.CritPower = mapCharAttr.CritPower
    stAttr.HitRate = mapCharAttr.HitRate
    stAttr.Evd = mapCharAttr.Evd
    stAttr.DefPierce = mapCharAttr.DefPierce
    stAttr.WEP = mapCharAttr.WEP
    stAttr.FEP = mapCharAttr.FEP
    stAttr.SEP = mapCharAttr.SEP
    stAttr.AEP = mapCharAttr.AEP
    stAttr.LEP = mapCharAttr.LEP
    stAttr.DEP = mapCharAttr.DEP
    stAttr.WEE = mapCharAttr.WEE
    stAttr.FEE = mapCharAttr.FEE
    stAttr.SEE = mapCharAttr.SEE
    stAttr.AEE = mapCharAttr.AEE
    stAttr.LEE = mapCharAttr.LEE
    stAttr.DEE = mapCharAttr.DEE
    stAttr.WER = mapCharAttr.WER
    stAttr.FER = mapCharAttr.FER
    stAttr.SER = mapCharAttr.SER
    stAttr.AER = mapCharAttr.AER
    stAttr.LER = mapCharAttr.LER
    stAttr.DER = mapCharAttr.DER
    stAttr.WEI = mapCharAttr.WEI
    stAttr.FEI = mapCharAttr.FEI
    stAttr.SEI = mapCharAttr.SEI
    stAttr.AEI = mapCharAttr.AEI
    stAttr.LEI = mapCharAttr.LEI
    stAttr.DEI = mapCharAttr.DEI
    stAttr.DefIgnore = mapCharAttr.DefIgnore
    stAttr.ShieldBonus = mapCharAttr.ShieldBonus
    stAttr.IncomingShieldBonus = mapCharAttr.IncomingShieldBonus
    stAttr.SkillLevel = tbSkillLevel
    stAttr.skinId = self:GetCharSkinId(nCharId)
    stAttr.attrId = tostring(nAttrId)
    stAttr.Suppress = mapCharAttr.Suppress
    stAttr.NormalDmgRatio = mapCharAttr.NORMALDMG
    stAttr.SkillDmgRatio = mapCharAttr.SKILLDMG
    stAttr.UltraDmgRatio = mapCharAttr.ULTRADMG
    stAttr.OtherDmgRatio = mapCharAttr.OTHERDMG
    stAttr.RcdNormalDmgRatio = mapCharAttr.RCDNORMALDMG
    stAttr.RcdSkillDmgRatio = mapCharAttr.RCDSKILLDMG
    stAttr.RcdUltraDmgRatio = mapCharAttr.RCDULTRADMG
    stAttr.RcdOtherDmgRatio = mapCharAttr.RCDOTHERDMG
    stAttr.MarkDmgRatio = mapCharAttr.MARKDMG
    stAttr.SummonDmgRatio = mapCharAttr.SUMMONDMG
    stAttr.RcdSummonDmgRatio = mapCharAttr.RCDSUMMONDMG
    stAttr.ProjectileDmgRatio = mapCharAttr.PROJECTILEDMG
    stAttr.RcdProjectileDmgRatio = mapCharAttr.RCDPROJECTILEDMG
    stAttr.GENDMG = mapCharAttr.GENDMG
    stAttr.DMGPLUS = mapCharAttr.DMGPLUS
    stAttr.FINALDMG = mapCharAttr.FINALDMG
    stAttr.FINALDMGPLUS = mapCharAttr.FINALDMGPLUS
    stAttr.WEERCD = mapCharAttr.WEERCD
    stAttr.FEERCD = mapCharAttr.FEERCD
    stAttr.SEERCD = mapCharAttr.SEERCD
    stAttr.AEERCD = mapCharAttr.AEERCD
    stAttr.LEERCD = mapCharAttr.LEERCD
    stAttr.DEERCD = mapCharAttr.DEERCD
    stAttr.GENDMGRCD = mapCharAttr.GENDMGRCD
    stAttr.DMGPLUSRCD = mapCharAttr.DMGPLUSRCD
    stAttr.NormalCritRate = mapCharAttr.NormalCritRate
    stAttr.SkillCritRate = mapCharAttr.SkillCritRate
    stAttr.UltraCritRate = mapCharAttr.UltraCritRate
    stAttr.MarkCritRate = mapCharAttr.MarkCritRate
    stAttr.SummonCritRate = mapCharAttr.SummonCritRate
    stAttr.ProjectileCritRate = mapCharAttr.ProjectileCritRate
    stAttr.OtherCritRate = mapCharAttr.OtherCritRate
    stAttr.NormalCritPower = mapCharAttr.NormalCritPower
    stAttr.SkillCritPower = mapCharAttr.SkillCritPower
    stAttr.UltraCritPower = mapCharAttr.UltraCritPower
    stAttr.MarkCritPower = mapCharAttr.MarkCritPower
    stAttr.SummonCritPower = mapCharAttr.SummonCritPower
    stAttr.ProjectileCritPower = mapCharAttr.ProjectileCritPower
    stAttr.OtherCritPower = mapCharAttr.OtherCritPower
    stAttr.ToughnessDamageAdjust = mapCharAttr.ToughnessDamageAdjust
    stAttr.EnergyConvRatio = mapCharAttr.EnergyConvRatio
    stAttr.EnergyEfficiency = mapCharAttr.EnergyEfficiency
    stAttr.initHp = 0
    do return 0 end
    -- DECOMPILER ERROR: 5 unprocessed JMP targets
  end
end

PlayerCharData.CalCharacterTrialAttrBattle = function(self, nTrialId, stAttr, bMainChar, tbDiscId, nBuildId)
  -- function num : 0_83 , upvalues : _ENV
  local mapChar = (self._mapTrialChar)[nTrialId]
  if mapChar == nil then
    printError("没有该角色数据" .. nTrialId)
    return 0
  end
  local nCharId = mapChar.nId
  local nLevel = mapChar.nLevel
  local nAdvance = mapChar.nAdvance
  local nAttrId = (UTILS.GetCharacterAttributeId)(nCharId, nAdvance, nLevel)
  local mapCharAttrCfg = (ConfigTable.GetData_Attribute)(tostring(nAttrId))
  if mapCharAttrCfg == nil then
    printError("属性配置不存在:" .. nAttrId)
    return {}
  end
  local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
  if mapCharCfg == nil then
    printError("角色配置不存在:" .. nCharId)
    return {}
  end
  for _,v in ipairs(AllEnum.AttachAttr) do
    if v.bPlayer and mapCharCfg[v.sKey] ~= nil then
      mapCharAttrCfg[v.sKey] = mapCharCfg[v.sKey]
    end
  end
  local mapDiscAttr = {}
  for _,v in ipairs(AllEnum.AttachAttr) do
    mapDiscAttr[v.sKey] = {Key = v.sKey, Value = 0, CfgValue = 0}
  end
  if tbDiscId ~= nil then
    for _,nDiscId in ipairs(tbDiscId) do
      local mapDisc = (PlayerData.Disc):GetTrialDiscById(nDiscId)
      for _,v in ipairs(AllEnum.AttachAttr) do
        -- DECOMPILER ERROR at PC107: Confused about usage of register: R25 in 'UnsetPending'

        (mapDiscAttr[v.sKey]).CfgValue = (mapDiscAttr[v.sKey]).CfgValue + ((mapDisc.mapAttrBase)[v.sKey]).CfgValue
      end
    end
  end
  do
    local mapBuildAttr = {}
    if nBuildId ~= nil then
      mapBuildAttr = (PlayerData.Build):GetBuildAttrBase(nBuildId, true)
    else
      for _,v in ipairs(AllEnum.AttachAttr) do
        mapBuildAttr[v.sKey] = {Key = v.sKey, Value = 0, CfgValue = 0}
      end
    end
    do
      local tbSkillLevel = self:GetTrialCharSkillAddedLevel(nTrialId)
      if bMainChar == true then
        (table.remove)(tbSkillLevel, 3)
      else
        ;
        (table.remove)(tbSkillLevel, 2)
      end
      local mapCharAttr = {}
      for _,v in ipairs(AllEnum.AttachAttr) do
        mapCharAttr[v.sKey] = mapCharAttrCfg[v.sKey] + (mapDiscAttr[v.sKey]).CfgValue + (mapBuildAttr[v.sKey]).CfgValue
      end
      local tbTalent = (PlayerData.Talent):GetTrialFateTalent(nTrialId)
      stAttr.actorLevel = nLevel
      stAttr.breakCount = mapChar.nAdvance
      stAttr.activeTalentInfos = tbTalent
      stAttr.Atk = mapCharAttr.Atk
      stAttr.Hp = mapCharAttr.Hp
      stAttr.Def = mapCharAttr.Def
      stAttr.CritRate = mapCharAttr.CritRate
      stAttr.CritResistance = mapCharAttr.CritResistance
      stAttr.CritPower = mapCharAttr.CritPower
      stAttr.HitRate = mapCharAttr.HitRate
      stAttr.Evd = mapCharAttr.Evd
      stAttr.DefPierce = mapCharAttr.DefPierce
      stAttr.WEP = mapCharAttr.WEP
      stAttr.FEP = mapCharAttr.FEP
      stAttr.SEP = mapCharAttr.SEP
      stAttr.AEP = mapCharAttr.AEP
      stAttr.LEP = mapCharAttr.LEP
      stAttr.DEP = mapCharAttr.DEP
      stAttr.WEE = mapCharAttr.WEE
      stAttr.FEE = mapCharAttr.FEE
      stAttr.SEE = mapCharAttr.SEE
      stAttr.AEE = mapCharAttr.AEE
      stAttr.LEE = mapCharAttr.LEE
      stAttr.DEE = mapCharAttr.DEE
      stAttr.WER = mapCharAttr.WER
      stAttr.FER = mapCharAttr.FER
      stAttr.SER = mapCharAttr.SER
      stAttr.AER = mapCharAttr.AER
      stAttr.LER = mapCharAttr.LER
      stAttr.DER = mapCharAttr.DER
      stAttr.WEI = mapCharAttr.WEI
      stAttr.FEI = mapCharAttr.FEI
      stAttr.SEI = mapCharAttr.SEI
      stAttr.AEI = mapCharAttr.AEI
      stAttr.LEI = mapCharAttr.LEI
      stAttr.DEI = mapCharAttr.DEI
      stAttr.DefIgnore = mapCharAttr.DefIgnore
      stAttr.ShieldBonus = mapCharAttr.ShieldBonus
      stAttr.IncomingShieldBonus = mapCharAttr.IncomingShieldBonus
      stAttr.SkillLevel = tbSkillLevel
      stAttr.skinId = self:GetCharSkinId(nCharId)
      stAttr.attrId = tostring(nAttrId)
      stAttr.Suppress = mapCharAttr.Suppress
      stAttr.NormalDmgRatio = mapCharAttr.NORMALDMG
      stAttr.SkillDmgRatio = mapCharAttr.SKILLDMG
      stAttr.UltraDmgRatio = mapCharAttr.ULTRADMG
      stAttr.OtherDmgRatio = mapCharAttr.OTHERDMG
      stAttr.RcdNormalDmgRatio = mapCharAttr.RCDNORMALDMG
      stAttr.RcdSkillDmgRatio = mapCharAttr.RCDSKILLDMG
      stAttr.RcdUltraDmgRatio = mapCharAttr.RCDULTRADMG
      stAttr.RcdOtherDmgRatio = mapCharAttr.RCDOTHERDMG
      stAttr.MarkDmgRatio = mapCharAttr.MARKDMG
      stAttr.SummonDmgRatio = mapCharAttr.SUMMONDMG
      stAttr.RcdSummonDmgRatio = mapCharAttr.RCDSUMMONDMG
      stAttr.ProjectileDmgRatio = mapCharAttr.PROJECTILEDMG
      stAttr.RcdProjectileDmgRatio = mapCharAttr.RCDPROJECTILEDMG
      stAttr.GENDMG = mapCharAttr.GENDMG
      stAttr.DMGPLUS = mapCharAttr.DMGPLUS
      stAttr.FINALDMG = mapCharAttr.FINALDMG
      stAttr.FINALDMGPLUS = mapCharAttr.FINALDMGPLUS
      stAttr.WEERCD = mapCharAttr.WEERCD
      stAttr.FEERCD = mapCharAttr.FEERCD
      stAttr.SEERCD = mapCharAttr.SEERCD
      stAttr.AEERCD = mapCharAttr.AEERCD
      stAttr.LEERCD = mapCharAttr.LEERCD
      stAttr.DEERCD = mapCharAttr.DEERCD
      stAttr.GENDMGRCD = mapCharAttr.GENDMGRCD
      stAttr.DMGPLUSRCD = mapCharAttr.DMGPLUSRCD
      stAttr.NormalCritRate = mapCharAttr.NormalCritRate
      stAttr.SkillCritRate = mapCharAttr.SkillCritRate
      stAttr.UltraCritRate = mapCharAttr.UltraCritRate
      stAttr.MarkCritRate = mapCharAttr.MarkCritRate
      stAttr.SummonCritRate = mapCharAttr.SummonCritRate
      stAttr.ProjectileCritRate = mapCharAttr.ProjectileCritRate
      stAttr.OtherCritRate = mapCharAttr.OtherCritRate
      stAttr.NormalCritPower = mapCharAttr.NormalCritPower
      stAttr.SkillCritPower = mapCharAttr.SkillCritPower
      stAttr.UltraCritPower = mapCharAttr.UltraCritPower
      stAttr.MarkCritPower = mapCharAttr.MarkCritPower
      stAttr.SummonCritPower = mapCharAttr.SummonCritPower
      stAttr.ProjectileCritPower = mapCharAttr.ProjectileCritPower
      stAttr.OtherCritPower = mapCharAttr.OtherCritPower
      stAttr.ToughnessDamageAdjust = mapCharAttr.ToughnessDamageAdjust
      stAttr.EnergyConvRatio = mapCharAttr.EnergyConvRatio
      stAttr.EnergyEfficiency = mapCharAttr.EnergyEfficiency
      stAttr.initHp = 0
      return 0
    end
  end
end

PlayerCharData.UpdateAllCharRecordInfoRedDot = function(self)
  -- function num : 0_84 , upvalues : _ENV
  for charId,v in pairs(self._mapChar) do
    self:UpdateCharRecordInfoReddot(charId, false)
  end
end

PlayerCharData.UpdateCharRecordReddot = function(self, nCharId, bReset, lastLevel, curLevel)
  -- function num : 0_85 , upvalues : LocalData, _ENV
  local bNew = false
  if lastLevel ~= nil and curLevel ~= nil and lastLevel < curLevel then
    bNew = true
    ;
    (LocalData.SetPlayerLocalData)("CharacterArchive" .. nCharId, lastLevel)
  else
    bNew = not bReset
    if bNew then
      lastLevel = (LocalData.GetPlayerLocalData)("CharacterArchive" .. nCharId)
      local mapData = self:GetCharAffinityData(nCharId)
      curLevel = mapData ~= nil and mapData.Level or nil
    else
      do
        ;
        (LocalData.DelPlayerLocalData)("CharacterArchive" .. nCharId)
        local foreachCharacterArchive = function(mapData)
    -- function num : 0_85_0 , upvalues : nCharId, bNew, _ENV, lastLevel, curLevel
    if mapData.CharacterId == nCharId then
      if not bNew then
        (RedDotManager.SetValid)(RedDotDefine.Role_Record_Info_Item, {nCharId, mapData.Id}, false)
      else
        if lastLevel ~= nil and curLevel ~= nil and lastLevel < curLevel and mapData.UnlockAffinityLevel > 0 and lastLevel < mapData.UnlockAffinityLevel and mapData.UnlockAffinityLevel <= curLevel then
          (RedDotManager.SetValid)(RedDotDefine.Role_Record_Info_Item, {nCharId, mapData.Id}, true)
        end
      end
    end
  end

        ForEachTableLine(DataTable.CharacterArchive, foreachCharacterArchive)
      end
    end
  end
end

PlayerCharData.UpdateCharVoiceReddot = function(self, nCharId, bReset, lastLevel, curLevel, nPlotId)
  -- function num : 0_86 , upvalues : LocalData, _ENV
  local bNew = false
  if lastLevel ~= nil and curLevel ~= nil and lastLevel < curLevel then
    bNew = true
    ;
    (LocalData.SetPlayerLocalData)("CharacterArchiveVoice" .. nCharId, lastLevel)
  else
    bNew = not bReset
    if bNew then
      lastLevel = (LocalData.GetPlayerLocalData)("CharacterArchiveVoice" .. nCharId)
      local mapData = self:GetCharAffinityData(nCharId)
      curLevel = mapData ~= nil and mapData.Level or nil
    else
      do
        ;
        (LocalData.DelPlayerLocalData)("CharacterArchiveVoice" .. nCharId)
        local foreachCharacterArchiveVoice = function(mapData)
    -- function num : 0_86_0 , upvalues : nCharId, bNew, _ENV, lastLevel, curLevel, nPlotId
    if mapData.CharacterId == nCharId then
      if not bNew then
        (RedDotManager.SetValid)(RedDotDefine.Role_Record_Voice_Item, {nCharId, mapData.Id}, false)
      else
        if lastLevel ~= nil and curLevel ~= nil and lastLevel < curLevel and mapData.UnlockAffinityLevel > 0 and lastLevel < mapData.UnlockAffinityLevel and mapData.UnlockAffinityLevel <= curLevel then
          (RedDotManager.SetValid)(RedDotDefine.Role_Record_Voice_Item, {nCharId, mapData.Id}, true)
        end
        if nPlotId ~= nil and nPlotId == mapData.UnlockPlot then
          (RedDotManager.SetValid)(RedDotDefine.Role_Record_Voice_Item, {nCharId, mapData.Id}, true)
        end
      end
    end
  end

        ForEachTableLine(DataTable.CharacterArchiveVoice, foreachCharacterArchiveVoice)
      end
    end
  end
end

PlayerCharData.UpdateCharPlotReddot = function(self, nCharId)
  -- function num : 0_87 , upvalues : _ENV
  local tbPlot = (CacheTable.GetData)("_Plot", nCharId)
  if tbPlot ~= nil then
    for _,v in ipairs(tbPlot) do
      local bValid = false
      local bLocked, txt = self:IsPlotUnlock(v.Id, nCharId)
      if not bLocked then
        bValid = not self:IsCharPlotFinish(nCharId, v.Id)
      end
      ;
      (RedDotManager.SetValid)(RedDotDefine.Role_AffinityPlotItem, {nCharId, v.Id}, bValid)
    end
  end
end

PlayerCharData.UpdateCharArchiveRewardRedDot = function(self, nCharId)
  -- function num : 0_88 , upvalues : _ENV
  local nCurFavorLevel = (self:GetCharAffinityData(nCharId)).Level
  local foreachCharacterArchive = function(mapData)
    -- function num : 0_88_0 , upvalues : nCharId, nCurFavorLevel, _ENV, self
    if mapData.CharacterId == nCharId then
      local bReward = false
      if mapData.UnlockAffinityLevel <= nCurFavorLevel and mapData.ArchType == (GameEnum.ArchType).SpecialType and mapData.ArchReward ~= 0 then
        bReward = not self:CheckCharArchiveReward(nCharId, mapData.Id)
      end
      ;
      (RedDotManager.SetValid)(RedDotDefine.Role_RecordRewardItem, {nCharId, mapData.Id}, bReward)
    end
  end

  ForEachTableLine(DataTable.CharacterArchive, foreachCharacterArchive)
end

PlayerCharData.UpdateCharRecordInfoReddot = function(self, nCharId, bReset, lastLevel, curLevel)
  -- function num : 0_89
  self:UpdateCharPlotReddot(nCharId)
  self:UpdateCharRecordReddot(nCharId, bReset, lastLevel, curLevel)
  self:UpdateCharVoiceReddot(nCharId, bReset, lastLevel, curLevel)
  self:UpdateCharArchiveRewardRedDot(nCharId)
end

PlayerCharData.InitCharArchiveContentUpdateRedDot = function(self, nCharId)
  -- function num : 0_90 , upvalues : _ENV
  local tbContentList = (self._tbArchiveUpdate)[nCharId]
  if tbContentList ~= nil then
    for nId,v in pairs(tbContentList) do
      local bUpdate, nValue = self:CheckCharArchiveContentUpdate(nCharId, nId)
      -- DECOMPILER ERROR at PC21: Confused about usage of register: R10 in 'UnsetPending'

      ;
      (((self._tbArchiveUpdate)[nCharId])[nId]).nValue = bUpdate and -1 or nValue
    end
  end
  do
    local tbBaseContentList = (self._tbArchiveBaseUpdate)[nCharId]
    if tbBaseContentList ~= nil then
      for nId,v in pairs(tbBaseContentList) do
        local bUpdate, nValue = self:CheckCharArchiveBaseContentUpdate(nCharId, nId)
        -- DECOMPILER ERROR at PC45: Confused about usage of register: R11 in 'UnsetPending'

        ;
        (((self._tbArchiveBaseUpdate)[nCharId])[nId]).nValue = bUpdate and -1 or nValue
      end
    end
  end
end

PlayerCharData.UpdateCharArchiveContentUpdateRedDot = function(self, nCharId, nIndex, nNewValue, nLastValue)
  -- function num : 0_91 , upvalues : _ENV
  local affinityData = (PlayerData.Char):GetCharAffinityData(nCharId)
  if affinityData == nil then
    return 
  end
  local nCurFavourLevel = affinityData.Level
  local tbContentList = (self._tbArchiveUpdate)[nCharId]
  if tbContentList ~= nil then
    for nId,v in pairs(tbContentList) do
      if v.nValue ~= -1 then
        local bUpdate = false
        if nLastValue >= v.UpdateAff1 or v.UpdateAff1 > nNewValue then
          bUpdate = nIndex ~= 1 or v.UpdateAff1 <= 0 or v.nValue & 1 ~= 0
          if v.UpdatePlot1 ~= nNewValue then
            do
              bUpdate = nIndex ~= 2 or v.UpdatePlot1 <= 0 or v.nValue >> 1 & 1 ~= 0
              if nIndex == 3 and v.UpdateStory1 > 0 and v.nValue >> 2 & 1 == 0 then
                bUpdate = (PlayerData.Avg):IsStoryReaded(v.UpdateStory1)
              end
              -- DECOMPILER ERROR at PC80: Confused about usage of register: R14 in 'UnsetPending'

              if bUpdate then
                (((self._tbArchiveUpdate)[nCharId])[nId]).nValue = 1 << nIndex - 1 | v.nValue
              end
              local mapCfg = (ConfigTable.GetData)("CharacterArchive", nId)
              local bUnlock = false
              if mapCfg.UnlockAffinityLevel > nCurFavourLevel then
                do
                  bUnlock = mapCfg == nil
                  ;
                  (RedDotManager.SetValid)(RedDotDefine.Role_Record_InfoUpdate_Item, {nCharId, nId}, ((((self._tbArchiveUpdate)[nCharId])[nId]).nValue == 7 and bUnlock))
                  -- DECOMPILER ERROR at PC113: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC113: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC113: LeaveBlock: unexpected jumping out DO_STMT

                  -- DECOMPILER ERROR at PC113: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC113: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC113: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC113: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC113: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC113: LeaveBlock: unexpected jumping out IF_STMT

                end
              end
            end
          end
        end
      end
    end
  end
  local tbBaseContentList = (self._tbArchiveBaseUpdate)[nCharId]
  do
    if tbBaseContentList ~= nil then
      local bBaseInfoUpdate = false
      for nId,v in pairs(tbBaseContentList) do
        if v.nValue ~= -1 then
          local bUpdate = false
          if nLastValue >= v.UpdateAff1 or v.UpdateAff1 > nNewValue then
            bUpdate = nIndex ~= 1 or v.UpdateAff1 <= 0 or v.nValue & 1 ~= 0
            if v.UpdatePlot1 ~= nNewValue then
              do
                do
                  bUpdate = nIndex ~= 2 or v.UpdatePlot1 <= 0 or v.nValue >> 1 & 1 ~= 0
                  if nIndex == 3 and v.UpdateStory1 > 0 and v.nValue >> 2 & 1 == 0 then
                    bUpdate = (PlayerData.Avg):IsStoryReaded(v.UpdateStory1)
                  end
                  if not bBaseInfoUpdate then
                    bBaseInfoUpdate = bUpdate
                  end
                  -- DECOMPILER ERROR at PC190: Confused about usage of register: R16 in 'UnsetPending'

                  if bUpdate then
                    (((self._tbArchiveBaseUpdate)[nCharId])[nId]).nValue = 1 << nIndex - 1 | v.nValue
                  end
                  ;
                  (RedDotManager.SetValid)(RedDotDefine.Role_Record_BaseInfoUpdate_Item, nCharId, bBaseInfoUpdate)
                  -- DECOMPILER ERROR at PC198: LeaveBlock: unexpected jumping out DO_STMT

                  -- DECOMPILER ERROR at PC198: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC198: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC198: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC198: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC198: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC198: LeaveBlock: unexpected jumping out IF_STMT

                end
              end
            end
          end
        end
      end
    end
    -- DECOMPILER ERROR: 22 unprocessed JMP targets
  end
end

PlayerCharData.StoryPass = function(self, tbStoryId)
  -- function num : 0_92 , upvalues : _ENV
  if #tbStoryId > 0 then
    for nCharId,v in pairs(self._tbArchiveUpdate) do
      for _,nStoryId in ipairs(tbStoryId) do
        self:UpdateCharArchiveContentUpdateRedDot(nCharId, 3, nStoryId)
      end
    end
  end
end

PlayerCharData.ResetArchiveContentUpdateRedDot = function(self, nCharId)
  -- function num : 0_93 , upvalues : _ENV
  local tbContentList = (self._tbArchiveUpdate)[nCharId]
  if tbContentList ~= nil then
    for nId,v in pairs(tbContentList) do
      if v.nValue == 7 then
        v.nValue = -1
        ;
        (RedDotManager.SetValid)(RedDotDefine.Role_Record_InfoUpdate_Item, {nCharId, nId}, false)
      end
      ;
      (RedDotManager.SetValid)(RedDotDefine.Role_Record_BaseInfoUpdate_Item, nCharId, false)
    end
  end
end

PlayerCharData.GetCharPanelSkillDescType = function(self, ...)
  -- function num : 0_94
  return self.bCharPanel_IsSimpleDesc
end

PlayerCharData.SetCharPanelSkillDescType = function(self, bIsSimple)
  -- function num : 0_95 , upvalues : LocalData
  self.bCharPanel_IsSimpleDesc = bIsSimple
  ;
  (LocalData.SetLocalData)("Char_", "CharPanel_IsSimpleDesc", self.bCharPanel_IsSimpleDesc)
end

PlayerCharData.GetTipsPanelSkillDescType = function(self, ...)
  -- function num : 0_96
  return self.bTipsPanel_IsSimpleDesc
end

PlayerCharData.SetTipsPanelSkillDescType = function(self, bIsSimple)
  -- function num : 0_97 , upvalues : LocalData
  self.bTipsPanel_IsSimpleDesc = bIsSimple
  ;
  (LocalData.SetLocalData)("Char_", "TipsPanel_IsSimpleDesc", self.bTipsPanel_IsSimpleDesc)
end

local tbSortNameTextCfg = {"CharList_Sort_Toggle_Level", "CharList_Sort_Toggle_Rare", "CharList_Sort_Toggle_Skill", "CharList_Sort_Toggle_Affinity", "CharList_Sort_Toggle_Time"}
local tbSortType = {[1] = (AllEnum.SortType).Level, [2] = (AllEnum.SortType).Rarity, [3] = (AllEnum.SortType).Skill, [4] = (AllEnum.SortType).Affinity, [5] = (AllEnum.SortType).Time, [100] = (AllEnum.SortType).ElementType, [101] = (AllEnum.SortType).Id}
local tbDefaultSortField = {"Level", "Rare", "EET", "nId"}
PlayerCharData.GetCharSortNameTextCfg = function(self)
  -- function num : 0_98 , upvalues : tbSortNameTextCfg
  return tbSortNameTextCfg
end

PlayerCharData.GetCharSortType = function(self)
  -- function num : 0_99 , upvalues : tbSortType
  return tbSortType
end

PlayerCharData.GetCharSortField = function(self)
  -- function num : 0_100 , upvalues : tbDefaultSortField
  return tbDefaultSortField
end

return PlayerCharData

