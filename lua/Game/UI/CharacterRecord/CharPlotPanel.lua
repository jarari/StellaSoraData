local BasePanel = require "GameCore.UI.BasePanel"
local CharPlotPanel = class("CharPlotPanel", BasePanel)

-- Panel 定义
--[[
CharPlotPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
CharPlotPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
CharPlotPanel._bAddToBackHistory = true
CharPlotPanel._nSnapshotPrePanel = 0
local SortingLayerName = require "GameCore.UI.SortingLayerName"
]]
CharPlotPanel._bIsMainPanel = false
CharPlotPanel._tbDefine = {
    {sPrefabPath = "CharacterInfoEx/CharPlotPanel.prefab", sCtrlName = "Game.UI.CharacterRecord.CharPlotCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function CharPlotPanel:Awake()
end
function CharPlotPanel:OnEnable()
end
function CharPlotPanel:OnDisable()
end
function CharPlotPanel:OnDestroy()
end
function CharPlotPanel:OnRelease()
end
-------------------- callback funcion --------------------
return CharPlotPanel
