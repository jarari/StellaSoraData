--玩家氪金数据
------------------------------ local ------------------------------
local PlayerMallData = class("PlayerMallData")
local TimerManager = require "GameCore.Timer.TimerManager"
local MessageBoxManager = require "GameCore.Module.MessageBoxManager"

local ClientManager = CS.ClientManager.Instance
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
local SDKManager = CS.SDKManager.Instance

local DisplayMode = {
    Hide = 0,
    End = 1,
    Stay = 2
}

local OrderStatus = {
    Unpaid = "Unpaid", --尚未到账，后续可继续请求
    Done = "Done",     --已发放，后续不用再继续请求
    Retry = "Retry",   --异常，请稍后重试
    Error = "Error",   --异常，请放弃尝试
}
-------------------------------------------------------------------

------------------------------ public -----------------------------
function PlayerMallData:Init()
    self._tbNextMallPackage = nil
    self._tbNextMallShop = nil

    self._tbOrderCollect = {} -- 当前等待领取订单队列
    self._mapOrderId = {} -- 调用支付暂存的订单信息，key值为extra-data
    self._nOrderIdPaying = nil -- 当前正在支付中的订单id(在sdk没指定值的时候使用)
    self._tbWaitingOrderCollect = nil -- 当前领取失败需要重新等待领取的订单队列
    self._mapOrderReward = nil -- 当前所有订单能获得的奖励
    self._mapOrderCollecting = nil -- 当前正在领取中的订单
    self._bWaitTimeOut = false -- 是否等待超时
    self._bRetry = false -- 当前处理订单是否处于重试状态
    self._bProcessingOrder = false -- 当前是否在处理订单
    self._timerOrderCollect = nil -- 订单处理队列计时器
    self._timerOrderWait = nil -- 处理中界面计时器

    self._tbPackagePage = {}
    self._tbExchangeShop = {}

    EventManager.Add("OnSdkPaySuc", PlayerMallData, self.OnEvent_PayRespone)
    EventManager.Add("OnSdkPayFail", PlayerMallData, self.OnEvent_PayRespone)

    self:ProcessExchangeShop()
    self:ProcessPackagePage()
end

function PlayerMallData:UnInit()
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

    EventManager.Remove("OnSdkPaySuc", PlayerMallData, self.OnEvent_PayRespone)
    EventManager.Remove("OnSdkPayFail", PlayerMallData, self.OnEvent_PayRespone)
end

function PlayerMallData:GetExchangeShop()
    return self._tbExchangeShop
end

function PlayerMallData:GetPackagePage(nType)
    return self._tbPackagePage[nType] or {}
end

function PlayerMallData:CheckOrderProcess()
    return self._bProcessingOrder
end

------------------------------- Buy ------------------------------
function PlayerMallData:BuyGem(sId,sStatistical)
    ---客户端埋点---
    local tab = {}
    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
    NovaAPI.UserEventUpload("purchase_click",tab)
    ---客户端埋点结束---
    local function callback(mapData)
        -- mapData.ExtraData    透传数据
        -- mapData.Id   返回订单号
        -- mapData.NotifyUrl    游戏服务器发货回调地址
        self._mapOrderId[mapData.ExtraData] = {nOrderId = mapData.Id, StatisticalGroup = sStatistical, nType = AllEnum.RMBOrderType.Mall}
        EventManager.Hit(EventId.BlockInput, true) -- 呼出sdk窗口前屏蔽操作
        self._nOrderIdPaying = mapData.Id
        SDKManager:Pay(sId, mapData.NotifyUrl, mapData.ExtraData)
    end
    self:SendMallGemOrderReq(sId, callback)
end

function PlayerMallData:BuyPackage(sId,sStatistical)
    ---客户端埋点---
    local tab = {}
    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
    NovaAPI.UserEventUpload("purchase_click",tab)
    ---客户端埋点结束---
    local function callback(mapData)
        -- mapData.ExtraData    透传数据
        -- mapData.Id   返回订单号
        -- mapData.NotifyUrl    游戏服务器发货回调地址
        self._mapOrderId[mapData.ExtraData] = {nOrderId = mapData.Id, StatisticalGroup = sStatistical, nType = AllEnum.RMBOrderType.Mall}
        EventManager.Hit(EventId.BlockInput, true) -- 呼出sdk窗口前屏蔽操作
        self._nOrderIdPaying = mapData.Id
        SDKManager:Pay(sId, mapData.NotifyUrl, mapData.ExtraData)
    end
    self:SendMallPackageOrderReq(sId, callback)
end

function PlayerMallData:BuyMonthlyCard(sId,sStatistical)
    ---客户端埋点---
    local tab = {}
    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
    NovaAPI.UserEventUpload("purchase_click",tab)
    ---客户端埋点结束---
    local function callback(mapData)
        -- mapData.ExtraData    透传数据
        -- mapData.Id   返回订单号
        -- mapData.NotifyUrl    游戏服务器发货回调地址
        self._mapOrderId[mapData.ExtraData] = {nOrderId = mapData.Id, StatisticalGroup = sStatistical, nType = AllEnum.RMBOrderType.Mall}
        EventManager.Hit(EventId.BlockInput, true) -- 呼出sdk窗口前屏蔽操作
        self._nOrderIdPaying = mapData.Id
        SDKManager:Pay(sId, mapData.NotifyUrl, mapData.ExtraData)
    end
    self:SendMallMonthlyCardOrderReq(sId, callback)
end

function PlayerMallData:BuyBattlePass(nMode, nVersion, sId,sStatistical)
    ---客户端埋点---
    local tab = {}
    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
    NovaAPI.UserEventUpload("purchase_click",tab)
    ---客户端埋点结束---
    local function callback(mapData)
        -- mapData.ExtraData    透传数据
        -- mapData.Id   返回订单号
        -- mapData.NotifyUrl    游戏服务器发货回调地址
        self._mapOrderId[mapData.ExtraData] = {nOrderId = mapData.Id, StatisticalGroup = sStatistical, nType = AllEnum.RMBOrderType.BattlePass}
        EventManager.Hit(EventId.BlockInput, true) -- 呼出sdk窗口前屏蔽操作
        self._nOrderIdPaying = mapData.Id
        SDKManager:Pay(sId, mapData.NotifyUrl, mapData.ExtraData)
    end
    self:SendBattlePassOrderReq(nMode, nVersion, callback)
end

------------------------------- Test ------------------------------
-- 测试功能，跳过sdk
function PlayerMallData:TestBuyBattlePass(nMode, nVersion)
    local function callback(mapData)
        self:CollectEnqueue(mapData.Id, AllEnum.RMBOrderType.BattlePass)
        self:ProcessOrder()
    end
    self:SendBattlePassOrderReq(nMode, nVersion, callback)
end

function PlayerMallData:TestBuyGemSuc(sId)
    local function callback(mapData)
        self:CollectEnqueue(mapData.Id, AllEnum.RMBOrderType.Mall)
        self:ProcessOrder()
    end
    self:SendMallGemOrderReq(sId, callback)
end

function PlayerMallData:TestBuyPackageSuc(sId)
    local function callback(mapData)
        self:CollectEnqueue(mapData.Id, AllEnum.RMBOrderType.Mall)
        self:ProcessOrder()
    end
    self:SendMallPackageOrderReq(sId, callback)
end

function PlayerMallData:TestBuyMonthlyCardSuc(sId)
    local function callback(mapData)
        self:CollectEnqueue(mapData.Id, AllEnum.RMBOrderType.Mall)
        self:ProcessOrder()
    end
    self:SendMallMonthlyCardOrderReq(sId, callback)
end

-------------------------- Exchange Shop --------------------------
function PlayerMallData:ProcessExchangeShop()
    self._tbExchangeShop = {}
    local function func_ForEach_ExchangeShop(mapData)
        table.insert(self._tbExchangeShop, mapData)
    end
    ForEachTableLine(DataTable.MallShopPage, func_ForEach_ExchangeShop)

    table.sort(self._tbExchangeShop, function(a, b)
        return a.Sort < b.Sort
    end)
end

function PlayerMallData:ParseShopList(tbList)
    local tbShop = {}
    for _, v in pairs(tbList) do
        local mapCfg = ConfigTable.GetData("MallShop", v.Id)
        if mapCfg then
            local mapPage = ConfigTable.GetData("MallShopPage", mapCfg.GroupId)
            if mapPage then
                if v.Stock > 0 or mapCfg.DisplayMode ~= DisplayMode.Hide then
                    local nDeListTime = PlayerData.Shop:ChangeToTimeStamp(mapCfg.DeListTime)
                    local nNextRefreshTime, bPrioritizeDeList = self:CalNextTime(v.RefreshTime, nDeListTime)
                    local mapPackage = {
                        sId = v.Id,
                        nCurStock = v.Stock,

                        nPageSort = mapPage.Sort,
                        nSort = mapCfg.Sort,
                        nDisplayMode = mapCfg.DisplayMode,

                        bPrioritizeDeList = bPrioritizeDeList,
                        nNextRefreshTime = nNextRefreshTime
                    }
                    table.insert(tbShop, mapPackage)
                end
            end
        end
    end

    local function comp(a, b)
        if (a.nCurStock == 0 and a.nDisplayMode == DisplayMode.End) ~= (b.nCurStock == 0 and b.nDisplayMode == DisplayMode.End) then
            return not (a.nCurStock == 0 and a.nDisplayMode == DisplayMode.End) and
            (b.nCurStock == 0 and b.nDisplayMode == DisplayMode.End)
        elseif a.nPageSort ~= b.nPageSort then
            return a.nPageSort < b.nPageSort
        else
            return a.nSort < b.nSort
        end
    end
    table.sort(tbShop, comp)

    return tbShop
end

-- 获取下一次更新时间
function PlayerMallData:CalShopAutoTime(tbList)
    local tbTime = {}
    for _, mapData in pairs(tbList) do
        if mapData.nNextRefreshTime > 0 then
            table.insert(tbTime, mapData.nNextRefreshTime)
        end
    end
    for _, mapData in pairs(self._tbNextMallShop or {}) do
        table.insert(tbTime, mapData.nListTime)
    end
    if #tbTime == 0 then
        return 0
    end
    table.sort(tbTime)
    return tbTime[1] - ClientManager.serverTimeStamp
end

-- 统计未来会被开放的兑换物
function PlayerMallData:UpdateNextMallShop()
    local nServerTimeStamp = ClientManager.serverTimeStamp
    if self._tbNextMallShop == nil then
        self._tbNextMallShop = {}
        local function func_ForEach_Shop(mapCfgData)
            local nListTime = PlayerData.Shop:ChangeToTimeStamp(mapCfgData.ListTime)
            if nListTime > 0 and nListTime > nServerTimeStamp then
                table.insert(self._tbNextMallShop, {
                    nId = mapCfgData.Id,
                    nListTime = nListTime,
                })
            end
        end
        ForEachTableLine(DataTable.MallShop, func_ForEach_Shop)
    else
        local nCount = #self._tbNextMallShop
        if nCount > 0 then
            for i = nCount, -1, 1 do
                if self._tbNextMallShop[i].nListTime <= nServerTimeStamp then
                    table.remove(self._tbNextMallShop, i)
                end
            end
        end
    end
end

----------------------------- Package -----------------------------
function PlayerMallData:ProcessPackagePage()
    self._tbPackagePage = {}
    local function func_ForEach_PackagePage(mapData)
        local nType = mapData.Type
        if self._tbPackagePage[nType] == nil then
            self._tbPackagePage[nType] = {}
        end
        table.insert(self._tbPackagePage[nType], mapData)
    end
    ForEachTableLine(DataTable.MallPackagePage, func_ForEach_PackagePage)
    for _, v in pairs(self._tbPackagePage) do
        table.sort(v, function(a, b)
            return a.Sort < b.Sort
        end)
    end
end

function PlayerMallData:ParsePackageList(tbList)
    local tbPackage = {}
    for _, v in pairs(tbList) do
        local mapCfg = ConfigTable.GetData("MallPackage", v.Id)
        if mapCfg then
            local mapPage = ConfigTable.GetData("MallPackagePage", mapCfg.GroupId)
            if mapPage then
                if v.Stock > 0 or mapCfg.DisplayMode ~= DisplayMode.Hide then
                    local nDeListTime = PlayerData.Shop:ChangeToTimeStamp(mapCfg.DeListTime)
                    local nNextRefreshTime, bPrioritizeDeList = self:CalNextTime(v.RefreshTime, nDeListTime)
                    local mapPackage = {
                        sId = v.Id,
                        nCurStock = v.Stock,

                        nPageSort = mapPage.Sort,
                        nSort = mapCfg.Sort,
                        nDisplayMode = mapCfg.DisplayMode,

                        bPrioritizeDeList = bPrioritizeDeList,
                        nNextRefreshTime = nNextRefreshTime
                    }
                    table.insert(tbPackage, mapPackage)
                end
            end
        end
    end

    local function comp(a, b)
        if (a.nCurStock == 0 and a.nDisplayMode == DisplayMode.End) ~= (b.nCurStock == 0 and b.nDisplayMode == DisplayMode.End) then
            return not (a.nCurStock == 0 and a.nDisplayMode == DisplayMode.End) and
            (b.nCurStock == 0 and b.nDisplayMode == DisplayMode.End)
        elseif a.nPageSort ~= b.nPageSort then
            return a.nPageSort < b.nPageSort
        else
            return a.nSort < b.nSort
        end
    end
    table.sort(tbPackage, comp)

    return tbPackage
end

function PlayerMallData:CalNextTime(nReTime, nDeTime)
    if nDeTime > 0 then
        if nReTime > 0 then
            if nReTime > nDeTime then
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

-- 获取下一次更新时间
function PlayerMallData:CalPackageAutoTime(tbPackageList)
    local tbTime = {}
    for _, mapData in pairs(tbPackageList) do
        if mapData.nNextRefreshTime > 0 then
            table.insert(tbTime, mapData.nNextRefreshTime)
        end
    end
    for _, mapData in pairs(self._tbNextMallPackage) do
        table.insert(tbTime, mapData.nListTime)
    end
    if #tbTime == 0 then
        return 0
    end
    table.sort(tbTime)
    return tbTime[1] - ClientManager.serverTimeStamp
end

-- 统计未来会被开放的礼包
function PlayerMallData:UpdateNextMallPackage()
    local nServerTimeStamp = ClientManager.serverTimeStamp
    if self._tbNextMallPackage == nil then
        self._tbNextMallPackage = {}
        local function func_ForEach_Package(mapCfgData)
            local nListTime = PlayerData.Shop:ChangeToTimeStamp(mapCfgData.ListTime)
            if nListTime > 0 and nListTime > nServerTimeStamp then
                table.insert(self._tbNextMallPackage, {
                    nId = mapCfgData.Id,
                    nListTime = nListTime,
                })
            end
        end
        ForEachTableLine(DataTable.MallPackage, func_ForEach_Package)
    else
        local nCount = #self._tbNextMallPackage
        if nCount > 0 then
            for i = nCount, -1, 1 do
                if self._tbNextMallPackage[i].nListTime <= nServerTimeStamp then
                    table.remove(self._tbNextMallPackage, i)
                end
            end
        end
    end
end

------------------------------ Event ------------------------------
function PlayerMallData:OnEvent_SdkPaySuc(nCode, sMsg, nOrderId, sExData)
    local mapOrder = self._mapOrderId[sExData]
    if mapOrder == nil then
        printError("OrderId not found:" .. sExData)
        return
    end
    local nCacheOrderId = self._mapOrderId[sExData].nOrderId
    local nOrderType = self._mapOrderId[sExData].nType
    ---客户端埋点---
    local sStatistical = self._mapOrderId[sExData].StatisticalGroup
    local tab = {}
    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})

    if sStatistical ~= nil then
        if sStatistical == "pack.first" then --购买6元破冰礼包
            NovaAPI.UserEventUpload("purchase_starterpack",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_pack_first_160")
            ---日服PC埋点---
        elseif sStatistical == "pack.sr" then --购买SR角色自选礼包
            NovaAPI.UserEventUpload("purchase_srtrekkerselect",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_pack_sr_680")
            ---日服PC埋点---
        elseif sStatistical == "pack.role" then -- 购买新手启程角色礼包
            NovaAPI.UserEventUpload("purchase_newtrekkerpack",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_pack_role_1480")
            ---日服PC埋点---
        elseif sStatistical == "pack.disc" then --购买新手启程星盘礼包
            NovaAPI.UserEventUpload("purchase_newdiscpack",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_pack_disc_1480")
            ---日服PC埋点---
        elseif sStatistical == "pack.role_common" then--购买新手角色普池礼包
            NovaAPI.UserEventUpload("purchase_newtrekkerstandard",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_pack_role_common_1280")
            ---日服PC埋点---
        elseif sStatistical == "monthlyCard.small" then --购买月卡
            NovaAPI.UserEventUpload("purchase_monthlycard",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_monthlyCard_small_650")
            ---日服PC埋点---
        elseif sStatistical == "pack_role_m" then --购买月间角色券礼包 --pack.01_role_m
            NovaAPI.UserEventUpload("purchase_monthtrekkervoucher",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_pack_01_role_m_2600")
            ---日服PC埋点---
        elseif sStatistical == "pack_disc_m" then --购买月间星盘券礼包 --pack.01_disc_m
            NovaAPI.UserEventUpload("purchase_monthdiscvoucher",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_pack_01_disc_m_2600")
            ---日服PC埋点---
        elseif sStatistical == "pack_role_w" then --购买养成资源周礼包*角色 --01_role_w
            NovaAPI.UserEventUpload("purchase_weektrekkerres",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_pack_01_role_w_860")
            ---日服PC埋点---
        elseif sStatistical == "pack_disc_w" then --购买养成资源周礼包*星盘 --01_disc_w
            NovaAPI.UserEventUpload("purchase_weekdiscres",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_pack_01_disc_w_860")
            ---日服PC埋点---
        elseif sStatistical == "pack_role" then --购买角色庆典礼包 --02_role
            NovaAPI.UserEventUpload("purchase_trekkercelebration",tab)
        elseif sStatistical == "pack_gift" then --购买角色甜点礼包 --01_gift
            NovaAPI.UserEventUpload("purchase_trekkerdessert",tab)
        elseif sStatistical == "pack_disc" then --购买星盘畅听礼包--02_disc
            NovaAPI.UserEventUpload("purchase_discmusic",tab)
        elseif sStatistical == "pack_res" then --购买角色养成礼包 --01_res
            NovaAPI.UserEventUpload("purchase_trekkerupgrade",tab)
        elseif sStatistical == "pack.op_role" then --购买开服角色招募礼包
            NovaAPI.UserEventUpload("purchase_launchtrekker",tab)
        elseif sStatistical == "pack.op_disc" then --购买开服星盘招募礼包
            NovaAPI.UserEventUpload("purchase_launchdisc",tab)
        elseif string.find(sStatistical, "gem") ~= nil then --购买任一档位钻石
            NovaAPI.UserEventUpload("purchase_diamond",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_" .. sStatistical)
            ---日服PC埋点---
        elseif sStatistical == "BattlePassPremium" then --购买普通版BP
            NovaAPI.UserEventUpload("purchase_standardbp",tab)
            ---日服PC埋点---
            PlayerData.Base:UserEventUpload_PC("pc_purchase_battlepass_68_1280")
            ---日服PC埋点---
        elseif sStatistical == "BattlePassOrigin_Luxury" or sStatistical == "BattlePassOrigin_Complement" then --购买豪华版BP
            NovaAPI.UserEventUpload("purchase_deluxebp",tab)
            ---日服PC埋点---
            local tmpEvent = sStatistical == "BattlePassOrigin_Luxury" and "pc_purchase_battlepass_98_1980" or "pc_purchase_battlepass_38_980"
            PlayerData.Base:UserEventUpload_PC(tmpEvent)
            ---日服PC埋点---
        elseif sStatistical == "skin_3d" then --购买任一皮肤
            NovaAPI.UserEventUpload("purchase_skin",tab)
        end
    end
    ---客户端埋点结束---
    self._mapOrderId[sExData] = nil
    self:CollectEnqueue(nCacheOrderId, nOrderType)
    self:ProcessOrder()
end


function PlayerMallData:OnEvent_SdkPayFail(nCode, sMsg, nOrderId, sExData, nOrderIdPaying)
    printError("SdkPayFail Msg:" .. sMsg )
    printError("SdkPayFail nCode:" .. nCode )
    local mapOrder = self._mapOrderId[sExData]
    if mapOrder == nil then
        printError("OrderId not found:" .. sExData)
        if sExData == "" and nOrderIdPaying and nOrderIdPaying ~= "" and nOrderIdPaying ~= 0 then -- 保底取消订单
            for k, v in pairs(self._mapOrderId) do
                if v.nOrderId == nOrderIdPaying then
                    self._mapOrderId[k] = nil
                    break
                end
            end
            self:SendMallOrderCancelReq(nOrderIdPaying, nCode)
        end
        return
    end
    local nCacheOrderId = self._mapOrderId[sExData].nOrderId
    self._mapOrderId[sExData] = nil
    self:SendMallOrderCancelReq(nCacheOrderId, nCode)
end

function PlayerMallData:OnEvent_PayRespone(nCode, sMsg, nOrderId, sExData)
    EventManager.Hit(EventId.BlockInput, false) -- sdk处理结束，打开操作
    printLog("收到SDK PayRespone")
    -- 201180 订单已支付成功，等待系统发货（国服）
    -- 200180 订单已支付成功，等待系统发货（外服）
    local nOrderIdPaying = self._nOrderIdPaying
    self._nOrderIdPaying = nil
    if nCode == 200180 or nCode == 0 or nCode == 201180 then
        self:OnEvent_SdkPaySuc(nCode, sMsg, nOrderId, sExData)
    else
        self:OnEvent_SdkPayFail(nCode, sMsg, nOrderId, sExData, nOrderIdPaying)
    end
end

------------------------------ Order -----------------------------
function PlayerMallData:OpenOrderWait()
    if MessageBoxManager.CheckOrderWaitOpen() then
        return
    end

    EventManager.Hit("OpenOrderWait")
    self._timerOrderWait = TimerManager.Add(1, 30, self, function()
        self._bWaitTimeOut = true
        EventManager.Hit(EventId.OpenMessageBox,
            { nType = AllEnum.MessageBox.Alert, sContent = ConfigTable.GetUIText("Mall_OrderRetry"), bDisableSnap = true })
        self:CloseOrderWait()
    end, true, true, false)
end

function PlayerMallData:CloseOrderWait()
    if self._timerOrderWait ~= nil then
        self._timerOrderWait:Cancel(false)
        self._timerOrderWait = nil
    end

    if MessageBoxManager.CheckOrderWaitOpen() then
        EventManager.Hit("CloseOrderWait")
    end
end

function PlayerMallData:ProcessOrder(bRetry)
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
        tbReward = {},
        tbSpReward = {},
        tbSrc = {},
        tbDst = {}
    }
    self:CollectDequeue()
end

function PlayerMallData:SetReCollectTimer()
    if self._timerOrderCollect ~= nil then
        self._timerOrderCollect:Cancel(false)
        self._timerOrderCollect = nil
    end
    if #self._tbOrderCollect > 0 then
        self._timerOrderCollect = TimerManager.Add(1, 2, self, function()
            self:ProcessOrder(true)
        end, true, true, false)
    end
end

function PlayerMallData:CollectDequeue()
    local mapOrder = self._tbOrderCollect[1]
    table.remove(self._tbOrderCollect, 1)

    printLog("当前处理订单：" .. mapOrder.nOrderId)
    if next(self._tbOrderCollect) ~= nil then
        printLog("----预备订单----")
        for _, v in ipairs(self._tbOrderCollect) do
            printLog("订单：" .. v.nOrderId .. "    等待处理")
        end
        printLog("---------------")
    else
        printLog("后续无待处理订单")
    end

    self._mapOrderCollecting = mapOrder

    if mapOrder.nType == AllEnum.RMBOrderType.Mall then
        local function callback(mapData) -- fail和suc都走这个回调
            self._mapOrderCollecting = nil
            local tbSpReward = PlayerData.CharSkin:GetSkinForReward()
            self:CollectOrder(mapOrder, mapData, tbSpReward)
        end
        self:SendMallOrderCollectReq(mapOrder.nOrderId, callback)
    elseif mapOrder.nType == AllEnum.RMBOrderType.BattlePass then
        local function callback(mapData) -- fail和suc都走这个回调
            self._mapOrderCollecting = nil
            local tbSpReward = PlayerData.CharSkin:GetSkinForReward()

            if mapData.CollectResp then -- 成功
                PlayerData.BattlePass:OnPremiumBuySuccess(mapData)
                self:CollectOrder(mapOrder, mapData.CollectResp, tbSpReward)
            else -- 失败
                self:CollectOrder(mapOrder, mapData, tbSpReward)
            end
        end
        self:SendBattlePassOrderCollectReq(mapOrder.nOrderId, callback)
    end
end

function PlayerMallData:CollectOrder(mapOrder, mapData, tbSpReward)
    printLog("订单：" .. mapOrder.nOrderId .. "    奖励状态：" .. mapData.Status)

    if mapData.Items and next(mapData.Items) ~= nil then
        local mapReward = PlayerData.Item:ProcessRewardChangeInfo(mapData.Items)
        for _, v in pairs(mapReward.tbReward) do
            table.insert(self._mapOrderReward.tbReward, v)
        end
        for _, v in pairs(mapReward.tbSpReward) do
            table.insert(self._mapOrderReward.tbSpReward, v)
        end
        for _, v in pairs(mapReward.tbSrc) do
            table.insert(self._mapOrderReward.tbSrc, v)
        end
        for _, v in pairs(mapReward.tbDst) do
            table.insert(self._mapOrderReward.tbDst, v)
        end
    end
    if tbSpReward and next(tbSpReward) ~= nil then
        for _, v in pairs(tbSpReward) do
            table.insert(self._mapOrderReward.tbSpReward, v)
        end
    end

    if mapData.Status == OrderStatus.Unpaid or mapData.Status == OrderStatus.Retry then
        local bHasWait = false
        for _, v in pairs(self._tbWaitingOrderCollect) do
            if v.nOrderId == mapOrder.nOrderId then
                bHasWait = true
                printError("订单：" .. mapOrder.nOrderId .. "    重复进入等待列表")
                break
            end
        end
        if not bHasWait then
            table.insert(self._tbWaitingOrderCollect, mapOrder)
        end
    end

    ---客户端埋点---
    if mapData.Status == OrderStatus.Done then
        local tab_1 = {}
        table.insert(tab_1,{"role_id",tostring(PlayerData.Base._nPlayerId)})
        NovaAPI.UserEventUpload("confirm_order",tab_1)

        local tab = {}
        table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
        NovaAPI.UserEventUpload("purchase_complete",tab)
    end
    ---客户端埋点结束---

    -- if mapData.Status == OrderStatus.Error then
    --     EventManager.Hit(EventId.OpenMessageBox,
    --         { nType = AllEnum.MessageBox.Alert, sContent = GetUITextData("Mall_OrderRetry") })
    -- end

    if not self._tbOrderCollect or #self._tbOrderCollect == 0 then
        self:CollectEnd(mapData.Status ~= OrderStatus.Done)
    else
        self:CollectDequeue()
    end
end

function PlayerMallData:CollectEnd(bError)
    local function funcClear()
        self._bProcessingOrder = false

        self._tbOrderCollect = {}
        if self._bWaitTimeOut then -- 超时后不再重新统计重请求订单，理论上这里的订单不是unpaid的，未支付的订单在sdk支付失败的返回中取消了
            self._bWaitTimeOut = false
            for _, mapOrder in pairs(self._tbWaitingOrderCollect) do
                printError("订单：" .. mapOrder.nOrderId .. "    超时订单，需要联系客服，不再请求")
            end
        else -- 没超时订单重进订单列表
            printLog("----需重新请求的订单----")
            for _, mapOrder in pairs(self._tbWaitingOrderCollect) do
                table.insert(self._tbOrderCollect, mapOrder)
                printLog("订单：" .. mapOrder.nOrderId .. "    未成功，重新进入订单列表")
            end
            printLog("---------------")
        end
        self._tbWaitingOrderCollect = {}

        if next(self._tbOrderCollect) == nil then
            local bMoney = true -- 是否氪金订单
            EventManager.Hit("MallOrderClear", bMoney)
        end
        self:SetReCollectTimer()
    end

    if not bError then
        self:CloseOrderWait()
    end

    if PanelManager.CheckPanelOpen(PanelId.ReceiveAutoTrans) == true or
        PanelManager.CheckPanelOpen(PanelId.ReceivePropsTips) == true or
        PanelManager.CheckPanelOpen(PanelId.ReceiveSpecialReward) == true or
        PanelManager.CheckNextPanelOpening()
    then
        funcClear() -- 冲突展示时，跳过展示 TODO:或者换种展示效果
    else
        local sTip = nil
        if self._bRetry and self._bWaitTimeOut then
            sTip = ConfigTable.GetUIText("Mall_OrderDelayed")
        end
        UTILS.OpenReceiveByReward(self._mapOrderReward, funcClear, sTip)
    end
end

function PlayerMallData:CollectEnqueue(nOrderId, nType)
    if not self._tbOrderCollect then
        self._tbOrderCollect = {}
    end

    table.insert(self._tbOrderCollect, { nOrderId = nOrderId, nType = nType })
end

----------------------------- Network -----------------------------
function PlayerMallData:SendBattlePassOrderReq(nMode, nVersion, callback)
    local mapMsg = {
        Mode = nMode,
        Version = nVersion
    }
    local function successCallback(_, mapData)
        printLog("创建订单：" .. mapData.Id)
        callback(mapData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.battle_pass_order_req, mapMsg, nil, successCallback)
end

-- 获取钻石商城产品列表
function PlayerMallData:SendMallGemListReq(callback)
    local function successCallback(_, mapData)
        callback(mapData.List)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.mall_gem_list_req, {}, nil, successCallback)
end

-- 下单购买商品
function PlayerMallData:SendMallGemOrderReq(sId, callback)
    if type(sId) == "number" then
        sId = tostring(sId)
    end
    local mapMsg = {
        Value = sId
    }
    local function successCallback(_, mapData)
        printLog("创建订单：" .. mapData.Id)
        callback(mapData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.mall_gem_order_req, mapMsg, nil, successCallback)
end

-- 取消某个尚未支付的订单
function PlayerMallData:SendMallOrderCancelReq(nId, nCode, callback)
    local tbCancelCode = {200154, 200230, 200340, 200500, 200600, 201236, 101606, 101731, 201230, 201221, 201223, 201224}
    if table.indexof(tbCancelCode, nCode) == 0 then
        local bMoney = true -- 是否氪金订单
        EventManager.Hit("MallOrderClear", bMoney)
        return -- 取消订单对应错误码不符合设计预期，直接不向服务器发送取消订单
    end
    -- if type(nId) == "number" then
    --     nId = tostring(nId)
    -- end
    -- local mapMsg = {
    --     Value = nId
    -- }
    -- local function successCallback(_, mapData)
        printLog("订单取消")
        EventManager.Hit(EventId.OpenMessageBox, { nType = AllEnum.MessageBox.Alert, sContent = ConfigTable.GetUIText("Mall_OrderCancel") })
        local bMoney = true -- 是否氪金订单
        EventManager.Hit("MallOrderClear", bMoney)
    -- end
    -- HttpNetHandler.SendMsg(NetMsgId.Id.mall_order_cancel_req, mapMsg, nil, successCallback)
end

-- 领取某个支付成功的订单的奖励
function PlayerMallData:SendMallOrderCollectReq(nId, callback)
    if type(nId) == "number" then
        nId = tostring(nId)
    end
    local mapMsg = {
        Value = nId
    }
    local function successCallback(_, mapData)
        callback(mapData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.mall_order_collect_req, mapMsg, nil, successCallback)
end

-- 领取战令支付成功的订单的奖励
function PlayerMallData:SendBattlePassOrderCollectReq(nId, callback)
    if type(nId) == "number" then
        nId = tostring(nId)
    end
    local mapMsg = {
        Value = nId
    }
    local function successCallback(_, mapData)
        callback(mapData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.battle_pass_order_collect_req, mapMsg, nil, successCallback)
end

-- 获取月卡商城产品列表
function PlayerMallData:SendMallMonthlyCardListReq(callback)
    local function successCallback(_, mapData)
        callback(mapData.List[1]) -- 目前只有一个月卡
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.mall_monthlyCard_list_req, {}, nil, successCallback)
end

-- 购买月卡商城商品
function PlayerMallData:SendMallMonthlyCardOrderReq(sId, callback)
    local mapMsg = {
        Value = sId
    }
    local function successCallback(_, mapData)
        printLog("创建订单：" .. mapData.Id)
        callback(mapData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.mall_monthlyCard_order_req, mapMsg, nil, successCallback)
end

-- 获取礼包商城产品已购买过的商品列表
function PlayerMallData:SendMallPackageListReq(callback)
    local function successCallback(_, mapData)
        self:UpdateNextMallPackage()
        local tbPackageList = self:ParsePackageList(mapData.List)
        local nAutoTime = self:CalPackageAutoTime(tbPackageList)
        callback(tbPackageList, nAutoTime)
        --刷新红点
        self:UpdateMallRedDot(tbPackageList)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.mall_package_list_req, {}, nil, successCallback)
end

-- 购买礼包商城产品
function PlayerMallData:SendMallPackageOrderReq(sId, callback)
    local mapMsg = {
        Value = sId
    }
    local function successCallback(_, mapData)
        --EventManager.Hit("MallCloseDetail")
        if mapData.Order then
            printLog("创建订单：" .. mapData.Order.Id)
            callback(mapData.Order)
        else
            UTILS.OpenReceiveByChangeInfo(mapData.Change)
            local bMoney = false -- 是否氪金订单
            EventManager.Hit("MallOrderClear", bMoney)
            WwiseAudioMgr:SetState("system", "shop_purchased")
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.mall_package_order_req, mapMsg, nil, successCallback)
end

-- 获取兑换品商城产品已购买过的商品列表
function PlayerMallData:SendMallShopListReq(callback)
    local function successCallback(_, mapData)
        self:UpdateNextMallShop()
        local tbList = self:ParseShopList(mapData.List)
        local nAutoTime = self:CalShopAutoTime(tbList)
        callback(tbList, nAutoTime)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.mall_shop_list_req, {}, nil, successCallback)
end

-- 购买兑换品商城产品
function PlayerMallData:SendMallShopOrderReq(sId, nCount)
    local mapMsg = {
        Id = sId,
        Qty = nCount,
    }
    local function successCallback(_, mapData)
        UTILS.OpenReceiveByChangeInfo(mapData)
        local bMoney = false -- 是否氪金订单
        EventManager.Hit("MallOrderClear", bMoney)
        WwiseAudioMgr:SetState("system", "shop_purchased")
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.mall_shop_order_req, mapMsg, nil, successCallback)
end

-- 兑换角色碎片
function PlayerMallData:SendCharFragmentConvertReq(callBack)
    local mapMsg = {}
    HttpNetHandler.SendMsg(NetMsgId.Id.fragments_convert_req, mapMsg, nil, callBack)
end

function PlayerMallData:ProcessOrderPaidNotify(mapData)
    if self._mapOrderCollecting and self._mapOrderCollecting.nOrderId == mapData.OrderId then
        return -- 有当前处理的相同订单时，不再重复请求
    end

    -- StoreGem         = 0 // 钻石商城
    -- StorePackage     = 1 // 礼包商城
    -- StoreMonthlyCard = 2 // 月卡商城
    -- StoreBattlePass  = 3 // 战令进阶商城
    local nType = AllEnum.RMBOrderType.Mall
    if mapData.Store == 3 then
        nType = AllEnum.RMBOrderType.BattlePass
    end
    self:CollectEnqueue(mapData.OrderId, nType)
    self:ProcessOrder()
end

----------------------------- 红点相关 -----------------------------
function PlayerMallData:UpdateMallRedDot(tbPackageList)
    local bCheck = false
    for _, mallData in ipairs(tbPackageList) do
        local mapCfg = ConfigTable.GetData("MallPackage", mallData.sId)
        if nil ~= mapCfg then
            if mapCfg.CurrencyType == GameEnum.currencyType.Free then
                local tbCond = decodeJson(mapCfg.OrderCondParams)
                local bPurchaseAble = PlayerData.Shop:CheckShopCond(mapCfg.OrderCondType, tbCond)
                if mallData.nCurStock > 0 and bPurchaseAble then
                    bCheck = true
                    RedDotManager.SetValid(RedDotDefine.FreePackage, { mallData.sId }, true)
                else
                    RedDotManager.SetValid(RedDotDefine.FreePackage, { mallData.sId }, false)
                end
            end
        end
    end
    RedDotManager.SetValid(RedDotDefine.Mall_Free, nil, bCheck)
end

-------------------------------------------------------------------

return PlayerMallData
