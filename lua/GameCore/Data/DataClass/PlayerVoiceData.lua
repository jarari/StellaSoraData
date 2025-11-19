local PlayerVoiceData = class("PlayerVoiceData")
local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
local TimerManager = require("GameCore.Timer.TimerManager")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local ClientManager = (CS.ClientManager).Instance
local LocalData = require("GameCore.Data.LocalData")
local TN = (AllEnum.Actor2DType).Normal
local TF = (AllEnum.Actor2DType).FullScreen
local board_click_time = (ConfigTable.GetConfigNumber)("HFCtimer")
local board_click_max_count = (ConfigTable.GetConfigNumber)("HFCcounter")
local board_click_free_time = (ConfigTable.GetConfigNumber)("Hangtimer")
local npc_board_click_time = (ConfigTable.GetConfigNumber)("NpcHFCtimer")
local npc_board_click_max_count = (ConfigTable.GetConfigNumber)("NpcHFCcounter")
local npc_board_click_free_time = (ConfigTable.GetConfigNumber)("NpcHangtimer")
local board_free_trigger_none = 0
local board_free_trigger_hang = 1
local board_free_trigger_ex_hang = 2
local charFavorLevelClickVoice = {
[1] = {nLevel = 10, sClickVoiceKey = "affchat1"}
, 
[2] = {nLevel = 15, sClickVoiceKey = "affchat2"}
, 
[3] = {nLevel = 20, sClickVoiceKey = "affchat3"}
, 
[4] = {nLevel = 25, sClickVoiceKey = "affchat4"}
, 
[5] = {nLevel = 30, sClickVoiceKey = "affchat5"}
}
local charFavorLevelUnlockVoice = {
{nLevel = 10, sUnlockVoiceKey = "afflv1"}
, 
{nLevel = 15, sUnlockVoiceKey = "afflv2"}
, 
{nLevel = 25, sUnlockVoiceKey = "afflv3"}
, 
{nLevel = 30, sUnlockVoiceKey = "afflv4"}
}
local voiceRandomSkinLimit = {"posterchat"}
PlayerVoiceData.Init = function(self)
  -- function num : 0_0 , upvalues : board_free_trigger_none, _ENV
  self.bFirstEnterGame = true
  self.bNpc = false
  self.nNpcId = 0
  self.bStartBoardClickTimer = false
  self.nContinuousClickCount = 0
  self.nBoardClickTime = 0
  self.nBoardFreeTime = 0
  self.nVoiceDuration = 0
  self.nCurVoiceId = nil
  self.nTriggerFreeVoiceState = board_free_trigger_none
  self.boardClickTimer = nil
  self.boardFreeTimer = nil
  self.boardPlayTimer = nil
  self.tbHolidayVoice = {}
  self.tbHolidayVoiceKey = {}
  ;
  (EventManager.Add)(EventId.UIOperate, self, self.OnEvent_UIOperate)
  ;
  (EventManager.Add)(EventId.AvgVoiceDuration, self, self.OnEvent_AvgVoiceDuration)
  ;
  (EventManager.Add)(EventId.IsNewDay, self, self.OnEvent_NewDay)
  self:InitConfig()
end

PlayerVoiceData.UnInit = function(self)
  -- function num : 0_1 , upvalues : _ENV
  (EventManager.Remove)(EventId.UIOperate, self, self.OnEvent_UIOperate)
  ;
  (EventManager.Remove)(EventId.AvgVoiceDuration, self, self.OnEvent_AvgVoiceDuration)
  ;
  (EventManager.Remove)(EventId.IsNewDay, self, self.OnEvent_NewDay)
end

PlayerVoiceData.InitConfig = function(self)
  -- function num : 0_2 , upvalues : _ENV
  local foreachVoiceControl = function(line)
    -- function num : 0_2_0 , upvalues : _ENV, self
    if line.dateTrigger and line.date ~= "" then
      local tbParam = (string.split)(line.date, ".")
      local year, month, day = 0, nil, nil
      if #tbParam == 3 then
        year = tonumber(tbParam[1])
        month = tonumber(tbParam[2])
        day = tonumber(tbParam[3])
      else
        month = tonumber(tbParam[1])
        day = tonumber(tbParam[2])
      end
      ;
      (table.insert)(self.tbHolidayVoice, {voiceKey = line.Id, 
date = {year = year, month = month, day = day}
})
    end
  end

  ForEachTableLine((ConfigTable.Get)("CharacterVoiceControl"), foreachVoiceControl)
end

PlayerVoiceData.PlayCharVoice = function(self, voiceKey, nCharId, nSkinId, bNpc)
  -- function num : 0_3 , upvalues : _ENV, WwiseAudioMgr
  if voiceKey ~= nil then
    local tbVoiceKey = {}
    if type(voiceKey) ~= "table" then
      (table.insert)(tbVoiceKey, voiceKey)
    else
      tbVoiceKey = voiceKey
    end
    if not nSkinId then
      nSkinId = 0
    end
    -- DECOMPILER ERROR at PC29: Unhandled construct in 'MakeBoolean' P1

    if nCharId ~= 0 and nSkinId == 0 then
      if bNpc then
        local mapNpcCfg = (ConfigTable.GetData)("BoardNPC", nCharId)
        if mapNpcCfg ~= nil then
          nSkinId = mapNpcCfg.DefaultSkinId
        end
      else
        do
          nSkinId = (PlayerData.Char):GetCharSkinId(nCharId)
          nSkinId = 0
          local nVoiceId = WwiseAudioMgr:WwiseVoice_Play(nCharId, tbVoiceKey, nil, nSkinId)
          if nVoiceId ~= nil and nVoiceId ~= 0 then
            self.nCurVoiceId = nVoiceId
          end
          do return nVoiceId end
        end
      end
    end
  end
end

PlayerVoiceData.StopCharVoice = function(self)
  -- function num : 0_4 , upvalues : _ENV, WwiseAudioMgr
  if self.nCurVoiceId ~= nil and self.nCurVoiceId ~= 0 then
    local mapVoDirectoryData = (ConfigTable.GetData)("VoDirectory", self.nCurVoiceId)
    do
      if mapVoDirectoryData ~= nil then
        local tbCfg = (ConfigTable.GetData)("CharacterVoiceControl", mapVoDirectoryData.votype)
        if tbCfg ~= nil then
          WwiseAudioMgr:WwiseVoice_Stop(tbCfg.voPlayer - 1)
        end
      end
      self.nCurVoiceId = 0
    end
  end
end

PlayerVoiceData.CheckHoliday = function(self)
  -- function num : 0_5 , upvalues : ClientManager, _ENV
  self.tbHolidayVoiceKey = {}
  local nServerTimeStamp = ClientManager.serverTimeStamp
  local nYear = tonumber((os.date)("%Y", nServerTimeStamp))
  local nMonth = tonumber((os.date)("%m", nServerTimeStamp))
  local nDay = tonumber((os.date)("%d", nServerTimeStamp))
  for _,v in ipairs(self.tbHolidayVoice) do
    -- DECOMPILER ERROR at PC48: Unhandled construct in 'MakeBoolean' P1

    if (v.date).year ~= 0 and (v.date).year == nYear and (v.date).month == nMonth and (v.date).day == nDay then
      (table.insert)(self.tbHolidayVoiceKey, v.voiceKey)
    end
    if (v.date).month == nMonth and (v.date).day == nDay then
      (table.insert)(self.tbHolidayVoiceKey, v.voiceKey)
    end
  end
end

PlayerVoiceData.CheckBirthday = function(self)
  -- function num : 0_6 , upvalues : ClientManager, _ENV
  local nServerTimeStamp = ClientManager.serverTimeStamp
  local nYear = tonumber((os.date)("%Y", nServerTimeStamp))
  local nMonth = tonumber((os.date)("%m", nServerTimeStamp))
  local nDay = tonumber((os.date)("%d", nServerTimeStamp))
  local curBoardCharId = (PlayerData.Board):GetCurBoardCharID()
  local mapCharDesc = (ConfigTable.GetData)("CharacterDes", curBoardCharId)
  do
    if mapCharDesc ~= nil and mapCharDesc.Birthday ~= "" then
      local tbParam = (string.split)(mapCharDesc.Birthday, ".")
      -- DECOMPILER ERROR at PC60: Unhandled construct in 'MakeBoolean' P1

      if #tbParam == 3 and nYear == tonumber(tbParam[1]) and nMonth == tonumber(tbParam[2]) and nDay == tonumber(tbParam[3]) then
        return true
      end
    end
    if nMonth == tonumber(tbParam[1]) and nDay == tonumber(tbParam[2]) then
      return true
    end
    return false
  end
end

local getBoardClickTime = function(bNpc)
  -- function num : 0_7 , upvalues : npc_board_click_time, board_click_time
  return bNpc and npc_board_click_time or board_click_time
end

local getBoardClickMaxCount = function(bNpc)
  -- function num : 0_8 , upvalues : npc_board_click_max_count, board_click_max_count
  return bNpc and npc_board_click_max_count or board_click_max_count
end

local getBoardClickFreeTime = function(bNpc)
  -- function num : 0_9 , upvalues : npc_board_click_free_time, board_click_free_time
  return bNpc and npc_board_click_free_time or board_click_free_time
end

PlayerVoiceData.StartBoardFreeTimer = function(self, nNpcId)
  -- function num : 0_10 , upvalues : board_free_trigger_ex_hang, TimerManager
  if nNpcId ~= nil or self.bNpc then
    self.bNpc = true
    if not nNpcId then
      self.nNpcId = nNpcId == nil or 0
      self.bNpc = false
      self.nNpcId = 0
      self.bStartBoardClickTimer = true
      if self.boardFreeTimer == nil and self.nTriggerFreeVoiceState ~= board_free_trigger_ex_hang then
        self.boardFreeTimer = (TimerManager.Add)(0, 0.1, self, self.CheckBoardFree, true, true, false)
      end
    end
  end
end

PlayerVoiceData.CheckBoardFree = function(self)
  -- function num : 0_11 , upvalues : getBoardClickFreeTime, board_free_trigger_none, board_free_trigger_hang, board_free_trigger_ex_hang
  self.nBoardFreeTime = self.nBoardFreeTime + 0.1
  if getBoardClickFreeTime(self.bNpc) <= self.nBoardFreeTime then
    self:ResetBoardFreeTimer()
    if self.nTriggerFreeVoiceState == board_free_trigger_none then
      self.nTriggerFreeVoiceState = board_free_trigger_hang
      self:PlayBoardFreeVoice()
    else
      if self.nTriggerFreeVoiceState == board_free_trigger_hang then
        self.nTriggerFreeVoiceState = board_free_trigger_ex_hang
        self:PlayBoardFreeLongTimeVoice()
      end
    end
  end
end

PlayerVoiceData.ResetBoardFreeTimer = function(self)
  -- function num : 0_12 , upvalues : TimerManager
  if self.boardFreeTimer ~= nil then
    (TimerManager.Remove)(self.boardFreeTimer, false)
  end
  self.boardFreeTimer = nil
  self.nBoardFreeTime = 0
end

PlayerVoiceData.StartBoardPlayTimer = function(self)
  -- function num : 0_13 , upvalues : TimerManager
  if self.boardPlayTimer == nil then
    self.boardPlayTimer = (TimerManager.Add)(1, self.nVoiceDuration, nil, function()
    -- function num : 0_13_0 , upvalues : self
    self:StartBoardFreeTimer()
  end
, true, true, false)
  end
end

PlayerVoiceData.ResetBoardPlayTimer = function(self)
  -- function num : 0_14 , upvalues : TimerManager
  if self.boardPlayTimer ~= nil then
    (TimerManager.Remove)(self.boardPlayTimer, false)
  end
  self.boardPlayTimer = nil
  self.nVoiceDuration = 0
end

PlayerVoiceData.PlayBoardSelectVoice = function(self, nCharId)
  -- function num : 0_15
  local sVoiceKey = "greet"
  self:PlayCharVoice(sVoiceKey, nCharId)
end

PlayerVoiceData.PlayMainViewOpenVoice = function(self)
  -- function num : 0_16 , upvalues : _ENV, ClientManager
  local curBoardCharId = (PlayerData.Board):GetCurBoardCharID()
  self:CheckHoliday()
  local bPlayFirst = false
  local tbVoiceKey = {}
  if curBoardCharId ~= nil then
    local nServerTimeStamp = ClientManager.serverTimeStamp
    local nHour = tonumber((os.date)("%H", nServerTimeStamp))
    local getIndex = function(nHour)
    -- function num : 0_16_0
    if nHour >= 6 and nHour < 12 then
      return 1, "greetmorn"
    else
      if nHour >= 12 and nHour < 18 then
        return 2, "greetnoon"
      else
        return 3, "greetnight"
      end
    end
  end

    local nIndex, sKey = getIndex(nHour)
    if self.bFirstEnterGame == true then
      tbVoiceKey = {sKey}
      self.bFirstEnterGame = false
    else
      tbVoiceKey = {sKey, "greet"}
    end
    if #self.tbHolidayVoiceKey > 0 then
      for _,v in ipairs(self.tbHolidayVoiceKey) do
        (table.insert)(tbVoiceKey, v)
      end
    end
    do
      if self:CheckBirthday() then
        (table.insert)(tbVoiceKey, "birth")
      end
      self:PlayCharVoice(tbVoiceKey, curBoardCharId)
    end
  end
end

PlayerVoiceData.CheckContinuousClick = function(self)
  -- function num : 0_17 , upvalues : getBoardClickTime
  self.nBoardClickTime = self.nBoardClickTime + 0.1
  local nTime = getBoardClickTime(self.bNpc)
  if nTime < self.nBoardClickTime then
    self:ResetBoardClickTimer()
  end
end

PlayerVoiceData.ResetBoardClickTimer = function(self)
  -- function num : 0_18 , upvalues : TimerManager
  if self.boardClickTimer ~= nil then
    (TimerManager.Remove)(self.boardClickTimer, false)
  end
  self.boardClickTimer = nil
  self.nBoardClickTime = 0
  self.nContinuousClickCount = 0
end

PlayerVoiceData.PlayBoardClickVoice = function(self)
  -- function num : 0_19 , upvalues : TimerManager, _ENV, getBoardClickMaxCount, Actor2DManager, TN, TF, charFavorLevelClickVoice
  self.bNpc = false
  self.nNpcId = 0
  if self.nBoardClickTime == 0 and self.boardClickTimer == nil then
    self.boardClickTimer = (TimerManager.Add)(0, 0.1, self, self.CheckContinuousClick, true, true, false)
  end
  self.nContinuousClickCount = self.nContinuousClickCount + 1
  local curBoardCharId = (PlayerData.Board):GetCurBoardCharID()
  if curBoardCharId ~= nil then
    local tbVoiceKey = {}
    if getBoardClickMaxCount(self.bNpc) < self.nContinuousClickCount then
      (table.insert)(tbVoiceKey, "hfc")
      self:ResetBoardClickTimer()
    else
      ;
      (table.insert)(tbVoiceKey, "posterchat")
      local curActor2DType = (Actor2DManager.GetCurrentActor2DType)()
      if curActor2DType == TN then
        (table.insert)(tbVoiceKey, "standee")
      else
        if curActor2DType == TF then
          (table.insert)(tbVoiceKey, "fullscreen")
        end
      end
      local mapData = (PlayerData.Char):GetCharAffinityData(curBoardCharId)
      if mapData ~= nil then
        local nLevel = mapData.Level
        for _,v in ipairs(charFavorLevelClickVoice) do
          if v.nLevel <= nLevel then
            (table.insert)(tbVoiceKey, v.sClickVoiceKey)
          end
        end
      end
    end
    do
      if #self.tbHolidayVoiceKey > 0 then
        for _,v in ipairs(self.tbHolidayVoiceKey) do
          (table.insert)(tbVoiceKey, R10_PC100)
        end
      end
      do
        if self:CheckBirthday() then
          (table.insert)(tbVoiceKey, "birth")
        end
        local nVoiceId = self:PlayCharVoice(tbVoiceKey, curBoardCharId)
        if nVoiceId ~= nil and nVoiceId ~= 0 then
          (PlayerData.Quest):SendClientEvent((GameEnum.questCompleteCondClient).InteractL2D)
        end
      end
    end
  end
end

PlayerVoiceData.PlayBoardNPCClickVoice = function(self, nNpcId)
  -- function num : 0_20 , upvalues : TimerManager, getBoardClickMaxCount, _ENV
  self.bNpc = true
  self.nNpcId = nNpcId
  if self.nBoardClickTime == 0 and self.boardClickTimer == nil then
    self.boardClickTimer = (TimerManager.Add)(0, 0.1, self, self.CheckContinuousClick, true, true, false)
  end
  self.nContinuousClickCount = self.nContinuousClickCount + 1
  local curBoardCharId = nNpcId
  if curBoardCharId ~= nil then
    local tbVoiceKey = {}
    if getBoardClickMaxCount(self.bNpc) < self.nContinuousClickCount then
      (table.insert)(tbVoiceKey, "hfc_npc")
      self:ResetBoardClickTimer()
    else
      ;
      (table.insert)(tbVoiceKey, "posterchat_npc")
    end
    self:PlayCharVoice(tbVoiceKey, curBoardCharId, nil, true)
  end
end

PlayerVoiceData.PlayBoardFreeVoice = function(self)
  -- function num : 0_21 , upvalues : _ENV
  local curBoardCharId, sVoiceKey = nil, nil
  if not self.bNpc then
    curBoardCharId = (PlayerData.Board):GetCurBoardCharID()
    sVoiceKey = "hang"
  else
    curBoardCharId = self.nNpcId
    sVoiceKey = "hang_npc"
  end
  if curBoardCharId ~= nil then
    self:PlayCharVoice(sVoiceKey, curBoardCharId)
  end
end

PlayerVoiceData.PlayBoardFreeLongTimeVoice = function(self)
  -- function num : 0_22 , upvalues : _ENV
  local curBoardCharId, sVoiceKey = nil, nil
  if not self.bNpc then
    curBoardCharId = (PlayerData.Board):GetCurBoardCharID()
    sVoiceKey = "exhang"
  else
    curBoardCharId = self.nNpcId
    sVoiceKey = "exhang_npc"
  end
  if curBoardCharId ~= nil then
    self:PlayCharVoice(sVoiceKey, curBoardCharId)
  end
end

PlayerVoiceData.PlayBattleResultVoice = function(self, tbChar, bWin)
  -- function num : 0_23 , upvalues : _ENV
  local nIndex = (math.random)(1, #tbChar)
  local nCharId = tbChar[nIndex]
  local sVoiceKey = bWin and "win" or "lose"
  self:PlayCharVoice(sVoiceKey, nCharId)
end

PlayerVoiceData.CheckPlayGiftVoice = function(self, nLevel, nLastLevel)
  -- function num : 0_24 , upvalues : charFavorLevelUnlockVoice
  local bPlay = true
  if nLastLevel ~= nLevel then
    for i = 1, #charFavorLevelUnlockVoice do
      if charFavorLevelUnlockVoice[i] ~= nil and nLastLevel < (charFavorLevelUnlockVoice[i]).nLevel and (charFavorLevelUnlockVoice[i]).nLevel <= nLevel then
        bPlay = false
        break
      end
    end
  end
  do
    return bPlay
  end
end

PlayerVoiceData.PlayCharFavourUpVoice = function(self, nCharId, nLastFavourLevel)
  -- function num : 0_25 , upvalues : _ENV, charFavorLevelUnlockVoice
  local nVoiceId = nil
  local mapData = (PlayerData.Char):GetCharAffinityData(nCharId)
  if mapData ~= nil then
    local nLevel = mapData.Level
    local sVoiceKey = ""
    for i = 1, #charFavorLevelUnlockVoice do
      if charFavorLevelUnlockVoice[i] ~= nil and nLastFavourLevel < (charFavorLevelUnlockVoice[i]).nLevel and (charFavorLevelUnlockVoice[i]).nLevel <= nLevel then
        sVoiceKey = (charFavorLevelUnlockVoice[i]).sUnlockVoiceKey
      end
    end
    if sVoiceKey ~= "" then
      nVoiceId = self:PlayCharVoice(sVoiceKey, nCharId)
    end
  end
  do
    return nVoiceId
  end
end

PlayerVoiceData.ClearTimer = function(self)
  -- function num : 0_26
  self:ResetBoardPlayTimer()
  self:ResetBoardFreeTimer()
  self:ResetBoardClickTimer()
  self.bStartBoardClickTimer = false
  self.bNpc = false
  self.nNpcId = 0
end

PlayerVoiceData.OnEvent_UIOperate = function(self)
  -- function num : 0_27 , upvalues : board_free_trigger_none
  self.nBoardFreeTime = 0
  self.nTriggerFreeVoiceState = board_free_trigger_none
  if self.bStartBoardClickTimer and self.nVoiceDuration == 0 then
    self:StartBoardFreeTimer()
  end
end

PlayerVoiceData.OnEvent_AvgVoiceDuration = function(self, nDuration)
  -- function num : 0_28 , upvalues : board_free_trigger_ex_hang
  self:ResetBoardPlayTimer()
  self.nVoiceDuration = nDuration
  if self.bStartBoardClickTimer and self.nTriggerFreeVoiceState ~= board_free_trigger_ex_hang then
    self:ResetBoardFreeTimer()
    self:StartBoardPlayTimer()
  end
end

PlayerVoiceData.OnEvent_NewDay = function(self)
  -- function num : 0_29
  self:CheckHoliday()
end

return PlayerVoiceData

