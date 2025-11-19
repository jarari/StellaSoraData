local ConfigData = require("GameCore.Data.ConfigData")
local DiscData = require("GameCore.Data.DataClass.DiscData")
local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
local PlayerDiscData = class("PlayerDiscData")
PlayerDiscData.Init = function(self)
  -- function num : 0_0
  self._mapDisc = {}
  self.nMaxBreakLimitMat = 5
  self:ProcessTableData()
end

PlayerDiscData.ProcessTableData = function(self)
  -- function num : 0_1
  self:ProcessExpTable()
  self:ProcessConfigTable()
  self:ProcessDiscTable()
end

PlayerDiscData.ProcessExpTable = function(self)
  -- function num : 0_2 , upvalues : _ENV
  self.tbItemExp = {}
  local foreachDiscItemExp = function(mapData)
    -- function num : 0_2_0 , upvalues : _ENV, self
    (table.insert)(self.tbItemExp, {nItemId = mapData.ItemId, nExpValue = mapData.Exp})
  end

  ForEachTableLine(DataTable.DiscItemExp, foreachDiscItemExp)
  local sort = function(a, b)
    -- function num : 0_2_1
    do return b.nExpValue < a.nExpValue end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end

  ;
  (table.sort)(self.tbItemExp, sort)
end

PlayerDiscData.ProcessConfigTable = function(self)
  -- function num : 0_3 , upvalues : _ENV
  self.tbExpPerGold = {}
  local tbGold = (ConfigTable.GetConfigNumberArray)("DiscStrengthenGoldFactor")
  if type(tbGold) == "table" then
    for nRarity,sValue in ipairs(tbGold) do
      -- DECOMPILER ERROR at PC17: Confused about usage of register: R7 in 'UnsetPending'

      (self.tbExpPerGold)[nRarity] = sValue / 1000
    end
  end
  do
    self.tbMaxStar = {}
    local tbBreak = (ConfigTable.GetConfigNumberArray)("DiscRarityLimitBreakMax")
    if type(tbBreak) == "table" then
      for nRarity,sValue in ipairs(tbBreak) do
        -- DECOMPILER ERROR at PC36: Confused about usage of register: R8 in 'UnsetPending'

        (self.tbMaxStar)[nRarity] = sValue
      end
    end
  end
end

PlayerDiscData.ProcessDiscTable = function(self)
  -- function num : 0_4 , upvalues : _ENV
  self.ItemToDisc = {}
  local func_ForEach = function(mapData)
    -- function num : 0_4_0 , upvalues : self
    -- DECOMPILER ERROR at PC3: Confused about usage of register: R1 in 'UnsetPending'

    (self.ItemToDisc)[mapData.TransformItemId] = mapData.Id
  end

  ForEachTableLine(DataTable.Disc, func_ForEach)
  local func_ForEach_main = function(mapData)
    -- function num : 0_4_1 , upvalues : _ENV
    (CacheTable.SetField)("_MainSkill", mapData.GroupId, mapData.Level, mapData)
  end

  ForEachTableLine(DataTable.MainSkill, func_ForEach_main)
  local func_ForEach_Note = function(mapData)
    -- function num : 0_4_2 , upvalues : _ENV
    (CacheTable.SetField)("_SubNoteSkillPromoteGroup", mapData.GroupId, mapData.Phase, mapData)
  end

  ForEachTableLine(DataTable.SubNoteSkillPromoteGroup, func_ForEach_Note)
  local func_ForEach_Secondary = function(mapData)
    -- function num : 0_4_3 , upvalues : _ENV
    (CacheTable.SetField)("_SecondarySkill", mapData.GroupId, mapData.Level, mapData)
  end

  ForEachTableLine(DataTable.SecondarySkill, func_ForEach_Secondary)
end

PlayerDiscData.GetAllDisc = function(self)
  -- function num : 0_5 , upvalues : _ENV
  local discList = {}
  for _,discData in pairs(self._mapDisc) do
    (table.insert)(discList, discData)
  end
  return discList
end

PlayerDiscData.GetDiscById = function(self, nId)
  -- function num : 0_6
  if not nId or nId == 0 then
    return 
  end
  if (self._mapDisc)[nId] == nil then
    return (self._mapDisc)[nId]
  end
end

PlayerDiscData.GetDiscSkillScore = function(self, nId, tbNote)
  -- function num : 0_7 , upvalues : _ENV
  local mapDisc = (self._mapDisc)[nId]
  local nScore = 0
  for i = 1, 2 do
    if (mapDisc.tbSubSkillGroupId)[i] then
      local tbGroup = (CacheTable.GetData)("_SecondarySkill", (mapDisc.tbSubSkillGroupId)[i])
      if tbGroup then
        local nMaxLayer = #tbGroup
        for j = nMaxLayer, 1, -1 do
          if tbGroup[j] then
            local bActive = mapDisc:CheckSubSkillActive(tbNote, tbGroup[j])
            if bActive then
              nScore = nScore + (tbGroup[j]).Score
              break
            end
          end
        end
      end
    end
  end
  return nScore
end

PlayerDiscData.GetDiscSkillByNote = function(self, tbDisc, tbHasNote, nNeedNote)
  -- function num : 0_8 , upvalues : _ENV
  local tbSkill = {}
  local sNote = tostring(nNeedNote)
  for _,nDiscId in pairs(tbDisc) do
    local mapData = self:GetDiscById(nDiscId)
    if mapData == nil then
      return {}
    end
    for _,nSubSkillGroupId in pairs(mapData.tbSubSkillGroupId) do
      local tbGroup = (CacheTable.GetData)("_SecondarySkill", nSubSkillGroupId)
      if tbGroup then
        local nCurLayer = 0
        local nMaxLayer = #tbGroup
        for i = nMaxLayer, 1, -1 do
          if tbGroup[i] then
            local bActive = mapData:CheckSubSkillActive(tbHasNote, tbGroup[i])
            if bActive then
              nCurLayer = i
              break
            end
          end
        end
        do
          if nCurLayer ~= nMaxLayer or not nMaxLayer then
            local nNextLayer = nCurLayer + 1
          end
          if tbGroup[nNextLayer] then
            local nSubSkillId = (tbGroup[nNextLayer]).Id
            local tbActiveNote = decodeJson((tbGroup[nNextLayer]).NeedSubNoteSkills)
            if tbActiveNote[sNote] then
              local tbNote = {}
              for k,v in pairs(tbActiveNote) do
                local nNoteId = tonumber(k)
                local nNoteCount = tonumber(v)
                if nNoteId then
                  tbNote[nNoteId] = nNoteCount
                end
              end
              ;
              (table.insert)(tbSkill, {nId = nSubSkillId, tbNote = tbNote})
            end
          end
          do
            -- DECOMPILER ERROR at PC84: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC84: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC84: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
  return tbSkill
end

PlayerDiscData.GetBGMDisc = function(self)
  -- function num : 0_9
  return self.nBGMDisc or 0
end

PlayerDiscData.CheckDiscL2D = function(self, nId)
  -- function num : 0_10
  local discData = (self._mapDisc)[nId]
  if not discData then
    return false
  end
  return discData.bUnlockL2D
end

PlayerDiscData.CalcDiscEffect = function(self, nId)
  -- function num : 0_11 , upvalues : _ENV
  local discData = (self._mapDisc)[nId]
  local tbEft = {}
  if discData ~= nil then
    for _,mapEft in ipairs(discData:GetSkillEffect()) do
      (table.insert)(tbEft, mapEft)
    end
  end
  do
    return tbEft
  end
end

PlayerDiscData.CalcDiscEffectInBuild = function(self, nId, tbSecondarySkill)
  -- function num : 0_12 , upvalues : _ENV
  local discData = (self._mapDisc)[nId]
  local tbEffectId = {}
  if discData == nil then
    return tbEffectId
  end
  local add = function(tbEfId)
    -- function num : 0_12_0 , upvalues : _ENV, tbEffectId
    if not tbEfId then
      return 
    end
    for _,nEfId in pairs(tbEfId) do
      if type(nEfId) == "number" and nEfId > 0 then
        (table.insert)(tbEffectId, {nEfId, 0})
      end
    end
  end

  local mapMainCfg = (ConfigTable.GetData)("MainSkill", discData.nMainSkillId)
  if mapMainCfg then
    add(mapMainCfg.EffectId)
  end
  for _,v in ipairs(tbSecondarySkill) do
    local mapSubCfg = (ConfigTable.GetData)("SecondarySkill", v)
    if mapSubCfg and (table.indexof)(discData.tbSubSkillGroupId, mapSubCfg.GroupId) > 0 then
      add(mapSubCfg.EffectId)
    end
  end
  return tbEffectId
end

PlayerDiscData.CalcDiscInfoInBuild = function(self, nId, tbSecondarySkill)
  -- function num : 0_13 , upvalues : _ENV
  local discData = (self._mapDisc)[nId]
  local discInfo = (CS.Lua2CSharpInfo_DiscInfo)()
  if discData == nil then
    return discInfo
  end
  local tbSkillInfo = {}
  for _,v in ipairs(tbSecondarySkill) do
    local mapSubCfg = (ConfigTable.GetData)("SecondarySkill", v, true)
    if mapSubCfg and (table.indexof)(discData.tbSubSkillGroupId, mapSubCfg.GroupId) > 0 then
      local skillInfo = (CS.Lua2CSharpInfo_DiscSkillInfo)()
      skillInfo.skillId = v
      skillInfo.skillLevel = mapSubCfg.Level
      ;
      (table.insert)(tbSkillInfo, skillInfo)
    end
  end
  local mapMainCfg = (ConfigTable.GetData)("MainSkill", discData.nMainSkillId, true)
  do
    if mapMainCfg then
      local skillInfo = (CS.Lua2CSharpInfo_DiscSkillInfo)()
      skillInfo.skillId = discData.nMainSkillId
      skillInfo.skillLevel = 1
      ;
      (table.insert)(tbSkillInfo, skillInfo)
    end
    discInfo.discId = nId
    discInfo.discScript = discData.sSkillScript
    discInfo.skillInfos = tbSkillInfo
    discInfo.discLevel = discData.nLevel
    return discInfo
  end
end

PlayerDiscData.GenerateLocalDiscData = function(self, configId, nExp, nLevel, nPhase, nStar)
  -- function num : 0_14 , upvalues : _ENV, DiscData
  if not configId then
    printError("GenerateLocalDiscData Failed!")
    return 
  end
  local mapDisc = {}
  mapDisc.Id = configId
  mapDisc.Exp = nExp or 0
  mapDisc.Level = nLevel or 1
  mapDisc.Phase = nPhase or 0
  mapDisc.Star = nStar or 0
  mapDisc.Read = false
  local discData = (DiscData.new)(mapDisc)
  return discData
end

PlayerDiscData.GetAttrBase = function(self, nGroupId, nPhase, nTargetLv, nExtraGroupId, nStar)
  -- function num : 0_15 , upvalues : _ENV, ConfigData
  local mapExtra = nil
  do
    if nStar > 0 and nExtraGroupId > 0 then
      local nExtraId = (UTILS.GetDiscExtraAttributeId)(nExtraGroupId, nStar)
      mapExtra = (ConfigTable.GetData)("DiscExtraAttribute", tostring(nExtraId))
    end
    local nAttrId = (UTILS.GetDiscAttributeId)(nGroupId, nPhase, nTargetLv)
    local mapAttribute = (ConfigTable.GetData_Attribute)(tostring(nAttrId))
    local mapAttr = {}
    if mapAttribute then
      for _,v in ipairs(AllEnum.AttachAttr) do
        local nParamValue = mapAttribute[v.sKey] or 0
        mapAttr[v.sKey] = {Key = v.sKey, Value = v.bPercent and nParamValue * ConfigData.IntFloatPrecision * 100 or nParamValue, CfgValue = mapAttribute[v.sKey] or 0}
        if not mapExtra[v.sKey] then
          local nExtraParamValue = not mapExtra or 0
        end
        local nExtraValue = v.bPercent and nExtraParamValue * ConfigData.IntFloatPrecision * 100 or nExtraParamValue
        -- DECOMPILER ERROR at PC86: Confused about usage of register: R18 in 'UnsetPending'

        ;
        (mapAttr[v.sKey]).Value = (mapAttr[v.sKey]).Value + nExtraValue
        -- DECOMPILER ERROR at PC93: Confused about usage of register: R18 in 'UnsetPending'

        ;
        (mapAttr[v.sKey]).CfgValue = (mapAttr[v.sKey]).CfgValue + nExtraParamValue
      end
    end
    do
      return mapAttr
    end
  end
end

PlayerDiscData.GetDiscMaxStar = function(self, nRarity)
  -- function num : 0_16
  return (self.tbMaxStar)[nRarity]
end

PlayerDiscData.GetBreakLimitMat = function(self, nId)
  -- function num : 0_17 , upvalues : _ENV
  local discData = (self._mapDisc)[nId]
  local nMatId = discData.nTransformItemId
  local nCount = (PlayerData.Item):GetItemCountByID(nMatId)
  return nMatId, nCount
end

PlayerDiscData.GetAllBreakLimitMat = function(self)
  -- function num : 0_18 , upvalues : _ENV
  local tbMat = {}
  for nId,discData in pairs(self._mapDisc) do
    local nMatId, nCount = self:GetBreakLimitMat(nId)
    if discData.nMaxStar - discData.nStar < nCount then
      nCount = discData.nMaxStar - discData.nStar
    end
    if nCount > 0 then
      (table.insert)(tbMat, {nTid = nMatId, nCount = nCount})
    end
  end
  ;
  (table.sort)(tbMat, function(a, b)
    -- function num : 0_18_0 , upvalues : _ENV
    local rarityA = ((ConfigTable.GetData_Item)(a.nTid)).Rarity
    local rarityB = ((ConfigTable.GetData_Item)(b.nTid)).Rarity
    if rarityA >= rarityB then
      do return rarityA == rarityB end
      if b.nCount >= a.nCount then
        do return a.nCount == b.nCount end
        do return a.nTid < b.nTid end
        -- DECOMPILER ERROR: 6 unprocessed JMP targets
      end
    end
  end
)
  return tbMat
end

PlayerDiscData.GetIndexOfNewBreakLimitMat = function(self, tbMat)
  -- function num : 0_19 , upvalues : _ENV
  local nCurCount = 0
  for _,_ in pairs(tbMat) do
    nCurCount = nCurCount + 1
  end
  if nCurCount == self.nMaxBreakLimitMat then
    return 0
  end
  local nIndex = 0
  for _,v in pairs(tbMat) do
    if nIndex < v.nAddIndex then
      nIndex = v.nAddIndex
    end
  end
  return nIndex + 1
end

PlayerDiscData.GetMaxLv = function(self, nRarity, nCurPhase)
  -- function num : 0_20 , upvalues : _ENV
  local nMaxLv = 1
  local foreachDiscPromoteLimit = function(mapData)
    -- function num : 0_20_0 , upvalues : nRarity, _ENV, nCurPhase, nMaxLv
    if mapData.Rarity == nRarity and tonumber(mapData.Phase) == nCurPhase then
      nMaxLv = mapData.MaxLevel
    end
  end

  ForEachTableLine(DataTable.DiscPromoteLimit, foreachDiscPromoteLimit)
  return tonumber(nMaxLv)
end

PlayerDiscData.GetUpgradeNote = function(self, nId)
  -- function num : 0_21 , upvalues : _ENV
  local tbShowNote = {}
  local mapDisc = (self._mapDisc)[nId]
  local mapGroup = (CacheTable.GetData)("_SubNoteSkillPromoteGroup", mapDisc.nSubNoteSkillGroupId)
  if not mapGroup then
    return tbShowNote
  end
  local nNextPhase = mapDisc.nPhase + 1
  local mapCfg = nil
  while 1 do
    if type(nNextPhase) == "number" and nNextPhase >= 0 then
      mapCfg = mapGroup[nNextPhase]
      if not mapCfg then
        nNextPhase = nNextPhase - 1
        -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out IF_STMT

        -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC25: LeaveBlock: unexpected jumping out IF_STMT

      end
    end
  end
  if not mapCfg then
    return tbShowNote
  end
  local tbCurSubNoteSkills = mapDisc.tbSubNoteSkills
  local tbNextSubNoteSkills = {}
  local tbNote = decodeJson(mapCfg.SubNoteSkills)
  for k,v in pairs(tbNote) do
    local nNoteId = tonumber(k)
    local nNoteCount = tonumber(v)
    if nNoteId then
      (table.insert)(tbNextSubNoteSkills, {nId = nNoteId, nCount = nNoteCount})
    end
  end
  for _,mapNextNote in pairs(tbNextSubNoteSkills) do
    local bNew = true
    for _,mapCurNote in pairs(tbCurSubNoteSkills) do
      if mapNextNote.nId == mapCurNote.nId then
        bNew = false
        if mapCurNote.nCount < mapNextNote.nCount then
          (table.insert)(tbShowNote, {mapNextNote.nId, mapCurNote.nCount, mapNextNote.nCount})
        end
        break
      end
    end
    do
      do
        if bNew then
          (table.insert)(tbShowNote, {mapNextNote.nId, mapNextNote.nCount})
        end
        -- DECOMPILER ERROR at PC95: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
  return tbShowNote
end

PlayerDiscData.GetUpgradeMatList = function(self)
  -- function num : 0_22 , upvalues : _ENV
  local tbMat = {}
  for _,value in ipairs(self.tbItemExp) do
    (table.insert)(tbMat, {nItemId = value.nItemId, nExpValue = value.nExpValue, nCost = 0})
  end
  return tbMat
end

PlayerDiscData.GetCustomizeLevelExp = function(self, nId, nLevel)
  -- function num : 0_23
  local mapDisc = (self._mapDisc)[nId]
  local nUpgradeGroupId = mapDisc.nStrengthenGroupId
  local nTargetLevel = mapDisc.nMaxLv <= nLevel and mapDisc.nMaxLv or nLevel
  local nNextExp = self:CalUpgradeExp(nUpgradeGroupId, mapDisc.nLevel, nTargetLevel, mapDisc.nExp)
  return nNextExp
end

PlayerDiscData.GetMaxLevelExp = function(self, nId)
  -- function num : 0_24
  local mapDisc = (self._mapDisc)[nId]
  local nUpgradeGroupId = mapDisc.nStrengthenGroupId
  local nNextExp = self:CalUpgradeExp(nUpgradeGroupId, mapDisc.nLevel, mapDisc.nMaxLv, mapDisc.nExp)
  return nNextExp
end

PlayerDiscData.GetCustomizeLevelDataAndCost = function(self, nId, nLevel)
  -- function num : 0_25
  local nTargetExp = self:GetCustomizeLevelExp(nId, nLevel)
  local tbMat = self:CalUpgradeMat(nTargetExp)
  local mapTargetLevel, nGoldCost = self:GetLevelDataAndCostByMat(nId, tbMat)
  return mapTargetLevel, tbMat, nGoldCost
end

PlayerDiscData.GetMaxLevelDataAndCost = function(self, nId)
  -- function num : 0_26
  local nTargetExp = self:GetMaxLevelExp(nId)
  local tbMat = self:CalUpgradeMat(nTargetExp)
  local mapTargetLevel, nGoldCost = self:GetLevelDataAndCostByMat(nId, tbMat)
  return mapTargetLevel, tbMat, nGoldCost
end

PlayerDiscData.GetMaxMatCost = function(self, nId, tbMat, mapMat)
  -- function num : 0_27 , upvalues : _ENV
  local nMatExp = mapMat.nExpValue
  local nMaxExp = self:GetMaxLevelExp(nId)
  local nHasExp = self:GetMatExp(tbMat)
  local nCount = (math.ceil)((nMaxExp - nHasExp) / nMatExp)
  return nCount
end

PlayerDiscData.GetMatExp = function(self, tbMat)
  -- function num : 0_28 , upvalues : _ENV
  local nTotalExp = 0
  for _,mapMat in pairs(tbMat) do
    nTotalExp = nTotalExp + mapMat.nExpValue * mapMat.nCost
  end
  return nTotalExp
end

PlayerDiscData.GetLevelDataAndCostByMat = function(self, nId, tbMat)
  -- function num : 0_29 , upvalues : _ENV
  local mapDisc = (self._mapDisc)[nId]
  local nMatExp = self:GetMatExp(tbMat)
  local nExpPerGold = (self.tbExpPerGold)[mapDisc.nRarity]
  local nGoldCost = nMatExp * nExpPerGold
  local nTotalExp = nMatExp + mapDisc.nExp
  local nUpgradeGroupId = mapDisc.nStrengthenGroupId
  local nStartLevel = mapDisc.nLevel
  local nMaxLevel = mapDisc.nMaxLv
  local nTargetLevel = nStartLevel
  for i = nStartLevel, nMaxLevel - 1 do
    local nUpgradeId = nUpgradeGroupId * 1000 + i + 1
    local mapUpgrade = (ConfigTable.GetData)("DiscStrengthen", nUpgradeId, true)
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
      nGoldCost = nGoldCost - (nTotalExp) * nExpPerGold
      nMatExp = nMatExp - (nTotalExp)
      nTotalExp = 0
    end
    local mapLevelData = {nLevel = nTargetLevel, nExp = (math.ceil)(nTotalExp), nMaxLevel = nMaxLevel, nMaxExp = self:GetMaxExp(nUpgradeGroupId, nTargetLevel), nMatExp = nMatExp}
    return mapLevelData, nGoldCost
  end
end

PlayerDiscData.CalUpgradeExp = function(self, nUpgradeGroupId, nStartLevel, nTargetLevel, nStartExp)
  -- function num : 0_30 , upvalues : _ENV
  local nTotalExp = 0
  for i = nStartLevel, nTargetLevel - 1 do
    local nUpgradeId = nUpgradeGroupId * 1000 + i + 1
    local mapUpgrade = (ConfigTable.GetData)("DiscStrengthen", nUpgradeId, true)
    local nExp = 0
    if mapUpgrade then
      nExp = mapUpgrade.Exp
    end
    nTotalExp = nTotalExp + nExp
  end
  nTotalExp = nTotalExp - nStartExp
  return nTotalExp
end

PlayerDiscData.GetMaxExp = function(self, nUpgradeGroupId, nLevel)
  -- function num : 0_31 , upvalues : _ENV
  local nUpgradeId = nUpgradeGroupId * 1000 + nLevel + 1
  local mapUpgrade = (ConfigTable.GetData)("DiscStrengthen", nUpgradeId, true)
  if not mapUpgrade then
    return 0
  end
  local nExp = mapUpgrade.Exp
  return nExp
end

PlayerDiscData.CalCostProportion = function(self, nTarget, tbMatType, tbHas)
  -- function num : 0_32 , upvalues : _ENV
  local nTypeCount = #tbMatType
  local GetProportionedSum = function(tbProportioned)
    -- function num : 0_32_0 , upvalues : nTypeCount, tbMatType
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
    -- function num : 0_32_1
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
    -- function num : 0_32_2 , upvalues : nTypeCount, GetProportionedSum, nTarget, nMinTarget, tbCost, GetLargeFaceValue, _ENV, tbMatType, tbHas, Proportion
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

PlayerDiscData.CalUpgradeMat = function(self, nTargetExp)
  -- function num : 0_33 , upvalues : _ENV
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

PlayerDiscData.GetDiscIdList = function(self)
  -- function num : 0_34 , upvalues : _ENV
  local tbDisc = {}
  for nId,_ in pairs(self._mapDisc) do
    (table.insert)(tbDisc, nId)
  end
  return tbDisc
end

PlayerDiscData.SendDiscStrengthenReq = function(self, nId, tbMat, callback)
  -- function num : 0_35 , upvalues : _ENV
  if (self._mapDisc)[nId] == nil then
    printError((string.format)("星盘不存在, id为: %d", nId))
    return 
  end
  local tbItems = {}
  for _,mapMat in pairs(tbMat) do
    if mapMat.nCost > 0 then
      (table.insert)(tbItems, {Id = 0, Qty = mapMat.nCost, Tid = mapMat.nItemId})
    end
  end
  local msgData = {Id = nId, Items = tbItems}
  local successCallback = function(_, mapMainData)
    -- function num : 0_35_0 , upvalues : self, nId, callback
    self:UpdateDiscData(nId, {Level = mapMainData.Level, Exp = mapMainData.Exp})
    callback()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).disc_strengthen_req, msgData, nil, successCallback)
end

PlayerDiscData.SendDiscPromoteReq = function(self, nId, callback)
  -- function num : 0_36 , upvalues : _ENV
  if (self._mapDisc)[nId] == nil then
    printError((string.format)("星盘不存在, id为: %d", nId))
    return 
  end
  local successCallback = function(_, mapMainData)
    -- function num : 0_36_0 , upvalues : self, nId, callback
    self:UpdateDiscData(nId, {Phase = mapMainData.Phase})
    self:UpdateStoryReddot((self._mapDisc)[nId])
    self:UpdateAvgReddot((self._mapDisc)[nId])
    callback()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).disc_promote_req, {Id = nId}, nil, successCallback)
end

PlayerDiscData.SendDiscLimitBreakReq = function(self, nId, nCount, callback)
  -- function num : 0_37 , upvalues : _ENV
  if (self._mapDisc)[nId] == nil then
    printError((string.format)("星盘不存在, id为: %d", nId))
    return 
  end
  local successCallback = function(_, mapMainData)
    -- function num : 0_37_0 , upvalues : self, nId, callback
    self:UpdateDiscData(nId, {Star = mapMainData.Star})
    self:UpdateBreakLimitReddot((self._mapDisc)[nId])
    callback()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).disc_limit_break_req, {Id = nId, Qty = nCount}, nil, successCallback)
end

PlayerDiscData.SendAllDiscLimitBreakReq = function(self, callback)
  -- function num : 0_38 , upvalues : _ENV
  local successCallback = function(_, mapMainData)
    -- function num : 0_38_0 , upvalues : _ENV, self, callback
    for _,mapData in ipairs(mapMainData.LimitBreaks) do
      self:UpdateDiscData(mapData.Id, {Star = mapData.Star})
      self:UpdateBreakLimitReddot((self._mapDisc)[mapData.Id])
    end
    callback()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).disc_all_limit_break_req, {}, nil, successCallback)
end

PlayerDiscData.SendDiscReadRewardReceiveReq = function(self, nId, nType, callback)
  -- function num : 0_39 , upvalues : _ENV
  if (self._mapDisc)[nId] == nil then
    printError((string.format)("星盘不存在, id为: %d", nId))
    return 
  end
  local msgData = {Id = nId, ReadType = nType}
  local successCallback = function(_, mapMainData)
    -- function num : 0_39_0 , upvalues : nType, _ENV, self, nId, callback
    if nType == (AllEnum.DiscReadType).DiscStory then
      self:UpdateDiscData(nId, {Read = true})
      self:UpdateStoryReddot((self._mapDisc)[nId])
      ;
      (UTILS.OpenReceiveByChangeInfo)(mapMainData)
    else
      if nType == (AllEnum.DiscReadType).DiscAvg then
        self:UpdateDiscData(nId, {Avg = true})
        self:UpdateAvgReddot((self._mapDisc)[nId])
      end
    end
    if callback then
      callback(mapMainData)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).disc_read_reward_receive_req, msgData, nil, successCallback)
end

PlayerDiscData.SendPlayerMusicSetReq = function(self, nId, callback)
  -- function num : 0_40 , upvalues : _ENV
  local successCallback = function(_, mapMainData)
    -- function num : 0_40_0 , upvalues : self, nId, callback
    self:CacheBGMDisc(nId)
    callback()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_music_set_req, {Value = nId}, nil, successCallback)
end

PlayerDiscData.CacheBGMDisc = function(self, nId)
  -- function num : 0_41 , upvalues : WwiseAudioMgr, _ENV
  self.nBGMDisc = nId
  if nId == 0 then
    WwiseAudioMgr.DiscUIBgm = ""
    return 
  end
  local mapCfg = (ConfigTable.GetData)("DiscIP", nId)
  if not mapCfg then
    WwiseAudioMgr.DiscUIBgm = ""
    return 
  end
  WwiseAudioMgr.DiscUIBgm = mapCfg.VoFile
end

PlayerDiscData.CacheDiscData = function(self, tbData)
  -- function num : 0_42 , upvalues : _ENV
  for nId,_ in pairs(self._mapDisc) do
    -- DECOMPILER ERROR at PC5: Confused about usage of register: R7 in 'UnsetPending'

    (self._mapDisc)[nId] = nil
  end
  self:CreateNewDisc(tbData)
end

PlayerDiscData.CreateNewDisc = function(self, tbData)
  -- function num : 0_43 , upvalues : _ENV
  if tbData == nil then
    return 
  end
  for _,mapDisc in ipairs(tbData) do
    if (self._mapDisc)[mapDisc.Id] == nil then
      self:CreateDiscData(mapDisc)
    else
      printError((string.format)("星盘唯一Id重复, 唯一Id: %d", mapDisc.Id))
    end
  end
end

PlayerDiscData.UpdateDiscData = function(self, nId, mapData)
  -- function num : 0_44 , upvalues : _ENV
  if (self._mapDisc)[nId] == nil then
    printLog((string.format)("该星盘不存在/是新星盘, 唯一Id: %d", nId))
    self:CreateDiscData(mapData)
  else
    ;
    ((self._mapDisc)[nId]):ParseServerData(mapData)
  end
end

PlayerDiscData.CreateDiscData = function(self, mapDisc)
  -- function num : 0_45 , upvalues : DiscData
  local discData = (DiscData.new)(mapDisc)
  local nId = discData.nId
  -- DECOMPILER ERROR at PC5: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self._mapDisc)[nId] = discData
  self:UpdateStoryReddot(discData)
  self:UpdateAvgReddot(discData)
  self:UpdateBreakLimitReddot(discData)
end

PlayerDiscData.UpdateStoryReddot = function(self, mapDisc)
  -- function num : 0_46 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("Disc", mapDisc.nId)
  local nLimit = (ConfigTable.GetConfigNumber)("DiscStoryReadLimit")
  if mapDisc.bRead ~= false or nLimit > mapDisc.nPhase then
    (RedDotManager.SetValid)(RedDotDefine.Disc_SideB_Read, {mapDisc.nId}, mapCfg == nil or not mapCfg.Visible)
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end
end

PlayerDiscData.UpdateAvgReddot = function(self, mapDisc)
  -- function num : 0_47 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("Disc", mapDisc.nId)
  local mapIPCfg = (ConfigTable.GetData)("DiscIP", mapDisc.nId)
  local nLimit = (ConfigTable.GetConfigNumber)("DiscAVGStoryReadLimit")
  if mapIPCfg.AvgId == "" or mapDisc.bAvgRead ~= false or nLimit > mapDisc.nPhase then
    (RedDotManager.SetValid)(RedDotDefine.Disc_SideB_Avg, {mapDisc.nId}, mapCfg == nil or not mapCfg.Visible or mapIPCfg == nil)
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end
end

PlayerDiscData.UpdateBreakLimitReddot = function(self, mapDisc)
  -- function num : 0_48 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("Disc", mapDisc.nId)
  do
    if mapCfg ~= nil and mapCfg.Visible then
      local _, nMatCount = self:GetBreakLimitMat(mapDisc.nId)
      ;
      (RedDotManager.SetValid)(RedDotDefine.Disc_BreakBtn, {mapDisc.nId}, nMatCount > 0 and mapDisc.nStar < mapDisc.nMaxStar)
    end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end
end

PlayerDiscData.UpdateBreakLimitRedDotByItem = function(self, mapChange)
  -- function num : 0_49 , upvalues : _ENV
  for _,v in ipairs(mapChange) do
    local nId = (self.ItemToDisc)[v.Tid]
    if nId and (self._mapDisc)[nId] and v.Qty > 0 then
      self:UpdateBreakLimitReddot((self._mapDisc)[nId])
    end
  end
end

PlayerDiscData.CreateTrialDisc = function(self, tbTrialId)
  -- function num : 0_50 , upvalues : _ENV
  self._mapTrialDisc = {}
  for _,nTrialId in ipairs(tbTrialId) do
    local mapCfg = (ConfigTable.GetData)("TrialDisc", nTrialId)
    if mapCfg == nil then
      printError("体验星盘数据没有找到：" .. nTrialId)
      return 
    end
    local discData = self:GenerateLocalDiscData(mapCfg.DiscId, 0, mapCfg.Level, mapCfg.Phase, mapCfg.Star)
    -- DECOMPILER ERROR at PC27: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self._mapTrialDisc)[nTrialId] = discData
  end
end

PlayerDiscData.GetTrialDiscById = function(self, nId)
  -- function num : 0_51 , upvalues : _ENV
  if not nId then
    return 
  end
  if (self._mapTrialDisc)[nId] == nil then
    printLog((string.format)("该星盘不存在或新获得, 唯一Id: %d", nId))
  end
  return (self._mapTrialDisc)[nId]
end

PlayerDiscData.DeleteTrialDisc = function(self)
  -- function num : 0_52
  self._mapTrialDisc = {}
end

PlayerDiscData.CalcTrialEffectInBuild = function(self, nTrialId, tbSecondarySkill)
  -- function num : 0_53 , upvalues : _ENV
  local discData = (self._mapTrialDisc)[nTrialId]
  local tbEffectId = {}
  if discData == nil then
    return tbEffectId
  end
  local add = function(tbEfId)
    -- function num : 0_53_0 , upvalues : _ENV, tbEffectId
    if not tbEfId then
      return 
    end
    for _,nEfId in pairs(tbEfId) do
      if type(nEfId) == "number" and nEfId > 0 then
        (table.insert)(tbEffectId, {nEfId, 0})
      end
    end
  end

  local mapMainCfg = (ConfigTable.GetData)("MainSkill", discData.nMainSkillId)
  if mapMainCfg then
    add(mapMainCfg.EffectId)
  end
  for _,v in ipairs(tbSecondarySkill) do
    local mapSubCfg = (ConfigTable.GetData)("SecondarySkill", v)
    if mapSubCfg and (table.indexof)(discData.tbSubSkillGroupId, mapSubCfg.GroupId) > 0 then
      add(mapSubCfg.EffectId)
    end
  end
  return tbEffectId
end

PlayerDiscData.CalcTrialInfoInBuild = function(self, nTrialId, tbSecondarySkill)
  -- function num : 0_54 , upvalues : _ENV
  local discData = (self._mapTrialDisc)[nTrialId]
  local discInfo = (CS.Lua2CSharpInfo_DiscInfo)()
  if discData == nil then
    return discInfo
  end
  local tbSkillInfo = {}
  for _,v in ipairs(tbSecondarySkill) do
    local mapSubCfg = (ConfigTable.GetData)("SecondarySkill", v, true)
    if mapSubCfg and (table.indexof)(discData.tbSubSkillGroupId, mapSubCfg.GroupId) > 0 then
      local skillInfo = (CS.Lua2CSharpInfo_DiscSkillInfo)()
      skillInfo.skillId = v
      skillInfo.skillLevel = mapSubCfg.Level
      ;
      (table.insert)(tbSkillInfo, skillInfo)
    end
  end
  local mapMainCfg = (ConfigTable.GetData)("MainSkill", discData.nMainSkillId, true)
  do
    if mapMainCfg then
      local skillInfo = (CS.Lua2CSharpInfo_DiscSkillInfo)()
      skillInfo.skillId = discData.nMainSkillId
      skillInfo.skillLevel = 1
      ;
      (table.insert)(tbSkillInfo, skillInfo)
    end
    discInfo.discId = discData.nId
    discInfo.discScript = discData.sSkillScript
    discInfo.skillInfos = tbSkillInfo
    discInfo.discLevel = discData.nLevel
    return discInfo
  end
end

local tbSortNameTextCfg = {"CharList_Sort_Toggle_Level", "CharList_Sort_Toggle_Rare", "CharList_Sort_Toggle_Time"}
local tbSortType = {[1] = (AllEnum.SortType).Level, [2] = (AllEnum.SortType).Rarity, [3] = (AllEnum.SortType).Time, [100] = (AllEnum.SortType).ElementType, [101] = (AllEnum.SortType).Id}
local tbDefaultSortField = {"nLevel", "nRarity", "nEET", "nId"}
PlayerDiscData.GetDiscSortNameTextCfg = function(self)
  -- function num : 0_55 , upvalues : tbSortNameTextCfg
  return tbSortNameTextCfg
end

PlayerDiscData.GetDiscSortType = function(self)
  -- function num : 0_56 , upvalues : tbSortType
  return tbSortType
end

PlayerDiscData.GetDiscSortField = function(self)
  -- function num : 0_57 , upvalues : tbDefaultSortField
  return tbDefaultSortField
end

return PlayerDiscData

