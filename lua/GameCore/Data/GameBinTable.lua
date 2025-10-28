local ConfigData = require "GameCore.Data.ConfigData"
local PB = require "pb"
-- local protoc = require "GameCore.Network.protoc"
local GameTableDefine = require "Game.CodeGen.GAME_TABLE_DEFINE"
require "GameCore.Data.LuaDataTable"
local rawget = rawget
local pairs = pairs
local tableInsert = table.insert
local assert = assert

local GameBinTable = {}

local function ForEachTableLine(tb, f)
    if f == nil or tb == nil then
        return
    end

    local raw = rawget(tb, "raw")

    for k, _ in pairs(raw) do
        f(tb[k])
    end
end

local function GetTableKeys(tb)
    if tb == nil then
        return
    end

    local raw = rawget(tb, "raw")
    if raw == nil then
        traceback("raw = nil !")
        return
    end

    local keys = {}
    for k, _ in pairs(raw) do
        tableInsert(keys, k)
    end

    return keys
end

function LoadGameBinTable(sLanguage)
    local pbSchema = NovaAPI.LoadLuaBytes("Game/CodeGen/table.pb")
    assert(PB.load(pbSchema))
    for k, v in pairs(GameTableDefine.CommonTable) do
        local tab = ConfigData.LoadCommonBinTable(k, v, sLanguage)
        GameBinTable[k] = tab
        -- local keys = GetTableKeys(tab)
        -- printTable(keys)
    end
    
    _G.DataTable = GameBinTable
    _G.ForEachTableLine = ForEachTableLine
    _G.GetTableKeys = GetTableKeys
end
