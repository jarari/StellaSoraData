local MallPopupPanel = class("MallPopupPanel", BasePanel)
MallPopupPanel._bIsMainPanel = false
MallPopupPanel._tbDefine = {
{sPrefabPath = "Mall/MallPopupPanel.prefab", sCtrlName = "Game.UI.Mall.MallPopupCtrl"}
}
MallPopupPanel.Awake = function(self)
  -- function num : 0_0
end

MallPopupPanel.OnEnable = function(self)
  -- function num : 0_1
end

MallPopupPanel.OnDisable = function(self)
  -- function num : 0_2
end

MallPopupPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return MallPopupPanel

