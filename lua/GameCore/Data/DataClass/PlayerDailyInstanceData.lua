local PlayerDailyInstanceData = class("PlayerDailyInstanceData")
local LocalData = require("GameCore.Data.LocalData")
local newDayTime = (UTILS.GetDayRefreshTimeOffset)()
local SDKManager = (CS.SDKManager).Instance
PlayerDailyInstanceData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.curLevel = nil
  self.mapAllLevel = {}
  self.bInSettlement = false
  self.tbLastMaxHard = {}
  self.mapLevelCfg = {}
  self:InitConfigData()
  ;
  (EventManager.Add)("Daily_Instance_Gameplay_Time", self, self.OnEvent_Time)
end

PlayerDailyInstanceData.OnEvent_Time = function(self, nTime)
  -- function num : 0_1
  self._TotalTime = nTime
end

PlayerDailyInstanceData.InitConfigData = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local funcForeachLine = function(line)
    -- function num : 0_2_0 , upvalues : self
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self.mapLevelCfg)[line.DailyType] == nil then
      (self.mapLevelCfg)[line.DailyType] = {}
    end
    -- DECOMPILER ERROR at PC13: Confused about usage of register: R1 in 'UnsetPending'

    ;
    ((self.mapLevelCfg)[line.DailyType])[line.Id] = line
  end

  ForEachTableLine(DataTable.DailyInstance, funcForeachLine)
end

PlayerDailyInstanceData.EnterDailyInstanceEditor = function(self, nFloor, tbChar, tbDisc, tbNote)
  -- function num : 0_3 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Editor.DailyInstance.DailyInstanceEditor")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, nFloor, tbChar, tbDisc, tbNote)
  end
end

PlayerDailyInstanceData.EnterDailyInstance = function(self, nLevelId, nBuildId)
  -- function num : 0_4 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Adventure.DailyInstance.DailyInstanceLevel")
  if luaClass == nil then
    return 
  end
  self.curLevel = luaClass
  if type((self.curLevel).BindEvent) == "function" then
    (self.curLevel):BindEvent()
  end
  if type((self.curLevel).Init) == "function" then
    (self.curLevel):Init(self, nLevelId, nBuildId)
  end
end

PlayerDailyInstanceData.SetSelBuildId = function(self, nBuildId)
  -- function num : 0_5
  self.selBuildId = nBuildId
end

PlayerDailyInstanceData.GetCachedBuildId = function(self, nLevelId)
  -- function num : 0_6 , upvalues : _ENV
  if (PlayerData.Guide):GetGuideState() then
    do
      if self.selBuildId ~= 0 and self.selBuildId ~= nil then
        local ret = self.selBuildId
        return ret
      end
      do return 0 end
      do
        if self.selBuildId ~= 0 and self.selBuildId ~= nil then
          local ret = self.selBuildId
          return ret
        end
        if nLevelId == 0 then
          return 0
        end
        do
          if (self.mapAllLevel)[nLevelId] == nil then
            local mapLevelCfgData = (ConfigTable.GetData)("DailyInstance", nLevelId)
            if mapLevelCfgData == nil then
              return 0
            end
            if mapLevelCfgData.PreLevelId ~= 0 then
              if (self.mapAllLevel)[mapLevelCfgData.PreLevelId] ~= nil then
                return ((self.mapAllLevel)[mapLevelCfgData.PreLevelId]).nBuildId
              else
                return 0
              end
            else
              return 0
            end
          end
          return ((self.mapAllLevel)[nLevelId]).nBuildId
        end
      end
    end
  end
end

PlayerDailyInstanceData.CacheDailyInstanceLevel = function(self, tbData)
  -- function num : 0_7 , upvalues : _ENV
  if tbData == nil then
    return 
  end
  for _,mapData in ipairs(tbData) do
    local b1 = 1
    local b2 = 2
    local b3 = 4
    local t1 = mapData.Star & b1 > 0
    local t2 = mapData.Star & b2 > 0
    local t3 = mapData.Star & b3 > 0
    local nStar = (self.CalStar)(mapData.Star)
    -- DECOMPILER ERROR at PC43: Confused about usage of register: R14 in 'UnsetPending'

    ;
    (self.mapAllLevel)[mapData.Id] = {nStar = nStar, nBuildId = mapData.BuildId, 
tbTarget = {t1, t2, t3}
}
  end
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

PlayerDailyInstanceData.GetDailyInstanceLevelUnlock = function(self, nLevelId)
  -- function num : 0_8 , upvalues : _ENV
  local mapLevelCfgData = (ConfigTable.GetData)("DailyInstance", nLevelId)
  if mapLevelCfgData == nil then
    return false
  end
  if mapLevelCfgData.PreLevelId == 0 then
    return true
  end
  if (PlayerData.Base):GetWorldClass() < mapLevelCfgData.NeedWorldClass then
    return false, mapLevelCfgData.NeedWorldClass
  end
  if (self.mapAllLevel)[mapLevelCfgData.PreLevelId] == nil then
    return false
  end
  if mapLevelCfgData.PreLevelStar <= ((self.mapAllLevel)[mapLevelCfgData.PreLevelId]).nStar then
    return true
  end
  return false
end

PlayerDailyInstanceData.GetDailyInstanceUnlockMsg = function(self, nLevelId)
  -- function num : 0_9 , upvalues : _ENV
  local mapLevelCfgData = (ConfigTable.GetData)("DailyInstance", nLevelId)
  if mapLevelCfgData.PreLevelId == 0 then
    return true
  end
  local isWorldClass = true
  if (PlayerData.Base):GetWorldClass() < mapLevelCfgData.NeedWorldClass then
    isWorldClass = false
  end
  local isPreLevelStar = true
  if (self.mapAllLevel)[mapLevelCfgData.PreLevelId] == nil or ((self.mapAllLevel)[mapLevelCfgData.PreLevelId]).nStar < mapLevelCfgData.PreLevelStar then
    isPreLevelStar = false
  end
  if isWorldClass == false or isPreLevelStar == false then
    return false, isWorldClass, isPreLevelStar
  end
  return true
end

PlayerDailyInstanceData.GetDailyInstanceStar = function(self, nLevelId)
  -- function num : 0_10
  if nLevelId == nil then
    return 0, {false, false, false}
  end
  if (self.mapAllLevel)[nLevelId] == nil then
    return 0, {false, false, false}
  end
  if ((self.mapAllLevel)[nLevelId]).tbTarget ~= nil or not {false, false, false} then
    return ((self.mapAllLevel)[nLevelId]).nStar, ((self.mapAllLevel)[nLevelId]).tbTarget
  end
end

PlayerDailyInstanceData.MsgEnterDailyInstance = function(self, nLevelId, nBuildId, callback)
  -- function num : 0_11 , upvalues : _ENV
  local msg = {}
  msg.Id = nLevelId
  msg.BuildId = nBuildId
  msg.RewardType = self.lastRewardType
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local msgCallback = function()
    -- function num : 0_11_0 , upvalues : self, nLevelId, nBuildId, callback
    self:EnterDailyInstance(nLevelId, nBuildId)
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R0 in 'UnsetPending'

    if (self.mapAllLevel)[nLevelId] == nil then
      (self.mapAllLevel)[nLevelId] = {nStar = 0, nBuildId = 0}
    end
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R0 in 'UnsetPending'

    ;
    ((self.mapAllLevel)[nLevelId]).nBuildId = nBuildId
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).daily_instance_apply_req, msg, nil, msgCallback)
end

PlayerDailyInstanceData.MsgSettleDailyInstance = function(self, nLevelId, nBuildId, nStar, callback)
  -- function num : 0_12 , upvalues : _ENV
  if nStar == 0 then
    if callback ~= nil then
      callback({}, {}, {})
    end
    if (PlayerData.Guide):GetGuideState() then
      (EventManager.Hit)("Guide_DailyInstance_Fail")
    end
    self:EventUpload(2, nLevelId, nBuildId)
    return 
  end
  local msg = {}
  msg.Star = nStar
  msg.Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).DailyInstance, nStar > 0)}
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_12_0 , upvalues : nStar, self, nLevelId, nBuildId, callback
    local b1 = 1
    local b2 = 2
    local b3 = 4
    local t1 = nStar & b1 > 0
    local t2 = nStar & b2 > 0
    local t3 = nStar & b3 > 0
    local nStarCount = (t1 and 1 or 0) + (t2 and 1 or 0) + (t3 and 1 or 0)
    -- DECOMPILER ERROR at PC55: Confused about usage of register: R9 in 'UnsetPending'

    if (self.mapAllLevel)[nLevelId] ~= nil then
      if ((self.mapAllLevel)[nLevelId]).nStar < nStarCount then
        ((self.mapAllLevel)[nLevelId]).nStar = nStarCount
      end
      -- DECOMPILER ERROR at PC70: Confused about usage of register: R9 in 'UnsetPending'

      if ((self.mapAllLevel)[nLevelId]).tbTarget == nil then
        ((self.mapAllLevel)[nLevelId]).tbTarget = {false, false, false}
      end
      -- DECOMPILER ERROR at PC82: Confused about usage of register: R9 in 'UnsetPending'

      if not t1 then
        (((self.mapAllLevel)[nLevelId]).tbTarget)[1] = (((self.mapAllLevel)[nLevelId]).tbTarget)[1]
        -- DECOMPILER ERROR at PC94: Confused about usage of register: R9 in 'UnsetPending'

        if not t2 then
          (((self.mapAllLevel)[nLevelId]).tbTarget)[2] = (((self.mapAllLevel)[nLevelId]).tbTarget)[2]
          -- DECOMPILER ERROR at PC106: Confused about usage of register: R9 in 'UnsetPending'

          if not t3 then
            (((self.mapAllLevel)[nLevelId]).tbTarget)[3] = (((self.mapAllLevel)[nLevelId]).tbTarget)[3]
            -- DECOMPILER ERROR at PC121: Confused about usage of register: R9 in 'UnsetPending'

            ;
            (self.mapAllLevel)[nLevelId] = {nStar = nStar, nBuildId = nBuildId, 
tbTarget = {t1, t2, t3}
}
            if callback ~= nil then
              callback(mapMsgData.Select, mapMsgData.First, mapMsgData.Exp, mapMsgData.Change)
            end
            self:EventUpload(1, nLevelId, nBuildId)
            -- DECOMPILER ERROR: 17 unprocessed JMP targets
          end
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).daily_instance_settle_req, msg, nil, msgCallback)
  if (PlayerData.Guide):GetGuideState() then
    (EventManager.Hit)("Guide_DailyInstance_Settle")
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerDailyInstanceData.EventUpload = function(self, result, nLevelId, nBuildId)
  -- function num : 0_13 , upvalues : _ENV
  self._EndTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local tabUpLevel = {}
  ;
  (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (table.insert)(tabUpLevel, {"game_cost_time", tostring(self._TotalTime)})
  ;
  (table.insert)(tabUpLevel, {"real_cost_time", tostring(self._EndTime - self._EntryTime)})
  ;
  (table.insert)(tabUpLevel, {"build_id", tostring(nBuildId)})
  ;
  (table.insert)(tabUpLevel, {"battle_id", tostring(nLevelId)})
  ;
  (table.insert)(tabUpLevel, {"battle_result", tostring(result)})
  ;
  (NovaAPI.UserEventUpload)("daily_instance_battle", tabUpLevel)
end

PlayerDailyInstanceData.LevelEnd = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if self.curLevel ~= nil and type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
end

PlayerDailyInstanceData.CalStar = function(nOrigin)
  -- function num : 0_15
  nOrigin = (nOrigin & 1431655765) + (nOrigin >> 1 & 1431655765)
  nOrigin = (nOrigin & 858993459) + (nOrigin >> 2 & 858993459)
  nOrigin = (nOrigin & 252645135) + (nOrigin >> 4 & 252645135)
  nOrigin = (nOrigin) * 16843009 >> 24
  return nOrigin
end

PlayerDailyInstanceData.GetCurLevel = function(self)
  -- function num : 0_16
  if self.curLevel == nil then
    return 0
  end
  return (self.curLevel).nLevelId
end

PlayerDailyInstanceData.SetLastMaxHard = function(self, nGroupId, nMaxHard)
  -- function num : 0_17
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self.tbLastMaxHard)[nGroupId] = nMaxHard
end

PlayerDailyInstanceData.GetLastMaxHard = function(self, nGroupId)
  -- function num : 0_18
  return (self.tbLastMaxHard)[nGroupId] or 0
end

PlayerDailyInstanceData.GetMaxDailyInstanceHard = function(self, nType)
  -- function num : 0_19 , upvalues : _ENV
  local retHard = 1
  local tbLevelList = (self.mapLevelCfg)[nType]
  if tbLevelList ~= nil then
    for nLevelId,mapLevel in pairs(tbLevelList) do
      if self:GetDailyInstanceLevelUnlock(nLevelId) then
        retHard = (math.max)(mapLevel.Difficulty, retHard)
      end
    end
  end
  do
    return retHard
  end
end

PlayerDailyInstanceData.GetLevelOpenState = function(self, nType)
  -- function num : 0_20 , upvalues : _ENV
  nType = (GameEnum.dailyType).Common
  local mapData = (ConfigTable.GetData)("DailyInstanceType", nType)
  if mapData ~= nil then
    local bMainLine = true
    do
      if mapData.MainLineId > 0 then
        local nStar = (PlayerData.Mainline):GetMianlineLevelStar(mapData.MainLineId)
        bMainLine = nStar > 0
      end
      local worldClass = (PlayerData.Base):GetWorldClass()
      local bWorldClass = mapData.WorldClassLevel <= worldClass
      do
        local bUnlock = not bMainLine or bWorldClass
        if not bMainLine then
          return (AllEnum.DailyInstanceState).Not_MainLine, bUnlock
        end
        if not bWorldClass then
          return (AllEnum.DailyInstanceState).Not_WorldClass, bUnlock
        end
        do return (AllEnum.DailyInstanceState).Open, bUnlock end
        do return (AllEnum.DailyInstanceState).None end
        -- DECOMPILER ERROR: 7 unprocessed JMP targets
      end
    end
  end
end

PlayerDailyInstanceData.GetUnOpenTipText = function(self, nLevelState, nType)
  -- function num : 0_21 , upvalues : _ENV
  nType = (GameEnum.dailyType).Common
  local sTipStr = nil
  if nLevelState == (AllEnum.DailyInstanceState).Not_MainLine then
    local mapData = (ConfigTable.GetData)("DailyInstanceType", nType)
    local mapLevelData = (ConfigTable.GetData_Mainline)(mapData.MainLineId)
    if not (ConfigTable.GetUIText)("MainLine_Lock") then
      do
        sTipStr = orderedFormat(mapLevelData == nil or "", mapLevelData.Num, mapLevelData.Name)
        sTipStr = orderedFormat((ConfigTable.GetUIText)("MainLine_Lock") or "", tostring(mapData.MainLineId), "")
        if nLevelState == (AllEnum.DailyInstanceState).Not_WorldClass then
          local mapData = (ConfigTable.GetData)("DailyInstanceType", nType)
          sTipStr = orderedFormat((ConfigTable.GetUIText)("WorldClass_Lock") or "", mapData.WorldClassLevel)
        else
          do
            if nLevelState == (AllEnum.DailyInstanceState).Not_HardUnlock then
              sTipStr = (ConfigTable.GetUIText)("Level_Lock")
            end
            return sTipStr or ""
          end
        end
      end
    end
  end
end

PlayerDailyInstanceData.CheckLevelOpen = function(self, nType, nHard, bShowTips)
  -- function num : 0_22 , upvalues : _ENV
  if nType == 0 then
    return (AllEnum.DailyInstanceState).Open
  end
  local nLevelState, bUnlock = self:GetLevelOpenState(nType)
  do
    if nHard ~= nil and nLevelState == (AllEnum.DailyInstanceState).Open then
      local nMaxUnlockHard = self:GetMaxDailyInstanceHard(nType)
      if nMaxUnlockHard < nHard then
        nLevelState = (AllEnum.DailyInstanceState).Not_HardUnlock
      end
    end
    do
      if bShowTips == true then
        local sTipStr = self:GetUnOpenTipText(nLevelState, nType)
        if sTipStr ~= nil and sTipStr ~= "" then
          (EventManager.Hit)(EventId.OpenMessageBox, sTipStr)
        end
      end
      do return nLevelState == (AllEnum.DailyInstanceState).Open, bUnlock end
      -- DECOMPILER ERROR: 1 unprocessed JMP targets
    end
  end
end

PlayerDailyInstanceData.SetSettlementState = function(self, bInSettlement)
  -- function num : 0_23
  self.bInSettlement = bInSettlement
end

PlayerDailyInstanceData.GetSettlementState = function(self)
  -- function num : 0_24
  return self.bInSettlement
end

PlayerDailyInstanceData.GetLastRewardType = function(self)
  -- function num : 0_25 , upvalues : LocalData, _ENV
  do
    if self.lastRewardType == nil then
      local lastType = (LocalData.GetPlayerLocalData)("DailyRewardType")
      if lastType == nil then
        self:SetRewardType((GameEnum.DailyRewardType).CharExp)
      else
        self.lastRewardType = lastType
      end
    end
    return tonumber(self.lastRewardType)
  end
end

PlayerDailyInstanceData.SetRewardType = function(self, nType)
  -- function num : 0_26 , upvalues : LocalData
  self.lastRewardType = nType
  ;
  (LocalData.SetPlayerLocalData)("DailyRewardType", nType)
end

PlayerDailyInstanceData.SendDailyInstanceRaidReq = function(self, nId, nCount, callback)
  -- function num : 0_27 , upvalues : _ENV
  local Events = {}
  local msgData = {Id = nId, RewardType = self.lastRewardType, Times = nCount}
  if #Events > 0 then
    msgData.Events = {
List = {}
}
    -- DECOMPILER ERROR at PC14: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (msgData.Events).List = Events
  end
  local successCallback = function(_, mapMainData)
    -- function num : 0_27_0 , upvalues : callback
    callback(mapMainData.Rewards, mapMainData.Change)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).daily_instance_raid_req, msgData, nil, successCallback)
end

return PlayerDailyInstanceData

