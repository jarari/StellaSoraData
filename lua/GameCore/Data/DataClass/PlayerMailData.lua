local PlayerMailData = class("PlayerMailData")
local TimerManager = require("GameCore.Timer.TimerManager")
PlayerMailData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.bisNew = false
  ;
  (EventManager.Add)(EventId.UpdateWorldClass, self, self.UpdateWorldClass)
  self._mapMail = {}
  self.bNeedUpdate = true
  self.funcCallBack = nil
  self.isOpen = false
  self.delayCallOpen = nil
  self.bInitRedDot = false
  self:StopDeadLineTimer()
end

PlayerMailData.HandleDefaultMail = function(self, tab)
  -- function num : 0_1 , upvalues : _ENV
  local id = tab.Id
  local dMsg = (ConfigTable.GetData)("MailTemplate", tab.TemplateId)
  if dMsg ~= nil then
    if tab.Subject == nil or tab.Subject == "" then
      tab.Subject = dMsg.Subject
    end
    if tab.Desc == nil or tab.Desc == "" then
      tab.Desc = dMsg.Desc
    end
    if tab.Author == nil or tab.Author == "" then
      tab.Author = dMsg.Author
    end
    if (tab.Attachments == nil or #tab.Attachments == 0) and tab.Read then
      tab.Recv = true
    end
    tab.Icon = dMsg.Icon
    tab.LetterPaper = dMsg.LetterPaper
  end
  return tab
end

PlayerMailData.CacheMailData = function(self, mapData)
  -- function num : 0_2 , upvalues : _ENV
  self.bNeedUpdate = false
  self.bisNew = false
  self._mapMail = {}
  if mapData == nil then
    self:RunCallBack()
    self:StopDeadLineTimer()
  else
    if mapData.List == nil then
      self:RunCallBack()
      self:StopDeadLineTimer()
      return 
    end
    for _,mapMail in ipairs(mapData.List) do
      -- DECOMPILER ERROR at PC28: Confused about usage of register: R7 in 'UnsetPending'

      if mapMail.TemplateId == 0 then
        (self._mapMail)[mapMail.Id] = mapMail
      else
        local _data = self:HandleDefaultMail(mapMail)
        -- DECOMPILER ERROR at PC35: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self._mapMail)[mapMail.Id] = _data
      end
    end
    self:RunCallBack()
    self:StartDeadLineTimer()
  end
  if not self.bInitRedDot then
    self.bInitRedDot = true
  end
  self:UpdateMailUnReceiveRedDot()
end

PlayerMailData.UpdateMailRed = function(self, isNew)
  -- function num : 0_3 , upvalues : _ENV
  self.bisNew = isNew
  if (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).Mail) and isNew then
    (RedDotManager.SetValid)(RedDotDefine.Mail_UnRead, nil, true)
  end
  self.bisNew = false
end

PlayerMailData.UpdateWorldClass = function(self)
  -- function num : 0_4 , upvalues : _ENV
  if (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).Mail) then
    (RedDotManager.SetValid)(RedDotDefine.Mail_UnRead, nil, self.bisNew)
    self.bisNew = false
  end
end

PlayerMailData.UpdateMailList = function(self, mapMsgData)
  -- function num : 0_5 , upvalues : _ENV
  self.bisNew = true
  self.bNeedUpdate = true
  if (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).Mail) and mapMsgData.New then
    (RedDotManager.SetValid)(RedDotDefine.Mail_New, nil, true)
  end
  ;
  (EventManager.Hit)("GetAllMailList")
end

PlayerMailData.ReceiveMailItem = function(self, mapData)
  -- function num : 0_6 , upvalues : _ENV
  local tabItem = {}
  local tmpTab = {}
  if type(mapData.Ids) == "table" then
    for i = 1, #mapData.Ids do
      -- DECOMPILER ERROR at PC22: Confused about usage of register: R8 in 'UnsetPending'

      if (self._mapMail)[(mapData.Ids)[i]] ~= nil then
        ((self._mapMail)[(mapData.Ids)[i]]).Read = true
        -- DECOMPILER ERROR at PC27: Confused about usage of register: R8 in 'UnsetPending'

        ;
        ((self._mapMail)[(mapData.Ids)[i]]).Recv = true
        if ((self._mapMail)[(mapData.Ids)[i]]).Attachments and #((self._mapMail)[(mapData.Ids)[i]]).Attachments > 0 then
          for k,v in pairs(((self._mapMail)[(mapData.Ids)[i]]).Attachments) do
            local itemCfg = (ConfigTable.GetData)("Item", v.Tid)
            if itemCfg ~= nil and itemCfg.Type ~= (GameEnum.itemType).CharacterSkin then
              if tmpTab[v.Tid] == nil then
                tmpTab[v.Tid] = v.Qty
              else
                tmpTab[v.Tid] = tmpTab[v.Tid] + v.Qty
              end
            end
          end
        end
      end
    end
    for i,v in pairs(tmpTab) do
      (table.insert)(tabItem, {Tid = i, Qty = v})
    end
    ;
    (UTILS.OpenReceiveByDisplayItem)(tabItem, mapData.Items, function()
    -- function num : 0_6_0 , upvalues : _ENV
    (PlayerData.Base):TryOpenWorldClassUpgrade()
  end
)
  end
  self:RunCallBack()
  self:UpdateMailUnReceiveRedDot()
end

PlayerMailData.ReadMail = function(self, mapMsgData)
  -- function num : 0_7
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R2 in 'UnsetPending'

  if (self._mapMail)[mapMsgData.Value] ~= nil then
    ((self._mapMail)[mapMsgData.Value]).Read = true
    -- DECOMPILER ERROR at PC25: Confused about usage of register: R2 in 'UnsetPending'

    if ((self._mapMail)[mapMsgData.Value]).Attachments == nil or #((self._mapMail)[mapMsgData.Value]).Attachments == 0 then
      ((self._mapMail)[mapMsgData.Value]).Recv = true
    end
  end
  self:RunCallBack()
end

PlayerMailData.RemoveMail = function(self, mapData)
  -- function num : 0_8 , upvalues : _ENV
  if type(mapData.Ids) == "table" then
    for i = 1, #mapData.Ids do
      -- DECOMPILER ERROR at PC19: Confused about usage of register: R6 in 'UnsetPending'

      if (self._mapMail)[(mapData.Ids)[i]] ~= nil then
        (self._mapMail)[(mapData.Ids)[i]] = nil
      end
    end
  end
  do
    local wait = function()
    -- function num : 0_8_0 , upvalues : _ENV, self
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    self:RunCallBack()
  end

    ;
    (cs_coroutine.start)(wait)
  end
end

PlayerMailData.GetAgainAllMain = function(self)
  -- function num : 0_9 , upvalues : _ENV
  local fCb = function()
    -- function num : 0_9_0 , upvalues : _ENV
    (EventManager.Hit)("OnEvent_RefrushMailGroup")
  end

  self.funcCallBack = fCb
  self:SengMsgMailList()
end

PlayerMailData.SengMsgMailList = function(self, callback)
  -- function num : 0_10 , upvalues : _ENV
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mail_list_req, {}, nil, callback)
end

PlayerMailData.RefreshMailRedDot = function(self, mapMsgData)
  -- function num : 0_11 , upvalues : _ENV
  if (PlayerData.Base):CheckFunctionUnlock((GameEnum.OpenFuncType).Mail) and mapMsgData.New then
    (RedDotManager.SetValid)(RedDotDefine.Mail_New, nil, true)
  end
end

PlayerMailData.GetAllMail = function(self, func_callBack, isOpen)
  -- function num : 0_12
  if func_callBack then
    self.funcCallBack = func_callBack
  end
  self.isOpen = isOpen
  if self.bNeedUpdate then
    self:SengMsgMailList()
  else
    self:RunCallBack()
  end
end

PlayerMailData.RunCallBack = function(self)
  -- function num : 0_13 , upvalues : _ENV, TimerManager
  if self.funcCallBack then
    (self.funcCallBack)()
    self.funcCallBack = nil
  end
  if self.isOpen then
    local func = function()
    -- function num : 0_13_0 , upvalues : _ENV
    (EventManager.Hit)(EventId.OpenPanel, PanelId.Mail)
  end

    ;
    (EventManager.Hit)(EventId.SetTransition, 5, func)
    self.isOpen = false
    local time = ((CS.ClientManager).Instance).serverTimeStamp
    local hour = tonumber((os.date)("%H", time))
    local minute = tonumber((os.date)("%M", time))
    local second = tonumber((os.date)("%S", time))
    local delaySec = 100800 - hour * 3600 - minute * 60 - second
    self.delayCallOpen = (TimerManager.Add)(1, delaySec, self, self.DelayTimeCallMsg, true, true, false)
  end
end

PlayerMailData.CheckMailDeadLine = function(self)
  -- function num : 0_14 , upvalues : _ENV
  local bNeedRefresh = false
  for id,v in pairs(self._mapMail) do
    if v.Deadline ~= 0 and not (self.tbDeadLineCheckList)[id] then
      local remainTime = v.Deadline - ((CS.ClientManager).Instance).serverTimeStamp
      -- DECOMPILER ERROR at PC21: Confused about usage of register: R8 in 'UnsetPending'

      if remainTime <= 0 then
        (self.tbDeadLineCheckList)[id] = true
        bNeedRefresh = true
        break
      end
    end
  end
  do
    if bNeedRefresh then
      self:UpdateMailUnReceiveRedDot()
      ;
      (EventManager.Hit)("GetAllMailList")
    end
  end
end

PlayerMailData.StartDeadLineTimer = function(self)
  -- function num : 0_15 , upvalues : TimerManager
  if self.timerMailDeadLine == nil then
    self.timerMailDeadLine = (TimerManager.Add)(0, 10, self, self.CheckMailDeadLine, true, true, false)
  end
end

PlayerMailData.StopDeadLineTimer = function(self)
  -- function num : 0_16 , upvalues : TimerManager
  if self.timerMailDeadLine ~= nil then
    (TimerManager.Remove)(self.timerMailDeadLine, false)
  end
  self.timerMailDeadLine = nil
  self.tbDeadLineCheckList = {}
end

PlayerMailData.DelayTimeCallMsg = function(self)
  -- function num : 0_17 , upvalues : _ENV, TimerManager
  do
    if self.bNeedUpdate then
      local cb = function()
    -- function num : 0_17_0 , upvalues : _ENV
    (EventManager.Hit)(EventId.RefrushMailView)
  end

      self:GetAllMail(cb, false)
    end
    self:CancelTimeDelay()
    local time = ((CS.ClientManager).Instance).serverTimeStamp
    local hour = tonumber((os.date)("%H", time))
    local minute = tonumber((os.date)("%M", time))
    local second = tonumber((os.date)("%S", time))
    local delaySec = 100800 - hour * 3600 - minute * 60 - second
    self.delayCallOpen = (TimerManager.Add)(1, delaySec, self, self.DelayTimeCallMsg, true, true, false)
  end
end

PlayerMailData.SendMailRecvReq = function(self, id, flag, callback)
  -- function num : 0_18 , upvalues : _ENV
  if callback then
    self.funcCallBack = callback
  end
  local skinCachClearCb = function(_, mapMsgData)
    -- function num : 0_18_0 , upvalues : _ENV, callback
    (PlayerData.CharSkin):TryOpenSkinShowPanel(function()
      -- function num : 0_18_0_0 , upvalues : _ENV, mapMsgData
      (PlayerData.Mail):ReceiveMailItem(mapMsgData)
    end
)
    if callback then
      callback()
    end
  end

  local sendMsgBody = {Id = id, Flag = flag}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mail_recv_req, sendMsgBody, nil, skinCachClearCb)
end

PlayerMailData.SendMailGetSurveryMsg = function(self, id, callback)
  -- function num : 0_19 , upvalues : _ENV
  if callback then
    self.funcCallBack = callback
  end
  local sendMsgBody = {SurveyId = id}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).player_survey_req, sendMsgBody, nil, callback)
end

PlayerMailData.SendMailReadReq = function(self, id, flag, callback)
  -- function num : 0_20 , upvalues : _ENV
  local sendMsgBody = {Id = id, Flag = flag}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mail_read_req, sendMsgBody, nil, callback)
end

PlayerMailData.SendMailRemoveReq = function(self, id, flag, callback)
  -- function num : 0_21 , upvalues : _ENV
  if callback then
    self.funcCallBack = callback
  end
  local sendMsgBody = {Id = id, Flag = flag}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mail_remove_req, sendMsgBody, nil, callback)
end

PlayerMailData.SendMailPin = function(self, id, flag, isPin, callback)
  -- function num : 0_22 , upvalues : _ENV
  local sendMsgBody = {Id = id, Flag = flag, Pin = isPin}
  local cb = function(_, mapMsgData)
    -- function num : 0_22_0 , upvalues : self, callback
    -- DECOMPILER ERROR at PC4: Confused about usage of register: R2 in 'UnsetPending'

    ((self._mapMail)[mapMsgData.Id]).Flag = mapMsgData.Flag
    -- DECOMPILER ERROR at PC9: Confused about usage of register: R2 in 'UnsetPending'

    ;
    ((self._mapMail)[mapMsgData.Id]).Pin = mapMsgData.Pin
    callback()
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).mail_pin_req, sendMsgBody, nil, cb)
end

PlayerMailData.CancelTimeDelay = function(self)
  -- function num : 0_23
  if self.delayCallOpen then
    (self.delayCallOpen):Cancel(nil)
    self.delayCallOpen = nil
  end
end

PlayerMailData.ClearFunCallBack = function(self)
  -- function num : 0_24
  if self.funcCallBack then
    self.funcCallBack = nil
  end
end

PlayerMailData.UpdateMailUnReadRedDot = function(self)
  -- function num : 0_25 , upvalues : _ENV
  local bUnRead = false
  for _,mail in pairs(self._mapMail) do
    if not mail.Read then
      bUnRead = true
      break
    end
  end
  do
    ;
    (RedDotManager.SetValid)(RedDotDefine.Mail_UnRead, nil, bUnRead)
  end
end

PlayerMailData.UpdateMailUnReceiveRedDot = function(self)
  -- function num : 0_26 , upvalues : _ENV
  local nUnReceive = false
  for _,mail in pairs(self._mapMail) do
    if (mail.Deadline == 0 or ((CS.ClientManager).Instance).serverTimeStamp < mail.Deadline) and mail.Attachments and #mail.Attachments > 0 and not mail.Recv then
      nUnReceive = true
      break
    end
  end
  do
    ;
    (RedDotManager.SetValid)(RedDotDefine.Mail_UnReceive, nil, nUnReceive)
  end
end

return PlayerMailData

