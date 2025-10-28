-- Panel 模板

local CookieGamePanel = class("CookieGamePanel", BasePanel)
-- Panel 定义
CookieGamePanel._bIsMainPanel = true
CookieGamePanel._tbDefine = {
    {sPrefabPath = "Activity/Cookie/CookieGamePanel.prefab", sCtrlName = "Game.UI.Activity.Cookie.CookieGameCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function CookieGamePanel:Awake()
    -- self.nActId = nil
    -- self.actData = nil
end
function CookieGamePanel:OnEnable()
end
function CookieGamePanel:OnAfterEnter()
end
function CookieGamePanel:OnDisable()
end
function CookieGamePanel:OnDestroy()
end
function CookieGamePanel:OnRelease()
end
-------------------- callback function --------------------
return CookieGamePanel
