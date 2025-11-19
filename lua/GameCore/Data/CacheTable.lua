local cacheTable = {}
local GetCache = function(name)
  -- function num : 0_0 , upvalues : _ENV, cacheTable
  if name == nil then
    traceback("获取缓存数据时, name 参数不能为空！！！")
    return 
  end
  if cacheTable[name] == nil then
    cacheTable[name] = {}
  end
  return cacheTable[name]
end

local SetCache = function(name, tb)
  -- function num : 0_1 , upvalues : _ENV, cacheTable
  if name == nil then
    traceback("写入缓存数据时, name 参数不能为空！！！")
    return 
  end
  cacheTable[name] = tb
end

local GetCacheData = function(name, key)
  -- function num : 0_2 , upvalues : _ENV, GetCache
  if key == nil then
    traceback("获取缓存数据时, key 参数不能为空！！！")
    return 
  end
  local tb = GetCache(name)
  if tb == nil then
    return 
  end
  return tb[key]
end

local SetCacheData = function(name, key, data)
  -- function num : 0_3 , upvalues : _ENV, GetCache
  if name == nil then
    traceback("写入缓存数据时, name 参数不能为空！！！")
    return 
  end
  if key == nil then
    traceback("写入缓存数据时, key 参数不能为空！！！")
    return 
  end
  local tb = GetCache(name)
  tb[key] = data
end

local SetCacheField = function(name, key, field, data)
  -- function num : 0_4 , upvalues : _ENV, GetCache
  if name == nil then
    traceback("写入缓存数据时, name 参数不能为空！！！")
    return 
  end
  if key == nil then
    traceback("写入缓存数据时, key 参数不能为空！！！")
    return 
  end
  if field == nil then
    traceback("写入缓存数据时, field 参数不能为空！！！")
    return 
  end
  local tb = GetCache(name)
  if tb == nil then
    return 
  end
  if tb[key] == nil then
    tb[key] = {}
  end
  -- DECOMPILER ERROR at PC30: Confused about usage of register: R5 in 'UnsetPending'

  ;
  (tb[key])[field] = data
end

local InsertCacheData = function(name, key, data)
  -- function num : 0_5 , upvalues : _ENV, GetCache
  if name == nil then
    traceback("写入缓存数据时, name 参数不能为空！！！")
    return 
  end
  if key == nil then
    traceback("写入缓存数据时, key 参数不能为空！！！")
    return 
  end
  local tb = GetCache(name)
  if tb == nil then
    return 
  end
  if tb[key] == nil then
    tb[key] = {}
  end
  ;
  (table.insert)(tb[key], data)
end

-- DECOMPILER ERROR at PC15: Confused about usage of register: R7 in 'UnsetPending'

_G.CacheTable = {Get = GetCache, Set = SetCache, GetData = GetCacheData, SetData = SetCacheData, SetField = SetCacheField, InsertData = InsertCacheData}

