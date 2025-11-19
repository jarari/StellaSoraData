local ConsumablePanel = class("ConsumablePanel", BasePanel)
ConsumablePanel._bIsMainPanel = false
ConsumablePanel._tbDefine = {
{sPrefabPath = "ConsumablesPanel/ConsumablesPanel.prefab", sCtrlName = "Game.UI.Consumable.ConsumableCtrl"}
}
ConsumablePanel.Awake = function(self)
  -- function num : 0_0
end

ConsumablePanel.OnEnable = function(self)
  -- function num : 0_1
end

ConsumablePanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

ConsumablePanel.OnDisable = function(self)
  -- function num : 0_3
end

ConsumablePanel.OnDestroy = function(self)
  -- function num : 0_4
end

ConsumablePanel.OnRelease = function(self)
  -- function num : 0_5
end

return ConsumablePanel

