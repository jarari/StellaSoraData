local BasePanel = require "GameCore.UI.BasePanel"
local ExChangePanel = class("ExChangePanel", BasePanel)

-- Panel 定义
ExChangePanel._bIsMainPanel = false
ExChangePanel._tbDefine = {
    {sPrefabPath = "ExChange/ExChangePanel.prefab", sCtrlName = "Game.UI.ExChange.ExChangeCtrl"}
}
-------------------- local funcion --------------------

-------------------- base funcion --------------------
function ExChangePanel:Awake()
end
function ExChangePanel:OnEnable()
end
function ExChangePanel:OnDisable()
end
function ExChangePanel:OnDestroy()
end
function ExChangePanel:OnRelease()
end
-------------------- callback funcion --------------------
return ExChangePanel
