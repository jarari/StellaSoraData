local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local PlayerBoardData = class("PlayerBoardData")
local PlayerHandbookData = PlayerData.Handbook
local LocalData = require("GameCore.Data.LocalData")
local max_select_count = 5
PlayerBoardData.Init = function(self)
  -- function num : 0_0
  self.tbSelectBoardList = {}
  self.tbTmpSelectBoardList = {}
  self.tbTmpSelectSkinList = {}
  self.nBoardPanelShowId = 0
  self.nBoardPanelCGType = 0
  self.nCurBoardIdx = 1
end

PlayerBoardData.CacheBoardData = function(self, mapMagData)
  -- function num : 0_1 , upvalues : LocalData, _ENV
  local nLocalIdx = (LocalData.GetPlayerLocalData)("MainBoardIndex")
  if nLocalIdx == nil then
    (LocalData.SetPlayerLocalData)("MainBoardIndex", "1")
  end
  self.nCurBoardIdx = tonumber((LocalData.GetPlayerLocalData)("MainBoardIndex"))
  self.tbSelectBoardList = mapMagData
  self:ResetBoardList()
end

PlayerBoardData.GetSelectBoardData = function(self)
  -- function num : 0_2
  return self.tbSelectBoardList
end

PlayerBoardData.CheckSelectBoardChar = function(self)
  -- function num : 0_3 , upvalues : _ENV, PlayerHandbookData
  for _,nId in ipairs(self.tbSelectBoardList) do
    local handbookData = PlayerHandbookData:GetHandbookDataById(nId)
    if handbookData ~= nil and handbookData:GetType() == (GameEnum.handbookType).SKIN then
      return true
    end
  end
  return false
end

PlayerBoardData.GetCurBoardData = function(self)
  -- function num : 0_4 , upvalues : PlayerHandbookData
  if #self.tbSelectBoardList < self.nCurBoardIdx then
    self:ResetBoardIndex()
  end
  if (self.tbSelectBoardList)[self.nCurBoardIdx] ~= nil then
    local nId = (self.tbSelectBoardList)[self.nCurBoardIdx]
    if nId ~= nil then
      local handbookData = PlayerHandbookData:GetHandbookDataById(nId)
      return handbookData
    end
  end
end

PlayerBoardData.GetCurBoardCharID = function(self)
  -- function num : 0_5 , upvalues : _ENV
  local curBoardData = self:GetCurBoardData()
  if curBoardData ~= nil and curBoardData:GetType() == (GameEnum.handbookType).SKIN then
    return curBoardData:GetCharId()
  end
end

PlayerBoardData.GetTempBoardData = function(self)
  -- function num : 0_6 , upvalues : PlayerHandbookData
  if (self.tbSelectBoardList)[self.nCurBoardIdx] ~= nil then
    local nId = (self.tbSelectBoardList)[self.nCurBoardIdx]
    if nId ~= nil then
      return PlayerHandbookData:GetTempHandbookDataById(nId)
    end
  end
end

PlayerBoardData.ChangeNextBoard = function(self)
  -- function num : 0_7 , upvalues : LocalData, _ENV
  if #self.tbSelectBoardList <= 1 then
    return false
  end
  self.nCurBoardIdx = self.nCurBoardIdx + 1
  if #self.tbSelectBoardList < self.nCurBoardIdx then
    self.nCurBoardIdx = 1
  end
  ;
  (LocalData.SetPlayerLocalData)("MainBoardIndex", tostring(self.nCurBoardIdx))
  return true
end

PlayerBoardData.ChangeLastBoard = function(self)
  -- function num : 0_8 , upvalues : LocalData, _ENV
  if #self.tbSelectBoardList <= 1 then
    return false
  end
  self.nCurBoardIdx = self.nCurBoardIdx - 1
  if self.nCurBoardIdx <= 0 then
    self.nCurBoardIdx = #self.tbSelectBoardList
  end
  ;
  (LocalData.SetPlayerLocalData)("MainBoardIndex", tostring(self.nCurBoardIdx))
  return true
end

PlayerBoardData.ResetBoardIndex = function(self)
  -- function num : 0_9 , upvalues : LocalData, _ENV
  self.nCurBoardIdx = 1
  ;
  (LocalData.SetPlayerLocalData)("MainBoardIndex", tostring(self.nCurBoardIdx))
end

PlayerBoardData.GetMaxSelectCount = function(self)
  -- function num : 0_10 , upvalues : max_select_count
  return max_select_count
end

PlayerBoardData.GetBoardDragThreshold = function(self)
  -- function num : 0_11 , upvalues : _ENV
  return (ConfigTable.GetConfigNumber)("MainViewDragThreshold")
end

PlayerBoardData.ResetBoardList = function(self)
  -- function num : 0_12 , upvalues : _ENV
  self.tbTmpSelectBoardList = clone(self.tbSelectBoardList)
end

PlayerBoardData.SetTmpBoardList = function(self, tbList)
  -- function num : 0_13
  self.tbTmpSelectBoardList = tbList
end

PlayerBoardData.CheckInTmpBoardList = function(self, nHandbookId)
  -- function num : 0_14 , upvalues : _ENV
  for _,v in pairs(self.tbTmpSelectBoardList) do
    if v == nHandbookId then
      return true
    end
  end
  return false
end

PlayerBoardData.GetTmpBoardIndexById = function(self, nHandbookId)
  -- function num : 0_15 , upvalues : _ENV
  for k,v in pairs(self.tbTmpSelectBoardList) do
    if v == nHandbookId then
      return k
    end
  end
  return 0
end

PlayerBoardData.InsertTmpBoard = function(self, nHandbookId)
  -- function num : 0_16 , upvalues : max_select_count, _ENV
  if max_select_count <= #self.tbTmpSelectBoardList then
    return false
  end
  ;
  (table.insert)(self.tbTmpSelectBoardList, nHandbookId)
  return true
end

PlayerBoardData.RemoveTmpBoard = function(self, nHandbookId)
  -- function num : 0_17 , upvalues : _ENV
  local removeIdx = 0
  for k,v in pairs(self.tbTmpSelectBoardList) do
    if v == nHandbookId then
      removeIdx = k
      break
    end
  end
  do
    if removeIdx ~= 0 then
      (table.remove)(self.tbTmpSelectBoardList, removeIdx)
    end
  end
end

PlayerBoardData.ChangeTmpCharSkin = function(self, nCharId, nHandbookId)
  -- function num : 0_18 , upvalues : _ENV, PlayerHandbookData
  self:SetTmpSkinSelect(nCharId, nHandbookId)
  for k,v in pairs(self.tbTmpSelectBoardList) do
    local handbookData = PlayerHandbookData:GetHandbookDataById(v)
    -- DECOMPILER ERROR at PC26: Confused about usage of register: R9 in 'UnsetPending'

    if handbookData ~= nil and handbookData:GetType() == (GameEnum.handbookType).SKIN and handbookData:GetCharId() == nCharId then
      (self.tbTmpSelectBoardList)[k] = nHandbookId
      break
    end
  end
end

PlayerBoardData.GetTmpBoardList = function(self)
  -- function num : 0_19
  return self.tbTmpSelectBoardList
end

PlayerBoardData.SetTmpSkinSelect = function(self, nCharId, handbookId)
  -- function num : 0_20
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R3 in 'UnsetPending'

  (self.tbTmpSelectSkinList)[nCharId] = handbookId
end

PlayerBoardData.ResetTmpSkinSelect = function(self)
  -- function num : 0_21
  self.tbTmpSelectSkinList = {}
end

PlayerBoardData.GetTmpSkinSelect = function(self)
  -- function num : 0_22
  return self.tbTmpSelectSkinList
end

PlayerBoardData.SetBoardPanelSelectId = function(self, nId)
  -- function num : 0_23
  self.nBoardPanelShowId = nId
end

PlayerBoardData.GetBoardPanelSelectId = function(self)
  -- function num : 0_24
  return self.nBoardPanelShowId
end

PlayerBoardData.SetBoardPanelL2DType = function(self, nType)
  -- function num : 0_25
  self.nBoardPanelCGType = nType
end

PlayerBoardData.GetBoardPanelL2DType = function(self)
  -- function num : 0_26
  return self.nBoardPanelCGType
end

PlayerBoardData.SendBoardSet = function(self, callback)
  -- function num : 0_27 , upvalues : _ENV
  if self.tbTmpSelectBoardList ~= nil and next(self.tbTmpSelectBoardList) ~= nil then
    local sendBoardList = {}
    for _,v in pairs(self.tbTmpSelectBoardList) do
      if v ~= nil then
        (table.insert)(sendBoardList, v)
      end
    end
    local bChange = false
    if #sendBoardList ~= #self.tbSelectBoardList then
      bChange = true
    else
      for k,v in ipairs(sendBoardList) do
        if (self.tbSelectBoardList)[k] == nil or (self.tbSelectBoardList)[k] ~= v then
          bChange = true
          break
        end
      end
    end
    do
      local callbackFunc = function()
    -- function num : 0_27_0 , upvalues : self, _ENV, callback
    local nSelectId = self:GetBoardPanelSelectId()
    for k,v in ipairs(self.tbSelectBoardList) do
      if v == nSelectId then
        self.nCurBoardIdx = k
        break
      end
    end
    do
      if callback ~= nil then
        callback()
      end
    end
  end

      if bChange then
        local msgData = {Ids = sendBoardList}
        ;
        (HttpNetHandler.SendMsg)((NetMsgId.Id).player_board_set_req, msgData, nil, callbackFunc)
      else
        do
          callbackFunc()
        end
      end
    end
  end
end

PlayerBoardData.SetBoardSuccess = function(self)
  -- function num : 0_28 , upvalues : _ENV
  self.tbSelectBoardList = {}
  for _,v in pairs(self.tbTmpSelectBoardList) do
    if v ~= nil then
      (table.insert)(self.tbSelectBoardList, v)
    end
  end
  self:ResetBoardList()
  self:ResetBoardIndex()
end

PlayerBoardData.SetBoardFail = function(self)
  -- function num : 0_29
  self:ResetBoardList()
end

PlayerBoardData.GetUsableBoardCharId = function(self)
  -- function num : 0_30 , upvalues : _ENV, PlayerHandbookData
  local curBoardData = self:GetCurBoardData()
  if curBoardData:GetType() == (GameEnum.handbookType).SKIN then
    return curBoardData:GetCharId(), curBoardData:GetSkinId()
  end
  local tbBoardChar = {}
  for _,nId in ipairs(self.tbSelectBoardList) do
    local handbookData = PlayerHandbookData:GetHandbookDataById(nId)
    if handbookData:GetType() == (GameEnum.handbookType).SKIN then
      (table.insert)(tbBoardChar, handbookData)
    end
  end
  if #tbBoardChar > 0 then
    local nRandomIndex = (math.random)(1, #tbBoardChar)
    local boardData = tbBoardChar[nRandomIndex]
    if boardData ~= nil then
      return boardData:GetCharId(), boardData:GetSkinId()
    end
  else
    do
      local ownedChar = (PlayerData.Char):GetDataForCharList()
      local tbAllChar = {}
      for _,v in pairs(ownedChar) do
        local mapCfg = (ConfigTable.GetData_Character)(v.nId)
        if mapCfg ~= nil and mapCfg.Visible then
          (table.insert)(tbAllChar, v)
        end
      end
      local nRandomIndex = (math.random)(1, #tbAllChar)
      local charData = tbAllChar[nRandomIndex]
      if charData ~= nil then
        return charData.nId, (PlayerData.Char):GetCharUsedSkinId(charData.nId)
      end
    end
  end
end

PlayerBoardData.GetNPCDefaultSkinId = function(self, nNPCId)
  -- function num : 0_31 , upvalues : _ENV
  local tbNPCCfg = (ConfigTable.GetData)("BoardNPC", nNPCId)
  if tbNPCCfg == nil then
    printError("读取BoardNPC表格失败！！！NPCId = " .. nNPCId)
    return 
  end
  return tbNPCCfg.DefaultSkinId
end

PlayerBoardData.GetNPCUsingSkinId = function(self, nNPCId)
  -- function num : 0_32
  return self:GetNPCDefaultSkinId(nNPCId)
end

PlayerBoardData.ChooseBoardList = function(self)
  -- function num : 0_33 , upvalues : _ENV
  local tbHandBook = (PlayerData.Handbook):GetAllHandbookData()
  local tbAllCharHandBook = {}
  for _,v in pairs(tbHandBook) do
    if v:GetType() == (GameEnum.handbookType).SKIN and v:CheckUnlock() then
      (table.insert)(tbAllCharHandBook, v)
    end
  end
  local remaining = #tbAllCharHandBook
  local tbResult = {}
  for i = 1, (math.min)(remaining, 5) do
    local index = (math.random)(1, remaining)
    ;
    (table.insert)(tbResult, (tbAllCharHandBook[index]):GetId())
    tbAllCharHandBook[index] = tbAllCharHandBook[remaining]
    remaining = remaining - 1
  end
  local msgData = {Ids = tbResult}
  self.tbTmpSelectBoardList = tbResult
  local callbackFunc = function()
    -- function num : 0_33_0 , upvalues : self, _ENV
    local nSelectId = self:GetBoardPanelSelectId()
    for k,v in ipairs(self.tbSelectBoardList) do
      if v == nSelectId then
        self.nCurBoardIdx = k
        break
      end
    end
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_board_set_req, msgData, nil, callbackFunc)
end

return PlayerBoardData

