local ConfigData = require("GameCore.Data.ConfigData")
local AttrConfig = require("GameCore.Common.AttrConfig")
local EquipmentData = class("EquipmentData")
EquipmentData.ctor = function(self, mapEquipment, nCharId, nGemId)
  -- function num : 0_0
  self:Clear()
  self:InitEquip(mapEquipment, nCharId, nGemId)
end

EquipmentData.Clear = function(self)
  -- function num : 0_1
  self.nCharId = nil
  self.nGemId = nil
  self.sName = nil
  self.sIcon = nil
  self.sDesc = nil
  self.nType = nil
  self.nGenerateId = nil
  self.nRefreshId = nil
  self.bLock = nil
  self.tbAffix = nil
  self.tbAlterAffix = nil
  self.tbPotentialAffix = nil
  self.tbSkillAffix = nil
  self.tbRandomAttr = nil
  self.tbEffect = nil
end

EquipmentData.InitEquip = function(self, mapEquipment, nCharId, nGemId)
  -- function num : 0_2 , upvalues : _ENV
  self.nCharId = nCharId
  self.nGemId = nGemId
  local equipmentCfg = (ConfigTable.GetData)("CharGem", nGemId)
  if equipmentCfg == nil then
    printError((string.format)("获取装备表配置失败！！！id = [%s]", nGemId))
    return 
  end
  self:ParseConfigData(equipmentCfg)
  self:ParseServerData(mapEquipment)
end

EquipmentData.ParseConfigData = function(self, equipmentCfg)
  -- function num : 0_3
  self.sName = equipmentCfg.Title
  self.sIcon = equipmentCfg.Icon
  self.sDesc = equipmentCfg.Desc
  self.nType = equipmentCfg.Type
  self.nGenerateId = equipmentCfg.GenerateCostTid
  self.nRefreshId = equipmentCfg.RefreshCostTid
  self.tbRandomAttr = {}
end

EquipmentData.ParseServerData = function(self, mapEquipment)
  -- function num : 0_4
  self.bLock = mapEquipment.Lock
  self:UpdateAffix(mapEquipment.Attributes)
  self:UpdateAlterAffix(mapEquipment.AlterAttributes)
end

EquipmentData.UpdateAffix = function(self, tbAttributes)
  -- function num : 0_5
  self.tbAffix = tbAttributes
  self:UpdateRandomAttr(self.tbAffix)
end

EquipmentData.UpdateAlterAffix = function(self, tbAttributes)
  -- function num : 0_6
  self.tbAlterAffix = tbAttributes
end

EquipmentData.ReplaceRandomAttr = function(self)
  -- function num : 0_7 , upvalues : _ENV
  if not self.tbAlterAffix or next(self.tbAlterAffix) == nil then
    return 
  end
  self.tbAffix = clone(self.tbAlterAffix)
  for k,_ in ipairs(self.tbAlterAffix) do
    -- DECOMPILER ERROR at PC18: Confused about usage of register: R6 in 'UnsetPending'

    (self.tbAlterAffix)[k] = 0
  end
  self:UpdateRandomAttr(self.tbAffix)
end

EquipmentData.UpdateRandomAttr = function(self, mapAttrs)
  -- function num : 0_8 , upvalues : _ENV, ConfigData
  self.tbPotentialAffix = {}
  self.tbSkillAffix = {}
  self.tbRandomAttr = {}
  self.tbEffect = {}
  for _,v in ipairs(mapAttrs) do
    if v > 0 then
      local mapCfg = (ConfigTable.GetData)("CharGemAttrValue", v)
      if mapCfg then
        if mapCfg.AttrType == (GameEnum.CharGemEffectType).Potential then
          (table.insert)(self.tbPotentialAffix, mapCfg)
        else
          if mapCfg.AttrType == (GameEnum.CharGemEffectType).SkillLevel then
            (table.insert)(self.tbSkillAffix, mapCfg)
          else
            if mapCfg.AttrTypeSecondSubtype == (GameEnum.parameterType).BASE_VALUE then
              if not tonumber(mapCfg.Value) then
                local value = mapCfg.AttrType ~= (GameEnum.effectType).ATTR_FIX and mapCfg.AttrType ~= (GameEnum.effectType).PLAYER_ATTR_FIX or 0
              end
              local mapData = {AttrId = v, Value = value, CfgValue = value / ConfigData.IntFloatPrecision}
              ;
              (table.insert)(self.tbRandomAttr, mapData)
            else
              do
                do
                  ;
                  (table.insert)(self.tbEffect, mapCfg.EffectId)
                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out DO_STMT

                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC86: LeaveBlock: unexpected jumping out IF_STMT

                end
              end
            end
          end
        end
      end
    end
  end
end

EquipmentData.UpdateLockState = function(self, bLock)
  -- function num : 0_9
  self.bLock = bLock
end

EquipmentData.GetEnhancedPotential = function(self)
  -- function num : 0_10 , upvalues : _ENV
  local tbPotential = {}
  for _,v in ipairs(self.tbPotentialAffix) do
    local nPotentialId = (UTILS.GetPotentialId)(self.nCharId, v.AttrTypeFirstSubtype)
    if not tbPotential[nPotentialId] then
      tbPotential[nPotentialId] = 0
    end
    tbPotential[nPotentialId] = tbPotential[nPotentialId] + tonumber(v.Value)
  end
  return tbPotential
end

EquipmentData.GetEnhancedSkill = function(self)
  -- function num : 0_11 , upvalues : _ENV
  local tbSkillId = (PlayerData.Char):GetSkillIds(self.nCharId)
  local tbSkill = {}
  for _,v in ipairs(self.tbSkillAffix) do
    local nSkillId = tbSkillId[v.AttrTypeFirstSubtype]
    if not tbSkill[nSkillId] then
      tbSkill[nSkillId] = 0
    end
    tbSkill[nSkillId] = tbSkill[nSkillId] + tonumber(v.Value)
  end
  return tbSkill
end

EquipmentData.GetRandomAttr = function(self)
  -- function num : 0_12
  return self.tbRandomAttr
end

EquipmentData.GetEffect = function(self)
  -- function num : 0_13
  return self.tbEffect
end

EquipmentData.CheckAlterEmpty = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if not self.tbAlterAffix or next(self.tbAlterAffix) == nil then
    return true
  end
  for _,v in pairs(self.tbAlterAffix) do
    if v == 0 then
      return true
    end
  end
  return false
end

EquipmentData.GetTypeDesc = function(self)
  -- function num : 0_15 , upvalues : _ENV
  local sLanguage = ((AllEnum.EquipmentType)[self.nType]).Language
  return (ConfigTable.GetUIText)(sLanguage)
end

EquipmentData.GetTypeIcon = function(self)
  -- function num : 0_16 , upvalues : _ENV
  return ((AllEnum.EquipmentType)[self.nType]).Icon
end

EquipmentData.GetEffectDescId = function(self, attrSybType1, attrSybType2)
  -- function num : 0_17 , upvalues : _ENV
  return (GameEnum.effectType).ATTR_FIX * 10000 + attrSybType1 * 10 + attrSybType2
end

return EquipmentData

