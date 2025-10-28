------------------------------ local ------------------------------
local ActivityDataBase = require "GameCore.Data.DataClass.Activity.ActivityDataBase"
local ActivityShopData = class("ActivityShopData", ActivityDataBase)
local ClientManager = CS.ClientManager.Instance

local DisplayMode = {
    Hide = 0,
    End = 1,
    Stay = 2
}
-------------------------------------------------------------------

------------------------------ public -----------------------------
function ActivityShopData:Init()
    self.tbShops = {}
    self.tbGoods = {}
    self.tbServerData = {}
    self.bFirstInShop = true

    self:ParseConfig()
end

function ActivityShopData:ParseConfig()
    local mapCfg = ConfigTable.GetData("ActivityShopControl", self.nActId)
    if not mapCfg then
        return
    end

    self.mapShopControlCfg = mapCfg
end

function ActivityShopData:RefreshActivityShopData(mapData)
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

-- 检查商品数据
function ActivityShopData:CheckGoodsData(nShopId)
    local tbGoods = self:GetNeedToRefreshGoods(nShopId)
    if #tbGoods == 0 then
        return
    end
    for _, mapGoods in pairs(tbGoods) do
        self:UpdateGoodsData(nShopId, mapGoods.nId)
    end
end

-- 获取有效商店列表
function ActivityShopData:GetShopList()
    local tbList = {}
    for _, mapShop in pairs(self.tbShops) do
        if mapShop.bUnlock and mapShop.bOpenAble then
            table.insert(tbList, mapShop)
        end
    end
    table.sort(tbList, function(a, b)
        return a.nSequence < b.nSequence
    end)
    return tbList
end

-- 获取有效商品列表
function ActivityShopData:GetGoodsList(nShopId)
    local tbList = {}
    for _, mapGoods in pairs(self.tbGoods[nShopId]) do
        if mapGoods.bUnlock and (not mapGoods.bSoldOut or mapGoods.nDisplayMode ~= DisplayMode.Hide) then
            table.insert(tbList, mapGoods)
        end
    end
    local function comp(a, b)
        if (a.bSoldOut and a.nDisplayMode == DisplayMode.End) ~= (b.bSoldOut and b.nDisplayMode == DisplayMode.End) then
            return not (a.bSoldOut and a.nDisplayMode == DisplayMode.End) and
                (b.bSoldOut and b.nDisplayMode == DisplayMode.End)
        else
            return a.nSaleNumber < b.nSaleNumber
        end
    end
    table.sort(tbList, comp)
    return tbList
end

-- 获取所有商店中最早的下一次更新时间
function ActivityShopData:GetShopAutoUpdateTime()
    local tbTime = {}
    for _, mapShop in pairs(self.tbShops) do
        if mapShop.nNextRefreshTime > 0 then
            table.insert(tbTime, mapShop.nNextRefreshTime)
        end
    end
    if #tbTime == 0 then
        return 0
    end
    table.sort(tbTime)
    return tbTime[1] - ClientManager.serverTimeStamp
end

-- 获取当前商店货物中最早的下一次更新时间
function ActivityShopData:GetGoodsAutoUpdateTime(nShopId)
    local tbTime = {}
    for _, mapGoods in pairs(self.tbGoods[nShopId]) do
        if mapGoods.nNextRefreshTime > 0 then
            table.insert(tbTime, mapGoods.nNextRefreshTime)
        end
    end
    if #tbTime == 0 then
        return 0
    end
    table.sort(tbTime)
    return tbTime[1] - ClientManager.serverTimeStamp
end

function ActivityShopData:GetShopFirstIn()
    local bFirst = self.bFirstInShop
    if self.bFirstInShop == true then
        self.bFirstInShop = false
    end
    return bFirst
end

--------------------------- Create Data ---------------------------
-- 创建本地数据
function ActivityShopData:CreateData()
    if not self.mapShopControlCfg then
        return
    end

    local nServerTimeStamp = ClientManager.serverTimeStamp
    local nCloseTime = self.nEndTime
    local bExpired = nCloseTime ~= 0 and nServerTimeStamp >= nCloseTime
    if bExpired then
        return -- 过期了就没必要创建了
    end

    for _, nShopId in ipairs(self.mapShopControlCfg.ShopIds) do
        local mapCfg = ConfigTable.GetData("ActivityShop", nShopId)
        if mapCfg then
            self:CreateShopData(mapCfg)
        end
    end

    local function func_ForEach_Goods(mapCfgData)
        if self.tbShops[mapCfgData.ShopId] then
            self:CreateGoodsData(mapCfgData)
        end
    end
    ForEachTableLine(DataTable.ActivityGoods, func_ForEach_Goods)
end

function ActivityShopData:CreateShopData(mapCfgData)
    local mapShop = {
        nId = mapCfgData.Id,
        nSequence = mapCfgData.Sequence,
        nRefreshTimeType = mapCfgData.RefreshTimeType,
        nRefreshInterval = mapCfgData.RefreshInterval,
        nUnlockCondType = mapCfgData.UnlockCondType,
        tbUnlockCondParams = decodeJson(mapCfgData.UnlockCondParams),

        bUnlock = false,
        bOpenAble = false,
        nServerRefreshTime = 0,
        nNextRefreshTime = 0,
    }
    self.tbShops[mapCfgData.Id] = mapShop

    self:UpdateShopData(mapCfgData.Id)
end

function ActivityShopData:CreateGoodsData(mapCfgData)
    local mapGoods = {
        nId = mapCfgData.Id,
        nSaleNumber = mapCfgData.SaleNumber,
        nMaximumLimit = mapCfgData.MaximumLimit,
        nAppearCondType = mapCfgData.AppearCondType,
        tbAppearCondParams = decodeJson(mapCfgData.AppearCondParams),
        nPurchaseCondType = mapCfgData.PurchaseCondType,
        tbPurchaseCondParams = decodeJson(mapCfgData.PurchaseCondParams),
        nUnlockPurchaseTime = self:ChangeToTimeStamp(mapCfgData.UnlockPurchaseTime),
        nDisplayMode = mapCfgData.DisplayMode,

        bUnlock = false,
        bPurchasable = false,
        bPurchasTime = false,
        bSoldOut = false,

        nBoughtCount = 0,
        nNextRefreshTime = 0,
    }
    if not self.tbGoods[mapCfgData.ShopId] then
        self.tbGoods[mapCfgData.ShopId] = {}
    end
    self.tbGoods[mapCfgData.ShopId][mapCfgData.Id] = mapGoods

    self:UpdateGoodsData(mapCfgData.ShopId, mapCfgData.Id)
end

function ActivityShopData:ChangeToTimeStamp(sTime)
    return sTime == "" and 0 or ClientManager:ISO8601StrToTimeStamp(sTime)
end

--------------------------- Update Data ---------------------------
-- 更新本地数据
function ActivityShopData:UpdateData(tbShopIds)
    local nServerTimeStamp = ClientManager.serverTimeStamp
    local nCloseTime = self.nEndTime
    local bExpired = nCloseTime ~= 0 and nServerTimeStamp >= nCloseTime
    if bExpired then -- 所有商店共用一个过期和开启时间
        self.tbShops = {}
        self.tbGoods = {}
        return
    end

    for _, nShopId in pairs(tbShopIds) do
        self:UpdateShopData(nShopId)
        for nGoodsId, _ in pairs(self.tbGoods[nShopId]) do
            self:UpdateGoodsData(nShopId, nGoodsId)
        end
    end
end

function ActivityShopData:UpdateShopData(nId)
    self.tbShops[nId].bUnlock = self:CheckShopCond(self.tbShops[nId].nUnlockCondType, self.tbShops[nId].tbUnlockCondParams)
    self.tbShops[nId].bOpenAble = ClientManager.serverTimeStamp >= self.nOpenTime
    self.tbShops[nId].nServerRefreshTime = self.tbServerData[nId] and self.tbServerData[nId].RefreshTime or 0
    self.tbShops[nId].nNextRefreshTime = self:UpdateNextShopRefreshTime(nId, self.tbShops[nId].nServerRefreshTime)
end

function ActivityShopData:UpdateGoodsData(nShopId, nGoodsId)
    local mapGoods = self.tbGoods[nShopId][nGoodsId]
    local nBoughtCount = self:GetBoughtCount(nGoodsId)
    self.tbGoods[nShopId][nGoodsId].bUnlock = self:CheckShopCond(mapGoods.nAppearCondType, mapGoods.tbAppearCondParams)
    self.tbGoods[nShopId][nGoodsId].bPurchasable = self:CheckShopCond(mapGoods.nPurchaseCondType, mapGoods.tbPurchaseCondParams)
    self.tbGoods[nShopId][nGoodsId].bPurchasTime = ClientManager.serverTimeStamp >= mapGoods.nUnlockPurchaseTime
    self.tbGoods[nShopId][nGoodsId].bSoldOut = nBoughtCount ~= 0 and nBoughtCount == mapGoods.nMaximumLimit
    self.tbGoods[nShopId][nGoodsId].nBoughtCount = nBoughtCount
    self.tbGoods[nShopId][nGoodsId].nNextRefreshTime = self:UpdateNextGoodsRefreshTime(nShopId, nGoodsId)
end

-- 更新当前商店最早的下一次刷新时间
function ActivityShopData:UpdateNextShopRefreshTime(nId, nServerRefreshTime)
    local mapShop = self.tbShops[nId]
    local nOpenTime = self.nOpenTime
    if nOpenTime > 0 then
        if nOpenTime - ClientManager.serverTimeStamp > 0 then
            return nOpenTime -- 开放时间没到，下一次的刷新时间优先判断开启时间
        end
    end

    local nNextRefreshTime = 0
    local nCloseTime = self.nEndTime
    if nCloseTime > 0 then
        nNextRefreshTime = nCloseTime
    end
    if mapShop.nRefreshTimeType > 0 then
        local nTime = nServerRefreshTime
        nNextRefreshTime = (nNextRefreshTime == 0 or nTime < nNextRefreshTime) and nTime or nNextRefreshTime
    end
    return nNextRefreshTime
end

-- 更新当前商品最早的下一次刷新时间
function ActivityShopData:UpdateNextGoodsRefreshTime(nShopId, nGoodsId)
    local mapGoods = self.tbGoods[nShopId][nGoodsId]

    local nNextRefreshTime = 0
    if mapGoods.nUnlockPurchaseTime > 0 then
        local nTime = mapGoods.nUnlockPurchaseTime
        nNextRefreshTime = (nNextRefreshTime == 0 or nTime < nNextRefreshTime) and nTime or nNextRefreshTime
    end
    return nNextRefreshTime
end

--------------------------- Server Data ---------------------------
-- 把服务器数据换个结构，方便查找
function ActivityShopData:ProcessServerData(mapServerData)
    for _, mapShop in ipairs(mapServerData) do
        self.tbServerData[mapShop.Id] = {}
        self.tbServerData[mapShop.Id].RefreshTime = mapShop.RefreshTime or 0
        for _, mapBoughtGoods in ipairs(mapShop.Infos) do
            self.tbServerData[mapShop.Id][mapBoughtGoods.Id] = mapBoughtGoods.Number
        end
    end
end

-- 获取商品的已购买数量
function ActivityShopData:GetBoughtCount(nGoodsId)
    local mapGoods = ConfigTable.GetData("ActivityGoods", nGoodsId)
    if mapGoods == nil then
        printError("商品配置不存在" .. nGoodsId)
        return 0
    end
    local nShopId = mapGoods.ShopId
    if self.tbServerData[nShopId] and self.tbServerData[nShopId][nGoodsId] then
        return self.tbServerData[nShopId][nGoodsId]
    else
        return 0
    end
end

------------------------------ Check ------------------------------
-- 获取需要更新数据的商店
function ActivityShopData:GetNeedToRefreshShops()
    local tbShopIds = {}
    local nServerTimeStamp = ClientManager.serverTimeStamp
    for _, mapShop in pairs(self.tbShops) do
        if not mapShop.bUnlock then -- 被锁定限制
            local bUnlock = self:CheckShopCond(mapShop.nUnlockCondType, mapShop.tbUnlockCondParams)
            if bUnlock then
                table.insert(tbShopIds, mapShop.nId)
            end
        elseif mapShop.nNextRefreshTime > 0 then -- 被时间限制
            if nServerTimeStamp >= mapShop.nNextRefreshTime then
                table.insert(tbShopIds, mapShop.nId)
            end
        end
    end
    return tbShopIds
end

-- 获取需要更新数据的商品
function ActivityShopData:GetNeedToRefreshGoods(nShopId)
    local tbGoods = {}
    local nServerTimeStamp = ClientManager.serverTimeStamp
    for _, mapGoods in pairs(self.tbGoods[nShopId]) do
        if not mapGoods.bUnlock then -- 被出现锁定限制
            local bUnlock = self:CheckShopCond(mapGoods.nAppearCondType, mapGoods.tbAppearCondParams)
            if bUnlock then
                table.insert(tbGoods, mapGoods)
            end
        elseif not mapGoods.bPurchasable then -- 被购买锁定限制
            local bPurchasable = self:CheckShopCond(mapGoods.nPurchaseCondType, mapGoods.tbPurchaseCondParams)
            if bPurchasable then
                table.insert(tbGoods, mapGoods)
            end
        elseif mapGoods.nNextRefreshTime > 0 then -- 被时间限制
            if nServerTimeStamp >= mapGoods.nNextRefreshTime then
                table.insert(tbGoods, mapGoods)
            end
        end
    end
    return tbGoods
end

-- 检测商店和商品限制
function ActivityShopData:CheckShopCond(eCond, tbParam)
    if eCond == 0 then
        return true
    elseif eCond == GameEnum.shopCond.WorldClassSpecific and #tbParam == 1 then
        local worldClass = PlayerData.Base:GetWorldClass()
        return worldClass >= tbParam[1]
    elseif eCond == GameEnum.shopCond.ShopPreGoodsSellOut and #tbParam == 2 then -- 活动的商品
        local nBeforeId = tbParam[2]
        local nBoughtCount = self:GetBoughtCount(nBeforeId)
        local mapCfg = ConfigTable.GetData("ActivityGoods", nBeforeId)
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

----------------------------- Network -----------------------------

-- 购买商品
function ActivityShopData:SendActivityShopPurchaseReq(nShopId, nGoodsId, nCount, callback)
    local mapMsg = {
        ActivityId = self.nActId,
        GoodsId = nGoodsId,
        Number = nCount,
        RefreshTime = self.tbShops[nShopId].nServerRefreshTime,
        ShopId = nShopId,
    }
    local function successCallback(_, mapData)
        if mapData.IsRefresh then
            self:ProcessServerData({ mapData.Shop })
            EventManager.Hit("ActivityShopTimeRefresh")
        else
            if not self.tbServerData[nShopId] then
                self.tbServerData[nShopId] = {}
            end
            self.tbServerData[nShopId][nGoodsId] = mapData.PurchasedNumber
        end
        self:UpdateData({ nShopId })

        UTILS.OpenReceiveByChangeInfo(mapData.Change)

        if callback then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_shop_purchase_req, mapMsg, nil, successCallback)
end

-------------------------------------------------------------------

return ActivityShopData
