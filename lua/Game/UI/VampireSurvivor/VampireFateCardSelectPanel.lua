-- Panel 模板

local VampireFateCardSelectPanel = class("VampireFateCardSelectPanel", BasePanel)

-- Panel 定义
--[[
VampireFateCardSelectPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
VampireFateCardSelectPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0

VampireFateCardSelectPanel._bAddToBackHistory = true
VampireFateCardSelectPanel._nSnapshotPrePanel = 0
VampireFateCardSelectPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
VampireFateCardSelectPanel._bIsMainPanel = false
VampireFateCardSelectPanel._bAddToBackHistory = false
VampireFateCardSelectPanel._tbDefine = {
    {sPrefabPath = "VampireBattle/VampireFateCardSelectPanel.prefab", sCtrlName = "Game.UI.VampireSurvivor.VampireFateCardSelect"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function VampireFateCardSelectPanel:Awake()
end
function VampireFateCardSelectPanel:OnEnable()
end
function VampireFateCardSelectPanel:OnAfterEnter()
end
function VampireFateCardSelectPanel:OnDisable()
end
function VampireFateCardSelectPanel:OnDestroy()
end
function VampireFateCardSelectPanel:OnRelease()
end
-------------------- callback function --------------------
return VampireFateCardSelectPanel
