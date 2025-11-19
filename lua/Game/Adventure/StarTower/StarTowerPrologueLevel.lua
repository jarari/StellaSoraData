local LocalData = require("GameCore.Data.LocalData")
local SDKManager = (CS.SDKManager).Instance
local PB = require("pb")
local mapPrologueConfig = {nDifficulty = 1, 
tbStage = {99901}
, 
FloorNum = {5}
, 
tbTeam = {103, 112, 111}
, 
tbDiscs = {}
, 
tbEvent = {
{}
, 
{}
, 
{
{Id = 3, 
SelectPotentialCase = {
Infos = {
{Tid = 510307, Level = 1}
, 
{Tid = 510302, Level = 1}
, 
{Tid = 510312, Level = 1}
}
}
}
}
, 
{
{Id = 4, 
SelectPotentialCase = {
Infos = {
{Tid = 510341, Level = 1}
, 
{Tid = 510301, Level = 1}
, 
{Tid = 510308, Level = 1}
}
}
}
, 
{Id = 5, 
SelectPotentialCase = {
Infos = {
{Tid = 511125, Level = 1}
, 
{Tid = 511121, Level = 1}
, 
{Tid = 511130, Level = 1}
}
}
}
, 
{Id = 6, 
SelectPotentialCase = {
Infos = {
{Tid = 511227, Level = 1}
, 
{Tid = 511221, Level = 1}
, 
{Tid = 511226, Level = 1}
}
}
}
}
, 
{}
}
, 
tbButton = {
{"Fire2", "Fire4", "ActorSwitch1", "ActorSwitch2", "SwitchWithUltra1", "SwitchWithUltra2"}
, 
{"Fire1", "Fire4", "ActorSwitch1", "ActorSwitch2", "SwitchWithUltra1", "SwitchWithUltra2"}
, 
{"Fire4", "ActorSwitch1", "ActorSwitch2", "SwitchWithUltra1", "SwitchWithUltra2"}
, 
{"ActorSwitch1", "ActorSwitch2", "SwitchWithUltra1", "SwitchWithUltra2"}
, 
{}
}
, 
tbLevel = {
{}
, 
{}
, 
{nLevel = 2, nExp = 1000}
, 
{nLevel = 3, nExp = 1500}
, 
{nLevel = 4, nExp = 1800}
, 
{}
}
, sAvgId1 = Settings.sPrologueAvgId1, sVideoName = Settings.sPrologueVideo, sAvgId2 = Settings.sPrologueAvgId2, 
ClearVoice = {"", "", "special_effect_slowmotion", "special_effect_slowmotion", "special_effect_slowmotion"}
, 
tEventIndex = {[2] = 6, [3] = 7, [4] = 8, [5] = 9}
}
local StarTowerPrologueLevel = class("StarTowerPrologueLevel")
local LocalStarTowerDataKey = "StarTowerData"
local RapidJson = require("rapidjson")
local PATH = "Game.Adventure.StarTower.StarTowerRoom."
local mapProcCtrl = {[(GameEnum.starTowerRoomType).BattleRoom] = "BattleRoom", [(GameEnum.starTowerRoomType).EliteBattleRoom] = "BattleRoom", [(GameEnum.starTowerRoomType).BossRoom] = "BattleRoom", [(GameEnum.starTowerRoomType).FinalBossRoom] = "BattleRoom", [(GameEnum.starTowerRoomType).DangerRoom] = "BattleRoom", [(GameEnum.starTowerRoomType).HorrorRoom] = "BattleRoom"}
local mapEventConfig = {takeEffect = "OnEvent_TakeEffect", LoadLevelRefresh = "OnEvent_LoadLevelRefresh", AdventureModuleEnter = "OnEvent_AdventureModuleEnter", [EventId.StarTowerMap] = "OnEvent_OpenStarTowerMap", AbandonStarTower = "OnEvent_AbandonStarTower", [EventId.StarTowerDepot] = "OnEvent_OpenStarTowerDepot", FreezeFrameEnd = "OnEvent_FreezeFrameEnd", [EventId.TransAnimOutClear] = "OnEvent_TransAnimOutClear"}
local EncodeTempData = function(mapData)
  -- function num : 0_0 , upvalues : _ENV
  local stTempData = (CS.StarTowerTempData)(1)
  local stCharacter = {}
  if mapData.effectInfo ~= nil then
    for nCharId,mapEffect in pairs(mapData.effectInfo) do
      if stCharacter[nCharId] == nil then
        stCharacter[nCharId] = (CS.StarTowerCharacter)(nCharId)
      end
      for nEtfId,mapEft in pairs(mapEffect.mapEffect) do
        ((stCharacter[nCharId]).tbEffect):Add((CS.StarTowerEffect)(nEtfId, mapEft.nCount, mapEft.nCd))
      end
    end
  end
  do
    if mapData.buffInfo ~= nil then
      for nCharId,mapBuff in pairs(mapData.buffInfo) do
        if stCharacter[nCharId] == nil then
          stCharacter[nCharId] = (CS.StarTowerCharacter)(nCharId)
        end
        for _,buffInfo in ipairs(mapBuff) do
          ((stCharacter[nCharId]).tbBuff):Add((CS.StarTowerBuffInfo)(buffInfo.Id, buffInfo.CD, buffInfo.nNum))
        end
      end
    end
    do
      if mapData.stateInfo ~= nil then
        for nCharId,mapStatus in pairs(mapData.stateInfo) do
          if stCharacter[nCharId] == nil then
            stCharacter[nCharId] = (CS.StarTowerCharacter)(nCharId)
          end
          -- DECOMPILER ERROR at PC92: Confused about usage of register: R8 in 'UnsetPending'

          ;
          (stCharacter[nCharId]).stateInfo = (CS.StarTowerState)(mapStatus.nState, mapStatus.nStateTime)
        end
      end
      do
        if mapData.ammoInfo ~= nil then
          for nCharId,mapAmmoInfo in pairs(mapData.ammoInfo) do
            if stCharacter[nCharId] == nil then
              stCharacter[nCharId] = (CS.StarTowerCharacter)(nCharId)
            end
            -- DECOMPILER ERROR at PC121: Confused about usage of register: R8 in 'UnsetPending'

            ;
            (stCharacter[nCharId]).ammoInfo = (CS.StarTowerAmmoInfo)(mapAmmoInfo.nCurAmmo, mapAmmoInfo.nAmmo1, mapAmmoInfo.nAmmo2, mapAmmoInfo.nAmmo3, mapAmmoInfo.nAmmoMax1, mapAmmoInfo.nAmmoMax2, mapAmmoInfo.nAmmoMax3)
          end
        end
        do
          if mapData.skillInfo ~= nil then
            for _,skill in ipairs(mapData.skillInfo) do
              (stTempData.skillInfo):Add((CS.StarTowerSkill)(skill.nCharId, skill.nSkillId, skill.nCd, skill.nSectionAmount, skill.nSectionResumeTime, skill.nUseTimeHint, skill.nEnergy))
            end
          end
          do
            for _,st in pairs(stCharacter) do
              (stTempData.characterInfo):Add(st)
            end
            local jsonData = (NovaAPI.ParseStarTowerData)(stTempData)
            return jsonData
          end
        end
      end
    end
  end
end

local DecodeTempData = function(sJsonChar)
  -- function num : 0_1 , upvalues : _ENV
  local tempData = {}
  tempData.skillInfo = {}
  local stData = (NovaAPI.DecodeStarTowerData)(sJsonChar)
  local nCount = (stData.skillInfo).Count
  for index = 0, nCount - 1 do
    local stSkill = (stData.skillInfo)[index]
    ;
    (table.insert)(tempData.skillInfo, {nCharId = stSkill.nCharId, nSkillId = stSkill.nSkillId, nCd = stSkill.nCd, nSectionAmount = stSkill.nSectionAmount, nSectionResumeTime = stSkill.nSectionResumeTime, nUseTimeHint = stSkill.nUseTimeHint, nEnergy = stSkill.nEnergy})
  end
  return tempData
end

StarTowerPrologueLevel.ctor = function(self, parent)
  -- function num : 0_2 , upvalues : mapPrologueConfig, _ENV
  self.nTransAnimOutClearCount = 1
  self.EnumCase = {Battle = 1, OpenDoor = 2, PotentialSelect = 3, FateCardSelect = 4, NoteSelect = 5, NpcEvent = 6, SelectSpecialPotential = 7, RecoveryHP = 8, NpcRecoveryHP = 9, Hawker = 10, StrengthenMachine = 11, DoorDanger = 12}
  self:BindEvent()
  local BuildStarTowerAllFloorData = function()
    -- function num : 0_2_0 , upvalues : mapPrologueConfig, _ENV
    local ret = {}
    local difficulty = mapPrologueConfig.nDifficulty
    local tbStage = mapPrologueConfig.tbStage
    local tbFloorNum = mapPrologueConfig.FloorNum
    for nIdx,nStageGroupId in ipairs(tbStage) do
      local nFloorNum = tbFloorNum[nIdx]
      if nFloorNum == nil then
        nFloorNum = 99
      end
      for nLevel = 1, nFloorNum do
        local nStageLevelId = nStageGroupId * 100 + nLevel
        if (ConfigTable.GetData)("StarTowerStage", nStageLevelId) ~= nil then
          do
            (table.insert)(ret, (ConfigTable.GetData)("StarTowerStage", nStageLevelId))
            -- DECOMPILER ERROR at PC34: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC34: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
    return ret, difficulty
  end

  self.bPrologue = true
  self.parent = parent
  self.nTowerId = 999
  self.nCurLevel = 1
  self.bRanking = false
  self.tbStarTowerAllLevel = BuildStarTowerAllFloorData()
  self.tbStrengthMachineCost = (ConfigTable.GetConfigNumberArray)(R4_PC25)
end

StarTowerPrologueLevel.Exit = function(self)
  -- function num : 0_3
  self:UnBindEvent()
  if self.curRoom ~= nil then
    (self.curRoom):Exit()
  end
end

StarTowerPrologueLevel.BindEvent = function(self)
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

StarTowerPrologueLevel.UnBindEvent = function(self)
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

StarTowerPrologueLevel.Init = function(self, mapMeta, mapRoom, mapLocalData, sJsonChar)
  -- function num : 0_6 , upvalues : _ENV, DecodeTempData, mapPrologueConfig
  local GetCharacterAttr = function(tbTeam)
    -- function num : 0_6_0 , upvalues : _ENV, self
    local ret = {}
    for idx,nTid in ipairs(tbTeam) do
      local stActorInfo = (self.CalCharFixedEffect)(nTid, idx == 1)
      ret[nTid] = stActorInfo
    end
    do return ret end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

  self._mapNote = {[90011] = 0, [90012] = 0, [90013] = 0, [90014] = 0, [90015] = 0}
  self._mapPotential = {}
  self._mapFateCard = {}
  self._mapItem = {}
  self.nTowerId = mapMeta.Id
  self.nCurLevel = (mapRoom.Data).Floor
  self.tbTeam = {}
  for _,mapChar in ipairs(mapMeta.Chars) do
    (table.insert)(self.tbTeam, mapChar.Id)
    -- DECOMPILER ERROR at PC33: Confused about usage of register: R11 in 'UnsetPending'

    ;
    (self._mapPotential)[mapChar.Id] = {}
  end
  if mapLocalData.mapPotential ~= nil then
    for _,tbData in ipairs(mapLocalData.mapPotential) do
      -- DECOMPILER ERROR at PC51: Confused about usage of register: R11 in 'UnsetPending'

      if (self._mapPotential)[tbData[1]] == nil then
        (self._mapPotential)[tbData[1]] = {}
      end
      -- DECOMPILER ERROR at PC57: Confused about usage of register: R11 in 'UnsetPending'

      ;
      ((self._mapPotential)[tbData[1]])[tbData[2]] = tbData[3]
    end
  end
  do
    if mapLocalData.mapFateCard ~= nil then
      for _,tbData in ipairs(mapLocalData.mapFateCard) do
        -- DECOMPILER ERROR at PC73: Confused about usage of register: R11 in 'UnsetPending'

        (self._mapFateCard)[tbData[1]] = {tbData[2], tbData[3]}
      end
    end
    do
      self.tbDisc = mapMeta.Discs
      self.curRoom = nil
      self.mapFateCardUseCount = {}
      self.nTeamLevel = mapLocalData.nLevel
      self.nTeamExp = mapLocalData.nExp
      self.nTotalTime = 0
      self.mapCharacterTempData = DecodeTempData(sJsonChar)
      self.mapEffectTriggerCount = {}
      self.bBattleEnd = mapLocalData.bBattleEnd
      self.tbEndCaseId = mapLocalData.tbEndCaseId
      self.ActorHp = mapLocalData.ActorHp
      if (self.mapCharacterTempData).effectInfo ~= nil then
        for _,mapData in pairs((self.mapCharacterTempData).effectInfo) do
          if mapData.mapEffect ~= nil then
            for nEftId,value in pairs(mapData.mapEffect) do
              -- DECOMPILER ERROR at PC116: Confused about usage of register: R16 in 'UnsetPending'

              (self.mapEffectTriggerCount)[nEftId] = value.nCount
            end
          end
        end
      end
      do
        self.mapCharAttr = GetCharacterAttr(self.tbTeam)
        self:SetRoguelikeHistoryMapId()
        if #self.tbStarTowerAllLevel == 0 then
          printError("StarTower Config Data Missing:" .. self.nTowerId)
        end
        self.curMapId = (mapRoom.Data).MapId
        self:SetRoguelikeHistoryMapId(self.curMapId)
        local nNextRoomType = 0
        local bFinal = false
        if self.nCurLevel + 1 <= #self.tbStarTowerAllLevel then
          local mapNextStage = (self.tbStarTowerAllLevel)[self.nCurLevel + 1]
          nNextRoomType = mapNextStage.RoomType
        else
          do
            bFinal = true
            safe_call_cs_func((CS.AdventureModuleHelper).EnterStarTowerMap, self.nStarTowerDifficulty, false, bFinal, {0, 0, 0}, nNextRoomType)
            local tbCase = {}
            local mapStage = (self.tbStarTowerAllLevel)[self.nCurLevel]
            if mapStage == nil or self.nCurLevel <= 2 then
              (table.insert)(tbCase, {Id = 1, 
DoorCase = {Floor = 1, Type = 1}
})
              ;
              (table.insert)(tbCase, {Id = 2, 
BattleCase = {TimeLimit = false, FateCard = false}
})
            else
              if mapStage.RoomType == (GameEnum.starTowerRoomType).BattleRoom then
                if self.bBattleEnd then
                  (table.insert)(tbCase, {Id = 1, 
DoorCase = {Floor = 1, Type = 1}
})
                  if (mapPrologueConfig.tbEvent)[self.nCurLevel] ~= nil then
                    for _,mapCaseData in ipairs((mapPrologueConfig.tbEvent)[self.nCurLevel]) do
                      if (table.indexof)(self.tbEndCaseId, mapCaseData.Id) < 1 then
                        (table.insert)(tbCase, mapCaseData)
                      end
                    end
                  end
                else
                  do
                    ;
                    (table.insert)(tbCase, {Id = 1, 
BattleCase = {TimeLimit = false, FateCard = false}
})
                    ;
                    (table.insert)(tbCase, {Id = 1, 
DoorCase = {Floor = 1, Type = 1}
})
                    local roomClass = self:GetcurRoom()
                    self.curRoom = (roomClass.new)(self, tbCase, mapRoom.Data)
                    local tbButton = (mapPrologueConfig.tbButton)[self.nCurLevel]
                    if tbButton == nil then
                      tbButton = {}
                    end
                    safe_call_cs_func((CS.AdventureModuleHelper).SetProloguelBattleMsg, tbButton)
                    ;
                    (NovaAPI.EnterModule)("AdventureModuleScene", true)
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

StarTowerPrologueLevel.CheckDoorCase = function(self)
  -- function num : 0_7 , upvalues : mapPrologueConfig, _ENV
  if (mapPrologueConfig.tbEvent)[self.nCurLevel] ~= nil then
    for _,mapCaseData in ipairs((mapPrologueConfig.tbEvent)[self.nCurLevel]) do
      if (table.indexof)(self.tbEndCaseId, mapCaseData.Id) < 1 then
        return false
      end
    end
  end
  do
    return true
  end
end

StarTowerPrologueLevel.StarTowerInteract = function(self, mapMsgData, callback)
  -- function num : 0_8 , upvalues : mapPrologueConfig, _ENV
  if self.bEnd then
    return 
  end
  local nExpChange = 0
  local nLevelChange = 0
  local nType, mapCase = nil, nil
  local tbChangeFateCard = {}
  local mapChangeNote = {}
  local mapRewardChange = {}
  if self.curRoom ~= nil then
    nType = (self.curRoom):GetCaseById(mapMsgData.Id)
  end
  if nType ~= nil then
    if nType == (self.EnumCase).Battle then
      self.bBattleEnd = true
      local tbCase = {}
      if (mapPrologueConfig.tbEvent)[self.nCurLevel] ~= nil then
        for _,mapCaseData in ipairs((mapPrologueConfig.tbEvent)[self.nCurLevel]) do
          if (table.indexof)(self.tbEndCaseId, mapCaseData.Id) < 1 then
            (table.insert)(tbCase, mapCaseData)
          end
        end
        if (mapPrologueConfig.ClearVoice)[self.nCurLevel] ~= nil and (mapPrologueConfig.ClearVoice)[self.nCurLevel] ~= "" and not (mapMsgData.BattleEndReq).Defeat then
          local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
          WwiseAudioMgr:PostEvent((mapPrologueConfig.ClearVoice)[self.nCurLevel])
        end
      end
      do
        local mapExpData = (mapPrologueConfig.tbLevel)[self.nCurLevel]
        if mapExpData ~= nil then
          if mapExpData.nExp ~= nil then
            nExpChange = mapExpData.nExp - self.nTeamExp
            self.nTeamExp = mapExpData.nExp
          end
          if mapExpData.nLevel ~= nil then
            nLevelChange = mapExpData.nLevel - self.nTeamLevel
            self.nTeamLevel = mapExpData.nLevel
          end
        end
        local mapHp = ((self.GetActorHp)())
        do
          local nHp = nil
          if mapHp ~= nil then
            nHp = mapHp[self.ActorHp]
          end
          if nHp == nil then
            nHp = -1
          end
          self.ActorHp = nHp
          if self:CheckDoorCase() then
            (table.insert)(tbCase, {Id = 2, 
DoorCase = {Floor = 1, Type = 1}
})
          end
          if self.curRoom ~= nil then
            (self.curRoom):SaveCase(tbCase)
          end
          if nType == (self.EnumCase).PotentialSelect then
            local tbPotential = mapCase.Infos
            local nIdx = (mapMsgData.SelectReq).Index + 1
            local mapPotential = tbPotential[nIdx]
            do
              if mapPotential ~= nil then
                local mapChangeInfo = {}
                mapChangeInfo["proto.PotentialInfo"] = {
{Tid = mapPotential.Tid, Level = mapPotential.Level}
}
                tbChangeFateCard = self:ProcessChangeInfo(mapChangeInfo)
              end
              ;
              (table.insert)(self.tbEndCaseId, mapMsgData.Id)
              do
                if self:CheckDoorCase() then
                  local tbCase = {}
                  ;
                  (table.insert)(tbCase, {Id = 2, 
DoorCase = {Floor = 1, Type = 1}
})
                  if self.curRoom ~= nil then
                    (self.curRoom):SaveCase(tbCase)
                  end
                end
                if nType == (self.EnumCase).FateCardSelect then
                  local tbFateCard = mapCase.Ids
                  local nIdx = (mapMsgData.SelectReq).Index + 1
                  local nFateCardId = tbFateCard[nIdx]
                  if nFateCardId ~= nil then
                    local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
                    if mapFateCardCfgData ~= nil then
                      local mapChangeInfo = {}
                      mapChangeInfo["proto.FateCardInfo"] = {
{Tid = nFateCardId, Remain = mapFateCardCfgData.Count, Room = mapFateCardCfgData.ActiveNumber}
}
                      -- DECOMPILER ERROR at PC213: Overwrote pending register: R9 in 'AssignReg'

                      -- DECOMPILER ERROR at PC214: Overwrote pending register: R8 in 'AssignReg'

                      tbChangeFateCard = self:ProcessChangeInfo(mapChangeInfo)
                    end
                  end
                  do
                    ;
                    (table.insert)(self.tbEndCaseId, mapMsgData.Id)
                    do
                      if self:CheckDoorCase() then
                        local tbCase = {}
                        ;
                        (table.insert)(tbCase, {Id = 2, 
DoorCase = {Floor = 1, Type = 1}
})
                        if self.curRoom ~= nil then
                          (self.curRoom):SaveCase(tbCase)
                        end
                      end
                      if callback ~= nil and type(callback) == "function" then
                        local mapNetData = {Id = mapMsgData.Id, 
Settle = {}
}
                        callback(mapNetData, tbChangeFateCard, mapChangeNote, mapRewardChange, nLevelChange, nExpChange)
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

StarTowerPrologueLevel.StarTowerClear = function(self)
  -- function num : 0_9 , upvalues : _ENV, mapPrologueConfig
  local onAvg2End = function()
    -- function num : 0_9_0 , upvalues : _ENV, self, onAvg2End
    (EventManager.Remove)("StoryDialog_DialogEnd", self, onAvg2End)
    ;
    (PlayerData.Guide):SetPlayerLearnReq(1, -1)
    local tab_1 = {}
    ;
    (table.insert)(tab_1, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (NovaAPI.UserEventUpload)("chapter0_complete", tab_1)
    local tbRewardList = {}
    ;
    (table.insert)(tbRewardList, {nId = 103, bNew = true, 
tbItemList = {}
})
    ;
    (table.insert)(tbRewardList, {nId = 111, bNew = true, 
tbItemList = {}
})
    ;
    (table.insert)(tbRewardList, {nId = 112, bNew = true, 
tbItemList = {}
})
    local callback = function()
      -- function num : 0_9_0_0 , upvalues : _ENV
      (NovaAPI.EnterModule)("MainMenuModuleScene", true, 17)
    end

    local tab = {}
    ;
    (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (table.insert)(tab, {"newbie_tutorial_id", "13"})
    ;
    (NovaAPI.UserEventUpload)("newbie_tutorial", tab)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.ReceiveSpecialReward, tbRewardList, callback)
  end

  local onVideoEnd = function()
    -- function num : 0_9_1 , upvalues : _ENV, self, onVideoEnd, mapPrologueConfig, onAvg2End
    (EventManager.Remove)("VIDEO_END", self, onVideoEnd)
    if mapPrologueConfig.sAvgId2 ~= "" and mapPrologueConfig.sAvgId2 ~= nil then
      (EventManager.Add)("StoryDialog_DialogEnd", self, onAvg2End)
      ;
      (EventManager.Hit)("StoryDialog_DialogStart", mapPrologueConfig.sAvgId2)
      local tab_1 = {}
      ;
      (table.insert)(tab_1, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
      ;
      (table.insert)(tab_1, {"newbie_tutorial_id", "12"})
      ;
      (NovaAPI.UserEventUpload)("newbie_tutorial", tab_1)
    else
      do
        onAvg2End()
      end
    end
  end

  local avgEndCallback = function()
    -- function num : 0_9_2 , upvalues : _ENV, self, avgEndCallback, onVideoEnd, mapPrologueConfig
    (EventManager.Remove)("StoryDialog_DialogEnd", self, avgEndCallback)
    ;
    (EventManager.Add)("VIDEO_END", self, onVideoEnd)
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.ProVideoGUI, mapPrologueConfig.sVideoName, false, 0, false, 0, true)
    local tab_1 = {}
    ;
    (table.insert)(tab_1, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (table.insert)(tab_1, {"newbie_tutorial_id", "11"})
    ;
    (NovaAPI.UserEventUpload)("newbie_tutorial", tab_1)
  end

  local levelEndCallback = function()
    -- function num : 0_9_3 , upvalues : self, _ENV, levelEndCallback, mapPrologueConfig, avgEndCallback
    (self.parent):StarTowerEnd()
    ;
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
    if mapPrologueConfig.sAvgId1 ~= "" and mapPrologueConfig.sAvgId1 ~= nil then
      local tab = {}
      ;
      (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
      ;
      (table.insert)(tab, {"newbie_tutorial_id", "10"})
      ;
      (NovaAPI.UserEventUpload)("newbie_tutorial", tab)
      ;
      (EventManager.Add)("StoryDialog_DialogEnd", self, avgEndCallback)
      ;
      (EventManager.Hit)("StoryDialog_DialogStart", mapPrologueConfig.sAvgId1)
    else
      do
        avgEndCallback()
      end
    end
  end

  ;
  (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
  ;
  ((CS.AdventureModuleHelper).LevelStateChanged)(true)
end

StarTowerPrologueLevel.EnterRoom = function(self)
  -- function num : 0_10 , upvalues : _ENV, mapPrologueConfig
  if self.bEnd then
    return 
  end
  if self.curRoom ~= nil then
    (self.curRoom):Exit()
    self.curRoom = nil
  end
  if #self.tbStarTowerAllLevel < self.nCurLevel + 1 then
    self:StarTowerClear()
    return 
  end
  local tbHistoryMapId = self:GetRoguelikeHistoryMapId()
  local tbCharSkinId = {}
  for _,nCharId in ipairs(self.tbTeam) do
    (table.insert)(tbCharSkinId, (PlayerData.Char):GetCharSkinId(nCharId))
  end
  local stRoomMeta = nil
  self.nCurLevel = self.nCurLevel + 1
  self.nTransAnimOutClearCount = 1
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (table.insert)(tab, {"newbie_tutorial_id", tostring((mapPrologueConfig.tEventIndex)[self.nCurLevel])})
  ;
  (NovaAPI.UserEventUpload)("newbie_tutorial", tab)
  local nNextStage = ((self.tbStarTowerAllLevel)[self.nCurLevel]).Id
  stRoomMeta = (CS.Lua2CSharpInfo_FixedRoguelike)(self.nTowerId, nNextStage, tbHistoryMapId, self.tbTeam, tbCharSkinId, 0, "", 0, -1, self.bRanking, 0)
  local floorId = nil
  self.curMapId = safe_call_cs_func2((CS.AdventureModuleHelper).RandomStarTowerMap, stRoomMeta)
  self:SetRoguelikeHistoryMapId(self.curMapId)
  local OnLevelUnloadComplete = function()
    -- function num : 0_10_0 , upvalues : _ENV, self, OnLevelUnloadComplete
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, OnLevelUnloadComplete)
    self:OnEvent_AdventureModuleEnter()
  end

  local NetCallback = function(_, mapNetData)
    -- function num : 0_10_1 , upvalues : _ENV, self, mapPrologueConfig, OnLevelUnloadComplete
    if mapNetData.EnterResp == nil then
      printError("房间数据返回为空")
      return 
    end
    self.bBattleEnd = false
    local nNextRoomType = 0
    local bFinal = false
    if self.nCurLevel + 1 <= #self.tbStarTowerAllLevel then
      local mapNextStage = (self.tbStarTowerAllLevel)[self.nCurLevel + 1]
      nNextRoomType = mapNextStage.RoomType
    else
      do
        bFinal = true
        safe_call_cs_func((CS.AdventureModuleHelper).EnterStarTowerMap, self.nStarTowerDifficulty, false, bFinal, {0, 0, 0}, nNextRoomType)
        local roomClass = self:GetcurRoom()
        self.curRoom = (roomClass.new)(self, ((mapNetData.EnterResp).Room).Cases, ((mapNetData.EnterResp).Room).Data)
        local tbButton = (mapPrologueConfig.tbButton)[self.nCurLevel]
        if tbButton == nil then
          tbButton = {}
        end
        safe_call_cs_func((CS.AdventureModuleHelper).SetProloguelBattleMsg, tbButton)
        ;
        (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, OnLevelUnloadComplete)
        safe_call_cs_func((CS.AdventureModuleHelper).LevelStateChanged, false)
      end
    end
  end

  local mapData = {
EnterResp = {
Room = {
Data = {Floor = self.nCurLevel, MapId = self.curMapId, ParamId = floorId or 0}
, 
Cases = {}
}
}
}
  local mapStage = (self.tbStarTowerAllLevel)[self.nCurLevel]
  if mapStage == nil or self.nCurLevel <= 2 then
    self.bBattleEnd = false
    ;
    (table.insert)(((mapData.EnterResp).Room).Cases, {Id = 1, 
DoorCase = {Floor = 1, Type = 1}
})
    ;
    (table.insert)(((mapData.EnterResp).Room).Cases, {Id = 2, 
BattleCase = {TimeLimit = false, FateCard = false}
})
  else
    if mapStage.RoomType == (GameEnum.starTowerRoomType).BattleRoom then
      self.bBattleEnd = false
      ;
      (table.insert)(((mapData.EnterResp).Room).Cases, {Id = 1, 
BattleCase = {TimeLimit = false, FateCard = false}
})
    else
      self.bBattleEnd = true
      ;
      (table.insert)(((mapData.EnterResp).Room).Cases, {Id = 1, 
DoorCase = {Floor = 1, Type = 1}
})
    end
  end
  for _,mapFateCardRemain in pairs(self._mapFateCard) do
    if mapFateCardRemain[2] ~= nil and mapFateCardRemain[2] > 0 then
      mapFateCardRemain[2] = mapFateCardRemain[2] - 1
    end
  end
  NetCallback(nil, mapData)
  self:SetLocalData()
end

StarTowerPrologueLevel.StarTowerFailed = function(self)
  -- function num : 0_11 , upvalues : _ENV, mapPrologueConfig
  if self.curRoom ~= nil then
    (self.curRoom):Exit()
    self.curRoom = nil
  end
  local tbHistoryMapId = self:GetRoguelikeHistoryMapId()
  local tbCharSkinId = {}
  for _,nCharId in ipairs(self.tbTeam) do
    (table.insert)(tbCharSkinId, (PlayerData.Char):GetCharSkinId(nCharId))
  end
  local stRoomMeta = nil
  local nNextStage = ((self.tbStarTowerAllLevel)[self.nCurLevel]).Id
  stRoomMeta = (CS.Lua2CSharpInfo_FixedRoguelike)(self.nTowerId, nNextStage, tbHistoryMapId, self.tbTeam, tbCharSkinId, 0, "", 0, -1, self.bRanking, 0)
  local floorId = nil
  self.curMapId = safe_call_cs_func2((CS.AdventureModuleHelper).RandomStarTowerMap, stRoomMeta)
  self:SetRoguelikeHistoryMapId(self.curMapId)
  local OnLevelUnloadComplete = function()
    -- function num : 0_11_0 , upvalues : _ENV, self, OnLevelUnloadComplete
    (EventManager.Remove)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, OnLevelUnloadComplete)
    self:OnEvent_AdventureModuleEnter()
  end

  local NetCallback = function(_, mapNetData)
    -- function num : 0_11_1 , upvalues : _ENV, self, mapPrologueConfig, OnLevelUnloadComplete
    if mapNetData.EnterResp == nil then
      printError("房间数据返回为空")
      return 
    end
    self.bBattleEnd = false
    local nNextRoomType = 0
    local bFinal = false
    if self.nCurLevel + 1 <= #self.tbStarTowerAllLevel then
      local mapNextStage = (self.tbStarTowerAllLevel)[self.nCurLevel + 1]
      nNextRoomType = mapNextStage.RoomType
    else
      do
        bFinal = true
        safe_call_cs_func((CS.AdventureModuleHelper).EnterStarTowerMap, self.nStarTowerDifficulty, false, bFinal, {0, 0, 0}, nNextRoomType)
        local roomClass = self:GetcurRoom()
        self.curRoom = (roomClass.new)(self, ((mapNetData.EnterResp).Room).Cases, ((mapNetData.EnterResp).Room).Data)
        local tbButton = (mapPrologueConfig.tbButton)[self.nCurLevel]
        if tbButton == nil then
          tbButton = {}
        end
        safe_call_cs_func((CS.AdventureModuleHelper).SetProloguelBattleMsg, tbButton)
        ;
        (EventManager.Add)("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, OnLevelUnloadComplete)
        safe_call_cs_func((CS.AdventureModuleHelper).LevelStateChanged, false)
      end
    end
  end

  local mapData = {
EnterResp = {
Room = {
Data = {Floor = self.nCurLevel, MapId = self.curMapId, ParamId = floorId or 0}
, 
Cases = {}
}
}
}
  local mapStage = (self.tbStarTowerAllLevel)[self.nCurLevel]
  if mapStage == nil or self.nCurLevel <= 2 then
    self.bBattleEnd = false
    ;
    (table.insert)(((mapData.EnterResp).Room).Cases, {Id = 1, 
DoorCase = {Floor = 1, Type = 1}
})
    ;
    (table.insert)(((mapData.EnterResp).Room).Cases, {Id = 2, 
BattleCase = {TimeLimit = false, FateCard = false}
})
  else
    if mapStage.RoomType == (GameEnum.starTowerRoomType).BattleRoom then
      self.bBattleEnd = false
      ;
      (table.insert)(((mapData.EnterResp).Room).Cases, {Id = 1, 
BattleCase = {TimeLimit = false, FateCard = false}
})
    else
      self.bBattleEnd = true
      ;
      (table.insert)(((mapData.EnterResp).Room).Cases, {Id = 1, 
DoorCase = {Floor = 1, Type = 1}
})
    end
  end
  NetCallback(nil, mapData)
  self:SetLocalData()
end

StarTowerPrologueLevel.ProcessChangeInfo = function(self, mapData)
  -- function num : 0_12 , upvalues : _ENV
  local tbChangeFateCard = {}
  local mapChangeNote = {}
  local mapRewardChange = {}
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
        -- DECOMPILER ERROR at PC33: Confused about usage of register: R12 in 'UnsetPending'

        ;
        (self._mapFateCard)[mapFateCardData.Tid] = nil
        ;
        (table.insert)(tbChangeFateCard, {mapFateCardData.Tid, 0, 0, -1})
      else
        local nCountSum = 0
        if (self._mapFateCard)[mapFateCardData.Tid] == nil then
          nCountSum = 1
        end
        -- DECOMPILER ERROR at PC58: Confused about usage of register: R13 in 'UnsetPending'

        ;
        (self._mapFateCard)[mapFateCardData.Tid] = {mapFateCardData.Remain, mapFateCardData.Room}
        if mapFateCardData.Room ~= 0 and mapFateCardData.Remain ~= 0 then
          self:AddFateCardEft(mapFateCardData.Tid)
        else
          self:RemoveFateCardEft(mapFateCardData.Tid)
        end
        ;
        (table.insert)(tbChangeFateCard, {mapFateCardData.Tid, ((self._mapFateCard)[mapFateCardData.Tid])[1] - nBeforeEftCount, ((self._mapFateCard)[mapFateCardData.Tid])[2] - nBeforeRoomCount, nCountSum})
      end
    end
  end
  do
    if mapData["proto.PotentialInfo"] ~= nil then
      for _,mapPotentialInfo in ipairs(mapData["proto.PotentialInfo"]) do
        local mapPotentialCfgData = (ConfigTable.GetData)("Potential", mapPotentialInfo.Tid)
        if mapPotentialCfgData == nil then
          printError("PotentialCfgData Missing" .. mapPotentialInfo.Tid)
        else
          local nCharId = mapPotentialCfgData.CharId
          -- DECOMPILER ERROR at PC122: Confused about usage of register: R12 in 'UnsetPending'

          if ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] == nil then
            ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] = 0
          end
          -- DECOMPILER ERROR at PC132: Confused about usage of register: R12 in 'UnsetPending'

          ;
          ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] = ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] + mapPotentialInfo.Level
        end
        do
          do
            self:ChangePotential(mapPotentialInfo.Tid)
            -- DECOMPILER ERROR at PC136: LeaveBlock: unexpected jumping out DO_STMT

          end
        end
      end
    end
    if mapData["proto.NoteInfo"] ~= nil then
      for _,mapNoteInfo in ipairs(mapData["proto.NoteInfo"]) do
        print((string.format)("音符数量变化：%d,%d", mapNoteInfo.Tid, mapNoteInfo.Qty))
        -- DECOMPILER ERROR at PC160: Confused about usage of register: R10 in 'UnsetPending'

        if (self._mapNote)[mapNoteInfo.Tid] == nil then
          (self._mapNote)[mapNoteInfo.Tid] = 0
        end
        -- DECOMPILER ERROR at PC168: Confused about usage of register: R10 in 'UnsetPending'

        ;
        (self._mapNote)[mapNoteInfo.Tid] = (self._mapNote)[mapNoteInfo.Tid] + mapNoteInfo.Qty
        if mapChangeNote[mapNoteInfo.Tid] == nil then
          mapChangeNote[mapNoteInfo.Tid] = mapNoteInfo.Qty
        else
          mapChangeNote[mapNoteInfo.Tid] = mapChangeNote[mapNoteInfo.Tid] + mapNoteInfo.Qty
        end
      end
      self:ResetNoteInfo()
      self:ChangeNote()
    end
    if mapData["proto.TowerItemInfo"] ~= nil then
      for _,mapItemInfo in ipairs(mapData["proto.TowerItemInfo"]) do
        -- DECOMPILER ERROR at PC203: Confused about usage of register: R10 in 'UnsetPending'

        if (self._mapItem)[mapItemInfo.Tid] == nil then
          (self._mapItem)[mapItemInfo.Tid] = 0
        end
        -- DECOMPILER ERROR at PC211: Confused about usage of register: R10 in 'UnsetPending'

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
          -- DECOMPILER ERROR at PC242: Confused about usage of register: R10 in 'UnsetPending'

          if (self._mapItem)[mapItemInfo.Tid] == nil then
            (self._mapItem)[mapItemInfo.Tid] = 0
          end
          -- DECOMPILER ERROR at PC250: Confused about usage of register: R10 in 'UnsetPending'

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
        return tbChangeFateCard, mapChangeNote, mapRewardChange
      end
    end
  end
end

StarTowerPrologueLevel.OnEvent_AdventureModuleEnter = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local mapDiscData = {}
  for _,nDiscId in ipairs(self.tbDisc) do
    mapDiscData[nDiscId] = (PlayerData.Disc):GetDiscById(nDiscId)
  end
  local mapAddLevel = {}
  for _,nCharId in ipairs(self.tbTeam) do
    mapAddLevel[nCharId] = (PlayerData.Char):GetCharEnhancedPotential(nCharId)
  end
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerProloguePanel, self.tbTeam, self.tbDisc, {}, mapDiscData, mapAddLevel, self.nTowerId, 0)
  ;
  (EventManager.Hit)("FirstInputEnable")
  for nCharId,mapInfo in pairs(self.mapCharAttr) do
    safe_call_cs_func((CS.AdventureModuleHelper).SetActorAttribute, nCharId, mapInfo)
  end
  self:ResetAmmo()
  self:ResetSommon()
  self:ResetPersonalPerk()
  self:ResetFateCard()
  self:ResetNoteInfo()
  self:ResetDiscInfo()
end

StarTowerPrologueLevel.OnEvent_LoadLevelRefresh = function(self)
  -- function num : 0_14
  self.mapFateCardUseCount = {}
  self.mapPotentialEft = self:ResetEffect()
  if self.curRoom ~= nil then
    (self.curRoom):Enter()
  end
  self:SetActorHP()
  self:ResetSkill()
end

StarTowerPrologueLevel.OnEvent_TakeEffect = function(self, nCharId, EffectId)
  -- function num : 0_15
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
    -- DECOMPILER ERROR at PC33: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self.mapFateCardUseCount)[nFateCardId] = (self.mapFateCardUseCount)[nFateCardId] + 1
  end
end

StarTowerPrologueLevel.OnEvent_OpenStarTowerMap = function(self)
  -- function num : 0_16
end

StarTowerPrologueLevel.OnEvent_OpenStarTowerDepot = function(self)
  -- function num : 0_17 , upvalues : _ENV
  (EventManager.Hit)("CloseStarTowerDepot")
end

StarTowerPrologueLevel.OnEvent_AbandonStarTower = function(self)
  -- function num : 0_18
end

StarTowerPrologueLevel.OnEvent_FreezeFrameEnd = function(self)
  -- function num : 0_19 , upvalues : _ENV
  if self.nCurLevel > 1 then
    local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
    WwiseAudioMgr:PostEvent("special_effect_slowmotion_end")
  end
end

StarTowerPrologueLevel.OnEvent_TransAnimOutClear = function(self)
  -- function num : 0_20 , upvalues : _ENV
  if (self.nCurLevel == 2 or self.nCurLevel == 5) and (self.nTransAnimOutClearCount == 1 or self.nTransAnimOutClearCount == 3) then
    (EventManager.Hit)("InputEnable", false)
  end
  self.nTransAnimOutClearCount = self.nTransAnimOutClearCount + 1
end

StarTowerPrologueLevel.GetActorHp = function()
  -- function num : 0_21 , upvalues : _ENV
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

StarTowerPrologueLevel.GetcurRoom = function(self)
  -- function num : 0_22 , upvalues : mapProcCtrl, PATH, _ENV
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

StarTowerPrologueLevel.GetStageId = function(self, nFloor)
  -- function num : 0_23
  if (self.tbStarTowerAllLevel)[nFloor] ~= nil then
    return ((self.tbStarTowerAllLevel)[nFloor]).Id
  end
  return 0
end

StarTowerPrologueLevel.GetStageLevel = function(self, nStage)
  -- function num : 0_24 , upvalues : _ENV
  for nLevel,mapStageData in ipairs(self.tbStarTowerAllLevel) do
    if mapStageData.Id == nStage then
      return nLevel
    end
  end
  return 1
end

StarTowerPrologueLevel.GetTeam = function(self)
  -- function num : 0_25 , upvalues : mapPrologueConfig
  return mapPrologueConfig.tbTeam
end

StarTowerPrologueLevel.GetDiscs = function(self)
  -- function num : 0_26 , upvalues : mapPrologueConfig
  return mapPrologueConfig.tbDiscs
end

StarTowerPrologueLevel.RemoveFateCardEft = function(self, nFateCardId)
  -- function num : 0_27 , upvalues : _ENV
  local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
  if mapFateCardCfgData == nil then
    printError("FateCardCfgData Missing:" .. nFateCardId)
  else
    local nEftId = mapFateCardCfgData.Id
    if (self.mapFateCardEft)[nEftId] ~= nil then
      for _,tbUid in ipairs(((self.mapFateCardEft)[nEftId]).tbEftUid) do
        (UTILS.RemoveEffect)(tbUid[1], tbUid[2])
      end
      -- DECOMPILER ERROR at PC32: Confused about usage of register: R4 in 'UnsetPending'

      ;
      (self.mapFateCardEft)[nEftId] = nil
    end
  end
end

StarTowerPrologueLevel.AddFateCardEft = function(self, nFateCardId)
  -- function num : 0_28 , upvalues : _ENV
  local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
  if mapFateCardCfgData == nil then
    printError("FateCardCfgData Missing:" .. nFateCardId)
  else
    if (self.mapFateCardEft)[mapFateCardCfgData.ClientEffect] ~= nil then
      return 
    end
    if mapFateCardCfgData.ClientEffect == 0 then
      return 
    end
    local nReaminCount = mapFateCardCfgData.Count
    if (self._mapFateCard)[nFateCardId] ~= nil then
      nReaminCount = ((self._mapFateCard)[nFateCardId])[1]
    end
    if nReaminCount ~= 0 then
      return 
    end
    -- DECOMPILER ERROR at PC40: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self.mapFateCardEft)[mapFateCardCfgData.ClientEffect] = {nFateCardId = nFateCardId, 
tbEftUid = {}
}
    for _,nCharId in ipairs(self.tbTeam) do
      local nUid = (UTILS.AddFateCardEft)(nCharId, mapFateCardCfgData.ClientEffect, nReaminCount)
      ;
      (table.insert)(((self.mapFateCardEft)[mapFateCardCfgData.ClientEffect]).tbEftUid, nUid)
    end
  end
end

StarTowerPrologueLevel.ChangePotential = function(self, nPotentialId)
  -- function num : 0_29 , upvalues : _ENV
  local mapPotentialCfgData = (ConfigTable.GetData)("Potential", nPotentialId)
  if mapPotentialCfgData == nil then
    printError("PotentialCfgData Missing" .. nPotentialId)
    return 
  end
  local nCharId = mapPotentialCfgData.CharId
  local nCount = 0
  if ((self._mapPotential)[nCharId])[nPotentialId] ~= nil then
    nCount = ((self._mapPotential)[nCharId])[nPotentialId]
  end
  local stPerkInfo = (CS.Lua2CSharpInfo_TPPerkInfo)()
  stPerkInfo.perkId = nPotentialId
  stPerkInfo.nCount = nCount
  safe_call_cs_func((CS.AdventureModuleHelper).ChangePersonalPerkIds, {stPerkInfo}, nCharId)
  if (self.mapPotentialEft)[nPotentialId] ~= nil then
    for _,tbEft in ipairs((self.mapPotentialEft)[nPotentialId]) do
      (UTILS.RemoveEffect)(tbEft[1], tbEft[2])
    end
    -- DECOMPILER ERROR at PC54: Confused about usage of register: R6 in 'UnsetPending'

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
    for _,nEftId in ipairs(tbEft) do
      -- DECOMPILER ERROR at PC101: Confused about usage of register: R17 in 'UnsetPending'

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

StarTowerPrologueLevel.ChangeNote = function(self)
  -- function num : 0_30 , upvalues : _ENV
  local checkHas = function(tbDiscEft, nEftId)
    -- function num : 0_30_0 , upvalues : _ENV
    for _,v in pairs(tbDiscEft) do
      if v[1] == nEftId then
        return true
      end
    end
    return false
  end

  for k,nDiscId in ipairs(self.tbDisc) do
    -- DECOMPILER ERROR at PC13: Confused about usage of register: R7 in 'UnsetPending'

    if k <= 3 then
      if (self.mapDiscEft)[nDiscId] == nil then
        (self.mapDiscEft)[nDiscId] = {}
      end
      local mapDiscData = (PlayerData.Disc):GetDiscById(nDiscId)
      if mapDiscData ~= nil then
        local tbDiscEft = mapDiscData:GetSkillEffect(self._mapNote)
        for _,mapEft in ipairs(tbDiscEft) do
          -- DECOMPILER ERROR at PC38: Confused about usage of register: R14 in 'UnsetPending'

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
        local tbRemoveEft = {}
        for nEftId,tbEft in pairs((self.mapDiscEft)[nDiscId]) do
          if not checkHas(tbDiscEft, nEftId) then
            (table.insert)(tbRemoveEft, nEftId)
            for _,tbEftData in ipairs(tbEft) do
              (UTILS.RemoveEffect)(tbEftData[1], tbEftData[2])
            end
          end
        end
        for _,nEftId in ipairs(tbRemoveEft) do
          -- DECOMPILER ERROR at PC107: Confused about usage of register: R15 in 'UnsetPending'

          ((self.mapDiscEft)[nDiscId])[nEftId] = nil
        end
      end
    end
  end
end

StarTowerPrologueLevel.GetFateCardUsage = function(self)
  -- function num : 0_31 , upvalues : _ENV
  local ret = {}
  for nFateCardId,nCount in pairs(self.mapFateCardUseCount) do
    (table.insert)(ret, {Id = nFateCardId, Times = nCount})
  end
  return ret
end

StarTowerPrologueLevel.GetDamageRecord = function(self)
  -- function num : 0_32 , upvalues : _ENV
  local ret = {}
  for _,nCharId in pairs(self.tbTeam) do
    local nDamage = safe_call_cs_func((CS.AdventureModuleHelper).GetCharacterDamage, nCharId, false)
    ;
    (table.insert)(ret, nDamage)
  end
  safe_call_cs_func((CS.AdventureModuleHelper).ClearCharacterDamageRecord, false)
  return ret
end

StarTowerPrologueLevel.CheckBattleEnd = function(tbCases)
  -- function num : 0_33 , upvalues : _ENV
  for _,mapCases in ipairs(tbCases) do
    if mapCases.BattleCase ~= nil then
      return false
    end
  end
  return true
end

StarTowerPrologueLevel.RecoverHp = function(self, nEffectId)
  -- function num : 0_34 , upvalues : _ENV
  local nCharId = (self.tbTeam)[1]
  print("AddRecoverEft:" .. nEffectId)
  ;
  (UTILS.AddEffect)(nCharId, nEffectId, 0, 0)
  local mapHp = ((self.GetActorHp)())
  local nHp = nil
  if mapHp ~= nil then
    nHp = mapHp[nCharId]
  end
  if nHp == nil then
    nHp = -1
  end
  return nHp
end

StarTowerPrologueLevel.CalBuildScore = function(self)
  -- function num : 0_35 , upvalues : _ENV
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

StarTowerPrologueLevel.SetRoguelikeHistoryMapId = function(self, nMapId)
  -- function num : 0_36 , upvalues : _ENV, LocalStarTowerDataKey, RapidJson
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

StarTowerPrologueLevel.GetRoguelikeHistoryMapId = function(self)
  -- function num : 0_37 , upvalues : _ENV, LocalStarTowerDataKey, RapidJson
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

StarTowerPrologueLevel.CacheTempData = function(self)
  -- function num : 0_38 , upvalues : _ENV
  local FP = (CS.TrueSync).FP
  self.mapCharacterTempData = {}
  local AdventureModuleHelper = CS.AdventureModuleHelper
  local id = (AdventureModuleHelper.GetCurrentActivePlayer)()
  -- DECOMPILER ERROR at PC15: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).curCharId = ((CS.AdventureModuleHelper).GetCharacterId)(id)
  -- DECOMPILER ERROR at PC18: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).skillInfo = {}
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).effectInfo = {}
  -- DECOMPILER ERROR at PC24: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).buffInfo = {}
  -- DECOMPILER ERROR at PC27: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).stateInfo = {}
  -- DECOMPILER ERROR at PC30: Confused about usage of register: R4 in 'UnsetPending'

  ;
  (self.mapCharacterTempData).ammoInfo = {}
  -- DECOMPILER ERROR at PC34: Confused about usage of register: R4 in 'UnsetPending'

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
          (table.insert)((self.mapCharacterTempData).skillInfo, {nCharId = charTid, nSkillId = clsSkillInfo.skillId, nCd = (clsSkillInfo.currentUseInterval).RawValue, nSectionAmount = clsSkillInfo.currentSectionAmount, nSectionResumeTime = (clsSkillInfo.currentResumeTime).RawValue, nUseTimeHint = (clsSkillInfo.currentUseTimeHint).RawValue, nEnergy = (clsSkillInfo.currentEnergy).RawValue})
        end
      end
    end
    do
      -- DECOMPILER ERROR at PC118: Confused about usage of register: R16 in 'UnsetPending'

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
          -- DECOMPILER ERROR at PC155: Confused about usage of register: R25 in 'UnsetPending'

          if mapEft.Remove and nCd > 0 then
            ((((self.mapCharacterTempData).effectInfo)[charTid]).mapEffect)[(eftInfo.effectConfig).Id] = {nCount = 0, nCd = nCd}
          end
        end
      end
      do
        if self.mapEffectTriggerCount ~= nil then
          for nEftId,nCount in pairs(self.mapEffectTriggerCount) do
            -- DECOMPILER ERROR at PC178: Confused about usage of register: R22 in 'UnsetPending'

            if ((((self.mapCharacterTempData).effectInfo)[charTid]).mapEffect)[nEftId] == nil then
              ((((self.mapCharacterTempData).effectInfo)[charTid]).mapEffect)[nEftId] = {nCount = nCount, nCd = 0}
            else
              -- DECOMPILER ERROR at PC185: Confused about usage of register: R22 in 'UnsetPending'

              ;
              (((((self.mapCharacterTempData).effectInfo)[charTid]).mapEffect)[nEftId]).nCount = nCount
            end
          end
        end
        do
          local tbBuffInfo = (AdventureModuleHelper.GetEntityBuffList)(playerids[i])
          -- DECOMPILER ERROR at PC194: Confused about usage of register: R18 in 'UnsetPending'

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
              -- DECOMPILER ERROR at PC238: Confused about usage of register: R18 in 'UnsetPending'

              ;
              ((self.mapCharacterTempData).stateInfo)[charTid] = {nState = nStatus, nStateTime = nStatusTime}
              -- DECOMPILER ERROR at PC244: Confused about usage of register: R18 in 'UnsetPending'

              if tbAmmo ~= nil then
                ((self.mapCharacterTempData).ammoInfo)[charTid] = {}
                -- DECOMPILER ERROR at PC248: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nCurAmmo = nAmmoType
                -- DECOMPILER ERROR at PC253: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmo1 = tbAmmo[0]
                -- DECOMPILER ERROR at PC258: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmo2 = tbAmmo[1]
                -- DECOMPILER ERROR at PC263: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmo3 = tbAmmo[2]
                -- DECOMPILER ERROR at PC268: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax1 = tbAmmo[3]
                -- DECOMPILER ERROR at PC273: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax2 = tbAmmo[4]
                -- DECOMPILER ERROR at PC278: Confused about usage of register: R18 in 'UnsetPending'

                ;
                (((self.mapCharacterTempData).ammoInfo)[charTid]).nAmmoMax3 = tbAmmo[5]
              end
              -- DECOMPILER ERROR at PC279: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC279: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC279: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC279: LeaveBlock: unexpected jumping out DO_STMT

            end
          end
        end
      end
    end
  end
end

StarTowerPrologueLevel.CalCharFixedEffect = function(nCharId, bMainChar)
  -- function num : 0_39 , upvalues : _ENV
  local stActorInfo = (CS.Lua2CSharpInfo_CharAttribute)()
  ;
  (PlayerData.Char):CalCharacterAttrBattle(nCharId, stActorInfo, bMainChar)
  return stActorInfo
end

StarTowerPrologueLevel.ResetAmmo = function(self)
  -- function num : 0_40 , upvalues : _ENV
  if (self.mapCharacterTempData).ammoInfo ~= nil then
    local ret = {}
    for nCharId,mapAmmo in ipairs((self.mapCharacterTempData).ammoInfo) do
      local stInfo = (CS.Lua2CSharpInfo_ActorAmmoInfo)()
      local tbAmmoCount = {stInfo.nAmmo1, stInfo.nAmmo2, stInfo.nAmmo3, stInfo.nAmmoMax1, stInfo.nAmmoMax2, stInfo.nAmmoMax3}
      stInfo.actorID = nCharId
      stInfo.ammoCount = tbAmmoCount
      stInfo.ammoType = mapAmmo.nCurAmmo
      ;
      (table.insert)(ret, stInfo)
    end
    safe_call_cs_func((CS.AdventureModuleHelper).ResetActorSkillInfo, ret)
  end
end

StarTowerPrologueLevel.ResetSommon = function(self)
  -- function num : 0_41 , upvalues : _ENV
  if (self.mapCharacterTempData).sommonInfo ~= nil then
    safe_call_cs_func((CS.AdventureModuleHelper).SetSummonMonsters, (self.mapCharacterTempData).sommonInfo)
  end
end

StarTowerPrologueLevel.ResetEffect = function(self)
  -- function num : 0_42 , upvalues : _ENV
  local retPotential = {}
  local retDisc = {}
  local retFateCard = {}
  local mapCharEffect = {}
  for _,nCharId in ipairs(self.tbTeam) do
    mapCharEffect[nCharId] = {}
    -- DECOMPILER ERROR at PC19: Confused about usage of register: R10 in 'UnsetPending'

    ;
    (mapCharEffect[nCharId])[(AllEnum.EffectType).Affinity] = (PlayerData.Char):CalcAffinityEffect(nCharId)
    -- DECOMPILER ERROR at PC29: Confused about usage of register: R10 in 'UnsetPending'

    ;
    (mapCharEffect[nCharId])[(AllEnum.EffectType).Talent] = (PlayerData.Char):CalcTalentEffect(nCharId)
    if (self._mapPotential)[nCharId] ~= nil then
      for nPotentialId,nPotentialCount in pairs((self._mapPotential)[nCharId]) do
        -- DECOMPILER ERROR at PC51: Confused about usage of register: R15 in 'UnsetPending'

        if (mapCharEffect[nCharId])[(AllEnum.EffectType).Potential] == nil then
          (mapCharEffect[nCharId])[(AllEnum.EffectType).Potential] = {}
        end
        local mapPotentialCfgData = (ConfigTable.GetData)("Potential", nPotentialId)
        if mapPotentialCfgData == nil then
          printError("Potential CfgData Missing:" .. nPotentialId)
        else
          -- DECOMPILER ERROR at PC74: Confused about usage of register: R16 in 'UnsetPending'

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
  end
  local mapDiscEffect = {}
  for k,nDiscId in ipairs(self.tbDisc) do
    if k <= 3 then
      local mapDiscData = (PlayerData.Disc):GetDiscById(nDiscId)
      if mapDiscData ~= nil then
        local tbDiscEft = mapDiscData:GetSkillEffect(self._mapNote)
        mapDiscEffect[nDiscId] = tbDiscEft
      end
    end
  end
  local mapFateCardEffect = {}
  for nFateCardId,tbRemain in pairs(self._mapFateCard) do
    if tbRemain[1] ~= 0 and tbRemain[2] ~= 0 then
      local mapFateCardCfgData = (ConfigTable.GetData)("FateCard", nFateCardId)
      if mapFateCardCfgData == nil then
        printError("FateCardCfgData Missing:" .. nFateCardId)
      else
        if mapFateCardCfgData.ClientEffect == 0 then
          print("FateCardCfgData no clientEft:" .. nFateCardId)
        else
          mapFateCardEffect[nFateCardId] = {mapFateCardCfgData.ClientEffect, tbRemain[2]}
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
              -- DECOMPILER ERROR at PC326: Confused about usage of register: R22 in 'UnsetPending'

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
            local nEftUid = (UTILS.AddFateCardEft)(nCharId, tbFateCardEft[1], tbFateCardEft[2])
            if retFateCard[tbFateCardEft[1]] == nil then
              retFateCard[tbFateCardEft[1]] = {nFateCardId = nFateCardId, 
tbEftUid = {}
}
            end
            ;
            (table.insert)((retFateCard[tbFateCardEft[1]]).tbEftUid, {nEftUid, nCharId})
          end
          do
            -- DECOMPILER ERROR at PC391: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC391: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC391: LeaveBlock: unexpected jumping out DO_STMT

          end
        end
      end
    end
  end
  return retPotential, retDisc, retFateCard
end

StarTowerPrologueLevel.ResetPersonalPerk = function(self)
  -- function num : 0_43 , upvalues : _ENV
  for nCharId,mapPotential in pairs(self._mapPotential) do
    local tbStInfo = {}
    for nPotentialId,nCount in pairs(mapPotential) do
      local stPerkInfo = (CS.Lua2CSharpInfo_TPPerkInfo)()
      stPerkInfo.perkId = nPotentialId
      stPerkInfo.nCount = nCount
      ;
      (table.insert)(tbStInfo, stPerkInfo)
    end
    safe_call_cs_func((CS.AdventureModuleHelper).ChangePersonalPerkIds, tbStInfo, nCharId)
  end
end

StarTowerPrologueLevel.ResetFateCard = function(self)
  -- function num : 0_44 , upvalues : _ENV
  local tbFCInfo = {}
  for i,v in pairs(self._mapFateCard) do
    if v[1] ~= 0 and v[2] ~= 0 then
      local cardInfo = (ConfigTable.GetData)("FateCard", i)
      if cardInfo == nil then
        return 
      end
      if cardInfo.ThemeType ~= 0 then
        local fcInfo = (CS.Lua2CSharpInfo_FateCardThemeInfo)()
        fcInfo.theme = cardInfo.ThemeType
        fcInfo.rank = cardInfo.ThemeValue
        fcInfo.triggerTypes = cardInfo.ThemeTriggerType
        ;
        (table.insert)(tbFCInfo, fcInfo)
      end
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetFateCardThemes, tbFCInfo)
end

StarTowerPrologueLevel.ResetNoteInfo = function(self)
  -- function num : 0_45 , upvalues : _ENV
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

StarTowerPrologueLevel.ResetDiscInfo = function(self)
  -- function num : 0_46 , upvalues : _ENV
  local tbDiscInfo = {}
  for k,nDiscId in ipairs(self.tbDisc) do
    if k <= 3 then
      local mapDiscData = (PlayerData.Disc):GetDiscById(nDiscId)
      if mapDiscData ~= nil then
        local discInfo = mapDiscData:GetDiscInfo(self._mapNote)
        ;
        (table.insert)(tbDiscInfo, discInfo)
      end
    end
  end
  safe_call_cs_func((CS.AdventureModuleHelper).SetDiscInfo, tbDiscInfo)
end

StarTowerPrologueLevel.ResetSkill = function(self)
  -- function num : 0_47 , upvalues : _ENV
  local ret = {}
  if (self.mapCharacterTempData).skillInfo ~= nil then
    for _,skillInfo in ipairs((self.mapCharacterTempData).skillInfo) do
      local stSkillInfo = (CS.Lua2CSharpInfo_ResetSkillInfo)()
      stSkillInfo.skillId = skillInfo.nSkillId
      stSkillInfo.currentSectionAmount = skillInfo.nSectionAmount
      stSkillInfo.cd = skillInfo.nCd
      stSkillInfo.currentResumeTime = skillInfo.nSectionResumeTime
      stSkillInfo.currentUseTimeHint = skillInfo.nUseTimeHint
      stSkillInfo.energy = skillInfo.nEnergy
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

StarTowerPrologueLevel.SetActorHP = function(self)
  -- function num : 0_48 , upvalues : _ENV, mapPrologueConfig
  local tbActorInfo = {}
  local stCharInfo = (CS.Lua2CSharpInfo_ActorAttribute)()
  stCharInfo.actorID = (mapPrologueConfig.tbTeam)[1]
  stCharInfo.curHP = self.ActorHp
  ;
  (table.insert)(tbActorInfo, stCharInfo)
  safe_call_cs_func((CS.AdventureModuleHelper).ResetActorAttributes, {stCharInfo})
end

StarTowerPrologueLevel.SetLocalData = function(self)
  -- function num : 0_49 , upvalues : _ENV, RapidJson, EncodeTempData, LocalData
  local tbPotential = {}
  for nCharId,mapPotential in pairs(self._mapPotential) do
    for nPotentialId,nCount in pairs(mapPotential) do
      (table.insert)(tbPotential, {nCharId, nPotentialId, nCount})
    end
  end
  local tbFateCard = {}
  for nFateCardId,tbRemain in pairs(self._mapFateCard) do
    (table.insert)(tbFateCard, {nFateCardId, tbRemain[1], tbRemain[2]})
  end
  local mapLocalData = {mapFateCard = tbFateCard, mapPotential = tbPotential, nLevel = self.nTeamLevel, nExp = self.nTeamExp, bBattleEnd = self.bBattleEnd, tbEndCaseId = self.tbEndCaseId, nCurFloor = self.nCurLevel, ActorHp = self.ActorHp}
  local sJson = (RapidJson.encode)(mapLocalData)
  local sJsonCharacter = EncodeTempData(self.mapCharacterTempData)
  local lastAccount = (LocalData.GetLocalData)("LoginUIData", "LastUserName_All")
  ;
  (LocalData.SetLocalData)(lastAccount, "StarTowerPrologueLevel", sJson)
  ;
  (LocalData.SetLocalData)(lastAccount, "StarTowerPrologueLevelChar", sJsonCharacter)
end

StarTowerPrologueLevel.GetRecommondPotential = function(self, tbPotentialData)
  -- function num : 0_50 , upvalues : _ENV
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
    -- function num : 0_50_0 , upvalues : self, _ENV
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
  if #ret1 < 2 then
    return ret1
  end
  local ret2 = {}
  local nCurBuildCount = -1
  local GetPotentialBuildCount = function(nPotnetialId)
    -- function num : 0_50_1 , upvalues : _ENV, self
    local ret = 0
    local potentialCfg = (ConfigTable.GetData)("Potential", nPotnetialId)
    if potentialCfg ~= nil then
      local nCharId = potentialCfg.CharId
      for nId,nCount in pairs((self._mapPotential)[nCharId]) do
        local mapCfg = (ConfigTable.GetData)("Potential", nId)
        if mapCfg ~= nil and mapCfg.Build == potentialCfg.Build then
          ret = ret + 1
        end
      end
    end
    do
      return ret
    end
  end

  for _,nPotentialId in ipairs(ret1) do
    local nCount = GetPotentialBuildCount(nPotentialId)
    if nCurBuildCount < 0 then
      (table.insert)(ret2, nPotentialId)
      nCurBuildCount = nCount
    else
      if nCount == nCurBuildCount then
        (table.insert)(ret2, nPotentialId)
      else
        if nCount < nCurBuildCount then
          ret2 = {}
          ;
          (table.insert)(ret2, nPotentialId)
          nCurBuildCount = nCount
        end
      end
    end
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
      else
        if nCurCount == curLessPotential then
          (table.insert)(ret3, nPotentialId)
        else
          if nCurCount < curLessPotential then
            ret3 = {}
            ;
            (table.insert)(ret3, nPotentialId)
            curLessPotential = nCurCount
          end
        end
      end
    end
  end
  return ret3
end

StarTowerPrologueLevel.UserEventUpload = function(self, strEventName, parme1, parme2)
  -- function num : 0_51 , upvalues : SDKManager, _ENV
  SDKManager:UserEventUpload(strEventName, tostring(parme1), tostring(parme2))
end

return StarTowerPrologueLevel

