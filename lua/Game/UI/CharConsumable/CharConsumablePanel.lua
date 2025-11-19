local CharConsumablePanel = class("CharConsumablePanel", BasePanel)
CharConsumablePanel._bIsMainPanel = false
CharConsumablePanel._tbDefine = {
{sPrefabPath = "CharConsumablePanel/CharConsumablePanel.prefab", sCtrlName = "Game.UI.CharConsumable.CharConsumableCtrl"}
}
CharConsumablePanel.Awake = function(self)
  -- function num : 0_0
end

CharConsumablePanel.OnEnable = function(self)
  -- function num : 0_1
end

CharConsumablePanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

CharConsumablePanel.OnDisable = function(self)
  -- function num : 0_3
end

CharConsumablePanel.OnDestroy = function(self)
  -- function num : 0_4
end

CharConsumablePanel.OnRelease = function(self)
  -- function num : 0_5
end

return CharConsumablePanel

