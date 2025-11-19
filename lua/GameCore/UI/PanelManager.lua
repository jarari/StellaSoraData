local TimerManager = require("GameCore.Timer.TimerManager")
local WwiseAudioMgr = (CS.WwiseAudioManager).Instance
local ClientMgr = CS.ClientManager
local AdventureModuleHelper = CS.AdventureModuleHelper
local PanelManager = {}
local mapUIRootTransform, mapDefinePanel, objCurPanel, objNextPanel, tbBackHistory, tbDisposablePanel, trSnapshotParent, tbTemplateSnapshot, nThresholdHistoryPanelCount, objTransitionPanel, bMainViewSkipAnimIn = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local nInputRC = 0
local tbGoSnapShot, objPlayerInfoPanel = nil, nil
local OnClearRequiredLua = function(listener, strPath)
  -- function num : 0_0 , upvalues : _ENV
  printLog("[Lua重载] 清除了：" .. strPath)
  -- DECOMPILER ERROR at PC7: Confused about usage of register: R2 in 'UnsetPending'

  ;
  (package.loaded)[strPath] = nil
end

local TakeSnapshot = function(nType)
  -- function num : 0_1 , upvalues : tbTemplateSnapshot, _ENV, trSnapshotParent
  local goSnapshotIns = nil
  if nType <= 0 or tbTemplateSnapshot == nil then
    return goSnapshotIns
  end
  local goT = tbTemplateSnapshot[nType]
  if goT ~= nil and goT:IsNull() == false then
    goSnapshotIns = instantiate(goT, trSnapshotParent)
    goSnapshotIns:SetActive(true)
    local goUIEffectSnapshot = nil
    if nType == 1 or nType == 3 or nType == 4 then
      goUIEffectSnapshot = ((goSnapshotIns.transform):GetChild(0)).gameObject
    else
      goUIEffectSnapshot = goSnapshotIns
    end
    ;
    (NovaAPI.UIEffectSnapShotCapture)(goUIEffectSnapshot)
  end
  do
    return goSnapshotIns
  end
end

local GetPanelName = function(nPanelId)
  -- function num : 0_2 , upvalues : _ENV
  for k,v in pairs(PanelId) do
    if v == nPanelId then
      return k
    end
  end
end

local AddTbGoSnapShot = function(nPanelId, goIns)
  -- function num : 0_3 , upvalues : _ENV, tbGoSnapShot
  if Settings.bDestroyHistoryUIInstance then
    if tbGoSnapShot == nil then
      tbGoSnapShot = {}
    end
    if goIns ~= nil then
      tbGoSnapShot[nPanelId] = {goIns = goIns, bMove = false}
    end
  end
end

local MoveSnapShot = function(nPanelId)
  -- function num : 0_4 , upvalues : _ENV, tbGoSnapShot, trSnapshotParent
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

  if Settings.bDestroyHistoryUIInstance and tbGoSnapShot[nPanelId] ~= nil then
    (tbGoSnapShot[nPanelId]).bMove = true
    ;
    ((((tbGoSnapShot[nPanelId]).goIns).gameObject).transform):SetParent(trSnapshotParent)
  end
end

local GetSnapShot = function(nPanelId)
  -- function num : 0_5 , upvalues : _ENV, tbGoSnapShot
  -- DECOMPILER ERROR at PC8: Confused about usage of register: R1 in 'UnsetPending'

  if Settings.bDestroyHistoryUIInstance and tbGoSnapShot[nPanelId] ~= nil then
    (tbGoSnapShot[nPanelId]).bMove = false
    ;
    (((tbGoSnapShot[nPanelId]).goIns).gameObject):SetActive(true)
    return (tbGoSnapShot[nPanelId]).goIns
  end
end

local HideMoveSnapshot = function()
  -- function num : 0_6 , upvalues : _ENV, tbGoSnapShot
  if Settings.bDestroyHistoryUIInstance and tbGoSnapShot ~= nil then
    for _,v in pairs(tbGoSnapShot) do
      if v.bMove and v.goIns ~= nil then
        ((v.goIns).gameObject):SetActive(false)
      end
    end
  end
end

local RemoveTbSnapShot = function(nPanelId)
  -- function num : 0_7 , upvalues : _ENV, tbGoSnapShot
  if Settings.bDestroyHistoryUIInstance and tbGoSnapShot[nPanelId] ~= nil then
    local goIns = (tbGoSnapShot[nPanelId]).goIns
    if goIns ~= nil then
      destroy(goIns)
    end
    tbGoSnapShot[nPanelId] = nil
  end
end

local CheckThresholdCount = function()
  -- function num : 0_8 , upvalues : nThresholdHistoryPanelCount, _ENV, tbBackHistory, RemoveTbSnapShot
  if nThresholdHistoryPanelCount == nil then
    nThresholdHistoryPanelCount = (ConfigTable.GetConfigNumber)("MaxHistoryPanel")
  end
  local nCurCount = #tbBackHistory
  if nThresholdHistoryPanelCount < nCurCount then
    local nDelCount = nCurCount - nThresholdHistoryPanelCount
    local tbNeedRemovePanelIndex = {}
    for i = 1, nCurCount do
      if (tbBackHistory[i])._nPanelId ~= PanelId.MainView then
        (table.insert)(tbNeedRemovePanelIndex, i)
        nDelCount = nDelCount - 1
      end
    end
    do
      if nDelCount > 0 then
        nDelCount = #tbNeedRemovePanelIndex
        if nDelCount == nCurCount - nThresholdHistoryPanelCount then
          for i = nDelCount, 1, -1 do
            local nPanelIndex = tbNeedRemovePanelIndex[i]
            RemoveTbSnapShot((tbBackHistory[nPanelIndex])._nPanelId)
            ;
            (tbBackHistory[nPanelIndex]):_Exit()
            ;
            (tbBackHistory[nPanelIndex]):_Destroy()
            ;
            (table.remove)(tbBackHistory, nPanelIndex)
          end
        end
      end
    end
  end
end

local DoBackToTarget = function(nTargetIndex)
  -- function num : 0_9 , upvalues : _ENV, tbBackHistory, objCurPanel, RemoveTbSnapShot, GetSnapShot, GetPanelName, PanelManager
  if type(nTargetIndex) ~= "number" then
    nTargetIndex = 1
  end
  local nCount = #tbBackHistory
  do
    if nTargetIndex < nCount and objCurPanel ~= nil then
      local func_PreExitDone = function()
    -- function num : 0_9_0 , upvalues : objCurPanel, _ENV, tbBackHistory, nCount, nTargetIndex, RemoveTbSnapShot, GetSnapShot, GetPanelName
    if objCurPanel._bAddToBackHistory == true then
      (table.remove)(tbBackHistory, nCount)
    end
    nCount = #tbBackHistory
    for i = nCount, nTargetIndex + 1, -1 do
      local objPanel = tbBackHistory[i]
      RemoveTbSnapShot(objPanel._nPanelId)
      objPanel:_PreExit()
      objPanel:_Exit()
      objPanel:_Destroy()
      ;
      (table.remove)(tbBackHistory, i)
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
    ;
    (PanelManager.CloseAllDisposablePanel)()
  end
end

local CloseCurPanel = function()
  -- function num : 0_10 , upvalues : tbBackHistory, objCurPanel, _ENV, GetSnapShot, GetPanelName, RemoveTbSnapShot
  local nLastIndex = #tbBackHistory
  if objCurPanel == nil then
    return 
  end
  if objCurPanel._bAddToBackHistory ~= true or objCurPanel._bAddToBackHistory == true and nLastIndex > 1 then
    local func_DoBack = function()
    -- function num : 0_10_0 , upvalues : objCurPanel, _ENV, tbBackHistory, nLastIndex, GetSnapShot, GetPanelName
    if objCurPanel._bAddToBackHistory == true then
      (table.remove)(tbBackHistory, nLastIndex)
    end
    nLastIndex = #tbBackHistory
    local objBackPanel = tbBackHistory[nLastIndex]
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

local ClosePanel = function(nPanelId)
  -- function num : 0_11 , upvalues : objCurPanel, CloseCurPanel, tbBackHistory, _ENV, RemoveTbSnapShot, GetPanelName
  if objCurPanel ~= nil then
    if objCurPanel._nPanelId == nPanelId then
      CloseCurPanel()
    else
      local nCount = #tbBackHistory
      for i = nCount, 1, -1 do
        local objPanel = tbBackHistory[i]
        if objPanel._nPanelId == nPanelId then
          (table.remove)(tbBackHistory, i)
          objPanel:_Destroy()
          RemoveTbSnapShot(objPanel._nPanelId)
          objPanel = nil
          printLog("[界面切换] 仅关闭指定的界面：" .. GetPanelName(nPanelId))
          break
        end
      end
    end
  end
end

local OnClosePanel = function(listener, nPanelId)
  -- function num : 0_12 , upvalues : objNextPanel, _ENV, GetPanelName, tbDisposablePanel, RemoveTbSnapShot, ClosePanel
  if objNextPanel ~= nil then
    printError("[界面切换] 关闭界面：" .. GetPanelName(nPanelId) .. " 失败，上一次界面切换流程尚未完成，正在处理：" .. GetPanelName(objNextPanel._nPanelId))
    return 
  end
  if type(nPanelId) == "number" then
    local bIsMainPanel = true
    if type(tbDisposablePanel) == "table" then
      for i,v in ipairs(tbDisposablePanel) do
        if v._nPanelId == nPanelId then
          (EventManager.Hit)("Guide_CloseDisposablePanel", nPanelId)
          v:_PreExit()
          v:_Exit()
          v:_Destroy()
          ;
          (table.remove)(tbDisposablePanel, i)
          RemoveTbSnapShot(v._nPanelId)
          bIsMainPanel = false
          printLog("[界面切换] 关闭了非主 Panel 界面：" .. GetPanelName(nPanelId))
          break
        end
      end
    end
    do
      if bIsMainPanel == true then
        ClosePanel(nPanelId)
      end
    end
  end
end

local OnCloseCurPanel = function(listener)
  -- function num : 0_13 , upvalues : objCurPanel, CloseCurPanel
  if objCurPanel ~= nil and objCurPanel._bIsMainPanel == true then
    CloseCurPanel()
  end
end

local EnterNext = function()
  -- function num : 0_14 , upvalues : objNextPanel, objCurPanel, _ENV, GetPanelName
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

local ExitCurrent = function()
  -- function num : 0_15 , upvalues : objCurPanel, EnterNext
  if objCurPanel == nil then
    EnterNext()
  else
    objCurPanel:_Exit()
    EnterNext()
  end
end

local PreEnterNext = function()
  -- function num : 0_16 , upvalues : TakeSnapshot, objNextPanel, AddTbGoSnapShot, _ENV, ExitCurrent, HideMoveSnapshot
  local goSnapshot = TakeSnapshot(objNextPanel._nSnapshotPrePanel)
  AddTbGoSnapShot(objNextPanel._nPanelId, goSnapshot)
  ;
  (cs_coroutine.start)(function()
    -- function num : 0_16_0 , upvalues : _ENV, objNextPanel, ExitCurrent, goSnapshot, HideMoveSnapshot
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    objNextPanel:_PreEnter(ExitCurrent, goSnapshot)
    HideMoveSnapshot()
  end
)
end

local PreExitCurrent = function()
  -- function num : 0_17 , upvalues : objCurPanel, PreEnterNext, MoveSnapShot
  if objCurPanel == nil then
    PreEnterNext()
  else
    MoveSnapShot(objCurPanel._nPanelId)
    objCurPanel:_PreExit(PreEnterNext, true)
  end
end

local OnOpenPanel = function(listener, nPanelId, ...)
  -- function num : 0_18 , upvalues : objNextPanel, _ENV, GetPanelName, tbBackHistory, objCurPanel, mapDefinePanel, PreExitCurrent, tbDisposablePanel, MoveSnapShot, TakeSnapshot, CheckThresholdCount
  if objNextPanel ~= nil then
    printError("[界面切换] 打开界面：" .. GetPanelName(nPanelId) .. " 失败，上一次界面切换流程尚未完成，正在处理：" .. GetPanelName(objNextPanel._nPanelId))
    return 
  end
  if nPanelId == PanelId.MainView and #tbBackHistory > 0 then
    (EventManager.Hit)(EventId.CloesCurPanel)
    return 
  end
  if objCurPanel ~= nil and objCurPanel._nPanelId == nPanelId then
    return 
  end
  local luaClass = require(mapDefinePanel[nPanelId])
  local tbParameter = {}
  for i = 1, select("#", ...) do
    local param = select(i, ...)
    ;
    (table.insert)(tbParameter, param)
  end
  local nIndex = 1
  if objCurPanel ~= nil then
    nIndex = objCurPanel._nIndex + 1
  end
  local objTempPanel = (luaClass.new)(nIndex, nPanelId, tbParameter)
  if objTempPanel._bIsMainPanel == true then
    objNextPanel = objTempPanel
    if objNextPanel._bAddToBackHistory == true then
      (table.insert)(tbBackHistory, objNextPanel)
    end
    PreExitCurrent()
  else
    local _bHasOpenTips = false
    for i,v in ipairs(tbDisposablePanel) do
      if _bHasOpenTips == false then
        _bHasOpenTips = (UTILS.CheckIsTipsPanel)(v._nPanelId)
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
    objTempPanel._nIndex = objTempPanel._nIndex + #tbDisposablePanel
    objTempPanel._bIsExtraTips = _bHasOpenTips
    local goSnapshot = TakeSnapshot(objTempPanel._nSnapshotPrePanel)
    objTempPanel:_PreEnter(nil, goSnapshot)
    objTempPanel:_Enter()
    ;
    (table.insert)(tbDisposablePanel, objTempPanel)
    printLog("[界面切换] 打开非主 Panel：" .. GetPanelName(nPanelId) .. "成功。")
  end
  do
    CheckThresholdCount()
  end
end

local OnOpenLoading = function(listener, objTarget, callbackUpdate, callbackDone)
  -- function num : 0_19 , upvalues : _ENV
  if objTarget ~= nil and type(callbackUpdate) == "function" then
  end
end

local OnBlockInput = function(listener, bEnable)
  -- function num : 0_20 , upvalues : ClientMgr
  if bEnable == true then
    (ClientMgr.Instance):EnableInputBlock()
  else
    ;
    (ClientMgr.Instance):DisableInputBlock()
  end
end

local OnTemporaryBlockInput = function(listener, nDuration, callback)
  -- function num : 0_21 , upvalues : OnBlockInput, PanelManager, _ENV, TimerManager
  if nDuration > 0 then
    local timerCallback = function()
    -- function num : 0_21_0 , upvalues : OnBlockInput, PanelManager, _ENV, callback
    OnBlockInput(PanelManager, false)
    if type(callback) == "function" then
      callback()
    end
  end

    OnBlockInput(PanelManager, true)
    ;
    (TimerManager.Add)(1, nDuration, PanelManager, timerCallback, true, true, true)
  end
end

local OnMarkCurCanvasFullRectWH = function()
  -- function num : 0_22 , upvalues : trSnapshotParent, _ENV
  if trSnapshotParent ~= nil and trSnapshotParent:IsNull() == false then
    local rt = trSnapshotParent:GetComponent("RectTransform")
    -- DECOMPILER ERROR at PC15: Confused about usage of register: R1 in 'UnsetPending'

    Settings.CURRENT_CANVAS_FULL_RECT_WIDTH = (rt.rect).width
    -- DECOMPILER ERROR at PC19: Confused about usage of register: R1 in 'UnsetPending'

    Settings.CURRENT_CANVAS_FULL_RECT_HEIGHT = (rt.rect).height
    -- DECOMPILER ERROR at PC23: Confused about usage of register: R1 in 'UnsetPending'

    Settings.CANVAS_SCALE = (rt.localScale).x
  end
end

local OnCSLuaManagerShutdown = function()
  -- function num : 0_23 , upvalues : objCurPanel, _ENV, PanelManager, OnCSLuaManagerShutdown, OnOpenPanel, OnClosePanel, OnCloseCurPanel, OnOpenLoading, OnBlockInput, OnTemporaryBlockInput, OnMarkCurCanvasFullRectWH, OnClearRequiredLua
  if objCurPanel ~= nil then
    objCurPanel:_PreExit()
    objCurPanel:_Exit()
    objCurPanel:_Destroy()
  end
  ;
  (EventManager.Remove)(EventId.CSLuaManagerShutdown, PanelManager, OnCSLuaManagerShutdown)
  ;
  (EventManager.Remove)(EventId.OpenPanel, PanelManager, OnOpenPanel)
  ;
  (EventManager.Remove)(EventId.ClosePanel, PanelManager, OnClosePanel)
  ;
  (EventManager.Remove)(EventId.CloesCurPanel, PanelManager, OnCloseCurPanel)
  ;
  (EventManager.Remove)(EventId.OpenLoading, PanelManager, OnOpenLoading)
  ;
  (EventManager.Remove)(EventId.BlockInput, PanelManager, OnBlockInput)
  ;
  (EventManager.Remove)(EventId.TemporaryBlockInput, PanelManager, OnTemporaryBlockInput)
  ;
  (EventManager.Remove)("ReEnterLogin", PanelManager, PanelManager.OnConfirmBackToLogIn)
  ;
  (EventManager.Remove)("OnSdkLogout", PanelManager, PanelManager.OnConfirmBackToLogIn)
  ;
  (EventManager.Remove)(EventId.MarkFullRectWH, PanelManager, OnMarkCurCanvasFullRectWH)
  ;
  (EventManager.Remove)("ClearRequiredLua", PanelManager, OnClearRequiredLua)
end

local AddEventCallback = function()
  -- function num : 0_24 , upvalues : _ENV, PanelManager, OnCSLuaManagerShutdown, OnOpenPanel, OnClosePanel, OnCloseCurPanel, OnOpenLoading, OnBlockInput, OnTemporaryBlockInput, OnMarkCurCanvasFullRectWH, OnClearRequiredLua
  (EventManager.Add)(EventId.CSLuaManagerShutdown, PanelManager, OnCSLuaManagerShutdown)
  ;
  (EventManager.Add)(EventId.OpenPanel, PanelManager, OnOpenPanel)
  ;
  (EventManager.Add)(EventId.ClosePanel, PanelManager, OnClosePanel)
  ;
  (EventManager.Add)(EventId.CloesCurPanel, PanelManager, OnCloseCurPanel)
  ;
  (EventManager.Add)(EventId.OpenLoading, PanelManager, OnOpenLoading)
  ;
  (EventManager.Add)(EventId.BlockInput, PanelManager, OnBlockInput)
  ;
  (EventManager.Add)(EventId.TemporaryBlockInput, PanelManager, OnTemporaryBlockInput)
  ;
  (EventManager.Add)("ReEnterLogin", PanelManager, PanelManager.OnConfirmBackToLogIn)
  ;
  (EventManager.Add)("OnSdkLogout", PanelManager, PanelManager.OnConfirmBackToLogIn)
  ;
  (EventManager.Add)(EventId.MarkFullRectWH, PanelManager, OnMarkCurCanvasFullRectWH)
  ;
  (EventManager.Add)("ClearRequiredLua", PanelManager, OnClearRequiredLua)
end

local InitGuidePanel = function()
  -- function num : 0_25 , upvalues : _ENV
  if AVG_EDITOR == true then
    return 
  end
  local GuidePanel = require("Game.UI.Guide.GuidePanel")
  local objGuidePanel = (GuidePanel.new)((AllEnum.UI_SORTING_ORDER).Guide, PanelId.Guide, {})
  objGuidePanel:_PreEnter()
  objGuidePanel:_Enter()
end

local InitTransitionPanel = function()
  -- function num : 0_26 , upvalues : _ENV, objTransitionPanel
  local TransitionPanel = require("Game.UI.TransitionEx.TransitionPanel")
  objTransitionPanel = (TransitionPanel.new)((AllEnum.UI_SORTING_ORDER).Transition, PanelId.Transition, {})
  objTransitionPanel:_PreEnter()
  objTransitionPanel:_Enter()
end

local CreateCBTTips = function()
  -- function num : 0_27 , upvalues : _ENV, PanelManager
  if EXE_EDITOR == true then
    return 
  end
  local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
  local ResType = GameResourceLoader.ResType
  local prefab = (GameResourceLoader.LoadAsset)(ResType.Any, Settings.AB_ROOT_PATH .. "UI/CBT_Tips/CBT_TipsPanel.prefab", typeof(Object), "UI", -999)
  local trParent = (PanelManager.GetUIRoot)((AllEnum.SortingLayerName).UI_Top)
  local goPrefabInstance = instantiate(prefab, trParent)
  goPrefabInstance.name = prefab.name
  ;
  (goPrefabInstance.transform):SetAsLastSibling()
  local _canvasCBTTips = goPrefabInstance:GetComponent("Canvas")
  ;
  (NovaAPI.SetCanvasWorldCamera)(_canvasCBTTips, ((CS.GameCameraStackManager).Instance).uiCamera)
end

local CreatePlayerInfoTips = function()
  -- function num : 0_28 , upvalues : _ENV, objPlayerInfoPanel
  if EXE_EDITOR == true then
    return 
  end
  local PlayerInfoPanel = require("Game.UI.PlayerInfo.PlayerInfoPanel")
  objPlayerInfoPanel = (PlayerInfoPanel.new)((AllEnum.UI_SORTING_ORDER).Player_Info, PanelId.PlayerInfo, {})
  objPlayerInfoPanel:_PreEnter()
  objPlayerInfoPanel:_Enter()
end

PanelManager.Init = function()
  -- function num : 0_29 , upvalues : _ENV, mapUIRootTransform, trSnapshotParent, tbTemplateSnapshot, OnMarkCurCanvasFullRectWH, objCurPanel, objNextPanel, tbBackHistory, tbDisposablePanel, mapDefinePanel, AddEventCallback, InitGuidePanel, InitTransitionPanel, CreatePlayerInfoTips
  local goUIRoot = (GameObject.Find)("==== UI ROOT ====")
  if goUIRoot ~= nil then
    mapUIRootTransform = {}
    mapUIRootTransform[0] = goUIRoot.transform
    local func_CacheRootTransform = function(sSortingLayerName, sNodeName)
    -- function num : 0_29_0 , upvalues : goUIRoot, mapUIRootTransform
    local trNode = (goUIRoot.transform):Find(sNodeName)
    mapUIRootTransform[sSortingLayerName] = trNode
  end

    func_CacheRootTransform((AllEnum.SortingLayerName).HUD, "---- HUD ----")
    func_CacheRootTransform((AllEnum.SortingLayerName).UI, "---- UI ----")
    func_CacheRootTransform((AllEnum.SortingLayerName).UI_Top, "---- UI TOP ----")
    func_CacheRootTransform((AllEnum.SortingLayerName).UI_Video, "---- UI Video ----")
    func_CacheRootTransform((AllEnum.SortingLayerName).Overlay, "---- UI OVERLAY ----")
    trSnapshotParent = (mapUIRootTransform[0]):Find("---- UI ----/Snapshot")
    tbTemplateSnapshot = {}
    tbTemplateSnapshot[1] = (trSnapshotParent:GetChild(0)).gameObject
    tbTemplateSnapshot[2] = (trSnapshotParent:GetChild(1)).gameObject
    tbTemplateSnapshot[3] = (trSnapshotParent:GetChild(2)).gameObject
    tbTemplateSnapshot[4] = (trSnapshotParent:GetChild(3)).gameObject
    OnMarkCurCanvasFullRectWH()
  end
  do
    objCurPanel = nil
    objNextPanel = nil
    tbBackHistory = {}
    tbDisposablePanel = {}
    mapDefinePanel = require("GameCore.UI.PanelDefine")
    AddEventCallback()
    InitGuidePanel()
    InitTransitionPanel()
    local goBootstrapUI = (GameObject.Find)("==== Builtin UI ====/BootstrapUI")
    ;
    (GameObject.Destroy)(goBootstrapUI)
    local goLaunchUI = (GameObject.Find)("==== Builtin UI ====/LaunchUI")
    ;
    (NovaAPI.CloseLaunchLoading)(goLaunchUI)
    CreatePlayerInfoTips()
  end
end

PanelManager.GetUIRoot = function(sSortingLayerName)
  -- function num : 0_30 , upvalues : mapUIRootTransform
  if sSortingLayerName == nil then
    sSortingLayerName = 0
  end
  return mapUIRootTransform[sSortingLayerName]
end

PanelManager.Home = function()
  -- function num : 0_31 , upvalues : _ENV, tbBackHistory, DoBackToTarget
  local nBackToIdx = 1
  for nIndex,objPanel in ipairs(tbBackHistory) do
    if objPanel._nPanelId == PanelId.MainMenu then
      nBackToIdx = nIndex
      break
    end
  end
  do
    DoBackToTarget(nBackToIdx)
  end
end

PanelManager.OnConfirmBackToLogIn = function()
  -- function num : 0_32 , upvalues : objCurPanel, tbBackHistory, _ENV, RemoveTbSnapShot
  if objCurPanel == nil then
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
    ;
    (table.remove)(tbBackHistory, i)
    RemoveTbSnapShot(objPanel._nPanelId)
    if objCurPanel ~= nil and objCurPanel == objPanel then
      objCurPanel = nil
    end
    objPanel = nil
  end
  ;
  (PlayerData.UnInit)()
  ;
  (PlayerData.Init)()
  ;
  (NovaAPI.ExitGame)()
end

PanelManager.Release = function()
  -- function num : 0_33 , upvalues : _ENV, tbBackHistory
  if type(tbBackHistory) == "table" then
    for i,objPanel in ipairs(tbBackHistory) do
      objPanel:_Release()
    end
  end
end

PanelManager.GetCurPanelId = function()
  -- function num : 0_34 , upvalues : objCurPanel
  if objCurPanel ~= nil then
    return objCurPanel._nPanelId
  end
  return 0
end

PanelManager.GetDisposablePanelState = function(nPanelId)
  -- function num : 0_35 , upvalues : _ENV, tbDisposablePanel
  for i,v in ipairs(tbDisposablePanel) do
    if v._nPanelId == nPanelId then
      return true
    end
  end
  return false
end

PanelManager.CheckPanelOpen = function(nPanelId)
  -- function num : 0_36 , upvalues : _ENV, tbBackHistory, tbDisposablePanel
  if type(tbBackHistory) == "table" then
    for i,objPanel in ipairs(tbBackHistory) do
      if objPanel._nPanelId == nPanelId then
        return true, objPanel._bIsActive
      end
    end
  end
  do
    if type(tbDisposablePanel) == "table" then
      for i,v in ipairs(tbDisposablePanel) do
        if v._nPanelId == nPanelId then
          return true, v._bIsActive
        end
      end
    end
    do
      return false, false
    end
  end
end

PanelManager.CheckNextPanelOpening = function()
  -- function num : 0_37 , upvalues : objNextPanel
  do return objNextPanel ~= nil end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

PanelManager.SetMainViewSkipAnimIn = function(bIn)
  -- function num : 0_38 , upvalues : bMainViewSkipAnimIn
  bMainViewSkipAnimIn = bIn
end

PanelManager.GetMainViewSkipAnimIn = function()
  -- function num : 0_39 , upvalues : bMainViewSkipAnimIn
  return bMainViewSkipAnimIn
end

PanelManager.InputEnable = function(bAudioStop, bDisActiveUICombat)
  -- function num : 0_40 , upvalues : _ENV, AdventureModuleHelper, WwiseAudioMgr, nInputRC
  print("PanelManager.InputEnable")
  local resume = function()
    -- function num : 0_40_0 , upvalues : _ENV, AdventureModuleHelper, bAudioStop, WwiseAudioMgr, bDisActiveUICombat
    local wait = function()
      -- function num : 0_40_0_0 , upvalues : _ENV, AdventureModuleHelper, bAudioStop, WwiseAudioMgr, bDisActiveUICombat
      (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
      ;
      (NovaAPI.InputEnable)()
      ;
      (AdventureModuleHelper.ResumeLogic)()
      if bAudioStop then
        WwiseAudioMgr:PostEvent("char_common_all_stop")
        WwiseAudioMgr:PostEvent("mon_common_all_stop")
      else
        WwiseAudioMgr:PostEvent("char_common_all_resume")
        WwiseAudioMgr:PostEvent("mon_common_all_resume")
      end
      if not bDisActiveUICombat then
        WwiseAudioMgr:PostEvent("ui_loading_combatSFX_active", nil, false)
      end
    end

    ;
    (cs_coroutine.start)(wait)
  end

  nInputRC = nInputRC - 1
  if nInputRC == 0 then
    resume()
  end
  if nInputRC < 0 then
    nInputRC = 0
    printError("InputEnable与InputDisable使用不匹配，请成对使用")
    resume()
  end
end

PanelManager.InputDisable = function()
  -- function num : 0_41 , upvalues : _ENV, nInputRC, AdventureModuleHelper, WwiseAudioMgr
  print("PanelManager.InputDisable")
  if nInputRC == 0 then
    (NovaAPI.InputDisable)()
    ;
    (AdventureModuleHelper.PauseLogic)()
    WwiseAudioMgr:PostEvent("ui_loading_combatSFX_mute", nil, false)
    WwiseAudioMgr:PostEvent("char_common_all_pause")
    WwiseAudioMgr:PostEvent("mon_common_all_pause")
  end
  nInputRC = nInputRC + 1
end

PanelManager.ClearInputState = function()
  -- function num : 0_42 , upvalues : nInputRC
  nInputRC = 0
end

local goDiscSkillActive, goSelect1, goSelect2, goSelect3, goDashboard, trSupportRole, trMainRole, trSkillHint, trJoystick, goTransition, goPlayerInfo = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
PanelManager.SwitchUI = function()
  -- function num : 0_43 , upvalues : mapUIRootTransform, _ENV, goDiscSkillActive, goSelect1, goSelect2, goSelect3, goDashboard, trSupportRole, trMainRole, trSkillHint, trJoystick, goTransition, goPlayerInfo
  if mapUIRootTransform == nil then
    return 
  end
  local trUIRoot = nil
  trUIRoot = mapUIRootTransform[(AllEnum.SortingLayerName).UI]
  if trUIRoot ~= nil then
    if goDiscSkillActive == nil or goDiscSkillActive ~= nil and goDiscSkillActive:IsNull() == true then
      goDiscSkillActive = trUIRoot:Find("DiscSkillActivePanel")
      if goDiscSkillActive ~= nil and goDiscSkillActive:IsNull() == false then
        goDiscSkillActive:SetParent(mapUIRootTransform[0])
      end
    end
    if goSelect1 == nil or goSelect1 ~= nil and goSelect1:IsNull() == true then
      goSelect1 = trUIRoot:Find("FateCardSelectPanel")
      if goSelect1 ~= nil and goSelect1:IsNull() == false then
        goSelect1:SetParent(mapUIRootTransform[0])
      end
    end
    if goSelect2 == nil or goSelect2 ~= nil and goSelect2:IsNull() == true then
      goSelect2 = trUIRoot:Find("NoteSelectPanel")
      if goSelect2 ~= nil and goSelect2:IsNull() == false then
        goSelect2:SetParent(mapUIRootTransform[0])
      end
    end
    if goSelect3 == nil or goSelect3 ~= nil and goSelect3:IsNull() == true then
      goSelect3 = trUIRoot:Find("PotentialSelectPanel")
      if goSelect3 ~= nil and goSelect3:IsNull() == false then
        goSelect3:SetParent(mapUIRootTransform[0])
      end
    end
    if goDashboard == nil or goDashboard ~= nil and goDashboard:IsNull() == true then
      goDashboard = trUIRoot:Find("BattleDashboard")
      if goDashboard ~= nil and goDashboard:IsNull() == false then
        goDashboard:SetParent(mapUIRootTransform[0])
        trSupportRole = goDashboard:Find("--safe_area--/--support_role--")
        trMainRole = goDashboard:Find("--safe_area--/--main_role--")
        trSkillHint = goDashboard:Find("--safe_area--/--skill_hint--")
        trJoystick = goDashboard:Find("--safe_area--/--joystick--")
      end
    end
    if (trUIRoot.localScale).x > 0 then
      trUIRoot.localScale = Vector3.zero
      trJoystick.localScale = Vector3.zero
    else
      trUIRoot.localScale = Vector3.one
      trJoystick.localScale = Vector3.one
    end
  end
  trUIRoot = mapUIRootTransform[(AllEnum.SortingLayerName).UI_Top]
  if trUIRoot ~= nil then
    if goTransition == nil or goTransition ~= nil and goTransition:IsNull() == true then
      goTransition = trUIRoot:Find("TransitionPanel")
      if goTransition ~= nil and goTransition:IsNull() == false then
        goTransition:SetParent(mapUIRootTransform[0])
      end
    end
    if (trUIRoot.localScale).x > 0 then
      trUIRoot.localScale = Vector3.zero
    else
      trUIRoot.localScale = Vector3.one
    end
  end
  trUIRoot = mapUIRootTransform[(AllEnum.SortingLayerName).Overlay]
  if trUIRoot ~= nil then
    if goPlayerInfo == nil or goPlayerInfo ~= nil and goPlayerInfo:IsNull() == true then
      goPlayerInfo = trUIRoot:Find("PlayerInfoPanel/----AdaptedArea----")
    end
    if (goPlayerInfo.localScale).x > 0 then
      goPlayerInfo.localScale = Vector3.zero
    else
      goPlayerInfo.localScale = Vector3.one
    end
  end
end

PanelManager.SwitchSkillBtn = function()
  -- function num : 0_44 , upvalues : mapUIRootTransform, goDashboard, _ENV, trSupportRole, trMainRole, trSkillHint, trJoystick
  if mapUIRootTransform == nil then
    return 
  end
  do
    if goDashboard == nil or goDashboard ~= nil and goDashboard:IsNull() == true then
      local trUIRoot = mapUIRootTransform[(AllEnum.SortingLayerName).UI]
      goDashboard = trUIRoot:Find("BattleDashboard")
      if goDashboard ~= nil and goDashboard:IsNull() == false then
        goDashboard:SetParent(mapUIRootTransform[0])
        trSupportRole = goDashboard:Find("--safe_area--/--support_role--")
        trMainRole = goDashboard:Find("--safe_area--/--main_role--")
        trSkillHint = goDashboard:Find("--safe_area--/--skill_hint--")
        trJoystick = goDashboard:Find("--safe_area--/--joystick--")
      end
    end
    if (trSupportRole.localScale).x > 0 then
      trSupportRole.localScale = Vector3.zero
      trMainRole.localScale = Vector3.zero
      trSkillHint.localScale = Vector3.zero
    else
      trSupportRole.localScale = Vector3.one
      trMainRole.localScale = Vector3.one
      trSkillHint.localScale = Vector3.one
    end
  end
end

PanelManager.CloseAllDisposablePanel = function()
  -- function num : 0_45 , upvalues : _ENV, tbDisposablePanel
  if type(tbDisposablePanel) == "table" then
    local n = #tbDisposablePanel
    for i = n, 1, -1 do
      local objTempPanel = tbDisposablePanel[i]
      objTempPanel:_PreExit()
      objTempPanel:_Exit()
      objTempPanel:_Destroy()
      objTempPanel = nil
      ;
      (table.remove)(tbDisposablePanel, i)
    end
    if n > 0 then
      printLog("[界面切换] 同时关闭所有非主 Panel 界面")
    end
  end
end

PanelManager.CheckInTransition = function()
  -- function num : 0_46 , upvalues : objTransitionPanel, _ENV
  do
    if objTransitionPanel ~= nil then
      local nStatus = objTransitionPanel:GetTransitionStatus()
      if nStatus ~= (AllEnum.TransitionStatus).OutAnimDone then
        return true
      end
    end
    return false
  end
end

return PanelManager

