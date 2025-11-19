local PlayerStateData = class("PlayerStateData")
PlayerStateData.Init = function(self)
  -- function num : 0_0
  self.tbWorldClassRewardState = {}
  self.tbCharAdvanceRewards = {}
  self.tbCharAffinityReward = {}
  self.bNewAchievement = false
  self.bFriendState = false
  self.bMailOverflow = false
  self.bInStarTowerSweep = false
  self.nVampireId = 0
end

PlayerStateData.CacheStateData = function(self, mapMsgData)
  -- function num : 0_1 , upvalues : _ENV
  if mapMsgData ~= nil then
    self:CacheStarTowerStateData(mapMsgData.StarTower)
    self:CacheCharAdvanceRewardsState(mapMsgData.CharAdvanceRewards)
    self:CacheWorldClassRewardState(mapMsgData.WorldClassReward)
    self:CacheAchievementState((mapMsgData.Achievement).New)
    self:CacheFriendState(mapMsgData)
    ;
    (RedDotManager.SetValid)(RedDotDefine.BattlePass_Quest_Server, nil, (mapMsgData.BattlePass).State == 1 or (mapMsgData.BattlePass).State == 3)
    ;
    (RedDotManager.SetValid)(RedDotDefine.BattlePass_Reward, nil, (mapMsgData.BattlePass).State >= 2)
    ;
    (PlayerData.Mail):UpdateMailRed((mapMsgData.Mail).New)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Mall_Free, nil, (mapMsgData.MallPackage).New)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Friend_Apply, nil, mapMsgData.Friend)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Friend_Energy, nil, (mapMsgData.FriendEnergy).State)
    ;
    (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Affinity, nil, mapMsgData.NpcAffinityReward)
    ;
    (PlayerData.Quest):UpdateServerQuestRedDot(mapMsgData.TravelerDuelQuest)
    ;
    (PlayerData.Quest):UpdateServerQuestRedDot(mapMsgData.TravelerDuelChallengeQuest)
    ;
    (PlayerData.InfinityTower):UpdateBountyRewardState(mapMsgData.InfinityTower)
    ;
    (PlayerData.StarTowerBook):UpdateServerRedDot(mapMsgData.StarTowerBook)
    ;
    (PlayerData.ScoreBoss):UpdateRedDot(mapMsgData.ScoreBoss)
    ;
    (PlayerData.Activity):UpdateActivityState(mapMsgData.Activities)
    ;
    (PlayerData.StorySet):UpdateStorySetState(mapMsgData.StorySet)
    self.nVampireId = mapMsgData.VampireSurvivorId
  else
    self.bMailState = false
  end
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

PlayerStateData.CacheWorldClassRewardState = function(self, WorldClassReward)
  -- function num : 0_2 , upvalues : _ENV
  self.tbWorldClassRewardState = {(string.byte)(WorldClassReward.Flag, 1, -1)}
  ;
  (PlayerData.Base):RefreshWorldClassRedDot()
end

PlayerStateData.CacheWorldClassRewardStateInBoard = function(self, WorldClassReward)
  -- function num : 0_3 , upvalues : _ENV
  if WorldClassReward == nil then
    return 
  end
  self.tbWorldClassRewardState = {(string.byte)(WorldClassReward, 1, -1)}
end

PlayerStateData.CacheAchievementState = function(self, bNew)
  -- function num : 0_4
  self.bNewAchievement = bNew
end

PlayerStateData.CacheFriendState = function(self, mapMsgData)
  -- function num : 0_5
  if not mapMsgData.Friend then
    self.bFriendState = (mapMsgData.FriendEnergy).State
  end
end

PlayerStateData.CacheStarTowerStateData = function(self, mapData)
  -- function num : 0_6
  if mapData ~= nil then
    self.mapStarTowerState = mapData
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R2 in 'UnsetPending'

    if (self.mapStarTowerState).BuildId ~= 0 then
      (self.mapStarTowerState).Id = 0
    end
    -- DECOMPILER ERROR at PC14: Confused about usage of register: R2 in 'UnsetPending'

    if (self.mapStarTowerState).Floor == 0 then
      (self.mapStarTowerState).Floor = 1
    end
  else
    self.mapStarTowerState = {BuildId = 0, Id = 0, Floor = 1, Sweep = false}
  end
end

PlayerStateData.CacheCharAdvanceRewardsState = function(self, CharAdRewards)
  -- function num : 0_7 , upvalues : _ENV
  if CharAdRewards == nil then
    return 
  end
  if CharAdRewards == {} then
    return 
  end
  for _,v in ipairs(CharAdRewards) do
    -- DECOMPILER ERROR at PC19: Confused about usage of register: R7 in 'UnsetPending'

    (self.tbCharAdvanceRewards)[v.CharId] = (string.byte)(v.Flag, 1, -1)
  end
  self:RefreshCharAdvanceRewardRedDot()
end

PlayerStateData.CacheCharactersAdRewards_Notify = function(self, mapMsgData)
  -- function num : 0_8 , upvalues : _ENV
  if mapMsgData == nil then
    return 
  end
  -- DECOMPILER ERROR at PC11: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (self.tbCharAdvanceRewards)[mapMsgData.CharId] = (string.byte)(mapMsgData.Flag, 1, -1)
  self:RefreshCharAdvanceRewardRedDot()
end

PlayerStateData.GetCharAdvanceRewards = function(self, nCharId, nAdvance)
  -- function num : 0_9
  if (self.tbCharAdvanceRewards)[nCharId] >> nAdvance - 1 & 1 ~= 1 then
    do return not (self.tbCharAdvanceRewards)[nCharId] end
    do return false end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end
end

PlayerStateData.GetCanPickedAdvanceRewards = function(self, nCharId, nMaxAdvance)
  -- function num : 0_10
  if (self.tbCharAdvanceRewards)[nCharId] then
    for nIndex = 1, nMaxAdvance do
      if (self.tbCharAdvanceRewards)[nCharId] >> nIndex - 1 & 1 == 1 then
        return nIndex
      end
    end
  else
    do
      do return 0 end
    end
  end
end

PlayerStateData.CheckState = function(self)
  -- function num : 0_11 , upvalues : _ENV
  if (self.mapStarTowerState).BuildId ~= 0 then
    print("正在保存的BuildId" .. (self.mapStarTowerState).BuildId)
    local buildDetailcallback = function(mapBuild)
    -- function num : 0_11_0 , upvalues : _ENV, self
    (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerBuildSave, false, mapBuild)
    -- DECOMPILER ERROR at PC10: Confused about usage of register: R1 in 'UnsetPending'

    ;
    (self.mapStarTowerState).BuildId = 0
  end

    ;
    (PlayerData.Build):GetBuildDetailData(buildDetailcallback, (self.mapStarTowerState).BuildId)
    return true
  end
  do
    return false
  end
end

PlayerStateData.CheckVampireState = function(self, callback)
  -- function num : 0_12 , upvalues : _ENV
  if self.nVampireId > 0 then
    local mapVampireCfgData = (ConfigTable.GetData)("VampireSurvivor", self.nVampireId)
    do
      if mapVampireCfgData == nil then
        if callback ~= nil and type(callback) == "function" then
          callback(false)
        end
        self.nVampireId = 0
        return 
      end
      do
        if mapVampireCfgData.Type == (GameEnum.vampireSurvivorType).Turn then
          local curSeason, nLevel = (PlayerData.VampireSurvivor):GetCurSeason()
          if nLevel ~= self.nVampireId then
            if callback ~= nil and type(callback) == "function" then
              callback(false)
            end
            self.nVampireId = 0
            return 
          end
        end
        local GetDataCallback = function()
    -- function num : 0_12_0 , upvalues : self, _ENV, mapVampireCfgData
    local ConfirmCallback = function()
      -- function num : 0_12_0_0 , upvalues : self, _ENV
      self.nVampireId = 0
      ;
      (PlayerData.VampireSurvivor):ReEnterVampireSurvivor(self.nVampireId)
    end

    local CancelCallback = function()
      -- function num : 0_12_0_1 , upvalues : mapVampireCfgData, _ENV, self
      local netMsgCallback = function(_, msgData)
        -- function num : 0_12_0_1_0 , upvalues : mapVampireCfgData, _ENV, self
        if mapVampireCfgData ~= nil and mapVampireCfgData.Type == (GameEnum.vampireSurvivorType).Turn then
          (PlayerData.VampireSurvivor):AddPointAndLevel((msgData.Defeat).FinalScore, 0, (msgData.Defeat).SeasonId)
        end
        ;
        (PlayerData.VampireSurvivor):CacheScoreByLevel(self.nVampireId, (msgData.Defeat).FinalScore)
        ;
        (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("VampireReconnnect_Abandon"))
        self.nVampireId = 0
      end

      local msg = {
KillCount = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
, Time = 0, Defeat = true, 
Events = {
List = {}
}
}
      ;
      (HttpNetHandler.SendMsg)((NetMsgId.Id).vampire_survivor_settle_req, msg, nil, netMsgCallback)
    end

    local data = {nType = (AllEnum.MessageBox).Confirm, sContent = orderedFormat((ConfigTable.GetUIText)("VampireReconnnect_Hint") or "", mapVampireCfgData.Name), sConfirm = (ConfigTable.GetUIText)("RoguelikeReenter_Yes"), sCancel = (ConfigTable.GetUIText)("RoguelikeReenter_No"), sContentSub = "", callbackConfirm = ConfirmCallback, callbackCancel = CancelCallback, bCloseNoHandler = true, bRedCancel = true}
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, data)
  end

        local success = function(bSuccess)
    -- function num : 0_12_1 , upvalues : _ENV, self, success, callback, GetDataCallback
    (EventManager.Remove)("GetTalentDataVampire", self, success)
    if bSuccess then
      if callback ~= nil and type(callback) == "function" then
        callback(true)
      end
      GetDataCallback()
    else
      self.nVampireId = 0
      printError("GetTalentDataVampire Failed")
      if callback ~= nil and type(callback) == "function" then
        callback(false)
      end
    end
  end

        ;
        (EventManager.Add)("GetTalentDataVampire", self, success)
        local ret, _, _ = (PlayerData.VampireSurvivor):GetTalentData()
        if ret ~= nil then
          success(true)
        end
      end
      do
        if callback ~= nil and type(callback) == "function" then
          callback(false)
        end
      end
    end
  end
end

PlayerStateData.GetStarTowerState = function(self)
  -- function num : 0_13
  return self.mapStarTowerState
end

PlayerStateData.CheckStarTowerState = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if self.mapStarTowerState == nil then
    return false
  end
  local bState = (self.mapStarTowerState).Id ~= 0
  if bState then
    print((string.format)("正在进行的遗迹:%s", (self.mapStarTowerState).Id))
    local nMaxCount = (ConfigTable.GetConfigNumber)("StarTowerReconnMaxCnt")
    do
      local confirmCallback = function()
    -- function num : 0_14_0 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC4: Confused about usage of register: R0 in 'UnsetPending'

    (self.mapStarTowerState).ReConnection = (self.mapStarTowerState).ReConnection + 1
    if (self.mapStarTowerState).Sweep then
      (PlayerData.StarTower):ReenterTowerFastBattle()
    else
      ;
      (PlayerData.StarTower):ReenterTower((self.mapStarTowerState).Id)
    end
  end

      local cancelCallback = function()
    -- function num : 0_14_1 , upvalues : _ENV, self, nMaxCount
    local giveUpCallback = function()
      -- function num : 0_14_1_0 , upvalues : _ENV, self, nMaxCount
      (PlayerData.StarTower):GiveUpReconnect((self.mapStarTowerState).Id, (self.mapStarTowerState).CharIds, (self.mapStarTowerState).ReConnection < nMaxCount)
      -- DECOMPILER ERROR: 1 unprocessed JMP targets
    end

    giveUpCallback()
  end

      if (self.mapStarTowerState).ReConnection < 0 then
        local msg = {nType = (AllEnum.MessageBox).Confirm, sContent = (ConfigTable.GetUIText)("Roguelike_Reenter_Hint_Clear"), sConfirm = (ConfigTable.GetUIText)("RoguelikeReenter_Yes"), sCancel = (ConfigTable.GetUIText)("RoguelikeReenter_No"), callbackConfirm = confirmCallback, callbackCancel = cancelCallback, bCloseNoHandler = true, bRedCancel = true}
        ;
        (EventManager.Hit)(EventId.OpenMessageBox, msg)
      elseif not (ConfigTable.GetUIText)("Roguelike_Reenter_Hint") then
        local sHint = orderedFormat((self.mapStarTowerState).ReConnection >= nMaxCount or "", nMaxCount - (self.mapStarTowerState).ReConnection, nMaxCount)
        do
          do
            local msg = {nType = (AllEnum.MessageBox).Confirm, sContent = sHint, sConfirm = (ConfigTable.GetUIText)("RoguelikeReenter_Yes"), sCancel = (ConfigTable.GetUIText)("RoguelikeReenter_No"), callbackConfirm = confirmCallback, callbackCancel = cancelCallback, bCloseNoHandler = true, bRedCancel = true}
            ;
            (EventManager.Hit)(EventId.OpenMessageBox, msg)
            do
              local msg = {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Roguelike_Reenter_Hint_Limit"), sTitle = "", sConfirm = (ConfigTable.GetUIText)("RoguelikeReenter_Yes"), callbackConfirm = cancelCallback}
              ;
              (EventManager.Hit)(EventId.OpenMessageBox, msg)
              ;
              (EventManager.Hit)("HaveRoguelikeState")
            end
            do return bState end
            -- DECOMPILER ERROR: 6 unprocessed JMP targets
          end
        end
      end
    end
  end
end

PlayerStateData.GetStarTowerRecon = function(self)
  -- function num : 0_15
  return (self.mapStarTowerState).ReConnection
end

PlayerStateData.GetWorldClassRewardState = function(self)
  -- function num : 0_16
  return self.tbWorldClassRewardState
end

PlayerStateData.ResetWorldClassRewardState = function(self, nLv)
  -- function num : 0_17 , upvalues : _ENV
  local nIndex = (math.ceil)(nLv / 8)
  local bActive = 1 << nLv - (nIndex - 1) * 8 - 1 & (self.tbWorldClassRewardState)[nIndex] > 0
  -- DECOMPILER ERROR at PC28: Confused about usage of register: R4 in 'UnsetPending'

  if bActive then
    (self.tbWorldClassRewardState)[nIndex] = (self.tbWorldClassRewardState)[nIndex] & ~(1 << nLv - (nIndex - 1) * 8 - 1)
  end
  ;
  (PlayerData.Base):RefreshWorldClassRedDot()
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerStateData.ResetIntervalWorldClassRewardState = function(self, nMinLevel, nMaxLevel)
  -- function num : 0_18 , upvalues : _ENV
  for nLv = nMinLevel, nMaxLevel do
    local nIndex = (math.ceil)(nLv / 8)
    local bActive = 1 << nLv - (nIndex - 1) * 8 - 1 & (self.tbWorldClassRewardState)[nIndex] > 0
    -- DECOMPILER ERROR at PC32: Confused about usage of register: R9 in 'UnsetPending'

    if bActive then
      (self.tbWorldClassRewardState)[nIndex] = (self.tbWorldClassRewardState)[nIndex] & ~(1 << nLv - (nIndex - 1) * 8 - 1)
    end
  end
  ;
  (PlayerData.Base):RefreshWorldClassRedDot()
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerStateData.ResetAllWorldClassRewardState = function(self)
  -- function num : 0_19 , upvalues : _ENV
  for k,_ in pairs(self.tbWorldClassRewardState) do
    -- DECOMPILER ERROR at PC5: Confused about usage of register: R6 in 'UnsetPending'

    (self.tbWorldClassRewardState)[k] = 0
  end
  ;
  (PlayerData.Base):RefreshWorldClassRedDot()
end

PlayerStateData.SetMailOverflow = function(self, bOverflow)
  -- function num : 0_20
  self.bMailOverflow = bOverflow
end

PlayerStateData.GetMailOverflow = function(self)
  -- function num : 0_21
  return self.bMailOverflow
end

PlayerStateData.SetStarTowerSweepState = function(self, bInSweep)
  -- function num : 0_22
  self.bInStarTowerSweep = bInSweep
end

PlayerStateData.GetStarTowerSweepState = function(self)
  -- function num : 0_23
  return self.bInStarTowerSweep
end

PlayerStateData.RefreshCharAdvanceRewardRedDot = function(self)
  -- function num : 0_24 , upvalues : _ENV
  local tbAdvanceLevel = (PlayerData.Char):GetAdvanceLevelTable()
  for charId,v in pairs(self.tbCharAdvanceRewards) do
    local charCfg = (ConfigTable.GetData_Character)(charId)
    if charCfg ~= nil then
      local nGrade = charCfg.Grade
      local tbLevelAttr = tbAdvanceLevel[nGrade]
      local maxAdvance = #tbLevelAttr - 1
      for i = 1, maxAdvance do
        local bReceive = v >> i - 1 & 1 == 1
        ;
        (RedDotManager.SetValid)(RedDotDefine.Role_AdvanceReward, {charId, i}, bReceive)
      end
    end
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

return PlayerStateData

