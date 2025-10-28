local BasePanel = require "GameCore.UI.BasePanel"
local SwimThemeStoryPanel = class("SwimThemeStoryPanel", BasePanel)

-- Panel 定义
--[[
SwimThemeStoryPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
SwimThemeStoryPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
SwimThemeStoryPanel._bIsMainPanel = true
SwimThemeStoryPanel._bAddToBackHistory = true
SwimThemeStoryPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
SwimThemeStoryPanel._sSortingLayerName = SortingLayerName.UI
]]
SwimThemeStoryPanel._sUIResRootPath = "UI_Activity/"
SwimThemeStoryPanel._tbDefine = {
    {sPrefabPath = "Swim/Story/SwimThemeStoryPanel.prefab", sCtrlName = "Game.UI.ActivityTheme.Swim.Story.SwimThemeStoryCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function SwimThemeStoryPanel:Awake()
end
function SwimThemeStoryPanel:OnEnable()
end
function SwimThemeStoryPanel:OnDisable()
end
function SwimThemeStoryPanel:OnDestroy()
end
function SwimThemeStoryPanel:OnRelease()
end
-------------------- callback funcion --------------------
return SwimThemeStoryPanel
