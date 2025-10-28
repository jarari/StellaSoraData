-- Panel 模板

local LoginRewardPopUpPanel = class("LoginRewardPopUpPanel", BasePanel)
-- Panel 定义
LoginRewardPopUpPanel._bIsMainPanel = false
LoginRewardPopUpPanel._tbDefine = {
    {sPrefabPath = "LoginRewardPopUp/LoginRewardPopUpPanel.prefab", sCtrlName = "Game.UI.Activity.LoginReward.LoginRewardPopUpCtrl"}
}
-------------------- local function --------------------

-------------------- base function --------------------
function LoginRewardPopUpPanel:Awake()
    self.nActId = nil
    self.actData = nil
end
function LoginRewardPopUpPanel:OnEnable()
end
function LoginRewardPopUpPanel:OnAfterEnter()
end
function LoginRewardPopUpPanel:OnDisable()
end
function LoginRewardPopUpPanel:OnDestroy()
end
function LoginRewardPopUpPanel:OnRelease()
end
-------------------- callback function --------------------
return LoginRewardPopUpPanel
