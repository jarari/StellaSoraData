local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
local ResType = GameResourceLoader.ResType
local GameCameraStackManager = CS.GameCameraStackManager
local BasePanel = class("BasePanel")
local sTopBarCtrlLua = "Game.UI.TopBarEx.TopBarCtrl"
local sSafeAreaRoot = "----SafeAreaRoot----"
local bDebugLog = false
local typeof = typeof
BasePanel.ctor = function(self, nIndex, nPanelId, tbParam)
  -- function num : 0_0 , upvalues : _ENV
  self._nIndex = nIndex
  self._nPanelId = nPanelId
  self._bIsActive = false
  self._tbParam = tbParam
  if self._nFADEINTYPE == nil then
    self._nFADEINTYPE = 1
  end
  if self._nFadeInType == nil then
    self._nFadeInType = 1
  end
  if self._bIsMainPanel == nil then
    self._bIsMainPanel = true
  end
  if self._bAddToBackHistory == nil then
    self._bAddToBackHistory = true
  end
  if self._nSnapshotPrePanel == nil then
    self._nSnapshotPrePanel = 0
  end
  if self._sSortingLayerName == nil then
    self._sSortingLayerName = (AllEnum.SortingLayerName).UI
  end
  if self._tbDefine == nil then
    self._tbDefine = {}
  end
  if self._sUIResRootPath ~= nil then
    self.sUIResRootPath = Settings.AB_ROOT_PATH .. self._sUIResRootPath
  else
    self.sUIResRootPath = Settings.AB_ROOT_PATH .. "UI/"
  end
  self._tbObjCtrl = {}
  self._tbObjChildCtrl = {}
  self._tbObjDyncChildCtrl = {}
  if type(self.Awake) == "function" then
    self:Awake()
  end
  self.bIsTipsPanel = (UTILS.CheckIsTipsPanel)(self._nPanelId)
end

BasePanel._PreExit = function(self, callback, bPlayFadeOut)
  -- function num : 0_1 , upvalues : _ENV
  if self._bIsActive == false then
    return 
  end
  self:_UnbindEventCallback()
  for sName,objChildCtrl in ipairs(self._tbObjChildCtrl) do
    objChildCtrl:_PreExit()
  end
  for i,objDyncChildCtrl in ipairs(self._tbObjDyncChildCtrl) do
    objDyncChildCtrl:_PreExit()
  end
  local nCount = #self._tbObjCtrl
  local func_PreExitDone = function()
    -- function num : 0_1_0 , upvalues : nCount, _ENV, callback
    nCount = nCount - 1
    if nCount == 0 and type(callback) == "function" then
      callback()
    end
  end

  for i,objCtrl in ipairs(self._tbObjCtrl) do
    objCtrl:_PreExit(func_PreExitDone, bPlayFadeOut)
  end
end

BasePanel._PreEnter = function(self, callback, goSnapshot)
  -- function num : 0_2 , upvalues : _ENV, sTopBarCtrlLua, sSafeAreaRoot, GameResourceLoader, ResType, typeof
  local _trParent = (PanelManager.GetUIRoot)(self._sSortingLayerName)
  local nCount = #self._tbDefine
  local func_DoInstantiate = function(nIndex)
    -- function num : 0_2_0 , upvalues : nCount, _ENV, callback, func_DoInstantiate, self, _trParent, sTopBarCtrlLua, sSafeAreaRoot, goSnapshot, GameResourceLoader, ResType, typeof
    local func_ProcNext = function()
      -- function num : 0_2_0_0 , upvalues : nIndex, nCount, _ENV, callback, func_DoInstantiate
      nIndex = nIndex + 1
      -- DECOMPILER ERROR at PC13: Unhandled construct in 'MakeBoolean' P1

      if nCount < nIndex and type(callback) == "function" then
        callback()
      end
      func_DoInstantiate(nIndex)
    end

    local objCtrl = (self._tbObjCtrl)[nIndex]
    if objCtrl ~= nil and objCtrl.gameObject ~= nil then
      objCtrl:ParsePrefab()
      func_ProcNext()
    else
      local tbDefine = (self._tbDefine)[nIndex]
      do
        local sPrefabFullPath = self.sUIResRootPath .. tbDefine.sPrefabPath
        local sLuaClassName = tbDefine.sCtrlName
        local func_PrefabLoaded = function(uiPrefab)
      -- function num : 0_2_0_1 , upvalues : _ENV, sLuaClassName, _trParent, sTopBarCtrlLua, self, nIndex, sSafeAreaRoot, goSnapshot, GameResourceLoader, objCtrl, func_ProcNext
      local luaClassName = require(sLuaClassName)
      local trParent = _trParent
      if sLuaClassName == sTopBarCtrlLua and self._trTopBarParent ~= nil then
        trParent = self._trTopBarParent
      end
      local goPrefabInstance = instantiate(uiPrefab, trParent)
      goPrefabInstance.name = uiPrefab.name
      ;
      (goPrefabInstance.transform):SetAsLastSibling()
      if nIndex == 1 then
        self._trTopBarParent = (goPrefabInstance.transform):Find(sSafeAreaRoot)
        if self._trTopBarParent == nil then
          self._trTopBarParent = goPrefabInstance.transform
        end
        if goSnapshot ~= nil and goSnapshot:IsNull() == false then
          (goSnapshot.transform):SetParent(goPrefabInstance.transform)
          -- DECOMPILER ERROR at PC49: Confused about usage of register: R4 in 'UnsetPending'

          ;
          (goSnapshot.transform).localScale = Vector3.one
          ;
          (goSnapshot.transform):SetAsFirstSibling()
          local rt = goSnapshot:GetComponent("RectTransform")
          rt.anchorMax = Vector2.one
          rt.anchorMin = Vector2.zero
          rt.anchoredPosition = Vector2.zero
        end
      end
      do
        ;
        (NovaAPI.ProcResPathNote)(goPrefabInstance, (GameResourceLoader.MakeBundleGroup)("UI", self._nPanelId))
        if objCtrl == nil then
          objCtrl = (luaClassName.new)(goPrefabInstance, self)
          ;
          (table.insert)(self._tbObjCtrl, objCtrl)
        else
          objCtrl:ParsePrefab(goPrefabInstance)
          if type(objCtrl.Awake) == "function" then
            objCtrl:Awake()
          end
        end
        func_ProcNext()
      end
    end

        local prefab = (GameResourceLoader.LoadAsset)(ResType.Any, sPrefabFullPath, typeof(Object), "UI", self._nPanelId)
        if prefab == nil or prefab:IsNull() == true then
          printError(sPrefabFullPath .. " can not found!!!")
        end
        func_PrefabLoaded(prefab)
      end
    end
  end

  func_DoInstantiate(1)
  self._bIsActive = true
end

BasePanel._Exit = function(self)
  -- function num : 0_3 , upvalues : _ENV
  if self._bIsActive == false then
    return 
  end
  if type(self.OnDisable) == "function" then
    self:OnDisable()
  end
  for sName,objChildCtrl in ipairs(self._tbObjChildCtrl) do
    objChildCtrl:_Exit()
  end
  for i,objDyncChildCtrl in ipairs(self._tbObjDyncChildCtrl) do
    objDyncChildCtrl:_Exit()
  end
  for i,objCtrl in ipairs(self._tbObjCtrl) do
    objCtrl:_Exit()
  end
  self:_DebugLogDataCount("OnDisable")
  self._bIsActive = false
end

BasePanel._Enter = function(self, bPlayFadeIn)
  -- function num : 0_4 , upvalues : _ENV, GameCameraStackManager
  self:_BindEventCallback()
  for i,objCtrl in ipairs(self._tbObjCtrl) do
    local canvas = (objCtrl.gameObject):GetComponent("Canvas")
    if canvas ~= nil and canvas:IsNull() == false then
      (NovaAPI.SetCanvasWorldCamera)(canvas, (GameCameraStackManager.Instance).uiCamera)
      ;
      (NovaAPI.SetCanvasSortingName)(canvas, self._sSortingLayerName)
      local nSortingOrder = 0
      if (AllEnum.UI_SORTING_ORDER).Guide <= self._nIndex then
        nSortingOrder = self._nIndex
      else
        if self.bIsTipsPanel == true then
          nSortingOrder = (AllEnum.UI_SORTING_ORDER).Tips
          if self._bIsExtraTips == true then
            nSortingOrder = (AllEnum.UI_SORTING_ORDER).TipsEx
          end
        else
          if self._nPanelId == PanelId.ProVideoGUI then
            nSortingOrder = (AllEnum.UI_SORTING_ORDER).ProVideo
          else
            nSortingOrder = self._nIndex * 100 + i
          end
        end
      end
      ;
      (NovaAPI.SetCanvasSortingOrder)(canvas, nSortingOrder)
      objCtrl._nSortingOrder = nSortingOrder
      ;
      (NovaAPI.SetCanvasPlaneDistance)(canvas, 101)
    end
    do
      do
        ;
        (objCtrl.gameObject):SetActive(true)
        objCtrl:_Enter(bPlayFadeIn)
        -- DECOMPILER ERROR at PC79: LeaveBlock: unexpected jumping out DO_STMT

      end
    end
  end
  for sName,objChildCtrl in ipairs(self._tbObjChildCtrl) do
    objChildCtrl:_Enter()
  end
  if type(self.OnEnable) == "function" then
    self:OnEnable(bPlayFadeIn)
  end
  ;
  (EventManager.Hit)("OnEvent_PanelOnEnableById", self._nPanelId)
  self:_DebugLogDataCount("OnEnable")
end

BasePanel._AfterEnter = function(self)
  -- function num : 0_5 , upvalues : _ENV
  if type(self.OnAfterEnter) == "function" then
    self:OnAfterEnter()
  end
end

BasePanel._SetPrefabInstance = function(self, bDel)
  -- function num : 0_6 , upvalues : _ENV
  local nCount = #self._tbObjDyncChildCtrl
  for i = nCount, 1, -1 do
    local objDyncChildCtrl = (self._tbObjDyncChildCtrl)[i]
    objDyncChildCtrl:_Destroy()
    objDyncChildCtrl.gameObject = nil
    ;
    (table.remove)(self._tbObjDyncChildCtrl, i)
  end
  for i,objCtrl in ipairs(self._tbObjCtrl) do
    if bDel == true then
      if objCtrl.__cname == "TopBarCtrl" then
        objCtrl.gameObject = nil
      else
        if objCtrl.gameObject ~= nil and (objCtrl.gameObject):IsNull() == false then
          destroy(objCtrl.gameObject)
          objCtrl.gameObject = nil
        end
      end
      self._trTopBarParent = nil
    else
      if objCtrl.gameObject ~= nil and (objCtrl.gameObject):IsNull() == false then
        (objCtrl.gameObject):SetActive(false)
      end
    end
  end
  if bDel == true then
    nCount = #self._tbObjChildCtrl
    for i = nCount, 1, -1 do
      local o = (self._tbObjChildCtrl)[i]
      o._nGoInstanceId = nil
      o.gameObject = nil
      ;
      (table.remove)(self._tbObjChildCtrl, i)
    end
  end
  do
    self:_DebugLogDataCount("Before OnDestroy")
  end
end

BasePanel._Destroy = function(self)
  -- function num : 0_7 , upvalues : _ENV, GameResourceLoader
  if type(self.OnDestroy) == "function" then
    self:OnDestroy()
  end
  for i,objCtrl in ipairs(self._tbObjCtrl) do
    (GameResourceLoader.UnloadAsset)((objCtrl._panel)._nPanelId)
    objCtrl:_Destroy()
  end
  for sName,objChildCtrl in ipairs(self._tbObjChildCtrl) do
    objChildCtrl:_Destroy()
  end
  self:_SetPrefabInstance(true)
  self._tbParam = nil
  self._tbObjCtrl = nil
  self._tbObjChildCtrl = nil
  self._tbObjDyncChildCtrl = nil
end

BasePanel._Release = function(self)
  -- function num : 0_8 , upvalues : _ENV
  if type(self.OnRelease) == "function" then
    self:OnRelease()
  end
  if type(self._tbObjCtrl) == "table" then
    for i,objCtrl in ipairs(self._tbObjCtrl) do
      objCtrl:_Release()
    end
  end
  do
    if type(self._tbObjChildCtrl) == "table" then
      for sName,objChildCtrl in ipairs(self._tbObjChildCtrl) do
        objChildCtrl:_Release()
      end
    end
  end
end

BasePanel._BindEventCallback = function(self)
  -- function num : 0_9 , upvalues : _ENV
  if type(self._mapEventConfig) == "table" then
    for nEventId,sCallbackName in pairs(self._mapEventConfig) do
      local callback = self[sCallbackName]
      if type(callback) == "function" then
        (EventManager.Add)(nEventId, self, callback)
      end
    end
  end
end

BasePanel._UnbindEventCallback = function(self)
  -- function num : 0_10 , upvalues : _ENV
  if type(self._mapEventConfig) == "table" then
    for nEventId,sCallbackName in pairs(self._mapEventConfig) do
      local callback = self[sCallbackName]
      if type(callback) == "function" then
        (EventManager.Remove)(nEventId, self, callback)
      end
    end
  end
end

BasePanel._DebugLogDataCount = function(self, sTitle)
  -- function num : 0_11 , upvalues : bDebugLog, _ENV
  if bDebugLog == false then
    return 
  end
  local sPanelName = self.__cname
  local nObjCtrlCnt = (table.nums)(self._tbObjCtrl)
  local nObjChildCtrlCnt = (table.nums)(self._tbObjChildCtrl)
  local nObjDyncChildCtrlCnt = (table.nums)(self._tbObjDyncChildCtrl)
  local sDebugLog = (string.format)("[%s.%s] ctrl实例数量：%d，子ctrl实例数量：%d，动态子ctrl实例数量：%d。", sPanelName, sTitle, nObjCtrlCnt, nObjChildCtrlCnt, nObjDyncChildCtrlCnt)
  printLog(sDebugLog)
end

BasePanel.GetPanelParam = function(self)
  -- function num : 0_12 , upvalues : _ENV
  if type(self._tbParam) == "table" then
    return self._tbParam
  else
    return nil
  end
end

return BasePanel

