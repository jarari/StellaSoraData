local Event = require "GameCore.Event.Event"
local EntityEvent = require "GameCore.Event.EntityEvent"
local TimerManager = nil
local TimerScaleType = require "GameCore.Timer.TimerScaleType"
local TimerResetType = require "GameCore.Timer.TimerResetType"

local EventManager = {}
local mapEvent = nil
local mapTempAdd = nil
local mapTempRemove = nil
local mapOnHitEventId = nil
local timerCheckReset = nil

local function timerCallback()
    local sEvent = ""
    for nId, _ in pairs(mapOnHitEventId or {}) do
        sEvent = sEvent .. tostring(nId) .. ", "
    end
    if sEvent ~= "" then
        printLog("EventManager 检查，没有复位事件：" .. sEvent)
    end
end

local function CheckReset()
    if TimerManager == nil then
        TimerManager = require "GameCore.Timer.TimerManager"
    end
    if timerCheckReset == nil then
        timerCheckReset = TimerManager.Add(0, 10, EventManager, timerCallback, true, false, TimerScaleType.RealTime)
    else
        timerCheckReset:Reset(TimerResetType.ResetElapsed)
    end
end

local function Pairlist(...)
    local tbParam = {}
    for i = 1, select("#", ...) do
        local param = select(i, ...)
        table.insert(tbParam, param)
    end
    return tbParam
end

local function ProcAdd(nEventId)
    if mapEvent == nil or mapTempAdd == nil then
        return
    end
    local tbEventAdd = mapTempAdd[nEventId]
    if tbEventAdd == nil then
        return
    end
    if mapEvent[nEventId] == nil then
        mapTempAdd[nEventId] = nil
        return
    end
    local tbEventExist = mapEvent[nEventId]
    for iAdd, eventAdd in ipairs(tbEventAdd) do
        local bCanAdd = true
        for iExist, eventExist in ipairs(tbEventExist) do
            if eventExist._listener == eventAdd._listener and eventExist._callback == eventAdd._callback then
                bCanAdd = false
                break -- 同事件，同监听者，同回调，不能重复添加。
            end
        end
        if bCanAdd == true then
            table.insert(tbEventExist, eventAdd)
        end
    end
    mapTempAdd[nEventId] = nil
end

local function ProcRemove(nEventId)
    if mapEvent == nil or mapTempRemove == nil then
        return
    end
    local tbEventRemove = mapTempRemove[nEventId]
    if tbEventRemove == nil then
        return
    end
    if mapEvent[nEventId] == nil then
        mapTempRemove[nEventId] = nil
        return
    end
    local tbEventExist = mapEvent[nEventId]
    for iRemove, eventRemove in ipairs(tbEventRemove) do
        local nIndexExist = nil
        for iExist, eventExist in ipairs(tbEventExist) do
            if eventExist._listener == eventRemove._listener and eventExist._callback == eventRemove._callback then
                nIndexExist = iExist
                break
            end
        end
        if nIndexExist ~= nil then
            table.remove(tbEventExist, nIndexExist)
        end
    end
    mapTempRemove[nEventId] = nil
end

function EventManager.Init()
    mapEvent = {}
    mapTempAdd = {}
    mapTempRemove = {}
    mapOnHitEventId = {}
    EventManager.InitEntityEvent()
end

function EventManager.Add(nEventId, listener, callback)
    if mapEvent == nil or mapOnHitEventId == nil or mapTempAdd == nil then
        return
    end
    if listener == nil or callback == nil then
        return
    end
    if mapOnHitEventId[nEventId] == nil then -- 当前该事件未处于触发中，可以进行Add操作。
        if mapEvent[nEventId] == nil then
            mapEvent[nEventId] = {}
        end
        local tbEvent = mapEvent[nEventId]
        for i, event in ipairs(tbEvent) do
            if event._listener == listener and event._callback == callback then
                return -- 同事件，同监听者，同回调，不能重复添加。
            end
        end
        table.insert(tbEvent, Event.new(listener, callback))
    else -- 当前该事件处于触发中，加入临时列表中，待该事件触发完成后再处理Add操作。
        if mapTempAdd[nEventId] == nil then
            mapTempAdd[nEventId] = {}
        end
        local tbEventAdd = mapTempAdd[nEventId]
        for i, eventAdd in ipairs(tbEventAdd) do
            if eventAdd._listener == listener and eventAdd._callback == callback then
                return -- 同事件，同监听者，同回调，不能重复添加。
            end
        end
        table.insert(tbEventAdd, Event.new(listener, callback))
    end
end

function EventManager.Remove(nEventId, listener, callback)
    if mapEvent == nil or mapOnHitEventId == nil or mapTempRemove == nil then
        return
    end
    if listener == nil or callback == nil then
        return
    end
    if mapOnHitEventId[nEventId] == nil then -- 当前该事件未处于触发中，可以进行Remove操作。
        local tbEvent = mapEvent[nEventId]
        if tbEvent == nil then
            return
        end
        local nIndex = nil
        for i, event in ipairs(tbEvent) do
            if event._listener == listener and event._callback == callback then
                nIndex = i
                break
            end
        end
        if nIndex ~= nil then
            table.remove(tbEvent, nIndex)
        end
    else -- 当前该事件处于触发中，加入临时列表中，待该事件触发完成后再处理Remove操作。
        if mapTempRemove[nEventId] == nil then
            mapTempRemove[nEventId] = {}
        end
        local tbEventRemove = mapTempRemove[nEventId]
        for iRemove, eventRemove in ipairs(tbEventRemove) do
            if eventRemove._listener == listener and eventRemove._callback == callback then
                return -- 同事件，同监听者，同回调，已在移除临时列表中。
            end
        end
        table.insert(tbEventRemove, Event.new(listener, callback))
    end
end

function EventManager.RemoveAll(nEventId) -- 慎用！！
    mapEvent[nEventId] = nil
    mapTempAdd[nEventId] = nil
    mapTempRemove[nEventId] = nil
end

function EventManager.Hit(nEventId, ...)
    if mapEvent == nil or mapOnHitEventId == nil then
        return
    end
    CheckReset()
    local tbEvent = mapEvent[nEventId]
    if tbEvent ~= nil and mapOnHitEventId[nEventId] == nil then -- 在某事件的回调中，不能再次触发同事件。
        mapOnHitEventId[nEventId] = true
        --local tbParam = Pairlist(...)
        for i, event in ipairs(tbEvent) do
            if event ~= nil and event._listener ~= nil and event._callback ~= nil then
                if AVG_EDITOR == true then
                    local bIgnore = false
                    if event._listener.GetPanelId ~= nil then
                        if AVG_EDITOR_PLAYING == true and event._listener:GetPanelId() == PanelId.AvgEditor then
                            bIgnore = true
                        end
                    end
                    if bIgnore ~= true then
                        event._callback(event._listener, ...)
                    end
                else
                    event._callback(event._listener, ...)
                end
            end
        end
        mapOnHitEventId[nEventId] = nil
        -- 在某事件回调中Add或Remove同事件时，会在该事件回调全部处理完后，再执行Add或Remove。
        ProcAdd(nEventId)
        ProcRemove(nEventId)
    end
end


-- entity event
local mapEntityEvent = nil
local mapTempEntityEventAdd = nil
local mapTempEntityEventRemove = nil
local mapOnHitEntityEventId = nil

local function ProcAddEntityEvent(nEventId)
    if mapEntityEvent == nil or mapTempEntityEventAdd == nil then
        return
    end
    local _mapExist = mapEntityEvent[nEventId]
    local _mapAdd = mapTempEntityEventAdd[nEventId]
    if _mapAdd == nil then
        return
    end
    if _mapExist == nil then
        mapTempEntityEventAdd[nEventId] = nil
        return
    end
    for nEntityId, tbEntityEventAdd in pairs(_mapAdd) do
        local tbEntityEventExist = _mapExist[nEntityId]
        if tbEntityEventExist == nil then
            _mapExist[nEntityId] = {}
            tbEntityEventExist = _mapExist[nEntityId]
        end
        for i, entityEventAdd in ipairs(tbEntityEventAdd) do
            local bCanAdd = true
            for ii, entityEventExist in ipairs(tbEntityEventExist) do
                if entityEventExist._listener == entityEventAdd._listener and entityEventExist._callback == entityEventAdd._callback then
                    bCanAdd = false
                    break -- 同事件，同监听者，同回调，不能重复添加。
                end
            end
            if bCanAdd == true then
                table.insert(tbEntityEventExist, entityEventAdd)
            end
        end
    end
    mapTempEntityEventAdd[nEventId] = nil
end

local function ProcRemoveEntityEvent(nEventId)
    if mapEntityEvent == nil or mapTempEntityEventRemove == nil then
        return
    end
    local _mapExist = mapEntityEvent[nEventId]
    local _mapRemove = mapTempEntityEventRemove[nEventId]
    if _mapRemove == nil then
        return
    end
    if _mapExist == nil then
        mapTempEntityEventRemove[nEventId] = nil
        return
    end
    for nEntityId, tbEntityEventRemove in pairs(_mapRemove) do
        local tbEntityEventExist = _mapExist[nEntityId]
        if tbEntityEventExist ~= nil then
            for i, entityEventRemove in ipairs(tbEntityEventRemove) do
                local nIndexExist = nil
                for ii, entityEventExist in ipairs(tbEntityEventExist) do
                    if entityEventExist._listener == entityEventRemove._listener and entityEventExist._callback == entityEventRemove._callback then
                        nIndexExist = ii
                        break
                    end
                end
                if nIndexExist ~= nil then
                    table.remove(tbEntityEventExist, nIndexExist)
                end
            end
        end
    end
    mapTempEntityEventRemove[nEventId] = nil
end

function EventManager.InitEntityEvent()
    mapEntityEvent = {}
    mapTempEntityEventAdd = {}
    mapTempEntityEventRemove = {}
    mapOnHitEntityEventId = {}
end

function EventManager.AddEntityEvent(nEventId, nEntityId, listener, callback)
    if mapEntityEvent == nil or mapOnHitEntityEventId == nil or mapTempEntityEventAdd == nil then
        return
    end
    if nEntityId == nil or listener == nil or callback == nil then
        return
    end
    if mapOnHitEntityEventId[nEventId] == nil then -- 当前该事件未处于触发中，可以进行Add操作。
        if mapEntityEvent[nEventId] == nil then
            mapEntityEvent[nEventId] = {}
        end
        local _map = mapEntityEvent[nEventId]
        if _map[nEntityId] == nil then
            mapEntityEvent[nEventId][nEntityId] = {}
        end
        local tbEntityEvent = _map[nEntityId] -- main key: event id, sub key: entity id, value: entity event table
        for i, entityEvent in ipairs(tbEntityEvent) do
            if entityEvent._listener == listener and entityEvent._callback == callback then
                return -- 同事件，同 entity id，同监听者，同回调，不能重复添加。
            end
        end
        table.insert(tbEntityEvent, EntityEvent.new(listener, nEntityId, callback))
    else -- 当前该事件处于触发中，加入临时列表中，待该事件触发完成后再处理Add操作。
        if mapTempEntityEventAdd[nEventId] == nil then
            mapTempEntityEventAdd[nEventId] = {}
        end
        local _map = mapTempEntityEventAdd[nEventId]
        if _map[nEntityId] == nil then
            mapTempEntityEventAdd[nEventId][nEntityId] = {}
        end
        local tbEntityEventAdd = _map[nEntityId]
        for i, entityEventAdd in ipairs(tbEntityEventAdd) do
            if entityEventAdd._listener == listener and entityEventAdd._callback == callback then
                return -- 同事件，同 entity id，同监听者，同回调，不能重复添加。
            end
        end
        table.insert(tbEntityEventAdd, EntityEvent.new(listener, nEntityId, callback))
    end
end

function EventManager.RemoveEntityEvent(nEventId, nEntityId, listener, callback)
    if mapEntityEvent == nil or mapOnHitEntityEventId == nil or mapTempEntityEventRemove == nil then
        return
    end
    if nEntityId == nil or listener == nil or callback == nil then
        return
    end
    if mapOnHitEntityEventId[nEventId] == nil then -- 当前该事件未处于触发中，可以进行Remove操作。
        local _map = mapEntityEvent[nEventId]
        if _map == nil then
            return
        end
        local tbEntityEvent = _map[nEntityId]
        if tbEntityEvent == nil then
            return
        end
        local nIndex = nil
        for i, entityEvent in ipairs(tbEntityEvent) do
            if entityEvent._listener == listener and entityEvent._callback == callback then
                nIndex = i
                break
            end
        end
        if nIndex ~= nil then
            table.remove(tbEntityEvent, nIndex)
        end
    else -- 当前该事件处于触发中，加入临时列表中，待该事件触发完成后再处理Remove操作。
        if mapTempEntityEventRemove[nEventId] == nil then
            mapTempEntityEventRemove[nEventId] = {}
        end
        local _map = mapTempEntityEventRemove[nEventId]
        if _map[nEntityId] == nil then
            mapTempEntityEventRemove[nEventId][nEntityId] = {}
        end
        local tbEntityEventRemove = _map[nEntityId]
        for i, entityEventRemove in ipairs(tbEntityEventRemove) do
            if entityEventRemove._listener == listener and entityEventRemove._callback == callback then
                return -- 同事件，同 entity id，同监听者，同回调，已在移除临时列表中。
            end
        end
        table.insert(tbEntityEventRemove, EntityEvent.new(listener, nEntityId, callback))
    end
end

function EventManager.HitEntityEvent(nEventId, nEntityId, ...)
    if mapEntityEvent == nil or mapOnHitEntityEventId == nil then
        return
    end
    local _map = mapEntityEvent[nEventId]
    if _map ~= nil and mapOnHitEntityEventId[nEventId] == nil then -- 在某事件的回调中，不能再次触发同事件。
        local tbEntityEvent = _map[nEntityId]
        if tbEntityEvent ~= nil then
            mapOnHitEntityEventId[nEventId] = true
            --local tbParam = Pairlist(...)
            for i, entityEvent in ipairs(tbEntityEvent) do
                if entityEvent ~= nil and entityEvent._listener ~= nil and entityEvent._callback ~= nil then
                    --entityEvent._callback(entityEvent._listener, table.unpack(tbParam))
                    entityEvent._callback(entityEvent._listener,...)
                end
            end
            mapOnHitEntityEventId[nEventId] = nil
            -- 在某事件回调中Add或Remove同事件时，会在该事件回调全部处理完后，再执行Add或Remove。
            ProcAddEntityEvent(nEventId)
            ProcRemoveEntityEvent(nEventId)
        end
    end
end

return EventManager
