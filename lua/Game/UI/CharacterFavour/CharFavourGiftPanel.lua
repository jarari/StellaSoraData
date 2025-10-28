local BasePanel = require "GameCore.UI.BasePanel"
local CharFavourGiftPanel = class("CharFavourGiftPanel", BasePanel)

-- Panel 定义
--[[
CharFavourGiftPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharFavourGiftPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
CharFavourGiftPanel._bIsMainPanel = true
CharFavourGiftPanel._bAddToBackHistory = true
CharFavourGiftPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
CharFavourGiftPanel._sSortingLayerName = SortingLayerName.UI
]]
CharFavourGiftPanel._tbDefine = {
    {sPrefabPath = "CharacterFavour/CharFavourGiftPanel.prefab", sCtrlName = "Game.UI.CharacterFavour.CharFavourGiftCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function CharFavourGiftPanel:Awake()
end
function CharFavourGiftPanel:OnEnable()
end
function CharFavourGiftPanel:OnDisable()
end
function CharFavourGiftPanel:OnDestroy()
end
function CharFavourGiftPanel:OnRelease()
end
-------------------- callback funcion --------------------
return CharFavourGiftPanel
