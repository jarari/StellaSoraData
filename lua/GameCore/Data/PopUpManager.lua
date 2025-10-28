local PopUpManager = { }
local ClientManager = CS.ClientManager.Instance
local LocalData = require "GameCore.Data.LocalData"
local RapidJson = require "rapidjson"
local ModuleManager = require "GameCore.Module.ModuleManager"

local popUpPanelConfig = {}
local _tbPopUpQueue = {}   
local _tbPopUpCache = {}   -- 本次已展示过的弹窗列表(同类型界面只显示一次)
local _popUpCallback = nil
local _bInPopUpQueue = false
local _bInterruptPopUp = false
local _tbSpecifyPopUp = {}  -- 指定类型的弹窗列表
local _tempPopUpMapData = {} -- 临时记录当前的弹窗数据，防止跳转回主界面后无法继续弹窗逻辑
local _interruptPopUpIndex = 0

function PopUpManager.Init()
    local function foreachPopupSeq(mapData)
        local data = {
            nPanelId = mapData.PanelId,
            nSortId = mapData.SortId,
            bLocalSave = mapData.bLocalSave
        }
        popUpPanelConfig[mapData.Type] = data
    end
    ForEachTableLine(ConfigTable.Get("PopUpSequence"), foreachPopupSeq)
end

function PopUpManager.InitLoginQueue()
    local sTime = LocalData.GetPlayerLocalData("LoginPanelTime")
    local nTime = tonumber(sTime) or 0
    local nNextTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
    if nNextTime > nTime then
        _tbPopUpQueue = {}
        PopUpManager.SaveLocalData()
    else
        local sJson = LocalData.GetPlayerLocalData("LoginPanelQueue")
        local tb = decodeJson(sJson)
        if type(tb) == "table" then
            _tbPopUpQueue = tb
        end
    end
end

function PopUpManager.SaveLocalData()
    local nNextTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
    local tbLocalSave = {}
    for _, v in ipairs(_tbPopUpQueue) do
        local mapConfig = popUpPanelConfig[v.nType]
        if mapConfig and mapConfig.bLocalSave then
            table.insert(tbLocalSave, v)
        end
    end
    LocalData.SetPlayerLocalData("LoginPanelQueue", RapidJson.encode(tbLocalSave))
    LocalData.SetPlayerLocalData("LoginPanelTime", tostring(nNextTime))
end

function PopUpManager.StartShowPopUp(callback)
    _popUpCallback = callback
    _bInPopUpQueue = true
    PopUpManager.PopUpDeQueue()
end

function PopUpManager.PopUpEnQueue(nType, mapData)
    local bAdded = false
    for nIndex, mapPopUp in ipairs(_tbPopUpQueue) do
        if mapPopUp.nType == nType then
            _tbPopUpQueue[nIndex].mapData = mapData
            bAdded = true
            break
        end
    end
    bAdded = bAdded or _tbPopUpCache[nType]
    if not bAdded then
        table.insert(_tbPopUpQueue, {
            nType = nType,
            mapData = mapData
        })
    end

    table.sort(_tbPopUpQueue, function (a, b)
        local nSortA = popUpPanelConfig[a.nType].nSortId or 999
        local nSortB = popUpPanelConfig[b.nType].nSortId or 999
        return nSortA < nSortB
    end)

    if nType == GameEnum.PopUpSeqType.MonthlyCard and PlayerData.Mall:CheckOrderProcess() then
        return -- 月卡订单处理中时先不能弹
    end
    EventManager.Hit("MainViewCheckOpenPanel")
end

function PopUpManager.PopUpDeQueue()
    local function exitPopUpQueue()
        if _popUpCallback ~= nil then
            _popUpCallback() 
        end
        --退出弹窗队列时清空缓存列表
        _tbPopUpCache = {}
        _bInPopUpQueue = false
        _bInterruptPopUp = false
        _interruptPopUpIndex = 0
        EventManager.Hit("Event_MainViewPopUpEnd")
    end
    if #_tbPopUpQueue == 0 then
        if not _bInterruptPopUp and _interruptPopUpIndex == 0 then
            exitPopUpQueue()
            return
        end
    end
    if not _bInterruptPopUp and _interruptPopUpIndex == 0 then
        _tempPopUpMapData = table.remove(_tbPopUpQueue, 1)
    else
        local mapData = _tempPopUpMapData.mapData
        for i = 1, _interruptPopUpIndex do
            table.remove(mapData, 1)
        end
        if #mapData == 0 then
            exitPopUpQueue()
            return
        else
            _tempPopUpMapData.mapData = mapData
        end
    end
    _bInterruptPopUp = false
    _interruptPopUpIndex = 0
    local mapNext = _tempPopUpMapData
    _tbPopUpCache[mapNext.nType] = true
    local function callback(funcCall)
        PopUpManager.PopUpDeQueue()
        if nil ~= funcCall then
            funcCall()
        end
    end
    local mapConfig = popUpPanelConfig[mapNext.nType]
    if mapConfig ~= nil then
        if mapNext.nType == GameEnum.PopUpSeqType.MessageBox then
            local msg = {
                nType = AllEnum.MessageBox.Alert,
                sContent = mapNext.mapData,
                callbackConfirm = callback,
            }
            EventManager.Hit(EventId.OpenMessageBox, msg)
        else
            EventManager.Hit(EventId.OpenPanel, mapConfig.nPanelId, mapNext.mapData, callback)
        end
        if mapConfig.bLocalSave then
            PopUpManager.SaveLocalData()
        end
    end
end

--跳转时暂时停止弹窗逻辑(临时处理)
function PopUpManager.InterruptPopUp(index)
    _bInterruptPopUp = true
    _interruptPopUpIndex = index
end

function PopUpManager.OpenPopUpPanelByType(nType, callback)
    local nRemoveIdx = 0
    for nIdx, data in ipairs(_tbPopUpQueue) do
        if data.nType == nType then
            nRemoveIdx = nIdx
            break
        end
    end
    if nRemoveIdx ~= 0 then
        local mapNext = table.remove(_tbPopUpQueue, nRemoveIdx)
        local mapConfig = popUpPanelConfig[mapNext.nType]
        if mapConfig ~= nil then
            EventManager.Hit(EventId.OpenPanel, mapConfig.nPanelId, mapNext.mapData, callback)
            if mapConfig.bLocalSave then
                PopUpManager.SaveLocalData()
            end
        end
    else
        if callback ~= nil then
            callback()
        end
    end
end

--弹指定类型的弹窗
function PopUpManager.OpenPopUpPanel(tbType, callback)
    local bInPopUp = PopUpManager.CheckInPopUpQueue()
    if bInPopUp then
        return
    end
    _tbSpecifyPopUp = tbType
    local function popUp()
        if #_tbSpecifyPopUp == 0 then
            if callback ~= nil then
                callback()
            end
            return
        end
        local nType = table.remove(_tbSpecifyPopUp, 1)
        PopUpManager.OpenPopUpPanelByType(nType, popUp)
    end
    popUp()
end

function PopUpManager.CheckInPopUpQueue()
    return _bInPopUpQueue and not _bInterruptPopUp
end

return PopUpManager