-- Panel 模板

local TravelerDuelLevelPanel = class("TravelerDuelLevelPanel", BasePanel)

-- Panel 定义
--[[
TravelerDuelLevelPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
TravelerDuelLevelPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
TravelerDuelLevelPanel._bIsMainPanel = true
TravelerDuelLevelPanel._bAddToBackHistory = true
TravelerDuelLevelPanel._nSnapshotPrePanel = 0

TravelerDuelLevelPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
TravelerDuelLevelPanel._tbDefine = {
    {sPrefabPath = "TravelerDuelLevelSelect/TravelerDuelLevelPanel.prefab", sCtrlName = "Game.UI.TravelerDuelLevelSelect.TravelerDuelLevelSelectCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function TravelerDuelLevelPanel:Awake()
end
function TravelerDuelLevelPanel:OnEnable()
end
function TravelerDuelLevelPanel:OnDisable()
end
function TravelerDuelLevelPanel:OnDestroy()
end
function TravelerDuelLevelPanel:OnRelease()
end
-------------------- callback function --------------------
return TravelerDuelLevelPanel
