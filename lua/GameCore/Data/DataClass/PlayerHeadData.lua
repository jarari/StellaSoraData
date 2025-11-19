local PlayerHeadData = class("PlayerHeadData")
PlayerHeadData.Init = function(self)
  -- function num : 0_0
  self.tbHeadList = {}
  self:InitConfig()
end

PlayerHeadData.UnInit = function(self)
  -- function num : 0_1
end

PlayerHeadData.InitConfig = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local foreachHead = function(mapData)
    -- function num : 0_2_0 , upvalues : self
    -- DECOMPILER ERROR at PC5: Confused about usage of register: R1 in 'UnsetPending'

    (self.tbHeadList)[mapData.Id] = {mapCfg = mapData, bUnlock = false}
  end

  ForEachTableLine(DataTable.PlayerHead, foreachHead)
end

PlayerHeadData.DelHeadId = function(self, nId)
  -- function num : 0_3
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbHeadList)[nId] ~= nil then
    ((self.tbHeadList)[nId]).bUnlock = false
  end
end

PlayerHeadData.ChangePlayerHead = function(self, mapData)
  -- function num : 0_4 , upvalues : _ENV
  if not mapData then
    return 
  end
  for _,v in pairs(mapData) do
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R7 in 'UnsetPending'

    if (self.tbHeadList)[v.Tid] ~= nil then
      ((self.tbHeadList)[v.Tid]).bUnlock = true
    end
    ;
    (RedDotManager.SetValid)(RedDotDefine.Friend_Head_Item, v.Tid, true)
  end
end

PlayerHeadData.GetPlayerHeadList = function(self)
  -- function num : 0_5 , upvalues : _ENV
  local tbHeadList = {}
  local nCurId = (PlayerData.Base):GetPlayerHeadId()
  for nId,v in pairs(self.tbHeadList) do
    local mapData = {}
    if (v.mapCfg).IsShow and (v.bUnlock or v.bUnlock or (v.mapCfg).IsLockShow) then
      mapData.nId = nId
      mapData.mapCfg = v.mapCfg
      mapData.nUnlock = v.bUnlock and 1 or 0
      if nId == nCurId then
        mapData.nSort = 1
      else
        mapData.nSort = 0
      end
      ;
      (table.insert)(tbHeadList, mapData)
    end
  end
  ;
  (table.sort)(tbHeadList, function(a, b)
    -- function num : 0_5_0
    if a.nUnlock == b.nUnlock then
      if a.nId >= b.nId then
        do return a.nSort ~= b.nSort end
        do return b.nUnlock < a.nUnlock end
        do return b.nSort < a.nSort end
        -- DECOMPILER ERROR: 5 unprocessed JMP targets
      end
    end
  end
)
  return tbHeadList
end

PlayerHeadData.SendGetHeadListMsg = function(self, callback)
  -- function num : 0_6 , upvalues : _ENV
  local netCallback = function(_, netMsgData)
    -- function num : 0_6_0 , upvalues : _ENV, self, callback
    for nId,v in pairs(self.tbHeadList) do
      v.bUnlock = (table.indexof)(netMsgData.List, nId) > 0
    end
    if callback ~= nil then
      callback()
    end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_head_icon_info_req, {}, nil, netCallback)
end

PlayerHeadData.SendPlayerHeadIconSetReq = function(self, nHeadIconId, callback)
  -- function num : 0_7 , upvalues : _ENV
  local msgData = {HeadIcon = nHeadIconId}
  local successCallback = function(_, mapMainData)
    -- function num : 0_7_0 , upvalues : _ENV, nHeadIconId, callback
    (PlayerData.Base):ChangePlayerHeadId(nHeadIconId)
    if callback then
      callback(mapMainData)
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_head_icon_set_req, msgData, nil, successCallback)
end

return PlayerHeadData

