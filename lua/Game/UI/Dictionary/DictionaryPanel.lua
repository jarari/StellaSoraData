-- DictionaryPanel Panel

local DictionaryPanel = class("DictionaryPanel", BasePanel)
-- Panel 定义
DictionaryPanel._tbDefine = {
    {sPrefabPath = "Dictionary/DictionaryPanel.prefab", sCtrlName = "Game.UI.Dictionary.DictionaryCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function DictionaryPanel:Awake()
    self.bStarTowerFastBattle = self:GetPanelParam()[1]
end
function DictionaryPanel:OnEnable()
end
function DictionaryPanel:OnAfterEnter()
    EventManager.Hit("CloseSideBanner")
end
function DictionaryPanel:OnDisable()
end
function DictionaryPanel:OnDestroy()
end
-------------------- callback function --------------------
return DictionaryPanel
