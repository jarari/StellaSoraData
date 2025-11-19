local PlayerHandbookData = PlayerData.Handbook
local PlayerCharSkinData = class("PlayerCharSkinData")
local TimerManager = require("GameCore.Timer.TimerManager")
local TimerScaleType = require("GameCore.Timer.TimerScaleType")
local LocalData = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
local ClientManager = (CS.ClientManager).Instance
local tableInsert = table.insert
local tableRemove = table.remove
local SkinData = require("GameCore.Data.DataClass.SkinData")
PlayerCharSkinData.Init = function(self)
  -- function num : 0_0
  self.tbSkinDataList = {}
  self.tbSkinGainQueue = {}
end

PlayerCharSkinData.UpdateSkinData = function(self, skinId, handbookId, unlock)
  -- function num : 0_1 , upvalues : SkinData
  if (self.tbSkinDataList)[skinId] == nil then
    local skinData = (SkinData.new)(skinId, handbookId, unlock)
    -- DECOMPILER ERROR at PC10: Confused about usage of register: R5 in 'UnsetPending'

    ;
    (self.tbSkinDataList)[skinId] = skinData
  else
    do
      ;
      ((self.tbSkinDataList)[skinId]):UpdateUnlockState(unlock)
    end
  end
end

PlayerCharSkinData.GetSkinListByCharacterId = function(self, charId)
  -- function num : 0_2 , upvalues : _ENV
  local tbSkinList = {}
  for skinId,skin in pairs(self.tbSkinDataList) do
    if skin:GetCharId() == charId then
      tbSkinList[skinId] = skin
    end
  end
  return tbSkinList
end

PlayerCharSkinData.GetSkinDataBySkinId = function(self, skinId)
  -- function num : 0_3
  return (self.tbSkinDataList)[skinId]
end

PlayerCharSkinData.CheckSkinUnlock = function(self, skinId)
  -- function num : 0_4
  if (self.tbSkinDataList)[skinId] ~= nil then
    return ((self.tbSkinDataList)[skinId]):CheckUnlock()
  end
  return false
end

PlayerCharSkinData.SkinGainEnqueue = function(self, mapMsgData)
  -- function num : 0_5 , upvalues : tableInsert
  local bNew = mapMsgData.New ~= nil
  if mapMsgData.New == nil or not (mapMsgData.New).Value then
    local nSkinId = (mapMsgData.Duplicated).ID
  end
  local tbItemList = {}
  if mapMsgData.Duplicated ~= nil then
    tbItemList = (mapMsgData.Duplicated).Items
  end
  if not tbItemList then
    local tbData = {nId = nSkinId, bNew = bNew, 
tbItemList = {}
}
    tableInsert(self.tbSkinGainQueue, tbData)
    -- DECOMPILER ERROR: 5 unprocessed JMP targets
  end
end

PlayerCharSkinData.RemoveSkinQueue = function(self, nId)
  -- function num : 0_6 , upvalues : tableRemove
  for i = #self.tbSkinGainQueue, 1, -1 do
    if ((self.tbSkinGainQueue)[i]).nId == nId then
      tableRemove(self.tbSkinGainQueue, i)
    end
  end
end

PlayerCharSkinData.TryOpenSkinShowPanel = function(self, callback)
  -- function num : 0_7 , upvalues : _ENV
  if #self.tbSkinGainQueue == 0 then
    if callback ~= nil then
      callback()
    end
    return false
  end
  ;
  (EventManager.Hit)(EventId.OpenPanel, PanelId.ReceiveSpecialReward, self.tbSkinGainQueue, callback)
  return true
end

PlayerCharSkinData.CheckNewSkin = function(self)
  -- function num : 0_8
  do return #self.tbSkinGainQueue > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerCharSkinData.GetSkinForReward = function(self)
  -- function num : 0_9 , upvalues : _ENV
  local tbSpReward = {}
  if #self.tbSkinGainQueue == 0 then
    return tbSpReward
  end
  tbSpReward = clone(self.tbSkinGainQueue)
  self.tbSkinGainQueue = {}
  return tbSpReward
end

PlayerCharSkinData.UpdateSkinUnlock = function(self, unlockList)
  -- function num : 0_10
end

return PlayerCharSkinData

