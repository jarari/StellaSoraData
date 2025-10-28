-- PotentialDetailPanel Panel

local PotentialDetailPanel = class("PotentialDetailPanel", BasePanel)
-- Panel 定义
PotentialDetailPanel._bIsMainPanel = false
PotentialDetailPanel._bAddToBackHistory = false
PotentialDetailPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
PotentialDetailPanel._tbDefine = {
    {sPrefabPath = "PotentialDetail/PotentialDetailPanel.prefab", sCtrlName = "Game.UI.PotentialDetail.PotentialDetailCtrl"},
}
-------------------- local function --------------------
-------------------- base function --------------------
function PotentialDetailPanel:Awake()
end
function PotentialDetailPanel:OnEnable()
end
function PotentialDetailPanel:OnDisable()
end
function PotentialDetailPanel:OnDestroy()
end
-------------------- callback function --------------------
return PotentialDetailPanel
