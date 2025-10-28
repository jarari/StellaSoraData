local BasePanel = require "GameCore.UI.BasePanel"
local StoryChapterPanel = class("StoryChapterPanel", BasePanel)

-- Panel 定义
--[[
StoryChapterPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
StoryChapterPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
StoryChapterPanel._bIsMainPanel = true
StoryChapterPanel._bAddToBackHistory = true
StoryChapterPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
StoryChapterPanel._sSortingLayerName = SortingLayerName.UI
]]
StoryChapterPanel._tbDefine = {
    {sPrefabPath = "MainlineEx/StoryChapterPanel.prefab", sCtrlName = "Game.UI.MainlineEx.StoryChapterCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function StoryChapterPanel:Awake()
end
function StoryChapterPanel:OnEnable()
end
function StoryChapterPanel:OnDisable()
end
function StoryChapterPanel:OnDestroy()
end
function StoryChapterPanel:OnRelease()
end
-------------------- callback funcion --------------------
return StoryChapterPanel
