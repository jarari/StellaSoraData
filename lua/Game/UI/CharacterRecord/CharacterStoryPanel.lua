local BasePanel = require "GameCore.UI.BasePanel"
local CharacterStoryPanel = class("CharacterStoryPanel", BasePanel)

-- Panel 定义
--[[
CharacterStoryPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharacterStoryPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
CharacterStoryPanel._bAddToBackHistory = true
CharacterStoryPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
]]
CharacterStoryPanel._bIsMainPanel = false
CharacterStoryPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoEx/CharacterStoryPanel.prefab", sCtrlName = "Game.UI.CharacterRecord.CharacterStoryCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function CharacterStoryPanel:Awake()
end
function CharacterStoryPanel:OnEnable()
end
function CharacterStoryPanel:OnDisable()
end
function CharacterStoryPanel:OnDestroy()
end
function CharacterStoryPanel:OnRelease()
end
-------------------- callback funcion --------------------
return CharacterStoryPanel
