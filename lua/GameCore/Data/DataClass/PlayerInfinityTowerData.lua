local PlayerInfinityTowerData = class("PlayerInfinityTowerData")
local LocalData = require "GameCore.Data.LocalData"
local newDayTime = UTILS.GetDayRefreshTimeOffset()

function PlayerInfinityTowerData:Init()
    self.selBuildId = {}
    self.againOrNextLv = 0
    self.itDifficultyData = {} --难度表
    --self.itLevelData = {} --表数据

    --self.itMsgData = {} --服务端数据
    self:HandleITDifficultyData() --处理原始表
    self:HandleMsgData()
    self.InfinityTowerRewardsTab = {}
    self.isGetITInfo = false

    self.BountyLevel = 0 -- 擂台赏金等级
    self.tabPlotsIds = {} --已领奖励的剧情ID列表
    self.tabUnLockPlotsIds = {}--已解锁的剧情ID列表（已领则已解锁）
    self.UnLockTower = {} --已解锁塔Id
    self.NextLevelId = 0

    self.cacheCharTid = nil
    EventManager.Add(EventId.IsNewDay, self, self.OnEvent_NewDay)

    --EventManager.Add(EventId.UpdateWorldClass, self, self.OnEvent_UpdateWorldClass)
    self.isAutoNextLv = false

    self.TwinNpcId = 173174
    self.TabVoiceNpc = {}
end

function PlayerInfinityTowerData:UnInit()
    EventManager.Remove(EventId.IsNewDay, self, self.OnEvent_NewDay)
    --EventManager.Remove(EventId.UpdateWorldClass, self, self.OnEvent_UpdateWorldClass)
end

function PlayerInfinityTowerData:OnEvent_NewDay()
    --self:UpdateInfinityDaily(true)
    --每天奖励可领奖
    self:UpdateBountyRewardState(self.BountyLevel)
end

function PlayerInfinityTowerData:HandleITDifficultyData()
    local itLevelData = {}
    local itTowrtDiffFloorCount = {}
    local itTowrtDiffFirstFloor = {}
    local itTowrtDiffEndFloor = {}
    local function foreach_Base(baseData)
        if itLevelData[baseData.DifficultyId] == nil then
            itLevelData[baseData.DifficultyId] = {}
        end
        if itTowrtDiffFloorCount[baseData.DifficultyId] == nil then
            itTowrtDiffFloorCount[baseData.DifficultyId] = 0
            itTowrtDiffFirstFloor[baseData.DifficultyId] = 9999
            itTowrtDiffEndFloor[baseData.DifficultyId] = 0
        end
        if baseData.Floor < itTowrtDiffFirstFloor[baseData.DifficultyId] then
            itTowrtDiffFirstFloor[baseData.DifficultyId] = baseData.Floor
        end
        if baseData.Floor > itTowrtDiffEndFloor[baseData.DifficultyId] then
            itTowrtDiffEndFloor[baseData.DifficultyId] = baseData.Floor
        end
        itTowrtDiffFloorCount[baseData.DifficultyId] = itTowrtDiffFloorCount[baseData.DifficultyId] + 1
        itLevelData[baseData.DifficultyId][baseData.Floor] = baseData
    end
    ForEachTableLine(DataTable.InfinityTowerLevel,foreach_Base)

    local function foreach_Base(baseData)
        if self.itDifficultyData[baseData.TowerId] == nil then
            self.itDifficultyData[baseData.TowerId] = {}
            self.itDifficultyData[baseData.TowerId].LastLvId = 0
            self.itDifficultyData[baseData.TowerId].ChallengeIds = {}
            self.itDifficultyData[baseData.TowerId].Diff = {}
            self.itDifficultyData[baseData.TowerId].totalLevleCount = 0
        end
        local tab = {
            diff = baseData,
            level = itLevelData[baseData.Id],
            diffLevelCount = itTowrtDiffFloorCount[baseData.Id] or 0,
            firstFloor = itTowrtDiffFirstFloor[baseData.Id] or 0,
            endFloor = itTowrtDiffEndFloor[baseData.Id] or 0,
        }
        self.itDifficultyData[baseData.TowerId].Diff[baseData.Sort] = tab
        --printError("baseData.TowerId === " .. baseData.TowerId)
        self.itDifficultyData[baseData.TowerId].totalLevleCount = self.itDifficultyData[baseData.TowerId].totalLevleCount + tab.diffLevelCount
    end
    ForEachTableLine(DataTable.InfinityTowerDifficulty,foreach_Base)
end

------------服务端数据---------------
--function PlayerInfinityTowerData:OnEvent_UpdateWorldClass()
--    if self.isHaveDailyReward then
--        local worldClass = PlayerData.Base:GetWorldClass()
--        local openClass = ConfigTable.GetData("OpenFunc", GameEnum.OpenFuncType.InfinityTower).NeedWorldClass
--        if worldClass >= openClass then
--            self:UpdateInfinityDaily(self.isHaveDailyReward)
--        end
--    end
--end

function PlayerInfinityTowerData:InfinityTowerRewardsStateNotify(mapMsgData)
    local rewardLv = mapMsgData.Value
    self:UpdateBountyRewardState(rewardLv)
end

function PlayerInfinityTowerData:UpdateBountyRewardState(lv)
    local function foreach_Base(baseData)
        if baseData.Level == lv then
            if baseData.RewardDropId ~= 0 then
                self:UpdateInfinityDaily(true)
            end
        end
    end
    ForEachTableLine(DataTable.InfinityTowerBountyLevel,foreach_Base)
end

function PlayerInfinityTowerData:UpdateInfinityDaily(isHave)
    self.isHaveDailyReward = isHave
    local worldClass = PlayerData.Base:GetWorldClass()
    local openClass = ConfigTable.GetData("OpenFunc", GameEnum.OpenFuncType.InfinityTower).NeedWorldClass
    if worldClass >= openClass then
        --临时屏蔽
        --RedDotManager.SetValid(RedDotDefine.Map_InfinityTowerDaily, nil, self.isHaveDailyReward)
    end
end

--申请无尽塔关卡数据
--1710901632  测试build id
function PlayerInfinityTowerData:GetITInfoReq()
    --printError("GetITInfoReq GetITInfoReq")
    local function msgCallback(_, mapMsgData)
        self:CacheInfinityData(mapMsgData)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.infinity_tower_info_req, {}, nil, msgCallback)
end

function PlayerInfinityTowerData:CacheInfinityData(mapMsgData)

    self.BountyLevel = 0--mapMsgData.BountyLevel -- 擂台赏金等级（临时屏蔽）
    for i, v in pairs(mapMsgData.PlotsIds) do
        self.tabPlotsIds[v] = true
    end

    for i, v in pairs(mapMsgData.Infos) do
        self.itDifficultyData[v.Id].LastLvId = v.LevelId
        for i1, v1 in pairs(v.ChallengeIds) do
            table.insert(self.itDifficultyData[v.Id].ChallengeIds,v1)
        end
    end

    if not self.isGetITInfo then
        EventManager.Hit("Get_InfinityTower_InfoReq")
    end
    self.isGetITInfo = true
    self:HandPlotMsg()
end

--申请进入无尽塔
--lid 关卡ID
--bid BuildId
--11001
--1726653663
function PlayerInfinityTowerData:EnterITApplyReq(nLevelId,nBuildId,isTip)

    if self.nPrevBuildId ~= nBuildId then
        self:ClearCharDamageData()
    end
    self.nPrevBuildId = nBuildId

    if isTip then
        local TipsTime = LocalData.GetPlayerLocalData("IntinityT_Tips_Time")
        local _tipDay = 0
        if TipsTime ~= nil then
            _tipDay = tonumber(TipsTime)
        end
        local curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
        local fixedTimeStamp = curTimeStamp - newDayTime * 3600
        local nYear = tonumber(os.date("!%Y", fixedTimeStamp))
        local nMonth = tonumber(os.date("!%m", fixedTimeStamp))
        local nDay = tonumber(os.date("!%d", fixedTimeStamp))
        local nowD = nYear * 366 + nMonth * 31 + nDay
        if nowD == _tipDay then
            self:SendEnterITApplyReq(nLevelId,nBuildId,false)
        else
            local function GetBuildCallback(mapBuildData)
                local recLv = ConfigTable.GetData("InfinityTowerLevel", nLevelId).RecommendLv
                local recRank = ConfigTable.GetData("InfinityTowerLevel", nLevelId).RecommendBuildRank
                local charTid = mapBuildData.tbChar[1].nTid
                local charData = PlayerData.Char:GetCharDataByTid(charTid)
                if charData ~= nil then
                    if charData.nLevel >= recLv and PlayerData.Build:CalBuildRank(mapBuildData.nScore).Id >= recRank then
                        --HttpNetHandler.SendMsg(NetMsgId.Id.infinity_tower_apply_req, msg, nil, msgCallback)
                        self:SendEnterITApplyReq(nLevelId,nBuildId,false)
                    else
                        local isSelectAgain = false
                        local function confirmCallback()
                            if isSelectAgain then
                                local _curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
                                local _fixedTimeStamp = _curTimeStamp - newDayTime * 3600
                                local _nYear = tonumber(os.date("!%Y", _fixedTimeStamp))
                                local _nMonth = tonumber(os.date("!%m", _fixedTimeStamp))
                                local _nDay = tonumber(os.date("!%d", _fixedTimeStamp))
                                local _nowD = _nYear * 366 + _nMonth * 31 + _nDay
                                LocalData.SetPlayerLocalData("IntinityT_Tips_Time",tostring(_nowD))
                            end
                            self:SendEnterITApplyReq(nLevelId,nBuildId,false)
                        end
                        local function againCallback(isSelect)
                            isSelectAgain = isSelect
                            --printError(tostring(isSelect))
                        end
                        local msg = {
                            nType = AllEnum.MessageBox.Confirm,
                            sContent = ConfigTable.GetUIText("InfinityTower_Recommend_Tips"),
                            callbackConfirm = confirmCallback,
                            callbackAgain = againCallback,
                            bBlur = false
                        }
                        EventManager.Hit(EventId.OpenMessageBox, msg)
                    end
                else
                    self:SendEnterITApplyReq(nLevelId,nBuildId,false)
                end
            end
            PlayerData.Build:GetBuildDetailData(GetBuildCallback,nBuildId)
        end
    else
        self:SendEnterITApplyReq(nLevelId,nBuildId,false)
    end
end

function PlayerInfinityTowerData:SendEnterITApplyReq(nLevelId,nBuildId,isAgainNext)
    self._EntryTime = CS.ClientManager.Instance.serverTimeStampWithTimeZone
    self._Build_id = nBuildId
    self._Level_id = nLevelId
    local msg = {}
    msg.LevelId = nLevelId
    msg.BuildId = nBuildId
    local function msgCallback()
        if isAgainNext then
            EventManager.Hit("Infinity_Tower_AgainOrNext")
            CS.AdventureModuleHelper.LevelStateChanged(false)
        else
            self:EnterInfinityTower(nLevelId,nBuildId,false)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.infinity_tower_apply_req, msg, nil, msgCallback)
end

function PlayerInfinityTowerData:EnterInfinityTowerAgainNext()
    if  self.againOrNextLv ~= 0 then
        local lvData = ConfigTable.GetData("InfinityTowerLevel", self.againOrNextLv)
        local _diff = lvData.DifficultyId
        local diffData = ConfigTable.GetData("InfinityTowerDifficulty", _diff)
        local _towerId = diffData.TowerId
        local build = self.selBuildId[_towerId] or 0
        self:EnterInfinityTower(self.againOrNextLv,build,true)
    end
end

function PlayerInfinityTowerData:RefreshCharDamageData(tbCharId)
    self.tbCharDamage = {}
    local tbCurrDamage = {}
    for i = 1, #tbCharId do
        local damage = CS.AdventureModuleHelper.GetCharacterDamage(tbCharId[i], false)
        local actorInfo = {}
        actorInfo.nCharId = tbCharId[i]
        actorInfo.nDamage = damage
        table.insert(tbCurrDamage, actorInfo)
    end
    
    if self.tbPrevDamage == nil then
        self.tbCharDamage = tbCurrDamage
    else
        -- 无尽塔的伤害统计各层累加，需要减去上一层的伤害
        for i = 1, #tbCurrDamage do
            local nDmg = tbCurrDamage[i].nDamage - self.tbPrevDamage[tbCurrDamage[i].nCharId] or 0
            table.insert(self.tbCharDamage, {nCharId = tbCurrDamage[i].nCharId, nDamage = nDmg})
        end
    end
    
    -- 记录当前的伤害数据，作为下一层的前一层数据
    self.tbPrevDamage = {}
    for k, v in pairs(tbCurrDamage) do
        self.tbPrevDamage[v.nCharId] = v.nDamage
    end
end

function PlayerInfinityTowerData:ClearCharDamageData()
    self.tbPrevDamage = nil
    self.tbCharDamage = nil
end

--申请结算无尽塔关卡 Value:1胜利,2失败,3退出
function PlayerInfinityTowerData:ITSettleReq(val, time, tbCharId)
    local msg = {}
    msg.Value = val
    msg.Events = {List = PlayerData.Achievement:GetBattleAchievement(GameEnum.levelType.InfinityTower,val == 1)}
    self:RefreshCharDamageData(tbCharId)
    --printError("val  ==== " .. val)
    local function msgCallback(_,mapMsgData)
        local lvData = ConfigTable.GetData("InfinityTowerLevel", self.currentLevel)
        local _diff = lvData.DifficultyId
        local diffData = ConfigTable.GetData("InfinityTowerDifficulty", _diff)
        local _towerId = diffData.TowerId
        self:SetSelectLvSortId(diffData.Sort)
        if val == 1 then
            --胜利
            local lastLvId = self.itDifficultyData[_towerId].LastLvId
            if lastLvId ~= 0 then
                local lastlvData = ConfigTable.GetData("InfinityTowerLevel", lastLvId)
                local _lastdiff = lastlvData.DifficultyId
                if _lastdiff == _diff then
                    if lastlvData.Floor < lvData.Floor then
                        if lvData.LevelType ~= GameEnum.InfinityTowerLevelType.Challenge then
                            self.itDifficultyData[_towerId].LastLvId = self.currentLevel
                        else
                            table.insert(self.itDifficultyData[_towerId].ChallengeIds,self.currentLevel)
                        end
                    end
                elseif _lastdiff < _diff then
                    if lvData.LevelType ~= GameEnum.InfinityTowerLevelType.Challenge then
                        self.itDifficultyData[_towerId].LastLvId = self.currentLevel
                    else
                        table.insert(self.itDifficultyData[_towerId].ChallengeIds,self.currentLevel)
                    end
                end
            else
                if lvData.LevelType ~= GameEnum.InfinityTowerLevelType.Challenge then
                    self.itDifficultyData[_towerId].LastLvId = self.currentLevel
                else
                    table.insert(self.itDifficultyData[_towerId].ChallengeIds,self.currentLevel)
                end
            end

            self.NextLevelId = mapMsgData.NextLevelId
            self.LastBountyLevel = self.BountyLevel
            self.BountyLevel = 0--mapMsgData.BountyLevel  --临时屏蔽
            local tabItem = {}
            for k, v in pairs(mapMsgData.Show) do
                table.insert(tabItem, {Tid = v.Tid, Qty = v.Qty, rewardType = AllEnum.RewardType.First})
            end
            --UTILS.OpenReceiveByDisplayItem(tabItem, mapMsgData.Change)
            local tmpPlotId = self:CheckLevelSetPlot()
            EventManager.Hit("Infinity_Tower_SettleSuccess",true,time,tabItem,mapMsgData.Change,tmpPlotId, self.tbCharDamage)
            self:SetBreakoutMsgData(self.currentLevel)
            self.isLevelClear = true
        elseif val == 2 then
            --失败
            EventManager.Hit("Infinity_Tower_SettleSuccess",false,time, nil, nil, nil, self.tbCharDamage)
            self.isLevelClear = false
        elseif val == 3 then
            EventManager.Hit("Infinity_Tower_SettleSuccess",false,time, nil, nil, nil, self.tbCharDamage)
            self.isLevelClear = false
        end

        ------埋点数据------
        self._EndTime = CS.ClientManager.Instance.serverTimeStampWithTimeZone
        local tabUpLevel = {}
        local tmpAuto = self:GetAutoNextLv() and "1" or "2"
        table.insert(tabUpLevel,{"role_id",tostring(PlayerData.Base._nPlayerId)})
        table.insert(tabUpLevel,{"is_auto",tmpAuto})
        table.insert(tabUpLevel,{"game_cost_time",tostring(time)})
        table.insert(tabUpLevel,{"real_cost_time",tostring(self._EndTime - self._EntryTime)})
        table.insert(tabUpLevel,{"build_id",tostring(self._Build_id)})
        table.insert(tabUpLevel,{"battle_id",tostring(self._Level_id)})
        table.insert(tabUpLevel,{"battle_result",tostring(val)})
        NovaAPI.UserEventUpload("infinity_tower_battle",tabUpLevel)
        ------埋点数据------
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.infinity_tower_settle_req, msg, nil, msgCallback)
end

--请求领取无尽塔每日奖励
function PlayerInfinityTowerData:ITDailyRewardReq()
    local function msgCallback(_,mapMsgData)
        local tabItem = {}
        for k, v in pairs(mapMsgData.Show) do
            table.insert(tabItem, {Tid = v.Tid, Qty = v.Qty})
        end
        UTILS.OpenReceiveByDisplayItem(tabItem, mapMsgData.Change)
        self:UpdateInfinityDaily(false)
        EventManager.Hit("InfinityTower_DailyCallback")
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.infinity_tower_daily_reward_receive_req, {}, nil, msgCallback)
end

--请求领取无尽塔剧情奖励
function PlayerInfinityTowerData:ITPlotRewardReq(plotId)
    local msg = {}
    msg.Value = plotId
    local function msgCallback(_,mapMsgData)
        local tabItem = {}
        for k, v in pairs(mapMsgData.Show) do
            table.insert(tabItem, {Tid = v.Tid, Qty = v.Qty, rewardType = AllEnum.RewardType.First})
        end
        UTILS.OpenReceiveByDisplayItem(tabItem, mapMsgData.Change)
        self.tabPlotsIds[plotId] = true
        local isHave = false
        for i, v in pairs(self.tabUnLockPlotsIds) do
            if self.tabPlotsIds[i] == nil then
                isHave = true
                break
            end
        end
        RedDotManager.SetValid(RedDotDefine.Map_InfinityTowerPlot, nil, isHave)
        EventManager.Hit("Refresh_Infinity_PlotList")
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.infinity_tower_plot_reward_receive_req, msg, nil, msgCallback)
end
------------进入无尽塔关卡------------
function PlayerInfinityTowerData:EnterInfinityTower(lvId,buildId,isContinue)
    --printError("lvId ======== " .. lvId)
    self.isContinue = isContinue
    self.currentLevel = lvId
    local lvData = ConfigTable.GetData("InfinityTowerLevel", lvId)
    if lvData == nil then
        printError("无尽塔floorData 为空,lvData id === " .. lvId)
        return
    end
    local floorData = ConfigTable.GetData("InfinityTowerFloor", lvData.FloorId)
    if floorData == nil then
        printError("无尽塔floorData 为空,floor id === " .. lvData.FloorId)
        return
    end
    if self.curLevel == nil then
        local luaClass =  require "Game.Adventure.InfinityTower.InfinityTowerLevel"
        if luaClass == nil then
            return
        end
        self.curLevel = luaClass
    end
    local lvData = ConfigTable.GetData("InfinityTowerLevel", lvId)
    local _diff = lvData.DifficultyId
    local diffData = ConfigTable.GetData("InfinityTowerDifficulty", _diff)
    local _towerId = diffData.TowerId
    LocalData.SetPlayerLocalData("IntinityT_Select_Build_" .._towerId,buildId)
    self.selBuildId[_towerId] = buildId
    if type(self.curLevel.BindEvent) == "function" and self.againOrNextLv == 0 then
        self.curLevel:BindEvent()
    end
    if type(self.curLevel.Init) == "function" then
        self.curLevel:Init(self,floorData.Id,buildId,self.againOrNextLv,isContinue)
    end
    self.againOrNextLv = 0
    self.NextLevelId = 0
end

function PlayerInfinityTowerData:CacheBuildCharTid(tab)
    self.cacheCharTid = tab
end

function PlayerInfinityTowerData:EnterInfinityTowerEditor(floorId,tbChar, tbDisc, tbNote)
    self.currentLevel = 11001
    local floorData = ConfigTable.GetData("InfinityTowerFloor", floorId)
    if floorData == nil then
        printError("无尽塔floorData 为空,floor id === " .. floorId)
        return
    end
    local luaClass =  require "Game.Adventure.InfinityTower.InfinityTowerEditor"
    if luaClass == nil then
        return
    end
    self.curLevel = luaClass
    if type(self.curLevel.BindEvent) == "function" then
        self.curLevel:BindEvent()
    end
    if type(self.curLevel.Init) == "function" then
        self.curLevel:Init(self,floorId,tbChar, tbDisc, tbNote)
    end
end

function PlayerInfinityTowerData:GetFloorAffixBuff(tbCharId,floorId)
    local floorData = ConfigTable.GetData("InfinityTowerFloor", floorId)
    local tabAffix = floorData.AffixId
    local tabBuff = {}
    if #tabAffix > 0 then
        for i = 1, #tabAffix do
            local itAffixData = ConfigTable.GetData("InfinityTowerAffix", tabAffix[i])
            if itAffixData.TriggerCondition == 1 then
                local param = decodeJson(itAffixData.TriggerParam)
                local paramEET = param[1]
                local paramCount = param[2] or 0
                local tmpCount = 0
                for i, v in pairs(tbCharId) do
                    local tmpCharacter = ConfigTable.GetData_Character(v)
                    --printError(tmpCharacter.EET .. "  " .. paramEET)
                    if tmpCharacter and tmpCharacter.EET == paramEET then
                        tmpCount = tmpCount + 1
                    end
                end
                if tmpCount >= paramCount then
                    for i, v in pairs(itAffixData.AddCamp) do
                        table.insert(tabBuff,v)
                    end
                end
            elseif itAffixData.TriggerCondition == 2 then
                --暂不处理
            elseif itAffixData.TriggerCondition == 0 then
                for i, v in pairs(itAffixData.AddCamp) do
                    table.insert(tabBuff,v)
                end
            end
        end
    end
    return tabBuff

end

function PlayerInfinityTowerData:LevelEnd()
    if nil ~= self.curLevel and type(self.curLevel.UnBindEvent) == "function" then
        self.curLevel:UnBindEvent()
    end
    self.curLevel = nil
    self.againOrNextLv = 0
    self:ClearCharDamageData()
    self.nPrevBuildId = nil
end

function PlayerInfinityTowerData:GetCurrentLv()
    return self.currentLevel
end

------------关卡解锁相关-------
--是否开放（周几）
function PlayerInfinityTowerData:CheckOpenDay(index)
    local mapData = ConfigTable.GetData("InfinityTower", index)
    if mapData == nil then
        return false
    end
    if #mapData.OpenDay == 0 then
        return false
    end
    local curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
    local fixedTimeStamp = curTimeStamp - newDayTime * 3600
    local nWeek = tonumber(os.date("!%w", fixedTimeStamp))
    --printError("nWeek === " .. nWeek)
    return table.indexof(mapData.OpenDay,nWeek) > 0
end

function PlayerInfinityTowerData:GetNextDaySec(index)
    local curTimeStamp =  CS.ClientManager.Instance.serverTimeStampWithTimeZone
    local fixedTimeStamp = curTimeStamp - newDayTime * 3600
    local weekday_utc =tonumber(os.date("!%w", fixedTimeStamp))
    local target_weekday = 0
    local mapData = ConfigTable.GetData("InfinityTower", index)
    for i, v in pairs(mapData.OpenDay) do
        if weekday_utc < v then
            target_weekday = v
            break
        end
    end
    --printError(index .. "   " .. target_weekday)
    -- 计算到下一个目标星期几需要几天（如果今天就是目标天，则为 0）
    local days_to_target = (target_weekday - weekday_utc + 7) % 7
    local nHour = tonumber(os.date("!%H", fixedTimeStamp))
    local nMin = tonumber(os.date("!%M", fixedTimeStamp))
    local nSec = tonumber(os.date("!%S", fixedTimeStamp))
    local totalSec = days_to_target * 86400 - (nHour * 3600 + nMin * 60 + nSec)
    return totalSec
end
--塔是否解锁
function PlayerInfinityTowerData:CheckTowerUnLock(towerId,PreTowerLevelId)
    if self.UnLockTower[towerId] then
        return true
    end
    if PreTowerLevelId == 0 then
        self.UnLockTower[towerId] = true
        return true
    end

    local lvData = ConfigTable.GetData("InfinityTowerLevel", PreTowerLevelId)
    local _diff = lvData.DifficultyId
    local _diffData = ConfigTable.GetData("InfinityTowerDifficulty", _diff)
    local _towerId = _diffData.TowerId

    local _lastLvId = self.itDifficultyData[_towerId].LastLvId
    if _lastLvId == 0 then
        return false
    end
    local lvLastData = ConfigTable.GetData("InfinityTowerLevel", _lastLvId)
    local _lastDiff = lvLastData.DifficultyId
    if _lastDiff > _diff then
        self.UnLockTower[towerId] = true
        return true
    elseif _lastDiff == _diff then
        if lvData.Floor <= lvLastData.Floor then
            self.UnLockTower[towerId] = true
            return true
        else
            return false
        end
    else
        return false
    end
end

--是否满足世界等级
function PlayerInfinityTowerData:CheckLockWorldClass(ChooseLevelId)
    local lvData = ConfigTable.GetData("InfinityTowerLevel", ChooseLevelId)
    local _diff = lvData.DifficultyId
    local _diffData = ConfigTable.GetData("InfinityTowerDifficulty", _diff)
    local _unlockWorldClass = _diffData.UnlockWorldClass
    local worldClass = PlayerData.Base:GetWorldClass()
    if worldClass >= _unlockWorldClass then
        return false
    end
    return true
end
--塔是否全部通过
function PlayerInfinityTowerData:GetTowerPassAll(towerId)
    local _lastLvId = self.itDifficultyData[towerId].LastLvId
    if _lastLvId == 0 then
        return false
    end
    local lvLastData = ConfigTable.GetData("InfinityTowerLevel", _lastLvId)
    local lvLastFloor = lvLastData.Floor

    local towerTotalLvCount = self.itDifficultyData[towerId].totalLevleCount
    if lvLastFloor == towerTotalLvCount then
        return true
    end
    return false
end

--塔中不同难度关卡是否全部通关
function PlayerInfinityTowerData:GetTowerDiffPassAll(towerId,diffSort)
    local _lastLvId = self.itDifficultyData[towerId].LastLvId
    if _lastLvId == 0 then
        return false
    end
    local lvLastData = ConfigTable.GetData("InfinityTowerLevel", _lastLvId)
    local diffData = self:GetTowerDiffData(towerId,diffSort)
    --printError( lvLastData.Floor .. "  " .. diffData.firstFloor .. "  " .. diffData.endFloor)
    if lvLastData.Floor >=  diffData.endFloor then
        return true
    end
    return false
end

--判断关卡是否完成
function PlayerInfinityTowerData:JudgeLevelPass(towerId,levelId)
    local _lastLvId = self.itDifficultyData[towerId].LastLvId
    if _lastLvId == 0 then
        return false
    end
    local lvLastData = ConfigTable.GetData("InfinityTowerLevel", _lastLvId)
    local lvData = ConfigTable.GetData("InfinityTowerLevel", levelId)
    if lvData.Floor <= lvLastData.Floor then
        return true
    end
    return false
end

--判断关卡是否可挑战关卡
function PlayerInfinityTowerData:JudgeLevelCanChallenge(towerId,levelId)
    local _lastLvId = self.itDifficultyData[towerId].LastLvId
    local lvData = ConfigTable.GetData("InfinityTowerLevel", levelId)
    if _lastLvId == 0 then
        if lvData.Floor == 1 then
            return true
        end
        return false
    end
    local lvLastData = ConfigTable.GetData("InfinityTowerLevel", _lastLvId)
    if lvData.Floor == lvLastData.Floor + 1 then
        return true
    end
    return false
end

--判断关卡是否未解锁
function PlayerInfinityTowerData:JudgeLevelLock(towerId,levelId)
    local _lastLvId = self.itDifficultyData[towerId].LastLvId
    local lvData = ConfigTable.GetData("InfinityTowerLevel", levelId)
    if _lastLvId == 0 then
        if lvData.Floor > 1 then
            return true
        end
        return false
    end
    local lvLastData = ConfigTable.GetData("InfinityTowerLevel", _lastLvId)
    if lvData.Floor >= lvLastData.Floor + 2 then
        return true
    end
    return false
end

--判断擂台等级晋级条件 及 剧情解锁条件
function PlayerInfinityTowerData:JudgeInfinityTowerCond(Cond,CondParam)
    if Cond == GameEnum.InfinityTowerCond.LevelClearWithSpecificId then
        local lvId = CondParam[1]
        local lvData = ConfigTable.GetData("InfinityTowerLevel", lvId)
        local diff = lvData.DifficultyId
        local diffData = ConfigTable.GetData("InfinityTowerDifficulty", diff)
        local towerId = diffData.TowerId
        local towerLastLvId = self.itDifficultyData[towerId].LastLvId
        if towerLastLvId == 0 then
            return false
        end
        local lvDataLastLv = ConfigTable.GetData("InfinityTowerLevel", towerLastLvId)
        if lvData.Floor <= lvDataLastLv.Floor then
            return true
        end
        return false
    elseif Cond == GameEnum.InfinityTowerCond.InfinityTowerWithSpecificLevelTotal then
        local CondPassCount = CondParam[1]
        local totalPassCount = 0
        for i, v in pairs(self.itDifficultyData) do
            if v.LastLvId ~= 0 then
                local lastLv = v.LastLvId
                local lvData = ConfigTable.GetData("InfinityTowerLevel", lastLv)
                totalPassCount = totalPassCount + lvData.Floor
            end
        end
        if totalPassCount >= CondPassCount then
            return true
        end
        return false
    elseif Cond == GameEnum.InfinityTowerCond.AnyTowerWithSpecificTotalLevel then
        local CondCount = CondParam[1]
        local CondFloor = CondParam[2]
        local count = 0
        for i, v in pairs(self.itDifficultyData) do
            if v.LastLvId ~= 0 then
                local lastLv = v.LastLvId
                local lvData = ConfigTable.GetData("InfinityTowerLevel", lastLv)
                if lvData.Floor >= CondFloor then
                    count = count + 1
                end
            end
        end
        if count >= CondCount then
            return true
        end
        return false
    elseif Cond == GameEnum.InfinityTowerCond.BountyLevelSpecific then
        if self.BountyLevel >= CondParam[1] then
            return true
        end
        return false
    end
    return true
end

--判断Build 是否可以进入无尽塔
function PlayerInfinityTowerData:JudgeInfinityTowerBuildCanUse(tbCharTid,levelId)
    local lvData = ConfigTable.GetData("InfinityTowerLevel", levelId)
    local Cond = lvData.EntryCond
    local CondParam = lvData.EntryCondParam
    if Cond == GameEnum.InfinityTowerCond.MasterCharactersWithSpecificElementType then
        local charId = tbCharTid[1]
        local charData = ConfigTable.GetData_Character(charId)
        if charData.EET == CondParam[1] then
            return true
        end
        return false
    elseif Cond == GameEnum.InfinityTowerCond.ElementTypeWithSpecificQuantityNoLessThanQuantity then
        local count = 0
        for i, v in pairs(tbCharTid) do
            local charId = v
            local charData = ConfigTable.GetData_Character(charId)
            if charData.EET == CondParam[1] then
                count = count + 1
            end
        end
        return count >= CondParam[2]
    elseif Cond == GameEnum.InfinityTowerCond.ElementTypeWithSpecificQuantityNoMoreThanQuantity then
        local count = 0
        for i, v in pairs(tbCharTid) do
            local charId = v
            local charData = ConfigTable.GetData_Character(charId)
            if charData.EET == CondParam[1] then
                count = count + 1
            end
        end
        return count <= CondParam[2]
    end
    return true
end

------------关卡解锁相关结束---------

---------获取表数据--------------
function PlayerInfinityTowerData:GetTowerDiffCount(towerId)
    return #self.itDifficultyData[towerId].Diff
end

function PlayerInfinityTowerData:GetTowerDiffData(towerId,sortId)
    return self.itDifficultyData[towerId].Diff[sortId]
end

function PlayerInfinityTowerData:GetTowerPassFloor(towerId)
    local _lastLvId = self.itDifficultyData[towerId].LastLvId
    if _lastLvId == 0 then
       return 0
    end
    local lvData = ConfigTable.GetData("InfinityTowerLevel", _lastLvId)
    if lvData then
        return lvData.Floor
    end
    return 0
end

function PlayerInfinityTowerData:GetTowerPassLv(towerId)
    return self.itDifficultyData[towerId].LastLvId
end

function PlayerInfinityTowerData:GetTowerLayerData(towerId,floor)
    --return self.itLevelData[towerId][floor]
    return nil
end
---------获取表数据结束-----------
function PlayerInfinityTowerData:GetCachedBuildId(lvId)
    local lvData = ConfigTable.GetData("InfinityTowerLevel", lvId)
    local diff = lvData.DifficultyId
    local diffData = ConfigTable.GetData("InfinityTowerDifficulty", diff)
    local towerId = diffData.TowerId
    return self.selBuildId[towerId] or 0
end

function PlayerInfinityTowerData:GetSaveBuildId(lvId)
    local lvData = ConfigTable.GetData("InfinityTowerLevel", lvId)
    local diff = lvData.DifficultyId
    local diffData = ConfigTable.GetData("InfinityTowerDifficulty", diff)
    local towerId = diffData.TowerId
    local tmpBuild = LocalData.GetPlayerLocalData("IntinityT_Select_Build_" ..towerId)
    if tmpBuild ~= nil then
        --printError(tmpBuild)
        return tonumber(tmpBuild)
    end
    return 0
end

function PlayerInfinityTowerData:SetSelBuildId(nBuildId,lvId)
    local lvData = ConfigTable.GetData("InfinityTowerLevel", lvId)
    local diff = lvData.DifficultyId
    local diffData = ConfigTable.GetData("InfinityTowerDifficulty", diff)
    local towerId = diffData.TowerId
    self.selBuildId[towerId] = nBuildId
end

function PlayerInfinityTowerData:GetInitInfoState()
    return self.isGetITInfo
end

---------再次挑战或者进入进入下一关---------
function PlayerInfinityTowerData:AnginOrNextLv(isAgain)
    self.againOrNextLv = 0
    if isAgain then
        self.againOrNextLv = self.currentLevel
        return true,self.againOrNextLv
    else

        if self.NextLevelId ~= 0 then
            self.againOrNextLv = self.NextLevelId
            return true,self.NextLevelId
        else
            return false,0
        end
    end
end

function PlayerInfinityTowerData:GoAnginOrNextLv()
    if self.againOrNextLv ~= 0 then
        local lvData = ConfigTable.GetData("InfinityTowerLevel", self.againOrNextLv)
        local _diff = lvData.DifficultyId
        local diffData = ConfigTable.GetData("InfinityTowerDifficulty", _diff)
        local _towerId = diffData.TowerId
        local build = self.selBuildId[_towerId] or 0
        self:SendEnterITApplyReq(self.againOrNextLv,build ,true)
    end

end

-----------BottonMsg----------
---
function PlayerInfinityTowerData:HandleMsgData()
    self.bottomList_Daily = {}
    self.bottomList_Breakout = {}
    self.bottomList_News = {}
    local function foreach_Base(baseData)
        if baseData.Type == GameEnum.InfinityTowerMsgType.Daily then
            for i, v in pairs(baseData.DayOfWeek) do
                if self.bottomList_Daily[v] == nil then
                    self.bottomList_Daily[v] = {}
                end
                table.insert(self.bottomList_Daily[v],baseData.Id)
            end
        elseif baseData.Type == GameEnum.InfinityTowerMsgType.Breakout then
            if baseData.Condition == GameEnum.InfinityTowerMsgConditions.SpecialLv then
                local tmpJ = decodeJson(baseData.Params)
                for _, lvId in pairs (tmpJ) do
                    self.bottomList_Breakout[lvId] = baseData.Id
                end
            end
        elseif baseData.Type == GameEnum.InfinityTowerMsgType.News then
            table.insert(self.bottomList_News,baseData.Id)
        end
    end
    ForEachTableLine(DataTable.InfinityTowerMsg,foreach_Base)
end

function PlayerInfinityTowerData:SetBreakoutMsgData(lvId)
    --if
    --LocalData.SetPlayerLocalData(sKey, sValue)
    if self.bottomList_Breakout[lvId] ~= nil then
        LocalData.SetPlayerLocalData("IntinityT_Breakout_Id", tostring(lvId))
        local curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
        local fixedTimeStamp = curTimeStamp - newDayTime * 3600
        LocalData.SetPlayerLocalData("IntinityT_Breakout_Time", tostring(fixedTimeStamp))
    end
end

function PlayerInfinityTowerData:RandomBottomMsg()
    self.randomBotMsg = {}
    local curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
    local fixedTimeStamp = curTimeStamp - newDayTime * 3600
    local nWeek = tonumber(os.date("!%w", fixedTimeStamp))

    --daily
    local tmpDayList = self.bottomList_Daily[nWeek]
    local nDayId = tmpDayList[math.random(1, #tmpDayList)]
    if nDayId ~= 0 then
        self.randomBotMsg[GameEnum.InfinityTowerMsgType.Daily] = nDayId
    end

    --Breakout
    local tmpBreakoutId = LocalData.GetPlayerLocalData("IntinityT_Breakout_Id")
    if tmpBreakoutId ~= nil then
        local saveTime = LocalData.GetPlayerLocalData("IntinityT_Breakout_Time")
        if  saveTime ~= nil then
            local nSaveWeek = tonumber(os.date("!%w", tonumber(saveTime)))
            if nWeek == nSaveWeek then
                self.randomBotMsg[GameEnum.InfinityTowerMsgType.Breakout] = self.bottomList_Breakout[tonumber(tmpBreakoutId)]
            else
                LocalData.DelPlayerLocalData("IntinityT_Breakout_Id")
                LocalData.DelPlayerLocalData("IntinityT_Breakout_Time")
            end
        end
    end
    --News
    self.randomBotMsg[GameEnum.InfinityTowerMsgType.News] = {}
    local tmpNews = {}
    for i, v in pairs(self.bottomList_News) do
        table.insert(tmpNews,v)
    end
    local tabLength = #tmpNews
    for i = 1, tabLength do
        local index = math.random(1, #tmpNews)
        local nNewsId = tmpNews[index]
        local _data = ConfigTable.GetData("InfinityTowerMsg", nNewsId)
        if table.indexof(_data.DayOfWeek,nWeek) > 0 then
            table.insert(self.randomBotMsg[GameEnum.InfinityTowerMsgType.News],nNewsId)
            if #self.randomBotMsg[GameEnum.InfinityTowerMsgType.News] == 3 then
                break
            end
        end
        table.remove(tmpNews,index)
    end
end

function PlayerInfinityTowerData:GetBottomMsgId(type,index)
    if type == GameEnum.InfinityTowerMsgType.News then
        return self.randomBotMsg[GameEnum.InfinityTowerMsgType.News][index]
    else
        return self.randomBotMsg[type]
    end
end
-----------BottonMsg----------

------剧情相关-----------
--self.tabPlotsIds
function PlayerInfinityTowerData:HandPlotMsg()
    local function foreach_Base(baseData)
        if self.tabPlotsIds[baseData.Id] then
            self.tabUnLockPlotsIds[baseData.Id] = true
        else
            local isUnlock = self:JudgeInfinityTowerCond(baseData.UnlockCond,baseData.CondParam)
            if isUnlock then
                RedDotManager.SetValid(RedDotDefine.Map_InfinityTowerPlot, nil, true)
                self.tabUnLockPlotsIds[baseData.Id] = true
            end
        end
    end
    ForEachTableLine(DataTable.InfinityTowerPlot,foreach_Base)
end
--获取剧情是否已解锁
function PlayerInfinityTowerData:GetPlotUnLock(plotId)
    if self.tabUnLockPlotsIds[plotId] then
        return true
    end
    return false
end
--获取剧情是否已领奖
function PlayerInfinityTowerData:GetPlotGetReward(plotId)
    if self.tabPlotsIds[plotId] then
        return true
    end
    return false
end
--关卡结束时检测是否有可播放的剧情
function PlayerInfinityTowerData:CheckLevelSetPlot()
    local tmpPlotId = 0
    local function foreach_Base(baseData)
        if not self.tabUnLockPlotsIds[baseData.Id] then
            local isUnlock = self:JudgeInfinityTowerCond(baseData.UnlockCond,baseData.CondParam)
            if isUnlock then
                tmpPlotId = baseData.Id
                RedDotManager.SetValid(RedDotDefine.Map_InfinityTowerPlot, nil, true)
                self.tabUnLockPlotsIds[baseData.Id] = true
            end
        end
    end
    ForEachTableLine(DataTable.InfinityTowerPlot,foreach_Base)

    return tmpPlotId
end

--播放剧情
function PlayerInfinityTowerData:PlayPlot(plotId)
    local plotData = ConfigTable.GetData("InfinityTowerPlot", plotId)
    local sAvgId = plotData.avgId
    local function avgEndCallback()
        EventManager.Remove("StoryDialog_DialogEnd",self,avgEndCallback)
        if self.tabPlotsIds[plotId] == nil then
            self:ITPlotRewardReq(plotId)
        end
    end
    EventManager.Add("StoryDialog_DialogEnd",self,avgEndCallback)
    EventManager.Hit("StoryDialog_DialogStart", sAvgId)
end
------剧情相关-----------

function PlayerInfinityTowerData:SetPageState(index)
    self.PageState = index
    if index == 1 then
        self.isLevelClear = false
    end
end

function PlayerInfinityTowerData:GetPageState()
    return self.PageState or 1
end

--self.isAutoNextLv = true
function PlayerInfinityTowerData:SetAutoNextLv(isAuto)
    self.isAutoNextLv = isAuto
end

function PlayerInfinityTowerData:GetAutoNextLv()
    return self.isAutoNextLv
end

--关卡内返回--
function PlayerInfinityTowerData:SetSelectLvSortId(sortId)
    self.selectDiffSort = sortId
end

function PlayerInfinityTowerData:GetSelectLvSortId()
    return self.selectDiffSort or 1
end
--关卡内返回--

--播放语音相关--
function PlayerInfinityTowerData:OnEvent_PlayTwinEffect()
    if not self.isContinue then
        PlayerData.Voice:PlayCharVoice("twin_effect", self.TwinNpcId,nil,true)
    end
    --self.TabVoiceNpc
end

function PlayerInfinityTowerData:GetNPCVoiceKey(NpcId)
    local isFirst = true
    if self.TabVoiceNpc[NpcId] then
        isFirst = false
    else
        self.TabVoiceNpc[NpcId] = true
    end
    local timeNow = CS.ClientManager.Instance.serverTimeStamp
    local nHour = tonumber(os.date("%H", timeNow))
    if nHour >= 6 and nHour < 12 then
        return isFirst, "greetmorn_npc"
    elseif nHour >= 12 and nHour < 18 then
        return isFirst, "greetnoon_npc"
    else
        return isFirst, "greetnight_npc"
    end

end

--播放语音相关--

return PlayerInfinityTowerData