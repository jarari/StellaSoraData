local LampNoticePanel = class("LampNoticePanel", BasePanel)
LampNoticePanel._bIsMainPanel = false
LampNoticePanel._sSortingLayerName = (AllEnum.SortingLayerName).Overlay
LampNoticePanel._tbDefine = {
{sPrefabPath = "LampNotice/LampNoticePanel.prefab", sCtrlName = "Game.UI.LampNotice.LampNoticeCtrl"}
}
LampNoticePanel.Awake = function(self)
  -- function num : 0_0
end

LampNoticePanel.OnEnable = function(self)
  -- function num : 0_1
end

LampNoticePanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

LampNoticePanel.OnDisable = function(self)
  -- function num : 0_3
end

LampNoticePanel.OnDestroy = function(self)
  -- function num : 0_4
end

LampNoticePanel.OnRelease = function(self)
  -- function num : 0_5
end

return LampNoticePanel

