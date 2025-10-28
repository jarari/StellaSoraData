-- DiscSamplePanel Panel

local DiscSamplePanel = class("DiscSamplePanel", BasePanel)

DiscSamplePanel._bIsMainPanel = false
DiscSamplePanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
DiscSamplePanel._tbDefine = {
    {sPrefabPath = "Disc/DiscSamplePanel.prefab", sCtrlName = "Game.UI.Disc.DiscSampleCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function DiscSamplePanel:Awake()
end
function DiscSamplePanel:OnEnable()
end
function DiscSamplePanel:OnDisable()
end
function DiscSamplePanel:OnDestroy()
end
-------------------- callback function --------------------
return DiscSamplePanel
