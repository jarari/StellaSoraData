local BasePanel = require "GameCore.UI.BasePanel"
local CharFavourExpUpPanel = class("CharFavourExpUpPanel", BasePanel)

-- Panel 定义
--[[
CharFavourExpUpPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharFavourExpUpPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
CharFavourExpUpPanel._bIsMainPanel = true
CharFavourExpUpPanel._bAddToBackHistory = true
CharFavourExpUpPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
CharFavourExpUpPanel._sSortingLayerName = SortingLayerName.UI
]]
CharFavourExpUpPanel._bIsMainPanel = false
CharFavourExpUpPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
CharFavourExpUpPanel._tbDefine = {
    {sPrefabPath = "CharacterFavour/CharFavourExpUpPanel.prefab", sCtrlName = "Game.UI.CharacterFavour.CharFavourExpUpCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function CharFavourExpUpPanel:Awake()
end
function CharFavourExpUpPanel:OnEnable()
end
function CharFavourExpUpPanel:OnDisable()
end
function CharFavourExpUpPanel:OnDestroy()
end
function CharFavourExpUpPanel:OnRelease()
end
-------------------- callback funcion --------------------
return CharFavourExpUpPanel
