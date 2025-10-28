local BasePanel = require "GameCore.UI.BasePanel"
local CharFavourRewardPanel = class("CharFavourRewardPanel", BasePanel)

-- Panel 定义
--[[
CharFavourRewardPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharFavourRewardPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
CharFavourRewardPanel._bIsMainPanel = true
CharFavourRewardPanel._bAddToBackHistory = true
CharFavourRewardPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
CharFavourRewardPanel._sSortingLayerName = SortingLayerName.UI
]]
CharFavourRewardPanel._bIsMainPanel = false
CharFavourRewardPanel._tbDefine = {
    {sPrefabPath = "CharacterFavour/CharFavourRewardPanel.prefab", sCtrlName = "Game.UI.CharacterFavour.CharFavourRewardCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function CharFavourRewardPanel:Awake()
end
function CharFavourRewardPanel:OnEnable()
end
function CharFavourRewardPanel:OnDisable()
end
function CharFavourRewardPanel:OnDestroy()
end
function CharFavourRewardPanel:OnRelease()
end
-------------------- callback funcion --------------------
return CharFavourRewardPanel
