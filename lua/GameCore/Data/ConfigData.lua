local RapidJson = require("rapidjson")
local GameTableDefine = require("Game.CodeGen.GAME_TABLE_DEFINE")
local ClientManager = (CS.ClientManager).Instance
require("GameCore.Data.ConfigTable")
require("GameCore.Data.CacheTable")
local ConfigData = {IntFloatPrecision = 0.0001}
local PreProcess = function()
  -- function num : 0_0
end

ConfigData.Load = function(sLanguage)
  -- function num : 0_1 , upvalues : _ENV, PreProcess
  (NovaAPI.LoadAllDataTable)(sLanguage)
  require("GameCore.Data.LanguageTable")
  ;
  (LanguageTable.Init)(sLanguage)
  if (NovaAPI.IsBinFormatEnabled)() then
    require("GameCore.Data.GameBinTable")
    LoadGameBinTable(sLanguage)
  else
    require("GameCore.Data.GameJsonTable")
    LoadGameJsonTable(sLanguage)
  end
  PreProcess()
  printLog("Config data loaded.")
end

ConfigData.Unload = function()
  -- function num : 0_2 , upvalues : _ENV
  (NovaAPI.UnLoadAllDataTable)()
  printLog("Config data unload.")
end

local GenLanguageTable = function(jsonArray)
  -- function num : 0_3 , upvalues : _ENV
  do
    if jsonArray ~= nil and type(jsonArray) == "table" then
      local jsonObject = {}
      for _,v in ipairs(jsonArray) do
        local id = v.Key
        jsonObject[id] = v.Value
      end
      return jsonObject
    end
    return nil
  end
end

local ConvertKeyTable = function(jsonArray)
  -- function num : 0_4 , upvalues : _ENV
  do
    if jsonArray ~= nil and type(jsonArray) == "table" and jsonArray.list ~= nil and type(jsonArray.list) == "table" then
      local jsonObject = {}
      for i,v in ipairs(jsonArray.list) do
        local id = v.Id
        jsonObject[id] = v
      end
      return jsonObject
    end
    return nil
  end
end

local ConvertNoKeyTable = function(jsonArray)
  -- function num : 0_5 , upvalues : _ENV
  do
    if jsonArray ~= nil and type(jsonArray) == "table" and jsonArray.list ~= nil and type(jsonArray.list) == "table" then
      local jsonObject = {}
      for i,v in ipairs(jsonArray.list) do
        jsonObject[i] = v
      end
      return jsonObject
    end
    return nil
  end
end

local HandleLanguage = function(jsonArray, sLanguage, tableName, langDefine)
  -- function num : 0_6 , upvalues : ConfigData, _ENV
  if langDefine == nil then
    return 
  end
  local languageTab = (ConfigData.LoadLanguageTable)(sLanguage, tableName)
  if jsonArray ~= nil and type(jsonArray) == "table" and jsonArray.list ~= nil and type(jsonArray.list) == "table" then
    for _,v in ipairs(jsonArray.list) do
      for _,d in ipairs(langDefine) do
        local lang = v[d]
        if not languageTab[lang] then
          do
            v[d] = lang == nil or ""
            -- DECOMPILER ERROR at PC38: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC38: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
  end
end

ConfigData.LoadLanguageTable = function(lang, tableName)
  -- function num : 0_7 , upvalues : _ENV, RapidJson
  local jsonText = (NovaAPI.LoadTableData)("language/" .. lang .. "/" .. tableName .. ".json") or ""
  if not (RapidJson.decode)(jsonText) then
    local tab = {}
  end
  return tab
end

ConfigData.LoadCommonJsonTable = function(tableName, define, sLanguage)
  -- function num : 0_8 , upvalues : _ENV, RapidJson, HandleLanguage, ConvertKeyTable, ConvertNoKeyTable
  local jsonText = (NovaAPI.LoadTableData)("json/" .. tableName .. ".json") or ""
  local tab = (RapidJson.decode)(jsonText)
  local lang = define.Lang
  if (NovaAPI.IsLQA)() then
    lang = nil
  end
  HandleLanguage(tab, sLanguage, tableName, lang)
  local tab1 = nil
  if define.Key then
    tab1 = ConvertKeyTable(tab)
  else
    tab1 = ConvertNoKeyTable(tab)
  end
  return tab1
end

ConfigData.LoadCommonBinTable = function(tableName, define, sLanguage)
  -- function num : 0_9 , upvalues : _ENV, ClientManager, ConfigData
  local tab = {}
  ;
  (NovaAPI.LoadCommonBinData)("bin/" .. tableName .. ".bytes", tab)
  local langs = define.Lang
  if (NovaAPI.IsLQA)() then
    langs = nil
  end
  local lang = nil
  local loaded = false
  if not ClientManager:GetMemoryType() and langs ~= nil then
    lang = (ConfigData.LoadLanguageTable)(sLanguage, tableName)
    loaded = true
  end
  local meta = {pbName = tableName, langs = langs, lang = lang, loaded = loaded}
  local tab1 = LoadDataTable(meta, tab)
  return tab1
end

return ConfigData

