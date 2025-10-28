-- CraftingPanel Panel
local CraftingPanel = class("CraftingPanel", BasePanel)
CraftingPanel._tbDefine = {
    {sPrefabPath = "Crafting/CraftingPanel.prefab", sCtrlName = "Game.UI.Crafting.CraftingCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function CraftingPanel:Awake()
end
function CraftingPanel:OnEnable()
end
function CraftingPanel:OnDisable()
end
function CraftingPanel:OnDestroy()
end
-------------------- callback function --------------------
return CraftingPanel
