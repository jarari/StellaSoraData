local BasePanel = require "GameCore.UI.BasePanel"
local CharFavourTaskPanel = class("CharFavourTaskPanel", BasePanel)

-- Panel 定义
--[[
CharFavourTaskPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharFavourTaskPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
CharFavourTaskPanel._bIsMainPanel = true
CharFavourTaskPanel._bAddToBackHistory = true
CharFavourTaskPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
CharFavourTaskPanel._sSortingLayerName = SortingLayerName.UI
]]
CharFavourTaskPanel._bIsMainPanel = false
CharFavourTaskPanel._tbDefine = {
    {sPrefabPath = "CharacterFavour/CharFavourTaskPanel.prefab", sCtrlName = "Game.UI.CharacterFavour.CharFavourTaskCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function CharFavourTaskPanel:Awake()
end
function CharFavourTaskPanel:OnEnable()
end
function CharFavourTaskPanel:OnDisable()
end
function CharFavourTaskPanel:OnDestroy()
end
function CharFavourTaskPanel:OnRelease()
end
-------------------- callback funcion --------------------
return CharFavourTaskPanel
