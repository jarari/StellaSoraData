-- Panel 模板

local GachaPanel = class("GachaPanel", BasePanel)

-- Panel 定义
--[[
GachaPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
GachaPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
GachaPanel._bIsMainPanel = true
GachaPanel._bAddToBackHistory = true
GachaPanel._nSnapshotPrePanel = 0

GachaPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
GachaPanel._tbDefine = {
    {sPrefabPath = "GachaEx/GachaPanel.prefab", sCtrlName = "Game.UI.GachaEx.GachaCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function GachaPanel:Awake()
end
function GachaPanel:OnEnable()
end
function GachaPanel:OnDisable()
end
function GachaPanel:OnDestroy()
end
function GachaPanel:OnRelease()
end
-------------------- callback function --------------------
return GachaPanel
