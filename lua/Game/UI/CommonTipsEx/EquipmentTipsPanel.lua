-- Panel 模板

local EquipmentTipsPanel = class("EquipmentTipsPanel", BasePanel)
EquipmentTipsPanel._bIsMainPanel = false
EquipmentTipsPanel._bAddToBackHistory = false

EquipmentTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
-- Panel 定义
--[[
EquipmentTipsPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
EquipmentTipsPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
EquipmentTipsPanel._bIsMainPanel = true
EquipmentTipsPanel._bAddToBackHistory = true
EquipmentTipsPanel._nSnapshotPrePanel = 0

EquipmentTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
EquipmentTipsPanel._tbDefine = {
    {sPrefabPath = "CommonTipsEx/EquipmentTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.EquipmentTipsCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function EquipmentTipsPanel:Awake()
end
function EquipmentTipsPanel:OnEnable()
end
function EquipmentTipsPanel:OnDisable()
end
function EquipmentTipsPanel:OnDestroy()
end
function EquipmentTipsPanel:OnRelease()
end
-------------------- callback function --------------------
return EquipmentTipsPanel
