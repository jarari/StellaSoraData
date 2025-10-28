-- Panel 模板

local PerkTipsPanel = class("PerkTipsPanel", BasePanel)
PerkTipsPanel._bIsMainPanel = false
PerkTipsPanel._bAddToBackHistory = false

PerkTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
-- Panel 定义
--[[
PerkTipsPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
PerkTipsPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
PerkTipsPanel._bIsMainPanel = true
PerkTipsPanel._bAddToBackHistory = true
PerkTipsPanel._nSnapshotPrePanel = 0

PerkTipsPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
PerkTipsPanel._tbDefine = {
    {sPrefabPath = "CommonTipsEx/PerkTips.prefab", sCtrlName = "Game.UI.CommonTipsEx.PerkTipsCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function PerkTipsPanel:Awake()
end
function PerkTipsPanel:OnEnable()
end
function PerkTipsPanel:OnDisable()
end
function PerkTipsPanel:OnDestroy()
end
function PerkTipsPanel:OnRelease()
end
-------------------- callback function --------------------
return PerkTipsPanel
