local BasePanel = require "GameCore.UI.BasePanel"
local CharEquipmentPanel = class("CharEquipmentPanel", BasePanel)

CharEquipmentPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoEx/CharEquipmentPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharEquipmentCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function CharEquipmentPanel:Awake()
    local tbParam = self:GetPanelParam()

    if type(tbParam) == "table" then
        self.nCharId = tbParam[1] -- 角色id可能为0
    end
end
function CharEquipmentPanel:OnEnable()
end
function CharEquipmentPanel:OnDisable()
end
function CharEquipmentPanel:OnDestroy()
end
function CharEquipmentPanel:OnRelease()
end
-------------------- callback function --------------------
return CharEquipmentPanel
