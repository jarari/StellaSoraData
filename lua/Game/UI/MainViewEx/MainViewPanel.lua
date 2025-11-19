local MainViewPanel = class("MainViewPanel", BasePanel)
MainViewPanel._nFadeInType = 0
MainViewPanel._tbDefine = {
{sPrefabPath = "MainViewEx/MainViewPanel.prefab", sCtrlName = "Game.UI.MainViewEx.MainViewCtrl"}
}
MainViewPanel.OnAfterEnter = function(self)
  -- function num : 0_0
end

return MainViewPanel

