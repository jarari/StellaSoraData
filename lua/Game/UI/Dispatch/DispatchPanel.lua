local BasePanel = require "GameCore.UI.BasePanel"
local DispatchPanel = class("DispatchPanel", BasePanel)

-- Panel 定义
--[[
DispatchPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
DispatchPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
DispatchPanel._bIsMainPanel = true
DispatchPanel._bAddToBackHistory = true
DispatchPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
DispatchPanel._sSortingLayerName = SortingLayerName.UI
]]
DispatchPanel._tbDefine = {
    {sPrefabPath = "Dispatch/DispatchPanel.prefab", sCtrlName = "Game.UI.Dispatch.DispatchCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function DispatchPanel:Awake()
end
function DispatchPanel:OnEnable()
end
function DispatchPanel:OnDisable()
end
function DispatchPanel:OnDestroy()
end
function DispatchPanel:OnRelease()
end
-------------------- callback funcion --------------------
return DispatchPanel
