local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local ActivityShopData = class("ActivityShopData", ActivityDataBase)
local ClientManager = (CS.ClientManager).Instance
local DisplayMode = {Hide = 0, End = 1, Stay = 2}
ActivityShopData.Init = function(self)
  -- function num : 0_0
  self.tbShops = {}
  self.tbGoods = {}
  self.tbServerData = {}
  self.bFirstInShop = true
  self:ParseConfig()
end

ActivityShopData.ParseConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local mapCfg = (ConfigTable.GetData)("ActivityShopControl", self.nActId)
  if not mapCfg then
    return 
  end
  self.mapShopControlCfg = mapCfg
end

ActivityShopData.RefreshActivityShopData = function(self, mapData)
  -- function num : 0_2 , upvalues : _ENV
  if mapData and mapData.Shops then
    self:ProcessServerData(mapData.Shops)
  end
  if next(self.tbShops) == nil then
    self:CreateData()
  else
    local tbShopIds = self:GetNeedToRefreshShops()
    if #tbShopIds > 0 then
      self:UpdateData(tbShopIds)
    end
  end
end

ActivityShopData.CheckGoodsData = function(self, nShopId)
  -- function num : 0_3 , upvalues : _ENV
  local tbGoods = self:GetNeedToRefreshGoods(nShopId)
  if #tbGoods == 0 then
    return 
  end
  for _,mapGoods in pairs(tbGoods) do
    self:UpdateGoodsData(nShopId, mapGoods.nId)
  end
end

ActivityShopData.GetShopList = function(self)
  -- function num : 0_4 , upvalues : _ENV
  local tbList = {}
  for _,mapShop in pairs(self.tbShops) do
    if mapShop.bUnlock and mapShop.bOpenAble then
      (table.insert)(tbList, mapShop)
    end
  end
  ;
  (table.sort)(tbList, function(a, b)
    -- function num : 0_4_0
    do return a.nSequence < b.nSequence end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return tbList
end

ActivityShopData.GetGoodsList = function(self, nShopId)
  -- function num : 0_5 , upvalues : _ENV, DisplayMode
  local tbList = {}
  for _,mapGoods in pairs((self.tbGoods)[nShopId]) do
    if mapGoods.bUnlock and (not mapGoods.bSoldOut or mapGoods.nDisplayMode ~= DisplayMode.Hide) then
      (table.insert)(tbList, mapGoods)
    end
  end
  local comp = function(a, b)
    -- function num : 0_5_0 , upvalues : DisplayMode
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

ActivityShopData.GetShopAutoUpdateTime = function(self)
  -- function num : 0_6 , upvalues : _ENV, ClientManager
  local tbTime = {}
  for _,mapShop in pairs(self.tbShops) do
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

ActivityShopData.GetGoodsAutoUpdateTime = function(self, nShopId)
  -- function num : 0_7 , upvalues : _ENV, ClientManager
  local tbTime = {}
  for _,mapGoods in pairs((self.tbGoods)[nShopId]) do
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

ActivityShopData.GetShopFirstIn = function(self)
  -- function num : 0_8
  local bFirst = self.bFirstInShop
  if self.bFirstInShop == true then
    self.bFirstInShop = false
  end
  return bFirst
end

ActivityShopData.CreateData = function(self)
  -- function num : 0_9 , upvalues : ClientManager, _ENV
  if not self.mapShopControlCfg then
    return 
  end
  local nServerTimeStamp = ClientManager.serverTimeStamp
  local nCloseTime = self.nEndTime
  local bExpired = nCloseTime ~= 0 and nCloseTime <= nServerTimeStamp
  if bExpired then
    return 
  end
  for _,nShopId in ipairs((self.mapShopControlCfg).ShopIds) do
    local mapCfg = (ConfigTable.GetData)("ActivityShop", nShopId)
    if mapCfg then
      self:CreateShopData(mapCfg)
    end
  end
  local func_ForEach_Goods = function(mapCfgData)
    -- function num : 0_9_0 , upvalues : self
    if (self.tbShops)[mapCfgData.ShopId] then
      self:CreateGoodsData(mapCfgData)
    end
  end

  ForEachTableLine(DataTable.ActivityGoods, func_ForEach_Goods)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

ActivityShopData.CreateShopData = function(self, mapCfgData)
  -- function num : 0_10 , upvalues : _ENV
  local mapShop = {nId = mapCfgData.Id, nSequence = mapCfgData.Sequence, nRefreshTimeType = mapCfgData.RefreshTimeType, nRefreshInterval = mapCfgData.RefreshInterval, nUnlockCondType = mapCfgData.UnlockCondType, tbUnlockCondParams = decodeJson(mapCfgData.UnlockCondParams), bUnlock = false, bOpenAble = false, nServerRefreshTime = 0, nNextRefreshTime = 0}
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self.tbShops)[mapCfgData.Id] = mapShop
  self:UpdateShopData(mapCfgData.Id)
end

ActivityShopData.CreateGoodsData = function(self, mapCfgData)
  -- function num : 0_11 , upvalues : _ENV
  local mapGoods = {nId = mapCfgData.Id, nSaleNumber = mapCfgData.SaleNumber, nMaximumLimit = mapCfgData.MaximumLimit, nAppearCondType = mapCfgData.AppearCondType, tbAppearCondParams = decodeJson(mapCfgData.AppearCondParams), nPurchaseCondType = mapCfgData.PurchaseCondType, tbPurchaseCondParams = decodeJson(mapCfgData.PurchaseCondParams), nUnlockPurchaseTime = self:ChangeToTimeStamp(mapCfgData.UnlockPurchaseTime), nDisplayMode = mapCfgData.DisplayMode, bUnlock = false, bPurchasable = false, bPurchasTime = false, bSoldOut = false, nBoughtCount = 0, nNextRefreshTime = 0}
  -- DECOMPILER ERROR at PC39: Confused about usage of register: R3 in 'UnsetPending'

  if not (self.tbGoods)[mapCfgData.ShopId] then
    (self.tbGoods)[mapCfgData.ShopId] = {}
  end
  -- DECOMPILER ERROR at PC44: Confused about usage of register: R3 in 'UnsetPending'

  ;
  ((self.tbGoods)[mapCfgData.ShopId])[mapCfgData.Id] = mapGoods
  self:UpdateGoodsData(mapCfgData.ShopId, mapCfgData.Id)
end

ActivityShopData.ChangeToTimeStamp = function(self, sTime)
  -- function num : 0_12 , upvalues : ClientManager
  if sTime ~= "" or not 0 then
    return ClientManager:ISO8601StrToTimeStamp(sTime)
  end
end

ActivityShopData.UpdateData = function(self, tbShopIds)
  -- function num : 0_13 , upvalues : ClientManager, _ENV
  local nServerTimeStamp = ClientManager.serverTimeStamp
  local nCloseTime = self.nEndTime
  local bExpired = nCloseTime ~= 0 and nCloseTime <= nServerTimeStamp
  if bExpired then
    self.tbShops = {}
    self.tbGoods = {}
    return 
  end
  for _,nShopId in pairs(tbShopIds) do
    self:UpdateShopData(nShopId)
    for nGoodsId,_ in pairs((self.tbGoods)[nShopId]) do
      self:UpdateGoodsData(nShopId, nGoodsId)
    end
  end
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

ActivityShopData.UpdateShopData = function(self, nId)
  -- function num : 0_14 , upvalues : ClientManager
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R2 in 'UnsetPending'

  ((self.tbShops)[nId]).bUnlock = self:CheckShopCond(((self.tbShops)[nId]).nUnlockCondType, ((self.tbShops)[nId]).tbUnlockCondParams)
  -- DECOMPILER ERROR at PC19: Confused about usage of register: R2 in 'UnsetPending'

  ;
  ((self.tbShops)[nId]).bOpenAble = self.nOpenTime <= ClientManager.serverTimeStamp
  -- DECOMPILER ERROR at PC32: Confused about usage of register: R2 in 'UnsetPending'

  ;
  ((self.tbShops)[nId]).nServerRefreshTime = (self.tbServerData)[nId] and ((self.tbServerData)[nId]).RefreshTime or 0
  -- DECOMPILER ERROR at PC41: Confused about usage of register: R2 in 'UnsetPending'

  ;
  ((self.tbShops)[nId]).nNextRefreshTime = self:UpdateNextShopRefreshTime(nId, ((self.tbShops)[nId]).nServerRefreshTime)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

ActivityShopData.UpdateGoodsData = function(self, nShopId, nGoodsId)
  -- function num : 0_15 , upvalues : ClientManager
  local mapGoods = ((self.tbGoods)[nShopId])[nGoodsId]
  local nBoughtCount = self:GetBoughtCount(nGoodsId)
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self.tbGoods)[nShopId])[nGoodsId]).bUnlock = self:CheckShopCond(mapGoods.nAppearCondType, mapGoods.tbAppearCondParams)
  -- DECOMPILER ERROR at PC21: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self.tbGoods)[nShopId])[nGoodsId]).bPurchasable = self:CheckShopCond(mapGoods.nPurchaseCondType, mapGoods.tbPurchaseCondParams)
  -- DECOMPILER ERROR at PC31: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self.tbGoods)[nShopId])[nGoodsId]).bPurchasTime = mapGoods.nUnlockPurchaseTime <= ClientManager.serverTimeStamp
  -- DECOMPILER ERROR at PC42: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self.tbGoods)[nShopId])[nGoodsId]).bSoldOut = nBoughtCount ~= 0 and nBoughtCount == mapGoods.nMaximumLimit
  -- DECOMPILER ERROR at PC46: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self.tbGoods)[nShopId])[nGoodsId]).nBoughtCount = nBoughtCount
  -- DECOMPILER ERROR at PC54: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (((self.tbGoods)[nShopId])[nGoodsId]).nNextRefreshTime = self:UpdateNextGoodsRefreshTime(nShopId, nGoodsId)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

ActivityShopData.UpdateNextShopRefreshTime = function(self, nId, nServerRefreshTime)
  -- function num : 0_16 , upvalues : ClientManager
  local mapShop = (self.tbShops)[nId]
  local nOpenTime = self.nOpenTime
  if nOpenTime > 0 and nOpenTime - ClientManager.serverTimeStamp > 0 then
    return nOpenTime
  end
  local nNextRefreshTime = 0
  local nCloseTime = self.nEndTime
  if nCloseTime > 0 then
    nNextRefreshTime = nCloseTime
  end
  do
    if mapShop.nRefreshTimeType > 0 then
      local nTime = nServerRefreshTime
    end
    -- DECOMPILER ERROR at PC25: Unhandled construct in 'MakeBoolean' P3

    if (nNextRefreshTime == 0 or nTime < nNextRefreshTime) then
      return nNextRefreshTime
    end
  end
end

ActivityShopData.UpdateNextGoodsRefreshTime = function(self, nShopId, nGoodsId)
  -- function num : 0_17
  local mapGoods = ((self.tbGoods)[nShopId])[nGoodsId]
  local nNextRefreshTime = 0
  do
    if mapGoods.nUnlockPurchaseTime > 0 then
      local nTime = mapGoods.nUnlockPurchaseTime
    end
    -- DECOMPILER ERROR at PC14: Unhandled construct in 'MakeBoolean' P3

    if (nNextRefreshTime == 0 or nTime < nNextRefreshTime) then
      return nNextRefreshTime
    end
  end
end

ActivityShopData.ProcessServerData = function(self, mapServerData)
  -- function num : 0_18 , upvalues : _ENV
  for _,mapShop in ipairs(mapServerData) do
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R7 in 'UnsetPending'

    (self.tbServerData)[mapShop.Id] = {}
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R7 in 'UnsetPending'

    ;
    ((self.tbServerData)[mapShop.Id]).RefreshTime = mapShop.RefreshTime or 0
    for _,mapBoughtGoods in ipairs(mapShop.Infos) do
      -- DECOMPILER ERROR at PC25: Confused about usage of register: R12 in 'UnsetPending'

      ((self.tbServerData)[mapShop.Id])[mapBoughtGoods.Id] = mapBoughtGoods.Number
    end
  end
end

ActivityShopData.GetBoughtCount = function(self, nGoodsId)
  -- function num : 0_19 , upvalues : _ENV
  local mapGoods = (ConfigTable.GetData)("ActivityGoods", nGoodsId)
  if mapGoods == nil then
    printError("商品配置不存在" .. nGoodsId)
    return 0
  end
  local nShopId = mapGoods.ShopId
  if (self.tbServerData)[nShopId] and ((self.tbServerData)[nShopId])[nGoodsId] then
    return ((self.tbServerData)[nShopId])[nGoodsId]
  else
    return 0
  end
end

ActivityShopData.GetNeedToRefreshShops = function(self)
  -- function num : 0_20 , upvalues : ClientManager, _ENV
  local tbShopIds = {}
  local nServerTimeStamp = ClientManager.serverTimeStamp
  for _,mapShop in pairs(self.tbShops) do
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

ActivityShopData.GetNeedToRefreshGoods = function(self, nShopId)
  -- function num : 0_21 , upvalues : ClientManager, _ENV
  local tbGoods = {}
  local nServerTimeStamp = ClientManager.serverTimeStamp
  if (self.tbGoods)[nShopId] then
    for _,mapGoods in pairs((self.tbGoods)[nShopId]) do
      if not mapGoods.bUnlock then
        local bUnlock = self:CheckShopCond(mapGoods.nAppearCondType, mapGoods.tbAppearCondParams)
        if bUnlock then
          (table.insert)(tbGoods, mapGoods)
        end
      else
        do
          if not mapGoods.bPurchasable then
            local bPurchasable = self:CheckShopCond(mapGoods.nPurchaseCondType, mapGoods.tbPurchaseCondParams)
            if bPurchasable then
              (table.insert)(tbGoods, mapGoods)
            end
          else
            do
              do
                if mapGoods.nNextRefreshTime > 0 and mapGoods.nNextRefreshTime <= nServerTimeStamp then
                  (table.insert)(tbGoods, mapGoods)
                end
                -- DECOMPILER ERROR at PC52: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC52: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC52: LeaveBlock: unexpected jumping out IF_STMT

                -- DECOMPILER ERROR at PC52: LeaveBlock: unexpected jumping out DO_STMT

                -- DECOMPILER ERROR at PC52: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                -- DECOMPILER ERROR at PC52: LeaveBlock: unexpected jumping out IF_STMT

              end
            end
          end
        end
      end
    end
  end
  return tbGoods
end

ActivityShopData.CheckShopCond = function(self, eCond, tbParam)
  -- function num : 0_22 , upvalues : _ENV
  if eCond == 0 then
    return true
  else
    if eCond == (GameEnum.shopCond).WorldClassSpecific and #tbParam == 1 then
      local worldClass = (PlayerData.Base):GetWorldClass()
      return tbParam[1] <= worldClass
    elseif eCond == (GameEnum.shopCond).ShopPreGoodsSellOut and #tbParam == 2 then
      local nBeforeId = tbParam[2]
      local nBoughtCount = self:GetBoughtCount(nBeforeId)
      local mapCfg = (ConfigTable.GetData)("ActivityGoods", nBeforeId)
      if not mapCfg then
        return false
      end
      local bSoldOut = nBoughtCount ~= 0 and nBoughtCount == mapCfg.MaximumLimit
      return bSoldOut
    elseif eCond == (GameEnum.shopCond).ActivityShopPreGoodsSellOut and #tbParam == 3 then
      local nBeforeId = tbParam[3]
      local nBoughtCount = self:GetBoughtCount(nBeforeId)
      local mapCfg = (ConfigTable.GetData)("ActivityGoods", nBeforeId)
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
  -- DECOMPILER ERROR: 11 unprocessed JMP targets
end

ActivityShopData.SendActivityShopPurchaseReq = function(self, nShopId, nGoodsId, nCount, callback)
  -- function num : 0_23 , upvalues : _ENV
  local mapMsg = {ActivityId = self.nActId, GoodsId = nGoodsId, Number = nCount, RefreshTime = ((self.tbShops)[nShopId]).nServerRefreshTime, ShopId = nShopId}
  local successCallback = function(_, mapData)
    -- function num : 0_23_0 , upvalues : self, _ENV, nShopId, nGoodsId, callback
    if mapData.IsRefresh then
      self:ProcessServerData({mapData.Shop})
      ;
      (EventManager.Hit)("ActivityShopTimeRefresh")
    else
      -- DECOMPILER ERROR at PC22: Confused about usage of register: R2 in 'UnsetPending'

      if not (self.tbServerData)[nShopId] then
        (self.tbServerData)[nShopId] = {}
      end
      -- DECOMPILER ERROR at PC28: Confused about usage of register: R2 in 'UnsetPending'

      ;
      ((self.tbServerData)[nShopId])[nGoodsId] = mapData.PurchasedNumber
    end
    self:UpdateData({nShopId})
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapData.Change)
    if callback then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_shop_purchase_req, mapMsg, nil, successCallback)
end

return ActivityShopData

