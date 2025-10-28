--皮肤数据
------------------------------ local ------------------------------



local PlayerHandbookData = PlayerData.Handbook
local PlayerCharSkinData = class("PlayerCharSkinData")
local TimerManager = require "GameCore.Timer.TimerManager"


local TimerScaleType = require "GameCore.Timer.TimerScaleType"


local LocalData = require "GameCore.Data.LocalData"
local RapidJson = require "rapidjson"
local ClientManager = CS.ClientManager.Instance

local tableInsert = table.insert
local tableRemove = table.remove

local SkinData = require "GameCore.Data.DataClass.SkinData"

------------------------------ public ------------------------------

function PlayerCharSkinData:Init()
    self.tbSkinDataList = {}
    self.tbSkinGainQueue = {}
end 

function PlayerCharSkinData:UpdateSkinData(skinId, handbookId, unlock)
    if nil == self.tbSkinDataList[skinId] then
        local skinData = SkinData.new(skinId, handbookId, unlock)
        self.tbSkinDataList[skinId] = skinData
    else
        self.tbSkinDataList[skinId]:UpdateUnlockState(unlock)
    end
end

--获取指定角色的皮肤列表
function PlayerCharSkinData:GetSkinListByCharacterId(charId)
    local tbSkinList = {}
    for skinId, skin in pairs(self.tbSkinDataList) do
        if skin:GetCharId() == charId then
            tbSkinList[skinId] = skin
        end
    end
   
    return tbSkinList
end

function PlayerCharSkinData:GetSkinDataBySkinId(skinId)
    return self.tbSkinDataList[skinId]
end

function PlayerCharSkinData:CheckSkinUnlock(skinId)
    if self.tbSkinDataList[skinId] ~= nil then
        return self.tbSkinDataList[skinId]:CheckUnlock()
    end
    return false
end

--获取新皮肤播放表现
function PlayerCharSkinData:SkinGainEnqueue(mapMsgData)
    local bNew = nil ~= mapMsgData.New
    local nSkinId = nil ~= mapMsgData.New and mapMsgData.New.Value or mapMsgData.Duplicated.ID
    local tbItemList = {}
    if nil ~= mapMsgData.Duplicated then
        tbItemList = mapMsgData.Duplicated.Items
    end
    local tbData = {
        nId = nSkinId,     --皮肤id
        bNew = bNew,   --是否新获得
        tbItemList = tbItemList or {}  --重复获取转换后的物品列表
    }
    tableInsert(self.tbSkinGainQueue, tbData)
end

function PlayerCharSkinData:RemoveSkinQueue(nId)
    for i = #self.tbSkinGainQueue, 1, -1 do
        if self.tbSkinGainQueue[i].nId == nId then
            tableRemove(self.tbSkinGainQueue, i)
        end
    end
end

function PlayerCharSkinData:TryOpenSkinShowPanel(callback)
    if #self.tbSkinGainQueue == 0 then
        if callback ~= nil then callback() end
        return false
    end
    EventManager.Hit(EventId.OpenPanel, PanelId.ReceiveSpecialReward, self.tbSkinGainQueue, callback)
    return true
end

function PlayerCharSkinData:CheckNewSkin()
    return #self.tbSkinGainQueue > 0
end

function PlayerCharSkinData:GetSkinForReward()
    local tbSpReward = {}
    if #self.tbSkinGainQueue == 0 then
        return tbSpReward
    end
    tbSpReward = clone(self.tbSkinGainQueue)
    self.tbSkinGainQueue = {}
    return tbSpReward
end


------------------------------ update -----------------------------
--更新皮肤解锁数据
function PlayerCharSkinData:UpdateSkinUnlock(unlockList)
   
end

-------------------------------------------------------------------



return PlayerCharSkinData