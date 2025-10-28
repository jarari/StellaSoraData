-- MainBattlePausePanel Panel

local MainBattlePausePanel = class("MainBattlePausePanel", BasePanel)
-- Panel 定义
MainBattlePausePanel._bIsMainPanel = false
MainBattlePausePanel._tbDefine = {
    {sPrefabPath = "Battle/MainBattlePausePanel.prefab", sCtrlName = "Game.UI.Battle.MainBattlePauseCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function MainBattlePausePanel:Awake()
end
function MainBattlePausePanel:OnEnable()
end
function MainBattlePausePanel:OnDisable()
end
function MainBattlePausePanel:OnDestroy()
end
-------------------- callback function --------------------
return MainBattlePausePanel
