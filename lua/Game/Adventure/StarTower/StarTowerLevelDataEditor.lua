local StarTowerLevelDataEditor = class("StarTowerLevelDataEditor")
local LocalStarTowerDataKey = "StarTowerData"
local RapidJson = require "rapidjson"
local PATH = "Game.Adventure.StarTower.StarTowerRoom."
local PB = require "pb"
local mapProcCtrl = {
    [GameEnum.starTowerRoomType.BattleRoom] = "BattleRoom",
    [GameEnum.starTowerRoomType.EliteBattleRoom] = "BattleRoom",
    [GameEnum.starTowerRoomType.BossRoom] = "BattleRoom",
    [GameEnum.starTowerRoomType.FinalBossRoom] = "BattleRoom",
    [GameEnum.starTowerRoomType.DangerRoom] = "BattleRoom",
    [GameEnum.starTowerRoomType.HorrorRoom] = "BattleRoom",
}
local mapEventConfig = {
    takeEffect        = "OnEvent_TakeEffect",
    LoadLevelRefresh  = "OnEvent_LoadLevelRefresh",
    AdventureModuleEnter = "OnEvent_AdventureModuleEnter",
    [EventId.StarTowerMap] = "OnEvent_OpenStarTowerMap",
    AbandonStarTower = "OnEvent_AbandonStarTower",
    [EventId.StarTowerDepot] = "OnEvent_OpenStarTowerDepot",
    GMOpenDepot = "OnEvent_GMOpenDepot",
    TestBedNoteChange = "OnEvent_TestBedNoteChange",
}
--临时数据相关
local function EncodeTempData(mapData)
    local mapPBData = {}
    mapPBData.curCharId = mapData.curCharId
    mapPBData.skillInfo = mapData.skillInfo
    mapPBData.nCurQuestCond = mapData.nCurQuestCond
    mapPBData.characterInfo = {}

    local mapChar = {}
    for nCharId, mapEffect in pairs(mapData.effectInfo) do
        if mapChar[nCharId] == nil then
            mapChar[nCharId] = {nCharId = nCharId}
        end
        for nEtfId, mapEft in pairs(mapEffect.mapEffect) do
            if mapChar[nCharId].tbEffect == nil then
                mapChar[nCharId].tbEffect = {}
            end
            table.insert(mapChar[nCharId].tbEffect,{nId = nEtfId , nCount = mapEft.nCount , nCd = mapEft.nCd})
        end
    end
    for nCharId, mapBuff in pairs(mapData.buffInfo) do
        if mapChar[nCharId] == nil then
            mapChar[nCharId] = {nCharId = nCharId}
        end
        mapChar[nCharId].tbBuff = mapBuff
    end
    for nCharId, mapStatus in pairs(mapData.stateInfo) do
        if mapChar[nCharId] == nil then
            mapChar[nCharId] = {nCharId = nCharId}
        end
        mapChar[nCharId].stateInfo = mapStatus
    end
    for nCharId, mapAmmoInfo in pairs(mapData.ammoInfo) do
        if mapChar[nCharId] == nil then
            mapChar[nCharId] = {nCharId = nCharId}
        end
        mapChar[nCharId].ammoInfo = mapAmmoInfo
    end
    for _, mapCharacter in pairs(mapChar) do
        table.insert(mapPBData.characterInfo ,mapCharacter)
    end
    local msgName = "nova.client.roguelike.tempData"
    local data = assert(PB.encode(msgName, mapPBData))
    local zipData = NovaAPI.CompressBytes(data)
    if #data <= #zipData then
        return data,false
    else
        return zipData,true
    end

end
local function DecodeTempData(sData,bZip)
    local tempData = nil

    local msgName = "nova.client.roguelike.tempData"
    if bZip then
        sData = NovaAPI.DecompressString(sData)
    end
    local bSuccess,data = pcall(PB.decode,msgName, sData)
    if bSuccess then
        if data ~= nil then
            tempData = {}
            tempData.curCharId = data.curCharId
            tempData.skillInfo = data.skillInfo
            tempData.nCurQuestCond = data.nCurQuestCond
            tempData.effectInfo = {}
            tempData.buffInfo = {}
            tempData.stateInfo = {}
            tempData.ammoInfo = {}
            for _, mapChar in ipairs(data.characterInfo) do
                if mapChar.tbEffect ~= nil then
                    if tempData.effectInfo[mapChar.nCharId] == nil then
                        tempData.effectInfo[mapChar.nCharId] = {mapEffect = {}}
                    end
                    for _, mapEft in ipairs(mapChar.tbEffect) do
                        tempData.effectInfo[mapChar.nCharId].mapEffect[mapEft.nId] = {nCount = mapEft.nCount,nCd = mapEft.nCd}
                    end
                end
                if mapChar.tbBuff ~= nil then
                    tempData.buffInfo[mapChar.nCharId] = mapChar.tbBuff
                end
                if mapChar.stateInfo ~= nil then
                    tempData.stateInfo[mapChar.nCharId] = mapChar.stateInfo
                end
                if mapChar.ammoInfo ~= nil then
                    tempData.ammoInfo[mapChar.nCharId] = mapChar.ammoInfo
                end
            end
        end
    else
        printError("临时数据decode失败")
        return {}
    end
    return tempData
end
------------------------------------
---@diagnostic disable-next-line: duplicate-set-field
function StarTowerLevelDataEditor:ctor(parent,nStarTowerId)
    self:BindEvent()
    local pbSchema = NovaAPI.LoadLuaBytes("Game/Adventure/StarTower/roguelike_tempData.pb")
    assert(PB.load(pbSchema))
    local function BuildStarTowerAllFloorData(nTowerId)
        local ret = {}
        local difficulty
        local tbStage
        if nTowerId ~= 999 then
            local mapStarTowerCfgData = ConfigTable.GetData("StarTower", nTowerId)
            if mapStarTowerCfgData == nil then
                return {}
            end
            difficulty = mapStarTowerCfgData.Difficulty
            tbStage = mapStarTowerCfgData.StageGroupIds
        else
            difficulty = 1
            tbStage = {99901}
        end
        for _, nStageGroupId in ipairs(tbStage) do
            for nLevel = 1, 99 do
                local nStageLevelId = nStageGroupId * 100 + nLevel
                if ConfigTable.GetData("StarTowerStage", nStageLevelId) == nil then
                    break
                end
                table.insert(ret, ConfigTable.GetData("StarTowerStage", nStageLevelId))
            end
        end
        return ret,difficulty
    end
    self.parent = parent
    self.nTowerId = nStarTowerId
    self.nCurLevel = 1
    self.bRanking = false
    self.tbStarTowerAllLevel,self.nStarTowerDifficulty = BuildStarTowerAllFloorData(self.nTowerId)
    self.tbStrengthMachineCost = ConfigTable.GetConfigNumberArray("StrengthenMachineGoldConsume")
end
function StarTowerLevelDataEditor:Exit()
    self:UnBindEvent()
    if self.curRoom ~= nil then
        self.curRoom:Exit()
    end
end
function StarTowerLevelDataEditor:BindEvent()
    if type(mapEventConfig) ~= "table" then
        return
    end
    for nEventId, sCallbackName in pairs(mapEventConfig) do
        local callback = self[sCallbackName]
        if type(callback) == "function" then
            EventManager.Add(nEventId, self, callback)
        end
    end
end
function StarTowerLevelDataEditor:UnBindEvent()
    if type(mapEventConfig) ~= "table" then
        return
    end
    for nEventId, sCallbackName in pairs(mapEventConfig) do
        local callback = self[sCallbackName]
        if type(callback) == "function" then
            EventManager.Remove(nEventId, self, callback)
        end
    end
end
function StarTowerLevelDataEditor:Init(mapMeta,mapRoom,mapBag)
    local function GetCharacterAttr(tbTeam)
        local ret = {}
        for idx, nTid in ipairs(tbTeam) do
            local stActorInfo = self:CalCharFixedEffect(nTid,idx == 1)
            ret[nTid] = stActorInfo
        end
        return ret
    end
    --用于保存当前获取的音符数量{[nTid] = number(音符数量)}
    self._mapNote = {}
    --用于保存当前获取的潜能数量{[nCharId] = {[number(潜能ID)] = number(潜能数量)}}
    self._mapPotential = {}
    --用于保存当前获取的命运卡{[number(命运卡ID)] = {number(命运卡剩余次数),number(命运卡剩余房间次数)}}
    self._mapFateCard = {}
    --用于保存当前获取的物品数量{[number(物品ID)] = number(物品数量)}
    self._mapItem = {}
    self.nTowerId = mapMeta.Id
    self.nCurLevel = mapRoom.Data.Floor
    self.tbTeam = {}
    for _, mapChar in ipairs(mapMeta.Chars) do
        table.insert(self.tbTeam,mapChar.Id)
        self._mapPotential[mapChar.Id] = {}
    end
    self.tbDisc   = mapMeta.Discs --后续改为星盘编队
    self.curRoom  = nil          --当前房间
    self.mapFateCardUseCount = {} -- 当前层的命运卡使用数量
    self.nTeamLevel = mapMeta.TeamLevel
    self.nTeamExp = mapMeta.TeamExp
    --角色技能cd相关数据
    self.mapCharacterTempData = DecodeTempData(mapMeta.ClientData,mapMeta.Compress)
    self.mapEffectTriggerCount = {}
    if self.mapCharacterTempData.effectInfo ~= nil then
        for _, mapData in pairs(self.mapCharacterTempData.effectInfo) do
           if mapData.mapEffect ~= nil then
                for nEftId, value in pairs(mapData.mapEffect) do
                    self.mapEffectTriggerCount[nEftId] = value.nCount
                end
           end
        end
    end
    --当前角色的属性数据
    self.mapCharAttr = GetCharacterAttr(self.tbTeam)
    --根据服务器数据保存当前命运卡
    if mapBag ~= nil then
        self._mapNote[90011] = mapBag.Notes[1]
        self._mapNote[90012] = mapBag.Notes[2]
        self._mapNote[90013] = mapBag.Notes[3]
        self._mapNote[90014] = mapBag.Notes[4]
        self._mapNote[90015] = mapBag.Notes[5]
    end
    self:SetRoguelikeHistoryMapId()
    if #self.tbStarTowerAllLevel == 0 then
        printError("StarTower Config Data Missing:".. self.nTowerId)
    end
    ----进入房间----
    self.curMapId = mapRoom.Data.MapId
    self:SetRoguelikeHistoryMapId(self.curMapId)
    --local stRoomMeta = CS.Lua2CSharpInfo_FixedRoguelike(self.nTowerId,nFloorId,tbHistoryMapId,self.tbTeam,tbCharSkinId,0)
    --self.curMapId = safe_call_cs_func2(CS.AdventureModuleHelper.RandomStarTowerMap,stRoomMeta)

    local nNextRoomType = 0
    if self.nCurLevel + 1 <= #self.tbStarTowerAllLevel then
        local mapNextStage = self.tbStarTowerAllLevel[self.nCurLevel + 1]
        nNextRoomType = mapNextStage.RoomType
    end
    safe_call_cs_func(CS.AdventureModuleHelper.EnterStarTowerMap, self.nStarTowerDifficulty, false, false,{0,0,0},nNextRoomType)
    if self.nTowerId == 999 then
        safe_call_cs_func(CS.AdventureModuleHelper.SetProloguelBattleMsg, {})
    end
    local roomClass = self:GetcurRoom()
    self.curRoom = roomClass.new(self,mapRoom.Cases,mapRoom.Data)
    NovaAPI.EnterModule("AdventureModuleScene", true)
end
function StarTowerLevelDataEditor:StarTowerClear(nCaseId)
    local function PlaySuccessPerform(nMapId,mapResult,tbTeam,tbDisc)
        --[[
        local sBGM = ""
        if #tbDisc > 0 then
            local nSelectedOutfit = tbDisc[math.random(1, #tbDisc)]
            local mapOutfitCfg = ConfigTable.GetData("DiscIP", nSelectedOutfit)
            local sBGM = ""
            if mapOutfitCfg ~= nil then
                sBGM = mapOutfitCfg.VoFile
            end
        end
        ]]
        local function levelEndCallback()
            EventManager.Remove("ADVENTURE_LEVEL_UNLOAD_COMPLETE",self,levelEndCallback)
            if ConfigTable.GetData("StarTowerMap", nMapId) == nil then 
                printError("MapDataMissing:"..nMapId)
            end
            local nType = ConfigTable.GetData("StarTowerMap", nMapId).Theme
            local sName = ConfigTable.GetData("EndSceneType", nType).EndSceneName
            local function func_SettlementFinish()
            end
            local tbSkin = {}
            for _, nCharId in ipairs(tbTeam) do
                local nSkinId = PlayerData.Char:GetCharSkinId(nCharId)
                table.insert(tbSkin,nSkinId)
            end
            CS.AdventureModuleHelper.PlaySettlementPerform(sName, "", tbSkin, func_SettlementFinish)
        end
        EventManager.Add("ADVENTURE_LEVEL_UNLOAD_COMPLETE", self, levelEndCallback)
        local function openBattleResultPanel()
            EventManager.Remove("SettlementPerformLoadFinish",self, openBattleResultPanel)
            EventManager.Hit(EventId.OpenPanel, PanelId.StarTowerResult, mapResult, tbTeam)
            self.parent:StarTowerEnd()
        end
        EventManager.Add("SettlementPerformLoadFinish", self, openBattleResultPanel)
        CS.AdventureModuleHelper.LevelStateChanged(true)
        EventManager.Hit(EventId.OpenPanel, PanelId.BattleResultMask)
    end
    local EnterReq = {MapId = 0}
    local mapMsg = {
        Id = nCaseId,
        EnterReq = EnterReq
    }
    local function NetCallback(_,mapNetMsg)
        local mapBuildInfo = nil 
        local mapChangeInfo = {}
        local tbRes = {}
        local tbItem = {}
        local nTime = 0
        if mapNetMsg.Settle ~= nil then
            mapBuildInfo = mapNetMsg.Settle.Build
            mapChangeInfo = mapNetMsg.Settle.Change
            nTime = mapNetMsg.Settle.TotalTime
        end
        if mapChangeInfo ~= nil then
            local encodeInfo = UTILS.DecodeChangeInfo(mapChangeInfo)
            if encodeInfo["proto.Res"] ~= nil then
                for _, mapCoin in ipairs(encodeInfo["proto.Res"]) do
                    table.insert(tbRes, {nTid = mapCoin.Tid, nCount = mapCoin.Qty})
                end
            end
            if encodeInfo["proto.Item"] ~= nil then
                for _, mapItem in ipairs(encodeInfo["proto.Item"]) do
                    local mapItemConfigData = ConfigTable.GetData_Item(mapItem.Tid)
                    if mapItemConfigData.Stype ~= GameEnum.itemStype.Res then
                        table.insert(tbItem,{nTid = mapItem.Tid,nCount = mapItem.Qty})
                    end
                end
            end
        end
        local nPotentialCount = 0
        for _, mapPotential in pairs(self._mapPotential) do
           for _, nCount in pairs(mapPotential) do
                nPotentialCount = nPotentialCount + nCount
           end
        end
        local mapResult = {
            nRoguelikeId =  self.nTowerId,
            tbRes = tbRes,
            tbPresents = {},
            tbOutfit = {},
            tbItem = tbItem,
            tbRarityCount = {},
            bSuccess = true,
            nFloor = self.nCurLevel,
            nStage = self.tbStarTowerAllLevel[self.nCurLevel].Id,
            mapBuild = mapBuildInfo,
            nExp =  0,--msgData.nExp,
            nPerkCount = nPotentialCount,
            tbBonus = {},
            nTime = nTime,
            tbAffinities = {}, --msgData.Affinities
            mapChangeInfo = mapChangeInfo
        }
        PlaySuccessPerform(self.curMapId,mapResult,self.tbTeam,self.tbDisc)
    end
    local mapData = {}
    NetCallback(nil ,mapData)
end
function StarTowerLevelDataEditor:EnterRoom(nCaseId,nRoomType)
    if self.bEnd then
        return
    end
    if  self.curRoom ~= nil then
        self.curRoom:Exit()
        self.curRoom = nil
    end
    
    if self.nCurLevel + 1 > #self.tbStarTowerAllLevel then
        self:StarTowerClear(nCaseId)
        return
    end
    local tbHistoryMapId = self:GetRoguelikeHistoryMapId()
    local tbCharSkinId = {}
    for _, nCharId in ipairs(self.tbTeam) do
        table.insert(tbCharSkinId,PlayerData.Char:GetCharSkinId(nCharId))
    end
    local stRoomMeta 
    if nRoomType == GameEnum.starTowerRoomType.DangerRoom or nRoomType == GameEnum.starTowerRoomType.HorrorRoom then
        print(string.format("Enter HighDangerRoom RoomType:%d", nRoomType))
        local nStage = self.tbStarTowerAllLevel[self.nCurLevel].Id
        stRoomMeta = CS.Lua2CSharpInfo_FixedRoguelike(self.nTowerId,nStage,tbHistoryMapId,self.tbTeam,tbCharSkinId,0,0,nRoomType,self.bRanking)
    else
        self.nCurLevel = self.nCurLevel + 1
        local nNextStage = self.tbStarTowerAllLevel[self.nCurLevel].Id
        stRoomMeta = CS.Lua2CSharpInfo_FixedRoguelike(self.nTowerId,nNextStage,tbHistoryMapId,self.tbTeam,tbCharSkinId,0,0,-1,self.bRanking)
    end
    local floorId
    self.curMapId, floorId = safe_call_cs_func2(CS.AdventureModuleHelper.RandomStarTowerMap,stRoomMeta)
    if floorId == nil then
        floorId = 0
    end
    self:SetRoguelikeHistoryMapId(self.curMapId)
    local function OnLevelUnloadComplete()
        EventManager.Remove("ADVENTURE_LEVEL_UNLOAD_COMPLETE",self,OnLevelUnloadComplete)
        self:OnEvent_AdventureModuleEnter()
    end
    local function NetCallback(_,mapNetData)
        if mapNetData.EnterResp == nil then
            printError("房间数据返回为空")
            return
        end
        self:ProcessChangeInfo(mapNetData.Change)
        local nNextRoomType = 0
        if self.nCurLevel + 1 <= #self.tbStarTowerAllLevel then
            local mapNextStage = self.tbStarTowerAllLevel[self.nCurLevel + 1]
            nNextRoomType = mapNextStage.RoomType
        end
        safe_call_cs_func(CS.AdventureModuleHelper.EnterStarTowerMap, self.nStarTowerDifficulty, false, false,{0,0,0},nNextRoomType)
        if self.nTowerId == 999 then
            safe_call_cs_func(CS.AdventureModuleHelper.SetProloguelBattleMsg, {})
        end
        local roomClass = self:GetcurRoom()
        self.curRoom = roomClass.new(self,mapNetData.EnterResp.Room.Cases,mapNetData.EnterResp.Room.Data)
        EventManager.Add("ADVENTURE_LEVEL_UNLOAD_COMPLETE",self,OnLevelUnloadComplete)
        safe_call_cs_func(CS.AdventureModuleHelper.LevelStateChanged,false)
    end
    local EnterReq = {MapId = self.curMapId,ParamId = floorId}
    local mapData = {
        EnterResp = {
            Room = {
                Data = {
                    Floor = self.nCurLevel,
                    MapId = self.curMapId,
                    ParamId = floorId,
                },
                Cases = {
                    {Id = 1,DoorCase = {Floor = 1,Type = 1,}},
                    {Id = 2,BattleCase = {TimeLimit = false,FateCard = false,}},
                }
            }
        }
    }

    NetCallback(nil,mapData)
end
function StarTowerLevelDataEditor:StarTowerInteract(mapMsgData,callback)
    if self.bEnd then
        return
    end
    local function NetCallback(_,mapNetData)
        local tbChangeFateCard,mapChangeNote,mapItemChange = self:ProcessChangeInfo(mapNetData.Change)
        local nExpChange    = 0
        local nLevelChange  = 0
        local nBagCount = self._mapItem[AllEnum.CoinItemId.FixedRogCurrency]
        if nBagCount == nil then
            nBagCount = 0
        end
        EventManager.Hit("RefreshStarTowerCoin",nBagCount)
        EventManager.Hit("RefreshNoteCount",self._mapNote)
        if mapNetData.BattleEndResp ~= nil then
            if mapNetData.BattleEndResp.Victory ~= nil then
                nExpChange = mapNetData.BattleEndResp.Victory.Exp - self.nTeamExp
                nLevelChange = mapNetData.BattleEndResp.Victory.Lv - self.nTeamLevel
                self.nTeamLevel =  mapNetData.BattleEndResp.Victory.Lv
                self.nTeamExp   =  mapNetData.BattleEndResp.Victory.Exp
            end
        end
        if self.curRoom ~= nil then
            self.curRoom:SaveCase(mapNetData.Cases)
        end
        if callback ~= nil and type(callback) == "function" then
            callback(mapNetData,tbChangeFateCard,mapChangeNote,mapItemChange,nLevelChange,nExpChange)
        end
    end
    local mapData = {
        Cases = {},
        Settle = {Build = {},TotalTime = 0,TotalDamages = {0,0,0},Change = {}},
    }

    NetCallback(nil ,mapData)
end
function StarTowerLevelDataEditor:StarTowerFailed(mapChangeInfo,mapBuildInfo,nTime)
    print("放弃遗迹")
    local tbRes = {}
    local tbPresents = {}
    local tbOutfit   = {}
    local tbItem = {}
    if mapChangeInfo ~= nil then
        local encodeInfo = UTILS.DecodeChangeInfo(mapChangeInfo)
        if encodeInfo["proto.Res"] ~= nil then
            for _, mapCoin in ipairs(encodeInfo["proto.Res"]) do
                table.insert(tbRes, {nTid = mapCoin.Tid, nCount = mapCoin.Qty})
            end
        end
        if encodeInfo["proto.Item"] ~= nil then
            for _, mapItem in ipairs(encodeInfo["proto.Item"]) do
                local mapItemConfigData = ConfigTable.GetData_Item(mapItem.Tid)
                if mapItemConfigData.Stype ~= GameEnum.itemStype.Res then
                    table.insert(tbItem,{nTid = mapItem.Tid,nCount = mapItem.Qty})
                end
            end
        end
    end
    local nPotentialCount = 0
    for _, mapPotential in pairs(self._mapPotential) do
       for _, nCount in pairs(mapPotential) do
            nPotentialCount = nPotentialCount + nCount
       end
    end
    local mapResult = {
        nRoguelikeId =  self.nTowerId,
        tbRes = tbRes,
        tbPresents = tbPresents,
        tbOutfit = tbOutfit,
        tbItem = tbItem,
        tbRarityCount = {},
        bSuccess = false,
        nFloor = self.nCurLevel,
        nStage = self.tbStarTowerAllLevel[self.nCurLevel].Id,
        mapBuild = mapBuildInfo,
        nExp =  0,--msgData.nExp,
        nPerkCount = nPotentialCount,
        tbBonus = {},
        nTime = nTime,
        tbAffinities = {}, --msgData.Affinities
        mapChangeInfo = mapChangeInfo
    }
    EventManager.Hit(EventId.OpenPanel, PanelId.StarTowerResult, mapResult, self.tbTeam)
    self.parent:StarTowerEnd()
end
function StarTowerLevelDataEditor:OnEvent_AdventureModuleEnter()
    --打开界面
    EventManager.Hit(EventId.OpenPanel, PanelId.Adventure, self.tbTeam, self.nTowerId, self.tbDisc)
    --设置属性
    for nCharId,mapInfo in pairs(self.mapCharAttr) do
        safe_call_cs_func(CS.AdventureModuleHelper.SetActorAttribute,nCharId,mapInfo)
    end
    --初始化其他
    self:ResetAmmo()
    self:ResetSommon()
    self:ResetPersonalPerk()
    self:ResetFateCard()
    self:ResetNoteInfo()
    self:ResetDiscInfo()
end
function StarTowerLevelDataEditor:OnEvent_LoadLevelRefresh()
    self.mapFateCardUseCount = {} --清理数据
    self.mapPotentialEft,self.mapDiscEft,self.mapFateCardEft = self:ResetEffect()
    if self.curRoom ~= nil then
        self.curRoom:Enter()
    end
end
function StarTowerLevelDataEditor:OnEvent_TakeEffect(nCharId,EffectId)
    if self.mapEffectTriggerCount == nil then
        self.mapEffectTriggerCount = {}
    end
    if self.mapEffectTriggerCount[EffectId] == nil then
        self.mapEffectTriggerCount[EffectId] = 0
    end
    self.mapEffectTriggerCount[EffectId] = self.mapEffectTriggerCount[EffectId] + 1
    if self.mapFateCardEft[EffectId] ~= nil then
        local nFateCardId = self.mapFateCardEft[EffectId].nFateCardId
        if self.mapFateCardUseCount[nFateCardId] == nil then
            self.mapFateCardUseCount[nFateCardId] = 0
        end
        self.mapFateCardUseCount[nFateCardId] = self.mapFateCardUseCount[nFateCardId] + 1
    end
end
function StarTowerLevelDataEditor:OnEvent_OpenStarTowerMap()
    local bHighDanger = false
    if ConfigTable.GetData("StarTowerMap", self.curMapId) ~= nil then
        local nFunc = ConfigTable.GetData("StarTowerMap", self.curMapId).RoomType[1]
        bHighDanger = (nFunc == GameEnum.starTowerRoomType.DangerRoom or nFunc == GameEnum.starTowerRoomType.HorrorRoom)
    end

    EventManager.Hit("OpenStarTowerMap", self.tbStarTowerAllLevel,self.nCurLevel,self.nTowerId,self.tbTeam,bHighDanger, nil, self.mapCharData,#self.tbStarTowerAllLevel)
end
function StarTowerLevelDataEditor:OnEvent_OpenStarTowerDepot()
    EventManager.Hit("OpenStarTowerDepot", self._mapPotential)
    --[[
    printLog("当前拥有的潜能列表：")
    for nId, nLv in pairs(self._mapPotential) do
        printLog(string.format("Id = %s, Level = %s"), nId, nLv)
    end
    ]]
end
function StarTowerLevelDataEditor:OnEvent_AbandonStarTower()
    if self.bEnd then
        return
    end
    self.bEnd = true -- 不再处理其他交互
end
--tool func--
function StarTowerLevelDataEditor:ProcessChangeInfo(mapChangeData)
    local mapData = UTILS.DecodeChangeInfo(mapChangeData)
    local tbChangeFateCard = {}
    local mapChangeNote = {}
    local mapRewardChange = {}
    if mapData["proto.FateCardInfo"] ~= nil then
        for _, mapFateCardData in ipairs(mapData["proto.FateCardInfo"]) do
            local nBeforeRoomCount = 0
            local nBeforeEftCount = 0
            if self._mapFateCard[mapFateCardData.Tid] ~= nil then
                nBeforeRoomCount = self._mapFateCard[mapFateCardData.Tid][2]
                nBeforeEftCount  = self._mapFateCard[mapFateCardData.Tid][1]
            end
            if mapFateCardData.Qty == 0 then
                self:RemoveFateCardEft(mapFateCardData.Tid)
                self._mapFateCard[mapFateCardData.Tid] = nil
                table.insert(tbChangeFateCard,{mapFateCardData.Tid,0,0,-1})
                --EventManager.Hit("FateCardChange",mapFateCardData.Tid,0,0,-1)
            else
                local nCountSum = 0
                if self._mapFateCard[mapFateCardData.Tid] == nil then
                    nCountSum = 1
                end
                self._mapFateCard[mapFateCardData.Tid] = {mapFateCardData.Remain,mapFateCardData.Room}
                if mapFateCardData.Room ~= 0 and mapFateCardData.Remain ~= 0 then
                    self:AddFateCardEft(mapFateCardData.Tid)
                else
                    self:RemoveFateCardEft(mapFateCardData.Tid)
                end
                table.insert(tbChangeFateCard,{
                    mapFateCardData.Tid,
                    self._mapFateCard[mapFateCardData.Tid][1] - nBeforeEftCount,
                    self._mapFateCard[mapFateCardData.Tid][2] - nBeforeRoomCount,
                    nCountSum
                    }
                )
            end
        end
    end
    if mapData["proto.PotentialInfo"] ~= nil then
        for _, mapPotentialInfo in ipairs(mapData["proto.PotentialInfo"]) do
            local mapPotentialCfgData = ConfigTable.GetData("Potential", mapPotentialInfo.Tid)
            if mapPotentialCfgData == nil then
                printError("PotentialCfgData Missing"..mapPotentialInfo.Tid)
            else
                local nCharId = mapPotentialCfgData.CharId
                if self._mapPotential[nCharId][mapPotentialInfo.Tid] == nil then
                    self._mapPotential[nCharId][mapPotentialInfo.Tid] = 0
                end
                self._mapPotential[nCharId][mapPotentialInfo.Tid] = self._mapPotential[nCharId][mapPotentialInfo.Tid] + mapPotentialInfo.Level
            end
            self:ChangePotential(mapPotentialInfo.Tid)
        end
    end
    if mapData["proto.NoteInfo"] ~= nil then
        for _, mapNoteInfo in ipairs(mapData["proto.NoteInfo"]) do
            print(string.format("音符数量变化：%d,%d",mapNoteInfo.Tid, mapNoteInfo.Qty))
            if self._mapNote[mapNoteInfo.Tid] == nil then
                self._mapNote[mapNoteInfo.Tid] = 0
            end
            self._mapNote[mapNoteInfo.Tid] = self._mapNote[mapNoteInfo.Tid] + mapNoteInfo.Qty
            if mapChangeNote[mapNoteInfo.Tid] == nil then
                mapChangeNote[mapNoteInfo.Tid] = mapNoteInfo.Qty
            else
                mapChangeNote[mapNoteInfo.Tid] = mapChangeNote[mapNoteInfo.Tid] + mapNoteInfo.Qty
            end
        end
        self:ResetNoteInfo()
        self:ResetDiscInfo()
        self:ChangeNote()
    end
    if mapData["proto.TowerItemInfo"] ~= nil then
        for _, mapItemInfo in ipairs(mapData["proto.TowerItemInfo"]) do
            if self._mapItem[mapItemInfo.Tid] == nil then
                self._mapItem[mapItemInfo.Tid] = 0
            end
            self._mapItem[mapItemInfo.Tid] = self._mapItem[mapItemInfo.Tid] + mapItemInfo.Qty
            if mapRewardChange[mapItemInfo.Tid] == nil then
                mapRewardChange[mapItemInfo.Tid] = mapItemInfo.Qty
            else
                mapRewardChange[mapItemInfo.Tid] = mapRewardChange[mapItemInfo.Tid] + mapItemInfo.Qty
            end
        end
    end
    if mapData["proto.TowerResInfo"] ~= nil then
        for _, mapItemInfo in ipairs(mapData["proto.TowerResInfo"]) do
            if self._mapItem[mapItemInfo.Tid] == nil then
                self._mapItem[mapItemInfo.Tid] = 0
            end
            self._mapItem[mapItemInfo.Tid] = self._mapItem[mapItemInfo.Tid] + mapItemInfo.Qty
            if mapRewardChange[mapItemInfo.Tid] == nil then
                mapRewardChange[mapItemInfo.Tid] = mapItemInfo.Qty
            else
                mapRewardChange[mapItemInfo.Tid] = mapRewardChange[mapItemInfo.Tid] + mapItemInfo.Qty
            end
        end
    end 
    return tbChangeFateCard,mapChangeNote,mapRewardChange
end
function StarTowerLevelDataEditor.GetActorHp()
    local logStr = ""
    local tbActorEntity = CS.AdventureModuleHelper.GetCurrentGroupPlayers()
    local mapCurCharInfo = {}
    local count = tbActorEntity.Count - 1
    for i = 0, count do
        local nCharId = CS.AdventureModuleHelper.GetCharacterId(tbActorEntity[i])
        local hp = CS.AdventureModuleHelper.GetEntityHp(tbActorEntity[i])
        mapCurCharInfo[nCharId] = hp
        logStr = logStr .. string.format("EntityID:%d\t角色Id�?%d\t角色血量：%d\n",tbActorEntity[i],nCharId,hp)
    end
    print(logStr)
    return mapCurCharInfo
end
function StarTowerLevelDataEditor:GetcurRoom()
    if self.tbStarTowerAllLevel[self.nCurLevel] ~= nil then
        local sRoomName = mapProcCtrl[self.tbStarTowerAllLevel[self.nCurLevel].RoomType]
        if sRoomName == nil then
            sRoomName = "EventRoom"
        end
        local fullPath = PATH..sRoomName
        print(fullPath)
        local curRoom = require(fullPath)
        return curRoom
    else
        printError("Stage Missing :" .. self.nCurLevel)
        local sRoomName =  "EventRoom"
        local fullPath = PATH..sRoomName
        print(fullPath)
        local curRoom = require(fullPath)
        return curRoom
    end
end
function StarTowerLevelDataEditor:SyncCharacterInfo()
    local mapCharHp = self.GetActorHp()
    local msgData = {
        Info = {},
        ClientData = self:CacheTempData()
    }
    for nTid,mapCharInfo in pairs(self.mapActorInfo) do
        if mapCharHp[nTid] ~= nil then
            mapCharInfo.nHp = mapCharHp[nTid]
        end
        table.insert(msgData.Info,{CharId = nTid,Hp = mapCharInfo.nHp,Current = nTid == self.mapCharacterTempData.curCharId})
    end
end
function StarTowerLevelDataEditor:GetStageId(nFloor)
    if self.tbStarTowerAllLevel[nFloor] ~= nil then
        return self.tbStarTowerAllLevel[nFloor].Id
    end
    return 0
end
function StarTowerLevelDataEditor:GetStageLevel(nStage)
    for nLevel, mapStageData in ipairs(self.tbStarTowerAllLevel) do
        if mapStageData.Id == nStage then
            return nLevel
        end
    end
    return 1
end
function StarTowerLevelDataEditor:RemoveFateCardEft(nFateCardId)
    local mapFateCardCfgData = ConfigTable.GetData("FateCard", nFateCardId)
    if mapFateCardCfgData == nil then
        printError("FateCardCfgData Missing:"..nFateCardId)
    else
        local nEftId = ConfigTable.GetData("FateCard", nFateCardId)
        if self.mapFateCardEft[nEftId] ~= nil then
            for _, tbUid in ipairs(self.mapFateCardEft[nEftId].tbEftUid) do
                UTILS.RemoveEffect(tbUid[1],tbUid[2])
            end
            self.mapFateCardEft[nEftId] = nil
        end
    end
end
function StarTowerLevelDataEditor:AddFateCardEft(nFateCardId)
    local mapFateCardCfgData = ConfigTable.GetData("FateCard", nFateCardId)
    if mapFateCardCfgData == nil then
        printError("FateCardCfgData Missing:"..nFateCardId)
    else
        if self.mapFateCardEft[mapFateCardCfgData.ClientEffect] ~= nil then
            --print("重复添加fatecard效果")
            return
        end
        if mapFateCardCfgData.ClientEffect == 0 then
            return
        end
        local nReaminCount = mapFateCardCfgData.Count
        if self._mapFateCard[nFateCardId] ~= nil then
            nReaminCount = self._mapFateCard[nFateCardId][1]
        end
        if nReaminCount ~= 0  then
            return
        end
        self.mapFateCardEft[mapFateCardCfgData.ClientEffect] =  {nFateCardId = nFateCardId,tbEftUid = {}}
        for _, nCharId in ipairs(self.tbTeam) do
            local nUid = UTILS.AddFateCardEft(nCharId,mapFateCardCfgData.ClientEffect,nReaminCount)
            table.insert(self.mapFateCardEft[mapFateCardCfgData.ClientEffect].tbEftUid,nUid)
        end
    end
end
function StarTowerLevelDataEditor:ChangePotential(nPotentialId)
    local mapPotentialCfgData = ConfigTable.GetData("Potential", nPotentialId)
    if mapPotentialCfgData == nil then
        printError("PotentialCfgData Missing"..nPotentialId)
        return
    end
    local nCharId = mapPotentialCfgData.CharId
    local nCount = 0
    if self._mapPotential[nCharId][nPotentialId] ~= nil then
        nCount = self._mapPotential[nCharId][nPotentialId]
    end
    local stPerkInfo = CS.Lua2CSharpInfo_TPPerkInfo()
    stPerkInfo.perkId = nPotentialId
    stPerkInfo.nCount = nCount
    safe_call_cs_func(CS.AdventureModuleHelper.ChangePersonalPerkIds,{stPerkInfo},nCharId)
    --移除老效果
    if self.mapPotentialEft[nPotentialId] ~= nil then
        for _, tbEft in ipairs(self.mapPotentialEft[nPotentialId]) do
            UTILS.RemoveEffect(tbEft[1],tbEft[2])
        end
        self.mapPotentialEft[nPotentialId] = nil
    end
    --添加新效果
    if nCount < 1 then
        return
    end
    local tbEft = {}
    if mapPotentialCfgData.EffectId1 ~= 0 then
        table.insert(tbEft,mapPotentialCfgData.EffectId1)
    end
    if mapPotentialCfgData.EffectId2 ~= 0 then
        table.insert(tbEft,mapPotentialCfgData.EffectId2)
    end
    if mapPotentialCfgData.EffectId3 ~= 0 then
        table.insert(tbEft,mapPotentialCfgData.EffectId3)
    end
    if mapPotentialCfgData.EffectId4 ~= 0 then
        table.insert(tbEft,mapPotentialCfgData.EffectId4)
    end
    for _, nCharTid in ipairs(self.tbTeam) do
        for _, nEftId in ipairs(tbEft) do
            self.mapPotentialEft[nPotentialId] = {}
            local nEftUseCount = self.mapEffectTriggerCount[nEftId]
            if nEftUseCount == nil then
                nEftUseCount = 0
            end
            local nEftUid = UTILS.AddEffect(nCharId,nEftId,nCount,nEftUseCount)
            table.insert(self.mapPotentialEft[nPotentialId],{nEftUid,nCharTid})
        end
    end
end
function StarTowerLevelDataEditor:ChangeNote()
    local function checkHas(tbDiscEft, nEftId)
        for _, v in pairs(tbDiscEft) do
            if v[1] == nEftId then
                return true
            end
        end
        return false
    end
    for k, nDiscId in ipairs(self.tbDisc) do
        if k <= 3 then
            if self.mapDiscEft[nDiscId] == nil then
                self.mapDiscEft[nDiscId] = {}
            end
            local mapDiscData = PlayerData.Disc:GetDiscById(nDiscId)
            if mapDiscData ~= nil then
                local tbDiscEft = mapDiscData:GetSkillEffect(self._mapNote)
                for _, mapEft in ipairs(tbDiscEft) do --添加没有添加的新效果
                    if self.mapDiscEft[nDiscId][mapEft[1]] == nil then
                        self.mapDiscEft[nDiscId][mapEft[1]] = {}
                        local nEftUseCount = self.mapEffectTriggerCount[mapEft[1]]
                        if nEftUseCount == nil then
                            nEftUseCount = 0
                        end
                        for _, nCharId in ipairs(self.tbTeam) do
                            local nEftUid = UTILS.AddEffect(nCharId,mapEft[1],mapEft[2],nEftUseCount)
                            table.insert(self.mapDiscEft[nDiscId][mapEft[1]],{nEftUid,nCharId})
                        end
                    end
                end
                local tbRemoveEft = {}
                for nEftId, tbEft in pairs(self.mapDiscEft[nDiscId]) do
                    if not checkHas(tbDiscEft, nEftId) then
                        table.insert(tbRemoveEft, nEftId)
                        for _, tbEftData in ipairs(tbEft) do
                            UTILS.RemoveEffect(tbEftData[1],tbEftData[2])
                        end
                    end
                end
                for _, nEftId in ipairs(tbRemoveEft) do
                    self.mapDiscEft[nDiscId][nEftId] = nil
                end
            end
        end
    end
end
function StarTowerLevelDataEditor:GetFateCardUsage()
    local ret = {}
    for nFateCardId, nCount in pairs(self.mapFateCardUseCount) do
        table.insert(ret,{Id = nFateCardId,Times = nCount})
    end
    return ret
end
function StarTowerLevelDataEditor:GetDamageRecord()
    local ret = {}
    for _, nCharId in pairs(self.tbTeam) do
        local nDamage = safe_call_cs_func(CS.AdventureModuleHelper.GetCharacterDamage, nCharId, false)
        table.insert(ret,nDamage)
    end
    safe_call_cs_func(CS.AdventureModuleHelper.ClearCharacterDamageRecord, false)
    return ret
end
function StarTowerLevelDataEditor.CheckBattleEnd(tbCases)
    for _, mapCases in ipairs(tbCases) do
        if mapCases.BattleCase ~= nil then
            return false
        end
    end
    return true
end
function StarTowerLevelDataEditor:RecoverHp(nEffectId)
    local nCharId = self.tbTeam[1]
    print("AddRecoverEft:"..nEffectId)
    UTILS.AddEffect(nCharId,nEffectId,0,0)
    local mapHp = self.GetActorHp()
    local nHp
    if mapHp ~= nil then
        nHp = mapHp[nCharId]
    end
    if nHp == nil then
        nHp = -1
    end
    return nHp
end
--参数为空时为清空历史地图
function StarTowerLevelDataEditor:SetRoguelikeHistoryMapId(nMapId)
    local LocalData = require "GameCore.Data.LocalData"
    if nMapId == nil then
        LocalData.SetPlayerLocalData(LocalStarTowerDataKey, RapidJson.encode({}))
        return
    end
    local tbHistoryMap
    local tbTemp = {}
    local nHistoryMapCount = ConfigTable.GetConfigNumber("StarTowerHistoryMapLimit")
    local sJsonRoguelikeData = LocalData.GetPlayerLocalData(LocalStarTowerDataKey)
    if type(sJsonRoguelikeData) == "string" and sJsonRoguelikeData ~= "" then
        tbHistoryMap = RapidJson.decode(sJsonRoguelikeData)
    else
        tbHistoryMap = {}
    end
    if #tbHistoryMap < nHistoryMapCount then
        table.insert(tbHistoryMap,nMapId)
    else
        table.remove(tbHistoryMap,1)
        table.insert(tbHistoryMap,nMapId)
    end
    for _,mapId in ipairs(tbHistoryMap) do
        table.insert(tbTemp,mapId)
    end
    local sJsonRoguelikeDataAfter = RapidJson.encode(tbTemp)
    LocalData.SetPlayerLocalData(LocalStarTowerDataKey, sJsonRoguelikeDataAfter)
end
function StarTowerLevelDataEditor:GetRoguelikeHistoryMapId()
    local LocalData = require "GameCore.Data.LocalData"
    local sJsonRoguelikeData = LocalData.GetPlayerLocalData(LocalStarTowerDataKey)
    if type(sJsonRoguelikeData) == "string" and sJsonRoguelikeData ~= "" then
        local tbHistoryMap = RapidJson.decode(sJsonRoguelikeData)
        return tbHistoryMap
    else
        return {}
    end
end
--临时数据相关
function StarTowerLevelDataEditor:CacheTempData()
    local FP = CS.TrueSync.FP
    self.mapCharacterTempData = {}
    local AdventureModuleHelper = CS.AdventureModuleHelper
    local id = AdventureModuleHelper.GetCurrentActivePlayer()
    self.mapCharacterTempData.curCharId = CS.AdventureModuleHelper.GetCharacterId(id)
    self.mapCharacterTempData.skillInfo = {}
    self.mapCharacterTempData.effectInfo = {}
    self.mapCharacterTempData.buffInfo = {}
    self.mapCharacterTempData.stateInfo = {}
    self.mapCharacterTempData.ammoInfo = {}
    self.mapCharacterTempData.sommonInfo = AdventureModuleHelper.GetSummonMonsterInfos()
    local playerids = AdventureModuleHelper.GetCurrentGroupPlayers()
    local Count = playerids.Count - 1
    for i = 0, Count do
        local charTid = AdventureModuleHelper.GetCharacterId(playerids[i])
        local clsSkillId = AdventureModuleHelper.GetPlayerSkillCd(playerids[i])
        local nStatus = AdventureModuleHelper.GetPlayerActorStatus(playerids[i])
        local nStatusTime = AdventureModuleHelper.GetPlayerActorSpecialStatusTime(playerids[i])
        local tbAmmo = AdventureModuleHelper.GetPlayerActorAmmoCount(playerids[i])
        local nAmmoType = AdventureModuleHelper.GetPlayerActorAmmoType(playerids[i])
        print(string.format("Status:%d,Time:%d",nStatus,nStatusTime))
        if clsSkillId ~= nil then
            local tbSkillInfos = clsSkillId.skillInfos
            local nSkillCount = tbSkillInfos.Count - 1
            for j = 0 ,nSkillCount do
               local clsSkillInfo = tbSkillInfos[j]
               local mapSkill = ConfigTable.GetData_Skill(clsSkillInfo.skillId)
               if mapSkill.Type == GameEnum.skillType.ULTIMATE then
                    table.insert(self.mapCharacterTempData.skillInfo,
                    {
                        nCharId = charTid,
                        nSkillId = clsSkillInfo.skillId,
                        nCd  = clsSkillInfo.currentUseInterval.RawValue,
                        nSectionAmount = clsSkillInfo.currentSectionAmount,
                        nSectionResumeTime = clsSkillInfo.currentResumeTime.RawValue,
                        nUseTimeHint = clsSkillInfo.currentUseTimeHint.RawValue,
                        nEnergy = clsSkillInfo.currentEnergy.RawValue,
                    })
               end
            end
        end
        self.mapCharacterTempData.effectInfo[charTid] = {mapEffect = {}}
        local tbClsEfts = AdventureModuleHelper.GetEffectList(playerids[i])
        if tbClsEfts ~= nil then 
            local nEftCount = tbClsEfts.Count - 1
            for k = 0,nEftCount do
                local eftInfo = tbClsEfts[k]
                local mapEft = ConfigTable.GetData_Effect(eftInfo.effectConfig.Id)
                local nCd = eftInfo.CD.RawValue
                if mapEft.Remove and nCd > 0 then
                    self.mapCharacterTempData.effectInfo[charTid].mapEffect[eftInfo.effectConfig.Id] = {nCount = 0,nCd = nCd}
                end
            end
        end
        if self.mapEffectTriggerCount ~= nil then
            for nEftId,nCount in pairs(self.mapEffectTriggerCount) do
                if self.mapCharacterTempData.effectInfo[charTid].mapEffect[nEftId] == nil then
                    self.mapCharacterTempData.effectInfo[charTid].mapEffect[nEftId] = {nCount = nCount,nCd = 0}
                else
                    self.mapCharacterTempData.effectInfo[charTid].mapEffect[nEftId].nCount = nCount
                end
            end
        end
        local tbBuffInfo = AdventureModuleHelper.GetEntityBuffList(playerids[i])
        self.mapCharacterTempData.buffInfo[charTid] = {}
        if tbBuffInfo ~= nil then
            local nBuffCount = tbBuffInfo.Count - 1
            for l = 0,nBuffCount do
                local eftInfo = tbBuffInfo[l]
                local mapBuff = ConfigTable.GetData_Buff(eftInfo.buffConfig.Id)
                if mapBuff.NotRemove then
                    table.insert(self.mapCharacterTempData.buffInfo[charTid],{Id = eftInfo.buffConfig.Id,CD = eftInfo:GetBuffLeftTime().RawValue,nNum = eftInfo:GetBuffNum()})
                end
            end
        end
        self.mapCharacterTempData.stateInfo[charTid] = {nState = nStatus,nStateTime = nStatusTime}
        if tbAmmo ~= nil then
            self.mapCharacterTempData.ammoInfo[charTid] = {}
            self.mapCharacterTempData.ammoInfo[charTid].nCurAmmo = nAmmoType
            self.mapCharacterTempData.ammoInfo[charTid].nAmmo1 = tbAmmo[0]
            self.mapCharacterTempData.ammoInfo[charTid].nAmmo2 = tbAmmo[1]
            self.mapCharacterTempData.ammoInfo[charTid].nAmmo3 = tbAmmo[2]
        end
    end
    local data,bZip = EncodeTempData(self.mapCharacterTempData)
    return data,bZip
    -- print("temp数据长度�?"..#data)
    -- local msgInt = "proto.I32"
    -- local msgLength = {Value = #data}
    -- local dataLength = assert(PB.encode(msgInt, msgLength))
    -- local dataNew = dataLength .. data
    -- print("temp数据total长度�?"..#dataNew)
end
--角色相关参数设置方法
function StarTowerLevelDataEditor:CalCharFixedEffect(nCharId,bMainChar)
    local stActorInfo = CS.Lua2CSharpInfo_CharAttribute()
    PlayerData.Char:CalCharacterAttrBattle(nCharId,stActorInfo,bMainChar,self.tbDisc)
    return stActorInfo
end
function StarTowerLevelDataEditor:ResetAmmo()
    if self.mapCharacterTempData.ammoInfo ~= nil then
        local ret = {}
        for nCharId,mapAmmo in ipairs(self.mapCharacterTempData.ammoInfo) do
            local stInfo = CS.Lua2CSharpInfo_ActorAmmoInfo()
            local tbAmmoCount = {stInfo.nAmmo1,stInfo.nAmmo2,stInfo.nAmmo3}
            stInfo.actorID = nCharId
            stInfo.ammoCount = tbAmmoCount
            stInfo.ammoType = mapAmmo.nCurAmmo
            table.insert(ret,stInfo)
        end
        safe_call_cs_func(CS.AdventureModuleHelper.ResetActorSkillInfo,ret)
    end
end
function StarTowerLevelDataEditor:ResetSommon()
    if self.mapCharacterTempData.sommonInfo ~= nil then
        safe_call_cs_func(CS.AdventureModuleHelper.SetSummonMonsters,self.mapCharacterTempData.sommonInfo)
    end
end
function StarTowerLevelDataEditor:ResetEffect()
    local retPotential = {}
    local retDisc = {}
    local retFateCard = {}
    local mapCharEffect = {}
    for _, nCharId in ipairs(self.tbTeam) do
        mapCharEffect[nCharId] = {}
        mapCharEffect[nCharId][AllEnum.EffectType.Affinity] = PlayerData.Char:CalcAffinityEffect(nCharId)
        mapCharEffect[nCharId][AllEnum.EffectType.Talent] = PlayerData.Char:CalcTalentEffect(nCharId)
        if self._mapPotential[nCharId] ~= nil then
            for nPotentialId, nPotentialCount  in pairs(self._mapPotential[nCharId]) do
                if mapCharEffect[nCharId][AllEnum.EffectType.Potential] == nil then
                    mapCharEffect[nCharId][AllEnum.EffectType.Potential] = {}
                end
                local mapPotentialCfgData = ConfigTable.GetData("Potential", nPotentialId)
                if mapPotentialCfgData == nil then
                    printError("Potential CfgData Missing:"..nPotentialId)
                else
                    mapCharEffect[nCharId][AllEnum.EffectType.Potential][nPotentialId] = {{},nPotentialCount}
                    if mapPotentialCfgData.EffectId1 ~= 0 then
                        table.insert(mapCharEffect[nCharId][AllEnum.EffectType.Potential][nPotentialId][1],mapPotentialCfgData.EffectId1)
                    end
                    if mapPotentialCfgData.EffectId2 ~= 0 then
                        table.insert(mapCharEffect[nCharId][AllEnum.EffectType.Potential][nPotentialId][1],mapPotentialCfgData.EffectId2)
                    end
                    if mapPotentialCfgData.EffectId3 ~= 0 then
                        table.insert(mapCharEffect[nCharId][AllEnum.EffectType.Potential][nPotentialId][1],mapPotentialCfgData.EffectId3)
                    end
                    if mapPotentialCfgData.EffectId4 ~= 0 then
                        table.insert(mapCharEffect[nCharId][AllEnum.EffectType.Potential][nPotentialId][1],mapPotentialCfgData.EffectId4)
                    end
                end
            end
        end
    end
    local mapDiscEffect = {}
    for k, nDiscId in ipairs(self.tbDisc) do
        if k <= 3 then
            local mapDiscData = PlayerData.Disc:GetDiscById(nDiscId)
            if mapDiscData ~= nil then
                local tbDiscEft = mapDiscData:GetSkillEffect(self._mapNote)
                mapDiscEffect[nDiscId] = tbDiscEft
            end
        end
    end
    local mapFateCardEffect = {}
    for nFateCardId, tbRemain in pairs(self._mapFateCard) do
        if tbRemain[1] ~= 0 and tbRemain[2] ~= 0 then
            local mapFateCardCfgData = ConfigTable.GetData("FateCard", nFateCardId)
            if mapFateCardCfgData == nil then
                printError("FateCardCfgData Missing:"..nFateCardId)
            elseif mapFateCardCfgData.ClientEffect == 0 then
                print("FateCardCfgData no clientEft:"..nFateCardId)
            else
                mapFateCardEffect[nFateCardId] = {mapFateCardCfgData.ClientEffect,tbRemain[2]}
            end
        end
    end
    for _, nCharId in ipairs(self.tbTeam) do
        if mapCharEffect[nCharId][AllEnum.EffectType.Affinity] ~= nil then
            for _, nEftId in ipairs(mapCharEffect[nCharId][AllEnum.EffectType.Affinity]) do
                local nEftUseCount = self.mapEffectTriggerCount[nEftId]
                if nEftUseCount == nil then
                    nEftUseCount = 0
                end
                UTILS.AddEffect(nCharId,nEftId,0,nEftUseCount)
            end
        end
        if mapCharEffect[nCharId][AllEnum.EffectType.Talent] ~= nil then
            for _, nEftId in ipairs(mapCharEffect[nCharId][AllEnum.EffectType.Talent]) do
                local nEftUseCount = self.mapEffectTriggerCount[nEftId]
                if nEftUseCount == nil then
                    nEftUseCount = 0
                end
                UTILS.AddEffect(nCharId,nEftId,0,nEftUseCount)
            end
        end
        if mapCharEffect[nCharId][AllEnum.EffectType.Potential] ~= nil then
            for nPotentialId, tbPotentialData in pairs(mapCharEffect[nCharId][AllEnum.EffectType.Potential]) do
                for _, nEftId in ipairs(tbPotentialData[1]) do
                    if retPotential[nPotentialId] == nil then
                        retPotential[nPotentialId] = {}
                    end
                    local nEftUseCount = self.mapEffectTriggerCount[nEftId]
                    if nEftUseCount == nil then
                        nEftUseCount = 0
                    end
                    local nEftUid = UTILS.AddEffect(nCharId,nEftId,tbPotentialData[2],nEftUseCount)
                    table.insert(retPotential[nPotentialId],{nEftUid,nCharId})
                end
            end
        end
        for nDiscId, tbDiscEft in pairs(mapDiscEffect) do
            if retDisc[nDiscId] == nil then
                retDisc[nDiscId] = {}
            end
            for _, mapEft in ipairs(tbDiscEft) do
                if retDisc[nDiscId][mapEft[1]] == nil then
                    retDisc[nDiscId][mapEft[1]] = {}
                end
                local nEftUseCount = self.mapEffectTriggerCount[mapEft[1]]
                if nEftUseCount == nil then
                    nEftUseCount = 0
                end
                local nEftUid = UTILS.AddEffect(nCharId,mapEft[1],mapEft[2],nEftUseCount)
                table.insert(retDisc[nDiscId][mapEft[1]],{nEftUid,nCharId})
            end
        end
        for nFateCardId, tbFateCardEft in pairs(mapFateCardEffect) do
            if retFateCard[nFateCardId] == nil then
                retFateCard[nFateCardId] = {}
            end
            local nEftUid = UTILS.AddFateCardEft(nCharId,tbFateCardEft[1],tbFateCardEft[2])
            if retFateCard[tbFateCardEft[1]] == nil then
                retFateCard[tbFateCardEft[1]] = {nFateCardId = nFateCardId,tbEftUid = {}}
            end
            table.insert(retFateCard[tbFateCardEft[1]].tbEftUid,{nEftUid,nCharId})
        end
    end
    return retPotential,retDisc,retFateCard
end
function StarTowerLevelDataEditor:ResetPersonalPerk()
    for nCharId, mapPotential in pairs(self._mapPotential) do
        local tbStInfo = {}
        for nPotentialId,nCount in pairs(mapPotential) do
            local stPerkInfo = CS.Lua2CSharpInfo_TPPerkInfo()
            stPerkInfo.perkId = nPotentialId
            stPerkInfo.nCount = nCount
            table.insert(tbStInfo,stPerkInfo)
        end
        safe_call_cs_func(CS.AdventureModuleHelper.ChangePersonalPerkIds,tbStInfo,nCharId)
    end
end
function StarTowerLevelDataEditor:ResetFateCard()
    local tbFCInfo = {}
    for i, v in pairs(self._mapFateCard) do
        if v[1] ~= 0 and v[2] ~= 0 then
            local cardInfo = ConfigTable.GetData("FateCard", i)
            if cardInfo.ThemeType ~= 0 then
                local fcInfo = CS.Lua2CSharpInfo_FateCardThemeInfo()
                fcInfo.theme = cardInfo.ThemeType
                fcInfo.rank = cardInfo.ThemeValue
                fcInfo.triggerTypes = cardInfo.ThemeTriggerType
                table.insert(tbFCInfo,fcInfo)
            end
        end
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetFateCardThemes,tbFCInfo)
end
function StarTowerLevelDataEditor:ResetNoteInfo()
    local tbNoteInfo = {}
    for i, v in pairs(self._mapNote) do
        local noteInfo = CS.Lua2CSharpInfo_NoteInfo()
        noteInfo.noteId = i
        noteInfo.noteCount = v
        table.insert(tbNoteInfo, noteInfo)
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetNoteInfo, tbNoteInfo)
end
function StarTowerLevelDataEditor:ResetDiscInfo()
    local tbDiscInfo = {}
    for k, nDiscId in ipairs(self.tbDisc) do
        if k <= 3 then
            local mapDiscData = PlayerData.Disc:GetDiscById(nDiscId)
            if mapDiscData ~= nil then
                local discInfo = mapDiscData:GetDiscInfo(self._mapNote)
                table.insert(tbDiscInfo, discInfo)
            end
        end
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetDiscInfo,tbDiscInfo)
end

function StarTowerLevelDataEditor:OnEvent_GMOpenDepot(callback)
    callback(self._mapPotential, self._mapNote)
end

function StarTowerLevelDataEditor:OnEvent_TestBedNoteChange(noteList)
    if noteList then
        self._mapNote = {}
        for i = 0, noteList.Count - 1 do
            self._mapNote[noteList[i].Id] = noteList[i].count
        end
        self:ResetNoteInfo()
        self:ResetDiscInfo()
        self:ChangeNote()
    end
end

return StarTowerLevelDataEditor