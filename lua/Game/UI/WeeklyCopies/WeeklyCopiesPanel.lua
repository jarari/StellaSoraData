-- Panel 模板
local WeeklyCopiesPanel = class("WeeklyCopiesPanel", BasePanel)

-- Panel 定义
--[[
VampireLevelSelectPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
VampireLevelSelectPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
VampireLevelSelectPanel._bIsMainPanel = true
VampireLevelSelectPanel._bAddToBackHistory = true
VampireLevelSelectPanel._nSnapshotPrePanel = 0
VampireLevelSelectPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
WeeklyCopiesPanel._tbDefine = {
    {sPrefabPath = "WeeklyCopies/WeeklyCopiesPanel.prefab", sCtrlName = "Game.UI.WeeklyCopies.WeeklyCopiesCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function WeeklyCopiesPanel:Awake()
end
function WeeklyCopiesPanel:OnEnable()
end
function WeeklyCopiesPanel:OnAfterEnter()
end
function WeeklyCopiesPanel:OnDisable()
end
function WeeklyCopiesPanel:OnDestroy()
end
function WeeklyCopiesPanel:OnRelease()
end
-------------------- callback function --------------------
return WeeklyCopiesPanel
