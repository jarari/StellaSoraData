local DiscPreviewPanel = class("DiscPreviewPanel", BasePanel)
DiscPreviewPanel._bIsMainPanel = false
DiscPreviewPanel._tbDefine = {
{sPrefabPath = "DiscSkill/DiscPreviewPanel.prefab", sCtrlName = "Game.UI.DiscSkill.DiscPreviewCtrl"}
}
DiscPreviewPanel.Awake = function(self)
  -- function num : 0_0
end

DiscPreviewPanel.OnEnable = function(self)
  -- function num : 0_1
end

DiscPreviewPanel.OnDisable = function(self)
  -- function num : 0_2
end

DiscPreviewPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return DiscPreviewPanel

