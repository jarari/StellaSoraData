-- Panel 模板

local FixedRoguelikeLevelSelectPanel = class("FixedRoguelikeLevelSelectPanel", BasePanel)

-- Panel 定义
--[[
FixedRoguelikeLevelSelectPanel._bIsMainPanel = true
FixedRoguelikeLevelSelectPanel._bAddToBackHistory = true
FixedRoguelikeLevelSelectPanel._nSnapshotPrePanel = 0

FixedRoguelikeLevelSelectPanel._sSortingLayerName = AllEnum.SortingLayerName.UI
]]
FixedRoguelikeLevelSelectPanel._tbDefine = {
    {sPrefabPath = "FRLevelSelectEx/RoguelikeLevelSelect.prefab", sCtrlName = "Game.UI.FixedRoguelikeLevelSelectEx.FixedRoguelikeLevelCtrl"},
}
-------------------- local function --------------------

-------------------- base function --------------------
function FixedRoguelikeLevelSelectPanel:Awake()
end
function FixedRoguelikeLevelSelectPanel:OnEnable()
end
function FixedRoguelikeLevelSelectPanel:OnDisable()
end
function FixedRoguelikeLevelSelectPanel:OnDestroy()
end
function FixedRoguelikeLevelSelectPanel:OnRelease()
end
function FixedRoguelikeLevelSelectPanel:OnAfterEnter()
    local function wait()
        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
        PopUpManager.OpenPopUpPanelByType(GameEnum.PopUpSeqType.FuncUnlock)
    end
    cs_coroutine.start(wait)
end
-------------------- callback function --------------------
return FixedRoguelikeLevelSelectPanel
