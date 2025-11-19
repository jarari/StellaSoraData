local PlayerEquipmentInstanceData = class("PlayerEquipmentInstanceData")
local newDayTime = (UTILS.GetDayRefreshTimeOffset)()
PlayerEquipmentInstanceData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.curLevel = nil
  self.mapAllLevel = {}
  self.bInSettlement = false
  self.tbLastMaxHard = {}
  self.mapLevelCfg = {}
  self:InitConfigData()
  ;
  (EventManager.Add)("Equipment_Instance_Gameplay_Time", self, self.OnEvent_Time)
end

PlayerEquipmentInstanceData.OnEvent_Time = function(self, nTime)
  -- function num : 0_1
  self._TotalTime = nTime
end

PlayerEquipmentInstanceData.UnInit = function(self)
  -- function num : 0_2 , upvalues : _ENV
  (EventManager.Remove)("Equipment_Instance_Gameplay_Time", self, self.OnEvent_Time)
end

PlayerEquipmentInstanceData.InitConfigData = function(self)
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

  ForEachTableLine((ConfigTable.Get)("CharGemInstance"), funcForeachLine)
end

PlayerEquipmentInstanceData.EnterEquipmentInstanceEditor = function(self, nFloor, tbChar, tbDisc, tbNote)
  -- function num : 0_4 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Editor.EquipmentInstance.EquipmentInstanceEditor")
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

PlayerEquipmentInstanceData.EnterEquipmentInstance = function(self, nLevelId, nBuildId)
  -- function num : 0_5 , upvalues : _ENV
  if self.curLevel ~= nil then
    printError("当前关卡level不为空1")
    return 
  end
  local luaClass = require("Game.Adventure.EquipmentInstance.EquipmentInstanceLevel")
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

PlayerEquipmentInstanceData.SetSelBuildId = function(self, nBuildId)
  -- function num : 0_6
  self.selBuildId = nBuildId
end

PlayerEquipmentInstanceData.GetCachedBuildId = function(self, nLevelId)
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
        local mapLevelCfgData = (ConfigTable.GetData)("CharGemInstance", nLevelId)
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

PlayerEquipmentInstanceData.CacheEquipmentInstanceLevel = function(self, tbData)
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

PlayerEquipmentInstanceData.GetEquipmentInstanceLevelUnlock = function(self, nLevelId)
  -- function num : 0_9 , upvalues : _ENV
  local mapLevelCfgData = (ConfigTable.GetData)("CharGemInstance", nLevelId)
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

PlayerEquipmentInstanceData.GetEquipmentInstanceUnlockMsg = function(self, nLevelId)
  -- function num : 0_10 , upvalues : _ENV
  local mapLevelCfgData = (ConfigTable.GetData)("CharGemInstance", nLevelId)
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

PlayerEquipmentInstanceData.GetEquipmentInstanceStar = function(self, nLevelId)
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

PlayerEquipmentInstanceData.MsgEnterEquipmentInstance = function(self, nLevelId, nBuildId, callback)
  -- function num : 0_12 , upvalues : _ENV
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  self._Build_id = nBuildId
  self._Level_id = nLevelId
  local msg = {}
  msg.Id = nLevelId
  msg.BuildId = nBuildId
  local msgCallback = function(_, mapChangeInfo)
    -- function num : 0_12_0 , upvalues : self, nLevelId, nBuildId, callback
    self:EnterEquipmentInstance(nLevelId, nBuildId)
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
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_gem_instance_apply_req, msg, nil, msgCallback)
end

PlayerEquipmentInstanceData.MsgSettleEquipmentInstance = function(self, nLevelId, nBuildId, nStar, callback)
  -- function num : 0_13 , upvalues : _ENV
  local msg = {}
  msg.Star = nStar
  msg.Events = {List = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).EquipmentInstance, nStar > 0)}
  local msgCallback = function(_, mapMsgData)
    -- function num : 0_13_0 , upvalues : nStar, self, nLevelId, nBuildId, callback, _ENV
    local t1 = nStar >= 1
    local t2 = nStar >= 2
    local t3 = nStar >= 3
    -- DECOMPILER ERROR at PC31: Confused about usage of register: R5 in 'UnsetPending'

    if (self.mapAllLevel)[nLevelId] ~= nil then
      if ((self.mapAllLevel)[nLevelId]).nStar < nStar then
        ((self.mapAllLevel)[nLevelId]).nStar = nStar
      end
      -- DECOMPILER ERROR at PC46: Confused about usage of register: R5 in 'UnsetPending'

      if ((self.mapAllLevel)[nLevelId]).tbTarget == nil then
        ((self.mapAllLevel)[nLevelId]).tbTarget = {false, false, false}
      end
      -- DECOMPILER ERROR at PC58: Confused about usage of register: R5 in 'UnsetPending'

      if not t1 then
        (((self.mapAllLevel)[nLevelId]).tbTarget)[1] = (((self.mapAllLevel)[nLevelId]).tbTarget)[1]
        -- DECOMPILER ERROR at PC70: Confused about usage of register: R5 in 'UnsetPending'

        if not t2 then
          (((self.mapAllLevel)[nLevelId]).tbTarget)[2] = (((self.mapAllLevel)[nLevelId]).tbTarget)[2]
          -- DECOMPILER ERROR at PC82: Confused about usage of register: R5 in 'UnsetPending'

          if not t3 then
            (((self.mapAllLevel)[nLevelId]).tbTarget)[3] = (((self.mapAllLevel)[nLevelId]).tbTarget)[3]
            -- DECOMPILER ERROR at PC97: Confused about usage of register: R5 in 'UnsetPending'

            ;
            (self.mapAllLevel)[nLevelId] = {nStar = nStar, nBuildId = nBuildId, 
tbTarget = {t1, t2, t3}
}
            if callback ~= nil then
              callback(mapMsgData.AwardItems, mapMsgData.FirstItems, mapMsgData.SurpriseItems, mapMsgData.Exp, mapMsgData.Change)
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
            ;
            (table.insert)(tabUpLevel, {"battle_result", tostring(1)})
            ;
            (NovaAPI.UserEventUpload)("equipment_instance_battle", tabUpLevel)
            -- DECOMPILER ERROR: 11 unprocessed JMP targets
          end
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_gem_instance_settle_req, msg, nil, msgCallback)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerEquipmentInstanceData.LevelEnd = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if self.curLevel ~= nil and type((self.curLevel).UnBindEvent) == "function" then
    (self.curLevel):UnBindEvent()
  end
  self.curLevel = nil
end

PlayerEquipmentInstanceData.CalStar = function(nOrigin)
  -- function num : 0_15
  nOrigin = (nOrigin & 1431655765) + (nOrigin >> 1 & 1431655765)
  nOrigin = (nOrigin & 858993459) + (nOrigin >> 2 & 858993459)
  nOrigin = (nOrigin & 252645135) + (nOrigin >> 4 & 252645135)
  nOrigin = (nOrigin) * 16843009 >> 24
  return nOrigin
end

PlayerEquipmentInstanceData.GetCurLevel = function(self)
  -- function num : 0_16
  if self.curLevel == nil then
    return 0
  end
  return (self.curLevel).nLevelId
end

PlayerEquipmentInstanceData.SetLastMaxHard = function(self, nGroupId, nMaxHard)
  -- function num : 0_17
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self.tbLastMaxHard)[nGroupId] = nMaxHard
end

PlayerEquipmentInstanceData.GetLastMaxHard = function(self, nGroupId)
  -- function num : 0_18
  return (self.tbLastMaxHard)[nGroupId] or 0
end

PlayerEquipmentInstanceData.GetMaxEquipmentInstanceHard = function(self, nType)
  -- function num : 0_19 , upvalues : _ENV
  local retHard = 1
  local tbLevelList = (self.mapLevelCfg)[nType]
  if tbLevelList ~= nil then
    for nLevelId,mapLevel in pairs(tbLevelList) do
      if self:GetEquipmentInstanceLevelUnlock(nLevelId) then
        retHard = (math.max)(mapLevel.Difficulty, retHard)
      end
    end
  end
  do
    return retHard
  end
end

PlayerEquipmentInstanceData.GetLevelOpenState = function(self, nType)
  -- function num : 0_20 , upvalues : _ENV
  local mapData = (ConfigTable.GetData)("CharGemInstanceType", nType)
  if mapData ~= nil then
    return (AllEnum.EquipmentInstanceState).Open, true
  end
  return (AllEnum.EquipmentInstanceState).None
end

PlayerEquipmentInstanceData.GetUnOpenTipText = function(self, nLevelState, nType)
  -- function num : 0_21 , upvalues : _ENV
  local sTipStr = ""
  if nLevelState ~= (AllEnum.EquipmentInstanceState).Not_WorldClass or nLevelState == (AllEnum.EquipmentInstanceState).Not_HardUnlock then
    sTipStr = (ConfigTable.GetUIText)("Level_Lock")
  end
  return sTipStr
end

PlayerEquipmentInstanceData.CheckLevelOpen = function(self, nType, nHard, bShowTips)
  -- function num : 0_22 , upvalues : _ENV
  if nType == 0 then
    return (AllEnum.EquipmentInstanceState).Open
  end
  local nLevelState, bUnlock = self:GetLevelOpenState(nType)
  do
    if nHard ~= nil and nLevelState == (AllEnum.EquipmentInstanceState).Open then
      local nMaxUnlockHard = self:GetMaxEquipmentInstanceHard(nType)
      if nMaxUnlockHard < nHard then
        nLevelState = (AllEnum.EquipmentInstanceState).Not_HardUnlock
      end
    end
    do
      if bShowTips == true then
        local sTipStr = self:GetUnOpenTipText(nLevelState, nType)
        if sTipStr ~= nil and sTipStr ~= "" then
          (EventManager.Hit)(EventId.OpenMessageBox, sTipStr)
        end
      end
      do return nLevelState == (AllEnum.EquipmentInstanceState).Open, bUnlock end
      -- DECOMPILER ERROR: 1 unprocessed JMP targets
    end
  end
end

PlayerEquipmentInstanceData.SetSettlementState = function(self, bInSettlement)
  -- function num : 0_23
  self.bInSettlement = bInSettlement
end

PlayerEquipmentInstanceData.GetSettlementState = function(self)
  -- function num : 0_24
  return self.bInSettlement
end

PlayerEquipmentInstanceData.SendEquipmentInstanceRaidReq = function(self, nId, nCount, callback)
  -- function num : 0_25 , upvalues : _ENV
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
    -- function num : 0_25_0 , upvalues : callback
    callback(mapMainData.Rewards, mapMainData.Change)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).char_gem_instance_sweep_req, msgData, nil, successCallback)
end

return PlayerEquipmentInstanceData

