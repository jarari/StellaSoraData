local ReceivePropsPanel = class("ReceivePropsPanel", BasePanel)
ReceivePropsPanel._bIsMainPanel = false
ReceivePropsPanel._tbDefine = {
{sPrefabPath = "ReceivePropsEx/ReceivePropsPanel.prefab", sCtrlName = "Game.UI.ReceivePropsEx.ReceivePropsCtrl"}
}
ReceivePropsPanel.Awake = function(self)
  -- function num : 0_0
end

ReceivePropsPanel.OnEnable = function(self)
  -- function num : 0_1
end

ReceivePropsPanel.OnDisable = function(self)
  -- function num : 0_2
end

ReceivePropsPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return ReceivePropsPanel

