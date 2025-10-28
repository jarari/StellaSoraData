local PlayerRelevant = {}

--暴击次数
function PlayerRelevant.CritCount(mapAchievementData,AchievementDataDic)
    local ret = 0
    for nCharId, nCritCount in ipairs(AchievementDataDic.CritCountData) do
        if #mapAchievementData.ClientCompleteParams1 == 0 or table.indexof(mapAchievementData.ClientCompleteParams1,nCharId) > 0 then
            ret = ret  + nCritCount
        end
    end
    return ret
end
--释放技能类型
function PlayerRelevant.CastSkillTypeCount(mapAchievementData,AchievementDataDic)
    local nCount = 0
    local tbTarget = mapAchievementData.ClientCompleteParams1
    for nSkillId, nCastCount in pairs(AchievementDataDic.CastSkillData) do
        local mapSkill = ConfigTable.GetData("Skill",nSkillId)
        if mapSkill ~= nil then
            if table.indexof(tbTarget,mapSkill.Type) > 0 then
                nCount = nCount + nCastCount
            end
        end
    end
    return nCount
end
--释放技能Id
function PlayerRelevant.CastSkillCount(mapAchievementData,AchievementDataDic)
    local nCount = 0
    local tbTarget = mapAchievementData.ClientCompleteParams1
    for nSkillId, nCastCount in pairs(AchievementDataDic.CastSkillData) do
        local mapSkill = ConfigTable.GetData("Skill",nSkillId)
        if mapSkill ~= nil then
            if table.indexof(tbTarget,mapSkill.Id) > 0 then
                nCount = nCount + nCastCount
            end
        end
    end
    return nCount
end
--极限闪避次数
function PlayerRelevant.ExtremDodgeCount(mapAchievementData,AchievementDataDic)
    local ret = 0
    for nCharId, nPrefectDodgeCount in ipairs(AchievementDataDic.PrefectDodgeData) do
        if #mapAchievementData.ClientCompleteParams1 == 0 or table.indexof(mapAchievementData.ClientCompleteParams1,nCharId) > 0 then
            ret = ret  + nPrefectDodgeCount
        end
    end
    return ret
end
--触发印记类型
function PlayerRelevant.TriggerTagElement(mapAchievementData,AchievementDataDic)
    local nCount = 0
    local tbTarget = mapAchievementData.ClientCompleteParams1
    for nMark, nTriggerCount in pairs(AchievementDataDic.MarkTriggerData) do
        if table.indexof(tbTarget,nMark) > 0 then
            nCount = nCount + nTriggerCount
        end
    end
    return nCount
end
--单次伤害
function PlayerRelevant.OneHitDamage(mapAchievementData,AchievementDataDic)
    local nTarget = mapAchievementData.ClientCompleteParams1[1]
    if nTarget <= AchievementDataDic.MaxDamageValue then
        return 1
    end
    return 0
end
--通关时血量低于
function PlayerRelevant.ClearLevelWithHPBelow(mapAchievementData,AchievementDataDic,bSuccess)
    if not bSuccess then
        return 0 
    end
    local nTarget = mapAchievementData.ClientCompleteParams1[1]
    local nCurPrec = AchievementDataDic.MainActorHpPrec * 100
    if nCurPrec <= nTarget then
        return 1
    end
    return 0
end
return PlayerRelevant