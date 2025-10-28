-- DictionaryFRPanel Panel

local DictionaryFRPanel = class("DictionaryFRPanel", BasePanel)
-- Panel 定义
DictionaryFRPanel._bIsMainPanel = false
DictionaryFRPanel._tbDefine = {
    {sPrefabPath = "Dictionary/DictionaryPanel.prefab", sCtrlName = "Game.UI.Dictionary.DictionaryCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function DictionaryFRPanel:Awake()
    self.bStarTowerFastBattle = self:GetPanelParam()[1]
end
function DictionaryFRPanel:OnEnable()
end
function DictionaryFRPanel:OnDisable()
end
function DictionaryFRPanel:OnDestroy()
end
-------------------- callback function --------------------
return DictionaryFRPanel
