local MonsterRelevant = {}

--不击杀指定怪物时击杀指定怪物
function MonsterRelevant.CheckKillMonsterWithoutKillSpecifiedMonster(mapAchievementData,AchievementDataDic)
    for _, nMonsterId in ipairs(mapAchievementData.ClientCompleteParams1) do
        for nCharId, mapKillDic in pairs(AchievementDataDic.killDataDic) do
            if mapKillDic:ContainsKey(nMonsterId) then
                return 0
            end
        end
    end
    for _, nMonsterId in ipairs(mapAchievementData.ClientCompleteParams2) do
        for nCharId, mapKillDic in pairs(AchievementDataDic.killDataDic) do
            if mapKillDic:ContainsKey(nMonsterId) then
                return 1
            end
        end
    end
    return 0
end
--一次攻击击杀怪物数量
function MonsterRelevant.CheckKillMonsterWithOneAttack(mapAchievementData,AchievementDataDic)
    local nTarget = mapAchievementData.ClientCompleteParams1[1]
    local nTargetChar = mapAchievementData.ClientCompleteParams2[1]
    for nCharId, nCount in pairs(AchievementDataDic.OnceSkillKillCountDic) do
        if #nTargetChar == 0 or table.indexof(nTargetChar,nCharId) > 0 then
            if nCount > nTarget then
                return 1
            end
        end
    end
    return 0
end
--累计消灭X个Y级别的怪物
function MonsterRelevant.KillMonsterClass(mapAchievementData,AchievementDataDic)
    local nCount = 0
    local tbTarget = mapAchievementData.ClientCompleteParams1
    local tbTargetChar = mapAchievementData.ClientCompleteParams2
    for nCharId, mapKillDic in pairs(AchievementDataDic.killDataDic) do
        if #tbTargetChar == 0 or table.indexof(tbTargetChar,nCharId) > 0 then
            for nMonsterId, nKillCount in pairs(mapKillDic) do
                local mapMonsterCfg = ConfigTable.GetData("Monster",nMonsterId)
                if mapMonsterCfg ~= nil then
                    if table.indexof(tbTarget,mapMonsterCfg.EpicLv) > 0 then
                        nCount = nCount + nKillCount
                    end
                end
            end
        end
    end
    return nCount
end
--累计击杀X只带有TAG[Y]的怪物(Client)
function MonsterRelevant.KillMonsterWithTag(mapAchievementData,AchievementDataDic)
    local nCount = 0
    local nTargetChar = mapAchievementData.ClientCompleteParams1
    local tbTarget = mapAchievementData.ClientCompleteParams3
    if tbTarget == nil then
        return 0
    end
    for nCharId, mapKillDic in pairs(AchievementDataDic.killDataDic) do
        if #nTargetChar == 0 or table.indexof(nTargetChar,nCharId) > 0 then
            for nMonsterId, nKillCount in pairs(mapKillDic) do
                local mapMonsterCfg = ConfigTable.GetData("Monster",nMonsterId)
                if mapMonsterCfg ~= nil then
                    if table.indexof(mapMonsterCfg.Tag1,tbTarget) > 0 then
                        nCount = nCount + nKillCount
                    elseif table.indexof(mapMonsterCfg.Tag2,tbTarget) > 0 then
                        nCount = nCount + nKillCount
                    elseif table.indexof(mapMonsterCfg.Tag3,tbTarget) > 0 then
                        nCount = nCount + nKillCount
                    elseif table.indexof(mapMonsterCfg.Tag4,tbTarget) > 0 then
                        nCount = nCount + nKillCount
                    elseif table.indexof(mapMonsterCfg.Tag5,tbTarget) > 0 then
                        nCount = nCount + nKillCount
                    end
                end
            end
        end
    end
    return nCount
end
--累计击杀X只skin为Y的怪物(Client)
function MonsterRelevant.KillMonsterWithSkin(mapAchievementData,AchievementDataDic)
    local nCount = 0
    local tbTargetSkin = mapAchievementData.ClientCompleteParams1
    if tbTargetSkin == nil then
        return 0
    end
    for _, mapKillDic in pairs(AchievementDataDic.killDataDic) do
        if #tbTargetSkin > 0 then
            for nMonsterId, nKillCount in pairs(mapKillDic) do
                local mapMonsterCfg = ConfigTable.GetData("Monster",nMonsterId)
                if mapMonsterCfg ~= nil then
                    local nFAId = mapMonsterCfg.FAId
                    if table.indexof(tbTargetSkin,nFAId) > 0 then
                        nCount = nCount + nKillCount
                    end
                end
            end
        end
    end
    return nCount
end
return MonsterRelevant