
local DepotPanel = class("DepotPanel", BasePanel)

-- Panel 定义
--[[
DepotPanel._bIsMainPanel = true
DepotPanel._bAddToBackHistory = true
DepotPanel._nSnapshotPrePanel = 0

DepotPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
DepotPanel._bAddToBackHistory = true
DepotPanel._tbDefine = {
    {sPrefabPath = "DepotEx/DepotPanel.prefab", sCtrlName = "Game.UI.DepotEx.DepotCtrl"},
}
-------------------- local function --------------------

-------------------- base function --------------------

-------------------- callback function --------------------
return DepotPanel