local StarTowerLevelData = class("StarTowerLevelData")
local LocalStarTowerDataKey = "StarTowerData"
local RapidJson = require("rapidjson")
local PATH = "Game.Adventure.StarTower.StarTowerRoom."
local ConfigData = require("GameCore.Data.ConfigData")
local PB = require("pb")
local FP = (CS.TrueSync).FP
local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
local ModuleManager = require("GameCore.Module.ModuleManager")
local SDKManager = (CS.SDKManager).Instance
local AttrConfig = require("GameCore.Common.AttrConfig")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local mapProcCtrl = {[(GameEnum.starTowerRoomType).BattleRoom] = "BattleRoom", [(GameEnum.starTowerRoomType).EliteBattleRoom] = "BattleRoom", [(GameEnum.starTowerRoomType).BossRoom] = "BattleRoom", [(GameEnum.starTowerRoomType).FinalBossRoom] = "BattleRoom", [(GameEnum.starTowerRoomType).DangerRoom] = "BattleRoom", [(GameEnum.starTowerRoomType).HorrorRoom] = "BattleRoom"}
local mapBGMCfg = {[(GameEnum.starTowerRoomType).BattleRoom] = false, [(GameEnum.starTowerRoomType).EliteBattleRoom] = false, [(GameEnum.starTowerRoomType).BossRoom] = false, [(GameEnum.starTowerRoomType).FinalBossRoom] = false, [(GameEnum.starTowerRoomType).DangerRoom] = false, [(GameEnum.starTowerRoomType).HorrorRoom] = false, [(GameEnum.starTowerRoomType).ShopRoom] = true, [(GameEnum.starTowerRoomType).EventRoom] = true, [(GameEnum.starTowerRoomType).UnifyBattleRoom] = false}
local mapEventConfig = {takeEffect = "OnEvent_TakeEffect", LoadLevelRefresh = "OnEvent_LoadLevelRefresh", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", [EventId.StarTowerMap] = "OnEvent_OpenStarTowerMap", AbandonStarTower = "OnEvent_AbandonStarTower", [EventId.StarTowerDepot] = "OnEvent_OpenStarTowerDepot", [EventId.StarTowerLeave] = "OnEvent_StarTowerLeave", ReplayShopRoomBGM = "ReplayShopBGM"}
local EncodeTempDataJson = function(mapData)
  -- function num : 0_0 , upvalues : _ENV
  local stTempData = (CS.StarTowerTempData)(1)
  local stCharacter = {}
  for nCharId,mapEffect in pairs(mapData.effectInfo) do
    if stCharacter[nCharId] == nil then
      stCharacter[nCharId] = (CS.StarTowerCharacter)(nCharId)
    end
    for nEtfId,mapEft in pairs(mapEffect.mapEffect) do
      ((stCharacter[nCharId]).tbEffect):Add((CS.StarTowerEffect)(nEtfId, mapEft.nCount, mapEft.nCd))
    end
  end
  for nCharId,mapBuff in pairs(mapData.buffInfo) do
    if stCharacter[nCharId] == nil then
      stCharacter[nCharId] = (CS.StarTowerCharacter)(nCharId)
    end
    for _,buffInfo in ipairs(mapBuff) do
      ((stCharacter[nCharId]).tbBuff):Add((CS.StarTowerBuffInfo)(buffInfo.Id, buffInfo.CD, buffInfo.nNum))
    end
  end
  for nCharId,mapStatus in pairs(mapData.stateInfo) do
    if stCharacter[nCharId] == nil then
      stCharacter[nCharId] = (CS.StarTowerCharacter)(nCharId)
    end
    -- DECOMPILER ERROR at PC83: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (stCharacter[nCharId]).stateInfo = (CS.StarTowerState)(mapStatus.nState, mapStatus.nStateTime)
  end
  for nCharId,mapAmmoInfo in pairs(mapData.ammoInfo) do
    if stCharacter[nCharId] == nil then
      stCharacter[nCharId] = (CS.StarTowerCharacter)(nCharId)
    end
    -- DECOMPILER ERROR at PC109: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (stCharacter[nCharId]).ammoInfo = (CS.StarTowerAmmoInfo)(mapAmmoInfo.nCurAmmo, mapAmmoInfo.nAmmo1, mapAmmoInfo.nAmmo2, mapAmmoInfo.nAmmo3, mapAmmoInfo.nAmmoMax1, mapAmmoInfo.nAmmoMax2, mapAmmoInfo.nAmmoMax3)
  end
  for _,skill in ipairs(mapData.skillInfo) do
    (stTempData.skillInfo):Add((CS.StarTowerSkill)(skill.nCharId, skill.nSkillId, skill.nCd, skill.nSectionAmount, skill.nSectionResumeTime, skill.nUseTimeHint, skill.nEnergy))
  end
  for _,st in pairs(stCharacter) do
    (stTempData.characterInfo):Add(st)
  end
  local jsonData, length = (NovaAPI.ParseStarTowerDataCompressed)(stTempData)
  return jsonData, length
end

local DecodeTempDataJson = function(sData)
  -- function num : 0_1 , upvalues : _ENV
  local tempData = {}
  tempData.skillInfo = {}
  local stData = (NovaAPI.DecodeStarTowerDataCompressed)(sData)
  local nCount = (stData.skillInfo).Count
  for index = 0, nCount - 1 do
    local stSkill = (stData.skillInfo)[index]
    ;
    (table.insert)(tempData.skillInfo, {nCharId = stSkill.nCharId, nSkillId = stSkill.nSkillId, nCd = stSkill.nCd, nSectionAmount = stSkill.nSectionAmount, nSectionResumeTime = stSkill.nSectionResumeTime, nUseTimeHint = stSkill.nUseTimeHint, nEnergy = stSkill.nEnergy})
  end
  local nCharCount = (stData.characterInfo).Count
  for index = 0, nCharCount - 1 do
    local stChar = (stData.characterInfo)[index]
    local nCharId = stChar.nCharId
    local nEffectCount = (stChar.tbEffect).Count
    if tempData.effectInfo == nil then
      tempData.effectInfo = {}
    end
    -- DECOMPILER ERROR at PC59: Confused about usage of register: R12 in 'UnsetPending'

    if (tempData.effectInfo)[nCharId] == nil then
      (tempData.effectInfo)[nCharId] = {
mapEffect = {}
}
    end
    for e = 0, nEffectCount - 1 do
      local stEffect = (stChar.tbEffect)[e]
      -- DECOMPILER ERROR at PC75: Confused about usage of register: R17 in 'UnsetPending'

      ;
      (((tempData.effectInfo)[nCharId]).mapEffect)[stEffect.nId] = {nCount = stEffect.nCount, nCd = stEffect.nCd}
    end
    local nBuffCount = (stChar.tbBuff).Count
    if tempData.buffInfo == nil then
      tempData.buffInfo = {}
    end
    -- DECOMPILER ERROR at PC90: Confused about usage of register: R13 in 'UnsetPending'

    if (tempData.buffInfo)[nCharId] == nil then
      (tempData.buffInfo)[nCharId] = {}
    end
    for b = 0, nBuffCount - 1 do
      local stBuff = (stChar.tbBuff)[b]
      ;
      (table.insert)((tempData.buffInfo)[nCharId], {Id = stBuff.Id, CD = stBuff.CD, nNum = stBuff.nNum})
    end
    if stChar.stateInfo ~= nil then
      if tempData.stateInfo == nil then
        tempData.stateInfo = {}
      end
      -- DECOMPILER ERROR at PC127: Confused about usage of register: R13 in 'UnsetPending'

      ;
      (tempData.stateInfo)[nCharId] = {jsonStr = "", nState = (stChar.stateInfo).nState, nStateTime = (stChar.stateInfo).nStateTime}
    end
    if stChar.ammoInfo ~= nil then
      if tempData.ammoInfo == nil then
        tempData.ammoInfo = {}
      end
      -- DECOMPILER ERROR at PC159: Confused about usage of register: R13 in 'UnsetPending'

      ;
      (tempData.ammoInfo)[nCharId] = {nCurAmmo = (stChar.ammoInfo).nCurAmmo, nAmmo1 = (stChar.ammoInfo).nAmmo1, nAmmo2 = (stChar.ammoInfo).nAmmo2, nAmmo3 = (stChar.ammoInfo).nAmmo3, nAmmoMax1 = (stChar.ammoInfo).nAmmoMax1, nAmmoMax2 = (stChar.ammoInfo).nAmmoMax2, nAmmoMax3 = (stChar.ammoInfo).nAmmoMax3}
    end
  end
  return tempData
end

StarTowerLevelData.ctor = function(self, parent, nStarTowerId)
  -- function num : 0_2 , upvalues : _ENV
  self:BindEvent()
  local BuildStarTowerAllFloorData = function(nTowerId)
    -- function num : 0_2_0 , upvalues : _ENV
    local mapStarTowerCfgData = (ConfigTable.GetData)("StarTower", nTowerId)
    if mapStarTowerCfgData == nil then
      return {}
    end
    local ret = {}
    local levelDifficulty = mapStarTowerCfgData.Difficulty
    local difficulty = mapStarTowerCfgData.ValueDifficulty
    local tbStage = mapStarTowerCfgData.StageGroupIds
    local tbFloorNum = mapStarTowerCfgData.FloorNum
    for nIdx,nStageGroupId in ipairs(tbStage) do
      local nFloorNum = tbFloorNum[nIdx]
      if nFloorNum == nil then
        nFloorNum = 99
        printError("FloorNum Missing：" .. nTowerId .. " " .. nIdx)
      end
      for nLevel = 1, nFloorNum do
        local nStageLevelId = nStageGroupId * 100 + nLevel
        if (ConfigTable.GetData)("StarTowerStage", nStageLevelId) ~= nil then
          do
            (table.insert)(ret, (ConfigTable.GetData)("StarTowerStage", nStageLevelId))
            -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
    return ret, difficulty, levelDifficulty
  end

  local BuildStarTowerExpData = function(nTowerId)
    -- function num : 0_2_1 , upvalues : _ENV
    local ret = {}
    local forEachExp = function(mapData)
      -- function num : 0_2_1_0 , upvalues : nTowerId, ret
      if mapData.StarTowerId == nTowerId then
        ret[mapData.Stage] = mapData
      end
    end

    ForEachTableLine(DataTable.StarTowerFloorExp, forEachExp)
    return ret
  end

  self.parent = parent
  self.nTowerId = nStarTowerId
  self.nCurLevel = 1
  self.bRanking = false
  self.tbStarTowerAllLevel = BuildStarTowerAllFloorData(self.nTowerId)
  self.mapFloorExp = BuildStarTowerExpData(self.nTowerId)
  self.tbStrengthMachineCost = (ConfigTable.GetConfigNumberArray)("StrengthenMachineGoldConsume")
  ;
  (EventManager.Hit)("SetStarTowerLevelData", R7_PC11)
end

StarTowerLevelData.Exit = function(self)
  -- function num : 0_3 , upvalues : _ENV
  self:UnBindEvent()
  if self.curRoom ~= nil then
    (self.curRoom):Exit()
  end
  ;
  (EventManager.Hit)("SetStarTowerLevelData")
end

StarTowerLevelData.BindEvent = function(self)
  -- function num : 0_4 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Add)(nEventId, self, callback)
    end
  end
end

StarTowerLevelData.UnBindEvent = function(self)
  -- function num : 0_5 , upvalues : _ENV, mapEventConfig
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Remove)(nEventId, self, callback)
    end
  end
end

StarTowerLevelData.Init = function(self, mapMeta, mapRoom, mapBag, lastId)
  -- function num : 0_6 , upvalues : _ENV, DecodeTempDataJson, WwiseAudioMgr
  local GetCharacterAttr = function(tbTeam, mapDisc)
    -- function num : 0_6_0 , upvalues : _ENV, self
    local ret = {}
    for idx,nTid in ipairs(tbTeam) do
      local stActorInfo = self:CalCharFixedEffect(nTid, idx == 1, mapDisc)
      ret[nTid] = stActorInfo
    end
    do return ret end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

  self.mapCharData = self:BuildCharacterData(mapMeta.Chars, mapMeta.Discs)
  self._mapNote = {}
  local mapCfg = (ConfigTable.GetData)("StarTower", mapMeta.Id)
  if mapCfg ~= nil then
    local nDropGroup = mapCfg.SubNoteSkillDropGroupId
    local tbNoteDrop = (CacheTable.GetData)("_SubNoteSkillDropGroup", nDropGroup)
    if tbNoteDrop ~= nil then
      for _,v in ipairs(tbNoteDrop) do
        -- DECOMPILER ERROR at PC30: Confused about usage of register: R14 in 'UnsetPending'

        (self._mapNote)[v.SubNoteSkillId] = 0
      end
    end
  end
  do
    self._mapPotential = {}
    self._mapFateCard = {}
    self._mapItem = {}
    self.nTowerId = mapMeta.Id
    self.nCurLevel = (mapRoom.Data).Floor
    self.tbTeam = {}
    self.mapPotentialAddLevel = {}
    self.nLastStarTowerId = lastId or 0
    self.nLastRoomType = -1
    self.sLastBGM = ""
    for _,mapChar in ipairs(mapMeta.Chars) do
      (table.insert)(self.tbTeam, mapChar.Id)
      -- DECOMPILER ERROR at PC66: Confused about usage of register: R12 in 'UnsetPending'

      ;
      (self._mapPotential)[mapChar.Id] = {}
      local tbActive = ((self.mapCharData)[mapChar.Id]).tbActive
      local tbEquipment = ((self.mapCharData)[mapChar.Id]).tbEquipment
      -- DECOMPILER ERROR at PC81: Confused about usage of register: R14 in 'UnsetPending'

      ;
      (self.mapPotentialAddLevel)[mapChar.Id] = self:GetCharEnhancedPotential(tbActive, tbEquipment)
    end
    self.tbDisc = {}
    for _,mapDisc in ipairs(mapMeta.Discs) do
      (table.insert)(self.tbDisc, mapDisc.Id)
    end
    self.tbActiveSecondaryIds = mapMeta.ActiveSecondaryIds
    self.tbGrowthNodeEffect = (PlayerData.StarTower):GetClientEffectByNode(mapMeta.TowerGrowthNodes)
    self.nResurrectionCnt = mapMeta.ResurrectionCnt or 0
    self.curRoom = nil
    self.mapFateCardUseCount = {}
    self.nTeamLevel = mapMeta.TeamLevel
    self.nTeamExp = mapMeta.TeamExp
    self.nTotalTime = mapMeta.TotalTime
    self.nNPCInteractions = mapMeta.NPCInteractions
    if self.nRankBattleTime == nil then
      self.nRankBattleTime = 0
    end
    self.mapActorInfo = {
[(self.tbTeam)[1]] = {nHp = mapMeta.CharHp}
}
    if (mapRoom.Data).RoomType ~= nil or not -1 then
      self.nRoomType = (mapRoom.Data).RoomType
      self.cachedClientData = mapMeta.ClientData
      self.mapCharacterTempData = DecodeTempDataJson(mapMeta.ClientData)
      self.mapEffectTriggerCount = {}
      if (self.mapCharacterTempData).effectInfo ~= nil then
        for _,mapData in pairs((self.mapCharacterTempData).effectInfo) do
          if mapData.mapEffect ~= nil then
            for nEftId,value in pairs(mapData.mapEffect) do
              -- DECOMPILER ERROR at PC169: Confused about usage of register: R17 in 'UnsetPending'

              (self.mapEffectTriggerCount)[nEftId] = value.nCount
            end
          end
        end
      end
      do
        self.mapCharAttr = GetCharacterAttr(self.tbTeam, self.mapDiscData)
        self.cachedRoomMeta = mapRoom
        if mapBag ~= nil then
          for _,mapFateCardEft in ipairs(mapBag.FateCard) do
            -- DECOMPILER ERROR at PC192: Confused about usage of register: R12 in 'UnsetPending'

            (self._mapFateCard)[mapFateCardEft.Tid] = {mapFateCardEft.Remain, mapFateCardEft.Room}
          end
          for _,mapPotential in ipairs(mapBag.Potentials) do
            local nTid = mapPotential.Tid
            local mapPotentialCfgData = (ConfigTable.GetData)("Potential", nTid)
            if mapPotentialCfgData == nil then
              printError("PotentialCfgData Missing" .. nTid)
            else
              local nCharId = mapPotentialCfgData.CharId
              -- DECOMPILER ERROR at PC220: Confused about usage of register: R15 in 'UnsetPending'

              if (self._mapPotential)[nCharId] == nil then
                (self._mapPotential)[nCharId] = {}
              end
              -- DECOMPILER ERROR at PC224: Confused about usage of register: R15 in 'UnsetPending'

              ;
              ((self._mapPotential)[nCharId])[nTid] = mapPotential.Level
            end
          end
          for _,mapItem in ipairs(mapBag.Items) do
            local mapItemCfgData = (ConfigTable.GetData_Item)(mapItem.Tid)
            -- DECOMPILER ERROR at PC246: Confused about usage of register: R13 in 'UnsetPending'

            if mapItemCfgData ~= nil and mapItemCfgData.Stype == (GameEnum.itemStype).SubNoteSkill then
              (self._mapNote)[mapItem.Tid] = mapItem.Qty
            else
              -- DECOMPILER ERROR at PC251: Confused about usage of register: R13 in 'UnsetPending'

              ;
              (self._mapItem)[mapItem.Tid] = mapItem.Qty
            end
          end
          for _,mapItem in ipairs(mapBag.Res) do
            -- DECOMPILER ERROR at PC261: Confused about usage of register: R12 in 'UnsetPending'

            (self._mapItem)[mapItem.Tid] = mapItem.Qty
          end
        end
        do
          self:SetRoguelikeHistoryMapId()
          if #self.tbStarTowerAllLevel == 0 then
            printError("StarTower Config Data Missing:" .. self.nTowerId)
          end
          self.curMapId = (mapRoom.Data).MapId
          self:SetRoguelikeHistoryMapId(self.curMapId)
          local bBattleEnd = (self.CheckBattleEnd)(mapRoom.Cases)
          local nRoomType = self.nRoomType
          local tbDropInfo = self:GetDropInfo(self.nCurLevel, nRoomType, mapRoom.Cases)
          local nNextRoomType = 0
          local bFinal = false
          if self.nCurLevel + 1 <= #self.tbStarTowerAllLevel then
            local mapNextStage = (self.tbStarTowerAllLevel)[self.nCurLevel + 1]
            nNextRoomType = mapNextStage.RoomType
          else
            do
              bFinal = true
              local callback = function()
    -- function num : 0_6_1 , upvalues : _ENV, self, bBattleEnd, bFinal, tbDropInfo, nNextRoomType, mapRoom
    (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerPanel, self.tbTeam, self.tbDisc, self.mapCharData, self.mapDiscData, self.mapPotentialAddLevel, self.nTowerId, self.nLastStarTowerId)
    safe_call_cs_func((CS.AdventureModuleHelper).EnterStarTowerMap, self.nStarTowerDifficulty, bBattleEnd, bFinal, tbDropInfo, nNextRoomType)
    local roomClass = self:GetcurRoom()
    self.curRoom = (roomClass.new)(self, mapRoom.Cases, mapRoom.Data)
  end

              ;
              (NovaAPI.EnterModule)("AdventureModuleScene", true, 22, callback)
              WwiseAudioMgr:PostEvent("rouguelike_outfit_setVV")
            end
          end
        end
      end
    end
  end
end

StarTowerLevelData.StarTowerClear = function(self, nCaseId)
  -- function num : 0_7 , upvalues : _ENV, WwiseAudioMgr
  local PlaySuccessPerform = function(nMapId, mapResult, tbTeam, tbDisc)
    -- function num : 0_7_0 , upvalues : _ENV, self, WwiseAudioMgr
    local sBGM = ""
    local levelEndCallback = function()
      -- function num : 0_7_0_0 , upvalues : _ENV, self, levelEndCallback, nMapId, WwiseAudioMgr, tbTeam, sBGM
      (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
      if (ConfigTable.GetData)("StarTowerMap", nMapId) == nil then
        printError("MapDataMissing:" .. nMapId)
      end
      local nType = ((ConfigTable.GetData)("StarTowerMap", nMapId)).Theme
      local sName = ((ConfigTable.GetData)("EndSceneType", nType)).EndSceneName
      local func_SettlementFinish = function()
        -- function num : 0_7_0_0_0
      end

      WwiseAudioMgr:PostEvent("music_clear")
      WwiseAudioMgr:PostEvent("music_combat")
      local tbSkin = {}
      for _,nCharId in ipairs(tbTeam) do
        local nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
        ;
        (table.insert)(tbSkin, nSkinId)
      end
      ;
      ((CS.AdventureModuleHelper).PlaySettlementPerform)(sName, sBGM, tbSkin, func_SettlementFinish)
    end

    ;
    (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    local openBattleResultPanel = function()
      -- function num : 0_7_0_1 , upvalues : _ENV, self, openBattleResultPanel, mapResult, tbTeam
      (EventManager.Remove)("SettlementPerformLoadFinish", self, openBattleResultPanel)
      ;
      (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerResult, mapResult, tbTeam)
      ;
      (PlayerData.State):CacheStarTowerStateData(nil)
      ;
      (self.parent):StarTowerEnd()
    end

    ;
    (EventManager.Add)("SettlementPerformLoadFinish", self, openBattleResultPanel)
    ;
    ((CS.AdventureModuleHelper).LevelStateChanged)(true)
    ;
    (PlayerData.StarTower):CacheOnePassedId(mapResult.nRoguelikeId)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.BattleResultMask)
  end

  local nCheckSum = 0
  local bSuccess = nil
  local EnterReq = {MapId = 0, Checksum = nCheckSum}
  local mapMsg = {Id = nCaseId, EnterReq = EnterReq}
  local NetCallback = function(_, mapNetMsg)
    -- function num : 0_7_1 , upvalues : _ENV, self, PlaySuccessPerform
    local mapBuildInfo = nil
    local mapChangeInfo = {}
    local tbRes = {}
    local tbItem = {}
    local nTime = 0
    local mapNpcAffinity = nil
    local tbTowerRewards = {}
    if mapNetMsg.Settle ~= nil then
      mapBuildInfo = (mapNetMsg.Settle).Build
      mapChangeInfo = (mapNetMsg.Settle).Change
      nTime = (mapNetMsg.Settle).TotalTime
      mapNpcAffinity = (mapNetMsg.Settle).Reward
      local mapItems = {}
      for _,mapFirstReward in ipairs((mapNetMsg.Settle).Awards) do
        for _,mapRewardItem in ipairs(mapFirstReward.Items) do
          if mapItems[mapRewardItem.Tid] == nil then
            mapItems[mapRewardItem.Tid] = 0
          end
          mapItems[mapRewardItem.Tid] = mapItems[mapRewardItem.Tid] + mapRewardItem.Qty
        end
      end
      for nTid,nQty in pairs(mapItems) do
        (table.insert)(tbTowerRewards, {Tid = nTid, Qty = nQty, rewardType = (AllEnum.RewardType).First})
      end
      for _,mapItem in ipairs((mapNetMsg.Settle).TowerRewards) do
        (table.insert)(tbTowerRewards, {Tid = mapItem.Tid, Qty = mapItem.Qty})
      end
      ;
      (self.parent):CacheNpcAffinityChange((mapNetMsg.Settle).Reward, (mapNetMsg.Settle).NpcInteraction)
    end
    do
      if mapChangeInfo ~= nil then
        local encodeInfo = (UTILS.DecodeChangeInfo)(mapChangeInfo)
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
              if mapItemConfigData == nil then
                return 
              end
              if mapItemConfigData.Stype ~= (GameEnum.itemStype).Res then
                (table.insert)(tbItem, {nTid = mapItem.Tid, nCount = mapItem.Qty})
              end
            end
          end
          do
            local nPotentialCount = 0
            for _,mapPotential in pairs(self._mapPotential) do
              for _,nCount in pairs(mapPotential) do
                nPotentialCount = nPotentialCount + nCount
              end
            end
            local mapResult = {nRoguelikeId = self.nTowerId, tbDisc = self.tbDisc, tbRes = tbRes, 
tbPresents = {}
, 
tbOutfit = {}
, tbItem = tbItem, 
tbRarityCount = {}
, bSuccess = true, nFloor = self.nCurLevel, nStage = ((self.tbStarTowerAllLevel)[self.nCurLevel]).Id, mapBuild = mapBuildInfo, nExp = 0, nPerkCount = nPotentialCount, 
tbBonus = {}
, nTime = nTime, 
tbAffinities = {}
, mapChangeInfo = mapChangeInfo, tbRewards = tbTowerRewards, mapNPCAffinity = mapNpcAffinity}
            PlaySuccessPerform(self.curMapId, mapResult, self.tbTeam, self.tbDisc)
            local tabUpLevel = {}
            ;
            (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
            ;
            (table.insert)(tabUpLevel, {"game_cost_time", tostring(nTime)})
            ;
            (table.insert)(tabUpLevel, {"real_cost_time", tostring(0)})
            if mapBuildInfo and mapBuildInfo.Brief ~= nil then
              (table.insert)(tabUpLevel, {"build_id", tostring((mapBuildInfo.Brief).Id)})
            else
              ;
              (table.insert)(tabUpLevel, {"build_id", tostring(0)})
            end
            ;
            (table.insert)(tabUpLevel, {"tower_id", tostring(self.nTowerId)})
            ;
            (table.insert)(tabUpLevel, {"room_floor", tostring(self.nCurLevel)})
            ;
            (table.insert)(tabUpLevel, {"room_type", tostring(self.nRoomType)})
            ;
            (table.insert)(tabUpLevel, {"action", tostring(10)})
            ;
            (NovaAPI.UserEventUpload)("star_tower", tabUpLevel)
            local mapStarTower = (ConfigTable.GetData)("StarTower", self.nTowerId)
            if mapStarTower and mapStarTower.GroupId ~= 4 then
              local tmpEventId = (string.format)("pc_star_tower_%s_%s", mapStarTower.GroupId, mapStarTower.Difficulty)
              ;
              (PlayerData.Base):UserEventUpload_PC(tmpEventId)
            end
          end
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_interact_req, mapMsg, nil, NetCallback)
end

StarTowerLevelData.EnterRoom = function(self, nCaseId, nRoomType)
  -- function num : 0_8 , upvalues : _ENV, Actor2DManager
  if self.bEnd then
    return 
  end
  if self.curRoom ~= nil then
    (self.curRoom):Exit()
    self.curRoom = nil
  end
  if #self.tbStarTowerAllLevel < self.nCurLevel + 1 then
    self:StarTowerClear(nCaseId)
    return 
  end
  local tbHistoryMapId = self:GetRoguelikeHistoryMapId()
  local tbCharSkinId = {}
  for _,nCharId in ipairs(self.tbTeam) do
    (table.insert)(tbCharSkinId, (PlayerData.Char):GetCharSkinId(nCharId))
  end
  local stRoomMeta = nil
  if nRoomType == (GameEnum.starTowerRoomType).DangerRoom or nRoomType == (GameEnum.starTowerRoomType).HorrorRoom then
    print((string.format)("Enter HighDangerRoom RoomType:%d", nRoomType))
    local nStage = ((self.tbStarTowerAllLevel)[self.nCurLevel]).Id
    stRoomMeta = (CS.Lua2CSharpInfo_FixedRoguelike)(self.nTowerId, nStage, tbHistoryMapId, self.tbTeam, tbCharSkinId, 0, "", 0, nRoomType, self.bRanking, 0)
  else
    do
      self.nCurLevel = self.nCurLevel + 1
      do
        local nNextStage = ((self.tbStarTowerAllLevel)[self.nCurLevel]).Id
        stRoomMeta = (CS.Lua2CSharpInfo_FixedRoguelike)(self.nTowerId, nNextStage, tbHistoryMapId, self.tbTeam, tbCharSkinId, 0, "", 0, -1, self.bRanking, 0)
        local floorId = 0
        local sExData = ""
        local scenePrefabId = 0
        self.nRoomType = nRoomType
        self.curMapId = safe_call_cs_func2((CS.AdventureModuleHelper).RandomStarTowerMap, stRoomMeta)
        if self.curMapId == nil then
          printError("返回地图id为空！")
        end
        self:SetRoguelikeHistoryMapId(self.curMapId)
        local OnLevelUnloadComplete = function()
    -- function num : 0_8_0 , upvalues : _ENV, self, OnLevelUnloadComplete, Actor2DManager
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, OnLevelUnloadComplete)
    ;
    (Actor2DManager.ClearAll)()
    self:ResetCharacter()
  end

        local NetCallback = function(_, mapNetData)
    -- function num : 0_8_1 , upvalues : _ENV, self, nRoomType, OnLevelUnloadComplete
    if mapNetData.EnterResp == nil then
      printError("房间数据返回为空")
      return 
    end
    self.cachedRoomMeta = (mapNetData.EnterResp).Room
    self:ProcessChangeInfo(mapNetData.Change)
    local bBattleEnd = (self.CheckBattleEnd)(((mapNetData.EnterResp).Room).Cases)
    local mapMapData = (ConfigTable.GetData)("StarTowerMap", self.curMapId)
    if mapMapData == nil then
      return 
    end
    local tbDropInfo = self:GetDropInfo(self.nCurLevel, nRoomType, ((mapNetData.EnterResp).Room).Cases)
    local nNextRoomType = 0
    local bFinal = false
    if self.nCurLevel + 1 <= #self.tbStarTowerAllLevel then
      local mapNextStage = (self.tbStarTowerAllLevel)[self.nCurLevel + 1]
      nNextRoomType = mapNextStage.RoomType
    else
      do
        bFinal = true
        safe_call_cs_func((CS.AdventureModuleHelper).EnterStarTowerMap, self.nStarTowerDifficulty, bBattleEnd, bFinal, tbDropInfo, nNextRoomType)
        local roomClass = self:GetcurRoom()
        self.curRoom = (roomClass.new)(self, ((mapNetData.EnterResp).Room).Cases, ((mapNetData.EnterResp).Room).Data)
        ;
        (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, OnLevelUnloadComplete)
        safe_call_cs_func((CS.AdventureModuleHelper).ClearCharacterDamageRecord, false)
        safe_call_cs_func((CS.AdventureModuleHelper).LevelStateChanged, false)
      end
    end
  end

        local clientData, nDataLength = self:CacheTempData()
        self.cachedClientData = clientData
        local EnterReq = {MapId = self.curMapId, ParamId = floorId, DateLen = nDataLength, ClientData = clientData, MapParam = sExData, MapTableId = scenePrefabId}
        local mapMsg = {Id = nCaseId, EnterReq = EnterReq}
        ;
        (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_interact_req, mapMsg, nil, NetCallback)
      end
    end
  end
end

StarTowerLevelData.StarTowerInteract = function(self, mapMsgData, callback)
  -- function num : 0_9 , upvalues : _ENV
  if self.bEnd then
    return 
  end
  local NetCallback = function(_, mapNetData)
    -- function num : 0_9_0 , upvalues : self, _ENV, mapMsgData, callback
    local mapChangeNote, mapChangeSecondarySkill = self:ProcessTowerChangeData(mapNetData.Data)
    local tbChangeFateCard, mapItemChange, mapPotentialChange = self:ProcessChangeInfo(mapNetData.Change)
    local nExpChange = 0
    local nLevelChange = 0
    local nBagCount = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency]
    if nBagCount == nil then
      nBagCount = 0
    end
    local bSyncHp = false
    if #tbChangeFateCard > 0 then
      bSyncHp = true
    end
    for _,v in pairs(mapChangeNote) do
      if v.Qty > 0 then
        bSyncHp = true
        break
      end
    end
    do
      if next(mapPotentialChange) ~= nil then
        bSyncHp = true
      end
      ;
      (EventManager.Hit)("RefreshStarTowerCoin", nBagCount)
      ;
      (EventManager.Hit)("RefreshNoteCount", clone(self._mapNote), mapChangeNote, mapChangeSecondarySkill)
      ;
      (EventManager.Hit)("RefreshFateCard", clone(self._mapFateCard))
      if mapNetData.BattleEndResp ~= nil and (mapNetData.BattleEndResp).Victory ~= nil then
        nLevelChange = ((mapNetData.BattleEndResp).Victory).Lv - self.nTeamLevel
        nExpChange = ((mapNetData.BattleEndResp).Victory).Exp
        self.nTeamLevel = ((mapNetData.BattleEndResp).Victory).Lv
        self.nTeamExp = ((mapNetData.BattleEndResp).Victory).Exp
        self.nRankBattleTime = self.nRankBattleTime + ((mapNetData.BattleEndResp).Victory).BattleTime
      end
      if self.curRoom ~= nil then
        (self.curRoom):SaveCase(mapNetData.Cases)
        ;
        (self.curRoom):SaveSelectResp(mapNetData.SelectResp, mapMsgData.Id)
        if bSyncHp then
          (self.curRoom):SyncHp()
        end
      end
      if callback ~= nil and type(callback) == "function" then
        callback(mapNetData, tbChangeFateCard, mapChangeNote, mapItemChange, nLevelChange, nExpChange, mapPotentialChange, mapChangeSecondarySkill)
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_interact_req, mapMsgData, nil, NetCallback)
end

StarTowerLevelData.StarTowerFailed = function(self, mapChangeInfo, mapBuildInfo, nTime, npcAffinityReward, TowerRewards, NpcInteraction)
  -- function num : 0_10 , upvalues : _ENV, ModuleManager, WwiseAudioMgr
  print("放弃遗迹")
  local tbRes = {}
  local tbPresents = {}
  local tbOutfit = {}
  local tbItem = {}
  if self.curRoom ~= nil then
    nTime = nTime + (self.curRoom).nTime
  end
  if mapChangeInfo ~= nil then
    local encodeInfo = (UTILS.DecodeChangeInfo)(mapChangeInfo)
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
          if mapItemConfigData == nil then
            return 
          end
          if mapItemConfigData.Stype ~= (GameEnum.itemStype).Res then
            (table.insert)(tbItem, {nTid = mapItem.Tid, nCount = mapItem.Qty})
          end
        end
      end
      do
        local nPotentialCount = 0
        for _,mapPotential in pairs(self._mapPotential) do
          for _,nCount in pairs(mapPotential) do
            nPotentialCount = nPotentialCount + nCount
          end
        end
        ;
        (self.parent):CacheNpcAffinityChange(npcAffinityReward, NpcInteraction)
        local mapResult = {nRoguelikeId = self.nTowerId, tbDisc = self.tbDisc, tbRes = tbRes, tbPresents = tbPresents, tbOutfit = tbOutfit, tbItem = tbItem, 
tbRarityCount = {}
, bSuccess = false, nFloor = self.nCurLevel, nStage = ((self.tbStarTowerAllLevel)[self.nCurLevel]).Id, mapBuild = mapBuildInfo, nExp = 0, nPerkCount = nPotentialCount, 
tbBonus = {}
, nTime = nTime, 
tbAffinities = {}
, mapChangeInfo = mapChangeInfo, tbRewards = TowerRewards, mapNPCAffinity = npcAffinityReward}
        if (ModuleManager.GetIsAdventure)() then
          WwiseAudioMgr:PostEvent("music_clear")
          WwiseAudioMgr:PostEvent("music_combat")
        end
        local tabUpLevel = {}
        ;
        (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
        ;
        (table.insert)(tabUpLevel, {"game_cost_time", tostring(nTime)})
        ;
        (table.insert)(tabUpLevel, {"real_cost_time", tostring(((CS.ClientManager).Instance).serverTimeStampWithTimeZone - (self.curRoom)._EntryTime)})
        ;
        (table.insert)(tabUpLevel, {"tower_id", tostring(self.nTowerId)})
        ;
        (table.insert)(tabUpLevel, {"room_floor", tostring(self.nCurLevel)})
        ;
        (table.insert)(tabUpLevel, {"room_type", tostring(self.nRoomType)})
        ;
        (table.insert)(tabUpLevel, {"action", tostring(3)})
        ;
        (NovaAPI.UserEventUpload)("star_tower", tabUpLevel)
        ;
        (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerResult, mapResult, self.tbTeam)
        ;
        (PlayerData.State):CacheStarTowerStateData(nil)
        ;
        (self.parent):StarTowerEnd()
      end
    end
  end
end

StarTowerLevelData.ResetCharacter = function(self)
  -- function num : 0_11 , upvalues : _ENV
  for nCharId,mapInfo in pairs(self.mapCharAttr) do
    if self.mapActorInfo ~= nil and (self.mapActorInfo)[nCharId] ~= nil then
      mapInfo.initHp = ((self.mapActorInfo)[nCharId]).nHp
    end
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, mapInfo)
  end
  self:SetCharStatus()
  self:ResetAmmo()
  self:ResetSommon()
  self:ResetPersonalPerk()
  self:ResetFateCard()
  self:ResetNoteInfo()
  self:ResetDiscInfo()
end

StarTowerLevelData.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_12 , upvalues : _ENV
  for nCharId,mapInfo in pairs(self.mapCharAttr) do
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, mapInfo)
  end
  self:SetCharStatus()
  self:ResetAmmo()
  self:ResetSommon()
  self:ResetPersonalPerk()
  self:ResetFateCard()
  self:ResetNoteInfo()
  self:ResetDiscInfo()
end

StarTowerLevelData.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_13 , upvalues : _ENV
  self.mapFateCardUseCount = {}
  self.mapPotentialEft = {}
  self.mapDiscEft = {}
  self.mapNoteEft = {}
  self.mapFateCardEft = {}
  self.mapPotentialEft = self:ResetEffect()
  if self.curRoom ~= nil then
    self:PlayRoomBGM()
    ;
    (self.curRoom):Enter()
  end
  -- DECOMPILER ERROR at PC33: Overwrote pending register: R3 in 'AssignReg'

  -- DECOMPILER ERROR at PC35: Overwrote pending register: R4 in 'AssignReg'

  if (self.mapCharacterTempData).shieldList ~= nil then
    safe_call_cs_func((CS.AdventureModuleHelper).ResetShield, R3_PC13, R4_PC12)
  end
  self:ResetBuff()
  self:SetFateCardToAdventureModule()
  self:SetActorHP()
  self:ResetSkill()
  self:ResetFateCardRoomEft()
end

StarTowerLevelData.OnEvent_TakeEffect = function(self, nCharId, EffectId)
  -- function num : 0_14 , upvalues : _ENV
  if self.mapEffectTriggerCount == nil then
    self.mapEffectTriggerCount = {}
  end
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R3 in 'UnsetPending'

  if (self.mapEffectTriggerCount)[EffectId] == nil then
    (self.mapEffectTriggerCount)[EffectId] = 0
  end
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.mapEffectTriggerCount)[EffectId] = (self.mapEffectTriggerCount)[EffectId] + 1
  if (self.mapFateCardEft)[EffectId] ~= nil then
    local nFateCardId = ((self.mapFateCardEft)[EffectId]).nFateCardId
    -- DECOMPILER ERROR at PC28: Confused about usage of register: R4 in 'UnsetPending'

    if (self.mapFateCardUseCount)[nFateCardId] == nil then
      (self.mapFateCardUseCount)[nFateCardId] = 0
    end
    ;
    (EventManager.Hit)("FateCardCountChange", nFateCardId)
    -- DECOMPILER ERROR at PC38: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self.mapFateCardUseCount)[nFateCardId] = (self.mapFateCardUseCount)[nFateCardId] + 1
  end
end

StarTowerLevelData.OnEvent_OpenStarTowerMap = function(self)
  -- function num : 0_15 , upvalues : _ENV
  (NovaAPI.DispatchEventWithData)("LUA2CSHARP_UI_PAUSE")
  local bHighDanger = false
  bHighDanger = self.nRoomType == (GameEnum.starTowerRoomType).DangerRoom or self.nRoomType == (GameEnum.starTowerRoomType).HorrorRoom
  ;
  (EventManager.Hit)("OpenStarTowerMap", self.tbStarTowerAllLevel, self.nCurLevel, self.nTowerId, self.tbTeam, bHighDanger, nil, self.mapCharData, #self.tbStarTowerAllLevel)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

StarTowerLevelData.OnEvent_OpenStarTowerDepot = function(self, nTog, nParam)
  -- function num : 0_16 , upvalues : _ENV
  (EventManager.Hit)("OpenStarTowerDepot", self._mapPotential, self._mapNote, self._mapFateCard, self._mapItem, self.tbActiveSecondaryIds, nTog, nParam)
end

StarTowerLevelData.OnEvent_AbandonStarTower = function(self)
  -- function num : 0_17 , upvalues : _ENV
  if self.bEnd then
    return 
  end
  self.bEnd = true
  local callback = function(_, msgData)
    -- function num : 0_17_0 , upvalues : self
    self:StarTowerFailed(msgData.Change, msgData.Build, msgData.TotalTime, msgData.Reward, msgData.TowerRewards, msgData.NpcInteraction)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_give_up_req, {}, nil, callback)
end

StarTowerLevelData.OnEvent_StarTowerLeave = function(self)
  -- function num : 0_18 , upvalues : Actor2DManager, _ENV
  (Actor2DManager.ClearAll)()
  if self.bEnd then
    return 
  end
  ;
  (PanelManager.InputDisable)()
  local confirmCallback = function()
    -- function num : 0_18_0 , upvalues : _ENV, self
    local levelEndCallback = function()
      -- function num : 0_18_0_0 , upvalues : _ENV, self, levelEndCallback
      (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
      ;
      (NovaAPI.EnterModule)("MainMenuModuleScene", true, 17)
      ;
      (EventManager.Hit)(EventId.ClosePanel, PanelId.StarTowerPanel)
    end

    self.bEnd = true
    ;
    (self.parent):StarTowerEnd()
    local nRecon = (PlayerData.State):GetStarTowerRecon()
    local mapStateInfo = {Id = self.nTowerId, ReConnection = nRecon, BuildId = 0, CharIds = self.tbTeam, Floor = self.nCurLevel}
    ;
    (PlayerData.State):CacheStarTowerStateData(mapStateInfo)
    -- DECOMPILER ERROR at PC24: Confused about usage of register: R3 in 'UnsetPending'

    PlayerData.back2Home = true
    ;
    (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    ;
    ((CS.AdventureModuleHelper).LevelStateChanged)(true, 0, true)
    ;
    (PanelManager.InputEnable)()
    local tabUpLevel = {}
    ;
    (table.insert)(tabUpLevel, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (table.insert)(tabUpLevel, {"game_cost_time", tostring((self.curRoom).nTime)})
    ;
    (table.insert)(tabUpLevel, {"real_cost_time", tostring(((CS.ClientManager).Instance).serverTimeStampWithTimeZone - (self.curRoom)._EntryTime)})
    ;
    (table.insert)(tabUpLevel, {"tower_id", tostring(self.nTowerId)})
    ;
    (table.insert)(tabUpLevel, {"room_floor", tostring(self.nCurLevel)})
    ;
    (table.insert)(tabUpLevel, {"room_type", tostring(self.nRoomType)})
    ;
    (table.insert)(tabUpLevel, {"action", tostring(18)})
    ;
    (NovaAPI.UserEventUpload)("star_tower", tabUpLevel)
  end

  local cancelCallback = function()
    -- function num : 0_18_1 , upvalues : _ENV
    (PanelManager.InputEnable)()
  end

  local confirmGray = function()
    -- function num : 0_18_2 , upvalues : _ENV
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("StarTower_CantLeaveHint") or "")
  end

  local nMaxCount = (ConfigTable.GetConfigNumber)("StarTowerReconnMaxCnt")
  local nReConnection = (PlayerData.State):GetStarTowerRecon()
  local bGrayConfirm = nMaxCount <= nReConnection
  local sHint = orderedFormat((ConfigTable.GetUIText)("StarTower_Leave_Hint") or "", nMaxCount - nReConnection, nMaxCount)
  local msg = {nType = (AllEnum.MessageBox).Confirm, sContent = sHint, callbackConfirm = bGrayConfirm and confirmGray or confirmCallback, callbackCancel = cancelCallback, bDisableSnap = false, bGrayConfirm = bGrayConfirm}
  ;
  (EventManager.Hit)(EventId.OpenMessageBox, msg)
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

StarTowerLevelData.BuildCharacterData = function(self, tbCharacterData, tbDiscData)
  -- function num : 0_19 , upvalues : _ENV
  local EquipmentData = require("GameCore.Data.DataClass.EquipmentDataEx")
  local DiscData = require("GameCore.Data.DataClass.DiscData")
  local mapCharacter = {}
  local mapDisc = {}
  for idx,mapChar in ipairs(tbCharacterData) do
    do
      local tbEquipment, tbEquipmentSlot, tbEquipmentEffect = {}, {}, {}
      for _,starTowerEquipment in ipairs(mapChar.Gems) do
        if starTowerEquipment.Attributes then
          local bEmpty = false
          for _,v in pairs(starTowerEquipment.Attributes) do
            if v == 0 then
              bEmpty = true
              break
            end
          end
          do
            if not bEmpty then
              local nGemId = (PlayerData.Equipment):GetGemIdBySlot(mapChar.Id, starTowerEquipment.SlotId)
              local mapEquipmentInfo = {Lock = false, Attributes = starTowerEquipment.Attributes, 
AlterAttributes = {}
}
              local equipmentData = (EquipmentData.new)(mapEquipmentInfo, mapChar.Id, nGemId)
              ;
              (table.insert)(tbEquipment, equipmentData)
              tbEquipmentSlot[starTowerEquipment.SlotId] = equipmentData
            end
            do
              -- DECOMPILER ERROR at PC59: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC59: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC59: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
      for _,mapEquipment in pairs(tbEquipment) do
        local tbEffect = mapEquipment:GetEffect()
        for _,v in pairs(tbEffect) do
          (table.insert)(tbEquipmentEffect, v)
        end
      end
      local tbTalent = (CacheTable.GetData)("_TalentByIndex", mapChar.Id)
      if tbTalent == nil then
        printError("Talent表找不到该角色" .. mapChar.Id)
        tbTalent = {}
      end
      local tbActive = {}
      local tbNodes = (UTILS.ParseByteString)(mapChar.TalentNodes)
      for nIndex,v in pairs(tbTalent) do
        local bActive = (UTILS.IsBitSet)(tbNodes, nIndex)
        if bActive then
          (table.insert)(tbActive, v.Id)
        end
      end
      local GetCharSkillAddedLevel = function(nCharId, tbSkillLv, active, bMainChar)
    -- function num : 0_19_0 , upvalues : _ENV, tbEquipment
    local tbSkillLevel = {}
    local tbSkillIds = {}
    local charCfgData = (DataTable.Character)[nCharId]
    tbSkillIds[1] = charCfgData.NormalAtkId
    tbSkillIds[2] = charCfgData.SkillId
    tbSkillIds[3] = charCfgData.AssistSkillId
    tbSkillIds[4] = charCfgData.UltimateId
    local mapTalentEnhanceSkill = (PlayerData.Talent):CreateEnhancedSkill(nCharId, active)
    local mapEquipmentEnhanceSkill = {}
    for _,v in pairs(tbEquipment) do
      local tbSkill = v:GetEnhancedSkill()
      for nSkillId,nAdd in pairs(tbSkill) do
        if not mapEquipmentEnhanceSkill[nSkillId] then
          mapEquipmentEnhanceSkill[nSkillId] = 0
        end
        mapEquipmentEnhanceSkill[nSkillId] = mapEquipmentEnhanceSkill[nSkillId] + nAdd
      end
    end
    for i = 1, 4 do
      local nSkillId = tbSkillIds[i]
      local nAdd = 0
      if mapTalentEnhanceSkill and mapTalentEnhanceSkill[nSkillId] then
        nAdd = nAdd + mapTalentEnhanceSkill[nSkillId]
      end
      if mapEquipmentEnhanceSkill and mapEquipmentEnhanceSkill[nSkillId] then
        nAdd = nAdd + mapEquipmentEnhanceSkill[nSkillId]
      end
      local nLv = tbSkillLv[i] + (nAdd)
      ;
      (table.insert)(tbSkillLevel, nLv)
    end
    if bMainChar == true then
      (table.remove)(tbSkillLevel, 3)
    else
      ;
      (table.remove)(tbSkillLevel, 2)
    end
    return tbSkillLevel
  end

      local tbTalentEffect = {}
      for _,nTalentId in pairs(tbActive) do
        local mapCfg = (ConfigTable.GetData)("Talent", nTalentId)
        if mapCfg ~= nil then
          for _,nEffectId in pairs(mapCfg.EffectId) do
            (table.insert)(tbTalentEffect, nEffectId)
          end
        end
      end
      local effectIds = {}
      local mapAffinityCfg = (ConfigTable.GetData)("CharAffinityTemplate", mapChar.Id)
      if not mapAffinityCfg then
        return effectIds
      end
      local templateId = mapAffinityCfg.TemplateId
      local forEachAffinityLevel = function(affinityData)
    -- function num : 0_19_1 , upvalues : templateId, mapChar, _ENV, effectIds
    if affinityData.TemplateId == templateId and mapChar.AffinityLevel ~= nil and affinityData.AffinityLevel == mapChar.AffinityLevel and affinityData.Effect ~= nil and #affinityData.Effect > 0 then
      for k,v in ipairs(affinityData.Effect) do
        (table.insert)(effectIds, v)
      end
    end
  end

      ForEachTableLine(DataTable.AffinityLevel, forEachAffinityLevel)
      local tbAffinityeffectIds = effectIds
      local charData = {nId = mapChar.Id, nRankExp = 0, nFavor = 0, nSkinId = (PlayerData.Char):GetCharUsedSkinId(mapChar.Id), tbEquipment = tbEquipment, tbEquipmentSlot = tbEquipmentSlot, nLevel = mapChar.Level, nCreateTime = 0, nAdvance = mapChar.Advance, tbSkillLvs = GetCharSkillAddedLevel(mapChar.Id, mapChar.SkillLvs, tbActive, idx == 1), bUseSkillWhenActive_Branch1 = false, bUseSkillWhenActive_Branch2 = false, 
tbPlot = {}
, nAffinityExp = 0, nAffinityLevel = mapChar.AffinityLevel, 
tbAffinityQuests = {}
, tbActive = tbActive, tbAffinityeffectIds = tbAffinityeffectIds, tbTalentEffect = tbTalentEffect, tbEquipmentEffect = tbEquipmentEffect}
      mapCharacter[mapChar.Id] = charData
    end
  end
  for _,startowerDisc in ipairs(tbDiscData) do
    local l_0_19_68, l_0_19_69, l_0_19_70, _, startowerDisc = nil
    -- DECOMPILER ERROR at PC211: Confused about usage of register: R11 in 'UnsetPending'

    tbEquipment = mapChar.Id
    -- DECOMPILER ERROR at PC215: Confused about usage of register: R11 in 'UnsetPending'

    if tbEquipment ~= 0 then
      tbEquipmentSlot = mapChar.Id
      -- DECOMPILER ERROR at PC217: Confused about usage of register: R11 in 'UnsetPending'

      tbEquipmentSlot = mapChar.Level
      -- DECOMPILER ERROR at PC220: Confused about usage of register: R11 in 'UnsetPending'

      tbEquipmentSlot = mapChar.Phase
      -- DECOMPILER ERROR at PC222: Confused about usage of register: R11 in 'UnsetPending'

      tbEquipmentSlot = mapChar.Star
      local mapDiscInfo = nil
      tbEquipmentSlot = DiscData.new
      tbEquipmentEffect, tbEquipment = tbEquipment, {Id = tbEquipmentSlot, Level = tbEquipmentSlot, Exp = 0, Phase = tbEquipmentSlot, Star = tbEquipmentSlot, Read = false, CreatTime = 0}
      tbEquipmentSlot = tbEquipmentSlot(tbEquipmentEffect)
      local discData = nil
      -- DECOMPILER ERROR at PC229: Confused about usage of register: R11 in 'UnsetPending'

      tbEquipmentEffect = mapChar.Id
      mapDisc[tbEquipmentEffect] = tbEquipmentSlot
    end
  end
  do return mapCharacter, mapDisc end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

StarTowerLevelData.GetCharEnhancedPotential = function(self, tbActiveTalent, tbEquipment)
  -- function num : 0_20 , upvalues : _ENV
  local mapAddLevel = {}
  local add = function(mapAdd)
    -- function num : 0_20_0 , upvalues : _ENV, mapAddLevel
    if not mapAdd then
      return 
    end
    for nPotentialId,nAdd in pairs(mapAdd) do
      if not mapAddLevel[nPotentialId] then
        mapAddLevel[nPotentialId] = 0
      end
      mapAddLevel[nPotentialId] = mapAddLevel[nPotentialId] + nAdd
    end
  end

  local mapTalentAddLevel = (PlayerData.Talent):CreateEnhancedPotential(tbActiveTalent)
  local mapEquipmentAddLevel = {}
  for _,v in pairs(tbEquipment) do
    local tbPotential = v:GetEnhancedPotential()
    for nPotentialId,nAdd in pairs(tbPotential) do
      if not mapEquipmentAddLevel[nPotentialId] then
        mapEquipmentAddLevel[nPotentialId] = 0
      end
      mapEquipmentAddLevel[nPotentialId] = mapEquipmentAddLevel[nPotentialId] + nAdd
    end
  end
  add(mapTalentAddLevel)
  add(mapEquipmentAddLevel)
  return mapAddLevel
end

StarTowerLevelData.CalCharacterAttrBattle = function(self, nCharId, stAttr, bMainChar, mapDisc)
  -- function num : 0_21 , upvalues : _ENV, ConfigData, AttrConfig
  local GetCharEquipmentRandomAttr = function(tbEquipment)
    -- function num : 0_21_0 , upvalues : _ENV
    if not tbEquipment or #tbEquipment == 0 then
      return nil
    end
    local tbRandomAttrList = {}
    for _,mapEquipment in pairs(tbEquipment) do
      local mapRandomAttr = mapEquipment:GetRandomAttr()
      for k,v in ipairs(mapRandomAttr) do
        local nAttrId = v.AttrId
        if nAttrId ~= nil then
          local nCfgValue = v.CfgValue
          local nValue = v.Value
          if tbRandomAttrList[nAttrId] == nil then
            tbRandomAttrList[nAttrId] = {CfgValue = nCfgValue, Value = nValue}
          else
            -- DECOMPILER ERROR at PC35: Confused about usage of register: R16 in 'UnsetPending'

            ;
            (tbRandomAttrList[nAttrId]).CfgValue = (tbRandomAttrList[nAttrId]).CfgValue + nCfgValue
            -- DECOMPILER ERROR at PC40: Confused about usage of register: R16 in 'UnsetPending'

            ;
            (tbRandomAttrList[nAttrId]).Value = (tbRandomAttrList[nAttrId]).Value + nValue
          end
        end
      end
    end
    for _,v in pairs(tbRandomAttrList) do
      v.CfgValue = clearFloat(v.CfgValue)
    end
    return tbRandomAttrList
  end

  local mapChar = (self.mapCharData)[nCharId]
  if mapChar == nil then
    printError("没有该角色数据" .. nCharId)
    mapChar = {nLevel = 1, nAdvance = 0, 
tbSkillLvs = {1, 1, 1, 1}
}
  end
  local nLevel = mapChar.nLevel
  local nAdvance = mapChar.nAdvance
  local nAttrId = (UTILS.GetCharacterAttributeId)(nCharId, nAdvance, nLevel)
  local mapCharAttrCfg = (ConfigTable.GetData_Attribute)(tostring(nAttrId))
  if mapCharAttrCfg == nil then
    printError("属性配置不存在:" .. nAttrId)
    return {}
  end
  local mapCharCfg = (DataTable.Character)[nCharId]
  if mapCharCfg == nil then
    printError("角色配置不存在:" .. nCharId)
    return {}
  end
  for _,v in ipairs(AllEnum.AttachAttr) do
    if v.bPlayer and mapCharCfg[v.sKey] ~= nil then
      mapCharAttrCfg[v.sKey] = mapCharCfg[v.sKey]
    end
  end
  local mapDiscAttr = {}
  for _,v in ipairs(AllEnum.AttachAttr) do
    mapDiscAttr[v.sKey] = {Key = v.sKey, Value = 0, CfgValue = 0}
  end
  if mapDisc ~= nil then
    for _,mapDiscData in pairs(mapDisc) do
      for _,v in ipairs(AllEnum.AttachAttr) do
        -- DECOMPILER ERROR at PC110: Confused about usage of register: R23 in 'UnsetPending'

        (mapDiscAttr[v.sKey]).CfgValue = (mapDiscAttr[v.sKey]).CfgValue + ((mapDiscData.mapAttrBase)[v.sKey]).CfgValue
      end
    end
  end
  do
    local mapCharAttr = {}
    for _,v in ipairs(AllEnum.AttachAttr) do
      mapCharAttr[v.sKey] = mapCharAttrCfg[v.sKey] + (mapDiscAttr[v.sKey]).CfgValue
      mapCharAttr["_" .. v.sKey] = mapCharAttr[v.sKey]
      mapCharAttr["_" .. v.sKey .. "PercentAmend"] = 0
      mapCharAttr["_" .. v.sKey .. "Amend"] = 0
    end
    local AddAttrEffect_AllEffectSub = function(nSubType, nValue, mapAttr)
    -- function num : 0_21_1 , upvalues : _ENV, ConfigData, mapCharAttr
    local value = tonumber(nValue) or 0
    if nSubType == (GameEnum.parameterType).BASE_VALUE then
      if not mapAttr.bPercent or not value then
        local nAdd = value * ConfigData.IntFloatPrecision
      end
      mapCharAttr["_" .. mapAttr.sKey] = mapCharAttr["_" .. mapAttr.sKey] + nAdd
    end
  end

    local tbRandomAttr = GetCharEquipmentRandomAttr(mapChar.tbEquipment)
    if tbRandomAttr ~= nil then
      for nAttrValueId,v in pairs(tbRandomAttr) do
        local mapAttrCfg = (ConfigTable.GetData)("CharGemAttrValue", nAttrValueId)
        if mapAttrCfg then
          local attrType = mapAttrCfg.AttrType
          local attrSubType1 = mapAttrCfg.AttrTypeFirstSubtype
          local attrSubType2 = mapAttrCfg.AttrTypeSecondSubtype
          local bAttrFix = attrType == (GameEnum.effectType).ATTR_FIX or attrType == (GameEnum.effectType).PLAYER_ATTR_FIX
          if bAttrFix then
            local mapAttr = (AttrConfig.GetAttrByEffectType)(attrType, attrSubType1)
            if mapAttr == nil then
              printError((string.format)("【装备随机属性】lua属性配置中没找到对应配置!!! attrId = %s", nAttrValueId))
            else
              AddAttrEffect_AllEffectSub(attrSubType2, v.CfgValue, mapAttr)
            end
          end
        end
      end
    end
    for _,v in ipairs(AllEnum.AttachAttr) do
      mapCharAttr[v.sKey] = mapCharAttr["_" .. v.sKey] * (1 + mapCharAttr["_" .. v.sKey .. "PercentAmend"] / 100) + mapCharAttr["_" .. v.sKey .. "Amend"]
      mapCharAttr[v.sKey] = (math.floor)(mapCharAttr[v.sKey])
    end
    local tbTalent = (PlayerData.Talent):GetFateTalentByTalentNodes(nCharId, mapChar.tbActive)
    stAttr.actorLevel = nLevel
    stAttr.breakCount = mapChar.nAdvance
    stAttr.activeTalentInfos = tbTalent
    stAttr.Atk = mapCharAttr.Atk
    stAttr.Hp = mapCharAttr.Hp
    stAttr.Def = mapCharAttr.Def
    stAttr.CritRate = mapCharAttr.CritRate
    stAttr.CritResistance = mapCharAttr.CritResistance
    stAttr.CritPower = mapCharAttr.CritPower
    stAttr.HitRate = mapCharAttr.HitRate
    stAttr.Evd = mapCharAttr.Evd
    stAttr.DefPierce = mapCharAttr.DefPierce
    stAttr.WEP = mapCharAttr.WEP
    stAttr.FEP = mapCharAttr.FEP
    stAttr.SEP = mapCharAttr.SEP
    stAttr.AEP = mapCharAttr.AEP
    stAttr.LEP = mapCharAttr.LEP
    stAttr.DEP = mapCharAttr.DEP
    stAttr.WEE = mapCharAttr.WEE
    stAttr.FEE = mapCharAttr.FEE
    stAttr.SEE = mapCharAttr.SEE
    stAttr.AEE = mapCharAttr.AEE
    stAttr.LEE = mapCharAttr.LEE
    stAttr.DEE = mapCharAttr.DEE
    stAttr.WER = mapCharAttr.WER
    stAttr.FER = mapCharAttr.FER
    stAttr.SER = mapCharAttr.SER
    stAttr.AER = mapCharAttr.AER
    stAttr.LER = mapCharAttr.LER
    stAttr.DER = mapCharAttr.DER
    stAttr.WEI = mapCharAttr.WEI
    stAttr.FEI = mapCharAttr.FEI
    stAttr.SEI = mapCharAttr.SEI
    stAttr.AEI = mapCharAttr.AEI
    stAttr.LEI = mapCharAttr.LEI
    stAttr.DEI = mapCharAttr.DEI
    stAttr.DefIgnore = mapCharAttr.DefIgnore
    stAttr.ShieldBonus = mapCharAttr.ShieldBonus
    stAttr.IncomingShieldBonus = mapCharAttr.IncomingShieldBonus
    stAttr.SkillLevel = mapChar.tbSkillLvs
    stAttr.skinId = mapChar.nSkinId
    stAttr.attrId = tostring(nAttrId)
    stAttr.Suppress = mapCharAttr.Suppress
    stAttr.NormalDmgRatio = mapCharAttr.NORMALDMG
    stAttr.SkillDmgRatio = mapCharAttr.SKILLDMG
    stAttr.UltraDmgRatio = mapCharAttr.ULTRADMG
    stAttr.OtherDmgRatio = mapCharAttr.OTHERDMG
    stAttr.RcdNormalDmgRatio = mapCharAttr.RCDNORMALDMG
    stAttr.RcdSkillDmgRatio = mapCharAttr.RCDSKILLDMG
    stAttr.RcdUltraDmgRatio = mapCharAttr.RCDULTRADMG
    stAttr.RcdOtherDmgRatio = mapCharAttr.RCDOTHERDMG
    stAttr.MarkDmgRatio = mapCharAttr.MARKDMG
    stAttr.SummonDmgRatio = mapCharAttr.SUMMONDMG
    stAttr.RcdSummonDmgRatio = mapCharAttr.RCDSUMMONDMG
    stAttr.ProjectileDmgRatio = mapCharAttr.PROJECTILEDMG
    stAttr.RcdProjectileDmgRatio = mapCharAttr.RCDPROJECTILEDMG
    stAttr.GENDMG = mapCharAttr.GENDMG
    stAttr.DMGPLUS = mapCharAttr.DMGPLUS
    stAttr.FINALDMG = mapCharAttr.FINALDMG
    stAttr.FINALDMGPLUS = mapCharAttr.FINALDMGPLUS
    stAttr.WEERCD = mapCharAttr.WEERCD
    stAttr.FEERCD = mapCharAttr.FEERCD
    stAttr.SEERCD = mapCharAttr.SEERCD
    stAttr.AEERCD = mapCharAttr.AEERCD
    stAttr.LEERCD = mapCharAttr.LEERCD
    stAttr.DEERCD = mapCharAttr.DEERCD
    stAttr.GENDMGRCD = mapCharAttr.GENDMGRCD
    stAttr.DMGPLUSRCD = mapCharAttr.DMGPLUSRCD
    stAttr.NormalCritRate = mapCharAttr.NormalCritRate
    stAttr.SkillCritRate = mapCharAttr.SkillCritRate
    stAttr.UltraCritRate = mapCharAttr.UltraCritRate
    stAttr.MarkCritRate = mapCharAttr.MarkCritRate
    stAttr.SummonCritRate = mapCharAttr.SummonCritRate
    stAttr.ProjectileCritRate = mapCharAttr.ProjectileCritRate
    stAttr.OtherCritRate = mapCharAttr.OtherCritRate
    stAttr.NormalCritPower = mapCharAttr.NormalCritPower
    stAttr.SkillCritPower = mapCharAttr.SkillCritPower
    stAttr.UltraCritPower = mapCharAttr.UltraCritPower
    stAttr.MarkCritPower = mapCharAttr.MarkCritPower
    stAttr.SummonCritPower = mapCharAttr.SummonCritPower
    stAttr.ProjectileCritPower = mapCharAttr.ProjectileCritPower
    stAttr.OtherCritPower = mapCharAttr.OtherCritPower
    stAttr.EnergyConvRatio = mapCharAttr.EnergyConvRatio
    stAttr.EnergyEfficiency = mapCharAttr.EnergyEfficiency
    stAttr.ToughnessDamageAdjust = mapCharAttr.ToughnessDamageAdjust
    stAttr.initHp = 0
    do return 0 end
    -- DECOMPILER ERROR: 5 unprocessed JMP targets
  end
end

StarTowerLevelData.ProcessChangeInfo = function(self, mapChangeData)
  -- function num : 0_22 , upvalues : _ENV
  local mapData = (UTILS.DecodeChangeInfo)(mapChangeData)
  local tbChangeFateCard = {}
  local mapRewardChange = {}
  local mapPotentialChange = {}
  if mapData["proto.FateCardInfo"] ~= nil then
    for _,mapFateCardData in ipairs(mapData["proto.FateCardInfo"]) do
      local nBeforeRoomCount = 0
      local nBeforeEftCount = 0
      if (self._mapFateCard)[mapFateCardData.Tid] ~= nil then
        nBeforeRoomCount = ((self._mapFateCard)[mapFateCardData.Tid])[2]
        nBeforeEftCount = ((self._mapFateCard)[mapFateCardData.Tid])[1]
      end
      if mapFateCardData.Qty == 0 then
        self:RemoveFateCardEft(mapFateCardData.Tid)
        -- DECOMPILER ERROR at PC37: Confused about usage of register: R13 in 'UnsetPending'

        ;
        (self._mapFateCard)[mapFateCardData.Tid] = nil
        ;
        (table.insert)(tbChangeFateCard, {mapFateCardData.Tid, 0, 0, -1})
      else
        local nCountSum = 0
        if (self._mapFateCard)[mapFateCardData.Tid] == nil then
          nCountSum = 1
        end
        -- DECOMPILER ERROR at PC62: Confused about usage of register: R14 in 'UnsetPending'

        ;
        (self._mapFateCard)[mapFateCardData.Tid] = {mapFateCardData.Remain, mapFateCardData.Room}
        if mapFateCardData.Room ~= 0 and mapFateCardData.Remain ~= 0 then
          self:AddFateCardEft(mapFateCardData.Tid)
          local nBeforeCount = (math.max)(nBeforeEftCount, nBeforeRoomCount)
          if (self._mapFateCard)[mapFateCardData.Tid] ~= nil and nBeforeCount <= 0 then
            nCountSum = 2
          end
        else
          do
            do
              self:RemoveFateCardEft(mapFateCardData.Tid)
              ;
              (table.insert)(tbChangeFateCard, {mapFateCardData.Tid, ((self._mapFateCard)[mapFateCardData.Tid])[1] - nBeforeEftCount, ((self._mapFateCard)[mapFateCardData.Tid])[2] - nBeforeRoomCount, nCountSum})
              -- DECOMPILER ERROR at PC107: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC107: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC107: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC107: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC107: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
  if mapData["proto.PotentialInfo"] ~= nil then
    for _,mapPotentialInfo in ipairs(mapData["proto.PotentialInfo"]) do
      local mapPotentialCfgData = (ConfigTable.GetData)("Potential", mapPotentialInfo.Tid)
      if mapPotentialCfgData == nil then
        printError("PotentialCfgData Missing" .. mapPotentialInfo.Tid)
      else
        local nCharId = mapPotentialCfgData.CharId
        -- DECOMPILER ERROR at PC139: Confused about usage of register: R13 in 'UnsetPending'

        if ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] == nil then
          ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] = 0
        end
        local nCurLevel = ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid]
        local nNextLevel = ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] + mapPotentialInfo.Level
        mapPotentialChange[mapPotentialInfo.Tid] = {nLevel = nCurLevel, nNextLevel = nNextLevel}
        -- DECOMPILER ERROR at PC158: Confused about usage of register: R15 in 'UnsetPending'

        ;
        ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] = nNextLevel
        self:ChangePotentialCount(mapPotentialInfo.Tid, nNextLevel - nCurLevel)
        self:ChangePotential(mapPotentialInfo.Tid)
      end
    end
  end
  do
    if mapData["proto.TowerItemInfo"] ~= nil then
      for _,mapItemInfo in ipairs(mapData["proto.TowerItemInfo"]) do
        -- DECOMPILER ERROR at PC182: Confused about usage of register: R11 in 'UnsetPending'

        if (self._mapItem)[mapItemInfo.Tid] == nil then
          (self._mapItem)[mapItemInfo.Tid] = 0
        end
        -- DECOMPILER ERROR at PC190: Confused about usage of register: R11 in 'UnsetPending'

        ;
        (self._mapItem)[mapItemInfo.Tid] = (self._mapItem)[mapItemInfo.Tid] + mapItemInfo.Qty
        if mapRewardChange[mapItemInfo.Tid] == nil then
          mapRewardChange[mapItemInfo.Tid] = mapItemInfo.Qty
        else
          mapRewardChange[mapItemInfo.Tid] = mapRewardChange[mapItemInfo.Tid] + mapItemInfo.Qty
        end
      end
    end
    do
      if mapData["proto.TowerResInfo"] ~= nil then
        for _,mapItemInfo in ipairs(mapData["proto.TowerResInfo"]) do
          -- DECOMPILER ERROR at PC221: Confused about usage of register: R11 in 'UnsetPending'

          if (self._mapItem)[mapItemInfo.Tid] == nil then
            (self._mapItem)[mapItemInfo.Tid] = 0
          end
          -- DECOMPILER ERROR at PC229: Confused about usage of register: R11 in 'UnsetPending'

          ;
          (self._mapItem)[mapItemInfo.Tid] = (self._mapItem)[mapItemInfo.Tid] + mapItemInfo.Qty
          if mapRewardChange[mapItemInfo.Tid] == nil then
            mapRewardChange[mapItemInfo.Tid] = mapItemInfo.Qty
          else
            mapRewardChange[mapItemInfo.Tid] = mapRewardChange[mapItemInfo.Tid] + mapItemInfo.Qty
          end
        end
      end
      do
        local nScore = self:CalBuildScore()
        ;
        (EventManager.Hit)("StarTowerRefreshBuildScore", nScore)
        return tbChangeFateCard, mapRewardChange, mapPotentialChange
      end
    end
  end
end

StarTowerLevelData.ProcessTowerChangeData = function(self, mapChange)
  -- function num : 0_23 , upvalues : _ENV
  if not mapChange then
    return {}, {}
  end
  local mapChangeNote = {}
  if mapChange.Infos and next(mapChange.Infos) ~= nil then
    for _,mapNoteInfo in ipairs(mapChange.Infos) do
      print((string.format)("音符数量变化：%d,%d", mapNoteInfo.Tid, mapNoteInfo.Qty))
      -- DECOMPILER ERROR at PC33: Confused about usage of register: R8 in 'UnsetPending'

      if (self._mapNote)[mapNoteInfo.Tid] == nil then
        (self._mapNote)[mapNoteInfo.Tid] = 0
      end
      -- DECOMPILER ERROR at PC41: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (self._mapNote)[mapNoteInfo.Tid] = (self._mapNote)[mapNoteInfo.Tid] + mapNoteInfo.Qty
      mapChangeNote[mapNoteInfo.Tid] = mapNoteInfo
    end
    self:ResetNoteInfo()
    self:ResetDiscInfo()
    self:ChangeNote()
  end
  local mapChangeSecondarySkill = {}
  if mapChange.Secondaries and next(mapChange.Secondaries) ~= nil then
    for _,v in ipairs(mapChange.Secondaries) do
      (table.insert)(mapChangeSecondarySkill, v)
      if v.Active then
        (table.insert)(self.tbActiveSecondaryIds, v.SecondaryId)
      else
        ;
        (table.removebyvalue)(self.tbActiveSecondaryIds, v.SecondaryId)
      end
    end
  end
  do
    return mapChangeNote, mapChangeSecondarySkill
  end
end

StarTowerLevelData.GetActorHp = function()
  -- function num : 0_24 , upvalues : _ENV
  local logStr = ""
  local tbActorEntity = ((CS.AdventureModuleHelper).GetCurrentGroupPlayers)()
  local mapCurCharInfo = {}
  local count = tbActorEntity.Count - 1
  for i = 0, count do
    local nCharId = ((CS.AdventureModuleHelper).GetCharacterId)(tbActorEntity[i])
    local hp = ((CS.AdventureModuleHelper).GetEntityHp)(tbActorEntity[i])
    mapCurCharInfo[nCharId] = hp
    logStr = logStr .. (string.format)("EntityID:%d\t角色Id�?%d\t角色血量：%d\n", tbActorEntity[i], nCharId, hp)
  end
  print(logStr)
  return mapCurCharInfo
end

StarTowerLevelData.GetcurRoom = function(self)
  -- function num : 0_25 , upvalues : mapProcCtrl, PATH, _ENV
  if (self.tbStarTowerAllLevel)[self.nCurLevel] ~= nil then
    local sRoomName = mapProcCtrl[((self.tbStarTowerAllLevel)[self.nCurLevel]).RoomType]
    if sRoomName == nil then
      sRoomName = "EventRoom"
    end
    local fullPath = PATH .. sRoomName
    print(fullPath)
    local curRoom = require(fullPath)
    return curRoom
  else
    do
      printError("Stage Missing :" .. self.nCurLevel)
      local sRoomName = "EventRoom"
      local fullPath = PATH .. sRoomName
      print(fullPath)
      local curRoom = require(fullPath)
      do return curRoom end
    end
  end
end

StarTowerLevelData.GetStageId = function(self, nFloor)
  -- function num : 0_26
  if (self.tbStarTowerAllLevel)[nFloor] ~= nil then
    return ((self.tbStarTowerAllLevel)[nFloor]).Id
  end
  return 0
end

StarTowerLevelData.GetStage = function(self, nFloor)
  -- function num : 0_27
  if (self.tbStarTowerAllLevel)[nFloor] ~= nil then
    return ((self.tbStarTowerAllLevel)[nFloor]).Stage
  end
  return 0
end

StarTowerLevelData.RemoveFateCardEft = function(self, nFateCardId)
  -- function num : 0_28 , upvalues : _ENV
  local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
  if mapFateCardCfgData == nil then
    printError("FateCardCfgData Missing:" .. nFateCardId)
  else
    local nEftId = mapFateCardCfgData.ClientEffect
    if (self.mapFateCardEft)[nEftId] ~= nil and ((self.mapFateCardEft)[nEftId]).tbEftUid ~= nil then
      for _,tbUid in ipairs(((self.mapFateCardEft)[nEftId]).tbEftUid) do
        (UTILS.RemoveEffect)(tbUid[1], tbUid[2])
      end
      -- DECOMPILER ERROR at PC37: Confused about usage of register: R4 in 'UnsetPending'

      ;
      (self.mapFateCardEft)[nEftId] = nil
    end
    for _,nExEftId in ipairs(mapFateCardCfgData.ClientExEffect) do
      if (self.mapFateCardEft)[nExEftId] ~= nil and ((self.mapFateCardEft)[nExEftId]).tbEftUid ~= nil then
        for _,tbUid in ipairs(((self.mapFateCardEft)[nExEftId]).tbEftUid) do
          (UTILS.RemoveEffect)(tbUid[1], tbUid[2])
        end
        -- DECOMPILER ERROR at PC65: Confused about usage of register: R9 in 'UnsetPending'

        ;
        (self.mapFateCardEft)[nExEftId] = nil
      end
    end
  end
end

StarTowerLevelData.AddFateCardEft = function(self, nFateCardId)
  -- function num : 0_29 , upvalues : _ENV
  local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
  if mapFateCardCfgData == nil then
    printError("FateCardCfgData Missing:" .. nFateCardId)
  else
    if (self.mapFateCardEft)[mapFateCardCfgData.ClientEffect] ~= nil then
      return 
    end
    if mapFateCardCfgData.ClientEffect == 0 or mapFateCardCfgData.MethodMode ~= (GameEnum.fateCardMethodMode).ClientFateCard then
      return 
    end
    local nReaminCount = mapFateCardCfgData.Count
    if (self._mapFateCard)[nFateCardId] ~= nil then
      nReaminCount = ((self._mapFateCard)[nFateCardId])[1]
    end
    if nReaminCount == 0 then
      return 
    end
    -- DECOMPILER ERROR at PC46: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self.mapFateCardEft)[mapFateCardCfgData.ClientEffect] = {nFateCardId = nFateCardId, 
tbEftUid = {}
}
    for _,nEftId in ipairs(mapFateCardCfgData.ClientExEffect) do
      -- DECOMPILER ERROR at PC56: Confused about usage of register: R9 in 'UnsetPending'

      (self.mapFateCardEft)[nEftId] = {nFateCardId = nFateCardId, 
tbEftUid = {}
}
    end
    for _,nCharId in ipairs(self.tbTeam) do
      local nUid = (UTILS.AddFateCardEft)(nCharId, mapFateCardCfgData.ClientEffect, nReaminCount)
      ;
      (table.insert)(((self.mapFateCardEft)[mapFateCardCfgData.ClientEffect]).tbEftUid, {nUid, nCharId})
      for _,nEftId in ipairs(mapFateCardCfgData.ClientExEffect) do
        local nUid = (UTILS.AddFateCardEft)(nCharId, nEftId, -1)
        ;
        (table.insert)(((self.mapFateCardEft)[nEftId]).tbEftUid, {nUid, nCharId})
      end
    end
  end
end

StarTowerLevelData.ChangePotential = function(self, nPotentialId)
  -- function num : 0_30 , upvalues : _ENV
  local mapPotentialCfgData = (ConfigTable.GetData)("Potential", nPotentialId)
  if mapPotentialCfgData == nil then
    printError("PotentialCfgData Missing" .. nPotentialId)
    return 
  end
  local nCharId = mapPotentialCfgData.CharId
  local nCount = 0
  if ((self._mapPotential)[nCharId])[nPotentialId] ~= nil then
    nCount = ((self._mapPotential)[nCharId])[nPotentialId]
    if (self.mapPotentialAddLevel)[nCharId] ~= nil and ((self.mapPotentialAddLevel)[nCharId])[nPotentialId] ~= nil then
      nCount = nCount + ((self.mapPotentialAddLevel)[nCharId])[nPotentialId]
    end
  end
  if (self.mapPotentialEft)[nPotentialId] ~= nil then
    for _,tbEft in ipairs((self.mapPotentialEft)[nPotentialId]) do
      (UTILS.RemoveEffect)(tbEft[1], tbEft[2])
    end
    -- DECOMPILER ERROR at PC53: Confused about usage of register: R5 in 'UnsetPending'

    ;
    (self.mapPotentialEft)[nPotentialId] = nil
  end
  if nCount < 1 then
    return 
  end
  local tbEft = {}
  if mapPotentialCfgData.EffectId1 ~= 0 then
    (table.insert)(tbEft, mapPotentialCfgData.EffectId1)
  end
  if mapPotentialCfgData.EffectId2 ~= 0 then
    (table.insert)(tbEft, mapPotentialCfgData.EffectId2)
  end
  if mapPotentialCfgData.EffectId3 ~= 0 then
    (table.insert)(tbEft, mapPotentialCfgData.EffectId3)
  end
  if mapPotentialCfgData.EffectId4 ~= 0 then
    (table.insert)(tbEft, mapPotentialCfgData.EffectId4)
  end
  for _,nCharTid in ipairs(self.tbTeam) do
    if nCharTid == mapPotentialCfgData.CharId then
      for _,nEftId in ipairs(tbEft) do
        -- DECOMPILER ERROR at PC103: Confused about usage of register: R16 in 'UnsetPending'

        (self.mapPotentialEft)[nPotentialId] = {}
        local nEftUseCount = (self.mapEffectTriggerCount)[nEftId]
        if nEftUseCount == nil then
          nEftUseCount = 0
        end
        local nEftUid = (UTILS.AddEffect)(nCharId, nEftId, nCount, nEftUseCount)
        ;
        (table.insert)((self.mapPotentialEft)[nPotentialId], {nEftUid, nCharTid})
      end
    end
  end
end

StarTowerLevelData.SetFateCardToAdventureModule = function(self)
  -- function num : 0_31 , upvalues : _ENV
  local tbFateCardInfo = {}
  for nId,tbFateCard in pairs(self._mapFateCard) do
    local stFateCard = (CS.Lua2CSharpInfo_FateCardInfo)()
    stFateCard.fateCardId = nId
    stFateCard.Remain = tbFateCard[1]
    stFateCard.Room = tbFateCard[2]
    ;
    (table.insert)(tbFateCardInfo, stFateCard)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetFateCardInfos, tbFateCardInfo)
end

StarTowerLevelData.ChangeNote = function(self)
  -- function num : 0_32 , upvalues : _ENV
  for nDiscId,mapDiscData in pairs(self.mapDiscData) do
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R6 in 'UnsetPending'

    if (table.indexof)(self.tbDisc, nDiscId) <= 3 then
      if (self.mapDiscEft)[nDiscId] == nil then
        (self.mapDiscEft)[nDiscId] = {}
      else
        for _,tbEft in pairs((self.mapDiscEft)[nDiscId]) do
          for _,tbEftData in ipairs(tbEft) do
            (UTILS.RemoveEffect)(tbEftData[1], tbEftData[2])
          end
        end
        -- DECOMPILER ERROR at PC39: Confused about usage of register: R6 in 'UnsetPending'

        ;
        (self.mapDiscEft)[nDiscId] = {}
      end
      local tbDiscEft = mapDiscData:GetSkillEffect(self._mapNote)
      for _,mapEft in ipairs(tbDiscEft) do
        -- DECOMPILER ERROR at PC57: Confused about usage of register: R12 in 'UnsetPending'

        if ((self.mapDiscEft)[nDiscId])[mapEft[1]] == nil then
          ((self.mapDiscEft)[nDiscId])[mapEft[1]] = {}
          local nEftUseCount = (self.mapEffectTriggerCount)[mapEft[1]]
          if nEftUseCount == nil then
            nEftUseCount = 0
          end
          for _,nCharId in ipairs(self.tbTeam) do
            local nEftUid = (UTILS.AddEffect)(nCharId, mapEft[1], mapEft[2], nEftUseCount)
            ;
            (table.insert)(((self.mapDiscEft)[nDiscId])[mapEft[1]], {nEftUid, nCharId})
          end
        end
      end
    end
  end
  for nNoteId,nNoteCount in pairs(self._mapNote) do
    -- DECOMPILER ERROR at PC102: Confused about usage of register: R6 in 'UnsetPending'

    if (self.mapNoteEft)[nNoteId] == nil then
      (self.mapNoteEft)[nNoteId] = {}
    else
      for _,tbEft in pairs((self.mapNoteEft)[nNoteId]) do
        for _,tbEftData in ipairs(tbEft) do
          (UTILS.RemoveEffect)(tbEftData[1], tbEftData[2])
        end
      end
      -- DECOMPILER ERROR at PC124: Confused about usage of register: R6 in 'UnsetPending'

      ;
      (self.mapNoteEft)[nNoteId] = {}
    end
    if nNoteCount > 0 then
      local tbNoteEft = {}
      local mapNoteCfgData = (ConfigTable.GetData)("SubNoteSkill", nNoteId)
      if mapNoteCfgData == nil then
        printError("NoteCfgData Missing:" .. nNoteId)
      else
        for _,nEftId in ipairs(mapNoteCfgData.EffectId) do
          (table.insert)(tbNoteEft, {R16_PC151, nNoteCount})
        end
      end
      do
        for _,mapEft in ipairs(tbNoteEft) do
          -- DECOMPILER ERROR at PC169: Confused about usage of register: R13 in 'UnsetPending'

          if ((self.mapNoteEft)[nNoteId])[mapEft[1]] == nil then
            ((self.mapNoteEft)[nNoteId])[mapEft[1]] = {}
            local nEftUseCount = (self.mapEffectTriggerCount)[mapEft[1]]
            if nEftUseCount == nil then
              nEftUseCount = 0
            end
            for _,nCharId in ipairs(self.tbTeam) do
              local nEftUid = (UTILS.AddEffect)(nCharId, mapEft[1], mapEft[2], nEftUseCount)
              ;
              (table.insert)(((self.mapNoteEft)[nNoteId])[mapEft[1]], {nEftUid, nCharId})
            end
          end
        end
        do
          -- DECOMPILER ERROR at PC202: LeaveBlock: unexpected jumping out DO_STMT

          -- DECOMPILER ERROR at PC202: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC202: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
end

StarTowerLevelData.GetFateCardUsage = function(self)
  -- function num : 0_33 , upvalues : _ENV
  local ret = {}
  for nFateCardId,nCount in pairs(self.mapFateCardUseCount) do
    (table.insert)(ret, {Id = nFateCardId, Times = nCount})
  end
  return ret
end

StarTowerLevelData.GetDamageRecord = function(self)
  -- function num : 0_34 , upvalues : _ENV
  local ret = {}
  for _,nCharId in pairs(self.tbTeam) do
    local nDamage = safe_call_cs_func((CS.AdventureModuleHelper).GetCharacterDamage, nCharId, false)
    ;
    (table.insert)(ret, nDamage)
  end
  return ret
end

StarTowerLevelData.CheckBattleEnd = function(tbCases)
  -- function num : 0_35 , upvalues : _ENV
  for _,mapCases in ipairs(tbCases) do
    if mapCases.BattleCase ~= nil then
      return false
    end
  end
  return true
end

StarTowerLevelData.GetDropInfo = function(self, nCurLevel, nRoomType, tbCases)
  -- function num : 0_36 , upvalues : _ENV
  local ret = {0, 0, 0, 0}
  local nCurStage = (self.tbStarTowerAllLevel)[nCurLevel]
  local nCoinCount = nCurStage.InteriorCurrencyQuantity
  ret[1] = nCoinCount
  local mapExp = (self.mapFloorExp)[nCurStage.Stage]
  if mapExp == nil then
    ret[2] = 0
  else
    if nRoomType == (GameEnum.starTowerRoomType).DangerRoom then
      ret[2] = mapExp.DangerExp
    else
      if nRoomType == (GameEnum.starTowerRoomType).HorrorRoom then
        ret[2] = mapExp.HorrorExp
      else
        if nRoomType == (GameEnum.starTowerRoomType).BattleRoom then
          ret[2] = mapExp.NormalExp
        else
          if nRoomType == (GameEnum.starTowerRoomType).EliteBattleRoom then
            ret[2] = mapExp.EliteExp
          else
            if nRoomType == (GameEnum.starTowerRoomType).BossRoom then
              ret[2] = mapExp.BossExp
            else
              if nRoomType == (GameEnum.starTowerRoomType).FinalBossRoom then
                ret[2] = mapExp.FinalBossExp
              else
                ret[2] = 0
              end
            end
          end
        end
      end
    end
  end
  for _,mapCases in ipairs(tbCases) do
    if mapCases.BattleCase ~= nil then
      if (mapCases.BattleCase).FateCard then
        ret[3] = 1
      end
      if (mapCases.BattleCase).SubNoteSkillNum then
        ret[4] = (mapCases.BattleCase).SubNoteSkillNum
      end
    end
  end
  return ret
end

StarTowerLevelData.RecoverHp = function(self, nEffectId)
  -- function num : 0_37 , upvalues : _ENV
  for _,nCharId in ipairs(self.tbTeam) do
    print("AddRecoverEft:" .. nEffectId)
    ;
    (UTILS.AddEffect)(nCharId, nEffectId, 0, 0)
  end
  local nMainChar = (self.tbTeam)[1]
  local mapHp = ((self.GetActorHp)())
  local nHp = nil
  if mapHp ~= nil then
    nHp = mapHp[nMainChar]
  end
  if nHp == nil then
    nHp = -1
  end
  return nHp
end

StarTowerLevelData.QueryLevelInfo = function(self, nId, nType, nParam1, nParam2)
  -- function num : 0_38 , upvalues : _ENV
  if nType == (GameEnum.levelTypeData).None then
    return 0
  else
    if nType == (GameEnum.levelTypeData).Exclusive then
      local mapPotential = (ConfigTable.GetData)("Potential", nId)
      if mapPotential == nil then
        return 1
      end
      local nCharId = mapPotential.CharId
      if (self._mapPotential)[nCharId] == nil then
        return 1
      end
      if ((self._mapPotential)[nCharId])[nId] == nil then
        return 1
      end
      return ((self._mapPotential)[nCharId])[nId]
    else
      do
        if nType == (GameEnum.levelTypeData).Actor then
          if (self.mapCharData)[nId] == nil then
            return nil
          end
          return ((self.mapCharData)[nId]).nLevel
        else
          if nType == (GameEnum.levelTypeData).SkillSlot then
            if (self.mapCharData)[nId] == nil then
              return nil
            end
            if nParam1 == nil then
              return (((self.mapCharData)[nId]).tbSkillLvs)[1]
            else
              if nParam1 == 2 then
                return (((self.mapCharData)[nId]).tbSkillLvs)[2]
              else
                if nParam1 == 4 then
                  return (((self.mapCharData)[nId]).tbSkillLvs)[3]
                else
                  if nParam1 == 5 then
                    return (((self.mapCharData)[nId]).tbSkillLvs)[1]
                  else
                    return (((self.mapCharData)[nId]).tbSkillLvs)[1]
                  end
                end
              end
            end
          else
            if nType == (GameEnum.levelTypeData).BreakCount then
              if (self.mapCharData)[nId] == nil then
                return nil
              end
              return ((self.mapCharData)[nId]).nAdvance + 1
            end
          end
        end
      end
    end
  end
end

StarTowerLevelData.CalBuildScore = function(self)
  -- function num : 0_39 , upvalues : _ENV
  local nPotentialScore = 0
  for _,tbPotentialInfo in pairs(self._mapPotential) do
    for nPotentialId,nPotentialLevel in pairs(tbPotentialInfo) do
      local mapPotentialCfgData = (ConfigTable.GetData)("Potential", nPotentialId)
      if mapPotentialCfgData ~= nil and nPotentialLevel > 0 then
        nPotentialScore = nPotentialScore + (mapPotentialCfgData.BuildScore)[nPotentialLevel]
      end
    end
  end
  local nDiscScore = 0
  for k,nDiscId in ipairs(self.tbDisc) do
    if nDiscId ~= 0 and k <= 3 then
      nDiscScore = nDiscScore + (PlayerData.Disc):GetDiscSkillScore(nDiscId, self._mapNote)
    end
  end
  local nNoteScore = 0
  for nNoteId,nNoteCount in pairs(self._mapNote) do
    if nNoteCount > 0 then
      local mapCfg = (ConfigTable.GetData)("SubNoteSkill", nNoteId)
      if mapCfg and next(mapCfg.Scores) ~= nil then
        local nMax = #mapCfg.Scores
        local nLevel = nMax < nNoteCount and nMax or nNoteCount
        nNoteScore = nNoteScore + (mapCfg.Scores)[nLevel]
      end
    end
  end
  return nPotentialScore + (nDiscScore) + (nNoteScore)
end

StarTowerLevelData.SetRoguelikeHistoryMapId = function(self, nMapId)
  -- function num : 0_40 , upvalues : _ENV, LocalStarTowerDataKey, RapidJson
  local LocalData = require("GameCore.Data.LocalData")
  if nMapId == nil then
    (LocalData.SetPlayerLocalData)(LocalStarTowerDataKey, (RapidJson.encode)({}))
    return 
  end
  local tbHistoryMap = nil
  local tbTemp = {}
  local nHistoryMapCount = (ConfigTable.GetConfigNumber)("StarTowerHistoryMapLimit")
  local sJsonRoguelikeData = (LocalData.GetPlayerLocalData)(LocalStarTowerDataKey)
  if type(sJsonRoguelikeData) == "string" and sJsonRoguelikeData ~= "" then
    tbHistoryMap = (RapidJson.decode)(sJsonRoguelikeData)
  else
    tbHistoryMap = {}
  end
  if #tbHistoryMap < nHistoryMapCount then
    (table.insert)(tbHistoryMap, nMapId)
  else
    ;
    (table.remove)(tbHistoryMap, 1)
    ;
    (table.insert)(tbHistoryMap, nMapId)
  end
  for _,mapId in ipairs(tbHistoryMap) do
    (table.insert)(tbTemp, mapId)
  end
  local sJsonRoguelikeDataAfter = (RapidJson.encode)(tbTemp)
  ;
  (LocalData.SetPlayerLocalData)(LocalStarTowerDataKey, sJsonRoguelikeDataAfter)
end

StarTowerLevelData.GetRoguelikeHistoryMapId = function(self)
  -- function num : 0_41 , upvalues : _ENV, LocalStarTowerDataKey, RapidJson
  local LocalData = require("GameCore.Data.LocalData")
  local sJsonRoguelikeData = (LocalData.GetPlayerLocalData)(LocalStarTowerDataKey)
  if type(sJsonRoguelikeData) == "string" and sJsonRoguelikeData ~= "" then
    local tbHistoryMap = (RapidJson.decode)(sJsonRoguelikeData)
    return tbHistoryMap
  else
    do
      do return {} end
    end
  end
end

StarTowerLevelData.PlayRoomBGM = function(self)
  -- function num : 0_42 , upvalues : mapBGMCfg, _ENV, WwiseAudioMgr
  local bPlayOutfitBGM = mapBGMCfg[self.nRoomType]
  local bChangeBgmState = true
  if self.nLastRoomType ~= -1 then
    if not mapBGMCfg[self.nLastRoomType] or not bPlayOutfitBGM then
      self:ResetRoomBGM()
    else
      bChangeBgmState = false
    end
  end
  if not bPlayOutfitBGM then
    return 
  end
  local nIndex = (math.random)(1, 3)
  local nDiscId = (self.tbDisc)[nIndex]
  local mapOutfitCfg = (ConfigTable.GetData)("DiscIP", nDiscId)
  local sBGM = ""
  if mapOutfitCfg ~= nil then
    sBGM = mapOutfitCfg.VoFile
  end
  if sBGM ~= "" then
    WwiseAudioMgr:PostEvent("music_outfit_enter")
    WwiseAudioMgr:SetState("combat", "explore")
    WwiseAudioMgr:SetState("outfit", sBGM)
    self.sLastBGM = sBGM
  else
    if self.nLastRoomType == (GameEnum.starTowerRoomType).ShopRoom or self.nLastRoomType == (GameEnum.starTowerRoomType).EventRoom then
      self:ResetRoomBGM()
      self.sLastBGM = ""
    end
  end
  self.nLastRoomType = self.nRoomType
end

StarTowerLevelData.ResetRoomBGM = function(self)
  -- function num : 0_43 , upvalues : WwiseAudioMgr, _ENV
  WwiseAudioMgr:StopDiscMusic(true, function()
    -- function num : 0_43_0 , upvalues : _ENV
    (NovaAPI.UnLoadBankByEventName)("music_outfit_stop")
  end
)
end

StarTowerLevelData.ReplayShopBGM = function(self)
  -- function num : 0_44 , upvalues : WwiseAudioMgr
  if self.sLastBGM ~= "" then
    WwiseAudioMgr:PostEvent("music_outfit_enter")
    WwiseAudioMgr:SetState("combat", "explore")
    WwiseAudioMgr:SetState("outfit", self.sLastBGM)
  end
end

StarTowerLevelData.CacheTempData = function(self)
  -- function num : 0_45 , upvalues : _ENV, FP, EncodeTempDataJson
  self.mapCharacterTempData = {}
  local AdventureModuleHelper = CS.AdventureModuleHelper
  local id = (AdventureModuleHelper.GetCurrentActivePlayer)()
  -- DECOMPILER ERROR at PC12: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).curCharId = ((CS.AdventureModuleHelper).GetCharacterId)(id)
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).skillInfo = {}
  -- DECOMPILER ERROR at PC18: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).effectInfo = {}
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).buffInfo = {}
  -- DECOMPILER ERROR at PC24: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).stateInfo = {}
  -- DECOMPILER ERROR at PC27: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).ammoInfo = {}
  -- DECOMPILER ERROR at PC31: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).sommonInfo = (AdventureModuleHelper.GetSummonMonsterInfos)()
  local playerids = (AdventureModuleHelper.GetCurrentGroupPlayers)()
  local Count = playerids.Count - 1
  for i = 0, Count do
    local charTid = (AdventureModuleHelper.GetCharacterId)(playerids[i])
    local clsSkillId = (AdventureModuleHelper.GetPlayerSkillCd)(playerids[i])
    local nStatus = (AdventureModuleHelper.GetPlayerActorStatus)(playerids[i])
    local nStatusTime = (AdventureModuleHelper.GetPlayerActorSpecialStatusTime)(playerids[i])
    local tbAmmo = (AdventureModuleHelper.GetPlayerActorAmmoCount)(playerids[i])
    local nAmmoType = (AdventureModuleHelper.GetPlayerActorAmmoType)(playerids[i])
    local jsonString = (AdventureModuleHelper.GetPlayerActorLocalDataJson)(playerids[i])
    print((string.format)("Status:%d,Time:%d", nStatus, nStatusTime))
    if clsSkillId ~= nil then
      local tbSkillInfos = clsSkillId.skillInfos
      local nSkillCount = tbSkillInfos.Count - 1
      for j = 0, nSkillCount do
        local clsSkillInfo = tbSkillInfos[j]
        local mapSkill = (ConfigTable.GetData_Skill)(clsSkillInfo.skillId)
        if mapSkill == nil then
          return 
        end
        if not mapSkill.IsCleanSkillCD then
          (table.insert)((self.mapCharacterTempData).skillInfo, {nCharId = charTid, nSkillId = clsSkillInfo.skillId, nCd = (FP.ToInt)(clsSkillInfo.currentUseInterval), nSectionAmount = clsSkillInfo.currentSectionAmount, nSectionResumeTime = (FP.ToInt)(clsSkillInfo.currentResumeTime), nUseTimeHint = (FP.ToInt)(clsSkillInfo.currentUseTimeHint), nEnergy = (FP.ToInt)(clsSkillInfo.currentEnergy)})
        end
      end
    end
    do
      -- DECOMPILER ERROR at PC122: Confused about usage of register: R16 in 'UnsetPending'

      ;
      ((self.mapCharacterTempData).effectInfo)[charTid] = {
mapEffect = {}
}
      local tbClsEfts = (AdventureModuleHelper.GetEffectList)(playerids[i])
      if tbClsEfts ~= nil then
        local nEftCount = tbClsEfts.Count - 1
        for k = 0, nEftCount do
          local eftInfo = tbClsEfts[k]
          local mapEft = (ConfigTable.GetData_Effect)((eftInfo.effectConfig).Id)
          if mapEft == nil then
            return 
          end
          local nCd = (eftInfo.CD).RawValue
          -- DECOMPILER ERROR at PC157: Confused about usage of register: R25 in 'UnsetPending'

          if mapEft.Remove then
            ((((self.mapCharacterTempData).effectInfo)[charTid]).mapEffect)[(eftInfo.effectConfig).Id] = {nCount = 0, nCd = nCd}
          end
        end
      end
      do
        if self.mapEffectTriggerCount ~= nil then
          for nEftId,nCount in pairs(self.mapEffectTriggerCount) do
            -- DECOMPILER ERROR at PC180: Confused about usage of register: R22 in 'UnsetPending'

            if ((((self.mapCharacterTempData).effectInfo)[charTid]).mapEffect)[nEftId] == nil then
              ((((self.mapCharacterTempData).effectInfo)[charTid]).mapEffect)[nEftId] = {nCount = nCount, nCd = 0}
            else
              -- DECOMPILER ERROR at PC187: Confused about usage of register: R22 in 'UnsetPending'

              ;
              (((((self.mapCharacterTempData).effectInfo)[charTid]).mapEffect)[nEftId]).nCount = nCount
            end
          end
        end
        do
          local tbBuffInfo = (AdventureModuleHelper.GetEntityBuffList)(playerids[i])
          -- DECOMPILER ERROR at PC196: Confused about usage of register: R18 in 'UnsetPending'

          ;
          ((self.mapCharacterTempData).buffInfo)[charTid] = {}
          if tbBuffInfo ~= nil then
            local nBuffCount = tbBuffInfo.Count - 1
            for l = 0, nBuffCount do
              local eftInfo = tbBuffInfo[l]
              local mapBuff = (ConfigTable.GetData_Buff)((eftInfo.buffConfig).Id)
              if mapBuff == nil then
                return 
              end
              if mapBuff.NotRemove then
                (table.insert)(((self.mapCharacterTempData).buffInfo)[charTid], {Id = (eftInfo.buffConfig).Id, CD = (eftInfo:GetBuffLeftTime()).RawValue, nNum = eftInfo:GetBuffNum()})
              end
            end
          end
          do
            do
              -- DECOMPILER ERROR at PC241: Confused about usage of register: R18 in 'UnsetPending'

              ;
              ((self.mapCharacterTempData).stateInfo)[charTid] = {nState = nStatus, nStateTime = nStatusTime, jsonStr = jsonString}
              -- DECOMPILER ERROR at PC247: Confused about usage of register: R18 in 'UnsetPending'

              if tbAmmo ~= nil then
                ((self.mapCharacterTempData).ammoInfo)[charTid] = {}
                -- DECOMPILER ERROR at PC251: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nCurAmmo = nAmmoType
                -- DECOMPILER ERROR at PC256: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmo1 = tbAmmo[0]
                -- DECOMPILER ERROR at PC261: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmo2 = tbAmmo[1]
                -- DECOMPILER ERROR at PC266: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmo3 = tbAmmo[2]
                -- DECOMPILER ERROR at PC274: Confused about usage of register: R18 in 'UnsetPending'

                if tbAmmo.Length >= 6 then
                  (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax1 = tbAmmo[3]
                  -- DECOMPILER ERROR at PC279: Confused about usage of register: R18 in 'UnsetPending'

                  ;
                  (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax2 = tbAmmo[4]
                  -- DECOMPILER ERROR at PC284: Confused about usage of register: R18 in 'UnsetPending'

                  ;
                  (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax3 = tbAmmo[5]
                else
                  -- DECOMPILER ERROR at PC289: Confused about usage of register: R18 in 'UnsetPending'

                  ;
                  (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax1 = 0
                  -- DECOMPILER ERROR at PC293: Confused about usage of register: R18 in 'UnsetPending'

                  ;
                  (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax2 = 0
                  -- DECOMPILER ERROR at PC297: Confused about usage of register: R18 in 'UnsetPending'

                  ;
                  (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax3 = 0
                end
              end
              -- DECOMPILER ERROR at PC306: Confused about usage of register: R18 in 'UnsetPending'

              if charTid == (self.tbTeam)[1] then
                (self.mapCharacterTempData).shieldList = (AdventureModuleHelper.GetEntityShieldList)(playerids[i])
              end
              -- DECOMPILER ERROR at PC307: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC307: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC307: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC307: LeaveBlock: unexpected jumping out DO_STMT

            end
          end
        end
      end
    end
  end
  local mapCharHp = (self.GetActorHp)()
  for nTid,mapCharInfo in pairs(self.mapActorInfo) do
    if mapCharHp[nTid] ~= nil then
      mapCharInfo.nHp = mapCharHp[nTid]
    end
  end
  local data, nDataLength = EncodeTempDataJson(self.mapCharacterTempData)
  return data, nDataLength
end

StarTowerLevelData.CalCharFixedEffect = function(self, nCharId, bMainChar, mapDisc)
  -- function num : 0_46 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  self:CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar, mapDisc)
  return stActorInfo
end

StarTowerLevelData.ResetAmmo = function(self)
  -- function num : 0_47 , upvalues : _ENV
  if (self.mapCharacterTempData).ammoInfo ~= nil then
    local ret = {}
    for nCharId,mapAmmo in pairs((self.mapCharacterTempData).ammoInfo) do
      local stInfo = (CS.Lua2CSharpInfo_ActorAmmoInfo)()
      local tbAmmoCount = {mapAmmo.nAmmo1, mapAmmo.nAmmo2, mapAmmo.nAmmo3, mapAmmo.nAmmoMax1 or 0, mapAmmo.nAmmoMax2 or 0, mapAmmo.nAmmoMax3 or 0}
      stInfo.actorID = nCharId
      stInfo.ammoCount = tbAmmoCount
      stInfo.ammoType = mapAmmo.nCurAmmo
      ;
      (table.insert)(ret, stInfo)
    end
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAmmoInfos, ret)
  end
end

StarTowerLevelData.ResetSommon = function(self)
  -- function num : 0_48 , upvalues : _ENV
  if (self.mapCharacterTempData).sommonInfo ~= nil then
    safe_call_cs_func((CS.AdventureModuleHelper).SetSummonMonsters, (self.mapCharacterTempData).sommonInfo)
  end
end

StarTowerLevelData.ResetEffect = function(self)
  -- function num : 0_49 , upvalues : _ENV
  local retPotential = {}
  local retDisc = {}
  local retFateCard = {}
  local retNote = {}
  local mapCharEffect = {}
  for _,nCharId in ipairs(self.tbTeam) do
    mapCharEffect[nCharId] = {}
    -- DECOMPILER ERROR at PC26: Confused about usage of register: R11 in 'UnsetPending'

    if ((self.mapCharData)[nCharId]).tbAffinityeffectIds ~= nil or not {} then
      (mapCharEffect[nCharId])[(AllEnum.EffectType).Affinity] = ((self.mapCharData)[nCharId]).tbAffinityeffectIds
      -- DECOMPILER ERROR at PC42: Confused about usage of register: R11 in 'UnsetPending'

      if ((self.mapCharData)[nCharId]).tbTalentEffect ~= nil or not {} then
        (mapCharEffect[nCharId])[(AllEnum.EffectType).Talent] = ((self.mapCharData)[nCharId]).tbTalentEffect
        -- DECOMPILER ERROR at PC58: Confused about usage of register: R11 in 'UnsetPending'

        if ((self.mapCharData)[nCharId]).tbEquipmentEffect ~= nil or not {} then
          (mapCharEffect[nCharId])[(AllEnum.EffectType).Equipment] = ((self.mapCharData)[nCharId]).tbEquipmentEffect
          local nCount = 0
          if (self._mapPotential)[nCharId] ~= nil then
            for nPotentialId,nPotentialCount in pairs((self._mapPotential)[nCharId]) do
              if (self.mapPotentialAddLevel)[nCharId] ~= nil and ((self.mapPotentialAddLevel)[nCharId])[nPotentialId] ~= nil then
                nPotentialCount = nPotentialCount + ((self.mapPotentialAddLevel)[nCharId])[nPotentialId]
              end
              -- DECOMPILER ERROR at PC94: Confused about usage of register: R17 in 'UnsetPending'

              if (mapCharEffect[nCharId])[(AllEnum.EffectType).Potential] == nil then
                (mapCharEffect[nCharId])[(AllEnum.EffectType).Potential] = {}
              end
              local mapPotentialCfgData = (ConfigTable.GetData)("Potential", nPotentialId)
              if mapPotentialCfgData == nil then
                printError("Potential CfgData Missing:" .. nPotentialId)
              else
                -- DECOMPILER ERROR at PC117: Confused about usage of register: R18 in 'UnsetPending'

                ;
                ((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId] = {
{}
, nPotentialCount}
                if mapPotentialCfgData.EffectId1 ~= 0 then
                  (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId1)
                end
                if mapPotentialCfgData.EffectId2 ~= 0 then
                  (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId2)
                end
                if mapPotentialCfgData.EffectId3 ~= 0 then
                  (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId3)
                end
                if mapPotentialCfgData.EffectId4 ~= 0 then
                  (table.insert)((((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential])[nPotentialId])[1], mapPotentialCfgData.EffectId4)
                end
              end
            end
          end
          do
            -- DECOMPILER ERROR at PC176: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC176: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC176: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC176: LeaveBlock: unexpected jumping out IF_STMT

            -- DECOMPILER ERROR at PC176: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC176: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
  local mapDiscEffect = {}
  for nDiscId,mapDiscData in pairs(self.mapDiscData) do
    if (table.indexof)(self.tbDisc, nDiscId) <= 3 then
      local tbDiscEft = mapDiscData:GetSkillEffect(self._mapNote)
      mapDiscEffect[mapDiscData.nId] = tbDiscEft
    end
  end
  local mapFateCardEffect = {}
  for nFateCardId,tbRemain in pairs(self._mapFateCard) do
    if tbRemain[1] ~= 0 and tbRemain[2] ~= 0 then
      local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
      if mapFateCardCfgData == nil then
        printError("FateCardCfgData Missing:" .. nFateCardId)
      else
        if mapFateCardCfgData.MethodMode == (GameEnum.fateCardMethodMode).ClientFateCard and mapFateCardCfgData.ClientEffect ~= 0 then
          mapFateCardEffect[nFateCardId] = {}
          ;
          (table.insert)(mapFateCardEffect[nFateCardId], {mapFateCardCfgData.ClientEffect, tbRemain[1]})
          for _,nEftId in ipairs(mapFateCardCfgData.ClientExEffect) do
            (table.insert)(mapFateCardEffect[nFateCardId], {nEftId, -1})
          end
        end
      end
    end
  end
  local mapNoteEffect = {}
  for nNoteId,nNoteCount in pairs(self._mapNote) do
    if nNoteCount > 0 then
      local mapNoteCfgData = (ConfigTable.GetData)("SubNoteSkill", nNoteId)
      if mapNoteCfgData == nil then
        printError("NoteCfgData Missing:" .. nNoteId)
      else
        mapNoteEffect[nNoteId] = {}
        for _,nEftId in ipairs(mapNoteCfgData.EffectId) do
          (table.insert)(mapNoteEffect[nNoteId], {nEftId, nNoteCount})
        end
      end
    end
  end
  for _,nCharId in ipairs(self.tbTeam) do
    if (mapCharEffect[nCharId])[(AllEnum.EffectType).Affinity] ~= nil then
      for _,nEftId in ipairs((mapCharEffect[nCharId])[(AllEnum.EffectType).Affinity]) do
        local nEftUseCount = (self.mapEffectTriggerCount)[nEftId]
        if nEftUseCount == nil then
          nEftUseCount = 0
        end
        ;
        (UTILS.AddEffect)(nCharId, nEftId, 0, nEftUseCount)
      end
    end
    do
      if (mapCharEffect[nCharId])[(AllEnum.EffectType).Talent] ~= nil then
        for _,nEftId in ipairs((mapCharEffect[nCharId])[(AllEnum.EffectType).Talent]) do
          local nEftUseCount = (self.mapEffectTriggerCount)[nEftId]
          if nEftUseCount == nil then
            nEftUseCount = 0
          end
          ;
          (UTILS.AddEffect)(nCharId, nEftId, 0, nEftUseCount)
        end
      end
      do
        if (mapCharEffect[nCharId])[(AllEnum.EffectType).Equipment] ~= nil then
          for _,nEftId in ipairs((mapCharEffect[nCharId])[(AllEnum.EffectType).Equipment]) do
            local nEftUseCount = (self.mapEffectTriggerCount)[nEftId]
            if nEftUseCount == nil then
              nEftUseCount = 0
            end
            ;
            (UTILS.AddEffect)(nCharId, nEftId, 0, nEftUseCount)
          end
        end
        do
          if (mapCharEffect[nCharId])[(AllEnum.EffectType).Potential] ~= nil then
            for nPotentialId,tbPotentialData in pairs((mapCharEffect[nCharId])[(AllEnum.EffectType).Potential]) do
              for _,nEftId in ipairs(tbPotentialData[1]) do
                if retPotential[nPotentialId] == nil then
                  retPotential[nPotentialId] = {}
                end
                local nEftUseCount = (self.mapEffectTriggerCount)[nEftId]
                if nEftUseCount == nil then
                  nEftUseCount = 0
                end
                local nEftUid = (UTILS.AddEffect)(nCharId, nEftId, tbPotentialData[2], nEftUseCount)
                ;
                (table.insert)(retPotential[nPotentialId], {nEftUid, nCharId})
              end
            end
          end
          do
            for nDiscId,tbDiscEft in pairs(mapDiscEffect) do
              if retDisc[nDiscId] == nil then
                retDisc[nDiscId] = {}
              end
              for _,mapEft in ipairs(tbDiscEft) do
                -- DECOMPILER ERROR at PC454: Confused about usage of register: R24 in 'UnsetPending'

                if (retDisc[nDiscId])[mapEft[1]] == nil then
                  (retDisc[nDiscId])[mapEft[1]] = {}
                end
                local nEftUseCount = (self.mapEffectTriggerCount)[mapEft[1]]
                if nEftUseCount == nil then
                  nEftUseCount = 0
                end
                local nEftUid = (UTILS.AddEffect)(nCharId, mapEft[1], mapEft[2], nEftUseCount)
                ;
                (table.insert)((retDisc[nDiscId])[mapEft[1]], {nEftUid, nCharId})
              end
            end
            for nFateCardId,tbFateCardEft in pairs(mapFateCardEffect) do
              if retFateCard[nFateCardId] == nil then
                retFateCard[nFateCardId] = {}
              end
              for _,tbEft in ipairs(tbFateCardEft) do
                local nEftUid = (UTILS.AddFateCardEft)(nCharId, tbEft[1], tbEft[2])
                if retFateCard[tbEft[1]] == nil then
                  retFateCard[tbEft[1]] = {nFateCardId = nFateCardId, 
tbEftUid = {}
}
                end
                ;
                (table.insert)((retFateCard[tbEft[1]]).tbEftUid, {nEftUid, nCharId})
              end
            end
            for nNoteId,tbNoteEft in pairs(mapNoteEffect) do
              if retNote[nNoteId] == nil then
                retNote[nNoteId] = {}
              end
              for _,mapEft in ipairs(tbNoteEft) do
                -- DECOMPILER ERROR at PC546: Confused about usage of register: R24 in 'UnsetPending'

                if (retNote[nNoteId])[mapEft[1]] == nil then
                  (retNote[nNoteId])[mapEft[1]] = {}
                end
                local nEftUseCount = (self.mapEffectTriggerCount)[mapEft[1]]
                if nEftUseCount == nil then
                  nEftUseCount = 0
                end
                local nEftUid = (UTILS.AddEffect)(nCharId, mapEft[1], mapEft[2], nEftUseCount)
                ;
                (table.insert)((retNote[nNoteId])[mapEft[1]], {nEftUid, nCharId})
              end
            end
            do
              -- DECOMPILER ERROR at PC574: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC574: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC574: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC574: LeaveBlock: unexpected jumping out DO_STMT

            end
          end
        end
      end
    end
  end
  return retPotential, retDisc, retFateCard, retNote
end

StarTowerLevelData.ResetPersonalPerk = function(self)
  -- function num : 0_50 , upvalues : _ENV
  for nCharId,mapPotential in pairs(self._mapPotential) do
    local tbStInfo = {}
    for nPotentialId,nCount in pairs(mapPotential) do
      if (self.mapPotentialAddLevel)[nCharId] ~= nil and ((self.mapPotentialAddLevel)[nCharId])[nPotentialId] ~= nil then
        nCount = nCount + ((self.mapPotentialAddLevel)[nCharId])[nPotentialId]
      end
      local stPerkInfo = (CS.Lua2CSharpInfo_TPPerkInfo)()
      stPerkInfo.perkId = nPotentialId
      stPerkInfo.nCount = nCount
      ;
      (table.insert)(tbStInfo, stPerkInfo)
    end
    safe_call_cs_func((CS.AdventureModuleHelper).ChangePersonalPerkIds, tbStInfo, nCharId)
  end
end

StarTowerLevelData.ChangePotentialCount = function(self, nPotentialId, nChangeCount)
  -- function num : 0_51 , upvalues : _ENV
  local mapPotential = (ConfigTable.GetData)("Potential", nPotentialId)
  if mapPotential ~= nil then
    local nCharId = mapPotential.CharId
    local stPerkInfo = (CS.Lua2CSharpInfo_TPPerkInfo)()
    stPerkInfo.perkId = nPotentialId
    stPerkInfo.nCount = nChangeCount
    safe_call_cs_func((CS.AdventureModuleHelper).ChangePersonalPerkIds, {stPerkInfo}, nCharId, true)
  end
end

StarTowerLevelData.ResetFateCard = function(self)
  -- function num : 0_52 , upvalues : _ENV
  local tbFCInfo = {}
  for i,v in pairs(self._mapFateCard) do
    if v[1] ~= 0 and v[2] ~= 0 then
      local cardInfo = (ConfigTable.GetData)("FateCard", i)
      if cardInfo == nil then
        return 
      end
      if cardInfo.MethodMode == (GameEnum.fateCardMethodMode).LuaFateCard and cardInfo.ThemeType ~= 0 then
        local fcInfo = (CS.Lua2CSharpInfo_FateCardThemeInfo)()
        fcInfo.theme = cardInfo.ThemeType
        fcInfo.rank = cardInfo.ThemeValue
        fcInfo.triggerTypes = cardInfo.ThemeTriggerType
        fcInfo.operateType = 1
        ;
        (table.insert)(tbFCInfo, fcInfo)
      end
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetFateCardThemes, tbFCInfo)
end

StarTowerLevelData.ResetFateCardRoomEft = function(self)
  -- function num : 0_53 , upvalues : _ENV
  local roomEffect = {}
  for i,v in pairs(self._mapFateCard) do
    if v[1] ~= 0 and v[2] ~= 0 then
      local cardInfo = (ConfigTable.GetData)("FateCard", i)
      if cardInfo == nil then
        return 
      end
      if cardInfo.MethodMode == (GameEnum.fateCardMethodMode).FloorBuffFateCard then
        (table.insert)(roomEffect, cardInfo.ClientEffect)
      end
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).RefreshRoomEffects, roomEffect)
end

StarTowerLevelData.ResetNoteInfo = function(self)
  -- function num : 0_54 , upvalues : _ENV
  local tbNoteInfo = {}
  for i,v in pairs(self._mapNote) do
    local noteInfo = (CS.Lua2CSharpInfo_NoteInfo)()
    noteInfo.noteId = i
    noteInfo.noteCount = v
    ;
    (table.insert)(tbNoteInfo, noteInfo)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetNoteInfo, tbNoteInfo)
end

StarTowerLevelData.ResetDiscInfo = function(self)
  -- function num : 0_55 , upvalues : _ENV
  local tbDiscInfo = {}
  for nDiscId,mapDiscData in pairs(self.mapDiscData) do
    if (table.indexof)(self.tbDisc, nDiscId) <= 3 and mapDiscData ~= nil then
      local discInfo = mapDiscData:GetDiscInfo(self._mapNote)
      ;
      (table.insert)(tbDiscInfo, discInfo)
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetDiscInfo, tbDiscInfo)
end

StarTowerLevelData.SetActorHP = function(self)
  -- function num : 0_56 , upvalues : _ENV
  local tbActorInfo = {}
  if self.mapActorInfo == nil then
    return 
  end
  for nTid,mapCharInfo in pairs(self.mapActorInfo) do
    local stCharInfo = (CS.Lua2CSharpInfo_ActorAttribute)()
    stCharInfo.actorID = nTid
    stCharInfo.curHP = mapCharInfo.nHp
    ;
    (table.insert)(tbActorInfo, stCharInfo)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).ResetActorAttributes, tbActorInfo)
end

StarTowerLevelData.ResetBuff = function(self)
  -- function num : 0_57 , upvalues : _ENV
  local ret = {}
  if (self.mapCharacterTempData).buffInfo ~= nil then
    for nCharId,mapBuff in pairs((self.mapCharacterTempData).buffInfo) do
      for _,mapBuffInfo in ipairs(mapBuff) do
        local stBuffInfo = (CS.Lua2CSharpInfo_ResetBuffInfo)()
        stBuffInfo.Id = mapBuffInfo.Id
        stBuffInfo.Cd = mapBuffInfo.CD
        stBuffInfo.buffNum = mapBuffInfo.nNum
        if ret[nCharId] == nil then
          ret[nCharId] = {}
        end
        ;
        (table.insert)(ret[nCharId], stBuffInfo)
      end
    end
  end
  do
    safe_call_cs_func((CS.AdventureModuleHelper).ResetBuff, ret)
  end
end

StarTowerLevelData.ResetSkill = function(self)
  -- function num : 0_58 , upvalues : _ENV, FP
  local ret = {}
  if (self.mapCharacterTempData).skillInfo ~= nil then
    for _,skillInfo in ipairs((self.mapCharacterTempData).skillInfo) do
      local stSkillInfo = (CS.Lua2CSharpInfo_ResetSkillInfo)()
      stSkillInfo.skillId = skillInfo.nSkillId
      stSkillInfo.currentSectionAmount = skillInfo.nSectionAmount
      stSkillInfo.cd = ((FP.FromFloat)(skillInfo.nCd)).RawValue
      stSkillInfo.currentResumeTime = ((FP.FromFloat)(skillInfo.nSectionResumeTime)).RawValue
      stSkillInfo.currentUseTimeHint = ((FP.FromFloat)(skillInfo.nUseTimeHint)).RawValue
      stSkillInfo.energy = ((FP.FromFloat)(skillInfo.nEnergy)).RawValue
      if ret[skillInfo.nCharId] == nil then
        ret[skillInfo.nCharId] = {}
      end
      ;
      (table.insert)(ret[skillInfo.nCharId], stSkillInfo)
    end
  end
  do
    safe_call_cs_func((CS.AdventureModuleHelper).ResetActorSkillInfo, ret)
  end
end

StarTowerLevelData.SetCharStatus = function(self)
  -- function num : 0_59 , upvalues : _ENV
  local nStatus = 0
  local nStatusTime = 0
  local tbActorInfo = {}
  local jsonStr = ""
  for _,nTid in ipairs(self.tbTeam) do
    local stCharInfo = (CS.Lua2CSharpInfo_ActorStatus)()
    if (self.mapCharacterTempData).stateInfo ~= nil and ((self.mapCharacterTempData).stateInfo)[nTid] ~= nil then
      nStatus = (((self.mapCharacterTempData).stateInfo)[nTid]).nState
      nStatusTime = (((self.mapCharacterTempData).stateInfo)[nTid]).nStateTime
      jsonStr = (((self.mapCharacterTempData).stateInfo)[nTid]).jsonStr
    end
    stCharInfo.actorID = nTid
    stCharInfo.status = nStatus
    stCharInfo.specialStatusTime = nStatusTime
    stCharInfo.localDataJson = jsonStr
    ;
    (table.insert)(tbActorInfo, stCharInfo)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetActorStatus, tbActorInfo)
end

StarTowerLevelData.ReBattle = function(self)
  -- function num : 0_60 , upvalues : DecodeTempDataJson, _ENV
  if self.cachedRoomMeta == nil then
    return false
  end
  if self.cachedClientData ~= nil then
    self.mapCharacterTempData = DecodeTempDataJson(self.cachedClientData)
    self.mapEffectTriggerCount = {}
    if (self.mapCharacterTempData).effectInfo ~= nil then
      for _,mapData in pairs((self.mapCharacterTempData).effectInfo) do
        if mapData.mapEffect ~= nil then
          for nEftId,value in pairs(mapData.mapEffect) do
            -- DECOMPILER ERROR at PC32: Confused about usage of register: R11 in 'UnsetPending'

            (self.mapEffectTriggerCount)[nEftId] = value.nCount
          end
        end
      end
    end
  end
  do
    if self.curRoom ~= nil then
      (self.curRoom):Exit()
      self.curRoom = nil
    end
    local roomClass = self:GetcurRoom()
    self.curRoom = (roomClass.new)(self, (self.cachedRoomMeta).Cases, (self.cachedRoomMeta).Data)
    local OnLevelUnloadComplete = function()
    -- function num : 0_60_0 , upvalues : _ENV, self, OnLevelUnloadComplete
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, OnLevelUnloadComplete)
    self:ResetCharacter()
  end

    ;
    (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, OnLevelUnloadComplete)
    safe_call_cs_func((CS.AdventureModuleHelper).ClearCharacterDamageRecord, false)
    ;
    (NovaAPI.DispatchEventWithData)("Level_Restart", nil, {})
    safe_call_cs_func((CS.AdventureModuleHelper).LevelStateChanged, false)
  end
end

StarTowerLevelData.GetRecommondPotential = function(self, tbPotentialData)
  -- function num : 0_61 , upvalues : _ENV
  local tbPotential = {}
  for _,mapData in ipairs(tbPotentialData) do
    (table.insert)(tbPotential, mapData.Id)
  end
  local ret = {}
  local curRarity = 999
  for _,nPotentialId in ipairs(tbPotential) do
    local itemCfg = (ConfigTable.GetData)("Item", nPotentialId)
    if itemCfg ~= nil then
      local nRarity = itemCfg.Rarity
      if itemCfg.Stype == (GameEnum.itemStype).SpecificPotential then
        nRarity = 0
      end
      if nRarity < curRarity then
        ret = {}
        curRarity = nRarity
        ;
        (table.insert)(ret, nPotentialId)
      else
        if nRarity == curRarity then
          (table.insert)(ret, nPotentialId)
        end
      end
    end
  end
  if #ret < 2 then
    return ret
  end
  local ret1 = {}
  local nCurCharId = 0
  local nCurCount = -1
  local GetCharacterPotentialCount = function(nCharId)
    -- function num : 0_61_0 , upvalues : self, _ENV
    local ret = 0
    if (self._mapPotential)[nCharId] ~= nil then
      for _,nCount in pairs((self._mapPotential)[nCharId]) do
        ret = ret + nCount
      end
    end
    do
      return ret
    end
  end

  for _,nPotentialId in ipairs(ret) do
    local potentialCfg = (ConfigTable.GetData)("Potential", nPotentialId)
    if potentialCfg ~= nil then
      local nCharId = potentialCfg.CharId
      local nCount = GetCharacterPotentialCount(nCharId)
      if nCurCount < 0 then
        nCurCharId = nCharId
        nCurCount = nCount
        ;
        (table.insert)(ret1, nPotentialId)
      else
        if nCharId ~= nCurCharId and nCount < nCurCount then
          ret1 = {}
          nCurCharId = nCharId
          nCurCount = nCount
          ;
          (table.insert)(ret1, nPotentialId)
        else
          ;
          (table.insert)(ret1, nPotentialId)
        end
      end
    end
  end
  if #ret1 < 1 then
    return ret
  end
  if #ret1 < 2 then
    return ret1
  end
  local ret2 = {}
  local nCurBuildCount = -1
  local bHasBuild = false
  local GetPotentialBuildCount = function(nPotnetialId)
    -- function num : 0_61_1 , upvalues : _ENV, self
    local ret = 0
    local retBuild = 0
    local potentialCfg = (ConfigTable.GetData)("Potential", nPotnetialId)
    if potentialCfg ~= nil then
      retBuild = potentialCfg.Build
      local nCharId = potentialCfg.CharId
      for nId,nCount in pairs((self._mapPotential)[nCharId]) do
        local mapCfg = (ConfigTable.GetData)("Potential", nId)
        local potentialItemCfg = (ConfigTable.GetData_Item)(nId)
        if mapCfg ~= nil and potentialItemCfg ~= nil then
          local param = 1
          if potentialItemCfg.Stype == (GameEnum.itemStype).SpecificPotential then
            param = 99
          end
          if mapCfg.Build == potentialCfg.Build then
            ret = ret + param
          end
        end
      end
    end
    do
      return ret, retBuild
    end
  end

  for _,nPotentialId in ipairs(ret1) do
    local nCount, nBuild = GetPotentialBuildCount(nPotentialId)
    if nCurBuildCount < 0 and nBuild ~= 0 then
      (table.insert)(ret2, nPotentialId)
      nCurBuildCount = nCount
      bHasBuild = nBuild ~= (GameEnum.potentialBuild).PotentialBuildCommon
    else
      -- DECOMPILER ERROR at PC157: Unhandled construct in 'MakeBoolean' P1

      if bHasBuild and nBuild ~= (GameEnum.potentialBuild).PotentialBuildCommon then
        if nCount == nCurBuildCount then
          (table.insert)(ret2, nPotentialId)
        elseif nCurBuildCount < nCount then
          ret2 = {}
          ;
          (table.insert)(ret2, nPotentialId)
          nCurBuildCount = nCount
          bHasBuild = nBuild ~= (GameEnum.potentialBuild).PotentialBuildCommon
        end
      end
    end
    if nBuild == (GameEnum.potentialBuild).PotentialBuildCommon then
      if nCount == nCurBuildCount then
        (table.insert)(ret2, nPotentialId)
      elseif nCurBuildCount < nCount then
        ret2 = {}
        ;
        (table.insert)(ret2, nPotentialId)
        nCurBuildCount = nCount
      end
    else
      ret2 = {}
      ;
      (table.insert)(ret2, nPotentialId)
      nCurBuildCount = nCount
      bHasBuild = true
    end
  end
  if #ret2 < 1 then
    return ret1
  end
  if #ret2 < 2 then
    return ret2
  end
  local ret3 = {}
  local curLessPotential = -1
  for _,nPotentialId in ipairs(ret2) do
    local potentialCfg = (ConfigTable.GetData)("Potential", nPotentialId)
    if potentialCfg ~= nil then
      local nCharId = potentialCfg.CharId
      local nCurCount = 0
      if (self._mapPotential)[nCharId] ~= nil and ((self._mapPotential)[nCharId])[nPotentialId] ~= nil then
        nCurCount = ((self._mapPotential)[nCharId])[nPotentialId]
      end
      if curLessPotential < 0 then
        (table.insert)(ret3, nPotentialId)
        curLessPotential = nCurCount
      elseif nCurCount == curLessPotential then
        (table.insert)(ret3, nPotentialId)
      elseif nCurCount < curLessPotential then
        ret3 = {}
        ;
        (table.insert)(ret3, nPotentialId)
        curLessPotential = nCurCount
      end
    end
  end
  if #ret3 < 1 then
    return ret2
  end
  do return ret3 end
  -- DECOMPILER ERROR: 15 unprocessed JMP targets
end

return StarTowerLevelData

