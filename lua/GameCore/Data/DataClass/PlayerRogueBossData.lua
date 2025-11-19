local ClientManager = CS.ClientManager
local newDayTime = (UTILS.GetDayRefreshTimeOffset)()
local PlayerRogueBossData = class("PlayerRogueBossData")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
PlayerRogueBossData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  (EventManager.Add)(EventId.DelBuildItemId, self, self.OnEvent_DelBuildItemId)
  ;
  (EventManager.Add)("region_boss_ticket_notify", self, self.OnEvent_RefreshRes)
  self.passStar = 1
  self.nBeforeStar = 0
  self.selRegionBossId = 0
  self.selBuildId = 0
  self.selLvId = 0
  self.isWeeklyCopies = false
  self.weekBossThroughTime = nil
  self.curLevel = nil
  self._regionBossLevel = {}
  self._regionBossAffix = {}
  self:HandleDifficultyMsg()
  self:HandleAffixMsg()
  self.CacheBossLevelMsg = {}
  self.CacheWeeklyCopiesMsg = {}
  self.CacheWeeklyReceivedIds = {}
  self.isUnLock = false
  self.tbLastMaxHard = {}
  self.isPauseCount = 0
  self.nRegionBossChallengeTicket = 0
  self.isSelectHardCore = false
  self.upDataBuildId = 0
end

PlayerRogueBossData.GetUnlockRogueBoss = function(self, nId, nIndex)
  -- function num : 0_1 , upvalues : _ENV
  local data = (ConfigTable.GetData)("RegionBoss", nId)
  local _prev = decodeJson(data.UnlockCondition)
  for __,nMainlineId in ipairs(_prev) do
    local nStar = (PlayerData.Mainline):GetMainlineStar(nMainlineId)
    if type(nStar) ~= "number" then
      return false
    end
  end
  local worldClass = (PlayerData.Base):GetWorldClass()
  local tempData = ((self._regionBossLevel)[nId])[nIndex]
  if worldClass < tempData.NeedWorldClass then
    return false, tempData.NeedWorldClass
  end
  do
    if tempData.PreLevelId ~= 0 then
      local cachePreData = self:GetCacheBossLevelMsg(tempData.PreLevelId)
      if cachePreData == nil or cachePreData.Star == nil or cachePreData.Star < tempData.PreLevelStar then
        return false
      end
    end
    return true
  end
end

PlayerRogueBossData.GetRogueBossUnLockMsg = function(self, nId, nIndex)
  -- function num : 0_2 , upvalues : _ENV
  local worldClass = (PlayerData.Base):GetWorldClass()
  local tempData = ((self._regionBossLevel)[nId])[nIndex]
  local isWorldClass = true
  if worldClass < tempData.NeedWorldClass then
    isWorldClass = false
  end
  local isPreLevelStar = true
  do
    if tempData.PreLevelId ~= 0 then
      local cachePreData = self:GetCacheBossLevelMsg(tempData.PreLevelId)
      if cachePreData == nil or cachePreData.Star == nil or cachePreData.Star < tempData.PreLevelStar then
        isPreLevelStar = false
      end
    end
    if isWorldClass == false or isPreLevelStar == false then
      return false, isWorldClass, isPreLevelStar
    end
    return true
  end
end

PlayerRogueBossData.GetBossMaxLv = function(self, bossId)
  -- function num : 0_3 , upvalues : _ENV
  local maxLv = 1
  local worldClass = (PlayerData.Base):GetWorldClass()
  local lvGroupCount = ((self._regionBossLevel)[bossId]).groupCount
  for i = 1, lvGroupCount do
    local tempData = ((self._regionBossLevel)[bossId])[i]
    if tempData.NeedWorldClass <= worldClass then
      if tempData.PreLevelId ~= 0 then
        local cachePreData = (PlayerData.RogueBoss):GetCacheBossLevelMsg(tempData.Id)
        if cachePreData and cachePreData.Star > 0 then
          maxLv = i
        end
      else
        do
          do
            maxLv = i
            -- DECOMPILER ERROR at PC34: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC34: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC34: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC34: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC34: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
  return maxLv
end

PlayerRogueBossData.GetBossMaxGroupCount = function(self, bossId)
  -- function num : 0_4
  if (self._regionBossLevel)[bossId] ~= nil then
    return ((self._regionBossLevel)[bossId]).groupCount
  end
  return 0
end

PlayerRogueBossData.SetLastMaxHard = function(self, nGroupId, nHard)
  -- function num : 0_5
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self.tbLastMaxHard)[nGroupId] = nHard
end

PlayerRogueBossData.GetLastMaxHard = function(self, nGroupId)
  -- function num : 0_6
  return (self.tbLastMaxHard)[nGroupId] or 0
end

PlayerRogueBossData.GetMaxHard = function(self, nGroupId)
  -- function num : 0_7 , upvalues : _ENV
  local nHard = (PlayerData.RogueBoss):GetBossMaxLv(nGroupId)
  local maxCount = (PlayerData.RogueBoss):GetBossMaxGroupCount(nGroupId)
  if maxCount < nHard + 1 then
    nHard = maxCount
  else
    local bUnlock = (PlayerData.RogueBoss):GetUnlockRogueBoss(nGroupId, nHard + 1)
    if bUnlock then
      nHard = nHard + 1
    end
  end
  do
    return nHard
  end
end

PlayerRogueBossData.GetLevelOpenState = function(self, nGroupId)
  -- function num : 0_8 , upvalues : _ENV, newDayTime
  local mapData = (ConfigTable.GetData)("RegionBoss", nGroupId)
  if mapData ~= nil then
    local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
    local fixedTimeStamp = curTimeStamp - newDayTime * 3600
    local nWeek = tonumber((os.date)("!%w", fixedTimeStamp))
    local bOpenTime = (table.indexof)(mapData.OpenDay, nWeek) > 0
    local nLockMainline = 0
    local bMainLine = true
    local _prev = decodeJson(mapData.UnlockCondition)
    if #_prev > 0 then
      for _,nMainlineId in ipairs(_prev) do
        local nStar = (PlayerData.Mainline):GetMainlineStar(nMainlineId)
        if type(nStar) ~= "number" then
          nLockMainline = nMainlineId
        end
      end
      bMainLine = nLockMainline > 0
    end
    local bRogueLike = true
    local bUnlock = not bMainLine or bRogueLike
    if not bOpenTime then
      return (AllEnum.RogueBossLevelState).Not_OpenDay, bUnlock
    end
    if not bMainLine then
      return (AllEnum.RogueBossLevelState).Not_MainLine, bUnlock
    end
    if not bRogueLike then
      return (AllEnum.RogueBossLevelState).Not_RogueLike, bUnlock
    end
    return (AllEnum.RogueBossLevelState).Open, bUnlock
  end
  do return (AllEnum.RogueBossLevelState).None end
  -- DECOMPILER ERROR: 9 unprocessed JMP targets
end

PlayerRogueBossData.GetUnOpenTipText = function(self, nLevelState, nGroupId)
  -- function num : 0_9 , upvalues : _ENV
  local sTipStr = ""
  if nLevelState == (AllEnum.RogueBossLevelState).Not_OpenDay then
    sTipStr = (ConfigTable.GetUIText)("Not_Open_Time")
  else
    if nLevelState == (AllEnum.RogueBossLevelState).Not_MainLine then
      local mapData = (ConfigTable.GetData)("RegionBoss", nGroupId)
      local nLockMainline = 0
      local _prev = decodeJson(mapData.UnlockCondition)
      for _,nMainlineId in ipairs(_prev) do
        local nStar = (PlayerData.Mainline):GetMainlineStar(nMainlineId)
        if type(nStar) ~= "number" then
          nLockMainline = nMainlineId
        end
      end
      local mapLevelData = (ConfigTable.GetData_Mainline)(nLockMainline)
      if mapLevelData ~= nil then
        sTipStr = orderedFormat((ConfigTable.GetUIText)("MainLine_Lock"), mapLevelData.Num, mapLevelData.Name)
      else
        sTipStr = orderedFormat((ConfigTable.GetUIText)("MainLine_Lock"), tostring(nLockMainline), "")
      end
    else
      do
        if nLevelState == (AllEnum.RogueBossLevelState).Not_HardUnlock then
          sTipStr = (ConfigTable.GetUIText)("Level_Lock")
        end
        return sTipStr
      end
    end
  end
end

PlayerRogueBossData.GetUnOpenUITipText = function(self, nLevelState, nGroupId)
  -- function num : 0_10 , upvalues : _ENV
  local sTipStr = ""
  if nLevelState == (AllEnum.RogueBossLevelState).Not_OpenDay then
    sTipStr = (ConfigTable.GetUIText)("Not_Open_Time")
  else
    if nLevelState == (AllEnum.RogueBossLevelState).Not_MainLine then
      local mapData = (ConfigTable.GetData)("RegionBoss", nGroupId)
      local nLockMainline = 0
      local _prev = decodeJson(mapData.UnlockCondition)
      for _,nMainlineId in ipairs(_prev) do
        local nStar = (PlayerData.Mainline):GetMainlineStar(nMainlineId)
        if type(nStar) ~= "number" then
          nLockMainline = nMainlineId
        end
      end
      local mapLevelData = (ConfigTable.GetData_Mainline)(nLockMainline)
      if mapLevelData ~= nil then
        sTipStr = orderedFormat((ConfigTable.GetUIText)("MainLine_Lock"), mapLevelData.Num, mapLevelData.Name)
      else
        sTipStr = orderedFormat((ConfigTable.GetUIText)("MainLine_Lock"), tostring(nLockMainline), "")
      end
    else
      do
        if nLevelState == (AllEnum.RogueBossLevelState).Not_HardUnlock then
          sTipStr = (ConfigTable.GetUIText)("Level_Lock")
        end
        return sTipStr
      end
    end
  end
end

PlayerRogueBossData.CheckLevelOpen = function(self, nGroupId, nHard, bShowTips)
  -- function num : 0_11 , upvalues : _ENV
  if nGroupId == 0 then
    return (AllEnum.RogueBossLevelState).Open
  end
  local nLevelState, bUnlock = self:GetLevelOpenState(nGroupId)
  do
    if nHard ~= nil and nLevelState == (AllEnum.RogueBossLevelState).Open then
      local nMaxLevel = self:GetMaxHard(nGroupId)
      if nMaxLevel < nHard then
        nLevelState = (AllEnum.RogueBossLevelState).Not_HardUnlock
      end
    end
    do
      if bShowTips == true then
        local sTipStr = self:GetUnOpenTipText(nLevelState, nGroupId)
        if sTipStr ~= nil and sTipStr ~= "" then
          (EventManager.Hit)(EventId.OpenMessageBox, sTipStr)
        end
      end
      do return nLevelState == (AllEnum.RogueBossLevelState).Open, bUnlock end
      -- DECOMPILER ERROR: 1 unprocessed JMP targets
    end
  end
end

PlayerRogueBossData.HandleDifficultyMsg = function(self)
  -- function num : 0_12 , upvalues : _ENV
  local foreach_Diff = function(diffData)
    -- function num : 0_12_0 , upvalues : self
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self._regionBossLevel)[diffData.RegionBossId] == nil then
      (self._regionBossLevel)[diffData.RegionBossId] = {}
      -- DECOMPILER ERROR at PC12: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self._regionBossLevel)[diffData.RegionBossId]).groupCount = 0
    end
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R1 in 'UnsetPending'

    ;
    ((self._regionBossLevel)[diffData.RegionBossId])[diffData.Difficulty] = diffData
    -- DECOMPILER ERROR at PC26: Confused about usage of register: R1 in 'UnsetPending'

    ;
    ((self._regionBossLevel)[diffData.RegionBossId]).groupCount = ((self._regionBossLevel)[diffData.RegionBossId]).groupCount + 1
  end

  if self._regionBossLevel == nil then
    self._regionBossLevel = {}
  end
  ForEachTableLine(DataTable.RegionBossLevel, foreach_Diff)
end

PlayerRogueBossData.GetDiffAffixUnlockLv = function(self, regionBossId, entryGroupLevel)
  -- function num : 0_13
  local gCount = ((self._regionBossLevel)[regionBossId]).groupCount
  for i = 1, gCount do
    if (((self._regionBossLevel)[regionBossId])[i])[entryGroupLevel] ~= 0 then
      return (((self._regionBossLevel)[regionBossId])[i]).Difficulty
    end
  end
  return 1
end

PlayerRogueBossData.HandleAffixMsg = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local foreach_Affix = function(affixData)
    -- function num : 0_14_0 , upvalues : self
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self._regionBossAffix)[affixData.GroupId] == nil then
      (self._regionBossAffix)[affixData.GroupId] = {}
      -- DECOMPILER ERROR at PC12: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self._regionBossAffix)[affixData.GroupId]).groupCount = 0
    end
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R1 in 'UnsetPending'

    ;
    ((self._regionBossAffix)[affixData.GroupId])[affixData.Level] = affixData
    -- DECOMPILER ERROR at PC26: Confused about usage of register: R1 in 'UnsetPending'

    ;
    ((self._regionBossAffix)[affixData.GroupId]).groupCount = ((self._regionBossAffix)[affixData.GroupId]).groupCount + 1
  end

  ForEachTableLine(DataTable.RegionBossAffix, foreach_Affix)
end

PlayerRogueBossData.SetRegionBossId = function(self, _regionBossId)
  -- function num : 0_15
  self.selRegionBossId = _regionBossId
end

PlayerRogueBossData.GetRegionBossId = function(self)
  -- function num : 0_16
  return self.selRegionBossId
end

PlayerRogueBossData.GetRewardItem = function(self, id, isFirstPass, isThreeStar)
  -- function num : 0_17 , upvalues : _ENV
  local cfgData = (ConfigTable.GetData)("RegionBossLevel", id)
  local tbItem = {}
  local _base = decodeJson(cfgData.BaseAwardPreview)
  if not isFirstPass then
    local _first = decodeJson(cfgData.FirstAwardPreview)
    for k,v in ipairs(_first) do
      (table.insert)(tbItem, {Tid = v, rewardType = (AllEnum.RewardType).First})
    end
  end
  do
    if not isThreeStar then
      local _three = decodeJson(cfgData.ThreeStarAwardPreview)
      for k,v in ipairs(_three) do
        (table.insert)(tbItem, {Tid = v, rewardType = (AllEnum.RewardType).Three})
      end
    end
    do
      for k,v in ipairs(_base) do
        (table.insert)(tbItem, {Tid = v})
      end
      return tbItem
    end
  end
end

PlayerRogueBossData.SetSelLvId = function(self, id)
  -- function num : 0_18
  self.selLvId = id
end

PlayerRogueBossData.GetSelLvId = function(self)
  -- function num : 0_19
  return self.selLvId
end

PlayerRogueBossData.SetIsWeeklyCopies = function(self, isWeeklyCopies)
  -- function num : 0_20
  self.isWeeklyCopies = isWeeklyCopies
end

PlayerRogueBossData.GetIsWeeklyCopies = function(self)
  -- function num : 0_21
  return self.isWeeklyCopies
end

PlayerRogueBossData.CacheRogueBossData = function(self, tbData)
  -- function num : 0_22 , upvalues : _ENV
  if self.CacheBossLevelMsg == nil then
    self.CacheBossLevelMsg = {}
  end
  if tbData then
    for i,v in ipairs(tbData) do
      local tab = {}
      tab.Star = v.Star
      tab.First = v.First
      tab.ThreeStar = v.ThreeStar
      tab.BuildId = v.BuildId
      if not v.ThreeStar or not 3 then
        do
          tab.maxStar = v.Star
          -- DECOMPILER ERROR at PC30: Confused about usage of register: R8 in 'UnsetPending'

          ;
          (self.CacheBossLevelMsg)[v.Id] = tab
          -- DECOMPILER ERROR at PC31: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC31: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  self:OnEvent_RefreshRes((AllEnum.CoinItemId).RogueHardCoreTick)
end

PlayerRogueBossData.CacheWeeklyCopiesData = function(self, tbData)
  -- function num : 0_23 , upvalues : _ENV
  if self.CacheWeeklyCopiesMsg == nil then
    self.CacheWeeklyCopiesMsg = {}
  end
  if tbData then
    for i,v in pairs(tbData) do
      if (self.CacheWeeklyCopiesMsg)[v.Id] ~= nil then
        local tab = (self.CacheWeeklyCopiesMsg)[v.Id]
        if v.Time < tab.Time then
          tab.Time = v.Time
          tab.BuildId = v.BuildId
          tab.First = v.First
          -- DECOMPILER ERROR at PC31: Confused about usage of register: R8 in 'UnsetPending'

          ;
          (self.CacheWeeklyCopiesMsg)[v.Id] = tab
        end
      else
        do
          do
            local tab = {}
            tab.Id = v.Id
            tab.Time = v.Time
            tab.BuildId = v.BuildId
            tab.First = v.First
            -- DECOMPILER ERROR at PC44: Confused about usage of register: R8 in 'UnsetPending'

            ;
            (self.CacheWeeklyCopiesMsg)[v.Id] = tab
            -- DECOMPILER ERROR at PC45: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC45: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC45: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
end

PlayerRogueBossData.GetCacheWeeklyBossMsg = function(self, id)
  -- function num : 0_24
  return (self.CacheWeeklyCopiesMsg)[id] or nil
end

PlayerRogueBossData.CacheWeeklyThroughTime = function(self, time)
  -- function num : 0_25
  self.weekBossThroughTime = time
end

PlayerRogueBossData.ClearCacheWeeklyRecIds = function(self)
  -- function num : 0_26 , upvalues : _ENV
  self.CacheWeeklyReceivedIds = {}
  if (PanelManager.CheckPanelOpen)(PanelId.WeeklyCopiesPanel) then
    (EventManager.Hit)(EventId.OpenPanel, PanelId.WeeklyCopiesPanel)
  end
end

PlayerRogueBossData.GetCacheBossLevelMsg = function(self, Id)
  -- function num : 0_27
  return (self.CacheBossLevelMsg)[Id] or nil
end

PlayerRogueBossData.GetBeforeStar = function(self)
  -- function num : 0_28
  return self.nBeforeStar
end

PlayerRogueBossData.OnEvent_RefreshRes = function(self, nId)
  -- function num : 0_29 , upvalues : _ENV
  if nId == (AllEnum.CoinItemId).RogueHardCoreTick then
    self.nRegionBossChallengeTicket = (PlayerData.Item):GetItemCountByID((AllEnum.CoinItemId).RogueHardCoreTick)
    local worldClass = (PlayerData.Base):GetWorldClass()
    local openClass = ((ConfigTable.GetData)("OpenFunc", (GameEnum.OpenFuncType).RegionBossChallenge)).NeedWorldClass
    if openClass <= worldClass and self.nRegionBossChallengeTicket > 0 then
      (RedDotManager.SetValid)(RedDotDefine.Map_RogueBoss, nil, true)
    else
      ;
      (RedDotManager.SetValid)(RedDotDefine.Map_RogueBoss, nil, false)
    end
  end
end

PlayerRogueBossData.GetRegionBossChallengeTicket = function(self)
  -- function num : 0_30
  return self.nRegionBossChallengeTicket
end

PlayerRogueBossData.SetSelectRegionType = function(self, isHard)
  -- function num : 0_31
  self.isSelectHardCore = isHard
end

PlayerRogueBossData.GetSelectRegionType = function(self)
  -- function num : 0_32
  return self.isSelectHardCore
end

PlayerRogueBossData.EnterRegionBoss = function(self, mapData)
  -- function num : 0_33 , upvalues : _ENV
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  if self.curLevel ~= nil then
    if (self.curLevel).UnBindEvent ~= nil then
      (self.curLevel):UnBindEvent()
    end
    self.curLevel = nil
  end
  local luaClass = require("Game.Adventure.RegionBossLevel.RegionBossBattleLevel")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    self.upDataBuildId = self.selBuildId
    ;
    (self.curLevel):Init(self, self.selLvId, self.selBuildId, 1)
  end
end

PlayerRogueBossData.EnterWeekBoss = function(self, mapData)
  -- function num : 0_34 , upvalues : _ENV
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  if self.curLevel ~= nil then
    if (self.curLevel).UnBindEvent ~= nil then
      (self.curLevel):UnBindEvent()
    end
    self.curLevel = nil
  end
  local luaClass = require("Game.Adventure.RegionBossLevel.RegionBossBattleLevel")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    self.upDataBuildId = self.selBuildId
    ;
    (self.curLevel):Init(self, self.selLvId, self.selBuildId, 2)
  end
end

PlayerRogueBossData.EnterRoguelikeEditor = function(self, floorId, tbTeamCharId, tbDisc, tbNote)
  -- function num : 0_35 , upvalues : _ENV
  self.selLvId = 0
  self.nFloorId = floorId
  self.tbCharId = tbTeamCharId
  self.selBuildId = 0
  local foreach_level = function(_Data)
    -- function num : 0_35_0 , upvalues : floorId, self
    if _Data.FloorId == floorId then
      self.selLvId = _Data.Id
    end
  end

  ForEachTableLine(DataTable.RegionBossLevel, foreach_level)
  if self.curLevel ~= nil then
    if (self.curLevel).UnBindEvent ~= nil then
      (self.curLevel):UnBindEvent()
    end
    self.curLevel = nil
  end
  local luaClass = require("Game.Editor.RegionBossLevel.RegionBossBattleLevelEditor")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, self.selLvId, tbTeamCharId, tbDisc, tbNote)
  end
end

PlayerRogueBossData.LevelEnd = function(self)
  -- function num : 0_36
  self.curLevel = nil
end

PlayerRogueBossData.RegionBossLevelSettleReq = function(self, isWin, useTime, callback)
  -- function num : 0_37 , upvalues : _ENV
  if isWin and not (PlayerData.Guide):CheckGuideFinishById(16) then
    (PlayerData.Guide):SetPlayerLearnReq(16, -1)
  end
  local func_cbRegionBossLevelSettleAck = function(_, msgData)
    -- function num : 0_37_0 , upvalues : callback, self, _ENV, isWin, useTime
    if callback ~= nil then
      callback(msgData, self.passStar)
    end
    self._EndTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
    local tabUpLevel = {}
    local result = isWin and "1" or "2"
    ;
    (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (table.insert)(tabUpLevel, {"game_cost_time", tostring(useTime)})
    ;
    (table.insert)(tabUpLevel, {"real_cost_time", tostring(self._EndTime - self._EntryTime)})
    ;
    (table.insert)(tabUpLevel, {"build_id", tostring(self.upDataBuildId)})
    ;
    (table.insert)(tabUpLevel, {"battle_id", tostring(self.selLvId)})
    ;
    (table.insert)(tabUpLevel, {"battle_result", tostring(result)})
    ;
    (NovaAPI.UserEventUpload)("region_boss_battle", tabUpLevel)
  end

  self.passStar = 0
  if isWin then
    self.passStar = 1
    local lvMsg = (ConfigTable.GetData)("RegionBossLevel", self.selLvId)
    if lvMsg.RegionType == (GameEnum.RegionType).NormalRegion then
      local star2 = decodeJson(lvMsg.TwoStarCondition)
      local star3 = decodeJson(lvMsg.ThreeStarCondition)
      if star2[1] == 2 and useTime < star2[2] then
        self.passStar = 2
      end
      if star3[1] == 2 and useTime < star3[2] then
        self.passStar = 3
      end
    end
  end
  do
    local Events = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).RegionBoss, isWin)
    local mapSendMsg = {}
    mapSendMsg.Star = self.passStar
    if #Events > 0 then
      mapSendMsg.Events = {
List = {}
}
      -- DECOMPILER ERROR at PC70: Confused about usage of register: R7 in 'UnsetPending'

      ;
      (mapSendMsg.Events).List = Events
    end
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).region_boss_level_settle_req, mapSendMsg, nil, func_cbRegionBossLevelSettleAck)
  end
end

PlayerRogueBossData.WeeklyCopiesLevelSettleReq = function(self, isWin, useTime, callback)
  -- function num : 0_38 , upvalues : _ENV
  local func_cbRegionBossLevelSettleAck = function(_, msgData)
    -- function num : 0_38_0 , upvalues : callback, self, _ENV, isWin, useTime
    if callback ~= nil then
      callback(msgData, self.passStar)
    end
    self._EndTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
    local tabUpLevel = {}
    local result = isWin and "1" or "2"
    ;
    (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (table.insert)(tabUpLevel, {"game_cost_time", tostring(useTime)})
    ;
    (table.insert)(tabUpLevel, {"real_cost_time", tostring(self._EndTime - self._EntryTime)})
    ;
    (table.insert)(tabUpLevel, {"build_id", tostring(self.upDataBuildId)})
    ;
    (table.insert)(tabUpLevel, {"battle_id", tostring(self.selLvId)})
    ;
    (table.insert)(tabUpLevel, {"battle_result", tostring(result)})
    ;
    (NovaAPI.UserEventUpload)("week_boss", tabUpLevel)
  end

  local Events = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).WeeklyCopies, isWin)
  local mapSendMsg = {}
  mapSendMsg.Result = isWin
  mapSendMsg.Time = useTime
  if isWin then
    (PlayerData.RogueBoss):CacheWeeklyThroughTime(useTime)
  else
    ;
    (PlayerData.RogueBoss):CacheWeeklyThroughTime(nil)
  end
  if #Events > 0 then
    mapSendMsg.Events = {
List = {}
}
    -- DECOMPILER ERROR at PC33: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (mapSendMsg.Events).List = Events
  end
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).week_boss_settle_req, mapSendMsg, nil, func_cbRegionBossLevelSettleAck)
end

PlayerRogueBossData.WeeklyCopiesLevelSettleReqSuccess = function(self, msgData)
  -- function num : 0_39 , upvalues : _ENV
  local isFirst = msgData.First
  if self.weekBossThroughTime == nil or self.weekBossThroughTime == 0 then
    return 
  end
  local levels = {}
  local level = {}
  level.Id = self.selLvId
  level.Time = self.weekBossThroughTime
  level.First = isFirst
  level.BuildId = self.selBuildId
  ;
  (table.insert)(levels, level)
  self:CacheWeeklyCopiesData(levels)
  self.weekBossThroughTime = nil
end

PlayerRogueBossData.RegionBossLevelSettleSuccess = function(self, mapMsgData)
  -- function num : 0_40 , upvalues : _ENV
  self.nBeforeStar = 0
  if (self.CacheBossLevelMsg)[self:GetSelLvId()] then
    self.nBeforeStar = ((self.CacheBossLevelMsg)[self:GetSelLvId()]).Star
  end
  if self.passStar > 0 then
    local tempCache = (self.CacheBossLevelMsg)[self:GetSelLvId()]
    local data = {}
    data.Id = self:GetSelLvId()
    if tempCache and self.passStar < tempCache.Star then
      data.Star = tempCache.Star
    else
      data.Star = self.passStar
    end
    if tempCache and tempCache.First then
      data.First = tempCache.First
    else
      data.First = mapMsgData.First
    end
    if tempCache and tempCache.ThreeStar then
      data.ThreeStar = tempCache.ThreeStar
    else
      data.ThreeStar = mapMsgData.ThreeStar
    end
    data.BuildId = self.selBuildId
    if tempCache and tempCache.ThreeStar then
      data.maxStar = 3
    else
      if not mapMsgData.ThreeStar or not 3 then
        data.maxStar = self.passStar
        -- DECOMPILER ERROR at PC74: Confused about usage of register: R4 in 'UnsetPending'

        ;
        (self.CacheBossLevelMsg)[data.Id] = data
        local tempLvData = (ConfigTable.GetData)("RegionBossLevel", self:GetSelLvId())
        if tempLvData.Difficulty < ((self._regionBossLevel)[tempLvData.RegionBossId]).groupCount then
          local tempDiff = tempLvData.Difficulty + 1
          local _tempLvId = (((self._regionBossLevel)[tempLvData.RegionBossId])[tempDiff]).Id
          if (self.CacheBossLevelMsg)[_tempLvId] == nil then
            self:SetIsUnlock(true)
          end
        end
        do
          local tempCache = (self.CacheBossLevelMsg)[self:GetSelLvId()]
          local data = {}
          data.Id = self:GetSelLvId()
          if tempCache and self.passStar < tempCache.Star then
            data.Star = tempCache.Star
          else
            data.Star = self.passStar
          end
          if not tempCache or not tempCache.First then
            data.First = mapMsgData.First
            if not tempCache or not tempCache.ThreeStar then
              do
                data.ThreeStar = mapMsgData.ThreeStar
                data.BuildId = self.selBuildId
                if tempCache and self.passStar < tempCache.maxStar then
                  data.maxStar = tempCache.maxStar
                else
                  data.maxStar = self.passStar
                end
                -- DECOMPILER ERROR at PC151: Confused about usage of register: R4 in 'UnsetPending'

                ;
                (self.CacheBossLevelMsg)[data.Id] = data
                self:SetSelBuildId(0)
                self:OnEvent_RefreshRes((AllEnum.CoinItemId).RogueHardCoreTick)
              end
            end
          end
        end
      end
    end
  end
end

PlayerRogueBossData.RegionBossLevelSettleFail = function(self)
  -- function num : 0_41
end

PlayerRogueBossData.SetSelBuildId = function(self, bId)
  -- function num : 0_42
  self.selBuildId = bId
end

PlayerRogueBossData.GetSelBuildId = function(self)
  -- function num : 0_43
  return self.selBuildId
end

PlayerRogueBossData.OnEvent_DelBuildItemId = function(self, tab)
  -- function num : 0_44 , upvalues : _ENV
  for i,v in pairs(tab) do
    for i1,v1 in pairs(self.CacheBossLevelMsg) do
      if v1.BuildId == v then
        v1.BuildId = 0
      end
    end
  end
end

PlayerRogueBossData.GetIsUnlock = function(self)
  -- function num : 0_45
  return self.isUnLock
end

PlayerRogueBossData.SetIsUnlock = function(self, isPass)
  -- function num : 0_46
  self.isUnLock = isPass
end

PlayerRogueBossData.Sweep = function(self, nLevelId, nTimes, callback)
  -- function num : 0_47 , upvalues : _ENV
  local msg = {Id = nLevelId, Times = nTimes, 
Events = {
List = {}
}
}
  local successCallback = function(_, mapMainData)
    -- function num : 0_47_0 , upvalues : callback
    callback(mapMainData.Rewards, mapMainData.Change)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).region_boss_level_sweep_req, msg, nil, successCallback)
end

return PlayerRogueBossData

