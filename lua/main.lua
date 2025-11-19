require("GameCore.GameCore")
;
(NovaAPI.EnterModule)("LoginModuleScene", true)
if (NovaAPI.IsEditorPlatform)() then
  local forEachLine_Story = function(mapLineData)
  -- function num : 0_0 , upvalues : _ENV
  if mapLineData.AvgLuaName ~= "" then
    local nLanIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
    local sRequireRootPath = GetAvgLuaRequireRoot(nLanIdx) .. "Config/"
    local sAvgCfgPath = NovaAPI.ApplicationDataPath .. "/../Lua/" .. sRequireRootPath .. mapLineData.AvgLuaName .. ".lua"
    local isFileExists = ((((CS.System).IO).File).Exists)(sAvgCfgPath)
    if not isFileExists then
      printError("Story表中有不存在的Avg文件，请检查Story表，AvgName：" .. sAvgCfgPath)
    end
  end
end

  ForEachTableLine(DataTable.Story, forEachLine_Story)
end

