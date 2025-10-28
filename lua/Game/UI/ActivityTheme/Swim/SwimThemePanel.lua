local BasePanel = require "GameCore.UI.BasePanel"
local SwimThemePanel = class("SwimThemePanel", BasePanel)

-- Panel 定义
--[[
SwimThemePanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
SwimThemePanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
SwimThemePanel._bIsMainPanel = true
SwimThemePanel._bAddToBackHistory = true
SwimThemePanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
SwimThemePanel._sSortingLayerName = SortingLayerName.UI
]]
SwimThemePanel._sUIResRootPath = "UI_Activity/"
SwimThemePanel._tbDefine = {
    {sPrefabPath = "Swim/SwimThemePanel.prefab", sCtrlName = "Game.UI.ActivityTheme.Swim.SwimThemeCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function SwimThemePanel:Awake()
end
function SwimThemePanel:OnEnable()
end
function SwimThemePanel:OnDisable()
end
function SwimThemePanel:OnDestroy()
end
function SwimThemePanel:OnRelease()
end
-------------------- callback funcion --------------------
return SwimThemePanel
