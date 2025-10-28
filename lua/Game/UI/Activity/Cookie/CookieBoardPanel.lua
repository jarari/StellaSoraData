-- Panel 模板

local CookieBoardPanel = class("CookieBoardPanel", BasePanel)
-- Panel 定义
CookieBoardPanel._bIsMainPanel = true
CookieBoardPanel._tbDefine = {
    {sPrefabPath = "Activity/Cookie/CookieBoardPanel.prefab", sCtrlName = "Game.UI.Activity.Cookie.CookieBoardCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function CookieBoardPanel:Awake()
    -- self.nActId = nil
    -- self.actData = nil
end
function CookieBoardPanel:OnEnable()
end
function CookieBoardPanel:OnAfterEnter()
end
function CookieBoardPanel:OnDisable()
end
function CookieBoardPanel:OnDestroy()
end
function CookieBoardPanel:OnRelease()
end
-------------------- callback function --------------------
return CookieBoardPanel
