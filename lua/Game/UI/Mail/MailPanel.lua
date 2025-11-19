local MailPanel = class("MailPanel", BasePanel)
MailPanel._tbDefine = {
{sPrefabPath = "Mail/MailPanel.prefab", sCtrlName = "Game.UI.Mail.MailCtrl"}
}
MailPanel.Awake = function(self)
  -- function num : 0_0
end

MailPanel.OnEnable = function(self)
  -- function num : 0_1
end

MailPanel.OnDisable = function(self)
  -- function num : 0_2
end

MailPanel.OnDestroy = function(self)
  -- function num : 0_3
end

return MailPanel

