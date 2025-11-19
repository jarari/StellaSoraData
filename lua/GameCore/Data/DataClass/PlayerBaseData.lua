local PlayerBaseData = class("PlayerBaseData")
local TimerManager = require("GameCore.Timer.TimerManager")
local AvgManager = require("GameCore.Module.AvgManager")
local TimerScaleType = require("GameCore.Timer.TimerScaleType")
local ModuleManager = require("GameCore.Module.ModuleManager")
local localdata = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
local PcEventUpWorldLv = {[5] = "pc_level_5", [10] = "pc_level_10", [15] = "pc_level_15", [20] = "pc_level_20", [25] = "pc_level_25", [30] = "pc_level_30", [35] = "pc_level_35", [40] = "pc_level_40", [45] = "pc_level_45", [50] = "pc_level_50", [55] = "pc_level_55", [60] = "pc_level_60"}
PlayerBaseData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self._nPlayerId = nil
  self._sPlayerNickName = nil
  self._bMale = false
  self._nNewbie = nil
  self._nCreateTime = nil
  self._nHeadIconId = nil
  self._nHashtag = nil
  self._sSignature = nil
  self._nShowSkinId = nil
  self._nTitlePrefix = nil
  self._nTitleSuffix = nil
  self._tbTitle = nil
  self._tbCoreTeam = nil
  self._nWorldClass = 0
  self._nWorldExp = 0
  self._nWorldStage = 0
  self._nCurWorldStageIndex = 0
  self._nCurEnergy = 0
  self._nCurEnergyBattery = 0
  self._nEnergyTime = 0
  self._nEnergyBatteryTime = 0
  self._nBuyEnergyCount = 0
  self._nBuyEnergyLimit = 0
  self._mapEnergyTimer = nil
  self._nOldWorldClass = 0
  self._nOldWorldExp = 0
  self._tbHonorTitle = nil
  self._tbHonorTitleList = nil
  self._nSendGiftCnt = 0
  self._nRenameTime = 0
  self._bWorldClassChange = false
  self.bNewDay = false
  self.bNeedHotfix = false
  self.bShowNewDayWind = false
  self.bInLoading = false
  self:ProcessTableData()
  ;
  (EventManager.Add)(EventId.TransAnimInClear, self, self.OnEvent_TransAnimInClear)
  ;
  (EventManager.Add)(EventId.TransAnimOutClear, self, self.OnEvent_TransAnimOutClear)
  ;
  (EventManager.Add)(EventId.UserEvent_CreateRole, self, self.Event_CreateRole)
  ;
  (EventManager.Add)("Prologue_EventUpload", self, self.PrologueEventUpload)
end

PlayerBaseData.UnInit = function(self)
  -- function num : 0_1
  if self.NextRefreshTimer ~= nil then
    (self.NextRefreshTimer):Cancel()
    self.NextRefreshTimer = nil
  end
  if self._mapEnergyTimer ~= nil then
    (self._mapEnergyTimer):Cancel(nil)
    self._mapEnergyTimer = nil
  end
end

PlayerBaseData.ProcessTableData = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local _PlayerHead = {}
  local tbPlayerHead = {}
  local func_ForEach_Head = function(mapLineData)
    -- function num : 0_2_0 , upvalues : tbPlayerHead, _ENV, _PlayerHead
    tbPlayerHead = {Id = mapLineData.Id, Icon = mapLineData.Icon}
    ;
    (table.insert)(_PlayerHead, tbPlayerHead)
  end

  ForEachTableLine(DataTable.PlayerHead, func_ForEach_Head)
  ;
  (table.sort)(_PlayerHead, function(a, b)
    -- function num : 0_2_1
    do return a.Id < b.Id end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  ;
  (CacheTable.Set)("_PlayerHead", _PlayerHead)
  self._nMaxWorldClass = 0
  local func_ForEach_WorldClass = function(mapLineData)
    -- function num : 0_2_2 , upvalues : self
    self._nMaxWorldClass = self._nMaxWorldClass + 1
  end

  ForEachTableLine(DataTable.WorldClass, func_ForEach_WorldClass)
  self._nBuyEnergyLimit = 0
  local func_ForEach_EnergyBuy = function(mapLineData)
    -- function num : 0_2_3 , upvalues : self, _ENV
    if self._nBuyEnergyLimit < mapLineData.Id then
      self._nBuyEnergyLimit = mapLineData.Id
    end
    ;
    (CacheTable.SetField)("_EnergyBuy", mapLineData.PriceGroup, mapLineData.Id, mapLineData)
  end

  ForEachTableLine(DataTable.EnergyBuy, func_ForEach_EnergyBuy)
  local _tbDemonAdvance = {}
  local foreachTable = function(mapData)
    -- function num : 0_2_4 , upvalues : _ENV, _tbDemonAdvance
    local levelMin = (mapData.LevelRange)[1]
    local levelMax = (mapData.LevelRange)[2]
    local nType = (AllEnum.WorldClassType).LevelUp
    ;
    (table.insert)(_tbDemonAdvance, {nType = nType, nId = mapData.Id, nMinLevel = levelMin, nMaxLevel = levelMax})
    if mapData.AdvanceQuestGroup ~= 0 then
      local nType = (AllEnum.WorldClassType).Advance
      ;
      (table.insert)(_tbDemonAdvance, {nType = nType, nId = mapData.Id, nMinLevel = levelMax, nMaxLevel = levelMax})
    end
  end

  ForEachTableLine((ConfigTable.Get)("DemonAdvance"), foreachTable)
  ;
  (CacheTable.Set)("_DemonAdvance", _tbDemonAdvance)
end

PlayerBaseData.CacheAccInfo = function(self, mapData)
  -- function num : 0_3 , upvalues : _ENV
  if mapData ~= nil then
    self._nPlayerId = mapData.Id
    self._sPlayerNickName = mapData.NickName
    self._nNewbie = mapData.Newbie
    self._nCreateTime = mapData.CreateTime
    self._nHeadIconId = mapData.HeadIcon
    self._nHashtag = mapData.Hashtag
    self._sSignature = mapData.Signature
    self._nShowSkinId = mapData.SkinId
    self._nTitlePrefix = mapData.TitlePrefix
    self._nTitleSuffix = mapData.TitleSuffix
    self._tbCoreTeam = {}
    for i,v in ipairs(mapData.Chars) do
      -- DECOMPILER ERROR at PC30: Confused about usage of register: R7 in 'UnsetPending'

      (self._tbCoreTeam)[i] = v.CharId
    end
    self._bMale = mapData.Gender == true
    self._nSendGiftCnt = mapData.SendGiftCnt or 0
    ;
    (PlayerData.Roguelike):GetClientLocalRoguelikeData()
    ;
    (PlayerData.Guide):SetGuideNewbie(mapData.Newbies)
    -- DECOMPILER ERROR at PC56: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (CS.AdventureModuleHelper).playerUid = mapData.Id
    ;
    ((CS.InputManager).Instance):LoadBindingOverrides(mapData.Id)
    ;
    (EventManager.Hit)("FinishCacheAccInfo")
  end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

PlayerBaseData.CacheEnergyInfo = function(self, mapData)
  -- function num : 0_4 , upvalues : _ENV, TimerManager
  if mapData ~= nil then
    self._nCurEnergy = (mapData.Energy).Primary
    self._nCurEnergyBattery = (mapData.Energy).Secondary
    local nServerTime = ((CS.ClientManager).Instance).serverTimeStamp
    self._nEnergyTime = (mapData.Energy).IsPrimary == true and (mapData.Energy).NextDuration + nServerTime or 0
    if (mapData.Energy).IsPrimary ~= true or not 0 then
      self._nEnergyBatteryTime = (mapData.Energy).NextDuration + nServerTime
      self._nBuyEnergyCount = mapData.Count
      if self._mapEnergyTimer ~= nil then
        (self._mapEnergyTimer):Cancel(nil)
      end
      if (mapData.Energy).NextDuration == 0 then
        return 
      end
      if (mapData.Energy).IsPrimary == false then
        self._mapEnergyBatteryTimer = (TimerManager.Add)(1, (mapData.Energy).NextDuration, self, self.HandleEnergyBatteryTimer, true, true, false)
      else
        self._mapEnergyTimer = (TimerManager.Add)(1, (mapData.Energy).NextDuration, self, self.HandleEnergyTimer, true, true, false)
      end
    end
  end
end

PlayerBaseData.CacheTitleInfo = function(self, mapData)
  -- function num : 0_5 , upvalues : _ENV
  if not mapData then
    return 
  end
  if not self._tbTitle then
    self._tbTitle = {}
  end
  for _,v in pairs(mapData) do
    (table.insert)(self._tbTitle, v.TitleId)
  end
end

PlayerBaseData.CacheHonorTitleInfo = function(self, mapData)
  -- function num : 0_6 , upvalues : _ENV
  if not mapData then
    return 
  end
  self._tbHonorTitle = {}
  for _,v in pairs(mapData) do
    (table.insert)(self._tbHonorTitle, v)
  end
end

PlayerBaseData.CacheHonorTitleList = function(self, mapData)
  -- function num : 0_7 , upvalues : _ENV
  if not mapData then
    return 
  end
  if not self._tbHonorTitleList then
    self._tbHonorTitleList = {}
  end
  for _,v in pairs(mapData) do
    (table.insert)(self._tbHonorTitleList, v)
  end
  self:RefreshHonorTitleRedDot()
end

PlayerBaseData.CacheWorldClassInfo = function(self, mapData)
  -- function num : 0_8
  if mapData ~= nil then
    self._nWorldClass = mapData.Cur
    self._nWorldExp = mapData.LastExp
    self._nWorldStage = mapData.Stage
    self:RefreshCurWorldStageIndex()
  end
end

PlayerBaseData.CacheSendGiftCount = function(self, nCount)
  -- function num : 0_9
  self._nSendGiftCnt = nCount
end

PlayerBaseData.CacheRenameTime = function(self, nTime)
  -- function num : 0_10 , upvalues : _ENV
  self._nRenameTime = nTime
  local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
  local nPastTime = nCurTime - self._nRenameTime
  local nRemain = (ConfigTable.GetConfigNumber)("NickNameResetTimeLimit") - nPastTime
  if nRemain <= 0 then
    self.bRenameCD = false
    return 
  end
  self:SetRenameTimer(nRemain)
end

PlayerBaseData.RefreshEnergyBuyCount = function(self, nCount)
  -- function num : 0_11
  self._nBuyEnergyCount = nCount
end

PlayerBaseData.RefreshSendGiftCount = function(self, nCount)
  -- function num : 0_12
  self._nSendGiftCnt = nCount
end

PlayerBaseData.GetPlayerId = function(self)
  -- function num : 0_13
  return self._nPlayerId
end

PlayerBaseData.GetPlayerNickName = function(self)
  -- function num : 0_14
  return self._sPlayerNickName or "SaiLa"
end

PlayerBaseData.SetPlayerNickName = function(self, sPlayerName)
  -- function num : 0_15 , upvalues : _ENV
  if AVG_EDITOR == true then
    if type(sPlayerName) == "string" and sPlayerName ~= "" then
      self._sPlayerNickName = sPlayerName
    else
      self._sPlayerNickName = nil
    end
  end
end

PlayerBaseData.GetPlayerHashtag = function(self)
  -- function num : 0_16
  return self._nHashtag
end

PlayerBaseData.GetPlayerCoreTeam = function(self)
  -- function num : 0_17
  local tbTeam = {}
  for i = 1, 3 do
    if not (self._tbCoreTeam)[i] then
      tbTeam[i] = 0
    else
      tbTeam[i] = (self._tbCoreTeam)[i]
    end
  end
  return tbTeam
end

PlayerBaseData.GetPlayerAllTitle = function(self)
  -- function num : 0_18 , upvalues : _ENV
  local tbPrefix, tbSuffix = {}, {}
  for _,v in pairs(self._tbTitle) do
    local mapCfg = (ConfigTable.GetData)("Title", v)
    if mapCfg.TitleType == (GameEnum.TitleType).Prefix then
      (table.insert)(tbPrefix, {nId = v, sDesc = mapCfg.Desc, nSort = mapCfg.Sort})
    else
      ;
      (table.insert)(tbSuffix, {nId = v, sDesc = mapCfg.Desc, nSort = mapCfg.Sort})
    end
  end
  ;
  (table.sort)(tbPrefix, function(a, b)
    -- function num : 0_18_0
    do return a.nSort < b.nSort end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  ;
  (table.sort)(tbSuffix, function(a, b)
    -- function num : 0_18_1
    do return a.nSort < b.nSort end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return tbPrefix, tbSuffix
end

PlayerBaseData.GetPlayerTitle = function(self)
  -- function num : 0_19
  return self._nTitlePrefix, self._nTitleSuffix
end

PlayerBaseData.GetPlayerHonorTitle = function(self)
  -- function num : 0_20
  return self._tbHonorTitle
end

PlayerBaseData.GetPlayerHonorTitleList = function(self)
  -- function num : 0_21
  return self._tbHonorTitleList
end

PlayerBaseData.GetPlayerShowSkin = function(self)
  -- function num : 0_22
  return self._nShowSkinId
end

PlayerBaseData.GetPlayerSignature = function(self)
  -- function num : 0_23 , upvalues : _ENV
  if self._sSignature ~= "" or not (ConfigTable.GetUIText)("Friend_DefaultSign") then
    return self._sSignature
  end
end

PlayerBaseData.GetPlayerSex = function(self)
  -- function num : 0_24
  return self._bMale
end

PlayerBaseData.SetPlayerSex = function(self, bIsMale)
  -- function num : 0_25
  self._bMale = bIsMale == true
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerBaseData.IsDefaultHead = function(self, nId)
  -- function num : 0_26
  if nId == 100101 or nId == 101001 then
    return true
  else
    return false
  end
end

PlayerBaseData.ChangePlayerHeadId = function(self, nId)
  -- function num : 0_27
  self._nHeadIconId = nId
end

PlayerBaseData.GetPlayerHeadId = function(self)
  -- function num : 0_28
  return self._nHeadIconId
end

PlayerBaseData.GetPlayerCreatTime = function(self)
  -- function num : 0_29 , upvalues : _ENV
  return (os.date)("%Y.%m.%d", self._nCreateTime)
end

PlayerBaseData.GetPlayerAvgId = function(self)
  -- function num : 0_30
  local sName = "avg0_1"
  return sName
end

PlayerBaseData.HandleEnergyTimer = function(self)
  -- function num : 0_31 , upvalues : _ENV, TimerManager
  if self._nCurEnergy < (ConfigTable.GetConfigNumber)("EnergyMaxLimit") then
    self._nCurEnergy = self._nCurEnergy + 1
    local nEnergyGain = (ConfigTable.GetConfigNumber)("EnergyGain") * 60
    self._nEnergyTime = nEnergyGain + ((CS.ClientManager).Instance).serverTimeStamp
    if self._mapEnergyTimer ~= nil then
      (self._mapEnergyTimer):Cancel(nil)
    end
    self._mapEnergyTimer = (TimerManager.Add)(1, nEnergyGain, self, self.HandleEnergyTimer, true, true, false)
    ;
    (EventManager.Hit)(EventId.UpdateEnergy)
  else
    do
      self._nEnergyTime = 0
      if self._mapEnergyTimer ~= nil then
        (self._mapEnergyTimer):Cancel(nil)
      end
      self:HandleEnergyBatteryTimer()
    end
  end
end

PlayerBaseData.HandleEnergyBatteryTimer = function(self)
  -- function num : 0_32 , upvalues : _ENV, TimerManager
  if self._nCurEnergyBattery < (ConfigTable.GetConfigNumber)("EnergyBatteryMax") then
    self._nCurEnergyBattery = self._nCurEnergyBattery + 1
    local nEnergyBatteryGain = (ConfigTable.GetConfigNumber)("EnergyBatteryGain") * 60
    self._nEnergyBatteryTime = nEnergyBatteryGain + ((CS.ClientManager).Instance).serverTimeStamp
    if self._mapEnergyBatteryTimer ~= nil then
      (self._mapEnergyBatteryTimer):Cancel(nil)
    end
    self._mapEnergyBatteryTimer = (TimerManager.Add)(1, nEnergyBatteryGain, self, self.HandleEnergyBatteryTimer, true, true, false)
    ;
    (EventManager.Hit)(EventId.UpdateEnergyBattery)
  else
    do
      self._nEnergyBatteryTime = 0
      if self._mapEnergyBatteryTimer ~= nil then
        (self._mapEnergyBatteryTimer):Cancel(nil)
      end
    end
  end
end

PlayerBaseData.ChangeEnergy = function(self, mapData)
  -- function num : 0_33 , upvalues : _ENV, TimerManager
  if mapData ~= nil then
    if self._mapEnergyTimer ~= nil then
      (self._mapEnergyTimer):Cancel(nil)
    end
    if self._mapEnergyBatteryTimer ~= nil then
      (self._mapEnergyBatteryTimer):Cancel(nil)
    end
    local nLength = #mapData
    self._nCurEnergy = (mapData[nLength]).Primary
    self._nCurEnergyBattery = (mapData[nLength]).Secondary
    local nServerTime = ((CS.ClientManager).Instance).serverTimeStamp
    if (mapData[nLength]).IsPrimary == true then
      self._nEnergyTime = (mapData[nLength]).NextDuration + nServerTime
      if (mapData[nLength]).NextDuration ~= 0 then
        self._mapEnergyTimer = (TimerManager.Add)(1, (mapData[nLength]).NextDuration, self, self.HandleEnergyTimer, true, true, false)
      end
    else
      self._nEnergyBatteryTime = (mapData[nLength]).NextDuration + nServerTime
      if (mapData[nLength]).NextDuration ~= 0 then
        self._mapEnergyBatteryTimer = (TimerManager.Add)(1, (mapData[nLength]).NextDuration, self, self.HandleEnergyBatteryTimer, true, true, false)
      end
    end
    ;
    (EventManager.Hit)(EventId.UpdateEnergyBattery)
    ;
    (EventManager.Hit)(EventId.UpdateEnergy)
  end
end

PlayerBaseData.ChangeTitle = function(self, mapData)
  -- function num : 0_34 , upvalues : _ENV
  if not mapData then
    return 
  end
  if not self._tbTitle then
    self._tbTitle = {}
  end
  for _,v in pairs(mapData) do
    (table.insert)(self._tbTitle, v.TitleId)
    ;
    (RedDotManager.SetValid)(RedDotDefine.Friend_Title_Item, v.TitleId, true)
  end
end

PlayerBaseData.ChangeHonorTitle = function(self, mapData)
  -- function num : 0_35 , upvalues : _ENV, localdata, RapidJson
  if not mapData then
    return 
  end
  if not self._tbHonorTitleList then
    self._tbHonorTitleList = {}
  end
  local newData = {}
  local delData = {}
  for _,v in pairs(mapData) do
    (table.insert)(self._tbHonorTitleList, v.NewId)
    local honorData = (ConfigTable.GetData)("Honor", v.NewId)
    do
      do
        do
          if honorData.TabType == (GameEnum.honorTabType).Achieve then
            local foreachHonor = function(mapData)
    -- function num : 0_35_0 , upvalues : _ENV, honorData, delData
    if mapData.TabType == (GameEnum.honorTabType).Achieve and (mapData.Params)[1] == (honorData.Params)[1] and mapData.Priotity < honorData.Priotity then
      (table.insert)(delData, mapData.Id)
      ;
      (RedDotManager.SetValid)(RedDotDefine.Friend_Honor_Title_Item, mapData.Id, true)
    end
  end

            ForEachTableLine((ConfigTable.Get)("Honor"), foreachHonor)
          end
          ;
          (RedDotManager.SetValid)(RedDotDefine.Friend_Honor_Title_Item, v.NewId, true)
          ;
          (table.insert)(newData, v.NewId)
        end
        -- DECOMPILER ERROR at PC51: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
  if #newData > 0 or delData > 0 then
    local sJson = (localdata.GetPlayerLocalData)("HonorTitle")
    local localHonorTilte = decodeJson(sJson)
    if type(localHonorTilte) == "table" then
      if #newData > 0 then
        for k,v in ipairs(newData) do
          (table.insert)(localHonorTilte, v)
        end
      end
      do
        if #delData > 0 then
          for k,v in ipairs(delData) do
            if (table.indexof)(localHonorTilte, delData) then
              (table.removebyvalue)(localHonorTilte, v)
            end
          end
        end
        do
          ;
          (localdata.SetPlayerLocalData)("HonorTitle", (RapidJson.encode)(localHonorTilte))
        end
      end
    end
  end
end

PlayerBaseData.ChangeWorldClass = function(self, mapData)
  -- function num : 0_36 , upvalues : _ENV, PcEventUpWorldLv
  if mapData ~= nil then
    self._nOldWorldClass = self._nWorldClass
    self._nOldWorldExp = self._nWorldExp
    for _,v in ipairs(mapData) do
      self._nWorldClass = self._nWorldClass + v.AddClass
      self._nWorldExp = self._nWorldExp + v.ExpChange
    end
    self:SetWorldClassChange(self._nOldWorldClass ~= self._nWorldClass)
    self:CheckNewFuncUnlockWorldClass(self._nOldWorldClass, self._nWorldClass)
    ;
    (EventManager.Hit)(EventId.UpdateWorldClass)
    if self._nOldWorldClass ~= self._nWorldClass then
      self:RefreshCurWorldStageIndex()
      self:RefreshWorldClassRedDot()
      for i = self._nOldWorldClass + 1, self._nWorldClass do
        if i == 5 then
          local tab = {}
          ;
          (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
          ;
          (NovaAPI.UserEventUpload)("authorizationlevel_5", tab)
        elseif i == 10 then
          local tab = {}
          ;
          (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
          ;
          (NovaAPI.UserEventUpload)("authorizationlevel_10", tab)
        elseif i == 20 then
          local tab = {}
          ;
          (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
          ;
          (NovaAPI.UserEventUpload)("authorizationlevel_20", tab)
        end
        if PcEventUpWorldLv[i] then
          self:UserEventUpload_PC(PcEventUpWorldLv[i])
        end
      end
    end
  end
  -- DECOMPILER ERROR: 6 unprocessed JMP targets
end

PlayerBaseData.ChangeWorldClassInBoard = function(self, mapData)
  -- function num : 0_37 , upvalues : _ENV, PcEventUpWorldLv
  if mapData ~= nil then
    self._nOldWorldClass = self._nWorldClass
    self._nOldWorldExp = self._nWorldExp
    self._nWorldClass = mapData.FinalClass
    self._nWorldExp = mapData.LastExp
    ;
    (EventManager.Hit)(EventId.UpdateWorldClass)
    self:CheckNewFuncUnlockWorldClass(self._nOldWorldClass, self._nWorldClass)
    if self._nOldWorldClass ~= self._nWorldClass then
      local wait = function()
    -- function num : 0_37_0 , upvalues : _ENV, self
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    self:SetWorldClassChange(true)
    self:TryOpenWorldClassUpgrade()
  end

      ;
      (cs_coroutine.start)(wait)
      self:RefreshCurWorldStageIndex()
      self:RefreshWorldClassRedDot()
      for i = self._nOldWorldClass + 1, self._nWorldClass do
        if i == 5 then
          local tab = {}
          ;
          (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
          ;
          (NovaAPI.UserEventUpload)("authorizationlevel_5", tab)
        else
          do
            if i == 10 then
              local tab = {}
              ;
              (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
              ;
              (NovaAPI.UserEventUpload)("authorizationlevel_10", tab)
            else
              do
                do
                  do
                    if i == 20 then
                      local tab = {}
                      ;
                      (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
                      ;
                      (NovaAPI.UserEventUpload)("authorizationlevel_20", tab)
                    end
                    if PcEventUpWorldLv[i] then
                      self:UserEventUpload_PC(PcEventUpWorldLv[i])
                    end
                    -- DECOMPILER ERROR at PC105: LeaveBlock: unexpected jumping out DO_STMT

                    -- DECOMPILER ERROR at PC105: LeaveBlock: unexpected jumping out DO_STMT

                    -- DECOMPILER ERROR at PC105: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                    -- DECOMPILER ERROR at PC105: LeaveBlock: unexpected jumping out IF_STMT

                    -- DECOMPILER ERROR at PC105: LeaveBlock: unexpected jumping out DO_STMT

                    -- DECOMPILER ERROR at PC105: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                    -- DECOMPILER ERROR at PC105: LeaveBlock: unexpected jumping out IF_STMT

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

PlayerBaseData.RefreshCurWorldStageIndex = function(self)
  -- function num : 0_38 , upvalues : _ENV
  self._nCurWorldStageIndex = 0
  local tbDemonAdvanceCfg = (CacheTable.Get)("_DemonAdvance")
  local bMax = (tbDemonAdvanceCfg[#tbDemonAdvanceCfg]).nMaxLevel <= self._nWorldClass
  if bMax then
    self._nCurWorldStageIndex = #tbDemonAdvanceCfg
  else
    for k,v in ipairs(tbDemonAdvanceCfg) do
      -- DECOMPILER ERROR at PC36: Unhandled construct in 'MakeBoolean' P1

      if v.nType == (AllEnum.WorldClassType).LevelUp and v.nMinLevel <= self._nWorldClass and self._nWorldClass < v.nMaxLevel then
        self._nCurWorldStageIndex = k
        break
      end
      if v.nId ~= self._nWorldStage or not k + 1 then
        do
          self._nCurWorldStageIndex = v.nType ~= (AllEnum.WorldClassType).Advance or v.nMinLevel > self._nWorldClass or self._nWorldClass > v.nMaxLevel or k
          do break end
          -- DECOMPILER ERROR at PC63: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC63: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  -- DECOMPILER ERROR: 7 unprocessed JMP targets
end

PlayerBaseData.ChangeWorldStage = function(self, nStageId)
  -- function num : 0_39
  self._nWorldStage = nStageId
  self:RefreshCurWorldStageIndex()
end

PlayerBaseData.TryOpenWorldClassUpgrade = function(self, callback)
  -- function num : 0_40 , upvalues : _ENV
  do
    if self._bWorldClassChange then
      local popUpCallback = function()
    -- function num : 0_40_0 , upvalues : _ENV, callback
    (EventManager.Hit)("Guide_CloseWorldClassPopUp")
    if callback ~= nil then
      callback()
    end
  end

      ;
      (PopUpManager.OpenPopUpPanel)({(GameEnum.PopUpSeqType).WorldClass, (GameEnum.PopUpSeqType).FuncUnlock}, popUpCallback)
    end
    return self._bWorldClassChange
  end
end

PlayerBaseData.OnNextDayRefresh = function(self)
  -- function num : 0_41 , upvalues : _ENV, ModuleManager, AvgManager
  if self.NextRefreshTimer ~= nil then
    (self.NextRefreshTimer):Cancel()
    self.NextRefreshTimer = nil
  end
  local callback = function(_, msgData)
    -- function num : 0_41_0 , upvalues : self, _ENV, ModuleManager, AvgManager
    local curNextRefreshTime = self.NextRefreshTime
    self:SetNextRefreshTime(msgData.ServerTs)
    if msgData.ServerTs < curNextRefreshTime then
      return 
    end
    self:OnNewDay()
    ;
    (EventManager.Hit)(EventId.IsNewDay)
    local bInAdventure = (ModuleManager.GetIsAdventure)()
    local bInStarTowerSweep = not bInAdventure and (PlayerData.State):GetStarTowerSweepState() or (PanelManager.GetCurPanelId)() == PanelId.StarTowerResult or (PanelManager.GetCurPanelId)() == PanelId.StarTowerBuildSave
    local bInAvg = (AvgManager.CheckInAvg)()
    if bInAdventure or bInStarTowerSweep or bInAvg then
      print("Inlevel")
      self.bNewDay = true
      if bInAvg then
        self.bShowNewDayWind = true
      end
      return 
    end
    self:BackToHome()
    -- DECOMPILER ERROR: 5 unprocessed JMP targets
  end

  ;
  (HttpNetHandler.SendPingPong)(HttpNetHandler, true, callback)
end

PlayerBaseData.NeedHotfix = function(self)
  -- function num : 0_42 , upvalues : _ENV
  self.bNeedHotfix = true
  if (NovaAPI.GetCurrentModuleName)() == "MainMenuModuleScene" then
    (PlayerData.Base):OnBackToMainMenuModule()
  end
end

PlayerBaseData.SetNextRefreshTime = function(self, curTimeStamp)
  -- function num : 0_43 , upvalues : _ENV, TimerManager
  local serverTimeStamp = ((CS.ClientManager).Instance).serverTimeStamp
  self.NextRefreshTime = ((CS.ClientManager).Instance):GetNextRefreshTime(curTimeStamp) + 1
  if self.NextRefreshTimer == nil then
    self.NextRefreshTimer = (TimerManager.Add)(-1, 2, self, self.CheckNewDay, true, true, true, nil)
  end
  print("下次刷新时间:" .. self.NextRefreshTime)
  print("距下次刷新时间:" .. self.NextRefreshTime - serverTimeStamp)
end

PlayerBaseData.CheckNewDay = function(self)
  -- function num : 0_44 , upvalues : _ENV
  local serverTimeStamp = ((CS.ClientManager).Instance).serverTimeStamp
  if self.NextRefreshTime < serverTimeStamp then
    self:OnNextDayRefresh()
  end
end

PlayerBaseData.SetWorldClassChange = function(self, bChange, nDemonId, callback)
  -- function num : 0_45 , upvalues : _ENV
  self._bWorldClassChange = bChange
  if bChange then
    if not nDemonId then
      nDemonId = 0
    end
    local mapParam = {nDemonId = nDemonId, callback = callback}
    ;
    (PopUpManager.PopUpEnQueue)((GameEnum.PopUpSeqType).WorldClass, mapParam)
  end
end

PlayerBaseData.OnBackToMainMenuModule = function(self)
  -- function num : 0_46 , upvalues : _ENV
  print("New Day Check")
  if self.bNewDay == true then
    self:OnNextDayRefresh()
    self.bNewDay = false
    if self.bInLoading then
      self.bShowNewDayWind = true
    else
      self:BackToHome()
    end
  end
  if self.bNeedHotfix then
    self.bNeedHotfix = false
    local msg = {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Hotfix_Tip"), callbackConfirm = function()
    -- function num : 0_46_0 , upvalues : _ENV
    (NovaAPI.ExitGame)()
  end
}
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, msg)
  end
end

PlayerBaseData.CheckNextDayForSweep = function(self)
  -- function num : 0_47 , upvalues : _ENV
  local wait = function()
    -- function num : 0_47_0 , upvalues : _ENV, self
    (coroutine.yield)(((CS.UnityEngine).WaitForSeconds)(0.1))
    self:OnBackToMainMenuModule()
  end

  ;
  (cs_coroutine.start)(wait)
end

PlayerBaseData.BackToHome = function(self)
  -- function num : 0_48 , upvalues : _ENV
  if (PanelManager.GetCurPanelId)() ~= PanelId.MainView then
    (EventManager.Hit)("NewDay_Clear_Guide")
    local msg = {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Alert_NextDay"), callbackConfirm = function()
    -- function num : 0_48_0 , upvalues : _ENV
    (PanelManager.Home)()
  end
}
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, msg)
  end
end

PlayerBaseData.GetCurEnergy = function(self)
  -- function num : 0_49
  local mapRet = {}
  mapRet.nEnergy = self._nCurEnergy
  mapRet.nEnergyTime = self._nEnergyTime
  return mapRet
end

PlayerBaseData.GetCurEnergyBattery = function(self)
  -- function num : 0_50
  local mapRet = {}
  mapRet.nEnergyBattery = self._nCurEnergyBattery
  mapRet.nEnergyBatteryTime = self._nEnergyBatteryTime
  return mapRet
end

PlayerBaseData.GetMaxEnergyTime = function(self)
  -- function num : 0_51 , upvalues : _ENV
  local nMaxEnergy = (ConfigTable.GetConfigNumber)("EnergyMaxLimit") or 0
  local nEmptyEnergy = nMaxEnergy - self._nCurEnergy
  if nEmptyEnergy <= 0 then
    return 0
  end
  return (ConfigTable.GetConfigNumber)("EnergyGain") * 60 * nEmptyEnergy
end

PlayerBaseData.GetWorldClass = function(self)
  -- function num : 0_52
  return self._nWorldClass
end

PlayerBaseData.GetMaxWorldClass = function(self)
  -- function num : 0_53
  return self._nMaxWorldClass
end

PlayerBaseData.GetWorldClassState = function(self, nLv)
  -- function num : 0_54 , upvalues : _ENV
  local tbState = (PlayerData.State):GetWorldClassRewardState()
  local nIndex = (math.ceil)(nLv / 8)
  if 1 << nLv - (nIndex - 1) * 8 - 1 & tbState[nIndex] <= 0 then
    do return not tbState[nIndex] end
    do return false end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end
end

PlayerBaseData.GetEnabledWorldClassLv = function(self)
  -- function num : 0_55
  local bEnabled = false
  for i = 2, self._nMaxWorldClass do
    bEnabled = self:GetWorldClassState(i)
    if bEnabled then
      return i, bEnabled
    end
  end
  return self._nWorldClass + 1, false
end

PlayerBaseData.GetWorldExp = function(self)
  -- function num : 0_56
  return self._nWorldExp
end

PlayerBaseData.GetCurWorldClassStageIndex = function(self)
  -- function num : 0_57
  return self._nCurWorldStageIndex
end

PlayerBaseData.GetCurWorldClassStageId = function(self)
  -- function num : 0_58 , upvalues : _ENV
  local mapCfg = ((CacheTable.Get)("_DemonAdvance"))[self._nCurWorldStageIndex]
  if mapCfg ~= nil then
    return mapCfg.nId
  end
  return 0
end

PlayerBaseData.GetOldWorldClass = function(self)
  -- function num : 0_59
  return self._nOldWorldClass
end

PlayerBaseData.GetOldWorldExp = function(self)
  -- function num : 0_60
  return self._nOldWorldExp
end

PlayerBaseData.CheckEnergyEnough = function(self, nId)
  -- function num : 0_61 , upvalues : _ENV
  local mapData = (ConfigTable.GetData_Mainline)(nId)
  if mapData.EnergyConsume > self._nCurEnergy then
    do return mapData == nil end
    do return false end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end
end

PlayerBaseData.GetEnergyBuyCount = function(self)
  -- function num : 0_62
  return self._nBuyEnergyCount
end

PlayerBaseData.GetEnergyBuyLimit = function(self)
  -- function num : 0_63
  return self._nBuyEnergyLimit
end

PlayerBaseData.GetCurEnergyBuyGroup = function(self, nBuyCount)
  -- function num : 0_64 , upvalues : _ENV
  if not (CacheTable.Get)("_EnergyBuy") then
    local energyBuy = {}
  end
  local tbGroupData = {}
  for nGroup,data in pairs(energyBuy) do
    for nId,v in pairs(data) do
      if nId == nBuyCount then
        tbGroupData = data
        break
      end
    end
  end
  return tbGroupData
end

PlayerBaseData.GetSendGiftCount = function(self)
  -- function num : 0_65
  return self._nSendGiftCnt
end

PlayerBaseData.CheckRenameCD = function(self)
  -- function num : 0_66 , upvalues : _ENV
  if self.bRenameCD then
    local nPastTime = (ConfigTable.GetConfigNumber)("NickNameResetTimeLimit") - (((CS.ClientManager).Instance).serverTimeStamp - self._nRenameTime)
    local day = (math.ceil)(nPastTime / 86400)
    if day > 1 then
      (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = orderedFormat((ConfigTable.GetUIText)("Friend_Rename_TimeCDWarning1"), day)})
    else
      ;
      (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Friend_Rename_TimeCDWarning2")})
    end
  end
  do
    return self.bRenameCD
  end
end

PlayerBaseData.SetRenameTimer = function(self, nTime)
  -- function num : 0_67 , upvalues : TimerManager
  if self.timerRename ~= nil then
    (self.timerRename):Cancel(false)
    self.timerRename = nil
  end
  self.bRenameCD = true
  self.timerRename = (TimerManager.Add)(1, nTime, self, function()
    -- function num : 0_67_0 , upvalues : self
    self.bRenameCD = false
  end
, true, true, false)
end

PlayerBaseData.SendPlayerNameEditReq = function(self, sName, callback)
  -- function num : 0_68 , upvalues : _ENV
  local msgData = {Name = sName}
  local successCallback = function(_, mapMainData)
    -- function num : 0_68_0 , upvalues : self, sName, _ENV, callback
    self._sPlayerNickName = sName
    self._nHashtag = mapMainData.Hashtag
    self._nRenameTime = mapMainData.ResetTime
    self:SetRenameTimer((ConfigTable.GetConfigNumber)("NickNameResetTimeLimit"))
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_name_edit_req, msgData, nil, successCallback)
end

PlayerBaseData.SendPlayerWorldClassRewardReceiveReq = function(self, nLv, nStage, callback, nMinLevel)
  -- function num : 0_69 , upvalues : _ENV
  local msgData = {}
  if nLv ~= nil then
    msgData.Class = nLv
  end
  local tbReward = {}
  if nLv ~= nil then
    local mapCfg = (ConfigTable.GetData)("WorldClass", nLv)
    if mapCfg ~= nil then
      local tbRewardCfg = decodeJson(mapCfg.Reward)
      for sItem,nCount in pairs(tbRewardCfg) do
        local nItemId = tonumber(sItem)
        ;
        (table.insert)(tbReward, {Tid = nItemId, Qty = nCount})
      end
    end
  else
    do
      local mapReward = {}
      if not nMinLevel then
        nMinLevel = 1
      end
      for i = nMinLevel, self._nWorldClass do
        local bCanReceive = self:GetWorldClassState(R14_PC44)
        if bCanReceive then
          local mapCfg = (ConfigTable.GetData)(R14_PC44, R15_PC51)
          -- DECOMPILER ERROR at PC54: Overwrote pending register: R14 in 'AssignReg'

          if mapCfg ~= nil then
            R15_PC51 = mapCfg.Reward
            R14_PC44 = R14_PC44(R15_PC51)
            local tbRewardCfg = nil
            R15_PC51 = pairs
            R15_PC51 = R15_PC51(tbRewardCfg)
            for sItem,nCount in R15_PC51 do
              local nItemId = tonumber(sItem)
              if mapReward[nItemId] == nil then
                mapReward[nItemId] = nCount
              else
                mapReward[nItemId] = mapReward[nItemId] + nCount
              end
            end
          end
        end
      end
      for nId,nCount in pairs(mapReward) do
        (table.insert)(tbReward, {Tid = nId, Qty = nCount})
      end
      do
        local successCallback = function(_, mapMainData)
    -- function num : 0_69_0 , upvalues : _ENV, tbReward, self, callback
    (UTILS.OpenReceiveByDisplayItem)(tbReward, mapMainData, function()
      -- function num : 0_69_0_0 , upvalues : _ENV
      if (PlayerData.Guide):GetGuideState() then
        (EventManager.Hit)("Guide_ReceiveWorldClassReward")
      end
    end
)
    self:RefreshCurWorldStageIndex()
    callback(mapMainData)
  end

        ;
        (HttpNetHandler.SendMsg)((NetMsgId.Id).player_world_class_reward_receive_req, msgData, nil, successCallback)
      end
    end
  end
end

PlayerBaseData.SendPlayerWorldClassAdvanceReq = function(self, nStageId, callback)
  -- function num : 0_70 , upvalues : _ENV
  local successCallback = function(_, msgData)
    -- function num : 0_70_0 , upvalues : self, nStageId, _ENV
    local callback = function()
      -- function num : 0_70_0_0 , upvalues : self, nStageId, _ENV
      self:ChangeWorldStage(nStageId)
      ;
      (EventManager.Hit)("DemonAdvanceSuccess")
    end

    self:SetWorldClassChange(true, nStageId, callback)
    self:TryOpenWorldClassUpgrade()
    if callback ~= nil then
      callback(msgData)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_world_class_advance_req, {}, nil, successCallback)
end

PlayerBaseData.SendPlayerCharsShowReq = function(self, tbChar, callback)
  -- function num : 0_71 , upvalues : _ENV
  local msgData = {CharIds = tbChar}
  local successCallback = function(_, mapMainData)
    -- function num : 0_71_0 , upvalues : self, tbChar, callback
    self._tbCoreTeam = tbChar
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_chars_show_req, msgData, nil, successCallback)
end

PlayerBaseData.SendPlayerSignatureEditReq = function(self, sSignature, callback)
  -- function num : 0_72 , upvalues : _ENV
  local msgData = {Signature = sSignature}
  local successCallback = function(_, mapMainData)
    -- function num : 0_72_0 , upvalues : self, sSignature, callback
    self._sSignature = sSignature
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_signature_edit_req, msgData, nil, successCallback)
end

PlayerBaseData.SendPlayerSkinShowReq = function(self, nSkinId, callback)
  -- function num : 0_73 , upvalues : _ENV
  local msgData = {SkinId = nSkinId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_73_0 , upvalues : self, nSkinId, callback
    self._nShowSkinId = nSkinId
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_skin_show_req, msgData, nil, successCallback)
end

PlayerBaseData.SendPlayerTitleEditReq = function(self, nTitlePrefix, nTitleSuffix, callback)
  -- function num : 0_74 , upvalues : _ENV
  local msgData = {TitlePrefix = nTitlePrefix, TitleSuffix = nTitleSuffix}
  local successCallback = function(_, mapMainData)
    -- function num : 0_74_0 , upvalues : self, nTitlePrefix, nTitleSuffix, callback
    self._nTitlePrefix = nTitlePrefix
    self._nTitleSuffix = nTitleSuffix
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_title_edit_req, msgData, nil, successCallback)
end

PlayerBaseData.SendEnergyBuy = function(self, nCount, callback)
  -- function num : 0_75 , upvalues : _ENV
  (HttpNetHandler.SendMsg)((NetMsgId.Id).energy_buy_req, {Value = nCount}, nil, callback)
end

PlayerBaseData.SendEnergyBatteryExtract = function(self, nAmount, callback)
  -- function num : 0_76 , upvalues : _ENV
  (HttpNetHandler.SendMsg)((NetMsgId.Id).energy_extract_req, {Value = nAmount}, nil, callback)
end

PlayerBaseData.PlayerWorldClassRewardReceiveSuc = function(self, mapMainData)
  -- function num : 0_77
end

PlayerBaseData.PlayerWorldClassAdvanceSuc = function(self, mapMainData)
  -- function num : 0_78 , upvalues : _ENV
  (UTILS.OpenReceiveByChangeInfo)(mapMainData.Change)
  local nCurId = self:GetCurWorldClassStageId()
  local mapCfg = (ConfigTable.GetData)("DemonAdvance", nCurId)
  do
    if mapCfg ~= nil then
      local nGroupId = mapCfg.AdvanceQuestGroup
      ;
      (PlayerData.Quest):ReceiveDemonQuest(nGroupId)
    end
    self:RefreshWorldClassRedDot()
  end
end

PlayerBaseData.SendPlayerHonorTitleEditReq = function(self, tbhonorTitle, callback)
  -- function num : 0_79 , upvalues : _ENV
  local msgData = {List = tbhonorTitle}
  local successCallback = function()
    -- function num : 0_79_0 , upvalues : callback
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_honor_edit_req, msgData, nil, successCallback)
end

PlayerBaseData.OnNewDay = function(self)
  -- function num : 0_80
  self._nBuyEnergyCount = 0
  self._nSendGiftCnt = 0
end

PlayerBaseData.RefreshWorldClassRedDot = function(self)
  -- function num : 0_81 , upvalues : _ENV
  local nWorldClass = self:GetWorldClass()
  local nCurStageId = (PlayerData.Base):GetCurWorldClassStageId()
  local tbDemonAdvanceCfg = (CacheTable.Get)("_DemonAdvance")
  for _,v in ipairs(tbDemonAdvanceCfg) do
    local bRedDot = false
    if v.nType == (AllEnum.WorldClassType).LevelUp then
      for lv = v.nMinLevel, v.nMaxLevel do
        local bAble = self:GetWorldClassState(lv)
        if lv <= nWorldClass and bAble then
          bRedDot = true
          break
        end
      end
      do
        do
          ;
          (RedDotManager.SetValid)(RedDotDefine.WorldClass_LevelUp, v.nId, bRedDot)
          if v.nType == (AllEnum.WorldClassType).Advance then
            if nCurStageId == v.nId and nWorldClass == v.nMinLevel then
              local mapCfg = (ConfigTable.GetData)("DemonAdvance", v.nId)
              if mapCfg ~= nil then
                local tbQuestList = (PlayerData.Quest):GetDemonQuestData(mapCfg.AdvanceQuestGroup, v.nId)
                local nAllProgress = #tbQuestList
                local nCurProgress = 0
                for _,v in ipairs(tbQuestList) do
                  if v.nStatus == 1 then
                    nCurProgress = nCurProgress + 1
                  end
                end
                bRedDot = nAllProgress <= nCurProgress
              end
            end
            ;
            (RedDotManager.SetValid)(RedDotDefine.WorldClass_Advance, v.nId, bRedDot)
          end
          -- DECOMPILER ERROR at PC91: LeaveBlock: unexpected jumping out DO_STMT

          -- DECOMPILER ERROR at PC91: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC91: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

PlayerBaseData.RefreshHonorTitleRedDot = function(self)
  -- function num : 0_82 , upvalues : localdata, _ENV
  local sJson = (localdata.GetPlayerLocalData)("HonorTitle")
  local localHonorTilte = decodeJson(sJson)
  if type(localHonorTilte) ~= "table" then
    return 
  end
  for k,v in pairs(localHonorTilte) do
    (RedDotManager.SetValid)(RedDotDefine.Friend_Honor_Title_Item, tonumber(v), true)
  end
end

PlayerBaseData.SendPlayerRedeemCodeReq = function(self, sCode, callback)
  -- function num : 0_83 , upvalues : _ENV
  local msgData = {Value = sCode}
  local successCallback = function(_, msgData)
    -- function num : 0_83_0 , upvalues : callback
    if callback ~= nil then
      callback(msgData.Change)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).redeem_code_req, msgData, nil, successCallback)
end

PlayerBaseData.CheckFunctionBtn = function(self, nFuncId, PassCallback, sSound)
  -- function num : 0_84 , upvalues : _ENV
  if sSound == nil then
    sSound = "ui_common_feedback_error"
  end
  local mapFuncCfgData = (ConfigTable.GetData)("OpenFunc", nFuncId)
  if mapFuncCfgData == nil then
    printError("OpenFunc Data Missing:" .. nFuncId)
    return true
  end
  if mapFuncCfgData.NeedWorldClass > 0 and self._nWorldClass < mapFuncCfgData.NeedWorldClass then
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = sSound, sContent = (UTILS.ParseParamDesc)(mapFuncCfgData.Tips, mapFuncCfgData)})
    return false
  end
  do
    if mapFuncCfgData.NeedConditions > 0 then
      local nLevelStar = (PlayerData.Mainline):GetMianlineLevelStar(mapFuncCfgData.NeedConditions)
      if nLevelStar < 1 then
        (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Tips, sSound = sSound, sContent = (UTILS.ParseParamDesc)(mapFuncCfgData.Tips, mapFuncCfgData)})
        return false
      end
    end
    if type(PassCallback) == "function" then
      PassCallback()
    end
  end
end

PlayerBaseData.CheckFunctionUnlock = function(self, nFuncId, bShowTips)
  -- function num : 0_85 , upvalues : _ENV
  local mapFuncCfgData = (ConfigTable.GetData)("OpenFunc", nFuncId)
  if mapFuncCfgData == nil then
    printError("OpenFunc Data Missing:" .. nFuncId)
    return true
  end
  if mapFuncCfgData.NeedWorldClass > 0 and self._nWorldClass < mapFuncCfgData.NeedWorldClass then
    if bShowTips then
      (EventManager.Hit)(EventId.OpenMessageBox, (UTILS.ParseParamDesc)(mapFuncCfgData.Tips, mapFuncCfgData))
    end
    return false
  end
  do
    if mapFuncCfgData.NeedConditions > 0 then
      local nLevelStar = (PlayerData.Mainline):GetMianlineLevelStar(mapFuncCfgData.NeedConditions)
      if nLevelStar < 1 then
        if bShowTips then
          (EventManager.Hit)(EventId.OpenMessageBox, (UTILS.ParseParamDesc)(mapFuncCfgData.Tips, mapFuncCfgData))
        end
        return false
      end
    end
    return true
  end
end

PlayerBaseData.CheckNewFuncUnlockWorldClass = function(self, nBefore, nNew)
  -- function num : 0_86 , upvalues : _ENV
  local ForEachOpenFucn = function(mapData)
    -- function num : 0_86_0 , upvalues : nBefore, nNew, _ENV, self
    if nBefore < mapData.NeedWorldClass and mapData.NeedWorldClass <= nNew then
      do
        if mapData.NeedConditions > 0 then
          local nLevelStar = (PlayerData.Mainline):GetMianlineLevelStar(mapData.NeedConditions)
          if nLevelStar < 1 then
            return 
          end
        end
        if mapData.PopWindows then
          if self.tbFuncNeedShow == nil then
            self.tbFuncNeedShow = {}
          end
          ;
          (table.insert)(self.tbFuncNeedShow, mapData.Id)
          ;
          (PopUpManager.PopUpEnQueue)((GameEnum.PopUpSeqType).FuncUnlock, self.tbFuncNeedShow)
        end
        ;
        (EventManager.Hit)(EventId.NewFuncUnlockWorldClass, mapData.Id)
      end
    end
  end

  ForEachTableLine(DataTable.OpenFunc, ForEachOpenFucn)
end

PlayerBaseData.CheckNewFuncUnlockMainlinePass = function(self, nMainlineId)
  -- function num : 0_87 , upvalues : _ENV
  local ForEachOpenFucn = function(mapData)
    -- function num : 0_87_0 , upvalues : nMainlineId, self, _ENV
    if mapData.NeedConditions == nMainlineId then
      if mapData.NeedWorldClass > 0 and self._nWorldClass < mapData.NeedWorldClass then
        return 
      end
      if mapData.PopWindows then
        if self.tbFuncNeedShow == nil then
          self.tbFuncNeedShow = {}
        end
        ;
        (table.insert)(self.tbFuncNeedShow, mapData.Id)
        ;
        (PopUpManager.PopUpEnQueue)((GameEnum.PopUpSeqType).FuncUnlock, self.tbFuncNeedShow)
      end
    end
  end

  ForEachTableLine(DataTable.OpenFunc, ForEachOpenFucn)
end

PlayerBaseData.CheckNewFuncUnlockFixedRoguelike = function(self, nFRId)
  -- function num : 0_88 , upvalues : _ENV
  local ForEachOpenFunc = function(mapData)
    -- function num : 0_88_0 , upvalues : nFRId, self, _ENV
    if mapData.NeedRoguelike == nFRId then
      if mapData.NeedWorldClass > 0 and self._nWorldClass < mapData.NeedWorldClass then
        return 
      end
      do
        if mapData.NeedConditions > 0 then
          local nLevelStar = (PlayerData.Mainline):GetMianlineLevelStar(mapData.NeedConditions)
          if nLevelStar < 1 then
            return 
          end
        end
        if mapData.PopWindows then
          if self.tbFuncNeedShow == nil then
            self.tbFuncNeedShow = {}
          end
          print("tbFuncNeedShow:" .. mapData.Id)
          ;
          (table.insert)(self.tbFuncNeedShow, mapData.Id)
          ;
          (PopUpManager.PopUpEnQueue)((GameEnum.PopUpSeqType).FuncUnlock, self.tbFuncNeedShow)
        end
      end
    end
  end

  ForEachTableLine(DataTable.OpenFunc, ForEachOpenFunc)
end

PlayerBaseData.OnEvent_TransAnimInClear = function(self)
  -- function num : 0_89
  self.bInLoading = true
end

PlayerBaseData.OnEvent_TransAnimOutClear = function(self)
  -- function num : 0_90
  if self.bShowNewDayWind and self.bInLoading then
    self.bShowNewDayWind = false
    self:BackToHome()
  end
  self.bInLoading = false
end

PlayerBaseData.Event_CreateRole = function(self)
  -- function num : 0_91 , upvalues : _ENV
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring(self._nPlayerId)})
  ;
  (NovaAPI.UserEventUpload)("role_create", tab)
  ;
  ((CS.SDKManager).Instance):CreateRole(tostring(self._nPlayerId), self._sPlayerNickName, self._nCreateTime)
  local tab_1 = {}
  ;
  (table.insert)(tab_1, {"role_id", tostring(self._nPlayerId)})
  ;
  (NovaAPI.UserEventUpload)("role_login", tab_1)
end

PlayerBaseData.PrologueEventUpload = function(self, index)
  -- function num : 0_92 , upvalues : _ENV
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring(self._nPlayerId)})
  ;
  (table.insert)(tab, {"newbie_tutorial_id", index})
  ;
  (NovaAPI.UserEventUpload)("newbie_tutorial", tab)
  if index == "1" then
    (EventManager.Hit)("FirstInputEnable")
  end
end

PlayerBaseData.UserEventUpload_PC = function(self, eventName)
  -- function num : 0_93 , upvalues : _ENV
  local clientPublishRegion = (CS.ClientConfig).ClientPublishRegion
  local curPlatform = ((CS.ClientManager).Instance).Platform
  if clientPublishRegion == (CS.ClientPublishRegion).JP then
    if curPlatform == "windows" then
      local tab = {}
      ;
      (table.insert)(tab, {"role_id", tostring(self._nPlayerId)})
      ;
      (NovaAPI.UserEventUpload)(eventName, tab)
    else
      do
        local tmpEventName = (string.gsub)(eventName, "pc_", "move_")
        local tab = {}
        ;
        (table.insert)(tab, {"role_id", tostring(self._nPlayerId)})
        ;
        (NovaAPI.UserEventUpload)(tmpEventName, tab)
      end
    end
  end
end

return PlayerBaseData

