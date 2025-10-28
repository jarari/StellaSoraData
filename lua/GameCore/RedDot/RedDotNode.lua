local RedDotNode = class("RedDotNode")

local RedDotType = AllEnum.RedDotType

---@diagnostic disable-next-line: duplicate-set-field
function RedDotNode:ctor(sKey, parent)
    self.bManualRefresh = nil      -- 是否手动调用刷新（仅对本节点起效，不影响其他节点）
    self.sNodeKey = sKey            -- 节点名
    self.parentNode = parent        -- 父节点
    self.tbChildNodeList = nil      -- 子节点列表 
    self.nRedDotCount = 0           -- 红点数量
    self.tbObjNode = nil            -- 红点gameObject
    self.tbTxtRedDotCount = nil     -- 红点数量显示txt
    self.nShowType = nil            -- 红点显示类型
end

--注册红点
function RedDotNode:RegisterNode(objGo, nType, bManualRefresh)
    if nil == objGo then
        traceback(string.format("注册红点失败！！！传入的gameObject为空.  nodeKey = %s", self.sNodeKey))
        return
    end
    --默认红点类型
    if nil == nType then
        nType = RedDotType.Single
    end
    self.nShowType = nType
    self.bManualRefresh = bManualRefresh
    if self.tbObjNode == nil then
        self.tbObjNode = {}
    end

    --红点obj列表
    if type(objGo) == "table" then
        for _, v in ipairs(objGo) do
            local nInstanceId = v.gameObject:GetInstanceID()
            self.tbObjNode[nInstanceId] = v.gameObject
        end
    else
        local nInstanceId = objGo.gameObject:GetInstanceID()
        self.tbObjNode[nInstanceId] = objGo.gameObject
    end

    self.tbTxtRedDotCount = {}
    for _, v in pairs(self.tbObjNode) do
        if v:IsNull() ~= true then
            local trObj = v.gameObject:GetComponent("Transform")
            local trNode = trObj:Find("---RedDot---")
            if nil == trNode then
                printError("红点UI结构不标准！！！请检查")
                return
            end

            if nType == RedDotType.Number then
                local trText = trNode:Find("txtRedDot")
                if nil ~= trText then
                    local nInstanceId = trText:GetInstanceID()
                    self.tbTxtRedDotCount[nInstanceId] = trText:GetComponent("TMP_Text")
                end
            end
        end
    end
    self:RefreshRedDotShow()
end

--注销红点
function RedDotNode:UnRegisterNode(objGo)
    if nil == objGo then
        self.tbObjNode = nil
        self.tbTxtRedDotCount = nil
    else
        if self.tbObjNode == nil then
            return
        end
        
        if type(objGo) == "table" then
            for _, v in ipairs(objGo) do
                local nInstanceId = v:GetInstanceID()
                self.tbObjNode[nInstanceId] = nil
            end
        else
            local nInstanceId = objGo:GetInstanceID()
            self.tbObjNode[nInstanceId] = nil
        end
    end
end

function RedDotNode:AddChildNode(sKey)
    if nil == self.tbChildNodeList then
        self.tbChildNodeList = {}
    end
    local node = RedDotNode.new(sKey, self)
    table.insert(self.tbChildNodeList, node)
    return node
end

function RedDotNode:GetChildNode(sKey)
    if nil ~= self.tbChildNodeList then
        for _, node in ipairs(self.tbChildNodeList) do
            if node:GetNodeKey() == sKey then
                return node
            end
        end
    end
end

--设置红点显示状态
--bDelayRefresh  延迟刷新界面显示状态，传true时需要自己手动在合适的时机刷新红点显示
function RedDotNode:SetValid(bValid)
    if self:GetValid() == bValid and (nil == self.tbChildNodeList or #self.tbChildNodeList <= 0) then
        return
    end
    if bValid then
        self.nRedDotCount = self.nRedDotCount + 1
    else
        self.nRedDotCount = self.nRedDotCount - 1
    end
    if not self.bManualRefresh then
        self:RefreshRedDotShow()
    end
    if nil ~= self.parentNode then
        self.parentNode:SetValid(bValid)
    end
end

--刷新红点数量
function RedDotNode:SetCount(nCount)
    if self:GetCount() == nCount and (nil == self.tbChildNodeList or #self.tbChildNodeList <= 0) then
        return
    end
    self.nRedDotCount = nCount
    self:RefreshRedDotShow()
    if nil ~= self.parentNode then
        self.parentNode:SetCount(nCount)
    end
end

--刷新红点显示
function RedDotNode:RefreshRedDotShow()
    if nil == self.tbObjNode or nil == next(self.tbObjNode) then
        return
    end
    for _, v in pairs(self.tbObjNode) do
        if v:IsNull() == true then
            traceback("疑似上一次注册的红点未注销！！！请检查 nodeKey = "..self.sNodeKey)
        else
            v.gameObject:SetActive(self:GetValid())
        end
    end

    if self.nShowType == RedDotType.Number then
        for _, v in pairs(self.tbTxtRedDotCount) do
            NovaAPI.SetTMPText(v, self:GetCount())
        end
    end
end

function RedDotNode:GetNodeKey()
    return self.sNodeKey
end

function RedDotNode:GetValid()
    return self.nRedDotCount > 0
end

function RedDotNode:GetCount()
    return self.nRedDotCount
end

function RedDotNode:CheckLeafNode()
    return nil == self.tbChildNodeList or #self.tbChildNodeList == 0
end

function RedDotNode:PrintRedDot(bParent, bLeaf)
    if self.sNodeKey == "Root" then
        return
    end
    local sObj = ""
    local nCount = 0
    if self.tbObjNode ~= nil then
        for nInsId, v in pairs(self.tbObjNode) do
            nCount = nCount + 1
            sObj = sObj .. string.format("%s | %s", nInsId, v.gameObject:GetInstanceID())
            sObj = sObj .. "\n"
        end

        local sLog = string.format("<color=red>[RedDot]</color> 节点key %s|红点state %s|绑定gameObject数量 %s\n", 
                self.sNodeKey, self.nRedDotCount, nCount)
        sLog = sLog .. sObj
        traceback(sLog)
    end

    if bParent then
        if nil ~= self.parentNode then
            self.parentNode:PrintRedDot(true)
        end
    elseif bLeaf then
        if nil ~= self.tbChildNodeList then
            for _, v in ipairs(self.tbChildNodeList) do
                v:PrintRedDot(nil, true)
            end
        end
    end
end

return RedDotNode