local ConfigData = require("GameCore.Data.ConfigData")
require("Diagnose")
local tab = {}
tab.Init = function(lang)
  -- function num : 0_0 , upvalues : tab
  (tab.SetType)(lang)
end

tab.SetType = function(lang)
  -- function num : 0_1 , upvalues : tab
  tab.LanguageType = lang
end

tab.GetType = function()
  -- function num : 0_2 , upvalues : tab
  if tab.LanguageType == nil then
    tab.LanguageType = "zh_CN"
  end
  return tab.LanguageType
end

-- DECOMPILER ERROR at PC14: Confused about usage of register: R2 in 'UnsetPending'

_G.LanguageTable = tab

