-- Panel 模板

local DailyInstanceLevelSelectPanel = class("DailyInstanceLevelSelectPanel", BasePanel)

-- Panel 定义
--[[
DailyInstanceLevelSelectPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
DailyInstanceLevelSelectPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
DailyInstanceLevelSelectPanel._bIsMainPanel = true
DailyInstanceLevelSelectPanel._bAddToBackHistory = true
DailyInstanceLevelSelectPanel._nSnapshotPrePanel = 0

DailyInstanceLevelSelectPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
DailyInstanceLevelSelectPanel._tbDefine = {
    {sPrefabPath = "DailyInstanceLevelSelect/DailyInstanceLevelSelectEx.prefab", sCtrlName = "Game.UI.DailyInstanceLevelSelect.DailyInstanceLevelSelectCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function DailyInstanceLevelSelectPanel:Awake()
end
function DailyInstanceLevelSelectPanel:OnEnable()
end
function DailyInstanceLevelSelectPanel:OnDisable()
end
function DailyInstanceLevelSelectPanel:OnDestroy()
end
function DailyInstanceLevelSelectPanel:OnRelease()
end
-------------------- callback function --------------------
return DailyInstanceLevelSelectPanel
