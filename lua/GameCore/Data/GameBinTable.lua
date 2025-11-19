local ConfigData = require("GameCore.Data.ConfigData")
local PB = require("pb")
local GameTableDefine = require("Game.CodeGen.GAME_TABLE_DEFINE")
require("GameCore.Data.LuaDataTable")
local rawget = rawget
local pairs = pairs
local tableInsert = table.insert
local assert = assert
local GameBinTable = {}
local ForEachTableLine = function(tb, f)
  -- function num : 0_0 , upvalues : rawget, pairs
  if f == nil or tb == nil then
    return 
  end
  local raw = rawget(tb, "raw")
  for k,_ in pairs(raw) do
    f(tb[k])
  end
end

local GetTableKeys = function(tb)
  -- function num : 0_1 , upvalues : rawget, _ENV, pairs, tableInsert
  if tb == nil then
    return 
  end
  local raw = rawget(tb, "raw")
  if raw == nil then
    traceback("raw = nil !")
    return 
  end
  local keys = {}
  for k,_ in pairs(raw) do
    tableInsert(keys, k)
  end
  return keys
end

LoadGameBinTable = function(sLanguage)
  -- function num : 0_2 , upvalues : _ENV, assert, PB, pairs, GameTableDefine, ConfigData, GameBinTable, ForEachTableLine, GetTableKeys
  local pbSchema = (NovaAPI.LoadLuaBytes)("Game/CodeGen/table.pb")
  assert((PB.load)(pbSchema))
  for k,v in pairs(GameTableDefine.CommonTable) do
    local tab = (ConfigData.LoadCommonBinTable)(k, v, sLanguage)
    GameBinTable[k] = tab
  end
  -- DECOMPILER ERROR at PC23: Confused about usage of register: R2 in 'UnsetPending'

  _G.DataTable = GameBinTable
  -- DECOMPILER ERROR at PC26: Confused about usage of register: R2 in 'UnsetPending'

  _G.ForEachTableLine = ForEachTableLine
  -- DECOMPILER ERROR at PC29: Confused about usage of register: R2 in 'UnsetPending'

  _G.GetTableKeys = GetTableKeys
end


