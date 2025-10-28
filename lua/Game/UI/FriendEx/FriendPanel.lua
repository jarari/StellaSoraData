-- FriendPanel Panel

local FriendPanel = class("FriendPanel", BasePanel)
-- Panel 定义
FriendPanel._tbDefine = {
    {sPrefabPath = "FriendEx/FriendPanel.prefab", sCtrlName = "Game.UI.FriendEx.FriendCtrl"},
}
-------------------- base function --------------------
function FriendPanel:Awake()
    self.tbAddCache = {}
end
function FriendPanel:OnEnable()
end
function FriendPanel:OnDisable()
end
function FriendPanel:OnDestroy()
end
-------------------- callback function --------------------
return FriendPanel
