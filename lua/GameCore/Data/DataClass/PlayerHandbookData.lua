--图鉴数据
------------------------------ local ------------------------------



local PlayerHandbookData = class("PlayerHandbookData")

local HandbookSkinData = require "GameCore.Data.DataClass.HandBookData.HandbookSkinData"
local HandbookDiscData = require "GameCore.Data.DataClass.HandBookData.HandbookDiscData"
local HandbookPlotData = require "GameCore.Data.DataClass.HandBookData.HandbookPlotData"


------------------------------ local -----------------------------

function PlayerHandbookData:ParseBitMapData(bitMap)
    local bitMapData = {}
    for k, v in ipairs(bitMap) do
        for i = 1, 64 do
            bitMapData[(k - 1) * 64 + i] = (v & (1 << (i - 1))) ~= 0 and 1 or 0
        end
    end
    return bitMapData
end

------------------------------ public -----------------------------
function PlayerHandbookData:Init()
    self.tbHandbookMsgData = {}  --所有图鉴数据（解析用）
    self.tbHandbookData = {}    --所有图鉴数据
    self.tbHandbookCfgData = {}  --图鉴配表数据
    self:InitHandbookTableData()
end 

function PlayerHandbookData:InitHandbookTableData()
    local func_ForEach = function(line)
        local handbookData = self:CreateHandbook(line.Type, line.Id, 0)
        self.tbHandbookData[line.Id] = handbookData
        
        if nil == self.tbHandbookCfgData[line.Type] then
            self.tbHandbookCfgData[line.Type] = {}
        end
        self.tbHandbookCfgData[line.Type][line.Index] = line.Id
    end

    ForEachTableLine(DataTable.Handbook, func_ForEach)
end

function PlayerHandbookData:CreateHandbook(type, id, unlock)
    local handbookData
    if type == GameEnum.handbookType.SKIN then
        handbookData = HandbookSkinData.new(id, unlock)
    elseif type == GameEnum.handbookType.OUTFIT then
        handbookData = HandbookDiscData.new(id, unlock)
    elseif type == GameEnum.handbookType.PLOT then
        handbookData = HandbookPlotData.new(id,unlock)
    end
    return handbookData
end

function PlayerHandbookData:UpdateHandbook(msgData)
    local tbLastData = self.tbHandbookMsgData[msgData.Type] or {}
    local tbData = UTILS.ParseByteString(msgData.Data)

    local nByteTableLength = #tbData
    local n64Count = math.ceil(nByteTableLength / 8)
    for j = 1, n64Count do
        for i = 1, 64 do
            --新解锁的图鉴index
            local nIndex = (j - 1) * 64 + i
            local lastResult = UTILS.IsBitSet(tbLastData, nIndex)
            local curResult = UTILS.IsBitSet(tbData, nIndex)
            if lastResult ~= curResult then
                if nil ~= self.tbHandbookCfgData[msgData.Type] then
                    local id = self.tbHandbookCfgData[msgData.Type][nIndex]
                    if nil == self.tbHandbookData[id] then
                        local handbookData = self:CreateHandbook(msgData.Type, id, 1)
                        self.tbHandbookData[id] = handbookData
                    else
                        self.tbHandbookData[id]:UpdateUnlockState(1)
                    end
                end
            end
        end
    end
    self.tbHandbookMsgData[msgData.Type] = tbData
end

function PlayerHandbookData:CacheHandbookData(mapMsgData)
    for _, v in pairs(mapMsgData) do
        self:UpdateHandbook(v)
    end
    
    self:UpdateSkinData()
end

--更新图鉴数据
function PlayerHandbookData:UpdateHandbookData(msgData)
    self:UpdateHandbook(msgData)
    self:UpdateSkinData()
end

--更新皮肤数据
function PlayerHandbookData:UpdateSkinData()
    local tbSkinHandbook = self:GetUnlockHandbookByType(GameEnum.handbookType.SKIN)
    local tbSkinCfgData = self.tbHandbookCfgData[GameEnum.handbookType.SKIN]
    if nil ~= tbSkinCfgData then
        for idx, id in pairs(tbSkinCfgData) do
            local cfgData = ConfigTable.GetData("Handbook", id)
            local nUnlock = nil ~= tbSkinHandbook[id] and 1 or 0
            PlayerData.CharSkin:UpdateSkinData(cfgData.SkinId, id, nUnlock)
        end
    end
end

function PlayerHandbookData:GetUnlockHandbookByType(type)
    local tbDataList = {}
    for _, v in pairs(self.tbHandbookData) do
        if v:GetType() == type and v:CheckUnlock() then
            tbDataList[v:GetId()] = v
        end
    end
    return tbDataList
end

function PlayerHandbookData:GetHandbookDataById(id)
    return self.tbHandbookData[id]
end

function PlayerHandbookData:GetAllHandbookData()
    return self.tbHandbookData
end

function PlayerHandbookData:CheckHandbookUnlock(id)
    local handbookData = self:GetHandbookDataById(id)
    if nil == handbookData then
        return false
    end
    return handbookData:CheckUnlock()
end

function PlayerHandbookData:GetTempHandbookDataById(id)
    local cfgData = ConfigTable.GetData("Handbook", id)
    if nil == cfgData then
        printError("Get Handbook data fail!!! id = ".. id)
        --临时处理  避免有老账号默认看板id是角色id时进主界面黑屏问题
        return self:GetTempHandbookDataById(410301)
    end
    
    local data = self:CreateHandbook(cfgData.Type, id, 1)
    return data
end

--获取看板角色数据
function PlayerHandbookData:GetBoardCharList()
    local tbCharList = {}
    local tbUnlockSkinList = self:GetUnlockHandbookByType(GameEnum.handbookType.SKIN)
    if nil ~= tbUnlockSkinList then
        for id, data in pairs(tbUnlockSkinList) do
            local charId = data:GetCharId() 
            if nil == tbCharList[charId] then
                tbCharList[charId] = {}
            end
            table.insert(tbCharList[charId], data)
        end
    end
    return tbCharList
end


return PlayerHandbookData