local CraftingTipPanel = class("CraftingTipPanel", BasePanel)
CraftingTipPanel._bIsMainPanel = false
CraftingTipPanel._tbDefine = {
{sPrefabPath = "Crafting/CraftingTipPanel.prefab", sCtrlName = "Game.UI.Crafting.CraftingTipCtrl"}
}
CraftingTipPanel.Awake = function(self)
  -- function num : 0_0
end

CraftingTipPanel.OnEnable = function(self)
  -- function num : 0_1
end

CraftingTipPanel.OnDisable = function(self)
  -- function num : 0_2
end

CraftingTipPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return CraftingTipPanel

