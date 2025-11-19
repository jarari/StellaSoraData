local PlayerHandbookData = class("PlayerHandbookData")
local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
local femaleSurfix = "_FP"
local maleSurfix = "_MP"
local HandbookSkinData = require("GameCore.Data.DataClass.HandBookData.HandbookSkinData")
local HandbookDiscData = require("GameCore.Data.DataClass.HandBookData.HandbookDiscData")
local HandbookPlotData = require("GameCore.Data.DataClass.HandBookData.HandbookPlotData")
local HandbookStorySetData = require("GameCore.Data.DataClass.HandBookData.HandbookStorySetData")
PlayerHandbookData.ParseBitMapData = function(self, bitMap)
  -- function num : 0_0 , upvalues : _ENV
  local bitMapData = {}
  for k,v in ipairs(bitMap) do
    for i = 1, 64 do
      bitMapData[(k - 1) * 64 + i] = v & 1 << i - 1 ~= 0 and 1 or 0
    end
  end
  return bitMapData
end

PlayerHandbookData.Init = function(self)
  -- function num : 0_1
  self.tbHandbookMsgData = {}
  self.tbHandbookData = {}
  self.tbHandbookCfgData = {}
  self:InitHandbookTableData()
end

PlayerHandbookData.InitHandbookTableData = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local func_ForEach = function(line)
    -- function num : 0_2_0 , upvalues : self
    local handbookData = self:CreateHandbook(line.Type, line.Id, 0)
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self.tbHandbookData)[line.Id] = handbookData
    -- DECOMPILER ERROR at PC17: Confused about usage of register: R2 in 'UnsetPending'

    if (self.tbHandbookCfgData)[line.Type] == nil then
      (self.tbHandbookCfgData)[line.Type] = {}
    end
    -- DECOMPILER ERROR at PC23: Confused about usage of register: R2 in 'UnsetPending'

    ;
    ((self.tbHandbookCfgData)[line.Type])[line.Index] = line.Id
  end

  ForEachTableLine(DataTable.Handbook, func_ForEach)
end

PlayerHandbookData.CreateHandbook = function(self, type, id, unlock)
  -- function num : 0_3 , upvalues : _ENV, HandbookSkinData, HandbookDiscData, HandbookPlotData, HandbookStorySetData
  local handbookData = nil
  if type == (GameEnum.handbookType).SKIN then
    handbookData = (HandbookSkinData.new)(id, unlock)
  else
    if type == (GameEnum.handbookType).OUTFIT then
      handbookData = (HandbookDiscData.new)(id, unlock)
    else
      if type == (GameEnum.handbookType).PLOT then
        handbookData = (HandbookPlotData.new)(id, unlock)
      else
        if type == (GameEnum.handbookType).StorySet then
          handbookData = (HandbookStorySetData.new)(id, unlock)
        end
      end
    end
  end
  return handbookData
end

PlayerHandbookData.UpdateHandbook = function(self, msgData)
  -- function num : 0_4 , upvalues : _ENV
  if not (self.tbHandbookMsgData)[msgData.Type] then
    local tbLastData = {}
  end
  local tbData = (UTILS.ParseByteString)(msgData.Data)
  local nByteTableLength = #tbData
  local n64Count = (math.ceil)(nByteTableLength / 8)
  for j = 1, n64Count do
    for i = 1, 64 do
      local nIndex = (j - 1) * 64 + i
      local lastResult = (UTILS.IsBitSet)(tbLastData, nIndex)
      local curResult = (UTILS.IsBitSet)(tbData, nIndex)
      if lastResult ~= curResult and (self.tbHandbookCfgData)[msgData.Type] ~= nil then
        local id = ((self.tbHandbookCfgData)[msgData.Type])[nIndex]
        if (self.tbHandbookData)[id] == nil then
          local handbookData = self:CreateHandbook(msgData.Type, id, 1)
          -- DECOMPILER ERROR at PC57: Confused about usage of register: R19 in 'UnsetPending'

          ;
          (self.tbHandbookData)[id] = handbookData
        else
          do
            do
              ;
              ((self.tbHandbookData)[id]):UpdateUnlockState(1)
              -- DECOMPILER ERROR at PC64: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC64: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC64: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC64: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC64: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
  -- DECOMPILER ERROR at PC68: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (self.tbHandbookMsgData)[msgData.Type] = tbData
end

PlayerHandbookData.CacheHandbookData = function(self, mapMsgData)
  -- function num : 0_5 , upvalues : _ENV
  for _,v in pairs(mapMsgData) do
    self:UpdateHandbook(v)
  end
  self:UpdateSkinData()
end

PlayerHandbookData.UpdateHandbookData = function(self, msgData)
  -- function num : 0_6
  self:UpdateHandbook(msgData)
  self:UpdateSkinData()
end

PlayerHandbookData.UpdateSkinData = function(self)
  -- function num : 0_7 , upvalues : _ENV
  local tbSkinHandbook = self:GetUnlockHandbookByType((GameEnum.handbookType).SKIN)
  local tbSkinCfgData = (self.tbHandbookCfgData)[(GameEnum.handbookType).SKIN]
  if tbSkinCfgData ~= nil then
    for idx,id in pairs(tbSkinCfgData) do
      local cfgData = (ConfigTable.GetData)("Handbook", id)
      local nUnlock = tbSkinHandbook[id] ~= nil and 1 or 0
      ;
      (PlayerData.CharSkin):UpdateSkinData(cfgData.SkinId, id, nUnlock)
    end
  end
end

PlayerHandbookData.GetUnlockHandbookByType = function(self, typeParam)
  -- function num : 0_8 , upvalues : _ENV
  local tbType = {}
  if type(typeParam) ~= "table" then
    (table.insert)(tbType, typeParam)
  else
    tbType = typeParam
  end
  local tbDataList = {}
  for _,v in pairs(self.tbHandbookData) do
    for _,nType in ipairs(tbType) do
      if v:GetType() == nType and v:CheckUnlock() then
        tbDataList[v:GetId()] = v
      end
    end
  end
  return tbDataList
end

PlayerHandbookData.GetHandbookDataById = function(self, id)
  -- function num : 0_9
  return (self.tbHandbookData)[id]
end

PlayerHandbookData.GetAllHandbookData = function(self)
  -- function num : 0_10
  return self.tbHandbookData
end

PlayerHandbookData.CheckHandbookUnlock = function(self, id)
  -- function num : 0_11
  local handbookData = self:GetHandbookDataById(id)
  if handbookData == nil then
    return false
  end
  return handbookData:CheckUnlock()
end

PlayerHandbookData.GetTempHandbookDataById = function(self, id)
  -- function num : 0_12 , upvalues : _ENV
  local cfgData = (ConfigTable.GetData)("Handbook", id)
  if cfgData == nil then
    printError("Get Handbook data fail!!! id = " .. id)
    return self:GetTempHandbookDataById(410301)
  end
  local data = self:CreateHandbook(cfgData.Type, id, 1)
  return data
end

PlayerHandbookData.GetBoardCharList = function(self)
  -- function num : 0_13 , upvalues : _ENV
  local tbCharList = {}
  local tbUnlockSkinList = self:GetUnlockHandbookByType((GameEnum.handbookType).SKIN)
  if tbUnlockSkinList ~= nil then
    for id,data in pairs(tbUnlockSkinList) do
      local charId = data:GetCharId()
      if tbCharList[charId] == nil then
        tbCharList[charId] = {}
      end
      ;
      (table.insert)(tbCharList[charId], data)
    end
  end
  do
    return tbCharList
  end
end

PlayerHandbookData.GetPlotResourcePath = function(self, nId)
  -- function num : 0_14 , upvalues : _ENV, femaleSurfix, maleSurfix, GameResourceLoader
  local bSecDiff = false
  local mapCfg = (ConfigTable.GetData)("MainScreenCG", nId)
  if mapCfg ~= nil then
    local sFemale = Settings.AB_ROOT_PATH .. mapCfg.FullScreenImg .. femaleSurfix .. ".png"
    local sMale = Settings.AB_ROOT_PATH .. mapCfg.FullScreenImg .. maleSurfix .. ".png"
    if (GameResourceLoader.ExistsAsset)(sFemale) or (GameResourceLoader.ExistsAsset)(sMale) then
      bSecDiff = true
    end
  end
  do
    local sSurfix = ""
    do
      if bSecDiff then
        local bIsMale = (PlayerData.Base):GetPlayerSex()
        sSurfix = bIsMale and maleSurfix or femaleSurfix
      end
      local tbResourcePath = {FullScreenImg = mapCfg.FullScreenImg .. (sSurfix), ListImg = mapCfg.ListImg .. (sSurfix), Icon = mapCfg.Icon .. (sSurfix)}
      return tbResourcePath
    end
  end
end

return PlayerHandbookData

