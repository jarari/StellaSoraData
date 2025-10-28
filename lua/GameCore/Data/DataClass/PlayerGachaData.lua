--玩家抽卡数据

------------------------------ local ------------------------------



local RapidJson = require "rapidjson"



local PlayerGachaData = class("PlayerGachaData")


-------------------------------------------------------------------



------------------------------local function ----------------------

function IsOpenCardPool(sStartTime,sEndTime)
    if string.len(sStartTime) == 0 or string.len(sEndTime) == 0 then
        return true
    end
    local nowTime = CS.ClientManager.Instance.serverTimeStamp
    return nowTime>String2Time(sStartTime) and nowTime<String2Time(sEndTime)
end

function String2Time(sTime)
    if sTime ~= "" then
        return CS.ClientManager.Instance:ISO8601StrToTimeStamp(sTime);
    else
        return 0
    end
end

------------------------------ public -----------------------------
function PlayerGachaData:Init()
    self.hadData = false
    self._openedPool = {}
    self:RefreshOpenedPool()
    -- 玩家每个卡池每日已经抽卡次数
    self._mapGachaCount = {} -- { [nPoolID] = nCount }
    -- 玩家每个卡池没有抽到AUP的次数
    self._mapAupMissTimes = {}
    -- 玩家每个卡池没有抽到A的次数
    self._mapAMissTimes = {}
    -- 玩家每个卡池已保底AUP的次数
    self._AupGuaranteeTimes = {}
    -- 玩家每个卡池已总计抽卡次数
    self._mapTotalGachaTimes = {}
    self._mapRecvFirstTenReward = {}
    self._mapRecvGuaranteeReward = {}
    self._mapGachaTotalTimes = {}
    self._mapGachaHistory = {}
    self._mapPoolProbCache={}
    self._mapNewbieData={}
    -- 预处理Gacha表 start
    local function func_ForEach_Gacha(mapGacha)
        if type(mapGacha.OnceTicket) == "string" then
            mapGacha.OnceTicket = RapidJson.decode(mapGacha.OnceTicket)
        end
        if type(mapGacha.TenTimesTicket) == "string" then
            mapGacha.TenTimesTicket = RapidJson.decode(mapGacha.TenTimesTicket)
        end
    end
    ForEachTableLine(DataTable.Gacha,func_ForEach_Gacha)
    --------------  end
end
--已弃用
function PlayerGachaData:RefreshOpenedPool()
    self._openedPool = {}
    local function func_ForEach_Gacha(mapGacha)
        if IsOpenCardPool(mapGacha.StartTime,mapGacha.EndTime) then
            table.insert(self._openedPool,mapGacha.ID)
        end
    end
    ForEachTableLine(DataTable.Gacha,func_ForEach_Gacha)
end

function PlayerGachaData:GetOpenedPool()
    local ret = {}
    local function func_ForEach_Gacha(mapGacha)
        if mapGacha.StorageId == GameEnum.gachaStorageType.BeginnerCardPool then
            -- local nGachCount = self._mapTotalGachaTimes[mapGacha.Id]
            -- if nGachCount == nil then
            --     nGachCount = 0
            -- end
            -- if nGachCount < nNewBiePoolCount then
            --     table.insert(ret,mapGacha.Id)
            -- end
            local newbieData = self:GetGachaNewbieData(mapGacha.Id)
            if newbieData~= nil and not newbieData.Receive then
                table.insert(ret,mapGacha.Id)
            end
        else
            if IsOpenCardPool(mapGacha.StartTime,mapGacha.EndTime) then
                table.insert(ret,mapGacha.Id)
            end
        end
    end
    ForEachTableLine(DataTable.Gacha,func_ForEach_Gacha)
    return ret
end
function PlayerGachaData:CacheGachaData(mapData)
    for k, v in pairs(mapData) do
        self._mapGachaCount[v.Id] = v.DaysCount
        self._mapAupMissTimes[v.Id] = v.AupMissTimes
        self._mapTotalGachaTimes[v.Id] = v.TotalTimes
        self._AupGuaranteeTimes[v.Id] = v.AupGuaranteeTimes
        self._mapRecvFirstTenReward[v.Id] = v.ReveFirstTenReward
        self._mapRecvGuaranteeReward[v.Id] = v.RecvGuaranteeReward
        self._mapGachaTotalTimes[v.Id] = v.GachaTotalTimes
        self._mapAMissTimes[v.Id] = v.AMissTimes
    end
end
function PlayerGachaData:CacheGachaHistory(nSaveId,mapData)
    if self._mapGachaHistory[nSaveId] == nil  then
        self._mapGachaHistory[nSaveId] = {}
    end
    for _, mapHistory in ipairs(mapData.List) do
        table.insert(self._mapGachaHistory[nSaveId],mapHistory)
    end
end
function PlayerGachaData:AddGachaHistory(nSaveId,nGachaId,mapData)
    if self._mapGachaHistory[nSaveId] == nil  then
       return
    end
    local Ids = {}
    for _, mapCard in ipairs(mapData.Cards) do
        table.insert(Ids,mapCard.Card.Tid)
    end
    table.insert(self._mapGachaHistory[nSaveId],{
        Ids = Ids,
        Time = mapData.Time,
        Gid = nGachaId
    })
end
function PlayerGachaData:GetGachaCountById(nPoolID)
    if self._mapGachaCount[nPoolID] == nil then
        return 0
    else
        return self._mapGachaCount[nPoolID]
    end
end
function PlayerGachaData:GetGachaTotalCountById(nPoolID)
    if self._mapTotalGachaTimes[nPoolID] == nil then
        return 0
    else
        return self._mapTotalGachaTimes[nPoolID]
    end
end
function PlayerGachaData:GetAupMissTimesById(nPoolID)
    if self._mapAupMissTimes[nPoolID] == nil then
        return 0
    else
        return self._mapAupMissTimes[nPoolID]
    end
end
function PlayerGachaData:GetAMissTimesById(nPoolID)
    if self._mapAMissTimes[nPoolID] == nil then
        return 0
    else
        return self._mapAMissTimes[nPoolID]
    end
end
function PlayerGachaData:GetAupGuaranteeById(nPoolID)
    if self._AupGuaranteeTimes[nPoolID] == nil then
        return 0
    else
        return self._AupGuaranteeTimes[nPoolID]
    end
end

function PlayerGachaData:GetRecvFirstTenReward(nPoolID)
    if self._mapRecvFirstTenReward[nPoolID] == nil then
        return false
    else
        return self._mapRecvFirstTenReward[nPoolID]
    end
end

function PlayerGachaData:GetRecvGuaranteeReward(nPoolID)
    if self._mapRecvGuaranteeReward[nPoolID] == nil then
        return false
    else
        return self._mapRecvGuaranteeReward[nPoolID]
    end
end

function PlayerGachaData:GetGachaTotalTimes(nPoolID)
    if self._mapGachaTotalTimes[nPoolID] == nil then
        return 0
    else
        return self._mapGachaTotalTimes[nPoolID]
    end
end

function PlayerGachaData:GachaCountChanged(nPoolID,nDayCount)
    self._mapGachaCount[nPoolID] = nDayCount
end
function PlayerGachaData:AupMissTimesCountChanged(nPoolID,nCount)
    self._mapAupMissTimes[nPoolID] = nCount
end
function PlayerGachaData:AMissTimesCountChanged(nPoolID,nCount)
    if nCount == nil then
        nCount = 0
    end
    self._mapAMissTimes[nPoolID] = nCount
end
function PlayerGachaData:TotalCountChanged(nPoolID,nCount)
    self._mapTotalGachaTimes[nPoolID] = nCount
end
function PlayerGachaData:AupGuaranteeTimesChanged(nPoolID,nCount)
    self._AupGuaranteeTimes[nPoolID] = nCount
end

function PlayerGachaData:RecvFirstTenReward(nPoolID,bValue)
    self._mapRecvFirstTenReward[nPoolID] = bValue
end

function PlayerGachaData:RecvGuaranteeReward(nPoolID,bValue)
    self._mapRecvGuaranteeReward[nPoolID] = bValue
end

function PlayerGachaData:GachaTotalTimes(nPoolID,nCount)
    self._mapGachaTotalTimes[nPoolID] = nCount
end

function PlayerGachaData:GetGachaInfomation(callback)
    local function GetInfoCallback(_,mapData)
        self.hadData = true
        self:CacheGachaData(mapData.Information)
        if type(callback) == "function" then
            callback()
        end
    end
    if self.hadData then
        if type(callback) == "function" then
            callback()
        end
    else
        HttpNetHandler.SendMsg(NetMsgId.Id.gacha_information_req, {}, nil, GetInfoCallback)
    end
end
function PlayerGachaData:GetGachaHistory(nSaveId,callback)
    if self._mapGachaHistory[nSaveId] ~= nil then
        if type(callback) == "function" then
            callback(self._mapGachaHistory[nSaveId])
        end
        return
    end

    local function GetHistoryCallback(_,mapData)
        self:CacheGachaHistory(nSaveId,mapData)
        if type(callback) == "function" then
            callback(self._mapGachaHistory[nSaveId])
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.gacha_histories_req, {Value = nSaveId}, nil, GetHistoryCallback)
end
--mode(1:单抽 2:10连)
function PlayerGachaData:SendGachaReq(nId,nMode,callback)
    local function GachaCallback(_,mapData)
        self:GachaCountChanged(nId,mapData.DaysCount)
        self:AupMissTimesCountChanged(nId,mapData.AupMissTimes)
        self:AMissTimesCountChanged(nId,mapData.AMissTimes)
        self:TotalCountChanged(nId,mapData.TotalTimes)
        self:AupGuaranteeTimesChanged(nId,mapData.AupGuaranteeTimes)
        self:GachaTotalTimes(nId, mapData.GachaTotalTimes)
        if nMode == 2 then
            self:RecvFirstTenReward(nId, true)
        end
        local mapGacha = ConfigTable.GetData("Gacha", nId)
        if mapGacha ~= nil and mapGacha.StorageId > 0 then
            self:AddGachaHistory(mapGacha.StorageId,nId,mapData)
        end
        -- if self._mapGachaCount[nId] == nil then
        --     self._mapGachaCount[nId] = 0
        -- end
        -- self._mapGachaCount[nId] =  self._mapGachaCount[nId] + (nMode == 1 and 1 or 10)
        if type(callback) == "function" then
            callback(mapData)
        end

        if nMode == 2 then
            local tab = {}
            table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
            if mapGacha.StorageId == GameEnum.gachaStorageType.CharacterCardPool then
                NovaAPI.UserEventUpload("standard_trekker_gacha10",tab) --常规旅人招募十连
            elseif mapGacha.StorageId == GameEnum.gachaStorageType.DiscCardPool then
                NovaAPI.UserEventUpload("standard_disc_gacha10",tab) --常规秘纹招募十连
            elseif mapGacha.StorageId == GameEnum.gachaStorageType.CharacterUpCardPool then
                NovaAPI.UserEventUpload("limited_trekker_gacha10",tab) --限时旅人招募十连
            elseif mapGacha.StorageId == GameEnum.gachaStorageType.DiscUpCardPool then
                NovaAPI.UserEventUpload("limited_disc_gacha10",tab) --限时秘纹招募十连
            elseif mapGacha.StorageId == GameEnum.gachaStorageType.BeginnerCardPool then
                NovaAPI.UserEventUpload("guaranteed5star_gacha10",tab) --五星必得十连
            end
        end
    end
    local mapMsgData = {
        Id = nId,
        Mode = nMode
    }
    EventManager.Hit("GachaProcessStart",true)
    HttpNetHandler.SendMsg(NetMsgId.Id.gacha_spin_req, mapMsgData, nil, GachaCallback)
end

function PlayerGachaData:GetPoolProbData(nPoolId)
    if self._mapPoolProbCache[nPoolId] ~=nil then
        return self._mapPoolProbCache[nPoolId]
    else
        local probUpItem,probItem=self:GetPoolProbDetail(nPoolId)
        self._mapPoolProbCache[nPoolId]={tbProbUpItem=probUpItem,tbProbItem=probItem}
    end
end
function PlayerGachaData:GetPoolProbDetail(nPoolID)
    local tbUpItemList={}
    local tbItemList={}

    local gachaConfig=ConfigTable.GetData("Gacha",nPoolID)
    local nStorageType=gachaConfig.StorageId
    local gachaStorageConfig=ConfigTable.GetData("GachaStorage",nStorageType)
    local nBTypeProb=gachaStorageConfig.BTypeProb   --B类奖励的概率
    local gachaATypeProbConfig=nil
    local function func_ForEach_GachaATypeProb(mapData)
        if mapData.Group==gachaStorageConfig.ATypeGroup and mapData.Times==0 then
            gachaATypeProbConfig=mapData
        end
    end
    ForEachTableLine(DataTable.GachaATypeProb,func_ForEach_GachaATypeProb)
    local nATypeProb=gachaATypeProbConfig.Prob  --A类奖励的概率
    local nCTypeProb=10000-nATypeProb-nBTypeProb --C类奖励的概率

    local nATypePkgUpProb=nATypeProb*gachaStorageConfig.ATypeUpProb/10000                   --A类Up包概率
    local nATypePkgProb=nATypeProb*(1-gachaStorageConfig.ATypeUpProb/10000)                 --A类包概率
    local nBTypePkgUpProb=nBTypeProb*gachaStorageConfig.BTypeUpProb/10000                   --B类Up包概率
    local nBTypePkgGuaranteeProb=nBTypeProb*gachaStorageConfig.BTypeGuaranteeProb/10000        --B类保底包概率
    local nBTypePkgProb=nBTypeProb*(1-(gachaStorageConfig.BTypeUpProb+gachaStorageConfig.BTypeGuaranteeProb)/10000)                 --B类包概率
    local nCTypePkgProb=10000-nATypePkgUpProb-nATypePkgProb-nBTypePkgUpProb-nBTypePkgProb-nBTypePkgGuaranteeProb   --C类包概率

    local tbATypeItem={}
    local tbBTypeItem={}
    local tbCTypeItem={}
    local tbATypeUpItem={}
    local tbBTypeUpItem={}
    local tbBTypeGuaranteeItem={}

    local nATypeTotalWeight=0
    local nBTypeTotalWeight=0
    local nCTypeTotalWeight=0
    local nATypeUpTotalWeight=0
    local nBTypeUpTotalWeight=0
    local nBTypeGuaranteeWeight=0

    local function func_ForEachGachaPkg(mapData)
        if mapData.PkgId==gachaConfig.ATypePkg then
            table.insert(tbATypeItem,{nGoodsId=mapData.GoodsId,nWeight=mapData.Weight})
            nATypeTotalWeight=nATypeTotalWeight+mapData.Weight
        elseif mapData.PkgId==gachaConfig.BTypePkg then
            table.insert(tbBTypeItem,{nGoodsId=mapData.GoodsId,nWeight=mapData.Weight})
            nBTypeTotalWeight=nBTypeTotalWeight+mapData.Weight
        elseif mapData.PkgId==gachaConfig.BGuaranteePkg then
            table.insert(tbBTypeGuaranteeItem,{nGoodsId=mapData.GoodsId,nWeight=mapData.Weight})
            nBTypeGuaranteeWeight = nBTypeGuaranteeWeight+mapData.Weight
        elseif mapData.PkgId==gachaConfig.CTypePkg then
            table.insert(tbCTypeItem,{nGoodsId=mapData.GoodsId,nWeight=mapData.Weight})
            nCTypeTotalWeight=nCTypeTotalWeight+mapData.Weight
        elseif mapData.PkgId==gachaConfig.ATypeUpPkg then
            table.insert(tbATypeUpItem,{nGoodsId=mapData.GoodsId,nWeight=mapData.Weight})
            nATypeUpTotalWeight=nATypeUpTotalWeight+mapData.Weight
        elseif mapData.PkgId==gachaConfig.BTypeUpPkg then
            table.insert(tbBTypeUpItem,{nGoodsId=mapData.GoodsId,nWeight=mapData.Weight})
            nBTypeUpTotalWeight=nBTypeUpTotalWeight+mapData.Weight
        end

    end
    ForEachTableLine(DataTable.GachaPkg,func_ForEachGachaPkg)
    for _, v in pairs(tbATypeItem) do
        local nProb=(v.nWeight/nATypeTotalWeight)*nATypePkgProb/10000*100
        table.insert(tbItemList,{nGoodsId=v.nGoodsId,nProbValue=nProb})
    end
    for _, v in pairs(tbBTypeItem) do
        local nProb=(v.nWeight/nBTypeTotalWeight)*nBTypePkgProb/10000*100
        table.insert(tbItemList,{nGoodsId=v.nGoodsId,nProbValue=nProb})
    end
    for _, v in pairs(tbBTypeGuaranteeItem) do
        local nProb=(v.nWeight/nBTypeGuaranteeWeight)*nBTypePkgGuaranteeProb/10000*100
        table.insert(tbItemList,{nGoodsId=v.nGoodsId,nProbValue=nProb})
    end
    for _, v in pairs(tbCTypeItem) do
        local nProb=(v.nWeight/nCTypeTotalWeight)*nCTypePkgProb/10000*100
        table.insert(tbItemList,{nGoodsId=v.nGoodsId,nProbValue=nProb})
    end
    for _, v in pairs(tbATypeUpItem) do
        local nProb=(v.nWeight/nATypeUpTotalWeight)*nATypePkgUpProb/10000*100
        table.insert(tbUpItemList,{nGoodsId=v.nGoodsId,nProbValue=nProb})
    end
    for _, v in pairs(tbBTypeUpItem) do
        local nProb=(v.nWeight/nBTypeUpTotalWeight)*nBTypePkgUpProb/10000*100
        table.insert(tbUpItemList,{nGoodsId=v.nGoodsId,nProbValue=nProb})
    end

    
    local function sortItem(a,b)
        local aItemConfig=ConfigTable.GetData_Item(a.nGoodsId)
        local bItemConfig=ConfigTable.GetData_Item(b.nGoodsId)
        if aItemConfig.Rarity<bItemConfig.Rarity then
            return true
        elseif aItemConfig.Rarity>bItemConfig.Rarity then
            return false
        else 
            if aItemConfig.Type==GameEnum.itemType.Char and bItemConfig.Type==GameEnum.itemType.Disc then
                return true
            elseif aItemConfig.Type==GameEnum.itemType.Disc and bItemConfig.Type==GameEnum.itemType.Char then
                return false
            else
                return aItemConfig.Id<bItemConfig.Id
            end
        end
    end
    table.sort(tbUpItemList,sortItem)
    table.sort(tbItemList,sortItem)
    return tbUpItemList,tbItemList
end

function PlayerGachaData:SendGachaGuaranteeRewardReq(nId,callback)
    local function GachaCallback(_,mapData)
        self:RecvGuaranteeReward(nId, true)
        if type(callback) == "function" then
            callback(mapData)
        end
    end
    local mapMsgData = {
        Value = nId,
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.gacha_guarantee_reward_receive_req, mapMsgData, nil, GachaCallback)
end

-------------------------------------------------------------------

--- newbie ---

function PlayerGachaData:CacheGachaNewbieData(mapData)
    
    for _, v in ipairs(mapData) do
        local newbie = {}
        newbie.Id = v.Id
        newbie.Receive = v.Receive
        newbie.Times = v.Times
        newbie.Cards = {}
        for _,v1 in ipairs(v.Cards) do
            local cards = {}
            for _,v2 in ipairs(v1.Values) do
                table.insert(cards, v2)
            end
            table.insert(newbie.Cards, cards)
        end
        newbie.Temp = {}
        if v.Temp ~= nil then
            for _,v2 in ipairs(v.Temp.Values) do
                table.insert(newbie.Temp, v2)
            end
        end
        self._mapNewbieData[v.Id] = newbie
    end
    printTable(self._mapNewbieData)
end

function PlayerGachaData:GetGachaNewbieData(nId)
    if self._mapNewbieData[nId] == nil then
        local newbie = {}
        newbie.Id = nId
        newbie.Receive = false
        newbie.Times = 0
        newbie.Cards = {}
        newbie.Temp = {}
        self._mapNewbieData[nId] = newbie
    end
    return self._mapNewbieData[nId]
end

function PlayerGachaData:GetGachaNewbieInfomation(callback)
    local function GetInfoCallback(_,mapData)
        self.hadNewbieData = true
        self:CacheGachaNewbieData(mapData.List)
        if type(callback) == "function" then
            callback()
        end
    end
    if self.hadNewbieData then
        if type(callback) == "function" then
            callback()
        end
    else
        HttpNetHandler.SendMsg(NetMsgId.Id.gacha_newbie_info_req, {}, nil, GetInfoCallback)
    end
end

function PlayerGachaData:SendGachaNewbieReq(nId,callback)
    local function GachaCallback(_,mapData)
        local data = self._mapNewbieData[nId]
        data.Times = data.Times + 1
        data.Temp = {}
        for _,v in ipairs(mapData.Cards) do
            table.insert(data.Temp, v)
        end
        self._mapNewbieData[nId] = data
        if type(callback) == "function" then
            callback(mapData)
        end
        local tab = {}
        table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
        NovaAPI.UserEventUpload("guaranteed5star_gacha10",tab)
    end
    local mapMsgData = {
        Value = nId,
    }
    EventManager.Hit("GachaProcessStart",true)
    HttpNetHandler.SendMsg(NetMsgId.Id.gacha_newbie_spin_req, mapMsgData, nil, GachaCallback)
end

function PlayerGachaData:SendGachaNewbieSaveReq(nId,idx,callback)
    local function GachaCallback(_,mapData)
        local data = self._mapNewbieData[nId]
        local cards = {}
        
        for _,v in ipairs(data.Temp) do
            table.insert(cards, v)
        end
        if idx == 0 then
            table.insert(data.Cards, cards)
        elseif idx > 0 then
            data.Cards[idx] = cards
        end
        
        data.Temp = {}
        self._mapNewbieData[nId] = data

        if type(callback) == "function" then
            callback(mapData)
        end
        local tab = {}
        table.insert(tab,{"role_id",tostring(PlayerData.Base._nPlayerId)})
        NovaAPI.UserEventUpload("guaranteed5star_gacha10",tab)
    end
    local mapMsgData = {
        Id = nId,
        Idx = idx,
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.gacha_newbie_save_req, mapMsgData, nil, GachaCallback)
end

function PlayerGachaData:SendGachaNewbieObtainReq(nId,idx,callback)
    local function GachaCallback(_,mapData)
        local data = self._mapNewbieData[nId]
        data.Receive = true
        self._mapNewbieData[nId] = data

        if type(callback) == "function" then
            callback(mapData)
        end
    end
    local mapMsgData = {
        Id = nId,
        Idx = idx,
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.gacha_newbie_obtain_req, mapMsgData, nil, GachaCallback)
end

---

return PlayerGachaData