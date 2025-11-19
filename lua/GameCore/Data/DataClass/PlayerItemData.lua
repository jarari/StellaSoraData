local ConfigData = require("GameCore.Data.ConfigData")
local PlayerItemData = class("PlayerItemData")
PlayerItemData.Init = function(self)
  -- function num : 0_0
  self._mapItem = {}
  self:PreProcess()
end

PlayerItemData.GetAllItemMinExpire = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local nMinExpire = -1
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  for Tid,value in pairs(self._mapItem) do
    local itemCfg = (ConfigTable.GetData_Item)(Tid)
    if itemCfg ~= nil and itemCfg.Display then
      for nExpire,_ in pairs(value.mapExpires) do
        if (nMinExpire == -1 or nExpire < nMinExpire) and nExpire > 0 and curTime < nExpire then
          nMinExpire = nExpire
        end
      end
    end
  end
  return nMinExpire
end

PlayerItemData.GetItemsByStype = function(self, nType)
  -- function num : 0_2 , upvalues : _ENV
  local tbItem = {}
  for index,value in pairs(self._mapItem) do
    if ((ConfigTable.GetData_Item)(index)).Stype == nType then
      (table.insert)(tbItem, 1, value)
    end
  end
  return tbItem
end

PlayerItemData.GetItemsByMark = function(self, nMark)
  -- function num : 0_3 , upvalues : _ENV
  local tbItem = {}
  local tbType = {}
  local foreachItemPackMark = function(mapData)
    -- function num : 0_3_0 , upvalues : nMark, tbType
    if mapData.PackMark == nMark then
      tbType = mapData.ItemStype
    end
  end

  ForEachTableLine(DataTable.ItemPackMark, foreachItemPackMark)
  for index,value in pairs(self._mapItem) do
    if (table.indexof)(tbType, ((ConfigTable.GetData_Item)(index)).Stype) > 0 then
      (table.insert)(tbItem, 1, value)
    end
  end
  return tbItem
end

PlayerItemData.GetItemSortByExpire = function(self, nTid)
  -- function num : 0_4 , upvalues : _ENV
  local ret = {}
  if (self._mapItem)[nTid] ~= nil then
    local tbExpires = {}
    for nExpire,_ in pairs(((self._mapItem)[nTid]).mapExpires) do
      local curTime = ((CS.ClientManager).Instance).serverTimeStamp
      local remainTime = nExpire - curTime
      if remainTime > 0 or nExpire == 0 then
        (table.insert)(tbExpires, nExpire)
      end
    end
    ;
    (table.sort)(tbExpires)
    for _,nExpire in ipairs(tbExpires) do
      for nId,nCount in pairs(((((self._mapItem)[nTid]).mapExpires)[nExpire]).mapId) do
        (table.insert)(ret, {nId, nCount})
      end
    end
  end
  do
    return ret
  end
end

PlayerItemData.GetCharFragmentsData = function(self)
  -- function num : 0_5 , upvalues : _ENV
  local tbFragment = {}
  for k,v in pairs(self._mapItem) do
    do
      local mapData = (ConfigTable.GetData_Item)(v.Tid)
      if mapData ~= nil and mapData.Stype == (GameEnum.itemStype).CharShard then
        local mapChar = nil
        local func_EachChar = function(mapLineData)
    -- function num : 0_5_0 , upvalues : v, _ENV, mapChar
    if mapLineData.FragmentsId == v.Tid and (PlayerData.Char):GetCharDataByTid(mapLineData.Id) == nil then
      mapChar = mapLineData
    end
  end

        ForEachTableLine(DataTable.Character, func_EachChar)
        if mapChar ~= nil then
          local data = {nId = mapChar.Id, Rare = mapChar.Grade, Level = 0, nFragments = self:GetItemCountByID(v.Tid), nNeedFragments = mapChar.RecruitmentQty, EET = mapChar.EET}
          ;
          (table.insert)(tbFragment, data)
        end
      end
    end
  end
  return tbFragment
end

PlayerItemData.GetCharHoldingState = function(self, nCharId, nGetChar, nGetFragments)
  -- function num : 0_6 , upvalues : _ENV
  if not nGetFragments then
    nGetFragments = 0
  end
  local mapCharCfg = (ConfigTable.GetData_Character)(nCharId)
  if mapCharCfg == nil then
    return 
  end
  local nRemain, bNew = (PlayerData.Talent):GetRemainFragments(nCharId)
  if nGetChar and nGetChar > 0 then
    if bNew then
      nGetFragments = nGetFragments + (nGetChar - 1) * mapCharCfg.TransformQty
    else
      nGetFragments = nGetFragments + nGetChar * mapCharCfg.TransformQty
    end
  end
  if nRemain - (nGetFragments) < 0 then
    local mapGradeCfg = (ConfigTable.GetData)("CharGrade", mapCharCfg.Grade)
    if mapGradeCfg == nil then
      return 
    end
    local sMaxTsName = ((ConfigTable.GetData_Item)(mapGradeCfg.SubstituteItemId)).Title
    local sTsName = ((ConfigTable.GetData_Item)(mapCharCfg.FragmentsId)).Title
    return orderedFormat((ConfigTable.GetUIText)("Overflow_BuyChar"), sTsName, sTsName, sMaxTsName)
  else
    do
      do return  end
    end
  end
end

PlayerItemData.GetDiscHoldingState = function(self, nId, nGetCount)
  -- function num : 0_7 , upvalues : _ENV
  local mapDisc = (PlayerData.Disc):GetDiscById(nId)
  local mapCfg = (ConfigTable.GetData)("Disc", nId)
  local mapItem = (ConfigTable.GetData_Item)(nId)
  if mapCfg == nil or mapItem == nil then
    return 
  end
  local nTsId = mapCfg.TransformItemId
  local sTsName = ((ConfigTable.GetData_Item)(nTsId)).Title
  local nMaxTsId = (mapCfg.MaxStarTransformItem)[1]
  local sMaxTsName = ((ConfigTable.GetData_Item)(nMaxTsId)).Title
  local nHasTs = self:GetItemCountByID(nTsId)
  local nRemain = 0
  if mapDisc then
    nRemain = mapDisc.nMaxStar - mapDisc.nStar - nHasTs - nGetCount
  else
    local nMaxStar = (PlayerData.Disc):GetDiscMaxStar(mapItem.Rarity)
    nRemain = nMaxStar - nHasTs - (nGetCount - 1)
  end
  do
    if nRemain < 0 and mapDisc and mapDisc.nMaxStar == mapDisc.nStar then
      return orderedFormat((ConfigTable.GetUIText)("Overflow_BuyDiscMaxStar"), mapDisc.sName, sTsName, sMaxTsName)
    else
      if nRemain < 0 then
        return orderedFormat((ConfigTable.GetUIText)("Overflow_BuyDisc"), sTsName, sTsName, sMaxTsName)
      else
        return 
      end
    end
  end
end

PlayerItemData.PreProcess = function(self)
  -- function num : 0_8 , upvalues : _ENV
  local mapDrop = {}
  local func_EachDrop = function(mapLineData)
    -- function num : 0_8_0 , upvalues : mapDrop, _ENV
    local nDropId = mapLineData.DropId
    local nDropPkgId = mapLineData.PkgId
    if mapDrop[nDropId] == nil then
      mapDrop[nDropId] = {}
    end
    local idx = (table.indexof)(mapDrop[nDropId], nDropPkgId)
    if idx <= 0 then
      (table.insert)(mapDrop[nDropId], nDropPkgId)
    end
  end

  ForEachTableLine(DataTable.Drop, func_EachDrop)
  local mapDropPgk = {}
  local func_EachDropPkg = function(mapLineData)
    -- function num : 0_8_1 , upvalues : mapDropPgk, _ENV
    local nDropPkgId = mapLineData.PkgId
    local nItemId = mapLineData.ItemId
    if mapDropPgk[nDropPkgId] == nil then
      mapDropPgk[nDropPkgId] = {}
    end
    local idx = (table.indexof)(mapDropPgk[nDropPkgId], nItemId)
    if idx <= 0 then
      (table.insert)(mapDropPgk[nDropPkgId], nItemId)
    end
  end

  ForEachTableLine(DataTable.DropPkg, func_EachDropPkg)
  self._mapDropItem = {}
  for nDropId,tbDropPkgId in pairs(mapDrop) do
    -- DECOMPILER ERROR at PC26: Confused about usage of register: R10 in 'UnsetPending'

    if (self._mapDropItem)[nDropId] == nil then
      (self._mapDropItem)[nDropId] = {}
    end
    for __,nDropPkgId in ipairs(tbDropPkgId) do
      local tbItemId = mapDropPgk[nDropPkgId]
      for ___,nItemId in ipairs(tbItemId) do
        local idx = (table.indexof)((self._mapDropItem)[nDropId], nItemId)
        if idx <= 0 then
          (table.insert)((self._mapDropItem)[nDropId], nItemId)
        end
      end
    end
  end
  self._mapDropShow = {}
  local forEachDropShow = function(mapData)
    -- function num : 0_8_2 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self._mapDropShow)[mapData.DropId] == nil then
      (self._mapDropShow)[mapData.DropId] = {}
    end
    ;
    (table.insert)((self._mapDropShow)[mapData.DropId], mapData)
  end

  ForEachTableLine(DataTable.DropItemShow, forEachDropShow)
  self._mapMaxAcquireReward = {}
  local forEachAcquireReward = function(mapData)
    -- function num : 0_8_3 , upvalues : self
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self._mapMaxAcquireReward)[mapData.itemStype] == nil then
      (self._mapMaxAcquireReward)[mapData.itemStype] = {}
    end
    -- DECOMPILER ERROR at PC21: Confused about usage of register: R1 in 'UnsetPending'

    if ((self._mapMaxAcquireReward)[mapData.itemStype])[mapData.itemRarity] == nil then
      ((self._mapMaxAcquireReward)[mapData.itemStype])[mapData.itemRarity] = mapData.AcquireTimes
    end
    -- DECOMPILER ERROR at PC35: Confused about usage of register: R1 in 'UnsetPending'

    if ((self._mapMaxAcquireReward)[mapData.itemStype])[mapData.itemRarity] < mapData.AcquireTimes then
      ((self._mapMaxAcquireReward)[mapData.itemStype])[mapData.itemRarity] = mapData.AcquireTimes
    end
  end

  ForEachTableLine(DataTable.AcquireReward, forEachAcquireReward)
end

PlayerItemData.GetDropItem = function(self, nDropId)
  -- function num : 0_9
  return (self._mapDropItem)[nDropId]
end

PlayerItemData.GetDropItemShow = function(self, nDropId)
  -- function num : 0_10
  return (self._mapDropShow)[nDropId]
end

PlayerItemData.CacheItemData = function(self, mapData)
  -- function num : 0_11 , upvalues : _ENV
  self._mapItem = {}
  for k,v in ipairs(mapData) do
    -- DECOMPILER ERROR at PC14: Confused about usage of register: R7 in 'UnsetPending'

    if (self._mapItem)[v.Tid] == nil then
      (self._mapItem)[v.Tid] = {}
      -- DECOMPILER ERROR at PC19: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self._mapItem)[v.Tid]).Tid = v.Tid
      -- DECOMPILER ERROR at PC23: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self._mapItem)[v.Tid]).nExpireCount = 0
      -- DECOMPILER ERROR at PC28: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self._mapItem)[v.Tid]).mapExpires = {}
    end
    -- DECOMPILER ERROR at PC43: Confused about usage of register: R7 in 'UnsetPending'

    if (((self._mapItem)[v.Tid]).mapExpires)[v.Expire] == nil then
      (((self._mapItem)[v.Tid]).mapExpires)[v.Expire] = {}
      -- DECOMPILER ERROR at PC50: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).nTotalCount = 0
      -- DECOMPILER ERROR at PC58: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).mapId = {}
      -- DECOMPILER ERROR at PC67: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self._mapItem)[v.Tid]).nExpireCount = ((self._mapItem)[v.Tid]).nExpireCount + 1
    end
    -- DECOMPILER ERROR at PC77: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).mapId)[v.Id] = v.Qty
    -- DECOMPILER ERROR at PC93: Confused about usage of register: R7 in 'UnsetPending'

    ;
    ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).nTotalCount = ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).nTotalCount + v.Qty
  end
end

PlayerItemData.GetItemCountByTidExpire = function(self, nTid, nExpire)
  -- function num : 0_12
  if (self._mapItem)[nTid] ~= nil and (((self._mapItem)[nTid]).tbmapExpires)[nExpire] ~= nil then
    return ((((self._mapItem)[nTid]).tbmapExpires)[nExpire]).nTotalCount
  end
  return 0
end

PlayerItemData.ChangeItem = function(self, mapChange)
  -- function num : 0_13 , upvalues : _ENV
  if type(mapChange) ~= "table" then
    return 
  end
  for k,v in ipairs(mapChange) do
    -- DECOMPILER ERROR at PC18: Confused about usage of register: R7 in 'UnsetPending'

    if (self._mapItem)[v.Tid] == nil then
      (self._mapItem)[v.Tid] = {}
      -- DECOMPILER ERROR at PC23: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self._mapItem)[v.Tid]).Tid = v.Tid
      -- DECOMPILER ERROR at PC27: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self._mapItem)[v.Tid]).nExpireCount = 0
      -- DECOMPILER ERROR at PC32: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self._mapItem)[v.Tid]).mapExpires = {}
    end
    -- DECOMPILER ERROR at PC47: Confused about usage of register: R7 in 'UnsetPending'

    if (((self._mapItem)[v.Tid]).mapExpires)[v.Expire] == nil then
      (((self._mapItem)[v.Tid]).mapExpires)[v.Expire] = {}
      -- DECOMPILER ERROR at PC54: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).nTotalCount = 0
      -- DECOMPILER ERROR at PC62: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).mapId = {}
      -- DECOMPILER ERROR at PC71: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((self._mapItem)[v.Tid]).nExpireCount = ((self._mapItem)[v.Tid]).nExpireCount + 1
    end
    -- DECOMPILER ERROR at PC92: Confused about usage of register: R7 in 'UnsetPending'

    if (((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).mapId)[v.Id] == nil then
      (((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).mapId)[v.Id] = v.Qty
      -- DECOMPILER ERROR at PC108: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).nTotalCount = ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).nTotalCount + v.Qty
    else
      -- DECOMPILER ERROR at PC129: Confused about usage of register: R7 in 'UnsetPending'

      ;
      (((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).mapId)[v.Id] = v.Qty + (((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).mapId)[v.Id]
      -- DECOMPILER ERROR at PC145: Confused about usage of register: R7 in 'UnsetPending'

      ;
      ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).nTotalCount = v.Qty + ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).nTotalCount
      -- DECOMPILER ERROR at PC165: Confused about usage of register: R7 in 'UnsetPending'

      if (((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).mapId)[v.Id] <= 0 then
        (((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).mapId)[v.Id] = nil
      end
      -- DECOMPILER ERROR at PC180: Confused about usage of register: R7 in 'UnsetPending'

      if ((((self._mapItem)[v.Tid]).mapExpires)[v.Expire]).nTotalCount <= 0 then
        (((self._mapItem)[v.Tid]).mapExpires)[v.Expire] = nil
        -- DECOMPILER ERROR at PC189: Confused about usage of register: R7 in 'UnsetPending'

        ;
        ((self._mapItem)[v.Tid]).nExpireCount = ((self._mapItem)[v.Tid]).nExpireCount - 1
        -- DECOMPILER ERROR at PC198: Confused about usage of register: R7 in 'UnsetPending'

        if ((self._mapItem)[v.Tid]).nExpireCount <= 0 then
          (self._mapItem)[v.Tid] = nil
        end
      end
    end
    ;
    (EventManager.Hit)(EventId.CoinResChange, v.Tid, v.Qty)
  end
  ;
  (PlayerData.Talent):UpdateCharTalentRedDotByItem(mapChange)
  ;
  (PlayerData.Disc):UpdateBreakLimitRedDotByItem(mapChange)
  ;
  (PlayerData.StarTower):UpdateGrowthRedDotByItem(mapChange)
end

PlayerItemData.GetItemCountByID = function(self, Tid)
  -- function num : 0_14 , upvalues : _ENV
  local itemCfgData = (ConfigTable.GetData_Item)(Tid, true)
  if itemCfgData == nil then
    return 0
  end
  if itemCfgData.Type == (GameEnum.itemType).Res then
    return (PlayerData.Coin):GetCoinCount(Tid)
  end
  if itemCfgData.Type == (GameEnum.itemType).Energy then
    return ((PlayerData.Base):GetCurEnergy()).nEnergy
  end
  if itemCfgData.Type == (GameEnum.itemType).Honor then
    local tbHonor = (PlayerData.Base):GetPlayerHonorTitleList()
    local bHas = (table.indexof)(tbHonor, Tid) > 0
    return bHas and 1 or 0
  end
  do
    if (self._mapItem)[Tid] ~= nil then
      local count = 0
      for key,value in pairs(((self._mapItem)[Tid]).mapExpires) do
        local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
        if key == 0 or nCurTime < key then
          count = count + value.nTotalCount
        end
      end
      return count
    end
    do return 0 end
    -- DECOMPILER ERROR: 7 unprocessed JMP targets
  end
end

PlayerItemData.GetItemCacheDataByID = function(self, Tid)
  -- function num : 0_15
  if (self._mapItem)[Tid] ~= nil then
    return (self._mapItem)[Tid]
  end
  return nil
end

PlayerItemData.GetCYODisplayItem = function(self, nId)
  -- function num : 0_16 , upvalues : _ENV
  local tbDetailItem = {}
  local sDetailTitle = ""
  local mapItemCfgData = (ConfigTable.GetData_Item)(nId)
  if mapItemCfgData == nil then
    return tbDetailItem, sDetailTitle
  end
  local sort = function(a, b)
    -- function num : 0_16_0 , upvalues : _ENV
    local mapItemCfgDataA = (ConfigTable.GetData_Item)(a.nId)
    local mapItemCfgDataB = (ConfigTable.GetData_Item)(b.nId)
    if mapItemCfgDataA.Rarity >= mapItemCfgDataB.Rarity then
      do return not mapItemCfgDataA or not mapItemCfgDataB or mapItemCfgDataA.Rarity == mapItemCfgDataB.Rarity end
      do return a.nId < b.nId end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end

  if mapItemCfgData.Stype == (GameEnum.itemStype).RandomPackage then
    local mapItemUseCfg = decodeJson(mapItemCfgData.UseArgs)
    for sTid,_ in pairs(mapItemUseCfg) do
      local nItemTid = tonumber(sTid)
      if nItemTid ~= nil then
        local tbDropShowData = self:GetDropItemShow(nItemTid)
        if tbDropShowData ~= nil then
          for _,mapData in ipairs(tbDropShowData) do
            (table.insert)(tbDetailItem, {nId = mapData.ItemId, nCount = mapData.ItemQty})
          end
        end
      end
    end
    ;
    (table.sort)(tbDetailItem, sort)
    sDetailTitle = (ConfigTable.GetUIText)("ItemTip_RandomPackageTitle")
  else
    do
      do
        if mapItemCfgData.Stype == (GameEnum.itemStype).ComCYO then
          local mapItemUseCfg = decodeJson(mapItemCfgData.UseArgs)
          for sTid,nCount in pairs(mapItemUseCfg) do
            local nItemTid = tonumber(sTid)
            if nItemTid ~= nil then
              (table.insert)(tbDetailItem, {nId = nItemTid, nCount = nCount})
            end
          end
          ;
          (table.sort)(tbDetailItem, sort)
          sDetailTitle = (ConfigTable.GetUIText)("ItemTip_ComCYOTitle")
        end
        return tbDetailItem, sDetailTitle
      end
    end
  end
end

PlayerItemData.AutoFillMat = function(self, tbNeedItem)
  -- function num : 0_17 , upvalues : _ENV
  local bAllNone = true
  local tbEmptyItem = {}
  for _,v in ipairs(tbNeedItem) do
    local nId = v.nId
    local mapHelperCfg = (ConfigTable.GetData)("ProduceHelper", nId, true)
    if mapHelperCfg then
      bAllNone = false
    else
      tbEmptyItem[nId] = true
    end
  end
  if bAllNone then
    return {}, {}, {}
  end
  local sort = function(a, b)
    -- function num : 0_17_0 , upvalues : _ENV
    local mapItemCfgDataA = (ConfigTable.GetData_Item)(a.nId)
    local mapItemCfgDataB = (ConfigTable.GetData_Item)(b.nId)
    if mapItemCfgDataA.Rarity >= mapItemCfgDataB.Rarity then
      do return not mapItemCfgDataA or not mapItemCfgDataB or mapItemCfgDataA.Rarity == mapItemCfgDataB.Rarity end
      do return a.nId < b.nId end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end

  ;
  (table.sort)(tbNeedItem, sort)
  local tbFillStep, tbPick, tbReadyToFillStep, tbReadyToPick = {}, {}, {}, {}
  local tbUseItem, tbReadyToUseItem = {}, {}
  local tbNeedCount, tbRemainCount = {}, {}
  local tbAlreadyItem = {}
  local tbGetItem = {}
  local tbReadyLog = {}
  for _,v in ipairs(tbNeedItem) do
    local nId = v.nId
    local nHasCount = self:GetItemCountByID(v.nId)
    if nHasCount < v.nCount then
      tbNeedCount[nId] = v.nCount - nHasCount
      tbRemainCount[nId] = 0
    else
      tbNeedCount[nId] = 0
      tbRemainCount[nId] = nHasCount - v.nCount
      tbAlreadyItem[nId] = true
    end
  end
  local buildCountData = function(nId)
    -- function num : 0_17_1 , upvalues : tbReadyToUseItem, tbRemainCount, self
    if not tbReadyToUseItem[nId] then
      tbReadyToUseItem[nId] = 0
    end
    if not tbRemainCount[nId] then
      tbRemainCount[nId] = self:GetItemCountByID(nId)
    end
  end

  local readyUse = function(nId, nNeed)
    -- function num : 0_17_2 , upvalues : tbReadyToUseItem
    tbReadyToUseItem[nId] = tbReadyToUseItem[nId] + nNeed
  end

  local useCYO = function(mapHelperCfg, nNeedCYO)
    -- function num : 0_17_3 , upvalues : _ENV, tbRemainCount, tbReadyToUseItem, tbReadyLog, self, tbReadyToPick, readyUse
    if nNeedCYO == 0 then
      return 
    end
    for _,nCYOId in ipairs(mapHelperCfg.ComCYOIds) do
      local nCurCYORemain = tbRemainCount[nCYOId] - tbReadyToUseItem[nCYOId]
      if nCurCYORemain > 0 then
        if nNeedCYO <= nCurCYORemain then
          (table.insert)(tbReadyLog, "快捷养成-自选包 道具ID:" .. mapHelperCfg.Id .. " 自选包ID:" .. nCYOId .. " 使用次数:" .. nNeedCYO .. " 名称:" .. ((ConfigTable.GetData_Item)(mapHelperCfg.Id)).Title)
          local tbList = self:GetAutoFillPickList(nCYOId, mapHelperCfg.Id, nNeedCYO)
          for _,v in ipairs(tbList) do
            (table.insert)(tbReadyToPick, v)
          end
          readyUse(nCYOId, nNeedCYO)
          return 
        else
          do
            ;
            (table.insert)(tbReadyLog, "快捷养成-自选包 道具ID:" .. mapHelperCfg.Id .. " 自选包ID:" .. nCYOId .. " 使用次数:" .. nCurCYORemain .. " 名称:" .. ((ConfigTable.GetData_Item)(mapHelperCfg.Id)).Title)
            do
              local tbList = self:GetAutoFillPickList(nCYOId, mapHelperCfg.Id, nCurCYORemain)
              for _,v in ipairs(tbList) do
                (table.insert)(tbReadyToPick, v)
              end
              readyUse(nCYOId, nCurCYORemain)
              nNeedCYO = nNeedCYO - nCurCYORemain
              -- DECOMPILER ERROR at PC93: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC93: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC93: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC93: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC93: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end

  local fill = function(nId, nNeed, bUseCYO)
    -- function num : 0_17_4 , upvalues : buildCountData, tbRemainCount, tbReadyToUseItem, _ENV, tbReadyLog, readyUse, fill, tbReadyToFillStep, useCYO
    buildCountData(nId)
    local nCurRemain = tbRemainCount[nId] - tbReadyToUseItem[nId]
    if nNeed <= nCurRemain then
      (table.insert)(tbReadyLog, "快捷养成-道具直接满足 道具ID:" .. nId .. " 数量:" .. nNeed .. " 名称:" .. ((ConfigTable.GetData_Item)(nId)).Title)
      readyUse(nId, nNeed)
      return true
    end
    local mapHelperCfg = (ConfigTable.GetData)("ProduceHelper", nId, true)
    if not mapHelperCfg then
      printLog("自动填充失败，该道具无ProduceHelper配置：" .. nId)
      return false
    end
    local Crafting = function(nNeedCrafting)
      -- function num : 0_17_4_0 , upvalues : mapHelperCfg, _ENV, nId, fill, bUseCYO, readyUse, tbReadyLog, tbReadyToFillStep
      if mapHelperCfg.ProductionId == 0 then
        return false
      end
      local mapProductionCfg = (ConfigTable.GetData)("Production", mapHelperCfg.ProductionId)
      if not mapProductionCfg then
        printError("自动填充失败，该配方无Production配置：" .. mapHelperCfg.ProductionId)
        return false
      end
      if mapProductionCfg.ProductionId ~= nId then
        printError("自动填充失败，该配方（" .. mapHelperCfg.ProductionId .. "）的产物" .. mapProductionCfg.ProductionId .. "与目标产物不同" .. nId)
        return false
      end
      local bOpen = (PlayerData.Crafting):CheckProductionUnlock(mapHelperCfg.ProductionId)
      if not bOpen then
        return false
      end
      local nCraftTimes = (math.ceil)(nNeedCrafting / mapProductionCfg.ProductionPerBatch)
      local nCraftedCount = nCraftTimes * mapProductionCfg.ProductionPerBatch
      for i = 1, 4 do
        local nMtId = mapProductionCfg["RawMaterialId" .. i]
        local nMtCount = mapProductionCfg["RawMaterialCount" .. i]
        if nMtId > 0 then
          local bAble = fill(nMtId, nMtCount * nCraftTimes, bUseCYO)
          if not bAble then
            return false
          end
        end
      end
      if nNeedCrafting < nCraftedCount then
        readyUse(nId, nNeedCrafting - nCraftedCount)
      end
      ;
      (table.insert)(tbReadyLog, "快捷养成-合成 道具ID:" .. nId .. " 配方ID:" .. mapHelperCfg.ProductionId .. " 合成次数:" .. nCraftTimes .. " 名称:" .. ((ConfigTable.GetData_Item)(nId)).Title)
      local msgData = {}
      msgData.Product = {Id = mapHelperCfg.ProductionId, Num = nCraftTimes}
      ;
      (table.insert)(tbReadyToFillStep, msgData)
      return true
    end

    if bUseCYO then
      local nAllCYOCount = 0
      for _,nCYOId in ipairs(mapHelperCfg.ComCYOIds) do
        buildCountData(nCYOId)
        nAllCYOCount = nAllCYOCount + tbRemainCount[nCYOId] - tbReadyToUseItem[nCYOId]
      end
      if nNeed <= nCurRemain + (nAllCYOCount) then
        local nNeedCYO = nNeed - nCurRemain
        useCYO(mapHelperCfg, nNeedCYO)
        if nCurRemain > 0 then
          (table.insert)(tbReadyLog, "快捷养成-道具满足部分 道具ID:" .. nId .. " 数量:" .. nCurRemain .. " 名称:" .. ((ConfigTable.GetData_Item)(nId)).Title)
          readyUse(nId, nCurRemain)
        end
        return true
      else
        do
          local nAfterCYONeed = nNeed - nCurRemain - (nAllCYOCount)
          do
            local bAble = Crafting(nAfterCYONeed)
            if bAble then
              useCYO(mapHelperCfg, nAllCYOCount)
              if nCurRemain > 0 then
                (table.insert)(tbReadyLog, "快捷养成-道具满足部分 道具ID:" .. nId .. " 数量:" .. nCurRemain .. " 名称:" .. ((ConfigTable.GetData_Item)(nId)).Title)
                readyUse(nId, nCurRemain)
              end
            end
            do return bAble end
            local nNeedCrafting = nNeed - nCurRemain
            local bAble = Crafting(nNeedCrafting)
            if bAble and nCurRemain > 0 then
              (table.insert)(tbReadyLog, "快捷养成-道具满足部分 道具ID:" .. nId .. " 数量:" .. nCurRemain .. " 名称:" .. ((ConfigTable.GetData_Item)(nId)).Title)
              readyUse(nId, nCurRemain)
            end
            do return bAble end
          end
        end
      end
    end
  end

  local addUse = function(bAddAble, nAddId)
    -- function num : 0_17_5 , upvalues : tbGetItem, _ENV, tbReadyToUseItem, tbRemainCount, tbUseItem, tbReadyToFillStep, tbFillStep, tbReadyToPick, tbPick, tbReadyLog
    if bAddAble then
      if not tbGetItem[nAddId] then
        tbGetItem[nAddId] = 0
      end
      tbGetItem[nAddId] = tbGetItem[nAddId] + 1
      for nUseId,nUseCount in pairs(tbReadyToUseItem) do
        tbRemainCount[nUseId] = tbRemainCount[nUseId] - nUseCount
        if not tbUseItem[nUseId] then
          tbUseItem[nUseId] = 0
        end
        tbUseItem[nUseId] = tbUseItem[nUseId] + nUseCount
      end
      for _,mapStep in ipairs(tbReadyToFillStep) do
        local bHasStep = false
        for k,v in pairs(tbFillStep) do
          -- DECOMPILER ERROR at PC48: Confused about usage of register: R13 in 'UnsetPending'

          if (v.Product).Id == (mapStep.Product).Id then
            ((tbFillStep[k]).Product).Num = ((tbFillStep[k]).Product).Num + (mapStep.Product).Num
            bHasStep = true
            break
          end
        end
        do
          do
            if not bHasStep then
              (table.insert)(tbFillStep, mapStep)
            end
            -- DECOMPILER ERROR at PC60: LeaveBlock: unexpected jumping out DO_STMT

          end
        end
      end
      for _,mapReadyPick in ipairs(tbReadyToPick) do
        local bAdded = false
        for _,mapPick in ipairs(tbPick) do
          if mapPick.Id == mapReadyPick.Id and mapPick.Tid == mapReadyPick.Tid and mapPick.SelectTid == mapReadyPick.SelectTid then
            if mapReadyPick.Qty ~= 0 or not 1 then
              local nAdd = mapReadyPick.Qty
            end
            if mapPick.Qty ~= 0 or not 1 then
              local nHas = mapPick.Qty
            end
            mapPick.Qty = nAdd + nHas
            bAdded = true
            break
          end
        end
        do
          do
            if not bAdded then
              (table.insert)(tbPick, mapReadyPick)
            end
            -- DECOMPILER ERROR at PC110: LeaveBlock: unexpected jumping out DO_STMT

          end
        end
      end
      for _,sLog in ipairs(tbReadyLog) do
        printLog(sLog)
      end
    end
    do
      tbReadyToUseItem = {}
      tbReadyToFillStep = {}
      tbReadyToPick = {}
      tbReadyLog = {}
    end
  end

  for _,v in ipairs(tbNeedItem) do
    local nId = v.nId
    if not tbAlreadyItem[nId] and not tbEmptyItem[nId] then
      for _ = 1, tbNeedCount[nId] do
        local bAble = fill(nId, 1)
        addUse(bAble, nId)
        if not bAble then
          local bAbleAfterCYO = fill(nId, 1, true)
          addUse(bAbleAfterCYO, nId)
        end
      end
    end
  end
  ;
  (table.sort)(tbFillStep, function(a, b)
    -- function num : 0_17_6 , upvalues : _ENV
    local mapProductionCfg_a = (ConfigTable.GetData)("Production", (a.Product).Id)
    local mapProductionCfg_b = (ConfigTable.GetData)("Production", (b.Product).Id)
    if mapProductionCfg_a and mapProductionCfg_b then
      local mapItemCfg_a = (ConfigTable.GetData_Item)(mapProductionCfg_a.ProductionId)
      local mapItemCfg_b = (ConfigTable.GetData_Item)(mapProductionCfg_b.ProductionId)
      if mapItemCfg_b.Rarity >= mapItemCfg_a.Rarity then
        do
          do return not mapItemCfg_a or not mapItemCfg_b end
          do return (a.Product).Id < (b.Product).Id end
          -- DECOMPILER ERROR: 3 unprocessed JMP targets
        end
      end
    end
  end
)
  local msgData = {}
  msgData.Pick = {}
  -- DECOMPILER ERROR at PC117: Confused about usage of register: R22 in 'UnsetPending'

  ;
  (msgData.Pick).List = tbPick
  ;
  (table.insert)(tbFillStep, 1, msgData)
  local tbShowNeedItem = {}
  for _,v in ipairs(tbNeedItem) do
    if tbGetItem[v.nId] then
      local nHasCount = self:GetItemCountByID(v.nId)
      local nAfterCount = nHasCount + tbGetItem[v.nId]
      ;
      (table.insert)(tbShowNeedItem, {nId = v.nId, nCount = nAfterCount, nNeed = v.nCount})
    end
  end
  local sUseLog = "消耗的道具：\n"
  for nId,nCount in pairs(tbUseItem) do
    sUseLog = sUseLog .. "id:" .. nId .. " count:" .. nCount .. " 名称:" .. ((ConfigTable.GetData_Item)(nId)).Title .. "\n"
  end
  printLog(sUseLog)
  local sRemainLog = "剩余的道具：\n"
  for nId,nCount in pairs(tbRemainCount) do
    sRemainLog = sRemainLog .. "id:" .. nId .. " count:" .. nCount .. " 名称:" .. ((ConfigTable.GetData_Item)(nId)).Title .. "\n"
  end
  printLog(sRemainLog)
  local sGetLog = "目标获得的道具：\n"
  for nId,nCount in pairs(tbGetItem) do
    sGetLog = sGetLog .. "id:" .. nId .. " count:" .. nCount .. " 名称:" .. ((ConfigTable.GetData_Item)(nId)).Title .. "\n"
  end
  printLog(sGetLog)
  return tbFillStep, tbUseItem, tbShowNeedItem
end

PlayerItemData.GetAutoFillPickList = function(self, nItemId, nChooseTid, nCount)
  -- function num : 0_18 , upvalues : _ENV
  local tbItem = self:GetItemSortByExpire(nItemId)
  if #tbItem == 0 then
    printError("没有可使用的道具：" .. nItemId)
    return {}
  end
  local tbUseItem = {}
  local nRemainCount = nCount
  for _,tbItemCount in ipairs(tbItem) do
    if tbItemCount[2] < nRemainCount then
      if tbItemCount[2] ~= 1 or not 0 then
        do
          (table.insert)(tbUseItem, {Id = tbItemCount[1], Tid = nItemId, SelectTid = nChooseTid, Qty = tbItemCount[2]})
          nRemainCount = nRemainCount - tbItemCount[2]
          ;
          (table.insert)(tbUseItem, {Id = tbItemCount[1], Tid = nItemId, SelectTid = nChooseTid, Qty = nRemainCount == 1 and 0 or nRemainCount})
          nRemainCount = 0
          do break end
          -- DECOMPILER ERROR at PC60: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC60: LeaveBlock: unexpected jumping out IF_STMT

          -- DECOMPILER ERROR at PC60: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC60: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  return tbUseItem
end

PlayerItemData.SendItemGrowthReq = function(self, tbStep, callback)
  -- function num : 0_19 , upvalues : _ENV
  if not tbStep or next(tbStep) == nil then
    return 
  end
  local msgData = {List = tbStep}
  local msgCallback = function(sendData, netMsg)
    -- function num : 0_19_0 , upvalues : _ENV, callback
    (EventManager.Hit)("AutoFillSuccess")
    ;
    (UTILS.OpenReceiveByChangeInfo)(netMsg)
    if callback ~= nil and type(callback) == "function" then
      callback(sendData, netMsg)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).item_quick_growth_req, msgData, nil, msgCallback)
end

PlayerItemData.CheckItemCountExceededLimit = function(self, callBack)
  -- function num : 0_20
  callBack(false)
end

PlayerItemData.ProcessRewardChangeInfo = function(self, mapChangeInfo)
  -- function num : 0_21 , upvalues : _ENV
  local mapDecodeInfo = (UTILS.DecodeChangeInfo)(mapChangeInfo)
  local tbRewardById = {}
  local tbReward, tbSpReward = {}, {}
  local tbDst, tbSrc = {}, {}
  local tbDstByIdx, tbSrcByIdx = {}, {}
  local tbNewCharOrDisc = {}
  local tbAcquireInfo = {}
  local tbItemAcquireReward = {}
  local add_reward = function(nId, nCount)
    -- function num : 0_21_0 , upvalues : tbRewardById
    if not tbRewardById[nId] then
      tbRewardById[nId] = 0
    end
    tbRewardById[nId] = tbRewardById[nId] + nCount
  end

  local add_acquire_reward = function(tbItem)
    -- function num : 0_21_1 , upvalues : _ENV, tbItemAcquireReward
    for _,v in ipairs(tbItem) do
      if not tbItemAcquireReward[v.Tid] then
        tbItemAcquireReward[v.Tid] = 0
      end
      tbItemAcquireReward[v.Tid] = tbItemAcquireReward[v.Tid] + v.Qty
    end
  end

  if type(mapDecodeInfo) == "table" then
    if type(mapDecodeInfo["proto.Acquire"]) == "table" then
      tbAcquireInfo = self:ProcessAcquireInfo(mapDecodeInfo["proto.Acquire"])
    end
    if type(mapDecodeInfo["proto.Char"]) == "table" then
      for _,mapData in ipairs(mapDecodeInfo["proto.Char"]) do
        local itemInfo = (ConfigTable.GetData_Character)(mapData.Tid)
        if itemInfo then
          local tbItemList = self:GetAcquireReward(mapData.Tid, 1)
          add_acquire_reward(tbItemList)
          local rewardData = {nId = mapData.Tid, nType = (GameEnum.itemType).Char, bNew = true, tbItemList = tbItemList}
          ;
          (table.insert)(tbSpReward, rewardData)
          add_reward(mapData.Tid, 1)
          tbNewCharOrDisc[mapData.Tid] = true
        end
      end
    end
    do
      if type(mapDecodeInfo["proto.Disc"]) == "table" then
        for _,mapData in ipairs(mapDecodeInfo["proto.Disc"]) do
          local itemInfo = (ConfigTable.GetData)("Disc", mapData.Id)
          if itemInfo then
            local tbItemList = self:GetAcquireReward(mapData.Id, 1)
            add_acquire_reward(tbItemList)
            local rewardData = {nId = mapData.Id, bNew = true, tbItemList = tbItemList}
            ;
            (table.insert)(tbSpReward, rewardData)
            add_reward(mapData.Id, 1)
            tbNewCharOrDisc[mapData.Id] = true
          end
        end
      end
      do
        if type(mapDecodeInfo["proto.Transform"]) == "table" then
          for _,mapTrans in ipairs(mapDecodeInfo["proto.Transform"]) do
            for _,mapData in ipairs(mapTrans.Src) do
              if not tbSrc[mapData.Tid] then
                tbSrc[mapData.Tid] = {Tid = mapData.Tid, Qty = 0}
              end
              -- DECOMPILER ERROR at PC145: Confused about usage of register: R25 in 'UnsetPending'

              ;
              (tbSrc[mapData.Tid]).Qty = (tbSrc[mapData.Tid]).Qty + mapData.Qty
            end
            for _,mapData in ipairs(mapTrans.Dst) do
              if not tbDst[mapData.Tid] then
                tbDst[mapData.Tid] = {Tid = mapData.Tid, Qty = 0}
              end
              -- DECOMPILER ERROR at PC169: Confused about usage of register: R25 in 'UnsetPending'

              ;
              (tbDst[mapData.Tid]).Qty = (tbDst[mapData.Tid]).Qty + mapData.Qty
            end
          end
          for _,mapData in pairs(tbSrc) do
            local nSrcId = mapData.Tid
            local mapAcquireInfo = tbAcquireInfo[nSrcId]
            if mapAcquireInfo and mapAcquireInfo.Begin == 0 then
              mapAcquireInfo.Begin = 1
            end
            if (ConfigTable.GetData_Character)(nSrcId, true) and tbNewCharOrDisc[nSrcId] == nil then
              for k = 1, mapData.Qty do
                local tbItemList = {}
                if mapAcquireInfo then
                  tbItemList = self:GetAcquireReward(nSrcId, mapAcquireInfo.Begin + k)
                end
                add_acquire_reward(tbItemList)
                local rewardData = {nId = nSrcId, nType = (GameEnum.itemType).Char, bNew = false, tbItemList = tbItemList}
                ;
                (table.insert)(tbSpReward, rewardData)
              end
            end
            do
              if (ConfigTable.GetData)("Disc", nSrcId, true) and tbNewCharOrDisc[nSrcId] == nil then
                for k = 1, mapData.Qty do
                  local tbItemList = {}
                  if mapAcquireInfo then
                    tbItemList = self:GetAcquireReward(nSrcId, mapAcquireInfo.Begin + k)
                  end
                  add_acquire_reward(tbItemList)
                  local rewardData = {nId = nSrcId, bNew = false, tbItemList = tbItemList}
                  ;
                  (table.insert)(tbSpReward, rewardData)
                end
              end
              do
                -- DECOMPILER ERROR at PC263: LeaveBlock: unexpected jumping out DO_STMT

              end
            end
          end
          for _,v in pairs(tbSrc) do
            (table.insert)(tbSrcByIdx, v)
          end
          for _,v in pairs(tbDst) do
            (table.insert)(tbDstByIdx, v)
          end
        end
        do
          if type(mapDecodeInfo["proto.Res"]) == "table" then
            for _,mapData in ipairs(mapDecodeInfo["proto.Res"]) do
              local itemInfo = (ConfigTable.GetData_Item)(mapData.Tid)
              if itemInfo then
                add_reward(mapData.Tid, mapData.Qty)
              end
            end
          end
          do
            if type(mapDecodeInfo["proto.Item"]) == "table" then
              for _,mapData in ipairs(mapDecodeInfo["proto.Item"]) do
                local itemInfo = (ConfigTable.GetData_Item)(mapData.Tid)
                if itemInfo then
                  add_reward(mapData.Tid, mapData.Qty)
                end
              end
            end
            do
              if type(mapDecodeInfo["proto.Energy"]) == "table" then
                for _,mapData in ipairs(mapDecodeInfo["proto.Energy"]) do
                  local mapEnergy = (PlayerData.Base):GetCurEnergy()
                  local itemInfo = (ConfigTable.GetData_Item)((AllEnum.CoinItemId).Energy)
                  if itemInfo and mapData.Primary > 0 then
                    add_reward((AllEnum.CoinItemId).Energy, mapData.Primary - mapEnergy.nEnergy)
                  end
                end
              end
              do
                if type(mapDecodeInfo["proto.WorldClass"]) == "table" then
                  for _,mapData in ipairs(mapDecodeInfo["proto.WorldClass"]) do
                    local itemInfo = (ConfigTable.GetData_Item)((AllEnum.CoinItemId).WorldClassExp)
                    if itemInfo and mapData.ExpChange > 0 then
                      add_reward((AllEnum.CoinItemId).WorldClassExp, mapData.ExpChange)
                    end
                  end
                end
                do
                  if type(mapDecodeInfo["proto.Title"]) == "table" then
                    for _,mapData in ipairs(mapDecodeInfo["proto.Title"]) do
                      local titleInfo = (ConfigTable.GetData)("Title", mapData.TitleId)
                      if titleInfo ~= nil then
                        local itemInfo = (ConfigTable.GetData_Item)(titleInfo.ItemId)
                        if itemInfo then
                          add_reward(titleInfo.ItemId, 1)
                        end
                      end
                    end
                  end
                  do
                    if type(mapDecodeInfo["proto.Honor"]) == "table" then
                      for _,mapData in ipairs(mapDecodeInfo["proto.Honor"]) do
                        local itemInfo = (ConfigTable.GetData_Item)(mapData.NewId)
                        if itemInfo then
                          add_reward(mapData.NewId, 1)
                        end
                      end
                    end
                    do
                      if type(mapDecodeInfo["proto.HeadIcon"]) == "table" then
                        for _,mapData in ipairs(mapDecodeInfo["proto.HeadIcon"]) do
                          local itemInfo = (ConfigTable.GetData_Item)(mapData.Tid)
                          if itemInfo then
                            add_reward(mapData.Tid, 1)
                          end
                        end
                      end
                      do
                        for nId,nCount in pairs(tbRewardById) do
                          if nCount <= 0 then
                            tbRewardById[nId] = nil
                          else
                            -- DECOMPILER ERROR at PC479: Unhandled construct in 'MakeBoolean' P1

                            if tbDst[nId] and (tbDst[nId]).Qty < nCount then
                              tbRewardById[nId] = nCount - (tbDst[nId]).Qty
                            else
                              tbRewardById[nId] = nil
                            end
                          end
                        end
                        for _,mapData in pairs(tbSrc) do
                          add_reward(mapData.Tid, mapData.Qty)
                        end
                        if next(tbItemAcquireReward) ~= nil then
                          for nId,nCount in pairs(tbItemAcquireReward) do
                            -- DECOMPILER ERROR at PC511: Unhandled construct in 'MakeBoolean' P1

                            if tbRewardById[nId] and nCount < tbRewardById[nId] then
                              tbRewardById[nId] = tbRewardById[nId] - nCount
                            else
                              tbRewardById[nId] = nil
                            end
                          end
                        end
                        do
                          for nId,nCount in pairs(tbRewardById) do
                            (table.insert)(tbReward, {id = nId, count = nCount})
                          end
                          do
                            return {tbReward = tbReward, tbSpReward = tbSpReward, tbSrc = tbSrcByIdx, tbDst = tbDstByIdx}
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

PlayerItemData.ProcessRewardDisplayItem = function(self, tbItem, mapTrans)
  -- function num : 0_22 , upvalues : _ENV
  local tbReward, tbSpReward = {}, {}
  if not tbItem then
    return tbReward, tbSpReward
  end
  local process_sp = function(mapData)
    -- function num : 0_22_0 , upvalues : mapTrans, self, _ENV, tbSpReward, tbReward
    local bNew = false
    if mapTrans and (mapTrans.tbNewCharOrDisc)[mapData.Tid] then
      bNew = true
      -- DECOMPILER ERROR at PC12: Confused about usage of register: R2 in 'UnsetPending'

      ;
      (mapTrans.tbNewCharOrDisc)[mapData.Tid] = false
    end
    local mapAcquireInfo = (mapTrans.tbAcquireInfo)[mapData.Tid]
    for i = 1, mapData.Qty do
      if i > 1 then
        bNew = false
      end
      local tbItemList = {}
      if mapAcquireInfo then
        tbItemList = self:GetAcquireReward(mapData.Tid, mapAcquireInfo.Begin + i)
      end
      local rewardData = {nId = mapData.Tid, bNew = bNew, tbItemList = tbItemList}
      ;
      (table.insert)(tbSpReward, rewardData)
    end
    ;
    (table.insert)(tbReward, {id = mapData.Tid, count = mapData.Qty, rewardType = mapData.rewardType})
  end

  local tbItemAfter = {}
  for _,mapData in ipairs(tbItem) do
    (table.insert)(tbItemAfter, mapData)
  end
  for _,mapData in ipairs(tbItem) do
    local mapItemCfg = (ConfigTable.GetData_Item)(mapData.Tid)
    if mapItemCfg ~= nil then
      local nType = mapItemCfg.Type
      if nType == (GameEnum.itemType).Char or nType == (GameEnum.itemType).CharacterSkin then
        process_sp(mapData)
      else
        if nType == (GameEnum.itemType).Disc then
          process_sp(mapData)
        else
          ;
          (table.insert)(tbReward, {id = mapData.Tid, count = mapData.Qty, rewardType = mapData.rewardType})
        end
      end
    end
  end
  return tbReward, tbSpReward
end

PlayerItemData.ProcessTransChangeInfo = function(self, mapChangeInfo)
  -- function num : 0_23 , upvalues : _ENV
  local mapDecodeInfo = (UTILS.DecodeChangeInfo)(mapChangeInfo)
  local tbDst, tbSrc = {}, {}
  local tbDstByIdx, tbSrcByIdx = {}, {}
  local tbAcquireInfo = {}
  local tbNewCharOrDisc = {}
  if type(mapDecodeInfo) == "table" then
    if type(mapDecodeInfo["proto.Char"]) == "table" then
      for _,mapData in ipairs(mapDecodeInfo["proto.Char"]) do
        local itemInfo = (ConfigTable.GetData_Character)(mapData.Tid)
        if itemInfo then
          tbNewCharOrDisc[mapData.Tid] = true
        end
      end
    end
    do
      if type(mapDecodeInfo["proto.Disc"]) == "table" then
        for _,mapData in ipairs(mapDecodeInfo["proto.Disc"]) do
          local itemInfo = (ConfigTable.GetData)("Disc", mapData.Id)
          if itemInfo then
            tbNewCharOrDisc[mapData.Id] = true
          end
        end
      end
      do
        if type(mapDecodeInfo["proto.Transform"]) == "table" then
          for _,mapTrans in ipairs(mapDecodeInfo["proto.Transform"]) do
            for _,mapData in ipairs(mapTrans.Src) do
              if not tbSrc[mapData.Tid] then
                tbSrc[mapData.Tid] = {Tid = mapData.Tid, Qty = 0}
              end
              -- DECOMPILER ERROR at PC84: Confused about usage of register: R19 in 'UnsetPending'

              ;
              (tbSrc[mapData.Tid]).Qty = (tbSrc[mapData.Tid]).Qty + mapData.Qty
            end
            for _,mapData in ipairs(mapTrans.Dst) do
              if not tbDst[mapData.Tid] then
                tbDst[mapData.Tid] = {Tid = mapData.Tid, Qty = 0}
              end
              -- DECOMPILER ERROR at PC108: Confused about usage of register: R19 in 'UnsetPending'

              ;
              (tbDst[mapData.Tid]).Qty = (tbDst[mapData.Tid]).Qty + mapData.Qty
            end
          end
          for _,v in pairs(tbSrc) do
            (table.insert)(tbSrcByIdx, v)
          end
          for _,v in pairs(tbDst) do
            (table.insert)(tbDstByIdx, v)
          end
        end
        do
          if type(mapDecodeInfo["proto.Acquire"]) == "table" then
            tbAcquireInfo = self:ProcessAcquireInfo(mapDecodeInfo["proto.Acquire"])
          end
          return {tbSrc = tbSrcByIdx, tbDst = tbDstByIdx, tbNewCharOrDisc = tbNewCharOrDisc, tbAcquireInfo = tbAcquireInfo}
        end
      end
    end
  end
end

PlayerItemData.ProcessAcquireInfo = function(self, mapAcquire)
  -- function num : 0_24 , upvalues : _ENV
  local tbAcqById = {}
  for _,tbAcqList in ipairs(mapAcquire) do
    for _,mapAcq in ipairs(tbAcqList.List) do
      if not tbAcqById[mapAcq.Tid] then
        tbAcqById[mapAcq.Tid] = {}
      end
      ;
      (table.insert)(tbAcqById[mapAcq.Tid], mapAcq)
    end
  end
  local tbCombinedAcq = {}
  for Tid,v in pairs(tbAcqById) do
    (table.sort)(v, function(a, b)
    -- function num : 0_24_0
    do return a.Begin < b.Begin end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
    local Begin = (v[1]).Begin
    local Count = 0
    for _,mapAcq in ipairs(v) do
      Count = Count + mapAcq.Count
    end
    tbCombinedAcq[Tid] = {Begin = Begin, Count = Count}
  end
  return tbCombinedAcq
end

PlayerItemData.GetAcquireReward = function(self, nTid, nAcquireTimes)
  -- function num : 0_25 , upvalues : _ENV
  local tbList = {}
  local mapItemCfg = (ConfigTable.GetData_Item)(nTid)
  if not mapItemCfg then
    return tbList
  end
  local nMax = ((self._mapMaxAcquireReward)[mapItemCfg.Stype])[mapItemCfg.Rarity]
  if nMax < nAcquireTimes then
    nAcquireTimes = nMax
  end
  local nId = mapItemCfg.Stype * 1000 + mapItemCfg.Rarity * 100 + nAcquireTimes
  local mapCfg = (ConfigTable.GetData)("AcquireReward", nId)
  if not mapCfg or mapCfg.ItemNum == 0 then
    return tbList
  end
  ;
  (table.insert)(tbList, {Tid = mapCfg.ItemId, Qty = mapCfg.ItemNum})
  return tbList
end

PlayerItemData.CacheFragmentsOverflow = function(self, mapChangeInfo, mapGachaChangeInfo)
  -- function num : 0_26
  if mapChangeInfo then
    self.mapOverTrans = self:ProcessTransChangeInfo(mapChangeInfo)
  end
  if mapGachaChangeInfo then
    self.mapGachaTrans = self:ProcessTransChangeInfo(mapGachaChangeInfo)
  end
end

PlayerItemData.TryOpenFragmentsOverflow = function(self, callback)
  -- function num : 0_27 , upvalues : _ENV
  local tbSrc, tbDst = {}, {}
  if self.mapGachaTrans and (self.mapGachaTrans).tbSrc and #(self.mapGachaTrans).tbSrc > 0 then
    for _,v in ipairs((self.mapGachaTrans).tbSrc) do
      (table.insert)(tbSrc, v)
    end
    for _,v in ipairs((self.mapGachaTrans).tbDst) do
      (table.insert)(tbDst, v)
    end
    self.mapGachaTrans = nil
  end
  if self.mapOverTrans and (self.mapOverTrans).tbSrc and #(self.mapOverTrans).tbSrc > 0 then
    for _,v in ipairs((self.mapOverTrans).tbSrc) do
      (table.insert)(tbSrc, v)
    end
    for _,v in ipairs((self.mapOverTrans).tbDst) do
      (table.insert)(tbDst, v)
    end
    self.mapOverTrans = nil
  end
  if #tbDst > 0 and #tbSrc > 0 then
    (EventManager.Hit)(EventId.OpenPanel, PanelId.ReceiveAutoTrans, tbSrc, tbDst, callback)
  else
    if callback then
      callback()
    end
  end
end

PlayerItemData.GetFragmentsOverflow = function(self)
  -- function num : 0_28
  return self.mapOverTrans
end

PlayerItemData.SendUseItemMsg = function(self, itemList, callback, bShowReceiveProps)
  -- function num : 0_29 , upvalues : _ENV
  local msgData = {}
  msgData.Use = {}
  local msgCallback = function(sendData, netMsg)
    -- function num : 0_29_0 , upvalues : callback, _ENV, bShowReceiveProps
    local showRewardCallback = function()
      -- function num : 0_29_0_0 , upvalues : callback, _ENV, sendData, netMsg
      if callback ~= nil and type(callback) == "function" then
        callback(sendData, netMsg)
      end
    end

    if bShowReceiveProps then
      (UTILS.OpenReceiveByChangeInfo)(netMsg, showRewardCallback)
    else
      showRewardCallback()
    end
  end

  -- DECOMPILER ERROR at PC7: Confused about usage of register: R6 in 'UnsetPending'

  if itemList ~= nil then
    (msgData.Use).List = itemList
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).item_use_req, msgData, nil, msgCallback)
  end
end

PlayerItemData.SendPickItemMsg = function(self, itemList, callback, bShowReceiveProps)
  -- function num : 0_30 , upvalues : _ENV
  local msgData = {}
  msgData.Pick = {}
  local msgCallback = function(sendData, netMsg)
    -- function num : 0_30_0 , upvalues : callback, _ENV, bShowReceiveProps
    local showRewardCallback = function()
      -- function num : 0_30_0_0 , upvalues : callback, _ENV, sendData, netMsg
      if callback ~= nil and type(callback) == "function" then
        callback(sendData, netMsg)
      end
    end

    if bShowReceiveProps then
      (UTILS.OpenReceiveByChangeInfo)(netMsg, showRewardCallback)
    else
      showRewardCallback()
    end
  end

  -- DECOMPILER ERROR at PC7: Confused about usage of register: R6 in 'UnsetPending'

  if itemList ~= nil then
    (msgData.Pick).List = itemList
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).item_use_req, msgData, nil, msgCallback)
  end
end

return PlayerItemData

