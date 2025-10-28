-- EquipmentRenamePanel Panel

local EquipmentRenamePanel = class("EquipmentRenamePanel", BasePanel)
-- Panel 定义
EquipmentRenamePanel._bIsMainPanel = false
EquipmentRenamePanel._tbDefine = {
    {sPrefabPath = "Equipment/EquipmentRenamePanel.prefab", sCtrlName = "Game.UI.Equipment.EquipmentRenameCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function EquipmentRenamePanel:Awake()
end
function EquipmentRenamePanel:OnEnable()
end
function EquipmentRenamePanel:OnDisable()
end
function EquipmentRenamePanel:OnDestroy()
end
-------------------- callback function --------------------
return EquipmentRenamePanel
