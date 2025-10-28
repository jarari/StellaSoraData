local EquipmentSelectPanel = class("EquipmentSelectPanel", BasePanel)

EquipmentSelectPanel._bIsMainPanel = false
EquipmentSelectPanel._tbDefine = {
    {sPrefabPath = "Equipment/EquipmentInfoPanel.prefab", sCtrlName = "Game.UI.Equipment.EquipmentInfoCtrl"}
}
-------------------- local function --------------------


-------------------- base function --------------------
function EquipmentSelectPanel:Awake()
    
end
function EquipmentSelectPanel:OnEnable()
end
function EquipmentSelectPanel:OnAfterEnter()
end
function EquipmentSelectPanel:OnDisable()
end
function EquipmentSelectPanel:OnDestroy()
end
function EquipmentSelectPanel:OnRelease()
end
-------------------- callback function --------------------
return EquipmentSelectPanel
