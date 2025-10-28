local GameResourceLoader = require "Game.Common.Resource.GameResourceLoader"
local TimerManager = require "GameCore.Timer.TimerManager"
local AvgManager = {}
local objAvgPanel = nil
local objAvgBubblePanel = nil   -- avg气泡
local nTransitionType = 0
local function OnEvent_AvgBBEnd(_)
    if objAvgBubblePanel ~= nil then
        objAvgBubblePanel:_PreExit()
        objAvgBubblePanel:_Exit()
        objAvgBubblePanel:_Destroy()
        objAvgBubblePanel = nil
    end
end
local function OnEvent_AvgBBStart(_, sAvgId, sGroupId, sLanguage, sVoLan)
    OnEvent_AvgBBEnd(_)
    local AvgBubblePanel = require "Game.UI.AvgBubble.AvgBubblePanel"
    if sLanguage == nil then sLanguage = Settings.sCurrentTxtLanguage end
    if sVoLan == nil then sVoLan = Settings.sCurrentVoLanguage end
    objAvgBubblePanel = AvgBubblePanel.new(AllEnum.UI_SORTING_ORDER.AVG_Bubble, PanelId.AvgBB, {sAvgId, sGroupId, sLanguage, sVoLan})
    objAvgBubblePanel:_PreEnter()
    objAvgBubblePanel:_Enter()
end
local function OnEvent_AvgSTStart(_, sAvgId, sLanguage, sVoLan, sGroupId, nStartCMDID)

    local func_DoStart = function()
        if sLanguage == nil then sLanguage = Settings.sCurrentTxtLanguage end
        if sVoLan == nil then sVoLan = Settings.sCurrentVoLanguage end
        OnEvent_AvgBBEnd(_) -- BB 处于各功能优先级的低位，触发 ST 时可以强制结束。
        local AvgPanel = require "Game.UI.Avg.AvgPanel"
        objAvgPanel = AvgPanel.new(AllEnum.UI_SORTING_ORDER.AVG_ST, PanelId.AvgST, {sAvgId, sLanguage, sVoLan, sGroupId, nStartCMDID}) -- sLanguage 详见 AllEnum.Language
        objAvgPanel:_PreEnter()
        objAvgPanel:_Enter()
        -- NovaAPI.SetScreenSleepTimeout(true) -- Avg演出里更细分的设置 (Auto On/Off + choice)
    end

    local function func_OnEvent_TransAnimInClear()
        EventManager.Hit(EventId.SetTransition)
        func_DoStart() --TimerManager.Add(1, 0.25, AvgManager, func_DoStart, true, true, true, nil)
    end

    if AVG_EDITOR == true then
        func_DoStart()
    else
        if sAvgId == Settings.sPrologueAvgId1 or sAvgId == Settings.sPrologueAvgId2 then
            EventManager.Hit(EventId.HideProloguePanle, false)
            EventManager.Hit("__CloseLoadingView", nil, nil, 0.5)
            func_DoStart()
        else
            local sAvgIdHead = string.sub(sAvgId, 1, 2)
            if sAvgIdHead == "ST" or sAvgIdHead == "CG" or sAvgIdHead == "DP" then
                nTransitionType = sAvgIdHead == "DP" and 12 or 11 -- 类型12是派遣类演出专用的转场动画需要在派遣类演出结束时播
                EventManager.Hit(EventId.SetTransition, nTransitionType, func_OnEvent_TransAnimInClear)
            else
                func_DoStart() -- 那些不需要转场动画的演出就直接开始播了
            end
        end
    end
end
local function OnEvent_AvgSTEnd(_)

    local function func_DoEnd()
        NovaAPI.DispatchEventWithData("StoryDialog_DialogEnd") -- 通知 C# 侧 AVG 播完了。
        if objAvgPanel ~= nil then
            objAvgPanel:_PreExit()
            objAvgPanel:_Exit()
            objAvgPanel:_Destroy()
            objAvgPanel = nil
            NovaAPI.SetScreenSleepTimeout(false)
        end
        if AVG_EDITOR ~= true then
            GameResourceLoader.Unload("UI", "ui_avg") -- 卸载名为 ui_avg 的 AB（气泡表情、特效、等）
        end
        GameResourceLoader.Unload("ImageAvg") -- 卸载所有 AVG 用的背景图资源
        GameResourceLoader.Unload("Actor2DAvg") -- 卸载所有 AVG 用的角色资源（png + live2d）
    end

    local function func_OnEvent_TransAnimInClear()
        EventManager.Hit(EventId.SetTransition)
        func_DoEnd()
    end

    if nTransitionType ~= 0 then
        EventManager.Hit(EventId.SetTransition, nTransitionType, func_OnEvent_TransAnimInClear)
        nTransitionType = 0
    else
        func_DoEnd()
    end
end
local function Uninit(_)
    -- AvgST
    if objAvgPanel ~= nil then OnEvent_AvgSTEnd(_) end
    EventManager.Remove("StoryDialog_DialogStart", AvgManager, OnEvent_AvgSTStart)
    EventManager.Remove("StoryDialog_DialogEnd", AvgManager, OnEvent_AvgSTEnd)
    -- AvgBB
    OnEvent_AvgBBEnd(_)
    EventManager.Remove(EventId.AvgBubbleShow, AvgManager, OnEvent_AvgBBStart)
    EventManager.Remove(EventId.AvgBubbleExit, AvgManager, OnEvent_AvgBBEnd)
    -- 游戏app关闭
    EventManager.Remove(EventId.CSLuaManagerShutdown, AvgManager, Uninit)
end
function AvgManager.Init()
    -- AvgST
    EventManager.Add("StoryDialog_DialogStart", AvgManager, OnEvent_AvgSTStart)
    EventManager.Add("StoryDialog_DialogEnd", AvgManager, OnEvent_AvgSTEnd)
    -- AvgBB
    EventManager.Add(EventId.AvgBubbleShow, AvgManager, OnEvent_AvgBBStart)
    EventManager.Add(EventId.AvgBubbleExit, AvgManager, OnEvent_AvgBBEnd)
    -- 游戏app关闭
    EventManager.Add(EventId.CSLuaManagerShutdown, AvgManager, Uninit)
end
return AvgManager
