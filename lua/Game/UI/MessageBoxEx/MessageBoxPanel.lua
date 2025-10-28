-- MessageBoxPanel Panel

local MessageBoxPanel = class("MessageBoxPanel", BasePanel)
-- Panel 定义





MessageBoxPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
MessageBoxPanel._bAddToBackHistory = false
--[[
MessageBoxPanel._bIsMainPanel = true
MessageBoxPanel._nSnapshotPrePanel = 0
]]
MessageBoxPanel._tbDefine = {
    {sPrefabPath = "MessageBoxEx/MessageBoxPanel.prefab", sCtrlName = "Game.UI.MessageBoxEx.MessageBoxCtrl"},
}

-------------------- local function --------------------
function MessageBoxPanel:SetTop(goCanvas)
    --[[ -- 比最下面的子节点高一层
    local nTopLayer = 0
    if nil ~= self.trUIRoot then
        local nChildCount = self.trUIRoot.childCount
        local trChild = self.trUIRoot:GetChild(nChildCount - 2) -- 除自己以外所以多减一
        nTopLayer = NovaAPI.GetCanvasSortingOrder(trChild:GetComponent("Canvas"))
    end
    if nTopLayer > 0 then
        NovaAPI.SetCanvasSortingOrder(goCanvas, nTopLayer + 1)
    end ]] -- 老夏，调整完排序，可以不需要了
end
-------------------- base function --------------------
function MessageBoxPanel:Awake()
    self.bBlur = true
    self.trUIRoot = GameObject.Find("---- UI TOP ----").transform
end
function MessageBoxPanel:OnEnable()
end
function MessageBoxPanel:OnDisable()
end
function MessageBoxPanel:OnDestroy()
end
-------------------- callback function --------------------
return MessageBoxPanel
