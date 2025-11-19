local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
local TimerManager = require("GameCore.Timer.TimerManager")
local AvgManager = {}
local objAvgPanel, objAvgBubblePanel = nil, nil
local nTransitionType = 0
local bInAvg = false
local OnEvent_AvgBBEnd = function(_)
  -- function num : 0_0 , upvalues : objAvgBubblePanel
  if objAvgBubblePanel ~= nil then
    objAvgBubblePanel:_PreExit()
    objAvgBubblePanel:_Exit()
    objAvgBubblePanel:_Destroy()
    objAvgBubblePanel = nil
  end
end

local OnEvent_AvgBBStart = function(_, sAvgId, sGroupId, sLanguage, sVoLan)
  -- function num : 0_1 , upvalues : OnEvent_AvgBBEnd, _ENV, objAvgBubblePanel
  OnEvent_AvgBBEnd(_)
  local AvgBubblePanel = require("Game.UI.AvgBubble.AvgBubblePanel")
  if sLanguage == nil then
    sLanguage = Settings.sCurrentTxtLanguage
  end
  if sVoLan == nil then
    sVoLan = Settings.sCurrentVoLanguage
  end
  objAvgBubblePanel = (AvgBubblePanel.new)((AllEnum.UI_SORTING_ORDER).AVG_Bubble, PanelId.AvgBB, {sAvgId, sGroupId, sLanguage, sVoLan})
  objAvgBubblePanel:_PreEnter()
  objAvgBubblePanel:_Enter()
end

local OnEvent_AvgSTStart = function(_, sAvgId, sLanguage, sVoLan, sGroupId, nStartCMDID, sTransStyle)
  -- function num : 0_2 , upvalues : _ENV, bInAvg, OnEvent_AvgBBEnd, objAvgPanel, nTransitionType
  local nStyle = 11
  if type(sTransStyle) == "string" and sTransStyle ~= "" then
    local sStyle = (string.gsub)(sTransStyle, "style_", "")
    local _n = tonumber(sStyle)
    if type(_n) == "number" then
      nStyle = _n
    end
  end
  do
    bInAvg = true
    local func_DoStart = function()
    -- function num : 0_2_0 , upvalues : sLanguage, _ENV, sVoLan, OnEvent_AvgBBEnd, _, objAvgPanel, sAvgId, sGroupId, nStartCMDID
    if sLanguage == nil then
      sLanguage = Settings.sCurrentTxtLanguage
    end
    if sVoLan == nil then
      sVoLan = Settings.sCurrentVoLanguage
    end
    OnEvent_AvgBBEnd(_)
    local AvgPanel = require("Game.UI.Avg.AvgPanel")
    objAvgPanel = (AvgPanel.new)((AllEnum.UI_SORTING_ORDER).AVG_ST, PanelId.AvgST, {sAvgId, sLanguage, sVoLan, sGroupId, nStartCMDID})
    objAvgPanel:_PreEnter()
    objAvgPanel:_Enter()
  end

    local func_OnEvent_TransAnimInClear = function()
    -- function num : 0_2_1 , upvalues : _ENV, func_DoStart
    (EventManager.Hit)(EventId.SetTransition)
    func_DoStart()
  end

    if AVG_EDITOR == true then
      func_DoStart()
    else
      if sAvgId == Settings.sPrologueAvgId1 or sAvgId == Settings.sPrologueAvgId2 then
        (EventManager.Hit)(EventId.HideProloguePanle, false)
        ;
        (EventManager.Hit)("__CloseLoadingView", nil, nil, 0.5)
        func_DoStart()
      else
        local sAvgIdHead = (string.sub)(sAvgId, 1, 2)
        if sAvgIdHead ~= "DP" or not 12 then
          nTransitionType = sAvgIdHead ~= "ST" and sAvgIdHead ~= "CG" and sAvgIdHead ~= "DP" or nStyle
          ;
          (EventManager.Hit)(EventId.SetTransition, nTransitionType, func_OnEvent_TransAnimInClear)
          func_DoStart()
        end
      end
    end
  end
end

local OnEvent_AvgSTEnd = function(_)
  -- function num : 0_3 , upvalues : _ENV, objAvgPanel, GameResourceLoader, bInAvg, nTransitionType
  local func_DoEnd = function()
    -- function num : 0_3_0 , upvalues : _ENV, objAvgPanel, GameResourceLoader, bInAvg
    (NovaAPI.DispatchEventWithData)("StoryDialog_DialogEnd")
    if objAvgPanel ~= nil then
      objAvgPanel:_PreExit()
      objAvgPanel:_Exit()
      objAvgPanel:_Destroy()
      objAvgPanel = nil
      ;
      (NovaAPI.SetScreenSleepTimeout)(false)
    end
    if AVG_EDITOR ~= true then
      (GameResourceLoader.Unload)("UI", "ui_avg")
    end
    ;
    (GameResourceLoader.Unload)("ImageAvg")
    ;
    (GameResourceLoader.Unload)("Actor2DAvg")
    bInAvg = false
  end

  local func_OnEvent_TransAnimInClear = function()
    -- function num : 0_3_1 , upvalues : _ENV, func_DoEnd
    (EventManager.Hit)(EventId.SetTransition)
    func_DoEnd()
  end

  if nTransitionType ~= 0 then
    if nTransitionType == 12 then
      func_DoEnd()
    else
      ;
      (EventManager.Hit)(EventId.SetTransition, nTransitionType, func_OnEvent_TransAnimInClear)
    end
    nTransitionType = 0
  else
    func_DoEnd()
  end
end

local Uninit = function(_)
  -- function num : 0_4 , upvalues : objAvgPanel, OnEvent_AvgSTEnd, _ENV, AvgManager, OnEvent_AvgSTStart, OnEvent_AvgBBEnd, OnEvent_AvgBBStart, Uninit
  if objAvgPanel ~= nil then
    OnEvent_AvgSTEnd(_)
  end
  ;
  (EventManager.Remove)("StoryDialog_DialogStart", AvgManager, OnEvent_AvgSTStart)
  ;
  (EventManager.Remove)("StoryDialog_DialogEnd", AvgManager, OnEvent_AvgSTEnd)
  OnEvent_AvgBBEnd(_)
  ;
  (EventManager.Remove)(EventId.AvgBubbleShow, AvgManager, OnEvent_AvgBBStart)
  ;
  (EventManager.Remove)(EventId.AvgBubbleExit, AvgManager, OnEvent_AvgBBEnd)
  ;
  (EventManager.Remove)(EventId.CSLuaManagerShutdown, AvgManager, Uninit)
end

AvgManager.Init = function()
  -- function num : 0_5 , upvalues : _ENV, AvgManager, OnEvent_AvgSTStart, OnEvent_AvgSTEnd, OnEvent_AvgBBStart, OnEvent_AvgBBEnd, Uninit
  (EventManager.Add)("StoryDialog_DialogStart", AvgManager, OnEvent_AvgSTStart)
  ;
  (EventManager.Add)("StoryDialog_DialogEnd", AvgManager, OnEvent_AvgSTEnd)
  ;
  (EventManager.Add)(EventId.AvgBubbleShow, AvgManager, OnEvent_AvgBBStart)
  ;
  (EventManager.Add)(EventId.AvgBubbleExit, AvgManager, OnEvent_AvgBBEnd)
  ;
  (EventManager.Add)(EventId.CSLuaManagerShutdown, AvgManager, Uninit)
end

AvgManager.CheckInAvg = function()
  -- function num : 0_6 , upvalues : bInAvg
  return bInAvg
end

return AvgManager

