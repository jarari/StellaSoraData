local FriendCartePanel = class("FriendCartePanel", BasePanel)
FriendCartePanel._bIsMainPanel = false
FriendCartePanel._tbDefine = {
{sPrefabPath = "FriendEx/FriendCartePanel.prefab", sCtrlName = "Game.UI.FriendEx.FriendCarteCtrl"}
}
FriendCartePanel.Awake = function(self)
  -- function num : 0_0
end

FriendCartePanel.OnEnable = function(self)
  -- function num : 0_1
end

FriendCartePanel.OnDisable = function(self)
  -- function num : 0_2
end

FriendCartePanel.OnDestroy = function(self)
  -- function num : 0_3
end

return FriendCartePanel

