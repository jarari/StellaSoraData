local PlayerPhoneData = class("PlayerPhoneData")
local ModuleManager = require("GameCore.Module.ModuleManager")
local LocalData = require("GameCore.Data.LocalData")
PlayerPhoneData.Init = function(self)
  -- function num : 0_0 , upvalues : _ENV
  self.tbAddressBook = {}
  self.tbChatMsgCache = {}
  self.tbPhoneMsgChoiceTarget = {}
  self.tbPhoneMsgGroupData = {}
  self.tbHistoryMsg = {}
  self.tbHistorySelection = {}
  self.tbNewChatList = {}
  self.bInitChatData = false
  self:InitCfg()
  ;
  (EventManager.Add)(EventId.AfterEnterMain, self, self.OnEvent_AfterEnterMain)
end

PlayerPhoneData.InitCfg = function(self)
  -- function num : 0_1 , upvalues : _ENV
  local foreachPlot = function(mapData)
    -- function num : 0_1_0 , upvalues : _ENV
    if mapData.ConnectChatId ~= 0 then
      local tbData = {}
      tbData.sAvgId = mapData.AvgId
      tbData.nCharId = mapData.Char
      tbData.nPlotId = mapData.Id
      ;
      (CacheTable.SetData)("_PlotChat", mapData.ConnectChatId, tbData)
    end
  end

  ForEachTableLine(DataTable.Plot, foreachPlot)
end

PlayerPhoneData.CachePhoneMsgCount = function(self, msgNetData)
  -- function num : 0_2 , upvalues : _ENV
  if msgNetData.NewMessage <= 0 then
    (RedDotManager.SetValid)(RedDotDefine.Phone_New, nil, msgNetData == nil)
    do
      local bNewValue = (RedDotManager.GetValid)(RedDotDefine.Phone)
      ;
      (RedDotManager.SetValid)(RedDotDefine.Phone_UnComplete, nil, not bNewValue and msgNetData.ProgressMessage > 0)
      -- DECOMPILER ERROR: 4 unprocessed JMP targets
    end
  end
end

PlayerPhoneData.GetChatState = function(self, chatData)
  -- function num : 0_3 , upvalues : _ENV
  if chatData.nProcess == 0 then
    return (AllEnum.PhoneChatState).New
  else
    if chatData.nProcess < chatData.nAllProcess then
      return (AllEnum.PhoneChatState).UnComplete
    else
      if chatData.nAllProcess <= chatData.nProcess then
        return (AllEnum.PhoneChatState).Complete
      end
    end
  end
end

PlayerPhoneData.CreateNewChat = function(self, mapMsgData)
  -- function num : 0_4
  local chatData = {}
  chatData.nChatId = mapMsgData.Id
  chatData.nProcess = mapMsgData.Process
  chatData.tbSelection = mapMsgData.Options
  local chatAvgMsg = self:GetAVGPhoneMsg(chatData.nChatId)
  if chatAvgMsg == nil then
    return 
  end
  chatData.avgMsg = chatAvgMsg
  chatData.nAllProcess = #chatAvgMsg
  chatData.nStatus = self:GetChatState(chatData)
  if chatData.nProcess > 0 then
    self:ParseAvgHistoryPhoneMsgData(chatData.nChatId, chatData.avgMsg, chatData.nProcess, chatData.tbSelection)
  end
  return chatData
end

PlayerPhoneData.RefreshAddressStatus = function(self, nAddressId)
  -- function num : 0_5 , upvalues : _ENV
  local addressData = (self.tbAddressBook)[nAddressId]
  if addressData ~= nil then
    local bNew = false
    local bUnComplete = false
    for _,chat in pairs(addressData.tbChatList) do
      if chat.nStatus == (AllEnum.PhoneChatState).UnComplete then
        bUnComplete = true
        break
      else
        if chat.nStatus == (AllEnum.PhoneChatState).New then
          bNew = true
        end
      end
    end
    do
      if bUnComplete then
        addressData.nStatus = (AllEnum.PhoneChatState).UnComplete
      else
        if bNew then
          addressData.nStatus = (AllEnum.PhoneChatState).New
        else
          addressData.nStatus = (AllEnum.PhoneChatState).Complete
        end
      end
    end
  end
end

PlayerPhoneData.CacheAddressBookData = function(self, msgNetData)
  -- function num : 0_6 , upvalues : _ENV
  self.bInitChatData = true
  for _,v in ipairs(msgNetData) do
    local mapChar = (ConfigTable.GetData_Character)(v.CharId)
    -- DECOMPILER ERROR at PC22: Confused about usage of register: R8 in 'UnsetPending'

    if mapChar ~= nil and mapChar.Visible then
      if (self.tbAddressBook)[v.CharId] == nil then
        (self.tbAddressBook)[v.CharId] = {}
      end
      local tbChatList = {}
      for _,chat in ipairs(v.Chats) do
        local chatData = self:CreateNewChat(chat)
        if chatData ~= nil then
          tbChatList[chat.Id] = chatData
        end
      end
      -- DECOMPILER ERROR at PC40: Confused about usage of register: R9 in 'UnsetPending'

      ;
      ((self.tbAddressBook)[v.CharId]).tbChatList = tbChatList
      -- DECOMPILER ERROR at PC45: Confused about usage of register: R9 in 'UnsetPending'

      ;
      ((self.tbAddressBook)[v.CharId]).nTime = v.TriggerTime
      -- DECOMPILER ERROR at PC50: Confused about usage of register: R9 in 'UnsetPending'

      ;
      ((self.tbAddressBook)[v.CharId]).bTop = v.Top
      -- DECOMPILER ERROR at PC54: Confused about usage of register: R9 in 'UnsetPending'

      ;
      ((self.tbAddressBook)[v.CharId]).nOptTime = 0
      -- DECOMPILER ERROR at PC62: Confused about usage of register: R9 in 'UnsetPending'

      if v.nOptTime ~= nil then
        ((self.tbAddressBook)[v.CharId]).nOptTime = v.nOptTime
      end
      self:RefreshAddressStatus(v.CharId)
    end
  end
  self:RefreshRedDot()
end

PlayerPhoneData.RefreshChatProcess = function(self, nAddressId, nChatId, nProcess, tbSelection)
  -- function num : 0_7 , upvalues : _ENV
  local addressData = (self.tbAddressBook)[nAddressId]
  if addressData ~= nil then
    local tbChatList = addressData.tbChatList
    if tbChatList[nChatId] ~= nil then
      local chatData = tbChatList[nChatId]
      local lastProcess = chatData.nProcess
      chatData.nProcess = nProcess
      if tbSelection ~= nil then
        chatData.tbSelection = tbSelection
        local data = (chatData.avgMsg)[lastProcess]
        if not tonumber((data.param)[1]) then
          local nGroupId = data == nil or data.cmd ~= "SetPhoneMsgChoiceBegin" or 0
        end
        -- DECOMPILER ERROR at PC37: Confused about usage of register: R11 in 'UnsetPending'

        if nGroupId == #tbSelection then
          if (self.tbHistorySelection)[nChatId] == nil then
            (self.tbHistorySelection)[nChatId] = {}
          else
            for k,v in pairs((self.tbHistorySelection)[nChatId]) do
              if v.groupID == (data.param)[1] then
                (table.remove)((self.tbHistorySelection)[nChatId], k)
                break
              end
            end
          end
          do
            do
              do
                do
                  local dataSelection = {groupID = (data.param)[1], choiceIndex = tostring(tbSelection[#tbSelection])}
                  ;
                  (table.insert)((self.tbHistorySelection)[nChatId], dataSelection)
                  chatData.nStatus = self:GetChatState(chatData)
                  self:UpdateHistoryPhoneMsgData(nChatId, (chatData.avgMsg)[nProcess], nProcess)
                  self:RefreshAddressStatus(nAddressId)
                  self:RefreshRedDot()
                end
              end
            end
          end
        end
      end
    end
  end
end

PlayerPhoneData.NewChatTrigger = function(self, mapMsgData)
  -- function num : 0_8 , upvalues : _ENV, ModuleManager
  local nChatId = mapMsgData.Value
  local tbData = {Id = nChatId, 
Options = {}
, Process = 0}
  local chatCfg = (ConfigTable.GetData)("Chat", nChatId)
  if chatCfg ~= nil then
    local nAddressId = chatCfg.AddressBookId
    local mapChar = (ConfigTable.GetData_Character)(nAddressId)
    -- DECOMPILER ERROR at PC29: Confused about usage of register: R7 in 'UnsetPending'

    if mapChar ~= nil and mapChar.Visible then
      if (self.tbAddressBook)[nAddressId] == nil then
        (self.tbAddressBook)[nAddressId] = {}
        -- DECOMPILER ERROR at PC33: Confused about usage of register: R7 in 'UnsetPending'

        ;
        ((self.tbAddressBook)[nAddressId]).tbChatList = {}
      end
      local chatData = self:CreateNewChat(tbData)
      -- DECOMPILER ERROR at PC42: Confused about usage of register: R8 in 'UnsetPending'

      if chatData ~= nil then
        (((self.tbAddressBook)[nAddressId]).tbChatList)[nChatId] = chatData
      end
      -- DECOMPILER ERROR at PC49: Confused about usage of register: R8 in 'UnsetPending'

      ;
      ((self.tbAddressBook)[nAddressId]).nTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
      self:RefreshAddressStatus(nAddressId)
      self:RefreshRedDot()
      local sCurModule = (ModuleManager.GetCurModuleName)()
      local bInGacha = (PanelManager.CheckPanelOpen)(PanelId.GachaSpin)
      local bPhoneOpen = (PanelManager.CheckPanelOpen)(PanelId.Phone)
      local bAffinityPanelOpen = (PanelManager.CheckPanelOpen)(PanelId.CharBgPanel)
      if bAffinityPanelOpen or bPhoneOpen or sCurModule ~= "MainMenuModuleScene" or bInGacha then
        local tbData = {nAddressId = nAddressId, nChatId = nChatId, nSortId = chatCfg.Priority}
        ;
        (table.insert)(self.tbNewChatList, tbData)
      else
        do
          if chatCfg.AutoPopUp then
            (EventManager.Hit)(EventId.OpenPanel, PanelId.PhonePopUp, nChatId)
          end
        end
      end
    end
  end
end

PlayerPhoneData.PhoneContactReportSuc = function(self, mapMsgData)
  -- function num : 0_9 , upvalues : _ENV
  do
    if mapMsgData ~= nil and mapMsgData ~= nil then
      local mapDecodedChangeInfo = (UTILS.DecodeChangeInfo)(mapMsgData)
      ;
      (HttpNetHandler.ProcChangeInfo)(mapDecodedChangeInfo)
    end
    ;
    (EventManager.Hit)("RecordChatProcessSuccess", mapMsgData)
  end
end

PlayerPhoneData.GetAddressBookList = function(self)
  -- function num : 0_10 , upvalues : _ENV, LocalData
  local tbSortList = {}
  for addressId,v in pairs(self.tbAddressBook) do
    do
      local tbChatList = {}
      for _,chat in pairs(v.tbChatList) do
        (table.insert)(tbChatList, chat)
      end
      if #tbChatList > 0 then
        (table.sort)(tbChatList, function(a, b)
    -- function num : 0_10_0 , upvalues : LocalData, addressId, _ENV
    local lastChat = (LocalData.GetPlayerLocalData)("LastPhoneChatId" .. addressId)
    if a.nChatId == lastChat and a.nStatus == (AllEnum.PhoneChatState).UnComplete then
      return true
    else
      if b.nChatId == lastChat and b.nStatus == (AllEnum.PhoneChatState).UnComplete then
        return false
      end
    end
    if b.nChatId >= a.nChatId then
      do return a.nStatus ~= b.nStatus end
      do return b.nStatus < a.nStatus end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
        local tbData = {nAddressId = addressId, tbChatList = tbChatList, nTime = v.nTime, nStatus = v.nStatus, bTop = v.bTop, nOptTime = v.nOptTime}
        ;
        (table.insert)(tbSortList, tbData)
      end
    end
  end
  ;
  (table.sort)(tbSortList, function(a, b)
    -- function num : 0_10_1
    if b.nOptTime >= a.nOptTime then
      do return not a.bTop or not b.bTop end
      if a.nStatus == b.nStatus then
        if a.nTime == b.nTime then
          if a.nAddressId >= b.nAddressId then
            do return a.bTop or b.bTop end
            do return b.nTime < a.nTime end
            do return b.nStatus < a.nStatus end
            do return a.bTop end
            -- DECOMPILER ERROR: 8 unprocessed JMP targets
          end
        end
      end
    end
  end
)
  return tbSortList
end

PlayerPhoneData.GetAddressBookData = function(self, nAddressId)
  -- function num : 0_11
  if (self.tbAddressBook)[nAddressId] ~= nil then
    local addressData = (self.tbAddressBook)[nAddressId]
    return {nAddressId = nAddressId, tbChatList = addressData.tbChatList, nTime = addressData.nTime, nStatus = addressData.nStatus, bTop = addressData.bTop}
  end
end

PlayerPhoneData.GetChatHistoryList = function(self, nAddressId)
  -- function num : 0_12 , upvalues : _ENV
  local tbSortChatList = {}
  if (self.tbAddressBook)[nAddressId] ~= nil then
    local tbChatList = ((self.tbAddressBook)[nAddressId]).tbChatList
    for _,v in pairs(tbChatList) do
      (table.insert)(tbSortChatList, v)
    end
    ;
    (table.sort)(tbSortChatList, function(a, b)
    -- function num : 0_12_0
    if b.nChatId >= a.nChatId then
      do return a.nStatus ~= b.nStatus end
      do return a.nStatus < b.nStatus end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
  else
    do
      printError((string.format)("获取聊天信息失败！！！addressId = [%s]", nAddressId))
      return tbSortChatList
    end
  end
end

PlayerPhoneData.GetChatData = function(self, nAddressId, nChatId)
  -- function num : 0_13 , upvalues : _ENV
  do
    if (self.tbAddressBook)[nAddressId] ~= nil then
      local tbChatList = ((self.tbAddressBook)[nAddressId]).tbChatList
      if tbChatList[nChatId] ~= nil then
        return tbChatList[nChatId]
      end
    end
    traceback((string.format)("获取聊天信息失败！！！addressId = [%s], chatId = [%s]", nAddressId, nChatId))
  end
end

PlayerPhoneData.RefreshRedDot = function(self)
  -- function num : 0_14 , upvalues : _ENV
  (RedDotManager.SetValid)(RedDotDefine.Phone_New, nil, false)
  ;
  (RedDotManager.SetValid)(RedDotDefine.Phone_UnComplete, nil, false)
  local bUnComplete = false
  for addressId,v in pairs(self.tbAddressBook) do
    (RedDotManager.SetValid)(RedDotDefine.Phone_New_Item, addressId, v.nStatus == (AllEnum.PhoneChatState).New)
    bUnComplete = bUnComplete or v.nStatus == (AllEnum.PhoneChatState).UnComplete
    ;
    (RedDotManager.SetValid)(RedDotDefine.Phone_UnComplete_Item, addressId, v.nStatus == (AllEnum.PhoneChatState).UnComplete)
  end
  local bNew = (RedDotManager.GetValid)(RedDotDefine.Phone)
  ;
  (RedDotManager.SetValid)(RedDotDefine.Phone_UnComplete, nil, (not bNew and bUnComplete))
  -- DECOMPILER ERROR: 7 unprocessed JMP targets
end

PlayerPhoneData.TrySendAddressListReq = function(self, callback)
  -- function num : 0_15
  if not self.bInitChatData then
    self:SendAddressListReq(callback)
  else
    if callback ~= nil then
      callback()
    end
  end
end

PlayerPhoneData.OpenPhonePanel = function(self, openCall, nTog)
  -- function num : 0_16 , upvalues : _ENV
  local callback = function()
    -- function num : 0_16_0 , upvalues : _ENV, self, openCall, nTog
    local bChat = false
    for _,v in pairs(self.tbAddressBook) do
      for _,chat in pairs(v.tbChatList) do
        bChat = true
        do break end
      end
    end
    if not bChat then
      (EventManager.Hit)(EventId.OpenMessageBox, (ConfigTable.GetUIText)("Phone_Chat_Empty"))
    else
      if openCall ~= nil then
        openCall()
      end
      ;
      (EventManager.Hit)(EventId.OpenPanel, PanelId.Phone, nTog)
    end
  end

  self:TrySendAddressListReq(callback)
end

PlayerPhoneData.CheckHasNewChat = function(self)
  -- function num : 0_17
  do return #self.tbNewChatList > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PlayerPhoneData.CheckNewChat = function(self, nAddressId, callback)
  -- function num : 0_18 , upvalues : _ENV
  local bNewChat = false
  ;
  (table.sort)(self.tbNewChatList, function(a, b)
    -- function num : 0_18_0
    if a.nChatId >= b.nChatId then
      do return a.nSortId ~= b.nSortId end
      do return b.nSortId < a.nSortId end
      -- DECOMPILER ERROR: 3 unprocessed JMP targets
    end
  end
)
  if #self.tbNewChatList > 0 then
    bNewChat = true
    local tbData = (self.tbNewChatList)[#self.tbNewChatList]
    local chatCfg = (ConfigTable.GetData)("Chat", tbData.nChatId)
    local bPhoneOpen = (PanelManager.CheckPanelOpen)(PanelId.Phone)
    if chatCfg ~= nil then
      if chatCfg.AutoPopUp and not bPhoneOpen then
        (EventManager.Hit)(EventId.OpenPanel, PanelId.PhonePopUp, tbData.nChatId, false, callback)
      else
        self:RefreshRedDot()
        ;
        (EventManager.Hit)("NewChatTrigger", tbData.nAddressId, tbData.nChatId)
        if callback ~= nil then
          callback()
        end
      end
    end
  else
    do
      if nAddressId ~= nil then
        local tbHistoryChat = self:GetChatHistoryList(nAddressId)
        local tbNewChat = {}
        for k,v in pairs(tbHistoryChat) do
          if v.nStatus == (AllEnum.PhoneChatState).New then
            (table.insert)(tbNewChat, v)
          end
        end
        if #tbNewChat < 1 then
          for k,v in pairs(tbHistoryChat) do
            if v.nStatus == (AllEnum.PhoneChatState).UnComplete then
              (table.insert)(tbNewChat, v)
            end
          end
        end
        do
          do
            if #tbNewChat > 0 then
              self:RefreshRedDot()
              ;
              (EventManager.Hit)("NewChatTrigger", nAddressId, (tbNewChat[1]).nChatId)
            end
            if callback ~= nil then
              callback()
            end
            if callback ~= nil then
              callback()
            end
            self.tbNewChatList = {}
            return bNewChat
          end
        end
      end
    end
  end
end

PlayerPhoneData.GetNextProcess = function(self, nAddressId, nChatId, nProcess)
  -- function num : 0_19 , upvalues : _ENV
  local chatData = self:GetChatData(nAddressId, nChatId)
  local nNextProcess = nProcess
  local tbMsg = (chatData.avgMsg)[nNextProcess]
  if tbMsg ~= nil and tbMsg.cmd == "SetPhoneMsgChoiceJumpTo" then
    local chatCfg = (ConfigTable.GetData)("Chat", nChatId)
    if chatCfg ~= nil then
      local sGroupId = (tbMsg.param)[1]
      local tbData = ((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. chatCfg.AVGGroupId])[sGroupId]
      if tbData.nBeginCmdId < nNextProcess then
        nNextProcess = self:SetPhoneMsgChoiceEnd(nChatId, sGroupId)
      end
    end
  end
  do
    return chatData.nAllProcess < nNextProcess and chatData.nAllProcess or nNextProcess
  end
end

PlayerPhoneData.CheckChatComplete = function(self, nChatId)
  -- function num : 0_20 , upvalues : _ENV
  local chatCfg = (ConfigTable.GetData)("Chat", nChatId)
  if chatCfg ~= nil then
    local nAddressId = chatCfg.AddressBookId
    local dataAddress = (self.tbAddressBook)[nAddressId]
    if dataAddress ~= nil and dataAddress.tbChatList ~= nil then
      local chatData = (dataAddress.tbChatList)[nChatId]
      return chatData.nAllProcess <= chatData.nProcess
    end
  end
  printError((string.format)("聊天未解锁，请检查配置！！chatId = [%s])", nChatId))
  do return true end
  -- DECOMPILER ERROR: 2 unprocessed JMP targets
end

PlayerPhoneData.ParseAvgContactsData = function(self)
  -- function num : 0_21 , upvalues : _ENV
  local nCurLanguageIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
  self.sAvgContactsPath = GetAvgLuaRequireRoot(nCurLanguageIdx) .. "Preset/AvgContacts"
  local tbContacts = require(self.sAvgContactsPath)
  self.tbAvgContacts = {}
  for i,v in ipairs(tbContacts) do
    -- DECOMPILER ERROR at PC34: Confused about usage of register: R8 in 'UnsetPending'

    (self.tbAvgContacts)[v.id] = {name = v.name, signature = ProcAvgTextContent(v.signature), landmark = ProcAvgTextContent(v.landmark), icon = v.icon}
  end
end

PlayerPhoneData.GetAvgContactsData = function(self, sContactsId)
  -- function num : 0_22
  if self.tbAvgContacts == nil then
    self:ParseAvgContactsData()
  end
  local tbContacts = (self.tbAvgContacts)[sContactsId]
  if tbContacts == nil then
    return nil
  else
    return tbContacts
  end
end

PlayerPhoneData.GetAVGPhoneMsg = function(self, nChatId, sLanguage)
  -- function num : 0_23 , upvalues : _ENV
  local chatCfg = (ConfigTable.GetData)("Chat", nChatId)
  if chatCfg ~= nil then
    if sLanguage == nil then
      sLanguage = Settings.sCurrentTxtLanguage
    end
    local nCurLanguageIdx = GetLanguageIndex(sLanguage)
    local sAvgCfgPath = GetAvgLuaRequireRoot(nCurLanguageIdx) .. "Config/" .. chatCfg.AVGId
    if (self.tbChatMsgCache)[sAvgCfgPath] == nil then
      local ok, tbAllAvgCfg = pcall(require, sAvgCfgPath)
      if not ok then
        printError("AvgId对应的配置文件没有找到，path：" .. sAvgCfgPath .. ". error: " .. tbAllAvgCfg)
        return 
      else
        -- DECOMPILER ERROR at PC41: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self.tbChatMsgCache)[sAvgCfgPath] = {}
        local sMsgGroup = nil
        for i,v in ipairs(tbAllAvgCfg) do
          if v.cmd == "SetGroupId" then
            sMsgGroup = (v.param)[1]
            -- DECOMPILER ERROR at PC55: Confused about usage of register: R14 in 'UnsetPending'

            ;
            ((self.tbChatMsgCache)[sAvgCfgPath])[sMsgGroup] = {}
            -- DECOMPILER ERROR at PC61: Confused about usage of register: R14 in 'UnsetPending'

            ;
            (self.tbPhoneMsgGroupData)[chatCfg.AVGId .. sMsgGroup] = {}
            -- DECOMPILER ERROR at PC67: Confused about usage of register: R14 in 'UnsetPending'

            ;
            ((self.tbPhoneMsgGroupData)[chatCfg.AVGId .. sMsgGroup]).nStartCmdId = i
          else
            if v.cmd ~= "End" then
              (table.insert)(((self.tbChatMsgCache)[sAvgCfgPath])[sMsgGroup], v)
              -- DECOMPILER ERROR at PC94: Confused about usage of register: R14 in 'UnsetPending'

              if v.cmd == "SetPhoneMsgChoiceBegin" then
                if (self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup] == nil then
                  (self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup] = {}
                end
                local sChoiceGroup = (v.param)[1]
                -- DECOMPILER ERROR at PC115: Confused about usage of register: R15 in 'UnsetPending'

                if ((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup])[sChoiceGroup] == nil then
                  ((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup])[sChoiceGroup] = {nBeginCmdId = 0, nEndCmdId = 0, 
tbTargetCmdId = {}
}
                end
                -- DECOMPILER ERROR at PC122: Confused about usage of register: R15 in 'UnsetPending'

                ;
                (((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup])[sChoiceGroup]).nBeginCmdId = i
              else
                do
                  -- DECOMPILER ERROR at PC139: Confused about usage of register: R14 in 'UnsetPending'

                  if v.cmd == "SetPhoneMsgChoiceJumpTo" then
                    if (self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup] == nil then
                      (self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup] = {}
                    end
                    local sChoiceGroup = (v.param)[1]
                    local nIndex = (v.param)[2]
                    -- DECOMPILER ERROR at PC162: Confused about usage of register: R16 in 'UnsetPending'

                    if ((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup])[sChoiceGroup] == nil then
                      ((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup])[sChoiceGroup] = {nBeginCmdId = 0, nEndCmdId = 0, 
tbTargetCmdId = {}
}
                    end
                    -- DECOMPILER ERROR at PC170: Confused about usage of register: R16 in 'UnsetPending'

                    ;
                    ((((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup])[sChoiceGroup]).tbTargetCmdId)[nIndex] = i
                  else
                    do
                      -- DECOMPILER ERROR at PC187: Confused about usage of register: R14 in 'UnsetPending'

                      if v.cmd == "SetPhoneMsgChoiceEnd" then
                        if (self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup] == nil then
                          (self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup] = {}
                        end
                        local sChoiceGroup = (v.param)[1]
                        -- DECOMPILER ERROR at PC208: Confused about usage of register: R15 in 'UnsetPending'

                        if ((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup])[sChoiceGroup] == nil then
                          ((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup])[sChoiceGroup] = {nBeginCmdId = 0, nEndCmdId = 0, 
tbTargetCmdId = {}
}
                        end
                        -- DECOMPILER ERROR at PC215: Confused about usage of register: R15 in 'UnsetPending'

                        ;
                        (((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. sMsgGroup])[sChoiceGroup]).nEndCmdId = i
                      end
                      do
                        -- DECOMPILER ERROR at PC216: LeaveBlock: unexpected jumping out DO_STMT

                        -- DECOMPILER ERROR at PC216: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                        -- DECOMPILER ERROR at PC216: LeaveBlock: unexpected jumping out IF_STMT

                        -- DECOMPILER ERROR at PC216: LeaveBlock: unexpected jumping out DO_STMT

                        -- DECOMPILER ERROR at PC216: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                        -- DECOMPILER ERROR at PC216: LeaveBlock: unexpected jumping out IF_STMT

                        -- DECOMPILER ERROR at PC216: LeaveBlock: unexpected jumping out IF_THEN_STMT

                        -- DECOMPILER ERROR at PC216: LeaveBlock: unexpected jumping out IF_STMT

                        -- DECOMPILER ERROR at PC216: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                        -- DECOMPILER ERROR at PC216: LeaveBlock: unexpected jumping out IF_STMT

                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    do
      if (self.tbChatMsgCache)[sAvgCfgPath] ~= nil then
        return ((self.tbChatMsgCache)[sAvgCfgPath])[chatCfg.AVGGroupId]
      end
    end
  end
end

PlayerPhoneData.ParseAvgHistoryPhoneMsgData = function(self, nChatId, tbMsgData, nProcess, tbSelection)
  -- function num : 0_24 , upvalues : _ENV
  self:ClearHistoryPhoneMsgData(nChatId)
  if tbMsgData ~= nil then
    local choiceCount = 0
    local sCurChoiceIndex = "0"
    local sCurGroupId = "0"
    local bFindChoice = false
    local bStartChoice = false
    for i,v in ipairs(tbMsgData) do
      if i <= nProcess then
        do
          if v.cmd == "SetPhoneMsg" and bStartChoice and bFindChoice then
            local data = {cmd = v.cmd, param = v.param, process = i}
            ;
            (table.insert)((self.tbHistoryMsg)[nChatId], data)
          end
          do
            local data = {cmd = v.cmd, param = v.param, process = i}
            ;
            (table.insert)((self.tbHistoryMsg)[nChatId], data)
            if v.cmd == "SetPhoneMsgChoiceBegin" then
              if tbSelection ~= nil and choiceCount < #tbSelection then
                choiceCount = choiceCount + 1
                sCurChoiceIndex = tostring(tbSelection[choiceCount])
                sCurGroupId = (v.param)[1] or "0"
                bStartChoice = true
              else
                if i == nProcess then
                  local data = {cmd = v.cmd, param = v.param, process = i}
                  ;
                  (table.insert)((self.tbHistoryMsg)[nChatId], data)
                end
              end
            else
              do
                if v.cmd == "SetPhoneMsgChoiceJumpTo" then
                  local sGroupId = (v.param)[1]
                  if sGroupId == sCurGroupId then
                    local sIndex = (v.param)[2]
                    if sIndex == sCurChoiceIndex then
                      bFindChoice = true
                      local dataSelection = {groupID = sCurGroupId, choiceIndex = sIndex}
                      ;
                      (table.insert)((self.tbHistorySelection)[nChatId], dataSelection)
                    else
                      do
                        do
                          do
                            bFindChoice = false
                            if v.cmd == "SetPhoneMsgChoiceEnd" then
                              bFindChoice = false
                              bStartChoice = false
                            end
                            do break end
                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out DO_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out DO_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out IF_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out IF_THEN_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out IF_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out IF_THEN_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out IF_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out DO_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out IF_ELSE_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out IF_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out DO_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out DO_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out IF_THEN_STMT

                            -- DECOMPILER ERROR at PC115: LeaveBlock: unexpected jumping out IF_STMT

                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

PlayerPhoneData.GetAvgStartCmdId = function(self, nChatId)
  -- function num : 0_25 , upvalues : _ENV
  local chatCfg = (ConfigTable.GetData)("Chat", nChatId)
  if chatCfg ~= nil then
    local tbData = (self.tbPhoneMsgGroupData)[chatCfg.AVGId .. chatCfg.AVGGroupId]
    if tbData ~= nil then
      return tbData.nStartCmdId
    end
  end
end

PlayerPhoneData.ClearHistoryPhoneMsgData = function(self, nChatId)
  -- function num : 0_26
  -- DECOMPILER ERROR at PC2: Confused about usage of register: R2 in 'UnsetPending'

  (self.tbHistoryMsg)[nChatId] = {}
  -- DECOMPILER ERROR at PC5: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (self.tbHistorySelection)[nChatId] = {}
end

PlayerPhoneData.UpdateHistoryPhoneMsgData = function(self, nChatId, tbMsgData, nProcess)
  -- function num : 0_27 , upvalues : _ENV
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R4 in 'UnsetPending'

  if (self.tbHistoryMsg)[nChatId] == nil then
    (self.tbHistoryMsg)[nChatId] = {}
    local data = {cmd = tbMsgData.cmd, param = tbMsgData.param, process = nProcess}
    ;
    (table.insert)((self.tbHistoryMsg)[nChatId], data)
    return 
  end
  do
    if nProcess <= (((self.tbHistoryMsg)[nChatId])[#(self.tbHistoryMsg)[nChatId]]).process then
      return 
    end
    if tbMsgData.cmd ~= "SetPhoneMsg" and tbMsgData.cmd ~= "SetPhoneMsgChoiceBegin" then
      return 
    end
    local lastData = ((self.tbHistoryMsg)[nChatId])[#(self.tbHistoryMsg)[nChatId]]
    if lastData.cmd == "SetPhoneMsgChoiceBegin" then
      (table.remove)((self.tbHistoryMsg)[nChatId], #(self.tbHistoryMsg)[nChatId])
    end
    local data = {cmd = tbMsgData.cmd, param = tbMsgData.param, process = nProcess}
    ;
    (table.insert)((self.tbHistoryMsg)[nChatId], data)
  end
end

PlayerPhoneData.GetHistoryPhoneMsgData = function(self, nChatId)
  -- function num : 0_28
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbHistoryMsg)[nChatId] == nil then
    (self.tbHistoryMsg)[nChatId] = {}
  end
  return (self.tbHistoryMsg)[nChatId]
end

PlayerPhoneData.GetHistoryPhoneSelectionData = function(self, nChatId)
  -- function num : 0_29
  -- DECOMPILER ERROR at PC6: Confused about usage of register: R2 in 'UnsetPending'

  if (self.tbHistorySelection)[nChatId] == nil then
    (self.tbHistorySelection)[nChatId] = {}
  end
  return (self.tbHistorySelection)[nChatId]
end

PlayerPhoneData.GetChatMsg = function(self, chatData, nIndex)
  -- function num : 0_30
  local avgGroupMsg = chatData.avgMsg
  if avgGroupMsg ~= nil then
    if nIndex == 1 then
      return avgGroupMsg[nIndex]
    else
      local tbChatList = (self.tbHistoryMsg)[chatData.nChatId]
      return tbChatList[#tbChatList]
    end
  end
end

PlayerPhoneData.GetChatContent = function(self, chatData, nIndex)
  -- function num : 0_31 , upvalues : _ENV
  local avgGroupMsg = chatData.avgMsg
  if avgGroupMsg ~= nil then
    local tbAvgMsg = avgGroupMsg[nIndex]
    if nIndex == 1 then
      return ProcAvgTextContent((tbAvgMsg.param)[3], GetLanguageIndex(Settings.sCurrentTxtLanguage))
    else
      local tbChatList = (self.tbHistoryMsg)[chatData.nChatId]
      local chatData = tbChatList[#tbChatList]
      return ProcAvgTextContent((chatData.param)[3], GetLanguageIndex(Settings.sCurrentTxtLanguage))
    end
  end
end

PlayerPhoneData.SetPhoneMsgChoiceJumpTo = function(self, nChatId, nGroupId, nIndex)
  -- function num : 0_32 , upvalues : _ENV
  local chatCfg = (ConfigTable.GetData)("Chat", nChatId)
  if chatCfg ~= nil then
    local tbData = ((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. chatCfg.AVGGroupId])[tostring(nGroupId)]
    if tbData ~= nil then
      return (tbData.tbTargetCmdId)[tostring(nIndex)]
    end
  end
end

PlayerPhoneData.SetPhoneMsgChoiceEnd = function(self, nChatId, nGroupId)
  -- function num : 0_33 , upvalues : _ENV
  local chatCfg = (ConfigTable.GetData)("Chat", nChatId)
  if chatCfg ~= nil then
    nGroupId = tostring(nGroupId)
    local tbData = ((self.tbPhoneMsgChoiceTarget)[chatCfg.AVGId .. chatCfg.AVGGroupId])[nGroupId]
    if tbData ~= nil then
      return tbData.nEndCmdId
    end
  end
end

PlayerPhoneData.GetTopCount = function(self)
  -- function num : 0_34 , upvalues : _ENV
  local nTopCount = 0
  for k,v in pairs(self.tbAddressBook) do
    if v.bTop then
      nTopCount = nTopCount + 1
    end
  end
  return nTopCount
end

PlayerPhoneData.SetPhoneTopStatus = function(self, nAddressId, bTop)
  -- function num : 0_35 , upvalues : _ENV
  local callback = function(...)
    -- function num : 0_35_0
  end

  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).phone_contacts_top_req, {Value = nAddressId}, nil, callback)
  -- DECOMPILER ERROR at PC13: Confused about usage of register: R4 in 'UnsetPending'

  ;
  ((self.tbAddressBook)[nAddressId]).bTop = bTop
  -- DECOMPILER ERROR at PC22: Confused about usage of register: R4 in 'UnsetPending'

  if bTop then
    ((self.tbAddressBook)[nAddressId]).nOptTime = ((CS.ClientManager).Instance).serverTimeStampWithTimeZone
  end
end

PlayerPhoneData.SendAddressListReq = function(self, callback)
  -- function num : 0_36 , upvalues : _ENV
  (HttpNetHandler.SendMsg)((NetMsgId.Id).phone_contacts_info_req, {}, nil, callback)
end

PlayerPhoneData.SendChatProcess = function(self, nAddressId, nChatId, nProcess, tbSelection, bEnd, callback)
  -- function num : 0_37 , upvalues : _ENV
  local httpCall = function(mapMsgData)
    -- function num : 0_37_0 , upvalues : self, nChatId, _ENV, nAddressId, nProcess, tbSelection, callback
    do
      if (self.tbHistoryMsg)[nChatId] == nil or next((self.tbHistoryMsg)[nChatId]) == nil then
        local chatData = self:GetChatData(nAddressId, nChatId)
        self:ParseAvgHistoryPhoneMsgData(nChatId, chatData.avgMsg, nProcess, tbSelection)
      end
      self:RefreshChatProcess(nAddressId, nChatId, nProcess, tbSelection)
      if callback ~= nil then
        callback()
      end
    end
  end

  local netMsg = {ChatId = nChatId, Options = tbSelection, Process = nProcess, End = bEnd}
  ;
  (HttpNetHandler.SendMsg)((NetMsgId.Id).phone_contacts_report_req, netMsg, nil, httpCall)
end

PlayerPhoneData.OnEvent_AfterEnterMain = function(self)
  -- function num : 0_38
end

return PlayerPhoneData

