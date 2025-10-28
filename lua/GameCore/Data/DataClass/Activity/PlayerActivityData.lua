local PlayerActivityData = class("PlayerActivityData")
local PeriodicQuestActData = require "GameCore.Data.DataClass.Activity.PeriodicQuestActData"
local LoginRewardActData = require "GameCore.Data.DataClass.Activity.LoginRewardActData"
local MiningGameData = require "GameCore.Data.DataClass.Activity.MiningGameData"
local TrialActData = require "GameCore.Data.DataClass.Activity.TrialActData"
local CookieActData = require "GameCore.Data.DataClass.Activity.CookieGameData"
local TowerDefenseData = require"GameCore.Data.DataClass.Activity.TowerDefenseData"
local JointDrillActData = require"GameCore.Data.DataClass.Activity.JointDrillActData"
local ActivityLevelTypeData = require"GameCore.Data.DataClass.Activity.ActivityLevelTypeData"
local ActivityTaskData = require "GameCore.Data.DataClass.Activity.ActivityTaskData" -- xiajiabin
local ActivityShopData = require "GameCore.Data.DataClass.Activity.ActivityShopData"
local AdvertiseActData = require "GameCore.Data.DataClass.Activity.AdvertiseActData"
local LocalData = require "GameCore.Data.LocalData"
local SwimThemeData = require("GameCore.Data.DataClass.Activity.SwimThemeData")
local TimerManager = require("GameCore.Timer.TimerManager")

function PlayerActivityData:Init()
    self.bCacheActData = false
    self.tbAllActivity = {}         -- 活动列表
    self.tbAllActivityGroup = {}    -- 当前所有的活动主题（组��?
    self.tbActivityPopUp = {}       -- 需要显示的活动开屏列��?
    self.tbLoginRewardPopUp = {}    -- 登录奖励弹窗
    self.tbReadedCG = {}            -- 已读的CG列表
    self:InitActivityCfg()
    EventManager.Add(EventId.IsNewDay, self, self.OnEvent_NewDay)
    EventManager.Add(EventId.UpdateWorldClass, self, self.OnEvent_UpdateWorldClass)
    EventManager.Add("Story_RewardClosed", self, self.OnEvent_StoryEnd)
end

function PlayerActivityData:UnInit()
    EventManager.Remove(EventId.IsNewDay, self, self.OnEvent_NewDay)
    EventManager.Remove(EventId.UpdateWorldClass, self, self.OnEvent_UpdateWorldClass)
    EventManager.Remove("Story_RewardClosed", self, self.OnEvent_StoryEnd)
end

function PlayerActivityData:InitActivityCfg()
    local function foreachTableLine(line)
        if nil == CacheTable.GetData("_PeriodicQuestGroup", line.Belong) then
            CacheTable.SetData("_PeriodicQuestGroup", line.Belong, {})
        end
        if nil == CacheTable.GetData("_PeriodicQuestGroup", line.Belong)[line.UnlockTime + 1] then
            CacheTable.GetData("_PeriodicQuestGroup", line.Belong)[line.UnlockTime + 1] = {}
        end
        table.insert(CacheTable.GetData("_PeriodicQuestGroup", line.Belong)[line.UnlockTime + 1], line.GroupId)

        if nil == CacheTable.GetData("_PeriodicQuestDay", line.Belong) then
            CacheTable.SetData("_PeriodicQuestDay", line.Belong, {})
        end
        CacheTable.GetData("_PeriodicQuestDay", line.Belong)[line.GroupId] = line.UnlockTime + 1

        if nil == CacheTable.GetData("_PeriodicQuestMaxDay", line.Belong) then
            CacheTable.SetData("_PeriodicQuestMaxDay", line.Belong, 0)
        end
        if line.UnlockTime + 1 > CacheTable.GetData("_PeriodicQuestMaxDay", line.Belong) then
            CacheTable.SetData("_PeriodicQuestMaxDay", line.Belong, line.UnlockTime + 1)
        end
    end
    ForEachTableLine(DataTable.PeriodicQuestGroup, foreachTableLine)

    local function foreachTableLine(line)
        CacheTable.InsertData("_PeriodicQuest", line.Belong, line)
    end
    ForEachTableLine(DataTable.PeriodicQuest, foreachTableLine)
    
    local function foreachLoginRewardGroup(line)
        CacheTable.InsertData("_LoginRewardGroup", line.RewardGroupId, line)
    end
    ForEachTableLine(DataTable.LoginRewardGroup, foreachLoginRewardGroup)

    local function foreachTableLine(line)
        CacheTable.SetData("_ActivityTaskControl", line.ActivityId, line)
    end
    ForEachTableLine(DataTable.ActivityTaskControl, foreachTableLine)
end

--活动详情数据
function PlayerActivityData:CacheAllActivityData(mapNetMsg)
    if mapNetMsg.List ~= nil then
        for _, v in ipairs(mapNetMsg.List) do
            local nActId = v.Id
            local actCfg = ConfigTable.GetData("Activity", nActId)
            if nil ~= actCfg then
                if actCfg.ActivityType == GameEnum.activityType.Avg then
                    self:RefreshActivityAvgData(nActId, v.Avg)
                end
            end
            if nil ~= actCfg then
                if actCfg.ActivityType == GameEnum.activityType.PeriodicQuest then
                    self:RefreshPeriodicActQuest(nActId, v.Periodic)
                elseif actCfg.ActivityType == GameEnum.activityType.LoginReward then
                    self:RefreshLoginRewardActData(nActId, v.Login)
                elseif actCfg.ActivityType == GameEnum.activityType.Mining then
                    self:RefreshMiningGameActData(nActId,v.Mining)
                elseif actCfg.ActivityType == GameEnum.activityType.Cookie then
                    self:RefreshCookieGameActData(nActId,v.Cookie)
                elseif actCfg.ActivityType==GameEnum.activityType.TowerDefense then
                    self:RefreshTowerDefenseActData(nActId,v.TowerDefense)
                elseif actCfg.ActivityType == GameEnum.activityType.JointDrill then
                    self:RefreshJointDrillActData(nActId, v.JointDrill)
                elseif actCfg.ActivityType == GameEnum.activityType.Levels then
                    self:RefreshActivityLevelGameActData(nActId, v.Levels)
                elseif actCfg.ActivityType == GameEnum.activityType.Trial then
                    self:RefreshTrialActData(nActId, v.Trial)
                elseif actCfg.ActivityType == GameEnum.activityType.CG then
                    self:RefreshActivityCGData(v.CG)
                elseif actCfg.ActivityType == GameEnum.activityType.Task then -- xiajiabin
                    local actIns = self.tbAllActivity[nActId]
                    if actIns == nil then
                        local mapActData = {}
                        mapActData.Id = nActId
                        mapActData.StartTime = 0
                        mapActData.EndTime = 0
                        actIns = ActivityTaskData.new(mapActData)
                        self.tbAllActivity[nActId] = actIns
                    end
                    actIns:CacheData(v.Task)
                    --刷新活动任务弹窗用
                    EventManager.Hit("RefreshActivityTask")
                elseif actCfg.ActivityType == GameEnum.activityType.Shop then
                    self:RefreshActivityShopData(nActId, v.Shop)
                elseif actCfg.ActivityType == GameEnum.activityType.Advertise then
                    self:RefreshInfinityTowerActData(nActId, v.Shop)
                end
            end
        end
    end
    self:RefreshLoginRewardPopUpList()
end

--活动数据处理(当前开启的活动列表)
function PlayerActivityData:CacheActivityData(mapNetMsg)
    if nil == mapNetMsg then
        return
    end
    for _, v in ipairs(mapNetMsg) do
        self:CreateActivityIns(v)
    end
end

function PlayerActivityData:UpdateActivityState(mapNetMsg)
    if nil == mapNetMsg then
        return
    end
    for _, v in ipairs(mapNetMsg) do
        if self.tbAllActivity[v.Id] ~= nil then
            self.tbAllActivity[v.Id]:UpdateActivityState(v)
        end
    end
    self:RefreshPopUpList()
    self:RefreshActivityRedDot()
end

function PlayerActivityData:RefreshActivityData(mapNetMsg)
    if nil == self.tbAllActivity[mapNetMsg.Id] then
        self:CreateActivityIns(mapNetMsg)
        --有新活动开启时主动请求下活动详情数据
        self:SendActivityDetailMsg(nil, true)
    else
        self.tbAllActivity[mapNetMsg.Id]:RefreshActivityData(mapNetMsg)
    end
  
    self:RefreshPopUpList()
    self:RefreshActivityRedDot()
end

function PlayerActivityData:RefreshActivityStateData(mapNetMsg)
    if nil ~= self.tbAllActivity[mapNetMsg.Id] then
        self.tbAllActivity[mapNetMsg.Id]:RefreshStateData(mapNetMsg.RedDot, mapNetMsg.Banner)
        self:RefreshActivityRedDot()
    end
end

function PlayerActivityData:CreateActivityIns(actData)
    local actIns
    local actCfg = ConfigTable.GetData("Activity", actData.Id)
    if actCfg == nil then
        return
    end
    if actCfg.ActivityType == GameEnum.activityType.PeriodicQuest then
        actIns = PeriodicQuestActData.new(actData)
    elseif actCfg.ActivityType == GameEnum.activityType.LoginReward then
        actIns = LoginRewardActData.new(actData)
    elseif actCfg.ActivityType == GameEnum.activityType.Mining then
        actIns = MiningGameData.new(actData)
    elseif actCfg.ActivityType == GameEnum.activityType.Trial then
        actIns = TrialActData.new(actData)
    elseif actCfg.ActivityType == GameEnum.activityType.Cookie then
        actIns = CookieActData.new(actData)
    elseif actCfg.ActivityType == GameEnum.activityType.TowerDefense then
        actIns = TowerDefenseData.new (actData)
    elseif actCfg.ActivityType == GameEnum.activityType.JointDrill then
        actIns = JointDrillActData.new(actData)
    elseif actCfg.ActivityType == GameEnum.activityType.Levels then
        actIns = ActivityLevelTypeData.new(actData)
    elseif actCfg.ActivityType == GameEnum.activityType.Avg then
        PlayerData.ActivityAvg:CacheActivityAvgData(actData)
    elseif actCfg.ActivityType == GameEnum.activityType.Task then -- xiajiabin
        actIns = ActivityTaskData.new(actData)
    elseif actCfg.ActivityType == GameEnum.activityType.Shop then
        actIns = ActivityShopData.new(actData)
    elseif actCfg.ActivityType == GameEnum.activityType.Advertise then
        actIns = AdvertiseActData.new(actData)
    end
    if actIns ~= nil then
        self.tbAllActivity[actData.Id] = actIns
    end
end

function PlayerActivityData:RefreshActivityRedDot()
    for _, v in pairs(self.tbAllActivity) do
        RedDotManager.SetValid(RedDotDefine.Activity_Tab, v:GetActId(), v:CheckActShow() and v:GetActivityRedDot())
        if type(v.RefreshRedDot) == "function" then
            v:RefreshRedDot()
        end
    end
end

function PlayerActivityData:GetActivityList()
    return self.tbAllActivity
end

function PlayerActivityData:GetSortedActList()
    local tbActList = {}
    for k, v in pairs(self.tbAllActivity) do
        if v:CheckActShow() then
            local bInActGroup = false
            if v:GetActCfgData().ActivityThemeType > 0 or self:IsActivityInActivityGroup(v:GetActId()) then
                bInActGroup = true
            end
            if not bInActGroup then
                table.insert(tbActList, v)
            end
        end
    end
    table.sort(tbActList, function(a, b)
        if a:GetActSortId() == b:GetActSortId() then
            return a:GetActId() < b:GetActId()
        end
        return a:GetActSortId() < b:GetActSortId()
    end)
    return tbActList
end

function PlayerActivityData:GetActivityDataById(nActId)
    return self.tbAllActivity[nActId] or nil
end
--------------------- 活动主题（组）数��? --------------
function PlayerActivityData:CacheActivityGroupData()
    local function foreachActGroup(mapData)
        self:CreateActivityGroupIns(mapData)
    end
    ForEachTableLine(ConfigTable.Get("ActivityGroup"),foreachActGroup)
    self:RefreshPopUpList()
end

function PlayerActivityData:CreateActivityGroupIns(actData)
    local actIns
    local actCfg = actData
    if actCfg == nil then
        return
    end
    local nOpenTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(actCfg.StartTime)
    local nEndEnterTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(actCfg.EnterEndTime)
    local curTime = CS.ClientManager.Instance.serverTimeStamp
    if curTime >= nOpenTime and curTime < nEndEnterTime then
        if actCfg.ActivityGroupType == GameEnum.activityThemeType.Swim then
            actIns = SwimThemeData.new(actData)
        end
        self.tbAllActivityGroup[actData.Id] = actIns
        PlayerData.ActivityAvg:RefreshAvgRedDot()
    elseif curTime < nOpenTime then
        TimerManager.Add(1, nOpenTime - curTime, nil, function()
            self:RefreshActivityGroupData(actData)
        end, true, true, true)
    end
end

function PlayerActivityData:RefreshActivityGroupData(actData)
    if nil == self.tbAllActivityGroup[actData.Id] then
        self:CreateActivityGroupIns(actData)
    else
        self.tbAllActivityGroup[actData.Id]:RefreshActivityData(actData)
    end
end

function PlayerActivityData:GetSortedActGroupList()
    local tbActGroupList = {}
    for k, v in pairs(self.tbAllActivityGroup) do
        if v:CheckActGroupShow() then
            table.insert(tbActGroupList, v)
        end
    end
    table.sort(tbActGroupList, function(a, b)
        if not a:CheckActivityGroupOpen() and b:CheckActivityGroupOpen() then
            return false
        elseif a:CheckActivityGroupOpen() and not b:CheckActivityGroupOpen() then
            return true
        end
        return a:GetActGroupId() < b:GetActGroupId()
    end)
    return tbActGroupList
end

function PlayerActivityData:GetActivityGroupDataById(nActGroupId)
    return self.tbAllActivityGroup[nActGroupId]
end

--获取显示在主界面的活动组
function PlayerActivityData:GetMainviewShowActivityGroup()
    local tbShowList = {}
    for _, actGroupData in pairs(self.tbAllActivityGroup) do
        if actGroupData:CheckActGroupShow() and actGroupData:IsUnlockShow() then
            table.insert(tbShowList, actGroupData)
        end
    end
    table.sort(tbShowList, function(a, b)
        if not a:CheckActivityGroupOpen() and b:CheckActivityGroupOpen() then
            return false
        elseif a:CheckActivityGroupOpen() and not b:CheckActivityGroupOpen() then
            return true
        end
        return a:GetActGroupId() < b:GetActGroupId()
    end)
    return tbShowList
end

function PlayerActivityData:IsActivityInActivityGroup(nActId)
    for _, actGroupData in pairs(self.tbAllActivityGroup) do
        if actGroupData:CheckActGroupShow() then
            return actGroupData:IsActivityInActivityGroup(nActId)
        end
    end
    return false
end

--------------------- 周期活动数据 -------------------- 

function PlayerActivityData:RefreshPeriodicActQuest(nActId, mapMsgData)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:RefreshQuestList(mapMsgData.Quests)
        self.tbAllActivity[nActId]:RefreshFinalStatus(mapMsgData.FinalStatus)
    end
end

function PlayerActivityData:RefreshSingleQuest(questData)
    local actCfg=ConfigTable.GetData("Activity",questData.ActivityId)
    if not actCfg then
        return
    end
    if actCfg.ActivityType==GameEnum.activityType.PeriodicQuest then
        local questCfg = ConfigTable.GetData("PeriodicQuest", questData.Id)
        if questCfg then
            local nActId = questCfg.Belong
            if nil ~= self.tbAllActivity[nActId] then
                self.tbAllActivity[nActId]:RefreshQuestData(questData)
            end
            --刷新活动任务
            EventManager.Hit("RefreshPeriodicAct", nActId)
        end
    elseif actCfg.ActivityType==GameEnum.activityType.Mining then
        if nil ~=self.tbAllActivity[questData.ActivityId] then
            self.tbAllActivity[questData.ActivityId]:RefreshQuestData(questData)
        end
    elseif actCfg.ActivityType == GameEnum.activityType.Cookie then
        if nil ~= self.tbAllActivity[questData.ActivityId] then
            self.tbAllActivity[questData.ActivityId]:RefreshQuestData(questData)
        end
    elseif actCfg.ActivityType == GameEnum.activityType.JointDrill then
        PlayerData.JointDrill:RefreshQuestData(questData)
    elseif actCfg.ActivityType == GameEnum.activityType.Task then -- xiajiabin
        self.tbAllActivity[questData.ActivityId]:RefreshSingleQuest(questData)
        EventManager.Hit("RefreshActivityTask")
    end
end

--------------------- 登录奖励活动数据 --------------------
function PlayerActivityData:CacheLoginRewardActData(nActId, mapMsgData)
    self:RefreshLoginRewardActData(nActId, mapMsgData)
    self:RefreshLoginRewardPopUpList()
end

function PlayerActivityData:RefreshLoginRewardActData(nActId, actData)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:RefreshLoginData(actData.Receive, actData.Actual)
    end
end

function PlayerActivityData:ReceiveLoginRewardSuc(nActId)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:ReceiveRewardSuc()
    end
    self:RefreshLoginRewardPopUpList()
end

--------------------- 开屏广��? --------------------
function PlayerActivityData:RefreshPopUpList()
    self.tbActivityPopUp = {}
    local bFuncOpen = PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.Activity)
    if not bFuncOpen then
        return
    end
    for _, v in pairs(self.tbAllActivity) do
        if v:CheckPopUp() and v:CheckActPlay() then
            table.insert(self.tbActivityPopUp, v:GetActId())
        end
    end
    for _, v in pairs(self.tbAllActivityGroup) do
        if v:CheckPopUp() and v:CheckActGroupPopUpShow() and v:IsUnlock() then
            table.insert(self.tbActivityPopUp, v:GetActGroupId())
        end
    end
    if #self.tbActivityPopUp > 0 then
        PlayerData.PopUp:InsertPopUpQueue(self.tbActivityPopUp)
    end
end

--登录奖励弹窗
function PlayerActivityData:RefreshLoginRewardPopUpList()
    self.tbLoginRewardPopUp = {}
    local bFuncOpen = PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.Activity)
    if not bFuncOpen then
        return
    end
    for nActId, data in pairs(self.tbAllActivity) do
        local nActType = data:GetActType()
        if nActType == GameEnum.activityType.LoginReward and data:CheckCanReceive() and data:CheckActivityOpen() then
            table.insert(self.tbLoginRewardPopUp, data)
        end
    end

    table.sort(self.tbLoginRewardPopUp, function(a, b)
        if a:GetActSortId() == b:GetActSortId() then
            return a:GetActId() < b:GetActId()
        end
        return a:GetActSortId() < b:GetActSortId()
    end)

    if #self.tbLoginRewardPopUp > 0 then
        PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.ActivityLogin, self.tbLoginRewardPopUp)
    end
end

--------------------- Mining --------------------
function PlayerActivityData:RefreshMiningGameActData(nActId,msgMapData)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:RefreshMiningGameActData(nActId,msgMapData)
    end
end

--------------------- Cookie --------------------
function PlayerActivityData:RefreshCookieGameActData(nActId,msgMapData)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:RefreshCookieGameActData(nActId,msgMapData)
    end
end

--------------------- JointDrill --------------------
function PlayerActivityData:RefreshJointDrillActData(nActId, msgData)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:RefreshJointDrillActData(msgData)
    end
end
--------------------- TowerDefense --------------------
function  PlayerActivityData:RefreshTowerDefenseActData(nActId, msgData)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:RefreshTowerDefenseActData(nActId,msgData)
    end
end

--------------------- ActivityLevel --------------------
function  PlayerActivityData:RefreshActivityLevelGameActData(nActId, msgData)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:RefreshActivityLevelGameActData(nActId,msgData)
    end
end

function PlayerActivityData:SetActivityLevelActId(nActId)
    self.nActivityLevelActId = nActId
end

function PlayerActivityData:GetActivityLevelActId()
    return self.nActivityLevelActId
end

--------------------- Trial --------------------
function  PlayerActivityData:RefreshTrialActData(nActId, msgData)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:RefreshTrialActData(msgData)
    end
end
--------------------- Avg ---------------------------
function PlayerActivityData:RefreshActivityAvgData(nActId, msgData)
    PlayerData.ActivityAvg:RefreshActivityAvgData(nActId, msgData)
end
--------------------- Shop --------------------
function  PlayerActivityData:RefreshActivityShopData(nActId, msgData)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:RefreshActivityShopData(msgData)
    end
end
--------------------- cg ----------------------------
function PlayerActivityData:RefreshActivityCGData(msgData)
    self.tbReadedCG = {}
    for _, actId in pairs(msgData) do
        table.insert(self.tbReadedCG, actId)
    end
end

function PlayerActivityData:IsCGPlayed(nActId)
    return table.indexof(self.tbReadedCG, nActId) > 0
end
--------------------- banner --------------------
function PlayerActivityData:GetActivityBannerList()
    local tbList = {}
    for _, v in pairs(self.tbAllActivity) do
        if v:CheckShowBanner() then
            table.insert(tbList, v)
        end
    end
    table.sort(tbList, function(a, b)
        return a:GetActId() < b:GetActId()
    end)
    return tbList
end

--------------------- TowerAllOpen -----------------
function  PlayerActivityData:RefreshInfinityTowerActData(nActId, msgData)
    if nil ~= self.tbAllActivity[nActId] then
        self.tbAllActivity[nActId]:RefreshInfinityTowerActData(nActId,msgData)
    end
end

--------------------- http call --------------------
--获取所有活动数��?
function PlayerActivityData:SendActivityDetailMsg(callback, bForceGet)
    local function callFunc()
        self.bCacheActData = true
        if callback ~= nil then
            callback()
        end
    end
    if not self.bCacheActData or bForceGet then
        HttpNetHandler.SendMsg(NetMsgId.Id.activity_detail_req, {}, nil, callFunc)
    else
        if callback ~= nil then
            callback()
        end
    end
end

--region#周期活动
--领取周期活动任务奖励 (QuestId = 0 表示一键领��?)
function PlayerActivityData:SendReceivePerQuest(nActId, nQuestId, callback)
    local callFunc = function(_, mapChangeInfo)
        --手动刷新任务状��?
        local actData = self.tbAllActivity[nActId]
        local tbQuestList = actData:RefreshQuestStatus(nQuestId)

        --显示奖励弹窗
        UTILS.OpenReceiveByChangeInfo(mapChangeInfo, callback)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_periodic_reward_receive_req, 
            {ActivityId = nActId, QuestId = nQuestId}, nil, callFunc)
end

--领取周期活动最终奖��?
function PlayerActivityData:SendReceiveFinalReward(nActId, callback)
    local callFunc = function(_, mapMsgData)
        self:ReceiveFinalRewardSuc(nActId, mapMsgData)
        if nil ~= callback then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_periodic_final_reward_receive_req,
            {Value = nActId}, nil, callFunc)
end

function PlayerActivityData:ReceiveQuestReward(mapMsgData)
    UTILS.OpenReceiveByChangeInfo(mapMsgData)
end

function PlayerActivityData:ReceiveFinalRewardSuc(actId, mapMsgData)
    local actData = self.tbAllActivity[actId]
    if nil ~= actData then
        actData:RefreshFinalStatus(true)
        UTILS.OpenReceiveByChangeInfo(mapMsgData)
    end
end

--endregion

--region#登录奖励活动
function PlayerActivityData:SendReceiveLoginRewardMsg(nActId, callFunc)
    local callback = function(_, mapMsgData)
        self:ReceiveLoginRewardSuc(nActId)
        UTILS.OpenReceiveByChangeInfo(mapMsgData, callFunc)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.activity_login_reward_receive_req, {Value = nActId}, nil, callback)
end

--endregion


--------------------- public function --------------------
function PlayerActivityData:OpenActivityPanel(nActId)
    --判断当前是否有活动可以展��?
    local tbList = self:GetSortedActList()
    if nil == next(tbList) then
        self:RefreshActivityRedDot()
        EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Activity_Empty"))
        return
    end
    
    local openFunc = function()
        local func = function() EventManager.Hit(EventId.OpenPanel, PanelId.ActivityList, nActId) end
        EventManager.Hit(EventId.SetTransition, 5, func)
    end

    self:SendActivityDetailMsg(openFunc)
end

function PlayerActivityData:OnEvent_NewDay()
    --跨天重新拉取活动信息
    self.bCacheActData = false
end

--升级需要刷新开屏公告
function PlayerActivityData:OnEvent_UpdateWorldClass()
    self:RefreshPopUpList()
end

function PlayerActivityData:OnEvent_StoryEnd()
    self:RefreshPopUpList()
end

return PlayerActivityData