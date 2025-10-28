
local BasePanel = require "GameCore.UI.BasePanel"
local AffinityRewardPanel = class("AffinityRewardPanel", BasePanel)

-- Panel 定义
--[[
AffinityRewardPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
AffinityRewardPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
AffinityRewardPanel._bIsMainPanel = true
AffinityRewardPanel._bAddToBackHistory = true
AffinityRewardPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
AffinityRewardPanel._sSortingLayerName = SortingLayerName.UI
]]
AffinityRewardPanel._bIsMainPanel = false
AffinityRewardPanel._tbDefine = {
    {sPrefabPath = "StarTowerBook/NpcAffinityRewardPanel.prefab", sCtrlName = "Game.UI.StarTowerBook.Affinity.AffinityRewardCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function AffinityRewardPanel:Awake()
end
function AffinityRewardPanel:OnEnable()
end
function AffinityRewardPanel:OnDisable()
end
function AffinityRewardPanel:OnDestroy()
end
function AffinityRewardPanel:OnRelease()
end
-------------------- callback funcion --------------------
return AffinityRewardPanel
