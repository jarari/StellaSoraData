local BaseRoom = class("BaseRoom")
local TimerManager = require("GameCore.Timer.TimerManager")
local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
BaseRoom.ctor = function(self, parentData, tbCases)
  -- function num : 0_0
  self.EnumCase = {Battle = 1, OpenDoor = 2, PotentialSelect = 3, FateCardSelect = 4, NoteSelect = 5, NpcEvent = 6, SelectSpecialPotential = 7, RecoveryHP = 8, NpcRecoveryHP = 9, Hawker = 10, StrengthenMachine = 11, DoorDanger = 12, SyncHP = 13}
  self.EnumPopup = {Reward = 1, Potential = 2, StrengthFx = 3, Disc = 4, Affinity = 5}
  self.curRoomType = 0
  self.bBattleEnd = false
  self.nCoinTemp = 0
  self.tbEvent = {}
  self._tbTimer = {}
  self.roomData = {}
  self.parent = parentData
  self.mapCases = {}
  self.bProcessing = true
  self.nTaskType = 0
  self.mapNpc = {}
  self.initCases = tbCases
  self.tbPopup = {}
  self.blockNpcBtn = false
end

BaseRoom._BindEventCallback = function(self, mapEventConfig)
  -- function num : 0_1 , upvalues : _ENV
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Add)(nEventId, self, callback)
    end
  end
  local callback1 = self.OnEvent_NpcSpawned
  if type(callback1) == "function" then
    (EventManager.Add)("LevelNpcSpawned", self, callback1)
  end
  local callback2 = self.OnEvent_DiscSkillActive
  if type(callback2) == "function" then
    (EventManager.Add)("DiscSkillActive", self, callback2)
  end
  local callback3 = self.OnEvent_RewardPopup
  if type(callback3) == "function" then
    (EventManager.Add)("StarTowerReward", self, callback3)
  end
  local callback4 = self.OnEvent_PotentialPopup
  if type(callback4) == "function" then
    (EventManager.Add)("PotentialLevelUp", self, callback4)
  end
  local callback5 = self.OnEvent_ShopStrengthFx
  if type(callback5) == "function" then
    (EventManager.Add)("ShopStrengthFx", self, callback5)
  end
  local callback6 = self.OnEvent_CloseLoadingView
  if type(callback5) == "function" then
    (EventManager.Add)(EventId.TransAnimOutClear, self, callback6)
  end
end

BaseRoom._UnbindEventCallback = function(self, mapEventConfig)
  -- function num : 0_2 , upvalues : _ENV
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Remove)(nEventId, self, callback)
    end
  end
  local callback1 = self.OnEvent_NpcSpawned
  ;
  (EventManager.Remove)("LevelNpcSpawned", self, callback1)
  local callback2 = self.OnEvent_DiscSkillActive
  ;
  (EventManager.Remove)("DiscSkillActive", self, callback2)
  local callback3 = self.OnEvent_RewardPopup
  ;
  (EventManager.Remove)("StarTowerReward", self, callback3)
  local callback4 = self.OnEvent_PotentialPopup
  ;
  (EventManager.Remove)("PotentialLevelUp", self, callback4)
  local callback5 = self.OnEvent_ShopStrengthFx
  ;
  (EventManager.Remove)("ShopStrengthFx", self, callback5)
  local callback6 = self.OnEvent_CloseLoadingView
  ;
  (EventManager.Remove)(EventId.TransAnimOutClear, self, callback6)
end

BaseRoom._RemoveAllTimer = function(self)
  -- function num : 0_3 , upvalues : _ENV, TimerManager
  for i,timer in ipairs(self._tbTimer) do
    if timer ~= nil then
      (TimerManager.Remove)(timer, false)
    end
  end
end

BaseRoom.AddTimer = function(self, nTargetCount, nInterval, sCallbackName, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
  -- function num : 0_4 , upvalues : _ENV, TimerManager
  local callback = nil
  if type(sCallbackName) == "function" then
    callback = sCallbackName
  else
    callback = self[sCallbackName]
  end
  if type(callback) == "function" then
    local timer = (TimerManager.Add)(nTargetCount, nInterval, self, callback, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
    if timer ~= nil then
      (table.insert)(self._tbTimer, timer)
    end
    return timer
  else
    do
      do return nil end
    end
  end
end

BaseRoom.Enter = function(self)
  -- function num : 0_5 , upvalues : _ENV
  self._EntryTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  self:_BindEventCallback(self._mapEventConfig)
  local nLevel = (self.parent).nCurLevel
  local nTotalLevel = #(self.parent).tbStarTowerAllLevel
  local nType = (self.parent).nRoomType
  if (self.parent).nTowerId ~= 999 then
    (EventManager.Hit)("ShowStarTowerLevelTitle", nLevel, nTotalLevel, nType)
  end
  ;
  (EventManager.Hit)("StarTowerSetButtonEnable", true, true)
  ;
  (EventManager.Hit)("InitStarTowerNote", (self.parent)._mapNote)
  self:SaveCase(self.initCases)
  self.initCases = nil
  self.nTime = 0
  if type(self.LevelStart) == "function" then
    self:LevelStart()
  end
  ;
  (EventManager.Hit)("RefreshFateCard", clone((self.parent)._mapFateCard))
  if nType == (GameEnum.starTowerRoomType).ShopRoom then
    (EventManager.Hit)("Guide_PassiveCheck_Msg", "Guide_ShopRoom")
  end
end

BaseRoom.Exit = function(self)
  -- function num : 0_6 , upvalues : _ENV
  (EventManager.Hit)("ShowStarTowerRoomInfo", false)
  ;
  (EventManager.Hit)("FRRoomEnd")
  self:_RemoveAllTimer()
  self:_UnbindEventCallback(self._mapEventConfig)
end

BaseRoom.ActiveTeleport = function(self)
  -- function num : 0_7 , upvalues : _ENV
  safe_call_cs_func((CS.AdventureModuleHelper).OpenActiveTeleporter)
  if not self.bShowTeleport then
    self.bShowTeleport = true
    self:ShowTeleportIndicator()
  end
end

BaseRoom.ShowTeleportIndicator = function(self)
  -- function num : 0_8 , upvalues : _ENV
  local mapMapData = (ConfigTable.GetData)("StarTowerMap", (self.parent).curMapId)
  if mapMapData ~= nil and mapMapData.OutPortHint then
    local tbTeleports = ((CS.AdventureModuleHelper).GetLevelTeleporters)()
    if tbTeleports ~= nil then
      for i = 0, tbTeleports.Count - 1 do
        (EventManager.Hit)("SetIndicator", 2, tbTeleports[i], Vector3.zero, nil)
      end
    end
  end
end

BaseRoom.SaveCase = function(self, tbCases)
  -- function num : 0_9 , upvalues : _ENV
  if tbCases == nil then
    return 
  end
  for _,mapCaseData in ipairs(tbCases) do
    if mapCaseData.BattleCase ~= nil then
      print("BattleCase")
      if (self.mapCases)[(self.EnumCase).Battle] ~= nil then
        printError("战斗事件重复 可能导致房间事件处理无法结束")
      end
      -- DECOMPILER ERROR at PC26: Confused about usage of register: R7 in 'UnsetPending'

      ;
      (self.mapCases)[(self.EnumCase).Battle] = {}
      -- DECOMPILER ERROR at PC32: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self.mapCases)[(self.EnumCase).Battle]).Id = mapCaseData.Id
      -- DECOMPILER ERROR at PC38: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self.mapCases)[(self.EnumCase).Battle]).Data = mapCaseData.BattleCase
      -- DECOMPILER ERROR at PC43: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self.mapCases)[(self.EnumCase).Battle]).bFinish = false
    else
      if mapCaseData.DoorCase ~= nil then
        if (mapCaseData.DoorCase).Type == (GameEnum.starTowerRoomType).DangerRoom then
          print("DangerRoomCase")
          local mapStarTower = (ConfigTable.GetData)("StarTower", (self.parent).nTowerId)
          local nNpcId = mapStarTower.DangerNpc
          local mapNpcCfgData = (ConfigTable.GetData)("NPCConfig", nNpcId)
          local nBoardNpcId = mapNpcCfgData.NPCId
          local nSkinId = (PlayerData.Board):GetNPCUsingSkinId(nBoardNpcId)
          -- DECOMPILER ERROR at PC78: Confused about usage of register: R12 in 'UnsetPending'

          ;
          (self.mapNpc)[nNpcId] = mapCaseData.Id
          safe_call_cs_func((CS.AdventureModuleHelper).SpawnNPC, nNpcId, nSkinId)
          -- DECOMPILER ERROR at PC96: Confused about usage of register: R12 in 'UnsetPending'

          if (self.mapCases)[(self.EnumCase).DoorDanger] == nil then
            (self.mapCases)[(self.EnumCase).DoorDanger] = {}
          end
          -- DECOMPILER ERROR at PC103: Confused about usage of register: R12 in 'UnsetPending'

          ;
          ((self.mapCases)[(self.EnumCase).DoorDanger])[mapCaseData.Id] = mapCaseData.DoorCase
          -- DECOMPILER ERROR at PC110: Confused about usage of register: R12 in 'UnsetPending'

          ;
          (((self.mapCases)[(self.EnumCase).DoorDanger])[mapCaseData.Id]).bFinish = false
        else
          do
            if (mapCaseData.DoorCase).Type == (GameEnum.starTowerRoomType).HorrorRoom then
              print("HorrorRoomCase")
              local mapStarTower = (ConfigTable.GetData)("StarTower", (self.parent).nTowerId)
              local nNpcId = mapStarTower.HorrorNpc
              local mapNpcCfgData = (ConfigTable.GetData)("NPCConfig", nNpcId)
              local nBoardNpcId = mapNpcCfgData.NPCId
              local nSkinId = (PlayerData.Board):GetNPCUsingSkinId(nBoardNpcId)
              -- DECOMPILER ERROR at PC142: Confused about usage of register: R12 in 'UnsetPending'

              ;
              (self.mapNpc)[nNpcId] = mapCaseData.Id
              safe_call_cs_func((CS.AdventureModuleHelper).SpawnNPC, nNpcId, nSkinId)
              -- DECOMPILER ERROR at PC160: Confused about usage of register: R12 in 'UnsetPending'

              if (self.mapCases)[(self.EnumCase).DoorDanger] == nil then
                (self.mapCases)[(self.EnumCase).DoorDanger] = {}
              end
              -- DECOMPILER ERROR at PC167: Confused about usage of register: R12 in 'UnsetPending'

              ;
              ((self.mapCases)[(self.EnumCase).DoorDanger])[mapCaseData.Id] = mapCaseData.DoorCase
              -- DECOMPILER ERROR at PC174: Confused about usage of register: R12 in 'UnsetPending'

              ;
              (((self.mapCases)[(self.EnumCase).DoorDanger])[mapCaseData.Id]).bFinish = false
            else
              do
                print("DoorCase")
                if (self.mapCases)[(self.EnumCase).OpenDoor] == nil then
                  self:ActiveTeleport()
                  -- DECOMPILER ERROR at PC195: Confused about usage of register: R7 in 'UnsetPending'

                  ;
                  (self.mapCases)[(self.EnumCase).OpenDoor] = {mapCaseData.Id, (mapCaseData.DoorCase).Type}
                end
                if mapCaseData.SelectPotentialCase ~= nil then
                  print("SelectPotentialCase")
                  -- DECOMPILER ERROR at PC213: Confused about usage of register: R7 in 'UnsetPending'

                  if (self.mapCases)[(self.EnumCase).PotentialSelect] == nil then
                    (self.mapCases)[(self.EnumCase).PotentialSelect] = {}
                  end
                  -- DECOMPILER ERROR at PC220: Confused about usage of register: R7 in 'UnsetPending'

                  ;
                  ((self.mapCases)[(self.EnumCase).PotentialSelect])[mapCaseData.Id] = mapCaseData.SelectPotentialCase
                  -- DECOMPILER ERROR at PC227: Confused about usage of register: R7 in 'UnsetPending'

                  ;
                  (((self.mapCases)[(self.EnumCase).PotentialSelect])[mapCaseData.Id]).bFinish = false
                else
                  if mapCaseData.SelectSpecialPotentialCase ~= nil then
                    print("SelectSpecialPotentialCase")
                    -- DECOMPILER ERROR at PC245: Confused about usage of register: R7 in 'UnsetPending'

                    if (self.mapCases)[(self.EnumCase).SelectSpecialPotential] == nil then
                      (self.mapCases)[(self.EnumCase).SelectSpecialPotential] = {}
                    end
                    -- DECOMPILER ERROR at PC252: Confused about usage of register: R7 in 'UnsetPending'

                    ;
                    ((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[mapCaseData.Id] = mapCaseData.SelectSpecialPotentialCase
                    -- DECOMPILER ERROR at PC259: Confused about usage of register: R7 in 'UnsetPending'

                    ;
                    (((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[mapCaseData.Id]).bFinish = false
                  else
                    if mapCaseData.SelectFateCardCase ~= nil then
                      print("SelectFateCardCase")
                      -- DECOMPILER ERROR at PC277: Confused about usage of register: R7 in 'UnsetPending'

                      if (self.mapCases)[(self.EnumCase).FateCardSelect] == nil then
                        (self.mapCases)[(self.EnumCase).FateCardSelect] = {}
                      end
                      -- DECOMPILER ERROR at PC284: Confused about usage of register: R7 in 'UnsetPending'

                      ;
                      ((self.mapCases)[(self.EnumCase).FateCardSelect])[mapCaseData.Id] = mapCaseData.SelectFateCardCase
                      -- DECOMPILER ERROR at PC291: Confused about usage of register: R7 in 'UnsetPending'

                      ;
                      (((self.mapCases)[(self.EnumCase).FateCardSelect])[mapCaseData.Id]).bFinish = false
                    else
                      if mapCaseData.SelectNoteCase ~= nil then
                        print("SelectNoteCase")
                        -- DECOMPILER ERROR at PC309: Confused about usage of register: R7 in 'UnsetPending'

                        if (self.mapCases)[(self.EnumCase).NoteSelect] == nil then
                          (self.mapCases)[(self.EnumCase).NoteSelect] = {}
                        end
                        -- DECOMPILER ERROR at PC316: Confused about usage of register: R7 in 'UnsetPending'

                        ;
                        ((self.mapCases)[(self.EnumCase).NoteSelect])[mapCaseData.Id] = mapCaseData.SelectNoteCase
                        -- DECOMPILER ERROR at PC323: Confused about usage of register: R7 in 'UnsetPending'

                        ;
                        (((self.mapCases)[(self.EnumCase).NoteSelect])[mapCaseData.Id]).bFinish = false
                      else
                        if mapCaseData.SelectOptionsEventCase ~= nil then
                          print("SelectOptionsEventCase")
                          -- DECOMPILER ERROR at PC341: Confused about usage of register: R7 in 'UnsetPending'

                          if (self.mapCases)[(self.EnumCase).NpcEvent] == nil then
                            (self.mapCases)[(self.EnumCase).NpcEvent] = {}
                          end
                          local mapEventCfgData = (ConfigTable.GetData)("StarTowerEvent", (mapCaseData.SelectOptionsEventCase).EvtId)
                          if mapEventCfgData ~= nil then
                            local nNpcId = (mapCaseData.SelectOptionsEventCase).NPCId
                            local mapNpcCfgData = (ConfigTable.GetData)("NPCConfig", nNpcId)
                            if mapNpcCfgData ~= nil then
                              local nBoardNpcId = mapNpcCfgData.NPCId
                              local nSkinId = (PlayerData.Board):GetNPCUsingSkinId(nBoardNpcId)
                              if (self.mapNpc)[nNpcId] ~= nil then
                                printError("NpcId重复" .. (mapCaseData.SelectOptionsEventCase).EvtId)
                              end
                              -- DECOMPILER ERROR at PC377: Confused about usage of register: R12 in 'UnsetPending'

                              ;
                              (self.mapNpc)[nNpcId] = mapCaseData.Id
                              safe_call_cs_func((CS.AdventureModuleHelper).SpawnNPC, nNpcId, nSkinId)
                              local nActionId = (mapCaseData.SelectOptionsEventCase).EvtId * 10000 + nNpcId
                              -- DECOMPILER ERROR at PC397: Confused about usage of register: R13 in 'UnsetPending'

                              if (ConfigTable.GetData)("StarTowerEventAction", nActionId) ~= nil then
                                (mapCaseData.SelectOptionsEventCase).nActionId = nActionId
                              else
                                printError("该事件没有对应的action" .. (mapCaseData.SelectOptionsEventCase).EvtId)
                                -- DECOMPILER ERROR at PC406: Confused about usage of register: R13 in 'UnsetPending'

                                ;
                                (mapCaseData.SelectOptionsEventCase).nActionId = 0
                              end
                            else
                              do
                                do
                                  do
                                    printError("没有找到对应NPC配置 " .. nNpcId)
                                    -- DECOMPILER ERROR at PC419: Confused about usage of register: R8 in 'UnsetPending'

                                    ;
                                    ((self.mapCases)[(self.EnumCase).NpcEvent])[mapCaseData.Id] = mapCaseData.SelectOptionsEventCase
                                    -- DECOMPILER ERROR at PC428: Confused about usage of register: R8 in 'UnsetPending'

                                    ;
                                    (((self.mapCases)[(self.EnumCase).NpcEvent])[mapCaseData.Id]).bFinish = (mapCaseData.SelectOptionsEventCase).Done
                                    -- DECOMPILER ERROR at PC435: Confused about usage of register: R8 in 'UnsetPending'

                                    ;
                                    (((self.mapCases)[(self.EnumCase).NpcEvent])[mapCaseData.Id]).bFirst = true
                                    if mapCaseData.RecoveryHPCase ~= nil then
                                      print("RecoveryHPCase")
                                      -- DECOMPILER ERROR at PC453: Confused about usage of register: R7 in 'UnsetPending'

                                      if (self.mapCases)[(self.EnumCase).RecoveryHP] == nil then
                                        (self.mapCases)[(self.EnumCase).RecoveryHP] = {}
                                      end
                                      -- DECOMPILER ERROR at PC460: Confused about usage of register: R7 in 'UnsetPending'

                                      ;
                                      ((self.mapCases)[(self.EnumCase).RecoveryHP])[mapCaseData.Id] = mapCaseData.RecoveryHPCase
                                      -- DECOMPILER ERROR at PC467: Confused about usage of register: R7 in 'UnsetPending'

                                      ;
                                      (((self.mapCases)[(self.EnumCase).RecoveryHP])[mapCaseData.Id]).bFinish = false
                                    else
                                      if mapCaseData.NpcRecoveryHPCase ~= nil then
                                        print("NpcRecoveryHPCase")
                                        local mapStarTower = (ConfigTable.GetData)("StarTower", (self.parent).nTowerId)
                                        local nNpcId = mapStarTower.ResqueNpc
                                        local mapNpcCfgData = (ConfigTable.GetData)("NPCConfig", nNpcId)
                                        local nBoardNpcId = mapNpcCfgData.NPCId
                                        local nSkinId = (PlayerData.Board):GetNPCUsingSkinId(nBoardNpcId)
                                        safe_call_cs_func((CS.AdventureModuleHelper).SpawnNPC, nNpcId, nSkinId)
                                        -- DECOMPILER ERROR at PC502: Confused about usage of register: R12 in 'UnsetPending'

                                        ;
                                        (self.mapNpc)[nNpcId] = mapCaseData.Id
                                        -- DECOMPILER ERROR at PC513: Confused about usage of register: R12 in 'UnsetPending'

                                        if (self.mapCases)[(self.EnumCase).NpcRecoveryHP] == nil then
                                          (self.mapCases)[(self.EnumCase).NpcRecoveryHP] = {}
                                        end
                                        -- DECOMPILER ERROR at PC520: Confused about usage of register: R12 in 'UnsetPending'

                                        ;
                                        ((self.mapCases)[(self.EnumCase).NpcRecoveryHP])[mapCaseData.Id] = mapCaseData.NpcRecoveryHPCase
                                        -- DECOMPILER ERROR at PC527: Confused about usage of register: R12 in 'UnsetPending'

                                        ;
                                        (((self.mapCases)[(self.EnumCase).NpcRecoveryHP])[mapCaseData.Id]).bFinish = false
                                      else
                                        do
                                          if mapCaseData.HawkerCase ~= nil then
                                            print("HawkerCase")
                                            local nType = (self.parent).nRoomType
                                            local mapStarTower = (ConfigTable.GetData)("StarTower", (self.parent).nTowerId)
                                            local nNpcId = mapStarTower.ShopNpc
                                            if nType ~= (GameEnum.starTowerRoomType).ShopRoom then
                                              nNpcId = mapStarTower.StandShopNpc
                                            end
                                            local mapNpcCfgData = (ConfigTable.GetData)("NPCConfig", nNpcId)
                                            local nBoardNpcId = mapNpcCfgData.NPCId
                                            local nSkinId = (PlayerData.Board):GetNPCUsingSkinId(nBoardNpcId)
                                            -- DECOMPILER ERROR at PC563: Confused about usage of register: R13 in 'UnsetPending'

                                            ;
                                            (self.mapNpc)[nNpcId] = mapCaseData.Id
                                            -- DECOMPILER ERROR at PC574: Confused about usage of register: R13 in 'UnsetPending'

                                            if (self.mapCases)[(self.EnumCase).Hawker] == nil then
                                              (self.mapCases)[(self.EnumCase).Hawker] = {}
                                            end
                                            -- DECOMPILER ERROR at PC581: Confused about usage of register: R13 in 'UnsetPending'

                                            ;
                                            ((self.mapCases)[(self.EnumCase).Hawker])[mapCaseData.Id] = mapCaseData.HawkerCase
                                            -- DECOMPILER ERROR at PC588: Confused about usage of register: R13 in 'UnsetPending'

                                            ;
                                            (((self.mapCases)[(self.EnumCase).Hawker])[mapCaseData.Id]).bFinish = false
                                            safe_call_cs_func((CS.AdventureModuleHelper).SpawnNPC, nNpcId, nSkinId)
                                          else
                                            do
                                              if mapCaseData.StrengthenMachineCase ~= nil then
                                                print("StrengthenMachineCase")
                                                local mapStarTower = (ConfigTable.GetData)("StarTower", (self.parent).nTowerId)
                                                local nNpcId = mapStarTower.UpgradeNpc
                                                local mapNpcCfgData = (ConfigTable.GetData)("NPCConfig", nNpcId)
                                                local nBoardNpcId = mapNpcCfgData.NPCId
                                                local nSkinId = (PlayerData.Board):GetNPCUsingSkinId(nBoardNpcId)
                                                -- DECOMPILER ERROR at PC623: Confused about usage of register: R12 in 'UnsetPending'

                                                ;
                                                (self.mapNpc)[nNpcId] = mapCaseData.Id
                                                -- DECOMPILER ERROR at PC634: Confused about usage of register: R12 in 'UnsetPending'

                                                if (self.mapCases)[(self.EnumCase).StrengthenMachine] == nil then
                                                  (self.mapCases)[(self.EnumCase).StrengthenMachine] = {}
                                                end
                                                -- DECOMPILER ERROR at PC641: Confused about usage of register: R12 in 'UnsetPending'

                                                ;
                                                ((self.mapCases)[(self.EnumCase).StrengthenMachine])[mapCaseData.Id] = mapCaseData.StrengthenMachineCase
                                                -- DECOMPILER ERROR at PC648: Confused about usage of register: R12 in 'UnsetPending'

                                                ;
                                                (((self.mapCases)[(self.EnumCase).StrengthenMachine])[mapCaseData.Id]).bFinish = false
                                                safe_call_cs_func((CS.AdventureModuleHelper).SpawnNPC, nNpcId, nSkinId)
                                              else
                                                do
                                                  do
                                                    -- DECOMPILER ERROR at PC664: Confused about usage of register: R7 in 'UnsetPending'

                                                    if mapCaseData.SyncHPCase ~= nil then
                                                      (self.mapCases)[(self.EnumCase).SyncHP] = mapCaseData.Id
                                                    end
                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC665: LeaveBlock: unexpected jumping out IF_STMT

                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

BaseRoom.SaveSelectResp = function(self, mapCaseData, nCaseId)
  -- function num : 0_10
  if not mapCaseData or not nCaseId then
    return 
  end
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R3 in 'UnsetPending'

  if mapCaseData.SelectPotentialCase ~= nil then
    ((self.mapCases)[(self.EnumCase).PotentialSelect])[nCaseId] = mapCaseData.SelectPotentialCase
    -- DECOMPILER ERROR at PC19: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (((self.mapCases)[(self.EnumCase).PotentialSelect])[nCaseId]).bFinish = false
    -- DECOMPILER ERROR at PC25: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (((self.mapCases)[(self.EnumCase).PotentialSelect])[nCaseId]).bReRoll = true
  else
    -- DECOMPILER ERROR at PC35: Confused about usage of register: R3 in 'UnsetPending'

    if mapCaseData.SelectSpecialPotentialCase ~= nil then
      ((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[nCaseId] = mapCaseData.SelectSpecialPotentialCase
      -- DECOMPILER ERROR at PC41: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[nCaseId]).bFinish = false
      -- DECOMPILER ERROR at PC47: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[nCaseId]).bReRoll = true
    else
      -- DECOMPILER ERROR at PC57: Confused about usage of register: R3 in 'UnsetPending'

      if mapCaseData.SelectFateCardCase ~= nil then
        ((self.mapCases)[(self.EnumCase).FateCardSelect])[nCaseId] = mapCaseData.SelectFateCardCase
        -- DECOMPILER ERROR at PC63: Confused about usage of register: R3 in 'UnsetPending'

        ;
        (((self.mapCases)[(self.EnumCase).FateCardSelect])[nCaseId]).bFinish = false
        -- DECOMPILER ERROR at PC69: Confused about usage of register: R3 in 'UnsetPending'

        ;
        (((self.mapCases)[(self.EnumCase).FateCardSelect])[nCaseId]).bReRoll = true
      else
        -- DECOMPILER ERROR at PC79: Confused about usage of register: R3 in 'UnsetPending'

        if mapCaseData.HawkerCase ~= nil then
          ((self.mapCases)[(self.EnumCase).Hawker])[nCaseId] = mapCaseData.HawkerCase
          -- DECOMPILER ERROR at PC85: Confused about usage of register: R3 in 'UnsetPending'

          ;
          (((self.mapCases)[(self.EnumCase).Hawker])[nCaseId]).bFinish = false
          -- DECOMPILER ERROR at PC91: Confused about usage of register: R3 in 'UnsetPending'

          ;
          (((self.mapCases)[(self.EnumCase).Hawker])[nCaseId]).bReRoll = true
        end
      end
    end
  end
end

BaseRoom.HandleNpc = function(self, nNpcId, nNpcUid)
  -- function num : 0_11 , upvalues : _ENV
  if self.blockNpcBtn then
    return 
  end
  local nCaseId = (self.mapNpc)[nNpcId]
  if nCaseId == nil then
    printError("Npc没有对应事件ID:" .. nNpcId)
    return 
  end
  local mapNpcCfgData = (ConfigTable.GetData)("NPCConfig", nNpcId)
  if mapNpcCfgData == nil then
    printError("Npc config missing:" .. nNpcId)
    return 
  end
  if mapNpcCfgData.type == (GameEnum.npcNewType).Narrate then
    local tbChat = ((ConfigTable.GetData)("NPCConfig", nNpcId)).Lines
    local nTalkId = tbChat[(math.random)(1, #tbChat)]
    if nTalkId == nil then
      nTalkId = 0
    end
    local nBoardNpcId = ((ConfigTable.GetData)("NPCConfig", nNpcId)).NPCId
    local nSkinId = (PlayerData.Board):GetNPCUsingSkinId(nBoardNpcId)
    local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.NpcOptionPanel, 0, 0, {}, nSkinId, 1, {}, {}, nTalkId, 0, true, false, nCoin, (self.parent).nTowerId, (self.parent)._mapNote)
    return 
  else
    do
      if mapNpcCfgData.type == (GameEnum.npcNewType).Event then
        self:OpenNpcOptionPanel(nCaseId, nNpcId)
        return 
      else
        if mapNpcCfgData.type == (GameEnum.npcNewType).Resque then
          self:HandleNpcRecover(nCaseId, nNpcId)
          return 
        else
          if mapNpcCfgData.type == (GameEnum.npcNewType).Danger then
            self:HandleNpcDangerRoom(nCaseId, nNpcId)
            return 
          else
            if mapNpcCfgData.type == (GameEnum.npcNewType).Horror then
              self:HandleNpcDangerRoom(nCaseId, nNpcId)
              return 
            else
              if mapNpcCfgData.type == (GameEnum.npcNewType).Shop then
                self:InteractiveShop(nCaseId, nNpcId)
                return 
              else
                if mapNpcCfgData.type == (GameEnum.npcNewType).Upgrade then
                  self:InteractiveStrengthMachine(nCaseId, nNpcId)
                  return 
                else
                  printError("待处理事件")
                end
              end
            end
          end
        end
      end
      printError("没有找到可交互的事件:" .. nNpcId)
    end
  end
end

BaseRoom.GetBattleCase = function(self)
  -- function num : 0_12 , upvalues : _ENV
  if (self.mapCases)[(self.EnumCase).PotentialSelect] ~= nil then
    for nId,mapData in pairs((self.mapCases)[(self.EnumCase).PotentialSelect]) do
      if mapData.bFinish ~= true then
        return 
      end
    end
  end
  do
    return false
  end
end

BaseRoom.HandleCases = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local wait_case = function(callback)
    -- function num : 0_13_0 , upvalues : _ENV
    (EventManager.Hit)(EventId.BlockInput, true)
    local wait = function()
      -- function num : 0_13_0_0 , upvalues : _ENV, callback
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (EventManager.Hit)(EventId.BlockInput, false)
      callback()
    end

    ;
    (cs_coroutine.start)(wait)
  end

  if (self.tbPopup)[(self.EnumPopup).StrengthFx] ~= nil then
    for _,mapData in ipairs((self.tbPopup)[(self.EnumPopup).StrengthFx]) do
      do
        if not mapData.bFinish then
          do
            self:HandleShopStrengthFx(mapData)
            do return  end
            -- DECOMPILER ERROR at PC21: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC21: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
  if (self.tbPopup)[(self.EnumPopup).Potential] ~= nil then
    for _,mapData in ipairs((self.tbPopup)[(self.EnumPopup).Potential]) do
      if not mapData.bFinish then
        wait_case(function()
    -- function num : 0_13_1 , upvalues : self, mapData
    self:HandlePopupPotential(mapData)
  end
)
        return 
      end
    end
  end
  do
    if (self.tbPopup)[(self.EnumPopup).Reward] ~= nil then
      for _,mapData in ipairs((self.tbPopup)[(self.EnumPopup).Reward]) do
        if not mapData.bFinish then
          wait_case(function()
    -- function num : 0_13_2 , upvalues : self, mapData
    self:HandlePopupReward(mapData)
  end
)
          return 
        end
      end
    end
    do
      if (self.mapCases)[(self.EnumCase).RecoveryHP] ~= nil then
        for nId,mapData in pairs((self.mapCases)[(self.EnumCase).RecoveryHP]) do
          if mapData.bFinish ~= true then
            self:HandleRecover(nId)
            return 
          end
        end
      end
      do
        if (self.mapCases)[(self.EnumCase).SelectSpecialPotential] ~= nil then
          for nId,mapData in pairs((self.mapCases)[(self.EnumCase).SelectSpecialPotential]) do
            if mapData.bFinish ~= true then
              wait_case(function()
    -- function num : 0_13_3 , upvalues : self, nId
    self:OpenSelectPotential(nId, true)
  end
)
              return 
            end
          end
        end
        do
          if (self.mapCases)[(self.EnumCase).PotentialSelect] ~= nil then
            for nId,mapData in pairs((self.mapCases)[(self.EnumCase).PotentialSelect]) do
              if mapData.bFinish ~= true then
                wait_case(function()
    -- function num : 0_13_4 , upvalues : self, nId
    self:OpenSelectPotential(nId)
  end
)
                return 
              end
            end
          end
          do
            if (self.mapCases)[(self.EnumCase).NoteSelect] ~= nil then
              for nId,mapData in pairs((self.mapCases)[(self.EnumCase).NoteSelect]) do
                if mapData.bFinish ~= true then
                  wait_case(function()
    -- function num : 0_13_5 , upvalues : self, nId
    self:OpenSelectNote(nId)
  end
)
                  return 
                end
              end
            end
            do
              if (self.mapCases)[(self.EnumCase).FateCardSelect] ~= nil then
                for nId,mapData in pairs((self.mapCases)[(self.EnumCase).FateCardSelect]) do
                  if mapData.bFinish ~= true then
                    wait_case(function()
    -- function num : 0_13_6 , upvalues : self, nId
    self:OpenSelectFateCard(nId)
  end
)
                    return 
                  end
                end
              end
              do
                if (self.tbPopup)[(self.EnumPopup).Disc] ~= nil then
                  for _,mapData in ipairs((self.tbPopup)[(self.EnumPopup).Disc]) do
                    if not mapData.bFinish then
                      wait_case(function()
    -- function num : 0_13_7 , upvalues : self, mapData
    self:HandlePopupDisc(mapData)
  end
)
                      return 
                    end
                  end
                end
                do
                  if (self.tbPopup)[(self.EnumPopup).Affinity] ~= nil then
                    for _,mapData in ipairs((self.tbPopup)[(self.EnumPopup).Affinity]) do
                      (EventManager.Hit)("ShowNPCAffinity", mapData.NPCId, mapData.Increase)
                    end
                    -- DECOMPILER ERROR at PC231: Confused about usage of register: R2 in 'UnsetPending'

                    ;
                    (self.tbPopup)[(self.EnumPopup).Affinity] = {}
                  end
                  self.blockNpcBtn = false
                  return false
                end
              end
            end
          end
        end
      end
    end
  end
end

BaseRoom.OpenSelectPotential = function(self, nCaseId, bSpecial)
  -- function num : 0_14 , upvalues : _ENV
  local ProcessSpecialPotentialData = function(nId)
    -- function num : 0_14_0 , upvalues : self, _ENV
    local mapCaseData = ((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[nId]
    local tbPotential = {}
    local mapPotential = {}
    for _,nPotentialId in ipairs(mapCaseData.Ids) do
      (table.insert)(tbPotential, {Id = nPotentialId, Count = 1})
      mapPotential[nPotentialId] = 0
      local mapPotentialCfgData = (ConfigTable.GetData)("Potential", nPotentialId)
      if mapPotentialCfgData == nil then
        printError("PotentialCfgData Missing" .. nPotentialId)
        return 
      end
      local nCharId = mapPotentialCfgData.CharId
      if (((self.parent)._mapPotential)[nCharId])[nPotentialId] ~= nil then
        mapPotential[nPotentialId] = (((self.parent)._mapPotential)[nCharId])[nPotentialId]
      end
    end
    local nType = 0
    if mapCaseData.TeamLevel > 0 then
      nType = 1
    end
    local mapRoll = {CanReRoll = mapCaseData.CanReRoll, ReRollPrice = mapCaseData.ReRollPrice}
    return tbPotential, mapPotential, nType, mapCaseData.TeamLevel, mapCaseData.NewIds, mapRoll
  end

  local ProcessPotentialData = function(nId)
    -- function num : 0_14_1 , upvalues : self, _ENV
    local mapCaseData = ((self.mapCases)[(self.EnumCase).PotentialSelect])[nId]
    local tbPotential = {}
    local mapPotential = {}
    for _,mapPotentialInfo in ipairs(mapCaseData.Infos) do
      (table.insert)(tbPotential, {Id = mapPotentialInfo.Tid, Count = mapPotentialInfo.Level})
      mapPotential[mapPotentialInfo.Tid] = 0
      local mapPotentialCfgData = (ConfigTable.GetData)("Potential", mapPotentialInfo.Tid)
      if mapPotentialCfgData == nil then
        printError("PotentialCfgData Missing" .. mapPotentialInfo.Tid)
        return 
      end
      local nCharId = mapPotentialCfgData.CharId
      if (((self.parent)._mapPotential)[nCharId])[mapPotentialInfo.Tid] ~= nil then
        mapPotential[mapPotentialInfo.Tid] = (((self.parent)._mapPotential)[nCharId])[mapPotentialInfo.Tid]
      end
    end
    local mapRoll = {CanReRoll = mapCaseData.CanReRoll, ReRollPrice = mapCaseData.ReRollPrice}
    return tbPotential, mapPotential, mapCaseData.Type, mapCaseData.TeamLevel, mapCaseData.NewIds, mapRoll, mapCaseData.LuckyIds
  end

  local GetUnfinishedSelect = function()
    -- function num : 0_14_2 , upvalues : self, _ENV, ProcessSpecialPotentialData, ProcessPotentialData
    if (self.mapCases)[(self.EnumCase).SelectSpecialPotential] ~= nil then
      for nId,mapData in pairs((self.mapCases)[(self.EnumCase).SelectSpecialPotential]) do
        if mapData.bFinish ~= true then
          local tbPotential, mapPotential, nType, nLevel, tbNewIds, mapRoll = ProcessSpecialPotentialData(nId)
          return nId, tbPotential, mapPotential, nType, nLevel, tbNewIds, mapRoll
        end
      end
    end
    do
      if (self.mapCases)[(self.EnumCase).PotentialSelect] ~= nil then
        for nId,mapData in pairs((self.mapCases)[(self.EnumCase).PotentialSelect]) do
          if mapData.bFinish ~= true then
            local tbPotential, mapPotential, nType, nLevel, tbNewIds, mapRoll, tbLuckyIds = ProcessPotentialData(nId)
            return nId, tbPotential, mapPotential, nType, nLevel, tbNewIds, mapRoll, tbLuckyIds
          end
        end
      end
      do
        return 0, {}, {}, 0
      end
    end
  end

  local SelectCallback = function(nIdx, nId, panelCallback, bReRoll)
    -- function num : 0_14_3 , upvalues : _ENV, self, GetUnfinishedSelect
    do
      if nId == -1 then
        local wait = function()
      -- function num : 0_14_3_0 , upvalues : _ENV, self
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      self:HandleCases()
    end

        ;
        (cs_coroutine.start)(wait)
        return 
      end
      local msg = {}
      msg.Id = nId
      msg.SelectReq = {}
      -- DECOMPILER ERROR at PC15: Confused about usage of register: R5 in 'UnsetPending'

      if bReRoll then
        (msg.SelectReq).ReRoll = true
      else
        -- DECOMPILER ERROR at PC19: Confused about usage of register: R5 in 'UnsetPending'

        ;
        (msg.SelectReq).Index = nIdx - 1
      end
      local InteractiveCallback = function(callbackMsg)
      -- function num : 0_14_3_1 , upvalues : self, nId, GetUnfinishedSelect, _ENV, panelCallback
      local Id = callbackMsg.Id
      -- DECOMPILER ERROR at PC29: Confused about usage of register: R2 in 'UnsetPending'

      if (self.mapCases)[(self.EnumCase).SelectSpecialPotential] ~= nil and ((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[Id] ~= nil then
        if (((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[nId]).bReRoll then
          (((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[nId]).bReRoll = false
        else
          -- DECOMPILER ERROR at PC36: Confused about usage of register: R2 in 'UnsetPending'

          ;
          (((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[Id]).bFinish = true
        end
      end
      -- DECOMPILER ERROR at PC65: Confused about usage of register: R2 in 'UnsetPending'

      if (self.mapCases)[(self.EnumCase).PotentialSelect] ~= nil and ((self.mapCases)[(self.EnumCase).PotentialSelect])[Id] ~= nil then
        if (((self.mapCases)[(self.EnumCase).PotentialSelect])[nId]).bReRoll then
          (((self.mapCases)[(self.EnumCase).PotentialSelect])[nId]).bReRoll = false
        else
          -- DECOMPILER ERROR at PC72: Confused about usage of register: R2 in 'UnsetPending'

          ;
          (((self.mapCases)[(self.EnumCase).PotentialSelect])[Id]).bFinish = true
        end
      end
      local caseId, tbPotential, mapPotential, nType, nTeamLevel, tbNewIds, mapRoll, tbLuckyIds = GetUnfinishedSelect()
      local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
      if panelCallback ~= nil and type(panelCallback) == "function" then
        local tbRecommend = (self.parent):GetRecommondPotential(tbPotential)
        panelCallback(caseId, tbPotential, mapPotential, nType, nTeamLevel, tbNewIds, mapRoll, nCoin, tbLuckyIds, tbRecommend)
      end
    end

      ;
      (self.parent):StarTowerInteract(msg, InteractiveCallback)
    end
  end

  local tbPotential, mapPotential, nType, nTeamLevel, tbNewIds, mapRoll, tbLuckyIds = nil, nil, nil, nil, nil, nil, nil
  if bSpecial then
    tbPotential = ProcessSpecialPotentialData(nCaseId)
  else
    -- DECOMPILER ERROR at PC21: Overwrote pending register: R12 in 'AssignReg'

    -- DECOMPILER ERROR at PC22: Overwrote pending register: R11 in 'AssignReg'

    -- DECOMPILER ERROR at PC23: Overwrote pending register: R10 in 'AssignReg'

    -- DECOMPILER ERROR at PC24: Overwrote pending register: R9 in 'AssignReg'

    -- DECOMPILER ERROR at PC25: Overwrote pending register: R8 in 'AssignReg'

    tbPotential = ProcessPotentialData(nCaseId)
  end
  local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
  local tbRecommend = (self.parent):GetRecommondPotential(tbPotential)
  ;
  (EventManager.Hit)("StarTowerPotentialSelect", nCaseId, tbPotential, mapPotential, nType, nTeamLevel, tbNewIds, SelectCallback, mapRoll, nCoin, tbLuckyIds, tbRecommend)
end

BaseRoom.OpenSelectNote = function(self, nCaseId)
  -- function num : 0_15 , upvalues : _ENV
  local ProcessNoteData = function(nId)
    -- function num : 0_15_0 , upvalues : self
    local mapCaseData = ((self.mapCases)[(self.EnumCase).NoteSelect])[nId]
    local tbNoteSelect = mapCaseData.Info
    local mapNote = (self.parent)._mapNote
    return tbNoteSelect, mapNote
  end

  local GetUnfinishedSelect = function()
    -- function num : 0_15_1 , upvalues : self, _ENV, ProcessNoteData
    if (self.mapCases)[(self.EnumCase).NoteSelect] ~= nil then
      for nId,mapData in pairs((self.mapCases)[(self.EnumCase).NoteSelect]) do
        if mapData.bFinish ~= true then
          local tbPotential, mapPotential = ProcessNoteData(nId)
          return nId, tbPotential, mapPotential
        end
      end
    end
    do
      return 0, {}, {}
    end
  end

  local SelectCallback = function(nIdx, nId, panelCallback)
    -- function num : 0_15_2 , upvalues : _ENV, self, GetUnfinishedSelect
    do
      if nIdx == -1 then
        local wait = function()
      -- function num : 0_15_2_0 , upvalues : _ENV, self
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      self:HandleCases()
    end

        ;
        (cs_coroutine.start)(wait)
        return 
      end
      local msg = {}
      msg.Id = nId
      msg.SelectReq = {}
      -- DECOMPILER ERROR at PC14: Confused about usage of register: R4 in 'UnsetPending'

      ;
      (msg.SelectReq).Index = nIdx - 1
      local InteractiveCallback = function(callbackMsg)
      -- function num : 0_15_2_1 , upvalues : self, GetUnfinishedSelect, panelCallback, _ENV
      local Id = callbackMsg.Id
      -- DECOMPILER ERROR at PC19: Confused about usage of register: R2 in 'UnsetPending'

      if (self.mapCases)[(self.EnumCase).NoteSelect] ~= nil and ((self.mapCases)[(self.EnumCase).NoteSelect])[Id] ~= nil then
        (((self.mapCases)[(self.EnumCase).NoteSelect])[Id]).bFinish = true
      end
      local caseId, tbNoteSelect, mapNote = GetUnfinishedSelect()
      if panelCallback ~= nil and type(panelCallback) == "function" then
        panelCallback(caseId, tbNoteSelect, mapNote)
      end
    end

      ;
      (self.parent):StarTowerInteract(msg, InteractiveCallback)
    end
  end

  local tbNoteSelect, mapNote = ProcessNoteData(nCaseId)
  ;
  (EventManager.Hit)("StarTowerSelectNote", nCaseId, mapNote, tbNoteSelect, SelectCallback)
end

BaseRoom.OpenSelectFateCard = function(self, nCaseId)
  -- function num : 0_16 , upvalues : _ENV
  local ProcessFateCard = function(nId)
    -- function num : 0_16_0 , upvalues : self
    local mapCaseData = ((self.mapCases)[(self.EnumCase).FateCardSelect])[nId]
    local tbFateCard = mapCaseData.Ids
    local tbNewIds = mapCaseData.NewIds
    local bReward = mapCaseData.Give
    local mapRoll = {CanReRoll = mapCaseData.CanReRoll, ReRollPrice = mapCaseData.ReRollPrice}
    return tbFateCard, tbNewIds, mapRoll, bReward
  end

  local GetUnfinishedSelect = function()
    -- function num : 0_16_1 , upvalues : self, _ENV, ProcessFateCard
    if (self.mapCases)[(self.EnumCase).FateCardSelect] ~= nil then
      for nId,mapData in pairs((self.mapCases)[(self.EnumCase).FateCardSelect]) do
        if mapData.bFinish ~= true then
          local tbFateCard, tbNewIds, mapRoll, bReward = ProcessFateCard(nId)
          return nId, tbFateCard, tbNewIds, mapRoll, bReward
        end
      end
    end
    do
      return 0, {}, {}
    end
  end

  local SelectCallback = function(nIdx, nId, panelCallback, bReRoll)
    -- function num : 0_16_2 , upvalues : _ENV, self, GetUnfinishedSelect
    do
      if nIdx == -1 then
        local wait = function()
      -- function num : 0_16_2_0 , upvalues : _ENV, self
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      self:HandleCases()
    end

        ;
        (cs_coroutine.start)(wait)
        return 
      end
      local msg = {}
      msg.Id = nId
      msg.SelectReq = {}
      -- DECOMPILER ERROR at PC15: Confused about usage of register: R5 in 'UnsetPending'

      if bReRoll then
        (msg.SelectReq).ReRoll = true
      else
        -- DECOMPILER ERROR at PC19: Confused about usage of register: R5 in 'UnsetPending'

        ;
        (msg.SelectReq).Index = nIdx - 1
      end
      local InteractiveCallback = function(callbackMsg)
      -- function num : 0_16_2_1 , upvalues : self, nId, GetUnfinishedSelect, _ENV, panelCallback
      local Id = callbackMsg.Id
      -- DECOMPILER ERROR at PC30: Confused about usage of register: R2 in 'UnsetPending'

      if (self.mapCases)[(self.EnumCase).FateCardSelect] ~= nil and ((self.mapCases)[(self.EnumCase).FateCardSelect])[nId] ~= nil then
        if (((self.mapCases)[(self.EnumCase).FateCardSelect])[nId]).bReRoll then
          (((self.mapCases)[(self.EnumCase).FateCardSelect])[nId]).bReRoll = false
        else
          -- DECOMPILER ERROR at PC38: Confused about usage of register: R2 in 'UnsetPending'

          ;
          (((self.mapCases)[(self.EnumCase).FateCardSelect])[nId]).bFinish = true
        end
      end
      local caseId, tbFateCard, tbNewIds, mapRoll, bReward = GetUnfinishedSelect()
      local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
      if panelCallback ~= nil and type(panelCallback) == "function" then
        panelCallback(caseId, tbFateCard, tbNewIds, mapRoll, nCoin, bReward)
      end
    end

      ;
      (self.parent):StarTowerInteract(msg, InteractiveCallback)
    end
  end

  local tbFateCard, tbNewIds, mapRoll, bReward = ProcessFateCard(nCaseId)
  local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
  ;
  (EventManager.Hit)("StarTowerSelectFateCard", nCaseId, tbFateCard, tbNewIds, SelectCallback, mapRoll, nCoin, bReward)
end

BaseRoom.OpenNpcOptionPanel = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_17 , upvalues : _ENV
  if (self.mapCases)[(self.EnumCase).NpcEvent] == nil then
    printError("No NpcOptionCase!")
    return 
  end
  local mapCase = ((self.mapCases)[(self.EnumCase).NpcEvent])[nCaseId]
  if mapCase == nil then
    printError("No NpcOptionCase! :" .. nCaseId)
    return 
  end
  local nBoardNpcId = ((ConfigTable.GetData)("NPCConfig", nNpcConfigId)).NPCId
  local nSkinId = (PlayerData.Board):GetNPCUsingSkinId(nBoardNpcId)
  local mapAffinity = {}
  for _,mapInfo in ipairs(mapCase.Infos) do
    mapAffinity[mapInfo.NPCId] = mapInfo.Affinity
  end
  if mapCase.bFinish then
    local tbLines = ((ConfigTable.GetData)("NPCConfig", nNpcConfigId)).Lines
    local tbChat = {}
    for _,nTalkId in ipairs(tbLines) do
      local mapTalkCfg = (ConfigTable.GetData)("StarTowerTalk", nTalkId)
      if mapTalkCfg ~= nil and mapAffinity[mapTalkCfg.NPCId] ~= nil then
        local nAffinity = mapAffinity[mapTalkCfg.NPCId]
        if #mapTalkCfg.Affinity == 2 and nAffinity ~= nil and (mapTalkCfg.Affinity)[1] < nAffinity and nAffinity <= (mapTalkCfg.Affinity)[2] then
          (table.insert)(tbChat, nTalkId)
        end
      end
    end
    if #tbChat < 1 then
      (table.insert)(tbChat, tbLines[1])
    end
    local nCount = #tbChat
    local nTalkId = tbChat[1]
    if nCount > 1 then
      nTalkId = tbChat[(math.random)(1, #tbChat)]
    end
    if nTalkId == nil then
      nTalkId = 0
    end
    local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.NpcOptionPanel, 0, 0, {}, nSkinId, 1, {}, {}, nTalkId, 0, true, false, nCoin, (self.parent).nTowerId, (self.parent)._mapNote)
    return 
  end
  do
    local tbOption = mapCase.Options
    local tbUnabledOption = mapCase.FailedIdxes
    local nTableEvtId = mapCase.EvtId
    local nEventId = nCaseId
    local callback = function(nIdx, nEvtId)
    -- function num : 0_17_0 , upvalues : _ENV, nNpcConfigId, tbOption, self, nCaseId, mapCase
    (EventManager.Hit)("InteractiveNpcFinish", nNpcConfigId)
    local nOptionId = tbOption[nIdx]
    local mapOptionData = (ConfigTable.GetData)("EventOptions", nOptionId)
    local bJump = false
    if mapOptionData ~= nil then
      bJump = mapOptionData.IgnoreInterActive
    else
      printError("EventOptions Missing：" .. nOptionId)
    end
    if bJump then
      return 
    end
    local msg = {}
    msg.Id = nEvtId
    msg.SelectReq = {}
    -- DECOMPILER ERROR at PC30: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (msg.SelectReq).Index = nIdx - 1
    local InteractiveCallback = function(callbackMsg, tbChangeFateCard, mapChangeNote, mapItemChange, nLevelChange, nExpChange, mapPotentialChange, mapChangeSecondarySkill)
      -- function num : 0_17_0_0 , upvalues : _ENV, self, nCaseId, mapCase, nIdx
      local wait = function()
        -- function num : 0_17_0_0_0 , upvalues : _ENV, self
        (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
        ;
        (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
        self:HandleCases()
      end

      local bSuccess = false
      if callbackMsg.SelectResp ~= nil and (callbackMsg.SelectResp).Resp ~= nil then
        bSuccess = ((callbackMsg.SelectResp).Resp).OptionsResult
      end
      -- DECOMPILER ERROR at PC20: Confused about usage of register: R10 in 'UnsetPending'

      if bSuccess then
        (((self.mapCases)[(self.EnumCase).NpcEvent])[nCaseId]).bFinish = true
        local tbInfo = {}
        -- DECOMPILER ERROR at PC32: Confused about usage of register: R11 in 'UnsetPending'

        if (self.tbPopup)[(self.EnumPopup).Affinity] == nil then
          (self.tbPopup)[(self.EnumPopup).Affinity] = {}
        end
        for _,mapChange in ipairs(((callbackMsg.SelectResp).Resp).AffinityChange) do
          (table.insert)(tbInfo, {NPCId = mapChange.NPCId, Affinity = mapChange.Affinity})
          ;
          (table.insert)((self.tbPopup)[(self.EnumPopup).Affinity], {NPCId = mapChange.NPCId, Increase = mapChange.Increase})
        end
        -- DECOMPILER ERROR at PC68: Confused about usage of register: R11 in 'UnsetPending'

        ;
        (((self.mapCases)[(self.EnumCase).NpcEvent])[nCaseId]).Infos = tbInfo
        ;
        (EventManager.Hit)("StarTowerEventInteract", clone(mapChangeNote), clone(mapItemChange), clone(mapPotentialChange), clone(tbChangeFateCard), clone(mapChangeSecondarySkill))
        ;
        (cs_coroutine.start)(wait)
      else
        do
          ;
          (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Startower_EventFailHint"))
          ;
          (table.insert)(mapCase.FailedIdxes, nIdx - 1)
          if callbackMsg.SelectResp ~= nil and (callbackMsg.SelectResp).Resp ~= nil and ((callbackMsg.SelectResp).Resp).OptionsParamId ~= nil and ((callbackMsg.SelectResp).Resp).OptionsParamId ~= 0 then
            local sTextId = "EventResult_" .. tostring(((callbackMsg.SelectResp).Resp).OptionsParamId)
            local sResultHint = (ConfigTable.GetUIText)(sTextId)
            ;
            (EventManager.Hit)(EventId.OpenMessageBox, sResultHint)
          end
        end
      end
    end

    ;
    (self.parent):StarTowerInteract(msg, InteractiveCallback)
  end

    local tbLines = ((ConfigTable.GetData)("NPCConfig", nNpcConfigId)).FirstLines
    local tbChat = {}
    for _,nTalkId in ipairs(tbLines) do
      local mapTalkCfg = (ConfigTable.GetData)("StarTowerTalk", nTalkId)
      if mapTalkCfg ~= nil and mapAffinity[mapTalkCfg.NPCId] ~= nil then
        local nAffinity = mapAffinity[mapTalkCfg.NPCId]
        if #mapTalkCfg.Affinity == 2 and nAffinity ~= nil and (mapTalkCfg.Affinity)[1] < nAffinity and nAffinity <= (mapTalkCfg.Affinity)[2] then
          (table.insert)(tbChat, nTalkId)
        end
      end
    end
    if #tbChat < 1 then
      (table.insert)(tbChat, tbLines[1])
    end
    local nCount = #tbChat
    local nTalkId = tbChat[1]
    if nCount > 1 then
      nTalkId = tbChat[(math.random)(1, #tbChat)]
    end
    if nTalkId == nil then
      nTalkId = 0
    end
    mapCase.bFirst = false
    local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.NpcOptionPanel, 1, nEventId, tbOption, nSkinId, callback, tbUnabledOption, nTableEvtId, nTalkId, mapCase.nActionId, false, false, nCoin, (self.parent).nTowerId, (self.parent)._mapNote)
  end
end

BaseRoom.HandleRecover = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_18 , upvalues : _ENV
  if (self.mapCases)[(self.EnumCase).RecoveryHP] == nil then
    printError("No RecoveryHP!")
    return 
  end
  local mapCase = ((self.mapCases)[(self.EnumCase).RecoveryHP])[nCaseId]
  if mapCase == nil then
    printError("No RecoveryHP! :" .. nCaseId)
    return 
  end
  if mapCase.bFinish then
    printError("Event has finished! :" .. nCaseId)
    return 
  end
  local nEftId = mapCase.EffectId
  local nHp = (self.parent):RecoverHp(nEftId)
  local msg = {}
  msg.Id = nCaseId
  msg.RecoveryHPReq = {}
  -- DECOMPILER ERROR at PC42: Confused about usage of register: R7 in 'UnsetPending'

  ;
  (msg.RecoveryHPReq).Hp = nHp
  local callback = function(_, msgData)
    -- function num : 0_18_0 , upvalues : self, nCaseId
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

    (((self.mapCases)[(self.EnumCase).RecoveryHP])[nCaseId]).bFinish = true
    self:HandleCases()
  end

  ;
  (self.parent):StarTowerInteract(msg, callback)
end

BaseRoom.HandleNpcRecover = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_19 , upvalues : _ENV
  if (self.mapCases)[(self.EnumCase).NpcRecoveryHP] == nil then
    printError("No NpcOptionCase!")
    return 
  end
  local mapCase = ((self.mapCases)[(self.EnumCase).NpcRecoveryHP])[nCaseId]
  if mapCase == nil then
    printError("No NpcOptionCase! :" .. nCaseId)
    return 
  end
  if mapCase.bFinish then
    local nBoardNpcId = ((ConfigTable.GetData)("NPCConfig", nNpcConfigId)).NPCId
    local nSkinId = (PlayerData.Board):GetNPCUsingSkinId(nBoardNpcId)
    local tbChat = ((ConfigTable.GetData)("NPCConfig", nNpcConfigId)).Lines
    local nCount = #tbChat
    local nTalkId = tbChat[1]
    if nCount > 1 then
      nTalkId = tbChat[(math.random)(1, #tbChat)]
    end
    if nTalkId == nil then
      nTalkId = 0
    end
    local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.NpcOptionPanel, 0, 0, {}, nSkinId, 1, {}, {}, nTalkId, 0, true, false, nCoin, (self.parent).nTowerId, (self.parent)._mapNote)
    return 
  end
  do
    local nEftId = mapCase.EffectId
    local nHp = (self.parent):RecoverHp(nEftId)
    local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
    WwiseAudioMgr:PostEvent("ui_battle_cure")
    local msg = {}
    msg.Id = nCaseId
    msg.RecoveryHPReq = {}
    -- DECOMPILER ERROR at PC105: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (msg.RecoveryHPReq).Hp = nHp
    local callback = function(_, msgData)
    -- function num : 0_19_0 , upvalues : _ENV, nNpcConfigId, self, nCaseId
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("StarTower_NpcRecoverTips"))
    ;
    (EventManager.Hit)("InteractiveNpcFinish", nNpcConfigId)
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (((self.mapCases)[(self.EnumCase).NpcRecoveryHP])[nCaseId]).bFinish = true
  end

    ;
    (self.parent):StarTowerInteract(msg, callback)
  end
end

BaseRoom.HandleNpcDangerRoom = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_20 , upvalues : _ENV
  if (self.mapCases)[(self.EnumCase).DoorDanger] == nil then
    printError("No NpcOptionCase!")
    return 
  end
  local mapCase = ((self.mapCases)[(self.EnumCase).DoorDanger])[nCaseId]
  if mapCase == nil then
    printError("No NpcOptionCase! :" .. nCaseId)
    return 
  end
  local nRoomType = mapCase.Type
  local nBoardNpcId = ((ConfigTable.GetData)("NPCConfig", nNpcConfigId)).NPCId
  local nSkinId = (PlayerData.Board):GetNPCUsingSkinId(nBoardNpcId)
  local callback = function(nIdx, nEvtId)
    -- function num : 0_20_0 , upvalues : _ENV, nNpcConfigId, self, nRoomType
    (EventManager.Hit)("InteractiveNpcFinish", nNpcConfigId)
    if nIdx == 1 then
      (self.parent):EnterRoom(nEvtId, nRoomType)
    else
      return 
    end
  end

  local tbChat = ((ConfigTable.GetData)("NPCConfig", nNpcConfigId)).Lines
  local nTalkId = tbChat[(math.random)(1, #tbChat)]
  if nTalkId == nil then
    nTalkId = 0
  end
  local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.NpcOptionPanel, 2, nCaseId, {}, nSkinId, callback, {}, 0, nTalkId, 0, false, false, nCoin, (self.parent).nTowerId, (self.parent)._mapNote)
end

BaseRoom.HandlePopupDisc = function(self, mapData)
  -- function num : 0_21 , upvalues : _ENV
  local callback = function()
    -- function num : 0_21_0 , upvalues : mapData, self
    mapData.bFinish = true
    self:HandleCases()
  end

  ;
  (EventManager.Hit)("StarTowerShowDiscSkill", mapData.param, clone((self.parent)._mapNote), callback)
end

BaseRoom.HandlePopupReward = function(self, mapData)
  -- function num : 0_22 , upvalues : _ENV
  local callback = function()
    -- function num : 0_22_0 , upvalues : mapData, self
    mapData.bFinish = true
    self:HandleCases()
  end

  ;
  (EventManager.Hit)("StarTowerShowReward", mapData.param, callback)
end

BaseRoom.HandlePopupPotential = function(self, mapData)
  -- function num : 0_23 , upvalues : _ENV
  local callback = function()
    -- function num : 0_23_0 , upvalues : mapData, self
    mapData.bFinish = true
    self:HandleCases()
  end

  ;
  (EventManager.Hit)("ShowPotentialLevelUp", mapData.param, callback)
end

BaseRoom.HandleShopStrengthFx = function(self, mapData)
  -- function num : 0_24 , upvalues : _ENV
  local callback = function()
    -- function num : 0_24_0 , upvalues : mapData, self
    mapData.bFinish = true
    self:HandleCases()
  end

  ;
  (EventManager.Hit)("ShowShopStrengthFx", mapData.param, callback)
end

BaseRoom.InteractiveShop = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_25 , upvalues : _ENV, WwiseAudioMgr
  if (self.mapCases)[(self.EnumCase).Hawker] == nil then
    printError("No Hawker Case!")
    return 
  end
  local mapCase = ((self.mapCases)[(self.EnumCase).Hawker])[nCaseId]
  if mapCase == nil then
    printError("No Hawker Case! :" .. nCaseId)
    return 
  end
  local BuildRollData = function(case)
    -- function num : 0_25_0
    return {CanReRoll = case.CanReRoll, ReRollPrice = case.ReRollPrice, ReRollTimes = case.ReRollTimes}
  end

  local BuildShopData = function(case)
    -- function num : 0_25_1 , upvalues : _ENV, self
    local tbShopData = {}
    for index,mapGood in ipairs(case.List) do
      tbShopData[index] = {Idx = mapGood.Idx, bSoldOut = (table.indexof)(case.Purchase, mapGood.Sid) > 0, Price = mapGood.Price, nDiscount = mapGood.Discount, nCharId = mapGood.CharPos > 0 and ((self.parent).tbTeam)[mapGood.CharPos] or 0, nSid = mapGood.Sid, nType = mapGood.Type, nGoodsId = mapGood.GoodsId}
    end
    do return tbShopData end
    -- DECOMPILER ERROR: 4 unprocessed JMP targets
  end

  local BuyCallback = function(nEvtId, nSid, callback, bReRoll)
    -- function num : 0_25_2 , upvalues : _ENV, self, BuildRollData, BuildShopData
    local msg = {}
    msg.Id = nEvtId
    msg.HawkerReq = {}
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R5 in 'UnsetPending'

    if bReRoll then
      (msg.HawkerReq).ReRoll = true
    else
      -- DECOMPILER ERROR at PC10: Confused about usage of register: R5 in 'UnsetPending'

      ;
      (msg.HawkerReq).Sid = nSid
    end
    local InteractiveCallback = function(callbackMsg, tbChangeFateCard, mapChangeNote, mapItemChange, nLevelChange, nExpChange, mapPotentialChange)
      -- function num : 0_25_2_0 , upvalues : callback, _ENV, self, nEvtId, BuildRollData, BuildShopData, nSid
      if not ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] then
        local nBagCount = callback == nil or type(callback) ~= "function" or 0
      end
      local mapInteractiveCase = ((self.mapCases)[(self.EnumCase).Hawker])[nEvtId]
      -- DECOMPILER ERROR at PC32: Confused about usage of register: R9 in 'UnsetPending'

      if mapInteractiveCase.bReRoll then
        (((self.mapCases)[(self.EnumCase).Hawker])[nEvtId]).bReRoll = false
        local mapRoll = BuildRollData(mapInteractiveCase)
        local tbShopData = BuildShopData(mapInteractiveCase)
        callback(nBagCount, tbShopData, mapRoll)
      else
        do
          do
            ;
            (table.insert)(mapInteractiveCase.Purchase, nSid)
            callback(nBagCount)
            ;
            (EventManager.Hit)("StarTowerShopInteract", mapChangeNote)
            self:HandleCases()
          end
        end
      end
    end

    ;
    (self.parent):StarTowerInteract(msg, InteractiveCallback)
  end

  local mapRoll = BuildRollData(mapCase)
  local tbShopData = BuildShopData(mapCase)
  local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerShop, tbShopData, nCoin, BuyCallback, nCaseId, mapRoll, (self.parent).tbDisc, (self.parent)._mapNote, (self.parent).nTowerId, (self.parent).nCurLevel)
  WwiseAudioMgr:SetState("combat", "shopIn")
  WwiseAudioMgr:StopDiscMusic(true, function()
    -- function num : 0_25_3 , upvalues : _ENV
    (NovaAPI.UnLoadBankByEventName)("music_outfit_stop")
  end
)
end

BaseRoom.InteractiveStrengthMachine = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_26 , upvalues : _ENV
  if (self.mapCases)[(self.EnumCase).StrengthenMachine] == nil then
    printError("No StrengthMachine Case!")
    return 
  end
  local mapCase = ((self.mapCases)[(self.EnumCase).StrengthenMachine])[nCaseId]
  if mapCase == nil then
    printError("No StrengthMachine Case! :" .. nCaseId)
    return 
  end
  local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency]
  if nCoin == nil then
    nCoin = 0
  end
  local nDiscount = mapCase.Discount
  local bFirstFree = mapCase.FirstFree
  local nCost = ((self.parent).tbStrengthMachineCost)[mapCase.Times + 1]
  if nCost == nil then
    nCost = ((self.parent).tbStrengthMachineCost)[#(self.parent).tbStrengthMachineCost]
  end
  nCost = nCost - nDiscount
  if bFirstFree then
    nCost = 0
  end
  if nCoin < nCost then
    printError("Not Enough Coin!")
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("StarTower_NotEnoughCoin"))
    return 
  end
  local InteractiveCallback = function(netmsgData)
    -- function num : 0_26_0 , upvalues : _ENV, bFirstFree, mapCase, self, nDiscount, nCost, nNpcConfigId
    if netmsgData.StrengthenMachineResp ~= nil and not (netmsgData.StrengthenMachineResp).BuySucceed then
      (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("StarTower_NoPotential"))
      printError("没有可选的潜能")
      return 
    end
    if bFirstFree then
      mapCase.FirstFree = false
    else
      mapCase.Times = mapCase.Times + 1
    end
    local nCoinAfter = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency]
    if nCoinAfter == nil then
      nCoinAfter = 0
    end
    local nCostAfter = ((self.parent).tbStrengthMachineCost)[mapCase.Times + 1]
    if nCostAfter == nil then
      nCostAfter = ((self.parent).tbStrengthMachineCost)[#(self.parent).tbStrengthMachineCost]
    end
    nCostAfter = nCostAfter - nDiscount
    ;
    (EventManager.Hit)("ShopStrengthFx", {nCost = nCost})
    local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
    WwiseAudioMgr:PostEvent("ui_battle_buff_get")
    self:HandleCases()
    ;
    (EventManager.Hit)("InteractiveNpcFinish", nNpcConfigId, nCostAfter, nCoinAfter)
  end

  local msg = {}
  msg.Id = nCaseId
  ;
  (self.parent):StarTowerInteract(msg, InteractiveCallback)
end

BaseRoom.CheckBattleEnd = function(self)
  -- function num : 0_27
  if (self.mapCases)[(self.EnumCase).Battle] == nil then
    return true
  end
  return ((self.mapCases)[(self.EnumCase).Battle]).bFinish
end

BaseRoom.SyncHp = function(self)
  -- function num : 0_28 , upvalues : _ENV
  local nSyncHpCaseId = (self.mapCases)[(self.EnumCase).SyncHP]
  if nSyncHpCaseId ~= nil and nSyncHpCaseId > 0 then
    local mapCharHpInfo = ((self.parent).GetActorHp)()
    local nMainChar = ((self.parent).tbTeam)[1]
    local nHp = -1
    if mapCharHpInfo[nMainChar] ~= nil then
      nHp = mapCharHpInfo[nMainChar]
    end
    local mapCase = {Id = nSyncHpCaseId, 
RecoveryHPReq = {Hp = nHp}
}
    local callback = function(_, mapNetData)
    -- function num : 0_28_0 , upvalues : self
    -- DECOMPILER ERROR at PC3: Confused about usage of register: R2 in 'UnsetPending'

    (self.mapCases)[(self.EnumCase).SyncHP] = 0
    self:SaveCase(mapNetData.Cases)
  end

    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_interact_req, mapCase, nil, callback)
  end
end

BaseRoom.OnEvent_NpcSpawned = function(self, nEntityId, nNpcId, trNpc)
  -- function num : 0_29 , upvalues : _ENV
  local nCaseId = (self.mapNpc)[nNpcId]
  local mapNpcCfgData = (ConfigTable.GetData)("NPCConfig", nNpcId)
  if nCaseId == nil then
    (EventManager.Hit)("NPCShow", true, nNpcId, nEntityId)
  else
    if mapNpcCfgData ~= nil and mapNpcCfgData.type == (GameEnum.npcNewType).Upgrade then
      if (self.mapCases)[(self.EnumCase).StrengthenMachine] == nil then
        (EventManager.Hit)("NPCShow", true, nNpcId, nEntityId)
        return 
      else
        local mapCase = ((self.mapCases)[(self.EnumCase).StrengthenMachine])[nCaseId]
        if mapCase == nil then
          (EventManager.Hit)("NPCShow", true, nNpcId, nEntityId)
          return 
        end
        local nDiscount = mapCase.Discount or 0
        local bFirstFree = mapCase.FirstFree
        local nTime = mapCase.Times + 1
        local nCost = ((self.parent).tbStrengthMachineCost)[nTime]
        if nCost == nil then
          nCost = ((self.parent).tbStrengthMachineCost)[#(self.parent).tbStrengthMachineCost]
        end
        nCost = nCost - nDiscount
        if bFirstFree then
          nCost = 0
        end
        local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency]
        if nCoin == nil then
          nCoin = 0
        end
        ;
        (EventManager.Hit)("NPCShow", true, nNpcId, nEntityId, nCost, nCoin)
      end
    else
      do
        ;
        (EventManager.Hit)("NPCShow", true, nNpcId, nEntityId)
        ;
        (EventManager.Hit)("SetIndicator", 3, trNpc, Vector3.zero, mapNpcCfgData.HintIcon)
      end
    end
  end
end

BaseRoom.OnEvent_DiscSkillActive = function(self, tbParam)
  -- function num : 0_30 , upvalues : _ENV
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbPopup)[(self.EnumPopup).Disc] == nil then
    (self.tbPopup)[(self.EnumPopup).Disc] = {}
  end
  ;
  (table.insert)((self.tbPopup)[(self.EnumPopup).Disc], {bFinish = false, param = tbParam})
end

BaseRoom.OnEvent_RewardPopup = function(self, tbParam)
  -- function num : 0_31 , upvalues : _ENV
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbPopup)[(self.EnumPopup).Reward] == nil then
    (self.tbPopup)[(self.EnumPopup).Reward] = {}
  end
  ;
  (table.insert)((self.tbPopup)[(self.EnumPopup).Reward], {bFinish = false, param = tbParam})
end

BaseRoom.OnEvent_PotentialPopup = function(self, tbParam)
  -- function num : 0_32 , upvalues : _ENV
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbPopup)[(self.EnumPopup).Potential] == nil then
    (self.tbPopup)[(self.EnumPopup).Potential] = {}
  end
  ;
  (table.insert)((self.tbPopup)[(self.EnumPopup).Potential], {bFinish = false, param = tbParam})
end

BaseRoom.OnEvent_ShopStrengthFx = function(self, tbParam)
  -- function num : 0_33 , upvalues : _ENV
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbPopup)[(self.EnumPopup).StrengthFx] == nil then
    (self.tbPopup)[(self.EnumPopup).StrengthFx] = {}
  end
  ;
  (table.insert)((self.tbPopup)[(self.EnumPopup).StrengthFx], {bFinish = false, param = tbParam})
end

BaseRoom.OnEvent_CloseLoadingView = function(self)
  -- function num : 0_34
  self:HandleCases()
end

BaseRoom.GetShopGoods = function(self)
  -- function num : 0_35 , upvalues : _ENV
  local nType = (self.parent).nRoomType
  local mapStarTower = (ConfigTable.GetData)("StarTower", (self.parent).nTowerId)
  if not mapStarTower then
    return 
  end
  local nNpcId = mapStarTower.ShopNpc
  if nType ~= (GameEnum.starTowerRoomType).ShopRoom then
    nNpcId = mapStarTower.StandShopNpc
  end
  if (self.mapCases)[(self.EnumCase).Hawker] and (self.mapNpc)[nNpcId] then
    return (((self.mapCases)[(self.EnumCase).Hawker])[(self.mapNpc)[nNpcId]]).List
  end
end

BaseRoom.GetCaseById = function(self, nId)
  -- function num : 0_36 , upvalues : _ENV
  for nType,mapCase in pairs(self.mapCases) do
    if type(mapCase) == "table" then
      if mapCase.Id == nil then
        for nCaseId,mapCaseData in pairs(mapCase) do
          if nCaseId == nId then
            return nType, mapCaseData
          end
        end
      else
        do
          do
            if mapCase.Id == nId then
              return nType, mapCase
            end
            -- DECOMPILER ERROR at PC30: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC30: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC30: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC30: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC30: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
  return nil
end

return BaseRoom

