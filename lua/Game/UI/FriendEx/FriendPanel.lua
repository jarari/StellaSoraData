local FriendPanel = class("FriendPanel", BasePanel)
FriendPanel._tbDefine = {
{sPrefabPath = "FriendEx/FriendPanel.prefab", sCtrlName = "Game.UI.FriendEx.FriendCtrl"}
}
FriendPanel.Awake = function(self)
  -- function num : 0_0
  self.tbAddCache = {}
end

FriendPanel.OnEnable = function(self)
  -- function num : 0_1
end

FriendPanel.OnDisable = function(self)
  -- function num : 0_2
end

FriendPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return FriendPanel

