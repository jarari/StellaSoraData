-- Panel 模板

local CharConsumablePanel = class("CharConsumablePanel", BasePanel)
CharConsumablePanel._bIsMainPanel = false
-- Panel 定义
--[[
CharConsumablePanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharConsumablePanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
CharConsumablePanel._bAddToBackHistory = true
CharConsumablePanel._nSnapshotPrePanel = 0
CharConsumablePanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
CharConsumablePanel._tbDefine = {
    {sPrefabPath = "CharConsumablePanel/CharConsumablePanel.prefab", sCtrlName = "Game.UI.CharConsumable.CharConsumableCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function CharConsumablePanel:Awake()
end
function CharConsumablePanel:OnEnable()
end
function CharConsumablePanel:OnAfterEnter()
end
function CharConsumablePanel:OnDisable()
end
function CharConsumablePanel:OnDestroy()
end
function CharConsumablePanel:OnRelease()
end
-------------------- callback function --------------------
return CharConsumablePanel
