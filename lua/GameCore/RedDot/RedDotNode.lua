local RedDotNode = class("RedDotNode")
local RedDotType = AllEnum.RedDotType
RedDotNode.ctor = function(self, sKey, parent)
  -- function num : 0_0
  self.bManualRefresh = nil
  self.sNodeKey = sKey
  self.parentNode = parent
  self.tbChildNodeList = nil
  self.nRedDotCount = 0
  self.tbObjNode = nil
  self.tbTxtRedDotCount = nil
  self.nShowType = nil
end

RedDotNode.RegisterNode = function(self, objGo, nType, bManualRefresh)
  -- function num : 0_1 , upvalues : _ENV, RedDotType
  if objGo == nil then
    traceback((string.format)("注册红点失败！！！传入的gameObject为空.  nodeKey = %s", self.sNodeKey))
    return 
  end
  if nType == nil then
    nType = RedDotType.Single
  end
  self.nShowType = nType
  self.bManualRefresh = bManualRefresh
  if self.tbObjNode == nil then
    self.tbObjNode = {}
  end
  if type(objGo) == "table" then
    for _,v in ipairs(objGo) do
      local nInstanceId = (v.gameObject):GetInstanceID()
      -- DECOMPILER ERROR at PC34: Confused about usage of register: R10 in 'UnsetPending'

      ;
      (self.tbObjNode)[nInstanceId] = v.gameObject
    end
  else
    do
      do
        local nInstanceId = (objGo.gameObject):GetInstanceID()
        -- DECOMPILER ERROR at PC43: Confused about usage of register: R5 in 'UnsetPending'

        ;
        (self.tbObjNode)[nInstanceId] = objGo.gameObject
        self.tbTxtRedDotCount = {}
        for _,v in pairs(self.tbObjNode) do
          if v:IsNull() ~= true then
            local trObj = (v.gameObject):GetComponent("Transform")
            local trNode = trObj:Find("---RedDot---")
            if trNode == nil then
              printError("红点UI结构不标准！！！请检查")
              return 
            end
            if nType == RedDotType.Number then
              local trText = trNode:Find("txtRedDot")
              if trText ~= nil then
                local nInstanceId = trText:GetInstanceID()
                -- DECOMPILER ERROR at PC81: Confused about usage of register: R13 in 'UnsetPending'

                ;
                (self.tbTxtRedDotCount)[nInstanceId] = trText:GetComponent("TMP_Text")
              end
            end
          end
        end
        self:RefreshRedDotShow()
      end
    end
  end
end

RedDotNode.UnRegisterNode = function(self, objGo)
  -- function num : 0_2 , upvalues : _ENV
  if objGo == nil then
    self.tbObjNode = nil
    self.tbTxtRedDotCount = nil
  else
    if self.tbObjNode == nil then
      return 
    end
    if type(objGo) == "table" then
      for _,v in ipairs(objGo) do
        local nInstanceId = v:GetInstanceID()
        -- DECOMPILER ERROR at PC21: Confused about usage of register: R8 in 'UnsetPending'

        ;
        (self.tbObjNode)[nInstanceId] = nil
      end
    else
      do
        local nInstanceId = objGo:GetInstanceID()
        -- DECOMPILER ERROR at PC28: Confused about usage of register: R3 in 'UnsetPending'

        ;
        (self.tbObjNode)[nInstanceId] = nil
      end
    end
  end
end

RedDotNode.AddChildNode = function(self, sKey)
  -- function num : 0_3 , upvalues : RedDotNode, _ENV
  if self.tbChildNodeList == nil then
    self.tbChildNodeList = {}
  end
  local node = (RedDotNode.new)(sKey, self)
  ;
  (table.insert)(self.tbChildNodeList, node)
  return node
end

RedDotNode.GetChildNode = function(self, sKey)
  -- function num : 0_4 , upvalues : _ENV
  if self.tbChildNodeList ~= nil then
    for _,node in ipairs(self.tbChildNodeList) do
      if node:GetNodeKey() == sKey then
        return node
      end
    end
  end
end

RedDotNode.SetValid = function(self, bValid)
  -- function num : 0_5
  if self:GetValid() == bValid and (self.tbChildNodeList == nil or #self.tbChildNodeList <= 0) then
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
  if self.parentNode ~= nil then
    (self.parentNode):SetValid(bValid)
  end
end

RedDotNode.SetCount = function(self, nCount)
  -- function num : 0_6
  if self:GetCount() == nCount and (self.tbChildNodeList == nil or #self.tbChildNodeList <= 0) then
    return 
  end
  self.nRedDotCount = nCount
  self:RefreshRedDotShow()
  if self.parentNode ~= nil then
    (self.parentNode):SetCount(nCount)
  end
end

RedDotNode.RefreshRedDotShow = function(self)
  -- function num : 0_7 , upvalues : _ENV, RedDotType
  if self.tbObjNode == nil or next(self.tbObjNode) == nil then
    return 
  end
  for _,v in pairs(self.tbObjNode) do
    if v:IsNull() == true then
      traceback("疑似上一次注册的红点未注销！！！请检查 nodeKey = " .. self.sNodeKey)
    else
      ;
      (v.gameObject):SetActive(self:GetValid())
    end
  end
  if self.nShowType == RedDotType.Number then
    for _,v in pairs(self.tbTxtRedDotCount) do
      (NovaAPI.SetTMPText)(v, self:GetCount())
    end
  end
end

RedDotNode.GetNodeKey = function(self)
  -- function num : 0_8
  return self.sNodeKey
end

RedDotNode.GetValid = function(self)
  -- function num : 0_9
  do return self.nRedDotCount > 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

RedDotNode.GetCount = function(self)
  -- function num : 0_10
  return self.nRedDotCount
end

RedDotNode.CheckLeafNode = function(self)
  -- function num : 0_11
  do return self.tbChildNodeList == nil or #self.tbChildNodeList == 0 end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

RedDotNode.PrintRedDot = function(self, bParent, bLeaf)
  -- function num : 0_12 , upvalues : _ENV
  if self.sNodeKey == "Root" then
    return 
  end
  local sObj = ""
  local nCount = 0
  if self.tbObjNode ~= nil then
    for nInsId,v in pairs(self.tbObjNode) do
      nCount = nCount + 1
      sObj = sObj .. (string.format)("%s | %s", nInsId, (v.gameObject):GetInstanceID())
      sObj = sObj .. "\n"
    end
    local sLog = (string.format)("<color=red>[RedDot]</color> 节点key %s|红点state %s|绑定gameObject数量 %s\n", self.sNodeKey, self.nRedDotCount, nCount)
    sLog = sLog .. sObj
    traceback(sLog)
  end
  do
    -- DECOMPILER ERROR at PC50: Unhandled construct in 'MakeBoolean' P1

    if bParent and self.parentNode ~= nil then
      (self.parentNode):PrintRedDot(true)
    end
    if bLeaf and self.tbChildNodeList ~= nil then
      for _,v in ipairs(self.tbChildNodeList) do
        v:PrintRedDot(nil, true)
      end
    end
  end
end

return RedDotNode

