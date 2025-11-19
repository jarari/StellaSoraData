local LoginRewardPopUpPanel = class("LoginRewardPopUpPanel", BasePanel)
LoginRewardPopUpPanel._bIsMainPanel = false
LoginRewardPopUpPanel._tbDefine = {
{sPrefabPath = "LoginRewardPopUp/LoginRewardPopUpPanel.prefab", sCtrlName = "Game.UI.Activity.LoginReward.LoginRewardPopUpCtrl"}
}
LoginRewardPopUpPanel.Awake = function(self)
  -- function num : 0_0
  self.nActId = nil
  self.actData = nil
end

LoginRewardPopUpPanel.OnEnable = function(self)
  -- function num : 0_1
end

LoginRewardPopUpPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

LoginRewardPopUpPanel.OnDisable = function(self)
  -- function num : 0_3
end

LoginRewardPopUpPanel.OnDestroy = function(self)
  -- function num : 0_4
end

LoginRewardPopUpPanel.OnRelease = function(self)
  -- function num : 0_5
end

return LoginRewardPopUpPanel

