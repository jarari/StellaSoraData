local PlayerPhoneData = class("PlayerPhoneData")
local ModuleManager = require "GameCore.Module.ModuleManager"
local LocalData = require("GameCore.Data.LocalData")

function PlayerPhoneData:Init()
    self.tbAddressBook = {}     --联系人列表
    self.tbChatMsgCache = {}    --Avg配置缓存
    self.tbPhoneMsgChoiceTarget = {}    --Avg选项目标
    self.tbPhoneMsgGroupData = {}    --Avg组配置
    self.tbHistoryMsg = {}      --历史消息列表
    self.tbHistorySelection = {}    --历史消息选项列表
    self.tbNewChatList = {}     --新触发聊天列表
    self.bInitChatData = false
    
    self:InitCfg()
    EventManager.Add(EventId.AfterEnterMain, self, self.OnEvent_AfterEnterMain)
end

--表格数据处理
function PlayerPhoneData:InitCfg()
    local function foreachPlot(mapData)
        if mapData.ConnectChatId ~= 0 then
            local tbData = {}
            tbData.sAvgId = mapData.AvgId
            tbData.nCharId = mapData.Char
            tbData.nPlotId = mapData.Id
            CacheTable.SetData("_PlotChat", mapData.ConnectChatId, tbData)
        end
    end
    ForEachTableLine(DataTable.Plot, foreachPlot)
end

--region 数据刷新
--登录时获取聊天消息数量，更新红点显示
function PlayerPhoneData:CachePhoneMsgCount(msgNetData)
    if nil ~= msgNetData then
        RedDotManager.SetValid(RedDotDefine.Phone_New, nil, msgNetData.NewMessage > 0)
        local bNewValue = RedDotManager.GetValid(RedDotDefine.Phone)
        RedDotManager.SetValid(RedDotDefine.Phone_UnComplete, nil, not bNewValue and msgNetData.ProgressMessage > 0)
    end
end

--获取聊天状态
function PlayerPhoneData:GetChatState(chatData)
    if chatData.nProcess == 0 then
        return AllEnum.PhoneChatState.New
    elseif chatData.nProcess < chatData.nAllProcess then
        return AllEnum.PhoneChatState.UnComplete
    elseif chatData.nProcess >= chatData.nAllProcess then
        return AllEnum.PhoneChatState.Complete
    end
end

function PlayerPhoneData:CreateNewChat(mapMsgData)
    local chatData = {}
    chatData.nChatId = mapMsgData.Id
    chatData.nProcess = mapMsgData.Process
    chatData.tbSelection = mapMsgData.Options
    
    local chatAvgMsg = self:GetAVGPhoneMsg(chatData.nChatId)
    if nil == chatAvgMsg then
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

--刷新联系人聊天状态
function PlayerPhoneData:RefreshAddressStatus(nAddressId)
    local addressData = self.tbAddressBook[nAddressId]
    if nil ~= addressData then
        local bNew = false
        local bUnComplete = false
        for _, chat in pairs(addressData.tbChatList) do
            if chat.nStatus == AllEnum.PhoneChatState.UnComplete then
                bUnComplete = true
                break
            elseif chat.nStatus == AllEnum.PhoneChatState.New then
                bNew = true
            end
        end
        if bUnComplete then
            addressData.nStatus = AllEnum.PhoneChatState.UnComplete
        elseif bNew then
            addressData.nStatus = AllEnum.PhoneChatState.New
        else
            addressData.nStatus = AllEnum.PhoneChatState.Complete
        end
    end
end

function PlayerPhoneData:CacheAddressBookData(msgNetData)
    self.bInitChatData = true
    for _, v in ipairs(msgNetData) do
        local mapChar = ConfigTable.GetData_Character(v.CharId)
        if mapChar ~= nil and mapChar.Visible then
            if nil == self.tbAddressBook[v.CharId] then
                self.tbAddressBook[v.CharId] = {}
            end
            local tbChatList = {}
            for _, chat in ipairs(v.Chats) do
                local chatData = self:CreateNewChat(chat)
                if nil ~= chatData then
                    tbChatList[chat.Id] = chatData
                end
            end
            self.tbAddressBook[v.CharId].tbChatList = tbChatList
            self.tbAddressBook[v.CharId].nTime = v.TriggerTime
            self.tbAddressBook[v.CharId].bTop = v.Top
            self.tbAddressBook[v.CharId].nOptTime = 0
            if v.nOptTime ~= nil then self.tbAddressBook[v.CharId].nOptTime = v.nOptTime end

            self:RefreshAddressStatus(v.CharId)
        end
    end
    self:RefreshRedDot()
end

--刷新聊天进度（客户端本地先刷新，关闭界面时向服务器同步进度）
function PlayerPhoneData:RefreshChatProcess(nAddressId, nChatId, nProcess, tbSelection)
    local addressData = self.tbAddressBook[nAddressId]
    if nil ~= addressData then
        local tbChatList = addressData.tbChatList
        if nil ~= tbChatList[nChatId] then
            local chatData = tbChatList[nChatId]
            local lastProcess = chatData.nProcess
            chatData.nProcess = nProcess
            if nil ~= tbSelection then
                chatData.tbSelection = tbSelection
                local data = chatData.avgMsg[lastProcess]
                if data ~= nil and data.cmd == "SetPhoneMsgChoiceBegin" then
                    local nGroupId = tonumber(data.param[1]) or 0
                    -- 当最后一个消息为选项时，记录的选项数量等于当前选项事件组的编号，说明这个选项已经选了，此时才记录选项。
                    if nGroupId == #tbSelection then
                        if self.tbHistorySelection[nChatId] == nil then
                            self.tbHistorySelection[nChatId] = {}
                        else
                            for k, v in pairs(self.tbHistorySelection[nChatId]) do
                                if tostring(v.groupID) == tostring(data.param[1]) then
                                    table.remove(self.tbHistorySelection[nChatId], k)
                                    break
                                end
                            end
                        end
                        local dataSelection = {groupID = tostring(data.param[1]), choiceIndex = tbSelection[#tbSelection]}
                        table.insert(self.tbHistorySelection[nChatId], dataSelection)
                    end
                end
            end
            
            --刷新聊天状态
            chatData.nStatus = self:GetChatState(chatData)
            --更新历史记录
            self:UpdateHistoryPhoneMsgData(nChatId, chatData.avgMsg[nProcess], nProcess)
        end
        --刷新联系人状态
        self:RefreshAddressStatus(nAddressId)
    end
    
    --刷新红点显示
    self:RefreshRedDot()
end

--触发新的聊天
function PlayerPhoneData:NewChatTrigger(mapMsgData)
    local nChatId = mapMsgData.Value
    local tbData = {
        Id = nChatId,
        Options = {},
        Process = 0,
    }
    local chatCfg = ConfigTable.GetData("Chat", nChatId)
    if nil ~= chatCfg then
        local nAddressId = chatCfg.AddressBookId
        local mapChar = ConfigTable.GetData_Character(nAddressId)
        if mapChar ~= nil and mapChar.Visible then
            if nil == self.tbAddressBook[nAddressId] then
                self.tbAddressBook[nAddressId] = {}
                self.tbAddressBook[nAddressId].tbChatList = {}
            end
            local chatData = self:CreateNewChat(tbData)
            if nil ~= chatData then
                self.tbAddressBook[nAddressId].tbChatList[nChatId] = chatData
            end
            self.tbAddressBook[nAddressId].nTime = CS.ClientManager.Instance.serverTimeStampWithTimeZone

            self:RefreshAddressStatus(nAddressId)
            --刷新红点显示
            self:RefreshRedDot()

            --战斗结算界面或者抽卡界面或好感度升级界面延迟弹出手机界面
            local sCurModule = ModuleManager.GetCurModuleName()
            local bInGacha = PanelManager.CheckPanelOpen(PanelId.GachaSpin)
            local bPhoneOpen = PanelManager.CheckPanelOpen(PanelId.Phone)
            local bAffinityPanelOpen = PanelManager.CheckPanelOpen(PanelId.CharBgPanel)
            if bAffinityPanelOpen or bPhoneOpen or sCurModule ~= "MainMenuModuleScene" or bInGacha then
                local tbData = {nAddressId = nAddressId, nChatId = nChatId, nSortId = chatCfg.Priority}
                table.insert(self.tbNewChatList, tbData)
            elseif chatCfg.AutoPopUp then
                --弹出聊天弹窗
                EventManager.Hit(EventId.OpenPanel, PanelId.PhonePopUp, nChatId)
            end
        end
    end
end

--聊天奖励
function PlayerPhoneData:PhoneContactReportSuc(mapMsgData)
    if nil ~= mapMsgData then
        if nil ~= mapMsgData then
            local mapDecodedChangeInfo = UTILS.DecodeChangeInfo(mapMsgData)
            HttpNetHandler.ProcChangeInfo(mapDecodedChangeInfo)
        end
    end
    EventManager.Hit("RecordChatProcessSuccess", mapMsgData)
end

--endregion

--region public
function PlayerPhoneData:GetAddressBookList()
    local tbSortList = {}
    for addressId, v in pairs(self.tbAddressBook) do
        local tbChatList = {}
        for _, chat in pairs(v.tbChatList) do
            table.insert(tbChatList, chat)
            
        end
        if #tbChatList > 0 then
            table.sort(tbChatList, function(a, b)
                local lastChat = LocalData.GetPlayerLocalData("LastPhoneChatId" .. addressId)
                if a.nChatId == lastChat and a.nStatus == AllEnum.PhoneChatState.UnComplete then
                    return true
                elseif b.nChatId == lastChat and b.nStatus == AllEnum.PhoneChatState.UnComplete then
                    return false
                end
                if a.nStatus == b.nStatus then
                    return a.nChatId > b.nChatId
                end
                return a.nStatus > b.nStatus
            end)
            local tbData = {nAddressId = addressId, tbChatList = tbChatList, nTime = v.nTime, nStatus = v.nStatus, bTop = v.bTop, nOptTime = v.nOptTime}
            table.insert(tbSortList, tbData)
        end
    end
    
    table.sort(tbSortList, function(a, b)
        if a.bTop and b.bTop then
            return a.nOptTime > b.nOptTime
        elseif not a.bTop and not b.bTop then
            if a.nStatus == b.nStatus then
                if a.nTime == b.nTime then
                    return a.nAddressId < b.nAddressId
                end
                return a.nTime > b.nTime
            end
            return a.nStatus > b.nStatus
        end
        return a.bTop
    end)
    return tbSortList
end

function PlayerPhoneData:GetAddressBookData(nAddressId)
    if nil ~= self.tbAddressBook[nAddressId] then
        local addressData = self.tbAddressBook[nAddressId]
        return {nAddressId = nAddressId, tbChatList = addressData.tbChatList, nTime = addressData.nTime, nStatus = addressData.nStatus, bTop = addressData.bTop}
    end
end

function PlayerPhoneData:GetChatHistoryList(nAddressId)
    local tbSortChatList = {}
    if nil ~= self.tbAddressBook[nAddressId] then
        local tbChatList = self.tbAddressBook[nAddressId].tbChatList
        for _, v in pairs(tbChatList) do
            table.insert(tbSortChatList, v)
        end
        table.sort(tbSortChatList, function(a, b)
            if a.nStatus == b.nStatus then
                return a.nChatId > b.nChatId
            end
            return a.nStatus < b.nStatus
        end)
    else
        printError(string.format("获取聊天信息失败！！！addressId = [%s]", nAddressId))
    end
    return tbSortChatList
end

function PlayerPhoneData:GetChatData(nAddressId, nChatId)
    if nil ~= self.tbAddressBook[nAddressId] then
        local tbChatList = self.tbAddressBook[nAddressId].tbChatList
        if nil ~= tbChatList[nChatId] then
            return tbChatList[nChatId]
        end
    end
    traceback(string.format("获取聊天信息失败！！！addressId = [%s], chatId = [%s]", nAddressId, nChatId))
end

function PlayerPhoneData:RefreshRedDot()
    RedDotManager.SetValid(RedDotDefine.Phone_New, nil, false)
    RedDotManager.SetValid(RedDotDefine.Phone_UnComplete, nil, false)
    local bUnComplete = false
    for addressId, v in pairs(self.tbAddressBook) do
        RedDotManager.SetValid(RedDotDefine.Phone_New_Item, addressId, v.nStatus == AllEnum.PhoneChatState.New)
        bUnComplete = bUnComplete or v.nStatus == AllEnum.PhoneChatState.UnComplete
        RedDotManager.SetValid(RedDotDefine.Phone_UnComplete_Item, addressId, v.nStatus == AllEnum.PhoneChatState.UnComplete)
    end
    local bNew = RedDotManager.GetValid(RedDotDefine.Phone)
    RedDotManager.SetValid(RedDotDefine.Phone_UnComplete, nil, not bNew and bUnComplete)
end

function PlayerPhoneData:TrySendAddressListReq(callback)
    if not self.bInitChatData then
        self:SendAddressListReq(callback)
    else
        if nil ~= callback then
            callback()
        end
    end
end

function PlayerPhoneData:OpenPhonePanel(openCall, nTog)
    local callback = function()
        --检查有没有聊天
        local bChat = false
        for _, v in pairs(self.tbAddressBook) do
            for _, chat in pairs(v.tbChatList) do
                bChat = true
                break
            end
        end
        if not bChat then
            EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Phone_Chat_Empty"))
        else
            if nil ~= openCall then
                openCall()
            end
            EventManager.Hit(EventId.OpenPanel, PanelId.Phone, nTog)
        end
    end
    
    self:TrySendAddressListReq(callback)
end

function PlayerPhoneData:CheckHasNewChat()
    return #self.tbNewChatList > 0
end

function PlayerPhoneData:CheckNewChat(nAddressId, callback)
    local bNewChat = false
    --对新聊天按照优先级排序
    table.sort(self.tbNewChatList, function(a, b)
        if a.nSortId == b.nSortId then
            return a.nChatId < b.nChatId
        end
        return a.nSortId > b.nSortId
    end)

    if #self.tbNewChatList > 0 then
        bNewChat = true
        local tbData = self.tbNewChatList[#self.tbNewChatList]
        local chatCfg = ConfigTable.GetData("Chat", tbData.nChatId)
        local bPhoneOpen = PanelManager.CheckPanelOpen(PanelId.Phone)
        if chatCfg ~= nil then
            if chatCfg.AutoPopUp and not bPhoneOpen then
                --弹出聊天弹窗
                EventManager.Hit(EventId.OpenPanel, PanelId.PhonePopUp, tbData.nChatId, false, callback)
            else
                --延迟刷新红点
                self:RefreshRedDot()
                EventManager.Hit("NewChatTrigger", tbData.nAddressId, tbData.nChatId)
                if nil ~= callback then
                    callback()
                end
            end
        end
    elseif nAddressId ~= nil then
        local tbHistoryChat = self:GetChatHistoryList(nAddressId)
        local tbNewChat = {}
        for k, v in pairs(tbHistoryChat) do
            if v.nStatus == AllEnum.PhoneChatState.New then
                table.insert(tbNewChat, v)
            end
        end
        if #tbNewChat < 1 then
            for k, v in pairs(tbHistoryChat) do
                if v.nStatus == AllEnum.PhoneChatState.UnComplete then
                    table.insert(tbNewChat, v)
                end
            end
        end
        if #tbNewChat > 0 then
            --延迟刷新红点
            self:RefreshRedDot()
            EventManager.Hit("NewChatTrigger", nAddressId, tbNewChat[1].nChatId)
        end
        if nil ~= callback then
            callback()
        end
    else
        if nil ~= callback then
            callback()
        end        
    end
    --只弹出优先级最高的聊天，其他搁置
    self.tbNewChatList = {}
    return bNewChat
end

--获取下一条聊天index
function PlayerPhoneData:GetNextProcess(nAddressId, nChatId, nProcess)
    local chatData = self:GetChatData(nAddressId, nChatId)
    local nNextProcess = nProcess
    local tbMsg = chatData.avgMsg[nNextProcess]
    if nil ~= tbMsg then
        if tbMsg.cmd == "SetPhoneMsgChoiceJumpTo" then
            local chatCfg = ConfigTable.GetData("Chat", nChatId)
            if chatCfg ~= nil then
                local sGroupId = tbMsg.param[1]
                local tbData = self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..chatCfg.AVGGroupId][sGroupId]
                if nNextProcess > tbData.nBeginCmdId then
                    nNextProcess = self:SetPhoneMsgChoiceEnd(nChatId, sGroupId)
                end
            end
        end

        --[[
        if nil ~= chatData.avgMsg[nNextProcess] then
            tbMsg = chatData.avgMsg[nNextProcess]
            if tbMsg.cmd == "SetPhoneMsgChoiceEnd" then
                nNextProcess = nNextProcess + 1
            end
        end
        ]]
    end

    return nNextProcess > chatData.nAllProcess and chatData.nAllProcess or nNextProcess
end

function PlayerPhoneData:CheckChatComplete(nChatId)
    local chatCfg = ConfigTable.GetData("Chat", nChatId)
    if nil ~= chatCfg then
        local nAddressId = chatCfg.AddressBookId
        local dataAddress = self.tbAddressBook[nAddressId]
        if nil ~= dataAddress and nil ~= dataAddress.tbChatList then
            local chatData = dataAddress.tbChatList[nChatId]
            return chatData.nProcess >= chatData.nAllProcess
        end 
    end
    printError(string.format("聊天未解锁，请检查配置！！chatId = [%s])", nChatId))
    return true
end
--endregion 
----------------------------------- avg --------------------------------
--avg联系人
function PlayerPhoneData:ParseAvgContactsData()
    local nCurLanguageIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
    self.sAvgContactsPath = GetAvgLuaRequireRoot(nCurLanguageIdx) .. "Preset/AvgContacts"
    local tbContacts = require(self.sAvgContactsPath)
    self.tbAvgContacts = {}
    for i, v in ipairs(tbContacts) do
        self.tbAvgContacts[v.id] = {name = v.name, signature = ProcAvgTextContent(v.signature), landmark = ProcAvgTextContent(v.landmark), icon = v.icon}
    end
end

--获取avg联系人信息
function PlayerPhoneData:GetAvgContactsData(sContactsId)
    if self.tbAvgContacts == nil then
        self:ParseAvgContactsData()
    end
    local tbContacts = self.tbAvgContacts[sContactsId]
    if tbContacts == nil then
        return nil
    else
        return tbContacts
    end
end

--avg配置
function PlayerPhoneData:GetAVGPhoneMsg(nChatId, sLanguage)
    local chatCfg = ConfigTable.GetData("Chat", nChatId)
    if nil ~= chatCfg then
        if sLanguage == nil then sLanguage = Settings.sCurrentTxtLanguage end
        local nCurLanguageIdx = GetLanguageIndex(sLanguage)
        local sAvgCfgPath = GetAvgLuaRequireRoot(nCurLanguageIdx) .. "Config/" .. chatCfg.AVGId
        if nil == self.tbChatMsgCache[sAvgCfgPath] then
            local ok, tbAllAvgCfg =  pcall(require, sAvgCfgPath)
            if not ok then
                printError("AvgId对应的配置文件没有找到，path：" .. sAvgCfgPath .. ". error: " .. tbAllAvgCfg)
                return
            else
                self.tbChatMsgCache[sAvgCfgPath] = {}
                local sMsgGroup
                for i, v in ipairs(tbAllAvgCfg) do
                    if v.cmd == "SetGroupId" then
                        sMsgGroup = v.param[1]
                        self.tbChatMsgCache[sAvgCfgPath][sMsgGroup] = {}
                        self.tbPhoneMsgGroupData[chatCfg.AVGId..sMsgGroup] = {}
                        self.tbPhoneMsgGroupData[chatCfg.AVGId..sMsgGroup].nStartCmdId = i
                    elseif v.cmd ~= "End" then
                        table.insert(self.tbChatMsgCache[sAvgCfgPath][sMsgGroup], v)
                        if v.cmd == "SetPhoneMsgChoiceBegin" then
                            if self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup] == nil then 
                                self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup] = {}
                            end
                            local sChoiceGroup = v.param[1]
                            if self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup][sChoiceGroup] == nil then 
                                self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup][sChoiceGroup] = {nBeginCmdId = 0, nEndCmdId = 0, tbTargetCmdId = {}} 
                            end
                            self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup][sChoiceGroup].nBeginCmdId = i
                        elseif v.cmd == "SetPhoneMsgChoiceJumpTo" then
                            if self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup] == nil then 
                                self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup] = {}
                            end
                            local sChoiceGroup = v.param[1]
                            local nIndex = v.param[2]
                            if self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup][sChoiceGroup] == nil then 
                                self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup][sChoiceGroup] = {nBeginCmdId = 0, nEndCmdId = 0, tbTargetCmdId = {}} 
                            end
                            self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup][sChoiceGroup].tbTargetCmdId[nIndex] = i
                        elseif v.cmd == "SetPhoneMsgChoiceEnd" then
                            if self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup] == nil then 
                                self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup] = {}
                            end
                            local sChoiceGroup = v.param[1]
                            if self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup][sChoiceGroup] == nil then 
                                self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup][sChoiceGroup] = {nBeginCmdId = 0, nEndCmdId = 0, tbTargetCmdId = {}} 
                            end
                            self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..sMsgGroup][sChoiceGroup].nEndCmdId = i
                        end
                    end
                end
            end
        end

        if nil ~= self.tbChatMsgCache[sAvgCfgPath] then
            return self.tbChatMsgCache[sAvgCfgPath][chatCfg.AVGGroupId]
        end
    end
end

--解析历史记录
function PlayerPhoneData:ParseAvgHistoryPhoneMsgData(nChatId, tbMsgData, nProcess, tbSelection)
    self:ClearHistoryPhoneMsgData(nChatId) --解析前重置已有数据

    if nil ~= tbMsgData then
        local choiceCount = 0
        local nCurChoiceIndex = 0
        local nCurGroupId = 0
        local bFindChoice = false
        local bStartChoice = false
        for i, v in ipairs(tbMsgData) do
            if i <= nProcess then
                if v.cmd == "SetPhoneMsg" then
                    if bStartChoice then
                        if bFindChoice then
                            local data = {cmd = v.cmd, param = v.param, process = i}
                            table.insert(self.tbHistoryMsg[nChatId], data)
                        end    
                    else
                        local data = {cmd = v.cmd, param = v.param, process = i}
                        table.insert(self.tbHistoryMsg[nChatId], data)
                    end
                elseif v.cmd == "SetPhoneMsgChoiceBegin" then
                    if tbSelection ~= nil and choiceCount < #tbSelection then
                        choiceCount = choiceCount + 1
                        nCurChoiceIndex = tbSelection[choiceCount]
                        nCurGroupId = tonumber(v.param[1]) or 0
                        bStartChoice = true
                    else
                        if i == nProcess then
                            local data = {cmd = v.cmd, param = v.param, process = i}
                            table.insert(self.tbHistoryMsg[nChatId], data)
                        end
                    end
                elseif v.cmd == "SetPhoneMsgChoiceJumpTo" then
                    local nGroupId = tonumber(v.param[1])
                    if nGroupId == nCurGroupId then
                        local nIndex = tonumber(v.param[2])
                        if nIndex == nCurChoiceIndex then
                            bFindChoice = true
                            local dataSelection = {groupID = tostring(nCurGroupId), choiceIndex = nIndex}
                            table.insert(self.tbHistorySelection[nChatId], dataSelection)
                        else
                            bFindChoice = false
                        end
                    end
                elseif v.cmd == "SetPhoneMsgChoiceEnd" then
                    bFindChoice = false
                    bStartChoice = false
                end
            else
                break
            end
        end
    end
end

function PlayerPhoneData:GetAvgStartCmdId(nChatId)
    local chatCfg = ConfigTable.GetData("Chat", nChatId)
    if chatCfg ~= nil then
        local tbData = self.tbPhoneMsgGroupData[chatCfg.AVGId..chatCfg.AVGGroupId] -- 按 组id + 索引 找到初始cmdId
        if tbData ~= nil then
            --返回进度
            return tbData.nStartCmdId
        end
    end
end

--清空历史记录
function PlayerPhoneData:ClearHistoryPhoneMsgData(nChatId)
    self.tbHistoryMsg[nChatId] = {}
    self.tbHistorySelection[nChatId] = {}
end

--更新历史记录
function PlayerPhoneData:UpdateHistoryPhoneMsgData(nChatId, tbMsgData, nProcess)
    if self.tbHistoryMsg[nChatId] == nil then
        self.tbHistoryMsg[nChatId] = {}
        local data = {cmd = tbMsgData.cmd, param = tbMsgData.param, process = nProcess}
        table.insert(self.tbHistoryMsg[nChatId], data)
        return
    end

    if self.tbHistoryMsg[nChatId][#self.tbHistoryMsg[nChatId]].process >= nProcess then
        return
    end

    if tbMsgData.cmd ~= "SetPhoneMsg" and tbMsgData.cmd ~= "SetPhoneMsgChoiceBegin" then
        return
    end

    local lastData = self.tbHistoryMsg[nChatId][#self.tbHistoryMsg[nChatId]]
    if lastData.cmd == "SetPhoneMsgChoiceBegin" then
        table.remove(self.tbHistoryMsg[nChatId], #self.tbHistoryMsg[nChatId])
    end

    local data = {cmd = tbMsgData.cmd, param = tbMsgData.param, process = nProcess}
    table.insert(self.tbHistoryMsg[nChatId], data)
end

--获取历史聊天记录
function PlayerPhoneData:GetHistoryPhoneMsgData(nChatId)
    if self.tbHistoryMsg[nChatId] == nil then
        self.tbHistoryMsg[nChatId] = {}
    end
    
    return self.tbHistoryMsg[nChatId]
end

--获取历史选项记录
function PlayerPhoneData:GetHistoryPhoneSelectionData(nChatId)
    if self.tbHistorySelection[nChatId] == nil then
        self.tbHistorySelection[nChatId] = {}
    end
    
    return self.tbHistorySelection[nChatId]
end

function PlayerPhoneData:GetChatMsg(chatData, nIndex)
    local avgGroupMsg = chatData.avgMsg
    if nil ~= avgGroupMsg then
        if nIndex == 1 then
            return avgGroupMsg[nIndex]
        else
            local tbChatList = self.tbHistoryMsg[chatData.nChatId]
            return tbChatList[#tbChatList]
        end
    end
end

--获取avg聊天内容
function PlayerPhoneData:GetChatContent(chatData, nIndex)
    local avgGroupMsg = chatData.avgMsg
     if nil ~= avgGroupMsg then
        local tbAvgMsg = avgGroupMsg[nIndex]
         if nIndex == 1 then
             return ProcAvgTextContent(tbAvgMsg.param[3], GetLanguageIndex(Settings.sCurrentTxtLanguage))
         else
             local tbChatList = self.tbHistoryMsg[chatData.nChatId]
             local chatData = tbChatList[#tbChatList]
             return ProcAvgTextContent(chatData.param[3], GetLanguageIndex(Settings.sCurrentTxtLanguage))
         end
    end
end

function PlayerPhoneData:SetPhoneMsgChoiceJumpTo(nChatId, nGroupId, nIndex)
    local chatCfg = ConfigTable.GetData("Chat", nChatId)
    if chatCfg ~= nil then
        local tbData = self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..chatCfg.AVGGroupId][tostring(nGroupId)] -- 按 组id + 索引 找到跳转目标指令 id
        if tbData ~= nil then
            --返回进度
            return tbData.tbTargetCmdId[tostring(nIndex)]
        end
    end
end

function PlayerPhoneData:SetPhoneMsgChoiceEnd(nChatId, nGroupId)
    local chatCfg = ConfigTable.GetData("Chat", nChatId)
    if chatCfg ~= nil then
        nGroupId = tostring(nGroupId)
        local tbData = self.tbPhoneMsgChoiceTarget[chatCfg.AVGId..chatCfg.AVGGroupId][nGroupId] -- 按 组id + 索引 找到跳转目标指令 id
        if tbData ~= nil then
            --返回进度
            return tbData.nEndCmdId
        end
    end
end

function PlayerPhoneData:GetTopCount()
    local nTopCount = 0
    for k, v in pairs(self.tbAddressBook) do
        if v.bTop then nTopCount = nTopCount + 1 end
    end
    return nTopCount
end

function PlayerPhoneData:SetPhoneTopStatus(nAddressId, bTop)
    -- 告知服务器记录置顶信息
    local callback = function(...) end
    HttpNetHandler.SendMsg(NetMsgId.Id.phone_contacts_top_req, {Value = nAddressId},nil, callback)
    -- 客户端数据自己更新
    self.tbAddressBook[nAddressId].bTop = bTop
    if bTop then 
        self.tbAddressBook[nAddressId].nOptTime = CS.ClientManager.Instance.serverTimeStampWithTimeZone 
    end
end

--region 协议
--请求联系人列表
function PlayerPhoneData:SendAddressListReq(callback)
    HttpNetHandler.SendMsg(NetMsgId.Id.phone_contacts_info_req, { }, nil, callback)
end

--向服务器发送保存进度请求
function PlayerPhoneData:SendChatProcess(nAddressId, nChatId, nProcess, tbSelection, bEnd, callback)
    local httpCall = function(mapMsgData)
        if nil == self.tbHistoryMsg[nChatId] or nil == next(self.tbHistoryMsg[nChatId]) then
            --重置历史聊天记录
            local chatData = self:GetChatData(nAddressId, nChatId)
            self:ParseAvgHistoryPhoneMsgData(nChatId, chatData.avgMsg, nProcess, tbSelection)
        end
        --更新聊天进度
        self:RefreshChatProcess(nAddressId, nChatId, nProcess, tbSelection)
       
        if nil ~= callback then
            callback()
        end
    end
    local netMsg = {
        ChatId = nChatId,
        Options = tbSelection,
        Process = nProcess,
        End = bEnd,
    }
    HttpNetHandler.SendMsg(NetMsgId.Id.phone_contacts_report_req, netMsg, nil, httpCall)
end
--endregion
function PlayerPhoneData:OnEvent_AfterEnterMain()
    --self:CheckNewChat()
end

return PlayerPhoneData