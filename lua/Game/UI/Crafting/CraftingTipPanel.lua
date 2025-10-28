-- CraftingPanel Panel
local CraftingTipPanel = class("CraftingTipPanel", BasePanel)
CraftingTipPanel._bIsMainPanel = false

CraftingTipPanel._tbDefine = {
    {sPrefabPath = "Crafting/CraftingTipPanel.prefab", sCtrlName = "Game.UI.Crafting.CraftingTipCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function CraftingTipPanel:Awake()
end
function CraftingTipPanel:OnEnable()
end
function CraftingTipPanel:OnDisable()
end
function CraftingTipPanel:OnDestroy()
end
-------------------- callback function --------------------
return CraftingTipPanel
