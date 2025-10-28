
local PlayerEquipmentInstanceData =  class("PlayerEquipmentInstanceData")
local newDayTime = UTILS.GetDayRefreshTimeOffset()

function PlayerEquipmentInstanceData:Init()
    self.curLevel = nil
    self.mapAllLevel = {}
    self.bInSettlement = false   --是否在结算状态(避免结算重复进入)
    self.tbLastMaxHard = {}  --进入副本前已解锁最高等级记录
    self.mapLevelCfg = {}  --关卡配表数据
    self:InitConfigData()
    EventManager.Add("Equipment_Instance_Gameplay_Time", self, self.OnEvent_Time)
end

function PlayerEquipmentInstanceData:OnEvent_Time(nTime)
    self._TotalTime = nTime
end

function PlayerEquipmentInstanceData:UnInit()
    EventManager.Remove("Equipment_Instance_Gameplay_Time", self, self.OnEvent_Time)
end

function PlayerEquipmentInstanceData:InitConfigData()
    local function funcForeachLine(line)
        if nil == self.mapLevelCfg[line.Type] then
            self.mapLevelCfg[line.Type] = {}
        end
        self.mapLevelCfg[line.Type][line.Id] = line
    end
    ForEachTableLine(ConfigTable.Get("CharGemInstance"), funcForeachLine)
end

function PlayerEquipmentInstanceData:EnterEquipmentInstanceEditor(nFloor,tbChar, tbDisc, tbNote)
    if self.curLevel ~= nil then
        printError("当前关卡level不为空1")
        return
    end
    local luaClass =  require "Game.Adventure.EquipmentInstance.EquipmentInstanceEditor"
    if luaClass == nil then
        return
    end
    self.curLevel = luaClass
    if type(self.curLevel.BindEvent) == "function" then
        self.curLevel:BindEvent()
    end
    if type(self.curLevel.Init) == "function" then
        self.curLevel:Init(self,nFloor,tbChar, tbDisc, tbNote)
    end
end
function PlayerEquipmentInstanceData:EnterEquipmentInstance(nLevelId, nBuildId)
    if self.curLevel ~= nil then
        printError("当前关卡level不为空1")
        return
    end
    local luaClass =  require "Game.Adventure.EquipmentInstance.EquipmentInstanceLevel"
    if luaClass == nil then
        return
    end
    self.curLevel = luaClass
    if type(self.curLevel.BindEvent) == "function" then
        self.curLevel:BindEvent()
    end
    if type(self.curLevel.Init) == "function" then
        self.curLevel:Init(self,nLevelId, nBuildId)
    end
end
function PlayerEquipmentInstanceData:SetSelBuildId(nBuildId)
    self.selBuildId = nBuildId
end
function PlayerEquipmentInstanceData:GetCachedBuildId(nLevelId)
    if self.selBuildId ~= 0 and self.selBuildId ~= nil then
        local ret = self.selBuildId
        return ret
    end
    if nLevelId == 0 then
        return 0
    end
    if self.mapAllLevel[nLevelId] == nil then
        local mapLevelCfgData = ConfigTable.GetData("CharGemInstance", nLevelId)
        if mapLevelCfgData == nil then
            return 0
        end
        if mapLevelCfgData.PreLevelId ~= 0 then
            if self.mapAllLevel[mapLevelCfgData.PreLevelId] ~= nil then
                return self.mapAllLevel[mapLevelCfgData.PreLevelId].nBuildId
            else
                return 0
            end
        else
            return 0
        end
    end
    return self.mapAllLevel[nLevelId].nBuildId
end
function PlayerEquipmentInstanceData:CacheEquipmentInstanceLevel(tbData)
    if tbData == nil then
        return
    end
    for _, mapData in ipairs(tbData) do
        local t1 = mapData.Star >= 1
        local t2 = mapData.Star >= 2
        local t3 = mapData.Star >= 3
        local nStar = mapData.Star

        self.mapAllLevel[mapData.Id] = {nStar = nStar,nBuildId = mapData.BuildId,tbTarget = {t1,t2,t3}}
    end
end

function PlayerEquipmentInstanceData:GetEquipmentInstanceLevelUnlock(nLevelId)
    local mapLevelCfgData = ConfigTable.GetData("CharGemInstance", nLevelId)
    if mapLevelCfgData == nil then
        return false
    end
    if mapLevelCfgData.PreLevelId == 0 then
        return true
    end
    if PlayerData.Base:GetWorldClass() < mapLevelCfgData.NeedWorldClass then
        return false, mapLevelCfgData.NeedWorldClass
    end
    if self.mapAllLevel[mapLevelCfgData.PreLevelId] == nil then
        return false
    end
    if self.mapAllLevel[mapLevelCfgData.PreLevelId].nStar >= mapLevelCfgData.PreLevelStar then
        return true
    end
    return false
end

function PlayerEquipmentInstanceData:GetEquipmentInstanceUnlockMsg(nLevelId)
    local mapLevelCfgData = ConfigTable.GetData("CharGemInstance", nLevelId)
    if mapLevelCfgData.PreLevelId == 0 then
        return true
    end
    local isWorldClass = true
    if PlayerData.Base:GetWorldClass() < mapLevelCfgData.NeedWorldClass then
        isWorldClass = false
    end
    local isPreLevelStar = true
    if self.mapAllLevel[mapLevelCfgData.PreLevelId] == nil or self.mapAllLevel[mapLevelCfgData.PreLevelId].nStar < mapLevelCfgData.PreLevelStar then
        isPreLevelStar = false
    end
    if isWorldClass == false or isPreLevelStar == false then
        return false,isWorldClass,isPreLevelStar
    end
    return true
end
function PlayerEquipmentInstanceData:GetEquipmentInstanceStar(nLevelId)
    if nLevelId == nil then
        return 0 , {false,false,false}
    end
    if self.mapAllLevel[nLevelId] == nil then
        return 0 , {false,false,false}
    end
    return self.mapAllLevel[nLevelId].nStar,self.mapAllLevel[nLevelId].tbTarget == nil and {false,false,false} or self.mapAllLevel[nLevelId].tbTarget
end
function PlayerEquipmentInstanceData:MsgEnterEquipmentInstance(nLevelId, nBuildId, callback)
    self._EntryTime = CS.ClientManager.Instance.serverTimeStampWithTimeZone
    self._Build_id = nBuildId
    self._Level_id = nLevelId
    local msg = {}
    msg.Id = nLevelId
    msg.BuildId = nBuildId
    local function msgCallback(_, mapChangeInfo)
        self:EnterEquipmentInstance(nLevelId,nBuildId)
        if self.mapAllLevel[nLevelId] == nil then
            self.mapAllLevel[nLevelId] = {nStar  = 0, nBuildId = 0}
        end
        self.mapAllLevel[nLevelId].nBuildId = nBuildId
        if callback ~= nil then
            callback(mapChangeInfo)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.char_gem_instance_apply_req, msg, nil, msgCallback)
end
function PlayerEquipmentInstanceData:MsgSettleEquipmentInstance(nLevelId,nBuildId,nStar,callback)
    --[[
    if nStar == 0 then
        if callback ~= nil then
            callback({},{},{})
        end
        return
    end
    ]]
    local msg = {}
    msg.Star = nStar
    msg.Events = {List = PlayerData.Achievement:GetBattleAchievement(GameEnum.levelType.EquipmentInstance,nStar > 0)}

    local function msgCallback(_,mapMsgData)
        local t1 = nStar >= 1
        local t2 = nStar >= 2
        local t3 = nStar >= 3
        if self.mapAllLevel[nLevelId] ~= nil then
            if self.mapAllLevel[nLevelId].nStar < nStar then
                self.mapAllLevel[nLevelId].nStar = nStar
            end
            if self.mapAllLevel[nLevelId].tbTarget == nil then
                self.mapAllLevel[nLevelId].tbTarget = {false,false,false}
            end
            self.mapAllLevel[nLevelId].tbTarget[1] = t1 or self.mapAllLevel[nLevelId].tbTarget[1]
            self.mapAllLevel[nLevelId].tbTarget[2] = t2 or self.mapAllLevel[nLevelId].tbTarget[2]
            self.mapAllLevel[nLevelId].tbTarget[3] = t3 or self.mapAllLevel[nLevelId].tbTarget[3]
        else
            self.mapAllLevel[nLevelId] = {nStar = nStar, nBuildId = nBuildId, tbTarget = {t1,t2,t3}}
        end
        if callback ~= nil then
           callback(mapMsgData.AwardItems, mapMsgData.FirstItems, mapMsgData.SurpriseItems, mapMsgData.Exp, mapMsgData.Change)
        end
        ------埋点数据------
        self._EndTime = CS.ClientManager.Instance.serverTimeStampWithTimeZone
        local tabUpLevel = {}
        table.insert(tabUpLevel,{"role_id",tostring(PlayerData.Base._nPlayerId)})
        table.insert(tabUpLevel,{"game_cost_time",tostring(self._TotalTime)})
        table.insert(tabUpLevel,{"real_cost_time",tostring(self._EndTime - self._EntryTime)})
        table.insert(tabUpLevel,{"build_id",tostring(self._Build_id)})
        table.insert(tabUpLevel,{"battle_id",tostring(self._Level_id)})
        table.insert(tabUpLevel,{"battle_result",tostring(1)})
        NovaAPI.UserEventUpload("equipment_instance_battle",tabUpLevel)
        ------埋点数据------
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.char_gem_instance_settle_req, msg, nil, msgCallback)
end
function PlayerEquipmentInstanceData:LevelEnd()
    if nil ~= self.curLevel and type(self.curLevel.UnBindEvent) == "function" then
        self.curLevel:UnBindEvent()
    end
    self.curLevel = nil
end
function PlayerEquipmentInstanceData.CalStar(nOrigin)
    nOrigin = (nOrigin & 0x55555555) + ((nOrigin >> 1) & 0x55555555) ;

    nOrigin = (nOrigin & 0x33333333) + ((nOrigin >> 2) & 0x33333333) ;

    nOrigin = (nOrigin & 0x0F0F0F0F) + ((nOrigin >> 4) & 0x0F0F0F0F) ;

    nOrigin = (nOrigin*(0x01010101) >> 24) ;

    return nOrigin;
end

function PlayerEquipmentInstanceData:GetCurLevel()
    if self.curLevel == nil then
        return 0
    end
    return self.curLevel.nLevelId
end

function PlayerEquipmentInstanceData:SetLastMaxHard(nGroupId, nMaxHard)
    self.tbLastMaxHard[nGroupId] = nMaxHard
end

function PlayerEquipmentInstanceData:GetLastMaxHard(nGroupId)
    return self.tbLastMaxHard[nGroupId] or 0
end

--获取当前可选的最大难度
function PlayerEquipmentInstanceData:GetMaxEquipmentInstanceHard(nType)
    local retHard = 1
    local tbLevelList = self.mapLevelCfg[nType]
    if nil ~= tbLevelList then
        for nLevelId, mapLevel in pairs(tbLevelList) do
            if self:GetEquipmentInstanceLevelUnlock(nLevelId) then
                retHard = math.max(mapLevel.Difficulty, retHard)
            end
        end
    end
    return retHard
end

--获取关卡状态
function PlayerEquipmentInstanceData:GetLevelOpenState(nType)
    local mapData = ConfigTable.GetData("CharGemInstanceType", nType)
    if nil ~= mapData then
        return AllEnum.EquipmentInstanceState.Open, true
    end
    return AllEnum.EquipmentInstanceState.None
end

function PlayerEquipmentInstanceData:GetUnOpenTipText(nLevelState, nType)
    local sTipStr = ""
  if nLevelState == AllEnum.EquipmentInstanceState.Not_WorldClass then
        --世界等级不满足
    elseif nLevelState == AllEnum.EquipmentInstanceState.Not_HardUnlock then
        --难度未解锁
        sTipStr = ConfigTable.GetUIText("Level_Lock")
    end
    return sTipStr
end

function PlayerEquipmentInstanceData:CheckLevelOpen(nType, nHard, bShowTips)
    if nType == 0 then
        return AllEnum.EquipmentInstanceState.Open
    end

    local nLevelState, bUnlock = self:GetLevelOpenState(nType)
    if nil ~= nHard and nLevelState == AllEnum.EquipmentInstanceState.Open then
        local nMaxUnlockHard = self:GetMaxEquipmentInstanceHard(nType)
        if nHard > nMaxUnlockHard then
            nLevelState = AllEnum.EquipmentInstanceState.Not_HardUnlock
        end
    end

    if true == bShowTips then
        local sTipStr = self:GetUnOpenTipText(nLevelState, nType)
        if nil ~= sTipStr and "" ~= sTipStr then
            EventManager.Hit(EventId.OpenMessageBox, sTipStr)
        end
    end

    return nLevelState == AllEnum.EquipmentInstanceState.Open, bUnlock
end

function PlayerEquipmentInstanceData:SetSettlementState(bInSettlement)
    self.bInSettlement = bInSettlement
end

function PlayerEquipmentInstanceData:GetSettlementState()
    return self.bInSettlement
end

--扫荡
function PlayerEquipmentInstanceData:SendEquipmentInstanceRaidReq(nId, nCount, callback)
    local Events = {}
    local msgData = {
        Id = nId,
        Times = nCount,
    }
    if #Events > 0 then
        msgData.Events = {List = {}}
        msgData.Events.List = Events
    end
    local function successCallback(_, mapMainData)
        callback(mapMainData.Rewards, mapMainData.Change)
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.char_gem_instance_sweep_req, msgData, nil, successCallback)
end

return PlayerEquipmentInstanceData
