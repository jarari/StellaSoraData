-- Panel 模板

local VampireLevelSelectPanel = class("VampireLevelSelectPanel", BasePanel)

-- Panel 定义
--[[
VampireLevelSelectPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
VampireLevelSelectPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
VampireLevelSelectPanel._bIsMainPanel = true
VampireLevelSelectPanel._bAddToBackHistory = true
VampireLevelSelectPanel._nSnapshotPrePanel = 0
VampireLevelSelectPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
VampireLevelSelectPanel._tbDefine = {
    {sPrefabPath = "VampireLevelSelect/VampireLevelSelectPanel.prefab", sCtrlName = "Game.UI.VampireLevelSelect.VampireLevelSelectCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function VampireLevelSelectPanel:Awake()
end
function VampireLevelSelectPanel:OnEnable()
end
function VampireLevelSelectPanel:OnAfterEnter()
end
function VampireLevelSelectPanel:OnDisable()
end
function VampireLevelSelectPanel:OnDestroy()
end
function VampireLevelSelectPanel:OnRelease()
end
-------------------- callback function --------------------
return VampireLevelSelectPanel
