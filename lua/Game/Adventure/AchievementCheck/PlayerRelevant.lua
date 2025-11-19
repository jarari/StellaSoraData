local PlayerRelevant = {}
PlayerRelevant.CritCount = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_0 , upvalues : _ENV
  local ret = 0
  for nCharId,nCritCount in ipairs(AchievementDataDic.CritCountData) do
    if #mapAchievementData.ClientCompleteParams1 == 0 or (table.indexof)(mapAchievementData.ClientCompleteParams1, nCharId) > 0 then
      ret = ret + nCritCount
    end
  end
  return ret
end

PlayerRelevant.CastSkillTypeCount = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_1 , upvalues : _ENV
  local nCount = 0
  local tbTarget = mapAchievementData.ClientCompleteParams1
  for nSkillId,nCastCount in pairs(AchievementDataDic.CastSkillData) do
    local mapSkill = (ConfigTable.GetData)("Skill", nSkillId)
    if mapSkill ~= nil and (table.indexof)(tbTarget, mapSkill.Type) > 0 then
      nCount = nCount + nCastCount
    end
  end
  return nCount
end

PlayerRelevant.CastSkillCount = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_2 , upvalues : _ENV
  local nCount = 0
  local tbTarget = mapAchievementData.ClientCompleteParams1
  for nSkillId,nCastCount in pairs(AchievementDataDic.CastSkillData) do
    local mapSkill = (ConfigTable.GetData)("Skill", nSkillId)
    if mapSkill ~= nil and (table.indexof)(tbTarget, mapSkill.Id) > 0 then
      nCount = nCount + nCastCount
    end
  end
  return nCount
end

PlayerRelevant.ExtremDodgeCount = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_3 , upvalues : _ENV
  local ret = 0
  for nCharId,nPrefectDodgeCount in ipairs(AchievementDataDic.PrefectDodgeData) do
    if #mapAchievementData.ClientCompleteParams1 == 0 or (table.indexof)(mapAchievementData.ClientCompleteParams1, nCharId) > 0 then
      ret = ret + nPrefectDodgeCount
    end
  end
  return ret
end

PlayerRelevant.TriggerTagElement = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_4 , upvalues : _ENV
  local nCount = 0
  local tbTarget = mapAchievementData.ClientCompleteParams1
  for nMark,nTriggerCount in pairs(AchievementDataDic.MarkTriggerData) do
    if (table.indexof)(tbTarget, nMark) > 0 then
      nCount = nCount + nTriggerCount
    end
  end
  return nCount
end

PlayerRelevant.OneHitDamage = function(mapAchievementData, AchievementDataDic)
  -- function num : 0_5
  local nTarget = (mapAchievementData.ClientCompleteParams1)[1]
  if nTarget <= AchievementDataDic.MaxDamageValue then
    return 1
  end
  return 0
end

PlayerRelevant.ClearLevelWithHPBelow = function(mapAchievementData, AchievementDataDic, bSuccess)
  -- function num : 0_6
  if not bSuccess then
    return 0
  end
  local nTarget = (mapAchievementData.ClientCompleteParams1)[1]
  local nCurPrec = AchievementDataDic.MainActorHpPrec * 100
  if nCurPrec <= nTarget then
    return 1
  end
  return 0
end

return PlayerRelevant

