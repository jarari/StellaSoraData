local ConfigData = require("GameCore.Data.ConfigData")
local TimerManager = require("GameCore.Timer.TimerManager")
local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
local ResType = GameResourceLoader.ResType
local AdventureModuleHelper = CS.AdventureModuleHelper
local BaseCtrl = class("BaseCtrl")
local sRootPath = Settings.AB_ROOT_PATH
local bDebugLog = false
local typeof = typeof
BaseCtrl.ctor = function(self, goPrefabInstance, objPanel)
  -- function num : 0_0 , upvalues : _ENV
  self._panel = objPanel
  self._tbTimer = {}
  self._mapPrefab = {}
  self._mapLoadAssets = {}
  self._mapHandler = {}
  self._mapNode = {}
  self:ParsePrefab(goPrefabInstance)
  if type(self.Awake) == "function" then
    self:Awake()
  end
  self._autoRemoveUnusedTimer = nil
end

BaseCtrl.ParsePrefab = function(self, goPrefabInstance)
  -- function num : 0_1
  if goPrefabInstance ~= nil and goPrefabInstance:IsNull() == false then
    self.gameObject = goPrefabInstance
  end
  self:_ParseNode(self._mapNodeConfig)
end

BaseCtrl._PreExit = function(self, callback, bPlayFadeOut)
  -- function num : 0_2 , upvalues : _ENV, TimerManager
  self:_UnbindComponentCallback(self._mapNodeConfig)
  self:_UnbindEventCallback(self._mapEventConfig)
  self:_RemoveAllTimer()
  if type(self.OnPreExit) == "function" then
    self:OnPreExit()
  end
  local func_DoCallback = function()
    -- function num : 0_2_0 , upvalues : _ENV, callback
    if type(callback) == "function" then
      callback()
    end
  end

  if bPlayFadeOut == true and type(self.FadeOut) == "function" then
    local nDelayTime = self:FadeOut()
    if type(nDelayTime) == "number" and nDelayTime > 0 then
      local func_timer = function(timer)
    -- function num : 0_2_1 , upvalues : func_DoCallback
    func_DoCallback()
  end

      ;
      (TimerManager.Add)(1, nDelayTime, self, func_timer, true, true)
    else
      do
        do
          func_DoCallback()
          func_DoCallback()
        end
      end
    end
  end
end

BaseCtrl._Exit = function(self)
  -- function num : 0_3 , upvalues : _ENV
  if type(self.OnDisable) == "function" then
    self:OnDisable()
  end
  if type(self._mapNode) == "table" then
    for sKey,obj in pairs(self._mapNode) do
      -- DECOMPILER ERROR at PC22: Confused about usage of register: R6 in 'UnsetPending'

      if type(obj) ~= "table" then
        (self._mapNode)[sKey] = 0
      else
      end
      if type(obj.__cname) == "string" then
        for i,_obj in ipairs(obj) do
          -- DECOMPILER ERROR at PC41: Confused about usage of register: R11 in 'UnsetPending'

          if type(_obj) ~= "table" then
            ((self._mapNode)[sKey])[i] = 0
          end
        end
        do
          -- DECOMPILER ERROR at PC45: LeaveBlock: unexpected jumping out IF_THEN_STMT

          -- DECOMPILER ERROR at PC45: LeaveBlock: unexpected jumping out IF_STMT

        end
      end
    end
  end
  self:_DebugLogDataCount("OnDisable")
end

BaseCtrl._Enter = function(self, bPlayFadeIn)
  -- function num : 0_4 , upvalues : _ENV
  self:_BindComponentCallback(self._mapNodeConfig)
  self:_BindEventCallback(self._mapEventConfig)
  self:_RegisterRedDot()
  if type(self.OnEnable) == "function" then
    self:OnEnable()
  end
  if type(self.FadeIn) == "function" then
    self:FadeIn(bPlayFadeIn)
    -- DECOMPILER ERROR at PC26: Confused about usage of register: R2 in 'UnsetPending'

    ;
    (self._panel)._nFadeInType = (self._panel)._nFADEINTYPE
  end
  self:_DebugLogDataCount("OnEnable")
end

BaseCtrl._Destroy = function(self)
  -- function num : 0_5 , upvalues : _ENV
  if type(self.OnDestroy) == "function" then
    self:OnDestroy()
  end
  for k,v in pairs(self._mapPrefab) do
    self:DestroyPrefabInstance(k)
  end
  for k,v in pairs(self._mapLoadAssets) do
    self:UnLoadAsset(k)
  end
  self._panel = nil
  self._tbTimer = nil
  self._mapPrefab = nil
  self._mapLoadAssets = nil
  self._mapHandler = nil
  self._mapNode = nil
end

BaseCtrl._Release = function(self)
  -- function num : 0_6 , upvalues : _ENV
  if self.gameObject ~= nil and (self.gameObject):IsNull() == false and type(self.OnRelease) == "function" then
    self:OnRelease()
  end
end

BaseCtrl._ParseNode = function(self, mapNodeConfig)
  -- function num : 0_7 , upvalues : _ENV
  if self.gameObject ~= nil and type(mapNodeConfig) == "table" then
    local trPrefabRoot = (self.gameObject).transform
    do
      local mapNode = {}
      local func_MarkAllNode = function(trRoot)
    -- function num : 0_7_0 , upvalues : mapNode, func_MarkAllNode
    local nChildCount = trRoot.childCount - 1
    for i = 0, nChildCount do
      local trChild = trRoot:GetChild(i)
      mapNode[trChild.name] = trChild.gameObject
      if trChild.childCount > 0 then
        func_MarkAllNode(trChild)
      end
    end
  end

      func_MarkAllNode(trPrefabRoot)
      for sKey,mapConfig in pairs(mapNodeConfig) do
        local sNodeName = mapConfig.sNodeName
        local nCount = mapConfig.nCount
        local sComponentName = mapConfig.sComponentName
        local sCtrlName = mapConfig.sCtrlName
        local sLanguageId = mapConfig.sLanguageId
        if type(sNodeName) ~= "string" then
          sNodeName = tostring(sKey)
        end
        local tbNodeName = {}
        -- DECOMPILER ERROR at PC47: Confused about usage of register: R16 in 'UnsetPending'

        if type(nCount) == "number" then
          if type((self._mapNode)[sKey]) ~= "table" then
            (self._mapNode)[sKey] = {}
          end
          for i = 1, nCount do
            (table.insert)(tbNodeName, sNodeName .. tostring(i))
          end
        else
          do
            do
              ;
              (table.insert)(tbNodeName, sNodeName)
              for nIndex,sName in ipairs(tbNodeName) do
                local bComponentFound = true
                local objNode = nil
                local goNode = mapNode[sName]
                if goNode ~= nil then
                  if type(sCtrlName) == "string" then
                    local objCtrl = nil
                    local nGoInstanceId = goNode:GetInstanceID()
                    for _nObjCtrlIdx,_objCtrl in ipairs((self._panel)._tbObjChildCtrl) do
                      if _objCtrl._nGoInstanceId == nGoInstanceId then
                        objCtrl = _objCtrl
                        break
                      end
                    end
                    do
                      do
                        do
                          if objCtrl == nil then
                            local luaClass = require(sCtrlName)
                            objCtrl = (luaClass.new)(goNode, self._panel)
                            objCtrl._nGoInstanceId = nGoInstanceId
                            ;
                            (table.insert)((self._panel)._tbObjChildCtrl, objCtrl)
                          end
                          objCtrl:ParsePrefab(goNode)
                          objNode = objCtrl
                          if sComponentName == nil then
                            sComponentName = "GameObject"
                          end
                          if sComponentName == "GameObject" then
                            objNode = goNode
                          else
                            if sComponentName == "Transform" then
                              objNode = goNode.transform
                            else
                              local _sComponentName = sComponentName
                              if sComponentName == "InputField_onEndEdit" then
                                _sComponentName = "InputField"
                              end
                              bComponentFound = goNode:GetNodeComponent(_sComponentName)
                              if objNode ~= nil and type(sLanguageId) == "string" then
                                if _sComponentName == "Text" then
                                  if (ConfigTable.GetUIText)(sLanguageId) then
                                    (NovaAPI.SetText)(objNode, (ConfigTable.GetUIText)(sLanguageId))
                                  else
                                    printError("UIText缺失配置:" .. sLanguageId)
                                  end
                                else
                                  if _sComponentName == "TMP_Text" then
                                    if (ConfigTable.GetUIText)(sLanguageId) then
                                      (NovaAPI.SetTMPText)(objNode, (ConfigTable.GetUIText)(sLanguageId))
                                    else
                                      printError("UIText缺失配置:" .. sLanguageId)
                                    end
                                  end
                                end
                              end
                            end
                          end
                          do
                            do
                              -- DECOMPILER ERROR at PC202: Confused about usage of register: R24 in 'UnsetPending'

                              if bComponentFound == true and objNode ~= nil then
                                if type(nCount) == "number" then
                                  ((self._mapNode)[sKey])[nIndex] = objNode
                                else
                                  -- DECOMPILER ERROR at PC205: Confused about usage of register: R24 in 'UnsetPending'

                                  ;
                                  (self._mapNode)[sKey] = objNode
                                end
                              else
                                printError("节点找到了但组件没找到，节点名：" .. sName .. "，组件名：" .. sComponentName .. "，panel id：" .. tostring((table.keyof)(PanelId, (self._panel)._nPanelId)))
                              end
                              printError("界面预设体中配置的节点没找到，预设体名字：" .. trPrefabRoot.name .. "，节点名字：" .. sName)
                              -- DECOMPILER ERROR at PC231: LeaveBlock: unexpected jumping out DO_STMT

                              -- DECOMPILER ERROR at PC231: LeaveBlock: unexpected jumping out DO_STMT

                              -- DECOMPILER ERROR at PC231: LeaveBlock: unexpected jumping out DO_STMT

                              -- DECOMPILER ERROR at PC231: LeaveBlock: unexpected jumping out DO_STMT

                              -- DECOMPILER ERROR at PC231: LeaveBlock: unexpected jumping out IF_THEN_STMT

                              -- DECOMPILER ERROR at PC231: LeaveBlock: unexpected jumping out IF_STMT

                              -- DECOMPILER ERROR at PC231: LeaveBlock: unexpected jumping out IF_THEN_STMT

                              -- DECOMPILER ERROR at PC231: LeaveBlock: unexpected jumping out IF_STMT

                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
              -- DECOMPILER ERROR at PC233: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC233: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC233: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
end

BaseCtrl._BindComponentCallback = function(self, mapNodeConfig)
  -- function num : 0_8 , upvalues : _ENV
  if type(mapNodeConfig) ~= "table" then
    return 
  end
  local func_DoBind = function(objComp, sCompName, cb, sNodeKey, nIndex)
    -- function num : 0_8_0 , upvalues : _ENV, self
    local sHandlerKey = sNodeKey
    if type(nIndex) == "number" then
      sHandlerKey = sNodeKey .. tostring(nIndex)
    end
    local func_Handler = function(...)
      -- function num : 0_8_0_0 , upvalues : _ENV, self, cb, objComp, nIndex
      local ui_func = ui_handler(self, cb, objComp, nIndex)
      ui_func(...)
      ;
      (EventManager.Hit)(EventId.UIOperate)
    end

    if sCompName == "Button" then
      (objComp.onClick):AddListener(func_Handler)
    else
      if sCompName == "ButtonEx" then
        (objComp.onClick):AddListener(func_Handler)
      else
        if sCompName == "UIButton" then
          (objComp.onClick):AddListener(func_Handler)
        else
          if sCompName == "NaviButton" then
            (objComp.onClick):AddListener(func_Handler)
          else
            if sCompName == "TMPHyperLink" then
              (objComp.onClick):AddListener(func_Handler)
            else
              if sCompName == "Toggle" then
                (NovaAPI.AddToggleListener)(objComp, func_Handler)
              else
                if sCompName == "UIToggle" then
                  (NovaAPI.AddUIToggleListener)(objComp, func_Handler)
                else
                  if sCompName == "ScrollRect" then
                    (NovaAPI.AddScrollRectListener)(objComp, func_Handler)
                  else
                    if sCompName == "Slider" then
                      (NovaAPI.AddSliderListener)(objComp, func_Handler)
                    else
                      if sCompName == "LoopScrollView" then
                        (objComp.onValueChanged):AddListener(func_Handler)
                      else
                        if sCompName == "InputField" then
                          (NovaAPI.AddIPValueChangedListener)(objComp, func_Handler)
                        else
                          if sCompName == "InputField_onEndEdit" then
                            (objComp.onEndEdit):AddListener(func_Handler)
                          else
                            if sCompName == "TMP_Dropdown" then
                              (objComp.onValueChanged):AddListener(func_Handler)
                            else
                              if sCompName == "Dropdown" then
                                (NovaAPI.AddDropDownListener)(objComp, func_Handler)
                              else
                                if sCompName == "TMP_InputField" then
                                  (objComp.onValueChanged):AddListener(func_Handler)
                                else
                                  if sCompName == "LoopScrollSnap" then
                                    (objComp.onGridSelect):AddListener(func_Handler)
                                  else
                                    if sCompName == "UIDrag" then
                                      (objComp.onDragEvent):AddListener(func_Handler)
                                    else
                                      if sCompName == "UIZoom" then
                                        (objComp.onZoom):AddListener(func_Handler)
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
          end
        end
      end
    end
    -- DECOMPILER ERROR at PC150: Confused about usage of register: R7 in 'UnsetPending'

    if type(func_Handler) == "function" then
      (self._mapHandler)[sHandlerKey] = func_Handler
    end
  end

  for sKey,mapConfig in pairs(mapNodeConfig) do
    local sCallback = mapConfig.callback
    local sComponentName = mapConfig.sComponentName
    local nCount = mapConfig.nCount
    if type(sCallback) == "string" and type(sComponentName) == "string" then
      local funcCallback = self[sCallback]
      if type(funcCallback) == "function" then
        if type((self._mapNode)[sKey]) == "table" and type(nCount) == "number" then
          for i = 1, nCount do
            func_DoBind(((self._mapNode)[sKey])[i], sComponentName, funcCallback, sKey, i)
          end
        else
          do
            do
              func_DoBind((self._mapNode)[sKey], sComponentName, funcCallback, sKey)
              printError("没有找到组件的回调函数，节点名字：" .. sKey .. "，回调函数名字：" .. sCallback)
              -- DECOMPILER ERROR at PC71: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC71: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC71: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC71: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC71: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC71: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC71: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
end

BaseCtrl._UnbindComponentCallback = function(self, mapNodeConfig)
  -- function num : 0_9 , upvalues : _ENV
  if type(mapNodeConfig) ~= "table" then
    return 
  end
  local func_DoUnbind = function(objComp, sCompName, sNodeKey, nIndex)
    -- function num : 0_9_0 , upvalues : _ENV, self
    local sHandlerKey = sNodeKey
    if type(nIndex) == "number" then
      sHandlerKey = sNodeKey .. tostring(nIndex)
    end
    local func_Handler = (self._mapHandler)[sHandlerKey]
    if objComp ~= nil and func_Handler ~= nil then
      if sCompName == "Button" then
        (objComp.onClick):RemoveListener(func_Handler)
      else
        if sCompName == "ButtonEx" then
          (objComp.onClick):RemoveListener(func_Handler)
        else
          if sCompName == "UIButton" then
            (objComp.onClick):RemoveListener(func_Handler)
          else
            if sCompName == "NaviButton" then
              (objComp.onClick):RemoveListener(func_Handler)
            else
              if sCompName == "TMPHyperLink" then
                (objComp.onClick):RemoveListener(func_Handler)
              else
                if sCompName == "Toggle" then
                  (NovaAPI.RemoveToggleListener)(objComp, func_Handler)
                else
                  if sCompName == "UIToggle" then
                    (NovaAPI.RemoveUIToggleListener)(objComp, func_Handler)
                  else
                    if sCompName == "ScrollRect" then
                      (NovaAPI.RemoveScrollRectListener)(objComp, func_Handler)
                    else
                      if sCompName == "Slider" then
                        (NovaAPI.RemoveSliderListener)(objComp, func_Handler)
                      else
                        if sCompName == "LoopScrollView" then
                          (objComp.onValueChanged):RemoveListener(func_Handler)
                        else
                          if sCompName == "InputField" then
                            (NovaAPI.RemoveIPValueChangedListener)(objComp, func_Handler)
                          else
                            if sCompName == "InputField_onEndEdit" then
                              (objComp.onEndEdit):RemoveListener(func_Handler)
                            else
                              if sCompName == "TMP_Dropdown" then
                                (objComp.onValueChanged):RemoveListener(func_Handler)
                              else
                                if sCompName == "Dropdown" then
                                  (NovaAPI.RemoveDropDownListener)(objComp, func_Handler)
                                else
                                  if sCompName == "TMP_InputField" then
                                    (objComp.onValueChanged):RemoveListener(func_Handler)
                                  else
                                    if sCompName == "LoopScrollSnap" then
                                      (objComp.onGridSelect):RemoveListener(func_Handler)
                                    else
                                      if sCompName == "UIDrag" then
                                        (objComp.onDragEvent):RemoveListener(func_Handler)
                                      else
                                        if sCompName == "UIZoom" then
                                          (objComp.onZoom):RemoveListener(func_Handler)
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
            end
          end
        end
      end
    end
    -- DECOMPILER ERROR at PC149: Confused about usage of register: R6 in 'UnsetPending'

    ;
    (self._mapHandler)[sHandlerKey] = nil
    func_Handler = nil
  end

  for sKey,mapConfig in pairs(mapNodeConfig) do
    local sCallback = mapConfig.callback
    local sComponentName = mapConfig.sComponentName
    local nCount = mapConfig.nCount
    if type(sCallback) == "string" and type(sComponentName) == "string" then
      local funcCallback = self[sCallback]
      if type(funcCallback) == "function" then
        if type((self._mapNode)[sKey]) == "table" and type(nCount) == "number" then
          for i = 1, nCount do
            func_DoUnbind(((self._mapNode)[sKey])[i], sComponentName, sKey, i)
          end
        else
          do
            do
              func_DoUnbind((self._mapNode)[sKey], sComponentName, sKey)
              printError("没有找到组件的回调函数，节点名字：" .. sKey .. "，回调函数名字：" .. sCallback)
              -- DECOMPILER ERROR at PC69: LeaveBlock: unexpected jumping out DO_STMT

              -- DECOMPILER ERROR at PC69: LeaveBlock: unexpected jumping out IF_ELSE_STMT

              -- DECOMPILER ERROR at PC69: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC69: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC69: LeaveBlock: unexpected jumping out IF_STMT

              -- DECOMPILER ERROR at PC69: LeaveBlock: unexpected jumping out IF_THEN_STMT

              -- DECOMPILER ERROR at PC69: LeaveBlock: unexpected jumping out IF_STMT

            end
          end
        end
      end
    end
  end
end

BaseCtrl._BindEventCallback = function(self, mapEventConfig)
  -- function num : 0_10 , upvalues : _ENV
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Add)(nEventId, self, callback)
    end
  end
end

BaseCtrl._UnbindEventCallback = function(self, mapEventConfig)
  -- function num : 0_11 , upvalues : _ENV
  if type(mapEventConfig) ~= "table" then
    return 
  end
  for nEventId,sCallbackName in pairs(mapEventConfig) do
    local callback = self[sCallbackName]
    if type(callback) == "function" then
      (EventManager.Remove)(nEventId, self, callback)
    end
  end
end

BaseCtrl._RemoveAllTimer = function(self)
  -- function num : 0_12 , upvalues : TimerManager, _ENV
  local n = #self._tbTimer
  for i = n, 1, -1 do
    (TimerManager.Remove)((self._tbTimer)[i], false)
    ;
    (table.remove)(self._tbTimer, i)
  end
  if (table.nums)(self._tbTimer) > 0 then
    self._tbTimer = {}
  end
  if self._autoRemoveUnusedTimer ~= nil then
    (self._autoRemoveUnusedTimer):Cancel()
    self._autoRemoveUnusedTimer = nil
  end
end

BaseCtrl._DebugLogDataCount = function(self, sTitle)
  -- function num : 0_13 , upvalues : bDebugLog, _ENV
  if bDebugLog == false then
    return 
  end
  local sCtrlName = self.__cname
  local sGoName = (self.gameObject).name
  local nTimerCnt = (table.nums)(self._tbTimer)
  local nPrefabInsCnt = (table.nums)(self._mapPrefab)
  local nHandlerCnt = (table.nums)(self._mapHandler)
  local nNodeCnt = (table.nums)(self._mapNode)
  local sDebugLog = (string.format)("[%s.%s] 预设体：%s，计时器数量：%d，自理预设体实例数量：%d，回调数量：%d，节点数量：%d。", sCtrlName, sTitle, sGoName, nTimerCnt, nPrefabInsCnt, nHandlerCnt, nNodeCnt)
  printLog(sDebugLog)
end

BaseCtrl._RegisterRedDot = function(self)
  -- function num : 0_14 , upvalues : _ENV
  if self._mapRedDotConfig ~= nil then
    for key,cfg in pairs(self._mapRedDotConfig) do
      local sNodeName = cfg.sNodeName
      local nNodeIndex = cfg.nNodeIndex
      local objNode = nil
      if nNodeIndex == nil then
        objNode = (self._mapNode)[sNodeName]
      else
        if (self._mapNode)[sNodeName] ~= nil then
          objNode = ((self._mapNode)[sNodeName])[nNodeIndex]
        end
      end
      if objNode == nil then
        printError((string.format)("绑定红点失败！！！ 找不到红点节点.key = %s, nodeName = %s", key, sNodeName))
      else
        ;
        (RedDotManager.RegisterNode)(key, cfg.param, objNode.gameObject)
      end
    end
  end
end

BaseCtrl.GetPanelId = function(self)
  -- function num : 0_15
  return (self._panel)._nPanelId
end

BaseCtrl.GetPanelParam = function(self)
  -- function num : 0_16
  return (self._panel):GetPanelParam()
end

BaseCtrl.GetAtlasSprite = function(self, sAtlasPath, sSpriteName)
  -- function num : 0_17 , upvalues : _ENV, sRootPath, GameResourceLoader, ResType, typeof
  if (string.find)(sAtlasPath, "/CommonEx/") ~= nil or (string.find)(sAtlasPath, "/Common/") ~= nil then
    printError("新版UI在换过图集做法后，从图集中取Sprite时不应出现/CommonEx/目录 或 /Common/ 目录。" .. sAtlasPath .. "," .. sSpriteName)
    printError("panel id:" .. (self._panel)._nPanelId .. "，ctrl name:" .. self.__cname)
    return nil
  end
  local sFullPath = (string.format)("%sUI/CommonEx/atlas_png/%s/%s.png", sRootPath, sAtlasPath, sSpriteName)
  return (GameResourceLoader.LoadAsset)(ResType.Any, sFullPath, typeof(Sprite))
end

BaseCtrl.GetPngSprite = function(self, sPath)
  -- function num : 0_18 , upvalues : _ENV, GameResourceLoader, ResType, sRootPath, typeof
  if type(sPath) == "number" then
    printError("调用接口处需更新，panel id:" .. (self._panel)._nPanelId .. "，ctrl name:" .. self.__cname)
    return nil
  end
  if (string.find)(sPath, "Icon/") == nil and (string.find)(sPath, "Image/") == nil and (string.find)(sPath, "ImageAvg/") == nil and (string.find)(sPath, "big_sprites/") == nil then
    printError("配置表中 Icon 资源字段内容填写错误，应填路径，如：Icon/Item/item_1，panel id:" .. (self._panel)._nPanelId .. "，ctrl name:" .. self.__cname)
    return nil
  else
    local sp = (GameResourceLoader.LoadAsset)(ResType.Any, sRootPath .. sPath .. ".png", typeof(Sprite))
    if sp == nil then
      printError((string.format)("未找到 icon 资源：%s，panel id：%s，ctrl name：%s", sPath, tostring((self._panel)._nPanelId), tostring(self.__cname)))
    end
    return sp
  end
end

BaseCtrl.GetSprite_FrameColor = function(self, nRarity, sFrameType, bBigSprites)
  -- function num : 0_19 , upvalues : _ENV
  local sPngName = sFrameType .. (AllEnum.FrameColor_New)[nRarity]
  if bBigSprites then
    return self:GetPngSprite("UI/big_sprites/" .. sPngName)
  else
    return self:GetAtlasSprite("12_rare", sPngName)
  end
end

BaseCtrl.GetSprite_Coin = function(self, nCoinItemId)
  -- function num : 0_20 , upvalues : _ENV
  local mapItem = (ConfigTable.GetData_Item)(nCoinItemId)
  if mapItem == nil then
    return nil
  else
    if mapItem.Icon2 == nil or mapItem.Icon2 == "" then
      return nil
    else
      return self:GetPngSprite(mapItem.Icon2)
    end
  end
end

BaseCtrl.GetAvgCharHeadIcon = function(self, sSpeakerId, sFace)
  -- function num : 0_21 , upvalues : _ENV
  if sFace == nil then
    sFace = "002"
  end
  if sSpeakerId == nil or sSpeakerId == "" or sSpeakerId == "avg0_1" or sSpeakerId == "0" then
    sSpeakerId = AdjustMainRoleAvgCharId()
  end
  local sIconPath = (string.format)("Icon/AvgHead/%s/%s_%s", sSpeakerId, sSpeakerId, sFace)
  return self:GetPngSprite(sIconPath)
end

BaseCtrl.SetSprite = function(self, imgObj, sPath)
  -- function num : 0_22 , upvalues : sRootPath, _ENV
  local sFullPath = sRootPath .. sPath .. ".png"
  local bSuc = (NovaAPI.SetImageSprite)(imgObj, sFullPath)
  if not bSuc then
    traceback((string.format)("Sprite设置失败：%s，panel id：%s，ctrl name：%s", sFullPath, tostring((self._panel)._nPanelId), tostring(self.__cname)))
  end
  return bSuc
end

BaseCtrl.SetAtlasSprite = function(self, imgObj, sAtlasPath, sSpriteName)
  -- function num : 0_23 , upvalues : _ENV, sRootPath
  if (string.find)(sAtlasPath, "/CommonEx/") ~= nil or (string.find)(sAtlasPath, "/Common/") ~= nil then
    printError("新版UI在换过图集做法后，从图集中取Sprite时不应出现/CommonEx/目录 或 /Common/ 目录。" .. sAtlasPath .. "," .. sSpriteName)
    printError("panel id:" .. (self._panel)._nPanelId .. "，ctrl name:" .. self.__cname)
    return false
  end
  local sFullPath = (string.format)("%sUI/CommonEx/atlas_png/%s/%s.png", sRootPath, sAtlasPath, sSpriteName)
  local bSuc = (NovaAPI.SetImageSprite)(imgObj, sFullPath)
  if not bSuc then
    traceback((string.format)("icon设置失败：%s，panel id：%s，ctrl name：%s", sFullPath, tostring((self._panel)._nPanelId), tostring(self.__cname)))
  end
  return bSuc
end

BaseCtrl.SetActivityAtlasSprite = function(self, imgObj, sActivityPath, sSpriteName)
  -- function num : 0_24 , upvalues : _ENV, sRootPath
  local sFullPath = (string.format)("%sUI_Activity/%s/SpriteAtlas/%s.png", sRootPath, sActivityPath, sSpriteName)
  local bSuc = (NovaAPI.SetImageSprite)(imgObj, sFullPath)
  if not bSuc then
    traceback((string.format)("icon设置失败：%s，panel id：%s，ctrl name：%s", sFullPath, tostring((self._panel)._nPanelId), tostring(self.__cname)))
  end
  return bSuc
end

BaseCtrl.SetPngSprite = function(self, imgObj, sPath)
  -- function num : 0_25 , upvalues : _ENV, sRootPath
  if type(sPath) == "number" then
    traceback("调用接口处需更新，panel id:" .. (self._panel)._nPanelId .. "，ctrl name:" .. self.__cname)
    ;
    (NovaAPI.SetImageSpriteAsset)(imgObj, nil)
    return false
  end
  if (string.find)(sPath, "Icon/") == nil and (string.find)(sPath, "Image/") == nil and (string.find)(sPath, "ImageAvg/") == nil and (string.find)(sPath, "big_sprites/") == nil and (string.find)(sPath, "Disc/") == nil and (string.find)(sPath, "Play_") == nil and (string.find)(sPath, "UI_Activity") == nil then
    traceback("配置表中 Icon 资源字段内容填写错误，应填路径，如：Icon/Item/item_1，panel id:" .. (self._panel)._nPanelId .. "，ctrl name:" .. self.__cname)
    ;
    (NovaAPI.SetImageSpriteAsset)(imgObj, nil)
    return false
  else
    local sFullPath = sRootPath .. sPath .. ".png"
    local bSuc = (NovaAPI.SetImageSprite)(imgObj, sFullPath)
    if not bSuc then
      traceback((string.format)("icon设置失败：%s，panel id：%s，ctrl name：%s", sFullPath, tostring((self._panel)._nPanelId), tostring(self.__cname)))
    end
    return bSuc
  end
end

BaseCtrl.SetSprite_FrameColor = function(self, imgObj, nRarity, sFrameType, bBigSprites)
  -- function num : 0_26 , upvalues : _ENV
  local sPngName = sFrameType .. (AllEnum.FrameColor_New)[nRarity]
  if bBigSprites then
    return self:SetPngSprite(imgObj, "UI/big_sprites/" .. sPngName)
  else
    return self:SetAtlasSprite(imgObj, "12_rare", sPngName)
  end
end

BaseCtrl.SetSprite_Coin = function(self, imgObj, nCoinItemId)
  -- function num : 0_27 , upvalues : _ENV
  local mapItem = (ConfigTable.GetData_Item)(nCoinItemId)
  if mapItem == nil then
    return false
  else
    if mapItem.Icon2 == nil or mapItem.Icon2 == "" then
      return false
    else
      return self:SetPngSprite(imgObj, mapItem.Icon2)
    end
  end
end

BaseCtrl.SetAvgCharHeadIcon = function(self, imgObj, sSpeakerId, sFace)
  -- function num : 0_28 , upvalues : _ENV
  if sFace == nil then
    sFace = "002"
  end
  if sSpeakerId == nil or sSpeakerId == "" or sSpeakerId == "avg0_1" or sSpeakerId == "0" then
    sSpeakerId = AdjustMainRoleAvgCharId()
  end
  local sIconPath = (string.format)("Icon/AvgHead/%s/%s_%s", sSpeakerId, sSpeakerId, sFace)
  return self:SetPngSprite(imgObj, sIconPath)
end

BaseCtrl.GetAvgStageEffect = function(self, sName, sType)
  -- function num : 0_29 , upvalues : _ENV, sRootPath, GameResourceLoader, ResType, typeof
  if sName == nil then
    return nil
  end
  local sFullPath = (string.format)("%sImageAvg/AvgStageEffect/%s.png", sRootPath, sName)
  return (GameResourceLoader.LoadAsset)(ResType.Any, sFullPath, typeof(Texture))
end

BaseCtrl.GetAvgPortrait = function(self, sAvgCharId, sPose, sFace)
  -- function num : 0_30 , upvalues : _ENV, sRootPath, GameResourceLoader, ResType, typeof
  local sPathBody = (string.format)("%sActor2D/CharacterAvg/%s/atlas_png/%s/%s_%s_001.png", sRootPath, sAvgCharId, sPose, sAvgCharId, sPose)
  local sPathFace = (string.format)("%sActor2D/CharacterAvg/%s/atlas_png/%s/%s_%s_%s.png", sRootPath, sAvgCharId, sPose, sAvgCharId, sPose, sFace)
  local sPathBlackBody = (string.format)("%sActor2D/CharacterAvg/%s/%s_%s_001x.png", sRootPath, sAvgCharId, sAvgCharId, sPose)
  local spBody = ((GameResourceLoader.LoadAsset)(ResType.Any, sPathBody, typeof(Sprite)))
  local spFace = nil
  if (GameResourceLoader.ExistsAsset)(sPathFace) == true then
    spFace = (GameResourceLoader.LoadAsset)(ResType.Any, sPathFace, typeof(Sprite))
  end
  local spBlackBody = spBody
  if (GameResourceLoader.ExistsAsset)(sPathBlackBody) == true then
    spBlackBody = (GameResourceLoader.LoadAsset)(ResType.Any, sPathBlackBody, typeof(Sprite))
  end
  local sFullPath = (string.format)("%sActor2D/CharacterAvg/%s/%s.asset", sRootPath, sAvgCharId, sAvgCharId)
  local objOffset = (GameResourceLoader.LoadAsset)(ResType.Any, sFullPath, typeof(CS.Actor2DOffsetData))
  local nX, nY = 0, 0
  if objOffset == nil then
    printError(sFullPath)
    return 
  end
  local s, x, y = objOffset:GetOffsetData(PanelId.AvgST, indexOfPose(sPose), true, nX, nY)
  local v3OffsetPos = Vector3(x, y, 0)
  local v3OffsetScale = Vector3(s, s, 1)
  return spBody, spFace, v3OffsetPos, v3OffsetScale, spBlackBody
end

BaseCtrl.GetAvgPortraitEmojiOffsetData = function(self, sAvgCharId, sPose, nEmojiIndex)
  -- function num : 0_31 , upvalues : _ENV, sRootPath, GameResourceLoader, ResType, typeof
  local sFullPath = (string.format)("%sActor2D/CharacterAvg/%s/%s.asset", sRootPath, sAvgCharId, sAvgCharId)
  local objOffset = (GameResourceLoader.LoadAsset)(ResType.Any, sFullPath, typeof(CS.Actor2DOffsetData))
  local nX, nY = 0, 0
  local s, x, y = objOffset:GetEmojiData(PanelId.AvgST, indexOfPose(sPose), nEmojiIndex, nX, nY)
  local v3OffsetPos = Vector3(x, y, 0)
  local v3OffsetScale = Vector3(s, (math.abs)(s), 1)
  return v3OffsetPos, v3OffsetScale
end

BaseCtrl.GetAvgHeadFrameOffsetData = function(self, sAvgCharId, sPose, nFrameIndex)
  -- function num : 0_32 , upvalues : _ENV, sRootPath, GameResourceLoader, ResType, typeof
  local sFullPath = (string.format)("%sActor2D/CharacterAvg/%s/%s.asset", sRootPath, sAvgCharId, sAvgCharId)
  local objOffset = (GameResourceLoader.LoadAsset)(ResType.Any, sFullPath, typeof(CS.Actor2DOffsetData))
  if nFrameIndex == 2 then
    nFrameIndex = 3
  end
  local nX, nY = 0, 0
  local s, x, y = objOffset:Get_AvgCharHeadFrameData(PanelId.AvgST, indexOfPose(sPose), nFrameIndex, nX, nY)
  return x, y, s
end

BaseCtrl.OnEvent_AvgSpeedUp_Timer = function(self, nRate)
  -- function num : 0_33
  local n = #self._tbTimer
  for i = n, 1, -1 do
    local timer = (self._tbTimer)[i]
    if timer ~= nil then
      timer:SetSpeed(nRate)
    end
  end
end

BaseCtrl.SetAvgCharHeadIconByPrefab = function(self, img, sPrefabPath)
  -- function num : 0_34 , upvalues : sRootPath, GameResourceLoader, ResType, typeof, _ENV
  local sFullPath = sRootPath .. sPrefabPath
  local prefab = (GameResourceLoader.LoadAsset)(ResType.Any, sFullPath, typeof(GameObject), "UI", (self._panel)._nPanelId)
  ;
  (NovaAPI.SetImageSpriteWithPrefab)(img, prefab)
end

BaseCtrl.AddTimer = function(self, nTargetCount, nInterval, sCallbackName, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
  -- function num : 0_35 , upvalues : _ENV, TimerManager
  local callback = nil
  if type(sCallbackName) == "function" then
    callback = sCallbackName
  else
    callback = self[sCallbackName]
  end
  if type(callback) == "function" then
    local timer = (TimerManager.Add)(nTargetCount, nInterval, self, callback, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
    if timer ~= nil then
      if self:GetPanelId() == PanelId.AvgST and type((self._panel).nSpeedRate) == "number" then
        timer:SetSpeed((self._panel).nSpeedRate)
      end
      ;
      (table.insert)(self._tbTimer, timer)
    end
    return timer
  else
    do
      do return nil end
    end
  end
end

BaseCtrl._autoRemoveTimer = function(self, timer)
  -- function num : 0_36 , upvalues : _ENV
  local n = #self._tbTimer
  for i = n, 1, -1 do
    local timer = (self._tbTimer)[i]
    if timer ~= nil and timer:IsUnused() == true then
      (table.remove)(self._tbTimer, i)
    end
  end
end

BaseCtrl.CreatePrefabInstance = function(self, sPrefabPath, trParent)
  -- function num : 0_37 , upvalues : sRootPath, GameResourceLoader, ResType, typeof, _ENV
  local sFullPath = sRootPath .. sPrefabPath
  local prefab = (GameResourceLoader.LoadAsset)(ResType.Any, sFullPath, typeof(Object), "UI", (self._panel)._nPanelId)
  if trParent == nil then
    trParent = (self.gameObject).transform
  end
  local goPrefabIns = instantiate(prefab, trParent)
  goPrefabIns.name = sPrefabPath
  -- DECOMPILER ERROR at PC23: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (self._mapPrefab)[sPrefabPath] = goPrefabIns
  return goPrefabIns
end

BaseCtrl.DestroyPrefabInstance = function(self, sPrefabPath)
  -- function num : 0_38 , upvalues : _ENV
  local goIns = (self._mapPrefab)[sPrefabPath]
  if goIns ~= nil then
    destroy(goIns)
    -- DECOMPILER ERROR at PC8: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self._mapPrefab)[sPrefabPath] = nil
  end
end

BaseCtrl.LoadAsset = function(self, sPrefabPath, assetType)
  -- function num : 0_39 , upvalues : sRootPath, typeof, _ENV, GameResourceLoader, ResType
  local sFullPath = sRootPath .. sPrefabPath
  if assetType == nil then
    assetType = typeof(Object)
  end
  local prefab = (GameResourceLoader.LoadAsset)(ResType.Any, sFullPath, assetType, "UI", (self._panel)._nPanelId)
  -- DECOMPILER ERROR at PC20: Confused about usage of register: R5 in 'UnsetPending'

  if prefab ~= nil then
    (self._mapLoadAssets)[sPrefabPath] = prefab
  end
  return prefab
end

BaseCtrl.LoadAssetAsync = function(self, sPrefabPath, assetType, callback)
  -- function num : 0_40 , upvalues : sRootPath, typeof, _ENV, GameResourceLoader, ResType
  local sFullPath = sRootPath .. sPrefabPath
  if assetType == nil then
    assetType = typeof(Object)
  end
  local callBack = function(obj)
    -- function num : 0_40_0 , upvalues : self, sPrefabPath, callback
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R1 in 'UnsetPending'

    if obj ~= nil then
      if obj ~= nil then
        (self._mapLoadAssets)[sPrefabPath] = obj
      end
      if callback ~= nil then
        callback(obj)
      end
    end
  end

  ;
  (GameResourceLoader.LoadAssetAsync)(ResType.Any, sFullPath, assetType, "UI", (self._panel)._nPanelId, callBack)
end

BaseCtrl.UnLoadAsset = function(self, sPrefabPath)
  -- function num : 0_41
  local prefab = (self._mapLoadAssets)[sPrefabPath]
  if prefab ~= nil then
    prefab = nil
    -- DECOMPILER ERROR at PC6: Confused about usage of register: R3 in 'UnsetPending'

    ;
    (self._mapLoadAssets)[sPrefabPath] = nil
  end
end

BaseCtrl.SpawnPrefabInstance = function(self, prefab, sLuaClassName, sPoolName, parent)
  -- function num : 0_42 , upvalues : AdventureModuleHelper, _ENV
  local goPrefabIns = (AdventureModuleHelper.SpawnPrefabInstance)(prefab, sPoolName, parent)
  local luaClassName = require(sLuaClassName)
  local objCtrl = (luaClassName.new)(goPrefabIns, self._panel)
  objCtrl:_Enter()
  return objCtrl
end

BaseCtrl.DespawnPrefabInstance = function(self, objCtrl, sPoolName)
  -- function num : 0_43 , upvalues : AdventureModuleHelper
  if objCtrl ~= nil then
    objCtrl:_PreExit()
    objCtrl:_Exit()
    objCtrl:_Destroy()
    ;
    (AdventureModuleHelper.DespawnPrefabInstance)(objCtrl.gameObject, sPoolName)
  end
end

BaseCtrl.BindCtrlByNode = function(self, goNode, sCtrlName)
  -- function num : 0_44 , upvalues : _ENV
  local objCtrl = nil
  local luaClass = require(sCtrlName)
  if luaClass == nil then
    printError("Ctrl Lua not found, path:" .. sCtrlName)
  else
    objCtrl = (luaClass.new)(goNode, self._panel)
    ;
    (table.insert)((self._panel)._tbObjDyncChildCtrl, objCtrl)
    objCtrl:_Enter()
  end
  return objCtrl
end

BaseCtrl.UnbindCtrlByNode = function(self, objCtrl)
  -- function num : 0_45 , upvalues : _ENV
  objCtrl:_PreExit()
  objCtrl:_Exit()
  objCtrl:_Destroy()
  objCtrl.gameObject = nil
  ;
  (table.remove)((self._panel)._tbObjDyncChildCtrl, (table.indexof)((self._panel)._tbObjDyncChildCtrl, objCtrl))
end

BaseCtrl.SetAnimationCallback = function(self, animatior, sCallbackName)
  -- function num : 0_46 , upvalues : _ENV
  local wait = function()
    -- function num : 0_46_0 , upvalues : _ENV, animatior, self, sCallbackName
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    local time = (animatior:GetCurrentAnimatorStateInfo(0)).length
    self:AddTimer(1, time, sCallbackName, true, true, true)
  end

  ;
  (cs_coroutine.start)(wait)
end

BaseCtrl.ParseHitDamageDesc = function(self, nHitDamageId, nLevel)
  -- function num : 0_47 , upvalues : _ENV, ConfigData
  local sDesc = ""
  local mapDamage = (ConfigTable.GetData_HitDamage)(nHitDamageId)
  if not mapDamage then
    printError("该 hit damage id 找不到数据:" .. nHitDamageId)
    sDesc = (string.format)("<color=#FF0000>%d</color>", nHitDamageId)
    return sDesc
  end
  local nPercent = (mapDamage.SkillPercentAmend)[nLevel]
  local nAbs = (mapDamage.SkillAbsAmend)[nLevel]
  if not nPercent or not nAbs then
    printError((string.format)("该技能等级在 HitDamage 表中找不到数据, hit damage id:%d, level:%d", nHitDamageId, nLevel))
    sDesc = (string.format)("<color=#FF0000>%d</color>", nHitDamageId)
    return sDesc
  end
  nPercent = nPercent * ConfigData.IntFloatPrecision
  nPercent = FormatNum(nPercent)
  nAbs = FormatNum(nAbs)
  if nPercent ~= 0 or not "" then
    local sPercent = tostring(nPercent) .. "%%"
  end
  if nAbs ~= 0 or not "" then
    local sAbs = tostring(nAbs)
  end
  if nPercent ~= 0 and nAbs ~= 0 then
    sDesc = sPercent .. "+" .. sAbs
  else
    sDesc = sPercent .. sAbs
  end
  return sDesc
end

BaseCtrl.ThousandsNumber = function(self, number)
  -- function num : 0_48 , upvalues : _ENV
  local formatted = (tostring(number))
  -- DECOMPILER ERROR at PC3: Overwrote pending register: R3 in 'AssignReg'

  local k = .end
  while 1 do
    formatted = (string.gsub)(formatted, "^(.*-?%d+)(%d%d%d)", "%1,%2")
  end
  if k ~= 0 then
    return formatted
  end
end

BaseCtrl.GetGamepadUINode = function(self)
  -- function num : 0_49 , upvalues : _ENV
  local tbNode = {}
  if self.gameObject == nil or type(self._mapNodeConfig) ~= "table" then
    return tbNode
  end
  local add = function(sKey, mapConfig, sComponentName)
    -- function num : 0_49_0 , upvalues : _ENV, self, tbNode
    if mapConfig.sComponentName == sComponentName then
      local nCount = mapConfig.nCount
      if type(nCount) == "number" then
        for i = 1, nCount do
          local mapNode = ((self._mapNode)[sKey])[i]
          if mapNode then
            (table.insert)(tbNode, {mapNode = mapNode, sComponentName = sComponentName, sAction = mapConfig.sAction})
          end
        end
      else
        do
          local mapNode = (self._mapNode)[sKey]
          if mapNode then
            (table.insert)(tbNode, {mapNode = mapNode, sComponentName = sComponentName, sAction = mapConfig.sAction})
          end
        end
      end
    end
  end

  for sKey,mapConfig in pairs(self._mapNodeConfig) do
    add(sKey, mapConfig, "NaviButton")
    add(sKey, mapConfig, "GamepadScroll")
  end
  return tbNode
end

return BaseCtrl

