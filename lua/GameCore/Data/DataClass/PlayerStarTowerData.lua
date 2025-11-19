local LocalData = require("GameCore.Data.LocalData")
local PlayerStarTowerData = class("PlayerStarTowerData")
local ClientManager = (CS.ClientManager).Instance
local PB = require("pb")
local localData = require("GameCore.Data.LocalData")
PlayerStarTowerData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV, PB
  local pbSchema = (NovaAPI.LoadLuaBytes)("Game/Adventure/StarTower/roguelike_tempData.pb")
  assert((PB.load)(pbSchema))
  self.LevelData = nil
  self:CacheClientEffectNodeConfigData()
  self.nRankingRewardLower = 0
  self.nMaxRankingIndex = 0
  self.nLastRankingRefreshTime = 0
  self.nRankingRefreshTime = 600
  self.mapSelfRankingData = nil
  self.mapRankingData = nil
  self.nWeekRewardCount = 0
  self.nStarTowerTicket = 0
  self:InitConfig()
  self.tbPassedId = {}
  self.bPotentialDescSimple = nil
  self.mapNpcAffinityGroupMaxLevel = {}
  local forEachAffinityLevel = function(mapData)
    -- function num : 0_0_0 , upvalues : self
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R1 in 'UnsetPending'

    if (self.mapNpcAffinityGroupMaxLevel)[mapData.AffinityGroupId] == nil then
      (self.mapNpcAffinityGroupMaxLevel)[mapData.AffinityGroupId] = 0
    end
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R1 in 'UnsetPending'

    if (self.mapNpcAffinityGroupMaxLevel)[mapData.AffinityGroupId] < mapData.Level then
      (self.mapNpcAffinityGroupMaxLevel)[mapData.AffinityGroupId] = mapData.Level
    end
  end

  ForEachTableLine(DataTable.NPCAffinityGroup, forEachAffinityLevel)
  self:InitNpcAffinity()
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  ;
  (EventManager.Add)(EventId.UpdateWorldClass, self, self.OnEvent_WorldClass)
end

PlayerStarTowerData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  ;
  (EventManager.Remove)(EventId.UpdateWorldClass, self, self.OnEvent_WorldClass)
end

PlayerStarTowerData.EnterTower = function(self, nTowerId, nTeamIdx, tbDisc)
  -- function num : 0_2 , upvalues : _ENV
  if self.LevelData ~= nil then
    self:StarTowerEnd()
  end
  local luaClass = require("Game.Adventure.StarTower.StarTowerLevelData")
  self.LevelData = (luaClass.new)(self, nTowerId)
  local nStageId = (self.LevelData):GetStageId(1)
  local tbTeam = (PlayerData.Team):GetTeamCharId(nTeamIdx)
  local tbCharSkinId = {}
  for _,nCharId in ipairs(tbTeam) do
    (table.insert)(tbCharSkinId, (PlayerData.Char):GetCharSkinId(nCharId))
  end
  local stRoomMeta = (CS.Lua2CSharpInfo_FixedRoguelike)(nTowerId, nStageId, {}, tbTeam, tbCharSkinId, 0, "", 0, -1, false, 0)
  local curMapId, nFloorId, sExdata, scenePrefabId = safe_call_cs_func2((CS.AdventureModuleHelper).RandomStarTowerMap, stRoomMeta)
  local applyCallback = function(_, mapMsgData)
    -- function num : 0_2_0 , upvalues : nTowerId, tbTeam, self, _ENV
    local mapStateInfo = {Id = nTowerId, ReConnection = 0, BuildId = 0, CharIds = tbTeam, Floor = 0}
    -- DECOMPILER ERROR at PC9: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self.LevelData).nReportId = ""
    safe_call_cs_func((CS.AdventureModuleHelper).SetDamageRecordId, "")
    ;
    (PlayerData.State):CacheStarTowerStateData(mapStateInfo)
    local starTowerInfo = mapMsgData.Info
    ;
    (self.LevelData):Init(starTowerInfo.Meta, starTowerInfo.Room, starTowerInfo.Bag, mapMsgData.LastId)
  end

  local mapMsg = {Id = nTowerId, FormationId = nTeamIdx, CharHp = -1, MapId = curMapId, ParamId = nFloorId, MapParam = sExdata, MapTableId = scenePrefabId}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_apply_req, mapMsg, nil, applyCallback)
end

PlayerStarTowerData.EnterTowerEditor = function(self, nTowerId, nMapId, nFloorId, nStage, tbTeam, tbDisc, tbNote)
  -- function num : 0_3 , upvalues : _ENV
  local luaClass = require("Game.Editor.StarTower.StarTowerLevelDataEditor")
  self.LevelData = (luaClass.new)(self, nTowerId)
  local nLevel = (self.LevelData):GetStageLevel(nStage)
  local nStageId = nStage
  local tbCharSkinId = {}
  for _,nCharId in ipairs(tbTeam) do
    (table.insert)(tbCharSkinId, (PlayerData.Char):GetCharSkinId(nCharId))
  end
  local stRoomMeta = (CS.Lua2CSharpInfo_FixedRoguelike)(nTowerId, nStageId, {}, tbTeam, tbCharSkinId, nMapId, "", nFloorId, -1, false, 0)
  local curMapId, _, _ = safe_call_cs_func2((CS.AdventureModuleHelper).RandomStarTowerMap, stRoomMeta)
  local applyCallback = function(_, mapMsgData)
    -- function num : 0_3_0 , upvalues : self
    (self.LevelData):Init(mapMsgData.Meta, mapMsgData.Room, mapMsgData.Bag)
  end

  local mapMsgData = {
Meta = {Id = nTowerId, CharHp = -1, TeamLevel = 0, TeamExp = 0, 
Chars = {
{Id = tbTeam[1]}
, 
{Id = tbTeam[2]}
, 
{Id = tbTeam[3]}
}
, Discs = tbDisc, Compress = false, ClientData = ""}
, 
Room = {
Data = {Floor = nLevel, MapId = curMapId, ParamId = nFloorId}
, 
Cases = {
{Id = 1, 
DoorCase = {Floor = 1, Type = 1}
}
, 
{Id = 2, 
BattleCase = {TimeLimit = false, FateCard = false}
}
}
}
, 
Bag = {
Notes = {[1] = tbNote[90011] or 0, [2] = tbNote[90012] or 0, [3] = tbNote[90013] or 0, [4] = tbNote[90014] or 0, [5] = tbNote[90015] or 0}
}
}
  applyCallback(nil, mapMsgData)
end

PlayerStarTowerData.EnterTowerPrologue = function(self)
  -- function num : 0_4 , upvalues : LocalData, _ENV
  local lastAccount = (LocalData.GetLocalData)("LoginUIData", "LastUserName_All")
  local sJson = (LocalData.GetLocalData)(lastAccount, "StarTowerPrologueLevel")
  local sJsonChar = ((LocalData.GetLocalData)(lastAccount, "StarTowerPrologueLevelChar"))
  local mapLocalData = nil
  if sJson ~= nil then
    mapLocalData = decodeJson(sJson)
  else
    mapLocalData = {}
    mapLocalData.mapFateCard = {}
    mapLocalData.mapPotential = {}
    mapLocalData.nLevel = 1
    mapLocalData.nExp = 0
    mapLocalData.bBattleEnd = false
    mapLocalData.tbEndCaseId = {}
    mapLocalData.nCurFloor = 1
    mapLocalData.ActorHp = -1
  end
  local luaClass = require("Game.Adventure.StarTower.StarTowerPrologueLevel")
  self.LevelData = (luaClass.new)(self)
  local tbTeam = (self.LevelData):GetTeam()
  local Discs = (self.LevelData):GetDiscs()
  local nStageId = (self.LevelData):GetStageId(mapLocalData.nCurFloor)
  local nLevel = mapLocalData.nCurFloor
  local tbCharSkinId = {}
  for _,nCharId in ipairs(tbTeam) do
    (table.insert)(tbCharSkinId, (PlayerData.Char):GetCharSkinId(nCharId))
  end
  local stRoomMeta = (CS.Lua2CSharpInfo_FixedRoguelike)(999, nStageId, {}, tbTeam, tbCharSkinId, 0, "", 0, -1, false, 0)
  local curMapId, nFloorId, scenePrefabId = safe_call_cs_func2((CS.AdventureModuleHelper).RandomStarTowerMap, stRoomMeta)
  local applyCallback = function(_, mapMsgData, mapSaveData)
    -- function num : 0_4_0 , upvalues : self, sJsonChar
    (self.LevelData):Init(mapMsgData.Meta, mapMsgData.Room, mapSaveData, sJsonChar)
  end

  local mapMsgData = {
Meta = {Id = 999, CharHp = -1, TeamLevel = 0, TeamExp = 0, 
Chars = {
{Id = tbTeam[1]}
, 
{Id = tbTeam[2]}
, 
{Id = tbTeam[3]}
}
, Discs = Discs, Compress = false, ClientData = ""}
, 
Room = {
Data = {Floor = nLevel, MapId = curMapId, ParamId = nFloorId, MapTableId = scenePrefabId}
, 
Cases = {}
}
}
  applyCallback(nil, mapMsgData, mapLocalData)
end

PlayerStarTowerData.EnterTowerFastBattle = function(self, nTowerId, nTeamIdx)
  -- function num : 0_5 , upvalues : _ENV
  local tbTeam = (PlayerData.Team):GetTeamCharId(nTeamIdx)
  local tbCharSkinId = {}
  for _,nCharId in ipairs(tbTeam) do
    (table.insert)(tbCharSkinId, (PlayerData.Char):GetCharSkinId(nCharId))
  end
  local applyCallback = function(_, mapMsgData)
    -- function num : 0_5_0 , upvalues : nTowerId, tbTeam, _ENV
    local mapStateInfo = {Id = nTowerId, ReConnection = 0, BuildId = 0, CharIds = tbTeam, Floor = 0, Sweep = true}
    ;
    (PlayerData.State):CacheStarTowerStateData(mapStateInfo)
    local starTowerInfo = mapMsgData.Info
    local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData.Change)
    ;
    (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerFastBattle, starTowerInfo)
  end

  local mapMsg = {Id = nTowerId, FormationId = nTeamIdx, CharHp = -1, MapId = -1, ParamId = -1, MapParam = "", MapTableId = -1, Sweep = true}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_apply_req, mapMsg, nil, applyCallback)
end

PlayerStarTowerData.ReenterTower = function(self, nTowerId)
  -- function num : 0_6 , upvalues : _ENV
  local callback = function(_, msgData)
    -- function num : 0_6_0 , upvalues : _ENV, self, nTowerId
    local luaClass = require("Game.Adventure.StarTower.StarTowerLevelData")
    self.LevelData = (luaClass.new)(self, nTowerId)
    local tbTeam = {}
    for _,mapChar in ipairs((msgData.Meta).Chars) do
      (table.insert)(tbTeam, mapChar.Id)
    end
    local tbCharSkinId = {}
    for _,nCharId in ipairs(tbTeam) do
      (table.insert)(tbCharSkinId, (PlayerData.Char):GetCharSkinId(nCharId))
    end
    local nFloor = ((msgData.Room).Data).Floor
    local nStageId = (self.LevelData):GetStageId(nFloor)
    local nDangerRoom = ((msgData.Room).Data).RoomType
    local stRoomMeta = (CS.Lua2CSharpInfo_FixedRoguelike)(nTowerId, nStageId, {}, tbTeam, tbCharSkinId, ((msgData.Room).Data).MapId, ((msgData.Room).Data).MapParam, ((msgData.Room).Data).ParamId, nDangerRoom, false, ((msgData.Room).Data).MapTableId)
    -- DECOMPILER ERROR at PC71: Confused about usage of register: R9 in 'UnsetPending'

    ;
    (self.LevelData).nReportId = nReportId
    safe_call_cs_func((CS.AdventureModuleHelper).SetDamageRecordId, "")
    local curMapId, nFloorId, sExdata, _ = safe_call_cs_func2((CS.AdventureModuleHelper).RandomStarTowerMap, stRoomMeta)
    ;
    (self.LevelData):Init(msgData.Meta, msgData.Room, msgData.Bag)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_info_req, {}, nil, callback)
end

PlayerStarTowerData.ReenterTowerFastBattle = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local callback = function(_, msgData)
    -- function num : 0_7_0 , upvalues : _ENV
    local starTowerInfo = {Meta = msgData.Meta, Room = msgData.Room, Bag = msgData.Bag}
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerFastBattle, starTowerInfo)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_info_req, {}, nil, callback)
end

PlayerStarTowerData.StarTowerEnd = function(self)
  -- function num : 0_8
  if self.LevelData ~= nil then
    (self.LevelData):Exit()
    self.LevelData = nil
  end
end

PlayerStarTowerData.GiveUpReconnect = function(self, nTowerId, tbMember, bShowConfirm, giveUpCallback)
  -- function num : 0_9 , upvalues : _ENV
  local callback = function(_, msgData)
    -- function num : 0_9_0 , upvalues : _ENV, self, nTowerId, tbMember, giveUpCallback
    local tbRes = {}
    local tbPresents = {}
    local tbOutfit = {}
    local tbItem = {}
    local encodeInfo = (UTILS.DecodeChangeInfo)(msgData.Change)
    if encodeInfo["proto.Res"] ~= nil then
      for _,mapCoin in ipairs(encodeInfo["proto.Res"]) do
        (table.insert)(tbRes, {nTid = mapCoin.Tid, nCount = mapCoin.Qty})
        if mapCoin.Tid == (AllEnum.CoinItemId).FRRewardCurrency then
          (PlayerData.StarTower):AddStarTowerTicket(mapCoin.Qty)
        end
      end
    end
    do
      if encodeInfo["proto.Item"] ~= nil then
        for _,mapItem in ipairs(encodeInfo["proto.Item"]) do
          local mapItemConfigData = (ConfigTable.GetData_Item)(mapItem.Tid)
          if mapItemConfigData ~= nil and mapItemConfigData.Stype ~= (GameEnum.itemStype).Res then
            (table.insert)(tbItem, {nTid = mapItem.Tid, nCount = mapItem.Qty})
          end
        end
      end
      do
        self:CacheNpcAffinityChange(msgData.Reward, msgData.NpcInteraction)
        local mapResult = {nRoguelikeId = nTowerId, tbRes = tbRes, tbPresents = tbPresents, tbOutfit = tbOutfit, tbItem = tbItem, 
tbRarityCount = {}
, bSuccess = false, nFloor = msgData.Floor, nStage = 0, mapBuild = msgData.Build, nExp = msgData.Exp, nPerkCount = msgData.PotentialCnt, 
tbBonus = {}
, nTime = msgData.TotalTime, tbAffinities = msgData.Affinities, mapChangeInfo = msgData.Change, mapNPCAffinity = msgData.Reward, tbRewards = msgData.TowerRewards, bSweep = ((PlayerData.State):GetStarTowerState()).Sweep}
        ;
        (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerResult, mapResult, tbMember)
        print("放弃重连")
        if giveUpCallback ~= nil then
          giveUpCallback()
        end
      end
    end
  end

  local callfirmCallback = function()
    -- function num : 0_9_1 , upvalues : _ENV, callback
    local mapStateInfo = {Id = 0, ReConnection = 0, BuildId = 0, 
CharIds = {}
, Floor = 0, Sweep = ((PlayerData.State):GetStarTowerState()).Sweep}
    ;
    (PlayerData.State):CacheStarTowerStateData(mapStateInfo)
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_give_up_req, {}, nil, callback)
  end

  local sContent = (ConfigTable.GetUIText)("StarTower_Pause_Tips")
  local msg = {nType = (AllEnum.MessageBox).Confirm, sContent = sContent or "", callbackConfirm = callfirmCallback}
  if bShowConfirm then
    (EventManager.Hit)(EventId.OpenMessageBox, msg)
  else
    callfirmCallback()
  end
end

PlayerStarTowerData.InitConfig = function(self)
  -- function num : 0_10 , upvalues : _ENV
  local foreachStarTower = function(mapData)
    -- function num : 0_10_0 , upvalues : _ENV
    (CacheTable.InsertData)("_StarTower", mapData.GroupId, mapData)
    ;
    (CacheTable.InsertData)("_StarTowerDifficulty", mapData.ValueDifficulty, mapData)
    ;
    (CacheTable.SetField)("_StarTowerGroupDifficulty", mapData.GroupId, mapData.Difficulty, mapData)
  end

  ForEachTableLine((ConfigTable.Get)("StarTower"), foreachStarTower)
  local foreachNoteDrop = function(mapData)
    -- function num : 0_10_1 , upvalues : _ENV
    (CacheTable.InsertData)("_SubNoteSkillDropGroup", mapData.GroupId, mapData)
  end

  ForEachTableLine((ConfigTable.Get)("SubNoteSkillDropGroup"), foreachNoteDrop)
  local foreachLimitReward = function(mapData)
    -- function num : 0_10_2 , upvalues : _ENV
    if (CacheTable.GetData)("_StarTowerLimitReward", mapData.StarTowerId) == nil then
      (CacheTable.SetData)("_StarTowerLimitReward", mapData.StarTowerId, {})
    end
    if ((CacheTable.GetData)("_StarTowerLimitReward", mapData.StarTowerId))[mapData.Stage] == nil then
      ((CacheTable.GetData)("_StarTowerLimitReward", mapData.StarTowerId))[mapData.Stage] = {}
    end
    -- DECOMPILER ERROR at PC38: Confused about usage of register: R1 in 'UnsetPending'

    ;
    (((CacheTable.GetData)("_StarTowerLimitReward", mapData.StarTowerId))[mapData.Stage])[mapData.RoomType] = mapData
  end

  ForEachTableLine(DataTable.StarTowerLimitReward, foreachLimitReward)
  local foreachTeamExp = function(mapData)
    -- function num : 0_10_3 , upvalues : _ENV
    (CacheTable.SetField)("_StarTowerTeamExpGroup", mapData.GroupId, mapData.Level, mapData)
  end

  ForEachTableLine(DataTable.StarTowerTeamExp, foreachTeamExp)
end

PlayerStarTowerData.CachePassedId = function(self, tbIds)
  -- function num : 0_11 , upvalues : _ENV
  if tbIds ~= nil then
    self.tbPassedId = tbIds
    ;
    (EventManager.Hit)(EventId.StarTowerPass)
  end
end

PlayerStarTowerData.CacheOnePassedId = function(self, passedId)
  -- function num : 0_12 , upvalues : _ENV
  if (table.indexof)(self.tbPassedId, passedId) < 1 then
    (table.insert)(self.tbPassedId, passedId)
  end
end

PlayerStarTowerData.GetFirstPassReward = function(self, nLevelId)
  -- function num : 0_13 , upvalues : _ENV
  local mapLevelCfgData = (ConfigTable.GetData)("StarTower", nLevelId)
  if mapLevelCfgData == nil then
    return false
  end
  for _,nPassedId in ipairs(self.tbPassedId) do
    local mapPassCfgData = (ConfigTable.GetData)("StarTower", nPassedId)
    if mapPassCfgData ~= nil and mapLevelCfgData.Difficulty <= mapPassCfgData.Difficulty and mapLevelCfgData.GroupId == mapPassCfgData.GroupId then
      return true
    end
  end
end

PlayerStarTowerData.GetShowHintRewardReward = function(self, nLevelId)
  -- function num : 0_14 , upvalues : _ENV
  local mapLevelCfgData = (ConfigTable.GetData)("StarTower", nLevelId)
  if mapLevelCfgData == nil then
    return false
  end
  if mapLevelCfgData.Difficulty == 1 then
    return false
  end
  if not self:IsStarTowerUnlock(nLevelId) then
    return false
  end
  for _,nPassedId in ipairs(self.tbPassedId) do
    local mapPassCfgData = (ConfigTable.GetData)("StarTower", nPassedId)
    if mapPassCfgData ~= nil and mapLevelCfgData.Difficulty - 1 <= mapPassCfgData.Difficulty and mapLevelCfgData.GroupId == mapPassCfgData.GroupId then
      return false
    end
  end
  return true
end

PlayerStarTowerData.ClearData = function(self)
  -- function num : 0_15
  if self.LevelData ~= nil then
    (self.LevelData):Exit()
    self.LevelData = nil
  end
end

PlayerStarTowerData.QueryLevelInfo = function(self, nId, nType, nParam1, nParam2)
  -- function num : 0_16 , upvalues : _ENV
  if self.LevelData ~= nil and type((self.LevelData).QueryLevelInfo) == "function" then
    return (self.LevelData):QueryLevelInfo(nId, nType, nParam1, nParam2)
  end
  return nil
end

PlayerStarTowerData.CheckPassedId = function(self, nStarTowerId)
  -- function num : 0_17 , upvalues : _ENV
  if (table.indexof)(self.tbPassedId, nStarTowerId) < 1 then
    return false
  end
  return true
end

PlayerStarTowerData.IsStarTowerUnlock = function(self, nStarTowerId)
  -- function num : 0_18 , upvalues : _ENV
  local mapStarTowerCfgData = (ConfigTable.GetData)("StarTower", nStarTowerId)
  if mapStarTowerCfgData == nil then
    printError("StarTower Cfg Missing:" .. nStarTowerId)
    return false
  end
  local tbCond = decodeJson(mapStarTowerCfgData.PreConditions)
  if tbCond == nil then
    return true
  else
    local sTip = nil
    for _,tbCondInfo in ipairs(tbCond) do
      if tbCondInfo[1] == 1 then
        local nCondLevelId = tbCondInfo[2]
        if (table.indexof)(self.tbPassedId, nCondLevelId) < 1 then
          local mapStarTower = (ConfigTable.GetData)("StarTower", nCondLevelId)
          if mapStarTower ~= nil then
            sTip = orderedFormat((ConfigTable.GetUIText)("Rogue_UnlockStarTower"), mapStarTower.Name)
          end
          return false, sTip, tbCondInfo[1], nCondLevelId
        end
      else
        do
          if tbCondInfo[1] == 2 then
            local nWorldCalss = (PlayerData.Base):GetWorldClass()
            local nCondClass = tbCondInfo[2]
            if nWorldCalss < nCondClass then
              sTip = orderedFormat((ConfigTable.GetUIText)("Rogue_UnlockWorldLv"), nCondClass)
              return false, sTip, tbCondInfo[1], nCondClass
            end
          else
            do
              if tbCondInfo[1] == 3 then
                local nMainlineId = tbCondInfo[2]
                local nStar = (PlayerData.Mainline):GetMianlineLevelStar(nMainlineId)
                if nStar <= 0 then
                  local storyConfig = (ConfigTable.GetData)("Story", nMainlineId, "not have this story ID")
                  if storyConfig ~= nil then
                    sTip = orderedFormat((ConfigTable.GetUIText)("Rogue_UnlockMainLine"), storyConfig.Title)
                  end
                  return false, sTip, tbCondInfo[1], nMainlineId
                end
              else
                do
                  if tbCondInfo[1] == 4 then
                    local nDifficulty = tbCondInfo[2]
                    local tbStarTower = (CacheTable.GetData)("_StarTowerDifficulty", nDifficulty)
                    local bUnlock = false
                    for _,v in ipairs(tbStarTower) do
                      local nId = v.Id
                      if (table.indexof)(self.tbPassedId, nId) >= 1 then
                        bUnlock = true
                        break
                      end
                    end
                    do
                      do
                        if not bUnlock then
                          sTip = orderedFormat((ConfigTable.GetUIText)("Rogue_UnlockDifficulty"), nDifficulty - 1)
                          return false, sTip, tbCondInfo[1], nDifficulty
                        end
                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out DO_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out IF_THEN_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out IF_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out DO_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out IF_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out DO_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out IF_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out DO_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                        -- DECOMPILER ERROR at PC157: LeaveBlock: unexpected jumping out IF_STMT

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
  do
    return true
  end
end

PlayerStarTowerData.IsStarTowerGroupUnlock = function(self, nStarTowerGroupId)
  -- function num : 0_19 , upvalues : _ENV
  local bUnlock = false
  local mapStarTowerGroup = (CacheTable.GetData)("_StarTower", nStarTowerGroupId)
  if mapStarTowerGroup ~= nil then
    for _,v in ipairs(mapStarTowerGroup) do
      if not bUnlock then
        bUnlock = self:IsStarTowerUnlock(v.Id)
      end
    end
  end
  do
    return bUnlock
  end
end

PlayerStarTowerData.GetMaxDifficult = function(self, nGroupId)
  -- function num : 0_20 , upvalues : _ENV
  local ret = 1
  local mapGroup = (CacheTable.GetData)("_StarTower", nGroupId)
  if mapGroup == nil then
    return false
  end
  for _,mapStarTower in pairs(mapGroup) do
    if self:IsStarTowerUnlock(mapStarTower.Id) and ret < mapStarTower.Difficulty then
      ret = mapStarTower.Difficulty
    end
  end
  return ret
end

PlayerStarTowerData.GetMaxPassedDifficult = function(self, nGroupId)
  -- function num : 0_21 , upvalues : _ENV
  local ret = 0
  local mapGroup = (CacheTable.GetData)("_StarTower", nGroupId)
  if mapGroup == nil then
    return ret
  end
  for _,mapStarTower in pairs(mapGroup) do
    if self:IsStarTowerUnlock(mapStarTower.Id) and self:CheckPassedId(mapStarTower.Id) and ret < mapStarTower.Difficulty then
      ret = mapStarTower.Difficulty
    end
  end
  return ret
end

PlayerStarTowerData.CheckUnlockTowerSweep = function(self)
  -- function num : 0_22 , upvalues : _ENV
  if (self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).UnlockTowerSweep] then
    for nNodeId,v in pairs((self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).UnlockTowerSweep]) do
      if not self.nFirstGrowthGroup then
        return false
      else
        local bActive = (((self.tbGrowthNodes)[v.Group])[nNodeId]).bActive
        if not bActive then
          return false
        else
          return true
        end
      end
    end
  end
end

PlayerStarTowerData.CheckCanSweep = function(self, nGroupId, nStarTowerId)
  -- function num : 0_23 , upvalues : _ENV
  local sTips, sLock = "", ""
  if (self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).UnlockTowerSweep] then
    for nNodeId,v in pairs((self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).UnlockTowerSweep]) do
      if not self.nFirstGrowthGroup then
        printError("点击星塔扫荡前未请求星塔养成数据")
        break
      else
        local bActive = (((self.tbGrowthNodes)[v.Group])[nNodeId]).bActive
        if not bActive then
          sTips = orderedFormat((ConfigTable.GetUIText)("StarTower_Sweep_NodeAlert"), v.Name)
          sLock = (ConfigTable.GetUIText)("StarTower_Sweep_Btn_Lock_Growth")
          return false, sTips, sLock
        else
          break
        end
      end
    end
  end
  do
    sLock = (ConfigTable.GetUIText)("StarTower_Sweep_Btn_Lock_Clear")
    sTips = (ConfigTable.GetUIText)("StarTower_Sweep_ClearAlert")
    local nMaxDifficulty = self:GetMaxPassedDifficult(nGroupId)
    if nMaxDifficulty <= 0 then
      return false, sTips, sLock
    end
    local mapGroup = (CacheTable.GetData)("_StarTower", nGroupId)
    if mapGroup == nil then
      return false, sTips, sLock
    end
    for _,mapStarTower in pairs(mapGroup) do
      if mapStarTower.Difficulty > nMaxDifficulty then
        do
          do return mapStarTower.Id ~= nStarTowerId, sTips, sLock end
          -- DECOMPILER ERROR at PC98: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC98: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
    do return false, sTips, sLock end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end
end

PlayerStarTowerData.GetStarTowerRewardLimit = function(self)
  -- function num : 0_24 , upvalues : _ENV
  local nWorldClass = (PlayerData.Base):GetWorldClass()
  local worldClassCfg = (ConfigTable.GetData)("WorldClass", nWorldClass, true)
  if not worldClassCfg then
    return 0
  end
  local nLimit = worldClassCfg.RewardLimit
  local mapUp = nil
  if (self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).TowerTicketLimitUp] then
    for nNodeId,v in pairs((self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).TowerTicketLimitUp]) do
      if not self.nFirstGrowthGroup then
        printError("判断票根货币上限前未请求星塔养成数据")
        break
      else
        local bActive = (((self.tbGrowthNodes)[v.Group])[nNodeId]).bActive
        if bActive then
          local tbParams = decodeJson(v.ClientParams)
          if not mapUp or mapUp.priority < v.Priority then
            mapUp = {value = tbParams[1], priority = v.Priority}
          end
        end
      end
    end
  end
  do
    local nUp = mapUp and mapUp.value or 0
    nLimit = nLimit + nUp
    return nLimit
  end
end

PlayerStarTowerData.GetDiscFormationSubSlot = function(self)
  -- function num : 0_25 , upvalues : _ENV
  local nBase = (ConfigTable.GetConfigNumber)("StarTowerDiscExtraSubSlotCount")
  local nSlotCount = 0
  if (self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).DiscExtraSubSlot] then
    for nNodeId,v in pairs((self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).DiscExtraSubSlot]) do
      if not self.nFirstGrowthGroup then
        printError("判断辅位星盘编队开放数量前未请求星塔养成数据")
        break
      else
        local bActive = (((self.tbGrowthNodes)[v.Group])[nNodeId]).bActive
        if bActive then
          local tbParams = decodeJson(v.ClientParams)
          if nSlotCount < tbParams[1] then
            nSlotCount = tbParams[1]
          end
        end
      end
    end
  end
  do
    local nAfter = nSlotCount + nBase
    if nAfter > 3 then
      nAfter = 3
    end
    return nAfter
  end
end

PlayerStarTowerData.CacheStarTowerTicket = function(self, nCount)
  -- function num : 0_26
  self.nStarTowerTicket = nCount
end

PlayerStarTowerData.AddStarTowerTicket = function(self, nCount)
  -- function num : 0_27
  if nCount == nil then
    return 
  end
  self.nStarTowerTicket = self.nStarTowerTicket + nCount
end

PlayerStarTowerData.GetStarTowerTicket = function(self)
  -- function num : 0_28
  return self.nStarTowerTicket
end

PlayerStarTowerData.GetAvailableStarTowerTicket = function(self)
  -- function num : 0_29
  local nLimit = self:GetStarTowerRewardLimit()
  local nAvailable = nLimit - self.nStarTowerTicket
  return nAvailable
end

PlayerStarTowerData.OnEvent_NewDay = function(self)
  -- function num : 0_30 , upvalues : _ENV
  self.bGetAffinity = false
  local curTimeStamp = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  local nWeek = tonumber((os.date)("!%w", curTimeStamp))
  if nWeek == 1 then
    self.nStarTowerTicket = 0
  end
end

PlayerStarTowerData.CacheClientEffectNodeConfigData = function(self)
  -- function num : 0_31 , upvalues : _ENV
  self.tbClientEffectNodeByIndex = {}
  self.tbClientEffectNodeByType = {}
  local foreachNode = function(mapLineData)
    -- function num : 0_31_0 , upvalues : self
    if mapLineData.IsClient then
      local nGroupId = mapLineData.Group
      -- DECOMPILER ERROR at PC10: Confused about usage of register: R2 in 'UnsetPending'

      if not (self.tbClientEffectNodeByIndex)[nGroupId] then
        (self.tbClientEffectNodeByIndex)[nGroupId] = {}
      end
      -- DECOMPILER ERROR at PC19: Confused about usage of register: R2 in 'UnsetPending'

      if not (self.tbClientEffectNodeByType)[mapLineData.EffectClient] then
        (self.tbClientEffectNodeByType)[mapLineData.EffectClient] = {}
      end
      -- DECOMPILER ERROR at PC23: Confused about usage of register: R2 in 'UnsetPending'

      ;
      ((self.tbClientEffectNodeByIndex)[nGroupId])[mapLineData.NodeId] = mapLineData
      -- DECOMPILER ERROR at PC28: Confused about usage of register: R2 in 'UnsetPending'

      ;
      ((self.tbClientEffectNodeByType)[mapLineData.EffectClient])[mapLineData.Id] = mapLineData
    end
  end

  ForEachTableLine(DataTable.StarTowerGrowthNode, foreachNode)
end

PlayerStarTowerData.GetClientEffectByNode = function(self, tbActiveNode)
  -- function num : 0_32 , upvalues : _ENV
  local tbEffectType = {}
  for nGroupId,tbGroupNode in pairs(self.tbClientEffectNodeByIndex) do
    for NodeId,mapLine in pairs(tbGroupNode) do
      local nNode = tbActiveNode[nGroupId]
      local bActive = false
      bActive = not nNode or nNode & 1 << NodeId - 1 ~= 0
      if bActive and (not tbEffectType[mapLine.EffectClient] or (tbEffectType[mapLine.EffectClient]).Priority < mapLine.Priority) then
        tbEffectType[mapLine.EffectClient] = {ClientParams = mapLine.ClientParams, Priority = mapLine.Priority}
      end
    end
  end
  do return tbEffectType end
  -- DECOMPILER ERROR: 5 unprocessed JMP targets
end

PlayerStarTowerData.ParseGrowthData = function(self, mapMsgData)
  -- function num : 0_33
  self.tbGrowthNodes = {}
  self.tbGrowthGroup = {}
  self.nFirstGrowthGroup = 0
  self:ParseGrowthGroupConfigData()
  self:ParseGrowthNodeConfigData(mapMsgData)
  self:ParseGrowthGroupServerData()
  self:ParseGrowthNodeServerData()
end

PlayerStarTowerData.ParseGrowthGroupConfigData = function(self)
  -- function num : 0_34 , upvalues : _ENV
  local create = function(mapLineData)
    -- function num : 0_34_0 , upvalues : self
    local mapGroup = (self.tbGrowthGroup)[mapLineData.Id]
    if not mapGroup then
      mapGroup = {nId = mapLineData.Id, nPreGroup = mapLineData.PreGroup, nNextGroup = 0, nWorldClass = mapLineData.WorldClass, bLock = true, nAllNodeCount = 0, nActiveNodeCount = 0}
      -- DECOMPILER ERROR at PC19: Confused about usage of register: R2 in 'UnsetPending'

      ;
      (self.tbGrowthGroup)[mapLineData.Id] = mapGroup
    end
    return mapGroup
  end

  local foreachGroup = function(mapLineData)
    -- function num : 0_34_1 , upvalues : create, _ENV, self
    local nGroupId = mapLineData.Id
    create(mapLineData)
    if mapLineData.PreGroup ~= 0 then
      local mapCfg = (ConfigTable.GetData)("StarTowerGrowthGroup", mapLineData.PreGroup)
      if mapCfg then
        local mapPreGroup = create(mapCfg)
        mapPreGroup.nNextGroup = nGroupId
      end
    else
      do
        self.nFirstGrowthGroup = nGroupId
      end
    end
  end

  ForEachTableLine(DataTable.StarTowerGrowthGroup, foreachGroup)
end

PlayerStarTowerData.ParseGrowthNodeConfigData = function(self, tbActiveNode)
  -- function num : 0_35 , upvalues : _ENV
  local create = function(mapLineData)
    -- function num : 0_35_0 , upvalues : self, tbActiveNode
    local mapNode = ((self.tbGrowthNodes)[mapLineData.Group])[mapLineData.Id]
    if not mapNode then
      local nNode = tbActiveNode[mapLineData.Group]
      local bActive = false
      bActive = not nNode or nNode & 1 << mapLineData.NodeId - 1 ~= 0
      mapNode = {nId = mapLineData.Id, tbPreNodes = mapLineData.PreNodes, 
tbNextNodes = {}
, bActive = bActive, bReady = false}
      -- DECOMPILER ERROR at PC34: Confused about usage of register: R4 in 'UnsetPending'

      ;
      ((self.tbGrowthNodes)[mapLineData.Group])[mapLineData.Id] = mapNode
    end
    do return mapNode end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end

  local foreachNode = function(mapLineData)
    -- function num : 0_35_1 , upvalues : self, create, _ENV
    local nGroupId = mapLineData.Group
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

    if not (self.tbGrowthNodes)[nGroupId] then
      (self.tbGrowthNodes)[nGroupId] = {}
    end
    create(mapLineData)
    if #mapLineData.PreNodes > 0 then
      for _,nPreId in ipairs(mapLineData.PreNodes) do
        local mapCfg = (ConfigTable.GetData)("StarTowerGrowthNode", nPreId)
        if mapCfg then
          local mapPreNode = create(mapCfg)
          ;
          (table.insert)(mapPreNode.tbNextNodes, mapLineData.Id)
        end
      end
    end
  end

  ForEachTableLine(DataTable.StarTowerGrowthNode, foreachNode)
end

PlayerStarTowerData.ParseGrowthGroupServerData = function(self)
  -- function num : 0_36 , upvalues : _ENV
  local nCurWorldClass = (PlayerData.Base):GetWorldClass()
  local bPreGroupAllActive = true
  local mapCurGroup = (self.tbGrowthGroup)[self.nFirstGrowthGroup]
  while mapCurGroup do
    local nCurGroupId = mapCurGroup.nId
    local bLock = not bPreGroupAllActive or nCurWorldClass < mapCurGroup.nWorldClass
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R6 in 'UnsetPending'

    ;
    ((self.tbGrowthGroup)[nCurGroupId]).bLock = bLock
    local nAllNodeCount, nActiveNodeCount = 0, 0
    for _,mapNode in pairs((self.tbGrowthNodes)[nCurGroupId]) do
      nAllNodeCount = nAllNodeCount + 1
      if mapNode.bActive then
        nActiveNodeCount = nActiveNodeCount + 1
      end
    end
    -- DECOMPILER ERROR at PC37: Confused about usage of register: R8 in 'UnsetPending'

    ;
    ((self.tbGrowthGroup)[nCurGroupId]).nAllNodeCount = nAllNodeCount
    -- DECOMPILER ERROR at PC40: Confused about usage of register: R8 in 'UnsetPending'

    ;
    ((self.tbGrowthGroup)[nCurGroupId]).nActiveNodeCount = nActiveNodeCount
    mapCurGroup = (self.tbGrowthGroup)[mapCurGroup.nNextGroup]
    bPreGroupAllActive = nActiveNodeCount == nAllNodeCount
  end
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

PlayerStarTowerData.ParseGrowthNodeServerData = function(self)
  -- function num : 0_37 , upvalues : _ENV
  for nGroupId,tbNodes in pairs(self.tbGrowthNodes) do
    local bGroupLock = ((self.tbGrowthGroup)[nGroupId]).bLock
    for nId,_ in pairs(tbNodes) do
      -- DECOMPILER ERROR at PC16: Confused about usage of register: R12 in 'UnsetPending'

      if bGroupLock then
        (((self.tbGrowthNodes)[nGroupId])[nId]).bReady = false
      else
        self:CheckNodeReady(nId, nGroupId)
      end
    end
  end
end

PlayerStarTowerData.CheckNodeReady = function(self, nId, nGroupId)
  -- function num : 0_38 , upvalues : _ENV
  local bAllPreActive = true
  for _,nPreId in pairs((((self.tbGrowthNodes)[nGroupId])[nId]).tbPreNodes) do
    if not ((self.tbGrowthNodes)[nGroupId])[nPreId] then
      printError("星塔养成没有节点配置" .. nPreId)
    else
      if not (((self.tbGrowthNodes)[nGroupId])[nPreId]).bActive then
        bAllPreActive = false
        break
      end
    end
  end
  do
    -- DECOMPILER ERROR at PC32: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (((self.tbGrowthNodes)[nGroupId])[nId]).bReady = bAllPreActive
  end
end

PlayerStarTowerData.UnlockNode = function(self, nId, nGroupId)
  -- function num : 0_39 , upvalues : _ENV
  local nCurWorldClass = (PlayerData.Base):GetWorldClass()
  local mapCurGroup = (self.tbGrowthGroup)[nGroupId]
  -- DECOMPILER ERROR at PC9: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self.tbGrowthNodes)[nGroupId])[nId]).bActive = true
  -- DECOMPILER ERROR at PC16: Confused about usage of register: R5 in 'UnsetPending'

  ;
  ((self.tbGrowthGroup)[nGroupId]).nActiveNodeCount = ((self.tbGrowthGroup)[nGroupId]).nActiveNodeCount + 1
  if mapCurGroup.nActiveNodeCount == mapCurGroup.nAllNodeCount then
    local nNextGroupId = mapCurGroup.nNextGroup
    if not (self.tbGrowthGroup)[nNextGroupId] then
      return 
    end
    local bLock = nCurWorldClass < ((self.tbGrowthGroup)[nNextGroupId]).nWorldClass
    -- DECOMPILER ERROR at PC36: Confused about usage of register: R7 in 'UnsetPending'

    ;
    ((self.tbGrowthGroup)[nNextGroupId]).bLock = bLock
    if not bLock then
      for _,v in pairs((self.tbGrowthNodes)[nNextGroupId]) do
        -- DECOMPILER ERROR at PC52: Confused about usage of register: R12 in 'UnsetPending'

        if #v.tbPreNodes == 0 then
          (((self.tbGrowthNodes)[nNextGroupId])[v.nId]).bReady = true
        end
      end
    end
  else
    for _,nNextId in pairs((((self.tbGrowthNodes)[nGroupId])[nId]).tbNextNodes) do
      self:CheckNodeReady(R12_PC66, nGroupId)
    end
  end
  -- DECOMPILER ERROR: 5 unprocessed JMP targets
end

PlayerStarTowerData.UnlockMultiNode = function(self, tbNodeId, nGroupId)
  -- function num : 0_40 , upvalues : _ENV
  local bHasCore = false
  for _,nId in ipairs(tbNodeId) do
    local mapCfg = (ConfigTable.GetData)("StarTowerGrowthNode", nId)
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R10 in 'UnsetPending'

    if mapCfg then
      (((self.tbGrowthNodes)[nGroupId])[nId]).bActive = true
      -- DECOMPILER ERROR at PC22: Confused about usage of register: R10 in 'UnsetPending'

      ;
      ((self.tbGrowthGroup)[nGroupId]).nActiveNodeCount = ((self.tbGrowthGroup)[nGroupId]).nActiveNodeCount + 1
      if mapCfg.Type == (GameEnum.towerGrowthNodeType).Core then
        bHasCore = true
      end
    end
  end
  local nCurWorldClass = (PlayerData.Base):GetWorldClass()
  local mapCurGroup = (self.tbGrowthGroup)[nGroupId]
  if mapCurGroup.nActiveNodeCount == mapCurGroup.nAllNodeCount then
    local nNextGroupId = mapCurGroup.nNextGroup
    if not (self.tbGrowthGroup)[nNextGroupId] then
      return bHasCore
    end
    local bLock = nCurWorldClass < ((self.tbGrowthGroup)[nNextGroupId]).nWorldClass
    -- DECOMPILER ERROR at PC57: Confused about usage of register: R8 in 'UnsetPending'

    ;
    ((self.tbGrowthGroup)[nNextGroupId]).bLock = bLock
    if not bLock then
      for _,v in pairs((self.tbGrowthNodes)[nNextGroupId]) do
        -- DECOMPILER ERROR at PC73: Confused about usage of register: R13 in 'UnsetPending'

        if #v.tbPreNodes == 0 then
          (((self.tbGrowthNodes)[nNextGroupId])[v.nId]).bReady = true
        end
      end
    end
  else
    for nId,v in pairs((self.tbGrowthNodes)[nGroupId]) do
      if not v.bActive then
        self:CheckNodeReady(R13_PC88, nGroupId)
      end
    end
  end
  do return bHasCore end
  -- DECOMPILER ERROR: 5 unprocessed JMP targets
end

PlayerStarTowerData.GetGrowthGroup = function(self, nId)
  -- function num : 0_41
  return (self.tbGrowthGroup)[nId]
end

PlayerStarTowerData.GetSortedGrowthGroup = function(self)
  -- function num : 0_42 , upvalues : _ENV
  local tbSorted = {}
  local mapCurGroup = (self.tbGrowthGroup)[self.nFirstGrowthGroup]
  while mapCurGroup do
    (table.insert)(tbSorted, mapCurGroup)
    mapCurGroup = (self.tbGrowthGroup)[mapCurGroup.nNextGroup]
  end
  return tbSorted
end

PlayerStarTowerData.GetGrowthNodesByGroup = function(self, nGroupId)
  -- function num : 0_43
  return (self.tbGrowthNodes)[nGroupId]
end

PlayerStarTowerData.GetGrowthNode = function(self, nId, nGroupId)
  -- function num : 0_44 , upvalues : _ENV
  do
    if not nGroupId then
      local mapCfg = (ConfigTable.GetData)("StarTowerGrowthNode", nId)
      if not mapCfg then
        printError("星塔养成节点Id有误, 未找到配置表数据, Id: " .. nId)
        return {}
      end
      nGroupId = mapCfg.Group
    end
    return ((self.tbGrowthNodes)[nGroupId])[nId]
  end
end

PlayerStarTowerData.CheckGroupReady = function(self, nGroupId)
  -- function num : 0_45 , upvalues : _ENV
  if ((self.tbGrowthGroup)[nGroupId]).bLock then
    return false, (ConfigTable.GetUIText)("STGrowth_GroupLocked")
  end
  local bGroupAllActive = ((self.tbGrowthGroup)[nGroupId]).nAllNodeCount == ((self.tbGrowthGroup)[nGroupId]).nActiveNodeCount
  if bGroupAllActive then
    return false, (ConfigTable.GetUIText)("STGrowth_GroupAlreadyActived")
  end
  local tbGroup = {}
  for _,v in pairs((self.tbGrowthNodes)[nGroupId]) do
    (table.insert)(tbGroup, v)
  end
  ;
  (table.sort)(tbGroup, function(a, b)
    -- function num : 0_45_0 , upvalues : _ENV
    do return ((ConfigTable.GetData)("StarTowerGrowthNode", a.nId)).NodeId < ((ConfigTable.GetData)("StarTowerGrowthNode", b.nId)).NodeId end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  local checkMat = function(mapCfg)
    -- function num : 0_45_1 , upvalues : _ENV
    local bMat = true
    for i = 1, 3 do
      if mapCfg["ItemId" .. i] ~= 0 then
        local nHas = (PlayerData.Item):GetItemCountByID(mapCfg["ItemId" .. i])
        if nHas < mapCfg["ItemQty" .. i] then
          bMat = false
          break
        end
      end
    end
    do
      return bMat
    end
  end

  local bAble = false
  for _,v in ipairs(tbGroup) do
    if not v.bActive and v.bReady then
      local mapCfg = (ConfigTable.GetData)("StarTowerGrowthNode", v.nId)
      if mapCfg then
        bAble = checkMat(mapCfg)
        break
      end
    end
  end
  do return bAble, (ConfigTable.GetUIText)("STGrowth_NoMat") end
  -- DECOMPILER ERROR: 5 unprocessed JMP targets
end

PlayerStarTowerData.SendTowerGrowthDetailReq = function(self, callback)
  -- function num : 0_46 , upvalues : _ENV
  if not self.nFirstGrowthGroup then
    local successCallback = function(_, mapMainData)
    -- function num : 0_46_0 , upvalues : self, callback
    self:ParseGrowthData(mapMainData.Detail)
    self:UpdateGrowthReddot()
    if callback then
      callback()
    end
  end

    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).tower_growth_detail_req, {}, nil, successCallback)
  else
    do
      if callback then
        callback()
      end
    end
  end
end

PlayerStarTowerData.SendTowerGrowthNodeUnlockReq = function(self, nId, nGroupId, callback)
  -- function num : 0_47 , upvalues : _ENV
  local msgData = {Value = nId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_47_0 , upvalues : self, nId, nGroupId, callback
    self:UnlockNode(nId, nGroupId)
    self:UpdateGrowthReddot()
    if callback then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).tower_growth_node_unlock_req, msgData, nil, successCallback)
end

PlayerStarTowerData.SendTowerGrowthGroupNodeUnlockReq = function(self, nGroupId, callback)
  -- function num : 0_48 , upvalues : _ENV
  local msgData = {Value = nGroupId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_48_0 , upvalues : _ENV, self, nGroupId, callback
    local tbDecodeChange = (UTILS.DecodeChangeInfo)(mapMainData.ChangeInfo)
    local tbItem = tbDecodeChange["proto.Item"]
    do
      if type(tbItem) == "table" and #tbItem == 1 and (tbItem[1]).Qty < 0 then
        local nCount = -1 * (tbItem[1]).Qty
        ;
        (EventManager.Hit)(EventId.OpenMessageBox, orderedFormat((ConfigTable.GetUIText)("STGrowth_AllActiveSuc") or "", nCount, #mapMainData.Nodes))
      end
      local bHasCore = self:UnlockMultiNode(mapMainData.Nodes, nGroupId)
      self:UpdateGrowthReddot()
      if callback then
        callback(mapMainData.Nodes, bHasCore)
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).tower_growth_group_node_unlock_req, msgData, nil, successCallback)
end

PlayerStarTowerData.UpdateGrowthReddot = function(self)
  -- function num : 0_49 , upvalues : _ENV
  local checkMat = function(mapCfg)
    -- function num : 0_49_0 , upvalues : _ENV
    local bMat = true
    for i = 1, 3 do
      if mapCfg["ItemId" .. i] ~= 0 then
        local nHas = (PlayerData.Item):GetItemCountByID(mapCfg["ItemId" .. i])
        if nHas < mapCfg["ItemQty" .. i] then
          bMat = false
          break
        end
      end
    end
    do
      return bMat
    end
  end

  local nGroupCount = #self.tbGrowthGroup
  local nGroupId = nil
  for i = nGroupCount, 1, -1 do
    if not ((self.tbGrowthGroup)[i]).bLock then
      nGroupId = i
      break
    end
  end
  do
    local bHas = false
    if (self.tbGrowthNodes)[nGroupId] then
      for nId,mapNode in pairs((self.tbGrowthNodes)[nGroupId]) do
        if not mapNode.bActive and mapNode.bReady then
          local mapCfg = (ConfigTable.GetData)("StarTowerGrowthNode", nId)
          if mapCfg and checkMat(mapCfg) then
            bHas = true
            break
          end
        end
      end
    end
    do
      ;
      (RedDotManager.SetValid)(RedDotDefine.StarTowerGrowth, nil, bHas)
    end
  end
end

PlayerStarTowerData.UpdateGrowthRedDotByItem = function(self, mapChange)
  -- function num : 0_50 , upvalues : _ENV
  if not self.nFirstGrowthGroup then
    return 
  end
  if not self.tbGrowthNodeMat then
    self.tbGrowthNodeMat = (ConfigTable.GetConfigNumberArray)("StarTowerGrowthItemIds")
  end
  for _,v in ipairs(mapChange) do
    if (table.indexof)(self.tbGrowthNodeMat, v.Tid) > 0 and v.Qty > 0 then
      self:UpdateGrowthReddot()
      return 
    end
  end
end

PlayerStarTowerData.OnEvent_WorldClass = function(self)
  -- function num : 0_51 , upvalues : _ENV
  if not self.nFirstGrowthGroup then
    return 
  end
  local nCurWorldClass = (PlayerData.Base):GetWorldClass()
  for nGroupId,v in ipairs(self.tbGrowthGroup) do
    if v.bLock then
      local mapPreGroup = (self.tbGrowthGroup)[v.nPreGroup]
      local bPreGroupAllActive = mapPreGroup.nAllNodeCount == mapPreGroup.nActiveNodeCount
      local bLock = not bPreGroupAllActive or nCurWorldClass < v.nWorldClass
      -- DECOMPILER ERROR at PC35: Confused about usage of register: R10 in 'UnsetPending'

      if not bLock then
        ((self.tbGrowthGroup)[nGroupId]).bLock = bLock
        for nNodeId,mapNode in pairs((self.tbGrowthNodes)[nGroupId]) do
          -- DECOMPILER ERROR at PC48: Confused about usage of register: R15 in 'UnsetPending'

          if #mapNode.tbPreNodes == 0 then
            (((self.tbGrowthNodes)[nGroupId])[nNodeId]).bReady = true
          end
        end
      end
      self:UpdateGrowthReddot()
      break
    end
  end
  -- DECOMPILER ERROR: 6 unprocessed JMP targets
end

PlayerStarTowerData.GetAffinity = function(self, callback)
  -- function num : 0_52 , upvalues : _ENV
  local netMsg_callback = function(_, msgData)
    -- function num : 0_52_0 , upvalues : self, callback
    self:CacheNpcAffinity(msgData)
    if callback ~= nil then
      self.bGetAffinity = true
      callback()
    end
  end

  if self.bGetAffinity == true then
    if callback ~= nil then
      callback()
    end
    return 
  end
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).npc_affinity_book_get_req, {}, nil, netMsg_callback)
end

PlayerStarTowerData.InitNpcAffinity = function(self)
  -- function num : 0_53
  self.mapNpcAffinity = {}
  self.nAffinityGetCount = 0
  self.bGetAffinity = false
end

PlayerStarTowerData.CacheNpcAffinity = function(self, mapData)
  -- function num : 0_54 , upvalues : _ENV
  self.nAffinityGetCount = mapData.Number
  for _,mapAffinityData in ipairs(mapData.Infos) do
    local ret = {Level = 0, Exp = 0, nNeed = 0, nTotalExp = mapAffinityData.Affinity, nMaxLevel = 0, tbPlotIds = mapAffinityData.PlotIds}
    local nAffinityExp = mapAffinityData.Affinity
    local mapNpc = (ConfigTable.GetData)("StarTowerNPC", mapAffinityData.NPCId)
    -- DECOMPILER ERROR at PC25: Confused about usage of register: R10 in 'UnsetPending'

    if mapNpc == nil then
      (self.mapNpcAffinity)[mapAffinityData.NPCId] = ret
    end
    local nGroupId = mapNpc.AffinityGroupId
    local nMaxLevel = (self.mapNpcAffinityGroupMaxLevel)[nGroupId]
    ret.nMaxLevel = nMaxLevel
    -- DECOMPILER ERROR at PC34: Confused about usage of register: R12 in 'UnsetPending'

    if nMaxLevel == nil then
      (self.mapNpcAffinity)[mapAffinityData.NPCId] = ret
    end
    for i = 0, nMaxLevel do
      local nId = nGroupId * 100 + i
      local mapAffinityCfgData = (ConfigTable.GetData)("NPCAffinityGroup", nId)
      if mapAffinityCfgData ~= nil and mapAffinityCfgData.AffinityValue <= nAffinityExp then
        ret.Level = mapAffinityCfgData.Level
        ret.Exp = nAffinityExp - mapAffinityCfgData.AffinityValue
        if mapAffinityCfgData.Level + 1 <= nMaxLevel then
          local nNextId = nGroupId * 100 + mapAffinityCfgData.Level + 1
          local nNextLevelCfgData = (ConfigTable.GetData)("NPCAffinityGroup", nNextId)
          if nNextLevelCfgData ~= nil then
            ret.nNeed = nNextLevelCfgData.AffinityValue - mapAffinityCfgData.AffinityValue
          end
        else
          do
            do
              ret.nNeed = 0
              -- DECOMPILER ERROR at PC77: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC77: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC77: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC77: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC77: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
    -- DECOMPILER ERROR at PC80: Confused about usage of register: R12 in 'UnsetPending'

    ;
    (self.mapNpcAffinity)[mapAffinityData.NPCId] = ret
  end
  self:UpdateNpcAffinityRedDot()
end

PlayerStarTowerData.ReceiveNpcAffinityReward = function(self, nNpcId, nPlotId, receiveCallback)
  -- function num : 0_55 , upvalues : _ENV
  local mapMsg = {Value = nPlotId}
  local receivePropCallback = function(mapShow, mapChange)
    -- function num : 0_55_0 , upvalues : receiveCallback, _ENV
    if receiveCallback ~= nil and type(receiveCallback) == "function" then
      receiveCallback(mapShow, mapChange)
    end
  end

  local callback = function(_, mapRespData)
    -- function num : 0_55_1 , upvalues : self, nNpcId, _ENV, nPlotId, receivePropCallback
    -- DECOMPILER ERROR at PC18: Confused about usage of register: R2 in 'UnsetPending'

    if self.mapNpcAffinity ~= nil then
      if (self.mapNpcAffinity)[nNpcId] == nil then
        (self.mapNpcAffinity)[nNpcId] = {Level = 0, Exp = 0, nNeed = 0, nTotalExp = 0, nMaxLevel = 0, 
tbPlotIds = {}
}
      end
      if ((self.mapNpcAffinity)[nNpcId]).tbPlotIds ~= nil then
        (table.insert)(((self.mapNpcAffinity)[nNpcId]).tbPlotIds, nPlotId)
      end
    end
    self:UpdateNpcAffinityRedDot()
    receivePropCallback(mapRespData.Show, mapRespData.Change)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).npc_affinity_plot_reward_receive_req, mapMsg, nil, callback)
end

PlayerStarTowerData.GetNpcAffinityWeekCount = function(self)
  -- function num : 0_56
  return self.nAffinityGetCount
end

PlayerStarTowerData.CacheNpcAffinityChange = function(self, tbRewards, nCount)
  -- function num : 0_57 , upvalues : _ENV
  for _,mapReward in ipairs(tbRewards) do
    local nNpcId = (mapReward.Change).NPCId
    -- DECOMPILER ERROR at PC19: Confused about usage of register: R9 in 'UnsetPending'

    if (self.mapNpcAffinity)[nNpcId] == nil then
      (self.mapNpcAffinity)[nNpcId] = {Level = 0, Exp = 0, nNeed = 0, nTotalExp = 0, nMaxLevel = 0, 
tbPlotIds = {}
}
    end
    -- DECOMPILER ERROR at PC24: Confused about usage of register: R9 in 'UnsetPending'

    ;
    ((self.mapNpcAffinity)[nNpcId]).nTotalExp = (mapReward.Change).Affinity
    local nAffinityExp = (mapReward.Change).Affinity
    local mapNpc = (ConfigTable.GetData)("StarTowerNPC", nNpcId)
    if mapNpc ~= nil then
      local nGroupId = mapNpc.AffinityGroupId
      local nMaxLevel = (self.mapNpcAffinityGroupMaxLevel)[nGroupId]
      -- DECOMPILER ERROR at PC39: Confused about usage of register: R13 in 'UnsetPending'

      ;
      ((self.mapNpcAffinity)[nNpcId]).nMaxLevel = nMaxLevel
      if nMaxLevel ~= nil then
        for i = 0, nMaxLevel do
          local nId = nGroupId * 100 + i
          local mapAffinityCfgData = (ConfigTable.GetData)("NPCAffinityGroup", nId)
          -- DECOMPILER ERROR at PC61: Confused about usage of register: R19 in 'UnsetPending'

          if mapAffinityCfgData ~= nil and mapAffinityCfgData.AffinityValue <= nAffinityExp then
            ((self.mapNpcAffinity)[nNpcId]).Level = mapAffinityCfgData.Level
            -- DECOMPILER ERROR at PC66: Confused about usage of register: R19 in 'UnsetPending'

            ;
            ((self.mapNpcAffinity)[nNpcId]).Exp = nAffinityExp - mapAffinityCfgData.AffinityValue
            if mapAffinityCfgData.Level + 1 <= nMaxLevel then
              local nNextId = nGroupId * 100 + mapAffinityCfgData.Level + 1
              local nNextLevelCfgData = (ConfigTable.GetData)("NPCAffinityGroup", nNextId)
              -- DECOMPILER ERROR at PC87: Confused about usage of register: R21 in 'UnsetPending'

              if nNextLevelCfgData ~= nil then
                ((self.mapNpcAffinity)[nNpcId]).nNeed = nNextLevelCfgData.AffinityValue - mapAffinityCfgData.AffinityValue
              end
            else
              do
                do
                  -- DECOMPILER ERROR at PC91: Confused about usage of register: R19 in 'UnsetPending'

                  ;
                  ((self.mapNpcAffinity)[nNpcId]).nNeed = 0
                  -- DECOMPILER ERROR at PC92: LeaveBlock: unexpected jumping out DO_STMT

                  -- DECOMPILER ERROR at PC92: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                  -- DECOMPILER ERROR at PC92: LeaveBlock: unexpected jumping out IF_STMT

                  -- DECOMPILER ERROR at PC92: LeaveBlock: unexpected jumping out IF_THEN_STMT

                  -- DECOMPILER ERROR at PC92: LeaveBlock: unexpected jumping out IF_STMT

                end
              end
            end
          end
        end
      end
    end
  end
  if nCount ~= nil then
    self.nAffinityGetCount = nCount
  end
  self:UpdateNpcAffinityRedDot()
end

PlayerStarTowerData.GetNpcAffinityData = function(self, nNpcId)
  -- function num : 0_58 , upvalues : _ENV
  if (self.mapNpcAffinity)[nNpcId] ~= nil then
    return clone((self.mapNpcAffinity)[nNpcId])
  else
    local ret = {Level = 0, Exp = 0, nNeed = 1, nTotalExp = 0, nMaxLevel = 0, 
tbPlotIds = {}
}
    local mapNpc = (ConfigTable.GetData)("StarTowerNPC", nNpcId)
    if mapNpc ~= nil then
      local nGroupId = mapNpc.AffinityGroupId
      local nId = nGroupId * 100 + 1
      local mapAffinityCfgData = (ConfigTable.GetData)("NPCAffinityGroup", nId)
      if mapAffinityCfgData ~= nil then
        ret.nNeed = mapAffinityCfgData.AffinityValue
      end
    end
    do
      do return ret end
    end
  end
end

PlayerStarTowerData.GetNpcReceivedPlot = function(self, nNpcId)
  -- function num : 0_59
  if (self.mapNpcAffinity)[nNpcId] ~= nil then
    return ((self.mapNpcAffinity)[nNpcId]).tbPlotIds
  else
    return {}
  end
end

PlayerStarTowerData.GetNpcPlotReceived = function(self, nNpcId, nPlotId)
  -- function num : 0_60 , upvalues : _ENV
  if (table.indexof)(((self.mapNpcAffinity)[nNpcId]).tbPlotIds, nPlotId) <= 0 then
    do return (self.mapNpcAffinity)[nNpcId] == nil end
    do return false end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end
end

PlayerStarTowerData.ChangeNpcAffinity = function(self, mapInfo)
  -- function num : 0_61 , upvalues : _ENV
  local nNpcId = mapInfo.NPCId
  -- DECOMPILER ERROR at PC14: Confused about usage of register: R3 in 'UnsetPending'

  if (self.mapNpcAffinity)[nNpcId] == nil then
    (self.mapNpcAffinity)[nNpcId] = {Level = 0, Exp = 0, nNeed = 0, nTotalExp = 0, nMaxLevel = 0, 
tbPlotIds = {}
}
  end
  -- DECOMPILER ERROR at PC18: Confused about usage of register: R3 in 'UnsetPending'

  ;
  ((self.mapNpcAffinity)[nNpcId]).nTotalExp = mapInfo.Affinity
  local nAffinityExp = mapInfo.Affinity
  local mapNpc = (ConfigTable.GetData)("StarTowerNPC", nNpcId)
  if mapNpc ~= nil then
    local nGroupId = mapNpc.AffinityGroupId
    local nMaxLevel = (self.mapNpcAffinityGroupMaxLevel)[nGroupId]
    -- DECOMPILER ERROR at PC32: Confused about usage of register: R7 in 'UnsetPending'

    ;
    ((self.mapNpcAffinity)[nNpcId]).nMaxLevel = nMaxLevel
    if nMaxLevel ~= nil then
      for i = 0, nMaxLevel do
        local nId = nGroupId * 100 + i
        local mapAffinityCfgData = (ConfigTable.GetData)("NPCAffinityGroup", nId)
        -- DECOMPILER ERROR at PC54: Confused about usage of register: R13 in 'UnsetPending'

        if mapAffinityCfgData ~= nil and mapAffinityCfgData.AffinityValue <= nAffinityExp then
          ((self.mapNpcAffinity)[nNpcId]).Level = mapAffinityCfgData.Level
          -- DECOMPILER ERROR at PC59: Confused about usage of register: R13 in 'UnsetPending'

          ;
          ((self.mapNpcAffinity)[nNpcId]).Exp = nAffinityExp - mapAffinityCfgData.AffinityValue
          if mapAffinityCfgData.Level + 1 <= nMaxLevel then
            local nNextId = nGroupId * 100 + mapAffinityCfgData.Level + 1
            local nNextLevelCfgData = (ConfigTable.GetData)("NPCAffinityGroup", nNextId)
            -- DECOMPILER ERROR at PC80: Confused about usage of register: R15 in 'UnsetPending'

            if nNextLevelCfgData ~= nil then
              ((self.mapNpcAffinity)[nNpcId]).nNeed = nNextLevelCfgData.AffinityValue - mapAffinityCfgData.AffinityValue
            end
          else
            do
              do
                -- DECOMPILER ERROR at PC84: Confused about usage of register: R13 in 'UnsetPending'

                ;
                ((self.mapNpcAffinity)[nNpcId]).nNeed = 0
                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out IF_STMT

                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out IF_THEN_STMT

                -- DECOMPILER ERROR at PC85: LeaveBlock: unexpected jumping out IF_STMT

              end
            end
          end
        end
      end
    end
  end
  do
    self:UpdateNpcAffinityRedDot()
  end
end

PlayerStarTowerData.UpdateNpcAffinityRedDot = function(self)
  -- function num : 0_62 , upvalues : _ENV
  local forEachNpc = function(mapData)
    -- function num : 0_62_0 , upvalues : _ENV
    (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Affinity_Reward, mapData.Id, false)
  end

  ForEachTableLine(DataTable.StarTowerNPC, forEachNpc)
  local ForEachNpcPlot = function(mapData)
    -- function num : 0_62_1 , upvalues : self, _ENV
    local nNpcId = mapData.NPCId
    if (self.mapNpcAffinity)[nNpcId] ~= nil and mapData.AffinityLevel <= ((self.mapNpcAffinity)[nNpcId]).Level and (table.indexof)(((self.mapNpcAffinity)[nNpcId]).tbPlotIds, mapData.Id) < 1 then
      (RedDotManager.SetValid)(RedDotDefine.StarTowerBook_Affinity_Reward, nNpcId, true)
    end
  end

  ForEachTableLine(DataTable.NPCAffinityPlot, ForEachNpcPlot)
end

PlayerStarTowerData.SetPotentialDescSimple = function(self, bSimple)
  -- function num : 0_63 , upvalues : LocalData
  self.bPotentialDescSimple = bSimple
  ;
  (LocalData.SetPlayerLocalData)("StarTowerPotentialDescSimple", bSimple and "1" or "0")
end

PlayerStarTowerData.GetPotentialDescSimple = function(self)
  -- function num : 0_64 , upvalues : LocalData, _ENV
  do
    if self.bPotentialDescSimple == nil then
      local sValue = (LocalData.GetPlayerLocalData)("StarTowerPotentialDescSimple")
      if sValue == nil then
        sValue = (ConfigTable.GetConfigValue)("PotentialShowDetail")
        ;
        (LocalData.SetPlayerLocalData)("StarTowerPotentialDescSimple", sValue)
      end
      self.bPotentialDescSimple = tonumber(sValue) ~= 1
    end
    do return self.bPotentialDescSimple end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end
end

PlayerStarTowerData.GetPotentialMaxLevelWithCurGrowth = function(self, nId)
  -- function num : 0_65 , upvalues : _ENV
  local nMaxLevel = 0
  local mapCfg = (ConfigTable.GetData)("Potential", nId)
  if mapCfg then
    nMaxLevel = nMaxLevel + mapCfg.MaxLevel
  end
  local nAdd = 0
  if (self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).PotentialMaxLvUp] then
    for nNodeId,v in pairs((self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).PotentialMaxLvUp]) do
      if not self.nFirstGrowthGroup then
        printError("查询潜能最大等级前未请求星塔养成数据")
        break
      else
        local bActive = (((self.tbGrowthNodes)[v.Group])[nNodeId]).bActive
        if bActive then
          local tbParams = decodeJson(v.ClientParams)
          if nAdd < tbParams[1] then
            nAdd = tbParams[1]
          end
        end
      end
    end
  end
  do
    nMaxLevel = nMaxLevel + nAdd
    return nMaxLevel
  end
end

PlayerStarTowerData.GetPotentialMaxLevelWithMaxGrowth = function(self, nId)
  -- function num : 0_66 , upvalues : _ENV
  local nMaxLevel = 0
  local mapCfg = (ConfigTable.GetData)("Potential", nId)
  if mapCfg then
    nMaxLevel = nMaxLevel + mapCfg.MaxLevel
  end
  local nAdd = 0
  if (self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).PotentialMaxLvUp] then
    for _,v in pairs((self.tbClientEffectNodeByType)[(GameEnum.towerGrowthEffect).PotentialMaxLvUp]) do
      local tbParams = decodeJson(v.ClientParams)
      if nAdd < tbParams[1] then
        nAdd = tbParams[1]
      end
    end
  end
  do
    nMaxLevel = nMaxLevel + nAdd
    return nMaxLevel
  end
end

PlayerStarTowerData.GetPotentialMaxLevelWithEquipment = function(self)
  -- function num : 0_67 , upvalues : _ENV
  return (ConfigTable.GetConfigNumber)("CharMaxPonLevel")
end

return PlayerStarTowerData

