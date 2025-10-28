local GameResourceLoader = require "Game.Common.Resource.GameResourceLoader"
local DatingPanel = class("DatingPanel", BasePanel)
DatingPanel._tbDefine = {
    {sPrefabPath = "Phone/DatingPanel.prefab", sCtrlName = "Game.UI.Phone.Dating.DatingCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function DatingPanel:Awake()
end
function DatingPanel:OnEnable()
end
function DatingPanel:OnAfterEnter()
end
function DatingPanel:OnDisable()
end
function DatingPanel:OnDestroy()
    -- 卸载AVG资源
    GameResourceLoader.Unload("ImageAvg")
end
function DatingPanel:OnRelease()
end
-------------------- callback function --------------------
return DatingPanel
