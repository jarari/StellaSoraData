local PlayerActivityData = class("PlayerActivityData")
local PeriodicQuestActData = require("GameCore.Data.DataClass.Activity.PeriodicQuestActData")
local LoginRewardActData = require("GameCore.Data.DataClass.Activity.LoginRewardActData")
local MiningGameData = require("GameCore.Data.DataClass.Activity.MiningGameData")
local TrialActData = require("GameCore.Data.DataClass.Activity.TrialActData")
local CookieActData = require("GameCore.Data.DataClass.Activity.CookieActData")
local TowerDefenseData = require("GameCore.Data.DataClass.Activity.TowerDefenseData")
local JointDrillActData = require("GameCore.Data.DataClass.Activity.JointDrillActData")
local ActivityLevelTypeData = require("GameCore.Data.DataClass.Activity.ActivityLevelTypeData")
local ActivityTaskData = require("GameCore.Data.DataClass.Activity.ActivityTaskData")
local ActivityShopData = require("GameCore.Data.DataClass.Activity.ActivityShopData")
local AdvertiseActData = require("GameCore.Data.DataClass.Activity.AdvertiseActData")
local LocalData = require("GameCore.Data.LocalData")
local SwimThemeData = require("GameCore.Data.DataClass.Activity.SwimThemeData")
local OurRegiment_10101Data = require("GameCore.Data.DataClass.Activity.OurRegiment_10101Data")
local Dream_10102Data = require("GameCore.Data.DataClass.Activity.Dream_10102Data")
local TimerManager = require("GameCore.Timer.TimerManager")
local BdConvertData = require("GameCore.Data.DataClass.Activity.BdConvertData")
local BreakOut_30101Data = require("GameCore.Data.DataClass.Activity.BreakOut_30101Data")
local BreakOutData = require("GameCore.Data.DataClass.Activity.BreakOutData")
PlayerActivityData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.bCacheActData = false
  self.tbAllActivity = {}
  self.tbAllActivityGroup = {}
  self.tbActivityPopUp = {}
  self.tbLoginRewardPopUp = {}
  self.tbReadedCG = {}
  self:InitActivityCfg()
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  ;
  (EventManager.Add)(EventId.UpdateWorldClass, self, self.OnEvent_UpdateWorldClass)
  ;
  (EventManager.Add)("Story_RewardClosed", self, self.OnEvent_StoryEnd)
end

PlayerActivityData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  ;
  (EventManager.Remove)(EventId.UpdateWorldClass, self, self.OnEvent_UpdateWorldClass)
  ;
  (EventManager.Remove)("Story_RewardClosed", self, self.OnEvent_StoryEnd)
end

PlayerActivityData.InitActivityCfg = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local foreachTableLine = function(line)
    -- function num : 0_2_0 , upvalues : _ENV
    if (CacheTable.GetData)("_PeriodicQuestGroup", line.Belong) == nil then
      (CacheTable.SetData)("_PeriodicQuestGroup", line.Belong, {})
    end
    if ((CacheTable.GetData)("_PeriodicQuestGroup", line.Belong))[line.UnlockTime + 1] == nil then
      ((CacheTable.GetData)("_PeriodicQuestGroup", line.Belong))[line.UnlockTime + 1] = {}
    end
    ;
    (table.insert)(((CacheTable.GetData)("_PeriodicQuestGroup", line.Belong))[line.UnlockTime + 1], line.GroupId)
    if (CacheTable.GetData)("_PeriodicQuestDay", line.Belong) == nil then
      (CacheTable.SetData)("_PeriodicQuestDay", line.Belong, {})
    end
    ;
    ((CacheTable.GetData)("_PeriodicQuestDay", line.Belong))[line.GroupId] = line.UnlockTime + 1
    if (CacheTable.GetData)("_PeriodicQuestMaxDay", line.Belong) == nil then
      (CacheTable.SetData)("_PeriodicQuestMaxDay", line.Belong, 0)
    end
    if (CacheTable.GetData)("_PeriodicQuestMaxDay", line.Belong) < line.UnlockTime + 1 then
      (CacheTable.SetData)("_PeriodicQuestMaxDay", line.Belong, line.UnlockTime + 1)
    end
  end

  ForEachTableLine(DataTable.PeriodicQuestGroup, foreachTableLine)
  local foreachTableLine = function(line)
    -- function num : 0_2_1 , upvalues : _ENV
    (CacheTable.InsertData)("_PeriodicQuest", line.Belong, line)
  end

  ForEachTableLine(DataTable.PeriodicQuest, foreachTableLine)
  local foreachLoginRewardGroup = function(line)
    -- function num : 0_2_2 , upvalues : _ENV
    (CacheTable.InsertData)("_LoginRewardGroup", line.RewardGroupId, line)
  end

  ForEachTableLine(DataTable.LoginRewardGroup, foreachLoginRewardGroup)
  local foreachTableLine = function(line)
    -- function num : 0_2_3 , upvalues : _ENV
    (CacheTable.SetData)("_ActivityTaskControl", line.ActivityId, line)
  end

  ForEachTableLine(DataTable.ActivityTaskControl, foreachTableLine)
end

PlayerActivityData.CacheAllActivityData = function(self, mapNetMsg)
  -- function num : 0_3 , upvalues : _ENV, ActivityTaskData
  if mapNetMsg.List ~= nil then
    for _,v in ipairs(mapNetMsg.List) do
      local nActId = v.Id
      local actCfg = (ConfigTable.GetData)("Activity", nActId)
      if actCfg ~= nil and actCfg.ActivityType == (GameEnum.activityType).Avg then
        self:RefreshActivityAvgData(nActId, v.Avg)
      end
      if actCfg ~= nil then
        if actCfg.ActivityType == (GameEnum.activityType).PeriodicQuest then
          self:RefreshPeriodicActQuest(nActId, v.Periodic)
        else
          if actCfg.ActivityType == (GameEnum.activityType).LoginReward then
            self:RefreshLoginRewardActData(nActId, v.Login)
          else
            if actCfg.ActivityType == (GameEnum.activityType).Mining then
              self:RefreshMiningGameActData(nActId, v.Mining)
            else
              if actCfg.ActivityType == (GameEnum.activityType).Cookie then
                self:RefreshCookieGameActData(nActId, v.Cookie)
              else
                if actCfg.ActivityType == (GameEnum.activityType).TowerDefense then
                  self:RefreshTowerDefenseActData(nActId, v.TowerDefense)
                else
                  if actCfg.ActivityType == (GameEnum.activityType).JointDrill then
                    self:RefreshJointDrillActData(nActId, v.JointDrill)
                  else
                    if actCfg.ActivityType == (GameEnum.activityType).Levels then
                      self:RefreshActivityLevelGameActData(nActId, v.Levels)
                    else
                      if actCfg.ActivityType == (GameEnum.activityType).Trial then
                        self:RefreshTrialActData(nActId, v.Trial)
                      else
                        if actCfg.ActivityType == (GameEnum.activityType).CG then
                          self:RefreshActivityCGData(v.CG)
                        else
                          if actCfg.ActivityType == (GameEnum.activityType).Task then
                            local actIns = (self.tbAllActivity)[nActId]
                            do
                              do
                                do
                                  if actIns == nil then
                                    local mapActData = {}
                                    mapActData.Id = nActId
                                    mapActData.StartTime = 0
                                    mapActData.EndTime = 0
                                    actIns = (ActivityTaskData.new)(mapActData)
                                    -- DECOMPILER ERROR at PC144: Confused about usage of register: R11 in 'UnsetPending'

                                    ;
                                    (self.tbAllActivity)[nActId] = actIns
                                  end
                                  actIns:CacheData(v.Task)
                                  ;
                                  (EventManager.Hit)("RefreshActivityTask")
                                  if actCfg.ActivityType == (GameEnum.activityType).Shop then
                                    self:RefreshActivityShopData(nActId, v.Shop)
                                  else
                                    if actCfg.ActivityType == (GameEnum.activityType).Advertise then
                                      self:RefreshInfinityTowerActData(nActId, v.Shop)
                                    else
                                      if actCfg.ActivityType == (GameEnum.activityType).BDConvert then
                                        self:RefreshBdConvertData(nActId, v.BdConvert)
                                      else
                                        if actCfg.ActivityType == (GameEnum.activityType).Breakout then
                                          self:RefreshBreakoutData(nActId, v.Breakout)
                                        end
                                      end
                                    end
                                  end
                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out DO_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out DO_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_THEN_STMT

                                  -- DECOMPILER ERROR at PC196: LeaveBlock: unexpected jumping out IF_STMT

                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  self:RefreshLoginRewardPopUpList()
  self:RefreshActivityRedDot()
end

PlayerActivityData.CacheActivityData = function(self, mapNetMsg)
  -- function num : 0_4 , upvalues : _ENV
  if mapNetMsg == nil then
    return 
  end
  for _,v in ipairs(mapNetMsg) do
    self:CreateActivityIns(v)
  end
end

PlayerActivityData.UpdateActivityState = function(self, mapNetMsg)
  -- function num : 0_5 , upvalues : _ENV
  if mapNetMsg == nil then
    return 
  end
  for _,v in ipairs(mapNetMsg) do
    if (self.tbAllActivity)[v.Id] ~= nil then
      ((self.tbAllActivity)[v.Id]):UpdateActivityState(v)
    end
  end
  self:RefreshPopUpList()
  self:RefreshActivityRedDot()
end

PlayerActivityData.RefreshActivityData = function(self, mapNetMsg)
  -- function num : 0_6
  if (self.tbAllActivity)[mapNetMsg.Id] == nil then
    self:CreateActivityIns(mapNetMsg)
    self:SendActivityDetailMsg(nil, true)
  else
    ;
    ((self.tbAllActivity)[mapNetMsg.Id]):RefreshActivityData(mapNetMsg)
  end
  self:RefreshPopUpList()
  self:RefreshActivityRedDot()
end

PlayerActivityData.RefreshActivityStateData = function(self, mapNetMsg)
  -- function num : 0_7
  if (self.tbAllActivity)[mapNetMsg.Id] ~= nil then
    ((self.tbAllActivity)[mapNetMsg.Id]):RefreshStateData(mapNetMsg.RedDot, mapNetMsg.Banner)
    self:RefreshActivityRedDot()
  end
end

PlayerActivityData.RefreshActStatus = function(self)
  -- function num : 0_8 , upvalues : _ENV
  for _,actData in pairs(self.tbAllActivity) do
    local bPlay = actData:GetPlayState()
    if not bPlay then
      actData:RefreshPlayState()
      local bPlay_new = actData:GetPlayState()
      if bPlay_new then
        actData:UpdateStatus()
      end
    end
  end
end

PlayerActivityData.CreateActivityIns = function(self, actData)
  -- function num : 0_9 , upvalues : _ENV, PeriodicQuestActData, LoginRewardActData, MiningGameData, TrialActData, CookieActData, TowerDefenseData, JointDrillActData, ActivityLevelTypeData, ActivityTaskData, ActivityShopData, AdvertiseActData, BdConvertData, BreakOutData
  local actIns = nil
  local actCfg = (ConfigTable.GetData)("Activity", actData.Id)
  if actCfg == nil then
    return 
  end
  if actCfg.ActivityType == (GameEnum.activityType).PeriodicQuest then
    actIns = (PeriodicQuestActData.new)(actData)
  else
    if actCfg.ActivityType == (GameEnum.activityType).LoginReward then
      actIns = (LoginRewardActData.new)(actData)
    else
      if actCfg.ActivityType == (GameEnum.activityType).Mining then
        actIns = (MiningGameData.new)(actData)
      else
        if actCfg.ActivityType == (GameEnum.activityType).Trial then
          actIns = (TrialActData.new)(actData)
        else
          if actCfg.ActivityType == (GameEnum.activityType).Cookie then
            actIns = (CookieActData.new)(actData)
          else
            if actCfg.ActivityType == (GameEnum.activityType).TowerDefense then
              actIns = (TowerDefenseData.new)(actData)
            else
              if actCfg.ActivityType == (GameEnum.activityType).JointDrill then
                actIns = (JointDrillActData.new)(actData)
              else
                if actCfg.ActivityType == (GameEnum.activityType).Levels then
                  actIns = (ActivityLevelTypeData.new)(actData)
                else
                  if actCfg.ActivityType == (GameEnum.activityType).Avg then
                    (PlayerData.ActivityAvg):CacheActivityAvgData(actData)
                  else
                    if actCfg.ActivityType == (GameEnum.activityType).Task then
                      actIns = (ActivityTaskData.new)(actData)
                    else
                      if actCfg.ActivityType == (GameEnum.activityType).Shop then
                        actIns = (ActivityShopData.new)(actData)
                      else
                        if actCfg.ActivityType == (GameEnum.activityType).Advertise then
                          actIns = (AdvertiseActData.new)(actData)
                        else
                          if actCfg.ActivityType == (GameEnum.activityType).BDConvert then
                            actIns = (BdConvertData.new)(actData)
                          else
                            if actCfg.ActivityType == (GameEnum.activityType).Breakout then
                              actIns = (BreakOutData.new)(actData)
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  -- DECOMPILER ERROR at PC167: Confused about usage of register: R4 in 'UnsetPending'

  if actIns ~= nil then
    (self.tbAllActivity)[actData.Id] = actIns
  end
end

PlayerActivityData.RefreshActivityRedDot = function(self)
  -- function num : 0_10 , upvalues : _ENV, LocalData
  local bHasNewRedDot = false
  for _,v in pairs(self.tbAllActivity) do
    if v:CheckActShow() then
      (RedDotManager.SetValid)(RedDotDefine.Activity_Tab, v:GetActId(), v:GetActivityRedDot())
      if type(v.RefreshRedDot) == "function" then
        v:RefreshRedDot()
      end
      local bInActGroup = false
      if (v:GetActCfgData()).ActivityThemeType > 0 or self:IsActivityInActivityGroup(v:GetActId()) then
        bInActGroup = true
      end
      if not bInActGroup and v:CheckActShow() then
        local bTabRedDot = (RedDotManager.GetValid)(RedDotDefine.Activity_Tab, v:GetActId())
        local sData = (LocalData.GetPlayerLocalData)("Activity_Tab_New_" .. v:GetActId())
        local nValue = tonumber(sData == nil and "0" or sData)
        local bNewRedDot = (nValue == 0 and not bTabRedDot)
        if bNewRedDot then
          bHasNewRedDot = true
        end
        ;
        (RedDotManager.SetValid)(RedDotDefine.Activity_New_Tab, v:GetActId(), bNewRedDot)
      end
      -- DECOMPILER ERROR at PC82: LeaveBlock: unexpected jumping out IF_THEN_STMT

      -- DECOMPILER ERROR at PC82: LeaveBlock: unexpected jumping out IF_STMT

    end
  end
  local bHasGroupNewRedDot = false
  for nId,v in pairs(self.tbAllActivityGroup) do
    if v:CheckActGroupShow() and (RedDotManager.GetValid)(RedDotDefine.Activity_New_Tab, nId) then
      bHasGroupNewRedDot = true
    end
  end
  local bHasRedDot = (RedDotManager.GetValid)(RedDotDefine.Activity)
  ;
  (RedDotManager.SetValid)(RedDotDefine.Activity_New, nil, (bHasRedDot or not bHasNewRedDot) and bHasGroupNewRedDot)
  -- DECOMPILER ERROR: 7 unprocessed JMP targets
end

PlayerActivityData.GetActivityList = function(self)
  -- function num : 0_11
  return self.tbAllActivity
end

PlayerActivityData.GetSortedActList = function(self)
  -- function num : 0_12 , upvalues : _ENV
  local tbActList = {}
  for k,v in pairs(self.tbAllActivity) do
    if v:CheckActShow() then
      local bInActGroup = false
      if (v:GetActCfgData()).ActivityThemeType > 0 or self:IsActivityInActivityGroup(v:GetActId()) then
        bInActGroup = true
      end
      if not bInActGroup then
        (table.insert)(tbActList, v)
      end
    end
  end
  ;
  (table.sort)(tbActList, function(a, b)
    -- function num : 0_12_0
    if a:GetActId() >= b:GetActId() then
      do return a:GetActSortId() ~= b:GetActSortId() end
      do return a:GetActSortId() < b:GetActSortId() end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
  return tbActList
end

PlayerActivityData.GetActivityDataById = function(self, nActId)
  -- function num : 0_13
  return (self.tbAllActivity)[nActId] or nil
end

PlayerActivityData.CacheActivityGroupData = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local foreachActGroup = function(mapData)
    -- function num : 0_14_0 , upvalues : self
    self:CreateActivityGroupIns(mapData)
  end

  ForEachTableLine((ConfigTable.Get)("ActivityGroup"), foreachActGroup)
  self:RefreshPopUpList()
  self:RefreshActGroupNewRedDot()
end

PlayerActivityData.CreateActivityGroupIns = function(self, actData)
  -- function num : 0_15 , upvalues : _ENV, SwimThemeData, OurRegiment_10101Data, Dream_10102Data, BreakOut_30101Data, TimerManager
  local actIns = nil
  local actCfg = actData
  if actCfg == nil then
    return 
  end
  local nOpenTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(actCfg.StartTime)
  local nEndEnterTime = ((CS.ClientManager).Instance):ISO8601StrToTimeStamp(actCfg.EnterEndTime)
  local curTime = ((CS.ClientManager).Instance).serverTimeStamp
  if nOpenTime <= curTime and curTime < nEndEnterTime then
    if actCfg.ActivityThemeType == (GameEnum.activityThemeType).Swim then
      actIns = (SwimThemeData.new)(actData)
    else
      if actCfg.ActivityThemeType == (GameEnum.activityThemeType).OurRegiment_10101 then
        actIns = (OurRegiment_10101Data.new)(actData)
      else
        if actCfg.ActivityThemeType == (GameEnum.activityThemeType).Dream_10102 then
          actIns = (Dream_10102Data.new)(actData)
        else
          if actCfg.ActivityThemeType == (GameEnum.activityThemeType).BreakOut_30101 then
            actIns = (BreakOut_30101Data.new)(actData)
          end
        end
      end
    end
    -- DECOMPILER ERROR at PC70: Confused about usage of register: R7 in 'UnsetPending'

    ;
    (self.tbAllActivityGroup)[actData.Id] = actIns
    ;
    (PlayerData.ActivityAvg):RefreshAvgRedDot()
  else
    if curTime < nOpenTime then
      (TimerManager.Add)(1, nOpenTime - curTime, nil, function()
    -- function num : 0_15_0 , upvalues : self, actData
    self:RefreshActivityGroupData(actData)
  end
, true, true, true)
    end
  end
end

PlayerActivityData.RefreshActivityGroupData = function(self, actData)
  -- function num : 0_16
  if (self.tbAllActivityGroup)[actData.Id] == nil then
    self:CreateActivityGroupIns(actData)
  else
    ;
    ((self.tbAllActivityGroup)[actData.Id]):RefreshActivityData(actData)
  end
  self:RefreshActGroupNewRedDot()
end

PlayerActivityData.RefreshActGroupNewRedDot = function(self)
  -- function num : 0_17 , upvalues : _ENV, LocalData
  for _,actIns in pairs(self.tbAllActivityGroup) do
    if actIns:CheckActGroupShow() then
      local sData = (LocalData.GetPlayerLocalData)("Activity_Tab_New_" .. actIns:GetActGroupId())
      local nValue = tonumber(sData == nil and "0" or sData)
      local bNewRedDot = nValue == 0
      ;
      (RedDotManager.SetValid)(RedDotDefine.Activity_New_Tab, actIns:GetActGroupId(), bNewRedDot)
    end
  end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerActivityData.GetSortedActGroupList = function(self)
  -- function num : 0_18 , upvalues : _ENV
  local tbActGroupList = {}
  for k,v in pairs(self.tbAllActivityGroup) do
    if v:CheckActGroupShow() then
      (table.insert)(tbActGroupList, v)
    end
  end
  ;
  (table.sort)(tbActGroupList, function(a, b)
    -- function num : 0_18_0
    if not a:CheckActivityGroupOpen() and b:CheckActivityGroupOpen() then
      return false
    else
      if a:CheckActivityGroupOpen() and not b:CheckActivityGroupOpen() then
        return true
      end
    end
    do return a:GetActGroupId() < b:GetActGroupId() end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return tbActGroupList
end

PlayerActivityData.GetActivityGroupDataById = function(self, nActGroupId)
  -- function num : 0_19
  return (self.tbAllActivityGroup)[nActGroupId]
end

PlayerActivityData.GetMainviewShowActivityGroup = function(self)
  -- function num : 0_20 , upvalues : _ENV
  local tbShowList = {}
  for _,actGroupData in pairs(self.tbAllActivityGroup) do
    if actGroupData:CheckActGroupShow() and actGroupData:IsUnlockShow() then
      (table.insert)(tbShowList, actGroupData)
    end
  end
  ;
  (table.sort)(tbShowList, function(a, b)
    -- function num : 0_20_0
    if not a:CheckActivityGroupOpen() and b:CheckActivityGroupOpen() then
      return false
    else
      if a:CheckActivityGroupOpen() and not b:CheckActivityGroupOpen() then
        return true
      end
    end
    do return a:GetActGroupId() < b:GetActGroupId() end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return tbShowList
end

PlayerActivityData.IsActivityInActivityGroup = function(self, nActId)
  -- function num : 0_21 , upvalues : _ENV
  local isInGroup, getActId = nil, nil
  for _,actGroupData in pairs(self.tbAllActivityGroup) do
    if actGroupData:CheckActGroupShow() then
      isInGroup = actGroupData:IsActivityInActivityGroup(nActId)
      if isInGroup == true then
        return isInGroup, getActId
      end
    end
  end
  return false
end

PlayerActivityData.RefreshPeriodicActQuest = function(self, nActId, mapMsgData)
  -- function num : 0_22
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshQuestList(mapMsgData.Quests)
    ;
    ((self.tbAllActivity)[nActId]):RefreshFinalStatus(mapMsgData.FinalStatus)
  end
end

PlayerActivityData.RefreshSingleQuest = function(self, questData)
  -- function num : 0_23 , upvalues : _ENV
  local actCfg = (ConfigTable.GetData)("Activity", questData.ActivityId)
  if not actCfg then
    return 
  end
  if actCfg.ActivityType == (GameEnum.activityType).PeriodicQuest then
    local questCfg = (ConfigTable.GetData)("PeriodicQuest", questData.Id)
    if questCfg then
      local nActId = questCfg.Belong
      if (self.tbAllActivity)[nActId] ~= nil then
        ((self.tbAllActivity)[nActId]):RefreshQuestData(questData)
      end
      ;
      (EventManager.Hit)("RefreshPeriodicAct", nActId)
    end
  else
    do
      -- DECOMPILER ERROR at PC53: Unhandled construct in 'MakeBoolean' P1

      if actCfg.ActivityType == (GameEnum.activityType).Mining and (self.tbAllActivity)[questData.ActivityId] ~= nil then
        ((self.tbAllActivity)[questData.ActivityId]):RefreshQuestData(questData)
      end
      -- DECOMPILER ERROR at PC71: Unhandled construct in 'MakeBoolean' P1

      if actCfg.ActivityType == (GameEnum.activityType).Cookie and (self.tbAllActivity)[questData.ActivityId] ~= nil then
        ((self.tbAllActivity)[questData.ActivityId]):RefreshQuestData(questData)
      end
      if actCfg.ActivityType == (GameEnum.activityType).JointDrill then
        (PlayerData.JointDrill):RefreshQuestData(questData)
      else
        if actCfg.ActivityType == (GameEnum.activityType).Task then
          ((self.tbAllActivity)[questData.ActivityId]):RefreshSingleQuest(questData)
          ;
          (EventManager.Hit)("RefreshActivityTask")
        else
          -- DECOMPILER ERROR at PC118: Unhandled construct in 'MakeBoolean' P1

          if actCfg.ActivityType == (GameEnum.activityType).BDConvert and (self.tbAllActivity)[questData.ActivityId] ~= nil then
            ((self.tbAllActivity)[questData.ActivityId]):RefreshQuestData(questData)
          end
        end
      end
      if actCfg.ActivityType == (GameEnum.activityType).TowerDefense and (self.tbAllActivity)[questData.ActivityId] ~= nil then
        ((self.tbAllActivity)[questData.ActivityId]):RefreshQuestData(questData)
      end
    end
  end
end

PlayerActivityData.CacheLoginRewardActData = function(self, nActId, mapMsgData)
  -- function num : 0_24
  self:RefreshLoginRewardActData(nActId, mapMsgData)
  self:RefreshLoginRewardPopUpList()
end

PlayerActivityData.RefreshLoginRewardActData = function(self, nActId, actData)
  -- function num : 0_25
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshLoginData(actData.Receive, actData.Actual)
  end
end

PlayerActivityData.ReceiveLoginRewardSuc = function(self, nActId)
  -- function num : 0_26
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):ReceiveRewardSuc()
  end
  self:RefreshLoginRewardPopUpList()
end

PlayerActivityData.RefreshPopUpList = function(self)
  -- function num : 0_27 , upvalues : _ENV
  self.tbActivityPopUp = {}
  local bFuncOpen = (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).Activity)
  if not bFuncOpen then
    return 
  end
  for _,v in pairs(self.tbAllActivity) do
    if v:CheckPopUp() and v:CheckActPlay() then
      (table.insert)(self.tbActivityPopUp, v:GetActId())
    end
  end
  for _,v in pairs(self.tbAllActivityGroup) do
    if v:CheckPopUp() and v:CheckActGroupPopUpShow() and v:IsUnlock() then
      (table.insert)(self.tbActivityPopUp, v:GetActGroupId())
    end
  end
  if #self.tbActivityPopUp > 0 then
    (PlayerData.PopUp):InsertPopUpQueue(self.tbActivityPopUp)
  end
end

PlayerActivityData.RefreshLoginRewardPopUpList = function(self)
  -- function num : 0_28 , upvalues : _ENV
  self.tbLoginRewardPopUp = {}
  local bFuncOpen = (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).Activity)
  if not bFuncOpen then
    return 
  end
  for nActId,data in pairs(self.tbAllActivity) do
    local nActType = data:GetActType()
    if nActType == (GameEnum.activityType).LoginReward and data:CheckCanReceive() and data:CheckActivityOpen() then
      (table.insert)(self.tbLoginRewardPopUp, data)
    end
  end
  ;
  (table.sort)(self.tbLoginRewardPopUp, function(a, b)
    -- function num : 0_28_0
    if a:GetActId() >= b:GetActId() then
      do return a:GetActSortId() ~= b:GetActSortId() end
      do return a:GetActSortId() < b:GetActSortId() end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
  if #self.tbLoginRewardPopUp > 0 then
    (PopUpManager.PopUpEnQueue)((GameEnum.PopUpSeqType).ActivityLogin, self.tbLoginRewardPopUp)
  end
end

PlayerActivityData.RefreshMiningGameActData = function(self, nActId, msgMapData)
  -- function num : 0_29
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshMiningGameActData(nActId, msgMapData)
  end
end

PlayerActivityData.RefreshCookieGameActData = function(self, nActId, msgMapData)
  -- function num : 0_30
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshCookieGameActData(nActId, msgMapData)
  end
end

PlayerActivityData.RefreshJointDrillActData = function(self, nActId, msgData)
  -- function num : 0_31
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshJointDrillActData(msgData)
  end
end

PlayerActivityData.RefreshTowerDefenseActData = function(self, nActId, msgData)
  -- function num : 0_32
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshTowerDefenseActData(nActId, msgData)
  end
end

PlayerActivityData.RefreshBdConvertData = function(self, nActId, msgData)
  -- function num : 0_33
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshBdConvertData(nActId, msgData)
  end
end

PlayerActivityData.RefreshBreakoutData = function(self, nActId, msgData)
  -- function num : 0_34
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshBreakoutData(nActId, msgData)
  end
end

PlayerActivityData.RefreshActivityLevelGameActData = function(self, nActId, msgData)
  -- function num : 0_35
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshActivityLevelGameActData(nActId, msgData)
  end
end

PlayerActivityData.SetActivityLevelActId = function(self, nActId)
  -- function num : 0_36
  self.nActivityLevelActId = nActId
end

PlayerActivityData.GetActivityLevelActId = function(self)
  -- function num : 0_37
  return self.nActivityLevelActId
end

PlayerActivityData.RefreshTrialActData = function(self, nActId, msgData)
  -- function num : 0_38
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshTrialActData(msgData)
  end
end

PlayerActivityData.RefreshActivityAvgData = function(self, nActId, msgData)
  -- function num : 0_39 , upvalues : _ENV
  (PlayerData.ActivityAvg):RefreshActivityAvgData(nActId, msgData)
end

PlayerActivityData.RefreshActivityShopData = function(self, nActId, msgData)
  -- function num : 0_40
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshActivityShopData(msgData)
  end
end

PlayerActivityData.RefreshActivityCGData = function(self, msgData)
  -- function num : 0_41 , upvalues : _ENV
  self.tbReadedCG = {}
  for _,actId in pairs(msgData) do
    (table.insert)(self.tbReadedCG, actId)
  end
end

PlayerActivityData.IsCGPlayed = function(self, nActId)
  -- function num : 0_42 , upvalues : _ENV
  do return (table.indexof)(self.tbReadedCG, nActId) > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerActivityData.GetActivityBannerList = function(self)
  -- function num : 0_43 , upvalues : _ENV
  local tbList = {}
  for _,v in pairs(self.tbAllActivity) do
    if v:CheckShowBanner() then
      (table.insert)(tbList, v)
    end
  end
  ;
  (table.sort)(tbList, function(a, b)
    -- function num : 0_43_0
    do return a:GetActId() < b:GetActId() end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
  return tbList
end

PlayerActivityData.RefreshInfinityTowerActData = function(self, nActId, msgData)
  -- function num : 0_44
  if (self.tbAllActivity)[nActId] ~= nil then
    ((self.tbAllActivity)[nActId]):RefreshInfinityTowerActData(nActId, msgData)
  end
end

PlayerActivityData.SendActivityDetailMsg = function(self, callback, bForceGet)
  -- function num : 0_45 , upvalues : _ENV
  local callFunc = function()
    -- function num : 0_45_0 , upvalues : self, callback
    self.bCacheActData = true
    if callback ~= nil then
      callback()
    end
  end

  if not self.bCacheActData or bForceGet then
    (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_detail_req, {}, nil, callFunc)
  else
    if callback ~= nil then
      callback()
    end
  end
end

PlayerActivityData.SendReceivePerQuest = function(self, nActId, nQuestId, callback)
  -- function num : 0_46 , upvalues : _ENV
  local callFunc = function(_, mapChangeInfo)
    -- function num : 0_46_0 , upvalues : self, nActId, nQuestId, _ENV, callback
    local actData = (self.tbAllActivity)[nActId]
    local tbQuestList = actData:RefreshQuestStatus(nQuestId)
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapChangeInfo, callback)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_periodic_reward_receive_req, {ActivityId = nActId, QuestId = nQuestId}, nil, callFunc)
end

PlayerActivityData.SendReceiveFinalReward = function(self, nActId, callback)
  -- function num : 0_47 , upvalues : _ENV
  local callFunc = function(_, mapMsgData)
    -- function num : 0_47_0 , upvalues : self, nActId, callback
    self:ReceiveFinalRewardSuc(nActId, mapMsgData)
    if callback ~= nil then
      callback()
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_periodic_final_reward_receive_req, {Value = nActId}, nil, callFunc)
end

PlayerActivityData.ReceiveQuestReward = function(self, mapMsgData)
  -- function num : 0_48 , upvalues : _ENV
  (UTILS.OpenReceiveByChangeInfo)(mapMsgData)
end

PlayerActivityData.ReceiveFinalRewardSuc = function(self, actId, mapMsgData)
  -- function num : 0_49 , upvalues : _ENV
  local actData = (self.tbAllActivity)[actId]
  if actData ~= nil then
    actData:RefreshFinalStatus(true)
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapMsgData)
  end
end

PlayerActivityData.SendReceiveLoginRewardMsg = function(self, nActId, callFunc)
  -- function num : 0_50 , upvalues : _ENV
  local callback = function(_, mapMsgData)
    -- function num : 0_50_0 , upvalues : self, nActId, _ENV, callFunc
    self:ReceiveLoginRewardSuc(nActId)
    ;
    (UTILS.OpenReceiveByChangeInfo)(mapMsgData, callFunc)
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).activity_login_reward_receive_req, {Value = nActId}, nil, callback)
end

PlayerActivityData.OpenActivityPanel = function(self, nActId)
  -- function num : 0_51 , upvalues : _ENV
  local tbList = self:GetSortedActList()
  if next(tbList) == nil then
    self:RefreshActivityRedDot()
    ;
    (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Activity_Empty"))
    return 
  end
  local openFunc = function()
    -- function num : 0_51_0 , upvalues : _ENV, nActId
    local func = function()
      -- function num : 0_51_0_0 , upvalues : _ENV, nActId
      (EventManager.Hit)(EventId.OpenPanel, PanelId.ActivityList, nActId)
    end

    ;
    (EventManager.Hit)(EventId.SetTransition, 5, func)
  end

  self:SendActivityDetailMsg(openFunc)
end

PlayerActivityData.OnEvent_NewDay = function(self)
  -- function num : 0_52
  self.bCacheActData = false
end

PlayerActivityData.OnEvent_UpdateWorldClass = function(self)
  -- function num : 0_53
  self:RefreshPopUpList()
  self:RefreshActStatus()
  self:RefreshActGroupNewRedDot()
end

PlayerActivityData.OnEvent_StoryEnd = function(self)
  -- function num : 0_54
  self:RefreshPopUpList()
  self:RefreshActStatus()
  self:RefreshActGroupNewRedDot()
end

return PlayerActivityData

