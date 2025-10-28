local LampNoticeManager = {}
local TimerManager=require "GameCore.Timer.TimerManager"
local Event = require("GameCore.Event.Event")

local objNoticePanel=nil

local totalTimer=nil
local intervalTimer=nil

local function CreateLampNoticePanel()
    local noticePanel= require "Game.UI.LampNotice.LampNoticePanel"
    objNoticePanel=noticePanel.new(AllEnum.UI_SORTING_ORDER.LampNotice,PanelId.LampNoticePanel,{})
    objNoticePanel:_PreEnter()
    objNoticePanel:_Enter()
end
local function HideLampNotice(_,isDelay)
    if intervalTimer~=nil then
        intervalTimer:_Stop()
        intervalTimer=nil
    end
    if totalTimer~=nil then
        totalTimer:_Stop()
        totalTimer=nil
    end
    EventManager.Hit("CloseLampNotice",isDelay)
end
---@param noticeData {sContent,nShowTime,nIntervalTime,nTotalTime }
---nShowTime 单次显示的时间 只有固定模式 使用
---nIntervalTime 在不超过总时间的条件下 间隔 nIntervalTime后 重新显示该信息
---nTotalTime 在nTotalTime这段时间 会在指定间隔时间后重新显示该信息
local function ShowLampNotice(_,noticeData)
    --掐掉上一个
    HideLampNotice(nil,false)

    local stopLampNotice=function ()
        HideLampNotice(nil,false)
    end
    totalTimer=TimerManager.Add(1,noticeData.nTotalTime,nil,stopLampNotice,true,true,false,nil)
    local showNoticeUI=function ()
        EventManager.Hit("ShowNoticeContent",noticeData.sContent,noticeData.nShowTime)
    end
    local nCount=noticeData.nTotalTime//noticeData.nIntervalTime
    intervalTimer=TimerManager.Add(nCount,noticeData.nIntervalTime,nil,showNoticeUI,true,true,false,nil)
    EventManager.Hit("ShowNoticeContent",noticeData.sContent,noticeData.nShowTime)
end
local function NoticeChangeNotify(_,msgData)
    if not UTILS.CheckChannelList_Notice(msgData.Channel) then
        return 
    end
    if msgData.IsStop then
        HideLampNotice(nil,false)
        return
    end
    local noticeData={
        sContent=msgData.Content,
        nShowTime=msgData.Duration,
        nIntervalTime=msgData.Interval,
        nTotalTime=msgData.EndTime-CS.ClientManager.Instance.serverTimeStamp,
    }
    ShowLampNotice(_,noticeData)
end

local function Uninit()
    EventManager.Remove("NoticeChangeNotify",LampNoticeManager,NoticeChangeNotify)
    EventManager.Remove(EventId.OpenLampNotice,LampNoticeManager,ShowLampNotice)
    EventManager.Remove(EventId.CloseLampNotice,LampNoticeManager,HideLampNotice)
    --游戏app关闭
    EventManager.Remove(EventId.CSLuaManagerShutdown, LampNoticeManager, Uninit)
end
function LampNoticeManager.Init()
    CreateLampNoticePanel()
    EventManager.Add("NoticeChangeNotify",LampNoticeManager,NoticeChangeNotify)
    EventManager.Add(EventId.OpenLampNotice,LampNoticeManager,ShowLampNotice)
    EventManager.Add(EventId.CloseLampNotice,LampNoticeManager,HideLampNotice)
    --游戏app关闭
    EventManager.Add(EventId.CSLuaManagerShutdown, LampNoticeManager, Uninit)
end

return LampNoticeManager
