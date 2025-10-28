---@class EquipmentData

local ConfigData = require "GameCore.Data.ConfigData"
local AttrConfig = require "GameCore.Common.AttrConfig"

local EquipmentData = class("EquipmentData")

---@diagnostic disable-next-line: duplicate-set-field
function EquipmentData:ctor(mapEquipment, nCharId, nGemId)
    self:Clear()
    self:InitEquip(mapEquipment, nCharId, nGemId)
end

function EquipmentData:Clear()
    self.nCharId = nil          -- 绑定的角色
    self.nGemId = nil           -- 装备Id

    self.sName = nil            -- 装备名
    self.sIcon = nil            -- 装备icon(大图)
    self.sDesc = nil            -- 装备描述
    self.nType = nil            -- 装备类型
    self.nGenerateId = nil      -- 生成道具
    self.nRefreshId = nil       -- 刷新道具

    self.bLock = nil            -- 词条刷新锁定
    self.tbAffix = nil          -- 词条
    self.tbAlterAffix = nil     -- 备选词条
    self.tbPotentialAffix = nil -- 词条潜能相关
    self.tbSkillAffix = nil     -- 词条技能相关
    self.tbRandomAttr = nil     -- 词条属性相关
    self.tbEffect = nil         -- 词条百分比属性effect
end

function EquipmentData:InitEquip(mapEquipment, nCharId, nGemId)
    self.nCharId = nCharId
    self.nGemId = nGemId

    local equipmentCfg = ConfigTable.GetData("CharGem", nGemId)
    if nil == equipmentCfg then
        printError(string.format("获取装备表配置失败！！！id = [%s]", nGemId))
        return
    end

    self:ParseConfigData(equipmentCfg)
    self:ParseServerData(mapEquipment)
end

function EquipmentData:ParseConfigData(equipmentCfg)
    self.sName = equipmentCfg.Title
    self.sIcon = equipmentCfg.Icon
    self.sDesc = equipmentCfg.Desc
    self.nType = equipmentCfg.Type
    self.nGenerateId = equipmentCfg.GenerateCostTid
    self.nRefreshId = equipmentCfg.RefreshCostTid

    self.tbRandomAttr = {}
end

function EquipmentData:ParseServerData(mapEquipment)
    self.bLock = mapEquipment.Lock

    self:UpdateAffix(mapEquipment.Attributes)
    self:UpdateAlterAffix(mapEquipment.AlterAttributes)
end

function EquipmentData:UpdateAffix(tbAttributes)
    self.tbAffix = tbAttributes
    self:UpdateRandomAttr(self.tbAffix)
end

function EquipmentData:UpdateAlterAffix(tbAttributes)
    self.tbAlterAffix = tbAttributes
end

function EquipmentData:ReplaceRandomAttr()
    if not self.tbAlterAffix or next(self.tbAlterAffix) == nil then
        return
    end
    self.tbAffix = clone(self.tbAlterAffix)
    for k, _ in ipairs(self.tbAlterAffix) do
        self.tbAlterAffix[k] = 0
    end
    self:UpdateRandomAttr(self.tbAffix)
end

-- 更新随机属性
function EquipmentData:UpdateRandomAttr(mapAttrs)
    self.tbPotentialAffix = {}
    self.tbSkillAffix = {}
    self.tbRandomAttr = {}
    self.tbEffect = {}
    for _, v in ipairs(mapAttrs) do
        if v > 0 then
            local mapCfg = ConfigTable.GetData("CharGemAttrValue", v)
            if mapCfg then
                if mapCfg.AttrType == GameEnum.CharGemEffectType.Potential then
                    table.insert(self.tbPotentialAffix, mapCfg)
                elseif mapCfg.AttrType == GameEnum.CharGemEffectType.SkillLevel then
                    table.insert(self.tbSkillAffix, mapCfg)
                elseif mapCfg.AttrType == GameEnum.effectType.ATTR_FIX or mapCfg.AttrType == GameEnum.effectType.PLAYER_ATTR_FIX then
                    if mapCfg.AttrTypeSecondSubtype == GameEnum.parameterType.BASE_VALUE then
                        local value = tonumber(mapCfg.Value) or 0 -- 这张表配的属性数值是string类型，里面的值没有百分比相关（intfloat）的区分处理
                        local mapData = {
                            AttrId = v,
                            Value = value,
                            CfgValue = value / ConfigData.IntFloatPrecision -- 配置值要全乘10000，百分比的类型判断在具体加数值的地方的AddAttrEffect_AllEffectSub处理，会把非intfloat类型的数组再除10000
                        }
                        table.insert(self.tbRandomAttr, mapData)
                    else
                        table.insert(self.tbEffect, mapCfg.EffectId) -- 除基础值外走effect
                    end
                end
            end
        end
    end
end

function EquipmentData:UpdateLockState(bLock)
    self.bLock = bLock
end

function EquipmentData:GetEnhancedPotential()
    local tbPotential = {}
    for _, v in ipairs(self.tbPotentialAffix) do
        local nPotentialId = UTILS.GetPotentialId(self.nCharId, v.AttrTypeFirstSubtype)
        if not tbPotential[nPotentialId] then
            tbPotential[nPotentialId] = 0
        end
        tbPotential[nPotentialId] = tbPotential[nPotentialId] + tonumber(v.Value)
    end
    return tbPotential
end

function EquipmentData:GetEnhancedSkill()
    local tbSkillId = PlayerData.Char:GetSkillIds(self.nCharId)
    local tbSkill = {}
    for _, v in ipairs(self.tbSkillAffix) do
        local nSkillId = tbSkillId[v.AttrTypeFirstSubtype]
        if not tbSkill[nSkillId] then
            tbSkill[nSkillId] = 0
        end
        tbSkill[nSkillId] = tbSkill[nSkillId] + tonumber(v.Value)
    end
    return tbSkill
end

function EquipmentData:GetRandomAttr()
    return self.tbRandomAttr
end

function EquipmentData:GetEffect()
    return self.tbEffect
end

function EquipmentData:CheckAlterEmpty()
    if not self.tbAlterAffix or next(self.tbAlterAffix) == nil then
        return true
    end
    for _, v in pairs(self.tbAlterAffix) do
        if v == 0 then
            return true
        end
    end
    return false
end

function EquipmentData:GetTypeDesc()
    local sLanguage = AllEnum.EquipmentType[self.nType].Language
    return ConfigTable.GetUIText(sLanguage)
end

function EquipmentData:GetTypeIcon()
    return AllEnum.EquipmentType[self.nType].Icon
end

function EquipmentData:GetEffectDescId(attrSybType1, attrSybType2)
    return GameEnum.effectType.ATTR_FIX * 10000 + attrSybType1 * 10 + attrSybType2
end

return EquipmentData
