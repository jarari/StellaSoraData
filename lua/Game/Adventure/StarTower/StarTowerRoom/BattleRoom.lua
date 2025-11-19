local BaseRoom = require("Game.Adventure.StarTower.StarTowerRoom.BaseRoom")
local BattleRoom = class("BattleRoom", BaseRoom)
BattleRoom._mapEventConfig = {CSHARP2LUA_BATTLE_DROP_COIN = "OnEvent_GetCoin", ADVENTURE_BATTLE_MONSTER_DIED = "OnEvent_MonsterDied", LevelStateChanged = "OnEvent_LevelStateChanged", LevelUseTotalTime = "OnEvent_TimeEnd", LevelPauseUseTotalTime = "OnEvent_TimeEnd", InteractiveNpc = "OnEvent_InteractiveNpc", Level_Settlement = "OnEvent_ActorFinishDie"}
BattleRoom.LevelStart = function(self)
  -- function num : 0_0 , upvalues : _ENV
  local mapBattleCase = (self.mapCases)[(self.EnumCase).Battle]
  self.nCoinTemp = 0
  self.bBattleEnd = false
  if mapBattleCase == nil then
    self.bBattleEnd = true
    ;
    (EventManager.Hit)("ShowStarTowerRoomInfo", true, (self.parent).nTeamLevel, (self.parent).nTeamExp, clone((self.parent)._mapNote), clone((self.parent)._mapFateCard))
    local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency]
    if nCoin == nil then
      nCoin = 0
    end
    local nBuildScore = (self.parent):CalBuildScore()
    ;
    (EventManager.Hit)("ShowStarTowerCoin", true, nCoin, nBuildScore)
    self:AddTimer(1, 0.1, function()
    -- function num : 0_0_0 , upvalues : _ENV
    ((CS.WwiseAudioManager).Instance):SetState("combat", "explore")
  end
, true, true, true)
    return 
  end
  do
    ;
    (PlayerData.Achievement):SetSpecialBattleAchievement((GameEnum.levelType).StarTower)
    if (mapBattleCase.Data).TimeLimit then
      local nLevel = (self.parent).nCurLevel
      local nType = (self.parent).nRoomType
      local nStage = (self.parent):GetStage(nLevel)
      ;
      (EventManager.Hit)("OpenBossTime", nStage, nType)
    end
    do
      ;
      (EventManager.Hit)("ShowStarTowerCoin", false)
      self.bFailed = false
      local nType = (self.parent).nRoomType
      if nType == (GameEnum.starTowerRoomType).BossRoom or nType == (GameEnum.starTowerRoomType).FinalBossRoom then
        (EventManager.Hit)("StartClientRankTimer")
      end
    end
  end
end

BattleRoom.OnLoadLevelRefresh = function(self)
  -- function num : 0_1
end

BattleRoom.OnEvent_LevelStateChanged = function(self, nState)
  -- function num : 0_2 , upvalues : _ENV
  if self.bFailed then
    printError("角色已死亡")
    return 
  end
  if nState == (GameEnum.levelState).Teleporter then
    if (self.mapCases)[(self.EnumCase).OpenDoor] == nil then
      printError("无传送门case 无法进入下一层")
      return 
    end
    local tbDoorCase = (self.mapCases)[(self.EnumCase).OpenDoor]
    ;
    (self.parent):EnterRoom(tbDoorCase[1], tbDoorCase[2])
    return 
  end
  do
    if (self.mapCases)[(self.EnumCase).Battle] == nil then
      printError("无战斗事件需要处理")
      return 
    end
    ;
    (EventManager.Hit)("CloseBossTime", nState == (GameEnum.levelState).Success)
    local msg = {}
    local nEventId = ((self.mapCases)[(self.EnumCase).Battle]).Id
    msg.Id = nEventId
    msg.BattleEndReq = {}
    local nType = (self.parent).nRoomType
    if nType == (GameEnum.starTowerRoomType).BossRoom or nType == (GameEnum.starTowerRoomType).FinalBossRoom then
      (EventManager.Hit)("ResetClientRankTimer")
    end
    if nState == (GameEnum.levelState).Success then
      self.bBattleEnd = true
      ;
      (EventManager.Hit)("ShowStarTowerRoomInfo", true, (self.parent).nTeamLevel, (self.parent).nTeamExp, clone((self.parent)._mapNote), clone((self.parent)._mapFateCard))
      local nCoin = ((self.parent)._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency]
      if nCoin == nil then
        nCoin = 0
      end
      local nBuildScore = (self.parent):CalBuildScore()
      ;
      (EventManager.Hit)("ShowStarTowerCoin", true, nCoin, nBuildScore)
      local mapCharHpInfo = ((self.parent).GetActorHp)()
      local nMainChar = ((self.parent).tbTeam)[1]
      local nHp = -1
      if mapCharHpInfo[nMainChar] ~= nil then
        nHp = mapCharHpInfo[nMainChar]
      end
      local tbUsage = (self.parent):GetFateCardUsage()
      local clientData, nDataLength = (self.parent):CacheTempData()
      local tbDamage = (self.parent):GetDamageRecord()
      local tbSamples = (UTILS.GetBattleSamples)()
      -- DECOMPILER ERROR at PC152: Confused about usage of register: R15 in 'UnsetPending'

      if (self.parent).nTotalTime ~= nil then
        (self.parent).nTotalTime = (self.parent).nTotalTime + self.nTime
      end
      local tbEvent = {}
      tbEvent = (PlayerData.Achievement):GetBattleAchievement((GameEnum.levelType).StarTower, true)
      -- DECOMPILER ERROR at PC176: Confused about usage of register: R16 in 'UnsetPending'

      ;
      (msg.BattleEndReq).Victory = {HP = nHp, Time = self.nTime, ClientData = clientData, fateCardUsage = tbUsage, DateLen = nDataLength, Damages = tbDamage, Sample = tbSamples, 
Events = {List = tbEvent}
}
      local tabUpLevel = {}
      ;
      (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
      ;
      (table.insert)(tabUpLevel, {"game_cost_time", tostring(self.nTime)})
      ;
      (table.insert)(tabUpLevel, {"real_cost_time", tostring(((CS.ClientManager).Instance).serverTimeStampWithTimeZone - self._EntryTime)})
      ;
      (table.insert)(tabUpLevel, {"tower_id", tostring((self.parent).nTowerId)})
      ;
      (table.insert)(tabUpLevel, {"room_floor", tostring((self.parent).nCurLevel)})
      ;
      (table.insert)(tabUpLevel, {"room_type", tostring((self.parent).nRoomType)})
      ;
      (table.insert)(tabUpLevel, {"action", tostring(2)})
      ;
      (NovaAPI.UserEventUpload)("star_tower", tabUpLevel)
    elseif nState == (GameEnum.levelState).Failed then
      self.bFailed = true
      return 
    end
    local callback = function(msgData, tbChangeFateCard, mapChangeNote, mapItemChange, nLevelChange, nExpChange)
    -- function num : 0_2_0 , upvalues : self, _ENV
    self.nCoinTemp = 0
    -- DECOMPILER ERROR at PC5: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self.mapCases)[(self.EnumCase).Battle]).bFinish = true
    self.nWaitShowTime = 0
    self.showFinishCall = nil
    local setTime = function(nTime, callback)
      -- function num : 0_2_0_0 , upvalues : self
      self.nWaitShowTime = nTime
      self.showFinishCall = callback
    end

    ;
    (EventManager.Hit)("ShowBattleReward", nLevelChange, nExpChange, tbChangeFateCard, mapChangeNote, mapItemChange, setTime)
    self.blockNpcBtn = true
    local waitCallback = function()
      -- function num : 0_2_0_1 , upvalues : self
      if self.showFinishCall ~= nil then
        (self.showFinishCall)()
        self.showFinishCall = nil
      end
      self:HandleCases()
    end

    if self.nWaitShowTime > 0 then
      self:AddTimer(1, self.nWaitShowTime, waitCallback, true, true, true, nil)
    else
      waitCallback()
    end
  end

    ;
    (self.parent):StarTowerInteract(msg, callback)
    -- DECOMPILER ERROR: 8 unprocessed JMP targets
  end
end

BattleRoom.OnEvent_MonsterDied = function(self)
  -- function num : 0_3
end

BattleRoom.OnEvent_InteractiveNpc = function(self, nNpcId, nNpcUid)
  -- function num : 0_4
  self:HandleNpc(nNpcId, nNpcUid)
end

BattleRoom.OnEvent_GetCoin = function(self, num)
  -- function num : 0_5
end

BattleRoom.OnEvent_TimeEnd = function(self, nTime)
  -- function num : 0_6
  self.nTime = nTime
end

BattleRoom.OnEvent_ActorFinishDie = function(self)
  -- function num : 0_7 , upvalues : _ENV
  if self.bBattleEnd then
    (EventManager.Hit)("AbandonStarTower")
  else
    local msg = {}
    do
      local nEventId = ((self.mapCases)[(self.EnumCase).Battle]).Id
      msg.Id = nEventId
      msg.BattleEndReq = {}
      -- DECOMPILER ERROR at PC18: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (msg.BattleEndReq).Defeat = true
      local callback = function(msgData)
    -- function num : 0_7_0 , upvalues : self, _ENV
    self.nCoinTemp = 0
    -- DECOMPILER ERROR at PC5: Confused about usage of register: R1 in 'UnsetPending'

    ;
    ((self.mapCases)[(self.EnumCase).Battle]).bFinish = true
    print("遗迹失败")
    ;
    (self.parent):StarTowerFailed((msgData.Settle).Change, (msgData.Settle).Build, (msgData.Settle).TotalTime, (msgData.Settle).Reward, (msgData.Settle).TowerRewards, (msgData.Settle).NpcInteraction)
  end

      local ConfirmCallback = function()
    -- function num : 0_7_1 , upvalues : self, _ENV
    (self.parent):ReBattle()
    ;
    (PanelManager.InputEnable)()
  end

      local CancelCallback = function()
    -- function num : 0_7_2 , upvalues : self, msg, callback, _ENV
    (self.parent):StarTowerInteract(msg, callback)
    ;
    (PanelManager.InputEnable)()
  end

      if (self.parent).bPrologue == true then
        (self.parent):StarTowerInteract(msg, callback)
      else
        local data = {nType = (AllEnum.MessageBox).Confirm, sContent = (ConfigTable.GetUIText)("Startower_ReBattleHint"), sContentSub = "", callbackConfirm = ConfirmCallback, callbackCancel = CancelCallback}
        ;
        (EventManager.Hit)(EventId.OpenMessageBox, data)
        ;
        (PanelManager.InputDisable)()
      end
    end
  end
end

return BattleRoom

