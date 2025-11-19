local PlayerBattlePassData = class("PlayerBattlePassData")
PlayerBattlePassData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.nSeasonId = 0
  self.nCurMode = 0
  self.nVersion = 0
  self.nDeadlineTS = 0
  self.nLevel = 0
  self.nExp = 0
  self.nMaxLevel = 0
  self.nExpThisWeek = 0
  self.tbBaseReward = nil
  self.tbPremiumReward = nil
  self.hasData = false
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  ;
  (EventManager.Add)("BattlePassNeedRefresh", self, self.OnEvent_NeedRefresh)
  self:InitConfig()
end

PlayerBattlePassData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

PlayerBattlePassData.InitConfig = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local forEachBattlePassLevel = function(mapData)
    -- function num : 0_2_0 , upvalues : self
    if self.nMaxLevel < mapData.ID then
      self.nMaxLevel = mapData.ID
    end
  end

  ForEachTableLine(DataTable.BattlePassLevel, forEachBattlePassLevel)
  self.mapBattlePassName = {}
  local func_ForEach_Line = function(mapData)
    -- function num : 0_2_1 , upvalues : self, _ENV
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R1 in 'UnsetPending'

    (self.mapBattlePassName)[mapData.LuxuryProductId] = (ConfigTable.GetUIText)("BattlePassRewardLuxury")
    -- DECOMPILER ERROR at PC13: Confused about usage of register: R1 in 'UnsetPending'

    ;
    (self.mapBattlePassName)[mapData.PremiumProductId] = (ConfigTable.GetUIText)("BattlePassRewardPremium")
    -- DECOMPILER ERROR at PC20: Confused about usage of register: R1 in 'UnsetPending'

    ;
    (self.mapBattlePassName)[mapData.ComplementaryProductId] = (ConfigTable.GetUIText)("BattlePassRewardLuxury")
  end

  ForEachTableLine(DataTable.BattlePass, func_ForEach_Line)
end

PlayerBattlePassData.CacheBattlePassInfo = function(self, mapData)
  -- function num : 0_3 , upvalues : _ENV
  if mapData == nil then
    return 
  end
  print("当前赛季ID：" .. mapData.Id)
  self.nSeasonId = mapData.Id
  self.nCurMode = mapData.Mode
  self.nVersion = mapData.Version
  self.nDeadlineTS = mapData.Deadline
  self.nLevel = mapData.Level
  self.nExp = mapData.Exp
  self.nExpThisWeek = mapData.ExpThisWeek
  self.tbBaseReward = (UTILS.ParseByteString)(mapData.BasicReward)
  self.tbPremiumReward = (UTILS.ParseByteString)(mapData.PremiumReward)
  local nExpLimit = (ConfigTable.GetConfigNumber)("BattlePassWeeklyExpLimit")
  if nExpLimit < self.nExpThisWeek then
    self.nExpThisWeek = self.nExpThisWeek
  end
  self:UpdateRewardRedDot()
  ;
  (RedDotManager.SetValid)(RedDotDefine.BattlePass_Quest_Server, nil, false)
  if mapData.DailyQuests ~= nil then
    (PlayerData.Quest):CacheAllQuest((mapData.DailyQuests).List)
  end
  if mapData.WeeklyQuests ~= nil then
    (PlayerData.Quest):CacheAllQuest((mapData.WeeklyQuests).List)
  end
  self.hasData = true
end

PlayerBattlePassData.UpdateQuestRedDot = function(self, bCanDailyReceive, bCanWeekReceive)
  -- function num : 0_4 , upvalues : _ENV
  local nExpLimit = (ConfigTable.GetConfigNumber)("BattlePassWeeklyExpLimit")
  self.nExpThisWeek = self.nExpThisWeek
  if nExpLimit <= self.nExpThisWeek then
    (RedDotManager.SetValid)(RedDotDefine.BattlePass_Quest_Daily, nil, false)
    ;
    (RedDotManager.SetValid)(RedDotDefine.BattlePass_Quest_Week, nil, false)
  else
    local bMaxLevel = self.nMaxLevel <= self.nLevel
    if bCanDailyReceive then
      (RedDotManager.SetValid)(RedDotDefine.BattlePass_Quest_Daily, nil, not bMaxLevel)
      if bCanWeekReceive then
        do
          (RedDotManager.SetValid)(RedDotDefine.BattlePass_Quest_Week, nil, not bMaxLevel)
          -- DECOMPILER ERROR: 4 unprocessed JMP targets
        end
      end
    end
  end
end

PlayerBattlePassData.UpdateRewardRedDot = function(self)
  -- function num : 0_5 , upvalues : _ENV
  local bCanReceive = false
  local mapReward = {}
  local nRewardCount = 0
  local foreachReward = function(mapData)
    -- function num : 0_5_0 , upvalues : self, mapReward, nRewardCount
    if mapData.ID == self.nSeasonId then
      mapReward[mapData.Level] = mapData
      nRewardCount = nRewardCount + 1
    end
  end

  ForEachTableLine(DataTable.BattlePassReward, foreachReward)
  for i = 1, nRewardCount do
    if mapReward[i] ~= nil then
      local bNormalReceive = (UTILS.IsBitSet)(self.tbBaseReward, i)
      local bVipReceive = (UTILS.IsBitSet)(self.tbPremiumReward, i)
      if i <= self.nLevel and (not bNormalReceive or self.nCurMode <= 0 or not bVipReceive) then
        bCanReceive = true
        break
      end
    end
  end
  do
    ;
    (RedDotManager.SetValid)(RedDotDefine.BattlePass_Reward, nil, bCanReceive)
    local nExpLimit = (ConfigTable.GetConfigNumber)("BattlePassWeeklyExpLimit")
    if self.nMaxLevel <= self.nLevel or nExpLimit <= self.nExpThisWeek then
      (RedDotManager.SetValid)(RedDotDefine.BattlePass_Quest_Week, nil, false)
      ;
      (RedDotManager.SetValid)(RedDotDefine.BattlePass_Quest_Daily, nil, false)
    end
  end
end

PlayerBattlePassData.OnPremiumBuySuccess = function(self, mapData)
  -- function num : 0_6 , upvalues : _ENV
  if self.nLevel ~= mapData.Level then
    local mapLevelData = {nOldLevel = self.nLevel, nOldExp = self.nExp, nLevel = mapData.Level, nExp = self.nExp}
    do
      local callback = function()
    -- function num : 0_6_0 , upvalues : _ENV, self, callback, mapData, mapLevelData
    (EventManager.Remove)("MallOrderClear", self, callback)
    local levelupCallback = function()
      -- function num : 0_6_0_0 , upvalues : _ENV, mapData
      local mapReward = (PlayerData.Item):ProcessRewardChangeInfo((mapData.CollectResp).Items)
      local tbSelectedItem = {}
      for _,mapItemData in ipairs(mapReward.tbReward) do
        local mapItemCfgData = (ConfigTable.GetData_Item)(mapItemData.id)
        if mapItemCfgData ~= nil and mapItemCfgData.Stype == (GameEnum.itemStype).OutfitCYO then
          (table.insert)(tbSelectedItem, mapItemData.id)
        end
      end
      if #tbSelectedItem > 0 then
        (EventManager.Hit)(EventId.OpenPanel, PanelId.Consumable, tbSelectedItem)
      end
      ;
      (EventManager.Hit)("BattlePassLevelUpPanelClose")
    end

    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.BattlePassUpgrade, levelupCallback, mapLevelData)
  end

      ;
      (EventManager.Add)("MallOrderClear", self, callback)
    end
  else
    do
      do
        local callback = function()
    -- function num : 0_6_1 , upvalues : _ENV, self, callback, mapData
    (EventManager.Remove)("MallOrderClear", self, callback)
    if mapData.Mode == 1 then
      local msg = {nType = (AllEnum.MessageBox).Alert, sContent = (ConfigTable.GetUIText)("BattlePassRewardPremium_ReceiveTip")}
      ;
      (EventManager.Hit)(EventId.OpenMessageBox, msg)
    end
  end

        ;
        (EventManager.Add)("MallOrderClear", self, callback)
        self.nVersion = mapData.Version
        self.nCurMode = mapData.Mode
        self.nLevel = mapData.Level
        self:UpdateRewardRedDot()
        ;
        (EventManager.Hit)("BattlePassPremiumSuccess")
      end
    end
  end
end

PlayerBattlePassData.OnQuestReceive = function(self, msgData)
  -- function num : 0_7 , upvalues : _ENV
  self.nLevel = msgData.Level
  self.nExp = msgData.Exp
  local nExpLimit = (ConfigTable.GetConfigNumber)("BattlePassWeeklyExpLimit")
  self.nExpThisWeek = msgData.ExpThisWeek
  if nExpLimit < self.nExpThisWeek then
    self.nExpThisWeek = self.nExpThisWeek
  end
  self:UpdateRewardRedDot()
end

PlayerBattlePassData.GetBattlePassName = function(self, sId)
  -- function num : 0_8
  return (self.mapBattlePassName)[sId]
end

PlayerBattlePassData.OnEvent_NewDay = function(self)
  -- function num : 0_9
  self.hasData = false
end

PlayerBattlePassData.OnEvent_NeedRefresh = function(self)
  -- function num : 0_10
  self.hasData = false
end

PlayerBattlePassData.NetMsg_BuyBattlePassLevel = function(self, nLevel, callback)
  -- function num : 0_11 , upvalues : _ENV
  local msg = {Value = nLevel, Version = self.nVersion}
  local mapLevelData = {nOldLevel = self.nLevel, nOldExp = self.nExp}
  local msgCallback = function(_, msgData)
    -- function num : 0_11_0 , upvalues : self, mapLevelData, _ENV, callback
    self.nLevel = msgData.Level
    mapLevelData.nLevel = self.nLevel
    mapLevelData.nExp = self.nExp
    local callabck = function()
      -- function num : 0_11_0_0 , upvalues : _ENV
      (EventManager.Hit)("BattlePassLevelUpPanelClose")
    end

    ;
    (EventManager.Hit)(EventId.OpenPanel, PanelId.BattlePassUpgrade, callabck, mapLevelData)
    ;
    (EventManager.Hit)("BattlePassBuyLevel")
    if callback ~= nil and type(callback) == "function" then
      callback()
    end
    self:UpdateRewardRedDot()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).battle_pass_level_buy_req, msg, nil, msgCallback)
end

PlayerBattlePassData.NetMsg_BattlePassRewardReceive = function(self, bAll, nLevel, bBasic, callback)
  -- function num : 0_12 , upvalues : _ENV
  local msg = {}
  if bAll then
    msg.All = {}
  else
    if bBasic then
      msg.Basic = nLevel
    else
      msg.Premium = nLevel
    end
  end
  msg.Version = self.nVersion
  local msgCallback = function(_, msgData)
    -- function num : 0_12_0 , upvalues : self, _ENV, callback
    self.tbBaseReward = (UTILS.ParseByteString)(msgData.BasicReward)
    self.tbPremiumReward = (UTILS.ParseByteString)(msgData.PremiumReward)
    ;
    (EventManager.Hit)("UpdateBattlePassReward", msgData.Change)
    self:UpdateRewardRedDot()
    if callback ~= nil and type(callback) == "function" then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).battle_pass_reward_receive_req, msg, nil, msgCallback)
end

PlayerBattlePassData.GetBattlePassInfo = function(self, callback)
  -- function num : 0_13 , upvalues : _ENV
  local GetMsgCallback = function()
    -- function num : 0_13_0 , upvalues : self, _ENV, callback
    if not self.hasData then
      printError("未获取到战令数据")
      return 
    end
    local mapRet = {}
    local mapReward = {}
    local nRewardCount = 0
    local foreachReward = function(mapData)
      -- function num : 0_13_0_0 , upvalues : self, mapReward, nRewardCount
      if mapData.ID == self.nSeasonId then
        mapReward[mapData.Level] = mapData
        nRewardCount = nRewardCount + 1
      end
    end

    ForEachTableLine(DataTable.BattlePassReward, foreachReward)
    mapRet.nSeasonId = self.nSeasonId
    mapRet.nCurMode = self.nCurMode
    mapRet.nVersion = self.nVersion
    mapRet.nDeadlineTS = self.nDeadlineTS
    mapRet.nLevel = self.nLevel
    mapRet.nExp = self.nExp
    mapRet.nExpThisWeek = self.nExpThisWeek
    mapRet.tbReward = {}
    for i = 1, nRewardCount do
      if mapReward[i] ~= nil then
        local bNormalReceive = (UTILS.IsBitSet)(self.tbBaseReward, i)
        local bVipReceive = (UTILS.IsBitSet)(self.tbPremiumReward, i)
        ;
        (table.insert)(mapRet.tbReward, {nLevel = i, nNormalTid = (mapReward[i]).Tid1, nNormalQty = (mapReward[i]).Qty1, nVipTid1 = (mapReward[i]).Tid2, nVipQty1 = (mapReward[i]).Qty2, nVipTid2 = (mapReward[i]).Tid3, nVipQty2 = (mapReward[i]).Qty3, bNormalReceive = bNormalReceive, bVipReceive = bVipReceive, bFocus = (mapReward[i]).Focus})
      end
    end
    callback(mapRet)
  end

  if self.hasData then
    GetMsgCallback()
  else
    ;
    (HttpNetHandler.SendMsg)((NetMsgId.Id).battle_pass_info_req, {}, nil, GetMsgCallback)
  end
end

PlayerBattlePassData.GetRefreshTime = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if self.nSeasonId == 0 then
    return "-"
  end
  local mapSeasonCfgData = (ConfigTable.GetData)("BattlePass", self.nSeasonId)
  if mapSeasonCfgData == nil then
    return "-"
  end
  local nEndTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(mapSeasonCfgData.EndTime)
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  local remainTime = nEndTime - curTime
  if remainTime < 0 then
    return "-"
  end
  local sTimeStr = "-"
  local remainTime = nEndTime - curTime
  if remainTime >= 86400 then
    local day = (math.floor)(remainTime / 86400)
    local hour = (math.floor)((remainTime - day * 86400) / 3600)
    if hour == 0 then
      day = day - 1
      hour = 24
    end
    sTimeStr = orderedFormat((ConfigTable.GetUIText)("Energy_LeftTime_Day"), day, hour)
  else
    do
      if remainTime >= 3600 then
        local hour = (math.floor)(remainTime / 3600)
        local min = (math.floor)((remainTime - hour * 3600) / 60)
        if min == 0 then
          hour = hour - 1
          min = 60
        end
        sTimeStr = orderedFormat((ConfigTable.GetUIText)("Energy_LeftTime_Hour"), hour, min)
      else
        do
          sTimeStr = (ConfigTable.GetUIText)("Energy_LeftTime_LessThenHour")
          return sTimeStr
        end
      end
    end
  end
end

PlayerBattlePassData.GetHasBattlePass = function(self)
  -- function num : 0_15 , upvalues : _ENV
  if self.nSeasonId <= 0 then
    do return not self.hasData end
    local IsOpenCardPool = function(sStartTime, sEndTime)
    -- function num : 0_15_0 , upvalues : _ENV
    if (string.len)(sStartTime) == 0 or (string.len)(sEndTime) == 0 then
      return true
    end
    local nowTime = ((CS.ClientManager).Instance).serverTimeStamp
    do return String2Time(sStartTime) < nowTime and nowTime < String2Time(sEndTime) end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end

    do
      local ret = false
      local func_ForEach_Gacha = function(mapGacha)
    -- function num : 0_15_1 , upvalues : IsOpenCardPool, ret
    if IsOpenCardPool(mapGacha.StartTime, mapGacha.EndTime) then
      ret = true
    end
  end

      ForEachTableLine(DataTable.BattlePass, func_ForEach_Gacha)
      return ret
    end
    -- DECOMPILER ERROR: 3 unprocessed JMP targets
  end
end

PlayerBattlePassData.GetMaxLevel = function(self)
  -- function num : 0_16
  return self.nMaxLevel
end

return PlayerBattlePassData

