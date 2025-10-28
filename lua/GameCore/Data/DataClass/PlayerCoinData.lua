--玩家货币数据

------------------------------ local ------------------------------








local PlayerCoinData = class("PlayerCoinData")
-------------------------------------------------------------------

------------------------------ public -----------------------------
function PlayerCoinData:Init()
    -- 玩家拥有的货币资源数据
    self._mapCoin = nil -- { [nItemId] = nCoinCount }
end

function PlayerCoinData:CacheCoin(mapData)
    if self._mapCoin == nil then
        self._mapCoin = {}
    end
    for _, mapCoinInfo in ipairs(mapData) do
        self._mapCoin[mapCoinInfo.Tid] = mapCoinInfo.Qty
    end
end
function PlayerCoinData:GetCoinCount(nCoinItemId)
    if type(self._mapCoin) == "table" then
        local nCoinCount = self._mapCoin[nCoinItemId]
        if type(nCoinCount) == "number" then
            return nCoinCount
        else
            self._mapCoin[nCoinItemId] = 0
            return 0
        end
    else
        self._mapCoin = {}
        self._mapCoin[nCoinItemId] = 0
        return 0
    end
end
function PlayerCoinData:ChangeCoin(mapCoinChange)
    if type(mapCoinChange) == "table" then
        for i, v in ipairs(mapCoinChange) do
            local nCoinItemId = v.Tid -- item 表中的 Id
            local nChangeCount = v.Qty -- 正数为增加，负数为扣除
            local nCurCount = self:GetCoinCount(nCoinItemId)
            self._mapCoin[nCoinItemId] = nCurCount + nChangeCount
            EventManager.Hit(EventId.CoinResChange, nCoinItemId, nCurCount, nChangeCount) -- 触发货币资源数量变更事件，参数：货币Id，变化前的数量，变化量。
            if nCoinItemId == AllEnum.CoinItemId.STONE then
                EventManager.Hit(EventId.CoinResChange, AllEnum.CoinItemId.FREESTONE)
            end
        end
    end
end
-------------------------------------------------------------------
-- 传入钻石数量，兑换心相碎片，默认规则(免费钻不够使用付费钻)
function PlayerCoinData:SendGemConvertReqReq(nCount, callback)
    local mapMsg = {
        Value = nCount
    }
    local function successCallback(_, mapData)
        if callback then
            callback(mapData)
        end
        UTILS.OpenReceiveByChangeInfo(mapData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.gem_convert_req, mapMsg, nil, successCallback)
end
function PlayerCoinData:SendGMReq(...)
    local sArgs = ""
    local nCount = select("#", ...)
    for i = 1, nCount do
        local param = select(i, ...)
        if i == nCount then
            sArgs = sArgs .. param
        else
            sArgs = sArgs .. param .. " "
        end
    end
    local msgData = {
        Action = "changeItems",
        Args = sArgs,
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.sudo_req, msgData)
end
--------------------------------------------------------------------


return PlayerCoinData