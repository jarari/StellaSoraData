local CharacterAttrData = class("CharacterAttrData")
local ConfigData = require "GameCore.Data.ConfigData"
local AttrConfig = require "GameCore.Common.AttrConfig"

---@diagnostic disable-next-line: duplicate-set-field
function CharacterAttrData:ctor(nId, mapCustom)
    self.nId    = nId -- 角色Id

    self.tbAttr = {}
    self.CharAttrList = AttrConfig.GetCharAttrList()
    for _, v in pairs(self.CharAttrList) do
        if v.bAllEffectSub then
            self.tbAttr["_" .. v.sKey] = nil                   -- 基础值
            self.tbAttr["_" .. v.sKey .. "PercentAmend"] = nil -- 百分比修正
            self.tbAttr["_" .. v.sKey .. "Amend"] = nil        -- 绝对值修正
        else
            self.tbAttr["_origin" .. v.sKey] = nil             -- 原始值
        end

        self.tbAttr[v.sKey] = nil           -- 最终值
        self.tbAttr["base" .. v.sKey] = nil -- 白值
    end

    self.eetType  = nil        -- 角色元素专精类型
    self.eet      = nil        -- 角色元素专精(本角色对应元素)
    self.baseEET  = nil        -- 角色白字元素专精(本角色对应元素)

    self.attrList = nil        -- 角色属性列表, 与AllEnum.CharAttr顺序对应
    self:ParseConfig(mapCustom)
end

function CharacterAttrData:ParseConfig(mapCustom)
    if not self.nId then
        return
    end
    local config = ConfigTable.GetData_Character(self.nId)
    if not config then
        return
    end
    local mapChar
    if mapCustom == nil then
    	mapChar = PlayerData.Char:GetCharDataByTid(self.nId)
    else
        mapChar = mapCustom.mapChar
    end
    local nAttributeId = UTILS.GetCharacterAttributeId(tonumber(config.AttributeId), mapChar.nAdvance, mapChar.nLevel)
    local attrConfig = ConfigTable.GetData_Attribute(tostring(nAttributeId))
    if not attrConfig then
        printError("角色表属性id配置不对，角色" .. self.nId)
        return
    end
    local skillConfig = ConfigTable.GetData_Skill(config.UltimateId)
    if not skillConfig then
        printError("角色Skill表大招没配" .. config.UltimateId)
        return
    end

    for _, v in pairs(self.CharAttrList) do
        local mapCfg = attrConfig
        if v.nConfigType == AllEnum.CharConfigType.Attr then
            mapCfg = attrConfig
        elseif v.nConfigType == AllEnum.CharConfigType.Char then
            mapCfg = config
        elseif v.nConfigType == AllEnum.CharConfigType.Skill then
            mapCfg = skillConfig
        end
        local originVale = mapCfg[v.sKey] or 0

        if v.bAllEffectSub then -- 全类型修改的属性目前不会是bIntFloat和bPercent
            self.tbAttr["_" .. v.sKey] = originVale
            self.tbAttr["_" .. v.sKey .. "PercentAmend"] = 0
            self.tbAttr["_" .. v.sKey .. "Amend"] = 0
            self.tbAttr["base" .. v.sKey] = self.tbAttr["_" .. v.sKey]
        else
            self.tbAttr["_origin" .. v.sKey] = v.bIntFloat and originVale * ConfigData.IntFloatPrecision or originVale
            self.tbAttr["base" .. v.sKey] = v.bPercent and self.tbAttr["_origin" .. v.sKey] * 100 or self.tbAttr["_origin" .. v.sKey]
        end

        self.tbAttr[v.sKey] = self.tbAttr["base" .. v.sKey]
    end

    self.eetType = AllEnum.EET[config.EET] -- 通过角色的元素确定对应的元素专精
    self.baseEET = attrConfig[self.eetType] or 0
    self.eet = self.baseEET

    self:AddAttr()
    self:AddEffect(mapCustom)

    self:UpdateAttrList()
end

-- 更换角色
function CharacterAttrData:SetCharacter(nId, mapCustom)
    self.nId = nId
    self:ParseConfig(mapCustom)
end

function CharacterAttrData:AddAttr()
    for _, v in ipairs(AllEnum.AttachAttr) do
        if self.tbAttr["base" .. v.sKey] then
            if self.CharAttrList[v.sKey].bDifferentiate then -- 区分白字绿字的属性
                self.tbAttr["base" .. v.sKey] = self.tbAttr["base" .. v.sKey]
            else -- 都加
                self.tbAttr["base" .. v.sKey] = self.tbAttr["base" .. v.sKey] -- +
            end
        end

        if self.tbAttr["_" .. v.sKey] then
            self.tbAttr["_" .. v.sKey] = self.tbAttr["_" .. v.sKey] -- + 
        end

        if self.tbAttr[v.sKey] and not self.tbAttr["_" .. v.sKey] then -- AllEffectSub全effect计算的属性是后续CalAllEffectSubAttr()算的，不在这里算self.tbAttr[v.sKey]
            self.tbAttr[v.sKey] = self.tbAttr[v.sKey] -- +
        end
    end
end

function CharacterAttrData:AddEffect(mapCustom)
    local tbAllEfts = {}

    if not mapCustom then
        local tbAffinityEfts = PlayerData.Char:GetCharAffinityEffects(self.nId)
        local tbTalentEfts = PlayerData.Talent:GetTalentEffect(self.nId)
        local tbEquipmentEfts = PlayerData.Equipment:GetCharEquipmentEffect(self.nId)
        if tbAffinityEfts then
            for _, value in pairs(tbAffinityEfts) do
                table.insert(tbAllEfts, value)
            end
        end
        if tbTalentEfts then
            for _, value in pairs(tbTalentEfts) do
                table.insert(tbAllEfts, value)
            end
        end
        if tbEquipmentEfts then
            for _, value in pairs(tbEquipmentEfts) do
                table.insert(tbAllEfts, value)
            end
        end
    else
        tbAllEfts = mapCustom.tbEffect or {}
    end

    self:AddAttrEffect(tbAllEfts)
    self:AddEquipmentRandomAttr(mapCustom)
    self:CalAllEffectSubAttr()
end

-- 添加效果
function CharacterAttrData:AddAttrEffect(tbAttrEffect)
    for _, attrEffectId in ipairs(tbAttrEffect) do
        local config = ConfigTable.GetData_Effect(attrEffectId)
        local valueConfig = ConfigTable.GetData("EffectValue", attrEffectId)
        if valueConfig ~= nil and config ~= nil then
            local bAttrFix = valueConfig.EffectType == GameEnum.effectType.ATTR_FIX or valueConfig.EffectType == GameEnum.effectType.PLAYER_ATTR_FIX
            if bAttrFix and config.Trigger == GameEnum.trigger.NOTHING then
                local mapAttr = AttrConfig.GetAttrByEffectType(valueConfig.EffectType, valueConfig.EffectTypeFirstSubtype)
                if mapAttr then
                    if mapAttr.bAllEffectSub then
                        self:AddAttrEffect_AllEffectSub(valueConfig.EffectTypeSecondSubtype, valueConfig.EffectTypeParam1, mapAttr)
                    else
                        self:AddAttrEffect_BaseValue(valueConfig.EffectTypeSecondSubtype, valueConfig.EffectTypeParam1, mapAttr)
                    end
                else
                    local value = tonumber(valueConfig.EffectTypeParam1) or 0
                    if valueConfig.EffectTypeFirstSubtype == self.eetType and valueConfig.EffectTypeSecondSubtype == GameEnum.parameterType.BASE_VALUE then -- 角色自身对应的元素专精和专有元素专精
                        self.baseEET = self.baseEET + value
                        self.eet = self.eet + value
                    end
                end
            end
        end
    end
end

--计算装备随机属性
function CharacterAttrData:AddEquipmentRandomAttr(mapCustom)
    local tbRandomAttr = {}
    if mapCustom then
        tbRandomAttr = mapCustom.tbRandomAttr or {}
    else
        tbRandomAttr = PlayerData.Equipment:GetCharEquipmentRandomAttr(self.nId)
    end

    for nAttrId, v in pairs(tbRandomAttr) do
        local mapAttrCfg = ConfigTable.GetData("CharGemAttrValue", nAttrId)
        if mapAttrCfg then
            local attrType = mapAttrCfg.AttrType       --属性类型
            local attrSubType1 = mapAttrCfg.AttrTypeFirstSubtype  --属性一级子类型
            local attrSubType2 = mapAttrCfg.AttrTypeSecondSubtype  --属性二级子类型

            local bAttrFix = attrType == GameEnum.effectType.ATTR_FIX or attrType == GameEnum.effectType.PLAYER_ATTR_FIX
            if bAttrFix then
                local mapAttr = AttrConfig.GetAttrByEffectType(attrType, attrSubType1)
                if mapAttr then
                    if mapAttr.bAllEffectSub then
                        self:AddAttrEffect_AllEffectSub(attrSubType2, v.Value, mapAttr)
                    else
                        self:AddAttrEffect_BaseValue(attrSubType2, v.Value, mapAttr)
                    end
                else
                    local value = tonumber(v.CfgValue) or 0
                    if attrSubType1 == self.eetType and attrSubType2 == GameEnum.parameterType.BASE_VALUE then -- 角色自身对应的元素专精和专有元素专精
                        self.baseEET = self.baseEET + value
                        self.eet = self.eet + value
                    end
                end
            end
        end
    end
end

function CharacterAttrData:AddAttrEffect_AllEffectSub(nSubType, nValue, mapAttr)
    -- 全类型修改的属性目前都是区分值的，不会改变属性的base
    local value = tonumber(nValue) or 0
    if nSubType == GameEnum.parameterType.PERCENTAGE then
        self.tbAttr["_" .. mapAttr.sKey .. "PercentAmend"] = self.tbAttr["_" .. mapAttr.sKey .. "PercentAmend"] + value * 100
    elseif nSubType == GameEnum.parameterType.ABSOLUTE_VALUE then
        self.tbAttr["_" .. mapAttr.sKey .. "Amend"] = self.tbAttr["_" .. mapAttr.sKey .. "Amend"] + value
    elseif nSubType == GameEnum.parameterType.BASE_VALUE then
        self.tbAttr["_" .. mapAttr.sKey] = self.tbAttr["_" .. mapAttr.sKey] + value
    end
end

function CharacterAttrData:AddAttrEffect_BaseValue(nSubType, nValue, mapAttr)
    local value = tonumber(nValue) or 0
    if nSubType == GameEnum.parameterType.BASE_VALUE then
        local nAdd = mapAttr.bPercent and value * 100 or value
        if not mapAttr.bDifferentiate then
            self.tbAttr["base" .. mapAttr.sKey] = self.tbAttr["base" .. mapAttr.sKey] + nAdd
        end
        self.tbAttr[mapAttr.sKey] = self.tbAttr[mapAttr.sKey] + nAdd
    end
end

function CharacterAttrData:CalAllEffectSubAttr()
    for _, v in pairs(self.CharAttrList) do
        if v.bAllEffectSub then
            self.tbAttr[v.sKey] = (self.tbAttr["_" .. v.sKey] * (1 + self.tbAttr["_" .. v.sKey .. "PercentAmend"] / 100)) + self.tbAttr["_" .. v.sKey .. "Amend"]
            self.tbAttr[v.sKey] = math.floor(self.tbAttr[v.sKey])
        end
    end
end

function CharacterAttrData:UpdateAttrList()
    if not self.attrList then
        self.attrList = {}
    end
    for k, v in pairs(AllEnum.CharAttr) do
        if not self.attrList[k] then
            self.attrList[k] = {}
        end
        self.attrList[k].totalValue, self.attrList[k].baseValue = self.tbAttr[v.sKey], self.tbAttr["base" .. v.sKey]
    end
end

function CharacterAttrData:GetEETType()
    return self.eetType
end

function CharacterAttrData:GetEET()
    return self.eet, self.baseEET
end

function CharacterAttrData:GetAttrList()
    return self.attrList
end

return CharacterAttrData
