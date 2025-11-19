local PlayerTeamData = class("PlayerTeamData")
PlayerTeamData.Init = function(self)
  -- function num : 0_0
  self._tbTeam = nil
end

PlayerTeamData.CacheFormationInfo = function(self, mapData)
  -- function num : 0_1 , upvalues : _ENV
  if mapData == nil then
    return 
  end
  if self._tbTeam == nil then
    self._tbTeam = {}
    for i = 1, (AllEnum.Const).MAX_TEAM_COUNT do
      -- DECOMPILER ERROR at PC29: Confused about usage of register: R6 in 'UnsetPending'

      (self._tbTeam)[i] = {nCaptainIndex = 0, 
tbTeamMemberId = {0, 0, 0}
, 
tbTeamDiscId = {0, 0, 0}
}
    end
  end
  do
    if mapData.Info ~= nil then
      for k,v in pairs(mapData.Info) do
        local nTeamId = v.Number
        local mapTeamData = (self._tbTeam)[nTeamId]
        if mapTeamData ~= nil then
          mapTeamData.nCaptainIndex = 1
        else
          mapTeamData = {nCaptainIndex = 1, 
tbTeamMemberId = {0, 0, 0}
, 
tbTeamDiscId = {0, 0, 0}
}
        end
        for nIndex,nCharId in ipairs(v.CharIds) do
          -- DECOMPILER ERROR at PC65: Confused about usage of register: R14 in 'UnsetPending'

          (mapTeamData.tbTeamMemberId)[nIndex] = nCharId
        end
        for nIndex,nDiscId in ipairs(v.DiscIds) do
          -- DECOMPILER ERROR at PC73: Confused about usage of register: R14 in 'UnsetPending'

          (mapTeamData.tbTeamDiscId)[nIndex] = nDiscId
        end
      end
    end
  end
end

PlayerTeamData.UpdateFormationInfo = function(self, nTeamId, tbCharIds, tbDiscIds, callback)
  -- function num : 0_2 , upvalues : _ENV
  local PlayerFormationReq = {}
  PlayerFormationReq.Formation = {}
  -- DECOMPILER ERROR at PC4: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (PlayerFormationReq.Formation).Number = nTeamId
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (PlayerFormationReq.Formation).Captain = 1
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (PlayerFormationReq.Formation).CharIds = tbCharIds
  -- DECOMPILER ERROR at PC10: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (PlayerFormationReq.Formation).DiscIds = tbDiscIds
  local Callback = function()
    -- function num : 0_2_0 , upvalues : self, nTeamId, _ENV, tbCharIds, tbDiscIds, callback
    if self._tbTeam == nil then
      self._tbTeam = {}
    end
    local mapTeamData = (self._tbTeam)[nTeamId]
    mapTeamData.nCaptainIndex = 1
    for nIndex,nCharId in ipairs(tbCharIds) do
      -- DECOMPILER ERROR at PC14: Confused about usage of register: R6 in 'UnsetPending'

      (mapTeamData.tbTeamMemberId)[nIndex] = nCharId
    end
    if tbDiscIds then
      for nIndex,nDiscId in ipairs(tbDiscIds) do
        -- DECOMPILER ERROR at PC25: Confused about usage of register: R6 in 'UnsetPending'

        (mapTeamData.tbTeamDiscId)[nIndex] = nDiscId
      end
    end
    do
      if callback ~= nil and type(callback) == "function" then
        callback()
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_formation_req, PlayerFormationReq, nil, Callback)
end

PlayerTeamData.GetTeamData = function(self, nTeamId)
  -- function num : 0_3
  if self._tbTeam == nil then
    return nil, nil
  end
  local mapTeamData = (self._tbTeam)[nTeamId]
  if mapTeamData ~= nil then
    return mapTeamData.nCaptainIndex, mapTeamData.tbTeamMemberId
  else
    return nil, nil
  end
end

PlayerTeamData.GetTeamDiscData = function(self, nTeamId)
  -- function num : 0_4
  if self._tbTeam == nil then
    return {0, 0, 0, 0, 0, 0}
  end
  local mapTeamData = (self._tbTeam)[nTeamId]
  if mapTeamData ~= nil then
    return mapTeamData.tbTeamDiscId
  else
    return {0, 0, 0, 0, 0, 0}
  end
end

PlayerTeamData.GetTeamCharId = function(self, nTeamId)
  -- function num : 0_5 , upvalues : _ENV
  local mapTeamData = (self._tbTeam)[nTeamId]
  local tbCharId = {}
  if mapTeamData ~= nil then
    local nCaptainId = (mapTeamData.tbTeamMemberId)[mapTeamData.nCaptainIndex]
    ;
    (table.insert)(tbCharId, nCaptainId)
    for _nIdx,_nCharId in ipairs(mapTeamData.tbTeamMemberId) do
      if _nCharId ~= 0 and _nCharId ~= nCaptainId then
        (table.insert)(tbCharId, _nCharId)
      end
    end
  end
  do
    return tbCharId
  end
end

PlayerTeamData.CheckTeamValid = function(self, nTeamId)
  -- function num : 0_6 , upvalues : _ENV
  if self._tbTeam == nil then
    return false
  end
  local mapTeam = (self._tbTeam)[nTeamId]
  if mapTeam == nil then
    return false
  else
    if type(mapTeam.tbTeamMemberId) == "table" then
      for i,nCharId in ipairs(mapTeam.tbTeamMemberId) do
        if nCharId < 1 then
          return false
        end
      end
      return true
    else
      return false
    end
  end
end

PlayerTeamData.TempCreateRoguelikeTeam = function(self, tbTeamCharId)
  -- function num : 0_7
  self._tbTeam = {}
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (self._tbTeam)[5] = {nCaptainIndex = 1, tbTeamMemberId = tbTeamCharId}
end

return PlayerTeamData

