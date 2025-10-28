local BasePanel = require "GameCore.UI.BasePanel"
local StoryEntrancePanel = class("StoryEntrancePanel", BasePanel)

-- Panel 定义
--[[
StoryEntrancePanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
StoryEntrancePanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
StoryEntrancePanel._bIsMainPanel = true
StoryEntrancePanel._bAddToBackHistory = true
StoryEntrancePanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
StoryEntrancePanel._sSortingLayerName = SortingLayerName.UI
]]
StoryEntrancePanel._tbDefine = {
    {sPrefabPath = "MainlineEx/StoryEntrancePanel.prefab", sCtrlName = "Game.UI.MainlineEx.StoryEntranceCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function StoryEntrancePanel:Awake()
end
function StoryEntrancePanel:OnEnable()
end
function StoryEntrancePanel:OnDisable()
end
function StoryEntrancePanel:OnDestroy()
end
function StoryEntrancePanel:OnRelease()
end
-------------------- callback funcion --------------------
return StoryEntrancePanel
