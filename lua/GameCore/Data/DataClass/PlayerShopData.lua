local PlayerShopData = class("PlayerShopData")
local ClientManager = (CS.ClientManager).Instance
local DisplayMode = {Hide = 0, End = 1, Stay = 2}
PlayerShopData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self._tbShops = {}
  self._tbGoods = {}
  self._tbServerData = {}
  self._bFirstInShop = true
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  ;
  (EventManager.Add)(EventId.NewFuncUnlockWorldClass, self, self.OnEvent_NewFuncUnlockWorldClass)
end

PlayerShopData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  ;
  (EventManager.Remove)(EventId.NewFuncUnlockWorldClass, self, self.OnEvent_NewFuncUnlockWorldClass)
end

PlayerShopData.OnEvent_NewDay = function(self)
  -- function num : 0_2
  self:CacheDailyShopReward(true)
end

PlayerShopData.OnEvent_NewFuncUnlockWorldClass = function(self, nId)
  -- function num : 0_3 , upvalues : _ENV
  if nId == (GameEnum.OpenFuncType).DailyReward then
    self:CacheDailyShopReward(true)
  end
end

PlayerShopData.CheckShopData = function(self, callback)
  -- function num : 0_4 , upvalues : _ENV
  if next(self._tbShops) == nil then
    local func_create = function()
    -- function num : 0_4_0 , upvalues : self, callback
    self:CreateData()
    if callback then
      callback()
    end
  end

    do
      self:SendResidentShopGetReq({}, func_create)
    end
  else
    do
      local tbShopIds = self:GetNeedToRefreshShops()
      if #tbShopIds > 0 then
        local func_update = function()
    -- function num : 0_4_1 , upvalues : self, tbShopIds, callback
    self:UpdateData(tbShopIds)
    if callback then
      callback()
    end
  end

        self:SendResidentShopGetReq(tbShopIds, func_update)
      else
        do
          if callback then
            callback()
          end
        end
      end
    end
  end
end

PlayerShopData.CheckGoodsData = function(self, nShopId)
  -- function num : 0_5 , upvalues : ClientManager, _ENV
  local tbGoods = self:GetNeedToRefreshGoods(nShopId)
  if #tbGoods == 0 then
    return 
  end
  local nServerTimeStamp = ClientManager.serverTimeStamp
  for _,mapGoods in pairs(tbGoods) do
    -- DECOMPILER ERROR at PC21: Confused about usage of register: R9 in 'UnsetPending'

    if mapGoods.nDownShelfTime ~= 0 and mapGoods.nDownShelfTime <= nServerTimeStamp then
      ((self._tbGoods)[nShopId])[mapGoods.nId] = nil
    else
      self:UpdateGoodsData(nShopId, mapGoods.nId)
    end
  end
end

PlayerShopData.GetShopList = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local tbList = {}
  for _,mapShop in pairs(self._tbShops) do
    if mapShop.bUnlock and mapShop.bOpenAble then
      (table.insert)(tbList, mapShop)
    end
  end
  ;
  (table.sort)(tbList, function(a, b)
    -- function num : 0_6_0
    do return a.nSequence < b.nSequence end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return tbList
end

PlayerShopData.GetGoodsList = function(self, nShopId)
  -- function num : 0_7 , upvalues : _ENV, DisplayMode
  local tbList = {}
  for _,mapGoods in pairs((self._tbGoods)[nShopId]) do
    if mapGoods.bUnlock and mapGoods.bOpenAble and (not mapGoods.bSoldOut or mapGoods.nDisplayMode ~= DisplayMode.Hide) then
      (table.insert)(tbList, mapGoods)
    end
  end
  local comp = function(a, b)
    -- function num : 0_7_0 , upvalues : DisplayMode
    -- DECOMPILER ERROR at PC36: Unhandled construct in 'MakeBoolean' P1

    if (a.bSoldOut and a.nDisplayMode == DisplayMode.End) or b.bSoldOut and b.nDisplayMode ~= DisplayMode.End then
      do return not a.bSoldOut or a.nDisplayMode == DisplayMode.End == not b.bSoldOut or b.nDisplayMode == DisplayMode.End end
      do return a.nSaleNumber < b.nSaleNumber end
      -- DECOMPILER ERROR: 11 unprocessed JMP targets
    end
  end

  ;
  (table.sort)(tbList, comp)
  return tbList
end

PlayerShopData.GetShopAutoUpdateTime = function(self)
  -- function num : 0_8 , upvalues : _ENV, ClientManager
  local tbTime = {}
  for _,mapShop in pairs(self._tbShops) do
    if mapShop.nNextRefreshTime > 0 then
      (table.insert)(tbTime, mapShop.nNextRefreshTime)
    end
  end
  if #tbTime == 0 then
    return 0
  end
  ;
  (table.sort)(tbTime)
  return tbTime[1] - ClientManager.serverTimeStamp
end

PlayerShopData.GetGoodsAutoUpdateTime = function(self, nShopId)
  -- function num : 0_9 , upvalues : _ENV, ClientManager
  local tbTime = {}
  for _,mapGoods in pairs((self._tbGoods)[nShopId]) do
    if mapGoods.nNextRefreshTime > 0 then
      (table.insert)(tbTime, mapGoods.nNextRefreshTime)
    end
  end
  if #tbTime == 0 then
    return 0
  end
  ;
  (table.sort)(tbTime)
  return tbTime[1] - ClientManager.serverTimeStamp
end

PlayerShopData.GetShopFirstIn = function(self)
  -- function num : 0_10
  local bFirst = self._bFirstInShop
  if self._bFirstInShop == true then
    self._bFirstInShop = false
  end
  return bFirst
end

PlayerShopData.CreateData = function(self)
  -- function num : 0_11 , upvalues : ClientManager, _ENV
  local nServerTimeStamp = ClientManager.serverTimeStamp
  local func_ForEach_Shop = function(mapCfgData)
    -- function num : 0_11_0 , upvalues : self, nServerTimeStamp
    self:CreateShopData(mapCfgData, nServerTimeStamp)
  end

  ForEachTableLine(DataTable.ResidentShop, func_ForEach_Shop)
  local func_ForEach_Goods = function(mapCfgData)
    -- function num : 0_11_1 , upvalues : self, nServerTimeStamp
    if (self._tbShops)[mapCfgData.ShopId] then
      self:CreateGoodsData(mapCfgData, nServerTimeStamp)
    end
  end

  ForEachTableLine(DataTable.ResidentGoods, func_ForEach_Goods)
end

PlayerShopData.CreateShopData = function(self, mapCfgData, nServerTimeStamp)
  -- function num : 0_12 , upvalues : _ENV
  local nCloseTime = self:ChangeToTimeStamp(mapCfgData.CloseTime)
  local bExpired = nCloseTime ~= 0 and nCloseTime <= nServerTimeStamp
  if bExpired then
    return 
  end
  local mapShop = {nId = mapCfgData.Id, tbShopCoin = mapCfgData.ShopCoin, sName = mapCfgData.Name, nSequence = mapCfgData.Sequence, nRefreshTimeType = mapCfgData.RefreshTimeType, nRefreshInterval = mapCfgData.RefreshInterval, nUnlockCondType = mapCfgData.UnlockCondType, tbUnlockCondParams = decodeJson(mapCfgData.UnlockCondParams), nOpenTime = self:ChangeToTimeStamp(mapCfgData.OpenTime), nCloseTime = nCloseTime, bUnlock = false, bOpenAble = false, nServerRefreshTime = 0, nNextRefreshTime = 0}
  -- DECOMPILER ERROR at PC42: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (self._tbShops)[mapCfgData.Id] = mapShop
  self:UpdateShopData(mapCfgData.Id)
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerShopData.CreateGoodsData = function(self, mapCfgData, nServerTimeStamp)
  -- function num : 0_13 , upvalues : _ENV
  local nDownShelfTime = self:ChangeToTimeStamp(mapCfgData.DownShelfTime)
  local bExpired = nDownShelfTime ~= 0 and nDownShelfTime <= nServerTimeStamp
  if bExpired then
    return 
  end
  local mapGoods = {nId = mapCfgData.Id, sName = mapCfgData.Name, sDesc = mapCfgData.Desc, nSaleNumber = mapCfgData.SaleNumber, nItemId = mapCfgData.ItemId, nItemQuantity = mapCfgData.ItemQuantity, nMaximumLimit = mapCfgData.MaximumLimit, nCurrencyItemId = mapCfgData.CurrencyItemId, nPrice = mapCfgData.Price, nOriginalPrice = mapCfgData.OriginalPrice, nDiscount = mapCfgData.Discount, nAppearCondType = mapCfgData.AppearCondType, tbAppearCondParams = decodeJson(mapCfgData.AppearCondParams), nPurchaseCondType = mapCfgData.PurchaseCondType, tbPurchaseCondParams = decodeJson(mapCfgData.PurchaseCondParams), nUpShelfTime = self:ChangeToTimeStamp(mapCfgData.UpShelfTime), nDownShelfTime = nDownShelfTime, nUnlockPurchaseTime = self:ChangeToTimeStamp(mapCfgData.UnlockPurchaseTime), nDisplayMode = mapCfgData.DisplayMode, bUnlock = false, bPurchasable = false, bPurchasTime = false, bOpenAble = false, bSoldOut = false, nBoughtCount = 0, nNextRefreshTime = 0}
  -- DECOMPILER ERROR at PC73: Confused about usage of register: R6 in 'UnsetPending'

  if not (self._tbGoods)[mapCfgData.ShopId] then
    (self._tbGoods)[mapCfgData.ShopId] = {}
  end
  -- DECOMPILER ERROR at PC78: Confused about usage of register: R6 in 'UnsetPending'

  ;
  ((self._tbGoods)[mapCfgData.ShopId])[mapCfgData.Id] = mapGoods
  self:UpdateGoodsData(mapCfgData.ShopId, mapCfgData.Id)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

PlayerShopData.ChangeToTimeStamp = function(self, sTime)
  -- function num : 0_14 , upvalues : ClientManager
  if sTime ~= "" or not 0 then
    return ClientManager:ISO8601StrToTimeStamp(sTime)
  end
end

PlayerShopData.UpdateData = function(self, tbShopIds)
  -- function num : 0_15 , upvalues : ClientManager, _ENV
  local nServerTimeStamp = ClientManager.serverTimeStamp
  for _,nShopId in pairs(tbShopIds) do
    -- DECOMPILER ERROR at PC16: Confused about usage of register: R8 in 'UnsetPending'

    if ((self._tbShops)[nShopId]).nCloseTime ~= 0 and ((self._tbShops)[nShopId]).nCloseTime <= nServerTimeStamp then
      (self._tbShops)[nShopId] = nil
      -- DECOMPILER ERROR at PC18: Confused about usage of register: R8 in 'UnsetPending'

      ;
      (self._tbGoods)[nShopId] = nil
    else
      self:UpdateShopData(nShopId)
      for nGoodsId,mapGoods in pairs((self._tbGoods)[nShopId]) do
        -- DECOMPILER ERROR at PC36: Confused about usage of register: R13 in 'UnsetPending'

        if mapGoods.nDownShelfTime ~= 0 and mapGoods.nDownShelfTime <= nServerTimeStamp then
          ((self._tbGoods)[nShopId])[nGoodsId] = nil
        else
          self:UpdateGoodsData(nShopId, nGoodsId)
        end
      end
    end
  end
end

PlayerShopData.UpdateShopData = function(self, nId)
  -- function num : 0_16 , upvalues : ClientManager
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R2 in 'UnsetPending'

  ((self._tbShops)[nId]).bUnlock = self:CheckShopCond(((self._tbShops)[nId]).nUnlockCondType, ((self._tbShops)[nId]).tbUnlockCondParams)
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R2 in 'UnsetPending'

  ;
  ((self._tbShops)[nId]).bOpenAble = ((self._tbShops)[nId]).nOpenTime <= ClientManager.serverTimeStamp
  -- DECOMPILER ERROR at PC34: Confused about usage of register: R2 in 'UnsetPending'

  ;
  ((self._tbShops)[nId]).nServerRefreshTime = (self._tbServerData)[nId] and ((self._tbServerData)[nId]).RefreshTime or 0
  -- DECOMPILER ERROR at PC43: Confused about usage of register: R2 in 'UnsetPending'

  ;
  ((self._tbShops)[nId]).nNextRefreshTime = self:UpdateNextShopRefreshTime(nId, ((self._tbShops)[nId]).nServerRefreshTime)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

PlayerShopData.UpdateGoodsData = function(self, nShopId, nGoodsId)
  -- function num : 0_17 , upvalues : _ENV, ClientManager
  local mapGoods = ((self._tbGoods)[nShopId])[nGoodsId]
  local nBoughtCount = self:GetBoughtCount(nGoodsId)
  -- DECOMPILER ERROR at PC16: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self._tbGoods)[nShopId])[nGoodsId]).bUnlock = self:CheckShopCond(mapGoods.nAppearCondType, mapGoods.tbAppearCondParams, (AllEnum.ShopCondSource).ResidentGoods)
  -- DECOMPILER ERROR at PC27: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self._tbGoods)[nShopId])[nGoodsId]).bPurchasable = self:CheckShopCond(mapGoods.nPurchaseCondType, mapGoods.tbPurchaseCondParams, (AllEnum.ShopCondSource).ResidentGoods)
  -- DECOMPILER ERROR at PC37: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self._tbGoods)[nShopId])[nGoodsId]).bPurchasTime = mapGoods.nUnlockPurchaseTime <= ClientManager.serverTimeStamp
  -- DECOMPILER ERROR at PC47: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self._tbGoods)[nShopId])[nGoodsId]).bOpenAble = mapGoods.nUpShelfTime <= ClientManager.serverTimeStamp
  -- DECOMPILER ERROR at PC58: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self._tbGoods)[nShopId])[nGoodsId]).bSoldOut = nBoughtCount ~= 0 and nBoughtCount == mapGoods.nMaximumLimit
  -- DECOMPILER ERROR at PC62: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self._tbGoods)[nShopId])[nGoodsId]).nBoughtCount = nBoughtCount
  -- DECOMPILER ERROR at PC70: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self._tbGoods)[nShopId])[nGoodsId]).nNextRefreshTime = self:UpdateNextGoodsRefreshTime(nShopId, nGoodsId)
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

PlayerShopData.UpdateNextShopRefreshTime = function(self, nId, nServerRefreshTime)
  -- function num : 0_18 , upvalues : ClientManager
  local mapShop = (self._tbShops)[nId]
  do
    if mapShop.nOpenTime > 0 then
      local nTime = mapShop.nOpenTime
      if nTime - ClientManager.serverTimeStamp > 0 then
        return nTime
      end
    end
    local nNextRefreshTime = 0
    do
      if mapShop.nCloseTime > 0 then
        local nTime = mapShop.nCloseTime
        nNextRefreshTime = nTime
      end
      do
        if mapShop.nRefreshTimeType > 0 then
          local nTime = nServerRefreshTime
        end
        -- DECOMPILER ERROR at PC27: Unhandled construct in 'MakeBoolean' P3

        if (nNextRefreshTime == 0 or nTime < nNextRefreshTime) then
          return nNextRefreshTime
        end
      end
    end
  end
end

PlayerShopData.UpdateNextGoodsRefreshTime = function(self, nShopId, nGoodsId)
  -- function num : 0_19 , upvalues : ClientManager
  local mapGoods = ((self._tbGoods)[nShopId])[nGoodsId]
  do
    if mapGoods.nUpShelfTime > 0 then
      local nTime = mapGoods.nUpShelfTime
      if nTime - ClientManager.serverTimeStamp > 0 then
        return nTime
      end
    end
    local nNextRefreshTime = 0
    do
      if mapGoods.nDownShelfTime > 0 then
        local nTime = mapGoods.nDownShelfTime
        nNextRefreshTime = nTime
      end
      do
        if mapGoods.nUnlockPurchaseTime > 0 then
          local nTime = mapGoods.nUnlockPurchaseTime
        end
        -- DECOMPILER ERROR at PC28: Unhandled construct in 'MakeBoolean' P3

        if (nNextRefreshTime == 0 or nTime < nNextRefreshTime) then
          return nNextRefreshTime
        end
      end
    end
  end
end

PlayerShopData.ProcessServerData = function(self, mapServerData)
  -- function num : 0_20 , upvalues : _ENV
  for _,mapShop in ipairs(mapServerData) do
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R7 in 'UnsetPending'

    (self._tbServerData)[mapShop.Id] = {}
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R7 in 'UnsetPending'

    ;
    ((self._tbServerData)[mapShop.Id]).RefreshTime = mapShop.RefreshTime or 0
    for _,mapBoughtGoods in ipairs(mapShop.Infos) do
      -- DECOMPILER ERROR at PC25: Confused about usage of register: R12 in 'UnsetPending'

      ((self._tbServerData)[mapShop.Id])[mapBoughtGoods.Id] = mapBoughtGoods.Number
    end
  end
end

PlayerShopData.GetBoughtCount = function(self, nGoodsId)
  -- function num : 0_21 , upvalues : _ENV
  local mapGoods = (ConfigTable.GetData)("ResidentGoods", nGoodsId)
  if mapGoods == nil then
    printError("商品配置不存在" .. nGoodsId)
    return 0
  end
  local nShopId = mapGoods.ShopId
  if (self._tbServerData)[nShopId] and ((self._tbServerData)[nShopId])[nGoodsId] then
    return ((self._tbServerData)[nShopId])[nGoodsId]
  else
    return 0
  end
end

PlayerShopData.CacheDailyShopReward = function(self, bDailyReward)
  -- function num : 0_22 , upvalues : _ENV
  local bUnlock = (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).DailyReward)
  self.bDailyReward = not bUnlock or bDailyReward
  ;
  (RedDotManager.SetValid)(RedDotDefine.Shop_Daily, nil, self.bDailyReward)
end

PlayerShopData.GetDailyShopReward = function(self)
  -- function num : 0_23
  return self.bDailyReward
end

PlayerShopData.GetNeedToRefreshShops = function(self)
  -- function num : 0_24 , upvalues : ClientManager, _ENV
  local tbShopIds = {}
  local nServerTimeStamp = ClientManager.serverTimeStamp
  for _,mapShop in pairs(self._tbShops) do
    if not mapShop.bUnlock then
      local bUnlock = self:CheckShopCond(mapShop.nUnlockCondType, mapShop.tbUnlockCondParams)
      if bUnlock then
        (table.insert)(tbShopIds, mapShop.nId)
      end
    else
      do
        do
          if mapShop.nNextRefreshTime > 0 and mapShop.nNextRefreshTime <= nServerTimeStamp then
            (table.insert)(tbShopIds, mapShop.nId)
          end
          -- DECOMPILER ERROR at PC32: LeaveBlock: unexpected jumping out DO_STMT

          -- DECOMPILER ERROR at PC32: LeaveBlock: unexpected jumping out IF_ELSE_STMT

          -- DECOMPILER ERROR at PC32: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  return tbShopIds
end

PlayerShopData.GetNeedToRefreshGoods = function(self, nShopId)
  -- function num : 0_25 , upvalues : ClientManager, _ENV
  local tbGoods = {}
  local nServerTimeStamp = ClientManager.serverTimeStamp
  if (self._tbGoods)[nShopId] then
    for _,mapGoods in pairs((self._tbGoods)[nShopId]) do
      if not mapGoods.bUnlock then
        local bUnlock = self:CheckShopCond(mapGoods.nAppearCondType, mapGoods.tbAppearCondParams, (AllEnum.ShopCondSource).ResidentGoods)
        if bUnlock then
          (table.insert)(tbGoods, mapGoods)
        end
      else
        do
          if not mapGoods.bPurchasable then
            local bPurchasable = self:CheckShopCond(mapGoods.nPurchaseCondType, mapGoods.tbPurchaseCondParams, (AllEnum.ShopCondSource).ResidentGoods)
            if bPurchasable then
              (table.insert)(tbGoods, mapGoods)
            end
          else
            do
              do
                if mapGoods.nNextRefreshTime > 0 and mapGoods.nNextRefreshTime <= nServerTimeStamp then
                  (table.insert)(tbGoods, mapGoods)
                end
                -- DECOMPILER ERROR at PC58: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC58: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC58: LeaveBlock: unexpected jumping out IF_STMT

                -- DECOMPILER ERROR at PC58: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC58: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC58: LeaveBlock: unexpected jumping out IF_STMT

              end
            end
          end
        end
      end
    end
  end
  return tbGoods
end

PlayerShopData.CheckShopCond = function(self, eCond, tbParam, nType)
  -- function num : 0_26 , upvalues : _ENV
  if eCond == 0 then
    return true
  else
    if eCond == (GameEnum.shopCond).WorldClassSpecific and #tbParam == 1 then
      local worldClass = (PlayerData.Base):GetWorldClass()
      return tbParam[1] <= worldClass
    elseif eCond == (GameEnum.shopCond).ShopPreGoodsSellOut and #tbParam == 2 and nType == (AllEnum.ShopCondSource).ResidentGoods then
      local nBeforeId = tbParam[2]
      local nBoughtCount = self:GetBoughtCount(nBeforeId)
      local mapCfg = (ConfigTable.GetData)("ResidentGoods", nBeforeId)
      if not mapCfg then
        return false
      end
      local bSoldOut = nBoughtCount ~= 0 and nBoughtCount == mapCfg.MaximumLimit
      return bSoldOut
    else
      printError("条件配置错误：")
      return false
    end
  end
  -- DECOMPILER ERROR: 7 unprocessed JMP targets
end

PlayerShopData.SendResidentShopGetReq = function(self, tbShopIds, callback)
  -- function num : 0_27 , upvalues : _ENV
  local mapMsg = {ShopIds = tbShopIds}
  local successCallback = function(_, mapData)
    -- function num : 0_27_0 , upvalues : self, callback, _ENV
    if mapData.Shops then
      self:ProcessServerData(mapData.Shops)
      callback()
    else
      printError("商店数据为空")
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).resident_shop_get_req, mapMsg, nil, successCallback)
end

PlayerShopData.SendResidentShopPurchaseReq = function(self, nShopId, nGoodsId, nCount, callback)
  -- function num : 0_28 , upvalues : _ENV
  local mapMsg = {GoodsId = nGoodsId, Number = nCount, RefreshTime = ((self._tbShops)[nShopId]).nServerRefreshTime, ShopId = nShopId}
  local successCallback = function(_, mapData)
    -- function num : 0_28_0 , upvalues : self, _ENV, nShopId, nGoodsId, callback
    if mapData.IsRefresh then
      self:ProcessServerData({mapData.Shop})
      ;
      (EventManager.Hit)("ShopTimeRefresh")
    else
      -- DECOMPILER ERROR at PC22: Confused about usage of register: R2 in 'UnsetPending'

      if not (self._tbServerData)[nShopId] then
        (self._tbServerData)[nShopId] = {}
      end
      -- DECOMPILER ERROR at PC28: Confused about usage of register: R2 in 'UnsetPending'

      ;
      ((self._tbServerData)[nShopId])[nGoodsId] = mapData.PurchasedNumber
    end
    self:UpdateData({nShopId})
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapData.Change)
    if callback then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).resident_shop_purchase_req, mapMsg, nil, successCallback)
end

PlayerShopData.SendDailyShopRewardReceiveReq = function(self, callback)
  -- function num : 0_29 , upvalues : _ENV
  local successCallback = function(_, mapData)
    -- function num : 0_29_0 , upvalues : self, _ENV, callback
    self.bDailyReward = false
    ;
    (RedDotManager.SetValid)(RedDotDefine.Shop_Daily, nil, false)
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapData)
    if callback then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).daily_shop_reward_receive_req, {}, nil, successCallback)
end

return PlayerShopData

