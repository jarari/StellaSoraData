local tableconcat = table.concat
local stringformat = string.format
local StringBuilder = {}
StringBuilder.new = function(self, sep)
  -- function num : 0_0 , upvalues : _ENV
  local object = {}
  setmetatable(object, self)
  self.__index = self
  object.sep = sep
  object.buffer = {}
  return object
end

StringBuilder.Append = function(self, str)
  -- function num : 0_1
  -- DECOMPILER ERROR at PC4: Confused about usage of register: R2 in 'UnsetPending'

  (self.buffer)[#self.buffer + 1] = str
end

StringBuilder.AppendFormat = function(self, format, ...)
  -- function num : 0_2 , upvalues : stringformat
  self:Append(stringformat(format, ...))
end

StringBuilder.AppendLine = function(self, str)
  -- function num : 0_3
  self:Append(str)
  self:Append("\r\n")
end

StringBuilder.ToString = function(self)
  -- function num : 0_4 , upvalues : tableconcat
  return tableconcat(self.buffer, self.sep)
end

StringBuilder.Clear = function(self)
  -- function num : 0_5
  local count = #self.buffer
  for i = 1, count do
    -- DECOMPILER ERROR at PC7: Confused about usage of register: R6 in 'UnsetPending'

    (self.buffer)[i] = nil
  end
end

local __printTable = function(tb, sb, name, aPreText, bLast)
  -- function num : 0_6 , upvalues : _ENV, __printTable
  if tb == nil then
    return 
  end
  if bLast == nil then
    bLast = false
  end
  if not name then
    name = ""
  end
  local preText = aPreText or ""
  local subPreText = ""
  if aPreText == nil then
    sb:AppendLine("[ROOT]")
  else
    if bLast then
      subPreText = preText .. "    "
    else
      subPreText = preText .. "│  "
    end
    if type(tb) == "table" then
      if bLast then
        sb:AppendLine((string.format)("%s└─[%s]", preText, name))
      else
        sb:AppendLine((string.format)("%s├─[%s]", preText, name))
      end
    else
      if bLast then
        sb:AppendLine((string.format)("%s└─%s= %s", preText, name, tostring(tb)))
      else
        sb:AppendLine((string.format)("%s├─%s= %s", preText, name, tostring(tb)))
      end
    end
  end
  if type(tb) == "table" then
    local counter = 0
    local count = 0
    for _,_ in pairs(tb) do
      count = count + 1
    end
    for key,obj in pairs(tb) do
      counter = counter + 1
      __printTable(obj, sb, key, subPreText, counter == count)
    end
  end
  if bLast then
    sb:AppendLine(preText)
  end
  -- DECOMPILER ERROR: 4 unprocessed JMP targets
end

PrintTable = function(tb, filename)
  -- function num : 0_7 , upvalues : StringBuilder, __printTable, _ENV
  local sb = StringBuilder:new()
  __printTable(tb, sb)
  local str = sb:ToString()
  if filename then
    local f = (io.open)(filename, "w")
    if f ~= nil then
      f:write(str)
      f:close()
    end
  else
    do
      print(str)
    end
  end
end


