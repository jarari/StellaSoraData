local LocalData = require "GameCore.Data.LocalData"
local PlayerStarTowerData = class("PlayerStarTowerData")
local ClientManager = CS.ClientManager.Instance
local PB = require "pb"
local localData = require("GameCore.Data.LocalData")

function PlayerStarTowerData:Init()
    local pbSchema = NovaAPI.LoadLuaBytes("Game/Adventure/StarTower/roguelike_tempData.pb")
    assert(PB.load(pbSchema))
    self.LevelData = nil

    -- 星塔养成相关
    self:CacheClientEffectNodeConfigData()
    -- 星塔排行榜相关
    self.nRankingRewardLower = 0
    self.nMaxRankingIndex = 0
    self.nLastRankingRefreshTime = 0            -- 上次刷新时间
    self.nRankingRefreshTime = 10 * 60          -- 排行榜刷新时间
    self.mapSelfRankingData = nil               -- 自身排名数据
    self.mapRankingData = nil                   -- 榜单数据
    self.nWeekRewardCount = 0                   -- 星塔周奖励数量
    self.nStarTowerTicket = 0                   -- 通过星塔获得的星途票根数量
    self:InitConfig()
    self.tbPassedId = {}
    self.bPotentialDescSimple = nil            -- 潜能三选一是否显示简略描述（记录在本地）

    ---NPC好感度相关
    self.mapNpcAffinityGroupMaxLevel = {}
    local function forEachAffinityLevel(mapData)
        if self.mapNpcAffinityGroupMaxLevel[mapData.AffinityGroupId] == nil then
            self.mapNpcAffinityGroupMaxLevel[mapData.AffinityGroupId] = 0
        end
        if mapData.Level > self.mapNpcAffinityGroupMaxLevel[mapData.AffinityGroupId] then
            self.mapNpcAffinityGroupMaxLevel[mapData.AffinityGroupId] = mapData.Level
        end
    end
    ForEachTableLine(DataTable.NPCAffinityGroup,forEachAffinityLevel)
    self:InitNpcAffinity()
    EventManager.Add(EventId.IsNewDay, self, self.OnEvent_NewDay)
    EventManager.Add(EventId.UpdateWorldClass, self, self.OnEvent_WorldClass)
end

function PlayerStarTowerData:UnInit()
    EventManager.Remove(EventId.IsNewDay, self, self.OnEvent_NewDay)
    EventManager.Remove(EventId.UpdateWorldClass, self, self.OnEvent_WorldClass)
end

function PlayerStarTowerData:EnterTower(nTowerId,nTeamIdx,tbDisc)
    local luaClass = require "Game.Adventure.StarTower.StarTowerLevelData"
    self.LevelData = luaClass.new(self,nTowerId)
    local nStageId = self.LevelData:GetStageId(1)
    local tbTeam = PlayerData.Team:GetTeamCharId(nTeamIdx)
    local tbCharSkinId = {}
    for _, nCharId in ipairs(tbTeam) do
        table.insert(tbCharSkinId,PlayerData.Char:GetCharSkinId(nCharId))
    end
    local stRoomMeta = CS.Lua2CSharpInfo_FixedRoguelike(nTowerId,nStageId,{},tbTeam,tbCharSkinId,0,"",0,-1,false,0)
    local curMapId,nFloorId,sExdata,scenePrefabId = safe_call_cs_func2(CS.AdventureModuleHelper.RandomStarTowerMap,stRoomMeta)
    local function applyCallback(_,mapMsgData)
        local mapStateInfo = {
            Id = nTowerId,
            ReConnection = 0,
            BuildId = 0,
            CharIds = tbTeam,
            Floor = 0,
        }
        self.LevelData.nReportId = ""        
        safe_call_cs_func(CS.AdventureModuleHelper.SetDamageRecordId,"")
        PlayerData.State:CacheStarTowerStateData(mapStateInfo)
        local starTowerInfo = mapMsgData.Info
        self.LevelData:Init(starTowerInfo.Meta, starTowerInfo.Room, starTowerInfo.Bag, mapMsgData.LastId)
    end

    local mapMsg = {
        Id = nTowerId,
        FormationId = nTeamIdx,
        --DiscIds = tbDisc,
        CharHp = -1,
        MapId = curMapId,
        ParamId = nFloorId,
        MapParam = sExdata,
        MapTableId = scenePrefabId
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_apply_req, mapMsg, nil, applyCallback)
end

function PlayerStarTowerData:EnterTowerEditor(nTowerId,nMapId,nFloorId,nStage,tbTeam,tbDisc,tbNote)
    local luaClass = require "Game.Adventure.StarTower.StarTowerLevelDataEditor"
    self.LevelData = luaClass.new(self,nTowerId)
    local nLevel = self.LevelData:GetStageLevel(nStage)
    local nStageId = nStage
    local tbCharSkinId = {}
    for _, nCharId in ipairs(tbTeam) do
        table.insert(tbCharSkinId,PlayerData.Char:GetCharSkinId(nCharId))
    end
    local stRoomMeta = CS.Lua2CSharpInfo_FixedRoguelike(nTowerId,nStageId,{},tbTeam,tbCharSkinId,nMapId,"",nFloorId,-1,false,0)
    local curMapId,_,_ = safe_call_cs_func2(CS.AdventureModuleHelper.RandomStarTowerMap,stRoomMeta)
    local function applyCallback(_,mapMsgData)
        self.LevelData:Init(mapMsgData.Meta,mapMsgData.Room,mapMsgData.Bag)
    end
    local mapMsgData = {
        Meta = {
            Id = nTowerId,
            CharHp = -1,
            TeamLevel = 0,
            TeamExp = 0,
            Chars = {{Id = tbTeam[1]},{Id = tbTeam[2]},{Id = tbTeam[3]}},
            Discs = tbDisc,
            Compress = false,
            ClientData = ""
        },
        Room = {
            Data = {
                Floor = nLevel,
                MapId = curMapId,
                ParamId = nFloorId,
            },
            Cases = {
                {Id = 1,DoorCase = {Floor = 1,Type = 1,}},
                {Id = 2,BattleCase = {TimeLimit = false,FateCard = false,}},
            }
        },
        Bag = {
            Notes = {
                [1] = tbNote[90011] or 0,
                [2] = tbNote[90012] or 0,
                [3] = tbNote[90013] or 0,
                [4] = tbNote[90014] or 0,
                [5] = tbNote[90015] or 0,
            }
        }
    }
    applyCallback(nil,mapMsgData)
end
function PlayerStarTowerData:EnterTowerPrologue()
    local lastAccount = LocalData.GetLocalData("LoginUIData", "LastUserName_All")
    local sJson = LocalData.GetLocalData(lastAccount,"StarTowerPrologueLevel")
    local sJsonChar = LocalData.GetLocalData(lastAccount,"StarTowerPrologueLevelChar")
    local mapLocalData
    if sJson ~= nil then
        mapLocalData = decodeJson(sJson)
    else
        mapLocalData = {}
        mapLocalData.mapFateCard = {}
        mapLocalData.mapPotential = {}
        mapLocalData.nLevel = 1
        mapLocalData.nExp = 0
        mapLocalData.bBattleEnd = false
        mapLocalData.tbEndCaseId = {}
        mapLocalData.nCurFloor = 1
        mapLocalData.ActorHp = -1
    end
    local luaClass = require "Game.Adventure.StarTower.StarTowerPrologueLevel"
    self.LevelData = luaClass.new(self)
    local tbTeam = self.LevelData:GetTeam()
    local Discs = self.LevelData:GetDiscs()
    local nStageId = self.LevelData:GetStageId(mapLocalData.nCurFloor)
    local nLevel = mapLocalData.nCurFloor
    local tbCharSkinId = {}
    for _, nCharId in ipairs(tbTeam) do
        table.insert(tbCharSkinId,PlayerData.Char:GetCharSkinId(nCharId))
    end
    local stRoomMeta = CS.Lua2CSharpInfo_FixedRoguelike(999,nStageId,{},tbTeam,tbCharSkinId,0,"",0,-1,false,0)
    local curMapId,nFloorId,scenePrefabId = safe_call_cs_func2(CS.AdventureModuleHelper.RandomStarTowerMap,stRoomMeta)
    local function applyCallback(_,mapMsgData,mapSaveData)
        self.LevelData:Init(mapMsgData.Meta,mapMsgData.Room,mapSaveData,sJsonChar)
    end
    local mapMsgData = {
        Meta = {
            Id = 999,
            CharHp = -1,
            TeamLevel = 0,
            TeamExp = 0,
            Chars = {{Id = tbTeam[1]},{Id = tbTeam[2]},{Id = tbTeam[3]}},
            Discs = Discs,
            Compress = false,
            ClientData = ""
        },
        Room = {
            Data = {
                Floor = nLevel,
                MapId = curMapId,
                ParamId = nFloorId,
                MapTableId = scenePrefabId
            },
            Cases = {
            }
        }
    }
    applyCallback(nil,mapMsgData,mapLocalData)
end
function PlayerStarTowerData:EnterTowerFastBattle(nTowerId, nTeamIdx)
    local tbTeam = PlayerData.Team:GetTeamCharId(nTeamIdx)
    local tbCharSkinId = {}
    for _, nCharId in ipairs(tbTeam) do
        table.insert(tbCharSkinId,PlayerData.Char:GetCharSkinId(nCharId))
    end
    local function applyCallback(_,mapMsgData)
        local mapStateInfo = {
            Id = nTowerId,
            ReConnection = 0,
            BuildId = 0,
            CharIds = tbTeam,
            Floor = 0,
            Sweep = true,
        }
        PlayerData.State:CacheStarTowerStateData(mapStateInfo)
        local starTowerInfo = mapMsgData.Info
        local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
        EventManager.Hit(EventId.OpenPanel, PanelId.StarTowerFastBattle, starTowerInfo)
    end

    local mapMsg = {
        Id = nTowerId,
        FormationId = nTeamIdx,
        --DiscIds = tbDisc,
        CharHp = -1,
        MapId = -1,
        ParamId = -1,
        MapParam = "",
        MapTableId = -1,
        Sweep = true,
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_apply_req, mapMsg, nil, applyCallback)
end

function PlayerStarTowerData:ReenterTower(nTowerId)
    local function callback(_,msgData)
        local luaClass = require "Game.Adventure.StarTower.StarTowerLevelData"
        self.LevelData = luaClass.new(self,nTowerId)
        local tbTeam = {}
        for _, mapChar in ipairs(msgData.Meta.Chars) do
            table.insert(tbTeam,mapChar.Id)
        end
        local tbCharSkinId = {}
        for _, nCharId in ipairs(tbTeam) do
            table.insert(tbCharSkinId,PlayerData.Char:GetCharSkinId(nCharId))
        end
        local nFloor = msgData.Room.Data.Floor
        local nStageId = self.LevelData:GetStageId(nFloor)
        local nDangerRoom = msgData.Room.Data.RoomType

        local stRoomMeta = CS.Lua2CSharpInfo_FixedRoguelike(
            nTowerId,
            nStageId,
            {},
            tbTeam,
            tbCharSkinId,
            msgData.Room.Data.MapId,
            msgData.Room.Data.MapParam,
            msgData.Room.Data.ParamId,
            nDangerRoom,
            false,
            msgData.Room.Data.MapTableId
        )
        self.LevelData.nReportId = nReportId
        safe_call_cs_func(CS.AdventureModuleHelper.SetDamageRecordId, "")
        local curMapId,nFloorId,sExdata,_ = safe_call_cs_func2(CS.AdventureModuleHelper.RandomStarTowerMap,stRoomMeta)
        self.LevelData:Init(msgData.Meta,msgData.Room,msgData.Bag)
    end
    --发送进入请求
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_info_req, {}, nil, callback)
end

function PlayerStarTowerData:ReenterTowerFastBattle()
    local function callback(_, msgData)
        --[[
        local tbTeam = {}
        for _, mapChar in ipairs(msgData.Meta.Chars) do
            table.insert(tbTeam, mapChar.Id)
        end
        local tbCharSkinId = {}
        for _, nCharId in ipairs(tbTeam) do
            table.insert(tbCharSkinId, PlayerData.Char:GetCharSkinId(nCharId))
        end
        ]]
        local starTowerInfo = { Meta = msgData.Meta, Room = msgData.Room, Bag = msgData.Bag}
        EventManager.Hit(EventId.OpenPanel, PanelId.StarTowerFastBattle, starTowerInfo)
    end
    --发送进入请求
    HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_info_req, {}, nil, callback)
end

function PlayerStarTowerData:StarTowerEnd()
    if  self.LevelData ~= nil then
        self.LevelData:Exit()
        self.LevelData = nil
    end
end
function PlayerStarTowerData:GiveUpReconnect(nTowerId,tbMember,bShowConfirm, giveUpCallback)
    local function callback(_,msgData)
        local tbRes = {}
        local tbPresents = {}
        local tbOutfit   = {}
        local tbItem = {}
        local encodeInfo = UTILS.DecodeChangeInfo(msgData.Change)
        if encodeInfo["proto.Res"] ~= nil then
            for _, mapCoin in ipairs(encodeInfo["proto.Res"]) do
                table.insert(tbRes, {nTid = mapCoin.Tid, nCount = mapCoin.Qty})
                if mapCoin.Tid == AllEnum.CoinItemId.FRRewardCurrency then
                    PlayerData.StarTower:AddStarTowerTicket(mapCoin.Qty)
                end
            end
        end
        if encodeInfo["proto.Item"] ~= nil then
            for _, mapItem in ipairs(encodeInfo["proto.Item"]) do
                local mapItemConfigData = ConfigTable.GetData_Item(mapItem.Tid)
                if mapItemConfigData ~= nil then
                    if mapItemConfigData.Stype ~= GameEnum.itemStype.Res then
                        table.insert(tbItem,{nTid = mapItem.Tid,nCount = mapItem.Qty})
                    end
                end
            end
        end
        self:CacheNpcAffinityChange(msgData.Reward,msgData.NpcInteraction)

        local mapResult = {
            nRoguelikeId = nTowerId,
            tbRes = tbRes,
            tbPresents = tbPresents,
            tbOutfit = tbOutfit,
            tbItem = tbItem,
            tbRarityCount = {},
            bSuccess = false,
            nFloor = msgData.Floor,
            nStage = 0,
            mapBuild = msgData.Build,
            nExp = msgData.Exp,
            nPerkCount = msgData.PotentialCnt,
            tbBonus = {},
            nTime = msgData.TotalTime,
            tbAffinities = msgData.Affinities,
            mapChangeInfo = msgData.Change,
            mapNPCAffinity = msgData.Reward,
            tbRewards  = msgData.TowerRewards,
            bSweep = PlayerData.State:GetStarTowerState().Sweep,
        }

        EventManager.Hit(EventId.OpenPanel, PanelId.StarTowerResult, mapResult, tbMember)
        print("放弃重连")
        if giveUpCallback ~= nil then
            giveUpCallback()
        end
    end
    local function callfirmCallback()
        local mapStateInfo = {
            Id = 0,
            ReConnection = 0,
            BuildId = 0,
            CharIds = {},
            Floor = 0,
            Sweep = PlayerData.State:GetStarTowerState().Sweep,
        }
        PlayerData.State:CacheStarTowerStateData(mapStateInfo)
        HttpNetHandler.SendMsg(NetMsgId.Id.star_tower_give_up_req, {}, nil, callback)
    end


    local sContent = ConfigTable.GetUIText("StarTower_Pause_Tips")
    local msg = {
        nType = AllEnum.MessageBox.Confirm,
        sContent = sContent or "",
        callbackConfirm = callfirmCallback,
    }
    if bShowConfirm then
        EventManager.Hit(EventId.OpenMessageBox, msg)
    else
        callfirmCallback()
    end
end
function PlayerStarTowerData:InitConfig()
    --星塔组
    local function foreachStarTower(mapData)
        CacheTable.InsertData("_StarTower", mapData.GroupId, mapData)
        CacheTable.InsertData("_StarTowerDifficulty", mapData.ValueDifficulty, mapData)
        CacheTable.SetField("_StarTowerGroupDifficulty", mapData.GroupId, mapData.Difficulty, mapData)
    end
    ForEachTableLine(ConfigTable.Get("StarTower"), foreachStarTower)
    
    --音符掉落包
    local function foreachNoteDrop(mapData)
        CacheTable.InsertData("_SubNoteSkillDropGroup", mapData.GroupId, mapData)
    end
    ForEachTableLine(ConfigTable.Get("SubNoteSkillDropGroup"), foreachNoteDrop)
    
    --星塔限时挑战奖励
    local function foreachLimitReward(mapData)
        if nil == CacheTable.GetData("_StarTowerLimitReward", mapData.StarTowerId) then
            CacheTable.SetData("_StarTowerLimitReward", mapData.StarTowerId, {})
        end
        if nil == CacheTable.GetData("_StarTowerLimitReward", mapData.StarTowerId)[mapData.Stage] then
            CacheTable.GetData("_StarTowerLimitReward", mapData.StarTowerId)[mapData.Stage] = {}
        end
        CacheTable.GetData("_StarTowerLimitReward", mapData.StarTowerId)[mapData.Stage][mapData.RoomType] = mapData
    end
    ForEachTableLine(DataTable.StarTowerLimitReward, foreachLimitReward)
    
    --队伍经验等级(组id
    local function foreachTeamExp(mapData)
        CacheTable.SetField("_StarTowerTeamExpGroup", mapData.GroupId, mapData.Level, mapData)
    end
    ForEachTableLine(DataTable.StarTowerTeamExp, foreachTeamExp)
    
end
function PlayerStarTowerData:CachePassedId(tbIds)
    if tbIds ~= nil then
        self.tbPassedId = tbIds
        EventManager.Hit(EventId.StarTowerPass)
    end
end
function PlayerStarTowerData:CacheOnePassedId(passedId)
    if table.indexof(self.tbPassedId, passedId) < 1 then
        table.insert(self.tbPassedId, passedId)
    end
end
function PlayerStarTowerData:GetFirstPassReward(nLevelId)
    local mapLevelCfgData = ConfigTable.GetData("StarTower",nLevelId)
    if mapLevelCfgData == nil then
        return false
    end
    for _, nPassedId in ipairs(self.tbPassedId) do
        local mapPassCfgData = ConfigTable.GetData("StarTower",nPassedId)
        if mapPassCfgData ~= nil then
            if  mapPassCfgData.Difficulty >= mapLevelCfgData.Difficulty and mapLevelCfgData.GroupId == mapPassCfgData.GroupId then
                return true
            end
        end
    end    
end
function PlayerStarTowerData:GetShowHintRewardReward(nLevelId)
    local mapLevelCfgData = ConfigTable.GetData("StarTower",nLevelId)
    if mapLevelCfgData == nil then
        return false
    end
    if mapLevelCfgData.Difficulty == 1 then
        return false
    end
    if not self:IsStarTowerUnlock(nLevelId) then
        return false
    end
    for _, nPassedId in ipairs(self.tbPassedId) do
        local mapPassCfgData = ConfigTable.GetData("StarTower",nPassedId)
        if mapPassCfgData ~= nil then
            if  mapPassCfgData.Difficulty >= mapLevelCfgData.Difficulty - 1 and mapLevelCfgData.GroupId == mapPassCfgData.GroupId then
                return false
            end
        end
    end   
    return true
end
function PlayerStarTowerData:ClearData()
    if  self.LevelData ~= nil then
        self.LevelData:Exit()
        self.LevelData = nil
    end
end
function PlayerStarTowerData:QueryLevelInfo(nId,nType,nParam1,nParam2)
    if self.LevelData ~= nil and type(self.LevelData.QueryLevelInfo) == "function" then
        return self.LevelData:QueryLevelInfo(nId,nType,nParam1,nParam2)
    end
    return nil
end
--------------------------------------- 普通星塔 ---------------------------
function PlayerStarTowerData:CheckPassedId(nStarTowerId)
    if table.indexof(self.tbPassedId, nStarTowerId) < 1 then
        return false
    end
    return true
end
function PlayerStarTowerData:IsStarTowerUnlock(nStarTowerId)
    local mapStarTowerCfgData = ConfigTable.GetData("StarTower", nStarTowerId)
    if mapStarTowerCfgData == nil then
        printError("StarTower Cfg Missing:"..nStarTowerId)
        return false
    end
    local tbCond = decodeJson(mapStarTowerCfgData.PreConditions)
    if tbCond == nil then
        return true
    else
        local sTip
        for _, tbCondInfo in ipairs(tbCond) do
            if tbCondInfo[1] == 1 then
                local nCondLevelId = tbCondInfo[2]
                if table.indexof(self.tbPassedId, nCondLevelId) < 1 then
                    local mapStarTower = ConfigTable.GetData("StarTower", nCondLevelId)
                    if mapStarTower ~= nil then
                        sTip = orderedFormat(ConfigTable.GetUIText("Rogue_UnlockStarTower"), mapStarTower.Name)
                    end
                    return false, sTip, tbCondInfo[1], nCondLevelId
                end
            elseif tbCondInfo[1] == 2 then
                local nWorldCalss = PlayerData.Base:GetWorldClass()
                local nCondClass = tbCondInfo[2]
                if nWorldCalss < nCondClass then
                    sTip = orderedFormat(ConfigTable.GetUIText("Rogue_UnlockWorldLv"), nCondClass)
                    return false, sTip, tbCondInfo[1], nCondClass
                end
            elseif tbCondInfo[1] == 3 then
                local nMainlineId = tbCondInfo[2]
                local nStar = PlayerData.Mainline:GetMianlineLevelStar(nMainlineId)
                if nStar <= 0 then
                    local storyConfig = ConfigTable.GetData("Story", nMainlineId, "not have this story ID")
                    if storyConfig ~= nil then
                        sTip = orderedFormat(ConfigTable.GetUIText("Rogue_UnlockMainLine"), storyConfig.Title)
                    end
                    return false, sTip, tbCondInfo[1], nMainlineId
                end
            elseif tbCondInfo[1] == 4 then
                --TODO高亮！！！  CBT版本临时处理，星塔难度和数值难度不统一，这里先按难度-1临时处理
                local nDifficulty = tbCondInfo[2]
                local tbStarTower = CacheTable.GetData("_StarTowerDifficulty", nDifficulty)
                local bUnlock = false
                for _, v in ipairs(tbStarTower) do
                    local nId = v.Id
                    if table.indexof(self.tbPassedId, nId) >= 1 then
                        bUnlock = true
                        break
                    end
                end
                if not bUnlock then
                    sTip = orderedFormat(ConfigTable.GetUIText("Rogue_UnlockDifficulty"), nDifficulty - 1)
                    return false, sTip, tbCondInfo[1], nDifficulty
                end
            end
        end
    end
    return true
end

function PlayerStarTowerData:IsStarTowerGroupUnlock(nStarTowerGroupId)
    local bUnlock = false
    local mapStarTowerGroup = CacheTable.GetData("_StarTower", nStarTowerGroupId)
    if nil ~= mapStarTowerGroup then
        for _, v in ipairs(mapStarTowerGroup) do
            bUnlock = bUnlock or self:IsStarTowerUnlock(v.Id)
        end
    end
    return bUnlock
end

function PlayerStarTowerData:GetMaxDifficult(nGroupId)
    local ret = 1
    local mapGroup = CacheTable.GetData("_StarTower", nGroupId)
    if mapGroup == nil then
        return false
    end
    for _, mapStarTower in pairs(mapGroup) do
        if self:IsStarTowerUnlock(mapStarTower.Id) then
            if mapStarTower.Difficulty > ret then
                ret = mapStarTower.Difficulty
            end
        end
    end
    return ret
end

function PlayerStarTowerData:GetMaxPassedDifficult(nGroupId)
    local ret = 0
    local mapGroup = CacheTable.GetData("_StarTower", nGroupId)
    if mapGroup == nil then
        return ret
    end
    for _, mapStarTower in pairs(mapGroup) do
        if self:IsStarTowerUnlock(mapStarTower.Id) and self:CheckPassedId(mapStarTower.Id) then
            if mapStarTower.Difficulty > ret then
                ret = mapStarTower.Difficulty
            end
        end
    end
    return ret
end

function PlayerStarTowerData:CheckUnlockTowerSweep()
    if self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.UnlockTowerSweep] then
        for nNodeId, v in pairs(self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.UnlockTowerSweep]) do
            if not self.nFirstGrowthGroup then
                return false
            else
                local bActive = self.tbGrowthNodes[v.Group][nNodeId].bActive
                if not bActive then
                    return false
                else
                    return true
                end
            end
        end
    end
end

function PlayerStarTowerData:CheckCanSweep(nGroupId, nStarTowerId)
    local sTips, sLock = "", ""
    -- 养成锁
    if self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.UnlockTowerSweep] then
        for nNodeId, v in pairs(self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.UnlockTowerSweep]) do
            if not self.nFirstGrowthGroup then
                printError("点击星塔扫荡前未请求星塔养成数据")
                break
            else
                local bActive = self.tbGrowthNodes[v.Group][nNodeId].bActive
                if not bActive then
                    sTips = orderedFormat(ConfigTable.GetUIText("StarTower_Sweep_NodeAlert"), v.Name)
                    sLock = ConfigTable.GetUIText("StarTower_Sweep_Btn_Lock_Growth")
                    return false, sTips, sLock
                else
                    break
                end
            end
        end
    end

    -- 难度锁
    sLock = ConfigTable.GetUIText("StarTower_Sweep_Btn_Lock_Clear")
    sTips = ConfigTable.GetUIText("StarTower_Sweep_ClearAlert")
    local nMaxDifficulty = self:GetMaxPassedDifficult(nGroupId)
    if nMaxDifficulty <= 0 then
        return false, sTips, sLock
    end
    local mapGroup = CacheTable.GetData("_StarTower", nGroupId)
    if mapGroup == nil then
        return false, sTips, sLock
    end
    for _, mapStarTower in pairs(mapGroup) do
        if mapStarTower.Id == nStarTowerId then
            return mapStarTower.Difficulty <= nMaxDifficulty, sTips, sLock
        end
    end
    return false, sTips, sLock
end

function PlayerStarTowerData:GetStarTowerRewardLimit()
    local nWorldClass = PlayerData.Base:GetWorldClass()
    local worldClassCfg = ConfigTable.GetData("WorldClass", nWorldClass, true)
    if not worldClassCfg then
        return 0
    end
    local nLimit = worldClassCfg.RewardLimit
    local mapUp
    if self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.TowerTicketLimitUp] then
        for nNodeId, v in pairs(self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.TowerTicketLimitUp]) do
            if not self.nFirstGrowthGroup then
                printError("判断票根货币上限前未请求星塔养成数据")
                break
            else
                local bActive = self.tbGrowthNodes[v.Group][nNodeId].bActive
                if bActive then
                    local tbParams = decodeJson(v.ClientParams)
                    if not mapUp or mapUp.priority < v.Priority then
                        mapUp = {
                            value = tbParams[1],
                            priority = v.Priority
                        }
                    end
                end
            end
        end
    end
    local nUp = mapUp and mapUp.value or 0
    nLimit = nLimit + nUp
    return nLimit
end

function PlayerStarTowerData:GetDiscFormationSubSlot()
    local nBase = ConfigTable.GetConfigNumber("StarTowerDiscExtraSubSlotCount")
    local nSlotCount = 0
    if self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.DiscExtraSubSlot] then
        for nNodeId, v in pairs(self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.DiscExtraSubSlot]) do
            if not self.nFirstGrowthGroup then
                printError("判断辅位星盘编队开放数量前未请求星塔养成数据")
                break
            else
                local bActive = self.tbGrowthNodes[v.Group][nNodeId].bActive
                if bActive then
                    local tbParams = decodeJson(v.ClientParams)
                    if nSlotCount < tbParams[1] then
                        nSlotCount = tbParams[1]
                    end
                end
            end
        end
    end
    local nAfter = nSlotCount + nBase
    if nAfter > 3 then
        nAfter = 3
    end
    return nAfter
end

--------------------------------------- 星塔排行榜 ---------------------------

function PlayerStarTowerData:CacheStarTowerTicket(nCount)
    self.nStarTowerTicket = nCount
end
--星塔结算时更新数量
function PlayerStarTowerData:AddStarTowerTicket(nCount)
    if nCount == nil then
        return
    end
    self.nStarTowerTicket = self.nStarTowerTicket + nCount
end

function PlayerStarTowerData:GetStarTowerTicket()
    return  self.nStarTowerTicket
end

function PlayerStarTowerData:GetAvailableStarTowerTicket()
    local nLimit = self:GetStarTowerRewardLimit()
    local nAvailable = nLimit - self.nStarTowerTicket
    return nAvailable
end

function PlayerStarTowerData:OnEvent_NewDay()
    self.bGetAffinity = false
    local curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
    local nWeek = tonumber(os.date("!%w", curTimeStamp))
    if nWeek == 1 then
        --刷新门票每周获取上限
        self.nStarTowerTicket = 0
    end
end

--------------------------------------- 星塔养成 ---------------------------
function PlayerStarTowerData:CacheClientEffectNodeConfigData()
    self.tbClientEffectNodeByIndex = {}
    self.tbClientEffectNodeByType = {}
    local function foreachNode(mapLineData)
        if mapLineData.IsClient then
            local nGroupId = mapLineData.Group
            if not self.tbClientEffectNodeByIndex[nGroupId] then
                self.tbClientEffectNodeByIndex[nGroupId] = {}
            end
            if not self.tbClientEffectNodeByType[mapLineData.EffectClient] then
                self.tbClientEffectNodeByType[mapLineData.EffectClient] = {}
            end
            self.tbClientEffectNodeByIndex[nGroupId][mapLineData.NodeId] = mapLineData
            self.tbClientEffectNodeByType[mapLineData.EffectClient][mapLineData.Id] = mapLineData
        end
    end
    ForEachTableLine(DataTable.StarTowerGrowthNode, foreachNode)
end

function PlayerStarTowerData:GetClientEffectByNode(tbActiveNode)
    local tbEffectType = {}
    for nGroupId, tbGroupNode in pairs(self.tbClientEffectNodeByIndex) do
        for NodeId, mapLine in pairs(tbGroupNode) do
            local nNode = tbActiveNode[nGroupId]
            local bActive = false
            if nNode then
                bActive = (nNode & (1 << (NodeId - 1))) ~= 0
            end
            if bActive then -- 优先度判断唯一
                if not tbEffectType[mapLine.EffectClient] or tbEffectType[mapLine.EffectClient].Priority < mapLine.Priority then
                    tbEffectType[mapLine.EffectClient] = {
                        ClientParams = mapLine.ClientParams,
                        Priority = mapLine.Priority
                    }
                end
            end
        end
    end
    return tbEffectType
end

function PlayerStarTowerData:ParseGrowthData(mapMsgData)
    self.tbGrowthNodes = {}
    self.tbGrowthGroup = {}
    self.nFirstGrowthGroup = 0
    self:ParseGrowthGroupConfigData()
    self:ParseGrowthNodeConfigData(mapMsgData)
    self:ParseGrowthGroupServerData()
    self:ParseGrowthNodeServerData()
end

function PlayerStarTowerData:ParseGrowthGroupConfigData()
    local function create(mapLineData)
        local mapGroup = self.tbGrowthGroup[mapLineData.Id]
        if not mapGroup then
            mapGroup = {
                nId = mapLineData.Id,
                nPreGroup = mapLineData.PreGroup,
                nNextGroup = 0,
                nWorldClass = mapLineData.WorldClass,
                bLock = true,
                nAllNodeCount = 0,
                nActiveNodeCount = 0,
            }
            self.tbGrowthGroup[mapLineData.Id] = mapGroup
        end
        return mapGroup
    end

    local function foreachGroup(mapLineData)
        local nGroupId = mapLineData.Id
        create(mapLineData)
        if mapLineData.PreGroup ~= 0 then
            local mapCfg = ConfigTable.GetData("StarTowerGrowthGroup", mapLineData.PreGroup)
            if mapCfg then
                local mapPreGroup = create(mapCfg)
                mapPreGroup.nNextGroup = nGroupId
            end
        else
            self.nFirstGrowthGroup = nGroupId
        end
    end
    ForEachTableLine(DataTable.StarTowerGrowthGroup, foreachGroup)
end

function PlayerStarTowerData:ParseGrowthNodeConfigData(tbActiveNode)
    local function create(mapLineData)
        local mapNode = self.tbGrowthNodes[mapLineData.Group][mapLineData.Id]
        if not mapNode then
            local nNode = tbActiveNode[mapLineData.Group]
            local bActive = false
            if nNode then
                bActive = (nNode & (1 << (mapLineData.NodeId - 1))) ~= 0
            end
            mapNode = {
                nId = mapLineData.Id,
                tbPreNodes = mapLineData.PreNodes,
                tbNextNodes = {},
                bActive = bActive,
                bReady = false,
            }
            self.tbGrowthNodes[mapLineData.Group][mapLineData.Id] = mapNode
        end
        return mapNode
    end

    local function foreachNode(mapLineData)
        local nGroupId = mapLineData.Group
        if not self.tbGrowthNodes[nGroupId] then
            self.tbGrowthNodes[nGroupId] = {}
        end
        create(mapLineData)
        if #mapLineData.PreNodes > 0 then
            for _, nPreId in ipairs(mapLineData.PreNodes) do
                local mapCfg = ConfigTable.GetData("StarTowerGrowthNode", nPreId)
                if mapCfg then
                    local mapPreNode = create(mapCfg)
                    table.insert(mapPreNode.tbNextNodes, mapLineData.Id)
                end
            end
        end
    end
    ForEachTableLine(DataTable.StarTowerGrowthNode, foreachNode)
end

function PlayerStarTowerData:ParseGrowthGroupServerData()
    local nCurWorldClass = PlayerData.Base:GetWorldClass()
    local bPreGroupAllActive = true
    local mapCurGroup = self.tbGrowthGroup[self.nFirstGrowthGroup]
    while mapCurGroup do
        local nCurGroupId = mapCurGroup.nId
        local bLock = not bPreGroupAllActive or nCurWorldClass < mapCurGroup.nWorldClass
        self.tbGrowthGroup[nCurGroupId].bLock = bLock

        local nAllNodeCount, nActiveNodeCount = 0, 0
        for _, mapNode in pairs(self.tbGrowthNodes[nCurGroupId]) do
            nAllNodeCount = nAllNodeCount + 1
            if mapNode.bActive then
                nActiveNodeCount = nActiveNodeCount + 1
            end
        end
        self.tbGrowthGroup[nCurGroupId].nAllNodeCount = nAllNodeCount
        self.tbGrowthGroup[nCurGroupId].nActiveNodeCount = nActiveNodeCount

        mapCurGroup = self.tbGrowthGroup[mapCurGroup.nNextGroup]
        bPreGroupAllActive = nActiveNodeCount == nAllNodeCount
    end
end

function PlayerStarTowerData:ParseGrowthNodeServerData()
    for nGroupId, tbNodes in pairs(self.tbGrowthNodes) do
        local bGroupLock = self.tbGrowthGroup[nGroupId].bLock
        for nId, _ in pairs(tbNodes) do
            if bGroupLock then
                self.tbGrowthNodes[nGroupId][nId].bReady = false
            else
                self:CheckNodeReady(nId, nGroupId)
            end
        end
    end
end

function PlayerStarTowerData:CheckNodeReady(nId, nGroupId)
    local bAllPreActive = true
    for _, nPreId in pairs(self.tbGrowthNodes[nGroupId][nId].tbPreNodes) do
        if not self.tbGrowthNodes[nGroupId][nPreId] then
            printError("星塔养成没有节点配置"..nPreId)
        else
            if not self.tbGrowthNodes[nGroupId][nPreId].bActive then
                bAllPreActive = false
                break
            end
        end
    end
    self.tbGrowthNodes[nGroupId][nId].bReady = bAllPreActive
end

function PlayerStarTowerData:UnlockNode(nId, nGroupId)
    local nCurWorldClass = PlayerData.Base:GetWorldClass()
    local mapCurGroup = self.tbGrowthGroup[nGroupId]
    self.tbGrowthNodes[nGroupId][nId].bActive = true
    self.tbGrowthGroup[nGroupId].nActiveNodeCount = self.tbGrowthGroup[nGroupId].nActiveNodeCount + 1
    if mapCurGroup.nActiveNodeCount == mapCurGroup.nAllNodeCount then
        local nNextGroupId = mapCurGroup.nNextGroup
        if not self.tbGrowthGroup[nNextGroupId] then
            return
        end
        local bLock = nCurWorldClass < self.tbGrowthGroup[nNextGroupId].nWorldClass
        self.tbGrowthGroup[nNextGroupId].bLock = bLock
        if not bLock then
            for _, v in pairs(self.tbGrowthNodes[nNextGroupId]) do
                if #v.tbPreNodes == 0 then
                    self.tbGrowthNodes[nNextGroupId][v.nId].bReady = true
                end
            end
        end
    else
        for _, nNextId in pairs(self.tbGrowthNodes[nGroupId][nId].tbNextNodes) do
            self:CheckNodeReady(nNextId, nGroupId)
        end
    end
end

function PlayerStarTowerData:UnlockMultiNode(tbNodeId, nGroupId)
    local bHasCore = false
    for _, nId in ipairs(tbNodeId) do
        local mapCfg = ConfigTable.GetData("StarTowerGrowthNode", nId)
        if mapCfg then
            self.tbGrowthNodes[nGroupId][nId].bActive = true
            self.tbGrowthGroup[nGroupId].nActiveNodeCount = self.tbGrowthGroup[nGroupId].nActiveNodeCount + 1
            if mapCfg.Type == GameEnum.towerGrowthNodeType.Core then
                bHasCore = true
            end
        end
    end

    local nCurWorldClass = PlayerData.Base:GetWorldClass()
    local mapCurGroup = self.tbGrowthGroup[nGroupId]
    if mapCurGroup.nActiveNodeCount == mapCurGroup.nAllNodeCount then
        local nNextGroupId = mapCurGroup.nNextGroup
        if not self.tbGrowthGroup[nNextGroupId] then
            return bHasCore
        end
        local bLock = nCurWorldClass < self.tbGrowthGroup[nNextGroupId].nWorldClass
        self.tbGrowthGroup[nNextGroupId].bLock = bLock
        if not bLock then
            for _, v in pairs(self.tbGrowthNodes[nNextGroupId]) do
                if #v.tbPreNodes == 0 then
                    self.tbGrowthNodes[nNextGroupId][v.nId].bReady = true
                end
            end
        end
    else
        for nId, v in pairs(self.tbGrowthNodes[nGroupId]) do
            if not v.bActive then
                self:CheckNodeReady(nId, nGroupId)
            end
        end
    end

    return bHasCore
end

function PlayerStarTowerData:GetGrowthGroup(nId)
    return self.tbGrowthGroup[nId]
end

function PlayerStarTowerData:GetSortedGrowthGroup()
    local tbSorted = {}
    local mapCurGroup = self.tbGrowthGroup[self.nFirstGrowthGroup]
    while mapCurGroup do
        table.insert(tbSorted, mapCurGroup)
        mapCurGroup = self.tbGrowthGroup[mapCurGroup.nNextGroup]
    end
    return tbSorted
end

function PlayerStarTowerData:GetGrowthNodesByGroup(nGroupId)
    return self.tbGrowthNodes[nGroupId]
end

function PlayerStarTowerData:GetGrowthNode(nId, nGroupId)
    if not nGroupId then
        local mapCfg = ConfigTable.GetData("StarTowerGrowthNode", nId)
        if not mapCfg then
            printError("星塔养成节点Id有误, 未找到配置表数据, Id: " .. nId)
            return {}
        end
        nGroupId = mapCfg.Group
    end
    return self.tbGrowthNodes[nGroupId][nId]
end

function PlayerStarTowerData:CheckGroupReady(nGroupId)
    if self.tbGrowthGroup[nGroupId].bLock then
        return false, ConfigTable.GetUIText("STGrowth_GroupLocked")
    end

    local bGroupAllActive = self.tbGrowthGroup[nGroupId].nAllNodeCount == self.tbGrowthGroup[nGroupId].nActiveNodeCount
    if bGroupAllActive then
        return false, ConfigTable.GetUIText("STGrowth_GroupAlreadyActived")
    end

    local tbGroup = {}
    for _, v in pairs(self.tbGrowthNodes[nGroupId]) do
        table.insert(tbGroup, v)
    end
    table.sort(tbGroup, function (a, b)
        return ConfigTable.GetData("StarTowerGrowthNode", a.nId).NodeId < ConfigTable.GetData("StarTowerGrowthNode", b.nId).NodeId
    end)

    local function checkMat(mapCfg)
        local bMat = true
        for i = 1, 3 do
            if mapCfg["ItemId" .. i] ~= 0 then
                local nHas = PlayerData.Item:GetItemCountByID(mapCfg["ItemId" .. i])
                if nHas < mapCfg["ItemQty" .. i] then
                    bMat = false
                    break
                end
            end
        end
        return bMat
    end

    local bAble = false
    for _, v in ipairs(tbGroup) do
        if not v.bActive and v.bReady then
            local mapCfg = ConfigTable.GetData("StarTowerGrowthNode", v.nId)
            if mapCfg then
                bAble = checkMat(mapCfg) -- 只判断待激活的第一个
                break
            end
        end
    end
    return bAble, ConfigTable.GetUIText("STGrowth_NoMat")
end

function PlayerStarTowerData:SendTowerGrowthDetailReq(callback)
    if not self.nFirstGrowthGroup then
        local function successCallback(_, mapMainData)
            -- int32数组，索引是GroupId
            self:ParseGrowthData(mapMainData.Detail)
            self:UpdateGrowthReddot()
            if callback then
                callback()
            end
        end
        HttpNetHandler.SendMsg(NetMsgId.Id.tower_growth_detail_req, {}, nil, successCallback)
    else
        if callback then
            callback()
        end
    end
end

function PlayerStarTowerData:SendTowerGrowthNodeUnlockReq(nId, nGroupId, callback)
    local msgData = {
        Value = nId,
    }
    local function successCallback(_, mapMainData)
        self:UnlockNode(nId, nGroupId)
        self:UpdateGrowthReddot()
        if callback then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.tower_growth_node_unlock_req, msgData, nil, successCallback)
end

function PlayerStarTowerData:SendTowerGrowthGroupNodeUnlockReq(nGroupId, callback)
    local msgData = {
        Value = nGroupId,
    }
    local function successCallback(_, mapMainData)
        local tbDecodeChange = UTILS.DecodeChangeInfo(mapMainData.ChangeInfo)
        local tbItem = tbDecodeChange["proto.Item"]
        if type(tbItem) == "table" and #tbItem == 1 and tbItem[1].Qty < 0 then
            local nCount = -1 * tbItem[1].Qty
            EventManager.Hit(EventId.OpenMessageBox, orderedFormat(ConfigTable.GetUIText("STGrowth_AllActiveSuc") or "", nCount, #mapMainData.Nodes))
        end

        local bHasCore = self:UnlockMultiNode(mapMainData.Nodes, nGroupId)
        self:UpdateGrowthReddot()
        if callback then
            callback(mapMainData.Nodes, bHasCore)
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.tower_growth_group_node_unlock_req, msgData, nil, successCallback)
end

function PlayerStarTowerData:UpdateGrowthReddot()
    local function checkMat(mapCfg)
        local bMat = true
        for i = 1, 3 do
            if mapCfg["ItemId" .. i] ~= 0 then
                local nHas = PlayerData.Item:GetItemCountByID(mapCfg["ItemId" .. i])
                if nHas < mapCfg["ItemQty" .. i] then
                    bMat = false
                    break
                end
            end
        end
        return bMat
    end

    local nGroupCount = #self.tbGrowthGroup
    local nGroupId
    for i = nGroupCount, 1, -1 do
        if not self.tbGrowthGroup[i].bLock then
            nGroupId = i
            break
        end
    end

    local bHas = false
    if self.tbGrowthNodes[nGroupId] then
        for nId, mapNode in pairs(self.tbGrowthNodes[nGroupId]) do
            if not mapNode.bActive and mapNode.bReady then
                local mapCfg = ConfigTable.GetData("StarTowerGrowthNode", nId)
                if mapCfg and checkMat(mapCfg) then
                    bHas = true
                    break
                end
            end
        end
    end
    RedDotManager.SetValid(RedDotDefine.StarTowerGrowth, nil, bHas)
end

function PlayerStarTowerData:UpdateGrowthRedDotByItem(mapChange)
    if not self.nFirstGrowthGroup then
        return
    end
    if not self.tbGrowthNodeMat then
        self.tbGrowthNodeMat = ConfigTable.GetConfigNumberArray("StarTowerGrowthItemIds")
    end
    for _, v in ipairs(mapChange) do
        if table.indexof(self.tbGrowthNodeMat, v.Tid) > 0 and v.Qty > 0 then
            self:UpdateGrowthReddot()
            return
        end
    end
end

function PlayerStarTowerData:OnEvent_WorldClass()
    if not self.nFirstGrowthGroup then
        return
    end
    local nCurWorldClass = PlayerData.Base:GetWorldClass()
    for nGroupId, v in ipairs(self.tbGrowthGroup) do -- 按顺序查，第一个被锁着的层才判断，后面层肯定还是锁着的
        if v.bLock then
            local mapPreGroup = self.tbGrowthGroup[v.nPreGroup]
            local bPreGroupAllActive = mapPreGroup.nAllNodeCount == mapPreGroup.nActiveNodeCount
            local bLock = not bPreGroupAllActive or nCurWorldClass < v.nWorldClass
            if not bLock then
                self.tbGrowthGroup[nGroupId].bLock = bLock
                for nNodeId, mapNode in pairs(self.tbGrowthNodes[nGroupId]) do
                    if #mapNode.tbPreNodes == 0 then
                        self.tbGrowthNodes[nGroupId][nNodeId].bReady = true
                    end
                end
            end
            self:UpdateGrowthReddot()
            break
        end
    end
end
---------------------------------------NPC AFFINITY------------------------------------
function PlayerStarTowerData:GetAffinity(callback)
    local function netMsg_callback(_,msgData)
        self:CacheNpcAffinity(msgData)
        if callback ~= nil then
            self.bGetAffinity = true
            callback()
        end
    end
    if self.bGetAffinity == true then
        if callback ~= nil then
            callback()
        end
        return
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.npc_affinity_book_get_req, {}, nil, netMsg_callback)
end
function PlayerStarTowerData:InitNpcAffinity()
    self.mapNpcAffinity = {}
    self.nAffinityGetCount = 0
    self.bGetAffinity = false
end
function PlayerStarTowerData:CacheNpcAffinity(mapData)
    self.nAffinityGetCount = mapData.Number
    for _ , mapAffinityData in ipairs(mapData.Infos) do
        local ret = {
            Level = 0,
            Exp = 0,
            nNeed = 0,
            nTotalExp = mapAffinityData.Affinity,
            nMaxLevel = 0,
            tbPlotIds = mapAffinityData.PlotIds,
        }
        local nAffinityExp = mapAffinityData.Affinity
        local mapNpc = ConfigTable.GetData("StarTowerNPC",mapAffinityData.NPCId)
        if mapNpc == nil then
            self.mapNpcAffinity[mapAffinityData.NPCId] = ret
        end
        local nGroupId = mapNpc.AffinityGroupId
        local nMaxLevel = self.mapNpcAffinityGroupMaxLevel[nGroupId]
        ret.nMaxLevel = nMaxLevel
        if nMaxLevel == nil then
            self.mapNpcAffinity[mapAffinityData.NPCId] = ret
        end
        for i = 0, nMaxLevel do
            local nId = nGroupId * 100 + i
            local mapAffinityCfgData = ConfigTable.GetData("NPCAffinityGroup",nId)
            if mapAffinityCfgData ~= nil then
                if mapAffinityCfgData.AffinityValue <= nAffinityExp then
                    ret.Level = mapAffinityCfgData.Level
                    ret.Exp = nAffinityExp - mapAffinityCfgData.AffinityValue
                    if mapAffinityCfgData.Level + 1 <= nMaxLevel then
                        local nNextId = nGroupId * 100 + mapAffinityCfgData.Level + 1
                        local nNextLevelCfgData = ConfigTable.GetData("NPCAffinityGroup",nNextId)
                        if nNextLevelCfgData ~= nil then
                            ret.nNeed = nNextLevelCfgData.AffinityValue - mapAffinityCfgData.AffinityValue
                        end
                    else
                        ret.nNeed = 0
                    end
                end
            end
        end
        self.mapNpcAffinity[mapAffinityData.NPCId] = ret
    end
    self:UpdateNpcAffinityRedDot()
end
function PlayerStarTowerData:ReceiveNpcAffinityReward(nNpcId,nPlotId,receiveCallback)
    local mapMsg = {Value = nPlotId}
    local function receivePropCallback(mapShow,mapChange)
        if receiveCallback ~= nil and type(receiveCallback) == "function" then
            receiveCallback(mapShow,mapChange)
        end
    end
    local function callback(_,mapRespData)
        if self.mapNpcAffinity ~= nil then
            if self.mapNpcAffinity[nNpcId] == nil then
                self.mapNpcAffinity[nNpcId] = {
                Level = 0,
                Exp = 0,
                nNeed = 0,
                nTotalExp = 0,
                nMaxLevel = 0,
                tbPlotIds = {},}
            end
            if self.mapNpcAffinity[nNpcId].tbPlotIds ~= nil then
                table.insert(self.mapNpcAffinity[nNpcId].tbPlotIds,nPlotId)
            end
        end 
        self:UpdateNpcAffinityRedDot()
        receivePropCallback(mapRespData.Show, mapRespData.Change) 
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.npc_affinity_plot_reward_receive_req, mapMsg, nil, callback)
end
function PlayerStarTowerData:GetNpcAffinityWeekCount()
    return self.nAffinityGetCount
end
function PlayerStarTowerData:CacheNpcAffinityChange(tbRewards,nCount)
    for _, mapReward in ipairs(tbRewards) do
        local nNpcId = mapReward.Change.NPCId
        if self.mapNpcAffinity[nNpcId] == nil then
            self.mapNpcAffinity[nNpcId] = {           
            Level = 0,
            Exp = 0,
            nNeed = 0,
            nTotalExp = 0,
            nMaxLevel = 0,
            tbPlotIds = {},
        }
        end
        self.mapNpcAffinity[nNpcId].nTotalExp = mapReward.Change.Affinity
        local nAffinityExp = mapReward.Change.Affinity
        local mapNpc = ConfigTable.GetData("StarTowerNPC",nNpcId)
        if mapNpc ~= nil then
            local nGroupId = mapNpc.AffinityGroupId
            local nMaxLevel = self.mapNpcAffinityGroupMaxLevel[nGroupId]
            self.mapNpcAffinity[nNpcId].nMaxLevel = nMaxLevel
            if nMaxLevel ~= nil then
                for i = 0, nMaxLevel do
                    local nId = nGroupId * 100 + i
                    local mapAffinityCfgData = ConfigTable.GetData("NPCAffinityGroup",nId)
                    if mapAffinityCfgData ~= nil then
                        if mapAffinityCfgData.AffinityValue <= nAffinityExp then
                            self.mapNpcAffinity[nNpcId].Level = mapAffinityCfgData.Level
                            self.mapNpcAffinity[nNpcId].Exp = nAffinityExp - mapAffinityCfgData.AffinityValue
                            if mapAffinityCfgData.Level + 1 <= nMaxLevel then
                                local nNextId = nGroupId * 100 + mapAffinityCfgData.Level + 1
                                local nNextLevelCfgData = ConfigTable.GetData("NPCAffinityGroup",nNextId)
                                if nNextLevelCfgData ~= nil then
                                    self.mapNpcAffinity[nNpcId].nNeed = nNextLevelCfgData.AffinityValue - mapAffinityCfgData.AffinityValue
                                end
                            else
                                self.mapNpcAffinity[nNpcId].nNeed = 0
                            end
                        end
                    end
                end
            end
        end
    end
    if nCount ~= nil then
        self.nAffinityGetCount = nCount
    end
    self:UpdateNpcAffinityRedDot()
end
function PlayerStarTowerData:GetNpcAffinityData(nNpcId)
    if self.mapNpcAffinity[nNpcId] ~= nil then
       return clone(self.mapNpcAffinity[nNpcId])
    else
        local ret = {
            Level = 0,
            Exp = 0,
            nNeed = 1,
            nTotalExp = 0,
            nMaxLevel = 0,
            tbPlotIds = {},
        }
        local mapNpc = ConfigTable.GetData("StarTowerNPC",nNpcId)
        if mapNpc ~= nil then
            local nGroupId = mapNpc.AffinityGroupId
            local nId = nGroupId * 100 + 1
            local mapAffinityCfgData = ConfigTable.GetData("NPCAffinityGroup",nId)
            if mapAffinityCfgData ~= nil then
                ret.nNeed = mapAffinityCfgData.AffinityValue
            end
        end
        return ret
    end
end
function PlayerStarTowerData:GetNpcReceivedPlot(nNpcId)
    if self.mapNpcAffinity[nNpcId] ~= nil then
        return self.mapNpcAffinity[nNpcId].tbPlotIds
    else
        return {}
    end
end
function PlayerStarTowerData:GetNpcPlotReceived(nNpcId,nPlotId)
    if self.mapNpcAffinity[nNpcId] ~= nil then
        return table.indexof(self.mapNpcAffinity[nNpcId].tbPlotIds,nPlotId) > 0
    else
        return false
    end
end
function PlayerStarTowerData:GMChangeNpcAffinity(mapInfo)
    local nNpcId = mapInfo.NPCId
    if self.mapNpcAffinity[nNpcId] == nil then
        self.mapNpcAffinity[nNpcId] = {Level = 0,Exp = 0, nNeed = 0,nTotalExp = 0,nMaxLevel = 0,tbPlotIds = {}}
    end
    self.mapNpcAffinity[nNpcId].nTotalExp = mapInfo.Affinity
    local nAffinityExp = mapInfo.Affinity
    local mapNpc = ConfigTable.GetData("StarTowerNPC",nNpcId)
    if mapNpc ~= nil then
        local nGroupId = mapNpc.AffinityGroupId
        local nMaxLevel = self.mapNpcAffinityGroupMaxLevel[nGroupId]
        self.mapNpcAffinity[nNpcId].nMaxLevel = nMaxLevel
        if nMaxLevel ~= nil then
            for i = 0, nMaxLevel do
                local nId = nGroupId * 100 + i
                local mapAffinityCfgData = ConfigTable.GetData("NPCAffinityGroup",nId)
                if mapAffinityCfgData ~= nil then
                    if mapAffinityCfgData.AffinityValue <= nAffinityExp then
                        self.mapNpcAffinity[nNpcId].Level = mapAffinityCfgData.Level
                        self.mapNpcAffinity[nNpcId].Exp = nAffinityExp - mapAffinityCfgData.AffinityValue
                        if mapAffinityCfgData.Level + 1 <= nMaxLevel then
                            local nNextId = nGroupId * 100 + mapAffinityCfgData.Level + 1
                            local nNextLevelCfgData = ConfigTable.GetData("NPCAffinityGroup",nNextId)
                            if nNextLevelCfgData ~= nil then
                                self.mapNpcAffinity[nNpcId].nNeed = nNextLevelCfgData.AffinityValue - mapAffinityCfgData.AffinityValue
                            end
                        else
                            self.mapNpcAffinity[nNpcId].nNeed = 0
                        end
                    end
                end
            end
        end
    end
    self:UpdateNpcAffinityRedDot()
end
function PlayerStarTowerData:UpdateNpcAffinityRedDot()
    local function forEachNpc(mapData)
        RedDotManager.SetValid(RedDotDefine.StarTowerBook_Affinity_Reward, mapData.Id, false)
    end
    ForEachTableLine(DataTable.StarTowerNPC,forEachNpc)
    local function ForEachNpcPlot(mapData)
        local nNpcId = mapData.NPCId
        if self.mapNpcAffinity[nNpcId] ~= nil then
            if self.mapNpcAffinity[nNpcId].Level >= mapData.AffinityLevel and
            table.indexof(self.mapNpcAffinity[nNpcId].tbPlotIds,mapData.Id) < 1 then
                RedDotManager.SetValid(RedDotDefine.StarTowerBook_Affinity_Reward, nNpcId, true)
            end
        end
    end
    ForEachTableLine(DataTable.NPCAffinityPlot,ForEachNpcPlot)
end 
------------------------------------------ 通用 ---------------------------------------
function PlayerStarTowerData:SetPotentialDescSimple(bSimple)
    self.bPotentialDescSimple = bSimple
    LocalData.SetPlayerLocalData("StarTowerPotentialDescSimple", bSimple and "1" or "0")
end
function PlayerStarTowerData:GetPotentialDescSimple()
    if self.bPotentialDescSimple == nil then
        local sValue = LocalData.GetPlayerLocalData("StarTowerPotentialDescSimple")
        if sValue == nil then
            sValue = ConfigTable.GetConfigValue("PotentialShowDetail")
            LocalData.SetPlayerLocalData("StarTowerPotentialDescSimple", sValue)
        end
        self.bPotentialDescSimple = tonumber(sValue) ~= 1
    end
    return self.bPotentialDescSimple
end
-- 潜能最大等级 潜能配置+当前养成提升
function PlayerStarTowerData:GetPotentialMaxLevelWithCurGrowth(nId)
    local nMaxLevel = 0
    -- 配置
    local mapCfg = ConfigTable.GetData("Potential", nId)
    if mapCfg then
        nMaxLevel = nMaxLevel + mapCfg.MaxLevel
    end
    -- 养成
    local nAdd = 0
    if self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.PotentialMaxLvUp] then
        for nNodeId, v in pairs(self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.PotentialMaxLvUp]) do
            if not self.nFirstGrowthGroup then
                printError("查询潜能最大等级前未请求星塔养成数据")
                break
            else
                local bActive = self.tbGrowthNodes[v.Group][nNodeId].bActive
                if bActive then
                    local tbParams = decodeJson(v.ClientParams)
                    if nAdd < tbParams[1] then
                        nAdd = tbParams[1]
                    end
                end
            end
        end
    end
    nMaxLevel = nMaxLevel + nAdd

    return nMaxLevel
end
-- 潜能最大等级 潜能配置+最大养成提升
function PlayerStarTowerData:GetPotentialMaxLevelWithMaxGrowth(nId)
    local nMaxLevel = 0
    -- 配置
    local mapCfg = ConfigTable.GetData("Potential", nId)
    if mapCfg then
        nMaxLevel = nMaxLevel + mapCfg.MaxLevel
    end
    -- 养成
    local nAdd = 0
    if self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.PotentialMaxLvUp] then
        for _, v in pairs(self.tbClientEffectNodeByType[GameEnum.towerGrowthEffect.PotentialMaxLvUp]) do
            local tbParams = decodeJson(v.ClientParams)
            if nAdd < tbParams[1] then
                nAdd = tbParams[1]
            end
        end
    end
    nMaxLevel = nMaxLevel + nAdd

    return nMaxLevel
end
-- 潜能最大等级 潜能配置+最大养成提升+装备提升
function PlayerStarTowerData:GetPotentialMaxLevelWithEquipment()
    return ConfigTable.GetConfigNumber("CharMaxPonLevel")
end

return PlayerStarTowerData