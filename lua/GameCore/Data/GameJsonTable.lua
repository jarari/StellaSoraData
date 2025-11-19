local ConfigData = require("GameCore.Data.ConfigData")
local GameTableDefine = require("Game.CodeGen.GAME_TABLE_DEFINE")
local pairs = pairs
local tableInsert = table.insert
local GameJsonTable = {}
local ForEachTableLine = function(tb, f)
  -- function num : 0_0 , upvalues : pairs
  if f == nil or tb == nil then
    return 
  end
  for k,_ in pairs(tb) do
    f(tb[k])
  end
end

local GetTableKeys = function(tb)
  -- function num : 0_1 , upvalues : pairs, tableInsert
  if tb == nil then
    return 
  end
  local keys = {}
  for k,_ in pairs(tb) do
    tableInsert(keys, k)
  end
  return keys
end

LoadGameJsonTable = function(sLanguage)
  -- function num : 0_2 , upvalues : pairs, GameTableDefine, ConfigData, GameJsonTable, _ENV, ForEachTableLine, GetTableKeys
  for k,v in pairs(GameTableDefine.CommonTable) do
    local tab = (ConfigData.LoadCommonJsonTable)(k, v, sLanguage)
    GameJsonTable[k] = tab
  end
  -- DECOMPILER ERROR at PC14: Confused about usage of register: R1 in 'UnsetPending'

  _G.DataTable = GameJsonTable
  -- DECOMPILER ERROR at PC17: Confused about usage of register: R1 in 'UnsetPending'

  _G.ForEachTableLine = ForEachTableLine
  -- DECOMPILER ERROR at PC20: Confused about usage of register: R1 in 'UnsetPending'

  _G.GetTableKeys = GetTableKeys
end


