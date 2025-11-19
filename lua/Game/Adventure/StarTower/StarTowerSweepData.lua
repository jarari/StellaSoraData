local StarTowerSweepData = class("StarTowerSweepData")
local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
local mapEventConfig = {}
StarTowerSweepData.ctor = function(self, nStarTowerId)
  -- function num : 0_0 , upvalues : _ENV
  self.EnumCase = {Battle = 1, OpenDoor = 2, PotentialSelect = 3, FateCardSelect = 4, NoteSelect = 5, NpcEvent = 6, SelectSpecialPotential = 7, RecoveryHP = 8, NpcRecoveryHP = 9, Hawker = 10, StrengthenMachine = 11, DoorDanger = 12, SyncHP = 13}
  self.EnumPopup = {Disc = 1, Reward = 2, Potential = 3, StrengthFx = 4, Affinity = 5}
  self:BindEvent()
  local BuildStarTowerAllFloorData = function(nTowerId)
    -- function num : 0_0_0 , upvalues : _ENV
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
        printError("FloorNum Missing��" .. nTowerId .. " " .. nIdx)
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
    -- function num : 0_0_1 , upvalues : _ENV
    local ret = {}
    local forEachExp = function(mapData)
      -- function num : 0_0_1_0 , upvalues : nTowerId, ret
      if mapData.StarTowerId == nTowerId then
        ret[mapData.Stage] = mapData
      end
    end

    ForEachTableLine(DataTable.StarTowerFloorExp, forEachExp)
    return ret
  end

  self.nTowerId = nStarTowerId
  self.nCurLevel = 1
  self.bRanking = false
  self.tbStarTowerAllLevel = BuildStarTowerAllFloorData(self.nTowerId)
  self.mapFloorExp = BuildStarTowerExpData(self.nTowerId)
  self.tbStrengthMachineCost = (ConfigTable.GetConfigNumberArray)("StrengthenMachineGoldConsume")
end

StarTowerSweepData.BindEvent = function(self)
  -- function num : 0_1 , upvalues : _ENV, mapEventConfig
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

StarTowerSweepData.UnBindEvent = function(self)
  -- function num : 0_2 , upvalues : _ENV, mapEventConfig
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

StarTowerSweepData.Init = function(self, mapMeta, mapRoom, mapBag)
  -- function num : 0_3 , upvalues : _ENV
  local GetCharacterAttr = function(tbTeam, mapDisc)
    -- function num : 0_3_0 , upvalues : _ENV, self
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
        -- DECOMPILER ERROR at PC30: Confused about usage of register: R13 in 'UnsetPending'

        (self._mapNote)[v.SubNoteSkillId] = 0
      end
    end
  end
  do
    self._mapPotential = {}
    self._mapFateCard = {}
    self._mapItem = {}
    self.tbTeam = {}
    self.mapPotentialAddLevel = {}
    for _,mapChar in ipairs(mapMeta.Chars) do
      (table.insert)(self.tbTeam, mapChar.Id)
      -- DECOMPILER ERROR at PC55: Confused about usage of register: R11 in 'UnsetPending'

      ;
      (self._mapPotential)[mapChar.Id] = {}
      local tbActive = ((self.mapCharData)[mapChar.Id]).tbActive
      local tbEquipment = ((self.mapCharData)[mapChar.Id]).tbEquipment
      -- DECOMPILER ERROR at PC70: Confused about usage of register: R13 in 'UnsetPending'

      ;
      (self.mapPotentialAddLevel)[mapChar.Id] = self:GetCharEnhancedPotential(tbActive, tbEquipment)
    end
    self.tbDisc = {}
    for _,mapDisc in ipairs(mapMeta.Discs) do
      (table.insert)(self.tbDisc, mapDisc.Id)
    end
    self.nTowerId = mapMeta.Id
    self.nCurLevel = (mapRoom.Data).Floor
    self.tbActiveSecondaryIds = mapMeta.ActiveSecondaryIds
    self.tbGrowthNodeEffect = (PlayerData.StarTower):GetClientEffectByNode(mapMeta.TowerGrowthNodes)
    self.nResurrectionCnt = mapMeta.ResurrectionCnt or 0
    self.nTeamLevel = mapMeta.TeamLevel
    self.nTeamExp = mapMeta.TeamExp
    self.nTotalTime = mapMeta.TotalTime
    if self.nRankBattleTime == nil then
      self.nRankBattleTime = 0
    end
    if (mapRoom.Data).RoomType ~= nil or not -1 then
      self.nRoomType = (mapRoom.Data).RoomType
      if mapBag ~= nil then
        for _,mapFateCardEft in ipairs(mapBag.FateCard) do
          -- DECOMPILER ERROR at PC136: Confused about usage of register: R11 in 'UnsetPending'

          (self._mapFateCard)[mapFateCardEft.Tid] = {mapFateCardEft.Remain, mapFateCardEft.Room}
        end
        for _,mapPotential in ipairs(mapBag.Potentials) do
          local nTid = mapPotential.Tid
          local mapPotentialCfgData = (ConfigTable.GetData)("Potential", nTid)
          if mapPotentialCfgData == nil then
            printError("PotentialCfgData Missing" .. nTid)
          else
            local nCharId = mapPotentialCfgData.CharId
            -- DECOMPILER ERROR at PC164: Confused about usage of register: R14 in 'UnsetPending'

            if (self._mapPotential)[nCharId] == nil then
              (self._mapPotential)[nCharId] = {}
            end
            -- DECOMPILER ERROR at PC168: Confused about usage of register: R14 in 'UnsetPending'

            ;
            ((self._mapPotential)[nCharId])[nTid] = mapPotential.Level
          end
        end
        for _,mapItem in ipairs(mapBag.Items) do
          local mapItemCfgData = (ConfigTable.GetData_Item)(mapItem.Tid)
          -- DECOMPILER ERROR at PC190: Confused about usage of register: R12 in 'UnsetPending'

          if mapItemCfgData ~= nil and mapItemCfgData.Stype == (GameEnum.itemStype).SubNoteSkill then
            (self._mapNote)[mapItem.Tid] = mapItem.Qty
          else
            -- DECOMPILER ERROR at PC195: Confused about usage of register: R12 in 'UnsetPending'

            ;
            (self._mapItem)[mapItem.Tid] = mapItem.Qty
          end
        end
        for _,mapItem in ipairs(mapBag.Res) do
          -- DECOMPILER ERROR at PC205: Confused about usage of register: R11 in 'UnsetPending'

          (self._mapItem)[mapItem.Tid] = mapItem.Qty
        end
      end
      do
        self:InitRoom(mapRoom.Cases)
      end
    end
  end
end

StarTowerSweepData.BuildCharacterData = function(self, tbCharacterData, tbDiscData)
  -- function num : 0_4 , upvalues : _ENV
  local EquipmentData = require("GameCore.Data.DataClass.EquipmentDataEx")
  local DiscData = require("GameCore.Data.DataClass.DiscData")
  local mapCharacter = {}
  local mapDisc = {}
  for idx,mapChar in ipairs(tbCharacterData) do
    do
      do
        local tbEquipment, tbEquipmentSlot = {}, {}
        for _,starTowerEquipment in ipairs(mapChar.Gems) do
          if starTowerEquipment.Attributes then
            local bEmpty = false
            do
              for _,v in pairs(starTowerEquipment.Attributes) do
                if v == 0 then
                  bEmpty = true
                  break
                end
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
                -- DECOMPILER ERROR at PC58: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC58: LeaveBlock: unexpected jumping out IF_THEN_STMT

                -- DECOMPILER ERROR at PC58: LeaveBlock: unexpected jumping out IF_STMT

              end
            end
          end
        end
        local tbTalent = (CacheTable.GetData)("_TalentByIndex", mapChar.Id)
        if tbTalent == nil then
          printError("Talent���Ҳ����ý�ɫ" .. mapChar.Id)
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
    -- function num : 0_4_0 , upvalues : _ENV, tbEquipment
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
        local tbAffinityeffectIds = {}
        local mapCfg = (ConfigTable.GetData)("CharAffinityTemplate", mapChar.Id)
        if mapCfg ~= nil then
          local templateId = mapCfg.TemplateId
          local forEachAffinityLevel = function(affinityData)
    -- function num : 0_4_1 , upvalues : templateId, mapChar, _ENV, tbAffinityeffectIds
    if affinityData.TemplateId == templateId and mapChar.AffinityLevel ~= nil and affinityData.AffinityLevel <= mapChar.AffinityLevel and affinityData.Effect ~= nil and #affinityData.Effect > 0 then
      for k,v in ipairs(affinityData.Effect) do
        (table.insert)(tbAffinityeffectIds, v)
      end
    end
  end

          ForEachTableLine(DataTable.AffinityLevel, forEachAffinityLevel)
        end
        do
          local charData = {nId = mapChar.Id, nRankExp = 0, nFavor = 0, nSkinId = (PlayerData.Char):GetCharUsedSkinId(mapChar.Id), tbEquipment = tbEquipment, tbEquipmentSlot = tbEquipmentSlot, nLevel = mapChar.Level, nCreateTime = 0, nAdvance = mapChar.Advance, tbSkillLvs = GetCharSkillAddedLevel(mapChar.Id, mapChar.SkillLvs, tbActive, idx == 1), bUseSkillWhenActive_Branch1 = false, bUseSkillWhenActive_Branch2 = false, 
tbPlot = {}
, nAffinityExp = 0, nAffinityLevel = mapChar.AffinityLevel, 
tbAffinityQuests = {}
, tbActive = tbActive, tbAffinityeffectIds = tbAffinityeffectIds, tbTalentEffect = tbTalentEffect}
          mapCharacter[mapChar.Id] = charData
        end
        -- DECOMPILER ERROR at PC183: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
  for _,startowerDisc in ipairs(tbDiscData) do
    local l_0_4_55, l_0_4_56, l_0_4_57, _, startowerDisc = nil
    -- DECOMPILER ERROR at PC190: Confused about usage of register: R11 in 'UnsetPending'

    tbEquipmentSlot = mapChar.Id
    -- DECOMPILER ERROR at PC192: Confused about usage of register: R11 in 'UnsetPending'

    tbEquipmentSlot = mapChar.Level
    -- DECOMPILER ERROR at PC195: Confused about usage of register: R11 in 'UnsetPending'

    tbEquipmentSlot = mapChar.Phase
    -- DECOMPILER ERROR at PC197: Confused about usage of register: R11 in 'UnsetPending'

    tbEquipmentSlot = mapChar.Star
    local mapDiscInfo = nil
    tbEquipmentSlot = DiscData.new
    tbTalent, tbEquipment = tbEquipment, {Id = tbEquipmentSlot, Level = tbEquipmentSlot, Exp = 0, Phase = tbEquipmentSlot, Star = tbEquipmentSlot, Read = false, CreatTime = 0}
    tbEquipmentSlot = tbEquipmentSlot(tbTalent)
    local discData = nil
    -- DECOMPILER ERROR at PC204: Confused about usage of register: R11 in 'UnsetPending'

    tbTalent = mapChar.Id
    mapDisc[tbTalent] = tbEquipmentSlot
  end
  do return mapCharacter, mapDisc end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

StarTowerSweepData.GetCharEnhancedPotential = function(self, tbActiveTalent, tbEquipment)
  -- function num : 0_5 , upvalues : _ENV
  local mapAddLevel = {}
  local add = function(mapAdd)
    -- function num : 0_5_0 , upvalues : _ENV, mapAddLevel
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

StarTowerSweepData.InitRoom = function(self, tbCases)
  -- function num : 0_6
  self.bEnd = false
  self.tbEvent = {}
  self.roomData = {}
  self.mapCases = {}
  self.bProcessing = true
  self.nTaskType = 0
  self.mapNpc = {}
  self:SaveCase(tbCases)
  self.tbPopup = {}
  self.blockNpcBtn = false
end

StarTowerSweepData.SaveCase = function(self, tbCases)
  -- function num : 0_7 , upvalues : _ENV
  for _,mapCaseData in ipairs(tbCases) do
    if mapCaseData.BattleCase ~= nil then
      print("BattleCase")
      if (self.mapCases)[(self.EnumCase).Battle] ~= nil then
        printError("ս���¼��ظ� ���ܵ��·����¼������޷�����")
      end
      -- DECOMPILER ERROR at PC23: Confused about usage of register: R7 in 'UnsetPending'

      ;
      (self.mapCases)[(self.EnumCase).Battle] = {}
      -- DECOMPILER ERROR at PC29: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self.mapCases)[(self.EnumCase).Battle]).Id = mapCaseData.Id
      -- DECOMPILER ERROR at PC35: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self.mapCases)[(self.EnumCase).Battle]).Data = mapCaseData.BattleCase
      -- DECOMPILER ERROR at PC40: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self.mapCases)[(self.EnumCase).Battle]).bFinish = false
    else
      if mapCaseData.DoorCase ~= nil then
        if (mapCaseData.DoorCase).Type == (GameEnum.starTowerRoomType).DangerRoom then
          print("DangerRoomCase")
          local mapStarTower = (ConfigTable.GetData)("StarTower", self.nTowerId)
          local nNpcId = mapStarTower.DangerNpc
          local mapNpcCfgData = (ConfigTable.GetData)("NPCConfig", nNpcId)
          local nBoardNpcId = mapNpcCfgData.NPCId
          -- DECOMPILER ERROR at PC69: Confused about usage of register: R11 in 'UnsetPending'

          ;
          (self.mapNpc)[nNpcId] = mapCaseData.Id
          -- DECOMPILER ERROR at PC80: Confused about usage of register: R11 in 'UnsetPending'

          if (self.mapCases)[(self.EnumCase).DoorDanger] == nil then
            (self.mapCases)[(self.EnumCase).DoorDanger] = {}
          end
          -- DECOMPILER ERROR at PC87: Confused about usage of register: R11 in 'UnsetPending'

          ;
          ((self.mapCases)[(self.EnumCase).DoorDanger])[mapCaseData.Id] = mapCaseData.DoorCase
          -- DECOMPILER ERROR at PC94: Confused about usage of register: R11 in 'UnsetPending'

          ;
          (((self.mapCases)[(self.EnumCase).DoorDanger])[mapCaseData.Id]).bFinish = false
          -- DECOMPILER ERROR at PC101: Confused about usage of register: R11 in 'UnsetPending'

          ;
          (((self.mapCases)[(self.EnumCase).DoorDanger])[mapCaseData.Id]).NpcId = nNpcId
        else
          do
            if (mapCaseData.DoorCase).Type == (GameEnum.starTowerRoomType).HorrorRoom then
              print("HorrorRoomCase")
              local mapStarTower = (ConfigTable.GetData)("StarTower", self.nTowerId)
              local nNpcId = mapStarTower.HorrorNpc
              -- DECOMPILER ERROR at PC121: Confused about usage of register: R9 in 'UnsetPending'

              ;
              (self.mapNpc)[nNpcId] = mapCaseData.Id
              -- DECOMPILER ERROR at PC132: Confused about usage of register: R9 in 'UnsetPending'

              if (self.mapCases)[(self.EnumCase).DoorDanger] == nil then
                (self.mapCases)[(self.EnumCase).DoorDanger] = {}
              end
              -- DECOMPILER ERROR at PC139: Confused about usage of register: R9 in 'UnsetPending'

              ;
              ((self.mapCases)[(self.EnumCase).DoorDanger])[mapCaseData.Id] = mapCaseData.DoorCase
              -- DECOMPILER ERROR at PC146: Confused about usage of register: R9 in 'UnsetPending'

              ;
              (((self.mapCases)[(self.EnumCase).DoorDanger])[mapCaseData.Id]).bFinish = false
              -- DECOMPILER ERROR at PC153: Confused about usage of register: R9 in 'UnsetPending'

              ;
              (((self.mapCases)[(self.EnumCase).DoorDanger])[mapCaseData.Id]).NpcId = nNpcId
            else
              do
                print("DoorCase")
                -- DECOMPILER ERROR at PC172: Confused about usage of register: R7 in 'UnsetPending'

                if (self.mapCases)[(self.EnumCase).OpenDoor] == nil then
                  (self.mapCases)[(self.EnumCase).OpenDoor] = {mapCaseData.Id, (mapCaseData.DoorCase).Type}
                end
                if mapCaseData.SelectPotentialCase ~= nil then
                  print("SelectPotentialCase")
                  -- DECOMPILER ERROR at PC190: Confused about usage of register: R7 in 'UnsetPending'

                  if (self.mapCases)[(self.EnumCase).PotentialSelect] == nil then
                    (self.mapCases)[(self.EnumCase).PotentialSelect] = {}
                  end
                  -- DECOMPILER ERROR at PC197: Confused about usage of register: R7 in 'UnsetPending'

                  ;
                  ((self.mapCases)[(self.EnumCase).PotentialSelect])[mapCaseData.Id] = mapCaseData.SelectPotentialCase
                  -- DECOMPILER ERROR at PC204: Confused about usage of register: R7 in 'UnsetPending'

                  ;
                  (((self.mapCases)[(self.EnumCase).PotentialSelect])[mapCaseData.Id]).bFinish = false
                else
                  if mapCaseData.SelectSpecialPotentialCase ~= nil then
                    print("SelectSpecialPotentialCase")
                    -- DECOMPILER ERROR at PC222: Confused about usage of register: R7 in 'UnsetPending'

                    if (self.mapCases)[(self.EnumCase).SelectSpecialPotential] == nil then
                      (self.mapCases)[(self.EnumCase).SelectSpecialPotential] = {}
                    end
                    -- DECOMPILER ERROR at PC229: Confused about usage of register: R7 in 'UnsetPending'

                    ;
                    ((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[mapCaseData.Id] = mapCaseData.SelectSpecialPotentialCase
                    -- DECOMPILER ERROR at PC236: Confused about usage of register: R7 in 'UnsetPending'

                    ;
                    (((self.mapCases)[(self.EnumCase).SelectSpecialPotential])[mapCaseData.Id]).bFinish = false
                  else
                    if mapCaseData.SelectFateCardCase ~= nil then
                      print("SelectFateCardCase")
                      -- DECOMPILER ERROR at PC254: Confused about usage of register: R7 in 'UnsetPending'

                      if (self.mapCases)[(self.EnumCase).FateCardSelect] == nil then
                        (self.mapCases)[(self.EnumCase).FateCardSelect] = {}
                      end
                      -- DECOMPILER ERROR at PC261: Confused about usage of register: R7 in 'UnsetPending'

                      ;
                      ((self.mapCases)[(self.EnumCase).FateCardSelect])[mapCaseData.Id] = mapCaseData.SelectFateCardCase
                      -- DECOMPILER ERROR at PC268: Confused about usage of register: R7 in 'UnsetPending'

                      ;
                      (((self.mapCases)[(self.EnumCase).FateCardSelect])[mapCaseData.Id]).bFinish = false
                    else
                      if mapCaseData.SelectNoteCase ~= nil then
                        print("SelectNoteCase")
                        -- DECOMPILER ERROR at PC286: Confused about usage of register: R7 in 'UnsetPending'

                        if (self.mapCases)[(self.EnumCase).NoteSelect] == nil then
                          (self.mapCases)[(self.EnumCase).NoteSelect] = {}
                        end
                        -- DECOMPILER ERROR at PC293: Confused about usage of register: R7 in 'UnsetPending'

                        ;
                        ((self.mapCases)[(self.EnumCase).NoteSelect])[mapCaseData.Id] = mapCaseData.SelectNoteCase
                        -- DECOMPILER ERROR at PC300: Confused about usage of register: R7 in 'UnsetPending'

                        ;
                        (((self.mapCases)[(self.EnumCase).NoteSelect])[mapCaseData.Id]).bFinish = false
                      else
                        if mapCaseData.SelectOptionsEventCase ~= nil then
                          print("SelectOptionsEventCase")
                          -- DECOMPILER ERROR at PC318: Confused about usage of register: R7 in 'UnsetPending'

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
                                printError("NpcId�ظ�" .. (mapCaseData.SelectOptionsEventCase).EvtId)
                              end
                              -- DECOMPILER ERROR at PC354: Confused about usage of register: R12 in 'UnsetPending'

                              ;
                              (self.mapNpc)[nNpcId] = mapCaseData.Id
                              local nActionId = (mapCaseData.SelectOptionsEventCase).EvtId * 10000 + nNpcId
                              -- DECOMPILER ERROR at PC367: Confused about usage of register: R13 in 'UnsetPending'

                              if (ConfigTable.GetData)("StarTowerEventAction", nActionId) ~= nil then
                                (mapCaseData.SelectOptionsEventCase).nActionId = nActionId
                              else
                                printError("���¼�û�ж�Ӧ��action" .. (mapCaseData.SelectOptionsEventCase).EvtId)
                                -- DECOMPILER ERROR at PC376: Confused about usage of register: R13 in 'UnsetPending'

                                ;
                                (mapCaseData.SelectOptionsEventCase).nActionId = 0
                              end
                            else
                              do
                                do
                                  do
                                    printError("û���ҵ���ӦNPC���� " .. nNpcId)
                                    -- DECOMPILER ERROR at PC389: Confused about usage of register: R8 in 'UnsetPending'

                                    ;
                                    ((self.mapCases)[(self.EnumCase).NpcEvent])[mapCaseData.Id] = mapCaseData.SelectOptionsEventCase
                                    -- DECOMPILER ERROR at PC398: Confused about usage of register: R8 in 'UnsetPending'

                                    ;
                                    (((self.mapCases)[(self.EnumCase).NpcEvent])[mapCaseData.Id]).bFinish = (mapCaseData.SelectOptionsEventCase).Done
                                    -- DECOMPILER ERROR at PC405: Confused about usage of register: R8 in 'UnsetPending'

                                    ;
                                    (((self.mapCases)[(self.EnumCase).NpcEvent])[mapCaseData.Id]).bFirst = true
                                    if mapCaseData.RecoveryHPCase ~= nil then
                                      print("RecoveryHPCase")
                                      -- DECOMPILER ERROR at PC423: Confused about usage of register: R7 in 'UnsetPending'

                                      if (self.mapCases)[(self.EnumCase).RecoveryHP] == nil then
                                        (self.mapCases)[(self.EnumCase).RecoveryHP] = {}
                                      end
                                      -- DECOMPILER ERROR at PC430: Confused about usage of register: R7 in 'UnsetPending'

                                      ;
                                      ((self.mapCases)[(self.EnumCase).RecoveryHP])[mapCaseData.Id] = mapCaseData.RecoveryHPCase
                                      -- DECOMPILER ERROR at PC437: Confused about usage of register: R7 in 'UnsetPending'

                                      ;
                                      (((self.mapCases)[(self.EnumCase).RecoveryHP])[mapCaseData.Id]).bFinish = false
                                    else
                                      if mapCaseData.NpcRecoveryHPCase ~= nil then
                                        print("NpcRecoveryHPCase")
                                        local mapStarTower = (ConfigTable.GetData)("StarTower", self.nTowerId)
                                        local nNpcId = mapStarTower.ResqueNpc
                                        -- DECOMPILER ERROR at PC453: Confused about usage of register: R9 in 'UnsetPending'

                                        ;
                                        (self.mapNpc)[nNpcId] = mapCaseData.Id
                                        -- DECOMPILER ERROR at PC464: Confused about usage of register: R9 in 'UnsetPending'

                                        if (self.mapCases)[(self.EnumCase).NpcRecoveryHP] == nil then
                                          (self.mapCases)[(self.EnumCase).NpcRecoveryHP] = {}
                                        end
                                        -- DECOMPILER ERROR at PC471: Confused about usage of register: R9 in 'UnsetPending'

                                        ;
                                        ((self.mapCases)[(self.EnumCase).NpcRecoveryHP])[mapCaseData.Id] = mapCaseData.NpcRecoveryHPCase
                                        -- DECOMPILER ERROR at PC478: Confused about usage of register: R9 in 'UnsetPending'

                                        ;
                                        (((self.mapCases)[(self.EnumCase).NpcRecoveryHP])[mapCaseData.Id]).bFinish = false
                                      else
                                        do
                                          if mapCaseData.HawkerCase ~= nil then
                                            print("HawkerCase")
                                            local nType = self.nRoomType
                                            local mapStarTower = (ConfigTable.GetData)("StarTower", self.nTowerId)
                                            local nNpcId = mapStarTower.ShopNpc
                                            if nType ~= (GameEnum.starTowerRoomType).ShopRoom then
                                              nNpcId = mapStarTower.StandShopNpc
                                            end
                                            -- DECOMPILER ERROR at PC501: Confused about usage of register: R10 in 'UnsetPending'

                                            ;
                                            (self.mapNpc)[nNpcId] = mapCaseData.Id
                                            -- DECOMPILER ERROR at PC506: Confused about usage of register: R10 in 'UnsetPending'

                                            ;
                                            (self.mapCases)[(self.EnumCase).Hawker] = mapCaseData.HawkerCase
                                            -- DECOMPILER ERROR at PC512: Confused about usage of register: R10 in 'UnsetPending'

                                            ;
                                            ((self.mapCases)[(self.EnumCase).Hawker]).Id = mapCaseData.Id
                                            -- DECOMPILER ERROR at PC517: Confused about usage of register: R10 in 'UnsetPending'

                                            ;
                                            ((self.mapCases)[(self.EnumCase).Hawker]).nNpc = nNpcId
                                            -- DECOMPILER ERROR at PC522: Confused about usage of register: R10 in 'UnsetPending'

                                            ;
                                            ((self.mapCases)[(self.EnumCase).Hawker]).bFinish = false
                                          else
                                            do
                                              if mapCaseData.StrengthenMachineCase ~= nil then
                                                print("StrengthenMachineCase")
                                                local mapStarTower = (ConfigTable.GetData)("StarTower", self.nTowerId)
                                                local nNpcId = mapStarTower.UpgradeNpc
                                                -- DECOMPILER ERROR at PC538: Confused about usage of register: R9 in 'UnsetPending'

                                                ;
                                                (self.mapNpc)[nNpcId] = mapCaseData.Id
                                                -- DECOMPILER ERROR at PC543: Confused about usage of register: R9 in 'UnsetPending'

                                                ;
                                                (self.mapCases)[(self.EnumCase).StrengthenMachine] = mapCaseData.StrengthenMachineCase
                                                -- DECOMPILER ERROR at PC549: Confused about usage of register: R9 in 'UnsetPending'

                                                ;
                                                ((self.mapCases)[(self.EnumCase).StrengthenMachine]).Id = mapCaseData.Id
                                                -- DECOMPILER ERROR at PC554: Confused about usage of register: R9 in 'UnsetPending'

                                                ;
                                                ((self.mapCases)[(self.EnumCase).StrengthenMachine]).bFinish = false
                                              else
                                                do
                                                  do
                                                    -- DECOMPILER ERROR at PC563: Confused about usage of register: R7 in 'UnsetPending'

                                                    if mapCaseData.SyncHPCase ~= nil then
                                                      (self.mapCases)[(self.EnumCase).SyncHP] = mapCaseData.Id
                                                    end
                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out DO_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                                    -- DECOMPILER ERROR at PC564: LeaveBlock: unexpected jumping out IF_STMT

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

StarTowerSweepData.SaveSelectResp = function(self, mapCaseData, nCaseId)
  -- function num : 0_8
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
        if mapCaseData.HawkerCase ~= nil then
          local temp = (self.mapCases)[(self.EnumCase).Hawker]
          -- DECOMPILER ERROR at PC82: Confused about usage of register: R4 in 'UnsetPending'

          ;
          (self.mapCases)[(self.EnumCase).Hawker] = mapCaseData.HawkerCase
          -- DECOMPILER ERROR at PC87: Confused about usage of register: R4 in 'UnsetPending'

          ;
          ((self.mapCases)[(self.EnumCase).Hawker]).bFinish = false
          -- DECOMPILER ERROR at PC92: Confused about usage of register: R4 in 'UnsetPending'

          ;
          ((self.mapCases)[(self.EnumCase).Hawker]).bReRoll = true
          -- DECOMPILER ERROR at PC98: Confused about usage of register: R4 in 'UnsetPending'

          ;
          ((self.mapCases)[(self.EnumCase).Hawker]).Id = temp.Id
          -- DECOMPILER ERROR at PC104: Confused about usage of register: R4 in 'UnsetPending'

          ;
          ((self.mapCases)[(self.EnumCase).Hawker]).nNpc = temp.nNpcId
        end
      end
    end
  end
end

StarTowerSweepData.StarTowerInteract = function(self, mapMsgData, callback)
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
    ;
    (EventManager.Hit)("RefreshNoteCount", self._mapNote, mapChangeNote, mapChangeSecondarySkill)
    if mapNetData.BattleEndResp ~= nil and (mapNetData.BattleEndResp).Victory ~= nil then
      nExpChange = ((mapNetData.BattleEndResp).Victory).Exp - self.nTeamExp
      nLevelChange = ((mapNetData.BattleEndResp).Victory).Lv - self.nTeamLevel
      self.nTeamLevel = ((mapNetData.BattleEndResp).Victory).Lv
      self.nTeamExp = ((mapNetData.BattleEndResp).Victory).Exp
      self.nRankBattleTime = self.nRankBattleTime + ((mapNetData.BattleEndResp).Victory).BattleTime
    end
    ;
    (EventManager.Hit)("RefreshFastBattleInfo", tbChangeFateCard, mapChangeNote, mapItemChange, nLevelChange, nExpChange, mapPotentialChange)
    self:SaveCase(mapNetData.Cases)
    self:SaveSelectResp(mapNetData.SelectResp, mapMsgData.Id)
    if callback ~= nil and type(callback) == "function" then
      callback(mapNetData, tbChangeFateCard, mapChangeNote, mapItemChange, nLevelChange, nExpChange, mapPotentialChange)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_interact_req, mapMsgData, nil, NetCallback)
end

StarTowerSweepData.EnterRoom = function(self, nCaseId, nRoomType)
  -- function num : 0_10 , upvalues : _ENV
  if #self.tbStarTowerAllLevel < self.nCurLevel + 1 then
    self:StarTowerClear(nCaseId)
    return 
  end
  local floorId = 0
  local sExData = ""
  local scenePrefabId = 0
  self.nRoomType = nRoomType
  if nRoomType ~= (GameEnum.starTowerRoomType).DangerRoom and nRoomType ~= (GameEnum.starTowerRoomType).HorrorRoom then
    self.nCurLevel = self.nCurLevel + 1
  end
  local NetCallback = function(_, mapNetData)
    -- function num : 0_10_0 , upvalues : _ENV, self
    if mapNetData.EnterResp == nil then
      printError("�������ݷ���Ϊ��")
      return 
    end
    self:ProcessChangeInfo(mapNetData.Change)
    self:InitRoom(((mapNetData.EnterResp).Room).Cases)
    ;
    (EventManager.Hit)("InitRoom")
  end

  local EnterReq = {MapId = self.curMapId, ParamId = floorId, DateLen = 0, ClientData = "", MapParam = sExData, MapTableId = scenePrefabId}
  local mapMsg = {Id = nCaseId, EnterReq = EnterReq}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_interact_req, mapMsg, nil, NetCallback)
end

StarTowerSweepData.StarTowerLeave = function(self)
  -- function num : 0_11 , upvalues : _ENV
  local nRecon = (PlayerData.State):GetStarTowerRecon()
  local mapStateInfo = {Id = self.nTowerId, ReConnection = nRecon, BuildId = 0, CharIds = self.tbTeam, Floor = self.nCurLevel, Sweep = true}
  ;
  (PlayerData.State):CacheStarTowerStateData(mapStateInfo)
end

StarTowerSweepData.StarTowerClear = function(self, nCaseId)
  -- function num : 0_12 , upvalues : _ENV
  local EnterReq = {MapId = 0}
  local mapMsg = {Id = nCaseId, EnterReq = EnterReq}
  local NetCallback = function(_, mapNetMsg)
    -- function num : 0_12_0 , upvalues : _ENV, self
    local mapBuildInfo = nil
    local mapChangeInfo = {}
    local tbRes = {}
    local tbItem = {}
    local nTime = 0
    local mapNpcAffinity = {}
    local tbTowerRewards = {}
    if mapNetMsg.Settle ~= nil then
      (PlayerData.StarTower):CacheNpcAffinityChange((mapNetMsg.Settle).Reward, (mapNetMsg.Settle).NpcInteraction)
      mapBuildInfo = (mapNetMsg.Settle).Build
      mapChangeInfo = (mapNetMsg.Settle).Change
      nTime = (mapNetMsg.Settle).TotalTime
      mapNpcAffinity = (mapNetMsg.Settle).Reward
      tbTowerRewards = (mapNetMsg.Settle).TowerRewards
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
, mapChangeInfo = mapChangeInfo, bRanking = self.bRanking, mapNPCAffinity = mapNpcAffinity, tbRewards = tbTowerRewards, bSweep = true}
          ;
          (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerResult, mapResult, self.tbTeam)
          local wait = function()
      -- function num : 0_12_0_0 , upvalues : _ENV
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (EventManager.Hit)(EventId.ClosePanel, PanelId.StarTowerFastBattle)
    end

          ;
          (cs_coroutine.start)(wait)
          ;
          (PlayerData.State):CacheStarTowerStateData(nil)
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).star_tower_interact_req, mapMsg, nil, NetCallback)
end

StarTowerSweepData.ProcessChangeInfo = function(self, mapChangeData)
  -- function num : 0_13 , upvalues : _ENV
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
      -- DECOMPILER ERROR at PC34: Confused about usage of register: R13 in 'UnsetPending'

      if mapFateCardData.Qty == 0 then
        (self._mapFateCard)[mapFateCardData.Tid] = nil
        ;
        (table.insert)(tbChangeFateCard, {mapFateCardData.Tid, 0, 0, -1})
      else
        local nCountSum = 0
        if (self._mapFateCard)[mapFateCardData.Tid] == nil then
          nCountSum = 1
        else
          if mapFateCardData.Room ~= 0 and mapFateCardData.Remain ~= 0 then
            local nBeforeCount = (math.max)(nBeforeEftCount, nBeforeRoomCount)
            if (self._mapFateCard)[mapFateCardData.Tid] ~= nil and nBeforeCount <= 0 then
              nCountSum = 2
            end
          end
        end
        do
          do
            -- DECOMPILER ERROR at PC79: Confused about usage of register: R14 in 'UnsetPending'

            ;
            (self._mapFateCard)[mapFateCardData.Tid] = {mapFateCardData.Remain, mapFateCardData.Room}
            ;
            (table.insert)(tbChangeFateCard, {mapFateCardData.Tid, ((self._mapFateCard)[mapFateCardData.Tid])[1] - nBeforeEftCount, ((self._mapFateCard)[mapFateCardData.Tid])[2] - nBeforeRoomCount, nCountSum})
            -- DECOMPILER ERROR at PC98: LeaveBlock: unexpected jumping out DO_STMT

            -- DECOMPILER ERROR at PC98: LeaveBlock: unexpected jumping out IF_ELSE_STMT

            -- DECOMPILER ERROR at PC98: LeaveBlock: unexpected jumping out IF_STMT

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
        -- DECOMPILER ERROR at PC130: Confused about usage of register: R13 in 'UnsetPending'

        if ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] == nil then
          ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] = 0
        end
        local nCurLevel = ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid]
        local nNextLevel = ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] + mapPotentialInfo.Level
        mapPotentialChange[mapPotentialInfo.Tid] = {nLevel = nCurLevel, nNextLevel = nNextLevel}
        -- DECOMPILER ERROR at PC149: Confused about usage of register: R15 in 'UnsetPending'

        ;
        ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] = nNextLevel
      end
    end
  end
  do
    if mapData["proto.TowerItemInfo"] ~= nil then
      for _,mapItemInfo in ipairs(mapData["proto.TowerItemInfo"]) do
        -- DECOMPILER ERROR at PC166: Confused about usage of register: R11 in 'UnsetPending'

        if (self._mapItem)[mapItemInfo.Tid] == nil then
          (self._mapItem)[mapItemInfo.Tid] = 0
        end
        -- DECOMPILER ERROR at PC174: Confused about usage of register: R11 in 'UnsetPending'

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
          -- DECOMPILER ERROR at PC205: Confused about usage of register: R11 in 'UnsetPending'

          if (self._mapItem)[mapItemInfo.Tid] == nil then
            (self._mapItem)[mapItemInfo.Tid] = 0
          end
          -- DECOMPILER ERROR at PC213: Confused about usage of register: R11 in 'UnsetPending'

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
        return tbChangeFateCard, mapRewardChange, mapPotentialChange
      end
    end
  end
end

StarTowerSweepData.ProcessTowerChangeData = function(self, mapChange)
  -- function num : 0_14 , upvalues : _ENV
  if not mapChange then
    return {}, {}
  end
  local mapChangeNote = {}
  if mapChange.Infos and next(mapChange.Infos) ~= nil then
    for _,mapNoteInfo in ipairs(mapChange.Infos) do
      print((string.format)("���������仯��%d,%d", mapNoteInfo.Tid, mapNoteInfo.Qty))
      -- DECOMPILER ERROR at PC33: Confused about usage of register: R8 in 'UnsetPending'

      if (self._mapNote)[mapNoteInfo.Tid] == nil then
        (self._mapNote)[mapNoteInfo.Tid] = 0
      end
      -- DECOMPILER ERROR at PC41: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (self._mapNote)[mapNoteInfo.Tid] = (self._mapNote)[mapNoteInfo.Tid] + mapNoteInfo.Qty
      mapChangeNote[mapNoteInfo.Tid] = mapNoteInfo
    end
  end
  do
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
end

StarTowerSweepData.HandleNpc = function(self, nNpcId, nNpcUid)
  -- function num : 0_15 , upvalues : _ENV
  if self.blockNpcBtn then
    return 
  end
  local nCaseId = (self.mapNpc)[nNpcId]
  if nCaseId == nil then
    printError("Npcû�ж�Ӧ�¼�ID:" .. nNpcId)
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
    local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.NpcOptionPanel, 0, 0, {}, nSkinId, 1, {}, {}, nTalkId, 0, true, true, nCoin, self.nTowerId, self._mapNote)
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
                  printError("�������¼�")
                end
              end
            end
          end
        end
      end
      printError("û���ҵ��ɽ������¼�:" .. nNpcId)
    end
  end
end

StarTowerSweepData.HandleCases = function(self)
  -- function num : 0_16 , upvalues : _ENV
  if (self.mapCases)[(self.EnumCase).Battle] ~= nil and ((self.mapCases)[(self.EnumCase).Battle]).bFinish ~= true then
    local msg = {}
    local nEventId = ((self.mapCases)[(self.EnumCase).Battle]).Id
    msg.Id = nEventId
    msg.BattleEndReq = {}
    -- DECOMPILER ERROR at PC38: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (msg.BattleEndReq).Victory = {HP = 0, Time = 0, ClientData = "", 
fateCardUsage = {}
, DateLen = 0, 
Damages = {}
, 
Sample = {}
, 
Events = {
List = {}
}
}
    local callback = function(callbackMsg)
    -- function num : 0_16_0 , upvalues : self
    -- DECOMPILER ERROR at PC12: Confused about usage of register: R1 in 'UnsetPending'

    if callbackMsg ~= nil and callbackMsg.SelectResp ~= nil then
      ((self.mapCases)[(self.EnumCase).Battle]).bFinish = ((callbackMsg.SelectResp).Resp).OptionsResult
    else
      -- DECOMPILER ERROR at PC18: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self.mapCases)[(self.EnumCase).Battle]).bFinish = true
    end
    self:HandleCases()
  end

    self:StarTowerInteract(msg, callback)
    return 
  end
  do
    if (self.tbPopup)[(self.EnumPopup).StrengthFx] ~= nil then
      for _,mapData in ipairs((self.tbPopup)[(self.EnumPopup).StrengthFx]) do
        if not mapData.bFinish then
          self:HandleShopStrengthFx(mapData)
          return 
        end
      end
    end
    do
      if (self.tbPopup)[(self.EnumPopup).Potential] ~= nil then
        for _,mapData in ipairs((self.tbPopup)[(self.EnumPopup).Potential]) do
          if not mapData.bFinish then
            self:HandlePopupPotential(mapData)
            return 
          end
        end
      end
      do
        if (self.tbPopup)[(self.EnumPopup).Reward] ~= nil then
          for _,mapData in ipairs((self.tbPopup)[(self.EnumPopup).Reward]) do
            if not mapData.bFinish then
              self:HandlePopupReward(mapData)
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
                  self:OpenSelectPotential(nId, true)
                  return 
                end
              end
            end
            do
              if (self.mapCases)[(self.EnumCase).PotentialSelect] ~= nil then
                for nId,mapData in pairs((self.mapCases)[(self.EnumCase).PotentialSelect]) do
                  if mapData.bFinish ~= true then
                    self:OpenSelectPotential(nId)
                    return 
                  end
                end
              end
              do
                if (self.mapCases)[(self.EnumCase).NoteSelect] ~= nil then
                  for nId,mapData in pairs((self.mapCases)[(self.EnumCase).NoteSelect]) do
                    if mapData.bFinish ~= true then
                      self:OpenSelectNote(nId)
                      return 
                    end
                  end
                end
                do
                  if (self.mapCases)[(self.EnumCase).FateCardSelect] ~= nil then
                    for nId,mapData in pairs((self.mapCases)[(self.EnumCase).FateCardSelect]) do
                      if mapData.bFinish ~= true then
                        self:OpenSelectFateCard(nId)
                        return 
                      end
                    end
                  end
                  do
                    if (self.tbPopup)[(self.EnumPopup).Disc] ~= nil then
                      for _,mapData in ipairs((self.tbPopup)[(self.EnumPopup).Disc]) do
                        if not mapData.bFinish then
                          self:HandlePopupDisc(mapData)
                          return 
                        end
                      end
                    end
                    do
                      if (self.mapCases)[(self.EnumCase).NpcEvent] ~= nil then
                        for nId,mapData in pairs((self.mapCases)[(self.EnumCase).NpcEvent]) do
                          if mapData.bFinish ~= true then
                            self:HandleNpc(mapData.NPCId)
                            return 
                          end
                        end
                      end
                      do
                        if (self.mapCases)[(self.EnumCase).DoorDanger] ~= nil then
                          for nId,mapData in pairs((self.mapCases)[(self.EnumCase).DoorDanger]) do
                            if mapData.bFinish ~= true then
                              self:HandleNpc(mapData.NpcId)
                              mapData.bFinish = true
                              return 
                            end
                          end
                        end
                        do
                          ;
                          (EventManager.Hit)("EventHandleOver")
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
      end
    end
  end
end

StarTowerSweepData.OpenSelectPotential = function(self, nCaseId, bSpecial)
  -- function num : 0_17 , upvalues : _ENV
  local ProcessSpecialPotentialData = function(nId)
    -- function num : 0_17_0 , upvalues : self, _ENV
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
      if ((self._mapPotential)[nCharId])[nPotentialId] ~= nil then
        mapPotential[nPotentialId] = ((self._mapPotential)[nCharId])[nPotentialId]
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
    -- function num : 0_17_1 , upvalues : self, _ENV
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
      if ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid] ~= nil then
        mapPotential[mapPotentialInfo.Tid] = ((self._mapPotential)[nCharId])[mapPotentialInfo.Tid]
      end
    end
    local mapRoll = {CanReRoll = mapCaseData.CanReRoll, ReRollPrice = mapCaseData.ReRollPrice}
    return tbPotential, mapPotential, mapCaseData.Type, mapCaseData.TeamLevel, mapCaseData.NewIds, mapRoll, mapCaseData.LuckyIds
  end

  local GetUnfinishedSelect = function()
    -- function num : 0_17_2 , upvalues : self, _ENV, ProcessSpecialPotentialData, ProcessPotentialData
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
    -- function num : 0_17_3 , upvalues : _ENV, self, GetUnfinishedSelect
    do
      if nId == -1 then
        local wait = function()
      -- function num : 0_17_3_0 , upvalues : _ENV, self
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
      -- function num : 0_17_3_1 , upvalues : self, nId, GetUnfinishedSelect, _ENV, panelCallback
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
      local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
      if panelCallback ~= nil and type(panelCallback) == "function" then
        local tbRecommend = self:GetRecommondPotential(tbPotential)
        panelCallback(caseId, tbPotential, mapPotential, nType, nTeamLevel, tbNewIds, mapRoll, nCoin, tbLuckyIds, tbRecommend)
      end
    end

      self:StarTowerInteract(msg, InteractiveCallback)
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
  local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
  local tbRecommend = self:GetRecommondPotential(tbPotential)
  ;
  (EventManager.Hit)("StarTowerPotentialSelect", nCaseId, tbPotential, mapPotential, nType, nTeamLevel, tbNewIds, SelectCallback, mapRoll, nCoin, tbLuckyIds, tbRecommend)
end

StarTowerSweepData.OpenSelectNote = function(self, nCaseId)
  -- function num : 0_18 , upvalues : _ENV
  local ProcessNoteData = function(nId)
    -- function num : 0_18_0 , upvalues : self
    local mapCaseData = ((self.mapCases)[(self.EnumCase).NoteSelect])[nId]
    local tbNoteSelect = mapCaseData.Info
    local mapNote = self._mapNote
    return tbNoteSelect, mapNote
  end

  local GetUnfinishedSelect = function()
    -- function num : 0_18_1 , upvalues : self, _ENV, ProcessNoteData
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
    -- function num : 0_18_2 , upvalues : _ENV, self, GetUnfinishedSelect
    do
      if nIdx == -1 then
        local wait = function()
      -- function num : 0_18_2_0 , upvalues : _ENV, self
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
      -- function num : 0_18_2_1 , upvalues : self, GetUnfinishedSelect, panelCallback, _ENV
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

      self:StarTowerInteract(msg, InteractiveCallback)
    end
  end

  local tbNoteSelect, mapNote = ProcessNoteData(nCaseId)
  ;
  (EventManager.Hit)("StarTowerSelectNote", nCaseId, mapNote, tbNoteSelect, SelectCallback)
end

StarTowerSweepData.OpenSelectFateCard = function(self, nCaseId)
  -- function num : 0_19 , upvalues : _ENV
  local ProcessFateCard = function(nId)
    -- function num : 0_19_0 , upvalues : self
    local mapCaseData = ((self.mapCases)[(self.EnumCase).FateCardSelect])[nId]
    local tbFateCard = mapCaseData.Ids
    local tbNewIds = mapCaseData.NewIds
    local bReward = mapCaseData.Give
    local mapRoll = {CanReRoll = mapCaseData.CanReRoll, ReRollPrice = mapCaseData.ReRollPrice}
    return tbFateCard, tbNewIds, mapRoll, bReward
  end

  local GetUnfinishedSelect = function()
    -- function num : 0_19_1 , upvalues : self, _ENV, ProcessFateCard
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
    -- function num : 0_19_2 , upvalues : _ENV, self, GetUnfinishedSelect
    do
      if nIdx == -1 then
        local wait = function()
      -- function num : 0_19_2_0 , upvalues : _ENV, self
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
      -- function num : 0_19_2_1 , upvalues : self, nId, GetUnfinishedSelect, _ENV, panelCallback
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
      local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
      if panelCallback ~= nil and type(panelCallback) == "function" then
        panelCallback(caseId, tbFateCard, tbNewIds, mapRoll, nCoin, bReward)
      end
    end

      self:StarTowerInteract(msg, InteractiveCallback)
    end
  end

  local tbFateCard, tbNewIds, mapRoll, bReward = ProcessFateCard(nCaseId)
  local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
  ;
  (EventManager.Hit)("StarTowerSelectFateCard", nCaseId, tbFateCard, tbNewIds, SelectCallback, mapRoll, nCoin, bReward)
end

StarTowerSweepData.OpenNpcOptionPanel = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_20 , upvalues : _ENV
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
  if mapCase.bFinish then
    local tbChat = ((ConfigTable.GetData)("NPCConfig", nNpcConfigId)).Lines
    local nCount = #tbChat
    local nTalkId = tbChat[1]
    if nCount > 1 then
      nTalkId = tbChat[(math.random)(1, #tbChat)]
    end
    if nTalkId == nil then
      nTalkId = 0
    end
    local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.NpcOptionPanel, 0, 0, {}, nSkinId, 1, {}, {}, nTalkId, 0, true, true, nCoin, self.nTowerId, self._mapNote)
    return 
  end
  do
    local tbOption = mapCase.Options
    local tbUnabledOption = mapCase.FailedIdxes
    local nTableEvtId = mapCase.EvtId
    local nEventId = nCaseId
    local callback = function(nIdx, nEvtId, bClose)
    -- function num : 0_20_0 , upvalues : _ENV, nNpcConfigId, self, nCaseId, tbOption, mapCase
    (EventManager.Hit)("InteractiveNpcFinish", nNpcConfigId)
    -- DECOMPILER ERROR at PC13: Confused about usage of register: R3 in 'UnsetPending'

    if bClose then
      (((self.mapCases)[(self.EnumCase).NpcEvent])[nCaseId]).bFinish = true
      self:HandleCases()
      return 
    end
    local nOptionId = tbOption[nIdx]
    local mapOptionData = (ConfigTable.GetData)("EventOptions", nOptionId)
    local bJump = false
    if mapOptionData ~= nil then
      bJump = mapOptionData.IgnoreInterActive
    else
      printError("EventOptions Missing��" .. nOptionId)
    end
    -- DECOMPILER ERROR at PC42: Confused about usage of register: R6 in 'UnsetPending'

    if bJump then
      (((self.mapCases)[(self.EnumCase).NpcEvent])[nCaseId]).bFinish = true
      self:HandleCases()
      return 
    end
    local msg = {}
    msg.Id = nEvtId
    msg.SelectReq = {}
    -- DECOMPILER ERROR at PC53: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (msg.SelectReq).Index = nIdx - 1
    local InteractiveCallback = function(callbackMsg, tbChangeFateCard, mapChangeNote, mapItemChange, nLevelChange, nExpChange, mapPotentialChange)
      -- function num : 0_20_0_0 , upvalues : _ENV, self, nCaseId, mapCase, nIdx, nNpcConfigId
      local wait = function()
        -- function num : 0_20_0_0_0 , upvalues : _ENV, self
        (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
        ;
        (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
        self:HandleCases()
      end

      local bSuccess = false
      if callbackMsg.SelectResp ~= nil and (callbackMsg.SelectResp).Resp ~= nil then
        bSuccess = ((callbackMsg.SelectResp).Resp).OptionsResult
      end
      -- DECOMPILER ERROR at PC20: Confused about usage of register: R9 in 'UnsetPending'

      if bSuccess then
        (((self.mapCases)[(self.EnumCase).NpcEvent])[nCaseId]).bFinish = true
        local tbInfo = {}
        for _,mapChange in ipairs(((callbackMsg.SelectResp).Resp).AffinityChange) do
          (table.insert)(tbInfo, {NPCId = mapChange.NPCId, Affinity = mapChange.Affinity})
          ;
          (EventManager.Hit)("ShowNPCAffinity", mapChange.NPCId, mapChange.Increase)
        end
        -- DECOMPILER ERROR at PC51: Confused about usage of register: R10 in 'UnsetPending'

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
          self:HandleNpc(nNpcConfigId)
          if callbackMsg.SelectResp ~= nil and (callbackMsg.SelectResp).Resp ~= nil and ((callbackMsg.SelectResp).Resp).OptionsParamId ~= nil and ((callbackMsg.SelectResp).Resp).OptionsParamId ~= 0 then
            local sTextId = "EventResult_" .. tostring(((callbackMsg.SelectResp).Resp).OptionsParamId)
            local sResultHint = (ConfigTable.GetUIText)(sTextId)
            ;
            (EventManager.Hit)(EventId.OpenMessageBox, sResultHint)
          end
        end
      end
    end

    self:StarTowerInteract(msg, InteractiveCallback)
  end

    local mapAffinity = {}
    for _,mapInfo in ipairs(mapCase.Infos) do
      mapAffinity[mapInfo.NPCId] = mapInfo.Affinity
    end
    local tbLines = ((ConfigTable.GetData)("NPCConfig", nNpcConfigId)).FirstLines
    local tbChat = {}
    for _,nTalkId in ipairs(tbLines) do
      local mapTalkCfg = (ConfigTable.GetData)("StarTowerTalk", nTalkId)
      if mapTalkCfg ~= nil and mapAffinity[mapTalkCfg.NPCId] ~= nil then
        local nAffinity = mapAffinity[mapTalkCfg.NPCId]
        if #mapTalkCfg.Affinity == 2 and nAffinity ~= nil and (mapTalkCfg.Affinity)[1] <= nAffinity and nAffinity <= (mapTalkCfg.Affinity)[2] then
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
    local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.NpcOptionPanel, 1, nEventId, tbOption, nSkinId, callback, tbUnabledOption, nTableEvtId, nTalkId, mapCase.nActionId, false, true, nCoin, self.nTowerId, self._mapNote)
  end
end

StarTowerSweepData.HandleRecover = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_21 , upvalues : _ENV
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
  local nHp = 0
  local msg = {}
  msg.Id = nCaseId
  msg.RecoveryHPReq = {}
  -- DECOMPILER ERROR at PC38: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (msg.RecoveryHPReq).Hp = nHp
  local callback = function(_, msgData)
    -- function num : 0_21_0 , upvalues : self, nCaseId
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

    (((self.mapCases)[(self.EnumCase).RecoveryHP])[nCaseId]).bFinish = true
    self:HandleCases()
  end

  self:StarTowerInteract(msg, callback)
end

StarTowerSweepData.HandleNpcRecover = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_22 , upvalues : _ENV
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
    local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.NpcOptionPanel, 0, 0, {}, nSkinId, 1, {}, {}, nTalkId, 0, true, true, nCoin, self.nTowerId, self._mapNote)
    return 
  end
  do
    local nHp = 0
    local msg = {}
    msg.Id = nCaseId
    msg.RecoveryHPReq = {}
    -- DECOMPILER ERROR at PC92: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (msg.RecoveryHPReq).Hp = nHp
    local callback = function(_, msgData)
    -- function num : 0_22_0 , upvalues : _ENV, nNpcConfigId, self, nCaseId
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("StarTower_NpcRecoverTips"))
    ;
    (EventManager.Hit)("InteractiveNpcFinish", nNpcConfigId)
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (((self.mapCases)[(self.EnumCase).NpcRecoveryHP])[nCaseId]).bFinish = true
    self:HandleCases()
  end

    self:StarTowerInteract(msg, callback)
  end
end

StarTowerSweepData.HandleNpcDangerRoom = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_23 , upvalues : _ENV
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
    -- function num : 0_23_0 , upvalues : _ENV, nNpcConfigId, nRoomType, self
    (EventManager.Hit)("InteractiveNpcFinish", nNpcConfigId)
    if nIdx == 1 then
      (EventManager.Hit)("SweepEnterDangerRoom", nEvtId, nRoomType)
    else
      self:HandleCases()
    end
  end

  local tbChat = ((ConfigTable.GetData)("NPCConfig", nNpcConfigId)).Lines
  local nTalkId = tbChat[(math.random)(1, #tbChat)]
  if nTalkId == nil then
    nTalkId = 0
  end
  local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.NpcOptionPanel, 2, nCaseId, {}, nSkinId, callback, {}, 0, nTalkId, 0, false, true, nCoin, self.nTowerId, self._mapNote)
end

StarTowerSweepData.HandlePopupDisc = function(self, mapData)
  -- function num : 0_24 , upvalues : _ENV
  local callback = function()
    -- function num : 0_24_0 , upvalues : mapData, self
    mapData.bFinish = true
    self:HandleCases()
  end

  ;
  (EventManager.Hit)("StarTowerShowDiscSkill", mapData.param, clone(self._mapNote), callback)
end

StarTowerSweepData.HandlePopupReward = function(self, mapData)
  -- function num : 0_25 , upvalues : _ENV
  local callback = function()
    -- function num : 0_25_0 , upvalues : mapData, self
    mapData.bFinish = true
    self:HandleCases()
  end

  ;
  (EventManager.Hit)("StarTowerShowReward", mapData.param, callback)
end

StarTowerSweepData.HandlePopupPotential = function(self, mapData)
  -- function num : 0_26 , upvalues : _ENV
  local callback = function()
    -- function num : 0_26_0 , upvalues : mapData, self
    mapData.bFinish = true
    self:HandleCases()
  end

  ;
  (EventManager.Hit)("ShowPotentialLevelUp", mapData.param, callback)
end

StarTowerSweepData.HandleShopStrengthFx = function(self, mapData)
  -- function num : 0_27 , upvalues : _ENV
  local callback = function()
    -- function num : 0_27_0 , upvalues : mapData, self
    mapData.bFinish = true
    self:HandleCases()
  end

  ;
  (EventManager.Hit)("ShowShopStrengthFx", mapData.param, callback)
end

StarTowerSweepData.InteractiveShop = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_28 , upvalues : _ENV
  if (self.mapCases)[(self.EnumCase).Hawker] == nil then
    printError("No Hawker Case!")
    return 
  end
  local mapCase = (self.mapCases)[(self.EnumCase).Hawker]
  if mapCase == nil then
    printError("No Hawker Case! :" .. nCaseId)
    return 
  end
  local BuildRollData = function(case)
    -- function num : 0_28_0
    return {CanReRoll = case.CanReRoll, ReRollPrice = case.ReRollPrice, ReRollTimes = case.ReRollTimes}
  end

  local BuildShopData = function(case)
    -- function num : 0_28_1 , upvalues : _ENV, self
    local tbShopData = {}
    for index,mapGood in ipairs(case.List) do
      tbShopData[index] = {Idx = mapGood.Idx, bSoldOut = (table.indexof)(case.Purchase, mapGood.Sid) > 0, Price = mapGood.Price, nDiscount = mapGood.Discount, nCharId = mapGood.CharPos > 0 and (self.tbTeam)[mapGood.CharPos] or 0, nSid = mapGood.Sid, nType = mapGood.Type, nGoodsId = mapGood.GoodsId}
    end
    do return tbShopData end
    -- DECOMPILER ERROR: 4 unprocessed JMP targets
  end

  local BuyCallback = function(nEvtId, nSid, callback, bReRoll)
    -- function num : 0_28_2 , upvalues : _ENV, self, BuildRollData, BuildShopData
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
      -- function num : 0_28_2_0 , upvalues : callback, _ENV, self, BuildRollData, BuildShopData, nSid
      if not (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] then
        local nBagCount = callback == nil or type(callback) ~= "function" or 0
      end
      local mapInteractiveCase = (self.mapCases)[(self.EnumCase).Hawker]
      -- DECOMPILER ERROR at PC27: Confused about usage of register: R9 in 'UnsetPending'

      if mapInteractiveCase.bReRoll then
        ((self.mapCases)[(self.EnumCase).Hawker]).bReRoll = false
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

    self:StarTowerInteract(msg, InteractiveCallback)
  end

  local mapRoll = BuildRollData(mapCase)
  local tbShopData = BuildShopData(mapCase)
  local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency] or 0
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.StarTowerShop, tbShopData, nCoin, BuyCallback, nCaseId, mapRoll, self.tbDisc, self._mapNote, self.nTowerId, self.nCurLevel)
end

StarTowerSweepData.InteractiveStrengthMachine = function(self, nCaseId, nNpcConfigId)
  -- function num : 0_29 , upvalues : _ENV
  if (self.mapCases)[(self.EnumCase).StrengthenMachine] == nil then
    printError("No StrengthMachine Case!")
    return 
  end
  local mapCase = (self.mapCases)[(self.EnumCase).StrengthenMachine]
  if mapCase == nil then
    printError("No StrengthMachine Case! :" .. nCaseId)
    return 
  end
  local nCoin = (self._mapItem)[(AllEnum.CoinItemId).FixedRogCurrency]
  if nCoin == nil then
    nCoin = 0
  end
  local nDiscount = mapCase.Discount
  local bFirstFree = mapCase.FirstFree
  local nCost = (self.tbStrengthMachineCost)[mapCase.Times + 1]
  if nCost == nil then
    nCost = (self.tbStrengthMachineCost)[#self.tbStrengthMachineCost]
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
    -- function num : 0_29_0 , upvalues : _ENV, bFirstFree, mapCase, self
    if netmsgData.StrengthenMachineResp ~= nil and not (netmsgData.StrengthenMachineResp).BuySucceed then
      (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("StarTower_NoPotential"))
      printError("û�п�ѡ��Ǳ��")
      return 
    end
    if bFirstFree then
      mapCase.FirstFree = false
    else
      mapCase.Times = mapCase.Times + 1
    end
    self:HandleCases()
    ;
    (EventManager.Hit)("InteractiveNpcFinish")
    ;
    (EventManager.Hit)("RefreshStrengthMachineCost", mapCase.Times, mapCase.FirstFree)
  end

  local msg = {}
  msg.Id = nCaseId
  self:StarTowerInteract(msg, InteractiveCallback)
end

StarTowerSweepData.CalBuildScore = function(self)
  -- function num : 0_30 , upvalues : _ENV
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

StarTowerSweepData.GetDoorCase = function(self)
  -- function num : 0_31
  if (self.mapCases)[(self.EnumCase).OpenDoor] ~= nil then
    return ((self.mapCases)[(self.EnumCase).OpenDoor])[1], ((self.mapCases)[(self.EnumCase).OpenDoor])[2]
  end
  return nil
end

StarTowerSweepData.GetShopAndMachine = function(self)
  -- function num : 0_32
  local bShop = (self.mapCases)[(self.EnumCase).Hawker] ~= nil
  local bMachine = (self.mapCases)[(self.EnumCase).StrengthenMachine] ~= nil
  local nMachineCount, nDiscount, bFirstFree = 0, 0, false
  if bMachine then
    nMachineCount = ((self.mapCases)[(self.EnumCase).StrengthenMachine]).Times
    nDiscount = ((self.mapCases)[(self.EnumCase).StrengthenMachine]).Discount
    bFirstFree = ((self.mapCases)[(self.EnumCase).StrengthenMachine]).FirstFree
  end
  do return bShop, bMachine, nMachineCount, nDiscount, bFirstFree end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

StarTowerSweepData.OpenShop = function(self)
  -- function num : 0_33
  local mapShopCase = (self.mapCases)[(self.EnumCase).Hawker]
  if mapShopCase == nil then
    return false
  end
  local nCaseId = mapShopCase.Id
  self:InteractiveShop(nCaseId, mapShopCase.nNpc)
  return true
end

StarTowerSweepData.OpenStrengthMachine = function(self)
  -- function num : 0_34
  local mapStrengthMachine = (self.mapCases)[(self.EnumCase).StrengthenMachine]
  if mapStrengthMachine == nil then
    return false
  end
  self:InteractiveStrengthMachine(mapStrengthMachine.Id, 0)
  return true
end

StarTowerSweepData.DiscSkillActive = function(self, tbParam)
  -- function num : 0_35 , upvalues : _ENV
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbPopup)[(self.EnumPopup).Disc] == nil then
    (self.tbPopup)[(self.EnumPopup).Disc] = {}
  end
  ;
  (table.insert)((self.tbPopup)[(self.EnumPopup).Disc], {bFinish = false, param = tbParam})
end

StarTowerSweepData.CheckLastShopRoom = function(self)
  -- function num : 0_36
  local bLastRoom = self.nCurLevel == #self.tbStarTowerAllLevel
  do return bLastRoom end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

StarTowerSweepData.GetShopMinPrice = function(self)
  -- function num : 0_37 , upvalues : _ENV
  local nMinPrice = -1
  local mapCase = (self.mapCases)[(self.EnumCase).Hawker]
  if mapCase ~= nil then
    for index,mapGood in ipairs(mapCase.List) do
      local bSoldOut = (table.indexof)(mapCase.Purchase, mapGood.Sid) > 0
      if mapGood.Discount <= 0 or not mapGood.Discount then
        local nPrice = mapGood.Price
      end
      if (nPrice < nMinPrice or nMinPrice == -1) and not bSoldOut then
        nMinPrice = nPrice
      end
    end
    if mapCase.CanReRoll and mapCase.ReRollTimes > 0 and (nMinPrice <= 0 or not (math.min)(nMinPrice, mapCase.ReRollPrice)) then
      nMinPrice = mapCase.ReRollPrice
    end
  end
  do return nMinPrice end
  -- DECOMPILER ERROR: 7 unprocessed JMP targets
end

StarTowerSweepData.GetRecommondPotential = function(self, tbPotentialData)
  -- function num : 0_38 , upvalues : _ENV
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
    -- function num : 0_38_0 , upvalues : self, _ENV
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
    -- function num : 0_38_1 , upvalues : _ENV, self
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

StarTowerSweepData.GetShopGoods = function(self)
  -- function num : 0_39 , upvalues : _ENV
  local nType = self.nRoomType
  local mapStarTower = (ConfigTable.GetData)("StarTower", self.nTowerId)
  if not mapStarTower then
    return 
  end
  local nNpcId = mapStarTower.ShopNpc
  if nType ~= (GameEnum.starTowerRoomType).ShopRoom then
    nNpcId = mapStarTower.StandShopNpc
  end
  if (self.mapCases)[(self.EnumCase).Hawker] and (self.mapNpc)[nNpcId] then
    return ((self.mapCases)[(self.EnumCase).Hawker]).List
  end
end

return StarTowerSweepData

