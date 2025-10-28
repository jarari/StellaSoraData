
local EquipmentInstanceResultPanel = class("EquipmentInstanceResultPanel", BasePanel)

EquipmentInstanceResultPanel._bAddToBackHistory = false

-- Panel 定义
EquipmentInstanceResultPanel._tbDefine = {
    {sPrefabPath = "BattleResult/BattleResultPanel.prefab", sCtrlName = "Game.UI.BattleResult.EquipmentInstanceResultCtrl"}
}
-------------------- local function --------------------
-------------------- base function --------------------

function EquipmentInstanceResultPanel:Awake()
end
function EquipmentInstanceResultPanel:OnEnable()
end
function EquipmentInstanceResultPanel:OnDisable()
end
function EquipmentInstanceResultPanel:OnDestroy()
end
-------------------- callback function --------------------
return EquipmentInstanceResultPanel
