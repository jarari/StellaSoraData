local PlayerCoinData = class("PlayerCoinData")
PlayerCoinData.Init = function(self)
  -- function num : 0_0
  self._mapCoin = nil
end

PlayerCoinData.CacheCoin = function(self, mapData)
  -- function num : 0_1 , upvalues : _ENV
  if self._mapCoin == nil then
    self._mapCoin = {}
  end
  for _,mapCoinInfo in ipairs(mapData) do
    -- DECOMPILER ERROR at PC12: Confused about usage of register: R7 in 'UnsetPending'

    (self._mapCoin)[mapCoinInfo.Tid] = mapCoinInfo.Qty
  end
end

PlayerCoinData.GetCoinCount = function(self, nCoinItemId)
  -- function num : 0_2 , upvalues : _ENV
  if type(self._mapCoin) == "table" then
    local nCoinCount = (self._mapCoin)[nCoinItemId]
    if type(nCoinCount) == "number" then
      return nCoinCount
    else
      -- DECOMPILER ERROR at PC15: Confused about usage of register: R3 in 'UnsetPending'

      ;
      (self._mapCoin)[nCoinItemId] = 0
      return 0
    end
  else
    do
      self._mapCoin = {}
      -- DECOMPILER ERROR at PC22: Confused about usage of register: R2 in 'UnsetPending'

      ;
      (self._mapCoin)[nCoinItemId] = 0
      do return 0 end
    end
  end
end

PlayerCoinData.ChangeCoin = function(self, mapCoinChange)
  -- function num : 0_3 , upvalues : _ENV
  if type(mapCoinChange) == "table" then
    for i,v in ipairs(mapCoinChange) do
      local nCoinItemId = v.Tid
      local nChangeCount = v.Qty
      local nCurCount = self:GetCoinCount(nCoinItemId)
      -- DECOMPILER ERROR at PC16: Confused about usage of register: R10 in 'UnsetPending'

      ;
      (self._mapCoin)[nCoinItemId] = nCurCount + nChangeCount
      ;
      (EventManager.Hit)(EventId.CoinResChange, nCoinItemId, nCurCount, nChangeCount)
      if nCoinItemId == (AllEnum.CoinItemId).STONE then
        (EventManager.Hit)(EventId.CoinResChange, (AllEnum.CoinItemId).FREESTONE)
      end
    end
  end
end

PlayerCoinData.SendGemConvertReqReq = function(self, nCount, callback)
  -- function num : 0_4 , upvalues : _ENV
  local mapMsg = {Value = nCount}
  local successCallback = function(_, mapData)
    -- function num : 0_4_0 , upvalues : callback, _ENV
    if callback then
      callback(mapData)
    end
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapData)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).gem_convert_req, mapMsg, nil, successCallback)
end

return PlayerCoinData

