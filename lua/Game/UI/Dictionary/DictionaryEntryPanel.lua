local DictionaryEntryPanel = class("DictionaryEntryPanel", BasePanel)
DictionaryEntryPanel._bIsMainPanel = false
DictionaryEntryPanel._tbDefine = {
{sPrefabPath = "Dictionary/DictionaryEntryPanel.prefab", sCtrlName = "Game.UI.Dictionary.DictionaryEntryCtrl"}
}
DictionaryEntryPanel.Awake = function(self)
  -- function num : 0_0
end

DictionaryEntryPanel.OnEnable = function(self)
  -- function num : 0_1
end

DictionaryEntryPanel.OnDisable = function(self)
  -- function num : 0_2
end

DictionaryEntryPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return DictionaryEntryPanel

