local MonsterRelevant = {}
MonsterRelevant.CheckKillMonsterWithoutKillSpecifiedMonster = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_0 , upvalues : _ENV
  for _,nMonsterId in ipairs(mapAchievementData.ClientCompleteParams1) do
    for nCharId,mapKillDic in pairs(AchievementDataDic.killDataDic) do
      if mapKillDic:ContainsKey(nMonsterId) then
        return 0
      end
    end
  end
  for _,nMonsterId in ipairs(mapAchievementData.ClientCompleteParams2) do
    for nCharId,mapKillDic in pairs(AchievementDataDic.killDataDic) do
      if mapKillDic:ContainsKey(nMonsterId) then
        return 1
      end
    end
  end
  return 0
end

MonsterRelevant.CheckKillMonsterWithOneAttack = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_1 , upvalues : _ENV
  local nTarget = (mapAchievementData.ClientCompleteParams1)[1]
  local nTargetChar = (mapAchievementData.ClientCompleteParams2)[1]
  for nCharId,nCount in pairs(AchievementDataDic.OnceSkillKillCountDic) do
    if (#nTargetChar == 0 or (table.indexof)(nTargetChar, nCharId) > 0) and nTarget < nCount then
      return 1
    end
  end
  return 0
end

MonsterRelevant.KillMonsterClass = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_2 , upvalues : _ENV
  local nCount = 0
  local tbTarget = mapAchievementData.ClientCompleteParams1
  local tbTargetChar = mapAchievementData.ClientCompleteParams2
  for nCharId,mapKillDic in pairs(AchievementDataDic.killDataDic) do
    if #tbTargetChar == 0 or (table.indexof)(tbTargetChar, nCharId) > 0 then
      for nMonsterId,nKillCount in pairs(mapKillDic) do
        local mapMonsterCfg = (ConfigTable.GetData)("Monster", nMonsterId)
        if mapMonsterCfg ~= nil and (table.indexof)(tbTarget, mapMonsterCfg.EpicLv) > 0 then
          nCount = nCount + nKillCount
        end
      end
    end
  end
  return nCount
end

MonsterRelevant.KillMonsterWithTag = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_3 , upvalues : _ENV
  local nCount = 0
  local nTargetChar = mapAchievementData.ClientCompleteParams1
  local tbTarget = mapAchievementData.ClientCompleteParams3
  if tbTarget == nil then
    return 0
  end
  for nCharId,mapKillDic in pairs(AchievementDataDic.killDataDic) do
    if #nTargetChar == 0 or (table.indexof)(nTargetChar, nCharId) > 0 then
      for nMonsterId,nKillCount in pairs(mapKillDic) do
        local mapMonsterCfg = (ConfigTable.GetData)("Monster", nMonsterId)
        if mapMonsterCfg ~= nil then
          if (table.indexof)(mapMonsterCfg.Tag1, tbTarget) > 0 then
            nCount = nCount + nKillCount
          else
            if (table.indexof)(mapMonsterCfg.Tag2, tbTarget) > 0 then
              nCount = nCount + nKillCount
            else
              if (table.indexof)(mapMonsterCfg.Tag3, tbTarget) > 0 then
                nCount = nCount + nKillCount
              else
                if (table.indexof)(mapMonsterCfg.Tag4, tbTarget) > 0 then
                  nCount = nCount + nKillCount
                else
                  if (table.indexof)(mapMonsterCfg.Tag5, tbTarget) > 0 then
                    nCount = nCount + nKillCount
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  return nCount
end

MonsterRelevant.KillMonsterWithSkin = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_4 , upvalues : _ENV
  local nCount = 0
  local tbTargetSkin = mapAchievementData.ClientCompleteParams1
  if tbTargetSkin == nil then
    return 0
  end
  for _,mapKillDic in pairs(AchievementDataDic.killDataDic) do
    if #tbTargetSkin > 0 then
      for nMonsterId,nKillCount in pairs(mapKillDic) do
        local mapMonsterCfg = (ConfigTable.GetData)("Monster", nMonsterId)
        if mapMonsterCfg ~= nil then
          local nFAId = mapMonsterCfg.FAId
          if (table.indexof)(tbTargetSkin, nFAId) > 0 then
            nCount = nCount + nKillCount
          end
        end
      end
    end
  end
  return nCount
end

return MonsterRelevant

