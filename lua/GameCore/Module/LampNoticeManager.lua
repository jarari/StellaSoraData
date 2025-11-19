local LampNoticeManager = {}
local TimerManager = require("GameCore.Timer.TimerManager")
local Event = (require("GameCore.Event.Event"))
local objNoticePanel, totalTimer, intervalTimer = nil, nil, nil
local CreateLampNoticePanel = function()
  -- function num : 0_0 , upvalues : _ENV, objNoticePanel
  local noticePanel = require("Game.UI.LampNotice.LampNoticePanel")
  objNoticePanel = (noticePanel.new)((AllEnum.UI_SORTING_ORDER).LampNotice, PanelId.LampNoticePanel, {})
  objNoticePanel:_PreEnter()
  objNoticePanel:_Enter()
end

local HideLampNotice = function(_, isDelay)
  -- function num : 0_1 , upvalues : intervalTimer, totalTimer, _ENV
  if intervalTimer ~= nil then
    intervalTimer:_Stop()
    intervalTimer = nil
  end
  if totalTimer ~= nil then
    totalTimer:_Stop()
    totalTimer = nil
  end
  ;
  (EventManager.Hit)("CloseLampNotice", isDelay)
end

local ShowLampNotice = function(_, noticeData)
  -- function num : 0_2 , upvalues : HideLampNotice, totalTimer, TimerManager, _ENV, intervalTimer
  HideLampNotice(nil, false)
  local stopLampNotice = function()
    -- function num : 0_2_0 , upvalues : HideLampNotice
    HideLampNotice(nil, false)
  end

  totalTimer = (TimerManager.Add)(1, noticeData.nTotalTime, nil, stopLampNotice, true, true, false, nil)
  local showNoticeUI = function()
    -- function num : 0_2_1 , upvalues : _ENV, noticeData
    (EventManager.Hit)("ShowNoticeContent", noticeData.sContent, noticeData.nShowTime)
  end

  local nCount = noticeData.nTotalTime // noticeData.nIntervalTime
  intervalTimer = (TimerManager.Add)(nCount, noticeData.nIntervalTime, nil, showNoticeUI, true, true, false, nil)
  ;
  (EventManager.Hit)("ShowNoticeContent", noticeData.sContent, noticeData.nShowTime)
end

local NoticeChangeNotify = function(_, msgData)
  -- function num : 0_3 , upvalues : _ENV, HideLampNotice, ShowLampNotice
  if not (UTILS.CheckChannelList_Notice)(msgData.Channel) then
    return 
  end
  if msgData.IsStop then
    HideLampNotice(nil, false)
    return 
  end
  local noticeData = {sContent = msgData.Content, nShowTime = msgData.Duration, nIntervalTime = msgData.Interval, nTotalTime = msgData.EndTime - ((CS.ClientManager).Instance).serverTimeStamp}
  ShowLampNotice(_, noticeData)
end

local Uninit = function()
  -- function num : 0_4 , upvalues : _ENV, LampNoticeManager, NoticeChangeNotify, ShowLampNotice, HideLampNotice, Uninit
  (EventManager.Remove)("NoticeChangeNotify", LampNoticeManager, NoticeChangeNotify)
  ;
  (EventManager.Remove)(EventId.OpenLampNotice, LampNoticeManager, ShowLampNotice)
  ;
  (EventManager.Remove)(EventId.CloseLampNotice, LampNoticeManager, HideLampNotice)
  ;
  (EventManager.Remove)(EventId.CSLuaManagerShutdown, LampNoticeManager, Uninit)
end

LampNoticeManager.Init = function()
  -- function num : 0_5 , upvalues : CreateLampNoticePanel, _ENV, LampNoticeManager, NoticeChangeNotify, ShowLampNotice, HideLampNotice, Uninit
  CreateLampNoticePanel()
  ;
  (EventManager.Add)("NoticeChangeNotify", LampNoticeManager, NoticeChangeNotify)
  ;
  (EventManager.Add)(EventId.OpenLampNotice, LampNoticeManager, ShowLampNotice)
  ;
  (EventManager.Add)(EventId.CloseLampNotice, LampNoticeManager, HideLampNotice)
  ;
  (EventManager.Add)(EventId.CSLuaManagerShutdown, LampNoticeManager, Uninit)
end

return LampNoticeManager

