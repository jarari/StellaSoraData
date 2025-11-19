local PlayerMallData = class("PlayerMallData")
local TimerManager = require("GameCore.Timer.TimerManager")
local MessageBoxManager = require("GameCore.Module.MessageBoxManager")
local ClientManager = (CS.ClientManager).Instance
local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
local SDKManager = (CS.SDKManager).Instance
local DisplayMode = {Hide = 0, End = 1, Stay = 2}
local OrderStatus = {Unpaid = "Unpaid", Done = "Done", Retry = "Retry", Error = "Error"}
PlayerMallData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV, PlayerMallData
  self._tbNextMallPackage = nil
  self._tbNextMallShop = nil
  self._tbOrderCollect = {}
  self._mapOrderId = {}
  self._nOrderIdPaying = nil
  self._tbWaitingOrderCollect = nil
  self._mapOrderReward = nil
  self._mapOrderCollecting = nil
  self._bWaitTimeOut = false
  self._bRetry = false
  self._bProcessingOrder = false
  self._timerOrderCollect = nil
  self._timerOrderWait = nil
  self._tbPackagePage = {}
  self._tbExchangeShop = {}
  ;
  (EventManager.Add)("OnSdkPaySuc", PlayerMallData, self.OnEvent_PayRespone)
  ;
  (EventManager.Add)("OnSdkPayFail", PlayerMallData, self.OnEvent_PayRespone)
  self:ProcessExchangeShop()
  self:ProcessPackagePage()
end

PlayerMallData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV, PlayerMallData
  self._tbNextMallPackage = nil
  self._tbNextMallShop = nil
  self._tbOrderCollect = nil
  self._mapOrderId = nil
  self._nOrderIdPaying = nil
  self._tbWaitingOrderCollect = nil
  self._mapOrderReward = nil
  self._mapOrderCollecting = nil
  self._bWaitTimeOut = false
  self._bRetry = false
  self._bProcessingOrder = false
  self._timerOrderCollect = nil
  self._timerOrderWait = nil
  self._tbPackagePage = nil
  self._tbExchangeShop = nil
  ;
  (EventManager.Remove)("OnSdkPaySuc", PlayerMallData, self.OnEvent_PayRespone)
  ;
  (EventManager.Remove)("OnSdkPayFail", PlayerMallData, self.OnEvent_PayRespone)
end

PlayerMallData.GetExchangeShop = function(self)
  -- function num : 0_2
  return self._tbExchangeShop
end

PlayerMallData.GetPackagePage = function(self, nType)
  -- function num : 0_3
  if not (self._tbPackagePage)[nType] then
    return {}
  end
end

PlayerMallData.CheckOrderProcess = function(self)
  -- function num : 0_4
  return self._bProcessingOrder
end

PlayerMallData.BuyGem = function(self, sId, sStatistical)
  -- function num : 0_5 , upvalues : _ENV, SDKManager
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (NovaAPI.UserEventUpload)("purchase_click", tab)
  local callback = function(mapData)
    -- function num : 0_5_0 , upvalues : self, sStatistical, _ENV, SDKManager, sId
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R1 in 'UnsetPending'

    (self._mapOrderId)[mapData.ExtraData] = {nOrderId = mapData.Id, StatisticalGroup = sStatistical, nType = (AllEnum.RMBOrderType).Mall}
    ;
    (EventManager.Hit)(EventId.BlockInput, true)
    self._nOrderIdPaying = mapData.Id
    SDKManager:Pay(sId, mapData.NotifyUrl, mapData.ExtraData)
  end

  self:SendMallGemOrderReq(sId, callback)
end

PlayerMallData.BuyPackage = function(self, sId, sStatistical)
  -- function num : 0_6 , upvalues : _ENV, SDKManager
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (NovaAPI.UserEventUpload)("purchase_click", tab)
  local callback = function(mapData)
    -- function num : 0_6_0 , upvalues : self, sStatistical, _ENV, SDKManager, sId
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R1 in 'UnsetPending'

    (self._mapOrderId)[mapData.ExtraData] = {nOrderId = mapData.Id, StatisticalGroup = sStatistical, nType = (AllEnum.RMBOrderType).Mall}
    ;
    (EventManager.Hit)(EventId.BlockInput, true)
    self._nOrderIdPaying = mapData.Id
    SDKManager:Pay(sId, mapData.NotifyUrl, mapData.ExtraData)
  end

  self:SendMallPackageOrderReq(sId, callback)
end

PlayerMallData.BuyMonthlyCard = function(self, sId, sStatistical)
  -- function num : 0_7 , upvalues : _ENV, SDKManager
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (NovaAPI.UserEventUpload)("purchase_click", tab)
  local callback = function(mapData)
    -- function num : 0_7_0 , upvalues : self, sStatistical, _ENV, SDKManager, sId
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R1 in 'UnsetPending'

    (self._mapOrderId)[mapData.ExtraData] = {nOrderId = mapData.Id, StatisticalGroup = sStatistical, nType = (AllEnum.RMBOrderType).Mall}
    ;
    (EventManager.Hit)(EventId.BlockInput, true)
    self._nOrderIdPaying = mapData.Id
    SDKManager:Pay(sId, mapData.NotifyUrl, mapData.ExtraData)
  end

  self:SendMallMonthlyCardOrderReq(sId, callback)
end

PlayerMallData.BuyBattlePass = function(self, nMode, nVersion, sId, sStatistical)
  -- function num : 0_8 , upvalues : _ENV, SDKManager
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (NovaAPI.UserEventUpload)("purchase_click", tab)
  local callback = function(mapData)
    -- function num : 0_8_0 , upvalues : self, sStatistical, _ENV, SDKManager, sId
    -- DECOMPILER ERROR at PC11: Confused about usage of register: R1 in 'UnsetPending'

    (self._mapOrderId)[mapData.ExtraData] = {nOrderId = mapData.Id, StatisticalGroup = sStatistical, nType = (AllEnum.RMBOrderType).BattlePass}
    ;
    (EventManager.Hit)(EventId.BlockInput, true)
    self._nOrderIdPaying = mapData.Id
    SDKManager:Pay(sId, mapData.NotifyUrl, mapData.ExtraData)
  end

  self:SendBattlePassOrderReq(nMode, nVersion, callback)
end

PlayerMallData.TestBuyBattlePass = function(self, nMode, nVersion)
  -- function num : 0_9 , upvalues : _ENV
  local callback = function(mapData)
    -- function num : 0_9_0 , upvalues : self, _ENV
    self:CollectEnqueue(mapData.Id, (AllEnum.RMBOrderType).BattlePass)
    self:ProcessOrder()
  end

  self:SendBattlePassOrderReq(nMode, nVersion, callback)
end

PlayerMallData.TestBuyGemSuc = function(self, sId)
  -- function num : 0_10 , upvalues : _ENV
  local callback = function(mapData)
    -- function num : 0_10_0 , upvalues : self, _ENV
    self:CollectEnqueue(mapData.Id, (AllEnum.RMBOrderType).Mall)
    self:ProcessOrder()
  end

  self:SendMallGemOrderReq(sId, callback)
end

PlayerMallData.TestBuyPackageSuc = function(self, sId)
  -- function num : 0_11 , upvalues : _ENV
  local callback = function(mapData)
    -- function num : 0_11_0 , upvalues : self, _ENV
    self:CollectEnqueue(mapData.Id, (AllEnum.RMBOrderType).Mall)
    self:ProcessOrder()
  end

  self:SendMallPackageOrderReq(sId, callback)
end

PlayerMallData.TestBuyMonthlyCardSuc = function(self, sId)
  -- function num : 0_12 , upvalues : _ENV
  local callback = function(mapData)
    -- function num : 0_12_0 , upvalues : self, _ENV
    self:CollectEnqueue(mapData.Id, (AllEnum.RMBOrderType).Mall)
    self:ProcessOrder()
  end

  self:SendMallMonthlyCardOrderReq(sId, callback)
end

PlayerMallData.ProcessExchangeShop = function(self)
  -- function num : 0_13 , upvalues : _ENV
  self._tbExchangeShop = {}
  local func_ForEach_ExchangeShop = function(mapData)
    -- function num : 0_13_0 , upvalues : _ENV, self
    (table.insert)(self._tbExchangeShop, mapData)
  end

  ForEachTableLine(DataTable.MallShopPage, func_ForEach_ExchangeShop)
  ;
  (table.sort)(self._tbExchangeShop, function(a, b)
    -- function num : 0_13_1
    do return a.Sort < b.Sort end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
end

PlayerMallData.ParseShopList = function(self, tbList)
  -- function num : 0_14 , upvalues : _ENV, DisplayMode
  local tbShop = {}
  for _,v in pairs(tbList) do
    local mapCfg = (ConfigTable.GetData)("MallShop", v.Id)
    if mapCfg then
      local mapPage = (ConfigTable.GetData)("MallShopPage", mapCfg.GroupId)
      if mapPage and (v.Stock > 0 or mapCfg.DisplayMode ~= DisplayMode.Hide) then
        local nDeListTime = (PlayerData.Shop):ChangeToTimeStamp(mapCfg.DeListTime)
        local nNextRefreshTime, bPrioritizeDeList = self:CalNextTime(v.RefreshTime, nDeListTime)
        local mapPackage = {sId = v.Id, nCurStock = v.Stock, nPageSort = mapPage.Sort, nSort = mapCfg.Sort, nDisplayMode = mapCfg.DisplayMode, bPrioritizeDeList = bPrioritizeDeList, nNextRefreshTime = nNextRefreshTime}
        ;
        (table.insert)(tbShop, mapPackage)
      end
    end
  end
  local comp = function(a, b)
    -- function num : 0_14_0 , upvalues : DisplayMode
    -- DECOMPILER ERROR at PC36: Unhandled construct in 'MakeBoolean' P3

    if (a.nCurStock == 0 and a.nDisplayMode == DisplayMode.End) or b.nDisplayMode ~= DisplayMode.End then
      do return a.nCurStock == 0 and a.nDisplayMode == DisplayMode.End == b.nCurStock == 0 and b.nDisplayMode == DisplayMode.End end
      if a.nPageSort >= b.nPageSort then
        do return a.nPageSort == b.nPageSort end
        do return a.nSort < b.nSort end
        -- DECOMPILER ERROR: 11 unprocessed JMP targets
      end
    end
  end

  ;
  (table.sort)(tbShop, comp)
  return tbShop
end

PlayerMallData.CalShopAutoTime = function(self, tbList)
  -- function num : 0_15 , upvalues : _ENV, ClientManager
  local tbTime = {}
  for _,mapData in pairs(tbList) do
    if mapData.nNextRefreshTime > 0 then
      (table.insert)(tbTime, mapData.nNextRefreshTime)
    end
  end
  do
    if not self._tbNextMallShop then
      for _,mapData in pairs({}) do
        (table.insert)(tbTime, mapData.nListTime)
      end
      if #tbTime == 0 then
        return 0
      end
      ;
      (table.sort)(tbTime)
      return tbTime[1] - ClientManager.serverTimeStamp
    end
  end
end

PlayerMallData.UpdateNextMallShop = function(self)
  -- function num : 0_16 , upvalues : ClientManager, _ENV
  local nServerTimeStamp = ClientManager.serverTimeStamp
  if self._tbNextMallShop == nil then
    self._tbNextMallShop = {}
    local func_ForEach_Shop = function(mapCfgData)
    -- function num : 0_16_0 , upvalues : _ENV, nServerTimeStamp, self
    local nListTime = (PlayerData.Shop):ChangeToTimeStamp(mapCfgData.ListTime)
    if nListTime > 0 and nServerTimeStamp < nListTime then
      (table.insert)(self._tbNextMallShop, {nId = mapCfgData.Id, nListTime = nListTime})
    end
  end

    ForEachTableLine(DataTable.MallShop, func_ForEach_Shop)
  else
    do
      local nCount = #self._tbNextMallShop
      if nCount > 0 then
        for i = nCount, -1 do
          if ((self._tbNextMallShop)[i]).nListTime <= nServerTimeStamp then
            (table.remove)(self._tbNextMallShop, i)
          end
        end
      end
    end
  end
end

PlayerMallData.ProcessPackagePage = function(self)
  -- function num : 0_17 , upvalues : _ENV
  self._tbPackagePage = {}
  local func_ForEach_PackagePage = function(mapData)
    -- function num : 0_17_0 , upvalues : self, _ENV
    local nType = mapData.Type
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

    if (self._tbPackagePage)[nType] == nil then
      (self._tbPackagePage)[nType] = {}
    end
    ;
    (table.insert)((self._tbPackagePage)[nType], mapData)
  end

  ForEachTableLine(DataTable.MallPackagePage, func_ForEach_PackagePage)
  for _,v in pairs(self._tbPackagePage) do
    (table.sort)(v, function(a, b)
    -- function num : 0_17_1
    do return a.Sort < b.Sort end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  end
end

PlayerMallData.ParsePackageList = function(self, tbList)
  -- function num : 0_18 , upvalues : _ENV, DisplayMode
  local tbPackage = {}
  for _,v in pairs(tbList) do
    local mapCfg = (ConfigTable.GetData)("MallPackage", v.Id)
    if mapCfg then
      local mapPage = (ConfigTable.GetData)("MallPackagePage", mapCfg.GroupId)
      if mapPage and (v.Stock > 0 or mapCfg.DisplayMode ~= DisplayMode.Hide) then
        local nDeListTime = (PlayerData.Shop):ChangeToTimeStamp(mapCfg.DeListTime)
        local nNextRefreshTime, bPrioritizeDeList = self:CalNextTime(v.RefreshTime, nDeListTime)
        local mapPackage = {sId = v.Id, nCurStock = v.Stock, nPageSort = mapPage.Sort, nSort = mapCfg.Sort, nDisplayMode = mapCfg.DisplayMode, bPrioritizeDeList = bPrioritizeDeList, nNextRefreshTime = nNextRefreshTime}
        ;
        (table.insert)(tbPackage, mapPackage)
      end
    end
  end
  local comp = function(a, b)
    -- function num : 0_18_0 , upvalues : DisplayMode
    -- DECOMPILER ERROR at PC36: Unhandled construct in 'MakeBoolean' P3

    if (a.nCurStock == 0 and a.nDisplayMode == DisplayMode.End) or b.nDisplayMode ~= DisplayMode.End then
      do return a.nCurStock == 0 and a.nDisplayMode == DisplayMode.End == b.nCurStock == 0 and b.nDisplayMode == DisplayMode.End end
      if a.nPageSort >= b.nPageSort then
        do return a.nPageSort == b.nPageSort end
        do return a.nSort < b.nSort end
        -- DECOMPILER ERROR: 11 unprocessed JMP targets
      end
    end
  end

  ;
  (table.sort)(tbPackage, comp)
  return tbPackage
end

PlayerMallData.CalNextTime = function(self, nReTime, nDeTime)
  -- function num : 0_19
  if nDeTime > 0 then
    if nReTime > 0 then
      if nDeTime < nReTime then
        return nDeTime, true
      else
        return nReTime, false
      end
    else
      return nDeTime, true
    end
  else
    return nReTime, false
  end
end

PlayerMallData.CalPackageAutoTime = function(self, tbPackageList)
  -- function num : 0_20 , upvalues : _ENV, ClientManager
  local tbTime = {}
  for _,mapData in pairs(tbPackageList) do
    if mapData.nNextRefreshTime > 0 then
      (table.insert)(tbTime, mapData.nNextRefreshTime)
    end
  end
  for _,mapData in pairs(self._tbNextMallPackage) do
    (table.insert)(tbTime, mapData.nListTime)
  end
  if #tbTime == 0 then
    return 0
  end
  ;
  (table.sort)(tbTime)
  return tbTime[1] - ClientManager.serverTimeStamp
end

PlayerMallData.UpdateNextMallPackage = function(self)
  -- function num : 0_21 , upvalues : ClientManager, _ENV
  local nServerTimeStamp = ClientManager.serverTimeStamp
  if self._tbNextMallPackage == nil then
    self._tbNextMallPackage = {}
    local func_ForEach_Package = function(mapCfgData)
    -- function num : 0_21_0 , upvalues : _ENV, nServerTimeStamp, self
    local nListTime = (PlayerData.Shop):ChangeToTimeStamp(mapCfgData.ListTime)
    if nListTime > 0 and nServerTimeStamp < nListTime then
      (table.insert)(self._tbNextMallPackage, {nId = mapCfgData.Id, nListTime = nListTime})
    end
  end

    ForEachTableLine(DataTable.MallPackage, func_ForEach_Package)
  else
    do
      local nCount = #self._tbNextMallPackage
      if nCount > 0 then
        for i = nCount, -1 do
          if ((self._tbNextMallPackage)[i]).nListTime <= nServerTimeStamp then
            (table.remove)(self._tbNextMallPackage, i)
          end
        end
      end
    end
  end
end

PlayerMallData.OnEvent_SdkPaySuc = function(self, nCode, sMsg, nOrderId, sExData)
  -- function num : 0_22 , upvalues : _ENV
  local mapOrder = (self._mapOrderId)[sExData]
  if mapOrder == nil then
    printError("OrderId not found:" .. sExData)
    return 
  end
  local nCacheOrderId = ((self._mapOrderId)[sExData]).nOrderId
  local nOrderType = ((self._mapOrderId)[sExData]).nType
  local sStatistical = ((self._mapOrderId)[sExData]).StatisticalGroup
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  if sStatistical ~= nil then
    if sStatistical == "pack.first" then
      (NovaAPI.UserEventUpload)("purchase_starterpack", tab)
      ;
      (PlayerData.Base):UserEventUpload_PC("pc_purchase_pack_first_160")
    else
      if sStatistical == "pack.sr" then
        (NovaAPI.UserEventUpload)("purchase_srtrekkerselect", tab)
        ;
        (PlayerData.Base):UserEventUpload_PC("pc_purchase_pack_sr_680")
      else
        if sStatistical == "pack.role" then
          (NovaAPI.UserEventUpload)("purchase_newtrekkerpack", tab)
          ;
          (PlayerData.Base):UserEventUpload_PC("pc_purchase_pack_role_1480")
        else
          if sStatistical == "pack.disc" then
            (NovaAPI.UserEventUpload)("purchase_newdiscpack", tab)
            ;
            (PlayerData.Base):UserEventUpload_PC("pc_purchase_pack_disc_1480")
          else
            if sStatistical == "pack.role_common" then
              (NovaAPI.UserEventUpload)("purchase_newtrekkerstandard", tab)
              ;
              (PlayerData.Base):UserEventUpload_PC("pc_purchase_pack_role_common_1280")
            else
              if sStatistical == "monthlyCard.small" then
                (NovaAPI.UserEventUpload)("purchase_monthlycard", tab)
                ;
                (PlayerData.Base):UserEventUpload_PC("pc_purchase_monthlyCard_small_650")
              else
                if sStatistical == "pack_role_m" then
                  (NovaAPI.UserEventUpload)("purchase_monthtrekkervoucher", tab)
                  ;
                  (PlayerData.Base):UserEventUpload_PC("pc_purchase_pack_01_role_m_2600")
                else
                  if sStatistical == "pack_disc_m" then
                    (NovaAPI.UserEventUpload)("purchase_monthdiscvoucher", tab)
                    ;
                    (PlayerData.Base):UserEventUpload_PC("pc_purchase_pack_01_disc_m_2600")
                  else
                    if sStatistical == "pack_role_w" then
                      (NovaAPI.UserEventUpload)("purchase_weektrekkerres", tab)
                      ;
                      (PlayerData.Base):UserEventUpload_PC("pc_purchase_pack_01_role_w_860")
                    else
                      if sStatistical == "pack_disc_w" then
                        (NovaAPI.UserEventUpload)("purchase_weekdiscres", tab)
                        ;
                        (PlayerData.Base):UserEventUpload_PC("pc_purchase_pack_01_disc_w_860")
                      else
                        if sStatistical == "pack_role" then
                          (NovaAPI.UserEventUpload)("purchase_trekkercelebration", tab)
                        else
                          if sStatistical == "pack_gift" then
                            (NovaAPI.UserEventUpload)("purchase_trekkerdessert", tab)
                          else
                            if sStatistical == "pack_disc" then
                              (NovaAPI.UserEventUpload)("purchase_discmusic", tab)
                            else
                              if sStatistical == "pack_res" then
                                (NovaAPI.UserEventUpload)("purchase_trekkerupgrade", tab)
                              else
                                if sStatistical == "pack.op_role" then
                                  (NovaAPI.UserEventUpload)("purchase_launchtrekker", tab)
                                else
                                  if sStatistical == "pack.op_disc" then
                                    (NovaAPI.UserEventUpload)("purchase_launchdisc", tab)
                                  else
                                    if (string.find)(sStatistical, "gem") ~= nil then
                                      (NovaAPI.UserEventUpload)("purchase_diamond", tab)
                                      ;
                                      (PlayerData.Base):UserEventUpload_PC("pc_purchase_" .. sStatistical)
                                    else
                                      if sStatistical == "BattlePassPremium" then
                                        (NovaAPI.UserEventUpload)("purchase_standardbp", tab)
                                        ;
                                        (PlayerData.Base):UserEventUpload_PC("pc_purchase_battlepass_68_1280")
                                      else
                                        if sStatistical == "BattlePassOrigin_Luxury" or sStatistical == "BattlePassOrigin_Complement" then
                                          (NovaAPI.UserEventUpload)("purchase_deluxebp", tab)
                                          local tmpEvent = sStatistical == "BattlePassOrigin_Luxury" and "pc_purchase_battlepass_98_1980" or "pc_purchase_battlepass_38_980"
                                          ;
                                          (PlayerData.Base):UserEventUpload_PC(tmpEvent)
                                        else
                                          do
                                            if sStatistical == "skin_3d" then
                                              (NovaAPI.UserEventUpload)("purchase_skin", tab)
                                            end
                                            -- DECOMPILER ERROR at PC274: Confused about usage of register: R10 in 'UnsetPending'

                                            ;
                                            (self._mapOrderId)[sExData] = nil
                                            self:CollectEnqueue(nCacheOrderId, nOrderType)
                                            self:ProcessOrder()
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

PlayerMallData.OnEvent_SdkPayFail = function(self, nCode, sMsg, nOrderId, sExData, nOrderIdPaying)
  -- function num : 0_23 , upvalues : _ENV
  printError("SdkPayFail Msg:" .. sMsg)
  printError("SdkPayFail nCode:" .. nCode)
  local mapOrder = (self._mapOrderId)[sExData]
  if mapOrder == nil then
    printError("OrderId not found:" .. sExData)
    if sExData == "" and nOrderIdPaying and nOrderIdPaying ~= "" and nOrderIdPaying ~= 0 then
      for k,v in pairs(self._mapOrderId) do
        -- DECOMPILER ERROR at PC35: Confused about usage of register: R12 in 'UnsetPending'

        if v.nOrderId == nOrderIdPaying then
          (self._mapOrderId)[k] = nil
          break
        end
      end
      do
        self:SendMallOrderCancelReq(nOrderIdPaying, nCode)
        do return  end
        local nCacheOrderId = ((self._mapOrderId)[sExData]).nOrderId
        -- DECOMPILER ERROR at PC48: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self._mapOrderId)[sExData] = nil
        self:SendMallOrderCancelReq(nCacheOrderId, nCode)
      end
    end
  end
end

PlayerMallData.OnEvent_PayRespone = function(self, nCode, sMsg, nOrderId, sExData)
  -- function num : 0_24 , upvalues : _ENV
  (EventManager.Hit)(EventId.BlockInput, false)
  printLog("收到SDK PayRespone")
  local nOrderIdPaying = self._nOrderIdPaying
  self._nOrderIdPaying = nil
  if nCode == 200180 or nCode == 0 or nCode == 201180 then
    self:OnEvent_SdkPaySuc(nCode, sMsg, nOrderId, sExData)
  else
    self:OnEvent_SdkPayFail(nCode, sMsg, nOrderId, sExData, nOrderIdPaying)
  end
end

PlayerMallData.OpenOrderWait = function(self)
  -- function num : 0_25 , upvalues : MessageBoxManager, _ENV, TimerManager
  if (MessageBoxManager.CheckOrderWaitOpen)() then
    return 
  end
  ;
  (EventManager.Hit)("OpenOrderWait")
  self._timerOrderWait = (TimerManager.Add)(1, 30, self, function()
    -- function num : 0_25_0 , upvalues : self, _ENV
    self._bWaitTimeOut = true
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Mall_OrderRetry"), bDisableSnap = true})
    self:CloseOrderWait()
  end
, true, true, false)
end

PlayerMallData.CloseOrderWait = function(self)
  -- function num : 0_26 , upvalues : MessageBoxManager, _ENV
  if self._timerOrderWait ~= nil then
    (self._timerOrderWait):Cancel(false)
    self._timerOrderWait = nil
  end
  if (MessageBoxManager.CheckOrderWaitOpen)() then
    (EventManager.Hit)("CloseOrderWait")
  end
end

PlayerMallData.ProcessOrder = function(self, bRetry)
  -- function num : 0_27
  if self._bProcessingOrder then
    return 
  end
  self._bProcessingOrder = true
  self._bRetry = bRetry == true
  if not self._bRetry then
    self:OpenOrderWait()
  end
  self._tbWaitingOrderCollect = {}
  self._mapOrderReward = {
tbReward = {}
, 
tbSpReward = {}
, 
tbSrc = {}
, 
tbDst = {}
}
  self:CollectDequeue()
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerMallData.SetReCollectTimer = function(self)
  -- function num : 0_28 , upvalues : TimerManager
  if self._timerOrderCollect ~= nil then
    (self._timerOrderCollect):Cancel(false)
    self._timerOrderCollect = nil
  end
  if #self._tbOrderCollect > 0 then
    self._timerOrderCollect = (TimerManager.Add)(1, 2, self, function()
    -- function num : 0_28_0 , upvalues : self
    self:ProcessOrder(true)
  end
, true, true, false)
  end
end

PlayerMallData.CollectDequeue = function(self)
  -- function num : 0_29 , upvalues : _ENV
  local mapOrder = (self._tbOrderCollect)[1]
  ;
  (table.remove)(self._tbOrderCollect, 1)
  printLog("当前处理订单：" .. mapOrder.nOrderId)
  if next(self._tbOrderCollect) ~= nil then
    printLog("----预备订单----")
    for _,v in ipairs(self._tbOrderCollect) do
      printLog("订单：" .. v.nOrderId .. "    等待处理")
    end
    printLog("---------------")
  else
    printLog("后续无待处理订单")
  end
  self._mapOrderCollecting = mapOrder
  if mapOrder.nType == (AllEnum.RMBOrderType).Mall then
    local callback = function(mapData)
    -- function num : 0_29_0 , upvalues : self, _ENV, mapOrder
    self._mapOrderCollecting = nil
    local tbSpReward = (PlayerData.CharSkin):GetSkinForReward()
    self:CollectOrder(mapOrder, mapData, tbSpReward)
  end

    self:SendMallOrderCollectReq(mapOrder.nOrderId, callback)
  else
    do
      if mapOrder.nType == (AllEnum.RMBOrderType).BattlePass then
        local callback = function(mapData)
    -- function num : 0_29_1 , upvalues : self, _ENV, mapOrder
    self._mapOrderCollecting = nil
    local tbSpReward = (PlayerData.CharSkin):GetSkinForReward()
    if mapData.CollectResp then
      (PlayerData.BattlePass):OnPremiumBuySuccess(mapData)
      self:CollectOrder(mapOrder, mapData.CollectResp, tbSpReward)
    else
      self:CollectOrder(mapOrder, mapData, tbSpReward)
    end
  end

        self:SendBattlePassOrderCollectReq(mapOrder.nOrderId, callback)
      end
    end
  end
end

PlayerMallData.CollectOrder = function(self, mapOrder, mapData, tbSpReward)
  -- function num : 0_30 , upvalues : _ENV, OrderStatus
  printLog("订单：" .. mapOrder.nOrderId .. "    奖励状态：" .. mapData.Status)
  if mapData.Items and next(mapData.Items) ~= nil then
    local mapReward = (PlayerData.Item):ProcessRewardChangeInfo(mapData.Items)
    for _,v in pairs(mapReward.tbReward) do
      (table.insert)((self._mapOrderReward).tbReward, v)
    end
    for _,v in pairs(mapReward.tbSpReward) do
      (table.insert)((self._mapOrderReward).tbSpReward, v)
    end
    for _,v in pairs(mapReward.tbSrc) do
      (table.insert)((self._mapOrderReward).tbSrc, v)
    end
    for _,v in pairs(mapReward.tbDst) do
      (table.insert)((self._mapOrderReward).tbDst, v)
    end
  end
  do
    if tbSpReward and next(tbSpReward) ~= nil then
      for _,v in pairs(tbSpReward) do
        (table.insert)((self._mapOrderReward).tbSpReward, v)
      end
    end
    do
      if mapData.Status == OrderStatus.Unpaid or mapData.Status == OrderStatus.Retry then
        local bHasWait = false
        for _,v in pairs(self._tbWaitingOrderCollect) do
          if v.nOrderId == mapOrder.nOrderId then
            bHasWait = true
            printError("订单：" .. mapOrder.nOrderId .. "    重复进入等待列表")
            break
          end
        end
        do
          do
            if not bHasWait then
              (table.insert)(self._tbWaitingOrderCollect, mapOrder)
            end
            if mapData.Status == OrderStatus.Done then
              local tab_1 = {}
              ;
              (table.insert)(tab_1, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
              ;
              (NovaAPI.UserEventUpload)("confirm_order", tab_1)
              local tab = {}
              ;
              (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
              ;
              (NovaAPI.UserEventUpload)("purchase_complete", tab)
            end
            do
              if mapData.Status == OrderStatus.Done then
                self:CollectEnd(self._tbOrderCollect and #self._tbOrderCollect ~= 0)
                self:CollectDequeue()
                -- DECOMPILER ERROR: 3 unprocessed JMP targets
              end
            end
          end
        end
      end
    end
  end
end

PlayerMallData.CollectEnd = function(self, bError)
  -- function num : 0_31 , upvalues : _ENV
  local funcClear = function()
    -- function num : 0_31_0 , upvalues : self, _ENV
    self._bProcessingOrder = false
    self._tbOrderCollect = {}
    if self._bWaitTimeOut then
      self._bWaitTimeOut = false
      for _,mapOrder in pairs(self._tbWaitingOrderCollect) do
        printError("订单：" .. mapOrder.nOrderId .. "    超时订单，需要联系客服，不再请求")
      end
    else
      do
        printLog("----需重新请求的订单----")
        for _,mapOrder in pairs(self._tbWaitingOrderCollect) do
          (table.insert)(self._tbOrderCollect, mapOrder)
          printLog("订单：" .. mapOrder.nOrderId .. "    未成功，重新进入订单列表")
        end
        printLog("---------------")
        self._tbWaitingOrderCollect = {}
        do
          if next(self._tbOrderCollect) == nil then
            local bMoney = true
            ;
            (EventManager.Hit)("MallOrderClear", bMoney)
          end
          self:SetReCollectTimer()
        end
      end
    end
  end

  if not bError then
    self:CloseOrderWait()
  end
  if (PanelManager.CheckPanelOpen)(PanelId.ReceiveAutoTrans) == true or (PanelManager.CheckPanelOpen)(PanelId.ReceivePropsTips) == true or (PanelManager.CheckPanelOpen)(PanelId.ReceiveSpecialReward) == true or (PanelManager.CheckNextPanelOpening)() then
    funcClear()
  else
    local sTip = nil
    if self._bRetry and self._bWaitTimeOut then
      sTip = (ConfigTable.GetUIText)("Mall_OrderDelayed")
    end
    ;
    (UTILS.OpenReceiveByReward)(self._mapOrderReward, funcClear, sTip)
  end
end

PlayerMallData.CollectEnqueue = function(self, nOrderId, nType)
  -- function num : 0_32 , upvalues : _ENV
  if not self._tbOrderCollect then
    self._tbOrderCollect = {}
  end
  ;
  (table.insert)(self._tbOrderCollect, {nOrderId = nOrderId, nType = nType})
end

PlayerMallData.SendBattlePassOrderReq = function(self, nMode, nVersion, callback)
  -- function num : 0_33 , upvalues : _ENV
  local mapMsg = {Mode = nMode, Version = nVersion}
  local successCallback = function(_, mapData)
    -- function num : 0_33_0 , upvalues : _ENV, callback
    printLog("创建订单：" .. mapData.Id)
    callback(mapData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).battle_pass_order_req, mapMsg, nil, successCallback)
end

PlayerMallData.SendMallGemListReq = function(self, callback)
  -- function num : 0_34 , upvalues : _ENV
  local successCallback = function(_, mapData)
    -- function num : 0_34_0 , upvalues : callback
    callback(mapData.List)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mall_gem_list_req, {}, nil, successCallback)
end

PlayerMallData.SendMallGemOrderReq = function(self, sId, callback)
  -- function num : 0_35 , upvalues : _ENV
  if type(sId) == "number" then
    sId = tostring(sId)
  end
  local mapMsg = {Value = sId}
  local successCallback = function(_, mapData)
    -- function num : 0_35_0 , upvalues : _ENV, callback
    printLog("创建订单：" .. mapData.Id)
    callback(mapData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mall_gem_order_req, mapMsg, nil, successCallback)
end

PlayerMallData.SendMallOrderCancelReq = function(self, nId, nCode, callback)
  -- function num : 0_36 , upvalues : _ENV
  local tbCancelCode = {200154, 200230, 200340, 200500, 200600, 201236, 101606, 101731, 201230, 201221, 201223, 201224}
  do
    if (table.indexof)(tbCancelCode, nCode) == 0 then
      local bMoney = true
      ;
      (EventManager.Hit)("MallOrderClear", bMoney)
      return 
    end
    printLog("订单取消")
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Mall_OrderCancel")})
    local bMoney = true
    ;
    (EventManager.Hit)("MallOrderClear", bMoney)
  end
end

PlayerMallData.SendMallOrderCollectReq = function(self, nId, callback)
  -- function num : 0_37 , upvalues : _ENV
  if type(nId) == "number" then
    nId = tostring(nId)
  end
  local mapMsg = {Value = nId}
  local successCallback = function(_, mapData)
    -- function num : 0_37_0 , upvalues : callback
    callback(mapData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mall_order_collect_req, mapMsg, nil, successCallback)
end

PlayerMallData.SendBattlePassOrderCollectReq = function(self, nId, callback)
  -- function num : 0_38 , upvalues : _ENV
  if type(nId) == "number" then
    nId = tostring(nId)
  end
  local mapMsg = {Value = nId}
  local successCallback = function(_, mapData)
    -- function num : 0_38_0 , upvalues : callback
    callback(mapData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).battle_pass_order_collect_req, mapMsg, nil, successCallback)
end

PlayerMallData.SendMallMonthlyCardListReq = function(self, callback)
  -- function num : 0_39 , upvalues : _ENV
  local successCallback = function(_, mapData)
    -- function num : 0_39_0 , upvalues : callback
    callback((mapData.List)[1])
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mall_monthlyCard_list_req, {}, nil, successCallback)
end

PlayerMallData.SendMallMonthlyCardOrderReq = function(self, sId, callback)
  -- function num : 0_40 , upvalues : _ENV
  local mapMsg = {Value = sId}
  local successCallback = function(_, mapData)
    -- function num : 0_40_0 , upvalues : _ENV, callback
    printLog("创建订单：" .. mapData.Id)
    callback(mapData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mall_monthlyCard_order_req, mapMsg, nil, successCallback)
end

PlayerMallData.SendMallPackageListReq = function(self, callback)
  -- function num : 0_41 , upvalues : _ENV
  local successCallback = function(_, mapData)
    -- function num : 0_41_0 , upvalues : self, callback
    self:UpdateNextMallPackage()
    local tbPackageList = self:ParsePackageList(mapData.List)
    local nAutoTime = self:CalPackageAutoTime(tbPackageList)
    callback(tbPackageList, nAutoTime)
    self:UpdateMallRedDot(tbPackageList)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mall_package_list_req, {}, nil, successCallback)
end

PlayerMallData.SendMallPackageOrderReq = function(self, sId, callback)
  -- function num : 0_42 , upvalues : _ENV, WwiseAudioMgr
  local mapMsg = {Value = sId}
  local successCallback = function(_, mapData)
    -- function num : 0_42_0 , upvalues : _ENV, callback, WwiseAudioMgr
    if mapData.Order then
      printLog("创建订单：" .. (mapData.Order).Id)
      callback(mapData.Order)
    else
      ;
      (UTILS.OpenReceiveByChangeInfo)(mapData.Change)
      local bMoney = false
      ;
      (EventManager.Hit)("MallOrderClear", bMoney)
      WwiseAudioMgr:SetState("system", "shop_purchased")
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mall_package_order_req, mapMsg, nil, successCallback)
end

PlayerMallData.SendMallShopListReq = function(self, callback)
  -- function num : 0_43 , upvalues : _ENV
  local successCallback = function(_, mapData)
    -- function num : 0_43_0 , upvalues : self, callback
    self:UpdateNextMallShop()
    local tbList = self:ParseShopList(mapData.List)
    local nAutoTime = self:CalShopAutoTime(tbList)
    callback(tbList, nAutoTime)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mall_shop_list_req, {}, nil, successCallback)
end

PlayerMallData.SendMallShopOrderReq = function(self, sId, nCount)
  -- function num : 0_44 , upvalues : _ENV, WwiseAudioMgr
  local mapMsg = {Id = sId, Qty = nCount}
  local successCallback = function(_, mapData)
    -- function num : 0_44_0 , upvalues : _ENV, WwiseAudioMgr
    (UTILS.OpenReceiveByChangeInfo)(mapData)
    local bMoney = false
    ;
    (EventManager.Hit)("MallOrderClear", bMoney)
    WwiseAudioMgr:SetState("system", "shop_purchased")
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mall_shop_order_req, mapMsg, nil, successCallback)
end

PlayerMallData.SendCharFragmentConvertReq = function(self, callBack)
  -- function num : 0_45 , upvalues : _ENV
  local mapMsg = {}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).fragments_convert_req, mapMsg, nil, callBack)
end

PlayerMallData.ProcessOrderPaidNotify = function(self, mapData)
  -- function num : 0_46 , upvalues : _ENV
  if self._mapOrderCollecting and (self._mapOrderCollecting).nOrderId == mapData.OrderId then
    return 
  end
  local nType = (AllEnum.RMBOrderType).Mall
  if mapData.Store == 3 then
    nType = (AllEnum.RMBOrderType).BattlePass
  end
  self:CollectEnqueue(mapData.OrderId, nType)
  self:ProcessOrder()
end

PlayerMallData.UpdateMallRedDot = function(self, tbPackageList)
  -- function num : 0_47 , upvalues : _ENV
  local bCheck = false
  for _,mallData in ipairs(tbPackageList) do
    local mapCfg = (ConfigTable.GetData)("MallPackage", mallData.sId)
    if mapCfg ~= nil and mapCfg.CurrencyType == (GameEnum.currencyType).Free then
      local tbCond = decodeJson(mapCfg.OrderCondParams)
      local bPurchaseAble = (PlayerData.Shop):CheckShopCond(mapCfg.OrderCondType, tbCond)
      if mallData.nCurStock > 0 and bPurchaseAble then
        bCheck = true
        ;
        (RedDotManager.SetValid)(RedDotDefine.FreePackage, {mallData.sId}, true)
      else
        ;
        (RedDotManager.SetValid)(RedDotDefine.FreePackage, {mallData.sId}, false)
      end
    end
  end
  ;
  (RedDotManager.SetValid)(RedDotDefine.Mall_Free, nil, bCheck)
end

return PlayerMallData

