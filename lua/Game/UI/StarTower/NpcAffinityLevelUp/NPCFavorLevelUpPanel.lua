local BasePanel = require "GameCore.UI.BasePanel"
local NPCFavorLevelUpPanel = class("NPCFavorLevelUpPanel", BasePanel)

-- Panel 定义
--[[
NPCFavorLevelUpPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
NPCFavorLevelUpPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
NPCFavorLevelUpPanel._bIsMainPanel = true
NPCFavorLevelUpPanel._bAddToBackHistory = true
NPCFavorLevelUpPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
NPCFavorLevelUpPanel._sSortingLayerName = SortingLayerName.UI
]]
NPCFavorLevelUpPanel._bIsMainPanel = false
NPCFavorLevelUpPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
NPCFavorLevelUpPanel._tbDefine = {
    {sPrefabPath = "StarTower/NPCFavourLevelUpPanel.prefab", sCtrlName = "Game.UI.StarTower.NpcAffinityLevelUp.NPCFavorLevelUpCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function NPCFavorLevelUpPanel:Awake()
end
function NPCFavorLevelUpPanel:OnEnable()
end
function NPCFavorLevelUpPanel:OnDisable()
end
function NPCFavorLevelUpPanel:OnDestroy()
end
function NPCFavorLevelUpPanel:OnRelease()
end
-------------------- callback funcion --------------------
return NPCFavorLevelUpPanel
