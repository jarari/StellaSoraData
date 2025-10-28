-- Panel 模板

local ItemTipsPanel = class("ItemTipsPanel", BasePanel)
ItemTipsPanel._bIsMainPanel = false
ItemTipsPanel._bAddToBackHistory = false

ItemTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
-- Panel 定义
--[[
ItemTipsPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
ItemTipsPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
ItemTipsPanel._bIsMainPanel = true
ItemTipsPanel._bAddToBackHistory = true
ItemTipsPanel._nSnapshotPrePanel = 0

ItemTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
ItemTipsPanel._tbDefine = {
    {sPrefabPath = "CommonTipsEx/ItemTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.ItemTipsCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function ItemTipsPanel:Awake()
end
function ItemTipsPanel:OnEnable()
end
function ItemTipsPanel:OnDisable()
end
function ItemTipsPanel:OnDestroy()
end
function ItemTipsPanel:OnRelease()
end
-------------------- callback function --------------------
return ItemTipsPanel
