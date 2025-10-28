--PlayerRoguelikeData: 储存了玩家在遗迹关卡中的各种数据和服务器通信方法
--  PlayerRoguelikeData中关卡流程推进由c#消息驱动（包括宝箱，击杀怪物等）
--  由于不同层对流程消息的处理方式不同所以将层的消息处理作为process（Game/Adventure/RoguelikeFloor)
--  本次修改后移除了PlayerRoguelikeData中所有的状态变量，完全由process确定当前层的数据处理方法
--  每层的process实现了对roguelike消息的处理方法，由self.curFloorProcess调用
--  在结算时会记录下一层的process（nextFloorProcess），会在self:FloorEnd()中切换当前层的process
--  self:FloorEnd()是该层结束的方法，process中一定在最后调用该方法（在editor中是FloorEndEditor）
--  具体的层处理的注释写在每个process中
--  所有的流程处理方法都用注释隔开了，如果遇到问题可以在该层的process中找到当前的当前阶段的处理方法定位到问题的位置
--  如果要添加新的功能可以在原有的process function中修改但是要考虑其他层也会用到的情况，比较特殊的可以直接添加新的处理方法和process
--  层process的加载在self:LoadRoguelikeProcess()中如果有新的请添加到这里
--  因为有些层的结算和关卡切换不是同步的，所以需要记录下层的process在该层结束后切换
--  调用process的处理方法是通过方法名调用的，所以在新建层process时请注意方法名






local RapidJson = require "rapidjson"

local TimerManager = require "GameCore.Timer.TimerManager"

local serpent = require "serpent"
local AdventureModuleHelper = CS.AdventureModuleHelper
local PB = require "pb"
local PlayerRoguelikeData =  class("PlayerRoguelikeData")



-----------------------------------------------local function------------------------------------------
--向cs端设置当前遗迹和队伍信息 重连进入遗迹
function PlayerRoguelikeData:ReenterRoguelike(mapData)
    self:InitRoguelikeBag()
    PlayerData.nCurGameType = AllEnum.WorldMapNodeType.Roguelike
    local arrMapId = self:GetRoguelikeHistoryMapId(self.curRoguelikeId)
    local lastMapId = mapData.MapId
    safe_call_cs_func(CS.AdventureModuleHelper.EnterSelectTeam,AllEnum.WorldMapNodeType.Roguelike, mapData.FloorInfo.FloorID, arrMapId,lastMapId)
    if mapData.Items ~= nil then
        self:CacheRoguelikeBag(mapData.Items)
    end

    self.bKillBoss = mapData.IsKill
    local tbActorInfo = {}
    for index = 1, #mapData.Chars do
        local stCharInfo = CS.ActorInfo_Roguelike(mapData.Chars[index].Tid,mapData.Chars[index].CurHp)
        table.insert(tbActorInfo, stCharInfo)
    end
    local nRoguelikeId = ConfigTable.GetData("RoguelikeMap", mapData.MapId).RoguelikeId
    local nDifficult = ConfigTable.GetData("Roguelike", nRoguelikeId).Difficulty

    local stRoguelikeInfo = CS.Lua2CSharpInfo_Roguelike()
    if mapData.BossId ~= 0 then
        self.curFloorProcess = self._proc_bossFloor
        self.curFloorProcess:Init()
        if self.bKillBoss then
            self._nCurEnergy = self._nCurEnergy + ConfigTable.GetData("RoguelikeFloor", self._nFloorId).NeedEnergy
        end
    elseif ConfigTable.GetData("RoguelikeFloor", mapData.FloorInfo.FloorID).Floor == 1 then
        self.curFloorProcess = self._proc_firstFloor
        self.curFloorProcess:Init()
    else
        self.curFloorProcess = self._proc_normalFloor
        self.curFloorProcess:Init()
        self._nCurEnergy = self._nCurEnergy + ConfigTable.GetData("RoguelikeFloor", self._nFloorId).NeedEnergy
    end
    stRoguelikeInfo:SetData(nRoguelikeId,nDifficult,lastMapId,mapData.FloorInfo.FloorID,tbActorInfo,arrMapId,false,self.bKillBoss)

    for _, mapFloorData in pairs(CacheTable.GetData("_RoguelikeFloor", self.curRoguelikeId) or {}) do
        if mapFloorData.Floor < ConfigTable.GetData("RoguelikeFloor", self._nFloorId).Floor then
            self._nCurEnergy = self._nCurEnergy + mapFloorData.NeedEnergy
        end
    end

    safe_call_cs_func2(CS.AdventureModuleHelper.RandomRoguelikeMapId,stRoguelikeInfo)
    local tbChestInfo
    self._mapRandomChest,self._mapConstentChest, tbChestInfo = self:ProcessChestData(mapData.FloorInfo.RandomChests, mapData.FloorInfo.ConstantChests)
    self:LogChestItem()
    safe_call_cs_func(CS.AdventureModuleHelper.SetRoguelikeChestData,tbChestInfo)
    self:SetRoguelikeHistoryMapId(self.curRoguelikeId, mapData.MapId)
    if mapData.Records ~= nil then
        self:ReenterSetCurrentCharByServer(mapData.Records)
    else
        self:ReenterSetCurrentCharByLocal()
    end
    self:SetCharTalent()
    NovaAPI.EnterModule("AdventureModuleScene", true,17)
end
--设置当前流程，开始遗迹关卡
function PlayerRoguelikeData:EnterRoguelike(mapData)
    self.curFloorProcess = self._proc_firstFloor
    self.curFloorProcess:Init()
    self:SetCharTalent()
    NovaAPI.EnterModule("AdventureModuleScene", true,17)
end
function PlayerRoguelikeData:AddActorTalentEffects(mapTalent)
    local tbRet = {}
    local stActorAttribute = CS.Lua2CSharpInfo_ActorTalentEffect()
    local tbEftId = {}
    local tbEffect = decodeJson(ConfigTable.GetData("RoguelikeTalent", mapTalent.Tid).EffectList)
    local tbCurEffect = tbEffect[1]
    for k = 1,#tbCurEffect do
        table.insert(tbEftId, tbCurEffect[k])
    end
    stActorAttribute.actorID = mapTalent.CharId
    if tbEftId ~= nil then
        stActorAttribute.effectIds = tbEftId
    else
        stActorAttribute.effectIds = {}
    end
    table.insert(tbRet, stActorAttribute)
    safe_call_cs_func(AdventureModuleHelper.AddActorTalentEffects,tbRet)
end
function PlayerRoguelikeData:AddActorAttrEffects(nTid)
    local tbRet = {}
    local nCaptainIndex,tbTeamMemberId=PlayerData.Team:GetTeamData(5)
    local tbEftId = {}
    local tbEffect = decodeJson(ConfigTable.GetData("RoguelikeTalent", nTid).EffectList)
    local tbCurEffect = tbEffect[1]
    for k = 1,#tbCurEffect do
        table.insert(tbEftId, tbCurEffect[k])
    end
    for _, nCharId in ipairs(tbTeamMemberId) do
        local stActorAttribute = CS.Lua2CSharpInfo_ActorTalentEffect()
        stActorAttribute.actorID = nCharId
        if tbEftId ~= nil then
            stActorAttribute.effectIds = tbEftId
        else
            stActorAttribute.effectIds = {}
        end
        table.insert(tbRet,stActorAttribute)
    end
    AdventureModuleHelper.AddActorTalentEffects(tbRet)
end
function PlayerRoguelikeData:GetNextFloorInfo()
    local tbTeamCharInfo = {}
    local arrMapId = self:GetRoguelikeHistoryMapId(self.curRoguelikeId)
    local nCaptainIndex,tbTeamMemberId=PlayerData.Team:GetTeamData(5)
    local mapCurCharInfo = self.GetActorHp()
    local mapCaptainInfo = {nId = tbTeamMemberId[nCaptainIndex],nHp = mapCurCharInfo[tbTeamMemberId[nCaptainIndex]]}
    table.insert(tbTeamCharInfo, mapCaptainInfo)
    for i = 1, #tbTeamMemberId do
        if i ~= nCaptainIndex then
            local nActorHp = mapCurCharInfo[tbTeamMemberId[i]]
            local mapActorInfo = {nId = tbTeamMemberId[i],nHp = nActorHp}
            table.insert(tbTeamCharInfo, mapActorInfo)
        end
    end

    local tbActorInfo = {}
    for index = 1, #tbTeamCharInfo do
        local stCharInfo = CS.ActorInfo_Roguelike(tbTeamCharInfo[index].nId,tbTeamCharInfo[index].nHp)
        table.insert(tbActorInfo, stCharInfo)
    end

    local nCurFloor = ConfigTable.GetData("RoguelikeFloor", self._nFloorId).Floor
    local nNextFloorId = 0
    if CacheTable.GetData("_RoguelikeFloor", self.curRoguelikeId)[nCurFloor+1] == nil then
        return 0, 0
    else
        nNextFloorId = CacheTable.GetData("_RoguelikeFloor", self.curRoguelikeId)[nCurFloor+1].Id
    end
    local nDifficult = ConfigTable.GetData("Roguelike", self.curRoguelikeId).Difficulty

    local stRoguelikeInfo = CS.Lua2CSharpInfo_Roguelike(self.curRoguelikeId,nDifficult,0,nNextFloorId,tbActorInfo,arrMapId,false,false)
    local nMapId, nBossId = safe_call_cs_func2(CS.AdventureModuleHelper.RandomRoguelikeMapId,stRoguelikeInfo)
    self:SetRoguelikeHistoryMapId(self.curRoguelikeId, nMapId)
    print("Next Boss ID:" .. nBossId)
    return nMapId, nBossId
end
function PlayerRoguelikeData:LoadRoguelikeProcess()
    self._proc_firstFloor = require "Game.Adventure.RoguelikeFloor.FirstFloor"
    self._proc_bossFloor = require "Game.Adventure.RoguelikeFloor.BossFloor"
    self._proc_normalFloor = require "Game.Adventure.RoguelikeFloor.NormalFloor"
    self._proc_renterBossDiedFloor = require "Game.Adventure.RoguelikeFloor.RenterBossDiedFloor"
end
function PlayerRoguelikeData:LoadRoguelikeProcessEditor()
    self._proc_Editor = require "Game.Adventure.RoguelikeFloor.EditorFloor"
end
function PlayerRoguelikeData:GiveupSuccessCallBack(mapMsgData,bFailed)
    local ncurFloor,totalFloor = self:GetFloorInfo()
    local nPerkCount = self:CalPerkPerkCount()
    if NovaAPI.GetCurrentModuleName() == "AdventureModuleScene" then
        if bFailed~= nil then --关卡失败时需要延迟弹出结算
            local function callback()
                EventManager.Hit(EventId.OpenPanel, PanelId.RoguelikeResult,2,UTILS.DecodeChangeInfo(mapMsgData.Change),self:GetStrengthInfo(),mapMsgData.Build, ncurFloor,totalFloor,nPerkCount)
            end
            TimerManager.Add(1, 2, self, callback, true, true, true, nil)
        else
            EventManager.Hit(EventId.OpenPanel, PanelId.RoguelikeResult,3,UTILS.DecodeChangeInfo(mapMsgData.Change),self:GetStrengthInfo(),mapMsgData.Build,ncurFloor,totalFloor,nPerkCount)
        end
    else
        local nChangedEnergy = 0
        local mapDecodedInfo = {}
        if mapMsgData.Change ~= nil then
            mapDecodedInfo = UTILS.DecodeChangeInfo(mapMsgData.Change)
        end 
        if mapDecodedInfo["proto.Energy"] ~= nil then
            local finalValue = mapDecodedInfo["proto.Energy"][1].Primary
            local curValue = PlayerData.Base:GetCurEnergy()
            nChangedEnergy = finalValue - curValue.nEnergy
        end
        EventManager.Hit(EventId.OpenPanel, PanelId.RoguelikeResult,3,mapDecodedInfo,nChangedEnergy,mapMsgData.Build,ncurFloor,totalFloor,nPerkCount)
    end
end
function PlayerRoguelikeData.GetActorHp()
    local logStr = ""
    local tbActorEntity = AdventureModuleHelper.GetCurrentGroupPlayers()
    local mapCurCharInfo = {}
    local count = tbActorEntity.Count - 1
    for i = 0, count do
        local nCharId = AdventureModuleHelper.GetCharacterId(tbActorEntity[i])
        local hp = AdventureModuleHelper.GetEntityHp(tbActorEntity[i])
        mapCurCharInfo[nCharId] = hp
        logStr = logStr .. string.format("EntityID:%d\t角色Id：%d\t角色血量：%d\n",tbActorEntity[i],nCharId,hp)
    end
    print(logStr)
    return mapCurCharInfo
end
function PlayerRoguelikeData:GetFirstFloorId(nRoguelikeId)
    local tbAllFloor = CacheTable.GetData("_RoguelikeFloor", nRoguelikeId)
    if tbAllFloor ~= nil then
        return tbAllFloor[1].Id
    end
    return 0
end
function PlayerRoguelikeData:InitRoguelikeBag()
    self._mapRoguelikeBag = {}
end
function PlayerRoguelikeData:ProcessChestData(tbRandom,tbConstant)--处理宝箱数据
    local retRandom = {}
    local retContent = {}
    local tbLua2CSharp_ChestInfo = {}
    for type, randomChest in ipairs(tbRandom) do
        for _, chest in ipairs(randomChest.Chests) do
            if retRandom[type] == nil then
                retRandom[type] = {}
            end
            retRandom[type][chest.Idx] = chest
            local stChestInfo = CS.Lua2CSharpInfo_RoguelikeChestInfo(chest.Idx,chest.Tid,true,type - 1)
            table.insert(tbLua2CSharp_ChestInfo, stChestInfo)
        end
    end
    for type, constantChest in ipairs(tbConstant) do
        for _, chest in ipairs(constantChest.Chests) do
            if retContent[type] == nil then
                retContent[type] = {}
            end
            retContent[type][chest.Idx] = chest
            local stChestInfo = CS.Lua2CSharpInfo_RoguelikeChestInfo(chest.Idx,chest.Tid,false,type - 1)
            table.insert(tbLua2CSharp_ChestInfo, stChestInfo)
        end
    end
    self.nsmallBoxTotalCount = #(tbRandom[1].Chests) + #(tbConstant[1].Chests)
    self.nmediumBoxTotalCount = #(tbRandom[2].Chests) + #(tbConstant[2].Chests)
    return retRandom,retContent,tbLua2CSharp_ChestInfo
end
function PlayerRoguelikeData:GetStrengthInfo()
    local nTotalEnergy = 0
    for _, mapFloor in pairs(CacheTable.GetData("_RoguelikeFloor", self.curRoguelikeId) or {}) do
        nTotalEnergy = nTotalEnergy + mapFloor.NeedEnergy
    end
    local ret = nTotalEnergy - self._nCurEnergy
    if ret < 0 then
        ret = 0
    end
    return ret
end
function PlayerRoguelikeData:PrePorcessFloorData()
    local function foreach_Roguelike(mapRoguelikeFloorData)
        CacheTable.SetField("_RoguelikeFloor", mapRoguelikeFloorData.RoguelikeId, mapRoguelikeFloorData.Floor, mapRoguelikeFloorData)
    end
    ForEachTableLine(DataTable.RoguelikeFloor,foreach_Roguelike)

    local function foreach_Rogue(mapRoguelikeData)
        if self._Roguelike[mapRoguelikeData.GroupId] == nil then
            self._Roguelike[mapRoguelikeData.GroupId] = {}
            -- _indexId = 0
        end
        -- _indexId = _indexId + 1        
        self._Roguelike[mapRoguelikeData.GroupId][mapRoguelikeData.Difficulty] = mapRoguelikeData
    end
    if self._Roguelike == nil then
        self._Roguelike = {}
    end
    ForEachTableLine(DataTable.Roguelike,foreach_Rogue)
end
function PlayerRoguelikeData:RoguelikeClear(mapData)
    local mapDecodedInfo = {}
    if mapData.Change ~= nil then
        mapDecodedInfo = UTILS.DecodeChangeInfo(mapData.Change)
    end
    local tbBonus = self:CalBonusPerk(mapData.PerkIds)
    local ncurFloor,totalFloor = self:GetFloorInfo()
    local nPerkCount = self:CalPerkPerkCount()
    EventManager.Hit(EventId.OpenPanel, PanelId.RoguelikeResult,1,mapDecodedInfo,0,mapData.Build,ncurFloor,totalFloor,nPerkCount,tbBonus)
end
function PlayerRoguelikeData:CalBonusPerk(tbPerkIds)
    if tbPerkIds ~= nil then
        local ret = {}
        local mapBonus = {}
        for _, nPerkId in ipairs(tbPerkIds) do
            local mapPerk = ConfigTable.GetData_Perk(nPerkId)
            local bagPerks = self._mapRoguelikeBag[GameEnum.itemStype.RoguelikePerk]
            if mapBonus[nPerkId] == nil then
                if bagPerks == nil or bagPerks[nPerkId] == nil then
                    mapBonus[nPerkId] = {
                        nTid = nPerkId,
                        nStar = 0,
                        bNew = true,
                        nNewStar = 0,
                        bOverLimit = false
                    }
                else
                    if bagPerks[nPerkId] >= mapPerk.MaxLevel then
                        table.insert(ret,{
                            nTid = nPerkId,
                            nStar = 0,
                            bNew = false,
                            nNewStar = 0,
                            bOverLimit = true
                        })
                    else
                        mapBonus[nPerkId] = {
                            nTid = nPerkId,
                            nStar = bagPerks[nPerkId] - 1,
                            bNew = false,
                            nNewStar = 1,
                            bOverLimit = false
                        }
                    end
                end
            else
                if mapBonus[nPerkId].nStar +mapBonus[nPerkId].nNewStar >= mapPerk.MaxLevel - 1 then
                    table.insert(ret,{
                        nTid = nPerkId,
                        nStar = 0,
                        bNew = false,
                        nNewStar = 0,
                        bOverLimit = true
                    })

                else
                    mapBonus[nPerkId].nNewStar =  mapBonus[nPerkId].nNewStar + 1
                end
            end
        end
        for _, bonus in pairs(mapBonus) do
            table.insert(ret,bonus)
        end
        return ret
    end
    return nil
end
function PlayerRoguelikeData:CalPerkPerkCount()
    local bagPerks = self._mapRoguelikeBag[GameEnum.itemStype.RoguelikePerk]
    local ret = 0
    if bagPerks == nil then 
        return 0
    end
    for nTid, count in pairs(bagPerks) do
        local mapPerkConfigData = ConfigTable.GetData_Perk(nTid)
        if mapPerkConfigData ~= nil and mapPerkConfigData.PerkType ~= GameEnum.perkType.Tactics then
            ret = ret + count
        end
    end
    return ret
end
function PlayerRoguelikeData:RoguelikeStart()
    NovaAPI.EnterModule("AdventureModuleScene", true,17)
end
--过层或选择天赋出错时直接退出遗迹
function PlayerRoguelikeData:NetError()
    self:OnEvent_AbandonRoguelike(true)
end

----------------------------------------------- process function --------------------------------------
function PlayerRoguelikeData:SendSettleReq()
    local nNextFloorMapId,nNextFloorBossId = self:GetNextFloorInfo()
    if nNextFloorBossId > 0 then
        self.nextFloorProcess = self._proc_bossFloor
    else
        self.nextFloorProcess = self._proc_normalFloor
    end
    local tbTeamCharInfo = {}
    local nCaptainIndex,tbTeamMemberId=PlayerData.Team:GetTeamData(5)
    local mapCurCharInfo = self.GetActorHp()
    local mapCaptainInfo = {nId = tbTeamMemberId[nCaptainIndex],nHp = mapCurCharInfo[tbTeamMemberId[nCaptainIndex]]}
    table.insert(tbTeamCharInfo, mapCaptainInfo)
    for i = 1, #tbTeamMemberId do
        if i ~= nCaptainIndex then
            local nActorHp = mapCurCharInfo[tbTeamMemberId[i]]
            local mapActorInfo = {nId = tbTeamMemberId[i],nHp = nActorHp}
            table.insert(tbTeamCharInfo, mapActorInfo)
        end
    end
    local tbRoguelikeChar = {}
    for index = 1, #tbTeamCharInfo do
        local RoguelikeChar = {}
        RoguelikeChar.Tid = tbTeamCharInfo[index].nId
        RoguelikeChar.CurHp =  tbTeamCharInfo[index].nHp
        RoguelikeChar.Equips = {}
        self.mapCurCharInfo[RoguelikeChar.Tid] = RoguelikeChar.CurHp
        table.insert(tbRoguelikeChar,RoguelikeChar)
    end

    local msg = {}
    msg.MapId = nNextFloorMapId
    msg.BossId = nNextFloorBossId
    msg.KillOrdMstNum = self.nNormalMonsterCount
    msg.KillEltMstNum = self.nEliteMonsterCount
    msg.Chars = tbRoguelikeChar
    msg.ChestsFlag = self.tbOpenedChest
    msg.SelectedPerks = self.tbGetPerks
    msg.Records = self:CacheRoguelikeTempData()
    CS.AdventureModuleHelper.PauseLogic()
    print(serpent.block(msg))
    HttpNetHandler.SendMsg(NetMsgId.Id.roguelike_floor_settle_req, msg, nil, nil)
end
function PlayerRoguelikeData:SettleCallback(mapData)
    self.bKillBoss = false   
    self.nNormalMonsterCount = 0
    self.nEliteMonsterCount = 0
    self.nLordCount = 0
    self.tbOpenedChest = {}
    self.tbGetPerks = {}
    if mapData.NextFloor == nil then --通关 弹结算
        print("遗迹最终层结算结束")
        self:UpdatePassedId(self.curRoguelikeId)
        print("记录通过id")
        self:RoguelikeClear(mapData)
        print("弹出结算窗口")
        return
    end
    self._nPlayerCurFloor = self._nPlayerCurFloor + 1
    if type(self.curFloorProcess["SettleCallback"]) == "function" then
        self.curFloorProcess:SettleCallback(self)
    else
        printError("当前流程无对应处理方法：".. "SettleCallback")
    end
end
function PlayerRoguelikeData:SetCharTalent()
    local nCaptainIndex,tbTeamMemberId=PlayerData.Team:GetTeamData(5)
    local tbstInfo = {}
    for index = 1, #tbTeamMemberId do
        local nBranchId = PlayerData.Char:GetCharBranchId(tbTeamMemberId[index])
        local stTalentInfo = CS.Lua2CSharpInfo_ActorTalent()
        local nRank = PlayerData.Char:GetCharLv(tbTeamMemberId[index])
        stTalentInfo.actorID = tbTeamMemberId[index]
        stTalentInfo.talentID = nBranchId
        stTalentInfo.rank = nRank
        -- stTalentInfo.talentNodes = nil
        table.insert(tbstInfo, stTalentInfo)
    end
    safe_call_cs_func(CS.AdventureModuleHelper.SetCurrentActor,tbstInfo)
end
function PlayerRoguelikeData:SetActorEffects()
    local nCaptainIndex,tbTeamMemberId=PlayerData.Team:GetTeamData(5)
    for index = 1, #tbTeamMemberId do
        local tbstInfo = {}
        local tbEffectId = {}
        PlayerData.Char:CalcTalentEffect(tbTeamMemberId[index],tbstInfo,tbEffectId)
        for _, stInfo in ipairs(tbstInfo) do
            for eftId, tbValue in pairs(stInfo.effectIds) do
                local mapEffect = ConfigTable.GetData_Effect(eftId)
                if mapEffect ~= nil then
                    local useCount = -1
                    if mapEffect.TakeEffectLimit > 0 then
                        if self.mapEffectTriggerCount[eftId] ~= nil then
                            useCount = mapEffect.TakeEffectLimit - self.mapEffectTriggerCount[eftId]
                            useCount = math.max(useCount,0)
                        end
                    end
                    if useCount ~= 0 then
                        tbValue[1] = useCount
                    else
                        stInfo.effectIds[eftId] = nil
                    end
                end
            end
        end
        --safe_call_cs_func(CS.AdventureModuleHelper.SetActorInherentEffects,tbstInfo)
    end
end
function PlayerRoguelikeData:AddPerkEffect(nTid,nAddCount)
    local tbPerkInfos = {}
    local nCountAfter = 1
    if nAddCount == nil then
        nAddCount = 1
    end
    if self._mapRoguelikeBag[GameEnum.itemStype.RoguelikePerk] ~= nil and self._mapRoguelikeBag[GameEnum.itemStype.RoguelikePerk][nTid] ~= nil then
        nCountAfter = self._mapRoguelikeBag[GameEnum.itemStype.RoguelikePerk][nTid] + nAddCount
        if nCountAfter > 3 then
            nCountAfter = 3
        end
        local nCount = self._mapRoguelikeBag[GameEnum.itemStype.RoguelikePerk][nTid]
        local nSkillIdBefore = ConfigTable.GetData_Perk(nTid).EffectGroupId * 100 + nCount
        local mapSkillBefore  = ConfigTable.GetData("PerkPassiveSkill", nSkillIdBefore)
        if mapSkillBefore ~= nil then
            local stPerkEffectInfo = CS.Lua2CSharpInfo_ActorPerkEffect()
            stPerkEffectInfo.isAdd = false
            stPerkEffectInfo.perkId = nTid
            stPerkEffectInfo.shareCD = mapSkillBefore.ShareCD
            local mapBeforeEffectIds = {}
            for i = 1,4 do 
                local effectId = mapSkillBefore["EffectId"..i]
                if effectId >0 then
                    mapBeforeEffectIds[effectId] = -1
                end
            end
            stPerkEffectInfo.effectInfo = mapBeforeEffectIds
            table.insert(tbPerkInfos, stPerkEffectInfo)
        end
    else
        nCountAfter = nAddCount
        if nCountAfter > 3 then
            nCountAfter = 3
        end
    end
    local nSkillIdAfter = ConfigTable.GetData_Perk(nTid).EffectGroupId * 100 + nCountAfter
    local mapSkillAfter  = ConfigTable.GetData("PerkPassiveSkill", nSkillIdAfter)
    if mapSkillAfter == nil then
        return
    end
    local stPerkEffectInfoAfter = CS.Lua2CSharpInfo_ActorPerkEffect()
    stPerkEffectInfoAfter.isAdd = true
    stPerkEffectInfoAfter.perkId = nTid
    stPerkEffectInfoAfter.shareCD = mapSkillAfter.ShareCD
    local mapAfterEffectIds = {}
    for i = 1,4 do 
        local effectId = mapSkillAfter["EffectId"..i]
        if effectId >0 then
            local mapEffect = ConfigTable.GetData_Effect(effectId)
            local useCount = -1
            if mapEffect.TakeEffectLimit > 0 then
                if self.mapEffectTriggerCount[effectId] ~= nil then
                    useCount = mapEffect.TakeEffectLimit - self.mapEffectTriggerCount[effectId]
                    useCount = math.max(useCount,0)
                end
            end
            if useCount ~= 0 then
                mapAfterEffectIds[effectId] = useCount
            end
        end
    end
    stPerkEffectInfoAfter.effectInfo = mapAfterEffectIds
    table.insert(tbPerkInfos, stPerkEffectInfoAfter)

    --safe_call_cs_func(CS.AdventureModuleHelper.ChangePerkEffect,tbPerkInfos)
end
function PlayerRoguelikeData:ResetPerkEffect()
    local tbPerkInfos = {}
    if self._mapRoguelikeBag[GameEnum.itemStype.RoguelikePerk] == nil then
        return
    end
    for nTid,nCount in pairs(self._mapRoguelikeBag[GameEnum.itemStype.RoguelikePerk]) do
        local nMaxLevel = ConfigTable.GetData_Perk(nTid).MaxLevel
        local nLevel = nCount
        if nLevel > nMaxLevel then
            nLevel = nMaxLevel
        end
        local nSkillId = ConfigTable.GetData_Perk(nTid).EffectGroupId * 100 + nLevel
        local mapSkill  = ConfigTable.GetData("PerkPassiveSkill", nSkillId)
        local stPerkEffectInfo = CS.Lua2CSharpInfo_ActorPerkEffect()
        stPerkEffectInfo.isAdd = true
        stPerkEffectInfo.perkId = nTid
        stPerkEffectInfo.shareCD = mapSkill.ShareCD
        local mapEffectIds = {}
        for i = 1,4 do 
            local effectId = mapSkill["EffectId"..i]
            if effectId >0 then
                local mapEffect = ConfigTable.GetData_Effect(effectId)
                local useCount = -1
                if mapEffect.TakeEffectLimit > 0 then
                    if self.mapEffectTriggerCount[effectId] ~= nil then
                        useCount = mapEffect.TakeEffectLimit - self.mapEffectTriggerCount[effectId]
                        useCount = math.max(useCount,0)
                    end
                end
                if useCount ~= 0 then
                    mapEffectIds[effectId] = useCount
                end
            end
        end
        stPerkEffectInfo.effectIds = mapEffectIds
        table.insert(tbPerkInfos, stPerkEffectInfo)
    end
    --safe_call_cs_func(CS.AdventureModuleHelper.ChangePerkEffect,tbPerkInfos)
end
function PlayerRoguelikeData:SetActorAttribute(bStart)
    local tbActorInfo = {}
    if self._mapStartAttribute == nil then
        return
    end
    for index = 1, #self._mapStartAttribute do
        local stCharInfo = CS.Lua2CSharpInfo_ActorAttribute()
        stCharInfo.actorID = self._mapStartAttribute[index].Tid
        if bStart then --如果是第一层用原始血量
            stCharInfo.curHP = -1
        else
            stCharInfo.curHP = self._mapStartAttribute[index].CurHp
        end
        table.insert(tbActorInfo, stCharInfo)
    end
    safe_call_cs_func(CS.AdventureModuleHelper.ResetActorAttributes,tbActorInfo)
end
function PlayerRoguelikeData:SetActorAttributeFloor()
    local tbActorInfo = {}
    if self.mapCurCharInfo == nil then
        return
    end
    if self.mapCurCharInfo.charInfo == nil then
        return
    end
    for nTid, nHp in pairs(self.mapCurCharInfo.charInfo) do
        local stCharInfo = CS.Lua2CSharpInfo_ActorAttribute()
        stCharInfo.actorID = nTid
        stCharInfo.curHP = nHp
        table.insert(tbActorInfo, stCharInfo)
    end
    safe_call_cs_func(CS.AdventureModuleHelper.ResetActorAttributes,tbActorInfo)
end
function PlayerRoguelikeData:AbandonRoguelike(bFailed)
    local sendMsg = {}
    sendMsg.KillOrdMstNum = self.nNormalMonsterCount
    sendMsg.KillEltMstNum = self.nEliteMonsterCount
    sendMsg.ChestsFlag = self.tbOpenedChest
    sendMsg.SelectedPerks = self.tbGetPerks
    HttpNetHandler.SendMsg(NetMsgId.Id.roguelike_give_up_req, sendMsg, nil, nil)
end
function PlayerRoguelikeData:FloorEnd()
    if self.nextFloorProcess ~= nil then
        self.curFloorProcess = self.nextFloorProcess
        self.curFloorProcess:Init()
    else
        printError("下层处理流程未设置")
    end
    safe_call_cs_func(AdventureModuleHelper.LevelStateChanged,false)
    self.nmediumBoxCount = 0
    self.nsmallBoxCount = 0
    self:ResetBoxCount()
    if self.curFloorProcess ~= self._proc_bossFloor then 
        PlayerRoguelikeData._nCurEnergy = PlayerRoguelikeData._nCurEnergy + ConfigTable.GetData("RoguelikeFloor", PlayerRoguelikeData._nFloorId).NeedEnergy
    end
end
function PlayerRoguelikeData:FloorEndEditor()
    EventManager.Hit(EventId.OpenPanel, PanelId.RoguelikeResult,1,{},0,0,0,0)
end
function PlayerRoguelikeData:SyncKillBoss()
    local msg = {}
    msg.ChestsFlag = self.tbOpenedChest
    msg.SelectedPerks = self.tbGetPerks
    local function callback()
        self.tbOpenedChest = {}
        self.tbGetPerks = {}
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.roguelike_state_sync_req, msg, nil, callback)
end
function PlayerRoguelikeData:ResetBoxCount()
    EventManager.Hit("RefreshBoxCount",1,self.nsmallBoxTotalCount,0)
    EventManager.Hit("RefreshBoxCount",2,self.nmediumBoxTotalCount,0)
end
function PlayerRoguelikeData:CacheCharAttr()
    local id = AdventureModuleHelper.GetCurrentActivePlayer()
    self.mapCurCharInfo = {curChar = AdventureModuleHelper.GetCharacterId(id),charInfo = {}}
    local mapCharAttr = self.GetActorHp()
    local nCaptainIndex,tbTeamMemberId=PlayerData.Team:GetTeamData(5)
    for i = 1, #tbTeamMemberId do
        self.mapCurCharInfo.charInfo[tbTeamMemberId[i]] = mapCharAttr[tbTeamMemberId[i]]
    end
end
function PlayerRoguelikeData:ReenterSetCurrentCharByLocal()

end
function PlayerRoguelikeData:ReenterSetCurrentCharByServer(records)

end
----------------------------------------------- 通用接口-----------------------------------------------
function PlayerRoguelikeData:Init()
    self.sLocalRoguelikeDataKey = "RoguelikeData"
    self.sLocalRoguelikeTempDataKey = "RoguelikeTempData"
    self._Roguelike = {}

    -- EventManager.Add(EventId.SendMsgEnterRoguelike, self, self.SendEnterRoguelikeReq) -- Lua 侧界面按钮触发
    -- EventManager.Add(EventId.EnterRoguelike, self, self.OnEvent_OnRoguelikeEnter) -- 当进入roguelike关卡(c#侧模块场景切换流程AfterEnterModule时触发)
    -- EventManager.Add("LevelStateChanged", self, self.OnEvent_LevelStateChanged) --当接触传送点时
    -- EventManager.Add("ADVENTURE_BATTLE_MONSTER_DIED", self, self.OnEvent_MonsterDied) -- 怪物死亡消息
    -- EventManager.Add("InteractiveBoxGet", self, self.OnEvent_OpenChest) -- 战斗中开启宝箱
    -- EventManager.Add(EventId.AbandonRoguelike, self, self.OnEvent_AbandonRoguelike) --当放弃遗迹探索时
    -- EventManager.Add("LoadLevelRefresh", self, self.OnEvent_LoadLevelRefresh) -- 进入关卡
    -- EventManager.Add("LoadLevelRefresh", self, self.OnEvent_LoadLevelRefresh) -- 成功过层，刷新角色和界面数据
    -- EventManager.Add(EventId.SelectPerk, self, self.OnEvent_SelectPerk) -- 选择秘宝
    -- EventManager.Add("RoguelikeSkip", self, self.GM_Skip) -- 选择秘宝

    self._tbRglPassedIds = {} --已经通关的遗迹ID列表

    self._mapRoguelikeDrop = { mapOrdMstDrop = {}, mapEltMstDrop = {},  mapBossDrop = {} }
    self._mapRoguelikeHistoryMapId = {nLevelId = 0, tbMapId = {0, 0, 0}}
    self._mapRoguelikeFloorClearReward = nil --遗迹通关奖励
    self._mapStartAttribute = nil
    self._tbRoguelikeEquip = nil --以及装备（暂时不需要）
    self._mapRoguelikeBag = {} --遗迹背包
    self._SupplyDrop = nil
    self._mapRandomChest = {} --随机宝箱掉落数据
    self._mapConstentChest = {} --固定宝箱掉落数据
    self._nFloorId = 0 --当前层Id
    self.curRoguelikeId = 0 --当前遗迹Id
    self._nCurEnergy = 0 --当前层已经消耗的体力
    self._nPlayerCurFloor = 0 --玩家角色当前处在的层数（在boss关卡会与数据层数不同）

    self.bKillBoss = false       --是否已击杀boss
    self.nNormalMonsterCount = 0 --杀死的普通怪物数量
    self.nEliteMonsterCount = 0 --杀死的精英怪物数量
    self.nLordCount = 0 --杀死的Boss怪物数量
    self.nsmallBoxCount = 0
    self.nsmallBoxTotalCount = 0
    self.nmediumBoxCount = 0
    self.nmediumBoxTotalCount = 0
    self.tbOpenedChest = {} -- 开启的宝箱flag（int64 按位标记）
    self.mapCurCharInfo = {} --用于在过层时保存角色血量
    self.tbGetPerks = {} -- 获取的秘宝
    self.mapEffectTriggerCount = {} --用于记录某些限制使用次数的效果的生效次数

    self.nextFloorProcess = nil
    self.curFloorProcess = nil

    --local pbSchema = LuaManager.Instance:LoadBytes("Game/Adventure/RoguelikeFloor/roguelike_tempData.pb")
    --assert(PB.load(pbSchema))

    self:PrePorcessFloorData()
    self:LoadRoguelikeProcess()
end
function PlayerRoguelikeData:SendEnterRoguelikeReq(nRoguelikeId)
    self.bKillBoss = false   
    self.nNormalMonsterCount = 0
    self.nEliteMonsterCount = 0
    self.nsmallBoxCount = 0
    self.nsmallBoxTotalCount = 0
    self.nmediumBoxCount = 0
    self.nmediumBoxTotalCount = 0
    self.tbOpenedChest = {}
    self.tbGetPerks = {}
    self._nPlayerCurFloor = 1
    self.bNoNetwork = false
    self._bStart = true
    self.curRoguelikeId = nRoguelikeId
    local nFloorId = CacheTable.GetData("_RoguelikeFloor", nRoguelikeId)[1].Id
    local arrMapId = {0,0,0}
    local tbTeamCharInfo = {}
    self:InitRoguelikeBag()
    self:ClearRoguelikeTempData()
    local nCaptainIndex,tbTeamMemberId=PlayerData.Team:GetTeamData(5)
    local mapCaptainInfo = {nId = tbTeamMemberId[nCaptainIndex],nHp = -1}
    table.insert(tbTeamCharInfo, mapCaptainInfo)
    for i = 1, #tbTeamMemberId do
        if i ~= nCaptainIndex then
            local mapActorInfo = {nId = tbTeamMemberId[i],nHp = -1}
            table.insert(tbTeamCharInfo, mapActorInfo)
        end
    end
    local tbActorInfo = {}
    for index = 1, #tbTeamCharInfo do
        local stCharInfo = CS.ActorInfo_Roguelike(tbTeamCharInfo[index].nId,tbTeamCharInfo[index].nHp)
        table.insert(tbActorInfo, stCharInfo)
    end
    local nDifficult = ConfigTable.GetData("Roguelike", nRoguelikeId).Difficulty
    local stRoguelikeInfo = CS.Lua2CSharpInfo_Roguelike(nRoguelikeId,nDifficult,0,nFloorId,tbActorInfo,arrMapId,false,false)
    local nMapId, nBossId = safe_call_cs_func2(CS.AdventureModuleHelper.RandomRoguelikeMapId,stRoguelikeInfo)
    self._bIsBossFloor = nBossId ~= 0
    self._bSettleEnd = false
    self:SetRoguelikeHistoryMapId(self.curRoguelikeId, nMapId)
    local msg = {}
    msg.RoguelikeId = nRoguelikeId
    msg.MapId = nMapId
    msg.BossId = nBossId
    msg.FormationId = 5
    msg.Rehearsal = false
    HttpNetHandler.SendMsg(NetMsgId.Id.roguelike_enter_req, msg, nil, nil)
end
function PlayerRoguelikeData:EnterRoguelikeEditor(nRoguelikeId,nConfigFloorId)
    self.curRoguelikeId = nRoguelikeId
    self._nFloorId = CacheTable.GetData("_RoguelikeFloor", nRoguelikeId)[nConfigFloorId].Id
    PlayerData.nCurGameType = AllEnum.WorldMapNodeType.Roguelike
    local arrMapId = {0,0,0}
    local tbTeamCharInfo = {}
    self:InitRoguelikeBag()
    local nCaptainIndex,tbTeamMemberId=PlayerData.Team:GetTeamData(5)
    for _, sId in pairs(tbTeamMemberId) do
        if sId == 0 then
            EventManager.Hit(EventId.OpenMessageBox, {nType = AllEnum.MessageBox.Alert, sContent = ConfigTable.GetUIText("FixedRogueData_FormationError")})
            return
        end
    end
    local mapCaptainInfo = {nId = tbTeamMemberId[nCaptainIndex],nHp = -1}
    table.insert(tbTeamCharInfo, mapCaptainInfo)
    for i = 1, #tbTeamMemberId do
        if i ~= nCaptainIndex then
            local mapActorInfo = {nId = tbTeamMemberId[i],nHp = -1}
            table.insert(tbTeamCharInfo, mapActorInfo)
        end
    end
    local tbActorInfo = {}
    for index = 1, #tbTeamCharInfo do
        local stCharInfo = CS.ActorInfo_Roguelike(tbTeamCharInfo[index].nId,tbTeamCharInfo[index].nHp)
        table.insert(tbActorInfo, stCharInfo)
    end
    local nDifficult = ConfigTable.GetData("Roguelike", nRoguelikeId).Difficulty
    local stRoguelikeInfo = CS.Lua2CSharpInfo_Roguelike(nRoguelikeId,nDifficult,0,self._nFloorId,tbActorInfo,arrMapId,false,false)
    local nMapId, nBossId = safe_call_cs_func2(CS.AdventureModuleHelper.RandomRoguelikeMapId,stRoguelikeInfo)
    self:LoadRoguelikeProcessEditor()
    self.curFloorProcess = self._proc_Editor
    self.curFloorProcess:Init()
    self:SetCharTalent()
    NovaAPI.EnterModule("AdventureModuleScene", true,17)
end
function PlayerRoguelikeData:GetFloorInfo()
    local nTotalFloor = #CacheTable.GetData("_RoguelikeFloor", self.curRoguelikeId)
    return self._nPlayerCurFloor,nTotalFloor
end
function PlayerRoguelikeData:GetRoguelikeBag()
    return self._mapRoguelikeBag
end
function PlayerRoguelikeData:GetCurRoguelikeId()
    return self.curRoguelikeId
end
function PlayerRoguelikeData:IsLastFloor(nRoguelikeId,nFloorId)
    local nTotalFloor = #CacheTable.GetData("_RoguelikeFloor", self.curRoguelikeId)
    local mapCurRoguelike = CacheTable.GetData("_RoguelikeFloor", nRoguelikeId)
    if mapCurRoguelike == nil then
        return false
    end
    local mapCurFloor = ConfigTable.GetData("RoguelikeFloor", nFloorId)
    if mapCurFloor ~= nil then
        return mapCurFloor.Floor == nTotalFloor
    end
    return false
end
--------------------------------------------- 本地数据--------------------------------------------------
function PlayerRoguelikeData:GetClientLocalRoguelikeData()
    local LocalData = require "GameCore.Data.LocalData"
    local sJsonRoguelikeData = LocalData.GetPlayerLocalData(self.sLocalRoguelikeDataKey)
    if type(sJsonRoguelikeData) == "string" and sJsonRoguelikeData ~= "" then
        self._mapRoguelikeHistoryMapId = RapidJson.decode(sJsonRoguelikeData)
    else
        self:SetClientLocalRoguelikeData()
    end
end
function PlayerRoguelikeData:SetClientLocalRoguelikeData()
    local sJsonRoguelikeData = RapidJson.encode(self._mapRoguelikeHistoryMapId)
    if type(sJsonRoguelikeData) == "string" and sJsonRoguelikeData ~= "" then
        local LocalData = require "GameCore.Data.LocalData"
        LocalData.SetPlayerLocalData(self.sLocalRoguelikeDataKey, sJsonRoguelikeData)
    end
end
function PlayerRoguelikeData:GetRoguelikeHistoryMapId(nLevelId)
    if nLevelId ~= self._mapRoguelikeHistoryMapId.nLevelId then
        -- 历史纪录的MapId无效，若发送 roguelike_floor_enter_req 返回成功，则需重写历史纪录。
        return {0, 0, 0}
    else
        -- 所选随机关卡的 LevelId 相同，返回历史记录的 MapId 长度3。
        return self._mapRoguelikeHistoryMapId.tbMapId
    end
end
function PlayerRoguelikeData:SetRoguelikeHistoryMapId(nLevelId, nMapId)
    if nLevelId ~= self._mapRoguelikeHistoryMapId.nLevelId then
        self._mapRoguelikeHistoryMapId.nLevelId = nLevelId
        self._mapRoguelikeHistoryMapId.tbMapId = {nMapId, 0, 0}
    else
        local bMarked = false
        for nIdx, nMarkedMapId in ipairs(self._mapRoguelikeHistoryMapId.tbMapId) do
            if nMarkedMapId == 0 then
                bMarked = true
                self._mapRoguelikeHistoryMapId.tbMapId[nIdx] = nMapId
                break
            end
        end
        if bMarked == false then
            table.remove(self._mapRoguelikeHistoryMapId.tbMapId, 1)
            table.insert(self._mapRoguelikeHistoryMapId.tbMapId, nMapId)
        end
    end
    self:SetClientLocalRoguelikeData()
end
function PlayerRoguelikeData:SetRoguelikeTempData(mapData)
    local LocalData = require "GameCore.Data.LocalData"
    local sJsonRoguelikeData = RapidJson.encode(mapData)
    LocalData.SetPlayerLocalData(self.sLocalRoguelikeTempDataKey, sJsonRoguelikeData)
end
function PlayerRoguelikeData:GetRoguelikeTempData()
    local LocalData = require "GameCore.Data.LocalData"
    local sData = LocalData.GetPlayerLocalData(self.sLocalRoguelikeTempDataKey)
    local mapData = decodeJson(sData)
    return mapData
end
function PlayerRoguelikeData:ClearRoguelikeTempData()
    local LocalData = require "GameCore.Data.LocalData"
    local sJsonRoguelikeData = RapidJson.encode({})
    LocalData.SetPlayerLocalData(self.sLocalRoguelikeTempDataKey, sJsonRoguelikeData)
end
function PlayerRoguelikeData:CacheRoguelikeTempData()
    local mapData = {}
    local id = AdventureModuleHelper.GetCurrentActivePlayer()
    mapData.curCharId = AdventureModuleHelper.GetCharacterId(id)
    mapData.skillInfo = {}
    mapData.effectInfo = {}
    local playerids = AdventureModuleHelper.GetCurrentGroupPlayers()
    local Count = playerids.Count - 1
    for i = 0, Count do
        local skillId = AdventureModuleHelper.GetCurrentActorBindSkillId(playerids[i], 1)
        local cd = AdventureModuleHelper.GetActorSkillCD(playerids[i], skillId)
        local energy = AdventureModuleHelper.GetActorSkillEnergy(playerids[i], skillId)
        table.insert(mapData.skillInfo, 1, {skillId = skillId,cd = cd,energy = energy})
        skillId = AdventureModuleHelper.GetCurrentActorBindSkillId(playerids[i], 2)
        cd = AdventureModuleHelper.GetActorSkillCD(playerids[i], skillId)
        energy = AdventureModuleHelper.GetActorSkillEnergy(playerids[i], skillId)
        table.insert(mapData.skillInfo, 1, {skillId = skillId,cd = cd,energy = energy})
        skillId = AdventureModuleHelper.GetCurrentActorBindSkillId(playerids[i], 3)
        cd = AdventureModuleHelper.GetActorSkillCD(playerids[i], skillId)
        energy = AdventureModuleHelper.GetActorSkillEnergy(playerids[i], skillId)
        table.insert(mapData.skillInfo, 1, {skillId = skillId,cd = cd,energy = energy})
        skillId = AdventureModuleHelper.GetCurrentActorBindSkillId(playerids[i], 4)
        cd = AdventureModuleHelper.GetActorSkillCD(playerids[i], skillId)
        energy = AdventureModuleHelper.GetActorSkillEnergy(playerids[i], skillId)
        table.insert(mapData.skillInfo, 1, {skillId = skillId,cd = cd,energy = energy})
    end
    for effectId, nCount in pairs(self.mapEffectTriggerCount) do
        table.insert(mapData.effectInfo,{effectId = effectId,count = nCount})
    end
    local msgName = "nova.client.roguelike.tempData"
    local data = assert(PB.encode(msgName, mapData))
    print(type(data))

    self:SetRoguelikeTempData(mapData)

    return data
end
function PlayerRoguelikeData:AddToRoguelikeBag(nTid,nCount)
    if ConfigTable.GetData_Item(nTid) == nil then
        print("无对应tid数据：".. nTid)
        return 
    end
    local nType = ConfigTable.GetData_Item(nTid).Stype

    if self._mapRoguelikeBag[nType] == nil then
        self._mapRoguelikeBag[nType] = {}
    end
    if self._mapRoguelikeBag[nType][nTid] == nil then
        self._mapRoguelikeBag[nType][nTid] = 0
    end
    self._mapRoguelikeBag[nType][nTid] = nCount+self._mapRoguelikeBag[nType][nTid]
end
--------------------------------------------- 保存服务器数据--------------------------------------------
function PlayerRoguelikeData:CacheNextFloorData(mapData)
    if mapData.NextFloor == nil then
        return
    end
    local tbOrdMstDrop = mapData.NextFloor.OrdMstDrops
    local tbEltMstDrop = mapData.NextFloor.EltMstDrops
    local mapBossDrop = mapData.NextFloor.BossDrops
    self._nFloorId = mapData.NextFloor.FloorID
    self._SupplyDrop = mapData.SupplyDrop
    local tbChestInfo
    self._mapRandomChest,self._mapConstentChest, tbChestInfo = self:ProcessChestData(mapData.NextFloor.RandomChests, mapData.NextFloor.ConstantChests)
    safe_call_cs_func(CS.AdventureModuleHelper.SetRoguelikeChestData,tbChestInfo)
    self._mapRoguelikeDrop.mapOrdMstDrop = {}
    if type(tbOrdMstDrop) == "table" then
        for _, v in ipairs(tbOrdMstDrop) do
            local tbItemInfo = {}
            if v.DropPkgs then
                for __, vv in ipairs(v.DropPkgs) do
                    for ___, vvv in ipairs(vv.Drops) do
                        table.insert(tbItemInfo, {nItemId = vvv.Tid, nItemCount = vvv.Qty})
                    end
                end
            end
            self._mapRoguelikeDrop.mapOrdMstDrop[v.MonsterIndex] = tbItemInfo
        end
    end

    self._mapRoguelikeDrop.mapEltMstDrop = {}
    if type(tbEltMstDrop) == "table" then
        for _, v in ipairs(tbEltMstDrop) do
            local tbItemInfo = {}
            if v.DropPkgs then
                for __, vv in ipairs(v.DropPkgs) do
                    for ___, vvv in ipairs(vv.Drops) do
                        table.insert(tbItemInfo, {nItemId = vvv.Tid, nItemCount = vvv.Qty})
                    end
                end
            end
            self._mapRoguelikeDrop.mapEltMstDrop[v.MonsterIndex] = tbItemInfo
        end
    end

    self._mapRoguelikeDrop.mapBossDrop = {}
    if type(mapBossDrop) == "table" and type(mapBossDrop.MonsterIndex) == "number" then
        local tbItemInfo = {}
        for __, vv in ipairs(mapBossDrop.DropPkgs) do
            for ___, vvv in ipairs(vv.Drops) do
                table.insert(tbItemInfo, {nItemId = vvv.Tid, nItemCount = vvv.Qty})
            end
        end
        self._mapRoguelikeDrop.mapBossDrop[mapBossDrop.MonsterIndex] = tbItemInfo
    end
    self:LogDropItem()
    self:LogChestItem()
end
function PlayerRoguelikeData:CacheRoguelikeData(mapData)
    local tbOrdMstDrop = mapData.FloorInfo.OrdMstDrops
    local tbEltMstDrop = mapData.FloorInfo.EltMstDrops
    local mapBossDrop = mapData.FloorInfo.BossDrops
    self._nFloorId = mapData.FloorInfo.FloorID
    self._mapRoguelikeDrop.mapOrdMstDrop = {}
    self._nCurEnergy = ConfigTable.GetData("RoguelikeFloor", self._nFloorId).NeedEnergy
    local tbChestInfo
    self._mapRandomChest,self._mapConstentChest, tbChestInfo = self:ProcessChestData(mapData.FloorInfo.RandomChests, mapData.FloorInfo.ConstantChests)
    safe_call_cs_func(CS.AdventureModuleHelper.SetRoguelikeChestData,tbChestInfo)
    if type(tbOrdMstDrop) == "table" then
        for _, v in ipairs(tbOrdMstDrop) do
            local tbItemInfo = {}
            if v.DropPkgs then
                for __, vv in ipairs(v.DropPkgs) do
                    for ___, vvv in ipairs(vv.Drops) do
                        table.insert(tbItemInfo, {nItemId = vvv.Tid, nItemCount = vvv.Qty})
                    end
                end
            end
            self._mapRoguelikeDrop.mapOrdMstDrop[v.MonsterIndex] = tbItemInfo
        end
    end

    self._mapRoguelikeDrop.mapEltMstDrop = {}
    if type(tbEltMstDrop) == "table" then
        for _, v in ipairs(tbEltMstDrop) do
            local tbItemInfo = {}
            if v.DropPkgs then
                for __, vv in ipairs(v.DropPkgs) do
                    for ___, vvv in ipairs(vv.Drops) do
                        table.insert(tbItemInfo, {nItemId = vvv.Tid, nItemCount = vvv.Qty})
                    end
                end
            end
            self._mapRoguelikeDrop.mapEltMstDrop[v.MonsterIndex] = tbItemInfo
        end
    end

    self._mapRoguelikeDrop.mapBossDrop = {}
    if type(mapBossDrop) == "table" and type(mapBossDrop.MonsterIndex) == "number" then
        local tbItemInfo = {}
        for __, vv in ipairs(mapBossDrop.DropPkgs) do
            for ___, vvv in ipairs(vv.Drops) do
                table.insert(tbItemInfo, {nItemId = vvv.Tid, nItemCount = vvv.Qty})
            end
        end
        self._mapRoguelikeDrop.mapBossDrop[mapBossDrop.MonsterIndex] = tbItemInfo
    end
    self:LogDropItem()
    self:LogChestItem()
    self:EnterRoguelike(mapData)
end
--保存重连时当前遗迹的掉落数据等 nChangedEnergy用于在重连放弃结算时显示返还体力
function PlayerRoguelikeData:CacheReenterRoguelikeFloorData(mapData,nChangedEnergy)
    if mapData.Normal ~= nil then
        self._nPlayerCurFloor = ConfigTable.GetData("RoguelikeFloor", mapData.Normal.FloorInfo.FloorID).Floor
        self.curRoguelikeId = ConfigTable.GetData("RoguelikeFloor", mapData.Normal.FloorInfo.FloorID).RoguelikeId
        local tbOrdMstDrop = mapData.Normal.FloorInfo.OrdMstDrops
        local tbEltMstDrop = mapData.Normal.FloorInfo.EltMstDrops
        local mapBossDrop = mapData.Normal.FloorInfo.BossDrops
        self._nFloorId = mapData.Normal.FloorInfo.FloorID
        self._mapStartAttribute = mapData.Normal.Chars
        self.bKillBoss = false
        self.nNormalMonsterCount = 0
        self.nEliteMonsterCount = 0
        self.nLordCount = 0
        self.nsmallBoxCount = 0
        self.nmediumBoxCount = 0
        self.tbOpenedChest = {}
        self.tbGetPerks = {}
        self._mapRoguelikeDrop.mapOrdMstDrop = {}
        self._SupplyDrop = mapData.Normal.SupplyDrop
        if type(tbOrdMstDrop) == "table" then
            for _, v in ipairs(tbOrdMstDrop) do
                local tbItemInfo = {}
                if v.DropPkgs then
                    for __, vv in ipairs(v.DropPkgs) do
                        for ___, vvv in ipairs(vv.Drops) do
                            table.insert(tbItemInfo, {nItemId = vvv.Tid, nItemCount = vvv.Qty})
                        end
                    end
                end
                self._mapRoguelikeDrop.mapOrdMstDrop[v.MonsterIndex] = tbItemInfo
            end
        end

        self._mapRoguelikeDrop.mapEltMstDrop = {}
        if type(tbEltMstDrop) == "table" then
            for _, v in ipairs(tbEltMstDrop) do
                local tbItemInfo = {}
                if v.DropPkgs then
                    for __, vv in ipairs(v.DropPkgs) do
                        for ___, vvv in ipairs(vv.Drops) do
                            table.insert(tbItemInfo, {nItemId = vvv.Tid, nItemCount = vvv.Qty})
                        end
                    end
                end
                self._mapRoguelikeDrop.mapEltMstDrop[v.MonsterIndex] = tbItemInfo
            end
        end

        self._mapRoguelikeDrop.mapBossDrop = {}
        if type(mapBossDrop) == "table" and type(mapBossDrop.MonsterIndex) == "number" then
            local tbItemInfo = {}
            for __, vv in ipairs(mapBossDrop.DropPkgs) do
                for ___, vvv in ipairs(vv.Drops) do
                    table.insert(tbItemInfo, {nItemId = vvv.Tid, nItemCount = vvv.Qty})
                end
            end
            self._mapRoguelikeDrop.mapBossDrop[mapBossDrop.MonsterIndex] = tbItemInfo
        end
        self:LogDropItem()
        self:ReenterRoguelike(mapData.Normal)
    elseif mapData.Settle ~= nil then
        local ncurFloor,totalFloor = self:GetFloorInfo()
        local nPerkCount = self:CalPerkPerkCount()
        EventManager.Hit(EventId.OpenPanel, PanelId.RoguelikeResult,3,UTILS.DecodeChangeInfo(mapData.Settle.Change),nChangedEnergy,mapData.Settle.Build,ncurFloor,totalFloor,nPerkCount)
    end
end
function PlayerRoguelikeData:CacheRoguelikeBag(mapBagData)
    for j = 1, #mapBagData do
        local nType = ConfigTable.GetData_Item(mapBagData[j].Tid).Stype
        if self._mapRoguelikeBag[nType] == nil then
            self._mapRoguelikeBag[nType] = {}
        end
        self._mapRoguelikeBag[nType][mapBagData[j].Tid] = mapBagData[j].Qty
    end
end
function PlayerRoguelikeData:CachePassedId(tbData)
    if tbData ~= nil then
        self._tbRglPassedIds = tbData
    else
        self._tbRglPassedIds = {}
    end
end
function PlayerRoguelikeData:UpdatePassedId(id)
    if table.indexof(self._tbRglPassedIds, id) <= 0 then
        table.insert(self._tbRglPassedIds, id)
    end
end
------------------------------------------- 世界地图用到的接口-------------------------------------------
function PlayerRoguelikeData:GetUnlockedRoguelikeId(subMapId)
    local tbUnlockedId = {}
    local tbId = GetTableKeys(DataTable.Roguelike) or {}
    for _, nId in ipairs(tbId) do
        local mapData = ConfigTable.GetData("Roguelike", nId)
        if mapData ~= nil then
            if mapData.SubMapName == subMapId and mapData.Difficulty == 1 then
                local tbMainlineId = decodeJson(mapData.UnlockConditon)
                local bUnlocked = true
                for __, nMainlineId in ipairs (tbMainlineId) do
                    local nStar = PlayerData.Mainline:GetMainlineStar(nMainlineId)
                    if type(nStar) ~= "number" then
                        bUnlocked = false
                        break
                    end
                end
                if bUnlocked == true then
                    table.insert(tbUnlockedId, mapData.GroupId)
                end
            end
        end
    end
    return tbUnlockedId
end
--判断指定遗迹是否解锁
function PlayerRoguelikeData:IsRoguelikeUnlock(nRogueId)
    local mapData = ConfigTable.GetData("Roguelike", nRogueId)
    if mapData == nil then
        return false
    end
    local tbMainlineId = decodeJson(mapData.UnlockConditon)
    for __, nMainlineId in ipairs (tbMainlineId) do
        local nStar = PlayerData.Mainline:GetMainlineStar(nMainlineId)
        if type(nStar) ~= "number" then
            return false
        end
    end
    local tbPreConditions = decodeJson(mapData.PreConditions)
    for __, tbCondition in ipairs (tbPreConditions) do
        if tbCondition[1] == 1 then
            if not self:GetCurrRoguePass(tbCondition[2]) then
                return false
            end
        elseif tbCondition[1] == 2 then
            local nLevel = PlayerData.Base:GetWorldClass()
            if nLevel < tbCondition[2] then
                return false
            end
        end
    end
    return true
end
--判断指定遗迹组是否解锁
function PlayerRoguelikeData:IsRoguelikeGroupUnlock(nGroupId)
    local mapGroup = self._Roguelike[nGroupId]
    if mapGroup == nil then
        return false
    end
    for _, mapRoguelike in pairs(mapGroup) do
        if self:IsRoguelikeUnlock(mapRoguelike.Id) then
            return true
        end
    end
    return false
end
--获取刚刚完成主线是否是遗迹解锁条件
function PlayerRoguelikeData:GetPastMainPassUnlock(rId,mId)
    local mapData = self._Roguelike[rId][1]
    local tbMainlineId = decodeJson(mapData.UnlockConditon)
    for __, nMainlineId in ipairs (tbMainlineId) do
        if nMainlineId == mId then
            return true
        end
    end
    return false
end

function PlayerRoguelikeData:GetPreConditionsUnlock(nId)    
    local tbPreConditions = decodeJson(ConfigTable.GetData("Roguelike", nId).PreConditions)
    for __, nPreConditions in ipairs (tbPreConditions) do                
        if tonumber(nPreConditions[1]) == 1 then
            if table.indexof(self._tbRglPassedIds, tonumber(nPreConditions[2])) <= 0 then
                return false, true
            end
        elseif tonumber(nPreConditions[1]) == 2 then
            if PlayerData.Base:GetWorldClass() < tonumber(nPreConditions[2]) then
                return true,false
            end
        end
    end
    return true,true
end
function PlayerRoguelikeData:GetGroupMaxLv(nGroupId)
    local mapGroup = self._Roguelike[nGroupId]
    local maxLv = 1
    for i = 1, 3 do
        local tempData = mapGroup[i]
        if tempData then
            local isUnLockRogue,isUnLockLv = self:GetPreConditionsUnlock(tempData.Id)
            if isUnLockRogue and isUnLockLv then
                if tempData.Difficulty == 1 then
                    maxLv = i
                else
                    if self:GetCurrRoguePass(tempData.Id) then
                        maxLv = i
                    end
                end
            end
        end
    end
    return maxLv
end
function PlayerRoguelikeData:GetCurrRoguePass(nId) 
    if table.indexof(self._tbRglPassedIds, nId) <= 0 then
        return false
    end
    return true
end

function PlayerRoguelikeData:GetEnergyConsume(nId)
    local nEnergyConsume = 0
    local tbRoguelikeFloorId = GetTableKeys(DataTable.RoguelikeFloor) or {}
    for _, nFloorId in ipairs(tbRoguelikeFloorId) do
        local mapRoguelikeFloor = ConfigTable.GetData("RoguelikeFloor", nFloorId)
        if mapRoguelikeFloor ~= nil and mapRoguelikeFloor.RoguelikeId == nId then
            nEnergyConsume = nEnergyConsume + mapRoguelikeFloor.NeedEnergy
        end
    end
    return nEnergyConsume
end
function PlayerRoguelikeData:Select(nId)
    self._nSelectId = nId
end

-----------------------------------------消息处理-----------------------------------------
-- 当玩家触摸传送门或者角色全部死亡时发送的消息（result为false代表队员全部死掉直接结算）
function PlayerRoguelikeData:OnEvent_LevelStateChanged(LevelResult)
    if PlayerData.nCurGameType ~= AllEnum.WorldMapNodeType.Roguelike then
        return
    end
    if LevelResult == AllEnum.LevelResult.Failed then --角色全部死亡
        self:OnEvent_AbandonRoguelike(true)
        return
    elseif LevelResult == AllEnum.LevelResult.Teleporter then
        return
    end
    if type(self.curFloorProcess["OnTouchPortal"]) == "function" then
        self.curFloorProcess:OnTouchPortal(self)
    else
        printError("当前流程无对应处理方法：".. "OnTouchPortal")
    end
end
--当游戏场景加载完毕 角色创建完成后设置角色天赋属性
function PlayerRoguelikeData:OnEvent_OnRoguelikeEnter()

    if type(self.curFloorProcess["OnRoguelikeEnter"]) == "function" then
        self.curFloorProcess:OnRoguelikeEnter(self)
    else
        printError("当前流程无对应处理方法：".. "OnRoguelikeEnter")
    end
end
function PlayerRoguelikeData:OnEvent_MonsterDied(nMonsterID,nType)  
    if PlayerData.nCurGameType == AllEnum.WorldMapNodeType.Roguelike then
        if nType == GameEnum.monsterEpicType.NORMAL then
            if self._mapRoguelikeDrop.mapOrdMstDrop[self.nNormalMonsterCount] ~= nil then
                for _, mapDrop in ipairs(self._mapRoguelikeDrop.mapOrdMstDrop[self.nNormalMonsterCount]) do
                    EventManager.Hit(EventId.ShowRoguelikeDrop, mapDrop.nItemId,mapDrop.nItemCount)
                    self:AddToRoguelikeBag(mapDrop.nItemId,mapDrop.nItemCount)
                end 
            end
            self.nNormalMonsterCount = self.nNormalMonsterCount + 1
        elseif nType == GameEnum.monsterEpicType.ELITE or nType == GameEnum.monsterEpicType.LEADER then
            if self._mapRoguelikeDrop.mapEltMstDrop[self.nEliteMonsterCount] ~= nil then
                for _, mapDrop in ipairs(self._mapRoguelikeDrop.mapEltMstDrop[self.nEliteMonsterCount]) do
                    EventManager.Hit(EventId.ShowRoguelikeDrop, mapDrop.nItemId,mapDrop.nItemCount)
                    self:AddToRoguelikeBag(mapDrop.nItemId,mapDrop.nItemCount)
                end 
            end
            self.nEliteMonsterCount = self.nEliteMonsterCount + 1
        elseif nType == GameEnum.monsterEpicType.LORD then
            if PlayerRoguelikeData.bKillBoss then --临时处理
                printError("重复击杀boss")
                safe_call_cs_func(CS.AdventureModuleHelper.Lua2CSharp_RoguelikeOpenTeleporter)
                return
            end
            PlayerRoguelikeData.bKillBoss = true
            if self._mapRoguelikeDrop.mapBossDrop[self.nLordCount] ~= nil then
                for _, mapDrop in ipairs(self._mapRoguelikeDrop.mapBossDrop[self.nLordCount]) do
                    EventManager.Hit(EventId.ShowRoguelikeDrop, mapDrop.nItemId,mapDrop.nItemCount)
                    self:AddToRoguelikeBag(mapDrop.nItemId,mapDrop.nItemCount)
                end 
            end

            self._nCurEnergy = self._nCurEnergy + ConfigTable.GetData("RoguelikeFloor", self._nFloorId).NeedEnergy
            self.nLordCount =  self.nLordCount + 1
            if type(self.curFloorProcess["OnBossDied"]) == "function" then
                self.curFloorProcess:OnBossDied(self)
            else
                printError("当前流程无对应处理方法：".. "OnBossDied")
            end
        end
    end

end
function PlayerRoguelikeData:OnEvent_OpenChest(nIndex,bIsRandom,nType)
    if PlayerData.nCurGameType ~= AllEnum.WorldMapNodeType.Roguelike then
        return
    end
    nType = nType + 1
    local function ShowTips(nTid,nCount)
        if nTid == 0 or nCount == 0 then
            return
        end
        EventManager.Hit(EventId.ShowRoguelikeDrop,nTid,nCount)
    end
    local idx = math.ceil((nIndex + 1)/64)
        if #self.tbOpenedChest < idx then
            for i = #self.tbOpenedChest + 1,idx do
                table.insert(self.tbOpenedChest, 0)
            end
        end
    local nBitwise = nIndex%64
    self.tbOpenedChest[idx] = self.tbOpenedChest[idx]|(1<<nBitwise)
    local mapChest
    if bIsRandom then
        if self._mapRandomChest[nType] == nil then
            print("无对应宝箱类型：".. nType)
            return
        end
        if self._mapRandomChest[nType][nIndex] == nil then
            print("无对应宝箱数据：".. nType .." "..nIndex)
            return
        end
        mapChest = self._mapRandomChest[nType][nIndex]
    else
        if self._mapConstentChest[nType] == nil then
            print("无对应宝箱类型：".. nType)
            return
        end
        if  self._mapConstentChest[nType][nIndex] == nil then
            print("无对应宝箱数据：".. nType .." "..nIndex)
            return
        end
        mapChest = self._mapConstentChest[nType][nIndex]
    end

    local mapChestLocal = ConfigTable.GetData("Chest", mapChest.Tid)
    if mapChestLocal == nil then 
        print("无对应宝箱数据：".. mapChest.Tid)
        return
    end
    local function callback()
        for _, mapDrop in ipairs(mapChest.Drops) do
            EventManager.Hit(EventId.ShowRoguelikeDrop, mapDrop.Tid,mapDrop.Qty)
            self:AddToRoguelikeBag(mapDrop.Tid, mapDrop.Qty)
        end
        if mapChest.Perks ~= nil and #mapChest.Perks > 0 then
            EventManager.Hit(EventId.OpenPanel, PanelId.FixedRoguelikeZSPerk, mapChest.Perks, nIndex)
            NovaAPI.InputEnable()
            EventManager.Hit(EventId.BlockInput, false)
        end
            ShowTips(mapChestLocal.Item1,mapChestLocal.Number1)
            self:AddToRoguelikeBag(mapChestLocal.Item1, mapChestLocal.Number1)
            ShowTips(mapChestLocal.Item2,mapChestLocal.Number2)
            self:AddToRoguelikeBag(mapChestLocal.Item2, mapChestLocal.Number2)
            ShowTips(mapChestLocal.Item3,mapChestLocal.Number3)
            self:AddToRoguelikeBag(mapChestLocal.Item3, mapChestLocal.Number3)
            ShowTips(mapChestLocal.Item4,mapChestLocal.Number4)
            self:AddToRoguelikeBag(mapChestLocal.Item4, mapChestLocal.Number4)
    end
    TimerManager.Add(1, 1, self, callback, true, true, true, nil)
    --四月版本临时增加 在有秘宝时在延迟时间屏蔽玩家操作防止在延迟时间内玩家进入传送门过层导致秘宝选择报错
    if mapChest.Perks ~= nil and #mapChest.Perks > 0 then 
        NovaAPI.InputDisable()
        EventManager.Hit(EventId.BlockInput, true)
    end
    print("宝箱索引：".. nIndex .." 宝箱序列：".. self.tbOpenedChest[1])
end
function PlayerRoguelikeData:OnEvent_AbandonRoguelike(bFailed)
    if type(self.curFloorProcess["OnAbandon"]) == "function" then
        self.curFloorProcess:OnAbandon(self,bFailed)
    else
        printError("当前流程无对应处理方法：".. "OnAbandon")
    end
end
function PlayerRoguelikeData:OnEvent_LoadLevelRefresh()
end
function PlayerRoguelikeData:OnEvent_LoadLevelRefresh()
    if PlayerData.nCurGameType ~= AllEnum.WorldMapNodeType.Roguelike then
        return
    end
    self:SetActorEffects()
    self:ResetPerkEffect()
    self:SetActorAttributeFloor()
end
function PlayerRoguelikeData:OnEvent_SelectPerk(nIndex,selectPerks)
    table.insert(self.tbGetPerks,{Idx = nIndex,PerkIds = selectPerks})
    print("选择秘宝的宝箱索引：".. nIndex )
end
function PlayerRoguelikeData:OnEvent_TakeEffect(_,EffectId)
    if self.mapEffectTriggerCount[EffectId] == nil then
        self.mapEffectTriggerCount[EffectId] = 0
    end
    self.mapEffectTriggerCount[EffectId] = self.mapEffectTriggerCount[EffectId] + 1
end
----------------------------------------Debug----------------------------------------------------
function PlayerRoguelikeData:LogDropItem()
    
    if not Settings.bGMToolOpen then
        return
    end
    local logStr = "--------OrdMstDrop-------\n"
    if type(self._mapRoguelikeDrop.mapOrdMstDrop) == "table" then
        for key, tbDrop in pairs(self._mapRoguelikeDrop.mapOrdMstDrop) do
            local strIdx = string.format("第%d只普通怪:\n", key)
            for index, item in ipairs(tbDrop) do
                local itemStr = string.format("\t物品Id：%d  物品数量：%d\n",item.nItemId, item.nItemCount)
                strIdx = strIdx..itemStr
            end
            logStr = logStr..strIdx
        end
    end 
    logStr = logStr.."--------EltMstDrop-------\n"
    if type(self._mapRoguelikeDrop.mapEltMstDrop) == "table" then
        for key, tbDrop in pairs(self._mapRoguelikeDrop.mapEltMstDrop) do
            local strIdx = string.format("第%d只精英怪:\n", key)
            for index, item in ipairs(tbDrop) do
                local itemStr = string.format("\t物品Id：%d  物品数量：%d\n",item.nItemId, item.nItemCount)
                strIdx = strIdx..itemStr
            end
            logStr = logStr..strIdx
        end
    end 
    logStr = logStr.."--------BossMstDrop-------\n"
    if type(self._mapRoguelikeDrop.mapBossDrop) == "table" then
        for key, tbDrop in pairs(self._mapRoguelikeDrop.mapBossDrop) do
            local strIdx = string.format("第%d只Boss:\n", key)
            for index, item in ipairs(tbDrop) do
                local itemStr = string.format("\t物品Id：%d  物品数量：%d\n",item.nItemId, item.nItemCount)
                strIdx = strIdx..itemStr
            end
            logStr = logStr..strIdx
        end
    end 
    print(logStr)
end
function PlayerRoguelikeData:LogChestItem()
    
    if not Settings.bGMToolOpen then
        return
    end
    local logStr = "--------ConstantChests-------\n"
    if type(self._mapConstentChest) == "table" then
        for key, ChestData in pairs(self._mapConstentChest) do
            local strIdx = string.format("宝箱类型%d:\n", key)
            for index, Chest in pairs(ChestData) do
                local strChest = string.format("宝箱索引:%d  宝箱ID:%d\n",Chest.Idx,Chest.Tid)
                strIdx = strIdx..strChest
                for _, Drops in ipairs(Chest.Drops) do
                    local itemStr = string.format("\t物品Id：%d  物品数量：%d\n",Drops.Tid, Drops.Qty)
                    strIdx = strIdx..itemStr
                end
            end  
            logStr = logStr..strIdx
        end
    end 
    logStr = logStr.."--------RandomChests-------\n"
    if type(self._mapRandomChest) == "table" then
        for key, ChestData in pairs(self._mapRandomChest) do
            local strIdx = string.format("宝箱类型%d:\n", key)
            for index, Chest in pairs(ChestData) do
                local strChest = string.format("宝箱索引:%d  宝箱ID:%d\n",Chest.Idx,Chest.Tid)
                strIdx = strIdx..strChest
                for _, Drops in ipairs(Chest.Drops) do
                    local itemStr = string.format("\t物品Id：%d  物品数量：%d\n",Drops.Tid, Drops.Qty)
                    strIdx = strIdx..itemStr
                end
            end  
            logStr = logStr..strIdx        
        end     
    end 
    print(logStr)
end
function PlayerRoguelikeData:GM_Skip()
    if self.curFloorProcess ~= self._proc_bossFloor or self.bKillBoss then
        AdventureModuleHelper.Lua2CSharp_GMOrder_SkipLevel()
    end
end
return PlayerRoguelikeData