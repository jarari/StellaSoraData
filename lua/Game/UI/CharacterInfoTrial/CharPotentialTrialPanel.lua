-- CharPotentialPanel Panel

local CharPotentialTrialPanel = class("CharPotentialTrialPanel", BasePanel)
-- Panel 定义
CharPotentialTrialPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoTrial/CharPotentialTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharPotentialTrialCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function CharPotentialTrialPanel:Awake()
end
function CharPotentialTrialPanel:OnEnable()
end
function CharPotentialTrialPanel:OnDisable()
end
function CharPotentialTrialPanel:OnDestroy()
end
-------------------- callback function --------------------
return CharPotentialTrialPanel
