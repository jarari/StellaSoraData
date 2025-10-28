-- Panel 模板

local TravelerDuelRankUploadSuccessPanel = class("TravelerDuelRankUploadSuccessPanel", BasePanel)

-- Panel 定义
--[[
TravelerDuelRankUploadSuccessPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
TravelerDuelRankUploadSuccessPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
TravelerDuelRankUploadSuccessPanel._bIsMainPanel = true
TravelerDuelRankUploadSuccessPanel._bAddToBackHistory = true
TravelerDuelRankUploadSuccessPanel._nSnapshotPrePanel = 0
TravelerDuelRankUploadSuccessPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
TravelerDuelRankUploadSuccessPanel._bIsMainPanel = false
TravelerDuelRankUploadSuccessPanel._tbDefine = {
    {sPrefabPath = "TravelerDuelLevelSelect/TDUploadSuccessPanel.prefab", sCtrlName = "Game.UI.TravelerDuelLevelSelect.TravelerDuelRanking.TravelerDuelRankUploadSuccessCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function TravelerDuelRankUploadSuccessPanel:Awake()
end
function TravelerDuelRankUploadSuccessPanel:OnEnable()
end
function TravelerDuelRankUploadSuccessPanel:OnAfterEnter()
end
function TravelerDuelRankUploadSuccessPanel:OnDisable()
end
function TravelerDuelRankUploadSuccessPanel:OnDestroy()
end
function TravelerDuelRankUploadSuccessPanel:OnRelease()
end
-------------------- callback function --------------------
return TravelerDuelRankUploadSuccessPanel
