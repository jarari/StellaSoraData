local PlayerCraftingData = class("PlayerCraftingData")


function PlayerCraftingData:Init()
    --self.tbPresentsProductionList = {}
    self:InitCfgData()
end

function PlayerCraftingData:InitCfgData()
    local foreachProduction = function(line)
        local lineData = line
        local tbMaterialList = {}
        for i = 1, 4 do
            local nMtId = line["RawMaterialId"..i]
            local nMtCount = line["RawMaterialCount"..i]
            if nMtId > 0 then
                local tbMtInfo = {
                    nItemId = nMtId,
                    nCount = nMtCount,
                }
                table.insert(tbMaterialList, tbMtInfo)  
            end
        end
        line.MaterialList = tbMaterialList
        CacheTable.InsertData("_ProductionPage", line.Tag, lineData)
        CacheTable.InsertData("_ProductionGroup", line.Group, lineData)
        CacheTable.SetData("_Production", line.Id, lineData)
        
    end
    ForEachTableLine(DataTable.Production, foreachProduction)
    
    --[[
    local foreachPresents = function(line)
        if nil == CacheTable.GetData("_PresentsCraftingGroup", line.Group) then
            CacheTable.GetData("_PresentsCraftingGroup", line.Group) = {}
        end
        table.insert(CacheTable.GetData("_PresentsCraftingGroup", line.Group), line)
        if line.IsActived then
            table.insert(self.tbPresentsProductionList, line)
        end
    end
    ForEachTableLine(DataTable.PresentsCrafting, foreachPresents)
    
    table.sort(self.tbPresentsProductionList, function(a, b)
        if a.SortId == b.SortId then
            return a.Id > b.Id
        end
        return a.SortId < b.SortId
    end)
    ]]
end

----------------------------------- 材料合成 --------------------------------

--获取配方列表
function PlayerCraftingData:GetProductionListByPage(nPageType)
    local productionList = {}
    local nWorldClass = PlayerData.Base:GetWorldClass()
    local tbList = CacheTable.GetData("_ProductionPage", nPageType)
    if nil ~= tbList then
        for _, v in ipairs(tbList) do
            if v.IsActivated and v.IsShowWorldLevel <= nWorldClass then
                table.insert(productionList, v)
            end
        end
    end
    table.sort(productionList, function(a, b)
        if a.SortId == b.SortId then
            return a.Id < b.Id
        end
        return a.SotId < b.SortId
    end)
    return productionList
end

function PlayerCraftingData:GetProductionPageList()
    local tbPageList = {}
    local nWorldClass = PlayerData.Base:GetWorldClass()
    local _ProductionPage = CacheTable.Get("_ProductionPage") or {}
    for type, list in pairs(_ProductionPage) do
        if nil ~= list and nil ~= next(list) then
            local tbList = {}
            for _, v in ipairs(list) do
                if v.IsActived and v.IsShowWorldLevel <= nWorldClass then
                    table.insert(tbList, v)
                end
            end
            table.sort(tbList, function(a, b)
                if a.SortId == b.SortId then
                    return a.Id > b.Id
                end
                return a.SortId < b.SortId
            end)
           
            if nil ~= next(tbList) then
                local tbPage = {}
                tbPage.nType = type
                local typeCfg = ConfigTable.GetData("ProductionType", type)
                tbPage.nSortId = typeCfg.SortId
                tbPage.tbList = tbList
                table.insert(tbPageList, tbPage)
            end
        end
    end
    table.sort(tbPageList, function(a, b)
        if a.nSortId == b.nSortId then
            return a.nType < b.nType
        end
        return a.nSortId < b.nSortId
    end)
    return tbPageList
end

function PlayerCraftingData:GetProductionById(nId)
    return CacheTable.GetData("_Production", nId)
end

--检查配方是否解锁
function PlayerCraftingData:CheckProductionUnlock(nProductionId)
    local bUnlock = false
    local tbCfg = ConfigTable.GetData("Production", nProductionId)
    if nil ~= tbCfg then
        if tbCfg.IsActived then
            local nWorldClass = PlayerData.Base:GetWorldClass()
            bUnlock = nWorldClass >= tbCfg.IsShowWorldLevel and nWorldClass >= tbCfg.UnlockWorldLevel
        end
    end
    return bUnlock
end

--根据配方组获取配方列表
function PlayerCraftingData:GetProductionListByGroup(nGroupId)
    local tbGroupList = {}
    local tbList = CacheTable.GetData("_ProductionGroup", nGroupId)
    if nil ~= tbList then
        local nWorldClass = PlayerData.Base:GetWorldClass()
        for _, v in ipairs(tbList) do
            if v.IsActived and v.IsShowWorldLevel <= nWorldClass then
                table.insert(tbGroupList, v)
            end
        end
    end
    table.sort(tbGroupList, function(a, b)
        if a.SortId == b.SortId then
            return a.Id > b.Id
        end
        return a.SortId < b.SortId
    end)
    return tbGroupList
end

----------------------------------- 神器合成 --------------------------------
--[[GetPresentsProductionList
function PlayerCraftingData:()
    local tbList = {}
    local nWorldClass = PlayerData.Base:GetWorldClass()
    for _, v in ipairs(self.tbPresentsProductionList) do
        if v.IsShowWorldLevel <= nWorldClass then
            table.insert(tbList, v)
        end
    end
    return tbList
end

function PlayerCraftingData:GetPresentsMatList(nRarity)
    return PlayerData.PlayerPresentsData:GetPresentsListByRarity(nRarity)
end

--检查神器配方是否全部未解锁
function PlayerCraftingData:CheckPresentsTog()
    local bAllLock = true
    local nWorldClass = PlayerData.Base:GetWorldClass()
    for _, v in ipairs(self.tbPresentsProductionList) do
        if v.UnlockWorldLevel <= nWorldClass and v.IsShowWorldLevel <= nWorldClass then
            bAllLock = false
            break
        end
    end
    return bAllLock
end

]]
----------------------------------- http --------------------------------

function PlayerCraftingData:SendMaterialCrafting(nProductionId, nCount, callback)
    local function successCallback(MsgSend, mapMsgData)
        UTILS.OpenReceiveByChangeInfo(mapMsgData)
        if nil ~= callback then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.item_product_req, {Id = nProductionId, Num = nCount}, nil, successCallback)
end

function PlayerCraftingData:SendPresentsCrafting(nProductionId, tbMatList, callback)
    local function successCallback(MsgSend, mapMsgData)
        UTILS.OpenReceiveByChangeInfo(mapMsgData)
        if nil ~= callback then
            callback()
        end
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.presents_crafting_req, {Id = nProductionId, PresentsIds = tbMatList}, nil, successCallback)
end

return PlayerCraftingData