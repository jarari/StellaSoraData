
local CharSkillTrialPanel = class("CharSkillTrialPanel", BasePanel)
-- Panel 定义
--[[
TalentPanel._bIsMainPanel = true
TalentPanel._bAddToBackHistory = true
TalentPanel._nSnapshotPrePanel = 0

TalentPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
CharSkillTrialPanel._tbDefine = { {sPrefabPath = "CharacterInfoTrial/CharSkillTrialPanel.prefab", sCtrlName = "Game.UI.CharacterInfoTrial.CharSkillTrialCtrl"} }
function CharSkillTrialPanel:Awake()
    local tbParam = self:GetPanelParam()
    if type(tbParam) == "table" then
        self.nCharId = tbParam[1] -- 角色id可能为0
    end
end
return CharSkillTrialPanel