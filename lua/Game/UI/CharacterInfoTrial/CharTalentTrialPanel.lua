-- CharTalentPanel Panel

local CharTalentTrialPanel = class("CharTalentTrialPanel", BasePanel)
-- Panel 定义
CharTalentTrialPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoTrial/CharTalentTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharTalentTrialCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function CharTalentTrialPanel:Awake()
end
function CharTalentTrialPanel:OnEnable()
end
function CharTalentTrialPanel:OnDisable()
end
function CharTalentTrialPanel:OnDestroy()
end
-------------------- callback function --------------------
return CharTalentTrialPanel
