local PlayerSkillInstanceData = class("PlayerSkillInstanceData")
local newDayTime = (UTILS.GetDayRefreshTimeOffset)()
PlayerSkillInstanceData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.curLevel = nil
  self.mapAllLevel = {}
  self.bInSettlement = false
  self.tbLastMaxHard = {}
  self.mapLevelCfg = {}
  self:InitConfigData()
  ;
  (EventManager.Add)("Skill_Instance_Gameplay_Time", self, self.OnEvent_Time)
end

PlayerSkillInstanceData.OnEvent_Time = function(self, nTime)
  -- function num : 0_1
  self._TotalTime = nTime
end

PlayerSkillInstanceData.UnInit = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Remove)("Skill_Instance_Gameplay_Time", self, self.OnEvent_Time)
end

PlayerSkillInstanceData.InitConfigData = function(self)
  -- function num : 0_3 , upvalues : _ENV
  local funcForeachLine = function(line)
    -- function num : 0_3_0 , upvalues : self
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self.mapLevelCfg)[line.Type] == nil then
      (self.mapLevelCfg)[line.Type] = {}
    end
    -- DECOMPILER ERROR at PC13: Confused about usage of register: R1 in 'UnsetPending'

    ;
    ((self.mapLevelCfg)[line.Type])[line.Id] = line
  end

  ForEachTableLine((ConfigTable.Get)("SkillInstance"), funcForeachLine)
end

PlayerSkillInstanceData.EnterSkillInstanceEditor = function(self, nFloor, tbChar, tbDisc, tbNote)
  -- function num : 0_4 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Editor.SkillInstance.SkillInstanceEditor")
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

PlayerSkillInstanceData.EnterSkillInstance = function(self, nLevelId, nBuildId)
  -- function num : 0_5 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Adventure.SkillInstance.SkillInstanceLevel")
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

PlayerSkillInstanceData.SetSelBuildId = function(self, nBuildId)
  -- function num : 0_6
  self.selBuildId = nBuildId
end

PlayerSkillInstanceData.GetCachedBuildId = function(self, nLevelId)
  -- function num : 0_7 , upvalues : _ENV
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
        local mapLevelCfgData = (ConfigTable.GetData)("SkillInstance", nLevelId)
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

PlayerSkillInstanceData.CacheSkillInstanceLevel = function(self, tbData)
  -- function num : 0_8 , upvalues : _ENV
  if tbData == nil then
    return 
  end
  for _,mapData in ipairs(tbData) do
    local t1 = mapData.Star >= 1
    local t2 = mapData.Star >= 2
    local t3 = mapData.Star >= 3
    local nStar = mapData.Star
    -- DECOMPILER ERROR at PC35: Confused about usage of register: R11 in 'UnsetPending'

    ;
    (self.mapAllLevel)[mapData.Id] = {nStar = nStar, nBuildId = mapData.BuildId, 
tbTarget = {t1, t2, t3}
}
  end
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

PlayerSkillInstanceData.GetSkillInstanceLevelUnlock = function(self, nLevelId)
  -- function num : 0_9 , upvalues : _ENV
  local mapLevelCfgData = (ConfigTable.GetData)("SkillInstance", nLevelId)
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

PlayerSkillInstanceData.GetSkillInstanceUnlockMsg = function(self, nLevelId)
  -- function num : 0_10 , upvalues : _ENV
  local mapLevelCfgData = (ConfigTable.GetData)("SkillInstance", nLevelId)
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

PlayerSkillInstanceData.GetSkillInstanceStar = function(self, nLevelId)
  -- function num : 0_11
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

PlayerSkillInstanceData.MsgEnterSkillInstance = function(self, nLevelId, nBuildId, callback)
  -- function num : 0_12 , upvalues : _ENV
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  self._Build_id = nBuildId
  self._Level_id = nLevelId
  local msg = {}
  msg.Id = nLevelId
  msg.BuildId = nBuildId
  local msgCallback = function(_, mapChangeInfo)
    -- function num : 0_12_0 , upvalues : self, nLevelId, nBuildId, callback
    self:EnterSkillInstance(nLevelId, nBuildId)
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R2 in 'UnsetPending'

    if (self.mapAllLevel)[nLevelId] == nil then
      (self.mapAllLevel)[nLevelId] = {nStar = 0, nBuildId = 0}
    end
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R2 in 'UnsetPending'

    ;
    ((self.mapAllLevel)[nLevelId]).nBuildId = nBuildId
    if callback ~= nil then
      callback(mapChangeInfo)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).skill_instance_apply_req, msg, nil, msgCallback)
end

PlayerSkillInstanceData.MsgSettleSkillInstance = function(self, nLevelId, nBuildId, nStar, callback)
  -- function num : 0_13 , upvalues : _ENV
  local msg = {}
  msg.Star = nStar
  msg.Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).SkillInstance, nStar > 0)}
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_13_0 , upvalues : _ENV, nStar, self, nLevelId, nBuildId, callback
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    local t1 = nStar >= 1
    local t2 = nStar >= 2
    local t3 = nStar >= 3
    -- DECOMPILER ERROR at PC39: Confused about usage of register: R6 in 'UnsetPending'

    if (self.mapAllLevel)[nLevelId] ~= nil then
      if ((self.mapAllLevel)[nLevelId]).nStar < nStar then
        ((self.mapAllLevel)[nLevelId]).nStar = nStar
      end
      -- DECOMPILER ERROR at PC54: Confused about usage of register: R6 in 'UnsetPending'

      if ((self.mapAllLevel)[nLevelId]).tbTarget == nil then
        ((self.mapAllLevel)[nLevelId]).tbTarget = {false, false, false}
      end
      -- DECOMPILER ERROR at PC66: Confused about usage of register: R6 in 'UnsetPending'

      if not t1 then
        (((self.mapAllLevel)[nLevelId]).tbTarget)[1] = (((self.mapAllLevel)[nLevelId]).tbTarget)[1]
        -- DECOMPILER ERROR at PC78: Confused about usage of register: R6 in 'UnsetPending'

        if not t2 then
          (((self.mapAllLevel)[nLevelId]).tbTarget)[2] = (((self.mapAllLevel)[nLevelId]).tbTarget)[2]
          -- DECOMPILER ERROR at PC90: Confused about usage of register: R6 in 'UnsetPending'

          if not t3 then
            (((self.mapAllLevel)[nLevelId]).tbTarget)[3] = (((self.mapAllLevel)[nLevelId]).tbTarget)[3]
            -- DECOMPILER ERROR at PC105: Confused about usage of register: R6 in 'UnsetPending'

            ;
            (self.mapAllLevel)[nLevelId] = {nStar = nStar, nBuildId = nBuildId, 
tbTarget = {t1, t2, t3}
}
            if callback ~= nil then
              callback(mapMsgData.AwardItems, mapMsgData.FirstItems, mapMsgData.ThreeStarItems, mapMsgData.SurpriseItems, mapMsgData.Exp, mapMsgData.Change)
            end
            self._EndTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
            local tabUpLevel = {}
            ;
            (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
            ;
            (table.insert)(tabUpLevel, {"game_cost_time", tostring(self._TotalTime)})
            ;
            (table.insert)(tabUpLevel, {"real_cost_time", tostring(self._EndTime - self._EntryTime)})
            ;
            (table.insert)(tabUpLevel, {"build_id", tostring(self._Build_id)})
            ;
            (table.insert)(tabUpLevel, {"battle_id", tostring(self._Level_id)})
            if nStar > 0 then
              (table.insert)(tabUpLevel, {"battle_result", tostring(1)})
            else
              (table.insert)(tabUpLevel, {"battle_result", tostring(2)})
            end
            ;
            (NovaAPI.UserEventUpload)("skill_instance_battle", tabUpLevel)
            -- DECOMPILER ERROR: 13 unprocessed JMP targets
          end
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).skill_instance_settle_req, msg, nil, msgCallback)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerSkillInstanceData.EventUpload = function(self, result, nLevelId, nBuildId)
  -- function num : 0_14 , upvalues : _ENV
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
  (NovaAPI.UserEventUpload)("skill_instance_battle", tabUpLevel)
end

PlayerSkillInstanceData.LevelEnd = function(self)
  -- function num : 0_15 , upvalues : _ENV
  if self.curLevel ~= nil and type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
end

PlayerSkillInstanceData.CalStar = function(nOrigin)
  -- function num : 0_16
  nOrigin = (nOrigin & 1431655765) + (nOrigin >> 1 & 1431655765)
  nOrigin = (nOrigin & 858993459) + (nOrigin >> 2 & 858993459)
  nOrigin = (nOrigin & 252645135) + (nOrigin >> 4 & 252645135)
  nOrigin = (nOrigin) * 16843009 >> 24
  return nOrigin
end

PlayerSkillInstanceData.GetCurLevel = function(self)
  -- function num : 0_17
  if self.curLevel == nil then
    return 0
  end
  return (self.curLevel).nLevelId
end

PlayerSkillInstanceData.SetLastMaxHard = function(self, nGroupId, nMaxHard)
  -- function num : 0_18
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self.tbLastMaxHard)[nGroupId] = nMaxHard
end

PlayerSkillInstanceData.GetLastMaxHard = function(self, nGroupId)
  -- function num : 0_19
  return (self.tbLastMaxHard)[nGroupId] or 0
end

PlayerSkillInstanceData.GetMaxSkillInstanceHard = function(self, nType)
  -- function num : 0_20 , upvalues : _ENV
  local retHard = 1
  local tbLevelList = (self.mapLevelCfg)[nType]
  if tbLevelList ~= nil then
    for nLevelId,mapLevel in pairs(tbLevelList) do
      if self:GetSkillInstanceLevelUnlock(nLevelId) then
        retHard = (math.max)(mapLevel.Difficulty, retHard)
      end
    end
  end
  do
    return retHard
  end
end

PlayerSkillInstanceData.GetLevelOpenState = function(self, nType)
  -- function num : 0_21 , upvalues : _ENV
  local mapData = (ConfigTable.GetData)("SkillInstanceType", nType)
  if mapData ~= nil then
    local worldClass = (PlayerData.Base):GetWorldClass()
    local bWorldClass = mapData.WorldClassLevel <= worldClass
    local bUnlock = bWorldClass
    if not bWorldClass then
      return (AllEnum.SkillInstanceState).Not_WorldClass, bUnlock
    end
    return (AllEnum.SkillInstanceState).Open, bUnlock
  end
  do return (AllEnum.SkillInstanceState).None end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

PlayerSkillInstanceData.GetUnOpenTipText = function(self, nLevelState, nType)
  -- function num : 0_22 , upvalues : _ENV
  local sTipStr = ""
  if nLevelState == (AllEnum.SkillInstanceState).Not_WorldClass then
    local mapData = (ConfigTable.GetData)("SkillInstanceType", nType)
    sTipStr = orderedFormat((ConfigTable.GetUIText)("WorldClass_Lock") or "", mapData.WorldClassLevel)
  else
    do
      if nLevelState == (AllEnum.SkillInstanceState).Not_HardUnlock then
        sTipStr = (ConfigTable.GetUIText)("Level_Lock")
      end
      return sTipStr
    end
  end
end

PlayerSkillInstanceData.CheckLevelOpen = function(self, nType, nHard, bShowTips)
  -- function num : 0_23 , upvalues : _ENV
  if nType == 0 then
    return (AllEnum.SkillInstanceState).Open
  end
  local nLevelState, bUnlock = self:GetLevelOpenState(nType)
  do
    if nHard ~= nil and nLevelState == (AllEnum.SkillInstanceState).Open then
      local nMaxUnlockHard = self:GetMaxSkillInstanceHard(nType)
      if nMaxUnlockHard < nHard then
        nLevelState = (AllEnum.SkillInstanceState).Not_HardUnlock
      end
    end
    do
      if bShowTips == true then
        local sTipStr = self:GetUnOpenTipText(nLevelState, nType)
        if sTipStr ~= nil and sTipStr ~= "" then
          (EventManager.Hit)(EventId.OpenMessageBox, sTipStr)
        end
      end
      do return nLevelState == (AllEnum.SkillInstanceState).Open, bUnlock end
      -- DECOMPILER ERROR: 1 unprocessed JMP targets
    end
  end
end

PlayerSkillInstanceData.SetSettlementState = function(self, bInSettlement)
  -- function num : 0_24
  self.bInSettlement = bInSettlement
end

PlayerSkillInstanceData.GetSettlementState = function(self)
  -- function num : 0_25
  return self.bInSettlement
end

PlayerSkillInstanceData.SendSkillInstanceRaidReq = function(self, nId, nCount, callback)
  -- function num : 0_26 , upvalues : _ENV
  local Events = {}
  local msgData = {Id = nId, Times = nCount}
  if #Events > 0 then
    msgData.Events = {
List = {}
}
    -- DECOMPILER ERROR at PC12: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (msgData.Events).List = Events
  end
  local successCallback = function(_, mapMainData)
    -- function num : 0_26_0 , upvalues : callback
    callback(mapMainData.Rewards, mapMainData.Change)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).skill_instance_sweep_req, msgData, nil, successCallback)
end

return PlayerSkillInstanceData

