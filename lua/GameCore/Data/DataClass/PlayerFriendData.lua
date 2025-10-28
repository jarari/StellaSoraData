--玩家好友数据
------------------------------ local ------------------------------
local PlayerFriendData = class("PlayerFriendData")
local TimerManager = require "GameCore.Timer.TimerManager"

local EnergyState = {
    None = 0,     -- 未被赠送
    Able = 1,     -- 被赠送未领取
    Received = 2, -- 被赠送已领取
}
-------------------------------------------------------------------

------------------------------ public -----------------------------
function PlayerFriendData:Init()
    self._tbFriendList = {}    -- 好友列表
    self._tbFriendRequest = {} -- 好友申请
    self._nFriendListNum = 0
    self._nFriendRequestNum = 0
    self._nEnergyCount = 0
    self._nPerReceiveEnergyConfig = ConfigTable.GetConfigNumber("FriendReceiveEnergyCount")
    self._nMaxReceiveEnergyConfig = ConfigTable.GetConfigNumber("FriendReceiveEnergyMax")
end

function PlayerFriendData:CacheFriendData(mapMsgData)
    -- 好友列表数据
    self._tbFriendList = {}
    self._nFriendListNum = 0
    if mapMsgData.ReceiveEnergyCnt then
        self._nEnergyCount = mapMsgData.ReceiveEnergyCnt
    end
    for _, mapFriendInfo in pairs(mapMsgData.Friends) do
        local nId = mapFriendInfo.Base and mapFriendInfo.Base.Id or mapFriendInfo.Id
        self._tbFriendList[nId] = {}
        self:ParseFriendData(self._tbFriendList[nId], mapFriendInfo)
        self._nFriendListNum = self._nFriendListNum + 1
    end

    -- 好友申请数据
    self._tbFriendRequest = {}
    self._nFriendRequestNum = 0
    for nIndex, mapFriendInfo in pairs(mapMsgData.Invites) do
        self._tbFriendRequest[nIndex] = {}
        self:ParseFriendData(self._tbFriendRequest[nIndex], mapFriendInfo)
        self._nFriendRequestNum = self._nFriendRequestNum + 1
    end

    self:UpdateFriendApplyRedDot()
    self:UpdateFriendEnergyRedDot()
end

function PlayerFriendData:ParseFriendData(tbData, tbServer)
    if tbServer.Base then
        self:ParseFriendDetail(tbData, tbServer.Base)
        tbData.nGetEnergy = tbServer.GetEnergy
        tbData.bSendEnergy = tbServer.SendEnergy
        tbData.bStar = tbServer.Star
    else
        self:ParseFriendDetail(tbData, tbServer)
    end
end

function PlayerFriendData:ParseFriendDetail(tbData, tbServer)
    tbData.nHashtag = tbServer.Hashtag
    tbData.nHeadIconId = tbServer.HeadIcon
    tbData.nUId = tbServer.Id
    tbData.nLogin = tbServer.LastLoginTime
    tbData.sName = tbServer.NickName
    tbData.nTitlePrefix = tbServer.TitlePrefix
    tbData.nTitleSuffix = tbServer.TitleSuffix
    tbData.sName = tbServer.NickName
    tbData.nWorldClass = tbServer.WorldClass
    tbData.tbChar = tbServer.CharShows
    tbData.sSign = tbServer.Signature
    tbData.tbHonorTitle = tbServer.Honors
end

-- 获取当前好友列表
function PlayerFriendData:GetFriendListData()
    local tbList = {}
    if not self._tbFriendList then
        return tbList
    end
    for _, v in pairs(self._tbFriendList) do
        table.insert(tbList, v)
    end
    table.sort(tbList, function(a, b)
        if a.bStar ~= b.bStar then
            return a.bStar and not b.bStar
        else
            return a.nUId < b.nUId
        end
    end)
    return tbList
end

-- 获取当前好友数量
function PlayerFriendData:GetFriendListNum()
    return self._nFriendListNum
end

-- 获取当前好友申请
function PlayerFriendData:GetFriendRequestData()
    return self._tbFriendRequest
end

-- 获取当前好友申请数量
function PlayerFriendData:GetFriendRequestNum()
    return self._nFriendRequestNum
end

-- 判断是否已经是好友
function PlayerFriendData:JudgeIsFriend(nUId)
    return self._tbFriendList and self._tbFriendList[nUId]
end

-- 获取当前已从好友处领取体力的计数
function PlayerFriendData:GetEnergyCount()
    return self._nEnergyCount
end

function PlayerFriendData:JudgeEnergyGetAble()
    if not self._tbFriendList then
        return false
    end

    for _, v in pairs(self._tbFriendList) do
        if v.nGetEnergy == EnergyState.Able then
            return true
        end
    end
    return false
end

function PlayerFriendData:JudgeEnergySendAble()
    if not self._tbFriendList then
        return false
    end

    for _, v in pairs(self._tbFriendList) do
        if v.bSendEnergy == false then
            return true
        end
    end
    return false
end

-- 判断登录日期区分（今日/以前）
function PlayerFriendData:JudgeLogin(nNanoTime)
    local nTime = math.floor(nNanoTime / 10 ^ 9) -- 原时间计时是纳秒
    local nYear = tonumber(os.date("%Y", nTime))
    local nMonth = tonumber(os.date("%m", nTime))
    local nDay = tonumber(os.date("%d", nTime))

    local nCurTime = CS.ClientManager.Instance.serverTimeStamp
    local nThisYear = tonumber(os.date("%Y", nCurTime))
    local nThisMontn = tonumber(os.date("%m", nCurTime))
    local nToday = tonumber(os.date("%d", nCurTime))

    if nYear == nThisYear and nMonth == nThisMontn and nDay == nToday then
        -- 今日
        return ConfigTable.GetUIText("Friend_Today"), AllEnum.LoginTime.Today
        -- elseif nYear == nThisYear and nMonth == nThisMontn and nDay + 1 == nToday then
        --     -- 昨日
        --     return GetUITextData("Friend_Yesday"), AllEnum.LoginTime.Yesday
    else
        -- 具体日期
        return nYear .. "." .. nMonth .. "." .. nDay
    end
end

-- 好友列表内的本地数据里删除特定UID好友
function PlayerFriendData:DeleteFriend(nUId)
    if not self._tbFriendList then
        return
    end
    if self._tbFriendList[nUId] then
        self._tbFriendList[nUId] = nil
        self._nFriendListNum = self._nFriendListNum - 1
    end
    self:UpdateFriendEnergyRedDot()
end

-- 好友列表内的本地数据里新增好友
function PlayerFriendData:AddFriend(mapMainData)
    if not self._tbFriendList then
        self._tbFriendList = {}
    end
    -- 可能这个好友已在列表里了
    if self._tbFriendList[mapMainData.Friend.Id] then
        return
    end

    local tab = {}
    table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
    NovaAPI.UserEventUpload("add_friend",tab)

    -- 没有的话再添加这个好友
    self._tbFriendList[mapMainData.Friend.Id] = {}
    self:ParseFriendData(self._tbFriendList[mapMainData.Friend.Id], mapMainData.Friend)
    self._nFriendListNum = self._nFriendListNum + 1
    self:UpdateFriendEnergyRedDot()
end

-- 好友申请内的本地数据里删除特定UID申请
function PlayerFriendData:DeleteRequest(nUId)
    if not self._tbFriendRequest then
        return
    end
    for nIndex, mapFriendInfo in pairs(self._tbFriendRequest) do
        if nUId == mapFriendInfo.nUId then
            table.remove(self._tbFriendRequest, nIndex)
            self._nFriendRequestNum = self._nFriendRequestNum - 1
            return
        end
    end
    self:UpdateFriendApplyRedDot()
end

-- 更新好友状态
function PlayerFriendData:UpdateFriendState(mapFriendState)
    -- 结构
    -- FriendState =
    -- {
    --     Action,  -- 在线玩家:1收到申请好友;2申请好友被接受;3被删除好友
    --     Id,      -- 用户唯一ID
    -- }
    local nAction = mapFriendState.Action
    local nUId = mapFriendState.Id
    if nAction == 2 then
        self:DeleteRequest(nUId)
        EventManager.Hit("FriendRefreshRequest")
        local tab = {}
        table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
        NovaAPI.UserEventUpload("add_friend",tab)
    elseif nAction == 3 then
        self:DeleteFriend(nUId)
        EventManager.Hit("FriendRefreshList")
    end

    if nAction == 1 then
        --刷新红点
        RedDotManager.SetValid(RedDotDefine.Friend_Apply, nil, true)
    end
end

function PlayerFriendData:UpdateFriendEnergy(mapData)
    --刷新红点
    RedDotManager.SetValid(RedDotDefine.Friend_Energy, nil, mapData.State)
end

function PlayerFriendData:SetTimer(nTime)
    if nTime <= 0 then
        return
    end
    self.bCD = true
    if self.timer ~= nil then
        self.timer:Cancel(false)
        self.timer = nil
    end
    self.nCd = nTime
    self.timer = TimerManager.Add(1, nTime, self, function ()
        self.bCD = false
    end, true, true, false)
end

-- 获取好友列表和好友申请列表请求
function PlayerFriendData:SendFriendListGetReq(callback)
    if self.bCD then
        callback()
        return
    end

    local function successCallback(_, mapMainData)
        self:SetTimer(2)
        self:CacheFriendData(mapMainData)
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_list_get_req, {}, nil, successCallback)
end

-- 删除好友请求
function PlayerFriendData:SendFriendDeleteReq(nUId, callback)
    local msgData = {
        UId = nUId,
    }
    local function successCallback(_, mapMainData)
        self:DeleteFriend(nUId)
        callback(mapMainData)
    end
    -- 如果对方已经删了你好友，这时候再去删他，会走到UpdateFriendState
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_delete_req, msgData, nil, successCallback)
end

-- 通过好友申请请求
function PlayerFriendData:SendFriendAddAgreeReq(nUId, callback)
    local msgData = {
        UId = nUId,
    }
    local function successCallback(_, mapMainData)
        self:AddFriend(mapMainData)
        self:DeleteRequest(nUId)
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_add_agree_req, msgData, nil, successCallback)
end

-- 通过所有好友申请请求
function PlayerFriendData:SendFriendAllAgreeReq(callback)
    local function successCallback(_, mapMainData)
        self:CacheFriendData(mapMainData)
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_all_agree_req, {}, nil, successCallback)
end

-- 拒绝好友申请请求
function PlayerFriendData:SendFriendInvitesDeleteReq(tbUId, callback)
    local msgData = {
        UIds = tbUId,
    }
    local function successCallback(_, mapMainData)
        for _, nUId in pairs(tbUId) do
            self:DeleteRequest(nUId)
        end
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_invites_delete_req, msgData, nil, successCallback)
end

-- 发送好友申请请求
function PlayerFriendData:SendAddFriendReq(nUId, callback)
    local msgData = {
        UId = nUId,
    }
    local function successCallback(_, mapMainData)
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_add_req, msgData, nil, successCallback)
end

-- 搜索用户请求(昵称)
function PlayerFriendData:SendFriendNameSearchReq(sName, callback)
    local msgData = {
        Name = sName,
    }
    local function successCallback(_, mapMainData)
        if not mapMainData.Friends or #mapMainData.Friends == 0 then
            EventManager.Hit(EventId.OpenMessageBox,
                { nType = AllEnum.MessageBox.Alert, sContent = ConfigTable.GetUIText("Friend_SearchNone") })
        else
            local tbSearch = {}
            for nIndex, mapFriendInfo in pairs(mapMainData.Friends) do
                tbSearch[nIndex] = {}
                self:ParseFriendData(tbSearch[nIndex], mapFriendInfo)
            end
            callback(tbSearch)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_name_search_req, msgData, nil, successCallback)
end

-- 搜索用户请求(UId)
function PlayerFriendData:SendFriendUIdSearchReq(nUId, callback)
    local msgData = {
        Id = nUId,
    }
    local function successCallback(_, mapMainData)
        if not mapMainData.Friend then
            EventManager.Hit(EventId.OpenMessageBox,
                { nType = AllEnum.MessageBox.Alert, sContent = ConfigTable.GetUIText("Friend_SearchNone") })
        else
            local tbSearch = {}
            tbSearch[1] = {}
            self:ParseFriendData(tbSearch[1], mapMainData.Friend)
            callback(tbSearch)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_uid_search_req, msgData, nil, successCallback)
end

-- 请求领取好友赠送体力
function PlayerFriendData:SendFriendReceiveEnergyReq(tbUId, callback)
    local msgData = {
        UIds = tbUId, -- 好友UId列表，列表为空表示一键领取
    }
    local function successCallback(_, mapMainData)
        local nBefore = self._nEnergyCount
        for _, nId in pairs(mapMainData.UIds) do
            if self._tbFriendList[nId] then
                self._tbFriendList[nId].nGetEnergy = EnergyState.Received
            end
        end
        self._nEnergyCount = mapMainData.ReceiveEnergyCnt
        EventManager.Hit(EventId.OpenPanel, PanelId.ReceivePropsTips, {{id = AllEnum.CoinItemId.Energy, count = self._nEnergyCount - nBefore}})
        callback(mapMainData.UIds)
        self:UpdateFriendEnergyRedDot()
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_receive_energy_req, msgData, nil, successCallback)
end

-- 请求赠送好友体力
function PlayerFriendData:SendFriendSendEnergyReq(tbUId, callback)
    local msgData = {
        UIds = tbUId, -- 好友UId列表，列表为空表示一键赠送
    }
    local function successCallback(_, mapMainData)
        for _, nId in pairs(mapMainData.UIds) do
            if self._tbFriendList[nId] then
                self._tbFriendList[nId].bSendEnergy = true
            end
        end
        callback(mapMainData.UIds)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_send_energy_req, msgData, nil, successCallback)
end

-- 请求设置星级好友
function PlayerFriendData:SendFriendStarSetReq(tbUId, bStar, callback)
    local msgData = {
        UIds = tbUId,
        Star = bStar, -- ture加星，false取消
    }
    local function successCallback(_, mapMainData)
        for _, nId in pairs(tbUId) do
            if self._tbFriendList[nId] then
                self._tbFriendList[nId].bStar = bStar
            end
        end
        callback(mapMainData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_star_set_req, msgData, nil, successCallback)
end

-- 请求好友推荐列表
function PlayerFriendData:SendFriendRecommendationGetReq(callback)
    local function successCallback(_, mapMainData)
        if not mapMainData.Friends or #mapMainData.Friends == 0 then
            EventManager.Hit(EventId.OpenMessageBox,
                { nType = AllEnum.MessageBox.Alert, sContent = ConfigTable.GetUIText("Friend_NoneRecommend") })
        else
            local tbSearch = {}
            for nIndex, mapFriendInfo in pairs(mapMainData.Friends) do
                tbSearch[nIndex] = {}
                self:ParseFriendData(tbSearch[nIndex], mapFriendInfo)
            end
            callback(tbSearch)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.friend_recommendation_get_req, {}, nil, successCallback)
end

-------------------------------------------------------------------

--------------------------- 红点相关 --------------------------------
--好友申请红点
--有待处理好友请求时显示红点
function PlayerFriendData:UpdateFriendApplyRedDot()
    RedDotManager.SetValid(RedDotDefine.Friend_Apply, nil, self._nFriendRequestNum > 0)
end

function PlayerFriendData:UpdateFriendEnergyRedDot()
    local bCheck = false
    local bMax = PlayerData.Friend:GetEnergyCount() >= self._nMaxReceiveEnergyConfig
    if self._tbFriendList and not bMax then
        for _, v in pairs(self._tbFriendList) do
            if v.nGetEnergy == EnergyState.Able then
                bCheck = true
                break
            end
        end
    end
    RedDotManager.SetValid(RedDotDefine.Friend_Energy, nil, bCheck)
end

return PlayerFriendData
