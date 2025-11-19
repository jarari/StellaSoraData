local MainViewSidePanel = class("MainViewSidePanel", BasePanel)
MainViewSidePanel._nSnapshotPrePanel = 3
MainViewSidePanel._tbDefine = {
{sPrefabPath = "MainViewEx/MainViewSidePanel.prefab", sCtrlName = "Game.UI.MainViewEx.MainViewSideCtrl"}
}
MainViewSidePanel.Awake = function(self)
  -- function num : 0_0
end

MainViewSidePanel.OnEnable = function(self)
  -- function num : 0_1
end

MainViewSidePanel.OnDisable = function(self)
  -- function num : 0_2
end

MainViewSidePanel.OnDestroy = function(self)
  -- function num : 0_3
end

return MainViewSidePanel

