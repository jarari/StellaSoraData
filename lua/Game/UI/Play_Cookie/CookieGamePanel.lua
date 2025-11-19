local CookieGamePanel = class("CookieGamePanel", BasePanel)
CookieGamePanel._bIsMainPanel = true
CookieGamePanel._tbDefine = {
{sPrefabPath = "Play_Cookie/CookieGamePanel.prefab", sCtrlName = "Game.UI.Play_Cookie.CookieGameCtrl"}
}
CookieGamePanel.Awake = function(self)
  -- function num : 0_0
end

CookieGamePanel.OnEnable = function(self)
  -- function num : 0_1
end

CookieGamePanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

CookieGamePanel.OnDisable = function(self)
  -- function num : 0_3
end

CookieGamePanel.OnDestroy = function(self)
  -- function num : 0_4
end

CookieGamePanel.OnRelease = function(self)
  -- function num : 0_5
end

return CookieGamePanel

