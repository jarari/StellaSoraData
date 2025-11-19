local CharacterAttrData = class("CharacterAttrData")
local ConfigData = require("GameCore.Data.ConfigData")
local AttrConfig = require("GameCore.Common.AttrConfig")
CharacterAttrData.ctor = function(self, nId, mapCustom)
  -- function num : 0_0 , upvalues : AttrConfig, _ENV
  self.nId = nId
  self.tbAttr = {}
  self.CharAttrList = (AttrConfig.GetCharAttrList)()
  for _,v in pairs(self.CharAttrList) do
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R8 in 'UnsetPending'

    if v.bAllEffectSub then
      (self.tbAttr)["_" .. v.sKey] = nil
      -- DECOMPILER ERROR at PC23: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (self.tbAttr)["_" .. v.sKey .. "PercentAmend"] = nil
      -- DECOMPILER ERROR at PC29: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (self.tbAttr)["_" .. v.sKey .. "Amend"] = nil
    else
      -- DECOMPILER ERROR at PC35: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (self.tbAttr)["_origin" .. v.sKey] = nil
    end
    -- DECOMPILER ERROR at PC38: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self.tbAttr)[v.sKey] = nil
    -- DECOMPILER ERROR at PC43: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self.tbAttr)["base" .. v.sKey] = nil
  end
  self.eetType = nil
  self.eet = nil
  self.baseEET = nil
  self.attrList = nil
  self:ParseConfig(mapCustom)
end

CharacterAttrData.ParseConfig = function(self, mapCustom)
  -- function num : 0_1 , upvalues : _ENV, ConfigData
  if not self.nId then
    return 
  end
  local config = (ConfigTable.GetData_Character)(self.nId)
  if not config then
    return 
  end
  local mapChar = nil
  if mapCustom == nil then
    mapChar = (PlayerData.Char):GetCharDataByTid(self.nId)
  else
    mapChar = mapCustom.mapChar
  end
  local nAttributeId = (UTILS.GetCharacterAttributeId)(tonumber(config.AttributeId), mapChar.nAdvance, mapChar.nLevel)
  local attrConfig = (ConfigTable.GetData_Attribute)(tostring(nAttributeId))
  if not attrConfig then
    printError("角色表属性id配置不对，角色" .. self.nId)
    return 
  end
  local skillConfig = (ConfigTable.GetData_Skill)(config.UltimateId)
  if not skillConfig then
    printError("角色Skill表大招没配" .. config.UltimateId)
    return 
  end
  for _,v in pairs(self.CharAttrList) do
    local mapCfg = attrConfig
    if v.nConfigType == (AllEnum.CharConfigType).Attr then
      mapCfg = attrConfig
    else
      if v.nConfigType == (AllEnum.CharConfigType).Char then
        mapCfg = config
      else
        if v.nConfigType == (AllEnum.CharConfigType).Skill then
          mapCfg = skillConfig
        end
      end
    end
    local originVale = mapCfg[v.sKey] or 0
    -- DECOMPILER ERROR at PC96: Confused about usage of register: R14 in 'UnsetPending'

    if v.bAllEffectSub then
      (self.tbAttr)["_" .. v.sKey] = originVale
      -- DECOMPILER ERROR at PC102: Confused about usage of register: R14 in 'UnsetPending'

      ;
      (self.tbAttr)["_" .. v.sKey .. "PercentAmend"] = 0
      -- DECOMPILER ERROR at PC108: Confused about usage of register: R14 in 'UnsetPending'

      ;
      (self.tbAttr)["_" .. v.sKey .. "Amend"] = 0
      -- DECOMPILER ERROR at PC118: Confused about usage of register: R14 in 'UnsetPending'

      ;
      (self.tbAttr)["base" .. v.sKey] = (self.tbAttr)["_" .. v.sKey]
    else
      -- DECOMPILER ERROR at PC132: Confused about usage of register: R14 in 'UnsetPending'

      ;
      (self.tbAttr)["_origin" .. v.sKey] = v.bIntFloat and originVale * ConfigData.IntFloatPrecision or originVale
      -- DECOMPILER ERROR at PC153: Confused about usage of register: R14 in 'UnsetPending'

      if not v.bPercent or not (self.tbAttr)["_origin" .. v.sKey] * 100 then
        do
          (self.tbAttr)["base" .. v.sKey] = (self.tbAttr)["_origin" .. v.sKey]
          -- DECOMPILER ERROR at PC161: Confused about usage of register: R14 in 'UnsetPending'

          ;
          (self.tbAttr)[v.sKey] = (self.tbAttr)["base" .. v.sKey]
          -- DECOMPILER ERROR at PC162: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC162: LeaveBlock: unexpected jumping out IF_STMT

          -- DECOMPILER ERROR at PC162: LeaveBlock: unexpected jumping out IF_ELSE_STMT

          -- DECOMPILER ERROR at PC162: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  self.eetType = (AllEnum.EET)[config.EET]
  self.baseEET = attrConfig[self.eetType] or 0
  self.eet = self.baseEET
  self:AddAttr()
  self:AddEffect(mapCustom)
  self:UpdateAttrList()
end

CharacterAttrData.SetCharacter = function(self, nId, mapCustom)
  -- function num : 0_2
  self.nId = nId
  self:ParseConfig(mapCustom)
end

CharacterAttrData.AddAttr = function(self)
  -- function num : 0_3 , upvalues : _ENV
  for _,v in ipairs(AllEnum.AttachAttr) do
    -- DECOMPILER ERROR at PC27: Confused about usage of register: R6 in 'UnsetPending'

    if (self.tbAttr)["base" .. v.sKey] then
      if ((self.CharAttrList)[v.sKey]).bDifferentiate then
        (self.tbAttr)["base" .. v.sKey] = (self.tbAttr)["base" .. v.sKey]
      else
        -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

        ;
        (self.tbAttr)["base" .. v.sKey] = (self.tbAttr)["base" .. v.sKey]
      end
    end
    -- DECOMPILER ERROR at PC55: Confused about usage of register: R6 in 'UnsetPending'

    if (self.tbAttr)["_" .. v.sKey] then
      (self.tbAttr)["_" .. v.sKey] = (self.tbAttr)["_" .. v.sKey]
    end
    -- DECOMPILER ERROR at PC73: Confused about usage of register: R6 in 'UnsetPending'

    if (self.tbAttr)[v.sKey] and not (self.tbAttr)["_" .. v.sKey] then
      (self.tbAttr)[v.sKey] = (self.tbAttr)[v.sKey]
    end
  end
end

CharacterAttrData.AddEffect = function(self, mapCustom)
  -- function num : 0_4 , upvalues : _ENV
  local tbAllEfts = {}
  if not mapCustom then
    local tbAffinityEfts = (PlayerData.Char):GetCharAffinityEffects(self.nId)
    local tbTalentEfts = (PlayerData.Talent):GetTalentEffect(self.nId)
    local tbEquipmentEfts = (PlayerData.Equipment):GetCharEquipmentEffect(self.nId)
    if tbAffinityEfts then
      for _,value in pairs(tbAffinityEfts) do
        (table.insert)(tbAllEfts, value)
      end
    end
    do
      if tbTalentEfts then
        for _,value in pairs(tbTalentEfts) do
          (table.insert)(tbAllEfts, value)
        end
      end
      do
        if tbEquipmentEfts then
          for _,value in pairs(tbEquipmentEfts) do
            (table.insert)(tbAllEfts, value)
          end
        end
        do
          if not mapCustom.tbEffect then
            tbAllEfts = {}
          end
          self:AddAttrEffect(tbAllEfts)
          self:AddEquipmentRandomAttr(mapCustom)
          self:CalAllEffectSubAttr()
        end
      end
    end
  end
end

CharacterAttrData.AddAttrEffect = function(self, tbAttrEffect)
  -- function num : 0_5 , upvalues : _ENV, AttrConfig
  for _,attrEffectId in ipairs(tbAttrEffect) do
    local config = (ConfigTable.GetData_Effect)(attrEffectId)
    local valueConfig = (ConfigTable.GetData)("EffectValue", attrEffectId)
    if valueConfig.EffectType ~= (GameEnum.effectType).ATTR_FIX and valueConfig.EffectType ~= (GameEnum.effectType).PLAYER_ATTR_FIX then
      local bAttrFix = valueConfig == nil or config == nil
      if bAttrFix and config.Trigger == (GameEnum.trigger).NOTHING then
        local mapAttr = (AttrConfig.GetAttrByEffectType)(valueConfig.EffectType, valueConfig.EffectTypeFirstSubtype)
        if mapAttr then
          if mapAttr.bAllEffectSub then
            self:AddAttrEffect_AllEffectSub(valueConfig.EffectTypeSecondSubtype, valueConfig.EffectTypeParam1, mapAttr)
          else
            self:AddAttrEffect_BaseValue(valueConfig.EffectTypeSecondSubtype, valueConfig.EffectTypeParam1, mapAttr)
          end
        else
          local value = tonumber(valueConfig.EffectTypeParam1) or 0
          if valueConfig.EffectTypeFirstSubtype == self.eetType and valueConfig.EffectTypeSecondSubtype == (GameEnum.parameterType).BASE_VALUE then
            self.baseEET = self.baseEET + value
            self.eet = self.eet + value
          end
        end
      end
      -- DECOMPILER ERROR at PC82: LeaveBlock: unexpected jumping out IF_THEN_STMT

      -- DECOMPILER ERROR at PC82: LeaveBlock: unexpected jumping out IF_STMT

    end
  end
  -- DECOMPILER ERROR: 5 unprocessed JMP targets
end

CharacterAttrData.AddEquipmentRandomAttr = function(self, mapCustom)
  -- function num : 0_6 , upvalues : _ENV, AttrConfig
  local tbRandomAttr = {}
  if mapCustom and not mapCustom.tbRandomAttr then
    tbRandomAttr = {}
    tbRandomAttr = (PlayerData.Equipment):GetCharEquipmentRandomAttr(self.nId)
    for nAttrId,v in pairs(tbRandomAttr) do
      local mapAttrCfg = (ConfigTable.GetData)("CharGemAttrValue", nAttrId)
      if mapAttrCfg then
        local attrType = mapAttrCfg.AttrType
        local attrSubType1 = mapAttrCfg.AttrTypeFirstSubtype
        local attrSubType2 = mapAttrCfg.AttrTypeSecondSubtype
        local bAttrFix = attrType == (GameEnum.effectType).ATTR_FIX or attrType == (GameEnum.effectType).PLAYER_ATTR_FIX
        if bAttrFix then
          local mapAttr = (AttrConfig.GetAttrByEffectType)(attrType, attrSubType1)
          if mapAttr then
            if mapAttr.bAllEffectSub then
              self:AddAttrEffect_AllEffectSub(attrSubType2, v.Value, mapAttr)
            else
              self:AddAttrEffect_BaseValue(attrSubType2, v.Value, mapAttr)
            end
          else
            local value = tonumber(v.CfgValue) or 0
            if attrSubType1 == self.eetType and attrSubType2 == (GameEnum.parameterType).BASE_VALUE then
              self.baseEET = self.baseEET + value
              self.eet = self.eet + value
            end
          end
        end
      end
    end
    -- DECOMPILER ERROR: 5 unprocessed JMP targets
  end
end

CharacterAttrData.AddAttrEffect_AllEffectSub = function(self, nSubType, nValue, mapAttr)
  -- function num : 0_7 , upvalues : _ENV
  local value = tonumber(nValue) or 0
  -- DECOMPILER ERROR at PC24: Confused about usage of register: R5 in 'UnsetPending'

  if nSubType == (GameEnum.parameterType).PERCENTAGE then
    (self.tbAttr)["_" .. mapAttr.sKey .. "PercentAmend"] = (self.tbAttr)["_" .. mapAttr.sKey .. "PercentAmend"] + value * 100
  else
    -- DECOMPILER ERROR at PC43: Confused about usage of register: R5 in 'UnsetPending'

    if nSubType == (GameEnum.parameterType).ABSOLUTE_VALUE then
      (self.tbAttr)["_" .. mapAttr.sKey .. "Amend"] = (self.tbAttr)["_" .. mapAttr.sKey .. "Amend"] + value
    else
      -- DECOMPILER ERROR at PC60: Confused about usage of register: R5 in 'UnsetPending'

      if nSubType == (GameEnum.parameterType).BASE_VALUE then
        (self.tbAttr)["_" .. mapAttr.sKey] = (self.tbAttr)["_" .. mapAttr.sKey] + value
      end
    end
  end
end

CharacterAttrData.AddAttrEffect_BaseValue = function(self, nSubType, nValue, mapAttr)
  -- function num : 0_8 , upvalues : _ENV
  local value = tonumber(nValue) or 0
  if not mapAttr.bPercent or not value * 100 then
    local nAdd = nSubType ~= (GameEnum.parameterType).BASE_VALUE or value
  end
  -- DECOMPILER ERROR at PC31: Confused about usage of register: R6 in 'UnsetPending'

  if not mapAttr.bDifferentiate then
    (self.tbAttr)["base" .. mapAttr.sKey] = (self.tbAttr)["base" .. mapAttr.sKey] + nAdd
  end
  -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (self.tbAttr)[mapAttr.sKey] = (self.tbAttr)[mapAttr.sKey] + nAdd
end

CharacterAttrData.CalAllEffectSubAttr = function(self)
  -- function num : 0_9 , upvalues : _ENV
  for _,v in pairs(self.CharAttrList) do
    -- DECOMPILER ERROR at PC30: Confused about usage of register: R6 in 'UnsetPending'

    if v.bAllEffectSub then
      (self.tbAttr)[v.sKey] = (self.tbAttr)["_" .. v.sKey] * (1 + (self.tbAttr)["_" .. v.sKey .. "PercentAmend"] / 100) + (self.tbAttr)["_" .. v.sKey .. "Amend"]
      -- DECOMPILER ERROR at PC39: Confused about usage of register: R6 in 'UnsetPending'

      ;
      (self.tbAttr)[v.sKey] = (math.floor)((self.tbAttr)[v.sKey])
    end
  end
end

CharacterAttrData.UpdateAttrList = function(self)
  -- function num : 0_10 , upvalues : _ENV
  if not self.attrList then
    self.attrList = {}
  end
  for k,v in pairs(AllEnum.CharAttr) do
    -- DECOMPILER ERROR at PC16: Confused about usage of register: R6 in 'UnsetPending'

    if not (self.attrList)[k] then
      (self.attrList)[k] = {}
    end
    -- DECOMPILER ERROR at PC29: Confused about usage of register: R7 in 'UnsetPending'

    -- DECOMPILER ERROR at PC30: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self.attrList)[k]).totalValue = (self.tbAttr)[v.sKey]
  end
end

CharacterAttrData.GetEETType = function(self)
  -- function num : 0_11
  return self.eetType
end

CharacterAttrData.GetEET = function(self)
  -- function num : 0_12
  return self.eet, self.baseEET
end

CharacterAttrData.GetAttrList = function(self)
  -- function num : 0_13
  return self.attrList
end

return CharacterAttrData

