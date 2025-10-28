local BasePanel = require "GameCore.UI.BasePanel"
local CharShardsConvertPanel = class("CharShardsConvertPanel", BasePanel)

-- Panel 定义
--[[
CharShardsConvertPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharShardsConvertPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
CharShardsConvertPanel._bIsMainPanel = true
CharShardsConvertPanel._bAddToBackHistory = true
CharShardsConvertPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
CharShardsConvertPanel._sSortingLayerName = SortingLayerName.UI
]]
CharShardsConvertPanel._bIsMainPanel = false
CharShardsConvertPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
CharShardsConvertPanel._tbDefine = {
    {sPrefabPath = "Mall/CharShardsConvertPanel.prefab", sCtrlName = "Game.UI.Mall.CharShardsConvertCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function CharShardsConvertPanel:Awake()
end
function CharShardsConvertPanel:OnEnable()
end
function CharShardsConvertPanel:OnDisable()
end
function CharShardsConvertPanel:OnDestroy()
end
function CharShardsConvertPanel:OnRelease()
end
-------------------- callback funcion --------------------
return CharShardsConvertPanel
