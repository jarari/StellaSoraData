-- DiscPreviewPanel Panel

local DiscPreviewPanel = class("DiscPreviewPanel", BasePanel)
-- Panel 定义
DiscPreviewPanel._bIsMainPanel = false
DiscPreviewPanel._tbDefine = {
    {sPrefabPath = "DiscSkill/DiscPreviewPanel.prefab", sCtrlName = "Game.UI.DiscSkill.DiscPreviewCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function DiscPreviewPanel:Awake()
end
function DiscPreviewPanel:OnEnable()
end
function DiscPreviewPanel:OnDisable()
end
function DiscPreviewPanel:OnDestroy()
end
-------------------- callback function --------------------
return DiscPreviewPanel
