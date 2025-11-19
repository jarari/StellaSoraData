local PB = require("pb")
local ipairs = ipairs
local rawget = rawget
local setmetatable = setmetatable
local ConfigData = require("GameCore.Data.ConfigData")
local ReadTable = {}
ReadTable.__index = function(self, k)
  -- function num : 0_0 , upvalues : rawget, ConfigData, _ENV, PB, ipairs
  local raw = rawget(self, "raw")
  local meta = rawget(self, "meta")
  local lang = meta.lang
  local loaded = meta.loaded
  local pbName = meta.pbName
  local langs = meta.langs
  local line = raw[k]
  if langs ~= nil and lang == nil and not loaded then
    lang = (ConfigData.LoadLanguageTable)((LanguageTable.GetType)(), pbName)
    meta.lang = lang
    meta.loaded = true
  end
  if line ~= nil then
    local lineInstance = assert((PB.decode)("nova.client." .. pbName, line))
    if langs ~= nil then
      for _,v in ipairs(langs) do
        local field = lineInstance[v]
        if not lang[field] then
          do
            lineInstance[v] = field == nil or lang == nil or ""
            -- DECOMPILER ERROR at PC54: LeaveBlock: unexpected jumping out IF_THEN_STMT

            -- DECOMPILER ERROR at PC54: LeaveBlock: unexpected jumping out IF_STMT

          end
        end
      end
    end
    return lineInstance
  end
end

LoadDataTable = function(meta, raw, lang)
  -- function num : 0_1 , upvalues : setmetatable, ReadTable
  local newTable = {raw = raw, meta = meta, lang = lang}
  setmetatable(newTable, ReadTable)
  return newTable
end


