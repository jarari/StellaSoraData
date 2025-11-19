local GamepadUIManager = {}
local InputManager = CS.InputManager
local ClientManager = (CS.ClientManager).Instance
local sRootPath = Settings.AB_ROOT_PATH
local nCurUIType = (AllEnum.GamepadUIType).Other
local sCurUIName = nil
local tbHistory = {}
local mapGamepadUI = {}
local mapMouseConfig = {}
local bEnableInput = false
local bBlockUI = false
local bFirstInputEnable = false
local SetGamepadIcon = function(img, sAction)
  -- function num : 0_0 , upvalues : nCurUIType, _ENV, sRootPath
  local sIcon = nil
  if nCurUIType == (AllEnum.GamepadUIType).PS then
    sIcon = (ConfigTable.GetField)("GamepadAction", sAction, "PlayStationIcon")
  else
    if nCurUIType == (AllEnum.GamepadUIType).Xbox then
      sIcon = (ConfigTable.GetField)("GamepadAction", sAction, "XboxIcon")
    else
      if nCurUIType == (AllEnum.GamepadUIType).Keyboard or nCurUIType == (AllEnum.GamepadUIType).Mouse then
        sIcon = (ConfigTable.GetField)("GamepadAction", sAction, "KeyboardIcon")
      end
    end
  end
  if sIcon == "" then
    (img.gameObject):SetActive(false)
    return 
  end
  ;
  (img.gameObject):SetActive(true)
  sIcon = sRootPath .. sIcon .. ".png"
  ;
  (NovaAPI.SetImageSprite)(img, sIcon)
  ;
  (NovaAPI.SetImageNativeSize)(img)
end

local RefreshCurTypeUINode = function(v)
  -- function num : 0_1 , upvalues : nCurUIType, _ENV, SetGamepadIcon
  if not v.sAction then
    return 
  end
  if v.sComponentName == "NaviButton" then
    if (v.mapNode):IsNull() then
      return 
    end
    local trRoot = (((v.mapNode).gameObject):GetComponent("Transform")):Find("AnimRoot")
    if trRoot then
      local Other = trRoot:Find("Other")
      if not Other then
        return 
      end
      local General = trRoot:Find("General")
      local Xbox = trRoot:Find("Xbox")
      local PS = trRoot:Find("PS")
      local Keyboard = trRoot:Find("Keyboard")
      if General then
        if Xbox then
          (Xbox.gameObject):SetActive(false)
        end
        if PS then
          (PS.gameObject):SetActive(false)
        end
        if Keyboard then
          (Keyboard.gameObject):SetActive(false)
        end
        ;
        (General.gameObject):SetActive(nCurUIType ~= (AllEnum.GamepadUIType).Other)
        ;
        (Other.gameObject):SetActive(nCurUIType == (AllEnum.GamepadUIType).Other)
        if nCurUIType ~= (AllEnum.GamepadUIType).Other then
          local icon = General:Find("imgAction")
          if icon then
            SetGamepadIcon(icon:GetComponent("Image"), v.sAction)
          end
        end
      elseif nCurUIType ~= (AllEnum.GamepadUIType).Xbox then
        (Xbox.gameObject):SetActive(General or not Xbox or not PS or not Keyboard)
        ;
        (PS.gameObject):SetActive(nCurUIType == (AllEnum.GamepadUIType).PS)
        ;
        (Keyboard.gameObject):SetActive(nCurUIType == (AllEnum.GamepadUIType).Keyboard or nCurUIType == (AllEnum.GamepadUIType).Mouse)
        ;
        (Other.gameObject):SetActive(nCurUIType == (AllEnum.GamepadUIType).Other)
        do
          local icon = nil
          if nCurUIType == (AllEnum.GamepadUIType).Xbox then
            icon = Xbox:Find("imgAction")
          elseif nCurUIType == (AllEnum.GamepadUIType).PS then
            icon = PS:Find("imgAction")
          elseif nCurUIType == (AllEnum.GamepadUIType).Keyboard or nCurUIType == (AllEnum.GamepadUIType).Mouse then
            icon = Keyboard:Find("imgAction")
          end
          if icon then
            SetGamepadIcon(icon:GetComponent("Image"), v.sAction)
          end
          if v.sComponentName == "GamepadScroll" then
            if (v.mapNode):IsNull() then
              return 
            end
            local trRoot = (((v.mapNode).gameObject):GetComponent("Transform")):Find("Scrollbar")
            if trRoot then
              local icon = trRoot:Find("imgAction")
              if nCurUIType == (AllEnum.GamepadUIType).Other then
                do
                  (icon.gameObject):SetActive(not icon)
                  if nCurUIType ~= (AllEnum.GamepadUIType).Other then
                    SetGamepadIcon(icon:GetComponent("Image"), v.sAction)
                  end
                  -- DECOMPILER ERROR: 15 unprocessed JMP targets
                end
              end
            end
          end
        end
      end
    end
  end
end

local RefreshCurTypeUI = function()
  -- function num : 0_2 , upvalues : sCurUIName, mapGamepadUI, _ENV, mapMouseConfig, RefreshCurTypeUINode
  if not sCurUIName then
    return 
  end
  local tbNode = mapGamepadUI[sCurUIName]
  if (tbNode == nil or next(tbNode) == nil) and mapMouseConfig[sCurUIName] == nil then
    printWarn("GamepadUIManager：当前UI内节点刷新失败，可能该UI从来没有打开过：" .. sCurUIName)
    return 
  end
  for _,v in pairs(tbNode) do
    RefreshCurTypeUINode(v)
  end
end

local ChangeUIType = function(nAfterType)
  -- function num : 0_3 , upvalues : nCurUIType, _ENV, sCurUIName, RefreshCurTypeUI
  if nAfterType == nCurUIType then
    return 
  end
  local nBeforeType = nCurUIType
  nCurUIType = nAfterType
  ;
  (EventManager.Hit)("GamepadUIChange", sCurUIName, nBeforeType, nAfterType)
  RefreshCurTypeUI()
end

local GetUITypeByGamepad = function()
  -- function num : 0_4 , upvalues : InputManager, _ENV
  local nType = (InputManager.Instance):CheckGamepadType()
  local nAfterType = (AllEnum.GamepadUIType).Other
  if nType == (InputManager.GamepadType).PS then
    nAfterType = (AllEnum.GamepadUIType).PS
  else
    if nType == (InputManager.GamepadType).XBox or nType == (InputManager.GamepadType).Switch or nType == (InputManager.GamepadType).Other then
      nAfterType = (AllEnum.GamepadUIType).Xbox
    else
      if nType == (InputManager.GamepadType).None then
        nAfterType = (AllEnum.GamepadUIType).Other
      end
    end
  end
  return nAfterType
end

local OnEvent_LastInputDeviceChange = function(_, nType)
  -- function num : 0_5 , upvalues : _ENV, ClientManager, InputManager, GetUITypeByGamepad, ChangeUIType
  local bMobile = (NovaAPI.IsMobilePlatform)()
  local bTable = ClientManager.isTabletDevice
  local nAfterType = (AllEnum.GamepadUIType).Other
  if nType == (InputManager.InputDeviceType).PSGamepad then
    nAfterType = (AllEnum.GamepadUIType).PS
  else
    if nType == (InputManager.InputDeviceType).XBoxGamepad then
      nAfterType = (AllEnum.GamepadUIType).Xbox
    else
      if nType == (InputManager.InputDeviceType).Keyboard and (not bMobile or bTable) then
        nAfterType = (AllEnum.GamepadUIType).Keyboard
      else
        if nType == (InputManager.InputDeviceType).Mouse and (not bMobile or bTable) then
          nAfterType = (AllEnum.GamepadUIType).Mouse
        else
          if nType == (InputManager.InputDeviceType).Other then
            nAfterType = GetUITypeByGamepad()
          else
            if nType == (InputManager.InputDeviceType).None then
              nAfterType = (AllEnum.GamepadUIType).Other
            end
          end
        end
      end
    end
  end
  ChangeUIType(nAfterType)
end

local GetUITypeByInputDevice = function()
  -- function num : 0_6 , upvalues : _ENV, InputManager, GetUITypeByGamepad
  local bMobile = (NovaAPI.IsMobilePlatform)()
  local nType = (InputManager.Instance):CheckInputDeviceType()
  local nAfterType = (AllEnum.GamepadUIType).Other
  if nType == (InputManager.InputDeviceType).PSGamepad then
    nAfterType = (AllEnum.GamepadUIType).PS
  else
    if nType == (InputManager.InputDeviceType).XBoxGamepad then
      nAfterType = (AllEnum.GamepadUIType).Xbox
    else
      if nType == (InputManager.InputDeviceType).Keyboard and not bMobile then
        nAfterType = (AllEnum.GamepadUIType).Keyboard
      else
        if nType == (InputManager.InputDeviceType).Mouse and not bMobile then
          nAfterType = (AllEnum.GamepadUIType).Mouse
        else
          if nType == (InputManager.InputDeviceType).Other then
            nAfterType = GetUITypeByGamepad()
          else
            if nType == (InputManager.InputDeviceType).None then
              nAfterType = (AllEnum.GamepadUIType).Other
            end
          end
        end
      end
    end
  end
  return nAfterType
end

local OnEvent_OnDeviceChange = function(_, changeType)
  -- function num : 0_7 , upvalues : GetUITypeByInputDevice, ChangeUIType
  if changeType.value__ == 0 or changeType.value__ == 1 then
    local nAfterType = GetUITypeByInputDevice()
    ChangeUIType(nAfterType)
  end
end

local OnEvent_BlockGamepadUI = function(_, bBlock)
  -- function num : 0_8 , upvalues : bBlockUI, sCurUIName, mapGamepadUI, _ENV, bFirstInputEnable
  bBlockUI = bBlock
  if not sCurUIName then
    return 
  end
  local tbNode = mapGamepadUI[sCurUIName]
  if tbNode == nil or next(tbNode) == nil then
    return 
  end
  for _,v in pairs(tbNode) do
    if (v.mapNode):IsNull() == false then
      if bFirstInputEnable then
        (NovaAPI.SetComponentEnable)(v.mapNode, not bBlock)
      else
        ;
        (NovaAPI.SetComponentEnable)(v.mapNode, false)
      end
    else
      printWarn("GamepadUIManager：当前UI实例已销毁，无需屏蔽：" .. sCurUIName)
      return 
    end
  end
end

local EnableNode = function(sCtrlName)
  -- function num : 0_9 , upvalues : _ENV, mapGamepadUI, mapMouseConfig, sCurUIName, bBlockUI, bFirstInputEnable
  if not sCtrlName then
    printWarn("GamepadUIManager：当前UI内节点打开失败，CtrlName为空")
    return 
  end
  if (NovaAPI.IsEditorPlatform)() then
    printLog("GamepadUIManager：Enable UI " .. sCtrlName)
  end
  local tbNode = mapGamepadUI[sCtrlName]
  if (tbNode == nil or next(tbNode) == nil) and mapMouseConfig[sCurUIName] == nil then
    printWarn("GamepadUIManager：当前UI内节点打开失败，可能该UI从来没有打开过：" .. sCtrlName)
    return 
  end
  for _,v in pairs(tbNode) do
    if (v.mapNode):IsNull() then
      printError("GamepadUIManager：当前UI内节点打开失败，UI实例已销毁：" .. sCtrlName)
      return 
    end
    if not bBlockUI and bFirstInputEnable then
      if (v.mapNode).enabled == true then
        (NovaAPI.SetComponentEnable)(v.mapNode, false)
      end
      ;
      (NovaAPI.SetComponentEnable)(v.mapNode, true)
    else
      ;
      (NovaAPI.SetComponentEnable)(v.mapNode, false)
    end
  end
end

local DisableNode = function(sCtrlName)
  -- function num : 0_10 , upvalues : _ENV, mapGamepadUI, mapMouseConfig, sCurUIName
  if not sCtrlName then
    printWarn("GamepadUIManager：当前UI内节点关闭失败，CtrlName为空")
    return 
  end
  if (NovaAPI.IsEditorPlatform)() then
    printLog("GamepadUIManager：Disable UI " .. sCtrlName)
  end
  local tbNode = mapGamepadUI[sCtrlName]
  if (tbNode == nil or next(tbNode) == nil) and mapMouseConfig[sCurUIName] == nil then
    printWarn("GamepadUIManager：当前UI内节点关闭失败，可能该UI从来没有打开过：" .. sCtrlName)
    return 
  end
  for _,v in pairs(tbNode) do
    if (v.mapNode):IsNull() then
      printError("GamepadUIManager：当前UI内节点关闭失败，UI实例已销毁：" .. sCtrlName)
      return 
    end
    ;
    (NovaAPI.SetComponentEnable)(v.mapNode, false)
  end
end

local OnEvent_FirstInputEnable = function()
  -- function num : 0_11 , upvalues : bFirstInputEnable, sCurUIName, EnableNode
  bFirstInputEnable = true
  if sCurUIName then
    EnableNode(sCurUIName)
  end
end

local OnEvent_OpenBuiltinAlert = function(_, bOpen, _okBtn, _confirmBtn, _cancelBtn)
  -- function num : 0_12 , upvalues : bEnableInput, _ENV, GamepadUIManager
  if not bEnableInput then
    (NovaAPI.SetNaviButtonAction)(_okBtn, false)
    ;
    (NovaAPI.SetNaviButtonAction)(_confirmBtn, false)
    ;
    (NovaAPI.SetNaviButtonAction)(_cancelBtn, false)
    return 
  end
  if bOpen then
    local tbGamepadUINode = {
[1] = {mapNode = _okBtn, sComponentName = "NaviButton", sAction = "buttonSouth"}
, 
[2] = {mapNode = _confirmBtn, sComponentName = "NaviButton", sAction = "buttonSouth"}
, 
[3] = {mapNode = _cancelBtn, sComponentName = "NaviButton", sAction = "buttonEast"}
}
    ;
    (GamepadUIManager.EnableGamepadUI)("BuiltinUI", tbGamepadUINode)
    ;
    (NovaAPI.SetNaviButtonAction)(_okBtn, true)
    ;
    (NovaAPI.SetNaviButtonAction)(_confirmBtn, true)
    ;
    (NovaAPI.SetNaviButtonAction)(_cancelBtn, true)
  else
    do
      ;
      (GamepadUIManager.DisableGamepadUI)("BuiltinUI")
    end
  end
end

local Uninit = function(_)
  -- function num : 0_13 , upvalues : _ENV, GamepadUIManager, OnEvent_OnDeviceChange, OnEvent_LastInputDeviceChange, OnEvent_BlockGamepadUI, OnEvent_FirstInputEnable, OnEvent_OpenBuiltinAlert, Uninit
  (EventManager.Remove)("LuaEventName_OnDeviceChange", GamepadUIManager, OnEvent_OnDeviceChange)
  ;
  (EventManager.Remove)("LuaEventName_LastInputDeviceChange", GamepadUIManager, OnEvent_LastInputDeviceChange)
  ;
  (EventManager.Remove)("__BlockGamepadUI", GamepadUIManager, OnEvent_BlockGamepadUI)
  ;
  (EventManager.Remove)("FirstInputEnable", GamepadUIManager, OnEvent_FirstInputEnable)
  ;
  (EventManager.Remove)("__OpenBuiltinAlert", GamepadUIManager, OnEvent_OpenBuiltinAlert)
  ;
  (EventManager.Remove)(EventId.CSLuaManagerShutdown, GamepadUIManager, Uninit)
end

GamepadUIManager.Init = function()
  -- function num : 0_14 , upvalues : nCurUIType, GetUITypeByInputDevice, _ENV, GamepadUIManager, OnEvent_OnDeviceChange, OnEvent_LastInputDeviceChange, OnEvent_BlockGamepadUI, OnEvent_FirstInputEnable, OnEvent_OpenBuiltinAlert, Uninit
  nCurUIType = GetUITypeByInputDevice()
  ;
  (EventManager.Add)("LuaEventName_OnDeviceChange", GamepadUIManager, OnEvent_OnDeviceChange)
  ;
  (EventManager.Add)("LuaEventName_LastInputDeviceChange", GamepadUIManager, OnEvent_LastInputDeviceChange)
  ;
  (EventManager.Add)("__BlockGamepadUI", GamepadUIManager, OnEvent_BlockGamepadUI)
  ;
  (EventManager.Add)("FirstInputEnable", GamepadUIManager, OnEvent_FirstInputEnable)
  ;
  (EventManager.Add)("__OpenBuiltinAlert", GamepadUIManager, OnEvent_OpenBuiltinAlert)
  ;
  (EventManager.Add)(EventId.CSLuaManagerShutdown, GamepadUIManager, Uninit)
end

GamepadUIManager.EnableGamepadUI = function(sCtrlName, tbNode, goDefaultSelected, bEnableVirtualMouse, bBlockCursor)
  -- function num : 0_15 , upvalues : sCurUIName, _ENV, InputManager, DisableNode, mapGamepadUI, mapMouseConfig, tbHistory, RefreshCurTypeUI, EnableNode
  if sCurUIName == sCtrlName then
    printWarn("GamepadUIManager：重复打开Gamepad UI：" .. sCtrlName)
    return 
  end
  ;
  (NovaAPI.ClearSelectedUI)()
  if goDefaultSelected then
    (NovaAPI.SetSelectedUI)(goDefaultSelected)
  end
  -- DECOMPILER ERROR at PC23: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (InputManager.Instance).IsVirtualMouseEnabled = bEnableVirtualMouse == true
  -- DECOMPILER ERROR at PC29: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (InputManager.Instance).IsBlockCursor = bBlockCursor == true
  local bSwitch = false
  if sCurUIName then
    DisableNode(sCurUIName)
    bSwitch = true
  end
  sCurUIName = sCtrlName
  mapGamepadUI[sCurUIName] = clone(tbNode)
  if not mapMouseConfig[sCurUIName] then
    mapMouseConfig[sCurUIName] = {}
  end
  -- DECOMPILER ERROR at PC57: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (mapMouseConfig[sCurUIName]).VirtualMouse = bEnableVirtualMouse == true
  -- DECOMPILER ERROR at PC64: Confused about usage of register: R6 in 'UnsetPending'

  ;
  (mapMouseConfig[sCurUIName]).BlockCursor = bBlockCursor == true
  ;
  (table.insert)(tbHistory, sCurUIName)
  RefreshCurTypeUI()
  if bSwitch then
    local wait = function()
    -- function num : 0_15_0 , upvalues : _ENV, EnableNode, sCurUIName
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    EnableNode(sCurUIName)
  end

    ;
    (cs_coroutine.start)(wait)
  else
    EnableNode(sCurUIName)
  end
  -- DECOMPILER ERROR: 8 unprocessed JMP targets
end

GamepadUIManager.DisableGamepadUI = function(sCtrlName)
  -- function num : 0_16 , upvalues : _ENV, tbHistory, sCurUIName, DisableNode, mapGamepadUI, mapMouseConfig, InputManager, RefreshCurTypeUI, EnableNode
  local nIndex = (table.indexof)(tbHistory, sCtrlName)
  if nIndex == 0 then
    return 
  end
  if sCurUIName == sCtrlName then
    DisableNode(sCtrlName)
    mapGamepadUI[sCtrlName] = nil
    mapMouseConfig[sCtrlName] = nil
    ;
    (table.remove)(tbHistory, nIndex)
    sCurUIName = nil
    if next(tbHistory) ~= nil then
      sCurUIName = tbHistory[#tbHistory]
      -- DECOMPILER ERROR at PC36: Confused about usage of register: R2 in 'UnsetPending'

      ;
      (InputManager.Instance).IsVirtualMouseEnabled = (mapMouseConfig[sCurUIName]).VirtualMouse
      -- DECOMPILER ERROR at PC41: Confused about usage of register: R2 in 'UnsetPending'

      ;
      (InputManager.Instance).IsBlockCursor = (mapMouseConfig[sCurUIName]).BlockCursor
      RefreshCurTypeUI()
      local wait = function()
    -- function num : 0_16_0 , upvalues : _ENV, sCurUIName, EnableNode
    (coroutine.yield)(((CS.UnityEngine).WaitForEndOfFrame)())
    if sCurUIName then
      EnableNode(sCurUIName)
      ;
      (EventManager.Hit)("GamepadUIReopen", sCurUIName)
    else
      printWarn("GamepadUIManager：关闭历史未找到对应ctrl")
    end
  end

      ;
      (cs_coroutine.start)(wait)
    end
  else
    do
      mapGamepadUI[sCtrlName] = nil
      mapMouseConfig[sCtrlName] = nil
      ;
      (table.remove)(tbHistory, nIndex)
    end
  end
end

GamepadUIManager.AddGamepadUINode = function(sCtrlName, tbNode)
  -- function num : 0_17 , upvalues : mapGamepadUI, _ENV, sCurUIName, EnableNode, RefreshCurTypeUINode, DisableNode
  if not mapGamepadUI or not mapGamepadUI[sCtrlName] then
    printWarn("GamepadUIManager：当前ui不存在，添加节点失败Gamepad UI：" .. sCtrlName)
    return 
  end
  for _,v in pairs(tbNode) do
    (table.insert)(mapGamepadUI[sCtrlName], v)
  end
  if sCurUIName == sCtrlName then
    EnableNode(sCtrlName)
    for _,v in pairs(tbNode) do
      RefreshCurTypeUINode(v)
    end
  else
    do
      DisableNode(sCtrlName)
    end
  end
end

GamepadUIManager.SetSelectedUI = function(goSelected)
  -- function num : 0_18 , upvalues : _ENV
  (NovaAPI.SetSelectedUI)(goSelected)
end

GamepadUIManager.ClearSelectedUI = function()
  -- function num : 0_19 , upvalues : _ENV
  (NovaAPI.ClearSelectedUI)()
end

GamepadUIManager.SetNavigation = function(tbUIObj, bHorizontal, bLoop)
  -- function num : 0_20 , upvalues : _ENV
  if bHorizontal == nil then
    bHorizontal = true
  end
  if bLoop == nil then
    bLoop = true
  end
  ;
  (NovaAPI.SetGamepadUINavigation)(tbUIObj, bHorizontal, bLoop)
end

GamepadUIManager.GetCurUIType = function()
  -- function num : 0_21 , upvalues : nCurUIType
  return nCurUIType
end

GamepadUIManager.GetCurUIName = function()
  -- function num : 0_22 , upvalues : sCurUIName
  return sCurUIName
end

GamepadUIManager.GetInputState = function()
  -- function num : 0_23 , upvalues : bEnableInput
  return bEnableInput
end

GamepadUIManager.GetPrveUIName = function()
  -- function num : 0_24 , upvalues : _ENV, tbHistory
  if next(tbHistory) == nil then
    return 
  end
  local nCount = #tbHistory
  if nCount > 1 then
    return tbHistory[nCount - 1]
  end
end

GamepadUIManager.EnterAdventure = function(bSkipFirstInputEnable)
  -- function num : 0_25 , upvalues : InputManager, sCurUIName, tbHistory, mapGamepadUI, mapMouseConfig, bEnableInput, bFirstInputEnable
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R1 in 'UnsetPending'

  (InputManager.Instance).IsVirtualMouseEnabled = false
  -- DECOMPILER ERROR at PC3: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (InputManager.Instance).IsBlockCursor = false
  -- DECOMPILER ERROR at PC5: Confused about usage of register: R1 in 'UnsetPending'

  ;
  (InputManager.Instance).IsBattleSubmit = true
  sCurUIName = nil
  tbHistory = {}
  mapGamepadUI = {}
  mapMouseConfig = {}
  bEnableInput = true
  bFirstInputEnable = bSkipFirstInputEnable
end

GamepadUIManager.QuitAdventure = function()
  -- function num : 0_26 , upvalues : InputManager, sCurUIName, tbHistory, mapGamepadUI, mapMouseConfig, bEnableInput, bFirstInputEnable
  -- DECOMPILER ERROR at PC1: Confused about usage of register: R0 in 'UnsetPending'

  (InputManager.Instance).IsVirtualMouseEnabled = true
  -- DECOMPILER ERROR at PC3: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (InputManager.Instance).IsBlockCursor = false
  -- DECOMPILER ERROR at PC5: Confused about usage of register: R0 in 'UnsetPending'

  ;
  (InputManager.Instance).IsBattleSubmit = false
  sCurUIName = nil
  tbHistory = {}
  mapGamepadUI = {}
  mapMouseConfig = {}
  bEnableInput = false
  bFirstInputEnable = false
end

GamepadUIManager.GetInputName = function(mapInput)
  -- function num : 0_27 , upvalues : _ENV
  if not mapInput.name or not mapInput.displayName then
    return 
  end
  local sName = mapInput.displayName
  if (string.find)(mapInput.name, "left") then
    sName = (string.gsub)(mapInput.name, "left", "L-")
  else
    if (string.find)(mapInput.name, "right") then
      sName = (string.gsub)(mapInput.name, "right", "R-")
    else
      if sName == "Num Del" then
        sName = "Num."
      else
        if (string.find)(mapInput.name, "numpad") then
          local position = (string.find)(sName, " ")
          if position then
            sName = "Num" .. (string.sub)(sName, position + 1)
          else
            sName = "Num" .. sName
          end
        end
      end
    end
  end
  do
    return sName
  end
end

return GamepadUIManager

