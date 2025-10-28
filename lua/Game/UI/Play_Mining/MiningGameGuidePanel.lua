-- Panel 模板

local MiningGameGuidePanel = class("MiningGameGuidePanel", BasePanel)

-- Panel 定义
--[[
MiningGameGuidePanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
MiningGameGuidePanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
MiningGameGuidePanel._bIsMainPanel = true
MiningGameGuidePanel._bAddToBackHistory = true
MiningGameGuidePanel._nSnapshotPrePanel = 0
MiningGameGuidePanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
MiningGameGuidePanel._tbDefine = {
    {sPrefabPath = "Play_Mining/MiningGameGuidePanel.prefab", sCtrlName = "Game.UI.Play_Mining.MiningGameGuideCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function MiningGameGuidePanel:Awake()
end
function MiningGameGuidePanel:OnEnable()
end
function MiningGameGuidePanel:OnAfterEnter()
end
function MiningGameGuidePanel:OnDisable()
end
function MiningGameGuidePanel:OnDestroy()
end
function MiningGameGuidePanel:OnRelease()
end
-------------------- callback function --------------------
return MiningGameGuidePanel
