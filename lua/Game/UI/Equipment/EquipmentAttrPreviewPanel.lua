local EquipmentAttrPreviewPanel = class("EquipmentAttrPreviewPanel", BasePanel)

EquipmentAttrPreviewPanel._bIsMainPanel = false
EquipmentAttrPreviewPanel._tbDefine = {
    {sPrefabPath = "Equipment/EquipmentAttrPreviewPanel.prefab", sCtrlName = "Game.UI.Equipment.EquipmentAttrPreviewCtrl"}
}
-------------------- local function --------------------


-------------------- base function --------------------
function EquipmentAttrPreviewPanel:Awake()
    
end
function EquipmentAttrPreviewPanel:OnEnable()
end
function EquipmentAttrPreviewPanel:OnAfterEnter()
end
function EquipmentAttrPreviewPanel:OnDisable()
end
function EquipmentAttrPreviewPanel:OnDestroy()
end
function EquipmentAttrPreviewPanel:OnRelease()
end
-------------------- callback function --------------------
return EquipmentAttrPreviewPanel
