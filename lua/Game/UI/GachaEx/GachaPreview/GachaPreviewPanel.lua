local GachaPreviewPanel = class("GachaPreviewPanel", BasePanel)
GachaPreviewPanel._bIsMainPanel = false
GachaPreviewPanel._tbDefine = {
{sPrefabPath = "GachaEx/GachaCharInfoPanel.prefab", sCtrlName = "Game.UI.GachaEx.GachaPreview.GachaPreviewCtrl"}
}
GachaPreviewPanel.Awake = function(self)
  -- function num : 0_0
end

GachaPreviewPanel.OnEnable = function(self)
  -- function num : 0_1
end

GachaPreviewPanel.OnDisable = function(self)
  -- function num : 0_2
end

GachaPreviewPanel.OnDestroy = function(self)
  -- function num : 0_3
end

GachaPreviewPanel.OnRelease = function(self)
  -- function num : 0_4
end

return GachaPreviewPanel

