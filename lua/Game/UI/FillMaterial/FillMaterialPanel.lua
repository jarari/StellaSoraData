-- FillMaterialPanel Panel

local FillMaterialPanel = class("FillMaterialPanel", BasePanel)
-- Panel 定义
FillMaterialPanel._bIsMainPanel = false
FillMaterialPanel._tbDefine = {
    {sPrefabPath = "FillMaterial/FillMaterialPanel.prefab", sCtrlName = "Game.UI.FillMaterial.FillMaterialCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function FillMaterialPanel:Awake()
end
function FillMaterialPanel:OnEnable()
end
function FillMaterialPanel:OnDisable()
end
function FillMaterialPanel:OnDestroy()
end
-------------------- callback function --------------------
return FillMaterialPanel
