-- DictionaryEntryPanel Panel

local DictionaryEntryPanel = class("DictionaryEntryPanel", BasePanel)
-- Panel 定义
DictionaryEntryPanel._bIsMainPanel = false

DictionaryEntryPanel._tbDefine = {
    {sPrefabPath = "Dictionary/DictionaryEntryPanel.prefab", sCtrlName = "Game.UI.Dictionary.DictionaryEntryCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function DictionaryEntryPanel:Awake()
end
function DictionaryEntryPanel:OnEnable()
end
function DictionaryEntryPanel:OnDisable()
end
function DictionaryEntryPanel:OnDestroy()
end
-------------------- callback function --------------------
return DictionaryEntryPanel
