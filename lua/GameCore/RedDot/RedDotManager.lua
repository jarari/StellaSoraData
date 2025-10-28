local RedDotManager = {}
local RedDotNode = require "GameCore.RedDot.RedDotNode"

local stringSplit = string.split
local RapidJson = require "rapidjson"

local mapKeyList = {}
local rootNode = nil
local trUIRoot = nil
local DEBUG_OPEN = false
------------------------------ public function -----------------------

function RedDotManager.Init()
    trUIRoot = GameObject.Find("---- UI ----").transform
    EventManager.Add("LuaEventName_UnRegisterRedDot", RedDotManager, RedDotManager.OnEvent_UnRegisterRedDot)
end

--注册红点 (param:动态参数, bManualRefresh:是否手动调用刷新显示, bRebind:是否是重新绑定，传true会强制清空node下所有的红点绑定)
function RedDotManager.RegisterNode(sKey, param, objGo, nType, bManualRefresh, bRebind)
    local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
    if not bCheck then
        return
    end
    
    if objGo ~= nil then
        local tbParam = {}
        if param == nil then
            tbParam.sParam = "empty"
        elseif type(param) ~= "table" then
            tbParam.sParam = param
        else
            tbParam = param
        end

        --红点obj列表
        local function bindCS(obj)
            NovaAPI.UnRegisterRedDotNode(obj.gameObject)
            -- 确保RedDotNode一定会调用OnDestroy，这里先把红点移到根节点SetActive true 再移回来
            local trParent = obj.transform.parent
            obj.transform:SetParent(trUIRoot)
            obj.gameObject:SetActive(true)
            local paramJson = RapidJson.encode(tbParam)
            NovaAPI.AddRedDotNode(obj.gameObject, sKey, paramJson)
            obj.gameObject:SetActive(false)
            obj.transform:SetParent(trParent)
        end
        if type(objGo) == "table" then
            for _, v in ipairs(objGo) do
                bindCS(v.gameObject)
            end
        else
            bindCS(objGo.gameObject)
        end
    end
    
    local node = RedDotManager.GetNode(sNodeKey)
    if nil ~= node then
        if bRebind then
            node:UnRegisterNode()
        end
        node:RegisterNode(objGo, nType, bManualRefresh)
    end
end

--注销
function RedDotManager.UnRegisterNode(sKey, param, objGo)
    local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
    if not bCheck then
        return
    end
    if RedDotManager.CheckNodeExist(sNodeKey) then
        local node = RedDotManager.GetNode(sNodeKey)
        if nil ~= node then
            node:UnRegisterNode(objGo)
        end
    end
end

function RedDotManager.OnEvent_UnRegisterRedDot(_, sKey, paramJson, objGo)
    local tbParam = decodeJson(paramJson)
    local param
    if tbParam["sParam"] == nil then
        param = tbParam
    elseif tbParam["sParam"] == "empty" then
        param = nil
    elseif tbParam["sParam"] ~= nil  then
        param = tbParam["sParam"]
    end

    local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
    if not bCheck then
        return
    end
    if RedDotManager.CheckNodeExist(sNodeKey) then
        local node = RedDotManager.GetNode(sNodeKey)
        if nil ~= node then
            node:UnRegisterNode(objGo)
        end
    end
    
    --RedDotManager.UnRegisterNode(sKey, param, objGo)
end

--设置红点显示状态(只能设置叶子节点状态)
function RedDotManager.SetValid(sKey, param, bValid)
    local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
    if not bCheck then
        return
    end
    local node = RedDotManager.GetNode(sNodeKey)
    if nil ~= node then
        if not node:CheckLeafNode() then
            return
        end
        node:SetValid(bValid)
    end
end

--刷新红点数量
function RedDotManager.SetCount(sKey, param, nCount)
    local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
    if not bCheck then
        return
    end
    local node = RedDotManager.GetNode(sNodeKey)
    if nil ~= node then
        if not node:CheckLeafNode() then
            return
        end
        node:SetCount(nCount)
    end
end

function RedDotManager.GetValid(sKey, param)
    local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
    if not bCheck then
        return
    end
    local node = RedDotManager.GetNode(sNodeKey)
    if nil ~= node then
        return node:GetValid()
    end
    
    return false
end

function RedDotManager.RefreshRedDotShow(sKey, param)
    local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
    if not bCheck then
        return
    end
    if RedDotManager.CheckNodeExist(sNodeKey) then
        local node = RedDotManager.GetNode(sNodeKey)
        if nil ~= node then
            node:RefreshRedDotShow()
        end
    end
end

function RedDotManager.PrintRedDot(sKey, param, bParent, bLeaf)
    if not DEBUG_OPEN then
        return
    end
    
    local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
    if not bCheck then
        return
    end
    local node = RedDotManager.GetNode(sNodeKey)
    if nil ~= node then
        node:PrintRedDot(bParent, bLeaf)
    end
end
------------------------------ private function -----------------------

--检查param合理性
function RedDotManager.GetNodeKey(sKey, param)
    local sNodeKey = ""
    local bCheck = true
    if nil == sKey then
        bCheck = false
        traceback(string.format("红点注册传入参数错误，请检查！！!, key = %s, param = %s", sKey, param))
    else
        if nil == param then
            sNodeKey = sKey
        else
            if type(param) ~= "table" then
                sNodeKey = string.gsub(sKey, "<param>", param, 1)
            else
                sNodeKey = sKey
                for _, v in ipairs(param) do
                    sNodeKey = string.gsub(sNodeKey, "<param>", v, 1)
                end
            end
        end

        --替换剩余无用的param为空
        sNodeKey = string.gsub(sNodeKey, "<param>", "")
        local tbSplit = stringSplit(sNodeKey, ".") or {}
        sNodeKey = ""
        local index = 1
        for _, v in ipairs(tbSplit) do
            if nil ~= v and "" ~= v then
                if index == 1 then
                    sNodeKey = v
                else
                    sNodeKey = sNodeKey .. ".".. v
                end
                index = index + 1
            end
        end
    end
    return bCheck, sNodeKey
end

function RedDotManager.GetNode(sNodeKey)
    if nil == rootNode then
        rootNode = RedDotNode.new(RedDotDefine.Root)
    end
    
    local curNode = rootNode
    local tbKeyList = RedDotManager.ParseKey(sNodeKey)
    for _, key in ipairs(tbKeyList) do
        local node = curNode:GetChildNode(key)
        if nil == node then
            node = curNode:AddChildNode(key)
        end
        curNode = node
    end
    return curNode
end

function RedDotManager.CheckNodeExist(sNodeKey)
    return nil ~= RedDotManager.GetKeyList(sNodeKey)
end

function RedDotManager.GetKeyList(sNodeKey)
    return mapKeyList[sNodeKey]
end

function RedDotManager.ParseKey(sNodeKey)
    local tbKeyList = RedDotManager.GetKeyList(sNodeKey)
    if nil == tbKeyList then
        tbKeyList = stringSplit(sNodeKey, ".") or {}
    end

    mapKeyList[sNodeKey] = tbKeyList
    return tbKeyList
end

return RedDotManager