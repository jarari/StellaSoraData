local RegionBossBuildPanel = class("RegionBossBuildPanel", BasePanel)
RegionBossBuildPanel._tbDefine = {
{sPrefabPath = "RegionBossFormationEx/RegionBossBuildPanel.prefab", sCtrlName = "Game.UI.RegionBossFormationEx.RegionBossBuildCtrl"}
}
RegionBossBuildPanel.Awake = function(self)
  -- function num : 0_0 , upvalues : _ENV
  (EventManager.Add)("EnterModule", self, self.OnEvent_EnterModule)
end

RegionBossBuildPanel.OnEnable = function(self)
  -- function num : 0_1
end

RegionBossBuildPanel.OnDisable = function(self)
  -- function num : 0_2
end

RegionBossBuildPanel.OnDestroy = function(self)
  -- function num : 0_3 , upvalues : _ENV
  (EventManager.Remove)("EnterModule", self, self.OnEvent_EnterModule)
end

RegionBossBuildPanel.OnRelease = function(self)
  -- function num : 0_4
end

RegionBossBuildPanel.OnEvent_EnterModule = function(self, moduleMgr, sExitModuleName, sEnterModuleName)
  -- function num : 0_5
  if sEnterModuleName == "AdventureModuleScene" then
    self.bAddBuild = false
  end
end

return RegionBossBuildPanel

