local PopUpManager = {}
local ClientManager = (CS.ClientManager).Instance
local LocalData = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
local ModuleManager = require("GameCore.Module.ModuleManager")
local popUpPanelConfig = {}
local _tbPopUpQueue = {}
local _tbPopUpCache = {}
local _popUpCallback = nil
local _bInPopUpQueue = false
local _bInterruptPopUp = false
local _tbSpecifyPopUp = {}
local _tempPopUpMapData = {}
local _interruptPopUpIndex = 0
PopUpManager.Init = function()
  -- function num : 0_0 , upvalues : popUpPanelConfig, _ENV
  local foreachPopupSeq = function(mapData)
    -- function num : 0_0_0 , upvalues : popUpPanelConfig
    local data = {nPanelId = mapData.PanelId, nSortId = mapData.SortId, bLocalSave = mapData.bLocalSave}
    popUpPanelConfig[mapData.Type] = data
  end

  ForEachTableLine((ConfigTable.Get)("PopUpSequence"), foreachPopupSeq)
end

PopUpManager.InitLoginQueue = function()
  -- function num : 0_1 , upvalues : LocalData, _ENV, ClientManager, _tbPopUpQueue, PopUpManager
  local sTime = (LocalData.GetPlayerLocalData)("LoginPanelTime")
  local nTime = tonumber(sTime) or 0
  local nNextTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
  if nTime < nNextTime then
    _tbPopUpQueue = {}
    ;
    (PopUpManager.SaveLocalData)()
  else
    local sJson = (LocalData.GetPlayerLocalData)("LoginPanelQueue")
    local tb = decodeJson(sJson)
    if type(tb) == "table" then
      _tbPopUpQueue = tb
    end
  end
end

PopUpManager.SaveLocalData = function()
  -- function num : 0_2 , upvalues : ClientManager, _ENV, _tbPopUpQueue, popUpPanelConfig, LocalData, RapidJson
  local nNextTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
  local tbLocalSave = {}
  for _,v in ipairs(_tbPopUpQueue) do
    local mapConfig = popUpPanelConfig[v.nType]
    if mapConfig and mapConfig.bLocalSave then
      (table.insert)(tbLocalSave, v)
    end
  end
  ;
  (LocalData.SetPlayerLocalData)("LoginPanelQueue", (RapidJson.encode)(tbLocalSave))
  ;
  (LocalData.SetPlayerLocalData)("LoginPanelTime", tostring(nNextTime))
end

PopUpManager.StartShowPopUp = function(callback)
  -- function num : 0_3 , upvalues : _popUpCallback, _bInPopUpQueue, PopUpManager
  _popUpCallback = callback
  _bInPopUpQueue = true
  ;
  (PopUpManager.PopUpDeQueue)()
end

PopUpManager.PopUpEnQueue = function(nType, mapData)
  -- function num : 0_4 , upvalues : _ENV, _tbPopUpQueue, popUpPanelConfig
  local bAdded = false
  for nIndex,mapPopUp in ipairs(_tbPopUpQueue) do
    -- DECOMPILER ERROR at PC9: Confused about usage of register: R8 in 'UnsetPending'

    if mapPopUp.nType == nType then
      (_tbPopUpQueue[nIndex]).mapData = mapData
      bAdded = true
      break
    end
  end
  do
    if not bAdded then
      (table.insert)(_tbPopUpQueue, {nType = nType, mapData = mapData})
    end
    ;
    (table.sort)(_tbPopUpQueue, function(a, b)
    -- function num : 0_4_0 , upvalues : popUpPanelConfig
    local nSortA = (popUpPanelConfig[a.nType]).nSortId or 999
    local nSortB = (popUpPanelConfig[b.nType]).nSortId or 999
    do return nSortA < nSortB end
    -- DECOMPILER ERROR: 1 unprocessed JMP targets
  end
)
    if nType == (GameEnum.PopUpSeqType).MonthlyCard and (PlayerData.Mall):CheckOrderProcess() then
      return 
    end
    ;
    (EventManager.Hit)("MainViewCheckOpenPanel")
  end
end

PopUpManager.PopUpDeQueue = function()
  -- function num : 0_5 , upvalues : _popUpCallback, _tbPopUpCache, _bInPopUpQueue, _bInterruptPopUp, _interruptPopUpIndex, _ENV, _tbPopUpQueue, _tempPopUpMapData, PopUpManager, popUpPanelConfig
  local exitPopUpQueue = function()
    -- function num : 0_5_0 , upvalues : _popUpCallback, _tbPopUpCache, _bInPopUpQueue, _bInterruptPopUp, _interruptPopUpIndex, _ENV
    if _popUpCallback ~= nil then
      _popUpCallback()
    end
    _tbPopUpCache = {}
    _bInPopUpQueue = false
    _bInterruptPopUp = false
    _interruptPopUpIndex = 0
    ;
    (EventManager.Hit)("Event_MainViewPopUpEnd")
  end

  if #_tbPopUpQueue == 0 and not _bInterruptPopUp and _interruptPopUpIndex == 0 then
    exitPopUpQueue()
    return 
  end
  if not _bInterruptPopUp and _interruptPopUpIndex == 0 then
    _tempPopUpMapData = (table.remove)(_tbPopUpQueue, 1)
  else
    local mapData = _tempPopUpMapData.mapData
    for i = 1, _interruptPopUpIndex do
      (table.remove)(mapData, 1)
    end
    if #mapData == 0 then
      exitPopUpQueue()
      return 
    else
      _tempPopUpMapData.mapData = mapData
    end
  end
  do
    _bInterruptPopUp = false
    _interruptPopUpIndex = 0
    local mapNext = _tempPopUpMapData
    _tbPopUpCache[mapNext.nType] = true
    local callback = function(funcCall)
    -- function num : 0_5_1 , upvalues : PopUpManager
    (PopUpManager.PopUpDeQueue)()
    if funcCall ~= nil then
      funcCall()
    end
  end

    local mapConfig = popUpPanelConfig[mapNext.nType]
    if mapConfig ~= nil then
      if mapNext.nType == (GameEnum.PopUpSeqType).MessageBox then
        local msg = {nType = (AllEnum.MessageBox).Alert, sContent = mapNext.mapData, callbackConfirm = callback}
        ;
        (EventManager.Hit)(EventId.OpenMessageBox, msg)
      else
        do
          local mapData = {}
          if mapNext.nType == (GameEnum.PopUpSeqType).ActivityFaceAnnounce then
            for k,v in pairs(mapNext.mapData) do
              (table.insert)(mapData, v)
            end
          else
            do
              do
                mapData = mapNext.mapData
                ;
                (EventManager.Hit)(EventId.OpenPanel, mapConfig.nPanelId, mapData, callback)
                if mapConfig.bLocalSave then
                  (PopUpManager.SaveLocalData)()
                end
              end
            end
          end
        end
      end
    end
  end
end

PopUpManager.InterruptPopUp = function(index)
  -- function num : 0_6 , upvalues : _bInterruptPopUp, _interruptPopUpIndex
  _bInterruptPopUp = true
  _interruptPopUpIndex = index
end

PopUpManager.OpenPopUpPanelByType = function(nType, callback)
  -- function num : 0_7 , upvalues : _ENV, _tbPopUpQueue, popUpPanelConfig, PopUpManager
  local nRemoveIdx = 0
  for nIdx,data in ipairs(_tbPopUpQueue) do
    if data.nType == nType then
      nRemoveIdx = nIdx
      break
    end
  end
  do
    if nRemoveIdx ~= 0 then
      local mapNext = (table.remove)(_tbPopUpQueue, nRemoveIdx)
      local mapConfig = popUpPanelConfig[mapNext.nType]
      if mapConfig ~= nil then
        (EventManager.Hit)(EventId.OpenPanel, mapConfig.nPanelId, mapNext.mapData, callback)
        if mapConfig.bLocalSave then
          (PopUpManager.SaveLocalData)()
        end
      end
    else
      do
        if callback ~= nil then
          callback()
        end
      end
    end
  end
end

PopUpManager.OpenPopUpPanel = function(tbType, callback)
  -- function num : 0_8 , upvalues : PopUpManager, _tbSpecifyPopUp, _ENV
  local bInPopUp = (PopUpManager.CheckInPopUpQueue)()
  if bInPopUp then
    return 
  end
  _tbSpecifyPopUp = tbType
  local popUp = function()
    -- function num : 0_8_0 , upvalues : _tbSpecifyPopUp, callback, _ENV, PopUpManager, popUp
    if #_tbSpecifyPopUp == 0 then
      if callback ~= nil then
        callback()
      end
      return 
    end
    local nType = (table.remove)(_tbSpecifyPopUp, 1)
    ;
    (PopUpManager.OpenPopUpPanelByType)(nType, popUp)
  end

  popUp()
end

PopUpManager.CheckInPopUpQueue = function()
  -- function num : 0_9 , upvalues : _bInPopUpQueue, _bInterruptPopUp
  if _bInPopUpQueue then
    return not _bInterruptPopUp
  end
end

return PopUpManager

