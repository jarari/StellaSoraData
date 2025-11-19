local CraftingPanel = class("CraftingPanel", BasePanel)
CraftingPanel._tbDefine = {
{sPrefabPath = "Crafting/CraftingPanel.prefab", sCtrlName = "Game.UI.Crafting.CraftingCtrl"}
}
CraftingPanel.Awake = function(self)
  -- function num : 0_0
end

CraftingPanel.OnEnable = function(self)
  -- function num : 0_1
end

CraftingPanel.OnDisable = function(self)
  -- function num : 0_2
end

CraftingPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return CraftingPanel

