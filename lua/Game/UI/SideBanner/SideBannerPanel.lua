-- SideBanner Panel

local SideBanner = class("SideBanner", BasePanel)
-- Panel 定义
SideBanner._sSortingLayerName = AllEnum.SortingLayerName.Overlay
SideBanner._bAddToBackHistory = false
SideBanner._tbDefine = {
    {sPrefabPath = "SideBanner/SideBannerPanel.prefab", sCtrlName = "Game.UI.SideBanner.SideBannerCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function SideBanner:Awake()
end
function SideBanner:OnEnable()
end
function SideBanner:OnDisable()
end
function SideBanner:OnDestroy()
end
-------------------- callback function --------------------
return SideBanner
