
local PlayerBattlePassData = class("PlayerBattlePassData")

function PlayerBattlePassData:Init()
    self.nSeasonId = 0 --当前赛季ID
    self.nCurMode = 0 --模式 0为普通版，1为进阶版, 2为豪华版
    self.nVersion = 0 --当前战令信息版本号
    self.nDeadlineTS = 0 --当前赛季结束时间戳
    self.nLevel = 0 --当前等级
    self.nExp = 0   --当前经验
    self.nMaxLevel = 0  --最大等级
    self.nExpThisWeek = 0 --本周是否已达经验获取上限
    self.tbBaseReward = nil    --基础版奖励领取状态位图
    self.tbPremiumReward = nil    --进阶版奖励领取状态位图
    self.hasData = false
    EventManager.Add(EventId.IsNewDay, self, self.OnEvent_NewDay)
    EventManager.Add("BattlePassNeedRefresh", self, self.OnEvent_NeedRefresh)
    
    self:InitConfig()
end
function PlayerBattlePassData:UnInit()
    EventManager.Remove(EventId.IsNewDay, self, self.OnEvent_NewDay)
end
function PlayerBattlePassData:InitConfig()
    local function forEachBattlePassLevel(mapData)
        if mapData.ID > self.nMaxLevel then
            self.nMaxLevel = mapData.ID
        end
    end
    ForEachTableLine(DataTable.BattlePassLevel, forEachBattlePassLevel)

    self.mapBattlePassName = {}
    local function func_ForEach_Line(mapData)
        self.mapBattlePassName[mapData.LuxuryProductId] = ConfigTable.GetUIText("BattlePassRewardLuxury")
        self.mapBattlePassName[mapData.PremiumProductId] = ConfigTable.GetUIText("BattlePassRewardPremium")
        self.mapBattlePassName[mapData.ComplementaryProductId] = ConfigTable.GetUIText("BattlePassRewardLuxury")
    end
    ForEachTableLine(DataTable.BattlePass, func_ForEach_Line)
end
function PlayerBattlePassData:CacheBattlePassInfo(mapData)
    if mapData == nil then
        return
    end
    print("当前赛季ID："..mapData.Id)
    self.nSeasonId = mapData.Id
    self.nCurMode = mapData.Mode
    self.nVersion = mapData.Version
    self.nDeadlineTS = mapData.Deadline
    self.nLevel = mapData.Level
    self.nExp = mapData.Exp
    self.nExpThisWeek = mapData.ExpThisWeek
    self.tbBaseReward = UTILS.ParseByteString(mapData.BasicReward)
    self.tbPremiumReward = UTILS.ParseByteString(mapData.PremiumReward)
    local nExpLimit = ConfigTable.GetConfigNumber("BattlePassWeeklyExpLimit")
    if self.nExpThisWeek > nExpLimit then
        self.nExpThisWeek = self.nExpThisWeek
    end
    self:UpdateRewardRedDot()
    --清空任务红点
    RedDotManager.SetValid(RedDotDefine.BattlePass_Quest_Server, nil, false)
    if mapData.DailyQuests ~= nil then
        PlayerData.Quest:CacheAllQuest(mapData.DailyQuests.List)
    end
    if mapData.WeeklyQuests ~= nil then
        PlayerData.Quest:CacheAllQuest(mapData.WeeklyQuests.List)
    end
    self.hasData = true
end
function PlayerBattlePassData:UpdateQuestRedDot(bCanDailyReceive, bCanWeekReceive)
    local nExpLimit = ConfigTable.GetConfigNumber("BattlePassWeeklyExpLimit")
    self.nExpThisWeek = self.nExpThisWeek
    if self.nExpThisWeek >= nExpLimit then
        RedDotManager.SetValid(RedDotDefine.BattlePass_Quest_Daily, nil, false)
        RedDotManager.SetValid(RedDotDefine.BattlePass_Quest_Week, nil, false)
    else
        local bMaxLevel = self.nLevel >= self.nMaxLevel
        RedDotManager.SetValid(RedDotDefine.BattlePass_Quest_Daily, nil, bCanDailyReceive and not bMaxLevel)
        RedDotManager.SetValid(RedDotDefine.BattlePass_Quest_Week, nil, bCanWeekReceive and not bMaxLevel)
    end
end
function PlayerBattlePassData:UpdateRewardRedDot()
    local bCanReceive = false
    local mapReward = {}
    local nRewardCount = 0
    local function foreachReward(mapData)
        if mapData.ID == self.nSeasonId then
            mapReward[mapData.Level] = mapData
            nRewardCount = nRewardCount + 1
        end
    end
    ForEachTableLine(DataTable.BattlePassReward,foreachReward)
    for i = 1, nRewardCount, 1 do
        if mapReward[i] ~= nil then
            local bNormalReceive = UTILS.IsBitSet(self.tbBaseReward, i)
            local bVipReceive = UTILS.IsBitSet(self.tbPremiumReward, i)
            if i <= self.nLevel and (not bNormalReceive or (self.nCurMode > 0 and not bVipReceive)) then
                bCanReceive = true
                break
            end
        end
    end
    RedDotManager.SetValid(RedDotDefine.BattlePass_Reward, nil, bCanReceive)
    --刷新任务红点
    local nExpLimit = ConfigTable.GetConfigNumber("BattlePassWeeklyExpLimit")
    if self.nLevel >= self.nMaxLevel or self.nExpThisWeek >= nExpLimit then
        RedDotManager.SetValid(RedDotDefine.BattlePass_Quest_Week, nil, false)
        RedDotManager.SetValid(RedDotDefine.BattlePass_Quest_Daily, nil, false)
    end
end
function PlayerBattlePassData:OnPremiumBuySuccess(mapData)
    if self.nLevel ~= mapData.Level then
        local mapLevelData = {
            nOldLevel = self.nLevel,
            nOldExp = self.nExp,
            nLevel = mapData.Level,
            nExp = self.nExp,
        }
        local function callback()
            EventManager.Remove("MallOrderClear",self,callback)
            local function levelupCallback()
                local mapReward = PlayerData.Item:ProcessRewardChangeInfo(mapData.CollectResp.Items)
                local tbSelectedItem = {}
                for _, mapItemData in ipairs(mapReward.tbReward) do
                    local mapItemCfgData = ConfigTable.GetData_Item(mapItemData.id)
                    if mapItemCfgData ~= nil and mapItemCfgData.Stype == GameEnum.itemStype.OutfitCYO then
                       table.insert(tbSelectedItem,mapItemData.id)
                    end
                end
                if #tbSelectedItem > 0 then
                    EventManager.Hit(EventId.OpenPanel,PanelId.Consumable,tbSelectedItem)
                end
                EventManager.Hit("BattlePassLevelUpPanelClose")
            end
            EventManager.Hit(EventId.OpenPanel,PanelId.BattlePassUpgrade,levelupCallback,mapLevelData)
        end
        EventManager.Add("MallOrderClear",self,callback)
    else
        local function callback()
            EventManager.Remove("MallOrderClear",self,callback)
            if mapData.Mode == 1 then
                -- 进阶版因为没有直接奖励，需要弹窗提示
                local msg = {
                    nType = AllEnum.MessageBox.Alert,
                    sContent = ConfigTable.GetUIText("BattlePassRewardPremium_ReceiveTip"),
                }
                EventManager.Hit(EventId.OpenMessageBox, msg)
            end
        end
        EventManager.Add("MallOrderClear",self,callback)
    end
    self.nVersion = mapData.Version
    self.nCurMode = mapData.Mode
    self.nLevel = mapData.Level
    --刷新红点
    self:UpdateRewardRedDot()
    EventManager.Hit("BattlePassPremiumSuccess")
end
function PlayerBattlePassData:OnQuestReceive(msgData)
    self.nLevel = msgData.Level
    self.nExp = msgData.Exp
    local nExpLimit = ConfigTable.GetConfigNumber("BattlePassWeeklyExpLimit")
    self.nExpThisWeek = msgData.ExpThisWeek
    if self.nExpThisWeek > nExpLimit then
        self.nExpThisWeek = self.nExpThisWeek
    end
    --刷新红点
    self:UpdateRewardRedDot()
end
function PlayerBattlePassData:GetBattlePassName(sId)
    return self.mapBattlePassName[sId]
end
function PlayerBattlePassData:OnEvent_NewDay()
    self.hasData = false
end
function PlayerBattlePassData:OnEvent_NeedRefresh()
    self.hasData = false
end
function PlayerBattlePassData:NetMsg_BuyBattlePassLevel(nLevel,callback)
    local msg = {
        Value = nLevel;
        Version = self.nVersion;
    }
    local mapLevelData = {
        nOldLevel = self.nLevel,
        nOldExp = self.nExp,
    }
    local function msgCallback(_,msgData)
        self.nLevel = msgData.Level
        mapLevelData.nLevel = self.nLevel
        mapLevelData.nExp = self.nExp
        local function callabck()
            EventManager.Hit("BattlePassLevelUpPanelClose")
        end
        EventManager.Hit(EventId.OpenPanel,PanelId.BattlePassUpgrade,callabck,mapLevelData)
        EventManager.Hit("BattlePassBuyLevel")
        if callback ~= nil and type(callback) == "function" then
            callback()
        end
        --刷新红点
        self:UpdateRewardRedDot()
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.battle_pass_level_buy_req,msg,nil,msgCallback)
end
function PlayerBattlePassData:NetMsg_BattlePassRewardReceive(bAll,nLevel,bBasic,callback)
    local msg = {}
    if bAll then
        msg.All = {}
    elseif bBasic then
        msg.Basic = nLevel
    else
        msg.Premium = nLevel
    end
    msg.Version = self.nVersion
    local function msgCallback(_,msgData)
        self.tbBaseReward = UTILS.ParseByteString(msgData.BasicReward)
        self.tbPremiumReward = UTILS.ParseByteString(msgData.PremiumReward)
        EventManager.Hit("UpdateBattlePassReward",msgData.Change)
        self:UpdateRewardRedDot()
        if callback ~= nil and type(callback) == "function" then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.battle_pass_reward_receive_req,msg,nil,msgCallback)
end
function PlayerBattlePassData:GetBattlePassInfo(callback)
    local function GetMsgCallback()
        if not self.hasData then
            printError("未获取到战令数据")
            return
        end
        local mapRet = {}
        local mapReward = {}
        local nRewardCount = 0
        local function foreachReward(mapData)
            if mapData.ID == self.nSeasonId then
                mapReward[mapData.Level] = mapData
                nRewardCount = nRewardCount + 1
            end
        end
        ForEachTableLine(DataTable.BattlePassReward,foreachReward)
        
        mapRet.nSeasonId = self.nSeasonId
        mapRet.nCurMode = self.nCurMode --模式 0为普通版，1为进阶版, 2为豪华版
        mapRet.nVersion = self.nVersion--当前战令信息版本号
        mapRet.nDeadlineTS = self.nDeadlineTS --当前赛季结束时间戳
        mapRet.nLevel = self.nLevel --当前等级
        mapRet.nExp = self.nExp   --当前经验
        mapRet.nExpThisWeek = self.nExpThisWeek--本周是否已达经验获取上限
        mapRet.tbReward = {}
        for i = 1, nRewardCount, 1 do
            if mapReward[i] ~= nil then
                local bNormalReceive = UTILS.IsBitSet(self.tbBaseReward, i)
                local bVipReceive = UTILS.IsBitSet(self.tbPremiumReward, i)
                table.insert(mapRet.tbReward,{
                    nLevel = i,
                    nNormalTid = mapReward[i].Tid1,
                    nNormalQty = mapReward[i].Qty1,
                    nVipTid1 = mapReward[i].Tid2,
                    nVipQty1 = mapReward[i].Qty2,
                    nVipTid2 = mapReward[i].Tid3,
                    nVipQty2 = mapReward[i].Qty3,
                    bNormalReceive =  bNormalReceive,
                    bVipReceive =  bVipReceive,
                    bFocus = mapReward[i].Focus
                })
            end
        end
        callback(mapRet)
    end
    if self.hasData then
        GetMsgCallback()
    else
        HttpNetHandler.SendMsg(NetMsgId.Id.battle_pass_info_req,{},nil,GetMsgCallback)
    end
end
function PlayerBattlePassData:GetHasBattlePass()
    if self.hasData then
        return self.nSeasonId > 0
    else
        local function IsOpenCardPool(sStartTime,sEndTime)
            if string.len(sStartTime) == 0 or string.len(sEndTime) == 0 then
                return true
            end
            local nowTime = CS.ClientManager.Instance.serverTimeStamp
            return nowTime>String2Time(sStartTime) and nowTime<String2Time(sEndTime)
        end
        local ret = false
        local function func_ForEach_Gacha(mapGacha)
            if IsOpenCardPool(mapGacha.StartTime,mapGacha.EndTime) then
                ret = true
            end
        end
        ForEachTableLine(DataTable.BattlePass,func_ForEach_Gacha)
        return ret
    end
end
function PlayerBattlePassData:GetMaxLevel()
    return self.nMaxLevel
end
return PlayerBattlePassData