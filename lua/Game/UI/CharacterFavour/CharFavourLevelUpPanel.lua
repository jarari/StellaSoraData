local BasePanel = require "GameCore.UI.BasePanel"
local CharFavourLevelUpPanel = class("CharFavourLevelUpPanel", BasePanel)

-- Panel 定义
--[[
CharFavourLevelUpPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharFavourLevelUpPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
CharFavourLevelUpPanel._bIsMainPanel = true
CharFavourLevelUpPanel._bAddToBackHistory = true
CharFavourLevelUpPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
CharFavourLevelUpPanel._sSortingLayerName = SortingLayerName.UI
]]
CharFavourLevelUpPanel._bIsMainPanel = false
CharFavourLevelUpPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
CharFavourLevelUpPanel._tbDefine = {
    {sPrefabPath = "CharacterFavour/CharFavourLevelUpPanel.prefab", sCtrlName = "Game.UI.CharacterFavour.CharFavourLevelUpCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function CharFavourLevelUpPanel:Awake()
end
function CharFavourLevelUpPanel:OnEnable()
end
function CharFavourLevelUpPanel:OnDisable()
end
function CharFavourLevelUpPanel:OnDestroy()
end
function CharFavourLevelUpPanel:OnRelease()
end
-------------------- callback funcion --------------------
return CharFavourLevelUpPanel
