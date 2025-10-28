--用于保存玩家当前状态信息（新邮件、是否有未完成的roguelike关卡等）

local PlayerStateData = class("PlayerStateData")

function PlayerStateData:Init()
    self.tbWorldClassRewardState = {}
    self.tbCharAdvanceRewards ={}
    self.tbCharAffinityReward = {}
    self.bNewAchievement = false
    self.bFriendState = false
    self.bMailOverflow = false  --本次奖励是否溢出
    self.bInStarTowerSweep = false
end

function PlayerStateData:CacheStateData(mapMsgData)
    if mapMsgData ~= nil then
        self:CacheStarTowerStateData(mapMsgData.StarTower)
        self:CacheCharAdvanceRewardsState(mapMsgData.CharAdvanceRewards)
        self:CacheWorldClassRewardState(mapMsgData.WorldClassReward)
        self:CacheAchievementState(mapMsgData.Achievement.New)
        self:CacheFriendState(mapMsgData)
         --战令红点
        RedDotManager.SetValid(RedDotDefine.BattlePass_Quest_Server, nil, mapMsgData.BattlePass.State == 1 or mapMsgData.BattlePass.State == 3)
        RedDotManager.SetValid(RedDotDefine.BattlePass_Reward, nil, mapMsgData.BattlePass.State >= 2)
        --邮件红点
        PlayerData.Mail:UpdateMailRed(mapMsgData.Mail.New)
        --商城红点
        RedDotManager.SetValid(RedDotDefine.Mall_Free, nil, mapMsgData.MallPackage.New)
        --好友申请红点
        RedDotManager.SetValid(RedDotDefine.Friend_Apply, nil, mapMsgData.Friend)
        --好友赠送体力红点
        RedDotManager.SetValid(RedDotDefine.Friend_Energy, nil, mapMsgData.FriendEnergy.State)
        RedDotManager.SetValid(RedDotDefine.StarTowerBook_Affinity, nil, mapMsgData.NpcAffinityReward)
        --旅人对决任务红点
        PlayerData.Quest:UpdateServerQuestRedDot(mapMsgData.TravelerDuelQuest)
        PlayerData.Quest:UpdateServerQuestRedDot(mapMsgData.TravelerDuelChallengeQuest)
        --无尽塔是否有每日奖励可领取
        PlayerData.InfinityTower:UpdateBountyRewardState(mapMsgData.InfinityTower)
        --星塔图鉴红点
        PlayerData.StarTowerBook:UpdateServerRedDot(mapMsgData.StarTowerBook)
        --联合讨伐(boss rush)红点
        PlayerData.ScoreBoss:UpdateRedDot(mapMsgData.ScoreBoss)
        --活动红点
        PlayerData.Activity:UpdateActivityState(mapMsgData.Activities)
        --故事集红点
        PlayerData.StorySet:UpdateStorySetState(mapMsgData.StorySet)
    else
        self.bMailState = false
    end
end
function PlayerStateData:CacheWorldClassRewardState(WorldClassReward)
    self.tbWorldClassRewardState = {string.byte(WorldClassReward.Flag, 1, -1)}
    PlayerData.Base:RefreshWorldClassRedDot()
end
function PlayerStateData:CacheWorldClassRewardStateGM(WorldClassReward)
    if WorldClassReward == nil then
        return
    end
    self.tbWorldClassRewardState = {string.byte(WorldClassReward, 1, -1)}
end
function PlayerStateData:CacheAchievementState(bNew)
    self.bNewAchievement = bNew
end
function PlayerStateData:CacheFriendState(mapMsgData)
    self.bFriendState = mapMsgData.Friend or mapMsgData.FriendEnergy.State
end
function PlayerStateData:CacheStarTowerStateData(mapData)
    if mapData ~= nil then
        self.mapStarTowerState = mapData
        if self.mapStarTowerState.BuildId ~= 0 then
            self.mapStarTowerState.Id = 0
        end
        if self.mapStarTowerState.Floor == 0 then
            self.mapStarTowerState.Floor = 1
        end
    else
        self.mapStarTowerState = {BuildId = 0, Id = 0, Floor = 1, Sweep = false}
    end
end
--游戏开始时从服务器端获取奖励领取信息
function PlayerStateData:CacheCharAdvanceRewardsState(CharAdRewards)
    if CharAdRewards == nil  then
        return
    end
    if CharAdRewards == {}  then
        return
    end
    for _, v in ipairs(CharAdRewards) do
        self.tbCharAdvanceRewards[v.CharId] = string.byte(v.Flag, 1, -1)
    end
    self:RefreshCharAdvanceRewardRedDot()
end

--角色阶级属性改变时改变存储的奖励领取信息
function PlayerStateData:CacheCharactersAdRewards_Notify(mapMsgData)
    if mapMsgData == nil then
        return
    end
    self.tbCharAdvanceRewards[mapMsgData.CharId]=string.byte(mapMsgData.Flag, 1, -1)
    self:RefreshCharAdvanceRewardRedDot()
end

--获得角色奖励领取情况
function PlayerStateData:GetCharAdvanceRewards(nCharId,nAdvance)
    if self.tbCharAdvanceRewards[nCharId] then
        return (self.tbCharAdvanceRewards[nCharId] >> (nAdvance-1) & 1) == 1
    else
        return false
    end
end

function PlayerStateData:GetCanPickedAdvanceRewards(nCharId,nMaxAdvance)
    if self.tbCharAdvanceRewards[nCharId] then
        for nIndex=1,nMaxAdvance,1 do
            if (self.tbCharAdvanceRewards[nCharId] >> (nIndex-1) & 1) == 1 then
                return nIndex
            end
        end
    else
        return 0
    end
end

function PlayerStateData:CheckState()
    if self.mapStarTowerState.BuildId ~= 0 then
        print("正在保存的BuildId"..self.mapStarTowerState.BuildId)
        local function buildDetailcallback(mapBuild)
            EventManager.Hit(EventId.OpenPanel, PanelId.StarTowerBuildSave,false,mapBuild)
            self.mapStarTowerState.BuildId = 0
        end
        PlayerData.Build:GetBuildDetailData(buildDetailcallback,self.mapStarTowerState.BuildId)
        return true
    end
    return false
end
function PlayerStateData:GetStarTowerState()
    return self.mapStarTowerState
end
function PlayerStateData:CheckStarTowerState()
    if self.mapStarTowerState == nil then
        return false
    end
    local bState = self.mapStarTowerState.Id ~= 0
    if bState then
        print(string.format("正在进行的遗迹:%s", self.mapStarTowerState.Id))
        local nMaxCount = ConfigTable.GetConfigNumber("StarTowerReconnMaxCnt")
        
        local function confirmCallback()
            --printError("*****")
            self.mapStarTowerState.ReConnection = self.mapStarTowerState.ReConnection + 1
            if self.mapStarTowerState.Sweep then
                PlayerData.StarTower:ReenterTowerFastBattle()
            else              
                PlayerData.StarTower:ReenterTower(self.mapStarTowerState.Id)
            end
        end
        local function cancelCallback()
            --printError("-----")
            local giveUpCallback = function()

                PlayerData.StarTower:GiveUpReconnect(self.mapStarTowerState.Id,self.mapStarTowerState.CharIds,self.mapStarTowerState.ReConnection < nMaxCount)
            end
            giveUpCallback()
        end
        if self.mapStarTowerState.ReConnection < 0  then
            local msg = {
                nType = AllEnum.MessageBox.Confirm,
                sContent = ConfigTable.GetUIText("Roguelike_Reenter_Hint_Clear"),
                sConfirm = ConfigTable.GetUIText("RoguelikeReenter_Yes"),
                sCancel = ConfigTable.GetUIText("RoguelikeReenter_No"),
                callbackConfirm = confirmCallback,
                callbackCancel = cancelCallback,
                bCloseNoHandler = true,
                bRedCancel = true,
            }
            EventManager.Hit(EventId.OpenMessageBox, msg)
        elseif self.mapStarTowerState.ReConnection < nMaxCount then
            local sHint = orderedFormat(ConfigTable.GetUIText("Roguelike_Reenter_Hint") or "",nMaxCount - self.mapStarTowerState.ReConnection,nMaxCount)
            local msg = {
                nType = AllEnum.MessageBox.Confirm,
                sContent = sHint,
                sConfirm = ConfigTable.GetUIText("RoguelikeReenter_Yes"),
                sCancel = ConfigTable.GetUIText("RoguelikeReenter_No"),
                callbackConfirm = confirmCallback,
                callbackCancel = cancelCallback,
                bCloseNoHandler = true,
                bRedCancel = true,
            }
            EventManager.Hit(EventId.OpenMessageBox, msg)
        else
            local msg = {
                nType = AllEnum.MessageBox.Alert,
                sContent = ConfigTable.GetUIText("Roguelike_Reenter_Hint_Limit"),
                sTitle = "",
                sConfirm = ConfigTable.GetUIText("RoguelikeReenter_Yes"),
                callbackConfirm = cancelCallback,
            }
            EventManager.Hit(EventId.OpenMessageBox, msg)
        end
        EventManager.Hit("HaveRoguelikeState")
    end
    return bState
end
function PlayerStateData:GetStarTowerRecon()
    return self.mapStarTowerState.ReConnection
end
function PlayerStateData:GetWorldClassRewardState()
    return self.tbWorldClassRewardState
end
function PlayerStateData:ResetWorldClassRewardState(nLv)
    local nIndex = math.ceil(nLv / 8)
    local bActive = ((1 << (nLv - (nIndex - 1) * 8 - 1)) & self.tbWorldClassRewardState[nIndex]) > 0
    if bActive then
        self.tbWorldClassRewardState[nIndex] = self.tbWorldClassRewardState[nIndex] & ~(1 << (nLv - (nIndex - 1) * 8 - 1))
    end
    PlayerData.Base:RefreshWorldClassRedDot()
end
function PlayerStateData:ResetIntervalWorldClassRewardState(nMinLevel, nMaxLevel)
    for nLv = nMinLevel, nMaxLevel do
        local nIndex = math.ceil(nLv / 8)
        local bActive = ((1 << (nLv - (nIndex - 1) * 8 - 1)) & self.tbWorldClassRewardState[nIndex]) > 0
        if bActive then
            self.tbWorldClassRewardState[nIndex] = self.tbWorldClassRewardState[nIndex] & ~(1 << (nLv - (nIndex - 1) * 8 - 1))
        end
    end
    PlayerData.Base:RefreshWorldClassRedDot()
end
function PlayerStateData:ResetAllWorldClassRewardState()
    for k, _ in pairs(self.tbWorldClassRewardState) do
        self.tbWorldClassRewardState[k] = 0
    end
    PlayerData.Base:RefreshWorldClassRedDot()
end
function PlayerStateData:SetMailOverflow(bOverflow)
    self.bMailOverflow = bOverflow
end
function PlayerStateData:GetMailOverflow()
    return self.bMailOverflow
end
function PlayerStateData:SetStarTowerSweepState(bInSweep)
    self.bInStarTowerSweep = bInSweep
end
function PlayerStateData:GetStarTowerSweepState()
    return self.bInStarTowerSweep
end
------------------ 红点相关 -------------

--升阶奖励红点
--有奖励可领取时显示红点
function PlayerStateData:RefreshCharAdvanceRewardRedDot()
    local tbAdvanceLevel = PlayerData.Char:GetAdvanceLevelTable()
    for charId, v in pairs(self.tbCharAdvanceRewards) do
        local charCfg = ConfigTable.GetData_Character(charId)
        if nil ~= charCfg then
            local nGrade = charCfg.Grade
            local tbLevelAttr = tbAdvanceLevel[nGrade]
            local maxAdvance = #tbLevelAttr - 1
            for i = 1, maxAdvance do
                local bReceive = (v >> (i - 1) & 1) == 1
                RedDotManager.SetValid(RedDotDefine.Role_AdvanceReward, {charId, i}, bReceive)
            end
        end
    end
end

return PlayerStateData