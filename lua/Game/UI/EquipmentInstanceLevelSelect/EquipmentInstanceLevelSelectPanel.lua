-- Panel 模板

local EquipmentInstanceLevelSelectPanel = class("EquipmentInstanceLevelSelectPanel", BasePanel)

EquipmentInstanceLevelSelectPanel._tbDefine = {
    {sPrefabPath = "EquipmentInstanceLevelSelect/EquipmentInstanceLevelSelect.prefab", sCtrlName = "Game.UI.EquipmentInstanceLevelSelect.EquipmentInstanceLevelSelectCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function EquipmentInstanceLevelSelectPanel:Awake()
end
function EquipmentInstanceLevelSelectPanel:OnEnable()
end
function EquipmentInstanceLevelSelectPanel:OnDisable()
end
function EquipmentInstanceLevelSelectPanel:OnDestroy()
end
function EquipmentInstanceLevelSelectPanel:OnRelease()
end
-------------------- callback function --------------------
return EquipmentInstanceLevelSelectPanel
