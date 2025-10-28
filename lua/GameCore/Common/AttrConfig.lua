local AttrConfig = {}

local CharAttrList =
{
    Hp               = { sKey = "Hp", nConfigType = AllEnum.CharConfigType.Attr, bDifferentiate = true, bAllEffectSub = true },
    Atk              = { sKey = "Atk", nConfigType = AllEnum.CharConfigType.Attr, bDifferentiate = true, bAllEffectSub = true },
    Def              = { sKey = "Def", nConfigType = AllEnum.CharConfigType.Attr, bDifferentiate = true, bAllEffectSub = true },
    CritRate         = { sKey = "CritRate", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true, bDifferentiate = true },
    CritPower        = { sKey = "CritPower", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true, bDifferentiate = true },
    Suppress         = { sKey = "Suppress", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },

    UltraEnergy      = { sKey = "UltraEnergy", nConfigType = AllEnum.CharConfigType.Skill, bIntFloat = true },
    EnergyEfficiency = { sKey = "EnergyEfficiency", nConfigType = AllEnum.CharConfigType.Char, bIntFloat = true, bPercent = true },
    EnergyConvRatio  = { sKey = "EnergyConvRatio", nConfigType = AllEnum.CharConfigType.Char, bIntFloat = true, bPercent = true },

    DefPierce        = { sKey = "DefPierce", nConfigType = AllEnum.CharConfigType.Attr },
    DefIgnore        = { sKey = "DefIgnore", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },

    WEE              = { sKey = "WEE", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },
    WEP              = { sKey = "WEP", nConfigType = AllEnum.CharConfigType.Attr },
    WEI              = { sKey = "WEI", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },

    FEE              = { sKey = "FEE", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },
    FEP              = { sKey = "FEP", nConfigType = AllEnum.CharConfigType.Attr },
    FEI              = { sKey = "FEI", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },

    SEE              = { sKey = "SEE", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },
    SEP              = { sKey = "SEP", nConfigType = AllEnum.CharConfigType.Attr },
    SEI              = { sKey = "SEI", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },

    AEE              = { sKey = "AEE", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },
    AEP              = { sKey = "AEP", nConfigType = AllEnum.CharConfigType.Attr },
    AEI              = { sKey = "AEI", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },

    LEE              = { sKey = "LEE", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },
    LEP              = { sKey = "LEP", nConfigType = AllEnum.CharConfigType.Attr },
    LEI              = { sKey = "LEI", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },

    DEE              = { sKey = "DEE", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },
    DEP              = { sKey = "DEP", nConfigType = AllEnum.CharConfigType.Attr },
    DEI              = { sKey = "DEI", nConfigType = AllEnum.CharConfigType.Attr, bIntFloat = true, bPercent = true },

    AtkSpd           = { sKey = "AtkSpd", nConfigType = AllEnum.CharConfigType.Char, bIntFloat = true, bPercent = true },
    WER              = { sKey = "WER", nConfigType = AllEnum.CharConfigType.Attr },
    SER              = { sKey = "SER", nConfigType = AllEnum.CharConfigType.Attr },
    AER              = { sKey = "AER", nConfigType = AllEnum.CharConfigType.Attr },
    FER              = { sKey = "FER", nConfigType = AllEnum.CharConfigType.Attr },
    LER              = { sKey = "LER", nConfigType = AllEnum.CharConfigType.Attr },
    DER              = { sKey = "DER", nConfigType = AllEnum.CharConfigType.Attr },

    WEERCD           = { sKey = "WEERCD", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    FEERCD           = { sKey = "FEERCD", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    SEERCD           = { sKey = "SEERCD", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    AEERCD           = { sKey = "AEERCD", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    LEERCD           = { sKey = "LEERCD", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    DEERCD           = { sKey = "DEERCD", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    GENDMGRCD        = { sKey = "GENDMGRCD", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    DMGPLUSRCD       = { sKey = "DMGPLUSRCD", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },

    NORMALDMG        = { sKey = "NORMALDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    SKILLDMG         = { sKey = "SKILLDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    ULTRADMG         = { sKey = "ULTRADMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    OTHERDMG         = { sKey = "OTHERDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true }, 
    MARKDMG          = { sKey = "MARKDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },

    RCDNORMALDMG     = { sKey = "RCDNORMALDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    RCDSKILLDMG      = { sKey = "RCDSKILLDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    RCDULTRADMG      = { sKey = "RCDULTRADMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    RCDOTHERDMG      = { sKey = "RCDOTHERDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    RCDMARKDMG       = { sKey = "RCDMARKDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },

    GENDMG           = { sKey = "GENDMG", nConfigType = AllEnum.CharConfigType.Attr },
    DMGPLUS          = { sKey = "DMGPLUS", nConfigType = AllEnum.CharConfigType.Attr },
    FINALDMG         = { sKey = "FINALDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },
    FINALDMGPLUS     = { sKey = "FINALDMGPLUS", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true },

    SUMMONDMG        = {sKey = "SUMMONDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    RCDSUMMONDMG     = {sKey = "RCDSUMMONDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    PROJECTILEDMG    = {sKey = "PROJECTILEDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    RCDPROJECTILEDMG = {sKey = "RCDPROJECTILEDMG", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},

    NormalCritRate   = {sKey = "NormalCritRate", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    SkillCritRate   = {sKey = "SkillCritRate", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    UltraCritRate   = {sKey = "UltraCritRate", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    MarkCritRate   = {sKey = "MarkCritRate", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    SummonCritRate   = {sKey = "SummonCritRate", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    ProjectileCritRate   = {sKey = "ProjectileCritRate", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    OtherCritRate   = {sKey = "OtherCritRate", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    

    NormalCritPower  = {sKey = "NormalCritPower", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    SkillCritPower   = {sKey = "SkillCritPower", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    UltraCritPower   = {sKey = "UltraCritPower", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    SummonCritPower  = {sKey = "SummonCritPower", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    MarkCritPower    = {sKey = "MarkCritPower", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    OtherCritPower   = {sKey = "OtherCritPower", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
    ProjectileCritPower = {sKey = "ProjectileCritPower", nConfigType = AllEnum.CharConfigType.Attr, bPercent = true},
}

local EffectTypeToAttr =
{
    [GameEnum.effectType.ATTR_FIX] = {
        --- 攻击力
        [GameEnum.effectAttributeType.ATK] = CharAttrList.Atk,
        --- 防御力
        [GameEnum.effectAttributeType.DEF] = CharAttrList.Def,
        --- 生命上限
        [GameEnum.effectAttributeType.MAXHP] = CharAttrList.Hp,
        --- 命中
        [GameEnum.effectAttributeType.HITRATE] = nil,
        --- 回避
        [GameEnum.effectAttributeType.EVD] = nil,
        --- 暴击
        [GameEnum.effectAttributeType.CRITRATE] = CharAttrList.CritRate,
        --- 暴击抵抗
        [GameEnum.effectAttributeType.CRITRESIST] = nil,
        --- 暴击伤害
        [GameEnum.effectAttributeType.CRITPOWER_P] = CharAttrList.CritPower,
        --- 防御穿透
        [GameEnum.effectAttributeType.PENETRATE] = CharAttrList.DefPierce,
        --- 无视防御
        [GameEnum.effectAttributeType.DEF_IGNORE] = CharAttrList.DefIgnore,
        --- 水系抗性
        [GameEnum.effectAttributeType.WER] = CharAttrList.WER,
        --- 火系抗性
        [GameEnum.effectAttributeType.FER] = CharAttrList.FER,
        --- 地系抗性
        [GameEnum.effectAttributeType.SER] = CharAttrList.SER,
        --- 风系抗性
        [GameEnum.effectAttributeType.AER] = CharAttrList.AER,
        --- 光系抗性
        [GameEnum.effectAttributeType.LER] = CharAttrList.LER,
        --- 暗系抗性
        [GameEnum.effectAttributeType.DER] = CharAttrList.DER,
        --- 水系伤害
        [GameEnum.effectAttributeType.WEE] = CharAttrList.WEE,
        --- 火系伤害
        [GameEnum.effectAttributeType.FEE] = CharAttrList.FEE,
        --- 地系伤害
        [GameEnum.effectAttributeType.SEE] = CharAttrList.SEE,
        --- 风系伤害
        [GameEnum.effectAttributeType.AEE] = CharAttrList.AEE,
        --- 光系伤害
        [GameEnum.effectAttributeType.LEE] = CharAttrList.LEE,
        --- 暗系伤害
        [GameEnum.effectAttributeType.DEE] = CharAttrList.DEE,
        --- 水系穿透
        [GameEnum.effectAttributeType.WEP] = CharAttrList.WEP,
        --- 火系穿透
        [GameEnum.effectAttributeType.FEP] = CharAttrList.FEP,
        --- 地系穿透
        [GameEnum.effectAttributeType.SEP] = CharAttrList.SEP,
        --- 风系穿透
        [GameEnum.effectAttributeType.AEP] = CharAttrList.AEP,
        --- 光系穿透
        [GameEnum.effectAttributeType.LEP] = CharAttrList.LEP,
        --- 暗系穿透
        [GameEnum.effectAttributeType.DEP] = CharAttrList.DEP,
        --- 无视水系伤害
        [GameEnum.effectAttributeType.WEI] = CharAttrList.WEI,
        --- 无视火系伤害
        [GameEnum.effectAttributeType.FEI] = CharAttrList.FEI,
        --- 无视地系伤害
        [GameEnum.effectAttributeType.SEI] = CharAttrList.SEI,
        --- 无视风系伤害
        [GameEnum.effectAttributeType.AEI] = CharAttrList.AEI,
        --- 无视光系伤害
        [GameEnum.effectAttributeType.LEI] = CharAttrList.LEI,
        --- 无视暗系伤害
        [GameEnum.effectAttributeType.DEI] = CharAttrList.DEI,
        --- 受到水系伤害
        [GameEnum.effectAttributeType.WEERCD] = CharAttrList.WEERCD,
        --- 受到火系伤害
        [GameEnum.effectAttributeType.FEERCD] = CharAttrList.FEERCD,
        --- 受到地系伤害
        [GameEnum.effectAttributeType.SEERCD] = CharAttrList.SEERCD,
        --- 受到风系伤害
        [GameEnum.effectAttributeType.AEERCD] = CharAttrList.AEERCD,
        --- 受到光系伤害
        [GameEnum.effectAttributeType.LEERCD] = CharAttrList.LEERCD,
        --- 受到暗系伤害
        [GameEnum.effectAttributeType.DEERCD] = CharAttrList.DEERCD,
        --- 重量
        [GameEnum.effectAttributeType.WEIGHT] = nil,
        --- 最大韧性
        [GameEnum.effectAttributeType.TOUGHNESS_MAX] = nil,
        --- 破韧效率
        [GameEnum.effectAttributeType.TOUGHNESS_DAMAGE_ADJUST] = nil,
        --- 护盾上限
        [GameEnum.effectAttributeType.SHIELD_MAX] = nil,
        --- 护盾穿透
        [GameEnum.effectAttributeType.SHIELD_MAX] = nil,
        --- 移动速度
        [GameEnum.effectAttributeType.MOVESPEED] = nil,
        --- 攻击速度
        [GameEnum.effectAttributeType.ATKSPD_P] = CharAttrList.AtkSpd,
        --- 强度
        [GameEnum.effectAttributeType.INTENSITY] = nil,
        --- 造成伤害
        [GameEnum.effectAttributeType.GENDMG] = CharAttrList.GENDMG,
        --- 伤害值
        [GameEnum.effectAttributeType.DMGPLUS] = CharAttrList.DMGPLUS,
        --- 最终伤害
        [GameEnum.effectAttributeType.FINALDMG] = CharAttrList.FINALDMG,
        --- 最终伤害值
        [GameEnum.effectAttributeType.FINALDMGPLUS] = CharAttrList.FINALDMGPLUS,
        --- 受到所有伤害
        [GameEnum.effectAttributeType.GENDMGRCD] = CharAttrList.GENDMGRCD,
        --- 受到伤害
        [GameEnum.effectAttributeType.DMGPLUSRCD] = nil,
        --- 弱点压制
        [GameEnum.effectAttributeType.SUPPRESS] = CharAttrList.Suppress,
        --- 普攻伤害
        [GameEnum.effectAttributeType.NORMALDMG] = CharAttrList.NORMALDMG,
        --- 技能伤害
        [GameEnum.effectAttributeType.SKILLDMG] = CharAttrList.SKILLDMG,
        --- 绝招伤害
        [GameEnum.effectAttributeType.ULTRADMG] = CharAttrList.ULTRADMG,
        --- 其他伤害
        [GameEnum.effectAttributeType.OTHERDMG] = CharAttrList.OTHERDMG,
        --- 受到普攻伤害
        [GameEnum.effectAttributeType.RCDNORMALDMG] = CharAttrList.RCDNORMALDMG,
        --- 受到技能伤害
        [GameEnum.effectAttributeType.RCDSKILLDMG] = CharAttrList.RCDSKILLDMG,
        --- 受到绝招伤害
        [GameEnum.effectAttributeType.RCDULTRADMG] = CharAttrList.RCDULTRADMG,
        --- 受到其他伤害
        [GameEnum.effectAttributeType.RCDOTHERDMG] = CharAttrList.RCDOTHERDMG,
        --- 印记伤害
        [GameEnum.effectAttributeType.MARKDMG] = CharAttrList.MARKDMG,
        --- 受到印记伤害
        [GameEnum.effectAttributeType.RCDMARKDMG] = CharAttrList.RCDMARKDMG,
        --- 仆从伤害
        [GameEnum.effectAttributeType.SUMMONDMG] = CharAttrList.SUMMONDMG,
        --- 受到仆从伤害
        [GameEnum.effectAttributeType.RCDSUMMONDMG] = CharAttrList.RCDSUMMONDMG,
        --- 衍生物伤害
        [GameEnum.effectAttributeType.PROJECTILEDMG] = CharAttrList.PROJECTILEDMG,
        --- 受到衍生物伤害
        [GameEnum.effectAttributeType.RCDPROJECTILEDMG] = CharAttrList.RCDPROJECTILEDMG,
        --- 普攻暴击
        [GameEnum.effectAttributeType.NORMALCRITRATE] = CharAttrList.NormalCritRate,
        --- 技能暴击
        [GameEnum.effectAttributeType.SKILLCRITRATE] = CharAttrList.SkillCritRate,
        --- 绝招暴击
        [GameEnum.effectAttributeType.ULTRACRITRATE] = CharAttrList.UltraCritRate,
        --- 印记暴击
        [GameEnum.effectAttributeType.MARKCRITRATE] = CharAttrList.MarkCritRate,
        --- 仆从暴击
        [GameEnum.effectAttributeType.SUMMONCRITRATE] = CharAttrList.SummonCritRate,
        --- 衍生物暴击
        [GameEnum.effectAttributeType.PROJECTILECRITRATE] = CharAttrList.ProjectileCritRate,
        --- 其他暴击
        [GameEnum.effectAttributeType.OTHERCRITRATE] = CharAttrList.OtherCritRate,
        --- 普攻暴击伤害
        [GameEnum.effectAttributeType.NORMALCRITPOWER] = CharAttrList.NormalCritPower,
        --- 技能暴击伤害
        [GameEnum.effectAttributeType.SKILLCRITPOWER] = CharAttrList.SkillCritPower,
        --- 绝招暴击伤害
        [GameEnum.effectAttributeType.ULTRACRITPOWER] = CharAttrList.UltraCritPower,
        --- 印记暴击伤害
        [GameEnum.effectAttributeType.MARKCRITPOWER] = CharAttrList.MarkCritPower,
        --- 仆从暴击伤害
        [GameEnum.effectAttributeType.SUMMONCRITPOWER] = CharAttrList.SummonCritPower,
        --- 衍生物暴击伤害
        [GameEnum.effectAttributeType.PROJECTILECRITPOWER] = CharAttrList.ProjectileCritPower,
        --- 其他暴击伤害
        [GameEnum.effectAttributeType.OTHERCRITPOWER] = CharAttrList.OtherCritPower,
        --- 能量上限
        [GameEnum.effectAttributeType.ENERGY_MAX] = nil,
    },

    [GameEnum.effectType.PLAYER_ATTR_FIX] = {
        [GameEnum.playerAttributeType.FRONT_ADD_ENERGY] = CharAttrList.EnergyEfficiency,
        [GameEnum.playerAttributeType.ADD_ENERGY] = CharAttrList.EnergyConvRatio,
    }
}

function AttrConfig.GetAttrByEffectType(nEffectType, nEffectSubType)
    return EffectTypeToAttr[nEffectType][nEffectSubType]
end

function AttrConfig.GetCharAttrList()
    return CharAttrList
end

return AttrConfig