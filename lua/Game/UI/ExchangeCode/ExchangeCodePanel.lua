local BasePanel = require "GameCore.UI.BasePanel"
local ExchangeCodePanel = class("ExchangeCodePanel", BasePanel)

-- Panel 定义
ExchangeCodePanel._bIsMainPanel = false
-- ExchangeCodePanel._nSnapshotPrePanel=1
ExchangeCodePanel._sSortingLayerName=AllEnum.SortingLayerName.UI

ExchangeCodePanel._tbDefine = {
    {sPrefabPath = "ExchangeCode/ExchangeCodePanel.prefab", sCtrlName = "Game.UI.ExchangeCode.ExchangeCodeCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function ExchangeCodePanel:Awake()
end
function ExchangeCodePanel:OnEnable()
end
function ExchangeCodePanel:OnDisable()
end
function ExchangeCodePanel:OnDestroy()
end
function ExchangeCodePanel:OnRelease()
end
-------------------- callback funcion --------------------
return ExchangeCodePanel
