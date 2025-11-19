local PlayerFriendData = class("PlayerFriendData")
local TimerManager = require("GameCore.Timer.TimerManager")
local EnergyState = {None = 0, Able = 1, Received = 2}
PlayerFriendData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self._tbFriendList = {}
  self._tbFriendRequest = {}
  self._nFriendListNum = 0
  self._nFriendRequestNum = 0
  self._nEnergyCount = 0
  self._nPerReceiveEnergyConfig = (ConfigTable.GetConfigNumber)("FriendReceiveEnergyCount")
  self._nMaxReceiveEnergyConfig = (ConfigTable.GetConfigNumber)("FriendReceiveEnergyMax")
end

PlayerFriendData.CacheFriendData = function(self, mapMsgData)
  -- function num : 0_1 , upvalues : _ENV
  self._tbFriendList = {}
  self._nFriendListNum = 0
  if mapMsgData.ReceiveEnergyCnt then
    self._nEnergyCount = mapMsgData.ReceiveEnergyCnt
  end
  for _,mapFriendInfo in pairs(mapMsgData.Friends) do
    if not mapFriendInfo.Base or not (mapFriendInfo.Base).Id then
      local nId = mapFriendInfo.Id
    end
    -- DECOMPILER ERROR at PC22: Confused about usage of register: R8 in 'UnsetPending'

    ;
    (self._tbFriendList)[nId] = {}
    self:ParseFriendData((self._tbFriendList)[nId], mapFriendInfo)
    self._nFriendListNum = self._nFriendListNum + 1
  end
  self._tbFriendRequest = {}
  self._nFriendRequestNum = 0
  for nIndex,mapFriendInfo in pairs(mapMsgData.Invites) do
    -- DECOMPILER ERROR at PC42: Confused about usage of register: R7 in 'UnsetPending'

    (self._tbFriendRequest)[nIndex] = {}
    self:ParseFriendData((self._tbFriendRequest)[nIndex], mapFriendInfo)
    self._nFriendRequestNum = self._nFriendRequestNum + 1
  end
  self:UpdateFriendApplyRedDot()
  self:UpdateFriendEnergyRedDot()
end

PlayerFriendData.ParseFriendData = function(self, tbData, tbServer)
  -- function num : 0_2
  if tbServer.Base then
    self:ParseFriendDetail(tbData, tbServer.Base)
    tbData.nGetEnergy = tbServer.GetEnergy
    tbData.bSendEnergy = tbServer.SendEnergy
    tbData.bStar = tbServer.Star
  else
    self:ParseFriendDetail(tbData, tbServer)
  end
end

PlayerFriendData.ParseFriendDetail = function(self, tbData, tbServer)
  -- function num : 0_3
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

PlayerFriendData.GetFriendListData = function(self)
  -- function num : 0_4 , upvalues : _ENV
  local tbList = {}
  if not self._tbFriendList then
    return tbList
  end
  for _,v in pairs(self._tbFriendList) do
    (table.insert)(tbList, v)
  end
  ;
  (table.sort)(tbList, function(a, b)
    -- function num : 0_4_0
    if a.bStar ~= b.bStar then
      if a.bStar then
        do return not b.bStar end
        do return a.nUId < b.nUId end
        -- DECOMPILER ERROR: 2 unprocessed JMP targets
      end
    end
  end
)
  return tbList
end

PlayerFriendData.GetFriendListNum = function(self)
  -- function num : 0_5
  return self._nFriendListNum
end

PlayerFriendData.GetFriendRequestData = function(self)
  -- function num : 0_6
  return self._tbFriendRequest
end

PlayerFriendData.GetFriendRequestNum = function(self)
  -- function num : 0_7
  return self._nFriendRequestNum
end

PlayerFriendData.JudgeIsFriend = function(self, nUId)
  -- function num : 0_8
  if self._tbFriendList then
    return (self._tbFriendList)[nUId]
  end
end

PlayerFriendData.GetEnergyCount = function(self)
  -- function num : 0_9
  return self._nEnergyCount
end

PlayerFriendData.JudgeEnergyGetAble = function(self)
  -- function num : 0_10 , upvalues : _ENV, EnergyState
  if not self._tbFriendList then
    return false
  end
  for _,v in pairs(self._tbFriendList) do
    if v.nGetEnergy == EnergyState.Able then
      return true
    end
  end
  return false
end

PlayerFriendData.JudgeEnergySendAble = function(self)
  -- function num : 0_11 , upvalues : _ENV
  if not self._tbFriendList then
    return false
  end
  for _,v in pairs(self._tbFriendList) do
    if v.bSendEnergy == false then
      return true
    end
  end
  return false
end

PlayerFriendData.JudgeLogin = function(self, nNanoTime)
  -- function num : 0_12 , upvalues : _ENV
  local nTime = (math.floor)(nNanoTime / 1000000000)
  local nYear = tonumber((os.date)("%Y", nTime))
  local nMonth = tonumber((os.date)("%m", nTime))
  local nDay = tonumber((os.date)("%d", nTime))
  local nCurTime = ((CS.ClientManager).Instance).serverTimeStamp
  if nCurTime - nTime <= 86400 then
    return (ConfigTable.GetUIText)("Friend_Today"), (AllEnum.LoginTime).Today
  else
    return nYear .. "." .. nMonth .. "." .. nDay
  end
end

PlayerFriendData.DeleteFriend = function(self, nUId)
  -- function num : 0_13
  if not self._tbFriendList then
    return 
  end
  -- DECOMPILER ERROR at PC9: Confused about usage of register: R2 in 'UnsetPending'

  if (self._tbFriendList)[nUId] then
    (self._tbFriendList)[nUId] = nil
    self._nFriendListNum = self._nFriendListNum - 1
  end
  self:UpdateFriendEnergyRedDot()
end

PlayerFriendData.AddFriend = function(self, mapMainData)
  -- function num : 0_14 , upvalues : _ENV
  if not self._tbFriendList then
    self._tbFriendList = {}
  end
  if (self._tbFriendList)[(mapMainData.Friend).Id] then
    return 
  end
  local tab = {}
  ;
  (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
  ;
  (NovaAPI.UserEventUpload)("add_friend", tab)
  -- DECOMPILER ERROR at PC34: Confused about usage of register: R3 in 'UnsetPending'

  ;
  (self._tbFriendList)[(mapMainData.Friend).Id] = {}
  self:ParseFriendData((self._tbFriendList)[(mapMainData.Friend).Id], mapMainData.Friend)
  self._nFriendListNum = self._nFriendListNum + 1
  self:UpdateFriendEnergyRedDot()
end

PlayerFriendData.DeleteRequest = function(self, nUId)
  -- function num : 0_15 , upvalues : _ENV
  if not self._tbFriendRequest then
    return 
  end
  for nIndex,mapFriendInfo in pairs(self._tbFriendRequest) do
    if nUId == mapFriendInfo.nUId then
      (table.remove)(self._tbFriendRequest, nIndex)
      self._nFriendRequestNum = self._nFriendRequestNum - 1
      return 
    end
  end
  self:UpdateFriendApplyRedDot()
end

PlayerFriendData.UpdateFriendState = function(self, mapFriendState)
  -- function num : 0_16 , upvalues : _ENV
  local nAction = mapFriendState.Action
  local nUId = mapFriendState.Id
  if nAction == 2 then
    self:DeleteRequest(nUId)
    ;
    (EventManager.Hit)("FriendRefreshRequest")
    local tab = {}
    ;
    (table.insert)(tab, {"role_id", tostring((PlayerData.Base)._nPlayerId)})
    ;
    (NovaAPI.UserEventUpload)("add_friend", tab)
  else
    do
      if nAction == 3 then
        self:DeleteFriend(nUId)
        ;
        (EventManager.Hit)("FriendRefreshList")
      end
      if nAction == 1 then
        (RedDotManager.SetValid)(RedDotDefine.Friend_Apply, nil, true)
      end
    end
  end
end

PlayerFriendData.UpdateFriendEnergy = function(self, mapData)
  -- function num : 0_17 , upvalues : _ENV
  (RedDotManager.SetValid)(RedDotDefine.Friend_Energy, nil, mapData.State)
end

PlayerFriendData.SetTimer = function(self, nTime)
  -- function num : 0_18 , upvalues : TimerManager
  if nTime <= 0 then
    return 
  end
  self.bCD = true
  if self.timer ~= nil then
    (self.timer):Cancel(false)
    self.timer = nil
  end
  self.nCd = nTime
  self.timer = (TimerManager.Add)(1, nTime, self, function()
    -- function num : 0_18_0 , upvalues : self
    self.bCD = false
  end
, true, true, false)
end

PlayerFriendData.SendFriendListGetReq = function(self, callback)
  -- function num : 0_19 , upvalues : _ENV
  if self.bCD then
    callback()
    return 
  end
  local successCallback = function(_, mapMainData)
    -- function num : 0_19_0 , upvalues : self, callback
    self:SetTimer(2)
    self:CacheFriendData(mapMainData)
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_list_get_req, {}, nil, successCallback)
end

PlayerFriendData.SendFriendDeleteReq = function(self, nUId, callback)
  -- function num : 0_20 , upvalues : _ENV
  local msgData = {UId = nUId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_20_0 , upvalues : self, nUId, callback
    self:DeleteFriend(nUId)
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_delete_req, msgData, nil, successCallback)
end

PlayerFriendData.SendFriendAddAgreeReq = function(self, nUId, callback)
  -- function num : 0_21 , upvalues : _ENV
  local msgData = {UId = nUId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_21_0 , upvalues : self, nUId, callback
    self:AddFriend(mapMainData)
    self:DeleteRequest(nUId)
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_add_agree_req, msgData, nil, successCallback)
end

PlayerFriendData.SendFriendAllAgreeReq = function(self, callback)
  -- function num : 0_22 , upvalues : _ENV
  local successCallback = function(_, mapMainData)
    -- function num : 0_22_0 , upvalues : self, callback
    self:CacheFriendData(mapMainData)
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_all_agree_req, {}, nil, successCallback)
end

PlayerFriendData.SendFriendInvitesDeleteReq = function(self, tbUId, callback)
  -- function num : 0_23 , upvalues : _ENV
  local msgData = {UIds = tbUId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_23_0 , upvalues : _ENV, tbUId, self, callback
    for _,nUId in pairs(tbUId) do
      self:DeleteRequest(nUId)
    end
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_invites_delete_req, msgData, nil, successCallback)
end

PlayerFriendData.SendAddFriendReq = function(self, nUId, callback)
  -- function num : 0_24 , upvalues : _ENV
  local msgData = {UId = nUId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_24_0 , upvalues : callback
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_add_req, msgData, nil, successCallback)
end

PlayerFriendData.SendFriendNameSearchReq = function(self, sName, callback)
  -- function num : 0_25 , upvalues : _ENV
  local msgData = {Name = sName}
  local successCallback = function(_, mapMainData)
    -- function num : 0_25_0 , upvalues : _ENV, self, callback
    if not mapMainData.Friends or #mapMainData.Friends == 0 then
      (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Friend_SearchNone")})
    else
      local tbSearch = {}
      for nIndex,mapFriendInfo in pairs(mapMainData.Friends) do
        tbSearch[nIndex] = {}
        self:ParseFriendData(tbSearch[nIndex], mapFriendInfo)
      end
      callback(tbSearch)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_name_search_req, msgData, nil, successCallback)
end

PlayerFriendData.SendFriendUIdSearchReq = function(self, nUId, callback)
  -- function num : 0_26 , upvalues : _ENV
  local msgData = {Id = nUId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_26_0 , upvalues : _ENV, self, callback
    if not mapMainData.Friend then
      (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Friend_SearchNone")})
    else
      local tbSearch = {}
      tbSearch[1] = {}
      self:ParseFriendData(tbSearch[1], mapMainData.Friend)
      callback(tbSearch)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_uid_search_req, msgData, nil, successCallback)
end

PlayerFriendData.SendFriendReceiveEnergyReq = function(self, tbUId, callback)
  -- function num : 0_27 , upvalues : _ENV, EnergyState
  local msgData = {UIds = tbUId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_27_0 , upvalues : self, _ENV, EnergyState, callback
    local nBefore = self._nEnergyCount
    for _,nId in pairs(mapMainData.UIds) do
      -- DECOMPILER ERROR at PC12: Confused about usage of register: R8 in 'UnsetPending'

      if (self._tbFriendList)[nId] then
        ((self._tbFriendList)[nId]).nGetEnergy = EnergyState.Received
      end
    end
    self._nEnergyCount = mapMainData.ReceiveEnergyCnt
    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.ReceivePropsTips, {
{id = (AllEnum.CoinItemId).Energy, count = self._nEnergyCount - nBefore}
})
    callback(mapMainData.UIds)
    self:UpdateFriendEnergyRedDot()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_receive_energy_req, msgData, nil, successCallback)
end

PlayerFriendData.SendFriendSendEnergyReq = function(self, tbUId, callback)
  -- function num : 0_28 , upvalues : _ENV
  local msgData = {UIds = tbUId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_28_0 , upvalues : _ENV, self, callback
    for _,nId in pairs(mapMainData.UIds) do
      -- DECOMPILER ERROR at PC10: Confused about usage of register: R7 in 'UnsetPending'

      if (self._tbFriendList)[nId] then
        ((self._tbFriendList)[nId]).bSendEnergy = true
      end
    end
    callback(mapMainData.UIds)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_send_energy_req, msgData, nil, successCallback)
end

PlayerFriendData.SendFriendStarSetReq = function(self, tbUId, bStar, callback)
  -- function num : 0_29 , upvalues : _ENV
  local msgData = {UIds = tbUId, Star = bStar}
  local successCallback = function(_, mapMainData)
    -- function num : 0_29_0 , upvalues : _ENV, tbUId, self, bStar, callback
    for _,nId in pairs(tbUId) do
      -- DECOMPILER ERROR at PC11: Confused about usage of register: R7 in 'UnsetPending'

      if (self._tbFriendList)[nId] then
        ((self._tbFriendList)[nId]).bStar = bStar
      end
    end
    callback(mapMainData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_star_set_req, msgData, nil, successCallback)
end

PlayerFriendData.SendFriendRecommendationGetReq = function(self, callback)
  -- function num : 0_30 , upvalues : _ENV
  local successCallback = function(_, mapMainData)
    -- function num : 0_30_0 , upvalues : _ENV, self, callback
    if not mapMainData.Friends or #mapMainData.Friends == 0 then
      (EventManager.Hit)(EventId.OpenMessageBox, {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("Friend_NoneRecommend")})
    else
      local tbSearch = {}
      for nIndex,mapFriendInfo in pairs(mapMainData.Friends) do
        tbSearch[nIndex] = {}
        self:ParseFriendData(tbSearch[nIndex], mapFriendInfo)
      end
      callback(tbSearch)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).friend_recommendation_get_req, {}, nil, successCallback)
end

PlayerFriendData.UpdateFriendApplyRedDot = function(self)
  -- function num : 0_31 , upvalues : _ENV
  (RedDotManager.SetValid)(RedDotDefine.Friend_Apply, nil, self._nFriendRequestNum > 0)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerFriendData.UpdateFriendEnergyRedDot = function(self)
  -- function num : 0_32 , upvalues : _ENV, EnergyState
  local bCheck = false
  local bMax = self._nMaxReceiveEnergyConfig <= (PlayerData.Friend):GetEnergyCount()
  if self._tbFriendList and not bMax then
    for _,v in pairs(self._tbFriendList) do
      if v.nGetEnergy == EnergyState.Able then
        bCheck = true
        break
      end
    end
  end
  ;
  (RedDotManager.SetValid)(RedDotDefine.Friend_Energy, nil, bCheck)
  -- DECOMPILER ERROR: 3 unprocessed JMP targets
end

return PlayerFriendData

