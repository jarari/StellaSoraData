local PlayerInfinityTowerData = class("PlayerInfinityTowerData")
local LocalData = require("GameCore.Data.LocalData")
local newDayTime = (UTILS.GetDayRefreshTimeOffset)()
PlayerInfinityTowerData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.selBuildId = {}
  self.againOrNextLv = 0
  self.itDifficultyData = {}
  self:HandleITDifficultyData()
  self:HandleMsgData()
  self.InfinityTowerRewardsTab = {}
  self.isGetITInfo = false
  self.BountyLevel = 0
  self.tabPlotsIds = {}
  self.tabUnLockPlotsIds = {}
  self.UnLockTower = {}
  self.NextLevelId = 0
  self.cacheCharTid = nil
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  self.isAutoNextLv = false
  self.TwinNpcId = 173174
  self.TabVoiceNpc = {}
end

PlayerInfinityTowerData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

PlayerInfinityTowerData.OnEvent_NewDay = function(self)
  -- function num : 0_2
  self:UpdateBountyRewardState(self.BountyLevel)
end

PlayerInfinityTowerData.HandleITDifficultyData = function(self)
  -- function num : 0_3 , upvalues : _ENV
  local itLevelData = {}
  local itTowrtDiffFloorCount = {}
  local itTowrtDiffFirstFloor = {}
  local itTowrtDiffEndFloor = {}
  local foreach_Base = function(baseData)
    -- function num : 0_3_0 , upvalues : itLevelData, itTowrtDiffFloorCount, itTowrtDiffFirstFloor, itTowrtDiffEndFloor
    if itLevelData[baseData.DifficultyId] == nil then
      itLevelData[baseData.DifficultyId] = {}
    end
    if itTowrtDiffFloorCount[baseData.DifficultyId] == nil then
      itTowrtDiffFloorCount[baseData.DifficultyId] = 0
      itTowrtDiffFirstFloor[baseData.DifficultyId] = 9999
      itTowrtDiffEndFloor[baseData.DifficultyId] = 0
    end
    if baseData.Floor < itTowrtDiffFirstFloor[baseData.DifficultyId] then
      itTowrtDiffFirstFloor[baseData.DifficultyId] = baseData.Floor
    end
    if itTowrtDiffEndFloor[baseData.DifficultyId] < baseData.Floor then
      itTowrtDiffEndFloor[baseData.DifficultyId] = baseData.Floor
    end
    itTowrtDiffFloorCount[baseData.DifficultyId] = itTowrtDiffFloorCount[baseData.DifficultyId] + 1
    -- DECOMPILER ERROR at PC41: Confused about usage of register: R1 in 'UnsetPending'

    ;
    (itLevelData[baseData.DifficultyId])[baseData.Floor] = baseData
  end

  ForEachTableLine(DataTable.InfinityTowerLevel, foreach_Base)
  local foreach_Base = function(baseData)
    -- function num : 0_3_1 , upvalues : self, itLevelData, itTowrtDiffFloorCount, itTowrtDiffFirstFloor, itTowrtDiffEndFloor
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self.itDifficultyData)[baseData.TowerId] == nil then
      (self.itDifficultyData)[baseData.TowerId] = {}
      -- DECOMPILER ERROR at PC12: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self.itDifficultyData)[baseData.TowerId]).LastLvId = 0
      -- DECOMPILER ERROR at PC17: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self.itDifficultyData)[baseData.TowerId]).ChallengeIds = {}
      -- DECOMPILER ERROR at PC22: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self.itDifficultyData)[baseData.TowerId]).Diff = {}
      -- DECOMPILER ERROR at PC26: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self.itDifficultyData)[baseData.TowerId]).totalLevleCount = 0
    end
    local tab = {diff = baseData, level = itLevelData[baseData.Id], diffLevelCount = itTowrtDiffFloorCount[baseData.Id] or 0, firstFloor = itTowrtDiffFirstFloor[baseData.Id] or 0, endFloor = itTowrtDiffEndFloor[baseData.Id] or 0}
    -- DECOMPILER ERROR at PC55: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (((self.itDifficultyData)[baseData.TowerId]).Diff)[baseData.Sort] = tab
    -- DECOMPILER ERROR at PC65: Confused about usage of register: R2 in 'UnsetPending'

    ;
    ((self.itDifficultyData)[baseData.TowerId]).totalLevleCount = ((self.itDifficultyData)[baseData.TowerId]).totalLevleCount + tab.diffLevelCount
  end

  ForEachTableLine(DataTable.InfinityTowerDifficulty, foreach_Base)
end

PlayerInfinityTowerData.InfinityTowerRewardsStateNotify = function(self, mapMsgData)
  -- function num : 0_4
  local rewardLv = mapMsgData.Value
  self:UpdateBountyRewardState(rewardLv)
end

PlayerInfinityTowerData.UpdateBountyRewardState = function(self, lv)
  -- function num : 0_5 , upvalues : _ENV
  local foreach_Base = function(baseData)
    -- function num : 0_5_0 , upvalues : lv, self
    if baseData.Level == lv and baseData.RewardDropId ~= 0 then
      self:UpdateInfinityDaily(true)
    end
  end

  ForEachTableLine(DataTable.InfinityTowerBountyLevel, foreach_Base)
end

PlayerInfinityTowerData.UpdateInfinityDaily = function(self, isHave)
  -- function num : 0_6 , upvalues : _ENV
  self.isHaveDailyReward = isHave
  local worldClass = (PlayerData.Base):GetWorldClass()
  local openClass = ((ConfigTable.GetData)("OpenFunc", (GameEnum.OpenFuncType).InfinityTower)).NeedWorldClass
  if openClass <= worldClass then
  end
end

PlayerInfinityTowerData.GetITInfoReq = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_7_0 , upvalues : self
    self:CacheInfinityData(mapMsgData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).infinity_tower_info_req, {}, nil, msgCallback)
end

PlayerInfinityTowerData.CacheInfinityData = function(self, mapMsgData)
  -- function num : 0_8 , upvalues : _ENV
  self.BountyLevel = 0
  for i,v in pairs(mapMsgData.PlotsIds) do
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R7 in 'UnsetPending'

    (self.tabPlotsIds)[v] = true
  end
  for i,v in pairs(mapMsgData.Infos) do
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R7 in 'UnsetPending'

    ((self.itDifficultyData)[v.Id]).LastLvId = v.LevelId
    for i1,v1 in pairs(v.ChallengeIds) do
      (table.insert)(((self.itDifficultyData)[v.Id]).ChallengeIds, v1)
    end
  end
  if not self.isGetITInfo then
    (EventManager.Hit)("Get_InfinityTower_InfoReq")
  end
  self.isGetITInfo = true
  self:HandPlotMsg()
end

PlayerInfinityTowerData.EnterITApplyReq = function(self, nLevelId, nBuildId, isTip)
  -- function num : 0_9 , upvalues : LocalData, _ENV, newDayTime
  if self.nPrevBuildId ~= nBuildId then
    self:ClearCharDamageData()
  end
  self.nPrevBuildId = nBuildId
  if isTip then
    local TipsTime = (LocalData.GetPlayerLocalData)("IntinityT_Tips_Time")
    local _tipDay = 0
    if TipsTime ~= nil then
      _tipDay = tonumber(TipsTime)
    end
    local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
    local fixedTimeStamp = curTimeStamp - newDayTime * 3600
    local nYear = tonumber((os.date)("!%Y", fixedTimeStamp))
    local nMonth = tonumber((os.date)("!%m", fixedTimeStamp))
    local nDay = tonumber((os.date)("!%d", fixedTimeStamp))
    local nowD = nYear * 366 + nMonth * 31 + nDay
    if nowD == _tipDay then
      self:SendEnterITApplyReq(nLevelId, nBuildId, false)
    else
      local GetBuildCallback = function(mapBuildData)
    -- function num : 0_9_0 , upvalues : _ENV, nLevelId, self, nBuildId, newDayTime, LocalData
    local recLv = ((ConfigTable.GetData)("InfinityTowerLevel", nLevelId)).RecommendLv
    local recRank = ((ConfigTable.GetData)("InfinityTowerLevel", nLevelId)).RecommendBuildRank
    local charTid = ((mapBuildData.tbChar)[1]).nTid
    local charData = (PlayerData.Char):GetCharDataByTid(charTid)
    if charData ~= nil then
      if recLv <= charData.nLevel and recRank <= ((PlayerData.Build):CalBuildRank(mapBuildData.nScore)).Id then
        self:SendEnterITApplyReq(nLevelId, nBuildId, false)
      else
        local isSelectAgain = false
        do
          local confirmCallback = function()
      -- function num : 0_9_0_0 , upvalues : isSelectAgain, _ENV, newDayTime, LocalData, self, nLevelId, nBuildId
      if isSelectAgain then
        local _curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
        local _fixedTimeStamp = _curTimeStamp - newDayTime * 3600
        local _nYear = tonumber((os.date)("!%Y", _fixedTimeStamp))
        local _nMonth = tonumber((os.date)("!%m", _fixedTimeStamp))
        local _nDay = tonumber((os.date)("!%d", _fixedTimeStamp))
        local _nowD = _nYear * 366 + _nMonth * 31 + _nDay
        ;
        (LocalData.SetPlayerLocalData)("IntinityT_Tips_Time", tostring(_nowD))
      end
      do
        self:SendEnterITApplyReq(nLevelId, nBuildId, false)
      end
    end

          local againCallback = function(isSelect)
      -- function num : 0_9_0_1 , upvalues : isSelectAgain
      isSelectAgain = isSelect
    end

          local msg = {nType = (AllEnum.MessageBox).Confirm, sContent = (ConfigTable.GetUIText)("InfinityTower_Recommend_Tips"), callbackConfirm = confirmCallback, callbackAgain = againCallback, bBlur = false}
          ;
          (EventManager.Hit)(EventId.OpenMessageBox, msg)
        end
      end
    else
      do
        self:SendEnterITApplyReq(nLevelId, nBuildId, false)
      end
    end
  end

      ;
      (PlayerData.Build):GetBuildDetailData(GetBuildCallback, nBuildId)
    end
  else
    do
      self:SendEnterITApplyReq(nLevelId, nBuildId, false)
    end
  end
end

PlayerInfinityTowerData.SendEnterITApplyReq = function(self, nLevelId, nBuildId, isAgainNext)
  -- function num : 0_10 , upvalues : _ENV
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  self._Build_id = nBuildId
  self._Level_id = nLevelId
  local msg = {}
  msg.LevelId = nLevelId
  msg.BuildId = nBuildId
  local msgCallback = function()
    -- function num : 0_10_0 , upvalues : isAgainNext, _ENV, self, nLevelId, nBuildId
    if isAgainNext then
      (EventManager.Hit)("Infinity_Tower_AgainOrNext")
      ;
      ((CS.AdventureModuleHelper).LevelStateChanged)(false)
    else
      self:EnterInfinityTower(nLevelId, nBuildId, false)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).infinity_tower_apply_req, msg, nil, msgCallback)
end

PlayerInfinityTowerData.EnterInfinityTowerAgainNext = function(self)
  -- function num : 0_11 , upvalues : _ENV
  if self.againOrNextLv ~= 0 then
    local lvData = (ConfigTable.GetData)("InfinityTowerLevel", self.againOrNextLv)
    local _diff = lvData.DifficultyId
    local diffData = (ConfigTable.GetData)("InfinityTowerDifficulty", _diff)
    local _towerId = diffData.TowerId
    local build = (self.selBuildId)[_towerId] or 0
    self:EnterInfinityTower(self.againOrNextLv, build, true)
  end
end

PlayerInfinityTowerData.RefreshCharDamageData = function(self, tbCharId)
  -- function num : 0_12 , upvalues : _ENV
  self.tbCharDamage = {}
  local tbCurrDamage = {}
  for i = 1, #tbCharId do
    local damage = ((CS.AdventureModuleHelper).GetCharacterDamage)(tbCharId[i], true)
    local actorInfo = {}
    actorInfo.nCharId = tbCharId[i]
    actorInfo.nDamage = damage
    ;
    (table.insert)(self.tbCharDamage, actorInfo)
  end
  ;
  ((CS.AdventureModuleHelper).ClearCharacterDamageRecord)(true)
end

PlayerInfinityTowerData.ClearCharDamageData = function(self)
  -- function num : 0_13
  self.tbPrevDamage = nil
  self.tbCharDamage = nil
end

PlayerInfinityTowerData.ITSettleReq = function(self, val, time, tbCharId)
  -- function num : 0_14 , upvalues : _ENV
  local msg = {}
  msg.Value = val
  msg.Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).InfinityTower, val == 1)}
  self:RefreshCharDamageData(tbCharId)
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_14_0 , upvalues : _ENV, self, val, time
    local lvData = (ConfigTable.GetData)("InfinityTowerLevel", self.currentLevel)
    local _diff = lvData.DifficultyId
    local diffData = (ConfigTable.GetData)("InfinityTowerDifficulty", _diff)
    local _towerId = diffData.TowerId
    self:SetSelectLvSortId(diffData.Sort)
    if val == 1 then
      local lastLvId = ((self.itDifficultyData)[_towerId]).LastLvId
      if lastLvId ~= 0 then
        local lastlvData = (ConfigTable.GetData)("InfinityTowerLevel", lastLvId)
        local _lastdiff = lastlvData.DifficultyId
        -- DECOMPILER ERROR at PC45: Confused about usage of register: R9 in 'UnsetPending'

        -- DECOMPILER ERROR at PC45: Unhandled construct in 'MakeBoolean' P1

        if _lastdiff == _diff and lastlvData.Floor < lvData.Floor then
          if lvData.LevelType ~= (GameEnum.InfinityTowerLevelType).Challenge then
            ((self.itDifficultyData)[_towerId]).LastLvId = self.currentLevel
          else
            ;
            (table.insert)(((self.itDifficultyData)[_towerId]).ChallengeIds, self.currentLevel)
          end
        end
        -- DECOMPILER ERROR at PC66: Confused about usage of register: R9 in 'UnsetPending'

        if _lastdiff < _diff then
          if lvData.LevelType ~= (GameEnum.InfinityTowerLevelType).Challenge then
            ((self.itDifficultyData)[_towerId]).LastLvId = self.currentLevel
          else
            ;
            (table.insert)(((self.itDifficultyData)[_towerId]).ChallengeIds, self.currentLevel)
          end
        end
      else
        do
          -- DECOMPILER ERROR at PC85: Confused about usage of register: R7 in 'UnsetPending'

          if lvData.LevelType ~= (GameEnum.InfinityTowerLevelType).Challenge then
            ((self.itDifficultyData)[_towerId]).LastLvId = self.currentLevel
          else
            ;
            (table.insert)(((self.itDifficultyData)[_towerId]).ChallengeIds, self.currentLevel)
          end
          self.NextLevelId = mapMsgData.NextLevelId
          self.LastBountyLevel = self.BountyLevel
          self.BountyLevel = 0
          local tabItem = {}
          for k,v in pairs(mapMsgData.Show) do
            (table.insert)(tabItem, {Tid = v.Tid, Qty = v.Qty, rewardType = (AllEnum.RewardType).First})
          end
          do
            local tmpPlotId = self:CheckLevelSetPlot()
            ;
            (EventManager.Hit)("Infinity_Tower_SettleSuccess", true, time, tabItem, mapMsgData.Change, tmpPlotId, self.tbCharDamage)
            self:SetBreakoutMsgData(self.currentLevel)
            self.isLevelClear = true
            if val == 2 then
              (EventManager.Hit)("Infinity_Tower_SettleSuccess", false, time, nil, nil, nil, self.tbCharDamage)
              self.isLevelClear = false
            else
              if val == 3 then
                (EventManager.Hit)("Infinity_Tower_SettleSuccess", false, time, nil, nil, nil, self.tbCharDamage)
                self.isLevelClear = false
              end
            end
            self._EndTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
            local tabUpLevel = {}
            local tmpAuto = self:GetAutoNextLv() and "1" or "2"
            ;
            (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
            ;
            (table.insert)(tabUpLevel, {"is_auto", tmpAuto})
            ;
            (table.insert)(tabUpLevel, {"game_cost_time", tostring(time)})
            ;
            (table.insert)(tabUpLevel, {"real_cost_time", tostring(self._EndTime - self._EntryTime)})
            ;
            (table.insert)(tabUpLevel, {"build_id", tostring(self._Build_id)})
            ;
            (table.insert)(tabUpLevel, {"battle_id", tostring(self._Level_id)})
            ;
            (table.insert)(tabUpLevel, {"battle_result", tostring(val)})
            ;
            (NovaAPI.UserEventUpload)("infinity_tower_battle", tabUpLevel)
          end
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).infinity_tower_settle_req, msg, nil, msgCallback)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerInfinityTowerData.ITDailyRewardReq = function(self)
  -- function num : 0_15 , upvalues : _ENV
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_15_0 , upvalues : _ENV, self
    local tabItem = {}
    for k,v in pairs(mapMsgData.Show) do
      (table.insert)(tabItem, {Tid = v.Tid, Qty = v.Qty})
    end
    ;
    (UTILS.OpenReceiveByDisplayItem)(tabItem, mapMsgData.Change)
    self:UpdateInfinityDaily(false)
    ;
    (EventManager.Hit)("InfinityTower_DailyCallback")
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).infinity_tower_daily_reward_receive_req, {}, nil, msgCallback)
end

PlayerInfinityTowerData.ITPlotRewardReq = function(self, plotId)
  -- function num : 0_16 , upvalues : _ENV
  local msg = {}
  msg.Value = plotId
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_16_0 , upvalues : _ENV, self, plotId
    local tabItem = {}
    for k,v in pairs(mapMsgData.Show) do
      (table.insert)(tabItem, {Tid = v.Tid, Qty = v.Qty, rewardType = (AllEnum.RewardType).First})
    end
    ;
    (UTILS.OpenReceiveByDisplayItem)(tabItem, mapMsgData.Change)
    -- DECOMPILER ERROR at PC27: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self.tabPlotsIds)[plotId] = true
    local isHave = false
    for i,v in pairs(self.tabUnLockPlotsIds) do
      if (self.tabPlotsIds)[i] == nil then
        isHave = true
        break
      end
    end
    do
      ;
      (RedDotManager.SetValid)(RedDotDefine.Map_InfinityTowerPlot, nil, isHave)
      ;
      (EventManager.Hit)("Refresh_Infinity_PlotList")
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).infinity_tower_plot_reward_receive_req, msg, nil, msgCallback)
end

PlayerInfinityTowerData.EnterInfinityTower = function(self, lvId, buildId, isContinue)
  -- function num : 0_17 , upvalues : _ENV, LocalData
  self.isContinue = isContinue
  self.currentLevel = lvId
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", lvId)
  if lvData == nil then
    printError("无尽塔floorData 为空,lvData id === " .. lvId)
    return 
  end
  local floorData = (ConfigTable.GetData)("InfinityTowerFloor", lvData.FloorId)
  if floorData == nil then
    printError("无尽塔floorData 为空,floor id === " .. lvData.FloorId)
    return 
  end
  do
    if self.curLevel == nil then
      local luaClass = require("Game.Adventure.InfinityTower.InfinityTowerLevel")
      if luaClass == nil then
        return 
      end
      self.curLevel = luaClass
    end
    local lvData = (ConfigTable.GetData)("InfinityTowerLevel", lvId)
    local _diff = lvData.DifficultyId
    local diffData = (ConfigTable.GetData)("InfinityTowerDifficulty", _diff)
    local _towerId = diffData.TowerId
    ;
    (LocalData.SetPlayerLocalData)("IntinityT_Select_Build_" .. _towerId, buildId)
    -- DECOMPILER ERROR at PC57: Confused about usage of register: R10 in 'UnsetPending'

    ;
    (self.selBuildId)[_towerId] = buildId
    if type((self.curLevel).BindEvent) == "function" and self.againOrNextLv == 0 then
      (self.curLevel):BindEvent()
    end
    if type((self.curLevel).Init) == "function" then
      (self.curLevel):Init(self, floorData.Id, buildId, self.againOrNextLv, isContinue)
    end
    self.againOrNextLv = 0
    self.NextLevelId = 0
  end
end

PlayerInfinityTowerData.CacheBuildCharTid = function(self, tab)
  -- function num : 0_18
  self.cacheCharTid = tab
end

PlayerInfinityTowerData.EnterInfinityTowerEditor = function(self, floorId, tbChar, tbDisc, tbNote)
  -- function num : 0_19 , upvalues : _ENV
  self.currentLevel = 11001
  local floorData = (ConfigTable.GetData)("InfinityTowerFloor", floorId)
  if floorData == nil then
    printError("无尽塔floorData 为空,floor id === " .. floorId)
    return 
  end
  local luaClass = require("Game.Editor.InfinityTower.InfinityTowerEditor")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, floorId, tbChar, tbDisc, tbNote)
  end
end

PlayerInfinityTowerData.GetFloorAffixBuff = function(self, tbCharId, floorId)
  -- function num : 0_20 , upvalues : _ENV
  local floorData = (ConfigTable.GetData)("InfinityTowerFloor", floorId)
  local tabAffix = floorData.AffixId
  local tabBuff = {}
  if #tabAffix > 0 then
    for i = 1, #tabAffix do
      local itAffixData = (ConfigTable.GetData)("InfinityTowerAffix", tabAffix[i])
      if itAffixData.TriggerCondition == 1 then
        local param = decodeJson(itAffixData.TriggerParam)
        local paramEET = param[1]
        local paramCount = param[2] or 0
        local tmpCount = 0
        for i,v in pairs(tbCharId) do
          local tmpCharacter = (ConfigTable.GetData_Character)(v)
          if tmpCharacter and tmpCharacter.EET == paramEET then
            tmpCount = tmpCount + 1
          end
        end
        if paramCount <= tmpCount then
          for i,v in pairs(itAffixData.AddCamp) do
            (table.insert)(tabBuff, v)
          end
        end
      else
      end
      do
        if itAffixData.TriggerCondition ~= 2 or itAffixData.TriggerCondition == 0 then
          for i,v in pairs(itAffixData.AddCamp) do
            (table.insert)(tabBuff, v)
          end
        end
        do
          -- DECOMPILER ERROR at PC79: LeaveBlock: unexpected jumping out DO_STMT

        end
      end
    end
  end
  return tabBuff
end

PlayerInfinityTowerData.LevelEnd = function(self)
  -- function num : 0_21 , upvalues : _ENV
  if self.curLevel ~= nil and type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
  self.againOrNextLv = 0
  self:ClearCharDamageData()
  self.nPrevBuildId = nil
end

PlayerInfinityTowerData.GetCurrentLv = function(self)
  -- function num : 0_22
  return self.currentLevel
end

PlayerInfinityTowerData.CheckOpenDay = function(self, index)
  -- function num : 0_23 , upvalues : _ENV, newDayTime
  local mapData = (ConfigTable.GetData)("InfinityTower", index)
  if mapData == nil then
    return false
  end
  if #mapData.OpenDay == 0 then
    return false
  end
  local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local fixedTimeStamp = curTimeStamp - newDayTime * 3600
  local nWeek = tonumber((os.date)("!%w", fixedTimeStamp))
  do return (table.indexof)(mapData.OpenDay, nWeek) > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerInfinityTowerData.GetNextDaySec = function(self, index)
  -- function num : 0_24 , upvalues : _ENV, newDayTime
  local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local fixedTimeStamp = curTimeStamp - newDayTime * 3600
  local weekday_utc = tonumber((os.date)("!%w", fixedTimeStamp))
  local target_weekday = 0
  local mapData = (ConfigTable.GetData)("InfinityTower", index)
  for i,v in pairs(mapData.OpenDay) do
    if weekday_utc < v then
      target_weekday = v
      break
    end
  end
  do
    local days_to_target = (target_weekday - weekday_utc + 7) % 7
    local nHour = tonumber((os.date)("!%H", fixedTimeStamp))
    local nMin = tonumber((os.date)("!%M", fixedTimeStamp))
    local nSec = tonumber((os.date)("!%S", fixedTimeStamp))
    local totalSec = days_to_target * 86400 - (nHour * 3600 + nMin * 60 + nSec)
    return totalSec
  end
end

PlayerInfinityTowerData.CheckTowerUnLock = function(self, towerId, PreTowerLevelId)
  -- function num : 0_25 , upvalues : _ENV
  if (self.UnLockTower)[towerId] then
    return true
  end
  -- DECOMPILER ERROR at PC9: Confused about usage of register: R3 in 'UnsetPending'

  if PreTowerLevelId == 0 then
    (self.UnLockTower)[towerId] = true
    return true
  end
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", PreTowerLevelId)
  local _diff = lvData.DifficultyId
  local _diffData = (ConfigTable.GetData)("InfinityTowerDifficulty", _diff)
  local _towerId = _diffData.TowerId
  local _lastLvId = ((self.itDifficultyData)[_towerId]).LastLvId
  if _lastLvId == 0 then
    return false
  end
  local lvLastData = (ConfigTable.GetData)("InfinityTowerLevel", _lastLvId)
  local _lastDiff = lvLastData.DifficultyId
  -- DECOMPILER ERROR at PC40: Confused about usage of register: R10 in 'UnsetPending'

  if _diff < _lastDiff then
    (self.UnLockTower)[towerId] = true
    return true
  else
    -- DECOMPILER ERROR at PC51: Confused about usage of register: R10 in 'UnsetPending'

    if _lastDiff == _diff then
      if lvData.Floor <= lvLastData.Floor then
        (self.UnLockTower)[towerId] = true
        return true
      else
        return false
      end
    else
      return false
    end
  end
end

PlayerInfinityTowerData.CheckLockWorldClass = function(self, ChooseLevelId)
  -- function num : 0_26 , upvalues : _ENV
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", ChooseLevelId)
  local _diff = lvData.DifficultyId
  local _diffData = (ConfigTable.GetData)("InfinityTowerDifficulty", _diff)
  local _unlockWorldClass = _diffData.UnlockWorldClass
  local worldClass = (PlayerData.Base):GetWorldClass()
  if _unlockWorldClass <= worldClass then
    return false
  end
  return true
end

PlayerInfinityTowerData.GetTowerPassAll = function(self, towerId)
  -- function num : 0_27 , upvalues : _ENV
  local _lastLvId = ((self.itDifficultyData)[towerId]).LastLvId
  if _lastLvId == 0 then
    return false
  end
  local lvLastData = (ConfigTable.GetData)("InfinityTowerLevel", _lastLvId)
  local lvLastFloor = lvLastData.Floor
  local towerTotalLvCount = ((self.itDifficultyData)[towerId]).totalLevleCount
  if lvLastFloor == towerTotalLvCount then
    return true
  end
  return false
end

PlayerInfinityTowerData.GetTowerDiffPassAll = function(self, towerId, diffSort)
  -- function num : 0_28 , upvalues : _ENV
  local _lastLvId = ((self.itDifficultyData)[towerId]).LastLvId
  if _lastLvId == 0 then
    return false
  end
  local lvLastData = (ConfigTable.GetData)("InfinityTowerLevel", _lastLvId)
  local diffData = self:GetTowerDiffData(towerId, diffSort)
  if diffData.endFloor <= lvLastData.Floor then
    return true
  end
  return false
end

PlayerInfinityTowerData.JudgeLevelPass = function(self, towerId, levelId)
  -- function num : 0_29 , upvalues : _ENV
  local _lastLvId = ((self.itDifficultyData)[towerId]).LastLvId
  if _lastLvId == 0 then
    return false
  end
  local lvLastData = (ConfigTable.GetData)("InfinityTowerLevel", _lastLvId)
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", levelId)
  if lvData.Floor <= lvLastData.Floor then
    return true
  end
  return false
end

PlayerInfinityTowerData.JudgeLevelCanChallenge = function(self, towerId, levelId)
  -- function num : 0_30 , upvalues : _ENV
  local _lastLvId = ((self.itDifficultyData)[towerId]).LastLvId
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", levelId)
  if _lastLvId == 0 then
    if lvData.Floor == 1 then
      return true
    end
    return false
  end
  local lvLastData = (ConfigTable.GetData)("InfinityTowerLevel", _lastLvId)
  if lvData.Floor == lvLastData.Floor + 1 then
    return true
  end
  return false
end

PlayerInfinityTowerData.JudgeLevelLock = function(self, towerId, levelId)
  -- function num : 0_31 , upvalues : _ENV
  local _lastLvId = ((self.itDifficultyData)[towerId]).LastLvId
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", levelId)
  if _lastLvId == 0 then
    if lvData.Floor > 1 then
      return true
    end
    return false
  end
  local lvLastData = (ConfigTable.GetData)("InfinityTowerLevel", _lastLvId)
  if lvLastData.Floor + 2 <= lvData.Floor then
    return true
  end
  return false
end

PlayerInfinityTowerData.JudgeInfinityTowerCond = function(self, Cond, CondParam)
  -- function num : 0_32 , upvalues : _ENV
  if Cond == (GameEnum.InfinityTowerCond).LevelClearWithSpecificId then
    local lvId = CondParam[1]
    local lvData = (ConfigTable.GetData)("InfinityTowerLevel", lvId)
    local diff = lvData.DifficultyId
    local diffData = (ConfigTable.GetData)("InfinityTowerDifficulty", diff)
    local towerId = diffData.TowerId
    local towerLastLvId = ((self.itDifficultyData)[towerId]).LastLvId
    if towerLastLvId == 0 then
      return false
    end
    local lvDataLastLv = (ConfigTable.GetData)("InfinityTowerLevel", towerLastLvId)
    if lvData.Floor <= lvDataLastLv.Floor then
      return true
    end
    return false
  else
    do
      if Cond == (GameEnum.InfinityTowerCond).InfinityTowerWithSpecificLevelTotal then
        local CondPassCount = CondParam[1]
        local totalPassCount = 0
        for i,v in pairs(self.itDifficultyData) do
          if v.LastLvId ~= 0 then
            local lastLv = v.LastLvId
            local lvData = (ConfigTable.GetData)("InfinityTowerLevel", lastLv)
            totalPassCount = totalPassCount + lvData.Floor
          end
        end
        if CondPassCount <= totalPassCount then
          return true
        end
        return false
      else
        do
          if Cond == (GameEnum.InfinityTowerCond).AnyTowerWithSpecificTotalLevel then
            local CondCount = CondParam[1]
            local CondFloor = CondParam[2]
            local count = 0
            for i,v in pairs(self.itDifficultyData) do
              if v.LastLvId ~= 0 then
                local lastLv = v.LastLvId
                local lvData = (ConfigTable.GetData)("InfinityTowerLevel", lastLv)
                if CondFloor <= lvData.Floor then
                  count = count + 1
                end
              end
            end
            if CondCount <= count then
              return true
            end
            return false
          else
            do
              if Cond == (GameEnum.InfinityTowerCond).BountyLevelSpecific then
                if CondParam[1] <= self.BountyLevel then
                  return true
                end
                return false
              end
              return true
            end
          end
        end
      end
    end
  end
end

PlayerInfinityTowerData.JudgeInfinityTowerBuildCanUse = function(self, tbCharTid, levelId)
  -- function num : 0_33 , upvalues : _ENV
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", levelId)
  local Cond = lvData.EntryCond
  local CondParam = lvData.EntryCondParam
  if Cond == (GameEnum.InfinityTowerCond).MasterCharactersWithSpecificElementType then
    local charId = tbCharTid[1]
    local charData = (ConfigTable.GetData_Character)(charId)
    if charData.EET == CondParam[1] then
      return true
    end
    return false
  else
    do
      if Cond == (GameEnum.InfinityTowerCond).ElementTypeWithSpecificQuantityNoLessThanQuantity then
        local count = 0
        for i,v in pairs(tbCharTid) do
          local charId = v
          local charData = (ConfigTable.GetData_Character)(charId)
          if charData.EET == CondParam[1] then
            count = count + 1
          end
        end
        return CondParam[2] <= count
      elseif Cond == (GameEnum.InfinityTowerCond).ElementTypeWithSpecificQuantityNoMoreThanQuantity then
        local count = 0
        for i,v in pairs(tbCharTid) do
          local charId = v
          local charData = (ConfigTable.GetData_Character)(charId)
          if charData.EET == CondParam[1] then
            count = count + 1
          end
        end
        return count <= CondParam[2]
      end
      do return true end
      -- DECOMPILER ERROR: 5 unprocessed JMP targets
    end
  end
end

PlayerInfinityTowerData.GetTowerDiffCount = function(self, towerId)
  -- function num : 0_34
  return #((self.itDifficultyData)[towerId]).Diff
end

PlayerInfinityTowerData.GetTowerDiffData = function(self, towerId, sortId)
  -- function num : 0_35
  return (((self.itDifficultyData)[towerId]).Diff)[sortId]
end

PlayerInfinityTowerData.GetTowerPassFloor = function(self, towerId)
  -- function num : 0_36 , upvalues : _ENV
  local _lastLvId = ((self.itDifficultyData)[towerId]).LastLvId
  if _lastLvId == 0 then
    return 0
  end
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", _lastLvId)
  if lvData then
    return lvData.Floor
  end
  return 0
end

PlayerInfinityTowerData.GetTowerPassLv = function(self, towerId)
  -- function num : 0_37
  return ((self.itDifficultyData)[towerId]).LastLvId
end

PlayerInfinityTowerData.GetTowerLayerData = function(self, towerId, floor)
  -- function num : 0_38
  return nil
end

PlayerInfinityTowerData.GetCachedBuildId = function(self, lvId)
  -- function num : 0_39 , upvalues : _ENV
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", lvId)
  local diff = lvData.DifficultyId
  local diffData = (ConfigTable.GetData)("InfinityTowerDifficulty", diff)
  local towerId = diffData.TowerId
  return (self.selBuildId)[towerId] or 0
end

PlayerInfinityTowerData.GetSaveBuildId = function(self, lvId)
  -- function num : 0_40 , upvalues : _ENV, LocalData
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", lvId)
  local diff = lvData.DifficultyId
  local diffData = (ConfigTable.GetData)("InfinityTowerDifficulty", diff)
  local towerId = diffData.TowerId
  local tmpBuild = (LocalData.GetPlayerLocalData)("IntinityT_Select_Build_" .. towerId)
  if tmpBuild ~= nil then
    return tonumber(tmpBuild)
  end
  return 0
end

PlayerInfinityTowerData.SetSelBuildId = function(self, nBuildId, lvId)
  -- function num : 0_41 , upvalues : _ENV
  local lvData = (ConfigTable.GetData)("InfinityTowerLevel", lvId)
  local diff = lvData.DifficultyId
  local diffData = (ConfigTable.GetData)("InfinityTowerDifficulty", diff)
  local towerId = diffData.TowerId
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R7 in 'UnsetPending'

  ;
  (self.selBuildId)[towerId] = nBuildId
end

PlayerInfinityTowerData.GetInitInfoState = function(self)
  -- function num : 0_42
  return self.isGetITInfo
end

PlayerInfinityTowerData.AnginOrNextLv = function(self, isAgain)
  -- function num : 0_43
  self.againOrNextLv = 0
  if isAgain then
    self.againOrNextLv = self.currentLevel
    return true, self.againOrNextLv
  else
    if self.NextLevelId ~= 0 then
      self.againOrNextLv = self.NextLevelId
      return true, self.NextLevelId
    else
      return false, 0
    end
  end
end

PlayerInfinityTowerData.GoAnginOrNextLv = function(self)
  -- function num : 0_44 , upvalues : _ENV
  if self.againOrNextLv ~= 0 then
    local lvData = (ConfigTable.GetData)("InfinityTowerLevel", self.againOrNextLv)
    local _diff = lvData.DifficultyId
    local diffData = (ConfigTable.GetData)("InfinityTowerDifficulty", _diff)
    local _towerId = diffData.TowerId
    local build = (self.selBuildId)[_towerId] or 0
    self:SendEnterITApplyReq(self.againOrNextLv, build, true)
  end
end

PlayerInfinityTowerData.HandleMsgData = function(self)
  -- function num : 0_45 , upvalues : _ENV
  self.bottomList_Daily = {}
  self.bottomList_Breakout = {}
  self.bottomList_News = {}
  local foreach_Base = function(baseData)
    -- function num : 0_45_0 , upvalues : _ENV, self
    if baseData.Type == (GameEnum.InfinityTowerMsgType).Daily then
      for i,v in pairs(baseData.DayOfWeek) do
        -- DECOMPILER ERROR at PC16: Confused about usage of register: R6 in 'UnsetPending'

        if (self.bottomList_Daily)[v] == nil then
          (self.bottomList_Daily)[v] = {}
        end
        ;
        (table.insert)((self.bottomList_Daily)[v], baseData.Id)
      end
    else
      do
        -- DECOMPILER ERROR at PC41: Unhandled construct in 'MakeBoolean' P1

        if baseData.Type == (GameEnum.InfinityTowerMsgType).Breakout and baseData.Condition == (GameEnum.InfinityTowerMsgConditions).SpecialLv then
          local tmpJ = decodeJson(baseData.Params)
          for _,lvId in pairs(tmpJ) do
            -- DECOMPILER ERROR at PC47: Confused about usage of register: R7 in 'UnsetPending'

            (self.bottomList_Breakout)[lvId] = baseData.Id
          end
        end
        do
          if baseData.Type == (GameEnum.InfinityTowerMsgType).News then
            (table.insert)(self.bottomList_News, baseData.Id)
          end
        end
      end
    end
  end

  ForEachTableLine(DataTable.InfinityTowerMsg, foreach_Base)
end

PlayerInfinityTowerData.SetBreakoutMsgData = function(self, lvId)
  -- function num : 0_46 , upvalues : LocalData, _ENV, newDayTime
  if (self.bottomList_Breakout)[lvId] ~= nil then
    (LocalData.SetPlayerLocalData)("IntinityT_Breakout_Id", tostring(lvId))
    local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
    local fixedTimeStamp = curTimeStamp - newDayTime * 3600
    ;
    (LocalData.SetPlayerLocalData)("IntinityT_Breakout_Time", tostring(fixedTimeStamp))
  end
end

PlayerInfinityTowerData.RandomBottomMsg = function(self)
  -- function num : 0_47 , upvalues : _ENV, newDayTime, LocalData
  self.randomBotMsg = {}
  local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local fixedTimeStamp = curTimeStamp - newDayTime * 3600
  local nWeek = tonumber((os.date)("!%w", fixedTimeStamp))
  local tmpDayList = (self.bottomList_Daily)[nWeek]
  local nDayId = tmpDayList[(math.random)(1, #tmpDayList)]
  -- DECOMPILER ERROR at PC30: Confused about usage of register: R6 in 'UnsetPending'

  if nDayId ~= 0 then
    (self.randomBotMsg)[(GameEnum.InfinityTowerMsgType).Daily] = nDayId
  end
  local tmpBreakoutId = (LocalData.GetPlayerLocalData)("IntinityT_Breakout_Id")
  if tmpBreakoutId ~= nil then
    local saveTime = (LocalData.GetPlayerLocalData)("IntinityT_Breakout_Time")
    if saveTime ~= nil then
      local nSaveWeek = tonumber((os.date)("!%w", tonumber(saveTime)))
      -- DECOMPILER ERROR at PC61: Confused about usage of register: R9 in 'UnsetPending'

      if nWeek == nSaveWeek then
        (self.randomBotMsg)[(GameEnum.InfinityTowerMsgType).Breakout] = (self.bottomList_Breakout)[tonumber(tmpBreakoutId)]
      else
        ;
        (LocalData.DelPlayerLocalData)("IntinityT_Breakout_Id")
        ;
        (LocalData.DelPlayerLocalData)("IntinityT_Breakout_Time")
      end
    end
  end
  do
    -- DECOMPILER ERROR at PC74: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self.randomBotMsg)[(GameEnum.InfinityTowerMsgType).News] = {}
    local tmpNews = {}
    for i,v in pairs(self.bottomList_News) do
      (table.insert)(tmpNews, v)
    end
    local tabLength = #tmpNews
    for i = 1, tabLength do
      local index = (math.random)(1, #tmpNews)
      local nNewsId = tmpNews[index]
      local _data = (ConfigTable.GetData)("InfinityTowerMsg", nNewsId)
      if (table.indexof)(_data.DayOfWeek, nWeek) > 0 then
        (table.insert)((self.randomBotMsg)[(GameEnum.InfinityTowerMsgType).News], nNewsId)
      end
      if #(self.randomBotMsg)[(GameEnum.InfinityTowerMsgType).News] ~= 3 then
        do
          (table.remove)(tmpNews, index)
          -- DECOMPILER ERROR at PC132: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC132: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
end

PlayerInfinityTowerData.GetBottomMsgId = function(self, type, index)
  -- function num : 0_48 , upvalues : _ENV
  if type == (GameEnum.InfinityTowerMsgType).News then
    return ((self.randomBotMsg)[(GameEnum.InfinityTowerMsgType).News])[index]
  else
    return (self.randomBotMsg)[type]
  end
end

PlayerInfinityTowerData.HandPlotMsg = function(self)
  -- function num : 0_49 , upvalues : _ENV
  local foreach_Base = function(baseData)
    -- function num : 0_49_0 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

    if (self.tabPlotsIds)[baseData.Id] then
      (self.tabUnLockPlotsIds)[baseData.Id] = true
    else
      local isUnlock = self:JudgeInfinityTowerCond(baseData.UnlockCond, baseData.CondParam)
      if isUnlock then
        (RedDotManager.SetValid)(RedDotDefine.Map_InfinityTowerPlot, nil, true)
        -- DECOMPILER ERROR at PC25: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (self.tabUnLockPlotsIds)[baseData.Id] = true
      end
    end
  end

  ForEachTableLine(DataTable.InfinityTowerPlot, foreach_Base)
end

PlayerInfinityTowerData.GetPlotUnLock = function(self, plotId)
  -- function num : 0_50
  if (self.tabUnLockPlotsIds)[plotId] then
    return true
  end
  return false
end

PlayerInfinityTowerData.GetPlotGetReward = function(self, plotId)
  -- function num : 0_51
  if (self.tabPlotsIds)[plotId] then
    return true
  end
  return false
end

PlayerInfinityTowerData.CheckLevelSetPlot = function(self)
  -- function num : 0_52 , upvalues : _ENV
  local tmpPlotId = 0
  local foreach_Base = function(baseData)
    -- function num : 0_52_0 , upvalues : self, tmpPlotId, _ENV
    if not (self.tabUnLockPlotsIds)[baseData.Id] then
      local isUnlock = self:JudgeInfinityTowerCond(baseData.UnlockCond, baseData.CondParam)
      if isUnlock then
        tmpPlotId = baseData.Id
        ;
        (RedDotManager.SetValid)(RedDotDefine.Map_InfinityTowerPlot, nil, true)
        -- DECOMPILER ERROR at PC23: Confused about usage of register: R2 in 'UnsetPending'

        ;
        (self.tabUnLockPlotsIds)[baseData.Id] = true
      end
    end
  end

  ForEachTableLine(DataTable.InfinityTowerPlot, foreach_Base)
  return tmpPlotId
end

PlayerInfinityTowerData.PlayPlot = function(self, plotId)
  -- function num : 0_53 , upvalues : _ENV
  local plotData = (ConfigTable.GetData)("InfinityTowerPlot", plotId)
  local sAvgId = plotData.avgId
  local avgEndCallback = function()
    -- function num : 0_53_0 , upvalues : _ENV, self, avgEndCallback, plotId
    (EventManager.Remove)("StoryDialog_DialogEnd", self, avgEndCallback)
    if (self.tabPlotsIds)[plotId] == nil then
      self:ITPlotRewardReq(plotId)
    end
  end

  ;
  (EventManager.Add)("StoryDialog_DialogEnd", self, avgEndCallback)
  ;
  (EventManager.Hit)("StoryDialog_DialogStart", sAvgId)
end

PlayerInfinityTowerData.SetPageState = function(self, index)
  -- function num : 0_54
  self.PageState = index
  if index == 1 then
    self.isLevelClear = false
  end
end

PlayerInfinityTowerData.GetPageState = function(self)
  -- function num : 0_55
  return self.PageState or 1
end

PlayerInfinityTowerData.SetAutoNextLv = function(self, isAuto)
  -- function num : 0_56
  self.isAutoNextLv = isAuto
end

PlayerInfinityTowerData.GetAutoNextLv = function(self)
  -- function num : 0_57
  return self.isAutoNextLv
end

PlayerInfinityTowerData.SetSelectLvSortId = function(self, sortId)
  -- function num : 0_58
  self.selectDiffSort = sortId
end

PlayerInfinityTowerData.GetSelectLvSortId = function(self)
  -- function num : 0_59
  return self.selectDiffSort or 1
end

PlayerInfinityTowerData.OnEvent_PlayTwinEffect = function(self)
  -- function num : 0_60 , upvalues : _ENV
  if not self.isContinue then
    (PlayerData.Voice):PlayCharVoice("twin_effect", self.TwinNpcId, nil, true)
  end
end

PlayerInfinityTowerData.GetNPCVoiceKey = function(self, NpcId)
  -- function num : 0_61 , upvalues : _ENV
  local isFirst = true
  if (self.TabVoiceNpc)[NpcId] then
    isFirst = false
  else
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self.TabVoiceNpc)[NpcId] = true
  end
  local timeNow = ((CS.ClientManager).Instance).serverTimeStamp
  local nHour = tonumber((os.date)("%H", timeNow))
  if nHour >= 6 and nHour < 12 then
    return isFirst, "greetmorn_npc"
  else
    if nHour >= 12 and nHour < 18 then
      return isFirst, "greetnoon_npc"
    else
      return isFirst, "greetnight_npc"
    end
  end
end

return PlayerInfinityTowerData

