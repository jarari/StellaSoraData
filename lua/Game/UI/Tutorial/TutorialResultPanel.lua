-- Panel 模板

local TutorialResultPanel = class("TutorialResultPanel", BasePanel)
TutorialResultPanel._bAddToBackHistory = false
-- Panel 定义
--[[
TutorialResultPanel._nFADEINTYPE = 1 -- (0:第一次进入动画,1:重复播进入动画,2:不播进入动画)
TutorialResultPanel._nFadeInType = 1 -- 如果有初次入场动画需求，则配置0
TutorialResultPanel._bIsMainPanel = true
TutorialResultPanel._bAddToBackHistory = true
TutorialResultPanel._nSnapshotPrePanel = 0
TutorialResultPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
TutorialResultPanel._tbDefine = {
    {sPrefabPath = "Tutorial/TutorialResultPanel.prefab", sCtrlName = "Game.UI.Tutorial.TutorialResultCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function TutorialResultPanel:Awake()
end
function TutorialResultPanel:OnEnable()
end
function TutorialResultPanel:OnAfterEnter()
end
function TutorialResultPanel:OnDisable()
end
function TutorialResultPanel:OnDestroy()
end
function TutorialResultPanel:OnRelease()
end
-------------------- callback function --------------------
return TutorialResultPanel
