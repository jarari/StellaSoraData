-- Panel 模板

local RogueBossSelectPanel = class("RogueBossSelectPanel", BasePanel)

-- Panel 定义
--[[
RogueBossSelectPanel._bIsMainPanel = true
RogueBossSelectPanel._bAddToBackHistory = true
RogueBossSelectPanel._nSnapshotPrePanel = 0

RogueBossSelectPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
RogueBossSelectPanel._tbDefine = {
    {sPrefabPath = "FRLevelSelectEx/RogueBossSelect.prefab", sCtrlName = "Game.UI.FixedRoguelikeLevelSelectEx.RogueBossSelectCtrl"},
}
-------------------- local function --------------------

-------------------- base function --------------------
function RogueBossSelectPanel:Awake()
end
function RogueBossSelectPanel:OnEnable()
end
function RogueBossSelectPanel:OnDisable()
end
function RogueBossSelectPanel:OnDestroy()
end
function RogueBossSelectPanel:OnRelease()
end
-------------------- callback function --------------------
return RogueBossSelectPanel
