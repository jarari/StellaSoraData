local BasePanel = require "GameCore.UI.BasePanel"
local MainlineExPanel = class("MainlineExPanel", BasePanel)

-- Panel 定义
--[[
MainlineExPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
MainlineExPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
MainlineExPanel._bIsMainPanel = true
MainlineExPanel._bAddToBackHistory = true
MainlineExPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
MainlineExPanel._sSortingLayerName = SortingLayerName.UI
]]
MainlineExPanel._tbDefine = {
    {sPrefabPath = "MainlineEx/MainlineExPanel.prefab", sCtrlName = "Game.UI.MainlineEx.MainlineExCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function MainlineExPanel:Awake()
end
function MainlineExPanel:OnEnable()
end
function MainlineExPanel:OnDisable()
end
function MainlineExPanel:OnDestroy()
end
function MainlineExPanel:OnRelease()
end
-------------------- callback funcion --------------------
return MainlineExPanel
