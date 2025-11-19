local FormationPanel = class("FormationPanel", BasePanel)
FormationPanel._tbDefine = {
{sPrefabPath = "MainlineFormationEx/MainlineFormationScenePanel.prefab", sCtrlName = "Game.UI.FormationEx.FormationCtrl"}
}
FormationPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  (EventManager.Add)("EnterModule", self, self.OnEvent_EnterModule)
end

FormationPanel.OnEnable = function(self, bPlayFadeIn)
  -- function num : 0_1
end

FormationPanel.OnDisable = function(self)
  -- function num : 0_2
end

FormationPanel.OnDestroy = function(self)
  -- function num : 0_3 , upvalues : _ENV
  (EventManager.Remove)("EnterModule", self, self.OnEvent_EnterModule)
end

FormationPanel.OnEvent_EnterModule = function(self, moduleMgr, sExitModuleName, sEnterModuleName)
  -- function num : 0_4
  if sEnterModuleName == "AdventureModuleScene" then
    self.bAddBuild = false
  end
end

return FormationPanel

