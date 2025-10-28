-- Panel 模板

local RoguelikeResultPanel = class("RoguelikeResultPanel", BasePanel)

-- Panel 定义
--[[
RoguelikeResultPanel._bIsMainPanel = true
RoguelikeResultPanel._bAddToBackHistory = true
RoguelikeResultPanel._nSnapshotPrePanel = 0

RoguelikeResultPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
RoguelikeResultPanel._bAddToBackHistory = false
RoguelikeResultPanel._tbDefine = {
    {sPrefabPath = "RoguelikeResultPanel/RoguelikeResult.prefab", sCtrlName = "Game.UI.RoguelikeResultPanel.RoguelikeResultCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function RoguelikeResultPanel:Awake()
end
function RoguelikeResultPanel:OnEnable()
end
function RoguelikeResultPanel:OnDisable()
end
function RoguelikeResultPanel:OnDestroy()
end
-------------------- callback function --------------------
return RoguelikeResultPanel
