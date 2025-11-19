local FilterData = class("FilterData")
local LocalData = require("GameCore.Data.LocalData")
FilterData.ctor = function(self)
  -- function num : 0_0
end

FilterData.Init = function(self)
  -- function num : 0_1 , upvalues : _ENV
  self.tbCacheFilter = {}
  self.tbFilter = {}
  for fKey,v in pairs(AllEnum.ChooseOptionCfg) do
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R6 in 'UnsetPending'

    (self.tbFilter)[fKey] = {}
    for sKey,_ in pairs(v.items) do
      -- DECOMPILER ERROR at PC18: Confused about usage of register: R11 in 'UnsetPending'

      ((self.tbFilter)[fKey])[sKey] = false
    end
  end
  self.nFormationCharSrotType = (AllEnum.SortType).Level
  self.bFormationCharOrder = false
  self.nFormationDiscSrotType = (AllEnum.SortType).Level
  self.bFormationDiscOrder = false
end

FilterData.Reset = function(self, tbOption)
  -- function num : 0_2 , upvalues : _ENV
  if tbOption == nil then
    return 
  end
  self.tbCacheFilter = {}
  for fKey,_ in pairs(self.tbFilter) do
    if (table.indexof)(tbOption, fKey) > 0 then
      for sKey,_ in pairs((self.tbFilter)[fKey]) do
        -- DECOMPILER ERROR at PC23: Confused about usage of register: R12 in 'UnsetPending'

        ((self.tbFilter)[fKey])[sKey] = false
      end
    end
  end
end

FilterData.IsDirty = function(self, optionType)
  -- function num : 0_3 , upvalues : _ENV
  if optionType == (AllEnum.OptionType).Char then
    local dirty = self:_IsDirty((AllEnum.ChooseOption).Char_Element)
    if not dirty then
      dirty = self:_IsDirty((AllEnum.ChooseOption).Char_Rarity)
    end
    if not dirty then
      dirty = self:_IsDirty((AllEnum.ChooseOption).Char_PowerStyle)
    end
    if not dirty then
      dirty = self:_IsDirty((AllEnum.ChooseOption).Char_TacticalStyle)
    end
    if not dirty then
      dirty = self:_IsDirty((AllEnum.ChooseOption).Char_AffiliatedForces)
    end
    return dirty
  else
    do
      if optionType == (AllEnum.OptionType).Disc then
        local dirty = self:_IsDirty((AllEnum.ChooseOption).Star_Element)
        if not dirty then
          dirty = self:_IsDirty((AllEnum.ChooseOption).Star_Rarity)
        end
        if not dirty then
          dirty = self:_IsDirty((AllEnum.ChooseOption).Star_Note)
        end
        if not dirty then
          dirty = self:_IsDirty((AllEnum.ChooseOption).Star_Tag)
        end
        return dirty
      else
        do
          do
            if optionType == (AllEnum.OptionType).Equipment then
              local dirty = self:_IsDirty((AllEnum.ChooseOption).Equip_Rarity)
              if not dirty then
                dirty = self:_IsDirty((AllEnum.ChooseOption).Equip_Type)
              end
              if not dirty then
                dirty = self:_IsDirty((AllEnum.ChooseOption).Equip_Theme_Circle)
              end
              if not dirty then
                dirty = self:_IsDirty((AllEnum.ChooseOption).Equip_Theme_Square)
              end
              if not dirty then
                dirty = self:_IsDirty((AllEnum.ChooseOption).Equip_Theme_Pentagon)
              end
              if not dirty then
                dirty = self:_IsDirty((AllEnum.ChooseOption).Equip_PowerStyle)
              end
              if not dirty then
                dirty = self:_IsDirty((AllEnum.ChooseOption).Equip_TacticalStyle)
              end
              if not dirty then
                dirty = self:_IsDirty((AllEnum.ChooseOption).Equip_AffiliatedForces)
              end
              if not dirty then
                dirty = self:_IsDirty((AllEnum.ChooseOption).Equip_Match)
              end
              return dirty
            end
            return false
          end
        end
      end
    end
  end
end

FilterData._IsDirty = function(self, fKey)
  -- function num : 0_4 , upvalues : _ENV
  for _,result in pairs((self.tbFilter)[fKey]) do
    if result == true then
      return true
    end
  end
  return false
end

FilterData.CheckFilterByChar = function(self, charId)
  -- function num : 0_5 , upvalues : _ENV
  local charData = (ConfigTable.GetData_Character)(charId)
  local mapCharDescCfg = (ConfigTable.GetData)("CharacterDes", charId)
  local isFilter = true
  if mapCharDescCfg == nil or charData == nil then
    return isFilter
  end
  isFilter = self:_GetFilterByKey((AllEnum.ChooseOption).Char_Element, charData.EET)
  if isFilter then
    isFilter = self:_GetFilterByKey((AllEnum.ChooseOption).Char_Rarity, charData.Grade)
  end
  if isFilter then
    isFilter = self:_GetFilterByKey((AllEnum.ChooseOption).Char_PowerStyle, charData.Class)
  end
  if isFilter then
    isFilter = self:_GetFilterByKey((AllEnum.ChooseOption).Char_TacticalStyle, (mapCharDescCfg.Tag)[2])
  end
  if isFilter then
    isFilter = self:_GetFilterByKey((AllEnum.ChooseOption).Char_AffiliatedForces, (mapCharDescCfg.Tag)[3])
  end
  return isFilter
end

FilterData.CheckFilterByDisc = function(self, discId)
  -- function num : 0_6 , upvalues : _ENV
  local discCfg = (ConfigTable.GetData)("Disc", discId)
  local discData = (PlayerData.Disc):GetDiscById(discId)
  local isFilter = true
  isFilter = self:_GetFilterByKey((AllEnum.ChooseOption).Star_Element, discData.nEET)
  if isFilter then
    isFilter = self:_GetFilterByKey((AllEnum.ChooseOption).Star_Rarity, discData.nRarity)
  end
  local isFilter2 = true
  local A = {}
  if not discData.tbShowNote then
    for _,noteId in ipairs({}) do
      A[noteId] = true
    end
    for sKey,v in pairs((self.tbFilter)[(AllEnum.ChooseOption).Star_Note]) do
      if v == true and A[sKey] == nil then
        isFilter2 = false
      end
    end
    if isFilter then
      isFilter = isFilter2
    end
    local isFilter3 = true
    local B = {}
    if not discData.tbTag then
      for _,tagId in pairs({}) do
        B[tagId] = true
      end
      for sKey,v in pairs((self.tbFilter)[(AllEnum.ChooseOption).Star_Tag]) do
        if v == true and B[sKey] == nil then
          isFilter3 = false
        end
      end
      if isFilter then
        isFilter = isFilter3
      end
      return isFilter
    end
  end
end

FilterData.CheckFilerByEquip = function(self, equipId, nCharId)
  -- function num : 0_7 , upvalues : _ENV
  local equipmentData = (PlayerData.Equipment):GetEquipmentById(equipId)
  local isFilter = true
  local nEquipType = equipmentData:GetType()
  if isFilter then
    isFilter = self:_GetFilterByKey((AllEnum.ChooseOption).Equip_Rarity, equipmentData:GetRarity())
  end
  if isFilter then
    isFilter = self:_GetFilterByKey((AllEnum.ChooseOption).Equip_Type, nEquipType)
  end
  local tbBaseAttrDescId = equipmentData:GetBaseAttrDescId()
  local tbSelectAttr = {}
  local tbCurAttr = {}
  if nEquipType == (GameEnum.equipmentType).Square then
    tbCurAttr = (self.tbFilter)[(AllEnum.ChooseOption).Equip_Theme_Square]
  else
    if nEquipType == (GameEnum.equipmentType).Circle then
      tbCurAttr = (self.tbFilter)[(AllEnum.ChooseOption).Equip_Theme_Circle]
    else
      if nEquipType == (GameEnum.equipmentType).Pentagon then
        tbCurAttr = (self.tbFilter)[(AllEnum.ChooseOption).Equip_Theme_Pentagon]
      end
    end
  end
  for nKey,v in pairs(tbCurAttr) do
    if v then
      tbSelectAttr[nKey] = 1
    end
  end
  local bAttr = true
  if next(tbSelectAttr) ~= nil then
    bAttr = false
    for _,id in ipairs(tbBaseAttrDescId) do
      if tbSelectAttr[id] ~= nil then
        bAttr = true
        break
      end
    end
    do
      if isFilter then
        isFilter = bAttr
      end
      local tbTag = equipmentData:GetTag()
      local tbSelectTag = {}
      for nKey,v in pairs((self.tbFilter)[(AllEnum.ChooseOption).Equip_PowerStyle]) do
        if v then
          tbSelectTag[nKey] = 1
        end
      end
      local bTag = true
      if next(tbSelectTag) ~= nil then
        bTag = false
        for _,tag in ipairs(tbTag) do
          if tbSelectTag[tag] ~= nil then
            bTag = true
            break
          end
        end
        do
          if isFilter then
            isFilter = bTag
          end
          tbSelectTag = {}
          for nKey,v in pairs((self.tbFilter)[(AllEnum.ChooseOption).Equip_TacticalStyle]) do
            if v then
              tbSelectTag[nKey] = 1
            end
          end
          if next(tbSelectTag) ~= nil then
            bTag = false
            for _,tag in ipairs(tbTag) do
              if tbSelectTag[tag] ~= nil then
                bTag = true
                break
              end
            end
            do
              if isFilter then
                isFilter = bTag
              end
              tbSelectTag = {}
              for nKey,v in pairs((self.tbFilter)[(AllEnum.ChooseOption).Equip_AffiliatedForces]) do
                if v then
                  tbSelectTag[nKey] = 1
                end
              end
              if next(tbSelectTag) ~= nil then
                bTag = false
                for _,tag in ipairs(tbTag) do
                  if tbSelectTag[tag] ~= nil then
                    bTag = true
                    break
                  end
                end
                do
                  if isFilter then
                    isFilter = bTag
                  end
                  do
                    if nCharId ~= nil then
                      local nMatchCount = equipmentData:GetTagMatchCount(nCharId)
                      if isFilter then
                        isFilter = self:_GetFilterByKey((AllEnum.ChooseOption).Equip_Match, nMatchCount)
                      end
                    end
                    return isFilter
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

FilterData._GetFilterByKey = function(self, fKey, sKey)
  -- function num : 0_8 , upvalues : _ENV
  local isAllFalse = false
  for optionKey,_ in pairs((self.tbFilter)[fKey]) do
    if not isAllFalse then
      isAllFalse = ((self.tbFilter)[fKey])[optionKey]
    end
  end
  if not isAllFalse then
    return true
  end
  return ((self.tbFilter)[fKey])[sKey]
end

FilterData.GetFilterByKey = function(self, fKey, sKey)
  -- function num : 0_9
  return ((self.tbFilter)[fKey])[sKey]
end

FilterData.SetCacheFilterByKey = function(self, fKey, sKey, flag)
  -- function num : 0_10
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R4 in 'UnsetPending'

  if (self.tbCacheFilter)[fKey] == nil then
    (self.tbCacheFilter)[fKey] = {}
  end
  -- DECOMPILER ERROR at PC9: Confused about usage of register: R4 in 'UnsetPending'

  ;
  ((self.tbCacheFilter)[fKey])[sKey] = flag
end

FilterData.SyncFilterByCache = function(self)
  -- function num : 0_11 , upvalues : _ENV
  for fKey,v in pairs(self.tbCacheFilter) do
    for sKey,vv in pairs(v) do
      -- DECOMPILER ERROR at PC10: Confused about usage of register: R11 in 'UnsetPending'

      ((self.tbFilter)[fKey])[sKey] = vv
    end
  end
end

FilterData.GetCacheFilterByKey = function(self, fKey, sKey)
  -- function num : 0_12
  if (self.tbCacheFilter)[fKey] ~= nil and ((self.tbCacheFilter)[fKey])[sKey] ~= nil then
    return ((self.tbCacheFilter)[fKey])[sKey], true
  end
  return self:GetFilterByKey(fKey, sKey), false
end

FilterData.CacheCharSort = function(self, nType, bOrder)
  -- function num : 0_13 , upvalues : LocalData
  self.nFormationCharSrotType = nType
  self.bFormationCharOrder = bOrder
  ;
  (LocalData.SetPlayerLocalData)("FormationCharSrotType", self.nFormationCharSrotType)
  ;
  (LocalData.SetPlayerLocalData)("FormationCharOrder", self.bFormationCharOrder)
end

FilterData.CacheDiscSort = function(self, nType, bOrder)
  -- function num : 0_14 , upvalues : LocalData
  self.nFormationDiscSrotType = nType
  self.bFormationDiscOrder = bOrder
  ;
  (LocalData.SetPlayerLocalData)("FormationDiscSrotType", self.nFormationDiscSrotType)
  ;
  (LocalData.SetPlayerLocalData)("FormationDiscOrder", self.bFormationDiscOrder)
end

FilterData.InitSortData = function(self)
  -- function num : 0_15 , upvalues : _ENV, LocalData
  self.nFormationCharSrotType = (AllEnum.SortType).Level
  self.bFormationCharOrder = false
  self.nFormationDiscSrotType = (AllEnum.SortType).Level
  self.bFormationDiscOrder = false
  if not (LocalData.GetPlayerLocalData)("FormationCharSrotType") then
    self.nFormationCharSrotType = (AllEnum.SortType).Level
    self.bFormationCharOrder = (LocalData.GetPlayerLocalData)("FormationCharOrder") or false
    if not (LocalData.GetPlayerLocalData)("FormationDiscSrotType") then
      self.nFormationDiscSrotType = (AllEnum.SortType).Level
      self.bFormationDiscOrder = (LocalData.GetPlayerLocalData)("FormationDiscOrder") or false
    end
  end
end

return FilterData

