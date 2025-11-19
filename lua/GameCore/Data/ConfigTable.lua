local warn_color_tag = "<color=#FFFF00>"
local error_color_tag = "<color=#FF0000>"
local end_color_tag = "</color>"
local table_tag = "<color=#00FF00><b>☀️策划数据表☀️</b></color>"
local cache = {}
local ClearCache = function()
  -- function num : 0_0 , upvalues : cache
  cache = {}
end

local ClearTableCache = function(name)
  -- function num : 0_1 , upvalues : _ENV, cache
  if name == nil then
    traceback("获取策划数据表数据时, name 参数不能为空！！！")
    return 
  end
  cache[name] = {}
end

local GetTable = function(name, post_warn)
  -- function num : 0_2 , upvalues : _ENV, table_tag, warn_color_tag, end_color_tag, error_color_tag, cache
  if name == nil then
    traceback("获取策划数据表数据时, name 参数不能为空！！！")
    return 
  end
  local tb = (_G.DataTable)[name]
  if tb == nil then
    if post_warn == true then
      printWarn(table_tag .. " [" .. warn_color_tag .. name .. end_color_tag .. "] 不存在！！！")
    else
      traceback(table_tag .. " [" .. error_color_tag .. name .. end_color_tag .. "] 不存在！！！")
    end
    return 
  end
  if cache[name] == nil then
    cache[name] = {}
  end
  return tb
end

local GetTableData = function(name, key, post_warn)
  -- function num : 0_3 , upvalues : _ENV, GetTable, cache, table_tag, warn_color_tag, end_color_tag, error_color_tag
  if key == nil then
    traceback("获取策划数据表数据时, key 参数不能为空！！！")
    return 
  end
  local tb = GetTable(name, post_warn)
  if tb == nil then
    return 
  end
  local cacheTb = cache[name]
  local line = cacheTb[key]
  if line ~= nil then
    return line
  end
  line = tb[key]
  if line == nil then
    if post_warn == true then
      printWarn(table_tag .. " [" .. warn_color_tag .. name .. end_color_tag .. "] 中没找到 Id = [" .. warn_color_tag .. key .. end_color_tag .. "] 的数据行！！！")
    else
      traceback(table_tag .. " [" .. error_color_tag .. name .. end_color_tag .. "] 中没找到 Id = [" .. error_color_tag .. key .. end_color_tag .. "] 的数据行！！！")
    end
    return 
  end
  cacheTb[key] = line
  return line
end

local GetTableField = function(name, key, field, post_warn)
  -- function num : 0_4 , upvalues : GetTableData, _ENV, table_tag, warn_color_tag, end_color_tag, error_color_tag
  local line = GetTableData(name, key, post_warn)
  if line == nil then
    return 
  end
  if field == nil then
    traceback("获取策划数据表数据时, field 参数不能为空！！！")
    return 
  end
  local field_obj = line[field]
  if field_obj == nil then
    if post_warn == true then
      printWarn(table_tag .. " [" .. warn_color_tag .. name .. end_color_tag .. "] 中 Id = [" .. warn_color_tag .. key .. end_color_tag .. "] 的数据行中没找到字段 [" .. warn_color_tag .. field .. end_color_tag .. "] ！！！")
    else
      traceback(table_tag .. " [" .. error_color_tag .. name .. end_color_tag .. "] 中 Id = [" .. error_color_tag .. key .. end_color_tag .. "] 的数据行中没找到字段 [" .. error_color_tag .. field .. end_color_tag .. "] ！！！")
    end
  end
  return field_obj
end

local GetUITextData = function(key, post_warn)
  -- function num : 0_5 , upvalues : GetTableField
  return GetTableField("UIText", key, "Text", post_warn) or ""
end

local configCache = {}
local GetTableConfigData = function(key, post_warn)
  -- function num : 0_6 , upvalues : _ENV, configCache, GetTableField
  if key == nil then
    traceback("获取策划数据表数据时, key 参数不能为空！！！")
    return 
  end
  local data = configCache[key]
  if data ~= nil then
    return data
  end
  data = GetTableField("Config", key, "Value", post_warn)
  if data == nil then
    return 
  end
  configCache[key] = data
  return data
end

local GetTableConfigNumber = function(key, post_warn)
  -- function num : 0_7 , upvalues : _ENV, configCache, GetTableField, table_tag, warn_color_tag, end_color_tag, error_color_tag
  if key == nil then
    traceback("获取策划数据表数据时, key 参数不能为空！！！")
    return 
  end
  local data = configCache[key]
  if data ~= nil then
    return data
  end
  data = GetTableField("Config", key, "Value", post_warn)
  if data == nil then
    return 
  end
  local num = tonumber(data)
  if num == nil then
    if post_warn == true then
      printWarn(table_tag .. " [" .. warn_color_tag .. "Config" .. end_color_tag .. "] 中 Id = [" .. warn_color_tag .. key .. end_color_tag .. "] 的数据行中的字段 [" .. warn_color_tag .. "Value" .. end_color_tag .. "] 不是数字！！！")
    else
      traceback(table_tag .. " [" .. error_color_tag .. "Config" .. end_color_tag .. "] 中 Id = [" .. error_color_tag .. key .. end_color_tag .. "] 的数据行中的字段 [" .. error_color_tag .. "Value" .. end_color_tag .. "] 不是数字！！！")
    end
    return 
  end
  configCache[key] = num
  return num
end

local GetTableConfigArray = function(key, post_warn)
  -- function num : 0_8 , upvalues : _ENV, configCache, GetTableField
  if key == nil then
    traceback("获取策划数据表数据时, key 参数不能为空！！！")
    return 
  end
  local data = configCache[key]
  if data ~= nil then
    return data
  end
  data = GetTableField("Config", key, "Value", post_warn)
  if data == nil then
    return 
  end
  local arr = (string.split)(data, ",")
  configCache[key] = arr
  return arr
end

local GetTableConfigNumberArray = function(key, post_warn)
  -- function num : 0_9 , upvalues : _ENV, configCache, GetTableField, table_tag, warn_color_tag, end_color_tag, error_color_tag
  if key == nil then
    traceback("获取策划数据表数据时, key 参数不能为空！！！")
    return 
  end
  local data = configCache[key]
  if data ~= nil then
    return data
  end
  data = GetTableField("Config", key, "Value", post_warn)
  if data == nil then
    return 
  end
  if not (string.split)(data, ",") then
    local arr = {}
  end
  if #arr == 0 then
    configCache[key] = {}
    return {}
  end
  local res = {}
  for _,v in ipairs(arr) do
    local num = tonumber(v)
    if num == nil then
      if post_warn == true then
        printWarn(table_tag .. " [" .. warn_color_tag .. "Config" .. end_color_tag .. "] 中 Id = [" .. warn_color_tag .. key .. end_color_tag .. "] 的数据行中的字段 [" .. warn_color_tag .. "Value" .. end_color_tag .. "] 不是数字数组！！！")
      else
        traceback(table_tag .. " [" .. error_color_tag .. "Config" .. end_color_tag .. "] 中 Id = [" .. error_color_tag .. key .. end_color_tag .. "] 的数据行中的字段 [" .. error_color_tag .. "Value" .. end_color_tag .. "] 不是数字数组！！！")
      end
      return res
    end
    ;
    (table.insert)(res, num)
  end
  configCache[key] = res
  return res
end

local GetTableData_Character = function(key, post_warn)
  -- function num : 0_10 , upvalues : GetTableData
  return GetTableData("Character", key, post_warn)
end

local GetTableData_Skill = function(key, post_warn)
  -- function num : 0_11 , upvalues : GetTableData
  return GetTableData("Skill", key, post_warn)
end

local GetTableData_Item = function(key, post_warn)
  -- function num : 0_12 , upvalues : GetTableData
  return GetTableData("Item", key, post_warn)
end

local GetTableData_World = function(key, post_warn)
  -- function num : 0_13 , upvalues : GetTableData
  return GetTableData("World", key, post_warn)
end

local GetTableData_HitDamage = function(key, post_warn)
  -- function num : 0_14 , upvalues : GetTableData
  return GetTableData("HitDamage", key, post_warn)
end

local GetTableData_Attribute = function(key, post_warn)
  -- function num : 0_15 , upvalues : GetTableData
  return GetTableData("Attribute", key, post_warn)
end

local GetTableData_Buff = function(key, post_warn)
  -- function num : 0_16 , upvalues : GetTableData
  return GetTableData("Buff", key, post_warn)
end

local GetTableData_Effect = function(key, post_warn)
  -- function num : 0_17 , upvalues : GetTableData
  return GetTableData("Effect", key, post_warn)
end

local GetTableData_Mainline = function(key, post_warn)
  -- function num : 0_18 , upvalues : GetTableData
  return GetTableData("Mainline", key, post_warn)
end

local GetTableData_Perk = function(key, post_warn)
  -- function num : 0_19 , upvalues : GetTableData
  return GetTableData("Perk", key, post_warn)
end

local GetTableData_Story = function(key, post_warn)
  -- function num : 0_20 , upvalues : GetTableData
  return GetTableData("Story", key, post_warn)
end

local GetTableData_CharacterSkin = function(key, post_warn)
  -- function num : 0_21 , upvalues : GetTableData
  return GetTableData("CharacterSkin", key, post_warn)
end

local GetTableData_Trap = function(key, post_warn)
  -- function num : 0_22 , upvalues : GetTableData
  return GetTableData("Trap", key, post_warn)
end

-- DECOMPILER ERROR at PC54: Confused about usage of register: R29 in 'UnsetPending'

_G.ConfigTable = {ClearCache = ClearCache, ClearTableCache = ClearTableCache, Get = GetTable, GetData = GetTableData, GetField = GetTableField, GetUIText = GetUITextData, GetConfigValue = GetTableConfigData, GetConfigNumber = GetTableConfigNumber, GetConfigArray = GetTableConfigArray, GetConfigNumberArray = GetTableConfigNumberArray, GetData_Character = GetTableData_Character, GetData_Skill = GetTableData_Skill, GetData_Item = GetTableData_Item, GetData_World = GetTableData_World, GetData_HitDamage = GetTableData_HitDamage, GetData_Attribute = GetTableData_Attribute, GetData_Buff = GetTableData_Buff, GetData_Effect = GetTableData_Effect, GetData_Mainline = GetTableData_Mainline, GetData_Perk = GetTableData_Perk, GetData_Story = GetTableData_Story, GetData_CharacterSkin = GetTableData_CharacterSkin, GetData_Trap = GetTableData_Trap}

