local RedDotManager = {}
local RedDotNode = require("GameCore.RedDot.RedDotNode")
local stringSplit = string.split
local RapidJson = require("rapidjson")
local mapKeyList = {}
local rootNode, trUIRoot = nil, nil
local DEBUG_OPEN = false
RedDotManager.Init = function()
  -- function num : 0_0 , upvalues : trUIRoot, _ENV, RedDotManager
  trUIRoot = ((GameObject.Find)("---- UI ----")).transform
  ;
  (EventManager.Add)("LuaEventName_UnRegisterRedDot", RedDotManager, RedDotManager.OnEvent_UnRegisterRedDot)
end

RedDotManager.RegisterNode = function(sKey, param, objGo, nType, bManualRefresh, bRebind)
  -- function num : 0_1 , upvalues : RedDotManager, _ENV, trUIRoot, RapidJson
  local bCheck, sNodeKey = (RedDotManager.GetNodeKey)(sKey, param)
  if not bCheck then
    return 
  end
  if objGo ~= nil then
    local tbParam = {}
    do
      if param == nil then
        tbParam.sParam = "empty"
      else
        if type(param) ~= "table" then
          tbParam.sParam = param
        else
          tbParam = param
        end
      end
      do
        local bindCS = function(obj)
    -- function num : 0_1_0 , upvalues : _ENV, trUIRoot, RapidJson, tbParam, sKey
    (NovaAPI.UnRegisterRedDotNode)(obj.gameObject)
    local trParent = (obj.transform).parent
    ;
    (obj.transform):SetParent(trUIRoot)
    ;
    (obj.gameObject):SetActive(true)
    local paramJson = (RapidJson.encode)(tbParam)
    ;
    (NovaAPI.AddRedDotNode)(obj.gameObject, sKey, paramJson)
    ;
    (obj.gameObject):SetActive(false)
    ;
    (obj.transform):SetParent(trParent)
  end

        if type(objGo) == "table" then
          for _,v in ipairs(objGo) do
            bindCS(v.gameObject)
          end
        else
          do
            bindCS(objGo.gameObject)
          end
        end
        local node = (RedDotManager.GetNode)(sNodeKey)
        if node ~= nil then
          if bRebind then
            node:UnRegisterNode()
          end
          node:RegisterNode(objGo, nType, bManualRefresh)
        end
      end
    end
  end
end

RedDotManager.UnRegisterNode = function(sKey, param, objGo)
  -- function num : 0_2 , upvalues : RedDotManager
  local bCheck, sNodeKey = (RedDotManager.GetNodeKey)(sKey, param)
  if not bCheck then
    return 
  end
  if (RedDotManager.CheckNodeExist)(sNodeKey) then
    local node = (RedDotManager.GetNode)(sNodeKey)
    if node ~= nil then
      node:UnRegisterNode(objGo)
    end
  end
end

RedDotManager.OnEvent_UnRegisterRedDot = function(_, sKey, paramJson, objGo)
  -- function num : 0_3 , upvalues : _ENV, RedDotManager
  local tbParam = (decodeJson(paramJson))
  local param = nil
  if tbParam.sParam == nil then
    param = tbParam
  else
    if tbParam.sParam == "empty" then
      param = nil
    else
      if tbParam.sParam ~= nil then
        param = tbParam.sParam
      end
    end
  end
  local bCheck, sNodeKey = (RedDotManager.GetNodeKey)(sKey, param)
  if not bCheck then
    return 
  end
  if (RedDotManager.CheckNodeExist)(sNodeKey) then
    local node = (RedDotManager.GetNode)(sNodeKey)
    if node ~= nil then
      node:UnRegisterNode(objGo)
    end
  end
end

RedDotManager.SetValid = function(sKey, param, bValid)
  -- function num : 0_4 , upvalues : RedDotManager
  local bCheck, sNodeKey = (RedDotManager.GetNodeKey)(sKey, param)
  if not bCheck then
    return 
  end
  local node = (RedDotManager.GetNode)(sNodeKey)
  if node ~= nil then
    if not node:CheckLeafNode() then
      return 
    end
    node:SetValid(bValid)
  end
end

RedDotManager.SetCount = function(sKey, param, nCount)
  -- function num : 0_5 , upvalues : RedDotManager
  local bCheck, sNodeKey = (RedDotManager.GetNodeKey)(sKey, param)
  if not bCheck then
    return 
  end
  local node = (RedDotManager.GetNode)(sNodeKey)
  if node ~= nil then
    if not node:CheckLeafNode() then
      return 
    end
    node:SetCount(nCount)
  end
end

RedDotManager.GetValid = function(sKey, param)
  -- function num : 0_6 , upvalues : RedDotManager
  local bCheck, sNodeKey = (RedDotManager.GetNodeKey)(sKey, param)
  if not bCheck then
    return 
  end
  local node = (RedDotManager.GetNode)(sNodeKey)
  if node ~= nil then
    return node:GetValid()
  end
  return false
end

RedDotManager.RefreshRedDotShow = function(sKey, param)
  -- function num : 0_7 , upvalues : RedDotManager
  local bCheck, sNodeKey = (RedDotManager.GetNodeKey)(sKey, param)
  if not bCheck then
    return 
  end
  if (RedDotManager.CheckNodeExist)(sNodeKey) then
    local node = (RedDotManager.GetNode)(sNodeKey)
    if node ~= nil then
      node:RefreshRedDotShow()
    end
  end
end

RedDotManager.PrintRedDot = function(sKey, param, bParent, bLeaf)
  -- function num : 0_8 , upvalues : DEBUG_OPEN, RedDotManager
  if not DEBUG_OPEN then
    return 
  end
  local bCheck, sNodeKey = (RedDotManager.GetNodeKey)(sKey, param)
  if not bCheck then
    return 
  end
  local node = (RedDotManager.GetNode)(sNodeKey)
  if node ~= nil then
    node:PrintRedDot(bParent, bLeaf)
  end
end

RedDotManager.GetNodeKey = function(sKey, param)
  -- function num : 0_9 , upvalues : _ENV, stringSplit
  local sNodeKey = ""
  local bCheck = true
  if sKey == nil then
    bCheck = false
    traceback((string.format)("红点注册传入参数错误，请检查！！!, key = %s, param = %s", sKey, param))
  else
    if param == nil then
      sNodeKey = sKey
    else
      if type(param) ~= "table" then
        sNodeKey = (string.gsub)(sKey, "<param>", param, 1)
      else
        sNodeKey = sKey
        for _,v in ipairs(param) do
          sNodeKey = (string.gsub)(sNodeKey, "<param>", v, 1)
        end
      end
    end
    do
      sNodeKey = (string.gsub)(sNodeKey, "<param>", "")
      if not stringSplit(sNodeKey, ".") then
        local tbSplit = {}
      end
      sNodeKey = ""
      local index = 1
      for _,v in ipairs(tbSplit) do
        if v ~= nil and v ~= "" then
          if index == 1 then
            sNodeKey = v
          else
            sNodeKey = sNodeKey .. "." .. v
          end
          index = index + 1
        end
      end
      do
        return bCheck, sNodeKey
      end
    end
  end
end

RedDotManager.GetNode = function(sNodeKey)
  -- function num : 0_10 , upvalues : rootNode, RedDotNode, _ENV, RedDotManager
  if rootNode == nil then
    rootNode = (RedDotNode.new)(RedDotDefine.Root)
  end
  local curNode = rootNode
  local tbKeyList = (RedDotManager.ParseKey)(sNodeKey)
  for _,key in ipairs(tbKeyList) do
    local node = curNode:GetChildNode(key)
    if node == nil then
      node = curNode:AddChildNode(key)
    end
    curNode = node
  end
  return curNode
end

RedDotManager.CheckNodeExist = function(sNodeKey)
  -- function num : 0_11 , upvalues : RedDotManager
  do return (RedDotManager.GetKeyList)(sNodeKey) ~= nil end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

RedDotManager.GetKeyList = function(sNodeKey)
  -- function num : 0_12 , upvalues : mapKeyList
  return mapKeyList[sNodeKey]
end

RedDotManager.ParseKey = function(sNodeKey)
  -- function num : 0_13 , upvalues : RedDotManager, stringSplit, mapKeyList
  local tbKeyList = (RedDotManager.GetKeyList)(sNodeKey)
  if tbKeyList == nil and not stringSplit(sNodeKey, ".") then
    tbKeyList = {}
  end
  mapKeyList[sNodeKey] = tbKeyList
  return tbKeyList
end

return RedDotManager

