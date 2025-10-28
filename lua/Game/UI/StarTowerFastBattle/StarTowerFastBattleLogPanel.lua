local StarTowerFastBattleLogPanel = class("StarTowerFastBattleLogPanel", BasePanel)
-- Panel 定义

StarTowerFastBattleLogPanel._bIsMainPanel = false

StarTowerFastBattleLogPanel._tbDefine = {
    {sPrefabPath = "StarTowerFastBattle/StarTowerFastBattleLogPanel.prefab", sCtrlName = "Game.UI.StarTowerFastBattle.StarTowerFastBattleLogCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function StarTowerFastBattleLogPanel:Awake()
    self.tbHistoryLog = self:GetPanelParam()[1]
end
function StarTowerFastBattleLogPanel:OnEnable()
end
function StarTowerFastBattleLogPanel:OnDisable()
end
function StarTowerFastBattleLogPanel:OnDestroy()
end
-------------------- callback function --------------------
return StarTowerFastBattleLogPanel
