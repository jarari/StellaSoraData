local PlayerDictionaryData = class("PlayerDictionaryData")
local Status = {Uncompleted = 0, Unreceived = 1, Received = 2}
PlayerDictionaryData.Init = function(self)
  -- function num : 0_0
  self._tbEntryStatus = {}
  self._tbEntryId = {}
  self:ProcessTableData()
end

PlayerDictionaryData.ProcessTableData = function(self)
  -- function num : 0_1 , upvalues : _ENV, Status
  local func_ForEach_DictionaryEntry = function(mapData)
    -- function num : 0_1_0 , upvalues : self, _ENV, Status
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self._tbEntryId)[mapData.Tab] == nil then
      (self._tbEntryId)[mapData.Tab] = {}
    end
    -- DECOMPILER ERROR at PC14: Confused about usage of register: R1 in 'UnsetPending'

    ;
    ((self._tbEntryId)[mapData.Tab])[mapData.Index] = mapData.Id
    -- DECOMPILER ERROR at PC24: Confused about usage of register: R1 in 'UnsetPending'

    if mapData.FinishType == (GameEnum.questCompleteCond).ClientReport then
      (self._tbEntryStatus)[mapData.Id] = Status.Uncompleted
    end
  end

  ForEachTableLine(DataTable.DictionaryEntry, func_ForEach_DictionaryEntry)
end

PlayerDictionaryData.GetEntryStatus = function(self, nId)
  -- function num : 0_2 , upvalues : Status
  return (self._tbEntryStatus)[nId] or Status.Uncompleted
end

PlayerDictionaryData.GetCompletedEntry = function(self, bAll)
  -- function num : 0_3 , upvalues : _ENV, Status
  local tbList = {}
  for nId,nStatus in pairs(self._tbEntryStatus) do
    if nStatus == Status.Received or nStatus == Status.Unreceived then
      local mapCfg = (ConfigTable.GetData)("DictionaryEntry", nId)
      local mapTab = (ConfigTable.GetData)("DictionaryTab", mapCfg.Tab)
      if nStatus ~= Status.Unreceived then
        do
          local mapData = {nId = nId, nIndex = mapCfg.Index, nSort = mapCfg.Sort, sTitle = mapCfg.Title, nTab = mapCfg.Tab, bUnreceived = not bAll and mapTab.HideInBattle}
          ;
          (table.insert)(tbList, mapData)
          -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out IF_STMT

          -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC47: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  do return tbList end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerDictionaryData.GetUncompletedEntry = function(self)
  -- function num : 0_4 , upvalues : _ENV, Status
  local tbList = {}
  for nId,nStatus in pairs(self._tbEntryStatus) do
    if nStatus == Status.Uncompleted then
      (table.insert)(tbList, nId)
    end
  end
  return tbList
end

PlayerDictionaryData.CacheDictionaryData = function(self, tbData)
  -- function num : 0_5 , upvalues : _ENV
  if not tbData then
    return 
  end
  for _,mapTab in pairs(tbData) do
    for _,mapEntry in pairs(mapTab.Entries) do
      local nId = ((self._tbEntryId)[mapTab.TabId])[mapEntry.Index]
      -- DECOMPILER ERROR at PC20: Confused about usage of register: R13 in 'UnsetPending'

      if nId then
        (self._tbEntryStatus)[nId] = mapEntry.Status
        self:UpdateDictionarySubRedDot(mapTab.TabId, mapEntry.Index, mapEntry.Status)
      else
        printError("DictionaryEntry表变更，TabId" .. mapTab.TabId .. ";Index" .. mapEntry.Index .. "对应的词条未找到")
      end
    end
  end
end

PlayerDictionaryData.ChangeDictionaryData = function(self, mapData)
  -- function num : 0_6 , upvalues : Status, _ENV
  local nId = ((self._tbEntryId)[mapData.TabId])[mapData.Index]
  do
    if not (self._tbEntryStatus)[nId] or (self._tbEntryStatus)[nId] == Status.Uncompleted then
      local mapCfg = (ConfigTable.GetData)("DictionaryEntry", nId)
      if mapCfg ~= nil and mapCfg.Popup == true then
        (PlayerData.SideBanner):AddDictionaryEntry(nId)
      end
    end
    -- DECOMPILER ERROR at PC31: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self._tbEntryStatus)[nId] = mapData.Status
    self:UpdateDictionarySubRedDot(mapData.TabId, mapData.Index, mapData.Status)
  end
end

PlayerDictionaryData.SendDictRewardReq = function(self, nTabId, nIndex, callback)
  -- function num : 0_7 , upvalues : _ENV, Status
  local mapMsg = {TabId = nTabId, Index = nIndex}
  local successCallback = function(_, mapData)
    -- function num : 0_7_0 , upvalues : _ENV, nIndex, self, nTabId, Status, callback
    local mapReward = (PlayerData.Item):ProcessRewardChangeInfo(mapData)
    if nIndex == 0 then
      for nEntryIndex,nId in pairs((self._tbEntryId)[nTabId]) do
        -- DECOMPILER ERROR at PC16: Confused about usage of register: R8 in 'UnsetPending'

        (self._tbEntryStatus)[nId] = Status.Received
        self:UpdateDictionarySubRedDot(nTabId, nEntryIndex, Status.Received)
      end
    else
      do
        do
          local nId = ((self._tbEntryId)[nTabId])[nIndex]
          -- DECOMPILER ERROR at PC33: Confused about usage of register: R4 in 'UnsetPending'

          ;
          (self._tbEntryStatus)[nId] = Status.Received
          self:UpdateDictionarySubRedDot(nTabId, nIndex, Status.Received)
          if callback then
            callback(mapReward)
          end
        end
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).dictionary_reward_receive_req, mapMsg, nil, successCallback)
end

PlayerDictionaryData.UpdateDictionarySubRedDot = function(self, nTabId, nIndex, nStatus)
  -- function num : 0_8 , upvalues : _ENV, Status
  (RedDotManager.SetValid)(RedDotDefine.Dictionary_Sub, {nTabId, nIndex}, nStatus == Status.Unreceived)
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

return PlayerDictionaryData

