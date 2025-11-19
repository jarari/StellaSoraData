clone = function(object)
  -- function num : 0_0 , upvalues : _ENV
  local lookup_table = {}
  local _copy = function(object)
    -- function num : 0_0_0 , upvalues : _ENV, lookup_table, _copy
    if type(object) ~= "table" then
      return object
    else
      if lookup_table[object] then
        return lookup_table[object]
      end
    end
    local new_table = {}
    lookup_table[object] = new_table
    for key,value in pairs(object) do
      new_table[_copy(key)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end

  return _copy(object)
end

class = function(classname, super)
  -- function num : 0_1 , upvalues : _ENV
  local superType = (type(super))
  -- DECOMPILER ERROR at PC3: Overwrote pending register: R3 in 'AssignReg'

  local cls = .end
  if superType ~= "function" and superType ~= "table" then
    superType = nil
  end
  if superType == "function" or super and super.__ctype == 1 then
    cls = {}
    if superType == "table" then
      for k,v in pairs(super) do
        cls[k] = v
      end
      cls.__create = super.__create
      cls.super = super
    else
      cls.__create = super
    end
    cls.ctor = function()
    -- function num : 0_1_0
  end

    cls.__cname = classname
    cls.__ctype = 1
    cls.new = function(...)
    -- function num : 0_1_1 , upvalues : cls, _ENV
    local instance = (cls.__create)(...)
    for k,v in pairs(cls) do
      instance[k] = v
    end
    instance.class = cls
    instance:ctor(...)
    return instance
  end

  else
    if super then
      cls = clone(super)
      cls.super = super
    else
      cls = {ctor = function(...)
    -- function num : 0_1_2
  end
}
    end
    cls.__cname = classname
    cls.__ctype = 2
    cls.__index = cls
    cls.new = function(...)
    -- function num : 0_1_3 , upvalues : _ENV, cls
    local instance = setmetatable({}, cls)
    instance.class = cls
    instance:ctor(...)
    return instance
  end

  end
  return cls
end

import = function(moduleName, currentModuleName)
  -- function num : 0_2 , upvalues : _ENV
  local currentModuleNameParts = nil
  local moduleFullName = moduleName
  local offset = 1
  while 1 do
    if (string.byte)(moduleName, offset) ~= 46 then
      moduleFullName = (string.sub)(moduleName, offset)
      if currentModuleNameParts and #currentModuleNameParts > 0 then
        moduleFullName = (table.concat)(currentModuleNameParts, ".") .. "." .. moduleFullName
      end
      break
    end
    offset = offset + 1
    if not currentModuleNameParts then
      do
        if not currentModuleName then
          local n, v = (debug.getlocal)(3, 1)
          currentModuleName = v
        end
        currentModuleNameParts = (string.split)(currentModuleName, ".")
        ;
        (table.remove)(currentModuleNameParts, #currentModuleNameParts)
        -- DECOMPILER ERROR at PC52: LeaveBlock: unexpected jumping out DO_STMT

        -- DECOMPILER ERROR at PC52: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC52: LeaveBlock: unexpected jumping out IF_STMT

      end
    end
  end
  return require(moduleFullName)
end

handler = function(obj, method, uiComponent)
  -- function num : 0_3
  return function(...)
    -- function num : 0_3_0 , upvalues : uiComponent, method, obj
    if uiComponent == nil then
      return method(obj, ...)
    else
      return method(obj, uiComponent, ...)
    end
  end

end

ui_handler = function(obj, method, uiComponent, nIndex)
  -- function num : 0_4 , upvalues : _ENV
  return function(...)
    -- function num : 0_4_0 , upvalues : _ENV, nIndex, method, obj, uiComponent
    if type(nIndex) == "number" then
      return method(obj, uiComponent, nIndex, ...)
    else
      return method(obj, uiComponent, ...)
    end
  end

end

dotween_callback_handler = function(obj, method, ...)
  -- function num : 0_5 , upvalues : _ENV
  local tbParameter = {}
  for i = 1, select("#", ...) do
    local param = select(i, ...)
    ;
    (table.insert)(tbParameter, param)
  end
  return function()
    -- function num : 0_5_0 , upvalues : obj, _ENV, method, tbParameter
    if obj ~= nil and type(method) == "function" then
      local ok, error = pcall(method, obj, (table.unpack)(tbParameter))
      if not ok then
        printError(error)
      end
    end
  end

end

safe_call_cs_func = function(cs_func, ...)
  -- function num : 0_6 , upvalues : _ENV
  local tbParameter = {}
  for i = 1, select("#", ...) do
    local param = select(i, ...)
    ;
    (table.insert)(tbParameter, param)
  end
  local ok, result = pcall(cs_func, (table.unpack)(tbParameter))
  if not ok then
    printError(result)
  else
    return result
  end
end

safe_call_cs_func2 = function(cs_func, ...)
  -- function num : 0_7 , upvalues : _ENV
  local tbParameter = {}
  for i = 1, select("#", ...) do
    local param = select(i, ...)
    ;
    (table.insert)(tbParameter, param)
  end
  local tbResult = {pcall(cs_func, (table.unpack)(tbParameter))}
  if not tbResult[1] then
    printError(tbResult[2])
  else
    ;
    (table.remove)(tbResult, 1)
    return (table.unpack)(tbResult)
  end
end

-- DECOMPILER ERROR at PC18: Confused about usage of register: R0 in 'UnsetPending'

table.nums = function(t)
  -- function num : 0_8 , upvalues : _ENV
  local count = 0
  for k,v in pairs(t) do
    count = count + 1
  end
  return count
end

-- DECOMPILER ERROR at PC21: Confused about usage of register: R0 in 'UnsetPending'

table.keys = function(hashtable)
  -- function num : 0_9 , upvalues : _ENV
  local keys = {}
  for k,v in pairs(hashtable) do
    keys[#keys + 1] = k
  end
  return keys
end

-- DECOMPILER ERROR at PC24: Confused about usage of register: R0 in 'UnsetPending'

table.values = function(hashtable)
  -- function num : 0_10 , upvalues : _ENV
  local values = {}
  for k,v in pairs(hashtable) do
    if v ~= json.null then
      values[#values + 1] = v
    end
  end
  return values
end

-- DECOMPILER ERROR at PC27: Confused about usage of register: R0 in 'UnsetPending'

table.merge = function(dest, src)
  -- function num : 0_11 , upvalues : _ENV
  for k,v in pairs(src) do
    dest[k] = v
  end
end

-- DECOMPILER ERROR at PC30: Confused about usage of register: R0 in 'UnsetPending'

table.insertto = function(dest, src, begin)
  -- function num : 0_12 , upvalues : _ENV
  begin = checkint(begin)
  if begin <= 0 then
    begin = #dest + 1
  end
  local len = #src
  for i = 0, len - 1 do
    dest[i + (begin)] = src[i + 1]
  end
end

checknumber = function(value, base)
  -- function num : 0_13 , upvalues : _ENV
  return tonumber(value, base) or 0
end

checkint = function(value)
  -- function num : 0_14 , upvalues : _ENV
  return (math.round)(checknumber(value))
end

-- DECOMPILER ERROR at PC37: Confused about usage of register: R0 in 'UnsetPending'

math.round = function(value)
  -- function num : 0_15 , upvalues : _ENV
  value = checknumber(value)
  return (math.floor)(value + 0.5)
end

checkbool = function(value)
  -- function num : 0_16
  do return value ~= nil and value ~= false end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

checktable = function(value)
  -- function num : 0_17 , upvalues : _ENV
  if type(value) ~= "table" then
    value = {}
  end
  return value
end

isset = function(hashtable, key)
  -- function num : 0_18 , upvalues : _ENV
  local t = type(hashtable)
  do return (t == "table" or t == "userdata") and hashtable[key] ~= nil end
  -- DECOMPILER ERROR: 1 unprocessed JMP targets
end

-- DECOMPILER ERROR at PC46: Confused about usage of register: R0 in 'UnsetPending'

table.indexof = function(array, value, begin)
  -- function num : 0_19
  for i = begin or 1, #array do
    if array[i] == value then
      return i
    end
  end
  return 0
end

-- DECOMPILER ERROR at PC49: Confused about usage of register: R0 in 'UnsetPending'

table.keyof = function(hashtable, value)
  -- function num : 0_20 , upvalues : _ENV
  for k,v in pairs(hashtable) do
    if v == value then
      return k
    end
  end
  return nil
end

-- DECOMPILER ERROR at PC52: Confused about usage of register: R0 in 'UnsetPending'

table.removebyvalue = function(array, value, removeall)
  -- function num : 0_21 , upvalues : _ENV
  local c, i, max = 0, 1, #array
  while 1 do
    if i <= max then
      if array[i] == value then
        (table.remove)(array, i)
        c = c + 1
        i = i - 1
        max = max - 1
      end
      if removeall then
        i = i + 1
        -- DECOMPILER ERROR at PC19: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC19: LeaveBlock: unexpected jumping out IF_STMT

        -- DECOMPILER ERROR at PC19: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC19: LeaveBlock: unexpected jumping out IF_STMT

      end
    end
  end
  return c
end

-- DECOMPILER ERROR at PC55: Confused about usage of register: R0 in 'UnsetPending'

table.map = function(t, fn)
  -- function num : 0_22 , upvalues : _ENV
  for k,v in pairs(t) do
    t[k] = fn(v, k)
  end
end

-- DECOMPILER ERROR at PC58: Confused about usage of register: R0 in 'UnsetPending'

table.walk = function(t, fn)
  -- function num : 0_23 , upvalues : _ENV
  for k,v in pairs(t) do
    fn(v, k)
  end
end

-- DECOMPILER ERROR at PC61: Confused about usage of register: R0 in 'UnsetPending'

table.shuffle = function(t)
  -- function num : 0_24 , upvalues : _ENV
  local n = #t
  do
    while n > 2 do
      local k = (math.random)(n)
      t[n] = t[k]
      n = n - 1
    end
    return t
  end
end

-- DECOMPILER ERROR at PC64: Confused about usage of register: R0 in 'UnsetPending'

table.filter = function(t, fn)
  -- function num : 0_25 , upvalues : _ENV
  for k,v in pairs(t) do
    if not fn(v, k) then
      t[k] = nil
    end
  end
end

-- DECOMPILER ERROR at PC67: Confused about usage of register: R0 in 'UnsetPending'

table.unique = function(t, bArray)
  -- function num : 0_26 , upvalues : _ENV
  local check = {}
  local n = {}
  local idx = 1
  for k,v in pairs(t) do
    if not check[v] then
      if bArray then
        n[idx] = v
        idx = idx + 1
      else
        n[k] = v
      end
      check[v] = true
    end
  end
  return n
end

-- DECOMPILER ERROR at PC70: Confused about usage of register: R0 in 'UnsetPending'

string.htmlspecialchars = function(input)
  -- function num : 0_27 , upvalues : _ENV
  for k,v in pairs(string._htmlspecialchars_set) do
    input = (string.gsub)(input, k, v)
  end
  return input
end

-- DECOMPILER ERROR at PC73: Confused about usage of register: R0 in 'UnsetPending'

string.restorehtmlspecialchars = function(input)
  -- function num : 0_28 , upvalues : _ENV
  for k,v in pairs(string._htmlspecialchars_set) do
    input = (string.gsub)(input, v, k)
  end
  return input
end

-- DECOMPILER ERROR at PC76: Confused about usage of register: R0 in 'UnsetPending'

string.nl2br = function(input)
  -- function num : 0_29 , upvalues : _ENV
  return (string.gsub)(input, "\n", "<br />")
end

-- DECOMPILER ERROR at PC79: Confused about usage of register: R0 in 'UnsetPending'

string.text2html = function(input)
  -- function num : 0_30 , upvalues : _ENV
  input = (string.gsub)(input, "\t", "    ")
  input = (string.htmlspecialchars)(input)
  input = (string.gsub)(input, " ", "&nbsp;")
  input = (string.nl2br)(input)
  return input
end

-- DECOMPILER ERROR at PC82: Confused about usage of register: R0 in 'UnsetPending'

string.split = function(input, delimiter)
  -- function num : 0_31 , upvalues : _ENV
  input = tostring(input)
  delimiter = tostring(delimiter)
  if delimiter == "" then
    return false
  end
  local pos, arr = 0, {}
  for st,sp in function()
    -- function num : 0_31_0 , upvalues : _ENV, input, delimiter, pos
    return (string.find)(input, delimiter, pos, true)
  end
 do
    (table.insert)(arr, (string.sub)(input, pos, st - 1))
    pos = sp + 1
  end
  ;
  (table.insert)(arr, (string.sub)(input, pos))
  return arr
end

-- DECOMPILER ERROR at PC85: Confused about usage of register: R0 in 'UnsetPending'

string.ltrim = function(input)
  -- function num : 0_32 , upvalues : _ENV
  return (string.gsub)(input, "^[ \t\n\r]+", "")
end

-- DECOMPILER ERROR at PC88: Confused about usage of register: R0 in 'UnsetPending'

string.rtrim = function(input)
  -- function num : 0_33 , upvalues : _ENV
  return (string.gsub)(input, "[ \t\n\r]+$", "")
end

-- DECOMPILER ERROR at PC91: Confused about usage of register: R0 in 'UnsetPending'

string.trim = function(input)
  -- function num : 0_34 , upvalues : _ENV
  input = (string.gsub)(input, "^[ \t\n\r]+", "")
  return (string.gsub)(input, "[ \t\n\r]+$", "")
end

-- DECOMPILER ERROR at PC94: Confused about usage of register: R0 in 'UnsetPending'

string.ucfirst = function(input)
  -- function num : 0_35 , upvalues : _ENV
  return (string.upper)((string.sub)(input, 1, 1)) .. (string.sub)(input, 2)
end

local urlencodechar = function(char)
  -- function num : 0_36 , upvalues : _ENV
  return "%" .. (string.format)("%02X", (string.byte)(char))
end

-- DECOMPILER ERROR at PC98: Confused about usage of register: R1 in 'UnsetPending'

string.urlencode = function(input)
  -- function num : 0_37 , upvalues : _ENV, urlencodechar
  input = (string.gsub)(tostring(input), "\n", "\r\n")
  input = (string.gsub)(input, "([^%w%.%- ])", urlencodechar)
  return (string.gsub)(input, " ", "+")
end

-- DECOMPILER ERROR at PC101: Confused about usage of register: R1 in 'UnsetPending'

string.urldecode = function(input)
  -- function num : 0_38 , upvalues : _ENV
  input = (string.gsub)(input, "+", " ")
  input = (string.gsub)(input, "%%(%x%x)", function(h)
    -- function num : 0_38_0 , upvalues : _ENV
    return (string.char)(checknumber(h, 16))
  end
)
  input = (string.gsub)(input, "\r\n", "\n")
  return input
end

-- DECOMPILER ERROR at PC104: Confused about usage of register: R1 in 'UnsetPending'

string.utf8len = function(input)
  -- function num : 0_39 , upvalues : _ENV
  local len = (string.len)(input)
  local left = len
  local cnt = 0
  local arr = {0, 192, 224, 240, 248, 252}
  while left ~= 0 do
    local tmp = (string.byte)(input, -left)
    local i = #arr
    while arr[i] do
      if arr[i] <= tmp then
        left = left - i
        break
      end
      i = i - 1
    end
    cnt = cnt + 1
  end
  do
    return cnt
  end
end

-- DECOMPILER ERROR at PC107: Confused about usage of register: R1 in 'UnsetPending'

string.formatnumberthousands = function(num)
  -- function num : 0_40 , upvalues : _ENV
  (tostring(checknumber(num)))
  local formatted = nil
  local k = nil
  while 1 do
    formatted = (string.gsub)(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
  end
  if k ~= 0 then
    return formatted
  end
end

-- DECOMPILER ERROR at PC110: Confused about usage of register: R1 in 'UnsetPending'

string.append_all = function(buffer, ...)
  -- function num : 0_41 , upvalues : _ENV
  for i = 1, select("#", ...) do
    (table.insert)(buffer, select(i, ...))
  end
end

print_dump = function(data, showMetatable, lastCount)
  -- function num : 0_42 , upvalues : _ENV
  if type(data) ~= "table" then
    if type(data) == "string" then
      print("\"", data, "\"")
    else
      print(tostring(data))
    end
  else
    local count = lastCount or 0
    count = count + 1
    print("{\n")
    if showMetatable then
      for i = 1, count do
        print("\t")
      end
      local mt = getmetatable(data)
      print("\"__metatable\" = ")
      print_dump(mt, showMetatable, count)
      print(",\n")
    end
    do
      for key,value in pairs(data) do
        for i = 1, count do
          print("\t")
        end
        if type(key) == "string" then
          print("\"", key, "\" = ")
        else
          if type(key) == "number" then
            print("[", key, "] = ")
          else
            print(tostring(key))
          end
        end
        print_dump(value, showMetatable, count)
        print(",\n")
      end
      do
        do
          for i = 1, lastCount or 0 do
            print("\t")
          end
          print("}")
          if not lastCount then
            print("\n")
          end
        end
      end
    end
  end
end

setfenv = function(fn, env)
  -- function num : 0_43 , upvalues : _ENV
  local i = 1
  while 1 do
    local name = (debug.getupvalue)(fn, i)
    if name == "_ENV" then
      (debug.upvaluejoin)(fn, i, function()
    -- function num : 0_43_0 , upvalues : env
    return env
  end
, 1)
      break
    else
    end
    if name then
      do
        i = i + 1
        -- DECOMPILER ERROR at PC20: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC20: LeaveBlock: unexpected jumping out IF_STMT

      end
    end
  end
  return fn
end

getfenv = function(fn)
  -- function num : 0_44 , upvalues : _ENV
  local i = 1
  while 1 do
    local name, val = (debug.getupvalue)(fn, i)
    if name == "_ENV" then
      return val
    else
    end
    if name then
      do
        i = i + 1
        -- DECOMPILER ERROR at PC13: LeaveBlock: unexpected jumping out IF_THEN_STMT

        -- DECOMPILER ERROR at PC13: LeaveBlock: unexpected jumping out IF_STMT

      end
    end
  end
end

run_with_env = function(env, fn, ...)
  -- function num : 0_45 , upvalues : _ENV
  setfenv(fn, env)
  fn(...)
end

local sortedKeys = function(t)
  -- function num : 0_46 , upvalues : _ENV
  local keys = {}
  for k in pairs(t) do
    if type(k) == "number" then
      (table.insert)(keys, k)
    end
  end
  ;
  (table.sort)(keys)
  return keys
end

ipairsSorted = function(t)
  -- function num : 0_47 , upvalues : sortedKeys
  local keys = sortedKeys(t)
  local i = 0
  return function()
    -- function num : 0_47_0 , upvalues : i, keys, t
    i = i + 1
    if keys[i] then
      return keys[i], t[keys[i]]
    end
  end

end

orderedFormat = function(formatStr, ...)
  -- function num : 0_48 , upvalues : _ENV
  local args = {...}
  return formatStr:gsub("{(%d+)}", function(index)
    -- function num : 0_48_0 , upvalues : _ENV, args
    index = tonumber(index) + 1
    return tostring(args[index])
  end
)
end

clearFloat = function(a)
  -- function num : 0_49 , upvalues : _ENV
  local floor = (math.floor)(a)
  local ceil = (math.ceil)(a)
  if (math.abs)(a - floor) < 1e-10 then
    return floor
  end
  if (math.abs)(a - ceil) < 1e-10 then
    return ceil
  end
  return a
end


