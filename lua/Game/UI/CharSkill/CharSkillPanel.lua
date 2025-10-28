
local TalentPanel = class("TalentPanel", BasePanel)
-- Panel 定义
--[[
TalentPanel._bIsMainPanel = true
TalentPanel._bAddToBackHistory = true
TalentPanel._nSnapshotPrePanel = 0

TalentPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
TalentPanel._tbDefine = { {sPrefabPath = "CharSkill/CharSkillPanel.prefab", sCtrlName = "Game.UI.CharSkill.CharSkillCtrl"} }
function TalentPanel:Awake()
    local tbParam = self:GetPanelParam()
    if type(tbParam) == "table" then
        self.nCharId = tbParam[1] -- 角色id可能为0
    end
end
return TalentPanel