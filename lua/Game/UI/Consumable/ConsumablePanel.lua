-- Panel 模板

local ConsumablePanel = class("ConsumablePanel", BasePanel)
ConsumablePanel._bIsMainPanel = false
-- Panel 定义
--[[
ConsumablePanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
ConsumablePanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
ConsumablePanel._bAddToBackHistory = true
ConsumablePanel._nSnapshotPrePanel = 0
ConsumablePanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
ConsumablePanel._tbDefine = {
    {sPrefabPath = "ConsumablesPanel/ConsumablesPanel.prefab", sCtrlName = "Game.UI.Consumable.ConsumableCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function ConsumablePanel:Awake()
end
function ConsumablePanel:OnEnable()
end
function ConsumablePanel:OnAfterEnter()
end
function ConsumablePanel:OnDisable()
end
function ConsumablePanel:OnDestroy()
end
function ConsumablePanel:OnRelease()
end
-------------------- callback function --------------------
return ConsumablePanel
