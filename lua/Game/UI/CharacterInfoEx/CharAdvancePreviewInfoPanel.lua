local BasePanel = require "GameCore.UI.BasePanel"
local CharAdvancePreviewInfoPanel = class("CharAdvancePreviewInfoPanel", BasePanel)

CharAdvancePreviewInfoPanel._bIsMainPanel = false
-- Panel 定义
--[[
CharAdvancePreviewInfoPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharAdvancePreviewInfoPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
CharAdvancePreviewInfoPanel._bIsMainPanel = true
CharAdvancePreviewInfoPanel._bAddToBackHistory = true
CharAdvancePreviewInfoPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
CharAdvancePreviewInfoPanel._sSortingLayerName = SortingLayerName.UI
]]
CharAdvancePreviewInfoPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoEx/CharAdvancePreviewInfoPanel.prefab", sCtrlName = "Game.UI.CharacterInfoEx.CharAdvancePreviewInfoCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function CharAdvancePreviewInfoPanel:Awake()
end
function CharAdvancePreviewInfoPanel:OnEnable()
end
function CharAdvancePreviewInfoPanel:OnDisable()
end
function CharAdvancePreviewInfoPanel:OnDestroy()
end
function CharAdvancePreviewInfoPanel:OnRelease()
end
-------------------- callback function --------------------
return CharAdvancePreviewInfoPanel
