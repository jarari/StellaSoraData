local _G = _G
local sub = string.sub
local package = package
local append, concat, remove = table.insert, table.concat, table.remove
local path = {}
local at = function(s, i)
  -- function num : 0_0 , upvalues : sub
  return sub(s, i, i)
end

local sep, seps = nil, nil
path.sep = "/"
path.dirsep = ":"
seps = {["/"] = true}
sep = path.sep
path.splitpath = function(P)
  -- function num : 0_1 , upvalues : at, sep, sub
  local i = #P
  local ch = at(P, i)
  while i > 0 and ch ~= sep do
    i = i - 1
    ch = at(P, i)
  end
  if i == 0 then
    return "", P
  else
    return sub(P, 1, i - 1), sub(P, i + 1)
  end
end

path.splitext = function(P)
  -- function num : 0_2 , upvalues : at, seps, sub
  local i = #P
  local ch = at(P, i)
  while i > 0 and ch ~= "." do
    if seps[ch] then
      return P, ""
    end
    i = i - 1
    ch = at(P, i)
  end
  if i == 0 then
    return P, ""
  else
    return sub(P, 1, i - 1), sub(P, i)
  end
end

path.dirname = function(P)
  -- function num : 0_3 , upvalues : path
  local p1 = (path.splitpath)(P)
  return p1
end

path.basename = function(P)
  -- function num : 0_4 , upvalues : path
  local _, p2 = (path.splitpath)(P)
  return p2
end

path.extension = function(P)
  -- function num : 0_5 , upvalues : path
  local _, p2 = (path.splitext)(P)
  return p2
end

path.join = function(p1, p2, ...)
  -- function num : 0_6 , upvalues : _ENV, path, at
  if select("#", ...) > 0 then
    local p = (path.join)(p1, p2)
    local args = {...}
    for i = 1, #args do
      p = (path.join)(p, args[i])
    end
    return p
  end
  do
    local endc = at(p1, #p1)
    if endc ~= path.sep and endc ~= "" then
      p1 = p1 .. path.sep
    end
    return p1 .. p2
  end
end

path.normpath = function(P)
  -- function num : 0_7 , upvalues : at, sep, remove, append, concat
  local anchor = ""
  if P:match("^//") and at(P, 3) ~= "/" then
    anchor = "//"
    P = P:sub(3)
  else
    if at(P, 1) == "/" then
      anchor = "/"
      P = P:match("^/*(.*)$")
    end
  end
  local parts = {}
  for part in P:gmatch("[^" .. sep .. "]+") do
    if part == ".." then
      if #parts ~= 0 and parts[#parts] ~= ".." then
        remove(parts)
      else
        append(parts, part)
      end
    else
      if part ~= "." then
        append(parts, part)
      end
    end
  end
  P = anchor .. concat(parts, sep)
  if P == "" then
    P = "."
  end
  return P
end

path.common_prefix = function(path1, path2)
  -- function num : 0_8 , upvalues : at, sep, path
  if #path2 < #path1 then
    path2 = path1
  end
  for i = 1, #path1 do
    if at(path1, i) ~= at(path2, i) then
      local cp = path1:sub(1, i - 1)
      if at(path1, i - 1) ~= sep then
        cp = (path.dirname)(cp)
      end
      return cp
    end
  end
  -- DECOMPILER ERROR at PC49: Overwrote pending register: R0 in 'AssignReg'

  if at(path2, #path1 + 1) ~= sep then
    return path1
  end
end

path.package_path = function(mod)
  -- function num : 0_9 , upvalues : package
  local res, err1, err2 = nil, nil, nil
  res = (package.searchpath)(mod, package.path)
  if res then
    return res, true
  end
  res = (package.searchpath)(mod, package.cpath)
  if res then
    return res, false
  end
end

return path

