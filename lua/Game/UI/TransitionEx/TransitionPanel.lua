-- TransitionPanel
local TransitionPanel = class("TransitionPanel", BasePanel)
TransitionPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
TransitionPanel._bAddToBackHistory = false
-- Panel 定义
--[[
TransitionPanel._bIsMainPanel = true
TransitionPanel._nSnapshotPrePanel = 0
]]
TransitionPanel._tbDefine = {
    {sPrefabPath = "TransitionEx/TransitionPanel.prefab", sCtrlName = "Game.UI.TransitionEx.TransitionCtrl"},
}

function TransitionPanel:Awake()
    self.STATUS = AllEnum.TransitionStatus.OutAnimDone
end

function TransitionPanel:ChangeStatus(nStatus)
    self.STATUS = nStatus
end

function TransitionPanel:GetTransitionStatus()
    return self.STATUS
end

return TransitionPanel