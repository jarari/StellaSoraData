-- FriendCartePanel Panel

local FriendCartePanel = class("FriendCartePanel", BasePanel)
-- Panel 定义
FriendCartePanel._bIsMainPanel = false
--[[
FriendCartePanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
FriendCartePanel._bAddToBackHistory = false
FriendCartePanel._bIsMainPanel = true
FriendCartePanel._nSnapshotPrePanel = 0
]]
FriendCartePanel._tbDefine = {
    {sPrefabPath = "FriendEx/FriendCartePanel.prefab", sCtrlName = "Game.UI.FriendEx.FriendCarteCtrl"},
}
-------------------- base function --------------------
function FriendCartePanel:Awake()
end
function FriendCartePanel:OnEnable()
end
function FriendCartePanel:OnDisable()
end
function FriendCartePanel:OnDestroy()
end
-------------------- callback function --------------------
return FriendCartePanel
