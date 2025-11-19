local RapidJson = require("rapidjson")
local PlayerGachaData = class("PlayerGachaData")
IsOpenCardPool = function(sStartTime, sEndTime)
  -- function num : 0_0 , upvalues : _ENV
  if (string.len)(sStartTime) == 0 or (string.len)(sEndTime) == 0 then
    return true
  end
  local nowTime = ((CS.ClientManager).Instance).serverTimeStamp
  do return String2Time(sStartTime) < nowTime and nowTime < String2Time(sEndTime) end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

String2Time = function(sTime)
  -- function num : 0_1 , upvalues : _ENV
  if sTime ~= "" then
    return ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(sTime)
  else
    return 0
  end
end

PlayerGachaData.Init = function(self)
  -- function num : 0_2 , upvalues : _ENV, RapidJson
  self.hadData = false
  self._openedPool = {}
  self:RefreshOpenedPool()
  self._mapGachaCount = {}
  self._mapAupMissTimes = {}
  self._mapAMissTimes = {}
  self._AupGuaranteeTimes = {}
  self._mapTotalGachaTimes = {}
  self._mapRecvFirstTenReward = {}
  self._mapRecvGuaranteeReward = {}
  self._mapGachaTotalTimes = {}
  self._mapGachaHistory = {}
  self._mapPoolProbCache = {}
  self._mapNewbieData = {}
  local func_ForEach_Gacha = function(mapGacha)
    -- function num : 0_2_0 , upvalues : _ENV, RapidJson
    if type(mapGacha.OnceTicket) == "string" then
      mapGacha.OnceTicket = (RapidJson.decode)(mapGacha.OnceTicket)
    end
    if type(mapGacha.TenTimesTicket) == "string" then
      mapGacha.TenTimesTicket = (RapidJson.decode)(mapGacha.TenTimesTicket)
    end
  end

  ForEachTableLine(DataTable.Gacha, func_ForEach_Gacha)
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

PlayerGachaData.RefreshOpenedPool = function(self)
  -- function num : 0_3 , upvalues : _ENV
  self._openedPool = {}
  local func_ForEach_Gacha = function(mapGacha)
    -- function num : 0_3_0 , upvalues : _ENV, self
    if IsOpenCardPool(mapGacha.StartTime, mapGacha.EndTime) then
      (table.insert)(self._openedPool, mapGacha.ID)
    end
  end

  ForEachTableLine(DataTable.Gacha, func_ForEach_Gacha)
end

PlayerGachaData.GetOpenedPool = function(self)
  -- function num : 0_4 , upvalues : _ENV
  local ret = {}
  local func_ForEach_Gacha = function(mapGacha)
    -- function num : 0_4_0 , upvalues : _ENV, self, ret
    if mapGacha.StorageId == (GameEnum.gachaStorageType).BeginnerCardPool then
      local newbieData = self:GetGachaNewbieData(mapGacha.Id)
      if newbieData ~= nil and not newbieData.Receive then
        (table.insert)(ret, mapGacha.Id)
      end
    else
      do
        if IsOpenCardPool(mapGacha.StartTime, mapGacha.EndTime) then
          (table.insert)(ret, mapGacha.Id)
        end
      end
    end
  end

  ForEachTableLine(DataTable.Gacha, func_ForEach_Gacha)
  return ret
end

PlayerGachaData.CacheGachaData = function(self, mapData)
  -- function num : 0_5 , upvalues : _ENV
  for k,v in pairs(mapData) do
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R7 in 'UnsetPending'

    (self._mapGachaCount)[v.Id] = v.DaysCount
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self._mapAupMissTimes)[v.Id] = v.AupMissTimes
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self._mapTotalGachaTimes)[v.Id] = v.TotalTimes
    -- DECOMPILER ERROR at PC19: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self._AupGuaranteeTimes)[v.Id] = v.AupGuaranteeTimes
    -- DECOMPILER ERROR at PC23: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self._mapRecvFirstTenReward)[v.Id] = v.ReveFirstTenReward
    -- DECOMPILER ERROR at PC27: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self._mapRecvGuaranteeReward)[v.Id] = v.RecvGuaranteeReward
    -- DECOMPILER ERROR at PC31: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self._mapGachaTotalTimes)[v.Id] = v.GachaTotalTimes
    -- DECOMPILER ERROR at PC35: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self._mapAMissTimes)[v.Id] = v.AMissTimes
  end
end

PlayerGachaData.CacheGachaHistory = function(self, nSaveId, mapData)
  -- function num : 0_6 , upvalues : _ENV
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R3 in 'UnsetPending'

  if (self._mapGachaHistory)[nSaveId] == nil then
    (self._mapGachaHistory)[nSaveId] = {}
  end
  for _,mapHistory in ipairs(mapData.List) do
    (table.insert)((self._mapGachaHistory)[nSaveId], mapHistory)
  end
end

PlayerGachaData.AddGachaHistory = function(self, nSaveId, nGachaId, mapData)
  -- function num : 0_7 , upvalues : _ENV
  if (self._mapGachaHistory)[nSaveId] == nil then
    return 
  end
  local Ids = {}
  for _,mapCard in ipairs(mapData.Cards) do
    (table.insert)(Ids, (mapCard.Card).Tid)
  end
  ;
  (table.insert)((self._mapGachaHistory)[nSaveId], {Ids = Ids, Time = mapData.Time, Gid = nGachaId})
end

PlayerGachaData.GetGachaCountById = function(self, nPoolID)
  -- function num : 0_8
  if (self._mapGachaCount)[nPoolID] == nil then
    return 0
  else
    return (self._mapGachaCount)[nPoolID]
  end
end

PlayerGachaData.GetGachaTotalCountById = function(self, nPoolID)
  -- function num : 0_9
  if (self._mapTotalGachaTimes)[nPoolID] == nil then
    return 0
  else
    return (self._mapTotalGachaTimes)[nPoolID]
  end
end

PlayerGachaData.GetAupMissTimesById = function(self, nPoolID)
  -- function num : 0_10 , upvalues : _ENV
  local mapPoolCfgData = (ConfigTable.GetData)("Gacha", nPoolID)
  if (self._mapAupMissTimes)[nPoolID] == nil then
    if mapPoolCfgData ~= nil then
      for nId,nCount in pairs(self._mapAupMissTimes) do
        local mapPoolCfg = (ConfigTable.GetData)("Gacha", nId)
        -- DECOMPILER ERROR at PC27: Confused about usage of register: R9 in 'UnsetPending'

        if mapPoolCfg ~= nil and mapPoolCfg.StorageId == mapPoolCfgData.StorageId then
          (self._mapAupMissTimes)[nPoolID] = nCount
          return (self._mapAupMissTimes)[nPoolID]
        end
      end
    else
      do
        do return 0 end
        do return (self._mapAupMissTimes)[nPoolID] end
        return 0
      end
    end
  end
end

PlayerGachaData.GetAMissTimesById = function(self, nPoolID)
  -- function num : 0_11 , upvalues : _ENV
  local mapPoolCfgData = (ConfigTable.GetData)("Gacha", nPoolID)
  if (self._mapAMissTimes)[nPoolID] == nil then
    if mapPoolCfgData ~= nil then
      for nId,nCount in pairs(self._mapAMissTimes) do
        local mapPoolCfg = (ConfigTable.GetData)("Gacha", nId)
        -- DECOMPILER ERROR at PC27: Confused about usage of register: R9 in 'UnsetPending'

        if mapPoolCfg ~= nil and mapPoolCfg.StorageId == mapPoolCfgData.StorageId then
          (self._mapAMissTimes)[nPoolID] = nCount
          return (self._mapAMissTimes)[nPoolID]
        end
      end
    else
      do
        do return 0 end
        do return (self._mapAMissTimes)[nPoolID] end
        return 0
      end
    end
  end
end

PlayerGachaData.GetAupGuaranteeById = function(self, nPoolID)
  -- function num : 0_12 , upvalues : _ENV
  local mapPoolCfgData = (ConfigTable.GetData)("Gacha", nPoolID)
  if (self._AupGuaranteeTimes)[nPoolID] == nil then
    if mapPoolCfgData ~= nil then
      for nId,nCount in pairs(self._AupGuaranteeTimes) do
        local mapPoolCfg = (ConfigTable.GetData)("Gacha", nId)
        -- DECOMPILER ERROR at PC27: Confused about usage of register: R9 in 'UnsetPending'

        if mapPoolCfg ~= nil and mapPoolCfg.StorageId == mapPoolCfgData.StorageId then
          (self._AupGuaranteeTimes)[nPoolID] = nCount
          return (self._AupGuaranteeTimes)[nPoolID]
        end
      end
    else
      do
        do return 0 end
        do return (self._AupGuaranteeTimes)[nPoolID] end
        return 0
      end
    end
  end
end

PlayerGachaData.GetRecvFirstTenReward = function(self, nPoolID)
  -- function num : 0_13
  if (self._mapRecvFirstTenReward)[nPoolID] == nil then
    return false
  else
    return (self._mapRecvFirstTenReward)[nPoolID]
  end
end

PlayerGachaData.GetRecvGuaranteeReward = function(self, nPoolID)
  -- function num : 0_14
  if (self._mapRecvGuaranteeReward)[nPoolID] == nil then
    return false
  else
    return (self._mapRecvGuaranteeReward)[nPoolID]
  end
end

PlayerGachaData.GetGachaTotalTimes = function(self, nPoolID)
  -- function num : 0_15
  if (self._mapGachaTotalTimes)[nPoolID] == nil then
    return 0
  else
    return (self._mapGachaTotalTimes)[nPoolID]
  end
end

PlayerGachaData.GachaCountChanged = function(self, nPoolID, nDayCount)
  -- function num : 0_16
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self._mapGachaCount)[nPoolID] = nDayCount
end

PlayerGachaData.AupMissTimesCountChanged = function(self, nPoolID, nCount)
  -- function num : 0_17 , upvalues : _ENV
  local mapPoolCfgData = (ConfigTable.GetData)("Gacha", nPoolID)
  if mapPoolCfgData ~= nil then
    if nCount == nil then
      nCount = 0
    end
    for nId,_ in pairs(self._mapAupMissTimes) do
      local mapPoolCfg = (ConfigTable.GetData)("Gacha", nId)
      -- DECOMPILER ERROR at PC26: Confused about usage of register: R10 in 'UnsetPending'

      if mapPoolCfg ~= nil and mapPoolCfg.StorageId == mapPoolCfgData.StorageId then
        (self._mapAupMissTimes)[nId] = nCount
      end
    end
  end
  do
    -- DECOMPILER ERROR at PC30: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self._mapAupMissTimes)[nPoolID] = nCount
  end
end

PlayerGachaData.AMissTimesCountChanged = function(self, nPoolID, nCount)
  -- function num : 0_18 , upvalues : _ENV
  local mapPoolCfgData = (ConfigTable.GetData)("Gacha", nPoolID)
  if mapPoolCfgData ~= nil then
    if nCount == nil then
      nCount = 0
    end
    for nId,_ in pairs(self._mapAMissTimes) do
      local mapPoolCfg = (ConfigTable.GetData)("Gacha", nId)
      -- DECOMPILER ERROR at PC26: Confused about usage of register: R10 in 'UnsetPending'

      if mapPoolCfg ~= nil and mapPoolCfg.StorageId == mapPoolCfgData.StorageId then
        (self._mapAMissTimes)[nId] = nCount
      end
    end
  end
  do
    -- DECOMPILER ERROR at PC30: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self._mapAMissTimes)[nPoolID] = nCount
  end
end

PlayerGachaData.TotalCountChanged = function(self, nPoolID, nCount)
  -- function num : 0_19
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self._mapTotalGachaTimes)[nPoolID] = nCount
end

PlayerGachaData.AupGuaranteeTimesChanged = function(self, nPoolID, nCount)
  -- function num : 0_20
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self._AupGuaranteeTimes)[nPoolID] = nCount
end

PlayerGachaData.RecvFirstTenReward = function(self, nPoolID, bValue)
  -- function num : 0_21
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self._mapRecvFirstTenReward)[nPoolID] = bValue
end

PlayerGachaData.RecvGuaranteeReward = function(self, nPoolID, bValue)
  -- function num : 0_22
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self._mapRecvGuaranteeReward)[nPoolID] = bValue
end

PlayerGachaData.GachaTotalTimes = function(self, nPoolID, nCount)
  -- function num : 0_23
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self._mapGachaTotalTimes)[nPoolID] = nCount
end

PlayerGachaData.GetGachaInfomation = function(self, callback)
  -- function num : 0_24 , upvalues : _ENV
  local GetInfoCallback = function(_, mapData)
    -- function num : 0_24_0 , upvalues : self, _ENV, callback
    self.hadData = true
    self:CacheGachaData(mapData.Information)
    if type(callback) == "function" then
      callback()
    end
  end

  -- DECOMPILER ERROR at PC10: Unhandled construct in 'MakeBoolean' P1

  if self.hadData and type(callback) == "function" then
    callback()
  end
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).gacha_information_req, {}, nil, GetInfoCallback)
end

PlayerGachaData.GetGachaHistory = function(self, nSaveId, callback)
  -- function num : 0_25 , upvalues : _ENV
  if (self._mapGachaHistory)[nSaveId] ~= nil then
    if type(callback) == "function" then
      callback((self._mapGachaHistory)[nSaveId])
    end
    return 
  end
  local GetHistoryCallback = function(_, mapData)
    -- function num : 0_25_0 , upvalues : self, nSaveId, _ENV, callback
    self:CacheGachaHistory(nSaveId, mapData)
    if type(callback) == "function" then
      callback((self._mapGachaHistory)[nSaveId])
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).gacha_histories_req, {Value = nSaveId}, nil, GetHistoryCallback)
end

PlayerGachaData.SendGachaReq = function(self, nId, nMode, callback)
  -- function num : 0_26 , upvalues : _ENV
  local GachaCallback = function(_, mapData)
    -- function num : 0_26_0 , upvalues : self, nId, nMode, _ENV, callback
    self:GachaCountChanged(nId, mapData.DaysCount)
    self:AupMissTimesCountChanged(nId, mapData.AupMissTimes)
    self:AMissTimesCountChanged(nId, mapData.AMissTimes)
    self:TotalCountChanged(nId, mapData.TotalTimes)
    self:AupGuaranteeTimesChanged(nId, mapData.AupGuaranteeTimes)
    self:GachaTotalTimes(nId, mapData.GachaTotalTimes)
    if nMode == 2 then
      self:RecvFirstTenReward(nId, true)
    end
    local mapGacha = (ConfigTable.GetData)("Gacha", nId)
    if mapGacha ~= nil and mapGacha.StorageId > 0 then
      self:AddGachaHistory(mapGacha.StorageId, nId, mapData)
    end
    if type(callback) == "function" then
      callback(mapData)
    end
    if nMode == 2 then
      local tab = {}
      ;
      (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
      if mapGacha.StorageId == (GameEnum.gachaStorageType).CharacterCardPool then
        (NovaAPI.UserEventUpload)("standard_trekker_gacha10", tab)
      else
        if mapGacha.StorageId == (GameEnum.gachaStorageType).DiscCardPool then
          (NovaAPI.UserEventUpload)("standard_disc_gacha10", tab)
        else
          if mapGacha.StorageId == (GameEnum.gachaStorageType).CharacterUpCardPool then
            (NovaAPI.UserEventUpload)("limited_trekker_gacha10", tab)
          else
            if mapGacha.StorageId == (GameEnum.gachaStorageType).DiscUpCardPool then
              (NovaAPI.UserEventUpload)("limited_disc_gacha10", tab)
            else
              if mapGacha.StorageId == (GameEnum.gachaStorageType).BeginnerCardPool then
                (NovaAPI.UserEventUpload)("guaranteed5star_gacha10", tab)
              end
            end
          end
        end
      end
    end
  end

  local mapMsgData = {Id = nId, Mode = nMode}
  ;
  (EventManager.Hit)("GachaProcessStart", true)
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).gacha_spin_req, mapMsgData, nil, GachaCallback)
end

PlayerGachaData.GetPoolProbData = function(self, nPoolId)
  -- function num : 0_27
  if (self._mapPoolProbCache)[nPoolId] ~= nil then
    return (self._mapPoolProbCache)[nPoolId]
  else
    local probUpItem, probItem = self:GetPoolProbDetail(nPoolId)
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self._mapPoolProbCache)[nPoolId] = {tbProbUpItem = probUpItem, tbProbItem = probItem}
  end
end

PlayerGachaData.GetPoolProbDetail = function(self, nPoolID)
  -- function num : 0_28 , upvalues : _ENV
  local tbUpItemList = {}
  local tbItemList = {}
  local gachaConfig = (ConfigTable.GetData)("Gacha", nPoolID)
  local nStorageType = gachaConfig.StorageId
  local gachaStorageConfig = (ConfigTable.GetData)("GachaStorage", nStorageType)
  local nBTypeProb = gachaStorageConfig.BTypeProb
  local gachaATypeProbConfig = nil
  local func_ForEach_GachaATypeProb = function(mapData)
    -- function num : 0_28_0 , upvalues : gachaStorageConfig, gachaATypeProbConfig
    if mapData.Group == gachaStorageConfig.ATypeGroup and mapData.Times == 0 then
      gachaATypeProbConfig = mapData
    end
  end

  ForEachTableLine(DataTable.GachaATypeProb, func_ForEach_GachaATypeProb)
  local nATypeProb = gachaATypeProbConfig.Prob
  local nCTypeProb = 10000 - nATypeProb - nBTypeProb
  local nATypePkgUpProb = nATypeProb * gachaStorageConfig.ATypeUpProb / 10000
  local nATypePkgProb = nATypeProb * (1 - gachaStorageConfig.ATypeUpProb / 10000)
  local nBTypePkgUpProb = nBTypeProb * gachaStorageConfig.BTypeUpProb / 10000
  local nBTypePkgGuaranteeProb = nBTypeProb * gachaStorageConfig.BTypeGuaranteeProb / 10000
  local nBTypePkgProb = nBTypeProb * (1 - (gachaStorageConfig.BTypeUpProb + gachaStorageConfig.BTypeGuaranteeProb) / 10000)
  local nCTypePkgProb = 10000 - nATypePkgUpProb - nATypePkgProb - nBTypePkgUpProb - nBTypePkgProb - nBTypePkgGuaranteeProb
  local tbATypeItem = {}
  local tbBTypeItem = {}
  local tbCTypeItem = {}
  local tbATypeUpItem = {}
  local tbBTypeUpItem = {}
  local tbBTypeGuaranteeItem = {}
  local nATypeTotalWeight = 0
  local nBTypeTotalWeight = 0
  local nCTypeTotalWeight = 0
  local nATypeUpTotalWeight = 0
  local nBTypeUpTotalWeight = 0
  local nBTypeGuaranteeWeight = 0
  local func_ForEachGachaPkg = function(mapData)
    -- function num : 0_28_1 , upvalues : gachaConfig, _ENV, tbATypeItem, nATypeTotalWeight, tbBTypeItem, nBTypeTotalWeight, tbBTypeGuaranteeItem, nBTypeGuaranteeWeight, tbCTypeItem, nCTypeTotalWeight, tbATypeUpItem, nATypeUpTotalWeight, tbBTypeUpItem, nBTypeUpTotalWeight
    if mapData.PkgId == gachaConfig.ATypePkg then
      (table.insert)(tbATypeItem, {nGoodsId = mapData.GoodsId, nWeight = mapData.Weight})
      nATypeTotalWeight = nATypeTotalWeight + mapData.Weight
    else
      if mapData.PkgId == gachaConfig.BTypePkg then
        (table.insert)(tbBTypeItem, {nGoodsId = mapData.GoodsId, nWeight = mapData.Weight})
        nBTypeTotalWeight = nBTypeTotalWeight + mapData.Weight
      else
        if mapData.PkgId == gachaConfig.BGuaranteePkg then
          (table.insert)(tbBTypeGuaranteeItem, {nGoodsId = mapData.GoodsId, nWeight = mapData.Weight})
          nBTypeGuaranteeWeight = nBTypeGuaranteeWeight + mapData.Weight
        else
          if mapData.PkgId == gachaConfig.CTypePkg then
            (table.insert)(tbCTypeItem, {nGoodsId = mapData.GoodsId, nWeight = mapData.Weight})
            nCTypeTotalWeight = nCTypeTotalWeight + mapData.Weight
          else
            if mapData.PkgId == gachaConfig.ATypeUpPkg then
              (table.insert)(tbATypeUpItem, {nGoodsId = mapData.GoodsId, nWeight = mapData.Weight})
              nATypeUpTotalWeight = nATypeUpTotalWeight + mapData.Weight
            else
              if mapData.PkgId == gachaConfig.BTypeUpPkg then
                (table.insert)(tbBTypeUpItem, {nGoodsId = mapData.GoodsId, nWeight = mapData.Weight})
                nBTypeUpTotalWeight = nBTypeUpTotalWeight + mapData.Weight
              end
            end
          end
        end
      end
    end
  end

  ForEachTableLine(DataTable.GachaPkg, func_ForEachGachaPkg)
  for _,v in pairs(tbATypeItem) do
    local nProb = v.nWeight / nATypeTotalWeight * nATypePkgProb / 10000 * 100
    ;
    (table.insert)(tbItemList, {nGoodsId = v.nGoodsId, nProbValue = nProb})
  end
  for _,v in pairs(tbBTypeItem) do
    local nProb = v.nWeight / nBTypeTotalWeight * nBTypePkgProb / 10000 * 100
    ;
    (table.insert)(tbItemList, {nGoodsId = v.nGoodsId, nProbValue = nProb})
  end
  for _,v in pairs(tbBTypeGuaranteeItem) do
    local nProb = v.nWeight / nBTypeGuaranteeWeight * nBTypePkgGuaranteeProb / 10000 * 100
    ;
    (table.insert)(tbItemList, {nGoodsId = v.nGoodsId, nProbValue = nProb})
  end
  for _,v in pairs(tbCTypeItem) do
    local nProb = v.nWeight / nCTypeTotalWeight * nCTypePkgProb / 10000 * 100
    ;
    (table.insert)(tbItemList, {nGoodsId = v.nGoodsId, nProbValue = nProb})
  end
  for _,v in pairs(tbATypeUpItem) do
    local nProb = v.nWeight / nATypeUpTotalWeight * nATypePkgUpProb / 10000 * 100
    ;
    (table.insert)(tbUpItemList, {nGoodsId = v.nGoodsId, nProbValue = nProb})
  end
  for _,v in pairs(tbBTypeUpItem) do
    local nProb = v.nWeight / nBTypeUpTotalWeight * nBTypePkgUpProb / 10000 * 100
    ;
    (table.insert)(tbUpItemList, {nGoodsId = v.nGoodsId, nProbValue = nProb})
  end
  local sortItem = function(a, b)
    -- function num : 0_28_2 , upvalues : _ENV
    local aItemConfig = (ConfigTable.GetData_Item)(a.nGoodsId)
    local bItemConfig = (ConfigTable.GetData_Item)(b.nGoodsId)
    if aItemConfig.Rarity < bItemConfig.Rarity then
      return true
    else
      if bItemConfig.Rarity < aItemConfig.Rarity then
        return false
      else
        if aItemConfig.Type == (GameEnum.itemType).Char and bItemConfig.Type == (GameEnum.itemType).Disc then
          return true
        else
          if aItemConfig.Type == (GameEnum.itemType).Disc and bItemConfig.Type == (GameEnum.itemType).Char then
            return false
          else
            return aItemConfig.Id < bItemConfig.Id
          end
        end
      end
    end
    -- DECOMPILER ERROR: 2 unprocessed JMP targets
  end

  ;
  (table.sort)(tbUpItemList, sortItem)
  ;
  (table.sort)(tbItemList, sortItem)
  return tbUpItemList, tbItemList
end

PlayerGachaData.SendGachaGuaranteeRewardReq = function(self, nId, callback)
  -- function num : 0_29 , upvalues : _ENV
  local GachaCallback = function(_, mapData)
    -- function num : 0_29_0 , upvalues : self, nId, _ENV, callback
    self:RecvGuaranteeReward(nId, true)
    if type(callback) == "function" then
      callback(mapData)
    end
  end

  local mapMsgData = {Value = nId}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).gacha_guarantee_reward_receive_req, mapMsgData, nil, GachaCallback)
end

PlayerGachaData.OnEvent_NewDay = function(self)
  -- function num : 0_30
  self.hadData = false
end

PlayerGachaData.CacheGachaNewbieData = function(self, mapData)
  -- function num : 0_31 , upvalues : _ENV
  for _,v in ipairs(mapData) do
    local newbie = {}
    newbie.Id = v.Id
    newbie.Receive = v.Receive
    newbie.Times = v.Times
    newbie.Cards = {}
    for _,v1 in ipairs(v.Cards) do
      local cards = {}
      for _,v2 in ipairs(v1.Values) do
        (table.insert)(cards, v2)
      end
      ;
      (table.insert)(newbie.Cards, cards)
    end
    newbie.Temp = {}
    if v.Temp ~= nil then
      for _,v2 in ipairs((v.Temp).Values) do
        (table.insert)(newbie.Temp, v2)
      end
    end
    do
      do
        -- DECOMPILER ERROR at PC55: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self._mapNewbieData)[v.Id] = newbie
        -- DECOMPILER ERROR at PC56: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
  printTable(self._mapNewbieData)
end

PlayerGachaData.GetGachaNewbieData = function(self, nId)
  -- function num : 0_32
  do
    if (self._mapNewbieData)[nId] == nil then
      local newbie = {}
      newbie.Id = nId
      newbie.Receive = false
      newbie.Times = 0
      newbie.Cards = {}
      newbie.Temp = {}
      -- DECOMPILER ERROR at PC13: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (self._mapNewbieData)[nId] = newbie
    end
    return (self._mapNewbieData)[nId]
  end
end

PlayerGachaData.GetGachaNewbieInfomation = function(self, callback)
  -- function num : 0_33 , upvalues : _ENV
  local GetInfoCallback = function(_, mapData)
    -- function num : 0_33_0 , upvalues : self, _ENV, callback
    self.hadNewbieData = true
    self:CacheGachaNewbieData(mapData.List)
    if type(callback) == "function" then
      callback()
    end
  end

  -- DECOMPILER ERROR at PC10: Unhandled construct in 'MakeBoolean' P1

  if self.hadNewbieData and type(callback) == "function" then
    callback()
  end
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).gacha_newbie_info_req, {}, nil, GetInfoCallback)
end

PlayerGachaData.SendGachaNewbieReq = function(self, nId, callback)
  -- function num : 0_34 , upvalues : _ENV
  local GachaCallback = function(_, mapData)
    -- function num : 0_34_0 , upvalues : self, nId, _ENV, callback
    local data = (self._mapNewbieData)[nId]
    data.Times = data.Times + 1
    data.Temp = {}
    for _,v in ipairs(mapData.Cards) do
      (table.insert)(data.Temp, v)
    end
    -- DECOMPILER ERROR at PC21: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self._mapNewbieData)[nId] = data
    if type(callback) == "function" then
      callback(mapData)
    end
    local tab = {}
    ;
    (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (NovaAPI.UserEventUpload)("guaranteed5star_gacha10", tab)
  end

  local mapMsgData = {Value = nId}
  ;
  (EventManager.Hit)("GachaProcessStart", true)
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).gacha_newbie_spin_req, mapMsgData, nil, GachaCallback)
end

PlayerGachaData.SendGachaNewbieSaveReq = function(self, nId, idx, callback)
  -- function num : 0_35 , upvalues : _ENV
  local GachaCallback = function(_, mapData)
    -- function num : 0_35_0 , upvalues : self, nId, _ENV, idx, callback
    local data = (self._mapNewbieData)[nId]
    local cards = {}
    for _,v in ipairs(data.Temp) do
      (table.insert)(cards, v)
    end
    if idx == 0 then
      (table.insert)(data.Cards, cards)
    else
      -- DECOMPILER ERROR at PC29: Confused about usage of register: R4 in 'UnsetPending'

      if idx > 0 then
        (data.Cards)[idx] = cards
      end
    end
    data.Temp = {}
    -- DECOMPILER ERROR at PC34: Confused about usage of register: R4 in 'UnsetPending'

    ;
    (self._mapNewbieData)[nId] = data
    if type(callback) == "function" then
      callback(mapData)
    end
    local tab = {}
    ;
    (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (NovaAPI.UserEventUpload)("guaranteed5star_gacha10", tab)
  end

  local mapMsgData = {Id = nId, Idx = idx}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).gacha_newbie_save_req, mapMsgData, nil, GachaCallback)
end

PlayerGachaData.SendGachaNewbieObtainReq = function(self, nId, idx, callback)
  -- function num : 0_36 , upvalues : _ENV
  local GachaCallback = function(_, mapData)
    -- function num : 0_36_0 , upvalues : self, nId, _ENV, callback
    local data = (self._mapNewbieData)[nId]
    data.Receive = true
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self._mapNewbieData)[nId] = data
    if type(callback) == "function" then
      callback(mapData)
    end
  end

  local mapMsgData = {Id = nId, Idx = idx}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).gacha_newbie_obtain_req, mapMsgData, nil, GachaCallback)
end

return PlayerGachaData

