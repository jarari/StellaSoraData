local PlayerStorySetData = class("PlayerStorySetData")
PlayerStorySetData.Init = function(self)
  -- function num : 0_0
  self.tbChapter = {}
  self.bGetData = false
  self:InitConfig()
end

PlayerStorySetData.InitConfig = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local funcForeachSection = function(mapData)
    -- function num : 0_1_0 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

    if (self.tbChapter)[mapData.ChapterId] == nil then
      (self.tbChapter)[mapData.ChapterId] = {}
      -- DECOMPILER ERROR at PC13: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self.tbChapter)[mapData.ChapterId]).tbSectionList = {}
      -- DECOMPILER ERROR at PC17: Confused about usage of register: R1 in 'UnsetPending'

      ;
      ((self.tbChapter)[mapData.ChapterId]).bUnlock = false
    end
    ;
    (table.insert)(((self.tbChapter)[mapData.ChapterId]).tbSectionList, {nId = mapData.Id, nSortId = mapData.SortId, nStatus = (AllEnum.StorySetStatus).Lock})
  end

  ForEachTableLine((ConfigTable.Get)("StorySetSection"), funcForeachSection)
  for _,v in pairs(self.tbChapter) do
    if v.tbSectionList ~= nil then
      (table.sort)(v.tbSectionList, function(a, b)
    -- function num : 0_1_1
    do return a.nId < b.nId end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
    end
  end
end

PlayerStorySetData.UnInit = function(self)
  -- function num : 0_2
end

PlayerStorySetData.UpdateStorySetState = function(self, bState)
  -- function num : 0_3 , upvalues : _ENV
  (RedDotManager.SetValid)(RedDotDefine.Story_Set_Server, nil, bState)
end

PlayerStorySetData.CacheStorySetData = function(self, netMsg)
  -- function num : 0_4 , upvalues : _ENV
  if netMsg.Chapters ~= nil then
    for _,data in ipairs(netMsg.Chapters) do
      -- DECOMPILER ERROR at PC15: Confused about usage of register: R7 in 'UnsetPending'

      if (self.tbChapter)[data.ChapterId] ~= nil then
        ((self.tbChapter)[data.ChapterId]).bUnlock = true
        local nCurIndex = data.SectionIndex or 0
        nCurIndex = nCurIndex + 1
        local bShow = false
        local mapChapterCfg = (ConfigTable.GetData)("StorySetChapter", data.ChapterId)
        if mapChapterCfg ~= nil then
          bShow = mapChapterCfg.IsShow
        end
        for nIndex,v in ipairs(((self.tbChapter)[data.ChapterId]).tbSectionList) do
          if nIndex <= nCurIndex then
            v.nStatus = (AllEnum.StorySetStatus).UnLock
          end
          if (table.indexof)(data.RewardedIds, v.nId) > 0 then
            v.nStatus = (AllEnum.StorySetStatus).Received
          end
          ;
          (RedDotManager.SetValid)(RedDotDefine.Story_Set_Section, {data.ChapterId, v.nId}, (v.nStatus == (AllEnum.StorySetStatus).UnLock and bShow))
        end
      end
    end
  end
  -- DECOMPILER ERROR: 5 unprocessed JMP targets
end

PlayerStorySetData.UnlockNewChapter = function(self, nId)
  -- function num : 0_5 , upvalues : _ENV
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbChapter)[nId] ~= nil then
    ((self.tbChapter)[nId]).bUnlock = true
    local bShow = false
    local mapCfg = (ConfigTable.GetData)("StorySetChapter", nId)
    if mapCfg ~= nil then
      bShow = mapCfg.IsShow
    end
    for k,v in ipairs(((self.tbChapter)[nId]).tbSectionList) do
      if k == 1 then
        v.nStatus = (AllEnum.StorySetStatus).UnLock
        ;
        (RedDotManager.SetValid)(RedDotDefine.Story_Set_Section, {nId, v.nId}, bShow)
        break
      end
    end
  end
end

PlayerStorySetData.GetAllChapterList = function(self)
  -- function num : 0_6 , upvalues : _ENV
  local tbChapter = {}
  for nId,v in pairs(self.tbChapter) do
    local mapCfg = (ConfigTable.GetData)("StorySetChapter", nId)
    if mapCfg ~= nil and mapCfg.IsShow then
      (table.insert)(tbChapter, {nId = nId, tbSectionList = v.tbSectionList, bUnlock = v.bUnlock})
    end
  end
  ;
  (table.sort)(tbChapter, function(a, b)
    -- function num : 0_6_0
    do return a.nId < b.nId end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return tbChapter
end

PlayerStorySetData.TryOpenStorySetPanel = function(self, callback)
  -- function num : 0_7
  if not self.bGetData then
    self:SendGetStorySetData(callback)
  else
    if callback ~= nil then
      callback()
    end
  end
end

PlayerStorySetData.SendGetStorySetData = function(self, callback)
  -- function num : 0_8 , upvalues : _ENV
  local func_cb = function(_, netMsg)
    -- function num : 0_8_0 , upvalues : _ENV, callback
    (RedDotManager.SetValid)(RedDotDefine.Story_Set_Server, nil, false)
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).story_set_info_req, {}, nil, func_cb)
end

PlayerStorySetData.ReceiveStorySetReward = function(self, nChapterId, nSectionId, callback)
  -- function num : 0_9 , upvalues : _ENV
  local func_cb = function(_, netMsg)
    -- function num : 0_9_0 , upvalues : self, nChapterId, _ENV, nSectionId, callback
    if (self.tbChapter)[nChapterId] ~= nil then
      local nIndex = 0
      for k,v in ipairs(((self.tbChapter)[nChapterId]).tbSectionList) do
        if v.nId == nSectionId then
          nIndex = k
          break
        end
      end
      do
        -- DECOMPILER ERROR at PC31: Confused about usage of register: R3 in 'UnsetPending'

        if nIndex ~= 0 then
          ((((self.tbChapter)[nChapterId]).tbSectionList)[nIndex]).nStatus = (AllEnum.StorySetStatus).Received
          ;
          (RedDotManager.SetValid)(RedDotDefine.Story_Set_Section, {nChapterId, nSectionId}, false)
          nIndex = nIndex + 1
        end
        -- DECOMPILER ERROR at PC58: Confused about usage of register: R3 in 'UnsetPending'

        if nIndex <= #((self.tbChapter)[nChapterId]).tbSectionList then
          ((((self.tbChapter)[nChapterId]).tbSectionList)[nIndex]).nStatus = (AllEnum.StorySetStatus).UnLock
          local bShow = false
          local mapCfg = (ConfigTable.GetData)("StorySetChapter", nChapterId)
          if mapCfg ~= nil then
            bShow = mapCfg.IsShow
          end
          local nId = ((((self.tbChapter)[nChapterId]).tbSectionList)[nIndex]).nId
          ;
          (RedDotManager.SetValid)(RedDotDefine.Story_Set_Section, {nChapterId, nId}, bShow)
        end
        do
          if callback ~= nil then
            callback(netMsg)
          end
          ;
          (EventManager.Hit)("ReceiveStorySetRewardSuc")
        end
      end
    end
  end

  local msg = {ChapterId = nChapterId, SectionId = nSectionId}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).story_set_reward_receive_req, msg, nil, func_cb)
end

return PlayerStorySetData

