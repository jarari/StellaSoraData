local CookieBoardPanel = class("CookieBoardPanel", BasePanel)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
CookieBoardPanel._bIsMainPanel = true
CookieBoardPanel._tbDefine = {
{sPrefabPath = "Play_Cookie/CookieBoardPanel.prefab", sCtrlName = "Game.UI.Play_Cookie.CookieBoardCtrl"}
}
CookieBoardPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : GamepadUIManager
  (GamepadUIManager.EnterAdventure)(true)
end

CookieBoardPanel.OnEnable = function(self)
  -- function num : 0_1
end

CookieBoardPanel.OnAfterEnter = function(self)
  -- function num : 0_2
end

CookieBoardPanel.OnDisable = function(self)
  -- function num : 0_3
end

CookieBoardPanel.OnDestroy = function(self)
  -- function num : 0_4 , upvalues : GamepadUIManager
  (GamepadUIManager.QuitAdventure)()
end

CookieBoardPanel.OnRelease = function(self)
  -- function num : 0_5
end

return CookieBoardPanel

