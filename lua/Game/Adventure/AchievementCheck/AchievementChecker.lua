local AchievementChecker = {}
local MonsterRelevant = require("Game.Adventure.AchievementCheck.MonsterRelevant")
local SkillsRelevant = require("Game.Adventure.AchievementCheck.SkillsRelevant")
local PlayerRelevant = require("Game.Adventure.AchievementCheck.PlayerRelevant")
AchievementChecker.BattleAchievementCheckFunction = {[(GameEnum.questCompleteCondClient).KillMonsterWithoutHitBySkill] = SkillsRelevant.KillMonsterWithoutHitBySkill, [(GameEnum.questCompleteCondClient).KillMonsterWithoutKillSpecifiedMonster] = MonsterRelevant.CheckKillMonsterWithoutKillSpecifiedMonster, [(GameEnum.questCompleteCondClient).KillMonsterWithOneAttack] = MonsterRelevant.CheckKillMonsterWithOneAttack, [(GameEnum.questCompleteCondClient).CritCount] = PlayerRelevant.CritCount, [(GameEnum.questCompleteCondClient).CastSkillTypeCount] = PlayerRelevant.CastSkillTypeCount, [(GameEnum.questCompleteCondClient).CastSkillCount] = PlayerRelevant.CastSkillCount, [(GameEnum.questCompleteCondClient).ExtremDodgeCount] = PlayerRelevant.ExtremDodgeCount, [(GameEnum.questCompleteCondClient).KillMonsterClass] = MonsterRelevant.KillMonsterClass, [(GameEnum.questCompleteCondClient).TriggerTagElement] = PlayerRelevant.TriggerTagElement, [(GameEnum.questCompleteCondClient).OneHitDamage] = PlayerRelevant.OneHitDamage, [(GameEnum.questCompleteCondClient).ClearLevelWithHPBelow] = PlayerRelevant.ClearLevelWithHPBelow, [(GameEnum.questCompleteCondClient).KillMonsterWithTag] = MonsterRelevant.KillMonsterWithTag, [(GameEnum.questCompleteCondClient).KillMonsterWithSkin] = MonsterRelevant.KillMonsterWithSkin}
AchievementChecker.CheckBattleAchievement = function(self, tbAchievementId, tbRet, bBattleSuccess)
  -- function num : 0_0 , upvalues : _ENV
  local battleData = (NovaAPI.GetAchievementData)()
  if battleData == nil then
    printError("成就战斗数据null")
    return 
  end
  for _,nAchievementId in ipairs(tbAchievementId) do
    local mapAchievementData = (ConfigTable.GetData)("Achievement", nAchievementId)
    if mapAchievementData == nil then
      printError("成就数据不存在：" .. nAchievementId)
      return 
    end
    if mapAchievementData.CompleteCondClient > 999 then
      local bHasValue, nCount = (battleData.specialBattleData):TryGetValue(mapAchievementData.CompleteCondClient)
      print("Check Special Battle Achievement:" .. nAchievementId .. " Type:" .. mapAchievementData.CompleteCondClient)
      if bHasValue and nCount > 0 then
        print("Add Special Battle Achievement:" .. nAchievementId .. " Type:" .. mapAchievementData.CompleteCondClient .. " Count:" .. nCount)
        ;
        (table.insert)(tbRet, {
Data = {nCount, nAchievementId}
, Id = (GameEnum.eventTypes).eClient})
      end
    else
      do
        if (self.BattleAchievementCheckFunction)[mapAchievementData.CompleteCondClient] == nil then
          printError("成就检测方法未绑定：" .. mapAchievementData.CompleteCondClient)
          return 
        end
        do
          local nCount = ((self.BattleAchievementCheckFunction)[mapAchievementData.CompleteCondClient])(mapAchievementData, battleData, bBattleSuccess)
          if nCount > 0 then
            print((string.format)("成就%d完成", nAchievementId))
            ;
            (table.insert)(tbRet, {
Data = {nCount, nAchievementId}
, Id = (GameEnum.eventTypes).eClient})
          end
          -- DECOMPILER ERROR at PC109: LeaveBlock: unexpected jumping out DO_STMT

          -- DECOMPILER ERROR at PC109: LeaveBlock: unexpected jumping out IF_ELSE_STMT

          -- DECOMPILER ERROR at PC109: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
end

return AchievementChecker

