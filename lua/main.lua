require "GameCore.GameCore"
NovaAPI.EnterModule("LoginModuleScene", true)

-- 一些启动时的检查可以放在这个地方进行操作，仅限editor环境下
if NovaAPI.IsEditorPlatform() then
    --检查Story表中的Avg文件是否存在
    local forEachLine_Story = function(mapLineData)
        if mapLineData.AvgLuaName ~= "" then
            local nLanIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
            local sRequireRootPath = GetAvgLuaRequireRoot(nLanIdx) .. "Config/" -- 路径是：Game/UI/Avg/_cn/Config/
            local sAvgCfgPath = NovaAPI.ApplicationDataPath.."/../Lua/" .. sRequireRootPath .. mapLineData.AvgLuaName..".lua"
            local isFileExists = CS.System.IO.File.Exists(sAvgCfgPath)
            if not isFileExists then
                printError("Story表中有不存在的Avg文件，请检查Story表，AvgName："..sAvgCfgPath)--mapLineData.AvgLuaName)
            end
        end
    end
    ForEachTableLine(DataTable.Story, forEachLine_Story)
end