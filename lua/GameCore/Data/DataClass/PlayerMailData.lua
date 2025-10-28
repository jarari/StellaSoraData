-- 玩家邮件数据
local PlayerMailData = class("PlayerMailData")
local TimerManager = require "GameCore.Timer.TimerManager"

function PlayerMailData:Init()
    self.bisNew = false
    EventManager.Add(EventId.UpdateWorldClass, self, self.UpdateWorldClass)
    self._mapMail = {}
    self.bNeedUpdate = true

    self.funcCallBack = nil
    self.isOpen = false
    self.delayCallOpen = nil
    self.bInitRedDot = false
    self:StopDeadLineTimer()
 --[[{
        [Id] = {
            uint32 Id = 1;
            string Subject = 2;//主题
            string Desc = 3;   //描述
            --uint32 Source = 4; //来源 比如：系统0，运营1，角色2
            uint32 TemplateId = 4;  //模板id
            string Author = 5; //作者,根据不同的来源，填充不同的内容，角色应该是填写ID
            int64 Time = 6;    //生成时间戳
            int64 Deadline = 7;//过期时间戳
            bool Read = 8;     //true为已读
            bool Recv = 9;     //true为已领
            repeated ItemTpl Attachments = 10;
            uint64 Flag = 11;//与ID配合区分邮件
            repeated string SubjectArgs = 12; // 标题可配参数
            repeated string DescArgs = 13; // 内容可配参数
            uint32 SurveyCid; 
            
        }
    }
]]
end

function PlayerMailData:HandleDefaultMail(tab)
    local id = tab.Id
    local dMsg = ConfigTable.GetData("MailTemplate", tab.TemplateId)

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
        if tab.Attachments == nil or #tab.Attachments == 0 then
            if tab.Read then
                tab.Recv = true
            end
        end
        tab.Icon = dMsg.Icon
        tab.LetterPaper = dMsg.LetterPaper
        --local tabProp = {}
        --for i = 1, 6 do
        --    if dMsg["Props" .. i] ~= 0 then
        --        local tabItem = {}
        --        tabItem.Tid = dMsg["Props" .. i]
        --        tabItem.Qty = dMsg["PropsCount" .. i]
        --        table.insert(tabProp,tabItem)
        --    end
        --end
        --tab.Attachments = tabProp
    end
    return tab
end

function PlayerMailData:CacheMailData(mapData)
    self.bNeedUpdate = false
    self.bisNew = false
    self._mapMail = {}
    if mapData == nil then
        --self._mapMail = {}
        self:RunCallBack()
        self:StopDeadLineTimer()
    else
        if mapData.List == nil then
            --self._mapMail = {}
            self:RunCallBack()
            self:StopDeadLineTimer()
            return
        end
        for _, mapMail in ipairs(mapData.List) do
            --printError("mapMail Id ==== " .. mapMail.Id)
            if mapMail.TemplateId == 0 then
                self._mapMail[mapMail.Id] = mapMail
            else
                local _data = self:HandleDefaultMail(mapMail)
                self._mapMail[mapMail.Id] = _data
            end
        end
        self:RunCallBack()
        self:StartDeadLineTimer()
    end

    if not self.bInitRedDot then
        --登录时服务器下发  本地不再检查是否有未读邮件
        --self:UpdateMailUnReadRedDot()
        self.bInitRedDot = true
    end
    self:UpdateMailUnReceiveRedDot()
end

function PlayerMailData:UpdateMailRed(isNew)
    self.bisNew = isNew
    if PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.Mail) then
        if isNew then
            RedDotManager.SetValid(RedDotDefine.Mail_UnRead, nil, true)
        end
        self.bisNew = false
    end
end

function PlayerMailData:UpdateWorldClass()
    if PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.Mail) then
        RedDotManager.SetValid(RedDotDefine.Mail_UnRead, nil, self.bisNew)
        self.bisNew = false
    end
end

--收到服务器推送刷新邮件
function PlayerMailData:UpdateMailList(mapMsgData)
    self.bisNew = true
    self.bNeedUpdate = true
    if PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.Mail) then
        if mapMsgData.New then
            RedDotManager.SetValid(RedDotDefine.Mail_New, nil, true)
        end
    end
    EventManager.Hit("GetAllMailList")
end

function PlayerMailData:ReceiveMailItem(mapData)
    local tabItem = {}
    local tmpTab = {}
    if type(mapData.Ids) == "table" then
        for i = 1, #mapData.Ids do
            if self._mapMail[mapData.Ids[i]] ~= nil then
                self._mapMail[mapData.Ids[i]].Read = true
                self._mapMail[mapData.Ids[i]].Recv = true

                if self._mapMail[mapData.Ids[i]].Attachments and #self._mapMail[mapData.Ids[i]].Attachments > 0 then
                    for k, v in pairs(self._mapMail[mapData.Ids[i]].Attachments) do
                        --table.insert(tabItem, {Tid = v.Tid, Qty = v.Qty})
                        local itemCfg = ConfigTable.GetData("Item",v.Tid)
                        if itemCfg ~= nil and itemCfg.Type ~= GameEnum.itemType.CharacterSkin then
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

        for i, v in pairs(tmpTab) do
            table.insert(tabItem, {Tid = i, Qty = v})
        end

        --Type小的在前  Rarity小的在前 tid小的在前
        --一键领取时，获得道具按照道具类型（资源>心相风景>礼物>其他）>稀有度由高到低>道具tid由低到高的顺序排序
        --UTILS.OpenReceiveByChangeInfo(mapData.Items)
        UTILS.OpenReceiveByDisplayItem(tabItem, mapData.Items, function()
            PlayerData.Base:TryOpenWorldClassUpgrade()
        end)
    end
    self:RunCallBack()

    --刷新红点
    self:UpdateMailUnReceiveRedDot()
end

function PlayerMailData:ReadMail(mapMsgData)
    --printError("mapMsgData === " .. mapMsgData.Value)
    if self._mapMail[mapMsgData.Value] ~= nil then
        self._mapMail[mapMsgData.Value].Read = true
        if self._mapMail[mapMsgData.Value].Attachments == nil or #self._mapMail[mapMsgData.Value].Attachments == 0 then
            self._mapMail[mapMsgData.Value].Recv = true
        end
    end
    self:RunCallBack()
end

function PlayerMailData:RemoveMail(mapData)
    if type(mapData.Ids) == "table" then
        for i = 1, #mapData.Ids do
            --printError(mapData.Ids[i] .. "RemoveMail")
            if self._mapMail[mapData.Ids[i]] ~= nil then
                --printError(mapData.Ids[i] .. "  RemoveMail****")
                self._mapMail[mapData.Ids[i]] = nil
            end
        end
    end
    local wait = function()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        self:RunCallBack()
    end
    cs_coroutine.start(wait)
end

function PlayerMailData:GetAgainAllMain()
    local function fCb()
        EventManager.Hit("OnEvent_RefrushMailGroup")
    end
    self.funcCallBack = fCb
    self:SengMsgMailList()
end

function PlayerMailData:SengMsgMailList(callback)
    HttpNetHandler.SendMsg(NetMsgId.Id.mail_list_req, {}, nil, callback)
end

--收到服务器推送时更新红点显示状态
function PlayerMailData:RefreshMailRedDot(mapMsgData)
    if PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.Mail) then
        if mapMsgData.New then
            --有新邮件更新红点
            RedDotManager.SetValid(RedDotDefine.Mail_New, nil, true)
        end
    end
end

function PlayerMailData:GetAllMail(func_callBack, isOpen)
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

function PlayerMailData:RunCallBack()
    --邮件界面打开请求信息时有callBack
    if self.funcCallBack then
        self.funcCallBack()
        self.funcCallBack = nil
    end
    if self.isOpen then
        local func = function() EventManager.Hit(EventId.OpenPanel, PanelId.Mail) end
        EventManager.Hit(EventId.SetTransition, 5, func)
        self.isOpen = false
        local time = CS.ClientManager.Instance.serverTimeStamp
        local hour = tonumber(os.date("%H",time))
        local minute = tonumber(os.date("%M",time))
        local second = tonumber(os.date("%S",time))

        local delaySec = 86400 + 3600 * 4 - hour * 3600 - minute * 60 - second
        --printError("delaySec === " .. delaySec)
        self.delayCallOpen = TimerManager.Add(1, delaySec, self, self["DelayTimeCallMsg"], true, true, false)
    end
end

function PlayerMailData:CheckMailDeadLine()
    local bNeedRefresh = false
    for id, v in pairs(self._mapMail) do
        if v.Deadline ~= 0 and not self.tbDeadLineCheckList[id] then
            local remainTime = v.Deadline - CS.ClientManager.Instance.serverTimeStamp
            --邮件已过期
            if remainTime <= 0 then
                self.tbDeadLineCheckList[id] = true
                bNeedRefresh = true
                break
            end
        end
    end

    if bNeedRefresh then
        --有过期邮件，重新刷新红点和UI显示
        self:UpdateMailUnReceiveRedDot()
        EventManager.Hit("GetAllMailList")
    end
end

--本地检查邮件是否已过期，有邮件过期时需要刷新红点及UI
function PlayerMailData:StartDeadLineTimer()
    if nil == self.timerMailDeadLine then
        self.timerMailDeadLine = TimerManager.Add(0, 10, self, self.CheckMailDeadLine, true, true, false)
    end
end

function PlayerMailData:StopDeadLineTimer()
    if nil ~= self.timerMailDeadLine then
        TimerManager.Remove(self.timerMailDeadLine, false)
    end
    self.timerMailDeadLine = nil
    self.tbDeadLineCheckList = {}
end

function PlayerMailData:DelayTimeCallMsg()
    if self.bNeedUpdate then
        local function cb()
            EventManager.Hit(EventId.RefrushMailView)
        end
        self:GetAllMail(cb,false)
    end

    self:CancelTimeDelay()
    --一直打开的情况下重新注册
    local time = CS.ClientManager.Instance.serverTimeStamp
    local hour = tonumber(os.date("%H",time))
    local minute = tonumber(os.date("%M",time))
    local second = tonumber(os.date("%S",time))

    local delaySec = 86400 + 3600 * 4 - hour * 3600 - minute * 60 - second
    --printError("delaySec === " .. delaySec)
    self.delayCallOpen = TimerManager.Add(1, delaySec, self, self["DelayTimeCallMsg"], true, true, false)
end

--领取奖励 一键领取发送0，单独领取发送对应邮件ID上来
function PlayerMailData:SendMailRecvReq(id,flag,callback)
    if callback then
        self.funcCallBack = callback
    end
    local skinCachClearCb = function(_, mapMsgData) 
        PlayerData.CharSkin:TryOpenSkinShowPanel(function() PlayerData.Mail:ReceiveMailItem(mapMsgData) end)
        if callback then callback() end
    end
    --printError("SendMailRecvReq === " .. id .. "   " .. flag)
    local sendMsgBody = {Id = id,Flag = flag}
    HttpNetHandler.SendMsg(NetMsgId.Id.mail_recv_req, sendMsgBody, nil, skinCachClearCb)
end

--获取问卷数据
function PlayerMailData:SendMailGetSurveryMsg(id,callback)
    if callback then
        self.funcCallBack = callback
    end
    --printError("SendMailGetSurveryMsg ===".. id)
    local sendMsgBody = {SurveyId = id}
    HttpNetHandler.SendMsg(NetMsgId.Id.player_survey_req, sendMsgBody, nil, callback)
end

--标记邮件已读
function PlayerMailData:SendMailReadReq(id,flag,callback)
    --if callback then
    --    self.funcCallBack = callback
    --end
    --printError("id === *** " .. id .. "   " .. flag)
    local sendMsgBody = {Id = id,Flag = flag}
    HttpNetHandler.SendMsg(NetMsgId.Id.mail_read_req, sendMsgBody, nil, callback)
end

--删除邮件 一键删除所有已读已领发送0，单独删除发送对应邮件ID上来
function PlayerMailData:SendMailRemoveReq(id,flag,callback)
    if callback then
        self.funcCallBack = callback
    end
    --printError("SendMailRemoveReq === " .. id .. "   " .. flag)
    local sendMsgBody = {Id = id,Flag = flag}
    HttpNetHandler.SendMsg(NetMsgId.Id.mail_remove_req, sendMsgBody, nil, callback)
end

--标记邮件或者解除标记
function PlayerMailData:SendMailPin(id,flag,isPin,callback)
    local sendMsgBody = {Id = id,Flag = flag,Pin = isPin}
    local function cb(_,mapMsgData)
        self._mapMail[mapMsgData.Id].Flag = mapMsgData.Flag
        self._mapMail[mapMsgData.Id].Pin = mapMsgData.Pin
        callback()
    end
    HttpNetHandler.SendMsg(NetMsgId.Id.mail_pin_req, sendMsgBody, nil, cb)
end

function PlayerMailData:CancelTimeDelay()
    if self.delayCallOpen then
        self.delayCallOpen:Cancel(nil)
        self.delayCallOpen = nil
    end
end

function PlayerMailData:ClearFunCallBack()
    if self.funcCallBack then
        self.funcCallBack = nil
    end
end

------------------ 红点相关 ---------
--有未读邮件时显示红点，点击查看后消失
--有未领取奖励邮件时显示红点，奖励领取后消失
--本次登录中收到新邮件时重新显示红点
function PlayerMailData:UpdateMailUnReadRedDot()
    local bUnRead = false
    for _, mail in pairs(self._mapMail) do
        if not mail.Read then
            bUnRead = true
            break
        end
    end
    RedDotManager.SetValid(RedDotDefine.Mail_UnRead, nil, bUnRead)
end

function PlayerMailData:UpdateMailUnReceiveRedDot()
    local nUnReceive = false
    for _, mail in pairs(self._mapMail) do
        --有附件检查是否已领取
        if (mail.Deadline == 0 or CS.ClientManager.Instance.serverTimeStamp < mail.Deadline) and mail.Attachments and #mail.Attachments > 0 and not mail.Recv then
            nUnReceive = true
            break
        end
    end
    RedDotManager.SetValid(RedDotDefine.Mail_UnReceive, nil, nUnReceive)
end

return PlayerMailData