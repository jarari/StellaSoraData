-- Panel 模板

local AchievementPanel = class("AchievementPanel", BasePanel)

-- Panel 定义
--[[
AchievementPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
AchievementPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
AchievementPanel._bIsMainPanel = true
AchievementPanel._bAddToBackHistory = true
AchievementPanel._nSnapshotPrePanel = 0
AchievementPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
AchievementPanel._tbDefine = {
    {sPrefabPath = "AchievementEx/AchievementPanel.prefab", sCtrlName = "Game.UI.AchievementEx.AchievementCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function AchievementPanel:Awake()
end
function AchievementPanel:OnEnable()
end
function AchievementPanel:OnAfterEnter()
end
function AchievementPanel:OnDisable()
end
function AchievementPanel:OnDestroy()
end
function AchievementPanel:OnRelease()
end
-------------------- callback function --------------------
return AchievementPanel
