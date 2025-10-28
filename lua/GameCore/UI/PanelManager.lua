-- 界面管理
local TimerManager = require "GameCore.Timer.TimerManager"
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
local ClientMgr = CS.ClientManager
local AdventureModuleHelper = CS.AdventureModuleHelper
local PanelManager = {}
local mapUIRootTransform = nil
local mapDefinePanel = nil
local objCurPanel = nil
local objNextPanel = nil
local tbBackHistory = nil
local tbDisposablePanel = nil -- 非主 Panel 不参与回退历史，应附属于某个主 Panel 且自行控制开关逻辑
local trSnapshotParent = nil
local tbTemplateSnapshot = nil
local nThresholdHistoryPanelCount = nil
local objTransitionPanel = nil -- 界面切换转场Panel
local bMainViewSkipAnimIn = nil -- 主界面专用的动画控制变量
local nInputRC = 0
local tbGoSnapShot = nil    -- 低内存模式下截屏实例
local objPlayerInfoPanel=nil --玩家UID

local function OnClearRequiredLua(listener, strPath)
    printLog("[Lua重载] 清除了：" .. strPath)
    package.loaded[strPath] = nil
end
local function TakeSnapshot(nType)
    local goSnapshotIns = nil
    if nType <= 0 or tbTemplateSnapshot == nil then return goSnapshotIns end
    local goT = tbTemplateSnapshot[nType]
    if goT ~= nil and goT:IsNull() == false then
        goSnapshotIns = instantiate(goT, trSnapshotParent)
        goSnapshotIns:SetActive(true)
        local goUIEffectSnapshot
        if nType == 1 or nType == 3 or nType == 4 then
            goUIEffectSnapshot = goSnapshotIns.transform:GetChild(0).gameObject
        else
            goUIEffectSnapshot = goSnapshotIns
        end
        NovaAPI.UIEffectSnapShotCapture(goUIEffectSnapshot)
    end
    return goSnapshotIns
end
local function GetPanelName(nPanelId)
    for k, v in pairs(PanelId) do
        if v == nPanelId then
            return k
        end
    end
end
---------- 界面切换流程 ---------- begin
local function AddTbGoSnapShot(nPanelId, goIns)
    if Settings.bDestroyHistoryUIInstance then
        if tbGoSnapShot == nil then
            tbGoSnapShot = {}
        end
        if goIns ~= nil then
            tbGoSnapShot[nPanelId] = {goIns = goIns, bMove = false}
        end
    end
end
local function MoveSnapShot(nPanelId)
    if Settings.bDestroyHistoryUIInstance and tbGoSnapShot[nPanelId] ~= nil then
        tbGoSnapShot[nPanelId].bMove = true
        tbGoSnapShot[nPanelId].goIns.gameObject.transform:SetParent(trSnapshotParent)
    end
end
local function GetSnapShot(nPanelId)
    if Settings.bDestroyHistoryUIInstance and tbGoSnapShot[nPanelId] ~= nil then
        tbGoSnapShot[nPanelId].bMove = false
        tbGoSnapShot[nPanelId].goIns.gameObject:SetActive(true)
        return tbGoSnapShot[nPanelId].goIns
    end
end
local function HideMoveSnapshot()
    --单独加隐藏方法是避免出现 下一个打开的界面也需要截屏，提前隐藏会截到黑屏问题
    if Settings.bDestroyHistoryUIInstance and tbGoSnapShot ~= nil then
        for _, v in pairs(tbGoSnapShot) do
            if v.bMove and v.goIns ~= nil then
                v.goIns.gameObject:SetActive(false)
            end
        end
    end
end
local function RemoveTbSnapShot(nPanelId)
    if Settings.bDestroyHistoryUIInstance and tbGoSnapShot[nPanelId] ~= nil then
        local goIns = tbGoSnapShot[nPanelId].goIns
        if goIns ~= nil then
            destroy(goIns)
        end
        tbGoSnapShot[nPanelId] = nil
    end
end
local function CheckThresholdCount()
    if nThresholdHistoryPanelCount == nil then 
        nThresholdHistoryPanelCount = ConfigTable.GetConfigNumber("MaxHistoryPanel")
    end
    local nCurCount = #tbBackHistory
    if nCurCount > nThresholdHistoryPanelCount then
        local nDelCount = nCurCount - nThresholdHistoryPanelCount -- 需要移除的数量
        local tbNeedRemovePanelIndex = {}
        for i = 1, nCurCount, 1 do
            if tbBackHistory[i]._nPanelId ~= PanelId.MainView then
                table.insert(tbNeedRemovePanelIndex, i)
                nDelCount = nDelCount - 1
                if nDelCount <= 0 then break end
            end
        end
        nDelCount = #tbNeedRemovePanelIndex
        if nDelCount == nCurCount - nThresholdHistoryPanelCount then
            for i = nDelCount, 1, -1 do
                local nPanelIndex = tbNeedRemovePanelIndex[i]
                RemoveTbSnapShot(tbBackHistory[nPanelIndex]._nPanelId)
                tbBackHistory[nPanelIndex]:_Exit()
                tbBackHistory[nPanelIndex]:_Destroy()
                table.remove(tbBackHistory, nPanelIndex)
            end
            -- TODO:需要刷新一下当前还在历史队列中的 Panel 以及非主 Panel 的 self._nIndex 当它们下次执行 _Enter() 时会重设 Canvas.sortingOrder
        end
    end
end
local function DoBackToTarget(nTargetIndex)
    if type(nTargetIndex) ~= "number" then
        nTargetIndex = 1
    end
    local nCount = #tbBackHistory
    if nCount > nTargetIndex and objCurPanel ~= nil then
        local function func_PreExitDone()
            if objCurPanel._bAddToBackHistory == true then
                table.remove(tbBackHistory, nCount)
            end
            nCount = #tbBackHistory
            for i = nCount, nTargetIndex + 1, -1 do
                local objPanel = tbBackHistory[i]
                RemoveTbSnapShot(objPanel._nPanelId)
                objPanel:_PreExit()
                objPanel:_Exit()
                objPanel:_Destroy()
                table.remove(tbBackHistory, i)
            end
            local objBackPanel = tbBackHistory[nTargetIndex]
            if type(objBackPanel.Awake) == "function" then
                objBackPanel:Awake()
            end
            local goSnapshot = GetSnapShot(objBackPanel._nPanelId)
            objBackPanel:_PreEnter(nil, goSnapshot)
            objCurPanel:_Exit()
            objBackPanel:_Enter()
            objCurPanel:_Destroy()
            objCurPanel = objBackPanel
            printLog("[界面切换] 已返回至历史队列指定的索引：" .. tostring(nTargetIndex) .. "，界面：" .. GetPanelName(objCurPanel._nPanelId))
        end
        objCurPanel:_PreExit(func_PreExitDone, true)
    end

    PanelManager.CloseAllDisposablePanel()
end
local function CloseCurPanel()
    local nLastIndex = #tbBackHistory
    if objCurPanel == nil then
        return
    end
    if (objCurPanel._bAddToBackHistory ~= true) or (objCurPanel._bAddToBackHistory == true and nLastIndex > 1) then
        local function func_DoBack()
            if objCurPanel._bAddToBackHistory == true then
                table.remove(tbBackHistory, nLastIndex)
            end
            nLastIndex = #tbBackHistory
            local objBackPanel = tbBackHistory[nLastIndex]
            --[[ if Settings.bDestroyHistoryUIInstance then -- 销毁历史队列中 UI prefab 实例时，在返回它时，不应该再 Awake 一下，因为 Awake 中一般都是初始化时定义一些变量的初始值。
                if type(objBackPanel.Awake) == "function" then
                    objBackPanel:Awake()
                end
            end ]]
            local goSnapshot = GetSnapShot(objBackPanel._nPanelId)
            objBackPanel:_PreEnter(nil, goSnapshot)
            objCurPanel:_Exit()
            objBackPanel:_Enter()
            objCurPanel:_Destroy()
            objCurPanel = objBackPanel
            objCurPanel:_AfterEnter()
            printLog("[界面切换] 已完成：关闭当前并打开历史队列的最后一个， 当前打开的界面：" .. GetPanelName(objCurPanel._nPanelId))
        end
        RemoveTbSnapShot(objCurPanel._nPanelId)
        objCurPanel:_PreExit(func_DoBack, true)
    end
end
local function ClosePanel(nPanelId)
    if objCurPanel ~= nil then
        if objCurPanel._nPanelId == nPanelId then
            CloseCurPanel()
        else
            local nCount = #tbBackHistory
            for i = nCount, 1, -1 do
                local objPanel = tbBackHistory[i]
                if objPanel._nPanelId == nPanelId then
                    table.remove(tbBackHistory, i)
                    objPanel:_Destroy()
                    RemoveTbSnapShot(objPanel._nPanelId)
                    objPanel = nil
                    printLog("[界面切换] 仅关闭指定的界面：" .. GetPanelName(nPanelId))
                    -- TODO:需要刷新一下当前还在历史队列中的 Panel 以及非主 Panel 的 self._nIndex 当它们下次执行 _Enter() 时会重设 Canvas.sortingOrder
                    break
                end
            end
        end
    end
end
local function OnClosePanel(listener, nPanelId)
    if objNextPanel ~= nil then
        printError("[界面切换] 关闭界面：" .. GetPanelName(nPanelId) .. " 失败，上一次界面切换流程尚未完成，正在处理：" .. GetPanelName(objNextPanel._nPanelId))
        return
    end
    if type(nPanelId) == "number" then -- 处理关闭指定 id 的 panel
        local bIsMainPanel = true
        if type(tbDisposablePanel) == "table" then
            for i, v in ipairs(tbDisposablePanel) do
                if v._nPanelId == nPanelId then
                    EventManager.Hit("Guide_CloseDisposablePanel", nPanelId)
                    v:_PreExit()
                    v:_Exit()
                    v:_Destroy()
                    table.remove(tbDisposablePanel, i)
                    RemoveTbSnapShot(v._nPanelId)
                    bIsMainPanel = false
                    printLog("[界面切换] 关闭了非主 Panel 界面：" .. GetPanelName(nPanelId))
                    break
                end
            end
        end
        if bIsMainPanel == true then
            ClosePanel(nPanelId)
        end
    end
end
local function OnCloseCurPanel(listener)
    if objCurPanel ~= nil and objCurPanel._bIsMainPanel == true then
        CloseCurPanel()
    end
end
local function EnterNext()
    -- 下个界面根据数据初始化及设置排序层级最后在其淡入的同时销毁当前界面预设体实例
    objNextPanel:_Enter(true)
    if objCurPanel ~= nil then
        if objCurPanel._bAddToBackHistory == true then
            objCurPanel:_SetPrefabInstance(Settings.bDestroyHistoryUIInstance)
        else
            objCurPanel:_Destroy()
        end
    end
    objCurPanel = objNextPanel
    objNextPanel = nil
    objCurPanel:_AfterEnter()
    printLog("[界面切换] 完成，当前界面：" .. tostring(objCurPanel._nPanelId) .. ", " .. GetPanelName(objCurPanel._nPanelId))
end
local function ExitCurrent()
    -- 当前界面清理数据、变量、引用等
    if objCurPanel == nil then
        EnterNext()
    else
        objCurPanel:_Exit()
        EnterNext()
    end
end
local function PreEnterNext()
    local goSnapshot = TakeSnapshot(objNextPanel._nSnapshotPrePanel)
    AddTbGoSnapShot(objNextPanel._nPanelId, goSnapshot)
    if Settings.bOpenClientDebug == true then
        objNextPanel:_PreEnter(ExitCurrent, goSnapshot) -- 下个界面的预设体逐个加载实例化
        HideMoveSnapshot()
    else
        cs_coroutine.start(function()
            coroutine.yield(CS.UnityEngine.WaitForEndOfFrame()) -- 截屏需要等一帧
            objNextPanel:_PreEnter(ExitCurrent, goSnapshot) -- 下个界面的预设体逐个加载实例化
            HideMoveSnapshot()
        end)
    end
end
local function PreExitCurrent()
    -- 当前界面淡出及事件和控件回调的解绑
    if objCurPanel == nil then
        PreEnterNext()
    else
        MoveSnapShot(objCurPanel._nPanelId)
        objCurPanel:_PreExit(PreEnterNext, true)
    end
end
local function OnOpenPanel(listener, nPanelId, ...)
    if objNextPanel ~= nil then
        printError("[界面切换] 打开界面：" .. GetPanelName(nPanelId) .. " 失败，上一次界面切换流程尚未完成，正在处理：" .. GetPanelName(objNextPanel._nPanelId))
        return
    end
    if nPanelId == PanelId.MainView and #tbBackHistory > 0 then
        -- C#侧的模块，从战斗模块回到主界面模块时，关闭当前结算界面，返回上一个界面即可
        EventManager.Hit(EventId.CloesCurPanel)
        return
    end
    if objCurPanel ~= nil and objCurPanel._nPanelId == nPanelId then
        return
    end
    -- 界面跳跃处理，方案1：历史队列中已有同 panel id 时，直接移除。
    --[[ local nn = #tbBackHistory - 1
    for i = nn, 1, -1 do
        if tbBackHistory[i]._nPanelId == nPanelId then
            tbBackHistory[i]:_Exit()
            tbBackHistory[i]:_Destroy()
            table.remove(tbBackHistory, i)
        end
    end ]]
    local luaClass = require(mapDefinePanel[nPanelId])
    local tbParameter = {}
    for i = 1, select("#", ...) do
        local param = select(i, ...)
        table.insert(tbParameter, param)
    end
    local nIndex = 1
    if objCurPanel ~= nil then
        nIndex = objCurPanel._nIndex + 1
    end
    local objTempPanel = luaClass.new(nIndex, nPanelId, tbParameter)
    if objTempPanel._bIsMainPanel == true then
        objNextPanel = objTempPanel
        if objNextPanel._bAddToBackHistory == true then
            table.insert(tbBackHistory, objNextPanel)
        end
        PreExitCurrent()
    else
        local _bHasOpenTips = false
        for i, v in ipairs(tbDisposablePanel) do
            if _bHasOpenTips == false then
                _bHasOpenTips = UTILS.CheckIsTipsPanel(v._nPanelId)
            end
            if v._nPanelId == nPanelId then
                MoveSnapShot(v._nPanelId)
                objTempPanel:_PreExit()
                objTempPanel:_Exit()
                objTempPanel:_Destroy()
                objTempPanel = nil
                printLog("[界面切换] 打开非主 Panel：" .. GetPanelName(nPanelId) .. " 失败，不能重复打开。")
                return
            end
        end
        objTempPanel._nIndex = objTempPanel._nIndex + #tbDisposablePanel -- 修正非主 panel 的 _nIndex
        objTempPanel._bIsExtraTips = _bHasOpenTips
        local goSnapshot = TakeSnapshot(objTempPanel._nSnapshotPrePanel)
        objTempPanel:_PreEnter(nil, goSnapshot)
        objTempPanel:_Enter()
        table.insert(tbDisposablePanel, objTempPanel)
        printLog("[界面切换] 打开非主 Panel：" .. GetPanelName(nPanelId) .. "成功。")
    end
    CheckThresholdCount() -- 界面跳转处理，方案2：除主界面外，回退历史队列长度超过阈值时，将队列头部的界面移除。
end
---------- 界面切换流程 ---------- end
local function OnOpenLoading(listener, objTarget, callbackUpdate, callbackDone)
    if objTarget ~= nil then
        if type(callbackUpdate) == "function" then
            -- 显示百分比进度条
        else
            -- 显示转菊花
        end
    end
end
local function OnBlockInput(listener, bEnable)
    if bEnable == true then
        ClientMgr.Instance:EnableInputBlock()
    else
        ClientMgr.Instance:DisableInputBlock()
    end
end
local function OnTemporaryBlockInput(listener, nDuration, callback)
    if nDuration > 0 then
        local timerCallback = function()
            OnBlockInput(PanelManager, false)
            if type(callback) == "function" then
                callback()
            end
        end
        OnBlockInput(PanelManager, true)
        TimerManager.Add(1, nDuration, PanelManager, timerCallback, true, true, true)
    end
end
local function OnMarkCurCanvasFullRectWH()
    if trSnapshotParent ~= nil and trSnapshotParent:IsNull() == false then
        local rt = trSnapshotParent:GetComponent("RectTransform")
        Settings.CURRENT_CANVAS_FULL_RECT_WIDTH = rt.rect.width
        Settings.CURRENT_CANVAS_FULL_RECT_HEIGHT = rt.rect.height
        Settings.CANVAS_SCALE = rt.localScale.x
    end
    -- printLog(string.format("settings W:%s, H:%s", tostring(Settings.CURRENT_CANVAS_FULL_RECT_WIDTH), tostring(Settings.CURRENT_CANVAS_FULL_RECT_HEIGHT)))
end
local function OnCSLuaManagerShutdown()
    if objCurPanel ~= nil then -- 仅需处理当前界面的回调及事件解绑
        objCurPanel:_PreExit()
        objCurPanel:_Exit()
        objCurPanel:_Destroy()
    end
    EventManager.Remove(EventId.CSLuaManagerShutdown, PanelManager, OnCSLuaManagerShutdown)
    EventManager.Remove(EventId.OpenPanel, PanelManager, OnOpenPanel)
    EventManager.Remove(EventId.ClosePanel, PanelManager, OnClosePanel)
    EventManager.Remove(EventId.CloesCurPanel, PanelManager, OnCloseCurPanel)
    EventManager.Remove(EventId.OpenLoading, PanelManager, OnOpenLoading)
    EventManager.Remove(EventId.BlockInput, PanelManager, OnBlockInput)
    EventManager.Remove(EventId.TemporaryBlockInput, PanelManager, OnTemporaryBlockInput)
    EventManager.Remove("ReEnterLogin", PanelManager, PanelManager.OnConfirmBackToLogIn)
    EventManager.Remove("OnSdkLogout", PanelManager, PanelManager.OnConfirmBackToLogIn)
    EventManager.Remove(EventId.MarkFullRectWH, PanelManager, OnMarkCurCanvasFullRectWH) -- 记录当前 Canvas 全屏的宽和高
    EventManager.Remove("ClearRequiredLua", PanelManager, OnClearRequiredLua)
end
local function AddEventCallback()
    EventManager.Add(EventId.CSLuaManagerShutdown, PanelManager, OnCSLuaManagerShutdown)
    EventManager.Add(EventId.OpenPanel, PanelManager, OnOpenPanel)
    EventManager.Add(EventId.ClosePanel, PanelManager, OnClosePanel)
    EventManager.Add(EventId.CloesCurPanel, PanelManager, OnCloseCurPanel)
    EventManager.Add(EventId.OpenLoading, PanelManager, OnOpenLoading) -- overlay
    EventManager.Add(EventId.BlockInput, PanelManager, OnBlockInput) -- overlay
    EventManager.Add(EventId.TemporaryBlockInput, PanelManager, OnTemporaryBlockInput)
    EventManager.Add("ReEnterLogin", PanelManager, PanelManager.OnConfirmBackToLogIn)
    EventManager.Add("OnSdkLogout", PanelManager, PanelManager.OnConfirmBackToLogIn) -- C#侧SDK相关的代码会触发
    EventManager.Add(EventId.MarkFullRectWH, PanelManager, OnMarkCurCanvasFullRectWH) -- 记录当前 Canvas 全屏的宽和高
    EventManager.Add("ClearRequiredLua", PanelManager, OnClearRequiredLua)
end
local function InitGuidePanel()
    if AVG_EDITOR == true then return end
    local GuidePanel = require "Game.UI.Guide.GuidePanel"
    local objGuidePanel = GuidePanel.new(AllEnum.UI_SORTING_ORDER.Guide, PanelId.Guide, {})
    objGuidePanel:_PreEnter()
    objGuidePanel:_Enter()
end
local function InitTransitionPanel()
    local TransitionPanel = require "Game.UI.TransitionEx.TransitionPanel"
    objTransitionPanel = TransitionPanel.new(AllEnum.UI_SORTING_ORDER.Transition, PanelId.Transition, {})
    objTransitionPanel:_PreEnter()
    objTransitionPanel:_Enter()
end
local function CreateCBTTips()
    if EXE_EDITOR == true then return end
    local GameResourceLoader = require "Game.Common.Resource.GameResourceLoader"
    local ResType = GameResourceLoader.ResType
    local prefab = GameResourceLoader.LoadAsset(ResType.Any, Settings.AB_ROOT_PATH .. "UI/CBT_Tips/CBT_TipsPanel.prefab", typeof(Object), "UI", -999)
    local trParent = PanelManager.GetUIRoot(AllEnum.SortingLayerName.UI_Top)
    local goPrefabInstance = instantiate(prefab, trParent)
    goPrefabInstance.name = prefab.name
    goPrefabInstance.transform:SetAsLastSibling()
    local _canvasCBTTips = goPrefabInstance:GetComponent("Canvas")
    NovaAPI.SetCanvasWorldCamera(_canvasCBTTips, CS.GameCameraStackManager.Instance.uiCamera)
end
local function CreatePlayerInfoTips()
    if EXE_EDITOR == true then return end
    local PlayerInfoPanel = require "Game.UI.PlayerInfo.PlayerInfoPanel"
    objPlayerInfoPanel = PlayerInfoPanel.new(AllEnum.UI_SORTING_ORDER.Player_Info, PanelId.PlayerInfo, {})
    objPlayerInfoPanel:_PreEnter()
    objPlayerInfoPanel:_Enter()
end



------------------------------ public ------------------------------
function PanelManager.Init()
    local goUIRoot = GameObject.Find("==== UI ROOT ====")
    if goUIRoot ~= nil then
        mapUIRootTransform = {}
        mapUIRootTransform[0] = goUIRoot.transform
        local function func_CacheRootTransform(sSortingLayerName, sNodeName)
            local trNode = goUIRoot.transform:Find(sNodeName)
            mapUIRootTransform[sSortingLayerName] = trNode
        end
        func_CacheRootTransform(AllEnum.SortingLayerName.HUD, "---- HUD ----")
        func_CacheRootTransform(AllEnum.SortingLayerName.UI, "---- UI ----")
        func_CacheRootTransform(AllEnum.SortingLayerName.UI_Top, "---- UI TOP ----")
        func_CacheRootTransform(AllEnum.SortingLayerName.UI_Video, "---- UI Video ----")
        func_CacheRootTransform(AllEnum.SortingLayerName.Overlay, "---- UI OVERLAY ----")
        trSnapshotParent = mapUIRootTransform[0]:Find("---- UI ----/Snapshot")
        -- trSafeAreaMask = mapUIRootTransform[0]:Find("---- UI TOP ----/SafeAreaMaskCanvas/----safe_area_mask----")
        tbTemplateSnapshot = {}
        tbTemplateSnapshot[1] = trSnapshotParent:GetChild(0).gameObject
        tbTemplateSnapshot[2] = trSnapshotParent:GetChild(1).gameObject
        tbTemplateSnapshot[3] = trSnapshotParent:GetChild(2).gameObject
        tbTemplateSnapshot[4] = trSnapshotParent:GetChild(3).gameObject
        OnMarkCurCanvasFullRectWH()
    end
    objCurPanel = nil
    objNextPanel = nil
    tbBackHistory = {}
    tbDisposablePanel = {}
    mapDefinePanel = require "GameCore.UI.PanelDefine"
    AddEventCallback()
    InitGuidePanel()
    InitTransitionPanel()

    local goBootstrapUI = GameObject.Find("==== Builtin UI ====/BootstrapUI")
    GameObject.Destroy(goBootstrapUI)
    local goLaunchUI = GameObject.Find("==== Builtin UI ====/LaunchUI")
    NovaAPI.CloseLaunchLoading(goLaunchUI)
    -- CreateCBTTips()
    CreatePlayerInfoTips()
end
function PanelManager.GetUIRoot(sSortingLayerName)
    if sSortingLayerName == nil then
        sSortingLayerName = 0
    end
    return mapUIRootTransform[sSortingLayerName]
end
function PanelManager.Home()
    local nBackToIdx = 1
    for nIndex, objPanel in ipairs(tbBackHistory) do
        if objPanel._nPanelId == PanelId.MainMenu then
            nBackToIdx = nIndex
            break
        end
    end
    DoBackToTarget(nBackToIdx)
end
function PanelManager.OnConfirmBackToLogIn()
    if objCurPanel == nil then -- 意外情况可能会在初始化前，或者未打开任何界面前，收到事件，做个安全处理。
        return
    end
    if objCurPanel._bAddToBackHistory ~= true then
        objCurPanel:_PreExit()
        objCurPanel:_Exit()
        objCurPanel:_Destroy()
        objCurPanel = nil
    end
    local nCount = #tbBackHistory
    for i = nCount, 1, -1 do
        local objPanel = tbBackHistory[i]
        objPanel:_PreExit()
        objPanel:_Exit()
        objPanel:_Destroy()
        table.remove(tbBackHistory, i)
        RemoveTbSnapShot(objPanel._nPanelId)
        if objCurPanel ~= nil and objCurPanel == objPanel then
            objCurPanel = nil
        end
        objPanel = nil
    end
    --CS.HttpNetworkManager.Instance:Init()
    --NovaAPI.RestartNetwork()

    PlayerData.UnInit()
    PlayerData.Init()
    NovaAPI.ExitGame()
end
function PanelManager.Release()
    if type(tbBackHistory) == "table" then
        for i, objPanel in ipairs(tbBackHistory) do
            objPanel:_Release()
        end
    end
end
function PanelManager.GetCurPanelId()
    if objCurPanel ~= nil then
        return objCurPanel._nPanelId
    end
    return 0
end
function PanelManager.GetDisposablePanelState(nPanelId)
    for i, v in ipairs(tbDisposablePanel) do
        if v._nPanelId == nPanelId then
            return true
        end
    end
    return false
end
--检查panel是否打开(包含主Panel和非主Panel)
function PanelManager.CheckPanelOpen(nPanelId)
    --先检查主Panel
    if type(tbBackHistory) == "table" then
        for i, objPanel in ipairs(tbBackHistory) do
            if objPanel._nPanelId == nPanelId then
                return true, objPanel._bIsActive
            end
        end
    end

    --检查非主Panel
    if type(tbDisposablePanel) == "table" then
        for i, v in ipairs(tbDisposablePanel) do
            if v._nPanelId == nPanelId then
                return true, v._bIsActive
            end
        end
    end
    return false, false
end
function PanelManager.CheckNextPanelOpening()
    return objNextPanel ~= nil
end
function PanelManager.SetMainViewSkipAnimIn(bIn)
    bMainViewSkipAnimIn = bIn
end
function PanelManager.GetMainViewSkipAnimIn()
    return bMainViewSkipAnimIn
end
-- 战斗界面内，都是先disable再enable，从disable时开始计数
function PanelManager.InputEnable(bAudioStop, bDisActiveUICombat)
    print("PanelManager.InputEnable")
    local function resume()
        -- InputEnable得等一帧，不然UI和战斗的按键会同时触发
        local wait = function()
            coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
            NovaAPI.InputEnable()
            AdventureModuleHelper.ResumeLogic()
            if bAudioStop then
                WwiseAudioMgr:PostEvent("char_common_all_stop")
                WwiseAudioMgr:PostEvent("mon_common_all_stop")
            else
                WwiseAudioMgr:PostEvent("char_common_all_resume")
                WwiseAudioMgr:PostEvent("mon_common_all_resume")
            end
            if not bDisActiveUICombat then
                WwiseAudioMgr:PostEvent("ui_loading_combatSFX_active",nil,false)
            end
        end
        cs_coroutine.start(wait)
    end

    nInputRC = nInputRC - 1
    if nInputRC == 0 then
        resume()
    end

    if nInputRC < 0 then
        nInputRC = 0
        printError("InputEnable与InputDisable使用不匹配，请成对使用")
        -- 保底恢复
        resume()
    end
end
function PanelManager.InputDisable()
    print("PanelManager.InputDisable")
    if nInputRC == 0 then
        NovaAPI.InputDisable()
        AdventureModuleHelper.PauseLogic()
        WwiseAudioMgr:PostEvent("ui_loading_combatSFX_mute",nil,false)
        WwiseAudioMgr:PostEvent("char_common_all_pause")
        WwiseAudioMgr:PostEvent("mon_common_all_pause")
    end
    nInputRC = nInputRC + 1
end
function PanelManager.ClearInputState()
    nInputRC = 0
end

-- 路视频相关需求专用接口 start
local goDiscSkillActive,goSelect1,goSelect2,goSelect3,--[[trStarTowerRoomInfo,]]goDashboard,trSupportRole,trMainRole,trSkillHint,trJoystick,goTransition,goPlayerInfo
function PanelManager.SwitchUI()
    if mapUIRootTransform == nil then return end
    local trUIRoot
    trUIRoot = mapUIRootTransform[AllEnum.SortingLayerName.UI]
    if trUIRoot ~= nil then
        -- 特殊处理星盘（秘纹）激活界面
        if goDiscSkillActive == nil or (goDiscSkillActive ~= nil and goDiscSkillActive:IsNull() == true) then
            goDiscSkillActive = trUIRoot:Find("DiscSkillActivePanel")
            if goDiscSkillActive ~= nil and goDiscSkillActive:IsNull() == false then
                goDiscSkillActive:SetParent(mapUIRootTransform[0])
            end
        end
        -- 特殊处理三选一界面
        if goSelect1 == nil or (goSelect1 ~= nil and goSelect1:IsNull() == true) then
            goSelect1 = trUIRoot:Find("FateCardSelectPanel")
            if goSelect1 ~= nil and goSelect1:IsNull() == false then
                goSelect1:SetParent(mapUIRootTransform[0])
            end
        end
        if goSelect2 == nil or (goSelect2 ~= nil and goSelect2:IsNull() == true) then
            goSelect2 = trUIRoot:Find("NoteSelectPanel")
            if goSelect2 ~= nil and goSelect2:IsNull() == false then
                goSelect2:SetParent(mapUIRootTransform[0])
            end
        end
        if goSelect3 == nil or (goSelect3 ~= nil and goSelect3:IsNull() == true) then
            goSelect3 = trUIRoot:Find("PotentialSelectPanel")
            if goSelect3 ~= nil and goSelect3:IsNull() == false then
                goSelect3:SetParent(mapUIRootTransform[0])
            end
        end
        --[[ 
            -- 特殊处理 命运卡片 不受隐藏开关影响
            if trStarTowerRoomInfo == nil or (trStarTowerRoomInfo ~= nil and trStarTowerRoomInfo:IsNull() == true) then
                trStarTowerRoomInfo = trUIRoot:Find("StarTowerRoomInfo")
                if trStarTowerRoomInfo ~= nil and trStarTowerRoomInfo:IsNull() == false then
                    trStarTowerRoomInfo:SetParent(mapUIRootTransform[0])
                end
            end
            if trStarTowerRoomInfo ~= nil and trStarTowerRoomInfo:IsNull() == false then
                local tr = trStarTowerRoomInfo:GetChild(0)
                if tr ~= nil and tr:IsNull() == false then
                    local nChildCount = tr.childCount - 1
                    for i = 0, nChildCount, 1 do
                        local trChild = tr:GetChild(i)
                        if trChild ~= nil and trChild:IsNull() == false then
                            if trChild.name ~= "FateCard" then
                                if trChild.localScale.x > 0 then
                                    trChild.localScale = Vector3.zero
                                else
                                    trChild.localScale = Vector3.one
                                end
                            end
                        end
                    end
                end
            end
        ]]
        if goDashboard == nil or (goDashboard ~= nil and goDashboard:IsNull() == true) then
            goDashboard = trUIRoot:Find("BattleDashboard")
            if goDashboard ~= nil and goDashboard:IsNull() == false then
                goDashboard:SetParent(mapUIRootTransform[0])
                trSupportRole = goDashboard:Find("--safe_area--/--support_role--")
                trMainRole = goDashboard:Find("--safe_area--/--main_role--")
                trSkillHint = goDashboard:Find("--safe_area--/--skill_hint--")
                trJoystick = goDashboard:Find("--safe_area--/--joystick--")
            end
        end
        if trUIRoot.localScale.x > 0 then -- 当前可见，改成不可见
            trUIRoot.localScale = Vector3.zero
            trJoystick.localScale = Vector3.zero
        else -- 当前不可见，改成可见
            trUIRoot.localScale = Vector3.one
            trJoystick.localScale = Vector3.one
        end
    end
    trUIRoot = mapUIRootTransform[AllEnum.SortingLayerName.UI_Top]
    if trUIRoot ~= nil then
        if goTransition == nil or (goTransition ~= nil and goTransition:IsNull() == true) then
            goTransition = trUIRoot:Find("TransitionPanel")
            if goTransition ~= nil and goTransition:IsNull() == false then
                goTransition:SetParent(mapUIRootTransform[0])
            end
        end
        if trUIRoot.localScale.x > 0 then -- 当前可见，改成不可见
            trUIRoot.localScale = Vector3.zero
        else -- 当前不可见，改成可见
            trUIRoot.localScale = Vector3.one
        end
    end
    trUIRoot = mapUIRootTransform[AllEnum.SortingLayerName.Overlay]
    if trUIRoot ~= nil then
        if goPlayerInfo == nil or (goPlayerInfo ~= nil and goPlayerInfo:IsNull() == true) then
            goPlayerInfo = trUIRoot:Find("PlayerInfoPanel/----AdaptedArea----")
        end
        if goPlayerInfo.localScale.x > 0 then -- 当前可见，改成不可见
            goPlayerInfo.localScale = Vector3.zero
        else -- 当前不可见，改成可见
            goPlayerInfo.localScale = Vector3.one
        end
    end
end
function PanelManager.SwitchSkillBtn()
    if mapUIRootTransform == nil then return end
    if goDashboard == nil or (goDashboard ~= nil and goDashboard:IsNull() == true) then
        local trUIRoot = mapUIRootTransform[AllEnum.SortingLayerName.UI]
        goDashboard = trUIRoot:Find("BattleDashboard")
        if goDashboard ~= nil and goDashboard:IsNull() == false then
            goDashboard:SetParent(mapUIRootTransform[0])
            trSupportRole = goDashboard:Find("--safe_area--/--support_role--")
            trMainRole = goDashboard:Find("--safe_area--/--main_role--")
            trSkillHint = goDashboard:Find("--safe_area--/--skill_hint--")
            trJoystick = goDashboard:Find("--safe_area--/--joystick--")
        end
    end
    if trSupportRole.localScale.x > 0 then -- 当前可见，改成不可见
        trSupportRole.localScale = Vector3.zero
        trMainRole.localScale = Vector3.zero
        trSkillHint.localScale = Vector3.zero
    else -- 当前不可见，改成可见
        trSupportRole.localScale = Vector3.one
        trMainRole.localScale = Vector3.one
        trSkillHint.localScale = Vector3.one
    end
end
function PanelManager.CloseAllDisposablePanel()
    -- 关闭非main panel
    if type(tbDisposablePanel) == "table" then
        local n = #tbDisposablePanel
        for i = n, 1, -1 do
            local objTempPanel = tbDisposablePanel[i]
            objTempPanel:_PreExit()
            objTempPanel:_Exit()
            objTempPanel:_Destroy()
            objTempPanel = nil
            table.remove(tbDisposablePanel, i)
        end
        if n > 0 then
            printLog("[界面切换] 同时关闭所有非主 Panel 界面")
        end
    end
end
-- 路视频相关需求专用接口 end

function PanelManager.CheckInTransition()
    if objTransitionPanel ~= nil then
        local nStatus = objTransitionPanel:GetTransitionStatus()
        if nStatus ~= AllEnum.TransitionStatus.OutAnimDone then
            return true
        end
    end
    return false
end

return PanelManager
